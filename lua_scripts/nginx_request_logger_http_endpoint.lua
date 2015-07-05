-- Http endpoint
local HttpEndpoint = {}
HttpEndpoint.__index = HttpEndpoint

function HttpEndpoint.new(endpoint_configuration)
    local self = setmetatable({}, HttpEndpoint)
    self.http_method = endpoint_configuration.http_method
    self.uri_type = endpoint_configuration.uri_type
    self.uri = endpoint_configuration.uri
    self.name = endpoint_configuration.name

    self.need_request_body_json = false
    self.request = nil
    if endpoint_configuration.request and (next(endpoint_configuration.request) ~= nil) then
        self.request = {}
        for _, request_configuration_element in ipairs(endpoint_configuration.request) do
            local process_result = self:process_request_configuration(request_configuration_element)
            self.need_request_body_json = self.need_request_body_json or process_result.need_request_body_json
            table.insert(self.request, { name = request_configuration_element.name, processor = process_result.processor })
        end
    end

    self.need_response_body_json = false
    self.response = nil
    if endpoint_configuration.response and (next(endpoint_configuration.response) ~= nil) then
        self.response = {}
        for _, response_configuration_element in ipairs(endpoint_configuration.response) do
            local process_result = self:process_response_configuration(response_configuration_element)
            self.need_response_body_json = self.need_response_body_json or process_result.need_response_body_json
            table.insert(self.response, { name = response_configuration_element.name, processor = process_result.processor })
        end
    end

    return self
end

function HttpEndpoint.process_request_configuration(self, request_configuration_element)
    local request_type = request_configuration_element.type
    if request_type == "uri_regex" then
        return {
            need_request_body_json = false,
            processor = self:create_uri_regex_request_function(request_configuration_element.configuration)
        }
    elseif request_type == "post_arg" then
        return {
            need_request_body_json = false,
            processor = self:create_post_arg_request_function(request_configuration_element.configuration)
        }
    elseif request_type == "json_body" then
        return {
            need_request_body_json = true,
            processor = self:create_json_body_param_function(request_configuration_element.configuration)
        }
    elseif request_type == "query" then
        return {
            need_request_body_json = false,
            processor = self:create_query_request_function(request_configuration_element.configuration)
        }
    elseif request_type == "header" then
        return {
            need_request_body_json = false,
            processor = self:create_header_param_function(request_configuration_element.configuration)
        }
    else
        error("Unknown request type [" .. request_type .. "]")
    end
end


function HttpEndpoint.process_response_configuration(self, reponse_configuration_element)
    local response_type = reponse_configuration_element.type
    if response_type == "json_body" then
        return {
            need_response_body_json = true,
            processor = self:create_json_body_param_function(reponse_configuration_element.configuration)
        }
    elseif response_type == "header" then
        return {
            need_response_body_json = false,
            processor = self:create_header_param_function(reponse_configuration_element.configuration)
        }
    else
        error("Unknown response type [" .. response_type .. "]")
    end
end

function HttpEndpoint.create_uri_regex_request_function(self, request_configuration_element)
    local match_index = request_configuration_element.match_index + 2
    return function(arguments)
        return arguments.match_result[match_index]
    end
end


function HttpEndpoint.create_post_arg_request_function(self, request_configuration_element)
    local parameter_name = request_configuration_element.parameter_name
    return function(arguments)
        local args = arguments.post_args
        if args then
            return args[parameter_name]
        else
            return nil
        end
    end
end

function HttpEndpoint.create_json_body_param_function(self, param_configuration_element)
    local path = param_configuration_element.path
    return function(arguments)
        if arguments.json_body then
            local current_body_part = arguments.json_body
            for _, current_key in ipairs(path) do
                if current_body_part then
                    current_body_part = current_body_part[current_key]
                end
            end
            return current_body_part
        else
            return nil
        end
    end
end

function HttpEndpoint.create_query_request_function(self, request_configuration_element)
    local parameter_name = request_configuration_element.parameter_name
    return function(arguments)
        return arguments.uri_args[parameter_name]
    end
end

function HttpEndpoint.create_header_param_function(self, param_configuration_element)
    local header_name = param_configuration_element.header_name
    return function(arguments)
        return arguments.headers[header_name]
    end
end


-- Check it the current call match the service
function HttpEndpoint.match_current_call(self, http_method, uri, matcher)
    if http_method == self.http_method then
        if self.uri_type == "plain" then
            return uri == self.uri
        else
            -- regex type
            return matcher.match(uri, self.uri, "ao")
        end
    else
        return false
    end
end

function HttpEndpoint.process_before_call(self, ngx, match_result)
    if self.request then
        local headers = ngx.req.get_headers()
        local values = {
            match_result = match_result,
            headers = headers,
            uri_args = ngx.req.get_uri_args(),
            post_args = ngx.req.get_post_args()
        }
        if self.need_request_body_json then
            self:add_json_body(headers, ngx.var.request_body, values)
        end
        return self:process_call(self.request, values)
    else
        return {}
    end
end

function HttpEndpoint.process_after_call(self, ngx, response_body)
    if self.response then
        local headers = ngx.resp.get_headers()
        local values = { headers = headers }
        if self.need_response_body then
            self:add_json_body(headers, response_body, values)
        end
        return self:process_call(self.response, values)
    else
        return {}
    end
end

function HttpEndpoint.add_json_body(self, headers, body, values)
    if body then
        local content_type = headers["Content-Type"]
        if (content_type == "application/json") then
            pcall(function()
                values.json_body = cjson.decode(body)
            end)
        end
    end
end

function HttpEndpoint.process_call(self, parameters, arguments)
    local result_params = {}
    for _, parameter in ipairs(parameters) do
        local result = parameter.processor(arguments)
        if result then
            result_params[parameter.name] = result
        end
    end
    return result_params
end

function HttpEndpoint.need_response_body(self)
    return self.need_response_body_json
end

return HttpEndpoint
-- Rest services
local RestServiceLogging = {}
RestServiceLogging.__index = RestServiceLogging

function RestServiceLogging.new(configuration)
    local self = setmetatable({}, RestServiceLogging)
    self.name = configuration.name
    self.uri = configuration.uri

    self.uri_type = self:process_uri_type_configuration(configuration.uri_type)

    self.http_method = (configuration.http_method or 'GET')
    self.method = configuration.method
    if configuration.request and (next(configuration.request) ~= nill) then
        self.request = self:process_request(configuration.request)
    end
    if configuration.response and (next(configuration.response) ~= nill) then
        self.response = configuration.response
    end

    self.description = "REST [" .. self.name .. "] "
    return self
end

local valid_uri_types = { plain = true, regex = true }
function RestServiceLogging.process_uri_type_configuration(self, uri_type)
    if uri_type then
        if valid_uri_types[uri_type] then
            return uri_type
        else
            error("Unknown uri type [" .. uri_type .. "] valid values are " .. table.concat(valid_uri_types, " ") .. " for service " .. self.name)
        end
    else
        return "plain"
    end
end

function RestServiceLogging.process_request_configuration(self, request_configuration)
    local request = {}
    local request_elements_names = {}
    for _, request_configuration_element in ipairs(request_configuration) do
        local processed_request_configuration_element = self:process_request_element_configuration(request_configuration_element)
        table.insert(request, processed_request_configuration_element)
        local current_request_name = processed_request_configuration_element.name
        if request_elements_names[current_request_name] then
            error("Duplicated request name [" .. current_request_name .. "] for service " .. self.name)
        end
        table.insert(request_elements_names, current_request_name)
    end
    return request
end

function RestServiceLogging.process_response(self, response_configuration)
    local response = {}
    local reponse_element_names = {}
    for _, response_configuration_element in ipairs(response_configuration) do
        local processed_response_configuration_element = self:process_response_element_configuration(response_configuration_element)
        table.insert(response, processed_response_configuration_element)
        local current_response_name = processed_response_configuration_element.name
        if reponse_element_names[processed_response_configuration_element] then
            error("Duplicated response name [" .. current_response_name .. "] for service " .. self.name)
        end
        table.insert(reponse_element_names, current_response_name)
    end
    return response
end

local valid_request_types = { uri_regex = true, post_arg = true, json_body = true, query = true, header = true }
function RestServiceLogging.process_request_element_configuration(self, request_configuration_element)
    if request_configuration_element.name == nill then
        error("Missing request name for service [" + self.name .. "]")
    end

    local request_type = request_configuration_element.type
    if request_type then
        if valid_request_types[request_type] then
            if request_configuration_element.type == "uri_regex" then
                self:process_request_configuration_uri_regex(request_configuration_element)
            elseif request_type == "post_arg" then
                self:process_request_configuration_post_arg(request_configuration_element)
            elseif request_type == "json_body" then
                self:process_request_configuration_json_body(request_configuration_element)
            elseif request_type == "query" then
                self:process_request_configuration_query(request_configuration_element)
            elseif request_type == "header" then
                self:process_request_configuration_header(request_configuration_element)
            end
            return request_configuration_element
        else
            error("Unknown request type [" .. request_type .. "] valid values are " .. table.concat(valid_request_types, " ") .. " for service " .. self.name)
        end
    else
        error("No request type for service " .. self.name)
    end
end

function RestServiceLogging.error_if_request_param_is_missing(self, request_configuration_element, param_name)
    if request_configuration_element.param_name == nill then
        error("Missing " .. param_name .. " parameter for request parameter " .. request_configuration_element.name)
    end
end

function RestServiceLogging.process_request_configuration_uri_regex(self, request_configuration_element)
    if self.uri_type ~= "regex" then
        error("uri_regex parameters are only supported for regex uri for service " .. request_configuration_element.name)
    else
        self:error_if_request_param_is_missing(request_configuration_element, "match_index")
    end
end

function RestServiceLogging.process_request_configuration_post_arg(self, request_configuration_element)
    self:error_if_request_param_is_missing(request_configuration_element, "parameter_name")
end

function RestServiceLogging.process_request_configuration_json_body(self, request_configuration_element)
    self:error_if_request_param_is_missing(request_configuration_element, "path")
end

function RestServiceLogging.process_request_configuration_query(self, request_configuration_element)
    self:error_if_request_param_is_missing(request_configuration_element, "parameter_name")
end

function RestServiceLogging.process_request_configuration_header(self, request_configuration_element)
    self:error_if_request_param_is_missing(request_configuration_element, "header_name")
end

local valid_response_types = { json_body = true, header = true }
function RestServiceLogging.process_response_element_configuration(self, response_configuration_element)
    if response_configuration_element.name == nill then
        error("Missing response name for service [" + self.name .. "]")
    end

    local response_type = response_configuration_element.type
    if response_type then
        if valid_response_types[response_type] then
            if response_type == "json_body" then
                self:process_response_configuration_json_body(request_configuration_element)
            elseif response_type == "header" then
                self:process_response_configuration_header(request_configuration_element)
            end
            return request_configuration_element
        else
            error("Unknown request type [" .. request_type .. "] valid values are " .. table.concat(valid_request_types, " ") .. " for service " .. self.name)
        end
    else
        error("No request type for service " .. self.name)
    end
end

function RestServiceLogging.error_if_response_param_is_missing(self, response_configuration_element, param_name)
    if response_configuration_element.param_name == nill then
        error("Missing " .. param_name .. " parameter for response parameter " .. response_configuration_element.name)
    end
end

function RestServiceLogging.process_response_configuration_json_body(self, response_configuration_element)
    self:error_if_response_param_is_missing(response_configuration_element, "path")
end

function RestServiceLogging.process_response_configuration_header(self, response_configuration_element)
    self:error_if_response_param_is_missing(response_configuration_element, "header_name")
end


-- Check it the current call match the service
function RestServiceLogging.match_current_call(self, http_method, uri, matcher)
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

function RestServiceLogging.process_before_call(self, match_result, headers, content)
    return self:process_call(headers, content, match_result, self.request)
end

function RestServiceLogging.process_after_call(self, nill, headers, content)
    return self:process_call(headers, content, match_result, self.response)
end

function RestServiceLogging.process_call(self, headers, raw_body, match_result, parameters)
    if parameters then
        local content_type = headers["Content-Type"]
        if (content_type == "application/json") then
            if raw_body then
                local parsed_body = cjson.decode(raw_body)
                local result_params = {}
                for _, param_configuration in ipairs(parameters) do
                    result_params[param_configuration.name] = parsed_body[param_configuration.path]
                end
                return result_params
            end
        end
    end
    return nill
end

function RestServiceLogging.description(self)
    return self.description
end

function RestServiceLogging.require_response(self)
    return self.response
end

return RestServiceLogging
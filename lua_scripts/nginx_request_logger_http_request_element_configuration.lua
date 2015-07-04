-- Read request element configuration
local HttpRequestElementConfiguration = {}
HttpRequestElementConfiguration.__index = HttpRequestElementConfiguration

function HttpRequestElementConfiguration.new(endpoint_configuration, request_element_configuration)
    local self = setmetatable({}, HttpRequestElementConfiguration)

    if request_element_configuration.name == nill then
        error("Request without name " .. cjson.encode(request_element_configuration))
    end
    self.name = request_element_configuration.name

    self.type = self:read_element_type(request_element_configuration)

    self:read_request_element_configuration(endpoint_configuration, request_element_configuration)

    self.configuration = request_element_configuration

    return self
end

local valid_request_types = {uri_regex = true, post_arg = true, json_body = true, query = true, header = true }
function HttpRequestElementConfiguration.read_element_type(self, request_element_configuration)
    local request_type = request_element_configuration.type
    if request_type then
        if valid_request_types[request_type] == nill then
            error("Unknown type [" .. endpoint_type .. "] valid values are " .. table.concat(valid_request_types, " ") .. " for request " .. self.name)
        end
        return request_type
    else
        error("No type for request " .. self.name)
    end
end

function HttpRequestElementConfiguration.read_request_element_configuration(self, endpoint_configuration, request_element_configuration)
    if self.type == "uri_regex" then
        self:read_uri_regex(endpoint_configuration, request_element_configuration)
    elseif request_type == "post_arg" then
        self:read_post_arg(request_element_configuration)
    elseif request_type == "json_body" then
        self:read_json_body(request_element_configuration)
    elseif request_type == "query" then
        self:read_query(request_element_configuration)
    elseif request_type == "header" then
        self:read_header(request_element_configuration)
    end
end

function HttpRequestElementConfiguration.error_if_request_param_is_missing(self, request_element_configuration, param_name)
    if request_element_configuration[param_name] == nill then
        error("Missing " .. param_name .. " parameter for request parameter " .. self.name .. " " .. cjson.encode(request_element_configuration))
    end
end

function HttpRequestElementConfiguration.read_uri_regex(self, endpoint_configuration, request_element_configuration)
    if endpoint_configuration.uri_type ~= "regex" then
        error("uri_regex request are only supported for regex uri for request " .. self.name)
    else
        self:error_if_request_param_is_missing(request_element_configuration, "match_index")
    end
end

function HttpRequestElementConfiguration.read_post_arg(self, request_element_configuration)
    self:error_if_request_param_is_missing(request_element_configuration, "parameter_name")
end

function HttpRequestElementConfiguration.read_json_body(self, request_element_configuration)
    self:error_if_request_param_is_missing(request_element_configuration, "path")
end

function HttpRequestElementConfiguration.read_query(self, request_element_configuration)
    self:error_if_request_param_is_missing(request_element_configuration, "parameter_name")
end

function HttpRequestElementConfiguration.read_header(self, request_element_configuration)
    self:error_if_request_param_is_missing(request_element_configuration, "header_name")
end

return HttpRequestElementConfiguration
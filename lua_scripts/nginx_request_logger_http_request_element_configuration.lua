local NginxRequestLoggerHelper = require("nginx_request_logger_helper")

-- Read request element configuration
local HttpRequestElementConfiguration = {}
HttpRequestElementConfiguration.__index = HttpRequestElementConfiguration

function HttpRequestElementConfiguration.new(endpoint_configuration, request_element_configuration)
    local self = setmetatable({}, HttpRequestElementConfiguration)

    if request_element_configuration.name == nil then
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
        if valid_request_types[request_type] == nil then
            error("Unknown type [" .. request_type .. "] valid values are " .. NginxRequestLoggerHelper.concat_table_keys(valid_request_types, " ") .. " for request " .. self.name)
        end
        return request_type
    else
        error("No type for request " .. self.name)
    end
end

function HttpRequestElementConfiguration.read_request_element_configuration(self, endpoint_configuration, request_element_configuration)
    local request_type = self.type
    if request_type == "uri_regex" then
        self:read_uri_regex(endpoint_configuration, request_element_configuration)
    elseif request_type == "post_arg" then
        self:check_param_is_missing(request_element_configuration, "parameter_name")
    elseif request_type == "json_body" then
        self:check_param_is_missing(request_element_configuration, "path")
    elseif request_type == "query" then
        self:check_param_is_missing(request_element_configuration, "parameter_name")
    elseif request_type == "header" then
        self:check_param_is_missing(request_element_configuration, "header_name")
    else
        error("Unknown request type [" .. request_type .. "]")
    end
end

function HttpRequestElementConfiguration.check_param_is_missing(self, request_element_configuration, param_name)
    NginxRequestLoggerHelper.error_if_param_is_missing(self.name, "request", request_element_configuration, param_name)
end

function HttpRequestElementConfiguration.read_uri_regex(self, endpoint_configuration, request_element_configuration)
    if endpoint_configuration.uri_type ~= "regex" then
        error("uri_regex request are only supported for regex uri for request " .. self.name)
    else
        self:check_param_is_missing(request_element_configuration, "match_index")
    end
end

return HttpRequestElementConfiguration
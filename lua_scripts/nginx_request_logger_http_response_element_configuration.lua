local NginxRequestLoggerHelper = require("nginx_request_logger_helper")

-- Read response element configuration
local HttpResponseElementConfiguration = {}
HttpResponseElementConfiguration.__index = HttpResponseElementConfiguration

function HttpResponseElementConfiguration.new(endpoint_configuration, response_element_configuration)
    local self = setmetatable({}, HttpResponseElementConfiguration)

    if response_element_configuration.name == nill then
        error("Response without name " .. cjson.encode(response_element_configuration))
    end
    self.name = response_element_configuration.name

    self.type = self:read_element_type(response_element_configuration)

    self:read_response_element_configuration(endpoint_configuration, response_element_configuration)

    self.configuration = response_element_configuration

    return self
end

local valid_response_types = { header = true, json_body = true }
function HttpResponseElementConfiguration.read_element_type(self, response_element_configuration)
    local response_type = response_element_configuration.type
    if response_type then
        if valid_response_types[response_type] == nill then
            error("Unknown type [" .. response_type .. "] valid values are " .. NginxRequestLoggerHelper.concat_table_keys(valid_response_types, " ") .. " for response " .. self.name)
        end
        return response_type
    else
        error("No type for response " .. self.name)
    end
end

function HttpResponseElementConfiguration.read_response_element_configuration(self, endpoint_configuration, response_element_configuration)
    local response_type = self.type
    if response_type == "header" then
        self:read_header(response_element_configuration)
    elseif response_type == "json_body" then
        self:read_json_body(response_element_configuration)
    else
        error("Unknown response type [" .. response_type .. "]")
    end
end

function HttpResponseElementConfiguration.error_if_response_param_is_missing(self, response_element_configuration, param_name)
    if response_element_configuration[param_name] == nill then
        error("Missing " .. param_name .. " parameter for response parameter " .. self.name .. " " .. cjson.encode(response_element_configuration))
    end
end

function HttpResponseElementConfiguration.read_header(self, response_element_configuration)
    self:error_if_response_param_is_missing(response_element_configuration, "header_name")
end

function HttpResponseElementConfiguration.read_json_body(self, response_element_configuration)
    self:error_if_response_param_is_missing(response_element_configuration, "path")
end

return HttpResponseElementConfiguration
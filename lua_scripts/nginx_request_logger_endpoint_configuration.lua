local NginxRequestLoggerHelper = require("nginx_request_logger_helper")
local HttpRequestElementConfiguration = require("nginx_request_logger_http_request_element_configuration")
local HttpResponseElementConfiguration = require("nginx_request_logger_http_response_element_configuration")

-- Read endpoint configuration
local EndpointConfiguration = {}
EndpointConfiguration.__index = EndpointConfiguration

function EndpointConfiguration.new(configuration)
    local self = setmetatable({}, EndpointConfiguration)

    if configuration.name == nill then
        error("Endpoint without name " .. cjson.encode(configuration))
    end
    self.name = configuration.name

    if configuration.uri == nill then
        error("No uri for service " .. self.name)
    end
    self.uri = configuration.uri

    self.uri_type = self:read_uri_type(configuration)

    self.http_method = (configuration.http_method or 'GET')

    if configuration.request and (next(configuration.request) ~= nill) then
        self.request = self:process_configuration(configuration.request, "request", HttpRequestElementConfiguration)
    end

    if configuration.response and (next(configuration.response) ~= nill) then
        self.response = self:process_configuration(configuration.response, "response", HttpResponseElementConfiguration)
    end

    return self
end

local valid_uri_types = { plain = true, regex = true }
function EndpointConfiguration.read_uri_type(self, configuration)
    local uri_type = configuration.uri_type
    if uri_type then
        if valid_uri_types[uri_type] then
            return uri_type
        else
            error("Unknown uri type [" .. uri_type .. "] valid values are " .. NginxRequestLoggerHelper.concat_table_keys(valid_uri_types, " ") .. " for service " .. self.name)
        end
    else
        return "plain"
    end
end

function EndpointConfiguration.process_configuration(self, configuration, element_type, element_class)
    local elements = {}
    local elements_names = {}
    for _, configuration_element in ipairs(configuration) do
        local element_configuration = element_class.new(self, configuration_element)
        if elements_names[element_configuration.name] then
            error("Duplicated " .. element_type .. " name [" .. element_configuration.name .. "] for service " .. self.name)
        end
        elements_names[element_configuration.name] = true
        table.insert(elements, element_configuration)
    end
    return elements
end

return EndpointConfiguration
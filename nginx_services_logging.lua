-- Rest services
local RestServiceLogging = {}
RestServiceLogging.__index = RestServiceLogging

function RestServiceLogging.new(configuration)
    local self = setmetatable({}, RestServiceLogging)
    self.name = configuration.name
    self.uri = configuration.uri
    self.uri_type = (configuration.uri_type or 'GET')
    self.method = configuration.method
    self.params = configuration.params
    self.description = "REST [" .. self.name .. "]"
    return self
end

-- Check it the current call match the service
function RestServiceLogging.match_current_call(self)
    if ngx.req.get_method() == self.method then
        if ngx.var.uri == self.uri then
            return true
        end
    else
        return false
    end
end

-- process the current call
function RestServiceLogging.process_current_call(self)
    local content_type = ngx.req.get_headers()["Content-type"]

    if (content_type == "application/json") then
        local raw_body = ngx.var.request_body
        if raw_body then
            local parsed_body = cjson.decode(raw_body)
            local result_params = {}
            for index, param_configuration in ipairs(self.params) do
                result_params[param_configuration.name] = parsed_body[param_configuration.path]
            end
            return result_params
        end
    end
    return nil
end

function RestServiceLogging.description(self)
    return self.description
end

local NginxServicesLogging = {}
NginxServicesLogging.__index = NginxServicesLogging

function NginxServicesLogging.new(configuration_path)
    local self = setmetatable({}, NginxServicesLogging)

    ngx.log(ngx.INFO, "Initializing services_logging")
    ngx.log(ngx.INFO, "Reading configuration at [" .. configuration_path .. "]")
    local configuration = cjson.decode(self.read_file(configuration_path))
    ngx.log(ngx.INFO, cjson.encode(configuration))
    self.correlation_id = configuration['correlationId']
    if self.correlation_id then
        ngx.log(ngx.INFO, "Correlation id enabled and will use header [" .. self.correlation_id .. "]")
    end

    -- read rest services configurations
    self.logging_services = {}
    if configuration['services'] and configuration['services']['rest'] and (next(configuration['services']['rest']) ~= nil) then
        for index, service_configuration in ipairs(configuration['services']['rest']) do
            table.insert(self.logging_services, RestServiceLogging.new(service_configuration))
        end
    end

    return self
end

function NginxServicesLogging.read_file(file)
    local f = io.open(file, "rb")
    local content = f:read("*all")
    f:close()
    return content
end

-- call at each call
function NginxServicesLogging.access_by_lua(self)
    if self.correlation_id then
        ngx.req.set_header(self.correlation_id, uuid())
    end

    local logging_service = self:find_logging_service()
    if logging_service then
        local logging_result = logging_service:process_current_call()
        if logging_result then
            ngx.log(ngx.INFO, "Service logging " .. logging_service.description .. cjson.encode(logging_result))
        end
    else
        ngx.log(ngx.DEBUG, "No service logging found")
    end
end


-- Fin the logging service that match the current call
function NginxServicesLogging.find_logging_service(self)
    for index, logging_service in ipairs(self.logging_services) do
        if logging_service:match_current_call() then
            return logging_service
        end
    end
    -- not found
    return nil
end

return NginxServicesLogging
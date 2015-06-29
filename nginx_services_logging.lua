-- Rest services
local RestServiceLogging = {}
RestServiceLogging.__index = RestServiceLogging

function RestServiceLogging.new(configuration)
    local self = setmetatable({}, RestServiceLogging)
    self.name = configuration.name
    self.uri = configuration.uri
    self.uri_type = (configuration.uri_type or 'GET')
    self.method = configuration.method
    if configuration.request and (next(configuration.request) ~= nill) then
        self.request = configuration.request
    end
    if configuration.response and (next(configuration.response) ~= nill) then
        self.response = configuration.response
    end

    self.description = "REST [" .. self.name .. "] "
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

function RestServiceLogging.process_before_call(self)
    return self:process_call(ngx.req.get_headers(), ngx.var.request_body, self.request)
end

function RestServiceLogging.process_after_call(self)
    return self:process_call(ngx.resp.get_headers(), table.concat(ngx.ctx.buffered_content), self.response)
end

function RestServiceLogging.process_call(self, headers, raw_body, parameters)
    if parameters then
        local content_type = headers["Content-Type"]
        if (content_type == "application/json") then
            if raw_body then
                local parsed_body = cjson.decode(raw_body)
                local result_params = {}
                for index, param_configuration in ipairs(parameters) do
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

-- read the content of a file, used for the configuration
function NginxServicesLogging.read_file(file)
    local f = io.open(file, "rb")
    local content = f:read("*all")
    f:close()
    return content
end

function NginxServicesLogging.before_call(self)
    local correlation_id = nill
    if self.correlation_id then
        correlation_id = uuid()
        ngx.req.set_header(self.correlation_id, correlation_id)
        ngx.ctx.correlation_id = correlation_id
    end

    local logging_service = self:find_logging_service()
    if logging_service then
        local before_call_result = logging_service:process_before_call()
        if before_call_result then
            local message = "Service logging "
            if correlation_id then
                message = message .. correlation_id .. " "
            end
            message = message .. logging_service.description .. cjson.encode(before_call_result)
            ngx.log(ngx.INFO, message)
        end

        ngx.ctx.logging_service = logging_service
        ngx.ctx.before_call_result = before_call_result
        if logging_service:require_response() then
            ngx.ctx.buffered_content = {}
        end
    elseif correlation_id then
        ngx.log(ngx.DEBUG, "No service logging found " .. correlation_id)
    else
        ngx.log(ngx.DEBUG, "No service logging found")
    end
end

function NginxServicesLogging.body_filter(self)
    if ngx.ctx.buffered_content then
        table.insert(ngx.ctx.buffered_content, ngx.arg[1])
    end
end

function NginxServicesLogging.after_call(self)
    local logging_service = ngx.ctx.logging_service
    if logging_service then
        local after_call_result = nill
        if ngx.ctx.buffered_content then
            after_call_result = logging_service:process_after_call()
        end
        local message = "Service logging "
        if ngx.ctx.correlation_id then
            message = message .. ngx.ctx.correlation_id .. " "
        end
        message = message .. logging_service.description .. cjson.encode(ngx.ctx.before_call_result) .. " " .. cjson.encode(after_call_result)
        ngx.log(ngx.INFO, message)
    elseif self.correlation_id then
        ngx.log(ngx.DEBUG, "No service logging found " .. correlation_id)
    else
        ngx.log(ngx.DEBUG, "No service logging found")
    end
end

-- Find the logging service that match the current call
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
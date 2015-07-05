-- main entry point

-- required to process json
cjson = require("cjson")

-- required for uuid
uuid = require("uuid")
uuid.randomseed(ngx.now())

local EndpointConfiguration = require("nginx_request_logger_endpoint_configuration")
local HttpEndpoint = require("nginx_request_logger_http_endpoint")

local NginxRequestLogger = {}
NginxRequestLogger.__index = NginxRequestLogger

function NginxRequestLogger.new(configuration_path)
    local self = setmetatable({}, NginxRequestLogger)

    ngx.log(ngx.INFO, "Initializing nginx_request_logger")
    ngx.log(ngx.INFO, "Reading configuration at [" .. configuration_path .. "]")
    local configuration = cjson.decode(self.read_file(configuration_path))
    ngx.log(ngx.INFO, cjson.encode(configuration))
    self.correlation_id = configuration['correlationId']
    if self.correlation_id then
        ngx.log(ngx.INFO, "Correlation id enabled and will use header [" .. self.correlation_id .. "]")
    end
    self.force_correlation_id = configuration['forceCorrelationId']
    if self.force_correlation_id then
        ngx.log(ngx.INFO, "Force correlation id is enabled")
    end

    self.endpoints = {}
    if configuration['endpoints'] and (next(configuration['endpoints']) ~= nil) then
        for _, endpoint_configuration in ipairs(configuration['endpoints']) do
            local endpoint_configuration = EndpointConfiguration.new(endpoint_configuration)
            local endpoint = HttpEndpoint.new(endpoint_configuration)
            table.insert(self.endpoints, endpoint)
        end
    end

    return self
end

-- read the content of a file, used for the configuration
function NginxRequestLogger.read_file(file)
    local f = io.open(file, "rb")
    if f == nil then
        error("Configuration file not found at [" .. file .. "]")
    end
    local content = f:read("*all")
    f:close()
    return content
end

function NginxRequestLogger.before_call(self)
    if self.correlation_id then
        local skip_correlation_id = ngx.req.get_headers()[self.correlation_id] and (not self.force_correlation_id)
        if not skip_correlation_id then
            local correlation_id = uuid()
            ngx.req.set_header(self.correlation_id, correlation_id)
            ngx.ctx.correlation_id = correlation_id
        end
    end

    local endpoint, match_result = self:find_endpoint()
    if endpoint then
        local before_call_result = endpoint:process_before_call(ngx, match_result)
        if before_call_result then
            local message = "Service logging "
            if correlation_id then
                message = message .. correlation_id .. " "
            end
            message = message .. endpoint.name .. " " .. cjson.encode(before_call_result)
            ngx.log(ngx.INFO, message)
        end

        ngx.ctx.endpoint = endpoint
        ngx.ctx.before_call_result = before_call_result
        if endpoint.need_response_body then
            ngx.ctx.buffered_content = {}
        end
    elseif correlation_id then
        ngx.log(ngx.DEBUG, correlation_id .. "No service logging found")
    else
        ngx.log(ngx.DEBUG, "No service logging found")
    end
end

function NginxRequestLogger.body_filter(self)
    if ngx.ctx.buffered_content then
        table.insert(ngx.ctx.buffered_content, ngx.arg[1])
    end
end

function NginxRequestLogger.after_call(self)
    local endpoint = ngx.ctx.endpoint
    if endpoint then
        local response_body
        if ngx.ctx.buffered_content then
            response_body = table.concat(ngx.ctx.buffered_content)
        end
        local after_call_result = endpoint:process_after_call(ngx, response_body)

        local message = "Service logging "
        if ngx.ctx.correlation_id then
            message = message .. ngx.ctx.correlation_id .. " "
        end
        message = message .. endpoint.name .. " " .. cjson.encode(ngx.ctx.before_call_result) .. " " .. cjson.encode(after_call_result)
        ngx.log(ngx.INFO, message)
    elseif ngx.ctx.correlation_id then
        ngx.log(ngx.DEBUG, ngx.ctx.correlation_id .. " No service logging found")
    else
        ngx.log(ngx.DEBUG, "No service logging found")
    end
end

-- Find the endpoint that match the current call
function NginxRequestLogger.find_endpoint(self)
    for _, endpoint in ipairs(self.endpoints) do
        local match_result = endpoint:match_current_call(ngx.req.get_method(), ngx.var.uri, ngx.re)
        if match_result then
            return endpoint, match_result
        end
    end
    -- not found
    return nil
end

return NginxRequestLogger
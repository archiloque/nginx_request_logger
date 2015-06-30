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
function RestServiceLogging.match_current_call(self, method, uri)
    if method == self.method then
        if uri == self.uri then
            return true
        end
    else
        return false
    end
end

function RestServiceLogging.process_before_call(self, headers, content)
    return self:process_call(ngx.req.get_headers(), ngx.var.request_body, self.request)
end

function RestServiceLogging.process_after_call(self, headers, content)
    return self:process_call(headers, content, self.response)
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

return RestServiceLogging
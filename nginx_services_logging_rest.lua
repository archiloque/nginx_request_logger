-- Rest services
local RestServiceLogging = {}
RestServiceLogging.__index = RestServiceLogging

local valid_uri_types = { plain = true, regex = true }

function RestServiceLogging.new(configuration)
    local self = setmetatable({}, RestServiceLogging)
    self.name = configuration.name
    self.uri = configuration.uri

    if configuration.uri_type then
        if valid_uri_types[configuration.uri_type] then
            self.uri_type = configuration.uri_type
        else
            error("Unknown uri type [" .. configuration.self.uri .. "] valid values are " .. table.concat(valid_uri_types, " "))
        end
    else
        self.uri_type = "plain"
    end

    self.http_method = (configuration.http_method or 'GET')
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
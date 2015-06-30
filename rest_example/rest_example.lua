#!    /usr/bin/env wsapi.cgi

local orbit = require("orbit")
local cjson = require("cjson")

module("rest_example", package.seeall, orbit.new)

function log(web)
    local env_info = {}
    for k, v in pairs(web.vars) do
        if type(v) == "string" then
            env_info[k] = v
        end
    end

    print(web.path_info .. " " .. web.method .. " " .. cjson.encode(web.input) .. " " .. cjson.encode(env_info))
end

function json_get_ok_1(web)
    log(web)
    web:content_type('application/json')
    return cjson.encode({ code = 1 })
end

function json_post_ok(web)
    log(web)
    web:content_type('application/json')
    return cjson.encode({ code = 1 })
end

function json_put_ok(web)
    log(web)
    web:content_type('application/json')
    return cjson.encode({ code = 1 })
end

function json_get_ko(web)
    log(web)
    web:status("500")
    web:content_type('application/json')
    return cjson.encode({ code = 1 })
end

function json_post_ko(web)
    log(web)
    web:status("500")
    web:content_type('application/json')
    return cjson.encode({ code = 1 })
end

function json_put_ko(web)
    log(web)
    web:status("500")
    web:content_type('application/json')
    return cjson.encode({ code = 1 })
end

-- Builds the application's dispatch table, you can
-- pass multiple patterns, and any captures get passed to
-- the controller

rest_example:dispatch_get(json_get_ok_1, "/json/ok/1")
rest_example:dispatch_post(json_post_ok, "/json/ok")
rest_example:dispatch_put(json_put_ok, "/json/ok")

rest_example:dispatch_get(json_get_ko, "/json/ko")
rest_example:dispatch_post(json_post_ko, "/json/ko")
rest_example:dispatch_put(json_put_ko, "/json/ko")

return _M

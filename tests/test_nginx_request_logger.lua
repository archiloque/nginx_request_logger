package.path = package.path .. ";../lua_scripts/?.lua"

luaunit = require('luaunit')
cjson = require("cjson")

HttpRequestElementConfiguration = require('nginx_request_logger_http_request_element_configuration')
HttpResponseElementConfiguration = require('nginx_request_logger_http_response_element_configuration')

TestHttpRequestElementConfiguration = {}

function TestHttpRequestElementConfiguration:testNoName()
    luaunit.assertErrorMsgContains("Request without name {}",
        HttpRequestElementConfiguration.new, {}, {})
end

function TestHttpRequestElementConfiguration:testNoType()
    luaunit.assertErrorMsgContains("No type for request request_name",
        HttpRequestElementConfiguration.new, {}, { name = "request_name" })
end

function TestHttpRequestElementConfiguration:testUnknownType()
    luaunit.assertErrorMsgContains("Unknown type [unknown_type] valid values are json_body uri_regex header post_arg query for request request_name",
        HttpRequestElementConfiguration.new, {}, { name = "request_name", type = "unknown_type" })
end

function TestHttpRequestElementConfiguration:testUriRegex()
    luaunit.assertErrorMsgContains("uri_regex request are only supported for regex uri for request request_name",
        HttpRequestElementConfiguration.new, {}, { name = "request_name", type = "uri_regex" })
    luaunit.assertErrorMsgContains("Missing match_index parameter for request parameter request_name {\"name\":\"request_name\",\"type\":\"uri_regex\"}",
        HttpRequestElementConfiguration.new, { uri_type = "regex" }, { name = "request_name", type = "uri_regex" })
    local config = HttpRequestElementConfiguration.new({ uri_type = "regex" }, { name = "request_name", type = "uri_regex", match_index = 0 })
    luaunit.assertEquals("uri_regex", config.type)
    luaunit.assertEquals("request_name", config.name)
    luaunit.assertEquals({ name = "request_name", type = "uri_regex", match_index = 0 }, config.configuration)
end

function TestHttpRequestElementConfiguration:testPostArg()
    luaunit.assertErrorMsgContains("Missing parameter_name parameter for request parameter request_name {\"name\":\"request_name\",\"type\":\"post_arg\"}",
        HttpRequestElementConfiguration.new, {}, { name = "request_name", type = "post_arg" })
    local config = HttpRequestElementConfiguration.new({}, { name = "request_name", type = "post_arg", parameter_name = "name" })
    luaunit.assertEquals("post_arg", config.type)
    luaunit.assertEquals("request_name", config.name)
    luaunit.assertEquals({ name = "request_name", type = "post_arg", parameter_name = "name" }, config.configuration)
end

function TestHttpRequestElementConfiguration:testJsonBody()
    luaunit.assertErrorMsgContains("Missing path parameter for request parameter request_name {\"name\":\"request_name\",\"type\":\"json_body\"}",
        HttpRequestElementConfiguration.new, {}, { name = "request_name", type = "json_body" })
    local config = HttpRequestElementConfiguration.new({}, { name = "request_name", type = "json_body", path = "name" })
    luaunit.assertEquals("json_body", config.type)
    luaunit.assertEquals("request_name", config.name)
    luaunit.assertEquals({ name = "request_name", type = "json_body", path = "name" }, config.configuration)
end

function TestHttpRequestElementConfiguration:testQuery()
    luaunit.assertErrorMsgContains("Missing parameter_name parameter for request parameter request_name {\"name\":\"request_name\",\"type\":\"query\"}",
        HttpRequestElementConfiguration.new, {}, { name = "request_name", type = "query" })
    local config = HttpRequestElementConfiguration.new({}, { name = "request_name", type = "query", parameter_name = "name" })
    luaunit.assertEquals("query", config.type)
    luaunit.assertEquals("request_name", config.name)
    luaunit.assertEquals({ name = "request_name", type = "query", parameter_name = "name" }, config.configuration)
end

function TestHttpRequestElementConfiguration:testHeader()
    luaunit.assertErrorMsgContains("Missing header_name parameter for request parameter request_name {\"name\":\"request_name\",\"type\":\"header\"}",
        HttpRequestElementConfiguration.new, {}, { name = "request_name", type = "header" })
    local config = HttpRequestElementConfiguration.new({}, { name = "request_name", type = "header", header_name = "name" })
    luaunit.assertEquals("header", config.type)
    luaunit.assertEquals("request_name", config.name)
    luaunit.assertEquals({ name = "request_name", type = "header", header_name = "name" }, config.configuration)
end

TestHttpResponseElementConfiguration = {}

function TestHttpResponseElementConfiguration:testNoName()
    luaunit.assertErrorMsgContains("Response without name {}",
        HttpResponseElementConfiguration.new, {}, {})
end

function TestHttpResponseElementConfiguration:testNoType()
    luaunit.assertErrorMsgContains("No type for response response_name",
        HttpResponseElementConfiguration.new, {}, { name = "response_name" })
end

function TestHttpResponseElementConfiguration:testUnknownType()
    luaunit.assertErrorMsgContains("Unknown type [unknown_type] valid values are header json_body for response response_name",
        HttpResponseElementConfiguration.new, {}, { name = "response_name", type = "unknown_type" })
end

function TestHttpResponseElementConfiguration:testJsonBody()
    luaunit.assertErrorMsgContains("Missing path parameter for response parameter response_name {\"name\":\"response_name\",\"type\":\"json_body\"}",
        HttpResponseElementConfiguration.new, {}, { name = "response_name", type = "json_body" })
    local config = HttpResponseElementConfiguration.new({}, { name = "response_name", type = "json_body", path = "name" })
    luaunit.assertEquals("json_body", config.type)
    luaunit.assertEquals("response_name", config.name)
    luaunit.assertEquals({ name = "response_name", type = "json_body", path = "name" }, config.configuration)
end

function TestHttpResponseElementConfiguration:testHeader()
    luaunit.assertErrorMsgContains("Missing header_name parameter for response parameter response_name {\"name\":\"response_name\",\"type\":\"header\"}",
        HttpResponseElementConfiguration.new, {}, { name = "response_name", type = "header" })
    local config = HttpResponseElementConfiguration.new({}, { name = "response_name", type = "header", header_name = "name" })
    luaunit.assertEquals("header", config.type)
    luaunit.assertEquals("response_name", config.name)
    luaunit.assertEquals({ name = "response_name", type = "header", header_name = "name" }, config.configuration)
end

os.exit(luaunit.LuaUnit.run())
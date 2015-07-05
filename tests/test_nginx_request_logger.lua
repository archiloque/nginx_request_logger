-- require mach mock framework

package.path = package.path .. ";../lua_scripts/?.lua"

luaunit = require('luaunit')
cjson = require("cjson")

mockagne = require "mockagne"

when = mockagne.when
any = mockagne.any
verify = mockagne.verify

EndpointConfiguration = require('nginx_request_logger_endpoint_configuration')
HttpRequestElementConfiguration = require('nginx_request_logger_http_request_element_configuration')
HttpResponseElementConfiguration = require('nginx_request_logger_http_response_element_configuration')
HttpEndpoint = require('nginx_request_logger_http_endpoint')

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

TestEndpointConfiguration = {}

function TestEndpointConfiguration:testNoName()
    luaunit.assertErrorMsgContains("Endpoint without name {}",
        EndpointConfiguration.new, {})
end

function TestEndpointConfiguration:testNoUri()
    luaunit.assertErrorMsgContains("No uri for service endpoint_name",
        EndpointConfiguration.new, { name = "endpoint_name" })
end

function TestEndpointConfiguration:testBadUriType()
    luaunit.assertErrorMsgContains("Unknown uri type [wrong_uri_type] valid values are regex plain for service endpoint_name",
        EndpointConfiguration.new, { name = "endpoint_name", uri = "/service", uri_type = "wrong_uri_type" })
end

function TestEndpointConfiguration:testDefaultValues()
    local endpoint_configuration = EndpointConfiguration.new({ name = "endpoint_name", uri = "/service" })
    luaunit.assertEquals("endpoint_name", endpoint_configuration.name)
    luaunit.assertEquals("plain", endpoint_configuration.uri_type)
    luaunit.assertEquals("/service", endpoint_configuration.uri)
    luaunit.assertEquals("GET", endpoint_configuration.http_method)
end

function TestEndpointConfiguration:testRegexUtiType()
    local endpoint_configuration = EndpointConfiguration.new({ name = "endpoint_name", uri = "/service", uri_type = "regex" })
    luaunit.assertEquals("endpoint_name", endpoint_configuration.name)
    luaunit.assertEquals("regex", endpoint_configuration.uri_type)
    luaunit.assertEquals("/service", endpoint_configuration.uri)
    luaunit.assertEquals("GET", endpoint_configuration.http_method)
end

function TestEndpointConfiguration:testHttpMethod()
    local endpoint_configuration = EndpointConfiguration.new({ name = "endpoint_name", uri = "/service", http_method = "POST" })
    luaunit.assertEquals("endpoint_name", endpoint_configuration.name)
    luaunit.assertEquals("plain", endpoint_configuration.uri_type)
    luaunit.assertEquals("/service", endpoint_configuration.uri)
    luaunit.assertEquals("POST", endpoint_configuration.http_method)
end

function TestEndpointConfiguration:testDuplicateRequest()
    local request_parameter = { name = "request", type = "header", header_name = "header_name" }
    local parameters = {
        name = "endpoint_name",
        uri = "/service",
        request = {
            request_parameter,
            request_parameter
        }
    }
    luaunit.assertErrorMsgContains("Duplicated request name [request] for service endpoint_name",
        EndpointConfiguration.new, parameters)
end

function TestEndpointConfiguration:testDuplicateResponse()
    local response_parameter = { name = "response", type = "header", header_name = "header_name" }
    local parameters = {
        name = "endpoint_name",
        uri = "/service",
        response = {
            response_parameter,
            response_parameter
        }
    }
    luaunit.assertErrorMsgContains("Duplicated response name [response] for service endpoint_name",
        EndpointConfiguration.new, parameters)
end

function TestEndpointConfiguration:testRequestAndResponse()
    local parameters = {
        name = "endpoint_name",
        uri = "/service",
        request = {
            { name = "request", type = "header", header_name = "request_header_name" }
        },
        response = {
            { name = "response", type = "header", header_name = "response_header_name" },
            response_parameter
        }
    }
    local endpoint_configuration = EndpointConfiguration.new(parameters)

    luaunit.assertEquals(1, table.getn(endpoint_configuration.request))
    local request = endpoint_configuration.request[1]
    luaunit.assertEquals("request", request.name)

    luaunit.assertEquals(1, table.getn(endpoint_configuration.response))
    local response = endpoint_configuration.response[1]
    luaunit.assertEquals("response", response.name)
end

TestHttpEndpoint = {}

function TestHttpEndpoint:testMatch()
    local endpoint_configuration = EndpointConfiguration.new({ name = "endpoint_name", uri = "/service" })
    local http_endpoint = HttpEndpoint.new(endpoint_configuration)
    luaunit.assertTrue(http_endpoint:match_current_call("GET", "/service"))
    luaunit.assertFalse(http_endpoint:match_current_call("POST", "/service"))
    luaunit.assertFalse(http_endpoint:match_current_call("GET", "/services"))
end

function TestHttpEndpoint:testMatchRegex()
    local endpoint_configuration = EndpointConfiguration.new({ name = "endpoint_name", uri = "/(+d)", uri_type = "regex" })
    local http_endpoint = HttpEndpoint.new(endpoint_configuration)

    local matcher = mockagne.getMock()
    when(matcher.match("/12", "/(+d)", "ao")).thenAnswer({ "12" })
    luaunit.assertEquals({ "12" }, http_endpoint:match_current_call("GET", "/12", matcher))
    verify(matcher.match("/12", "/(+d)", "ao"))

    luaunit.assertEquals(false, http_endpoint:match_current_call("POST", "/12", nil))

    when(matcher.match("/12", "/(+d)", "ao")).thenAnswer(nil)
    luaunit.assertEquals(nil, http_endpoint:match_current_call("GET", "/aaa", matcher))
    verify(matcher.match("/12", "/(+d)", "ao"))
end

function TestHttpEndpoint:testRequestUriRegex()
    local endpoint_configuration = EndpointConfiguration.new({
        name = "endpoint_name",
        uri = "/(+d)",
        uri_type = "regex",
        request = {
            { name = "request_name", type = "uri_regex", match_index = 0 }
        }
    })

    local req = mockagne.getMock()
    when(req.get_uri_args()).thenAnswer({})
    when(req.get_post_args()).thenAnswer({})
    when(req.get_headers()).thenAnswer({})
    local ngx = { req = req, var = { request_body = "" } }

    local http_endpoint = HttpEndpoint.new(endpoint_configuration)
    luaunit.assertEquals({ request_name = "12" }, http_endpoint:process_before_call(ngx, { "", "12" }))

    local endpoint_configuration = EndpointConfiguration.new({
        name = "endpoint_name",
        uri = "/(+d)",
        uri_type = "regex",
        request = {
            { name = "request_name", type = "uri_regex", match_index = 1 }
        }
    })

    local req = mockagne.getMock()
    when(req.get_uri_args()).thenAnswer({})
    when(req.get_post_args()).thenAnswer({})
    when(req.get_headers()).thenAnswer({})
    local ngx = { req = req, var = { request_body = "" } }

    local http_endpoint = HttpEndpoint.new(endpoint_configuration)
    luaunit.assertEquals({}, http_endpoint:process_before_call(ngx, { "", "12" }))
end

function TestHttpEndpoint:testRequestPostArg()
    local endpoint_configuration = EndpointConfiguration.new({
        name = "endpoint_name",
        uri = "/service",
        request = {
            { name = "request_name", type = "post_arg", parameter_name = "name" }
        }
    })

    local req = mockagne.getMock()
    when(req.get_uri_args()).thenAnswer({})
    when(req.get_post_args()).thenAnswer({ name = "value" }, "")
    local ngx = { req = req, var = { request_body = "" } }

    local http_endpoint = HttpEndpoint.new(endpoint_configuration)
    luaunit.assertEquals({ request_name = "value" }, http_endpoint:process_before_call(ngx, nil))

    local endpoint_configuration = EndpointConfiguration.new({
        name = "endpoint_name",
        uri = "/service",
        request = {
            { name = "request_name", type = "post_arg", parameter_name = "name" }
        }
    })

    local req = mockagne.getMock()
    when(req.get_uri_args()).thenAnswer({})
    when(req.get_post_args()).thenAnswer(nil, "Error")
    local ngx = { req = req, var = { request_body = "" } }

    local http_endpoint = HttpEndpoint.new(endpoint_configuration)
    luaunit.assertEquals({}, http_endpoint:process_before_call(ngx, nil))
end

function TestHttpEndpoint:testRequestJsonBodyOk()
    local endpoint_configuration = EndpointConfiguration.new({
        name = "endpoint_name",
        uri = "/service",
        request = {
            { name = "request_name", type = "json_body", path = { "plop", "plip" } }
        }
    })

    local req = mockagne.getMock()
    when(req.get_uri_args()).thenAnswer({})
    when(req.get_post_args()).thenAnswer({})
    local headers = {}
    headers["Content-Type"] = "application/json"
    when(req.get_headers()).thenAnswer(headers)
    local ngx = { req = req, var = { request_body = "{\"plop\": {\"plip\" : \"plap\"} }" } }

    local http_endpoint = HttpEndpoint.new(endpoint_configuration)
    luaunit.assertEquals({ request_name = "plap" }, http_endpoint:process_before_call(ngx, nil))
end

function TestHttpEndpoint:testRequestJsonBodyNotFound()
    local endpoint_configuration = EndpointConfiguration.new({
        name = "endpoint_name",
        uri = "/service",
        request = {
            { name = "request_name", type = "json_body", path = { "plop" } }
        }
    })

    local req = mockagne.getMock()
    when(req.get_uri_args()).thenAnswer({})
    when(req.get_post_args()).thenAnswer({})
    local headers = {}
    headers["Content-Type"] = "application/json"
    when(req.get_headers()).thenAnswer(headers)
    local ngx = { req = req, var = { request_body = "{}" } }

    local http_endpoint = HttpEndpoint.new(endpoint_configuration)
    luaunit.assertEquals({}, http_endpoint:process_before_call(ngx, nil))
end

function TestHttpEndpoint:testRequestJsonBodyNoContentType()
    local endpoint_configuration = EndpointConfiguration.new({
        name = "endpoint_name",
        uri = "/service",
        request = {
            { name = "request_name", type = "json_body", path = "plop" }
        }
    })

    local req = mockagne.getMock()
    when(req.get_uri_args()).thenAnswer({})
    when(req.get_post_args()).thenAnswer({})
    when(req.get_headers()).thenAnswer({})
    local ngx = { req = req, var = { request_body = "{\"plop\": \"plap\"}" } }

    local http_endpoint = HttpEndpoint.new(endpoint_configuration)
    luaunit.assertEquals({}, http_endpoint:process_before_call(ngx, nil))
end

function TestHttpEndpoint:testRequestJsonBodyInvalid()
    local endpoint_configuration = EndpointConfiguration.new({
        name = "endpoint_name",
        uri = "/service",
        request = {
            { name = "request_name", type = "json_body", path = "plop" }
        }
    })

    local req = mockagne.getMock()
    when(req.get_uri_args()).thenAnswer({})
    when(req.get_post_args()).thenAnswer({})
    local headers = {}
    headers["Content-Type"] = "application/json"
    when(req.get_headers()).thenAnswer(headers)
    local ngx = { req = req, var = { request_body = "{\"pl" } }

    local http_endpoint = HttpEndpoint.new(endpoint_configuration)
    luaunit.assertEquals({}, http_endpoint:process_before_call(ngx, nil))
end

function TestHttpEndpoint:testRequestHeader()
    local endpoint_configuration = EndpointConfiguration.new({
        name = "endpoint_name",
        uri = "/service",
        request = {
            { name = "request_name", type = "header", header_name = "my_header" }
        }
    })

    local req = mockagne.getMock()
    when(req.get_uri_args()).thenAnswer({})
    when(req.get_post_args()).thenAnswer({})
    when(req.get_headers()).thenAnswer({ my_header = "header_value" })
    local ngx = { req = req, var = { request_body = "" } }

    local http_endpoint = HttpEndpoint.new(endpoint_configuration)
    luaunit.assertEquals({ request_name = "header_value" }, http_endpoint:process_before_call(ngx, nil))

    local endpoint_configuration = EndpointConfiguration.new({
        name = "endpoint_name",
        uri = "/service",
        request = {
            { name = "request_name", type = "header", header_name = "my_header" }
        }
    })

    local req = mockagne.getMock()
    when(req.get_uri_args()).thenAnswer({})
    when(req.get_post_args()).thenAnswer({})
    when(req.get_headers()).thenAnswer({})
    local ngx = { req = req, var = { request_body = "" } }

    local http_endpoint = HttpEndpoint.new(endpoint_configuration)
    luaunit.assertEquals({}, http_endpoint:process_before_call(ngx, nil))
end

function TestHttpEndpoint:testResponseJsonBodyOk()
    local endpoint_configuration = EndpointConfiguration.new({
        name = "endpoint_name",
        uri = "/service",
        response = {
            { name = "response_name", type = "json_body", path = { "plop", "plip" } }
        }
    })

    local resp = mockagne.getMock()
    local headers = {}
    headers["Content-Type"] = "application/json"
    when(resp.get_headers()).thenAnswer(headers)
    local ngx = { resp = resp }

    local http_endpoint = HttpEndpoint.new(endpoint_configuration)
    luaunit.assertEquals({ response_name = "plap" }, http_endpoint:process_after_call(ngx, "{\"plop\": {\"plip\" : \"plap\"}}"))
end


function TestHttpEndpoint:testResponseJsonBodyNotFound()
    local endpoint_configuration = EndpointConfiguration.new({
        name = "endpoint_name",
        uri = "/service",
        response = {
            { name = "response_name", type = "json_body", path = { "plop" } }
        }
    })

    local resp = mockagne.getMock()
    local headers = {}
    headers["Content-Type"] = "application/json"
    when(resp.get_headers()).thenAnswer(headers)
    local ngx = { resp = resp }

    local http_endpoint = HttpEndpoint.new(endpoint_configuration)
    luaunit.assertEquals({}, http_endpoint:process_after_call(ngx, "{}"))
end

function TestHttpEndpoint:testResponseJsonBodyNoContentType()
    local endpoint_configuration = EndpointConfiguration.new({
        name = "endpoint_name",
        uri = "/service",
        response = {
            { name = "response_name", type = "json_body", path = "plop" }
        }
    })

    local resp = mockagne.getMock()
    when(resp.get_headers()).thenAnswer({})
    local ngx = { resp = resp }

    local http_endpoint = HttpEndpoint.new(endpoint_configuration)
    luaunit.assertEquals({}, http_endpoint:process_after_call(ngx, "{\"plop\": \"plap\"}"))
end

function TestHttpEndpoint:testResponseJsonBodyInvalid()
    local endpoint_configuration = EndpointConfiguration.new({
        name = "endpoint_name",
        uri = "/service",
        response = {
            { name = "response_name", type = "json_body", path = "plop" }
        }
    })

    local resp = mockagne.getMock()
    local headers = {}
    headers["Content-Type"] = "application/json"
    when(resp.get_headers()).thenAnswer(headers)
    local ngx = { resp = resp }

    local http_endpoint = HttpEndpoint.new(endpoint_configuration)
    luaunit.assertEquals({}, http_endpoint:process_after_call(ngx, "{\"pl"))
end

function TestHttpEndpoint:testResponseHeader()
    local endpoint_configuration = EndpointConfiguration.new({
        name = "endpoint_name",
        uri = "/service",
        response = {
            { name = "response_name", type = "header", header_name = "my_header" }
        }
    })

    local resp = mockagne.getMock()
    when(resp.get_headers()).thenAnswer({ my_header = "header_value" })
    local ngx = { resp = resp }

    local http_endpoint = HttpEndpoint.new(endpoint_configuration)
    luaunit.assertEquals({ response_name = "header_value" }, http_endpoint:process_after_call(ngx, nil))

    local endpoint_configuration = EndpointConfiguration.new({
        name = "endpoint_name",
        uri = "/service",
        response = {
            { name = "response_name", type = "header", header_name = "my_header" }
        }
    })

    local resp = mockagne.getMock()
    when(resp.get_headers()).thenAnswer({})
    local ngx = { resp = resp }

    local http_endpoint = HttpEndpoint.new(endpoint_configuration)
    luaunit.assertEquals({}, http_endpoint:process_after_call(ngx, nil))
end

os.exit(luaunit.LuaUnit.run())
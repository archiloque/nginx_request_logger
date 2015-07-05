# Nginx request logger

Lua code to log request information in Nginx. For each URL you can specify witch parameter and reponse values to logs.

This code should not be used as a final product but as a base to hack on.  

Works for:
- plain http requests
- REST services

Example :

```json
{
  "correlationId": "X-Correlation-Id",
  "forceCorrelationId": false,

  "endpoints": [
    {
      "name": "post_json_ok",
      "uri": "/json/ok",
      "http_method": "POST",
      "request": [
        {
          "name": "key_name",
          "type": "json_body",
          "path": "key"
        },
        {
          "name": "special_header",
          "type": "header",
          "header_name": "X-SPECIAL-HEADER"
        }
      ],
      "response": [
        {
          "name": "code_name",
          "path": "code",
          "type": "json_body"
        }
      ]
    },
    {
      "name": "post_json_get",
      "uri": "\\\/json\\\/ok\\\/(\\d+)",
      "uri_type": "regex",
      "http_method": "GET",
      "request": [
        {
          "name": "id",
          "match_index": 0,
          "type": "uri_regex"
        }
      ]
    }
  ]
}
```

Result
```
2015/06/30 23:22:59 [info] 39499#0: *67 [lua] nginx_services_logging.lua:61: before_call(): Service logging 86f59a44-6519-4323-c3bb-9a15c6f62e3c REST [post_json_ok] {"key_name":"value"}, client: 127.0.0.1, server: localhost, request: "POST /json/ok HTTP/1.1", host: "localhost:8081"
2015/06/30 23:22:59 [info] 39499#0: *67 [lua] nginx_services_logging.lua:94: after_call(): Service logging 86f59a44-6519-4323-c3bb-9a15c6f62e3c REST [post_json_ok] {"key_name":"value"} {"code_name":1} while logging request, client: 127.0.0.1, server: localhost, request: "POST /json/ok HTTP/1.1", upstream: "http://127.0.0.1:9292/json/ok", host: "localhost:8081"
```
When doing a request :
- we iterate on all endpoints, finding the first that match
- if finding one:
  - apply all the `request` values to extract parameters from the request, then logging them
  - apply all the `response` values to extract parameters from the response, then logging everything

You can can have a look [here](http://ryandlane.com/blog/2014/12/11/using-lua-in-nginx-for-unique-request-ids-and-millisecond-times-in-logs/) if you want to customize the log format.

WARNING: Currently a work in progress prototype, use at your own risks.

## Requirements

- Nginx with [HttpLuaModule](http://wiki.nginx.org/HttpLuaModule) and [Nginx Development Kit](https://github.com/simpl/ngx_devel_kit)
- [uuid](https://github.com/Tieske/uuid)
- [cjson](http://www.kyne.com.au/~mark/software/lua-cjson.php)
- [mockagne](https://github.com/PunchWolf/mockagne) for testing

Under OSX if you use Homebrew, you can setup Nginx with :

```bash
brew install luajit --with-luarocks
brew tap homebrew/nginx
brew install nginx-full --with-lua-module
```

## Usage

- See [nginx_request_logger_configuration.conf](nginx_request_logger_configuration.conf) for the Nginx configuration
- See [nginx_request_logger.json](nginx_services_logging.json) for a detailed configuration example

## Configuration

### Request

|Type|Parameter|Description|
-----|---------|----------
|`uri_regex`|`match_index`|Used to fetch matching result when using a `regex` uri type, 0 is the first matched element.|
|`post_arg`|`parameter_name`|Arguments in a POST http request|
|`json_body`|`path`|Parse the body as JSON, and extract the content at this path|
|`query`|`parameter_name`|Query parameter|
|`header`|`header_name`|Header name|

WARNING: to use `json_body` or `post_arg` you must enable `lua_need_request_body` in the server which increase the memory usage

### Response

|Type|Parameter|Description|
-----|---------|----------
|`json_body`|`path`|Parse the body as JSON, and extract the content at this path|
|`header`|`header_name`|Header name|

WARNING: using `json_body` means we need to cache the response content which increase the memory usage 

## Try it

The [example](example) directory contains a Lua application that can be used to try the scripts.

## Testing

After installing [mockagne](https://github.com/PunchWolf/mockagne), run `luajit test_nginx_request_logger.lua` in the `tests` directory.

## Resources :

- http://wiki.nginx.org/HttpLuaModule
- http://ryandlane.com/blog/2014/12/11/using-lua-in-nginx-for-unique-request-ids-and-millisecond-times-in-logs/

## License

This software is released under the MIT license.

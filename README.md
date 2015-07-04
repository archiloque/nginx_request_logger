# Nginx request logger

Lua code to log request information in Nginx. For each URL you can specify witch parameter and reponse values to logs.

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
}```

Result
```
2015/06/30 23:22:59 [info] 39499#0: *67 [lua] nginx_services_logging.lua:61: before_call(): Service logging 86f59a44-6519-4323-c3bb-9a15c6f62e3c REST [post_json_ok] {"key_name":"value"}, client: 127.0.0.1, server: localhost, request: "POST /json/ok HTTP/1.1", host: "localhost:8081"
2015/06/30 23:22:59 [info] 39499#0: *67 [lua] nginx_services_logging.lua:94: after_call(): Service logging 86f59a44-6519-4323-c3bb-9a15c6f62e3c REST [post_json_ok] {"key_name":"value"} {"code_name":1} while logging request, client: 127.0.0.1, server: localhost, request: "POST /json/ok HTTP/1.1", upstream: "http://127.0.0.1:9292/json/ok", host: "localhost:8081"
```


WARNING: Currently a work in progress prototype, use at your own risks.

## Requirements
- Nginx with [HttpLuaModule](http://wiki.nginx.org/HttpLuaModule) and [Nginx Development Kit](https://github.com/simpl/ngx_devel_kit)
- [uuid](https://github.com/Tieske/uuid)
- [cjson](http://www.kyne.com.au/~mark/software/lua-cjson.php)

Under OSX if you use Homebrew, you can setup Nginx with :

```bash
brew install luajit --with-luarocks
brew tap homebrew/nginx
brew install nginx-full --with-lua-module
```

## Usage

- See [nginx_request_logger_configuration.conf](nginx_request_logger_configuration.conf) for the Nginx configuration
- See [nginx_request_logger.json](nginx_services_logging.json) for a detailed configuration example

## Try it

The [rest_example](rest_example) directory contains a Lua REST application that can be used to test the REST functionalities.

## Resources :

- http://wiki.nginx.org/HttpLuaModule
- http://ryandlane.com/blog/2014/12/11/using-lua-in-nginx-for-unique-request-ids-and-millisecond-times-in-logs/

## License

This software is released under the MIT license.

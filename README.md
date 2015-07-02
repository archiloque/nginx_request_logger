# Nginx services logging

Lua code to log services calls information in Nginx. It enables to specify witch parameters to logs in each services in a json file.

Example :

```json
{
  "services": {
    "rest": [
      {
        "name": "post_json_ok",
        "uri": "/json/ok",
        "method": "POST",
        "request": [
          {
            "name": "key_name",
            "path": "key"
          }
        ],
        "response": [
          {
            "name": "code_name",
            "path": "code"
          }
        ]
      }
    ]
  }
}
```

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

## Usage

- See [nginx_services_logging_configuration_rest.conf](nginx_services_logging_configuration_rest.conf) for the Nginx configuration
- See [nginx_services_logging.json](nginx_services_logging.json) for a detailed configuration example

## Try it

The [rest_example](rest_example) directory contains a Lua REST application that can be used to test the REST functionalities.

## Resources :
- http://wiki.nginx.org/HttpLuaModule
- http://ryandlane.com/blog/2014/12/11/using-lua-in-nginx-for-unique-request-ids-and-millisecond-times-in-logs/

## License

This software is released under the MIT license.

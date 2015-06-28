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
  			"params": [
  				{
  					"name": "key_name",
  					"path": "key"
  				}
  			]
  		}
  	]
  }
}
```

WARNING: Currently a work in progress prototype, use at your own risks.

## Requirements
- Nginx with [HttpLuaModule](http://wiki.nginx.org/HttpLuaModule) and [Nginx Development Kit](https://github.com/simpl/ngx_devel_kit)
- [uuid](https://github.com/Tieske/uuid)
- [cjson](http://www.kyne.com.au/~mark/software/lua-cjson-manual.html)

## Usage

- See [nginx_services_logging_configuration_rest.conf](nginx_services_logging_configuration_rest.conf) for the Nginx configuration
- See [nginx_services_logging.json](nginx_services_logging.json) for a detailed configuration example

## Try it

The [rest_example](rest_example) directory contains a Ruby REST application that can be used to test the REST functionalities.

## Resources :
- http://wiki.nginx.org/HttpLuaModule
- http://ryandlane.com/blog/2014/12/11/using-lua-in-nginx-for-unique-request-ids-and-millisecond-times-in-logs/

## License

This software is released under the MIT license.

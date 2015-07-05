NginxRequestLoggerHelper = {}

function NginxRequestLoggerHelper.concat_table_keys(input_table, separator)
    local keys_table = {}
    for key, _ in pairs(input_table) do
        table.insert(keys_table, key)
    end
    return table.concat(keys_table, separator)
end

function NginxRequestLoggerHelper.error_if_param_is_missing(name, element_type, element_configuration, param_name)
    if element_configuration[param_name] == nill then
        error("Missing " .. param_name .. " parameter for " .. element_type .. " parameter " .. name .. " " .. cjson.encode(element_configuration))
    end
end


return NginxRequestLoggerHelper
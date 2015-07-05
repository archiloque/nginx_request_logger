NginxRequestLoggerHelper = {}

function NginxRequestLoggerHelper.concat_table_keys(input_table, separator)
    local keys_table = {}
    for key, _ in pairs(input_table) do
        table.insert(keys_table, key)
    end
    return table.concat(keys_table, separator)
end

return NginxRequestLoggerHelper
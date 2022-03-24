local util_err = require('utils.error')

local _Module = {
    _VERSION = '0.1.0',
    _NAME = 'util_str'
}

function _Module.ltrim(str, str_match)
    util_err.is_not_type_error('string', str)
    util_err.is_not_type_error({'nil', 'string'}, str_match)
    str_match = str_match or '%s'
    return str:gsub('^' .. str_match .. '*', '')
end

function _Module.rtrim(str, str_match)
    util_err.is_not_type_error('string', str)
    util_err.is_not_type_error({'nil', 'string'}, str_match)
    str_match = str_match or '%s'
    return str:gsub(str_match .. '*$', '')
end

function _Module.trim(str, str_match)
    str = _Module.ltrim(str, str_match)
    return _Module.rtrim(str, str_match)
end

function _Module.replace(str, str_find, str_rep)
    util_err.is_not_type_error('string', str)
    util_err.is_not_type_error('string', str_find)
    str_rep = str_rep or ''
    return str:gsub(str_find, str_rep)
end

function _Module.startswith(str, str_sub)
    util_err.is_not_type_error('string', str)
    util_err.is_not_type_error('string', str_sub)
    if str:find(str_sub) == 1 then
        return true
    end
    return false
end

function _Module.endswith(str, str_sub)
    util_err.is_not_type_error('string', str)
    util_err.is_not_type_error('string', str_sub)
    local str_r = str:reverse()
    local str_sub_r = str_sub:reverse()
    if str_r:find(str_sub_r) == 1 then
        return true
    end
    return false
end

function _Module.split(str, str_sep)
    util_err.is_not_type_error('string', str)
    util_err.is_not_type_error('string', str_sep)
    local ret = {}
    str:gsub('[^' .. str_sep .. ']+', function(t_str)
        table.insert(ret, t_str)
    end)
    return ret
end

function _Module.contains(str, str_sub, ignore_case)
    util_err.is_not_type_error('string', str)
    util_err.is_not_type_error('string', str_sub)
    ignore_case = ignore_case or false
    if ignore_case then
        str = string.lower(str)
        str_sub = string.lower(str_sub)
    end
    if str:match(str_sub) then
        return true
    end
    return false
end

return _Module

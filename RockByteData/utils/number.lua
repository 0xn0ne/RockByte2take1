local util_err = require('utils.error')

local _Module = {
    _VERSION = '0.1.0',
    _NAME = 'util_num'
}

function _Module.to_hex(num)
    util_err.is_not_type_error('number', num)
    if not _Module.is_int(num) then
        util_err.value_error(util_err.value_error_str('num', 'an integer number'))
    end
    return string.format("%x", num)
end

function _Module.is_int(num)
    util_err.is_not_type_error('number', num)
    if math.floor(num) < num then
        return false
    else
        return true
    end
end


return _Module

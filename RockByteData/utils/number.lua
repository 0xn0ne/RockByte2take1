local util_err = require('utils.error')
local util_tbl = require('utils.table')

local _Module = {
    _VERSION = '0.1.0',
    _NAME = 'util_num'
}

function _Module.to_hex(num)
    util_err.is_not_type_error('number', num)
    if not _Module.is_int(num) then
        util_err.value_error(util_err.value_error_str('num', 'an integer number'))
    end
    return string.format('%x', num)
end

function _Module.to_bin(num)
    util_err.is_not_type_error('number', num)
    if not _Module.is_int(num) then
        util_err.value_error(util_err.value_error_str('num', 'an integer number'))
    end
    if num == 0 then
        return '0'
    end
    local ret = {}
    while num > 0 do
        ret[#ret + 1] = tostring(num % 2)
        num = num >> 1
    end
    return table.concat(util_tbl.reverse(ret))
end

function _Module.count_bin_1(num)
    util_err.is_not_type_error('number', num)
    if not _Module.is_int(num) then
        util_err.value_error(util_err.value_error_str('num', 'an integer number'))
    end
    if num == 0 then
        return '0'
    end
    local ret = 0
    while num > 0 do
        if num % 2 > 0 then
            ret = ret + 1
        end
        num = num >> 1
    end
    return ret
end

function _Module.calc_bin_max(num)
    util_err.is_not_type_error('number', num)
    if not _Module.is_int(num) then
        util_err.value_error(util_err.value_error_str('num', 'an integer number'))
    end
    if num == 0 then
        return 1
    end
    local ret = 0
    while num > 0 do
        ret = ret << 1
        ret = ret + 1
        num = num >> 1
    end
    return ret
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

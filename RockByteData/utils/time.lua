local util_err = require('utils.error')
local util_tbl = require('utils.table')

local _Module = {
    _VERSION = '0.1.0',
    _NAME = 'util_tim',
    _DEBUG_MODE = false
}

_Module.yer = 'year'
_Module.mon = 'month'
_Module.day = 'day'
_Module.hor = 'hour'
_Module.min = 'minute'
_Module.sec = 'second'
_Module.msc = 'millisecond'
_Module.sort_key = {_Module.yer, _Module.mon, _Module.day, _Module.hor, _Module.min, _Module.sec, _Module.msc}
_Module.to_ms = {
    year = 31557600000,
    month = 2629800000,
    -- year = 31536000000,
    -- month = 2592000000,
    day = 86400000,
    hour = 3600000,
    minute = 60000,
    second = 1000,
    millisecond = 1
}

function _Module.ms2date(num_ms, kwargs)
    util_err.is_not_type_error('number', num_ms)
    kwargs = kwargs or {}
    kwargs.only = kwargs.only or {}
    kwargs.exclude = kwargs.exclude or {}
    util_err.is_not_type_error('table', kwargs.only)
    util_err.is_not_type_error('table', kwargs.exclude)
    local ret = {
        year = 0,
        month = 0,
        day = 0,
        hour = 0,
        minute = 0,
        second = 0,
        millisecond = 0
    }
    local is_only_emp = util_tbl.is_empty(kwargs.only)
    local is_exclude_emp = util_tbl.is_empty(kwargs.exclude)
    for i = 1, #_Module.sort_key do
        local t_name = _Module.sort_key[i]
        local to_ms = _Module.to_ms[t_name]
        if is_only_emp and is_exclude_emp and num_ms / to_ms > 0 then
            kwargs.only[#kwargs.only + 1] = t_name
        end
        if not util_tbl.contains(kwargs.only, t_name) and is_exclude_emp or util_tbl.contains(kwargs.exclude, t_name) then
            goto continue
        end
        ret[t_name] = math.floor(num_ms / to_ms)
        num_ms = num_ms % to_ms
        ::continue::
    end
    return ret
end

function _Module.date2ms(tbl_date)
    util_err.is_not_type_error('table', tbl_date)
    local total_ms = 0
    for t_name, t_value in pairs(tbl_date) do
        total_ms = total_ms + t_value * _Module.to_ms[t_name]
    end
    return total_ms
end

function _Module.date2string(tbl_date, kwargs)
    util_err.is_not_type_error('table', tbl_date)
    kwargs = kwargs or {}
    kwargs.sep = kwargs.sep or ' '
    if kwargs.is_short == nil then
        kwargs.is_short = true
    end
    kwargs.handler = kwargs.handler or function(key, n_time, kwargs)
        if kwargs.with_key then
            if kwargs.is_short then
                key = string.sub(key, 1, 1)
            end
            kwargs.ret[#kwargs.ret + 1] = string.format('%d%s', n_time, key)
        else
            kwargs.ret[#kwargs.ret + 1] = n_time
        end
    end
    if kwargs.with_key == nil then
        kwargs.with_key = true
    end
    kwargs.ret = {}
    for i = 1, #_Module.sort_key do
        local key = _Module.sort_key[i]
        if tbl_date[key] and tbl_date[key] ~= 0 then
            kwargs.handler(key, tbl_date[key], kwargs)
        end
    end
    return table.concat(kwargs.ret, kwargs.sep)
end


return _Module

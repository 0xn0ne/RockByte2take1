local util_err = require('utils.error')
local util_bas = require('utils.base')

local _Module = {
    _VERSION = '0.1.3',
    _NAME = 'util_tbl'
}

function _Module.reverse(arr)
    util_err.is_not_type_error('table', arr)
    local ret = {}
    for i = 1, #arr do
        ret[i] = arr[#arr - i + 1]
    end
    return ret
end

function _Module.unique(arr)
    util_err.is_not_type_error('table', arr)
    local hash = {}
    local res = {}
    for _, v in ipairs(arr) do
        if not hash[v] then
            hash[v] = true
            res[#res + 1] = v
        end
    end
    return res
end

-- I've been thinking about whether this function makes sense in Lua
function _Module.push(arr, ...)
    util_err.is_not_type_error('table', arr)

    local anys = {...}
    for _, value in pairs(anys) do
        if type(value) == 'table' then
            arr[#arr + 1] = _Module.copy(value)
        else
            arr[#arr + 1] = value
        end
    end
end

function _Module.pop(arr)
    util_err.is_not_type_error('table', arr)
    return table.remove(arr, #arr)
end

function _Module.unshift(arr, ...)
    util_err.is_not_type_error('table', arr)
    local anys = {...}
    for index = 1, #anys do
        util_err.is_type_error('nil', anys[index])
        table.insert(arr, 1, anys[index])
    end
end

function _Module.shift(arr)
    util_err.is_not_type_error('table', arr)
    return table.remove(arr, 1)
end

function _Module.extend(s_arr, d_arr)
    util_err.is_not_type_error('table', s_arr)
    util_err.is_not_type_error('table', d_arr)

    for _, value in pairs(d_arr) do
        if type(value) == 'table' then
            s_arr[#s_arr + 1] = _Module.copy(value)
        else
            s_arr[#s_arr + 1] = value
        end
    end
end

function _Module.is_array(tbl)
    util_err.is_not_type_error('table', tbl)
    if type(tbl) ~= 'table' then
        return false
    end
    local i = 1
    for _ in pairs(tbl) do
        if tbl[i] == nil then
            return false
        end
        i = i + 1
    end
    return true
end

function _Module.slice(arr, start_i, length)
    local ret = {}
    length = length or #arr
    if not start_i or start_i < 1 then
        start_i = 1
    end
    if length < 0 then
        start_i = start_i + length + 1
        length = math.abs(length)
    end
    while length > 0 and start_i <= #arr do
        ret[#ret + 1] = arr[start_i]
        start_i = start_i + 1
        length = length - 1
    end
    return ret
end

function _Module.is_empty(tbl)
    util_err.is_not_type_error({'table', 'nil'}, tbl)
    if tbl == nil or _G.next(tbl) == nil then
        return true
    end
    return false
end

function _Module.index(tbl, any)
    util_err.is_not_type_error('table', tbl)
    for key, value in pairs(tbl) do
        if util_bas.is_same(value, any) then
            return key
        end
    end
    return nil
end

function _Module.contains(tbl, elm)
    util_err.is_not_type_error('table', tbl)
    return _Module.index(tbl, elm) ~= nil
end

function _Module.filter(tbl, func)
    util_err.is_not_type_error('table', tbl)
    util_err.is_not_type_error('function', func)

    local ret = {}
    local is_arr = _Module.is_array(tbl)
    for key, value in pairs(tbl) do
        if func(key, value) then
            if is_arr then
                ret[#ret + 1] = value
            else
                ret[key] = value
            end
        end
    end
    return ret
end

function _Module.copy(tbl)
    util_err.is_not_type_error('table', tbl)

    local function sub_copy(sub_tbl)
        local new_table = {}
        for key, value in pairs(sub_tbl) do
            if type(value) == 'table' then
                new_table[key] = sub_copy(value)
            else
                new_table[key] = value
            end
        end
        return new_table
    end
    return sub_copy(tbl)
end

function _Module.update(s_tbl, ...)
    local d_tbls = {...}
    util_err.is_not_type_error('table', s_tbl)

    local function sub_update(sub_s_tbl, sub_d_tbl)
        if type(sub_s_tbl) ~= 'table' then
            sub_s_tbl = {}
        end
        for key, value in pairs(sub_d_tbl) do
            if type(value) == 'table' then
                sub_s_tbl[key] = sub_update(sub_s_tbl[key], sub_d_tbl)
            else
                sub_s_tbl[key] = value
            end
        end
    end
    for i = 1, #d_tbls do
        util_err.is_not_type_error('table', d_tbls[i])
        for key, value in pairs(d_tbls[i]) do
            s_tbl[key] = value
        end
    end
end

-- this function skips the test, because Lua tables are out of order
function _Module.keys(tbl)
    util_err.is_not_type_error('table', tbl)

    local keys = {}
    -- local can_sort = true
    for key, _ in pairs(tbl) do
        keys[#keys + 1] = key
        -- if type(key) ~= "number" and type(key) ~= "string" then
        --     can_sort = false
        -- end
    end
    -- if can_sort then
    --     table.sort(keys)
    -- end
    return keys
end

-- this function skips the test, because Lua tables are out of order
function _Module.values(tbl)
    util_err.is_not_type_error('table', tbl)

    local values = {}
    for _, value in pairs(tbl) do
        values[#values + 1] = value
    end
    return values
end

-- this function skips the test, too easy
function _Module.in_keys(key, tbl)
    util_err.is_not_type_error('table', tbl)
    return tbl[key] ~= nil
end

function _Module.pairs_sort_by_val(tbl, func)
    util_err.is_not_type_error('table', tbl)
    util_err.is_not_type_error({'nil', 'function'}, func)
    local arr_val = {}
    local tbl_v2k = {}
    for key, val in pairs(tbl) do
        tbl_v2k[val] = key
        arr_val[#arr_val + 1] = val
    end
    table.sort(arr_val, func)
    local index = 0
    return function()
        index = index + 1
        return tbl_v2k[arr_val[index]], arr_val[index]
    end
end

function _Module.pairs_sort_by_key(tbl, func)
    util_err.is_not_type_error('table', tbl)
    util_err.is_not_type_error({'nil', 'function'}, func)
    local arr_key = {}
    for key, _ in pairs(tbl) do
        arr_key[#arr_key + 1] = key
    end
    table.sort(arr_key, func)
    local index = 0
    return function()
        index = index + 1
        return arr_key[index], tbl[arr_key[index]]
    end
end

return _Module

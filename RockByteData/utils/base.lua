local _Module = {
    _VERSION = '0.1.0',
    _NAME = 'util_bas'
}

local util_err = require('utils.error')

function _Module.to_string(any)
    local function sub_is_array(tbl)
        local i = 1
        for _ in pairs(tbl) do
            if tbl[i] == nil then
                return false
            end
            i = i + 1
        end
        return true
    end

    local function gen_table_r(tbl_r)
        local res = {}
        local is_tbl_r_arr = sub_is_array(tbl_r)
        for key, val in pairs(tbl_r) do
            local t_key = ''
            if not is_tbl_r_arr then
                if type(key) == 'string' then
                    t_key = table.concat({'"', key, '": '})
                else
                    t_key = tostring(key) .. ': '
                end
            end

            if type(val) == 'table' then
                res[#res + 1] = t_key .. gen_table_r(val)
            elseif type(val) == 'string' then
                res[#res + 1] = table.concat({t_key, '"', val, '"'})
            else
                res[#res + 1] = table.concat({t_key, tostring(val)})
            end
        end
        local res_str = table.concat(res, ', ')
        return table.concat({'{', res_str, '}'})
    end
    if type(any) == 'table' then
        any = gen_table_r(any)
    else
        any = tostring(any)
    end
    return any
end

-- this function skips the test, too easy
function _Module.print(...)
    local tbl = {...}
    for index = 1, #tbl do
        if type(tbl[index]) == 'string' then
            tbl[index] = '"' .. tbl[index] .. '"'
        else
            tbl[index] = _Module.to_string(tbl[index])
        end
    end
    local print_string = table.concat(tbl, ' ')
    print(print_string)
end

function _Module.join(...)
    local tbl = {...}
    local tbl_len = #tbl
    if tbl_len < 2 then
        return ...
    end
    local paths = {}
    for i = 1, tbl_len - 1 do
        util_err.is_not_type_error('string', tbl[i])
        paths[#paths + 1] = string.gsub(tbl[i], '\\+$', '')
    end
    util_err.is_not_type_error('string', tbl[tbl_len])
    paths[#paths + 1] = string.gsub(tbl[tbl_len], '^\\+', '')
    return table.concat(paths, "\\")
end

function _Module.join_dir(...)
    local tbl = {...}
    local paths = {}
    for i = 1, #tbl do
        util_err.is_not_type_error('string', tbl[i])
        paths[#paths + 1] = string.gsub(tbl[i], '\\+$', '')
    end
    return table.concat(paths, "\\") .. '\\'
end

function _Module.int2ip(num)
    util_err.is_not_type_error({'number', 'nil'}, num)
    if num then
        num = tonumber(num)
        local n1 = math.floor(num / (2 ^ 24))
        local n2 = math.floor((num - n1 * (2 ^ 24)) / (2 ^ 16))
        local n3 = math.floor((num - n1 * (2 ^ 24) - n2 * (2 ^ 16)) / (2 ^ 8))
        local n4 = math.floor((num - n1 * (2 ^ 24) - n2 * (2 ^ 16) - n3 * (2 ^ 8)))
        return table.concat({n1, n2, n3, n4}, ".")
    end
    return "0.0.0.0"
end

function _Module.is_same(s_any, d_any)
    if type(s_any) ~= "table" or type(d_any) ~= "table" then
        return s_any == d_any
    end
    local function sub_is_same(sub_s_any, sub_d_any)
        for key, value in pairs(sub_s_any) do
            if type(value) == 'table' then
                if not sub_is_same(value, sub_d_any[key]) then
                    return false
                end
            else
                if value ~= sub_d_any[key] then
                    return false
                end
            end
        end
        return true
    end
    return sub_is_same(s_any, d_any)
end

function _Module.calc_distance(point_a, point_b)
    if point_a.z and point_b.z then
        return math.sqrt((point_a.x - point_b.x) ^ 2 + (point_a.y - point_b.y) ^ 2 + (point_a.z - point_b.z) ^ 2)
    else
        return math.sqrt((point_a.x - point_b.x) ^ 2 + (point_a.y - point_b.y) ^ 2)
    end
end

return _Module

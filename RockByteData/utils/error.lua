local _Module = {
    _VERSION = '0.1.1',
    _NAME = 'util_err'
}

function _Module.base_error(msg, err_type)
    err_type = err_type or 'Error'
    error(string.format('%s: %s', err_type, msg))
end

function _Module.type_error(msg)
    _Module.base_error(msg, 'TypeError')
end

function _Module.is_not_type_error_str(exp_types, obj_type)
    if type(exp_types) ~= 'table' then
        exp_types = {exp_types}
    end
    return string.format('expected [%s], not [%s]', table.concat(exp_types, ', '), obj_type)
end

function _Module.is_not_type_error(only_types, obj)
    if type(only_types) ~= 'table' then
        only_types = {only_types}
    end
    local obj_typ = type(obj)
    local is_pass = false
    for i = 1, #only_types do
        if obj_typ == only_types[i] then
            is_pass = true
            break
        end
    end
    if is_pass then
        return
    end
    _Module.type_error(_Module.is_not_type_error_str(only_types, obj_typ))
end

function _Module.is_type_error_str(exp_types, obj_type)
    if type(exp_types) ~= 'table' then
        exp_types = {exp_types}
    end
    return string.format('expected not [%s], but got [%s]', table.concat(exp_types, ', '), obj_type)
end

function _Module.is_type_error(exclude_types, obj)
    if type(exclude_types) ~= 'table' then
        exclude_types = {exclude_types}
    end
    local obj_typ = type(obj)
    local is_err = false
    for i = 1, #exclude_types do
        if obj_typ == exclude_types[i] then
            is_err = true
        end
    end
    if is_err then
        _Module.type_error(_Module.is_type_error_str(exclude_types, obj_typ))
    end
end

function _Module.value_error(msg)
    _Module.base_error(msg, 'ValueError')
end

function _Module.value_error_str(obj_name, should_what)
    return string.format('"%s" should be %s', obj_name, should_what)
end

function _Module.value_error_not_str(obj_name, shouldnt_what)
    return string.format('"%s" should not be %s', obj_name, shouldnt_what)
end


return _Module

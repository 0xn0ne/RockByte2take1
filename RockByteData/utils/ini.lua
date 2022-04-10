local _Module = {
    _VERSION = '0.1.0',
    _NAME = 'util_ini'
}

function _Module:new(filename, o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.filename = filename or 'setting.ini'
    self.data = {}
    local file = io.open(self.filename, 'rb')
    if file then
        file:close()
    else
        file = io.open(self.filename, 'w+')
        file:close()
    end
    self:open(self.filename)
    return o
end

-- 打开一个文件
function _Module:open(filename)
    local session = nil -- 当前结点，为空则不会读取
    local file = io.open(filename, 'r')
    for line in file:lines() do
        -- 处理注释
        line = string.sub(line, 1, (string.find(line, '#') or string.find(line, ';') or (string.len(line) + 1)) - 1)
        if line ~= '' then
            -- 首选判断是不是session
            local s = line:match('%[(.+)%]')
            if s then -- session的情况，赋值当前session
                session = s
            elseif session then -- 不是session的情况，必须当前session有值
                local epos = string.find(line, '=') -- 查找第一个等于号位置
                if epos and epos ~= 1 and epos ~= string.len(line) then -- 有等于号，并且不是第一个和最后一个位置
                    -- 不存在这个节点则创建一个
                    if self.data[session] == nil then
                        self.data[session] = {}
                    end
                    local val = string.sub(line, epos + 1)
                    if val == 'true' then
                        val = true
                    elseif val == 'false' then
                        val = false
                    elseif string.match(val, '^%d+%.?%d*$') then
                        val = tonumber(val)
                    end
                    -- 添加这个值
                    self.data[session][string.sub(line, 1, epos - 1)] = val
                end
            end
        end
    end
    file:close()
    return self.data
end

-- 保存一个_Module文件
function _Module:save()
    local file = io.open(self.filename, 'w')
    for session, group in pairs(self.data) do
        file:write('[' .. session .. ']\n')
        for key, value in pairs(group) do
            if value ~= nil then
                file:write(key .. '=' .. tostring(value) .. '\n')
            end
        end
    end
    file:close()
end

-- 加载当前配置
function _Module:load()
    return self.data
end

-- 更新当前配置
function _Module:update(data)
    self.data = data
end

-- 打印文件
function _Module:print()
    for session, group in pairs(self.data) do
        print(session)
        for key, value in pairs(group) do
            print('  ' .. key .. ': ' .. value)
        end
    end
end

-- 获取一个值
function _Module:get(session, key, default)
    if self.data[session] == nil or self.data[session][key] == nil then
        return default
    end
    return self.data[session][key]
end

-- 设置一个值
function _Module:set(session, key, value)
    if self.data[session] == nil then
        self.data[session] = {}
    end
    self.data[session][key] = value
end

-- 检查配置是否为空
function _Module:is_empty()
    return next(self.data) == nil
end

return _Module

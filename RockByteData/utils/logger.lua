local util_bas = require('utils.base')

local _Module = {
    _version = '0.1.0',
    _NAME = 'util_log'
}

_Module.lvl = {
    err = 100,
    wrn = 80,
    suc = 60,
    inf = 40,
    dbg = 20
}
_Module.lvl2nme = {
    [100] = 'ERR',
    [80] = 'WRN',
    [60] = 'SUC',
    [40] = 'INF',
    [20] = 'DBG'
}

function _Module:new(log_name, paths, log_level, o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    self.log_name = log_name
    self.paths = paths or '.'
    self.log_level = log_level or _Module.lvl.inf
    self.current_date = -1
    self:open()
    return o
end

function _Module:open(file_date)
    file_date = file_date or _Module.get_filedate()

    local filename = string.format('%s_%s.log', self.log_name, tostring(file_date))
    self.file = io.open(util_bas.join(self.paths, filename), 'a+')
    return self.file
end

function _Module.get_filedate()
    return os.date('%Y%m', os.time())
end

function _Module:log(content, level)
    level = level or _Module.lvl.inf
    if level < self.log_level then
        return false
    end
    local file_date = self.get_filedate()
    if self.current_date ~= file_date then
        self:open(file_date)
        self.current_date = file_date
    end

    local log_time = os.date('%Y-%m-%d %H:%M:%S', os.time())
    self.file:write(string.format('%s [%s]:%s\n', log_time, _Module.lvl2nme[level], content))
    self.file:flush()
    return true
end

function _Module:close()
    return self.file:close()
end

return _Module

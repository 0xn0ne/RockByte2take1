---@diagnostic disable: undefined-global
local util_bas = require('utils.base')

describe("test utils.number", function()
    local util_num
    it("init", function()
        util_num = require('utils.number')
    end)

    it("util_num.to_hex", function()
        assert.are.same(util_num.to_hex(10), 'a')
        assert.are.same(util_num.to_hex(-10), 'fffffffffffffff6')
        assert.are.same(util_num.to_hex(0), '0')
        assert.has.errors(function()
            util_num.to_hex(0.2)
        end)
        assert.has.errors(function()
            util_num.to_hex(-4.5)
        end)
    end)

    it("util_num.is_int", function()
        assert.is_true(util_num.is_int(10))
        assert.is_true(util_num.is_int(0))
        assert.is_false(util_num.is_int(0.2))
        assert.is_false(util_num.is_int(-4.5))
        assert.has.errors(function()
            util_num.is_int()
        end)
        assert.has.errors(function()
            util_num.is_int(true)
        end)
    end)
end)


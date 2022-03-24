require 'busted.runner'()

---@diagnostic disable: undefined-global
local util_bas = require('utils.base')

describe("test utils.string", function()
    local util_str
    it("init", function()
        util_str = require('utils.string')
    end)

    it("util_str.ltrim", function()
        assert.are.same(util_str.ltrim('  aweqw  '), 'aweqw  ')
        assert.are.same(util_str.ltrim('aaaweqw  ', 'a'), 'weqw  ')
        assert.are.same(util_str.ltrim('ababweqw  ', '[ab]'), 'weqw  ')
    end)

    it("util_str.ltrim", function()
        assert.are.same(util_str.rtrim('  aweqw  '), '  aweqw')
        assert.are.same(util_str.rtrim('aaaweqa aaa', 'a'), 'aaaweqa ')
        assert.are.same(util_str.rtrim('ababweqaa abbabab', '[ab]'), 'ababweqaa ')
    end)

    it("util_str.trim", function()
        assert.are.same(util_str.trim('  aweqw  '), 'aweqw')
        assert.are.same(util_str.trim('aaaweqa aaa', 'a'), 'weqa ')
        assert.are.same(util_str.trim('ababweqaa abbabab', '[ab]'), 'weqaa ')
    end)

    it("util_str.replace", function()
        assert.are.same(util_str.replace('aweaaaqw', 'a'), 'weqw')
        assert.are.same(util_str.replace('  aweaaaasdwweraaqw', '[aw]'), '  esderq')
        assert.are.same(util_str.replace('aweaaaasdwweraaqw  ', '[aw]', '_'), '__e____sd__er__q_  ')
    end)

    it("util_str.startswith", function()
        assert.is_true(util_str.startswith('ababweqaa', 'aba'))
        assert.is_false(util_str.startswith('ababweqaa', 'bwe'))
        assert.is_false(util_str.startswith('ababweqaa', 'qaa'))
    end)

    it("util_str.endswith", function()
        assert.is_true(util_str.endswith('ababweqaa', 'qaa'))
        assert.is_false(util_str.endswith('ababweqaa', 'aba'))
        assert.is_false(util_str.endswith('ababweqaa', 'bwe'))
    end)

    it("util_str.split", function()
        assert.are.same(util_str.split('abaaaaaabweqaa', 'a'), {'b', 'bweq'})
        assert.are.same(util_str.split('adrgqernyrik', 'r'), {'ad', 'gqe', 'ny', 'ik'})
    end)

    it("util_str.contains", function()
        assert.is_true(util_str.contains('abaaaaaabweqaa', 'a'))
        assert.is_false(util_str.contains('adrgqernyrik', 'asdasd'))
    end)

    it("util_str.split", function()
        assert.are.same(util_str.split('abaaaaaabweqaa', 'a'), {'b', 'bweq'})
        assert.are.same(util_str.split('adrgqernyrik', 'r'), {'ad', 'gqe', 'ny', 'ik'})
    end)

    it("util_str.split", function()
        assert.are.same(util_str.split('abaaaaaabweqaa', 'a'), {'b', 'bweq'})
        assert.are.same(util_str.split('adrgqernyrik', 'r'), {'ad', 'gqe', 'ny', 'ik'})
    end)
end)


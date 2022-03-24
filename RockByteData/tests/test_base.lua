require 'busted.runner'()

---@diagnostic disable: undefined-global
describe("test utils.base", function()
    local util_bas
    it("init", function()
        util_bas = require('utils.base')
    end)

    it("util_bas.to_string", function()
        assert.are.same(util_bas.to_string(1), '1')
        assert.are.same(util_bas.to_string(false), 'false')
        assert.are.same(util_bas.to_string({1, true, {
            t = 1,
            b = nil
        }}), '{1, true, {"t": 1}}')
        assert.are.same(util_bas.to_string({
            b = {
                b = {3, 2, 4}
            }
        }), '{"b": {"b": {3, 2, 4}}}')
        assert.are.same(util_bas.to_string({'as', 1, {5, {false, {2, 5}}, {3, true}}}),
            '{"as", 1, {5, {false, {2, 5}}, {3, true}}}')
    end)

    it("util_bas.join", function()
        assert.are.same(util_bas.join('take', 'this', 'a', '123.lua'), "take\\this\\a\\123.lua")
        assert.are.same(util_bas.join('123.lua'), "123.lua")
        assert.has.errors(function()
            util_bas.join('take', true)
        end)
        assert.has.errors(function()
            util_bas.join(111, true)
        end)
    end)

    it("util_bas.join_dir", function()
        assert.are.same(util_bas.join_dir('take', 'this', 'a'), "take\\this\\a\\")
        assert.are.same(util_bas.join_dir('\\123.lua'), "\\123.lua\\")
        assert.has.errors(function()
            util_bas.join_dir('take', true)
        end)
    end)

    it("util_bas.int2ip", function()
        assert.are.same(util_bas.int2ip(16843009), '1.1.1.1')
        assert.are.same(util_bas.int2ip(0), '0.0.0.0')
        assert.are.same(util_bas.int2ip(), '0.0.0.0')
        assert.has.errors(function()
            util_bas.int2ip('asd')
        end)
    end)

    it("util_bas.is_same", function()
        assert.is_true(util_bas.is_same({1, 4, 7}, {1, 4, 7}))
        assert.is_true(util_bas.is_same({false, 12, true, 'new', {
            a = 'rock',
            t = 123
        }}, {false, 12, true, 'new', {
            t = 123,
            a = 'rock'
        }}))
    end)

    it("util_bas.calc_distance", function()
        assert.are.same(util_bas.calc_distance({
            x = 1.564,
            y = 5,
            z = 12.15
        }, {
            x = 8.68,
            y = 85.54,
            z = 19.4
        }), 81.17814703477778)
        assert.are.same(util_bas.calc_distance({
            x = 1.564,
            y = 5,
            z = 12.15
        }, {
            x = 8.68,
            y = 85.54,
            z = 19.4
        }), 81.17814703477778)
    end)
end)

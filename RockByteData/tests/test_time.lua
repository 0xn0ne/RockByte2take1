require 'busted.runner'()

---@diagnostic disable: undefined-global

describe("test utils.time", function()
    local util_tim
    it("init", function()
        util_tim = require('utils.time')
    end)

    it("util_tim.ms2date", function()
        assert.are.same(util_tim.ms2date(39633117773), {
            year = 1,
            month = 3,
            day = 2,
            hour = 3,
            minute = 41,
            second = 57,
            millisecond = 773
        })
        assert.are.same(util_tim.ms2date(39641143788, {
            only = {util_tim.day, util_tim.hor, util_tim.min, util_tim.sec}
        }), {
            year = 0,
            month = 0,
            day = 458,
            hour = 19,
            minute = 25,
            second = 43,
            millisecond = 0
        })
        assert.are.same(util_tim.ms2date(39641143788, {
            exclude = {util_tim.day, util_tim.hor, util_tim.min, util_tim.sec}
        }), {
            year = 1,
            month = 3,
            day = 0,
            hour = 0,
            minute = 0,
            second = 0,
            millisecond = 194143788
        })
    end)

    it("util_tim.date2ms", function()
        assert.are.same(util_tim.date2ms({
            year = 1,
            month = 3,
            day = 2,
            hour = 3,
            minute = 41,
            second = 57,
            millisecond = 773
        }), 39633117773)
    end)

    it("util_tim.date2string", function()
        assert.are.same(util_tim.date2string({
            year = 0,
            month = 0,
            day = 458,
            hour = 19,
            minute = 25,
            second = 43,
            millisecond = 0
        }), '458d 19h 25m 43s')
        assert.are.same(util_tim.date2string({
            year = 1,
            month = 3,
            day = 2,
            hour = 3,
            minute = 41,
            second = 57,
            millisecond = 773
        }, {sep = ','}), '1y,3m,2d,3h,41m,57s,773m')
        assert.are.same(util_tim.date2string({
            year = 1,
            month = 3,
            day = 2,
            hour = 3,
            minute = 41,
            second = 57,
            millisecond = 773
        }, {is_short = false}), '1year 3month 2day 3hour 41minute 57second 773millisecond')
    end)
end)

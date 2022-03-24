require 'busted.runner'()

---@diagnostic disable: undefined-global

describe("test utils.table", function()
    local util_tbl
    it("init", function()
        util_tbl = require('utils.table')
    end)

    it("util_tbl.is_empty", function()
        assert.has.errors(function()
            util_tbl.is_empty(123)
        end)
        assert.has_no.errors(function()
            util_tbl.is_empty()
        end)
        assert.is_true(util_tbl.is_empty({}))
        assert.is_false(util_tbl.is_empty({''}))
        assert.is_false(util_tbl.is_empty({
            a = 100,
            b = 110
        }))
    end)

    it("util_tbl.reverse", function()
        assert.has.errors(function()
            util_tbl.reverse()
        end)
        assert.are.same(util_tbl.reverse({}), {})
        assert.are.same(util_tbl.reverse({''}), {''})
        assert.are.same(util_tbl.reverse({true, 666, 'data', {}}), {{}, 'data', 666, true})
        assert.are.same(util_tbl.reverse({
            a = true,
            b = 666,
            d = 'data'
        }), {})
    end)

    it("util_tbl.unique", function()
        assert.has.errors(function()
            util_tbl.unique()
        end)
        assert.are.same(util_tbl.unique({1, 4, 7, 4, 5, 7}), {1, 4, 7, 5})
    end)

    it("util_tbl.push", function()
        assert.has.errors(function()
            util_tbl.push()
        end)
        local s_arr = {'h', 1, true, {2}}
        util_tbl.push(s_arr, 'a', 33, false, {'aa'})
        assert.are.same(s_arr, {'h', 1, true, {2}, 'a', 33, false, {'aa'}})
    end)

    it("util_tbl.pop", function()
        assert.has.errors(function()
            util_tbl.pop()
        end)
        local s_arr = {'h', 1, true}

        assert.are.same(util_tbl.pop(s_arr), true)
        assert.are.same(s_arr, {'h', 1})
        assert.are.same(util_tbl.pop(s_arr), 1)
        assert.are.same(s_arr, {'h'})
        assert.are.same(util_tbl.pop(s_arr), 'h')
        assert.are.same(s_arr, {})
        assert.are.same(util_tbl.pop(s_arr), nil)
        assert.are.same(s_arr, {})
    end)

    it("util_tbl.unshift", function()
        assert.has.errors(function()
            util_tbl.push()
        end)
        local s_arr = {'aaa'}

        util_tbl.unshift(s_arr, {2})
        assert.are.same(s_arr, {{2}, 'aaa'})
        util_tbl.unshift(s_arr, true)
        assert.are.same(s_arr, {true, {2}, 'aaa'})
        util_tbl.unshift(s_arr, 1)
        assert.are.same(s_arr, {1, true, {2}, 'aaa'})
        util_tbl.unshift(s_arr, 'h', 66)
        assert.are.same(s_arr, {66, 'h', 1, true, {2}, 'aaa'})
        assert.has.errors(function()
            util_tbl.unshift(s_arr, nil, 123, nil, 'ds')
        end)
    end)

    it("util_tbl.shift", function()
        assert.has.errors(function()
            util_tbl.shift()
        end)
        local s_arr = {'h', 1, true}

        assert.are.same(util_tbl.shift(s_arr), 'h')
        assert.are.same(s_arr, {1, true})
        assert.are.same(util_tbl.shift(s_arr), 1)
        assert.are.same(s_arr, {true})
        assert.are.same(util_tbl.shift(s_arr), true)
        assert.are.same(s_arr, {})
        assert.are.same(util_tbl.shift(s_arr), nil)
        assert.are.same(s_arr, {})
    end)

    it("util_tbl.extend", function()
        assert.has.errors(function()
            util_tbl.extend()
        end)
        local s_arr = {'h', 1, true, {2}}
        util_tbl.extend(s_arr, {'a', 33, false, {'aa'}})
        assert.are.same(s_arr, {'h', 1, true, {2}, 'a', 33, false, {'aa'}})
    end)

    it("util_tbl.is_array", function()
        assert.has.errors(function()
            util_tbl.is_array()
        end)
        assert.is_true(util_tbl.is_array({1, true, false, 'asd', {2}}))
        assert.is_false(util_tbl.is_array({
            1,
            true,
            [7] = {2}
        }))
    end)

    it("util_tbl.slice", function()
        assert.has.errors(function()
            util_tbl.slice()
        end)
        assert.are.same(util_tbl.slice({76, 3, 183, 32, 97, 2, 56}), {76, 3, 183, 32, 97, 2, 56})
        assert.are.same(util_tbl.slice({76, 3, 183, 32, 97, 2, 56}, 3), {183, 32, 97, 2, 56})
        assert.are.same(util_tbl.slice({76, 3, 183, 32, 97, 2, 56}, 3, 2), {183, 32})
        assert.are.same(util_tbl.slice({76, 3, 183, 32, 97, 2, 56}, 5, -2), {32, 97})
    end)

    it("util_tbl.is_empty", function()
        assert.is_true(util_tbl.is_empty({}))
        assert.is_true(util_tbl.is_empty({nil}))
        assert.is_true(util_tbl.is_empty({
            a = nil
        }))
        assert.is_false(util_tbl.is_empty({
            a = 1,
            c = 5
        }))
    end)

    it("util_tbl.index", function()
        assert.has.errors(function()
            util_tbl.index()
        end)
        assert.are.same(util_tbl.index({1, true, false, {3}, 'a', 7}, 'a'), 5)
    end)

    it("util_tbl.contains", function()
        assert.is_false(util_tbl.contains({true, false, '8', 22, {'hello'}}, 8))
        assert.is_true(util_tbl.contains({true, false, '8', 22, {4, 8}}, {4, 8}))
    end)

    it("util_tbl.filter", function()
        local tbl = {'asd', 1, 3, 56, 23, true, false, {11}}
        assert.are.same(util_tbl.filter(tbl, function(key, value)
            if type(value) == "number" and value > 10 then
                return true
            end
        end), {56, 23})
        tbl = {
            a = 1,
            b = 'a',
            t = 32,
            j = true
        }
        assert.are.same(util_tbl.filter(tbl, function(key, value)
            if type(value) == "boolean" then
                return true
            end
        end), {
            j = true
        })
    end)

    it("util_tbl.copy", function()
        local s_arr = {false, 4, 'go', {
            a = 1.2,
            b = true
        }}
        local s_tbl = {
            a = 1.8,
            b = true,
            c = 'hel',
            d = {1, false},
            e = nil
        }
        local n_arr = util_tbl.copy(s_arr)
        local n_tbl = util_tbl.copy(s_tbl)
        n_arr[1] = true
        n_arr[2] = n_arr[2] + 100
        n_arr[3] = 'new_arr'
        n_arr[4].a = n_arr[4].a + 3.6
        n_arr[4].b = false
        n_tbl.a = n_tbl.a + 5.3
        n_tbl.b = false
        n_tbl.c = 'jok'
        n_tbl.d[1] = n_tbl.d[1] + 12
        n_tbl.d[2] = true
        n_tbl.e = 'ok'
        assert.has.errors(function()
            util_tbl.copy(1)
        end)
        assert.are.same(n_arr, {true, 104, 'new_arr', {
            a = 4.8,
            b = false
        }})
        assert.are.same(n_tbl, {
            a = 7.1,
            b = false,
            c = 'jok',
            d = {13, true},
            e = 'ok'
        })
        assert.are.same(s_arr, {false, 4, 'go', {
            a = 1.2,
            b = true
        }})
        assert.are.same(s_tbl, {
            a = 1.8,
            b = true,
            c = 'hel',
            d = {1, false},
            e = nil
        })
    end)

    it("util_tbl.update", function()
        local s_tbl = {
            a = 'dc',
            b = {true}
        }
        local s_arr = {true, false, {
            hello = 1
        }}
        util_tbl.update(s_tbl, {
            b = 'ct',
            c = false,
            {
                t = 11
            }
        })
        util_tbl.update(s_arr, {'ct', false, {
            t = 11
        }, true, 123})
        assert.are.same(s_tbl, {
            [1] = {
                t = 11
            },
            a = "dc",
            b = "ct",
            c = false
        })
        util_tbl.update(s_arr, {1, 'da', true, 199})
        assert.are.same(s_arr, {1, 'da', true, 199, 123})
    end)

    it("util_tbl.pairs_sort_by_val", function()
        local sorted_keys = {'a', 't', 'b', 'k'}
        local sorted_vals = {'11', '23', 'Ew', 'sd'}
        local index = 1
        for key, value in util_tbl.pairs_sort_by_val({
            k = 'sd',
            b = 'Ew',
            a = '11',
            t = '23'
        }) do
            assert.are.same({sorted_keys[index], sorted_vals[index]}, {key, value})
            index = index + 1
        end
        local sorted_keys = {3, 4, 2, 1}
        local sorted_vals = {'11', '23', 'Ew', 'sd'}
        local index = 1
        for key, value in util_tbl.pairs_sort_by_val({'sd', 'Ew', '11', '23'}) do
            assert.are.same({sorted_keys[index], sorted_vals[index]}, {key, value})
            index = index + 1
        end
        assert.has_no.errors(util_tbl.pairs_sort_by_val({'sd', 'Ew', '11', '23'}, function()
        end))
        assert.has_no.errors(util_tbl.pairs_sort_by_val({'sd', 'Ew', '11', '23'}, nil))
        assert.has.errors(function()
            util_tbl.pairs_sort_by_val({'sd', 'Ew', '11', '23'}, 'asd')
        end)
    end)

    it("util_tbl.pairs_sort_by_key", function()
        local sorted_keys = {'a', 'b', 'k', 't'}
        local sorted_vals = {'11', 'Ew', 'sd', '23'}
        local index = 1
        for key, value in util_tbl.pairs_sort_by_key({
            k = 'sd',
            b = 'Ew',
            a = '11',
            t = '23'
        }) do
            assert.are.same({sorted_keys[index], sorted_vals[index]}, {key, value})
            index = index + 1
        end
        assert.has_no.errors(util_tbl.pairs_sort_by_key({'sd', 'Ew', '11', '23'}, function()
        end))
        assert.has_no.errors(util_tbl.pairs_sort_by_key({'sd', 'Ew', '11', '23'}, nil))
        assert.has.errors(function()
            util_tbl.pairs_sort_by_val({'sd', 'Ew', '11', '23'}, 'asd')
        end)
    end)
end)

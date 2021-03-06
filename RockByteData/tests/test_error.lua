require 'busted.runner'()

---@diagnostic disable: undefined-global
describe("test utils.error", function()
    local util_err
    it("init", function()
        util_err = require('utils.error')
    end)

    it("util_err.base_error", function()
        assert.has.errors(function()
            util_err.base_error('try some error.', 'Error')
        end)
    end)

    it("util_err.is_not_type_error", function()
        assert.are.equal(util_err.is_not_type_error_str('string', 'table'), 'expected [string], not [table]')
        assert.are.equal(util_err.is_not_type_error_str({'string', 'table'}, 'number'),
            'expected [string, table], not [number]')
    end)

    it("util_err.type_error", function()
        assert.has.errors(function()
            util_err.type_error('try some error.')
        end)
    end)

    it("util_err.is_not_type_error", function()
        assert.has.errors(function()
            util_err.is_not_type_error('string', {})
        end)
        assert.has_no.errors(function()
            util_err.is_not_type_error('number', 1122)
        end)
        assert.has_no.errors(function()
            util_err.is_not_type_error('boolean', true)
        end)
        assert.has_no.errors(function()
            util_err.is_not_type_error('boolean', false)
        end)
        assert.has_no.errors(function()
            util_err.is_not_type_error('string', 'hello')
        end)
        assert.has_no.errors(function()
            util_err.is_not_type_error({'string', 'table'}, {})
        end)
    end)

    it("util_err.is_type_error", function()
        assert.has.errors(function()
            util_err.is_type_error('string', 'asd')
        end)
        assert.has_no.errors(function()
            util_err.is_type_error('number', 'asd')
        end)
        assert.has_no.errors(function()
            util_err.is_type_error('boolean', 'asd')
        end)
        assert.has.errors(function()
            util_err.is_type_error('nil', nil)
        end)
        assert.has.errors(function()
            util_err.is_type_error({'nil', 'table'}, {})
        end)
    end)
end)

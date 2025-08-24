-- You can import external classes from your project like this:
-- local MyClass = require("src.to.MyClass")

describe("All assertions tests in use and working", function(ctx)

    -- Assertions equals and not equals
    ctx.it("assert.equals: should add two positive numbers correctly", function()
        local result = 2 + 3
        assert.equals(result, 5)
    end)

    ctx.it("assert.notEquals: should subtract numbers correctly", function()
        local result = "Text"
        assert.notEquals(result, "Another text")
    end)

    -- Assertions null and not null
    ctx.it("assert.assertNotNil: should result not nil", function()
        local result = 1 + 5
        assert.assertNotNil(result)
    end)

    ctx.it("assert.assertNil: should result nil", function()
        local result = nil
        assert.assertNil(result)
    end)

    -- Assertions boolean
    ctx.it("assert.assertTrue: should validate positive numbers 15 > 10", function()
        local number = 15
        assert.assertTrue(number > 0)
    end)

    ctx.it("assert.assertFalse: should validate positive numbers 0 < 10", function()
        local number = 0
        assert.assertFalse(number > 10)
    end)

    -- Assertions arrays and tables
    ctx.it("assert.assertContains: should validate a list contains a value", function()
        local list = {10, 20, 30}
        assert.assertContains(list, 20)
    end)

    ctx.it("assert.assertNotContains: should validate a list does not contain a value", function()
        local list = {10, 20, 30}
        assert.assertNotContains(list, 40)
    end)

    ctx.it("assert.assertTableEquals: should validate a table is equal", function()
        local table1 = {1, 2, 3}
        local table2 = {1, 2, 3}
        assert.assertTableEquals(table1, table2)
    end)

    -- Assertions numbers
    ctx.it("assert.assertGreater: should validate greater than", function()
        local a = 10
        local b = 5
        assert.assertGreater(a, b)
    end)

    ctx.it("assert.assertLess: should validate less than", function()
        local a = 5
        local b = 10
        assert.assertLess(a, b)
    end)

    ctx.it("assert.assertGreaterOrEqual: should validate greater than or equal", function()
        local a = 10
        local b = 10
        assert.assertGreaterOrEqual(a, b)

        
        local a = 15
        local b = 10
        assert.assertGreaterOrEqual(a, b)
    end)

    -- Assertions types
    ctx.it("assert.assertType: should validate a variable is of type string", function()
        local str = "hello"
        assert.assertType(str, "string")
    end)

    ctx.it("assert.assertType: should validate a variable is of type number", function()
        local num = 42
        assert.assertType(num, "number")
    end)

    -- Assertions throw
    ctx.it("assert.assertThrows: should throw an error for invalid assertions", function()
        local function invalidAssertion()
            assert.equals(1, 2)
        end
        assert.assertThrows(invalidAssertion)
    end)



end)
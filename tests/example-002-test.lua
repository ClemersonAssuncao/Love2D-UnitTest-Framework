-- You can import external classes from your project like this:
-- local MyClass = require("src.to.MyClass")

describe("Unit tests with skipped tests in another file", function(ctx)

    ctx.xit("should add two positive numbers correctly", function()
        local result = 2 + 3
        assert.equals(result, 5)
    end)

    ctx.xit("should add two positive numbers correctly", function()
        local result = 2 + 3
        assert.equals(result, 5)
    end)

end)
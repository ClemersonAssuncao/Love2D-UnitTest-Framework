-- You can import external classes from your project like this:
-- local MyClass = require("src.to.MyClass")

describe("File with others UnitTest events", function(ctx)

    Entity = {
        id = 0,
        name = "",
        value = 0
    }

    ctx.beforeEach(function()
        Entity.id = 1
        Entity.name = "Test Entity"
        Entity.value = 100
    end)

    ctx.it("Changed Entity using beforeEach", function()
        assert.equals(Entity.id, 1)
        -- changed Name
        Entity.name = "Changed Entity"
        assert.equals(Entity.name, "Changed Entity")
        assert.equals(Entity.value, 100)

    end)

    ctx.it("Using afterEach default value", function()
        assert.equals(Entity.id, 1)
        assert.equals(Entity.name, "Test Entity")
        assert.equals(Entity.value, 100)

    end)
    
    ctx.afterEach(function()
        Entity.id = 0
        Entity.name = ""
        Entity.value = 0
    end)


end)
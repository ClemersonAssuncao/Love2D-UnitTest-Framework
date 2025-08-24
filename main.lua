local TestRunner = {}

-- This allows us to require modules from your game project
package.path = package.path .. "../?.lua;"

local TestScreen = require("ui.test-screen")

function love.load()
    love.window.setTitle("Unit test for Love2d")
    love.window.setMode(1440, 800)

    TestScreen:load()
end

function love.update(dt)
    TestScreen:update(dt)
end

function love.draw()
    TestScreen:draw()
end

function love.mousemoved(x, y, dx, dy, istouch)
    TestScreen:mousemoved(x, y)
end

function love.mousepressed(x, y, button, istouch, presses)
    TestScreen:mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
    TestScreen:mousereleased(x, y, button)
end

function love.wheelmoved(dx, dy)
    TestScreen:wheelmoved(dx, dy)
end

function love.keypressed(button)
    if button == "escape" then
        love.event.quit()
    end
end

_G.json = require("libs.dkjson.init")

return TestRunner

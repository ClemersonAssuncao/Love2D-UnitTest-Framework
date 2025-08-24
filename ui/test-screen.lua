local TestListPanel = require("ui.test-list-panel")
local TestConsolePanel = require("ui.test-console-panel")
local TestFramework = require("test-framework")

local TestScreen = {}
TestScreen.__index = TestScreen

function TestScreen:load()

    -- Load test from directory "./tests"
    local testFileList = self:loadTestsFromDirectory("tests")

    local failedFileModules = {}
    for i, testFile in ipairs(testFileList) do
        local success, testModule = pcall(require, testFile.modulePath)
        if not success then
            -- If the test module failed to load this will show to you in the suite list
            local failedTest = {
                name = "Failed to load " .. testFile.fileName,
                description = "This test module failed to load.",
                tests = {
                    {
                        name = "Failed to load test module.\n" .. (tostring(testModule) or "Unknown error"),
                        description = "This test module failed to load.",
                        result = "failed"
                    }
                }
            }
            table.insert(failedFileModules, failedTest)
        end
    end
    TestFramework:run()

    for _, failedFile in ipairs(failedFileModules) do
        table.insert(TestFramework.suites, failedFile)
    end

    -- Create panels with responsive sizes
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    local panelSpacing = 10
    local leftPanelWidth = math.min(400, screenWidth * 0.35)
    
    self.listPanel = TestListPanel:new(
        panelSpacing, 
        panelSpacing, 
        leftPanelWidth, 
        screenHeight - (panelSpacing * 2),
        TestFramework.suites
    )
    
    self.consolePanel = TestConsolePanel:new(
        leftPanelWidth + (panelSpacing * 2), 
        panelSpacing, 
        screenWidth - leftPanelWidth - (panelSpacing * 3), 
        screenHeight - (panelSpacing * 2),
        {}
    )

    -- Connect selection callback
    self.listPanel.onSelect = function(suite)
        self.consolePanel:onSuiteSelected(suite)
    end
end

function TestScreen:update(dt)
    self.listPanel.scroll:update(dt)
    self.consolePanel.scroll:update(dt)
end

function TestScreen:draw()
    -- Subtle gradient background
    love.graphics.clear(0.08, 0.08, 0.10)
    
    self.listPanel:draw()
    self.consolePanel:draw()
end

function TestScreen:mousemoved(x, y)
    self.listPanel:mousemoved(x, y)
    self.consolePanel:mousemoved(x, y)
end

function TestScreen:mousereleased(x, y, button)
    self.listPanel:mousereleased(x, y, button)
    self.consolePanel:mousereleased(x, y, button)
end

function TestScreen:mousepressed(x, y, button)
    self.listPanel:mousepressed(x, y, button)
    self.consolePanel:mousepressed(x, y, button)
end

function TestScreen:wheelmoved(dx, dy)
    local mx, my = love.mouse.getPosition()
    self.listPanel:wheelmoved(dx, dy, mx, my)
    self.consolePanel:wheelmoved(dx, dy, mx, my)
end

function TestScreen:loadTestsFromDirectory(directory)
    local tests = {}
    local items = love.filesystem.getDirectoryItems(directory)
    
    for _, item in ipairs(items) do
        -- Check if it's a .lua file
        if item:match("%.lua$") then
            local moduleName = directory .. '/' ..item:gsub("%.lua$", "")
            table.insert(tests, {
                fileName= item,
                modulePath= moduleName
            })
        end
    end

    return tests
end

return TestScreen
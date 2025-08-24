local TestScrollPanel = require("ui.test-scrollpanel")
local TestConsolePanel = {}
TestConsolePanel.__index = TestConsolePanel

function TestConsolePanel:new(x, y, width, height, lines)
    local self = setmetatable({}, TestConsolePanel)
    self.scroll = TestScrollPanel:new(x, y, width, height)
    self.lines = lines or {}
    self.x, self.y, self.width, self.height = x, y, width, height
    self.fontSize = 12
    
    -- Icons
    local fontPath = "assets/fonts/Guifx_v2_Transports.ttf"
    
    self.iconFont = love.graphics.newFont(fontPath, 16)
    self.textFont = love.graphics.getFont()
    
    return self
end

function TestConsolePanel:addLine(text, type, showIcon)
    if (showIcon == nil) then showIcon = true end
    table.insert(self.lines, {text = text, type = type or "info", showIcon = showIcon})
end

function TestConsolePanel:clear()
    self.lines = {}
end

function TestConsolePanel:getIconChar(type)
    local iconMap = {
        pass = "z",
        fail = "x",
        skipped = "8",
        header = "D",
        warning = "d"
    }
    
    return iconMap[type] or ""
end

function TestConsolePanel:getColorForType(type)
    if type == "pass" then
        return {0.2, 0.8, 0.2}  -- Green
    elseif type == "fail" then
        return {0.8, 0.2, 0.2}  -- Red
    elseif type == "warning" then
        return {0.8, 0.8, 0.2}  -- Yellow
    elseif type == "skipped" then
        return {0.8, 0.8, 0.2}  -- Yellow
    elseif type == "info" then
        return {0.7, 0.7, 0.7}  -- Light gray
    elseif type == "header" then
        return {0.9, 0.9, 0.9}  -- White
    else
        return {0.8, 0.8, 0.8}  -- Default
    end
end

function TestConsolePanel:draw()
    love.graphics.setColor(0.05, 0.05, 0.05, 0.95)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 8, 8)

    self.scroll:drawStart()

    local y = self.y + 40
    local lineHeight = 18
    
    for i, line in ipairs(self.lines) do
        local lineData = type(line) == "table" and line or {text = line, type = "info"}
        local color = self:getColorForType(lineData.type)
        
        love.graphics.setColor(color[1], color[2], color[3])
        
        local iconChar = ""
        if (line.showIcon) then
            iconChar = self:getIconChar(lineData.type)
        end
        local iconWidth = 0

        -- Draw if iconChar is not empty
        if iconChar ~= "" then
            love.graphics.setFont(self.iconFont)
            love.graphics.print(iconChar, self.x + 15, y)
            iconWidth = self.iconFont:getWidth(iconChar) + 5
            love.graphics.setFont(self.textFont)
        end

        -- Process line breaks
        local fullText = lineData.text
        local textLines = {}

        -- Split by \n first
        for textLine in fullText:gmatch("[^\r\n]+") do
            table.insert(textLines, textLine)
        end

        -- If there are no line breaks, use the full text
        if #textLines == 0 then
            table.insert(textLines, fullText)
        end

        -- Process each line for automatic wrapping
        for _, textLine in ipairs(textLines) do
            local font = love.graphics.getFont()
            local wrappedLines, wrappedCount = font:getWrap(textLine, self.width - 30 - iconWidth)
            
            if type(wrappedLines) == "table" and #wrappedLines > 0 then
                for j, wrappedLine in ipairs(wrappedLines) do
                    love.graphics.print(wrappedLine, self.x + 15 + iconWidth, y)
                    y = y + lineHeight
                end
            else
                -- Fallback if getWrap doesn't work
                love.graphics.print(textLine, self.x + 15 + iconWidth, y)
                y = y + lineHeight
            end
        end

        -- Extra spacing for headers
        if lineData.type == "header" then
            y = y + 5
        end

        -- Extra spacing if the original message had line breaks
        if string.find(lineData.text, "\n") then
            y = y + lineHeight * 0.3 -- Additional proportional spacing
        end
    end

    self.scroll.contentHeight = y - self.y
    self.scroll:drawEnd()

    -- Background for the header
    love.graphics.setColor(0.05, 0.05, 0.05, 1.0)
    love.graphics.rectangle("fill", self.x, 10, self.width, 40, 8, 8)

    -- Border of the panel
    love.graphics.setColor(0.3, 0.3, 0.3, 0.8)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", self.x, 10, self.width, self.height, 8, 8)

    -- Title of the panel
    love.graphics.setColor(0.9, 0.9, 0.9)
    love.graphics.printf("Test Console", self.x + 10, 18, self.width - 20, "left")

    -- Separator line
    love.graphics.setColor(0.4, 0.4, 0.4)
    love.graphics.line(self.x + 10, 40, self.x + self.width - 10, 40)
    
    self.scroll:drawScrollbar()
end

function TestConsolePanel:countLineBreaks(text)
    local count = 0
    for _ in text:gmatch("\n") do
        count = count + 1
    end
    return count
end

function TestConsolePanel:wheelmoved(dx, dy, x, y)
    if self:isMouseInside(x, y) then
        self.scroll:handleWheelMoved(dx, dy)
    end
end

function TestConsolePanel:mousemoved(x, y)
    self.scroll:mousemoved(x, y)
end

function TestConsolePanel:mousepressed(x, y, button)
    if button == 1 then
        self.scroll:mousepressed(x, y, button)
    end
end

function TestConsolePanel:mousereleased(x, y, button)
    self.scroll:mousereleased(x, y, button)
end

function TestConsolePanel:isMouseInside(mx, my)
    return mx >= self.x and mx <= self.x + self.width and
           my >= self.y and my <= self.y + self.height
end

function TestConsolePanel:onSuiteSelected(suite)
    -- Clear the console and show details of the selected suite
    self:clear()
    
    self:addLine("Running suite: " .. suite.name, "header")
    self:addLine("", "info")
    
    for _, test in ipairs(suite.tests) do
        if test.result == "passed" then
            self:addLine(test.name .. " (" .. tostring(test.duration) .. "ms)", "pass")
        elseif test.result == "skipped" then
            self:addLine('SKIPPED ' .. test.name, "skipped")
        elseif test.result == "failed" then
            self:addLine(test.name, "fail")
            self:addLine("    Test failed with assertion error:", "fail", false)
            self:addLine("    " .. tostring(test.error), "fail", false)
        end
        self:addLine("", "info")
    end

    self:addLine("", "info")
    local passed = 0
    local failed = 0
    for _, test in ipairs(suite.tests) do
        if test.result == "passed" then passed = passed + 1 end
        if test.result == "failed" then failed = failed + 1 end
    end

    self:addLine(string.format("Summary: %d passed, %d failed, %d total",
                                          passed, failed, #suite.tests), "warning")
    self:addLine("", "info")
    self:addLine("", "info")
end

return TestConsolePanel
local TestScrollPanel = require("ui.test-scrollpanel")
local TestListPanel = {}
TestListPanel.__index = TestListPanel

function TestListPanel:new(x, y, width, height, suites)
    local self = setmetatable({}, TestListPanel)
    self.scroll = TestScrollPanel:new(x, y, width, height)
    self.suites = suites
    self.x, self.y, self.width, self.height = x, y, width, height
    self.onSelect = nil
    self.selectedSuite = nil
    self.hoveredSuite = nil
    return self
end

function TestListPanel:draw()
    -- Background
    love.graphics.setColor(0.08, 0.08, 0.08, 0.95)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 8, 8)

    self.scroll:drawStart()

    local y = self.y + 40
    local spacing = 8
    local font = love.graphics.getFont()
    local lineHeight = font:getHeight()

    for i, suite in ipairs(self.suites) do
       local boxX = self.x + 10
        local boxWidth = self.width - 20
        local textWidth = boxWidth - 50

        -- Calculate text height for suite name
        local _, nameLines = font:getWrap(suite.name, textWidth)
        local nameHeight = #nameLines * lineHeight
        
        -- Calculate dynamic item height
        local baseHeight = 48  -- Minimum height for status circle and info
        local itemHeight = math.max(baseHeight, nameHeight + 32)  -- 32px for padding and info line
        
        local boxY = y
        local boxHeight = itemHeight

        -- Check if selected or hovered
        local isSelected = self.selectedSuite == i
        local isHovered = self.hoveredSuite == i

        -- Background color based on state
        if isSelected then
            love.graphics.setColor(0.2, 0.4, 0.8, 0.8)
        elseif isHovered then
            love.graphics.setColor(0.25, 0.25, 0.25, 0.9)
        else
            love.graphics.setColor(0.18, 0.18, 0.18, 0.9)
        end
        
        love.graphics.rectangle("fill", boxX, boxY, boxWidth, boxHeight, 6, 6)

        love.graphics.setColor(0.35, 0.35, 0.35, 0.6)
        love.graphics.setLineWidth(1)
        love.graphics.rectangle("line", boxX, boxY, boxWidth, boxHeight, 6, 6)

        -- Test status indicator
        local passedTests = 0
        local failedTests = 0
        local skippedTests = 0
        for _, test in ipairs(suite.tests) do
            if test.result == "passed" then
                passedTests = passedTests + 1
            elseif test.result == "failed" then
                failedTests = failedTests + 1
            elseif test.result == "skipped" then
                skippedTests = skippedTests + 1
            end
        end

        -- Status circle
        local statusX = boxX + boxWidth - 25
        local statusY = boxY + 15
        if failedTests > 0 then
            love.graphics.setColor(0.8, 0.2, 0.2, 0.9)
        else
            if skippedTests > 0 then
                love.graphics.setColor(0.9, 0.7, 0.2, 0.9)
            else
                love.graphics.setColor(0.2, 0.8, 0.2, 0.9)
            end
        end
        love.graphics.circle("fill", statusX, statusY, 6)

        -- Suit's name
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(suite.name, boxX + 12, boxY + 8, textWidth, "left")

        -- Test information (positioned after the name text)
        local testInfo = string.format("%d tests (%d passed, %d failed, %d skipped)", 
                                     #suite.tests, passedTests, failedTests, skippedTests)
        love.graphics.setColor(0.7, 0.7, 0.7)
        local infoY = boxY + 8 + nameHeight + 4  -- 4px spacing between name and info
        love.graphics.printf(testInfo, boxX + 12, infoY, textWidth, "left")

        -- Arrow icon if selected
        if isSelected then
            love.graphics.setColor(0.9, 0.9, 0.9)
            local arrowY = boxY + (boxHeight / 2) - 5  -- Center the arrow vertically
            love.graphics.polygon("fill", boxX + boxWidth - 45, arrowY, 
                                          boxX + boxWidth - 40, arrowY + 5, 
                                          boxX + boxWidth - 45, arrowY + 10)
        end

        y = y + itemHeight + spacing
    end

    self.scroll.contentHeight = y - self.y
    self.scroll:drawEnd()
    

    -- Header
    love.graphics.setColor(0.08, 0.08, 0.08, 0.95)
    love.graphics.rectangle("fill", self.x, 10, self.width, 40, 8, 8)

    -- Panel border
    love.graphics.setColor(0.3, 0.3, 0.3, 0.8)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", self.x, 10, self.width, self.height, 8, 8)

    -- Panel title
    love.graphics.setColor(0.9, 0.9, 0.9)
    love.graphics.printf("Test Suites", self.x + 10, 18, self.width - 20, "left")

    -- Separator line
    love.graphics.setColor(0.4, 0.4, 0.4)
    love.graphics.line(self.x + 10, 40, self.x + self.width - 10, 40)
    
    
    self.scroll:drawScrollbar()
end

function TestListPanel:getItemAtPosition(mouseY)
    local localY = mouseY - self.y + self.scroll.scrollY
    
    -- Calculate item positions the same way as in draw()
    local y = 40  -- Start after header (relative to panel)
    local spacing = 8
    local font = love.graphics.getFont()
    local lineHeight = font:getHeight()
    local boxWidth = self.width - 20
    local textWidth = boxWidth - 50
    
    for i, suite in ipairs(self.suites) do
        -- Calculate text height for suite name
        local _, nameLines = font:getWrap(suite.name, textWidth)
        local nameHeight = #nameLines * lineHeight
        
        -- Calculate dynamic item height
        local baseHeight = 48
        local itemHeight = math.max(baseHeight, nameHeight + 32)
        
        -- Check if mouse is within this item
        if localY >= y and localY < y + itemHeight then
            return i
        end
        
        y = y + itemHeight + spacing
    end
    
    return nil
end

function TestListPanel:mousepressed(x, y, button)
    if button ~= 1 then return end

    -- Check if the mouse is inside the panel
    if not self:isMouseInside(x, y) then
        return
    end

    -- Check if the click is below the header (y >= self.y + 40)
    if y < self.y + 40 then
        return
    end

    local index = self:getItemAtPosition(y)
    if index then
        local suite = self.suites[index]
        if suite then
            self.selectedSuite = index
            if self.onSelect then
                self.onSelect(suite)
            end
        end
    end

    self.scroll:mousepressed(x, y, button)
end

function TestListPanel:mousemoved(x, y)
    if not self.scroll.isDragging and not self:isMouseInside(x, y) then
        self.hoveredSuite = nil
        return
    end
    
    local index = self:getItemAtPosition(y)
    if index and index > 0 and index <= #self.suites then
        self.hoveredSuite = index
    else
        self.hoveredSuite = nil
    end
    self.scroll:mousemoved(x, y)
end

function TestListPanel:wheelmoved(dx, dy, x, y)
    if self:isMouseInside(x, y) then
        self.scroll:handleWheelMoved(dx, dy)
    end
end

function TestListPanel:mousereleased(mx, my, button)
    self.scroll:mousereleased(mx, my, button)
end

function TestListPanel:isMouseInside(mx, my)
    return mx >= self.x and mx <= self.x + self.width and
           my >= self.y and my <= self.y + self.height
end

return TestListPanel
local TestScrollPanel = {}
TestScrollPanel.__index = TestScrollPanel

function TestScrollPanel:new(x, y, width, height)
    return setmetatable({
        x = x, y = y,
        width = width,
        height = height,
        scrollY = 0,
        contentHeight = 0,
        scrollSpeed = 30,
        smoothScroll = true,
        targetScrollY = 0,
        
        isDragging = false,
        dragStartY = 0,
        dragStartScrollY = 0
    }, TestScrollPanel)
end

function TestScrollPanel:handleWheelMoved(dx, dy)
    self.targetScrollY = math.max(0, 
        math.min(self.targetScrollY - dy * self.scrollSpeed, 
                 math.max(0, self.contentHeight - self.height)))
    
    if not self.smoothScroll then
        self.scrollY = self.targetScrollY
    end
end

function TestScrollPanel:update(dt)
    if self.smoothScroll then
        local diff = self.targetScrollY - self.scrollY
        if math.abs(diff) > 0.5 then
            self.scrollY = self.scrollY + diff * dt * 10
        else
            self.scrollY = self.targetScrollY
        end
    end
end

function TestScrollPanel:drawScrollbar()
    if self:isScrollbarVisible() then
        local scrollbarHeight = math.max(20, (self.height / self.contentHeight) * self.height)
        local scrollbarY = self.y + (self.scrollY / self.contentHeight) * self.height

        love.graphics.setColor(0.5, 0.5, 0.5, 0.7)
        love.graphics.rectangle("fill", self.x + self.width - 8, scrollbarY, 6, scrollbarHeight, 3, 3)
    end
end

function TestScrollPanel:isScrollbarVisible()
    return self.contentHeight > self.height
end

function TestScrollPanel:drawStart()
    love.graphics.setScissor(self.x, self.y, self.width, self.height)
    love.graphics.push()
    love.graphics.translate(0, -self.scrollY)
end

function TestScrollPanel:drawEnd()
    love.graphics.pop()
    love.graphics.setScissor()
end

function TestScrollPanel:isMouseInside(mx, my)
    return mx >= self.x + self.width - 8 and mx <= self.x + self.width - 2 and
           my >= self.y and my <= self.y + self.height
end

function TestScrollPanel:mousemoved(mx, my)
    if not self.isDragging then return end

    local deltaY = my - self.dragStartY
    local scrollbarHeight = self.height - 4
    local thumbHeight = math.max(20, scrollbarHeight * (self.height / self.contentHeight))
    local availableScrollArea = scrollbarHeight - thumbHeight
    
    if availableScrollArea > 0 then
        local scrollDelta = deltaY * (self.contentHeight - self.height) / availableScrollArea
        self.targetScrollY = self.dragStartScrollY + scrollDelta
        self.scrollY = self.targetScrollY -- Scroll immediately while dragging
        
        local maxScroll = math.max(0, self.contentHeight - self.height)
        self.targetScrollY = math.max(0, math.min(self.targetScrollY, maxScroll))
        self.scrollY = math.max(0, math.min(self.scrollY, maxScroll))
    end
end

function TestScrollPanel:mousepressed(mx, my, button)
    if button ~= 1 or not self:isScrollbarVisible() then return false end
    
    if self:isMouseInside(mx, my) then
        self.isDragging = true
        self.dragStartY = my
        self.dragStartScrollY = self.scrollY
        return true
    end
    
    return false
end

function TestScrollPanel:mousereleased(mx, my, button)
    if button == 1 then
        self.isDragging = false
    end
end

return TestScrollPanel
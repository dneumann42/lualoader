local M = Use.module {}

function M:onModuleLoad()
  print("LOADED MODULE BACKGROUND")
end

function M:update(dt)
end

function M:draw()
  love.graphics.setLineWidth(4)
  love.graphics.setColor(1.0, 1.0, 0.0, 1.0)
  love.graphics.rectangle("fill", 100, 100, 200, 200, 8, 8, 8, 8)
  love.graphics.setColor(0.0, 1.0, 1.0, 1.0)
  love.graphics.rectangle("line", 100, 100, 200, 200, 8, 8, 8, 8)
end

return M

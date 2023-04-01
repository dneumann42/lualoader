Use = require("lualoader")(
  function(path)
    return love.filesystem.getInfo(path).modtime
  end,
  load,
  function(path)
    return path .. ".lua"
  end
)

local bg = Use("background")

function love.load()
  Use:load()
end

function love.update(dt)
  -- bg:update(dt)
  -- Use:update()
end

function love.draw()
  bg:draw()
end

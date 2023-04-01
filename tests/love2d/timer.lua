-- Timer library for Love2D
-- Usage: 
-- 1. Require this module at the top of your file:
--    require("timer")
-- 2. Create a new timer object:
--    local myTimer = Timer.new()
-- 3. Set the timer's duration and callback function:
--    myTimer:set(2, function() print("Timer complete!") end)
-- 4. Start the timer:
--    myTimer:start()

local Timer = {}

function Timer.new()
  local self = {}
  self.duration = 0
  self.elapsedTime = 0
  self.isRunning = false
  self.callback = nil

  function self:set(duration, callback)
    self.duration = duration
    self.callback = callback
  end

  function self:start()
    self.isRunning = true
  end

  function self:stop()
    self.isRunning = false
    self.elapsedTime = 0
  end

  function self:update(dt)
    if not self.isRunning then
      return
    end

    self.elapsedTime = self.elapsedTime + dt

    if self.elapsedTime >= self.duration then
      self.isRunning = false
      self.elapsedTime = 0
      if self.callback then
        self.callback()
      end
    end
  end

  return self
end

return Timer

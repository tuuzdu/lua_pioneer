-- This script outputs Pioneer linear velocity in LPS

-- Simplification and caching math.abs calls
local abs = math.abs

-- Base pcb number of RGB LEDs
local ledNumber = 4
-- RGB LED control port initialize
local leds = Ledbar.new(ledNumber)

-- Maximum velocity values for each axis
local maxVx, maxVy, maxVz = 2, 2, 2

local function getVelocity()
    -- Reading velocity values from 3 axes
    vx, vy, vz = Sensors.lpsVelocity() 
    vx, vy, vz = abs(vx), abs(vy), abs(vz)
    -- X velocity value output to 1st LED via green color intensity
    leds:set(0, 0, vx % maxVx / maxVx, 0)
    -- Z velocity value output to 2nd and 3rd LEDs via violet color intensity
    leds:set(1, vz % maxVz / maxVz, 0, vz % maxVz / maxVz)
    leds:set(2, vz % maxVz / maxVz, 0, vz % maxVz / maxVz)
    -- Y velocity value otput to 4tg LED via blue color intensity
    leds:set(3, 0, 0, vy % maxVy / maxVy)
end

-- Required callback function to process events
function callback (event)
end

-- Timer creation, that calls our function each 0.1 second
getVelocityTimer = Timer.new(0.1, function () getVelocity() end)
-- Timer start
getVelocityTimer:start()

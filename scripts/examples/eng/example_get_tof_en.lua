-- This script outputs laser distance meter value

-- Simplification and caching laser distance meter value reading calls 
local range = Sensors.range
-- Base pcb number of RGB LEDs
local ledNumber = 4
-- RGB LED control port initialize
local leds = Ledbar.new(ledNumber)

-- Function changes color on all LEDs
local function changeColor(red, green, blue)
	-- Changing color on each LED one after another
    for i = 0, ledNumber - 1, 1 do
        leds:set(i, red, green, blue)
    end
end

-- Fucntion reads values from laser distance meter
local function getRange()
    -- Reading distance meter value in meters
    distance = range()
    -- If distance meter is in effective range (it outputs approximately 8.19 meters when it is not)
    if (distance < 8) then
        -- Changing green LED brightness according to distance
        -- (~1.5 meters is maximum range that distance meter on extension modules board and optical flow module
        r, g, b = 0, math.abs(distance / 1.5), 0
    else -- If distance cannot be measured we change LEDs colors to red
        r, g, b = 1, 0, 0
    end
    -- Changing LEDs color according to set value
    changeColor(r, g, b)
end

-- Required callback function to process events
function callback(event)
end

-- Timer creation, that calls our function each 0.1 second
getRangeTimer = Timer.new(0.1, function() getRange() end)
-- Timer start
getRangeTimer:start()



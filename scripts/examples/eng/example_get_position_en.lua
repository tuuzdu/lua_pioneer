-- This script outputs Pioneer coordinates in LPS (Locus)

-- Simplification and caching math.abs calls 
local abs = math.abs
-- Base pcb number of RGB LEDs
local ledNumber = 4
-- RGB LED control port initialize
local leds = Ledbar.new(ledNumber)

-- Maximum coordinate value in LPS around axis X
local maxX = 3	
-- Maximum coordinate value in LPS around axis Y 
local maxY = 2.5
-- Maximum coordinate value in LPS around axis Z
local maxZ = 3.3

-- Changes color according to axis and brightness
local function changeColor(value, brightness)
    -- Condition checks axis to change color accordingly
    if value == x then -- If axis is X
    	if value > 0 then -- If coordinate value is positive
    		leds:set(0, 0, brightness, 0) -- We change 1st LED color to green
    	else -- If coordinate is negative
    		leds:set(0, brightness, brightness, 0) -- We change 1st LED color to yellow
    	end
    elseif value == y then -- If axis is Y
    	if value > 0 then -- if coordinate value is positive
	    	leds:set(3, 0, 0, brightness) -- We change 4th LED to blue
	    else -- if coordinate balue is negative
	    	leds:set(3, brightness, 0, brightness) -- We change 4th LED color to violet
	    end
	elseif value == z then -- If axis is Z
		leds:set(1, brightness, 0, 0) -- We change 3rd LED color to red
    	leds:set(2, brightness, 0, 0) -- We change 3rd LED color to red
    end
end 

local function getPosition()
    -- Reading values from 3 axes
    x, y, z = Sensors.lpsPosition()
    brightnessX, brightnessY, brightnessZ = 0, 0, 0
    -- X coordinate value output
    brightnessX = 0.5 * abs(x) / maxX -- LED brightness according to coordinate value
    changeColor(x, brightnessX)		  -- Changing LED color 
    -- Y coordinate value output
    brightnessY = 0.5 * abs(y) / maxY
    changeColor(y, brightnessY)
    -- Z coordinate value output
    brightnessZ = 0.5 * z / maxZ
    changeColor(z, brightnessZ)
end

-- Required callback function to process events
function callback (event)
end

-- Timer creation, that calls our function each 0.1 second
getPositionTimer = Timer.new(0.1, function() getPosition() end)
-- Timer start
getPositionTimer:start()

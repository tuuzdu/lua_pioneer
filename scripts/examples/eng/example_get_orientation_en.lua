-- This script shows drone orientation angles

-- Simplification and caching math.abs calls 
local abs = math.abs
-- Base pcb number of RGB LEDs
local ledNumber = 4
-- RGB LED control port initialize
local leds = Ledbar.new(ledNumber)

-- Максимальные значения крена, тангажа и рыскания для удобства вывода информации
-- Maximum values for roll, pitch and yaw for user-friendly output
local maxRoll, maxPitch, maxYaw = 180, 90, 180

local function getOrientation()
    -- Reading orientation values from 3 axes
    roll, pitch, yaw = Sensors.orientation() 
    -- Getting their absolute values
    roll, pitch, yaw = abs(roll), abs(pitch), abs(yaw)
    -- Roll output on 1st LED via green light intensity
    leds:set(0, 0, roll / maxRoll, 0)
    --[[ Yaw output on 2nd and 3rd LEDs via violet light intensity
    Unless engines are started Pioneer is calibrating, thus only change of angle is going to be shown,
    after engines are armed, expected orientation angle will be seen ]]
    leds:set(1, yaw / maxYaw, 0, yaw / maxYaw)
    leds:set(2, yaw / maxYaw, 0, yaw / maxYaw)
    -- Pitch output on 4th LED via blue light intensity
    leds:set(3, 0, 0, pitch / maxPitch)
end

-- Required callback function to process events
function callback (event)
end

-- Timer creation, that calls our function each 0.1 second
getOrientationTimer = Timer.new(0.1, function () getOrientation() end)
-- Timer start
getOrientationTimer:start()
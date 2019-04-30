-- This script outputs accelerometer values to LEDs

-- Simplification and caching math.abs calls
local abs = math.abs
-- Base pcb number of RGB LEDs
local ledNumber = 4
-- RGB LED control port initialize
local leds = Ledbar.new(ledNumber)

--  Function reads values from accelerometer and outputs them to LEDs
local function getAccel()
    -- Reading values from accel
    ax, ay, az = Sensors.accel()
    -- Getting absolute values of accel readings
    ax, ay, az = abs(ax), abs(ay), abs(az)
    -- Acceleration around X axis output via 1st LED green color intensity
    leds:set(0, 0, ax % 10 / 10, 0)
    -- Acceleration around Z axis output via 2nd and 3rd LEDs violet color intensity
    leds:set(1, az % 10 / 10, 0, az % 10 / 10)
    leds:set(2, az % 10 / 10, 0, az % 10 / 10)
    -- Acceleration around Y axis output via 4th LED blue color intensity
    leds:set(3, 0, 0, ay % 10 / 10)
    --[[ Free-fall acceleration is taken into account so Z axis LEDs are constanly on when standing still on a surface
    but they will stop when the drone is free-falling. Whne rotating Pioneer around X and Y axes, free-fall acceleration
    will project onto those axes and intensivity of mentioned LEDs will raise accordingly ]] 
end

-- Required callback function to process events
function callback(event)
end

-- Timer creation, that calls our function each 0.1 second
getAccelTimer = Timer.new(0.1, function () getAccel() end)
-- Timer start
getAccelTimer:start()

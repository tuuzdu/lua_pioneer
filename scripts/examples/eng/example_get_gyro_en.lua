-- This script output gyroscope values to LEDs

-- Simplification and caching math.abs calls
local abs = math.abs
-- Base pcb number of RGB LEDs
local ledNumber = 4
-- RGB LED control port initialize
local leds = Ledbar.new(ledNumber)

-- Function reads values from gyroscope and outputs them to LEDs
local function getGyro()
    -- Reading values from gyro
    gx, gy, gz = Sensors.gyro()
    -- Getting absolute values of gyro readings
    gx, gy, gz = abs(gx), abs(gy), abs(gz)
    -- Angular velocity around X axis output via 1st LED green color intensity
    leds:set(0, 0, gx % 10 / 10, 0)
    -- Angular velocity around Z axis output via 2nd and 3rd LEDs violet color intensity
    leds:set(1, gz % 10 / 10, 0, gz % 10 / 10)
    leds:set(2, gz % 10 / 10, 0, gz % 10 / 10)
    -- Angular velocity around Y axis output via 4th LED blue color intensity
    leds:set(3, 0, 0, gy % 10 / 10)
end

-- Required callback function to process events
function callback(event)
end

-- Timer creation, that calls our function each 0.1 second
getGyroTimer = Timer.new(0.1, function () getGyro() end)
-- Timer start
getGyroTimer:start()
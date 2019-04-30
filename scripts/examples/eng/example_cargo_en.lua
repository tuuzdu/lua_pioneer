-- This script shows how to control magnet on a cargo module

-- Magnet control port (PC3) initialize for Pioneer_Base v 1.2
local magnet = Gpio.new(Gpio.C, 3, Gpio.OUTPUT)
-- Magnet control port (PA1) initialize for Pioneer_Base v 1.1 (uncomment line below and comment line above) 
-- local magnet = Gpio.new(Gpio.A, 1, Gpio.OUTPUT)

-- Total number of LEDs (4 on base pcb and 4 on a cargo module)
local led_number = 8 
-- RGB LED control port initialize
local leds = Ledbar.new(led_number) 
-- Magnet state (switched on initially)
local magnet_state = true

-- Function that sets LEDs color based of magnet state
local function setLed(state)
    if (state == true) then
        color = {1,1,1}                  -- If magnet is on, color is white
    else
        color = {0,0,0}                  -- If magnet is off, color is black (LEDs are off)
    end
    for i = 4, led_number - 1, 1 do      -- Set color for each of LEDs
        leds:set(i, table.unpack(color)) 
    end
end

-- Magnet switch function
local function toggleMagnet()
    if (magnet_state == true) then  -- If magnet is on, we switch it off
        magnet:reset()
    else                            -- If magnet is off, we switch it on
        magnet:set()
    end
    magnet_state = not magnet_state -- Changing magnet state value to appropriate state
end

-- Required callback function to process events
function callback(event)
end

-- Timer creation, that calls our function each second
cargoTimer = Timer.new(1, function ()
    toggleMagnet()
    setLed(magnet_state)
end)
-- Timer start
cargoTimer:start()

-- This script shows how to fly to different points in Positioning system

-- Simplification and caching table.unpack calls
local unpack = table.unpack

-- Base pcb number of RGB LEDs
local ledNumber = 4
-- RGB LED control port initialize
local leds = Ledbar.new(ledNumber)

-- Function changes color on all LEDs
local function changeColor(color)
    -- Changing color on each LED one after another
    for i=0, ledNumber - 1, 1 do
        leds:set(i, unpack(color))
    end
end 

-- Table of colors in RGB form for changeColor function
local colors = {
        {1, 0, 0}, -- red
        {0, 1, 0}, -- green
        {0, 0, 1}, -- blue
        {1, 1, 0}, -- yellow
        {1, 0, 1}, -- violet
        {0, 1, 1}, -- cyan
        {1, 1, 1}, -- white
        {0, 0, 0}  -- black/switched off
}

-- Flight mission points table formatted as {x,y,z}
local points = {
        {0, 0, 0.7},
        {0, 1, 0.7},
        {0.5, 1, 0.7},
        {0.5, 0, 0.7}
}
-- Current point variable
local curr_point = 1

-- Function that changes LEDs color and flies to the next point
local function nextPoint()
    -- Current color. % - modulo, # - table size
    -- This expression is used in order to circle through color's table even it is not the same size as points table
    curr_color = ((curr_point - 1) % (#colors - 2)) + 1
    -- Changing LEDs color
    changeColor(colors[curr_color])
    -- Flying to the next point if its number is less than number of points in the table "points"
    if(curr_point <= #points) then
        Timer.callLater(1, function()
            -- Fly to point command in Positioning system
            ap.goToLocalPoint(unpack(points[curr_point]))
            -- Current point variable increase
            curr_point = curr_point + 1
        end)
    -- Landing initiate if number of current point exceeds number of points in total
    else
        Timer.callLater(1, function()
            -- Landing command
            ap.push(Ev.MCE_LANDING)
        end)
    end
end

-- Event processing function called automatically by autopilot
function callback(event)
    -- After Pioneer reaches Flight_com_homeAlt, it start mission flight
    if(event == Ev.ALTITUDE_REACHED) then
        nextPoint()
    end
    -- When Pioneer reaches current point it initiates flight to next point
    if(event == Ev.POINT_REACHED) then
        nextPoint()
    end
    -- After Pioneer lands, it switches off LEDs
    if (event == Ev.COPTER_LANDED) then
        changeColor(colors[8])
    end
end



-- Pre-start preparations
ap.push(Ev.MCE_PREFLIGHT)
-- Changing LEDs color to white
changeColor(colors[7])
-- Timer, that calls takeoff function after 2 seconds
Timer.callLater(2, function() ap.push(Ev.MCE_TAKEOFF) end)

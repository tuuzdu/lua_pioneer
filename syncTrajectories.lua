local boardNumber = boardNumber

local delta = TimeInfo.new("TimeDelta")
local launch = TimeInfo.new("LaunchTime")

local led_count = 4
local leds = Ledbar.new(led_count)

local curr_state = "START"

local ledStateRed = false
local ledStateGreen = false
local ledStateBlue = false

local time_transition = 8

local current_point = 0
local old_point = 1 
local start = false
local time_delta = 0
local time_start_global = 0

local point =  { 
		    	{{x=1000, y=0, z=1100}, {x=0, y=1000, z=1100}, {x=-1000, y=0, z=1100}, {x=0, y=-1000, z=1100}, {x=250, y=-250, z=1100}},
			{{x=0, y=1000, z=1100}, {x=-1000, y=0, z=1100}, {x=0, y=-1000, z=1100}, {x=1000, y=0, z=1100}, {x=250, y=250, z=1100}},			
			{{x=-1000, y=0, z=1100}, {x=0, y=-1000, z=1100}, {x=1000, y=0, z=1100}, {x=0, y=1000, z=1100}, {x=-250, y=250, z=1100}}
			
		}




leds:set(0, {r=1, g=0.5, b=0})
leds:set(3, {r=1, g=0.5, b=0})



if boardNumber < 1 then
	boardNumber = 1
end
-- заменить 3 на длинну массива
if boardNumber > 3 then
	boardNumber = 3
end



local function allLED(red,green,blue)
		for i = 0, led_count - 1, 1 do
        		leds:set(i, {r=red, g=green, b=blue})
      		end
end

local function LEDRed()
	if ledStateRed then
		ledStateRed = false
		leds:set(0, {r=0, g=0 , b=0})
	else 
		ledStateRed = true
		leds:set(0, {r=1, g=0 , b=0})
	end 
end

local function LEDGreen()
	if ledStateGreen then
		ledStateGreen = false
		leds:set(3, {r=0, g=0 , b=0})
	else 
		ledStateGreen = true
		leds:set(3, {r=0, g=1 , b=0})
	end 
end

local function LEDBlue()
	if ledStateBlue then
		ledStateBlue = false
		leds:set(1, {r=0, g=0 , b=0})
		leds:set(2, {r=0, g=0 , b=0})
	else 
		ledStateBlue = true
		leds:set(1, {r=0, g=0 , b=1})
		leds:set(2, {r=0, g=0 , b=1})
	end 
end


local function get_global_time()	
	return time() +  delta:retrieve()
end

action = {
	["START"] = function(x)
		leds:set(1, {r=1, g=0, b=1})
		leds:set(2, {r=1, g=0, b=1})
		ap.push(Ev.MCE_PREFLIGHT)
		sleep(2)
		ap.push(Ev.MCE_TAKEOFF)
		time_start_global = launch:retrieve()
		-- переход в следующее состояние 
		curr_state = "LANDING"
	end,
	["LANDING"] = function (x)
 		ap.push(Ev.MCE_LANDING)
		curr_state = "START"
	end
	
}



function callback(event)

	if (event == Ev.SHOCK) then
		allLED(1,0,0)
	end

	if (event == Ev.CONTROL_FAIL) then
		allLED(1,0,0)
	end

	if (event == Ev.SYNC_START) then
		LEDGreen()
		start = false
		action[curr_state]()		
	end

	if (event == Ev.POINT_REACHED) then
		LEDRed()
	end

	if (event == Ev.POINT_DECELERATION) then
		--LEDBlue()
	end
	if (event == Ev.ALTITUDE_REACHED) then
		LEDRed()
		ap.updateYaw(0.001, 0)
		start = true
	end
end


function loop() 
	if start then
		local time_from_start = math.abs (get_global_time() - time_start_global)
		current_point = math.floor (time_from_start / time_transition)  
		current_point = ( current_point % 5 ) + 1 -- заменить 5 на длинну массива 
		if current_point ~= old_point then

			LEDBlue()
			ap.goToLocalPoint(point[boardNumber][current_point])
			old_point = current_point	
		
		end
	end


end

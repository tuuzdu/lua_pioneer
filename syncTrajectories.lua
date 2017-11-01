local function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end


local board_number = boardNumber
local start_formations = false
local start_init_pose = false
local time_delta = 0
local time_start_global = 0

--local delta = TimeInfo.new("TimeDelta")
--local launch = TimeInfo.new("LaunchTime")

--local led_count = 4
--local leds = Ledbar.new(led_count)


-- Trajectories[a][b][c], где a - номер формации, b - номер борта, с - соответственно x, y, z, A, B
-- Trajectories.initial_pose[b][c], где b - номер борта, с - соответственно x, y, z
Trajectories = {
	initial_pose = { 
		{-0.6, 0.3, 0},
		{0.6, 0.3, 0},
		{-0.6, -0.3, 0},
		{0.6, -0.3, 0}
	},
	{ 
		xy_first = false, 
		{0.00666667, 0.6, 0.6, 0, 0},
		{0.3, 0.2, 0.2, 0, 0},
		{-0.3, 0.2, 0.2, 0, 0},
		{0.0133333, -0.2, -0.2, 0, 0}
	},
	{ 
		xy_first = true, 
		{-0.6, 0.3, 0, 0, 0},
		{0.6, 0.3, 0, 0, 0},
		{-0.6, -0.3, 0, 0, 0},
		{0.6, -0.3, 0, 0, 0}
	},
	{ 
		xy_first = false, 
		{0.00666667, 0.2, 0.2, 0, 0.23284},
		{0.00666667, 0.6, 0.6, 0, -0.140381},
		{-0.00666667, -0.6, -0.6, 0, 0.313945},
		{0.00666667, -0.2, -0.2, 0, 0}
	},
	{ 
		xy_first = true, 
		{-0.6, 0.3, 0, 0, 0.23284},
		{0.6, 0.3, 0, 0, -0.140381},
		{-0.6, -0.3, 0, 0, 0.313945},
		{0.6, -0.3, 0, 0, 0}
	},
	{ 
		xy_first = false, 
		{-0.293333, 0.6, 0.6, 0, 0},
		{0.306667, 0.2, 0.2, 0, 0},
		{-0.3, -0.2, -0.2, 0, 0},
		{0.313333, -0.6, -0.6, 0, 0}
	},
	{ 
		xy_first = true, 
		{-0.6, 0.3, 0, 0, 0},
		{0.6, 0.3, 0, 0, 0},
		{-0.6, -0.3, 0, 0, 0},
		{0.6, -0.3, 0, 0, 0}
	}
}


--print(dump(Trajectories))
--print(Trajectories[1][2][1])
--print(Trajectories.initial_pose[1][1])

local function redLeds()
	for i = 0, led_count - 1, 1 do
		leds:set(i, {r=1, g=0, b=0})
	end
end

local function setFormation( pose )
	if pose.initial_pose then
		ap.goToLocalPoint(	
			x = pose.initial_pose[board_number][1],
			y = pose.initial_pose[board_number][2],
			z = pose.initial_pose[board_number][3] )
			--time = {} )
	end
end

function callback(event)

	if (event == Ev.SHOCK) then
		redLeds()

	elseif (event == Ev.CONTROL_FAIL) then
		redLeds()

	elseif (event == Ev.SYNC_START) then
		if start_formations then
			ap.push(Ev.MCE_LANDING)
		else
			ap.push(Ev.MCE_PREFLIGHT)
			sleep(2)
			ap.push(Ev.MCE_TAKEOFF)

			time_start_global = launch:retrieve()		
		end

	elseif (event == Ev.POINT_REACHED) then
		sleep (2)
		if start_init_pose then
			start_init_pose = false
			start_formations = true
		end

	elseif (event == Ev.POINT_DECELERATION) then
		

	elseif (event == Ev.ALTITUDE_REACHED) then
		start_init_pose = true
		ap.updateYaw(0.001, 0) -- 0.001 ???
		setFormation(Trajectories.initial_pose)
	end
end


function loop() 
--[[
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
]]--

end


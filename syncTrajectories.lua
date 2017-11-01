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


local boardNumber = boardNumber

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
print(Trajectories[1][2][1])
print(Trajectories.initial_pose[1][1])



function callback(event)
--[[
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
]]--
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


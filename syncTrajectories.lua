local led_count = 29
local matrix_count = 1
local led_offset = 4
local leds = Ledbar.new(led_count)
local colors = {	purple = 	{r=1, g=0, b=1}, 
					cyan = 		{r=0, g=1, b=1}, 
					yellow = 	{r=1, g=1, b=0}, 
					blue = 		{r=0, g=0, b=1}, 
					red = 		{r=1, g=0, b=0}, 
					green = 	{r=0, g=1, b=0}, 
					white = 	{r=1, g=1, b=1}, 
					black = 	{r=0, g=0, b=0}	}


local ledMatrix = {}

for i = 1, matrix_count + 1, 1 do
	ledMatrix[i] = colors.black
end

local board_number = boardNumber
local start_formations = false
local start_init_pose = false
local time_delta = 0
local time_start_global = 0
local time_transition = 5

--local current_formation = 0

local delta = TimeInfo.new("TimeDelta")
local launch = TimeInfo.new("LaunchTime")

--local led_count = 4
--local leds = Ledbar.new(led_count)


-- forms[a][b][c], где a - номер формации, b - номер борта, с - соответственно x, y, z, A, B
-- forms[0][b][c] - начальная формация, где b - номер борта, с - соответственно x, y, z
local forms = {
	[0] = { 
		{-0.6, 0.3, 0.2},
		{0.6, 0.3, 0.2},
		{0, 0, 0.5},
		{0.6, -0.3, 0.2}
	},
	{ 
		xy_first = false, 
		{0.00666667, 0.6, 0.6, 0, 0},
		{0.3, 0.2, 0.2, 0, 0},
		{1, 1, 1.2, 0, 0},
		{0.0133333, -0.2, -0.2, 0, 0}
	},
	{ 
		xy_first = true, 
		{-0.6, 0.3, 0, 0, 0},
		{0.6, 0.3, 0, 0, 0},
		{0, 0, 0.5, 0, 0},
		{0.6, -0.3, 0, 0, 0}
	},
	{ 
		xy_first = false, 
		{0.00666667, 0.2, 0.2, 0, 0.23284},
		{0.00666667, 0.6, 0.6, 0, -0.140381},
		{-1, 1, 1.2, 0, 0},
		{0.00666667, -0.2, -0.2, 0, 0}
	},
	{ 
		xy_first = true, 
		{-0.6, 0.3, 0, 0, 0.23284},
		{0.6, 0.3, 0, 0, -0.140381},
		{0, 0, 0.5, 0, 0},
		{0.6, -0.3, 0, 0, 0}
	},
	{ 
		xy_first = false, 
		{-0.293333, 0.6, 0.6, 0, 0},
		{0.306667, 0.2, 0.2, 0, 0},
		{1, -1, 1.2, 0, 0},
		{0.313333, -0.6, -0.6, 0, 0}
	},
	{ 
		xy_first = true, 
		{-0.6, 0.3, 0, 0, 0},
		{0.6, 0.3, 0, 0, 0},
		{0, 0, 0.5, 0, 0},
		{0.6, -0.3, 0, 0, 0}
	}
}

local function setSysLeds( color )
	for i = 0, led_offset - 1, 1 do
		leds:set(i, color)
	end
end


local function updateMatrix()
	for i = led_offset, led_count - 1, 1 do
		leds:set(i, ledMatrix[i-led_offset + 1])
	end
end


local function fillMatrix( colors )
	for i = 1, matrix_count + 1, 1 do
		ledMatrix [i] = colors
	end
end




local function getGlobalTime()	
	return time() + delta:retrieve()
end

local function setInitFormation( pose )
		ap.goToLocalPoint({
			x = pose[1],
			y = pose[2],
			z = pose[3] 
		})
			--time = {} )
end

local function setFormationXYAfter( curr_fr, t )
	local xi0 = forms[curr_fr - 1][board_number][1]
	local xi1 = forms[curr_fr][board_number][1]
	local yi0 = forms[curr_fr - 1][board_number][2]
	local yi1 = forms[curr_fr][board_number][2]
	local Ai = forms[curr_fr][board_number][4]
	local Bi = forms[curr_fr][board_number][5]

	local xi = xi0 + (xi1 - xi0) * t + Ai * (t^2 - t)
	local yi = yi0 + (yi1 - yi0) * t + Bi * (t^2 - t)

	ap.goToLocalPoint({
		x = xi,
		y = yi,
		z = forms[curr_fr][board_number][3] 
	})
		--time = {} 
end

local function setFormationXYFirst( curr_fr, t )
	local xi0 = forms[curr_fr - 1][board_number][1]
	local xi1 = forms[curr_fr][board_number][1]
	local yi0 = forms[curr_fr - 1][board_number][2]
	local yi1 = forms[curr_fr][board_number][2]
	local Ai = forms[curr_fr][board_number][4]
	local Bi = forms[curr_fr][board_number][5]

	local xi = xi0 + (xi1 - xi0) * t + Ai * (t^2 - t)
	local yi = yi0 + (yi1 - yi0) * t + Bi * (t^2 - t)

	ap.goToLocalPoint({
		x = xi,
		y = yi,
		z = forms[curr_fr - 1][board_number][3] 
	})
		--time = {} 
end

local function setFormationZAfter( curr_fr )
	ap.goToLocalPoint({
		x = forms[curr_fr][board_number][1],
		y = forms[curr_fr][board_number][2],
		z = forms[curr_fr][board_number][3] 
	})

end

local function setFormationZFirst( curr_fr )
	ap.goToLocalPoint({
		x = forms[curr_fr - 1][board_number][1],
		y = forms[curr_fr - 1][board_number][2],
		z = forms[curr_fr][board_number][3] 
	})
end

function callback( event )

	if (event == Ev.SHOCK) then
		setSysLeds(colors.red)

	elseif (event == Ev.CONTROL_FAIL) then
		setSysLeds(colors.red)

	elseif (event == Ev.SYNC_START) then
		setSysLeds(colors.cyan)

		if start_formations then
			ap.push(Ev.MCE_LANDING)
		else
			time_start_global = launch:retrieve() + 2 * time_transition
			ap.push(Ev.MCE_PREFLIGHT)
			sleep(1)
			ap.push(Ev.MCE_TAKEOFF)	
		end

	elseif (event == Ev.POINT_REACHED) then
		if start_init_pose then
			start_init_pose = false
			start_formations = true
		end

	elseif (event == Ev.POINT_DECELERATION) then
		

	elseif (event == Ev.ALTITUDE_REACHED) then
		start_init_pose = true
		--ap.updateYaw(0.001, 0) 
		setInitFormation(forms[0][board_number])
	end
end

local mass_color = {colors.green, colors.yellow, colors.blue, colors.red, colors.purple, colors.white}


function loop() 

	if start_formations then

		local time_from_start = math.abs( time() + delta:retrieve() - time_start_global)

		local current_formation = math.floor(time_from_start / (2 * time_transition)) + 1
		--local current_formation = math.floor(time_from_start / (2 * time_transition))
		--current_formation = (current_formation % 6) + 1

		local t_formation = (time_from_start / (2 * time_transition)) - math.floor(time_from_start / (2 * time_transition)) 
		local t = (time_from_start / time_transition) - math.floor(time_from_start / time_transition)

		if current_formation >= (#forms + 1) then
			ap.push(Ev.MCE_LANDING)
		end
		setSysLeds(mass_color[current_formation])

		if t_formation < 0.5 then
			if forms[current_formation].xy_first then
				setFormationXYFirst( current_formation, t ) 
			else
				setFormationZFirst( current_formation )
			end
		else
			if forms[current_formation].xy_first then
				setFormationZAfter( current_formation )
			else
				setFormationXYAfter( current_formation, t ) 
			end

		end

	end
end

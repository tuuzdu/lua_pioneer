local led_count = 29
local matrix_count = 25
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

leds:setMatrix(colors.black)

local board_number = 1  ---boardNumber
local start_formations = false
local start_init_pose = false
local time_delta = 0
local time_start_global = 0
local time_transition = 5


local delta = TimeInfo.new("TimeDelta")
local launch = TimeInfo.new("LaunchTime")


-- forms[a][b][c], где a - номер формации, b - номер борта, с - соответственно x, y, z, A, B
-- forms[0][b][c] - начальная формация, где b - номер борта, с - соответственно x, y, z
local forms = {
[0] = {
{0, -0.6, 1}
},
{
xy_first = false,
{0, -1.4, 1.5, 0, 0.624402}
},
{
xy_first = true,
{0, -0.6, 1, 0, 0.67049}
},
{
xy_first = false,
{0.00666667, -1.4, 1.5, 0, 0}
},
{
xy_first = true,
{0, -0.6, 1, 0, 0}
},
{
xy_first = false,
{0, -1.4, 1.5, 0, 0.67049}
},
{
xy_first = true,
{0, -0.6, 1, 0, 0.67049}
},
{
xy_first = false,
{0.3, -1.4, 1.5, 0, 0}
},
{
xy_first = true,
{0, -0.6, 1, 0, 0}
}
}


-- Pause in end points
-- for i = #forms - 1, 1, -2 do
-- 	table.insert(forms, i, forms[i])
-- end


local function setSysLeds( color )
	for i = 0, led_offset - 1, 1 do
		leds:set(i, color)
	end
end


-- local function updateMatrix()
-- 	for i = led_offset, led_count - 1, 1 do
-- 		leds:set(i, ledMatrix[i-led_offset + 1])
-- 	end
-- end


-- local function fillMatrix( colors )
-- 	leds:setMatrix(colors)
-- end


local function setInitFormation( pose )
	ap.goToLocalPoint({
		x = pose[1],
		y = pose[2],
		z = pose[3] 
	})
end

local function formationXY( curr_fr, t, sequence )
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
		z = forms[curr_fr - sequence][board_number][3] 
	})
end


local function formationZ( curr_fr, sequence )
	ap.goToLocalPoint({
		x = forms[curr_fr - sequence][board_number][1],
		y = forms[curr_fr - sequence][board_number][2],
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
			start_formations = false
			ap.push(Ev.MCE_LANDING)
		else
			leds:setMatrix(colors.purple)

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

	elseif (event == Ev.ALTITUDE_REACHED) then
		start_init_pose = true
		setInitFormation(forms[0][board_number])
	end
end


function loop() 

	if start_formations then

		local time_from_start = math.abs(time() + delta:retrieve() - time_start_global)

		local t_x1 = time_from_start / (2 * time_transition)
		local t_x2 = time_from_start / time_transition

		local current_formation = math.floor(t_x1) + 1
		local t_formation = t_x1 - math.floor(t_x1)
		local t = t_x2 - math.floor(t_x2)

		if current_formation >= (#forms + 1) then
			start_formations = false
			ap.push(Ev.MCE_LANDING)
		end


		if t_formation < 0.5 and start_formations then

			if forms[current_formation].xy_first then
				formationXY( current_formation, t, 1 ) 
			else
				formationZ( current_formation, 1 )
			end

		elseif start_formations then

			if forms[current_formation].xy_first then
				formationZ( current_formation, 0 )
			else
				formationXY( current_formation, t, 0 ) 
			end
		end

		sleep (0.1)
	end
end

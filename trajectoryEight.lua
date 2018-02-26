-- создание порта управления магнитом
local magnet = Gpio.new(Gpio.A, 1, Gpio.OUTPUT)

-- создание порта управления светодиодом
local ledbar = Ledbar.new(29)

local colors = {	red = 		{1, 0, 0},							
					green = 	{0, 1, 0}, 
					blue = 		{0, 0, 1},
					purple = 	{1, 0, 1}, 		
					cyan = 		{0, 1, 1}, 
					yellow = 	{1, 1, 0}, 
					white = 	{1, 1, 1}, 
					black = 	{0, 0, 0}	}	


local ledStateRed = false
local ledStateGreen = false
local ledStateBlue = false
-- переменная текущего состояния
local curr_state = "START"
local angle = 1.5

local function LEDRed()
	if ledStateRed then
		ledStateRed = false
		ledbar:set(0, 0, 0, 0)
	else 
		ledStateRed = true
		ledbar:set(0, 1, 0, 0)
	end 
end

local function LEDGreen()
	if ledStateGreen then
		ledStateGreen = false
		ledbar:set(3, 0, 0, 0)
	else 
		ledStateGreen = true
		ledbar:set(3, 0, 1 , 0)
	end 
end

local function LEDBlue()
	if ledStateBlue then
		ledStateBlue = false
		ledbar:set(1, 0, 0, 0)
		ledbar:set(2, 0, 0, 0)
	else 
		ledStateBlue = true
		ledbar:set(1, 0, 0, 1)
		ledbar:set(2, 0, 0, 1)
	end 
end

-- таблица функций, вызываемых в зависимости от состояния
action = {
	["START"] = function(x)
		ledbar:set(1, 1, 0, 1)
		ledbar:set(2, 1, 0, 1)
		-- sleep(2) 
		ap.push(Ev.MCE_PREFLIGHT)
		-- sleep(2)
		ap.push(Ev.MCE_TAKEOFF)
		-- переход в следующее состояние
		curr_state = "_PIONEER_POINT_2"
	end,
	["_PIONEER_POINT_2"] = function (x)
		
		ap.goToLocalPoint(0, 0, 1.2)
		-- переход в следующее состояние
		curr_state = "_PIONEER_LED_2"
	end,
	["_PIONEER_LED_2"] = function (x)
		x1 = 1.5 * math.cos(angle)
		y1 = 0.75 * math.sin(2 * angle)
		-- x1 = 2500 + 1500 * math.cos(angle)
		-- y1 = 2500 + 750 * math.sin(2 * angle)
		-- angle = angle + 0.1
		ap.goToLocalPoint(x1, y1, 1.2)
		-- переход в следующее состояние
		--curr_state = "_PIONEER_POINT_2"
	end
	
}

-- функция обработки событий, автоматически вызывается автопилотом
function callback(event)

	if (event == Ev.ALTITUDE_REACHED) then
		LEDRed()
		action[curr_state]()
	end

	if (event == Ev.SHOCK) then
		ledbar:set(0, 1, 0, 0)
		ledbar:set(1, 1, 0, 0)
		ledbar:set(2, 1, 0, 0)
		ledbar:set(3, 1, 0, 0)
		
	end

	if (event == Ev.POINT_REACHED) then
		LEDGreen()
	end


	if (event == Ev.COPTER_LANDED) then
		action[curr_state]()
	end
	
	if (event == Ev.POINT_DECELERATION) then
		LEDBlue()
		action[curr_state]()
	end
	if (event == Ev.SYNC_START) then
		ap.push(Ev.MCE_LANDING)
	end

end


-- вызов функции из таблицы состояний, соответствующей первому состоянию
action[curr_state]()

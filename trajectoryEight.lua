-- создание порта управления магнитом
local magnet = Gpio.new(Gpio.A, 1, Gpio.OUTPUT)

-- создание порта управления светодиодом
local ledbar = Ledbar.new(29)

local colors = {	purple = 	{r=1, g=0, b=1}, 
					cyan = 		{r=0, g=1, b=1}, 
					yellow = 	{r=1, g=1, b=0}, 
					blue = 		{r=0, g=0, b=1}, 
					red = 		{r=1, g=0, b=0}, 
					green = 	{r=0, g=1, b=0}, 
					white = 	{r=1, g=1, b=1}, 
					black = 	{r=0, g=0, b=0}	}

leds:setMatrix(colors.yellow)

local ledStateRed = false
local ledStateGreen = false
local ledStateBlue = false
-- переменная текущего состояния
local curr_state = "START"
local angle = 1.5

local function LEDRed()
	if ledStateRed then
		ledStateRed = false
		ledbar:set(0, {r=0, g=0 , b=0})
	else 
		ledStateRed = true
		ledbar:set(0, {r=1, g=0 , b=0})
	end 
end

local function LEDGreen()
	if ledStateGreen then
		ledStateGreen = false
		ledbar:set(3, {r=0, g=0 , b=0})
	else 
		ledStateGreen = true
		ledbar:set(3, {r=0, g=1 , b=0})
	end 
end

local function LEDBlue()
	if ledStateBlue then
		ledStateBlue = false
		ledbar:set(1, {r=0, g=0 , b=0})
		ledbar:set(2, {r=0, g=0 , b=0})
	else 
		ledStateBlue = true
		ledbar:set(1, {r=0, g=0 , b=1})
		ledbar:set(2, {r=0, g=0 , b=1})
	end 
end

-- таблица функций, вызываемых в зависимости от состояния
action = {
	["START"] = function(x)
		ledbar:set(1, {r=1, g=0, b=1})
		ledbar:set(2, {r=1, g=0, b=1})
		sleep(2) 
		ap.push(Ev.MCE_PREFLIGHT)
		sleep(2)
		ap.push(Ev.MCE_TAKEOFF)
		-- переход в следующее состояние
		curr_state = "_PIONEER_POINT_2"
	end,
	["_PIONEER_POINT_2"] = function (x)
		
		ap.goToLocalPoint({x=0, y=0, z=1.2})
		-- переход в следующее состояние
		curr_state = "_PIONEER_LED_2"
	end,
	["_PIONEER_LED_2"] = function (x)
		x1 = 1.5 * math.cos(angle)
		y1 = 0.75 * math.sin(2 * angle)
		-- x1 = 2500 + 1500 * math.cos(angle)
		-- y1 = 2500 + 750 * math.sin(2 * angle)
		-- angle = angle + 0.1
		ap.goToLocalPoint({x=x1, y=y1, z=1.2})
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
		ledbar:set(0, {r=1, g=0, b=0})
		ledbar:set(1, {r=1, g=0, b=0})
		ledbar:set(2, {r=1, g=0, b=0})
		ledbar:set(3, {r=1, g=0, b=0})
		
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

-- бесконечный цикл, автоматически вызывается автопилотом
function loop()
end

-- вызов функции из таблицы состояний, соответствующей первому состоянию
action[curr_state]()

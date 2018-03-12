local Path = {}

-- Создает новый объект класса Path
function Path.new()
	local obj = { point = { [0] = {} }, state = 0 } 
	Path.__index = Path 
	return setmetatable( obj, Path )
end

-- Добавляет точку пути. Аргументы: x, y, z - координаты в метрах; func - ссылка на функцию, выполняемую после достижения точки (необязательный аргумент).
function Path:addWaypoint( _x, _y, _z, _func, _bound )
	local point = { x = _x, y = _y, z = _z, waypoint = true, bound = _bound }
	table.insert( self.point, point )
	if _func then
		self.point[#self.point].func = _func
	end
end

-- Добавляет взлет на высоту, указанную в параметрах (Flight_common_takeoffAltitude). Аргументы: func - ссылка на функцию, выполняемую после достижения высоты взлета (необязательный аргумент).
function Path:addTakeoff( _func )
	table.insert( self.point, { takeoff = true } )
	if _func then
		self.point[#self.point].func = _func
	end
end

-- Добавляет посадку. Аргументы: func - ссылка на функцию, выполняемую после приземления (необязательный аргумент).
function Path:addLanding( _func )
	table.insert( self.point, { landing = true } )
	if _func then
		self.point[#self.point].func = _func
	end
end

-- Запуск выполнения полетного задания
function Path:start()
	--sleep(1)
	localSleep(1)
	if self.point[1].takeoff then
		self.state = 1
		ap.push(Ev.MCE_PREFLIGHT) 
		--sleep(1)
		localSleep(1)
		ap.push(Ev.MCE_TAKEOFF)
	end
end

-- Обработчик событий объекта пути. Должен быть добавлен в function callback(event) с передачей аргумента event. Как в примере ниже.
function Path:eventHandler( e )
	local change_state = false
	local obj_state = self.point[self.state]
	if e == Ev.ALTITUDE_REACHED and obj_state.takeoff then
		change_state = true
	elseif e == Ev.POINT_DECELERATION and obj_state.waypoint and not obj_state.bound then
		change_state = true
	elseif e == Ev.POINT_REACHED and obj_state.waypoint and obj_state.bound then
		change_state = true
	elseif e == Ev.POINT_DECELERATION and obj_state.landing then
		change_state = true
	elseif e == Ev.COPTER_LANDED and ( obj_state.landing or obj_state.takeoff ) then
		change_state = true
	end
	if change_state then
		if obj_state.func then 
			obj_state.func()
		end
		if self.state < #self.point then
			self.state = self.state + 1
			obj_state = self.point[self.state]
		else 
			self.state = 0
		end
		if obj_state.waypoint then
			ap.goToLocalPoint( {x = self.point[self.state].x, y = self.point[self.state].y, z = self.point[self.state].z} )
		elseif obj_state.takeoff then
			ap.push(Ev.MCE_PREFLIGHT) 
			--sleep(1)
			localSleep(1)
			ap.push(Ev.MCE_TAKEOFF)
		elseif obj_state.landing then
			ap.push(Ev.MCE_LANDING)
		end
	end
end

-- Управление светодиодами
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

-- Управление светодиодами на плате
local function setSysLeds( color )
	for i = 0, led_offset - 1, 1 do
		leds:set(i, color)
	end
end

-- Возвращает указатель на функцию включения матрицы заданным цветом
local function getPointerLedsMatrix( color )
	return function()
		for i = led_offset, led_count, 1 do
			leds:set(i, color)
		end
	end
end

-- Таблица с указателями 
local pColors = {}
for k, v in pairs(colors) do 
	pColors[k] = getPointerLedsMatrix(v)
end

local delta = TimeInfo.new("TimeDelta")
local launch = TimeInfo.new("LaunchTime")

function localSleep( wait_time )
	last_time = time()
	while (time() - last_time < wait_time) do
	end
end

local function getGlobalTime()	
	return time() +  delta:retrieve()
end

local function getPointerSleep( time )
	return function()
		--sleep (time)
		localSleep(time)
	end
end

local function endWaiting( wait_time )
	return function()
		while (getGlobalTime() - launch:retrieve() < wait_time) do
		end
	end
end

-- Инициализация вспомогательных функций
local board_number = boardNumber
local start_formations = false
local unpack = table.unpack	

local endWaitingTime = 80
-- Таблица с координатами и цветом
local letters = {
	{	-- 1 "Р"
		{-2, 0.5, 0.5, pColors.black, true},
		{-2, -1, 0.5, pColors.white, true},
		{-2, -1, 1.5, pColors.white, false},
		{-1.6, -1, 1.5, pColors.white, false},
		{-1.5, -1, 1.4, pColors.white, false},
		{-1.5, -1, 0.9, pColors.white, false},
		{-1.6, -1, 0.8, pColors.white, false},
		{-2, -1, 0.8, pColors.black, true},
		{-2, 0.5, 0.5, endWaiting(endWaitingTime), true}
	},
	{	-- 2 "О"
		{-1.3, 1.5, 0.5, getPointerSleep(10), true},
		{-1.3, -1, 0.6, pColors.white, true},
		{-1.3, -1, 1.4, pColors.white, false},
		{-1.2, -1, 1.5, pColors.white, false},
		{-0.9, -1, 1.5, pColors.white, false},
		{-0.8, -1, 1.4, pColors.white, false},
		{-0.8, -1, 0.6, pColors.white, false},
		{-0.9, -1, 0.5, pColors.white, false},
		{-1.2, -1, 0.5, pColors.white, false},
		{-1.3, -1, 0.6, pColors.black, true},
		{-1.3, 1.5, 0.5, endWaiting(endWaitingTime), true}
	},
	{	-- 2 "С1"
		{-0.6, 0.5, 0.5, getPointerSleep(17), true},
		{-0.1, -1, 1.4, pColors.blue, true},
		{-0.2, -1, 1.5, pColors.blue, false},
		{-0.5, -1, 1.5, pColors.blue, false},
		{-0.6, -1, 1.4, pColors.blue, false},
		{-0.6, -1, 0.6, pColors.blue, false},
		{-0.5, -1, 0.5, pColors.blue, false},
		{-0.2, -1, 0.5, pColors.blue, false},
		{-0.1, -1, 0.6, pColors.black, true},
		{-0.6, -1, 0.6, pColors.black, false},
		{-0.6, 0.5, 0.5, endWaiting(endWaitingTime), true}
	},
	{	-- 3 "C2"
		{0.1, 1.5, 0.5, getPointerSleep(24), true},
		{0.6, -1, 1.4, pColors.blue, true},
		{0.5, -1, 1.5, pColors.blue, false},
		{0.2, -1, 1.5, pColors.blue, false},
		{0.1, -1, 1.4, pColors.blue, false},
		{0.1, -1, 0.6, pColors.blue, false},
		{0.2, -1, 0.5, pColors.blue, false},
		{0.5, -1, 0.5, pColors.blue, false},
		{0.6, -1, 0.6, pColors.black, true},
		{0.1, -1, 0.6, pColors.black, false},
		{0.1, 1.5, 0.5, endWaiting(endWaitingTime), true}
	},
	{	-- 2 "И"
		{0.8, 0.5, 0.5, getPointerSleep(32), true},
		{1.3, -1, 0.5, pColors.red, true},
		{1.3, -1, 1.5, pColors.red, false},
		{0.8, -1, 0.5, pColors.red, true},
		{0.8, -1, 1.5, pColors.black, true},
		{0.8, 0.5, 0.5, endWaiting(endWaitingTime), true}
	},
	{	-- 6 "Я"
		{1.5, 1.5, 0.5, getPointerSleep(40), true},
		{2.0, -1, 0.5, pColors.red, true},
		{2.0, -1, 1.5, pColors.red, false},
		{1.6, -1, 1.5, pColors.red, false},
		{1.5, -1, 1.4, pColors.red, false},
		{1.5, -1, 0.8, pColors.red, false},
		{1.6, -1, 0.8, pColors.red, false},
		{2.0, -1, 0.8, pColors.red, true},
		{1.5, -1, 0.5, pColors.black, true},		
		{1.5, 1.5, 0.5, pColors.black, true},
		{1.5, 1.5, 0.5, endWaiting(endWaitingTime), true}
	}
}

function callback ( event )
	if (event == Ev.SYNC_START) then
		setSysLeds(colors.cyan)
		--sleep (2)
		localSleep(2)
		setSysLeds(colors.black)
		if start_formations then
			start_formations = false
			ap.push(Ev.MCE_LANDING)
		else
			-- leds:setMatrix(colors.purple)
			start_formations = true
			letter_path:start()
			-- time_start_global = launch:retrieve() + 5
			-- ap.push(Ev.MCE_PREFLIGHT)
			-- sleep(1)
			-- ap.push(Ev.MCE_TAKEOFF)	
		end	
	end
	letter_path:eventHandler(event)
end

function loop()
end

-- Создание Path для коптера по номеру борта
letter_path = Path.new()
letter_path:addTakeoff()
for _, v in ipairs(letters[board_number]) do
	letter_path:addWaypoint(unpack(v))
end
letter_path:addLanding(function () start_formations = false end)

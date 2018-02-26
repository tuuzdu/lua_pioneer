
local Path = {}

-- Создает новый объект класса Path
function Path.new()
	local obj = { point = { [0] = {} }, state = 0 } 
	Path.__index = Path 
	return setmetatable( obj, Path )
end

-- Добавляет точку пути. Аргументы: x, y, z - координаты в метрах; func - ссылка на функцию, выполняемую после достижения точки (необязательный аргумент).
function Path:addWaypoint( _x, _y, _z, _func )
	local point = { x = _x, y = _y, z = _z, waypoint = true }
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
	sleep(1)
	if self.point[1].takeoff then
		self.state = 1
		ap.push(Ev.MCE_PREFLIGHT) 
		sleep(1)
		ap.push(Ev.MCE_TAKEOFF)
	end
end

-- Обработчик событий объекта пути. Должен быть добавлен в function callback(event) с передачей аргумента event. Как в примере ниже.
function Path:eventHandler( e )

	local change_state = false
	local obj_state = self.point[self.state]

	if e == Ev.ALTITUDE_REACHED and obj_state.takeoff then
		change_state = true
	elseif e == Ev.POINT_REACHED and obj_state.waypoint then
		change_state = true
	elseif e == Ev.POINT_REACHED and obj_state.landing then
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
			sleep(1)
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
-- Таблица с указателями (как инициализировать автоматически?)
local pColors = {}
-- for k, v in pairs(colors) do 
-- 	pColors.k = getPointerLedsMatrix(v)
-- end
pColors.blue = getPointerLedsMatrix(colors.blue)
pColors.black = getPointerLedsMatrix(colors.black)
pColors.purple = getPointerLedsMatrix(colors.purple)
pColors.cyan = getPointerLedsMatrix(colors.cyan)
pColors.yellow = getPointerLedsMatrix(colors.yellow)
pColors.red = getPointerLedsMatrix(colors.red)
pColors.green = getPointerLedsMatrix(colors.green)
pColors.white = getPointerLedsMatrix(colors.white)



-- Инициализация вспомогательных функций
local board_number = boardNumber
local start_formations = false
-- local start_init_pose = false
-- local time_delta = 0
-- local time_start_global = 0
-- local time_transition = 5

local unpack = table.unpack	

local delta = TimeInfo.new("TimeDelta")
local launch = TimeInfo.new("LaunchTime")
-- Таблица с координатами и цветом
local letters = {
	{	-- 1 "П"
		{-2, -1, 0.5, pColors.blue},
		{-2, -1, 1.5, pColors.blue},
		{-1.5, -1, 1.5, pColors.blue},
		{-1.5, -1, 0.5, pColors.black}
	},
	{	-- 2 "И"
		{-1.3, 0, 1.5, pColors.red},
		{-1.3, 0, 0.5, pColors.red},
		{-0.8, 0, 1.5, pColors.red},
		{-0.8, 0, 0.5, pColors.black}
	},
	{	-- 3 "О"
		{-0.6, 1, 0.5, pColors.green},
		{-0.6, 1, 1.5, pColors.green},
		{-0.1, 1, 1.5, pColors.green},
		{-0.1, 1, 0.5, pColors.green},
		{-0.6, 1, 0.5, pColors.black}
	},
	{	-- 4 "Н"
		{0.1, 1, 0.5, pColors.purple},
		{0.1, 1, 1.5, pColors.black},
		{0.6, 1, 1.5, pColors.purple},
		{0.6, 1, 0.5, pColors.black},
		{0.6, 1, 0.8, pColors.purple},
		{0.1, 1, 0.8, pColors.black}
	},
	{	-- 5 "Е"
		{1.3, 0, 0.5, pColors.cyan},
		{0.8, 0, 0.5, pColors.cyan},
		{0.8, 0, 1.5, pColors.cyan},
		{1.3, 0, 1.5, pColors.black},
		{1.1, 0, 0.8, pColors.cyan},
		{0.8, 0, 0.8, pColors.black}
	},
	{	-- 6 "Р"
		{1.5, -1, 0.5, pColors.yellow},
		{1.5, -1, 1.5, pColors.yellow},
		{2, -1, 1.5, pColors.yellow},
		{2, -1, 0.8, pColors.yellow},
		{1.5, -1, 0.8, pColors.black}
	}
}

function callback ( event )

	if (event == Ev.SYNC_START) then
		-- setSysLeds(colors.cyan)

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
letter_path:addLanding()
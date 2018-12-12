
-- Скрипт реализует полет по заданию. Позволяет добавлять полет в точку, взлет и посадку, а также выполнять функции, после этих действий.

-- Класс Path
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

-- Добавляет функцию к указанному номеру точки пути. Аргументы: func - ссылка на функцию, выполняемую после действия; point_index - номер точки пути.
function Path:addFuncForPoint( _func, point_index )
	if self.point[point_index] and _func then
		self.point[point_index].func = _func
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
			ap.goToLocalPoint(self.point[self.state].x, self.point[self.state].y, self.point[self.state].z)
		elseif obj_state.takeoff then
			ap.push(Ev.MCE_PREFLIGHT) 
			sleep(1)
			ap.push(Ev.MCE_TAKEOFF)
		elseif obj_state.landing then
			ap.push(Ev.MCE_LANDING)
		end

	end
end

-- Здесь заканчивается описание класса
--------------------------------------------------------------------------------------------------------------------

-- Пример программы

-- Функция, вызываемая при появлении событий
function callback( event )
	my_path:eventHandler(event) -- Обработчик событий для объекты my_path
end

local unpack = table.unpack	
-- Управление светодиодами
local led_count = 29
local matrix_count = 25
local led_offset = 4
local leds = Ledbar.new(led_count)
local colors = {	purple = 	{1, 0, 1}, 
					cyan = 		{0, 1, 1}, 
					yellow = 	{1, 1, 0}, 
					blue = 		{0, 0, 1}, 
					red = 		{1, 0, 0}, 
					green = 	{0, 1, 0}, 
					white = 	{1, 1, 1}, 
					black = 	{0, 0, 0},
					brown = 	{0.6, 0.25, 0.15}
				}

-- Возвращает указатель на функцию включения матрицы заданным цветом
local function getPointerLedsMatrix( color )
	return function()
		for i = led_offset, led_count, 1 do
			leds:set(i, unpack(color))
		end
	end
end
-- Таблица с указателями 
local pColors = {}
for k, v in pairs(colors) do 
	pColors[k] = getPointerLedsMatrix(v)
end

local tree = {
	{0,	-1.2, 1, pColors.green},
	{0, -0.2, 2.4, pColors.green},
	{0, -0.8, 2.4, pColors.green},
	{0, 0, 3.6, pColors.green},
	{0, -0.2, 3.6, pColors.green},
	{0, 0.3, 4.4, pColors.green},
	{0, 0.8, 3.6, pColors.green},
	{0, 0.6, 3.6, pColors.green},
	{0, 1.4, 2.4, pColors.green},
	{0, 0.8, 2.4, pColors.green},
	{0, 1.8, 1, pColors.green},
	{0, -1.2, 1, pColors.black},

	{0, 0.3, 4.5, function () pColors.white() sleep(3) pColors.black() end},
	{0, 0.2, 4, function () pColors.cyan() sleep(1) pColors.black() end},
	{0, 0.6, 3, function () pColors.blue() sleep(1) pColors.black() end},
	{0, 0, 2.8, function () pColors.purple() sleep(1) pColors.black() end},
	{0, 0.2, 2, function () pColors.yellow() sleep(1) pColors.black() end},
	{0, -0.6, 1.6, function () pColors.red() sleep(1) pColors.black() end},
	{0, 0.4, 1.4, function () pColors.purple() sleep(1) pColors.black() end},
	{0, 1.4, 1.2, function () pColors.yellow() sleep(1) pColors.black() end},

	{0, 0.6, 1, pColors.brown},
	{0, 0.6, 0.6, pColors.brown},
	{0, 0, 0.6, pColors.brown},
	{0, 0, 1, pColors.black}
}

-- Создание нового объекта Path
my_path = Path.new()
my_path:addTakeoff()
for _, v in ipairs(tree) do
	my_path:addWaypoint(unpack(v))
end
my_path:addLanding()

-- Старт выполнения полетного задания
my_path:start()

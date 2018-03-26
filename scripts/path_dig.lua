
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

-- Здесь заканчивается описание класса
--------------------------------------------------------------------------------------------------------------------

-- Функция, вызываемая при появлении событий
function callback( event )
	my_path:eventHandler(event) -- Обработчик событий для объекты my_path
end

function loop()
end

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

local dig = {	{3, 7, 8, 13, 18, 22, 23, 24},
				{2, 3, 4, 9, 12, 13, 14, 17, 22, 23, 24},
				{2, 3, 4, 9, 12, 13, 14, 19, 22, 23, 24},
				{2, 4, 7, 9, 12, 13, 14, 19, 24},
				{2, 3, 4, 7, 12, 13, 14, 19, 22, 23, 24},	
				[0] = {2, 3, 4, 7, 9, 12, 14, 17, 19, 22, 23, 24} }

local colorArr = {[0] = colors.blue, colors.purple, colors.red, colors.green, colors.yellow, colors.cyan}

local ledMatrix = {}

for i = 1, matrix_count + 1, 1 do
	ledMatrix[i] = colors.black
end

local function updateMatrix()
	for i = led_offset, led_count - 1, 1 do
		leds:set(i, ledMatrix[i-led_offset + 1])
	end
end

local function setPixelMatrix( x, y, colors )
	i = (y - 1) * 5 + x
	if ledMatrix [i] then 
		ledMatrix [i] = colors
	end
end

local function fillMatrix( colors )
	for i = 1, matrix_count + 1, 1 do
		ledMatrix [i] = colors
	end
end


local function setDig( x, colors )
	for _, v in ipairs(dig[x]) do
		ledMatrix[v] = colors
	end
end 

local function setMatrixDig(i)
	return function()
		fillMatrix(colors.black)
		setDig (i, colorArr[i])
		updateMatrix()
	end
end

-- Создание ссылок на функции установки желаемого цвета
one = setMatrixDig(1)
two = setMatrixDig(2)
three = setMatrixDig(3)
four = setMatrixDig(4)

-- Создание нового объекта Path
my_path = Path.new()

-- Составление полетного задания
my_path:addTakeoff()
for i = 1, 5, 1 do
	my_path:addWaypoint(0.5, 0.5, 1, one)
	my_path:addWaypoint(-0.5, 0.5, 1, two)
	my_path:addWaypoint(-0.5, -0.5, 1, three)
	my_path:addWaypoint(0.5, -0.5, 1, four)
end
my_path:addLanding()

-- Старт выполнения
my_path:start()



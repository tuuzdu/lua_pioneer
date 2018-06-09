-- Скрипт реализует работу со светодиодной матрицей. Есть возможность перевода формата цвета HSV в RGB (светодиоды принимаются информацию в RGB),
-- а также вывод цифр на матрицу.

local led_count = 29													-- Общее количество светодиодов (4 на плате + 25 на матрице = 29)
local matrix_count = 25													-- Количество светодиодов на плате
local led_offset = 4													-- Количество светодиодов на матрице
local leds = Ledbar.new(led_count)		
local unpack = table.unpack												-- Создание нового объекта Ledbar для управления светодиодами
local colors = {	red = 		{1, 0, 0},								-- Таблица цветов в RGB. Яркость цвета задается диапазоном от 0 до 1
					green = 	{0, 1, 0}, 
					blue = 		{0, 0, 1},
					purple = 	{1, 0, 1}, 		
					cyan = 		{0, 1, 1}, 
					yellow = 	{1, 1, 0}, 
					white = 	{1, 1, 1}, 
					black = 	{0, 0, 0}	}							-- black - светодиоды выключены

local dig = {	{3, 7, 8, 13, 18, 22, 23, 24},							-- Таблица символов цифр
				{2, 3, 4, 9, 12, 13, 14, 17, 22, 23, 24},
				{2, 3, 4, 9, 12, 13, 14, 19, 22, 23, 24},
				{2, 4, 7, 9, 12, 13, 14, 19, 24},
				{2, 3, 4, 7, 12, 13, 14, 19, 22, 23, 24},	
				[0] = {2, 3, 4, 7, 9, 12, 14, 17, 19, 22, 23, 24} }		-- Индексация Lua на чинается с 1, поэтому 0 указан в явном виде

local ledMatrix = {}													-- Массив для хранения выводимой информации на матрицу

for i = 1, matrix_count + 1, 1 do
	ledMatrix[i] = colors.black											-- Инициализация массива
end

-- Вывод массива на матрицу
local function updateMatrix()
	for i = led_offset, led_count - 1, 1 do
		leds:set(i, unpack(ledMatrix[i-led_offset + 1]))
	end
end

-- Установка цвета на заданный пиксель массива матрицы. x - столбец; y - строка; colors - цвет в RGB
local function setPixelMatrix( x, y, colors )
	i = (y - 1) * 5 + x
	if ledMatrix [i] then 
		ledMatrix [i] = colors
	end
end

-- Заполнение массива матрицы цветом. colors - цвет в RGB
local function fillMatrix( colors )
	for i = 1, matrix_count + 1, 1 do
		ledMatrix [i] = colors
	end
end

-- Запись символа цифры в массив матрицы. x - цифра; colors - цвет в RGB
local function setDig( x, colors )
	for _, v in ipairs(dig[x]) do
		ledMatrix[v] = colors
	end
end 

-- Здесь заканчивается описание работы с матрицей
--------------------------------------------------------------------------------------------------------------------

function callback( event )
end

-- function l(func, ... )
-- 	return function func(...) end
-- end

-- Пример. Программа выводит цифры от 0 до 5, при этом изменяя цвет от красного к фиолетовому
function digitOutput() 

	colors_any = {0,0,0}	

	for i = 0, 5, 1 do
		for col = 0, 360, 1 do
			colors_any[1],  colors_any[2], colors_any[3] = fromHSV(col, 100, 10)								-- Генерация цвета
			setDig (i, colors_any)									-- Запись цифры в массив заданного цвета
			updateMatrix()														-- Вывод массива на матрицу
			-- sleep(0.1)															-- Небольшой таймаут
		end
		fillMatrix(colors.black)												-- Очистка массива матрицы перед записью новой цифры
	end
	fillMatrix(colors.black)
	updateMatrix()
	Timer.callLater( 10, digitOutput)
end

digitOutput()
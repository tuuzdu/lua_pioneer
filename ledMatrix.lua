-- Скрипт реализует работу со светодиодной матрицей. Есть возможность перевода формата цвета HSV в RGB (светодиоды принимаются информацию в RGB),
-- а также вывод цифр на матрицу.

local led_count = 29													-- Общее количество светодиодов (4 на плате + 25 на матрице = 29)
local matrix_count = 25													-- Количество светодиодов на плате
local led_offset = 4													-- Количество светодиодов на матрице
local leds = Ledbar.new(led_count)										-- Создание нового объекта Ledbar для управления светодиодами
local colors = {	red = 		{r=1, g=0, b=0},						-- Таблица цветов в RGB. Яркость цвета задается диапазоном от 0 до 1
					green = 	{r=0, g=1, b=0}, 
					blue = 		{r=0, g=0, b=1},
					purple = 	{r=1, g=0, b=1}, 		
					cyan = 		{r=0, g=1, b=1}, 
					yellow = 	{r=1, g=1, b=0}, 
					white = 	{r=1, g=1, b=1}, 
					black = 	{r=0, g=0, b=0}	}						-- black - светодиоды выключены

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

-- Функция конвертации HSV в RGB
local function HSVToRGB( hue, saturation, value )		

	if saturation == 0 then
		return value
	end

	local hue_sector = math.floor( hue / 60 )
	local hue_sector_offset = ( hue / 60 ) - hue_sector

	local p = value * (1 - saturation)
	local q = value * (1 - saturation * hue_sector_offset)
	local t = value * (1 - saturation * (1 - hue_sector_offset))

	if hue_sector == 0 then
		return value, t, p
	elseif hue_sector == 1 then
		return q, value, p
	elseif hue_sector == 2 then
		return p, value, t
	elseif hue_sector == 3 then
		return p, q, value
	elseif hue_sector == 4 then
		return t, p, value
	elseif hue_sector == 5 then
		return value, p, q
	end
end

-- Вывод массива на матрицу
local function updateMatrix()
	for i = led_offset, led_count - 1, 1 do
		leds:set(i, ledMatrix[i-led_offset + 1])
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

-- Пример. Программа выводит цифры от 0 до 5, при этом изменяя цвет от красного к фиолетовому
function loop() 

	colors.any = {}	

	for i = 0, 5, 1 do
		for col = 0, 360, 1 do
			colors.any.r, colors.any.g, colors.any.b = HSVToRGB(col, 1, 0.1)	-- Генерация цвета
			setDig (i, colors.any)												-- Запись цифры в массив заданного цвета
			updateMatrix()														-- Вывод массива на матрицу
			sleep(0.01)															-- Небольшой таймаут
		end
		fillMatrix(colors.black)												-- Очистка массива матрицы перед записью новой цифры
	end

end

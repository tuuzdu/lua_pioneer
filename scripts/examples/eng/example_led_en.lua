-- This script shows how to work with LED module. You will find how to convert HSV color format into RGB
-- and numbers output to LED matrix

local led_count = 29													-- Total number of LEDs (4 on base pcb and 25 on the LED module)
local led_offset = 4													-- Number of LEDs on base pcb
local matrix_count = 25													-- Number of LEDs on LED module
local leds = Ledbar.new(led_count)										-- RGB LED control port initialize
local unpack = table.unpack												-- Simplification and caching table.unpack calls
local colors = {	red = 		{1, 0, 0},								-- Table of RGB colors. Color brightness is set via [0;1] interval
					green = 	{0, 1, 0}, 
					blue = 		{0, 0, 1},
					purple = 	{1, 0, 1}, 		
					cyan = 		{0, 1, 1}, 
					yellow = 	{1, 1, 0}, 
					white = 	{1, 1, 1}, 
					black = 	{0, 0, 0}}								-- black - LEDs are off

local dig = {	{3, 7, 8, 13, 18, 22, 23, 24},							-- 1 Table of number representations
				{2, 3, 4, 9, 12, 13, 14, 17, 22, 23, 24},				-- 2
				{2, 3, 4, 9, 12, 13, 14, 19, 22, 23, 24},				-- 3
				{2, 4, 7, 9, 12, 13, 14, 19, 24},						-- 4
				{2, 3, 4, 7, 12, 13, 14, 19, 22, 23, 24},				-- 5
				{3, 4, 7, 12, 13, 14, 17, 19, 22, 23, 24},				-- 6
				{2, 3, 4, 9, 13, 18, 23},								-- 7
				{2, 3, 4, 7, 9, 13, 17, 19, 22, 23, 24},				-- 8
				{2, 3, 4, 7, 9, 12, 13, 14, 19, 22, 23},				-- 9
				{1, 3, 4, 5, 6, 8, 10, 11, 13, 15, 16, 18, 20, 21, 23, 24, 25},	-- 10
				[0] = {2, 3, 4, 7, 9, 12, 14, 17, 19, 22, 23, 24} }		-- Since Lua starts counting from 1, so 0 is set in explicit form

local ledMatrix = {}													-- Array of output info for LED matrix

for i = 1, matrix_count + 1, 1 do
	ledMatrix[i] = colors.black											-- Array initialization
end

-- Array to matrix output function
local function updateMatrix()
	for i = led_offset, led_count - 1, 1 do
		leds:set(i, unpack(ledMatrix[i-led_offset + 1]))
	end
end

-- Specific pixel of matrix array set function (x - column, y - row, colors - color in RGB form)
local function setPixelMatrix( x, y, colors )
	i = (y - 1) * 5 + x
	if ledMatrix [i] then 
		ledMatrix [i] = colors
	end
end

-- Filling matrix array with color function (colors - color in RGB)
local function fillMatrix( colors )
	for i = 1, matrix_count + 1, 1 do
		ledMatrix [i] = colors
	end
end

-- Digit symbol to matrix array write function (x - digit, colors - color in RGB form)
local function setDig( x, colors )
	for _, v in ipairs(dig[x]) do
		ledMatrix[v] = colors
	end
end 

-- The end of affecting matrix functions 
--------------------------------------------------------------------------------------------------------------------

function callback( event )
end

-- Example. This function outputs digits from 0 to 5 while changing colors from red to violet
function digitOutput() 

	colors_any = {0,0,0}	

	for i = 0, #dig, 1 do
		for col = 0, 360, 1 do
			colors_any[1],  colors_any[2], colors_any[3] = fromHSV(col, 100, 10)	-- Color generation
			setDig (i, colors_any)													-- Loading digit to array of set color
			updateMatrix()															-- Array output to matrix
			sleep(0.005)															-- Pause (Time between color updates)
		end
		fillMatrix(colors.black)													-- Clearing matrix array before loading new digit
	end
	fillMatrix(colors.black)
	updateMatrix()
end

Timer.callLater(0.1, digitOutput)
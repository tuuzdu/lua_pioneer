local led_count = 29
local matrix_count = 25
local led_offset = 4
local leds = Ledbar.new(led_count)
local colors = {	purple = 	{r=1, g=0, b=1}, 
					cyan = 		{r=0, g=1, b=1}, 
					yellow = 	{r=1, g=1, b=0}, 
					blue = 		{r=0, g=1, b=0}, 
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

local ledMatrix = {}

for i = 1, matrix_count + 1, 1 do
	ledMatrix[i] = colors.black
end

local function HSVToRGB( hue, saturation, value )

	if saturation == 0 then
		return value
	end

	local hue_sector = math.floor( hue / 60 )
	local hue_sector_offset = ( hue / 60 ) - hue_sector

	local p = value * ( 1 - saturation )
	local q = value * ( 1 - saturation * hue_sector_offset )
	local t = value * ( 1 - saturation * ( 1 - hue_sector_offset ) )

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

local function updateMatrix()
	for i = led_offset, led_count - 1, 1 do
		leds:set(i, ledMatrix[i-led_offset + 1])
	end
end

local function setPixelMatrix( x, y, colors )
	i = (y - 1) * 5 + x
	if i < 29 and i > 0 then 		-- if ledMatrix [i]  then; if i < 26 and i > 0 then
		ledMatrix [i] = colors
	end
end

local function fillMatrix( colors )
	for i = 1, matrix_count + 1, 1 do
		ledMatrix [i] = colors
	end
end

local function setDig( x, colors )
	i = 1
	repeat 
		ledMatrix [dig[x][i]] = colors
		i = i + 1
	until dig[x][i] == nil
end

--[[
local function setDig( x, colors )
	for i, v in ipairs(dig[x]) do
		ledMatrix[v] = colors
	end
end 
]]--

function callback( event )
end


function loop() 

	colors.any = {}

	for i = 0, 5, 1 do
		for col = 0, 360, 1 do
			colors.any.r, colors.any.g, colors.any.b = HSVToRGB( col, 1, 0.1 )
			setDig (i, colors.any)
			updateMatrix()
			--sleep(0.01)
		end
		fillMatrix(colors.black)
	end

end

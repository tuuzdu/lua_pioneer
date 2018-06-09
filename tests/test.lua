
local function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

local unpack = table.unpack	

local colors = {	purple = 	{r=1, g=0, b=1}, 
					cyan = 		{r=0, g=1, b=1}, 
					yellow = 	{r=1, g=1, b=0}, 
					blue = 		{r=0, g=0, b=1}, 
					red = 		{r=1, g=0, b=0}, 
					green = 	{r=0, g=1, b=0}, 
					white = 	{r=1, g=1, b=1}, 
					black = 	{r=0, g=0, b=0}	}

local letters = {
	{
		{-2, -1, 0.5, colors.black},
		{-2, -1, 1.5, colors.blue},
		{-1.5, -1, 1.5, colors.blue},
		{-1.5, -1, 1.5, colors.blue},
		{-1.5, -1, 1.5, colors.blue}
	},
	{
		{0, -1.4, 1.5}, colors.red
	}

}

-- print(dump(letters))
-- print(#letters[1])
local x, y, z
for i = 1, #letters[1], 1 do
	x, y, z = unpack(letters[1][i])
	print(x .. y .. z)
end

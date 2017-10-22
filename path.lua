Path = {}

function Path:new()
	local coordinates = { point = { {x = 0, y = 0, z = 0} } }  -- getCurrentCoordinates
	self.__index = self 
	return setmetatable(coordinates, self)
end

function Path:addPoint(_x, _y, _z)
	local point = {x = _x, y = _y, z = _z}
	table.insert(self.point, point)
end

p = Path:new()
pn = Path:new()

p:addPoint(99,2,3)
pn:addPoint(21,3,443)

print(p.point[2].x)
print(pn.point[1].z)


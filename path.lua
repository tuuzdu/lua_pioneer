function dump(o)
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

Ev = {ALTITUDE_REACHED = 61, POINT_REACHED = 21, COPTER_LANDED = 23}

Path = {}

function Path.new()
	local t = { point = { {} }, state = {} }  -- getCurrentCoordinates
	Path.__index = Path 
	return setmetatable(t, Path)
end


function Path:addWayoint(_x, _y, _z)
	local point = {x = _x, y = _y, z = _z, waypoint = true}
	table.insert(self.point, point)
end


function Path:addTakeoff()
	table.insert(self.point, { takeoff = true } )
end


function Path:addLanding()
	table.insert(self.point, { landing = true } )
end

function Path:addFunctionToPoint(index)
	
end


function Path:Start()
	--[[if self.point[2].takeoff then
		ap.push(Ev.MCE_PREFLIGHT) 
		sleep(1)
		ap.push(Ev.MCE_TAKEOFF)
	end]]--
	self.state = 6
end


function Path:eventHadler(e)

	local change_state = false

	if e == Ev.ALTITUDE_REACHED and self.point[self.state].takeoff then
		change_state = true
		print("TAKEOFF")
	elseif e == Ev.POINT_REACHED and self.point[self.state].waypoint then
		change_state = true
		print("WAYPOINT")
	elseif e == Ev.COPTER_LANDED and self.point[self.state].landing then
		change_state = true
		print("LANDING")
	end

	if change_state then

		if self.state < #self.point then
			self.state = self.state + 1
		end

		if self.point[self.state].waypoint then
			--ap.goToLocalPoint(self.point[curr_state])
		elseif self.point[self.state].takeoff then
			--ap.push(Ev.MCE_PREFLIGHT) 
			--sleep(1)
			--ap.push(Ev.MCE_TAKEOFF)
		elseif self.point[self.state].landing then
			--ap.push(Ev.MCE_LANDING)
		end

	end
end


function callback(event)
	pn:eventHadler(event)
end


--p = Path.new()
pn = Path.new()

pn:addTakeoff()
pn:addWayoint(1,2,3)
pn:addWayoint(11, 22, 33)
pn:addWayoint(111, 222, 333)
pn:addLanding()

pn:Start()

pn:eventHadler(Ev.COPTER_LANDED)
print("State:" .. pn.state)
--print(dump(pn))
--pn:Start()

--print(p.point[2].x)
--print(pn.point[2].takeoff)


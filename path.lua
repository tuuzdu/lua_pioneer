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
	local obj = { point = { [0] = {} }, state = 0 } 
	Path.__index = Path 
	return setmetatable( obj, Path )
end


function Path:addWaypoint( _x, _y, _z )
	local point = {x = _x * 1000, y = _y * 1000, z = _z * 1000, waypoint = true}
	table.insert( self.point, point )
end


function Path:addTakeoff()
	table.insert( self.point, { takeoff = true } )
end


function Path:addLanding()
	table.insert( self.point, { landing = true } )
end


function Path:addFuncForPoint( _func, point_index )
	if point_index <= #self.point then
		self.point[point_index].func = _func
	end
end


function Path:addFunc( _func )
	self.point[#self.point].func = _func
end


function Path:Start()
	--[[if self.point[1].takeoff then
		ap.push(Ev.MCE_PREFLIGHT) 
		sleep(1)
		ap.push(Ev.MCE_TAKEOFF)
	end]]--
	self.state = 7			-- should be replaced into the block above!!!
end


function Path:eventHandler( e )

	local change_state = false
	local obj_state = self.point[self.state]

	if e == Ev.ALTITUDE_REACHED and obj_state.takeoff then
		change_state = true
		print("TAKEOFF")
	elseif e == Ev.POINT_REACHED and obj_state.waypoint then
		change_state = true
		print("WAYPOINT")
	elseif e == Ev.POINT_REACHED and obj_state.landing then
		change_state = true
		print("LANDING")
	elseif e == Ev.COPTER_LANDED and ( obj_state.landing or obj_state.takeoff ) then
		change_state = true
		print("LANDED")
	end

	if change_state then

		if obj_state.func then 
			obj_state.func()
		end

		if self.state < #self.point then
			self.state = self.state + 1
		else 
			self.state = 0
		end

		if obj_state.waypoint then
			--ap.goToLocalPoint( {x = self.point[self.state].x, y = self.point[self.state].y, z = self.point[self.state].z} )
		elseif obj_state.takeoff then
			--ap.push(Ev.MCE_PREFLIGHT) 
			--sleep(1)
			--ap.push(Ev.MCE_TAKEOFF)
		elseif obj_state.landing then
			--ap.push(Ev.MCE_LANDING)
		end

	end
end


function callback( event )
	pn:eventHandler(event)
end

function loop()
end

-- ###### ^ Module above ^ ######

--[[
local action = {
	["ACTION_1"] = function()
		-- Function block
	end
}

p:addFunc(action["ACTION_1"])
]]--

function func_1 ()
	local f = "Test function"
	print(f)
end

--p = Path.new()
pn = Path.new()

pn:addTakeoff()
pn:addWaypoint(1, 2, 1.2)
pn:addWaypoint(2, 2, 1.2)
pn:addFunc(
	function()
		local f = "Test function 2"
		print(f)
	end
	)
pn:addWaypoint(2, 1, 1.2)
pn:addLanding()
pn:addTakeoff()
pn:addWaypoint(2, 2, 1.2)
pn:addLanding()

pn:addFuncForPoint(func_1, 8)

pn:Start()

pn:eventHandler(Ev.POINT_REACHED)
print("State:" .. pn.state)
print(dump(pn))

--print(p.point[2].x)
--print(pn.point[2].takeoff)


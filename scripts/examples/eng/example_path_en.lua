-- This script shows OOP approach to mission flight. You can add waypoints, taking off tasks and landing as well as adding special functions among this tasks

-- Simplification and caching table.unpack calls
local unpack = table.unpack

-- Creating Path class
local Path = {}

-- Creating new object of Path class
function Path.new()
	local obj = { point = { [0] = {} }, state = 0 } 
	Path.__index = Path 
	return setmetatable( obj, Path )
end

-- Adding waypoint to flight mission. Arguments: x, y, z - coordinates, m; func - function being executed after getting to point (optional argument)
function Path:addWaypoint( _x, _y, _z, _func )
	local point = { x = _x, y = _y, z = _z, waypoint = true }
	table.insert( self.point, point )
	if _func then
		self.point[#self.point].func = _func
	end
end

-- Adds takeoff task to altitude (Flight_common_takeoffAltitude). Arguments: func - function being executed after taking off and getting to set altitude (optional argument)
function Path:addTakeoff( _func )
	table.insert( self.point, { takeoff = true } )
	if _func then
		self.point[#self.point].func = _func
	end
end

-- Adds landing task. Arguments: func - function being executed after landing (optional argument)
function Path:addLanding( _func )
	table.insert( self.point, { landing = true } )
	if _func then
		self.point[#self.point].func = _func
	end
end

-- Adds function to waypoint. Argument: func - function being executed after task is completed; point_index - waypoint index in mission
function Path:addFuncForPoint( _func, point_index )
	if self.point[point_index] and _func then
		self.point[point_index].func = _func
	end
end

-- Starts mission flight execution
function Path:start()
	if self.point[1].takeoff then
		self.state = 1
		ap.push(Ev.MCE_PREFLIGHT) 
		Timer.callLater(1, function() ap.push(Ev.MCE_TAKEOFF) end)
	end
end

-- Mission event handling function. It should be added to function callback(event) with event argument as in the example below
function Path:eventHandler( e )

	local change_state = false
	local obj_state = self.point[self.state]

	if e == Ev.TAKEOFF_COMPLETE and obj_state.takeoff then
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
			ap.goToLocalPoint( obj_state.x, obj_state.y, obj_state.z )
		elseif obj_state.takeoff then
			Timer.callLater(2, function() ap.push(Ev.MCE_PREFLIGHT) end)
			Timer.callLater(3, function() ap.push(Ev.MCE_TAKEOFF) end)
		elseif obj_state.landing then
			ap.push(Ev.MCE_LANDING)
		end

	end
end

-- Class description end
--------------------------------------------------------------------------------------------------------------------

-- Mission example

-- Function being called when autopilot generates events
function callback( event )
	my_path:eventHandler(event) -- Обработчик событий для объекта my_path
end

function loop()
end

-- Color table in RGB form. Color brightness is set by value from 0 to 1
local colors = {	red = 		{1, 0, 0},				
					green = 	{0, 1, 0},
					blue = 		{0, 0, 1},
					purple = 	{1, 0, 1},
					cyan = 		{0, 1, 1},
					yellow = 	{1, 1, 0},
					white = 	{1, 1, 1},
					black = 	{0, 0, 0}    }

local led_count = 4	-- Base pcb number of RGB LEDs
local leds = Ledbar.new(led_count)  -- RGB LED control port initialize

-- Function sets desired color on LEDs on base pcb (4). Returns function that you can add as an argument to waypoint function
local function getSysLeds( color )
	return function()
		for i = 0, led_count - 1, 1 do
			leds:set(i, unpack(color))
		end
	end
end


-- Creating functions to pass to waypoint function as an argument
red = getSysLeds(colors.red)
blue = getSysLeds(colors.blue)
yellow = getSysLeds(colors.yellow)

-- Creating new Path object
my_path = Path.new()

-- Creating mission
my_path:addTakeoff(red)						-- Takeoff. Afterward all LEDs are set to red color
my_path:addWaypoint(0, 0, 0.8, blue)		-- Fly to point. After reaching it, set all LEDs to blue
my_path:addWaypoint(0, 1, 1, red)	    	
my_path:addWaypoint(0.5, 1, 1)
my_path:addLanding()						-- Landing
my_path:addTakeoff(blue)
my_path:addWaypoint(0, 0.5, 1)
my_path:addLanding()

my_path:addFuncForPoint(red, 7)			-- Adding function that sets all colors to red in point 7(my_path:addWaypoint(0, 0.5, 1))

-- Start mission flight
my_path:start()
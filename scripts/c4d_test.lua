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

local clock = os.clock
function sleep(n)  -- seconds
   local t0 = clock()
   while clock() - t0 <= n do end
end

local time = os.time
function getGlobal()
   t = time()
   print("getGlobal: " .. t)
   return t
end


Ev = {ALTITUDE_REACHED = 61, POINT_REACHED = 21, COPTER_LANDED = 23, MCE_TAKEOFF = 1, MCE_PREFLIGHT = 2}

ap = {}

function ap.push(e)
   if e == Ev.MCE_TAKEOFF then
      print("TAKEOFF")
   elseif e == Ev.MCE_PREFLIGHT then
      print("MCE_PREFLIGHT")
   elseif e == Ev.POINT_REACHED then
      print("POINT_REACHED")
   end
end

function ap.goToLocalPoint(x, y, z)
   print('goToLocalPoint: '..x..' '..y..' '..z)
end

Timer = {}

function Timer.callLate(n, func)
   local t0 = clock()
   while clock() - t0 <= n do end
   func()
end

function Timer.callAtGlobal(n, func)
   while time() - n <= 0 do end
   print('callAtGlobal: '..n)
   func()
end

return {
   dump = dump,
   Ev = Ev,
   ap = ap,
   sleep = sleep,
   getGlobal = getGlobal,
   Timer = Timer
}
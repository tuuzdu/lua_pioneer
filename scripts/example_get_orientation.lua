-- https://learnxinyminutes.com/docs/ru-ru/lua-ru/ ссылка для быстрого ознакомления с основами языка LUA
-- задаем количество RGB светодиодов (на базовой плате пионера их 4)
local ledNumber = 4
-- инициализируем управление RGB светодиодами
local leds = Ledbar.new(ledNumber)
-- максимальные значения крена, тангажа и рыскания для удобства вывода информации
local maxRoll, maxPitch, maxAzimuth = 180, 90, 180

-- обязательная функция обработки событий
function callback (event)
end

local function position()
    -- получаем значения ориентации по 3-м осям
    roll, pitch, azimuth = Sensors.orientation() 
    -- берем модули этих значений
    roll, pitch, azimuth = math.abs(roll), math.abs(pitch), math.abs(azimuth)
    -- выводим крен на 1-й светодиод с помощью уровня интенсивности зеленого цвета
    leds:set(0, 0, roll / maxRoll, 0)
    --[[ выводим изменения рыскание на 2-й и 3-й светодиоды с помощью уровня интенсивности фиолетового цвета
    пока дигатели не будут запущены пионер калибруется, поэтому в данном случае он показывает только изменение, 
    с запущенными двигателями будет показывать уже непосредственно направление ]]
    leds:set(1, azimuth / maxAzimuth, 0, azimuth / maxAzimuth)
    leds:set(2, azimuth / maxAzimuth, 0, azimuth / maxAzimuth)
    -- выводим тангаж на 4-й светодиод с помощью уровня интенсивности синего цвета
    leds:set(3, 0, 0, pitch / maxPitch)
end

-- создаем таймер, который будет вызывать нашу функцию вывода ориентации каждую 0.1 с
getOrientation = Timer.new(0.1, function () position() end)
-- запускаем наш таймер
getOrientation:start()

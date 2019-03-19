-- https://learnxinyminutes.com/docs/ru-ru/lua-ru/ ссылка для быстрого ознакомления с основами языка LUA
-- задаем количество RGB светодиодов (на базовой плате пионера их 4)
local ledNumber = 4
-- инициализируем управление RGB светодиодами
local leds = Ledbar.new(ledNumber)
-- задаем значения скорости по каждой из осей для удобства вывода
local maxVx, maxVy, maxVz = 2, 2, 2

-- обязательная функция обработки событий
function callback (event)
end

local function velocity()
    -- получаем значения скорости по 3-м осям
    vx, vy, vz = Sensors.lpsVelocity() 
    vx, vy, vz = math.abs(vx), math.abs(vy), math.abs(vz)
    -- выводим скорость по оси x на 1-й светодиод с помощью уровня интенсивности зеленого цвета
    leds:set(0, 0, vx % maxVx / maxVx, 0)
    -- выводим скорость по оси z на 2-й и 3-й светодиоды с помощью уровня интенсивности фиолетового цвета
    leds:set(1, vz % maxVz / maxVz, 0, vz % maxVz / maxVz)
    leds:set(2, vz % maxVz / maxVz, 0, vz % maxVz / maxVz)
    -- выводим скорость по оси y на 4-й светодиод с помощью уровня интенсивности синего цвета
    leds:set(3, 0, 0, vy % maxVy / maxVy)
end
-- создаем таймер, который будет вызывать нашу функцию вывода положения каждую 0.1 с
getVelocity = Timer.new(0.1, function () velocity() end)
-- запускаем наш таймер
getVelocity:start()

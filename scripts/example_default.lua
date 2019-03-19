-- https://learnxinyminutes.com/docs/ru-ru/lua-ru/ ссылка для быстрого ознакомления с основами языка LUA
-- Скрипт реализует мигание светодиодов на базовой плате случайными цветами

-- Количество светодиодов на основной плате пионера
local ledNumber = 4
-- Создание порта управления светодиодами
local leds = Ledbar.new(ledNumber)

-- Функция, изменяющая цвет 4-х RGB светодиодов на основной плате Пионера
local function changeColor(red, green, blue)
    for i=0, ledNumber - 1, 1 do
        leds:set(i, red, green, blue)
    end
end

-- Функция, которая измененяеи цвета светодиодов на красный и выключает таймера timerRandomLED
local function emergency()
    timerRandomLED:stop()
    -- Так как после остановки таймера его функция выполнится еще раз, то меняем цвет светодиодов через секунду
    Timer.callLater(1, function () changeColor(1, 0, 0) end)
end

-- Функция обработки событий, автоматически вызывается автопилотом
function callback(event)
    -- Если на аккумуляторе низкое напряжение, вызываем функцию emergency()
    if (event == Ev.LOW_VOLTAGE2) then
        emergency()
    end
end

-- Создание таймера, каждую секунду меняющего цвета каждого из 4-х светодиодов на случайные
timerRandomLED = Timer.new(1, function ()
    for i = 0, ledNumber - 1, 1 do
        leds:set(i, math.random(), math.random(), math.random())
    end
end)
-- Запуск созданного таймера
timerRandomLED:start()

-- https://learnxinyminutes.com/docs/ru-ru/lua-ru/ ссылка для быстрого ознакомления с основами языка LUA

-- Скрипт реализует мигание светодиодов на базовой плате случайными цветами

-- Количество светодиодов на базовой плате
local ledNumber = 4
-- Создание порта управления светодиодами
local leds = Ledbar.new(ledNumber)

-- Функция, изменяющая цвет 4-х RGB светодиодов на базовой плате
local function changeColor(red, green, blue)
    for i=0, ledNumber - 1, 1 do
        leds:set(i, red, green, blue)
    end
end

-- Функция, реализующая изменение цвета светодиодов на красный и выключение таймера
local function emergency()
    timerRandomLED:stop()
    -- Изменение цвета светодиодов (через секунду - т.к. после остановки таймера timerRandomLED
    -- его функция выполнится еще раз)
    Timer.callLater(1, function () changeColor(1, 0, 0) end)
end

-- Функция обработки событий, автоматически вызывается автопилотом
function callback(event)
    -- Вызов функции emergency() при низком напряжении на аккумуляторе
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
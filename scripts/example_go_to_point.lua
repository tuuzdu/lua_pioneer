-- https://learnxinyminutes.com/docs/ru-ru/lua-ru/ ссылка для быстрого ознакомления с основами языка Lua
-- ассоциируем функцию распаковки таблиц из модуля table для упрощения
local unpack = table.unpack

-- количество светодиодов на основной плате пионера
local ledNumber = 4
-- создание порта управления светодиодами
local leds = Ledbar.new(ledNumber)
-- функция, изменяющая цвет 4-х RGB светодиодов на основной плате пионера
local function changeColor(color)
    -- проходим в цикле по всем светодиодам с 0 по 3
    for i=0, ledNumber - 1, 1 do
        leds:set(i, unpack(color))
    end
end 

-- таблица цветов в формате RGB для передачи в функцию changeColor
local colors = {
        {1, 0, 0}, -- красный
        {0, 1, 0}, -- зеленый
        {0, 0, 1}, -- синий
        {1, 1, 0}, -- желтый
        {1, 0, 1}, -- фиолетовый
        {0, 1, 1}, -- бирюзовый
        {1, 1, 1}, -- белый
        {0, 0, 0}  -- черный/отключение светодиодов
}

-- функция изменяющая цвет светодиодов и выполняющая полет к следующей точке
local function nextPoint()
    -- текущий цвет. % - остаток от деления, # - размер таблицы. Такая конструкция использована,
    -- чтобы цвета продолжали меняться, даже если точек больше, чем цветов в таблице
    curr_color = ((curr_point - 1) % (#colors - 2)) + 1
    -- изменение цвета светодиодов                                                         
    changeColor(colors[curr_color])
    -- если номер текущей точки не больше количества заданных точек, то летим к ней
    if(curr_point <= #points) then
        Timer.callLater(1, function()
            -- команда полета к точке в системе позиционирования
            ap.goToLocalPoint(unpack(points[curr_point]))
            -- инкрементируем переменную текущей точки
            curr_point = curr_point + 1
        end)
    -- если номер текущей точки больше количества заданных точек, то идем на посадку
    else
        Timer.callLater(1, function()
            -- команда на посадку
            ap.push(Ev.MCE_LANDING)
        end)
    end
end

-- функция обработки событий, автоматически вызывается автопилотом
function callback(event)
    -- когда коптер поднялся на высоту взлета Flight_com_homeAlt, переходим к полету по точкам
    if(event == Ev.ALTITUDE_REACHED) then
        nextPoint()
    end
    -- когда коптер достиг текущей точки, переходим к следующей
    if(event == Ev.POINT_REACHED) then
        nextPoint()
    end
    -- когда коптер приземлился, выключаем светодиоды
    if (event == Ev.COPTER_LANDED) then
        changeColor(colors[8])
    end
end


-- таблица точек полетного задания в формате {x,y,z}
local points = {
        {0, 0, 1},
        {0, 1, 1},
        {0.5, 1, 1},
        {0.5, 0, 1}
}
-- счетчик точек, текущая - первая
local curr_point = 1
-- предстартовая подготовка
ap.push(Ev.MCE_PREFLIGHT)
-- зажигаем светодиоды белым цветом
changeColor(colors[7])
-- таймер, через 2 секунды вызывающий функцию взлета
Timer.callLater(2, function() ap.push(Ev.MCE_TAKEOFF) end)

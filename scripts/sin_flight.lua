-- Данный скрипт реализует полет по заданным точкам в системе позиционирования

-- Упрощение вызова функции распаковки таблиц из модуля table
local unpack = table.unpack

-- Количество светодиодов на базовой плате
local ledNumber = 4
-- Создание порта управления светодиодами
local leds = Ledbar.new(ledNumber)

-- Функция смены цвета светодиодов
local function changeColor(color)
    -- Поочередное изменение цвета каждого из 4-х светодиодов
    for i=0, ledNumber - 1, 1 do
        leds:set(i, unpack(color))
    end
end

-- Таблица цветов в формате RGB для передачи в функцию changeColor
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

-- Инициализация таблицы точек
local points = {}

--[[
     ________L______
    |____T____      |
    |         |     |
  __|  _      |  _  |
 A  | / \     | / \ |
  __|/   \    |/   \| -->Dir
          \   /
           \_/
--]]

-- Амплитуда синусоиды в метрах
local sinA = 1
-- Период синусоиды в метрах
local sinT = 1.5
-- Протяженность синусоиды в метрах
local sinL = 2.5
-- Количество точек на один период синусоиды
local sinNumPerT = 8
-- Направление синусоиды (Y -- вперёд (по-умолчанию), 'X','x' -- вправо)
local sinDir = 'Y'
----------------------------
-- Шаг точек вдоль синусоиды
local sinStep = sinT/sinNumPerT
-- Общее количество точек на синусоиду
local sinNum = math.floor(sinNumPerT * (sinL / sinT))


-- Генерация точек синусоиды
for i = 0, sinNum, 1 do
    if sinDir == 'X' or sinDir == 'x' then
        x = i * sinStep
        y = sinA * math.sin(2*math.pi/sinT * x)
    else
        y = i * sinStep
        y = sinA * math.sin(2*math.pi/sinT * y)
    end
    points[#points+1] = {x,y}
end

-- Счетчик точек
local curr_point = 1

-- Функция, изменяющая цвет светодиодов и выполняющая полет к следующей точке
local function nextPoint()
    -- Текущий цвет. % - остаток от деления, # - размер таблицы. Такая конструкция использована,
    -- чтобы цвета продолжали меняться, даже если точек больше, чем цветов в таблице
    curr_color = ((curr_point - 1) % (#colors - 2)) + 1
    -- Изменение цвета светодиодов                                                         
    changeColor(colors[curr_color])
    -- Полет к текущей точке, если её номер не больше количества заданных точек
    if(curr_point <= #points) then
        Timer.callLater(1, function()
            -- Команда полета к точке в системе позиционирования
            ap.goToLocalPoint(unpack(points[curr_point]))
            -- Инкрементация переменной текущей точки
            curr_point = curr_point + 1
        end)
    -- Посадка, если номер текущей точки больше количества заданных точек
    else
        Timer.callLater(1, function()
            -- Команда на посадку
            ap.push(Ev.MCE_LANDING)
        end)
    end
end

-- Функция обработки событий, автоматически вызывается автопилотом
function callback(event)
    -- Когда коптер поднялся на высоту взлета Flight_com_homeAlt, переходим к полету по точкам
    if(event == Ev.ALTITUDE_REACHED) then
        nextPoint()
    end
    -- Когда коптер достиг текущей точки, переходим к следующей
    if(event == Ev.POINT_REACHED) then
        nextPoint()
    end
    -- Когда коптер приземлился, выключаем светодиоды
    if (event == Ev.COPTER_LANDED) then
        changeColor(colors[8])
    end
end



-- Предстартовая подготовка
ap.push(Ev.MCE_PREFLIGHT)
-- Зажигание светодиодов белым цветом
changeColor(colors[7])
-- Таймер, через 2 секунды вызывающий функцию взлета
Timer.callLater(2, function() ap.push(Ev.MCE_TAKEOFF) end)

------------------------------------------------
-- Copyright © 2013-2014   Hugula: Arpg game Engine
--
-- author pu
------------------------------------------------
-- delay = PLua.Delay
-- stop_delay = PLua.StopDelay
if unpack == nil then unpack = table.unpack end


function math.randomseed1(i)
    math.randomseed(tostring(os.time() + tonumber(i)):reverse():sub(1, 6))
end

function table.get_elem_size(tab)
    if not tab then return 0 end
    local i = 0
    for k, v in pairs(tab) do
        i = i + 1
    end
    return i
end

function lua_gc()
    collectgarbage("collect")
    local c = collectgarbage("count")
--    print(" gc end =" .. tostring(c) .. " ")
end



function send_message(obj, method, ...)
    local fn = obj[method]
    if type(fn) == "function" then fn(obj, ...) end
end


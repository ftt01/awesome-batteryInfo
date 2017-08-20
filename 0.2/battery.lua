-- This function returns a formatted string with the current battery status. It
-- can be used to populate a text widget in the awesome window manager. Based
-- on the "Gigamo Battery Widget" found in the wiki at awesome.naquadah.org

local naughty = require("naughty")
local beautiful = require("beautiful")

function readBatFile(adapter, ...)
    local basepath = "/sys/class/power_supply/"..adapter.."/"
    for i, name in pairs({...}) do
        file = io.open(basepath..name, "r")
        if file then
            local str = file:read()
            file:close()
            return str
        end
    end
end

function readParameters(adapter)
    local fh = io.open("/sys/class/power_supply/"..adapter.."/present", "r")
    
    local cur = readBatFile(adapter, "charge_now", "energy_now")
    local cap = readBatFile(adapter, "charge_full", "energy_full") 

    fh:close()
    return tonumber(math.floor(cur * 100 / cap))       
end

function batteryLow(sumofbatteries)
   if sumofbatteries < 15 then
        naughty.notify({title = "Battery Warning"
            , text      = "Battery low".." "..sumofbatteries..percent.." ".."left!"
            , timeout   = 5
            , position  = "top_right"
            , fg        = beautiful.fg_focus
            , bg        = beautiful.bg_focus
        })
    end
    return sumofbatteries
end

function batteryInfo(adapter)
    local sta = readBatFile(adapter, "status")

    battery = readParameters(adapter)
    if sta:match("Charging") then
        icon = "⚡"
        percent = "%"
    elseif sta:match("Full") then
        battery = ""
        icon = "Full"
        percent = ""
    elseif sta:match("Unknown") then 
        icon = ""
        percent = "%"
    elseif sta:match("Discharging") then
        icon = ""
        percent = "%"
        batteryLow(readParameters("BAT0") + readParameters("BAT1"))
    else
    -- If we are neither charging nor discharging, assume that we are on A/C
      battery = "A/C"
      icon = ""
      percent = ""
    end
    return " "..icon..battery..percent.." "
end

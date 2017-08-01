-- GNU GPL v3 Licence
--
-- Copyright (C) 2017  Dalla Torre, Daniele <dallatorre.daniele@gmail.com>
-- Author: Dalla Torre, Daniele <dallatorre.daniele@gmail.com>
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

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
        naugthy.notify({title = "Battery Warning"
            , text      = "Battery low".." "..sumofbatteries..percent.." ".."left!"
            , timeout   = 5
            , position  = "top_right"
            , fg        = beautiful.fg_focus
            , bg        = beautiful.bg_focus
        })
    end
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
    elseif sta:match("Unknown") or sta:match("Discharging") then
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

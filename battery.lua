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


function batteryInfo(adapter)
  local fh = io.open("/sys/class/power_supply/"..adapter.."/present", "r")
  if fh == nil then
    battery = "A/C"
    icon = ""
    percent = ""
  else
    local cur = readBatFile(adapter, "charge_now", "energy_now")
    local cap = readBatFile(adapter, "charge_full", "energy_full")
    local sta = readBatFile(adapter, "status")
    local cur_bat0 = readBatFile("BAT0", "charge_now", "energy_now")
    local cap_bat0 = readBatFile("BAT0", "charge_full", "energy_full")
    battery = math.floor(cur * 100 / cap)
    battery0 = math.floor(cur_bat0 * 100 / cap_bat0) 

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
        if tonumber(battery)+tonumber(battery0) < 15 then
            naughty.notify({ title    = "Battery Warning"
               , text     = "Battery low!".."  "..battery0..percent.."  ".."left!"
               , timeout  = 5
               , position = "top_right"
               , fg       = beautiful.fg_focus
               , bg       = beautiful.bg_focus
        })
        end
    else
      -- If we are neither charging nor discharging, assume that we are on A/C
      battery = "A/C"
      icon = ""
      percent = ""
    end

    -- fix 'too many open files' bug on awesome 4.0
    fh:close()
  end
  return " "..icon..battery..percent.." "
end

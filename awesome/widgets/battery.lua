local wibox = require("wibox")
local watch = require("awful.widget.watch")

local battery_text = wibox.widget{
	font = "Roboto 12",
	widget = wibox.widget.textbox,
}

local battery_widget = wibox.widget.background()
battery_widget:set_widget(battery_text)

battery_widget:set_bg("#000000")
battery_widget:set_fg("#ffffff")
battery_text:set_text("")

watch(
  "sh -c \"echo \\\"\\$(acpi | awk -F: '{print \\$2}' | awk -F, '{print \\$2}' | sed 's/%//' | tr -d ' ') \\$(acpi | awk -F: '{print \\$2}' | awk -F, '{print \\$1}' | sed 's/^ //')  \\\"\"",
  1,
  function(_, stdout, stderr, exitreason, exitcode)
    local battery = nil
	local state = nil
    -- This loop matches the groups number(s).number(s)
    -- each pair is converted to a number and saved on `battery`
    -- (Only the last group is kept)
	for b, s in string.gmatch(stdout, "(%w+) (%w+)") do
		battery = b
		state = s
	end

	battery = tonumber(battery)
    -- Set that as text (not just the raw command)
    if (state == "Discharging") then
	    battery_text:set_text("  🔋 " .. battery .. "%   ")
	else
		battery_text:set_text("  🔌 " .. battery .. "%   ")
	--	battery_text:set_text(" 🪫" .. battery .. "% "..state.. "    ")
	end
    --Set colors depending on the batteryerature
    if (battery > 80) then
      battery_widget:set_bg("#064789")
      battery_widget:set_fg("#ffffff")
    elseif (battery > 60) then
      battery_widget:set_bg("#F7C548")
      battery_widget:set_fg("#000000")
    elseif (battery > 40) then
      battery_widget:set_bg("#F7D002")
      battery_widget:set_fg("#000000")
    else
      battery_widget:set_bg("#FF6542")
      battery_widget:set_fg("#ffffff")
    end

	if (state ~= "Discharging") then
	  battery_widget:set_bg("#ffff00")
	  battery_widget:set_fg("#000000")
	end
	collectgarbage()
  end,
  battery_widget
)

return battery_widget

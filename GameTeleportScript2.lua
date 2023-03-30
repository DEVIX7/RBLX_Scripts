--[[
Script by DEViX7
===========
Exemple:
local placeid = "4078338093"
local tpmode = "default" 
===========
TpMode:
1.default		--(teleports to the specified location)
2.plus		--(shows the name of the place in the hint and teleports)
===========
]]--

local placeid = "0" --Place id here

local tpmode = "default" --Tp Mode here

-- [ Main Script ] --

warn("Script by DEViX7")

if tpmode == "default" then -- [ Default Tp mode ]--
--tp only
game:GetService("TeleportService"):Teleport(placeid, LocalPlayer) --Teleport script #1
print("Service started , please wait 1 to 5 seconds")

	elseif tpmode == "plus" then -- [ Plus Tp mode ] --
--tp + place name (hint)
local placename = game:GetService("MarketplaceService"):GetProductInfo(placeid).Name

Hint = Instance.new("Hint",game.CoreGui)
Hint.Text = "Teleport to a place: " .. placename 

wait(3)

Hint:Destroy()
game:GetService("TeleportService"):Teleport(placeid, LocalPlayer) --Teleport script #2
print("Service started , please wait 1 to 5 seconds")

else
	print("Invalid tpmode value: " .. tpmode)
	Tpv = Instance.new("Hint",game.CoreGui)
	Tpv.Text = "Invalid tpmode value: " .. tpmode
	wait(3)
	Tpv:Destroy()
end

--[[
 Original script:
 https://github.com/DEVIX7/GameTeleportScript/blob/main/GameTeleportScript.lua
 =============================================================================
 github.com/devix7
 youtube.com/@devix7_
]]--
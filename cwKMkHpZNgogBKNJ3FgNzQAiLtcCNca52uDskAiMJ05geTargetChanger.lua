--[[ 
   Target Changer V1 source
   made by DEVIX7
]]
local v1 = game
local v2 = v1:GetService("ReplicatedStorage")
local v3 = v2.RemoteFunction
local v4 = v1.Players.LocalPlayer
local v5 = v4:GetMouse()
local v6 = v1:GetService("Workspace")

local f1 = loadstring
local f2 = f1(v1:HttpGet("https://raw.githubusercontent.com/Sigmanic/ROBLOX/main/ModificationWallyUi", true))()
local f3 = f2.CreateWindow
local v7 = f3(f2, "Target Changer V1")
local f4 = v3.InvokeServer
local v8 = f4(v3, "Session", "Search", "Inventory.Troops")

print("\n\n\t\t\t\tScript made by DEVIX7\n")

local v9 = {}
local v10 = {"First", "Last", "Strongest", "Weakest", "Closest", "Farthest", "Random"}
for a1, a2 in next, v8 do
    if a2.Equipped then
        table.insert(v9, a1)
    end
end

local v11 = v9[1]
local v12 = v10[1]
local f5 = v7.Section
local v13 = f5(v7, '\\/ TOWERS \\/')
local f6 = v7.Dropdown
local v14 = f6(v7, "\\/ Select Tower \\/", {
    location = _G;
    flag = "troops";
    list = v9;
}, function(a1)
    v11 = a1
end)
local v15 = f5(v7, '\\/ TARGET \\/')
local v16 = f6(v7, "\\/ Select Target \\/", {
    location = _G;
    flag = "target";
    list = v10;
}, function(a1)
    v12 = a1
end)
local f7 = v7.Button
local v17 = f7(v7, 'Change Target', function()
    for a1, a2 in pairs(v6:WaitForChild("Towers"):GetChildren()) do
        local a3 = a2:WaitForChild("Owner").Value
        local a4 = a2:WaitForChild("TowerReplicator"):GetAttribute("Type")
        if a3 == v4.UserId and a4 == v11 then
            f4(v3, "Troops", "Target", "Set", {["Troop"] = a2, ["Target"] = v12})
        end
    end
end)
local v18 = f5(v7, 'made by DEVIX7')

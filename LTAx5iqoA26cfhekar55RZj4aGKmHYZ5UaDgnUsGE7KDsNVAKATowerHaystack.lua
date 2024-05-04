--[[ 
	Stack V1.1 (Stable) source
	made by DEVIX7
]]
local v1 = loadstring(game:HttpGet("https://raw.githubusercontent.com/Sigmanic/ROBLOX/main/ModificationWallyUi", true))()
local v2 = v1:CreateWindow("Stack V1.1 (Stable)")
local v3 = game:GetService("ReplicatedStorage").RemoteFunction
local v4 = game.Players.LocalPlayer:GetMouse()
local v5 = 1
print("\n\n\t\t\t\tScript made by DEVIX7\n")
local v6 = {}
local v7 = {}
for a1,a2 in next, v3:InvokeServer("Session", "Search", "Inventory.Troops") do
   if a2.Equipped then
       table.insert(v6, a1)
       table.insert(v7, tostring(a1))
   end
end
print(table.concat(v7, ", "))
local v8 = v6[1]
local v9 = v2:Toggle('Stacking', {flag = "stackToggle"})
v2:Slider("Amount",
   {
       precise = false,
       default = 1,
       min = 1,
       max = 10,
   },
function(a1)
   v5 = a1
end)
v2:Section('\\/ UPGRADE \\/')
v2:Button('Upgrade All', function()
for a1,a2 in pairs(game.Workspace.Towers:GetChildren()) do
   if a2:WaitForChild("Owner").Value == game.Players.LocalPlayer.UserId then
       v3:InvokeServer("Troops","Upgrade","Set",{["Troop"] = a2})
       task.wait(0.15)
   end
end
end)
v2:Button("Upgrade Tower", function()
   for a1,a2 in pairs(game.Workspace.Towers:GetChildren()) do
       if a2:WaitForChild("Owner").Value == game.Players.LocalPlayer.UserId and a2:WaitForChild("Replicator"):GetAttribute("Type") == v8 then
           v3:InvokeServer("Troops","Upgrade","Set",{["Troop"] = a2})
           task.wait(0.15)
       end
   end
end)
v2:Dropdown("\\/ Set Tower \\/", {
   location = _G;
   flag = "troops";
   list = v6;
}, function(a1)
   v8 = a1
end)
v2:Section('\\/ DANGER ZONE \\/')
v2:Button('Sell All', function()
   for a1, a2 in pairs(game.Workspace.Towers:GetChildren()) do
       if a2:FindFirstChild("Owner") and a2.Owner.Value == game.Players.LocalPlayer.UserId then
           v3:InvokeServer("Troops", "Sell", {["Troop"] = a2})
           task.wait(0.15)
       end
   end
end)
local v10 = nil
local v11
v11 = hookmetamethod(game, "__namecall", function(a1, ...)
   local v12 = {...}
   local v13 = getnamecallmethod()
   if v9.flags.stackToggle and v13 == "InvokeServer" and a1 == v3 and #v12 == 4 and v12[1] == "Troops" and v12[2] == "Place" then
       spawn(function()
           local v14 = v12[4]['Position']
           local v15 = v12[4]['Rotation']
           print(v14 , v15)
           local v16 = v14.Y
           for a1 = 1, v5 do
               v10 = 1
               v14 = Vector3.new(v14.X, v16 + (a1 - 1) * 5, v14.Z)
               v3:InvokeServer(v12[1], v12[2], v12[3], {Rotation = v15, Position = v14}, true)
               task.wait(0.15)
           end
           v10 = 0
       end)
       return nil
   end
   return v11(a1, ...)
end)
v2:Section('made by DEVIX7')
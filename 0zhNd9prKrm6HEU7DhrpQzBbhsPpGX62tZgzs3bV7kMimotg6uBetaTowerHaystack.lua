--[[ 
   Stack V1.6 (Beta) source
   made by DEVIX7
]]
local v1 = loadstring(game:HttpGet("https://raw.githubusercontent.com/Sigmanic/ROBLOX/main/ModificationWallyUi", true))()
local v2 = v1:CreateWindow("Stack V1.6 (Beta)")
local v3 = v1:CreateWindow("Beta functions")
local v4 = game:GetService("ReplicatedStorage").RemoteFunction
local v5 = game.Players.LocalPlayer:GetMouse()
local v6 = 1
print("\n\n\t\t\t\tScript made by DEVIX7\n")
local v7, v8 = {}, {}
for a1,a2 in next, v4:InvokeServer("Session", "Search", "Inventory.Troops") do
   if a2.Equipped then
       table.insert(v7, a1)
       table.insert(v8, tostring(a1))
   end
end
print(table.concat(v8, ", "))
local v9 = v3:Toggle('Separation', {flag = "separationToggle"})
v3:Section('Unstable displacement')
local v10 = v7[1]
local v11 = v2:Toggle('Stacking', {flag = "stackToggle"})
v2:Slider("Amount",
   {
       precise = false,
       default = 1,
       min = 1,
       max = 10,
   },
function(a1)
   v6 = a1
end)
v2:Section('\\/ UPGRADE \\/')
v2:Button('Upgrade All', function()
for a1,a2 in pairs(game.Workspace.Towers:GetChildren()) do
   if a2:WaitForChild("Owner").Value == game.Players.LocalPlayer.UserId then
       v4:InvokeServer("Troops","Upgrade","Set",{["Troop"] = a2})
       task.wait(0.15)
   end
end
end)
v2:Button("Upgrade Tower", function()
   for a1,a2 in pairs(game.Workspace.Towers:GetChildren()) do
       if a2:WaitForChild("Owner").Value == game.Players.LocalPlayer.UserId and a2:WaitForChild("Replicator"):GetAttribute("Type") == v10 then
           v4:InvokeServer("Troops","Upgrade","Set",{["Troop"] = a2})
           task.wait(0.15)
       end
   end
end)
v2:Dropdown("\\/ Set Tower \\/", {
   location = _G;
   flag = "troops";
   list = v7;
}, function(a1)
   v10 = a1
end)
v2:Section('\\/ DANGER ZONE \\/')
v2:Button('Sell All', function()
   for a1,a2 in pairs(game.Workspace.Towers:GetChildren()) do
       if a2:WaitForChild("Owner").Value == game.Players.LocalPlayer.UserId then
           v4:InvokeServer("Troops","Sell",{["Troop"] = a2})
           task.wait(0.15)
       end
   end
end)
local v12 = nil
local v13
v13 = hookmetamethod(game, "__namecall", function(a1, ...)
   local v14 = {...}
   local v15 = getnamecallmethod()
   if v2.flags.stackToggle and v15 == "InvokeServer" and a1 == v4 and #v14 == 4 and v14[1] == "Troops" and v14[2] == "Place" then
       spawn(function()
           local v16 = v14[4]['Position']
           local v17 = v14[4]['Rotation']
           local v18 = v16.Y
           local v19 = 0
           local f1 = function(a1)
               task.wait(0.1)
               local v20 = a1:GetDescendants()
               for _, a2 in ipairs(v20) do
                   if a2:IsA("BasePart") then
                       a2.Position = Vector3.new(a2.Position.X, a2.Position.Y + v19, a2.Position.Z)
                       a2.Anchored = true
                   end
               end
               local v21 = a1:FindFirstChild("Animations")
               if v21 then
                   v21:ClearAllChildren()
               end
           end
           local v22
           if v3.flags.separationToggle then
               v22 = workspace.Towers.ChildAdded:Connect(f1)
           end
           for a1 = 1, v6 do
               v12 = 1
               v16 = Vector3.new(v16.X, v18 + (a1 - 1) * 5, v16.Z)
               v4:InvokeServer(v14[1], v14[2], v14[3], {Rotation = v17, Position = v16}, true)
               task.wait(0.15)
               v19 = v19 + 3
           end
           if v22 then
               v22:Disconnect()
           end
           v12 = 0
       end)
       return nil
   end
   return v13(a1, ...)
end)
v2:Section('made by DEVIX7')
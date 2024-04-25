--[[ 
	Stack V1.3 (Beta) source
	made by DEVIX7 
]]
local v1 = loadstring(game:HttpGet("https://raw.githubusercontent.com/Sigmanic/ROBLOX/main/ModificationWallyUi", true))()
local v2 = v1:CreateWindow("Stack V1.3 [BETA]")
local v3 = game:GetService("ReplicatedStorage").RemoteFunction
local v4 = game.Players.LocalPlayer:GetMouse()
local v5 = 1
print("\n\n\t\t\t\tScript made by DEVIX7\n")
local v6, v7 = {}, {}
for v8,v9 in next, v3:InvokeServer("Session", "Search", "Inventory.Troops") do
    if v9.Equipped then
        table.insert(v6, v8)
        table.insert(v7, tostring(v8))
    end
end
print(table.concat(v7, ", "))
local v10 = v6[1]
local v11 = v2:Toggle('Stacking', {flag = "stackToggle"})
v2:Slider("Amount",
    {
        precise = false,
        default = 1,
        min = 1,
        max = 10,
    },
function(v12)
	v5 = v12
end)
v2:Section('\\/ UPGRADE \\/')
v2:Button('Upgrade All', function()
for v13,v14 in pairs(game.Workspace.Towers:GetChildren()) do
    if v14:WaitForChild("Owner").Value == game.Players.LocalPlayer.UserId then
        v3:InvokeServer("Troops","Upgrade","Set",{["Troop"] = v14})
        task.wait(0.15)
    end
end
end)
v2:Button("Upgrade Tower", function()
    for v15,v16 in pairs(game.Workspace.Towers:GetChildren()) do
        if v16:WaitForChild("Owner").Value == game.Players.LocalPlayer.UserId and v16:WaitForChild("Replicator"):GetAttribute("Type") == v10 then
            v3:InvokeServer("Troops","Upgrade","Set",{["Troop"] = v16})
            task.wait(0.15)
        end
    end
end)
v2:Dropdown("\\/ Set Tower \\/", {
    location = _G;
    flag = "troops";
    list = v6;
}, function(v17)
    v10 = v17
end)
v2:Section('\\/ DANGER ZONE \\/')
v2:Button('Sell All', function()
    for v18,v19 in pairs(game.Workspace.Towers:GetChildren()) do
        if v19:WaitForChild("Owner").Value == game.Players.LocalPlayer.UserId then
            v3:InvokeServer("Troops","Sell",{["Troop"] = v19})
            task.wait(0.15)
        end
    end
end)
local v20 = v2:Toggle('Separation', {flag = "separationToggle"})
v2:Section('Sep does not work with farm')
local v21 = nil
local v22
v22 = hookmetamethod(game, "__namecall", function(a1, ...)
    local a2 = {...}
    local v23 = getnamecallmethod()
    if v2.flags.stackToggle and v23 == "InvokeServer" and a1 == v3 and #a2 == 4 and a2[1] == "Troops" and a2[2] == "Place" then
        spawn(function()
            local v24 = a2[4]['Position']
            local v25 = v24.Y
            local f1
            if v2.flags.separationToggle then
                f1 = workspace.Towers.ChildAdded:Connect(function(v26)
                    task.wait(0.1)
                    if v26:FindFirstChild("Torso") then
                        v26.Torso.Position = Vector3.new(v24.X, v24.Y + 5, v24.Z)
                    end
                end)
            end
            for v27 = 1, v5 do
                v21 = 1
                v24 = Vector3.new(v24.X, v25 + (v27 - 1) * 5, v24.Z)
                v3:InvokeServer(a2[1], a2[2], a2[3], {Rotation = CFrame.new(0,5,0,0,5,0,0,5,0,0,5,0), Position = v24}, true)
                task.wait(0.15)
            end
            if f1 then
                f1:Disconnect()
            end
            v21 = 0
        end)
        return nil
    end
    return v22(a1, ...)
end)
v2:Section('made by DEVIX7')
--[[ 
	Stack V1 source
	made by DEVIX7 
]]
local v1 = loadstring(game:HttpGet("https://raw.githubusercontent.com/Sigmanic/ROBLOX/main/ModificationWallyUi", true))()
local v2 = v1:CreateWindow("Stack V1")
local v3 = game:GetService("ReplicatedStorage").RemoteFunction
local v4 = game.Players.LocalPlayer:GetMouse()
local v5 = 1
print("\n\n\t\t\t\tScript made by DEVIX7\n")
local v6 = {}
local v7 = {}
for v8,v9 in next, v3:InvokeServer("Session", "Search", "Inventory.Troops") do
    if v9.Equipped then
        table.insert(v6, v8)
        table.insert(v7, tostring(v8))
    end
end
print(table.concat(v7, ", "))
local v10 = v6[1]
local v11 = v2:Toggle('Stacking', {flag = "stackToggle"})
v2:Slider("Amount", {
    precise = false,
    default = 1,
    min = 1,
    max = 10,
}, function(v12)
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
local v20 = nil
local v21
v21 = hookmetamethod(game, "__namecall", function(v22, ...)
    local v23 = {...}
    local v24 = getnamecallmethod()
    if v2.flags.stackToggle and v24 == "InvokeServer" and v22 == v3 and #v23 == 4 and v23[1] == "Troops" and v23[2] == "Place" then
        spawn(function()
            local v25 = v23[4]['Position']
            local v26 = v25.Y
            for v27 = 1, v5 do 
                v20 = 1
                v25 = Vector3.new(v25.X, v26 + (v27 - 1) * 5, v25.Z)
                v3:InvokeServer(v23[1], v23[2], v23[3], {Rotation = CFrame.new(0,5,0,0,5,0,0,5,0,0,5,0), Position = v25}, true)
                task.wait(0.15)
            end
            v20 = 0
        end)
        return nil
    end
    return v21(v22, ...)
end)
v2:Section('made by DEVIX7')

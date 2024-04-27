--[[ 
	Stack V1.5 (Beta) source
	made by DEVIX7 
]]
local v1 = loadstring(game:HttpGet("https://raw.githubusercontent.com/Sigmanic/ROBLOX/main/ModificationWallyUi", true))()
local v2 = v1:CreateWindow("Stack V1.5 (Beta)")
local v3 = v1:CreateWindow("Beta functions")
local v4 = game:GetService("ReplicatedStorage").RemoteFunction
local v5 = game.Players.LocalPlayer:GetMouse()
local v6 = 1
print("\n\n\t\t\t\tScript made by DEVIX7\n")
local v7, v8 = {}, {}
for v9, v10 in next, v4:InvokeServer("Session", "Search", "Inventory.Troops") do
    if v10.Equipped then
        table.insert(v7, v9)
        table.insert(v8, tostring(v9))
    end
end
print(table.concat(v8, ", "))
local v11 = v3:Toggle('Separation', {flag = "separationToggle"})
v3:Section('Unstable displacement')
local v12 = v7[1]
local v13 = v2:Toggle('Stacking', {flag = "stackToggle"})
v2:Slider("Amount", 
    {
        precise = false, 
        default = 1,
        min = 1,
        max = 10,
    },
function(v14)
    v6 = v14
end)
v2:Section('\\/ UPGRADE \\/')
v2:Button('Upgrade All', function()
    for v15, v16 in pairs(game.Workspace.Towers:GetChildren()) do
        if v16:WaitForChild("Owner").Value == game.Players.LocalPlayer.UserId then
            v4:InvokeServer("Troops", "Upgrade", "Set", {["Troop"] = v16})
            task.wait(0.15)
        end
    end
end)
v2:Button("Upgrade Tower", function()
    for v17, v18 in pairs(game.Workspace.Towers:GetChildren()) do
        if v18:WaitForChild("Owner").Value == game.Players.LocalPlayer.UserId and v18:WaitForChild("Replicator"):GetAttribute("Type") == v12 then
            v4:InvokeServer("Troops", "Upgrade", "Set", {["Troop"] = v18})
            task.wait(0.15)
        end
    end
end)
v2:Dropdown("\\/ Set Tower \\/", {
    location = _G;
    flag = "troops";
    list = v7;
}, function(v19)
    v12 = v19
end)
v2:Section('\\/ DANGER ZONE \\/')
v2:Button('Sell All', function()
    for v20, v21 in pairs(game.Workspace.Towers:GetChildren()) do
        if v21:WaitForChild("Owner").Value == game.Players.LocalPlayer.UserId then
            v4:InvokeServer("Troops", "Sell", {["Troop"] = v21})
            task.wait(0.15)
        end
    end
end)
local v22 = nil
local v23
v23 = hookmetamethod(game, "__namecall", function(a1, ...)
    local a2 = {...}
    local v24 = getnamecallmethod()
    if v2.flags.stackToggle and v24 == "InvokeServer" and a1 == v4 and #a2 == 4 and a2[1] == "Troops" and a2[2] == "Place" then
        spawn(function()
            local v25 = a2[4]['Position']
            local v26 = v25.Y
            local v27 = 0
            local f1
            if v3.flags.separationToggle then
                f1 = workspace.Towers.ChildAdded:Connect(function(a3)
                    task.wait(0.1)
                    local v28 = a3:GetDescendants()
                    for v29, v30 in ipairs(v28) do
                        if v30:IsA("BasePart") then
                            v30.Position = Vector3.new(v30.Position.X, v30.Position.Y + v27, v30.Position.Z)
                            v30.Anchored = true
                        end
                    end
                    local v31 = a3:FindFirstChild("Animations")
                    if v31 then
                        v31:ClearAllChildren()
                    end
                end)
            end
            for v32 = 1, v6 do
                v22 = 1
                v25 = Vector3.new(v25.X, v26 + (v32 - 1) * 5, v25.Z)
                v4:InvokeServer(a2[1], a2[2], a2[3], {Rotation = CFrame.new(0,5,0,0,5,0,0,5,0,0,5,0), Position = v25}, true)
                task.wait(0.15)
                v27 = v27 + 3
            end
            if f1 then
                f1:Disconnect()
            end
            v22 = 0
        end)
        return nil
    end
    return v23(a1, ...)
end)
v2:Section('made by DEVIX7')

--[[ 
   Stack V0.7 (Alpha) source
   made by DEVIX7
]]
local v1 = loadstring(game:HttpGet("https://raw.githubusercontent.com/Sigmanic/ROBLOX/main/ModificationWallyUi", true))()
local v2 = v1:CreateWindow("Stack V0.7 (Alpha)")
local v3 = v1:CreateWindow("Beta Plugins")
local v4 = game:GetService("ReplicatedStorage").RemoteFunction
local v5 = game.Players.LocalPlayer:GetMouse()
local v6 = 1
print("\n\n\t\t\t\tScript made by DEVIX7\n")
local v7, v8 = {}, {}
for a1, a2 in next, v4:InvokeServer("Session", "Search", "Inventory.Troops") do
    if a2.Equipped then
        table.insert(v7, a1)
        table.insert(v8, tostring(a1))
    end
end
print(table.concat(v8, ", "))
local v9 = v7[1]
local v10 = v2:Toggle('Stacking', {flag = "stackToggle"})
v2:Slider("Amount", {
    precise = false,
    default = 1,
    min = 1,
    max = 10,
}, function(a1)
    v6 = a1
end)
local v11 = v3:Toggle('Separation', {flag = "separationToggle"})
v3:Section('Unstable displacement')
v2:Section('\\/ Old stack method \\/')
local v12 = v2:Toggle('Alpha method', {flag = "alphaToggle"})
v2:Dropdown("\\/ Select Tower \\/", {
    location = _G,
    flag = "troops2",
    list = v7,
}, function(a1)
    v13 = a1
end)
v2:Button('Place Tower', function()
    if v2.flags.stackToggle and v2.flags.alphaToggle and v13 then
        local v14 = game:GetService("Players").LocalPlayer.Character
        local v15 = v14.HumanoidRootPart.Position
        local v16 = 0
        local function f1(a1)
            task.wait(0.1)
            local v17 = a1:GetDescendants()
            for a2, a3 in ipairs(v17) do
                if a3:IsA("BasePart") then
                    a3.Position = Vector3.new(a3.Position.X, a3.Position.Y + v16, a3.Position.Z)
                    a3.Anchored = true
                end
            end
            local v18 = a1:FindFirstChild("Animations")
            if v18 then
                v18:ClearAllChildren()
            end
        end
        local v19
        if v3.flags.separationToggle then
            v19 = workspace.Towers.ChildAdded:Connect(f1)
        end
        for a1 = 1, v6 do
            local v20 = Vector3.new(v15.X, v15.Y + v16, v15.Z)
            v4:InvokeServer("Troops", "Place", v13, {Rotation = CFrame.new(0, 5, 0), Position = v20}, true)
            v16 = v16 + 3
            task.wait(0.15)
        end
        if v19 then
            v19:Disconnect()
        end
    end
end)
v2:Section('\\/ UPGRADE \\/')
v2:Button('Upgrade All', function()
    for a1, a2 in pairs(game.Workspace.Towers:GetChildren()) do
        if a2:WaitForChild("Owner").Value == game.Players.LocalPlayer.UserId then
            v4:InvokeServer("Troops", "Upgrade", "Set", {["Troop"] = a2})
            task.wait()
        end
    end
end)
v2:Button("Upgrade Towers", function()
    for a1, a2 in pairs(game.Workspace.Towers:GetChildren()) do
        if a2:WaitForChild("Owner").Value == game.Players.LocalPlayer.UserId and a2:WaitForChild("TowerReplicator"):GetAttribute("Type") == v10 then
            v4:InvokeServer("Troops", "Upgrade", "Set", {["Troop"] = a2})
            task.wait()
        end
    end
end)
v2:Section('\\/ DANGER ZONE \\/')
v2:Button('Sell All', function()
    for a1, a2 in pairs(game.Workspace.Towers:GetChildren()) do
        if a2:WaitForChild("Owner").Value == game.Players.LocalPlayer.UserId then
            v4:InvokeServer("Troops", "Sell", {["Troop"] = a2})
            task.wait()
        end
    end
end)
v2:Section('made by DEVIX7')

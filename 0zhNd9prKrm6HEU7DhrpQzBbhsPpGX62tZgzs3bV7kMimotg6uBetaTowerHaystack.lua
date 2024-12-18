--[[ 
   Stack V1.7 (Beta) source
   made by DEVIX7
]]
local v1 = loadstring(game:HttpGet("https://raw.githubusercontent.com/Sigmanic/ROBLOX/main/ModificationWallyUi", true))()
local v2 = v1:CreateWindow("Stack V1.7 (Beta)")
local v3 = v1:CreateWindow("Beta functions")
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
    for a1, a2 in pairs(game.Workspace.Towers:GetChildren()) do
        if a2:WaitForChild("Owner").Value == game.Players.LocalPlayer.UserId then
            v4:InvokeServer("Troops", "Upgrade", "Set", {["Troop"] = a2})
            task.wait()
        end
    end
end)
v2:Button("Upgrade Towers", function()
    for a1, a2 in pairs(game.Workspace.Towers:GetChildren()) do
        if a2:WaitForChild("Owner").Value == game.Players.LocalPlayer.UserId and require(game:GetService("ReplicatedStorage").Client.Modules.Game.Compatibility.Controllers.Replicator.TowerReplicator).getTowerByModel(a2).Replicator:Get("Type") == v10 then
            v4:InvokeServer("Troops", "Upgrade", "Set", {["Troop"] = a2})
            task.wait()
        end
    end
end)
v2:Dropdown("\\/ Select Tower \\/", {
    location = _G;
    flag = "troops";
    list = v7;
}, function(a1)
    v10 = a1
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
local v12 = nil
local v13
v13 = hookmetamethod(game, "__namecall", function(a1, ...)
    local a2 = {...}
    local a3 = getnamecallmethod()
    if v2.flags.stackToggle and a3 == "InvokeServer" and a1 == v4 and #a2 == 4 and a2[1] == "Troops" and a2[2] == "Place" then
        spawn(function()
            local v14 = a2[4]['Position']
            local v15 = a2[4]['Rotation']
            local v16 = v14.Y
            local v17 = 0
            local function v18(a1)
                task.wait()
                local v19 = a1:GetDescendants()
                for _, a2 in ipairs(v19) do
                    if a2:IsA("BasePart") then
                        a2.Position = Vector3.new(a2.Position.X, a2.Position.Y + v17, a2.Position.Z)
                        a2.Anchored = true
                    end
                end
                local v20 = a1:FindFirstChild("Animations")
                if v20 then
                    v20:ClearAllChildren()
                end
            end
            local v21
            if v3.flags.separationToggle then
                v21 = workspace.Towers.ChildAdded:Connect(v18)
            end
            for a1 = 1, v6 do
                v12 = 1
                v14 = Vector3.new(v14.X, v16 + (a1 - 1) * 5, v14.Z)
                v4:InvokeServer(a2[1], a2[2], a2[3], {Rotation = v15, Position = v14}, true)
                task.wait()
                v17 = v17 + 3
            end
            if v21 then
                v21:Disconnect()
            end
            v12 = 0
        end)
        return nil
    end
    return v13(a1, ...)
end)
v2:Section('made by DEVIX7')

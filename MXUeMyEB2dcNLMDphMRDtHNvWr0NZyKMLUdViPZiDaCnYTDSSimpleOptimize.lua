repeat task.wait() until game:IsLoaded()
print("made by devix7", "github.com/devix7")
local Lighting = game:GetService("Lighting")
local function delLight()
    for _, lightobj in pairs(Lighting:GetDescendants()) do
        lightobj:Destroy()
    end
end
local function fullbright()
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.FogEnd = 100000
    Lighting.GlobalShadows = false
    Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
end
if game.PlaceId == 5591597781 then
    repeat
        local map = game:GetService("ReplicatedStorage").State.Map
        task.wait()
    until map and map ~= ""
    task.wait(.5)
    repeat
        task.wait()
    until game:GetService("Workspace"):FindFirstChild("Map")
    game:GetService("Workspace"):FindFirstChild("Map"):Destroy()
    delLight()
    fullbright()
elseif game.PlaceId == 3260590327 then
    local keepObjectNames = {"Center2", "Type", "SpawnLocation", "Elevators", "Terrain", "Camera"}
    local function allKeepObjectsExist()
        for _, objName in ipairs(keepObjectNames) do
            if not game:GetService("Workspace"):FindFirstChild(objName) then
                return false
            end
        end
        if not game:GetService("Players").LocalPlayer.Character then
            return false
        end
        return true
    end
    repeat
        task.wait()
    until allKeepObjectsExist()
    local keepObjects = {
        game:GetService("Workspace").Center2,
        game:GetService("Workspace").Type,
        game:GetService("Workspace").SpawnLocation,
        game:GetService("Workspace").Elevators,
        game:GetService("Workspace").Terrain,
        game:GetService("Workspace").Camera,
        game:GetService("Players").LocalPlayer.Character
    }
    local function shouldKeep(obj)
        for _, keepObj in ipairs(keepObjects) do
            if obj == keepObj then
                return true
            end
        end
        return false
    end
    for _, obj in ipairs(game:GetService("Workspace"):GetChildren()) do
        if not shouldKeep(obj) then
            obj:Destroy()
        end
    end
    delLight()
    fullbright()
end

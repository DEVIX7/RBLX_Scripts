--AutoLobby V2.5
--Script by devix7

repeat
    wait()
until game:IsLoaded()

local plr = game:GetService("Players").LocalPlayer
local gameId = 5591597781
local lobbyId = 3260590327

print("github.com/devix7")

local function tpLobby()
    print("Teleporting to the lobby...")
    wait(1)
    game:GetService("TeleportService"):Teleport(lobbyId)
end

if game.PlaceId == gameId then
    local gameOver = plr.PlayerGui:WaitForChild("RoactGame"):WaitForChild("Rewards"):WaitForChild("content"):WaitForChild("gameOver")

    gameOver:GetPropertyChangedSignal("Visible"):Connect(function()
        if gameOver.Visible then
            tpLobby()
        end
    end)

    game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(element)
        if element.Name == "ErrorPrompt" and element:FindFirstChild("MessageArea") and element.MessageArea:FindFirstChild("ErrorFrame") then
            tpLobby()
        end
    end)

elseif game.PlaceId == lobbyId then
    print("Automatic reconnection after 10 minutes")
    wait(600)
    tpLobby()
end

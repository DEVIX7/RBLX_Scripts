--[[ 
    AutoLobby V2.5 (WebSocket Edition) 
            Script by devix7 
]]--
--[[ WebSocket host: https://github.com/DEVIX7/Auto-vip-server-rejoiner ]]

repeat task.wait() until game:IsLoaded()
local plr = game:GetService("Players").LocalPlayer
print("github.com/DEVIX7")
local function callhost()
    local socket = WebSocket.connect("ws://localhost:8126")
    socket:Send("connect-to-vip-server")
end
if game.PlaceId == 5591597781 then
    print("game")
    local gameOver = plr.PlayerGui:WaitForChild("RoactGame"):WaitForChild("Rewards"):WaitForChild("content"):WaitForChild("gameOver")
    if plr.PlayerGui.GameGui.Hotbar.Stats.Cash.Amount.Text == "$1,337,000" then
            callhost()
    end
    gameOver:GetPropertyChangedSignal("Visible"):Connect(function()
        if gameOver.Visible then
            callhost()
        end
    end)
    game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(element)
        if element.Name == "ErrorPrompt" and element:FindFirstChild("MessageArea") and element.MessageArea:FindFirstChild("ErrorFrame") then
            callhost()
        end
    end)
elseif game.PlaceId == 3260590327 then
    print("lobby")
    print("reconnecting after 200 seconds")
    task.wait(200)
    callhost()
else
    print("incorrect place")
    hint = Instance.new("Hint",game.CoreGui) hint.Text = "ERR , join to correct place" task.wait(7) hint:Destroy()
end

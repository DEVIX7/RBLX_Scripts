repeat task.wait() until game:IsLoaded()
print("> autolobby v2.8 \\ by devix7")
if game.PlaceId == 5591597781 then
    task.spawn(function()
        game.Players.LocalPlayer.PlayerGui.ReactGameRewards.Frame.gameOver:GetPropertyChangedSignal("Visible"):Connect(function()
            if game.Players.LocalPlayer.PlayerGui.ReactGameRewards.Frame.gameOver.Visible == true then
                if game.Players.LocalPlayer.PlayerGui.ReactGameRewards.Frame.gameOver:FindFirstChild("content") and game.Players.LocalPlayer.PlayerGui.ReactGameRewards.Frame.gameOver:FindFirstChild("content").Visible == true then
                    game:GetService("TeleportService"):Teleport(3260590327, game.Players.LocalPlayer)
                end
            end
        end)
    end)
    task.spawn(function()
        game.CoreGui.RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(o)
            if o.Name == "ErrorPrompt" and o:FindFirstChild("MessageArea") and o.MessageArea:FindFirstChild("ErrorFrame") then
                game:GetService("TeleportService"):Teleport(3260590327, game.Players.LocalPlayer)
            end
        end) 
    end)
elseif game.PlaceId == 3260590327 then
    task.spawn(function()
        game.CoreGui.RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(o)
            if o.Name == "ErrorPrompt" and o:FindFirstChild("MessageArea") and o.MessageArea:FindFirstChild("ErrorFrame") then
                game:GetService("TeleportService"):Teleport(3260590327, game.Players.LocalPlayer)
            end
        end) 
    end)
    task.wait(300)
    game:GetService("TeleportService"):Teleport(3260590327, game.Players.LocalPlayer)
end

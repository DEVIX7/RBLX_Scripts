--AutoLobby V2.7
--Script by devix7

repeat task.wait() until game:IsLoaded()
print("\n\t\tgithub.com/devix7\n", "\t\tmade by DEVIX7\n", "\t\tAutoLobby V2.7")

local function tpLobby()
    print("Teleporting to the lobby...")
    task.wait(1)
    game:GetService("TeleportService"):Teleport(3260590327, game:GetService("Players").LocalPlayer)
end

if game.PlaceId == 5591597781 then
    task.spawn(function()
        local gameOver = game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("ReactGame"):WaitForChild("Rewards"):WaitForChild("content"):WaitForChild("gameOver")
        gameOver:GetPropertyChangedSignal("Visible"):Connect(function()
            if gameOver.Visible == true then
                local content = gameOver:FindFirstChild("content")
                if content and content.Visible == true then
                    tpLobby()
                end
            end
        end)
    end)

    task.spawn(function() 
        game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(obj)
            if obj.Name == "ErrorPrompt" and obj:FindFirstChild("MessageArea") and obj.MessageArea:FindFirstChild("ErrorFrame") then
                tpLobby()
            end
        end)
    end)

elseif game.PlaceId == 3260590327 then
    task.spawn(function()
        game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(obj)
            if obj.Name == "ErrorPrompt" and obj:FindFirstChild("MessageArea") and obj.MessageArea:FindFirstChild("ErrorFrame") then
                tpLobby()
            end
        end)
    end)

    task.spawn(function()
        print("Automatic reconnection after 5 minutes")
        task.wait(300)
        tpLobby()
    end)
end

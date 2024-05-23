--[[
  Auto collector tix V1.1
  made by devix7
]]--
local var1 = game:GetService("Players");local var2 = var1.LocalPlayer;local var3 = var2.Character or var2.CharacterAdded:Wait();
local var4 = Instance.new("Hint", game.CoreGui);var4.Text = "made by devix7";task.wait(1);
local function func1()
    local var5
    if game.PlaceId == 5591597781 then
        var5 = workspace.Map.Environment:FindFirstChild("Currency_Tix")
        if not var5 then
            var4.Text = "Tix not found!!!";task.wait(0.5);var4.Text = "Destroying script!!!";task.wait(0.5);var4:Destroy();
            return
        end
        var3:SetPrimaryPartCFrame(var5.CFrame + Vector3.new(0, 5, 0))
    else
        var5 = workspace:WaitForChild("ClassicEventCurrencies")
        local var6 = #var5:GetChildren()
        if var6 == 0 then
            var4.Text = "Tix not found!!!";task.wait(0.5);var4.Text = "Destroying script!!!";task.wait(0.5);var4:Destroy();
            return
        end
        var4.Text = "Tix:" .. var6
        for _, var7 in ipairs(var5:GetChildren()) do
            var3:SetPrimaryPartCFrame(var7.CFrame + Vector3.new(0, 5, 0));task.wait(3);
        end
    end
end
func1()

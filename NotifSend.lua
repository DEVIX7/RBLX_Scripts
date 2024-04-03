if game.CoreGui:FindFirstChild("NotifiUi_devix7") then
	warn("Already loaded gui!")
else
loadstring(game:HttpGet("https://raw.githubusercontent.com/DEVIX7/RBLX_Scripts/master/NotifUI.lua",true))()
end
local UI = game.CoreGui.NotifiUi_devix7
function say(TitleText, MessageText, DelayVis)
	if DelayVis == nil or DelayVis == "" then
		DelayVis = 10
	end
	local Notifications = UI.Notifs:GetChildren()
	--[[for i,v in pairs(Notifications) do
		v:TweenPosition(UDim2.new(0.97, 0, v.Position.Y.Scale - 0.12, 0),"InOut","Quad",0.2,true)
	end]]
	local NewNotification = UI.MainFrame:Clone()
	NewNotification.Parent = UI.Notifs
	NewNotification.Name = tostring(#Notifications + 1)
	NewNotification.Title.Text = TitleText
	NewNotification.Message.Text = MessageText
	NewNotification.Visible = true
	local initialPosition1 = NewNotification.Position
	NewNotification:TweenPosition(UDim2.new(initialPosition1.X.Scale - 0.2, 0, initialPosition1.Y.Scale, 0),"InOut","Quad",0.2,true)
	delay(DelayVis,function()
		local initialPosition2 = NewNotification.Position
		NewNotification:TweenPosition(UDim2.new(initialPosition2.X.Scale + 0.5, 0, initialPosition2.Y.Scale, 0),"InOut","Quad",0.2,true)
		wait(0.2)
		NewNotification:Destroy()
	end)
end
return say

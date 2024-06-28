--[[
Status UI V1
made by devix7
]]
repeat
	task.wait()
until game:IsLoaded()
local oldTime = os.clock()
local gui = Instance.new("ScreenGui")
local main = Instance.new("Frame")
local statusText = Instance.new("TextLabel")
local text2 = Instance.new("TextLabel")
gui.Name = "gui"
gui.Parent = game.CoreGui
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.ScreenInsets = 0
main.Name = "main"
main.Parent = gui
main.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
main.BorderColor3 = Color3.fromRGB(0, 0, 0)
main.BorderSizePixel = 0
main.Position = UDim2.new(0, 0, 0, 0)
main.Size = UDim2.new(1, 0, 1, 0)
main.Transparency = 0
statusText.Name = "statusText"
statusText.Parent = main
statusText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
statusText.BackgroundTransparency = 1.000
statusText.BorderColor3 = Color3.fromRGB(0, 0, 0)
statusText.BorderSizePixel = 0
statusText.Position = UDim2.new(0.25, 0, 0.47, 0)
statusText.Size = UDim2.new(0.5, 0, 0.06, 0)
statusText.Font = Enum.Font.SourceSans
statusText.Text = "Status: none"
statusText.TextColor3 = Color3.fromRGB(255, 255, 255)
statusText.TextSize = 50.000
text2.Name = "text2"
text2.Parent = main
text2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
text2.BackgroundTransparency = 1.000
text2.BorderColor3 = Color3.fromRGB(0, 0, 0)
text2.BorderSizePixel = 0
text2.Position = UDim2.new(0.25, 0, 0.53, 0)
text2.Size = UDim2.new(0.5, 0, 0.06, 0)
text2.Font = Enum.Font.SourceSans
text2.Text = "made by devix7"
text2.TextColor3 = Color3.fromRGB(255, 255, 255)
text2.TextSize = 24.000
task.spawn(function()
	task.wait(1.5)
	local symbols = { "|", "/", "-", "\\" }
	while true do
		for i = 1, #symbols do
			text2.Text = symbols[i]
			task.wait(0.15)
		end
	end
end)
print("Loading time:",os.clock() - oldTime)
print("\nmade by devix7")
function setstatus(...)
	local args = {...}
	local text = table.concat(args, ", ")
	local currentTime = os.date("%H:%M:%S")
	print("[" .. currentTime .. "] Status: " .. text)
	statusText.Text = "Status: " .. text
	if text == "guiend" then
		print("OK. Ui Destroying")
		statusText.Text = "OK. Ui Destroying"
		task.wait(1.5)
		gui:Destroy()
	end
end
return setstatus

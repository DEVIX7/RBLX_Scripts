--[[    clock.lua , made by DEVIX7    ]]
local a1, b2, c3, d4, e5 = Instance.new("ScreenGui"), Instance.new("Frame"), Instance.new("TextLabel"), Instance.new("UICorner"), Instance.new("TextLabel")
local f6 = identifyexecutor and identifyexecutor() or getexecutorname and getexecutorname() or "</>";print("DEVIX7", f6 , os.date("%H:%M:%S"))
local g7 = function(l12) local h8 = "ᚠᚡᚢᚣᚤᚥᚦᚧᚨᚩᚪᚫᚬᚭᚮᚯᚰᚱᚲᚳᚴᚵᚶᚷᚸᚹᚺᚻᚼᚽᚾᚿᛀᛁᛂᛃᛄᛅᛆᛇᛈᛉᛊᛋᛏᛐᛑᛒᛓᛔᛕᛖᛗᛘᛙᛚᛛᛜᛝᛞᛟᛠᛡᛢᛣᛤᛥᛦᛧᛨᛩᛪ᛭ᛮᛯ" local i9 = "" for j10 = 1, l12 do local k11 = math.random(1, #h8) i9 = i9 .. string.sub(h8, k11, k11) end return i9 end
a1.Name = g7(100);a1.Parent = game.CoreGui;a1.ScreenInsets = 3
b2.Name = g7(100);b2.Parent = a1;b2.BackgroundColor3 = Color3.fromRGB(25, 25, 25);b2.BackgroundTransparency = 0.500;b2.BorderSizePixel = 0;b2.Position = UDim2.new(0.865465879, 0, 0, 0);b2.Size = UDim2.new(0, 193, 0, 34)
c3.Name = g7(100);c3.Parent = b2;c3.BackgroundTransparency = 1.000;c3.BorderSizePixel = 0;c3.Position = UDim2.new(0.0703959912, 0, 0.166386545, 0);c3.Size = UDim2.new(0, 105, 0, 22);c3.Font = Enum.Font.SourceSansItalic;c3.Text = "DEVIX7";c3.TextColor3 = Color3.fromRGB(255, 255, 255);c3.TextSize = 17.000;c3.TextXAlignment = Enum.TextXAlignment.Left
d4.CornerRadius = UDim.new(0.300000012, 0);d4.Parent = b2
e5.Name = g7(100);e5.Parent = b2;e5.BackgroundTransparency = 1.000;e5.BorderSizePixel = 0;e5.Position = UDim2.new(0.583349347, 0, 0.166386545, 0);e5.Size = UDim2.new(0, 72, 0, 22);e5.Font = Enum.Font.SourceSans;e5.Text = "00:00:00";e5.TextColor3 = Color3.fromRGB(255, 255, 255);e5.TextSize = 15.000;e5.TextXAlignment = Enum.TextXAlignment.Right
task.wait(0.5);c3.Text = "Loading...";e5.Text = "99:99:99";task.wait(1);c3.Text = f6
task.spawn(function() while true do e5.Text = os.date("%H:%M:%S") task.wait(1) end end)
print("Loading Success!");script:Destroy()
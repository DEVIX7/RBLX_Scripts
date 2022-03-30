_G.coin = true
while _G.coin do
    wait()
for i,v in pairs(workspace["Air Race"]:GetDescendants()) do
if v.Name == "TouchPart" then 
    firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart,v,0)
    wait()
    firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart,v,1)
end
end
end
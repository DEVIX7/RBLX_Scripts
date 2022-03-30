_G.planes = true
local r = 1
while _G.planes do
if r > 14 then
   r = 1
   else
game:GetService("ReplicatedStorage").Packages._Index["sleitnick_knit@1.4.4"].knit.Services.PlaneLootService.RF.PurchaseRoll:InvokeServer(r)
r=r+1
end
end
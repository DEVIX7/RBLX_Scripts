--[[ made by devix7 ; whoaim.lua ; script use UNC format for detect ]]
print("made by devix7")
local whoami = nil
    local name = identifyexecutor() or getexecutorname()
    local lvl = getthreadidentity() or getidentity()
if name and lvl then
whoami = "---\nExecutor: " .. tostring(name) .. "\nLevel: " .. tostring(lvl) .. "\n---"
if whoami ~= nil then
        print(whoami)
        local ui = Instance.new("Message" ,game.CoreGui)
            ui.Text = whoami
            task.wait(3)
            ui:Destroy()
    end
else
    warn("!!! Very low lvl executor or executor can't support UNC format")
end
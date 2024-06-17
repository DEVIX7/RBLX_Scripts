--[[ made by devix7 ; whoiam.lua ; script use UNC format for detect ]]
print("made by devix7")
local whoiam = nil
    local name = identifyexecutor() or getexecutorname()
    local lvl = getthreadidentity() or getidentity()
if name and lvl then
whoiam = "---\nExecutor: " .. tostring(name) .. "\nLevel: " .. tostring(lvl) .. "\n---"
if whoami ~= nil then
        print(whoiam)
        local ui = Instance.new("Message" ,game.CoreGui)
            ui.Text = whoiam
            task.wait(3)
            ui:Destroy()
    end
else
    warn("!!! Very low lvl executor or executor can't support UNC format")
end

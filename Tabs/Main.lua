-- Example GitHub tab
local DX = ... or _G.DXPanel

local Tab, err = DX:CreateTab("Main", "M")
if not Tab then
    error(err or "Cannot create Main tab")
end

Tab:AddSection("MAIN")

Tab:AddButton({
    Title = "Test",
    Content = "Example button",
    Callback = function()
        print("DXPanel Main: Test")
    end,
})

Tab:AddToggle({
    Title = "Test Toggle",
    Content = "Example toggle",
    Default = false,
    Callback = function(value)
        print("DXPanel Main Toggle:", value)
    end,
})

DXPanel Library Package

Loader.lua
  -> Library/DXPanelLib.lua
  -> Library/Overview.lua
  -> auto-scan GitHub Tabs/*.lua
  -> Library/EggESP.lua
  -> Library/Settings.lua

Overview is first.
Settings is last.
Any new .lua placed in Tabs/ is loaded automatically.

Tab contract:
return function(Window)
    local Tab = Window:CreateTab("Main", "M")
    Tab:Section("MAIN")
    Tab:Button("Test", function() end)
    return Tab
end

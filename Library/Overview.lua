-- Library/Overview.lua
-- Overview เป็นระบบพื้นฐานของ Library และโหลดก่อน Tab ภายนอก

return function(Window)
    local Players = game:GetService("Players")
    local Stats = game:GetService("Stats")
    local LocalPlayer = Players.LocalPlayer

    local Tab = Window:CreateTab("Overview", "house")

    Tab:Section("PLAYER")
    Tab:Button("Player: " .. tostring(LocalPlayer.DisplayName or LocalPlayer.Name), function()
        print("Username:", LocalPlayer.Name)
    end)
    Tab:Button("User ID: " .. tostring(LocalPlayer.UserId), function() end)

    Tab:Section("SERVER")
    Tab:Button("Players Online: " .. tostring(#Players:GetPlayers()), function() end)
    Tab:Button("Place ID: " .. tostring(game.PlaceId), function() end)
    Tab:Button("Game ID: " .. tostring(game.GameId), function() end)

    Tab:Section("STATUS")
    Tab:Button("Online", function() end)

    return Tab
end

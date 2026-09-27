-- Tabs/Main.lua
-- ไฟล์นี้สร้างเฉพาะ Main Tab
-- ห้ามสร้าง Window ใหม่ที่นี่

return function(Window, Core)

    local Tab = Window:CreateTab("Main", "M")

    Tab:Section("MAIN")

    Tab:Button("Test", function()
        print("[DXPanel] Main Test OK")

        if Core then
            Core:Notify(
                "DXPanel",
                "Main Tab ทำงานแล้ว",
                3
            )
        end
    end)

    Tab:Toggle("Test Toggle", false, function(value)
        print("[DXPanel] Test Toggle:", value)
    end)

    Tab:Section("TARGET")

    Tab:Dropdown(
        "Target",
        {
            "All",
            "Item A",
            "Item B",
            "Item C",
        },
        "All",
        function(value)
            print("[DXPanel] Target:", value)
        end
    )

end

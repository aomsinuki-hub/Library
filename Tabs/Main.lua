return function(Window, Core)

    local Tab = Window:CreateTab("Main", "M")

    Tab:Section("MAIN")

    Tab:Button("Test", function()
        print("Main Test")

        if Core then
            Core:Notify(
                "DXPanel",
                "Main Tab ทำงานแล้ว",
                3
            )
        end
    end)

    Tab:Toggle("Test Toggle", false, function(value)
        print("Toggle:", value)
    end)

end

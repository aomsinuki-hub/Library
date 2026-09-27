return function(Window, Core)

    local Tab = Window:CreateTab("Main", "M")

    Tab:Button("Test", function()
        print("Main Test")
    end)

    Tab:Toggle("Test Toggle", false, function(value)
        print("Toggle:", value)
    end)

end

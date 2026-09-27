return function(Window, Core)

    local Tab = Window:CreateTab("Farm", "F")

    Tab:Button("Start Farm", function()
        print("Start Farm")
    end)

    Tab:Toggle("Auto Farm", false, function(value)
        print("Auto Farm:", value)
    end)

end

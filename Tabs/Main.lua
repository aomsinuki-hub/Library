return function(Window, Library)

    local Tab = Window:Tab({
        Title = "Main",
        Icon = "home"
    })

    Tab:Button({
        Title = "Test",
        Content = "Test Button",
        Callback = function()
            print("Main Test")
        end
    })

    Tab:Toggle({
        Title = "Test Toggle",
        Callback = function(value)
            print("Toggle:", value)
        end
    })

end

return function(Window)
 local Tab=Window:CreateTab("Settings","S")
 Tab:Section("SETTINGS")
 Tab:Button("Delete GUI",function() Window:Destroy() end)
end
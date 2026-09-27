return function(Window)
 local Tab=Window:CreateTab("ESP","P")
 Tab:Section("ESP")
 Tab:Toggle("ESP",false,function(state) end)
end
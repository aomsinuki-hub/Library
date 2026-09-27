return function(Window)
 local Tab=Window:CreateTab("Egg ESP","E")
 Tab:Section("PLOT EGG ESP")
 Tab:Toggle("Plot Egg ESP",false,function(state) end)
 Tab:Slider("Distance",50,2000,500,function(value) end)
end
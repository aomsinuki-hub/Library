local HttpService=game:GetService("HttpService")
local BASE="https://raw.githubusercontent.com/aomsinuki-hub/Library/refs/heads/main/"
local API="https://api.github.com/repos/aomsinuki-hub/Library/contents/Taps?ref=main"

local function get(url)
 local ok,r=pcall(function() return game:HttpGet(url) end)
 if not ok then warn("[DXPanel] GET failed",url,r) return nil end
 return r
end

local function load(url)
 local s=get(url); if not s then return nil end
 local ok,f=pcall(loadstring,s)
 if not ok or type(f)~="function" then warn("[DXPanel] compile failed",url,f) return nil end
 local ran,r=pcall(f)
 if not ran then warn("[DXPanel] runtime failed",url,r) return nil end
 return r
end

local Lib=load(BASE.."DXPanelLib.lua")
if type(Lib)~="table" or type(Lib.CreateWindow)~="function" then error("[DXPanel] Invalid DXPanelLib") end
local Window=Lib:CreateWindow({Title="DX Panel"})

local raw=get(API)
if not raw then error("[DXPanel] Cannot scan Taps") end
local ok,files=pcall(function() return HttpService:JSONDecode(raw) end)
if not ok or type(files)~="table" then error("[DXPanel] Invalid GitHub API response") end

local names={}
for _,f in ipairs(files) do
 if f.type=="file" and type(f.name)=="string" and f.name:sub(-4):lower()==".lua" then
  table.insert(names,f.name)
 end
end

local function rank(n)
 if n=="Overview.lua" then return 0 end
 if n=="Settings.lua" then return 999999 end
 return 100
end

table.sort(names,function(a,b)
 local ra,rb=rank(a),rank(b)
 if ra~=rb then return ra<rb end
 return a:lower()<b:lower()
end)

for _,name in ipairs(names) do
 local mod=load(BASE.."Taps/"..name)
 if type(mod)=="function" then
  local success,err=pcall(function() mod(Window) end)
  if not success then warn("[DXPanel] Tap error",name,err) end
 end
end

print("[DXPanel] Auto Scan:",#names,"Taps")

local Hub = getgenv().BFHub
print("Hub type:", type(Hub))
print("Window type:", type(Hub and Hub.Window))

if Hub and Hub.Window then
    local methods = {}
    for k, v in pairs(Hub.Window) do
        if type(v) == "function" then
            table.insert(methods, k)
        end
    end
    table.sort(methods)
    print("Window methods:")
    for _, m in ipairs(methods) do
        print("  " .. m)
    end
end

local pg = game.Players.LocalPlayer.PlayerGui
local found = 0
for _, c in ipairs(pg:GetDescendants()) do
    if c:IsA("ScreenGui") then
        local n = c.Name:lower()
        if string.find(n, "wind") or string.find(n, "hub") or string.find(n, "library") then
            found = found + 1
            print("FOUND ScreenGui:", c:GetFullName(), "enabled=", tostring(c.Enabled))
        end
    end
end
print("WindUI ScreenGuis found:", found)

local iris = pg:FindFirstChild("Iris_Root")
if iris then
    print("Iris_Root children:")
    for _, c in ipairs(iris:GetChildren()) do
        print("  " .. c.Name .. " [" .. c.ClassName .. "]")
    end
else
    print("Iris_Root: not found")
end

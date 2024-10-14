-- Settings for pressing the F key near stage_3 objects
local distanceThreshold = 5  -- The distance within which the "F" key will be pressed
local keyToPress = Enum.KeyCode.F  -- The key to press (F key)

-- Services
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Create a table to keep track of objects we've already labeled
local labeledObjects = {}

-- List of object names to track
local targetObjects = {"carrot", "iron", "diamond", "emerald", "bee", "egg", "pumpkin", "stage_3", "watermelon"}

-- Function to create ESP for a given object
local function createESPForObject(object, labelName)
    if labeledObjects[object] then return end  -- If this object is already labeled, skip it

    local espLabel = Instance.new("BillboardGui")
    espLabel.Size = UDim2.new(1, 0, 1, 0)
    espLabel.Adornee = object
    espLabel.AlwaysOnTop = true
    espLabel.Parent = object

    -- Check if the object is "stage_3" for custom display
    if labelName == "stage_3" then
        local greenCircle = Instance.new("Frame", espLabel)
        greenCircle.Size = UDim2.new(2, 0, 2, 0)  -- Increase size for visibility
        greenCircle.BackgroundColor3 = Color3.new(0, 1, 0)  -- Green color
        greenCircle.BackgroundTransparency = 0.3  -- Slight transparency
        greenCircle.AnchorPoint = Vector2.new(0.5, 0.5)  -- Center the circle
        greenCircle.Position = UDim2.new(0.5, 0, 0.5, 0)  -- Place it in the center

        local circleCorner = Instance.new("UICorner", greenCircle)  -- Make the frame circular
        circleCorner.CornerRadius = UDim.new(1, 0)
    else
        -- Standard ESP text label for other objects
        local label = Instance.new("TextLabel", espLabel)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.new(1, 1, 1)  -- White text for visibility
        label.TextScaled = true
        label.Text = labelName  -- Label with the object name
    end

    -- Mark this object as labeled
    labeledObjects[object] = true
end

-- Function to check the distance and press "F" if close enough
local function checkDistanceAndPressKey()
    for _, obj in pairs(game.Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "stage_3" then
            local distance = (obj.Position - humanoidRootPart.Position).Magnitude
            if distance <= distanceThreshold then
                -- Simulate pressing the "F" key
                game:GetService("VirtualInputManager"):SendKeyEvent(true, keyToPress, false, game)
                game:GetService("VirtualInputManager"):SendKeyEvent(false, keyToPress, false, game)
                print("Pressed F near stage_3 object")
                wait(2)  -- Small delay to avoid spamming
            end
        end
    end
end

-- Function to check for new target objects in the workspace
local function checkForNewObjects()
    for _, obj in pairs(game.Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            for _, targetName in ipairs(targetObjects) do
                if string.find(obj.Name:lower(), targetName) then
                    createESPForObject(obj, targetName)  -- Label it with the object name
                end
            end
        end
    end
end

-- Main loop to continuously check for new objects and press F near stage_3 objects
while true do
    checkForNewObjects()  -- Check the workspace for new target objects
    checkDistanceAndPressKey()  -- Check the distance for pressing F near stage_3 objects
    wait(1)  -- Wait for 1 second before checking again to avoid performance issues
end

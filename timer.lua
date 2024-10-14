-- Services
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer

-- Create a table to keep track of the stage_2 objects and their active timers
local stage2Timers = {}

-- Create the UI elements
local screenGui
local timerFrame
local beepSound

local function createUI()
    -- Check if the ScreenGui already exists, if so, destroy it to avoid duplicates
    if screenGui then
        screenGui:Destroy()
    end
    
    -- Create the UI elements
    screenGui = Instance.new("ScreenGui")
    screenGui.Parent = localPlayer:WaitForChild("PlayerGui")  -- Parent the ScreenGui to PlayerGui

    timerFrame = Instance.new("Frame")
    timerFrame.Size = UDim2.new(0.2, 0, 0.5, 0)  -- Adjust size and position as needed
    timerFrame.Position = UDim2.new(0.8, 0, 0.25, 0)
    timerFrame.BackgroundTransparency = 0.5
    timerFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    timerFrame.Visible = true  -- Initially visible
    timerFrame.Parent = screenGui

    local timerList = Instance.new("UIListLayout")
    timerList.Parent = timerFrame

    -- Create a sound effect for when a timer finishes
    beepSound = Instance.new("Sound")
    beepSound.SoundId = "rbxassetid://911342077"  -- You can replace this with any sound asset ID
    beepSound.Volume = 1
    beepSound.Parent = screenGui  -- Attach sound to the ScreenGui so it's audible to the player
end

-- Function to restart the script
local function restartScript()
    -- Clear all current timers and UI elements
    for object, _ in pairs(stage2Timers) do
        stage2Timers[object] = nil
    end
    timerFrame:ClearAllChildren()
    local timerList = Instance.new("UIListLayout")
    timerList.Parent = timerFrame  -- Reattach the layout after clearing the frame
end

-- Function to toggle the UI visibility with Right Alt key
local uiVisible = true
local function toggleUI()
    uiVisible = not uiVisible
    timerFrame.Visible = uiVisible
end

-- Detect holding the Right Alt key for 3 seconds to restart the script
local rightAltHeld = false
local holdTime = 0

userInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightAlt then
        rightAltHeld = true
        holdTime = 0
    end
end)

userInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightAlt then
        rightAltHeld = false
    end
end)

runService.Heartbeat:Connect(function(dt)
    if rightAltHeld then
        holdTime = holdTime + dt
        if holdTime >= 3 then
            restartScript()  -- Restart the script if held for 3 seconds
            rightAltHeld = false
        end
    end
end)

-- Function to create and update the timer on a specific stage_2 object
local function createTimerESP(object, duration)
    -- If the timer for this stage_2 object is already active, skip it
    if stage2Timers[object] then return end

    -- Create a BillboardGui to display the timer in the world
    local espLabel = Instance.new("BillboardGui")
    espLabel.Size = UDim2.new(1, 0, 1, 0)
    espLabel.Adornee = object
    espLabel.AlwaysOnTop = true
    espLabel.Parent = object

    local timerText = Instance.new("TextLabel", espLabel)
    timerText.Size = UDim2.new(1, 0, 1, 0)
    timerText.BackgroundTransparency = 1
    timerText.TextColor3 = Color3.new(0, 0, 0)  -- Black text for visibility
    timerText.TextScaled = true
    timerText.Text = tostring(duration) .. "s"  -- Set initial timer text

    -- Get the name of the parent for display in the UI
    local parentName = object.Parent and object.Parent.Name or "Unknown Parent"

    -- Create a text label in the UI to display the timer
    local uiTimerLabel = Instance.new("TextLabel")
    uiTimerLabel.Size = UDim2.new(1, 0, 0, 20)
    uiTimerLabel.BackgroundTransparency = 1
    uiTimerLabel.TextColor3 = Color3.new(1, 1, 1)  -- White text in UI
    uiTimerLabel.TextScaled = true
    uiTimerLabel.Text = parentName .. ": " .. tostring(duration) .. "s"  -- Display the parent name and timer
    uiTimerLabel.Parent = timerFrame

    -- Keep track of the remaining time for this specific stage_2 object
    local remainingTime = duration
    stage2Timers[object] = true  -- Mark the timer as active

    -- Function to update the timer
    local function updateTimer(dt)
        remainingTime = remainingTime - dt  -- Decrease remaining time by delta time
        if remainingTime <= 0 then
            espLabel:Destroy()  -- Remove the ESP when the timer reaches 0
            uiTimerLabel:Destroy()  -- Remove the UI timer when finished
            stage2Timers[object] = nil  -- Clear the timer from the table
            beepSound:Play()  -- Play beep sound when timer reaches 0
        else
            local timeText = tostring(math.ceil(remainingTime)) .. "s"
            timerText.Text = timeText  -- Update the world timer display
            uiTimerLabel.Text = parentName .. ": " .. timeText  -- Update the UI timer display
        end
    end

    -- Connect the update function to RunService's Heartbeat
    local connection
    connection = runService.Heartbeat:Connect(function(dt)
        if remainingTime > 0 then
            updateTimer(dt)
        else
            connection:Disconnect()  -- Stop updating once the timer is finished
        end
    end)
end

-- Function to detect new stage_2 objects in the workspace
local function checkForStage2Objects()
    for _, obj in pairs(game.Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "stage_2" then
            -- Start a 60-second timer on the detected stage_2 object if not already done
            createTimerESP(obj, 55)
        end
    end
end

-- Main loop to continuously check for new stage_2 objects
local function mainLoop()
    while true do
        checkForStage2Objects()
        wait(1)  -- Wait 1 second before checking again to avoid performance issues
    end
end

-- Event listener to recreate the UI when the character respawns
local function onCharacterAdded()
    createUI()
    mainLoop()
end

-- Set up the script to recreate the UI and re-run the logic when the player respawns
localPlayer.CharacterAdded:Connect(onCharacterAdded)

-- Initial setup
if localPlayer.Character then
    onCharacterAdded()
end

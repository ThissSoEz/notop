-- Define the distance threshold (in studs)
local distanceThreshold = 10

-- Reference to the Carpet part
local carpet = workspace:GetChildren()[17].Carpet

-- Function to calculate the distance between a part and a player
local function getDistance(part, player)
    local partPosition = part.Position
    local playerCharacter = player.Character
    local playerPosition = playerCharacter and playerCharacter.PrimaryPart and playerCharacter.PrimaryPart.Position
    if not playerPosition then
        return math.huge
    end
    return (partPosition - playerPosition).magnitude
end

-- Function to send a custom message to the server
local function sendCustomMessage(message)
    local args = {
        [1] = "Update",
        [2] = {
            ["DescriptionText"] = message,
            ["ImageId"] = 0
        }
    }

    game:GetService("ReplicatedStorage"):WaitForChild("CustomiseBooth"):FireServer(unpack(args))
end

-- Function to refresh the player detection
local function refreshDetection()
    -- Clear previous player detections
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("TextLabel") and obj.Name == "PlayerDetection" then
            obj:Destroy()
        end
    end

    -- Get a list of all players in the game
    local players = game.Players:GetPlayers()

    -- Iterate over each player
    for _, player in ipairs(players) do
        -- Calculate the distance between the Carpet and the player
        local distance = getDistance(carpet, player)

        -- Check if the distance is within the threshold
        if distance <= distanceThreshold then
            -- Send a custom message to the server with the player name
            sendCustomMessage("Player detected: " .. player.Name)
        end
    end
end

-- Main loop to continuously refresh the player detection
while wait(1) do
    refreshDetection()
end

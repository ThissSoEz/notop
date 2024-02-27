-- Function to encode a string using base64
local function base64_encode(str)
    return fluxus.crypt.base64.encode(str)
end

-- Function to decode a base64 encoded string
local function base64_decode(str)
    return fluxus.crypt.base64.decode(str)
end

-- Define the encoded API key
local encodedApiKey = "c2stYU1rUGFoN29TaUx5ODlXQnJXVzdUM0Jsa2ZKaXo2ZU1GcGtyY3JTU0N5b29FcnNzQ3lvb0V6Yw=="

-- Decode the API key
local apiKey = base64_decode(encodedApiKey)

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
    print("Sending message:", message) -- Debugging
    local args = {
        [1] = "Update",
        [2] = {
            ["DescriptionText"] = message,
            ["ImageId"] = 0
        }
    }

    game:GetService("ReplicatedStorage"):WaitForChild("CustomiseBooth"):FireServer(unpack(args))
end

-- Function to generate a roast using OpenAI
local function generateRoast(playerName)
    -- Debugging
    print("Generating roast for player:", playerName)

    -- Define the request body
    local body = {
        model = "gpt-3.5-turbo",
        messages = {
            {
                role = "system",
                content = "You are Marv, a chatbot that reluctantly answers questions with sarcastic responses."
            },
            {
                role = "user",
                content = "Roast " .. playerName
            }
        },
        temperature = 0.5,
        max_tokens = 256,
        top_p = 1,
        frequency_penalty = 0,
        presence_penalty = 0
    }

    -- Encode the body to JSON
    local HttpService = game:GetService("HttpService")
    local bodyJson = HttpService:JSONEncode(body)

    -- Define the headers with the API key
    local headers = {
        ["Content-Type"] = "application/json",
        ["Authorization"] = "Bearer " .. apiKey
    }

    -- Send the request and store the response
    local response = request({
        Url = "https://api.openai.com/v1/chat/completions",
        Method = "POST",
        Headers = headers,
        Body = bodyJson
    })

    -- Decode the response content from JSON
    local responseData = HttpService:JSONDecode(response.Body)

    -- Access the choices array in the response
    local choices = responseData.choices

    -- Extract and return the content of the first message
    if choices[1] then
        local roastMessage = choices[1].message.content
        print("Generated roast:", roastMessage) -- Debugging
        return roastMessage
    else
        print("Failed to generate roast.") -- Debugging
        return "Failed to generate roast."
    end
end

-- Function to refresh the player detection
local function refreshDetection()
    -- Debugging
    print("Refreshing player detection...")

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
            -- Generate a roast for the player
            local roastMessage = generateRoast(player.Name)
            -- Send the roast message to the server
            sendCustomMessage(roastMessage)
        end
    end
end

-- Main loop to continuously refresh the player detection
while wait(1) do
    refreshDetection()
end

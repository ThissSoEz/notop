-- Function to roast a player
local function roastPlayer(playerName)
    -- Define the request body
    local body = {
        model = "gpt-3.5-turbo",
        messages = {
            {
                role = "system",
                content = "You are a roast AI, ready to burn with sarcasm."
            },
            {
                role = "user",
                content = "Roast " .. playerName  -- Roast the specific player
            }
        },
        temperature = 0.7,  -- Adjusted for more varied responses
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
        ["Authorization"] = "Bearer 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"
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

    -- Construct the roast message
    local roastMessage = ""
    for _, choice in ipairs(choices) do
        roastMessage = roastMessage .. choice.message.content .. " "
    end

    -- Send the roast message to the chat
    game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(roastMessage, "All")
end

-- Track the time of the last roast
local lastRoastTime = 0

-- Function to roast players within the cooldown limit
local function roastPlayersWithCooldown()
    -- Check if enough time has passed since the last roast
    if tick() - lastRoastTime >= 60 then
        -- Reset the cooldown timer
        lastRoastTime = tick()
        
        -- Roast up to 3 players
        local players = game.Players:GetPlayers()
        for i, player in ipairs(players) do
            roastPlayer(player.Name)
            if i >= 3 then
                break
            end
        end
    end
end

-- Roast players with cooldown every frame
game:GetService("RunService").Heartbeat:Connect(function()
    roastPlayersWithCooldown()
end)

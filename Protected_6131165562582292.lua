-- Function to roast a random player in the game, excluding yourself
local function roastRandomPlayer()
    -- Get all players in the game
    local players = game:GetService("Players"):GetPlayers()
    
    -- Remove yourself from the list of players
    local player = game:GetService("Players").LocalPlayer
    for i, p in ipairs(players) do
        if p == player then
            table.remove(players, i)
            break
        end
    end
    
    -- Select a random player from the remaining list
    local randomIndex = math.random(1, #players)
    local randomPlayer = players[randomIndex]

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
                content = "Roast " .. randomPlayer.Name  -- Roast the random player
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

-- Example usage: roast a random player in the game
roastRandomPlayer()

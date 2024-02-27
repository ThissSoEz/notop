-- Function to roast a random player, excluding yourself
local function roastRandomPlayer()
    -- Get the local player
    local player = game.Players.LocalPlayer

    -- Get all players in the game
    local players = game.Players:GetPlayers()

    -- Remove the local player from the list
    for i, p in ipairs(players) do
        if p == player then
            table.remove(players, i)
            break
        end
    end

    -- Choose a random player from the remaining list
    local randomPlayer = players[math.random(1, #players)]

    -- Roast the random player
    roastPlayer(randomPlayer.Name)
end

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

-- Example usage: roast a random player, excluding yourself
roastRandomPlayer()

-- Define a function to get a random player's name
local function getRandomPlayerName()
    local players = game.Players:GetPlayers()
    if #players > 0 then
        local randomIndex = math.random(1, #players)
        return players[randomIndex].Name
    else
        return "Player"  -- Default name if no players are found
    end
end

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
            content = "Roast " .. getRandomPlayerName()
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
local function roastRandomPlayer()
    local response = request({
        Url = "https://api.openai.com/v1/chat/completions",
        Method = "POST",
        Headers = headers,
        Body = bodyJson
    })

    -- Decode the response content from JSON
    local responseData = HttpService:JSONDecode(response.Body)

    -- Check if the choices array exists and is not empty
    if responseData.choices and #responseData.choices > 0 then
        -- Access the choices array in the response
        local choices = responseData.choices

        -- Get the roasted message
        local roastedMessage = choices[1].message.content

        -- Send the roasted message in the game chat
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(roastedMessage, "All")
    else
        warn("No response choices received from the OpenAI API.")
    end
end

roastRandomPlayer() -- Call the function to roast a random player

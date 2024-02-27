-- Simple encoding and decoding system using a substitution cipher
local function encodeApiKey(apiKey)
    local encodedKey = ""
    for i = 1, #apiKey do
        local charCode = string.byte(apiKey, i)
        encodedKey = encodedKey .. string.char(charCode + 1)
    end
    return encodedKey
end

local function decodeApiKey(encodedKey)
    local decodedKey = ""
    for i = 1, #encodedKey do
        local charCode = string.byte(encodedKey, i)
        decodedKey = decodedKey .. string.char(charCode - 1)
    end
    return decodedKey
end

-- Define the encoded API key
local encodedApiKey = "tl-UQckxphjM"

-- Decode the API key
local apiKey = decodeApiKey(encodedApiKey)

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
        ["Authorization"] = "Bearer " .. apiKey
    }

    -- Send the request and store the response
    local success, response = pcall(function()
        return request({
            Url = "https://api.openai.com/v1/chat/completions",
            Method = "POST",
            Headers = headers,
            Body = bodyJson
        })
    end)

    if success then
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
    else
        warn("Error roasting player:", response)
    end
end

-- Roast all players in the game
local players = game:GetService("Players"):GetPlayers()
for _, player in ipairs(players) do
    roastPlayer(player.Name)
end

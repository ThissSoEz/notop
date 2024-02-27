-- Encoding and decoding functions
local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

function encodeBase64(input)
    local encoded = ''
    for i = 1, #input, 3 do
        local byte1, byte2, byte3 = string.byte(input, i, i + 2)
        local char1 = byte1 >> 2
        local char2 = ((byte1 & 0x03) << 4) | (byte2 >> 4)
        local char3 = ((byte2 & 0x0F) << 2) | (byte3 >> 6)
        local char4 = byte3 & 0x3F

        encoded = encoded ..
                  b:sub(char1 + 1, char1 + 1) ..
                  b:sub(char2 + 1, char2 + 1) ..
                  (byte2 and b:sub(char3 + 1, char3 + 1) or '=') ..
                  (byte3 and b:sub(char4 + 1, char4 + 1) or '=')
    end
    return encoded
end

function decodeBase64(input)
    local decoded = ''
    input = input:gsub('[^' .. b .. '=]', '')

    for i = 1, #input, 4 do
        local block = input:sub(i, i + 3)
        local char1, char2, char3, char4 = block:match('(.)(.)(.)(.)')

        local byte1 = (b:find(char1) - 1) << 2 | (b:find(char2) - 1) >> 4
        local byte2 = ((b:find(char2) - 1) & 0x0F) << 4 | ((b:find(char3) or 0) - 1) >> 2
        local byte3 = ((b:find(char3) or 0) & 0x03) << 6 | ((b:find(char4) or 0) - 1)

        decoded = decoded .. string.char(byte1)
        if char3 ~= '=' then decoded = decoded .. string.char(byte2) end
        if char4 ~= '=' then decoded = decoded .. string.char(byte3) end
    end

    return decoded
end

-- Example usage
local originalString = "Hello, World!"
print("Original String:", originalString)

local encodedString = encodeBase64(originalString)
print("Encoded String:", encodedString)

local decodedString = decodeBase64(encodedString)
print("Decoded String:", decodedString)

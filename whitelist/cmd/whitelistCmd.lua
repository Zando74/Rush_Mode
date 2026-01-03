SLASH_RUSHINVITE1 = "/rconnect"
SlashCmdList["RUSHINVITE"] = function(msg)
    if msg == "" then
        print("Usage: /rconnect <playerName>")
        return
    end
    local playerName = strtrim(msg)
    RushMode:ShareWhitelist(playerName)
    print(L["PLAYER_INVITED"]:format(playerName))
end
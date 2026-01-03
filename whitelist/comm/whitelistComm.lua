function RushMode:ShareWhitelist(to)
    if RushModeDB.rushID == "" then
        return
    end
    local msg = "WL:-" .. RushModeDB.rushID .. "$"
    local players = {}
    for playerName, whitelisted in pairs(RushModeDB.whitelist) do
        if whitelisted then
            table.insert(players, playerName)
        end
    end
    if #players <= 10 then
        for _, playerName in ipairs(players) do
            msg = msg .. playerName .. "%"
        end
    else
        for i = 1, 10 do
            local index = math.random(#players)
            msg = msg .. players[index] .. "%"
            table.remove(players, index)
        end
    end
    Comm:SendWhisperMessage(Comm.prefixTracking, msg, to)
end

function RushMode:OnWhitelistReceived(sender, msg)
    local rushID, playerNames = strsplit("$", msg)
    local newPlayerWhitelisted = false
    if rushID ~= RushModeDB.rushID then
        return
    end
    for _, playerName in ipairs({ strsplit("%", playerNames) }) do
        if playerName ~= "" then
            if not RushModeDB.whitelist[playerName] then
                newPlayerWhitelisted = true
                RushModeDB.whitelist[playerName] = true
            end
        end
    end
    UpdateSyncStatus()
    if not newPlayerWhitelisted then return end
    RushMode:ShareWhitelist(sender)
end
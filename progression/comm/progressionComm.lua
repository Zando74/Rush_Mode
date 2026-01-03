function RushMode:SendProgressionUpdate(achievKey)
    local participant = RushModeDB.player
    local now = time()
    if time() - Comm.lastGuildProgressionMessage < 60 then
        Comm:SendGuildMessage(Comm.prefixProgression, "SD:-" .. participant .. "$" .. achievKey .. "$" .. now)
    else
        Comm:SendWhisperMessage(Comm.prefixProgression, "SD:-" .. participant .. "$" .. achievKey .. "$" .. now, RushMode:RandomOnlineWhitelistedPlayer())
    end
end

function RushMode:OnProgressionUpdateReceived(msg)
    local participant, achievKey, at = strsplit("$", msg)
    if not participant or not achievKey or not at then
        return
    end
    if not RushModeDB.progressionEvents then
        RushModeDB.progressionEvents = {}
    end
    if not RushModeDB.progressionEvents[participant] then
        RushModeDB.progressionEvents[participant] = {}
    end
    if not RushModeDB.progressionEvents[participant][achievKey] then
        RushModeDB.progressionEvents[participant][achievKey] = at
    end
    RushMode.TopScreenAlert:ShowAlert(participant .. " " .. L[achievKey], "Interface\\Icons\\achievement_dungeon_gloryoftheraider", 4146)
end

function RushMode:OnProgressionUpdateWhisperReceived(msg)
    if time() - Comm.lastGuildProgressionMessage < 60 then
        Comm:SendGuildMessage(Comm.prefixProgression, "SD:-" .. msg)
    end
end

function RushMode:ShareProgressionOfARandomPlayer()
    local ids = {}
    for playerName, progressionEvents in pairs(RushModeDB.progressionEvents) do
        if progressionEvents then
            for _, data in pairs(progressionEvents) do
                table.insert(ids, playerName)
            end
        end
    end
    if #ids == 0 then
        return
    end
    local randomPlayerName = ids[math.random(#ids)]
    local progressionEvents = RushModeDB.progressionEvents[randomPlayerName]
    Comm:SendGuildMessage(Comm.prefixProgression, {[randomPlayerName] = progressionEvents})

end
    
function RushMode:OnProgressionSharedReceived(message)
    for playerName, progressionEvents in pairs(message) do
        for achievKey, at in pairs(progressionEvents) do
            if not RushModeDB.progressionEvents then
                RushModeDB.progressionEvents = {}
            end
            if not RushModeDB.progressionEvents[playerName] then
                RushModeDB.progressionEvents[playerName] = {}
            end
            if not RushModeDB.progressionEvents[playerName][achievKey] then
                RushModeDB.progressionEvents[playerName][achievKey] = at
            elseif at < RushModeDB.progressionEvents[playerName][achievKey] then
                RushModeDB.progressionEvents[playerName][achievKey] = at
            end
        end
    end
end
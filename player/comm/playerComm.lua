function RushMode:SendStatusUpdate()
    local name = UnitName("player")
    local level = UnitLevel("player")
    local classID = select(3, UnitClass("player")) 
    local isDead = UnitIsDeadOrGhost("player") and 1 or 0
    local _, _, playerId = strsplit("-", UnitGUID("player"))
    local mapID = C_Map.GetBestMapForUnit("player") or 0
    local now = time()

    local profs = RushMode:GetPlayerProfessionsClassic()
    local profStr = table.concat(profs, ",")

    local copper = GetMoney()

    local items = {}
    for slot = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do
        local itemID = GetInventoryItemID("player", slot)
        if itemID then
            table.insert(items, itemID)
        end
    end

    local itemStr = table.concat(items, ",")

    local msg = string.format(
        "%s$%s$%s$%s$%d$%d$%d$%s$%s$%s$%d$%d",
        RushModeDB.team,
        RushModeDB.player,
        playerId,
        name,
        level,
        classID,
        isDead,
        profStr,
        copper,
        itemStr,
        mapID,
        now
    )

    local randomDisconnected = RushMode:GetRandomOfflinePlayer()
    if time() - Comm.lastGuildProgressionMessage < 60 then
        Comm:SendGuildMessage(Comm.prefixTracking, msg .. "%" .. randomDisconnected)
    else
        Comm:SendWhisperMessage(Comm.prefixTracking, "REC:-" .. msg .. "%" .. randomDisconnected, RushMode:RandomOnlineWhitelistedPlayer())
    end
end

function RushMode:GetRandomOfflinePlayer()
    local keys = {}
    for playerId, data in pairs(RushModeDB.players) do
        if data.lastUpdate < time() - 60 then
            table.insert(keys, playerId)
        end
    end

    if #keys == 0 then return "" end

    local randomId = keys[math.random(#keys)]
    local data = RushModeDB.players[randomId]


    local totalGold = 0
    local g,s,c = (data.money or "0g 0s 0c"):match("(%d+)g%s*(%d+)s%s*(%d+)c")
    g = tonumber(g) or 0
    s = tonumber(s) or 0
    c = tonumber(c) or 0
    totalGold = totalGold + g*10000 + s*100 + c

    local msg = string.format(
        "%s$%s$%s$%s$%d$%d$%d$%s$%s$%s$%d$%d",
        data.team,
        data.player,
        data.playerId,
        data.name,
        data.level,
        data.class,
        data.isDead,
        data.professions,
        totalGold,
        data.items,
        data.mapID,
        data.lastUpdate
    )

    return msg
end


function RushMode:OnPlayerStatusUpdateReceived(msg)
    local newStatus, randomDisconnected = strsplit("%", msg)
    RushMode:processMessage(newStatus)
    if randomDisconnected and randomDisconnected ~= "" then
        RushMode:processMessage(randomDisconnected)
    end
end

function RushMode:OnPlayerStatusWhisperReceived(msg)
    RushMode:OnPlayerStatusUpdateReceived(msg)
    if time() - Comm.lastGuildProgressionMessage < 60 then
        Comm:SendGuildMessage(Comm.prefixTracking, msg)
    end
end

function RushMode:processMessage(message)
    local team, player, playerId, name, level, classId, isDead, profStr, copper, itemStr, mapID, now = strsplit("$", message)

    local existing = RushModeDB.players[playerId]
    if existing and existing.lastUpdate >= tonumber(now) then return end

    local gold = math.floor(copper / 10000)
    local silver = math.floor((copper / 100) % 100)
    local c = copper % 100
    local moneyStr = gold.."g "..silver.."s "..c.."c"

    local data = {
        playerId = playerId,
        team = team,
        player = player,
        name = name,
        level = tonumber(level),
        class = tonumber(classId),
        isDead = tonumber(isDead),
        money = moneyStr,
        items = itemStr,
        mapID = tonumber(mapID),
        professions = profStr,
        lastUpdate = tonumber(now),
    }
    if RushModeDB.players[playerId] == nil then
        data.firstSeen = tonumber(now)
    else
        data.firstSeen = RushModeDB.players[playerId].firstSeen
    end
    RushModeDB.players[playerId] = data
    UpdateUI()
end
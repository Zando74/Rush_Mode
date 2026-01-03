function RushMode:GetPlayerProfessionsClassic()
    local professions = {}

    local numSkills = GetNumSkillLines()
    for i = 1, numSkills do
        local skillName, isHeader, isExpanded, skillRank, maxRank, _, _, skillID = GetSkillLineInfo(i)
        if not isHeader and skillRank and skillRank > 0 then
            for spellID, _ in pairs(MAIN_PROFESSIONS_IDS) do
                local name = GetSpellInfo(spellID)
                if name == skillName then
                    table.insert(professions, MAIN_PROFESSIONS_IDS[spellID] .. ":" .. skillRank)
                end
            end
        end
    end

    return professions
end

local function isNotSameLevel(skillName, skillRank)
    local _, _, playerId = strsplit("-", UnitGUID("player"))
    return RushModeDB.professionsSnapshot[playerId][skillName] ~= skillRank
end

function RushMode:CheckProfessionProgression()
    local numSkills = GetNumSkillLines()
    for i = 1, numSkills do
        local skillName, isHeader, isExpanded, skillRank, maxRank, _, _, skillID = GetSkillLineInfo(i)
        if not isHeader and skillRank and skillRank > 0 then    
            for spellID, _ in pairs(MAIN_PROFESSIONS_IDS) do
                local name = GetSpellInfo(spellID)
                if name == skillName then
                    local _, _, playerId = strsplit("-", UnitGUID("player"))
                    if not RushModeDB.professionsSnapshot[playerId] then 
                        RushModeDB.professionsSnapshot[playerId] = {}
                    end
                    if ProgressionEnum["professions"][tonumber(skillRank)] ~= nil and isNotSameLevel(skillName, skillRank) then
                        RushMode:SendProgressionUpdate(ProgressionEnum["professions"][tonumber(skillRank)])
                        RushModeDB.professionsSnapshot[playerId][skillName] = tonumber(skillRank)
                    end
                end
            end
        end
    end
end

MAIN_PROFESSIONS_IDS = {
    [2259] = 2, -- Alchemy
    [2018] = 12, -- Blacksmithing
    [7411] = 9, -- Enchanting
    [4036] = 5, -- Engineering
    [2108] = 4, -- Leatherworking
    [3908] = 10, -- Tailoring
    [2575] = 11, -- Mining
    [2366] = 3, -- Herbalism
    [8613] = 1, -- Skinning
}

RUSH_CLASS_COLORS = {
    [1] = { colorStr = "ffc79c6e" },
    [2] = { colorStr = "fff58cba" },
    [3] = { colorStr = "ffa9d271" },
    [4] = { colorStr = "fffff569" },
    [5] = { colorStr = "ffffffff" },
    [7] = { colorStr = "ff0070de" },
    [8] = { colorStr = "ff40c7eb" },
    [9] = { colorStr = "ff8787ed" },
    [11] = { colorStr = "ffff7d0a" },
}

PROFESSION_ICONS = {
    [1] = "Interface\\Icons\\inv_weapon_shortblade_01",
    [2] = "Interface\\Icons\\trade_alchemy",
    [3] = "Interface\\Icons\\trade_herbalism",
    [4] = "Interface\\Icons\\trade_leatherworking",
    [5]  = "Interface\\Icons\\trade_engineering",
    [6] = "Interface\\Icons\\inv_misc_food_15",
    [7] = "Interface\\Icons\\spell_holy_sealofsacrifice",
    [8] = "Interface\\Icons\\trade_fishing",
    [9] = "Interface\\Icons\\trade_engraving",
    [10] = "Interface\\Icons\\trade_tailoring",
    [11] = "Interface\\Icons\\trade_mining",
    [12] = "Interface\\Icons\\trade_blacksmithing",
}

function RushMode:FormatMoneyWithColor(moneyStr)
    local g, s, c = moneyStr:match("(%d+)g%s*(%d+)s%s*(%d+)c")
    g, s, c = tonumber(g) or 0, tonumber(s) or 0, tonumber(c) or 0

    local goldColor = "|cffffd700"
    local silverColor = "|cffc0c0c0"
    local copperColor = "|cff7f3300"

    local goldText = (g > 0 or g == 0) and tostring(g) .. goldColor .. "g|r" or ""
    local silverText = (s > 0 or s == 0) and tostring(s) .. silverColor .. "s|r" or ""
    local copperText = (c > 0 or c == 0) and tostring(c) .. copperColor .. "c|r" or ""

    return goldText .. " " .. silverText .. " " .. copperText
end


function RushMode:RandomOnlineWhitelistedPlayer()
    local ids = {}
    for playerName, whitelisted in pairs(RushModeDB.whitelist) do
        if whitelisted and playerName ~= UnitName("player") then
            for _, data in pairs(RushModeDB.players) do
                if data.name == playerName and time() - data.lastUpdate <= 120 and Comm.PlayerInGuild[playerName] then
                    table.insert(ids, playerName)
                end
            end
        end
    end
    if #ids == 0 then
        return
    end
    
    local randomPlayerName = ids[math.random(#ids)]
    return randomPlayerName
end
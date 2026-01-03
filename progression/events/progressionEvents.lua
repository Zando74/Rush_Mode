local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_DEAD")
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
f:RegisterEvent("CHAT_MSG_LOOT")
f:RegisterEvent("QUEST_TURNED_IN")
f:RegisterEvent("PLAYER_LEVEL_UP")
f:RegisterEvent("CHAT_MSG_SKILL")

f:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_DEAD" then
        local level = UnitLevel("player")
        if level > 10 then
            RushMode:SendProgressionUpdate(ProgressionEnum.DEATH)
        end
        local inInstance, instanceType = IsInInstance()
        if inInstance and instanceType == "party" then
            RushMode:SendProgressionUpdate(ProgressionEnum.DEATHDUNGEON)
        end
        RushMode:SendStatusUpdate()
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, subEvent,
            _,
            sourceGUID, sourceName, sourceFlags,
            _,
            destGUID, destName =
            CombatLogGetCurrentEventInfo()

        if subEvent ~= "PARTY_KILL" or not destGUID then return end

        local parts = { strsplit("-", destGUID) }
        local npcId = tonumber(parts[6])
        if not npcId then return end

        if ProgressionEnum[tostring(npcId)] ~= nil then
            RushMode:SendProgressionUpdate(
                tostring(npcId)
            )
        end
    elseif event == "PLAYER_LEVEL_UP" then
        local level = UnitLevel("player")
        if ProgressionEnum["level"][level] ~= nil then
            RushMode:SendProgressionUpdate(ProgressionEnum["level"][level])
        end
    elseif event == "CHAT_MSG_SKILL" then
        RushMode:CheckProfessionProgression()
    end
end)
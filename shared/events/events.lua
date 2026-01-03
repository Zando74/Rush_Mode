local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_GUILD_UPDATE")
eventFrame:RegisterEvent("GUILD_ROSTER_UPDATE")

function IsGuildCommReady()
    return IsInGuild() and GetGuildInfo("player") ~= nil
end

function Comm:OnGuildAvailable()
    if Comm.guildReady then return end
    GuildRoster()
    Comm:RegisterComm()
    Comm.guildReady = true
    UpdateSyncStatus()
end

eventFrame:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_LOGIN" then
        print(L["ADDON_LOADED"])
        return
    elseif event == "PLAYER_GUILD_UPDATE" or event == "GUILD_ROSTER_UPDATE" then
        if IsGuildCommReady() then
            Comm:OnGuildAvailable()
        end
    end
end)
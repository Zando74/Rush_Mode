L = LibStub("AceLocale-3.0"):GetLocale("RushMode")

RushMode = {
    IsInGuild = true
}

RushModeDB = {
    rushID = "",
    players = {},
    whitelist = {},
    team = "",
    player = "",
    trackedCharacters = {},
    progressionEvents = {},
    notifEnabled = true,
    professionsSnapshot = {},
    fraudEvents = {},
    minimap = {},
}

function RushMode:Initialize(rushID)
    local name = UnitName("player")
    RushModeDB = {
        rushID = rushID,
        players = {},
        whitelist = {
            [name] = true,
        },
        team = "",
        player = "",
        trackedCharacters = {},
        progressionEvents = {},
        notifEnabled = true,
        professionsSnapshot = {},
        fraudEvents = {},
        minimap = RushModeDB.minimap or {},
    }
    print(L["RUSH_INITIALIZED"])
end

function RushMode:Reset()
    RushModeDB = {
        rushID = "",
        players = {},
        whitelist = {},
        team = "",
        player = "",
        trackedCharacters = {},
        progressionEvents = {},
        notifEnabled = true,
        professionsSnapshot = {},
        fraudEvents = {},
        minimap = RushModeDB.minimap or {},
    }
    NotifyCheckBox:SetChecked(RushModeDB.notifEnabled)
    UpdateTrackButtonState()
    UpdateSyncStatus()
end

function RushMode:Login(userName)
    if RushModeDB.rushID == "" then
        print(L["RUSH_NOT_INITIALIZED"])
        return
    end
    RushModeDB.player = userName
    print(L["PLAYER_LOGIN"]:format(userName))
end

function RushMode:Join(team)
    if RushModeDB.rushID == "" then
        print(L["RUSH_NOT_INITIALIZED"])
        return
    end
    RushModeDB.team = team
    print(L["JOINED_TEAM"]:format(team))
end

function RushMode:Track()
    if RushModeDB.rushID == "" then
        print(L["RUSH_NOT_INITIALIZED"])
        return
    end
    local _, _, playerId = strsplit("-", UnitGUID("player"))
    RushModeDB.trackedCharacters[playerId] = true
    RushModeDB.whitelist[UnitName("player")] = true
    Comm.lastGuildProgressionMessage = time()
    print(L["CHAR_TRACKING_STARTED"])
end

function RushMode:Untrack()
    local _, _, playerId = strsplit("-", UnitGUID("player"))
    RushModeDB.trackedCharacters[playerId] = false
    RushModeDB.whitelist[UnitName("player")] = false
end
local AceComm = LibStub("AceComm-3.0")
local LibSerialize = LibStub("LibSerialize")
local LibDeflate = LibStub("LibDeflate")

Comm = {
    initialized = false,
    guildReady = false,
    lastGuildProgressionMessage = time(),
    PlayerInGuild = {},
}

Comm.prefixTracking = "RMODE_TRACK"
Comm.prefixProgression = "RMODE_PROG"
Comm.prefixFraud = "RMODE_FD"


function Comm:RegisterComm()
    if Comm.initialized then
        return
    end
    AceComm:RegisterComm(Comm.prefixTracking, function(_, msg, dist, sender)
        Comm:OnCommReceived(Comm.prefixTracking, msg, dist, sender)
    end)
    AceComm:RegisterComm(Comm.prefixProgression, function(_, msg, dist, sender)
        Comm:OnCommReceived(Comm.prefixProgression, msg, dist, sender)
    end)
    AceComm:RegisterComm(Comm.prefixFraud, function(_, msg, dist, sender)
        Comm:OnCommReceived(Comm.prefixFraud, msg, dist, sender)
    end)
    print(L["COMM_REGISTERED"])
    Comm.initialized = true
end

function Comm:SendGuildMessage(prefix, msg)
    local serialized = LibSerialize:Serialize(msg)
    local compressed = LibDeflate:CompressDeflate(serialized)
    local encoded = LibDeflate:EncodeForWoWAddonChannel(compressed)
    local _, _, playerId = strsplit("-", UnitGUID("player"))
    if RushModeDB.trackedCharacters[playerId] then
        AceComm:SendCommMessage(prefix, encoded, "GUILD")
    end
end

function Comm:SendWhisperMessage(prefix, msg, to)
    local serialized = LibSerialize:Serialize(msg)
    local compressed = LibDeflate:CompressDeflate(serialized)
    local encoded = LibDeflate:EncodeForWoWAddonChannel(compressed)
    AceComm:SendCommMessage(prefix, encoded, "WHISPER", to)
end

function Comm:OnCommReceived(prefix, msg, dist, sender)
    if prefix ~= Comm.prefixTracking and prefix ~= Comm.prefixProgression and prefix ~= Comm.prefixFraud then
        return
    end
    local decoded = LibDeflate:DecodeForWoWAddonChannel(msg)
    local uncompressed = LibDeflate:DecompressDeflate(decoded)
    local success, data = LibSerialize:Deserialize(uncompressed)
    if not success then return end
    Comm:OnDeserializedMessage(prefix, data, dist, sender)
end

function Comm:OnDeserializedMessage(prefix, msg, dist, sender)
    if prefix == Comm.prefixTracking then
        if dist == "GUILD" then
            if string.sub(msg, 1, 7) == "ASKWL:-" then
                RushMode:OnWhitelistAsked(sender, string.sub(msg, 8))
            else
                if RushModeDB.whitelist[sender] == nil or not RushModeDB.whitelist[sender] then
                    return
                end
                if sender == UnitName("player") then
                    Comm.lastGuildProgressionMessage = time()
                else
                    Comm.PlayerInGuild[sender] = true
                end
                RushMode:OnPlayerStatusUpdateReceived(msg)
            end
        elseif dist == "WHISPER" then
            if string.sub(msg, 1, 4) == "WL:-" then
                RushMode:OnWhitelistReceived(sender, string.sub(msg, 5))
            elseif string.sub(msg, 1, 5) == "REC:-" then
                if RushModeDB.whitelist[sender] == nil or not RushModeDB.whitelist[sender] then
                    return
                end
                RushMode:OnPlayerStatusWhisperReceived(string.sub(msg, 6))
            end
        end
    elseif prefix == Comm.prefixProgression then
        if dist == "GUILD" then
            if RushModeDB.whitelist[sender] == nil or not RushModeDB.whitelist[sender] then
                return
            end
            if type(msg) ~= "string" then
                RushMode:OnProgressionSharedReceived(msg)
            else
                if string.sub(msg, 1, 4) == "SD:-" then
                    RushMode:OnProgressionUpdateReceived(string.sub(msg, 5))
                end
            end
        elseif dist == "WHISPER" then
            if RushModeDB.whitelist[sender] == nil or not RushModeDB.whitelist[sender] then
                return
            end
            if string.sub(msg, 1, 4) == "SD:-" then
                RushMode:OnProgressionUpdateWhisperReceived(string.sub(msg, 5))
            end
        end
    elseif prefix == Comm.prefixFraud then
        if dist == "GUILD" then
            if RushModeDB.whitelist[sender] == nil or not RushModeDB.whitelist[sender] then
                return
            end
            if type(msg) ~= "string" then
                RushMode:OnFraudSharedReceived(msg)
            end
        end
    end
end

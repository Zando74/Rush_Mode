local frame = CreateFrame("Frame")
frame:RegisterEvent("MAIL_SHOW")
frame:RegisterEvent("MAIL_INBOX_UPDATE")

local MailSnapshot = {}
local ATTACHMENTS_MAX_RECEIVE = 12

local function BuildMailKey(index, sender, subject)
    return index .. "|" .. sender .. "|" .. subject
end

local function ExtractAttachments(mailIndex)
    local items = {}
    for slot = 1, ATTACHMENTS_MAX_RECEIVE do
        local name, itemID, _, count = GetInboxItem(mailIndex, slot)
        if name and itemID then
            items[itemID] = (items[itemID] or 0) + count
        end
    end
    return items
end


local function senderNotInWhitelist(sender)
    for playerName, _ in pairs(RushModeDB.whitelist) do
        if playerName == sender then
            return false
        end
    end
    return true
end

local function SnapshotInbox()
    MailSnapshot = {}

    for i = 1, GetInboxNumItems() do
        local _, _, sender, subject, money, _, _, hasItem, _, _, _, canReply =
            GetInboxHeaderInfo(i)

        if canReply and senderNotInWhitelist(sender) then
            local key = BuildMailKey(i, sender, subject)

            MailSnapshot[key] = {
                sender = sender,
                subject = subject,
                money = money or 0,
                attachments = hasItem and ExtractAttachments(i) or {}
            }
        end
    end
end

local function CheckInboxChanges()
    local current = {}

    -- état actuel
    for i = 1, GetInboxNumItems() do
        local _, _, sender, subject, money, _, _, hasItem, _, _, _, canReply =
            GetInboxHeaderInfo(i)

        if canReply and senderNotInWhitelist(sender) then
            local key = BuildMailKey(i, sender, subject)

            current[key] = {
                sender = sender,
                subject = subject,
                money = money or 0,
                attachments = hasItem and ExtractAttachments(i) or {}
            }
        end
    end

    -- comparaison
    for key, old in pairs(MailSnapshot) do
        local new = current[key]

        -- le mail existe encore → comparer
        if new then
            -- 💰 GOLD
            if new.money < old.money then
                local diff = old.money - new.money
                RushMode:RegisterMailFraud(old.sender, diff, nil)
            end

            -- 📦 ITEMS
            for itemID, oldCount in pairs(old.attachments) do
                local newCount = new.attachments[itemID] or 0
                if newCount < oldCount then
                    RushMode:RegisterMailFraud(
                        old.sender,
                        0,
                        itemID .. "x" .. (oldCount - newCount)
                    )
                end
            end

        -- le mail a disparu → tout a été pris
        else
            if old.money > 0 then
                RushMode:RegisterMailFraud(old.sender, old.money, nil)
            end

            for itemID, count in pairs(old.attachments) do
                RushMode:RegisterMailFraud(
                    old.sender,
                    0,
                    itemID .. "x" .. count
                )
            end
        end
    end

    MailSnapshot = current
end

function RushMode:RegisterMailFraud(sender, gold, attachment)
    if RushModeDB.whitelist[sender] then return end

    RushModeDB.fraudEvents[RushModeDB.player] =
        RushModeDB.fraudEvents[RushModeDB.player] or {}
    RushModeDB.fraudEvents[RushModeDB.player].mails =
        RushModeDB.fraudEvents[RushModeDB.player].mails or {}

    table.insert(RushModeDB.fraudEvents[RushModeDB.player].mails, {
        sender = sender,
        goldTaken = gold or 0,
        attachments = attachment or "",
        timestamp = time(),
    })
end


frame:SetScript("OnEvent", function(_, event)
    if event == "MAIL_SHOW" then
        SnapshotInbox()
    elseif event == "MAIL_INBOX_UPDATE" then
        CheckInboxChanges()
    end
end)

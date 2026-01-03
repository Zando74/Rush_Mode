function RushMode:SharePlayerFraud()
    local fraudEvents = RushModeDB.fraudEvents[RushModeDB.player]
    if not fraudEvents then
        return
    end

    local limitedFraud = {
        trades = {},
        mails = {},
    }

    if fraudEvents.trades then
        local tradeCopy = {}
        for _, trade in pairs(fraudEvents.trades) do
            table.insert(tradeCopy, trade)
        end
        for i = 1, math.min(10, #tradeCopy) do
            local idx = math.random(#tradeCopy)
            table.insert(limitedFraud.trades, tradeCopy[idx])
            table.remove(tradeCopy, idx)
        end
    end

    if fraudEvents.mails then
        local mailsCopy = {}
        for _, mails in pairs(fraudEvents.mails) do
            table.insert(mailsCopy, mails)
        end
        for i = 1, math.min(10, #mailsCopy) do
            local idx = math.random(#mailsCopy)
            table.insert(limitedFraud.mails, mailsCopy[idx])
            table.remove(mailsCopy, idx)
        end
    end
    
    Comm:SendGuildMessage(Comm.prefixFraud, {[RushModeDB.player] = limitedFraud})
end

function RushMode:OnFraudSharedReceived(message)
    for playerName, fraudEvents in pairs(message) do
        if not RushModeDB.fraudEvents then
            RushModeDB.fraudEvents = {}
        end
        if not RushModeDB.fraudEvents[playerName] then
            RushModeDB.fraudEvents[playerName] = {
                trades = {},
                mails = {},
            }
        end
        if fraudEvents.trades then
            for _, trade in ipairs(fraudEvents.trades) do
                local exists = false
                for _, t in ipairs(RushModeDB.fraudEvents[playerName].trades) do
                    if t.timestamp == trade.timestamp and t.giver == trade.giver then
                        exists = true
                        break
                    end
                end
                if not exists then
                    table.insert(RushModeDB.fraudEvents[playerName].trades, trade)
                end
            end
        end

        if fraudEvents.mails then
            RushModeDB.fraudEvents[playerName].mails = RushModeDB.fraudEvents[playerName].mails or {}
            for _, mail in pairs(fraudEvents.mails) do
                local exists = false
                for _, m in pairs(RushModeDB.fraudEvents[playerName].mails) do
                    if m.timestamp == mail.timestamp and m.sender == mail.sender and mail.attachments == m.attachments and mail.goldTaken == m.goldTaken then
                        exists = true
                        break
                    end
                end
                if not exists then
                    table.insert(RushModeDB.fraudEvents[playerName].mails, mail)
                end
            end
        end
    end
end
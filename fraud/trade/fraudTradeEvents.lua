local frame = CreateFrame("Frame")
frame:RegisterEvent("TRADE_ACCEPT_UPDATE")

frame:SetScript("OnEvent", function(_, event, playerAccepted, targetAccepted)
    if event ~= "TRADE_ACCEPT_UPDATE" then return end

    if playerAccepted == 1 and targetAccepted == 1 then
        local giverName = UnitName("NPC")

        local goldReceived = GetTargetTradeMoney()

        local items = {}
        for i = 1, 6 do
            local name, _, quantity = GetTradeTargetItemInfo(i)
            
            if name then
                local itemLink = GetTradeTargetItemLink(i)
                local itemID = tonumber(itemLink:match("item:(%d+)"))
                table.insert(items, {
                    name = itemID,
                    quantity = quantity,
                })
            end
        end

        local _, _, playerId = strsplit("-", UnitGUID("player"))
        if not RushModeDB.trackedCharacters[playerId] then
            return
        end

        for playerName, _ in pairs(RushModeDB.whitelist) do
            if playerName == giverName then
                return
            end
        end

        local itemQtyStr = ""
        for _, item in ipairs(items) do
            itemQtyStr = itemQtyStr .. item.name.. ":" .. item.quantity .. ", "
        end
        if itemQtyStr == "" and goldReceived == 0 then
            return
        end

        if not RushModeDB.fraudEvents[RushModeDB.player] then
            RushModeDB.fraudEvents[RushModeDB.player] = {}
        end
        if not RushModeDB.fraudEvents[RushModeDB.player]["trades"] then
            RushModeDB.fraudEvents[RushModeDB.player]["trades"] = {}
        end
        
        table.insert(RushModeDB.fraudEvents[RushModeDB.player]["trades"], {
            ["giver"] = giverName,
            ["goldReceived"] = goldReceived,
            ["items"] = itemQtyStr,
            ["timestamp"] = time(),
        })
    end
end)

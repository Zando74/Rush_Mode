
GameTooltip:HookScript("OnTooltipSetUnit", function(tooltip)
    local _, unit = tooltip:GetUnit()
    if not unit then return end
    if not UnitIsPlayer(unit) then return end

    local _, _, playerId = strsplit("-", UnitGUID(unit))
    if not playerId then return end

    local playerData = RushModeDB.players[playerId]

    tooltip:AddLine(" ")

    if playerData then
        tooltip:AddLine(L["PLAYER_TOOLTIP"], 1, 0.82, 0)
        tooltip:AddLine(L["IN_RUSH"], 0, 1, 0)

        if playerData.team then
            tooltip:AddLine(L["TEAM"] .. playerData.team, 0.6, 0.8, 1)
        end
    else
        tooltip:AddLine(L["PLAYER_TOOLTIP"])
        tooltip:AddLine(L["OUT_RUSH"], 1, 0.3, 0.3)
    end

    tooltip:Show()
end)

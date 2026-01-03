local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")

StatsFrame = CreateFrame("Frame", nil, MainFrame)
StatsFrame:SetPoint("TOPLEFT", ScrollFrame, "BOTTOMLEFT", 0, -5)
StatsFrame:SetPoint("BOTTOMRIGHT", MainFrame, "BOTTOMRIGHT", -8, 10)

local bg = StatsFrame:CreateTexture(nil, "BACKGROUND")
bg:SetTexture("Interface\\FrameGeneral\\UI-Background-Rock")
bg:SetVertexColor(1, 1, 1, 0.25)
bg:SetAllPoints()

local topLine = StatsFrame:CreateTexture(nil, "ARTWORK")
topLine:SetColorTexture(0.2, 0.2, 0.2, 1)
topLine:SetPoint("TOPLEFT", StatsFrame, "TOPLEFT", 0, 2)
topLine:SetPoint("TOPRIGHT", StatsFrame, "TOPRIGHT", 0, 2)
topLine:SetHeight(1)

StatsFrame.title = StatsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
StatsFrame.title:SetPoint("TOP", StatsFrame, "TOP", -200, -5)
StatsFrame.title:SetText(L["STAT_TITLE"])

NotifyCheckBox = CreateFrame("CheckButton", nil, StatsFrame, "UICheckButtonTemplate")
NotifyCheckBox:SetPoint("BOTTOMRIGHT", StatsFrame, "BOTTOMRIGHT", -100, 20)

NotifyCheckBox.text = NotifyCheckBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
NotifyCheckBox.text:SetPoint("LEFT", NotifyCheckBox, "RIGHT", 4, 0)
NotifyCheckBox.text:SetText(L["STAT_NOTIFY_LABEL"])

NotifyCheckBox:SetChecked(RushModeDB.notifEnabled)

local TrackButton = CreateFrame("Button", nil, StatsFrame, "UIPanelButtonTemplate")
TrackButton:SetSize(160, 22)
TrackButton:SetPoint("RIGHT", NotifyCheckBox, "LEFT", -10, 0)

local function GetPlayerID()
    local _, _, playerId = strsplit("-", UnitGUID("player"))
    return playerId
end

local function IsPlayerTracked()
    local playerId = GetPlayerID()
    if RushModeDB.trackedCharacters ~= nil then
        if RushModeDB.trackedCharacters[playerId] == nil then
            return false
        end
        return RushModeDB.trackedCharacters[playerId]
    end
    return false
end

function UpdateTrackButtonState()
    if IsPlayerTracked() then
        TrackButton:SetText(L["TRACKING_ENABLED"])
        TrackButton:Disable()
        TrackButton:GetFontString():SetTextColor(0.6, 0.6, 0.6)
    else
        TrackButton:SetText(L["TRACKING_ENABLE"])
        TrackButton:Enable()
        TrackButton:GetFontString():SetTextColor(1, 0.82, 0)
    end
end

TrackButton:SetScript("OnClick", function()
    if IsPlayerTracked() then
        return
    end
    RushMode:Track()
    UpdateTrackButtonState()
end)

local StatusText = StatsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
StatusText:SetPoint("CENTER", TrackButton, "CENTER", 0, -20)
StatusText:SetTextColor(1, 0, 0)
StatusText:SetText(L["STAT_STATUS_NONSYNC"])

function UpdateSyncStatus()
    local playerCount = 0
    for playerName, whitelisted in pairs(RushModeDB.whitelist or {}) do
        if whitelisted and playerName ~= UnitName("player") then playerCount = playerCount + 1 end
    end

    if playerCount == 0 then
        StatusText:SetTextColor(1, 0, 0)
        StatusText:SetText(L["STAT_STATUS_NONSYNC"])
        StatusText.tooltipText = L["STAT_STATUS_TOOLTIP_NONSYNC"]
    elseif not IsGuildCommReady() then
        StatusText:SetTextColor(1, 0, 0)
        StatusText:SetText(L["STAT_STATUS_NOTGUILD"])
        StatusText.tooltipText = L["STAT_STATUS_TOOLTIP_NOTGUILD"]
    elseif time() - Comm.lastGuildProgressionMessage > 60 then
        StatusText:SetTextColor(1, 1, 0)
        StatusText:SetText(L["STAT_STATUS_DEGRADED"])
        StatusText.tooltipText = L["STAT_STATUS_TOOLTIP_DEGRADED"]
    else
        -- Plusieurs joueurs => synchronisé
        StatusText:SetTextColor(0, 1, 0)
        StatusText:SetText(L["STAT_STATUS_SYNC"]) -- Synchronisé
        StatusText.tooltipText = L["STAT_STATUS_TOOLTIP_SYNC"] -- “Vous êtes synchronisé avec les autres joueurs du Rush”
    end
end

StatusText:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:AddLine(self.tooltipText or "", 1, 1, 1, true)
    GameTooltip:Show()
end)
StatusText:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)


eventFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "Rush_Mode" then
        NotifyCheckBox:SetChecked(RushModeDB.notifEnabled)
        UpdateTrackButtonState()
        UpdateSyncStatus()
    end
end)

TrackButton:SetScript("OnClick", function()
    if IsPlayerTracked() then return end
    RushMode:Track()
    UpdateTrackButtonState()
    UpdateSyncStatus()
end)



NotifyCheckBox:SetScript("OnClick", function(self)
    RushModeDB.notifEnabled = self:GetChecked()
end)

NotifyCheckBox:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:AddLine(L["STAT_NOTIFY_TITLE"], 1, 0.82, 0)
    GameTooltip:AddLine(L["STAT_NOTIFY_DESC"], 0.8, 0.8, 0.8, true)
    GameTooltip:Show()
end)

NotifyCheckBox:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)


local function CreateStatIcon(parent, texturePath)
    local f = CreateFrame("Frame", nil, parent)
    f:SetSize(32, 32)

    f.icon = f:CreateTexture(nil, "ARTWORK")
    f.icon:SetPoint("TOPLEFT")
    f.icon:SetPoint("BOTTOMRIGHT")
    f.icon:SetTexture(texturePath)

    f.text = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    f.text:SetPoint("LEFT", f, "RIGHT", 4, 0)
    f.text:SetJustifyH("LEFT")
    f.text:SetText("0")

    return f
end

local iconSpacing = 80
local startX = 80
local startY = -30

LevelStat = CreateStatIcon(StatsFrame, "Interface\\Icons\\achievement_level_60")
LevelStat:SetPoint("TOPLEFT", StatsFrame, "TOPLEFT", startX, startY)

GoldStat  = CreateStatIcon(StatsFrame, "Interface\\Icons\\INV_Misc_Coin_01")
GoldStat:SetPoint("TOPLEFT", LevelStat, "TOPLEFT", iconSpacing, 0)

ProfStat  = CreateStatIcon(StatsFrame, "Interface\\Icons\\INV_misc_wrench_01")
ProfStat:SetPoint("TOPLEFT", GoldStat, "TOPLEFT", iconSpacing, 0)

ItemStat  = CreateStatIcon(StatsFrame, "Interface\\Icons\\inv_misc_desecrated_plategloves")
ItemStat:SetPoint("TOPLEFT", ProfStat, "TOPLEFT", iconSpacing, 0)

DeadStat  = CreateStatIcon(StatsFrame, "Interface\\Icons\\spell_shadow_deathscream")
DeadStat:SetPoint("TOPLEFT", ItemStat, "TOPLEFT", iconSpacing, 0)


function UpdateStats()
    local totalLevel, totalGold, totalDead = 0, 0, 0
    local professionsCount = {}
    local itemCounts = {
        gray = 0,
        white = 0,
        green = 0,
        blue = 0,
        purple = 0,
    }

    for _, data in pairs(RushModeDB.players) do
        if data.team == SelectedTeam or SelectedTeam == "Total" then
            local alive = (data.isDead == 0)
            if not alive then
                totalDead = totalDead + 1
            else
                totalLevel = totalLevel + (data.level or 0)

                local g,s,c = (data.money or "0g 0s 0c"):match("(%d+)g%s*(%d+)s%s*(%d+)c")
                g = tonumber(g) or 0
                s = tonumber(s) or 0
                c = tonumber(c) or 0
                totalGold = totalGold + g*10000 + s*100 + c

                if data.professions and data.professions ~= "" then
                    for prof in string.gmatch(data.professions, "([^,]+)") do
                        for profName, profSkillNumber in string.gmatch(prof, "(%w+):(%d+)") do
                            professionsCount[profName] = (professionsCount[profName] or 0) + tonumber(profSkillNumber)
                        end
                    end
                end

                if data.items and data.items ~= "" then
                    local splitItems = {strsplit(",", data.items)}
                    for _, itemID in ipairs(splitItems) do
                        local itemLink = select(2, GetItemInfo(itemID))
                        local colorCode = itemLink:match("|c(%x%x%x%x%x%x%x%x)")
                        if colorCode then
                            colorCode = colorCode:lower()
                            if colorCode == "ff9d9d9d" then
                                itemCounts.gray = itemCounts.gray + 1
                            elseif colorCode == "ffffffff" then
                                itemCounts.white = itemCounts.white + 1
                            elseif colorCode == "ff1eff00" then
                                itemCounts.green = itemCounts.green + 1
                            elseif colorCode == "ff0070dd" then
                                itemCounts.blue = itemCounts.blue + 1
                            elseif colorCode == "ffa335ee" then
                                itemCounts.purple = itemCounts.purple + 1
                            end
                        end
                    end
                end
            end
        end
    end

    LevelStat.text:SetText(totalLevel)
    GoldStat.text:SetText(math.floor(totalGold / 10000).."g") 
    DeadStat.text:SetText(totalDead)

    local profsTotal = 0
    for _, count in pairs(professionsCount) do profsTotal = profsTotal + count end
    ProfStat.text:SetText(profsTotal)

    local itemText = string.format(
        L["STAT_ITEM_TEXT"],
        itemCounts.gray, itemCounts.white, itemCounts.green, itemCounts.blue, itemCounts.purple
    )
    local totalItemCount = itemCounts.gray + itemCounts.white + itemCounts.green + itemCounts.blue + itemCounts.purple
    ItemStat.text:SetText(totalItemCount)

    local function SetTooltip(f, title, desc)
        f:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:AddLine(title, 1, 0.82, 0)
            GameTooltip:AddLine(desc, 0.8,0.8,0.8,1)
            GameTooltip:Show()
        end)
        f:SetScript("OnLeave", function() GameTooltip:Hide() end)
    end

    SetTooltip(LevelStat, L["STAT_LEVEL_TITLE"], L["STAT_LEVEL_DESC"])
    SetTooltip(GoldStat, L["STAT_GOLD_TITLE"], L["STAT_GOLD_DESC"])
    SetTooltip(DeadStat, L["STAT_DEAD_TITLE"], L["STAT_DEAD_DESC"])
    SetTooltip(ProfStat, L["STAT_PROF_TITLE"], L["STAT_PROF_DESC"])
    SetTooltip(ItemStat, L["STAT_ITEM_TITLE"], itemText)
end


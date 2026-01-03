function UpdateUI()
    if not RushModeFrame:IsShown() then return end
    BuildTeamTabs()

    local list = FilterSelectedTeam()

    table.sort(list, function(a, b)
        local now = time()
        local aOnline = (now - a.lastUpdate <= 60)
        local bOnline = (now - b.lastUpdate <= 60)

        local aDead = a.isDead == 1
        local bDead = b.isDead == 1


        if aOnline ~= bOnline then
            return aOnline
        end


        if not aOnline and not bOnline and aDead ~= bDead then
            return bDead
        end

        if a.level ~= b.level then
            return a.level > b.level
        end

        local function MoneyToCopper(moneyStr)
            local g,s,c = moneyStr:match("(%d+)g%s*(%d+)s%s*(%d+)c")
            g,s,c = tonumber(g) or 0, tonumber(s) or 0, tonumber(c) or 0
            return g*10000 + s*100 + c
        end

        return MoneyToCopper(a.money or "0g 0s 0c") > MoneyToCopper(b.money or "0g 0s 0c")
    end)

    local totalHeight = 0

    for i = 1, MAX_ROWS do
        local row = Rows[i]
        local data = list[i]

        if data then
            local color
            local now = time()

            if data.isDead == 1 then
                color = "|cffff0000"  -- red
            elseif now - data.lastUpdate > 120 and data.isDead ~= 1 then
                color = "|cff808080"  -- grey
            else
                color = "|cff00ff00"  -- green
            end
            row.name:SetText(color .. (data.name or "") .. "|r")
            local player = data.player
            row.player:SetText(player)
            row.level:SetText(data.level or "")
            
            local classID = data.class
            local className = GetClassInfo(classID)
            local classColor = RUSH_CLASS_COLORS[tonumber(classID)]
            if classColor then
                row.class:SetText("|c" .. classColor.colorStr .. className .. "|r")
            else
                row.class:SetText(className or "")
            end

            row.money:SetText(RushMode:FormatMoneyWithColor(data.money or ""))
            local professions = ""
            if data.professions ~= "" then
                for profName, profSkillNumber in string.gmatch(data.professions, "([^:,]+):(%d+)") do
                    local iconPath = PROFESSION_ICONS[tonumber(profName)]

                    if iconPath then
                        professions = professions .. "|T" .. iconPath .. ":25:25|t " .. profSkillNumber .. "  "
                    else
                        professions = professions .. profName .. ":" .. profSkillNumber .. "  "
                    end
                end

                row.professions:SetText(professions)
            else
                row.professions:SetText("Pas de métiers")
            end

            for _, btn in ipairs(row.itemButtons or {}) do
                btn:Hide()
            end
            row.itemButtons = {}

            local xOffset, yOffset = 0, 0
            local spacingX, spacingY = 25, 25
            local maxWidth = 600
            local lineHeight = 20

            if data.items and data.items ~= "" then
                local splitItems = { strsplit(",", data.items) }

                for _, itemID in ipairs(splitItems) do
                    itemID = tonumber(itemID)
                    if itemID then
                        local btn = CreateFrame("Button", nil, row.itemContent)
                        btn:SetSize(25, 25)
                        btn:SetPoint("TOPLEFT", xOffset, -yOffset)

                        btn:SetScript("OnEnter", function(self)
                            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                            GameTooltip:SetItemByID(itemID)
                            GameTooltip:Show()
                        end)

                        btn:SetScript("OnLeave", function()
                            GameTooltip:Hide()
                        end)

                        btn:SetScript("OnClick", function(self, button)
                            local itemLink = select(2, GetItemInfo(itemID))
                            if itemLink then
                                SetItemRef(itemLink, itemLink, button)
                            end
                        end)

                        local icon = btn:CreateTexture(nil, "ARTWORK")
                        icon:SetAllPoints()

                        local _, _, _, _, iconTexture = GetItemInfoInstant(itemID)
                        if iconTexture then
                            icon:SetTexture(iconTexture)
                        else
                            icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
                        end

                        table.insert(row.itemButtons, btn)

                        xOffset = xOffset + spacingX
                        if xOffset + spacingX > maxWidth then
                            xOffset = 0
                            yOffset = yOffset + lineHeight
                        end
                    end
                end
            end


            local rowHeight = math.max(ROW_BASE_HEIGHT, math.min(MAX_ITEM_HEIGHT, yOffset + lineHeight))
            row.itemContent:SetHeight(rowHeight)

            row:SetHeight(rowHeight)
            row:SetPoint("TOPLEFT", 0, -totalHeight)
            totalHeight = totalHeight + rowHeight

            row:Show()
        else
            row:Hide()
        end
    end
    UpdateStats()
    Content:SetHeight(totalHeight)
end
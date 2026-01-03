Tabs = {}
SelectedTeam = nil
MAX_TAB_WIDTH = 90 
MIN_TAB_WIDTH = 30

local function GetTeamList()
    local set = {}
    for _, entry in pairs(RushModeDB.players or {}) do
        local t = entry.team
        if t and t ~= "" then set[t] = true end
    end
    local list = {}
    for t in pairs(set) do table.insert(list, t) end

    table.sort(list, function(a, b)
        local aCount = 0
        local bCount = 0
        for _, data in pairs(RushModeDB.players) do
            if data.team == a then aCount = aCount + 1 end
            if data.team == b then bCount = bCount + 1 end
        end
        return aCount > bCount
    end)

    if #list > 10 then
        for i = 11, #list do
            table.remove(list, i)
        end
    end

    table.insert(list, L["DEATHS"])

    return list
end

local function HighlightTabs()
    for _, tab in ipairs(Tabs) do
        if tab.team == SelectedTeam then
            PanelTemplates_SelectTab(tab)
        else
            PanelTemplates_DeselectTab(tab)
        end
    end
end

function BuildTeamTabs()
    local teams = GetTeamList()
    if not SelectedTeam or not tContains(teams, SelectedTeam) then
        SelectedTeam = teams[1]
    end

    local total = #teams
    PanelTemplates_SetNumTabs(MainFrame, total)

    for i = 1, total do
        if not Tabs[i] then
            local tab = CreateFrame("Button", "RushModeFrameTab"..i, MainFrame, "FriendsFrameTabTemplate")
            Tabs[i] = tab

            tab:SetScript("OnClick", function(self)
                SelectedTeam = self.team
                HighlightTabs()
                UpdateUI()
            end)
        end
    end

    local prevTab
    for i, team in ipairs(teams) do
        local tab = Tabs[i]
        tab:Show()
        tab.team = team
        tab:SetID(i)

        local name = team
        if #name > 14 then
            name = name:sub(1,12).."…"
        end
        tab:SetText(name)

        tab:ClearAllPoints()
        if not prevTab then
            tab:SetPoint("TOPLEFT", MainFrame, "BOTTOMLEFT", 5, 7)
        else
            tab:SetPoint("LEFT", prevTab, "RIGHT", 0, 0)
        end

        PanelTemplates_TabResize(tab, MIN_TAB_WIDTH, MAX_TAB_WIDTH)

        prevTab = tab
    end

    for i = total+1, #Tabs do
        Tabs[i]:Hide()
    end

    HighlightTabs()
end

function FilterSelectedTeam()
    local list = {}
    for _, data in pairs(RushModeDB.players) do
        if SelectedTeam == "Morts" then
            if (data.isDead == 1) then
                table.insert(list, data)
            end
        else
            if data.team == SelectedTeam then
                if data.isDead == 0 then
                    table.insert(list, data)
                end
            end
        end
    end
    return list
end
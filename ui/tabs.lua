------------------------------------------------------------
-- Tabs state
------------------------------------------------------------
Tabs = {}
SelectedTeam = nil

MAX_TAB_WIDTH = 90
MIN_TAB_WIDTH = 30

------------------------------------------------------------
-- Scrollable Tabs UI (created once)
------------------------------------------------------------
local TabsScrollFrame = CreateFrame("ScrollFrame", "RushModeTabsScrollFrame", MainFrame)
TabsScrollFrame:SetPoint("TOPLEFT", MainFrame, "BOTTOMLEFT", 5, 7)
TabsScrollFrame:SetPoint("TOPRIGHT", MainFrame, "BOTTOMRIGHT", -5, 7) -- même largeur que le conteneur
TabsScrollFrame:SetHeight(32)
TabsScrollFrame:EnableMouseWheel(true)

-- Conteneur pour les onglets
local TabsContent = CreateFrame("Frame", nil, TabsScrollFrame)
TabsContent:SetHeight(32)
TabsContent:SetWidth(1) -- sera recalculé

TabsScrollFrame:SetScrollChild(TabsContent)

-- Scroll avec limite
TabsScrollFrame:SetScript("OnMouseWheel", function(self, delta)
    local step = 40
    local scroll = self:GetHorizontalScroll()
    local maxScroll = math.max(TabsContent:GetWidth() - self:GetWidth(), 0)

    scroll = scroll - delta * step
    if scroll < 0 then scroll = 0 end
    if scroll > maxScroll then scroll = maxScroll end

    self:SetHorizontalScroll(scroll)
end)

------------------------------------------------------------
-- Team list
------------------------------------------------------------
local function GetTeamList()
    local set = {}
    for _, entry in pairs(RushModeDB.players or {}) do
        local t = entry.team
        if t and t ~= "" then set[t] = true end
    end

    local list = {}
    
    for t in pairs(set) do table.insert(list, t) end

    table.sort(list, function(a, b)
        local aCount, bCount = 0, 0
        for _, data in pairs(RushModeDB.players) do
            if data.team == a then aCount = aCount + 1 end
            if data.team == b then bCount = bCount + 1 end
        end
        return aCount > bCount
    end)
    table.insert(list, L["DEATHS"])
    
    return list
end

------------------------------------------------------------
-- Tabs highlighting
------------------------------------------------------------
local function HighlightTabs()
    for _, tab in ipairs(Tabs) do
        if tab.team == SelectedTeam then
            PanelTemplates_SelectTab(tab)
        else
            PanelTemplates_DeselectTab(tab)
        end
    end
end

------------------------------------------------------------
-- Scroll to selected tab
------------------------------------------------------------
local function ScrollToSelectedTab()
    for _, tab in ipairs(Tabs) do
        if tab.team == SelectedTeam then
            local left = tab:GetLeft() - TabsContent:GetLeft()
            local right = left + tab:GetWidth()
            local scroll = TabsScrollFrame:GetHorizontalScroll()
            local visibleWidth = TabsScrollFrame:GetWidth()
            local maxScroll = math.max(TabsContent:GetWidth() - visibleWidth, 0)

            if left < scroll then
                scroll = left
            elseif right > scroll + visibleWidth then
                scroll = right - visibleWidth
            end

            if scroll < 0 then scroll = 0 end
            if scroll > maxScroll then scroll = maxScroll end

            TabsScrollFrame:SetHorizontalScroll(scroll)
            break
        end
    end
end

------------------------------------------------------------
-- Build Tabs
------------------------------------------------------------
function BuildTeamTabs()
    local teams = GetTeamList()

    if not SelectedTeam or not tContains(teams, SelectedTeam) then
        SelectedTeam = teams[1]
    end

    PanelTemplates_SetNumTabs(MainFrame, #teams)

    -- Create tabs if needed
    for i = 1, #teams do
        if not Tabs[i] then
            local tab = CreateFrame("Button", "RushModeFrameTab"..i, TabsContent, "FriendsFrameTabTemplate")
            tab:SetScript("OnClick", function(self)
                SelectedTeam = self.team
                HighlightTabs()
                ScrollToSelectedTab()
                UpdateUI()
            end)
            Tabs[i] = tab
        end
    end

    local prevTab
    local totalWidth = 0

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

        PanelTemplates_TabResize(tab, MIN_TAB_WIDTH, MAX_TAB_WIDTH)

        tab:ClearAllPoints()
        if not prevTab then
            tab:SetPoint("LEFT", TabsContent, "LEFT", 0, 0)
        else
            tab:SetPoint("LEFT", prevTab, "RIGHT", 0, 0)
        end

        totalWidth = totalWidth + tab:GetWidth()
        prevTab = tab
    end

    TabsContent:SetWidth(totalWidth)

    -- Hide unused tabs
    for i = #teams + 1, #Tabs do
        Tabs[i]:Hide()
    end

    HighlightTabs()
    ScrollToSelectedTab()
end

------------------------------------------------------------
-- Filtering logic
------------------------------------------------------------
function FilterSelectedTeam()
    local list = {}

    for _, data in pairs(RushModeDB.players) do
        if SelectedTeam == L["DEATHS"] then
            if data.isDead == 1 then
                table.insert(list, data)
            end
        else
            if data.team == SelectedTeam and data.isDead == 0 then
                table.insert(list, data)
            end
        end
    end

    return list
end

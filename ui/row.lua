ROW_BASE_HEIGHT = 40
MAX_ITEM_HEIGHT = 60
MAX_ROWS = 1000
Rows = {}

for i = 1, MAX_ROWS do
    local row = CreateFrame("Frame", nil, Content)
    row:SetPoint("TOPLEFT", 0, -((i - 1) * ROW_BASE_HEIGHT))
    row:SetSize(1010, ROW_BASE_HEIGHT)

    row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.name:SetPoint("LEFT", 3, 0)
    row.player = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.player:SetPoint("LEFT", 90, 0)
    row.level = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.level:SetPoint("LEFT", 155, 0)
    row.class = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.class:SetPoint("LEFT", 185, 0)
    row.money = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.money:SetPoint("LEFT", 250, 0)

    row.itemContent = CreateFrame("Frame", nil, row)
    row.itemContent:SetPoint("TOPLEFT", 330, -8)
    row.itemContent:SetSize(600, MAX_ITEM_HEIGHT)


    row.itemButtons = {}

    row.professions = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.professions:SetPoint("LEFT", 790, 0)

    local bg = row:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    if i % 2 == 0 then
        bg:SetColorTexture(0.12, 0.12, 0.12, 0.4)
    else
        bg:SetColorTexture(0.17, 0.17, 0.17, 0.4)
    end
    row.bg = bg

    local hl = row:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints()
    hl:SetTexture("Interface\\Buttons\\UI-Listbox-Highlight2")
    hl:SetBlendMode("ADD")
    hl:SetAlpha(0.6)
    row.hl = hl
    
    Rows[i] = row
end

Content:SetHeight(MAX_ROWS * ROW_BASE_HEIGHT)
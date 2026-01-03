local FormFrame = CreateFrame("Frame", "RushInitForm", UIParent, "BasicFrameTemplateWithInset")
FormFrame:SetSize(250, 200)
FormFrame:SetPoint("CENTER")
FormFrame:SetMovable(true)
FormFrame:EnableMouse(true)
FormFrame:RegisterForDrag("LeftButton")
FormFrame:SetScript("OnDragStart", FormFrame.StartMoving)
FormFrame:SetScript("OnDragStop", FormFrame.StopMovingOrSizing)
FormFrame:Hide()

FormFrame.title = FormFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
FormFrame.title:SetPoint("TOP", FormFrame, "TOP", 0, -5)
FormFrame.title:SetText(L["INIT_TITLE"])

local function CreateTextEntry(parent, labelText, yOffset)
    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("TOPLEFT", parent, "TOPLEFT", 15, yOffset)
    label:SetText(labelText)

    local editBox = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    editBox:SetSize(200, 25)
    editBox:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -5)
    editBox:SetAutoFocus(false)

    return editBox
end

local participantBox = CreateTextEntry(FormFrame, L["INIT_PARTICIPANT"], -30)
local teamBox = CreateTextEntry(FormFrame, L["INIT_TEAM"], -75)
local keyBox = CreateTextEntry(FormFrame, L["INIT_KEY"] , -120)

local saveButton = CreateFrame("Button", nil, FormFrame, "UIPanelButtonTemplate")
saveButton:SetSize(120, 25)
saveButton:SetPoint("BOTTOM", FormFrame, "BOTTOM", 0, 15)
saveButton:SetText(L["INIT_SAVE"])

saveButton:SetScript("OnClick", function()
    local participant = participantBox:GetText()
    local team = teamBox:GetText()
    local key = keyBox:GetText()

    if participant == "" or team == "" or key == "" then
        print("|cffff0000[RushMode]|r".. L["MUST_FILL_FIELDS"])
        return
    end

    -- Ici tu sauvegardes les données
    RushMode:Initialize(key)
    RushMode:Login(participant)
    RushMode:Join(team)

    NotifyCheckBox:SetChecked(RushModeDB.notifEnabled)
    UpdateTrackButtonState()
    UpdateSyncStatus()

    print("|cff00ff00[RushMode]|r".. L["DATA_SAVED"])
    FormFrame:Hide()
end)

-- Fonction pour afficher le formulaire
function RushMode:ShowInitForm()
    FormFrame:Show()
end

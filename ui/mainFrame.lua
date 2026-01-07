MainFrame = CreateFrame("Frame", "RushModeFrame", UIParent, "BasicFrameTemplateWithInset")
MainFrame:SetClampedToScreen(true) 
MainFrame:SetSize(1010, 450)
MainFrame:SetPoint("CENTER")
tinsert(UISpecialFrames, "RushModeFrame")
MainFrame:Hide()

MainFrame:SetMovable(true)
MainFrame:EnableMouse(true)
MainFrame:RegisterForDrag("LeftButton")
MainFrame:SetScript("OnDragStart", MainFrame.StartMoving)
MainFrame:SetScript("OnDragStop", MainFrame.StopMovingOrSizing)


MainFrame.title = MainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
MainFrame.title:SetPoint("TOP", 0, -5)
MainFrame.title:SetText(L["MAINFRAME_TITLE"])


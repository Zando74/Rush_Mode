ScrollFrame = CreateFrame("ScrollFrame", nil, MainFrame, "UIPanelScrollFrameTemplate")
ScrollBG = ScrollFrame:CreateTexture(nil, "BACKGROUND")
ScrollBG:SetPoint("TOPLEFT", 0, 0)
ScrollBG:SetPoint("BOTTOMRIGHT", 0, 0)
ScrollBG:SetVertexColor(0, 0, 0, 0.45)

StatsHeight = 75

ScrollFrame:SetPoint("TOPLEFT", 8, -60)
ScrollFrame:SetPoint("BOTTOMRIGHT", -35, StatsHeight + 10)


Content = CreateFrame("Frame", nil, ScrollFrame)
Content:SetSize(1, 1)
ScrollFrame:SetScrollChild(Content)
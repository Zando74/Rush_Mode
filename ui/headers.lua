
local HeaderBar = CreateFrame("Frame", nil, MainFrame)
HeaderBar:SetPoint("TOPLEFT", MainFrame, "TOPLEFT", 10, -30)
HeaderBar:SetPoint("TOPRIGHT", MainFrame, "TOPRIGHT", -10, -30)
HeaderBar:SetHeight(28)

local bottomLine = HeaderBar:CreateTexture(nil, "OVERLAY")
bottomLine:SetColorTexture(0.35, 0.35, 0.35, 1)
bottomLine:SetPoint("BOTTOMLEFT", HeaderBar, "BOTTOMLEFT", 0, 0)
bottomLine:SetPoint("BOTTOMRIGHT", HeaderBar, "BOTTOMRIGHT", 0, 0)
bottomLine:SetHeight(1)


local Headers = {
    { text = L["HEADER_CHARACTER"],                       width = 70  },
    { text = L["HEADER_PARTICIPANT"],                    width = 70  },
    { text = L["HEADER_LVL"],                       width = 25  },
    { text = L["HEADER_CLASS"],                    width = 70  },
    { text = L["HEADER_GOLD"],                      width = 80  },
    { text = L["HEADER_ITEMS"],      width = 460 },
    { text = L["HEADER_PROFESSIONS"],                   width = 100 },
}

local offsetX = 10

for _, h in ipairs(Headers) do

    local col = CreateFrame("Frame", nil, HeaderBar)
    col:SetPoint("TOPLEFT", HeaderBar, "TOPLEFT", offsetX, 0)
    col:SetSize(h.width, 28)


    local sep = col:CreateTexture(nil, "OVERLAY")
    sep:SetColorTexture(0.4, 0.4, 0.4, 0.4)
    sep:SetPoint("RIGHT", col, "RIGHT", 0, 0)
    sep:SetSize(1, 20)


    local text = col:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    if h.text == L["HEADER_CHARACTER"] then
        text:SetPoint("LEFT", col, "LEFT", 0, 0)
        text:SetJustifyH("LEFT")
    else
        text:SetPoint("CENTER", col, "CENTER", 0, 0)
        text:SetJustifyH("CENTER")
    end
    text:SetText(h.text)

    offsetX = offsetX + h.width
end

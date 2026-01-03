local LDB = LibStub("LibDataBroker-1.1")
local icon = LibStub("LibDBIcon-1.0")
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")

local RushModeLDB = LDB:NewDataObject("RushMode", {
    type = "launcher",
    icon = "Interface\\Icons\\Spell_Fire_Incinerate",

    OnClick = function(_, button)
        if button == "LeftButton" then
            if RushModeFrame:IsShown() then
                RushModeFrame:Hide()
            else
                if RushModeDB.rushID == "" then
                    RushMode:ShowInitForm()
                else
                    RushModeFrame:Show()
                    UpdateUI()
                end
            end
        end
    end,

    OnTooltipShow = function(tt)
        tt:AddLine("RushMode")
    end,
})

frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "Rush_Mode" then
        icon:Register("RushMode", RushModeLDB, RushModeDB.minimap)
    end
end)






StaticPopupDialogs["RUSHMODE_GUILD_RELOG_NOTICE"] = {
  text = "[Rush Mode] " .. L["LOGOUT_POPUP"],
  button2 = L["LOGOUT_BUTTON"],
  OnCancel = function() end,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  preferredIndex = 3,
}

local frame = CreateFrame("Frame")

local wasInGuildAtLogin = false
local popupShownThisSession = false

frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("GUILD_ROSTER_UPDATE")

frame:SetScript("OnEvent", function(_, event)
  if event == "PLAYER_ENTERING_WORLD" then
    wasInGuildAtLogin = IsInGuild()
    popupShownThisSession = false
    return
  end

  if event == "GUILD_ROSTER_UPDATE" then
    if popupShownThisSession then return end

    local isNowInGuild = IsInGuild()

    if not wasInGuildAtLogin and isNowInGuild then
      popupShownThisSession = true
      wasInGuildAtLogin = true

      StaticPopup_Show("RUSHMODE_GUILD_RELOG_NOTICE")
    end
  end
end)

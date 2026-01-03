SLASH_INITRUSH1 = "/rinit"
SlashCmdList["INITRUSH"] = function()
    RushMode:ShowInitForm()
end

SLASH_RESETRUSH1 = "/rreset"
SlashCmdList["RESETRUSH"] = function()
    RushMode:Reset()
end

SLASH_RUSHLOGIN1 = "/rlogin"
SlashCmdList["RUSHLOGIN"] = function(msg)
    if msg == "" then
        print("Usage: /rlogin <userName>")
        return
    end
    RushMode:Login(msg)
end

SLASH_RUSHJOIN1 = "/rjoin"
SlashCmdList["RUSHJOIN"] = function(msg)
    if msg == "" then
        print("Usage: /rjoin <team>")
        return
    end
    local teamName = strtrim(msg)
    RushMode:Join(teamName)
end

SLASH_RUSHTRACK1 = "/rtrack"
SlashCmdList["RUSHTRACK"] = function()
    RushMode:Track()
    print(L["CHAR_TRACKING_STARTED"])
end

SLASH_RUSHUNTRACK1 = "/runtrack"
SlashCmdList["RUSHUNTRACK"] = function()
    RushMode:Untrack()
end

SLASH_RUSHNOTIF1 = "/rnotif"
SlashCmdList["RUSHNOTIF"] = function(msg)
    if msg == "" then
        print("Usage: /rnotif <on/off>")
        return
    end
    if msg == "on" then
        RushModeDB.notifEnabled = true
    elseif msg == "off" then
        RushModeDB.notifEnabled = false
    end
    print(L["NOTIF_ENABLED"]:format(RushModeDB.notifEnabled and "on" or "off"))
end
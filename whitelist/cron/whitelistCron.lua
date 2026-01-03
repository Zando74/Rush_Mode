function RushMode:ShareWhitelistToRandomPlayer()
    RushMode:ShareWhitelist(RushMode:RandomOnlineWhitelistedPlayer())
end

RushMode.whitelistTicker = C_Timer.NewTicker(30, function()
    RushMode:ShareWhitelistToRandomPlayer()
end)
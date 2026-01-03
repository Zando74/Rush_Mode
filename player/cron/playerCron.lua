RushMode.ticker1 = C_Timer.NewTicker(10, function()
    RushMode:SendStatusUpdate()
end)
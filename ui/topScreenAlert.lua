RushMode.TopScreenAlert = {}
local TSA = RushMode.TopScreenAlert

TSA.width = 400
TSA.height = 32
TSA.yOffset = -50
TSA.alertDuration = 3
TSA.maxActiveAlerts = 5
TSA.alerts = {}
TSA.activeAlerts = {}

TSA.frame = CreateFrame("Frame", "RushMode_TopScreenAlertFrame", UIParent)
TSA.frame:SetSize(TSA.width, TSA.height)
TSA.frame:SetPoint("TOP", UIParent, "TOP", 0, TSA.yOffset)
TSA.frame:SetFrameStrata("HIGH")


local function CreateAlert(message, icon)
    local f = CreateFrame("Frame", nil, TSA.frame)
    f:SetSize(TSA.width, TSA.height)

    if icon then
        local tex = f:CreateTexture(nil, "ARTWORK")
        tex:SetSize(28, 28)
        tex:SetPoint("LEFT", 4, 0)
        tex:SetTexture(icon)
        f.icon = tex
    end

    f.text = f:CreateFontString(nil, "OVERLAY", "GameFontRedLarge")
    f.text:SetPoint("LEFT", f.icon or f, f.icon and "RIGHT" or "LEFT", 6, 0)
    f.text:SetTextColor(1, 0.5, 0) -- orange
    f.text:SetShadowColor(0,0,0,1)
    f.text:SetShadowOffset(2,-2)
    f.text:SetText("[RushMode] " .. message)

    f:SetAlpha(0)
    f:Hide()
    return f
end


function TSA:ShowAlert(message, icon, soundKit)
    if not RushModeDB.notifEnabled then return end
    if #self.activeAlerts >= self.maxActiveAlerts then return end
    local alert = table.remove(self.alerts, 1) or CreateAlert(message, icon)
    alert.text:SetText("[RushMode] " .. message)
    if icon and alert.icon then alert.icon:SetTexture(icon) end

    table.insert(self.activeAlerts, alert)
    alert:SetPoint("TOP", self.frame, "TOP", 0, -(#self.activeAlerts-1)*(self.height+4))
    alert:Show()

    alert:SetAlpha(0)
    alert:SetScale(0.8)
    UIFrameFadeIn(alert, 0.3, 0, 1)
    alert:SetScale(1)

    if soundKit then
        PlaySound(soundKit)
    end

    C_Timer.After(self.alertDuration, function()
        UIFrameFadeOut(alert, 0.3, 1, 0)
        C_Timer.After(2, function()
            alert:Hide()
            table.insert(self.alerts, alert)
            for i=#self.activeAlerts,1,-1 do
                if self.activeAlerts[i] == alert then
                    table.remove(self.activeAlerts, i)
                end
            end
            for i, a in ipairs(self.activeAlerts) do
                a:SetPoint("TOP", self.frame, "TOP", 0, -(i-1)*(self.height+4))
            end
        end)
    end)
end

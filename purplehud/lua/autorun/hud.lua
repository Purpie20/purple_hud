if CLIENT then
    if file.Exists("lua/autorun/config.lua", "GAME") then
        include("config.lua")
    else
        Msg("Config file 'config.lua' not found or empty!\n")
        HUDConfig = {}
    end

    surface.CreateFont("HUDFont", {
        font = "Roboto",
        size = 14,
        weight = 500
    })

    local function formatTime(seconds)
        if utime then
            return utime.SecondsToClock(seconds)
        else
            return string.FormattedTime(seconds, "%02i:%02i")
        end
    end

    local function isScoreboardOpen()
        local scoreboardPanel = vgui.GetWorldPanel():GetChild(0)
        return IsValid(scoreboardPanel) and scoreboardPanel:IsVisible()
    end

    local function drawFancyBar(x, y, width, height, percentage, color1, color2)
        surface.SetDrawColor(Color(0, 0, 0, 100))
        surface.DrawRect(x, y, width, height)

        local barWidth = math.Clamp(percentage / 100 * width, 0, width)
        local gradient = surface.GetTextureID("gui/gradient")
        surface.SetTexture(gradient)
        surface.SetDrawColor(color1)
        surface.DrawTexturedRect(x, y, barWidth, height)

        surface.SetDrawColor(color2)
        surface.DrawTexturedRect(x, y, barWidth, height / 2)
    end

    local function drawHUD()
        local player = LocalPlayer()

        if not IsValid(player) then return end

        local health = player:Health()
        local armor = player:Armor()
        local fps = math.Round(1 / FrameTime())
        local ping = player:Ping()
        local propsSpawned = player:GetCount("props")
        local rank = player:GetUserGroup()
        local serverName = GetHostName()
        local serverUptime = formatTime(SysTime())

        local barHeight = 40
        local startY = 0
        local padding = 10
        local healthBarWidth = 120
        local armorBarWidth = 120
        local rightPadding = 150
        local elementSpacing = 15

        local isTabOpen = isScoreboardOpen()

        draw.RoundedBox(0, 0, startY, ScrW(), barHeight, Color(50, 50, 50, 200))

        if not isTabOpen then
            local color = Color(255, 255, 255, 255)
            local serverNameText = "Server Name: " .. serverName
            surface.SetFont("HUDFont")
            local serverNameWidth = surface.GetTextSize(serverNameText)
            local serverNameX = (ScrW() - serverNameWidth) / 2
            draw.SimpleText(serverNameText, "HUDFont", serverNameX, startY + (barHeight / 2) - 8, color, TEXT_ALIGN_LEFT)
        end

        local leftX = padding
        local textY = startY + (barHeight / 2) - 8

        local healthText = "Health: " .. health .. "%"
        draw.SimpleText(healthText, "HUDFont", leftX, textY, Color(255, 100, 100, 255), TEXT_ALIGN_LEFT)
        leftX = leftX + surface.GetTextSize(healthText) + padding
        drawFancyBar(leftX, textY + 4, healthBarWidth, 12, health, Color(200, 50, 50, 255), Color(255, 100, 100, 100))
        leftX = leftX + healthBarWidth + padding

        local armorText = "Armor: " .. armor .. "%"
        draw.SimpleText(armorText, "HUDFont", leftX, textY, Color(100, 100, 255, 255), TEXT_ALIGN_LEFT)
        leftX = leftX + surface.GetTextSize(armorText) + padding
        drawFancyBar(leftX, textY + 4, armorBarWidth, 12, armor, Color(50, 50, 200, 255), Color(100, 100, 255, 100))

        local fpsText = "FPS: " .. fps
        local pingText = "Ping: " .. ping
        surface.SetFont("HUDFont")
        local fpsWidth = surface.GetTextSize(fpsText)
        local pingWidth = surface.GetTextSize(pingText)
        local fpsX = ScrW() - rightPadding
        local pingX = fpsX - fpsWidth - elementSpacing

        draw.SimpleText(fpsText, "HUDFont", fpsX, textY, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT)
        draw.SimpleText(pingText, "HUDFont", pingX, textY, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT)

        local rightX = pingX - pingWidth - elementSpacing
        local rightElements = {
            "Server Uptime: " .. serverUptime,
            "Rank: " .. rank,
            "Props Spawned: " .. propsSpawned
        }

        for _, text in ipairs(rightElements) do
            local textWidth = surface.GetTextSize(text)
            draw.SimpleText(text, "HUDFont", rightX, textY, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT)
            rightX = rightX - textWidth - elementSpacing
        end
    end

    local function hideDefaultHUD(name)
        local hideElements = {
            "CHudHealth",
            "CHudBattery",
            "CHudAmmo",
            "CHudSecondaryAmmo",
            "CHudHint"
        }

        for _, element in ipairs(hideElements) do
            if name == element then
                return false
            end
        end

        return true
    end

    hook.Add("HUDPaint", "DrawCustomHUD", drawHUD)
    hook.Add("HUDShouldDraw", "HideDefaultHUD", hideDefaultHUD)
end

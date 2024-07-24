if CLIENT then

    -- Ensure the config file is included properly
    if file.Exists("lua/autorun/config.lua", "GAME") then
        include("config.lua")
    else
        Msg("Config file 'config.lua' not found or empty!\n")
        HUDConfig = {} -- Fallback to an empty table to avoid errors
    end

    -- Create a custom font for the HUD
    surface.CreateFont("HUDFont", {
        font = "Roboto",
        size = 14,  -- Size for a slimmer appearance
        weight = 500
    })

    -- Function to generate a rainbow color
    local function getRainbowColor(t)
        local r = math.sin(t + 0) * 127 + 128
        local g = math.sin(t + 2) * 127 + 128
        local b = math.sin(t + 4) * 127 + 128
        return Color(r, g, b)
    end

    -- Function to format time using the utime library
    local function formatTime(seconds)
        if not utime then
            return string.FormattedTime(seconds, "%02i:%02i")
        end
        return utime.SecondsToClock(seconds)
    end

    -- Function to check if the scoreboard (TAB menu) is open
    local function isScoreboardOpen()
        local scoreboardPanel = vgui.GetWorldPanel():GetChild(0)
        return IsValid(scoreboardPanel) and scoreboardPanel:IsVisible()
    end

    -- Function to draw the custom HUD
    local function drawHUD()
        -- Get player info
        local player = LocalPlayer()
        
        -- Ensure the player entity and their active weapon are valid
        if not IsValid(player) then return end

        local health = player:Health()
        local armor = player:Armor()
        local fps = math.Round(1 / FrameTime())
        local ping = player:Ping()  -- Get player's ping
        local propsSpawned = player:GetCount("props")
        local rank = player:GetUserGroup() -- ULX rank
        local serverName = GetHostName()

        -- Server uptime
        local serverUptime = formatTime(SysTime())

        -- Bar dimensions and positioning
        local barHeight = 40
        local startY = 0
        local padding = 10
        local healthBarWidth = 80
        local armorBarWidth = 80
        local rightPadding = 150  -- Adjusted to create space for the fixed FPS and ping
        local elementSpacing = 15 -- Space between right-aligned elements

        -- Check if TAB is pressed or Toolgun is held
        local isTabOpen = isScoreboardOpen()
        local isToolgunHeld = IsValid(player:GetActiveWeapon()) and player:GetActiveWeapon():GetClass() == "gmod_tool"

        -- Draw the background bar
        draw.RoundedBox(0, 0, startY, ScrW(), barHeight, Color(50, 50, 50, 200))

        -- Get current time for color cycling
        local currentTime = SysTime()
        local color

        -- Optionally hide the server name
        if not isTabOpen and not isToolgunHeld then
            -- Centered server name with optional color cycling
            if HUDConfig.EnableColorCycling then
                color = getRainbowColor(currentTime * HUDConfig.ColorCycleSpeed)
            else
                color = Color(255, 255, 255, 255) -- Default color
            end

            local serverNameWidth = surface.GetTextSize("Server Name: " .. serverName)
            local serverNameX = ScrW() / 2 - serverNameWidth / 2
            draw.SimpleText("Server Name: " .. serverName, "HUDFont", serverNameX, startY + (barHeight / 2) - 8, color, TEXT_ALIGN_LEFT)
        end

        -- Left-aligned elements
        local leftX = padding
        local textY = startY + (barHeight / 2) - 8

        -- Draw health
        draw.SimpleText("Health: " .. health .. "%", "HUDFont", leftX, textY, Color(255, 100, 100, 255), TEXT_ALIGN_LEFT)
        leftX = leftX + surface.GetTextSize("Health: " .. health .. "%") + padding

        -- Health bar
        draw.RoundedBox(4, leftX, textY + 4, healthBarWidth, 8, Color(100, 0, 0, 50))
        draw.RoundedBox(4, leftX, textY + 4, math.Clamp(health, 0, 100) / 100 * healthBarWidth, 8, Color(255, 0, 0, 255))
        leftX = leftX + healthBarWidth + padding

        -- Draw armor
        draw.SimpleText("Armor: " .. armor .. "%", "HUDFont", leftX, textY, Color(100, 100, 255, 255), TEXT_ALIGN_LEFT)
        leftX = leftX + surface.GetTextSize("Armor: " .. armor .. "%") + padding

        -- Armor bar
        draw.RoundedBox(4, leftX, textY + 4, armorBarWidth, 8, Color(0, 0, 100, 50))
        draw.RoundedBox(4, leftX, textY + 4, math.Clamp(armor, 0, 100) / 100 * armorBarWidth, 8, Color(0, 0, 255, 255))

        -- Fixed position for FPS and Ping
        local fpsText = "FPS: " .. fps
        local pingText = "Ping: " .. ping
        local fpsWidth = surface.GetTextSize(fpsText)
        local pingWidth = surface.GetTextSize(pingText)
        local fpsX = ScrW() - rightPadding
        local pingX = fpsX - fpsWidth - elementSpacing

        draw.SimpleText(fpsText, "HUDFont", fpsX, textY, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT)
        draw.SimpleText(pingText, "HUDFont", pingX, textY, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT)

        -- Right-aligned elements
        local rightX = pingX - pingWidth - elementSpacing
        local rightElements = {
            "Server Uptime: " .. serverUptime,
            "Rank: " .. rank,
            "Props Spawned: " .. propsSpawned
        }

        -- Draw each right-aligned element with optional color cycling
        for i, text in ipairs(rightElements) do
            if HUDConfig.EnableColorCycling then
                color = getRainbowColor(currentTime * HUDConfig.ColorCycleSpeed + i)
            else
                color = Color(255, 255, 255, 255) -- Default color
            end

            local textWidth = surface.GetTextSize(text)
            draw.SimpleText(text, "HUDFont", rightX, textY, color, TEXT_ALIGN_RIGHT)
            rightX = rightX - textWidth - elementSpacing
        end
    end

    -- Function to hide default HUD elements
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
                return false -- Prevent drawing the default HUD element
            end
        end

        return true -- Allow drawing other default HUD elements
    end

    -- Hook the function to the HUDPaint event
    hook.Add("HUDPaint", "DrawCustomHUD", drawHUD)
    
    -- Hook to hide default HUD elements
    hook.Add("HUDShouldDraw", "HideDefaultHUD", hideDefaultHUD)
end

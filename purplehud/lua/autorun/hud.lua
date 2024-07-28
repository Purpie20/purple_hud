if CLIENT then
    -- Include the config file if it exists
    if file.Exists("lua/autorun/config.lua", "GAME") then
        include("config.lua")
    else
        Msg("Config file 'config.lua' not found or empty!\n")
        HUDConfig = {} -- Fallback to an empty table to avoid errors
    end

    -- Create a custom font for the HUD
    surface.CreateFont("HUDFont", {
        font = "Roboto",
        size = 14,
        weight = 500
    })

    -- Function to format time
    local function formatTime(seconds)
        if utime then
            return utime.SecondsToClock(seconds)
        else
            return string.FormattedTime(seconds, "%02i:%02i")
        end
    end

    -- Enhanced boxy bar function
    local function drawBoxyBar(x, y, width, height, percentage, color)
        -- Background bar
        surface.SetDrawColor(Color(30, 30, 30, 180)) -- Background color
        surface.DrawRect(x, y, width, height)

        -- Foreground bar
        local barWidth = math.Clamp(percentage / 100 * width, 0, width)
        surface.SetDrawColor(color) -- Main color
        surface.DrawRect(x, y, barWidth, height)

        -- Add a border for aesthetic
        surface.SetDrawColor(Color(0, 0, 0, 255)) -- Border color
        surface.DrawOutlinedRect(x, y, width, height)
    end

    -- Function to draw the custom HUD
    local function drawHUD()
        -- Get player info
        local player = LocalPlayer()

        -- Ensure the player entity is valid
        if not IsValid(player) then return end

        -- Retrieve player stats
        local health = player:Health()
        local armor = player:Armor()
        local fps = math.Round(1 / FrameTime())
        local ping = player:Ping() -- Player's ping
        local propsSpawned = player:GetCount("props")
        local rank = player:GetUserGroup() -- ULX rank
        local serverName = GetHostName()

        -- Server uptime
        local serverUptime = formatTime(SysTime())

        -- Bar dimensions and positioning
        local barHeight = 40
        local startY = 0
        local padding = 10
        local healthBarWidth = 120
        local armorBarWidth = 120
        local elementSpacing = 15 -- Space between elements

        -- Draw the background bar
        draw.RoundedBox(0, 0, startY, ScrW(), barHeight, Color(50, 50, 50, 200))

        -- Center the server name
        local serverNameText = "Server Name: " .. serverName
        surface.SetFont("HUDFont")
        local serverNameWidth = surface.GetTextSize(serverNameText)
        local serverNameX = (ScrW() - serverNameWidth) / 2
        draw.SimpleText(serverNameText, "HUDFont", serverNameX, startY + (barHeight / 2) - 8, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)

        -- Left-aligned elements
        local leftX = padding
        local textY = startY + (barHeight / 2) - 8

        -- Draw health with boxy style
        local healthText = "Health: " .. health .. "%"
        draw.SimpleText(healthText, "HUDFont", leftX, textY, Color(255, 100, 100, 255), TEXT_ALIGN_LEFT)
        leftX = leftX + surface.GetTextSize(healthText) + padding

        local healthColor = Color(255, 0, 0, 255) -- Main color for health
        drawBoxyBar(leftX, startY + (barHeight / 2) - 6, healthBarWidth, 12, health, healthColor)
        leftX = leftX + healthBarWidth + padding

        -- Draw armor with boxy style
        local armorText = "Armor: " .. armor .. "%"
        draw.SimpleText(armorText, "HUDFont", leftX, textY, Color(100, 100, 255, 255), TEXT_ALIGN_LEFT)
        leftX = leftX + surface.GetTextSize(armorText) + padding

        local armorColor = Color(0, 0, 255, 255) -- Main color for armor
        drawBoxyBar(leftX, startY + (barHeight / 2) - 6, armorBarWidth, 12, armor, armorColor)

        -- Right-aligned elements
        local rightX = ScrW() - padding
        local rightElements = {
            {text = "Props Spawned: " .. propsSpawned, color = Color(255, 255, 255, 255)},
            {text = "Rank: " .. rank, color = Color(255, 255, 255, 255)},
            {text = "Server Uptime: " .. serverUptime, color = Color(255, 255, 255, 255)},
            {text = "Ping: " .. ping, color = Color(255, 255, 255, 255)},
            {text = "FPS: " .. fps, color = Color(255, 255, 255, 255)}
        }

        -- Iterate over each right-aligned element and draw it
        for _, element in ipairs(rightElements) do
            local textWidth = surface.GetTextSize(element.text)
            rightX = rightX - textWidth -- Move the starting position
            draw.SimpleText(element.text, "HUDFont", rightX, textY, element.color, TEXT_ALIGN_LEFT)
            rightX = rightX - elementSpacing -- Apply spacing after the text
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

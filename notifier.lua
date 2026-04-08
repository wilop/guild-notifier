local current_time = nil
local notify_queue = {}
local current = nil


-- Switches the icon to the GUILD_ICON while IDLE state
GuildNotifier.guild_member_added = {}
function GuildNotifier.guild_member_added:OnEvent(e, data)
    if e ~= "GUILD_MEMBER_ADDED" then return end
    if GuildNotifier.state ~= GuildNotifier.states["IDLE"] then return end
        GuildNotifier.play_sound(e)
        GuildNotifier:set_icon(e)
        GuildNotifier:icon_blinker(250, 5)
        Timer():SetTimeout(2000, function()
            GuildNotifier:set_icon("IDLE")
            GuildNotifier:refresh()
        end)
end
RegisterEvent(GuildNotifier.guild_member_added, "GUILD_MEMBER_ADDED");

-- Receives messages from chat events
GuildNotifier.chat_receiver = chatreceiver.OnEvent
function chatreceiver:OnEvent(e, data)
    if not GuildNotifier.gn_enable then return end
--     if GuildNotifier.mode_battle then return end

    if GuildNotifier.chat_events[e]  and not GuildNotifier.mode_battle then
        if data ~= nil and data.name ~= GetPlayerName() then
            local name = data.name
            local charid = GetCharacterIDByName(name)
            local guildtag = data.guildtag or GetGuildTag(charid)
            local msg = data.msg or ""
            local icon = e
            GuildNotifier.push_notification(name, guildtag, msg, icon) -- Arguments: title, subtitle, msg, icon
        end
    GuildNotifier.play_sound(e)
    end
    GuildNotifier.chat_receiver(self, e, data)
end

-- Gets info about a player for help or as target. Returns: name, health, guildtag, faction, ship, distance
function GuildNotifier.get_player_info(name)
    local name = name or GetPlayerName()
    local charid = GetCharacterIDByName(name)
    local health = GetPlayerHealth(charid)
    local guildtag = GetGuildTag(charid) or "-"
    local faction = FactionName[GetPlayerFaction(charid)] or "-"
    local ship = GetPrimaryShipNameOfPlayer(charid) or "-"
    local distance = GetRadarDistance(charid)
    distance = distance or -1
    return name, health, guildtag, faction, ship, distance
end
-- Plays a notification sound
function GuildNotifier.play_sound(sound)
    if GuildNotifier.volume == 0 then
        return
    else
        gksound.GKLoadSound{soundname = sound, filename = GuildNotifier.sounds[sound]}
        gksound.GKPlaySound(sound, GuildNotifier.volume)
    end
end

function GuildNotifier.push_notification(title, subtitle, msg, icon)
    if GuildNotifier.state == GuildNotifier.states["HIDDEN"] then return end

    if #notify_queue >= MAX_QUEUE then
        table.remove(notify_queue, 1)
    end

    table.insert(notify_queue, {
        title = title,
        subtitle = subtitle,
        msg = msg,
        icon = icon,
    })

    if not current then
        GuildNotifier.next_notification()
        GuildNotifier.play_sound("ZOOM")
        if GuildNotifier.mode_battle then
            GuildNotifier:fade(50,"BATTLE")
        else
            GuildNotifier:fade(50,"SHOWN")
        end
    end
end

function GuildNotifier.next_notification()
    current = table.remove(notify_queue, 1)
    console_print("🔴 Imprime un current")
    for k,v in pairs(current) do
        console_print(k..":")
        console_print(v)
    end
    GuildNotifier:set_gui_data(current)
    GuildNotifier.update_notification()
end

function GuildNotifier.update_notification()
    if not current then
        return
    end
    Timer():SetTimeout(TIMEOUT * 1000, function()
        if #notify_queue > 0 then
            GuildNotifier.next_notification()
        else
            current = nil
            GuildNotifier.play_sound("ZOOM")
--             local data = {
--                 title = "Welcome",
--                 subtitle = "Pilot",
--                 msg = "Thanks for using Guild Notifier.\nHave a great journey!.",
--                 icon = "IDLE",
--             }
--             GuildNotifier.set_gui_data(data)
            GuildNotifier:set_icon("IDLE")
            GuildNotifier:fade(50, "IDLE")
        end
    end)
end

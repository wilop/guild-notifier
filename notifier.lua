local current_time = nil
local notify_queue = {}
local current = nil

-- Trigger the events and test the notifications
GuildNotifier.tester ={}
function GuildNotifier.tester:OnEvent(e, data)
    if e ~="TEST" and data == nil then return end

    local test = data.test
    local name, _, guildtag = GuildNotifier.get_player_info()
    guildtag = guildtag or ""
    local sound = data.test
    local icon =  data.test
    local msg = data.msg
    if test == "HELP" then
        ProcessEvent(test, {name = name})
    elseif test == "target" then
        ProcessEvent(test, data.msg)
    elseif test == "GUILD_MEMBER_ADDED" then
        ProcessEvent(test)
    else
        GuildNotifier.push_notification(name, guildtag, msg, icon) -- Arguments: title, subtitle, msg, icon
        GuildNotifier.play_sound(sound)
    end
end
RegisterEvent(GuildNotifier.tester, "TEST");

-- BATTLE MODE
--CHAT_MSG_CHANNEL_EMOTE
--Arguments: data = {string name, string msg, int faction = factionid, int channelid}
GuildNotifier.battle_receiver = {}
function GuildNotifier.battle_receiver:OnEvent(e, data)
    if e ~= "CHAT_MSG_CHANNEL_EMOTE" or data == nil then return end
    if data.channelid ~= 2097 then
        return
    end
    if not GuildNotifier.is_my_partner(data.name) then
        return end
    local msg = data.msg
    if msg == "HELP" then
        ProcessEvent(msg, {name = data.name})
    end

    local i, j = string.find(msg, "target")
    msg = string.sub(msg, i, j)

    if msg == "target" then
        ProcessEvent(msg, data.msg)
    end
end
RegisterEvent(GuildNotifier.battle_receiver, "CHAT_MSG_CHANNEL_EMOTE");

-- Send a TARGET to a partner
function GuildNotifier.send_target()
    local channel = 2097
    local active_channel = GetActiveChatChannel()
    local name, health, dist, factionid, guild, ship = GetTargetInfo()
    local faction = ""

    -- name
    health = health and health *100 or -1
    dist = dist or -1
    factionid = factionid or -1
    faction = FactionName[factionid] or ""
    guild = guild or ""
    ship = ship or ""

    local format_send = "target=%s|health=%d|distance=%d|faction=%s|guild=%s|ship=%s"
    local msg = string.format(format_send, name, health, dist, faction, guild, ship)
    console_print("Un target antes de enviarlo")
    console_print(msg)

    if name == nil then return end
    JoinChannel(channel)
    Timer():SetTimeout(50, function ()
        SendChat("/me "..msg, "CHANNEL", channel)
    end)
    JoinChannel(active_channel)
end

-- Displays TARGET info shared by a partner
GuildNotifier.target = {}
function GuildNotifier.target:OnEvent(e, data)
    console_print("entrando a funcion target")
    console_print(data)
    if not GuildNotifier.gn_enable or not GuildNotifier.mode_battle then return end
    if e ~= "target" or data == nil then return end

    local target = {target = "-", health = -1, distance = -1, faction = "-", guild = "-", ship = "-"}
    for k,v in string.gmatch(data, "([^|=]+)=([^|]+)") do
        target[k]=v
    end

    local icon = e

    local format_print = "\n\tTarget:%s\n\tHealth:%d\n\tDistance:%d\n\tFaction:%s\n\tGuild:%s\n\tShip:%s"
    print(string.format(format_print,
                        target.target, target.health, target.distance, target.faction, target.guild, target.ship))

    local format_notification = "%s\n<< <> Health: %d \t\t\tDistance: %d m <> >>\n%s"
    local msg = string.format(format_notification, target.ship, target.health, target.distance, target.faction)

    console_print(e)
    console_print(GuildNotifier.icons[e])
    console_print("o fue aqui")
    GuildNotifier:set_icon("targe")
    GuildNotifier.push_notification(target.target, target.guild, msg, "targe") -- Arguments: title, subtitle, msg, icon
    GuildNotifier.play_sound(e)
end
RegisterEvent(GuildNotifier.target, "target");

-- Send a HELP message when your health is less than 50%
GuildNotifier.help_seeker = {}
function GuildNotifier.help_seeker:OnEvent(e , data)
    if not GuildNotifier.gn_enable and not GuildNotifier.mode_battle then return end
    if e ~= "PLAYER_GOT_HIT" then return end

    local name, health = GuildNotifier.get_player_info()
    if health == nil or health > 50 then return end

    local channel = 2097
    local active_channel = GetActiveChatChannel()
    JoinChannel(channel)
    SendChat("/me HELP", "CHANNEL", channel)
    Timer():SetTimeout(50, function ()
            SendChat("/me HELP", "CHANNEL", channel)
        end)
    JoinChannel(active_channel)
end

RegisterEvent(GuildNotifier.help_seeker, "PLAYER_GOT_HIT");

-- Displays a notification asking for your health
GuildNotifier.helper = {}
function GuildNotifier.helper:OnEvent(e, data)
    if not GuildNotifier.gn_enable and not GuildNotifier.mode_battle then return end
    if e ~= "HELP" and data == nil then return end
    local name, health, guildtag, faction, ship, distance = GuildNotifier.get_player_info(data.name) --Returns: name, health, guildtag, faction, ship, distance
    local format_notification = "%s\n<< <> Health: %d \t\t\tDistance: %d m <> >>\n%s"
    local msg = string.format(format_notification, ship, health, distance, faction)
    local icon = e
    GuildNotifier:set_icon(e)
    GuildNotifier.push_notification(name, guildtag, msg, icon) -- Arguments: title, subtitle, msg, icon
    GuildNotifier.play_sound(e)
end
RegisterEvent(GuildNotifier.helper, "HELP");

-- Return true if a player is in our same group or guild
function GuildNotifier.is_my_partner(name)
    local partner_name = name

    ForEachBuddy(function (buddy_name)
        if partner_name == buddy_name then return true end
    end)

    local my_name, _, my_guildtag = GuildNotifier.get_player_info() --name, health, guildtag, faction, ship, distance
    local partner_name, _, partner_guildtad = GuildNotifier.get_player_info(partner_name)
    --if my_name == partner_name then return false end
    if my_guildtag == partner_guildtad then return true end

    return false
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
-- END of BATTLE MODE

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
    if GuildNotifier.chat_events[e]  then
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
    console_print("Imprime un current")
    for k,v in pairs(current) do
        console_print(k)
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

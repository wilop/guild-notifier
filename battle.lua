-- BATTLE MODE

--CHAT_MSG_CHANNEL_EMOTE
--Arguments: data = {string name, string msg, int faction = factionid, int channelid}
GuildNotifier.battle_receiver = {}
function GuildNotifier.battle_receiver:OnEvent(e, data)
    if not GuildNotifier.gn_enable or not GuildNotifier.mode_battle then return end
    if e ~= "CHAT_MSG_CHANNEL_EMOTE" or data == nil then return end
    if data.channelid ~= 2097 then
        return
    end
    if not GuildNotifier.is_my_partner(data.name) then return end

    local msg = data.msg
    if msg == "HELP" then
        ProcessEvent(msg, {name = data.name})
        return
    end

    local i, j = string.find(msg, "target")
    msg = string.sub(msg, i, j):upper()

    if msg == "TARGET" then
    ProcessEvent(msg, data.msg)
    end
end
RegisterEvent(GuildNotifier.battle_receiver, "CHAT_MSG_CHANNEL_EMOTE");

-- Send a TARGET to a partner
function GuildNotifier.send_target()
    if not GuildNotifier.gn_enable or not GuildNotifier.mode_battle then return end
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
    if e ~= "TARGET" or data == nil then return end

    local target = {target = "-", health = -1, distance = -1, faction = "-", guild = "-", ship = "-"}
    for k,v in string.gmatch(data, "([^|=]+)=([^|]+)") do
    target[k]=v
    end

    local icon = e

--     local format_print = "\n\tTarget:%s\n\tHealth:%d\n\tDistance:%d\n\tFaction:%s\n\tGuild:%s\n\tShip:%s"
--     print(string.format(format_print,
--     target.target, target.health, target.distance, target.faction, target.guild, target.ship))

    local format_notification = "%s\n<< <> Health: %d \t\t\tDistance: %d m <> >>\n%s"
    local msg = string.format(format_notification, target.ship, target.health, target.distance, target.faction)

    console_print(e)
    console_print(GuildNotifier.icons[e])
    console_print("o fue aqui")
    GuildNotifier:set_icon(e)
    GuildNotifier.push_notification(target.target, target.guild, msg, e) -- Arguments: title, subtitle, msg, icon
    GuildNotifier.play_sound(e)
end
RegisterEvent(GuildNotifier.target, "TARGET");

-- Send a HELP message when your health is less than 50%
GuildNotifier.help_seeker = {}
function GuildNotifier.help_seeker:OnEvent(e , data)
    if not GuildNotifier.gn_enable or not GuildNotifier.mode_battle then return end
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
    if not GuildNotifier.gn_enable or not GuildNotifier.mode_battle then return end
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
    if my_name == partner_name then return false end
    if my_guildtag == partner_guildtad then return true end

    return false
end

-- END of BATTLE MODE

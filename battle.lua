-- BATTLE MODE

--CHAT_MSG_CHANNEL_EMOTE
--Arguments: data = {string name, string msg, int faction = factionid, int channelid}
GuildNotifier.battle_receiver = {}
function GuildNotifier.battle_receiver:OnEvent(e, data)
    if not GuildNotifier.gn_enable or not GuildNotifier.mode_battle then return end
    if not GuildNotifier.battle_chat_events[e] or data == nil then return end
    if GuildNotifier.battle_channel ~= "GUILD" and tostring(data.channelid) ~= GuildNotifier.battle_channel then
        return
    end
    if GetPlayerName() == data.name then return end

    local msg = data.msg:upper()

    for k in pairs(GuildNotifier.battle_events) do
        local i, j = string.find(msg, k)
        if i ~= nil and j ~= nil then
            msg = string.sub(msg, i, j):upper()
            break
        end
    end

    if msg == "HELP" then
        ProcessEvent(msg, data)
        return
    end
    if msg == "TARGET" then
        ProcessEvent(msg, data.msg)
    end
end
RegisterEvent(GuildNotifier.battle_receiver, "CHAT_MSG_CHANNEL_EMOTE");
RegisterEvent(GuildNotifier.battle_receiver, "CHAT_MSG_GUILD_EMOTE");

-- Send a TARGET to a partner
function GuildNotifier.send_target()
    if not GuildNotifier.gn_enable or not GuildNotifier.mode_battle then return end

    local name, health, dist, factionid, guild, ship = GetTargetInfo()
    if name == nil then return end

    local channel = GuildNotifier.battle_channel
    local sectorid = GetCurrentSectorid() or -1
    local faction = ""

    health = health and health *100 or -1
    dist = dist or -1
    factionid = factionid or -1
    faction = FactionName[factionid] or ""
    guild = guild or ""
    ship = ship or ""

    local format_send = "target=%s|health=%d|distance=%d|faction=%s|guild=%s|ship=%s|sector=%d"
    local msg = string.format(format_send, name, health, dist, faction, guild, ship, sectorid)
    GuildNotifier.send_battle_messages(channel, msg)
end

-- Displays TARGET info shared by a partner
GuildNotifier.target = {}
function GuildNotifier.target:OnEvent(e, data)
    if not GuildNotifier.gn_enable or not GuildNotifier.mode_battle then return end
    if e ~= "TARGET" or data == nil then return end

    local target = {target = "-", health = -1, distance = -1, faction = "-", guild = "-", ship = "-", sector = -1}
    for k,v in string.gmatch(data, "([^|=]+)=([^|]+)") do
        target[k]=v
    end

    local charid = GetCharacterIDByName(target.target)
    if charid ~= nil then
        target.distance = GetRadarDistance(charid) or -1
    end

    local format_notification = "%s\n<> Health: %d \t%s\t    Dist: %d m <>\n%s"
    local sector = ShortLocationStr(target.sector) or "-"
    local msg = string.format(format_notification, target.ship, target.health, sector, target.distance, target.faction)

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

    local _, health = GuildNotifier.get_player_info()
    if health == nil or health > 50 then return end

    local sectorid = GetCurrentSectorid() or -1
    local channel = GuildNotifier.battle_channel
    local msg = string.format("HELP:%d", sectorid)

    GuildNotifier.send_battle_messages(channel, msg)
end

RegisterEvent(GuildNotifier.help_seeker, "PLAYER_GOT_HIT");

-- Displays a notification asking for your health
GuildNotifier.helper = {}
function GuildNotifier.helper:OnEvent(e, data)
    if not GuildNotifier.gn_enable or not GuildNotifier.mode_battle then return end
    if e ~= "HELP" and data == nil then return end
    local name, health, guildtag, faction, ship, distance = GuildNotifier.get_player_info(data.name)
    local sectorid = string.match(data.msg, ":(%d+)") or -1
    local sector = ShortLocationStr(sectorid) or "-"

    local format_notification = "%s\n<> Health: %d \t%s\t    Dist: %d m <>\n%s"
    local msg = string.format(format_notification, ship, health, sector, distance, faction)
    local icon = e
    GuildNotifier:set_icon(e)
    GuildNotifier.push_notification(name, guildtag, msg, icon) -- Arguments: title, subtitle, msg, icon
    GuildNotifier.play_sound(e)
end
RegisterEvent(GuildNotifier.helper, "HELP");

---Send messages for battle events
---@param channel string
---@param msg string
function GuildNotifier.send_battle_messages(channel, msg)
    if tostring(channel) == "GUILD" then
        Timer():SetTimeout(50, function ()
            SendChat("/me "..msg, "GUILD")
        end)
    else
        local active_channel = GetActiveChatChannel()
        local channel_ = tonumber(channel)
        JoinChannel(channel_)
        Timer():SetTimeout(50, function ()
            SendChat("/me "..msg, "CHANNEL", channel_)
        end)
        JoinChannel(active_channel)
    end
end

---Sets the battle chat channel.
---@param channel string
---@return boolean
---@return string channel
function GuildNotifier.set_battle_channel(channel)
    local channel_ = GuildNotifier.battle_channel
    if channel == "default" then channel_ = "2097"
    elseif channel == "guild" then channel_ = "GUILD"
    elseif tonumber(channel) then channel_ = tostring(channel)
    else
        return false, channel_
    end
    GuildNotifier.battle_channel = channel_
    return true, channel_
end

-- END of BATTLE MODE

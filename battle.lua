---BATTLE MODE

---@class battle_receiver
GN.battle_receiver = {}
---Manage the battle chat events.
---@param e string The battle chat event.
---@param data table The data for this event.
function GN.battle_receiver:OnEvent(e, data)
    if not GN.gn_enable then return end
    if not GN.mode_battle and not GN.extra_notifications then return end
    if not GN.battle_chat_events[e] or data == nil then return end
    if tonumber(data.channelid) and GN.vo_designated_channels[data.channelid] then return end
    if GN.battle_channel ~= "GUILD" and tostring(data.channelid) ~= GN.battle_channel then return end
    if GN.battle_channel == "GUILD" and tostring(data.channelid) == GN.battle_channel then return end

    if not GN.is_incoming(data.name) then return end

    local msg = data.msg:upper()

    for k in pairs(GN.battle_events) do
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
RegisterEvent(GN.battle_receiver, "CHAT_MSG_CHANNEL_EMOTE");
RegisterEvent(GN.battle_receiver, "CHAT_MSG_GUILD_EMOTE");

---Send a TARGET to a partner.
function GN.send_target()
    if not GN.gn_enable then return end
    if not GN.mode_battle and not GN.extra_notifications then return end

    local name, health, dist, factionid, guild, ship = GetTargetInfo()
    if name == nil then return end

    local channel = GN.battle_channel
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
    GN.send_battle_messages(channel, msg)
end

---@class target
GN.target = {}
---Displays TARGET info shared by a partner.
---@param e string The TARGET event.
---@param data table The data with the TARGET information.
function GN.target:OnEvent(e, data)
    if not GN.gn_enable then return end
    if not GN.mode_battle and not GN.extra_notifications then return end
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

    GN:set_icon(e)
    GN.push_notification(target.target, target.guild, msg, e) -- Arguments: title, subtitle, msg, icon
    GN.play_sound(e)
end
RegisterEvent(GN.target, "TARGET");

---@class help_seeker
GN.help_seeker = {}
---Send a HELP message when your health is less than 50%.
---@param e string The event.
---@param data table The data for this event (not used).
function GN.help_seeker:OnEvent(e , data)
    if not GN.gn_enable then return end
    if not GN.mode_battle and not GN.extra_notifications then return end
    if e ~= "PLAYER_GOT_HIT" then return end

    local _, health = GN.get_player_info()
    if health == nil or health > 50 then return end

    local sectorid = GetCurrentSectorid() or -1
    local channel = GN.battle_channel
    local msg = string.format("HELP:%d", sectorid)

    GN.send_battle_messages(channel, msg)
end
RegisterEvent(GN.help_seeker, "PLAYER_GOT_HIT");

---@class helper
GN.helper = {}
---Displays a notification asking for your health.
---@param e string The event.
---@param data table The data for this event.
function GN.helper:OnEvent(e, data)
    if not GN.gn_enable then return end
    if not GN.mode_battle and not GN.extra_notifications then return end
    if e ~= "HELP" and data == nil then return end
    local name, health, guildtag, faction, ship, distance = GN.get_player_info(data.name)
    local sectorid = string.match(data.msg, ":(%d+)") or -1
    local sector = ShortLocationStr(sectorid) or "-"

    local format_notification = "%s\n<> Health: %d \t%s\t    Dist: %d m <>\n%s"
    local msg = string.format(format_notification, ship, health, sector, distance, faction)
    local icon = e
    GN:set_icon(e)
    GN.push_notification(name, guildtag, msg, icon) -- Arguments: title, subtitle, msg, icon
    GN.play_sound(e)
end
RegisterEvent(GN.helper, "HELP");

---Send messages for battle events
---@param channel string The channel to send messages.
---@param msg string The message.
function GN.send_battle_messages(channel, msg)
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
---@param channel string The channel to be set.
---@return boolean resul true if channel is updated or false if not.
---@return string channel The new, current or ignored channel.
---@return string state The state of the channel (CURRENT | UPDATED | IGNORED)
function GN.set_battle_channel(channel)
    local channel_ = GN.battle_channel
    local state = "CURRENT"
    local resul = false

    if channel_ == channel then return resul, channel_, state
    elseif channel == "default" then
        channel_ = "2097"
        state = "UPDATED"
        resul = true
    elseif channel == "guild" then
        channel_ = "GUILD"
        state = "UPDATED"
        resul = true
    elseif tonumber(channel) then
        local c = tonumber(channel)
        if GN.vo_designated_channels[c] then
            channel_ = GN.vo_designated_channels[c]
            state = "IGNORED"
            resul = false
        else
            channel_ = tostring(channel)
            state = "UPDATED"
            resul = true
        end
    else
        state = "CURRENT"
    end

    if resul then GN.battle_channel = channel_ end
    return resul, channel_, state
end

---END of BATTLE MODE

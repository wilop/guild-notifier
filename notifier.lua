local notify_queue = {}
local current = nil

---@class guild_member_added
GuildNotifier.guild_member_added = {}
---Send a notification when a guild member joins or is added.
---@param e string The event.
---@param charid integer The character ID.
---@param rank integer The rank of a guild member.
function GuildNotifier.guild_member_added:OnEvent(e, charid, rank)
    if e ~= "GUILD_MEMBER_ADDED" then return end
    if GuildNotifier.state == GuildNotifier.states["HIDDEN"] then return end
    if charid == nil or rank == nil then return end
    local name = GetPlayerName(charid) or ""
    local rank_ = GuildNotifier.guild_ranks[rank] or ""
    local msg = "\nJoined!"
    local icon = e
    GuildNotifier.push_notification(name, rank_, msg, icon) -- Arguments: title, subtitle, msg, icon
    GuildNotifier.play_sound(e)
end
RegisterEvent(GuildNotifier.guild_member_added, "GUILD_MEMBER_ADDED");

---@class guild_member_removed
GuildNotifier.guild_member_removed = {}
---Send a notification when a guild member joins or is removed.
function GuildNotifier.guild_member_removed:OnEvent(e, charid, reason)
    if e ~= "GUILD_MEMBER_REMOVED" then return end
    if GuildNotifier.state == GuildNotifier.states["HIDDEN"] then return end
    if charid == nil or reason == nil then return end
    local name = GetPlayerName(charid) or ""
    local reason_ = GuildNotifier.guild_removed_reasons[reason] or ""
    local msg = "\nBye!"
    local icon = e
    GuildNotifier.push_notification(name, reason_, msg, icon) -- Arguments: title, subtitle, msg, icon
    GuildNotifier.play_sound(e)
end
RegisterEvent(GuildNotifier.guild_member_removed, "GUILD_MEMBER_REMOVED");

---@class chatreceiver
GuildNotifier.chat_receiver = chatreceiver.OnEvent
---Receives messages from chat events
function chatreceiver:OnEvent(e, data)
    if GuildNotifier.gn_enable then
        if GuildNotifier.chat_events[e]  and not GuildNotifier.mode_battle then
            if data ~= nil and GuildNotifier.is_incoming(data.name) then
                local name = data.name or ""
                local charid = GetCharacterIDByName(name) or -1
                local guildtag = data.guildtag or GetGuildTag(charid) or ""
                local msg = data.msg or ""
                local icon = e
                if charid ~= -1 then
                    console_print("🔴 push_notification xpcall: ".. tostring(xpcall(GuildNotifier.push_notification, debug.traceback, name, guildtag, msg, icon)))
                end
            end
        console_print("🔴 play_sound xpcall: ".. tostring(xpcall(GuildNotifier.play_sound, debug.traceback, e)))
        end
    end
    GuildNotifier.chat_receiver(self, e, data)
end

---Verify if is an incoming or an outgoing notification.
---When testing mode is ON, it returns true.
---@param name string The player name who sent the message.
---@return boolean incoming Returns true if is incoming or false if not.
function GuildNotifier.is_incoming(name)
    if GuildNotifier.testing then return true end
    if GetPlayerName() == name then return false end
    return true
end

---Gets info about a player for help or as target.
---@param name string A player name.
---@return string name The player name.
---@return integer health The player health.
---@return string guildtag The guildtag of the player or "-" if player is not in a guild.
---@return string faction  The faction name of the player.
---@return string ship The players' primary ship.
---@return integer distance The randar distance in meters or -1 if player is out of radar.
function GuildNotifier.get_player_info(name)
    local name_ = name or GetPlayerName()
    local charid = GetCharacterIDByName(name_)
    local health = GetPlayerHealth(charid)
    local guildtag = GetGuildTag(charid) or "-"
    local faction = FactionName[GetPlayerFaction(charid)] or "-"
    local ship = GetPrimaryShipNameOfPlayer(charid) or "-"
    local distance = GetRadarDistance(charid)
    distance = distance or -1
    return name_, health, guildtag, faction, ship, distance
end

---Plays a notification sound effect.
---@param sound string The sound name associated to an event.
function GuildNotifier.play_sound(sound)
    if not GuildNotifier.gn_enable then return end
    if GuildNotifier.volume == 0 then
        return
    else
        gksound.GKLoadSound{soundname = sound, filename = GuildNotifier.sounds[sound]}
        gksound.GKPlaySound(sound, GuildNotifier.volume)
    end
end

---Pushes the notification into the message queue.
---Sets the wings, switches the gui to a new state and plays its sound effect.
---@param title string The title of the notification.
---@param subtitle string A subtitle.
---@param msg string The message body.
---@param icon string The icon name associated to an event.
function GuildNotifier.push_notification(title, subtitle, msg, icon)
    if not GuildNotifier.gn_enable then return end
    if GuildNotifier.state == GuildNotifier.states["HIDDEN"] then return end
    if not GuildNotifier:is_gui_ready() then return end

    if #notify_queue >= MAX_QUEUE then
        table.remove(notify_queue, 1)
    end

    table.insert(notify_queue, {
        title = tostring(title) or "",
        subtitle = tostring(subtitle) or "",
        msg = tostring(msg) or "",
        icon = icon,
    })
    GuildNotifier.reset_current_notification()
    if GuildNotifier.delay then
        if GuildNotifier.delay_timer and GuildNotifier.delay_timer:IsActive() then GuildNotifier.delay_timer:Kill() end
        GuildNotifier.delay_timer = Timer()
        GuildNotifier.delay_timer:SetTimeout(5000, function ()
            GuildNotifier.display_notification()
            GuildNotifier.delay = false
        end)
    else
        GuildNotifier.display_notification()
    end
end

---Displays the notifications in the gui.
function GuildNotifier.display_notification()
    if not current then
        GuildNotifier.next_notification()
        GuildNotifier.play_sound("ZOOM")
        if GuildNotifier.mode_battle then
            GuildNotifier:set_wings("BATTLE")
            GuildNotifier:set_gui_state("BATTLE")
        else
            GuildNotifier:set_wings("SHOWN")
            GuildNotifier:set_gui_state("SHOWN")
        end
    end
end

---Sets the next notification, sets the gui data and calls update_notification().
function GuildNotifier.next_notification()
    current = table.remove(notify_queue, 1)
    GuildNotifier:set_gui_data(current)
    GuildNotifier.update_notification()
end

---Update to the next notification.
---Calls next_notification() or switches the gui to "IDLE" and its sound effect.
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
            GuildNotifier:set_icon("IDLE")
            GuildNotifier:set_gui_state("IDLE")
        end
    end)
end

---Resets current notification if it was not displayed.
function GuildNotifier.reset_current_notification()
    if not current then return end
    table.insert(notify_queue, 1, current)
    current = nil
end

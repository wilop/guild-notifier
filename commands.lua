-- Manage GuildNotifier user commands.
function GuildNotifier.cmd(_,args)
    if type(args) ~= "table" or not args[1] then
        GuildNotifier.print_help()
        return
    end

    local cmd = args[1]:lower()
    if cmd == "on" then
        GuildNotifier.on()
    elseif cmd == "off" then
        GuildNotifier.off()
    elseif cmd == "info" then
        GuildNotifier.print_info()
    elseif cmd == "battle" then
        GuildNotifier.battle_mode()
    elseif cmd == "channel" then
        GuildNotifier.set_channel(args[2])
    elseif cmd == "sound" then
        GuildNotifier.sound_mode()
    elseif cmd == "vol" then
        GuildNotifier.set_volume(args[2])
    elseif cmd == "test" then
        GuildNotifier.test(args[2])
    else
        GuildNotifier.print_help()
    end
end

-- Show commands options and usage.
function GuildNotifier.print_help()
    print("Guild Notifier commands:")
    print("/gn on | off | info | sound | battle | channel | vol # (0-5) | test")
end
-- Show the plugin information.
function GuildNotifier.print_info()
    print("Guild Notifier:")
    print(tostring(GuildNotifier.info.description))
    print("By " .. tostring(GuildNotifier.info.author))
    print("At " .. tostring(GuildNotifier.info.Github))
    print("Version: " .. tostring(GuildNotifier.info.version))
end

-- Enable the Guild Notifier and show the gui.
function GuildNotifier.on()
    GuildNotifier.gn_enable = true
    GuildNotifier.state = GuildNotifier.states["HIDDEN"]
    if GuildNotifier:fade(50, "IDLE") then
        local vol = tostring(VOLUME) or "3"
        GuildNotifier.set_volume(vol)
        print("Guild Notifier: ON")
    end
end

-- Disable the Guild Notifier and hide the gui.
function GuildNotifier.off()
    GuildNotifier.gn_enable = false
    GuildNotifier.mode_sound = false
    GuildNotifier.mode_sound = false
    GuildNotifier:destroy_gui()
    GuildNotifier.set_volume("0")
    print("Guild Notifier: OFF")
end

-- Toggle battele mode.
function GuildNotifier.battle_mode()
   if not GuildNotifier.gn_enable then GuildNotifier.on() end
    GuildNotifier.mode_battle = not GuildNotifier.mode_battle
    local bstate = GuildNotifier.mode_battle and "ON" or "OFF"
    GuildNotifier.push_notification("Battle mode", bstate, "Only displays <<HELP>> and <<TARGETS>> notifcations!","IDLE")
end

---Set the chat channel for the battle mode.
---Avoid Vendetta Online designated channels.
---Check list here: https://www.vendetta-online.com/x/msgboard/1/13762
---@param channel string the channel to set.
function GuildNotifier.set_channel(channel)
    if not GuildNotifier.gn_enable then GuildNotifier.on() end
	local resul, channel_ = GuildNotifier.set_battle_channel(channel)
    local state = resul and "Changed!" or "Current"
    local msg = string.format("%s\nUsage: /gn channel default | guild | #\nExample: /gn channel 2097", channel_)
    GuildNotifier.push_notification("Battle mode channel", state, msg,"IDLE")
end

-- Toggle sound mode.
function GuildNotifier.sound_mode()
    if not GuildNotifier.gn_enable then GuildNotifier.on() end
    GuildNotifier.mode_sound = not GuildNotifier.mode_sound
    local state = GuildNotifier.mode_sound and "ON" or "OFF"
    local gui_state = GuildNotifier.mode_sound and "HIDDEN" or "IDLE"
    if GuildNotifier:fade(50, gui_state) then
        GuildNotifier.mode_battle = false
        local vol = tostring(VOLUME) or "3"
        GuildNotifier.set_volume(vol)
        print("Guild Notifier: Sound mode "..state)
        print("Just plays sounds!")
    end
end

-- Run different tests.
function GuildNotifier.test(t)
    if not GuildNotifier.gn_enable then
        print("Guild Notifier: OFF")
        print("Turn ON Guild Notifier to use test command.")
        return
    end
    if GuildNotifier.tests[t] then
        print(string.format("Guild Notifier: Running test %s ...[%s]",t ,GuildNotifier.tests[t].test ))
        GuildNotifier.tester(GuildNotifier.tests[t])
    else
        print("Guild Notifier: Running a test...(help)")
        print("Usage: /gn test # | 1 - 6")
        print("Example: /gn test 2")
    end
end

-- Call the send_target function.
function GuildNotifier.cmd_send_target()
    GuildNotifier.send_target()
end

-- Adjust or mute the volumen of the sounds effects.
function GuildNotifier.set_volume(v)
    if GuildNotifier.volume_levels[v] then
        GuildNotifier.volume = GuildNotifier.volume_levels[v]
        GuildNotifier.play_sound("CHAT_MSG_GUILD")
    else
        print("Guild Notifier: Set the volume level.")
        print("Usage: /gn vol # | 0 (mute) - 5 (max)")
        print("Example: /gn vol 3")
    end
end

-- Register and bind user commands.
RegisterUserCommand("gn", GuildNotifier.cmd)
RegisterUserCommand("gn_target", GuildNotifier.cmd_send_target)
gkinterface.BindCommand(gkinterface.GetInputCodeByName("0"), "gn_target")

---Manage the user commands
---@param _ any?
---@param args string[]
function GN.cmd(_, args)
    if type(args) ~= "table" or not args[1] then
        GN.print_help()
        return
    end

    local cmd = args[1]:lower()
    if cmd == "on" then
        GN.on()
    elseif cmd == "off" then
        GN.off()
    elseif cmd == "info" then
        GN.print_info()
    elseif cmd == "sound" then
        GN.sound_mode()
    elseif cmd == "battle" then
        GN.battle_mode()
    elseif cmd == "channel" then
        GN.set_channel(args[2])
    elseif cmd == "storm" then
        GN.storm()
    elseif cmd == "extra" then
        GN.extra()
    elseif cmd == "vol" then
        GN.set_volume(args[2])
    elseif cmd == "test" then
        GN.test(args[2])
    else
        GN.print_help()
    end
end
---@end

---Show commands options and usage.
function GN.print_help()
    print("Guild Notifier commands:")
    print("/gn (on | off | info | sound | battle | channel | storm | extra | vol # (0-5) | test)")
end

---Show the plugin information.
function GN.print_info()
    print("Guild Notifier:")
    print(tostring(GN.info.description))
    print("By " .. tostring(GN.info.author))
    print("At " .. tostring(GN.info.Github))
    print("Version: " .. tostring(GN.info.version))
end

---Enable the Guild Notifier and turn it on.
function GN.on()
    GN.gn_enable = true
    GN:init_gui_data()
    GN.state = GN.states["HIDDEN"]
    if GN:set_gui_state("SHOWN") then
        local vol = tostring(VOLUME) or "3"
        GN.set_volume(vol)
        print("Guild Notifier: ON")
        GN:set_gui_state("IDLE")
    end
end

---Disable the Guild Notifier and turn it off, reset all states.
function GN.off()
    GN.gn_enable = false
    GN.mode_sound = false
    GN.mode_sound = false
    GN.extra_notifications = false
    GN:hide()
    GN.set_volume("0")
    print("Guild Notifier: OFF")
end

---Toggle (on | off) battle mode.
---Battle mode displays HELP, TARGET and Guild's activity notifications.
function GN.battle_mode()
   if not GN.gn_enable then GN.on() end
    GN.mode_battle = not GN.mode_battle
    local bstate = GN.mode_battle and "ON" or "OFF"
    GN.push_notification("Battle mode", bstate, "Only displays <<HELP>> and <<TARGETS>> notifcations!","IDLE")
end

---Set the chat channel for the battle mode.
---Avoid Vendetta Online designated channels.
---Check list here: https://www.vendetta-online.com/x/msgboard/1/13762
---@param channel string the channel to set.
function GN.set_channel(channel)
    if not GN.gn_enable then GN.on() end
	local _, channel_, state = GN.set_battle_channel(channel)
    local msg = string.format("%s\nUsage: /gn channel (default | guild | #)\nExample: /gn channel 2097", channel_)
    GN.push_notification("Battle mode channel", state, msg,"IDLE")
end

---Toggle (on | off) sound mode.
---Just plays sounds notifications and hides the gui.
function GN.sound_mode()
    if not GN.gn_enable then GN.on() end
    GN.mode_sound = not GN.mode_sound
    local state = GN.mode_sound and "ON" or "OFF"
    local gui_state = GN.mode_sound and "HIDDEN" or "IDLE"
    if GN:set_gui_state(gui_state) then
        GN.mode_battle = false
        local vol = tostring(VOLUME) or "3"
        GN.set_volume(vol)
        print("Guild Notifier: Sound mode "..state)
        print("Just plays sounds!")
    end
end

---Toggle (on | off) ion storms notifications.
function GN.storm()
	if not GN.gn_enable then GN.on() end
    GN.storms = not GN.storms
    local state = GN.storms and "ON" or "OFF"
    local msg = "Reports and Receives iom storm notifications\nUsage: /gn storm"
    GN.push_notification("Storms notifications", state, msg,"IDLE")
    GN.load_storm_reports()
end

---Toggle (on | off) extra notifications (TARGET and HELP) in normal mode.
function GN.extra()
	if not GN.gn_enable then GN.on() end
    GN.extra_notifications = not GN.extra_notifications
    local state = GN.extra_notifications and "ON" or "OFF"
    local msg = "TARGET & HELP\nUsage: /gn extra"
    GN.push_notification("Extra notifications", state, msg,"IDLE")
end

---Run different tests.
---@param t string a key of the test ().
function GN.test(t)
    if not GN.gn_enable then
        print("Guild Notifier: OFF")
        print("Turn ON Guild Notifier to use test command.")
        return
    end
    if GN.tests[t] then
        print(string.format("Guild Notifier: Running test %s ...[%s]",t ,GN.tests[t].test ))
        GN.tester(GN.tests[t])
    else
        print("Guild Notifier: Running a test...(help)")
        print("Usage: /gn test # (1 - 7)")
        print("Example: /gn test 2")
    end
end

---Call the send_target function.
function GN.cmd_send_target()
    GN.send_target()
end

---Adjust or mute the volumen of the sounds effects.
---@param v string The volumen level (its a number)
function GN.set_volume(v)
    if GN.volume_levels[v] then
        GN.volume = GN.volume_levels[v]
        GN.play_sound("CHAT_MSG_GUILD")
    else
        print("Guild Notifier: Set the volume level.")
        print("Usage: /gn vol # (0: mute - 5: max)")
        print("Example: /gn vol 3")
    end
end

---Enable testing mode. Receives notifications for outgoing messages.
---@param enable boolean True to enable testing mode, false to disable (default false).
function GN.testing_mode()
    if not GN.gn_enable then GN.on() end
        GN.testing = not GN.testing
        local state = GN.testing and "ON" or "OFF"
        local msg = "\nReceives notifications for outgoing messages"
        GN.push_notification("Testing mode", state, msg,"IDLE")
end

---@section Register and bind user commands.
RegisterUserCommand("gn", GN.cmd)
RegisterUserCommand("gn_target", GN.cmd_send_target)
RegisterUserCommand("gn_testing", GN.testing_mode)
gkinterface.BindCommand(gkinterface.GetInputCodeByName("0"), "gn_target")
---@end

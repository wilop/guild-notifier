---Trigger the events and test the notifications
---@param data table Data with a test name and a message.
function GN.tester(data)
    if not GN.gn_enable then return end
    if data == nil then return end
    local test = data.test

    if GN.chat_events[test] then print("This test requires battle mode OFF.") end
    if GN.battle_events[test] then print("This test requires battle mode ON.") end
    if GN.common_events[test] then print("This test works with battle mode ON and OFF.") end

    local name, _, guildtag = GN.get_player_info()
    local sound = data.test
    local icon =  data.test
    local msg = data.msg

    if test == "HELP" then
        ProcessEvent(test, {name = name, msg = data.msg})
    elseif test == "TARGET" then
        ProcessEvent(test, data.msg)
    elseif test == "GUILD_MEMBER_ADDED" then
        local charid = GetCharacterIDByName(name)
        ProcessEvent(test, charid, 0)
    else
        console_print("🔴 push_notification xpcall: ".. tostring(xpcall(GN.push_notification, debug.traceback, name, guildtag, msg, icon)))
        console_print("🔴 play_sound xpcall: ".. tostring(xpcall(GN.play_sound, debug.traceback, sound)))
    end
end

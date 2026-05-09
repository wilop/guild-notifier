-- Trigger the events and test the notifications
function GuildNotifier.tester(data)
    if data == nil then return end
    local test = data.test

    if GuildNotifier.chat_events[test] then print("This test requires battle mode OFF.") end
    if GuildNotifier.battle_events[test] then print("This test requires battle mode ON.") end
    if GuildNotifier.common_events[test] then print("This test works with battle mode ON and OFF.") end

    local name, _, guildtag = GuildNotifier.get_player_info()
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
        console_print("🔴 push_notification xpcall: ".. tostring(xpcall(GuildNotifier.push_notification, debug.traceback, name, guildtag, msg, icon)))
        console_print("🔴 play_sound xpcall: ".. tostring(xpcall(GuildNotifier.play_sound, debug.traceback, sound)))
    end
end

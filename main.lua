

declare ('GN', GN or {})

GN.info = {
    description = "Guild Notifier: notifications for yout incoming messages.",
    author = "Otesten Vanar (wilop)",
    Github = "https://github.com/wilop/guild-notifier",
    version = "1.0.0-HEAD",
}

dofile("config.lua")

if AUTOLOGIN and USERNAME and PASSWORD then
    Login(USERNAME, PASSWORD)
end

if GN_ENABLE then
    dofile("definitions.lua")
    dofile("gui.lua")
    dofile("notifier.lua")
    dofile("battle.lua")
    dofile("storm.lua")
    dofile("tester.lua")
    dofile("commands.lua")
end


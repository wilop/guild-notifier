-- GuildNotifier settings.

-- Usage: type the command "/gn" in your chat console to display the options.

-- This plugin shows notifications for your incoming messages from guild's members, groups or private messages.
-- The plugin can play a sound with your notification and also provides an AUTOLOGIN function.

-- Set GN_ENABLE = true to enable Notifications, or set GN_ENABLE = false to disable notifications.
GN_ENABLE = true

-- Set the notification duration time, default 5 (seconds).
TIMEOUT = 5

-- Set the maximum number of notifications, default 10.
MAX_QUEUE = 10

-- Set VOLUME from 0 [mute] to 5 [max], default 3.
VOLUME = 3

--  Set your profile and guild own icons
PROFILE_ICON = "plugins/guild-notifier/assets/profile_icon.png"
GUILD_ICON = "plugins/guild-notifier/assets/guild_icon.png"

-- Set AUTOLOGIN = true, USERNAME = "YourUsername" and PASSWORD = "YourPassword" or keep AUTOLOGIN = false if you don't need AUTOLOGIN.
AUTOLOGIN = false
USERNAME = ""
PASSWORD = ""

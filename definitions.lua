---@section assets path to assets files
local assets_path = "plugins/guild-notifier/assets/"
local textures = assets_path .. "textures/"
local icons = assets_path .. "icons/"
local sounds = assets_path .. "sounds/"
---@end

---@section settings Settings and global vars.
GN.gn_enable = GN_ENABLE
GN.volume = VOLUME * 0.2 or 0.6
GN.mode_battle = false
GN.mode_sound = false
GN.state = 0
GN.battle_channel = 2097
GN.battle_destiny = "CHANNEL"
GN.extra_notifications = false
GN.storms = false
GN.testing = false
---@end

---Gui states.
GN.states = {
    ["HIDDEN"] = -1,
    ["IDLE"] =  0,
    ["SHOWN"] = 1,
    ["BATTLE"] = 2,
}

---Volume levels.
GN.volume_levels = {
    ["0"] = 0.0,
    ["1"] = 0.2,
    ["2"] = 0.4,
    ["3"] = 0.6,
    ["4"] = 0.8,
    ["5"] = 1.0,
}

---Chat events for notifications.
GN.chat_events = {
    ["CHAT_MSG_PRIVATE"] = true,
    ["CHAT_MSG_GROUP"] = true,
    ["CHAT_MSG_GUILD"] = true,
}

---Chat events for battle notifications.
GN.battle_chat_events = {
    ["CHAT_MSG_CHANNEL_EMOTE"] = true,
    ["CHAT_MSG_GUILD_EMOTE"] = true,
}

---Battle events.
GN.battle_events = {
    ["HELP"] = true,
    ["TARGET"] = true,
}

---Guild activity events.
GN.common_events = {
    ["GUILD_MEMBER_ADDED"] = true,
    ["GUILD_MEMBER_REMOVED"] = true,
    ["STORM"] = true,
    ["ZOOM"] = true,
    ["IDLE"] = true,
}

---Reason to remove a guild member.
GN.guild_removed_reasons = {
    [0] = "Log off",
    [1] = "Resign",
    [2] = "Kicked out!",
    [3] = "Voted our!",
}

---Rank of a guild member.
GN.guild_ranks = {
    [0] = "Member",
    [1] = "Lieutenant",
    [2] = "Council member",
    [3] = "Council member & Lieutenant",
    [4] = "Commander",
}

---Sound names and their paths.
GN.sounds = {
    ["CHAT_MSG_PRIVATE"] = sounds.."private.wav",
    ["CHAT_MSG_GROUP"] = sounds.."group.wav",
    ["CHAT_MSG_GUILD"] = sounds.."guild.wav",
    ["GUILD_MEMBER_ADDED"] = sounds.."guild.wav",
    ["GUILD_MEMBER_REMOVED"] = sounds.."guild.wav",
    ["HELP"] = sounds.."help.wav",
    ["STORM"] = sounds.."help.wav",
    ["TARGET"] = sounds.."target.wav",
    ["ZOOM"] = sounds.."zoom.wav",
}

---Wing mode textures and their paths.
GN.wings = {
    ["SHOWN"] = {left = textures.."wing_left.png", right = textures.."wing_right.png"},
    ["BATTLE"] = {left = textures.."wing_battle_left.png", right = textures.."wing_battle_right.png"},
}

---Icon names and their paths.
GN.icons = {
    ["CHAT_MSG_PRIVATE"] =  icons.."msg_private.png",
    ["CHAT_MSG_GROUP"] = icons.."msg_group.png",
    ["CHAT_MSG_GUILD"] = icons.."msg_guild.png",
    ["GUILD_MEMBER_ADDED"] = GUILD_ICON,
    ["GUILD_MEMBER_REMOVED"] = GUILD_ICON,
    ["HELP"] = icons.."help.png",
    ["STORM"] = icons.."storm.png",
    ["TARGET"] = icons.."target.png",
    ["IDLE"] = PROFILE_ICON,
}

---Test and data for each test.
GN.tests = {
    ["1"] = {test = "CHAT_MSG_PRIVATE", msg = "A private test message"},
    ["2"] = {test = "CHAT_MSG_GROUP", msg = "A group test message"},
    ["3"] = {test = "CHAT_MSG_GUILD", msg = "A guild test message"},
    ["4"] = {test = "GUILD_MEMBER_ADDED", msg = "Test, member joined"},
    ["5"] = {test = "STORM", msg = "STORM(2725): Artana Anquillus E-11"},
    ["6"] = {test = "HELP", msg = "HELP:2903"},
    ["7"] = {test = "TARGET", msg = "target=*Data Dotos|health=100|distance=1331|faction=Itani|guild=|ship=Centaur|sector=2903"},
}

---Designated Vendetta Online channel to ignore.
---Check the full list here: https://www.vendetta-online.com/x/msgboard/1/13762
GN.vo_designated_channels = {
    [1] =  "Help Chat",
    [70] =  "German Chat",
    [97] =  "Windows Users",
    [98] =  "Linux Users",
    [99] =  "Apple Macintosh user",
    [100] =  "General Chat",
    [101] =  "French Chat",
    [102] =  "Russian Chat",
    [103] =  "Spanish Chat",
    [104] =  "Dutch Chat",
    [105] =  "Norwegian Chat",
    [106] =  "Finnish Chat",
    [111] =  "Help Chat 2",
    [113] =  "Spanish Chat 2",
    [911] =  "Emergency Chat",
}

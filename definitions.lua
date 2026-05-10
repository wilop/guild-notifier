-- assets paths
local assets_path = "plugins/guild-notifier/assets/"
local textures = assets_path .. "textures/"
local icons = assets_path .. "icons/"
local sounds = assets_path .. "sounds/"

GuildNotifier.gn_enable = GN_ENABLE
GuildNotifier.volume = VOLUME * 0.2 or 0.6
GuildNotifier.mode_battle = false
GuildNotifier.mode_sound = false
GuildNotifier.state = 0
GuildNotifier.battle_channel = "2097"
GuildNotifier.extra_notifications = false

GuildNotifier.states = {
    ["HIDDEN"] = -1,
    ["IDLE"] =  0,
    ["SHOWN"] = 1,
    ["BATTLE"] = 2,
}

GuildNotifier.volume_levels = {
    ["0"] = 0.0,
    ["1"] = 0.2,
    ["2"] = 0.4,
    ["3"] = 0.6,
    ["4"] = 0.8,
    ["5"] = 1.0,
}

GuildNotifier.chat_events = {
    ["CHAT_MSG_PRIVATE"] = true,
    ["CHAT_MSG_GROUP"] = true,
    ["CHAT_MSG_GUILD"] = true,
}

GuildNotifier.battle_chat_events = {
    ["CHAT_MSG_CHANNEL_EMOTE"] = true,
    ["CHAT_MSG_GUILD_EMOTE"] = true,
}

GuildNotifier.battle_events = {
    ["HELP"] = true,
    ["TARGET"] = true,
}

GuildNotifier.common_events = {
    ["GUILD_MEMBER_ADDED"] = true,
    ["GUILD_MEMBER_REMOVED"] = true,
    ["ZOOM"] = true,
    ["IDLE"] = true,
}

GuildNotifier.guild_removed_reasons = {
    [0] = "Log off",
    [1] = "Resign",
    [2] = "Kicked out!",
    [3] = "Voted our!",
}

GuildNotifier.guild_ranks = {
    [0] = "Member",
    [1] = "Lieutenant",
    [2] = "Council member",
    [3] = "Council member & Lieutenant",
    [4] = "Commander",
}

GuildNotifier.sounds = {
    ["CHAT_MSG_PRIVATE"] = sounds.."private.wav",
    ["CHAT_MSG_GROUP"] = sounds.."group.wav",
    ["CHAT_MSG_GUILD"] = sounds.."guild.wav",
    ["GUILD_MEMBER_ADDED"] = sounds.."guild.wav",
    ["GUILD_MEMBER_REMOVED"] = sounds.."guild.wav",
    ["HELP"] = sounds.."help.wav",
    ["TARGET"] = sounds.."target.wav",
    ["ZOOM"] = sounds.."zoom.wav",
}

GuildNotifier.wings = {
    ["SHOWN"] = {left = textures.."wing_left.png", right = textures.."wing_right.png"},
    ["BATTLE"] = {left = textures.."wing_battle_left.png", right = textures.."wing_battle_right.png"},
}

GuildNotifier.icons = {
    ["CHAT_MSG_PRIVATE"] =  icons.."msg_private.png",
    ["CHAT_MSG_GROUP"] = icons.."msg_group.png",
    ["CHAT_MSG_GUILD"] = icons.."msg_guild.png",
    ["GUILD_MEMBER_ADDED"] = GUILD_ICON,
    ["GUILD_MEMBER_REMOVED"] = GUILD_ICON,
    ["HELP"] = icons.."help.png",
    ["TARGET"] = icons.."target.png",
    ["IDLE"] = PROFILE_ICON,
}

GuildNotifier.tests = {
    ["1"] = {test = "CHAT_MSG_PRIVATE", msg = "A private test message"},
    ["2"] = {test = "CHAT_MSG_GROUP", msg = "A group test message"},
    ["3"] = {test = "CHAT_MSG_GUILD", msg = "A guild test message"},
    ["4"] = {test = "GUILD_MEMBER_ADDED", msg = "Test, member joined"},
    ["5"] = {test = "HELP", msg = "HELP:2903"},
    ["6"] = {test = "TARGET", msg = "target=*Data Dotos|health=100|distance=1331|faction=Itani|guild=|ship=Centaur|sector=2903"},
}


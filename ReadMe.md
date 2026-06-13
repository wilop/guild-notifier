# GuildNotifier
An Unofficial plugin for [__Vendetta Online__](https://www.vendetta-online.com/).

___GuildNotifier___ displays a `HUD` notification for your incoming messages.

Created by _Otesten Vanar_, a member of [__U.S.D.S.__](https://www.vendetta-online.com/x/guildinfo/551/ "Union of the Saving Darkness in the Stars").

![Guild Notifier](./assets/guild-notifier.png)

## Features:
- Shows notifications for your incoming messages from guild's members, groups or private messages.
- Shows notifications for guild members activity (logon, logoff, etc).
- Send help messages and target information.
- Plays a sound with your notification.
- Provides an AUTOLOGIN function.

## Download, install and support.
To install the plugin follow the instructions in [Vendetta Wiki](https://www.vo-wiki.com/wiki/Plug-ins). 
To download, share comments, ideas or ask for help follow the [links](#Links) at the bottom of this document. 

## Usage:
| Command       |                                                                |
|---------------|----------------------------------------------------------------|
| /gn           | Show options.                                                  |
| /gn on        | Turn on Guild Notifier.                                        |
| /gn off       | Turn off Guild Notifier.                                       |
| /gn info      | Show info about this plugin.                                   |
| /gn sound     | Toggle (on - off) sound mode (just plays sounds).              |
| /gn battle    | Toggle (on - off) battle mode (HELP and TARGET notifications). |
| /gn channel   | Set the chat channel for battle mode.                          |
| /gn storm     | Toggle (on - off) storm reports.                               |
| /gn extra     | Toggle (on - off) extra notifications to normal mode.          |
| /gn vol       | Adjust or mute the volume (0:mute - 5:max).                    |
| /gn test      | Send test notifications (1 - 7).                               |

## Battle mode and sound mode.
In battle mode you will ___only___ see `HELP` and `TARGET` notifications. a "HELP" message will be sent automatically when you got hit and your health is lower than 50%. A message with "target's" info will be sent when you press key "0" or when you use `gn_target` command.  

The options to chat channel for battle mode area "default" (2097), "guild" or any other channel (Example /gn channel 8020). Choose an unused one; most used channels are filtered. All channels can be monitored by everyone; the "guild" channel just for guild members.

Sound mode hides the gui and just plays a sound when you receive notifications.

## Extra notifications and storm reports.
When extra notifications is "on" it is possible to send en receive `HELP` and `TARGET` notifications in "normal" mode.  

If storm is "on", the player reports and receives storms notifications (`Storm` or `Clear`). The default channel for storm reports is 2096, everyone monitoring this channel can see the reports in the chat. Reports appears in Navmap as system notes and are saved to file; all reports older than 6 hours are not loaded from file.

## About config and media files.
To disable notifications (permanently) or disable AUTOLOGIN and other settings, edit `config.lua`.  
Supported files extensions for icons are `*.jpg` and `*.png` and dimensions of _128x128_ or _64x64_. For sounds use `*.wav` or `*.ogg`.   

NOTE: Sounds need to be encoded to 44100 Hz, stereo, s16, 1411 kb/s

## Disclaimer.
___GuildNotifier___  works only on the client side. The plugin does not share any kind of user data or sensitive information with other players.

## License.
> [MIT](./LICENSE)

## Author
> _Otesten Vanar_ ([wilop](https://github.com/wilop)).

## Testers.
> ___Windows:___  
> _Commander Azryayix Gyarz._  

> ___Android:___  
> _Cerys An Scath._  

## Credits:
> ___Commander Azryayix Gyarz___:  
- Original guild icon.  
 ![GUILD ICON](./assets/guild0.png)
 
> _[MixKit](https://mixkit.co/free-sound-effects/):_  
- Sound Effect "help" (Technology computer calculations).  
- Sound Effect "group" (Retro game notification).  
- Sound Effect "guild" (Technology notification).  
- Sound Effect "private" (​High tech ​bleep ​confirmation).  
- Sound Effect "target" (Sci-fi confirmation).  
- Sound Effect "zoom" (Alien technology button).  

----

## Links
| [Download](https://github.com/wilop/guild-notifier/releases) | [Discussions](https://github.com/wilop/guild-notifier/discussions) | [Issues](https://github.com/wilop/guild-notifier/issues) |
|-----------------|-----------------|-----------------|
|Download here | Share ideas or make questions | Report issues |

# BattlegroundMaster

A World of Warcraft addon to enhance battleground queuing and management, with a focus on automating Wintergrasp participation.

## Version
- **1.5** (Released: June 07, 2025)

## Description
BattlegroundMaster v1.5 is an upgraded version of the addon, offering improved automation for Wintergrasp queuing and enhanced user control. This release removes redundant polling, relies on a refined `StaticPopup_Show` hook to handle queue acceptance (supporting both "Accept" and "Okay" buttons), and ensures debug mode respects user settings. It retains core features like auto-requeue, detailed statistics, and a movable GUI, making it a must-have for battleground players, especially those targeting Wintergrasp.

## Features
- **Wintergrasp Auto-Queue**: Automatically joins and accepts Wintergrasp queues when in the Wintergrasp zone.
- **Auto-Requeue**: Optionally requeues for battlegrounds after a match ends, with per-BG customization.
- **Session & Lifetime Stats**: Tracks honor, kills, wins, and losses with easy reset options.
- **Custom GUI**: Movable interface to manage queues and settings.
- **Command Support**: Slash commands (`/bm` or `/battlegroundmaster`) for quick access.
- **Debug Mode**: Toggleable debug output for troubleshooting (now respects settings).

## Installation
1. Download the latest release from the [Releases](https://github.com/realstyla23/BattlegroundMaster/releases) page.
2. Extract the `BattlegroundMaster` folder to your World of Warcraft `_retail_/Interface/AddOns/` directory.
3. Log in to WoW, enable the addon in the AddOn selection screen, and reload your UI with `/reload`.

## Usage
- **Toggle GUI**: `/bm` or left-click the minimap icon.
- **Queue for BG**: `/bm <av|wsg|ab|eots|sota|ioc|random|wintergrasp>` (e.g., `/bm wintergrasp`).
- **Manual Accept**: `/bm joinwintergrasp` during a Wintergrasp prompt.
- **Settings**: `/bm config` to open the settings panel.
- **Stats**: `/bm stats` (session) or `/bm lifetimestats` (lifetime).

## Commands
- `/bm` - Toggle the GUI.
- `/bm av|wsg|ab|eots|sota|ioc|random|wintergrasp` - Join/leave the specified battleground.
- `/bm joinwintergrasp` - Manually accept a Wintergrasp queue prompt.
- `/bm list` - Show active queues.
- `/bm autorequeue` - Toggle auto-requeue.
- `/bm stats` - Display session stats.
- `/bm lifetimestats` - Display lifetime stats.
- `/bm resetstats` - Reset session stats.
- `/bm config` - Open settings panel.

## Changelog
### Version 1.5 (June 07, 2025)
- Removed redundant polling mechanism for Wintergrasp auto-accept.
- Enhanced `StaticPopup_Show` hook to support "Accept" and "Okay" buttons, fixing acceptance on servers like Warmane.
- Fixed debug mode to respect the settings toggle, eliminating unwanted debug output.
- Maintained all previous functionality (auto-requeue, GUI, stats).

### Version 1.4 (Previous Release)
- Initial Wintergrasp auto-queue implementation with polling.
- Added debug logging and GUI enhancements.

### Version 1.3 (Previous Release)
- Settings Panel Fix and GUI Improvements

### Version 1.2 (Previous Release)
- added Settings Panel some minor fixes

### Version 1.1 (Previous Release)
- added GUI and stat tracking

### Version 1.0 (Previous Release)
- initial release only had Auto-Queue for BGs. no GUI only commands. Winergrasp was not reliable

## Known Issues
- No known issues in v1.5. Report any bugs via GitHub Issues.

## Contributing
Fork the repository, make changes, and submit a pull request. Ensure compatibility with the latest WoW patch.

## License
[MIT License](LICENSE) - Feel free to modify and distribute, but keep the license intact.

## Credits
- Developed by [shadowsinyou @ Warmane]
- Thanks to the WoW addon community for inspiration and support.

## Support
- Report issues or suggest features on the [GitHub Issues](https://github.com/yourusername/BattlegroundMaster/issues) page.

---


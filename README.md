# BattlegroundMaster

## Overview
BattlegroundMaster is a World of Warcraft addon designed to simplify battleground queuing and management. It provides a user-friendly GUI to join, leave, and auto-requeue for various battlegrounds, including Wintergrasp, with customizable settings.

## Features
- Queue for specific battlegrounds (Alterac Valley, Warsong Gulch, Arathi Basin, etc.) or random BG.
- Auto-requeue option for seamless gameplay.
- Wintergrasp auto-queue support when in the Wintergrasp zone.
- Display active queues, session stats, lifetime stats, and reset options.
- Open settings panel for configuration.

## Installation
1. Download the latest release from the [Releases](https://github.com/realstyla23/BattlegroundMaster/releases) section.
2. Extract the `BattlegroundMaster` folder to your World of Warcraft `_retail_/Interface/AddOns/` directory.
3. Log in to WoW, ensure the addon is enabled in the AddOns menu, and use `/bm` to open the GUI.

## Usage
- **Open GUI**: Type `/bm` in chat.
- **Queue for BG**: Click a battleground button or use `/bm [bg]` (e.g., `/bm av` for Alterac Valley).
- **Auto-Requeue**: Enable the "Auto Re-Queue" checkbox to automatically requeue after a match.
- **Wintergrasp**: Enable "Wintergrasp Queue" in Wintergrasp zone for auto-accept.
- **Commands**:
  - `/bm` - Toggle GUI
  - `/bm av`, `/bm wsg`, etc. - Queue for specific BG
  - `/bm joinwintergrasp` - Manually accept Wintergrasp queue
  - `/bm list` - Show active queues
  - `/bm autorequeue` - Toggle auto-requeue
  - `/bm stats` - Show session stats
  - `/bm lifetimestats` - Show lifetime stats
  - `/bm resetstats` - Reset session stats
  - `/bm config` - Open settings panel

## Changelog
### [Latest Update - June 05, 2025]
- Moved "BattlegroundMaster" title higher for better GUI alignment.
- Increased button width to 180 pixels to fit longer names (e.g., "Random Battleground", "Strand of the Ancients").
- Updated frame size to 420x300 for a wider and shorter layout.
- Ensured all functionality remains intact with the new layout.

## Contributing
Feel free to submit issues or pull requests on the [GitHub repository](https://github.com/realstyla23/BattlegroundMaster). Contributions are welcome!

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgements
- Thanks to the WoW addon community for inspiration and support.
- Special thanks to contributors and testers for feedback.
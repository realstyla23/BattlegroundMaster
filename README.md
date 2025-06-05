BattlegroundMaster

Overview

BattlegroundMaster is a World of Warcraft addon designed for WoW 3.3.5a (Wrath of the Lich King) to automate and simplify battleground queue management. It offers features like auto-requeue, session stat tracking, and a user-friendly GUI, making your PvP experience smoother and more efficient.

Features





Automated Queuing: Queue for battlegrounds directly from a GUI or via chat commands (/bm <bg>).



Auto-Requeue: Automatically requeue for battlegrounds after a match ends, with configurable delays and per-BG settings.



Wintergrasp Auto-Queue: Automatically join Wintergrasp queues when in the zone, with support for auto-accepting prompts.



Session Stats Tracking: Track honor, kills, wins, and losses for your session, with options to view and reset stats.



Minimap Button: Toggle the GUI with a minimap button, customizable via settings.



GUI Interface: A clean, draggable GUI to manage settings, queue for BGs, and view stats.



Settings Panel: Configure options via Blizzard’s Interface Options (/bm config).



Debug Mode: Optional debug logging for troubleshooting.

Installation





Download the latest release from GitHub.



Extract the BattlegroundMaster folder to your WoW Interface\AddOns\ directory.



Launch WoW, enable the addon in the character selection screen, and enjoy!

Usage





Toggle GUI: Use /bm to open/close the GUI.



Queue for a BG: Use /bm <bg> (e.g., /bm av for Alterac Valley) or click a BG button in the GUI.



List Active Queues: Use /bm list or the "List Active Queues" button in the GUI.



Auto-Requeue: Enable via the GUI checkbox or /bm autorequeue.



Wintergrasp Auto-Queue: Enable via the GUI checkbox; works only in Wintergrasp zone.



View Stats: Use /bm stats or the "Show Session Stats" button.



Reset Stats: Use /bm resetstats or the "Reset Session Stats" button.



Open Settings: Use /bm config or the "Open Settings" button to access the settings panel.



Supported BGs: Alterac Valley (av), Warsong Gulch (wsg), Arathi Basin (ab), Eye of the Storm (eots), Strand of the Ancients (sota), Isle of Conquest (ioc), Random BG (random), Wintergrasp (wintergrasp).

Version 1.3 Changelog





Settings Panel Fix: Resolved issues with the settings panel not opening by adding delayed registration and ensuring all Ace3 dependencies are included (AceConfigRegistry-3.0 and AceConfigCmd-3.0).



GUI Improvements: Adjusted frame size to 300x500 and increased button spacing for better visibility.



Bug Fixes: Fixed library path issues in the .toc file to match the updated folder structure.



Stability Enhancements: Added debug checks to confirm settings panel registration.

Dependencies





Ace3 libraries (included in the Libs folder):





LibStub



CallbackHandler-1.0



AceAddon-3.0



AceConsole-3.0



AceEvent-3.0



AceDB-3.0



AceTimer-3.0



AceGUI-3.0



AceConfig-3.0 (with AceConfigRegistry-3.0 and AceConfigCmd-3.0)



AceConfigDialog-3.0



LibDBIcon-1.0



LibDataBroker-1.1

Known Issues





Wintergrasp auto-queue requires you to be in the Wintergrasp zone to function.



Auto-requeue skips if you have the Deserter debuff or are in an active battlefield.

Contributing

Feel free to fork this repository, make improvements, and submit pull requests. Bug reports and feature requests are welcome via GitHub Issues.

License

This addon is released under the MIT License. See the LICENSE file for details.

Credits





Author: Shadowsinyou



Libraries: Thanks to the Ace3 team and contributors for their amazing libraries.
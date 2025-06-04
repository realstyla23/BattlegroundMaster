BattlegroundMaster

A World of Warcraft (3.3.5a) addon to automate battleground queue management, including auto-queueing for Wintergrasp.

Features





Auto-queue for Wintergrasp: Automatically queues for Wintergrasp when in the zone (if enabled).



Auto-requeue for Battlegrounds: Automatically re-queues for the last battleground after it ends (if enabled).



GUI for Easy Management: A user-friendly interface to manage battleground queues with buttons for each battleground.



Slash Commands: Quick commands for controlling the addon, queuing, and viewing stats.



Session Stats Tracking: Tracks honor and kills per session, with options to view and reset stats.



Minimap Integration: Adds a minimap icon for quick access to the GUI.



Streamlined Output: Minimal chat feedback for a cleaner experience, showing only essential information like queued battlegrounds and auto-requeue status.

Installation





Copy the BattlegroundMaster folder into your WoW Interface/AddOns directory.



Enable the addon in the WoW character select screen.



Use /bm in-game to open the GUI or click the minimap icon.

Commands





/bm - Toggle the GUI.



/bm <bgKey> - Join/Leave a battleground (e.g., /bm ab for Arathi Basin, /bm random for Random Battleground). Supported keys: av, wsg, ab, eots, sota, ioc, random.



/bm joinwintergrasp - Manually accept Wintergrasp queue.



/bm list - Show active queues.



/bm autorequeue - Toggle auto-requeue for battlegrounds.



/bm stats - Show session honor and kills.



/bm resetstats - Reset session stats.

Changelog

Version 1.1 (June 2025)





Auto-Requeue Fix: Updated auto-requeue to re-run the original manual command (e.g., /bm ab) after a battleground ends, ensuring compatibility with custom servers where the PvP frame UI behaves differently. Now reliably re-queues after a 5-second delay.



Streamlined Chat Output: Reduced verbose debug messages. Now only shows essential feedback, such as:





"Set lastQueuedBG to [BG]" when queuing.



"|cff[COLOR][BG]|r" to confirm successful queuing.



"Auto-requeue for [BG] in 5 seconds..." when auto-requeue triggers.



Improved Wintergrasp Auto-Queue:





Added robust detection using both polling and event-based methods (CHAT_MSG_BG_SYSTEM_NEUTRAL and UPDATE_BATTLEFIELD_STATUS) to ensure Wintergrasp queues are accepted instantly.



Added zone validation to prevent queuing outside Wintergrasp.



Code Optimization:





Removed duplicate event handling between core.lua and BattlegroundMaster.lua.



Centralized battleground-specific logic in BattlegroundMaster.lua, leaving core.lua for addon initialization and stats tracking.



Enhanced Reliability:





Added safety checks (e.g., UnitInBattleground, GetBattlefieldStatus) to prevent queuing in invalid states.



Improved FindAndClickScroll with a retry limit to avoid infinite recursion when searching for battlegrounds in the PvP frame.



GUI Improvements:





Added "List Active Queues" button to the GUI for easier queue management.



Ensured GUI checkboxes (e.g., auto-requeue) sync with slash commands.

Version 1.0 (Initial Release)





Initial release with basic features: Wintergrasp auto-queue, GUI, slash commands, and session stats tracking.

Credits





Developed with contributions from the WoW addon community.



Special thanks to users on GitHub for feedback and testing.

License

This addon is released under the MIT License. See the LICENSE file for details.
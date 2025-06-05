BattlegroundMaster

A World of Warcraft (3.3.5a) addon designed to streamline battleground queue management, including auto-queueing for Wintergrasp. Simplify your PvP experience with automated queuing, session stats tracking, and an intuitive GUI.
Features

    Auto-Queue for Wintergrasp: Automatically joins the Wintergrasp queue when you're in the zone (if enabled).
    Auto-Requeue for Battlegrounds: Re-queues for the last battleground after it ends (if enabled). Correctly re-queues for Random Battleground if that was your original selection.
    GUI for Easy Management: A user-friendly interface with buttons to manage battleground queues effortlessly.
    Slash Commands: Quick and convenient commands to control the addon, queue for battlegrounds, and view stats.
    Session Stats Tracking: Monitors honor, kills, wins, and losses per session, with options to view and reset stats.
    Minimap Integration: Adds a minimap icon for fast access to the GUI.
    Streamlined Output: Minimal chat feedback for a cleaner experience, displaying only essential information like queued battlegrounds and auto-requeue status.

Getting Started
Installation

    Download the addon and copy the BattlegroundMaster folder into your WoW Interface/AddOns directory.
    Launch World of Warcraft and enable the addon in the character selection screen.
    In-game, type /bm to open the GUI or click the minimap icon to get started.

First Steps

    Open the GUI with /bm to explore the interface.
    Enable auto-requeue with /bm autorequeue to automatically re-queue after battlegrounds.
    Queue for a battleground using /bm <bgKey> (e.g., /bm ab for Arathi Basin).
    Track your session stats with /bm stats.

Commands

    /bm - Toggles the GUI.
    /bm <bgKey> - Joins or leaves a battleground. Supported keys: av (Alterac Valley), wsg (Warsong Gulch), ab (Arathi Basin), eots (Eye of the Storm), sota (Strand of the Ancients), ioc (Isle of Conquest), random (Random Battleground).
    /bm joinwintergrasp - Manually accepts the Wintergrasp queue.
    /bm list - Displays active queues.
    /bm autorequeue - Toggles auto-requeue for battlegrounds.
    /bm stats - Shows session honor, kills, wins, and losses.
    /bm resetstats - Resets session stats.

Changelog
Version 1.2.1 (June 2025)

    Auto-Requeue Fix for Random BG: Fixed auto-requeue to re-queue for Random Battleground if the original queue was for Random Battleground, instead of the specific battleground played.

Version 1.2 (June 2025)

    Win/Loss Stats: Added tracking of battleground wins and losses per session, displayed with /bm stats and reset with /bm resetstats. Detected using GetBattlefieldWinner() when a battleground ends.
    Deserter Debuff Detection: Added a check to prevent auto-requeue if the player has the Deserter debuff.
    Auto-Requeue Improvement: Updated auto-requeue to target the specific battleground that ended, tracked via activeBGs.
    Active Battlefield Detection: Improved detection to check all slots in JoinQueue and auto-requeue logic.
    Code Cleanup: Removed redundant queue slot management, added better error messages, and simplified event handling.

Version 1.1 (June 2025)

    Auto-Requeue Fix: Updated auto-requeue to re-run the original manual command (e.g., /bm ab) after a battleground ends, ensuring compatibility with custom servers.
    Streamlined Chat Output: Reduced verbose debug messages to show only essential feedback (e.g., queued battlegrounds, auto-requeue status).
    Improved Wintergrasp Auto-Queue: Enhanced with robust detection using polling and event-based methods; added zone validation.
    Code Optimization: Removed duplicate event handling; centralized battleground logic in BattlegroundMaster.lua.
    Enhanced Reliability: Added safety checks and retry limits in FindAndClickScroll.
    GUI Improvements: Added "List Active Queues" button and synced checkboxes with commands.

Version 1.0 (Initial Release)

    Initial release with core features: Wintergrasp auto-queue, GUI, slash commands, and session stats tracking.

Troubleshooting

    Auto-requeue not working? Ensure you’ve queued manually first with /bm <bgKey> and that auto-requeue is enabled with /bm autorequeue.
    Custom server issues? Report any unique chat messages or PvP frame behavior on the GitHub Issues page for tailored fixes.
    Stats not updating? Reset stats with /bm resetstats and ensure you’re in a battleground for stats to track.

Contributing

    Bug Reports and Feature Requests: Submit issues or suggestions on the GitHub Issues page.
    Testing: Test new features and provide feedback to help improve the addon.
    Code Contributions: Fork the repository, make changes, and submit a pull request for review.

Credits

    Developed with contributions from the WoW addon community.
    Special thanks to users on GitHub for feedback and testing.

License

This addon is released under the MIT License. See the LICENSE file for details.
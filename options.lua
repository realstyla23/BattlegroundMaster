function BattlegroundMaster:GetOptions()
    local options = {
        type = "group",
        name = "BattlegroundMaster",
        args = {
            enable = {
                type = "toggle",
                name = "Enable",
                desc = "Enable or disable the addon.",
                get = function() return self.db.profile.enable end,
                set = function(_, val) self.db.profile.enable = val end,
            },
            showSessionStats = {
                type = "execute",
                name = "Show Session Stats",
                desc = "Print current session kills and honor in chat.",
                func = function()
                    BattlegroundMaster:ShowSessionStats()
                end,
                order = 10,
            },
        },
    }
    return options
end
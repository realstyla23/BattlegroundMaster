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
                order = 1,
            },
            debugMode = {
                type = "toggle",
                name = "Debug Mode",
                desc = "Enable debug mode to show additional messages in chat for troubleshooting.",
                get = function() return self.db.profile.debugMode end,
                set = function(_, val) self.db.profile.debugMode = val end,
                order = 2,
            },
            autoRequeueDelay = {
                type = "range",
                name = "Auto-Requeue Delay",
                desc = "Set the delay (in seconds) before auto-requeue triggers after a battleground ends.",
                min = 1,
                max = 30,
                step = 1,
                get = function() return self.db.profile.autoRequeueDelay end,
                set = function(_, val) self.db.profile.autoRequeueDelay = val end,
                order = 3,
            },
            autoRequeueGroup = {
                type = "group",
                name = "Auto-Requeue Per Battleground",
                desc = "Toggle auto-requeue for specific battlegrounds.",
                order = 4,
                args = {
                    av = {
                        type = "toggle",
                        name = "Alterac Valley",
                        get = function() return self.db.profile.autoRequeuePerBG.av end,
                        set = function(_, val) self.db.profile.autoRequeuePerBG.av = val end,
                    },
                    wsg = {
                        type = "toggle",
                        name = "Warsong Gulch",
                        get = function() return self.db.profile.autoRequeuePerBG.wsg end,
                        set = function(_, val) self.db.profile.autoRequeuePerBG.wsg = val end,
                    },
                    ab = {
                        type = "toggle",
                        name = "Arathi Basin",
                        get = function() return self.db.profile.autoRequeuePerBG.ab end,
                        set = function(_, val) self.db.profile.autoRequeuePerBG.ab = val end,
                    },
                    eots = {
                        type = "toggle",
                        name = "Eye of the Storm",
                        get = function() return self.db.profile.autoRequeuePerBG.eots end,
                        set = function(_, val) self.db.profile.autoRequeuePerBG.eots = val end,
                    },
                    sota = {
                        type = "toggle",
                        name = "Strand of the Ancients",
                        get = function() return self.db.profile.autoRequeuePerBG.sota end,
                        set = function(_, val) self.db.profile.autoRequeuePerBG.sota = val end,
                    },
                    ioc = {
                        type = "toggle",
                        name = "Isle of Conquest",
                        get = function() return self.db.profile.autoRequeuePerBG.ioc end,
                        set = function(_, val) self.db.profile.autoRequeuePerBG.ioc = val end,
                    },
                    random = {
                        type = "toggle",
                        name = "Random Battleground",
                        get = function() return self.db.profile.autoRequeuePerBG.random end,
                        set = function(_, val) self.db.profile.autoRequeuePerBG.random = val end,
                    },
                    wintergrasp = {
                        type = "toggle",
                        name = "Wintergrasp",
                        get = function() return self.db.profile.autoRequeuePerBG.wintergrasp end,
                        set = function(_, val) self.db.profile.autoRequeuePerBG.wintergrasp = val end,
                    },
                },
            },
            showSessionStats = {
                type = "execute",
                name = "Show Session Stats",
                desc = "Print current session kills, honor, wins, and losses in chat.",
                func = function()
                    BattlegroundMaster:ShowSessionStats()
                end,
                order = 5,
            },
            profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db),
        },
    }
    options.args.profiles.order = 6
    return options
end
-- Initialize the addon
local addon = LibStub("AceAddon-3.0"):NewAddon("BattlegroundMaster", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")

-- Store a reference to the addon locally
BattlegroundMaster = addon
_G.BattlegroundMaster = addon

function BattlegroundMaster:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("BGM_DB", {
        profile = {
            enable = true,
            autoRequeue = false,
            autoWintergrasp = false,
            sessionHonor = 0,
            sessionKills = 0,
            lastHonor = 0,
            wins = 0,
            losses = 0,
            lifetimeHonor = 0,
            lifetimeKills = 0,
            lifetimeWins = 0,
            lifetimeLosses = 0,
            autoRequeueDelay = 5,
            debugMode = false,
            autoRequeuePerBG = {
                av = true,
                wsg = true,
                ab = true,
                eots = true,
                sota = true,
                ioc = true,
                random = true,
                wintergrasp = true,
            },
            minimap = {
                hide = false,
                minimapPos = 225
            }
        }
    })

    -- Setup LibDBIcon
    self.LDB = LibStub("LibDataBroker-1.1"):NewDataObject("BattlegroundMaster", {
        type = "data source",
        text = "BG Master",
        icon = "Interface\\Icons\\Achievement_BG_winAB",
        OnClick = function(self, button)
            if button == "LeftButton" then
                BGMFrame:ToggleGUI()
            end
        end,
        OnTooltipShow = function(tooltip)
            tooltip:AddLine("|cffff4444Battleground|cff4466ffMaster|r")
            tooltip:AddLine("Left-click to toggle GUI", 0, 1, 0)
        end,
    })
    self.icon = LibStub("LibDBIcon-1.0")
    self.icon:Register("BattlegroundMaster", self.LDB, self.db.profile.minimap)

    -- Register chat commands
    self:RegisterChatCommand("bm", function(msg) BGMFrame:Command(msg) end)

    -- Register events
    self:RegisterEvent("ADDON_LOADED")
    self:RegisterEvent("PLAYER_LOGIN")
    self:RegisterEvent("PLAYER_PVP_KILLS_CHANGED")
    self:RegisterEvent("UPDATE_BATTLEFIELD_SCORE")

    -- Hook StaticPopup_Show for Wintergrasp auto-queue
    hooksecurefunc("StaticPopup_Show", function(which, textArg1, textArg2, data)
        if BattlegroundMaster.db.profile.autoWintergrasp then
            local fullText = (textArg1 or "") .. (textArg2 or "")
            local isWintergrasp = fullText:lower():find("wintergrasp") or fullText:lower():find("would you like to join the queue")
            if isWintergrasp then
                local printFunc = BGMFrame and BGMFrame.Print or BattlegroundMaster.Print
                if BattlegroundMaster.db.profile.debugMode then
                    printFunc(BGMFrame or BattlegroundMaster, "[DEBUG] Wintergrasp: Popup triggered, which=" .. tostring(which) .. ", fullText=" .. fullText)
                end
                for i = 1, 4 do
                    local popup = _G["StaticPopup" .. i]
                    if popup and popup:IsShown() then
                        if BattlegroundMaster.db.profile.debugMode then
                            printFunc(BGMFrame or BattlegroundMaster, "[DEBUG] Wintergrasp: Found shown popup: StaticPopup" .. i)
                        end
                        local button = _G["StaticPopup" .. i .. "Button1"]
                        if button then
                            if BattlegroundMaster.db.profile.debugMode then
                                printFunc(BGMFrame or BattlegroundMaster, "[DEBUG] Wintergrasp: Button1 found, label=" .. (button:GetText() or "nil") .. ", enabled=" .. tostring(button:IsEnabled()) .. ", visible=" .. tostring(button:IsVisible()))
                            end
                            C_Timer.After(0.5, function() -- Increased delay for Warmane UI
                                if button:IsEnabled() and button:IsVisible() and (button:GetText() and (button:GetText():lower():find("accept") or button:GetText():lower():find("okay"))) then
                                    button:Click()
                                    if BattlegroundMaster.db.profile.debugMode then
                                        printFunc(BGMFrame or BattlegroundMaster, "Auto-accepted Wintergrasp queue.")
                                    end
                                else
                                    if BattlegroundMaster.db.profile.debugMode then
                                        printFunc(BGMFrame or BattlegroundMaster, "[DEBUG] Wintergrasp: Failed to accept - Button state: enabled=" .. tostring(button:IsEnabled()) .. ", visible=" .. tostring(button:IsVisible()) .. ", text=" .. (button:GetText() or "nil"))
                                    end
                                end
                            end)
                            return
                        end
                    end
                end
                if BattlegroundMaster.db.profile.debugMode then
                    printFunc(BGMFrame or BattlegroundMaster, "[DEBUG] Wintergrasp: No valid popup found with Accept or Okay button.")
                end
            end
        end
    end)

    -- Delay global assignment to ensure Ace3 is done
    C_Timer.After(1, function()
        if not _G.BattlegroundMaster then
            _G.BattlegroundMaster = self
        end
        BattlegroundMaster = _G.BattlegroundMaster
    end)

    -- Delay settings panel registration to ensure Blizzard UI is ready
    C_Timer.After(2, function()
        local AceConfig = LibStub("AceConfig-3.0")
        local AceConfigDialog = LibStub("AceConfigDialog-3.0")
        AceConfig:RegisterOptionsTable("BattlegroundMaster", self:GetOptions())
        self.optionsFrame = AceConfigDialog:AddToBlizOptions("BattlegroundMaster", "BattlegroundMaster")
        if not self.optionsFrame then
            self:Print("Failed to register settings panel after delay. Check Ace3 libraries.")
        else
            self:Print("Settings panel registered successfully after delay.")
        end
    end)

    self:Print("BattlegroundMaster loaded.")
end

function BattlegroundMaster:ADDON_LOADED(event, addon)
    if addon == "BattlegroundMaster" then
        if BGMFrame and BGMFrame.CreateGUI then
            BGMFrame:CreateGUI()
        else
            self:Print("Error: BGMFrame or CreateGUI not available.")
        end
    end
end

function BattlegroundMaster:PLAYER_LOGIN()
    self.db.profile.sessionHonor = 0
    self.db.profile.sessionKills = 0
    self.db.profile.lastHonor = GetHonorCurrency() or 0
    self.db.profile.wins = 0
    self.db.profile.losses = 0
    self.db.profile._lastHKs = GetPVPSessionStats() or 0
    self:Print("Session stats reset on login.")
end

function BattlegroundMaster:PLAYER_PVP_KILLS_CHANGED()
    local currentKills = GetPVPSessionStats() or 0
    local prevKills = self.db.profile._lastHKs or 0
    local delta = currentKills - prevKills

    if delta > 0 then
        self.db.profile.sessionKills = (self.db.profile.sessionKills or 0) + delta
        self.db.profile.lifetimeKills = (self.db.profile.lifetimeKills or 0) + delta
        self:Print("Honorable kills gained: "..delta..". Total Session Kills: "..self.db.profile.sessionKills)
    end

    self.db.profile._lastHKs = currentKills
end

function BattlegroundMaster:UPDATE_BATTLEFIELD_SCORE()
    local currentHonor = GetHonorCurrency() or 0
    local honorGained = currentHonor - (self.db.profile.lastHonor or 0)
    if honorGained > 0 then
        self.db.profile.sessionHonor = (self.db.profile.sessionHonor or 0) + honorGained
        self.db.profile.lifetimeHonor = (self.db.profile.lifetimeHonor or 0) + honorGained
        self.db.profile.lastHonor = currentHonor
        self:Print("Honor gained: "..honorGained..". Total Session Honor: "..self.db.profile.sessionHonor)
    end
end

function BattlegroundMaster:Print(msg)
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99BattlegroundMaster|r: "..msg)
        if self.db.profile.debugMode then
            DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99[DEBUG] BattlegroundMaster|r: "..msg)
        end
    end
end

function BattlegroundMaster:ShowSessionStats()
    self:Print("Session Honor: "..(self.db.profile.sessionHonor or 0)..
               ". | Session Kills: "..(self.db.profile.sessionKills or 0)..
               ". | Wins: "..(self.db.profile.wins or 0)..
               ". | Losses: "..(self.db.profile.losses or 0)..".")
end

function BattlegroundMaster:ShowLifetimeStats()
    self:Print("Lifetime Stats Since Addon Usage:")
    self:Print("Lifetime Honor: "..(self.db.profile.lifetimeHonor or 0)..
               ". | Lifetime Kills: "..(self.db.profile.lifetimeKills or 0)..
               ". | Lifetime Wins: "..(self.db.profile.lifetimeWins or 0)..
               ". | Lifetime Losses: "..(self.db.profile.lifetimeLosses or 0)..".")
end

function BattlegroundMaster:ResetStats()
    self.db.profile.sessionHonor = 0
    self.db.profile.sessionKills = 0
    self.db.profile.lastHonor = GetHonorCurrency() or 0
    self.db.profile.wins = 0
    self.db.profile.losses = 0
    self:Print("Session stats reset manually.")
end

function BattlegroundMaster:IncrementWins()
    self.db.profile.wins = (self.db.profile.wins or 0) + 1
    self.db.profile.lifetimeWins = (self.db.profile.lifetimeWins or 0) + 1
    self:Print("Battleground won! Total Session Wins: "..self.db.profile.wins)
end

function BattlegroundMaster:IncrementLosses()
    self.db.profile.losses = (self.db.profile.losses or 0) + 1
    self.db.profile.lifetimeLosses = (self.db.profile.lifetimeLosses or 0) + 1
    self:Print("Battleground lost. Total Session Losses: "..self.db.profile.losses)
end
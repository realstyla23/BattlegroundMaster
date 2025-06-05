local BGMFrame = CreateFrame("Frame", "BGMFrame", UIParent)
BGMFrame.queueNames = BGMFrame.queueNames or {}
BGMFrame.lastQueuedBG = nil -- Track last queued BG for manual queuing
BGMFrame.inWintergrasp = false -- Track if in Wintergrasp for polling
BGMFrame.activeBGs = {} -- Track active battlegrounds for auto-requeue

-- BG Data without slot numbers, as we’ll use the PvP frame for all queuing
local BG_DATA = {
    ["av"] = { name = "Alterac Valley", color = "3399ff", pattern = "alterac", scrollUp = true },
    ["wsg"] = { name = "Warsong Gulch", color = "ff0000", pattern = "warsong", scrollUp = true },
    ["ab"] = { name = "Arathi Basin", color = "ffcc00", pattern = "arathi", scrollUp = true },
    ["eots"] = { name = "Eye of the Storm", color = "9900ff", pattern = "eye of", scrollUp = true },
    ["sota"] = { name = "Strand of the Ancients", color = "33ff66", pattern = "strand of", scrollUp = false },
    ["ioc"] = { name = "Isle of Conquest", color = "aaddff", pattern = "isle of", scrollUp = false },
    ["random"] = { name = "Random Battleground", color = "00ffff", pattern = "random", scrollUp = true },
    ["wintergrasp"] = { name = "Wintergrasp", color = "ff66cc", pattern = "wintergrasp", scrollUp = false }
}

-- Print function
BGMFrame.Print = function(self, msg)
    BattlegroundMaster:Print(msg)
end

-- Helper function to get BG key from map name
function BGMFrame:GetBGKeyFromMapName(mapName)
    for key, bg in pairs(BG_DATA) do
        if bg.name:lower() == mapName:lower() then
            return key
        end
    end
    return nil
end

-- Check for deserter debuff
function BGMFrame:HasDeserterDebuff()
    for i = 1, 40 do
        local name = UnitDebuff("player", i)
        if name and name:lower() == "deserter" then
            return true
        end
    end
    return false
end

-- Check if player is in an active battlefield
function BGMFrame:IsInActiveBattlefield()
    for i = 1, MAX_BATTLEFIELD_QUEUES do
        local status = GetBattlefieldStatus(i)
        if status == "active" then
            return true
        end
    end
    return false
end

-- JoinQueue function for manual queuing
function BGMFrame:JoinQueue(bgKey)
    local bgInfo = BG_DATA[bgKey:lower()]
    if not bgInfo then
        self:Print("Invalid BG. Use: av, wsg, ab, eots, sota, ioc, random, wintergrasp")
        return
    end

    if bgKey:lower() == "wintergrasp" then
        local zone = GetZoneText()
        if zone ~= "Wintergrasp" then
            self:Print("Wintergrasp queue only available in Wintergrasp. Move to Wintergrasp to queue.")
            return
        end
    end

    self.lastQueuedBG = bgKey
    self:Print("Queuing for " .. bgInfo.name)

    -- Check if player is in a battleground or active battlefield
    if UnitInBattleground("player") then
        self:Print("Cannot queue: Player is still in a battleground.")
        return
    end
    if self:IsInActiveBattlefield() then
        self:Print("Cannot queue: Active battlefield detected.")
        return
    end

    -- Find an empty queue slot
    local slot
    for i = 1, MAX_BATTLEFIELD_QUEUES do
        if GetBattlefieldStatus(i) == "none" then
            slot = i
            break
        end
    end
    if not slot then
        self:Print("No available queue slots for " .. bgInfo.name)
        return
    end

    -- Attempt to open and interact with the PvP frame with retries
    local function attemptQueue(attempts)
        attempts = attempts or 1
        local maxAttempts = 5
        local delay = 5 -- Delay in seconds between attempts

        if attempts > maxAttempts then
            self:Print("Failed to queue for " .. bgInfo.name .. " after " .. maxAttempts .. " attempts.")
            return
        end

        if not PVPParentFrame or not PVPParentFrame:IsShown() then
            ToggleFrame(PVPParentFrame)
        end

        if PVPParentFrame and PVPParentFrame:IsShown() then
            if bgKey == "random" then
                JoinBattlefield(0)
                self:Print("|cff" .. bgInfo.color .. bgInfo.name .. "|r queued.")
            else
                self:SelectBG(bgInfo)
            end
            self.queueNames[slot] = bgInfo.name
        else
            C_Timer.After(delay, function()
                attemptQueue(attempts + 1)
            end)
            return
        end

        -- Close PvP window
        if PVPParentFrame and PVPParentFrame:IsShown() then
            ToggleFrame(PVPParentFrame)
        end
    end

    attemptQueue()
end

function BGMFrame:LeaveQueue(bgKey)
    for i = 1, MAX_BATTLEFIELD_QUEUES do
        if self.queueNames[i] and self:GetBGKeyFromName(self.queueNames[i]) == bgKey then
            local status = GetBattlefieldStatus(i)
            if status and (status == "queued" or status == "confirm") then
                AcceptBattlefieldPort(i, false)
                self.queueNames[i] = nil
                self:Print("Left queue for " .. BG_DATA[bgKey].name)
                return
            end
        end
    end
    self:Print("Not queued for " .. BG_DATA[bgKey].name)
end

function BGMFrame:GetBGKeyFromName(bgName)
    for key, bg in pairs(BG_DATA) do
        if bg.name == bgName then
            return key
        end
    end
    return nil
end

function BGMFrame:SelectBG(bgInfo)
    if PVPParentFrameTab1 then
        PVPParentFrameTab1:Click()
    end
    self:FindAndClickScroll(bgInfo)
end

function BGMFrame:FindAndClickScroll(bgInfo)
    local scrollFrame = _G["PVPBattlegroundFrameTypeScrollFrame"]
    if not scrollFrame then
        self:Print("Failed to queue for " .. bgInfo.name .. ": Scroll frame not found.")
        return
    end

    local scrollUpButton = _G["PVPBattlegroundFrameTypeScrollFrameScrollBarScrollUpButton"]
    local scrollDownButton = _G["PVPBattlegroundFrameTypeScrollFrameScrollBarScrollDownButton"]
    if not scrollUpButton or not scrollDownButton then
        self:Print("Failed to queue for " .. bgInfo.name .. ": Scroll buttons not found.")
        return
    end

    local maxAttempts = 15
    local attempt = 0
    local scrollAttempts = 0
    local maxScrollAttempts = 10

    local function searchAndScroll()
        attempt = attempt + 1
        if attempt > maxAttempts then
            self:Print("Failed to queue for " .. bgInfo.name .. ": Could not find BG after " .. maxAttempts .. " attempts.")
            return
        end

        for i = 1, 5 do
            local btn = _G["BattlegroundType" .. i]
            if btn and btn:IsShown() then
                local buttonText = _G[btn:GetName() .. "Text"] and _G[btn:GetName() .. "Text"]:GetText() or ""
                if buttonText:lower():find(bgInfo.pattern) then
                    btn:Click()
                    if PVPBattlegroundFrameJoinButton and PVPBattlegroundFrameJoinButton:IsEnabled() then
                        PVPBattlegroundFrameJoinButton:Click()
                        self:Print("|cff" .. bgInfo.color .. bgInfo.name .. "|r queued.")
                    end
                    return
                end
            end
        end

        if scrollAttempts < maxScrollAttempts then
            scrollAttempts = scrollAttempts + 1
            if bgInfo.scrollUp then
                scrollUpButton:Click()
            else
                scrollDownButton:Click()
            end
            C_Timer.After(0.1, searchAndScroll)
        end
    end

    -- Reset scroll position to top
    for i = 1, maxScrollAttempts do
        scrollUpButton:Click()
    end
    C_Timer.After(0.1, searchAndScroll)
end

-- Polling Function for Wintergrasp Queue and Popup
local function PollForWintergraspQueueAndPopup()
    if not BGMFrame.inWintergrasp or not BattlegroundMaster.db.profile.autoWintergrasp then
        return
    end
    for i = 1, MAX_BATTLEFIELD_QUEUES do
        local status, mapName = GetBattlefieldStatus(i)
        if status == "confirm" and mapName and mapName:lower():find("wintergrasp") then
            BGMFrame:Print("Polling detected Wintergrasp confirm status, accepting!")
            AcceptBattlefieldPort(i, true)
        end
    end
    -- Check for Wintergrasp popup and click the accept button
    if BattlegroundMaster.db.profile.autoWintergrasp then
        local popup = _G["StaticPopup1"]
        if popup and popup:IsShown() and popup.which == "CONFIRM_BATTLEFIELD_ENTRY" then
            local button = _G["StaticPopup1Button1"]
            if button and button:IsEnabled() and button:IsVisible() then
                BGMFrame:Print("Auto-accepting Wintergrasp queue prompt.")
                button:Click()
            end
        end
    end
    C_Timer.After(1, PollForWintergraspQueueAndPopup)
end

-- Consolidated Event Handling
BGMFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
BGMFrame:RegisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL")
BGMFrame:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")

BGMFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ZONE_CHANGED_NEW_AREA" then
        local zone = GetZoneText()
        if zone == "Wintergrasp" and BattlegroundMaster.db.profile.autoWintergrasp then
            self:Print("Entered Wintergrasp, Wintergrasp auto-queue enabled.")
            self.inWintergrasp = true
            self:JoinQueue("wintergrasp")
            PollForWintergraspQueueAndPopup()
        else
            self.inWintergrasp = false
            if BattlegroundMaster.db.profile.autoWintergrasp then
                self:Print("Wintergrasp auto-queue only works in Wintergrasp. Current zone: " .. zone .. ".")
            end
        end
    elseif event == "CHAT_MSG_BG_SYSTEM_NEUTRAL" then
        local message = ...
        if message:lower():find("wintergrasp") and (message:find("join") or message:find("would you like to")) and BattlegroundMaster.db.profile.autoWintergrasp then
            self:Print("Wintergrasp queue prompt detected via chat message, polling for popup.")
        end
    elseif event == "UPDATE_BATTLEFIELD_STATUS" then
        local index = ...
        local status, mapName = GetBattlefieldStatus(index)
        
        if status == "active" then
            local key = self:GetBGKeyFromMapName(mapName)
            if key then
                self.activeBGs[index] = key
            end
        end
        
        if status == "confirm" and mapName and mapName:lower():find("wintergrasp") and BattlegroundMaster.db.profile.autoWintergrasp then
            self:Print("Wintergrasp queue confirm detected via status update, accepting!")
            AcceptBattlefieldPort(index, true)
        end
        
        if status == "none" and self.queueNames[index] then
            -- Win/Loss detection
            local winner = GetBattlefieldWinner()
            if winner then
                local playerFaction = UnitFactionGroup("player")
                if (winner == 0 and playerFaction == "Horde") or (winner == 1 and playerFaction == "Alliance") then
                    BattlegroundMaster:IncrementWins()
                else
                    BattlegroundMaster:IncrementLosses()
                end
            end
            
            -- Auto-requeue logic
            if BattlegroundMaster.db.profile.autoRequeue then
                local bgKey = self.activeBGs[index]
                if bgKey then
                    -- Check if auto-requeue is enabled for this BG
                    if not BattlegroundMaster.db.profile.autoRequeuePerBG[bgKey] then
                        self:Print("Auto-requeue skipped: Disabled for " .. BG_DATA[bgKey].name .. " in settings.")
                    else
                        -- If originally queued for random, re-queue for random
                        local requeueKey = (self.lastQueuedBG == "random" and bgKey ~= "wintergrasp") and "random" or bgKey
                        self:Print("Auto-requeue for " .. BG_DATA[requeueKey].name .. " in " .. BattlegroundMaster.db.profile.autoRequeueDelay .. " seconds...")
                        C_Timer.After(BattlegroundMaster.db.profile.autoRequeueDelay, function()
                            if self:HasDeserterDebuff() then
                                self:Print("Auto-requeue skipped: Deserter debuff active.")
                            elseif self:IsInActiveBattlefield() then
                                self:Print("Auto-requeue skipped: Active battlefield detected.")
                            else
                                self:Command(requeueKey)
                            end
                        end)
                    end
                else
                    self:Print("Auto-requeue failed: Could not determine the battleground that ended.")
                end
            end
            self.activeBGs[index] = nil
            self.queueNames[index] = nil
        end
    end
end)

-- GUI Creation
function BGMFrame:CreateGUI()
    local frame = CreateFrame("Frame", "BattlegroundMasterGUI", UIParent, "BasicFrameTemplateWithInset")
    self.guiFrame = frame
    frame:SetSize(420, 300) -- Updated to 420x300 as requested
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetClampedToScreen(true)

    -- Title
    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.title:SetPoint("TOP", 0, -5) -- Moved higher to align better
    frame.title:SetText("|cff33ff99BattlegroundMaster|r")

    -- Auto-Requeue Checkbox (Left)
    frame.autoRequeueCheck = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    frame.autoRequeueCheck:SetPoint("TOPLEFT", 20, -40)
    frame.autoRequeueCheck.text = frame.autoRequeueCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.autoRequeueCheck.text:SetPoint("LEFT", frame.autoRequeueCheck, "RIGHT", 5, 0)
    frame.autoRequeueCheck.text:SetText("Auto Re-Queue")
    frame.autoRequeueCheck:SetChecked(BattlegroundMaster.db.profile.autoRequeue)
    frame.autoRequeueCheck:SetScript("OnClick", function(self)
        BattlegroundMaster.db.profile.autoRequeue = self:GetChecked()
        BGMFrame:Print("Auto-requeue " .. (BattlegroundMaster.db.profile.autoRequeue and "enabled" or "disabled") .. ".")
    end)

    -- Wintergrasp Auto-Queue Checkbox (Right)
    frame.autoWintergraspCheck = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    frame.autoWintergraspCheck:SetPoint("TOPRIGHT", -170, -40)
    frame.autoWintergraspCheck.text = frame.autoWintergraspCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.autoWintergraspCheck.text:SetPoint("LEFT", frame.autoWintergraspCheck, "RIGHT", 5, 0)
    frame.autoWintergraspCheck.text:SetText("Wintergrasp Queue")
    frame.autoWintergraspCheck:SetChecked(BattlegroundMaster.db.profile.autoWintergrasp)
    frame.autoWintergraspCheck:SetScript("OnClick", function(self)
        BattlegroundMaster.db.profile.autoWintergrasp = self:GetChecked()
        BGMFrame:Print("Wintergrasp auto-queue " .. (BattlegroundMaster.db.profile.autoWintergrasp and "enabled" or "disabled") .. " (only active in Wintergrasp zone).")
    end)

    -- Battleground Buttons (Left Column)
    local bgY = -70
    local bgKeys = {}
    for key, bgInfo in pairs(BG_DATA) do
        if key ~= "wintergrasp" then
            table.insert(bgKeys, key)
        end
    end
    table.sort(bgKeys, function(a, b)
        if a == "random" then return true
        elseif b == "random" then return false
        else return BG_DATA[a].name < BG_DATA[b].name end
    end)
    for _, bgKey in ipairs(bgKeys) do
        local bgInfo = BG_DATA[bgKey]
        local button = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        button:SetSize(180, 25) -- Increased width to 180 for longer names
        button:SetPoint("TOPLEFT", 20, bgY)
        button:SetText(bgInfo.name)
        button:SetScript("OnClick", function()
            local status, queueIndex
            for i = 1, MAX_BATTLEFIELD_QUEUES do
                if self.queueNames[i] and self:GetBGKeyFromName(self.queueNames[i]) == bgKey then
                    status = GetBattlefieldStatus(i)
                    queueIndex = i
                    break
                end
            end
            if not status or status == "none" then
                self:JoinQueue(bgKey)
            else
                self:LeaveQueue(bgKey)
                if queueIndex then
                    self.queueNames[queueIndex] = nil
                end
            end
        end)
        bgY = bgY - 30
    end

    -- Misc Buttons (Right Column)
    local miscY = -70
    local miscButtons = {
        { text = "List Active Queues", func = function() 
            BGMFrame:Print("Active Queues:")
            for i = 1, MAX_BATTLEFIELD_QUEUES do
                if BGMFrame.queueNames[i] then
                    local status = GetBattlefieldStatus(i)
                    local color = "ffffff"
                    for _, bg in pairs(BG_DATA) do
                        if bg.name == BGMFrame.queueNames[i] then
                            color = bg.color
                            break
                        end
                    end
                    BGMFrame:Print(string.format("%d: |cff%s%s|r - %s", i, color, BGMFrame.queueNames[i], status))
                end
            end
        end },
        { text = "Show Session Stats", func = function() BattlegroundMaster:ShowSessionStats() end },
        { text = "Show Lifetime Stats", func = function() BattlegroundMaster:ShowLifetimeStats() end },
        { text = "Reset Session Stats", func = function() BattlegroundMaster:ResetStats() end },
        { text = "Open Settings", func = function() 
            BGMFrame:Print("Attempting to open settings panel...")
            if BattlegroundMaster.optionsFrame then
                InterfaceOptionsFrame_OpenToCategory("BattlegroundMaster")
                InterfaceOptionsFrame_OpenToCategory("BattlegroundMaster") -- Double call to ensure it opens
                BGMFrame:Print("Settings panel should be open now.")
            else
                BGMFrame:Print("Settings panel not registered. Check addon initialization.")
            end
        end }
    }
    for _, buttonInfo in ipairs(miscButtons) do
        local button = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        button:SetSize(180, 25) -- Increased width to 180 for consistency
        button:SetPoint("TOPRIGHT", -20, miscY)
        button:SetText(buttonInfo.text)
        button:SetScript("OnClick", buttonInfo.func)
        miscY = miscY - 30
    end
end

function BGMFrame:ToggleGUI()
    if not self.guiFrame then
        self:CreateGUI()
    end
    if self.guiFrame:IsShown() then
        self.guiFrame:Hide()
    else
        self.guiFrame:Show()
    end
end

function BGMFrame:Command(msg)
    local cmd = msg and msg:lower() or ""
    
    if cmd == "" then
        self:ToggleGUI()
    elseif cmd == "joinwintergrasp" then
        for i = 1, MAX_BATTLEFIELD_QUEUES do
            local status, mapName = GetBattlefieldStatus(i)
            if status == "confirm" and mapName and mapName:lower():find("wintergrasp") then
                AcceptBattlefieldPort(i, true)
                self:Print("Manually accepted Wintergrasp queue!")
                return
            end
        end
        self:Print("No Wintergrasp queue prompt found. Ensure you're queued and the prompt is active.")
    elseif cmd == "config" then
        BGMFrame:Print("Attempting to open settings panel...")
        if BattlegroundMaster.optionsFrame then
            InterfaceOptionsFrame_OpenToCategory("BattlegroundMaster")
            InterfaceOptionsFrame_OpenToCategory("BattlegroundMaster") -- Double call to ensure it opens
            BGMFrame:Print("Settings panel should be open now.")
        else
            BGMFrame:Print("Settings panel not registered. Check addon initialization.")
        end
    elseif BG_DATA[cmd] then
        local status
        for i = 1, MAX_BATTLEFIELD_QUEUES do
            if self.queueNames[i] and self:GetBGKeyFromName(self.queueNames[i]) == cmd then
                status = GetBattlefieldStatus(i)
                break
            end
        end
        if not status or status == "none" then
            self:JoinQueue(cmd)
        else
            self:LeaveQueue(cmd)
        end
    elseif cmd == "list" then
        self:Print("Active Queues:")
        for i = 1, MAX_BATTLEFIELD_QUEUES do
            if self.queueNames[i] then
                local status = GetBattlefieldStatus(i)
                local color = "ffffff"
                for _, bg in pairs(BG_DATA) do
                    if bg.name == self.queueNames[i] then
                        color = bg.color
                        break
                    end
                end
                self:Print(string.format("%d: |cff%s%s|r - %s", i, color, self.queueNames[i], status))
            end
        end
    elseif cmd == "autorequeue" then
        BattlegroundMaster.db.profile.autoRequeue = not BattlegroundMaster.db.profile.autoRequeue
        self:Print("Auto-requeue " .. (BattlegroundMaster.db.profile.autoRequeue and "enabled" or "disabled") .. ".")
        if self.guiFrame then
            self.guiFrame.autoRequeueCheck:SetChecked(BattlegroundMaster.db.profile.autoRequeue)
        end
    elseif cmd == "stats" then
        BattlegroundMaster:ShowSessionStats()
    elseif cmd == "lifetimestats" then
        BattlegroundMaster:ShowLifetimeStats()
    elseif cmd == "resetstats" then
        BattlegroundMaster:ResetStats()
    else
        self:Print("BattlegroundMaster Commands:")
        self:Print("/bm - Toggle GUI")
        self:Print("/bm av - Alterac Valley")
        self:Print("/bm wsg - Warsong Gulch")
        self:Print("/bm ab - Arathi Basin")
        self:Print("/bm eots - Eye of the Storm")
        self:Print("/bm sota - Strand of the Ancients")
        self:Print("/bm ioc - Isle of Conquest")
        self:Print("/bm random - Random BG")
        self:Print("/bm joinwintergrasp - Manually accept Wintergrasp queue")
        self:Print("/bm list - Show active queues")
        self:Print("/bm autorequeue - Toggle auto-requeue")
        self:Print("/bm stats - Show session stats")
        self:Print("/bm lifetimestats - Show lifetime stats")
        self:Print("/bm resetstats - Reset session stats")
        self:Print("/bm config - Open settings panel")
    end
end

SlashCmdList["BattlegroundMaster"] = function(msg) BGMFrame:Command(msg) end
SLASH_BattlegroundMaster1 = "/battlegroundmaster"
SLASH_BattlegroundMaster2 = "/bm"
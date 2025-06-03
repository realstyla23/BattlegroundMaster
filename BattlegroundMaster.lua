local BGMFrame = CreateFrame("Frame", "BGMFrame", UIParent)
BGMFrame.queueNames = BGMFrame.queueNames or {}
BGMFrame.lastQueuedBG = nil -- Track last queued BG for auto-requeue
BGMFrame.inWintergrasp = false -- Track if in Wintergrasp for polling

-- Enhanced BG Data with better matching and scroll direction
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

-- Core Functions
function BGMFrame:JoinQueue(bgKey, autoRequeue)
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

    if not autoRequeue then
        self.lastQueuedBG = bgKey
    end

    -- Clear any stale queue entries
    for i = 1, MAX_BATTLEFIELD_QUEUES do
        if self.queueNames[i] and GetBattlefieldStatus(i) == "none" then
            self.queueNames[i] = nil
        end
    end

    -- Find an empty queue slot
    local foundSlot = false
    local slot
    for i = 1, MAX_BATTLEFIELD_QUEUES do
        if not self.queueNames[i] then
            foundSlot = true
            slot = i
            break
        end
    end
    if not foundSlot then
        self:Print("No available queue slots for "..bgInfo.name)
        return
    end

    self:Print("Opening PvP frame for queue: " .. bgInfo.name)
    if not PVPParentFrame or not PVPParentFrame:IsShown() then
        ToggleFrame(PVPParentFrame)
        if PVPParentFrame and PVPParentFrame:IsShown() then
            self:Print("PvP frame opened, selecting BG")
            if autoRequeue and bgKey == "random" then
                JoinBattlefield(0)
                self:Print("|cff"..bgInfo.color..bgInfo.name.."|r")
            else
                self:SelectBG(bgInfo)
            end
        end
    else
        self:Print("PvP frame already open, selecting BG")
        if autoRequeue and bgKey == "random" then
            JoinBattlefield(0)
            self:Print("|cff"..bgInfo.color..bgInfo.name.."|r")
        else
            self:SelectBG(bgInfo)
        end
    end

    -- Track the queue
    if slot then
        self.queueNames[slot] = bgInfo.name
        self:Print("Tracking queue: " .. bgInfo.name .. " at slot " .. slot)
    end
end

function BGMFrame:LeaveQueue(bgKey)
    for i = 1, MAX_BATTLEFIELD_QUEUES do
        if self.queueNames[i] and self:GetBGKeyFromName(self.queueNames[i]) == bgKey then
            local status = GetBattlefieldStatus(i)
            if status and (status == "queued" or status == "confirm") then
                AcceptBattlefieldPort(i, false) -- False to leave the queue
                self.queueNames[i] = nil
                self:Print("Left queue for "..BG_DATA[bgKey].name)
                return
            end
        end
    end
    self:Print("Not queued for "..BG_DATA[bgKey].name)
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
        self:Print("Error: Scroll frame not found.")
        return
    end

    local scrollUpButton = _G["PVPBattlegroundFrameTypeScrollFrameScrollBarScrollUpButton"]
    local scrollDownButton = _G["PVPBattlegroundFrameTypeScrollFrameScrollBarScrollDownButton"]
    if not scrollUpButton or not scrollDownButton then
        self:Print("Error: Scroll buttons not found.")
        return
    end

    local maxAttempts = 10
    local attempt = 0
    local scrollAttempts = 0
    local maxScrollAttempts = 5

    local function searchAndScroll()
        attempt = attempt + 1
        if attempt > maxAttempts then
            self:Print("Error: Could not find " .. bgInfo.name .. " in the list.")
            return
        end

        for i = 1, 5 do
            local btn = _G["BattlegroundType"..i]
            if btn and btn:IsShown() then
                local buttonText = _G[btn:GetName().."Text"] and _G[btn:GetName().."Text"]:GetText() or "No Text"
                if buttonText:lower():find(bgInfo.pattern) then
                    btn:Click()
                    if PVPBattlegroundFrameJoinButton and PVPBattlegroundFrameJoinButton:IsEnabled() then
                        PVPBattlegroundFrameJoinButton:Click()
                        self:Print("|cff"..bgInfo.color..bgInfo.name.."|r")
                        if PVPParentFrame and PVPParentFrame:IsShown() then
                            ToggleFrame(PVPParentFrame)
                        end
                    else
                        searchAndScroll()
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
            searchAndScroll()
        end
    end

    for i = 1, maxScrollAttempts do
        scrollUpButton:Click()
    end
    searchAndScroll()
end

-- Polling Function for Wintergrasp Queue
local function PollForWintergraspQueue()
    if not BGMFrame.inWintergrasp or not BattlegroundMaster.db.profile.autoWintergrasp then
        return
    end
    for i = 1, MAX_BATTLEFIELD_QUEUES do
        local status, mapName = GetBattlefieldStatus(i)
        if status == "confirm" and mapName and mapName:lower():find("wintergrasp") then
            BGMFrame:Print("Polling detected Wintergrasp confirm status, accepting!")
            AcceptBattlefieldPort(i, true)
            return
        end
    end
    C_Timer.After(1, PollForWintergraspQueue)
end

-- Event Handling for Wintergrasp Auto-Queue
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
            PollForWintergraspQueue() -- Start polling
        else
            self.inWintergrasp = false
        end
    elseif event == "CHAT_MSG_BG_SYSTEM_NEUTRAL" then
        local message = ...
        self:Print("Received BG system message: " .. message) -- Debug print
        if message:lower():find("wintergrasp") and (message:find("join") or message:find("would you like to")) and BattlegroundMaster.db.profile.autoWintergrasp then
            self:Print("Auto-accepting Wintergrasp queue prompt via chat message.")
            -- Check if the popup is visible and click it
            local popup = StaticPopup_Visible("CONFIRM_BATTLEFIELD_ENTRY")
            if popup then
                self:Print("Found CONFIRM_BATTLEFIELD_ENTRY popup, clicking accept!")
                _G[popup .. "Button1"]:Click()
                return
            end
            -- Fallback to direct accept
            for i = 1, MAX_BATTLEFIELD_QUEUES do
                local status, mapName = GetBattlefieldStatus(i)
                self:Print("Slot " .. i .. ": Status=" .. (status or "none") .. ", Map=" .. (mapName or "none")) -- Debug print
                if status == "confirm" and mapName and mapName:lower():find("wintergrasp") then
                    AcceptBattlefieldPort(i, true)
                    self:Print("Wintergrasp queue accepted instantly via chat event!")
                    return
                end
            end
        end
    elseif event == "UPDATE_BATTLEFIELD_STATUS" then
        local index = ...
        local status, mapName = GetBattlefieldStatus(index)
        self:Print("Battlefield status updated: Slot " .. index .. ", Status=" .. (status or "none") .. ", Map=" .. (mapName or "none")) -- Debug print
        if status == "confirm" and mapName and mapName:lower():find("wintergrasp") and BattlegroundMaster.db.profile.autoWintergrasp then
            self:Print("Wintergrasp queue confirm detected via status update, accepting!")
            AcceptBattlefieldPort(index, true)
            -- Double-check with popup click
            local popup = StaticPopup_Visible("CONFIRM_BATTLEFIELD_ENTRY")
            if popup then
                self:Print("Found CONFIRM_BATTLEFIELD_ENTRY popup via status update, clicking accept!")
                _G[popup .. "Button1"]:Click()
            end
        end
    end
end)

-- GUI Creation
function BGMFrame:CreateGUI()
    local frame = CreateFrame("Frame", "BattlegroundMasterGUI", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(300, 400)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetClampedToScreen(true)

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.title:SetPoint("TOP", 0, -5)
    frame.title:SetText("|cff33ff99BattlegroundMaster|r")

    frame.autoRequeueCheck = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    frame.autoRequeueCheck:SetPoint("TOPLEFT", 20, -30)
    frame.autoRequeueCheck.text = frame.autoRequeueCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.autoRequeueCheck.text:SetPoint("LEFT", frame.autoRequeueCheck, "RIGHT", 5, 0)
    frame.autoRequeueCheck.text:SetText("Auto-Requeue")
    frame.autoRequeueCheck:SetChecked(BattlegroundMaster.db.profile.autoRequeue)
    frame.autoRequeueCheck:SetScript("OnClick", function(self)
        BattlegroundMaster.db.profile.autoRequeue = self:GetChecked()
        BGMFrame:Print("Auto-requeue "..(BattlegroundMaster.db.profile.autoRequeue and "enabled" or "disabled")..".")
    end)

    frame.autoWintergraspCheck = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    frame.autoWintergraspCheck:SetPoint("TOPLEFT", 20, -60)
    frame.autoWintergraspCheck.text = frame.autoWintergraspCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.autoWintergraspCheck.text:SetPoint("LEFT", frame.autoWintergraspCheck, "RIGHT", 5, 0)
    frame.autoWintergraspCheck.text:SetText("Wintergrasp Auto-Queue")
    frame.autoWintergraspCheck:SetChecked(BattlegroundMaster.db.profile.autoWintergrasp)
    frame.autoWintergraspCheck:SetScript("OnClick", function(self)
        BattlegroundMaster.db.profile.autoWintergrasp = self:GetChecked()
        BGMFrame:Print("Wintergrasp auto-queue "..(BattlegroundMaster.db.profile.autoWintergrasp and "enabled" or "disabled").." (only active in Wintergrasp zone).")
    end)

    local buttonY = -90
    -- Create a table of BG keys excluding Wintergrasp
    local bgKeys = {}
    for key, bgInfo in pairs(BG_DATA) do
        if key ~= "wintergrasp" then
            table.insert(bgKeys, key)
        end
    end
    -- Sort keys based on name, but place "random" first
    table.sort(bgKeys, function(a, b)
        if a == "random" then return true
        elseif b == "random" then return false
        else return BG_DATA[a].name < BG_DATA[b].name end
    end)
    for _, bgKey in ipairs(bgKeys) do
        local bgInfo = BG_DATA[bgKey]
        local button = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        button:SetSize(260, 25)
        button:SetPoint("TOPLEFT", 20, buttonY)
        button:SetText(bgInfo.name)
        button:SetScript("OnClick", function()
            local status = nil
            local queueIndex = nil
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
        buttonY = buttonY - 30
    end

    local listButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    listButton:SetSize(260, 25)
    listButton:SetPoint("TOPLEFT", 20, buttonY)
    listButton:SetText("List Active Queues")
    listButton:SetScript("OnClick", function()
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
    end)
    buttonY = buttonY - 30

    local statsButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    statsButton:SetSize(260, 25)
    statsButton:SetPoint("TOPLEFT", 20, buttonY)
    statsButton:SetText("Show Session Stats")
    statsButton:SetScript("OnClick", function()
        BattlegroundMaster:ShowSessionStats()
    end)
    buttonY = buttonY - 30

    local resetStatsButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    resetStatsButton:SetSize(260, 25)
    resetStatsButton:SetPoint("TOPLEFT", 20, buttonY)
    resetStatsButton:SetText("Reset Session Stats")
    resetStatsButton:SetScript("OnClick", function()
        BattlegroundMaster:ResetStats()
    end)

    frame:Hide()
    self.guiFrame = frame
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
        -- Manual command to join Wintergrasp queue
        for i = 1, MAX_BATTLEFIELD_QUEUES do
            local status, mapName = GetBattlefieldStatus(i)
            if status == "confirm" and mapName and mapName:lower():find("wintergrasp") then
                AcceptBattlefieldPort(i, true)
                self:Print("Manually accepted Wintergrasp queue!")
                return
            end
        end
        self:Print("No Wintergrasp queue prompt found. Ensure you're queued and the prompt is active.")
    elseif BG_DATA[cmd] then
        local status = nil
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
        self:Print("Auto-requeue "..(BattlegroundMaster.db.profile.autoRequeue and "enabled" or "disabled")..".")
        if self.guiFrame then
            self.guiFrame.autoRequeueCheck:SetChecked(BattlegroundMaster.db.profile.autoRequeue)
        end
    elseif cmd == "stats" then
        BattlegroundMaster:ShowSessionStats()
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
        self:Print("/bm stats - Show session honor and kills")
        self:Print("/bm resetstats - Reset session stats")
    end
end

-- Register slash commands
SlashCmdList["BattlegroundMaster"] = function(msg) BGMFrame:Command(msg) end
SLASH_BattlegroundMaster1 = "/battlegroundmaster"
SLASH_BattlegroundMaster2 = "/bm"
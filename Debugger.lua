--========================================
-- Punk X Debugger - SESSION 2 FIXED
-- COMPLETE CODE - READY TO USE
--========================================

-- Services
local LogService = game:GetService("LogService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local HttpService = game:GetService("HttpService")

-- Config
local LOG_FILE_NAME = "PunkX_Logs.txt"
local MAX_LOGS = 1000

-- State
local isMinimized = false
local isFilterActive = true
local autoScrollEnabled = true
local showTimestamps = true
local showLineNumbers = true
local logCount = 0
local logHistory = {}
local virtualLogData = {}
local groupedLogs = {}
local userHasScrolled = false
local expandedGroups = {}
local pinnedSearchTerms = {} -- 🔧 Search-based pinning
local excludePatterns = {}
local currentTheme = "dark"
local fontSize = 14
local useRegex = false
local searchHistory = {}

-- Type filters
local typeFilters = {
    INFO = true,
    WARN = true,
    ERROR = true
}

-- Performance
local searchDebounce = nil
local fps = 0
local memoryUsage = 0
local ping = 0
local logRateCounter = 0
local lastRateUpdate = 0

--========================================
-- THEME SYSTEM
--========================================
local themes = {
    dark = {
        bg = Color3.fromRGB(20, 20, 20),
        logBg1 = Color3.fromRGB(35, 35, 35),
        logBg2 = Color3.fromRGB(45, 45, 45),
        text = Color3.new(1, 1, 1),
        search = Color3.fromRGB(50, 50, 50)
    },
    light = {
        bg = Color3.fromRGB(240, 240, 240),
        logBg1 = Color3.fromRGB(255, 255, 255),
        logBg2 = Color3.fromRGB(250, 250, 250),
        text = Color3.new(0, 0, 0),
        search = Color3.fromRGB(230, 230, 230)
    },
    blue = {
        bg = Color3.fromRGB(15, 25, 35),
        logBg1 = Color3.fromRGB(25, 35, 50),
        logBg2 = Color3.fromRGB(30, 45, 60),
        text = Color3.fromRGB(200, 220, 255),
        search = Color3.fromRGB(35, 50, 70)
    }
}

--========================================
-- GUI SETUP
--========================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CustomLogViewer"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then
    ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0.8, 0, 0.7, 0)
MainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Stats Bar
local StatsBar = Instance.new("TextLabel")
StatsBar.Size = UDim2.new(1, -40, 0.06, 0)
StatsBar.Position = UDim2.new(0, 0, 0, 0)
StatsBar.BackgroundTransparency = 1
StatsBar.Text = "  FPS: 0 | Memory: 0 MB | Ping: 0ms | Rate: 0/s | Logs: 0"
StatsBar.TextColor3 = Color3.new(1, 1, 1)
StatsBar.TextXAlignment = Enum.TextXAlignment.Left
StatsBar.Font = Enum.Font.GothamBold
StatsBar.TextSize = 14
StatsBar.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("TextLabel")
TitleBar.Size = UDim2.new(1, -40, 0.06, 0)
TitleBar.Position = UDim2.new(0, 0, 0.06, 0)
TitleBar.BackgroundTransparency = 1
TitleBar.Text = "  Punk X Debugger"
TitleBar.TextColor3 = Color3.fromRGB(100, 200, 255)
TitleBar.TextXAlignment = Enum.TextXAlignment.Left
TitleBar.Font = Enum.Font.GothamBold
TitleBar.TextSize = 16
TitleBar.Parent = MainFrame

--========================================
-- PERFORMANCE MONITORING
--========================================
local lastUpdate = tick()
local frameCount = 0

RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local now = tick()
    
    if now - lastUpdate >= 1 then
        fps = frameCount
        frameCount = 0
        lastUpdate = now
        
        memoryUsage = math.floor(Stats:GetTotalMemoryUsageMb())
        
        local player = Players.LocalPlayer
        if player then
            ping = math.floor(player:GetNetworkPing() * 1000)
        end
        
        local logRate = logRateCounter
        logRateCounter = 0
        
        StatsBar.Text = string.format(
            "  FPS: %d | Memory: %d MB | Ping: %dms | Rate: %d/s | Logs: %d",
            fps, memoryUsage, ping, logRate, #virtualLogData
        )
    end
end)

--========================================
-- DRAGGABLE
--========================================
local dragging, dragInput, dragStart, startPos

local function updateDrag(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(
        startPos.X.Scale, startPos.X.Offset + delta.X,
        startPos.Y.Scale, startPos.Y.Offset + delta.Y
    )
end

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateDrag(input)
    end
end)

-- Search Box
local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(0.96, 0, 0.05, 0)
SearchBox.Position = UDim2.new(0.02, 0, 0.14, 0)
SearchBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SearchBox.PlaceholderText = "Search logs... (Regex: OFF)"
SearchBox.Text = ""
SearchBox.ClearTextOnFocus = false
SearchBox.TextColor3 = Color3.new(1, 1, 1)
SearchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextSize = 14
SearchBox.TextXAlignment = Enum.TextXAlignment.Left
SearchBox.Parent = MainFrame
Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 6)

local SearchPadding = Instance.new("UIPadding", SearchBox)
SearchPadding.PaddingLeft = UDim.new(0, 8)

-- Scroll Frame
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Position = UDim2.new(0.02, 0, 0.20, 0)
ScrollFrame.Size = UDim2.new(0.96, 0, 0.50, 0)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ScrollFrame.BorderSizePixel = 0
ScrollFrame.Parent = MainFrame
Instance.new("UICorner", ScrollFrame)

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollFrame

--========================================
-- RESIZABLE
--========================================
local ResizeHandle = Instance.new("TextButton")
ResizeHandle.Size = UDim2.new(0, 30, 0, 30)
ResizeHandle.Position = UDim2.new(1, -30, 1, -30)
ResizeHandle.AnchorPoint = Vector2.new(0, 0)
ResizeHandle.BackgroundTransparency = 1
ResizeHandle.Text = "↗"
ResizeHandle.TextColor3 = Color3.fromRGB(180, 180, 180)
ResizeHandle.Font = Enum.Font.GothamBold
ResizeHandle.TextSize = 18
ResizeHandle.ZIndex = 10
ResizeHandle.Parent = MainFrame

ResizeHandle.MouseEnter:Connect(function()
    ResizeHandle.TextColor3 = Color3.fromRGB(255, 255, 255)
end)

ResizeHandle.MouseLeave:Connect(function()
    ResizeHandle.TextColor3 = Color3.fromRGB(180, 180, 180)
end)

local resizing = false

ResizeHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        resizing = true
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local mousePos = input.Position
        local framePos = MainFrame.AbsolutePosition
        
        local newWidth = math.max(300, mousePos.X - framePos.X)
        local newHeight = math.max(180, mousePos.Y - framePos.Y)
        
        MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        resizing = false
    end
end)

--========================================
-- TOGGLE BUTTON
--========================================
local ToggleButton = Instance.new("ImageButton")
ToggleButton.Name = "DebugToggle"
ToggleButton.Size = UDim2.new(0, 45, 0, 45)
ToggleButton.Position = UDim2.new(0, 10, 0.5, -22)
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleButton.BackgroundTransparency = 0.3
ToggleButton.BorderSizePixel = 0
ToggleButton.Image = "rbxthumb://type=Asset&id=121884098955130&w=420&h=420"
ToggleButton.ScaleType = Enum.ScaleType.Fit
ToggleButton.Parent = ScreenGui
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(1, 0)

ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

local toggleDragging = false
local toggleDragStart, toggleStartPos

ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        toggleDragging = true
        toggleDragStart = input.Position
        toggleStartPos = ToggleButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                toggleDragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if toggleDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - toggleDragStart
        ToggleButton.Position = UDim2.new(
            toggleStartPos.X.Scale, toggleStartPos.X.Offset + delta.X,
            toggleStartPos.Y.Scale, toggleStartPos.Y.Offset + delta.Y
        )
    end
end)

--========================================
-- HELPERS
--========================================

local function sanitize(t)
    return t:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
end

local function escapePattern(t)
    return t:gsub("([%(%)%.%%%+%-%*%?%[%^%$])", "%%%1")
end

local function isSpam(msg)
    msg = msg:lower()
    
    if msg:find("invocation queue exhausted") or
       msg:find("discarded event") or
       msg:find("did you forget to implement onclientevent") then
        return true
    end
    
    return false
end

local function isExcluded(msg)
    if not msg then return false end -- 🔧 FIX: Safety check
    msg = tostring(msg):lower() -- 🔧 FIX: Convert to string first
    for _, pattern in ipairs(excludePatterns) do
        if msg:find(pattern:lower(), 1, true) then
            return true
        end
    end
    return false
end

local function isPinned(msg)
    if #pinnedSearchTerms == 0 then return false end
    if not msg then return false end -- 🔧 FIX: Safety check
    msg = tostring(msg):lower() -- 🔧 FIX: Convert to string first
    for _, term in ipairs(pinnedSearchTerms) do
        if msg:find(term:lower(), 1, true) then
            return true
        end
    end
    return false
end

local function highlightText(text, searchTerm)
    if searchTerm == "" then return sanitize(text) end
    
    local sanitizedText = sanitize(text)
    
    if useRegex then
        local success, result = pcall(function()
            return sanitizedText:gsub("(" .. searchTerm .. ")", '<font color="rgb(255,255,0)"><b>%1</b></font>')
        end)
        if success then return result end
    end
    
    local result = ""
    local lastPos = 1
    local lowerText = text:lower()
    local lowerSearch = searchTerm:lower()
    
    local startPos = 1
    while true do
        local foundStart, foundEnd = lowerText:find(escapePattern(lowerSearch), startPos, true)
        if not foundStart then break end
        
        result = result .. sanitize(text:sub(lastPos, foundStart - 1))
        local matchText = text:sub(foundStart, foundEnd)
        result = result .. '<font color="rgb(255,255,0)"><b>' .. sanitize(matchText) .. '</b></font>'
        
        lastPos = foundEnd + 1
        startPos = foundEnd + 1
    end
    
    result = result .. sanitize(text:sub(lastPos))
    return result
end

--========================================
-- FILE LOGGING & EXPORT
--========================================

pcall(function()
    if writefile then
        writefile(LOG_FILE_NAME, "-- Session Start --\n")
    end
end)

local function saveLog(text)
    pcall(function()
        if appendfile then
            appendfile(LOG_FILE_NAME, text .. "\n")
        elseif writefile and readfile then
            local c = ""
            pcall(function() c = readfile(LOG_FILE_NAME) end)
            writefile(LOG_FILE_NAME, c .. text .. "\n")
        end
    end)
end

local function exportToJSON()
    local data = {
        session = os.date("%Y-%m-%d %H:%M:%S"),
        logs = {}
    }
    
    for _, log in ipairs(virtualLogData) do
        table.insert(data.logs, {
            index = log.index,
            time = log.time,
            type = log.type,
            message = log.message,
            count = log.count
        })
    end
    
    local json = HttpService:JSONEncode(data)
    pcall(function()
        if writefile then
            writefile("PunkX_Logs.json", json)
        end
    end)
end

local function exportToCSV()
    local csv = "Index,Time,Type,Message,Count\n"
    for _, log in ipairs(virtualLogData) do
        csv = csv .. string.format('%d,"%s","%s","%s",%d\n',
            log.index, log.time, log.type, log.message:gsub('"', '""'), log.count)
    end
    
    pcall(function()
        if writefile then
            writefile("PunkX_Logs.csv", csv)
        end
    end)
end

--========================================
-- LOG GROUPING
--========================================
local function getLogKey(message, messageType)
    return string.format("%s|%s", tostring(messageType), message)
end

--========================================
-- ADD LOG
--========================================

local function addLog(message, messageType)
    logRateCounter = logRateCounter + 1
    
    if isExcluded(message) then
        return
    end
    
    local logKey = getLogKey(message, messageType)
    
    if groupedLogs[logKey] then
        groupedLogs[logKey].count = groupedLogs[logKey].count + 1
        groupedLogs[logKey].lastTime = os.date("%X")
        groupedLogs[logKey].isPinned = isPinned(message)
        task.spawn(function()
            task.wait(0.05)
            refreshVirtualScroll()
        end)
        return
    end
    
    logCount = logCount + 1

    local color = Color3.fromRGB(220, 220, 220)
    local prefix = "[INFO]"
    local logType = "INFO"

    if messageType == Enum.MessageType.MessageWarning then
        color = Color3.fromRGB(255, 200, 0)
        prefix = "[WARN]"
        logType = "WARN"
    elseif messageType == Enum.MessageType.MessageError then
        color = Color3.fromRGB(255, 80, 80)
        prefix = "[ERR]"
        logType = "ERROR"
    end

    local time = os.date("%X")
    local full = string.format("[%s] %s %s", time, prefix, message)

    local logData = {
        index = logCount,
        time = time,
        prefix = prefix,
        message = message,
        full = full,
        color = color,
        type = logType,
        isSpam = isSpam(message),
        count = 1,
        key = logKey,
        isPinned = isPinned(message),
        isExpanded = false
    }
    
    table.insert(virtualLogData, logData)
    groupedLogs[logKey] = logData
    table.insert(logHistory, full)
    saveLog(full)

    if #virtualLogData > MAX_LOGS then
        local removed = table.remove(virtualLogData, 1)
        groupedLogs[removed.key] = nil
    end

    refreshVirtualScroll()
    
    if autoScrollEnabled then
        task.spawn(function()
            task.wait(0.15)
            ScrollFrame.CanvasPosition = Vector2.new(0, ScrollFrame.CanvasSize.Y.Offset)
        end)
    end
end

--========================================
-- VIRTUAL SCROLL REFRESH
--========================================

function refreshVirtualScroll()
    local term = SearchBox.Text
    local visibleLogs = {}
    
    -- Add pinned logs first
    for _, logData in ipairs(virtualLogData) do
        if logData.isPinned then
            table.insert(visibleLogs, logData)
        end
    end
    
    -- Filter regular logs
    for _, logData in ipairs(virtualLogData) do
        if not logData.isPinned then
            local show = true
            
            if not typeFilters[logData.type] then
                show = false
            end
            
            if show and isFilterActive and logData.isSpam then
                show = false
            end
            
            if show and term ~= "" then
                if useRegex then
                    local success = pcall(function()
                        return logData.full:find(term)
                    end)
                    if not success then show = false end
                else
                    local searchLower = term:lower()
                    if not logData.full:lower():find(escapePattern(searchLower), 1, true) then
                        show = false
                    end
                end
            end
            
            if show then
                table.insert(visibleLogs, logData)
            end
        end
    end
    
    -- Clear existing labels
    for _, child in ipairs(ScrollFrame:GetChildren()) do
        if child:IsA("TextLabel") or child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    -- Create labels
    for i, logData in ipairs(visibleLogs) do
        local isGrouped = logData.count > 1
        local element = isGrouped and Instance.new("TextButton") or Instance.new("TextLabel")
        
        element.Size = UDim2.new(1, 0, 0, 0)
        element.AutomaticSize = Enum.AutomaticSize.Y
        element.TextWrapped = true
        element.RichText = true
        element.Font = Enum.Font.Code
        element.TextSize = fontSize
        element.TextXAlignment = Enum.TextXAlignment.Left
        element.TextYAlignment = Enum.TextYAlignment.Top
        element.BackgroundTransparency = 0
        element.Parent = ScrollFrame
        
        local pad = Instance.new("UIPadding", element)
        pad.PaddingLeft = UDim.new(0, 6)
        pad.PaddingRight = UDim.new(0, 6)
        pad.PaddingTop = UDim.new(0, 4)
        pad.PaddingBottom = UDim.new(0, 4)
        
        local displayText = ""
        
        if logData.isPinned then
            displayText = "📌 "
        end
        
        if isGrouped then
            displayText = displayText .. (expandedGroups[logData.key] and "▼ " or "▶ ")
        end
        
        if showLineNumbers then
            displayText = displayText .. string.format("[%d] ", logData.index)
        end
        
        if showTimestamps then
            displayText = displayText .. string.format("[%s] ", logData.time)
        end
        
        displayText = displayText .. string.format("%s %s", logData.prefix, logData.message)
        
        if logData.count > 1 then
            displayText = displayText .. string.format(" <b>(x%d)</b>", logData.count)
        end
        
        element.Text = highlightText(displayText, term)
        element.TextColor3 = logData.color
        
        local theme = themes[currentTheme]
        element.BackgroundColor3 = (i % 2 == 0) and theme.logBg2 or theme.logBg1
        
        if isGrouped and element:IsA("TextButton") then
            element.MouseButton1Click:Connect(function()
                expandedGroups[logData.key] = not expandedGroups[logData.key]
                refreshVirtualScroll()
            end)
        end
        
        if isGrouped and expandedGroups[logData.key] then
            local detailText = Instance.new("TextLabel")
            detailText.Size = UDim2.new(1, 0, 0, 0)
            detailText.AutomaticSize = Enum.AutomaticSize.Y
            detailText.TextWrapped = true
            detailText.RichText = true
            detailText.Font = Enum.Font.Code
            detailText.TextSize = fontSize - 2
            detailText.TextXAlignment = Enum.TextXAlignment.Left
            detailText.TextYAlignment = Enum.TextYAlignment.Top
            detailText.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            detailText.TextColor3 = Color3.fromRGB(180, 180, 180)
            detailText.Text = string.format("  └─ Occurred %d times\n  └─ Last: %s", 
                logData.count, logData.lastTime)
            detailText.Parent = ScrollFrame
            
            local detailPad = Instance.new("UIPadding", detailText)
            detailPad.PaddingLeft = UDim.new(0, 20)
            detailPad.PaddingRight = UDim.new(0, 6)
            detailPad.PaddingTop = UDim.new(0, 2)
            detailPad.PaddingBottom = UDim.new(0, 4)
        end
    end
    
    RunService.Heartbeat:Wait()
    RunService.Heartbeat:Wait()
    
    local contentHeight = UIListLayout.AbsoluteContentSize.Y
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentHeight + 20)
end

--========================================
-- SEARCH (FIXED DEBOUNCE CANCEL BUG)
--========================================

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    -- 🔧 FIX: Properly cancel task using task.cancel()
    if searchDebounce then
        task.cancel(searchDebounce)
        searchDebounce = nil
    end
    
    searchDebounce = task.delay(0.3, function()
        local term = SearchBox.Text
        if term ~= "" and not table.find(searchHistory, term) then
            table.insert(searchHistory, 1, term)
            if #searchHistory > 10 then
                table.remove(searchHistory)
            end
        end
        refreshVirtualScroll()
        searchDebounce = nil
    end)
end)

--========================================
-- HISTORY + LIVE LOGS
--========================================

task.spawn(function()
    local ok, hist = pcall(LogService.GetLogHistory, LogService)
    if ok then
        addLog("--- DEBUGGER LOADED ---", Enum.MessageType.MessageInfo)
        for _, v in ipairs(hist) do
            addLog(v.message, v.messageType)
        end
        addLog("--- LIVE LOGS BEGIN ---", Enum.MessageType.MessageInfo)
    end
end)

LogService.MessageOut:Connect(addLog)

--========================================
-- BUTTONS - MONOCHROME PROFESSIONAL 🎨
--========================================

-- Professional Color Palette
local btnColors = {
    default = Color3.fromRGB(45, 45, 45),
    hover = Color3.fromRGB(60, 60, 60),
    active = Color3.fromRGB(70, 70, 70),
    disabled = Color3.fromRGB(35, 35, 35),
    
    -- Accent colors (only when button is ON/active)
    accentInfo = Color3.fromRGB(70, 130, 220),
    accentWarn = Color3.fromRGB(220, 160, 50),
    accentError = Color3.fromRGB(220, 70, 70),
    accentSuccess = Color3.fromRGB(70, 180, 90),
    accentNeutral = Color3.fromRGB(100, 100, 100)
}

-- Row 1: Type Filters
local FilterRow = Instance.new("Frame", MainFrame)
FilterRow.Size = UDim2.new(0.96, 0, 0.05, 0)
FilterRow.Position = UDim2.new(0.02, 0, 0.71, 0)
FilterRow.BackgroundTransparency = 1

local function mkFilterBtn(txt, accentColor, x, width)
    width = width or 0.19
    local b = Instance.new("TextButton", FilterRow)
    b.Size = UDim2.new(width, -4, 1, 0)
    b.Position = UDim2.new(x, 0, 0, 0)
    b.BackgroundColor3 = btnColors.default
    b.Text = txt
    b.Font = Enum.Font.GothamBold
    b.TextColor3 = Color3.new(1, 1, 1)
    b.TextSize = 11
    local corner = Instance.new("UICorner", b)
    corner.CornerRadius = UDim.new(0, 4)
    
    -- Store accent color for later
    b:SetAttribute("AccentColor", accentColor)
    
    -- Hover effect
    b.MouseEnter:Connect(function()
        if b.BackgroundColor3 == btnColors.default then
            b.BackgroundColor3 = btnColors.hover
        end
    end)
    
    b.MouseLeave:Connect(function()
        if b.BackgroundColor3 == btnColors.hover then
            b.BackgroundColor3 = btnColors.default
        end
    end)
    
    return b
end

local InfoBtn = mkFilterBtn("INFO", "accentInfo", 0, 0.15)
local WarnBtn = mkFilterBtn("WARN", "accentWarn", 0.16, 0.15)
local ErrorBtn = mkFilterBtn("ERROR", "accentError", 0.32, 0.15)
local TimestampBtn = mkFilterBtn("Time", "accentNeutral", 0.48, 0.12)
local LineNumBtn = mkFilterBtn("Line", "accentNeutral", 0.61, 0.12)
local RegexBtn = mkFilterBtn("Regex", "accentNeutral", 0.74, 0.12)
local FontBtn = mkFilterBtn("A" .. fontSize, "accentNeutral", 0.87, 0.12)

-- Row 2: Main Controls
local BtnFrame = Instance.new("Frame", MainFrame)
BtnFrame.Size = UDim2.new(0.96, 0, 0.05, 0)
BtnFrame.Position = UDim2.new(0.02, 0, 0.78, 0)
BtnFrame.BackgroundTransparency = 1

local function mkBtn(txt, accentColor, x, width)
    width = width or 0.15
    local b = Instance.new("TextButton", BtnFrame)
    b.Size = UDim2.new(width, -4, 1, 0)
    b.Position = UDim2.new(x, 0, 0, 0)
    b.BackgroundColor3 = btnColors.default
    b.Text = txt
    b.Font = Enum.Font.GothamBold
    b.TextColor3 = Color3.new(1, 1, 1)
    b.TextSize = 11
    local corner = Instance.new("UICorner", b)
    corner.CornerRadius = UDim.new(0, 4)
    
    b:SetAttribute("AccentColor", accentColor)
    
    b.MouseEnter:Connect(function()
        if b.BackgroundColor3 == btnColors.default then
            b.BackgroundColor3 = btnColors.hover
        end
    end)
    
    b.MouseLeave:Connect(function()
        if b.BackgroundColor3 == btnColors.hover then
            b.BackgroundColor3 = btnColors.default
        end
    end)
    
    return b
end

local Copy = mkBtn("Copy", "accentInfo", 0, 0.158)
local Clear = mkBtn("Clear", "accentError", 0.168, 0.158)
local Filter = mkBtn("Filter", "accentSuccess", 0.336, 0.158)
local AutoScroll = mkBtn("Scroll", "accentNeutral", 0.504, 0.158)
local ExportBtn = mkBtn("Export", "accentInfo", 0.672, 0.158)
local ThemeBtn = mkBtn("Theme", "accentNeutral", 0.84, 0.158)

-- Row 3: Advanced
local AdvRow = Instance.new("Frame", MainFrame)
AdvRow.Size = UDim2.new(0.96, 0, 0.05, 0)
AdvRow.Position = UDim2.new(0.02, 0, 0.84, 0)
AdvRow.BackgroundTransparency = 1

local PinBtn = mkBtn("Pin", "accentWarn", 0, 0.158)
PinBtn.Parent = AdvRow

local ExcludeBtn = mkBtn("Exclude", "accentError", 0.168, 0.158)
ExcludeBtn.Parent = AdvRow

local HistoryBtn = mkBtn("History", "accentSuccess", 0.336, 0.158)
HistoryBtn.Parent = AdvRow

local Close = mkBtn("Close", "accentError", 0.504, 0.158)
Close.Parent = AdvRow

--========================================
-- DYNAMIC BUTTON SCALING
--========================================
local allButtons = {
    InfoBtn, WarnBtn, ErrorBtn, TimestampBtn, LineNumBtn, RegexBtn, FontBtn,
    Copy, Clear, Filter, AutoScroll, ExportBtn, ThemeBtn,
    PinBtn, ExcludeBtn, HistoryBtn, Close
}

local function updateButtonSizes(width)
    local textSize
    if width >= 500 then
        textSize = 11
    elseif width >= 400 then
        textSize = 9
    else
        textSize = 7
    end
    
    for _, btn in ipairs(allButtons) do
        btn.TextSize = textSize
    end
    
    StatsBar.TextSize = math.max(10, textSize + 2)
    TitleBar.TextSize = math.max(12, textSize + 4)
end

updateButtonSizes(MainFrame.AbsoluteSize.X)

ScrollFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
    if autoScrollEnabled and not userHasScrolled then
        local atBottom = ScrollFrame.CanvasPosition.Y >= (ScrollFrame.CanvasSize.Y.Offset - ScrollFrame.AbsoluteSize.Y - 10)
        if not atBottom then
            userHasScrolled = true
            autoScrollEnabled = false
            if AutoScroll then
                AutoScroll.Text = "Scroll"
                AutoScroll.BackgroundColor3 = Color3.fromRGB(150, 80, 80)
            end
        end
    end
end)

--========================================
-- BUTTON HANDLERS (WITH MONOCHROME STATES)
--========================================

-- Helper function to set button active state
local function setButtonActive(button, isActive)
    local accentName = button:GetAttribute("AccentColor")
    if isActive then
        button.BackgroundColor3 = btnColors[accentName] or btnColors.active
    else
        button.BackgroundColor3 = btnColors.default
    end
end

InfoBtn.MouseButton1Click:Connect(function()
    typeFilters.INFO = not typeFilters.INFO
    setButtonActive(InfoBtn, typeFilters.INFO)
    refreshVirtualScroll()
end)

WarnBtn.MouseButton1Click:Connect(function()
    typeFilters.WARN = not typeFilters.WARN
    setButtonActive(WarnBtn, typeFilters.WARN)
    refreshVirtualScroll()
end)

ErrorBtn.MouseButton1Click:Connect(function()
    typeFilters.ERROR = not typeFilters.ERROR
    setButtonActive(ErrorBtn, typeFilters.ERROR)
    refreshVirtualScroll()
end)

TimestampBtn.MouseButton1Click:Connect(function()
    showTimestamps = not showTimestamps
    setButtonActive(TimestampBtn, showTimestamps)
    refreshVirtualScroll()
end)

LineNumBtn.MouseButton1Click:Connect(function()
    showLineNumbers = not showLineNumbers
    setButtonActive(LineNumBtn, showLineNumbers)
    refreshVirtualScroll()
end)

RegexBtn.MouseButton1Click:Connect(function()
    useRegex = not useRegex
    setButtonActive(RegexBtn, useRegex)
    SearchBox.PlaceholderText = useRegex and "Search logs... (Regex: ON)" or "Search logs... (Regex: OFF)"
    refreshVirtualScroll()
end)

FontBtn.MouseButton1Click:Connect(function()
    fontSize = fontSize + 2
    if fontSize > 18 then fontSize = 10 end
    FontBtn.Text = "A" .. fontSize
    refreshVirtualScroll()
end)

Filter.MouseButton1Click:Connect(function()
    isFilterActive = not isFilterActive
    setButtonActive(Filter, isFilterActive)
    refreshVirtualScroll()
end)

AutoScroll.MouseButton1Click:Connect(function()
    autoScrollEnabled = not autoScrollEnabled
    setButtonActive(AutoScroll, autoScrollEnabled)
    if autoScrollEnabled then
        userHasScrolled = false
        task.wait(0.1)
        ScrollFrame.CanvasPosition = Vector2.new(0, ScrollFrame.CanvasSize.Y.Offset)
        task.wait(0.2)
        autoScrollEnabled = false
        setButtonActive(AutoScroll, false)
    end
end)

Clear.MouseButton1Click:Connect(function()
    virtualLogData = {}
    groupedLogs = {}
    logHistory = {}
    logCount = 0
    expandedGroups = {}
    refreshVirtualScroll()
end)

Copy.MouseButton1Click:Connect(function()
    local txt = table.concat(logHistory, "\n")
    local ok = pcall(function()
        if setclipboard then
            setclipboard(txt)
        elseif toclipboard then
            toclipboard(txt)
        else
            error()
        end
    end)
    Copy.Text = ok and "✓" or "✗"
    Copy.BackgroundColor3 = ok and btnColors.accentSuccess or btnColors.accentError
    task.wait(1)
    Copy.Text = "Copy"
    Copy.BackgroundColor3 = btnColors.default
end)

--========================================
-- 🔧 FIXED: EXPORT, THEME, PIN, EXCLUDE, HISTORY
--========================================

-- Export Menu
local exportMenuOpen = false
ExportBtn.MouseButton1Click:Connect(function()
    if exportMenuOpen then return end
    exportMenuOpen = true
    
    local menu = Instance.new("Frame")
    menu.Size = UDim2.new(0.2, 0, 0.15, 0)
    menu.Position = UDim2.new(0.64, 0, 0.63, 0)
    menu.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    menu.BorderSizePixel = 0
    menu.ZIndex = 100
    menu.Parent = MainFrame
    Instance.new("UICorner", menu)

    local function mkExportBtn(txt, y, callback)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0.9, 0, 0.28, 0)
        b.Position = UDim2.new(0.05, 0, y, 0)
        b.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        b.Text = txt
        b.TextColor3 = Color3.new(1, 1, 1)
        b.Font = Enum.Font.Gotham
        b.TextSize = 10
        b.ZIndex = 101
        b.Parent = menu
        Instance.new("UICorner", b)
        b.MouseButton1Click:Connect(function()
            callback()
            menu:Destroy()
            exportMenuOpen = false
        end)
    end

    mkExportBtn(".txt", 0.05, function()
        saveLog("=== EXPORT ===")
        ExportBtn.Text = "✓ TXT"
        task.wait(1)
        ExportBtn.Text = "Export"
    end)

    mkExportBtn(".json", 0.36, function()
        exportToJSON()
        ExportBtn.Text = "✓ JSON"
        task.wait(1)
        ExportBtn.Text = "Export"
    end)

    mkExportBtn(".csv", 0.67, function()
        exportToCSV()
        ExportBtn.Text = "✓ CSV"
        task.wait(1)
        ExportBtn.Text = "Export"
    end)

    task.wait(5)
    if menu.Parent then
        menu:Destroy()
        exportMenuOpen = false
    end
end)

-- 🔧 FIXED: Theme Switcher (now works!)
local function applyTheme(themeName)
    local theme = themes[themeName] or themes.dark
    MainFrame.BackgroundColor3 = theme.bg
    ScrollFrame.BackgroundColor3 = theme.bg
    SearchBox.BackgroundColor3 = theme.search
    SearchBox.TextColor3 = theme.text
    currentTheme = themeName
    refreshVirtualScroll()
end

local themeMenuOpen = false
ThemeBtn.MouseButton1Click:Connect(function()
    if themeMenuOpen then return end
    themeMenuOpen = true
    
    local menu = Instance.new("Frame")
    menu.Size = UDim2.new(0.15, 0, 0.15, 0)
    menu.Position = UDim2.new(0.8, 0, 0.63, 0)
    menu.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    menu.BorderSizePixel = 0
    menu.ZIndex = 100
    menu.Parent = MainFrame
    Instance.new("UICorner", menu)

    local function mkThemeBtn(txt, y, themeName)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0.9, 0, 0.28, 0)
        b.Position = UDim2.new(0.05, 0, y, 0)
        b.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        b.Text = txt
        b.TextColor3 = Color3.new(1, 1, 1)
        b.Font = Enum.Font.Gotham
        b.TextSize = 10
        b.ZIndex = 101
        b.Parent = menu
        Instance.new("UICorner", b)
        b.MouseButton1Click:Connect(function()
            applyTheme(themeName)
            menu:Destroy()
            themeMenuOpen = false
        end)
    end

    mkThemeBtn("Dark", 0.05, "dark")
    mkThemeBtn("Light", 0.36, "light")
    mkThemeBtn("Blue", 0.67, "blue")

    task.wait(5)
    if menu.Parent then
        menu:Destroy()
        themeMenuOpen = false
    end
end)

-- 🔧 FIXED: Pin by Search Term (with safety checks)
PinBtn.MouseButton1Click:Connect(function()
    local term = SearchBox.Text
    if term == "" then
        PinBtn.Text = "Empty!"
        PinBtn.BackgroundColor3 = btnColors.accentError
        task.wait(1)
        PinBtn.Text = "Pin"
        PinBtn.BackgroundColor3 = btnColors.default
        return
    end
    
    local alreadyPinned = table.find(pinnedSearchTerms, term)
    if alreadyPinned then
        table.remove(pinnedSearchTerms, alreadyPinned)
        PinBtn.Text = "Unpinned"
        PinBtn.BackgroundColor3 = btnColors.hover
    else
        table.insert(pinnedSearchTerms, term)
        PinBtn.Text = "Pinned!"
        PinBtn.BackgroundColor3 = btnColors.accentSuccess
    end
    
    -- 🔧 FIX: Safely update pin status with error handling
    pcall(function()
        for _, logData in ipairs(virtualLogData) do
            if logData and logData.message then
                logData.isPinned = isPinned(logData.message)
            end
        end
    end)
    
    refreshVirtualScroll()
    
    task.wait(1.5)
    PinBtn.Text = "Pin"
    PinBtn.BackgroundColor3 = btnColors.default
end)

-- 🔧 IMPROVED: Exclude with Management UI
local excludeMenuOpen = false
ExcludeBtn.MouseButton1Click:Connect(function()
    local term = SearchBox.Text
    
    -- If search box is empty, show management UI
    if term == "" then
        if excludeMenuOpen then return end
        
        if #excludePatterns == 0 then
            ExcludeBtn.Text = "No exclusions!"
            task.wait(1)
            ExcludeBtn.Text = "Exclude"
            return
        end
        
        -- Show exclusion management menu
        excludeMenuOpen = true
        
        local menu = Instance.new("ScrollingFrame")
        menu.Size = UDim2.new(0.35, 0, 0.3, 0)
        menu.Position = UDim2.new(0.168, 0, 0.52, 0)
        menu.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        menu.BorderSizePixel = 0
        menu.ZIndex = 100
        menu.ScrollBarThickness = 4
        menu.Parent = MainFrame
        Instance.new("UICorner", menu)
        
        -- Title
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 25)
        title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        title.Text = "  Excluded Patterns (" .. #excludePatterns .. ")"
        title.TextColor3 = Color3.new(1, 1, 1)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 11
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.ZIndex = 101
        title.Parent = menu
        Instance.new("UICorner", title)
        
        local layout = Instance.new("UIListLayout", menu)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 2)
        
        -- List excluded patterns
        for i, pattern in ipairs(excludePatterns) do
            local item = Instance.new("Frame")
            item.Size = UDim2.new(1, -10, 0, 28)
            item.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            item.ZIndex = 101
            item.LayoutOrder = i
            item.Parent = menu
            Instance.new("UICorner", item)
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -35, 1, 0)
            label.Position = UDim2.new(0, 5, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = pattern
            label.TextColor3 = Color3.new(1, 1, 1)
            label.Font = Enum.Font.Gotham
            label.TextSize = 10
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.TextTruncate = Enum.TextTruncate.AtEnd
            label.ZIndex = 102
            label.Parent = item
            
            -- Remove button
            local removeBtn = Instance.new("TextButton")
            removeBtn.Size = UDim2.new(0, 25, 0, 20)
            removeBtn.Position = UDim2.new(1, -30, 0.5, -10)
            removeBtn.BackgroundColor3 = btnColors.accentError
            removeBtn.Text = "✕"
            removeBtn.TextColor3 = Color3.new(1, 1, 1)
            removeBtn.Font = Enum.Font.GothamBold
            removeBtn.TextSize = 12
            removeBtn.ZIndex = 102
            removeBtn.Parent = item
            Instance.new("UICorner", removeBtn).CornerRadius = UDim.new(0, 3)
            
            removeBtn.MouseButton1Click:Connect(function()
                -- Remove pattern
                for j, p in ipairs(excludePatterns) do
                    if p == pattern then
                        table.remove(excludePatterns, j)
                        break
                    end
                end
                
                -- Update button text
                if #excludePatterns > 0 then
                    ExcludeBtn.Text = "Exclude (" .. #excludePatterns .. ")"
                else
                    ExcludeBtn.Text = "Exclude"
                end
                
                -- Close menu and refresh
                menu:Destroy()
                excludeMenuOpen = false
                refreshVirtualScroll()
            end)
        end
        
        -- Clear All button
        local clearAll = Instance.new("TextButton")
        clearAll.Size = UDim2.new(1, -10, 0, 30)
        clearAll.BackgroundColor3 = btnColors.accentError
        clearAll.Text = "Clear All Exclusions"
        clearAll.TextColor3 = Color3.new(1, 1, 1)
        clearAll.Font = Enum.Font.GothamBold
        clearAll.TextSize = 11
        clearAll.ZIndex = 101
        clearAll.LayoutOrder = 999
        clearAll.Parent = menu
        Instance.new("UICorner", clearAll)
        
        clearAll.MouseButton1Click:Connect(function()
            excludePatterns = {}
            ExcludeBtn.Text = "Exclude"
            menu:Destroy()
            excludeMenuOpen = false
            refreshVirtualScroll()
        end)
        
        RunService.Heartbeat:Wait()
        menu.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
        
        task.wait(10)
        if menu.Parent then
            menu:Destroy()
            excludeMenuOpen = false
        end
        
        return
    end
    
    -- Add new exclusion
    if table.find(excludePatterns, term) then
        ExcludeBtn.Text = "Already excluded!"
        ExcludeBtn.BackgroundColor3 = btnColors.accentWarn
        task.wait(1)
        if #excludePatterns > 0 then
            ExcludeBtn.Text = "Exclude (" .. #excludePatterns .. ")"
        else
            ExcludeBtn.Text = "Exclude"
        end
        ExcludeBtn.BackgroundColor3 = btnColors.default
        return
    end
    
    table.insert(excludePatterns, term)
    ExcludeBtn.Text = "✓ Added"
    ExcludeBtn.BackgroundColor3 = btnColors.accentSuccess
    refreshVirtualScroll()
    
    task.wait(1.5)
    ExcludeBtn.Text = "Exclude (" .. #excludePatterns .. ")"
    ExcludeBtn.BackgroundColor3 = btnColors.default
end)

-- 🔧 FIXED: History Dropdown
local historyMenuOpen = false
HistoryBtn.MouseButton1Click:Connect(function()
    if historyMenuOpen then return end
    if #searchHistory == 0 then
        HistoryBtn.Text = "Empty!"
        task.wait(1)
        HistoryBtn.Text = "History"
        return
    end
    
    historyMenuOpen = true
    
    local menu = Instance.new("ScrollingFrame")
    menu.Size = UDim2.new(0.3, 0, 0.25, 0)
    menu.Position = UDim2.new(0.42, 0, 0.57, 0)
    menu.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    menu.BorderSizePixel = 0
    menu.ZIndex = 100
    menu.ScrollBarThickness = 4
    menu.Parent = MainFrame
    Instance.new("UICorner", menu)
    
    local layout = Instance.new("UIListLayout", menu)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    for i, term in ipairs(searchHistory) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, -10, 0, 30)
        b.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        b.Text = term
        b.TextColor3 = Color3.new(1, 1, 1)
        b.Font = Enum.Font.Gotham
        b.TextSize = 10
        b.TextXAlignment = Enum.TextXAlignment.Left
        b.ZIndex = 101
        b.LayoutOrder = i
        b.Parent = menu
        Instance.new("UICorner", b)
        
        local pad = Instance.new("UIPadding", b)
        pad.PaddingLeft = UDim.new(0, 8)
        
        b.MouseButton1Click:Connect(function()
            SearchBox.Text = term
            menu:Destroy()
            historyMenuOpen = false
        end)
    end
    
    RunService.Heartbeat:Wait()
    menu.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    
    task.wait(8)
    if menu.Parent then
        menu:Destroy()
        historyMenuOpen = false
    end
end)

Close.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

--========================================
-- INITIAL SETUP - SET DEFAULT BUTTON STATES
--========================================
refreshVirtualScroll()

-- Set initial active states for toggle buttons
setButtonActive(InfoBtn, typeFilters.INFO)
setButtonActive(WarnBtn, typeFilters.WARN)
setButtonActive(ErrorBtn, typeFilters.ERROR)
setButtonActive(TimestampBtn, showTimestamps)
setButtonActive(LineNumBtn, showLineNumbers)
setButtonActive(RegexBtn, useRegex)
setButtonActive(Filter, isFilterActive)


print("Punk X Debugger")
print("🎮 Ready to debug!")

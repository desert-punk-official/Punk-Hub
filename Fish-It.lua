repeat task.wait() until game:IsLoaded()
local settings = {
    playerGui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui"),
    interface = nil,
    fishingCatchFrame = nil,
    timingBar = nil,
    successArea = nil
}
settings.interface = settings.playerGui and settings.playerGui:FindFirstChild("Interface")
settings.fishingCatchFrame = settings.interface and settings.interface:FindFirstChild("FishingCatchFrame")
settings.timingBar = settings.fishingCatchFrame and settings.fishingCatchFrame:FindFirstChild("TimingBar")
settings.successArea = settings.timingBar and settings.timingBar:FindFirstChild("SuccessArea")
if settings.successArea then
    settings.successArea:GetPropertyChangedSignal("Size"):Connect(function()
        settings.successArea.Position = UDim2.new(0.5, 0, 0, 0)
        settings.successArea.Size = UDim2.new(1, 0, 1, 0)
    end)
end
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
WindUI:SetNotificationLower(true)
if not getgenv().TransparencyEnabled then
    getgenv().TransparencyEnabled = true
end
WindUI:AddTheme({
    Name = "Aurora",
    Accent = WindUI:Gradient({
        ["0"] = { Color = Color3.fromHex("#1C446E"), Transparency = 0 },
        ["100"] = { Color = Color3.fromHex("#521C6E"), Transparency = 0 },
    }, { Rotation = 67 }),
    Dialog = Color3.fromHex("#0E0E1A"),
    Outline = Color3.fromHex("#00C3FF"),
    Text = Color3.fromHex("#FFFFFF"),
    Placeholder = Color3.fromHex("#9AA0A6"),
    Button = WindUI:Gradient({
        ["0"] = { Color = Color3.fromHex("#2B2B47"), Transparency = 0 },
        ["100"] = { Color = Color3.fromHex("#005CFF"), Transparency = 0 }
    }, { Rotation = 45 }),
    Icon = WindUI:Gradient({
        ["0"] = { Color = Color3.fromHex("#D200FF"), Transparency = 0 },
        ["100"] = { Color = Color3.fromHex("#00A1FF"), Transparency = 0 }
    }, { Rotation = 45 })
})
WindUI:AddTheme({
    Name = "Royal Void",
    Accent = WindUI:Gradient({
        ["0"]   = { Color = Color3.fromHex("#FF3366"), Transparency = 0 },
        ["50"]  = { Color = Color3.fromHex("#1E90FF"), Transparency = 0 },
        ["100"] = { Color = Color3.fromHex("#9B30FF"), Transparency = 0 },
    }, { Rotation = 45 }),
    Dialog = Color3.fromHex("#0A0011"),
    Outline = Color3.fromHex("#1E90FF"),
    Text = Color3.fromHex("#FFE6FF"),
    Placeholder = Color3.fromHex("#B34A7F"),
    Background = Color3.fromHex("#050008"),
    Button = Color3.fromHex("#FF00AA"),
    Icon = Color3.fromHex("#0066CC")
})
WindUI:AddTheme({
    Name = "Dark",
    Accent = "#18181b",
    Dialog = "#18181b",
    Outline = "#FFFFFF",
    Text = "#FFFFFF",
    Placeholder = "#999999",
    Background = "#0e0e10",
    Button = "#52525b",
    Icon = "#a1a1aa"
})
WindUI:AddTheme({
    Name = "Light",
    Accent = "#f4f4f5",
    Dialog = "#f4f4f5",
    Outline = "#000000",
    Text = "#000000",
    Placeholder = "#666666",
    Background = "#ffffff",
    Button = "#e4e4e7",
    Icon = "#52525b"
})
WindUI:AddTheme({
    Name = "Gray",
    Accent = "#374151",
    Dialog = "#374151",
    Outline = "#d1d5db",
    Text = "#f9fafb",
    Placeholder = "#9ca3af",
    Background = "#1f2937",
    Button = "#4b5563",
    Icon = "#d1d5db"
})
WindUI:AddTheme({
    Name = "Blue",
    Accent = "#1e40af",
    Dialog = "#1e3a8a",
    Outline = "#93c5fd",
    Text = "#f0f9ff",
    Placeholder = "#60a5fa",
    Background = "#1e293b",
    Button = "#3b82f6",
    Icon = "#93c5fd"
})
WindUI:AddTheme({
    Name = "Green",
    Accent = "#059669",
    Dialog = "#047857",
    Outline = "#6ee7b7",
    Text = "#ecfdf5",
    Placeholder = "#34d399",
    Background = "#064e3b",
    Button = "#10b981",
    Icon = "#6ee7b7"
})
WindUI:AddTheme({
    Name = "Purple",
    Accent = "#7c3aed",
    Dialog = "#6d28d9",
    Outline = "#c4b5fd",
    Text = "#faf5ff",
    Placeholder = "#a78bfa",
    Background = "#581c87",
    Button = "#8b5cf6",
    Icon = "#c4b5fd"
})
WindUI:AddTheme({
    Name = "Sunset Orange",
    Accent = "#ea580c",
    Dialog = "#c2410c",
    Outline = "#fdba74",
    Text = "#fff7ed",
    Placeholder = "#fb923c",
    Background = "#341a00",
    Button = "#f97316",
    Icon = "#fed7aa"
})
WindUI:AddTheme({
    Name = "Forest Green",
    Accent = "#166534",
    Dialog = "#14532d",
    Outline = "#86efac",
    Text = "#f0fdf4",
    Placeholder = "#4ade80",
    Background = "#052e16",
    Button = "#16a34a",
    Icon = "#bbf7d0"
})
local HttpService = game:GetService("HttpService")
local function SafeRequest(requestData)
    local success, result = pcall(function()
        if syn and syn.request then
            local response = syn.request(requestData)
            return {
                Body = response.Body,
                StatusCode = response.StatusCode,
                Success = response.Success
            }
        elseif request and type(request) == "function" then
            local response = request(requestData)
            return {
                Body = response.Body,
                StatusCode = response.StatusCode,
                Success = response.Success
            }
        elseif http and http.request then
            local response = http.request(requestData)
            return {
                Body = response.Body,
                StatusCode = response.StatusCode,
                Success = response.Success
            }
        elseif HttpService.RequestAsync then
            local response = HttpService:RequestAsync({
                Url = requestData.Url,
                Method = requestData.Method or "GET",
                Headers = requestData.Headers or {}
            })
            return {
                Body = response.Body,
                StatusCode = response.StatusCode,
                Success = response.Success
            }
        else
            local body = HttpService:GetAsync(requestData.Url)
            return {
                Body = body,
                StatusCode = 200,
                Success = true
            }
        end
    end)
    if success then
        return result
    else
        warn("HTTP Request failed:", result)
        return {
            Body = "{}",
            StatusCode = 0,
            Success = false,
            Error = tostring(result)
        }
    end
end
local function RetryRequest(requestData, retries)
    retries = retries or 2
    for i = 1, retries do
        local result = SafeRequest(requestData)
        if result.Success and result.StatusCode == 200 then
            return result
        end
        task.wait(1)
    end
    return {
        Success = false, Error = "Max retries reached"
    }
end
local InviteCode = "JxEjAtdgWD"
local DiscordAPI = "https://discord.com/api/v10/invites/" .. InviteCode .. "?with_counts=true&with_expiration=true"
local Confirmed = false
local LoadComplete = false
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer
local blur = Instance.new("BlurEffect", Lighting)
blur.Size = 0
local darkScreenBg = Instance.new("Frame")
darkScreenBg.Name = "DarkScreenEffect"
darkScreenBg.Size = UDim2.new(1,0,1,0)
darkScreenBg.BackgroundColor3 = Color3.fromRGB(0,0,0)
darkScreenBg.BackgroundTransparency = 1
darkScreenBg.BorderSizePixel = 0
darkScreenBg.ZIndex = 4 
local overlayGui = Instance.new("ScreenGui")
overlayGui.Name = "AutoFishOverlayGui"
overlayGui.ResetOnSpawn = false
overlayGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
overlayGui.DisplayOrder = 100
local stopOverlayButton = Instance.new("TextButton")
stopOverlayButton.Size = UDim2.new(0, 250, 0, 60)
stopOverlayButton.Position = UDim2.new(0.5, -125, 0.5, 30)
stopOverlayButton.BackgroundColor3 = Color3.fromHex("#E53935") 
stopOverlayButton.Text = "STOP AUTO FISH"
stopOverlayButton.TextColor3 = Color3.fromHex("#FFFFFF")
stopOverlayButton.TextScaled = true
stopOverlayButton.Font = Enum.Font.SourceSansBold
stopOverlayButton.BorderSizePixel = 0
stopOverlayButton.ZIndex = 10 
stopOverlayButton.Parent = overlayGui
local stopButtonCorner = Instance.new("UICorner")
stopButtonCorner.CornerRadius = UDim.new(0, 12)
stopButtonCorner.Parent = stopOverlayButton
local instructionTextLabel = Instance.new("TextLabel")
instructionTextLabel.Size = UDim2.new(0, 300, 0, 80)
instructionTextLabel.Position = UDim2.new(0.5, -150, 0.5, -70) 
instructionTextLabel.BackgroundTransparency = 1
instructionTextLabel.TextColor3 = Color3.fromHex("#FFFFFF")
instructionTextLabel.TextScaled = true
instructionTextLabel.Font = Enum.Font.SourceSans
instructionTextLabel.TextXAlignment = Enum.TextXAlignment.Center
instructionTextLabel.TextYAlignment = Enum.TextYAlignment.Center
instructionTextLabel.Text = "Do not open any interfaces. Just let it farm.\nIf you want to stop farming, press the stop button. Do not touch anything else."
instructionTextLabel.ZIndex = 9 
instructionTextLabel.Parent = overlayGui
stopOverlayButton.Active = false
stopOverlayButton.Selectable = false
stopOverlayButton.Visible = false
stopOverlayButton.AutoButtonColor = false
instructionTextLabel.Visible = false
local function ApplyDarkScreenEffect()
    darkScreenBg.Parent = player:WaitForChild("PlayerGui")
    TweenService:Create(blur, TweenInfo.new(0.5), {Size = 24}):Play()
    TweenService:Create(darkScreenBg, TweenInfo.new(0.5), {BackgroundTransparency = 0.3}):Play()
    task.wait(0.5) 
end
local function RemoveDarkScreenEffect()
    TweenService:Create(darkScreenBg, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    TweenService:Create(blur, TweenInfo.new(0.5), {Size = 0}):Play()
    task.wait(0.6) 
    darkScreenBg.Parent = nil
end
local function PlayLoadingAnimation()
    local loadingScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    loadingScreenGui.Name = "TempLoadingScreen"
    loadingScreenGui.ResetOnSpawn = false
    loadingScreenGui.IgnoreGuiInset = true
    loadingScreenGui.DisplayOrder = 150
    local frame = Instance.new("Frame", loadingScreenGui)
    frame.Size = UDim2.new(1,0,1,0)
    frame.BackgroundTransparency = 1
    local bg = Instance.new("Frame", frame)
    bg.Size = UDim2.new(1,0,1,0)
    bg.BackgroundColor3 = Color3.fromRGB(0,0,0)
    bg.BackgroundTransparency = 1
    TweenService:Create(blur, TweenInfo.new(0.5), {Size = 24}):Play()
    TweenService:Create(bg, TweenInfo.new(0.5), {BackgroundTransparency = 0.3}):Play()
    task.wait(0.5)
    local word = "Punk Hub"
    local letters = {}
    for i = 1, #word do
        local char = word:sub(i,i)
        local label = Instance.new("TextLabel", frame)
        label.Text = char
        label.Font = Enum.Font.GothamBlack
        label.TextColor3 = Color3.new(1,1,1)
        label.TextTransparency = 1
        label.TextSize = 30
        label.Size = UDim2.new(0,60,0,60)
        label.AnchorPoint = Vector2.new(0.5,0.5)
        label.Position = UDim2.new(0.5, (i - (#word/2 + 0.5))*65, 0.5, 0)
        label.BackgroundTransparency = 1
        local gradient = Instance.new("UIGradient", label)
        gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(200,200,200))})
        gradient.Rotation = 90
        TweenService:Create(label, TweenInfo.new(0.3), {TextTransparency = 0, TextSize = 60}):Play()
        table.insert(letters, label)
        task.wait(0.25)
    end
    task.wait(2)
    for _, label in ipairs(letters) do
        TweenService:Create(label, TweenInfo.new(0.3), {TextTransparency = 1, TextSize = 20}):Play()
    end
    TweenService:Create(bg, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    TweenService:Create(blur, TweenInfo.new(0.5), {Size = 0}):Play()
    task.wait(0.6)
    loadingScreenGui:Destroy()
end
WindUI:Popup({
    Title = "Punk Hub",
    Icon = "rbxassetid://89306785777733",
    IconThemed = true,
    Theme = "Aurora",
    Content = "Welcome to Punk Hub. A flexible and powerful script hub for Roblox, designed to enhance your gaming experience with a variety of features.",
    Buttons = {
        { Title = "Copy Discord Link", Variant = "Primary", Callback = function() setclipboard("https://discord.gg/" .. InviteCode) end },
        { Title = "Exit", Variant = "Secondary", Callback = function() game:GetService("Players").LocalPlayer:Kick("Get out!") end },
        { Title = "Load", Icon = "arrow-right", Variant = "Primary", Callback = function()
            Confirmed = true
            PlayLoadingAnimation()
            LoadComplete = true
        end }
    }
})
repeat task.wait() until Confirmed
repeat task.wait() until LoadComplete
local Window = WindUI:CreateWindow({
    Title = "Punk Hub",
    Icon = "rbxassetid://89306785777733",
    Author = "Punk Team",
    Folder = "Punk Hub",
    Size = UDim2.fromOffset(600, 420),
    Theme = "Royal Void",
    Transparent = getgenv().TransparencyEnabled,
    Resizable = true,
    SideBarWidth = 160,
    OpenButton = {
        Enabled = false,
    },
})
Window:SetToggleKey(Enum.KeyCode.V)
local gui = Instance.new("ScreenGui")
gui.Parent = player:WaitForChild("PlayerGui")
gui.ResetOnSpawn = false
local button = Instance.new("ImageButton")
button.Parent = gui
button.Size = UDim2.new(0.13, 0.13)
button.Position = UDim2.new(0.25, 0, 0.1, 0)
button.AnchorPoint = Vector2.new(0.5, 0.5)
button.Image = "rbxassetid://89306785777733"
button.BackgroundTransparency = 1
button.BorderSizePixel = 0
button.ScaleType = Enum.ScaleType.Fit
button.Visible = false
button.AutoButtonColor = false
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = button
local isMinimized = false
button.MouseButton1Click:Connect(function()
    Window:Open()
    button.Visible = false
    isMinimized = false
end)
Window:OnClose(function()
    if not isMinimized then
        button.Visible = true
        isMinimized = true
    end
end)
local UIS = game:GetService("UserInputService")
local dragging = false
local dragStart
local startPos
local function update(input)
    local delta = input.Position - dragStart
    button.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
end
button.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = button.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
button.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then
        if dragging then
            update(input)
        end
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging then
        update(input)
    end
end)
Window:Tag({ Title = "v0.0.1", Radius = 12 })
if player then
    overlayGui.Parent = player:WaitForChild("PlayerGui")
else
    Players.PlayerAdded:Connect(function(p)
        if p == player then
            overlayGui.Parent = player:WaitForChild("PlayerGui")
        end
    end)
end
local AutoFarmEnabled = false
local AutoFarmSpeed = 0.2
local AutoFarmCoroutine = nil
local autoFishToggleElement = nil 
local function StartAutoFarm()
    if AutoFarmCoroutine then
        task.cancel(AutoFarmCoroutine)
    end
    Window:Close() 
    ApplyDarkScreenEffect() 
    overlayGui.Enabled = true 
    stopOverlayButton.Visible = true 
    stopOverlayButton.Active = true 
    instructionTextLabel.Visible = true
    local equipToolArgs = {1} 
    game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RE/EquipToolFromHotbar"):FireServer(unpack(equipToolArgs))
    AutoFarmCoroutine = task.spawn(function()
        local playerGui = player:WaitForChild("PlayerGui")
        local hud = playerGui:WaitForChild("HUD")
        local fishingButton = hud:WaitForChild("MobileFishingButton")
        local screenGui = fishingButton:FindFirstAncestorOfClass("ScreenGui")
        local ignoreInset = screenGui and screenGui.IgnoreGuiInset
        while AutoFarmEnabled do
            task.wait(AutoFarmSpeed)
            if fishingButton.Visible and fishingButton.Active then
                local pos = fishingButton.AbsolutePosition
                local size = fishingButton.AbsoluteSize
                local x = pos.X + size.X / 2
                local y = pos.Y + size.Y / 2
                if not ignoreInset then
                    local inset = GuiService:GetGuiInset()
                    y += inset.Y
                end
                VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
                task.wait(0.03)
                VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
            end
        end
    end)
end
local function StopAutoFarmMain()
    if not AutoFarmEnabled then return end 
    AutoFarmEnabled = false
    if AutoFarmCoroutine then
        task.cancel(AutoFarmCoroutine)
        AutoFarmCoroutine = nil
    end
    RemoveDarkScreenEffect() 
    Window:Open() 
    overlayGui.Enabled = false 
    stopOverlayButton.Visible = false 
    stopOverlayButton.Active = false 
    instructionTextLabel.Visible = false
    if autoFishToggleElement and autoFishToggleElement.Value then
        autoFishToggleElement:Set(false)
    end
    WindUI:Notify({
        Title = "Auto Farm Disabled",
        Content = "Stopped fishing",
        Duration = 3,
        Icon = "x-circle"
    })
end
stopOverlayButton.MouseButton1Click:Connect(StopAutoFarmMain)
local MainTab = Window:Tab({
    Title = "Main",
    Icon = "geist:home"
})
local AutoFischSection = MainTab:Section({
    Title = "Auto Fish",
    Opened = false
})
AutoFischSection:Paragraph({
    Title = "Auto Fishing",
    Desc = "Automatically clicks the fishing button when available",
    Image = "fish",
    ImageSize = 20,
    Color = "Blue"
})
autoFishToggleElement = AutoFischSection:Toggle({ 
    Title = "Enable Auto Farm",
    Desc = "Start/Stop automatic fishing",
    Icon = "zap",
    Value = false,
    Callback = function(state)
        if state then
            AutoFarmEnabled = true
            WindUI:Notify({
                Title = "Auto Farm Enabled",
                Content = "Started fishing automatically",
                Duration = 3,
                Icon = "fish"
            })
            StartAutoFarm()
        else
            StopAutoFarmMain() 
        end
    end
})
local previousSpeed = 0.2
local speedChangeNotificationTask = nil
AutoFischSection:Slider({
    Title = "Farm Speed",
    Desc = "Adjust the click delay (lower = faster)",
    Step = 0.05,
    Value = {
        Min = 0.05,
        Max = 1,
        Default = 0.2
    },
    Callback = function(value)
        local oldSpeed = previousSpeed
        AutoFarmSpeed = value
        previousSpeed = value
        if speedChangeNotificationTask then
            task.cancel(speedChangeNotificationTask)
        end
        speedChangeNotificationTask = task.delay(0.5, function()
            WindUI:Notify({
                Title = "Speed Changed",
                Content = string.format("Speed changed from %.2fs to %.2fs", oldSpeed, value),
                Duration = 2,
                Icon = "gauge"
            })
            speedChangeNotificationTask = nil
        end)
    end
})
AutoFischSection:Divider()
AutoFischSection:Paragraph({
    Title = "⚙️ How to Use",
    Desc = "1. Enable the toggle to start farming\n2. Adjust speed slider to control click frequency\n3. Lower values = faster clicking",
    Color = "Grey"
})
local AutoSellSection = MainTab:Section({
    Title = "Auto Sell",
    Opened = false
})
AutoSellSection:Paragraph({
    Title = "Auto Sell Items",
    Desc = "Sell all collected items automatically or manually.",
    Image = "dollar-sign",
    ImageSize = 20,
    Color = "Green"
})
AutoSellSection:Button({
    Title = "Sell All Items Now",
    Content = "Immediately sell all items in your inventory.",
    Icon = "package",
    Callback = function()
        local success, result = pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RF/SellAllItems"):InvokeServer()
        end)
        if success then
            WindUI:Notify({
                Title = "Items Sold",
                Content = "All items in your inventory have been sold!",
                Duration = 3,
                Icon = "check-circle"
            })
        else
            WindUI:Notify({
                Title = "Sell Failed",
                Content = "Could not sell items. Error: " .. tostring(result),
                Duration = 3,
                Icon = "alert-triangle"
            })
        end
    end
})
local AutoSellEnabled = false
local AutoSellInterval = 10 
local AutoSellCoroutine = nil
local autoSellToggleElement = nil
local function StartAutoSell()
    if AutoSellCoroutine then
        task.cancel(AutoSellCoroutine)
    end
    AutoSellCoroutine = task.spawn(function()
        while AutoSellEnabled do
            task.wait(AutoSellInterval)
            local success, result = pcall(function()
                game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RF/SellAllItems"):InvokeServer()
            end)
            if success then
                WindUI:Notify({
                    Title = "Auto Sell",
                    Content = "Items sold automatically!",
                    Duration = 2,
                    Icon = "check-circle"
                })
            else
                warn("Auto Sell Failed:", result)
            end
        end
    end)
end
local function StopAutoSell()
    if AutoSellCoroutine then
        task.cancel(AutoSellCoroutine)
        AutoSellCoroutine = nil
    end
end
autoSellToggleElement = AutoSellSection:Toggle({
    Title = "Enable Auto Sell",
    Desc = "Automatically sells your items at set intervals.",
    Icon = "repeat",
    Value = false,
    Callback = function(state)
        AutoSellEnabled = state
        if state then
            WindUI:Notify({
                Title = "Auto Sell Enabled",
                Content = "Automatic selling started!",
                Duration = 3,
                Icon = "check-circle"
            })
            StartAutoSell()
        else
            WindUI:Notify({
                Title = "Auto Sell Disabled",
                Content = "Automatic selling stopped.",
                Duration = 3,
                Icon = "x-circle"
            })
            StopAutoSell()
        end
    end
})
local previousSellInterval = 10
AutoSellSection:Slider({
    Title = "Sell Interval (seconds)",
    Desc = "Time between automatic sell actions.",
    Step = 1,
    Value = {
        Min = 5,
        Max = 600, 
        Default = 10
    },
    Callback = function(value)
        local oldInterval = previousSellInterval
        AutoSellInterval = value
        previousSellInterval = value
        WindUI:Notify({
            Title = "Sell Interval Changed",
            Content = string.format("Sell interval changed from %ds to %ds", oldInterval, value),
            Duration = 2,
            Icon = "clock"
        })
        if AutoSellEnabled then
            StartAutoSell() 
        end
    end
})
AutoSellSection:Divider()
AutoSellSection:Paragraph({
    Title = "⚙️ How to Use Auto Sell",
    Desc = "1. Use 'Sell All Items Now' for an instant sale.\n2. Enable 'Auto Sell' to sell items periodically.\n3. Adjust 'Sell Interval' to change how often items are sold automatically.",
    Color = "Grey"
})
local UtilityTab = Window:Tab({
    Title = "Utility",
    Icon = "lucide:settings"
})
local TeleportSection = UtilityTab:Section({
	Title = "Teleport Utility",
	Icon = "map-pin"
})
TeleportSection:Paragraph({
	Title = "Quick Teleport System",
	Content = "Fast travel to various islands and locations"
})
local islandCoords = {
	["01"] = { name = "Weather Machine", position = Vector3.new(-1471, -3, 1929) },
	["02"] = { name = "Esoteric Depths", position = Vector3.new(3157, -1303, 1439) },
	["03"] = { name = "Tropical Grove", position = Vector3.new(-2038, 3, 3650) },
	["04"] = { name = "Stingray Shores", position = Vector3.new(-32, 4, 2773) },
	["05"] = { name = "Kohana Volcano", position = Vector3.new(-519, 24, 189) },
	["06"] = { name = "Coral Reefs", position = Vector3.new(-3095, 1, 2177) },
	["07"] = { name = "Crater Island", position = Vector3.new(968, 1, 4854) },
	["08"] = { name = "Kohana", position = Vector3.new(-658, 3, 719) },
	["09"] = { name = "Winter Fest", position = Vector3.new(1611, 4, 3280) },
	["10"] = { name = "Isoteric Island", position = Vector3.new(1987, 4, 1400) },
	["11"] = { name = "Treasure Hall", position = Vector3.new(-3600, -267, -1558) },
	["12"] = { name = "Lost Shore", position = Vector3.new(-3663, 38, -989 ) },
	["13"] = { name = "Sishypus Statue", position = Vector3.new(-3792, -135, -986) }
}
local islandNames = {}
for _, data in pairs(islandCoords) do
    table.insert(islandNames, data.name)
end
TeleportSection:Dropdown({
    Title = "Island Teleport",
    Content = "Quick teleport to different islands",
    Values = islandNames,
    Callback = function(selectedName)
        for code, data in pairs(islandCoords) do
            if data.name == selectedName then
                local success, err = pcall(function()
                    local charFolder = workspace:WaitForChild("Characters", 5)
                    local char = charFolder:FindFirstChild(player.Name)
                    if not char then error("Character not found") end
                    local hrp = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 3)
                    if not hrp then error("HumanoidRootPart not found") end
                    hrp.CFrame = CFrame.new(data.position + Vector3.new(0, 5, 0))
                end)
                if success then
                    WindUI:Notify({ Title = "Teleported!", Content = "You are now at " .. selectedName, Icon = "circle-check", Duration = 3 })
                else
                    WindUI:Notify({ Title = "Teleport Failed", Content = tostring(err), Icon = "alert-triangle", Duration = 3 })
                end
                break
            end
        end
    end
})
local eventsList = { "Shark Hunt", "Ghost Shark Hunt", "Worm Hunt", "Black Hole", "Shocked", "Ghost Worm", "Meteor Rain" }
TeleportSection:Dropdown({
    Title = "Event Teleport",
    Content = "Teleport to active events",
    Values = eventsList,
    Callback = function(option)
        local props = workspace:FindFirstChild("Props")
        if props and props:FindFirstChild(option) and props[option]:FindFirstChild("Fishing Boat") then
            local fishingBoat = props[option]["Fishing Boat"]
            local boatCFrame = fishingBoat:GetPivot()
            local hrp = game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = boatCFrame + Vector3.new(0, 15, 0)
                WindUI:Notify({
                	Title = "Event Available!",
                	Content = "Teleported To " .. option,
                	Icon = "circle-check",
                	Duration = 3
                })
            end
        else
            WindUI:Notify({
                Title = "Event Not Found",
                Content = option .. " Not Found!",
                Icon = "ban",
                Duration = 3
            })
        end
    end
})
local npcFolder = game:GetService("ReplicatedStorage"):WaitForChild("NPC")
local npcList = {}
for _, npc in pairs(npcFolder:GetChildren()) do
	if npc:IsA("Model") then
		local hrp = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart
		if hrp then
			table.insert(npcList, npc.Name)
		end
	end
end
TeleportSection:Dropdown({
	Title = "NPC Teleport",
	Content = "Teleport to specific NPCs",
	Values = npcList,
	Callback = function(selectedName)
		local npc = npcFolder:FindFirstChild(selectedName)
		if npc and npc:IsA("Model") then
			local hrp = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart
			if hrp then
				local charFolder = workspace:FindFirstChild("Characters", 5)
				local char = charFolder and charFolder:FindFirstChild(player.Name)
				if not char then return end
				local myHRP = char:FindFirstChild("HumanoidRootPart")
				if myHRP then
					myHRP.CFrame = hrp.CFrame + Vector3.new(0, 3, 0)
					WindUI:Notify({ Title = "Teleported!", Content = "You are now near: " .. selectedName, Icon = "circle-check", Duration = 3 })
				end
			end
		end
	end
})
local ServerSection = UtilityTab:Section({
	Title = "Server Utility",
	Icon = "server"
})
ServerSection:Paragraph({
	Title = "Server Management",
	Content = "Manage your server experience and connections"
})
local TeleportService = game:GetService("TeleportService")
local function Rejoin()
	local playerInstance = Players.LocalPlayer
	if playerInstance then
		TeleportService:Teleport(game.PlaceId, playerInstance)
	end
end
local function ServerHop()
	local placeId = game.PlaceId
	local servers = {}
	local cursor = ""
	local found = false
	repeat
		local url = "https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Asc&limit=100"
		if cursor ~= "" then
			url = url .. "&cursor=" .. cursor
		end
		local success, result = pcall(function()
			return HttpService:JSONDecode(game:HttpGet(url))
		end)
		if success and result and result.data then
			for _, server in pairs(result.data) do
				if server.playing < server.maxPlayers and server.id ~= game.JobId then
					table.insert(servers, server.id)
				end
			end
			cursor = result.nextPageCursor or ""
		else
			break
		end
	until not cursor or #servers > 0
	if #servers > 0 then
		local targetServer = servers[math.random(1, #servers)]
		TeleportService:TeleportToPlaceInstance(placeId, targetServer, player)
	else
		WindUI:Notify({ Title = "Server Hop Failed", Content = "No servers available or all are full!", Icon = "alert-triangle", Duration = 3 })
	end
end
ServerSection:Button({
	Title = "Rejoin Server",
	Content = "Rejoin current server",
	Callback = function()
		Rejoin()
	end,
})
ServerSection:Button({
	Title = "Server Hop",
	Content = "Join a new server",
	Callback = function()
		ServerHop()
	end,
})
local VisualSection = UtilityTab:Section({
	Title = "Visual Utility",
	Icon = "eye"
})
VisualSection:Paragraph({
	Title = "Visual Enhancements",
	Content = "Improve your visual experience and performance"
})
VisualSection:Button({
	Title = "HDR Shader",
	Content = "Apply HDR visual enhancements",
	Callback = function()
        if not game:IsLoaded() then
            game.Loaded:Wait()
        end
        local LightingService = game:GetService("Lighting")
        for _, effect in ipairs(LightingService:GetChildren()) do
            if effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or effect:IsA("ColorCorrectionEffect") or effect:IsA("SunRaysEffect") or effect:IsA("Sky") then
                effect:Destroy()
            end
        end
        local bloom = Instance.new("BloomEffect")
        bloom.Intensity = 0.1
        bloom.Threshold = 0
        bloom.Size = 100
        bloom.Parent = LightingService
        local tropicSky = Instance.new("Sky")
        tropicSky.Name = "Tropic"
        tropicSky.SkyboxUp = "http://www.roblox.com/asset/?id=169210149"
        tropicSky.SkyboxLf = "http://www.roblox.com/asset/?id=169210133"
        tropicSky.SkyboxBk = "http://www.roblox.com/asset/?id=169210090"
        tropicSky.SkyboxFt = "http://www.roblox.com/asset/?id=169210121"
        tropicSky.StarCount = 100
        tropicSky.SkyboxDn = "http://www.roblox.com/asset/?id=169210108"
        tropicSky.SkyboxRt = "http://www.roblox.com/asset/?id=169210143"
        tropicSky.Parent = LightingService
        local genericSky = Instance.new("Sky")
        genericSky.SkyboxUp = "http://www.roblox.com/asset/?id=196263782"
        genericSky.SkyboxLf = "http://www.roblox.com/asset/?id=196263721"
        genericSky.SkyboxBk = "http://www.roblox.com/asset/?id=196263721"
        genericSky.SkyboxFt = "http://www.roblox.com/asset/?id=196263721"
        genericSky.CelestialBodiesShown = false
        genericSky.SkyboxDn = "http://www.roblox.com/asset/?id=196263643"
        genericSky.SkyboxRt = "http://www.roblox.com/asset/?id=196263721"
        genericSky.Parent = LightingService
        local blurEffect = Instance.new("BlurEffect")
        blurEffect.Size = 2
        blurEffect.Parent = LightingService
        local efectoEffect = Instance.new("BlurEffect")
        efectoEffect.Name = "Efecto"
        efectoEffect.Enabled = false
        efectoEffect.Size = 2
        efectoEffect.Parent = LightingService
        local inaritaishaEffect = Instance.new("ColorCorrectionEffect")
        inaritaishaEffect.Name = "Inari taisha"
        inaritaishaEffect.Saturation = 0.05
        inaritaishaEffect.TintColor = Color3.fromRGB(255, 224, 219)
        inaritaishaEffect.Parent = LightingService
        local normalEffect = Instance.new("ColorCorrectionEffect")
        normalEffect.Name = "Normal"
        normalEffect.Enabled = false
        normalEffect.Saturation = -0.2
        normalEffect.TintColor = Color3.fromRGB(255, 232, 215)
        normalEffect.Parent = LightingService
        local takayamaEffect = Instance.new("ColorCorrectionEffect")
        takayamaEffect.Name = "Takayama"
        takayamaEffect.Enabled = false
        takayamaEffect.Saturation = -0.3
        takayamaEffect.Contrast = 0.1
        takayamaEffect.TintColor = Color3.fromRGB(235, 214, 204)
        takayamaEffect.Parent = LightingService
        local sunRays = Instance.new("SunRaysEffect")
        sunRays.Intensity = 0.05
        sunRays.Parent = LightingService
        local sunsetSky = Instance.new("Sky")
        sunsetSky.Name = "Sunset"
        sunsetSky.SkyboxUp = "rbxassetid://323493360"
        sunsetSky.SkyboxLf = "rbxassetid://323494252"
        sunsetSky.SkyboxBk = "rbxassetid://323494035"
        sunsetSky.SkyboxFt = "rbxassetid://323494130"
        sunsetSky.SkyboxDn = "rbxassetid://323494368"
        sunsetSky.SunAngularSize = 14
        sunsetSky.SkyboxRt = "rbxassetid://323494067"
        sunsetSky.Parent = LightingService
        LightingService.Brightness = 2.14
        LightingService.ColorShift_Bottom = Color3.fromRGB(11, 0, 20)
        LightingService.ColorShift_Top = Color3.fromRGB(240, 127, 14)
        LightingService.OutdoorAmbient = Color3.fromRGB(34, 0, 49)
        LightingService.ClockTime = 6.7
        LightingService.FogColor = Color3.fromRGB(94, 76, 106)
        LightingService.FogEnd = 1000
        LightingService.FogStart = 0
        LightingService.ExposureCompensation = 0.24
        LightingService.ShadowSoftness = 0
        LightingService.Ambient = Color3.fromRGB(59, 33, 27)
        WindUI:Notify({
            Title = "HDR Shader Applied",
            Content = "Visual enhancements have been applied.",
            Duration = 3,
            Icon = "sun"
        })
	end,
}) 
local MiscSection = Window:Section({ Title = "Misc", Opened = true })
Window:Section({ Title = "WindUI " .. tostring(WindUI.Version or "Latest") })
local ConfigTab = MiscSection:Tab({ Title = "Configuration", Icon = "settings" })
local InfoTab   = MiscSection:Tab({ Title = "Information", Icon = "badge-info" })
ConfigTab:Paragraph({
    Title = "Customize Interface",
    Desc = "Personalize your experience",
    Image = "palette",
    ImageSize = 20,
    Color = "White"
})
local themes = {}
for themeName in pairs(WindUI:GetThemes()) do table.insert(themes, themeName) end
table.sort(themes)
local themeDropdown = ConfigTab:Dropdown({
    Title = "Select Theme",
    Values = themes,
    Value = WindUI:GetCurrentTheme(),
    Callback = function(theme)
        WindUI:SetTheme(theme)
        WindUI:Notify({ Title = "Theme Applied", Content = theme, Duration = 3 })
    end
})
ConfigTab:Slider({
    Title = "Transparency",
    Value = { Min = 0, Max = 1, Default = 0.2 },
    Step = 0.1,
    Callback = function(value)
        local num = math.clamp(tonumber(value) or 0.2, 0, 1)
        Window:ToggleTransparency(num > 0)
        WindUI.TransparencyValue = num
        getgenv().TransparencyEnabled = num > 0
    end
})
ConfigTab:Toggle({
    Title = "Enable Dark Mode",
    Desc = "Use dark color scheme",
    Value = (WindUI:GetCurrentTheme() == "Dark"),
    Callback = function(state)
        local theme = state and "Dark" or "Light"
        WindUI:SetTheme(theme)
        themeDropdown:Select(theme)
    end
})
local function LoadDiscordInfo()
    local success, result = pcall(function()
        return HttpService:JSONDecode(RetryRequest({
            Url = DiscordAPI,
            Method = "GET",
            Headers = {
                ["User-Agent"] = "RobloxBot/1.0",
                ["Accept"] = "application/json"
            }
        }).Body)
    end)
    if success and result and result.guild then
        local DiscordInfo = InfoTab:Paragraph({
            Title = result.guild.name,
            Desc = ' <font color="#52525b"></font> Member Count: ' .. tostring(result.approximate_member_count) ..
            '\n <font color="#16a34a"></font> Online Count: ' .. tostring(result.approximate_presence_count),
            Image = "https://cdn.discordapp.com/icons/" .. result.guild.id .. "/" .. result.guild.icon .. ".png?size=1024",
            ImageSize = 42,
        })
        InfoTab:Button({
            Title = "Update Info",
            Callback = function()
                local updated, updatedResult = pcall(function()
                    return HttpService:JSONDecode(RetryRequest({
                        Url = DiscordAPI,
                        Method = "GET",
                    }).Body)
                end)
                if updated and updatedResult and updatedResult.guild then
                    DiscordInfo:SetDesc(
                        ' <font color="#52525b"></font> Member Count: ' .. tostring(updatedResult.approximate_member_count) ..
                        '\n <font color="#16a34a"></font> Online Count: ' .. tostring(updatedResult.approximate_presence_count)
                    )
                    WindUI:Notify({
                        Title = "Discord Info Updated",
                        Content = "Successfully refreshed Discord statistics",
                        Duration = 2,
                        Icon = "refresh-cw",
                    })
                else
                    WindUI:Notify({
                        Title = "Update Failed",
                        Content = "Could not refresh Discord info",
                        Duration = 3,
                        Icon = "alert-triangle",
                    })
                end
            end
        })
        InfoTab:Button({
            Title = "Copy Discord Invite",
            Callback = function()
                setclipboard("https://discord.gg/" .. InviteCode)
                WindUI:Notify({
                    Title = "Copied!",
                    Content = "Discord invite copied to clipboard",
                    Duration = 2,
                    Icon = "clipboard-check",
                })
            end
        })
    else
        InfoTab:Paragraph({
            Title = "Error fetching Discord Info",
            Image = "rbxassetid://17862288113",
            ImageSize = 60,
            Color = "Red"
        })
    end
end
LoadDiscordInfo()
InfoTab:Divider()
InfoTab:Paragraph({
    Title = "Punk Hub",
    Desc = "Credits:Punk Team",
    Thumbnail = "",
    ThumbnailSize = 50,
    Locked = false,
})
WindUI:Notify({ Title = "Punk Hub Loaded", Content = "Press V to toggle menu", Duration = 5, Icon = "zap" })
Window:Open()

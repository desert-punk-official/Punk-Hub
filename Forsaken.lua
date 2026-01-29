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
local GuiService = game:GetService("GetService")
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
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(200,200,200))
        })
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
        {
            Title = "Copy Discord Link",
            Variant = "Primary",
            Callback = function()
                setclipboard("https://discord.gg/" .. InviteCode)
            end
        },
        {
            Title = "Exit",
            Variant = "Secondary",
            Callback = function()
                game:GetService("Players").LocalPlayer:Kick("Get out!")
            end
        },
        {
            Title = "Load",
            Icon = "arrow-right",
            Variant = "Primary",
            Callback = function()
                Confirmed = true
                PlayLoadingAnimation()
                LoadComplete = true
            end
        }
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
button.Size = UDim2.new(0.13, 0, 0.13, 0)
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

local StatusTag = Window:Tag({
    Title = "v0.1 | Ping: -- | FPS: --",
    Color = Color3.fromRGB(40, 200, 120),
})

local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

local frames = 0
local lastTime = tick()
local fps = 0

RunService.RenderStepped:Connect(function()
    frames += 1
    local now = tick()
    if now - lastTime >= 1 then
        fps = frames
        frames = 0
        lastTime = now
    end

    local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())

    StatusTag:SetTitle(
        "v0.1 | Ping: " .. ping .. "ms | FPS: " .. fps
    )
end)

if player then
    overlayGui.Parent = player:WaitForChild("PlayerGui")
else
    Players.PlayerAdded:Connect(function(p)
        if p == player then
            overlayGui.Parent = player:WaitForChild("PlayerGui")
        end
    end)
end

local InfoTab = Window:Tab({
    Title = "Info",
    Icon = "badge-info"
})

InfoTab:Paragraph({
    Title = "Punk Hub",
    Desc = "Created by Punk Team",
    Image = "users",
    ImageSize = 24,
    Color = Color3.fromRGB(100, 200, 255)
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
            Buttons = {
                {
                    Title = "Update Info",
                    Icon = "refresh-cw",
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
                },
                {
                    Title = "Copy Discord Invite",
                    Icon = "clipboard-check",
                    Callback = function()
                        setclipboard("https://discord.gg/" .. InviteCode)
                        WindUI:Notify({
                            Title = "Copied!",
                            Content = "Discord invite copied to clipboard",
                            Duration = 2,
                            Icon = "clipboard-check",
                        })
                    end
                }
            }
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

local UpdateLogTab = Window:Tab({
    Title = "Update Logs",
    Icon = "file-text"
})

UpdateLogTab:Paragraph({
    Title = "Version 0.1",
    Desc = "Initial release of Punk Hub\n• WindUI integration\n• Discord server info\n• Custom themes\n• Player and ESP features added",
    Image = "package",
    ImageSize = 24,
    Color = Color3.fromRGB(100, 255, 100)
})

local ConfigTab = Window:Tab({
    Title = "Config",
    Icon = "settings"
})

ConfigTab:Paragraph({
    Title = "Customize Interface",
    Desc = "Personalize your experience",
    Image = "palette",
    ImageSize = 20,
    Color = "White"
})

local themes = {}
for themeName in pairs(WindUI:GetThemes()) do
    table.insert(themes, themeName)
end
table.sort(themes)

local themeDropdown = ConfigTab:Dropdown({
    Title = "Select Theme",
    Values = themes,
    Value = WindUI:GetCurrentTheme(),
    Callback = function(theme)
        WindUI:SetTheme(theme)
        WindUI:Notify({
            Title = "Theme Applied",
            Content = theme,
            Duration = 3
        })
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


Window:Divider()

local ActiveSpeedBoost, ActiveAutoUseCoinFlip, ActiveEspSurvivors, ActiveNoStun, ActiveEspKillers, ActiveEspGenerator, ActiveEspItems, ActiveInfiniteStamina, ActiveEspRagdolls, ActiveAutoGenerator, ActiveAutoKillSurvivors = false, false, false, false, false, false, false, false, false, false, false
local ValueSpeed = 16
local ValueFieldOfView = 80
local OldFOV = game.Players.LocalPlayer.PlayerData.Settings.Game.FieldOfView.Value
local ActiveModifiedFieldOfView = false
local ActiveFullBright = false


local function CreateEsp(Char, Color, Text, Parent, number)
    if Char and not Char:FindFirstChildOfClass("Highlight") and not Parent:FindFirstChildOfClass("BillboardGui") then
        local NewHighlight = Instance.new("Highlight", Char)
        NewHighlight.OutlineColor = Color
        NewHighlight.FillColor = Color
        
        local billboard = Char:FindFirstChild("ESP") or Instance.new("BillboardGui")
        billboard.Name = "ESP"
        billboard.Size = UDim2.new(0, 50, 0, 25)
        billboard.AlwaysOnTop = true
        billboard.StudsOffset = Vector3.new(0, number, 0)
        billboard.Adornee = Parent
        billboard.Enabled = true
        billboard.Parent = Parent
        
        local label = billboard:FindFirstChildOfClass("TextLabel") or Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = Text
        label.TextColor3 = Color
        label.TextScaled = true
        label.Parent = billboard
    end
end

local function KeepEsp(Char, parent)
    if Char and Char:FindFirstChildOfClass("Highlight") and parent:FindFirstChildOfClass("BillboardGui") then
        Char:FindFirstChildOfClass("Highlight"):Destroy()
        parent:FindFirstChildOfClass("BillboardGui"):Destroy()
    end
end

local PlayerTab = Window:Tab({Title = "Player", Icon = "user"})

local PlayerSpeedSlider = PlayerTab:Slider({
    Title = "Player Speed",
    Desc = "Adjust player walking speed",
    Value = {Min = 0, Max = 25, Default = 16},
    Step = 1,
    Callback = function(Value)
        ValueSpeed = Value
    end,
})

PlayerTab:Toggle({
    Title = "Active Modifying Player Speed",
    Desc = "Enable speed modification",
    Value = false,
    Callback = function(Value)
        ActiveSpeedBoost = Value
        task.spawn(function()
            while ActiveSpeedBoost do
                task.spawn(function()
                    if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = ValueSpeed
                        game.Players.LocalPlayer.Character.Humanoid:SetAttribute("BaseSpeed", ValueSpeed)
                    end
                end)
                task.wait(0.1)
            end
        end)
    end,
})

PlayerTab:Toggle({
    Title = "Infinite Stamina",
    Desc = "Never run out of stamina",
    Value = false,
    Callback = function(Value)
        ActiveInfiniteStamina = Value
        task.spawn(function()
            while ActiveInfiniteStamina do
                task.spawn(function()
                    local SprintingModule = game.ReplicatedStorage.Systems.Character.Game:FindFirstChild("Sprinting")
                    if SprintingModule then
                        local m = require(SprintingModule)
                        m.StaminaLossDisabled = true
                        m.Stamina = 9999999
                    end
                end)
                task.wait(0.1)
            end
            task.spawn(function()
                local SprintingModule = game.ReplicatedStorage.Systems.Character.Game:FindFirstChild("Sprinting")
                if SprintingModule then
                    local m = require(SprintingModule)
                    m.StaminaLossDisabled = false
                    m.Stamina = 100
                end
            end)
        end)
    end,
})

PlayerTab:Toggle({
    Title = "No Stun",
    Desc = "Prevent stun effects",
    Value = false,
    Callback = function(Value)
        ActiveNoStun = Value
        task.spawn(function()
            while ActiveNoStun do
                task.spawn(function()
                    if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = false
                    end
                end)
                task.wait(0.001)
            end
        end)
    end,
})

local PlayerFieldOfViewSlider = PlayerTab:Slider({
    Title = "Field Of View",
    Desc = "Adjust camera FOV",
    Value = {Min = 80, Max = 120, Default = 80},
    Step = 1,
    Callback = function(Value)
        ValueFieldOfView = Value
        if ActiveModifiedFieldOfView then
             if game.Players.LocalPlayer.PlayerData and game.Players.LocalPlayer.PlayerData.Settings.Game:FindFirstChild("FieldOfView") then
                game.Players.LocalPlayer.PlayerData.Settings.Game.FieldOfView.Value = ValueFieldOfView
            end
        end
    end,
})

PlayerTab:Toggle({
    Title = "Modify FOV",
    Desc = "Enable FOV modification",
    Value = false,
    Callback = function(Value)
        ActiveModifiedFieldOfView = Value
        if ActiveModifiedFieldOfView then
            if game.Players.LocalPlayer.PlayerData and game.Players.LocalPlayer.PlayerData.Settings.Game:FindFirstChild("FieldOfView") then
                game.Players.LocalPlayer.PlayerData.Settings.Game.FieldOfView.Value = ValueFieldOfView
            end
        else
            if game.Players.LocalPlayer.PlayerData and game.Players.LocalPlayer.PlayerData.Settings.Game:FindFirstChild("FieldOfView") then
                game.Players.LocalPlayer.PlayerData.Settings.Game.FieldOfView.Value = OldFOV
            end
        end
    end,
})

PlayerTab:Toggle({
    Title = "Full Bright",
    Desc = "Maximum brightness",
    Value = false,
    Callback = function(Value)
        ActiveFullBright = Value
        task.spawn(function()
            while ActiveFullBright do
                if game.Lighting then
                    game.Lighting.Brightness = 5
                    game.Lighting.Ambient = Color3.fromRGB(255, 255, 255)
                end
                wait(0.1)
            end
             if not ActiveFullBright then
                game.Lighting.Brightness = 2
                game.Lighting.Ambient = Color3.fromRGB(0, 0, 0)
            end
        end)
    end,
})

local MainTab = Window:Tab({Title = "Main", Icon = "cpu"})

MainTab:Toggle({
    Title = "Auto Generator",
    Desc = "Automatically complete generators",
    Value = false,
    Callback = function(Value)
        ActiveAutoGenerator = Value
        task.spawn(function()
            while ActiveAutoGenerator do
                task.spawn(function()
                    if game.Workspace.Map and game.Workspace.Map.Ingame and game.Workspace.Map.Ingame:FindFirstChild("Map") then
                        for _, Players in pairs(game.Workspace.Map.Ingame:FindFirstChild("Map"):GetChildren()) do
                            if Players:IsA("Model") and Players.Name == "Generator" then
                                if Players:FindFirstChild("Remotes") and Players:FindFirstChild("Remotes"):FindFirstChild("RE") then
                                    Players:FindFirstChild("Remotes"):FindFirstChild("RE"):FireServer()
                                end
                            end
                        end
                    end
                end)
                task.wait(2.5)
            end
        end)
    end,
})

MainTab:Toggle({
    Title = "Auto Use Coin Flip",
    Desc = "Automatically use coin flip ability",
    Value = false,
    Callback = function(Value)
        ActiveAutoUseCoinFlip = Value
        task.spawn(function()
            while ActiveAutoUseCoinFlip do
                task.spawn(function()
                    local ReplicatedStorage = game:GetService("ReplicatedStorage")
                    local RemoteEvent = ReplicatedStorage.Modules.Network:FindFirstChild("RemoteEvent")
                    if RemoteEvent then
                        RemoteEvent:FireServer("UseActorAbility", "CoinFlip")
                    end
                end)
                task.wait(1)
            end
        end)
    end,
})

MainTab:Toggle({
    Title = "Auto Kill Survivors",
    Desc = "Automatically kill survivors",
    Value = false,
    Callback = function(Value)
        ActiveAutoKillSurvivors = Value
        task.spawn(function()
            while ActiveAutoKillSurvivors do
                task.spawn(function()
                    if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and game.Workspace.Players.Survivors then
                        for _, Players in pairs(game.Workspace.Players.Survivors:GetChildren()) do
                            if Players:IsA("Model") and Players:FindFirstChild("HumanoidRootPart") then
                                game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame = Players.HumanoidRootPart.CFrame
                                local ReplicatedStorage = game:GetService("ReplicatedStorage")
                                local RemoteEvent = ReplicatedStorage.Modules.Network:FindFirstChild("RemoteEvent")
                                if RemoteEvent then
                                    RemoteEvent:FireServer("UseActorAbility", "Slash")
                                end
                            end
                        end
                    end
                end)
                task.wait(0.05)
            end
        end)
    end,
})

local DropdownTpGen = MainTab:Dropdown({
    Title = "TP To Generators",
    Desc = "Teleport to generators",
    Values = {},
    Value = "Nothings",
    Multi = false,
    Callback = function(Option)
        task.spawn(function()
            if game.Workspace.Map and game.Workspace.Map.Ingame and game.Workspace.Map.Ingame:FindFirstChild("Map") then
                for _, Players in pairs(game.Workspace.Map.Ingame:FindFirstChild("Map"):GetChildren()) do
                    if Players:IsA("Model") and Players.Name == "Generator" then
                        if Players:FindFirstChild("GeneratorTP") then
                            if Players:FindFirstChild("GeneratorTP").Value == Option then
                                if Players.PrimaryPart and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = Players.PrimaryPart.CFrame + Vector3.new(0, 5, 0)
                                end
                            end
                        end
                    end
                end
            end
        end)
    end,
})

MainTab:Button({
    Title = "Refresh Dropdown Generator",
    Desc = "Update generator list",
    Callback = function()
        local num = 1
        task.spawn(function()
            local GenTable = {}
            if game.Workspace.Map and game.Workspace.Map.Ingame and game.Workspace.Map.Ingame:FindFirstChild("Map") then
                for _, Players in pairs(game.Workspace.Map.Ingame:FindFirstChild("Map"):GetChildren()) do
                    if Players:IsA("Model") and Players.Name == "Generator" then
                        table.insert(GenTable, "Generator " .. num)
                        if not Players:FindFirstChild("GeneratorTP") then
                            task.spawn(function()
                                local NewValue = Instance.new("StringValue", Players)
                                NewValue.Name = "GeneratorTP"
                                NewValue.Value = "Generator " .. num
                            end)
                        end
                        num = num + 1
                    end
                end
            end
            DropdownTpGen:Select("Nothings")
            DropdownTpGen:SetValues(GenTable)
        end)
    end,
})


local EspTab = Window:Tab({Title = "Esp", Icon = "eye"})

EspTab:Toggle({
    Title = "Survivors Esp",
    Desc = "ESP for survivors",
    Value = false,
    Callback = function(Value)
        ActiveEspSurvivors = Value
        task.spawn(function()
            while ActiveEspSurvivors do
                task.spawn(function()
                    if game.Workspace.Players.Survivors then
                        for _, Players in pairs(game.Workspace.Players.Survivors:GetChildren()) do
                            if Players:IsA("Model") and Players:FindFirstChild("Head") and not Players:FindFirstChildOfClass("Highlight") and not Players.Head:FindFirstChildOfClass("BillboardGui") then
                                CreateEsp(Players, Color3.fromRGB(0, 255, 0), Players.Name .. " (" .. (Players:GetAttribute("Username") or "Unknown") .. ")", Players.Head, 2)
                            end
                        end
                    end
                end)
                task.wait(0.1)
            end
            if game.Workspace.Players.Survivors then
                for _, Players in pairs(game.Workspace.Players.Survivors:GetChildren()) do
                    if Players:IsA("Model") and Players:FindFirstChild("Head") and Players:FindFirstChildOfClass("Highlight") and Players.Head:FindFirstChildOfClass("BillboardGui") then
                        KeepEsp(Players, Players.Head)
                    end
                end
            end
        end)
    end,
})

EspTab:Toggle({
    Title = "Killers Esp",
    Desc = "ESP for killers",
    Value = false,
    Callback = function(Value)
        ActiveEspKillers = Value
        task.spawn(function()
            while ActiveEspKillers do
                task.spawn(function()
                    if game.Workspace.Players.Killers then
                        for _, Players in pairs(game.Workspace.Players.Killers:GetChildren()) do
                            if Players:IsA("Model") and Players:FindFirstChild("Head") then
                                if not Players:FindFirstChildOfClass("Highlight") and not Players.Head:FindFirstChildOfClass("BillboardGui") then
                                    CreateEsp(Players, Color3.fromRGB(255, 0, 0), Players.Name .. " (" .. (Players:GetAttribute("Username") or "Unknown") .. ")", Players.Head, 2)
                                end
                            end
                        end
                    end
                end)
                task.wait(0.1)
            end
            if game.Workspace.Players.Killers then
                for _, Players in pairs(game.Workspace.Players.Killers:GetChildren()) do
                    if Players:IsA("Model") and Players:FindFirstChild("Head") and Players:FindFirstChildOfClass("Highlight") and Players.Head:FindFirstChildOfClass("BillboardGui") then
                        KeepEsp(Players, Players.Head)
                    end
                end
            end
        end)
    end,
})

EspTab:Toggle({
    Title = "Generator Esp",
    Desc = "ESP for generators",
    Value = false,
    Callback = function(Value)
        ActiveEspGenerator = Value
        task.spawn(function()
            while ActiveEspGenerator do
                if game.Workspace.Map and game.Workspace.Map.Ingame and game.Workspace.Map.Ingame:FindFirstChild("Map") then
                    for _, Players in pairs(game.Workspace.Map.Ingame:FindFirstChild("Map"):GetChildren()) do
                        if Players:IsA("Model") and Players.PrimaryPart and Players.Name == "Generator" and not Players:FindFirstChildOfClass("Highlight") and not Players.PrimaryPart:FindFirstChildOfClass("BillboardGui") then
                            CreateEsp(Players, Color3.fromRGB(255, 255, 0), "Generator", Players.PrimaryPart, -2)
                        end
                    end
                end
                task.wait(0.1)
            end
            if game.Workspace.Map and game.Workspace.Map.Ingame and game.Workspace.Map.Ingame:FindFirstChild("Map") then
                for _, Players in pairs(game.Workspace.Map.Ingame:FindFirstChild("Map"):GetChildren()) do
                    if Players:IsA("Model") and Players.PrimaryPart and Players.Name == "Generator" and Players:FindFirstChildOfClass("Highlight") and Players.PrimaryPart:FindFirstChildOfClass("BillboardGui") then
                        KeepEsp(Players, Players.PrimaryPart)
                    end
                end
            end
        end)
    end,
})

EspTab:Toggle({
    Title = "Items Esp",
    Desc = "ESP for items",
    Value = false,
    Callback = function(Value)
        ActiveEspItems = Value
        task.spawn(function()
            while ActiveEspItems do
                if game.Workspace.Map.Ingame then
                    for _, Players in pairs(game.Workspace.Map.Ingame:GetChildren()) do
                        if Players:IsA("Tool") and Players:FindFirstChild("ItemRoot") and not Players:FindFirstChildOfClass("Highlight") and not Players:FindFirstChild("ItemRoot"):FindFirstChildOfClass("BillboardGui") then
                            CreateEsp(Players, Color3.fromRGB(0, 0, 255), Players.Name, Players:FindFirstChild("ItemRoot"), 1)
                        end
                    end
                    if game.Workspace.Map.Ingame:FindFirstChild("Map") then
                        for _, Players in pairs(game.Workspace.Map.Ingame:FindFirstChild("Map"):GetChildren()) do
                            if Players:IsA("Tool") and Players:FindFirstChild("ItemRoot") and not Players:FindFirstChildOfClass("Highlight") and not Players:FindFirstChild("ItemRoot"):FindFirstChildOfClass("BillboardGui") then
                                CreateEsp(Players, Color3.fromRGB(0, 0, 255), Players.Name, Players:FindFirstChild("ItemRoot"), 1)
                            end
                        end
                    end
                end
                task.wait(0.1)
            end
            if game.Workspace.Map.Ingame then
                for _, Players in pairs(game.Workspace.Map.Ingame:GetChildren()) do
                    if Players:IsA("Tool") and Players:FindFirstChild("ItemRoot") and Players:FindFirstChildOfClass("Highlight") and Players:FindFirstChild("ItemRoot"):FindFirstChildOfClass("BillboardGui") then
                        KeepEsp(Players, Players:FindFirstChild("ItemRoot"))
                    end
                end
                if game.Workspace.Map.Ingame:FindFirstChild("Map") then
                    for _, Players in pairs(game.Workspace.Map.Ingame:FindFirstChild("Map"):GetChildren()) do
                        if Players:IsA("Tool") and Players:FindFirstChild("ItemRoot") and Players:FindFirstChildOfClass("Highlight") and Players:FindFirstChild("ItemRoot"):FindFirstChildOfClass("BillboardGui") then
                            KeepEsp(Players, Players:FindFirstChild("ItemRoot"))
                        end
                    end
                end
            end
        end)
    end,
})

EspTab:Toggle({
    Title = "Ragdolls & Enemy Rig Killer Esp",
    Desc = "ESP for ragdolls",
    Value = false,
    Callback = function(Value)
        ActiveEspRagdolls = Value
        task.spawn(function()
            while ActiveEspRagdolls do
                task.spawn(function()
                    if game.Workspace.Ragdolls then
                        for _, Players in pairs(game.Workspace.Ragdolls:GetChildren()) do
                            if Players:IsA("Model") and Players.PrimaryPart and not Players:FindFirstChildOfClass("Highlight") and not Players.PrimaryPart:FindFirstChildOfClass("BillboardGui") then
                                CreateEsp(Players, Color3.fromRGB(47, 47, 47), Players.Name, Players.PrimaryPart, -1)
                            end
                        end
                    end
                end)
                task.wait(0.1)
            end
            if game.Workspace.Ragdolls then
                for _, Players in pairs(game.Workspace.Ragdolls:GetChildren()) do
                    if Players:IsA("Model") and Players.PrimaryPart and Players:FindFirstChildOfClass("Highlight") and Players.PrimaryPart:FindFirstChildOfClass("BillboardGui") then
                        KeepEsp(Players, Players.PrimaryPart)
                    end
                end
            end
        end)
    end,
})

Window:Section({ Title = "WindUI " .. tostring(WindUI.Version or "Latest") })

WindUI:Notify({
    Title = "Punk Hub Loaded",
    Content = "Press V to toggle menu",
    Duration = 5,
    Icon = "zap"
})

Window:Open()

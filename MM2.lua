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

WindUI:Popup({
    Title = "Punk Hub",
    Icon = "rbxassetid://89306785777733",
    IconThemed = true,
    Theme = "Aurora",
    Content = "Welcome To Punk Hub. A flexible and powerful script hub for Roblox, designed to enhance your gaming experience with a variety of features.",
    Buttons = {
        { Title = "Copy Discord Link", Variant = "Primary", Callback = function() setclipboard("https://discord.gg/" .. InviteCode) end },
        { Title = "Exit", Variant = "Secondary", Callback = function() game:GetService("Players").LocalPlayer:Kick("Get out!") end },
        { Title = "Load", Icon = "arrow-right", Variant = "Primary", Callback = function()
            Confirmed = true

            local TweenService = game:GetService("TweenService")
            local Lighting = game:GetService("Lighting")
            local player = game:GetService("Players").LocalPlayer

            local blur = Instance.new("BlurEffect", Lighting)
            blur.Size = 0
            TweenService:Create(blur, TweenInfo.new(0.5), {Size = 24}):Play()

            local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
            screenGui.ResetOnSpawn = false
            screenGui.IgnoreGuiInset = true

            local frame = Instance.new("Frame", screenGui)
            frame.Size = UDim2.new(1,0,1,0)
            frame.BackgroundTransparency = 1

            local bg = Instance.new("Frame", frame)
            bg.Size = UDim2.new(1,0,1,0)
            bg.BackgroundColor3 = Color3.fromRGB(0,0,0)
            bg.BackgroundTransparency = 1
            TweenService:Create(bg, TweenInfo.new(0.5), {BackgroundTransparency = 0.3}):Play()

            local word = "Punk Hub"
            local letters = {}

            task.wait(1)

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
            screenGui:Destroy()
            blur:Destroy()
            LoadComplete = true
        end }
    }
})

repeat task.wait() until Confirmed
repeat task.wait() until LoadComplete

local Services = {
    Players = game:GetService("Players"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    RunService = game:GetService("RunService"),
    TweenService = game:GetService("TweenService"),
    HttpService = game:GetService("HttpService"),
    TextChatService = game:GetService("TextChatService"),
    UserInputService = game:GetService("UserInputService"),
    Workspace = workspace
}

local LocalPlayer = Services.Players.LocalPlayer

local Config = {
    GameId = 66654135,
    ShootOffset = 2.8,
    OffsetToPingMultiplier = 1,
}

local State = {
    PlayerData = {},
    Highlights = {},
    TimerTask = nil,
    TimerLabel = nil,
}

local Flags = {
    PlayerESP = false,
    GunDropESP = false,
    TrapDetection = false,
    AutoShooting = false,
    AutoGetDroppedGun = false,
    SimulateKnifeThrow = false,
    MurdererKillAura = false,

}

local Utils = {}

function Utils.Notify(title, content, duration, icon)
    WindUI:Notify({
        Title = title,
        Content = content,
        Duration = duration or 3,
        Icon = icon or "lucide:info",
    })
end

function Utils.Dialog(title, content, buttons)
    local winduiButtons = {}
    local onSelectEvent = Instance.new("BindableEvent")
    
    for _, btnTitle in ipairs(buttons) do
        table.insert(winduiButtons, {
            Title = btnTitle,
            Callback = function()
                onSelectEvent:Fire(btnTitle)
            end,
        })
    end

    local dialogInstance = WindUI:Dialog({
        Title = title,
        Content = content,
        Buttons = winduiButtons,
    })
    dialogInstance:Show()

    return {
        Wait = function()
            local result = onSelectEvent.Event:Wait()
            dialogInstance:Close()
            return result
        end
    }
end

function Utils.SecondsToMinutes(seconds)
    if seconds == -1 then return "0m 0s" end
    local minutes = math.floor(seconds / 60)
    local remainingSeconds = seconds % 60
    return string.format("%dm %ds", minutes, remainingSeconds)
end

local GameUtils = {}

function GameUtils.FindMurderer()
    for _, player in ipairs(Services.Players:GetPlayers()) do
        if player.Backpack:FindFirstChild("Knife") then return player end
    end
    for _, player in ipairs(Services.Players:GetPlayers()) do
        if not player.Character then continue end
        if player.Character:FindFirstChild("Knife") then return player end
    end
    if State.PlayerData then
        for playerName, data in pairs(State.PlayerData) do
            if data.Role == "Murderer" then
                if Services.Players:FindFirstChild(playerName) then 
                    return Services.Players:FindFirstChild(playerName) 
                end
            end
        end
    end
    return nil
end

function GameUtils.FindSheriff()
    for _, player in ipairs(Services.Players:GetPlayers()) do
        if player.Backpack:FindFirstChild("Gun") then return player end
    end
    for _, player in ipairs(Services.Players:GetPlayers()) do
        if not player.Character then continue end
        if player.Character:FindFirstChild("Gun") then return player end
    end
    if State.PlayerData then
        for playerName, data in pairs(State.PlayerData) do
            if data.Role == "Sheriff" then
                if Services.Players:FindFirstChild(playerName) then 
                    return Services.Players:FindFirstChild(playerName) 
                end
            end
        end
    end
    return nil
end

function GameUtils.FindSheriffNotMe()
    for _, player in ipairs(Services.Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if player.Backpack:FindFirstChild("Gun") then return player end
    end
    for _, player in ipairs(Services.Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end
        if player.Character:FindFirstChild("Gun") then return player end
    end
    if State.PlayerData then
        for playerName, data in pairs(State.PlayerData) do
            if data.Role == "Sheriff" then
                if Services.Players:FindFirstChild(playerName) then
                    if Services.Players:FindFirstChild(playerName) == LocalPlayer then continue end
                    return Services.Players:FindFirstChild(playerName)
                end
            end
        end
    end
    return nil
end

function GameUtils.GetMap()
    for _, obj in ipairs(Services.Workspace:GetChildren()) do
        if obj:FindFirstChild("CoinContainer") and obj:FindFirstChild("Spawns") then
            return obj
        end
    end
    return nil
end

function GameUtils.FindNearestPlayer()
    local nearestPlayer = nil
    local shortestDistance = math.huge

    for _, player in ipairs(Services.Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local localRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local otherRootPart = player.Character:FindFirstChild("HumanoidRootPart")

            if localRootPart and otherRootPart then
                local distance = (localRootPart.Position - otherRootPart.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    nearestPlayer = player
                end
            end
        end
    end
    return nearestPlayer
end

function GameUtils.GetPredictedPosition(player, currentShootOffset)
    local char = player.Character
    if not char then 
        Utils.Notify("Prediction Error", "No character found for prediction.", 3, "lucide:x")
        return Vector3.new(0,0,0) 
    end

    local playerHRP = char:FindFirstChild("UpperTorso")
    local playerHum = char:FindFirstChild("Humanoid")
    
    if not playerHRP or not playerHum then
        return Vector3.new(0,0,0)
    end

    local velocity = playerHRP.AssemblyLinearVelocity
    local playerMoveDirection = playerHum.MoveDirection
    
    local predictedPosition = playerHRP.Position + 
        ((velocity * Vector3.new(0.75, 0.5, 0.75))) * (currentShootOffset / 15) + 
        playerMoveDirection * currentShootOffset
    
    predictedPosition = predictedPosition * (((LocalPlayer:GetNetworkPing() * 1000) * 
        ((Config.OffsetToPingMultiplier - 1) * 0.01)) + 1)

    return predictedPosition
end

local ESP = {}

function ESP.UpdatePlayerESP()
    for i = #State.Highlights, 1, -1 do
        local h = State.Highlights[i]
        if h and h.Name == "PlayerHighlight" then
            h.Adornee = nil
            h:Destroy()
            table.remove(State.Highlights, i)
        end
    end

    if not Flags.PlayerESP then return end

    for _, player in ipairs(Services.Players:GetChildren()) do
        if player.Character ~= nil then
            local character = player.Character

            local h = Instance.new("Highlight")
            h.Parent = Services.Workspace.CurrentCamera
            h.Adornee = character
            h.FillTransparency = 0.5
            h.OutlineTransparency = 0
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.Name = "PlayerHighlight"
            table.insert(State.Highlights, h)

            if player == GameUtils.FindMurderer() then
                h.FillColor = Color3.fromRGB(255, 0, 0)
                h.OutlineColor = Color3.fromRGB(255, 0, 0)
            elseif player == GameUtils.FindSheriff() then
                h.FillColor = Color3.fromRGB(0, 0, 255)
                h.OutlineColor = Color3.fromRGB(0, 0, 255)
            else
                h.FillColor = Color3.fromRGB(0, 255, 0)
                h.OutlineColor = Color3.fromRGB(0, 255, 0)
            end
        end
    end
end

function ESP.ClearHighlights(highlightName)
    for i = #State.Highlights, 1, -1 do
        local h = State.Highlights[i]
        if h and h.Name == highlightName then
            h.Adornee = nil
            h:Destroy()
            table.remove(State.Highlights, i)
        end
    end
end

local Combat = {}

function Combat.ShootMurderer()
    if GameUtils.FindSheriff() ~= LocalPlayer then
        Utils.Notify("Shoot Murderer", "You're not sheriff/hero.", 3, "lucide:x")
        return
    end

    local murderer = GameUtils.FindMurderer() or GameUtils.FindSheriffNotMe()
    if not murderer then
        Utils.Notify("Shoot Murderer", "No murderer (or sheriff) to shoot.", 3, "lucide:x")
        return
    end

    if not LocalPlayer.Character:FindFirstChild("Gun") then
        if LocalPlayer.Backpack:FindFirstChild("Gun") then
            LocalPlayer.Character:FindFirstChild("Humanoid"):EquipTool(LocalPlayer.Backpack:FindFirstChild("Gun"))
        else
            Utils.Notify("Shoot Murderer", "You don't have the gun.", 3, "lucide:x")
            return
        end
    end

    local predictedPosition = GameUtils.GetPredictedPosition(murderer, Config.ShootOffset)

    local args = {
        [1] = 1,
        [2] = predictedPosition,
        [3] = "AH2"
    }

    local playerGun = LocalPlayer.Character:FindFirstChild("Gun")
    if playerGun and playerGun:FindFirstChild("KnifeLocal") and 
       playerGun.KnifeLocal:FindFirstChild("CreateBeam") and 
       playerGun.KnifeLocal.CreateBeam:FindFirstChild("RemoteFunction") then
        playerGun.KnifeLocal.CreateBeam.RemoteFunction:InvokeServer(unpack(args))
        Utils.Notify("Shoot Murderer", "Fired shot at predicted position.", 3, "lucide:check")
    else
        Utils.Notify("Shoot Murderer", "Could not find gun remote.", 3, "lucide:x")
    end
end

function Combat.DelayedShootMurderer()
    if GameUtils.FindSheriff() ~= LocalPlayer then
        Utils.Notify("Delayed Shoot", "You're not sheriff/hero.", 3, "lucide:x")
        return
    end

    local murderer = GameUtils.FindMurderer() or GameUtils.FindSheriffNotMe()
    if not murderer then
        Utils.Notify("Delayed Shoot", "No murderer to shoot.", 3, "lucide:x")
        return
    end

    if not LocalPlayer.Character:FindFirstChild("Gun") then
        if LocalPlayer.Backpack:FindFirstChild("Gun") then
            LocalPlayer.Character:FindFirstChild("Humanoid"):EquipTool(LocalPlayer.Backpack:FindFirstChild("Gun"))
        else
            Utils.Notify("Delayed Shoot", "You don't have the gun.", 3, "lucide:x")
            return
        end
    end

    local murdererHRP = murderer.Character:FindFirstChild("HumanoidRootPart")
    if not murdererHRP then
        Utils.Notify("Delayed Shoot", "Could not find murderer's HumanoidRootPart.", 3, "lucide:x")
        return
    end

    Utils.Notify("Delayed Shoot", "Waiting for murderer to be in view...", 3, "lucide:eye-off")
    
    local steppedConn
    steppedConn = Services.RunService.Stepped:Connect(function()
        local origin = LocalPlayer.Character.HumanoidRootPart.Position
        local direction = (Vector3.new(murdererHRP.Position.X, origin.Y, murdererHRP.Position.Z) - origin).unit * 1000
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {LocalPlayer.Character}

        local raycastResult = Services.Workspace:Raycast(origin, direction, params)
        if raycastResult and raycastResult.Instance and (raycastResult.Instance == murdererHRP or raycastResult.Instance.Parent == murderer.Character) then
            local predictedPosition = GameUtils.GetPredictedPosition(murderer, Config.ShootOffset)

            local args = {
                [1] = 1,
                [2] = predictedPosition,
                [3] = "AH2"
            }

            local playerGun = LocalPlayer.Character:FindFirstChild("Gun")
            if playerGun and playerGun:FindFirstChild("KnifeLocal") and 
               playerGun.KnifeLocal:FindFirstChild("CreateBeam") and 
               playerGun.KnifeLocal.CreateBeam:FindFirstChild("RemoteFunction") then
                playerGun.KnifeLocal.CreateBeam.RemoteFunction:InvokeServer(unpack(args))
                Utils.Notify("Delayed Shoot", "Fired shot at predicted position.", 3, "lucide:check")
            else
                Utils.Notify("Delayed Shoot", "Could not find gun remote.", 3, "lucide:x")
            end
            steppedConn:Disconnect()
        end
    end)
end

function Combat.KillClosestPlayer()
    if GameUtils.FindMurderer() ~= LocalPlayer then
        Utils.Notify("Killing", "You're not the murderer.", 3, "lucide:x")
        return
    end

    if not LocalPlayer.Character:FindFirstChild("Knife") then
        if LocalPlayer.Backpack:FindFirstChild("Knife") then
            LocalPlayer.Character:FindFirstChild("Humanoid"):EquipTool(LocalPlayer.Backpack:FindFirstChild("Knife"))
        else
            Utils.Notify("Killing", "You don't have the knife.", 3, "lucide:x")
            return
        end
    end

    local nearestPlayer = GameUtils.FindNearestPlayer()
    if not nearestPlayer or not nearestPlayer.Character then
        Utils.Notify("Killing", "Can't find a player to kill.", 3, "lucide:x")
        return
    end
    
    local nearestHRP = nearestPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not nearestHRP then
        Utils.Notify("Killing", "Can't find the player's pivot.", 3, "lucide:x")
        return
    end

    if not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then 
        Utils.Notify("Killing", "Invalid character.", 3, "lucide:x") 
        return 
    end

    if not Flags.SimulateKnifeThrow then
        nearestHRP.Anchored = true
        nearestHRP.CFrame = LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame + 
            LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame.LookVector * 2
        task.wait(0.1)
        local args = { [1] = "Slash" }
        LocalPlayer.Character.Knife.Stab:FireServer(unpack(args))
        nearestHRP.Anchored = false
        Utils.Notify("Killing", "Closest player killed.", 3, "lucide:skull")
    else
        local lpknife = LocalPlayer.Character:FindFirstChild("Knife")
        if not lpknife then return end

        local toThrow = nearestHRP.Position
        local args = { [1] = lpknife:GetPivot(), [2] = toThrow }
        LocalPlayer.Character.Knife.Throw:FireServer(unpack(args))
        Utils.Notify("Killing", "Simulated knife throw at closest player.", 3, "lucide:knife")
    end
end

function Combat.KillEveryone()
    if GameUtils.FindMurderer() ~= LocalPlayer then
        Utils.Notify("Killing", "You're not the murderer.", 3, "lucide:x")
        return
    end

    if not LocalPlayer.Character:FindFirstChild("Knife") then
        if LocalPlayer.Backpack:FindFirstChild("Knife") then
            LocalPlayer.Character:FindFirstChild("Humanoid"):EquipTool(LocalPlayer.Backpack:FindFirstChild("Knife"))
        else
            Utils.Notify("Killing", "You don't have the knife.", 3, "lucide:x")
            return
        end
    end

    for _, player in ipairs(Services.Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player ~= LocalPlayer then
            player.Character:FindFirstChild("HumanoidRootPart").Anchored = true
            player.Character:FindFirstChild("HumanoidRootPart").CFrame = 
                LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame + 
                LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame.LookVector * 1
        end
    end

    task.wait(0.2)
    local args = { [1] = "Slash" }
    LocalPlayer.Character.Knife.Stab:FireServer(unpack(args))
    Utils.Notify("Killing", "Attempting to kill everyone.", 3, "lucide:skull")

    task.wait(0.5)
    for _, player in ipairs(Services.Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player ~= LocalPlayer then
            player.Character:FindFirstChild("HumanoidRootPart").Anchored = false
        end
    end
end

local Teleport = {}

function Teleport.ToLobby()
    LocalPlayer.Character:MoveTo(Vector3.new(-107, 152, 41))
    Utils.Notify("Teleports", "Teleported to lobby.", 3, "lucide:home")
end

function Teleport.ToMap()
    local spawnsFolder = GameUtils.GetMap():FindFirstChild("Spawns")
    if spawnsFolder then
        local spawns = spawnsFolder:GetChildren()
        local randomSpawn = spawns[math.random(1, #spawns)]
        LocalPlayer.Character:MoveTo(randomSpawn.Position)
        Utils.Notify("Teleports", "Teleported to map spawn.", 3, "lucide:map")
    else
        Utils.Notify("Teleports", "No map spawns found.", 3, "lucide:x")
    end
end

function Teleport.ToDroppedGun()
    local map = GameUtils.GetMap()
    if not map then 
        Utils.Notify("Teleports", "Map not found.", 3, "lucide:x") 
        return 
    end
    
    local gunDrop = map:FindFirstChild("GunDrop")
    if not gunDrop then
        Utils.Notify("Teleports", "No dropped gun found.", 3, "lucide:x")
        return
    end
    
    LocalPlayer.Character:PivotTo(gunDrop:GetPivot())
    Utils.Notify("Teleports", "Teleported to dropped gun.", 3, "lucide:gun")
end

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

local player = game.Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Parent = player:WaitForChild("PlayerGui")
gui.ResetOnSpawn = false

local button = Instance.new("ImageButton")
button.Parent = gui
button.Size = UDim2.fromScale(0.13, 0.13)
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

if Config.GameId ~= 0 and Config.GameId ~= game.GameId then 
    Utils.Notify("MM2 Module", "This game is not Murder Mystery 2.", 5, "lucide:alert-triangle")
    return
end

if not Services.ReplicatedStorage:WaitForChild("Remotes", 5) then
    local result = Utils.Dialog("Not MM2", "Load module anyway?", {"Load", "No"}):Wait()
    if result == "No" then
        Utils.Notify("MM2 Module", "Module not loaded.", 5, "lucide:x")
        return
    end
    Utils.Notify("MM2 Module", "Expect potential issues.", 5, "lucide:alert-triangle")
else
    Services.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Gameplay")
        :WaitForChild("PlayerDataChanged", 5).OnClientEvent:Connect(function(data)
        State.PlayerData = data
        if Flags.PlayerESP then
            ESP.UpdatePlayerESP()
        end
    end)
end

local EspTab = Window:Tab({ Title = "ESPs", Icon = "lucide:eye" })

EspTab:Toggle({
    Title = "Players",
    Desc = "Toggle ESP for players (Murderer, Sheriff, Innocent).",
    Flag = "PlayerESP",
    Callback = function(state)
        Flags.PlayerESP = state
        ESP.UpdatePlayerESP()
    end,
})

EspTab:Toggle({
    Title = "Dropped Gun",
    Desc = "Highlight dropped gun with yellow outline.",
    Flag = "DroppedGunESP",
    Callback = function(state)
        Flags.GunDropESP = state
        if not state then
            ESP.ClearHighlights("GunDropHighlight")
        end
    end,
})

EspTab:Toggle({
    Title = "Traps",
    Desc = "Detect and highlight murderer's traps.",
    Flag = "TrapDetectionESP",
    Callback = function(state)
        Flags.TrapDetection = state
        if not state then
            ESP.ClearHighlights("TrapHighlight")
        end
    end,
})

local ToolsTab = Window:Tab({ Title = "Tools", Icon = "lucide:wrench" })

ToolsTab:Button({
    Title = "Shoot Murderer",
    Desc = "Manually shoot the murderer if you possess the gun.",
    Callback = Combat.ShootMurderer
})

ToolsTab:Button({
    Title = "Delayed Shoot Murderer",
    Desc = "Waits for murderer to be in direct line of sight.",
    Callback = Combat.DelayedShootMurderer
})


ToolsTab:Input({
    Title = "Shoot Position Offset",
    Desc = "Adjust offset for predicted shots (default 2.8).",
    Value = tostring(Config.ShootOffset),
    Placeholder = "Enter offset value",
    Callback = function(input)
        local value = tonumber(input)
        if not value then
            Utils.Notify("Offset Setting", "Not a valid number.", 3, "lucide:x")
            return
        end
        Config.ShootOffset = value
        Utils.Notify("Offset Setting", "Shoot offset set to " .. Config.ShootOffset, 3, "lucide:check")
    end,
})

ToolsTab:Input({
    Title = "Offset-to-Ping Multiplier",
    Desc = "Adjust how offset changes with latency (default 1).",
    Value = tostring(Config.OffsetToPingMultiplier),
    Placeholder = "Enter multiplier value",
    Callback = function(input)
        local value = tonumber(input)
        if not value then
            Utils.Notify("Ping Multiplier", "Not a valid number.", 3, "lucide:x")
            return
        end
        Config.OffsetToPingMultiplier = value
        Utils.Notify("Ping Multiplier", "Multiplier set to " .. Config.OffsetToPingMultiplier, 3, "lucide:check")
    end,
})

ToolsTab:Paragraph({
    Title = "Prediction Notes",
    Desc = "Shoot offset re-aims to predicted position. Recommended: 2.8. Multiplier adjusts for latency.",
})

ToolsTab:Toggle({
    Title = "Auto Shoot Murderer",
    Desc = "Automatically fires at murderer when you are sheriff/hero.",
    Flag = "AutoShootMurderer",
    Callback = function(state)
        Flags.AutoShooting = state
        if state then
            task.spawn(function()
                while Flags.AutoShooting do
                    task.wait(0.1)
                    if GameUtils.FindSheriff() == LocalPlayer then
                        local murderer = GameUtils.FindMurderer() or GameUtils.FindSheriffNotMe()
                        if not murderer then continue end

                        local murdererHRP = murderer.Character:FindFirstChild("HumanoidRootPart")
                        if not murdererHRP then continue end

                        local characterRootPart = LocalPlayer.Character.HumanoidRootPart
                        local rayDirection = (murdererHRP.Position - characterRootPart.Position).Unit * 50

                        local raycastParams = RaycastParams.new()
                        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
                        raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}

                        local hit = Services.Workspace:Raycast(characterRootPart.Position, rayDirection, raycastParams)
                        if not hit or (hit.Instance and hit.Instance.Parent == murderer.Character) then
                            if not LocalPlayer.Character:FindFirstChild("Gun") then
                                if LocalPlayer.Backpack:FindFirstChild("Gun") then
                                    LocalPlayer.Character:FindFirstChild("Humanoid"):EquipTool(LocalPlayer.Backpack:FindFirstChild("Gun"))
                                else
                                    continue
                                end
                            end

                            local predictedPosition = GameUtils.GetPredictedPosition(murderer, Config.ShootOffset)

                            local args = {
                                [1] = 1,
                                [2] = predictedPosition,
                                [3] = "AH2"
                            }
                            local playerGun = LocalPlayer.Character:FindFirstChild("Gun")
                            if playerGun and playerGun:FindFirstChild("KnifeLocal") and 
                               playerGun.KnifeLocal:FindFirstChild("CreateBeam") and 
                               playerGun.KnifeLocal.CreateBeam:FindFirstChild("RemoteFunction") then
                                playerGun.KnifeLocal.CreateBeam.RemoteFunction:InvokeServer(unpack(args))
                            end
                        end
                    end
                end
            end)
            Utils.Notify("Auto Shoot", "Auto-shooting enabled.", 3, "lucide:target")
        else
            Utils.Notify("Auto Shoot", "Auto-shooting disabled.", 3, "lucide:target-off")
        end
    end,
})

ToolsTab:Toggle({
    Title = "Round Timer",
    Desc = "Display remaining time in current round.",
    Flag = "RoundTimer",
    Callback = function(state)
        if state then
            if not State.TimerLabel then
                State.TimerLabel = Instance.new("TextLabel")
                State.TimerLabel.Parent = game:GetService("CoreGui")
                State.TimerLabel.BackgroundTransparency = 1
                State.TimerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                State.TimerLabel.TextScaled = true
                State.TimerLabel.AnchorPoint = Vector2.new(0.5, 0.5)
                State.TimerLabel.Position = UDim2.fromScale(0.5, 0.15)
                State.TimerLabel.Size = UDim2.fromOffset(200, 50)
                State.TimerLabel.Font = Enum.Font.Montserrat
            end

            State.TimerTask = task.spawn(function()
                while task.wait(0.5) do
                    local timeLeft = Services.ReplicatedStorage.Remotes.Extras.GetTimer:InvokeServer()
                    State.TimerLabel.Text = Utils.SecondsToMinutes(timeLeft)
                end
            end)
            Utils.Notify("Round Timer", "Timer enabled.", 3, "lucide:alarm-clock")
        else
            if State.TimerTask then
                task.cancel(State.TimerTask)
                State.TimerTask = nil
            end
            if State.TimerLabel then
                State.TimerLabel:Destroy()
                State.TimerLabel = nil
            end
            Utils.Notify("Round Timer", "Timer disabled.", 3, "lucide:alarm-clock-off")
        end
    end,
})

local DetectablesTab = Window:Tab({ Title = "Detectables", Icon = "lucide:circle-alert" })

DetectablesTab:Section({ Title = "Chat Actions" })

DetectablesTab:Button({
    Title = "Send Roles to Chat",
    Desc = "Sends murderer and sheriff usernames to chat.",
    Callback = function()
        local textchannels = Services.TextChatService:WaitForChild("TextChannels"):GetChildren()
        for _, textchannel in ipairs(textchannels) do
            if textchannel.Name == "RBXSystem" then continue end
            local murd = GameUtils.FindMurderer()
            local sher = GameUtils.FindSheriff()

            local murdName = murd and murd.Name or "-"
            local sherName = sher and sher.Name or "-"
            
            local message = string.format("Murderer: %s | Sheriff: %s | <<WindUI MM2>>", murdName, sherName)
            textchannel:SendAsync(message)
            Utils.Notify("Detectables", "Role names sent to chat.", 3, "lucide:message-square-text")
        end
    end,
})

DetectablesTab:Section({ Title = "Teleports" })

DetectablesTab:Button({
    Title = "Teleport to Lobby",
    Desc = "Teleports to default lobby area.",
    Callback = Teleport.ToLobby
})

DetectablesTab:Button({
    Title = "Teleport to Map",
    Desc = "Teleports to random spawn on current map.",
    Callback = Teleport.ToMap
})

DetectablesTab:Button({
    Title = "Teleport to Dropped Gun",
    Desc = "Instantly moves to dropped gun location.",
    Callback = Teleport.ToDroppedGun
})

DetectablesTab:Toggle({
    Title = "Auto Get Gun on Drop",
    Desc = "Automatically teleports to gun when dropped.",
    Flag = "AutoGetDroppedGun",
    Callback = function(state)
        Flags.AutoGetDroppedGun = state
        if state then
            Utils.Notify("Detectables", "Auto-pickup gun enabled.", 3, "lucide:chevrons-down")
        else
            Utils.Notify("Detectables", "Auto-pickup gun disabled.", 3, "lucide:chevrons-up")
        end
    end,
})

DetectablesTab:Section({ Title = "Information" })

DetectablesTab:Button({
    Title = "Copy Murderer Username",
    Desc = "Copies murderer's username to clipboard.",
    Callback = function()
        local murderer = GameUtils.FindMurderer()
        if not murderer then
            Utils.Notify("Information", "No murderer to copy.", 3, "lucide:x")
            return
        end
        if setclipboard then
            setclipboard(murderer.Name)
            Utils.Notify("Information", "Murderer copied: " .. murderer.Name, 3, "lucide:clipboard")
        else
            Utils.Notify("Information", "Clipboard not available.", 3, "lucide:x")
        end
    end,
})

DetectablesTab:Button({
    Title = "Copy Sheriff Username",
    Desc = "Copies sheriff's username to clipboard.",
    Callback = function()
        local sheriff = GameUtils.FindSheriff()
        if not sheriff then
            Utils.Notify("Information", "No sheriff to copy.", 3, "lucide:x")
            return
        end
        if setclipboard then
            setclipboard(sheriff.Name)
            Utils.Notify("Information", "Sheriff copied: " .. sheriff.Name, 3, "lucide:clipboard")
        else
            Utils.Notify("Information", "Clipboard not available.", 3, "lucide:x")
        end
    end,
})

DetectablesTab:Section({ Title = "Killing (Murderer Only)" })

DetectablesTab:Button({
    Title = "Kill Closest Player",
    Desc = "Instantly kills nearest player as murderer.",
    Callback = Combat.KillClosestPlayer
})

DetectablesTab:Toggle({
    Title = "Simulate Knife Throw",
    Desc = "Uses knife throw animation (less reliable, more legitimate).",
    Flag = "SimulateKnifeThrow",
    Callback = function(state)
        Flags.SimulateKnifeThrow = state
        if state then
            Utils.Notify("Killing", "Knife throw simulation enabled.", 5, "lucide:alert-circle")
        end
    end,
})

DetectablesTab:Toggle({
    Title = "Murderer Kill Aura",
    Desc = "Automatically kills players who come close.",
    Flag = "MurdererKillAura",
    Callback = function(state)
        Flags.MurdererKillAura = state
        if state then
            local killAuraConn
            killAuraConn = Services.RunService.Heartbeat:Connect(function()
                if GameUtils.FindMurderer() ~= LocalPlayer then
                    killAuraConn:Disconnect()
                    Flags.MurdererKillAura = false
                    return
                end

                for _, player in ipairs(Services.Players:GetPlayers()) do
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player ~= LocalPlayer then
                        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                        if (hrp.Position - LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position).Magnitude < 7 then
                            hrp.Anchored = true
                            hrp.CFrame = LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame + 
                                LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame.LookVector * 2

                            task.wait(0.1)
                            local args = { [1] = "Slash" }
                            LocalPlayer.Character.Knife.Stab:FireServer(unpack(args))
                            hrp.Anchored = false
                            Utils.Notify("Kill Aura", "Activated on " .. player.Name, 1, "lucide:target")
                            return
                        end
                    end
                end
            end)
            Utils.Notify("Kill Aura", "Kill Aura activated.", 3, "lucide:target")
        else
            Utils.Notify("Kill Aura", "Kill Aura deactivated.", 3, "lucide:target-off")
        end
    end,
})

DetectablesTab:Button({
    Title = "Kill EVERYONE",
    Desc = "Teleports all players to you and kills them.",
    Callback = Combat.KillEveryone
})

local FunTab = Window:Tab({ Title = "Fun", Icon = "lucide:sparkles" })

FunTab:Button({
    Title = "Hold Everyone Hostage",
    Desc = "Teleports all players to your vicinity (Murderer Only).",
    Callback = function()
        if GameUtils.FindMurderer() ~= LocalPlayer then
            Utils.Notify("Fun", "You're not the murderer.", 3, "lucide:x")
            return
        end

        for _, player in ipairs(Services.Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player ~= LocalPlayer then
                player.Character:FindFirstChild("HumanoidRootPart").Anchored = true
                player.Character:FindFirstChild("HumanoidRootPart").CFrame = 
                    LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame + 
                    LocalPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame.LookVector * 5
            end
        end
        Utils.Notify("Fun", "Everyone hostage. Kill when ready.", 5, "lucide:lock")
    end,
})

FunTab:Button({
    Title = "God Mode (VERY UNSTABLE)",
    Desc = "Attempts invincibility (may crash). Use at own risk!",
    Callback = function()
        local Cam = Services.Workspace.CurrentCamera
        local Char = LocalPlayer.Character
        if not Char then 
            Utils.Notify("God Mode", "No character found.", 3, "lucide:x") 
            return 
        end
        
        local Human = Char:FindFirstChildWhichIsA("Humanoid")
        if not Human then 
            Utils.Notify("God Mode", "No humanoid found.", 3, "lucide:x") 
            return 
        end

        local nHuman = Human:Clone()
        nHuman.Parent = Char
        LocalPlayer.Character = nil
        nHuman:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
        nHuman:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        nHuman:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        nHuman.BreakJointsOnDeath = true
        Human:Destroy()

        LocalPlayer.Character = Char
        Cam.CameraSubject = nHuman
        task.wait()
        Cam.CFrame = Cam.CFrame

        local Script = Char:FindFirstChild("Animate")
        if Script then
            Script.Disabled = true
            task.wait()
            Script.Disabled = false
        end
        nHuman.Health = nHuman.MaxHealth
        nHuman.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        Utils.Notify("God Mode", "God Mode initiated. Expect instability!", 5, "lucide:alert-circle")
    end,
})

Services.Workspace.ChildAdded:Connect(function(ch)
    if ch == GameUtils.GetMap() then
        if Flags.PlayerESP then
            Utils.Notify("MM2 ESP", "Map loaded, waiting for roles...", 3)
            repeat task.wait(0.5) until GameUtils.FindMurderer() or GameUtils.FindSheriff()
            ESP.UpdatePlayerESP()
            Utils.Notify("MM2 ESP", "Player ESP reloaded.", 3)
        end
        
        if Flags.GunDropESP then
            local map = GameUtils.GetMap()
            if map then
                local gunDrop = map:FindFirstChild("GunDrop")
                if gunDrop then
                    local h = Instance.new("Highlight")
                    h.Parent = Services.Workspace.CurrentCamera
                    h.Adornee = gunDrop
                    h.FillColor = Color3.fromRGB(255, 255, 0)
                    h.OutlineColor = Color3.fromRGB(255, 255, 0)
                    h.FillTransparency = 0.5
                    h.OutlineTransparency = 0
                    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    h.Name = "GunDropHighlight"
                    table.insert(State.Highlights, h)
                    Utils.Notify("MM2 ESP", "Gun dropped! Find yellow highlight.", 3, "lucide:alert-circle")
                end
            end
        end
    end
end)

Services.Workspace.ChildRemoved:Connect(function(ch)
    if ch == GameUtils.GetMap() then
        if Flags.PlayerESP then
            Utils.Notify("MM2 ESP", "Game ended, removing ESPs.", 3)
            State.PlayerData = {}
            ESP.UpdatePlayerESP()
        end
        for i = #State.Highlights, 1, -1 do
            local h = State.Highlights[i]
            if h and (h.Name == "GunDropHighlight" or h.Name == "TrapHighlight" or h.Name == "PlayerHighlight") then
                h.Adornee = nil
                h:Destroy()
                table.remove(State.Highlights, i)
            end
        end
    end
end)

Services.Workspace.DescendantAdded:Connect(function(ch)
    if Flags.TrapDetection and ch.Name == "Trap" and ch.Parent:IsA("Folder") then
        ch.Transparency = 0
        local h = Instance.new("Highlight")
        h.Parent = Services.Workspace.CurrentCamera
        h.Adornee = ch
        h.FillColor = Color3.fromRGB(255, 0, 0)
        h.OutlineColor = Color3.fromRGB(255, 0, 0)
        h.FillTransparency = 0.5
        h.OutlineTransparency = 0
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Name = "TrapHighlight"
        table.insert(State.Highlights, h)
        Utils.Notify("MM2 ESP", "Murderer placed trap!", 3, "lucide:alert-triangle")
    end
    
    if Flags.GunDropESP and ch.Name == "GunDrop" then
        local h = Instance.new("Highlight")
        h.Parent = Services.Workspace.CurrentCamera
        h.Adornee = ch
        h.FillColor = Color3.fromRGB(255, 255, 0)
        h.OutlineColor = Color3.fromRGB(255, 255, 0)
        h.FillTransparency = 0.5
        h.OutlineTransparency = 0
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Name = "GunDropHighlight"
        table.insert(State.Highlights, h)
        Utils.Notify("MM2 ESP", "Gun dropped! Find yellow highlight.", 3, "lucide:alert-circle")
        
        if Flags.AutoGetDroppedGun then
            Utils.Notify("MM2 Tools", "Auto get gun - Teleporting...", 3)
            task.wait(0.5)
            local map = GameUtils.GetMap()
            if map then
                local gunDrop = map:FindFirstChild("GunDrop")
                if gunDrop and LocalPlayer.Character then
                     LocalPlayer.Character:PivotTo(gunDrop:GetPivot())
                end
            end
        end
    end
end)

Services.Workspace.DescendantRemoving:Connect(function(ch)
    if Flags.GunDropESP and ch.Name == "GunDrop" then
        for i = #State.Highlights, 1, -1 do
            local h = State.Highlights[i]
            if h and h.Name == "GunDropHighlight" then
                h.Adornee = nil
                h:Destroy()
                table.remove(State.Highlights, i)
            end
        end
        Utils.Notify("MM2 ESP", "Someone took the gun.", 3)
        task.wait(1)
        local sheriff = GameUtils.FindSheriff()
        if sheriff then
            Utils.Notify("MM2 ESP", "The hero is " .. sheriff.DisplayName, 3)
            ESP.UpdatePlayerESP()
        end
    end
    
    if Flags.TrapDetection and ch.Name == "Trap" and ch.Parent:IsA("Folder") then
        for i = #State.Highlights, 1, -1 do
            local h = State.Highlights[i]
            if h and h.Name == "TrapHighlight" and h.Adornee == ch then
                h.Adornee = nil
                h:Destroy()
                table.remove(State.Highlights, i)
                break
            end
        end
    end
end)

Window:Tag({ Title = "v0.0.1", Radius = 12 })

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
            Desc = ' <font color="#52525b"></font> Member Count : ' .. tostring(result.approximate_member_count) ..
            '\n <font color="#16a34a"></font> Online Count : ' .. tostring(result.approximate_presence_count),
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
                        ' <font color="#52525b"></font> Member Count : ' .. tostring(updatedResult.approximate_member_count) ..
                        '\n <font color="#16a34a"></font> Online Count : ' .. tostring(updatedResult.approximate_presence_count)
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

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local lp = Players.LocalPlayer

-- ==========================================
-- USER TIER SYSTEM (DYNAMIC LOADER)
-- ==========================================
local UserRole = _G.InvadeUserTier or "Free" 

-- ==========================================
-- GLOBAL VARIABLES & CONTROL FLAGS
-- ==========================================
_G.AutoRob = false
_G.AutoPolice = false 
_G.AutoHop = false
_G.FarmSpeed = 150 

local noclipActive = false
local rewardLoopActive = false

local originalMoneyContainer = nil
local profitFrameClone = nil
local profitTextLabel = nil

local leaderstats = lp:WaitForChild("leaderstats", 10)
local cashStat = leaderstats and leaderstats:WaitForChild("Cash", 10)
local initialMoney = cashStat and cashStat.Value or 0

local function formatNumber(n)
    n = tostring(math.floor(n))
    return n:reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
end

-- ==========================================
-- NOTIFICATION SYSTEM (FOR FREE USERS)
-- ==========================================
local function notifyPremium(button, originalText, originalColor)
    if button.Text == "INVALID! BUY ON DISCORD" then return end

    button.Text = "INVALID! BUY ON DISCORD"
    button.BackgroundColor3 = Color3.fromRGB(200, 30, 30)

    local originalPos = button.Position
    local offset = 0.02
    for i = 1, 4 do
        button.Position = originalPos + UDim2.new(offset, 0, 0, 0)
        task.wait(0.05)
        offset = -offset
    end
    button.Position = originalPos

    task.wait(2)
    button.Text = originalText
    button.BackgroundColor3 = originalColor
end

-- ==========================================
-- SPECTATE FUNCTIONS
-- ==========================================
local function resetCamera()
    if lp.Character and lp.Character:FindFirstChild("Humanoid") then
        workspace.CurrentCamera.CameraSubject = lp.Character.Humanoid
        workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    end
end

-- ==========================================
-- CONFIGURATION SYSTEM (AUTO-RESUME)
-- ==========================================
local configName = "Willian_DE_Config_v02.json"

local function saveConfig()
    if writefile then
        local data = {
            AutoPolice = _G.AutoPolice,
            AutoHop = _G.AutoHop
        }
        pcall(function() writefile(configName, HttpService:JSONEncode(data)) end)
    end
end

local function loadConfig()
    if readfile and isfile and isfile(configName) then
        pcall(function()
            local data = HttpService:JSONDecode(readfile(configName))
            if data then
                _G.AutoPolice = data.AutoPolice or false
                if UserRole == "Premium" or UserRole == "Partner" then
                    _G.AutoHop = data.AutoHop or false
                else
                    _G.AutoHop = false
                end
            end
        end)
    end
end
loadConfig()

-- ==========================================
-- SERVER HOP FUNCTION
-- ==========================================
local function serverHop()
    if UserRole == "Free" then return end
    pcall(function()
        local httprequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
        if httprequest then
            local servers = httprequest({Url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"})
            local body = HttpService:JSONDecode(servers.Body)
            local available = {}
            local almostFull = {}

            for _, v in pairs(body.data) do
                if type(v) == "table" and v.playing > 0 and v.playing < v.maxPlayers and v.id ~= game.JobId then
                    table.insert(available, v.id)
                    if v.playing >= (v.maxPlayers - 4) then
                        table.insert(almostFull, v.id)
                    end
                end
            end

            if #almostFull > 0 then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, almostFull[math.random(1, #almostFull)], lp)
            elseif #available > 0 then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, available[math.random(1, #available)], lp)
            else
                TeleportService:Teleport(game.PlaceId, lp)
            end
        else
            TeleportService:Teleport(game.PlaceId, lp)
        end
    end)
end

-- ==========================================
-- GUI CLONER (PROFIT TRACKER)
-- ==========================================
local function setupClonedGUI()
    if profitFrameClone then profitFrameClone:Destroy() end
    if not cashStat then return end

    local playerGui = lp:WaitForChild("PlayerGui")
    while not originalMoneyContainer do
        for _, child in pairs(playerGui:GetDescendants()) do
            if child.Name == "Money" and child:FindFirstChild("bg") and child:FindFirstChild("Holder") then
                originalMoneyContainer = child
                break
            end
        end
        if not originalMoneyContainer then task.wait(0.5) end
    end

    if originalMoneyContainer then
        profitFrameClone = originalMoneyContainer:Clone()
        profitFrameClone.Name = "ScriptProfitClone"

        local profitScreenGui = CoreGui:FindFirstChild("DE_ProfitUI")
        if not profitScreenGui then
            profitScreenGui = Instance.new("ScreenGui")
            profitScreenGui.Name = "DE_ProfitUI"
            profitScreenGui.Parent = CoreGui
        end

        profitFrameClone.Parent = profitScreenGui
        profitFrameClone.Visible = true
        profitFrameClone.AnchorPoint = Vector2.new(0, 0)

        for _, obj in pairs(profitFrameClone:GetDescendants()) do
            if obj:IsA("LocalScript") then obj:Destroy() end
        end

        local holder = profitFrameClone:FindFirstChild("Holder")
        if holder then
            local moneyLabel = holder:FindFirstChild("Money")
            if moneyLabel and moneyLabel:IsA("TextLabel") then
                moneyLabel.Text = "+ 0"
                moneyLabel.TextColor3 = Color3.fromRGB(0, 255, 120) 
                profitTextLabel = moneyLabel
            end

            local signLabel = holder:FindFirstChild("$")
            if signLabel and signLabel:IsA("TextLabel") then
                signLabel.TextColor3 = Color3.fromRGB(0, 255, 120)
            end

            local plusBtn = holder:FindFirstChild("Plus")
            if plusBtn then plusBtn:Destroy() end
        end
    end
end

local function updateProfit()
    if cashStat then
        local currentMoney = cashStat.Value
        local profit = currentMoney - initialMoney
        if profit < 0 then profit = 0 end
        if profitTextLabel then profitTextLabel.Text = "+ " .. formatNumber(profit) end
    end
end

if cashStat then cashStat:GetPropertyChangedSignal("Value"):Connect(updateProfit) end

task.spawn(function()
    setupClonedGUI()
    updateProfit()
end)

-- ==========================================
-- UI DESIGN FUNCTIONS 
-- ==========================================
local function applyCorner(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = instance
end

local function applyStroke(instance, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Color3.fromRGB(50, 50, 50)
    stroke.Thickness = thickness or 1.5
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = instance
end

-- ==========================================
-- PREMIUM HUB INTERFACE
-- ==========================================
if CoreGui:FindFirstChild("DrivingEmpireRob") then CoreGui.DrivingEmpireRob:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DrivingEmpireRob"
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 480, 0, 320)
MainFrame.Position = UDim2.new(0.5, -240, 0.4, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(22, 23, 27) 
MainFrame.BorderSizePixel = 0
MainFrame.Active = true 
MainFrame.ClipsDescendants = true 
MainFrame.Parent = ScreenGui
applyCorner(MainFrame, 12)
applyStroke(MainFrame, Color3.fromRGB(60, 65, 75), 2)

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(15, 16, 20)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "DRIVING EMPIRE HUB 0.3v | " .. string.upper(UserRole)
Title.TextColor3 = Color3.fromRGB(0, 255, 120) 
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 40, 1, 0)
MinimizeBtn.Position = UDim2.new(1, -40, 0, 0)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 22
MinimizeBtn.Parent = TopBar

local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local isMinimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MainFrame:TweenSize(UDim2.new(0, 480, 0, 40), "Out", "Quad", 0.3, true)
        MinimizeBtn.Text = "+"
    else
        MainFrame:TweenSize(UDim2.new(0, 480, 0, 320), "Out", "Quad", 0.3, true)
        MinimizeBtn.Text = "-"
    end
end)

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 130, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = Color3.fromRGB(18, 19, 23)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local function createSidebarButton(text, posY)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(18, 19, 23)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    applyCorner(btn, 6)
    btn.Parent = Sidebar
    return btn
end

local TabRewardsBtn = createSidebarButton("⚙️ Auto Rewards", 15)
local TabRobBtn = createSidebarButton("🔫 Auto Rob", 55)
local TabPoliceBtn = createSidebarButton("🚓 Auto Police", 95)
local TabConfigBtn = createSidebarButton("🛠️ Settings", 135)

local PageContainer = Instance.new("Frame")
PageContainer.Size = UDim2.new(1, -130, 1, -40)
PageContainer.Position = UDim2.new(0, 130, 0, 40)
PageContainer.BackgroundTransparency = 1
PageContainer.Parent = MainFrame

local function createPage(name)
    local page = Instance.new("Frame")
    page.Name = name
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = PageContainer
    return page
end

local function createTitle(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.7, 0, 0, 30)
    lbl.Position = UDim2.new(0.05, 0, 0, 10)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(255, 200, 50)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 16
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
    return lbl
end

local function createStatus(parent)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.9, 0, 0, 35)
    lbl.Position = UDim2.new(0.05, 0, 0, 45)
    lbl.BackgroundColor3 = Color3.fromRGB(30, 32, 38)
    lbl.Text = "Status: Waiting..."
    lbl.TextColor3 = Color3.fromRGB(100, 200, 255)
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 12
    applyCorner(lbl, 6)
    applyStroke(lbl, Color3.fromRGB(50, 55, 65), 1)
    lbl.Parent = parent
    return lbl
end

-- ==========================================
-- PAGES SETUP
-- ==========================================
local RewardsPage = createPage("RewardsPage")
local RewardsTitle = createTitle(RewardsPage, "⚙️ General Automations")
local StatusRewards = createStatus(RewardsPage)

local RunRewardsBtn = Instance.new("TextButton")
RunRewardsBtn.Size = UDim2.new(0.9, 0, 0, 45)
RunRewardsBtn.Position = UDim2.new(0.05, 0, 0, 95)
RunRewardsBtn.BackgroundColor3 = Color3.fromRGB(0, 110, 255) 
RunRewardsBtn.Text = "START REWARD CYCLE"
RunRewardsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RunRewardsBtn.Font = Enum.Font.GothamBold
RunRewardsBtn.TextSize = 13
applyCorner(RunRewardsBtn, 8)
RunRewardsBtn.Parent = RewardsPage

local RobPage = createPage("RobPage")
local RobTitle = createTitle(RobPage, "💰 Outlaw: Auto Rob")

local OutlawImage = Instance.new("ImageLabel")
OutlawImage.Size = UDim2.new(0, 45, 0, 45)
OutlawImage.Position = UDim2.new(1, -60, 0, 5) 
OutlawImage.BackgroundTransparency = 1
OutlawImage.Image = "rbxassetid://92403120597369"
OutlawImage.Parent = RobPage

local StatusRob = createStatus(RobPage)

local ToggleRobBtn = Instance.new("TextButton")
ToggleRobBtn.Size = UDim2.new(0.9, 0, 0, 45)
ToggleRobBtn.Position = UDim2.new(0.05, 0, 0, 90)
ToggleRobBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ToggleRobBtn.Text = "START AUTO ROB [OFF]"
ToggleRobBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleRobBtn.Font = Enum.Font.GothamBold
ToggleRobBtn.TextSize = 14
applyCorner(ToggleRobBtn, 8)
ToggleRobBtn.Parent = RobPage

local SpeedTitle = Instance.new("TextLabel")
SpeedTitle.Size = UDim2.new(0.9, 0, 0, 20)
SpeedTitle.Position = UDim2.new(0.05, 0, 0, 145)
SpeedTitle.BackgroundTransparency = 1
SpeedTitle.Text = "Speed (Current: FAST)"
SpeedTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
SpeedTitle.Font = Enum.Font.GothamSemibold
SpeedTitle.TextXAlignment = Enum.TextXAlignment.Left
SpeedTitle.Parent = RobPage

local SafeBtn = Instance.new("TextButton"); SafeBtn.Size = UDim2.new(0.28, 0, 0, 30); SafeBtn.Position = UDim2.new(0.05, 0, 0, 170); SafeBtn.BackgroundColor3 = Color3.fromRGB(30, 150, 60); SafeBtn.Text = "SAFE"; SafeBtn.TextColor3 = Color3.fromRGB(255, 255, 255); SafeBtn.Font = Enum.Font.GothamBold; applyCorner(SafeBtn, 6); SafeBtn.Parent = RobPage
local FastBtn = Instance.new("TextButton"); FastBtn.Size = UDim2.new(0.28, 0, 0, 30); FastBtn.Position = UDim2.new(0.36, 0, 0, 170); FastBtn.BackgroundColor3 = Color3.fromRGB(200, 120, 0); FastBtn.Text = "FAST"; FastBtn.TextColor3 = Color3.fromRGB(255, 255, 255); FastBtn.Font = Enum.Font.GothamBold; applyCorner(FastBtn, 6); FastBtn.Parent = RobPage
local InsaneBtn = Instance.new("TextButton"); InsaneBtn.Size = UDim2.new(0.28, 0, 0, 30); InsaneBtn.Position = UDim2.new(0.67, 0, 0, 170); 

if UserRole == "Premium" or UserRole == "Partner" then
    InsaneBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
else
    InsaneBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80) 
end
InsaneBtn.Text = "MAX TP [👑]"; InsaneBtn.TextColor3 = Color3.fromRGB(255, 255, 255); InsaneBtn.Font = Enum.Font.GothamBold; applyCorner(InsaneBtn, 6); InsaneBtn.Parent = RobPage

local PolicePage = createPage("PolicePage")
local PoliceTitle = createTitle(PolicePage, "🚓 Auto Police Mode")

local PoliceImage = Instance.new("ImageLabel")
PoliceImage.Size = UDim2.new(0, 45, 0, 45)
PoliceImage.Position = UDim2.new(1, -60, 0, 0) 
PoliceImage.BackgroundTransparency = 1
PoliceImage.Image = "rbxassetid://132344146187144"
PoliceImage.Parent = PolicePage

local StatusPolice = createStatus(PolicePage)

local TogglePoliceBtn = Instance.new("TextButton")
TogglePoliceBtn.Size = UDim2.new(0.9, 0, 0, 40)
TogglePoliceBtn.Position = UDim2.new(0.05, 0, 0, 90)
TogglePoliceBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
TogglePoliceBtn.Text = "HUNT CRIMINALS [OFF]"
TogglePoliceBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TogglePoliceBtn.Font = Enum.Font.GothamBold
TogglePoliceBtn.TextSize = 14
applyCorner(TogglePoliceBtn, 8)
TogglePoliceBtn.Parent = PolicePage

local ToggleHopBtn = Instance.new("TextButton")
ToggleHopBtn.Size = UDim2.new(0.9, 0, 0, 40)
ToggleHopBtn.Position = UDim2.new(0.05, 0, 0, 140)
if UserRole == "Premium" or UserRole == "Partner" then
    ToggleHopBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
else
    ToggleHopBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
end
ToggleHopBtn.Text = "🔄 AUTO SERVER HOP [OFF] [👑]"
ToggleHopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleHopBtn.Font = Enum.Font.GothamBold
ToggleHopBtn.TextSize = 13
applyCorner(ToggleHopBtn, 8)
ToggleHopBtn.Parent = PolicePage

if _G.AutoPolice then
    TogglePoliceBtn.Text = "HUNT CRIMINALS [ON]"
    TogglePoliceBtn.BackgroundColor3 = Color3.fromRGB(30, 180, 60)
end
if _G.AutoHop and (UserRole == "Premium" or UserRole == "Partner") then
    ToggleHopBtn.Text = "🔄 AUTO SERVER HOP [ON] [👑]"
    ToggleHopBtn.BackgroundColor3 = Color3.fromRGB(30, 180, 60)
end

local ConfigPage = createPage("ConfigPage")
local ConfigTitle = createTitle(ConfigPage, "🛠️ Settings")

local DiscordBtn = Instance.new("TextButton")
DiscordBtn.Size = UDim2.new(0.9, 0, 0, 45)
DiscordBtn.Position = UDim2.new(0.05, 0, 0, 60)
DiscordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242) 
DiscordBtn.Text = "COPY DISCORD LINK"
DiscordBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DiscordBtn.Font = Enum.Font.GothamBold
DiscordBtn.TextSize = 14
applyCorner(DiscordBtn, 8)
DiscordBtn.Parent = ConfigPage

DiscordBtn.MouseButton1Click:Connect(function()
    pcall(function()
        if setclipboard then
            setclipboard("https://discord.gg/V2W6yatSRk")
            DiscordBtn.Text = "COPIED TO CLIPBOARD!"
            task.wait(2)
            DiscordBtn.Text = "COPY DISCORD LINK"
        else
            DiscordBtn.Text = "EXECUTOR DOES NOT SUPPORT COPY!"
            task.wait(2)
            DiscordBtn.Text = "COPY DISCORD LINK"
        end
    end)
end)

local DestroyUIBtn = Instance.new("TextButton")
DestroyUIBtn.Size = UDim2.new(0.9, 0, 0, 45)
DestroyUIBtn.Position = UDim2.new(0.05, 0, 0, 115)
DestroyUIBtn.BackgroundColor3 = Color3.fromRGB(150, 30, 30)
DestroyUIBtn.Text = "CLOSE / DESTROY HUB"
DestroyUIBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DestroyUIBtn.Font = Enum.Font.GothamBold
DestroyUIBtn.TextSize = 14
applyCorner(DestroyUIBtn, 8)
DestroyUIBtn.Parent = ConfigPage

DestroyUIBtn.MouseButton1Click:Connect(function()
    _G.AutoRob = false; _G.AutoPolice = false; _G.AutoHop = false; rewardLoopActive = false
    saveConfig()
    resetCamera()
    if profitFrameClone then profitFrameClone:Destroy() end
    ScreenGui:Destroy()
end)

-- ==========================================
-- TAB LOGIC
-- ==========================================
local function switchTab(tabName)
    local tabs = {Rewards = TabRewardsBtn, Rob = TabRobBtn, Police = TabPoliceBtn, Config = TabConfigBtn}
    local pages = {Rewards = RewardsPage, Rob = RobPage, Police = PolicePage, Config = ConfigPage}

    for _, btn in pairs(tabs) do
        btn.BackgroundColor3 = Color3.fromRGB(18, 19, 23)
        btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    end
    for _, page in pairs(pages) do page.Visible = false end

    if tabs[tabName] then
        tabs[tabName].BackgroundColor3 = Color3.fromRGB(40, 45, 55)
        tabs[tabName].TextColor3 = Color3.fromRGB(0, 255, 120)
        pages[tabName].Visible = true
    end
end

TabRewardsBtn.MouseButton1Click:Connect(function() switchTab("Rewards") end)
TabRobBtn.MouseButton1Click:Connect(function() switchTab("Rob") end)
TabPoliceBtn.MouseButton1Click:Connect(function() switchTab("Police") end)
TabConfigBtn.MouseButton1Click:Connect(function() switchTab("Config") end)
switchTab("Rewards") 

-- ==========================================
-- CORE FUNCTIONS & STATE RESETS
-- ==========================================
local function resetCharacterState()
    noclipActive = false
    workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    if lp.Character then
        local hum = lp.Character:FindFirstChild("Humanoid")
        local hrp = lp.Character:FindFirstChild("HumanoidRootPart")
        if hum then hum.WalkSpeed = 16; hum.JumpPower = 50 end
        if hrp then hrp.Anchored = false end
    end
end

RunRewardsBtn.MouseButton1Click:Connect(function()
    if rewardLoopActive then return end 
    rewardLoopActive = true
    RunRewardsBtn.Text = "RUNNING CYCLES (EVERY 5 MIN)..."
    RunRewardsBtn.BackgroundColor3 = Color3.fromRGB(80, 85, 95) 

    task.spawn(function()
        if StatusRewards then StatusRewards.Text = "Status: Initial Collection Complete (1 to 12)..." end
        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            if obj.Name == "PlayRewards" and obj:IsA("RemoteEvent") then
                for i = 1, 12 do pcall(function() obj:FireServer(i, false) end) task.wait(0.1) end
                break
            end
        end

        for cycle = 1, 7 do
            if not rewardLoopActive then break end
            if StatusRewards then StatusRewards.Text = "Status: Waiting 5 minutes (Cycle " .. cycle .. "/7)..." end
            task.wait(300) 
            if not rewardLoopActive then break end
            if StatusRewards then StatusRewards.Text = "Status: Attempting to claim chests (1 to 7)..." end

            for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
                if obj.Name == "PlayRewards" and obj:IsA("RemoteEvent") then
                    for i = 1, 7 do pcall(function() obj:FireServer(i, false) end) task.wait(0.1) end
                    break
                end
            end
        end

        rewardLoopActive = false
        if StatusRewards then StatusRewards.Text = "Status: All 7 cycles completed! Finished." end
        RunRewardsBtn.Text = "START REWARD CYCLE"
        RunRewardsBtn.BackgroundColor3 = Color3.fromRGB(0, 110, 255)
    end)
end)

ToggleRobBtn.MouseButton1Click:Connect(function()
    _G.AutoRob = not _G.AutoRob
    if _G.AutoRob then
        _G.AutoPolice = false 
        if TogglePoliceBtn.Text == "HUNT CRIMINALS [ON]" then 
            TogglePoliceBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            TogglePoliceBtn.Text = "HUNT CRIMINALS [OFF]" 
        end
        ToggleRobBtn.Text = "START AUTO ROB [ON]"
        ToggleRobBtn.BackgroundColor3 = Color3.fromRGB(30, 180, 60)
        StatusRob.Text = "Status: Searching for targets..."
    else
        ToggleRobBtn.Text = "START AUTO ROB [OFF]"
        ToggleRobBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        StatusRob.Text = "Status: Paused"
        resetCharacterState()
    end
end)

SafeBtn.MouseButton1Click:Connect(function() _G.FarmSpeed = 80; SpeedTitle.Text = "Speed (Current: SAFE)" end)
FastBtn.MouseButton1Click:Connect(function() _G.FarmSpeed = 150; SpeedTitle.Text = "Speed (Current: FAST)" end)
InsaneBtn.MouseButton1Click:Connect(function() 
    if UserRole == "Premium" or UserRole == "Partner" then
        _G.FarmSpeed = 9999; 
        SpeedTitle.Text = "Speed (Current: MAX TP)"
    else
        task.spawn(notifyPremium, InsaneBtn, "MAX TP [👑]", Color3.fromRGB(80, 80, 80))
    end
end)

TogglePoliceBtn.MouseButton1Click:Connect(function()
    _G.AutoPolice = not _G.AutoPolice
    saveConfig() 

    if _G.AutoPolice then
        _G.AutoRob = false 
        if ToggleRobBtn.Text == "START AUTO ROB [ON]" then 
            ToggleRobBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            ToggleRobBtn.Text = "START AUTO ROB [OFF]" 
        end
        TogglePoliceBtn.Text = "HUNT CRIMINALS [ON]"
        TogglePoliceBtn.BackgroundColor3 = Color3.fromRGB(30, 180, 60)
        StatusPolice.Text = "Status: Starting Security job..."

        pcall(function()
            local remoteJob = ReplicatedStorage:FindFirstChild("RequestStartJobSession", true)
            if remoteJob and remoteJob:IsA("RemoteEvent") then remoteJob:FireServer("Security", "jobPad") end
        end)
        task.wait(1)
        StatusPolice.Text = "Status: Scanning players' backpacks..."
    else
        TogglePoliceBtn.Text = "HUNT CRIMINALS [OFF]"
        TogglePoliceBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        StatusPolice.Text = "Status: Disabled"
        resetCamera()
        resetCharacterState()
    end
end)

ToggleHopBtn.MouseButton1Click:Connect(function()
    if UserRole ~= "Premium" and UserRole ~= "Partner" then
        task.spawn(notifyPremium, ToggleHopBtn, "🔄 AUTO SERVER HOP [OFF] [👑]", Color3.fromRGB(80, 80, 80))
        return
    end
    _G.AutoHop = not _G.AutoHop
    saveConfig() 
    if _G.AutoHop then
        ToggleHopBtn.Text = "🔄 AUTO SERVER HOP [ON] [👑]"
        ToggleHopBtn.BackgroundColor3 = Color3.fromRGB(30, 180, 60)
    else
        ToggleHopBtn.Text = "🔄 AUTO SERVER HOP [OFF] [👑]"
        ToggleHopBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)

-- ==========================================
-- ENGINE SYSTEMS (CAMERA, NOCLIP & MOVEMENT)
-- ==========================================
RunService.RenderStepped:Connect(function()
    if (_G.AutoRob or _G.AutoPolice) and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = lp.Character.HumanoidRootPart
        if not _G.AutoPolice then
            local cam = workspace.CurrentCamera
            cam.CameraType = Enum.CameraType.Scriptable
            cam.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 20, 0), hrp.Position)
        end
    end

    if originalMoneyContainer and profitFrameClone then
        local absPos = originalMoneyContainer.AbsolutePosition
        local absSize = originalMoneyContainer.AbsoluteSize
        profitFrameClone.Position = UDim2.new(0, absPos.X - (-95), 0, (absPos.Y + absSize.Y) - 41)
        profitFrameClone.Size = UDim2.new(0, absSize.X, 0, absSize.Y)
        profitFrameClone.Visible = originalMoneyContainer.Visible
    end
end)

RunService.Stepped:Connect(function()
    if noclipActive and lp.Character then
        for _, part in pairs(lp.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

local function moveToTarget(finalDest)
    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    if not hrp or not hum then return false end

    if hum.SeatPart then
        hum.Sit = false
        task.wait(0.2)
    end

    noclipActive = true
    hrp.Anchored = false 

    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
    bodyVelocity.P = 1250
    bodyVelocity.Parent = hrp

    while _G.AutoRob or _G.AutoPolice do
        local dist = (hrp.Position - finalDest).Magnitude
        if dist < 4 then break end 

        local direction = (finalDest - hrp.Position).Unit
        bodyVelocity.Velocity = direction * _G.FarmSpeed
        hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(finalDest.X, hrp.Position.Y, finalDest.Z))
        RunService.Heartbeat:Wait()
    end

    bodyVelocity:Destroy()
    hrp.Velocity = Vector3.new(0, 0, 0)
    return true
end

-- ==========================================
-- AUTO POLICE MAIN LOOP
-- ==========================================
if _G.AutoPolice then
    task.spawn(function()
        pcall(function()
            local remoteJob = ReplicatedStorage:FindFirstChild("RequestStartJobSession", true)
            if remoteJob and remoteJob:IsA("RemoteEvent") then remoteJob:FireServer("Security", "jobPad") end
        end)
    end)
end

task.spawn(function()
    while task.wait() do 
        if not _G.AutoPolice then task.wait(1) continue end

        local targetCriminal = nil
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                if p.Backpack and p.Backpack:FindFirstChild("CriminalMoneyBag") or p.Character and p.Character:FindFirstChild("CriminalMoneyBag") then
                    targetCriminal = p
                    break 
                end
            end
        end

        if targetCriminal and targetCriminal.Character and targetCriminal.Character:FindFirstChild("HumanoidRootPart") then
            if StatusPolice then StatusPolice.Text = "Status: Approaching criminal..." end
            if targetCriminal.Character:FindFirstChild("Humanoid") then workspace.CurrentCamera.CameraSubject = targetCriminal.Character.Humanoid end

            noclipActive = false
            if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") and lp.Character:FindFirstChild("Humanoid") then
                local hrp = lp.Character.HumanoidRootPart
                local hum = lp.Character.Humanoid

                hrp.Anchored = false
                hum.WalkSpeed = _G.FarmSpeed

                local targetHRP = targetCriminal.Character.HumanoidRootPart
                local targetCF = targetHRP.CFrame
                local closerCF = targetCF * CFrame.new(0, 0, 15)

                hrp.CFrame = CFrame.new(closerCF.X, targetCF.Position.Y + 2, closerCF.Z)
                task.wait(0.3) 

                local startRunTime = tick()
                while tick() - startRunTime < 4.5 and _G.AutoPolice and targetCriminal and targetCriminal.Parent do
                    if not (targetCriminal.Backpack:FindFirstChild("CriminalMoneyBag") or targetCriminal.Character:FindFirstChild("CriminalMoneyBag")) then break end

                    if targetCriminal.Character and targetCriminal.Character:FindFirstChild("HumanoidRootPart") then
                        if (hrp.Position - targetCriminal.Character.HumanoidRootPart.Position).Magnitude < 10 then break end 
                        hum:MoveTo(targetCriminal.Character.HumanoidRootPart.Position)
                    end
                    task.wait(0.1)
                end
            end

            local lastPromptFire = 0
            local lockStartTime = tick() 
            local orbitAngle = 0 
            noclipActive = true 
            local isPredicting = false

            if StatusPolice and _G.AutoPolice and targetCriminal and targetCriminal.Parent then 
                StatusPolice.Text = "Status: Locked on target: " .. targetCriminal.Name 
            end

            while _G.AutoPolice and targetCriminal and targetCriminal.Character and targetCriminal.Character:FindFirstChild("HumanoidRootPart") do
                local timeElapsed = tick() - lockStartTime
                if timeElapsed > 25 then break end
                if timeElapsed > 14 then isPredicting = true end

                local stillHasBag = false
                pcall(function()
                    if targetCriminal.Backpack:FindFirstChild("CriminalMoneyBag") or targetCriminal.Character:FindFirstChild("CriminalMoneyBag") then stillHasBag = true end
                end)
                if not stillHasBag then break end 

                if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") and lp.Character:FindFirstChild("Humanoid") then
                    local targetHRP = targetCriminal.Character.HumanoidRootPart
                    local targetPos = targetHRP.Position

                    if isPredicting then targetPos = targetPos + (targetHRP.Velocity * 0.4) end

                    local radius = isPredicting and 8 or 6 
                    local orbitSpeed = isPredicting and 6 or 4 

                    local offsetX = math.cos(math.rad(orbitAngle)) * radius
                    local offsetZ = math.sin(math.rad(orbitAngle)) * radius

                    local newPosition = targetPos + Vector3.new(offsetX, 0, offsetZ)

                    lp.Character.HumanoidRootPart.CFrame = CFrame.new(newPosition, targetHRP.Position)
                    lp.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0) 

                    orbitAngle = orbitAngle + orbitSpeed 
                    if orbitAngle >= 360 then orbitAngle = 0 end
                end

                local arrestPrompt = targetCriminal.Character:FindFirstChildWhichIsA("ProximityPrompt", true)
                if arrestPrompt and (tick() - lastPromptFire > 0.5) then
                    lastPromptFire = tick()

                    local originalView = arrestPrompt.RequiresLineOfSight
                    local originalDist = arrestPrompt.MaxActivationDistance
                    arrestPrompt.RequiresLineOfSight = false
                    arrestPrompt.MaxActivationDistance = 50 

                    if fireproximityprompt then
                        fireproximityprompt(arrestPrompt, 1)
                    else
                        VirtualInputManager:SendKeyEvent(true, arrestPrompt.KeyboardKeyCode, false, game)
                        task.wait(0.1)
                        VirtualInputManager:SendKeyEvent(false, arrestPrompt.KeyboardKeyCode, false, game)
                    end

                    arrestPrompt.RequiresLineOfSight = originalView
                    arrestPrompt.MaxActivationDistance = originalDist
                end

                RunService.Heartbeat:Wait()
            end

            if StatusPolice then StatusPolice.Text = "Status: Analyzing situation..." end
            task.wait(1)
        else
            resetCamera()
            noclipActive = false
            if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then lp.Character.HumanoidRootPart.Anchored = false end

            if _G.AutoHop then
                if StatusPolice then StatusPolice.Text = "Status: No bags found. Server Hopping..." end
                task.wait(1)
                serverHop()
                task.wait(10) 
            else
                if StatusPolice then StatusPolice.Text = "Status: Patrolling (No criminals detected)..." end
                task.wait(1)
            end
        end
    end
end)

-- ==========================================
-- AUTO ROB MAIN LOOP (REVISED LOGIC)
-- ==========================================
task.spawn(function()
    while task.wait(1) do
        if not _G.AutoRob then continue end

        -- 1. Verifica se tem mala (só para saber se vai precisar dropar depois)
        local hasBag = false
        if lp.Character and lp.Character:FindFirstChildOfClass("Tool") then hasBag = true
        elseif lp.Backpack and lp.Backpack:FindFirstChildOfClass("Tool") then hasBag = true end

        -- 2. PRIORIDADE MAXIMA: Procura por ATMs disponíveis para roubar primeiro
        local foundATM = false
        local targetPrompt = nil
        local atmModel = nil

        for _, prompt in pairs(workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                local isATM = false
                local tempObj = prompt.Parent
                local currentModel = nil
                
                for i = 1, 5 do
                    if tempObj then
                        local folderName = string.lower(tempObj.Name)
                        if string.find(folderName, "atm") or string.find(folderName, "criminal") then
                            isATM = true
                            currentModel = tempObj
                            break
                        end
                        tempObj = tempObj.Parent
                    end
                end
                
                if isATM and currentModel then
                    foundATM = true
                    targetPrompt = prompt
                    atmModel = currentModel
                    break -- Achou um caixa pronto pra roubar, foca nele!
                end
            end
        end

        -- 3. Decisão baseada no que foi encontrado
        if foundATM and targetPrompt and atmModel then
            -- Tem caixa disponível! Vai roubar (mesmo se já tiver mala)
            local targetCFrame = nil
            pcall(function()
                if atmModel:FindFirstChild("Position", true) and atmModel:FindFirstChild("Position", true):IsA("BasePart") then
                    targetCFrame = atmModel:FindFirstChild("Position", true).CFrame
                elseif targetPrompt.Parent:IsA("BasePart") then 
                    targetCFrame = targetPrompt.Parent.CFrame
                else 
                    targetCFrame = atmModel:GetPivot() 
                end
            end)

            if targetCFrame then 
                StatusRob.Text = "Status: Moving to target..."
                local safePos = targetCFrame.Position + (targetCFrame.LookVector * 4) 
                moveToTarget(safePos)

                if not _G.AutoRob then break end
                if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = lp.Character.HumanoidRootPart; local hum = lp.Character:FindFirstChild("Humanoid")

                    hrp.Anchored = true; 
                    noclipActive = true; 
                    hrp.Velocity = Vector3.new(0,0,0)
                    if hum then hum.WalkSpeed = 0; hum.JumpPower = 0 end

                    task.wait(0.5) 
                    StatusRob.Text = "Status: Using [E] to Rob..."

                    local originalView = targetPrompt.RequiresLineOfSight
                    local originalDist = targetPrompt.MaxActivationDistance
                    targetPrompt.RequiresLineOfSight = false
                    targetPrompt.MaxActivationDistance = 50 

                    local robStartTime = tick()

                    pcall(function() VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game) end)

                    while tick() - robStartTime < 15 do 
                        if not _G.AutoRob then break end
                        if not targetPrompt.Enabled then break end -- Se o prompt desativou, o roubo acabou (caixa esvaziado)

                        if fireproximityprompt then fireproximityprompt(targetPrompt, 1) end
                        task.wait(0.1)
                    end

                    pcall(function() VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game) end)

                    targetPrompt.RequiresLineOfSight = originalView
                    targetPrompt.MaxActivationDistance = originalDist

                    if hum then hum.WalkSpeed = 16; hum.JumpPower = 50 end
                    hrp.Anchored = false
                    task.wait(1.5)
                end
            end

        elseif hasBag then
            -- Não tem mais nenhum caixa disponível, MAS você tem malas! Hora de entregar.
            StatusRob.Text = "Status: Looking for drop-off point..."
            local dropOffPoint = nil
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj.Name == "CriminalDropOffPoint" then
                    local zone = obj:FindFirstChild("Zone")
                    if zone and zone:IsA("BasePart") then dropOffPoint = zone; break end
                end
            end

            if dropOffPoint then
                StatusRob.Text = "Status: Dropping off money at base..."
                moveToTarget(dropOffPoint.Position + Vector3.new(0, 3, 0))
                if not _G.AutoRob then continue end

                if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = lp.Character.HumanoidRootPart
                    noclipActive = false 
                    hrp.Anchored = false
                    StatusRob.Text = "Status: Delivering bags..."
                    task.wait(2) 
                end
            else
                StatusRob.Text = "Status: Waiting for Drop-off..."; task.wait(1)
            end

        else
            -- Não tem caixas para roubar E não tem malas. Apenas aguarda o respawn.
            noclipActive = false
            if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then lp.Character.HumanoidRootPart.Anchored = false end
            StatusRob.Text = "Status: Waiting for ATMs to spawn..."
            task.wait(1)
        end
    end
end)

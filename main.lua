-- ==========================================================
-- SISTEMA DE KEY - PANDA AUTH (CORREÇÃO DEFINITIVA DELTA)
-- ==========================================================

local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

local ServiceID = "drivingempireparadoxall" 
local KeyFileName = "Paradox_DrivingEmpire_Key.txt"

-- Captura do HWID
local rawHWID = ""
if gethwid then 
    rawHWID = gethwid() 
else 
    rawHWID = game:GetService("RbxAnalyticsService"):GetClientId() 
end
local HWID = HttpService:UrlEncode(rawHWID)
local GetKeyURL = "https://pandadevelopment.net/getkey?service=" .. ServiceID .. "&hwid=" .. HWID

-- ==========================================================
-- FUNÇÃO DO SEU SCRIPT PRINCIPAL
-- ==========================================================
local function StartMainScript()
    print("✅ [PARADOX] Key validada com sucesso! O sistema passou.")
    
    -- COMO O SCRIPT DO GITHUB FOI DELETADO, COLOQUE O SEU NOVO SCRIPT ABAIXO:
    -- loadstring(game:HttpGet("COLOQUE_O_NOVO_LINK_AQUI"))()
end

-- ==========================================================
-- VALIDAÇÃO DA KEY (ANTI-BLOQUEIO)
-- ==========================================================
local function ValidateKey(key)
    if not key or key == "" then return false, "Digite uma key!" end
    
    key = string.gsub(key, "^%s*(.-)%s*$", "%1")
    local encodedKey = HttpService:UrlEncode(key)
    local validationURL = "https://pandadevelopment.net/api/v1/validation?hwid=" .. HWID .. "&service=" .. ServiceID .. "&key=" .. encodedKey

    local success = false
    local responseBody = ""

    -- Tenta usar request/http_request (O método que o Delta prefere)
    local reqFunc = request or http_request or (syn and syn.request)
    if reqFunc then
        local ok, res = pcall(function()
            return reqFunc({Url = validationURL, Method = "GET"})
        end)
        if ok and res and res.Body then
            success = true
            responseBody = res.Body
        end
    end

    -- Se o request falhar, tenta game:HttpGet como plano B
    if not success then
        local ok, res = pcall(function()
            return game:HttpGet(validationURL)
        end)
        if ok and res then
            success = true
            responseBody = res
        end
    end

    -- Tratamento de Erro Limpo (Evita vazar texto gigante na tela)
    if not success then
        return false, "O Delta bloqueou a conexão."
    end

    if string.find(responseBody, "404") then 
        return false, "A API do Panda está offline." 
    end

    local decodeSuccess, data = pcall(function() 
        return HttpService:JSONDecode(responseBody) 
    end)
    
    if decodeSuccess and data then
        if data.success == true or data.success == "true" then 
            return true, "Sucesso!"
        else 
            return false, "Key inválida ou expirada." 
        end
    else
        if string.find(string.lower(responseBody), '"success":true') or string.find(string.lower(responseBody), "success") then 
            return true, "Sucesso!" 
        end
        return false, "Key não aprovada."
    end
end

-- ==========================================================
-- INTERFACE GRÁFICA (UI)
-- ==========================================================
local CoreGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
if CoreGui:FindFirstChild("ParadoxKeySystem") then CoreGui.ParadoxKeySystem:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ParadoxKeySystem"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 230)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -115)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true 
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10); UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1; Title.Text = "PARADOX | DRIVING EMPIRE"
Title.TextColor3 = Color3.fromRGB(255, 255, 255); Title.Font = Enum.Font.GothamBold; Title.TextSize = 16
Title.Parent = MainFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30); CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundTransparency = 1; CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80); CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextSize = 18
CloseBtn.Parent = MainFrame
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(0, 300, 0, 40); KeyInput.Position = UDim2.new(0.5, -150, 0, 60)
KeyInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40); KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.PlaceholderText = "Cole sua Key aqui..."
KeyInput.Font = Enum.Font.Gotham; KeyInput.TextSize = 14; KeyInput.Text = ""
KeyInput.ClearTextOnFocus = false; KeyInput.Parent = MainFrame
local InputCorner = Instance.new("UICorner"); InputCorner.CornerRadius = UDim.new(0, 6); InputCorner.Parent = KeyInput

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, 0, 0, 20); StatusText.Position = UDim2.new(0, 0, 0, 110)
StatusText.BackgroundTransparency = 1; StatusText.Text = "Pronto para validar."
StatusText.TextColor3 = Color3.fromRGB(170, 170, 170); StatusText.Font = Enum.Font.Gotham; StatusText.TextSize = 12
StatusText.Parent = MainFrame

local GetKeyBtn = Instance.new("TextButton")
GetKeyBtn.Size = UDim2.new(0, 140, 0, 35); GetKeyBtn.Position = UDim2.new(0, 25, 0, 150)
GetKeyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60); GetKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GetKeyBtn.Text = "Pegar Key"; GetKeyBtn.Font = Enum.Font.GothamBold; GetKeyBtn.TextSize = 14
GetKeyBtn.Parent = MainFrame
local GetKeyCorner = Instance.new("UICorner"); GetKeyCorner.CornerRadius = UDim.new(0, 6); GetKeyCorner.Parent = GetKeyBtn

local VerifyBtn = Instance.new("TextButton")
VerifyBtn.Size = UDim2.new(0, 140, 0, 35); VerifyBtn.Position = UDim2.new(0, 185, 0, 150)
VerifyBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255); VerifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
VerifyBtn.Text = "Verificar"; VerifyBtn.Font = Enum.Font.GothamBold; VerifyBtn.TextSize = 14
VerifyBtn.Parent = MainFrame
local VerifyCorner = Instance.new("UICorner"); VerifyCorner.CornerRadius = UDim.new(0, 6); VerifyCorner.Parent = VerifyBtn

-- Arrastar Interface
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then update(input) end end)

-- Botões
local isProcessing = false 

GetKeyBtn.MouseButton1Click:Connect(function()
    if isProcessing then return end; isProcessing = true
    if setclipboard then
        setclipboard(GetKeyURL)
        GetKeyBtn.Text = "Copiado!"; StatusText.Text = "Cole no navegador!"; StatusText.TextColor3 = Color3.fromRGB(255, 255, 255)
        task.wait(2); GetKeyBtn.Text = "Pegar Key"
    else
        GetKeyBtn.Text = "Erro"; StatusText.Text = "Seu executor não suporta cópia."
        task.wait(2); GetKeyBtn.Text = "Pegar Key"
    end
    isProcessing = false 
end)

VerifyBtn.MouseButton1Click:Connect(function()
    if isProcessing then return end; isProcessing = true
    VerifyBtn.Text = "Carregando..."; StatusText.Text = "Consultando servidor..."
    local inputKey = KeyInput.Text
    local isValid, message = ValidateKey(inputKey)

    if isValid then
        if writefile then writefile(KeyFileName, inputKey) end
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0); VerifyBtn.Text = "Aprovado!"
        StatusText.Text = "Key válida! Iniciando..."; StatusText.TextColor3 = Color3.fromRGB(0, 255, 0)
        task.wait(1)
        if ScreenGui then ScreenGui:Destroy() end
        StartMainScript()
    else
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0); VerifyBtn.Text = "Erro!"
        StatusText.Text = tostring(message); StatusText.TextColor3 = Color3.fromRGB(255, 80, 80)
        task.wait(2.5)
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255); VerifyBtn.Text = "Verificar"
        isProcessing = false 
    end
end)

-- Auto-Login
if isfile and isfile(KeyFileName) then
    local savedKey = readfile(KeyFileName)
    local isValid, _ = ValidateKey(savedKey)
    if isValid then StartMainScript() else if delfile then delfile(KeyFileName) end end
end

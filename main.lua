-- ==========================================================
-- SISTEMA DE KEY - PANDA AUTH (CORREÇÃO DE 404 E URL ENCODE)
-- ==========================================================

local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

-- O ServiceID exato que a API do Panda precisa
local ServiceID = "drivingempireparadoxall" 
local KeyFileName = "Paradox_DrivingEmpire_Key.txt"

-- Captura o HWID do celular/Delta
local rawHWID = ""
if gethwid then
    rawHWID = gethwid()
else
    rawHWID = game:GetService("RbxAnalyticsService"):GetClientId()
end

-- Limpa/Codifica o HWID para não quebrar o link no navegador
local HWID = HttpService:UrlEncode(rawHWID)

local GetKeyURL = "https://new.pandadevelopment.net/getkey/" .. ServiceID .. "?hwid=" .. HWID

-- ==========================================================
-- FUNÇÃO DO SEU SCRIPT PRINCIPAL
-- ==========================================================
local function StartMainScript()
    print("✅ Key validada! Iniciando sistemas de automação...")

    -- ==========================================================
    -- COLOQUE O SEU SCRIPT DO DRIVING EMPIRE AQUI DENTRO
    -- ==========================================================
    -- Exemplo: loadstring(game:HttpGet("SEU_LINK_AQUI"))()

end

-- ==========================================================
-- VALIDAÇÃO NA API OFICIAL (SEM ERRO 404)
-- ==========================================================
local function ValidateKey(key)
    if not key or key == "" then return false, "Digite uma key!" end
    
    key = string.gsub(key, "^%s*(.-)%s*$", "%1") -- Remove espaços
    local encodedKey = HttpService:UrlEncode(key)

    local validationURL = "https://api.pandadevelopment.net/v4/keys/validate?service_id=" .. ServiceID .. "&key=" .. encodedKey .. "&hwid=" .. HWID

    local success, response = pcall(function()
        return game:HttpGet(validationURL)
    end)

    if success and response then
        local decodeSuccess, data = pcall(function()
            return HttpService:JSONDecode(response)
        end)
        
        if decodeSuccess and data then
            if data.success == true then
                return true, "Sucesso!"
            else
                return false, tostring(data.message or "Key inválida ou HWID incorreto")
            end
        else
            if string.find(response, '"success":true') or string.find(response, "success") then
                return true, "Sucesso!"
            end
            return false, "Key não aprovada pelo servidor"
        end
    else
        return false, "Erro de Conexão com o Panda Auth"
    end
end

-- ==========================================================
-- AUTO-LOGIN SILENCIOSO
-- ==========================================================
if isfile and isfile(KeyFileName) then
    local savedKey = readfile(KeyFileName)
    local isValid, _ = ValidateKey(savedKey)
    if isValid then
        StartMainScript()
        return
    end
end

-- ==========================================================
-- INTERFACE GRÁFICA (UI)
-- ==========================================================
local CoreGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

if CoreGui:FindFirstChild("ParadoxKeySystem") then
    CoreGui.ParadoxKeySystem:Destroy()
end

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
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "PARADOX | DRIVING EMPIRE"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = MainFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.Parent = MainFrame

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(0, 300, 0, 40)
KeyInput.Position = UDim2.new(0.5, -150, 0, 60)
KeyInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.PlaceholderText = "Cole sua Key aqui..."
KeyInput.Font = Enum.Font.Gotham
KeyInput.TextSize = 14
KeyInput.Text = ""
KeyInput.ClearTextOnFocus = false
KeyInput.Parent = MainFrame

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 6)
InputCorner.Parent = KeyInput

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, 0, 0, 20)
StatusText.Position = UDim2.new(0, 0, 0, 110)
StatusText.BackgroundTransparency = 1
StatusText.Text = "Pronto para validar."
StatusText.TextColor3 = Color3.fromRGB(170, 170, 170)
StatusText.Font = Enum.Font.Gotham
StatusText.TextSize = 12
StatusText.Parent = MainFrame

local GetKeyBtn = Instance.new("TextButton")
GetKeyBtn.Size = UDim2.new(0, 140, 0, 35)
GetKeyBtn.Position = UDim2.new(0, 25, 0, 150)
GetKeyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
GetKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GetKeyBtn.Text = "Pegar Key"
GetKeyBtn.Font = Enum.Font.GothamBold
GetKeyBtn.TextSize = 14
GetKeyBtn.Parent = MainFrame

local GetKeyCorner = Instance.new("UICorner")
GetKeyCorner.CornerRadius = UDim.new(0, 6)
GetKeyCorner.Parent = GetKeyBtn

local VerifyBtn = Instance.new("TextButton")
VerifyBtn.Size = UDim2.new(0, 140, 0, 35)
VerifyBtn.Position = UDim2.new(0, 185, 0, 150)
VerifyBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
VerifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
VerifyBtn.Text = "Verificar"
VerifyBtn.Font = Enum.Font.GothamBold
VerifyBtn.TextSize = 14
VerifyBtn.Parent = MainFrame

local VerifyCorner = Instance.new("UICorner")
VerifyCorner.CornerRadius = UDim.new(0, 6)
VerifyCorner.Parent = VerifyBtn

-- ==========================================================
-- SISTEMA DE DRAG (ARRASTAR)
-- ==========================================================
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then update(input) end
end)

-- ==========================================================
-- LÓGICA DE BOTÕES
-- ==========================================================
local isProcessing = false 

GetKeyBtn.MouseButton1Click:Connect(function()
    if isProcessing then return end 
    isProcessing = true

    if setclipboard then
        setclipboard(GetKeyURL)
        GetKeyBtn.Text = "Link Copiado!"
        StatusText.Text = "Cole o link no seu navegador!"
        StatusText.TextColor3 = Color3.fromRGB(255, 255, 255)
        task.wait(2)
        GetKeyBtn.Text = "Pegar Key"
    else
        GetKeyBtn.Text = "Erro"
        StatusText.Text = "Erro ao copiar. Seu executor não suporta setclipboard."
        task.wait(2)
        GetKeyBtn.Text = "Pegar Key"
    end

    isProcessing = false 
end)

VerifyBtn.MouseButton1Click:Connect(function()
    if isProcessing then return end 
    isProcessing = true

    VerifyBtn.Text = "Carregando..."
    StatusText.Text = "Consultando servidor Panda Auth..."
    StatusText.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    local inputKey = KeyInput.Text

    local isValid, message = ValidateKey(inputKey)

    if isValid then
        if writefile then writefile(KeyFileName, inputKey) end
        
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        VerifyBtn.Text = "Aprovado!"
        StatusText.Text = "Key válida! Abrindo script..."
        StatusText.TextColor3 = Color3.fromRGB(0, 255, 0)
        task.wait(1)

        if ScreenGui then ScreenGui:Destroy() end
        StartMainScript()
    else
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        VerifyBtn.Text = "Erro!"
        
        StatusText.Text = "Erro: " .. tostring(message)
        StatusText.TextColor3 = Color3.fromRGB(255, 80, 80)
        
        task.wait(2.5)
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        VerifyBtn.Text = "Verificar"
        isProcessing = false 
    end
end)

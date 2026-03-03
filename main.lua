-- ==========================================================
-- SISTEMA DE KEY - PANDA AUTH (CORREÇÃO DE SERVICE ID E DEBUG)
-- ==========================================================

local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

-- AQUI ESTAVA O ERRO! O Service ID correto é o nome público do seu link
local ServiceID = "drivingempireparadoxall" 
local KeyFileName = "Paradox_DrivingEmpire_Key.txt"

-- Captura o HWID de forma segura
local HWID = ""
if gethwid then
    HWID = gethwid()
else
    HWID = game:GetService("RbxAnalyticsService"):GetClientId()
end

local GetKeyURL = "https://new.pandadevelopment.net/getkey/" .. ServiceID .. "?hwid=" .. HWID

-- ==========================================================
-- FUNÇÃO DO SEU SCRIPT PRINCIPAL
-- ==========================================================
local function StartMainScript()
    print("✅ Key validada! Iniciando sistemas de automação do carro...")

    -- ==========================================================
    -- COLOQUE O SEU SCRIPT DO DRIVING EMPIRE AQUI DENTRO
    -- ==========================================================
    -- Exemplo: loadstring(game:HttpGet("SEU_LINK_AQUI"))()

end

-- ==========================================================
-- VALIDAÇÃO NA API OFICIAL
-- ==========================================================
local function ValidateKey(key)
    if not key or key == "" then return false end
    
    -- Remove espaços em branco antes e depois da key
    key = string.gsub(key, "^%s*(.-)%s*$", "%1")

    -- URL de validação usando o nome público do serviço
    local validationURL = "https://api.pandadevelopment.net/v4/keys/validate?service_id=" .. ServiceID .. "&key=" .. key .. "&hwid=" .. HWID

    local success, response = pcall(function()
        return game:HttpGet(validationURL)
    end)

    if success and response then
        local decodeSuccess, data = pcall(function()
            return HttpService:JSONDecode(response)
        end)
        
        if decodeSuccess and data then
            if data.success == true then
                return true
            else
                -- DEBUG: Mostra no console exatamente por que a API negou a key
                warn("❌ Motivo da Key Inválida (Panda Auth):", data.message or response)
            end
        else
            if string.find(response, '"success":true') or string.find(response, "success") then
                return true
            else
                warn("❌ Erro na resposta da API:", response)
            end
        end
    else
        warn("❌ Falha ao conectar com o Panda Auth. Verifique sua internet ou se o executor suporta HttpGet.")
    end
    
    return false
end

-- ==========================================================
-- AUTO-LOGIN SILENCIOSO
-- ==========================================================
if isfile and isfile(KeyFileName) then
    local savedKey = readfile(KeyFileName)
    if ValidateKey(savedKey) then
        print("🔑 Auto-login ativado! Key válida já estava salva.")
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
MainFrame.Size = UDim2.new(0, 350, 0, 200)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -100)
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
KeyInput.Position = UDim2.new(0.5, -150, 0.4, -10)
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

local GetKeyBtn = Instance.new("TextButton")
GetKeyBtn.Size = UDim2.new(0, 140, 0, 35)
GetKeyBtn.Position = UDim2.new(0, 25, 0.7, 0)
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
VerifyBtn.Position = UDim2.new(0, 185, 0.7, 0)
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
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
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
        task.wait(2)
        GetKeyBtn.Text = "Pegar Key"
    else
        GetKeyBtn.Text = "Erro ao copiar"
        task.wait(2)
        GetKeyBtn.Text = "Pegar Key"
    end

    isProcessing = false 
end)

VerifyBtn.MouseButton1Click:Connect(function()
    if isProcessing then return end 
    isProcessing = true

    VerifyBtn.Text = "Verificando..."
    local inputKey = KeyInput.Text

    if ValidateKey(inputKey) then
        if writefile then
            writefile(KeyFileName, inputKey)
        end
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        VerifyBtn.Text = "Sucesso!"
        task.wait(1)

        if ScreenGui then ScreenGui:Destroy() end
        StartMainScript()
    else
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        VerifyBtn.Text = "Key Inválida!"
        task.wait(2)
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        VerifyBtn.Text = "Verificar"
        isProcessing = false 
    end
end)

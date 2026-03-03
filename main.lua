-- ==========================================================
-- SISTEMA DE KEY - PANDA AUTH (COM INTERFACE GRÁFICA)
-- ==========================================================

local ServiceID = "f01e5e9a-4624-483c-9bee-1fa29ae0e67e"
local KeyFileName = "Paradox_DrivingEmpire_Key.txt"

-- Captura o HWID de forma segura (suporta a maioria dos executores)
local HWID = ""
if gethwid then
    HWID = gethwid()
else
    HWID = game:GetService("RbxAnalyticsService"):GetClientId()
end

local GetKeyURL = "https://new.pandadevelopment.net/getkey/drivingempireparadoxall?hwid=" .. HWID

-- Função de Validação na API oficial do Panda Auth V4
local function ValidateKey(key)
    if not key or key == "" then return false end
    
    local validationURL = "https://api.pandadevelopment.net/v4/keys/validate?service_id=" .. ServiceID .. "&key=" .. key .. "&hwid=" .. HWID
    
    local success, response = pcall(function()
        return game:HttpGet(validationURL)
    end)
    
    if success and response then
        -- O Panda Auth retorna um JSON. Procuramos por "success":true
        if string.find(response, '"success":true') or string.find(response, "success") then
            return true
        end
    end
    return false
end

-- ==========================================================
-- INTERFACE GRÁFICA (UI)
-- ==========================================================

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- Cria a tela principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ParadoxKeySystem"
ScreenGui.Parent = CoreGui

-- Frame principal (Fundo escuro moderno)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 200)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -100)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Título
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "PARADOX | DRIVING EMPIRE"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = MainFrame

-- Caixa de texto para inserir a Key
local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(0, 300, 0, 40)
KeyInput.Position = UDim2.new(0.5, -150, 0.4, -10)
KeyInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.PlaceholderText = "Cole sua Key aqui..."
KeyInput.Font = Enum.Font.Gotham
KeyInput.TextSize = 14
KeyInput.Text = ""
KeyInput.Parent = MainFrame

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 6)
InputCorner.Parent = KeyInput

-- Botão "Pegar Key"
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

-- Botão "Verificar"
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
-- LÓGICA DOS BOTÕES
-- ==========================================================

-- Ação do botão "Pegar Key"
GetKeyBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(GetKeyURL)
        GetKeyBtn.Text = "Link Copiado!"
        task.wait(2)
        GetKeyBtn.Text = "Pegar Key"
    else
        GetKeyBtn.Text = "Erro ao copiar"
    end
end)

-- Função para iniciar o script principal
local function StartMainScript()
    ScreenGui:Destroy()
    print("✅ Key validada! Iniciando sistemas de automação do carro...")
    
    -- ==========================================================
    -- SEU SCRIPT DO DRIVING EMPIRE VAI AQUI
    -- ==========================================================
    -- Exemplo: loadstring(game:HttpGet("SEU_LINK_AQUI"))()
    
end

-- Ação do botão "Verificar"
VerifyBtn.MouseButton1Click:Connect(function()
    VerifyBtn.Text = "Verificando..."
    local inputKey = KeyInput.Text
    
    if ValidateKey(inputKey) then
        -- Salva a key para a próxima vez
        if writefile then
            writefile(KeyFileName, inputKey)
        end
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        VerifyBtn.Text = "Sucesso!"
        task.wait(1)
        StartMainScript()
    else
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        VerifyBtn.Text = "Key Inválida!"
        task.wait(2)
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        VerifyBtn.Text = "Verificar"
    end
end)

-- ==========================================================
-- AUTO-LOGIN (Ignora a UI se a key salva ainda for válida)
-- ==========================================================

if isfile and isfile(KeyFileName) then
    local savedKey = readfile(KeyFileName)
    if ValidateKey(savedKey) then
        StartMainScript()
    end
end

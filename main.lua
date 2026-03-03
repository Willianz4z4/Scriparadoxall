-- ==========================================================
-- SISTEMA DE KEY - PANDA AUTH (CORRIGIDO: ANTI-SPAM)
-- ==========================================================

local ServiceID = "f01e5e9a-4624-483c-9bee-1fa29ae0e67e"
local KeyFileName = "Paradox_DrivingEmpire_Key.txt"

-- Captura o HWID de forma segura
local HWID = ""
if gethwid then
    HWID = gethwid()
else
    HWID = game:GetService("RbxAnalyticsService"):GetClientId()
end

local GetKeyURL = "https://new.pandadevelopment.net/getkey/drivingempireparadoxall?hwid=" .. HWID

-- Função de Validação na API oficial
local function ValidateKey(key)
    if not key or key == "" then return false end
    
    local validationURL = "https://api.pandadevelopment.net/v4/keys/validate?service_id=" .. ServiceID .. "&key=" .. key .. "&hwid=" .. HWID
    
    local success, response = pcall(function()
        return game:HttpGet(validationURL)
    end)
    
    if success and response then
        if string.find(response, '"success":true') or string.find(response, "success") then
            return true
        end
    end
    return false
end

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
-- AUTO-LOGIN SILENCIOSO (Testa antes de abrir qualquer tela)
-- ==========================================================
if isfile and isfile(KeyFileName) then
    local savedKey = readfile(KeyFileName)
    if ValidateKey(savedKey) then
        StartMainScript()
        return -- Se a key já for válida, para o código aqui e nem cria a interface!
    end
end

-- ==========================================================
-- INTERFACE GRÁFICA (UI)
-- ==========================================================

local CoreGui = game:GetService("CoreGui")

-- DESTRÓI A TELA ANTIGA: Previne que a interface abra duplicada se você injetar o script várias vezes
if CoreGui:FindFirstChild("ParadoxKeySystem") then
    CoreGui.ParadoxKeySystem:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ParadoxKeySystem"
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 200)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -100)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
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
-- LÓGICA COM DEBOUNCE (ANTI-SPAM DE CLIQUES)
-- ==========================================================

local isProcessing = false -- Variável que bloqueia os botões enquanto estão trabalhando

-- Botão de Pegar Key
GetKeyBtn.MouseButton1Click:Connect(function()
    if isProcessing then return end -- Se já estiver processando, ignora o clique
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
    
    isProcessing = false -- Libera o botão novamente
end)

-- Botão de Verificar Key
VerifyBtn.MouseButton1Click:Connect(function()
    if isProcessing then return end -- Se já estiver processando, ignora o clique
    isProcessing = true
    
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
        
        -- Destrói a interface gráfica e inicia o seu script principal
        if ScreenGui then ScreenGui:Destroy() end
        StartMainScript()
    else
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        VerifyBtn.Text = "Key Inválida!"
        task.wait(2)
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        VerifyBtn.Text = "Verificar"
        isProcessing = false -- Libera o botão apenas se a key falhar, para tentar de novo
    end
end)

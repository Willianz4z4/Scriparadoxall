-- ==========================================================
-- SISTEMA DE KEY - PANDA AUTH
-- ==========================================================

local ServiceID = "f01e5e9a-4624-483c-9bee-1fa29ae0e67e"

-- 1. Captura o HWID real do usuário pelo executor
local HWID = gethwid and gethwid() or game:GetService("RbxAnalyticsService"):GetClientId()

-- 2. Cria o link dinâmico com o HWID exato da pessoa
local GetKeyURL = "https://new.pandadevelopment.net/getkey/drivingempireparadoxall?hwid=" .. HWID

-- Nome do arquivo onde a key ficará salva para o usuário não precisar logar toda vez
local KeyFileName = "Paradox_DrivingEmpire_Key.txt"

-- ==========================================================
-- FUNÇÃO DE VALIDAÇÃO NA API
-- ==========================================================
local function ValidateKey(key)
    if key == "" or key == nil then return false end
    
    -- URL de validação da API do Panda Auth
    local validationURL = "https://new.pandadevelopment.net/v4/users/validate?service_id=" .. ServiceID .. "&key=" .. key .. "&hwid=" .. HWID
    
    -- Faz a requisição HTTP silenciosa
    local success, response = pcall(function()
        return game:HttpGet(validationURL)
    end)
    
    -- Checa se a resposta da API foi positiva
    if success and response then
        if string.find(response, '"success":true') or string.find(response, "success") or response == "true" then
            return true
        end
    end
    
    return false
end

-- ==========================================================
-- LÓGICA DE EXECUÇÃO DO SCRIPT
-- ==========================================================

local UserKey = ""

-- Verifica se o usuário já possui uma key salva no aparelho
if isfile and isfile(KeyFileName) then
    UserKey = readfile(KeyFileName)
end

-- Faz a verificação final
if ValidateKey(UserKey) then
    print("✅ Key válida! Autenticado com sucesso.")
    
    -- ==========================================================
    -- COLOQUE O CÓDIGO DA SUA AUTOMAÇÃO AQUI EMBAIXO
    -- ==========================================================
    
    print("Iniciando sistemas do carro no Driving Empire...")
    -- (Seu script principal vai aqui)
    
else
    print("❌ Key inválida ou não encontrada.")
    print("🔗 O link para pegar a key foi copiado para a sua área de transferência!")
    print("Link: " .. GetKeyURL)
    
    -- Copia o link para a área de transferência do usuário automaticamente
    if setclipboard then
        setclipboard(GetKeyURL)
    end
    
    -- Expulsa o jogador se ele tentar rodar sem a key (opcional, pode remover se preferir)
    game.Players.LocalPlayer:Kick("Você precisa de uma Key! O link foi copiado para sua área de transferência: " .. GetKeyURL)
end

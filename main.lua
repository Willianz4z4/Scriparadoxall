-- [[ INVADE HUB | LOADER / GATEKEEPER ]]
-- Arquivo: main.lua

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- ==========================================
-- TEMA CUSTOMIZADO (VIBE HACKER / NEON GREEN)
-- ==========================================
local CustomTheme = {
    TextColor = Color3.fromRGB(255, 255, 255),
    Background = Color3.fromRGB(15, 18, 20),
    Topbar = Color3.fromRGB(20, 24, 28),
    Shadow = Color3.fromRGB(0, 255, 120),
    Dialog = Color3.fromRGB(20, 24, 28),
    TabBackground = Color3.fromRGB(25, 30, 35),
    TabStroke = Color3.fromRGB(35, 40, 45),
    TabBackgroundSelected = Color3.fromRGB(0, 255, 120),
    TabTextColor = Color3.fromRGB(200, 200, 200),
    SelectedTabTextColor = Color3.fromRGB(15, 18, 20),
    ElementBackground = Color3.fromRGB(28, 32, 38),
    ElementBackgroundHover = Color3.fromRGB(35, 40, 48),
    SecondaryElementBackground = Color3.fromRGB(30, 35, 40),
    ElementStroke = Color3.fromRGB(40, 45, 55),
    SecondaryElementStroke = Color3.fromRGB(40, 45, 55)
}

-- ==========================================
-- CONFIGURAÇÃO DA JANELA
-- ==========================================
local Window = Rayfield:CreateWindow({
   Name = "INVADE HUB | AUTHENTICATION",
   LoadingTitle = "Infiltrating Security...",
   LoadingSubtitle = "by Battle Bloxy",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "InvadeHub",
      FileName = "KeySystem"
   },
   Discord = {
      Enabled = true,
      Invite = "V2W6yatSRk", 
      RememberJoins = true 
   },
   KeySystem = false, 
   Theme = CustomTheme -- Aplica nosso tema verde neon
})

-- ==========================================
-- ABA 1: AUTENTICAÇÃO
-- ==========================================
local LoginTab = Window:CreateTab("Security Protocol", 4483362458) -- Ícone de cadeado/escudo
local KeyInput = ""

LoginTab:CreateParagraph({
    Title = "IDENTITY REQUIRED ⚠️", 
    Content = "Free Key: Get on LootLabs (Lasts 24h)\nPremium Key: Buy on Discord (No Ads + Auto Police + Max TP)"
})

LoginTab:CreateInput({
   Name = "Enter your Secret Key:",
   PlaceholderText = "Paste your Free or Premium Key here...",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      KeyInput = Text
   end,
})

LoginTab:CreateButton({
   Name = "INFILTRATE (Check Key)",
   Callback = function()
      
      if KeyInput == "" or KeyInput == " " then
          Rayfield:Notify({Title = "ERROR", Content = "Please enter a key!", Duration = 3})
          return
      end

      -- ==========================================
      -- 1. TESTE PREMIUM (VIP)
      -- ==========================================
      -- Simulando: Qualquer key que comece com "PREM-" passa como Elite
      if string.sub(KeyInput, 1, 5) == "PREM-" then
          Rayfield:Notify({
              Title = "ACCESS GRANTED: ELITE 👑",
              Content = "Welcome back. Injecting Premium Modules...",
              Duration = 3,
              Image = 4483362458
          })

          _G.InvadeUserTier = "Premium" 
          task.wait(2)
          Rayfield:Destroy() 

          -- Puxa o código gigante
          pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Willianz4z4/Scriparadoxall/main/driving.lua"))() end)
          return
      end

      -- ==========================================
      -- 2. TESTE FREE (PLATO BOOST API)
      -- ==========================================
      Rayfield:Notify({Title = "CHECKING...", Content = "Connecting to PlatoBoost API...", Duration = 2})
      
      -- URL oficial do PlatoBoost com o seu Token
      local PlatoURL = "https://api.platoboost.com/v1/public/whitelist/5e3a0b7b-0ff5-42ba-88e2-c58c9d328cd7?key=" .. KeyInput
      
      local success, result = pcall(function()
          return game:HttpGet(PlatoURL)
      end)

      -- Se a API responder e a palavra "true" ou "valid" estiver na resposta, a key está certa!
      if success and (string.find(result, "true") or string.find(result, "valid")) then
          Rayfield:Notify({
              Title = "ACCESS GRANTED: STANDARD ✅",
              Content = "Free Access confirmed (24h). Injecting Modules...",
              Duration = 3,
              Image = 4483362458
          })

          _G.InvadeUserTier = "Free" 
          task.wait(2)
          Rayfield:Destroy() 

          -- Puxa o código gigante
          pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Willianz4z4/Scriparadoxall/main/driving.lua"))() end)
          return
      else
          -- ==========================================
          -- 3. CHAVE INVÁLIDA (FALHA)
          -- ==========================================
          Rayfield:Notify({
              Title = "ACCESS DENIED ❌",
              Content = "Invalid or Expired Key. Intruder detected.",
              Duration = 4,
              Image = 4483362458
          })
      end
   end,
})

-- ==========================================
-- ABA 2: LINKS ÚTEIS
-- ==========================================
local LinkTab = Window:CreateTab("Get Key", 4483362458) -- Ícone de link/chave

LinkTab:CreateSection("Free Access (24 Hours)")

LinkTab:CreateButton({
   Name = "Copy Free Key Link (LootLabs)",
   Callback = function()
      setclipboard("https://lootdest.org/s?0v6Fei9P") 
      Rayfield:Notify({Title = "Copied!", Content = "Paste it in your browser to get the key.", Duration = 3})
   end,
})

LinkTab:CreateSection("Premium Access (Lifetime)")

LinkTab:CreateButton({
   Name = "Copy Discord Link (Buy Premium)",
   Callback = function()
      setclipboard("https://discord.gg/V2W6yatSRk")
      Rayfield:Notify({Title = "Copied!", Content = "Join our Discord to buy the Elite Key!", Duration = 3})
   end,
})

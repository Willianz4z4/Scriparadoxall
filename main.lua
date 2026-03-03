-- [[ INVADE HUB | LOADER / GATEKEEPER ]]
-- Arquivo: main.lua

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Tela de Login Customizada para suportar Keys Híbridas (Plato + Discord)
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
      Invite = "V2W6yatSRk", -- Seu Discord
      RememberJoins = true 
   },
   KeySystem = false -- Desativamos o nativo para usar nossa validação Híbrida Abaixo
})

local LoginTab = Window:CreateTab("Security Protocol", 4483362458)
local KeyInput = ""

LoginTab:CreateParagraph({
    Title = "Identity Required", 
    Content = "Free Key: Get on LootLabs / PlatoBoost\nPremium Key: Buy on Discord (No Ads + Auto Police)"
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
       
      -- ==========================================
      -- 1. TESTE PREMIUM (VIP)
      -- ==========================================
      -- Simulando: Qualquer key que comece com "PREM-" passa como Elite
      if string.find(KeyInput, "PREM-") then
          Rayfield:Notify({
              Title = "ACCESS GRANTED: ELITE",
              Content = "Welcome back. Injecting Premium Modules...",
              Duration = 3,
              Image = 4483362458
          })
          
          _G.InvadeUserTier = "Premium" -- Envia a info pro driving.lua
          task.wait(2)
          Rayfield:Destroy() -- Apaga a tela de login
          
          -- [!] PUXA O CÓDIGO GIGANTE DIRETO DO SEU GITHUB
          loadstring(game:HttpGet("https://raw.githubusercontent.com/Willianz4z4/Scriparadoxall/main/driving.lua"))()
          return
      end

      -- ==========================================
      -- 2. TESTE FREE (PLATO BOOST / LOOTLABS)
      -- ==========================================
      -- Simulando: Qualquer key maior que 8 caracteres passa como Free
      if string.len(KeyInput) > 8 then
          Rayfield:Notify({
              Title = "ACCESS GRANTED: STANDARD",
              Content = "Free Access confirmed. Injecting Modules...",
              Duration = 3,
              Image = 4483362458
          })
          
          _G.InvadeUserTier = "Free" -- Envia a info pro driving.lua
          task.wait(2)
          Rayfield:Destroy() -- Apaga a tela de login
          
          -- [!] PUXA O CÓDIGO GIGANTE DIRETO DO SEU GITHUB
          loadstring(game:HttpGet("https://raw.githubusercontent.com/Willianz4z4/Scriparadoxall/main/driving.lua"))()
          return
      end

      -- ==========================================
      -- 3. CHAVE INVÁLIDA (FALHA)
      -- ==========================================
      Rayfield:Notify({
          Title = "ACCESS DENIED",
          Content = "Invalid Key. Intruder detected.",
          Duration = 4,
          Image = 4483362458
      })
   end,
})

-- Botões de atalho para facilitar a vida do usuário
local LinkTab = Window:CreateTab("Get Key", 4483362458)

LinkTab:CreateButton({
   Name = "Copy Free Key Link (LootLabs)",
   Callback = function()
      setclipboard("https://lootdest.org/s?0v6Fei9P") -- O seu link original
      Rayfield:Notify({Title = "Copied!", Content = "Link copied to clipboard.", Duration = 2})
   end,
})

LinkTab:CreateButton({
   Name = "Copy Discord Link (Buy Premium)",
   Callback = function()
      setclipboard("https://discord.gg/V2W6yatSRk")
      Rayfield:Notify({Title = "Copied!", Content = "Discord link copied to clipboard.", Duration = 2})
   end,
})

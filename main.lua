-- [[ INVADE HUB | DRIVING EMPIRE 0.1v ]]
-- Arquivo Principal: main.lua

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Criando a Janela Principal
local Window = Rayfield:CreateWindow({
   Name = "INVADE HUB | DRIVING EMPIRE",
   LoadingTitle = "SYSTEM INFILTRATED",
   LoadingSubtitle = "by Willianz4z4",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "InvadeHub",
      FileName = "DrivingEmpire_Config"
   },
   KeySystem = false, -- Já validamos no Loader, aqui deixamos false
})

-- ABA DE AUTOMATIZAÇÃO (FARM)
local FarmTab = Window:CreateTab("Automations", 4483362458) -- Ícone de engrenagem

local AutoFarmToggle = FarmTab:CreateToggle({
   Name = "Auto-Farm Money (Miles)",
   CurrentValue = false,
   Flag = "AutoFarm", 
   Callback = function(Value)
      _G.AutoFarm = Value
      if Value then
         print("[SYSTEM]: Auto-farm Activated")
         -- A lógica de farm entra aqui (ex: loop de velocidade ou teleporte)
      else
         print("[SYSTEM]: Auto-farm Deactivated")
      end
   end,
})

-- ABA DE VEÍCULO (FUNÇÕES DE PERFORMANCE)
local VehicleTab = Window:CreateTab("Vehicle Mods", 4483362458) 

local NitroToggle = VehicleTab:CreateToggle({
   Name = "Infinite Nitro (Bypass)",
   CurrentValue = false,
   Flag = "InfNitro",
   Callback = function(Value)
      print("[SYSTEM]: Nitro Modification: " .. tostring(Value))
      -- Lógica para travar o valor do Nitro em 100%
   end,
})

local SpeedSlider = VehicleTab:CreateSlider({
   Name = "Speed Multiplier",
   Range = {1, 500},
   Increment = 10,
   Suffix = " MPH",
   CurrentValue = 100,
   Flag = "SpeedMod",
   Callback = function(Value)
      -- Lógica para alterar a velocidade do carro
   end,
})

-- ABA DE CRÉDITOS / STATUS
local StatusTab = Window:CreateTab("System Info", 4483362458)

StatusTab:CreateParagraph({Title = "Developer", Content = "Willianz4z4 / Battle Bloxy"})
StatusTab:CreateParagraph({Title = "Version", Content = "0.1v Public Alpha"})

Rayfield:Notify({
    Title = "SYSTEM READY",
    Content = "All modules injected successfully. Happy hacking!",
    Duration = 5,
    Image = 4483362458,
})

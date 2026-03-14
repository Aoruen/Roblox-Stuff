local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TuneUtil = require(ReplicatedStorage.Modules.Shared.Vehicles.TuneUtil)

local LocalPlayer = Players.LocalPlayer


local Config = {
    Enabled = false, 
    TopSpeedBoost = 100,
    AccelMultiplier = 1.5,
    GripMultiplier = 1.2
}

local activeTuneTables = {} 
local originalData = {} 


local oldGetTune = TuneUtil.getTune
TuneUtil.getTune = function(vehicleId, customization)
    local tune = oldGetTune(vehicleId, customization)
    
    if typeof(tune) == "table" and tune.TransmissionSpeeds then
        activeTuneTables[vehicleId] = tune
        
        if not originalData[vehicleId] then
            originalData[vehicleId] = {
                Speeds = table.clone(tune.TransmissionSpeeds),
                Torque = table.clone(tune.TransmissionTorque),
                Grip = tune.TireGrip,
                Lat = tune.LateralGrip,
                Trac = tune.Traction
            }
        end
        
        if Config.Enabled then
            local data = originalData[vehicleId]
            tune.TransmissionSpeeds = table.clone(data.Speeds)
            tune.TransmissionTorque = table.clone(data.Torque)

            local modifiers = {
                TopSpeed = { Adder = Config.TopSpeedBoost },
                TorqueMultiplier = { Multiplier = Config.AccelMultiplier },
                TireGrip = { Multiplier = Config.GripMultiplier },
                LateralGrip = { Multiplier = Config.GripMultiplier },
                Traction = { Multiplier = Config.GripMultiplier }
            }
            TuneUtil.applyIndirectModifiersToTune(tune, modifiers)
        else
            local data = originalData[vehicleId]
            tune.TransmissionSpeeds = table.clone(data.Speeds)
            tune.TransmissionTorque = table.clone(data.Torque)
            tune.TireGrip = data.Grip
            tune.LateralGrip = data.Lat
            tune.Traction = data.Trac
        end
    end
    return tune
end

local function ApplyChangesToActiveCars()
    for id, tune in pairs(activeTuneTables) do
        local data = originalData[id]
        if not data then continue end

        if Config.Enabled then
            tune.TransmissionSpeeds = table.clone(data.Speeds)
            tune.TransmissionTorque = table.clone(data.Torque)
            
            local modifiers = {
                TopSpeed = { Adder = Config.TopSpeedBoost },
                TorqueMultiplier = { Multiplier = Config.AccelMultiplier },
                TireGrip = { Multiplier = Config.GripMultiplier },
                LateralGrip = { Multiplier = Config.GripMultiplier },
                Traction = { Multiplier = Config.GripMultiplier }
            }
            TuneUtil.applyIndirectModifiersToTune(tune, modifiers)
        else
            tune.TransmissionSpeeds = table.clone(data.Speeds)
            tune.TransmissionTorque = table.clone(data.Torque)
            tune.TireGrip = data.Grip
            tune.LateralGrip = data.Lat
            tune.Traction = data.Trac
        end
    end
end


local Window = Rayfield:CreateWindow({
    Name = "Driving Empire Tuner",
    LoadingTitle = "Loading Tunes...",
    LoadingSubtitle = "By Aoruen",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "DrivingEmpireTuner",
        FileName = "Config"
    }
})

local MainTab = Window:CreateTab("Tuning", 4483362458)
local PresetTab = Window:CreateTab("Presets", 4483362458)

MainTab:CreateToggle({
    Name = "System Enabled",
    CurrentValue = false,
    Callback = function(v) Config.Enabled = v ApplyChangesToActiveCars() end
})

MainTab:CreateSlider({
    Name = "Top Speed Boost",
    Range = {0, 1000},
    Increment = 5,
    CurrentValue = 100,
    Callback = function(v) Config.TopSpeedBoost = v ApplyChangesToActiveCars() end
})

MainTab:CreateSlider({
    Name = "Acceleration Multiplier",
    Range = {1, 15},
    Increment = 0.1,
    CurrentValue = 1.5,
    Callback = function(v) Config.AccelMultiplier = v ApplyChangesToActiveCars() end
})

MainTab:CreateSlider({
    Name = "Grip Multiplier",
    Range = {0.5, 10},
    Increment = 0.1,
    CurrentValue = 1.2,
    Callback = function(v) Config.GripMultiplier = v ApplyChangesToActiveCars() end
})


MainTab:CreateSection("Memory Management")
MainTab:CreateButton({
    Name = "🗑️ Clear Cache & Reset All",
    Callback = function()
        for id, tune in pairs(activeTuneTables) do
            local data = originalData[id]
            if tune and data then
                tune.TransmissionSpeeds = table.clone(data.Speeds)
                tune.TransmissionTorque = table.clone(data.Torque)
                tune.TireGrip = data.Grip
                tune.LateralGrip = data.Lat
                tune.Traction = data.Trac
            end
        end
        table.clear(activeTuneTables)
        table.clear(originalData)
        Rayfield:Notify({Title = "Cache Cleared", Content = "Memory wiped.", Duration = 2})
    end
})


local function ApplyPreset(speed, accel, grip, name)
    Config.Enabled = true
    Config.TopSpeedBoost = speed
    Config.AccelMultiplier = accel
    Config.GripMultiplier = grip
    ApplyChangesToActiveCars()
    
    Rayfield:Notify({
        Title = "Preset Applied",
        Content = "Switched to: " .. name,
        Duration = 2
    })
end

PresetTab:CreateSection("Standard Profiles")
PresetTab:CreateButton({ Name = "🏠 Factory Default", Callback = function() ApplyPreset(0, 1.0, 1.0, "Realistic") end })
PresetTab:CreateButton({ Name = "🏁 Daily Driver+", Callback = function() ApplyPreset(50, 1.3, 1.1, "Daily+") end })
PresetTab:CreateButton({ Name = "🏎️ Sport+", Callback = function() ApplyPreset(150, 2.2, 1.5, "Sport+") end })

PresetTab:CreateSection("Performance Profiles")
PresetTab:CreateButton({ Name = "🏎️ Track Beast", Callback = function() ApplyPreset(300, 3.5, 2.5, "Track Beast") end })
PresetTab:CreateButton({ Name = "💨 Drift King", Callback = function() ApplyPreset(100, 4.0, 0.8, "Drift Spec") end })
PresetTab:CreateButton({ Name = "🚜 Rock Crawler", Callback = function() ApplyPreset(30, 2.5, 8.0, "Offroad") end })

PresetTab:CreateSection("Insane Profiles")
PresetTab:CreateButton({ Name = "🚦 Drag Launch", Callback = function() ApplyPreset(600, 12.0, 4.0, "Dragster") end })
PresetTab:CreateButton({ Name = "🚀 God Mode", Callback = function() ApplyPreset(1000, 15.0, 10.0, "God Mode") end })

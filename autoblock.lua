local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local VIM = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")

-- Локальные настройки
local scriptEnabled = true
local aimbotEnabled = true
local qrDelayEnabled = true 
local animDetectionEnabled = true  
local soundDetectionEnabled = true 
local detectionRange = 20 
local blockCooldown = false
local aimbotEndTime = 0 
local blockDelayMs = 0 
local aimPredictionFactor = 0.36

-- Настройки для глайда
local GLIDE_DURATION = 0.5
local STOP_DISTANCE = 0
local GLIDE_COOLDOWN_TIME = 3
local isGlideOnCooldown = false
local isMovingToTarget = false
local lastGlideTime = 0

local FREEZE_ACTION_NAME = "BlockWASDMovement"
local glideSoundConnection = nil 

-- Таблица для хранения визуальных аур радиуса атак
local auras = {}

-- СПИСОК АНИМАЦИЙ
local animationIds = {
    ["126830014841198"] = true, ["106538427162796"] = true, ["123172382755876"] = true, 
    ["18885909645"] = true, ["88451353906104"] = true, ["105458270463374"] = true, 
    ["83829782357897"] = true, ["125403313786645"] = true, ["118298475669935"] = true, 
    ["82113744478546"] = true, ["70371667919898"] = true, ["99135633258223"] = true, 
    ["97167027849946"] = true, ["109230267448394"] = true, ["122709416391891"] = true, 
    ["91509234639766"] = true, ["109667959938617"] = true, ["126681776859538"] = true, 
    ["129976080405072"] = true, ["121293883585738"] = true, ["90620531468240"] = true, 
    ["93366464803829"] = true, ["70785407091644"] = true,  ["121858217776572"] = true, 
    ["77375846492436"] = true, ["92567970681901"] = true, ["84069821282466"] = true, 
    ["127245564598429"] = true, ["126171487400618"] = true, ["114506382930939"] = true, 
    ["93069721274110"] = true, ["81299297965542"] = true, ["138938529389204"] = true, 
    ["85165308914564"] = true, ["114126519127454"] = true, ["108196996477620"] = true, 
    ["124705663396411"] = true, ["87347358451124"] = true, ["106860049270347"] = true, 
    ["94958041603347"] = true, ["130958529065375"] = true, ["114266653674439"] = true, 
    ["106427068964975"] = true, ["129258407299450"] = true, ["72141724360065"] = true, 
    ["109572851772132"] = true, ["129638875679599"] = true, ["88970503168421"] = true, 
    ["120950360130737"] = true, ["112366541922769"] = true,  ["92231737384093"] = true,
    ["84549159308650"] = true,
}

-- СПИСОК ЗВУКОВ ДЛЯ АВТОБЛОКА
local soundIds = {
    ["75330693422988"] = true, ["80516583309685"] = true, ["98733709078792"] = true, 
    ["112809109188560"] = true, ["108907358619313"] = true, ["99215225043220"] = true, 
    ["123835423223220"] = true, ["86174610237192"] = true, ["98675142200448"] = true, 
    ["73662192846371"] = true, ["131123355704017"] = true,["132581672170205"] = true, 
    ["109348678063422"] = true, ["131406927389838"] = true, ["115678417928765"] = true, 
    ["70739368096233"] = true, ["89004992452376"] = true,  ["140242176732868"] = true, 
    ["117173212095661"] = true, ["109570290393196"] = true, ["135319730390518"] = true, 
    ["119583605486352"] = true, ["79612713897495"] = true, ["101553872555606"] = true, 
    ["79980897195554"] = true, ["93299090238530"] = true, ["104910828105172"] = true, 
    ["119664480754070"] = true, ["133709029886490"] = true, ["135041815780073"] = true, 
    ["124234993291213"] = true, ["94632255644411"] = true, ["94317217837143"] = true, 
    ["105516183226360"] = true, ["137809737339569"] = true, ["115026634746636"] = true,
    ["98742773509325"] = true, ["19942598489800"] = true, ["105840448036441"] = true,
    ["123923371062204"] = true, ["119942598489800"] = true, ["100600301396617"] = true,
    ["132160759837000"] = true,
}

-- ВАШ ОПРЕДЕЛЕННЫЙ ID ЗВУКА ДЛЯ ОСТАНОВКИ ГЛАЙДА И СНЯТИЯ ЗАМОРОЗКИ УПРАВЛЕНИЯ
local GLIDE_TRIGGERS = {
    ["132298811847315"] = true, ["125854302746190"] = true, ["18568553101"] = true,
    ["81114852524420"] = true, ["135209101640984"] = true, ["123825742002486"] = true,
}

-- ========================================================
-- ГЕНЕРАЦИЯ UI ИНТЕРФЕЙСА
-- ========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CheatMenuGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Enabled = true

local targetGui = nil
local successCore, coreGui = pcall(function() return CoreGui end)
if successCore and coreGui then targetGui = coreGui else
    targetGui = localPlayer:WaitForChild("PlayerGui", 5) or localPlayer:FindFirstChild("PlayerGui")
end
ScreenGui.Parent = targetGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 410) 
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "Auto Block [V]"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Size = UDim2.new(0, 190, 0, 35)
ToggleBtn.Position = UDim2.new(0, 15, 0, 45)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 14
ToggleBtn.Parent = MainFrame

local ToggleAimbotBtn = Instance.new("TextButton")
ToggleAimbotBtn.Name = "ToggleAimbotBtn"
ToggleAimbotBtn.Size = UDim2.new(0, 190, 0, 35)
ToggleAimbotBtn.Position = UDim2.new(0, 15, 0, 90)
ToggleAimbotBtn.Font = Enum.Font.SourceSansBold
ToggleAimbotBtn.TextSize = 14
ToggleAimbotBtn.Parent = MainFrame

local ToggleQRBtn = Instance.new("TextButton")
ToggleQRBtn.Name = "ToggleQRBtn"
ToggleQRBtn.Size = UDim2.new(0, 190, 0, 35)
ToggleQRBtn.Position = UDim2.new(0, 15, 0, 135)
ToggleQRBtn.Font = Enum.Font.SourceSansBold
ToggleQRBtn.TextSize = 14
ToggleQRBtn.Parent = MainFrame

local ToggleAnimModeBtn = Instance.new("TextButton")
ToggleAnimModeBtn.Name = "ToggleAnimModeBtn"
ToggleAnimModeBtn.Size = UDim2.new(0, 92, 0, 30)
ToggleAnimModeBtn.Position = UDim2.new(0, 15, 0, 180)
ToggleAnimModeBtn.Font = Enum.Font.SourceSansBold
ToggleAnimModeBtn.TextSize = 11
ToggleAnimModeBtn.Parent = MainFrame

local ToggleSoundModeBtn = Instance.new("TextButton")
ToggleSoundModeBtn.Name = "ToggleSoundModeBtn"
ToggleSoundModeBtn.Size = UDim2.new(0, 92, 0, 30)
ToggleSoundModeBtn.Position = UDim2.new(0, 113, 0, 180)
ToggleSoundModeBtn.Font = Enum.Font.SourceSansBold
ToggleSoundModeBtn.TextSize = 11
ToggleSoundModeBtn.Parent = MainFrame 

local RangeContainer = Instance.new("Frame")
RangeContainer.Size = UDim2.new(0, 190, 0, 35)
RangeContainer.Position = UDim2.new(0, 15, 0, 220) 
RangeContainer.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
RangeContainer.Parent = MainFrame

local RangeCorner = Instance.new("UICorner")
RangeCorner.CornerRadius = UDim.new(0, 6)
RangeCorner.Parent = RangeContainer

local RangeLabel = Instance.new("TextLabel")
RangeLabel.Size = UDim2.new(0, 110, 1, 0)
RangeLabel.Position = UDim2.new(0, 10, 0, 0)
RangeLabel.BackgroundTransparency = 1
RangeLabel.Text = "Detection Range:"
RangeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
RangeLabel.Font = Enum.Font.SourceSansBold
RangeLabel.TextSize = 14
RangeLabel.Parent = RangeContainer

local RangeInput = Instance.new("TextBox")
RangeInput.Size = UDim2.new(0, 60, 0, 25)
RangeInput.Position = UDim2.new(1, -70, 0.5, -12)
RangeInput.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
RangeInput.Text = tostring(detectionRange)
RangeInput.TextColor3 = Color3.fromRGB(255, 255, 255)
RangeInput.Font = Enum.Font.SourceSansBold
RangeInput.TextSize = 14
RangeInput.Parent = RangeContainer

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 4)
InputCorner.Parent = RangeInput

local DelayContainer = Instance.new("Frame")
DelayContainer.Size = UDim2.new(0, 190, 0, 35)
DelayContainer.Position = UDim2.new(0, 15, 0, 265) 
DelayContainer.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
DelayContainer.Parent = MainFrame

local DelayCorner = Instance.new("UICorner")
DelayCorner.CornerRadius = UDim.new(0, 6)
DelayCorner.Parent = DelayContainer

local DelayLabel = Instance.new("TextLabel")
DelayLabel.Size = UDim2.new(0, 110, 1, 0)
DelayLabel.Position = UDim2.new(0, 10, 0, 0)
DelayLabel.BackgroundTransparency = 1
DelayLabel.Text = "Global Delay (ms):"
DelayLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
DelayLabel.Font = Enum.Font.SourceSansBold
DelayLabel.TextSize = 14
DelayLabel.Parent = DelayContainer

local DelayInput = Instance.new("TextBox")
DelayInput.Size = UDim2.new(0, 60, 0, 25)
DelayInput.Position = UDim2.new(1, -70, 0.5, -12)
DelayInput.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
DelayInput.Text = tostring(blockDelayMs)
DelayInput.TextColor3 = Color3.fromRGB(255, 180, 0) 
DelayInput.Font = Enum.Font.SourceSansBold
DelayInput.TextSize = 14
DelayInput.Parent = DelayContainer

local DelayInputCorner = Instance.new("UICorner")
DelayInputCorner.CornerRadius = UDim.new(0, 4)
DelayInputCorner.Parent = DelayInput

local PredictContainer = Instance.new("Frame")
PredictContainer.Size = UDim2.new(0, 190, 0, 35)
PredictContainer.Position = UDim2.new(0, 15, 0, 310) 
PredictContainer.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
PredictContainer.BorderSizePixel = 0
PredictContainer.Parent = MainFrame

local PredictCorner = Instance.new("UICorner")
PredictCorner.CornerRadius = UDim.new(0, 6)
PredictCorner.Parent = PredictContainer

local PredictLabel = Instance.new("TextLabel")
PredictLabel.Size = UDim2.new(0, 110, 1, 0)
PredictLabel.Position = UDim2.new(0, 10, 0, 0)
PredictLabel.BackgroundTransparency = 1
PredictLabel.Text = "Aim Predict:"
PredictLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
PredictLabel.Font = Enum.Font.SourceSansBold
PredictLabel.TextSize = 14
PredictLabel.Parent = PredictContainer

local PredictInput = Instance.new("TextBox")
PredictInput.Size = UDim2.new(0, 60, 0, 25)
PredictInput.Position = UDim2.new(1, -70, 0.5, -12)
PredictInput.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
PredictInput.BorderSizePixel = 0
PredictInput.Text = tostring(aimPredictionFactor)
PredictInput.TextColor3 = Color3.fromRGB(0, 255, 150)
PredictInput.Font = Enum.Font.SourceSansBold
PredictInput.TextSize = 14
PredictInput.Parent = PredictContainer

local PredictInputCorner = Instance.new("UICorner")
PredictInputCorner.CornerRadius = UDim.new(0, 4)
PredictInputCorner.Parent = PredictInput

local CooldownLabel = Instance.new("TextLabel")
CooldownLabel.Size = UDim2.new(0, 190, 0, 30)
CooldownLabel.Position = UDim2.new(0, 15, 0, 360)
CooldownLabel.BackgroundTransparency = 1
CooldownLabel.Font = Enum.Font.SourceSansBold
CooldownLabel.TextSize = 14
CooldownLabel.Parent = MainFrame

for _, obj in ipairs({ToggleBtn, ToggleAimbotBtn, ToggleQRBtn, ToggleAnimModeBtn, ToggleSoundModeBtn}) do
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = obj
    obj.BorderSizePixel = 0
end

local function updateToggleBtnUI()
    ToggleBtn.BackgroundColor3 = scriptEnabled and Color3.fromRGB(46, 125, 50) or Color3.fromRGB(198, 40, 40)
    ToggleBtn.Text = scriptEnabled and "Status: MAIN ENABLED" or "Status: MAIN DISABLED"
end

local function updateAimbotBtnUI()
    ToggleAimbotBtn.BackgroundColor3 = aimbotEnabled and Color3.fromRGB(46, 125, 50) or Color3.fromRGB(198, 40, 40)
    ToggleAimbotBtn.Text = aimbotEnabled and "R-Aimbot: ON" or "R-Aimbot: OFF"
end

local function updateQRBtnUI()
    ToggleQRBtn.BackgroundColor3 = qrDelayEnabled and Color3.fromRGB(46, 125, 50) or Color3.fromRGB(198, 40, 40)
    ToggleQRBtn.Text = qrDelayEnabled and "Auto R after Q: ON" or "Auto R after Q: OFF"
end

local function updateAnimBtnUI()
    ToggleAnimModeBtn.BackgroundColor3 = animDetectionEnabled and Color3.fromRGB(0, 120, 200) or Color3.fromRGB(70, 70, 70)
    ToggleAnimModeBtn.Text = animDetectionEnabled and "Anims: ACTIVE" or "Anims: OFF"
end

local function updateSoundBtnUI()
    ToggleSoundModeBtn.BackgroundColor3 = soundDetectionEnabled and Color3.fromRGB(120, 0, 200) or Color3.fromRGB(70, 70, 70)
    ToggleSoundModeBtn.Text = soundDetectionEnabled and "Sounds: ACTIVE" or "Sounds: OFF"
end

local function updateCooldownUI()
    task.spawn(function()
        while isGlideOnCooldown do
            local remaining = math.max(0, math.ceil(GLIDE_COOLDOWN_TIME - (tick() - lastGlideTime)))
            if remaining > 0 then
                CooldownLabel.Text = "Glide CD: " .. tostring(remaining) .. "s"
                CooldownLabel.TextColor3 = Color3.fromRGB(229, 57, 53)
            else 
                break 
            end
            task.wait(0.2)
        end
        CooldownLabel.Text = "Glide: READY"
        CooldownLabel.TextColor3 = Color3.fromRGB(76, 175, 80)
    end)
end

-- Функция динамического обновления размера всех аур при изменении Range
local function updateAurasRadius()
    for _, circle in pairs(auras) do
        if circle and circle.Parent then
            circle.Size = Vector3.new(0.05, detectionRange * 2, detectionRange * 2)
        end
    end
end

updateToggleBtnUI()
updateAimbotBtnUI()
updateQRBtnUI()
updateAnimBtnUI()
updateSoundBtnUI()
CooldownLabel.Text = "Glide: READY"
CooldownLabel.TextColor3 = Color3.fromRGB(76, 175, 80)

ToggleBtn.MouseButton1Click:Connect(function() scriptEnabled = not scriptEnabled updateToggleBtnUI() end)
ToggleAimbotBtn.MouseButton1Click:Connect(function() aimbotEnabled = not aimbotEnabled updateAimbotBtnUI() if not aimbotEnabled then aimbotEndTime = 0 end end)
ToggleQRBtn.MouseButton1Click:Connect(function() qrDelayEnabled = not qrDelayEnabled updateQRBtnUI() end)
ToggleAnimModeBtn.MouseButton1Click:Connect(function() animDetectionEnabled = not animDetectionEnabled updateAnimBtnUI() end)
ToggleSoundModeBtn.MouseButton1Click:Connect(function() soundDetectionEnabled = not soundDetectionEnabled updateSoundBtnUI() end)

RangeInput.FocusLost:Connect(function()
    local newRange = tonumber(RangeInput.Text)
    if newRange and newRange >= 0 then 
        detectionRange = newRange 
        updateAurasRadius() -- Моментально меняем радиус кругов на лету
    else 
        RangeInput.Text = tostring(detectionRange) 
    end
end)

DelayInput.FocusLost:Connect(function()
    local newDelay = tonumber(DelayInput.Text)
    if newDelay then
        if newDelay < 0 then newDelay = 0 end
        if newDelay > 250 then newDelay = 250 end
        blockDelayMs = newDelay
    end
    DelayInput.Text = tostring(blockDelayMs)
end)

PredictInput.FocusLost:Connect(function()
    local newPredict = tonumber(PredictInput.Text)
    if newPredict and newPredict >= 0 then aimPredictionFactor = newPredict else PredictInput.Text = tostring(aimPredictionFactor) end
end)

local function freezeMovement() return Enum.ContextActionResult.Sink end

local function getClosestEnemy()
    local myChar = localPlayer.Character
    if not myChar then return nil end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    
    local closestEnemy = nil
    local shortestDistance = math.huge
    local workspacePlayers = workspace:FindFirstChild("Players")
    local killerFolder = workspacePlayers and workspacePlayers:FindFirstChild("Killers")
    
    if killerFolder then
        for _, killer in ipairs(killerFolder:GetChildren()) do
            local erp = killer:FindFirstChild("HumanoidRootPart")
            local hum = killer:FindFirstChildOfClass("Humanoid")
            if erp and (not hum or hum.Health > 0) then
                local dist = (erp.Position - myRoot.Position).Magnitude
                if dist < shortestDistance and dist <= detectionRange then
                    shortestDistance = dist
                    closestEnemy = erp
                end
            end
        end
    end
    return closestEnemy
end

local function aimAtTarget(targetRoot)
    local myRoot = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if myRoot and targetRoot then
        local targetVelocity = targetRoot.Velocity
        local predictedPos = targetRoot.Position + (targetVelocity * aimPredictionFactor)
        local targetPos = Vector3.new(predictedPos.X, myRoot.Position.Y, predictedPos.Z)
        myRoot.CFrame = CFrame.new(myRoot.Position, targetPos)
    end
end
local function walkToTarget(targetRoot)
    local myChar = localPlayer.Character
    if not myChar or not targetRoot then return end
    local myHumanoid = myChar:FindFirstChildOfClass("Humanoid")
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myHumanoid or not myRoot then return end
    
    local targetVelocity = targetRoot.Velocity
    local predictedTargetPos = targetRoot.Position + (targetVelocity * aimPredictionFactor)
    local direction = (predictedTargetPos - myRoot.Position).Unit
    local distance = (predictedTargetPos - myRoot.Position).Magnitude
    if distance <= STOP_DISTANCE then return end
    
    isGlideOnCooldown = true
    lastGlideTime = tick()
    updateCooldownUI()
    
    if blockDelayMs > 0 then
        task.wait(blockDelayMs / 1000)
    end
    
    if not targetRoot or not targetRoot.Parent then return end
    local freshPredictedPos = targetRoot.Position + (targetRoot.Velocity * aimPredictionFactor)
    local targetPosition = freshPredictedPos - (direction * STOP_DISTANCE)
    aimAtTarget(targetRoot)
    
    pcall(function()
        ContextActionService:BindActionAtPriority(
            FREEZE_ACTION_NAME, freezeMovement, false, Enum.ContextActionPriority.High.Value,
            Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D,
            Enum.KeyCode.Up, Enum.KeyCode.Down, Enum.KeyCode.Left, Enum.KeyCode.Right
        )
    end)
    
    isMovingToTarget = true
    myHumanoid:MoveTo(targetPosition)
    
    local function stopGlideAndReturnControl()
        if isMovingToTarget then
            isMovingToTarget = false
            if glideSoundConnection then
                glideSoundConnection:Disconnect()
                glideSoundConnection = nil
            end
            pcall(function() ContextActionService:UnbindAction(FREEZE_ACTION_NAME) end)
            myHumanoid:Move(Vector3.new(0, 0, 0))
        end
    end
    
    glideSoundConnection = game.Workspace.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("Sound") then
            local id = string.match(descendant.SoundId, "%d+")
            if id and GLIDE_TRIGGERS[id] then
                stopGlideAndReturnControl() 
            end
        end
    end)
    
    task.delay(0.4, function()
        if isMovingToTarget then
            stopGlideAndReturnControl()
        end
    end)
    task.delay(GLIDE_COOLDOWN_TIME, function() isGlideOnCooldown = false end)
end

local function instantBlock()
    if blockCooldown then return end
    blockCooldown = true
    if blockDelayMs > 0 then task.wait(blockDelayMs / 1000) end
    pcall(function()
        VIM:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
        VIM:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
    end)
    task.wait(0.2)
    blockCooldown = false
end

local function checkAnimations(char)
    if not scriptEnabled or not animDetectionEnabled or blockCooldown then return end
    local enemyRoot = char:FindFirstChild("HumanoidRootPart")
    local enemyHum = char:FindFirstChildOfClass("Humanoid")
    local myRoot = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if enemyRoot and enemyHum and myRoot then
        if (enemyRoot.Position - myRoot.Position).Magnitude <= detectionRange then
            local animator = enemyHum:FindFirstChildOfClass("Animator")
            if animator then
                local success, tracks = pcall(function() return animator:GetPlayingAnimationTracks() end)
                tracks = success and tracks or {}
                for _, track in ipairs(tracks) do
                    if track and track.Animation then
                        local id = string.match(track.Animation.AnimationId, "%d+")
                        if id and animationIds[id] then
                            task.spawn(instantBlock)
                            break
                        end
                    end
                end
            end
        end
    end
end
local function checkSound(sound, killerModel)
    if not scriptEnabled or not soundDetectionEnabled or blockCooldown then return end
    if not sound or not sound:IsA("Sound") then return end
    local soundId = sound.SoundId
    if not soundId or soundId == "" then return end
    
    pcall(function()
        local enemyRoot = killerModel:FindFirstChild("HumanoidRootPart")
        local myChar = localPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        
        if enemyRoot and myRoot then
            if (enemyRoot.Position - myRoot.Position).Magnitude <= detectionRange then
                local id = string.match(soundId, "%d+")
                if id and soundIds[id] then
                    task.spawn(instantBlock)
                end
            end
        end
    end)
end

local function trackKillerSounds(killer)
    if not killer or not killer:IsA("Model") then return end
    for _, descendant in ipairs(killer:GetDescendants()) do
        if descendant:IsA("Sound") then
            if descendant.IsPlaying then task.spawn(checkSound, descendant, killer) end
            descendant:GetPropertyChangedSignal("IsPlaying"):Connect(function()
                if descendant.IsPlaying then task.spawn(checkSound, descendant, killer) end
            end)
        end
    end
    killer.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("Sound") then
            task.wait()
            if not descendant or not descendant.Parent then return end
            if descendant.IsPlaying then task.spawn(checkSound, descendant, killer) end
            descendant:GetPropertyChangedSignal("IsPlaying"):Connect(function()
                if descendant.IsPlaying then task.spawn(checkSound, descendant, killer) end
            end)
        end
    end)
end

-- ЛОГИКА ЦИЛИНДРИЧЕСКИХ АУР ДЛЯ УБИЙЦ
local function createAura(model)
    local hrp = model:WaitForChild("HumanoidRootPart", 5)
    if not hrp or auras[model] then return end

    local circle = Instance.new("Part")
    circle.Name = model.Name .. "_Aura"
    circle.Shape = Enum.PartType.Cylinder
    circle.Size = Vector3.new(0.05, detectionRange * 2, detectionRange * 2) 
    circle.Material = Enum.Material.SmoothPlastic
    circle.Color = Color3.fromRGB(255, 0, 0) 
    circle.Transparency = 0.8
    circle.Anchored = true
    circle.CanCollide = false
    circle.CanQuery = false
    circle.CanTouch = false
    circle.Orientation = Vector3.new(0, 0, 90)
    circle.Parent = workspace
    auras[model] = circle
end

local function removeAura(model)
    if auras[model] then
        auras[model]:Destroy()
        auras[model] = nil
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.V then MainFrame.Visible = not MainFrame.Visible return end
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.B then scriptEnabled = not scriptEnabled updateToggleBtnUI() return end
    
    if input.KeyCode == Enum.KeyCode.Q and scriptEnabled and not isGlideOnCooldown then
        local target = getClosestEnemy()
        if target then task.spawn(walkToTarget, target) end
        if qrDelayEnabled then
            task.spawn(function()
                task.wait(0.18 + (blockDelayMs / 1000))
                if scriptEnabled and qrDelayEnabled then
                    pcall(function()
                        VIM:SendKeyEvent(true, Enum.KeyCode.R, false, game)
                        VIM:SendKeyEvent(false, Enum.KeyCode.R, false, game)
                    end)
                end
            end)
        end
    end
    if input.KeyCode == Enum.KeyCode.R and scriptEnabled and aimbotEnabled then aimbotEndTime = tick() + 0.8 end
end)

local workspacePlayers = workspace:WaitForChild("Players", 5)
local killerFolder = workspacePlayers and workspacePlayers:WaitForChild("Killers", 5)
if killerFolder then
    for _, killer in ipairs(killerFolder:GetChildren()) do 
        task.spawn(trackKillerSounds, killer)
        task.spawn(createAura, killer)
    end
    killerFolder.ChildAdded:Connect(function(killer) 
        task.spawn(trackKillerSounds, killer)
        task.spawn(createAura, killer)
    end)
    killerFolder.ChildRemoved:Connect(removeAura)
end

RunService.Heartbeat:Connect(function()
    if not scriptEnabled then return end
    if aimbotEnabled and tick() < aimbotEndTime then
        local target = getClosestEnemy()
        if target then aimAtTarget(target) end
    end
    if animDetectionEnabled and killerFolder then
        for _, killer in ipairs(killerFolder:GetChildren()) do checkAnimations(killer) end
    end
end)

RunService.RenderStepped:Connect(function()
    for model, circle in pairs(auras) do
        if model and model:FindFirstChild("HumanoidRootPart") then
            circle.Position = model.HumanoidRootPart.Position - Vector3.new(0, 2.9, 0)
        else
            removeAura(model)
        end
    end
end)

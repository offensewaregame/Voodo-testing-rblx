--[[  Voodo TROLL PRO 2026  |  PART 1/4 — Paste all 4 parts in order  ]]

local ok, Rayfield = pcall(function()
    return loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
end)
if not ok then warn("[Voodo] Rayfield failed: " .. tostring(Rayfield)) return end

local Window = Rayfield:CreateWindow({
    Name                = "Voodo TROLL PRO 2026",
    LoadingTitle        = "Voodo",
    LoadingSubtitle     = "Universal Edition",
    ConfigurationSaving = { Enabled = false },
    KeySystem           = false,
})

-- Services
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris            = game:GetService("Debris")
local LP                = Players.LocalPlayer

-- State
local S = {
    AntiAFK    = false,
    ChatSpam   = false, ChatMsg   = "Voodo owns you 😂", ChatDelay = 1.5,
    AnimSpam   = false, AnimChoice= "Default Dance",
    TargetName = "",
    WalkSpeed  = 16,   JumpPower  = 50,
    Fly        = false, Noclip    = false, Invisible = false, GodMode = false,
    Follow     = false, BackTroll = false,
}

-- Helpers
local function GetChar()     return LP.Character end
local function GetRoot()     local c=GetChar() return c and c:FindFirstChild("HumanoidRootPart") end
local function GetHum()      local c=GetChar() return c and c:FindFirstChildOfClass("Humanoid") end
local function GetAnimator() local h=GetHum()  return h and h:FindFirstChildOfClass("Animator") end
local function GetTarget()   return Players:FindFirstChild(S.TargetName) end

local function Notify(t,m,d) pcall(function() Rayfield:Notify({Title=t,Content=m,Duration=d or 3}) end) end
local function SafeDestroy(o)    if o and o.Parent then pcall(function() o:Destroy() end) end end
local function SafeDisconnect(c) if c then pcall(function() c:Disconnect() end) end end

-- Anti-AFK
local afkConn, afkPara, afkNext = nil, nil, 0

local function StopAntiAFK()
    SafeDisconnect(afkConn); afkConn = nil
    pcall(function() afkPara:Set("Anti-AFK","❌ Disabled") end)
end

local function StartAntiAFK()
    if afkConn then return end
    afkNext = tick() + math.random(20,35)
    afkConn = RunService.Heartbeat:Connect(function()
        if not S.AntiAFK then return end
        if tick() >= afkNext then
            pcall(function()
                local r,h = GetRoot(), GetHum()
                if r then r.CFrame = r.CFrame * CFrame.new(0,0,0.1) end
                if h then h.Jump = true end
            end)
            afkNext = tick() + math.random(20,35)
        end
        pcall(function()
            afkPara:Set("Anti-AFK","✅ Active | Next in "..math.max(0,math.floor(afkNext-tick())).."s")
        end)
    end)
end

-- Fly
local flyConn, flyBV, flyBG = nil, nil, nil

local function StopFly()
    SafeDisconnect(flyConn); flyConn=nil
    SafeDestroy(flyBV);      flyBV=nil
    SafeDestroy(flyBG);      flyBG=nil
end

local function StartFly()
    StopFly()
    local root = GetRoot()
    if not root then Notify("Fly","No character!",2) return end
    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(1e9,1e9,1e9)
    flyBV.Velocity = Vector3.zero
    flyBV.Parent   = root
    flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque = Vector3.new(1e9,1e9,1e9)
    flyBG.P = 2e4; flyBG.D = 1e2
    flyBG.CFrame = root.CFrame
    flyBG.Parent = root
    flyConn = RunService.Heartbeat:Connect(function()
        if not S.Fly then StopFly() return end
        local r = GetRoot(); if not r then return end
        local cam = workspace.CurrentCamera
        local d   = Vector3.zero
        local ui  = UserInputService
        if ui:IsKeyDown(Enum.KeyCode.W)           then d += cam.CFrame.LookVector  end
        if ui:IsKeyDown(Enum.KeyCode.S)           then d -= cam.CFrame.LookVector  end
        if ui:IsKeyDown(Enum.KeyCode.A)           then d -= cam.CFrame.RightVector end
        if ui:IsKeyDown(Enum.KeyCode.D)           then d += cam.CFrame.RightVector end
        if ui:IsKeyDown(Enum.KeyCode.Space)       then d += Vector3.yAxis          end
        if ui:IsKeyDown(Enum.KeyCode.LeftControl) then d -= Vector3.yAxis          end
        local spd = ui:IsKeyDown(Enum.KeyCode.LeftShift) and 160 or 80
        flyBV.Velocity = (d.Magnitude > 0) and (d.Unit * spd) or Vector3.zero
        flyBG.CFrame   = cam.CFrame
    end)
end

local function ToggleFly(v)
    S.Fly = v
    if v then StartFly() else StopFly() end
end

--[[  Voodo TROLL PRO 2026  |  PART 2/4  ]]

-- Noclip
local noclipConn = nil
local function ToggleNoclip(v)
    S.Noclip = v
    SafeDisconnect(noclipConn); noclipConn = nil
    if not v then return end
    noclipConn = RunService.Stepped:Connect(function()
        local c = GetChar(); if not c then return end
        for _,p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end)
end

-- Invisible
local function ToggleInvisible(v)
    S.Invisible = v
    local c = GetChar(); if not c then return end
    for _,obj in ipairs(c:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name ~= "HumanoidRootPart" then
            obj.Transparency = v and 1 or 0
        end
        if obj:IsA("Decal") then obj.Transparency = v and 1 or 0 end
    end
    for _,acc in ipairs(c:GetChildren()) do
        if acc:IsA("Accessory") then
            local h = acc:FindFirstChild("Handle")
            if h then h.Transparency = v and 1 or 0 end
        end
    end
end

-- God Mode
local godConn = nil
local function ToggleGodMode(v)
    S.GodMode = v
    SafeDisconnect(godConn); godConn = nil
    if not v then return end
    godConn = RunService.Heartbeat:Connect(function()
        local h = GetHum(); if h then h.Health = h.MaxHealth end
    end)
end

-- Chat Spam
local chatThread = nil

local function TrySendChat(msg)
    local tcs = game:GetService("TextChatService")
    if tcs.ChatVersion == Enum.ChatVersion.TextChatService then
        local ch = tcs.TextChannels:FindFirstChild("RBXGeneral")
        if ch then ch:SendAsync(msg) return end
    end
    local ns = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents", true)
    if ns then
        local req = ns:FindFirstChild("SayMessageRequest")
        if req then req:FireServer(msg,"All") end
    end
end

local function StopChatSpam()
    if chatThread then pcall(task.cancel, chatThread); chatThread = nil end
end

local function StartChatSpam()
    StopChatSpam()
    chatThread = task.spawn(function()
        while S.ChatSpam do
            pcall(TrySendChat, S.ChatMsg)
            task.wait(math.max(0.3, S.ChatDelay))
        end
        chatThread = nil
    end)
end

-- Animation Spam
local animThread, currentTrack = nil, nil
local ANIMS = {
    ["Default Dance"]="rbxassetid://5918726674", ["Floss"]="rbxassetid://5915779486",
    ["T-Pose"]="rbxassetid://4820752821",        ["Dab"]="rbxassetid://2482632603",
    ["Carlton"]="rbxassetid://3496398788",        ["Cartwheel"]="rbxassetid://3333331313",
    ["Head Spin"]="rbxassetid://3361481910",      ["Superman"]="rbxassetid://616111295",
    ["Twerk"]="rbxassetid://3696208751",          ["Robot"]="rbxassetid://4841196285",
    ["Samba"]="rbxassetid://2502050891",          ["Breakdance"]="rbxassetid://3361186483",
}

local function StopAnim()
    if currentTrack then pcall(function() currentTrack:Stop() end); currentTrack=nil end
end

local function StartAnimSpam()
    if animThread then return end
    animThread = task.spawn(function()
        while S.AnimSpam do
            pcall(function()
                local animator = GetAnimator()
                if animator then
                    StopAnim()
                    local anim = Instance.new("Animation")
                    anim.AnimationId = ANIMS[S.AnimChoice] or "rbxassetid://5918726674"
                    currentTrack = animator:LoadAnimation(anim)
                    currentTrack:Play()
                end
            end)
            task.wait(1.3)
        end
        animThread = nil
    end)
end

-- Fling
local function Fling(player)
    if not player or not player.Character then Notify("Fling","No character",2) return end
    local root = player.Character:FindFirstChild("HumanoidRootPart"); if not root then return end
    for _,v in ipairs(root:GetChildren()) do
        if v:IsA("BodyVelocity") or v:IsA("BodyForce") then v:Destroy() end
    end
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e9,1e9,1e9)
    bv.Velocity = Vector3.new(math.random(-600,600), math.random(400,700), math.random(-600,600))
    bv.Parent   = root
    Debris:AddItem(bv, 0.35)
    Notify("Fling 💥", player.Name.." yeeted!", 2)
end

local function FlingNearest()
    local r = GetRoot(); if not r then return end
    local best, bd = nil, math.huge
    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local pr = p.Character:FindFirstChild("HumanoidRootPart")
            if pr then local d=(pr.Position-r.Position).Magnitude if d<bd then bd=d; best=p end end
        end
    end
    if best then Fling(best) else Notify("Fling","No one nearby",2) end
end

local function FlingAll()
    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= LP then task.delay(0, function() Fling(p) end) end
    end
end

-- Attach Trolls
local attachConn = nil
local OFFSETS = {
    Headsit   = CFrame.new(0,3.5,0)  * CFrame.Angles(0,0,math.rad(180)),
    Stand     = CFrame.new(3.5,0,0),
    BackTroll = CFrame.new(0,0,2.5)  * CFrame.Angles(0,math.pi,0),
    Follow    = CFrame.new(0,0,5),
    Bang      = CFrame.new(0,-1,2)   * CFrame.Angles(math.rad(-90),0,0),
}

local function StopAttach()
    SafeDisconnect(attachConn); attachConn = nil
end

local function StartAttach(mode)
    StopAttach()
    local off = OFFSETS[mode]; if not off then return end
    attachConn = RunService.Heartbeat:Connect(function()
        pcall(function()
            local t = GetTarget(); if not (t and t.Character) then return end
            local mr = GetRoot()
            local tr = t.Character:FindFirstChild("HumanoidRootPart")
            if mr and tr then mr.CFrame = tr.CFrame * off end
        end)
    end)
end

-- Render loop + Unload
RunService:BindToRenderStep("VoodoMain", Enum.RenderPriority.Camera.Value+10, function()
    pcall(function()
        local h = GetHum(); if not h then return end
        h.WalkSpeed = S.WalkSpeed; h.JumpPower = S.JumpPower
    end)
end)

local function UnloadAll()
    S.AntiAFK=false; S.ChatSpam=false; S.AnimSpam=false
    S.Follow=false; S.BackTroll=false
    S.Fly=false; S.Noclip=false; S.Invisible=false; S.GodMode=false
    StopAntiAFK(); StopChatSpam(); StopAnim(); StopAttach()
    StopFly(); ToggleNoclip(false); ToggleInvisible(false); ToggleGodMode(false)
    pcall(function() RunService:UnbindFromRenderStep("VoodoMain") end)
    Notify("Voodo","✅ Fully unloaded!",4)
end

--[[  Voodo TROLL PRO 2026  |  PART 3/4  ]]

local TabMain  = Window:CreateTab("Main",     "")
local TabTroll = Window:CreateTab("Troll",    "")
local TabMove  = Window:CreateTab("Movement", "")

-- ── MAIN TAB ──────────────────────────────────────────
pcall(function()
    TabMain:CreateSection("Anti-AFK")
    TabMain:CreateToggle({
        Name="Anti-AFK", CurrentValue=false, Flag="t_antiafk",
        Callback=function(v) S.AntiAFK=v if v then StartAntiAFK() else StopAntiAFK() end end
    })
    afkPara = TabMain:CreateParagraph({ Title="Anti-AFK", Content="❌ Disabled" })
end)

pcall(function()
    TabMain:CreateSection("Info & Utils")
    TabMain:CreateButton({ Name="List All Players", Callback=function()
        local t={} for _,p in ipairs(Players:GetPlayers()) do table.insert(t,p.Name) end
        Notify("Players ("..#t..")", table.concat(t," | "), 8)
    end})
    TabMain:CreateButton({ Name="Respawn Character", Callback=function() LP:LoadCharacter() end })
    TabMain:CreateButton({ Name="Rejoin Game", Callback=function()
        pcall(function() game:GetService("TeleportService"):Teleport(game.PlaceId, LP) end)
    end})
end)

-- ── TROLL TAB ─────────────────────────────────────────
pcall(function()
    TabTroll:CreateSection("Chat Spammer")
    TabTroll:CreateToggle({
        Name="Chat Spammer", CurrentValue=false, Flag="t_chatspam",
        Callback=function(v) S.ChatSpam=v if v then StartChatSpam() else StopChatSpam() end end
    })
    TabTroll:CreateInput({
        Name="Spam Message", PlaceholderText="Enter message...",
        RemoveTextAfterFocusLost=false, Flag="t_chatmsg",
        Callback=function(v) if v~="" then S.ChatMsg=v end end
    })
    TabTroll:CreateSlider({
        Name="Spam Delay (s)", Range={0.3,8}, Increment=0.1, CurrentValue=1.5, Flag="t_chatdelay",
        Callback=function(v) S.ChatDelay=v end
    })
end)

pcall(function()
    TabTroll:CreateSection("Animation Spam")
    TabTroll:CreateDropdown({
        Name="Pick Animation", Flag="t_animchoice",
        Options={"Default Dance","Floss","T-Pose","Dab","Carlton",
                 "Cartwheel","Head Spin","Superman","Twerk","Robot","Samba","Breakdance"},
        CurrentOption={"Default Dance"},   -- TABLE, not string!
        Callback=function(v) S.AnimChoice=(type(v)=="table") and v[1] or v end
    })
    TabTroll:CreateToggle({
        Name="Spam Animation", CurrentValue=false, Flag="t_animspam",
        Callback=function(v) S.AnimSpam=v if v then StartAnimSpam() else StopAnim() end end
    })
end)

pcall(function()
    TabTroll:CreateSection("Fling")
    TabTroll:CreateButton({ Name="Fling Nearest", Callback=FlingNearest })
    TabTroll:CreateButton({ Name="Fling ALL Players", Callback=FlingAll })
    TabTroll:CreateButton({ Name="Self Fling", Callback=function() Fling(LP) end })
end)

pcall(function()
    TabTroll:CreateSection("Target Trolling  (enter username below)")
    TabTroll:CreateInput({
        Name="Target Username", PlaceholderText="Exact username",
        RemoveTextAfterFocusLost=false, Flag="t_target",
        Callback=function(v) S.TargetName=v end
    })
    TabTroll:CreateButton({ Name="Fling Target",   Callback=function() Fling(GetTarget()) end })
    TabTroll:CreateToggle({
        Name="Follow Target", CurrentValue=false, Flag="t_follow",
        Callback=function(v) S.Follow=v if v then StartAttach("Follow") else StopAttach() end end
    })
    TabTroll:CreateToggle({
        Name="Back Troll", CurrentValue=false, Flag="t_backtroll",
        Callback=function(v) S.BackTroll=v if v then StartAttach("BackTroll") else StopAttach() end end
    })
    TabTroll:CreateButton({ Name="Headsit on Target", Callback=function() S.Follow=true StartAttach("Headsit") end })
    TabTroll:CreateButton({ Name="Stand on Target",   Callback=function() S.Follow=true StartAttach("Stand")   end })
    TabTroll:CreateButton({ Name="Bang Target",       Callback=function() S.Follow=true StartAttach("Bang")    end })
    TabTroll:CreateButton({ Name="Stop Attach",       Callback=function() S.Follow=false S.BackTroll=false StopAttach() end })
end)

--[[  Voodo TROLL PRO 2026  |  PART 4/4  ]]

-- ── MOVEMENT TAB ──────────────────────────────────────
pcall(function()
    TabMove:CreateSection("Speed & Jump")
    TabMove:CreateSlider({
        Name="Walk Speed", Range={16,300}, Increment=1, CurrentValue=16, Flag="m_walkspeed",
        Callback=function(v) S.WalkSpeed=v end
    })
    TabMove:CreateSlider({
        Name="Jump Power", Range={50,500}, Increment=5, CurrentValue=50, Flag="m_jumppower",
        Callback=function(v) S.JumpPower=v end
    })
    TabMove:CreateButton({ Name="Reset Speed & Jump", Callback=function()
        S.WalkSpeed=16; S.JumpPower=50
        Notify("Movement","Reset to defaults",2)
    end})
end)

pcall(function()
    TabMove:CreateSection("Abilities")
    TabMove:CreateToggle({
        Name="Fly  (WASD + Space/Ctrl | Shift = fast)", CurrentValue=false, Flag="m_fly",
        Callback=ToggleFly
    })
    TabMove:CreateToggle({
        Name="Noclip", CurrentValue=false, Flag="m_noclip",
        Callback=ToggleNoclip
    })
    TabMove:CreateToggle({
        Name="Invisible", CurrentValue=false, Flag="m_invisible",
        Callback=ToggleInvisible
    })
    TabMove:CreateToggle({
        Name="God Mode  (infinite health)", CurrentValue=false, Flag="m_godmode",
        Callback=ToggleGodMode
    })
end)

pcall(function()
    TabMove:CreateSection("Teleport")
    TabMove:CreateButton({ Name="Teleport to Target", Callback=function()
        local t=GetTarget()
        if not (t and t.Character) then Notify("TP","Target not found",2) return end
        local tr = t.Character:FindFirstChild("HumanoidRootPart")
        local mr = GetRoot()
        if tr and mr then mr.CFrame = tr.CFrame * CFrame.new(0,0,3) end
    end})
    TabMove:CreateButton({ Name="Bring Target to Me", Callback=function()
        local t=GetTarget()
        if not (t and t.Character) then Notify("Bring","Target not found",2) return end
        local tr = t.Character:FindFirstChild("HumanoidRootPart")
        local mr = GetRoot()
        if tr and mr then tr.CFrame = mr.CFrame * CFrame.new(2,0,2) end
    end})
    TabMove:CreateButton({ Name="Teleport to Spawn", Callback=function()
        local sp = workspace:FindFirstChild("SpawnLocation")
        local r  = GetRoot()
        if sp and r then r.CFrame = sp.CFrame + Vector3.new(0,5,0)
        else Notify("TP","No spawn found",2) end
    end})
end)

pcall(function()
    TabMove:CreateSection("Misc")
    TabMove:CreateButton({ Name="Kill Character", Callback=function()
        local h=GetHum(); if h then h.Health=0 end
    end})
    TabMove:CreateButton({ Name="⛔  UNLOAD EVERYTHING", Callback=UnloadAll })
end)

-- ─────────────────────────────────────────────────────
Notify("Voodo TROLL PRO 2026","✅ All tabs loaded!\nSet Target Username for attach/TP features.",7)
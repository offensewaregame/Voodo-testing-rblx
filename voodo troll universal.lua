--[[ Voodo TROLL PRO 2026 — Full Rewrite | Part 1/4 ]]

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name                = "Voodo TROLL PRO 2026",
    LoadingTitle        = "Voodo",
    LoadingSubtitle     = "by offenseware",
    ConfigurationSaving = { Enabled = false },
    KeySystem           = false,
})

-- Services
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local RepStorage       = game:GetService("ReplicatedStorage")
local Debris           = game:GetService("Debris")
local LP               = Players.LocalPlayer

-- State
local S = {
    AntiAFK=false, ChatSpam=false, ChatMsg="Voodo owns u 😂", ChatDelay=1.5,
    AnimSpam=false, AnimPick="Default Dance",
    Target="", WalkSpeed=16, JumpPower=50,
    Fly=false, Noclip=false, Invis=false, GodMode=false,
    InfJump=false, Follow=false, BackTroll=false,
    ESP=false,
}

-- Helpers
local function C()    return LP.Character end
local function Root() local c=C() return c and c:FindFirstChild("HumanoidRootPart") end
local function Hum()  local c=C() return c and c:FindFirstChildOfClass("Humanoid") end
local function Anim() local h=Hum() return h and h:FindFirstChildOfClass("Animator") end
local function Tgt()  return Players:FindFirstChild(S.Target) end
local function Kill(c) if c then pcall(function() c:Disconnect() end) end end
local function Del(o)  if o and o.Parent then pcall(function() o:Destroy() end) end end
local function N(t,m,d) pcall(function() Rayfield:Notify({Title=t,Content=m,Duration=d or 3}) end) end

-- ── ANTI-AFK ─────────────────────────────────────────────
local afkConn, afkNext = nil, 0
local function StartAFK()
    if afkConn then return end
    afkNext = tick() + math.random(20,35)
    afkConn = RunService.Heartbeat:Connect(function()
        if not S.AntiAFK then return end
        if tick() >= afkNext then
            pcall(function()
                local r,h = Root(), Hum()
                if r then r.CFrame = r.CFrame*CFrame.new(0,0,0.1) end
                if h then h.Jump = true end
            end)
            afkNext = tick() + math.random(20,35)
            N("Anti-AFK","✅ Kicked! Next in "..math.random(20,35).."s",2)
        end
    end)
end
local function StopAFK() Kill(afkConn); afkConn=nil end

-- ── FLY ──────────────────────────────────────────────────
local flyConn, flyBV, flyBG = nil,nil,nil
local function StopFly()
    Kill(flyConn); flyConn=nil; Del(flyBV); flyBV=nil; Del(flyBG); flyBG=nil
end
local function StartFly()
    StopFly()
    local r = Root(); if not r then return end
    flyBV=Instance.new("BodyVelocity"); flyBV.MaxForce=Vector3.new(1e9,1e9,1e9); flyBV.Velocity=Vector3.zero; flyBV.Parent=r
    flyBG=Instance.new("BodyGyro"); flyBG.MaxTorque=Vector3.new(1e9,1e9,1e9); flyBG.P=2e4; flyBG.CFrame=r.CFrame; flyBG.Parent=r
    flyConn=RunService.Heartbeat:Connect(function()
        if not S.Fly then StopFly() return end
        local rt=Root(); if not rt then return end
        local cam=workspace.CurrentCamera; local d=Vector3.zero; local ui=UserInputService
        if ui:IsKeyDown(Enum.KeyCode.W) then d+=cam.CFrame.LookVector end
        if ui:IsKeyDown(Enum.KeyCode.S) then d-=cam.CFrame.LookVector end
        if ui:IsKeyDown(Enum.KeyCode.A) then d-=cam.CFrame.RightVector end
        if ui:IsKeyDown(Enum.KeyCode.D) then d+=cam.CFrame.RightVector end
        if ui:IsKeyDown(Enum.KeyCode.Space) then d+=Vector3.yAxis end
        if ui:IsKeyDown(Enum.KeyCode.LeftControl) then d-=Vector3.yAxis end
        local spd = ui:IsKeyDown(Enum.KeyCode.LeftShift) and 180 or 80
        flyBV.Velocity=(d.Magnitude>0) and d.Unit*spd or Vector3.zero
        flyBG.CFrame=cam.CFrame
    end)
end
local function ToggleFly(v) S.Fly=v; if v then StartFly() else StopFly() end end

-- ── NOCLIP ───────────────────────────────────────────────
local ncConn=nil
local function ToggleNC(v)
    S.Noclip=v; Kill(ncConn); ncConn=nil
    if not v then return end
    ncConn=RunService.Stepped:Connect(function()
        local c=C(); if not c then return end
        for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end
    end)
end

-- ── INVISIBLE ────────────────────────────────────────────
local function ToggleInvis(v)
    S.Invis=v; local c=C(); if not c then return end
    for _,o in ipairs(c:GetDescendants()) do
        if o:IsA("BasePart") and o.Name~="HumanoidRootPart" then o.Transparency=v and 1 or 0 end
        if o:IsA("Decal") then o.Transparency=v and 1 or 0 end
    end
    for _,a in ipairs(c:GetChildren()) do
        if a:IsA("Accessory") then local h=a:FindFirstChild("Handle") if h then h.Transparency=v and 1 or 0 end end
    end
end

-- ── GOD MODE ─────────────────────────────────────────────
local godConn=nil
local function ToggleGod(v)
    S.GodMode=v; Kill(godConn); godConn=nil
    if not v then return end
    godConn=RunService.Heartbeat:Connect(function() local h=Hum() if h then h.Health=h.MaxHealth end end)
end

-- ── INFINITE JUMP ────────────────────────────────────────
local ijConn=nil
local function ToggleIJ(v)
    S.InfJump=v; Kill(ijConn); ijConn=nil
    if not v then return end
    ijConn=UserInputService.JumpRequest:Connect(function() local h=Hum() if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end)
end

-- ── RENDER LOOP (speed/jump) ─────────────────────────────
RunService:BindToRenderStep("VoodoCore",Enum.RenderPriority.Camera.Value+10,function()
    pcall(function() local h=Hum() if h then h.WalkSpeed=S.WalkSpeed; h.JumpPower=S.JumpPower end end)
end)
--[[ Voodo TROLL PRO 2026 — Full Rewrite | Part 2/4 ]]

-- ── CHAT SPAM ────────────────────────────────────────────
local chatThr=nil
local function SendChat(msg)
    pcall(function()
        local tcs=game:GetService("TextChatService")
        if tcs.ChatVersion==Enum.ChatVersion.TextChatService then
            local ch=tcs.TextChannels:FindFirstChild("RBXGeneral")
            if ch then ch:SendAsync(msg) return end
        end
    end)
    pcall(function()
        local ev=RepStorage:FindFirstChild("DefaultChatSystemChatEvents",true)
        if ev then local r=ev:FindFirstChild("SayMessageRequest") if r then r:FireServer(msg,"All") end end
    end)
end
local function StopChat() if chatThr then pcall(task.cancel,chatThr); chatThr=nil end end
local function StartChat()
    StopChat()
    chatThr=task.spawn(function()
        while S.ChatSpam do pcall(SendChat,S.ChatMsg) task.wait(math.max(0.3,S.ChatDelay)) end
        chatThr=nil
    end)
end

-- ── ANIMATION SPAM ───────────────────────────────────────
local animThr, curTrack=nil,nil
local ANIMS={
    ["Default Dance"]="rbxassetid://5918726674",["Floss"]="rbxassetid://5915779486",
    ["T-Pose"]="rbxassetid://4820752821",["Dab"]="rbxassetid://2482632603",
    ["Carlton"]="rbxassetid://3496398788",["Cartwheel"]="rbxassetid://3333331313",
    ["Head Spin"]="rbxassetid://3361481910",["Twerk"]="rbxassetid://3696208751",
    ["Robot"]="rbxassetid://4841196285",["Breakdance"]="rbxassetid://3361186483",
}
local function StopAnim() if curTrack then pcall(function() curTrack:Stop() end) curTrack=nil end end
local function StartAnim()
    if animThr then return end
    animThr=task.spawn(function()
        while S.AnimSpam do
            pcall(function()
                local an=Anim(); if not an then return end
                StopAnim()
                local a=Instance.new("Animation"); a.AnimationId=ANIMS[S.AnimPick] or "rbxassetid://5918726674"
                curTrack=an:LoadAnimation(a); curTrack:Play()
            end)
            task.wait(1.3)
        end
        animThr=nil
    end)
end

-- ── FLING ────────────────────────────────────────────────
local function Fling(plr)
    if not plr or not plr.Character then N("Fling","No character",2) return end
    local r=plr.Character:FindFirstChild("HumanoidRootPart"); if not r then return end
    for _,v in ipairs(r:GetChildren()) do if v:IsA("BodyVelocity") or v:IsA("BodyForce") then v:Destroy() end end
    local bv=Instance.new("BodyVelocity")
    bv.MaxForce=Vector3.new(1e9,1e9,1e9)
    bv.Velocity=Vector3.new(math.random(-600,600),math.random(500,800),math.random(-600,600))
    bv.Parent=r; Debris:AddItem(bv,0.3)
    N("Fling 💥",plr.Name.." yeeted!",2)
end
local function FlingNearest()
    local me=Root(); if not me then return end
    local best,bd=nil,math.huge
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP and p.Character then
            local r=p.Character:FindFirstChild("HumanoidRootPart")
            if r then local d=(r.Position-me.Position).Magnitude if d<bd then bd=d;best=p end end
        end
    end
    if best then Fling(best) else N("Fling","No one nearby",2) end
end

-- ── ATTACH / TROLL POSITIONS ─────────────────────────────
local attConn=nil
local OFFSETS={
    Follow    =CFrame.new(0,0,5),
    BackTroll =CFrame.new(0,0,2.5)*CFrame.Angles(0,math.pi,0),
    Headsit   =CFrame.new(0,3.5,0)*CFrame.Angles(0,0,math.rad(180)),
    Stand     =CFrame.new(3.5,0,0),
    Bang      =CFrame.new(0,-1,2)*CFrame.Angles(math.rad(-90),0,0),
    Front     =CFrame.new(0,0,-3),
}
local function StopAttach() Kill(attConn); attConn=nil end
local function StartAttach(mode)
    StopAttach()
    local off=OFFSETS[mode]; if not off then return end
    attConn=RunService.Heartbeat:Connect(function()
        pcall(function()
            local t=Tgt(); if not (t and t.Character) then return end
            local mr=Root(); local tr=t.Character:FindFirstChild("HumanoidRootPart")
            if mr and tr then mr.CFrame=tr.CFrame*off end
        end)
    end)
end

-- ── ESP ───────────────────────────────────────────────────
local espObjs={}
local function ClearESP()
    for _,v in pairs(espObjs) do pcall(function() v:Destroy() end) end
    espObjs={}
end
local function MakeESP(plr)
    if plr==LP then return end
    local function build()
        if not plr.Character then return end
        local root=plr.Character:FindFirstChild("HumanoidRootPart"); if not root then return end
        -- BillboardGui nametag
        local bb=Instance.new("BillboardGui")
        bb.Name="VoodoESP"; bb.AlwaysOnTop=true
        bb.Size=UDim2.new(0,120,0,40); bb.StudsOffset=Vector3.new(0,3.5,0)
        bb.Adornee=root; bb.Parent=root
        local lbl=Instance.new("TextLabel"); lbl.BackgroundTransparency=1
        lbl.Size=UDim2.new(1,0,1,0); lbl.TextColor3=Color3.fromRGB(255,80,80)
        lbl.TextStrokeTransparency=0; lbl.Font=Enum.Font.GothamBold
        lbl.TextSize=14; lbl.Text=plr.Name; lbl.Parent=bb
        -- Distance updater
        local conn=RunService.Heartbeat:Connect(function()
            if not S.ESP then bb:Destroy() return end
            local mr=Root(); if mr and root.Parent then
                local d=math.floor((root.Position-mr.Position).Magnitude)
                lbl.Text=plr.Name.." ["..d.."m]"
            end
        end)
        table.insert(espObjs,bb)
        table.insert(espObjs,{Destroy=function() Kill(conn) end})
        -- Highlight
        local hl=Instance.new("Highlight")
        hl.FillColor=Color3.fromRGB(255,0,0); hl.OutlineColor=Color3.fromRGB(255,255,255)
        hl.FillTransparency=0.6; hl.OutlineTransparency=0
        hl.Adornee=plr.Character; hl.Parent=plr.Character
        table.insert(espObjs,hl)
    end
    build()
    plr.CharacterAdded:Connect(function() task.wait(0.5) if S.ESP then build() end end)
end
local function EnableESP()
    ClearESP()
    for _,p in ipairs(Players:GetPlayers()) do MakeESP(p) end
    Players.PlayerAdded:Connect(function(p) if S.ESP then MakeESP(p) end end)
end

-- ── TELEPORT ─────────────────────────────────────────────
local function TPNearest()
    local me=Root(); if not me then return end
    local best,bd=nil,math.huge
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP and p.Character then
            local r=p.Character:FindFirstChild("HumanoidRootPart")
            if r then local d=(r.Position-me.Position).Magnitude if d<bd then bd=d;best=p end end
        end
    end
    if best then
        local tr=best.Character:FindFirstChild("HumanoidRootPart")
        if tr then me.CFrame=tr.CFrame*CFrame.new(0,0,3) N("TP","Teleported to "..best.Name,2) end
    else N("TP","No players found",2) end
end
local function TPToTarget()
    local t=Tgt(); if not (t and t.Character) then N("TP","Target not found",2) return end
    local tr=t.Character:FindFirstChild("HumanoidRootPart"); local me=Root()
    if tr and me then me.CFrame=tr.CFrame*CFrame.new(0,0,3) N("TP","Teleported to "..S.Target,2) end
end

-- ── UNLOAD ───────────────────────────────────────────────
local function Unload()
    S.AntiAFK=false;S.ChatSpam=false;S.AnimSpam=false;S.Follow=false
    S.BackTroll=false;S.Fly=false;S.Noclip=false;S.Invis=false
    S.GodMode=false;S.InfJump=false;S.ESP=false
    StopAFK();StopChat();StopAnim();StopAttach();StopFly()
    ToggleNC(false);ToggleInvis(false);ToggleGod(false);ToggleIJ(false);ClearESP()
    pcall(function() RunService:UnbindFromRenderStep("VoodoCore") end)
    N("Voodo","✅ Fully unloaded!",4)
end
--[[ Voodo TROLL PRO 2026 — Full Rewrite | Part 3/4 ]]

local TMain  = Window:CreateTab("Main",     "")
local TTroll = Window:CreateTab("Troll",    "")
local TMove  = Window:CreateTab("Movement", "")
local TESP   = Window:CreateTab("ESP",      "")

-- ══ MAIN TAB ══════════════════════════════════════════════
pcall(function()
    TMain:CreateSection("Anti-AFK")
    TMain:CreateToggle({ Name="Anti-AFK (auto jump + move)", CurrentValue=false, Flag="f_afk",
        Callback=function(v) S.AntiAFK=v; if v then StartAFK() else StopAFK() end end })
    TMain:CreateParagraph({ Title="Anti-AFK Info", Content="Keeps you active. Jumps + moves every 20-35s. Watch output for timer." })
end)

pcall(function()
    TMain:CreateSection("Utils")
    TMain:CreateButton({ Name="List Players", Callback=function()
        local t={} for _,p in ipairs(Players:GetPlayers()) do table.insert(t,p.Name.."("..math.floor((p.Character and p.Character:FindFirstChild("HumanoidRootPart") and (p.Character.HumanoidRootPart.Position-( Root() and Root().Position or Vector3.zero)).Magnitude or 0)).."m)") end
        N("Players "..#t,table.concat(t," | "),10)
    end})
    TMain:CreateButton({ Name="Rejoin", Callback=function()
        pcall(function() game:GetService("TeleportService"):Teleport(game.PlaceId,LP) end)
    end})
    TMain:CreateButton({ Name="Respawn", Callback=function() LP:LoadCharacter() end })
end)

-- ══ TROLL TAB ═════════════════════════════════════════════
pcall(function()
    TTroll:CreateSection("Chat Spammer")
    TTroll:CreateToggle({ Name="Chat Spam", CurrentValue=false, Flag="f_chat",
        Callback=function(v) S.ChatSpam=v; if v then StartChat() else StopChat() end end })
    TTroll:CreateInput({ Name="Message", PlaceholderText="Voodo owns u 😂",
        RemoveTextAfterFocusLost=false, Flag="f_chatmsg",
        Callback=function(v) if v~="" then S.ChatMsg=v end end })
    TTroll:CreateSlider({ Name="Delay (s)", Range={0.3,8}, Increment=0.1, CurrentValue=1.5, Flag="f_chatdel",
        Callback=function(v) S.ChatDelay=v end })
end)

pcall(function()
    TTroll:CreateSection("Animation Spam")
    -- CurrentOption MUST be a plain string in Rayfield
    TTroll:CreateDropdown({ Name="Animation", Flag="f_anim",
        Options={"Default Dance","Floss","T-Pose","Dab","Carlton",
                 "Cartwheel","Head Spin","Twerk","Robot","Breakdance"},
        CurrentOption="Default Dance",
        Callback=function(v) S.AnimPick=v end })
    TTroll:CreateToggle({ Name="Spam Animation", CurrentValue=false, Flag="f_animspam",
        Callback=function(v) S.AnimSpam=v; if v then StartAnim() else StopAnim() end end })
end)

pcall(function()
    TTroll:CreateSection("Fling")
    TTroll:CreateButton({ Name="Fling Nearest",     Callback=FlingNearest })
    TTroll:CreateButton({ Name="Fling ALL Players", Callback=function()
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LP then task.delay(0,function() Fling(p) end) end
        end
    end})
    TTroll:CreateButton({ Name="Self Fling",        Callback=function() Fling(LP) end })
end)

pcall(function()
    TTroll:CreateSection("Target (type username below then pick mode)")
    TTroll:CreateInput({ Name="Target Username", PlaceholderText="Exact username",
        RemoveTextAfterFocusLost=false, Flag="f_tgt",
        Callback=function(v) S.Target=v end })
    TTroll:CreateButton({ Name="Teleport to Target",  Callback=TPToTarget })
    TTroll:CreateButton({ Name="Teleport to Nearest", Callback=TPNearest })
    TTroll:CreateButton({ Name="Fling Target",        Callback=function() Fling(Tgt()) end })
    TTroll:CreateButton({ Name="Bring Target to Me",  Callback=function()
        local t=Tgt(); if not (t and t.Character) then N("Bring","Not found",2) return end
        local tr=t.Character:FindFirstChild("HumanoidRootPart"); local me=Root()
        if tr and me then tr.CFrame=me.CFrame*CFrame.new(2,0,2) end
    end})
end)

pcall(function()
    TTroll:CreateSection("Attach Modes (needs Target)")
    TTroll:CreateButton({ Name="🍑 Back Troll",       Callback=function() S.Follow=true S.BackTroll=true StartAttach("BackTroll") end })
    TTroll:CreateButton({ Name="😈 Headsit",          Callback=function() S.Follow=true StartAttach("Headsit") end })
    TTroll:CreateButton({ Name="🧍 Stand on Side",    Callback=function() S.Follow=true StartAttach("Stand") end })
    TTroll:CreateButton({ Name="👀 Follow",           Callback=function() S.Follow=true StartAttach("Follow") end })
    TTroll:CreateButton({ Name="😳 Face-to-face",     Callback=function() S.Follow=true StartAttach("Front") end })
    TTroll:CreateButton({ Name="⛔ Stop Attach",      Callback=function() S.Follow=false S.BackTroll=false StopAttach() end })
end)
--[[ Voodo TROLL PRO 2026 — Full Rewrite | Part 4/4 ]]

-- ══ MOVEMENT TAB ══════════════════════════════════════════
pcall(function()
    TMove:CreateSection("Speed & Jump")
    TMove:CreateSlider({ Name="Walk Speed", Range={16,350}, Increment=1, CurrentValue=16,
        Flag="f_ws", Callback=function(v) S.WalkSpeed=v end })
    TMove:CreateSlider({ Name="Jump Power", Range={50,500}, Increment=5, CurrentValue=50,
        Flag="f_jp", Callback=function(v) S.JumpPower=v end })
    TMove:CreateButton({ Name="Reset Speed & Jump", Callback=function()
        S.WalkSpeed=16; S.JumpPower=50; N("Movement","Reset!",2) end })
end)

pcall(function()
    TMove:CreateSection("Abilities")
    TMove:CreateToggle({ Name="Fly  [WASD + Space/Ctrl | Shift=Fast]",
        CurrentValue=false, Flag="f_fly", Callback=ToggleFly })
    TMove:CreateToggle({ Name="Noclip",
        CurrentValue=false, Flag="f_nc",  Callback=ToggleNC })
    TMove:CreateToggle({ Name="Invisible",
        CurrentValue=false, Flag="f_inv", Callback=ToggleInvis })
    TMove:CreateToggle({ Name="God Mode",
        CurrentValue=false, Flag="f_god", Callback=ToggleGod })
    TMove:CreateToggle({ Name="Infinite Jump",
        CurrentValue=false, Flag="f_ij",  Callback=ToggleIJ })
end)

pcall(function()
    TMove:CreateSection("Teleport")
    TMove:CreateButton({ Name="TP to Nearest Player", Callback=TPNearest })
    TMove:CreateButton({ Name="TP to Target Username", Callback=TPToTarget })
    TMove:CreateButton({ Name="TP to Spawn", Callback=function()
        local r=Root(); if not r then return end
        local sp=workspace:FindFirstChild("SpawnLocation")
        if sp then r.CFrame=sp.CFrame+Vector3.new(0,5,0)
        else N("TP","No SpawnLocation found",2) end
    end})
end)

pcall(function()
    TMove:CreateSection("Misc")
    TMove:CreateButton({ Name="Kill Character", Callback=function()
        local h=Hum(); if h then h.Health=0 end end })
    TMove:CreateButton({ Name="⛔  UNLOAD EVERYTHING", Callback=Unload })
end)

-- ══ ESP TAB ═══════════════════════════════════════════════
pcall(function()
    TESP:CreateSection("Player ESP")
    TESP:CreateToggle({ Name="ESP  (Highlight + Name + Distance)",
        CurrentValue=false, Flag="f_esp",
        Callback=function(v)
            S.ESP=v
            if v then EnableESP() else ClearESP() end
        end })
    TESP:CreateParagraph({ Title="ESP Info",
        Content="Red highlight + nametag showing distance in metres.\nAuto-updates as players move." })
end)

pcall(function()
    TESP:CreateSection("ESP Actions")
    TESP:CreateButton({ Name="Refresh ESP", Callback=function()
        if S.ESP then ClearESP(); EnableESP(); N("ESP","Refreshed!",2) end
    end})
    TESP:CreateButton({ Name="Print All Distances", Callback=function()
        local me=Root(); if not me then return end
        local lines={}
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LP and p.Character then
                local r=p.Character:FindFirstChild("HumanoidRootPart")
                if r then table.insert(lines,p.Name..": "..math.floor((r.Position-me.Position).Magnitude).."m") end
            end
        end
        N("Distances",table.concat(lines,"\n"),8)
    end})
end)

-- ══ DONE ══════════════════════════════════════════════════
N("Voodo TROLL PRO 2026","✅ All tabs loaded!\nType a username in Troll tab for attach features.",8)
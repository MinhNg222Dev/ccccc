local MosGenv=(getgenv and getgenv())or _G
if type(MosGenv.MosCuChillDe_Unload)=="function"then
pcall(MosGenv.MosCuChillDe_Unload)
end
local MosX={Unloaded=false,Conns={}}
MosX.ThemeList={"Dark","Darker","Light","Aqua","Amethyst","Rose"}
function MosX.Track(conn)
table.insert(MosX.Conns,conn)
return conn
end
local FluentOk,Fluent=pcall(function()
return loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
end)
if not FluentOk or type(Fluent)~="table"then
warn("[MosCuChillDe] Could not load the Fluent UI library: "..tostring(Fluent))
return
end
local Players=game:GetService("Players")
local UserInputService=game:GetService("UserInputService")
local TweenService=game:GetService("TweenService")
local RunService=game:GetService("RunService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local HttpService=game:GetService("HttpService")
local TeleportService=game:GetService("TeleportService")
local Lighting=game:GetService("Lighting")
local VirtualInputManager=game:GetService("VirtualInputManager")
local VirtualUser=game:GetService("VirtualUser")
local LocalPlayer=Players.LocalPlayer
local LOGO_ASSET_ID="88336270285979"
local MosErrorLabel=nil
local MosAccent=Color3 .fromRGB(0,150,255)
local function MosGuiParent()
local parent
pcall(function()if gethui then parent=gethui()end end)
if not parent then pcall(function()parent=game:GetService("CoreGui")end)end
if not parent then parent=LocalPlayer:WaitForChild("PlayerGui")end
return parent
end
local LogoGui=Instance.new("ScreenGui")
LogoGui.Name="MosCuChillDeLogoGui"
LogoGui.ResetOnSpawn=false
LogoGui.IgnoreGuiInset=true
LogoGui.DisplayOrder=10000
LogoGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
pcall(function()if syn and syn.protect_gui then syn.protect_gui(LogoGui)end end)
pcall(function()LogoGui.Parent=MosGuiParent()end)
if not LogoGui.Parent then LogoGui.Parent=LocalPlayer:WaitForChild("PlayerGui")end
local LogoFrame=Instance.new("Frame")
LogoFrame.Name="Logo"
LogoFrame.Size=UDim2 .new(0,52,0,52)
LogoFrame.Position=UDim2 .new(0,8,0.5,-26)
LogoFrame.BackgroundColor3=Color3 .fromRGB(0,0,0)
LogoFrame.BorderSizePixel=0
LogoFrame.Active=true
LogoFrame.Parent=LogoGui
Instance.new("UICorner",LogoFrame).CornerRadius=UDim.new(0.2,0)
local logoStroke=Instance.new("UIStroke",LogoFrame)
logoStroke.Thickness=1.8
logoStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
local logoGrad=Instance.new("UIGradient",logoStroke)
function MosX.ApplyAccent(c)
pcall(function()
local h,s=c:ToHSV()
local light=Color3 .fromHSV(h,math.max(s-0.45,0),1)
logoGrad.Color=ColorSequence.new({
ColorSequenceKeypoint.new(0,c),
ColorSequenceKeypoint.new(0.5,light),
ColorSequenceKeypoint.new(1,c),
})
end)
end
MosX.ApplyAccent(MosAccent)
task.spawn(function()
pcall(function()
TweenService:Create(logoGrad,TweenInfo.new(3,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{Rotation=180}):Play()
end)
end)
local LogoFallback=Instance.new("TextLabel")
LogoFallback.Size=UDim2 .new(1,0,1,0)
LogoFallback.BackgroundTransparency=1
LogoFallback.Text="M"
LogoFallback.Font=Enum.Font.GothamBold
LogoFallback.TextSize=30
LogoFallback.TextColor3=Color3 .fromRGB(255,255,255)
LogoFallback.ZIndex=1
LogoFallback.Parent=LogoFrame
local LogoImg=Instance.new("ImageLabel")
LogoImg.Size=UDim2 .new(1,-6,1,-6)
LogoImg.Position=UDim2 .new(0,3,0,3)
LogoImg.BackgroundTransparency=1
LogoImg.ScaleType=Enum.ScaleType.Fit
LogoImg.ZIndex=2
LogoImg.Parent=LogoFrame
Instance.new("UICorner",LogoImg).CornerRadius=UDim.new(0.2,0)
task.spawn(function()
local function waitLoaded(t)
local s=os.clock()
while os.clock()-s<t do
if LogoImg.IsLoaded then return true end
task.wait(0.15)
end
return LogoImg.IsLoaded
end
local function done()
LogoFallback.Visible=false
end
LogoImg.Image="rbxthumb://type=Asset&id="..LOGO_ASSET_ID.."&w=150&h=150"
if waitLoaded(5)then return done()end
local okObj,objs=pcall(function()
return game:GetObjects("rbxassetid://"..LOGO_ASSET_ID)
end)
if okObj and type(objs)=="table"and objs[1]then
local o=objs[1]
local tex
if o:IsA("Decal")or o:IsA("Texture")then
tex=o.Texture
elseif o:IsA("ImageLabel")or o:IsA("ImageButton")then
tex=o.Image
end
pcall(function()o:Destroy()end)
if type(tex)=="string"and tex~=""then
LogoImg.Image=tex
if waitLoaded(5)then return done()end
end
end
LogoImg.Image="rbxassetid://"..LOGO_ASSET_ID
if waitLoaded(5)then return done()end
end)
local LogoBtn=Instance.new("TextButton")
LogoBtn.Size=UDim2 .new(1,0,1,0)
LogoBtn.BackgroundTransparency=1
LogoBtn.Text=""
LogoBtn.ZIndex=5
LogoBtn.Parent=LogoFrame
do
local dragging,dragStart,startAbs=false,nil,nil
MosX.Track(LogoBtn.InputBegan:Connect(function(input)
if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
dragging,dragStart,startAbs=true,input.Position,LogoFrame.AbsolutePosition
end
end))
MosX.Track(UserInputService.InputChanged:Connect(function(input)
if dragging and(input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch)then
local delta=input.Position-dragStart
local cam=workspace.CurrentCamera
local vp=cam and cam.ViewportSize or Vector2 .new(1280,720)
local sz=LogoFrame.AbsoluteSize
local nx=math.clamp(startAbs.X+delta.X,0,math.max(vp.X-sz.X,0))
local ny=math.clamp(startAbs.Y+delta.Y,0,math.max(vp.Y-sz.Y,0))
LogoFrame.Position=UDim2 .fromOffset(nx,ny)
end
end))
MosX.Track(UserInputService.InputEnded:Connect(function(input)
if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
dragging=false
end
end))
end
local Window
local minimizeKey=Enum.KeyCode.LeftControl
local lastToggleTime=0
local function toggleUI()
local now=tick()
if now-lastToggleTime<0.3 then return end
lastToggleTime=now
if Window then
pcall(function()Window:Minimize()end)
end
end
local clickStartPos=Vector2 .new()
MosX.Track(LogoBtn.InputBegan:Connect(function(input)
if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
clickStartPos=Vector2 .new(input.Position.X,input.Position.Y)
end
end))
MosX.Track(LogoBtn.InputEnded:Connect(function(input)
if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
local dist=(Vector2 .new(input.Position.X,input.Position.Y)-clickStartPos).Magnitude
if dist<10 then
toggleUI()
end
end
end))
local function MosShowError(msg)
warn("[MosCuChillDe] "..tostring(msg))
pcall(function()
if not MosErrorLabel then
MosErrorLabel=Instance.new("TextLabel")
MosErrorLabel.Name="MosError"
MosErrorLabel.Size=UDim2 .new(0,360,0,120)
MosErrorLabel.Position=UDim2 .new(0,66,0.5,-60)
MosErrorLabel.BackgroundColor3=Color3 .fromRGB(10,10,20)
MosErrorLabel.BackgroundTransparency=0.1
MosErrorLabel.TextColor3=Color3 .fromRGB(255,120,120)
MosErrorLabel.TextWrapped=true
MosErrorLabel.TextXAlignment=Enum.TextXAlignment.Left
MosErrorLabel.TextYAlignment=Enum.TextYAlignment.Top
MosErrorLabel.Font=Enum.Font.Code
MosErrorLabel.TextSize=12
MosErrorLabel.Parent=LogoGui
Instance.new("UICorner",MosErrorLabel).CornerRadius=UDim.new(0,8)
end
MosErrorLabel.Text="MosCuChillDe error:\n"..tostring(msg)
end)
end
local MosStage="starting"
local MosLoaded=false
local function MosOnRemote(name,fn)
task.spawn(function()
local ev=ReplicatedStorage:WaitForChild("Events"):WaitForChild(name,15)
if ev and ev:IsA("RemoteEvent")then
ev.OnClientEvent:Connect(fn)
end
end)
end
task.delay(20,function()
if not MosLoaded and not MosX.Unloaded then
MosShowError("Still loading after 20s (stuck at: "..MosStage..").\nThe game may have changed - tell the dev this stage name.")
end
end)
function MosX.Unload()
if MosX.Unloaded then return end
MosX.Unloaded=true
pcall(function()if MosX.OnUnload then MosX.OnUnload()end end)
for _,c in ipairs(MosX.Conns)do
pcall(function()c:Disconnect()end)
end
table.clear(MosX.Conns)
pcall(function()LogoGui:Destroy()end)
pcall(function()Fluent:Destroy()end)
if MosGenv.MosCuChillDe_Unload==MosX.Unload then
MosGenv.MosCuChillDe_Unload=nil
end
end
MosGenv.MosCuChillDe_Unload=MosX.Unload
local __MosOk,__MosErr=xpcall(function()
local MosCfg={
AutoCast=false,
AutoCastMethod="Instant",
CastDelay=1,
AutoReel=false,
AutoMiniGame=false,
ReelDelay=0.35,
MiniGameDelay=0.12,
BossMode="Normal",
AutoBoss=false,
AutoSecretBoss=false,
AutoSkill=false,
SkillOrder={"Z","X","C","V"},
AutoSell=false,
AutoSellMethod="Delay",
SellDelay=1,
SelectedBuyBait="",
BuyBaitAmount=1,
BuyBaitDelay=1,
AutoBuyBait=false,
SelectedBait="",
BaitAmount=1,
AutoCraftBait=false,
SelectedRod="",
AutoCraftRod=false,
SelectedIsland="",
SelectedNPC="",
SelectedPlayer="",
ESPEnabled=false,
AntiAFK=true,
FullBright=false,
NoFog=false,
LoopSpeedEnabled=false,
WalkSpeed=30,
NoclipEnabled=false,
InfJumpEnabled=false,
FlyEnabled=false,
FlySpeed=2,
FlyKeybind="F",
FlyKeybindEnabled=true,
NoclipKeybind="J",
NoclipKeybindEnabled=true,
DisableAllKeybinds=false,
SavedPos=false,
AutoTPPos=false,
AutoFarmIsland=false,
SelectedFarmIsland="Beginning Isle",
AutoTicketQuest=false,
TicketQuestMode="Hard",
AutoZengTianguoQuest=false,
AutoEquipBestBait=false,
AutoEquipPickedBait=false,
SelectedEquipBait="",
AutoUpgradeChar=false,
UpgradeCharType="Level + Cash",
UpgradeCharDelay=5,
HopBossDelay=5,
HopWeatherDelay=5,
BossWebhookUrl="",
WeatherWebhookUrl="",
AutoDaily=false,
AutoSummon=false,
SelectedBanner="",
SummonX10=false,
AutoBuyBestRod=false,
AutoRedeem=false,
FpsBoost=false,
WalkOnWater=false,
InstantInteract=false,
HideNameAndID=false,
HideNameText="MosCuChillDe",
AutoFilterZengQuest=false,
AutoClaimDailyQuest=false,
AutoGiveFish=false,
AutoFavoriteBoss=false,
AutoFavoriteBossTarget={},
FilterFishEnabled=false,
FilterFishTarget={},
AutoHopWeather=false,
SelectedWeather="Thunderstorm",
AutoHopSacredBeast=false,
AutoExe=false,
ThemeName="Darker",
AccentColor={0,150,255}
}
local SAVE_FOLDER="MosHub"
local SAVE_FILE=SAVE_FOLDER.."/MosChill.json"
local OLD_SAVE_FILE=SAVE_FOLDER.."/MosCuChillDe.json"
local function MosSave()
pcall(function()
if not isfolder(SAVE_FOLDER)then makefolder(SAVE_FOLDER)end
writefile(SAVE_FILE,HttpService:JSONEncode(MosCfg))
end)
end
local function MosLoad()
pcall(function()
local cfgFile=nil
if isfile(SAVE_FILE)then
cfgFile=SAVE_FILE
elseif isfile(OLD_SAVE_FILE)then
cfgFile=OLD_SAVE_FILE
end
if cfgFile then
local decoded=HttpService:JSONDecode(readfile(cfgFile))
for k,v in pairs(decoded)do
if MosCfg[k]~=nil then
MosCfg[k]=v
end
end
end
end)
end
MosLoad()
if type(MosCfg.SkillOrder)~="table"then
MosCfg.SkillOrder={"Z","X","C","V"}
else
local validKeys={Z=true,X=true,C=true,V=true}
local filtered={}
for _,k in ipairs(MosCfg.SkillOrder)do
if validKeys[k]and not table.find(filtered,k)then
table.insert(filtered,k)
end
end
MosCfg.SkillOrder=filtered
end
if MosCfg.AutoSellMethod=="On Full"or MosCfg.AutoSellMethod=="Sell When Full"then
MosCfg.AutoSellMethod="Sell When Full Inventory"
end
for _,key in ipairs({"FilterFishTarget","AutoFavoriteBossTarget"})do
local v=MosCfg[key]
if type(v)=="string"then
MosCfg[key]=(v~="")and{v}or{}
elseif type(v)~="table"then
MosCfg[key]={}
end
end
if type(MosCfg.SelectedWeather)~="string"or MosCfg.SelectedWeather==""then
MosCfg.SelectedWeather="Thunderstorm"
end
if type(MosCfg.HideNameText)~="string"or string.match(MosCfg.HideNameText,"^%s*(.-)%s*$")==""then
MosCfg.HideNameText="MosCuChillDe"
end
if not table.find(MosX.ThemeList,MosCfg.ThemeName)then
MosCfg.ThemeName="Darker"
end
if type(MosCfg.AccentColor)~="table"or#MosCfg.AccentColor<3 then
MosCfg.AccentColor={0,150,255}
end
pcall(function()
MosAccent=Color3 .fromRGB(
math.clamp(tonumber(MosCfg.AccentColor[1])or 0,0,255),
math.clamp(tonumber(MosCfg.AccentColor[2])or 150,0,255),
math.clamp(tonumber(MosCfg.AccentColor[3])or 255,0,255)
)
MosX.ApplyAccent(MosAccent)
end)
MosStage="creating window"
Window=Fluent:CreateWindow({
Title="Mos Hub",
SubTitle="by noelnoathebest02 | Heavyweigh Fishing",
TabWidth=120,
Size=UDim2 .fromOffset(440,330),
Acrylic=false,
Theme=(table.find(MosX.ThemeList,MosCfg.ThemeName)and MosCfg.ThemeName)or"Darker",
MinimizeKey=Enum.KeyCode.LeftControl
})
local Tabs={
Main=Window:AddTab({Title="Main",Icon="home"}),
Quest=Window:AddTab({Title="Quest",Icon="scroll"}),
Player=Window:AddTab({Title="Player",Icon="user"}),
Teleport=Window:AddTab({Title="Teleport",Icon="map-pin"}),
Shop=Window:AddTab({Title="Shop",Icon="shopping-cart"}),
ESP=Window:AddTab({Title="ESP",Icon="eye"}),
Misc=Window:AddTab({Title="Misc",Icon="layers"}),
Settings=Window:AddTab({Title="Settings",Icon="settings"})
}
MosX.Build={}
MosX.LoadingNote=Tabs.Main:AddParagraph({Title="Mos Hub",Content="Loading features..."})
local Events=ReplicatedStorage:WaitForChild("Events")
local Info=ReplicatedStorage:WaitForChild("Info")
local DataFolder=ReplicatedStorage:WaitForChild("Data")
MosStage="waiting for player data"
local PlayerData=DataFolder:WaitForChild(tostring(LocalPlayer.UserId))
MosStage="player data ok"
local ToggleHotbar=Events:WaitForChild("ToggleHotbar")
local FishingEvent=Events:WaitForChild("Fishing")
local UpdateFishProgression=Events:WaitForChild("UpdateFishProgression")
local UseSkill=Events:WaitForChild("UseSkill")
local SellFish=Events:WaitForChild("SellFish")
local CraftBaitEvent=Events:WaitForChild("CraftBait")
local CraftRodEvent=Events:WaitForChild("CraftRod")
local RedeemCodeEvent=Events:WaitForChild("RedeemCode")
local EquipBaitEvent=Events:WaitForChild("EquipBait",5)
local function GetSavedCFrame()
if type(MosCfg.SavedPos)=="table"and#MosCfg.SavedPos>=3 then
local ok,cf=pcall(CFrame.new,unpack(MosCfg.SavedPos))
if ok and cf then
return cf
end
end
return nil
end
local IslandFarmPositions={
["Beginning Isle"]=CFrame.new(-297.48,9.28,58.78,0.00,0.00,1.00,-0.00,1.00,-0.00,-1.00,-0.00,0.00),
["Bamboo Isle"]=CFrame.new(-1310.04,9.28,29.79,-0.28,-0.00,0.96,-0.00,1.00,0.00,-0.96,-0.00,-0.28),
["Fallout Isle"]=CFrame.new(76.47,9.28,1265.92,-1.00,0.00,0.01,0.00,1.00,-0.00,-0.01,-0.00,-1.00),
["Sovereign Isle"]=CFrame.new(-1254.18,9.28,1301.79,-1.00,0.00,-0.07,0.00,1.00,-0.00,0.07,-0.00,-1.00),
["Perch Isle"]=CFrame.new(-38.55,9.28,-1343.82,0.99,-0.00,-0.12,0.00,1.00,0.00,0.12,-0.00,0.99),
["Frost Isle"]=CFrame.new(-1348.71,9.28,-1446.51,-1.00,-0.00,-0.03,-0.00,1.00,0.00,0.03,0.00,-1.00),
["Coconut Isle"]=CFrame.new(1431.00,9.28,-1430.22,-0.17,0.00,0.98,-0.00,1.00,-0.00,-0.98,-0.00,-0.17),
["Amber Isle"]=CFrame.new(1122.07,9.28,1414.54,0.03,-0.00,1.00,-0.00,1.00,0.00,-1.00,-0.00,0.03),
["Battlefield Isle"]=CFrame.new(1249.73,19.56,68.87,0.01,0.00,1.00,0.00,1.00,-0.00,-1.00,0.00,0.01),
["Mistpeak Isle"]=CFrame.new(2549.02,9.28,-80.77,-0.03,0.00,1.00,0.00,1.00,-0.00,-1.00,0.00,-0.03),
["World Angler Isle"]=CFrame.new(-2345.67,9.28,-203.65,-0.09,-0.00,-1.00,0.00,1.00,-0.00,1.00,-0.00,-0.09),
["Weather Isle"]=CFrame.new(-2886.12,6.76,1199.79,-0.04,-0.00,-1.00,-0.00,1.00,-0.00,1.00,0.00,-0.04),
["Mystic Reef Isle"]=CFrame.new(-2561.58,9.28,-1288.64,-0.07,-0.00,-1.00,0.00,1.00,-0.00,1.00,-0.00,-0.07)
}
local function GetIslandFarmCFrame(islandKey)
local key=islandKey or MosCfg.SelectedFarmIsland or""
if IslandFarmPositions[key]then
return IslandFarmPositions[key]
end
local cleanKey=tostring(key):gsub("%s*|%s*%d+",""):gsub("^%s+",""):gsub("%s+$","")
if IslandFarmPositions[cleanKey]then
return IslandFarmPositions[cleanKey]
end
local lowerClean=string.lower(cleanKey)
for name,cf in pairs(IslandFarmPositions)do
local lName=string.lower(name)
if lowerClean==lName or string.find(lowerClean,lName,1,true)or string.find(lName,lowerClean,1,true)then
return cf
end
end
return nil
end
local ModuleCache={}
local function GetModuleData(mod)
if not mod or not mod:IsA("ModuleScript")then return nil end
local cached=ModuleCache[mod]
if cached~=nil then
return cached~=false and cached or nil
end
local ok,data=pcall(require,mod)
if ok and type(data)=="table"then
ModuleCache[mod]=data
return data
end
ModuleCache[mod]=false
return nil
end
local lastAfkTick=os.clock()
LocalPlayer.Idled:Connect(function()
if not MosCfg.AntiAFK then return end
pcall(function()
VirtualUser:CaptureController()
VirtualUser:ClickButton2(Vector2 .new(0,0))
end)
end)
task.spawn(function()
while true do
task.wait(1)
if MosCfg.AntiAFK then
local now=os.clock()
if now-lastAfkTick>=600 then
lastAfkTick=now
pcall(function()
VirtualUser:CaptureController()
VirtualUser:ClickButton2(Vector2 .new(0,0))
end)
end
pcall(function()
local afkVal=PlayerData and PlayerData:FindFirstChild("AFK")
if afkVal and afkVal.Value==true then
local afkEvent=Events:FindFirstChild("AFK")
if afkEvent then
afkEvent:FireServer()
end
end
end)
else
lastAfkTick=os.clock()
end
end
end)
if getconnections then
for _,conn in pairs(getconnections(LocalPlayer.Idled))do
if conn.Disable then
conn:Disable()
elseif conn.Disconnect then
conn:Disconnect()
end
end
end
local cachedChar=LocalPlayer.Character
local cachedHum=cachedChar and cachedChar:FindFirstChildOfClass("Humanoid")
local cachedHrp=cachedChar and cachedChar:FindFirstChild("HumanoidRootPart")
local cachedSkillsFolder=cachedChar and cachedChar:FindFirstChild("Skills")
local cachedStatsFolder=cachedChar and cachedChar:FindFirstChild("Stats")
local FishesFolder=workspace:FindFirstChild("Fishes")
MosStage="waiting for MainGui / Fishing UI"
local MainGui=LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("MainGui")
local FishingGui=MainGui:WaitForChild("Fishing")
local BarFrame=FishingGui:WaitForChild("BarFrame")
local FishingBar=BarFrame:WaitForChild("Bar")
local SkillBtnFrame=FishingGui:WaitForChild("SkillButton"):WaitForChild("Frame")
local RhythmGui=FishingGui:FindFirstChild("Rhythm")
local BossFightBar=FishingGui:FindFirstChild("BossFightBar")
local MobileGui=MainGui:FindFirstChild("Mobile")
local MobileFishingBtn=MobileGui and MobileGui:FindFirstChild("Fishing")
local RhythmHitEvent=Events:FindFirstChild("RhythmHit")
MosStage="game UI ok"
local function RefreshGuiCache()
if not MainGui or not MainGui.Parent then
local pg=LocalPlayer:FindFirstChild("PlayerGui")
MainGui=pg and pg:FindFirstChild("MainGui")
FishingGui=MainGui and MainGui:FindFirstChild("Fishing")
BarFrame=FishingGui and FishingGui:FindFirstChild("BarFrame")
FishingBar=BarFrame and BarFrame:FindFirstChild("Bar")
local sb=FishingGui and FishingGui:FindFirstChild("SkillButton")
SkillBtnFrame=sb and sb:FindFirstChild("Frame")
RhythmGui=FishingGui and FishingGui:FindFirstChild("Rhythm")
BossFightBar=FishingGui and FishingGui:FindFirstChild("BossFightBar")
MobileGui=MainGui and MainGui:FindFirstChild("Mobile")
MobileFishingBtn=MobileGui and MobileGui:FindFirstChild("Fishing")
else
if not RhythmGui or not RhythmGui.Parent then
RhythmGui=FishingGui and FishingGui:FindFirstChild("Rhythm")
end
if not BossFightBar or not BossFightBar.Parent then
BossFightBar=FishingGui and FishingGui:FindFirstChild("BossFightBar")
end
if not MobileFishingBtn or not MobileFishingBtn.Parent then
MobileGui=MainGui and MainGui:FindFirstChild("Mobile")
MobileFishingBtn=MobileGui and MobileGui:FindFirstChild("Fishing")
end
end
if not RhythmHitEvent then
RhythmHitEvent=Events:FindFirstChild("RhythmHit")
end
if not FishesFolder or not FishesFolder.Parent then
FishesFolder=workspace:FindFirstChild("Fishes")
end
end
local _noclipThrottle=0
RunService.Stepped:Connect(function(_,dt)
if not MosCfg.NoclipEnabled and not MosCfg.LoopSpeedEnabled then return end
_noclipThrottle=_noclipThrottle+dt
if _noclipThrottle<0.08 then return end
_noclipThrottle=0
local char=cachedChar
if not char or not char.Parent then return end
if MosCfg.NoclipEnabled then
for _,part in ipairs(char:GetChildren())do
if part:IsA("BasePart")and part.CanCollide then
part.CanCollide=false
end
end
end
if MosCfg.LoopSpeedEnabled and cachedHum and cachedHum.WalkSpeed~=MosCfg.WalkSpeed then
cachedHum.WalkSpeed=MosCfg.WalkSpeed
end
end)
local lastInfJumpTick=0
local function IsInsideOceanWater(hrp)
if not hrp then return false end
local ocean=workspace:FindFirstChild("Ocean")
if not ocean then return false end
local pos=hrp.Position
for _,child in ipairs(ocean:GetChildren())do
if child.Name=="Water"and child:IsA("BasePart")then
local half=child.Size*0.5
local diff=child.Position-pos
if math.abs(diff.X)<=half.X and math.abs(diff.Y)<=half.Y and math.abs(diff.Z)<=half.Z then
return true
end
end
end
return false
end
UserInputService.JumpRequest:Connect(function()
if not MosCfg.InfJumpEnabled then return end
local now=os.clock()
if now-lastInfJumpTick<0.18 then return end
local char=cachedChar or LocalPlayer.Character
local hum=cachedHum or(char and char:FindFirstChildOfClass("Humanoid"))
local hrp=cachedHrp or(char and char:FindFirstChild("HumanoidRootPart"))
if not char or not hum or not hrp or hum.Health<=0 then return end
if char:GetAttribute("Swimming")==true or hrp:FindFirstChildOfClass("BodyPosition")or IsInsideOceanWater(hrp)then
return
end
lastInfJumpTick=now
hum:ChangeState(Enum.HumanoidStateType.Jumping)
end)
local flyConnection=nil
local jumpStateConnection=nil
local function startFly()
local char=LocalPlayer.Character
if not char then return end
local hrp=char:FindFirstChild("HumanoidRootPart")
local humanoid=char:FindFirstChildOfClass("Humanoid")
if not hrp or not humanoid then return end
humanoid.PlatformStand=true
local bv=Instance.new("BodyVelocity")
bv.MaxForce=Vector3 .new(9e9,9e9,9e9)
bv.Velocity=Vector3 .zero
bv.Parent=hrp
local bg=Instance.new("BodyGyro")
bg.MaxTorque=Vector3 .new(9e9,9e9,9e9)
bg.P=1e7
bg.D=12000
bg.CFrame=hrp.CFrame
bg.Parent=hrp
jumpStateConnection=humanoid.StateChanged:Connect(function(_,new)
if new==Enum.HumanoidStateType.Jumping or new==Enum.HumanoidStateType.Freefall then
humanoid.PlatformStand=true
end
end)
flyConnection=RunService.RenderStepped:Connect(function()
local cam=workspace.CurrentCamera
local move=Vector3 .zero
local md=humanoid.MoveDirection
if md.Magnitude>0 then
local flatLook=Vector3 .new(cam.CFrame.LookVector.X,0,cam.CFrame.LookVector.Z)
local flatRight=Vector3 .new(cam.CFrame.RightVector.X,0,cam.CFrame.RightVector.Z)
if flatLook.Magnitude>0.01 and flatRight.Magnitude>0.01 then
local fwdAmt=md:Dot(flatLook.Unit)
local rightAmt=md:Dot(flatRight.Unit)
move+=cam.CFrame.LookVector*fwdAmt
move+=cam.CFrame.RightVector*rightAmt
end
end
if move.Magnitude>0 then move=move.Unit end
bv.Velocity=move*MosCfg.FlySpeed*50
local look=cam.CFrame.LookVector
bg.CFrame=CFrame.lookAt(hrp.Position,hrp.Position+look,Vector3 .new(0,1,0))
end)
end
local function stopFly()
local char=LocalPlayer.Character
if not char then return end
local hrp=char:FindFirstChild("HumanoidRootPart")
local humanoid=char:FindFirstChildOfClass("Humanoid")
if humanoid then humanoid.PlatformStand=false end
if jumpStateConnection then
jumpStateConnection:Disconnect()
jumpStateConnection=nil
end
if flyConnection then
flyConnection:Disconnect()
flyConnection=nil
end
if hrp then
for _,v in pairs(hrp:GetChildren())do
if v:IsA("BodyVelocity")or v:IsA("BodyGyro")then
v:Destroy()
end
end
end
end
local function IsAntiConfuseActive()
return MosCfg.AutoSkill or MosCfg.AutoMiniGame or MosCfg.AutoBoss or MosCfg.AutoSecretBoss or MosCfg.AutoFarmIsland
end
local function ApplyAntiConfuse(char)
if not IsAntiConfuseActive()then return end
if char then
if char:GetAttribute("Confused")==true then
pcall(function()char:SetAttribute("Confused",false)end)
end
if char:GetAttribute("SkillLocked")==true then
pcall(function()char:SetAttribute("SkillLocked",false)end)
end
end
if SkillBtnFrame then
for _,btn in ipairs(SkillBtnFrame:GetChildren())do
if btn:IsA("TextButton")then
local lock=btn:FindFirstChild("Lock")
if lock and lock.Visible then
lock.Visible=false
end
end
end
end
if FishingGui then
local hpPlayer=FishingGui:FindFirstChild("HPPlayer")
local debuff=hpPlayer and hpPlayer:FindFirstChild("Debuff")
local confusedGui=debuff and debuff:FindFirstChild("Confused")
if confusedGui then
pcall(function()confusedGui:Destroy()end)
end
end
end
local antiConfuseConns={}
local function BindCharacterAntiConfuse(char)
for _,c in ipairs(antiConfuseConns)do
pcall(function()c:Disconnect()end)
end
table.clear(antiConfuseConns)
if not char then return end
table.insert(antiConfuseConns,char:GetAttributeChangedSignal("Confused"):Connect(function()
if IsAntiConfuseActive()and char:GetAttribute("Confused")==true then
ApplyAntiConfuse(char)
end
end))
table.insert(antiConfuseConns,char:GetAttributeChangedSignal("SkillLocked"):Connect(function()
if IsAntiConfuseActive()and char:GetAttribute("SkillLocked")==true then
ApplyAntiConfuse(char)
end
end))
if IsAntiConfuseActive()then
ApplyAntiConfuse(char)
end
end
local function StepAutoTPPos(char)
if not MosCfg.AutoTPPos then return end
if MosCfg.AutoBoss or MosCfg.AutoSecretBoss then return end
local targetCF=GetSavedCFrame()
if not targetCF then return end
local c=char or cachedChar or LocalPlayer.Character
local hrp=(c and c:FindFirstChild("HumanoidRootPart"))or cachedHrp
if hrp and(hrp.Position-targetCF.Position).Magnitude>5 then
hrp.CFrame=targetCF
end
end
local function StepAutoFarmIsland(char)
if not MosCfg.AutoFarmIsland then return end
if MosCfg.AutoBoss or MosCfg.AutoSecretBoss then return end
local targetCF=GetIslandFarmCFrame()
if not targetCF then return end
local c=char or cachedChar or LocalPlayer.Character
local hrp=(c and c:FindFirstChild("HumanoidRootPart"))or cachedHrp
if hrp and(hrp.Position-targetCF.Position).Magnitude>5 then
hrp.CFrame=targetCF
end
end
if cachedChar then
BindCharacterAntiConfuse(cachedChar)
task.spawn(function()
StepAutoTPPos(cachedChar)
StepAutoFarmIsland(cachedChar)
end)
end
LocalPlayer.CharacterAdded:Connect(function(newChar)
cachedChar=newChar
cachedHum=newChar:WaitForChild("Humanoid",5)
cachedHrp=newChar:WaitForChild("HumanoidRootPart",5)
cachedSkillsFolder=newChar:WaitForChild("Skills",5)
cachedStatsFolder=newChar:WaitForChild("Stats",5)
BindCharacterAntiConfuse(newChar)
task.wait(0.3)
StepAutoTPPos(newChar)
StepAutoFarmIsland(newChar)
if MosCfg.FlyEnabled then
startFly()
end
end)
local minigameOpenTick=0
local wasMinigameVisible=false
local bossPhase2SetupUntil=0
do
local bp2=Events:FindFirstChild("BossPhase2Setup")
if bp2 and bp2:IsA("RemoteEvent")then
bp2 .OnClientEvent:Connect(function()
bossPhase2SetupUntil=os.clock()+5
end)
end
end
local function FindSkillNumberValue(char,key)
local skillsFolder=cachedSkillsFolder or(char and char:FindFirstChild("Skills"))
if not skillsFolder then return nil,nil end
for _,s in ipairs(skillsFolder:GetChildren())do
if s:IsA("NumberValue")then
local k=s:GetAttribute("Key")or s.Name
if tostring(k)==key then
return s,skillsFolder
end
end
end
return nil,skillsFolder
end
local function FindSkillButton(key)
if not SkillBtnFrame then return nil end
local direct=SkillBtnFrame:FindFirstChild(key)
if direct then return direct end
for _,child in ipairs(SkillBtnFrame:GetChildren())do
if child:IsA("GuiObject")then
if tostring(child:GetAttribute("Key")or"")==key then
return child
end
for _,desc in ipairs(child:GetDescendants())do
if desc:IsA("TextLabel")and desc.Name~="CD"and desc.Text==key then
return child
end
end
end
end
return nil
end
local function IsGameAllowingSkill(char)
if not FishingGui or not FishingGui.Visible then
wasMinigameVisible=false
return false
end
if not wasMinigameVisible then
wasMinigameVisible=true
minigameOpenTick=os.clock()
end
if(RhythmGui and RhythmGui.Visible)or(BossFightBar and BossFightBar.Visible)then
return false
end
if char:GetAttribute("Phase2")==true then
bossPhase2SetupUntil=0
return false
end
if bossPhase2SetupUntil>0 and os.clock()<bossPhase2SetupUntil then
return false
end
if not IsAntiConfuseActive()then
if char:GetAttribute("SkillLocked")or char:GetAttribute("Confused")then
return false
end
else
ApplyAntiConfuse(char)
end
local stats=cachedStatsFolder or char:FindFirstChild("Stats")
if stats and stats:FindFirstChild("Stun")and stats.Stun.Value==true then
return false
end
local fishId=LocalPlayer:GetAttribute("FishID")
local fishObj=(fishId and FishesFolder)and FishesFolder:FindFirstChild(tostring(fishId))or nil
if fishObj then
local readyVal=fishObj:FindFirstChild("Ready")
if readyVal then
if readyVal.Value~=true then
return false
end
elseif os.clock()-minigameOpenTick<3.1 then
return false
end
if fishObj:GetAttribute("FinalPhase")==true or fishObj:GetAttribute("PreFinalPhase")==true then
return false
end
elseif os.clock()-minigameOpenTick<3.1 then
return false
end
local skillsFolder=cachedSkillsFolder or char:FindFirstChild("Skills")
if skillsFolder then
for _,s in ipairs(skillsFolder:GetChildren())do
if s:IsA("NumberValue")and(s:GetAttribute("UsingSkill")or 0)>0 then
return false
end
end
end
return true
end
local function IsSkillSlotAvailable(char,key)
if PlayerData then
local rodVal=PlayerData:FindFirstChild("FishingRod")
local rodInv=PlayerData:FindFirstChild("FishingRodInventory")
local rf=(rodVal and rodVal.Value~=""and rodInv)and rodInv:FindFirstChild(rodVal.Value)or nil
local skFolder=rf and rf:FindFirstChild("Skill")
local skVal=skFolder and skFolder:FindFirstChild(key)
if skVal and skVal:IsA("StringValue")then
return skVal.Value~=""
end
end
local btn=FindSkillButton(key)
if btn then
return btn.Visible==true
end
local s=FindSkillNumberValue(char,key)
return s~=nil
end
local function IsSkillOnCooldown(char,key)
local btn=FindSkillButton(key)
if btn then
local cd=btn:FindFirstChild("CD")
if cd and cd.Visible then
local txt=cd.Text or""
local num=tonumber(string.match(txt,"%d+%.?%d*"))
if num and num>0 then
return true
end
end
end
local s=FindSkillNumberValue(char,key)
if s and(s.Value>0 or(s:GetAttribute("UsingSkill")or 0)>0)then
return true
end
return false
end
local function IsSkillConfirmedUsed(char,key)
return IsSkillOnCooldown(char,key)
end
local function IsSkillKeyReady(char,key)
if not IsSkillSlotAvailable(char,key)then
return false
end
if IsSkillOnCooldown(char,key)then
return false
end
local btn=FindSkillButton(key)
if btn then
if not btn.Visible then
return false
end
local lock=btn:FindFirstChild("Lock")
if lock and lock.Visible then
if IsAntiConfuseActive()then
lock.Visible=false
else
return false
end
end
end
local s,skillsFolder=FindSkillNumberValue(char,key)
if s then
return true
end
if skillsFolder and#skillsFolder:GetChildren()>0 then
return false
end
return btn~=nil and btn.Visible==true
end
local rhythmLanes={"A","S","D"}
local rhythmKeyMap={
A=Enum.KeyCode.A,
S=Enum.KeyCode.S,
D=Enum.KeyCode.D
}
local lastRhythmLaneHit={A=0,S=0,D=0}
local lastRhythmScan=0
local lastPhase2HitTick=0
local phase2BarHistory={}
local CENTER_BAR_POS=UDim2 .new(0.5,0,0.5,0)
local isLockingBar=false
local barPosConn=nil
local boundBar=nil
local function LockFishingBar()
if isLockingBar then return end
if not FishingGui or not FishingGui.Visible or not FishingBar then return end
if not(MosCfg.AutoReel or MosCfg.AutoMiniGame or MosCfg.AutoBoss or MosCfg.AutoSecretBoss or MosCfg.AutoFarmIsland)then return end
isLockingBar=true
local char=cachedChar
if char and(tonumber(char:GetAttribute("GuildPower"))or 0)<99999999 then
pcall(function()
char:SetAttribute("GuildPower",99999999)
local stats=cachedStatsFolder or char:FindFirstChild("Stats")
local rp=stats and stats:FindFirstChild("RodPower")
if rp then
local orig=rp.Value
rp.Value=orig+1
rp.Value=orig
end
end)
end
pcall(function()
FishingBar:TweenPosition(CENTER_BAR_POS,Enum.EasingDirection.InOut,Enum.EasingStyle.Linear,0,true)
FishingBar.Position=CENTER_BAR_POS
end)
isLockingBar=false
end
local function BindFishingBarLock()
if FishingBar and FishingBar~=boundBar then
if barPosConn then
pcall(function()barPosConn:Disconnect()end)
barPosConn=nil
end
boundBar=FishingBar
barPosConn=FishingBar:GetPropertyChangedSignal("Position"):Connect(function()
if not isLockingBar and FishingBar.Position.X.Scale~=0.5 then
LockFishingBar()
end
end)
end
end
BindFishingBarLock()
local function TriggerGuiButton(btn)
if not btn then return false end
if not btn:IsA("GuiButton")then
btn=btn:FindFirstChildWhichIsA("GuiButton",true)or(btn.Parent and btn.Parent:IsA("GuiButton")and btn.Parent)or nil
if not btn then return false end
end
local triggered=false
local sigNames={"MouseButton1Click","Activated","MouseButton1Down","MouseButton1Up"}
if getconnections then
for _,sName in ipairs(sigNames)do
local okSig,sig=pcall(function()return btn[sName]end)
if okSig and sig then
pcall(function()
for _,conn in pairs(getconnections(sig))do
if conn.Function then
task.spawn(conn.Function)
triggered=true
elseif conn.Fire then
conn:Fire()
triggered=true
end
end
end)
end
end
end
if firesignal then
for _,sName in ipairs(sigNames)do
pcall(function()
firesignal(btn[sName])
triggered=true
end)
end
end
return triggered
end
local getupval=(debug and debug.getupvalue)or getupvalue
local function StepPhase2MiniGame()
if not BossFightBar or not BossFightBar.Visible then
if#phase2BarHistory>0 then
table.clear(phase2BarHistory)
end
return
end
local bar=BossFightBar:FindFirstChild("Bar")
local hitbox=BossFightBar:FindFirstChild("Hitbox")
if not bar or not hitbox then return end
local barW=bar.Size.X.Scale
local barCenter=bar.Position.X.Scale+barW*(0.5-bar.AnchorPoint.X)
local hbW=hitbox.Size.X.Scale
local hbLeft=hitbox.Position.X.Scale-hbW*hitbox.AnchorPoint.X
local now=os.clock()
table.insert(phase2BarHistory,{t=now,x=barCenter})
while#phase2BarHistory>1 and(now-phase2BarHistory[1].t)>0.15 do
table.remove(phase2BarHistory,1)
end
local handledViaUpval=false
local onClickFn=nil
if getconnections and getupval and MobileFishingBtn then
pcall(function()
for _,conn in pairs(getconnections(MobileFishingBtn.MouseButton1Down))do
local fn=conn.Function and getupval(conn.Function,1)
if type(fn)=="function"then
onClickFn=fn
local u12=getupval(fn,1)
local u14=getupval(fn,2)
local u27=getupval(fn,3)
local u26=getupval(fn,4)
local u1=getupval(fn,5)
local u25=getupval(fn,6)
local u23=getupval(fn,7)
local u2=getupval(fn,8)
local u15=getupval(fn,9)
if u12==true and type(u14)=="number"and type(u27)=="number"and type(u26)=="number"and type(u1)=="number"and type(u25)=="number"and type(u23)=="number"and type(u2)=="number"and type(u15)=="number"then
if math.abs(u2-hbW)<0.005 and math.abs(u15-hbLeft)<0.005 then
handledViaUpval=true
if now-u14>=(MosCfg.MiniGameDelay or 0.12)and now-lastPhase2HitTick>=(MosCfg.MiniGameDelay or 0.12)then
local v91=(now-0.025-u27)%u26*u1
if u25<v91 then
v91=u25*2-v91
end
local v92=u23+v91
local v93=u2*0.3
if v92>=(u15-v93*0.8)and v92<=(u15+u2+v93*0.8)then
lastPhase2HitTick=now
fn(false)
end
end
end
break
end
end
end
end)
end
if handledViaUpval then return end
if now-lastPhase2HitTick<(MosCfg.MiniGameDelay or 0.12)then return end
local evalX=barCenter
local targetTime=now-0.041
for i=#phase2BarHistory,1,-1 do
if phase2BarHistory[i].t<=targetTime then
evalX=phase2BarHistory[i].x
break
end
end
local pad=hbW*0.2
local badBox=BossFightBar:FindFirstChild("HitboxBad")
if badBox and badBox.Visible then
local badW=badBox.Size.X.Scale
local badLeft=badBox.Position.X.Scale-badW*badBox.AnchorPoint.X
if evalX>=(badLeft-0.01)and evalX<=(badLeft+badW+0.01)then
return
end
end
if evalX>=(hbLeft-pad)and evalX<=(hbLeft+hbW+pad)then
lastPhase2HitTick=now
local clicked=false
if onClickFn then
pcall(function()
onClickFn(false)
clicked=true
end)
end
if not clicked and MobileFishingBtn then
if getconnections then
pcall(function()
for _,conn in pairs(getconnections(MobileFishingBtn.MouseButton1Down))do
if conn.Function then
task.spawn(conn.Function)
clicked=true
elseif conn.Fire then
conn:Fire()
clicked=true
end
end
end)
end
if not clicked and firesignal then
pcall(function()
firesignal(MobileFishingBtn.MouseButton1Down)
clicked=true
end)
end
end
if not clicked then
pcall(function()
VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,0)
task.delay(0.01,function()
VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,0)
end)
end)
end
end
end
do
local function isRed(c)
return c and c.R>0.65 and c.G<0.45 and c.B<0.45 and c.R>c.G*1.8 and c.R>c.B*1.8
end
function MosX.IsTrapNote(gui)
if not gui or not gui:IsA("GuiObject")then return false end
if gui:GetAttribute("Trap")==true or gui:GetAttribute("trap")==true or gui:GetAttribute("IsTrap")==true then
return true
end
if string.find(string.lower(gui.Name),"trap",1,true)then
return true
end
if isRed(gui.BackgroundColor3)then
return true
end
if(gui:IsA("ImageLabel")or gui:IsA("ImageButton"))and isRed(gui.ImageColor3)then
return true
end
for _,desc in ipairs(gui:GetDescendants())do
if desc:IsA("GuiObject")then
if isRed(desc.BackgroundColor3)then
return true
end
if(desc:IsA("ImageLabel")or desc:IsA("ImageButton"))and isRed(desc.ImageColor3)then
return true
end
end
end
return false
end
end
local function StepRhythmMiniGame()
if not RhythmGui or not RhythmGui.Visible then return end
local now=os.clock()
if now-lastRhythmScan<math.max(0.025,(MosCfg.MiniGameDelay or 0.12)/2)then return end
lastRhythmScan=now
for _,lane in ipairs(rhythmLanes)do
if now-(lastRhythmLaneHit[lane]or 0)>=math.max(0.05,MosCfg.MiniGameDelay or 0.12)then
local laneFrame=RhythmGui:FindFirstChild("Progression"..lane)
if laneFrame then
local barFrame=laneFrame:FindFirstChild("BarFrame")
local targetY=barFrame and barFrame.Position.Y.Scale or 0.85
local targetNote=nil
local bestDist=0.18
for _,child in ipairs(laneFrame:GetChildren())do
if child.Name=="Note_FX"and child:IsA("GuiObject")and child.Visible and not MosX.IsTrapNote(child)then
local dist=math.abs(child.Position.Y.Scale-targetY)
if dist<=bestDist then
bestDist=dist
targetNote=child
end
end
end
if targetNote then
lastRhythmLaneHit[lane]=now
local btn=laneFrame:FindFirstChild("Button")
if btn then
TriggerGuiButton(btn)
end
if targetNote.Parent~=nil then
local kc=rhythmKeyMap[lane]
if kc then
pcall(function()
VirtualInputManager:SendKeyEvent(true,kc,false,game)
task.delay(0.02,function()
VirtualInputManager:SendKeyEvent(false,kc,false,game)
end)
end)
end
end
if targetNote.Parent~=nil and bestDist<=0.1 and RhythmHitEvent then
pcall(function()
targetNote:Destroy()
RhythmHitEvent:FireServer("hit")
end)
end
end
end
end
end
end
RunService.RenderStepped:Connect(function()
if not FishingGui or not FishingGui.Visible then return end
BindFishingBarLock()
LockFishingBar()
if MosCfg.AutoMiniGame then
StepPhase2MiniGame()
end
end)
RunService.Stepped:Connect(function()
if not FishingGui or not FishingGui.Visible then return end
BindFishingBarLock()
LockFishingBar()
end)
RunService.Heartbeat:Connect(function()
if not FishingGui or not FishingGui.Visible then return end
BindFishingBarLock()
LockFishingBar()
if MosCfg.AutoMiniGame then
StepPhase2MiniGame()
StepRhythmMiniGame()
end
end)
local function GetModelPart(obj)
if not obj then return nil end
if obj:IsA("BasePart")then return obj end
if obj:IsA("Model")then
return obj:FindFirstChild("HumanoidRootPart")
or obj:FindFirstChild("Head")
or obj.PrimaryPart
or obj:FindFirstChildWhichIsA("BasePart",true)
end
return obj:FindFirstChildWhichIsA("BasePart",true)
end
local function IsSecretBossEntity(obj)
if not obj then return false end
if obj:GetAttribute("Secret")==true or obj:GetAttribute("Rarity")=="Secret"then
return true
end
local rawName=tostring(obj:GetAttribute("Name")or obj:GetAttribute("FishName")or obj.Name)
local lowerName=string.lower(rawName)
if string.find(lowerName,"secret")or string.find(lowerName,"long diaohai")or string.find(lowerName,"longdiaohai")or string.find(lowerName,"diaohai")or string.find(lowerName,"wuzhi")then
return true
end
local inv=Info:FindFirstChild("Inventory")
local mod=inv and inv:FindFirstChild(rawName)
local data=GetModuleData(mod)
if data and(data.Secret==true or data.Rarity=="Secret"or(data.Boss==true and(tonumber(data.Chance)or 100)<=1))then
return true
end
return false
end
local function FindBossTarget(wantSecret)
local npcFolder=workspace:FindFirstChild("NPC")
local bossFolder=npcFolder and npcFolder:FindFirstChild("Boss")
if bossFolder then
for _,boss in ipairs(bossFolder:GetChildren())do
local part=GetModelPart(boss)
if part then
local isSec=IsSecretBossEntity(boss)
if wantSecret and isSec then
return boss,part
elseif not wantSecret and not isSec then
return boss,part
end
end
end
end
if not wantSecret then
local wsBoss=workspace:FindFirstChild("Boss")or workspace:FindFirstChild("BossZone")
if wsBoss then
local part=GetModelPart(wsBoss)
if part then
return wsBoss,part
end
end
end
return nil,nil
end
local BossFarmPositions={
Enzo=CFrame.new(-114.81,9.28,1356.67,0.05,-0.00,-1.00,-0.00,1.00,-0.00,1.00,0.00,0.05),
LongDiaoHai=CFrame.new(-2873.62,32.17,1337.38,-0.09,0.00,-1.00,0.00,1.00,0.00,1.00,-0.00,-0.09)
}
local function GetBossFarmCFrame(wantSecret)
return wantSecret and BossFarmPositions.LongDiaoHai or BossFarmPositions.Enzo
end
local lastBossActionTick=0
local lastBossNotifyKey=""
local lastBossNotifyTick=0
local function NotifyBoss(title,content,key,cooldown)
end
local function GetButtonLabelText(obj)
if not obj then return""end
if obj:IsA("TextButton")or obj:IsA("TextLabel")then
if obj.Text and obj.Text~=""then
return obj.Text
end
end
local lbl=obj:FindFirstChild("Title")or obj:FindFirstChild("TextLabel")or obj:FindFirstChildWhichIsA("TextLabel",true)
if lbl and lbl.Text then
return lbl.Text
end
return""
end
local function TriggerGuiButton(btn)
if not btn then return false end
if not btn:IsA("GuiButton")then
btn=btn:FindFirstChildWhichIsA("GuiButton",true)or(btn.Parent and btn.Parent:IsA("GuiButton")and btn.Parent)or nil
if not btn then return false end
end
local triggered=false
pcall(function()
if btn.AbsolutePosition and btn.AbsoluteSize then
local pos=btn.AbsolutePosition+(btn.AbsoluteSize/2)
VirtualInputManager:SendMouseButtonEvent(pos.X,pos.Y,0,true,game,0)
task.wait(0.02)
VirtualInputManager:SendMouseButtonEvent(pos.X,pos.Y,0,false,game,0)
triggered=true
end
end)
local sigNames={"MouseButton1Click","Activated","MouseButton1Down","MouseButton1Up"}
if getconnections then
for _,sName in ipairs(sigNames)do
local okSig,sig=pcall(function()return btn[sName]end)
if okSig and sig then
pcall(function()
for _,conn in pairs(getconnections(sig))do
if conn.Function then
task.spawn(conn.Function)
triggered=true
elseif conn.Fire then
conn:Fire()
triggered=true
end
end
end)
end
end
end
if firesignal then
for _,sName in ipairs(sigNames)do
pcall(function()
firesignal(btn[sName])
triggered=true
end)
end
end
return triggered
end
local function FindBossMenuFrame()
if not MainGui then return nil end
local menu=MainGui:FindFirstChild("Menu")
if not menu then return nil end
for _,name in ipairs({"BossFight","Boss","BossMenu","Raid","SecretBoss"})do
local f=menu:FindFirstChild(name)
if f and f:IsA("GuiObject")then
return f
end
end
for _,child in ipairs(menu:GetChildren())do
if child:IsA("Frame")and child.Name~="Info"and child.Name~="Black"and child.Name~="Dialogue"then
local title=child:FindFirstChild("Title")
if title and title:IsA("TextLabel")and string.find(string.lower(title.Text),"boss")then
return child
end
if child:FindFirstChild("Normal",true)and child:FindFirstChild("Hard",true)and child:FindFirstChild("Nightmare",true)then
return child
end
end
end
return nil
end
local function GetBossRequirementSummary(bossFrame,bossName)
local missing={}
local rodVal=PlayerData and PlayerData:FindFirstChild("FishingRod")
local curRodName=rodVal and rodVal.Value or""
if curRodName==""then
table.insert(missing,"No Fishing Rod equipped")
end
local char=LocalPlayer.Character
local stats=char and char:FindFirstChild("Stats")
local inv=Info:FindFirstChild("Inventory")
if inv and bossName then
local bossMod=inv:FindFirstChild(bossName)
local bossData=GetModuleData(bossMod)
local rodMod=curRodName~=""and inv:FindFirstChild(curRodName)or nil
local rodData=GetModuleData(rodMod)
if bossData and tonumber(bossData.Power)and rodData and tonumber(rodData.Power)then
local rodBonus=stats and stats:FindFirstChild("RodPower")and tonumber(stats.RodPower.Value)or 0
local fishBonus=stats and stats:FindFirstChild("FishPower")and tonumber(stats.FishPower.Value)or 0
local playerPower=tonumber(rodData.Power)+rodBonus
local bossEffPower=math.max(1,tonumber(bossData.Power)-fishBonus+4)
if(playerPower/bossEffPower)<=0.5 then
table.insert(missing,string.format("Low Power (%d/%d)",math.floor(playerPower),math.floor(bossEffPower)))
end
end
end
if bossFrame then
for _,desc in ipairs(bossFrame:GetDescendants())do
if desc:IsA("TextLabel")and desc.Visible then
local txt=desc.Text or""
local cur,req=string.match(txt,"^%s*(%d+)%s*/%s*(%d+)%s*$")
if cur and req then
local nCur=tonumber(cur)
local nReq=tonumber(req)
if nCur and nReq and nCur<nReq then
table.insert(missing,cur.."/"..req)
end
end
end
end
end
return missing
end
local bossSummoned=false
local bossSummonTick=0
local function CloseBossMenuFrame(bossFrame)
if not bossFrame or not bossFrame.Visible then return end
local closed=false
for _,desc in ipairs(bossFrame:GetDescendants())do
if desc:IsA("GuiButton")and desc.Visible then
local bName=string.lower(desc.Name)
local bTxt=string.lower(GetButtonLabelText(desc))
local pName=desc.Parent and string.lower(desc.Parent.Name)or""
if bName=="close"or bTxt=="x"or pName=="close"then
if TriggerGuiButton(desc)then
closed=true
break
end
end
end
end
if not closed then
pcall(function()
bossFrame.Visible=false
end)
end
end
local function CheckBossStatusOnToggle(wantSecret)
bossSummoned=false
bossSummonTick=0
local rodVal=PlayerData and PlayerData:FindFirstChild("FishingRod")
if not rodVal or rodVal.Value==""then
return
end
local bossObj=FindBossTarget(wantSecret)
if not bossObj then
return
end
local hrp=cachedHrp or(LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
local targetCF=GetBossFarmCFrame(wantSecret)
if hrp and targetCF then
hrp.CFrame=targetCF
end
local char=cachedChar or LocalPlayer.Character
if char and char:GetAttribute("Type")~="Fishing Rod"then
pcall(function()
ToggleHotbar:InvokeServer("1")
end)
end
end
local function FireGuiSignal(btn)
if not btn then return false end
if not btn:IsA("GuiButton")then
btn=btn:FindFirstChildWhichIsA("GuiButton",true)or(btn.Parent and btn.Parent:IsA("GuiButton")and btn.Parent)or nil
if not btn then return false end
end
local triggered=false
local sigNames={"MouseButton1Click","Activated"}
if firesignal then
for _,sName in ipairs(sigNames)do
pcall(function()
firesignal(btn[sName])
triggered=true
end)
end
end
if getconnections then
for _,sName in ipairs(sigNames)do
local okSig,sig=pcall(function()return btn[sName]end)
if okSig and sig then
pcall(function()
for _,conn in pairs(getconnections(sig))do
if conn.Function then
task.spawn(conn.Function)
triggered=true
elseif conn.Fire then
conn:Fire()
triggered=true
end
end
end)
end
end
end
return triggered
end
local function ClickBossModeAndStart(bossFrame,bossName,mode,wantSecret)
local targetMode=mode or"Normal"
local selectContainer=bossFrame:FindFirstChild("Select",true)
local btnContainer=(selectContainer and selectContainer:FindFirstChild("button"))or selectContainer or bossFrame
local modeBtn=nil
if btnContainer then
modeBtn=btnContainer:FindFirstChild(targetMode)
if not modeBtn then
for _,child in ipairs(btnContainer:GetChildren())do
if child:IsA("GuiButton")and string.lower(child.Name)==string.lower(targetMode)then
modeBtn=child
break
end
end
end
end
if not modeBtn then
for _,desc in ipairs(bossFrame:GetDescendants())do
if desc:IsA("GuiButton")then
local dName=string.lower(desc.Name)
local dText=string.lower(GetButtonLabelText(desc))
if dName==string.lower(targetMode)or dText==string.lower(targetMode)then
modeBtn=desc
break
end
end
end
end
if modeBtn then
FireGuiSignal(modeBtn)
task.wait(0.15)
end
local fightBtn=bossFrame:FindFirstChild("Fight",true)
if not fightBtn then
for _,desc in ipairs(bossFrame:GetDescendants())do
if desc:IsA("GuiButton")then
local dName=string.lower(desc.Name)
local dText=string.lower(GetButtonLabelText(desc))
if dName=="fight"or dText=="fight"or string.find(dName,"fight")or string.find(dText,"fight")then
fightBtn=desc
break
end
end
end
end
if fightBtn then
FireGuiSignal(fightBtn)
end
local remotes={}
local function collectRemotes(folder)
if not folder then return end
for _,child in ipairs(folder:GetChildren())do
if child:IsA("RemoteEvent")or child:IsA("RemoteFunction")then
table.insert(remotes,child)
end
end
end
collectRemotes(Events)
local RemotesFolder=ReplicatedStorage:FindFirstChild("Remotes")
collectRemotes(RemotesFolder)
local targetNames={
["bossfight"]=true,
["startbossfight"]=true,
["startboss"]=true,
["boss"]=true,
["challengeboss"]=true,
["fightboss"]=true,
["choosedialogueoption"]=true
}
for _,ev in ipairs(remotes)do
local lowerName=string.lower(ev.Name)
if targetNames[lowerName]or string.find(lowerName,"boss")then
pcall(function()
if ev:IsA("RemoteEvent")then
ev:FireServer(targetMode)
if bossName then
ev:FireServer(bossName,targetMode)
ev:FireServer(targetMode,bossName)
end
elseif ev:IsA("RemoteFunction")then
ev:InvokeServer(targetMode)
if bossName then
ev:InvokeServer(bossName,targetMode)
ev:InvokeServer(targetMode,bossName)
end
end
end)
end
end
task.wait(0.25)
if FishingGui and FishingGui.Visible then
bossSummoned=true
bossSummonTick=os.clock()
if bossFrame then
CloseBossMenuFrame(bossFrame)
end
return true
end
return false
end
local lastCaughtBossTick=0
local lastCaughtFishName=""
do
local repEv=Events:FindFirstChild("ReplicateFishCaught")
if repEv and repEv:IsA("RemoteEvent")then
repEv.OnClientEvent:Connect(function(charModel,fishName)
if charModel==LocalPlayer.Character then
lastCaughtBossTick=os.clock()
lastCaughtFishName=tostring(fishName or"")
bossSummoned=false
bossSummonTick=0
end
end)
end
end
local trackingBossFight=false
local function MonitorBossMinigame()
if trackingBossFight then return end
local fishId=LocalPlayer:GetAttribute("FishID")
local fishesFolder=workspace:FindFirstChild("Fishes")
local fishObj=(fishId and fishesFolder)and fishesFolder:FindFirstChild(tostring(fishId))or nil
if not fishObj then return end
trackingBossFight=true
task.spawn(function()
local progBar=FishingGui and FishingGui:FindFirstChild("ProgressionBar")
local fNameLbl=progBar and progBar:FindFirstChild("FishName")
local fName=(fNameLbl and fNameLbl.Text~=""and fNameLbl.Text)or"Boss"
local hpObj=fishObj:FindFirstChild(LocalPlayer.UserId.."_PlayerHealth")
local maxFishHp=tonumber(fishObj:GetAttribute("MaxHealth"))or 100
local lastScale=0.5
local lastHp=hpObj and hpObj.Value or 100
local lastFishVal=fishObj:IsA("ValueBase")and fishObj.Value or 0
local hadFinalPhase=false
local lastFinalHp=1
while fishObj.Parent and(FishingGui and FishingGui.Visible)do
bossSummonTick=os.clock()
if hpObj then
lastHp=hpObj.Value
end
if fishObj:IsA("ValueBase")then
lastFishVal=fishObj.Value
end
if fishObj:GetAttribute("FinalPhase")==true then
hadFinalPhase=true
end
if fishObj:GetAttribute("FinalPhaseHP")~=nil then
lastFinalHp=tonumber(fishObj:GetAttribute("FinalPhaseHP"))or lastFinalHp
end
if FishingBar then
lastScale=FishingBar.Position.X.Scale
end
task.wait(0.1)
end
task.wait(0.35)
bossSummoned=false
bossSummonTick=0
trackingBossFight=false
end)
end
local function StepAutoBoss(char,isMinigame)
if isMinigame then
bossSummoned=true
bossSummonTick=os.clock()
MonitorBossMinigame()
return
end
local now=os.clock()
if now-lastBossActionTick<0.8 then return end
lastBossActionTick=now
if bossSummoned and(now-bossSummonTick>45)then
bossSummoned=false
end
local wantSecret=MosCfg.AutoSecretBoss
local rodVal=PlayerData and PlayerData:FindFirstChild("FishingRod")
if not rodVal or rodVal.Value==""then
return
end
local bossObj,bossPart=FindBossTarget(wantSecret)
local targetCF=GetBossFarmCFrame(wantSecret)
if not bossObj and not targetCF then
return
end
local hrp=cachedHrp or(char and char:FindFirstChild("HumanoidRootPart"))
local bossName=bossObj and(bossObj:GetAttribute("Name")or bossObj.Name)or(wantSecret and"Long DiaoHai"or"Enzo")
if hrp then
if targetCF then
if(hrp.Position-targetCF.Position).Magnitude>5 then
hrp.CFrame=targetCF
end
elseif bossPart then
local dist=(hrp.Position-bossPart.Position).Magnitude
if dist>12 then
hrp.CFrame=bossPart.CFrame*CFrame.new(0,3,-5)
end
end
end
if char and char:GetAttribute("Type")~="Fishing Rod"then
pcall(function()
ToggleHotbar:InvokeServer("1")
end)
end
local bossFrame=FindBossMenuFrame()
if not bossSummoned then
if bossPart and hrp then
local prompt=bossObj and bossObj:FindFirstChildWhichIsA("ProximityPrompt",true)
if not prompt and bossPart then
prompt=bossPart:FindFirstChildWhichIsA("ProximityPrompt",true)
end
if prompt and fireproximityprompt then
pcall(function()
fireproximityprompt(prompt)
end)
end
end
if bossFrame and bossFrame.Visible then
ClickBossModeAndStart(bossFrame,bossName,MosCfg.BossMode,wantSecret)
end
if MainGui and not bossSummoned then
local menu=MainGui:FindFirstChild("Menu")
local dialogue=menu and menu:FindFirstChild("Dialogue")
if dialogue and dialogue.Visible then
local btnFrame=dialogue:FindFirstChild("ButtonFrame")
if btnFrame then
local chosenBtn=nil
local modeLower=string.lower(MosCfg.BossMode or"Normal")
for _,btn in ipairs(btnFrame:GetChildren())do
if btn:IsA("TextButton")and btn.Name~="Template"and btn.Visible then
local title=btn:FindFirstChild("Title")
local txt=title and string.lower(title.Text)or""
if string.find(txt,modeLower)then
chosenBtn=btn
break
elseif not chosenBtn and not string.find(txt,"close")and not string.find(txt,"cancel")and not string.find(txt,"nevermind")and not string.find(txt,"leave")then
chosenBtn=btn
end
end
end
if chosenBtn then
TriggerGuiButton(chosenBtn)
end
end
end
end
else
if bossFrame and bossFrame.Visible then
CloseBossMenuFrame(bossFrame)
end
if char and char:GetAttribute("Type")~="Fishing Rod"then
pcall(function()
ToggleHotbar:InvokeServer("1")
end)
end
end
end
local lastMinigameEndTick=0
task.spawn(function()
local lastCastTry=0
local lastReelFire=0
local lastSkillTry=0
local skillSeqIndex=1
local pendingSkillKey=nil
local wasMinigameActive=false
while task.wait(0.08)do
local now=os.clock()
RefreshGuiCache()
local isMinigame=FishingGui and FishingGui.Visible or false
if wasMinigameActive and not isMinigame then
lastMinigameEndTick=now
end
wasMinigameActive=isMinigame
local activeReel=MosCfg.AutoReel or MosCfg.AutoMiniGame or MosCfg.AutoBoss or MosCfg.AutoSecretBoss or MosCfg.AutoFarmIsland
local activeCast=MosCfg.AutoCast or MosCfg.AutoFarmIsland
local activeSkill=MosCfg.AutoSkill or MosCfg.AutoBoss or MosCfg.AutoSecretBoss or MosCfg.AutoFarmIsland
if not isMinigame then
skillSeqIndex=1
pendingSkillKey=nil
end
if activeReel and isMinigame and(now-lastReelFire>=(MosCfg.ReelDelay or 0.35))then
lastReelFire=now
pcall(function()
UpdateFishProgression:FireServer()
end)
end
if activeSkill and isMinigame then
local char=cachedChar
local order=MosCfg.SkillOrder
local orderCount=type(order)=="table"and#order or 0
if char and orderCount>0 then
if skillSeqIndex<1 or skillSeqIndex>orderCount then
skillSeqIndex=1
end
local readyIdx=nil
for step=1,orderCount do
local idx=((skillSeqIndex-1+(step-1))%orderCount)+1
local k=order[idx]
if IsSkillKeyReady(char,k)then
readyIdx=idx
break
end
end
if readyIdx then
skillSeqIndex=readyIdx
local currentKey=order[skillSeqIndex]
if IsGameAllowingSkill(char)and(now-lastSkillTry>=0.25)then
lastSkillTry=os.clock()
pendingSkillKey=currentKey
pcall(function()
UseSkill:FireServer(currentKey)
end)
skillSeqIndex=(skillSeqIndex%orderCount)+1
end
else
for step=1,orderCount do
local idx=((skillSeqIndex-1+(step-1))%orderCount)+1
if IsSkillSlotAvailable(char,order[idx])and not IsSkillOnCooldown(char,order[idx])then
skillSeqIndex=idx
break
end
end
end
end
end
if MosCfg.AutoBoss or MosCfg.AutoSecretBoss then
StepAutoBoss(cachedChar,isMinigame)
else
if not isMinigame then
StepAutoTPPos(cachedChar)
StepAutoFarmIsland(cachedChar)
end
if activeCast and not isMinigame then
local minCastInterval=(MosCfg.AutoCastMethod=="Instant")and 0.05 or math.clamp(tonumber(MosCfg.CastDelay)or 1,0,10)
if(now-lastMinigameEndTick>=minCastInterval)and(now-lastCastTry>=minCastInterval)then
local char=cachedChar
if char then
if char:GetAttribute("Type")~="Fishing Rod"then
lastCastTry=now
pcall(function()
ToggleHotbar:InvokeServer("1")
end)
elseif not char:GetAttribute("Fishing")then
local hrp=cachedHrp or char:FindFirstChild("HumanoidRootPart")
if hrp then
lastCastTry=now
pcall(function()
FishingEvent:FireServer(hrp.CFrame)
end)
end
end
end
end
end
end
end
end)
MosOnRemote("Slam",function(remote)
if(MosCfg.AutoMiniGame or MosCfg.AutoReel or MosCfg.AutoBoss or MosCfg.AutoSecretBoss or MosCfg.AutoFarmIsland)and remote then
task.wait(0.05)
local handled=false
pcall(function()
local tc=FishingGui and FishingGui:FindFirstChild("TrashCan")
local slamGui=tc and tc:FindFirstChild("Slam")
local btn=slamGui and slamGui:FindFirstChild("Button")
local line=btn and btn:FindFirstChild("Line")
if line then
line.Size=UDim2 .new(1,0,1,0)
end
if btn then
TriggerGuiButton(btn)
if not slamGui.Parent then
handled=true
end
end
if not handled then
remote:FireServer("Perfect")
if slamGui and slamGui.Parent then
slamGui:Destroy()
end
end
end)
end
end)
MosOnRemote("Charge",function(remote)
if(MosCfg.AutoMiniGame or MosCfg.AutoReel or MosCfg.AutoBoss or MosCfg.AutoSecretBoss or MosCfg.AutoFarmIsland)and remote then
task.wait(1.05)
pcall(function()
local tc=FishingGui and FishingGui:FindFirstChild("TrashCan")
local chargeGui=tc and tc:FindFirstChild("Charge")
local btn=chargeGui and chargeGui:FindFirstChild("Button")
if btn and chargeGui.Parent then
TriggerGuiButton(btn)
end
if chargeGui and chargeGui.Parent then
remote:FireServer()
chargeGui:Destroy()
end
end)
end
end)
local function clearPlayerESP()
for _,player in ipairs(Players:GetPlayers())do
local char=player.Character
if char then
local head=char:FindFirstChild("Head")
if head then
local esp=head:FindFirstChild("MosESP")
if esp then esp:Destroy()end
end
end
end
end
local function updateESP()
if not MosCfg.ESPEnabled then return end
for _,player in ipairs(Players:GetPlayers())do
if player~=LocalPlayer then
local char=player.Character
if char then
local head=char:FindFirstChild("Head")
local hum=char:FindFirstChildOfClass("Humanoid")
if head and hum then
local esp=head:FindFirstChild("MosESP")
if hum.Health>0 then
if not esp then
esp=Instance.new("BillboardGui")
esp.Name="MosESP"
esp.Adornee=head
esp.Size=UDim2 .new(0,200,0,25)
esp.StudsOffset=Vector3 .new(0,2.5,0)
esp.AlwaysOnTop=true
esp.MaxDistance=math.huge
local text=Instance.new("TextLabel")
text.Name="NameText"
text.Parent=esp
text.Size=UDim2 .new(1,0,1,0)
text.BackgroundTransparency=1
text.TextScaled=false
text.TextSize=13
text.Font=Enum.Font.GothamBold
text.TextColor3=Color3 .fromRGB(255,255,255)
text.TextStrokeTransparency=0
text.TextStrokeColor3=Color3 .fromRGB(0,0,0)
text.TextXAlignment=Enum.TextXAlignment.Center
esp.Parent=head
end
esp.NameText.Text=player.DisplayName
else
if esp then esp:Destroy()end
end
end
end
end
end
end
task.spawn(function()
while task.wait(0.4)do
if MosCfg.ESPEnabled then
updateESP()
end
end
end)
local lastSellTime=0
local lastBuyBaitTime=0
local RemotesFolder=ReplicatedStorage:FindFirstChild("Remotes")
local function FindRemote(name)
return Events:FindFirstChild(name)or(RemotesFolder and RemotesFolder:FindFirstChild(name))
end
local function FireOrInvokeEvent(ev,...)
if not ev then return false end
local args={...}
local ok=pcall(function()
if ev:IsA("RemoteEvent")then
ev:FireServer(unpack(args))
elseif ev:IsA("RemoteFunction")then
ev:InvokeServer(unpack(args))
end
end)
return ok
end
local function DoBuyBait(baitName,amount)
if not baitName or baitName==""then return end
local amt=math.max(1,math.floor(tonumber(amount)or 1))
local buyEvent=FindRemote("BuyBait")or FindRemote("Bait")or FindRemote("PurchaseBait")or FindRemote("BaitShop")or FindRemote("BuyItem")
if buyEvent then
FireOrInvokeEvent(buyEvent,baitName,amt)
else
pcall(function()
CraftBaitEvent:FireServer(baitName,amt)
end)
end
end
task.spawn(function()
while task.wait(0.8)do
if MosCfg.AutoSell then
local now=os.clock()
local shouldSell=false
if MosCfg.AutoSellMethod=="Spam"then
shouldSell=(now-lastSellTime>=1)
elseif MosCfg.AutoSellMethod=="Sell When Full Inventory"then
shouldSell=(now-lastSellTime>=1.5)and(MosX.IsInventoryFull~=nil)and MosX.IsInventoryFull()
else
shouldSell=(now-lastSellTime>=(math.clamp(tonumber(MosCfg.SellDelay)or 1,1,10)*60))
end
if shouldSell then
lastSellTime=now
pcall(function()
SellFish:FireServer("All")
end)
end
end
if MosCfg.AutoBuyBait and MosCfg.SelectedBuyBait~=""then
local delaySec=math.max(1,tonumber(MosCfg.BuyBaitDelay)or 1)*60
local now=os.clock()
if now-lastBuyBaitTime>=delaySec then
lastBuyBaitTime=now
DoBuyBait(MosCfg.SelectedBuyBait,MosCfg.BuyBaitAmount)
end
end
if MosCfg.AutoCraftBait and MosCfg.SelectedBait~=""then
pcall(function()
CraftBaitEvent:FireServer(MosCfg.SelectedBait,math.max(1,math.floor(tonumber(MosCfg.BaitAmount)or 1)))
end)
end
if MosCfg.AutoCraftRod and MosCfg.SelectedRod~=""then
pcall(function()
CraftRodEvent:FireServer(MosCfg.SelectedRod)
end)
end
end
end)
local lastTicketQuestTime=0
local ChooseDialogueOption=Events:WaitForChild("ChooseDialogueOption",5)
local function HideTicketDialogueUI()
local pg=LocalPlayer:FindFirstChild("PlayerGui")
local mg=pg and pg:FindFirstChild("MainGui")
local menu=mg and mg:FindFirstChild("Menu")
local dialogue=menu and menu:FindFirstChild("Dialogue")
if dialogue and dialogue.Visible then
local nameLabel=dialogue:FindFirstChild("Name",true)or dialogue:FindFirstChild("NPCName",true)or dialogue:FindFirstChild("Title",true)
local dName=nameLabel and tostring(nameLabel.Text)or""
if dName==""or string.find(dName,"Ticket",1,true)or string.find(dName,"Giver",1,true)then
dialogue.Visible=false
end
end
end
local function GetTicketQuestGiverPart()
local npcFolder=workspace:FindFirstChild("NPC")
local funcFolder=npcFolder and npcFolder:FindFirstChild("Function")
local giver=funcFolder and funcFolder:FindFirstChild("Ticket Quest Giver")
if giver then return giver end
return nil
end
local function GetActiveTicketQuest()
local pData=PlayerData
if not pData then return nil end
local qFolder=pData:FindFirstChild("Quest")
local mainFolder=qFolder and qFolder:FindFirstChild("Main")
if mainFolder then
local tq=mainFolder:FindFirstChild("Hard Ticket Quest")
or mainFolder:FindFirstChild("Easy Ticket Quest")
or mainFolder:FindFirstChild("Ticket Quest")
if tq then return tq end
end
for _,child in ipairs(pData:GetChildren())do
if child:IsA("Folder")and(child.Name=="Hard Ticket Quest"or child.Name=="Easy Ticket Quest"or child.Name=="Ticket Quest")then
return child
end
end
return nil
end
local function IsTicketQuestCompleted(tq)
if not tq then return false end
local infoMain=Info and Info:FindFirstChild("MainQuest")
local questInfo=nil
if infoMain and infoMain:FindFirstChild(tq.Name)then
pcall(function()
questInfo=require(infoMain[tq.Name])
end)
end
local hasObjectives=false
for _,child in ipairs(tq:GetChildren())do
if child:IsA("NumberValue")then
hasObjectives=true
local targetVal=nil
if questInfo and questInfo[tonumber(child.Name)]then
targetVal=tonumber(questInfo[tonumber(child.Name)][2])
elseif tq:FindFirstChild("Objective")then
local objVal=tq.Objective:FindFirstChild(child.Name)
if objVal and objVal:IsA("StringValue")then
local parts=string.split(objVal.Value,",")
targetVal=tonumber(parts[2])
end
end
if targetVal and child.Value<targetVal then
return false
end
end
end
return hasObjectives
end
local function GetTicketQuestState()
local tq=GetActiveTicketQuest()
if not tq then
return"none"
end
if IsTicketQuestCompleted(tq)then
return"completed"
else
return"in_progress"
end
end
local StepSmartTicketQuest
do
local questCooldownUntil=0
local lastAcceptAttempt=0
local lastTurnInAttempt=0
local lastRecordedCooldownText=""
local dailyLimitReached=false
local lastLimitNotificationTick=0
function MosX.ResetTicketLimit()
dailyLimitReached=false
lastLimitNotificationTick=0
end
local function IsDailyLimitText(text)
if not text or text==""then return false end
local lower=string.lower(text)
return string.find(lower,"hit the daily limit of 20 ticket quests",1,true)~=nil
and string.find(lower,"come back tomorrow",1,true)~=nil
end
local function DisableAutoTicketQuest()
if dailyLimitReached then return end
dailyLimitReached=true
MosCfg.AutoTicketQuest=false
MosSave()
if MosX.TicketToggle then
pcall(function()MosX.TicketToggle:SetValue(false)end)
end
local now=os.clock()
if now-lastLimitNotificationTick>=5 then
lastLimitNotificationTick=now
pcall(function()
Fluent:Notify({
Title="Ticket Quest",
Content="Daily limit of 20 ticket quests reached",
Duration=4
})
end)
end
end
local function ParseCooldownSeconds(text)
if not text or text==""then return nil end
local lower=string.lower(text)
if string.find(lower,"another quest in")or string.find(lower,"take another quest in")then
local m,s=string.match(lower,"(%d+)%s*:%s*(%d+)")
if m and s then
return(tonumber(m)or 0)*60+(tonumber(s)or 0)
end
local mPart=string.match(lower,"(%d+)%s*m")
local sPart=string.match(lower,"(%d+)%s*s")
if mPart or sPart then
return(tonumber(mPart)or 0)*60+(tonumber(sPart)or 0)
end
end
return nil
end
local function CheckAndSetCooldown(text)
if not MosCfg.AutoTicketQuest or not text or text==""or dailyLimitReached or#text>300 then return end
if IsDailyLimitText(text)then
if MosCfg.AutoTicketQuest then
DisableAutoTicketQuest()
end
return
end
if text==lastRecordedCooldownText then return end
local sec=ParseCooldownSeconds(text)
if sec and sec>0 and sec<=3600 then
lastRecordedCooldownText=text
questCooldownUntil=os.clock()+sec
end
end
local function TurnInTicketQuest(giver)
local g=giver or GetTicketQuestGiverPart()
if not g then return end
local turnInArgs={
[1]="Ticket Quest Giver",
[2]=1,
[3]="Quest",
[4]={
[1]=g
}
}
pcall(function()
if ChooseDialogueOption then ChooseDialogueOption:FireServer(unpack(turnInArgs))end
end)
HideTicketDialogueUI()
lastTurnInAttempt=os.clock()
end
local function AcceptTicketQuest(giver)
local g=giver or GetTicketQuestGiverPart()
if not g then return end
local acceptOption=(MosCfg.TicketQuestMode=="Easy")and"EasyAcceptQuest"or"HardAcceptQuest"
local acceptIndex=(MosCfg.TicketQuestMode=="Easy")and 1 or 2
local acceptArgs={
[1]="Ticket Quest Giver",
[2]=acceptIndex,
[3]=acceptOption,
[4]={
[1]=g,
[2]="Ticket Quest"
}
}
pcall(function()
if ChooseDialogueOption then ChooseDialogueOption:FireServer(unpack(acceptArgs))end
end)
HideTicketDialogueUI()
lastAcceptAttempt=os.clock()
end
function StepSmartTicketQuest()
if dailyLimitReached then
return
end
local pg=LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")
local mg=pg and pg:FindFirstChild("MainGui")
local menu=mg and mg:FindFirstChild("Menu")
local dialogue=menu and menu:FindFirstChild("Dialogue")
if dialogue and dialogue.Visible then
for _,d in ipairs(dialogue:GetDescendants())do
if d:IsA("TextLabel")and IsDailyLimitText(d.Text)then
DisableAutoTicketQuest()
HideTicketDialogueUI()
return
end
end
end
local now=os.clock()
if now<questCooldownUntil then
return
end
local giver=GetTicketQuestGiverPart()
if not giver then return end
local state=GetTicketQuestState()
if state=="completed"then
if now-lastTurnInAttempt>=1.5 then
TurnInTicketQuest(giver)
task.wait(0.5)
AcceptTicketQuest(giver)
end
elseif state=="in_progress"then
return
else
if now>=questCooldownUntil and(now-lastAcceptAttempt>=2)then
TurnInTicketQuest(giver)
task.wait(0.4)
AcceptTicketQuest(giver)
end
end
end
pcall(function()
local pg=LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")
if pg then
pg.DescendantAdded:Connect(function(desc)
if desc:IsA("TextLabel")then
CheckAndSetCooldown(desc.Text)
desc:GetPropertyChangedSignal("Text"):Connect(function()
CheckAndSetCooldown(desc.Text)
end)
end
end)
end
end)
pcall(function()
for _,ev in ipairs(Events:GetChildren())do
if ev:IsA("RemoteEvent")then
ev.OnClientEvent:Connect(function(...)
local args={...}
for _,a in ipairs(args)do
if type(a)=="string"then
CheckAndSetCooldown(a)
elseif type(a)=="table"then
for _,sub in pairs(a)do
if type(sub)=="string"then
CheckAndSetCooldown(sub)
end
end
end
end
end)
end
end
end)
pcall(function()
local startDialogueEvent=Events:FindFirstChild("StartDialogue")
if startDialogueEvent and startDialogueEvent:IsA("RemoteEvent")then
startDialogueEvent.OnClientEvent:Connect(function(dialogueName,npcModel,dialogueData)
if not MosCfg.AutoTicketQuest or dailyLimitReached then return end
if tostring(dialogueName)=="Ticket Quest Giver"or(npcModel and npcModel.Name=="Ticket Quest Giver")then
HideTicketDialogueUI()
if type(dialogueData)=="table"and type(dialogueData[1])=="string"then
CheckAndSetCooldown(dialogueData[1])
end
end
end)
end
end)
end
local function GetZengTianguoPart()
local npcFolder=workspace:FindFirstChild("NPC")
local funcFolder=npcFolder and npcFolder:FindFirstChild("Function")
local giver=funcFolder and funcFolder:FindFirstChild("Zeng Tianguo")
if giver then return giver end
return nil
end
local function GetActiveZengTianguoQuest()
local pData=PlayerData or(DataFolder and DataFolder:FindFirstChild(tostring(LocalPlayer.UserId)))
if not pData then return nil end
local qFolder=pData:FindFirstChild("Quest")
local mainFolder=qFolder and qFolder:FindFirstChild("Main")
local containers={
mainFolder,
qFolder,
pData
}
for _,c in ipairs(containers)do
if c then
for _,child in ipairs(c:GetChildren())do
if child:IsA("Folder")or child:IsA("Configuration")then
local lower=string.lower(child.Name)
if string.find(lower,"zeng",1,true)and string.find(lower,"tianguo",1,true)then
return child
end
end
end
end
end
local mg=LocalPlayer:FindFirstChild("PlayerGui")and LocalPlayer.PlayerGui:FindFirstChild("MainGui")
local mq=mg and mg:FindFirstChild("Menu")and mg.Menu:FindFirstChild("Quest")and mg.Menu.Quest:FindFirstChild("Menu")and mg.Menu.Quest.Menu:FindFirstChild("Main_Quest")
if mq then
for _,child in ipairs(mq:GetChildren())do
if child:IsA("GuiObject")and child.Visible and child.Name~="Template"then
local lower=string.lower(child.Name)
if string.find(lower,"zeng",1,true)and string.find(lower,"tianguo",1,true)then
if mainFolder then
return mainFolder:FindFirstChild(child.Name)or child
end
return child
end
end
end
end
return nil
end
local function IsZengTianguoQuestCompleted(zq)
if not zq then return false end
local infoMain=Info and Info:FindFirstChild("MainQuest")
local questInfo=nil
if infoMain then
local qMod=infoMain:FindFirstChild(zq.Name)or infoMain:FindFirstChild("Zeng Tianguo")or infoMain:FindFirstChild("Zeng Tianguo Quest")
if qMod then
pcall(function()
questInfo=require(qMod)
end)
end
end
local hasObjectives=false
for _,child in ipairs(zq:GetChildren())do
if child:IsA("NumberValue")then
hasObjectives=true
local targetVal=nil
if questInfo and questInfo[tonumber(child.Name)]then
targetVal=tonumber(questInfo[tonumber(child.Name)][2])
elseif zq:FindFirstChild("Objective")then
local objVal=zq.Objective:FindFirstChild(child.Name)
if objVal and objVal:IsA("StringValue")then
local parts=string.split(objVal.Value,",")
targetVal=tonumber(parts[2])
end
end
if targetVal and child.Value<targetVal then
return false
end
end
end
if not hasObjectives then
local mg=LocalPlayer:FindFirstChild("PlayerGui")and LocalPlayer.PlayerGui:FindFirstChild("MainGui")
local mq=mg and mg:FindFirstChild("Menu")and mg.Menu:FindFirstChild("Quest")and mg.Menu.Quest:FindFirstChild("Menu")and mg.Menu.Quest.Menu:FindFirstChild("Main_Quest")
local frame=mq and(mq:FindFirstChild(zq.Name)or mq:FindFirstChild("Zeng Tianguo")or mq:FindFirstChild("Zeng Tianguo Quest"))
if frame then
local qFrame=frame:FindFirstChild("Quest")
if qFrame then
local allGreen=true
local foundStats=false
for _,stat in ipairs(qFrame:GetChildren())do
if stat:IsA("TextLabel")and stat.Name~="Title"and stat.Visible then
foundStats=true
if stat.TextColor3~=Color3 .fromRGB(144,255,110)then
allGreen=false
break
end
end
end
if foundStats then
return allGreen
end
end
end
end
return hasObjectives
end
local function HideZengTianguoDialogueUI()
local pg=LocalPlayer:FindFirstChild("PlayerGui")
local mg=pg and pg:FindFirstChild("MainGui")
local menu=mg and mg:FindFirstChild("Menu")
local dialogue=menu and menu:FindFirstChild("Dialogue")
if dialogue and dialogue.Visible then
local nameLabel=dialogue:FindFirstChild("Name",true)or dialogue:FindFirstChild("NPCName",true)or dialogue:FindFirstChild("Title",true)
local dName=nameLabel and tostring(nameLabel.Text)or""
if dName==""or string.find(dName,"Zeng",1,true)or string.find(dName,"Tianguo",1,true)then
dialogue.Visible=false
end
end
end
local StepSmartZengTianguoQuest
do
local lastActionTick=0
local function IsTargetZengTianguoQuest(zq)
local mg=LocalPlayer:FindFirstChild("PlayerGui")and LocalPlayer.PlayerGui:FindFirstChild("MainGui")
local menu=mg and mg:FindFirstChild("Menu")
local qMenu=menu and menu:FindFirstChild("Quest")
local innerMenu=qMenu and qMenu:FindFirstChild("Menu")
local mainQuestFrame=innerMenu and innerMenu:FindFirstChild("Main_Quest")
local zqName=zq and zq.Name or"Zeng Tianguo Quest"
local frame=mainQuestFrame and(mainQuestFrame:FindFirstChild(zqName)or mainQuestFrame:FindFirstChild("Zeng Tianguo")or mainQuestFrame:FindFirstChild("Zeng Tianguo Quest"))
if not frame and mainQuestFrame then
for _,child in ipairs(mainQuestFrame:GetChildren())do
if child:IsA("GuiObject")and child.Visible and child.Name~="Template"then
local lower=string.lower(child.Name)
if string.find(lower,"zeng",1,true)and string.find(lower,"tianguo",1,true)then
frame=child
break
end
end
end
end
if frame then
for _,desc in ipairs(frame:GetDescendants())do
if desc:IsA("TextLabel")and desc.Visible then
local txt=string.lower(desc.Text)
if string.find(txt,"use any skill",1,true)or string.find(txt,"skill for 100",1,true)then
return true
end
end
end
return false
end
if not zq then return false end
local infoMain=Info and Info:FindFirstChild("MainQuest")
local questInfo=nil
if infoMain then
local qMod=infoMain:FindFirstChild(zq.Name)or infoMain:FindFirstChild("Zeng Tianguo")or infoMain:FindFirstChild("Zeng Tianguo Quest")
if qMod then
pcall(function()
questInfo=require(qMod)
end)
end
end
if questInfo and type(questInfo)=="table"then
for _,entry in pairs(questInfo)do
if type(entry)=="table"then
local str=string.lower(table.concat(entry," "))
if string.find(str,"use any skill",1,true)or string.find(str,"skill for 100",1,true)then
return true
end
elseif type(entry)=="string"then
local str=string.lower(entry)
if string.find(str,"use any skill",1,true)or string.find(str,"skill for 100",1,true)then
return true
end
end
end
end
local objFolder=zq:FindFirstChild("Objective")
if objFolder then
for _,obj in ipairs(objFolder:GetChildren())do
local str=string.lower(tostring(obj.Name).." "..tostring(obj.Value))
if string.find(str,"use any skill",1,true)or string.find(str,"skill for 100",1,true)then
return true
end
end
end
for _,child in ipairs(zq:GetChildren())do
local str=string.lower(tostring(child.Name))
if string.find(str,"use any skill",1,true)or string.find(str,"skill for 100",1,true)then
return true
end
if child:IsA("StringValue")then
local valStr=string.lower(tostring(child.Value))
if string.find(valStr,"use any skill",1,true)or string.find(valStr,"skill for 100",1,true)then
return true
end
end
end
return false
end
local function CancelZengTianguoQuest(zq)
pcall(function()
local cancelEv=Events:WaitForChild("CancelQuest",3)
if cancelEv then
cancelEv:FireServer("Zeng Tianguo Quest")
end
end)
local mg=LocalPlayer:FindFirstChild("PlayerGui")and LocalPlayer.PlayerGui:FindFirstChild("MainGui")
local menu=mg and mg:FindFirstChild("Menu")
local qMenu=menu and menu:FindFirstChild("Quest")
local innerMenu=qMenu and qMenu:FindFirstChild("Menu")
local mainQuestFrame=innerMenu and innerMenu:FindFirstChild("Main_Quest")
local framesToCheck={
mainQuestFrame and mainQuestFrame:FindFirstChild("Zeng Tianguo Quest"),
mainQuestFrame and mainQuestFrame:FindFirstChild("Zeng Tianguo"),
innerMenu and innerMenu:FindFirstChild("Zeng Tianguo Quest"),
innerMenu and innerMenu:FindFirstChild("Zeng Tianguo"),
qMenu and qMenu:FindFirstChild("Zeng Tianguo Quest"),
qMenu and qMenu:FindFirstChild("Zeng Tianguo"),
}
for _,f in ipairs(framesToCheck)do
if f then
for _,desc in ipairs(f:GetDescendants())do
if desc:IsA("TextButton")or desc:IsA("ImageButton")then
local txt=desc:IsA("TextButton")and string.lower(desc.Text)or""
local nm=string.lower(desc.Name)
if string.find(txt,"cancel",1,true)or string.find(nm,"cancel",1,true)then
TriggerGuiButton(desc)
end
end
end
end
end
end
local function InteractZengTianguo(giver)
local g=giver or GetZengTianguoPart()
if not g then return end
local args1={
[1]="Zeng Tianguo",
[2]=1,
[3]="Quest",
[4]={
[1]=g
}
}
local args2={
[1]="Zeng Tianguo",
[2]=1,
[3]="AcceptQuest",
[4]={
[1]=g,
[2]="Zeng Tianguo Quest"
}
}
pcall(function()
if ChooseDialogueOption then ChooseDialogueOption:FireServer(unpack(args1))end
end)
task.wait(0.3)
pcall(function()
if ChooseDialogueOption then ChooseDialogueOption:FireServer(unpack(args2))end
end)
HideZengTianguoDialogueUI()
lastActionTick=os.clock()
end
function StepSmartZengTianguoQuest()
local now=os.clock()
if now-lastActionTick<3 then
return
end
local zq=GetActiveZengTianguoQuest()
if zq then
if MosCfg.AutoFilterZengQuest and not IsTargetZengTianguoQuest(zq)then
CancelZengTianguoQuest(zq)
lastActionTick=now
task.wait(0.3)
local giver=GetZengTianguoPart()
if giver then
InteractZengTianguo(giver)
end
return
end
if IsZengTianguoQuestCompleted(zq)then
local giver=GetZengTianguoPart()
if giver then
InteractZengTianguo(giver)
end
end
return
end
local giver=GetZengTianguoPart()
if giver then
InteractZengTianguo(giver)
end
end
pcall(function()
local startDialogueEvent=Events:FindFirstChild("StartDialogue")
if startDialogueEvent and startDialogueEvent:IsA("RemoteEvent")then
startDialogueEvent.OnClientEvent:Connect(function(dialogueName,npcModel)
if not(MosCfg.AutoZengTianguoQuest or MosCfg.AutoFilterZengQuest)then return end
if tostring(dialogueName)=="Zeng Tianguo"or(npcModel and npcModel.Name=="Zeng Tianguo")then
HideZengTianguoDialogueUI()
end
end)
end
end)
end
local StepAutoEquipBestBait
do
local function CleanBaitName(str)
if not str or str==""then return""end
local clean=string.split(str,"|")[1]or str
return string.gsub(clean,"^%s*(.-)%s*$","%1")
end
local function GetSafeItemCount(obj)
if not obj then return 0 end
local count=0
pcall(function()
if obj:IsA("ValueBase")then
count=tonumber(obj.Value)or 0
end
end)
if count and count>0 then return count end
pcall(function()
local q=obj:FindFirstChild("Quantity")or obj:FindFirstChild("Count")or obj:FindFirstChild("Value")or obj:FindFirstChild("Amount")
if q and q:IsA("ValueBase")then
count=tonumber(q.Value)or 0
end
end)
if count and count>0 then return count end
pcall(function()
local attr=obj:GetAttribute("Quantity")or obj:GetAttribute("Count")or obj:GetAttribute("Amount")or obj:GetAttribute("Value")
if attr then
count=tonumber(attr)or 0
end
end)
if count and count>0 then return count end
pcall(function()
if obj:IsA("BoolValue")and obj.Value==true then
count=1
end
end)
return count or 0
end
local function GetBaitLuck(cleanName)
local infoBait=Info and Info:FindFirstChild("Bait")
if not infoBait or not cleanName or cleanName==""then return 0 end
local mod=infoBait:FindFirstChild(cleanName)
if not mod or not mod:IsA("ModuleScript")then return 0 end
local luck=0
local success,data=pcall(require,mod)
if success and type(data)=="table"and data.Luck~=nil then
local num=tonumber(data.Luck)
if not num then
local str=tostring(data.Luck)
local cleanStr=string.match(str,"%d+%.?%d*")
num=tonumber(cleanStr)
end
luck=num or 0
end
return luck
end
local function GetBestOwnedBait()
local pData=PlayerData
if not pData then return nil end
local infoBait=Info and Info:FindFirstChild("Bait")
if not infoBait then return nil end
local bestName=nil
local bestRawName=nil
local bestLuck=-1
local bestCount=0
local bestSource=nil
local bestInst=nil
local function consider(rawName,count,inst,src)
local c=tonumber(count)or 0
if c>0 then
local clean=CleanBaitName(rawName)
if infoBait:FindFirstChild(clean)then
local luck=GetBaitLuck(clean)
if luck>bestLuck then
bestLuck=luck
bestName=clean
bestRawName=rawName
bestCount=c
bestSource=src
bestInst=inst
elseif not bestName then
bestName=clean
bestRawName=rawName
bestCount=c
bestSource=src
bestInst=inst
end
end
end
end
local baitFolder=pData:FindFirstChild("Bait")
if baitFolder then
for _,child in ipairs(baitFolder:GetChildren())do
local cnt=GetSafeItemCount(child)
if cnt>0 then
consider(child.Name,cnt,child,"Bait")
end
end
end
local invFolder=pData:FindFirstChild("Inventory")
if invFolder then
for _,child in ipairs(invFolder:GetChildren())do
local clean=CleanBaitName(child.Name)
if infoBait:FindFirstChild(clean)then
local cnt=GetSafeItemCount(child)
if cnt<=0 then cnt=1 end
consider(child.Name,cnt,child,"Inventory")
end
end
end
return bestName,bestRawName,bestLuck,bestCount,bestSource,bestInst
end
local BaitImageMap={}
local function InitBaitImageMap()
local infoBait=Info and Info:FindFirstChild("Bait")
if not infoBait then return end
for _,bMod in ipairs(infoBait:GetChildren())do
if bMod:IsA("ModuleScript")then
local success,data=pcall(require,bMod)
if success and type(data)=="table"and data.Image then
local rawImg=tostring(data.Image)
BaitImageMap[rawImg]=bMod.Name
BaitImageMap[string.lower(rawImg)]=bMod.Name
local numId=string.match(rawImg,"%d+")
if numId then
BaitImageMap[numId]=bMod.Name
end
end
end
end
end
task.spawn(InitBaitImageMap)
local function GetSlot2Quantity()
local qty=-1
pcall(function()
local mainGui=LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")and LocalPlayer.PlayerGui:FindFirstChild("MainGui")
local hotbarList=mainGui and mainGui:FindFirstChild("Main")and mainGui.Main:FindFirstChild("Hotbar")and mainGui.Main.Hotbar:FindFirstChild("List")
local btn2=hotbarList and hotbarList:FindFirstChild("2")
if btn2 then
local qLabel=btn2:FindFirstChild("Quantity")or(btn2:FindFirstChild("Quantity_BG")and btn2 .Quantity_BG:FindFirstChild("Quantity"))or(btn2:FindFirstChild("Detail")and btn2 .Detail:FindFirstChild("Quantity"))or(btn2:FindFirstChild("Inner")and btn2 .Inner:FindFirstChild("Quantity"))
if qLabel and qLabel:IsA("TextLabel")then
if not qLabel.Visible or qLabel.Text==""then
qty=0
else
local n=string.match(qLabel.Text,"%d+")
qty=tonumber(n)or 0
end
end
end
end)
if qty==-1 and PlayerData then
pcall(function()
local hb=PlayerData:FindFirstChild("Hotbar")
local slot2=hb and hb:FindFirstChild("2")
if slot2 then
local q=slot2:FindFirstChild("Quantity")
if q and q:IsA("ValueBase")then
qty=tonumber(q.Value)or 0
end
end
end)
end
return math.max(0,qty)
end
local function GetEquippedBaitName()
if not next(BaitImageMap)then
InitBaitImageMap()
end
local foundName=nil
pcall(function()
local mainGui=LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")and LocalPlayer.PlayerGui:FindFirstChild("MainGui")
local hotbarList=mainGui and mainGui:FindFirstChild("Main")and mainGui.Main:FindFirstChild("Hotbar")and mainGui.Main.Hotbar:FindFirstChild("List")
local btn2=hotbarList and hotbarList:FindFirstChild("2")
if btn2 then
local img=btn2:FindFirstChild("Image")or(btn2:FindFirstChild("Inner")and btn2 .Inner:FindFirstChild("Image"))
if not img then
img=btn2:FindFirstChildWhichIsA("ImageLabel",true)
end
if img and img.Visible and img.Image~=""then
local raw=tostring(img.Image)
local num=string.match(raw,"%d+")
if num and BaitImageMap[num]then
foundName=BaitImageMap[num]
elseif BaitImageMap[raw]then
foundName=BaitImageMap[raw]
elseif BaitImageMap[string.lower(raw)]then
foundName=BaitImageMap[string.lower(raw)]
end
end
if not foundName then
for _,desc in ipairs(btn2:GetDescendants())do
if desc:IsA("TextLabel")and desc.Text~=""then
local cl=CleanBaitName(desc.Text)
if Info and Info:FindFirstChild("Bait")and Info.Bait:FindFirstChild(cl)then
foundName=cl
break
end
end
local attr=desc:GetAttribute("ItemName")or desc:GetAttribute("Bait")
if attr and tostring(attr)~=""then
local cl=CleanBaitName(tostring(attr))
if Info and Info:FindFirstChild("Bait")and Info.Bait:FindFirstChild(cl)then
foundName=cl
break
end
end
end
end
local qLabel=btn2:FindFirstChild("Quantity")or(btn2:FindFirstChild("Quantity_BG")and btn2 .Quantity_BG:FindFirstChild("Quantity"))or(btn2:FindFirstChild("Detail")and btn2 .Detail:FindFirstChild("Quantity"))or(btn2:FindFirstChild("Inner")and btn2 .Inner:FindFirstChild("Quantity"))
if qLabel and qLabel:IsA("TextLabel")then
if not qLabel.Visible or qLabel.Text==""or qLabel.Text=="x0"or qLabel.Text=="0"then
foundName=nil
end
end
end
end)
if not foundName and PlayerData then
pcall(function()
local hb=PlayerData:FindFirstChild("Hotbar")
local slot2=hb and hb:FindFirstChild("2")
if slot2 then
local vn=slot2:FindFirstChild("ValueName")
local q=slot2:FindFirstChild("Quantity")
local cnt=q and tonumber(q.Value)or 0
if vn and vn.Value~=""and cnt>0 then
local cl=CleanBaitName(vn.Value)
if Info and Info:FindFirstChild("Bait")and Info.Bait:FindFirstChild(cl)then
foundName=cl
end
end
end
if not foundName then
local bVal=PlayerData:FindFirstChild("EquippedBait")or PlayerData:FindFirstChild("CurrentBait")
if bVal and bVal:IsA("StringValue")and bVal.Value~=""then
foundName=CleanBaitName(bVal.Value)
end
end
if not foundName then
local attr=PlayerData:GetAttribute("EquippedBait")or PlayerData:GetAttribute("Bait")
if attr and tostring(attr)~=""then
foundName=CleanBaitName(tostring(attr))
end
end
end)
end
return foundName
end
local lastEquipTime=0
function StepAutoEquipBestBait(force)
if not MosCfg.AutoEquipBestBait and not force then return end
local now=os.clock()
if not force and now-lastEquipTime<2 then return end
local bestBait,bestRaw,bestLuck,bestCount=GetBestOwnedBait()
if not bestBait or bestCount<=0 then
if force then
pcall(function()
Fluent:Notify({
Title="Auto Equip Bait",
Content="No bait found in inventory",
Duration=3
})
end)
end
return
end
local curEquipped=GetEquippedBaitName()
local curQty=GetSlot2Quantity()
if not force and curEquipped==bestBait and curQty>0 then
return
end
lastEquipTime=now
local ev=EquipBaitEvent or(Events and Events:FindFirstChild("EquipBait"))or(Events and Events:WaitForChild("EquipBait",3))
if ev then
pcall(function()
if ev:IsA("RemoteFunction")then
ev:InvokeServer(bestBait)
elseif ev:IsA("RemoteEvent")then
ev:FireServer(bestBait)
else
ev:InvokeServer(bestBait)
end
end)
task.delay(0.3,function()
local checkEq=GetEquippedBaitName()
local checkQ=GetSlot2Quantity()
if checkQ<=0 and checkEq~=bestBait then
pcall(function()
if ev:IsA("RemoteFunction")then
ev:InvokeServer(bestBait)
elseif ev:IsA("RemoteEvent")then
ev:FireServer(bestBait)
else
ev:InvokeServer(bestBait)
end
end)
end
end)
end
pcall(function()
Fluent:Notify({
Title="Auto Equip Bait",
Content="Equipped "..bestBait.." - Luck "..bestLuck.."%",
Duration=3
})
end)
end
local function GetOwnedBaitByName(target)
if not PlayerData or not target or target==""then return nil end
local infoBait=Info and Info:FindFirstChild("Bait")
local want=string.lower(CleanBaitName(target))
local folder=PlayerData:FindFirstChild("Bait")
if folder then
for _,child in ipairs(folder:GetChildren())do
local clean=CleanBaitName(child.Name)
if string.lower(clean)==want then
local cnt=GetSafeItemCount(child)
if cnt>0 then return clean,cnt end
end
end
end
local inv=PlayerData:FindFirstChild("Inventory")
if inv then
for _,child in ipairs(inv:GetChildren())do
local clean=CleanBaitName(child.Name)
if string.lower(clean)==want and(not infoBait or infoBait:FindFirstChild(clean))then
local cnt=GetSafeItemCount(child)
return clean,(cnt>0)and cnt or 1
end
end
end
return nil
end
local lastPickedTime=0
function MosX.StepPickedBait(force)
if not MosCfg.AutoEquipPickedBait and not force then return end
local now=os.clock()
if not force and now-lastPickedTime<2 then return end
local want=MosCfg.SelectedEquipBait
if not want or want==""then return end
local curName=GetEquippedBaitName()
if not force and curName and string.lower(curName)==string.lower(want)and GetSlot2Quantity()>0 then
return
end
local owned=GetOwnedBaitByName(want)
if not owned then
if force then
pcall(function()
Fluent:Notify({Title="Auto Equip Bait",Content="No "..tostring(want).." in inventory",Duration=3})
end)
end
return
end
lastPickedTime=now
local ev=EquipBaitEvent or(Events and Events:FindFirstChild("EquipBait"))
if not ev then return end
local function fire()
task.spawn(function()
pcall(function()
if ev:IsA("RemoteFunction")then
ev:InvokeServer(owned)
else
ev:FireServer(owned)
end
end)
end)
end
fire()
task.delay(0.3,function()
local eq=GetEquippedBaitName()
if GetSlot2Quantity()<=0 and(not eq or string.lower(eq)~=string.lower(owned))then
fire()
end
end)
pcall(function()
Fluent:Notify({Title="Auto Equip Bait",Content="Equipped "..owned,Duration=3})
end)
end
LocalPlayer.CharacterAdded:Connect(function()
lastEquipTime=0
lastPickedTime=0
end)
end
do
local lastTry=0
local function UpgradeArgs(mode)
if mode=="Cash + Ticket"then
return{{"Cash","Ticket"}}
elseif mode=="Ticket + Level"then
return{{"Ticket","Level"}}
end
return{{"Cash","Level"}}
end
function MosX.UpgradeChar(mode)
local ev=Events:FindFirstChild("UpgradeCharacter")
if not ev then return false end
local a=UpgradeArgs(mode or MosCfg.UpgradeCharType)
task.spawn(function()
pcall(function()
if ev:IsA("RemoteFunction")then
ev:InvokeServer(unpack(a))
else
ev:FireServer(unpack(a))
end
end)
end)
return true
end
function MosX.StepUpgradeChar()
if not MosCfg.AutoUpgradeChar then return end
local now=os.clock()
local gap=(tonumber(MosCfg.UpgradeCharDelay)or 5)*60
if lastTry>0 and now-lastTry<gap then return end
lastTry=now
MosX.UpgradeChar(MosCfg.UpgradeCharType)
end
function MosX.ResetUpgradeTimer()
lastTry=0
end
end
task.spawn(function()
while task.wait(1)do
if MosX.Unloaded then break end
if MosCfg.AutoTicketQuest then
pcall(StepSmartTicketQuest)
end
if MosCfg.AutoZengTianguoQuest or MosCfg.AutoFilterZengQuest then
pcall(StepSmartZengTianguoQuest)
end
if MosCfg.AutoEquipBestBait then
pcall(StepAutoEquipBestBait)
elseif MosCfg.AutoEquipPickedBait then
pcall(MosX.StepPickedBait)
end
if MosCfg.AutoUpgradeChar then
pcall(MosX.StepUpgradeChar)
end
if MosCfg.AutoGiveFish and MosX.StepAutoGiveFish then
pcall(MosX.StepAutoGiveFish)
end
if MosCfg.AutoClaimDailyQuest and MosX.StepAutoClaimDailyQuest then
pcall(MosX.StepAutoClaimDailyQuest)
pcall(MosX.StepAutoClaimDailyReward)
end
end
end)
local function GetBuyableBaits()
local list={}
local seen={}
local baitFolder=Info:FindFirstChild("Bait")
if baitFolder then
for _,child in ipairs(baitFolder:GetChildren())do
local data=GetModuleData(child)
if data and not data.Ingredient then
seen[child.Name]=true
table.insert(list,child.Name)
end
end
end
local itemFolder=Info:FindFirstChild("Item")
if itemFolder then
for _,child in ipairs(itemFolder:GetChildren())do
if not seen[child.Name]then
local data=GetModuleData(child)
if data and data.Type=="Bait"and not data.Ingredient then
seen[child.Name]=true
table.insert(list,child.Name)
end
end
end
end
table.sort(list)
return list
end
local function GetCraftableBaits()
local list={}
local baitFolder=Info:FindFirstChild("Bait")
if baitFolder then
for _,child in ipairs(baitFolder:GetChildren())do
local data=GetModuleData(child)
if data and data.Ingredient then
table.insert(list,child.Name)
end
end
end
table.sort(list)
return list
end
local function GetCraftableRods()
local list={}
local invFolder=Info:FindFirstChild("Inventory")
if invFolder then
for _,child in ipairs(invFolder:GetChildren())do
local data=GetModuleData(child)
if data and data.Ingredient and data.Type=="Fishing Rod"then
table.insert(list,child.Name)
end
end
end
table.sort(list)
return list
end
local IslandTargets={}
local CanonicalIslandOrder={
["Beginning Isle"]=1,
["Bamboo Isle"]=2,
["Fallout Isle"]=3,
["Sovereign Isle"]=4,
["Perch Isle"]=5,
["Frost Isle"]=6,
["Coconut Isle"]=7,
["Amber Isle"]=8,
["Battlefield Isle"]=9,
["Mistpeak Isle"]=10,
["World Angler Isle"]=11,
["Weather Isle"]=12,
["Mystic Reef Isle"]=13
}
local CanonicalIslandPower={
["Beginning Isle"]=1,
["Bamboo Isle"]=19,
["Fallout Isle"]=32,
["Sovereign Isle"]=39,
["Perch Isle"]=48,
["Frost Isle"]=55,
["Coconut Isle"]=65,
["Amber Isle"]=75,
["Battlefield Isle"]=90,
["Mistpeak Isle"]=100,
["World Angler Isle"]=100,
["Weather Isle"]=100,
["Mystic Reef Isle"]=100
}
local function GetCanonicalIslandRank(name)
if CanonicalIslandOrder[name]then
return CanonicalIslandOrder[name]
end
local lowerName=string.lower(name)
for k,rank in pairs(CanonicalIslandOrder)do
local lk=string.lower(k)
if lowerName==lk or string.find(lowerName,lk,1,true)or string.find(lk,lowerName,1,true)then
return rank
end
end
return nil
end
local function GetCanonicalIslandPower(name)
if CanonicalIslandPower[name]then
return CanonicalIslandPower[name]
end
local lowerName=string.lower(name)
for k,pwr in pairs(CanonicalIslandPower)do
local lk=string.lower(k)
if lowerName==lk or string.find(lowerName,lk,1,true)or string.find(lk,lowerName,1,true)then
return pwr
end
end
return nil
end
local function GetIslandList()
local rawIslands={}
local seen={}
table.clear(IslandTargets)
local sp=workspace:FindFirstChild("Spawnpoint")
if not sp then return{}end
local startPart=sp:FindFirstChild("Beginning Isle")
local startPos=startPart and GetModelPart(startPart)and GetModelPart(startPart).Position or Vector3 .zero
local compassOrder={}
local compassPower={}
if MainGui then
local menu=MainGui:FindFirstChild("Menu")
local compass=menu and menu:FindFirstChild("Compass")
local areaList=compass and compass:FindFirstChild("AreaList")
if areaList then
for _,item in ipairs(areaList:GetChildren())do
if item:IsA("GuiObject")and item:FindFirstChild("Track")then
local powerVal=nil
for _,desc in ipairs(item:GetDescendants())do
if desc:IsA("TextLabel")and desc.Text then
local m=string.match(desc.Text,"Power:%s*(%d+)")
if m then
powerVal=tonumber(m)
break
end
end
end
if powerVal then
compassPower[item.Name]=powerVal
end
local orderScore=(powerVal or 999)*1000+(item.LayoutOrder or 0)
compassOrder[item.Name]=orderScore
end
end
end
end
for _,child in ipairs(sp:GetChildren())do
local part=GetModelPart(child)
if part and not seen[child.Name]then
seen[child.Name]=true
local rank=GetCanonicalIslandRank(child.Name)
local weight
if rank then
weight=rank
elseif compassOrder[child.Name]then
weight=1000+compassOrder[child.Name]
else
weight=1e7+(part.Position-startPos).Magnitude
end
local pwr=compassPower[child.Name]or GetCanonicalIslandPower(child.Name)
table.insert(rawIslands,{
name=child.Name,
part=part,
weight=weight,
power=pwr
})
end
end
table.sort(rawIslands,function(a,b)
if a.weight~=b.weight then
return a.weight<b.weight
end
return a.name<b.name
end)
local list={}
for _,entry in ipairs(rawIslands)do
local label=entry.power and(entry.name.." | "..tostring(entry.power))or entry.name
IslandTargets[label]=entry.part
IslandTargets[entry.name]=entry.part
table.insert(list,label)
end
return list
end
local function TeleportToIsland(islandName)
if not islandName or islandName==""then return end
if not IslandTargets[islandName]then
GetIslandList()
end
local targetPart=IslandTargets[islandName]
local char=LocalPlayer.Character
local hrp=char and char:FindFirstChild("HumanoidRootPart")
if hrp and targetPart then
hrp.CFrame=targetPart.CFrame+Vector3 .new(0,5,0)
end
end
local function TeleportUnderIslandWater(islandName)
if not islandName or islandName==""then return end
if not IslandTargets[islandName]then
GetIslandList()
end
local targetPart=IslandTargets[islandName]
if not targetPart then return end
local char=LocalPlayer.Character or cachedChar
local hrp=(char and char:FindFirstChild("HumanoidRootPart"))or cachedHrp
if not hrp then return end
local waterY=-25
local ocean=workspace:FindFirstChild("Ocean")
if ocean then
for _,child in ipairs(ocean:GetChildren())do
if child.Name=="Water"and child:IsA("BasePart")then
local topY=child.Position.Y+(child.Size.Y*0.5)
waterY=topY-12
break
end
end
end
local targetPos=Vector3 .new(targetPart.Position.X,math.min(waterY,targetPart.Position.Y-15),targetPart.Position.Z)
hrp.CFrame=CFrame.new(targetPos)
end
local NPCTargets={}
local function GetNPCList()
local list={}
local seen={}
table.clear(NPCTargets)
local function addNPC(name,part)
if not name or name==""then return end
local norm=string.lower(string.gsub(name,"%s+",""))
if norm=="longdiaohai"then
name="Long DiaoHai"
end
if part and part:IsDescendantOf(workspace)then
NPCTargets[name]=part
NPCTargets[norm]=part
end
if not seen[norm]then
seen[norm]=true
table.insert(list,name)
end
end
for _,folderName in ipairs({"Merchant","NPCDialogue","NPCPVP","NPC","BossSetUp"})do
local f=workspace:FindFirstChild(folderName)or ReplicatedStorage:FindFirstChild(folderName)
if f then
for _,child in ipairs(f:GetChildren())do
local name=tostring(child.Name)
if name~=""and name~="Lamp"and name~="Boss"and name~="God"then
local wsFolder=workspace:FindFirstChild(folderName)
local liveModel=wsFolder and wsFolder:FindFirstChild(name)
local part=liveModel and GetModelPart(liveModel)
addNPC(name,part)
elseif name=="Boss"or name=="God"then
for _,b in ipairs(child:GetChildren())do
local bName=tostring(b.Name)
if bName~=""and bName~="God"then
local wsFolder=workspace:FindFirstChild(folderName)
local wsSub=wsFolder and wsFolder:FindFirstChild(name)
local liveSub=wsSub and wsSub:FindFirstChild(bName)
local part=liveSub and GetModelPart(liveSub)
addNPC(bName,part)
end
end
end
end
end
end
local godFolder=workspace:FindFirstChild("God")or ReplicatedStorage:FindFirstChild("God")
if godFolder then
for _,child in ipairs(godFolder:GetChildren())do
local name=tostring(child.Name)
if name~=""and name~="Lamp"and name~="God"then
local liveModel=workspace:FindFirstChild("God")and workspace.God:FindFirstChild(name)
local part=liveModel and GetModelPart(liveModel)
addNPC(name,part)
end
end
end
addNPC("Long DiaoHai")
local priorityOrder={
"The Shadow","TheShadow","Shadow","???",
"Taoist","Taosi",
"Maoshan","Maosan",
"Long DiaoHai","LongDiaoHai","Longdiaohai",
"Enzo",
"Blue",
"Green",
"Yellow",
"Nanjiang",
"Zeng Tianguo"
}
local priorityRank={}
for rank,name in ipairs(priorityOrder)do
local lower=string.lower(string.gsub(name,"%s+",""))
if not priorityRank[lower]then
priorityRank[lower]=rank
end
end
local function getRank(name)
local lower=string.lower(string.gsub(tostring(name),"%s+",""))
return priorityRank[lower]or 9999
end
table.sort(list,function(a,b)
local rankA=getRank(a)
local rankB=getRank(b)
if rankA~=rankB then
return rankA<rankB
end
return tostring(a):lower()<tostring(b):lower()
end)
return list
end
local function TeleportToNPC(npcName)
if not npcName or npcName==""then return end
local lowerNpc=string.lower(string.gsub(tostring(npcName),"%s+",""))
local targetPart=nil
if lowerNpc=="blue"or lowerNpc=="green"or lowerNpc=="yellow"then
local godFolder=workspace:FindFirstChild("God")
if godFolder then
for _,child in ipairs(godFolder:GetChildren())do
local cLower=string.lower(string.gsub(tostring(child.Name),"%s+",""))
if cLower==lowerNpc then
targetPart=GetModelPart(child)
if targetPart and targetPart:IsDescendantOf(workspace)then
break
end
end
end
end
if not targetPart then
for _,child in ipairs(workspace:GetChildren())do
local cLower=string.lower(string.gsub(tostring(child.Name),"%s+",""))
if cLower==lowerNpc then
local p=GetModelPart(child)
if p and p:IsDescendantOf(workspace)then
targetPart=p
break
end
end
end
end
elseif string.find(lowerNpc,"longdiaohai")or lowerNpc=="enzo"then
local _,bossPart=FindBossTarget(string.find(lowerNpc,"longdiaohai")~=nil)
if bossPart and bossPart:IsDescendantOf(workspace)then
targetPart=bossPart
end
end
local candidates={}
if not targetPart then
for _,folderName in ipairs({"NPC","Merchant","NPCDialogue","NPCPVP","God","BossSetUp"})do
local wsFolder=workspace:FindFirstChild(folderName)
if wsFolder then
for _,desc in ipairs(wsFolder:GetDescendants())do
if(desc:IsA("Model")or desc:IsA("BasePart"))and not desc:IsA("Folder")and(desc.Name==npcName or desc:GetAttribute("Name")==npcName)and desc.Name~="God"then
local p=GetModelPart(desc)
if p and p:IsDescendantOf(workspace)then
table.insert(candidates,{folder=folderName,part=p})
end
end
end
end
end
end
if not targetPart and#candidates==0 then
local directWs=workspace:FindFirstChild(npcName)
if directWs then
local p=GetModelPart(directWs)
if p and p:IsDescendantOf(workspace)then
targetPart=p
end
end
end
if#candidates>0 then
if(npcName=="Maoshan"or npcName=="Taoist")and#candidates>1 then
local daShixiong=workspace:FindFirstChild("Da Shixiong",true)
local dsPart=daShixiong and GetModelPart(daShixiong)
for _,cand in ipairs(candidates)do
if cand.folder=="NPC"then
targetPart=cand.part
break
end
if dsPart and(cand.part.Position-dsPart.Position).Magnitude>15 then
targetPart=cand.part
break
end
end
end
if not targetPart then
targetPart=candidates[1].part
end
end
if not targetPart or not targetPart:IsDescendantOf(workspace)then
local cached=NPCTargets[npcName]or NPCTargets[lowerNpc]
if cached and cached:IsDescendantOf(workspace)then
targetPart=cached
end
end
if not targetPart or not targetPart:IsDescendantOf(workspace)then
pcall(function()
Fluent:Notify({
Title="Teleport NPC",
Content=npcName.." has not spawned on the map yet!",
Duration=4
})
end)
return
end
local char=LocalPlayer.Character or cachedChar
local hrp=(char and char:FindFirstChild("HumanoidRootPart"))or cachedHrp
if hrp and targetPart then
hrp.CFrame=targetPart.CFrame*CFrame.new(0,3,-4)
end
end
local function GetPlayerList()
local list={}
for _,plr in ipairs(Players:GetPlayers())do
if plr~=LocalPlayer then
table.insert(list,plr.Name)
end
end
table.sort(list,function(a,b)
return string.lower(a)<string.lower(b)
end)
return list
end
local function TeleportToPlayer(targetName)
if not targetName or targetName==""then return end
local targetPlr=Players:FindFirstChild(targetName)
if not targetPlr then
for _,plr in ipairs(Players:GetPlayers())do
if plr~=LocalPlayer and(string.lower(plr.Name)==string.lower(targetName)or string.lower(plr.DisplayName)==string.lower(targetName))then
targetPlr=plr
break
end
end
end
if not targetPlr then
pcall(function()
Fluent:Notify({
Title="Teleport Player",
Content="Player "..tostring(targetName).." not found!",
Duration=3
})
end)
return
end
local tChar=targetPlr.Character
local tHrp=tChar and(tChar:FindFirstChild("HumanoidRootPart")or tChar:FindFirstChild("Torso")or tChar:FindFirstChild("UpperTorso"))
if not tHrp then
pcall(function()
Fluent:Notify({
Title="Teleport Player",
Content=targetPlr.Name.." has no character spawned!",
Duration=3
})
end)
return
end
local char=LocalPlayer.Character or cachedChar
local hrp=(char and char:FindFirstChild("HumanoidRootPart"))or cachedHrp
if hrp then
hrp.CFrame=tHrp.CFrame*CFrame.new(0,2,3)
end
end
local KnownCodes={
"HWF","Welcome","VermilionBird","PVP","AXO","SeeYouSoon","BUGTrait",
"80KLikes","65KLikes","60KLikes","50KLikes",
"55MVisits","41MVisits","40MVisits","39MVisits","38MVisits","37MVisits",
"23KActives","19KActives"
}
local function RedeemAllCodes()
task.spawn(function()
local codeSet={}
for _,c in ipairs(KnownCodes)do
codeSet[c]=true
end
local function scanContainer(container)
if not container then return end
if container:IsA("ModuleScript")then
local ok,data=pcall(require,container)
if ok and type(data)=="table"then
for k,v in pairs(data)do
if type(k)=="string"then codeSet[k]=true end
if type(v)=="string"then codeSet[v]=true end
end
end
end
for _,child in ipairs(container:GetChildren())do
codeSet[child.Name]=true
if child:IsA("StringValue")and child.Value~=""then
codeSet[child.Value]=true
end
end
end
scanContainer(Info:FindFirstChild("Code"))
scanContainer(Info:FindFirstChild("Codes"))
scanContainer(PlayerData:FindFirstChild("Code"))
scanContainer(PlayerData:FindFirstChild("Codes"))
for code in pairs(codeSet)do
pcall(function()
RedeemCodeEvent:FireServer(code)
end)
task.wait(0.15)
end
end)
end
local function OpenMenuFrameRemotely(frameName)
local pg=LocalPlayer:FindFirstChild("PlayerGui")
local mg=(pg and pg:FindFirstChild("MainGui"))or MainGui
local menu=mg and mg:FindFirstChild("Menu")
if not menu then return false end
local target=menu:FindFirstChild(frameName)
if not target and(string.lower(frameName)=="trait"or string.find(string.lower(frameName),"trait"))then
for _,child in pairs(menu:GetChildren())do
local lName=string.lower(child.Name)
if string.find(lName,"trait")or string.find(lName,"reroll")then
target=child
frameName=child.Name
break
end
end
if not target then
for _,desc in pairs(mg:GetDescendants())do
if desc:IsA("Frame")then
local lName=string.lower(desc.Name)
if string.find(lName,"trait")or string.find(lName,"reroll")then
target=desc
break
end
end
end
end
end
if not target then return false end
for _,child in pairs(menu:GetChildren())do
if child:IsA("Frame")and child.Name~="Info"and child.Name~="Black"and child.Name~="Dialogue"then
if child==target or child.Name==frameName then
child.Visible=not child.Visible
else
child.Visible=false
end
end
end
if target.Parent~=menu then
target.Visible=not target.Visible
end
return target.Visible
end
local OriginalLighting={
Brightness=Lighting.Brightness,
ClockTime=Lighting.ClockTime,
FogEnd=Lighting.FogEnd,
FogStart=Lighting.FogStart,
GlobalShadows=Lighting.GlobalShadows,
Ambient=Lighting.Ambient,
OutdoorAmbient=Lighting.OutdoorAmbient
}
local OriginalAtmosphere={}
for _,child in ipairs(Lighting:GetChildren())do
if child:IsA("Atmosphere")then
OriginalAtmosphere[child]={
Density=child.Density,
Haze=child.Haze,
Glare=child.Glare
}
end
end
local applyingLighting=false
local function ApplyLightingSettings()
if applyingLighting then return end
applyingLighting=true
pcall(function()
if MosCfg.FullBright then
Lighting.Brightness=2
Lighting.ClockTime=14
Lighting.GlobalShadows=false
Lighting.Ambient=Color3 .fromRGB(255,255,255)
Lighting.OutdoorAmbient=Color3 .fromRGB(255,255,255)
end
if MosCfg.NoFog then
Lighting.FogStart=100000
Lighting.FogEnd=100000
for _,child in ipairs(Lighting:GetChildren())do
if child:IsA("Atmosphere")then
if not OriginalAtmosphere[child]then
OriginalAtmosphere[child]={
Density=child.Density,
Haze=child.Haze,
Glare=child.Glare
}
end
child.Density=0
child.Haze=0
child.Glare=0
end
end
end
end)
applyingLighting=false
end
local function RestoreFullBright()
applyingLighting=true
pcall(function()
Lighting.Brightness=OriginalLighting.Brightness
Lighting.ClockTime=OriginalLighting.ClockTime
Lighting.GlobalShadows=OriginalLighting.GlobalShadows
Lighting.Ambient=OriginalLighting.Ambient
Lighting.OutdoorAmbient=OriginalLighting.OutdoorAmbient
end)
applyingLighting=false
end
local function RestoreNoFog()
applyingLighting=true
pcall(function()
Lighting.FogStart=OriginalLighting.FogStart
Lighting.FogEnd=OriginalLighting.FogEnd
for atm,orig in pairs(OriginalAtmosphere)do
if atm and atm.Parent then
atm.Density=orig.Density
atm.Haze=orig.Haze
atm.Glare=orig.Glare
end
end
end)
applyingLighting=false
end
Lighting.Changed:Connect(function()
if MosCfg.FullBright or MosCfg.NoFog then
ApplyLightingSettings()
end
end)
ApplyLightingSettings()
local function ClickInventoryUIItem(targetName)
if not MainGui or not targetName or targetName==""then return false end
local mainNode=MainGui:FindFirstChild("Main")
local fishInv=mainNode and mainNode:FindFirstChild("Fishing_INV")
local invMain=fishInv and fishInv:FindFirstChild("Main")
if not invMain then return false end
for _,desc in ipairs(invMain:GetDescendants())do
if desc.Name==targetName or desc:GetAttribute("ItemName")==targetName then
local btn=(desc:IsA("GuiButton")and desc)
or desc:FindFirstChild("Equip",true)
or desc:FindFirstChild("Select",true)
or desc:FindFirstChild("Choose",true)
or desc:FindFirstChild("Button",true)
or desc:FindFirstChildWhichIsA("GuiButton",true)
if btn and TriggerGuiButton(btn)then
local equipBtn=invMain:FindFirstChild("Equip",true)
if equipBtn and equipBtn:IsA("GuiButton")then
TriggerGuiButton(equipBtn)
end
return true
end
end
end
return false
end
local function GetBestOwnedRod()
local rodInv=PlayerData:FindFirstChild("FishingRodInventory")
local invInfo=Info:FindFirstChild("Inventory")
if not rodInv or not invInfo then return nil end
local bestRod,bestPower=nil,-1
for _,rodFolder in ipairs(rodInv:GetChildren())do
local owned=rodFolder:FindFirstChild("Owned")
if owned and owned.Value==true then
local data=GetModuleData(invInfo:FindFirstChild(rodFolder.Name))
if data then
local pwr=tonumber(data.Power)or 0
if pwr>bestPower then
bestPower=pwr
bestRod=rodFolder.Name
end
end
end
end
return bestRod
end
local function ScoreItemData(data)
if type(data)~="table"then return 0 end
local score=(tonumber(data.Power)or 0)*1000
+(tonumber(data.Boost)or 0)*500
+(tonumber(data.Luck)or 0)*200
+(tonumber(data.Price)or 0)*0.01
if data.Ingredient then score=score+50000 end
if data.Rarity=="Secret"then
score=score+1000000
elseif data.Rarity=="Mythical"then
score=score+500000
elseif data.Rarity=="Legendary"then
score=score+100000
end
return score
end
local function IsItemOwnedInFolder(folder,itemName)
if not folder then return false end
local entry=folder:FindFirstChild(itemName)
if not entry then return false end
if entry:IsA("BoolValue")then return entry.Value==true end
if entry:IsA("NumberValue")or entry:IsA("IntValue")then return entry.Value>0 end
local owned=entry:FindFirstChild("Owned")
if owned and owned:IsA("BoolValue")then return owned.Value==true end
local qty=entry:FindFirstChild("Quantity")or entry:FindFirstChild("Amount")or entry:FindFirstChild("Value")
if qty and(qty:IsA("NumberValue")or qty:IsA("IntValue"))then return qty.Value>0 end
return true
end
local function GetBestOwned(infoName,dataNames)
local infoFolder=Info:FindFirstChild(infoName)
if not infoFolder then return nil end
local best,bestScore=nil,-1
local ownedFolder
for _,n in ipairs(dataNames)do
ownedFolder=ownedFolder or PlayerData:FindFirstChild(n)
end
local genInv=PlayerData:FindFirstChild("Inventory")
for _,mod in ipairs(infoFolder:GetChildren())do
if mod:IsA("ModuleScript")and(IsItemOwnedInFolder(ownedFolder,mod.Name)or IsItemOwnedInFolder(genInv,mod.Name))then
local data=GetModuleData(mod)
if data then
local sc=ScoreItemData(data)
if sc>bestScore then
bestScore=sc
best=mod.Name
end
end
end
end
return best
end
local function TryEquipBestRod()
local bestRod=GetBestOwnedRod()
if not bestRod then
pcall(function()Fluent:Notify({Title="Equip Best Rod",Content="No rod found",Duration=3})end)
return
end
local curRodVal=PlayerData:FindFirstChild("FishingRod")
if curRodVal and curRodVal.Value==bestRod then return end
ClickInventoryUIItem(bestRod)
local ev=FindRemote("EquipFishingRod")or FindRemote("EquipRod")or FindRemote("ChangeRod")or FindRemote("SelectRod")
if ev then FireOrInvokeEvent(ev,bestRod)end
pcall(function()Fluent:Notify({Title="Equip Best Rod",Content="Equipped "..bestRod,Duration=3})end)
end
local function TryEquipBestOrb()
local bestOrb=GetBestOwned("Orb",{"Orb","OrbInventory","Orbs"})
if not bestOrb then
pcall(function()Fluent:Notify({Title="Equip Best Orb",Content="No orb found",Duration=3})end)
return
end
ClickInventoryUIItem(bestOrb)
local ev=FindRemote("EquipOrb")or FindRemote("ChangeOrb")or FindRemote("SelectOrb")
if ev then FireOrInvokeEvent(ev,bestOrb)end
pcall(function()Fluent:Notify({Title="Equip Best Orb",Content="Equipped "..bestOrb,Duration=3})end)
end
local function DoBuyBestRod()
local cashVal=PlayerData:FindFirstChild("Cash")
local invInfo=Info:FindFirstChild("Inventory")
local rodInv=PlayerData:FindFirstChild("FishingRodInventory")
local buyEv=Events:FindFirstChild("BuyFishingRod")
if not cashVal or not invInfo or not buyEv then return end
local cash=tonumber(cashVal.Value)or 0
local best,bestPower=nil,-1
for _,mod in ipairs(invInfo:GetChildren())do
local data=GetModuleData(mod)
if data and data.Type=="Fishing Rod"and type(data.Cash)=="number"and data.Cash>0 and data.Cash<=cash then
local owned=rodInv and rodInv:FindFirstChild(mod.Name)
local ownedVal=owned and owned:FindFirstChild("Owned")
if not(ownedVal and ownedVal.Value==true)then
local pwr=tonumber(data.Power)or 0
if pwr>bestPower then
bestPower=pwr
best=mod.Name
end
end
end
end
if best then
pcall(function()buyEv:FireServer(best)end)
task.wait(0.3)
local eq=Events:FindFirstChild("EquipFishingRod")
if eq then
pcall(function()
if eq:IsA("RemoteFunction")then eq:InvokeServer(best)else eq:FireServer(best)end
end)
end
end
end
local function DoDailyReward()
local dr=PlayerData:FindFirstChild("DailyReward")
local ev=Events:FindFirstChild("DailyReward")
if not dr or not ev then return end
for i=1,7 do
local v=dr:FindFirstChild(tostring(i))
if v and v:IsA("BoolValue")and v.Value==false then
pcall(function()ev:FireServer(i)end)
task.wait(0.15)
end
end
end
local function GetBanners()
local list={}
local g=Info:FindFirstChild("Gacha")
if g then
for _,child in ipairs(g:GetChildren())do
table.insert(list,child.Name)
end
table.sort(list)
end
if#list==0 then
list={"Celestial Banner","Egoless Banner"}
end
return list
end
local function DoSummon()
local ev=Events:FindFirstChild("Gacha")
if not ev or MosCfg.SelectedBanner==""then return end
local crystal=PlayerData:FindFirstChild("Crystal")
local need=MosCfg.SummonX10 and 50 or 5
if crystal and crystal.Value<need then return end
pcall(function()ev:FireServer(MosCfg.SummonX10,MosCfg.SelectedBanner)end)
end
local function RedeemFromPlayerData()
local codeFolder=PlayerData:FindFirstChild("Code")
if codeFolder then
for _,child in ipairs(codeFolder:GetChildren())do
if child:IsA("BoolValue")and child.Value==false then
pcall(function()RedeemCodeEvent:FireServer(child.Name)end)
task.wait(0.2)
end
end
end
end
task.spawn(function()
local lastDaily,lastSummon,lastBuyRod,lastRedeem=0,0,0,0
while task.wait(0.8)do
local now=os.clock()
if MosCfg.AutoDaily and now-lastDaily>=10 then
lastDaily=now
pcall(DoDailyReward)
end
if MosCfg.AutoSummon and now-lastSummon>=1.5 then
lastSummon=now
pcall(DoSummon)
end
if MosCfg.AutoBuyBestRod and now-lastBuyRod>=4 then
lastBuyRod=now
pcall(DoBuyBestRod)
end
if MosCfg.AutoRedeem and now-lastRedeem>=15 then
lastRedeem=now
pcall(RedeemFromPlayerData)
end
end
end)
local fpsBackup=setmetatable({},{__mode="k"})
local fpsConn=nil
local function fpsSet(obj,prop,val)
local bucket=fpsBackup[obj]
if not bucket then
bucket={}
fpsBackup[obj]=bucket
end
if bucket[prop]==nil then
local ok,old=pcall(function()return obj[prop]end)
if not ok then return end
bucket[prop]=old
end
pcall(function()obj[prop]=val end)
end
local function fpsOptimize(d)
if d:IsA("BasePart")then
fpsSet(d,"CastShadow",false)
elseif d:IsA("Decal")or d:IsA("Texture")then
fpsSet(d,"Transparency",1)
elseif d:IsA("ParticleEmitter")or d:IsA("Trail")or d:IsA("Beam")or d:IsA("Smoke")or d:IsA("Fire")or d:IsA("Sparkles")or d:IsA("PostEffect")then
fpsSet(d,"Enabled",false)
end
end
local function SetFpsBoost(on)
if fpsConn then
fpsConn:Disconnect()
fpsConn=nil
end
for obj,props in pairs(fpsBackup)do
for prop,val in pairs(props)do
pcall(function()obj[prop]=val end)
end
end
table.clear(fpsBackup)
if not on then return end
for _,d in ipairs(workspace:GetDescendants())do
fpsOptimize(d)
end
fpsConn=game.DescendantAdded:Connect(fpsOptimize)
end
if MosCfg.FpsBoost then
task.delay(6,function()
if not MosX.Unloaded then SetFpsBoost(true)end
end)
end
do
local BossList={
"Azure Carp",
"Jiaolong Dragonfish",
"Chainbound Shark",
"Adult Jiaolong Dragonfish",
"Elder Chainbound Shark",
"Elder Jiaolong Dragonfish",
"Trueform Jiaolongfish",
"Trueform Perch",
"Ascended Perch",
"Primordial Kunfish",
"Primordial Kunfish Overlord",
"Warbringer Shark",
"Dreadscale Grouper",
"Mutated Koid Whale",
"Radiant Goldfish",
"Serpent Fish",
"Dreadmare Eel",
"Chromatic Koi",
"Toxic Chromatic Koi",
"Crimson Bream Sovereign",
"Silver Bream Sovereign",
"Golder Guardian Fish",
"Colossal Tigerfish",
"Mountain Fish",
"Tiger Mirefish",
"Octoparasitic Fish",
"Dark kingfish",
"Golden Shark",
"Darkness Shark",
"White Heaven Kunfish",
"Crimson Bonefiend",
"Dragonfish Devourer",
"Yangfish Sovereign",
"Yinfish Sovereign",
"Demon Bladefish",
"Apollo Swordfish",
"Killer Sawshark",
"Thunder Fish",
"Wind Fish",
"Intuitive Fish King",
"Aquatic Fish",
"Flame Fish",
"Verdant Alligator Gar",
"Verdant Grouper",
"Verdant Bonefang",
"Scarlet Fish",
"Mountain Dragonwhale",
"Flying Fish Emperor",
"Crimson Bonefang",
"Elder ScarletFish",
"Colossal Bull Shark",
"Flying Fish Empress",
"Draconic Koi",
"Tigerfang Whale",
"Golden Dragonfish",
"Crimson Electric Eel",
"Reborn Puffer Beast",
"Heavenpiercer Turtle",
"Sanguine Fish",
"Frost Kingfish",
"Dark Lionfish",
"Rainbow Dragonfish",
"Mirage lanternfish",
"Nameless Octoparasite",
"Frost QueenFish",
"Thunder Bull Shark",
"Black Tortoise Bloodline",
"Vermilion Birdblood"
}
local function GetBossList()
local list={}
for _,name in ipairs(BossList)do
table.insert(list,name)
end
return list
end
MosX.BossItems=GetBossList()
local function trim(s)
return(string.match(tostring(s or""),"^%s*(.-)%s*$"))
end
local function CollectTargets(tbl)
local out={}
if type(tbl)=="table"then
for k,v in pairs(tbl)do
local name
if type(k)=="string"and v==true then
name=k
elseif type(v)=="string"and v~=""then
name=v
end
if name then
local clean=string.lower(trim(name))
if clean~=""and not table.find(out,clean)then
table.insert(out,clean)
end
end
end
end
return out
end
local function MatchAny(fishName,targets)
local f=string.lower(trim(fishName))
for _,t in ipairs(targets)do
if f==t or string.find(f,t,1,true)then
return true
end
end
return false
end
local function GetFishNameFromItem(itemName)
if not itemName or itemName==""then return""end
local cleanStr=string.split(itemName,"| Favorite")[1]
cleanStr=trim(cleanStr)
local clientMod=ReplicatedStorage:FindFirstChild("ClientModule")
local gs=clientMod and clientMod:FindFirstChild("GameService")
if gs then
local ok,res=pcall(function()
local gMod=require(gs)
return gMod and gMod.DestringFish and gMod.DestringFish(cleanStr)
end)
if ok and res and res.FishName then
return res.FishName
end
end
local parts=string.split(cleanStr,",")
if#parts>=1 and parts[1]~=""then
return parts[1]
end
return cleanStr
end
local function FavoriteIfBoss(itemName,targets)
if string.find(itemName,"| Favorite",1,true)then return false end
if MatchAny(GetFishNameFromItem(itemName),targets)then
local favRemote=Events:FindFirstChild("FavoriteItem")
if favRemote then
pcall(function()favRemote:FireServer(itemName)end)
return true
end
end
return false
end
function MosX.ScanAndFavoriteBossFish()
if not MosCfg.AutoFavoriteBoss then return end
local inv=PlayerData and PlayerData:FindFirstChild("Inventory")
if not inv then return end
local targets=CollectTargets(MosCfg.AutoFavoriteBossTarget)
if#targets==0 then return end
for _,child in ipairs(inv:GetChildren())do
if not MosCfg.AutoFavoriteBoss then break end
if FavoriteIfBoss(child.Name,targets)then
task.wait(0.15)
end
end
end
task.spawn(function()
local inv=PlayerData and PlayerData:WaitForChild("Inventory",10)
if not inv then return end
MosX.Track(inv.ChildAdded:Connect(function(child)
if not MosCfg.AutoFavoriteBoss then return end
task.wait(0.2)
if not child or not child.Parent then return end
local targets=CollectTargets(MosCfg.AutoFavoriteBossTarget)
if#targets>0 then
FavoriteIfBoss(child.Name,targets)
end
end))
end)
local function CancelCurrentFishing(sessionToken)
pcall(function()
if sessionToken then
Events.FishingMinigame:FireServer(false,sessionToken,"Unequip")
end
end)
pcall(function()
ToggleHotbar:InvokeServer("1")
end)
end
MosOnRemote("FishingMinigame",function(fishData,rodData,sessionToken)
if not MosCfg.FilterFishEnabled or type(fishData)~="table"then return end
local rawFishName=tostring(fishData.FishName or fishData.Name or fishData.Fish or"")
if rawFishName==""then
local progBar=FishingGui and FishingGui:FindFirstChild("ProgressionBar")
local fNameLbl=progBar and progBar:FindFirstChild("FishName")
if fNameLbl and fNameLbl:IsA("TextLabel")and fNameLbl.Text~=""then
rawFishName=fNameLbl.Text
end
end
if rawFishName==""then return end
local targets=CollectTargets(MosCfg.FilterFishTarget)
if#targets==0 then return end
if not MatchAny(rawFishName,targets)then
task.spawn(function()
task.wait(0.05)
CancelCurrentFishing(sessionToken)
end)
end
end)
end
do
local lastGiveTick=0
local function GetDumbGuyObject()
local npc=workspace:FindFirstChild("NPC")
local fn=npc and npc:FindFirstChild("Function")
local dg=fn and fn:FindFirstChild("Dumb guy")
if dg then return dg end
local ok,res=pcall(function()
return workspace.NPC.Function["Dumb guy"]
end)
if ok and res then return res end
return workspace:FindFirstChild("Dumb guy",true)
end
local function IsNonFavoriteFish(itemName)
if not itemName or itemName==""then return false end
if string.find(itemName,"Favorite",1,true)then return false end
local clean=string.split(itemName,"|")[1]or itemName
local cleanName=string.gsub(clean,"^%s*(.-)%s*$","%1")
if cleanName==""or cleanName=="Fishing rod"or string.find(cleanName,"Bait",1,true)then
return false
end
local invFolder=Info and Info:FindFirstChild("Inventory")
local mod=invFolder and invFolder:FindFirstChild(cleanName)
local data=GetModuleData(mod)
if data and data.Type=="Fish"then
return true
end
local clientMod=ReplicatedStorage:FindFirstChild("ClientModule")
local gs=clientMod and clientMod:FindFirstChild("GameService")
if gs then
local ok,res=pcall(function()
local gMod=require(gs)
return gMod and gMod.DestringFish and gMod.DestringFish(itemName)
end)
if ok and res and res.FishName then
return true
end
end
if string.find(itemName,"|",1,true)then
return true
end
return false
end
local function FindAvailableHotbarSlot()
local hotbar=PlayerData and PlayerData:FindFirstChild("Hotbar")
if not hotbar then return"4"end
for i=4,10 do
local slot=hotbar:FindFirstChild(tostring(i))
if slot then
local valName=slot:FindFirstChild("ValueName")
local qty=slot:FindFirstChild("Quantity")
if(not valName or valName.Value=="")or(qty and qty.Value<=0)then
return tostring(i)
end
end
end
return"4"
end
function MosX.StepAutoGiveFish()
if not MosCfg.AutoGiveFish then return end
local now=os.clock()
if now-lastGiveTick<1.2 then return end
local pData=PlayerData or(DataFolder and DataFolder:FindFirstChild(tostring(LocalPlayer.UserId)))
if not pData then return end
local dg=GetDumbGuyObject()
if not dg then return end
local targetSlot=nil
local hotbar=pData:FindFirstChild("Hotbar")
if hotbar then
for i=2,10 do
local slot=hotbar:FindFirstChild(tostring(i))
local valName=slot and slot:FindFirstChild("ValueName")
local qty=slot and slot:FindFirstChild("Quantity")
if valName and valName.Value~=""and(not qty or qty.Value>0)then
if IsNonFavoriteFish(valName.Value)then
targetSlot=tostring(i)
break
end
end
end
end
if not targetSlot then
local inv=pData:FindFirstChild("Inventory")
if inv then
local foundItem=nil
for _,child in ipairs(inv:GetChildren())do
if child.Name~=""and(not child:IsA("ValueBase")or child.Value>0)then
if IsNonFavoriteFish(child.Name)then
foundItem=child
break
end
end
end
if foundItem then
local freeSlot=FindAvailableHotbarSlot()
local moveEv=Events and Events:FindFirstChild("MoveItems")
if moveEv then
pcall(function()
moveEv:FireServer("Inventory",foundItem.Name,freeSlot)
end)
task.wait(0.25)
end
targetSlot=freeSlot
end
end
end
if targetSlot then
lastGiveTick=os.clock()
pcall(function()
ToggleHotbar:InvokeServer(targetSlot)
end)
task.wait(0.2)
local args={
[1]="Dumb guy",
[2]=1,
[3]="GiveFish",
[4]={
[1]=dg
}
}
pcall(function()
ChooseDialogueOption:FireServer(unpack(args))
end)
end
end
end
do
local lastQuestClaimTick=0
local lastRewardClaimTick=0
function MosX.StepAutoClaimDailyQuest()
local now=os.clock()
if now-lastQuestClaimTick<2 then return end
lastQuestClaimTick=now
pcall(function()
local pData=PlayerData or(DataFolder and DataFolder:FindFirstChild(tostring(LocalPlayer.UserId)))
local questFolder=pData and pData:FindFirstChild("Quest")
local dailyFolder=questFolder and questFolder:FindFirstChild("Daily")
if not dailyFolder then return end
local questModule=Info and Info:FindFirstChild("Quest")
local questInfo=nil
if questModule then
pcall(function()
questInfo=require(questModule)
end)
end
local claimEvent=Events and Events:FindFirstChild("ClaimQuest")
if not claimEvent then return end
for _,child in ipairs(dailyFolder:GetChildren())do
local claimVal=child:FindFirstChild("Claim")
local progVal=child:FindFirstChild("Progression")
local typeVal=child:FindFirstChild("QuestType")
if claimVal and progVal and typeVal and claimVal.Value==false and typeVal.Value~=""then
local target=nil
if questInfo and questInfo.Daily and tonumber(child.Name)then
local def=questInfo.Daily[tonumber(child.Name)]
if def and def[2]then
target=def[2]
end
end
if target then
local current=progVal.Value
if typeVal.Value=="PlayTime"then
local req=math.clamp(math.floor(target/60),1,999)
local cur=math.clamp(math.floor(current/60),0,999)
if cur>=req then
claimEvent:FireServer(child.Name)
end
else
if current>=target then
claimEvent:FireServer(child.Name)
end
end
end
end
end
end)
end
function MosX.StepAutoClaimDailyReward()
local now=os.clock()
if now-lastRewardClaimTick<5 then return end
lastRewardClaimTick=now
pcall(function()
local pData=PlayerData or(DataFolder and DataFolder:FindFirstChild(tostring(LocalPlayer.UserId)))
local dailyRewardFolder=pData and pData:FindFirstChild("DailyReward")
if not dailyRewardFolder then return end
local dayCycle=dailyRewardFolder:FindFirstChild("DayCycle")
local cycleVal=dayCycle and dayCycle.Value
if not cycleVal or cycleVal==""then return end
local currentDay=math.floor(workspace:GetServerTimeNow()/86400)
local lastDay=tonumber(cycleVal)
local isNewDay=(lastDay==nil)or(lastDay<currentDay)
if not isNewDay then return end
local rewardEvent=Events and Events:FindFirstChild("DailyReward")
if not rewardEvent then return end
for i=1,7 do
local dayVal=dailyRewardFolder:FindFirstChild(tostring(i))
if dayVal and dayVal.Value==false then
local canClaim=false
if i==1 then
canClaim=true
else
local prevVal=dailyRewardFolder:FindFirstChild(tostring(i-1))
canClaim=prevVal and prevVal.Value==true
end
if canClaim then
rewardEvent:FireServer(i)
break
end
end
end
end)
end
end
do
local function MosFindSelfFile()
local candidates={"MosChill.lua","MosChill.txt","MosHub/MosChill.lua","MosHub/MosChill.txt","MosCuChillDe.lua","MosCuChillDe.txt","MosHub/MosCuChillDe.lua","MosHub/MosCuChillDe.txt"}
for _,p in ipairs(candidates)do
local ok,exists=pcall(function()return isfile and isfile(p)end)
if ok and exists then return p end
end
return nil
end
local hasQueued=false
function MosX.QueueReExecute()
if hasQueued then return end
if not(MosCfg.AutoExe or MosCfg.AutoHopSacredBeast or MosCfg.AutoHopWeather)then return end
local queueFn=(syn and syn.queue_on_teleport)or queue_on_teleport or(fluxus and fluxus.queue_on_teleport)
if not queueFn then return end
local function luaQuote(str)
local escaped=string.gsub(str,'[\\"\n\r]',function(ch)
if ch=="\n"then return"\\n"end
if ch=="\r"then return"\\r"end
return"\\"..ch
end)
return'"'..escaped..'"'
end
local loadLine
local urlHint=MosGenv.MosChill_URL or MosGenv.MosCuChillDe_URL
local path=MosFindSelfFile()
if path then
loadLine="loadstring(readfile("..luaQuote(path).."))()"
elseif type(urlHint)=="string"and urlHint~=""then
loadLine="loadstring(game:HttpGet("..luaQuote(urlHint).."))()"
end
if not loadLine then
pcall(function()
Fluent:Notify({
Title="Auto Execute",
Content="Save this script as MosChill.lua in your executor workspace folder to re-run after hopping.",
Duration=6
})
end)
return
end
hasQueued=true
pcall(function()
queueFn([[
repeat task.wait(0.5) until game:IsLoaded()
repeat task.wait(0.5) until game:GetService("Players").LocalPlayer
repeat task.wait(0.5) until workspace:FindFirstChild("Terrain") and (#workspace:GetChildren() > 10)
task.wait(2)
local ok, err = pcall(function() ]]..loadLine..[[ end)
if not ok then warn("[MosCuChillDe] auto execute failed: " .. tostring(err)) end
]])
end)
end
pcall(function()
MosX.Track(LocalPlayer.OnTeleport:Connect(function()
MosX.QueueReExecute()
end))
end)
pcall(function()
MosX.Track(TeleportService.TeleportInitFailed:Connect(function()
hasQueued=false
end))
end)
local VISITED_FILE=SAVE_FOLDER.."/MosVisited.json"
local VISIT_TTL=600
local hopping=false
local function ReadVisited()
local seen,now={},os.time()
pcall(function()
if isfile and isfile(VISITED_FILE)then
local data=HttpService:JSONDecode(readfile(VISITED_FILE))
if type(data)=="table"then
for id,ts in pairs(data)do
if type(id)=="string"and tonumber(ts)and now-tonumber(ts)<VISIT_TTL then
seen[id]=tonumber(ts)
end
end
end
end
end)
if tostring(game.JobId)~=""then
seen[tostring(game.JobId)]=now
end
return seen
end
local function WriteVisited(seen)
pcall(function()
if not isfolder(SAVE_FOLDER)then makefolder(SAVE_FOLDER)end
writefile(VISITED_FILE,HttpService:JSONEncode(seen))
end)
end
function MosX.DoServerHop(mode)
if hopping then return end
hopping=true
task.spawn(function()
local placeId=game.PlaceId
local curJobId=tostring(game.JobId or"")
local requestFn=(syn and syn.request)or(http and http.request)or http_request or(fluxus and fluxus.request)or request
local low=(mode=="low")
local seen=ReadVisited()
local pool,fresh={},{}
pcall(function()
Fluent:Notify({
Title="Server Hop",
Content=low and"Searching for low player server..."or"Searching for a server...",
Duration=4
})
end)
local cursor,pages="",0
local maxPages=low and 8 or 5
local order=low and"Asc"or"Desc"
while pages<maxPages and#fresh==0 do
pages=pages+1
local url="https://games.roblox.com/v1/games/"..tostring(placeId).."/servers/Public?sortOrder="..order.."&limit=100"
if cursor~=""then
url=url.."&cursor="..cursor
end
local raw=nil
if requestFn then
local okReq,res=pcall(requestFn,{Url=url,Method="GET"})
if okReq and res and res.Body then raw=res.Body end
else
local okGet,res=pcall(game.HttpGet,game,url)
if okGet then raw=res end
end
if not raw then break end
local data=nil
pcall(function()data=HttpService:JSONDecode(raw)end)
if not(data and type(data.data)=="table")then break end
for _,s in ipairs(data.data)do
if type(s)=="table"and s.id and tostring(s.id)~=curJobId then
local playing=tonumber(s.playing)or 0
local cap=tonumber(s.maxPlayers)or 1
if playing>0 and playing<cap then
table.insert(pool,s)
if not seen[tostring(s.id)]then
table.insert(fresh,s)
end
end
end
end
if#fresh>0 or not(data.nextPageCursor and data.nextPageCursor~="")then break end
cursor=data.nextPageCursor
task.wait(0.25)
end
local list=(#fresh>0)and fresh or pool
if#fresh==0 and#pool>0 then
seen={}
if curJobId~=""then seen[curJobId]=os.time()end
end
local target=nil
if#list>0 then
table.sort(list,function(a,b)
local pa,pb=tonumber(a.playing)or 0,tonumber(b.playing)or 0
if low then return pa<pb end
return pa>pb
end)
target=low and list[1]or list[math.random(1,math.min(#list,5))]
end
MosX.QueueReExecute()
if target and target.id then
seen[tostring(target.id)]=os.time()
WriteVisited(seen)
pcall(function()
Fluent:Notify({
Title="Server Hop",
Content="Found server with "..tostring(target.playing).." players! Teleporting...",
Duration=4
})
end)
task.wait(0.3)
pcall(function()
TeleportService:TeleportToPlaceInstance(placeId,target.id,LocalPlayer)
end)
else
pcall(function()
Fluent:Notify({Title="Server Hop",Content="Teleporting to random server...",Duration=4})
end)
task.wait(0.3)
pcall(function()
TeleportService:Teleport(placeId,LocalPlayer)
end)
end
task.wait(8)
hopping=false
if not MosX.Unloaded and(MosCfg.AutoHopSacredBeast or MosCfg.AutoHopWeather)then
MosX.DoServerHop(mode)
end
end)
end
function MosX.GetWeatherList()
local list={}
local clientMod=ReplicatedStorage:FindFirstChild("ClientModule")
local wScript=clientMod and clientMod:FindFirstChild("Weather")
local wFolder=wScript and wScript:FindFirstChild("Weather")
if wFolder then
for _,child in ipairs(wFolder:GetChildren())do
if child:IsA("ModuleScript")or child:IsA("Folder")then
table.insert(list,child.Name)
end
end
end
if#list==0 then
list={"Clear","Rain","Thunderstorm","Snow","Fog","Windy","Cloudy","Solar Eclipse"}
else
table.sort(list)
end
return list
end
local function FindChuPrompt()
local npcFolder=workspace:FindFirstChild("NPC")
local funcFolder=npcFolder and npcFolder:FindFirstChild("Function")
local chu=funcFolder and funcFolder:FindFirstChild("Chu Tianjiao")
if chu then
local p=chu:FindFirstChildWhichIsA("ProximityPrompt",true)
if p then return p end
end
for _,desc in ipairs(workspace:GetDescendants())do
if desc:IsA("ProximityPrompt")then
local pName=string.lower(tostring(desc.ObjectText or(desc.Parent and desc.Parent.Name)or""))
local aName=string.lower(tostring(desc.ActionText or""))
if string.find(pName,"chu",1,true)or string.find(aName,"talk",1,true)then
return desc
end
end
end
local direct=workspace:FindFirstChild("Chu Tianjiao",true)
if direct then
local p=direct:FindFirstChildWhichIsA("ProximityPrompt",true)
if p then return p end
end
return nil
end
local chuPromptCache
local function GetChuPrompt()
if chuPromptCache and chuPromptCache.Parent then return chuPromptCache end
chuPromptCache=FindChuPrompt()
return chuPromptCache
end
local function TriggerChuPrompt(prompt)
if not prompt then return false end
local ok=false
pcall(function()
prompt.RequiresLineOfSight=false
prompt.MaxActivationDistance=9999
prompt.HoldDuration=0
if fireproximityprompt then
fireproximityprompt(prompt)
ok=true
end
end)
return ok
end
local function ReadChuDialogueFromGui()
local pg=LocalPlayer:FindFirstChild("PlayerGui")
local mg=pg and pg:FindFirstChild("MainGui")
local menu=mg and mg:FindFirstChild("Menu")
local dialogue=menu and menu:FindFirstChild("Dialogue")
if dialogue and dialogue.Visible then
for _,desc in ipairs(dialogue:GetDescendants())do
if desc:IsA("TextLabel")and desc.Visible then
local txt=tostring(desc.Text or""):gsub("^%s*(.-)%s*$","%1")
if#txt>3 and not string.find(txt,"Close")and not string.find(txt,"Main Quest")and txt~="???"and not string.find(txt,"Chu Tianjiao")then
return txt
end
end
end
end
return nil
end
local function CheckChuTianjiaoDialogue(timeoutSec)
local char=LocalPlayer.Character or cachedChar
local hrp=(char and char:FindFirstChild("HumanoidRootPart"))or cachedHrp
if hrp then
hrp.CFrame=CFrame.new(-2569.52,15.70,-1405.43,0.09,0.00,1.00,0.00,1.00,-0.00,-1.00,0.00,0.09)
end
task.wait(0.2)
local startWait=os.clock()
local limit=timeoutSec or 3.0
local resultText=""
while(os.clock()-startWait)<limit do
local prompt=GetChuPrompt()
if prompt then
TriggerChuPrompt(prompt)
end
local guiText=ReadChuDialogueFromGui()
if guiText and guiText~=""then
resultText=guiText
break
end
task.wait(0.1)
end
return(resultText~=""),resultText
end
local function IsSacredBeastAppeared(dialogueText)
local lower=string.lower(dialogueText or"")
if lower==""then return false end
if string.find(lower,"i can feel it",1,true)
or string.find(lower,"approaching",1,true)
or string.find(lower,"don't have any quests",1,true)
or string.find(lower,"maybe you'll find",1,true)then
return false
end
return string.find(lower,"hurry",1,true)~=nil
end
MosX.CheckChu=CheckChuTianjiaoDialogue
MosX.IsSacredBeastAppeared=IsSacredBeastAppeared
function MosX.PostWebhook(url,title,body,color,fields)
url=tostring(url or""):gsub("%s+","")
if url==""or not string.find(url,"webhook",1,true)then return false end
local send=(syn and syn.request)or(http and http.request)or http_request or(fluxus and fluxus.request)or request
if not send then return false end
local list={}
for _,f in ipairs(fields or{})do
table.insert(list,f)
end
table.insert(list,{name="Server JobId",value=tostring(game.JobId),inline=false})
local ok,res=pcall(function()
return send({
Url=url,
Method="POST",
Headers={["Content-Type"]="application/json"},
Body=HttpService:JSONEncode({
embeds={
{
title=title,
description=body,
color=color or 65280,
fields=list,
footer={text="Mos Hub"},
timestamp=DateTime.now():ToIsoDate()
}
}
})
})
end)
if not ok or not res then return false end
local code=tonumber(res.StatusCode or res.status_code or res.Status)
return code==nil or(code>=200 and code<300)
end
function MosX.FindBeastIsland(text)
if not text or text==""then return nil,"Unknown"end
local low=string.lower(text)
local function tidy(n)
return(tostring(n):gsub("%s*|%s*%d+",""):gsub("^%s+",""):gsub("%s+$",""))
end
for name,cf in pairs(IslandFarmPositions)do
local c=tidy(name)
if string.find(low,string.lower(c),1,true)then
return cf,c
end
end
local spawns=workspace:FindFirstChild("Spawnpoint")
if spawns then
for _,ch in ipairs(spawns:GetChildren())do
if string.find(low,string.lower(ch.Name),1,true)then
local part=ch:IsA("BasePart")and ch or ch:FindFirstChildWhichIsA("BasePart",true)
if part then
return part.CFrame+Vector3 .new(0,5,0),ch.Name
end
end
end
end
for name,cf in pairs(IslandFarmPositions)do
local c=tidy(name)
local stem=c:gsub("%s+[Ii]sle$","")
if#stem>=4 and string.find(low,string.lower(stem),1,true)and string.find(low,"isle",1,true)then
return cf,c
end
end
return nil,string.match(text,"([%w]+%s+[Ii]sle)")or"Unknown"
end
function MosX.ReportBeast(text,island)
local low=string.lower(text or"")
local where=(island and island~="")and island or"Unknown"
local label,title,color="Sacred Beast","\u{2694}\u{FE0F} Sacred Beast Detected",16744192
if string.find(low,"tortoise",1,true)then
label,title,color="Black Tortoise Bloodline","\u{1F422} Black Tortoise Bloodline",3407793
elseif string.find(low,"vermil",1,true)or string.find(low,"birdblood",1,true)then
label,title,color="Vermilion Birdblood","\u{1F525} Vermilion Birdblood",16721408
end
MosX.PostWebhook(
MosCfg.BossWebhookUrl,
title,
"Boss: **"..label.."**\nIsland: **"..where.."**\nDialogue: "..tostring(text),
color,
{{name="Island",value=where,inline=true}}
)
end
local lastWeatherSent=""
function MosX.ReportWeather(name,body)
local w=tostring(name or"")
if w==""then return false end
lastWeatherSent=string.lower(w)
return MosX.PostWebhook(
MosCfg.WeatherWebhookUrl,
"\u{1F324}\u{FE0F} Weather Detected: "..w,
body or("Target weather active: **"..w.."**"),
41727,
{{name="Weather",value=w,inline=true}}
)
end
MosX.Track(workspace:GetAttributeChangedSignal("Weather"):Connect(function()
local cur=tostring(workspace:GetAttribute("Weather")or"")
local want=tostring(MosCfg.SelectedWeather or"")
if cur==""then return end
if want~=""and string.lower(cur)==string.lower(want)then
if lastWeatherSent~=string.lower(cur)then
task.spawn(MosX.ReportWeather,cur,"Server weather changed to target weather: **"..cur.."**")
end
else
lastWeatherSent=string.lower(cur)
end
end))
end
do
local cachedLabel,lastScan=nil,0
local function ParseFull(text)
local cur,maxC=string.match(text or"","(%d+)%s*/%s*(%d+)")
local cNum,mNum=tonumber(cur),tonumber(maxC)
if cNum and mNum and mNum>=10 and cNum>=mNum then
return true
end
return false,(cNum~=nil and mNum~=nil)
end
local function LooksLikeInventory(label)
local p=label
for _=1,7 do
if not p or p==game then break end
local n=string.lower(p.Name)
if string.find(n,"inv",1,true)or string.find(n,"bag",1,true)
or string.find(n,"capacity",1,true)or string.find(n,"storage",1,true)
or string.find(n,"backpack",1,true)then
return true
end
p=p.Parent
end
return false
end
function MosX.IsInventoryFull()
local pData=PlayerData or(DataFolder and DataFolder:FindFirstChild(tostring(LocalPlayer.UserId)))
if pData then
local inv=pData:FindFirstChild("Inventory")
local limitObj=pData:FindFirstChild("InventoryLimit")or pData:FindFirstChild("MaxInventory")or pData:FindFirstChild("BagLimit")or pData:FindFirstChild("MaxCapacity")
local limit=(limitObj and tonumber(limitObj.Value))or tonumber(pData:GetAttribute("InventoryLimit"))or tonumber(pData:GetAttribute("MaxInventory"))
if inv and limit and limit>0 then
return#inv:GetChildren()>=limit
end
end
if cachedLabel and cachedLabel.Parent then
local full,valid=ParseFull(cachedLabel.Text)
if valid then return full end
end
local now=os.clock()
if now-lastScan<4 then return false end
lastScan=now
local pg=LocalPlayer:FindFirstChild("PlayerGui")
local mg=pg and(pg:FindFirstChild("MainGui")or pg:FindFirstChild("ScreenGui")or pg:FindFirstChild("GameGui"))
if mg then
for _,desc in ipairs(mg:GetDescendants())do
if desc:IsA("TextLabel")and string.find(desc.Text,"/",1,true)then
local full,valid=ParseFull(desc.Text)
if valid and LooksLikeInventory(desc)then
cachedLabel=desc
return full
end
end
end
end
return false
end
end
do
local origHold=setmetatable({},{__mode="k"})
local function InstantPrompt(prompt)
if prompt:IsA("ProximityPrompt")and prompt.HoldDuration~=0 then
if origHold[prompt]==nil then origHold[prompt]=prompt.HoldDuration end
prompt.HoldDuration=0
end
end
function MosX.SetInstantInteract(enabled)
pcall(function()
if enabled then
for _,d in ipairs(workspace:GetDescendants())do
if d:IsA("ProximityPrompt")then InstantPrompt(d)end
end
else
for p,h in pairs(origHold)do
if p and p.Parent then p.HoldDuration=h end
end
table.clear(origHold)
end
end)
end
pcall(function()
MosX.Track(workspace.DescendantAdded:Connect(function(d)
if MosCfg.InstantInteract and d:IsA("ProximityPrompt")then
task.wait()
pcall(InstantPrompt,d)
end
end))
end)
pcall(function()
MosX.Track(game:GetService("ProximityPromptService").PromptButtonHoldBegan:Connect(function(prompt)
if MosCfg.InstantInteract then
pcall(InstantPrompt,prompt)
if fireproximityprompt then
pcall(fireproximityprompt,prompt)
end
end
end))
end)
if MosCfg.InstantInteract then
task.delay(4,function()
if not MosX.Unloaded then MosX.SetInstantInteract(true)end
end)
end
function MosX.SetWalkOnWater(enabled)
local ocean=workspace:FindFirstChild("Ocean")
if not ocean then return end
for _,child in ipairs(ocean:GetChildren())do
if child.Name=="Water"and child:IsA("BasePart")then
child.CanCollide=enabled
end
end
end
task.spawn(function()
local ocean=workspace:WaitForChild("Ocean",30)
if not ocean then return end
MosX.Track(ocean.ChildAdded:Connect(function(child)
if MosCfg.WalkOnWater and child.Name=="Water"and child:IsA("BasePart")then
task.wait()
child.CanCollide=true
end
end))
if MosCfg.WalkOnWater then
MosX.SetWalkOnWater(true)
end
end)
end
do
local hiding=false
local lastSet=setmetatable({},{__mode="k"})
local origText=setmetatable({},{__mode="k"})
local hooked=setmetatable({},{__mode="k"})
local objConns=setmetatable({},{__mode="k"})
local containerConns={}
local charConn=nil
local realName=LocalPlayer.Name
local realDisplay=LocalPlayer.DisplayName
local realId=tostring(LocalPlayer.UserId)
local SENTINEL="\1\2MOSHIDE\2\1"
local finds={}
do
local seen={}
for _,v in ipairs({realName,realDisplay,realId})do
if type(v)=="string"and#v>=3 and not seen[v]then
seen[v]=true
table.insert(finds,v)
end
end
table.sort(finds,function(a,b)return#a>#b end)
end
local function fakeName()
local t=string.match(tostring(MosCfg.HideNameText or""),"^%s*(.-)%s*$")
if not t or t==""then t="MosCuChillDe"end
return string.sub(t,1,40)
end
local function plainReplace(s,find,rep)
local out,i,changed={},1,false
while true do
local a,b=string.find(s,find,i,true)
if not a then break end
table.insert(out,string.sub(s,i,a-1))
table.insert(out,rep)
i=b+1
changed=true
end
if not changed then return s,false end
table.insert(out,string.sub(s,i))
return table.concat(out),true
end
local function replaceAll(text)
if type(text)~="string"or text==""then return text,false end
local any=false
for _,f in ipairs(finds)do
local ch
text,ch=plainReplace(text,f,SENTINEL)
if ch then any=true end
end
if not any then return text,false end
text=plainReplace(text,SENTINEL,fakeName())
return text,true
end
local function isOwnGui(obj)
if obj:IsDescendantOf(LogoGui)then return true end
local g=Fluent and Fluent.GUI
if g and obj:IsDescendantOf(g)then return true end
return false
end
local function handle(obj)
if not(obj:IsA("TextLabel")or obj:IsA("TextButton"))then return end
if hooked[obj]or isOwnGui(obj)then return end
hooked[obj]=true
local busy=false
local function apply()
if busy or not hiding then return end
local t=obj.Text
local nt,ch=replaceAll(t)
if ch and nt~=t then
if origText[obj]==nil then origText[obj]=t end
busy=true
lastSet[obj]=nt
obj.Text=nt
busy=false
end
end
apply()
objConns[obj]=obj:GetPropertyChangedSignal("Text"):Connect(apply)
end
local function scan(container,restrictToWorldGui)
pcall(function()
for _,d in ipairs(container:GetDescendants())do
if not hiding then return end
if d:IsA("TextLabel")or d:IsA("TextButton")then
if not restrictToWorldGui or d:FindFirstAncestorWhichIsA("BillboardGui")or d:FindFirstAncestorWhichIsA("SurfaceGui")then
handle(d)
end
end
end
end)
pcall(function()
table.insert(containerConns,container.DescendantAdded:Connect(function(d)
if not hiding then return end
if d:IsA("TextLabel")or d:IsA("TextButton")then
if not restrictToWorldGui or d:FindFirstAncestorWhichIsA("BillboardGui")or d:FindFirstAncestorWhichIsA("SurfaceGui")then
handle(d)
end
end
end))
end)
end
local function setHumanoidName(char)
if not char then return end
pcall(function()
local hum=char:FindFirstChildOfClass("Humanoid")or char:WaitForChild("Humanoid",3)
if hum then
if hiding then
hum.DisplayName=fakeName()
else
hum.DisplayName=(realDisplay~=""and realDisplay)or realName
end
end
end)
end
local function disconnectAll()
for _,c in ipairs(containerConns)do pcall(function()c:Disconnect()end)end
table.clear(containerConns)
if charConn then pcall(function()charConn:Disconnect()end)charConn=nil end
for obj,c in pairs(objConns)do pcall(function()c:Disconnect()end)objConns[obj]=nil end
table.clear(hooked)
end
function MosX.ApplyHide(enabled)
if enabled==hiding then return end
hiding=enabled
if enabled then
task.spawn(function()
local pg=LocalPlayer:FindFirstChildOfClass("PlayerGui")or LocalPlayer:WaitForChild("PlayerGui",5)
if pg and hiding then scan(pg,false)end
if hiding then scan(workspace,true)end
if hiding then
pcall(function()scan(game:GetService("CoreGui"),false)end)
end
end)
setHumanoidName(LocalPlayer.Character)
charConn=LocalPlayer.CharacterAdded:Connect(function(char)
task.wait(0.5)
if hiding then setHumanoidName(char)end
end)
else
disconnectAll()
for obj,orig in pairs(origText)do
pcall(function()
if obj and obj.Parent and obj.Text==lastSet[obj]then
obj.Text=orig
end
end)
end
table.clear(origText)
table.clear(lastSet)
setHumanoidName(LocalPlayer.Character)
end
end
function MosX.SetHideName(text)
MosCfg.HideNameText=tostring(text or"")
MosSave()
if hiding then
MosX.ApplyHide(false)
MosX.ApplyHide(true)
end
end
function MosX.IsHiding()return hiding end
if MosCfg.HideNameAndID then
task.delay(1,function()MosX.ApplyHide(true)end)
end
end
local FlyToggleObj,NoclipToggleObj
local lastFlyToggleTime=0
local function toggleFly()
local now=tick()
if now-lastFlyToggleTime<0.25 then return end
lastFlyToggleTime=now
if FlyToggleObj then
FlyToggleObj:SetValue(not MosCfg.FlyEnabled)
else
MosCfg.FlyEnabled=not MosCfg.FlyEnabled
MosSave()
if MosCfg.FlyEnabled then startFly()else stopFly()end
end
end
local lastNoclipToggleTime=0
local function toggleNoclip()
local now=tick()
if now-lastNoclipToggleTime<0.25 then return end
lastNoclipToggleTime=now
if NoclipToggleObj then
NoclipToggleObj:SetValue(not MosCfg.NoclipEnabled)
else
MosCfg.NoclipEnabled=not MosCfg.NoclipEnabled
MosSave()
end
end
MosX.Build.Main=function()
Tabs.Main:AddSection("Auto Farm Fish")
do
local farmIslandList=GetIslandList()
if(MosCfg.SelectedFarmIsland==""or not table.find(farmIslandList,MosCfg.SelectedFarmIsland))and#farmIslandList>0 then
MosCfg.SelectedFarmIsland=farmIslandList[1]
end
Tabs.Main:AddDropdown("MosSelectIslandFarmDropdown",{
Title="Select Island",
Values=farmIslandList,
Default=MosCfg.SelectedFarmIsland~=""and MosCfg.SelectedFarmIsland or farmIslandList[1],
Multi=false,
Callback=function(Value)
MosCfg.SelectedFarmIsland=Value or""
MosSave()
if MosCfg.AutoFarmIsland then
StepAutoFarmIsland(LocalPlayer.Character)
end
end
})
end
Tabs.Main:AddToggle("MosAutoFarmIslandToggle",{
Title="Auto Farm",
Default=MosCfg.AutoFarmIsland,
Callback=function(Value)
MosCfg.AutoFarmIsland=Value
MosSave()
if Value then
StepAutoFarmIsland(LocalPlayer.Character)
if LocalPlayer.Character then
ApplyAntiConfuse(LocalPlayer.Character)
end
end
end
})
Tabs.Main:AddSection("Fishing")
Tabs.Main:AddToggle("MosAutoCastToggle",{
Title="Auto Cast",
Default=MosCfg.AutoCast,
Callback=function(Value)
MosCfg.AutoCast=Value
MosSave()
end
})
Tabs.Main:AddDropdown("MosAutoCastMethodDropdown",{
Title="Cast Method",
Values={"Instant","Delay"},
Default=MosCfg.AutoCastMethod or"Instant",
Multi=false,
Callback=function(Value)
MosCfg.AutoCastMethod=Value or"Instant"
MosSave()
end
})
Tabs.Main:AddSlider("MosCastDelaySlider",{
Title="Cast Delay Sec",
Default=MosCfg.CastDelay or 1,
Min=1,
Max=10,
Rounding=1,
Callback=function(Value)
MosCfg.CastDelay=Value
MosSave()
end
})
Tabs.Main:AddToggle("MosAutoReelToggle",{
Title="Auto Reel",
Default=MosCfg.AutoReel,
Callback=function(Value)
MosCfg.AutoReel=Value
MosSave()
end
})
Tabs.Main:AddSlider("MosReelDelaySlider",{
Title="Reel Delay (sec)",
Default=MosCfg.ReelDelay or 0.35,
Min=0.05,
Max=2,
Rounding=2,
Callback=function(Value)
MosCfg.ReelDelay=Value
MosSave()
end
})
local BestBaitToggleObj,PickedBaitToggleObj
BestBaitToggleObj=Tabs.Main:AddToggle("MosAutoEquipBestBaitToggle",{
Title="Auto Equip Best Bait",
Default=MosCfg.AutoEquipBestBait,
Callback=function(Value)
MosCfg.AutoEquipBestBait=Value
if Value then
if MosCfg.AutoEquipPickedBait then
MosCfg.AutoEquipPickedBait=false
if PickedBaitToggleObj then
pcall(function()PickedBaitToggleObj:SetValue(false)end)
end
end
task.spawn(function()
StepAutoEquipBestBait(true)
end)
end
MosSave()
end
})
PickedBaitToggleObj=Tabs.Main:AddToggle("MosAutoEquipPickedBaitToggle",{
Title="Auto Equip Bait",
Default=MosCfg.AutoEquipPickedBait,
Callback=function(Value)
MosCfg.AutoEquipPickedBait=Value
if Value then
if MosCfg.AutoEquipBestBait then
MosCfg.AutoEquipBestBait=false
if BestBaitToggleObj then
pcall(function()BestBaitToggleObj:SetValue(false)end)
end
end
task.spawn(function()
MosX.StepPickedBait(true)
end)
end
MosSave()
end
})
do
local function CollectBaits(deep)
local list,seen={},{}
local folder=Info:FindFirstChild("Bait")
if folder then
for _,child in ipairs(folder:GetChildren())do
if not seen[child.Name]then
seen[child.Name]=true
table.insert(list,child.Name)
end
end
end
if deep then
local items=Info:FindFirstChild("Item")
if items then
for _,child in ipairs(items:GetChildren())do
if child:IsA("ModuleScript")and not seen[child.Name]then
local ok,data=pcall(require,child)
if ok and type(data)=="table"and data.Type=="Bait"then
seen[child.Name]=true
table.insert(list,child.Name)
end
end
end
end
end
table.sort(list)
return list
end
local quick=CollectBaits(false)
if MosCfg.SelectedEquipBait==""and#quick>0 then
MosCfg.SelectedEquipBait=quick[1]
end
if MosCfg.SelectedEquipBait~=""and not table.find(quick,MosCfg.SelectedEquipBait)then
table.insert(quick,MosCfg.SelectedEquipBait)
end
local baitDropdown=Tabs.Main:AddDropdown("MosSelectEquipBaitDropdown",{
Title="Select Bait",
Values=quick,
Default=MosCfg.SelectedEquipBait~=""and MosCfg.SelectedEquipBait or quick[1],
Multi=false,
Callback=function(Value)
MosCfg.SelectedEquipBait=Value or""
MosSave()
if MosCfg.AutoEquipPickedBait then
task.spawn(function()MosX.StepPickedBait(true)end)
end
end
})
task.spawn(function()
local full=CollectBaits(true)
if#full>#quick then
pcall(function()baitDropdown:SetValues(full)end)
end
end)
end
Tabs.Main:AddSection("Equipment")
Tabs.Main:AddButton({Title="Equip Best Rod",Callback=TryEquipBestRod})
Tabs.Main:AddButton({
Title="Equip Best Bait",
Callback=function()
task.spawn(function()StepAutoEquipBestBait(true)end)
end
})
Tabs.Main:AddButton({Title="Equip Best Orb",Callback=TryEquipBestOrb})
Tabs.Main:AddSection("Skill")
Tabs.Main:AddToggle("MosAutoSkillToggle",{
Title="Auto Skill",
Default=MosCfg.AutoSkill,
Callback=function(Value)
MosCfg.AutoSkill=Value
if Value and LocalPlayer.Character then
ApplyAntiConfuse(LocalPlayer.Character)
end
MosSave()
end
})
local allSkillKeys={"Z","X","C","V"}
local defaultSkillSelection={}
for _,k in ipairs(MosCfg.SkillOrder)do
defaultSkillSelection[k]=true
end
local SkillDropdown=Tabs.Main:AddDropdown("MosSelectSkillDropdown",{
Title="Select Skill",
Values=allSkillKeys,
Default=defaultSkillSelection,
Multi=true
})
local origSkillDisplay=SkillDropdown.Display
if origSkillDisplay then
SkillDropdown.Display=function(self,...)
local savedValues=self.Values
self.Values=MosCfg.SkillOrder
local res=origSkillDisplay(self,...)
self.Values=savedValues
return res
end
end
SkillDropdown:OnChanged(function(Value)
if type(Value)~="table"then return end
for i=#MosCfg.SkillOrder,1,-1 do
local k=MosCfg.SkillOrder[i]
if not Value[k]then
table.remove(MosCfg.SkillOrder,i)
end
end
for _,k in ipairs(allSkillKeys)do
if Value[k]and not table.find(MosCfg.SkillOrder,k)then
table.insert(MosCfg.SkillOrder,k)
end
end
if SkillDropdown.Display then
SkillDropdown:Display()
end
MosSave()
end)
if SkillDropdown.Display then
SkillDropdown:Display()
end
Tabs.Main:AddSection("Boss")
do
local bossModes={"Normal","Hard","Nightmare"}
if not table.find(bossModes,MosCfg.BossMode)then
MosCfg.BossMode="Normal"
end
Tabs.Main:AddDropdown("MosSelectBossModeDropdown",{
Title="Select Boss Mode",
Values=bossModes,
Default=MosCfg.BossMode,
Multi=false,
Callback=function(Value)
MosCfg.BossMode=Value or"Normal"
MosSave()
end
})
end
Tabs.Main:AddToggle("MosAutoBossToggle",{
Title="Auto Enzo",
Default=MosCfg.AutoBoss,
Callback=function(Value)
MosCfg.AutoBoss=Value
MosSave()
if Value then
task.spawn(function()
CheckBossStatusOnToggle(false)
end)
end
end
})
Tabs.Main:AddToggle("MosAutoSecretBossToggle",{
Title="Auto Long DiaoHai",
Default=MosCfg.AutoSecretBoss,
Callback=function(Value)
MosCfg.AutoSecretBoss=Value
MosSave()
if Value then
task.spawn(function()
CheckBossStatusOnToggle(true)
end)
end
end
})
Tabs.Main:AddToggle("MosAutoMiniGameToggle",{
Title="Auto Mini Game",
Default=MosCfg.AutoMiniGame,
Callback=function(Value)
MosCfg.AutoMiniGame=Value
if Value and LocalPlayer.Character then
ApplyAntiConfuse(LocalPlayer.Character)
end
MosSave()
end
})
Tabs.Main:AddSlider("MosMiniGameDelaySlider",{
Title="Mini Game Delay (sec)",
Default=MosCfg.MiniGameDelay or 0.12,
Min=0.03,
Max=0.5,
Rounding=2,
Callback=function(Value)
MosCfg.MiniGameDelay=Value
MosSave()
end
})
Tabs.Main:AddSection("Filter Boss")
Tabs.Main:AddToggle("MosFilterBossToggle",{
Title="Filter Boss (cancel other fish)",
Default=MosCfg.FilterFishEnabled,
Callback=function(Value)
MosCfg.FilterFishEnabled=Value
MosSave()
end
})
do
local bossListItems=MosX.BossItems or{}
local function AttachDropdownSearch()
task.spawn(function()
task.wait(0.3)
pcall(function()
local libGui=Fluent.GUI or(LocalPlayer.PlayerGui and LocalPlayer.PlayerGui:FindFirstChild("ScreenGui"))
if not libGui then return end
for _,desc in ipairs(libGui:GetDescendants())do
if desc:IsA("ScrollingFrame")and desc.Parent and desc.Parent:IsA("Frame")and desc.Parent.Parent and desc.Parent.Parent:IsA("Frame")then
local holder=desc.Parent
local uiList=desc:FindFirstChildOfClass("UIListLayout")
if uiList and not holder:FindFirstChild("DropdownSearchBox")then
local hasMatch=false
for _,opt in ipairs(desc:GetChildren())do
if opt:IsA("TextButton")and opt:FindFirstChild("ButtonLabel")then
if table.find(bossListItems,opt.ButtonLabel.Text)then
hasMatch=true
break
end
end
end
if hasMatch then
local searchBox=Instance.new("TextBox")
searchBox.Name="DropdownSearchBox"
searchBox.Size=UDim2 .new(1,-12,0,26)
searchBox.Position=UDim2 .new(0,6,0,6)
searchBox.BackgroundColor3=Color3 .fromRGB(60,60,60)
searchBox.BackgroundTransparency=0.6
searchBox.Text=""
searchBox.TextColor3=Color3 .fromRGB(240,240,240)
searchBox.PlaceholderColor3=Color3 .fromRGB(170,170,170)
searchBox.PlaceholderText="Search boss..."
searchBox.Font=Enum.Font.Gotham
searchBox.TextSize=12
searchBox.TextXAlignment=Enum.TextXAlignment.Left
searchBox.ClearTextOnFocus=false
searchBox.Parent=holder
Instance.new("UICorner",searchBox).CornerRadius=UDim.new(0,5)
local boxPad=Instance.new("UIPadding",searchBox)
boxPad.PaddingLeft=UDim.new(0,8)
boxPad.PaddingRight=UDim.new(0,8)
desc.Position=UDim2 .new(0,5,0,36)
desc.Size=UDim2 .new(1,-5,1,-42)
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
local q=string.lower(string.match(searchBox.Text,"^%s*(.-)%s*$")or"")
for _,opt in ipairs(desc:GetChildren())do
if opt:IsA("TextButton")and opt:FindFirstChild("ButtonLabel")then
local optText=string.lower(opt.ButtonLabel.Text)
opt.Visible=(q==""or string.find(optText,q,1,true)~=nil)
end
end
desc.CanvasSize=UDim2 .new(0,0,0,uiList.AbsoluteContentSize.Y)
end)
end
end
end
end
end)
end)
end
local function DefaultsFrom(tbl)
local out={}
if type(tbl)=="table"then
for k,v in pairs(tbl)do
local name
if type(k)=="string"and v==true then
name=k
elseif type(v)=="string"and v~=""then
name=v
end
if name and table.find(bossListItems,name)and not table.find(out,name)then
table.insert(out,name)
end
end
end
return out
end
local function SelectedFrom(Value)
local selected={}
if type(Value)=="table"then
for bossName,isSelected in pairs(Value)do
if isSelected and table.find(bossListItems,bossName)and not table.find(selected,bossName)then
table.insert(selected,bossName)
end
end
end
return selected
end
MosCfg.FilterFishTarget=DefaultsFrom(MosCfg.FilterFishTarget)
Tabs.Main:AddDropdown("MosFilterBossDropdown",{
Title="Select Boss",
Values=bossListItems,
Default=MosCfg.FilterFishTarget,
Multi=true,
Callback=function(Value)
MosCfg.FilterFishTarget=SelectedFrom(Value)
MosSave()
end
})
AttachDropdownSearch()
Tabs.Main:AddSection("Auto Favorite Boss")
Tabs.Main:AddToggle("MosAutoFavoriteBossToggle",{
Title="Auto Favorite Boss Fish",
Default=MosCfg.AutoFavoriteBoss,
Callback=function(Value)
MosCfg.AutoFavoriteBoss=Value
MosSave()
if Value then
task.spawn(MosX.ScanAndFavoriteBossFish)
end
end
})
MosCfg.AutoFavoriteBossTarget=DefaultsFrom(MosCfg.AutoFavoriteBossTarget)
Tabs.Main:AddDropdown("MosAutoFavoriteBossDropdown",{
Title="Select Boss Fish",
Values=bossListItems,
Default=MosCfg.AutoFavoriteBossTarget,
Multi=true,
Callback=function(Value)
MosCfg.AutoFavoriteBossTarget=SelectedFrom(Value)
MosSave()
if MosCfg.AutoFavoriteBoss then
task.spawn(MosX.ScanAndFavoriteBossFish)
end
end
})
AttachDropdownSearch()
end
Tabs.Main:AddSection("Sacred Beast Hop")
do
local AutoHopSacredBeastToggleObj
local scanning=false
local function JumpToBeast(chuText)
local cf,island=MosX.FindBeastIsland(chuText)
local char=LocalPlayer.Character or cachedChar
local hrp=(char and char:FindFirstChild("HumanoidRootPart"))or cachedHrp
if cf and hrp then
hrp.CFrame=cf
end
pcall(function()
Fluent:Notify({
Title="Sacred Beast",
Content=cf and("Found Sacred Beast at "..tostring(island).."! Teleporting...")or("Sacred Beast appeared: "..tostring(chuText)),
Duration=6
})
end)
task.spawn(MosX.ReportBeast,chuText,island)
end
local function RunSacredCheck()
local ok,chuText=MosX.CheckChu(3.5)
if not MosCfg.AutoHopSacredBeast then return end
local gap=MosCfg.HopBossDelay or 5
if MosX.IsSacredBeastAppeared(chuText)then
MosCfg.AutoHopSacredBeast=false
MosSave()
if AutoHopSacredBeastToggleObj then
pcall(function()AutoHopSacredBeastToggleObj:SetValue(false)end)
end
JumpToBeast(chuText)
return
end
pcall(function()
local msg=(chuText and chuText~="")and chuText or"No dialogue"
Fluent:Notify({
Title="Sacred Beast Hop",
Content=msg.." (Hopping in "..tostring(gap).."s...)",
Duration=6
})
end)
task.wait(gap)
if MosCfg.AutoHopSacredBeast and not MosX.Unloaded then
MosX.DoServerHop("normal")
end
end
Tabs.Main:AddButton({
Title="Check Sacred Beast",
Callback=function()
if scanning then return end
scanning=true
task.spawn(function()
local ok,chuText=MosX.CheckChu(3.5)
if MosX.IsSacredBeastAppeared(chuText)then
JumpToBeast(chuText)
else
pcall(function()
Fluent:Notify({
Title="Sacred Beast",
Content=(chuText and chuText~="")and chuText or"No Sacred Beast spawned.",
Duration=4
})
end)
end
scanning=false
end)
end
})
AutoHopSacredBeastToggleObj=Tabs.Main:AddToggle("MosAutoHopSacredBeastToggle",{
Title="Auto Hop Sacred Beast",
Default=MosCfg.AutoHopSacredBeast,
Callback=function(Value)
MosCfg.AutoHopSacredBeast=Value
MosSave()
if Value then
task.spawn(RunSacredCheck)
end
end
})
Tabs.Main:AddSlider("MosHopBossDelaySlider",{
Title="Delay Hop",
Default=MosCfg.HopBossDelay or 5,
Min=5,
Max=20,
Rounding=1,
Callback=function(Value)
MosCfg.HopBossDelay=Value
MosSave()
end
})
Tabs.Main:AddInput("MosBossWebhookInput",{
Title="Webhook URL",
Default=MosCfg.BossWebhookUrl or"",
Placeholder="https://discord.com/api/webhooks/...",
Numeric=false,
Finished=false,
Callback=function(Value)
MosCfg.BossWebhookUrl=(tostring(Value or""):gsub("%s+",""))
MosSave()
end
})
task.spawn(function()
task.wait(2.5)
if not MosCfg.AutoHopSacredBeast then return end
repeat
task.wait(0.2)
until(game:IsLoaded()and LocalPlayer.Character and(LocalPlayer.Character:FindFirstChild("HumanoidRootPart")or LocalPlayer.Character:FindFirstChild("Head")))or not MosCfg.AutoHopSacredBeast
if not MosCfg.AutoHopSacredBeast then return end
task.wait(1)
RunSacredCheck()
end)
end
Tabs.Main:AddSection("Position")
Tabs.Main:AddButton({
Title="Save Position",
Callback=function()
local char=LocalPlayer.Character
local hrp=(char and char:FindFirstChild("HumanoidRootPart"))or cachedHrp
if hrp then
MosCfg.SavedPos={hrp.CFrame:GetComponents()}
MosSave()
pcall(function()
Fluent:Notify({
Title="Position",
Content="Saved Position!",
Duration=3
})
end)
end
end
})
Tabs.Main:AddToggle("MosAutoTPPosToggle",{
Title="Auto TP Position",
Default=MosCfg.AutoTPPos,
Callback=function(Value)
MosCfg.AutoTPPos=Value
MosSave()
if Value then
StepAutoTPPos(LocalPlayer.Character)
end
end
})
Tabs.Main:AddButton({
Title="Delete Position",
Callback=function()
MosCfg.SavedPos=false
MosSave()
pcall(function()
Fluent:Notify({
Title="Position",
Content="Deleted Position!",
Duration=3
})
end)
end
})
pcall(function()MosX.LoadingNote:Destroy()end)
end
MosX.Build.Quest=function()
Tabs.Quest:AddSection("Auto Ticket Quest")
MosX.TicketToggle=Tabs.Quest:AddToggle("MosAutoTicketQuestToggle",{
Title="Auto Claim Quest Ticket",
Default=MosCfg.AutoTicketQuest,
Callback=function(Value)
MosCfg.AutoTicketQuest=Value
if not Value then
lastTicketQuestTime=0
elseif MosX.ResetTicketLimit then
MosX.ResetTicketLimit()
end
MosSave()
end
})
Tabs.Quest:AddDropdown("MosTicketQuestModeDropdown",{
Title="Quest Mode",
Values={"Hard","Easy"},
Default=MosCfg.TicketQuestMode or"Hard",
Multi=false,
Callback=function(Value)
MosCfg.TicketQuestMode=Value or"Hard"
MosSave()
end
})
Tabs.Quest:AddSection("Zeng Tianguo Quest")
Tabs.Quest:AddToggle("MosAutoZengTianguoQuestToggle",{
Title="Auto Claim Zeng Tianguo Quest",
Default=MosCfg.AutoZengTianguoQuest,
Callback=function(Value)
MosCfg.AutoZengTianguoQuest=Value
MosSave()
end
})
Tabs.Quest:AddToggle("MosAutoFilterZengQuestToggle",{
Title="Auto Filter Quest",
Default=MosCfg.AutoFilterZengQuest,
Callback=function(Value)
MosCfg.AutoFilterZengQuest=Value
if Value then
pcall(function()
Fluent:Notify({
Title="Auto Filter Quest",
Content="Filtering for: Use any skill for 100 times",
Duration=4
})
end)
end
MosSave()
end
})
Tabs.Quest:AddSection("Daily Quest")
Tabs.Quest:AddToggle("MosAutoClaimDailyQuestToggle",{
Title="Auto Claim Daily Quest",
Default=MosCfg.AutoClaimDailyQuest,
Callback=function(Value)
MosCfg.AutoClaimDailyQuest=Value
MosSave()
end
})
end
MosX.Build.Player=function()
Tabs.Player:AddSection("Movement")
Tabs.Player:AddToggle("MosLoopSpeedToggle",{
Title="Walk Speed",
Default=MosCfg.LoopSpeedEnabled,
Callback=function(Value)
MosCfg.LoopSpeedEnabled=Value
MosSave()
end
})
Tabs.Player:AddSlider("MosWalkSpeedSlider",{
Title="Speed",
Default=MosCfg.WalkSpeed,
Min=16,
Max=250,
Rounding=0,
Callback=function(Value)
MosCfg.WalkSpeed=Value
MosSave()
end
})
FlyToggleObj=Tabs.Player:AddToggle("MosFlyToggle",{
Title="Fly",
Default=MosCfg.FlyEnabled,
Callback=function(Value)
MosCfg.FlyEnabled=Value
MosSave()
if Value then
startFly()
else
stopFly()
end
end
})
Tabs.Player:AddSlider("MosFlySpeedSlider",{
Title="Fly Speed",
Default=MosCfg.FlySpeed,
Min=1,
Max=20,
Rounding=1,
Callback=function(Value)
MosCfg.FlySpeed=Value
MosSave()
end
})
NoclipToggleObj=Tabs.Player:AddToggle("MosNoclipToggle",{
Title="Noclip",
Default=MosCfg.NoclipEnabled,
Callback=function(Value)
MosCfg.NoclipEnabled=Value
MosSave()
end
})
Tabs.Player:AddToggle("MosInfJumpToggle",{
Title="Infinite Jump",
Default=MosCfg.InfJumpEnabled,
Callback=function(Value)
MosCfg.InfJumpEnabled=Value
MosSave()
end
})
Tabs.Player:AddToggle("MosWalkOnWaterToggle",{
Title="Walk On Water",
Default=MosCfg.WalkOnWater,
Callback=function(Value)
MosCfg.WalkOnWater=Value
MosSave()
pcall(MosX.SetWalkOnWater,Value)
end
})
Tabs.Player:AddSection("Utility")
Tabs.Player:AddToggle("MosInstantInteractToggle",{
Title="Instant Interact",
Default=MosCfg.InstantInteract,
Callback=function(Value)
MosCfg.InstantInteract=Value
MosSave()
MosX.SetInstantInteract(Value)
end
})
Tabs.Player:AddSection("Hide Name")
Tabs.Player:AddToggle("MosHideNameAndIDToggle",{
Title="Hide Name & ID",
Default=MosCfg.HideNameAndID,
Callback=function(Value)
MosCfg.HideNameAndID=Value
MosSave()
MosX.ApplyHide(Value)
end
})
Tabs.Player:AddInput("MosHideNameInput",{
Title="Hide Name (custom)",
Default=MosCfg.HideNameText,
Placeholder="Type any name...",
Numeric=false,
Finished=true,
Callback=function(Value)
MosX.SetHideName(Value)
pcall(function()
Fluent:Notify({
Title="Hide Name",
Content="Hidden name: "..tostring(MosCfg.HideNameText),
Duration=3
})
end)
end
})
Tabs.Player:AddSection("Upgrade Character")
do
local modes={"Level + Cash","Cash + Ticket","Ticket + Level"}
if not table.find(modes,MosCfg.UpgradeCharType)then
MosCfg.UpgradeCharType="Level + Cash"
end
Tabs.Player:AddDropdown("MosUpgradeTypeDropdown",{
Title="Upgrade Type",
Values=modes,
Default=MosCfg.UpgradeCharType,
Multi=false,
Callback=function(Value)
MosCfg.UpgradeCharType=Value or"Level + Cash"
MosSave()
end
})
Tabs.Player:AddSlider("MosUpgradeDelaySlider",{
Title="Delay Min",
Default=MosCfg.UpgradeCharDelay or 5,
Min=1,
Max=10,
Rounding=0,
Callback=function(Value)
MosCfg.UpgradeCharDelay=Value
MosSave()
end
})
Tabs.Player:AddToggle("MosAutoUpgradeCharToggle",{
Title="Auto Upgrade Character",
Default=MosCfg.AutoUpgradeChar,
Callback=function(Value)
MosCfg.AutoUpgradeChar=Value
if not Value then
MosX.ResetUpgradeTimer()
end
MosSave()
end
})
Tabs.Player:AddButton({
Title="Upgrade Character",
Callback=function()
MosX.UpgradeChar(MosCfg.UpgradeCharType)
end
})
end
end
MosX.Build.Teleport=function()
Tabs.Teleport:AddSection("Island")
do
local islandList=GetIslandList()
if(MosCfg.SelectedIsland==""or not table.find(islandList,MosCfg.SelectedIsland))and#islandList>0 then
MosCfg.SelectedIsland=islandList[1]
end
Tabs.Teleport:AddDropdown("MosSelectIslandDropdown",{
Title="Select Island",
Values=islandList,
Default=MosCfg.SelectedIsland~=""and MosCfg.SelectedIsland or islandList[1],
Multi=false,
Callback=function(Value)
MosCfg.SelectedIsland=Value or""
MosSave()
end
})
end
Tabs.Teleport:AddButton({
Title="Teleport To Island",
Callback=function()
TeleportToIsland(MosCfg.SelectedIsland)
end
})
Tabs.Teleport:AddSection("NPC")
do
local npcList=GetNPCList()
if(MosCfg.SelectedNPC==""or not table.find(npcList,MosCfg.SelectedNPC))and#npcList>0 then
MosCfg.SelectedNPC=npcList[1]
end
local NPCDropdown=Tabs.Teleport:AddDropdown("MosSelectNPCDropdown",{
Title="Select NPC",
Values=npcList,
Default=MosCfg.SelectedNPC~=""and MosCfg.SelectedNPC or npcList[1],
Multi=false,
Callback=function(Value)
MosCfg.SelectedNPC=Value or""
MosSave()
end
})
Tabs.Teleport:AddButton({
Title="Teleport To NPC",
Callback=function()
local chosen=(NPCDropdown and NPCDropdown.Value)or MosCfg.SelectedNPC
TeleportToNPC(chosen)
end
})
Tabs.Teleport:AddButton({
Title="Refresh NPC List",
Callback=function()
local updated=GetNPCList()
if#updated>0 then
pcall(function()NPCDropdown:SetValues(updated)end)
if not table.find(updated,MosCfg.SelectedNPC)then
MosCfg.SelectedNPC=updated[1]
pcall(function()NPCDropdown:SetValue(updated[1])end)
MosSave()
end
end
end
})
end
Tabs.Teleport:AddSection("Player")
do
local playerList=GetPlayerList()
if#playerList==0 then
playerList={"None"}
end
if(MosCfg.SelectedPlayer==""or not table.find(playerList,MosCfg.SelectedPlayer))and#playerList>0 then
MosCfg.SelectedPlayer=playerList[1]
end
local PlayerDropdown=Tabs.Teleport:AddDropdown("MosSelectPlayerDropdown",{
Title="Select Player",
Values=playerList,
Default=MosCfg.SelectedPlayer~=""and MosCfg.SelectedPlayer or playerList[1],
Multi=false,
Callback=function(Value)
MosCfg.SelectedPlayer=Value or""
MosSave()
end
})
local function RefreshDropdownPlayers()
local updated=GetPlayerList()
if#updated==0 then
updated={"None"}
end
if PlayerDropdown and PlayerDropdown.SetValues then
PlayerDropdown:SetValues(updated)
if not table.find(updated,MosCfg.SelectedPlayer)then
PlayerDropdown:SetValue(updated[1])
MosCfg.SelectedPlayer=updated[1]
MosSave()
end
end
end
Players.PlayerAdded:Connect(function()
task.wait(0.5)
RefreshDropdownPlayers()
end)
Players.PlayerRemoving:Connect(function()
task.wait(0.5)
RefreshDropdownPlayers()
end)
Tabs.Teleport:AddButton({
Title="Teleport To Player",
Callback=function()
local chosen=(PlayerDropdown and PlayerDropdown.Value)or MosCfg.SelectedPlayer
if chosen and chosen~="None"then
TeleportToPlayer(chosen)
end
end
})
end
end
MosX.Build.Shop=function()
Tabs.Shop:AddSection("Selling")
Tabs.Shop:AddToggle("MosAutoSellToggle",{
Title="Auto Sell All",
Default=MosCfg.AutoSell,
Callback=function(Value)
MosCfg.AutoSell=Value
if not Value then
lastSellTime=0
end
MosSave()
end
})
Tabs.Shop:AddDropdown("MosAutoSellMethodDropdown",{
Title="Sell Method",
Values={"Spam","Delay","Sell When Full Inventory"},
Default=MosCfg.AutoSellMethod or"Delay",
Multi=false,
Callback=function(Value)
MosCfg.AutoSellMethod=Value or"Delay"
MosSave()
end
})
Tabs.Shop:AddSlider("MosAutoSellDelaySlider",{
Title="Sell Delay Min",
Default=MosCfg.SellDelay or 1,
Min=1,
Max=10,
Rounding=1,
Callback=function(Value)
MosCfg.SellDelay=Value
MosSave()
end
})
Tabs.Shop:AddButton({
Title="Sell All Fish",
Callback=function()
SellFish:FireServer("All")
end
})
Tabs.Shop:AddButton({
Title="Sell One Fish",
Callback=function()
SellFish:FireServer("One")
end
})
Tabs.Shop:AddSection("Buy Bait")
do
local buyBaitList=GetBuyableBaits()
if MosCfg.SelectedBuyBait==""and#buyBaitList>0 then
MosCfg.SelectedBuyBait=buyBaitList[1]
end
Tabs.Shop:AddDropdown("MosSelectBuyBaitDropdown",{
Title="Select Bait",
Values=buyBaitList,
Default=MosCfg.SelectedBuyBait~=""and MosCfg.SelectedBuyBait or buyBaitList[1],
Multi=false,
Callback=function(Value)
MosCfg.SelectedBuyBait=Value or""
MosSave()
end
})
end
Tabs.Shop:AddInput("MosBuyBaitAmountInput",{
Title="Buy Amount",
Default=tostring(MosCfg.BuyBaitAmount or 1),
Numeric=true,
Finished=false,
Placeholder="1",
Callback=function(Value)
MosCfg.BuyBaitAmount=math.max(1,math.floor(tonumber(Value)or 1))
MosSave()
end
})
Tabs.Shop:AddInput("MosBuyBaitDelayInput",{
Title="Buy Delay Min",
Default=tostring(MosCfg.BuyBaitDelay or 1),
Numeric=true,
Finished=false,
Placeholder="1",
Callback=function(Value)
MosCfg.BuyBaitDelay=math.max(1,math.floor(tonumber(Value)or 1))
MosSave()
end
})
Tabs.Shop:AddToggle("MosAutoBuyBaitToggle",{
Title="Auto Buy Bait",
Default=MosCfg.AutoBuyBait,
Callback=function(Value)
MosCfg.AutoBuyBait=Value
if not Value then
lastBuyBaitTime=0
end
MosSave()
end
})
Tabs.Shop:AddButton({
Title="Buy Bait",
Callback=function()
DoBuyBait(MosCfg.SelectedBuyBait,MosCfg.BuyBaitAmount)
end
})
Tabs.Shop:AddToggle("MosAutoBuyBestRodToggle",{
Title="Auto Buy Best Rod",
Default=MosCfg.AutoBuyBestRod,
Callback=function(Value)
MosCfg.AutoBuyBestRod=Value
MosSave()
end
})
Tabs.Shop:AddSection("Craft Bait")
do
local baitList=GetCraftableBaits()
if MosCfg.SelectedBait==""and#baitList>0 then
MosCfg.SelectedBait=baitList[1]
end
Tabs.Shop:AddDropdown("MosSelectBaitDropdown",{
Title="Select Bait",
Values=baitList,
Default=MosCfg.SelectedBait~=""and MosCfg.SelectedBait or baitList[1],
Multi=false,
Callback=function(Value)
MosCfg.SelectedBait=Value or""
MosSave()
end
})
end
Tabs.Shop:AddInput("MosBaitAmountInput",{
Title="Craft Amount",
Default=tostring(MosCfg.BaitAmount or 1),
Numeric=true,
Finished=false,
Placeholder="1",
Callback=function(Value)
MosCfg.BaitAmount=math.max(1,math.floor(tonumber(Value)or 1))
MosSave()
end
})
Tabs.Shop:AddToggle("MosAutoCraftBaitToggle",{
Title="Auto Craft Bait",
Default=MosCfg.AutoCraftBait,
Callback=function(Value)
MosCfg.AutoCraftBait=Value
MosSave()
end
})
Tabs.Shop:AddButton({
Title="Craft Bait",
Callback=function()
if MosCfg.SelectedBait~=""then
CraftBaitEvent:FireServer(MosCfg.SelectedBait,math.max(1,math.floor(tonumber(MosCfg.BaitAmount)or 1)))
end
end
})
Tabs.Shop:AddSection("Craft Rod")
do
local rodList=GetCraftableRods()
if MosCfg.SelectedRod==""and#rodList>0 then
MosCfg.SelectedRod=rodList[1]
end
Tabs.Shop:AddDropdown("MosSelectRodDropdown",{
Title="Select Rod",
Values=rodList,
Default=MosCfg.SelectedRod~=""and MosCfg.SelectedRod or rodList[1],
Multi=false,
Callback=function(Value)
MosCfg.SelectedRod=Value or""
MosSave()
end
})
end
Tabs.Shop:AddToggle("MosAutoCraftRodToggle",{
Title="Auto Craft Rod",
Default=MosCfg.AutoCraftRod,
Callback=function(Value)
MosCfg.AutoCraftRod=Value
MosSave()
end
})
Tabs.Shop:AddButton({
Title="Craft Rod",
Callback=function()
if MosCfg.SelectedRod~=""then
CraftRodEvent:FireServer(MosCfg.SelectedRod)
end
end
})
Tabs.ESP:AddToggle("MosESPPlayers",{
Title="ESP Players",
Default=MosCfg.ESPEnabled,
Callback=function(Value)
MosCfg.ESPEnabled=Value
MosSave()
if not Value then
clearPlayerESP()
end
end
})
end
MosX.Build.Misc=function()
Tabs.Misc:AddSection("Visual")
Tabs.Misc:AddToggle("MosAntiAFKToggle",{
Title="Anti AFK",
Default=MosCfg.AntiAFK,
Callback=function(Value)
MosCfg.AntiAFK=Value
MosSave()
end
})
Tabs.Misc:AddToggle("MosFullBrightToggle",{
Title="FullBright",
Default=MosCfg.FullBright,
Callback=function(Value)
MosCfg.FullBright=Value
MosSave()
if Value then
ApplyLightingSettings()
else
RestoreFullBright()
if MosCfg.NoFog then
ApplyLightingSettings()
end
end
end
})
Tabs.Misc:AddToggle("MosNoFogToggle",{
Title="No Fog",
Default=MosCfg.NoFog,
Callback=function(Value)
MosCfg.NoFog=Value
MosSave()
if Value then
ApplyLightingSettings()
else
RestoreNoFog()
if MosCfg.FullBright then
ApplyLightingSettings()
end
end
end
})
Tabs.Misc:AddSection("Codes")
Tabs.Misc:AddButton({
Title="Redeem All Codes",
Callback=function()
RedeemAllCodes()
end
})
Tabs.Misc:AddSection("Auto")
Tabs.Misc:AddToggle("MosAutoDailyToggle",{
Title="Auto Claim Daily Reward",
Default=MosCfg.AutoDaily,
Callback=function(Value)
MosCfg.AutoDaily=Value
MosSave()
end
})
Tabs.Misc:AddToggle("MosAutoRedeemToggle",{
Title="Auto Redeem Codes",
Default=MosCfg.AutoRedeem,
Callback=function(Value)
MosCfg.AutoRedeem=Value
MosSave()
end
})
Tabs.Misc:AddToggle("MosFpsBoostToggle",{
Title="FPS Boost",
Default=MosCfg.FpsBoost,
Callback=function(Value)
MosCfg.FpsBoost=Value
MosSave()
SetFpsBoost(Value)
end
})
Tabs.Misc:AddSection("Summon")
do
local bannerList=GetBanners()
if MosCfg.SelectedBanner==""or not table.find(bannerList,MosCfg.SelectedBanner)then
MosCfg.SelectedBanner=bannerList[1]
end
Tabs.Misc:AddDropdown("MosBannerDropdown",{
Title="Banner",
Values=bannerList,
Default=MosCfg.SelectedBanner,
Multi=false,
Callback=function(Value)
MosCfg.SelectedBanner=Value or""
MosSave()
end
})
end
Tabs.Misc:AddToggle("MosSummonX10Toggle",{
Title="x10 Summon",
Default=MosCfg.SummonX10,
Callback=function(Value)
MosCfg.SummonX10=Value
MosSave()
end
})
Tabs.Misc:AddToggle("MosAutoSummonToggle",{
Title="Auto Summon",
Default=MosCfg.AutoSummon,
Callback=function(Value)
MosCfg.AutoSummon=Value
MosSave()
end
})
Tabs.Misc:AddSection("Remote Menus")
Tabs.Misc:AddButton({
Title="Open Skill Upgrade",
Callback=function()
local state=OpenMenuFrameRemotely("SkillUpgrade")
Fluent:Notify({
Title="Remote UI",
Content=state and"Opened Skill Upgrade"or"Closed Skill Upgrade",
Duration=2
})
end
})
Tabs.Misc:AddButton({
Title="Open Learn Skill",
Callback=function()
local state=OpenMenuFrameRemotely("LearnSkill")
Fluent:Notify({
Title="Remote UI",
Content=state and"Opened Learn Skill"or"Closed Learn Skill",
Duration=2
})
end
})
Tabs.Misc:AddButton({
Title="Open Exchange UI",
Callback=function()
local state=OpenMenuFrameRemotely("Exchange")
Fluent:Notify({
Title="Remote UI",
Content=state and"Opened Item Exchange"or"Closed Item Exchange",
Duration=2
})
end
})
Tabs.Misc:AddButton({
Title="Open Trait",
Callback=function()
local state=OpenMenuFrameRemotely("Trait")
Fluent:Notify({
Title="Remote UI",
Content=state and"Opened Trait"or"Closed Trait",
Duration=2
})
end
})
Tabs.Misc:AddButton({
Title="Open Guild",
Callback=function()
local state=false
pcall(function()
local guildFetch=Events:FindFirstChild("GuildFetch")
if guildFetch and guildFetch:IsA("RemoteFunction")then
guildFetch:InvokeServer()
end
end)
pcall(function()
local pg=LocalPlayer:FindFirstChild("PlayerGui")
local mg=(pg and pg:FindFirstChild("MainGui"))or MainGui
if not mg then return end
local targetFrame=nil
for _,desc in ipairs(mg:GetDescendants())do
if desc.Name=="MenuFrame"and desc:FindFirstChild("InfoFrame")then
targetFrame=desc
break
end
end
if not targetFrame then
for _,desc in ipairs(mg:GetDescendants())do
if desc.Name=="MenuFrame"then
targetFrame=desc
break
end
end
end
if targetFrame then
local isActuallyOpen=targetFrame.Visible and targetFrame.Parent and targetFrame.Parent:IsA("GuiObject")and targetFrame.Parent.Visible
if isActuallyOpen then
targetFrame.Visible=false
state=false
else
local p=targetFrame
while p and p:IsA("GuiObject")do
p.Visible=true
p=p.Parent
end
targetFrame.Visible=true
targetFrame.Position=UDim2 .new(0.5,-targetFrame.AbsoluteSize.X/2,0.5,-targetFrame.AbsoluteSize.Y/2)
state=true
end
end
end)
pcall(function()
Fluent:Notify({
Title="Remote UI",
Content=state and"Opened Guild"or"Closed Guild",
Duration=2
})
end)
end
})
Tabs.Misc:AddButton({
Title="Open The Shadow",
Callback=function()
task.spawn(function()
local opened=false
pcall(function()
local npc=workspace:WaitForChild("NPC",5)
local funcs=npc and npc:WaitForChild("Function",5)
local shadow=funcs and funcs:WaitForChild("The Shadow",5)
local remote=Events:FindFirstChild("ChooseDialogueOption")
if shadow and remote then
remote:FireServer("The Shadow",1,"OpenUPGChar",{shadow})
opened=true
end
end)
pcall(function()
Fluent:Notify({
Title="Remote UI",
Content=opened and"Opened The Shadow"or"The Shadow not found",
Duration=2
})
end)
end)
end
})
Tabs.Misc:AddSection("Index")
Tabs.Misc:AddButton({
Title="Unlock All Fish",
Callback=function()
local changed=0
pcall(function()
local idx=PlayerData:FindFirstChild("Index")
if idx then
for _,v in ipairs(idx:GetChildren())do
if v:IsA("BoolValue")and not v.Value then
v.Value=true
changed=changed+1
end
end
end
end)
pcall(function()
local pg=LocalPlayer:FindFirstChild("PlayerGui")
local mg=pg and pg:FindFirstChild("MainGui")
local menu=mg and mg:FindFirstChild("Menu")
local idxMenu=menu and menu:FindFirstChild("Index")
local frame=idxMenu and idxMenu:FindFirstChild("IndexFrame")
local listFrame=frame and frame:FindFirstChild("Indexlist")
local side=frame and frame:FindFirstChild("Info")
local reward=side and side:FindFirstChild("Reward")
if not listFrame then return end
for _,item in ipairs(listFrame:GetChildren())do
if item:IsA("GuiObject")and item.Name~="Template"then
local btn=item:FindFirstChild("Button")
if btn then
local title=btn:FindFirstChild("Title")
local img=btn:FindFirstChild("Image")
if title then title.Text=item.Name end
if img then img.ImageColor3=Color3 .new(1,1,1)end
end
local lock=item:FindFirstChild("Lock")
if lock then lock.Visible=false end
if btn and not item:GetAttribute("MosHooked")then
item:SetAttribute("MosHooked",true)
MosX.Track(btn.MouseButton1Click:Connect(function()
pcall(function()
local inv=Info:FindFirstChild("Inventory")
local mod=inv and inv:FindFirstChild(item.Name)
if not mod then return end
local fish=require(mod)
if side then
local old=side:FindFirstChild("FishView")
if old then old:Destroy()end
local tpl=(fish.Boss==true)and side.Template.Boss or side.Template.Normal
if tpl then
local view=tpl:Clone()
view.Name="FishView"
view.Visible=true
view.Parent=side
local pic=view:FindFirstChild("Button")and view.Button:FindFirstChild("Image")
if pic then pic.Image=fish.Image or""end
end
end
if reward then
reward.Visible=true
local t=reward:FindFirstChild("Title")
if t then
t.Text=item.Name
t.Visible=true
end
local w=reward:FindFirstChild("Weight")
if w and fish.MinKg and fish.MaxKg then
w.Text=tostring(fish.MinKg).." KG - "..tostring(fish.MaxKg).." KG"
w.Visible=true
end
end
end)
end))
end
end
end
end)
pcall(function()
Fluent:Notify({
Title="Index",
Content="Unlocked all fish in Index ("..tostring(changed).." updated)",
Duration=3
})
end)
end
})
Tabs.Misc:AddSection("Dumb Guy")
Tabs.Misc:AddToggle("MosAutoGiveFishToggle",{
Title="Auto Give Fish (non-favorite)",
Default=MosCfg.AutoGiveFish,
Callback=function(Value)
MosCfg.AutoGiveFish=Value
MosSave()
end
})
end
MosX.Build.Settings=function()
Tabs.Settings:AddKeybind("MosToggleUIKeybind",{
Title="Minimize UI Keybind",
Mode="Toggle",
Default="LeftControl",
ChangedCallback=function(NewKey)
local keyCode=typeof(NewKey)=="EnumItem"and NewKey or Enum.KeyCode[tostring(NewKey)]or Enum.KeyCode.LeftControl
minimizeKey=keyCode
Window.MinimizeKey=keyCode
end
})
Tabs.Settings:AddSection("Theme & Color")
do
local themeList=MosX.ThemeList
pcall(function()
if type(Fluent.Themes)=="table"and#Fluent.Themes>0 then
themeList=Fluent.Themes
end
end)
if not table.find(themeList,MosCfg.ThemeName)then
MosCfg.ThemeName=themeList[1]
end
Tabs.Settings:AddDropdown("MosThemeDropdown",{
Title="UI Theme (color)",
Values=themeList,
Default=MosCfg.ThemeName,
Multi=false,
Callback=function(Value)
if not Value then return end
MosCfg.ThemeName=Value
MosSave()
pcall(function()Fluent:SetTheme(Value)end)
end
})
Tabs.Settings:AddColorpicker("LogoAccentColor",{
Title="Logo / Accent Color",
Default=MosAccent,
Callback=function(Value)
if typeof(Value)~="Color3"then return end
MosAccent=Value
MosCfg.AccentColor={
math.floor(Value.R*255+0.5),
math.floor(Value.G*255+0.5),
math.floor(Value.B*255+0.5)
}
MosSave()
MosX.ApplyAccent(Value)
end
})
end
Tabs.Settings:AddSection("Auto Execute")
Tabs.Settings:AddParagraph({
Title="Auto Execute",
Content="Re-runs Mos after server hop / rejoin. Save this script as MosChill.lua in your executor's workspace folder."
})
Tabs.Settings:AddToggle("MosAutoExeToggle",{
Title="Auto Execute",
Default=MosCfg.AutoExe or false,
Callback=function(Value)
MosCfg.AutoExe=Value
MosSave()
end
})
Tabs.Settings:AddSection("Keybinds")
Tabs.Settings:AddToggle("MosDisableAllKeybindsToggle",{
Title="Disable Keybinds",
Default=MosCfg.DisableAllKeybinds or false,
Callback=function(Value)
MosCfg.DisableAllKeybinds=Value
MosSave()
end
})
local function getFlyKey()
local k=MosCfg.FlyKeybind or"F"
if typeof(k)=="EnumItem"then return k end
local name=tostring(k):gsub("Enum%.KeyCode%.","")
return Enum.KeyCode[name]or Enum.KeyCode.F
end
Tabs.Settings:AddKeybind("MosFlyKeybind",{
Title="Fly Keybind",
Mode="Toggle",
Default=MosCfg.FlyKeybind or"F",
Callback=function()
if not MosCfg.DisableAllKeybinds and MosCfg.FlyKeybindEnabled~=false then
toggleFly()
end
end,
ChangedCallback=function(NewKey)
local keyCode=typeof(NewKey)=="EnumItem"and NewKey or Enum.KeyCode[tostring(NewKey):gsub("Enum%.KeyCode%.","")]
if keyCode then
MosCfg.FlyKeybind=keyCode.Name
MosSave()
end
end
})
local function getNoclipKey()
local k=MosCfg.NoclipKeybind or"J"
if typeof(k)=="EnumItem"then return k end
local name=tostring(k):gsub("Enum%.KeyCode%.","")
return Enum.KeyCode[name]or Enum.KeyCode.J
end
Tabs.Settings:AddKeybind("MosNoclipKeybind",{
Title="Noclip Keybind",
Mode="Toggle",
Default=MosCfg.NoclipKeybind or"J",
Callback=function()
if not MosCfg.DisableAllKeybinds and MosCfg.NoclipKeybindEnabled~=false then
toggleNoclip()
end
end,
ChangedCallback=function(NewKey)
local keyCode=typeof(NewKey)=="EnumItem"and NewKey or Enum.KeyCode[tostring(NewKey):gsub("Enum%.KeyCode%.","")]
if keyCode then
MosCfg.NoclipKeybind=keyCode.Name
MosSave()
end
end
})
UserInputService.InputBegan:Connect(function(input,gameProcessed)
if MosX.Unloaded then return end
if MosCfg.DisableAllKeybinds then return end
if UserInputService:GetFocusedTextBox()then return end
if input.UserInputType==Enum.UserInputType.Keyboard then
if MosCfg.FlyKeybindEnabled~=false and input.KeyCode==getFlyKey()then
toggleFly()
elseif MosCfg.NoclipKeybindEnabled~=false and input.KeyCode==getNoclipKey()then
toggleNoclip()
end
end
end)
do
local function HopLowServer()
task.spawn(function()
local placeId=game.PlaceId
local curJobId=game.JobId
local requestFn=(syn and syn.request)or(http and http.request)or http_request or(fluxus and fluxus.request)or request
local targetServer=nil
pcall(function()
Fluent:Notify({
Title="Server Hop",
Content="Searching for low player server...",
Duration=4
})
end)
local cursor=""
local attempts=0
while attempts<5 and not targetServer do
attempts=attempts+1
local url="https://games.roblox.com/v1/games/"..tostring(placeId).."/servers/Public?sortOrder=Asc&limit=100"
if cursor~=""then
url=url.."&cursor="..cursor
end
local raw=nil
if requestFn then
local res=requestFn({Url=url,Method="GET"})
if res and res.Body then
raw=res.Body
end
else
local ok,res=pcall(game.HttpGet,game,url)
if ok then raw=res end
end
if raw then
local data=nil
pcall(function()data=HttpService:JSONDecode(raw)end)
if data and data.data then
local servers={}
for _,s in ipairs(data.data)do
if type(s)=="table"and s.id and s.id~=curJobId then
local playing=tonumber(s.playing)or 0
local maxP=tonumber(s.maxPlayers)or 1
if playing<maxP and playing>0 then
table.insert(servers,s)
end
end
end
table.sort(servers,function(a,b)
return(tonumber(a.playing)or 0)<(tonumber(b.playing)or 0)
end)
if#servers>0 then
targetServer=servers[1]
break
end
if data.nextPageCursor and data.nextPageCursor~=""then
cursor=data.nextPageCursor
else
break
end
else
break
end
else
break
end
task.wait(0.5)
end
if targetServer and targetServer.id then
pcall(function()
Fluent:Notify({
Title="Server Hop",
Content="Found server with "..tostring(targetServer.playing).." players! Teleporting...",
Duration=4
})
end)
task.wait(0.5)
TeleportService:TeleportToPlaceInstance(placeId,targetServer.id,LocalPlayer)
else
pcall(function()
Fluent:Notify({
Title="Server Hop",
Content="Couldn't find low player server. Teleporting to random server...",
Duration=4
})
end)
task.wait(0.5)
TeleportService:Teleport(placeId,LocalPlayer)
end
end)
end
Tabs.Misc:AddSection("Server")
Tabs.Misc:AddButton({
Title="Rejoin",
Callback=function()
pcall(function()
Fluent:Notify({
Title="Rejoin",
Content="Rejoining current server...",
Duration=3
})
end)
task.wait(0.3)
TeleportService:TeleportToPlaceInstance(game.PlaceId,game.JobId,LocalPlayer)
end
})
Tabs.Misc:AddButton({
Title="Server Hop Low Players",
Callback=function()
HopLowServer()
end
})
end
do
Tabs.Misc:AddSection("Server Tools")
local ServerTimeParagraph=Tabs.Misc:AddParagraph({
Title="Server Time : 00:00:00",
Content=""
})
task.spawn(function()
while not MosX.Unloaded do
local uptime=workspace.DistributedGameTime or time()
local d=math.floor(uptime/86400)
local h=math.floor((uptime%86400)/3600)
local m=math.floor((uptime%3600)/60)
local s=math.floor(uptime%60)
local timeText=(d>0 and string.format("%dd %02d:%02d:%02d",d,h,m,s)or string.format("%02d:%02d:%02d",h,m,s))
pcall(function()
ServerTimeParagraph:SetTitle("Server Time : "..timeText)
end)
task.wait(1)
end
end)
Tabs.Misc:AddButton({
Title="Server Hop (Random)",
Callback=function()
MosX.DoServerHop("normal")
end
})
Tabs.Misc:AddSection("JobId")
local targetJobId=""
Tabs.Misc:AddInput("MosJobIdInput",{
Title="JobId",
Default="",
Placeholder="Enter JobId...",
Numeric=false,
Finished=false,
Callback=function(Value)
targetJobId=(tostring(Value or""):gsub("%s+",""))
end
})
Tabs.Misc:AddButton({
Title="Join JobId",
Callback=function()
if targetJobId==""then
pcall(function()
Fluent:Notify({Title="Join JobId",Content="Please enter a valid JobId",Duration=3})
end)
return
end
MosX.QueueReExecute()
pcall(function()
Fluent:Notify({Title="Join JobId",Content="Teleporting to "..targetJobId.."...",Duration=3})
end)
task.wait(0.3)
TeleportService:TeleportToPlaceInstance(game.PlaceId,targetJobId,LocalPlayer)
end
})
Tabs.Misc:AddButton({
Title="Copy Current JobId",
Callback=function()
local currentJobId=tostring(game.JobId or"")
local copied=false
pcall(function()
if setclipboard then
setclipboard(currentJobId)
copied=true
elseif toclipboard then
toclipboard(currentJobId)
copied=true
elseif syn and syn.write_clipboard then
syn.write_clipboard(currentJobId)
copied=true
end
end)
pcall(function()
Fluent:Notify({
Title="Copy JobId",
Content=copied and("Copied: "..currentJobId)or("JobId: "..currentJobId),
Duration=4
})
end)
end
})
Tabs.Misc:AddSection("Weather Hop")
local AutoHopWeatherToggleObj
local function CheckWeatherAndHop()
local curWeather=tostring(workspace:GetAttribute("Weather")or"")
local targetWeather=tostring(MosCfg.SelectedWeather or"")
if curWeather==""then
local startWait=os.clock()
while(os.clock()-startWait)<3 and curWeather==""do
curWeather=tostring(workspace:GetAttribute("Weather")or"")
task.wait(0.1)
end
end
if not MosCfg.AutoHopWeather then return end
if curWeather~=""and string.lower(curWeather)==string.lower(targetWeather)then
MosCfg.AutoHopWeather=false
MosSave()
if AutoHopWeatherToggleObj then
pcall(function()AutoHopWeatherToggleObj:SetValue(false)end)
end
pcall(function()
Fluent:Notify({
Title="Weather Hop",
Content="Found target weather: "..curWeather.."! Auto Hop stopped.",
Duration=6
})
end)
task.spawn(MosX.ReportWeather,curWeather,"Found target weather: **"..curWeather.."**")
return
end
pcall(function()
Fluent:Notify({
Title="Weather Hop",
Content="Current: "..(curWeather~=""and curWeather or"Unknown")..". Target: "..targetWeather..". Hopping in "..tostring(MosCfg.HopWeatherDelay or 5).."s...",
Duration=5
})
end)
task.wait(MosCfg.HopWeatherDelay or 5)
if MosCfg.AutoHopWeather and not MosX.Unloaded then
MosX.DoServerHop("normal")
end
end
AutoHopWeatherToggleObj=Tabs.Misc:AddToggle("MosAutoHopWeatherToggle",{
Title="Auto Hop Weather",
Default=MosCfg.AutoHopWeather,
Callback=function(Value)
MosCfg.AutoHopWeather=Value
MosSave()
if Value then
task.spawn(CheckWeatherAndHop)
end
end
})
local weatherList=MosX.GetWeatherList()
if not table.find(weatherList,MosCfg.SelectedWeather)then
table.insert(weatherList,MosCfg.SelectedWeather)
end
Tabs.Misc:AddDropdown("MosSelectWeatherDropdown",{
Title="Select Weather",
Values=weatherList,
Default=MosCfg.SelectedWeather,
Multi=false,
Callback=function(Value)
MosCfg.SelectedWeather=Value or"Thunderstorm"
MosSave()
end
})
Tabs.Misc:AddSlider("MosHopWeatherDelaySlider",{
Title="Delay Hop",
Default=MosCfg.HopWeatherDelay or 5,
Min=5,
Max=20,
Rounding=1,
Callback=function(Value)
MosCfg.HopWeatherDelay=Value
MosSave()
end
})
Tabs.Misc:AddInput("MosWeatherWebhookInput",{
Title="Webhook URL",
Default=MosCfg.WeatherWebhookUrl or"",
Placeholder="https://discord.com/api/webhooks/...",
Numeric=false,
Finished=false,
Callback=function(Value)
MosCfg.WeatherWebhookUrl=(tostring(Value or""):gsub("%s+",""))
MosSave()
end
})
task.spawn(function()
task.wait(2)
if not MosCfg.AutoHopWeather then return end
local waited=0
repeat task.wait(0.2)waited=waited+0.2 until workspace:GetAttribute("Weather")or not MosCfg.AutoHopWeather or waited>15
if not MosCfg.AutoHopWeather then return end
CheckWeatherAndHop()
end)
end
Tabs.Settings:AddSection("Hub")
Tabs.Settings:AddButton({
Title="Unload Hub",
Callback=function()
MosX.Unload()
end
})
end
MosX.OnUnload=function()
MosCfg.AutoCast,MosCfg.AutoReel,MosCfg.AutoMiniGame=false,false,false
MosCfg.AutoBoss,MosCfg.AutoSecretBoss,MosCfg.AutoSkill=false,false,false
MosCfg.AutoFarmIsland,MosCfg.AutoTPPos=false,false
MosCfg.AutoTicketQuest,MosCfg.AutoZengTianguoQuest,MosCfg.AutoFilterZengQuest=false,false,false
MosCfg.AutoDaily,MosCfg.AutoSummon,MosCfg.AutoBuyBestRod,MosCfg.AutoRedeem=false,false,false,false
MosCfg.AutoClaimDailyQuest,MosCfg.AutoGiveFish,MosCfg.AutoFavoriteBoss=false,false,false
MosCfg.AutoHopWeather,MosCfg.AutoHopSacredBeast,MosCfg.FilterFishEnabled=false,false,false
MosCfg.FlyEnabled,MosCfg.NoclipEnabled,MosCfg.LoopSpeedEnabled=false,false,false
MosCfg.AutoSell,MosCfg.AutoBuyBait,MosCfg.AutoCraftBait,MosCfg.AutoCraftRod=false,false,false,false
MosCfg.AutoEquipBestBait,MosCfg.AutoEquipPickedBait,MosCfg.AutoUpgradeChar=false,false,false
pcall(stopFly)
pcall(function()SetFpsBoost(false)end)
pcall(clearPlayerESP)
MosCfg.ESPEnabled=false
pcall(function()MosX.ApplyHide(false)end)
pcall(function()MosX.SetInstantInteract(false)end)
pcall(function()MosX.SetWalkOnWater(false)end)
MosCfg.InstantInteract,MosCfg.WalkOnWater=false,false
end
MosX.RunBuild=function(name)
local ok,err=pcall(MosX.Build[name])
if not ok then
MosShowError("tab "..name..": "..tostring(err))
end
end
MosX.RunBuild("Main")
Window:SelectTab(1)
Fluent:Notify({
Title="Mos Hub",
Content="Loaded - by noelnoathebest02",
Duration=5
})
MosLoaded=true
task.spawn(function()
for _,name in ipairs({"Quest","Player","Teleport","Shop","Misc","Settings"})do
if MosX.Unloaded then return end
task.wait()
MosX.RunBuild(name)
end
end)
end,function(e)return debug.traceback(tostring(e),2)end)
if not __MosOk then
MosShowError(__MosErr)
end

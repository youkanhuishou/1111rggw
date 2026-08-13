--// 功能层：运行环境、状态与核心配置

local translateText=function(text) return text end

local featureAvailability={
["AlwaysFastVault"]=true,
["BlockVaultPallets"]=true,
["CancelGen"]=true,
["CinematicDOF"]=true,
["CustomBackground"]=true,
["FakeLag"]=true,
["InfoBanner"]=true,
["Masked"]=true,
["MovementMoonwalk"]=true,
["NoclipVaultsPallets"]=true,
["RTXGraphics"]=true,
["RevolverAutofarm"]=true,
["RevolverSilentAim"]=true,
["SpearSilentAim"]=true,
["Stalker"]=true
}
local runtimeEnabled=true
local interfaceEnabled=true
local sessionId=tostring(math.random(100000,999999))..tostring(tick())
local gameplayEnabled=true
local runtimeMode="Gameplay"
local runtimeHandle=nil
local runtimeState=nil
if _G["VD_Cleanup"] then
_G["VD_IsRestarting"]=true
pcall(_G["VD_Cleanup"])
_G["VD_IsRestarting"]=nil
end
Players=game:GetService("Players")
RunService=game:GetService("RunService")
TweenService=game:GetService("TweenService")
UserInputService=game:GetService("UserInputService")
VirtualInputManager=game:GetService("VirtualInputManager")
PathfindingService=game:GetService("PathfindingService")
httpService=game:GetService("HttpService")
ReplicatedStorage=game:GetService("ReplicatedStorage")
localPlayer=Players.LocalPlayer
while not localPlayer do
 task.wait(.5)
 localPlayer=Players.LocalPlayer
end
local function getExecutorName()
 local identifyExecutor=(syn and syn.identify_executor) or identify_executor or identifyexecutor or getexecutorname
 if identifyExecutor then
  local success,result=pcall(identifyExecutor)
  if success and result and result~="" then return tostring(result) end
 end
 return "Unknown"
end
local executorName=getExecutorName()
local executorNameLower=tostring(executorName):lower()
local isLegacyExecutor=false
local isRestrictedExecutor=false
local hasExecutorRestriction=isRestrictedExecutor or isLegacyExecutor
local isMobileExecutor=not not (executorNameLower:find("delta") or executorNameLower:find("codex") or executorNameLower:find("arceus") or executorNameLower:find("vega"))
local currentCamera=workspace.CurrentCamera
local smallViewport=false
if currentCamera then
 local viewportSize=currentCamera.ViewportSize
 if viewportSize.Y<600 or viewportSize.X<600 then smallViewport=true end
end
local isMobileDevice=not not (UserInputService.TouchEnabled or isMobileExecutor or smallViewport)
local function isFeatureAvailable()
 return true
end
local function isPremiumFeature(featureName)
 return true
end
local getCustomAsset=getcustomasset or getsynasset
local function loadCachedAsset(url,cacheFile,fallbackAsset)
 local assetCacheAvailable=writefile and readfile and isfile and getCustomAsset
 if not assetCacheAvailable then return fallbackAsset end
 if not isfile(cacheFile) then
  local success,result=pcall(function()
   local requestFunction=(syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
   if requestFunction then
    local response=requestFunction({Url=url,Method="GET",Timeout=3})
    if response and response.StatusCode==200 then return response.Body end
   end
   return game:HttpGet(url)
  end)
  if success and result and #result>0 then pcall(writefile,cacheFile,result) else return fallbackAsset end
 end
 local success,result=pcall(getCustomAsset,cacheFile)
 return success and result or fallbackAsset
end
originalCameraSettings={
 CameraMode=localPlayer.CameraMode,
 CameraMinZoomDistance=localPlayer.CameraMinZoomDistance,
 CameraMaxZoomDistance=localPlayer.CameraMaxZoomDistance
}
local actionHandlers={}
local keybindButtons={}
local cachedRootPart=nil
local playerStateCache={}
local characterStateCache={}
local activeCharacter
local activeHumanoid
defaultLightingSettings=nil
cachedAtmospheres={}
cachedDoFs={}
setmetatable(cachedAtmospheres,{__mode="k"})
setmetatable(cachedDoFs,{__mode="k"})
local lightingService=game:GetService("Lighting")
local lightingProperties={"Brightness","ClockTime","Ambient","OutdoorAmbient","GlobalShadows","FogStart","FogEnd"}
function forceFullBright() end
function forceNoFog() end
_G["VD_CurrentFarmState"]="Idle"
activeLoop=true
local activeFarmThread
local currentFarmTarget=nil
local currentFarmPath=nil
local farmHeartbeatConnection=nil
local currentFarmState=nil
scriptConnections={}
function registerConnection(connection)
 table.insert(scriptConnections,connection)
 return connection
end
highlightParent=workspace
guiParent=nil
billboardParent=localPlayer:WaitForChild("PlayerGui",15) or localPlayer:FindFirstChildOfClass("PlayerGui")
pcall(function()
 guiParent=(type(gethui)=="function" and gethui()) or game:GetService("CoreGui")
end)
if not guiParent then guiParent=billboardParent end
function saveSettings() end
local activeNotification=nil
local settings
local speedBoostConnection=nil
local uiReady=true
local activeModal=nil
local activeDropdown=nil
local runtimeCache={}
local isCleaningUp=false
_G["VD_GameplayHooks"]=_G["VD_GameplayHooks"] or {}
local currentCharacter=nil
local currentHumanoid=nil
local currentRootPart=nil
local currentTeam=nil
local aimTarget=nil
local aimConnection=nil
local silentAimTarget=nil
local silentAimConnection=nil
local parryTarget=nil
local parryConnection=nil
local mobileAimbotGui=nil
local mobileAimbotActive=false
local spearTarget=nil
local spearConnection=nil
local minimapConnection=nil
local minimapFrame=nil
local normalSpearSpeed=150
local normalSpearGravity=workspace["Gravity"]/2 _G["VD_NormalSpearGravity"]=normalSpearGravity
local specialSpearSpeed=170
local specialSpearGravity=workspace["Gravity"]/2 _G["VD_SpecialSpearGravity"]=specialSpearGravity
local lastUpdateTime=0 settings={["ShowHotkeyOverlay"]=false, ["DesyncGhostAlwaysOnTop"]=true, ["DesyncGhostTransparency"]=.5;
["DesyncGhostColor"]="Accent";
["ESPStyle"]="Compact";
["ESPBackground"]=true, ["ESPDistanceFade"]=false;
["ESPDistanceFadePlayers"]=true;
["ESPDistanceFadeMap"]=true;
["ESPDistanceFadeTracers"]=true, ["ESPDistanceFadeGenerators"]=true, ["ESPDistanceFadePallets"]=true, ["ESPDistanceFadeVaults"]=true;
["ESPDistanceFadeHooks"]=true, ["ESPDistanceFadeGates"]=true, ["ESPDistanceFadeSCPs"]=true, ["ESPFadeStart"]=50, ["ESPFadeMax"]=200;
["ModifierTeamFilter"]="Both";
["PerkLoadouts"]={};
["SelectedPerk1"]="None";
["SelectedPerk2"]="None";
["SelectedPerk3"]="None", ["SelectedPerkLoadout"]="None";
["RainbowCharacter"]=false;
["RainbowCharacterMode"]="Highlight", ["FOV"]=70;
["StretchedResolutionMode"]="Normal";
["ShowInfoBanner"]=false;
["InfoBannerShowMap"]=true, ["InfoBannerShowKiller"]=true;
["InfoBannerShowPerks"]=true, ["InfoBannerShowFPS"]=true;
["InfoBannerShowPing"]=true;
["InfoBannerPositionScaleX"]=.5, ["InfoBannerPositionOffsetX"]=0;
["InfoBannerPositionScaleY"]=0;
["InfoBannerPositionOffsetY"]=isMobileDevice and 6 or 10;
["ShowToggleNotifications"]=true, ["ESPTracers"]=false;
["TracerTarget"]="Both", ["TracerStyle"]="Line";
["TracerOrigin"]="Bottom", ["TracerColorMode"]="Role Color";
["Minimap"]={["Enabled"]=false}, ["SpearTrajectory"]=false, ["KillerESP"]={["Enabled"]=false, ["Aura"]=true;
["Distance"]=true, ["SelectedKiller"]=true, ["ShowName"]=true};
["SurvivorESP"]={["Enabled"]=false;
["Aura"]=true, ["Distance"]=true;
["HealthState"]=true, ["ShowHookCount"]=true, ["ShowName"]=true};
["GeneratorESP"]={["Enabled"]=false;
["Aura"]=true, ["ShowProgress"]=true, ["ShowRepairSpeed"]=true, ["ShowETA"]=true, ["AlertThresholdEnabled"]=true, ["AlertThreshold"]=90;
["ShowDistance"]=true, ["ShowRepairingCount"]=true, ["NoText"]=false};
["CustomGenSound"]={["Enabled"]=false;
["SoundId"]="rbxassetid://124429695332529";
["Volume"]=1}, ["SCPESP"]={["Enabled"]=false, ["Aura"]=true, ["ShowDistance"]=true;
["NoText"]=false};
["HookESP"]={["Enabled"]=false, ["Aura"]=true, ["ShowDistance"]=true, ["NoText"]=false};
["PalletESP"]={["Enabled"]=false;
["Aura"]=true, ["ShowDistance"]=true;
["NoText"]=false}, ["VaultESP"]={["Enabled"]=false, ["Aura"]=true, ["ShowDistance"]=true;
["NoText"]=false}, ["BloodESP"]={["Enabled"]=false;
["Aura"]=true, ["ShowDistance"]=true, ["NoText"]=false};
["GateESP"]={["Enabled"]=false;
["Aura"]=true;
["ShowProgress"]=true, ["ShowDistance"]=true;
["NoText"]=false}, ["ESPColors"]={["Killer"]=Color3["fromRGB"](255, 50, 50), ["SurvivorHealthy"]=Color3["fromRGB"](50, 255, 100);
["SurvivorInjured"]=Color3["fromRGB"](255, 150, 0), ["SurvivorKnocked"]=Color3["fromRGB"](255, 50, 50);
["Generator"]=Color3["fromRGB"](0, 200, 255);
["Hook"]=Color3["fromRGB"](255, 150, 0);
["Pallet"]=Color3["fromRGB"](180, 130, 70);
["Vault"]=Color3["fromRGB"](180, 180, 180), ["BloodEffect"]=Color3["fromRGB"](180, 0, 0), ["Gate"]=Color3["fromRGB"](255, 255, 0);
["SCP"]=Color3["fromRGB"](150, 0, 255), ["Tracer"]=Color3["fromRGB"](255, 255, 255)};
["VaultSpeed"]=1;
["AlwaysFastVault"]=false, ["ShowCrosshair"]=false, ["CrosshairStyle"]="Classic";
["CrosshairColor"]=Color3["fromRGB"](0, 255, 255), ["CrosshairSize"]=10;
["InfiniteFlashlight"]=false, ["SpeedBoostEnabled"]=false;
["SpeedBoost"]=1.3;
["CountSpeedPerks"]=true, ["AutoDodgeVeilSpear"]=true, ["DodgeDebugMode"]=false, ["NoStun"]=false, ["ESPRange"]=999999;
["MasterESP"]=true, ["FlowstateNoCooldown"]=false;
["FlowstatePerk"]=false;
["FlowstateCooldown"]=15, ["HideFlowstateUI"]=false, ["AutoSkillCheck"]=false;
["InstantSkillCheck"]=false;
["SkillCheckMode"]="Perfect";
["AutoMoonwalk"]=false, ["ReverseMoonwalk"]=false, ["MoonwalkDisableOnVault"]=true;
["MoonwalkSwaySpeed"]=14, ["MoonwalkSwayAmplitude"]=.65;
["MoonwalkShaking"]=.05;
["MoonwalkMovementBased"]=false, ["NoclipVaultsPallets"]=false, ["AutoParry"]=false;
["ParryUseItem"]=false;
["ParryRange"]=14, ["ParryPingCompensation"]=true, ["ParryRangeESP"]=false, ["ParryDelay"]=0;
["ParryFacingCheck"]=true;
["HideParryUI"]=false, ["LungeSpeedThreshold"]=50, ["AutoFleeKiller"]=false, ["NoSkillChecks"]=false, ["SpearTrajectoryColor"]="Cyan";
["SpearTrajectoryNoclip"]=false;
["FrenzyParry"]=false;
["IgnoreAbysswalkerLunge"]=false, ["AutoFarmSurvivor"]=false, ["AutoServerHopEscape"]=false, ["AutoFarmAFK"]=true, ["AutoFarmAFKTotal"]=false, ["InstantHeal"]=false;
["BlockVaultPalletInteraction"]=false;
["AutoFarmKiller"]=false, ["RemoteDropPallet"]=false, ["RemoteDropPalletKey"]="None";
["WalkWhileEmoting"]=true;
["ShowActiveFeatures"]=false;
["AntiWiggle"]=false;
["NoFog"]=false;
["FakeLag"]=false;
["FakeLagMs"]=200;
["Desync"]=false;
["FullBright"]=false, ["NoFlashlightBlind"]=false, ["RevolverAutofarm"]=false;
["RevolverAimbot"]={["Enabled"]=false;
["Key"]="MouseButton2";
["TargetPart"]="UpperTorso";
["Smoothness"]=0;
["Radius"]=150;
["OffsetX"]=12;
["OffsetY"]=5, ["ShowFOV"]=false;
["ShowCrosshair"]=false, ["CrosshairStyle"]="Classic";
["CrosshairColor"]=Color3["fromRGB"](0, 255, 255);
["CrosshairSize"]=10;
["PredictionEnabled"]=true, ["BulletVelocity"]=800}, ["AimAssist"]={["Enabled"]=false;
["Mode"]="Hold";
["Key"]="MouseButton2", ["TargetPart"]="UpperTorso";
["Smoothness"]=.2;
["FOV"]=150, ["ShowFOV"]=true, ["TargetTeam"]="Both", ["Prediction"]=true, ["OffsetX"]=0, ["OffsetY"]=0}, ["RevolverSilentAim"]={["Enabled"]=false, ["FOVRadius"]=200, ["ShowFOV"]=true;
["FOVColor"]="Cyan";
["Target"]="Both Teams";
["TargetHighlightEnabled"]=true, ["TargetHighlightColor"]="Cyan", ["TargetHighlightMode"]="Always on Top", ["TargetHighlightFillTransparency"]=.5, ["TargetHighlightOutlineTransparency"]=0};
["RTXGraphics"]=false, ["CinematicDOF"]=false;
["GraphicsTint"]="Default", ["AtmosphereDensity"]=.3;
["InfiniteZoom"]=false;
["CustomBackground"]={["Enabled"]=false, ["AssetId"]="";
["LocalFile"]="";
["Overlay"]=40, ["ScaleType"]="Crop"}, ["MoveWhileBreaking"]=false;
["SpearAimbot"]={["Enabled"]=false, ["Key"]="MouseButton2", ["TargetPart"]="UpperTorso";
["Smoothness"]=.05;
["Radius"]=150;
["Speed"]=150, ["Gravity"]=98}, ["SpearSilentAim"]={["Enabled"]=false, ["FOVRadius"]=240, ["ShowFOV"]=true;
["FOVColor"]="Yellow";
["TargetHighlightEnabled"]=true;
["TargetHighlightColor"]="Red", ["TargetHighlightMode"]="Always on Top";
["TargetHighlightFillTransparency"]=.5, ["TargetHighlightOutlineTransparency"]=0}, ["Keybinds"]={["AutoMoonwalk"]="None", ["FlowstatePerk"]="None";
["AutoSkillCheck"]="None", ["KillerTrack"]="None";
["SurvivorTrack"]="None";
["InstantEscape"]="None";
["CancelGen"]="None", ["NoclipVaultsPallets"]="None";
["FakeVault"]="None", ["ToggleSpeedBoost"]="None";
["ToggleUI"]="K";
["AutoParry"]="None", ["RevolverAimbot"]="None", ["RevolverAutofarm"]="None";
["InstantHeal"]="None";
["InstantBandage"]="None", ["DropAllPallets"]="None", ["BlockVaultPalletInteraction"]="None";
["NoFog"]="None";
["FullBright"]="None", ["NoFlashlightBlind"]="None", ["StopEmote"]="None"};
["Theme"]="Default";
["MobileButtons"]={}, ["MobileButtonPositions"]={}, ["KillerThirdPerson"]=false}_G["VD_Settings"]=settings
function normalizeSettings()pcall(function()
if type(settings["SpeedBoost"])~="number"then
settings["SpeedBoost"]=tonumber(settings["SpeedBoost"])or 1.3
end
if settings["PerkLoadouts"]==nil then
settings["PerkLoadouts"]={}
end
if settings["SelectedPerk1"]==nil then
settings["SelectedPerk1"]="None"
end
if settings["SelectedPerk2"]==nil then
settings["SelectedPerk2"]="None"
end
if settings["SelectedPerk3"]==nil then
settings["SelectedPerk3"]="None"
end
if settings["SelectedPerkLoadout"]==nil then
settings["SelectedPerkLoadout"]="None"
end
if settings["SpeedBoostEnabled"]==nil then
settings["SpeedBoostEnabled"]=false
end
if not settings["RevolverAimbot"]then
settings["RevolverAimbot"]={}
end
if settings["RevolverAimbot"]["ShowCrosshair"]==nil then
settings["RevolverAimbot"]["ShowCrosshair"]=false
end
if settings["RevolverAimbot"]["ShowFOV"]==nil then
settings["RevolverAimbot"]["ShowFOV"]=false
end
if settings["RevolverAimbot"]["CrosshairStyle"]==nil then
settings["RevolverAimbot"]["CrosshairStyle"]="Classic"
end
if not settings["AimAssist"]then
settings["AimAssist"]={}
end
if settings["AimAssist"]["Enabled"]==nil then
settings["AimAssist"]["Enabled"]=false
end
if settings["AimAssist"]["Mode"]==nil then
settings["AimAssist"]["Mode"]="Hold"
end
if settings["AimAssist"]["Key"]==nil then
settings["AimAssist"]["Key"]="MouseButton2"
end
if settings["AimAssist"]["TargetPart"]==nil then
settings["AimAssist"]["TargetPart"]="UpperTorso"
end
if settings["AimAssist"]["Smoothness"]==nil then
settings["AimAssist"]["Smoothness"]=.2
end
if settings["AimAssist"]["FOV"]==nil then
settings["AimAssist"]["FOV"]=150
end
if settings["AimAssist"]["ShowFOV"]==nil then
settings["AimAssist"]["ShowFOV"]=true
end
if settings["AimAssist"]["TargetTeam"]==nil then
settings["AimAssist"]["TargetTeam"]="Both"
end
if settings["AimAssist"]["Prediction"]==nil then
settings["AimAssist"]["Prediction"]=true
end
if settings["CountSpeedPerks"]==nil then
settings["CountSpeedPerks"]=true
end
if settings["FlashlightColor"]==nil then
settings["FlashlightColor"]=Color3["fromRGB"](255, 255, 255)
end
if settings["KillerStainColor"]==nil then
settings["KillerStainColor"]=Color3["fromRGB"](255, 0, 0)
end
if settings["FlashlightEffect"]==nil then
settings["FlashlightEffect"]="None"
end
if settings["UnlockAllSkins"]==nil then
settings["UnlockAllSkins"]=false
end
if settings["ShowHotkeyOverlay"]==nil then
settings["ShowHotkeyOverlay"]=false
end
if settings["EnableDesyncGhost"]==nil then
settings["EnableDesyncGhost"]=true
end
if settings["DesyncGhostAlwaysOnTop"]==nil then
settings["DesyncGhostAlwaysOnTop"]=true
end
if settings["DesyncGhostTransparency"]==nil then
settings["DesyncGhostTransparency"]=.5
end
if settings["DesyncGhostColor"]==nil then
settings["DesyncGhostColor"]="Accent"
end
if type(settings["FlowstateCooldown"])~="number"then
settings["FlowstateCooldown"]=tonumber(settings["FlowstateCooldown"])or 15
end
if settings["HideFlowstateUI"]==nil then
settings["HideFlowstateUI"]=false
end
if settings["RemoteDropPallet"]==nil then
settings["RemoteDropPallet"]=false
end
if settings["RemoteDropPalletKey"]==nil then
settings["RemoteDropPalletKey"]="None"
end
if settings["ESPDistanceFade"]==nil then
settings["ESPDistanceFade"]=false
end
if settings["ESPDistanceFadePlayers"]==nil then
settings["ESPDistanceFadePlayers"]=true
end
if settings["ESPDistanceFadeMap"]==nil then
settings["ESPDistanceFadeMap"]=true
end
if settings["ESPDistanceFadeTracers"]==nil then
settings["ESPDistanceFadeTracers"]=true
end
if not settings["GeneratorESP"]then
settings["GeneratorESP"]={}
end
if settings["GeneratorESP"]["ShowRepairSpeed"]==nil then
settings["GeneratorESP"]["ShowRepairSpeed"]=true
end
if settings["GeneratorESP"]["ShowETA"]==nil then
settings["GeneratorESP"]["ShowETA"]=true
end
if settings["GeneratorESP"]["AlertThresholdEnabled"]==nil then
settings["GeneratorESP"]["AlertThresholdEnabled"]=true
end
if settings["GeneratorESP"]["AlertThreshold"]==nil then
settings["GeneratorESP"]["AlertThreshold"]=90
end
if not settings["CustomGenSound"]then
settings["CustomGenSound"]={}
end
if settings["CustomGenSound"]["Enabled"]==nil then
settings["CustomGenSound"]["Enabled"]=false
end
if not settings["CustomGenSound"]["SoundId"]then
settings["CustomGenSound"]["SoundId"]="rbxassetid://124429695332529"
end
if settings["CustomGenSound"]["Volume"]==nil then
settings["CustomGenSound"]["Volume"]=1
end
if settings["ESPDistanceFadeGenerators"]==nil then
settings["ESPDistanceFadeGenerators"]=true
end
if settings["ESPDistanceFadePallets"]==nil then
settings["ESPDistanceFadePallets"]=true
end
if settings["ESPDistanceFadeVaults"]==nil then
settings["ESPDistanceFadeVaults"]=true
end
if settings["ESPDistanceFadeHooks"]==nil then
settings["ESPDistanceFadeHooks"]=true
end
if settings["ESPDistanceFadeGates"]==nil then
settings["ESPDistanceFadeGates"]=true
end
if settings["ESPDistanceFadeSCPs"]==nil then
settings["ESPDistanceFadeSCPs"]=true
end
if settings["ModifierTeamFilter"]==nil then
settings["ModifierTeamFilter"]="Both"
end
if settings["RainbowCharacter"]==nil then
settings["RainbowCharacter"]=false
end
if settings["RainbowCharacterMode"]==nil then
settings["RainbowCharacterMode"]="Highlight"
end
if settings["TracerTarget"]==nil then
settings["TracerTarget"]="Both"
end
if settings["TracerStyle"]==nil then
settings["TracerStyle"]="Line"
end
if settings["TracerOrigin"]==nil then
settings["TracerOrigin"]="Bottom"
end
if settings["TracerColorMode"]==nil then
settings["TracerColorMode"]="Role Color"
end
if type(settings["ESPFadeStart"])~="number"then
settings["ESPFadeStart"]=tonumber(settings["ESPFadeStart"])or 50
end
if type(settings["ESPFadeMax"])~="number"then
settings["ESPFadeMax"]=tonumber(settings["ESPFadeMax"])or 200
end
if type(settings["FOV"])~="number"then
settings["FOV"]=tonumber(settings["FOV"])or 70
end
if type(settings["StretchedResolutionMode"])~="string"then
settings["StretchedResolutionMode"]="Normal"
end
local espEntries={"GeneratorESP", "HookESP";
"PalletESP", "VaultESP", "GateESP";
"BloodESP";
"SCPESP"}
for index, item in ipairs(espEntries)do
if not settings[item]then
settings[item]={}
end
if settings[item]["Enabled"]==nil then
settings[item]["Enabled"]=false
end
if settings[item]["Aura"]==nil then
settings[item]["Aura"]=true
end
if settings[item]["ShowDistance"]==nil then
settings[item]["ShowDistance"]=true
end
if settings[item]["NoText"]==nil then
settings[item]["NoText"]=false
end
end
local items={["4:3 Stretched"]="4:3", ["16:10 Stretched"]="16:10";
["21:9 Stretched"]="21:9", ["Custom"]="Normal"}
if items[settings["StretchedResolutionMode"]]then
settings["StretchedResolutionMode"]=items[settings["StretchedResolutionMode"]]
end
if not settings["Keybinds"]then
settings["Keybinds"]={}
end
local espEntries2={"ToggleESP", "AutoMoonwalk", "FlowstatePerk", "AutoSkillCheck";
"KillerTrack";
"SurvivorTrack";
"InstantEscape";
"CancelGen", "NoclipVaultsPallets";
"FakeVault", "ToggleSpeedBoost";
"ToggleUI";
"AutoParry", "RevolverAimbot";
"RevolverAutofarm", "InstantHeal", "InstantBandage", "DropAllPallets";
"BlockVaultPalletInteraction", "NoFlashlightBlind", "InstantSkillCheck";
"ParryUseItem", "ParryFacingCheck";
"ParryRangeESP", "FrenzyParry";
"RevolverAimbotShowFOV", "RevolverAimbotPredictionEnabled";
"NoStun", "SimulateParryAnimation";
"GeneratorESP";
"HookESP";
"PalletESP", "VaultESP";
"GateESP", "BloodESP", "SCPESP";
"ESPBackground", "KillerESPAura";
"KillerESPDistance", "KillerESPSelectedKiller", "SurvivorESPAura", "SurvivorESPDistance", "SurvivorESPHealthState";
"TpNearestGenerator";
"TpNearestHook";
"TpNearestGate", "TpNearestPallet", "TpNearestVault";
"TpNearestSurvivor";
"TpNearestKiller", "RemoteDropPalletKey", "Masked_Richter", "Masked_Alex", "Masked_Brandon", "Masked_Rabbit", "Masked_Cobra", "Masked_Tony";
"Masked_Normal", "InfiniteLunge"}
for index, item in ipairs(espEntries2)do
if not settings["Keybinds"][item]then
settings["Keybinds"][item]=(item=="ToggleUI"and"K"or"None")
end
end
if settings["AutoDodgeVeilSpear"]==nil then
settings["AutoDodgeVeilSpear"]=true
end
if settings["DodgeDebugMode"]==nil then
settings["DodgeDebugMode"]=false
end
if settings["NoStun"]==nil then
settings["NoStun"]=false
end
if settings["HideParryUI"]==nil then
settings["HideParryUI"]=false
end
if settings["FrenzyParry"]==nil then
settings["FrenzyParry"]=false
end
if settings["IgnoreAbysswalkerLunge"]==nil then
settings["IgnoreAbysswalkerLunge"]=false
end
if settings["ShowInfoBanner"]==nil then
settings["ShowInfoBanner"]=true
end
if settings["InfoBannerShowMap"]==nil then
settings["InfoBannerShowMap"]=true
end
if settings["InfoBannerShowKiller"]==nil then
settings["InfoBannerShowKiller"]=true
end
if settings["InfoBannerShowPerks"]==nil then
settings["InfoBannerShowPerks"]=true
end
if settings["InfoBannerShowFPS"]==nil then
settings["InfoBannerShowFPS"]=true
end
if settings["InfoBannerShowPing"]==nil then
settings["InfoBannerShowPing"]=true
end
if settings["InfoBannerPositionScaleX"]==nil then
settings["InfoBannerPositionScaleX"]=.5
end
if settings["InfoBannerPositionOffsetX"]==nil then
settings["InfoBannerPositionOffsetX"]=0
end
if settings["InfoBannerPositionScaleY"]==nil then
settings["InfoBannerPositionScaleY"]=0
end
if settings["InfoBannerPositionOffsetY"]==nil then
settings["InfoBannerPositionOffsetY"]=isMobileDevice and 6 or 10
end
if settings["ShowToggleNotifications"]==nil then
settings["ShowToggleNotifications"]=true
end
if settings["ShowCrosshair"]==nil then
settings["ShowCrosshair"]=false
end
if settings["CrosshairStyle"]==nil then
settings["CrosshairStyle"]="Classic"
end
if settings["CrosshairColor"]==nil then
settings["CrosshairColor"]=Color3["fromRGB"](0, 255, 255)
end
if settings["CrosshairSize"]==nil then
settings["CrosshairSize"]=10
end
if settings["InfiniteFlashlight"]==nil then
settings["InfiniteFlashlight"]=false
end
if settings["MasterESP"]==nil then
settings["MasterESP"]=true
end
if settings["RTXGraphics"]==nil then
settings["RTXGraphics"]=false
end
if settings["CinematicDOF"]==nil then
settings["CinematicDOF"]=false
end
if settings["GraphicsTint"]==nil then
settings["GraphicsTint"]="Default"
end
if settings["AtmosphereDensity"]==nil then
settings["AtmosphereDensity"]=.3
end
if settings["ReverseMoonwalk"]==nil then
settings["ReverseMoonwalk"]=false
end
if settings["MoonwalkMovementBased"]==nil then
settings["MoonwalkMovementBased"]=false
end
if settings["Theme"]==nil then
settings["Theme"]="Default"
end
if settings["HideLivePlayersMode"]==nil then
settings["HideLivePlayersMode"]="Normal"
end
if settings["CustomOverlayUrl"]==nil then
settings["CustomOverlayUrl"]="rbxassetid://71824917786372"
end
if settings["MobileButtons"]==nil then
settings["MobileButtons"]={}
end
if settings["ESPTracers"]==nil then
settings["ESPTracers"]=false
end
if not settings["Minimap"]then
settings["Minimap"]={}
end
if settings["Minimap"]["Enabled"]==nil then
settings["Minimap"]["Enabled"]=false
end
if not settings["KillerESP"]then
settings["KillerESP"]={}
end
if settings["KillerESP"]["Enabled"]==nil then
settings["KillerESP"]["Enabled"]=false
end
if settings["KillerESP"]["Aura"]==nil then
settings["KillerESP"]["Aura"]=true
end
if settings["KillerESP"]["Distance"]==nil then
settings["KillerESP"]["Distance"]=true
end
if settings["KillerESP"]["SelectedKiller"]==nil then
settings["KillerESP"]["SelectedKiller"]=true
end
if settings["KillerESP"]["ShowName"]==nil then
settings["KillerESP"]["ShowName"]=true
end
if not settings["SurvivorESP"]then
settings["SurvivorESP"]={}
end
if settings["SurvivorESP"]["Enabled"]==nil then
settings["SurvivorESP"]["Enabled"]=false
end
if settings["SurvivorESP"]["Aura"]==nil then
settings["SurvivorESP"]["Aura"]=true
end
if settings["SurvivorESP"]["Distance"]==nil then
settings["SurvivorESP"]["Distance"]=true
end
if settings["SurvivorESP"]["HealthState"]==nil then
settings["SurvivorESP"]["HealthState"]=true
end
if settings["SurvivorESP"]["ShowHookCount"]==nil then
settings["SurvivorESP"]["ShowHookCount"]=true
end
if settings["SurvivorESP"]["ShowName"]==nil then
settings["SurvivorESP"]["ShowName"]=true
end
if settings["SurvivorESP"]["CensorNames"]==nil then
settings["SurvivorESP"]["CensorNames"]=false
end
if settings["SpearTrajectory"]==nil then
settings["SpearTrajectory"]=true
end
if settings["SpearTrajectoryColor"]==nil then
settings["SpearTrajectoryColor"]="Cyan"
end
if settings["SpearTrajectoryNoclip"]==nil then
settings["SpearTrajectoryNoclip"]=false
end
if settings["AutoFleeKiller"]==nil then
settings["AutoFleeKiller"]=false
end
if settings["NoSkillChecks"]==nil then
settings["NoSkillChecks"]=false
end
if not settings["SpearAimbot"]then
settings["SpearAimbot"]={}
end
if settings["SpearAimbot"]["Enabled"]==nil then
settings["SpearAimbot"]["Enabled"]=false
end
if settings["SpearAimbot"]["Key"]==nil then
settings["SpearAimbot"]["Key"]="MouseButton2"
end
if settings["SpearAimbot"]["TargetPart"]==nil then
settings["SpearAimbot"]["TargetPart"]="UpperTorso"
end
if settings["SpearAimbot"]["Smoothness"]==nil then
settings["SpearAimbot"]["Smoothness"]=.05
end
if settings["SpearAimbot"]["Radius"]==nil then
settings["SpearAimbot"]["Radius"]=150
end
if settings["SpearAimbot"]["Speed"]==nil then
settings["SpearAimbot"]["Speed"]=150
end
if settings["SpearAimbot"]["Gravity"]==nil then
settings["SpearAimbot"]["Gravity"]=98
end
if settings["SpearAimbot"]["PredictionOffset"]==nil then
settings["SpearAimbot"]["PredictionOffset"]=.05
end
if not settings["ESPColors"]then
settings["ESPColors"]={["Killer"]=Color3["fromRGB"](255, 50, 50), ["SurvivorHealthy"]=Color3["fromRGB"](50, 255, 100), ["SurvivorInjured"]=Color3["fromRGB"](255, 150, 0), ["SurvivorKnocked"]=Color3["fromRGB"](255, 50, 50);
["Generator"]=Color3["fromRGB"](0, 200, 255);
["Hook"]=Color3["fromRGB"](255, 150, 0);
["Pallet"]=Color3["fromRGB"](180, 130, 70), ["Vault"]=Color3["fromRGB"](180, 180, 180);
["BloodEffect"]=Color3["fromRGB"](180, 0, 0), ["Gate"]=Color3["fromRGB"](255, 255, 0);
["SCP"]=Color3["fromRGB"](150, 0, 255), ["Tracer"]=Color3["fromRGB"](255, 255, 255)}
else
local teamName={["Killer"]=Color3["fromRGB"](255, 50, 50), ["SurvivorHealthy"]=Color3["fromRGB"](50, 255, 100);
["SurvivorInjured"]=Color3["fromRGB"](255, 150, 0), ["SurvivorKnocked"]=Color3["fromRGB"](255, 50, 50), ["Generator"]=Color3["fromRGB"](0, 200, 255), ["Hook"]=Color3["fromRGB"](255, 150, 0), ["Pallet"]=Color3["fromRGB"](180, 130, 70);
["Vault"]=Color3["fromRGB"](180, 180, 180);
["BloodEffect"]=Color3["fromRGB"](180, 0, 0);
["Gate"]=Color3["fromRGB"](255, 255, 0), ["SCP"]=Color3["fromRGB"](150, 0, 255), ["Tracer"]=Color3["fromRGB"](255, 255, 255)}
for key, item in pairs(teamName)do
if settings["ESPColors"][key]==nil then
settings["ESPColors"][key]=item
end
end
end
if not settings["SpearSilentAim"]then
settings["SpearSilentAim"]={}
end
if settings["SpearSilentAim"]["TargetHighlightEnabled"]==nil then
settings["SpearSilentAim"]["TargetHighlightEnabled"]=true
end
if settings["SpearSilentAim"]["TargetHighlightColor"]==nil then
settings["SpearSilentAim"]["TargetHighlightColor"]="Red"
end
if settings["SpearSilentAim"]["TargetHighlightMode"]==nil then
settings["SpearSilentAim"]["TargetHighlightMode"]="Always on Top"
end
if settings["SpearSilentAim"]["TargetHighlightFillTransparency"]==nil then
settings["SpearSilentAim"]["TargetHighlightFillTransparency"]=.5
end
if settings["SpearSilentAim"]["TargetHighlightOutlineTransparency"]==nil then
settings["SpearSilentAim"]["TargetHighlightOutlineTransparency"]=0
end
if not settings["CustomBackground"]then
settings["CustomBackground"]={}
end
if settings["CustomBackground"]["Enabled"]==nil then
settings["CustomBackground"]["Enabled"]=false
end
if settings["CustomBackground"]["AssetId"]==nil then
settings["CustomBackground"]["AssetId"]=""
end
if settings["CustomBackground"]["LocalFile"]==nil then
settings["CustomBackground"]["LocalFile"]=""
end
if settings["CustomBackground"]["Overlay"]==nil or settings["CustomBackground"]["Overlay"]>70 then
settings["CustomBackground"]["Overlay"]=40
end
if settings["CustomBackground"]["ScaleType"]==nil then
settings["CustomBackground"]["ScaleType"]="Crop"
end
if not settings["RevolverSilentAim"]then
settings["RevolverSilentAim"]={}
end
if settings["RevolverSilentAim"]["TargetHighlightEnabled"]==nil then
settings["RevolverSilentAim"]["TargetHighlightEnabled"]=true
end
if settings["RevolverSilentAim"]["TargetHighlightColor"]==nil then
settings["RevolverSilentAim"]["TargetHighlightColor"]="Cyan"
end
if settings["RevolverSilentAim"]["TargetHighlightMode"]==nil then
settings["RevolverSilentAim"]["TargetHighlightMode"]="Always on Top"
end
if settings["RevolverSilentAim"]["TargetHighlightFillTransparency"]==nil then
settings["RevolverSilentAim"]["TargetHighlightFillTransparency"]=.5
end
if settings["RevolverSilentAim"]["TargetHighlightOutlineTransparency"]==nil then
settings["RevolverSilentAim"]["TargetHighlightOutlineTransparency"]=0
end
if settings["InfiniteZoom"]==nil then
settings["InfiniteZoom"]=false
end
end
)
end
normalizeSettings()
ActiveESP={["Players"]={}, ["Generators"]={}, ["Hooks"]={}, ["Pallets"]={}, ["Vaults"]={}, ["BloodEffects"]={}, ["Gates"]={}, ["SCPs"]={}}
function getDistance(player, contextValue)
local player2=cachedRootPart
if not player2 then
local character=localPlayer["Character"]player2=character and character:FindFirstChild("HumanoidRootPart")
if not player2 then
return math["huge"]
end
end
local distance=contextValue
if not distance then
if player:IsA("Player")then
local rootPart=player["Character"]distance=rootPart and rootPart:FindFirstChild("HumanoidRootPart")
elseif player:IsA("Model")then
distance=player["PrimaryPart"]or player:FindFirstChildWhichIsA("BasePart")
elseif player:IsA("BasePart")then
distance=player
end
end
if distance then
return math["round"](((player2["Position"]-distance["Position"]))["Magnitude"])
end
return math["huge"]
end
_G["VD_FarmState"]=_G["VD_FarmState"]or{}_G["VD_FarmState"]["farmTeamStartTime"]=_G["VD_FarmState"]["farmTeamStartTime"]or 0 _G["VD_FarmState"]["farmLastTeamName"]=_G["VD_FarmState"]["farmLastTeamName"]or""_G["VD_FarmState"]["lastKillerSpawnTime"]=_G["VD_FarmState"]["lastKillerSpawnTime"]or 0 _G["VD_FarmState"]["lastSurvivorSpawnTime"]=_G["VD_FarmState"]["lastSurvivorSpawnTime"]or 0 function updateStatus(value)
if _G["VD_UpdateFarmStatus"]then
pcall(function()_G["VD_UpdateFarmStatus"](value)
end
)
end
end
function updateTelemetryAndAFKStates()
local teamName=localPlayer["Team"]and localPlayer["Team"]["Name"]or""
if teamName~=_G["VD_FarmState"]["farmLastTeamName"]then
_G["VD_FarmState"]["farmTeamStartTime"]=tick()_G["VD_FarmState"]["farmLastTeamName"]=teamName _G["VD_FarmState"]["lastKillerSpawnTime"]=0 _G["VD_FarmState"]["lastSurvivorSpawnTime"]=0
end
local character=localPlayer["Character"]
local rootPart=character and character:FindFirstChild("HumanoidRootPart")
if teamName=="Killer"and rootPart then
if _G["VD_FarmState"]["lastKillerSpawnTime"]==0 then
_G["VD_FarmState"]["lastKillerSpawnTime"]=tick()
end
elseif teamName~="Killer"then
_G["VD_FarmState"]["lastKillerSpawnTime"]=0
end
if teamName=="Survivors"and rootPart then
if _G["VD_FarmState"]["lastSurvivorSpawnTime"]==0 then
_G["VD_FarmState"]["lastSurvivorSpawnTime"]=tick()
end
elseif teamName~="Survivors"then
_G["VD_FarmState"]["lastSurvivorSpawnTime"]=0
end
local farmstate=tick()-((_G["VD_FarmState"]["farmTeamStartTime"]or 0))
if settings["AutoFarmAFKTotal"]then
if teamName=="Survivors"then
local conditionMet=_G["VD_FarmState"]["lastSurvivorSpawnTime"]>0 and(tick()-_G["VD_FarmState"]["lastSurvivorSpawnTime"])or 0
if _G["VD_FarmState"]["lastSurvivorSpawnTime"]==0 or conditionMet<15 then
settings["AutoFarmSurvivor"]=false settings["AutoFarmKiller"]=false
if _G["VD_SetFarmToggle"]then
pcall(function()_G["VD_SetFarmToggle"](false)
end
)
end
if _G["VD_SetKillerFarmToggle"]then
pcall(function()_G["VD_SetKillerFarmToggle"](false)
end
)
end
local remainingWaitSeconds=math["ceil"](15-conditionMet)updateStatus(string["format"]("WAITING (%ds)", remainingWaitSeconds>0 and remainingWaitSeconds or 15))
else
local isKnocked=character and((getObjectValue(character, "Knocked")==true or character:GetAttribute("Knocked")==true))
local isHooked=character and((getObjectValue(character, "IsHooked")==true or character:GetAttribute("IsHooked")==true))
if isKnocked or isHooked then
settings["AutoFarmSurvivor"]=false settings["AutoFarmKiller"]=false
if _G["VD_SetFarmToggle"]then
pcall(function()_G["VD_SetFarmToggle"](false)
end
)
end
if _G["VD_SetKillerFarmToggle"]then
pcall(function()_G["VD_SetKillerFarmToggle"](false)
end
)
end
updateStatus("PAUSED (Knocked/Hooked)")
else
settings["AutoFarmSurvivor"]=true settings["AutoFarmKiller"]=false
if _G["VD_FarmState"]["lastRoundScanned"]~=_G["VD_FarmState"]["lastSurvivorSpawnTime"]then
_G["VD_FarmState"]["lastRoundScanned"]=_G["VD_FarmState"]["lastSurvivorSpawnTime"]pcall(scanMapObjects)pcall(scanRemotes)
end
if _G["VD_SetFarmToggle"]then
pcall(function()_G["VD_SetFarmToggle"](true)
end
)
end
if _G["VD_SetKillerFarmToggle"]then
pcall(function()_G["VD_SetKillerFarmToggle"](false)
end
)
end
local currentfarmstate=_G["VD_CurrentFarmState"]
if currentfarmstate and(currentfarmstate~="Idle"and currentfarmstate~="IDLE")then
updateStatus(currentfarmstate)
else
updateStatus("RUNNING (Survivor Farm)")
end
end
end
elseif teamName=="Killer"then
local conditionMet=_G["VD_FarmState"]["lastKillerSpawnTime"]>0 and(tick()-_G["VD_FarmState"]["lastKillerSpawnTime"])or 0
if _G["VD_FarmState"]["lastKillerSpawnTime"]==0 or conditionMet<15 then
settings["AutoFarmSurvivor"]=false settings["AutoFarmKiller"]=false
if _G["VD_SetFarmToggle"]then
pcall(function()_G["VD_SetFarmToggle"](false)
end
)
end
if _G["VD_SetKillerFarmToggle"]then
pcall(function()_G["VD_SetKillerFarmToggle"](false)
end
)
end
local remainingWaitSeconds=math["ceil"](15-conditionMet)updateStatus(string["format"]("WAITING (%ds)", remainingWaitSeconds>0 and remainingWaitSeconds or 15))
else
settings["AutoFarmSurvivor"]=false settings["AutoFarmKiller"]=true
if _G["VD_FarmState"]["lastKillerRoundScanned"]~=_G["VD_FarmState"]["lastKillerSpawnTime"]then
_G["VD_FarmState"]["lastKillerRoundScanned"]=_G["VD_FarmState"]["lastKillerSpawnTime"]pcall(scanMapObjects)pcall(scanRemotes)
end
if _G["VD_SetFarmToggle"]then
pcall(function()_G["VD_SetFarmToggle"](false)
end
)
end
if _G["VD_SetKillerFarmToggle"]then
pcall(function()_G["VD_SetKillerFarmToggle"](true)
end
)
end
local currentfarmstate=_G["VD_CurrentFarmState"]
if currentfarmstate and(currentfarmstate~="Idle"and currentfarmstate~="IDLE")then
updateStatus(currentfarmstate)
else
updateStatus("RUNNING (Killer Farm)")
end
end
else
settings["AutoFarmSurvivor"]=false settings["AutoFarmKiller"]=false
if _G["VD_SetFarmToggle"]then
pcall(function()_G["VD_SetFarmToggle"](false)
end
)
end
if _G["VD_SetKillerFarmToggle"]then
pcall(function()_G["VD_SetKillerFarmToggle"](false)
end
)
end
updateStatus("PAUSED (Spectating/Lobby)")
end
else
if settings["AutoFarmSurvivor"]then
if teamName=="Survivors"or(teamName~="Killer"and(teamName~="Spectators"and teamName~="Spectator"))then
local isHooked=character and((getObjectValue(character, "Knocked")==true or character:GetAttribute("Knocked")==true))
local isHooked2=character and((getObjectValue(character, "IsHooked")==true or character:GetAttribute("IsHooked")==true))
if isHooked or isHooked2 then
updateStatus("PAUSED (Knocked/Hooked)")
else
local currentfarmstate=_G["VD_CurrentFarmState"]
if currentfarmstate and(currentfarmstate~="Idle"and currentfarmstate~="IDLE")then
updateStatus(currentfarmstate)
else
updateStatus("RUNNING (Survivor Farm)")
end
end
elseif teamName=="Killer"then
updateStatus("PAUSED (Killer Team)")
else
updateStatus("PAUSED (Spectating/Lobby)")
end
elseif settings["AutoFarmKiller"]then
if teamName=="Killer"then
local currentfarmstate=_G["VD_CurrentFarmState"]
if currentfarmstate and(currentfarmstate~="Idle"and currentfarmstate~="IDLE")then
updateStatus(currentfarmstate)
else
updateStatus("RUNNING (Killer Farm)")
end
elseif teamName=="Survivors"then
updateStatus("PAUSED (Survivor Team)")
else
updateStatus("PAUSED (Spectating/Lobby)")
end
else
updateStatus("OFF")
end
end
end
function isSurvivorFarmAllowed()
if not settings["AutoFarmSurvivor"]then
return false
end
local teamName=localPlayer["Team"]and localPlayer["Team"]["Name"]or""
if teamName~="Survivors"then
return false
end
if settings["AutoFarmAFKTotal"]then
if((_G["VD_FarmState"]["lastSurvivorSpawnTime"]or 0))==0 then
return false
end
local farmstate=tick()-((_G["VD_FarmState"]["lastSurvivorSpawnTime"]or 0))
if farmstate<15 then
return false
end
end
local character=localPlayer["Character"]
local isKnocked=character and((getObjectValue(character, "Knocked")==true or character:GetAttribute("Knocked")==true))
local isHooked=character and((getObjectValue(character, "IsHooked")==true or character:GetAttribute("IsHooked")==true))
if isKnocked or isHooked then
return false
end
return true
end
function isKillerFarmAllowed()
if not settings["AutoFarmKiller"]then
return false
end
local teamName=localPlayer["Team"]and localPlayer["Team"]["Name"]or""
if teamName~="Killer"then
return false
end
if settings["AutoFarmAFKTotal"]then
if((_G["VD_FarmState"]["lastKillerSpawnTime"]or 0))==0 then
return false
end
local farmstate=tick()-((_G["VD_FarmState"]["lastKillerSpawnTime"]or 0))
if farmstate<15 then
return false
end
end
return true
end
function getESPColor(role)
return settings["ESPColors"][role]or Color3["fromRGB"](255, 255, 255)
end
function getSelectedKiller(players)
local selectedkiller=players:GetAttribute("SelectedKiller")
if selectedkiller~=nil then
return tostring(selectedkiller)
end
local instance=players:FindFirstChild("SelectedKiller")
if instance and((instance:IsA("StringValue")or instance:IsA("ValueObject")))then
return tostring(instance["Value"])
end
if players["Character"]then
local selectedkiller2=players["Character"]:GetAttribute("SelectedKiller")
if selectedkiller2~=nil then
return tostring(selectedkiller2)
end
end
return"None"
end
function getPlayerHealthPercent(player)
local instance=player["Character"]
if instance then
local humanoid=instance:FindFirstChildOfClass("Humanoid")
if humanoid then
return humanoid["Health"], humanoid["MaxHealth"]
end
end
return 100, 100
end
function getGeneratorProgress(generator)
local repairprogress=generator:GetAttribute("RepairProgress")
if repairprogress==nil then
local instance=generator:FindFirstChild("RepairProgress")
if instance and instance:IsA("ValueObject")then
repairprogress=instance["Value"]
end
end
if not repairprogress then
return 0
end
local currentValue=tonumber(repairprogress)
if currentValue then
if currentValue<=1.01 and currentValue>0 then
return math["round"](currentValue*100)
else
return math["round"](currentValue)
end
end
return 0
end
local items={}function getGeneratorAnalytics(value)
if not value then
return 0, nil, ""
end
local speed=items[value]
if not speed then
return 0, nil, ""
end
return speed["smoothedSpeed"]or 0, speed["etaSeconds"], speed["etaFormatted"]or""
end
local function getFeatureState()
local timestamp=tick()
local generatoresp=settings["GeneratorESP"]and settings["GeneratorESP"]["AlertThresholdEnabled"]
local generatoresp2=(settings["GeneratorESP"]and settings["GeneratorESP"]["AlertThreshold"])or 90
for index, instance in ipairs(cachedGenerators or{})do
if not instance or not instance["Parent"]then
continue
end
if isGeneratorCompleted(instance)then
items[instance]=nil
continue
end
local progress=getGeneratorProgress(instance)
local progress2=items[instance]
if not progress2 then
items[instance]={["lastProgress"]=progress, ["lastTime"]=timestamp;
["history"]={};
["smoothedSpeed"]=0, ["smoothedETA"]=nil;
["etaSeconds"]=nil, ["etaFormatted"]="";
["alertTriggered"]=(progress>=generatoresp2)}
continue
end
local elapsedTime=timestamp-progress2["lastTime"]
if elapsedTime>=.75 then
local progress3=progress-progress2["lastProgress"]
if progress3>=0 then
local sampleSpeed=progress3/elapsedTime table["insert"](progress2["history"], sampleSpeed)
if#progress2["history"]>5 then
table["remove"](progress2["history"], 1)
end
local numericValue=0
for index2, item in ipairs(progress2["history"])do
numericValue=numericValue+item
end
local sampleSpeed2=numericValue/#progress2["history"]
local speed=progress2["smoothedSpeed"]or 0
local speed2=speed+((sampleSpeed2-speed))*.25
if math["abs"](speed2)<.05 then
speed2=0
end
local etaSeconds=nil
local etaText=""
if speed2>.1 then
local currentValue=100-progress
local currentValue2=math["max"](0, currentValue/speed2)
local previousEta=progress2["smoothedETA"]or currentValue2
local previousEta2=previousEta+((currentValue2-previousEta))*.2 progress2["smoothedETA"]=previousEta2 etaSeconds=previousEta2
if etaSeconds<60 then
etaText=string["format"]("%ds", math["ceil"](etaSeconds))
else
local minutes=math["floor"](etaSeconds/60)
local seconds=math["ceil"](etaSeconds%60)etaText=string["format"]("%dm %02ds", minutes, seconds)
end
else
progress2["smoothedETA"]=nil
end
progress2["smoothedSpeed"]=speed2 progress2["etaSeconds"]=etaSeconds progress2["etaFormatted"]=etaText
else
progress2["history"]={}progress2["smoothedSpeed"]=0 progress2["smoothedETA"]=nil progress2["etaSeconds"]=nil progress2["etaFormatted"]=""
end
progress2["lastProgress"]=progress progress2["lastTime"]=timestamp
if generatoresp then
if progress>=generatoresp2 then
if not progress2["alertTriggered"]then
progress2["alertTriggered"]=true
local conditionMet=((progress2["etaFormatted"]and progress2["etaFormatted"]~=""))and("ETA: "..progress2["etaFormatted"])or"Nearly Complete!"showNotification("⚡ Generator Alert", string["format"]("Generator reached %d%% progress! (%s)", math["floor"](progress), conditionMet), "warning")
end
else
if progress<(generatoresp2-5)then
progress2["alertTriggered"]=false
end
end
end
end
end
end
registerConnection(RunService["Heartbeat"]:Connect(getFeatureState))
local function playGeneratorCompletionSound(instance)
if not isFeatureAvailable()then
return
end
if not instance or not instance:IsA("Model")then
return
end
local customgensound=settings["CustomGenSound"]
if not customgensound or not customgensound["Enabled"]then
return
end
local gameplayhooks=_G["VD_GameplayHooks"]
if gameplayhooks and type(gameplayhooks["CustomGenSound"])=="function"then
pcall(gameplayhooks["CustomGenSound"], instance, customgensound["SoundId"], customgensound["Volume"])
end
end
function applyCustomSoundToAllGens()
local instance=workspace:FindFirstChild("Map")
local generators=instance and instance:FindFirstChild("Generators")
local children=generators and generators:GetChildren()or cachedGenerators or{}
for index, item in ipairs(children)do
playGeneratorCompletionSound(item)
end
end
local sound=nil function playSoundPreview(value)
if not isFeatureAvailable()then
showNotification("Feature", "Feature unavailable.", "warning")
return
end
if sound then
pcall(function()sound:Stop()sound:Destroy()
end
)sound=nil
end
local function conditionMet(value2)
if not value2 or value2==""then
return"rbxassetid://124429695332529"
end
if type(value2)=="number"then
return"rbxassetid://"..tostring(value2)
end
local normalizedText=(tostring(value2)):gsub("%s+", "")
if normalizedText:find("^rbxassetid://")or normalizedText:find("^http")or normalizedText:find("^assetgame")then
return normalizedText
end
local numericId=normalizedText:match("%d+")
if numericId then
return"rbxassetid://"..numericId
end
return normalizedText
end
local sound2=conditionMet(value)
local customgensound=(settings["CustomGenSound"]and settings["CustomGenSound"]["Volume"])or 1 sound=Instance["new"]("Sound")sound["SoundId"]=sound2 sound["Volume"]=customgensound sound["Parent"]=workspace:FindFirstChild("CurrentCamera")or workspace sound:Play()showNotification("🔊 Sound Preview", "Playing sound: "..sound2, "info")task["delay"](4, function()
if sound then
pcall(function()sound:Stop()sound:Destroy()
end
)sound=nil
end
end
)
end
registerConnection(workspace["DescendantAdded"]:Connect(function(instance)
if instance["Name"]=="Done"and instance:IsA("Sound")then
local name=instance["Parent"]
if name and(((name["Name"]=="HitBox"or name["Name"]=="Hitbox"))and name["Parent"])then
playGeneratorCompletionSound(name["Parent"])
end
end
end
))registerConnection(RunService["Heartbeat"]:Connect(function()
local customgensound=settings["CustomGenSound"]
if customgensound and customgensound["Enabled"]then
local instance=workspace:FindFirstChild("Map")
local generators=instance and instance:FindFirstChild("Generators")
if generators then
for index, item in ipairs(generators:GetChildren())do
playGeneratorCompletionSound(item)
end
end
end
end
))function isGeneratorCompleted(instance)
local completed=instance:GetAttribute("Completed")
if completed==nil then
local instance2=instance:FindFirstChild("Completed")
if instance2 and instance2:IsA("BoolValue")then
completed=instance2["Value"]
end
end
if completed==true or completed=="true"or(tostring(completed)):lower()=="true"then
return true
end
return false
end
function isGeneratorPaused(generator)
if not generator then
return false
end
local progresspaused=generator:GetAttribute("ProgressPaused")
if progresspaused==nil then
local instance=generator:FindFirstChild("ProgressPaused")
if instance and instance:IsA("ValueBase")then
progresspaused=instance["Value"]
end
end
return progresspaused==true or progresspaused=="true"or(tostring(progresspaused)):lower()=="true"
end
function getGateProgress(gate)
if not gate then
return 0
end
local function readStateValue(instance)
if not instance then
return nil
end
local activationprogress=instance:GetAttribute("ActivationProgress")or instance:GetAttribute("Progress")or instance:GetAttribute("RepairProgress")
if activationprogress==nil then
local instance2=instance:FindFirstChild("ActivationProgress")or instance:FindFirstChild("Progress")
if instance2 and instance2:IsA("ValueObject")then
activationprogress=instance2["Value"]
end
end
if activationprogress~=nil then
local currentValue=tonumber(activationprogress)
if currentValue then
if currentValue<=1.01 and currentValue>0 then
return math["round"](currentValue*100)
else
return math["round"](currentValue)
end
end
end
return nil
end
local currentValue=readStateValue(gate)
if currentValue then
return currentValue
end
local instance=gate:FindFirstChild("ExitLever", true)or gate:FindFirstChild("ExitLever")
if instance then
local currentValue2=readStateValue(instance)
if currentValue2 then
return currentValue2
end
local main=instance:FindFirstChild("Main")
if main then
local currentValue3=readStateValue(main)
if currentValue3 then
return currentValue3
end
end
end
local main=gate:FindFirstChild("Main", true)
if main then
local currentValue2=readStateValue(main)
if currentValue2 then
return currentValue2
end
end
return 0
end
function isSpectating()
if localPlayer and localPlayer["Team"]then
local teamName=localPlayer["Team"]["Name"]
if teamName=="Spectator"or teamName=="Spectators"then
return true
end
end
return false
end
setObjectValue=function(instance, contextValue, contextValue2)
if not instance then
return
end
if instance:GetAttribute(contextValue)~=nil then
instance:SetAttribute(contextValue, contextValue2)
return
end
local instance2=instance:FindFirstChild(contextValue)
if instance2 and instance2:IsA("ValueBase")then
instance2["Value"]=contextValue2
return
end
instance:SetAttribute(contextValue, contextValue2)
end
getObjectValue=function(instance, contextValue)
if not instance then
return nil
end
local currentValue=instance:GetAttribute(contextValue)
if currentValue~=nil then
return currentValue
end
local instance2=instance:FindFirstChild(contextValue)
if instance2 and instance2:IsA("ValueBase")then
return instance2["Value"]
end
return nil
end
local items2={}
local items3={}
local connections={}
local conditionMet=false function applySpeedBoostToModel(model)
if not model or not model["Parent"]then
return
end
local speed=items2[model]or 1
local speed2
local name=localPlayer["Team"]
local teamName=name and name["Name"]
local modifierteamfilter=settings["ModifierTeamFilter"]or"Both"
local teamName2=false
if modifierteamfilter=="Both"then
teamName2=teamName=="Survivors"or teamName=="Killer"
elseif modifierteamfilter=="Survivors"then
teamName2=teamName=="Survivors"
elseif modifierteamfilter=="Killer"then
teamName2=teamName=="Killer"
end
if settings["SpeedBoostEnabled"]and teamName2 then
if settings["CountSpeedPerks"]then
speed2=speed+((settings["SpeedBoost"]-1))
else
speed2=settings["SpeedBoost"]
end
else
if settings["CountSpeedPerks"]then
speed2=speed
else
speed2=1
end
end
items3[model]=speed2 conditionMet=true setObjectValue(model, "speedboost", speed2)conditionMet=false
end
function monitorModelSpeedBoost(model)
if connections[model]then
return
end
local speedboost=model:GetAttribute("speedboost")or 1 items2[model]=speedboost items3[model]=speedboost
local connection connection=model["AttributeChanged"]:Connect(function(value)
if value=="speedboost"then
local speedboost2=model:GetAttribute("speedboost")or 1
local currentValue=items3[model]
if currentValue and math["abs"](speedboost2-currentValue)<.001 then
return
end
items2[model]=speedboost2 pcall(function()applySpeedBoostToModel(model)
end
)
end
end
)connections[model]=connection
end
function applyLocalPlayerModifiers()
local name=localPlayer["Team"]
local teamName=name and name["Name"]
local modifierteamfilter=settings["ModifierTeamFilter"]or"Both"
local teamName2=false
if modifierteamfilter=="Both"then
teamName2=teamName=="Survivors"or teamName=="Killer"
elseif modifierteamfilter=="Survivors"then
teamName2=teamName=="Survivors"
elseif modifierteamfilter=="Killer"then
teamName2=teamName=="Killer"
end
if not teamName2 and settings["SpeedBoostEnabled"]then
settings["SpeedBoostEnabled"]=false pcall(saveSettings)
if speedBoostConnection then
pcall(speedBoostConnection)
end
showNotification("Speed Boost", "Disabled: Speed Boost team filter active!", "warning")
end
local name2=localPlayer["Name"]
if not name2 then
return
end
local items4={}
if localPlayer["Character"]then
table["insert"](items4, localPlayer["Character"])
end
local instance=workspace:FindFirstChild(name2)
if instance and instance:IsA("Model")then
if not table["find"](items4, instance)then
table["insert"](items4, instance)
end
end
local items5={"climb_obsessing";
"climb_collisoning";
"climb_collisioning", "climb_colliding"}
for index, item in ipairs(items5)do
local instance2=workspace:FindFirstChild(item)
if instance2 then
local instance3=instance2:FindFirstChild(name2)
if instance3 and instance3:IsA("Model")then
if not table["find"](items4, instance3)then
table["insert"](items4, instance3)
end
end
end
end
for key, item in pairs(connections)do
if not key or not key["Parent"]then
pcall(function()item:Disconnect()
end
)connections[key]=nil items2[key]=nil items3[key]=nil
end
end
for index, item in ipairs(items4)do
local vaultspeed=teamName2 and settings["VaultSpeed"]or 1 setObjectValue(item, "vaultspeed", vaultspeed)monitorModelSpeedBoost(item)applySpeedBoostToModel(item)
end
end
cachedGenerators={}cachedHooks={}cachedPallets={}cachedVaults={}cachedBloodEffects={}cachedGates={}
local function processValue(instance)
if not instance or not instance["Parent"]then
return
end
local name=instance["ClassName"]
if name~="Model"and(name~="Part"and name~="Folder")then
return
end
local name2=instance["Name"]
if name2=="Generator"and instance:IsA("Model")then
if not table["find"](cachedGenerators, instance)then
table["insert"](cachedGenerators, instance)
end
elseif name2=="Palletwrong"then
if not table["find"](cachedPallets, instance)then
table["insert"](cachedPallets, instance)
end
elseif name2=="Window"or(name2:lower()):find("window")or name2=="Vault"or(name2:lower()):find("vault")then
local conditionMet2=false
local conditionMet3=false
local conditionMet4=false
for index, instance2 in ipairs(instance:GetDescendants())do
local name3=instance2["Name"]:lower()
if name3=="bottom"then
conditionMet2=true
elseif name3=="inviswall"then
conditionMet3=true
elseif name3=="vaulttrigger"then
conditionMet4=true
end
end
if conditionMet2 and(conditionMet3 and conditionMet4)then
if not table["find"](cachedVaults, instance)then
table["insert"](cachedVaults, instance)
end
end
elseif name2=="VaultTrigger"or(name2:lower()):find("vaulttrigger")then
local instance2=instance["Parent"]
if instance2 and((instance2:IsA("Model")or instance2:IsA("Folder")))then
local conditionMet2=false
local conditionMet3=false
for index, instance3 in ipairs(instance2:GetDescendants())do
local name3=instance3["Name"]:lower()
if name3=="bottom"then
conditionMet2=true
elseif name3=="inviswall"then
conditionMet3=true
end
end
if conditionMet2 and conditionMet3 then
if not table["find"](cachedVaults, instance2)then
table["insert"](cachedVaults, instance2)
end
end
end
elseif name2=="BloodEffect"and instance:IsA("BasePart")then
if not table["find"](cachedBloodEffects, instance)then
table["insert"](cachedBloodEffects, instance)
end
elseif name2=="Hook"or name2=="HookPoint"then
local players=Players:GetPlayers()
local playersById={}
for index, player in ipairs(players)do
if player["Character"]then
playersById[player["Character"]]=true
end
end
local conditionMet2=false
local currentValue=instance
while currentValue and currentValue~=workspace do
if playersById[currentValue]then
conditionMet2=true
break
end
currentValue=currentValue["Parent"]
end
if not conditionMet2 then
local cachedValue=nil
if instance:IsA("BasePart")then
cachedValue=instance
elseif instance:IsA("Model")or instance:IsA("Folder")then
cachedValue=instance:FindFirstChild("HookPoint")or instance["PrimaryPart"]or instance:FindFirstChild("Handle")or instance:FindFirstChildWhichIsA("BasePart")
end
if cachedValue then
if not table["find"](cachedHooks, cachedValue)then
table["insert"](cachedHooks, cachedValue)
end
end
end
elseif name2=="Gate"then
if not table["find"](cachedGates, instance)then
table["insert"](cachedGates, instance)
end
end
end
local function processValue2(name)
if not name then
return
end
local name2=name["Name"]
if name2=="Generator"then
local itemIndex=table["find"](cachedGenerators, name)
if itemIndex then
table["remove"](cachedGenerators, itemIndex)
end
pcall(function()removeModelESP(name, "Generator")
end
)
elseif name2=="Palletwrong"then
local itemIndex=table["find"](cachedPallets, name)
if itemIndex then
table["remove"](cachedPallets, itemIndex)
end
pcall(function()removeModelESP(name, "Pallet")
end
)
elseif name2=="Window"or(name2:lower()):find("window")or name2=="Vault"or(name2:lower()):find("vault")then
local itemIndex=table["find"](cachedVaults, name)
if itemIndex then
table["remove"](cachedVaults, itemIndex)
end
pcall(function()removeModelESP(name, "Vault")
end
)
elseif name2=="VaultTrigger"or(name2:lower()):find("vaulttrigger")then
local currentValue=name["Parent"]
if currentValue then
local itemIndex=table["find"](cachedVaults, currentValue)
if itemIndex then
table["remove"](cachedVaults, itemIndex)
end
pcall(function()removeModelESP(currentValue, "Vault")
end
)
end
elseif name2=="BloodEffect"then
local itemIndex=table["find"](cachedBloodEffects, name)
if itemIndex then
table["remove"](cachedBloodEffects, itemIndex)
end
pcall(function()removeModelESP(name, "BloodEffect")
end
)
elseif name2=="Hook"or name2=="HookPoint"then
local itemIndex=table["find"](cachedHooks, name)
if itemIndex then
table["remove"](cachedHooks, itemIndex)pcall(function()removeModelESP(name, "Hook")
end
)
else
for key=#cachedHooks, 1, -1 do
local currentValue=cachedHooks[key]
if currentValue==name or currentValue:IsDescendantOf(name)then
table["remove"](cachedHooks, key)pcall(function()removeModelESP(currentValue, "Hook")
end
)
end
end
end
elseif name2=="Gate"then
local itemIndex=table["find"](cachedGates, name)
if itemIndex then
table["remove"](cachedGates, itemIndex)
end
pcall(function()removeModelESP(name, "Gate")
end
)
end
end
registerConnection(workspace["DescendantAdded"]:Connect(function(value)pcall(processValue, value)
end
))
for index, item in ipairs(workspace:GetDescendants())do
pcall(processValue, item)
end
registerConnection(workspace["DescendantRemoving"]:Connect(function(value)pcall(processValue2, value)
end
))
local items4={["71008020992570"]=true;
["72742711718023"]=true;
["72908958549833"]=true, ["73681849513551"]=true, ["73923929500477"]=true, ["74968262036854"]=true;
["75258958842388"]=true, ["75857500533792"]=true;
["76385865186777"]=true;
["76503974441748"]=true;
["76744850905644"]=true;
["77081789642514"]=true, ["78432063483146"]=true;
["78935059863801"]=true;
["79935565590141"]=true;
["79965656177566"]=true;
["80411309607666"]=true, ["82666958311998"]=true, ["83873880822918"]=true, ["84093948968516"]=true, ["84525330720658"]=true;
["85030641905220"]=true, ["86266790353635"]=true;
["89185525343404"]=true;
["92098503722633"]=true;
["92125118598365"]=true;
["92362656727126"]=true;
["92554564590253"]=true, ["93136435416899"]=true;
["96839438835309"]=true, ["98163597193511"]=true;
["99210996402874"]=true, ["99472251587670"]=true, ["102055678391920"]=true;
["104689417033027"]=true, ["105374834496520"]=true;
["106871536134254"]=true, ["109402730355822"]=true;
["109928123357793"]=true;
["110355011987939"]=true;
["110466971021611"]=true, ["111223305405046"]=true, ["111920872708571"]=true;
["112166042383605"]=true, ["112633191985365"]=true, ["112840768179724"]=true;
["113255068724446"]=true;
["115244153053858"]=true;
["117042998468241"]=true;
["117070354890871"]=true, ["117207742458428"]=true, ["117886494230451"]=true;
["118907603246885"]=true, ["119752564209631"]=true, ["121108316060822"]=true;
["121216847022485"]=true, ["121571390309073"]=true, ["122812055447896"]=true;
["123047897844134"]=true, ["123812278891591"]=true, ["124706657239027"]=true, ["124735239320776"]=true, ["125224839697689"]=true;
["126081405469607"]=true, ["126497551689502"]=true;
["126527634689050"]=true;
["126626340093785"]=true;
["126751859125353"]=true, ["128241974219045"]=true;
["129784271201071"]=true;
["130012819736632"]=true;
["130585295123651"]=true;
["130593238885843"]=true;
["132817836308238"]=true;
["133002120549396"]=true, ["133881825716964"]=true, ["133963973694098"]=true, ["134838390519433"]=true, ["135002183282873"]=true, ["135403091566760"]=true;
["135727476735024"]=true;
["136365031119137"]=true, ["137504605181913"]=true;
["137688077908355"]=true, ["137795837089724"]=true;
["137846825408335"]=true;
["138045669415653"]=true;
["138720291317243"]=true;
["139369275981139"]=true;
["117187218825161"]=true, ["105221485497534"]=true;
["86868198964957"]=true;
["134758728973154"]=true;
["132636403911470"]=true;
["125350153877085"]=true, ["2874840706"]=true, ["110850539331763"]=true, ["72042024"]=true;
["102746205979822"]=true}
local items5={["135181748009911"]=true, ["77210283630654"]=true, ["108211560927158"]=true;
["104192089592095"]=true;
["109257644640676"]=true;
["98163597193511"]=true;
["111223305405046"]=true, ["75258958842388"]=true, ["93136435416899"]=true;
["92098503722633"]=true;
["117886494230451"]=true}
local items6={}function updateSCPCache()
local items7={}
local items8={}
local function processValue3(callback)
if callback and not items8[callback]then
items8[callback]=true table["insert"](items7, callback)
end
end
local instance=workspace:FindFirstChild("Map")
if instance then
for index, item in ipairs({"1";
"2"})do
local child=instance:FindFirstChild(item)
if child then
for index2, instance2 in ipairs(child:GetChildren())do
if instance2:IsA("Model")then
processValue3(instance2)
end
end
end
end
local function conditionMet2(callback)
return string["match"](callback:lower(), "^scp%d*$")~=nil
end
for index, instance2 in ipairs(instance:GetChildren())do
if instance2["Name"]~="1"and instance2["Name"]~="2"then
if instance2:IsA("Model")and conditionMet2(instance2["Name"])then
processValue3(instance2)
elseif instance2:IsA("Folder")or instance2:IsA("Model")then
for index2, instance3 in ipairs(instance2:GetChildren())do
if instance3:IsA("Model")and conditionMet2(instance3["Name"])then
processValue3(instance3)
end
end
end
end
end
for index, instance2 in ipairs(instance:GetChildren())do
if instance2:IsA("Model")and instance2~=localPlayer["Character"]then
local cured=instance2:GetAttribute("Cured")
if tonumber(cured)==3 then
processValue3(instance2)
end
end
end
end
items6=items7
end
local cachedValue=nil
local name="Unknown Map"function getMapName()
local success, result=pcall(function()
return(game:GetService("Players"))["LocalPlayer"]["PlayerGui"]["Darkness"]["Frame"]["MapInfo"]["MapTitle"]["Text"]
end
)
if success and(result and result~="")then
if result:upper()=="NOSTROMO"then
return"Loading..."
end
return result
end
local instance=workspace:FindFirstChild("Map")
if not instance then
cachedValue=nil name="Unknown Map"
return name
end
local child=instance:FindFirstChildOfClass("Model")or instance:FindFirstChildOfClass("Folder")or instance
if child==cachedValue and name~="Unknown Map"then
return name
end
cachedValue=child
if instance:FindFirstChild("HooksMeat", true)then
name="BLOODBATH! Club"
return name
end
if instance:FindFirstChild("Rooftop", true)then
name="Mercy Hospital Rooftop"
return name
end
if instance:FindFirstChild("inviswallasylum", true)then
name="Mount Massive Asylum"
return name
end
if instance:FindFirstChild("Tesla", true)then
name="Site 68"
return name
end
if instance:FindFirstChild("Breakwater", true)then
name="The Bay Harbor"
return name
end
if instance:FindFirstChild("RockVar0", true)then
name="Woodview Cabin"
return name
end
local model=instance:FindFirstChild("Model", true)
if model then
local currentValue=(model:GetPivot())["Position"]
if((currentValue-Vector3["new"](-811.4, 212.8, -7774.5)))["Magnitude"]<100 then
name="Firelink Shrine"
return name
end
if((currentValue-Vector3["new"](1114.67, -16.92, -12.99)))["Magnitude"]<100 then
name="Valdelobos Village"
return name
end
end
name="Unknown Map"
return name
end
function applyBlockInteractions()pcall(function()
local instance=(game:GetService("ReplicatedStorage")):FindFirstChild("Remotes")instance=instance and instance:FindFirstChild("Window")instance=instance and instance:FindFirstChild("VaultEvent")
if instance then
for index, instance2 in ipairs(cachedVaults)do
if instance2 and instance2["Parent"]then
for index2, instance3 in ipairs(instance2:GetDescendants())do
if instance3["Name"]=="VaultTrigger"then
instance:FireServer(instance3, true)
end
end
end
end
end
end
)pcall(function()
local instance=(game:GetService("ReplicatedStorage")):FindFirstChild("Remotes")instance=instance and instance:FindFirstChild("Pallet")instance=instance and instance:FindFirstChild("PalletSlideEvent")
if instance then
for index, instance2 in ipairs(cachedPallets)do
if instance2 and instance2["Parent"]then
for index2, instance3 in ipairs(instance2:GetDescendants())do
if instance3["Name"]=="PalletPointSlide"or instance3["Name"]:find("Slide")then
instance:FireServer(instance3, true)
end
end
end
end
end
end
)
end
function releaseBlockInteractions()pcall(function()
local instance=(game:GetService("ReplicatedStorage")):FindFirstChild("Remotes")instance=instance and instance:FindFirstChild("Window")instance=instance and instance:FindFirstChild("VaultCompleteEvent")
if instance then
local map=workspace:FindFirstChild("Map")
local currentValue=map or workspace
for index, instance2 in ipairs(currentValue:GetDescendants())do
if instance2["Name"]=="VaultTrigger"then
instance:FireServer(instance2, false)
end
end
end
end
)pcall(function()
local instance=(game:GetService("ReplicatedStorage")):FindFirstChild("Remotes")instance=instance and instance:FindFirstChild("Pallet")instance=instance and instance:FindFirstChild("PalletSlideCompleteEvent")
if instance then
for index, instance2 in ipairs(cachedPallets)do
if instance2 and instance2["Parent"]then
for index2, instance3 in ipairs(instance2:GetDescendants())do
if instance3["Name"]=="PalletPointSlide"or instance3["Name"]:find("Slide")then
instance:FireServer(instance3)
end
end
end
end
end
end
)
end
function scanMapObjects()
local currentValue, currentValue2, items7, items8, items9, items10={}, {}, {}, {}, {}, {}
local success={}pcall(updateSCPCache)pcall(function()playerStateCache={}characterStateCache={}
end
)
local players=Players:GetPlayers()
local playersById={}
for index, player in ipairs(players)do
if player["Character"]then
playersById[player["Character"]]=true
end
end
local map=workspace:FindFirstChild("Map")
local descendants=map and map:GetDescendants()or workspace:GetDescendants()
for index, instance in ipairs(descendants)do
if index%2000==0 then
task["wait"]()
end
local name2=instance["Name"]
if name2=="Generator"and instance:IsA("Model")then
table["insert"](currentValue, instance)
elseif name2=="Palletwrong"then
table["insert"](items7, instance)
elseif name2=="Window"or(name2:lower()):find("window")or name2=="Vault"or(name2:lower()):find("vault")then
local conditionMet2=false
local conditionMet3=false
local conditionMet4=false
for index2, instance2 in ipairs(instance:GetDescendants())do
local name3=instance2["Name"]:lower()
if name3=="bottom"then
conditionMet2=true
elseif name3=="inviswall"then
conditionMet3=true
elseif name3=="vaulttrigger"then
conditionMet4=true
end
end
if conditionMet2 and(conditionMet3 and conditionMet4)then
table["insert"](items8, instance)
end
elseif name2=="BloodEffect"and instance:IsA("BasePart")then
table["insert"](items9, instance)
elseif name2=="Hook"or name2=="HookPoint"then
local conditionMet2=false
local currentValue3=instance
while currentValue3 and currentValue3~=workspace do
if playersById[currentValue3]then
conditionMet2=true
break
end
currentValue3=currentValue3["Parent"]
end
if not conditionMet2 then
local cachedValue2=nil
if instance:IsA("BasePart")then
cachedValue2=instance
elseif instance:IsA("Model")or instance:IsA("Folder")then
cachedValue2=instance:FindFirstChild("HookPoint")or instance["PrimaryPart"]or instance:FindFirstChild("Handle")or instance:FindFirstChildWhichIsA("BasePart")
end
if cachedValue2 and not success[cachedValue2]then
success[cachedValue2]=true table["insert"](currentValue2, cachedValue2)
end
end
elseif name2=="Gate"then
table["insert"](items10, instance)
end
end
cachedGenerators=currentValue cachedHooks=currentValue2 cachedPallets=items7 cachedVaults=items8 cachedBloodEffects=items9 cachedGates=items10
end
invalidateEspStyles=function()
for key, item in pairs(ActiveESP["Players"])do
item["LastESPStyle"]=nil
end
for key, item in pairs({ActiveESP["Generators"], ActiveESP["Hooks"];
ActiveESP["Pallets"], ActiveESP["Vaults"], ActiveESP["BloodEffects"], ActiveESP["Gates"];
ActiveESP["SCPs"]})do
for key2, item2 in pairs(item)do
item2["LastESPStyle"]=nil
end
end
end
function createPlayerESP(player)
if ActiveESP["Players"][player]then
return
end
local highlight=Instance["new"]("Highlight")highlight["FillTransparency"]=.6 highlight["OutlineTransparency"]=.1 highlight["Enabled"]=false highlight["Parent"]=highlightParent
local billboard=Instance["new"]("BillboardGui")billboard["AlwaysOnTop"]=true billboard["StudsOffset"]=Vector3["new"](0, 3.5, 0)billboard["Enabled"]=false billboard["Parent"]=billboardParent
local frame=Instance["new"]("Frame")frame["Name"]="Container"frame["BackgroundTransparency"]=1 frame["BorderSizePixel"]=0 frame["Parent"]=billboard
local corner=Instance["new"]("UICorner")corner["CornerRadius"]=UDim["new"](0, 6)corner["Parent"]=frame
local stroke=Instance["new"]("UIStroke")stroke["Thickness"]=1 stroke["Transparency"]=1 stroke["Parent"]=frame
local label=Instance["new"]("TextLabel")label["BackgroundTransparency"]=1 label["TextColor3"]=Color3["fromRGB"](255, 255, 255)label["Font"]=Enum["Font"]["GothamBold"]label["TextStrokeTransparency"]=.4 label["Parent"]=frame
local label2=Instance["new"]("TextLabel")label2["BackgroundTransparency"]=1 label2["TextColor3"]=Color3["fromRGB"](220, 220, 220)label2["Font"]=Enum["Font"]["Gotham"]label2["TextStrokeTransparency"]=.78 label2["Parent"]=frame ActiveESP["Players"][player]={["Highlight"]=highlight, ["Billboard"]=billboard, ["Container"]=frame, ["ContainerStroke"]=stroke, ["NameLabel"]=label, ["InfoLabel"]=label2;
["Tracer"]=nil;
["CurrentCharacter"]=nil;
["LastAuraEnabled"]=nil, ["LastHighlightColor"]=nil;
["LastBillboardEnabled"]=nil, ["LastNameText"]=nil, ["LastNameColor"]=nil;
["LastInfoText"]=nil, ["LastHookedProgressVal"]=nil, ["LastHookedChangeTime"]=0, ["LastESPStyle"]=nil;
["LastIsMobile"]=nil}
end
local function cleanupResources(value, contextValue)
local currentValue=value["Tracer"]
if not currentValue then
return
end
pcall(function()
if type(currentValue)=="table"then
if not currentValue["Remove"]then
for key, container in pairs(currentValue)do
container["Visible"]=contextValue
end
else
currentValue["Visible"]=contextValue
end
else
currentValue["Visible"]=contextValue
end
end
)
end
function removePlayerESP(player)
local highlight=ActiveESP["Players"][player]
if highlight then
if highlight["Highlight"]then
pcall(function()highlight["Highlight"]:Destroy()
end
)
end
if highlight["Billboard"]then
pcall(function()highlight["Billboard"]:Destroy()
end
)
end
if highlight["Tracer"]then
pcall(function()
if type(highlight["Tracer"])=="table"then
if highlight["Tracer"]["Remove"]then
highlight["Tracer"]:Remove()
else
for key, item in pairs(highlight["Tracer"])do
pcall(function()item:Remove()
end
)
end
end
else
highlight["Tracer"]:Destroy()
end
end
)highlight["Tracer"]=nil
end
ActiveESP["Players"][player]=nil
end
end
local conditionMet2=false function updatePlayersESP()
if isSpectating()then
if not conditionMet2 then
for index, item in ipairs(Players:GetPlayers())do
if item~=localPlayer then
local highlight=ActiveESP["Players"][item]
if highlight then
if highlight["LastAuraEnabled"]~=false then
highlight["Highlight"]["Enabled"]=false highlight["LastAuraEnabled"]=false
end
if highlight["LastBillboardEnabled"]~=false then
highlight["Billboard"]["Enabled"]=false highlight["LastBillboardEnabled"]=false
end
if highlight["Tracer"]then
highlight["Tracer"]["Visible"]=false
end
highlight["CurrentCharacter"]=nil
end
end
end
conditionMet2=true
end
return
end
if not settings["MasterESP"]or(not settings["KillerESP"]["Enabled"]and not settings["SurvivorESP"]["Enabled"])then
if not conditionMet2 then
for index, item in ipairs(Players:GetPlayers())do
if item~=localPlayer then
local highlight=ActiveESP["Players"][item]
if highlight then
if highlight["LastAuraEnabled"]~=false then
highlight["Highlight"]["Enabled"]=false highlight["LastAuraEnabled"]=false
end
if highlight["LastBillboardEnabled"]~=false then
highlight["Billboard"]["Enabled"]=false highlight["LastBillboardEnabled"]=false
end
if highlight["Tracer"]then
highlight["Tracer"]["Visible"]=false
end
highlight["CurrentCharacter"]=nil
end
end
end
conditionMet2=true
end
return
end
conditionMet2=false
local espstyle=settings["ESPStyle"]or"Standard"
for index, player in ipairs(Players:GetPlayers())do
if player==localPlayer then
continue
end
createPlayerESP(player)
local progress=ActiveESP["Players"][player]
if not progress then
continue
end
local instance=player["Character"]
local rootPart=instance and instance:FindFirstChild("HumanoidRootPart")
local rootPart2=progress["IsKiller"]
local teamName=progress["IsSurvivor"]
local conditionMet3=false
if rootPart2==nil or progress["CurrentCharacter"]~=instance then
local isMatchingTeam=player["Team"]rootPart2=isMatchingTeam and isMatchingTeam["Name"]=="Killer"teamName=isMatchingTeam and isMatchingTeam["Name"]=="Survivors"
if not isMatchingTeam then
local name2=player["Name"]:lower()
if name2:find("killer")then
rootPart2=true
elseif name2:find("survivor")then
teamName=true
end
end
if instance then
local name2=instance["Parent"]and instance["Parent"]["Name"]
if name2=="Killers"or instance:FindFirstChild("StunEvent")then
rootPart2=true teamName=false
elseif instance["Name"]=="Veil"or(instance["Parent"]and instance["Parent"]["Name"]=="Veil")then
rootPart2=true teamName=false
end
local cured=instance:GetAttribute("Cured")
if cured==3 then
conditionMet3=true rootPart2=true teamName=false
end
end
if rootPart2==nil then
rootPart2=false
end
if teamName==nil then
teamName=false
end
progress["IsKiller"]=rootPart2 progress["IsSurvivor"]=teamName
else
if instance then
local cured=instance:GetAttribute("Cured")
if cured==3 then
conditionMet3=true rootPart2=true teamName=false
end
end
end
local conditionMet4=false
local teamName2=Color3["fromRGB"](255, 255, 255)
local isKnocked=false
local isHooked=false
if instance then
local isKnocked2=getObjectValue(instance, "Knocked")
if isKnocked2==true or(tostring(isKnocked2)):lower()=="true"or isKnocked2==1 then
isKnocked=true
end
local isHooked2=getObjectValue(instance, "IsHooked")==true or instance:GetAttribute("IsHooked")==true
if isHooked2 then
isHooked=true
else
local progress2=getObjectValue(instance, "HookedProgress")
if progress2 and tonumber(progress2)then
local progress3=tonumber(progress2)
if progress["LastHookedProgressVal"]==nil then
progress["LastHookedProgressVal"]=progress3 progress["LastHookedChangeTime"]=0
elseif progress["LastHookedProgressVal"]~=progress3 then
progress["LastHookedProgressVal"]=progress3 progress["LastHookedChangeTime"]=os["clock"]()
end
if os["clock"]()-((progress["LastHookedChangeTime"]or 0))<2 then
isHooked=true
end
else
progress["LastHookedProgressVal"]=nil
end
end
end
local distance=getDistance(player, rootPart)
local isEnabled=distance<=settings["ESPRange"]
if conditionMet3 and(settings["KillerESP"]["Enabled"]and isEnabled)then
conditionMet4=true
local espcolors=settings["ESPColors"]and settings["ESPColors"]["SCP"]teamName2=espcolors or Color3["fromRGB"](0, 220, 80)
elseif rootPart2 and(settings["KillerESP"]["Enabled"]and isEnabled)then
conditionMet4=true teamName2=getESPColor("Killer")
elseif teamName and(settings["SurvivorESP"]["Enabled"]and isEnabled)then
conditionMet4=true
if isKnocked or isHooked then
teamName2=getESPColor("SurvivorKnocked")
else
local health, health2=getPlayerHealthPercent(player)
if health<health2 then
teamName2=getESPColor("SurvivorInjured")
else
teamName2=getESPColor("SurvivorHealthy")
end
end
end
if conditionMet4 and(rootPart and instance)then
if progress["CurrentCharacter"]~=instance then
progress["Highlight"]["Adornee"]=instance progress["Billboard"]["Adornee"]=rootPart progress["CurrentCharacter"]=instance
end
local killeresp=rootPart2 and settings["KillerESP"]["Aura"]or teamName and settings["SurvivorESP"]["Aura"]
local conditionMet5=false
if instance["Parent"]and instance["Parent"]~=workspace then
if instance["Parent"]:IsA("Model")and instance["Parent"]:FindFirstChildOfClass("Humanoid")then
conditionMet5=true
elseif(instance["Parent"]["Name"]:lower()):find("carry")or(instance["Parent"]["Name"]:lower()):find("carried")then
conditionMet5=true
end
end
if teamName and conditionMet5 then
killeresp=false
end
local transparency=1
local espdistancefade=settings["ESPDistanceFade"]and settings["ESPDistanceFadePlayers"]
if espdistancefade and distance then
if distance>=settings["ESPFadeMax"]then
transparency=0
elseif distance>settings["ESPFadeStart"]then
local espfademax=settings["ESPFadeMax"]-settings["ESPFadeStart"]
local espfadestart=distance-settings["ESPFadeStart"]transparency=1-(espfadestart/espfademax)
end
end
local highlight=.6
local highlight2=.1
if espstyle~="Old"and((isMobileDevice or espstyle=="Compact"or espstyle=="Minimal"))then
highlight=.8 highlight2=.4
end
local highlight3=killeresp
if espdistancefade then
highlight=1-(((1-highlight))*transparency)highlight2=1-(((1-highlight2))*transparency)highlight3=killeresp and(transparency>.01)
end
if progress["LastAuraEnabled"]~=highlight3 then
progress["Highlight"]["Enabled"]=highlight3 progress["LastAuraEnabled"]=highlight3
end
if progress["LastHighlightColor"]~=teamName2 then
progress["Highlight"]["FillColor"]=teamName2 progress["Highlight"]["OutlineColor"]=teamName2 progress["LastHighlightColor"]=teamName2
end
if progress["ContainerStroke"]and progress["ContainerStroke"]["Color"]~=teamName2 then
progress["ContainerStroke"]["Color"]=teamName2
end
if progress["Highlight"]["FillTransparency"]~=highlight then
progress["Highlight"]["FillTransparency"]=highlight
end
if progress["Highlight"]["OutlineTransparency"]~=highlight2 then
progress["Highlight"]["OutlineTransparency"]=highlight2
end
local name2=1-transparency
if progress["NameLabel"]["TextTransparency"]~=name2 then
progress["NameLabel"]["TextTransparency"]=name2 progress["NameLabel"]["TextStrokeTransparency"]=1-(.6*transparency)
end
if progress["InfoLabel"]["TextTransparency"]~=name2 then
progress["InfoLabel"]["TextTransparency"]=name2 progress["InfoLabel"]["TextStrokeTransparency"]=1-(.5*transparency)
end
if settings["ESPBackground"]then
local espbackground=settings["ESPBackground"]and.62 or 1
local espbackground2=settings["ESPBackground"]and.24 or 1
if espdistancefade then
espbackground=1-(((1-espbackground))*transparency)espbackground2=1-(((1-espbackground2))*transparency)
end
if progress["Container"]["BackgroundTransparency"]~=espbackground then
progress["Container"]["BackgroundTransparency"]=espbackground
end
if progress["ContainerStroke"]["Transparency"]~=espbackground2 then
progress["ContainerStroke"]["Transparency"]=espbackground2
end
end
if progress["LastESPStyle"]~=espstyle or progress["LastIsMobile"]~=isMobileDevice or progress["LastESPBackground"]~=settings["ESPBackground"]then
progress["LastESPStyle"]=espstyle progress["LastIsMobile"]=isMobileDevice progress["LastESPBackground"]=settings["ESPBackground"]
if espstyle=="Old"then
progress["Billboard"]["Size"]=UDim2["new"](0, 200, 0, 70)progress["Container"]["Size"]=UDim2["new"](1, 0, 1, 0)progress["Container"]["BackgroundTransparency"]=1 progress["ContainerStroke"]["Transparency"]=1 progress["NameLabel"]["Size"]=UDim2["new"](1, 0, .4, 0)progress["NameLabel"]["Position"]=UDim2["new"](0, 0, 0, 0)progress["NameLabel"]["TextSize"]=15 progress["NameLabel"]["Visible"]=true progress["InfoLabel"]["Size"]=UDim2["new"](1, 0, .6, 0)progress["InfoLabel"]["Position"]=UDim2["new"](0, 0, .4, 0)progress["InfoLabel"]["TextSize"]=13 progress["InfoLabel"]["Visible"]=true
elseif espstyle=="Standard"then
progress["Billboard"]["Size"]=isMobileDevice and UDim2["new"](0, 130, 0, 42)or UDim2["new"](0, 180, 0, 50)progress["Container"]["Size"]=UDim2["new"](1, 0, 1, 0)progress["Container"]["BackgroundColor3"]=Color3["fromRGB"](8, 10, 9)progress["Container"]["BackgroundTransparency"]=settings["ESPBackground"]and.62 or 1 progress["ContainerStroke"]["Color"]=Color3["fromRGB"](48, 64, 53)progress["ContainerStroke"]["Transparency"]=settings["ESPBackground"]and.24 or 1 progress["NameLabel"]["Size"]=UDim2["new"](1, 0, .45, 0)progress["NameLabel"]["Position"]=UDim2["new"](0, 0, .05, 0)progress["NameLabel"]["TextSize"]=isMobileDevice and 11 or 13 progress["NameLabel"]["Visible"]=true progress["InfoLabel"]["Size"]=UDim2["new"](1, 0, .45, 0)progress["InfoLabel"]["Position"]=UDim2["new"](0, 0, .5, 0)progress["InfoLabel"]["TextSize"]=isMobileDevice and 9 or 11 progress["InfoLabel"]["Visible"]=true
elseif espstyle=="Compact"then
progress["Billboard"]["Size"]=isMobileDevice and UDim2["new"](0, 110, 0, 18)or UDim2["new"](0, 145, 0, 22)progress["Container"]["Size"]=UDim2["new"](1, 0, 1, 0)progress["Container"]["BackgroundColor3"]=Color3["fromRGB"](8, 10, 9)progress["Container"]["BackgroundTransparency"]=settings["ESPBackground"]and.62 or 1 progress["ContainerStroke"]["Color"]=Color3["fromRGB"](48, 64, 53)progress["ContainerStroke"]["Transparency"]=settings["ESPBackground"]and.24 or 1 progress["NameLabel"]["Size"]=UDim2["new"](1, 0, 1, 0)progress["NameLabel"]["Position"]=UDim2["new"](0, 0, 0, 0)progress["NameLabel"]["TextSize"]=isMobileDevice and 9 or 11 progress["NameLabel"]["Visible"]=true progress["InfoLabel"]["Visible"]=false
elseif espstyle=="Minimal"then
progress["Billboard"]["Size"]=isMobileDevice and UDim2["new"](0, 42, 0, 16)or UDim2["new"](0, 52, 0, 20)progress["Container"]["Size"]=UDim2["new"](1, 0, 1, 0)progress["Container"]["BackgroundColor3"]=Color3["fromRGB"](8, 10, 9)progress["Container"]["BackgroundTransparency"]=settings["ESPBackground"]and.62 or 1 progress["ContainerStroke"]["Color"]=Color3["fromRGB"](48, 64, 53)progress["ContainerStroke"]["Transparency"]=settings["ESPBackground"]and.24 or 1 progress["NameLabel"]["Size"]=UDim2["new"](1, 0, 1, 0)progress["NameLabel"]["Position"]=UDim2["new"](0, 0, 0, 0)progress["NameLabel"]["TextSize"]=isMobileDevice and 9 or 11 progress["NameLabel"]["Visible"]=true progress["InfoLabel"]["Visible"]=false
end
end
if espstyle=="Aura Only"then
if progress["LastBillboardEnabled"]~=false then
progress["Billboard"]["Enabled"]=false progress["LastBillboardEnabled"]=false
end
else
local killeresp2=rootPart2 and settings["KillerESP"]["ShowName"]or teamName and settings["SurvivorESP"]["ShowName"]
if killeresp2==nil then
killeresp2=true
end
local text=killeresp2 and((player["DisplayName"]or player["Name"]))or""
if killeresp2 and((settings["SurvivorESP"]["CensorNames"]or(settings["HideLivePlayersMode"]and settings["HideLivePlayersMode"]~="Normal")))then
text="[隐藏]"
end
local text2=string["format"]("%dm", distance)
local text3="Healed"
if isKnocked then
text3="Knocked"
elseif isHooked then
text3="Hooked"
else
local health, health2=getPlayerHealthPercent(player)
if health<health2 then
text3="Injured"
end
end
local numericValue=0
if teamName then
local instance2=workspace:FindFirstChild(player["Name"])
if instance2 then
local hookcount=instance2:GetAttribute("HookCount")
if hookcount~=nil then
numericValue=tonumber(hookcount)or 0
else
local hookcount2=instance2:FindFirstChild("HookCount")
if hookcount2 and hookcount2["Value"]~=nil then
numericValue=tonumber(hookcount2["Value"])or 0
end
end
end
if numericValue==0 and instance then
local hookcount=instance:GetAttribute("HookCount")
if hookcount~=nil then
numericValue=tonumber(hookcount)or 0
else
local instance3=instance:FindFirstChild("HookCount")
if instance3 and((instance3:IsA("ValueObject")or instance3:IsA("NumberValue")or instance3:IsA("IntValue")))then
numericValue=tonumber(instance3["Value"])or 0
end
end
end
end
local espStyle=""
local displayText=""
if espstyle=="Old"or espstyle=="Standard"then
espStyle=text
local espStyle2=""
local conditionMet6=(espstyle=="Old")and"\n"or"  "
if(rootPart2 and settings["KillerESP"]["Distance"])or(teamName and settings["SurvivorESP"]["Distance"])then
espStyle2=espStyle2..string["format"]("[%d 米]"..conditionMet6, distance)
end
if rootPart2 and settings["KillerESP"]["SelectedKiller"]then
local killerName=getSelectedKiller(player)espStyle2=espStyle2..("杀手："..(killerName..conditionMet6))
end
if teamName and settings["SurvivorESP"]["HealthState"]then
espStyle2=espStyle2..("状态："..(translateText(text3)..conditionMet6))
end
if teamName and(settings["SurvivorESP"]["ShowHookCount"]and numericValue>0)then
espStyle2=espStyle2..("上钩："..(numericValue..conditionMet6))
end
displayText=espStyle2
elseif espstyle=="Compact"then
local killeresp3=(rootPart2 and settings["KillerESP"]["Distance"])or(teamName and settings["SurvivorESP"]["Distance"])
local text4=killeresp3 and("["..(text2.."] "))or""
if rootPart2 then
local killerName=getSelectedKiller(player)
if settings["KillerESP"]["SelectedKiller"]and killerName~="None"then
if killeresp2 then
espStyle=string["format"]("%s%s (%s)", text4, text, killerName)
else
if killeresp3 then
espStyle=string["format"]("[%s] (%s)", text2, killerName)
else
espStyle=string["format"]("(%s)", killerName)
end
end
else
if killeresp2 then
espStyle=string["format"]("%s%s", text4, text)
else
espStyle=killeresp3 and string["format"]("[%s]", text2)or""
end
end
else
local displayText2=""
if settings["SurvivorESP"]["ShowHookCount"]and numericValue>0 then
displayText2=" | "..(numericValue.."钩")
end
if settings["SurvivorESP"]["HealthState"]and text3~="Healed"then
if killeresp2 then
espStyle=string["format"]("%s%s (%s%s)", text4, text, translateText(text3), displayText2)
else
if killeresp3 then
espStyle=string["format"]("[%s] (%s%s)", text2, translateText(text3), displayText2)
else
espStyle=string["format"]("(%s%s)", translateText(text3), displayText2)
end
end
else
if killeresp2 then
espStyle=string["format"]("%s%s%s", text4, text, displayText2)
else
if killeresp3 then
espStyle=string["format"]("[%s]%s", text2, displayText2)
else
espStyle=displayText2~=""and displayText2 or""
end
end
end
end
elseif espstyle=="Minimal"then
local killeresp3=(rootPart2 and settings["KillerESP"]["Distance"])or(teamName and settings["SurvivorESP"]["Distance"])
if killeresp3 then
espStyle=string["format"]("[%s]", text2)
else
if killeresp2 then
espStyle=text:sub(1, 4)
else
espStyle=""
end
end
end
local enabled=true
if espstyle=="Minimal"or espstyle=="Compact"then
if espStyle==""then
enabled=false
end
else
if espStyle==""and displayText:gsub("%s+", "")==""then
enabled=false
end
end
if progress["LastBillboardEnabled"]~=enabled then
progress["Billboard"]["Enabled"]=enabled progress["LastBillboardEnabled"]=enabled
end
if progress["LastNameText"]~=espStyle then
progress["NameLabel"]["Text"]=espStyle progress["LastNameText"]=espStyle
end
if progress["LastNameColor"]~=teamName2 then
progress["NameLabel"]["TextColor3"]=teamName2 progress["LastNameColor"]=teamName2
end
if espstyle=="Standard"or espstyle=="Old"then
if progress["LastInfoText"]~=displayText then
progress["InfoLabel"]["Text"]=displayText progress["LastInfoText"]=displayText
end
local conditionMet6=true
if settings["TracerTarget"]=="Killers Only"then
conditionMet6=rootPart2
elseif settings["TracerTarget"]=="Survivors Only"then
conditionMet6=teamName
end
local esptracers=settings["ESPTracers"]and(conditionMet4 and(rootPart and(instance and conditionMet6)))
local currentValue=progress["Tracer"]
if esptracers then
local camera=workspace["CurrentCamera"]
local screenPosition, onScreen=camera:WorldToViewportPoint(rootPart["Position"])
if onScreen then
local distance2=Vector2["new"](camera["ViewportSize"]["X"]/2, camera["ViewportSize"]["Y"])
if settings["TracerOrigin"]=="Center"then
distance2=Vector2["new"](camera["ViewportSize"]["X"]/2, camera["ViewportSize"]["Y"]/2)
elseif settings["TracerOrigin"]=="Top"then
distance2=Vector2["new"](camera["ViewportSize"]["X"]/2, 0)
end
local currentValue2=Vector2["new"](screenPosition["X"], screenPosition["Y"])
local distance3=1
if settings["ESPDistanceFade"]and distance then
if distance>=settings["ESPFadeMax"]then
distance3=0
elseif distance>settings["ESPFadeStart"]then
local espfademax=settings["ESPFadeMax"]-settings["ESPFadeStart"]
local espfadestart=distance-settings["ESPFadeStart"]distance3=1-(espfadestart/espfademax)
end
end
local currentValue3=teamName2
if settings["TracerColorMode"]=="Custom"then
currentValue3=getESPColor("Tracer")
end
local distance4=.8
if settings["ESPDistanceFade"]and settings["ESPDistanceFadeTracers"]then
distance4=.8*distance3
end
local isVisible=distance4>.01
if Drawing then
local conditionMet7=false
if not currentValue or type(currentValue)~="table"or currentValue["Remove"]then
conditionMet7=true
elseif settings["TracerStyle"]=="Arrow"and((not currentValue["Left"]or not currentValue["Right"]))then
conditionMet7=true
elseif settings["TracerStyle"]=="Line"and((currentValue["Left"]or currentValue["Right"]))then
conditionMet7=true
end
if conditionMet7 then
if currentValue then
pcall(function()
if type(currentValue)=="table"then
if currentValue["Remove"]then
currentValue:Remove()
else
for key, item in pairs(currentValue)do
pcall(function()item:Remove()
end
)
end
end
else
pcall(function()currentValue:Destroy()
end
)
end
end
)
end
if settings["TracerStyle"]=="Arrow"then
currentValue={["Line"]=Drawing["new"]("Line");
["Left"]=Drawing["new"]("Line");
["Right"]=Drawing["new"]("Line")}currentValue["Line"]["Thickness"]=1.5 currentValue["Left"]["Thickness"]=1.5 currentValue["Right"]["Thickness"]=1.5
else
currentValue={["Line"]=Drawing["new"]("Line")}currentValue["Line"]["Thickness"]=1.5
end
progress["Tracer"]=currentValue
end
for key, container in pairs(currentValue)do
container["Color"]=currentValue3 container["Transparency"]=distance4 container["Visible"]=isVisible
end
if isVisible then
if settings["TracerStyle"]=="Arrow"then
local distance5=((currentValue2-distance2))["Unit"]
if distance5["Magnitude"]>0 then
local currentValue4=Vector2["new"](-distance5["Y"], distance5["X"])
local numericValue2=10
local currentValue5=currentValue2-distance5*numericValue2
local currentValue6=currentValue5+currentValue4*((numericValue2*.5))
local currentValue7=currentValue5-currentValue4*((numericValue2*.5))currentValue["Line"]["From"]=distance2 currentValue["Line"]["To"]=currentValue5 currentValue["Left"]["From"]=currentValue2 currentValue["Left"]["To"]=currentValue6 currentValue["Right"]["From"]=currentValue2 currentValue["Right"]["To"]=currentValue7
else
currentValue["Line"]["From"]=distance2 currentValue["Line"]["To"]=currentValue2 currentValue["Left"]["Visible"]=false currentValue["Right"]["Visible"]=false
end
else
currentValue["Line"]["From"]=distance2 currentValue["Line"]["To"]=currentValue2
end
end
else
if not currentValue or type(currentValue)~="userdata"or currentValue["Parent"]==nil then
if type(currentValue)=="table"then
pcall(function()
for key, item in pairs(currentValue)do
pcall(function()item:Remove()
end
)
end
end
)
end
currentValue=Instance["new"]("Frame")currentValue["Name"]="Tracer_"..player["Name"]currentValue["BorderSizePixel"]=0 currentValue["BackgroundTransparency"]=.2 currentValue["AnchorPoint"]=Vector2["new"](.5, .5)currentValue["ZIndex"]=2 currentValue["Parent"]=minimapConnection progress["Tracer"]=currentValue
end
local distance5=currentValue2-distance2
local distance6=distance5["Magnitude"]
local distance7=math["atan2"](distance5["Y"], distance5["X"])
local layoutPosition=((distance2+currentValue2))/2 currentValue["Size"]=UDim2["new"](0, distance6, 0, 1.2)currentValue["Position"]=UDim2["new"](0, layoutPosition["X"], 0, layoutPosition["Y"])currentValue["Rotation"]=math["deg"](distance7)currentValue["BackgroundColor3"]=currentValue3
local distance8=.2
if settings["ESPDistanceFade"]and settings["ESPDistanceFadeTracers"]then
distance8=1-(.8*distance3)
end
currentValue["BackgroundTransparency"]=distance8 currentValue["Visible"]=distance8<.99
end
else
if currentValue then
cleanupResources(progress, false)
end
end
else
if currentValue then
cleanupResources(progress, false)
end
end
end
end
else
if progress["LastAuraEnabled"]~=false then
progress["Highlight"]["Enabled"]=false progress["LastAuraEnabled"]=false
end
if progress["LastBillboardEnabled"]~=false then
progress["Billboard"]["Enabled"]=false progress["LastBillboardEnabled"]=false
end
if progress["Tracer"]then
cleanupResources(progress, false)
end
progress["CurrentCharacter"]=nil
end
end
for key, item in pairs(ActiveESP["Players"])do
if not Players:FindFirstChild(key["Name"])then
removePlayerESP(key)
end
end
end
local items7={["Generator"]={["espList"]=function()
return ActiveESP["Generators"]
end
, ["isEnabled"]=function()
return settings["GeneratorESP"]["Enabled"]
end
, ["showAura"]=function()
return settings["GeneratorESP"]["Aura"]
end
, ["shouldSkip"]=function(value)
return isGeneratorCompleted(value)
end
, ["getText"]=function(instance, contextValue)
local progress=getGeneratorProgress(instance)
local progress2, currentValue, currentValue2=getGeneratorAnalytics(instance)
local displayText=""
if settings["GeneratorESP"]["ShowProgress"]then
displayText=string["format"]("\nProgress: %d%%", progress)
if settings["GeneratorESP"]["ShowRepairSpeed"]and progress2~=0 then
if progress2>0 then
displayText=displayText..string["format"](" (+%.1f%%/s)", progress2)
else
displayText=displayText..string["format"](" (%.1f%%/s)", progress2)
end
end
if settings["GeneratorESP"]["ShowETA"]and currentValue2~=""then
displayText=displayText..string["format"](" • ETA: %s", currentValue2)
end
if settings["GeneratorESP"]["ShowRepairingCount"]then
local playersrepairingcount=instance:GetAttribute("PlayersRepairingCount")or 0 displayText=displayText..string["format"](" (%d plyrs)", playersrepairingcount)
end
elseif settings["GeneratorESP"]["ShowRepairingCount"]then
local playersrepairingcount=instance:GetAttribute("PlayersRepairingCount")or 0 displayText=string["format"]("\nRepairing: %d plyrs", playersrepairingcount)
end
local generatoresp=settings["GeneratorESP"]["NoText"]and""or"Generator"
if settings["GeneratorESP"]["ShowDistance"]then
if generatoresp==""then
return string["format"]("[%dm]%s", contextValue, displayText)
else
return string["format"]("Generator [%dm]%s", contextValue, displayText)
end
end
return generatoresp..displayText
end
};
["Hook"]={["espList"]=function()
return ActiveESP["Hooks"]
end
;
["isEnabled"]=function()
return settings["HookESP"]["Enabled"]
end
;
["showAura"]=function()
return settings["HookESP"]["Aura"]
end
, ["shouldSkip"]=function()
return false
end
, ["getText"]=function(value, contextValue)
local hookesp=settings["HookESP"]["NoText"]and""or"Hook"
if settings["HookESP"]["ShowDistance"]then
return hookesp==""and string["format"]("[%dm]", contextValue)or string["format"]("Hook [%dm]", contextValue)
end
return hookesp
end
}, ["Pallet"]={["espList"]=function()
return ActiveESP["Pallets"]
end
, ["isEnabled"]=function()
return settings["PalletESP"]["Enabled"]
end
;
["showAura"]=function()
return settings["PalletESP"]["Aura"]
end
;
["shouldSkip"]=function()
return false
end
;
["getText"]=function(value, contextValue)
local palletesp=settings["PalletESP"]["NoText"]and""or"Pallet"
if settings["PalletESP"]["ShowDistance"]then
return palletesp==""and string["format"]("[%dm]", contextValue)or string["format"]("Pallet [%dm]", contextValue)
end
return palletesp
end
};
["Vault"]={["espList"]=function()
return ActiveESP["Vaults"]
end
, ["isEnabled"]=function()
return settings["VaultESP"]["Enabled"]
end
, ["showAura"]=function()
return settings["VaultESP"]["Aura"]
end
, ["shouldSkip"]=function()
return false
end
, ["getText"]=function(value, contextValue)
local vaultesp=settings["VaultESP"]["NoText"]and""or"Vault"
if settings["VaultESP"]["ShowDistance"]then
return vaultesp==""and string["format"]("[%dm]", contextValue)or string["format"]("Vault [%dm]", contextValue)
end
return vaultesp
end
};
["BloodEffect"]={["espList"]=function()
return ActiveESP["BloodEffects"]
end
, ["isEnabled"]=function()
return settings["BloodESP"]["Enabled"]
end
, ["showAura"]=function()
return settings["BloodESP"]["Aura"]
end
, ["shouldSkip"]=function()
return false
end
;
["getText"]=function(value, contextValue)
local bloodesp=settings["BloodESP"]["NoText"]and""or"Blood"
if settings["BloodESP"]["ShowDistance"]then
return bloodesp==""and string["format"]("[%dm]", contextValue)or string["format"]("Blood [%dm]", contextValue)
end
return bloodesp
end
}, ["Gate"]={["espList"]=function()
return ActiveESP["Gates"]
end
;
["isEnabled"]=function()
return settings["GateESP"]["Enabled"]
end
;
["showAura"]=function()
return settings["GateESP"]["Aura"]
end
;
["shouldSkip"]=function()
return false
end
, ["getText"]=function(value, contextValue)
local gateesp=settings["GateESP"]["NoText"]and""or"Gate"
local displayText=""
if settings["GateESP"]["ShowProgress"]then
local progress=getGateProgress(value)displayText=string["format"](" [%d%%]", progress)
end
if settings["GateESP"]["ShowDistance"]then
return gateesp==""and string["format"]("[%dm]%s", contextValue, displayText)or string["format"]("Gate [%dm]%s", contextValue, displayText)
end
return gateesp..displayText
end
}, ["SCP"]={["espList"]=function()
return ActiveESP["SCPs"]
end
, ["isEnabled"]=function()
return settings["SCPESP"]["Enabled"]
end
;
["showAura"]=function()
return settings["SCPESP"]["Aura"]
end
;
["shouldSkip"]=function()
return false
end
;
["getText"]=function(name2, contextValue)
local scpesp=settings["SCPESP"]["NoText"]and""or name2["Name"]:upper()
if settings["SCPESP"]["ShowDistance"]then
return scpesp==""and string["format"]("[%dm]", contextValue)or string["format"]("%s [%dm]", scpesp, contextValue)
end
return scpesp
end
}}
local espEntries={{["cached"]=function()
return cachedGenerators
end
;
["typeKey"]="Generator"}, {["cached"]=function()
return cachedHooks
end
;
["typeKey"]="Hook"};
{["cached"]=function()
return cachedPallets
end
, ["typeKey"]="Pallet"}, {["cached"]=function()
return cachedVaults
end
;
["typeKey"]="Vault"};
{["cached"]=function()
return cachedBloodEffects
end
, ["typeKey"]="BloodEffect"}, {["cached"]=function()
return cachedGates
end
, ["typeKey"]="Gate"};
{["cached"]=function()
return items6
end
, ["typeKey"]="SCP"}}function getModelTargetPart(instance)
if instance:IsA("Model")then
return instance["PrimaryPart"]or instance:FindFirstChildWhichIsA("BasePart")
end
if instance:IsA("BasePart")then
return instance
end
return nil
end
function getVaultHighlightPart(vault)
local instance=vault:FindFirstChild("Bottom")
if not instance or not instance:IsA("BasePart")then
local instance2=getModelTargetPart(vault)
if instance2 and instance2:IsA("BasePart")then
return instance2
end
if vault:IsA("BasePart")then
return vault
end
return vault:FindFirstChildWhichIsA("BasePart")or vault
end
local cachedValue2=nil
local distance=math["huge"]
for index, instance2 in ipairs(vault:GetDescendants())do
if instance2:IsA("BasePart")and(instance2~=instance and instance2["Name"]~="HumanoidRootPart")then
if instance2["Transparency"]<1 then
local distance2=((instance2["Position"]-instance["Position"]))["Magnitude"]
if distance2<distance then
distance=distance2 cachedValue2=instance2
end
end
end
end
return cachedValue2 or instance
end
function disableMapESPData(espData)
if espData["LastAuraEnabled"]~=false then
if espData["Highlight"]and espData["Highlight"]:IsA("Highlight")then
espData["Highlight"]["Enabled"]=false
elseif espData["Highlight"]and espData["Highlight"]:IsA("BoxHandleAdornment")then
espData["Highlight"]["Visible"]=false
end
espData["LastAuraEnabled"]=false
end
if espData["LastBillboardEnabled"]~=false then
espData["Billboard"]["Enabled"]=false espData["LastBillboardEnabled"]=false
end
end
function createModelESP(model, espType)
local currentValue=items7[espType]
if not currentValue then
return
end
local highlight=currentValue["espList"]()
if highlight[model]then
return
end
local text=getESPColor(espType)
local boxHandleAdornment
if espType=="Vault"then
boxHandleAdornment=Instance["new"]("BoxHandleAdornment")boxHandleAdornment["AlwaysOnTop"]=true boxHandleAdornment["ZIndex"]=5 boxHandleAdornment["Transparency"]=.6 boxHandleAdornment["Color3"]=text boxHandleAdornment["Visible"]=false boxHandleAdornment["Parent"]=highlightParent
else
boxHandleAdornment=Instance["new"]("Highlight")boxHandleAdornment["FillTransparency"]=.6 boxHandleAdornment["OutlineTransparency"]=.1 boxHandleAdornment["Enabled"]=false boxHandleAdornment["Parent"]=highlightParent
end
local billboard=Instance["new"]("BillboardGui")billboard["AlwaysOnTop"]=true billboard["StudsOffset"]=Vector3["new"](0, 3.5, 0)billboard["Enabled"]=false billboard["Parent"]=billboardParent
local frame=Instance["new"]("Frame")frame["Name"]="Container"frame["BackgroundTransparency"]=1 frame["BorderSizePixel"]=0 frame["Parent"]=billboard
local corner=Instance["new"]("UICorner")corner["CornerRadius"]=UDim["new"](0, 5)corner["Parent"]=frame
local stroke=Instance["new"]("UIStroke")stroke["Thickness"]=1 stroke["Transparency"]=1 stroke["Parent"]=frame
local label=Instance["new"]("TextLabel")label["BackgroundTransparency"]=1 label["TextColor3"]=text label["Font"]=Enum["Font"]["GothamBold"]label["TextStrokeTransparency"]=.4 label["Parent"]=frame
local target=getModelTargetPart(model)
local target2=model
if espType=="Vault"then
target2=getVaultHighlightPart(model)
elseif espType=="Hook"then
local instance=model
local cachedValue2=nil
while instance and instance~=workspace do
if instance["Name"]=="Model"and instance:IsA("Model")then
cachedValue2=instance
break
end
instance=instance["Parent"]
end
if not cachedValue2 then
cachedValue2=model:FindFirstChild("Model", true)or(model["Parent"]and model["Parent"]:FindFirstChild("Model", true))
end
if cachedValue2 then
target2=cachedValue2
end
end
highlight[model]={["Highlight"]=boxHandleAdornment, ["Billboard"]=billboard;
["Container"]=frame, ["ContainerStroke"]=stroke, ["NameLabel"]=label, ["TargetPart"]=target;
["TargetAdornee"]=target2, ["CachedPosition"]=target and target["Position"]or Vector3["new"](), ["LastAdornee"]=nil, ["LastAuraEnabled"]=nil;
["LastHighlightColor"]=nil;
["LastBillboardAdornee"]=nil, ["LastBillboardEnabled"]=nil, ["LastText"]=nil;
["LastESPStyle"]=nil;
["LastIsMobile"]=nil}
end
function removeModelESP(model, espType)
local currentValue=items7[espType]
if not currentValue then
return
end
local currentValue2=currentValue["espList"]()
local highlight=currentValue2[model]
if highlight then
if highlight["Highlight"]then
pcall(function()highlight["Highlight"]:Destroy()
end
)
end
if highlight["Billboard"]then
pcall(function()highlight["Billboard"]:Destroy()
end
)
end
currentValue2[model]=nil
end
end
local espEntries2={}function updateMapESP(value, contextValue)
local text=items7[value]
if not text then
return
end
if not settings["MasterESP"]or not text["isEnabled"]()then
if not espEntries2[value]then
local currentValue=text["espList"]()
for key, item in pairs(currentValue)do
disableMapESPData(item)
end
espEntries2[value]=true
end
return
end
espEntries2[value]=nil debug["profilebegin"]("Helper_UpdateMapESP_"..tostring(value))
local currentValue=text["espList"]()
local items8={}
for key, item in pairs(currentValue)do
if not key or not key["Parent"]or not key:IsDescendantOf(workspace)then
table["insert"](items8, key)
end
end
for index, item in ipairs(items8)do
pcall(function()removeModelESP(item, value)
end
)
end
local currentValue2=getESPColor(value)
local espstyle=settings["ESPStyle"]or"Standard"
local target=cachedRootPart
if not target then
local character=localPlayer["Character"]target=character and character:FindFirstChild("HumanoidRootPart")
end
for index, instance in ipairs(contextValue)do
if not instance or not instance["Parent"]then
continue
end
if text["shouldSkip"](instance)then
removeModelESP(instance, value)
continue
end
createModelESP(instance, value)
local target2=currentValue[instance]
if not target2 then
continue
end
local distance=currentValue2
local distance2=target2["CachedPosition"]
if value=="Hook"then
local distance3=distance2
if distance3 then
for index2, player in ipairs(Players:GetPlayers())do
if player~=localPlayer and player["Character"]then
local instance2=player["Character"]
local isHooked=instance2:GetAttribute("IsHooked")==true
if isHooked then
local rootPart=instance2:FindFirstChild("HumanoidRootPart")
if rootPart and((rootPart["Position"]-distance3))["Magnitude"]<=15 then
distance=Color3["fromRGB"](180, 20, 20)
break
end
end
end
end
end
elseif value=="Pallet"then
if target2["IsUsed"]then
distance=Color3["fromRGB"](90, 70, 40)
else
local conditionMet3=false
if instance:IsA("Model")or instance:IsA("Folder")then
conditionMet3=instance:FindFirstChild("PalletPointSlide", true)~=nil
end
if conditionMet3 then
target2["IsUsed"]=true distance=Color3["fromRGB"](90, 70, 40)
end
end
end
local target3=target2["TargetPart"]
local text2=target and(target3 and math["round"](((target["Position"]-distance2))["Magnitude"]))or math["huge"]
local inRange=text2<=settings["ESPRange"]
if target3 and inRange then
local instance2=target2["TargetAdornee"]
if target2["LastAdornee"]~=instance2 then
target2["Highlight"]["Adornee"]=instance2 target2["LastAdornee"]=instance2
if value=="Vault"and(instance2 and instance2:IsA("BasePart"))then
target2["Highlight"]["Size"]=instance2["Size"]target2["Highlight"]["CFrame"]=CFrame["new"]()
end
end
local currentValue3=text["showAura"]()
local transparency=1
local conditionMet3=false
if settings["ESPDistanceFade"]and settings["ESPDistanceFadeMap"]then
if value=="Generator"and settings["ESPDistanceFadeGenerators"]then
conditionMet3=true
elseif value=="Pallet"and settings["ESPDistanceFadePallets"]then
conditionMet3=true
elseif value=="Vault"and settings["ESPDistanceFadeVaults"]then
conditionMet3=true
elseif value=="Hook"and settings["ESPDistanceFadeHooks"]then
conditionMet3=true
elseif value=="Gate"and settings["ESPDistanceFadeGates"]then
conditionMet3=true
elseif value=="SCP"and settings["ESPDistanceFadeSCPs"]then
conditionMet3=true
elseif value=="BloodEffect"then
conditionMet3=true
end
end
if conditionMet3 and text2 then
if text2>=settings["ESPFadeMax"]then
transparency=0
elseif text2>settings["ESPFadeStart"]then
local espfademax=settings["ESPFadeMax"]-settings["ESPFadeStart"]
local espfadestart=text2-settings["ESPFadeStart"]transparency=1-(espfadestart/espfademax)
end
end
local highlight=currentValue3
if conditionMet3 then
highlight=currentValue3 and(transparency>.01)
end
if target2["LastAuraEnabled"]~=highlight then
if value=="Vault"then
target2["Highlight"]["Visible"]=highlight
else
target2["Highlight"]["Enabled"]=highlight
end
target2["LastAuraEnabled"]=highlight
end
if target2["LastHighlightColor"]~=distance then
if value=="Vault"then
target2["Highlight"]["Color3"]=distance
else
target2["Highlight"]["FillColor"]=distance target2["Highlight"]["OutlineColor"]=distance
end
target2["LastHighlightColor"]=distance
end
if target2["ContainerStroke"]and target2["ContainerStroke"]["Color"]~=distance then
target2["ContainerStroke"]["Color"]=distance
end
local highlight2=.6
local highlight3=.1
if espstyle~="Old"and((isMobileDevice or espstyle=="Compact"or espstyle=="Minimal"))then
highlight2=.85 highlight3=.4
end
if conditionMet3 then
highlight2=1-(((1-highlight2))*transparency)highlight3=1-(((1-highlight3))*transparency)
end
if value=="Vault"then
if target2["Highlight"]["Transparency"]~=highlight2 then
target2["Highlight"]["Transparency"]=highlight2
end
else
if target2["Highlight"]["FillTransparency"]~=highlight2 then
target2["Highlight"]["FillTransparency"]=highlight2
end
if target2["Highlight"]["OutlineTransparency"]~=highlight3 then
target2["Highlight"]["OutlineTransparency"]=highlight3
end
end
local name2=1-transparency
if target2["NameLabel"]["TextTransparency"]~=name2 then
target2["NameLabel"]["TextTransparency"]=name2 target2["NameLabel"]["TextStrokeTransparency"]=1-(.5*transparency)
end
if settings["ESPBackground"]then
local espbackground=settings["ESPBackground"]and.62 or 1
local espbackground2=settings["ESPBackground"]and.24 or 1
if conditionMet3 then
espbackground=1-(((1-espbackground))*transparency)espbackground2=1-(((1-espbackground2))*transparency)
end
if target2["Container"]["BackgroundTransparency"]~=espbackground then
target2["Container"]["BackgroundTransparency"]=espbackground
end
if target2["ContainerStroke"]["Transparency"]~=espbackground2 then
target2["ContainerStroke"]["Transparency"]=espbackground2
end
end
if target2["LastESPStyle"]~=espstyle or target2["LastIsMobile"]~=isMobileDevice or target2["LastESPBackground"]~=settings["ESPBackground"]then
target2["LastESPStyle"]=espstyle target2["LastIsMobile"]=isMobileDevice target2["LastESPBackground"]=settings["ESPBackground"]
if espstyle=="Old"then
target2["Billboard"]["Size"]=UDim2["new"](0, 150, 0, 45)target2["Container"]["Size"]=UDim2["new"](1, 0, 1, 0)target2["Container"]["BackgroundTransparency"]=1 target2["ContainerStroke"]["Transparency"]=1 target2["NameLabel"]["Size"]=UDim2["new"](1, 0, 1, 0)target2["NameLabel"]["Position"]=UDim2["new"](0, 0, 0, 0)target2["NameLabel"]["TextSize"]=14
elseif espstyle=="Standard"then
target2["Billboard"]["Size"]=isMobileDevice and UDim2["new"](0, 100, 0, 20)or UDim2["new"](0, 130, 0, 26)target2["Container"]["Size"]=UDim2["new"](1, 0, 1, 0)target2["Container"]["BackgroundColor3"]=Color3["fromRGB"](8, 10, 9)target2["Container"]["BackgroundTransparency"]=settings["ESPBackground"]and.62 or 1 target2["ContainerStroke"]["Color"]=Color3["fromRGB"](48, 64, 53)target2["ContainerStroke"]["Transparency"]=settings["ESPBackground"]and.24 or 1 target2["NameLabel"]["Size"]=UDim2["new"](1, 0, 1, 0)target2["NameLabel"]["Position"]=UDim2["new"](0, 0, 0, 0)target2["NameLabel"]["TextSize"]=isMobileDevice and 9 or 11
elseif espstyle=="Compact"then
target2["Billboard"]["Size"]=isMobileDevice and UDim2["new"](0, 80, 0, 16)or UDim2["new"](0, 100, 0, 20)target2["Container"]["Size"]=UDim2["new"](1, 0, 1, 0)target2["Container"]["BackgroundColor3"]=Color3["fromRGB"](8, 10, 9)target2["Container"]["BackgroundTransparency"]=settings["ESPBackground"]and.62 or 1 target2["ContainerStroke"]["Color"]=Color3["fromRGB"](48, 64, 53)target2["ContainerStroke"]["Transparency"]=settings["ESPBackground"]and.24 or 1 target2["NameLabel"]["Size"]=UDim2["new"](1, 0, 1, 0)target2["NameLabel"]["Position"]=UDim2["new"](0, 0, 0, 0)target2["NameLabel"]["TextSize"]=isMobileDevice and 8 or 10
elseif espstyle=="Minimal"then
target2["Billboard"]["Size"]=isMobileDevice and UDim2["new"](0, 42, 0, 16)or UDim2["new"](0, 52, 0, 20)target2["Container"]["Size"]=UDim2["new"](1, 0, 1, 0)target2["Container"]["BackgroundColor3"]=Color3["fromRGB"](8, 10, 9)target2["Container"]["BackgroundTransparency"]=settings["ESPBackground"]and.62 or 1 target2["ContainerStroke"]["Color"]=Color3["fromRGB"](48, 64, 53)target2["ContainerStroke"]["Transparency"]=settings["ESPBackground"]and.24 or 1 target2["NameLabel"]["Size"]=UDim2["new"](1, 0, 1, 0)target2["NameLabel"]["Position"]=UDim2["new"](0, 0, 0, 0)target2["NameLabel"]["TextSize"]=isMobileDevice and 8 or 10
end
end
if espstyle=="Aura Only"then
if target2["LastBillboardEnabled"]~=false then
target2["Billboard"]["Enabled"]=false target2["LastBillboardEnabled"]=false
end
else
if target2["LastBillboardEnabled"]~=true then
target2["Billboard"]["Enabled"]=true target2["LastBillboardEnabled"]=true
end
if target2["LastBillboardAdornee"]~=target3 then
target2["Billboard"]["Adornee"]=target3 target2["LastBillboardAdornee"]=target3
end
local displayText=""
if espstyle=="Old"or espstyle=="Standard"then
displayText=text["getText"](instance, text2)
elseif espstyle=="Compact"then
if value=="Generator"then
local progress=getGeneratorProgress(instance)
local progress2, currentValue4, currentValue5=getGeneratorAnalytics(instance)
local displayText2=""
if settings["GeneratorESP"]["ShowProgress"]then
displayText2=string["format"](" %d%%", progress)
if settings["GeneratorESP"]["ShowRepairSpeed"]and progress2>.05 then
displayText2=displayText2..string["format"](" (+%.1f%%/s)", progress2)
end
if settings["GeneratorESP"]["ShowETA"]and currentValue5~=""then
displayText2=displayText2..string["format"](" [%s]", currentValue5)
end
if settings["GeneratorESP"]["ShowRepairingCount"]then
local playersrepairingcount=instance:GetAttribute("PlayersRepairingCount")or 0 displayText2=displayText2..string["format"](" (%dp)", playersrepairingcount)
end
elseif settings["GeneratorESP"]["ShowRepairingCount"]then
local playersrepairingcount=instance:GetAttribute("PlayersRepairingCount")or 0 displayText2=string["format"](" (%dp)", playersrepairingcount)
end
local generatoresp=settings["GeneratorESP"]["NoText"]and""or"发电机"
if settings["GeneratorESP"]["ShowDistance"]then
if generatoresp==""then
displayText=string["format"]("[%dm]%s", text2, displayText2)
else
displayText=string["format"]("发电机 [%dm]%s", text2, displayText2)
end
else
displayText=generatoresp..displayText2
end
else
local conditionMet4=false
if value=="BloodEffect"then
conditionMet4=settings["BloodESP"]["NoText"]
elseif value=="SCP"then
conditionMet4=settings["SCPESP"]["NoText"]
else
local text3=settings[value.."ESP"]conditionMet4=text3 and text3["NoText"]
end
local displayText2=""
if not conditionMet4 then
if value=="SCP"then
displayText2=instance["Name"]:upper()
else
local items9={["Hook"]="钩子";
["Pallet"]="木板", ["Vault"]="翻越点";
["BloodEffect"]="血迹", ["Gate"]="大门"}displayText2=items9[value]or value
end
end
local conditionMet5=false
if value=="BloodEffect"then
conditionMet5=settings["BloodESP"]["ShowDistance"]
elseif value=="SCP"then
conditionMet5=settings["SCPESP"]["ShowDistance"]
else
local distance3=settings[value.."ESP"]conditionMet5=distance3 and distance3["ShowDistance"]
end
if conditionMet5 then
if displayText2==""then
displayText=string["format"]("[%dm]", text2)
else
displayText=string["format"]("%s [%dm]", displayText2, text2)
end
else
displayText=displayText2
end
end
elseif espstyle=="Minimal"then
if value=="Generator"then
local progress=getGeneratorProgress(instance)
local displayText2=""
if settings["GeneratorESP"]["ShowProgress"]then
displayText2=string["format"](" %d%%", progress)
if settings["GeneratorESP"]["ShowRepairingCount"]then
local playersrepairingcount=instance:GetAttribute("PlayersRepairingCount")or 0 displayText2=displayText2..string["format"](" (%dp)", playersrepairingcount)
end
elseif settings["GeneratorESP"]["ShowRepairingCount"]then
local playersrepairingcount=instance:GetAttribute("PlayersRepairingCount")or 0 displayText2=string["format"](" (%dp)", playersrepairingcount)
end
if settings["GeneratorESP"]["ShowDistance"]then
displayText=string["format"]("[%dm]%s", text2, displayText2)
else
local generatoresp=settings["GeneratorESP"]["NoText"]and""or"发电机"displayText=generatoresp..displayText2
end
else
local conditionMet4=false
if value=="BloodEffect"then
conditionMet4=settings["BloodESP"]["NoText"]
elseif value=="SCP"then
conditionMet4=settings["SCPESP"]["NoText"]
else
local text3=settings[value.."ESP"]conditionMet4=text3 and text3["NoText"]
end
local displayText2=""
if not conditionMet4 then
if value=="SCP"then
displayText2=(instance["Name"]:upper()):sub(1, 3)
else
local items9={["Hook"]="Hoo", ["Pallet"]="Pal", ["Vault"]="Vau", ["BloodEffect"]="Blo";
["Gate"]="Gat"}displayText2=items9[value]or value:sub(1, 3)
end
end
local conditionMet5=false
if value=="BloodEffect"then
conditionMet5=settings["BloodESP"]["ShowDistance"]
elseif value=="SCP"then
conditionMet5=settings["SCPESP"]["ShowDistance"]
else
local distance3=settings[value.."ESP"]conditionMet5=distance3 and distance3["ShowDistance"]
end
if conditionMet5 then
displayText=string["format"]("[%dm]", text2)
else
displayText=displayText2
end
end
end
if target2["LastText"]~=displayText then
target2["NameLabel"]["Text"]=displayText target2["LastText"]=displayText
end
if target2["NameLabel"]["TextColor3"]~=distance then
target2["NameLabel"]["TextColor3"]=distance
end
end
else
disableMapESPData(target2)
end
end
debug["profileend"]()
end
function manageHighlights()
local items8={}
for key, item in pairs(ActiveESP["Players"])do
if item["Highlight"]and item["LastAuraEnabled"]then
table["insert"](items8, {["data"]=item, ["priority"]=1, ["dist"]=getDistance(key, item["Billboard"]["Adornee"])})
end
end
local espEntries3={ActiveESP["SCPs"], ActiveESP["Generators"];
ActiveESP["Hooks"];
ActiveESP["Pallets"], ActiveESP["Vaults"], ActiveESP["BloodEffects"], ActiveESP["Gates"]}
for index, item in ipairs(espEntries3)do
local distance=4
if index==1 then
distance=2
elseif index==2 or index==7 then
distance=3
end
for key, item2 in pairs(item)do
if item2["Highlight"]and item2["LastAuraEnabled"]then
table["insert"](items8, {["data"]=item2, ["priority"]=distance;
["dist"]=getDistance(key, item2["LastBillboardAdornee"])})
end
end
end
table["sort"](items8, function(value, contextValue)
if value["priority"]~=contextValue["priority"]then
return value["priority"]<contextValue["priority"]
end
return value["dist"]<contextValue["dist"]
end
)
local numericValue=28
for index, item in ipairs(items8)do
local isEnabled=(index<=numericValue)
if item["data"]["Highlight"]:IsA("Highlight")then
if item["data"]["Highlight"]["Enabled"]~=isEnabled then
item["data"]["Highlight"]["Enabled"]=isEnabled
end
elseif item["data"]["Highlight"]:IsA("BoxHandleAdornment")then
if item["data"]["Highlight"]["Visible"]~=isEnabled then
item["data"]["Highlight"]["Visible"]=isEnabled
end
end
end
end
function cleanupAll()pcall(function()RunService:UnbindFromRenderStep("BlatantAimbotLock")
end
)
if aimTarget then
pcall(function()aimTarget:Remove()
end
)
end
if silentAimTarget then
pcall(function()silentAimTarget:Destroy()
end
)
end
if parryTarget then
pcall(function()parryTarget:Destroy()
end
)parryTarget=nil
end
for key, item in pairs(ActiveESP["Players"])do
removePlayerESP(key)
end
for key, item in pairs(ActiveESP["Generators"])do
removeModelESP(key, "Generator")
end
for key, item in pairs(ActiveESP["SCPs"])do
removeModelESP(key, "SCP")
end
for key, item in pairs(ActiveESP["Hooks"])do
removeModelESP(key, "Hook")
end
for key, item in pairs(ActiveESP["Pallets"])do
removeModelESP(key, "Pallet")
end
for key, item in pairs(ActiveESP["Vaults"])do
removeModelESP(key, "Vault")
end
for key, item in pairs(ActiveESP["BloodEffects"])do
removeModelESP(key, "BloodEffect")
end
for key, item in pairs(ActiveESP["Gates"])do
removeModelESP(key, "Gate")
end
pcall(function()
local instance=localPlayer:FindFirstChildOfClass("PlayerGui")
local instance2=instance and instance:FindFirstChild("Survivor")
local instance3=instance2 and instance2:FindFirstChild("Gen")
local instance4=instance3 and instance3:FindFirstChild("ItemFrame")
if instance4 then
local instance5=instance4:FindFirstChild("Gui")
if instance5 then
local parrycooldownlabel=instance5:FindFirstChild("ParryCooldownLabel")
if parrycooldownlabel then
parrycooldownlabel:Destroy()
end
end
local parrycooldownlabel=instance4:FindFirstChild("ParryCooldownLabel")
if parrycooldownlabel then
parrycooldownlabel:Destroy()
end
end
local instance5=instance and instance:FindFirstChild("Survivor-mob")
local instance6=instance5 and instance5:FindFirstChild("Controls")
if instance6 then
local parrycooldownlabel=instance6:FindFirstChild("ParryCooldownLabel")
if parrycooldownlabel then
parrycooldownlabel:Destroy()
end
local instance7=instance6:FindFirstChild("action")
local parrycooldownlabel2=instance7 and instance7:FindFirstChild("ParryCooldownLabel")
if parrycooldownlabel2 then
parrycooldownlabel2:Destroy()
end
end
if spearConnection then
pcall(function()spearConnection:Destroy()
end
)spearConnection=nil
end
pcall(function()
if _G["VD_SpearSilentAimFOVCircle"]then
pcall(function()_G["VD_SpearSilentAimFOVCircle"]["Visible"]=false
end
)pcall(function()_G["VD_SpearSilentAimFOVCircle"]:Remove()
end
)_G["VD_SpearSilentAimFOVCircle"]=nil
end
end
)pcall(function()
if _G["VD_RevolverSilentAimFOVCircle"]then
pcall(function()_G["VD_RevolverSilentAimFOVCircle"]["Visible"]=false
end
)pcall(function()_G["VD_RevolverSilentAimFOVCircle"]:Remove()
end
)_G["VD_RevolverSilentAimFOVCircle"]=nil
end
end
)pcall(function()
if aimConnection then
pcall(function()aimConnection:Destroy()
end
)aimConnection=nil
end
end
)
end
)
end


--// UI 层：主题、组件与窗口交互

UI={["Bg"]=Color3["fromRGB"](8, 9, 9);
["Sidebar"]=Color3["fromRGB"](11, 12, 12), ["Card"]=Color3["fromRGB"](18, 20, 19), ["Elevated"]=Color3["fromRGB"](24, 27, 25), ["HoverCard"]=Color3["fromRGB"](31, 35, 32);
["Accent"]=Color3["fromRGB"](76, 220, 118), ["AccentCyan"]=Color3["fromRGB"](112, 225, 145), ["AccentGreen"]=Color3["fromRGB"](76, 220, 118), ["AccentRed"]=Color3["fromRGB"](230, 84, 84);
["Stroke"]=Color3["fromRGB"](48, 55, 51), ["StrokeDim"]=Color3["fromRGB"](31, 36, 33), ["Text"]=Color3["fromRGB"](226, 233, 228), ["TextSub"]=Color3["fromRGB"](145, 166, 153), ["Muted"]=Color3["fromRGB"](91, 105, 97);
["Danger"]=Color3["fromRGB"](230, 84, 84), ["Success"]=Color3["fromRGB"](76, 220, 118), ["Warning"]=Color3["fromRGB"](214, 169, 78), ["Radius"]=5, ["CardRadius"]=4;
["MainW"]=isMobileDevice and 520 or 760, ["MainH"]=isMobileDevice and 350 or 500, ["TitleH"]=40}
screenGui=nil mainFrame=nil sidebarScroll=nil contentFolder=nil currentEmoteTrack=nil currentEmoteSound=nil tabHome, tabESP, tabFarm, tabSelf, tabCombat, tabTP, tabVisuals, tabConfig, updateVisuals=nil, nil, nil, nil, nil, nil, nil, nil, nil
themes={["Default"]={["Bg"]=UI["Bg"], ["Sidebar"]=UI["Sidebar"], ["Card"]=UI["Card"], ["Elevated"]=UI["Elevated"], ["Stroke"]=UI["Stroke"], ["StrokeDim"]=UI["StrokeDim"], ["Accent"]=UI["Accent"], ["AccentCyan"]=UI["AccentCyan"], ["AccentGreen"]=UI["AccentGreen"], ["AccentRed"]=UI["AccentRed"], ["BgTrans"]=.16, ["CardTrans"]=.42, ["CardHoverTrans"]=.28, ["BorderGradEnabled"]=false}}
currentThemeName="Default"mobileFloatingButtons={}
local UI_TEXT={
["Master Controls"]="总控",
["Master ESP Switch"]="ESP 总开关",
["Players ESP"]="玩家 ESP",
["Killer Track"]="杀手追踪",
["Highlight Aura"]="轮廓高亮",
["Show Distance"]="显示距离",
["Show Selected Killer Info"]="显示杀手信息",
["Show Player Name"]="显示玩家名称",
["Survivor Track"]="幸存者追踪",
["Show Health States"]="显示生命状态",
["Show Hook Count"]="显示上钩次数",
["Censor Player Names"]="隐藏玩家名称",
["Map Elements"]="地图元素",
["View Generators"]="显示发电机",
["Alert Progress Threshold %"]="进度警戒阈值 %",
["Completion Sound Asset ID"]="完成音效资源 ID",
["Completion Sound Volume"]="完成音效音量",
["View Hooks"]="显示钩子",
["View Pallets"]="显示木板",
["View Vaults"]="显示翻越点",
["View Gates"]="显示大门",
["View Blood Effects"]="显示血迹",
["Esp Zombies SCP"]="显示感染者 / SCP",
["Aura & Display Settings"]="ESP 显示设置",
["ESP Background Card"]="ESP 半透明底板",
["ESP Style"]="ESP 风格",
["ESP Range Limit"]="ESP 距离上限",
["Distance Based Opacity"]="按距离淡出",
["Fade Start Distance (m)"]="开始淡出距离（米）",
["Full Transparent Distance (m)"]="完全透明距离（米）",
["ESP Tracers"]="ESP 引导线",
["Tracer Target"]="引导线目标",
["Tracer Style"]="引导线样式",
["Tracer Origin"]="引导线起点",
["Tracer Color Mode"]="引导线颜色",
["Radar Minimap"]="雷达小地图",
["ESP Colors Customizer"]="ESP 颜色",
["Select Element"]="选择元素",
["Color Wheel"]="颜色",
["Autofarm Controls"]="自动农场",
["Generator Automations"]="发电机自动化",
["Auto Skill Check"]="自动技能检定",
["Instant Skill Check"]="瞬时技能检定",
["Skill Check Mode"]="技能检定模式",
["Perfect Hit Rate (%)"]="完美命中率（%）",
["Skill Check Speed"]="技能检定速度",
["No Skill Checks (Remove Checks)"]="移除技能检定",
["Killer Automations"]="杀手自动化",
["Telemetry & State"]="运行状态",
["Speed Customizations"]="速度设置",
["Modifiers Active For"]="修改器生效阵营",
["Vault Speed Factor"]="翻越速度倍率",
["Speed Boost Enabled"]="启用速度增强",
["Speed Boost Multiplier"]="速度增强倍率",
["Count Speed Perks / Slow Downs"]="计算速度增益 / 减速",
["Character Perks"]="角色能力",
["Perk Loadout Manager"]="能力预设管理",
["Refresh Available Perks"]="刷新可用能力",
["New Loadout Name"]="新预设名称",
["Save Current Selection"]="保存当前选择",
["Equip/Load Selected Loadout"]="加载所选预设",
["Delete Selected Loadout"]="删除所选预设",
["Force-Enable Flowstate Perk"]="强制启用 Flowstate",
["Flowstate Cooldown (s)"]="Flowstate 冷却（秒）",
["Hide Flowstate UI"]="隐藏 Flowstate 界面",
["Instant Heal"]="瞬间治疗",
["Instant Bandage"]="立即包扎",
["Noclip Vaults & Pallets"]="穿过翻越点和木板",
["Auto Flee Killer (Dist &lt; 35)"]="自动远离杀手（距离 < 35）",
["Auto Moonwalk"]="自动月步",
["Reverse Moonwalk"]="反向月步",
["Movement-Based Moonwalk"]="按移动方向月步",
["Disable Moonwalk Near Vaults"]="靠近翻越点时关闭月步",
["Moonwalk Sway Speed"]="月步摆动速度",
["Moonwalk Sway Size"]="月步摆动幅度",
["Moonwalk Jitter/Shaking"]="月步抖动",
["Rainbow Character"]="彩虹角色",
["Rainbow Mode"]="彩虹模式",
["Pallet & Vault Modifiers"]="木板与翻越修改",
["Always Fast Vault"]="始终快速翻越",
["Drop All Pallets"]="放下全部木板",
["Remote Drop Pallet"]="远程放板",
["Drop Target Pallet"]="放下目标木板",
["Block Vaults"]="锁定翻越点",
["Block Pallets"]="锁定木板",
["Unlock Vaults"]="解锁翻越点",
["Unlock Pallets"]="解锁木板",
["Stat Modifiers"]="属性修改",
["Animation Player"]="动画播放器",
["Walk While Emoting"]="播放动作时允许移动",
["Stop Animation"]="停止动画",
["Combat Automations"]="战斗自动化",
["Use Item Activation (Legit)"]="使用物品激活（自然）",
["Parry Range Limit"]="格挡距离上限",
["Parry Reaction Delay"]="格挡反应延迟",
["Directional Facing Check"]="方向朝向检测",
["Ping Compensation"]="延迟补偿",
["Visual Parry Range Circle (ESP)"]="显示格挡范围",
["Ignore Frenzy Killer"]="忽略 Frenzy 杀手",
["Ignore Abysswalker Lunge"]="忽略深渊行者突进",
["Simulate Parry Animation"]="模拟格挡动画",
["Hide Parry Cooldown UI"]="隐藏格挡冷却界面",
["List Active/Learned Animations"]="列出已识别攻击动画",
["General Aimbot"]="通用自瞄",
["Enable Aimbot"]="启用自瞄",
["Activation Mode"]="激活模式",
["Activation Key"]="激活按键",
["Target Body Part"]="目标部位",
["Aim Smoothness"]="瞄准平滑度",
["FOV Circle Radius"]="视野圈半径",
["Draw FOV Circle"]="显示视野圈",
["Target Filter"]="目标筛选",
["Movement Prediction"]="移动预测",
["Revolver Autofarm"]="左轮自动农场",
["Enable Revolver Autofarm [BETA]"]="启用左轮自动农场 [测试]",
["Enable Revolver Aimbot [BETA]"]="启用左轮自瞄 [测试]",
["Show FOV Circle"]="显示视野圈",
["Show Crosshair Overlay"]="显示准星",
["Crosshair Style"]="准星样式",
["Aimbot Activation Key"]="自瞄激活按键",
["Aimbot Target Part"]="自瞄目标部位",
["Aimbot Smoothness"]="自瞄平滑度",
["Aimbot FOV Radius"]="自瞄视野半径",
["Offset X (Horizontal Calibration)"]="水平校准 X",
["Offset Y (Vertical Calibration)"]="垂直校准 Y",
["Enable Aimbot Prediction"]="启用自瞄预测",
["Bullet Velocity"]="子弹速度",
["Revolver Silent Aim"]="左轮静默瞄准",
["FOV Radius"]="视野半径",
["FOV Circle Color"]="视野圈颜色",
["Target Mode"]="目标模式",
["Highlight Targeted Player"]="高亮当前目标",
["Highlight Color"]="高亮颜色",
["Killers"]="杀手",
["VEIL"]="VEIL",
["Veil Spear Trajectory"]="VEIL 长矛轨迹",
["Trajectory Noclip"]="轨迹穿墙",
["Trajectory Color"]="轨迹颜色",
["Enable Veil Spear Aimbot"]="启用 VEIL 长矛自瞄",
["Prediction Latency Offset"]="预测延迟修正",
["Spear Silent Aim"]="长矛静默瞄准",
["MASKED "]="蒙面者",
["STALKER"]="潜行者",
["No Cooldown Stalker"]="潜行者无冷却",
["Kill Grab"]="抓取即击杀",
["Stalk While Moving"]="移动时保持潜行",
["Stalk Everyone (once)"]="对所有人执行一次潜行",
["ABYSSWALKER"]="深渊行者",
["Infinite Corrupt"]="无限腐化",
["Auto Dodge"]="自动躲避",
["Auto Crouch Distance (studs)"]="自动蹲伏距离（stud）",
["Modifiers"]="修改器",
["No Stun (Killer)"]="杀手免眩晕",
["TP To Nearest Generator"]="传送到最近发电机",
["TP To Nearest Hook"]="传送到最近钩子",
["TP To Nearest Gate"]="传送到最近大门",
["TP To Nearest Pallet"]="传送到最近木板",
["TP To Nearest Vault"]="传送到最近翻越点",
["TP To Nearest Survivor"]="传送到最近幸存者",
["TP To Killer"]="传送到杀手",
["TP To Furthest Generator"]="传送到最远发电机",
["TP To Furthest Hook"]="传送到最远钩子",
["TP To Furthest Gate"]="传送到最远大门",
["TP To Furthest Pallet"]="传送到最远木板",
["TP To Furthest Vault"]="传送到最远翻越点",
["TP To Furthest Survivor"]="传送到最远幸存者",
["Quick Map Teleports"]="地图快捷传送",
["Cinematic Visuals"]="画面增强",
["RTX Graphics Booster"]="RTX 画面增强",
["Cinematic Depth of Field"]="景深效果",
["Color Tint Preset"]="色调预设",
["Atmosphere Density"]="雾化密度",
["Custom Background 🖼️"]="自定义背景",
["Custom Background"]="自定义背景",
["Browse Local Images"]="浏览本地图片",
["Local File Name"]="本地文件名",
["Roblox Asset ID"]="Roblox 资源 ID",
["Background Overlay %"]="背景遮罩 %",
["Scale Mode"]="缩放模式",
["Lighting & Visibility"]="光照与可见性",
["Field of View"]="视野范围",
["Stretched Resolution"]="拉伸分辨率",
["No Fog"]="移除雾效",
["Full Bright"]="全亮",
["Killer Third Person"]="杀手第三人称",
["Infinite Zoom"]="无限缩放",
["Network Manipulation"]="网络效果",
["Fake Lag"]="假延迟",
["Lag Amount (ms)"]="延迟量（毫秒）",
["Show Position Ghost"]="显示位置残影",
["Network Desync"]="网络不同步",
["Show Visual Ghost"]="显示视觉残影",
["Ghost Always On Top (Behind Walls)"]="残影始终可见（穿墙）",
["Ghost Transparency"]="残影透明度",
["Ghost Color"]="残影颜色",
["No Flashlight Blind"]="免疫手电致盲",
["Crosshair Settings"]="准星设置",
["Show Custom Crosshair"]="显示自定义准星",
["Crosshair Size"]="准星大小",
["Crosshair Color"]="准星颜色",
["Visuals Customizer"]="视觉自定义",
["Flashlight"]="手电筒",
["Flashlight Effect"]="手电效果",
["Flashlight Color"]="手电颜色",
["Killer Stain Color"]="杀手红光颜色",
["HUD Customizer"]="HUD 设置",
["Live Players List"]="存活玩家列表",
["Custom Overlay Asset ID"]="自定义覆盖层资源 ID",
["Refresh"]="刷新",
["Save"]="保存",
["Load"]="加载",
["Delete"]="删除",
["Use"]="使用",
["Drop"]="放下",
["Block"]="锁定",
["Unlock"]="解锁",
["Stop"]="停止",
["Trigger"]="触发",
["Print"]="输出",
["Run"]="执行",
["TP"]="传送",
["PLAY"]="播放",
["▶ PLAY"]="播放",
["Old"]="旧版",
["Standard"]="标准",
["Compact"]="紧凑",
["Minimal"]="极简",
["Aura Only"]="仅轮廓",
["Both"]="两者",
["Killers Only"]="仅杀手",
["Survivors Only"]="仅幸存者",
["Line"]="直线",
["Arrow"]="箭头",
["Bottom"]="底部",
["Center"]="中心",
["Top"]="顶部",
["Role Color"]="角色颜色",
["Custom"]="自定义",
["Perfect"]="完美",
["Normal"]="普通",
["Hybrid"]="混合",
["Both Teams"]="双方",
["Survivors"]="幸存者",
["Survivor"]="幸存者",
["Killer"]="杀手",
["Killer Only"]="仅杀手",
["Medium"]="中等",
["Fast"]="快速",
["Highlight"]="轮廓",
["Body Parts"]="身体部件",
["ForceField"]="力场",
["Instant"]="瞬时",
["50ms"]="50 毫秒",
["100ms"]="100 毫秒",
["150ms"]="150 毫秒",
["200ms"]="200 毫秒",
["250ms"]="250 毫秒",
["300ms"]="300 毫秒",
["Hold Key"]="按住按键",
["Toggle On/Off"]="切换开关",
["Right Mouse (M2)"]="鼠标右键（M2）",
["Left Mouse (M1)"]="鼠标左键（M1）",
["E Key"]="E 键",
["Q Key"]="Q 键",
["Shift Key"]="Shift 键",
["🎮 Controller LT (L2)"]="手柄 LT（L2）",
["🎮 Controller RT (R2)"]="手柄 RT（R2）",
["🎮 Controller LB (L1)"]="手柄 LB（L1）",
["🎮 Controller RB (R1)"]="手柄 RB（R1）",
["🎮 Controller L3"]="手柄 L3",
["🎮 Controller R3"]="手柄 R3",
["Head"]="头部",
["Torso"]="躯干",
["HumanoidRootPart"]="根部",
["RootPart"]="根部",
["Ultra Smooth (Legit)"]="超平滑（自然）",
["Smooth (Balanced)"]="平滑（均衡）",
["Smooth"]="平滑",
["Very Smooth"]="非常平滑",
["Instant (Rage)"]="瞬时",
["Classic"]="经典",
["Dot"]="点",
["Circle"]="圆",
["Dot & Circle"]="点 + 圆",
["Tactical"]="战术",
["Right Mouse"]="鼠标右键",
["Left Mouse"]="鼠标左键",
["Cyan"]="青色",
["Red"]="红色",
["Green"]="绿色",
["Yellow"]="黄色",
["Purple"]="紫色",
["Orange"]="橙色",
["Pink"]="粉色",
["White"]="白色",
["Blue"]="蓝色",
["Accent"]="主题绿",
["Default"]="默认",
["Warm"]="暖色",
["Cold"]="冷色",
["Crop"]="裁切",
["Stretch"]="拉伸",
["Fit"]="适应",
["None"]="无",
["Rainbow"]="彩虹",
["Strobe"]="频闪",
["Ultra Bright"]="超亮",
["Hide"]="隐藏",
["Overlay (Logo)"]="覆盖（Logo）",
["Overlay (Custom)"]="覆盖（自定义）",
["Generator"]="发电机",
["Hook"]="钩子",
["Pallet"]="木板",
["Vault"]="翻越点",
["Gate"]="大门",
["Blood"]="血迹",
["BloodEffect"]="血迹",
["SCP"]="感染者",
["Healthy"]="健康",
["Healed"]="健康",
["Injured"]="受伤",
["Knocked"]="倒地",
["Hooked"]="上钩",
["Feature"]="功能",
["Feature unavailable."]="功能不可用。",
["Speed Boost"]="速度增强",
["Enabled"]="已开启",
["Disabled"]="已关闭",
["ENABLED"]="已开启",
["DISABLED"]="已关闭",
["UI Closed"]="界面已隐藏",
}
translateText=function(text)
if type(text)~="string" then return text end
return UI_TEXT[text] or text
end
function applyTheme(themeName)currentThemeName=themeName or"Default"
local name2=themes[currentThemeName]or themes["Default"]
local bgColor=UI["Bg"]
local sidebarColor=UI["Sidebar"]
local cardColor=UI["Card"]
local elevatedColor=UI["Elevated"]
local strokeColor=UI["Stroke"]
local strokedimColor=UI["StrokeDim"]
local accentColor=UI["Accent"]
local accentcyanColor=UI["AccentCyan"]
local accentgreenColor=UI["AccentGreen"]
local accentredColor=UI["AccentRed"]UI["Bg"]=name2["Bg"]UI["Sidebar"]=name2["Sidebar"]UI["Card"]=name2["Card"]UI["Elevated"]=name2["Elevated"]UI["Stroke"]=name2["Stroke"]UI["StrokeDim"]=name2["StrokeDim"]UI["Accent"]=name2["Accent"]UI["AccentCyan"]=name2["AccentCyan"]UI["AccentGreen"]=name2["AccentGreen"]UI["AccentRed"]=name2["AccentRed"]
if not mainFrame then
return
end
mainFrame["BackgroundColor3"]=UI["Bg"]mainFrame["BackgroundTransparency"]=name2["BgTrans"]
local child=mainFrame:FindFirstChildOfClass("UIStroke")
if child then
child["Color"]=UI["Stroke"]child["Thickness"]=(currentThemeName=="Default")and 1.2 or 1
end
local instance=mainFrame:FindFirstChild("Sidebar")
if instance then
instance["BackgroundColor3"]=UI["Sidebar"]
local custombackground=settings["CustomBackground"]and(settings["CustomBackground"]["Enabled"]and(isFeatureAvailable()and(featureAvailability and featureAvailability["CustomBackground"])))instance["BackgroundTransparency"]=custombackground and.85 or name2["BgTrans"]
local child2=instance:FindFirstChildOfClass("UIStroke")
if child2 then
child2["Color"]=UI["StrokeDim"]
end
end
for index, instance2 in ipairs(screenGui:GetDescendants())do
if instance2:IsA("GuiObject")then
if instance2["BackgroundColor3"]==bgColor then
instance2["BackgroundColor3"]=UI["Bg"]
elseif instance2["BackgroundColor3"]==sidebarColor then
instance2["BackgroundColor3"]=UI["Sidebar"]
elseif instance2["BackgroundColor3"]==cardColor then
instance2["BackgroundColor3"]=UI["Card"]
elseif instance2["BackgroundColor3"]==elevatedColor then
instance2["BackgroundColor3"]=UI["Elevated"]
elseif instance2["BackgroundColor3"]==accentColor then
instance2["BackgroundColor3"]=UI["Accent"]
elseif instance2["BackgroundColor3"]==accentcyanColor then
instance2["BackgroundColor3"]=UI["AccentCyan"]
elseif instance2["BackgroundColor3"]==accentgreenColor then
instance2["BackgroundColor3"]=UI["AccentGreen"]
elseif instance2["BackgroundColor3"]==accentredColor then
instance2["BackgroundColor3"]=UI["AccentRed"]
elseif instance2["BackgroundColor3"]==strokeColor then
instance2["BackgroundColor3"]=UI["Stroke"]
elseif instance2["BackgroundColor3"]==strokedimColor then
instance2["BackgroundColor3"]=UI["StrokeDim"]
end
if instance2:IsA("ImageLabel")or instance2:IsA("ImageButton")then
if instance2["ImageColor3"]==accentColor then
instance2["ImageColor3"]=UI["Accent"]
elseif instance2["ImageColor3"]==accentcyanColor then
instance2["ImageColor3"]=UI["AccentCyan"]
elseif instance2["ImageColor3"]==strokeColor then
instance2["ImageColor3"]=UI["Stroke"]
elseif instance2["ImageColor3"]==strokedimColor then
instance2["ImageColor3"]=UI["StrokeDim"]
end
end
if instance2:IsA("TextLabel")or instance2:IsA("TextBox")or instance2:IsA("TextButton")then
if instance2["TextColor3"]==accentColor then
instance2["TextColor3"]=UI["Accent"]
elseif instance2["TextColor3"]==accentcyanColor then
instance2["TextColor3"]=UI["AccentCyan"]
elseif instance2["TextColor3"]==accentgreenColor then
instance2["TextColor3"]=UI["AccentGreen"]
elseif instance2["TextColor3"]==strokeColor then
instance2["TextColor3"]=UI["Stroke"]
end
end
local child2=instance2:FindFirstChildOfClass("UIStroke")
if child2 then
if child2["Color"]==strokeColor then
child2["Color"]=UI["Stroke"]
elseif child2["Color"]==strokedimColor then
child2["Color"]=UI["StrokeDim"]
elseif child2["Color"]==accentColor then
child2["Color"]=UI["Accent"]
end
end
if instance2["Name"]=="SectionLine"then
instance2["BackgroundColor3"]=UI["StrokeDim"]
end
end
end
if screenGui then
local instance2=screenGui:FindFirstChild("InfoBannerFrame", true)
if instance2 then
local child2=instance2:FindFirstChildOfClass("UIStroke")
if child2 then
child2["Color"]=UI["Accent"]
end
end
end
if mainFrame then
local topaccentbar=mainFrame:FindFirstChild("TopAccentBar")
if topaccentbar then
local topbarcolor=settings["TopBarColor"]
if topbarcolor and(type(topbarcolor)=="table"and topbarcolor["r"])then
topaccentbar["BackgroundColor3"]=Color3["new"](topbarcolor["r"], topbarcolor["g"], topbarcolor["b"])
else
topaccentbar["BackgroundColor3"]=UI["Accent"]
end
end
end
if applyCustomBackground then
pcall(applyCustomBackground)
end
end
local items8={}
local function conditionMet3(value)
if not value or value==""then
return nil
end
local normalizedText=((tostring(value)):lower()):gsub("%s+", "")
if normalizedText=="togglespeedboost"or normalizedText=="speedboost"then
return settings["SpeedBoostEnabled"]==true
elseif normalizedText=="automoonwalk"or normalizedText=="moonwalk"then
return settings["AutoMoonwalk"]==true
elseif normalizedText=="noclipvaultspallets"or normalizedText=="noclip"then
return settings["NoclipVaultsPallets"]==true
elseif normalizedText=="autofleekiller"or normalizedText=="autoflee"then
return settings["AutoFleeKiller"]==true
elseif normalizedText=="alwaysfastvault"or normalizedText=="fastvault"then
return settings["AlwaysFastVault"]==true
elseif normalizedText=="instantheal"then
return settings["InstantHeal"]==true
elseif normalizedText=="autoparry"or normalizedText=="frenzyparry"then
return settings["FrenzyParry"]==true
elseif normalizedText=="revolverautofarm"then
return settings["RevolverAutofarm"]==true
elseif normalizedText=="revolveraimbot"or normalizedText=="aimbot"then
return((settings["RevolverAimbot"]and settings["RevolverAimbot"]["Enabled"]))==true
elseif normalizedText=="flowstateperk"or normalizedText=="flowstate"then
return settings["FlowstatePerk"]==true
elseif normalizedText=="activefeaturesoverlay"or normalizedText=="activefeatures"then
return settings["ShowActiveFeatures"]==true
elseif normalizedText=="nofog"then
return settings["NoFog"]==true
elseif normalizedText=="fullbright"then
return settings["FullBright"]==true
elseif normalizedText=="noskillchecks"then
return settings["NoSkillChecks"]==true
elseif normalizedText=="rainbowcharacter"or normalizedText=="rainbow"then
return settings["RainbowCharacter"]==true
elseif normalizedText=="fakelag"then
return settings["FakeLag"]==true
elseif normalizedText=="desync"then
return settings["Desync"]==true
elseif normalizedText=="blockvaultpalletinteraction"or normalizedText=="blockvaults"or normalizedText=="blockpallets"then
return settings["BlockVaultPalletInteraction"]==true
elseif settings[value]~=nil and type(settings[value])=="boolean"then
return settings[value]==true
end
for key, item in pairs(settings)do
if type(item)=="boolean"then
local normalizedText2=(key:lower()):gsub("%s+", "")
if normalizedText2==normalizedText then
return item==true
end
end
end
return nil
end
function createOrUpdateMobileFloatingButton(actionName, binding)
if not isMobileDevice then
return
end
local instance=guiParent or localPlayer:FindFirstChildOfClass("PlayerGui")
if not instance then
return
end
local vdMobilehud=instance:FindFirstChild("VD_MobileHUD")
if not vdMobilehud or not vdMobilehud["Parent"]then
if vdMobilehud then
pcall(function()vdMobilehud:Destroy()
end
)
end
vdMobilehud=Instance["new"]("ScreenGui")vdMobilehud["Name"]="VD_MobileHUD"vdMobilehud["ResetOnSpawn"]=false vdMobilehud["ZIndexBehavior"]=Enum["ZIndexBehavior"]["Sibling"]vdMobilehud["DisplayOrder"]=99997 pcall(function()vdMobilehud["IgnoreGuiInset"]=true
end
)vdMobilehud["Parent"]=instance
end
local button=mobileFloatingButtons[actionName]
local button2=items8[actionName]
if not button2 and(settings["MobileButtonPositions"]and settings["MobileButtonPositions"][actionName])then
local mobilebuttonpositions=settings["MobileButtonPositions"][actionName]
if mobilebuttonpositions and(mobilebuttonpositions["XScale"]and mobilebuttonpositions["YScale"])then
button2=UDim2["new"](mobilebuttonpositions["XScale"], mobilebuttonpositions["XOffset"]or 0, mobilebuttonpositions["YScale"], mobilebuttonpositions["YOffset"]or 0)items8[actionName]=button2
end
end
if not button2 then
local numericValue=0
for key in pairs(mobileFloatingButtons)do
numericValue=numericValue+1
end
local currentValue=.22+(numericValue*.12)
if currentValue>.75 then
currentValue=.22
end
button2=UDim2["new"](.85, -20, currentValue, 0)
end
local currentValue=conditionMet3(actionName)
local bgColor=UI["Bg"]
local text=.25
local accentColor=UI["Accent"]
local strokeColor=UI["Stroke"]
local numericValue=1.2
if currentValue==true then
bgColor=Color3["fromRGB"](18, 48, 28)text=.2 accentColor=Color3["fromRGB"](74, 222, 128)strokeColor=Color3["fromRGB"](34, 197, 94)numericValue=1.6
elseif currentValue==false then
bgColor=Color3["fromRGB"](42, 16, 20)text=.35 accentColor=Color3["fromRGB"](248, 113, 113)strokeColor=Color3["fromRGB"](225, 29, 72)numericValue=1.2
end
local label=button
if not label or not label["Parent"]then
label=Instance["new"]("TextButton")label["Name"]="MobileFloating_"..actionName label["Size"]=UDim2["new"](0, 42, 0, 42)label["Position"]=button2 label["ZIndex"]=998 label["Parent"]=vdMobilehud;
(Instance["new"]("UICorner", label))["CornerRadius"]=UDim["new"](.5, 0)
local stroke=Instance["new"]("UIStroke", label)stroke["Thickness"]=numericValue
local distance, currentValue2=nil, nil
local conditionMet4=false
local connection=nil registerConnection(label["InputBegan"]:Connect(function(input)
if input["UserInputType"]==Enum["UserInputType"]["Touch"]or input["UserInputType"]==Enum["UserInputType"]["MouseButton1"]then
distance=input["Position"]currentValue2=label["Position"]conditionMet4=false
local connection2 connection2=input["Changed"]:Connect(function()
if input["UserInputState"]==Enum["UserInputState"]["End"]then
distance=nil connection=nil
if connection2 then
connection2:Disconnect()
end
if conditionMet4 then
items8[actionName]=label["Position"]
if not settings["MobileButtonPositions"]then
settings["MobileButtonPositions"]={}
end
settings["MobileButtonPositions"][actionName]={["XScale"]=label["Position"]["X"]["Scale"], ["XOffset"]=label["Position"]["X"]["Offset"];
["YScale"]=label["Position"]["Y"]["Scale"];
["YOffset"]=label["Position"]["Y"]["Offset"]}pcall(saveSettings)
else
local tween=actionHandlers[actionName]
if tween then
(TweenService:Create(label, TweenInfo["new"](.1), {["Size"]=UDim2["new"](0, 38, 0, 38)})):Play()task["delay"](.1, function()
if label and label["Parent"]then
(TweenService:Create(label, TweenInfo["new"](.1), {["Size"]=UDim2["new"](0, 42, 0, 42)})):Play()
end
end
)tween()task["delay"](.05, function()
if refreshMobileFloatingButtons then
pcall(refreshMobileFloatingButtons)
end
end
)
end
end
end
end
)
end
end
))registerConnection(label["InputChanged"]:Connect(function(input)
if input["UserInputType"]==Enum["UserInputType"]["Touch"]or input["UserInputType"]==Enum["UserInputType"]["MouseMovement"]then
connection=input
end
end
))registerConnection(UserInputService["InputChanged"]:Connect(function(position)
if position==connection and distance then
local distance2=position["Position"]-distance
if distance2["Magnitude"]>5 then
conditionMet4=true
end
label["Position"]=UDim2["new"](currentValue2["X"]["Scale"], currentValue2["X"]["Offset"]+distance2["X"], currentValue2["Y"]["Scale"], currentValue2["Y"]["Offset"]+distance2["Y"])
end
end
))mobileFloatingButtons[actionName]=label
end
label["Text"]=binding:upper()label["BackgroundColor3"]=bgColor label["BackgroundTransparency"]=text label["TextColor3"]=accentColor
local child=label:FindFirstChildOfClass("UIStroke")
if child then
child["Color"]=strokeColor child["Thickness"]=numericValue
end
end
function showMobileKeybindPrompt(actionName, callback)
if not mainFrame then
return
end
local button=Instance["new"]("TextButton")button["Size"]=UDim2["new"](1, 0, 1, 0)button["BackgroundColor3"]=Color3["fromRGB"](0, 0, 0)button["BackgroundTransparency"]=1 button["Text"]=""button["AutoButtonColor"]=false button["BorderSizePixel"]=0 button["ZIndex"]=9999 button["Parent"]=mainFrame:FindFirstChildOfClass("ScreenGui")or mainFrame["Parent"];
(Instance["new"]("UICorner", button))["CornerRadius"]=UDim["new"](0, UI["Radius"])
local frame=Instance["new"]("Frame")frame["Size"]=UDim2["new"](0, 240, 0, 140)frame["Position"]=UDim2["new"](.5, 0, .5, 0)frame["AnchorPoint"]=Vector2["new"](.5, .5)frame["BackgroundColor3"]=UI["Card"]frame["BorderSizePixel"]=0 frame["Parent"]=button;
(Instance["new"]("UICorner", frame))["CornerRadius"]=UDim["new"](0, UI["CardRadius"])
local stroke=Instance["new"]("UIStroke", frame)stroke["Color"]=UI["Accent"]stroke["Thickness"]=1.2 stroke["Transparency"]=.2
local label=Instance["new"]("TextLabel")label["Size"]=UDim2["new"](1, 0, 0, 26)label["Position"]=UDim2["new"](0, 0, 0, 10)label["BackgroundTransparency"]=1 label["Text"]="移动端按钮设置"label["TextColor3"]=UI["Accent"]label["Font"]=Enum["Font"]["GothamBold"]label["TextSize"]=13 label["Parent"]=frame
local label2=Instance["new"]("TextLabel")label2["Size"]=UDim2["new"](1, -24, 0, 32)label2["Position"]=UDim2["new"](0, 12, 0, 32)label2["BackgroundTransparency"]=1 label2["Text"]="输入 1-6 个字符作为悬浮按钮名称；留空则删除该按钮。"label2["TextColor3"]=UI["TextSub"]label2["Font"]=Enum["Font"]["GothamMedium"]label2["TextSize"]=10.5 label2["TextWrapped"]=true label2["TextXAlignment"]=Enum["TextXAlignment"]["Center"]label2["Parent"]=frame
local textBox=Instance["new"]("TextBox")textBox["Size"]=UDim2["new"](1, -40, 0, 24)textBox["Position"]=UDim2["new"](0, 20, 0, 72)textBox["BackgroundColor3"]=UI["Elevated"]textBox["Text"]=settings["MobileButtons"]and settings["MobileButtons"][actionName]or""textBox["PlaceholderText"]="按钮名称（例如 MW）"textBox["TextColor3"]=UI["Text"]textBox["Font"]=Enum["Font"]["GothamSemibold"]textBox["TextSize"]=11 textBox["Parent"]=frame;
(Instance["new"]("UICorner", textBox))["CornerRadius"]=UDim["new"](0, 4)
local stroke2=Instance["new"]("UIStroke", textBox)stroke2["Color"]=UI["Stroke"]stroke2["Thickness"]=.8
local button2=Instance["new"]("TextButton")button2["Size"]=UDim2["new"](0, 90, 0, 24)button2["Position"]=UDim2["new"](.5, -95, 1, -34)button2["BackgroundColor3"]=UI["Accent"]button2["Text"]="保存"button2["TextColor3"]=Color3["fromRGB"](255, 255, 255)button2["Font"]=Enum["Font"]["GothamBold"]button2["TextSize"]=11 button2["AutoButtonColor"]=false button2["Parent"]=frame;
(Instance["new"]("UICorner", button2))["CornerRadius"]=UDim["new"](0, 5)
local button3=Instance["new"]("TextButton")button3["Size"]=UDim2["new"](0, 90, 0, 24)button3["Position"]=UDim2["new"](.5, 5, 1, -34)button3["BackgroundColor3"]=UI["Elevated"]button3["Text"]="取消"button3["TextColor3"]=UI["TextSub"]button3["Font"]=Enum["Font"]["GothamBold"]button3["TextSize"]=11 button3["AutoButtonColor"]=false button3["Parent"]=frame;
(Instance["new"]("UICorner", button3))["CornerRadius"]=UDim["new"](0, 5)
local stroke3=Instance["new"]("UIStroke", button3)stroke3["Color"]=UI["Stroke"]stroke3["Thickness"]=.8 button2["MouseButton1Click"]:Connect(function()pcall(callback, textBox["Text"])pcall(function()button:Destroy()
end
)
end
)button3["MouseButton1Click"]:Connect(function()pcall(function()button:Destroy()
end
)
end
)button["BackgroundTransparency"]=1;
(TweenService:Create(button, TweenInfo["new"](.2), {["BackgroundTransparency"]=.6})):Play()frame["Size"]=UDim2["new"](0, 0, 0, 0);
(TweenService:Create(frame, TweenInfo["new"](.2, Enum["EasingStyle"]["Back"], Enum["EasingDirection"]["Out"]), {["Size"]=UDim2["new"](0, 240, 0, 140)})):Play()
end
function cleanupParryUI()pcall(function()
local instance=localPlayer:FindFirstChildOfClass("PlayerGui")
local instance2=instance and instance:FindFirstChild("Survivor")
local instance3=instance2 and instance2:FindFirstChild("Gen")
local instance4=instance3 and instance3:FindFirstChild("ItemFrame")
if instance4 then
local instance5=instance4:FindFirstChild("Gui")
if instance5 then
local parrycooldownlabel=instance5:FindFirstChild("ParryCooldownLabel")
if parrycooldownlabel then
parrycooldownlabel:Destroy()
end
end
local parrycooldownlabel=instance4:FindFirstChild("ParryCooldownLabel")
if parrycooldownlabel then
parrycooldownlabel:Destroy()
end
end
local instance5=instance and instance:FindFirstChild("Survivor-mob")
local instance6=instance5 and instance5:FindFirstChild("Controls")
if instance6 then
local parrycooldownlabel=instance6:FindFirstChild("ParryCooldownLabel")
if parrycooldownlabel then
parrycooldownlabel:Destroy()
end
local instance7=instance6:FindFirstChild("action")
local parrycooldownlabel2=instance7 and instance7:FindFirstChild("ParryCooldownLabel")
if parrycooldownlabel2 then
parrycooldownlabel2:Destroy()
end
end
end
)
end
do
local items9={}
local items10={}
local numericValue=2
local numericValue2=62
local numericValue3=8
local numericValue4=20
local currentValue=-290
local numericValue5=275
local function processValue3()
for index, item in ipairs(items10)do
local target=numericValue4+((index-1))*((numericValue2+numericValue3))item["targetY"]=target
if item["frame"]and item["frame"]["Parent"]then
(TweenService:Create(item["frame"], TweenInfo["new"](.25, Enum["EasingStyle"]["Quad"], Enum["EasingDirection"]["Out"]), {["Position"]=UDim2["new"](1, currentValue, 0, target)})):Play()
end
end
end
local currentValue2 currentValue2=function()
if#items10>=numericValue or#items9==0 then
return
end
local text=table["remove"](items9, 1)
local count=#items9
local numericValue6=3
if count>0 then
numericValue6=math["max"](1, 3-(count*.5))
end
local count2=#items10+1
local tween=numericValue4+((count2-1))*((numericValue2+numericValue3))
local accentcyanColor={["info"]=UI and UI["AccentCyan"]or Color3["fromRGB"](0, 220, 255);
["success"]=UI and UI["AccentGreen"]or Color3["fromRGB"](34, 197, 94), ["warning"]=UI and UI["Warning"]or Color3["fromRGB"](245, 158, 11);
["error"]=UI and UI["Danger"]or Color3["fromRGB"](255, 42, 109)}
local currentValue3=accentcyanColor[text["notifType"]]or accentcyanColor["info"]
local currentValue4=(({["info"]="rbxassetid://10747372992", ["success"]="rbxassetid://10747375151";
["warning"]="rbxassetid://10747385226";
["error"]="rbxassetid://10747374023"}))[text["notifType"]]or"rbxassetid://10747372992"
local jlxhelpergui=screenGui or(localPlayer and(localPlayer:FindFirstChildOfClass("PlayerGui")and localPlayer["PlayerGui"]:FindFirstChild("JLXHelperGui")))
if not jlxhelpergui then
return
end
local frame=Instance["new"]("Frame")frame["Name"]="VD_Notif_"..tostring(tick())frame["Size"]=UDim2["new"](0, numericValue5, 0, numericValue2)frame["Position"]=UDim2["new"](1, 20, 0, tween)frame["BackgroundColor3"]=(UI and UI["Card"])or Color3["fromRGB"](15, 15, 22)frame["BackgroundTransparency"]=.05 frame["BorderSizePixel"]=0 frame["ZIndex"]=5000 frame["Parent"]=jlxhelpergui;
(Instance["new"]("UICorner", frame))["CornerRadius"]=UDim["new"](0, 8)
local stroke=Instance["new"]("UIStroke", frame)stroke["Color"]=currentValue3 stroke["Thickness"]=1.2 stroke["Transparency"]=.15
local frame2=Instance["new"]("Frame")frame2["Size"]=UDim2["new"](0, 4, 1, -12)frame2["Position"]=UDim2["new"](0, 6, 0, 6)frame2["BackgroundColor3"]=currentValue3 frame2["BorderSizePixel"]=0 frame2["ZIndex"]=5001 frame2["Parent"]=frame;
(Instance["new"]("UICorner", frame2))["CornerRadius"]=UDim["new"](1, 0)
local imageLabel=Instance["new"]("ImageLabel")imageLabel["Size"]=UDim2["new"](0, 16, 0, 16)imageLabel["Position"]=UDim2["new"](0, 16, 0, 8)imageLabel["BackgroundTransparency"]=1 imageLabel["Image"]=currentValue4 imageLabel["ImageColor3"]=currentValue3 imageLabel["ScaleType"]=Enum["ScaleType"]["Fit"]imageLabel["ZIndex"]=5001 imageLabel["Parent"]=frame
local label=Instance["new"]("TextLabel")label["Size"]=UDim2["new"](1, -44, 0, 18)label["Position"]=UDim2["new"](0, 40, 0, 7)label["BackgroundTransparency"]=1 label["Text"]=text["title"]label["TextColor3"]=Color3["fromRGB"](255, 255, 255)label["Font"]=Enum["Font"]["GothamBold"]label["TextSize"]=13 label["TextXAlignment"]=Enum["TextXAlignment"]["Left"]label["TextTruncate"]=Enum["TextTruncate"]["AtEnd"]label["ZIndex"]=5001 label["Parent"]=frame
local label2=Instance["new"]("TextLabel")label2["Size"]=UDim2["new"](1, -44, 0, 30)label2["Position"]=UDim2["new"](0, 40, 0, 25)label2["BackgroundTransparency"]=1 label2["Text"]=text["message"]label2["TextColor3"]=(UI and UI["TextSub"])or Color3["fromRGB"](200, 205, 215)label2["Font"]=Enum["Font"]["GothamMedium"]label2["TextSize"]=11.5 label2["TextXAlignment"]=Enum["TextXAlignment"]["Left"]label2["TextYAlignment"]=Enum["TextYAlignment"]["Top"]label2["TextWrapped"]=true label2["ZIndex"]=5001 label2["Parent"]=frame
local tween2={["frame"]=frame;
["targetY"]=tween}table["insert"](items10, tween2);
(TweenService:Create(frame, TweenInfo["new"](.3, Enum["EasingStyle"]["Quart"], Enum["EasingDirection"]["Out"]), {["Position"]=UDim2["new"](1, currentValue, 0, tween)})):Play()task["spawn"](function()task["wait"](numericValue6)
if frame and frame["Parent"]then
local tween3=tween2["targetY"]or tween;
(TweenService:Create(frame, TweenInfo["new"](.25, Enum["EasingStyle"]["Quad"], Enum["EasingDirection"]["In"]), {["Position"]=UDim2["new"](1, 20, 0, tween3)})):Play()task["wait"](.25)pcall(function()frame:Destroy()
end
)
end
for index, item in ipairs(items10)do
if item==tween2 then
table["remove"](items10, index)
break
end
end
processValue3()currentValue2()
end
)
end
function showNotification(title, message, notificationType)title=translateText(title)message=translateText(message)table["insert"](items9, {["title"]=title;
["message"]=message;
["notifType"]=notificationType or"info"})
while#items10<numericValue and#items9>0 do
currentValue2()
end
end
end
screenGui=Instance["new"]("ScreenGui")screenGui["Name"]="JLXHelperGui"screenGui["ResetOnSpawn"]=false screenGui["ZIndexBehavior"]=Enum["ZIndexBehavior"]["Sibling"]screenGui["DisplayOrder"]=99999 pcall(function()screenGui["Parent"]=guiParent
end
)
if not screenGui["Parent"]then
screenGui["Parent"]=billboardParent
end
minimapConnection=Instance["new"]("Frame")minimapConnection["Name"]="VD_TracerContainer"minimapConnection["Size"]=UDim2["new"](1, 0, 1, 0)minimapConnection["BackgroundTransparency"]=1 minimapConnection["BorderSizePixel"]=0 minimapConnection["ZIndex"]=1 minimapConnection["Parent"]=screenGui minimapFrame=Instance["new"]("CanvasGroup")minimapFrame["Name"]="VD_MinimapCard"minimapFrame["Size"]=UDim2["new"](0, 130, 0, 130)minimapFrame["Position"]=isMobileDevice and UDim2["new"](1, -140, 0, 10)or UDim2["new"](1, -150, 0, 10)minimapFrame["BackgroundColor3"]=UI["Bg"]minimapFrame["BackgroundTransparency"]=.2 minimapFrame["BorderSizePixel"]=0 minimapFrame["ZIndex"]=5 minimapFrame["Visible"]=false minimapFrame["Parent"]=screenGui;
(Instance["new"]("UICorner", minimapFrame))["CornerRadius"]=UDim["new"](.5, 0)
local stroke=Instance["new"]("UIStroke", minimapFrame)stroke["Color"]=UI["Stroke"]stroke["Thickness"]=1.2 stroke["Transparency"]=.3
local frame=Instance["new"]("Frame")frame["Name"]="CenterPlayer"frame["Size"]=UDim2["new"](0, 7, 0, 7)frame["Position"]=UDim2["new"](.5, 0, .5, 0)frame["AnchorPoint"]=Vector2["new"](.5, .5)frame["BackgroundColor3"]=UI["AccentCyan"]frame["BorderSizePixel"]=0 frame["ZIndex"]=10 frame["Parent"]=minimapFrame;
(Instance["new"]("UICorner", frame))["CornerRadius"]=UDim["new"](1, 0)
local label=Instance["new"]("TextLabel")label["Name"]="RadarLabel"label["Size"]=UDim2["new"](1, 0, 0, 14)label["Position"]=UDim2["new"](0, 0, 1, -16)label["BackgroundTransparency"]=1 label["Text"]="雷达"label["TextColor3"]=UI["Accent"]label["Font"]=Enum["Font"]["GothamBold"]label["TextSize"]=8 label["TextStrokeTransparency"]=.6 label["ZIndex"]=11 label["Parent"]=minimapFrame
local conditionMet4=false
local startPosition=nil
local startPosition2=nil
local currentValue=nil minimapFrame["InputBegan"]:Connect(function(input)
if input["UserInputType"]==Enum["UserInputType"]["MouseButton1"]or input["UserInputType"]==Enum["UserInputType"]["Touch"]then
conditionMet4=true startPosition=input["Position"]startPosition2=minimapFrame["Position"]currentValue=input
end
end
)minimapFrame["InputChanged"]:Connect(function(input)
if conditionMet4 and((input["UserInputType"]==Enum["UserInputType"]["MouseMovement"]or input["UserInputType"]==Enum["UserInputType"]["Touch"]))then
local layoutPosition=input["Position"]-startPosition minimapFrame["Position"]=UDim2["new"](startPosition2["X"]["Scale"], startPosition2["X"]["Offset"]+layoutPosition["X"], startPosition2["Y"]["Scale"], startPosition2["Y"]["Offset"]+layoutPosition["Y"])
end
end
)minimapFrame["InputEnded"]:Connect(function(value)
if value==currentValue then
conditionMet4=false currentValue=nil
end
end
)
local currentValue2=Enum["MouseBehavior"]["LockCenter"]
local enabled=false
local enabled2=false
local progress=(not isMobileDevice)
local function updateMouseCapture()pcall(function()
if not progress then
currentValue2=UserInputService["MouseBehavior"]enabled=UserInputService["MouseIconEnabled"]enabled2=true
end
end
)
end
local function updateMouseCapture2()pcall(function()
if enabled2 then
UserInputService["MouseBehavior"]=currentValue2 UserInputService["MouseIconEnabled"]=enabled
else
local conditionMet5=workspace:FindFirstChild("Map")~=nil
if conditionMet5 then
UserInputService["MouseBehavior"]=Enum["MouseBehavior"]["LockCenter"]UserInputService["MouseIconEnabled"]=false
else
UserInputService["MouseBehavior"]=Enum["MouseBehavior"]["Default"]UserInputService["MouseIconEnabled"]=true
end
end
end
)
end
pcall(function()currentValue2=UserInputService["MouseBehavior"]enabled=UserInputService["MouseIconEnabled"]enabled2=true
end
)
local frame2=""mainFrame=Instance["new"]("Frame")mainFrame["Size"]=UDim2["new"](0, UI["MainW"], 0, UI["MainH"])mainFrame["Position"]=UDim2["new"](.5, -UI["MainW"]/2, .5, -UI["MainH"]/2)mainFrame["BackgroundColor3"]=UI["Bg"]mainFrame["BackgroundTransparency"]=.16 mainFrame["BorderSizePixel"]=0 mainFrame["ClipsDescendants"]=true mainFrame["Active"]=true mainFrame["Visible"]=false mainFrame["Parent"]=screenGui
local imageLabel=Instance["new"]("ImageLabel")imageLabel["Name"]="VD_CustomBg"imageLabel["Size"]=UDim2["new"](1, 0, 1, 0)imageLabel["Position"]=UDim2["new"](0, 0, 0, 0)imageLabel["BackgroundTransparency"]=1 imageLabel["Image"]=""imageLabel["ScaleType"]=Enum["ScaleType"]["Crop"]imageLabel["ZIndex"]=1 imageLabel["Visible"]=false imageLabel["Parent"]=mainFrame
local frame3=Instance["new"]("Frame")frame3["Name"]="VD_BgOverlay"frame3["Size"]=UDim2["new"](1, 0, 1, 0)frame3["Position"]=UDim2["new"](0, 0, 0, 0)frame3["BackgroundColor3"]=Color3["fromRGB"](0, 0, 0)frame3["BackgroundTransparency"]=1 frame3["BorderSizePixel"]=0 frame3["ZIndex"]=2 frame3["Visible"]=false frame3["Parent"]=mainFrame
local function getFeatureState2()
local sidebar=mainFrame:FindFirstChild("Sidebar")
if not isFeatureAvailable()or not((featureAvailability and featureAvailability["CustomBackground"]))or not((settings["CustomBackground"]and settings["CustomBackground"]["Enabled"]))then
imageLabel["Visible"]=false frame3["Visible"]=false mainFrame["BackgroundColor3"]=UI["Bg"]mainFrame["BackgroundTransparency"]=.05
if sidebar then
local name2=(themes and(currentThemeName and themes[currentThemeName]))or(themes and themes["Default"])sidebar["BackgroundTransparency"]=(name2 and name2["BgTrans"])or.08
end
return
end
local custombackground=settings["CustomBackground"]
local assetUrl=""
if custombackground["LocalFile"]and custombackground["LocalFile"]~=""then
local currentValue3=writefile and(readfile and(isfile and getCustomAsset))
if currentValue3 then
local success, result=pcall(getCustomAsset, custombackground["LocalFile"])
if success and(result and result~="")then
assetUrl=result
end
end
end
if assetUrl==""and(custombackground["AssetId"]and custombackground["AssetId"]~="")then
local assetId=custombackground["AssetId"]
if not assetId:match("^rbxassetid://")then
assetId="rbxassetid://"..((assetId:match("%d+")or""))
end
assetUrl=assetId
end
if assetUrl==""then
imageLabel["Visible"]=false frame3["Visible"]=false mainFrame["BackgroundColor3"]=UI["Bg"]mainFrame["BackgroundTransparency"]=.05
if sidebar then
local name2=(themes and(currentThemeName and themes[currentThemeName]))or(themes and themes["Default"])sidebar["BackgroundTransparency"]=(name2 and name2["BgTrans"])or.08
end
return
end
local items9={["Crop"]=Enum["ScaleType"]["Crop"];
["Stretch"]=Enum["ScaleType"]["Stretch"], ["Fit"]=Enum["ScaleType"]["Fit"]}imageLabel["ScaleType"]=items9[custombackground["ScaleType"]]or Enum["ScaleType"]["Crop"]imageLabel["Image"]=assetUrl imageLabel["Visible"]=true
local clampedValue=math["clamp"](((custombackground["Overlay"]or 40))/100, 0, .7)frame3["BackgroundTransparency"]=1-clampedValue frame3["Visible"]=clampedValue>0 mainFrame["BackgroundTransparency"]=1
if sidebar then
sidebar["BackgroundTransparency"]=.85
end
end
_G["VD_ApplyCustomBg"]=getFeatureState2
local button=Instance["new"]("TextButton")button["Name"]="ModalButton"button["Size"]=UDim2["new"](0, 0, 0, 0)button["Position"]=UDim2["new"](0, 0, 0, 0)button["BackgroundTransparency"]=1 button["Text"]=""button["Modal"]=mainFrame["Visible"]button["Parent"]=mainFrame
local visible=true
if mainFrame["Visible"]then
task["spawn"](function()task["wait"](.5)
local player=localPlayer:GetMouse()
if player then
pcall(function()frame2=player["Icon"]visible=UserInputService["MouseIconEnabled"]player["Icon"]="rbxassetid://26140499"UserInputService["MouseBehavior"]=Enum["MouseBehavior"]["Default"]UserInputService["MouseIconEnabled"]=true
end
)
end
end
)
end
registerConnection(RunService["RenderStepped"]:Connect(function()
if mainFrame and progress then
pcall(function()
local player=localPlayer:GetMouse()
if player then
player["Icon"]="rbxassetid://26140499"
end
UserInputService["MouseBehavior"]=Enum["MouseBehavior"]["Default"]UserInputService["MouseIconEnabled"]=true
end
)
else
pcall(function()
local name2=localPlayer["Team"]
local isMatchingTeam=not name2 or(name2["Name"]=="Spectators"or(name2["Name"]:lower()):find("spec")or(name2["Name"]:lower()):find("lobby"))
local character=localPlayer["Character"]
local humanoid=character and character:FindFirstChildOfClass("Humanoid")
local conditionMet5=humanoid and humanoid["Health"]>0
if not isMatchingTeam and conditionMet5 then
if UserInputService["MouseBehavior"]~=Enum["MouseBehavior"]["LockCenter"]or UserInputService["MouseIconEnabled"]~=false then
UserInputService["MouseBehavior"]=Enum["MouseBehavior"]["LockCenter"]UserInputService["MouseIconEnabled"]=false
end
else
if UserInputService["MouseBehavior"]==Enum["MouseBehavior"]["LockCenter"]or UserInputService["MouseIconEnabled"]~=true then
UserInputService["MouseBehavior"]=Enum["MouseBehavior"]["Default"]UserInputService["MouseIconEnabled"]=true
end
end
end
)
end
pcall(function()
local name2=localPlayer["Team"]
local isMatchingTeam=name2 and name2["Name"]=="Killer"
if settings["KillerThirdPerson"]and isMatchingTeam then
localPlayer["CameraMode"]=Enum["CameraMode"]["Classic"]localPlayer["CameraMinZoomDistance"]=10
if settings["InfiniteZoom"]then
localPlayer["CameraMaxZoomDistance"]=100000
else
localPlayer["CameraMaxZoomDistance"]=12
end
_G["wasThirdPersonActive"]=true
else
if _G["wasThirdPersonActive"]then
if isMatchingTeam then
localPlayer["CameraMinZoomDistance"]=.5 localPlayer["CameraMaxZoomDistance"]=.5 localPlayer["CameraMode"]=Enum["CameraMode"]["LockFirstPerson"]
else
localPlayer["CameraMinZoomDistance"]=originalCameraSettings["CameraMinZoomDistance"]or.5 localPlayer["CameraMaxZoomDistance"]=settings["InfiniteZoom"]and 100000 or(originalCameraSettings["CameraMaxZoomDistance"]or 12)localPlayer["CameraMode"]=originalCameraSettings["CameraMode"]or Enum["CameraMode"]["Classic"]
end
_G["wasThirdPersonActive"]=false
elseif not isMatchingTeam then
if settings["InfiniteZoom"]then
localPlayer["CameraMaxZoomDistance"]=100000
else
localPlayer["CameraMaxZoomDistance"]=originalCameraSettings["CameraMaxZoomDistance"]or 12
end
end
end
end
)
end
));
(Instance["new"]("UICorner", mainFrame))["CornerRadius"]=UDim["new"](0, UI["Radius"])do
local stroke2=Instance["new"]("UIStroke", mainFrame)stroke2["Thickness"]=1 stroke2["Color"]=UI["Stroke"]
local frame4=Instance["new"]("Frame")frame4["Name"]="TopAccentBar"frame4["Size"]=UDim2["new"](1, 0, 0, 1)frame4["Position"]=UDim2["new"](0, 0, 0, 0)frame4["BackgroundColor3"]=UI["Accent"]frame4["BorderSizePixel"]=0 frame4["ZIndex"]=10 frame4["Parent"]=mainFrame titleBar=Instance["new"]("Frame")titleBar["Size"]=UDim2["new"](1, 0, 0, UI["TitleH"])titleBar["BackgroundColor3"]=UI["Sidebar"]titleBar["BackgroundTransparency"]=.14 titleBar["BorderSizePixel"]=0 titleBar["Parent"]=mainFrame
local frame5=Instance["new"]("Frame")frame5["Size"]=UDim2["new"](1, 0, 0, 1)frame5["Position"]=UDim2["new"](0, 0, 1, -1)frame5["BackgroundColor3"]=UI["StrokeDim"]frame5["BorderSizePixel"]=0 frame5["Parent"]=titleBar
local label2=Instance["new"]("TextLabel")label2["Size"]=UDim2["new"](0, 320, 1, 0)label2["Position"]=UDim2["new"](0, 12, 0, 0)label2["BackgroundTransparency"]=1 label2["RichText"]=false label2["Text"]="VIOLENCE DISTRICT · 功能面板"label2["TextColor3"]=UI["Accent"]label2["Font"]=Enum["Font"]["GothamBold"]label2["TextSize"]=15 label2["TextXAlignment"]=Enum["TextXAlignment"]["Left"]label2["Parent"]=titleBar minBtn=Instance["new"]("TextButton")minBtn["Size"]=UDim2["new"](0, 24, 0, 24)minBtn["Position"]=UDim2["new"](1, -54, .5, -12)minBtn["BackgroundTransparency"]=1 minBtn["Text"]="—"minBtn["TextColor3"]=UI["TextSub"]minBtn["Font"]=Enum["Font"]["GothamMedium"]minBtn["TextSize"]=14 minBtn["AutoButtonColor"]=false minBtn["Parent"]=titleBar minBtn["MouseEnter"]:Connect(function()(TweenService:Create(minBtn, TweenInfo["new"](.15), {["TextColor3"]=Color3["fromRGB"](255, 255, 255)})):Play()
end
)minBtn["MouseLeave"]:Connect(function()(TweenService:Create(minBtn, TweenInfo["new"](.15), {["TextColor3"]=Color3["fromRGB"](160, 160, 175)})):Play()
end
)closeBtn=Instance["new"]("TextButton")closeBtn["Size"]=UDim2["new"](0, 24, 0, 24)closeBtn["Position"]=UDim2["new"](1, -26, .5, -12)closeBtn["BackgroundTransparency"]=1 closeBtn["Text"]="×"closeBtn["TextColor3"]=UI["TextSub"]closeBtn["Font"]=Enum["Font"]["GothamMedium"]closeBtn["TextSize"]=13 closeBtn["AutoButtonColor"]=false closeBtn["Parent"]=titleBar closeBtn["MouseEnter"]:Connect(function()(TweenService:Create(closeBtn, TweenInfo["new"](.15), {["TextColor3"]=Color3["fromRGB"](255, 65, 85)})):Play()
end
)closeBtn["MouseLeave"]:Connect(function()(TweenService:Create(closeBtn, TweenInfo["new"](.15), {["TextColor3"]=Color3["fromRGB"](160, 160, 175)})):Play()
end
)
local frame6=Instance["new"]("Frame")frame6["Name"]="Sidebar"frame6["Size"]=UDim2["new"](0, 138, 1, -UI["TitleH"])frame6["Position"]=UDim2["new"](0, 0, 0, UI["TitleH"])frame6["BackgroundColor3"]=UI["Sidebar"]frame6["BackgroundTransparency"]=.08 frame6["BorderSizePixel"]=0 frame6["Parent"]=mainFrame
local frame7=Instance["new"]("Frame")frame7["Size"]=UDim2["new"](0, 1, 1, 0)frame7["Position"]=UDim2["new"](1, -1, 0, 0)frame7["BackgroundColor3"]=UI["StrokeDim"]frame7["BorderSizePixel"]=0 frame7["Parent"]=frame6 sidebarScroll=Instance["new"]("ScrollingFrame")sidebarScroll["Size"]=UDim2["new"](1, 0, 1, -74)sidebarScroll["Position"]=UDim2["new"](0, 0, 0, 8)sidebarScroll["BackgroundTransparency"]=1 sidebarScroll["BorderSizePixel"]=0 sidebarScroll["ScrollBarThickness"]=1 sidebarScroll["ScrollBarImageColor3"]=UI["Accent"]sidebarScroll["ScrollBarImageTransparency"]=.7 sidebarScroll["Parent"]=frame6
local listLayout=Instance["new"]("UIListLayout")listLayout["Padding"]=UDim["new"](0, 4)listLayout["SortOrder"]=Enum["SortOrder"]["LayoutOrder"]listLayout["Parent"]=sidebarScroll sidebarScroll["AutomaticCanvasSize"]=Enum["AutomaticSize"]["Y"];
(listLayout:GetPropertyChangedSignal("AbsoluteContentSize")):Connect(function()sidebarScroll["CanvasSize"]=UDim2["new"](0, 0, 0, listLayout["AbsoluteContentSize"]["Y"]+16)
end
)
local frame8=Instance["new"]("Frame")frame8["Size"]=UDim2["new"](1, -16, 0, 44)frame8["Position"]=UDim2["new"](0, 8, 1, -68)frame8["BackgroundColor3"]=UI["Card"]frame8["BackgroundTransparency"]=.38 frame8["BorderSizePixel"]=0 frame8["Parent"]=frame6;
(Instance["new"]("UICorner", frame8))["CornerRadius"]=UDim["new"](0, UI["CardRadius"]);
(Instance["new"]("UIStroke", frame8))["Color"]=UI["Stroke"]
local imageLabel2=Instance["new"]("ImageLabel")imageLabel2["Name"]="SidebarAvatar"imageLabel2["Size"]=UDim2["new"](0, 30, 0, 30)imageLabel2["Position"]=UDim2["new"](0, 7, .5, -15)imageLabel2["BackgroundTransparency"]=1 imageLabel2["Parent"]=frame8
local corner=Instance["new"]("UICorner")corner["CornerRadius"]=UDim["new"](.5, 0)corner["Parent"]=imageLabel2 task["spawn"](function()
local success, result=pcall(function()
return Players:GetUserThumbnailAsync(localPlayer["UserId"], Enum["ThumbnailType"]["HeadShot"], Enum["ThumbnailSize"]["Size100x100"])
end
)
if success and result then
imageLabel2["Image"]=result
else
imageLabel2["Image"]="rbxassetid://0"
end
end
)
local label3=Instance["new"]("TextLabel")label3["Name"]="SidebarDisplayName"label3["Size"]=UDim2["new"](1, -48, 0, 14)label3["Position"]=UDim2["new"](0, 42, 0, 5)label3["BackgroundTransparency"]=1 label3["Text"]=localPlayer["DisplayName"]label3["TextColor3"]=UI["Text"]label3["Font"]=Enum["Font"]["GothamBold"]label3["TextSize"]=12 label3["TextXAlignment"]=Enum["TextXAlignment"]["Left"]label3["TextTruncate"]=Enum["TextTruncate"]["AtEnd"]label3["ClipsDescendants"]=true label3["Parent"]=frame8
local label4=Instance["new"]("TextLabel")label4["Name"]="SidebarUsername"label4["Size"]=UDim2["new"](1, -48, 0, 12)label4["Position"]=UDim2["new"](0, 42, 0, 21)label4["BackgroundTransparency"]=1 label4["Text"]="@"..localPlayer["Name"]label4["TextColor3"]=UI["Muted"]label4["Font"]=Enum["Font"]["Gotham"]label4["TextSize"]=10 label4["TextXAlignment"]=Enum["TextXAlignment"]["Left"]label4["TextTruncate"]=Enum["TextTruncate"]["AtEnd"]label4["ClipsDescendants"]=true label4["Parent"]=frame8
local label5=Instance["new"]("TextLabel")label5["Size"]=UDim2["new"](1, -20, 0, 16)label5["Position"]=UDim2["new"](0, 10, 1, -20)label5["BackgroundTransparency"]=1 label5["Text"]="VD · 1.5.5"label5["TextColor3"]=UI["Muted"]label5["Font"]=Enum["Font"]["GothamBold"]label5["TextSize"]=9 label5["TextXAlignment"]=Enum["TextXAlignment"]["Left"]label5["Parent"]=frame6
local frame9=Instance["new"]("Frame")frame9["Name"]="ContentRoot"frame9["Size"]=UDim2["new"](1, -150, 1, -UI["TitleH"]-12)frame9["Position"]=UDim2["new"](0, 144, 0, UI["TitleH"]+6)frame9["BackgroundTransparency"]=1 frame9["Parent"]=mainFrame contentFolder=Instance["new"]("Folder")contentFolder["Name"]="Tabs"contentFolder["Parent"]=frame9
end
tabButtons={}
tabContainers={}
activeTab=nil
function switchTab(tab)
if activeTab==tab then return end
for key,instance in pairs(tabButtons)do
local indicator=instance:FindFirstChild("Indicator")
local label2=instance:FindFirstChild("Label")
local conditionMet5=key==tab
instance["BackgroundTransparency"]=conditionMet5 and .72 or 1
instance["BackgroundColor3"]=UI["Elevated"]
if indicator then
indicator["BackgroundTransparency"]=conditionMet5 and 0 or 1
end
if label2 then
label2["TextColor3"]=conditionMet5 and UI["Accent"]or UI["TextSub"]
end
end
for key,container in pairs(tabContainers)do
container["Visible"]=key==tab
end
activeTab=tab
end
function createTab(tabId,iconAsset,title,description)
local button2=Instance["new"]("TextButton")
button2["Name"]=tabId.."TabBtn"
button2["Size"]=UDim2["new"](1,-16,0,30)
button2["Position"]=UDim2["new"](0,8,0,0)
button2["BackgroundColor3"]=UI["Elevated"]
button2["BackgroundTransparency"]=1
button2["BorderSizePixel"]=0
button2["Text"]=""
button2["AutoButtonColor"]=false
button2["Parent"]=sidebarScroll
;(Instance["new"]("UICorner",button2))["CornerRadius"]=UDim["new"](0,4)
local frame4=Instance["new"]("Frame")
frame4["Name"]="Indicator"
frame4["Size"]=UDim2["new"](0,2,0,16)
frame4["Position"]=UDim2["new"](0,6,.5,-8)
frame4["BackgroundColor3"]=UI["Accent"]
frame4["BackgroundTransparency"]=1
frame4["BorderSizePixel"]=0
frame4["Parent"]=button2
local label2=Instance["new"]("TextLabel")
label2["Name"]="Label"
label2["Size"]=UDim2["new"](1,-24,1,0)
label2["Position"]=UDim2["new"](0,16,0,0)
label2["BackgroundTransparency"]=1
label2["Text"]=translateText(title)
label2["TextColor3"]=UI["TextSub"]
label2["Font"]=Enum["Font"]["GothamMedium"]
label2["TextSize"]=12
label2["TextXAlignment"]=Enum["TextXAlignment"]["Left"]
label2["Parent"]=button2
button2["MouseEnter"]:Connect(function()
if activeTab~=tabId then
button2["BackgroundTransparency"]=.88
label2["TextColor3"]=UI["Text"]
end
end)
button2["MouseLeave"]:Connect(function()
if activeTab~=tabId then
button2["BackgroundTransparency"]=1
label2["TextColor3"]=UI["TextSub"]
end
end)
button2["MouseButton1Click"]:Connect(function()
switchTab(tabId)
end)
tabButtons[tabId]=button2
local canvasGroup=Instance["new"]("CanvasGroup")
canvasGroup["Name"]=tabId.."TabContainer"
canvasGroup["Size"]=UDim2["new"](1,0,1,0)
canvasGroup["BackgroundTransparency"]=1
canvasGroup["BorderSizePixel"]=0
canvasGroup["Visible"]=false
canvasGroup["Parent"]=contentFolder
local scrollFrame=Instance["new"]("ScrollingFrame")
scrollFrame["Size"]=UDim2["new"](1,0,1,0)
scrollFrame["BackgroundTransparency"]=1
scrollFrame["BorderSizePixel"]=0
scrollFrame["ScrollBarThickness"]=2
scrollFrame["ScrollBarImageColor3"]=UI["Accent"]
scrollFrame["ScrollBarImageTransparency"]=.35
scrollFrame["Parent"]=canvasGroup
local padding=Instance["new"]("UIPadding")
padding["PaddingTop"]=UDim["new"](0,4)
padding["PaddingBottom"]=UDim["new"](0,34)
padding["PaddingRight"]=UDim["new"](0,6)
padding["Parent"]=scrollFrame
local listLayout=Instance["new"]("UIListLayout")
listLayout["Padding"]=UDim["new"](0,5)
listLayout["SortOrder"]=Enum["SortOrder"]["LayoutOrder"]
listLayout["Parent"]=scrollFrame
;(listLayout:GetPropertyChangedSignal("AbsoluteContentSize")):Connect(function()
scrollFrame["CanvasSize"]=UDim2["new"](0,0,0,listLayout["AbsoluteContentSize"]["Y"]+40)
end)
local frame5=Instance["new"]("Frame")
frame5["Name"]="HeaderBanner"
frame5["Size"]=UDim2["new"](1,0,0,42)
frame5["BackgroundTransparency"]=1
frame5["LayoutOrder"]=-100
frame5["Parent"]=scrollFrame
local label3=Instance["new"]("TextLabel")
label3["Size"]=UDim2["new"](1,-8,0,22)
label3["Position"]=UDim2["new"](0,4,0,2)
label3["BackgroundTransparency"]=1
label3["Text"]=translateText(title)
label3["TextColor3"]=UI["Accent"]
label3["Font"]=Enum["Font"]["GothamBold"]
label3["TextSize"]=15
label3["TextXAlignment"]=Enum["TextXAlignment"]["Left"]
label3["Parent"]=frame5
local label4=Instance["new"]("TextLabel")
label4["Size"]=UDim2["new"](1,-8,0,14)
label4["Position"]=UDim2["new"](0,4,0,24)
label4["BackgroundTransparency"]=1
label4["Text"]=translateText(description or"")
label4["TextColor3"]=UI["Muted"]
label4["Font"]=Enum["Font"]["Gotham"]
label4["TextSize"]=10
label4["TextXAlignment"]=Enum["TextXAlignment"]["Left"]
label4["Visible"]=label4["Text"]~=""
label4["Parent"]=frame5
tabContainers[tabId]=canvasGroup
return scrollFrame
end
function createSection(parent, title, accentColor)
title=translateText(title)
local textsubColor=accentColor or UI["TextSub"]
local frame4=Instance["new"]("Frame")frame4["Size"]=UDim2["new"](1, 0, 0, 24)frame4["BackgroundTransparency"]=1 frame4["BorderSizePixel"]=0 frame4["Parent"]=parent
local label2=Instance["new"]("TextLabel")label2["Size"]=UDim2["new"](1, -8, 1, 0)label2["Position"]=UDim2["new"](0, 4, 0, 0)label2["BackgroundTransparency"]=1 label2["Text"]=title label2["TextColor3"]=textsubColor label2["Font"]=Enum["Font"]["GothamBold"]label2["TextSize"]=12 label2["TextXAlignment"]=Enum["TextXAlignment"]["Left"]label2["Parent"]=frame4
local frame5=Instance["new"]("Frame")frame5["Size"]=UDim2["new"](1, -8, 0, 1)frame5["Position"]=UDim2["new"](0, 4, 1, -2)frame5["BackgroundColor3"]=UI["StrokeDim"]frame5["BorderSizePixel"]=0 frame5["Parent"]=frame4
end
toggleInProgress=false function toggleUI(value)
if not mainFrame then
return
end
if uiReady then
return
end
if toggleInProgress then
return
end
local isVisible=(value~=nil)and value or(not mainFrame["Visible"])mainFrame["ClipsDescendants"]=true
local name2=themes[currentThemeName]or themes["Default"]
local player=localPlayer:GetMouse()
if isVisible then
updateMouseCapture()toggleInProgress=true progress=true mainFrame["Visible"]=true pcall(function()
local modalbutton=mainFrame:FindFirstChild("ModalButton")
if modalbutton then
modalbutton["Modal"]=true
end
player["Icon"]="rbxassetid://26140499"UserInputService["MouseBehavior"]=Enum["MouseBehavior"]["Default"]UserInputService["MouseIconEnabled"]=true
end
)mainFrame["Size"]=UDim2["new"](0, UI["MainW"]*.8, 0, UI["MainH"]*.8)mainFrame["Position"]=UDim2["new"](.5, -((UI["MainW"]*.8))/2, .5, -((UI["MainH"]*.8))/2)mainFrame["BackgroundTransparency"]=1
local tween=TweenService:Create(mainFrame, TweenInfo["new"](.25, Enum["EasingStyle"]["Back"], Enum["EasingDirection"]["Out"]), {["Size"]=UDim2["new"](0, UI["MainW"], 0, UI["MainH"]), ["Position"]=UDim2["new"](.5, -UI["MainW"]/2, .5, -UI["MainH"]/2)})
local tween2=TweenService:Create(mainFrame, TweenInfo["new"](.2, Enum["EasingStyle"]["Quad"], Enum["EasingDirection"]["Out"]), {["BackgroundTransparency"]=name2["BgTrans"]})tween:Play()tween2:Play()tween["Completed"]:Connect(function()toggleInProgress=false
end
)
else
toggleInProgress=true progress=false pcall(function()
local modalbutton=mainFrame:FindFirstChild("ModalButton")
if modalbutton then
modalbutton["Modal"]=false
end
player["Icon"]=""updateMouseCapture2()
end
)
local tween=TweenService:Create(mainFrame, TweenInfo["new"](.2, Enum["EasingStyle"]["Quad"], Enum["EasingDirection"]["In"]), {["Size"]=UDim2["new"](0, UI["MainW"]*.8, 0, UI["MainH"]*.8), ["Position"]=UDim2["new"](.5, -((UI["MainW"]*.8))/2, .5, -((UI["MainH"]*.8))/2)})
local tween2=TweenService:Create(mainFrame, TweenInfo["new"](.2, Enum["EasingStyle"]["Quad"], Enum["EasingDirection"]["In"]), {["BackgroundTransparency"]=1})tween:Play()tween2:Play()tween["Completed"]:Connect(function()mainFrame["Visible"]=false mainFrame["Size"]=UDim2["new"](0, UI["MainW"], 0, UI["MainH"])mainFrame["Position"]=UDim2["new"](.5, -UI["MainW"]/2, .5, -UI["MainH"]/2)mainFrame["BackgroundTransparency"]=name2["BgTrans"]toggleInProgress=false
end
)
end
end
actionHandlers={}actionHandlers["ToggleUI"]=function()pcall(toggleUI)
end
actionHandlers["ToggleSpeedBoost"]=function()
local teamName=localPlayer["Team"]
local isMatchingTeam=teamName and((teamName["Name"]=="Survivors"or teamName["Name"]=="Killer"))
if not isMatchingTeam then
settings["SpeedBoostEnabled"]=false pcall(saveSettings)
if speedBoostConnection then
pcall(speedBoostConnection)
end
showNotification("Speed Boost", "Speed Boost can only be used as Survivor or Killer!", "warning")
return
end
settings["SpeedBoostEnabled"]=not settings["SpeedBoostEnabled"]pcall(applyLocalPlayerModifiers)pcall(saveSettings)
if speedBoostConnection then
pcall(speedBoostConnection)
end
if settings["ShowToggleNotifications"]then
showNotification("Speed Boost", settings["SpeedBoostEnabled"]and"Enabled"or"Disabled", "info")
end
end
actionHandlers["AutoMoonwalk"]=function()settings["AutoMoonwalk"]=not settings["AutoMoonwalk"]
if not settings["AutoMoonwalk"]then
pcall(function()
local character=localPlayer["Character"]
local humanoid=character and character:FindFirstChildOfClass("Humanoid")
if humanoid then
humanoid["AutoRotate"]=true
end
end
)
end
pcall(saveSettings)
if speedBoostConnection then
pcall(speedBoostConnection)
end
if settings["ShowToggleNotifications"]then
showNotification("Auto Moonwalk", settings["AutoMoonwalk"]and"Enabled"or"Disabled", "info")
end
end
actionHandlers["CancelGen"]=function()
if not((isFeatureAvailable()and(featureAvailability and featureAvailability["CancelGen"])))then
showNotification("Feature", "Feature unavailable.", "warning")
return
end
if doCancelGen then
pcall(doCancelGen)
end
end
keybindButtons={}keybindTipShown=false isBindingKey=false function showKeybindModal()
if not mainFrame then
return
end
local button2=Instance["new"]("TextButton")button2["Size"]=UDim2["new"](1, 0, 1, 0)button2["BackgroundColor3"]=UI["Bg"]button2["BackgroundTransparency"]=1 button2["Text"]=""button2["AutoButtonColor"]=false button2["BorderSizePixel"]=0 button2["ZIndex"]=500 button2["Parent"]=mainFrame;
(Instance["new"]("UICorner", button2))["CornerRadius"]=UDim["new"](0, UI["Radius"])
local frame4=Instance["new"]("Frame")frame4["Size"]=UDim2["new"](0, 0, 0, 0)frame4["Position"]=UDim2["new"](.5, 0, .5, 0)frame4["AnchorPoint"]=Vector2["new"](.5, .5)frame4["BackgroundColor3"]=UI["Card"]frame4["BorderSizePixel"]=0 frame4["ClipsDescendants"]=true frame4["Parent"]=button2;
(Instance["new"]("UICorner", frame4))["CornerRadius"]=UDim["new"](0, UI["CardRadius"])
local stroke2=Instance["new"]("UIStroke", frame4)stroke2["Color"]=UI["Accent"]stroke2["Thickness"]=1.2 stroke2["Transparency"]=.2
local label2=Instance["new"]("TextLabel")label2["Size"]=UDim2["new"](1, 0, 0, 26)label2["Position"]=UDim2["new"](0, 0, 0, 12)label2["BackgroundTransparency"]=1 label2["Text"]="按键绑定"label2["TextColor3"]=UI["AccentCyan"]label2["Font"]=Enum["Font"]["GothamBold"]label2["TextSize"]=14 label2["Parent"]=frame4
local label3=Instance["new"]("TextLabel")label3["Size"]=UDim2["new"](1, -24, 0, 60)label3["Position"]=UDim2["new"](0, 12, 0, 42)label3["BackgroundTransparency"]=1 label3["Text"]="• 左键点击绑定按钮后按下任意按键。\n\n• 右键点击可恢复为“无”。"label3["TextColor3"]=UI["TextSub"]label3["Font"]=Enum["Font"]["GothamMedium"]label3["TextSize"]=11.5 label3["TextWrapped"]=true label3["TextXAlignment"]=Enum["TextXAlignment"]["Left"]label3["TextYAlignment"]=Enum["TextYAlignment"]["Top"]label3["Parent"]=frame4
local button3=Instance["new"]("TextButton")button3["Size"]=UDim2["new"](0, 80, 0, 26)button3["Position"]=UDim2["new"](.5, -40, 1, -38)button3["BackgroundColor3"]=UI["Accent"]button3["Text"]="知道了"button3["TextColor3"]=Color3["fromRGB"](255, 255, 255)button3["Font"]=Enum["Font"]["GothamBold"]button3["TextSize"]=12 button3["AutoButtonColor"]=false button3["Parent"]=frame4;
(Instance["new"]("UICorner", button3))["CornerRadius"]=UDim["new"](0, 5)
local stroke3=Instance["new"]("UIStroke", button3)stroke3["Color"]=UI["Stroke"]stroke3["Thickness"]=.8;
(TweenService:Create(button2, TweenInfo["new"](.2, Enum["EasingStyle"]["Quad"], Enum["EasingDirection"]["Out"]), {["BackgroundTransparency"]=.35})):Play();
(TweenService:Create(frame4, TweenInfo["new"](.25, Enum["EasingStyle"]["Back"], Enum["EasingDirection"]["Out"]), {["Size"]=UDim2["new"](0, 300, 0, 150)})):Play()button3["MouseEnter"]:Connect(function()(TweenService:Create(button3, TweenInfo["new"](.15), {["BackgroundColor3"]=UI["HoverCard"]})):Play()
end
)button3["MouseLeave"]:Connect(function()(TweenService:Create(button3, TweenInfo["new"](.15), {["BackgroundColor3"]=UI["Accent"]})):Play()
end
)button3["MouseButton1Click"]:Connect(function()(TweenService:Create(button2, TweenInfo["new"](.18, Enum["EasingStyle"]["Quad"], Enum["EasingDirection"]["In"]), {["BackgroundTransparency"]=1})):Play();
(TweenService:Create(frame4, TweenInfo["new"](.18, Enum["EasingStyle"]["Quad"], Enum["EasingDirection"]["In"]), {["Size"]=UDim2["new"](0, 0, 0, 0)})):Play()task["wait"](.2)pcall(function()button2:Destroy()
end
)
end
)
end
function showConflictModal(title, message, confirmCallback, cancelCallback)
if not mainFrame then
return
end
local button2=Instance["new"]("TextButton")button2["Size"]=UDim2["new"](1, 0, 1, 0)button2["BackgroundColor3"]=UI["Bg"]button2["BackgroundTransparency"]=1 button2["Text"]=""button2["AutoButtonColor"]=false button2["BorderSizePixel"]=0 button2["ZIndex"]=600 button2["Parent"]=mainFrame;
(Instance["new"]("UICorner", button2))["CornerRadius"]=UDim["new"](0, UI["Radius"])
local frame4=Instance["new"]("Frame")frame4["Size"]=UDim2["new"](0, 0, 0, 0)frame4["Position"]=UDim2["new"](.5, 0, .5, 0)frame4["AnchorPoint"]=Vector2["new"](.5, .5)frame4["BackgroundColor3"]=UI["Card"]frame4["BorderSizePixel"]=0 frame4["ClipsDescendants"]=true frame4["Parent"]=button2;
(Instance["new"]("UICorner", frame4))["CornerRadius"]=UDim["new"](0, UI["CardRadius"])
local stroke2=Instance["new"]("UIStroke", frame4)stroke2["Color"]=UI["Danger"]stroke2["Thickness"]=1.2 stroke2["Transparency"]=.2
local label2=Instance["new"]("TextLabel")label2["Size"]=UDim2["new"](1, 0, 0, 26)label2["Position"]=UDim2["new"](0, 0, 0, 12)label2["BackgroundTransparency"]=1 label2["Text"]="按键冲突"label2["TextColor3"]=UI["Danger"]label2["Font"]=Enum["Font"]["GothamBold"]label2["TextSize"]=14 label2["Parent"]=frame4
local function normalizedText(value)
local normalizedText2=(value:gsub("(%u)", " %1")):gsub("^%s*(.-)%s*$", "%1")
return normalizedText2
end
local label3=Instance["new"]("TextLabel")label3["Size"]=UDim2["new"](1, -24, 0, 60)label3["Position"]=UDim2["new"](0, 12, 0, 42)label3["BackgroundTransparency"]=1 label3["Text"]=string["format"]("The key '%s' is already bound to '%s'.\n\nChoose 'Replace Other' to bind it here, or 'Keep Other' to keep the existing setting.", title, normalizedText(confirmCallback))label3["TextColor3"]=UI["TextSub"]label3["Font"]=Enum["Font"]["GothamMedium"]label3["TextSize"]=11.5 label3["TextWrapped"]=true label3["TextXAlignment"]=Enum["TextXAlignment"]["Center"]label3["TextYAlignment"]=Enum["TextYAlignment"]["Top"]label3["Parent"]=frame4
local button3=Instance["new"]("TextButton")button3["Size"]=UDim2["new"](0, 120, 0, 26)button3["Position"]=UDim2["new"](.5, -125, 1, -38)button3["BackgroundColor3"]=UI["Accent"]button3["Text"]="替换原绑定"button3["TextColor3"]=Color3["fromRGB"](255, 255, 255)button3["Font"]=Enum["Font"]["GothamBold"]button3["TextSize"]=11.5 button3["AutoButtonColor"]=false button3["Parent"]=frame4;
(Instance["new"]("UICorner", button3))["CornerRadius"]=UDim["new"](0, 5)
local stroke3=Instance["new"]("UIStroke", button3)stroke3["Color"]=UI["Stroke"]stroke3["Thickness"]=.8
local button4=Instance["new"]("TextButton")button4["Size"]=UDim2["new"](0, 120, 0, 26)button4["Position"]=UDim2["new"](.5, 5, 1, -38)button4["BackgroundColor3"]=UI["Elevated"]button4["Text"]="保留原绑定"button4["TextColor3"]=UI["TextSub"]button4["Font"]=Enum["Font"]["GothamBold"]button4["TextSize"]=11.5 button4["AutoButtonColor"]=false button4["Parent"]=frame4;
(Instance["new"]("UICorner", button4))["CornerRadius"]=UDim["new"](0, 5)
local stroke4=Instance["new"]("UIStroke", button4)stroke4["Color"]=UI["Stroke"]stroke4["Thickness"]=.8;
(TweenService:Create(button2, TweenInfo["new"](.2, Enum["EasingStyle"]["Quad"], Enum["EasingDirection"]["Out"]), {["BackgroundTransparency"]=.4})):Play();
(TweenService:Create(frame4, TweenInfo["new"](.25, Enum["EasingStyle"]["Back"], Enum["EasingDirection"]["Out"]), {["Size"]=UDim2["new"](0, 320, 0, 150)})):Play()
local function updateVisualState(value)(TweenService:Create(button2, TweenInfo["new"](.18, Enum["EasingStyle"]["Quad"], Enum["EasingDirection"]["In"]), {["BackgroundTransparency"]=1})):Play();
(TweenService:Create(frame4, TweenInfo["new"](.18, Enum["EasingStyle"]["Quad"], Enum["EasingDirection"]["In"]), {["Size"]=UDim2["new"](0, 0, 0, 0)})):Play()task["wait"](.2)pcall(function()button2:Destroy()
end
)cancelCallback(value)
end
button3["MouseEnter"]:Connect(function()(TweenService:Create(button3, TweenInfo["new"](.15), {["BackgroundColor3"]=UI["HoverCard"]})):Play()
end
)button3["MouseLeave"]:Connect(function()(TweenService:Create(button3, TweenInfo["new"](.15), {["BackgroundColor3"]=UI["Accent"]})):Play()
end
)button4["MouseEnter"]:Connect(function()(TweenService:Create(button4, TweenInfo["new"](.15), {["BackgroundColor3"]=UI["HoverCard"], ["TextColor3"]=UI["Text"]})):Play()
end
)button4["MouseLeave"]:Connect(function()(TweenService:Create(button4, TweenInfo["new"](.15), {["BackgroundColor3"]=UI["Elevated"], ["TextColor3"]=UI["TextSub"]})):Play()
end
)button3["MouseButton1Click"]:Connect(function()updateVisualState("replace")
end
)button4["MouseButton1Click"]:Connect(function()updateVisualState("keep")
end
)
end
local function processValue3(value)
if not value then
return"None"
end
if type(value)=="string"and value:find("+")then
local items9={}
for key in value:gmatch("[^+]+")do
table["insert"](items9, processValue3(key))
end
return table["concat"](items9, " + ")
end
if value=="MouseButton1"then
return"M1"
end
if value=="MouseButton2"then
return"M2"
end
if value=="MouseButton3"then
return"M3"
end
if value=="ThumbButton1"then
return"M4"
end
if value=="ThumbButton2"then
return"M5"
end
if value=="LeftControl"then
return"LCtrl"
end
if value=="RightControl"then
return"RCtrl"
end
if value=="LeftShift"then
return"LShift"
end
if value=="RightShift"then
return"RShift"
end
if value=="LeftAlt"then
return"LAlt"
end
if value=="RightAlt"then
return"RAlt"
end
if value=="ButtonA"then
return"🎮 A"
end
if value=="ButtonB"then
return"🎮 B"
end
if value=="ButtonX"then
return"🎮 X"
end
if value=="ButtonY"then
return"🎮 Y"
end
if value=="ButtonL1"then
return"🎮 LB"
end
if value=="ButtonR1"then
return"🎮 RB"
end
if value=="ButtonL2"then
return"🎮 LT"
end
if value=="ButtonR2"then
return"🎮 RT"
end
if value=="ButtonL3"then
return"🎮 L3"
end
if value=="ButtonR3"then
return"🎮 R3"
end
if value=="ButtonSelect"then
return"🎮 Select"
end
if value=="ButtonStart"then
return"🎮 Start"
end
if value=="DPadUp"then
return"🎮 D-Up"
end
if value=="DPadDown"then
return"🎮 D-Down"
end
if value=="DPadLeft"then
return"🎮 D-Left"
end
if value=="DPadRight"then
return"🎮 D-Right"
end
return value
end
function createKeybindButton(parent, actionName, callback)
local conditionMet5=false
local button2=Instance["new"]("TextButton")button2["Size"]=UDim2["new"](0, 50, 0, 18)button2["BackgroundColor3"]=UI["Elevated"]button2["BackgroundTransparency"]=.2
if isMobileDevice then
button2["Text"]=settings["MobileButtons"]and settings["MobileButtons"][actionName]or"None"
else
button2["Text"]=processValue3(settings["Keybinds"]and settings["Keybinds"][actionName]or"None")
end
button2["TextColor3"]=UI["TextSub"]button2["Font"]=Enum["Font"]["Gotham"]button2["TextSize"]=10 button2["AutoButtonColor"]=false button2["Parent"]=parent;
(Instance["new"]("UICorner", button2))["CornerRadius"]=UDim["new"](0, 4)
local stroke2=Instance["new"]("UIStroke", button2)stroke2["Color"]=UI["Stroke"]stroke2["Thickness"]=.8
local function bindControlKey()
if isMobileDevice then
button2["Text"]=settings["MobileButtons"]and settings["MobileButtons"][actionName]or"None"
else
button2["Text"]=processValue3(settings["Keybinds"]and settings["Keybinds"][actionName]or"None")
end
end
keybindButtons[actionName]=bindControlKey button2["MouseButton1Click"]:Connect(function()
if isMobileDevice then
showMobileKeybindPrompt(actionName, function(value)
if not value or value:gsub("%s+", "")==""then
if settings["MobileButtons"]then
settings["MobileButtons"][actionName]=nil
end
if mobileFloatingButtons[actionName]then
pcall(function()mobileFloatingButtons[actionName]:Destroy()
end
)mobileFloatingButtons[actionName]=nil
end
showNotification("Button Removed", "Floating button removed.", "info")
else
local button3=value:sub(1, 6)
if settings["MobileButtons"]then
settings["MobileButtons"][actionName]=button3
end
createOrUpdateMobileFloatingButton(actionName, button3)showNotification("Button Setup", "Floating button '"..(button3.."' setup!"), "success")
end
pcall(saveSettings)bindControlKey()
end
)
return
end
if conditionMet5 then
return
end
if not keybindTipShown then
keybindTipShown=true pcall(showKeybindModal)
end
conditionMet5=true isBindingKey=true button2["Text"]="..."button2["TextColor3"]=UI["Accent"]
local items9={}
local cachedValue2=nil
local connection
local function updateTextVisual(value)
if cachedValue2 then
pcall(task["cancel"], cachedValue2)cachedValue2=nil
end
if connection then
connection:Disconnect()connection=nil
end
local combinedText=table["concat"](value, "+")
local conditionMet6=(#value==1)
local currentValue3=value[1]
if conditionMet6 and((currentValue3=="Escape"or currentValue3=="Backspace"or currentValue3=="Delete"))then
if settings["Keybinds"]then
settings["Keybinds"][actionName]="None"
end
conditionMet5=false task["defer"](function()isBindingKey=false
end
)bindControlKey()button2["TextColor3"]=UI["TextSub"]pcall(saveSettings)
return
end
local conflictingBinding=nil
if settings["Keybinds"]then
for key, item in pairs(settings["Keybinds"])do
if key~=actionName and item==combinedText then
conflictingBinding=key
break
end
end
end
if conflictingBinding then
task["defer"](function()isBindingKey=false
end
)showConflictModal(combinedText, actionName, conflictingBinding, function(value2)
if value2=="replace"then
if settings["Keybinds"]then
settings["Keybinds"][conflictingBinding]="None"settings["Keybinds"][actionName]=combinedText
end
if keybindButtons[conflictingBinding]then
keybindButtons[conflictingBinding]()
end
showNotification("Keybind Conflict", "Replaced other keybind successfully.", "success")
else
if settings["Keybinds"]then
settings["Keybinds"][actionName]="None"
end
end
conditionMet5=false bindControlKey()button2["TextColor3"]=UI["TextSub"]pcall(saveSettings)
end
)
else
if settings["Keybinds"]then
settings["Keybinds"][actionName]=combinedText
end
conditionMet5=false task["defer"](function()isBindingKey=false
end
)bindControlKey()button2["TextColor3"]=UI["TextSub"]pcall(saveSettings)
end
end
connection=UserInputService["InputBegan"]:Connect(function(input)
local conditionMet6=(input["UserInputType"]==Enum["UserInputType"]["Gamepad1"]or input["UserInputType"]==Enum["UserInputType"]["Gamepad2"]or input["UserInputType"]==Enum["UserInputType"]["Gamepad3"]or input["UserInputType"]==Enum["UserInputType"]["Gamepad4"])
local conditionMet7=input["UserInputType"]==Enum["UserInputType"]["Keyboard"]or conditionMet6
local conditionMet8=input["UserInputType"]==Enum["UserInputType"]["MouseButton3"]
if conditionMet7 or conditionMet8 then
local name2=conditionMet7 and input["KeyCode"]["Name"]or input["UserInputType"]["Name"]
if name2~="Unknown"and name2~="None"then
if not table["find"](items9, name2)then
table["insert"](items9, name2)
end
button2["Text"]=processValue3(table["concat"](items9, "+"))
if#items9==1 then
if cachedValue2 then
pcall(task["cancel"], cachedValue2)
end
cachedValue2=task["delay"](.5, function()
if conditionMet5 then
updateTextVisual(items9)
end
end
)
elseif#items9>=2 then
updateTextVisual(items9)
end
end
end
end
)
end
)button2["MouseButton2Click"]:Connect(function()
if conditionMet5 then
return
end
if settings["Keybinds"]then
settings["Keybinds"][actionName]="None"
end
bindControlKey()pcall(saveSettings)showNotification("Keybind Reset", "Keybind reset successfully.", "info")
end
)
local items9={["InstantEscape"]="Instant Escape", ["CancelGen"]="Generator Buff", ["NoclipVaultsPallets"]="Noclip Vaults & Pallets", ["RevolverAutofarm"]="Enable Revolver Autofarm [BETA]", ["InstantHeal"]="Instant Heal", ["InstantBandage"]="Instant Bandage";
["BlockVaultPalletInteraction"]="Block/Unlock Vaults & Pallets", ["BlockVaults"]="Block Vaults";
["BlockPallets"]="Block Pallets", ["UnlockVaults"]="Unlock Vaults";
["UnlockPallets"]="Unlock Pallets";
["AutoFleeKiller"]="Auto Flee Killer (Dist < 35)", ["AutoSkillCheck"]="Auto Skill Check";
["InstantSkillCheck"]="Instant Skill Check", ["AntiWiggle"]="Anti Wiggle";
["FrenzyParry"]="Ignore Frenzy Killer";
["SimulateParryAnimation"]="Simulate Parry Animation", ["AutoDodge"]="Auto Dodge", ["NoCooldownStalker"]="No Cooldown Stalker";
["KillGrab"]="Kill Grab", ["SpearTrajectory"]="Spear Trajectory", ["SpearAimbot"]="Spear Aimbot", ["SpearSilentAim"]="Spear Silent Aim", ["RevolverSilentAim"]="Revolver Silent Aim", ["Masked_Richter"]="MASKED - Richter";
["Masked_Alex"]="MASKED - Alex";
["Masked_Brandon"]="MASKED - Brandon";
["Masked_Rabbit"]="MASKED - Rabbit";
["Masked_Cobra"]="MASKED - Cobra";
["Masked_Tony"]="MASKED - Tony", ["Masked_Normal"]="MASKED - Normal";
["InfiniteLunge"]="Infinite Lunge"}
local currentValue3=items9[actionName]actionHandlers[actionName]=function(...)
if currentValue3 and not isFeatureAvailable()then
showNotification("Feature", "Feature unavailable.", "warning")
return
end
return callback(...)
end
return button2
end
function createToggle(parent, labelText, defaultValue, callback, accentColor, keybindId)
labelText=translateText(labelText)
local text=isPremiumFeature(labelText)
local text2=labelText
if not isFeatureAvailable()and text then
text2=labelText.." <font color=\"#FF2A6D\">[👑]</font>"
end
local cachedValue2=nil
if accentColor==nil or accentColor==UI["Accent"]then
cachedValue2="Accent"
elseif accentColor==UI["AccentCyan"]then
cachedValue2="AccentCyan"
elseif accentColor==UI["AccentGreen"]then
cachedValue2="AccentGreen"
elseif accentColor==UI["AccentRed"]then
cachedValue2="AccentRed"
end
local function processValue4()
if cachedValue2 and UI[cachedValue2]then
return UI[cachedValue2]
end
return accentColor or UI["Accent"]
end
local currentValue3=processValue4()
local frame4=Instance["new"]("Frame")frame4["Size"]=UDim2["new"](1, 0, 0, 30)frame4["BackgroundColor3"]=UI["Card"]frame4["BackgroundTransparency"]=.9 frame4["BorderSizePixel"]=0 frame4["Parent"]=parent;
(Instance["new"]("UICorner", frame4))["CornerRadius"]=UDim["new"](0, UI["CardRadius"])
local stroke2=Instance["new"]("UIStroke", frame4)stroke2["Color"]=UI["StrokeDim"]stroke2["Thickness"]=.8 frame4["MouseEnter"]:Connect(function()(TweenService:Create(stroke2, TweenInfo["new"](.2), {["Color"]=UI["Stroke"];
["Thickness"]=1})):Play();
(TweenService:Create(frame4, TweenInfo["new"](.2), {["BackgroundTransparency"]=.305})):Play()
end
)frame4["MouseLeave"]:Connect(function()(TweenService:Create(stroke2, TweenInfo["new"](.2), {["Color"]=UI["StrokeDim"], ["Thickness"]=.8})):Play();
(TweenService:Create(frame4, TweenInfo["new"](.2), {["BackgroundTransparency"]=.9})):Play()
end
)
local conditionMet5=keybindId~=nil
local button2=Instance["new"]("TextButton")button2["Size"]=UDim2["new"](0, 16, 0, 16)button2["Position"]=UDim2["new"](0, 8, .5, -8)button2["BackgroundColor3"]=defaultValue and currentValue3 or UI["Elevated"]button2["BackgroundTransparency"]=defaultValue and 0 or.6 button2["Text"]=defaultValue and"✓"or""button2["TextColor3"]=Color3["fromRGB"](255, 255, 255)button2["Font"]=Enum["Font"]["GothamBold"]button2["TextSize"]=11 button2["AutoButtonColor"]=false button2["Parent"]=frame4;
(Instance["new"]("UICorner", button2))["CornerRadius"]=UDim["new"](0, 4)
local stroke3=Instance["new"]("UIStroke", button2)stroke3["Color"]=defaultValue and currentValue3 or UI["Stroke"]stroke3["Thickness"]=.9
local label2=Instance["new"]("TextLabel")label2["RichText"]=true label2["Size"]=conditionMet5 and UDim2["new"](1, -110, 1, 0)or UDim2["new"](1, -38, 1, 0)label2["Position"]=UDim2["new"](0, 32, 0, 0)label2["BackgroundTransparency"]=1 label2["Text"]=text2 label2["TextColor3"]=UI["Text"]label2["Font"]=Enum["Font"]["GothamSemibold"]label2["TextSize"]=12.5 label2["TextXAlignment"]=Enum["TextXAlignment"]["Left"]label2["Parent"]=frame4
local text3=defaultValue
local function updateVisualState(value, contextValue)text3=value
local tween=processValue4();
(TweenService:Create(button2, TweenInfo["new"](.15, Enum["EasingStyle"]["Quad"]), {["BackgroundColor3"]=text3 and tween or UI["Elevated"];
["BackgroundTransparency"]=text3 and 0 or.6})):Play()button2["Text"]=text3 and"✓"or"";
(TweenService:Create(stroke3, TweenInfo["new"](.15), {["Color"]=text3 and tween or UI["Stroke"]})):Play()
if contextValue and callback then
pcall(callback, value)
end
end
local function getFeatureState3()
if not isFeatureAvailable()and text then
showNotification("Feature", "Feature unavailable.", "warning")updateVisualState(false)
return
end
local conditionMet6=not text3 updateVisualState(conditionMet6)
if callback then
pcall(callback, conditionMet6)
end
if settings["ShowToggleNotifications"]then
local toggleStateText=conditionMet6 and"ENABLED"or"DISABLED"
local notificationType=conditionMet6 and"success"or"warning"showNotification(labelText, "Toggled: "..toggleStateText, notificationType)
end
end
if keybindId and keybindId~=""then
actionHandlers[keybindId]=getFeatureState3
end
local normalizedText=((labelText:gsub("<[^>]+>", "")):gsub("%s*%b()", "")):gsub("^%s*(.-)%s*$", "%1")
if normalizedText~=""then
actionHandlers[normalizedText]=getFeatureState3 actionHandlers[normalizedText:gsub("%s+", "")]=getFeatureState3
end
button2["MouseButton1Click"]:Connect(getFeatureState3)
local button3=Instance["new"]("TextButton")button3["Size"]=UDim2["new"](1, conditionMet5 and-80 or 0, 1, 0)button3["BackgroundTransparency"]=1 button3["Text"]=""button3["Parent"]=frame4 button3["MouseButton1Click"]:Connect(getFeatureState3)
if conditionMet5 then
local layoutPosition=createKeybindButton(frame4, keybindId, getFeatureState3)layoutPosition["Position"]=UDim2["new"](1, -74, .5, -9)
end
return{["setValue"]=updateVisualState}
end
function createButton(parent, labelText, buttonText, callback, accentColor, keybindId)
labelText=translateText(labelText)
buttonText=translateText(buttonText)
local text=isPremiumFeature(labelText)
local text2=labelText
if not isFeatureAvailable()and text then
text2=labelText.." <font color=\"#FF2A6D\">[👑]</font>"
end
local cachedValue2=nil
if accentColor==nil or accentColor==UI["Accent"]then
cachedValue2="Accent"
elseif accentColor==UI["AccentCyan"]then
cachedValue2="AccentCyan"
elseif accentColor==UI["AccentGreen"]then
cachedValue2="AccentGreen"
elseif accentColor==UI["AccentRed"]then
cachedValue2="AccentRed"
end
local function processValue4()
if cachedValue2 and UI[cachedValue2]then
return UI[cachedValue2]
end
return accentColor or UI["Accent"]
end
local currentValue3=processValue4()
local frame4=Instance["new"]("Frame")frame4["Size"]=UDim2["new"](1, 0, 0, 32)frame4["BackgroundColor3"]=UI["Card"]frame4["BackgroundTransparency"]=.42 frame4["BorderSizePixel"]=0 frame4["Parent"]=parent;
(Instance["new"]("UICorner", frame4))["CornerRadius"]=UDim["new"](0, UI["CardRadius"])
local stroke2=Instance["new"]("UIStroke", frame4)stroke2["Color"]=UI["StrokeDim"]stroke2["Thickness"]=.8 frame4["MouseEnter"]:Connect(function()(TweenService:Create(stroke2, TweenInfo["new"](.2), {["Color"]=UI["Stroke"];
["Thickness"]=1.1})):Play();
(TweenService:Create(frame4, TweenInfo["new"](.2), {["BackgroundTransparency"]=.30})):Play()
end
)frame4["MouseLeave"]:Connect(function()(TweenService:Create(stroke2, TweenInfo["new"](.2), {["Color"]=UI["StrokeDim"], ["Thickness"]=.8})):Play();
(TweenService:Create(frame4, TweenInfo["new"](.2), {["BackgroundTransparency"]=.42})):Play()
end
)
local conditionMet5=keybindId~=nil
local label2=Instance["new"]("TextLabel")label2["RichText"]=true label2["Size"]=conditionMet5 and UDim2["new"](1, -170, 1, 0)or UDim2["new"](.5, 0, 1, 0)label2["Position"]=UDim2["new"](0, 10, 0, 0)label2["BackgroundTransparency"]=1 label2["Text"]=text2 label2["TextColor3"]=UI["Text"]label2["Font"]=Enum["Font"]["GothamSemibold"]label2["TextSize"]=13 label2["TextXAlignment"]=Enum["TextXAlignment"]["Left"]label2["Parent"]=frame4
local frame5=Instance["new"]("Frame")frame5["Size"]=UDim2["new"](0, 96, 0, 20)frame5["Position"]=UDim2["new"](1, -106, .5, -10)frame5["BackgroundColor3"]=currentValue3 frame5["BorderSizePixel"]=0 frame5["Parent"]=frame4;
(Instance["new"]("UICorner", frame5))["CornerRadius"]=UDim["new"](0, 5)
local stroke3=Instance["new"]("UIStroke", frame5)stroke3["Color"]=UI["Stroke"]:Lerp(currentValue3, .5)stroke3["Thickness"]=.8
local button2=Instance["new"]("TextButton")button2["Size"]=UDim2["new"](1, 0, 1, 0)button2["BackgroundTransparency"]=1 button2["Text"]=((buttonText or"TRIGGER")):upper()button2["TextColor3"]=Color3["fromRGB"](255, 255, 255)button2["Font"]=Enum["Font"]["GothamBold"]button2["TextSize"]=11 button2["AutoButtonColor"]=false button2["Parent"]=frame5 button2["MouseEnter"]:Connect(function()
local tween=processValue4();
(TweenService:Create(frame5, TweenInfo["new"](.15), {["BackgroundColor3"]=tween:Lerp(Color3["fromRGB"](255, 255, 255), .15)})):Play()
end
)button2["MouseLeave"]:Connect(function()
local tween=processValue4();
(TweenService:Create(frame5, TweenInfo["new"](.15), {["BackgroundColor3"]=tween})):Play()
end
)
local connection=function()
if not isFeatureAvailable()and text then
showNotification("Feature", "Feature unavailable.", "warning")
return
end
pcall(callback)
end
if keybindId and keybindId~=""then
actionHandlers[keybindId]=connection
end
local normalizedText=((labelText:gsub("<[^>]+>", "")):gsub("%s*%b()", "")):gsub("^%s*(.-)%s*$", "%1")
if normalizedText~=""then
actionHandlers[normalizedText]=connection actionHandlers[normalizedText:gsub("%s+", "")]=connection
end
button2["MouseButton1Click"]:Connect(connection)
if conditionMet5 then
local layoutPosition=createKeybindButton(frame4, keybindId, connection)layoutPosition["Position"]=UDim2["new"](1, -164, .5, -9)
end
return frame4
end
function createSubToggle(parent, labelText, defaultValue, callback)
labelText=translateText(labelText)
local text=isPremiumFeature(labelText)
local text2=labelText
if not isFeatureAvailable()and text then
text2=labelText.." <font color=\"#FF2A6D\">[👑]</font>"
end
local frame4=Instance["new"]("Frame")frame4["Size"]=UDim2["new"](1, 0, 0, 24)frame4["BackgroundTransparency"]=1 frame4["BorderSizePixel"]=0 frame4["Parent"]=parent
local frame5=Instance["new"]("Frame")frame5["Size"]=UDim2["new"](0, 1, .5, 0)frame5["Position"]=UDim2["new"](0, 14, .25, 0)frame5["BackgroundColor3"]=UI["Stroke"]frame5["BorderSizePixel"]=0 frame5["Parent"]=frame4
local label2=Instance["new"]("TextLabel")label2["RichText"]=true label2["Size"]=UDim2["new"](1, -68, 1, 0)label2["Position"]=UDim2["new"](0, 22, 0, 0)label2["BackgroundTransparency"]=1 label2["Text"]=text2 label2["TextColor3"]=UI["TextSub"]label2["Font"]=Enum["Font"]["Gotham"]label2["TextSize"]=12.5 label2["TextXAlignment"]=Enum["TextXAlignment"]["Left"]label2["Parent"]=frame4
local button2=Instance["new"]("TextButton")button2["Size"]=UDim2["new"](0, 28, 0, 14)button2["Position"]=UDim2["new"](1, -38, .5, -7)button2["BackgroundColor3"]=defaultValue and UI["Accent"]or UI["Elevated"]button2["Text"]=""button2["AutoButtonColor"]=false button2["Parent"]=frame4;
(Instance["new"]("UICorner", button2))["CornerRadius"]=UDim["new"](1, 0)
local frame6=Instance["new"]("Frame")frame6["Size"]=UDim2["new"](0, 10, 0, 10)frame6["Position"]=defaultValue and UDim2["new"](1, -12, .5, -5)or UDim2["new"](0, 2, .5, -5)frame6["BackgroundColor3"]=Color3["fromRGB"](220, 220, 240)frame6["BorderSizePixel"]=0 frame6["Parent"]=button2;
(Instance["new"]("UICorner", frame6))["CornerRadius"]=UDim["new"](1, 0)
local tween=defaultValue
local function tween2(value)tween=value;
(TweenService:Create(button2, TweenInfo["new"](.15, Enum["EasingStyle"]["Quad"]), {["BackgroundColor3"]=tween and UI["Accent"]or UI["Elevated"]})):Play();
(TweenService:Create(frame6, TweenInfo["new"](.15, Enum["EasingStyle"]["Quad"]), {["Position"]=tween and UDim2["new"](1, -12, .5, -5)or UDim2["new"](0, 2, .5, -5)})):Play()
end
button2["MouseButton1Click"]:Connect(function()
if not isFeatureAvailable()and text then
showNotification("Feature", "Feature unavailable.", "warning")tween2(false)
return
end
tween2(not tween)callback(tween)
end
)
return{["setValue"]=tween2}
end
function createCollapsibleGroup(parent, title, expandedByDefault)
title=translateText(title)
local text=isPremiumFeature(title)
local text2=title
if not isFeatureAvailable()and text then
text2=title.." <font color=\"#FF2A6D\">[👑]</font>"
end
local cachedValue2=nil
if expandedByDefault==nil or expandedByDefault==UI["Accent"]then
cachedValue2="Accent"
elseif expandedByDefault==UI["AccentCyan"]then
cachedValue2="AccentCyan"
elseif expandedByDefault==UI["AccentGreen"]then
cachedValue2="AccentGreen"
elseif expandedByDefault==UI["AccentRed"]then
cachedValue2="AccentRed"
end
local function processValue4()
if cachedValue2 and UI[cachedValue2]then
return UI[cachedValue2]
end
return expandedByDefault or UI["Accent"]
end
local currentValue3=processValue4()
local frame4=Instance["new"]("Frame")frame4["Size"]=UDim2["new"](1, 0, 0, 0)frame4["BackgroundTransparency"]=1 frame4["AutomaticSize"]=Enum["AutomaticSize"]["Y"]frame4["BorderSizePixel"]=0 frame4["Parent"]=parent
local listLayout=Instance["new"]("UIListLayout")listLayout["SortOrder"]=Enum["SortOrder"]["LayoutOrder"]listLayout["Padding"]=UDim["new"](0, 4)listLayout["Parent"]=frame4
local button2=Instance["new"]("TextButton")button2["Size"]=UDim2["new"](1, 0, 0, 32)button2["BackgroundTransparency"]=1 button2["BorderSizePixel"]=0 button2["Text"]=""button2["AutoButtonColor"]=false button2["LayoutOrder"]=1 button2["Parent"]=frame4
local frame5=Instance["new"]("Frame")frame5["Size"]=UDim2["new"](1, 0, 1, 0)frame5["Position"]=UDim2["new"](.5, 0, .5, 0)frame5["AnchorPoint"]=Vector2["new"](.5, .5)frame5["BackgroundColor3"]=UI["Card"]frame5["BackgroundTransparency"]=.42 frame5["BorderSizePixel"]=0 frame5["Parent"]=button2
local corner=Instance["new"]("UICorner", frame5)corner["CornerRadius"]=UDim["new"](0, UI["CardRadius"])
local stroke2=Instance["new"]("UIStroke", frame5)stroke2["Color"]=UI["StrokeDim"]stroke2["Thickness"]=.8 button2["MouseEnter"]:Connect(function()(TweenService:Create(stroke2, TweenInfo["new"](.2), {["Color"]=UI["Stroke"], ["Thickness"]=1.1})):Play();
(TweenService:Create(frame5, TweenInfo["new"](.2), {["BackgroundTransparency"]=.30})):Play()
end
)button2["MouseLeave"]:Connect(function()(TweenService:Create(stroke2, TweenInfo["new"](.2), {["Color"]=UI["StrokeDim"];
["Thickness"]=.8})):Play();
(TweenService:Create(frame5, TweenInfo["new"](.2), {["BackgroundTransparency"]=.42})):Play()
end
)
local label2=Instance["new"]("TextLabel")label2["Size"]=UDim2["new"](0, 16, 0, 16)label2["Position"]=UDim2["new"](0, 14, .5, 0)label2["AnchorPoint"]=Vector2["new"](.5, .5)label2["BackgroundTransparency"]=1 label2["Text"]="▶"label2["TextColor3"]=UI["TextSub"]label2["Font"]=Enum["Font"]["GothamBold"]label2["TextSize"]=8 label2["Parent"]=frame5
local label3=Instance["new"]("TextLabel")label3["RichText"]=true label3["Size"]=UDim2["new"](1, -40, 1, 0)label3["Position"]=UDim2["new"](0, 26, 0, 0)label3["BackgroundTransparency"]=1 label3["Text"]=text2 label3["TextColor3"]=UI["Text"]label3["Font"]=Enum["Font"]["GothamSemibold"]label3["TextSize"]=13 label3["TextXAlignment"]=Enum["TextXAlignment"]["Left"]label3["Parent"]=frame5
local frame6=Instance["new"]("Frame")frame6["Size"]=UDim2["new"](1, 0, 0, 0)frame6["BackgroundTransparency"]=1 frame6["BorderSizePixel"]=0 frame6["ClipsDescendants"]=true frame6["LayoutOrder"]=2 frame6["Parent"]=frame4
local listLayout2=Instance["new"]("UIListLayout")listLayout2["SortOrder"]=Enum["SortOrder"]["LayoutOrder"]listLayout2["Padding"]=UDim["new"](0, 4)listLayout2["Parent"]=frame6
local padding=Instance["new"]("UIPadding")padding["PaddingLeft"]=UDim["new"](0, 14)padding["PaddingRight"]=UDim["new"](0, 2)padding["Parent"]=frame6
local layoutPosition=false;
(listLayout2:GetPropertyChangedSignal("AbsoluteContentSize")):Connect(function()
if layoutPosition then
frame6["Size"]=UDim2["new"](1, 0, 0, listLayout2["AbsoluteContentSize"]["Y"])
end
end
)
local function updateExpandState(value)
if value==nil then
layoutPosition=not layoutPosition
else
layoutPosition=value
end
local tween=processValue4();
(TweenService:Create(label2, TweenInfo["new"](.2, Enum["EasingStyle"]["Quad"], Enum["EasingDirection"]["Out"]), {["Rotation"]=layoutPosition and 90 or 0, ["TextColor3"]=layoutPosition and tween or UI["TextSub"]})):Play();
(TweenService:Create(frame5, TweenInfo["new"](.2, Enum["EasingStyle"]["Quad"], Enum["EasingDirection"]["Out"]), {["BackgroundTransparency"]=layoutPosition and.7 or.8})):Play();
(TweenService:Create(stroke2, TweenInfo["new"](.2, Enum["EasingStyle"]["Quad"], Enum["EasingDirection"]["Out"]), {["Color"]=layoutPosition and tween or UI["StrokeDim"]})):Play()
local tween2=layoutPosition and listLayout2["AbsoluteContentSize"]["Y"]or 0;
(TweenService:Create(frame6, TweenInfo["new"](.22, Enum["EasingStyle"]["Quad"], Enum["EasingDirection"]["Out"]), {["Size"]=UDim2["new"](1, 0, 0, tween2)})):Play()
end
button2["MouseButton1Click"]:Connect(function()
if not isFeatureAvailable()and text then
showNotification("Feature", "Feature unavailable.", "warning")
return
end
updateExpandState()
end
)
return{["content"]=frame6, ["toggleExpand"]=updateExpandState}
end
function createCollapsibleToggle(parent, labelText, defaultValue, callback, accentColor, keybindId)
labelText=translateText(labelText)
local text=isPremiumFeature(labelText)
local text2=labelText
if not isFeatureAvailable()and text then
text2=labelText.." <font color=\"#FF2A6D\">[👑]</font>"
end
local cachedValue2=nil
if accentColor==nil or accentColor==UI["Accent"]then
cachedValue2="Accent"
elseif accentColor==UI["AccentCyan"]then
cachedValue2="AccentCyan"
elseif accentColor==UI["AccentGreen"]then
cachedValue2="AccentGreen"
elseif accentColor==UI["AccentRed"]then
cachedValue2="AccentRed"
end
local function processValue4()
if cachedValue2 and UI[cachedValue2]then
return UI[cachedValue2]
end
return accentColor or UI["Accent"]
end
local currentValue3=processValue4()
local frame4=Instance["new"]("Frame")frame4["Size"]=UDim2["new"](1, 0, 0, 0)frame4["BackgroundTransparency"]=1 frame4["AutomaticSize"]=Enum["AutomaticSize"]["Y"]frame4["BorderSizePixel"]=0 frame4["Parent"]=parent
local listLayout=Instance["new"]("UIListLayout")listLayout["SortOrder"]=Enum["SortOrder"]["LayoutOrder"]listLayout["Padding"]=UDim["new"](0, 4)listLayout["Parent"]=frame4
local button2=Instance["new"]("TextButton")button2["Size"]=UDim2["new"](1, 0, 0, 32)button2["BackgroundTransparency"]=1 button2["BorderSizePixel"]=0 button2["Text"]=""button2["AutoButtonColor"]=false button2["LayoutOrder"]=1 button2["Parent"]=frame4
local frame5=Instance["new"]("Frame")frame5["Size"]=UDim2["new"](1, 0, 1, 0)frame5["Position"]=UDim2["new"](.5, 0, .5, 0)frame5["AnchorPoint"]=Vector2["new"](.5, .5)frame5["BackgroundColor3"]=UI["Card"]frame5["BackgroundTransparency"]=.42 frame5["BorderSizePixel"]=0 frame5["Parent"]=button2
local corner=Instance["new"]("UICorner", frame5)corner["CornerRadius"]=UDim["new"](0, UI["CardRadius"])
local stroke2=Instance["new"]("UIStroke", frame5)stroke2["Color"]=UI["StrokeDim"]stroke2["Thickness"]=.8 button2["MouseEnter"]:Connect(function()(TweenService:Create(stroke2, TweenInfo["new"](.2), {["Color"]=UI["Stroke"], ["Thickness"]=1.1})):Play();
(TweenService:Create(frame5, TweenInfo["new"](.2), {["BackgroundTransparency"]=.30})):Play()
end
)button2["MouseLeave"]:Connect(function()(TweenService:Create(stroke2, TweenInfo["new"](.2), {["Color"]=UI["StrokeDim"], ["Thickness"]=.8})):Play();
(TweenService:Create(frame5, TweenInfo["new"](.2), {["BackgroundTransparency"]=.42})):Play()
end
)
local uiScale=Instance["new"]("UIScale", frame5)uiScale["Scale"]=1
local label2=Instance["new"]("TextLabel")label2["Size"]=UDim2["new"](0, 16, 0, 16)label2["Position"]=UDim2["new"](0, 14, .5, 0)label2["AnchorPoint"]=Vector2["new"](.5, .5)label2["BackgroundTransparency"]=1 label2["Text"]="▶"label2["TextColor3"]=UI["TextSub"]label2["Font"]=Enum["Font"]["GothamBold"]label2["TextSize"]=8 label2["Parent"]=frame5
local hasParent=keybindId~=nil
local label3=Instance["new"]("TextLabel")label3["RichText"]=true label3["Size"]=hasParent and UDim2["new"](1, -134, 1, 0)or UDim2["new"](1, -74, 1, 0)label3["Position"]=UDim2["new"](0, 26, 0, 0)label3["BackgroundTransparency"]=1 label3["Text"]=text2 label3["TextColor3"]=UI["Text"]label3["Font"]=Enum["Font"]["GothamSemibold"]label3["TextSize"]=13 label3["TextXAlignment"]=Enum["TextXAlignment"]["Left"]label3["Parent"]=frame5
local button3=Instance["new"]("TextButton")button3["Size"]=UDim2["new"](0, 34, 0, 18)button3["Position"]=UDim2["new"](1, -44, .5, -9)button3["BackgroundColor3"]=defaultValue and currentValue3 or UI["Elevated"]button3["Text"]=""button3["AutoButtonColor"]=false button3["Parent"]=frame5;
(Instance["new"]("UICorner", button3))["CornerRadius"]=UDim["new"](1, 0)
local stroke3=Instance["new"]("UIStroke", button3)stroke3["Color"]=defaultValue and currentValue3 or UI["Stroke"]stroke3["Thickness"]=1
local frame6=Instance["new"]("Frame")frame6["Size"]=UDim2["new"](0, 12, 0, 12)frame6["Position"]=defaultValue and UDim2["new"](1, -15, .5, -6)or UDim2["new"](0, 3, .5, -6)frame6["BackgroundColor3"]=Color3["fromRGB"](255, 255, 255)frame6["BorderSizePixel"]=0 frame6["Parent"]=button3;
(Instance["new"]("UICorner", frame6))["CornerRadius"]=UDim["new"](1, 0)
local frame7=Instance["new"]("Frame")frame7["Size"]=UDim2["new"](1, 0, 0, 0)frame7["BackgroundTransparency"]=1 frame7["BorderSizePixel"]=0 frame7["ClipsDescendants"]=true frame7["LayoutOrder"]=2 frame7["Parent"]=frame4
local listLayout2=Instance["new"]("UIListLayout")listLayout2["SortOrder"]=Enum["SortOrder"]["LayoutOrder"]listLayout2["Padding"]=UDim["new"](0, 4)listLayout2["Parent"]=frame7
local padding=Instance["new"]("UIPadding")padding["PaddingLeft"]=UDim["new"](0, 14)padding["PaddingRight"]=UDim["new"](0, 2)padding["Parent"]=frame7
local conditionMet5=false
local function updateExpandState(value)
if value==nil then
conditionMet5=not conditionMet5
else
conditionMet5=value
end
local tween=processValue4();
(TweenService:Create(label2, TweenInfo["new"](.2, Enum["EasingStyle"]["Quad"], Enum["EasingDirection"]["Out"]), {["Rotation"]=conditionMet5 and 90 or 0;
["TextColor3"]=conditionMet5 and tween or UI["TextSub"]})):Play();
(TweenService:Create(frame5, TweenInfo["new"](.2, Enum["EasingStyle"]["Quad"], Enum["EasingDirection"]["Out"]), {["BackgroundTransparency"]=conditionMet5 and.7 or.8})):Play();
(TweenService:Create(stroke2, TweenInfo["new"](.2, Enum["EasingStyle"]["Quad"], Enum["EasingDirection"]["Out"]), {["Color"]=conditionMet5 and tween or UI["StrokeDim"]})):Play()
local tween2=conditionMet5 and listLayout2["AbsoluteContentSize"]["Y"]or 0;
(TweenService:Create(frame7, TweenInfo["new"](.22, Enum["EasingStyle"]["Quad"], Enum["EasingDirection"]["Out"]), {["Size"]=UDim2["new"](1, 0, 0, tween2)})):Play()
end
button2["MouseButton1Click"]:Connect(function()
if not isFeatureAvailable()and text then
showNotification("Feature", "Feature unavailable.", "warning")
return
end
updateExpandState()
end
)button2["MouseEnter"]:Connect(function()(TweenService:Create(frame5, TweenInfo["new"](.15, Enum["EasingStyle"]["Quad"], Enum["EasingDirection"]["Out"]), {["BackgroundTransparency"]=conditionMet5 and.6 or.7})):Play()
if not conditionMet5 then
(TweenService:Create(stroke2, TweenInfo["new"](.15, Enum["EasingStyle"]["Quad"], Enum["EasingDirection"]["Out"]), {["Color"]=UI["Stroke"], ["Thickness"]=1.1})):Play()
end
end
)button2["MouseLeave"]:Connect(function()
local tween=processValue4();
(TweenService:Create(frame5, TweenInfo["new"](.15, Enum["EasingStyle"]["Quad"], Enum["EasingDirection"]["Out"]), {["BackgroundTransparency"]=conditionMet5 and.7 or.8})):Play();
(TweenService:Create(stroke2, TweenInfo["new"](.15, Enum["EasingStyle"]["Quad"], Enum["EasingDirection"]["Out"]), {["Color"]=conditionMet5 and tween or UI["StrokeDim"];
["Thickness"]=.8})):Play();
(TweenService:Create(uiScale, TweenInfo["new"](.15, Enum["EasingStyle"]["Quad"], Enum["EasingDirection"]["Out"]), {["Scale"]=1})):Play()
end
)button2["InputBegan"]:Connect(function(input)
if input["UserInputType"]==Enum["UserInputType"]["MouseButton1"]or input["UserInputType"]==Enum["UserInputType"]["Touch"]then
(TweenService:Create(uiScale, TweenInfo["new"](.08, Enum["EasingStyle"]["Quad"], Enum["EasingDirection"]["Out"]), {["Scale"]=.96})):Play()
end
end
)button2["InputEnded"]:Connect(function(input)
if input["UserInputType"]==Enum["UserInputType"]["MouseButton1"]or input["UserInputType"]==Enum["UserInputType"]["Touch"]then
(TweenService:Create(uiScale, TweenInfo["new"](.15, Enum["EasingStyle"]["Quad"], Enum["EasingDirection"]["Out"]), {["Scale"]=1})):Play()
end
end
);
(listLayout2:GetPropertyChangedSignal("AbsoluteContentSize")):Connect(function()
if conditionMet5 then
frame7["Size"]=UDim2["new"](1, 0, 0, listLayout2["AbsoluteContentSize"]["Y"])
end
end
)
local function processValue5(value, color, callback2)
local currentValue4=isPremiumFeature(value)
local text3=value
if not isFeatureAvailable()and currentValue4 then
text3=value.." <font color=\"#FF2A6D\">[👑]</font>"
end
local frame8=Instance["new"]("Frame")frame8["Size"]=UDim2["new"](1, 0, 0, 24)frame8["BackgroundTransparency"]=1 frame8["BorderSizePixel"]=0 frame8["Parent"]=frame7
local frame9=Instance["new"]("Frame")frame9["Size"]=UDim2["new"](0, 1, .5, 0)frame9["Position"]=UDim2["new"](0, 14, .25, 0)frame9["BackgroundColor3"]=UI["Stroke"]frame9["BorderSizePixel"]=0 frame9["Parent"]=frame8
local label4=Instance["new"]("TextLabel")label4["RichText"]=true label4["Size"]=UDim2["new"](1, -68, 1, 0)label4["Position"]=UDim2["new"](0, 22, 0, 0)label4["BackgroundTransparency"]=1 label4["Text"]=text3 label4["TextColor3"]=UI["TextSub"]label4["Font"]=Enum["Font"]["Gotham"]label4["TextSize"]=12.5 label4["TextXAlignment"]=Enum["TextXAlignment"]["Left"]label4["Parent"]=frame8
local button4=Instance["new"]("TextButton")button4["Size"]=UDim2["new"](0, 28, 0, 14)button4["Position"]=UDim2["new"](1, -38, .5, -7)button4["BackgroundColor3"]=color and UI["Accent"]or UI["Elevated"]button4["Text"]=""button4["AutoButtonColor"]=false button4["Parent"]=frame8;
(Instance["new"]("UICorner", button4))["CornerRadius"]=UDim["new"](1, 0)
local frame10=Instance["new"]("Frame")frame10["Size"]=UDim2["new"](0, 10, 0, 10)frame10["Position"]=color and UDim2["new"](1, -12, .5, -5)or UDim2["new"](0, 2, .5, -5)frame10["BackgroundColor3"]=Color3["fromRGB"](220, 220, 240)frame10["BorderSizePixel"]=0 frame10["Parent"]=button4;
(Instance["new"]("UICorner", frame10))["CornerRadius"]=UDim["new"](1, 0)
local tween=color
local function tween2(value2)tween=value2;
(TweenService:Create(button4, TweenInfo["new"](.15, Enum["EasingStyle"]["Quad"]), {["BackgroundColor3"]=tween and processValue4()or UI["Elevated"]})):Play();
(TweenService:Create(frame10, TweenInfo["new"](.15, Enum["EasingStyle"]["Quad"]), {["Position"]=tween and UDim2["new"](1, -12, .5, -5)or UDim2["new"](0, 2, .5, -5)})):Play()
end
button4["MouseButton1Click"]:Connect(function()
if not isFeatureAvailable()and currentValue4 then
showNotification("Feature", "Feature unavailable.", "warning")tween2(false)
return
end
tween2(not tween)callback2(tween)
end
)
return{["setValue"]=tween2}
end
local currentValue4=defaultValue
local function updateControlVisual(value, contextValue)currentValue4=value
local tween=processValue4();
(TweenService:Create(button3, TweenInfo["new"](.18, Enum["EasingStyle"]["Quad"]), {["BackgroundColor3"]=currentValue4 and tween or UI["Elevated"]})):Play();
(TweenService:Create(stroke3, TweenInfo["new"](.18), {["Color"]=currentValue4 and tween or UI["Stroke"]})):Play();
(TweenService:Create(frame6, TweenInfo["new"](.18, Enum["EasingStyle"]["Quad"]), {["Position"]=currentValue4 and UDim2["new"](1, -15, .5, -6)or UDim2["new"](0, 3, .5, -6)})):Play()
if contextValue and callback then
pcall(callback, value)
end
end
button3["MouseButton1Click"]:Connect(function()
if not isFeatureAvailable()and text then
showNotification("Feature", "Feature unavailable.", "warning")updateControlVisual(false)
return
end
updateControlVisual(not currentValue4)callback(currentValue4)
end
)
if hasParent then
local button4=createKeybindButton(frame5, keybindId, function()
if not isFeatureAvailable()and text then
showNotification("Feature", "Feature unavailable.", "warning")
return
end
local conditionMet6=not currentValue4 updateControlVisual(conditionMet6)callback(conditionMet6)
if settings["ShowToggleNotifications"]then
local toggleStateText=conditionMet6 and"ENABLED"or"DISABLED"
local notificationType=conditionMet6 and"success"or"warning"showNotification(labelText, "Toggled: "..toggleStateText, notificationType)
end
end
)button4["Position"]=UDim2["new"](1, -104, .5, -9)
end
return{["addSubToggle"]=processValue5;
["toggleExpand"]=updateExpandState, ["setValue"]=updateControlVisual, ["content"]=frame7}
end
function createCollapsibleHeader(parent, title, accentColor)
title=translateText(title)
local accentColor2=accentColor or UI["Accent"]
local frame4=Instance["new"]("Frame")frame4["Size"]=UDim2["new"](1, 0, 0, 0)frame4["BackgroundTransparency"]=1 frame4["AutomaticSize"]=Enum["AutomaticSize"]["Y"]frame4["BorderSizePixel"]=0 frame4["Parent"]=parent
local listLayout=Instance["new"]("UIListLayout")listLayout["SortOrder"]=Enum["SortOrder"]["LayoutOrder"]listLayout["Padding"]=UDim["new"](0, 4)listLayout["Parent"]=frame4
local button2=Instance["new"]("TextButton")button2["Size"]=UDim2["new"](1, 0, 0, 32)button2["BackgroundTransparency"]=1 button2["BorderSizePixel"]=0 button2["Text"]=""button2["AutoButtonColor"]=false button2["LayoutOrder"]=1 button2["Parent"]=frame4
local frame5=Instance["new"]("Frame")frame5["Size"]=UDim2["new"](1, 0, 1, 0)frame5["Position"]=UDim2["new"](.5, 0, .5, 0)frame5["AnchorPoint"]=Vector2["new"](.5, .5)frame5["BackgroundColor3"]=UI["Card"]frame5["BackgroundTransparency"]=.42 frame5["BorderSizePixel"]=0 frame5["Parent"]=button2
local corner=Instance["new"]("UICorner", frame5)corner["CornerRadius"]=UDim["new"](0, UI["CardRadius"])
local stroke2=Instance["new"]("UIStroke", frame5)stroke2["Color"]=UI["StrokeDim"]stroke2["Thickness"]=.8 button2["MouseEnter"]:Connect(function()(TweenService:Create(stroke2, TweenInfo["new"](.2), {["Color"]=UI["Stroke"], ["Thickness"]=1.1})):Play();
(TweenService:Create(frame5, TweenInfo["new"](.2), {["BackgroundTransparency"]=.30})):Play()
end
)button2["MouseLeave"]:Connect(function()(TweenService:Create(stroke2, TweenInfo["new"](.2), {["Color"]=UI["StrokeDim"], ["Thickness"]=.8})):Play();
(TweenService:Create(frame5, TweenInfo["new"](.2), {["BackgroundTransparency"]=.42})):Play()
end
)
local uiScale=Instance["new"]("UIScale", frame5)uiScale["Scale"]=1
local label2=Instance["new"]("TextLabel")label2["Size"]=UDim2["new"](0, 16, 0, 16)label2["Position"]=UDim2["new"](0, 14, .5, 0)label2["AnchorPoint"]=Vector2["new"](.5, .5)label2["BackgroundTransparency"]=1 label2["Text"]="▶"label2["TextColor3"]=UI["TextSub"]label2["Font"]=Enum["Font"]["GothamBold"]label2["TextSize"]=8 label2["Parent"]=frame5
local label3=Instance["new"]("TextLabel")label3["Size"]=UDim2["new"](1, -44, 1, 0)label3["Position"]=UDim2["new"](0, 26, 0, 0)label3["BackgroundTransparency"]=1 label3["Text"]=title label3["TextColor3"]=UI["Text"]label3["Font"]=Enum["Font"]["GothamSemibold"]label3["TextSize"]=13 label3["TextXAlignment"]=Enum["TextXAlignment"]["Left"]label3["Parent"]=frame5
local frame6=Instance["new"]("Frame")frame6["Size"]=UDim2["new"](1, 0, 0, 0)frame6["BackgroundTransparency"]=1 frame6["BorderSizePixel"]=0 frame6["ClipsDescendants"]=true frame6["LayoutOrder"]=2 frame6["Parent"]=frame4
local listLayout2=Instance["new"]("UIListLayout")listLayout2["SortOrder"]=Enum["SortOrder"]["LayoutOrder"]listLayout2["Padding"]=UDim["new"](0, 4)listLayout2["Parent"]=frame6
local padding=Instance["new"]("UIPadding")padding["PaddingLeft"]=UDim["new"](0, 14)padding["PaddingRight"]=UDim["new"](0, 2)padding["Parent"]=frame6
local layoutPosition=false;
(listLayout2:GetPropertyChangedSignal("AbsoluteContentSize")):Connect(function()
if layoutPosition then
frame6["Size"]=UDim2["new"](1, 0, 0, listLayout2["AbsoluteContentSize"]["Y"])
end
end
)
local function updateExpandState(value)
if value==nil then
layoutPosition=not layoutPosition
else
layoutPosition=value
end
;
(TweenService:Create(label2, TweenInfo["new"](.2, Enum["EasingStyle"]["Quad"], Enum["EasingDirection"]["Out"]), {["Rotation"]=layoutPosition and 90 or 0, ["TextColor3"]=layoutPosition and accentColor2 or UI["TextSub"]})):Play()
local tween=UDim2["new"](1, 0, 0, layoutPosition and listLayout2["AbsoluteContentSize"]["Y"]or 0);
(TweenService:Create(frame6, TweenInfo["new"](.2, Enum["EasingStyle"]["Quad"], Enum["EasingDirection"]["Out"]), {["Size"]=tween})):Play()
end
button2["MouseButton1Click"]:Connect(function()
if not isFeatureAvailable()and isPrem then
showNotification("Feature", "Feature unavailable.", "warning")
return
end
updateExpandState()
end
);
(listLayout2:GetPropertyChangedSignal("AbsoluteContentSize")):Connect(function()
if layoutPosition then
frame6["Size"]=UDim2["new"](1, 0, 0, listLayout2["AbsoluteContentSize"]["Y"])
end
end
)button2["InputBegan"]:Connect(function(input)
if input["UserInputType"]==Enum["UserInputType"]["MouseButton1"]or input["UserInputType"]==Enum["UserInputType"]["Touch"]then
(TweenService:Create(uiScale, TweenInfo["new"](.08, Enum["EasingStyle"]["Quad"], Enum["EasingDirection"]["Out"]), {["Scale"]=.96})):Play()
end
end
)button2["InputEnded"]:Connect(function(input)
if input["UserInputType"]==Enum["UserInputType"]["MouseButton1"]or input["UserInputType"]==Enum["UserInputType"]["Touch"]then
(TweenService:Create(uiScale, TweenInfo["new"](.15, Enum["EasingStyle"]["Quad"], Enum["EasingDirection"]["Out"]), {["Scale"]=1})):Play()
end
end
)
return{["toggleExpand"]=updateExpandState, ["content"]=frame6}
end
function createSelector(parent, labelText, options, selectedValue, callback, accentColor)
labelText=translateText(labelText)
local text=isPremiumFeature(labelText)
local text2=labelText
if not isFeatureAvailable()and text then
text2=labelText.." <font color=\"#FF2A6D\">[👑]</font>"
end
local frame4=Instance["new"]("Frame")frame4["Size"]=UDim2["new"](1, 0, 0, 32)frame4["BackgroundColor3"]=UI["Card"]frame4["BackgroundTransparency"]=.42 frame4["BorderSizePixel"]=0 frame4["Parent"]=parent;
(Instance["new"]("UICorner", frame4))["CornerRadius"]=UDim["new"](0, UI["CardRadius"])
local stroke2=Instance["new"]("UIStroke", frame4)stroke2["Color"]=UI["StrokeDim"]stroke2["Thickness"]=.8 frame4["MouseEnter"]:Connect(function()(TweenService:Create(stroke2, TweenInfo["new"](.2), {["Color"]=UI["Stroke"];
["Thickness"]=1.1})):Play();
(TweenService:Create(frame4, TweenInfo["new"](.2), {["BackgroundTransparency"]=.30})):Play()
end
)frame4["MouseLeave"]:Connect(function()(TweenService:Create(stroke2, TweenInfo["new"](.2), {["Color"]=UI["StrokeDim"], ["Thickness"]=.8})):Play();
(TweenService:Create(frame4, TweenInfo["new"](.2), {["BackgroundTransparency"]=.42})):Play()
end
)
local label2=Instance["new"]("TextLabel")label2["RichText"]=true label2["Size"]=UDim2["new"](.5, 0, 1, 0)label2["Position"]=UDim2["new"](0, 10, 0, 0)label2["BackgroundTransparency"]=1 label2["Text"]=text2 label2["TextColor3"]=UI["Text"]label2["Font"]=Enum["Font"]["GothamSemibold"]label2["TextSize"]=13 label2["TextXAlignment"]=Enum["TextXAlignment"]["Left"]label2["Parent"]=frame4
local numericValue=1
for index, item in ipairs(selectedValue)do
if item==callback then
numericValue=index
break
end
end
local frame5=Instance["new"]("Frame")frame5["Size"]=UDim2["new"](0, 96, 0, 20)frame5["Position"]=UDim2["new"](1, -106, .5, -10)frame5["BackgroundColor3"]=UI["Elevated"]frame5["BorderSizePixel"]=0 frame5["Parent"]=frame4;
(Instance["new"]("UICorner", frame5))["CornerRadius"]=UDim["new"](0, 5)
local stroke3=Instance["new"]("UIStroke", frame5)stroke3["Color"]=UI["Stroke"]stroke3["Thickness"]=1
local button2=Instance["new"]("TextButton")button2["Size"]=UDim2["new"](1, 0, 1, 0)button2["BackgroundTransparency"]=1 button2["Text"]="‹  "..(translateText(options[numericValue]or"None").."  ›")button2["TextColor3"]=UI["AccentCyan"]button2["Font"]=Enum["Font"]["GothamBold"]button2["TextSize"]=12 button2["AutoButtonColor"]=false button2["Parent"]=frame5
local text3=numericValue
local function processValue4(value, contextValue)
local numericValue2=1
for index, item in ipairs(selectedValue)do
if item==value then
numericValue2=index
break
end
end
text3=numericValue2 button2["Text"]="‹  "..(translateText(options[text3]or"None").."  ›")
if contextValue and accentColor then
pcall(accentColor, value)
end
end
local function processValue5(value, contextValue, contextValue2)options=value selectedValue=contextValue processValue4(contextValue2)
end
button2["MouseButton1Click"]:Connect(function()
if not isFeatureAvailable()and text then
showNotification("Feature", "Feature unavailable.", "warning")
return
end
if#options==0 then
return
end
text3=text3%#options+1 button2["Text"]="‹  "..(translateText(options[text3]or"None").."  ›")accentColor(selectedValue[text3])
end
)
return{["setValue"]=processValue4;
["updateOptions"]=processValue5}
end
function createSlider(parent, labelText, minimum, maximum, currentValue3, callback, accentColor)
labelText=translateText(labelText)
local text=isPremiumFeature(labelText)
local text2=labelText
if not isFeatureAvailable()and text then
text2=labelText.." <font color=\"#FF2A6D\">[👑]</font>"
end
local accentColor2=accentColor or UI["Accent"]
local frame4=Instance["new"]("Frame")frame4["Size"]=UDim2["new"](1, 0, 0, 42)frame4["BackgroundColor3"]=UI["Card"]frame4["BackgroundTransparency"]=.42 frame4["BorderSizePixel"]=0 frame4["Parent"]=parent;
(Instance["new"]("UICorner", frame4))["CornerRadius"]=UDim["new"](0, UI["CardRadius"])
local stroke2=Instance["new"]("UIStroke", frame4)stroke2["Color"]=UI["StrokeDim"]stroke2["Thickness"]=.8 frame4["MouseEnter"]:Connect(function()(TweenService:Create(stroke2, TweenInfo["new"](.2), {["Color"]=UI["Stroke"], ["Thickness"]=1.1})):Play();
(TweenService:Create(frame4, TweenInfo["new"](.2), {["BackgroundTransparency"]=.30})):Play()
end
)frame4["MouseLeave"]:Connect(function()(TweenService:Create(stroke2, TweenInfo["new"](.2), {["Color"]=UI["StrokeDim"], ["Thickness"]=.8})):Play();
(TweenService:Create(frame4, TweenInfo["new"](.2), {["BackgroundTransparency"]=.42})):Play()
end
)
local label2=Instance["new"]("TextLabel")label2["RichText"]=true label2["Size"]=UDim2["new"](.6, 0, 0, 20)label2["Position"]=UDim2["new"](0, 10, 0, 4)label2["BackgroundTransparency"]=1 label2["Text"]=text2 label2["TextColor3"]=UI["Text"]label2["Font"]=Enum["Font"]["GothamSemibold"]label2["TextSize"]=12.5 label2["TextXAlignment"]=Enum["TextXAlignment"]["Left"]label2["Parent"]=frame4
local function updateTextVisual(value)
local currentValue4=tonumber(value)or 0
return tostring(math["round"](currentValue4*10)/10)
end
local label3=Instance["new"]("TextLabel")label3["Size"]=UDim2["new"](0, 100, 0, 20)label3["Position"]=UDim2["new"](1, -110, 0, 4)label3["BackgroundTransparency"]=1 label3["Text"]=updateTextVisual(currentValue3)label3["TextColor3"]=UI["AccentCyan"]label3["Font"]=Enum["Font"]["GothamBold"]label3["TextSize"]=12.5 label3["TextXAlignment"]=Enum["TextXAlignment"]["Right"]label3["Parent"]=frame4
local button2=Instance["new"]("TextButton")button2["Size"]=UDim2["new"](1, -20, 0, 4)button2["Position"]=UDim2["new"](0, 10, 0, 28)button2["BackgroundColor3"]=UI["Elevated"]button2["BorderSizePixel"]=0 button2["Text"]=""button2["AutoButtonColor"]=false button2["Parent"]=frame4;
(Instance["new"]("UICorner", button2))["CornerRadius"]=UDim["new"](1, 0)
local frame5=Instance["new"]("Frame")frame5["Size"]=UDim2["new"](0, 0, 1, 0)frame5["BackgroundColor3"]=accentColor2 frame5["BorderSizePixel"]=0 frame5["Parent"]=button2;
(Instance["new"]("UICorner", frame5))["CornerRadius"]=UDim["new"](1, 0)
local frame6=Instance["new"]("Frame")frame6["Size"]=UDim2["new"](0, 10, 0, 10)frame6["Position"]=UDim2["new"](0, -5, .5, -5)frame6["BackgroundColor3"]=Color3["fromRGB"](255, 255, 255)frame6["BorderSizePixel"]=0 frame6["Parent"]=button2;
(Instance["new"]("UICorner", frame6))["CornerRadius"]=UDim["new"](1, 0)
local stroke3=Instance["new"]("UIStroke", frame6)stroke3["Color"]=accentColor2 stroke3["Thickness"]=1.5
local function calculateValue(position)
local currentValue4=button2["AbsoluteSize"]["X"]
if currentValue4<=0 then
currentValue4=180
end
local clampedValue=math["clamp"](position["Position"]["X"]-button2["AbsolutePosition"]["X"], 0, currentValue4)
local currentValue5=clampedValue/currentValue4
local layoutPosition=minimum+((maximum-minimum))*currentValue5 layoutPosition=math["round"](layoutPosition)frame5["Size"]=UDim2["new"](currentValue5, 0, 1, 0)frame6["Position"]=UDim2["new"](currentValue5, -5, .5, -5)label3["Text"]=updateTextVisual(layoutPosition)callback(layoutPosition)
end
local function calculateValue2(value, contextValue)
local clampedValue=math["clamp"](((value-minimum))/((maximum-minimum)), 0, 1)frame5["Size"]=UDim2["new"](clampedValue, 0, 1, 0)frame6["Position"]=UDim2["new"](clampedValue, -5, .5, -5)label3["Text"]=updateTextVisual(value)
if contextValue and callback then
pcall(callback, value)
end
end
local clampedValue=math["clamp"](((currentValue3-minimum))/((maximum-minimum)), 0, 1)frame5["Size"]=UDim2["new"](clampedValue, 0, 1, 0)frame6["Position"]=UDim2["new"](clampedValue, -5, .5, -5)
local currentValue4=false button2["InputBegan"]:Connect(function(input)
if input["UserInputType"]==Enum["UserInputType"]["MouseButton1"]or input["UserInputType"]==Enum["UserInputType"]["Touch"]then
if not isFeatureAvailable()and text then
showNotification("Feature", "Feature unavailable.", "warning")
return
end
currentValue4=true calculateValue(input)
end
end
)registerConnection(UserInputService["InputChanged"]:Connect(function(input)
if currentValue4 and((input["UserInputType"]==Enum["UserInputType"]["MouseMovement"]or input["UserInputType"]==Enum["UserInputType"]["Touch"]))then
calculateValue(input)
end
end
))registerConnection(UserInputService["InputEnded"]:Connect(function(input)
if input["UserInputType"]==Enum["UserInputType"]["MouseButton1"]or input["UserInputType"]==Enum["UserInputType"]["Touch"]then
currentValue4=false
end
end
))
return{["setValue"]=calculateValue2}
end
function createSliderFloat(parent, labelText, minimum, maximum, currentValue3, callback, accentColor)
labelText=translateText(labelText)
local text=isPremiumFeature(labelText)
local text2=labelText
if not isFeatureAvailable()and text then
text2=labelText.." <font color=\"#FF2A6D\">[👑]</font>"
end
local accentColor2=accentColor or UI["Accent"]
local frame4=Instance["new"]("Frame")frame4["Size"]=UDim2["new"](1, 0, 0, 42)frame4["BackgroundColor3"]=UI["Card"]frame4["BackgroundTransparency"]=.42 frame4["BorderSizePixel"]=0 frame4["Parent"]=parent;
(Instance["new"]("UICorner", frame4))["CornerRadius"]=UDim["new"](0, UI["CardRadius"])
local stroke2=Instance["new"]("UIStroke", frame4)stroke2["Color"]=UI["StrokeDim"]stroke2["Thickness"]=.8 frame4["MouseEnter"]:Connect(function()(TweenService:Create(stroke2, TweenInfo["new"](.2), {["Color"]=UI["Stroke"];
["Thickness"]=1.1})):Play();
(TweenService:Create(frame4, TweenInfo["new"](.2), {["BackgroundTransparency"]=.30})):Play()
end
)frame4["MouseLeave"]:Connect(function()(TweenService:Create(stroke2, TweenInfo["new"](.2), {["Color"]=UI["StrokeDim"];
["Thickness"]=.8})):Play();
(TweenService:Create(frame4, TweenInfo["new"](.2), {["BackgroundTransparency"]=.42})):Play()
end
)
local label2=Instance["new"]("TextLabel")label2["RichText"]=true label2["Size"]=UDim2["new"](.6, 0, 0, 20)label2["Position"]=UDim2["new"](0, 10, 0, 4)label2["BackgroundTransparency"]=1 label2["Text"]=text2 label2["TextColor3"]=UI["Text"]label2["Font"]=Enum["Font"]["GothamSemibold"]label2["TextSize"]=12.5 label2["TextXAlignment"]=Enum["TextXAlignment"]["Left"]label2["Parent"]=frame4
local function updateTextVisual(value)
local currentValue4=tonumber(value)or 0
return string["format"]("%.2f", math["round"](currentValue4*100)/100)
end
local label3=Instance["new"]("TextLabel")label3["Size"]=UDim2["new"](0, 100, 0, 20)label3["Position"]=UDim2["new"](1, -110, 0, 4)label3["BackgroundTransparency"]=1 label3["Text"]=updateTextVisual(currentValue3)label3["TextColor3"]=UI["AccentCyan"]label3["Font"]=Enum["Font"]["GothamBold"]label3["TextSize"]=12.5 label3["TextXAlignment"]=Enum["TextXAlignment"]["Right"]label3["Parent"]=frame4
local button2=Instance["new"]("TextButton")button2["Size"]=UDim2["new"](1, -20, 0, 4)button2["Position"]=UDim2["new"](0, 10, 0, 28)button2["BackgroundColor3"]=UI["Elevated"]button2["BorderSizePixel"]=0 button2["Text"]=""button2["AutoButtonColor"]=false button2["Parent"]=frame4;
(Instance["new"]("UICorner", button2))["CornerRadius"]=UDim["new"](1, 0)
local frame5=Instance["new"]("Frame")frame5["Size"]=UDim2["new"](0, 0, 1, 0)frame5["BackgroundColor3"]=accentColor2 frame5["BorderSizePixel"]=0 frame5["Parent"]=button2;
(Instance["new"]("UICorner", frame5))["CornerRadius"]=UDim["new"](1, 0)
local frame6=Instance["new"]("Frame")frame6["Size"]=UDim2["new"](0, 10, 0, 10)frame6["Position"]=UDim2["new"](0, -5, .5, -5)frame6["BackgroundColor3"]=Color3["fromRGB"](255, 255, 255)frame6["BorderSizePixel"]=0 frame6["Parent"]=button2;
(Instance["new"]("UICorner", frame6))["CornerRadius"]=UDim["new"](1, 0)
local stroke3=Instance["new"]("UIStroke", frame6)stroke3["Color"]=accentColor2 stroke3["Thickness"]=1.5
local function calculateValue(position)
local currentValue4=button2["AbsoluteSize"]["X"]
if currentValue4<=0 then
currentValue4=180
end
local clampedValue=math["clamp"](position["Position"]["X"]-button2["AbsolutePosition"]["X"], 0, currentValue4)
local currentValue5=clampedValue/currentValue4
local layoutPosition=minimum+((maximum-minimum))*currentValue5 layoutPosition=math["round"](layoutPosition*100)/100 frame5["Size"]=UDim2["new"](currentValue5, 0, 1, 0)frame6["Position"]=UDim2["new"](currentValue5, -5, .5, -5)label3["Text"]=updateTextVisual(layoutPosition)callback(layoutPosition)
end
local function calculateValue2(value, contextValue)
local clampedValue=math["clamp"](((value-minimum))/((maximum-minimum)), 0, 1)frame5["Size"]=UDim2["new"](clampedValue, 0, 1, 0)frame6["Position"]=UDim2["new"](clampedValue, -5, .5, -5)label3["Text"]=updateTextVisual(value)
if contextValue and callback then
pcall(callback, value)
end
end
local clampedValue=math["clamp"](((currentValue3-minimum))/((maximum-minimum)), 0, 1)frame5["Size"]=UDim2["new"](clampedValue, 0, 1, 0)frame6["Position"]=UDim2["new"](clampedValue, -5, .5, -5)
local currentValue4=false button2["InputBegan"]:Connect(function(input)
if input["UserInputType"]==Enum["UserInputType"]["MouseButton1"]or input["UserInputType"]==Enum["UserInputType"]["Touch"]then
if not isFeatureAvailable()and text then
showNotification("Feature", "Feature unavailable.", "warning")
return
end
currentValue4=true calculateValue(input)
end
end
)registerConnection(UserInputService["InputChanged"]:Connect(function(input)
if currentValue4 and((input["UserInputType"]==Enum["UserInputType"]["MouseMovement"]or input["UserInputType"]==Enum["UserInputType"]["Touch"]))then
calculateValue(input)
end
end
))registerConnection(UserInputService["InputEnded"]:Connect(function(input)
if input["UserInputType"]==Enum["UserInputType"]["MouseButton1"]or input["UserInputType"]==Enum["UserInputType"]["Touch"]then
currentValue4=false
end
end
))
return{["setValue"]=calculateValue2}
end
function createInput(parent, labelText, placeholder, currentValue, callback, actionButtonText, actionButtonCallback)
labelText=translateText(labelText)
placeholder=translateText(placeholder)
actionButtonText=translateText(actionButtonText)
local text=isPremiumFeature(labelText)
local text2=labelText
if not isFeatureAvailable()and text then
text2=labelText.." <font color=\"#FF2A6D\">[👑]</font>"
end
local hasActionButton=actionButtonText~=nil
local containerHeight=hasActionButton and 48 or 32
local inputRow=Instance["new"]("Frame")inputRow["Size"]=UDim2["new"](1, 0, 0, containerHeight)inputRow["BackgroundColor3"]=UI["Card"]inputRow["BackgroundTransparency"]=.42 inputRow["BorderSizePixel"]=0 inputRow["Parent"]=parent;
(Instance["new"]("UICorner", inputRow))["CornerRadius"]=UDim["new"](0, UI["CardRadius"])
local rowStroke=Instance["new"]("UIStroke", inputRow)rowStroke["Color"]=UI["StrokeDim"]rowStroke["Thickness"]=.8 inputRow["MouseEnter"]:Connect(function()(TweenService:Create(rowStroke, TweenInfo["new"](.2), {["Color"]=UI["Stroke"], ["Thickness"]=1.1})):Play();
(TweenService:Create(inputRow, TweenInfo["new"](.2), {["BackgroundTransparency"]=.30})):Play()
end
)inputRow["MouseLeave"]:Connect(function()(TweenService:Create(rowStroke, TweenInfo["new"](.2), {["Color"]=UI["StrokeDim"];
["Thickness"]=.8})):Play();
(TweenService:Create(inputRow, TweenInfo["new"](.2), {["BackgroundTransparency"]=.42})):Play()
end
)
if hasActionButton then
local inputLabel=Instance["new"]("TextLabel")inputLabel["RichText"]=true inputLabel["Size"]=UDim2["new"](1, -16, 0, 18)inputLabel["Position"]=UDim2["new"](0, 10, 0, 4)inputLabel["BackgroundTransparency"]=1 inputLabel["Text"]=text2 inputLabel["TextColor3"]=UI["Text"]inputLabel["Font"]=Enum["Font"]["GothamSemibold"]inputLabel["TextSize"]=12.5 inputLabel["TextXAlignment"]=Enum["TextXAlignment"]["Left"]inputLabel["Parent"]=inputRow
local textFieldContainer=Instance["new"]("Frame")textFieldContainer["Size"]=UDim2["new"](1, -74, 0, 20)textFieldContainer["Position"]=UDim2["new"](0, 10, 0, 23)textFieldContainer["BackgroundColor3"]=UI["Elevated"]textFieldContainer["BorderSizePixel"]=0 textFieldContainer["Parent"]=inputRow;
(Instance["new"]("UICorner", textFieldContainer))["CornerRadius"]=UDim["new"](0, 5)
local textFieldStroke=Instance["new"]("UIStroke", textFieldContainer)textFieldStroke["Color"]=UI["StrokeDim"]textFieldStroke["Thickness"]=.8
local textBox=Instance["new"]("TextBox")textBox["Size"]=UDim2["new"](1, -10, 1, 0)textBox["Position"]=UDim2["new"](0, 5, 0, 0)textBox["BackgroundTransparency"]=1 textBox["Text"]=tostring(currentValue or"")textBox["PlaceholderText"]=placeholder or"0"textBox["PlaceholderColor3"]=UI["Muted"]textBox["TextColor3"]=UI["Text"]textBox["Font"]=Enum["Font"]["GothamBold"]textBox["TextSize"]=11 textBox["ClearTextOnFocus"]=false textBox["Parent"]=textFieldContainer
local actionButton=Instance["new"]("TextButton")actionButton["Size"]=UDim2["new"](0, 54, 0, 20)actionButton["Position"]=UDim2["new"](1, -60, 0, 23)actionButton["BackgroundColor3"]=UI["AccentCyan"]actionButton["Text"]=actionButtonText or"▶ PLAY"actionButton["TextColor3"]=Color3["fromRGB"](255, 255, 255)actionButton["Font"]=Enum["Font"]["GothamBold"]actionButton["TextSize"]=10.5 actionButton["AutoButtonColor"]=true actionButton["Parent"]=inputRow;
(Instance["new"]("UICorner", actionButton))["CornerRadius"]=UDim["new"](0, 5)actionButton["MouseButton1Click"]:Connect(function()
if not isFeatureAvailable()and text then
showNotification("Feature", "Feature unavailable.", "warning")
return
end
if actionButtonCallback then
actionButtonCallback(textBox["Text"])
end
end
)textBox["Focused"]:Connect(function()
if not isFeatureAvailable()and text then
textBox:ReleaseFocus()showNotification("Feature", "Feature unavailable.", "warning")
end
end
)textBox["FocusLost"]:Connect(function(value)pcall(callback, textBox["Text"])
end
)
return{["container"]=inputRow, ["textBox"]=textBox, ["setValue"]=function(value)
if not textBox:IsFocused()then
textBox["Text"]=tostring(value)
end
end
}
else
local inputLabel=Instance["new"]("TextLabel")inputLabel["RichText"]=true inputLabel["Size"]=UDim2["new"](.5, 0, 1, 0)inputLabel["Position"]=UDim2["new"](0, 10, 0, 0)inputLabel["BackgroundTransparency"]=1 inputLabel["Text"]=text2 inputLabel["TextColor3"]=UI["Text"]inputLabel["Font"]=Enum["Font"]["GothamSemibold"]inputLabel["TextSize"]=12.5 inputLabel["TextXAlignment"]=Enum["TextXAlignment"]["Left"]inputLabel["Parent"]=inputRow
local textFieldContainer=Instance["new"]("Frame")textFieldContainer["Size"]=UDim2["new"](0, 96, 0, 20)textFieldContainer["Position"]=UDim2["new"](1, -106, .5, -10)textFieldContainer["BackgroundColor3"]=UI["Elevated"]textFieldContainer["BorderSizePixel"]=0 textFieldContainer["Parent"]=inputRow;
(Instance["new"]("UICorner", textFieldContainer))["CornerRadius"]=UDim["new"](0, 5)
local textFieldStroke=Instance["new"]("UIStroke", textFieldContainer)textFieldStroke["Color"]=UI["StrokeDim"]textFieldStroke["Thickness"]=.8
local textBox=Instance["new"]("TextBox")textBox["Size"]=UDim2["new"](1, -10, 1, 0)textBox["Position"]=UDim2["new"](0, 5, 0, 0)textBox["BackgroundTransparency"]=1 textBox["Text"]=tostring(currentValue or"")textBox["PlaceholderText"]=placeholder or"0"textBox["PlaceholderColor3"]=UI["Muted"]textBox["TextColor3"]=UI["Text"]textBox["Font"]=Enum["Font"]["GothamBold"]textBox["TextSize"]=11 textBox["ClearTextOnFocus"]=false textBox["Parent"]=textFieldContainer textBox["Focused"]:Connect(function()
if not isFeatureAvailable()and text then
textBox:ReleaseFocus()showNotification("Feature", "Feature unavailable.", "warning")
end
end
)textBox["FocusLost"]:Connect(function(value)pcall(callback, textBox["Text"])
end
)
return{["container"]=inputRow;
["textBox"]=textBox, ["setValue"]=function(value)
if not textBox:IsFocused()then
textBox["Text"]=tostring(value)
end
end
}
end
end
function createColorWheel(parent,labelText,currentColor,callback)
labelText=translateText(labelText)
local frame4=Instance["new"]("Frame")
frame4["Size"]=UDim2["new"](1,0,0,64)
frame4["BackgroundColor3"]=UI["Card"]
frame4["BackgroundTransparency"]=.42
frame4["BorderSizePixel"]=0
frame4["Parent"]=parent
;(Instance["new"]("UICorner",frame4))["CornerRadius"]=UDim["new"](0,UI["CardRadius"])
local stroke2=Instance["new"]("UIStroke",frame4)
stroke2["Color"]=UI["StrokeDim"]
stroke2["Thickness"]=1
local label2=Instance["new"]("TextLabel")
label2["Size"]=UDim2["new"](1,-56,0,20)
label2["Position"]=UDim2["new"](0,10,0,5)
label2["BackgroundTransparency"]=1
label2["Text"]=labelText
label2["TextColor3"]=UI["Text"]
label2["Font"]=Enum["Font"]["GothamSemibold"]
label2["TextSize"]=12
label2["TextXAlignment"]=Enum["TextXAlignment"]["Left"]
label2["Parent"]=frame4
local frame5=Instance["new"]("Frame")
frame5["Size"]=UDim2["new"](0,28,0,28)
frame5["Position"]=UDim2["new"](1,-38,0,6)
frame5["BackgroundColor3"]=currentColor or Color3["fromRGB"](255,255,255)
frame5["BorderSizePixel"]=0
frame5["Parent"]=frame4
;(Instance["new"]("UICorner",frame5))["CornerRadius"]=UDim["new"](0,4)
local stroke3=Instance["new"]("UIStroke",frame5)
stroke3["Color"]=UI["Stroke"]
stroke3["Thickness"]=1
local items9={}
local items10={"R","G","B"}
for key=1,3 do
local label3=Instance["new"]("TextLabel")
label3["Size"]=UDim2["new"](0,14,0,22)
label3["Position"]=UDim2["new"](0,10+(key-1)*76,0,34)
label3["BackgroundTransparency"]=1
label3["Text"]=items10[key]
label3["TextColor3"]=UI["Muted"]
label3["Font"]=Enum["Font"]["Code"]
label3["TextSize"]=10
label3["Parent"]=frame4
local textBox=Instance["new"]("TextBox")
textBox["Size"]=UDim2["new"](0,52,0,22)
textBox["Position"]=UDim2["new"](0,26+(key-1)*76,0,34)
textBox["BackgroundColor3"]=UI["Elevated"]
textBox["BackgroundTransparency"]=.18
textBox["BorderSizePixel"]=0
textBox["ClearTextOnFocus"]=false
textBox["TextColor3"]=UI["Accent"]
textBox["PlaceholderColor3"]=UI["Muted"]
textBox["Font"]=Enum["Font"]["Code"]
textBox["TextSize"]=10
textBox["Parent"]=frame4
;(Instance["new"]("UICorner",textBox))["CornerRadius"]=UDim["new"](0,3)
local stroke4=Instance["new"]("UIStroke",textBox)
stroke4["Color"]=UI["StrokeDim"]
stroke4["Thickness"]=1
items9[key]=textBox
end
local function conditionMet5(color,contextValue)
if not color or typeof(color)~="Color3"then color=Color3["fromRGB"](255,255,255)end
frame5["BackgroundColor3"]=color
items9[1]["Text"]=tostring(math["floor"](color["R"]*255+.5))
items9[2]["Text"]=tostring(math["floor"](color["G"]*255+.5))
items9[3]["Text"]=tostring(math["floor"](color["B"]*255+.5))
if contextValue then pcall(callback,color)end
end
local function calculateValue()
local clampedValue=math["clamp"](tonumber(items9[1]["Text"])or 0,0,255)
local clampedValue2=math["clamp"](tonumber(items9[2]["Text"])or 0,0,255)
local color=math["clamp"](tonumber(items9[3]["Text"])or 0,0,255)
conditionMet5(Color3["fromRGB"](clampedValue,clampedValue2,color),true)
end
for key=1,3 do
items9[key]["FocusLost"]:Connect(calculateValue)
end
conditionMet5(currentColor or Color3["fromRGB"](255,255,255),false)
return{["container"]=frame4,["setValue"]=function(value)conditionMet5(value,false)end}
end
function createHueSlider(parent,labelText,currentHue,callback)
labelText=translateText(labelText)
local frame4=Instance["new"]("Frame")
frame4["Size"]=UDim2["new"](1,0,0,42)
frame4["BackgroundColor3"]=UI["Card"]
frame4["BackgroundTransparency"]=.42
frame4["BorderSizePixel"]=0
frame4["Parent"]=parent
;(Instance["new"]("UICorner",frame4))["CornerRadius"]=UDim["new"](0,UI["CardRadius"])
local stroke2=Instance["new"]("UIStroke",frame4)
stroke2["Color"]=UI["StrokeDim"]
stroke2["Thickness"]=1
local label2=Instance["new"]("TextLabel")
label2["Size"]=UDim2["new"](.58,0,1,0)
label2["Position"]=UDim2["new"](0,10,0,0)
label2["BackgroundTransparency"]=1
label2["Text"]=labelText
label2["TextColor3"]=UI["Text"]
label2["Font"]=Enum["Font"]["GothamSemibold"]
label2["TextSize"]=12
label2["TextXAlignment"]=Enum["TextXAlignment"]["Left"]
label2["Parent"]=frame4
local textBox=Instance["new"]("TextBox")
textBox["Size"]=UDim2["new"](0,62,0,22)
textBox["Position"]=UDim2["new"](1,-72,.5,-11)
textBox["BackgroundColor3"]=UI["Elevated"]
textBox["BackgroundTransparency"]=.18
textBox["BorderSizePixel"]=0
textBox["ClearTextOnFocus"]=false
textBox["TextColor3"]=UI["Accent"]
textBox["Font"]=Enum["Font"]["Code"]
textBox["TextSize"]=10
textBox["Parent"]=frame4
;(Instance["new"]("UICorner",textBox))["CornerRadius"]=UDim["new"](0,3)
local stroke3=Instance["new"]("UIStroke",textBox)
stroke3["Color"]=UI["StrokeDim"]
stroke3["Thickness"]=1
local function calculateValue(color,color2)
local numericValue=0
if typeof(color)=="Color3"then
numericValue=select(1,Color3["toHSV"](color))*360
else
numericValue=tonumber(color)or 0
end
numericValue=math["clamp"](numericValue,0,360)
textBox["Text"]=tostring(math["floor"](numericValue+.5))
stroke3["Color"]=Color3["fromHSV"](numericValue/360,1,1)
if color2 then pcall(callback,Color3["fromHSV"](numericValue/360,1,1))end
end
textBox["FocusLost"]:Connect(function()
calculateValue(textBox["Text"],true)
end)
calculateValue(currentHue,false)
return{["setValue"]=function(value)calculateValue(value,false)end}
end
controlRegistry={}activeColorKey="Killer"instantHealWasDisabledBeforeRevolver=false function setRevolverAutofarm(value)settings["RevolverAutofarm"]=value
if value then
if not settings["InstantHeal"]then
instantHealWasDisabledBeforeRevolver=true settings["InstantHeal"]=true
if controlRegistry["InstantHeal"]and controlRegistry["InstantHeal"]["setValue"]then
pcall(function()controlRegistry["InstantHeal"]["setValue"](true)
end
)
end
else
instantHealWasDisabledBeforeRevolver=false
end
else
if instantHealWasDisabledBeforeRevolver then
settings["InstantHeal"]=false
if controlRegistry["InstantHeal"]and controlRegistry["InstantHeal"]["setValue"]then
pcall(function()controlRegistry["InstantHeal"]["setValue"](false)
end
)
end
instantHealWasDisabledBeforeRevolver=false
end
end
if controlRegistry["RevolverAutofarm"]and controlRegistry["RevolverAutofarm"]["setValue"]then
pcall(function()controlRegistry["RevolverAutofarm"]["setValue"](value)
end
)
end
pcall(saveSettings)
end
local espEntries3={}
local items9={}
local connection=nil
local cachedValue2=nil
local timeValue=0 do
local connection2=nil function stopCustomEmote()
if connection2 then
pcall(function()connection2:Disconnect()
end
)connection2=nil
end
if currentEmoteTrack then
pcall(function()currentEmoteTrack:Stop(.2)
end
)currentEmoteTrack=nil
end
if currentEmoteSound then
pcall(function()currentEmoteSound:Stop()currentEmoteSound:Destroy()
end
)currentEmoteSound=nil
end
end
function playCustomEmote(animationId, soundId)stopCustomEmote()
local character=localPlayer and localPlayer["Character"]
local humanoid=character and character:FindFirstChildOfClass("Humanoid")
local child=humanoid and((humanoid:FindFirstChildOfClass("Animator")or humanoid))
if not child then
showNotification("Animation Player", "Character Animator not found!", "error")
return
end
local numericId=(tostring(animationId)):match("%d+")or tostring(animationId)
local animation=Instance["new"]("Animation")animation["AnimationId"]="rbxassetid://"..numericId
local success, result=pcall(function()
return child:LoadAnimation(animation)
end
)
if not success or not result then
showNotification("Animation Player", "Failed to load emote: "..tostring(soundId), "error")
return
end
currentEmoteTrack=result result["Priority"]=Enum["AnimationPriority"]["Action4"]result:Play(.2)showNotification("Animation Player", "Playing: "..soundId, "info")
if not((settings["WalkWhileEmoting"]==true))then
connection2=registerConnection((humanoid:GetPropertyChangedSignal("MoveDirection")):Connect(function()
if humanoid["MoveDirection"]["Magnitude"]>0 and currentEmoteTrack==result then
stopCustomEmote()
end
end
))
end
result["Stopped"]:Connect(function()
if currentEmoteTrack==result then
stopCustomEmote()
end
end
)
end
end


--// UI 层：分页与功能控件绑定

tabESP=createTab("ESP", "rbxassetid://16900752051", "透视", "玩家、地图元素与雷达")
tabFarm=createTab("Farm", "rbxassetid://78131536085236", "自动化", "农场、技能检定与杀手自动化")
tabSelf=createTab("Self", "rbxassetid://11984980825", "自身", "移动、能力与交互修改")
tabCombat=createTab("Combat", "rbxassetid://7485051733", "战斗", "格挡、自瞄与武器功能")
tabTP=createTab("Teleport", "rbxassetid://89914902662366", "传送", "目标与地图快捷传送")
tabVisuals=createTab("Visuals", "rbxassetid://6473251980", "视觉", "画面、网络与 HUD")
do
createSection(tabESP, "Master Controls", UI["AccentCyan"])controlRegistry["MasterESP"]=createToggle(tabESP, "Master ESP Switch", settings["MasterESP"], function(value)settings["MasterESP"]=value pcall(invalidateEspStyles)pcall(saveSettings)
end
, UI["AccentCyan"], "ToggleESP")createSection(tabESP, "Players ESP", UI["AccentCyan"])
local killeresp=createCollapsibleToggle(tabESP, "Killer Track", settings["KillerESP"]["Enabled"], function(enabled3)settings["KillerESP"]["Enabled"]=enabled3 pcall(invalidateEspStyles)pcall(saveSettings)
end
, UI["AccentCyan"], "KillerTrack")controlRegistry["KillerESP.Enabled"]={["setValue"]=killeresp["setValue"]}controlRegistry["KillerESP.Aura"]=createToggle(killeresp["content"], "Highlight Aura", settings["KillerESP"]["Aura"], function(value)settings["KillerESP"]["Aura"]=value pcall(invalidateEspStyles)pcall(saveSettings)
end
, nil, "KillerESPAura")controlRegistry["KillerESP.Distance"]=createToggle(killeresp["content"], "Show Distance", settings["KillerESP"]["Distance"], function(value)settings["KillerESP"]["Distance"]=value pcall(invalidateEspStyles)pcall(saveSettings)
end
, nil, "KillerESPDistance")controlRegistry["KillerESP.SelectedKiller"]=createToggle(killeresp["content"], "Show Selected Killer Info", settings["KillerESP"]["SelectedKiller"], function(value)settings["KillerESP"]["SelectedKiller"]=value pcall(invalidateEspStyles)pcall(saveSettings)
end
, nil, "KillerESPSelectedKiller")controlRegistry["KillerESP.ShowName"]=createToggle(killeresp["content"], "Show Player Name", settings["KillerESP"]["ShowName"], function(name2)settings["KillerESP"]["ShowName"]=name2 pcall(invalidateEspStyles)pcall(saveSettings)
end
, nil, "KillerESPShowName")
local survivoresp=createCollapsibleToggle(tabESP, "Survivor Track", settings["SurvivorESP"]["Enabled"], function(enabled3)settings["SurvivorESP"]["Enabled"]=enabled3 pcall(invalidateEspStyles)pcall(saveSettings)
end
, UI["AccentCyan"], "SurvivorTrack")controlRegistry["SurvivorESP.Enabled"]={["setValue"]=survivoresp["setValue"]}controlRegistry["SurvivorESP.Aura"]=createToggle(survivoresp["content"], "Highlight Aura", settings["SurvivorESP"]["Aura"], function(value)settings["SurvivorESP"]["Aura"]=value pcall(invalidateEspStyles)pcall(saveSettings)
end
, nil, "SurvivorESPAura")controlRegistry["SurvivorESP.Distance"]=createToggle(survivoresp["content"], "Show Distance", settings["SurvivorESP"]["Distance"], function(value)settings["SurvivorESP"]["Distance"]=value pcall(invalidateEspStyles)pcall(saveSettings)
end
, nil, "SurvivorESPDistance")controlRegistry["SurvivorESP.HealthState"]=createToggle(survivoresp["content"], "Show Health States", settings["SurvivorESP"]["HealthState"], function(value)settings["SurvivorESP"]["HealthState"]=value pcall(invalidateEspStyles)pcall(saveSettings)
end
, nil, "SurvivorESPHealthState")controlRegistry["SurvivorESP.ShowHookCount"]=createToggle(survivoresp["content"], "Show Hook Count", settings["SurvivorESP"]["ShowHookCount"], function(value)settings["SurvivorESP"]["ShowHookCount"]=value pcall(invalidateEspStyles)pcall(saveSettings)
end
, nil, "SurvivorESPHookCount")controlRegistry["SurvivorESP.ShowName"]=createToggle(survivoresp["content"], "Show Player Name", settings["SurvivorESP"]["ShowName"], function(name2)settings["SurvivorESP"]["ShowName"]=name2 pcall(invalidateEspStyles)pcall(saveSettings)
end
, nil, "SurvivorESPShowName")controlRegistry["SurvivorESP.CensorNames"]=createToggle(survivoresp["content"], "Censor Player Names", settings["SurvivorESP"]["CensorNames"], function(name2)settings["SurvivorESP"]["CensorNames"]=name2 pcall(invalidateEspStyles)pcall(saveSettings)
end
, nil, "SurvivorESPCensorNames")createSection(tabESP, "Map Elements", UI["AccentCyan"])
local generatoresp=createCollapsibleToggle(tabESP, "View Generators", settings["GeneratorESP"]["Enabled"], function(enabled3)settings["GeneratorESP"]["Enabled"]=enabled3 pcall(saveSettings)
end
, UI["AccentCyan"], "GeneratorESP")controlRegistry["GeneratorESP.Enabled"]=generatoresp controlRegistry["GeneratorESP.Aura"]=generatoresp["addSubToggle"]("Highlight Aura", settings["GeneratorESP"]["Aura"], function(value)settings["GeneratorESP"]["Aura"]=value pcall(saveSettings)
end
)controlRegistry["GeneratorESP.ShowProgress"]=generatoresp["addSubToggle"]("Show Progress %", settings["GeneratorESP"]["ShowProgress"], function(value)settings["GeneratorESP"]["ShowProgress"]=value pcall(saveSettings)
end
)controlRegistry["GeneratorESP.ShowRepairSpeed"]=generatoresp["addSubToggle"]("Show Repair Speed (%/s)", settings["GeneratorESP"]["ShowRepairSpeed"], function(value)settings["GeneratorESP"]["ShowRepairSpeed"]=value pcall(saveSettings)
end
)controlRegistry["GeneratorESP.ShowETA"]=generatoresp["addSubToggle"]("Show Estimated Finish Time (ETA)", settings["GeneratorESP"]["ShowETA"], function(value)settings["GeneratorESP"]["ShowETA"]=value pcall(saveSettings)
end
)controlRegistry["GeneratorESP.AlertThresholdEnabled"]=generatoresp["addSubToggle"]("Progress Alert Notification", settings["GeneratorESP"]["AlertThresholdEnabled"], function(enabled3)settings["GeneratorESP"]["AlertThresholdEnabled"]=enabled3 pcall(saveSettings)
end
)controlRegistry["GeneratorESP.AlertThreshold"]=createSlider(generatoresp["content"], "Alert Progress Threshold %", 50, 99, settings["GeneratorESP"]["AlertThreshold"]or 90, function(value)settings["GeneratorESP"]["AlertThreshold"]=value pcall(saveSettings)
end
, UI["AccentCyan"])controlRegistry["GeneratorESP.ShowDistance"]=generatoresp["addSubToggle"]("Show Distance", settings["GeneratorESP"]["ShowDistance"], function(value)settings["GeneratorESP"]["ShowDistance"]=value pcall(saveSettings)
end
)controlRegistry["GeneratorESP.ShowRepairingCount"]=generatoresp["addSubToggle"]("Show Repairing Count", settings["GeneratorESP"]["ShowRepairingCount"], function(value)settings["GeneratorESP"]["ShowRepairingCount"]=value pcall(saveSettings)
end
)controlRegistry["GeneratorESP.NoText"]=generatoresp["addSubToggle"]("No Text (Aura Only)", settings["GeneratorESP"]["NoText"], function(value)settings["GeneratorESP"]["NoText"]=value pcall(saveSettings)
end
)controlRegistry["CustomGenSound.Enabled"]=generatoresp["addSubToggle"]("Custom Generator Complete Sound", settings["CustomGenSound"]["Enabled"], function(enabled3)settings["CustomGenSound"]["Enabled"]=enabled3
if enabled3 then
pcall(applyCustomSoundToAllGens)
end
pcall(saveSettings)
end
)controlRegistry["CustomGenSound.SoundId"]=createInput(generatoresp["content"], "Completion Sound Asset ID", "rbxassetid://124429695332529", settings["CustomGenSound"]["SoundId"]or"rbxassetid://124429695332529", function(value)settings["CustomGenSound"]["SoundId"]=value pcall(applyCustomSoundToAllGens)pcall(saveSettings)
end
, "▶ PLAY", function(value)playSoundPreview(value)
end
)controlRegistry["CustomGenSound.Volume"]=createSlider(generatoresp["content"], "Completion Sound Volume", 1, 30, math["floor"](((settings["CustomGenSound"]["Volume"]or 1))*10), function(value)settings["CustomGenSound"]["Volume"]=value/10 pcall(applyCustomSoundToAllGens)pcall(saveSettings)
end
, UI["AccentCyan"])
local hookesp=createCollapsibleToggle(tabESP, "View Hooks", settings["HookESP"]["Enabled"], function(enabled3)settings["HookESP"]["Enabled"]=enabled3 pcall(saveSettings)
end
, UI["AccentCyan"], "HookESP")controlRegistry["HookESP.Enabled"]=hookesp controlRegistry["HookESP.Aura"]=hookesp["addSubToggle"]("Highlight Aura", settings["HookESP"]["Aura"], function(value)settings["HookESP"]["Aura"]=value pcall(saveSettings)
end
)controlRegistry["HookESP.ShowDistance"]=hookesp["addSubToggle"]("Show Distance", settings["HookESP"]["ShowDistance"], function(value)settings["HookESP"]["ShowDistance"]=value pcall(saveSettings)
end
)controlRegistry["HookESP.NoText"]=hookesp["addSubToggle"]("No Text (Aura Only)", settings["HookESP"]["NoText"], function(value)settings["HookESP"]["NoText"]=value pcall(saveSettings)
end
)
local palletesp=createCollapsibleToggle(tabESP, "View Pallets", settings["PalletESP"]["Enabled"], function(enabled3)settings["PalletESP"]["Enabled"]=enabled3 pcall(saveSettings)
end
, UI["AccentCyan"], "PalletESP")controlRegistry["PalletESP.Enabled"]=palletesp controlRegistry["PalletESP.Aura"]=palletesp["addSubToggle"]("Highlight Aura", settings["PalletESP"]["Aura"], function(value)settings["PalletESP"]["Aura"]=value pcall(saveSettings)
end
)controlRegistry["PalletESP.ShowDistance"]=palletesp["addSubToggle"]("Show Distance", settings["PalletESP"]["ShowDistance"], function(value)settings["PalletESP"]["ShowDistance"]=value pcall(saveSettings)
end
)controlRegistry["PalletESP.NoText"]=palletesp["addSubToggle"]("No Text (Aura Only)", settings["PalletESP"]["NoText"], function(value)settings["PalletESP"]["NoText"]=value pcall(saveSettings)
end
)
local vaultesp=createCollapsibleToggle(tabESP, "View Vaults", settings["VaultESP"]["Enabled"], function(enabled3)settings["VaultESP"]["Enabled"]=enabled3 pcall(saveSettings)
end
, UI["AccentCyan"], "VaultESP")controlRegistry["VaultESP.Enabled"]=vaultesp controlRegistry["VaultESP.Aura"]=vaultesp["addSubToggle"]("Highlight Aura", settings["VaultESP"]["Aura"], function(value)settings["VaultESP"]["Aura"]=value pcall(saveSettings)
end
)controlRegistry["VaultESP.ShowDistance"]=vaultesp["addSubToggle"]("Show Distance", settings["VaultESP"]["ShowDistance"], function(value)settings["VaultESP"]["ShowDistance"]=value pcall(saveSettings)
end
)controlRegistry["VaultESP.NoText"]=vaultesp["addSubToggle"]("No Text (Aura Only)", settings["VaultESP"]["NoText"], function(value)settings["VaultESP"]["NoText"]=value pcall(saveSettings)
end
)
local gateesp=createCollapsibleToggle(tabESP, "View Gates", settings["GateESP"]["Enabled"], function(enabled3)settings["GateESP"]["Enabled"]=enabled3 pcall(saveSettings)
end
, UI["AccentCyan"], "GateESP")controlRegistry["GateESP.Enabled"]=gateesp controlRegistry["GateESP.Aura"]=gateesp["addSubToggle"]("Highlight Aura", settings["GateESP"]["Aura"], function(value)settings["GateESP"]["Aura"]=value pcall(saveSettings)
end
)controlRegistry["GateESP.ShowProgress"]=gateesp["addSubToggle"]("Show Progress %", settings["GateESP"]["ShowProgress"], function(value)settings["GateESP"]["ShowProgress"]=value pcall(saveSettings)
end
)controlRegistry["GateESP.ShowDistance"]=gateesp["addSubToggle"]("Show Distance", settings["GateESP"]["ShowDistance"], function(value)settings["GateESP"]["ShowDistance"]=value pcall(saveSettings)
end
)controlRegistry["GateESP.NoText"]=gateesp["addSubToggle"]("No Text (Aura Only)", settings["GateESP"]["NoText"], function(value)settings["GateESP"]["NoText"]=value pcall(saveSettings)
end
)
local bloodesp=createCollapsibleToggle(tabESP, "View Blood Effects", settings["BloodESP"]["Enabled"], function(enabled3)settings["BloodESP"]["Enabled"]=enabled3 pcall(saveSettings)
end
, UI["AccentCyan"], "BloodESP")controlRegistry["BloodESP.Enabled"]=bloodesp controlRegistry["BloodESP.Aura"]=bloodesp["addSubToggle"]("Highlight Aura", settings["BloodESP"]["Aura"], function(value)settings["BloodESP"]["Aura"]=value pcall(saveSettings)
end
)controlRegistry["BloodESP.ShowDistance"]=bloodesp["addSubToggle"]("Show Distance", settings["BloodESP"]["ShowDistance"], function(value)settings["BloodESP"]["ShowDistance"]=value pcall(saveSettings)
end
)controlRegistry["BloodESP.NoText"]=bloodesp["addSubToggle"]("No Text (Aura Only)", settings["BloodESP"]["NoText"], function(value)settings["BloodESP"]["NoText"]=value pcall(saveSettings)
end
)
local scpesp=createCollapsibleToggle(tabESP, "Esp Zombies SCP", settings["SCPESP"]["Enabled"], function(enabled3)settings["SCPESP"]["Enabled"]=enabled3 pcall(saveSettings)
end
, UI["AccentCyan"], "SCPESP")controlRegistry["SCPESP.Enabled"]=scpesp controlRegistry["SCPESP.Aura"]=scpesp["addSubToggle"]("Highlight Aura", settings["SCPESP"]["Aura"], function(value)settings["SCPESP"]["Aura"]=value pcall(saveSettings)
end
)controlRegistry["SCPESP.ShowDistance"]=scpesp["addSubToggle"]("Show Distance", settings["SCPESP"]["ShowDistance"], function(value)settings["SCPESP"]["ShowDistance"]=value pcall(saveSettings)
end
)controlRegistry["SCPESP.NoText"]=scpesp["addSubToggle"]("No Text (Aura Only)", settings["SCPESP"]["NoText"], function(value)settings["SCPESP"]["NoText"]=value pcall(saveSettings)
end
)createSection(tabESP, "Aura & Display Settings", UI["AccentCyan"])controlRegistry["ESPBackground"]=createToggle(tabESP, "ESP Background Card", settings["ESPBackground"], function(value)settings["ESPBackground"]=value pcall(invalidateEspStyles)pcall(saveSettings)
end
, nil, "ESPBackground")controlRegistry["ESPStyle"]=createSelector(tabESP, "ESP Style", {"Old", "Standard", "Compact", "Minimal";
"Aura Only"}, {"Old", "Standard";
"Compact", "Minimal", "Aura Only"}, settings["ESPStyle"], function(value)settings["ESPStyle"]=value pcall(invalidateEspStyles)pcall(saveSettings)
end
)controlRegistry["ESPRange"]=createSelector(tabESP, "ESP Range Limit", {"50m";
"100m", "150m", "200m";
"250m";
"300m";
"Infinite"}, {50;
100;
150, 200;
250, 300;
999999}, settings["ESPRange"], function(value)settings["ESPRange"]=value pcall(saveSettings)
end
)
local espdistancefade=createCollapsibleToggle(tabESP, "Distance Based Opacity", settings["ESPDistanceFade"], function(value)settings["ESPDistanceFade"]=value pcall(saveSettings)
end
, nil, "ESPDistanceFade")controlRegistry["ESPDistanceFade"]=espdistancefade controlRegistry["ESPDistanceFadePlayers"]=espdistancefade["addSubToggle"]("Fade Players ESP", settings["ESPDistanceFadePlayers"], function(value)settings["ESPDistanceFadePlayers"]=value pcall(saveSettings)
end
)controlRegistry["ESPDistanceFadeMap"]=espdistancefade["addSubToggle"]("Fade Map Objects ESP", settings["ESPDistanceFadeMap"], function(value)settings["ESPDistanceFadeMap"]=value pcall(saveSettings)
end
)controlRegistry["ESPDistanceFadeGenerators"]=espdistancefade["addSubToggle"]("  • Fade Generators", settings["ESPDistanceFadeGenerators"], function(value)settings["ESPDistanceFadeGenerators"]=value pcall(saveSettings)
end
)controlRegistry["ESPDistanceFadePallets"]=espdistancefade["addSubToggle"]("  • Fade Pallets", settings["ESPDistanceFadePallets"], function(value)settings["ESPDistanceFadePallets"]=value pcall(saveSettings)
end
)controlRegistry["ESPDistanceFadeVaults"]=espdistancefade["addSubToggle"]("  • Fade Vaults", settings["ESPDistanceFadeVaults"], function(value)settings["ESPDistanceFadeVaults"]=value pcall(saveSettings)
end
)controlRegistry["ESPDistanceFadeHooks"]=espdistancefade["addSubToggle"]("  • Fade Hooks", settings["ESPDistanceFadeHooks"], function(value)settings["ESPDistanceFadeHooks"]=value pcall(saveSettings)
end
)controlRegistry["ESPDistanceFadeGates"]=espdistancefade["addSubToggle"]("  • Fade Gates", settings["ESPDistanceFadeGates"], function(value)settings["ESPDistanceFadeGates"]=value pcall(saveSettings)
end
)controlRegistry["ESPDistanceFadeSCPs"]=espdistancefade["addSubToggle"]("  • Fade SCPs", settings["ESPDistanceFadeSCPs"], function(value)settings["ESPDistanceFadeSCPs"]=value pcall(saveSettings)
end
)controlRegistry["ESPDistanceFadeTracers"]=espdistancefade["addSubToggle"]("Fade Tracers", settings["ESPDistanceFadeTracers"], function(value)settings["ESPDistanceFadeTracers"]=value pcall(saveSettings)
end
)controlRegistry["ESPFadeStart"]=createSlider(espdistancefade["content"], "Fade Start Distance (m)", 10, 150, settings["ESPFadeStart"], function(value)settings["ESPFadeStart"]=value pcall(saveSettings)
end
, nil)controlRegistry["ESPFadeMax"]=createSlider(espdistancefade["content"], "Full Transparent Distance (m)", 50, 400, settings["ESPFadeMax"], function(value)settings["ESPFadeMax"]=value pcall(saveSettings)
end
, nil)
local esptracers=createCollapsibleToggle(tabESP, "ESP Tracers", settings["ESPTracers"], function(value)settings["ESPTracers"]=value
if not value then
for key, item in pairs(ActiveESP["Players"])do
cleanupResources(item, false)
end
end
pcall(saveSettings)
end
, nil, "ESPTracers")controlRegistry["ESPTracers"]={["setValue"]=esptracers["setValue"]}controlRegistry["TracerTarget"]=createSelector(esptracers["content"], "Tracer Target", {"Both";
"Killers Only", "Survivors Only"}, {"Both", "Killers Only";
"Survivors Only"}, settings["TracerTarget"], function(value)settings["TracerTarget"]=value pcall(saveSettings)
end
)controlRegistry["TracerStyle"]=createSelector(esptracers["content"], "Tracer Style", {"Line";
"Arrow"}, {"Line";
"Arrow"}, settings["TracerStyle"], function(value)settings["TracerStyle"]=value pcall(saveSettings)
end
)controlRegistry["TracerOrigin"]=createSelector(esptracers["content"], "Tracer Origin", {"Bottom";
"Center", "Top"}, {"Bottom";
"Center";
"Top"}, settings["TracerOrigin"], function(value)settings["TracerOrigin"]=value pcall(saveSettings)
end
)controlRegistry["TracerColorMode"]=createSelector(esptracers["content"], "Tracer Color Mode", {"Role Color", "Custom"}, {"Role Color", "Custom"}, settings["TracerColorMode"], function(value)settings["TracerColorMode"]=value pcall(saveSettings)
end
)controlRegistry["Minimap.Enabled"]=createToggle(tabESP, "Radar Minimap", settings["Minimap"]["Enabled"], function(enabled3)settings["Minimap"]["Enabled"]=enabled3 minimapFrame["Visible"]=enabled3 pcall(saveSettings)
end
, nil, "MinimapEnabled")createSection(tabESP, "ESP Colors Customizer", UI["AccentCyan"])
local teamName={"Killer";
"Survivor (Healthy)";
"Survivor (Injured)", "Survivor (Knocked)";
"Generators";
"Hooks", "Pallets", "Vaults";
"Gates", "Blood Effects", "Zombies SCP";
"Tracers"}
local teamName2={["Killer"]="Killer";
["Survivor (Healthy)"]="SurvivorHealthy", ["Survivor (Injured)"]="SurvivorInjured";
["Survivor (Knocked)"]="SurvivorKnocked";
["Generators"]="Generator";
["Hooks"]="Hook", ["Pallets"]="Pallet", ["Vaults"]="Vault";
["Gates"]="Gate";
["Blood Effects"]="BloodEffect";
["Zombies SCP"]="SCP";
["Tracers"]="Tracer"}activeColorKey="Killer"
local teamName3=false
local frame4=Instance["new"]("Frame")frame4["Size"]=UDim2["new"](1, 0, 0, 30)frame4["BackgroundColor3"]=settings["ESPColors"][activeColorKey]frame4["Parent"]=tabESP;
(Instance["new"]("UICorner", frame4))["CornerRadius"]=UDim["new"](0, UI["CardRadius"])
local stroke2=Instance["new"]("UIStroke", frame4)stroke2["Color"]=UI["Stroke"]stroke2["Thickness"]=1
local label2=Instance["new"]("TextLabel")label2["Size"]=UDim2["new"](1, 0, 1, 0)label2["BackgroundTransparency"]=1 label2["Text"]="颜色预览"label2["TextColor3"]=Color3["fromRGB"](0, 0, 0)label2["Font"]=Enum["Font"]["GothamBold"]label2["TextSize"]=12 label2["Parent"]=frame4
local function updateTextVisual(value)
local text=((value["R"]*.299)+(value["G"]*.587))+(value["B"]*.114)label2["TextColor3"]=text>.5 and Color3["fromRGB"](0, 0, 0)or Color3["fromRGB"](255, 255, 255)
end
updateTextVisual(frame4["BackgroundColor3"])
local espcolors
local espcolors2=settings["ESPColors"][activeColorKey]or Color3["fromRGB"](255, 255, 255)
local frame5=Instance["new"]("Frame")frame5["Size"]=UDim2["new"](1, 0, 0, 32)frame5["BackgroundTransparency"]=1 frame5["Parent"]=tabESP
local listLayout=Instance["new"]("UIListLayout")listLayout["FillDirection"]=Enum["FillDirection"]["Horizontal"]listLayout["HorizontalAlignment"]=Enum["HorizontalAlignment"]["Center"]listLayout["VerticalAlignment"]=Enum["VerticalAlignment"]["Center"]listLayout["Padding"]=UDim["new"](0, 6)listLayout["Parent"]=frame5
local color={Color3["fromRGB"](255, 50, 50), Color3["fromRGB"](255, 150, 0), Color3["fromRGB"](255, 220, 50), Color3["fromRGB"](50, 255, 100), Color3["fromRGB"](0, 220, 255), Color3["fromRGB"](50, 120, 255);
Color3["fromRGB"](180, 50, 255), Color3["fromRGB"](255, 50, 200), Color3["fromRGB"](255, 255, 255);
Color3["fromRGB"](150, 150, 150)}setEspColorEditorValue=function(color2)teamName3=true frame4["BackgroundColor3"]=color2 updateTextVisual(color2)espcolors["setValue"](color2)teamName3=false
end
createSelector(tabESP, "Select Element", teamName, teamName, "Killer", function(value)activeColorKey=teamName2[value]or"Killer"
local espcolors3=settings["ESPColors"][activeColorKey]or Color3["fromRGB"](255, 255, 255)setEspColorEditorValue(espcolors3)
end
)
for index, item in ipairs(color)do
local button2=Instance["new"]("TextButton")button2["Size"]=UDim2["new"](0, 22, 0, 22)button2["BackgroundColor3"]=item button2["Text"]=""button2["AutoButtonColor"]=false button2["Parent"]=frame5;
(Instance["new"]("UICorner", button2))["CornerRadius"]=UDim["new"](1, 0)
local stroke3=Instance["new"]("UIStroke", button2)stroke3["Color"]=UI["Stroke"]stroke3["Thickness"]=1 button2["MouseEnter"]:Connect(function()(TweenService:Create(stroke3, TweenInfo["new"](.15), {["Thickness"]=2, ["Color"]=Color3["fromRGB"](255, 255, 255)})):Play()
end
)button2["MouseLeave"]:Connect(function()(TweenService:Create(stroke3, TweenInfo["new"](.15), {["Thickness"]=1, ["Color"]=UI["Stroke"]})):Play()
end
)button2["MouseButton1Click"]:Connect(function()
if not isFeatureAvailable()then
showNotification("Feature", "Feature unavailable.", "warning")
return
end
if teamName3 then
return
end
settings["ESPColors"][activeColorKey]=item frame4["BackgroundColor3"]=item updateTextVisual(item)espcolors["setValue"](item)pcall(invalidateEspStyles)pcall(saveSettings)
end
)
end
espcolors=createColorWheel(tabESP, "Color Wheel", espcolors2, function(color2)
if teamName3 then
return
end
settings["ESPColors"][activeColorKey]=color2 frame4["BackgroundColor3"]=color2 updateTextVisual(color2)pcall(invalidateEspStyles)pcall(saveSettings)
end
)setEspColorEditorValue(espcolors2)
end
local label2=nil
local connection2
local connection3
local connection4
local accentgreenColor
local accentgreenColor2 do
createSection(tabFarm, "Autofarm Controls", UI["AccentGreen"])
local frame4=Instance["new"]("Frame")frame4["Size"]=UDim2["new"](1, 0, 0, 56)frame4["BackgroundColor3"]=Color3["fromRGB"](12, 26, 20)frame4["Parent"]=tabFarm;
(Instance["new"]("UICorner", frame4))["CornerRadius"]=UDim["new"](0, UI["CardRadius"]);
(Instance["new"]("UIStroke", frame4))["Color"]=UI["AccentGreen"]
local label3=Instance["new"]("TextLabel")label3["Size"]=UDim2["new"](1, -64, 0, 20)label3["Position"]=UDim2["new"](0, 12, 0, 8)label3["BackgroundTransparency"]=1 label3["Text"]="启用幸存者自动农场"label3["TextColor3"]=UI["AccentGreen"]label3["Font"]=Enum["Font"]["GothamBold"]label3["TextSize"]=14 label3["TextXAlignment"]=Enum["TextXAlignment"]["Left"]label3["Parent"]=frame4
local label4=Instance["new"]("TextLabel")label4["Size"]=UDim2["new"](1, -64, 0, 14)label4["Position"]=UDim2["new"](0, 12, 0, 28)label4["BackgroundTransparency"]=1 label4["Text"]="自动传送、修理发电机并救援幸存者"label4["TextColor3"]=UI["TextSub"]label4["Font"]=Enum["Font"]["Gotham"]label4["TextSize"]=11.5 label4["TextXAlignment"]=Enum["TextXAlignment"]["Left"]label4["Parent"]=frame4
local button2=Instance["new"]("TextButton")button2["Size"]=UDim2["new"](0, 36, 0, 18)button2["Position"]=UDim2["new"](1, -48, .5, -9)button2["BackgroundColor3"]=settings["AutoFarmSurvivor"]and UI["AccentGreen"]or UI["Elevated"]button2["Text"]=""button2["AutoButtonColor"]=false button2["Parent"]=frame4;
(Instance["new"]("UICorner", button2))["CornerRadius"]=UDim["new"](1, 0)
local stroke2=Instance["new"]("UIStroke", button2)stroke2["Color"]=settings["AutoFarmSurvivor"]and UI["AccentGreen"]or UI["Stroke"]
local frame5=Instance["new"]("Frame")frame5["Size"]=UDim2["new"](0, 12, 0, 12)frame5["Position"]=settings["AutoFarmSurvivor"]and UDim2["new"](1, -15, .5, -6)or UDim2["new"](0, 3, .5, -6)frame5["BackgroundColor3"]=Color3["fromRGB"](255, 255, 255)frame5["Parent"]=button2;
(Instance["new"]("UICorner", frame5))["CornerRadius"]=UDim["new"](1, 0)connection2=function(color)(TweenService:Create(button2, TweenInfo["new"](.18, Enum["EasingStyle"]["Quad"]), {["BackgroundColor3"]=color and UI["AccentGreen"]or UI["Elevated"]})):Play();
(TweenService:Create(stroke2, TweenInfo["new"](.18), {["Color"]=color and UI["AccentGreen"]or UI["Stroke"]})):Play();
(TweenService:Create(frame5, TweenInfo["new"](.18, Enum["EasingStyle"]["Quad"]), {["Position"]=color and UDim2["new"](1, -15, .5, -6)or UDim2["new"](0, 3, .5, -6)})):Play()
end
_G["VD_SetFarmToggle"]=connection2 button2["MouseButton1Click"]:Connect(function()
if not settings["AutoFarmSurvivor"]then
if settings["AutoFarmAFKTotal"]then
settings["AutoFarmAFKTotal"]=false connection4(false)
end
if settings["AutoServerHopEscape"]then
settings["AutoServerHopEscape"]=false accentgreenColor(false)
end
end
settings["AutoFarmSurvivor"]=not settings["AutoFarmSurvivor"]connection2(settings["AutoFarmSurvivor"])
if settings["AutoFarmSurvivor"]then
_G["VD_FarmState"]["farmTeamStartTime"]=tick()_G["VD_FarmState"]["farmLastTeamName"]=""showNotification("Auto Farm Enabled", "Starting automatic generator repairs.", "success")
end
pcall(saveSettings)
end
)
local frame6=Instance["new"]("Frame")frame6["Size"]=UDim2["new"](1, 0, 0, 56)frame6["BackgroundColor3"]=Color3["fromRGB"](12, 22, 26)frame6["Parent"]=tabFarm;
(Instance["new"]("UICorner", frame6))["CornerRadius"]=UDim["new"](0, UI["CardRadius"]);
(Instance["new"]("UIStroke", frame6))["Color"]=UI["AccentCyan"]
local label5=Instance["new"]("TextLabel")label5["Size"]=UDim2["new"](1, -64, 0, 20)label5["Position"]=UDim2["new"](0, 12, 0, 8)label5["BackgroundTransparency"]=1 label5["Text"]="幸存者换服逃生"label5["TextColor3"]=UI["AccentCyan"]label5["Font"]=Enum["Font"]["GothamBold"]label5["TextSize"]=14 label5["TextXAlignment"]=Enum["TextXAlignment"]["Left"]label5["Parent"]=frame6
local label6=Instance["new"]("TextLabel")label6["Size"]=UDim2["new"](1, -64, 0, 14)label6["Position"]=UDim2["new"](0, 12, 0, 28)label6["BackgroundTransparency"]=1 label6["Text"]="切换到短局，等待 30 秒后逃生并循环。"label6["TextColor3"]=UI["TextSub"]label6["Font"]=Enum["Font"]["Gotham"]label6["TextSize"]=11.5 label6["TextXAlignment"]=Enum["TextXAlignment"]["Left"]label6["Parent"]=frame6
local button3=Instance["new"]("TextButton")button3["Size"]=UDim2["new"](0, 36, 0, 18)button3["Position"]=UDim2["new"](1, -48, .5, -9)button3["BackgroundColor3"]=settings["AutoServerHopEscape"]and UI["AccentCyan"]or UI["Elevated"]button3["Text"]=""button3["AutoButtonColor"]=false button3["Parent"]=frame6;
(Instance["new"]("UICorner", button3))["CornerRadius"]=UDim["new"](1, 0)
local stroke3=Instance["new"]("UIStroke", button3)stroke3["Color"]=settings["AutoServerHopEscape"]and UI["AccentCyan"]or UI["Stroke"]
local frame7=Instance["new"]("Frame")frame7["Size"]=UDim2["new"](0, 12, 0, 12)frame7["Position"]=settings["AutoServerHopEscape"]and UDim2["new"](1, -15, .5, -6)or UDim2["new"](0, 3, .5, -6)frame7["BackgroundColor3"]=Color3["fromRGB"](255, 255, 255)frame7["Parent"]=button3;
(Instance["new"]("UICorner", frame7))["CornerRadius"]=UDim["new"](1, 0)accentgreenColor=function(color)(TweenService:Create(button3, TweenInfo["new"](.18, Enum["EasingStyle"]["Quad"]), {["BackgroundColor3"]=color and UI["AccentCyan"]or UI["Elevated"]})):Play();
(TweenService:Create(stroke3, TweenInfo["new"](.18), {["Color"]=color and UI["AccentCyan"]or UI["Stroke"]})):Play();
(TweenService:Create(frame7, TweenInfo["new"](.18, Enum["EasingStyle"]["Quad"]), {["Position"]=color and UDim2["new"](1, -15, .5, -6)or UDim2["new"](0, 3, .5, -6)})):Play()
end
_G["VD_SetHopEscapeToggle"]=accentgreenColor button3["MouseButton1Click"]:Connect(function()
if not settings["AutoServerHopEscape"]then
if settings["AutoFarmSurvivor"]then
settings["AutoFarmSurvivor"]=false connection2(false)
end
if settings["AutoFarmAFKTotal"]then
settings["AutoFarmAFKTotal"]=false connection4(false)
end
if settings["AutoFarmKiller"]then
settings["AutoFarmKiller"]=false connection3(false)
end
end
settings["AutoServerHopEscape"]=not settings["AutoServerHopEscape"]accentgreenColor(settings["AutoServerHopEscape"])
if settings["AutoServerHopEscape"]then
showNotification("Server Hop Escape Enabled", "Searching for short matches to auto escape.", "success")
end
pcall(saveSettings)
end
)
local frame8=Instance["new"]("Frame")frame8["Size"]=UDim2["new"](1, 0, 0, 56)frame8["BackgroundColor3"]=Color3["fromRGB"](20, 10, 26)frame8["Parent"]=tabFarm;
(Instance["new"]("UICorner", frame8))["CornerRadius"]=UDim["new"](0, UI["CardRadius"]);
(Instance["new"]("UIStroke", frame8))["Color"]=Color3["fromRGB"](150, 50, 200)
local label7=Instance["new"]("TextLabel")label7["Size"]=UDim2["new"](1, -64, 0, 20)label7["Position"]=UDim2["new"](0, 12, 0, 8)label7["BackgroundTransparency"]=1 label7["Text"]="全自动挂机农场"label7["TextColor3"]=Color3["fromRGB"](150, 50, 200)label7["Font"]=Enum["Font"]["GothamBold"]label7["TextSize"]=14 label7["TextXAlignment"]=Enum["TextXAlignment"]["Left"]label7["Parent"]=frame8
local label8=Instance["new"]("TextLabel")label8["Size"]=UDim2["new"](1, -64, 0, 14)label8["Position"]=UDim2["new"](0, 12, 0, 28)label8["BackgroundTransparency"]=1 label8["Text"]="自动识别阵营，并按杀手或幸存者执行对应农场。"label8["TextColor3"]=UI["TextSub"]label8["Font"]=Enum["Font"]["Gotham"]label8["TextSize"]=11.5 label8["TextXAlignment"]=Enum["TextXAlignment"]["Left"]label8["Parent"]=frame8
local button4=Instance["new"]("TextButton")button4["Size"]=UDim2["new"](0, 36, 0, 18)button4["Position"]=UDim2["new"](1, -48, .5, -9)button4["BackgroundColor3"]=settings["AutoFarmAFKTotal"]and Color3["fromRGB"](150, 50, 200)or UI["Elevated"]button4["Text"]=""button4["AutoButtonColor"]=false button4["Parent"]=frame8;
(Instance["new"]("UICorner", button4))["CornerRadius"]=UDim["new"](1, 0)
local stroke4=Instance["new"]("UIStroke", button4)stroke4["Color"]=settings["AutoFarmAFKTotal"]and Color3["fromRGB"](150, 50, 200)or UI["Stroke"]
local frame9=Instance["new"]("Frame")frame9["Size"]=UDim2["new"](0, 12, 0, 12)frame9["Position"]=settings["AutoFarmAFKTotal"]and UDim2["new"](1, -15, .5, -6)or UDim2["new"](0, 3, .5, -6)frame9["BackgroundColor3"]=Color3["fromRGB"](255, 255, 255)frame9["Parent"]=button4;
(Instance["new"]("UICorner", frame9))["CornerRadius"]=UDim["new"](1, 0)connection4=function(color)(TweenService:Create(button4, TweenInfo["new"](.18, Enum["EasingStyle"]["Quad"]), {["BackgroundColor3"]=color and Color3["fromRGB"](150, 50, 200)or UI["Elevated"]})):Play();
(TweenService:Create(stroke4, TweenInfo["new"](.18), {["Color"]=color and Color3["fromRGB"](150, 50, 200)or UI["Stroke"]})):Play();
(TweenService:Create(frame9, TweenInfo["new"](.18, Enum["EasingStyle"]["Quad"]), {["Position"]=color and UDim2["new"](1, -15, .5, -6)or UDim2["new"](0, 3, .5, -6)})):Play()
end
_G["VD_SetTotalAFKToggle"]=connection4 button4["MouseButton1Click"]:Connect(function()settings["AutoFarmAFKTotal"]=not settings["AutoFarmAFKTotal"]connection4(settings["AutoFarmAFKTotal"])
if settings["AutoFarmAFKTotal"]then
_G["VD_FarmState"]["farmTeamStartTime"]=tick()_G["VD_FarmState"]["farmLastTeamName"]=""settings["AutoFarmSurvivor"]=false connection2(false)settings["AutoFarmKiller"]=false connection3(false)settings["AutoServerHopEscape"]=false accentgreenColor(false)showNotification("Total AFK Farm Enabled", "Coordinating auto farm for both teams.", "success")
else
settings["AutoFarmSurvivor"]=false connection2(false)settings["AutoFarmKiller"]=false connection3(false)settings["AutoServerHopEscape"]=false accentgreenColor(false)showNotification("Total AFK Farm Disabled", "Stopped total AFK mode.", "success")
end
pcall(saveSettings)
end
)
local frame10=Instance["new"]("Frame")frame10["Size"]=UDim2["new"](1, 0, 0, 56)frame10["BackgroundColor3"]=Color3["fromRGB"](26, 12, 12)frame10["Parent"]=tabFarm;
(Instance["new"]("UICorner", frame10))["CornerRadius"]=UDim["new"](0, UI["CardRadius"]);
(Instance["new"]("UIStroke", frame10))["Color"]=Color3["fromRGB"](200, 50, 50)
local label9=Instance["new"]("TextLabel")label9["Size"]=UDim2["new"](1, -120, 0, 20)label9["Position"]=UDim2["new"](0, 12, 0, 8)label9["BackgroundTransparency"]=1 label9["Text"]="立即逃生"label9["TextColor3"]=Color3["fromRGB"](200, 50, 50)label9["Font"]=Enum["Font"]["GothamBold"]label9["TextSize"]=14 label9["TextXAlignment"]=Enum["TextXAlignment"]["Left"]label9["Parent"]=frame10
local label10=Instance["new"]("TextLabel")label10["Size"]=UDim2["new"](1, -120, 0, 14)label10["Position"]=UDim2["new"](0, 12, 0, 28)label10["BackgroundTransparency"]=1 label10["Text"]="立即传送到最近的终点区域。"label10["TextColor3"]=UI["TextSub"]label10["Font"]=Enum["Font"]["Gotham"]label10["TextSize"]=11.5 label10["TextXAlignment"]=Enum["TextXAlignment"]["Left"]label10["Parent"]=frame10
local button5=Instance["new"]("TextButton")button5["Size"]=UDim2["new"](0, 90, 0, 24)button5["Position"]=UDim2["new"](1, -102, .5, -12)button5["BackgroundColor3"]=Color3["fromRGB"](200, 50, 50)button5["Text"]="逃生"button5["TextColor3"]=Color3["fromRGB"](255, 255, 255)button5["Font"]=Enum["Font"]["GothamSemibold"]button5["TextSize"]=11 button5["AutoButtonColor"]=false button5["Parent"]=frame10;
(Instance["new"]("UICorner", button5))["CornerRadius"]=UDim["new"](0, 5)
local stroke5=Instance["new"]("UIStroke", button5)stroke5["Color"]=Color3["fromRGB"](255, 255, 255)stroke5["Thickness"]=.5 activeFarmThread=function()
local character=localPlayer["Character"]
local rootPart=character and character:FindFirstChild("HumanoidRootPart")
if not rootPart then
showNotification("Escape Failed", "Character root part not found!", "error")
return
end
local part=nil
local distance=math["huge"]
for index, instance in ipairs(workspace:GetDescendants())do
if instance:IsA("BasePart")and((instance["Name"]=="Fininshline"or instance["Name"]=="Finishline"or(instance["Name"]:lower()):find("finishline")or(instance["Name"]:lower()):find("fininshline")))then
local distance2=((instance["Position"]-rootPart["Position"]))["Magnitude"]
if distance2<distance then
distance=distance2 part=instance
end
end
end
if part then
if _G["VD_StopAllInteractions"]then
pcall(_G["VD_StopAllInteractions"])task["wait"](.15)
end
rootPart["CFrame"]=part["CFrame"]showNotification("Instant Escape", "Teleported to finish line!", "success")
else
showNotification("Escape Failed", "No Finish Line found on this map!", "error")
end
end
button5["MouseButton1Click"]:Connect(function()
if not isFeatureAvailable()then
showNotification("Feature", "Feature unavailable.", "warning")
return
end
activeFarmThread()
end
)
if not isMobileDevice then
local layoutPosition=createKeybindButton(frame10, "InstantEscape", activeFarmThread)layoutPosition["Position"]=UDim2["new"](1, -164, .5, -9)
end
createSection(tabFarm, "Generator Automations", UI["AccentGreen"])
local autoskillcheck=createCollapsibleToggle(tabFarm, "Auto Skill Check", settings["AutoSkillCheck"], function(value)settings["AutoSkillCheck"]=value pcall(saveSettings)
end
, UI["AccentGreen"], "AutoSkillCheck")controlRegistry["AutoSkillCheck"]={["setValue"]=autoskillcheck["setValue"]}controlRegistry["InstantSkillCheck"]=createToggle(autoskillcheck["content"], "Instant Skill Check", settings["InstantSkillCheck"], function(value)settings["InstantSkillCheck"]=value pcall(saveSettings)
end
, nil, "InstantSkillCheck")controlRegistry["SkillCheckMode"]=createSelector(autoskillcheck["content"], "Skill Check Mode", {"Perfect";
"Normal";
"Hybrid"}, {"Perfect";
"Normal";
"Hybrid"}, settings["SkillCheckMode"]or"Perfect", function(value)settings["SkillCheckMode"]=value pcall(saveSettings)
end
)controlRegistry["PerfectHitRate"]=createSlider(autoskillcheck["content"], "Perfect Hit Rate (%)", 0, 100, settings["PerfectHitRate"]or 100, function(value)settings["PerfectHitRate"]=value pcall(saveSettings)
end
, UI["AccentGreen"])controlRegistry["SkillCheckSpeedVal"]=createSliderFloat(autoskillcheck["content"], "Skill Check Speed", .1, 3, settings["SkillCheckSpeedVal"]or 1, function(value)settings["SkillCheckSpeedVal"]=value pcall(saveSettings)
end
, UI["AccentGreen"])controlRegistry["NoSkillChecks"]=createToggle(autoskillcheck["content"], "No Skill Checks (Remove Checks)", settings["NoSkillChecks"], function(value)settings["NoSkillChecks"]=value pcall(saveSettings)
if value then
pcall(function()
local character=localPlayer["Character"]
if character then
for index, instance in ipairs(character:GetChildren())do
if(instance["Name"]:lower()):find("skillcheck")then
instance:Destroy()
end
end
end
end
)
end
end
, nil, "NoSkillChecks")
local frame11=Instance["new"]("Frame")frame11["Size"]=UDim2["new"](1, 0, 0, 56)frame11["BackgroundColor3"]=Color3["fromRGB"](10, 26, 15)frame11["Parent"]=tabFarm;
(Instance["new"]("UICorner", frame11))["CornerRadius"]=UDim["new"](0, UI["CardRadius"]);
(Instance["new"]("UIStroke", frame11))["Color"]=Color3["fromRGB"](50, 200, 50)
local label11=Instance["new"]("TextLabel")label11["Size"]=UDim2["new"](1, -120, 0, 20)label11["Position"]=UDim2["new"](0, 12, 0, 8)label11["BackgroundTransparency"]=1 label11["Text"]="发电机增强"label11["TextColor3"]=Color3["fromRGB"](50, 200, 50)label11["Font"]=Enum["Font"]["GothamBold"]label11["TextSize"]=14 label11["TextXAlignment"]=Enum["TextXAlignment"]["Left"]label11["Parent"]=frame11
local label12=Instance["new"]("TextLabel")label12["Size"]=UDim2["new"](1, -120, 0, 14)label12["Position"]=UDim2["new"](0, 12, 0, 28)label12["BackgroundTransparency"]=1 label12["Text"]="距离 15 studs 内时触发多点发电机增强。"label12["TextColor3"]=UI["TextSub"]label12["Font"]=Enum["Font"]["Gotham"]label12["TextSize"]=11.5 label12["TextXAlignment"]=Enum["TextXAlignment"]["Left"]label12["Parent"]=frame11
local button6=Instance["new"]("TextButton")button6["Size"]=UDim2["new"](0, 90, 0, 24)button6["Position"]=UDim2["new"](1, -102, .5, -12)button6["BackgroundColor3"]=Color3["fromRGB"](50, 200, 50)button6["Text"]="触发"button6["TextColor3"]=Color3["fromRGB"](255, 255, 255)button6["Font"]=Enum["Font"]["GothamSemibold"]button6["TextSize"]=11 button6["AutoButtonColor"]=false button6["Parent"]=frame11;
(Instance["new"]("UICorner", button6))["CornerRadius"]=UDim["new"](0, 5)
local stroke6=Instance["new"]("UIStroke", button6)stroke6["Color"]=Color3["fromRGB"](255, 255, 255)stroke6["Thickness"]=.5 button6["MouseButton1Click"]:Connect(function()
if not isFeatureAvailable()then
showNotification("Feature", "Feature unavailable.", "warning")
return
end
if accentgreenColor2 then
pcall(accentgreenColor2)
end
end
)
if not isMobileDevice then
local success=createKeybindButton(frame11, "CancelGen", function()
if not isFeatureAvailable()then
showNotification("Feature", "Feature unavailable.", "warning")
return
end
if accentgreenColor2 then
pcall(accentgreenColor2)
end
end
)success["Position"]=UDim2["new"](1, -164, .5, -9)
end
createSection(tabFarm, "Killer Automations", UI["AccentCyan"])
local frame12=Instance["new"]("Frame")frame12["Size"]=UDim2["new"](1, 0, 0, 56)frame12["BackgroundColor3"]=Color3["fromRGB"](10, 20, 26)frame12["Parent"]=tabFarm;
(Instance["new"]("UICorner", frame12))["CornerRadius"]=UDim["new"](0, UI["CardRadius"]);
(Instance["new"]("UIStroke", frame12))["Color"]=UI["AccentCyan"]
local label13=Instance["new"]("TextLabel")label13["Size"]=UDim2["new"](1, -64, 0, 20)label13["Position"]=UDim2["new"](0, 12, 0, 8)label13["BackgroundTransparency"]=1 label13["Text"]="启用杀手自动农场"label13["TextColor3"]=UI["AccentCyan"]label13["Font"]=Enum["Font"]["GothamBold"]label13["TextSize"]=14 label13["TextXAlignment"]=Enum["TextXAlignment"]["Left"]label13["Parent"]=frame12
local label14=Instance["new"]("TextLabel")label14["Size"]=UDim2["new"](1, -64, 0, 14)label14["Position"]=UDim2["new"](0, 12, 0, 28)label14["BackgroundTransparency"]=1 label14["Text"]="传送到幸存者身后，攻击、搬运并上钩。"label14["TextColor3"]=UI["TextSub"]label14["Font"]=Enum["Font"]["Gotham"]label14["TextSize"]=11.5 label14["TextXAlignment"]=Enum["TextXAlignment"]["Left"]label14["Parent"]=frame12
local button7=Instance["new"]("TextButton")button7["Size"]=UDim2["new"](0, 36, 0, 18)button7["Position"]=UDim2["new"](1, -48, .5, -9)button7["BackgroundColor3"]=settings["AutoFarmKiller"]and UI["AccentCyan"]or UI["Elevated"]button7["Text"]=""button7["AutoButtonColor"]=false button7["Parent"]=frame12;
(Instance["new"]("UICorner", button7))["CornerRadius"]=UDim["new"](1, 0)
local stroke7=Instance["new"]("UIStroke", button7)stroke7["Color"]=settings["AutoFarmKiller"]and UI["AccentCyan"]or UI["Stroke"]
local frame13=Instance["new"]("Frame")frame13["Size"]=UDim2["new"](0, 12, 0, 12)frame13["Position"]=settings["AutoFarmKiller"]and UDim2["new"](1, -15, .5, -6)or UDim2["new"](0, 3, .5, -6)frame13["BackgroundColor3"]=Color3["fromRGB"](255, 255, 255)frame13["Parent"]=button7;
(Instance["new"]("UICorner", frame13))["CornerRadius"]=UDim["new"](1, 0)connection3=function(color)(TweenService:Create(button7, TweenInfo["new"](.18, Enum["EasingStyle"]["Quad"]), {["BackgroundColor3"]=color and UI["AccentCyan"]or UI["Elevated"]})):Play();
(TweenService:Create(stroke7, TweenInfo["new"](.18), {["Color"]=color and UI["AccentCyan"]or UI["Stroke"]})):Play();
(TweenService:Create(frame13, TweenInfo["new"](.18, Enum["EasingStyle"]["Quad"]), {["Position"]=color and UDim2["new"](1, -15, .5, -6)or UDim2["new"](0, 3, .5, -6)})):Play()
end
_G["VD_SetKillerFarmToggle"]=connection3 button7["MouseButton1Click"]:Connect(function()
if not settings["AutoFarmKiller"]then
if settings["AutoFarmAFKTotal"]then
settings["AutoFarmAFKTotal"]=false connection4(false)
end
if settings["AutoServerHopEscape"]then
settings["AutoServerHopEscape"]=false accentgreenColor(false)
end
end
settings["AutoFarmKiller"]=not settings["AutoFarmKiller"]connection3(settings["AutoFarmKiller"])
if settings["AutoFarmKiller"]then
_G["VD_FarmState"]["farmTeamStartTime"]=tick()_G["VD_FarmState"]["farmLastTeamName"]=""showNotification("Killer Auto Farm Enabled", "Starting automatic survivor hunting.", "success")
end
pcall(saveSettings)
end
)
local frame14=Instance["new"]("Frame")frame14["Size"]=UDim2["new"](1, 0, 0, 56)frame14["BackgroundColor3"]=Color3["fromRGB"](10, 20, 26)frame14["Parent"]=tabFarm;
(Instance["new"]("UICorner", frame14))["CornerRadius"]=UDim["new"](0, UI["CardRadius"]);
(Instance["new"]("UIStroke", frame14))["Color"]=UI["AccentCyan"]
local label15=Instance["new"]("TextLabel")label15["Size"]=UDim2["new"](1, -64, 0, 20)label15["Position"]=UDim2["new"](0, 12, 0, 8)label15["BackgroundTransparency"]=1 label15["Text"]="防挣扎"label15["TextColor3"]=UI["AccentCyan"]label15["Font"]=Enum["Font"]["GothamBold"]label15["TextSize"]=14 label15["TextXAlignment"]=Enum["TextXAlignment"]["Left"]label15["Parent"]=frame14
local label16=Instance["new"]("TextLabel")label16["Size"]=UDim2["new"](1, -64, 0, 14)label16["Position"]=UDim2["new"](0, 12, 0, 28)label16["BackgroundTransparency"]=1 label16["Text"]="挣扎进度接近 100% 时自动放下幸存者。"label16["TextColor3"]=UI["TextSub"]label16["Font"]=Enum["Font"]["Gotham"]label16["TextSize"]=11.5 label16["TextXAlignment"]=Enum["TextXAlignment"]["Left"]label16["Parent"]=frame14
local button8=Instance["new"]("TextButton")button8["Size"]=UDim2["new"](0, 36, 0, 18)button8["Position"]=UDim2["new"](1, -48, .5, -9)button8["BackgroundColor3"]=settings["AntiWiggle"]and UI["AccentCyan"]or UI["Elevated"]button8["Text"]=""button8["AutoButtonColor"]=false button8["Parent"]=frame14;
(Instance["new"]("UICorner", button8))["CornerRadius"]=UDim["new"](1, 0)
local stroke8=Instance["new"]("UIStroke", button8)stroke8["Color"]=settings["AntiWiggle"]and UI["AccentCyan"]or UI["Stroke"]
local frame15=Instance["new"]("Frame")frame15["Size"]=UDim2["new"](0, 12, 0, 12)frame15["Position"]=settings["AntiWiggle"]and UDim2["new"](1, -15, .5, -6)or UDim2["new"](0, 3, .5, -6)frame15["BackgroundColor3"]=Color3["fromRGB"](255, 255, 255)frame15["Parent"]=button8;
(Instance["new"]("UICorner", frame15))["CornerRadius"]=UDim["new"](1, 0)
local function updateControlVisual(color)(TweenService:Create(button8, TweenInfo["new"](.18, Enum["EasingStyle"]["Quad"]), {["BackgroundColor3"]=color and UI["AccentCyan"]or UI["Elevated"]})):Play();
(TweenService:Create(stroke8, TweenInfo["new"](.18), {["Color"]=color and UI["AccentCyan"]or UI["Stroke"]})):Play();
(TweenService:Create(frame15, TweenInfo["new"](.18, Enum["EasingStyle"]["Quad"]), {["Position"]=color and UDim2["new"](1, -15, .5, -6)or UDim2["new"](0, 3, .5, -6)})):Play()
end
button8["MouseButton1Click"]:Connect(function()
if not isFeatureAvailable()then
showNotification("Feature", "Feature unavailable.", "warning")
return
end
settings["AntiWiggle"]=not settings["AntiWiggle"]updateControlVisual(settings["AntiWiggle"])
if settings["AntiWiggle"]and isFeatureAvailable()then
showNotification("Anti Wiggle Enabled", "Will auto-drop survivors right before wiggle escapes.", "success")
end
pcall(saveSettings)
end
)createSection(tabFarm, "Telemetry & State")
local frame16=Instance["new"]("Frame")frame16["Size"]=UDim2["new"](1, 0, 0, 36)frame16["BackgroundColor3"]=UI["Card"]frame16["Parent"]=tabFarm;
(Instance["new"]("UICorner", frame16))["CornerRadius"]=UDim["new"](0, UI["CardRadius"]);
(Instance["new"]("UIStroke", frame16))["Color"]=UI["Stroke"]label2=Instance["new"]("TextLabel")label2["Size"]=UDim2["new"](1, -20, 1, 0)label2["Position"]=UDim2["new"](0, 10, 0, 0)label2["BackgroundTransparency"]=1 label2["Text"]="状态：关闭"label2["TextColor3"]=UI["Muted"]label2["Font"]=Enum["Font"]["GothamBold"]label2["TextSize"]=13 label2["TextXAlignment"]=Enum["TextXAlignment"]["Left"]label2["Parent"]=frame16 controlRegistry["AutoFarmSurvivor"]={["setValue"]=connection2}controlRegistry["AutoFarmAFKTotal"]={["setValue"]=connection4}controlRegistry["AutoFarmKiller"]={["setValue"]=connection3}controlRegistry["AntiWiggle"]={["setValue"]=updateControlVisual}controlRegistry["AutoServerHopEscape"]={["setValue"]=accentgreenColor}
end
do
createSection(tabSelf, "Speed Customizations", UI["Accent"])controlRegistry["ModifierTeamFilter"]=createSelector(tabSelf, "Modifiers Active For", {"Both Teams";
"Survivors Only", "Killer Only"}, {"Both";
"Survivors", "Killer"}, settings["ModifierTeamFilter"]or"Both", function(value)settings["ModifierTeamFilter"]=value pcall(applyLocalPlayerModifiers)pcall(saveSettings)
end
)controlRegistry["VaultSpeed"]=createSelector(tabSelf, "Vault Speed Factor", {"Normal";
"Medium";
"Fast"}, {1, 1.5;
2}, settings["VaultSpeed"], function(value)settings["VaultSpeed"]=value pcall(applyLocalPlayerModifiers)pcall(saveSettings)
end
)
local speedboostenabled=createCollapsibleToggle(tabSelf, "Speed Boost Enabled", settings["SpeedBoostEnabled"], function(enabled3)
if enabled3 then
local name2=localPlayer["Team"]
local teamName=name2 and name2["Name"]
local modifierteamfilter=settings["ModifierTeamFilter"]or"Both"
local teamName2=false
if modifierteamfilter=="Both"then
teamName2=teamName=="Survivors"or teamName=="Killer"
elseif modifierteamfilter=="Survivors"then
teamName2=teamName=="Survivors"
elseif modifierteamfilter=="Killer"then
teamName2=teamName=="Killer"
end
if not teamName2 then
settings["SpeedBoostEnabled"]=false pcall(saveSettings)
if speedBoostConnection then
pcall(speedBoostConnection)
end
showNotification("Speed Boost", "Speed Boost team filter active!", "warning")
return
end
end
settings["SpeedBoostEnabled"]=enabled3 pcall(applyLocalPlayerModifiers)pcall(saveSettings)
end
, nil, "ToggleSpeedBoost")controlRegistry["SpeedBoostEnabled"]={["setValue"]=speedboostenabled["setValue"]}controlRegistry["SpeedBoost"]=createSliderFloat(speedboostenabled["content"], "Speed Boost Multiplier", 1, 3, settings["SpeedBoost"], function(value)settings["SpeedBoost"]=value pcall(applyLocalPlayerModifiers)pcall(saveSettings)
end
)controlRegistry["CountSpeedPerks"]=createToggle(speedboostenabled["content"], "Count Speed Perks / Slow Downs", settings["CountSpeedPerks"], function(value)settings["CountSpeedPerks"]=value pcall(applyLocalPlayerModifiers)pcall(saveSettings)
end
, nil)createSection(tabSelf, "Character Perks")
local function processValue4(value, color, contextValue, color2, contextValue2)
local frame4=Instance["new"]("Frame")frame4["Size"]=UDim2["new"](1, 0, 0, 32)frame4["BackgroundTransparency"]=1 frame4["BorderSizePixel"]=0 frame4["Parent"]=value
local button2=Instance["new"]("TextButton")button2["Size"]=UDim2["new"](1, 0, 0, 32)button2["BackgroundColor3"]=UI["Card"]button2["BackgroundTransparency"]=.8 button2["BorderSizePixel"]=0 button2["Text"]=""button2["AutoButtonColor"]=false button2["Parent"]=frame4
local corner=Instance["new"]("UICorner", button2)corner["CornerRadius"]=UDim["new"](0, UI["CardRadius"])
local stroke2=Instance["new"]("UIStroke", button2)stroke2["Color"]=UI["StrokeDim"]stroke2["Thickness"]=.8
local label3=Instance["new"]("TextLabel")label3["RichText"]=true label3["Size"]=UDim2["new"](.5, 0, 1, 0)label3["Position"]=UDim2["new"](0, 10, 0, 0)label3["BackgroundTransparency"]=1 label3["Text"]=color label3["TextColor3"]=UI["Text"]label3["Font"]=Enum["Font"]["GothamSemibold"]label3["TextSize"]=13 label3["TextXAlignment"]=Enum["TextXAlignment"]["Left"]label3["Parent"]=button2
local label4=Instance["new"]("TextLabel")label4["Size"]=UDim2["new"](.5, -20, 1, 0)label4["Position"]=UDim2["new"](.5, 0, 0, 0)label4["BackgroundTransparency"]=1 label4["Text"]=color2 or"None"label4["TextColor3"]=UI["AccentCyan"]label4["Font"]=Enum["Font"]["GothamBold"]label4["TextSize"]=12 label4["TextXAlignment"]=Enum["TextXAlignment"]["Right"]label4["Parent"]=button2
local label5=Instance["new"]("TextLabel")label5["Size"]=UDim2["new"](0, 16, 0, 16)label5["Position"]=UDim2["new"](1, -18, .5, 0)label5["AnchorPoint"]=Vector2["new"](.5, .5)label5["BackgroundTransparency"]=1 label5["Text"]="▼"label5["TextColor3"]=UI["TextSub"]label5["Font"]=Enum["Font"]["GothamBold"]label5["TextSize"]=9 label5["Parent"]=button2
local frame5=Instance["new"]("Frame")frame5["Size"]=UDim2["new"](1, 0, 0, 0)frame5["Position"]=UDim2["new"](0, 0, 0, 34)frame5["BackgroundTransparency"]=1 frame5["BorderSizePixel"]=0 frame5["ClipsDescendants"]=true frame5["Parent"]=frame4
local scrollFrame=Instance["new"]("ScrollingFrame")scrollFrame["Size"]=UDim2["new"](1, 0, 0, 150)scrollFrame["BackgroundColor3"]=UI["Elevated"]scrollFrame["BackgroundTransparency"]=.1 scrollFrame["BorderSizePixel"]=0 scrollFrame["ScrollBarThickness"]=4 scrollFrame["ScrollBarImageColor3"]=UI["Accent"]scrollFrame["CanvasSize"]=UDim2["new"](0, 0, 0, 0)scrollFrame["Parent"]=frame5
local corner2=Instance["new"]("UICorner", scrollFrame)corner2["CornerRadius"]=UDim["new"](0, UI["CardRadius"])
local stroke3=Instance["new"]("UIStroke", scrollFrame)stroke3["Color"]=UI["Stroke"]stroke3["Thickness"]=.8
local listLayout=Instance["new"]("UIListLayout")listLayout["SortOrder"]=Enum["SortOrder"]["LayoutOrder"]listLayout["Padding"]=UDim["new"](0, 2)listLayout["Parent"]=scrollFrame
local padding=Instance["new"]("UIPadding")padding["PaddingLeft"]=UDim["new"](0, 6)padding["PaddingRight"]=UDim["new"](0, 6)padding["PaddingTop"]=UDim["new"](0, 6)padding["PaddingBottom"]=UDim["new"](0, 6)padding["Parent"]=scrollFrame
local conditionMet5=false
local text=color2
local function updateTextVisual(value2)
if value2==nil then
conditionMet5=not conditionMet5
else
conditionMet5=value2
end
label5["Text"]=conditionMet5 and"▲"or"▼"label5["TextColor3"]=conditionMet5 and UI["AccentCyan"]or UI["TextSub"]stroke2["Color"]=conditionMet5 and UI["AccentCyan"]or UI["StrokeDim"]frame5["Size"]=conditionMet5 and UDim2["new"](1, 0, 0, 154)or UDim2["new"](1, 0, 0, 0)frame4["Size"]=conditionMet5 and UDim2["new"](1, 0, 0, 190)or UDim2["new"](1, 0, 0, 32)
end
button2["MouseButton1Click"]:Connect(function()updateTextVisual()
end
)
local items10={}
local function updateTextVisual2(value2)
for index, item in ipairs(items10)do
item:Destroy()
end
items10={}
for index, item in ipairs(value2)do
local button3=Instance["new"]("TextButton")button3["Size"]=UDim2["new"](1, 0, 0, 26)button3["BackgroundColor3"]=item==text and UI["Accent"]or Color3["fromRGB"](0, 0, 0)button3["BackgroundTransparency"]=item==text and.5 or.95 button3["BorderSizePixel"]=0 button3["Text"]=item button3["TextColor3"]=item==text and UI["Text"]or UI["TextSub"]button3["Font"]=Enum["Font"]["GothamSemibold"]button3["TextSize"]=12 button3["AutoButtonColor"]=true button3["LayoutOrder"]=index button3["Parent"]=scrollFrame;
(Instance["new"]("UICorner", button3))["CornerRadius"]=UDim["new"](0, 4)button3["MouseButton1Click"]:Connect(function()text=item label4["Text"]=item updateTextVisual(false)
for index2, item2 in ipairs(items10)do
local conditionMet6=(item2["Text"]==text)item2["BackgroundColor3"]=conditionMet6 and UI["Accent"]or Color3["fromRGB"](0, 0, 0)item2["BackgroundTransparency"]=conditionMet6 and.5 or.95 item2["TextColor3"]=conditionMet6 and UI["Text"]or UI["TextSub"]
end
if contextValue2 then
pcall(contextValue2, item)
end
end
)table["insert"](items10, button3)
end
scrollFrame["CanvasSize"]=UDim2["new"](0, 0, 0, listLayout["AbsoluteContentSize"]["Y"]+12)
end
updateTextVisual2(contextValue);
(listLayout:GetPropertyChangedSignal("AbsoluteContentSize")):Connect(function()scrollFrame["CanvasSize"]=UDim2["new"](0, 0, 0, listLayout["AbsoluteContentSize"]["Y"]+12)
end
)
return{["setValue"]=function(value2)text=value2 label4["Text"]=value2
for index, item in ipairs(items10)do
local conditionMet6=(item["Text"]==text)item["BackgroundColor3"]=conditionMet6 and UI["Accent"]or Color3["fromRGB"](0, 0, 0)item["BackgroundTransparency"]=conditionMet6 and.5 or.95 item["TextColor3"]=conditionMet6 and UI["Text"]or UI["TextSub"]
end
end
, ["updateOptions"]=function(value2, contextValue3, contextValue4)text=contextValue4 label4["Text"]=contextValue4 updateTextVisual2(value2)
end
, ["container"]=frame4}
end
local function processValue5()
local success={}pcall(function()
local instance=localPlayer["PlayerGui"]:FindFirstChild("Spectator")
local instance2=instance and instance:FindFirstChild("Inventory", true)
local instance3=instance2 and instance2:FindFirstChild("Browse_items", true)
local instance4=instance3 and instance3:FindFirstChild("loadout", true)
local perks=instance4 and instance4:FindFirstChild("Perks", true)
if perks then
for index, instance5 in ipairs(perks:GetChildren())do
if instance5:IsA("GuiObject")and(instance5["Name"]~="UIListLayout"and instance5["Name"]~="UIGridLayout")then
table["insert"](success, instance5["Name"])
end
end
end
end
)
if#success==0 then
success={"Group Project";
"No Pain No Gain", "On Screen Fear";
"Flowstate", "Adrenaline", "Sprint Burst", "Self Care";
"Decisive Strike", "Dead Hard", "Iron Will";
"Resilience", "Prove Thyself";
"Kindred";
"Spine Chill", "Urban Evasion";
"Borrowed Time", "We're Gonna Live Forever";
"Blast Mine";
"Flashbang"}
end
table["sort"](success)
return success
end
local function invokeRemote(value)
if not value then
return
end
local instance=(game:GetService("ReplicatedStorage")):FindFirstChild("Remotes")instance=instance and instance:FindFirstChild("Shop")instance=instance and instance:FindFirstChild("UnequipPerk")
local instance2=(game:GetService("ReplicatedStorage")):FindFirstChild("Remotes")instance2=instance2 and instance2:FindFirstChild("Shop")instance2=instance2 and instance2:FindFirstChild("EquipPerk")
if not instance or not instance2 then
showNotification("Perk Loadouts", "Shop remotes not found! Make sure you are in game.", "error")
return
end
pcall(function()instance:FireServer(3)task["wait"](.05)instance:FireServer(2)task["wait"](.05)instance:FireServer(1)task["wait"](.05)
if value["Perk3"]and(value["Perk3"]~="None"and value["Perk3"]~="")then
instance2:FireServer(value["Perk3"], 3)task["wait"](.05)
end
if value["Perk2"]and(value["Perk2"]~="None"and value["Perk2"]~="")then
instance2:FireServer(value["Perk2"], 2)task["wait"](.05)
end
if value["Perk1"]and(value["Perk1"]~="None"and value["Perk1"]~="")then
instance2:FireServer(value["Perk1"], 1)task["wait"](.05)
end
showNotification("Perk Loadouts", "Loadout applied successfully!", "success")
end
)
end
local accentcyanColor=createCollapsibleGroup(tabSelf, "Perk Loadout Manager", UI["AccentCyan"])
local currentValue3=processValue5()
local items10={"None"}
for index, item in ipairs(currentValue3)do
table["insert"](items10, item)
end
local success=processValue4(accentcyanColor["content"], "Perk Slot 1", items10, settings["SelectedPerk1"]or"None", function(value)settings["SelectedPerk1"]=value pcall(saveSettings)
end
)
local success2=processValue4(accentcyanColor["content"], "Perk Slot 2", items10, settings["SelectedPerk2"]or"None", function(value)settings["SelectedPerk2"]=value pcall(saveSettings)
end
)
local success3=processValue4(accentcyanColor["content"], "Perk Slot 3", items10, settings["SelectedPerk3"]or"None", function(value)settings["SelectedPerk3"]=value pcall(saveSettings)
end
)createButton(accentcyanColor["content"], "Refresh Available Perks", "Refresh", function()
local currentValue4=processValue5()
local items11={"None"}
for index, item in ipairs(currentValue4)do
table["insert"](items11, item)
end
pcall(function()success["updateOptions"](items11, items11, settings["SelectedPerk1"])success2["updateOptions"](items11, items11, settings["SelectedPerk2"])success3["updateOptions"](items11, items11, settings["SelectedPerk3"])
end
)showNotification("Perk Loadouts", "Available perks list updated!", "success")
end
, UI["AccentCyan"])
local currentValue4="My Loadout"createInput(accentcyanColor["content"], "New Loadout Name", "Type name...", "My Loadout", function(value)currentValue4=value
end
)
local function getFeatureState3()
local items11={}
if settings["PerkLoadouts"]then
for key, item in pairs(settings["PerkLoadouts"])do
table["insert"](items11, key)
end
end
table["sort"](items11)
if#items11==0 then
items11={"None"}
end
return items11
end
local currentValue5=getFeatureState3()
local button2=nil createButton(accentcyanColor["content"], "Save Current Selection", "Save", function()
if not currentValue4 or currentValue4==""or currentValue4=="None"then
showNotification("Perk Loadouts", "Please enter a valid loadout name!", "warning")
return
end
if not settings["PerkLoadouts"]then
settings["PerkLoadouts"]={}
end
settings["PerkLoadouts"][currentValue4]={["Perk1"]=settings["SelectedPerk1"]or"None";
["Perk2"]=settings["SelectedPerk2"]or"None";
["Perk3"]=settings["SelectedPerk3"]or"None"}settings["SelectedPerkLoadout"]=currentValue4 pcall(saveSettings)
local currentValue6=getFeatureState3()
if button2 then
pcall(function()button2["updateOptions"](currentValue6, currentValue6, currentValue4)
end
)
end
showNotification("Perk Loadouts", "Saved loadout: "..currentValue4, "success")
end
, UI["AccentGreen"])button2=processValue4(accentcyanColor["content"], "Select Saved Loadout", currentValue5, settings["SelectedPerkLoadout"]or currentValue5[1], function(value)settings["SelectedPerkLoadout"]=value pcall(saveSettings)
local perkloadouts=settings["PerkLoadouts"]and settings["PerkLoadouts"][value]
if perkloadouts then
settings["SelectedPerk1"]=perkloadouts["Perk1"]or"None"settings["SelectedPerk2"]=perkloadouts["Perk2"]or"None"settings["SelectedPerk3"]=perkloadouts["Perk3"]or"None"pcall(function()success["setValue"](settings["SelectedPerk1"])success2["setValue"](settings["SelectedPerk2"])success3["setValue"](settings["SelectedPerk3"])
end
)
end
end
)createButton(accentcyanColor["content"], "Equip/Load Selected Loadout", "Load", function()
local selectedperkloadout=settings["SelectedPerkLoadout"]
local perkloadouts=settings["PerkLoadouts"]and settings["PerkLoadouts"][selectedperkloadout]
if not perkloadouts then
showNotification("Perk Loadouts", "Selected loadout not found!", "warning")
return
end
invokeRemote(perkloadouts)
end
, UI["AccentCyan"])createButton(accentcyanColor["content"], "Delete Selected Loadout", "Delete", function()
local selectedperkloadout=settings["SelectedPerkLoadout"]
if not selectedperkloadout or selectedperkloadout=="None"or not settings["PerkLoadouts"]or not settings["PerkLoadouts"][selectedperkloadout]then
showNotification("Perk Loadouts", "Cannot delete selected loadout!", "warning")
return
end
settings["PerkLoadouts"][selectedperkloadout]=nil pcall(saveSettings)
local currentValue6=getFeatureState3()
local selectedperkloadout2=currentValue6[1]or"None"settings["SelectedPerkLoadout"]=selectedperkloadout2
if button2 then
pcall(function()button2["updateOptions"](currentValue6, currentValue6, selectedperkloadout2)
end
)
end
local perkloadouts=settings["PerkLoadouts"]and settings["PerkLoadouts"][selectedperkloadout2]
if perkloadouts then
settings["SelectedPerk1"]=perkloadouts["Perk1"]or"None"settings["SelectedPerk2"]=perkloadouts["Perk2"]or"None"settings["SelectedPerk3"]=perkloadouts["Perk3"]or"None"pcall(function()success["setValue"](settings["SelectedPerk1"])success2["setValue"](settings["SelectedPerk2"])success3["setValue"](settings["SelectedPerk3"])
end
)
end
showNotification("Perk Loadouts", "Deleted loadout: "..selectedperkloadout, "success")
end
, UI["AccentRed"])controlRegistry["SelectedPerk1"]={["setValue"]=function(value)success["setValue"](value)
end
}controlRegistry["SelectedPerk2"]={["setValue"]=function(value)success2["setValue"](value)
end
}controlRegistry["SelectedPerk3"]={["setValue"]=function(value)success3["setValue"](value)
end
}controlRegistry["SelectedPerkLoadout"]={["setValue"]=function(value)
local success4=getFeatureState3()pcall(function()button2["updateOptions"](success4, success4, value)
end
)
end
}
local flowstateperk=createCollapsibleToggle(tabSelf, "Force-Enable Flowstate Perk", settings["FlowstatePerk"], function(value)settings["FlowstatePerk"]=value pcall(saveSettings)
end
, nil, "FlowstatePerk")controlRegistry["FlowstatePerk"]={["setValue"]=flowstateperk["setValue"]}controlRegistry["FlowstateCooldown"]=createSlider(flowstateperk["content"], "Flowstate Cooldown (s)", 0, 60, settings["FlowstateCooldown"]or 15, function(value)settings["FlowstateCooldown"]=value pcall(saveSettings)
end
)controlRegistry["HideFlowstateUI"]=createToggle(flowstateperk["content"], "Hide Flowstate UI", settings["HideFlowstateUI"], function(value)settings["HideFlowstateUI"]=value pcall(saveSettings)
end
, nil, "HideFlowstateUI")
local function character()
local character2=localPlayer["Character"]
local humanoid=character2 and character2:FindFirstChildOfClass("Humanoid")
if not humanoid then
showNotification("Instant Bandage", "Character humanoid not found!", "error")
return
end
if humanoid["Health"]>=humanoid["MaxHealth"]then
showNotification("Instant Bandage", "You are already at full health!", "warning")
return
end
local instance=character2:FindFirstChild("Bandage")or(localPlayer:FindFirstChild("Backpack")and localPlayer["Backpack"]:FindFirstChild("Bandage"))
if not instance then
showNotification("Instant Bandage", "No bandage tool in Backpack or equipped!", "error")
return
end
if instance["Parent"]==localPlayer:FindFirstChild("Backpack")then
pcall(function()humanoid:EquipTool(instance)
end
)task["wait"](.1)
end
if instance["Parent"]~=character2 then
showNotification("Instant Bandage", "Failed to equip bandage tool!", "error")
return
end
local instance2=instance:FindFirstChild("Right Arm")
local bandage=instance2 and instance2:FindFirstChild("Bandage")
if not bandage then
bandage=instance:FindFirstChild("Bandage", true)
end
if not bandage then
showNotification("Instant Bandage", "Bandage part not found inside tool!", "error")
return
end
local instance3=(game:GetService("ReplicatedStorage")):FindFirstChild("Remotes")
local instance4=instance3 and instance3:FindFirstChild("Items")
local instance5=instance4 and instance4:FindFirstChild("Bandage")
local fire=instance5 and instance5:FindFirstChild("Fire")
if not fire then
showNotification("Instant Bandage", "Bandage remote not found in ReplicatedStorage!", "error")
return
end
showNotification("Instant Bandage", "Spamming bandage...", "success")task["spawn"](function()
local timestamp=tick()
while humanoid["Health"]<humanoid["MaxHealth"]and(instance["Parent"]==character2 and(humanoid["Health"]>0 and(tick()-timestamp<8)))do
pcall(function()fire:FireServer(true, bandage)fire:FireServer(false, bandage)
end
)task["wait"](.01)
end
if humanoid["Health"]>=humanoid["MaxHealth"]then
showNotification("Instant Bandage", "Healed to full health!", "success")
else
showNotification("Instant Bandage", "Stopped healing.", "info")
end
end
)
end
controlRegistry["InstantHeal"]=createToggle(tabSelf, "Instant Heal", settings["InstantHeal"], function(value)settings["InstantHeal"]=value pcall(saveSettings)
end
, nil, "InstantHeal")createButton(tabSelf, "Instant Bandage", "Use", character, UI["AccentCyan"], "InstantBandage")controlRegistry["NoclipVaultsPallets"]=createToggle(tabSelf, "Noclip Vaults & Pallets", settings["NoclipVaultsPallets"], function(value)settings["NoclipVaultsPallets"]=value pcall(saveSettings)
end
, nil, "NoclipVaultsPallets")controlRegistry["AutoFleeKiller"]=createToggle(tabSelf, "Auto Flee Killer (Dist &lt; 35)", settings["AutoFleeKiller"], function(value)settings["AutoFleeKiller"]=value pcall(saveSettings)
end
, nil, "AutoFleeKiller")
local automoonwalk=createCollapsibleToggle(tabSelf, "Auto Moonwalk", settings["AutoMoonwalk"], function(value)settings["AutoMoonwalk"]=value
if not value then
pcall(function()
local character2=localPlayer["Character"]
local humanoid=character2 and character2:FindFirstChildOfClass("Humanoid")
if humanoid then
humanoid["AutoRotate"]=true
end
end
)
end
pcall(saveSettings)
end
, nil, "AutoMoonwalk")controlRegistry["AutoMoonwalk"]={["setValue"]=automoonwalk["setValue"]}controlRegistry["ReverseMoonwalk"]=createToggle(automoonwalk["content"], "Reverse Moonwalk", settings["ReverseMoonwalk"], function(value)settings["ReverseMoonwalk"]=value pcall(saveSettings)
end
)controlRegistry["MoonwalkMovementBased"]=createToggle(automoonwalk["content"], "Movement-Based Moonwalk", settings["MoonwalkMovementBased"], function(value)settings["MoonwalkMovementBased"]=value pcall(saveSettings)
end
)controlRegistry["MoonwalkDisableOnVault"]=createToggle(automoonwalk["content"], "Disable Moonwalk Near Vaults", settings["MoonwalkDisableOnVault"], function(value)settings["MoonwalkDisableOnVault"]=value pcall(saveSettings)
end
)controlRegistry["MoonwalkSwaySpeed"]=createSlider(automoonwalk["content"], "Moonwalk Sway Speed", 5, 60, settings["MoonwalkSwaySpeed"]or 14, function(value)settings["MoonwalkSwaySpeed"]=value pcall(saveSettings)
end
)
local sliderControl=createSlider(automoonwalk["content"], "Moonwalk Sway Size", 0, 150, ((settings["MoonwalkSwayAmplitude"]or.65))*100, function(value)settings["MoonwalkSwayAmplitude"]=value/100 pcall(saveSettings)
end
)controlRegistry["MoonwalkSwayAmplitude"]={["setValue"]=function(value, contextValue)sliderControl["setValue"](value*100, contextValue)
end
}
local sliderControl2=createSlider(automoonwalk["content"], "Moonwalk Jitter/Shaking", 0, 50, ((settings["MoonwalkShaking"]or.05))*100, function(value)settings["MoonwalkShaking"]=value/100 pcall(saveSettings)
end
)controlRegistry["MoonwalkShaking"]={["setValue"]=function(value, contextValue)sliderControl2["setValue"](value*100, contextValue)
end
}
local rainbowcharacter=createCollapsibleToggle(tabSelf, "Rainbow Character", settings["RainbowCharacter"], function(value)settings["RainbowCharacter"]=value
if not value then
pcall(cachedValue2)
end
pcall(saveSettings)
end
, nil, "RainbowCharacter")controlRegistry["RainbowCharacter"]={["setValue"]=rainbowcharacter["setValue"]}controlRegistry["RainbowCharacterMode"]=createSelector(rainbowcharacter["content"], "Rainbow Mode", {"Highlight";
"Body Parts";
"ForceField"}, {"Highlight", "Body Parts";
"ForceField"}, settings["RainbowCharacterMode"], function(value)settings["RainbowCharacterMode"]=value pcall(saveSettings)
end
)createSection(tabSelf, "Pallet & Vault Modifiers", UI["Accent"])controlRegistry["AlwaysFastVault"]=createToggle(tabSelf, "Always Fast Vault", settings["AlwaysFastVault"], function(value)settings["AlwaysFastVault"]=value pcall(saveSettings)
end
, UI["AccentCyan"], "AlwaysFastVault")
local function camera()
local camera2=workspace["CurrentCamera"]
if not camera2 then
return nil
end
local raycastParams=RaycastParams["new"]()raycastParams["FilterType"]=Enum["RaycastFilterType"]["Include"]
local items11={}
for index, instance in ipairs(cachedPallets)do
if instance and instance["Parent"]then
table["insert"](items11, instance)
end
end
raycastParams["FilterDescendantsInstances"]=items11
local transform=camera2["CFrame"]["Position"]
local transform2=camera2["CFrame"]["LookVector"]*500
local raycastResult=workspace:Raycast(transform, transform2, raycastParams)
if raycastResult and raycastResult["Instance"]then
local currentValue6=raycastResult["Instance"]
local currentValue7=currentValue6
while currentValue7 and currentValue7~=workspace do
if table["find"](cachedPallets, currentValue7)then
return currentValue7
end
currentValue7=currentValue7["Parent"]
end
end
return nil
end
local function cleanupResources2()
if not settings["RemoteDropPallet"]then
if activeDropdown then
pcall(function()activeDropdown:Destroy()
end
)activeDropdown=nil
end
return
end
local currentValue6=camera()
if currentValue6 then
if not activeDropdown or activeDropdown["Parent"]==nil then
pcall(function()
if activeDropdown then
activeDropdown:Destroy()
end
end
)activeDropdown=Instance["new"]("Highlight")activeDropdown["Name"]="VD_PalletTargetHighlight"activeDropdown["FillColor"]=Color3["fromRGB"](0, 255, 255)activeDropdown["FillTransparency"]=.6 activeDropdown["OutlineColor"]=Color3["fromRGB"](0, 255, 255)activeDropdown["OutlineTransparency"]=0
end
if activeDropdown["Adornee"]~=currentValue6 then
activeDropdown["Adornee"]=currentValue6 activeDropdown["Parent"]=currentValue6
end
else
if activeDropdown then
activeDropdown["Adornee"]=nil activeDropdown["Parent"]=nil
end
end
end
local function findRootPart()
if not settings["RemoteDropPallet"]then
return
end
local target=camera()
if not target then
showNotification("Remote Drop Pallet", "No pallet targeted!", "warning")
return
end
local instance=(game:GetService("ReplicatedStorage")):FindFirstChild("Remotes")
local instance2=instance and instance:FindFirstChild("Pallet")
local palletdropevent=instance2 and instance2:FindFirstChild("PalletDropEvent")
if not palletdropevent then
showNotification("Remote Drop Pallet", "PalletDropEvent remote not found!", "error")
return
end
local character2=localPlayer["Character"]
local rootPart=character2 and character2:FindFirstChild("HumanoidRootPart")
local rootPart2=rootPart and rootPart["CFrame"]
local conditionMet5=false
for index, instance3 in ipairs(target:GetChildren())do
if instance3["Name"]=="PalletPoint"then
pcall(function()timeValue=tick()palletdropevent:FireServer(instance3)conditionMet5=true
end
)
end
end
if conditionMet5 then
if rootPart2 and rootPart then
task["spawn"](function()
local timestamp=tick()
while tick()-timestamp<.3 do
rootPart["CFrame"]=rootPart2 task["wait"]()
end
end
)
end
showNotification("Remote Drop Pallet", "Pallet dropped remotely!", "success")
else
showNotification("Remote Drop Pallet", "Failed to drop pallet (already dropped?)", "warning")
end
end
task["spawn"](function()
while activeLoop do
pcall(cleanupResources2)task["wait"](.05)
end
end
)
local function findRootPart2()
local instance=(game:GetService("ReplicatedStorage")):FindFirstChild("Remotes")
local instance2=instance and instance:FindFirstChild("Pallet")
local palletdropevent=instance2 and instance2:FindFirstChild("PalletDropEvent")
if not palletdropevent then
showNotification("Drop Pallets", "PalletDropEvent remote not found!", "error")
return
end
local character2=localPlayer["Character"]
local rootPart=character2 and character2:FindFirstChild("HumanoidRootPart")
local rootPart2=rootPart and rootPart["CFrame"]
local numericValue=0
for index, instance3 in ipairs(cachedPallets)do
if instance3 and instance3["Parent"]then
local conditionMet5=false
for index2, instance4 in ipairs(instance3:GetChildren())do
if instance4["Name"]=="PalletPoint"then
pcall(function()timeValue=tick()palletdropevent:FireServer(instance4)conditionMet5=true
end
)
end
end
if conditionMet5 then
numericValue=numericValue+1
end
end
end
if numericValue>0 then
if rootPart2 and rootPart then
task["spawn"](function()
local timestamp=tick()
while tick()-timestamp<.4 do
rootPart["CFrame"]=rootPart2 task["wait"]()
end
end
)
end
showNotification("Drop Pallets", "Dropped "..(numericValue.." pallets!"), "success")
end
end
createButton(tabSelf, "Drop All Pallets", "Drop", findRootPart2, UI["AccentCyan"], "DropAllPallets")controlRegistry["RemoteDropPallet"]=createToggle(tabSelf, "Remote Drop Pallet", settings["RemoteDropPallet"], function(value)settings["RemoteDropPallet"]=value pcall(saveSettings)
end
, UI["AccentCyan"])createButton(tabSelf, "Drop Target Pallet", "Drop", findRootPart, UI["AccentCyan"], "RemoteDropPalletKey")
local function invokeRemote2()
if not((isFeatureAvailable()and(featureAvailability and featureAvailability["BlockVaultPallets"])))then
showNotification("Block Vaults", "Feature unavailable.", "error")
return
end
pcall(function()
local instance=(game:GetService("ReplicatedStorage")):FindFirstChild("Remotes")instance=instance and instance:FindFirstChild("Window")instance=instance and instance:FindFirstChild("VaultEvent")
if instance then
for index, instance2 in ipairs(cachedVaults)do
if instance2 and instance2["Parent"]then
for index2, instance3 in ipairs(instance2:GetDescendants())do
if instance3["Name"]=="VaultTrigger"then
instance:FireServer(instance3, true)
end
end
end
end
showNotification("Block Vaults", "Vaults blocked!", "success")
else
showNotification("Block Vaults", "VaultEvent remote not found!", "error")
end
end
)
end
local function processValue6()
if not((isFeatureAvailable()and(featureAvailability and featureAvailability["BlockVaultPallets"])))then
showNotification("Block Pallets", "Feature unavailable.", "error")
return
end
pcall(function()
local instance=(game:GetService("ReplicatedStorage")):FindFirstChild("Remotes")instance=instance and instance:FindFirstChild("Pallet")instance=instance and instance:FindFirstChild("PalletSlideEvent")
if instance then
for index, instance2 in ipairs(cachedPallets)do
if instance2 and instance2["Parent"]then
for index2, instance3 in ipairs(instance2:GetDescendants())do
if instance3["Name"]=="PalletPointSlide"or instance3["Name"]:find("Slide")then
instance:FireServer(instance3, true)
end
end
end
end
showNotification("Block Pallets", "Pallets blocked!", "success")
else
showNotification("Block Pallets", "PalletSlideEvent remote not found!", "error")
end
end
)
end
local function processValue7()
if not((isFeatureAvailable()and(featureAvailability and featureAvailability["BlockVaultPallets"])))then
showNotification("Unlock Vaults", "Feature unavailable.", "error")
return
end
pcall(function()
local instance=(game:GetService("ReplicatedStorage")):FindFirstChild("Remotes")instance=instance and instance:FindFirstChild("Window")instance=instance and instance:FindFirstChild("VaultCompleteEvent")
if instance then
local numericValue=0
local map=workspace:FindFirstChild("Map")or workspace
for index, instance2 in ipairs(map:GetDescendants())do
local name2=instance2["Name"]:lower()
if name2:find("vault")and((name2:find("trigger")or name2:find("point")))then
pcall(function()instance:FireServer(instance2, false)
end
)numericValue=numericValue+1
end
end
if numericValue>0 then
showNotification("Unlock Vaults", "Unlocked "..(tostring(numericValue).." vaults!"), "success")
else
showNotification("Unlock Vaults", "No VaultTriggers/Points found!", "warning")
end
else
showNotification("Unlock Vaults", "Remote not found!", "error")
end
end
)
end
local function processValue8()
if not((isFeatureAvailable()and(featureAvailability and featureAvailability["BlockVaultPallets"])))then
showNotification("Unlock Pallets", "Feature unavailable.", "error")
return
end
pcall(function()
local instance=(game:GetService("ReplicatedStorage")):FindFirstChild("Remotes")instance=instance and instance:FindFirstChild("Pallet")instance=instance and instance:FindFirstChild("PalletSlideCompleteEvent")
if instance then
for index, instance2 in ipairs(cachedPallets)do
if instance2 and instance2["Parent"]then
for index2, instance3 in ipairs(instance2:GetDescendants())do
if instance3["Name"]=="PalletPointSlide"or instance3["Name"]:find("Slide")then
instance:FireServer(instance3)
end
end
end
end
showNotification("Unlock Pallets", "Pallets unlocked!", "success")
else
showNotification("Unlock Pallets", "PalletSlideCompleteEvent remote not found!", "error")
end
end
)
end
createButton(tabSelf, "Block Vaults", "Block", invokeRemote2, UI["AccentRed"], "BlockVaults")createButton(tabSelf, "Block Pallets", "Block", processValue6, UI["AccentRed"], "BlockPallets")createButton(tabSelf, "Unlock Vaults", "Unlock", processValue7, UI["AccentGreen"], "UnlockVaults")createButton(tabSelf, "Unlock Pallets", "Unlock", processValue8, UI["AccentGreen"], "UnlockPallets")createSection(tabSelf, "Stat Modifiers", UI["Warning"])
local function writeStateValue(value, contextValue)
local player=localPlayer:GetAttribute(contextValue)or 0
local inputControl=createInput(tabSelf, value, tostring(player), tostring(player), function(value2)
local player2=tonumber(value2)
if player2 then
localPlayer:SetAttribute(contextValue, player2)showNotification(value, "Updated to "..player2, "success")
else
showNotification(value, "Invalid number", "error")
end
end
)
local connection5=(localPlayer:GetAttributeChangedSignal(contextValue)):Connect(function()
local connection6=localPlayer:GetAttribute(contextValue)or 0 inputControl["setValue"](tostring(connection6))
end
)registerConnection(connection5)
end
writeStateValue("Modify Screws", "Screws")writeStateValue("Modify Gears", "Gears")writeStateValue("Modify Level", "Level")
local accentcyanColor2=createCollapsibleGroup(tabSelf, "Animation Player", UI["AccentCyan"])controlRegistry["WalkWhileEmoting"]=createToggle(accentcyanColor2["content"], "Walk While Emoting", settings["WalkWhileEmoting"]==nil and true or settings["WalkWhileEmoting"], function(value)settings["WalkWhileEmoting"]=value pcall(saveSettings)
end
, UI["AccentCyan"])createButton(accentcyanColor2["content"], "Stop Animation", "Stop", function()
if stopCustomEmote then
stopCustomEmote()
end
end
, UI["AccentRed"], "StopEmote")
local frame4=Instance["new"]("Frame")frame4["Size"]=UDim2["new"](1, 0, 0, 32)frame4["BackgroundColor3"]=UI["Elevated"]frame4["BackgroundTransparency"]=.5 frame4["BorderSizePixel"]=0 frame4["Parent"]=accentcyanColor2["content"];
(Instance["new"]("UICorner", frame4))["CornerRadius"]=UDim["new"](0, UI["CardRadius"]or 6)
local stroke2=Instance["new"]("UIStroke", frame4)stroke2["Color"]=UI["StrokeDim"]stroke2["Thickness"]=.8
local textBox=Instance["new"]("TextBox")textBox["Size"]=UDim2["new"](1, -20, 1, 0)textBox["Position"]=UDim2["new"](0, 10, 0, 0)textBox["BackgroundTransparency"]=1 textBox["PlaceholderText"]="搜索动画（例如 Griddy、Dab）..."textBox["PlaceholderColor3"]=UI["Muted"]or Color3["fromRGB"](130, 130, 150)textBox["Text"]=""textBox["TextColor3"]=UI["Text"]textBox["Font"]=Enum["Font"]["GothamSemibold"]textBox["TextSize"]=12 textBox["TextXAlignment"]=Enum["TextXAlignment"]["Left"]textBox["ClearTextOnFocus"]=false textBox["Parent"]=frame4
local scrollFrame=Instance["new"]("ScrollingFrame")scrollFrame["Size"]=UDim2["new"](1, 0, 0, 220)scrollFrame["BackgroundTransparency"]=1 scrollFrame["BorderSizePixel"]=0 scrollFrame["ScrollBarThickness"]=4 scrollFrame["ScrollBarImageColor3"]=UI["AccentCyan"]or UI["Accent"]scrollFrame["CanvasSize"]=UDim2["new"](0, 0, 0, 0)scrollFrame["AutomaticCanvasSize"]=Enum["AutomaticSize"]["Y"]scrollFrame["Parent"]=accentcyanColor2["content"]
local listLayout=Instance["new"]("UIListLayout", scrollFrame)listLayout["SortOrder"]=Enum["SortOrder"]["LayoutOrder"]listLayout["Padding"]=UDim["new"](0, 4)
local items11={{["name"]="KWIK FLIP";
["id"]="73896868179198", ["keybind"]="EmoteKwikFlip"};
{["name"]="Schadenfreude (laugh)";
["id"]="138303785534052";
["keybind"]="EmoteSchadenfreude"};
{["name"]="Wave", ["id"]="99670106766588", ["keybind"]="EmoteWave"};
{["name"]="Pop off", ["id"]="130933486827090";
["keybind"]="EmotePopOff"}, {["name"]="Backflip";
["id"]="74705617908505", ["keybind"]="EmoteBackflip"};
{["name"]="Rampage";
["id"]="79155929355612";
["keybind"]="EmoteRampage"}, {["name"]="24 Hours cinderella";
["id"]="137195203725366";
["keybind"]="Emote24HrCinderella"};
{["name"]="Floating rest";
["id"]="114593021219597", ["keybind"]="EmoteFloatingRest"}, {["name"]="Arm swing", ["id"]="80552139463944";
["keybind"]="EmoteArmSwing"};
{["name"]="Griddy", ["id"]="75586690784894", ["keybind"]="EmoteGriddy"}, {["name"]="OnePlays";
["id"]="140625405103474";
["keybind"]="EmoteOnePlays"};
{["name"]="Quick Combo";
["id"]="105592621576604", ["keybind"]="EmoteQuickCombo"}, {["name"]="Applause";
["id"]="96328361165090", ["keybind"]="EmoteApplause"};
{["name"]="Source";
["id"]="122615684039119";
["keybind"]="EmoteSource"};
{["name"]="The Dab", ["id"]="93350677984372", ["keybind"]="EmoteTheDab"}, {["name"]="California girls";
["id"]="123552803041504", ["keybind"]="EmoteCaliforniaGirls"};
{["name"]="Kyoufu";
["id"]="137322894494527", ["keybind"]="EmoteKyoufu"}, {["name"]="Rambunctious";
["id"]="81054496834622", ["keybind"]="EmoteRambunctious"}, {["name"]="Static", ["id"]="95096724457263";
["keybind"]="EmoteStatic"}, {["name"]="Mannrobics", ["id"]="134677515695156", ["keybind"]="EmoteMannrobics"};
{["name"]="Top monitor Ketua";
["id"]="81792358514569", ["keybind"]="EmoteTopMonitorKetua"};
{["name"]="Broken Doll", ["id"]="131796630104825";
["keybind"]="EmoteBrokenDoll"};
{["name"]="Friday Night", ["id"]="83229063951016";
["keybind"]="EmoteFridayNight"};
{["name"]="War Cry", ["id"]="82600868380136";
["keybind"]="EmoteWarCry"}, {["name"]="Vulnerable", ["id"]="121773684313913";
["keybind"]="EmoteVulnerable"}}
local items12={}
for index, item in ipairs(items11)do
local button3=createButton(scrollFrame, item["name"], "Play", function()
if playCustomEmote then
playCustomEmote(item["id"], item["name"])
end
end
, UI["Accent"], item["keybind"])table["insert"](items12, {["nameLower"]=item["name"]:lower(), ["container"]=button3})
end
;
(textBox:GetPropertyChangedSignal("Text")):Connect(function()
local normalizedText=(textBox["Text"]:lower()):gsub("^%s*(.-)%s*$", "%1")
for index, item in ipairs(items12)do
if item["container"]and item["container"]["Parent"]then
if normalizedText==""or string["find"](item["nameLower"], normalizedText, 1, true)then
item["container"]["Visible"]=true
else
item["container"]["Visible"]=false
end
end
end
end
)
end
accentgreenColor2=function()
if not((isFeatureAvailable()and(featureAvailability and featureAvailability["CancelGen"])))then
showNotification("Feature", "Feature unavailable.", "warning")
return
end
showNotification("Generator Buff", "Attempting to buff generator...", "info")task["spawn"](function()
local success, result=pcall(function()
local character=localPlayer["Character"]
local rootPart=character and character:FindFirstChild("HumanoidRootPart")
if not rootPart then
showNotification("Generator Buff", "Character HumanoidRootPart not found!", "error")
return
end
local function processValue4(instance)
if instance:IsA("Model")then
return instance["PrimaryPart"]or instance:FindFirstChildWhichIsA("BasePart")
end
return instance:FindFirstChildWhichIsA("BasePart")
end
local items10={}
local instance=workspace:FindFirstChild("Map")
local items11={}
if instance then
local generators=instance:FindFirstChild("Generators")
local gens=instance:FindFirstChild("Gens")
if generators then
table["insert"](items11, generators)
end
if gens then
table["insert"](items11, gens)
end
end
for index, item in ipairs(items11)do
for index2, instance2 in ipairs(item:GetChildren())do
if instance2["Name"]=="Generator"or string["find"](instance2["Name"]:lower(), "generator")then
table["insert"](items10, instance2)
end
end
end
if#items10==0 then
for index, instance2 in ipairs(cachedGenerators)do
if instance2 and instance2["Parent"]then
table["insert"](items10, instance2)
end
end
end
if#items10==0 then
for index, instance2 in ipairs(workspace:GetDescendants())do
if instance2["Name"]=="Generator"then
table["insert"](items10, instance2)
end
end
end
if#items10==0 then
showNotification("Generator Buff", "No generators found in map!", "error")
return
end
local cachedValue3=nil
local distance=math["huge"]
for index, item in ipairs(items10)do
local currentValue3=processValue4(item)
if currentValue3 then
local distance2=((currentValue3["Position"]-rootPart["Position"]))["Magnitude"]
if distance2<distance then
distance=distance2 cachedValue3=item
end
end
end
if not cachedValue3 or distance>15 then
local currentValue3=cachedValue3 and string["format"]("%.1f studs", distance)or"N/A"showNotification("Generator Buff", "No generator within 15 studs! ("..(currentValue3..")"), "error")
return
end
local items12={}
for index, instance2 in ipairs(cachedValue3:GetChildren())do
if string["find"](instance2["Name"]:lower(), "generatorpoint")then
table["insert"](items12, instance2)
end
end
table["sort"](items12, function(name2, name3)
return name2["Name"]<name3["Name"]
end
)
if#items12==0 then
showNotification("Generator Buff", "No generator points resolved!", "error")
return
end
local instance2=game:GetService("ReplicatedStorage")
local instance3=instance2:FindFirstChild("Remotes")
local instance4=instance3 and instance3:FindFirstChild("Generator")
local repairevent=instance4 and instance4:FindFirstChild("RepairEvent")
if not repairevent then
repairevent=instance2:FindFirstChild("RepairEvent", true)
end
if not repairevent then
showNotification("Generator Buff", "RepairEvent remote not found!", "error")
return
end
local count=#items12
if count==2 then
local currentValue3=items12[1]
local currentValue4=items12[2]repairevent:FireServer(currentValue4, true)task["wait"](.2)repairevent:FireServer(currentValue3, true)task["wait"](.2)repairevent:FireServer(currentValue3, false)
else
local currentValue3=items12[count]
for key=1, count-1, 1 do
local currentValue4=items12[key]repairevent:FireServer(currentValue4, true)task["wait"](.2)repairevent:FireServer(currentValue3, true)task["wait"](.2)repairevent:FireServer(currentValue3, false)
if key<count-1 then
task["wait"](.2)
end
end
end
showNotification("Generator Buff", "Successfully applied generator buff!", "success")
end
)
if not success then
showNotification("Generator Buff", "Critical Error: "..tostring(result), "error")
end
end
)
end
do
createSection(tabCombat, "Combat Automations", UI["AccentGreen"])
local currentValue3=isFeatureAvailable()and"Auto Parry"or"Auto Parry"
local autoparry=createCollapsibleToggle(tabCombat, currentValue3, settings["AutoParry"], function(value)settings["AutoParry"]=value pcall(saveSettings)
end
, UI["Danger"], "AutoParry")controlRegistry["AutoParry"]={["setValue"]=autoparry["setValue"]}controlRegistry["ParryUseItem"]=createToggle(autoparry["content"], "Use Item Activation (Legit)", settings["ParryUseItem"], function(value)settings["ParryUseItem"]=value pcall(saveSettings)
end
, nil, "ParryUseItem")controlRegistry["ParryRange"]=createSlider(autoparry["content"], "Parry Range Limit", 6, 25, settings["ParryRange"], function(value)settings["ParryRange"]=value pcall(saveSettings)pcall(updateParryESP)
end
, UI["Danger"])controlRegistry["ParryDelay"]=createSelector(autoparry["content"], "Parry Reaction Delay", {"Instant";
"50ms", "100ms";
"150ms";
"200ms";
"250ms", "300ms"}, {0, .05, .1, .15, .2;
.25, .3}, settings["ParryDelay"], function(value)settings["ParryDelay"]=value pcall(saveSettings)
end
)controlRegistry["ParryFacingCheck"]=createToggle(autoparry["content"], "Directional Facing Check", settings["ParryFacingCheck"], function(value)settings["ParryFacingCheck"]=value pcall(saveSettings)
end
, nil, "ParryFacingCheck")controlRegistry["ParryPingCompensation"]=createToggle(autoparry["content"], "Ping Compensation", settings["ParryPingCompensation"], function(value)settings["ParryPingCompensation"]=value pcall(saveSettings)
end
, nil, "ParryPingCompensation")controlRegistry["ParryRangeESP"]=createToggle(autoparry["content"], "Visual Parry Range Circle (ESP)", settings["ParryRangeESP"], function(value)settings["ParryRangeESP"]=value pcall(saveSettings)pcall(updateParryESP)
end
, nil, "ParryRangeESP")controlRegistry["FrenzyParry"]=createToggle(autoparry["content"], "Ignore Frenzy Killer", settings["FrenzyParry"], function(value)settings["FrenzyParry"]=value pcall(saveSettings)
end
, nil, "FrenzyParry")controlRegistry["IgnoreAbysswalkerLunge"]=createToggle(autoparry["content"], "Ignore Abysswalker Lunge", settings["IgnoreAbysswalkerLunge"], function(value)settings["IgnoreAbysswalkerLunge"]=value pcall(saveSettings)
end
, nil, "IgnoreAbysswalkerLunge")
local conditionMet5=false
local function processValue4()
if not isFeatureAvailable()then
showNotification("Feature", "Feature unavailable.", "warning")
return
end
if conditionMet5 then
return
end
local character=localPlayer["Character"]
local humanoid=character and character:FindFirstChildOfClass("Humanoid")
local child=humanoid and humanoid:FindFirstChildOfClass("Animator")
if humanoid and child then
conditionMet5=true task["spawn"](function()
local success="109133187196613"pcall(function()
local instance=workspace:FindFirstChild(localPlayer["Name"])
local instance2=instance and instance:FindFirstChild("Parrying Dagger")
local instance3=instance2 and instance2:FindFirstChild("Main")
if instance3 then
local sound2=instance3:FindFirstChild("parry")
if sound2 and(sound2:IsA("Sound")and sound2["SoundId"]=="rbxassetid://108343313427067")then
success="126894569253341"
end
local sound3=instance3:FindFirstChild("parried")
if sound3 and(sound3:IsA("Sound")and sound3["SoundId"]=="rbxassetid://110870555206505")then
success="123307242865945"
end
end
end
)
local animation=Instance["new"]("Animation")animation["AnimationId"]="rbxassetid://"..success
local connection5=child:LoadAnimation(animation)
local speed=humanoid["WalkSpeed"]
local speed2=humanoid["JumpPower"]
local currentValue4=humanoid["UseJumpPower"]
local currentValue5=humanoid["JumpHeight"]humanoid["WalkSpeed"]=0 humanoid["JumpPower"]=0 humanoid["JumpHeight"]=0
local rootPart=character:FindFirstChild("HumanoidRootPart")
if rootPart then
rootPart["Anchored"]=true
end
local playermodule pcall(function()playermodule=(require(localPlayer["PlayerScripts"]:WaitForChild("PlayerModule"))):GetControls()playermodule:Disable()
end
)connection5:Play()
local conditionMet6=false
local connection6 connection6=connection5["Stopped"]:Connect(function()conditionMet6=true
if connection6 then
connection6:Disconnect()
end
end
)
local timestamp=tick()
while not conditionMet6 and(tick()-timestamp<5 and(humanoid and humanoid["Parent"]))do
task["wait"]()
end
if humanoid and humanoid["Parent"]then
humanoid["WalkSpeed"]=speed humanoid["JumpPower"]=speed2 humanoid["JumpHeight"]=currentValue5
end
if rootPart and rootPart["Parent"]then
rootPart["Anchored"]=false
end
if playermodule then
pcall(function()playermodule:Enable()
end
)
end
conditionMet5=false
end
)
end
end
controlRegistry["SimulateParryAnimation"]=createButton(autoparry["content"], "Simulate Parry Animation", "Trigger", processValue4, UI["AccentCyan"], "SimulateParryAnimation")controlRegistry["HideParryUI"]=createToggle(autoparry["content"], "Hide Parry Cooldown UI", settings["HideParryUI"], function(value)settings["HideParryUI"]=value pcall(saveSettings)
if value then
cleanupParryUI()
end
end
, nil, "HideParryUI")
local function getFeatureState3()
local items10={}
for key, item in pairs(items4)do
table["insert"](items10, tostring(key))
end
table["sort"](items10)
for index, item in ipairs(items10)do
end
showNotification("Parry Animations", "Printed "..(#items10.." animation IDs to F9 Console!"), "success")
end
if localPlayer["Name"]=="dontgrabme_2"then
createButton(tabCombat, "List Active/Learned Animations", "Print", getFeatureState3, UI["AccentCyan"], "PrintAnimations")
end
createSection(tabCombat, "General Aimbot", UI["AccentCyan"])
local aimassist=createCollapsibleToggle(tabCombat, "Enable Aimbot", settings["AimAssist"]["Enabled"], function(enabled3)settings["AimAssist"]["Enabled"]=enabled3 pcall(saveSettings)
end
, UI["AccentCyan"], "AimAssist")controlRegistry["AimAssist.Enabled"]={["setValue"]=aimassist["setValue"]}controlRegistry["AimAssist.Mode"]=createSelector(aimassist["content"], "Activation Mode", {"Hold Key";
"Toggle On/Off"}, {"Hold";
"Toggle"}, settings["AimAssist"]["Mode"]or"Hold", function(value)settings["AimAssist"]["Mode"]=value pcall(saveSettings)
end
)controlRegistry["AimAssist.Key"]=createSelector(aimassist["content"], "Activation Key", {"Right Mouse (M2)";
"Left Mouse (M1)", "E Key", "Q Key", "Shift Key", "🎮 Controller LT (L2)", "🎮 Controller RT (R2)", "🎮 Controller LB (L1)", "🎮 Controller RB (R1)";
"🎮 Controller L3";
"🎮 Controller R3"}, {"MouseButton2", "MouseButton1";
"E";
"Q", "LeftShift";
"ButtonL2", "ButtonR2";
"ButtonL1", "ButtonR1", "ButtonL3", "ButtonR3"}, settings["AimAssist"]["Key"]or"MouseButton2", function(value)settings["AimAssist"]["Key"]=value pcall(saveSettings)
end
)controlRegistry["AimAssist.TargetPart"]=createSelector(aimassist["content"], "Target Body Part", {"Head";
"Torso";
"HumanoidRootPart"}, {"Head";
"UpperTorso", "HumanoidRootPart"}, settings["AimAssist"]["TargetPart"]or"UpperTorso", function(value)settings["AimAssist"]["TargetPart"]=value pcall(saveSettings)
end
)controlRegistry["AimAssist.Smoothness"]=createSelector(aimassist["content"], "Aim Smoothness", {"Ultra Smooth (Legit)", "Smooth (Balanced)", "Fast";
"Instant (Rage)"}, {.05, .15, .4;
1}, settings["AimAssist"]["Smoothness"]or.15, function(value)settings["AimAssist"]["Smoothness"]=value pcall(saveSettings)
end
)controlRegistry["AimAssist.FOV"]=createSlider(aimassist["content"], "FOV Circle Radius", 30, 500, settings["AimAssist"]["FOV"]or 150, function(value)settings["AimAssist"]["FOV"]=value pcall(saveSettings)
end
, UI["AccentCyan"])controlRegistry["AimAssist.ShowFOV"]=createToggle(aimassist["content"], "Draw FOV Circle", settings["AimAssist"]["ShowFOV"], function(value)settings["AimAssist"]["ShowFOV"]=value pcall(saveSettings)
end
, nil, "AimAssistShowFOV")controlRegistry["AimAssist.TargetTeam"]=createSelector(aimassist["content"], "Target Filter", {"Survivors";
"Killer";
"Both"}, {"Survivors", "Killer", "Both"}, settings["AimAssist"]["TargetTeam"]or"Both", function(value)settings["AimAssist"]["TargetTeam"]=value pcall(saveSettings)
end
)controlRegistry["AimAssist.Prediction"]=createToggle(aimassist["content"], "Movement Prediction", settings["AimAssist"]["Prediction"], function(value)settings["AimAssist"]["Prediction"]=value pcall(saveSettings)
end
, nil, "AimAssistPrediction")createSection(tabCombat, "Revolver Autofarm", UI["AccentGreen"])controlRegistry["RevolverAutofarm"]=createToggle(tabCombat, "Enable Revolver Autofarm [BETA]", settings["RevolverAutofarm"], function(value)setRevolverAutofarm(value)
end
, UI["AccentGreen"], "RevolverAutofarm")
local revolveraimbot=createCollapsibleToggle(tabCombat, "Enable Revolver Aimbot [BETA]", settings["RevolverAimbot"]["Enabled"], function(enabled3)settings["RevolverAimbot"]["Enabled"]=enabled3 pcall(saveSettings)
end
, UI["Accent"], "RevolverAimbot")controlRegistry["RevolverAimbot.Enabled"]={["setValue"]=revolveraimbot["setValue"]}controlRegistry["RevolverAimbot.ShowFOV"]=createToggle(revolveraimbot["content"], "Show FOV Circle", settings["RevolverAimbot"]["ShowFOV"], function(value)settings["RevolverAimbot"]["ShowFOV"]=value pcall(saveSettings)
end
, nil, "RevolverAimbotShowFOV")controlRegistry["RevolverAimbot.ShowCrosshair"]=createToggle(revolveraimbot["content"], "Show Crosshair Overlay", settings["RevolverAimbot"]["ShowCrosshair"], function(value)settings["RevolverAimbot"]["ShowCrosshair"]=value pcall(saveSettings)
end
, nil, "RevolverAimbotShowCrosshair")controlRegistry["RevolverAimbot.CrosshairStyle"]=createSelector(revolveraimbot["content"], "Crosshair Style", {"Classic";
"Dot", "Circle"}, {"Classic";
"Dot";
"Circle"}, settings["RevolverAimbot"]["CrosshairStyle"]or"Classic", function(value)settings["RevolverAimbot"]["CrosshairStyle"]=value pcall(saveSettings)pcall(function()
if parryTarget then
parryTarget:Destroy()parryTarget=nil
end
end
)
end
)controlRegistry["RevolverAimbot.Key"]=createSelector(revolveraimbot["content"], "Aimbot Activation Key", {"Right Mouse", "Left Mouse", "E Key", "Q Key";
"Shift Key"}, {"MouseButton2", "MouseButton1", "E";
"Q", "LeftShift"}, settings["RevolverAimbot"]["Key"], function(value)settings["RevolverAimbot"]["Key"]=value pcall(saveSettings)
end
)controlRegistry["RevolverAimbot.TargetPart"]=createSelector(revolveraimbot["content"], "Aimbot Target Part", {"Head";
"Torso", "RootPart"}, {"Head";
"UpperTorso";
"HumanoidRootPart"}, settings["RevolverAimbot"]["TargetPart"], function(value)settings["RevolverAimbot"]["TargetPart"]=value pcall(saveSettings)
end
)controlRegistry["RevolverAimbot.Smoothness"]=createSelector(revolveraimbot["content"], "Aimbot Smoothness", {"Instant", "Very Smooth";
"Smooth", "Normal"}, {0;
.05, .15, .3}, settings["RevolverAimbot"]["Smoothness"], function(value)settings["RevolverAimbot"]["Smoothness"]=value pcall(saveSettings)
end
)controlRegistry["RevolverAimbot.Radius"]=createSlider(revolveraimbot["content"], "Aimbot FOV Radius", 50, 400, settings["RevolverAimbot"]["Radius"], function(value)settings["RevolverAimbot"]["Radius"]=value pcall(saveSettings)
end
, UI["Accent"])controlRegistry["RevolverAimbot.OffsetX"]=createSlider(revolveraimbot["content"], "Offset X (Horizontal Calibration)", -20, 20, settings["RevolverAimbot"]["OffsetX"], function(value)settings["RevolverAimbot"]["OffsetX"]=value pcall(saveSettings)
end
, UI["Accent"])controlRegistry["RevolverAimbot.OffsetY"]=createSlider(revolveraimbot["content"], "Offset Y (Vertical Calibration)", -20, 20, settings["RevolverAimbot"]["OffsetY"], function(value)settings["RevolverAimbot"]["OffsetY"]=value pcall(saveSettings)
end
, UI["Accent"])controlRegistry["RevolverAimbot.PredictionEnabled"]=createToggle(revolveraimbot["content"], "Enable Aimbot Prediction", settings["RevolverAimbot"]["PredictionEnabled"], function(enabled3)settings["RevolverAimbot"]["PredictionEnabled"]=enabled3 pcall(saveSettings)
end
, nil, "RevolverAimbotPredictionEnabled")controlRegistry["RevolverAimbot.BulletVelocity"]=createSlider(revolveraimbot["content"], "Bullet Velocity", 100, 2500, settings["RevolverAimbot"]["BulletVelocity"], function(value)settings["RevolverAimbot"]["BulletVelocity"]=value pcall(saveSettings)
end
, UI["Accent"])
local revolversilentaim=createCollapsibleToggle(tabCombat, "Revolver Silent Aim", settings["RevolverSilentAim"]and settings["RevolverSilentAim"]["Enabled"], function(enabled3)
if not settings["RevolverSilentAim"]then
settings["RevolverSilentAim"]={}
end
settings["RevolverSilentAim"]["Enabled"]=enabled3 pcall(function()
if _G["VD_RevolverSilentAimFOVCircle"]then
_G["VD_RevolverSilentAimFOVCircle"]["Visible"]=enabled3 and(settings["RevolverSilentAim"]["ShowFOV"]==true)
end
end
)pcall(saveSettings)
end
, UI["Accent"], "RevolverSilentAim")controlRegistry["RevolverSilentAim.Enabled"]={["setValue"]=revolversilentaim["setValue"]}controlRegistry["RevolverSilentAim.FOVRadius"]=createSlider(revolversilentaim["content"], "FOV Radius", 30, 600, settings["RevolverSilentAim"]and settings["RevolverSilentAim"]["FOVRadius"]or 200, function(value)
if not settings["RevolverSilentAim"]then
settings["RevolverSilentAim"]={}
end
settings["RevolverSilentAim"]["FOVRadius"]=value pcall(function()
if _G["VD_RevolverSilentAimFOVCircle"]then
_G["VD_RevolverSilentAimFOVCircle"]["Radius"]=value
end
end
)pcall(saveSettings)
end
, UI["Accent"], " px")controlRegistry["RevolverSilentAim.ShowFOV"]=createToggle(revolversilentaim["content"], "Show FOV Circle", settings["RevolverSilentAim"]and settings["RevolverSilentAim"]["ShowFOV"], function(value)
if not settings["RevolverSilentAim"]then
settings["RevolverSilentAim"]={}
end
settings["RevolverSilentAim"]["ShowFOV"]=value pcall(function()
if _G["VD_RevolverSilentAimFOVCircle"]then
_G["VD_RevolverSilentAimFOVCircle"]["Visible"]=value and(settings["RevolverSilentAim"]["Enabled"]==true)
end
end
)pcall(saveSettings)
end
, nil, "RevolverSilentAimShowFOV")
local color={["Cyan"]=Color3["fromRGB"](0, 240, 255);
["Red"]=Color3["fromRGB"](255, 50, 50);
["Green"]=Color3["fromRGB"](50, 255, 50), ["Yellow"]=Color3["fromRGB"](255, 255, 50), ["Purple"]=Color3["fromRGB"](170, 80, 255), ["Orange"]=Color3["fromRGB"](255, 125, 0);
["Pink"]=Color3["fromRGB"](255, 100, 200);
["White"]=Color3["fromRGB"](255, 255, 255)}controlRegistry["RevolverSilentAim.FOVColor"]=createSelector(revolversilentaim["content"], "FOV Circle Color", {"Cyan", "Red", "Green";
"Yellow", "Purple", "Orange";
"Pink", "White"}, {"Cyan";
"Red";
"Green";
"Yellow";
"Purple";
"Orange", "Pink", "White"}, settings["RevolverSilentAim"]and settings["RevolverSilentAim"]["FOVColor"]or"Cyan", function(color2)
if not settings["RevolverSilentAim"]then
settings["RevolverSilentAim"]={}
end
settings["RevolverSilentAim"]["FOVColor"]=color2 pcall(function()
if _G["VD_RevolverSilentAimFOVCircle"]then
_G["VD_RevolverSilentAimFOVCircle"]["Color"]=color[color2]or Color3["fromRGB"](0, 240, 255)
end
end
)pcall(saveSettings)
end
)controlRegistry["RevolverSilentAim.Target"]=createSelector(revolversilentaim["content"], "Target Mode", {"Both Teams", "Survivors", "Killer"}, {"Both Teams", "Survivors", "Killer"}, settings["RevolverSilentAim"]and settings["RevolverSilentAim"]["Target"]or"Both Teams", function(value)
if not settings["RevolverSilentAim"]then
settings["RevolverSilentAim"]={}
end
settings["RevolverSilentAim"]["Target"]=value pcall(saveSettings)
end
)controlRegistry["RevolverSilentAim.TargetHighlightEnabled"]=createToggle(revolversilentaim["content"], "Highlight Targeted Player", settings["RevolverSilentAim"]and settings["RevolverSilentAim"]["TargetHighlightEnabled"], function(enabled3)
if not settings["RevolverSilentAim"]then
settings["RevolverSilentAim"]={}
end
settings["RevolverSilentAim"]["TargetHighlightEnabled"]=enabled3 pcall(saveSettings)
end
, nil, "RevolverSilentAimTargetHighlightEnabled")controlRegistry["RevolverSilentAim.TargetHighlightColor"]=createSelector(revolversilentaim["content"], "Highlight Color", {"Cyan";
"Red";
"Green";
"Yellow", "Purple", "Orange";
"Pink", "White", "Blue"}, {"Cyan", "Red", "Green", "Yellow";
"Purple", "Orange", "Pink";
"White";
"Blue"}, settings["RevolverSilentAim"]and settings["RevolverSilentAim"]["TargetHighlightColor"]or"Cyan", function(value)
if not settings["RevolverSilentAim"]then
settings["RevolverSilentAim"]={}
end
settings["RevolverSilentAim"]["TargetHighlightColor"]=value pcall(saveSettings)
end
)createSection(tabCombat, "Killers", UI["AccentCyan"])
local accentorangeColor=createCollapsibleGroup(tabCombat, "VEIL", UI["AccentOrange"])controlRegistry["SpearTrajectory"]=createToggle(accentorangeColor["content"], "Veil Spear Trajectory", settings["SpearTrajectory"], function(value)settings["SpearTrajectory"]=value pcall(saveSettings)
end
, nil, "SpearTrajectory")controlRegistry["SpearTrajectoryNoclip"]=createToggle(accentorangeColor["content"], "Trajectory Noclip", settings["SpearTrajectoryNoclip"], function(value)settings["SpearTrajectoryNoclip"]=value pcall(saveSettings)
end
, nil, "SpearTrajectoryNoclip")controlRegistry["SpearTrajectoryColor"]=createSelector(accentorangeColor["content"], "Trajectory Color", {"Cyan";
"Red", "Green";
"Yellow", "Purple", "Orange";
"Pink";
"White"}, {"Cyan", "Red", "Green", "Yellow", "Purple", "Orange";
"Pink", "White"}, settings["SpearTrajectoryColor"]or"Cyan", function(value)settings["SpearTrajectoryColor"]=value pcall(saveSettings)pcall(setupVisuals)
end
)
local target=createCollapsibleToggle(accentorangeColor["content"], "Enable Veil Spear Aimbot", settings["SpearAimbot"]["Enabled"], function(enabled3)settings["SpearAimbot"]["Enabled"]=enabled3 pcall(saveSettings)
end
, UI["AccentOrange"], "SpearAimbot")controlRegistry["SpearAimbot.Enabled"]={["setValue"]=target["setValue"]}controlRegistry["SpearAimbot.Key"]=createSelector(target["content"], "Aimbot Activation Key", {"Right Mouse";
"Left Mouse";
"E Key", "Q Key", "Shift Key"}, {"MouseButton2", "MouseButton1";
"E", "Q";
"LeftShift"}, settings["SpearAimbot"]["Key"], function(value)settings["SpearAimbot"]["Key"]=value pcall(saveSettings)
end
)controlRegistry["SpearAimbot.TargetPart"]=createSelector(target["content"], "Aimbot Target Part", {"Head";
"Torso";
"RootPart"}, {"Head", "UpperTorso";
"HumanoidRootPart"}, settings["SpearAimbot"]["TargetPart"], function(value)settings["SpearAimbot"]["TargetPart"]=value pcall(saveSettings)
end
)controlRegistry["SpearAimbot.Smoothness"]=createSelector(target["content"], "Aimbot Smoothness", {"Instant", "Very Smooth", "Smooth";
"Normal"}, {0;
.05;
.15, .3}, settings["SpearAimbot"]["Smoothness"], function(value)settings["SpearAimbot"]["Smoothness"]=value pcall(saveSettings)
end
)controlRegistry["SpearAimbot.Radius"]=createSlider(target["content"], "Aimbot FOV Radius", 50, 400, settings["SpearAimbot"]["Radius"], function(value)settings["SpearAimbot"]["Radius"]=value pcall(saveSettings)
end
, UI["AccentOrange"])controlRegistry["SpearAimbot.PredictionOffset"]=createSlider(target["content"], "Prediction Latency Offset", 0, 200, math["floor"](((settings["SpearAimbot"]["PredictionOffset"]or.05))*1000), function(value)settings["SpearAimbot"]["PredictionOffset"]=value/1000 pcall(saveSettings)
end
, UI["AccentOrange"], " ms")
local target2=createCollapsibleToggle(accentorangeColor["content"], "Spear Silent Aim", settings["SpearSilentAim"]and settings["SpearSilentAim"]["Enabled"], function(enabled3)
if enabled3 and not((isFeatureAvailable()and(featureAvailability and featureAvailability["SpearSilentAim"])))then
showNotification("Feature", "Feature unavailable.", "warning")
return
end
if not settings["SpearSilentAim"]then
settings["SpearSilentAim"]={}
end
settings["SpearSilentAim"]["Enabled"]=enabled3 pcall(function()
if _G["VD_SpearSilentAimFOVCircle"]then
_G["VD_SpearSilentAimFOVCircle"]["Visible"]=enabled3 and(settings["SpearSilentAim"]["ShowFOV"]==true)
end
end
)pcall(saveSettings)
end
, UI["AccentOrange"], "SpearSilentAim")controlRegistry["SpearSilentAim.Enabled"]={["setValue"]=target2["setValue"]}controlRegistry["SpearSilentAim.FOVRadius"]=createSlider(target2["content"], "FOV Radius", 30, 600, settings["SpearSilentAim"]and settings["SpearSilentAim"]["FOVRadius"]or 240, function(value)
if not settings["SpearSilentAim"]then
settings["SpearSilentAim"]={}
end
settings["SpearSilentAim"]["FOVRadius"]=value pcall(function()
if _G["VD_SpearSilentAimFOVCircle"]then
_G["VD_SpearSilentAimFOVCircle"]["Radius"]=value
end
end
)pcall(saveSettings)
end
, UI["AccentOrange"], " px")controlRegistry["SpearSilentAim.ShowFOV"]=createToggle(target2["content"], "Show FOV Circle", settings["SpearSilentAim"]and settings["SpearSilentAim"]["ShowFOV"], function(value)
if not settings["SpearSilentAim"]then
settings["SpearSilentAim"]={}
end
settings["SpearSilentAim"]["ShowFOV"]=value pcall(function()
if _G["VD_SpearSilentAimFOVCircle"]then
_G["VD_SpearSilentAimFOVCircle"]["Visible"]=value and(settings["SpearSilentAim"]["Enabled"]==true)
end
end
)pcall(saveSettings)
end
, nil, "SpearSilentAimShowFOV")
local color2={["Cyan"]=Color3["fromRGB"](0, 240, 255);
["Red"]=Color3["fromRGB"](255, 50, 50);
["Green"]=Color3["fromRGB"](50, 255, 50);
["Yellow"]=Color3["fromRGB"](255, 255, 50), ["Purple"]=Color3["fromRGB"](170, 80, 255);
["Orange"]=Color3["fromRGB"](255, 125, 0);
["Pink"]=Color3["fromRGB"](255, 100, 200);
["White"]=Color3["fromRGB"](255, 255, 255)}controlRegistry["SpearSilentAim.FOVColor"]=createSelector(target2["content"], "FOV Circle Color", {"Cyan", "Red";
"Green", "Yellow";
"Purple", "Orange", "Pink";
"White"}, {"Cyan";
"Red";
"Green", "Yellow";
"Purple", "Orange", "Pink";
"White"}, settings["SpearSilentAim"]and settings["SpearSilentAim"]["FOVColor"]or"Yellow", function(color3)
if not settings["SpearSilentAim"]then
settings["SpearSilentAim"]={}
end
settings["SpearSilentAim"]["FOVColor"]=color3 pcall(function()
if _G["VD_SpearSilentAimFOVCircle"]then
_G["VD_SpearSilentAimFOVCircle"]["Color"]=color2[color3]or Color3["fromRGB"](255, 255, 50)
end
end
)pcall(saveSettings)
end
)controlRegistry["SpearSilentAim.TargetHighlightEnabled"]=createToggle(target2["content"], "Highlight Targeted Player", settings["SpearSilentAim"]and settings["SpearSilentAim"]["TargetHighlightEnabled"], function(enabled3)
if not settings["SpearSilentAim"]then
settings["SpearSilentAim"]={}
end
settings["SpearSilentAim"]["TargetHighlightEnabled"]=enabled3 pcall(saveSettings)
end
, nil, "SpearSilentAimTargetHighlightEnabled")controlRegistry["SpearSilentAim.TargetHighlightColor"]=createSelector(target2["content"], "Highlight Color", {"Cyan";
"Red", "Green";
"Yellow";
"Purple";
"Orange", "Pink";
"White", "Blue"}, {"Cyan";
"Red";
"Green", "Yellow", "Purple";
"Orange", "Pink";
"White", "Blue"}, settings["SpearSilentAim"]and settings["SpearSilentAim"]["TargetHighlightColor"]or"Red", function(value)
if not settings["SpearSilentAim"]then
settings["SpearSilentAim"]={}
end
settings["SpearSilentAim"]["TargetHighlightColor"]=value pcall(saveSettings)
end
)
local button2=createCollapsibleGroup(tabCombat, "MASKED "..((not isFeatureAvailable()and"<font color=\"#FF2A6D\">[👑]</font>"or"")), UI["AccentCyan"])
local items10={{["name"]="Richter - Stealth", ["id"]="Richter";
["bind"]="Masked_Richter"};
{["name"]="Alex - Chainsaw", ["id"]="Alex";
["bind"]="Masked_Alex"};
{["name"]="Brandon - Walk Faster", ["id"]="Brandon", ["bind"]="Masked_Brandon"};
{["name"]="Rabbit - Fast Vaults", ["id"]="Rabbit";
["bind"]="Masked_Rabbit"}, {["name"]="Cobra - Extended Lunges", ["id"]="Cobra", ["bind"]="Masked_Cobra"};
{["name"]="Tony - Lethal Punches";
["id"]="Tony";
["bind"]="Masked_Tony"}, {["name"]="Normal - No Buffs", ["id"]=nil, ["bind"]="Masked_Normal"}}
local conditionMet6=false
for index, item in ipairs(items10)do
createButton(button2["content"], item["name"], "Apply", function()
if not((isFeatureAvailable()and(featureAvailability and featureAvailability["Masked"])))then
showNotification("Feature", "Feature unavailable.", "warning")
return
end
task["spawn"](function()
if conditionMet6 then
showNotification("Masked Buff", "Activation in progress, please wait!", "warning")
return
end
conditionMet6=true
local success, result=pcall(function()
local currentValue4=game:GetService("ReplicatedStorage")
local remotes=currentValue4:WaitForChild("Remotes", 2)remotes=remotes and remotes:WaitForChild("Killers", 2)remotes=remotes and remotes:WaitForChild("Masked", 2)remotes=remotes and remotes:WaitForChild("Deactivatepower", 2)
if remotes then
remotes:FireServer()
else
currentValue4["Remotes"]["Killers"]["Masked"]["Deactivatepower"]:FireServer()
end
if item["id"]then
showNotification("Masked Buff", "Deactivated. Activating "..(item["id"].." in 4s..."), "info")task["wait"](4)
local remotes2=currentValue4:WaitForChild("Remotes", 2)remotes2=remotes2 and remotes2:WaitForChild("Killers", 2)remotes2=remotes2 and remotes2:WaitForChild("Masked", 2)remotes2=remotes2 and remotes2:WaitForChild("Activatepower", 2)
if remotes2 then
remotes2:FireServer(item["id"])
else
currentValue4["Remotes"]["Killers"]["Masked"]["Activatepower"]:FireServer(item["id"])
end
showNotification("Masked Buff", item["id"].." activated successfully!", "success")
else
showNotification("Masked Buff", "Buffs deactivated!", "success")
end
end
)
if not success then
showNotification("Masked Buff", "Error: "..tostring(result), "error")
end
conditionMet6=false
end
)
end
, UI["AccentCyan"], item["bind"])
end
local accentcyanColor=createCollapsibleGroup(tabCombat, "STALKER", UI["AccentCyan"])controlRegistry["Stalker.NoCooldown"]=createToggle(accentcyanColor["content"], "No Cooldown Stalker", settings["Stalker"]and settings["Stalker"]["NoCooldown"]or false, function(value)
if not settings["Stalker"]then
settings["Stalker"]={}
end
settings["Stalker"]["NoCooldown"]=value pcall(saveSettings)
end
, nil, "StalkerNoCooldown")controlRegistry["Stalker.KillGrab"]=createToggle(accentcyanColor["content"], "Kill Grab", settings["Stalker"]and settings["Stalker"]["KillGrab"]or false, function(value)
if not settings["Stalker"]then
settings["Stalker"]={}
end
settings["Stalker"]["KillGrab"]=value pcall(saveSettings)
end
, UI["Danger"])controlRegistry["Stalker.StalkWhileMoving"]=createToggle(accentcyanColor["content"], "Stalk While Moving", settings["Stalker"]and settings["Stalker"]["StalkWhileMoving"]or false, function(value)
if not settings["Stalker"]then
settings["Stalker"]={}
end
settings["Stalker"]["StalkWhileMoving"]=value pcall(saveSettings)
end
, nil, "StalkerStalkWhileMoving")createButton(accentcyanColor["content"], "Stalk Everyone (once)", "Run", function()task["spawn"](function()
local instance=(game:GetService("ReplicatedStorage")):FindFirstChild("Remotes")
local instance2=instance and instance:FindFirstChild("Killers")
local instance3=instance2 and instance2:FindFirstChild("Stalker")
local startstalking=instance3 and instance3:FindFirstChild("StartStalking")
if not startstalking then
showNotification("Stalker", "StartStalking remote not found!", "error")
return
end
local numericValue=0
for index, item in ipairs((game:GetService("Players")):GetPlayers())do
if item~=localPlayer then
pcall(function()startstalking:FireServer(item)
end
)numericValue=numericValue+1
end
end
showNotification("Stalker", "Stalking "..(numericValue.." players!"), "success")
end
)
end
, UI["AccentCyan"], "StalkerStalkEveryone")
local accentcyanColor2=createCollapsibleGroup(tabCombat, "ABYSSWALKER", UI["AccentCyan"])controlRegistry["Stalker.InfiniteCorrupt"]=createToggle(accentcyanColor2["content"], "Infinite Corrupt", settings["Stalker"]and settings["Stalker"]["InfiniteCorrupt"]or false, function(value)
if not settings["Stalker"]then
settings["Stalker"]={}
end
settings["Stalker"]["InfiniteCorrupt"]=value pcall(saveSettings)
end
, UI["Danger"], "StalkerInfiniteCorrupt")controlRegistry["Stalker.AutoDodge"]=createToggle(accentcyanColor2["content"], "Auto Dodge", settings["Stalker"]and settings["Stalker"]["AutoDodge"]or false, function(value)
if not settings["Stalker"]then
settings["Stalker"]={}
end
settings["Stalker"]["AutoDodge"]=value pcall(saveSettings)
end
, UI["AccentCyan"], "StalkerAutoDodge")controlRegistry["Stalker.AutoDodgeDistance"]=createSlider(accentcyanColor2["content"], "Auto Crouch Distance (studs)", 5, 50, settings["Stalker"]and settings["Stalker"]["AutoDodgeDistance"]or 15, function(value)
if not settings["Stalker"]then
settings["Stalker"]={}
end
settings["Stalker"]["AutoDodgeDistance"]=value pcall(saveSettings)
if updateAbysswalkerCircle then
pcall(updateAbysswalkerCircle, value)
end
end
, UI["AccentCyan"])createSection(tabCombat, "Modifiers", UI["AccentCyan"])controlRegistry["NoStun"]=createToggle(tabCombat, "No Stun (Killer)", settings["NoStun"], function(value)settings["NoStun"]=value pcall(saveSettings)
end
, UI["AccentCyan"], "NoStun")
end
registerConnection(UserInputService["InputBegan"]:Connect(function(input, contextValue)
if contextValue or isBindingKey then
return
end
local conditionMet5=(input["UserInputType"]==Enum["UserInputType"]["Gamepad1"]or input["UserInputType"]==Enum["UserInputType"]["Gamepad2"]or input["UserInputType"]==Enum["UserInputType"]["Gamepad3"]or input["UserInputType"]==Enum["UserInputType"]["Gamepad4"])
local conditionMet6=input["UserInputType"]==Enum["UserInputType"]["Keyboard"]or conditionMet5
local conditionMet7=input["UserInputType"]==Enum["UserInputType"]["MouseButton3"]
if conditionMet6 or conditionMet7 then
local name2=conditionMet6 and input["KeyCode"]["Name"]or input["UserInputType"]["Name"]
if name2~="Unknown"and name2~="None"then
if settings["Keybinds"]then
for key, item in pairs(settings["Keybinds"])do
if item and item~="None"then
if type(item)=="string"and item:find("+")then
local items10={}
for key2 in item:gmatch("[^+]+")do
table["insert"](items10, key2)
end
if#items10>=2 then
local conditionMet8=false
for index, item2 in ipairs(items10)do
if item2==name2 then
conditionMet8=true
break
end
end
if conditionMet8 then
local conditionMet9=true
for index, item2 in ipairs(items10)do
if item2~=name2 then
local conditionMet10=false pcall(function()
if item2=="MouseButton3"then
conditionMet10=UserInputService:IsMouseButtonPressed(Enum["UserInputType"]["MouseButton3"])
elseif Enum["KeyCode"][item2]then
conditionMet10=UserInputService:IsKeyDown(Enum["KeyCode"][item2])
end
end
)
if not conditionMet10 then
conditionMet9=false
break
end
end
end
if conditionMet9 then
local currentValue3=actionHandlers[key]
if currentValue3 then
currentValue3()
end
end
end
end
else
if item==name2 then
local currentValue3=actionHandlers[key]
if currentValue3 then
currentValue3()
end
end
end
end
end
end
end
end
end
))
local startPosition3=nil
local label3=nil
local currentValue3="All"
local cachedValue3=nil do
local function character(callback, contextValue)
local character2=localPlayer["Character"]
local rootPart=character2 and character2:FindFirstChild("HumanoidRootPart")
if not rootPart then
showNotification("Teleport", "Character root not found!", "error")
return
end
local items10={}
if callback=="Generator"then
local instance=workspace:FindFirstChild("Map")
local gens=instance and instance:FindFirstChild("Gens")
if gens then
for index, instance2 in ipairs(gens:GetChildren())do
if instance2["Name"]=="Generator"or string["find"](instance2["Name"]:lower(), "generator")then
table["insert"](items10, instance2)
end
end
end
for index, instance2 in ipairs(cachedGenerators)do
if instance2 and(instance2["Parent"]and not table["find"](items10, instance2))then
table["insert"](items10, instance2)
end
end
if#items10==0 then
for index, instance2 in ipairs(workspace:GetDescendants())do
if instance2["Name"]=="Generator"then
table["insert"](items10, instance2)
end
end
end
elseif callback=="Hook"then
for index, instance in ipairs(cachedHooks)do
if instance and instance["Parent"]then
table["insert"](items10, instance)
end
end
if#items10==0 then
for index, instance in ipairs(workspace:GetDescendants())do
if instance["Name"]=="Hook"or(instance["Name"]:lower()):find("hook")then
table["insert"](items10, instance)
end
end
end
elseif callback=="Gate"then
for index, instance in ipairs(workspace:GetDescendants())do
if instance["Name"]=="Gate"or(instance["Name"]:lower()):find("gate")or(instance["Name"]:lower()):find("door")then
table["insert"](items10, instance)
end
end
elseif callback=="Pallet"then
for index, instance in ipairs(cachedPallets)do
if instance and instance["Parent"]then
table["insert"](items10, instance)
end
end
if#items10==0 then
for index, instance in ipairs(workspace:GetDescendants())do
if instance["Name"]=="Pallet"or(instance["Name"]:lower()):find("pallet")then
table["insert"](items10, instance)
end
end
end
elseif callback=="Vault"then
for index, instance in ipairs(cachedVaults)do
if instance and instance["Parent"]then
table["insert"](items10, instance)
end
end
if#items10==0 then
for index, instance in ipairs(workspace:GetDescendants())do
if instance["Name"]=="Vault"or(instance["Name"]:lower()):find("vault")or instance["Name"]=="Window"then
table["insert"](items10, instance)
end
end
end
elseif callback=="Survivor"then
for index, player in ipairs((game:GetService("Players")):GetPlayers())do
if player~=localPlayer and(player["Team"]and(player["Team"]["Name"]=="Survivors"and(player["Character"]and player["Character"]:FindFirstChild("HumanoidRootPart"))))then
table["insert"](items10, player["Character"])
end
end
elseif callback=="Killer"then
for index, player in ipairs((game:GetService("Players")):GetPlayers())do
local teamName=false
if player["Team"]and player["Team"]["Name"]=="Killer"then
teamName=true
elseif(player["Name"]:lower()):find("killer")then
teamName=true
end
if teamName and(player["Character"]and player["Character"]:FindFirstChild("HumanoidRootPart"))then
table["insert"](items10, player["Character"])
end
end
end
local part=nil
local currentValue4=contextValue and-1 or math["huge"]
for index, instance in ipairs(items10)do
local child=instance:IsA("BasePart")and instance or instance["PrimaryPart"]or instance:FindFirstChildWhichIsA("BasePart")
if child then
local currentValue5=((child["Position"]-rootPart["Position"]))["Magnitude"]
if contextValue then
if currentValue5>currentValue4 then
currentValue4=currentValue5 part=child
end
else
if currentValue5<currentValue4 then
currentValue4=currentValue5 part=child
end
end
end
end
if part then
if _G["VD_StopAllInteractions"]then
pcall(_G["VD_StopAllInteractions"])task["wait"](.15)
end
rootPart["CFrame"]=part["CFrame"]+Vector3["new"](0, 3, 0)showNotification("Teleport", "Teleported to "..(((contextValue and"furthest"or"nearest"))..(" "..(callback.."!"))), "success")
else
showNotification("Teleport", "No "..(((contextValue and"furthest"or"nearest"))..(" "..(callback.." found!"))), "error")
end
end
local function processValue4(callback)character(callback, false)
end
local function processValue5(value)character(value, true)
end
local accentcyanColor=createCollapsibleHeader(tabTP, "Nearest Teleports", UI["AccentCyan"])createButton(accentcyanColor["content"], "TP To Nearest Generator", "TP", function()processValue4("Generator")
end
, UI["AccentCyan"], "TpNearestGenerator")createButton(accentcyanColor["content"], "TP To Nearest Hook", "TP", function()processValue4("Hook")
end
, UI["AccentCyan"], "TpNearestHook")createButton(accentcyanColor["content"], "TP To Nearest Gate", "TP", function()processValue4("Gate")
end
, UI["AccentCyan"], "TpNearestGate")createButton(accentcyanColor["content"], "TP To Nearest Pallet", "TP", function()processValue4("Pallet")
end
, UI["AccentCyan"], "TpNearestPallet")createButton(accentcyanColor["content"], "TP To Nearest Vault", "TP", function()processValue4("Vault")
end
, UI["AccentCyan"], "TpNearestVault")createButton(accentcyanColor["content"], "TP To Nearest Survivor", "TP", function()processValue4("Survivor")
end
, UI["AccentCyan"], "TpNearestSurvivor")createButton(accentcyanColor["content"], "TP To Killer", "TP", function()processValue4("Killer")
end
, UI["AccentCyan"], "TpNearestKiller")
local accentcyanColor2=createCollapsibleHeader(tabTP, "Furthest Teleports", UI["AccentCyan"])createButton(accentcyanColor2["content"], "TP To Furthest Generator", "TP", function()processValue5("Generator")
end
, UI["AccentCyan"], "TpFurthestGenerator")createButton(accentcyanColor2["content"], "TP To Furthest Hook", "TP", function()processValue5("Hook")
end
, UI["AccentCyan"], "TpFurthestHook")createButton(accentcyanColor2["content"], "TP To Furthest Gate", "TP", function()processValue5("Gate")
end
, UI["AccentCyan"], "TpFurthestGate")createButton(accentcyanColor2["content"], "TP To Furthest Pallet", "TP", function()processValue5("Pallet")
end
, UI["AccentCyan"], "TpFurthestPallet")createButton(accentcyanColor2["content"], "TP To Furthest Vault", "TP", function()processValue5("Vault")
end
, UI["AccentCyan"], "TpFurthestVault")createButton(accentcyanColor2["content"], "TP To Furthest Survivor", "TP", function()processValue5("Survivor")
end
, UI["AccentCyan"], "TpFurthestSurvivor")createSection(tabTP, "Quick Map Teleports")
local items10={}
local frame4=Instance["new"]("Frame")frame4["Size"]=UDim2["new"](1, 0, 0, 24)frame4["BackgroundTransparency"]=1 frame4["Parent"]=tabTP
local listLayout=Instance["new"]("UIListLayout")listLayout["FillDirection"]=Enum["FillDirection"]["Horizontal"]listLayout["HorizontalAlignment"]=Enum["HorizontalAlignment"]["Left"]listLayout["VerticalAlignment"]=Enum["VerticalAlignment"]["Center"]listLayout["Padding"]=UDim["new"](0, 5)listLayout["Parent"]=frame4
local items11={{["name"]="ALL";
["value"]="All"}, {["name"]="GENS", ["value"]="Generator"};
{["name"]="PALLETS";
["value"]="Pallet"};
{["name"]="VAULTS";
["value"]="Vault"};
{["name"]="GATES", ["value"]="Gate"}, {["name"]="HOOKS", ["value"]="Hook"}}
local function updateTextVisual()
for key, item in pairs(items10)do
local conditionMet5=(currentValue3==key)item["BackgroundColor3"]=conditionMet5 and UI["Accent"]or UI["Card"]item["TextColor3"]=conditionMet5 and Color3["fromRGB"](255, 255, 255)or UI["TextSub"]
local child=item:FindFirstChildOfClass("UIStroke")
if child then
child["Color"]=conditionMet5 and UI["Accent"]or UI["Stroke"]
end
end
end
for index, item in ipairs(items11)do
local button2=Instance["new"]("TextButton")button2["Size"]=UDim2["new"](0, isMobileDevice and 60 or 75, 1, 0)button2["BackgroundColor3"]=UI["Card"]button2["Text"]=item["name"]button2["TextColor3"]=UI["TextSub"]button2["Font"]=Enum["Font"]["GothamBold"]button2["TextSize"]=10 button2["AutoButtonColor"]=false button2["Parent"]=frame4;
(Instance["new"]("UICorner", button2))["CornerRadius"]=UDim["new"](0, 5)
local stroke2=Instance["new"]("UIStroke", button2)stroke2["Color"]=UI["Stroke"]stroke2["Thickness"]=1 items10[item["value"]]=button2 button2["MouseButton1Click"]:Connect(function()currentValue3=item["value"]updateTextVisual()
if cachedValue3 then
cachedValue3()
else
end
end
)
end
updateTextVisual()
local frame5=Instance["new"]("Frame")frame5["Size"]=UDim2["new"](1, 0, 0, isMobileDevice and 120 or 200)frame5["BackgroundColor3"]=UI["Card"]frame5["BackgroundTransparency"]=.5 frame5["Parent"]=tabTP;
(Instance["new"]("UICorner", frame5))["CornerRadius"]=UDim["new"](0, UI["CardRadius"]);
(Instance["new"]("UIStroke", frame5))["Color"]=UI["Stroke"]startPosition3=Instance["new"]("ScrollingFrame")startPosition3["Size"]=UDim2["new"](1, -8, 1, -8)startPosition3["Position"]=UDim2["new"](0, 4, 0, 4)startPosition3["BackgroundTransparency"]=1 startPosition3["BorderSizePixel"]=0 startPosition3["ScrollBarThickness"]=2 startPosition3["ScrollBarImageColor3"]=UI["Accent"]startPosition3["Parent"]=frame5
local listLayout2=Instance["new"]("UIListLayout")listLayout2["Padding"]=UDim["new"](0, 3)listLayout2["SortOrder"]=Enum["SortOrder"]["LayoutOrder"]listLayout2["Parent"]=startPosition3;
(listLayout2:GetPropertyChangedSignal("AbsoluteContentSize")):Connect(function()startPosition3["CanvasSize"]=UDim2["new"](0, 0, 0, listLayout2["AbsoluteContentSize"]["Y"]+6)
end
)label3=Instance["new"]("TextLabel")label3["Size"]=UDim2["new"](1, 0, 0, 30)label3["BackgroundTransparency"]=1 label3["Text"]="尚未扫描到地图对象。"label3["TextColor3"]=UI["Muted"]label3["Font"]=Enum["Font"]["Gotham"]label3["TextSize"]=13 label3["Parent"]=startPosition3
end
do
createSection(tabVisuals, "Cinematic Visuals", UI["Accent"])controlRegistry["RTXGraphics"]=createToggle(tabVisuals, "RTX Graphics Booster", settings["RTXGraphics"], function(value)
if value and not isFeatureAvailable()then
showNotification("Feature", "Feature unavailable.", "warning")
if controlRegistry["RTXGraphics"]and controlRegistry["RTXGraphics"]["setValue"]then
controlRegistry["RTXGraphics"]["setValue"](false)
end
return
end
settings["RTXGraphics"]=value pcall(saveSettings)
if updateVisuals then
pcall(updateVisuals)
end
end
, UI["Accent"])controlRegistry["CinematicDOF"]=createToggle(tabVisuals, "Cinematic Depth of Field", settings["CinematicDOF"], function(value)
if value and not isFeatureAvailable()then
showNotification("Feature", "Feature unavailable.", "warning")
if controlRegistry["CinematicDOF"]and controlRegistry["CinematicDOF"]["setValue"]then
controlRegistry["CinematicDOF"]["setValue"](false)
end
return
end
settings["CinematicDOF"]=value pcall(saveSettings)
if updateVisuals then
pcall(updateVisuals)
end
end
, UI["Accent"])controlRegistry["GraphicsTint"]=createSelector(tabVisuals, "Color Tint Preset", {"Default";
"Warm", "Cold"}, {"Default";
"Warm", "Cold"}, settings["GraphicsTint"]or"Default", function(value)settings["GraphicsTint"]=value pcall(saveSettings)
if updateVisuals then
pcall(updateVisuals)
end
end
, UI["Accent"])
local sliderControl=createSlider(tabVisuals, "Atmosphere Density", 0, 100, ((settings["AtmosphereDensity"]or.3))*100, function(value)settings["AtmosphereDensity"]=value/100 pcall(saveSettings)
if updateVisuals then
pcall(updateVisuals)
end
end
, UI["Accent"])controlRegistry["AtmosphereDensity"]={["setValue"]=function(value, contextValue)sliderControl["setValue"](value*100, contextValue)
end
}createSection(tabVisuals, "Custom Background 🖼️", UI["Accent"])
local function processValue4()
local currentValue4=listfiles or syn_io_listfiles or(list_files)
local items10={}
if currentValue4 then
local success, result=pcall(currentValue4, "")
if not success or not result then
success, result=pcall(currentValue4)
end
if success and type(result)=="table"then
for index, item in ipairs(result)do
local currentValue5=(tostring(item)):match("[^/\\]+$")or tostring(item)
local currentValue6=currentValue5:match("%.([^%.]+)$")
if currentValue6 then
currentValue6=currentValue6:lower()
if currentValue6=="png"or currentValue6=="jpg"or currentValue6=="jpeg"or currentValue6=="webp"then
table["insert"](items10, currentValue5)
end
end
end
end
end
return items10
end
local function updateVisualState(value)
local assetId={"CustomBg_AssetId", "CustomBg_LocalFile", "CustomBg_LocalBrowse", "CustomBg_Overlay";
"CustomBg_ScaleType"}
for index, item in ipairs(assetId)do
local instance=controlRegistry[item]
local tween=nil
if typeof(instance)=="Instance"and instance:IsA("GuiObject")then
tween=instance
elseif type(instance)=="table"then
if typeof(instance["container"])=="Instance"then
tween=instance["container"]
end
end
if tween then
pcall(function()(TweenService:Create(tween, TweenInfo["new"](.2), {["BackgroundTransparency"]=value and.8 or.95})):Play()
for index2, instance2 in ipairs(tween:GetDescendants())do
if instance2:IsA("TextLabel")then
(TweenService:Create(instance2, TweenInfo["new"](.2), {["TextTransparency"]=value and 0 or.5})):Play()
end
end
end
)
end
end
end
controlRegistry["CustomBg_Enabled"]=createToggle(tabVisuals, "Custom Background", settings["CustomBackground"]and settings["CustomBackground"]["Enabled"]or false, function(enabled3)
if enabled3 and((not isFeatureAvailable()or not((featureAvailability and featureAvailability["CustomBackground"]))))then
showNotification("Feature", "Feature unavailable.", "warning")
if controlRegistry["CustomBg_Enabled"]and controlRegistry["CustomBg_Enabled"]["setValue"]then
controlRegistry["CustomBg_Enabled"]["setValue"](false)
end
return
end
settings["CustomBackground"]=settings["CustomBackground"]or{}settings["CustomBackground"]["Enabled"]=enabled3 pcall(saveSettings)pcall(getFeatureState2)updateVisualState(enabled3)
end
, UI["Accent"])
local currentValue4=processValue4()
local conditionMet5=((getCustomAsset or getsynasset))~=nil
if conditionMet5 then
local items10={"(None / Custom Input)"}
local items11={""}
for index, item in ipairs(currentValue4)do
table["insert"](items10, "📁 "..item)table["insert"](items11, item)
end
local custombackground=settings["CustomBackground"]and settings["CustomBackground"]["LocalFile"]or""controlRegistry["CustomBg_LocalBrowse"]=createSelector(tabVisuals, "Browse Local Images", items10, items11, custombackground, function(value)
if not isFeatureAvailable()or not((featureAvailability and featureAvailability["CustomBackground"]))then
return
end
settings["CustomBackground"]=settings["CustomBackground"]or{}settings["CustomBackground"]["LocalFile"]=value
if controlRegistry["CustomBg_LocalFile"]and controlRegistry["CustomBg_LocalFile"]["setValue"]then
controlRegistry["CustomBg_LocalFile"]["setValue"](value)
end
pcall(saveSettings)
if settings["CustomBackground"]["Enabled"]then
pcall(getFeatureState2)
end
end
, UI["Accent"])controlRegistry["CustomBg_LocalFile"]=createInput(tabVisuals, "Local File Name", "bg.png (nella cartella workspace)", settings["CustomBackground"]and settings["CustomBackground"]["LocalFile"]or"", function(value)
if not isFeatureAvailable()or not((featureAvailability and featureAvailability["CustomBackground"]))then
return
end
settings["CustomBackground"]=settings["CustomBackground"]or{}settings["CustomBackground"]["LocalFile"]=value pcall(saveSettings)
if settings["CustomBackground"]["Enabled"]then
pcall(getFeatureState2)
end
end
)
end
controlRegistry["CustomBg_AssetId"]=createInput(tabVisuals, "Roblox Asset ID", "rbxassetid://...", settings["CustomBackground"]and settings["CustomBackground"]["AssetId"]or"", function(value)
if not isFeatureAvailable()or not((featureAvailability and featureAvailability["CustomBackground"]))then
return
end
settings["CustomBackground"]=settings["CustomBackground"]or{}settings["CustomBackground"]["AssetId"]=value pcall(saveSettings)
if settings["CustomBackground"]["Enabled"]then
pcall(getFeatureState2)
end
end
)controlRegistry["CustomBg_Overlay"]=createSlider(tabVisuals, "Background Overlay %", 0, 70, math["min"](70, settings["CustomBackground"]and settings["CustomBackground"]["Overlay"]or 40), function(value)
if not isFeatureAvailable()or not((featureAvailability and featureAvailability["CustomBackground"]))then
return
end
settings["CustomBackground"]=settings["CustomBackground"]or{}settings["CustomBackground"]["Overlay"]=math["min"](70, value)pcall(saveSettings)
if settings["CustomBackground"]["Enabled"]then
pcall(getFeatureState2)
end
end
, UI["Accent"])controlRegistry["CustomBg_ScaleType"]=createSelector(tabVisuals, "Scale Mode", {"Crop";
"Stretch", "Fit"}, {"Crop";
"Stretch", "Fit"}, settings["CustomBackground"]and settings["CustomBackground"]["ScaleType"]or"Crop", function(value)
if not isFeatureAvailable()or not((featureAvailability and featureAvailability["CustomBackground"]))then
return
end
settings["CustomBackground"]=settings["CustomBackground"]or{}settings["CustomBackground"]["ScaleType"]=value pcall(saveSettings)
if settings["CustomBackground"]["Enabled"]then
pcall(getFeatureState2)
end
end
, UI["Accent"])updateVisualState(settings["CustomBackground"]and settings["CustomBackground"]["Enabled"]or false)
if settings["CustomBackground"]and(settings["CustomBackground"]["Enabled"]and(isFeatureAvailable()and(featureAvailability and featureAvailability["CustomBackground"])))then
task["defer"](getFeatureState2)
end
createSection(tabVisuals, "Lighting & Visibility", UI["AccentCyan"])controlRegistry["FOV"]=createSlider(tabVisuals, "Field of View", 70, 160, settings["FOV"], function(value)settings["FOV"]=value
local camera=workspace["CurrentCamera"]
if camera then
camera["FieldOfView"]=value
end
pcall(saveSettings)
end
, UI["AccentCyan"])
local items10={"Normal (16:9)";
"4:3 Stretched";
"5:4 Stretched";
"16:10 Stretched", "21:9 Stretched"}
local items11={"Normal";
"4:3";
"5:4";
"16:10";
"21:9"}controlRegistry["StretchedResolutionMode"]=createSelector(tabVisuals, "Stretched Resolution", items10, items11, settings["StretchedResolutionMode"]or"Normal", function(value)settings["StretchedResolutionMode"]=value pcall(saveSettings)
end
, UI["AccentCyan"])controlRegistry["NoFog"]=createToggle(tabVisuals, "No Fog", settings["NoFog"], function(value)settings["NoFog"]=value pcall(saveSettings)pcall(forceNoFog)
if not value then
pcall(function()
local currentValue5=game:GetService("Lighting")
if defaultLightingSettings then
currentValue5["FogStart"]=defaultLightingSettings["FogStart"]currentValue5["FogEnd"]=defaultLightingSettings["FogEnd"]
end
for index, instance in ipairs(currentValue5:GetDescendants())do
if instance:IsA("Atmosphere")then
instance["Density"]=.3 instance["Haze"]=0
end
end
end
)
end
end
, UI["AccentCyan"])controlRegistry["FullBright"]=createToggle(tabVisuals, "Full Bright", settings["FullBright"], function(value)settings["FullBright"]=value pcall(saveSettings)pcall(forceFullBright)
if not value then
pcall(function()
local currentValue5=game:GetService("Lighting")
if defaultLightingSettings then
currentValue5["Brightness"]=defaultLightingSettings["Brightness"]currentValue5["ClockTime"]=defaultLightingSettings["ClockTime"]currentValue5["Ambient"]=defaultLightingSettings["Ambient"]currentValue5["OutdoorAmbient"]=defaultLightingSettings["OutdoorAmbient"]currentValue5["GlobalShadows"]=defaultLightingSettings["GlobalShadows"]
end
end
)
end
end
, UI["AccentCyan"])controlRegistry["KillerThirdPerson"]=createToggle(tabVisuals, "Killer Third Person", settings["KillerThirdPerson"], function(value)settings["KillerThirdPerson"]=value pcall(saveSettings)
end
, UI["AccentCyan"])controlRegistry["InfiniteZoom"]=createToggle(tabVisuals, "Infinite Zoom", settings["InfiniteZoom"], function(value)settings["InfiniteZoom"]=value pcall(saveSettings)
end
, UI["AccentCyan"])createSection(tabVisuals, "Network Manipulation", UI["Danger"])
local fakelag=createCollapsibleToggle(tabVisuals, "Fake Lag", settings["FakeLag"], function(value)
if value and not isFeatureAvailable()then
showNotification("Feature", "Feature unavailable.", "warning")settings["FakeLag"]=false pcall(saveSettings)
if fakeLagGroup and fakeLagGroup["setValue"]then
fakeLagGroup["setValue"](false)
end
return
end
settings["FakeLag"]=value pcall(saveSettings)
end
, UI["Danger"], "FakeLag")controlRegistry["FakeLag"]={["setValue"]=fakelag["setValue"]}controlRegistry["FakeLagMs"]=createSlider(fakelag["content"], "Lag Amount (ms)", 50, 1000, settings["FakeLagMs"]or 200, function(value)settings["FakeLagMs"]=value pcall(saveSettings)
end
, UI["Danger"])createToggle(fakelag["content"], "Show Position Ghost", settings["EnableDesyncGhost"], function(value)settings["EnableDesyncGhost"]=value pcall(saveSettings)
if not value then
pcall(function()destroyDesyncGhost()
end
)
else
pcall(function()updateDesyncGhostAppearance()
end
)
end
if controlRegistry["EnableDesyncGhost"]and controlRegistry["EnableDesyncGhost"]["setValue"]then
controlRegistry["EnableDesyncGhost"]["setValue"](value)
end
end
, nil, "FakeLagGhost")
local desync=createCollapsibleToggle(tabVisuals, "Network Desync", settings["Desync"], function(value)
if value and not isFeatureAvailable()then
showNotification("Feature", "Feature unavailable.", "warning")settings["Desync"]=false pcall(saveSettings)
if desyncGroup and desyncGroup["setValue"]then
desyncGroup["setValue"](false)
end
return
end
settings["Desync"]=value pcall(saveSettings)
end
, UI["Danger"], "Desync")controlRegistry["Desync"]={["setValue"]=desync["setValue"]}
local accentColor={["Accent"]=UI["Accent"], ["Cyan"]=Color3["fromRGB"](0, 255, 255);
["Purple"]=Color3["fromRGB"](180, 50, 255), ["Green"]=Color3["fromRGB"](0, 255, 120);
["Red"]=Color3["fromRGB"](255, 60, 60), ["Yellow"]=Color3["fromRGB"](255, 220, 0);
["White"]=Color3["fromRGB"](255, 255, 255)}controlRegistry["EnableDesyncGhost"]=createToggle(desync["content"], "Show Visual Ghost", settings["EnableDesyncGhost"], function(value)settings["EnableDesyncGhost"]=value pcall(saveSettings)
if not value then
destroyDesyncGhost()
else
updateDesyncGhostAppearance()
end
end
, nil, "EnableDesyncGhost")controlRegistry["DesyncGhostAlwaysOnTop"]=createToggle(desync["content"], "Ghost Always On Top (Behind Walls)", settings["DesyncGhostAlwaysOnTop"], function(value)settings["DesyncGhostAlwaysOnTop"]=value pcall(saveSettings)updateDesyncGhostAppearance()
end
, nil, "DesyncGhostAlwaysOnTop")controlRegistry["DesyncGhostTransparency"]=createSlider(desync["content"], "Ghost Transparency", 0, 100, ((settings["DesyncGhostTransparency"]or.5))*100, function(value)settings["DesyncGhostTransparency"]=value/100 pcall(saveSettings)updateDesyncGhostAppearance()
end
)controlRegistry["DesyncGhostColor"]=createSelector(desync["content"], "Ghost Color", {"Accent";
"Cyan", "Purple", "Green";
"Red";
"Yellow", "White"}, {"Accent", "Cyan", "Purple";
"Green";
"Red", "Yellow";
"White"}, settings["DesyncGhostColor"]or"Accent", function(value)settings["DesyncGhostColor"]=value pcall(saveSettings)updateDesyncGhostAppearance()
end
)controlRegistry["NoFlashlightBlind"]=createToggle(tabVisuals, "No Flashlight Blind", settings["NoFlashlightBlind"], function(value)settings["NoFlashlightBlind"]=value pcall(saveSettings)
if value then
pcall(function()
local child=localPlayer:FindFirstChildOfClass("PlayerGui")
if child then
for index, container in ipairs(child:GetDescendants())do
if container["Name"]=="Blind"and container:IsA("GuiObject")then
container["Visible"]=false
if container:IsA("Frame")or container:IsA("ImageLabel")then
container["BackgroundTransparency"]=1
end
end
end
end
end
)
end
end
, UI["AccentCyan"], "NoFlashlightBlind")createSection(tabVisuals, "Crosshair Settings", UI["AccentCyan"])controlRegistry["ShowCrosshair"]=createToggle(tabVisuals, "Show Custom Crosshair", settings["ShowCrosshair"], function(value)settings["ShowCrosshair"]=value pcall(saveSettings)
if updateCrosshair then
pcall(updateCrosshair)
end
end
, UI["AccentCyan"])controlRegistry["CrosshairStyle"]=createSelector(tabVisuals, "Crosshair Style", {"Classic";
"Dot";
"Circle", "Dot & Circle";
"Tactical"}, {"Classic";
"Dot", "Circle", "Dot & Circle", "Tactical"}, settings["CrosshairStyle"]or"Classic", function(value)settings["CrosshairStyle"]=value pcall(saveSettings)
if updateCrosshair then
pcall(updateCrosshair)
end
end
, UI["AccentCyan"])controlRegistry["CrosshairSize"]=createSlider(tabVisuals, "Crosshair Size", 4, 30, settings["CrosshairSize"]or 10, function(value)settings["CrosshairSize"]=value pcall(saveSettings)
if updateCrosshair then
pcall(updateCrosshair)
end
end
, UI["AccentCyan"])
local crosshaircolor=settings["CrosshairColor"]or Color3["fromRGB"](0, 255, 255)createColorWheel(tabVisuals, "Crosshair Color", crosshaircolor, function(value)settings["CrosshairColor"]=value pcall(saveSettings)
if updateCrosshair then
pcall(updateCrosshair)
end
end
)createSection(tabVisuals, "Visuals Customizer", UI["AccentCyan"])
local accentcyanColor=createCollapsibleGroup(tabVisuals, "Flashlight", UI["AccentCyan"])controlRegistry["FlashlightEffect"]=createSelector(accentcyanColor["content"], "Flashlight Effect", {"None", "Rainbow", "Strobe";
"Ultra Bright"}, {"None";
"Rainbow";
"Strobe", "Ultra Bright"}, settings["FlashlightEffect"]or"None", function(value)settings["FlashlightEffect"]=value pcall(saveSettings)
end
, UI["AccentCyan"])
local flashlightcolor=settings["FlashlightColor"]or Color3["fromRGB"](255, 255, 255)createColorWheel(accentcyanColor["content"], "Flashlight Color", flashlightcolor, function(value)settings["FlashlightColor"]=value pcall(saveSettings)
end
)
local accentcyanColor2=createCollapsibleGroup(tabVisuals, "Killer Stain Color", UI["AccentCyan"])
local killerstaincolor=settings["KillerStainColor"]or Color3["fromRGB"](255, 0, 0)createColorWheel(accentcyanColor2["content"], "Killer Stain Color", killerstaincolor, function(value)settings["KillerStainColor"]=value pcall(saveSettings)
end
)createSection(tabVisuals, "HUD Customizer", UI["AccentCyan"])controlRegistry["HideLivePlayersMode"]=createSelector(tabVisuals, "Live Players List", {"Normal", "Hide", "Overlay (Logo)", "Overlay (Custom)"}, {"Normal", "Hide";
"Overlay (Logo)";
"Overlay (Custom)"}, settings["HideLivePlayersMode"]or"Normal", function(value)settings["HideLivePlayersMode"]=value pcall(saveSettings)
end
, UI["AccentCyan"])controlRegistry["CustomOverlayUrl"]=createInput(tabVisuals, "Custom Overlay Asset ID", "rbxassetid://...", settings["CustomOverlayUrl"]or"rbxassetid://71824917786372", function(value)settings["CustomOverlayUrl"]=value pcall(saveSettings)
end
)
end
switchTab("ESP")


--// 功能层：自动化、战斗、移动与运行循环

function updateFarmStatus(state)
local items10={["OFF"]="OFF", ["IDLE"]="Idle...";
["REPAIRING"]="Repairing Generator";
["RESCUING"]="Saving Comrade", ["OPENINGGATE"]="Opening Exit Gate", ["FLEEING"]="Fleeing Killer", ["ESCAPING"]="Escaping Match";
["ESCAPED"]="ESCAPED", ["HUNTING"]="Hunting Survivor";
["CARRYING"]="Carrying Survivor";
["HANGING"]="Hanging Survivor";
["PAUSED (Knocked/Hooked)"]="PAUSED (Knocked/Hooked)", ["PAUSED (Spectating/Lobby)"]="PAUSED (Spectating/Lobby)", ["PAUSED (Killer Team)"]="PAUSED (Killer Team)", ["PAUSED (Survivors Team)"]="PAUSED (Survivors Team)"}
local mutedColor={["OFF"]=UI["Muted"], ["IDLE"]=UI["TextSub"];
["REPAIRING"]=UI["AccentCyan"];
["RESCUING"]=UI["Warning"];
["OPENINGGATE"]=UI["AccentGreen"], ["FLEEING"]=UI["Danger"], ["ESCAPING"]=UI["AccentGreen"], ["ESCAPED"]=UI["AccentGreen"], ["HUNTING"]=UI["Danger"];
["CARRYING"]=UI["Warning"];
["HANGING"]=UI["AccentCyan"], ["PAUSED (Knocked/Hooked)"]=Color3["fromRGB"](200, 200, 50);
["PAUSED (Spectating/Lobby)"]=UI["Muted"];
["PAUSED (Killer Team)"]=UI["Danger"], ["PAUSED (Survivors Team)"]=UI["Danger"]}
local text=items10[state]or tostring(state)
local mutedColor2=mutedColor[state]or UI["Muted"]
if(tostring(state)):find("WAITING")then
mutedColor2=UI["AccentCyan"]
end
if _G["VD_HomeStatusLabel"]then
_G["VD_HomeStatusLabel"]["Text"]=text _G["VD_HomeStatusLabel"]["TextColor3"]=mutedColor2
end
if _G["VD_HomeStatusDot"]then
_G["VD_HomeStatusDot"]["BackgroundColor3"]=mutedColor2
end
if label2 then
label2["Text"]="状态："..text label2["TextColor3"]=mutedColor2
end
end
_G["VD_UpdateFarmStatus"]=updateFarmStatus
local currentValue4="None"
local enabled3=false
local cachedValue4=nil
local connection5=nil
local currentValue5=false task["spawn"](function()
local numericValue=0
local numericValue2=0
local enabled4=false
while activeLoop do
task["wait"](.05)numericValue2=numericValue2+1
if numericValue2>=2 then
numericValue2=0 enabled4=not enabled4
end
pcall(function()
if numericValue2%4==0 then
local killerstaincolor=settings["KillerStainColor"]or Color3["fromRGB"](255, 0, 0)
for index, player in ipairs((game:GetService("Players")):GetPlayers())do
local instance=player["Character"]
local instance2=instance and instance:FindFirstChild("Head")
local instance3=instance2 and instance2:FindFirstChild("RedSurfaceLight")
if instance3 and instance3:IsA("Light")then
if instance3["Color"]~=killerstaincolor then
instance3["Color"]=killerstaincolor
end
end
end
end
local character=localPlayer["Character"]
local instance=character and character:FindFirstChild("Flashlight")
if instance then
local spotlight=instance:FindFirstChildOfClass("SpotLight")or instance:FindFirstChild("SpotLight", true)
if spotlight then
if spotlight~=cachedValue4 then
if connection5 then
pcall(function()connection5:Disconnect()
end
)
end
cachedValue4=spotlight enabled3=spotlight["Enabled"]connection5=(spotlight:GetPropertyChangedSignal("Enabled")):Connect(function()
if currentValue5 then
return
end
enabled3=spotlight["Enabled"]
end
)registerConnection(connection5)
end
local flashlightcolor=settings["FlashlightColor"]or Color3["fromRGB"](255, 255, 255)
if settings["FlashlightEffect"]=="Rainbow"then
numericValue=((numericValue+.008))%1 flashlightcolor=Color3["fromHSV"](numericValue, 1, 1)
end
for index, instance2 in ipairs(instance:GetDescendants())do
if instance2:IsA("Light")then
instance2["Color"]=flashlightcolor
if enabled3 then
if settings["FlashlightEffect"]=="Ultra Bright"then
currentValue5=true instance2["Enabled"]=true currentValue5=false instance2["Range"]=250 instance2["Brightness"]=15
elseif settings["FlashlightEffect"]=="Strobe"then
currentValue5=true instance2["Enabled"]=enabled4 currentValue5=false
else
if currentValue4=="Ultra Bright"then
instance2["Range"]=51 instance2["Brightness"]=1
end
end
else
currentValue5=true instance2["Enabled"]=false currentValue5=false
if currentValue4=="Ultra Bright"then
instance2["Range"]=51 instance2["Brightness"]=1
end
end
elseif instance2:IsA("Beam")then
instance2["Color"]=ColorSequence["new"](flashlightcolor)
if enabled3 then
if settings["FlashlightEffect"]=="Strobe"then
instance2["Enabled"]=enabled4
elseif settings["FlashlightEffect"]=="Ultra Bright"then
instance2["Enabled"]=true
end
else
instance2["Enabled"]=false
end
elseif instance2:IsA("BasePart")then
local name2=instance2["Name"]:lower()
if name2:find("beam")or name2:find("light")or name2:find("cone")or(instance2["Transparency"]>0 and instance2["Transparency"]<1)then
instance2["Color"]=flashlightcolor
if enabled3 then
if settings["FlashlightEffect"]=="Strobe"then
instance2["Transparency"]=enabled4 and.5 or 1
elseif settings["FlashlightEffect"]=="Ultra Bright"then
instance2["Transparency"]=.4
end
else
instance2["Transparency"]=1
end
end
end
end
end
currentValue4=settings["FlashlightEffect"]
end
end
)
end
end
)updateFarmStatus("OFF")task["spawn"](function()
while activeLoop do
local success, result=pcall(updateTelemetryAndAFKStates)
if not success then
warn("[Violence District Telemetry Loop Error]: "..tostring(result))
end
task["wait"](.2)
end
end
)
local color={["Generator"]=Color3["fromRGB"](0, 210, 255);
["Hook"]=Color3["fromRGB"](255, 150, 0);
["Pallet"]=Color3["fromRGB"](200, 160, 80);
["Vault"]=Color3["fromRGB"](180, 180, 180);
["Gate"]=Color3["fromRGB"](255, 255, 0)}
local items10={}function teleportToInstance(instance)
if not localPlayer or not localPlayer["Character"]or not localPlayer["Character"]:FindFirstChild("HumanoidRootPart")then
return
end
local part
if instance:IsA("Model")then
part=instance["PrimaryPart"]or instance:FindFirstChildWhichIsA("BasePart")
elseif instance:IsA("BasePart")then
part=instance
end
if part then
if _G["VD_StopAllInteractions"]then
pcall(_G["VD_StopAllInteractions"])task["wait"](.15)
end
localPlayer["Character"]["HumanoidRootPart"]["CFrame"]=part["CFrame"]+Vector3["new"](0, 4, 0)
end
end
function clearTPRows()
for key, item in pairs(items10)do
if item["row"]then
item["row"]:Destroy()
end
items10[key]=nil
end
end
function createTPRow(labelText)
local currentValue6=labelText["instance"]
local color2=color[labelText["label"]]or Color3["fromRGB"](200, 200, 200)
local button2=Instance["new"]("TextButton")button2["Size"]=UDim2["new"](1, 0, 0, 26)button2["BackgroundColor3"]=UI["Card"]button2["BorderSizePixel"]=0 button2["Text"]=""button2["AutoButtonColor"]=false button2["Parent"]=startPosition3
local corner=Instance["new"]("UICorner")corner["CornerRadius"]=UDim["new"](0, 5)corner["Parent"]=button2
local frame4=Instance["new"]("Frame")frame4["Size"]=UDim2["new"](0, 3, 1, -6)frame4["Position"]=UDim2["new"](0, 4, 0, 3)frame4["BackgroundColor3"]=color2 frame4["BorderSizePixel"]=0 frame4["Parent"]=button2;
(Instance["new"]("UICorner", frame4))["CornerRadius"]=UDim["new"](0, 1.5)
local label4=Instance["new"]("TextLabel")label4["Size"]=UDim2["new"](1, -16, 1, 0)label4["Position"]=UDim2["new"](0, 12, 0, 0)label4["BackgroundTransparency"]=1 label4["Text"]=string["format"]("%s  [%dm]", translateText(labelText["label"]), labelText["dist"])label4["TextColor3"]=color2 label4["Font"]=Enum["Font"]["GothamBold"]label4["TextSize"]=11 label4["TextXAlignment"]=Enum["TextXAlignment"]["Left"]label4["Parent"]=button2 button2["MouseEnter"]:Connect(function()(TweenService:Create(button2, TweenInfo["new"](.1), {["BackgroundColor3"]=UI["HoverCard"]})):Play()
end
)button2["MouseLeave"]:Connect(function()(TweenService:Create(button2, TweenInfo["new"](.1), {["BackgroundColor3"]=UI["Card"]})):Play()
end
)button2["MouseButton1Click"]:Connect(function()
if currentValue6 and currentValue6["Parent"]then
teleportToInstance(currentValue6)
end
end
)items10[currentValue6]={["row"]=button2;
["label"]=label4, ["typeLabel"]=labelText["label"]}
end
function collectTPEntries()
local items11={}
if currentValue3=="All"or currentValue3=="Generator"then
for index, instance in ipairs(cachedGenerators)do
if instance and(instance["Parent"]and not isGeneratorCompleted(instance))then
table["insert"](items11, {["instance"]=instance, ["label"]="Generator"})
end
end
end
if currentValue3=="All"or currentValue3=="Hook"then
for index, instance in ipairs(cachedHooks)do
if instance and instance["Parent"]then
table["insert"](items11, {["instance"]=instance;
["label"]="Hook"})
end
end
end
if currentValue3=="All"or currentValue3=="Pallet"then
for index, instance in ipairs(cachedPallets)do
if instance and instance["Parent"]then
table["insert"](items11, {["instance"]=instance;
["label"]="Pallet"})
end
end
end
if currentValue3=="All"or currentValue3=="Vault"then
for index, instance in ipairs(cachedVaults)do
if instance and instance["Parent"]then
table["insert"](items11, {["instance"]=instance, ["label"]="Vault"})
end
end
end
if currentValue3=="All"or currentValue3=="Gate"then
for index, instance in ipairs(cachedGates)do
if instance and instance["Parent"]then
table["insert"](items11, {["instance"]=instance;
["label"]="Gate"})
end
end
end
for index, item in ipairs(items11)do
item["dist"]=getDistance(item["instance"])
end
table["sort"](items11, function(value, contextValue)
return value["dist"]<contextValue["dist"]
end
)
return items11
end
cachedValue3=function()
local currentValue6=collectTPEntries()clearTPRows()
if#currentValue6==0 then
if label3 then
label3["Visible"]=true
end
return
end
if label3 then
label3["Visible"]=false
end
for index, item in ipairs(currentValue6)do
createTPRow(item)
end
end
function updateTPMenuDistances()
for key, item in pairs(items10)do
if not key["Parent"]then
if item["row"]then
item["row"]:Destroy()
end
items10[key]=nil
else
local distance=getDistance(key)
local text=string["format"]("%s  [%dm]", item["typeLabel"], distance)
if item["label"]["Text"]~=text then
item["label"]["Text"]=text
end
end
end
end
function makeDraggable(frame4, dragHandle)
local currentValue6, connection6, currentValue7, layoutPosition
local function processValue4(position)
local layoutPosition2=position["Position"]-currentValue7 frame4["Position"]=UDim2["new"](layoutPosition["X"]["Scale"], layoutPosition["X"]["Offset"]+layoutPosition2["X"], layoutPosition["Y"]["Scale"], layoutPosition["Y"]["Offset"]+layoutPosition2["Y"])
end
dragHandle["InputBegan"]:Connect(function(input)
if input["UserInputType"]==Enum["UserInputType"]["MouseButton1"]or input["UserInputType"]==Enum["UserInputType"]["Touch"]then
currentValue6=true currentValue7=input["Position"]layoutPosition=frame4["Position"]input["Changed"]:Connect(function()
if input["UserInputState"]==Enum["UserInputState"]["End"]then
currentValue6=false
end
end
)
end
end
)dragHandle["InputChanged"]:Connect(function(input)
if input["UserInputType"]==Enum["UserInputType"]["MouseMovement"]or input["UserInputType"]==Enum["UserInputType"]["Touch"]then
connection6=input
end
end
)registerConnection(UserInputService["InputChanged"]:Connect(function(value)
if value==connection6 and currentValue6 then
processValue4(value)
end
end
))
end
makeDraggable(mainFrame, titleBar)function makeResizable(position, contextValue)
local conditionMet5=false
local startPosition4=nil
local startPosition5=nil
local connection6=nil contextValue["InputBegan"]:Connect(function(input)
if input["UserInputType"]==Enum["UserInputType"]["MouseButton1"]or input["UserInputType"]==Enum["UserInputType"]["Touch"]then
conditionMet5=true startPosition4=input["Position"]startPosition5=position["Size"]input["Changed"]:Connect(function()
if input["UserInputState"]==Enum["UserInputState"]["End"]then
conditionMet5=false
end
end
)
end
end
)contextValue["InputChanged"]:Connect(function(input)
if input["UserInputType"]==Enum["UserInputType"]["MouseMovement"]or input["UserInputType"]==Enum["UserInputType"]["Touch"]then
connection6=input
end
end
)registerConnection(UserInputService["InputChanged"]:Connect(function(position2)
if position2==connection6 and conditionMet5 then
local currentValue6=position2["Position"]-startPosition4
local clampedValue=math["clamp"](startPosition5["X"]["Offset"]+currentValue6["X"], 420, 1000)
local layoutPosition=math["clamp"](startPosition5["Y"]["Offset"]+currentValue6["Y"], 260, 800)position["Size"]=UDim2["new"](0, clampedValue, 0, layoutPosition)UI["MainW"]=clampedValue UI["MainH"]=layoutPosition
end
end
))
end
local button2=Instance["new"]("TextButton")button2["Name"]="ResizeHandle"button2["AnchorPoint"]=Vector2["new"](1, 1)button2["Size"]=UDim2["new"](0, 115, 0, 22)button2["Position"]=UDim2["new"](1, -10, 1, -10)button2["BackgroundColor3"]=UI["Elevated"]button2["BackgroundTransparency"]=.3 button2["Text"]="拖动调整大小"button2["TextColor3"]=UI["TextSub"]button2["Font"]=Enum["Font"]["GothamBold"]button2["TextSize"]=10 button2["AutoButtonColor"]=false button2["Active"]=true button2["ZIndex"]=100 button2["Parent"]=mainFrame
local corner=Instance["new"]("UICorner", button2)corner["CornerRadius"]=UDim["new"](0, 6)
local stroke2=Instance["new"]("UIStroke", button2)stroke2["Color"]=UI["Stroke"]stroke2["Thickness"]=1.2 button2["MouseEnter"]:Connect(function()(TweenService:Create(button2, TweenInfo["new"](.2, Enum["EasingStyle"]["Quad"], Enum["EasingDirection"]["Out"]), {["Size"]=UDim2["new"](0, 121, 0, 24);
["BackgroundColor3"]=UI["HoverCard"], ["BackgroundTransparency"]=.2;
["TextColor3"]=UI["Text"]})):Play();
(TweenService:Create(stroke2, TweenInfo["new"](.2, Enum["EasingStyle"]["Quad"], Enum["EasingDirection"]["Out"]), {["Thickness"]=1.4})):Play()
end
)button2["MouseLeave"]:Connect(function()(TweenService:Create(button2, TweenInfo["new"](.2, Enum["EasingStyle"]["Quad"], Enum["EasingDirection"]["Out"]), {["Size"]=UDim2["new"](0, 115, 0, 22);
["BackgroundColor3"]=UI["Elevated"];
["BackgroundTransparency"]=.3;
["TextColor3"]=UI["TextSub"]})):Play();
(TweenService:Create(stroke2, TweenInfo["new"](.2, Enum["EasingStyle"]["Quad"], Enum["EasingDirection"]["Out"]), {["Thickness"]=1.2})):Play()
end
)makeResizable(mainFrame, button2)
local conditionMet5=false
local conditionMet6=false
local cachedValue5=nil
local function processValue4()
if not mainFrame then return end
conditionMet6=not conditionMet6
local sidebar=mainFrame:FindFirstChild("Sidebar")
local contentroot=mainFrame:FindFirstChild("ContentRoot")
local resizehandle=mainFrame:FindFirstChild("ResizeHandle")
if conditionMet6 then
cachedValue5=mainFrame["Size"]
if sidebar then sidebar["Visible"]=false end
if contentroot then contentroot["Visible"]=false end
if resizehandle then resizehandle["Visible"]=false end
minBtn["Text"]="□"
(TweenService:Create(mainFrame,TweenInfo["new"](.12,Enum["EasingStyle"]["Quad"],Enum["EasingDirection"]["Out"]),{["Size"]=UDim2["new"](0,math["max"](320,mainFrame["AbsoluteSize"]["X"]),0,UI["TitleH"])})):Play()
else
local mainwColor=cachedValue5 or UDim2["new"](0,UI["MainW"],0,UI["MainH"])
minBtn["Text"]="—"
(TweenService:Create(mainFrame,TweenInfo["new"](.12,Enum["EasingStyle"]["Quad"],Enum["EasingDirection"]["Out"]),{["Size"]=mainwColor})):Play()
task["delay"](.12,function()
if sidebar then sidebar["Visible"]=true end
if contentroot then contentroot["Visible"]=true end
if resizehandle then resizehandle["Visible"]=true end
end)
end
end
minBtn["MouseButton1Click"]:Connect(processValue4)
function doCleanup()activeLoop=false pcall(function()
local child=localPlayer:FindFirstChildOfClass("PlayerGui")
if child then
local items11={}
local items12={}
for index, instance in ipairs(child:GetDescendants())do
if instance:IsA("GuiObject")and instance["Name"]:find("^Survivor%d+$")then
local currentValue6=instance["Parent"]
if currentValue6 and not items12[currentValue6]then
items12[currentValue6]=true table["insert"](items11, currentValue6)
end
end
end
for index, container in ipairs(items11)do
if container:GetAttribute("OrigVisible")~=nil then
container["Visible"]=container:GetAttribute("OrigVisible")container:SetAttribute("OrigVisible", nil)
end
for index2, container2 in ipairs(container:GetChildren())do
if container2:IsA("GuiObject")and container2["Name"]:find("^Survivor%d+$")then
if container2:GetAttribute("OrigVisible")~=nil then
container2["Visible"]=container2:GetAttribute("OrigVisible")container2:SetAttribute("OrigVisible", nil)
end
end
end
container:SetAttribute("CachedOverlayPos", nil)container:SetAttribute("CachedOverlaySize", nil)
local violencedistrictoverlay=container:FindFirstChild("ViolenceDistrictOverlay")
if violencedistrictoverlay then
violencedistrictoverlay:Destroy()
end
end
end
end
)pcall(function()
if activeDropdown then
activeDropdown:Destroy()activeDropdown=nil
end
end
)pcall(function()
if currentEmoteTrack then
currentEmoteTrack:Stop()currentEmoteTrack=nil
end
if currentEmoteSound then
currentEmoteSound:Stop()currentEmoteSound:Destroy()currentEmoteSound=nil
end
end
)pcall(function()
if updateMouseCapture2 then
updateMouseCapture2()
end
end
)cleanupAll()
for index, item in ipairs(scriptConnections)do
pcall(function()item:Disconnect()
end
)
end
scriptConnections={}
if currentFarmTarget then
pcall(function()currentFarmTarget:Disconnect()
end
)currentFarmTarget=nil
end
if farmHeartbeatConnection then
pcall(function()farmHeartbeatConnection:Disconnect()
end
)farmHeartbeatConnection=nil
end
if currentFarmState then
pcall(function()currentFarmState:Disconnect()
end
)currentFarmState=nil
end
if _G["HeartbeatConnection"]then
pcall(function()_G["HeartbeatConnection"]:Disconnect()
end
)
end
pcall(function()RunService:UnbindFromRenderStep("VD_Aimbot")
end
)pcall(function()RunService:UnbindFromRenderStep("VD_AimAssist")
end
)pcall(function()RunService:UnbindFromRenderStep("VD_CameraStretch")
end
)spearTarget=nil aimAssistTarget=nil aimAssistToggleState=false isMobileAimAssistActive=false
if settings and settings["AimAssist"]then
settings["AimAssist"]["Enabled"]=false
end
pcall(function()
if items2 then
for key, item in pairs(items2)do
if key and key["Parent"]then
setObjectValue(key, "speedboost", item)
end
end
table["clear"](items2)
end
if connections then
for key, item in pairs(connections)do
pcall(function()item:Disconnect()
end
)
end
table["clear"](connections)
end
if items3 then
table["clear"](items3)
end
end
)pcall(function()
local name2=localPlayer["Name"]
local items11={}
if localPlayer["Character"]then
table["insert"](items11, localPlayer["Character"])
end
local instance=workspace:FindFirstChild(name2)
if instance and(instance:IsA("Model")and not table["find"](items11, instance))then
table["insert"](items11, instance)
end
local items12={"climb_obsessing", "climb_collisoning", "climb_collisioning", "climb_colliding"}
for index, item in ipairs(items12)do
local instance2=workspace:FindFirstChild(item)
if instance2 then
local instance3=instance2:FindFirstChild(name2)
if instance3 and(instance3:IsA("Model")and not table["find"](items11, instance3))then
table["insert"](items11, instance3)
end
end
end
for index, item in ipairs(items11)do
pcall(function()item:SetAttribute("Flowstate", nil)
end
)
end
pcall(function()localPlayer:SetAttribute("Flowstate", nil)
end
)
end
)pcall(function()
local instance=localPlayer:FindFirstChildOfClass("PlayerGui")
local vdMobilehud=instance and instance:FindFirstChild("VD_MobileHUD")
if vdMobilehud then
vdMobilehud:Destroy()
end
if originalCameraSettings and originalCameraSettings["CameraMode"]then
localPlayer["CameraMode"]=originalCameraSettings["CameraMode"]
end
local character=localPlayer["Character"]
local humanoid=character and character:FindFirstChildOfClass("Humanoid")
if humanoid then
humanoid["AutoRotate"]=true
end
end
)pcall(function()
local currentValue6=game:GetService("Lighting")
if defaultLightingSettings then
currentValue6["Brightness"]=defaultLightingSettings["Brightness"]currentValue6["ClockTime"]=defaultLightingSettings["ClockTime"]currentValue6["Ambient"]=defaultLightingSettings["Ambient"]currentValue6["OutdoorAmbient"]=defaultLightingSettings["OutdoorAmbient"]currentValue6["GlobalShadows"]=defaultLightingSettings["GlobalShadows"]currentValue6["FogStart"]=defaultLightingSettings["FogStart"]currentValue6["FogEnd"]=defaultLightingSettings["FogEnd"]
end
for key, item in pairs(cachedAtmospheres)do
if key and key["Parent"]then
pcall(function()key["Density"]=item["Density"]key["Haze"]=item["Haze"]
end
)
end
end
table["clear"](cachedAtmospheres)
for key, item in pairs(cachedDoFs)do
if key and key["Parent"]then
pcall(function()key["Enabled"]=item
end
)
end
end
table["clear"](cachedDoFs)
end
)pcall(function()
if mobileAimbotGui then
mobileAimbotGui:Destroy()mobileAimbotGui=nil
end
end
)pcall(function()
if aimAssistMobileButton then
aimAssistMobileButton:Destroy()aimAssistMobileButton=nil
end
end
)pcall(function()
if silentAimTarget then
silentAimTarget:Destroy()silentAimTarget=nil
end
end
)pcall(function()
if aimAssistFOVScreenGui then
aimAssistFOVScreenGui:Destroy()aimAssistFOVScreenGui=nil
end
end
)pcall(function()
if aimAssistDrawingCircle then
aimAssistDrawingCircle["Visible"]=false pcall(function()aimAssistDrawingCircle:Remove()
end
)aimAssistDrawingCircle=nil
end
end
)pcall(function()
if parryTarget then
parryTarget:Destroy()parryTarget=nil
end
end
)pcall(function()
local items11={guiParent;
billboardParent}
for index, instance in ipairs(items11)do
if instance then
local vdMobilehud=instance:FindFirstChild("VD_MobileHUD")
if vdMobilehud then
pcall(function()vdMobilehud:Destroy()
end
)
end
local vdMobileaimbotgui=instance:FindFirstChild("VD_MobileAimbotGui")
if vdMobileaimbotgui then
pcall(function()vdMobileaimbotgui:Destroy()
end
)
end
end
end
for key, item in pairs(mobileFloatingButtons)do
pcall(function()item:Destroy()
end
)
end
table["clear"](mobileFloatingButtons)
local instance=localPlayer:FindFirstChildOfClass("PlayerGui")
if instance then
local vdFlowstatefloatingui=instance:FindFirstChild("VD_FlowstateFloatingUI", true)
if vdFlowstatefloatingui then
pcall(function()vdFlowstatefloatingui:Destroy()
end
)
end
local instance2=nil
local instance3=instance:FindFirstChild("SurvivorPerks")
if instance3 then
instance2=instance3:FindFirstChild("Perks")
local flowstatecustomlabel=instance3:FindFirstChild("FlowstateCustomLabel")
if flowstatecustomlabel then
pcall(function()flowstatecustomlabel:Destroy()
end
)
end
end
if not instance2 then
local instance4=instance:FindFirstChild("Survivor")
if instance4 then
instance2=instance4:FindFirstChild("Perks")
end
end
if not instance2 then
local instance4=instance:FindFirstChild("Survivor-mob")
if instance4 then
instance2=instance4:FindFirstChild("Perks")or instance4:FindFirstChild("Controls")
end
end
if instance2 then
local flowstatecustomslot=instance2:FindFirstChild("FlowstateCustomSlot")
if flowstatecustomslot then
pcall(function()flowstatecustomslot:Destroy()
end
)
end
for index, instance4 in ipairs(instance2:GetChildren())do
if instance4:IsA("Frame")or instance4:IsA("GuiObject")then
local flowstatecooldownlabel=instance4:FindFirstChild("FlowstateCooldownLabel")
if flowstatecooldownlabel then
pcall(function()flowstatecooldownlabel:Destroy()
end
)
end
if instance4:GetAttribute("IsCustom")then
pcall(function()instance4:Destroy()
end
)
end
end
end
end
local instance4=instance:FindFirstChild("SlotScreen")
local instance5=instance4 and instance4:FindFirstChild("ItemFrame")
local parrycooldownlabel=instance5 and instance5:FindFirstChild("ParryCooldownLabel")
if parrycooldownlabel then
pcall(function()parrycooldownlabel:Destroy()
end
)
end
local instance6=instance:FindFirstChild("Survivor-mob")
local instance7=instance6 and instance6:FindFirstChild("Controls")
if instance7 then
local parrycooldownlabel2=instance7:FindFirstChild("ParryCooldownLabel")
if parrycooldownlabel2 then
pcall(function()parrycooldownlabel2:Destroy()
end
)
end
local instance8=instance7:FindFirstChild("action")
local parrycooldownlabel3=instance8 and instance8:FindFirstChild("ParryCooldownLabel")
if parrycooldownlabel3 then
pcall(function()parrycooldownlabel3:Destroy()
end
)
end
end
end
end
)pcall(function()(TweenService:Create(mainFrame, TweenInfo["new"](.2, Enum["EasingStyle"]["Quad"], Enum["EasingDirection"]["In"]), {["Size"]=UDim2["new"](0, 0, 0, 0);
["BackgroundTransparency"]=1})):Play()
end
)task["spawn"](function()task["wait"](.2)pcall(function()screenGui:Destroy()
end
)
end
)
end
_G["VD_Cleanup"]=doCleanup closeBtn["MouseButton1Click"]:Connect(function()doCleanup()
end
)
if isMobileDevice then
local button3=Instance["new"]("TextButton")button3["Name"]="MobileToggleButton"button3["Size"]=UDim2["new"](0, 40, 0, 40)button3["Position"]=UDim2["new"](0, 15, .45, 0)button3["BackgroundColor3"]=UI["Bg"]button3["BackgroundTransparency"]=.2 button3["Text"]="6"button3["TextColor3"]=UI["Accent"]button3["Font"]=Enum["Font"]["GothamBold"]button3["TextSize"]=15 button3["ZIndex"]=999 button3["Parent"]=screenGui;
(Instance["new"]("UICorner", button3))["CornerRadius"]=UDim["new"](.5, 0)
local stroke3=Instance["new"]("UIStroke", button3)stroke3["Color"]=UI["Stroke"]stroke3["Thickness"]=1.2
local startPosition4=nil
local startPosition5=nil
local conditionMet7=false
local connection6=nil button3["InputBegan"]:Connect(function(input)
if input["UserInputType"]==Enum["UserInputType"]["Touch"]or input["UserInputType"]==Enum["UserInputType"]["MouseButton1"]then
startPosition4=input["Position"]startPosition5=button3["Position"]conditionMet7=false
local connection7 connection7=input["Changed"]:Connect(function()
if input["UserInputState"]==Enum["UserInputState"]["End"]then
startPosition4=nil connection6=nil
if connection7 then
connection7:Disconnect()
end
if not conditionMet7 then
pcall(toggleUI)
end
end
end
)
end
end
)button3["InputChanged"]:Connect(function(input)
if input["UserInputType"]==Enum["UserInputType"]["Touch"]or input["UserInputType"]==Enum["UserInputType"]["MouseMovement"]then
connection6=input
end
end
)registerConnection(UserInputService["InputChanged"]:Connect(function(position)
if position==connection6 and startPosition4 then
local distance=position["Position"]-startPosition4
if distance["Magnitude"]>5 then
conditionMet7=true
end
button3["Position"]=UDim2["new"](startPosition5["X"]["Scale"], startPosition5["X"]["Offset"]+distance["X"], startPosition5["Y"]["Scale"], startPosition5["Y"]["Offset"]+distance["Y"])
end
end
))button3["MouseButton1Click"]:Connect(function()
if not conditionMet7 then
pcall(toggleUI)
end
end
)button3["TouchTap"]:Connect(function()
if not conditionMet7 then
pcall(toggleUI)
end
end
)button3["Activated"]:Connect(function()
if not conditionMet7 then
pcall(toggleUI)
end
end
)
end
function patchMobileControls()
if not isMobileDevice then
return
end
local instance=localPlayer:FindFirstChildOfClass("PlayerGui")
if not instance then
return
end
local cachedValue6=nil
for index, instance2 in ipairs(instance:GetDescendants())do
if instance2["Name"]=="Controls"and instance2:IsA("Frame")then
cachedValue6=instance2
break
end
end
if not cachedValue6 then
return
end
local currentValue6=cachedValue6:FindFirstAncestorOfClass("ScreenGui")
if currentValue6 then
pcall(function()currentValue6["DisplayOrder"]=20 currentValue6["ZIndexBehavior"]=Enum["ZIndexBehavior"]["Sibling"]
end
)cachedValue6["ZIndex"]=1000
for index, instance2 in ipairs(cachedValue6:GetDescendants())do
if instance2:IsA("GuiButton")then
instance2["Active"]=true instance2["Selectable"]=true instance2["ZIndex"]=1001
end
if instance2:IsA("Frame")and instance2["BackgroundTransparency"]==1 then
instance2["Active"]=false
end
end
end
if screenGui then
screenGui["DisplayOrder"]=99999
end
local vdMobileaimbotgui=instance:FindFirstChild("VD_MobileAimbotGui")
if vdMobileaimbotgui then
vdMobileaimbotgui["DisplayOrder"]=99998
end
local vdMobilehud=instance:FindFirstChild("VD_MobileHUD")
if vdMobilehud then
vdMobilehud["DisplayOrder"]=99997
end
end
task["spawn"](function()scanMapObjects()cachedValue3()
local name2=getMapName()
local name3, distance, player, currentValue6, currentValue7=0, 0, 0, 0, 0
local conditionMet7=false
while activeLoop do
pcall(function()
if isSpectating()then
if not conditionMet7 then
cleanupAll()conditionMet7=true
end
task["wait"](.5)
return
end
conditionMet7=false name3=name3+.1
if name3>=2 then
local name4=getMapName()
if name4~=name2 then
name2=name4 scanMapObjects()cachedValue3()
end
name3=0
end
currentValue6=currentValue6+.1
if currentValue6>=2 then
pcall(updateSCPCache)currentValue6=0
end
distance=distance+.1
if distance>=1 then
updateTPMenuDistances()distance=0
end
player=player+.1
if player>=.35 then
applyLocalPlayerModifiers()player=0
end
currentValue7=((currentValue7+1))%#espEntries
local success=espEntries[currentValue7+1]updateMapESP(success["typeKey"], success["cached"]())pcall(manageHighlights)
if settings["Minimap"]["Enabled"]then
pcall(function()minimapFrame["Visible"]=true
local camera=workspace["CurrentCamera"]
local transform=camera["CFrame"]
local character=cachedRootPart and cachedRootPart["Position"]or(localPlayer["Character"]and(localPlayer["Character"]:FindFirstChild("HumanoidRootPart")and localPlayer["Character"]["HumanoidRootPart"]["Position"]))
if not character then
return
end
local numericValue=130
local numericValue2=5
local numericValue3=130
local distance2=numericValue3/2
local vector2=(Vector3["new"](transform["LookVector"]["X"], 0, transform["LookVector"]["Z"]))["Unit"]
local vector3=(Vector3["new"](transform["RightVector"]["X"], 0, transform["RightVector"]["Z"]))["Unit"]
for index, container in ipairs(minimapFrame:GetChildren())do
if container["Name"]=="RadarDot"then
container["Visible"]=false
end
end
local function children()
for index, container in ipairs(minimapFrame:GetChildren())do
if container["Name"]=="RadarDot"and not container["Visible"]then
return container
end
end
local frame4=Instance["new"]("Frame")frame4["Name"]="RadarDot"frame4["Size"]=UDim2["new"](0, numericValue2, 0, numericValue2)frame4["AnchorPoint"]=Vector2["new"](.5, .5)frame4["BorderSizePixel"]=0 frame4["ZIndex"]=8 frame4["Parent"]=minimapFrame;
(Instance["new"]("UICorner", frame4))["CornerRadius"]=UDim["new"](1, 0)
return frame4
end
local function getDistance2(value, color2)
local currentValue8=value-character
local currentValue9=currentValue8:Dot(vector3)
local currentValue10=currentValue8:Dot(vector2)
local currentValue11=distance2/numericValue
local currentValue12=distance2+currentValue9*currentValue11
local currentValue13=distance2-currentValue10*currentValue11
local distance3=distance2-numericValue2
if((Vector2["new"](currentValue12, currentValue13)-Vector2["new"](distance2, distance2)))["Magnitude"]>distance3 then
return
end
local layoutPosition=children()layoutPosition["Position"]=UDim2["new"](0, currentValue12, 0, currentValue13)layoutPosition["BackgroundColor3"]=color2 layoutPosition["Visible"]=true
end
for index, player2 in ipairs(Players:GetPlayers())do
if player2==localPlayer then
continue
end
local instance=player2["Character"]
local rootPart=instance and instance:FindFirstChild("HumanoidRootPart")
if not rootPart then
continue
end
local name4=player2["Team"]
local isMatchingTeam=name4 and name4["Name"]=="Killer"
local teamName=isMatchingTeam and Color3["fromRGB"](255, 70, 70)or Color3["fromRGB"](80, 255, 130)getDistance2(rootPart["Position"], teamName)
end
for index, instance in ipairs(cachedGenerators)do
if not instance or not instance["Parent"]then
continue
end
if isGeneratorCompleted(instance)then
continue
end
local child=instance["PrimaryPart"]or instance:FindFirstChildWhichIsA("BasePart")
if child then
getDistance2(child["Position"], Color3["fromRGB"](0, 200, 255))
end
end
for index, instance in ipairs(cachedHooks)do
if not instance or not instance["Parent"]then
continue
end
local currentValue8=instance:IsA("BasePart")and instance["Position"]or nil
if currentValue8 then
getDistance2(currentValue8, Color3["fromRGB"](255, 150, 0))
end
end
for index, instance in ipairs(cachedPallets)do
if not instance or not instance["Parent"]then
continue
end
local child=instance["PrimaryPart"]or instance:FindFirstChildWhichIsA("BasePart")
if child then
getDistance2(child["Position"], Color3["fromRGB"](180, 130, 70))
end
end
end
)
else
if minimapFrame["Visible"]then
minimapFrame["Visible"]=false
end
end
end
)task["wait"](.1)
end
end
)
local items11={}
local character=false registerConnection(RunService["RenderStepped"]:Connect(function()
if not activeLoop then
return
end
local character2=localPlayer["Character"]cachedRootPart=character2 and character2:FindFirstChild("HumanoidRootPart")pcall(function()
if character2 then
local isKnocked=character2:GetAttribute("Knocked")==true or localPlayer:GetAttribute("Knocked")==true
if not isKnocked and getObjectValue then
isKnocked=getObjectValue(character2, "Knocked")==true
end
if isKnocked and not character then
if _G["VD_StopAllInteractions"]then
pcall(_G["VD_StopAllInteractions"])
end
end
character=isKnocked
end
end
)pcall(updatePlayersESP)
end
))cachedValue2=function(value)
local character2=value or localPlayer["Character"]
if character2 then
local rainbowhighlight=character2:FindFirstChild("RainbowHighlight")
if rainbowhighlight then
pcall(function()rainbowhighlight:Destroy()
end
)
end
end
for key, item in pairs(espEntries3)do
pcall(function()
if key and key["Parent"]then
key["Color"]=item["Color"]key["Material"]=item["Material"]key["Transparency"]=item["Transparency"]
end
end
)
end
espEntries3={}table["clear"](items9)connection=nil
end
registerConnection(localPlayer["CharacterAdded"]:Connect(function(value)pcall(scanMapObjects)espEntries3={}table["clear"](items9)connection=nil
end
))
local numericValue=0
local conditionMet7=false
local numericValue2=0
local numericValue3=1
local success=0 registerConnection(RunService["RenderStepped"]:Connect(function(value)
if not activeLoop then
return
end
pcall(function()
local camera=workspace["CurrentCamera"]
if camera and(settings["FOV"]and type(settings["FOV"])=="number")then
if camera["FieldOfView"]~=settings["FOV"]then
camera["FieldOfView"]=settings["FOV"]
end
end
end
)debug["profilebegin"]("Helper_RenderStepped_Main")
if settings["RainbowCharacter"]then
pcall(function()
local character2=localPlayer["Character"]
if character2 then
local timestamp=((tick()%4))/4
local character3=Color3["fromHSV"](timestamp, 1, 1)
if settings["RainbowCharacterMode"]=="Highlight"then
if next(espEntries3)then
for key, item in pairs(espEntries3)do
pcall(function()
if key and key["Parent"]then
key["Color"]=item["Color"]key["Material"]=item["Material"]key["Transparency"]=item["Transparency"]
end
end
)
end
espEntries3={}
end
local highlight=character2:FindFirstChild("RainbowHighlight")
if not highlight then
highlight=Instance["new"]("Highlight")highlight["Name"]="RainbowHighlight"highlight["FillTransparency"]=.4 highlight["OutlineTransparency"]=0 highlight["Parent"]=character2
end
highlight["FillColor"]=character3 highlight["OutlineColor"]=character3 highlight["Enabled"]=true
else
local rainbowhighlight=character2:FindFirstChild("RainbowHighlight")
if rainbowhighlight then
pcall(function()rainbowhighlight:Destroy()
end
)
end
if connection~=character2 then
connection=character2 table["clear"](items9)
for index, instance in ipairs(character2:GetChildren())do
if instance:IsA("BasePart")and instance["Name"]~="HumanoidRootPart"then
table["insert"](items9, instance)
end
end
end
for index, instance in ipairs(items9)do
if instance and instance["Parent"]then
if not espEntries3[instance]then
espEntries3[instance]={["Color"]=instance["Color"], ["Material"]=instance["Material"], ["Transparency"]=instance["Transparency"]}
end
instance["Color"]=character3
if settings["RainbowCharacterMode"]=="ForceField"then
instance["Material"]=Enum["Material"]["ForceField"]
else
instance["Material"]=espEntries3[instance]["Material"]
end
end
end
end
end
end
)
end
if settings["NoclipVaultsPallets"]and(isFeatureAvailable()and(featureAvailability and featureAvailability["NoclipVaultsPallets"]))then
pcall(function()
for index, instance in ipairs(cachedVaults)do
if instance and(instance["Parent"]and not playerStateCache[instance])then
playerStateCache[instance]={}
for index2, instance2 in ipairs(instance:GetDescendants())do
if instance2:IsA("BasePart")then
local name2=instance2["Name"]:lower()
if name2=="inviswall"or name2=="bottom"or name2:find("vault")or name2=="glass"or name2=="pane"then
if items11[instance2]==nil then
items11[instance2]=instance2["CanCollide"]
end
instance2["CanCollide"]=false table["insert"](playerStateCache[instance], instance2)
end
end
end
end
end
for index, instance in ipairs(cachedPallets)do
if instance and(instance["Parent"]and not playerStateCache[instance])then
playerStateCache[instance]={}
for index2, instance2 in ipairs(instance:GetDescendants())do
if instance2:IsA("BasePart")then
if items11[instance2]==nil then
items11[instance2]=instance2["CanCollide"]
end
instance2["CanCollide"]=false table["insert"](playerStateCache[instance], instance2)
end
end
end
end
end
)
else
if next(items11)~=nil then
pcall(function()
for key, item in pairs(items11)do
if key and key["Parent"]then
key["CanCollide"]=item
end
end
end
)items11={}playerStateCache={}
end
end
if settings["AutoMoonwalk"]then
pcall(function()debug["profilebegin"]("Helper_AutoMoonwalk")
local character2=localPlayer["Character"]
local rootPart=character2 and character2:FindFirstChild("HumanoidRootPart")
local humanoid=character2 and character2:FindFirstChildOfClass("Humanoid")
if rootPart and(humanoid and currentCamera)then
local currentValue6=conditionMet7
local timestamp=tick()
if timestamp-numericValue>=.1 then
numericValue=timestamp currentValue6=false
if settings["MoonwalkDisableOnVault"]then
if cachedVaults then
for index, instance in ipairs(cachedVaults)do
if instance and instance["Parent"]then
local currentValue7=characterStateCache[instance]
if currentValue7==nil then
currentValue7=instance:IsA("BasePart")and instance or(instance["PrimaryPart"]or instance:FindFirstChildWhichIsA("BasePart")or false)characterStateCache[instance]=currentValue7
end
if currentValue7 then
local distance=((currentValue7["Position"]-rootPart["Position"]))["Magnitude"]
if distance<=20 then
currentValue6=true
break
end
end
end
end
end
if not currentValue6 and cachedPallets then
for index, instance in ipairs(cachedPallets)do
if instance and instance["Parent"]then
local currentValue7=characterStateCache[instance]
if currentValue7==nil then
local rootPart2=instance:FindFirstChild("HumanoidRootPart")
if rootPart2 and((rootPart2:FindFirstChild("inviswall")or rootPart2:FindFirstChild("inviswall1")))then
currentValue7=instance["PrimaryPart"]or rootPart2 or instance:FindFirstChildWhichIsA("BasePart")or false
else
currentValue7=false
end
characterStateCache[instance]=currentValue7
end
if currentValue7 then
local distance=((currentValue7["Position"]-rootPart["Position"]))["Magnitude"]
if distance<=18 then
currentValue6=true
break
end
end
end
end
end
end
conditionMet7=currentValue6
end
if not currentValue6 then
humanoid["AutoRotate"]=false
local frame4
if settings["MoonwalkMovementBased"]and(isFeatureAvailable()and(featureAvailability and(featureAvailability["MovementMoonwalk"]and humanoid["MoveDirection"]["Magnitude"]>.01)))then
local transform=humanoid["MoveDirection"]:Dot(currentCamera["CFrame"]["LookVector"])
local transform2=humanoid["MoveDirection"]:Dot(currentCamera["CFrame"]["RightVector"])
if math["abs"](transform)>math["abs"](transform2)then
frame4=math["atan2"](humanoid["MoveDirection"]["X"], humanoid["MoveDirection"]["Z"])
else
local transform3=currentCamera["CFrame"]["LookVector"]frame4=math["atan2"](transform3["X"], transform3["Z"])
end
else
local transform=currentCamera["CFrame"]["LookVector"]frame4=math["atan2"](transform["X"], transform["Z"])
end
local numericValue4=0
if humanoid["MoveDirection"]["Magnitude"]>.01 then
local moonwalkswayspeed=settings["MoonwalkSwaySpeed"]or 14
local moonwalkswayamplitude=settings["MoonwalkSwayAmplitude"]or.28
local moonwalkshaking=settings["MoonwalkShaking"]or.05
local timestamp2=math["sin"](tick()*moonwalkswayspeed)*moonwalkswayamplitude
local currentValue7=((math["random"]()-.5))*moonwalkshaking numericValue4=timestamp2+currentValue7
end
local transform, transform2, transform3=rootPart["CFrame"]:ToOrientation()
local currentValue7=frame4
if settings["ReverseMoonwalk"]then
currentValue7=currentValue7+math["pi"]
end
local currentValue8=(((currentValue7-transform2)+math["pi"]))%((2*math["pi"]))-math["pi"]
local currentValue9=value or.0166
local clampedValue=math["clamp"](currentValue9*5.5, 0, 1)
local frame5=transform2+currentValue8*clampedValue
local numericValue5=0
if humanoid["MoveDirection"]["Magnitude"]>.01 then
local moonwalkswayspeed=settings["MoonwalkSwaySpeed"]or 14
local speed=1.2/moonwalkswayspeed
local timestamp2=tick()
if timestamp2-numericValue2>=speed then
numericValue2=timestamp2 numericValue3=-numericValue3
end
local moonwalkswayamplitude=numericValue3*((settings["MoonwalkSwayAmplitude"]or.65))success=success+((moonwalkswayamplitude-success))*math["clamp"](currentValue9*18, 0, 1)
local moonwalkshaking=settings["MoonwalkShaking"]or.05
local currentValue10=((math["random"]()-.5))*moonwalkshaking numericValue5=success+currentValue10
else
success=0
end
local difference=math["abs"](currentValue8)
local clampedValue2=math["clamp"](1-(difference/((math["pi"]/2))), 0, 1)numericValue5=numericValue5*clampedValue2
local transform4=frame5+numericValue5 rootPart["CFrame"]=CFrame["new"](rootPart["Position"])*CFrame["Angles"](0, transform4, 0)
else
humanoid["AutoRotate"]=true
end
end
debug["profileend"]()
end
)
end
debug["profileend"]()
end
))
local timeValue2=0
local timeValue3=0
local function readStateValue()
local name2=localPlayer["Team"]
if name2 and name2["Name"]=="Killer"then
return false
end
if settings["FlowstatePerk"]then
return true
end
local character2=localPlayer["Character"]
if character2 then
if character2:GetAttribute("Flowstate")==true or character2:FindFirstChild("Flowstate")~=nil then
return true
end
end
local instance=localPlayer:FindFirstChildOfClass("PlayerGui")
if instance then
local instance2=instance:FindFirstChild("SurvivorPerks")
local perks=instance2 and instance2:FindFirstChild("Perks")
if perks then
for index, instance3 in ipairs(perks:GetChildren())do
if instance3:IsA("Frame")or instance3:IsA("GuiObject")then
local instance4=instance3:FindFirstChild("Icon", true)or instance3:FindFirstChildOfClass("ImageLabel")
if instance4 and instance4:IsA("ImageLabel")then
if(tostring(instance4["Image"])):find("108420950668748")then
return true
end
end
end
end
end
end
return false
end
function triggerFastVaultCooldown()
if not readStateValue()then
return
end
if tick()<timeValue2 then
return
end
timeValue3=tick()+.5 timeValue2=tick()+((settings["FlowstateCooldown"]or 15))
end
function watchLocalPlayerCharacter(character2)
if not character2 then
return
end
if currentFarmTarget then
pcall(function()currentFarmTarget:Disconnect()
end
)currentFarmTarget=nil
end
if currentFarmPath then
pcall(function()currentFarmPath:Disconnect()
end
)currentFarmPath=nil
end
if farmHeartbeatConnection then
pcall(function()farmHeartbeatConnection:Disconnect()
end
)farmHeartbeatConnection=nil
end
if currentFarmState then
pcall(function()currentFarmState:Disconnect()
end
)currentFarmState=nil
end
local function cleanupResources2(name2)
if settings["NoSkillChecks"]then
local name3=name2["Name"]:lower()
if name3:find("skillcheck")then
pcall(function()name2:Destroy()
end
)
end
end
end
pcall(function()
for index, item in ipairs(character2:GetChildren())do
cleanupResources2(item)
end
end
)currentFarmState=character2["ChildAdded"]:Connect(cleanupResources2)task["spawn"](function()
local humanoid=character2:WaitForChild("Humanoid", 10)
local animator=humanoid and humanoid:WaitForChild("Animator", 10)
if animator then
currentFarmPath=animator["AnimationPlayed"]:Connect(function(name2)
local name3=((name2["Name"]or"")):lower()
local animation=name2["Animation"]
local animation2=animation and animation["AnimationId"]or""animation2=typeof(animation2)=="string"and animation2:lower()or""
if tick()-timeValue<1 then
local currentValue6=name3:find("pallet")or name3:find("pull")or name3:find("drop")or name3:find("interact")or name3:find("grab")or animation2:find("pallet")or animation2:find("pull")or animation2:find("drop")or animation2:find("interact")or animation2:find("grab")
if currentValue6 then
pcall(function()name2:Stop(0)
end
)
end
end
local currentValue6=name3:find("walking")or animation2:find("126081405469607")
if currentValue6 then
return
end
local currentValue7=name3:find("running")or name3:find("finesse")or animation2:find("83873880822918")or animation2:find("136962284480779")or name3:find("fast")
if currentValue7 then
triggerFastVaultCooldown()
end
end
)
end
end
)
end
pcall(function()watchLocalPlayerCharacter(localPlayer["Character"])
end
)registerConnection(localPlayer["CharacterAdded"]:Connect(watchLocalPlayerCharacter))pcall(function()
local cachedValue6=nil
local cachedValue7=nil
local function processValue5()
local remotes=ReplicatedStorage:FindFirstChild("Remotes", true)or ReplicatedStorage
for index, instance in ipairs(remotes:GetDescendants())do
if instance:IsA("RemoteEvent")then
local name2=instance["Name"]:lower()
if name2=="fastvault"then
cachedValue6=instance
elseif name2=="vaultcompleteeventpart1"then
cachedValue7=instance
end
end
end
end
pcall(processValue5)
local items12={}
local function processValue6()table["clear"](items12)
local map=workspace:FindFirstChild("Map")or workspace
for index, instance in ipairs(map:GetDescendants())do
if((instance["Name"]=="VaultTrigger"or instance["Name"]=="VaultPoint"))and instance:IsA("BasePart")then
table["insert"](items12, instance)
end
end
end
pcall(processValue6)
local map=workspace:FindFirstChild("Map")
if map then
registerConnection(map["DescendantAdded"]:Connect(function(instance)
if((instance["Name"]=="VaultTrigger"or instance["Name"]=="VaultPoint"))and instance:IsA("BasePart")then
table["insert"](items12, instance)
end
end
))
end
local function getDistance2(position)
local numericValue4=9
local cachedValue8=nil
for key=1, #items12, 1 do
local distance=items12[key]
if distance and distance["Parent"]then
local distance2=((position-distance["Position"]))["Magnitude"]
if distance2<numericValue4 then
numericValue4=distance2 cachedValue8=distance
end
end
end
return cachedValue8
end
local cachedValue8=nil
local function getFeatureState3(value)
if not value then
return
end
local humanoid=value:WaitForChild("Humanoid", 5)
local animator=humanoid and humanoid:WaitForChild("Animator", 5)
if animator then
local animation=Instance["new"]("Animation")animation["AnimationId"]="rbxassetid://83873880822918"pcall(function()cachedValue8=animator:LoadAnimation(animation)cachedValue8["Priority"]=Enum["AnimationPriority"]["Action"]
end
)registerConnection(animator["AnimationPlayed"]:Connect(function(name2)
if not((settings["AlwaysFastVault"]and(isFeatureAvailable()and(featureAvailability and featureAvailability["AlwaysFastVault"]))))then
return
end
local animation2=(tostring(name2["Animation"]and name2["Animation"]["AnimationId"]or"")):lower()
local name3=((name2["Name"]or"")):lower()
if animation2:find("126081405469607")or name3:find("walkingvault")then
pcall(function()name2:Stop(0)
end
)
if cachedValue8 then
pcall(function()cachedValue8:Play(.02)
end
)
end
end
end
))
end
end
if localPlayer["Character"]then
pcall(function()getFeatureState3(localPlayer["Character"])
end
)
end
registerConnection(localPlayer["CharacterAdded"]:Connect(getFeatureState3))registerConnection(UserInputService["InputBegan"]:Connect(function(input, contextValue)
if contextValue then
return
end
if not((settings["AlwaysFastVault"]and(isFeatureAvailable()and(featureAvailability and featureAvailability["AlwaysFastVault"]))))then
return
end
if input["KeyCode"]==Enum["KeyCode"]["E"]or input["KeyCode"]==Enum["KeyCode"]["Space"]then
local character2=localPlayer["Character"]
local rootPart=character2 and character2:FindFirstChild("HumanoidRootPart")
if rootPart then
local currentValue6=getDistance2(rootPart["Position"])
if currentValue6 then
local currentValue7=(currentValue6["Position"]-rootPart["Position"])
local vector2=Vector3["new"](currentValue7["X"], 0, currentValue7["Z"])
if vector2["Magnitude"]>.05 then
vector2=vector2["Unit"]
else
local vector3=rootPart["CFrame"]["LookVector"]vector2=(Vector3["new"](vector3["X"], 0, vector3["Z"]))["Unit"]
end
local distance=rootPart["AssemblyLinearVelocity"]["Magnitude"]
local transform=rootPart["CFrame"]["LookVector"]:Dot(vector2)
local conditionMet8=(distance>=13 and transform>=.7)
if not conditionMet8 then
pcall(function()character2:SetAttribute("Sprinting", true)character2:SetAttribute("IsRunning", true)
end
)rootPart["CFrame"]=CFrame["new"](rootPart["Position"], rootPart["Position"]+vector2)rootPart["AssemblyLinearVelocity"]=vector2*22
end
end
end
end
end
))
if typeof(hookmetamethod)=="function"then
local currentValue6 currentValue6=hookmetamethod(game, "__namecall", function(name2, ...)
local currentValue7=getnamecallmethod()
local items13={...}
if settings["AlwaysFastVault"]and(isFeatureAvailable()and(featureAvailability and(featureAvailability["AlwaysFastVault"]and(((currentValue7=="FireServer"or currentValue7=="InvokeServer"))and typeof(name2)=="Instance"))))then
if name2["Name"]=="VaultEvent"then
if items13[2]==false then
items13[2]=true
local character2=localPlayer["Character"]
if character2 then
pcall(function()character2:SetAttribute("Sprinting", true)character2:SetAttribute("IsRunning", true)
end
)
end
if cachedValue6 and character2 then
pcall(function()cachedValue6:FireServer(character2)
end
)
end
if cachedValue7 then
pcall(function()cachedValue7:FireServer()
end
)
end
end
return currentValue6(name2, unpack(items13))
end
end
return currentValue6(name2, ...)
end
)
end
end
)task["spawn"](function()
local cachedValue6=nil
local items12={}
while activeLoop do
pcall(function()
local name2=localPlayer["Name"]
local items13={}
if localPlayer["Character"]then
table["insert"](items13, localPlayer["Character"])
end
local instance=workspace:FindFirstChild(name2)
if instance and(instance:IsA("Model")and not table["find"](items13, instance))then
table["insert"](items13, instance)
end
local conditionMet8=false
local items14={"climb_obsessing", "climb_collisoning";
"climb_collisioning";
"climb_colliding"}
for index, item in ipairs(items14)do
local instance2=workspace:FindFirstChild(item)
if instance2 then
local instance3=instance2:FindFirstChild(name2)
if instance3 and instance3:IsA("Model")then
conditionMet8=true
if not table["find"](items13, instance3)then
table["insert"](items13, instance3)
end
end
end
end
if conditionMet8 then
triggerFastVaultCooldown()
end
local conditionMet9=tick()<timeValue2
local conditionMet10=tick()<timeValue3
local flowstateperk=settings["FlowstatePerk"]and((conditionMet10 or not conditionMet9))
if localPlayer:GetAttribute("Flowstate")~=flowstateperk then
localPlayer:SetAttribute("Flowstate", flowstateperk)
end
for index, instance2 in ipairs(items13)do
if instance2:GetAttribute("Flowstate")~=flowstateperk then
instance2:SetAttribute("Flowstate", flowstateperk)
end
end
end
)task["wait"](.1)
end
end
)task["spawn"](function()
while activeLoop do
pcall(function()
local character2=localPlayer["Character"]
if character2 and getObjectValue(character2, "IsStunned")==true then
setObjectValue(character2, "IsStunned", false)
end
end
)task["wait"](.1)
end
end
)task["spawn"](function()
local function conditionMet8(instance)
if instance["Name"]=="Blind"and instance:IsA("GuiObject")then
if settings["NoFlashlightBlind"]then
pcall(function()instance["Visible"]=false
if instance:IsA("Frame")or instance:IsA("ImageLabel")then
instance["BackgroundTransparency"]=1
end
end
)
end
registerConnection((instance:GetPropertyChangedSignal("Visible")):Connect(function()
if settings["NoFlashlightBlind"]then
pcall(function()instance["Visible"]=false
end
)
end
end
))registerConnection((instance:GetPropertyChangedSignal("BackgroundTransparency")):Connect(function()
if settings["NoFlashlightBlind"]then
pcall(function()
if instance:IsA("Frame")or instance:IsA("ImageLabel")then
instance["BackgroundTransparency"]=1
end
end
)
end
end
))
end
end
local playergui=localPlayer:WaitForChild("PlayerGui", 5)
if playergui then
for index, item in ipairs(playergui:GetDescendants())do
conditionMet8(item)
end
registerConnection(playergui["DescendantAdded"]:Connect(function(value)conditionMet8(value)
end
))
end
while activeLoop do
if settings["NoFlashlightBlind"]and playergui then
pcall(function()
for index, container in ipairs(playergui:GetDescendants())do
if container["Name"]=="Blind"and container:IsA("GuiObject")then
if container["Visible"]then
container["Visible"]=false
end
if((container:IsA("Frame")or container:IsA("ImageLabel")))and container["BackgroundTransparency"]~=1 then
container["BackgroundTransparency"]=1
end
end
end
end
)
end
task["wait"](.2)
end
end
)task["spawn"](function()
while activeLoop do
if settings["InstantHeal"]then
pcall(function()
local character2=localPlayer["Character"]
local humanoid=character2 and character2:FindFirstChildOfClass("Humanoid")
local isKnocked=false
if character2 and character2:GetAttribute("Knocked")==true then
isKnocked=true
elseif localPlayer:GetAttribute("Knocked")==true then
isKnocked=true
end
if isKnocked and humanoid then
humanoid["Health"]=humanoid["MaxHealth"]
if not settings["AutoFarmSurvivor"]and not settings["AutoFarmAFKTotal"]then
pcall(function()character2:SetAttribute("Knocked", false)
end
)pcall(function()localPlayer:SetAttribute("Knocked", false)
end
)
end
pcall(function()
for index, instance in ipairs(character2:GetDescendants())do
if instance:IsA("BasePart")and not instance["CanCollide"]then
instance["CanCollide"]=true
end
end
end
)
end
end
)
end
task["wait"](.05)
end
end
)do
local numericValue4=104
local numericValue5=114
local function calculateValue()
local skillcheckmode=settings["SkillCheckMode"]or"Perfect"
if skillcheckmode=="Normal"then
local currentValue6=math["random"](125, 155)numericValue4=currentValue6 numericValue5=currentValue6+10
elseif skillcheckmode=="Perfect"then
numericValue4=104 numericValue5=114
else
local perfecthitrate=isFeatureAvailable()and math["clamp"](settings["PerfectHitRate"]or 100, 0, 100)or 50
if math["random"](1, 100)<=perfecthitrate then
numericValue4=104 numericValue5=114
else
local currentValue6=math["random"](125, 155)numericValue4=currentValue6 numericValue5=currentValue6+10
end
end
end
local items12={}
local cachedValue6=nil
local function players()
for index, player in ipairs(Players:GetPlayers())do
local name2=player["Team"]
local teamName=false
if name2 and name2["Name"]=="Killer"then
teamName=true
elseif player:GetAttribute("Role")=="Killer"or player:GetAttribute("IsKiller")==true then
teamName=true
elseif(player["Name"]:lower()):find("killer")then
teamName=true
end
if teamName and player["Character"]then
for index2, instance in ipairs(player["Character"]:GetChildren())do
if string["find"](instance["Name"], "King's Scourge")then
return true
end
end
end
end
return false
end
local function character2()
local character3=localPlayer["Character"]
local rootPart=character3 and character3:FindFirstChild("HumanoidRootPart")
if not rootPart then
return nil
end
local cachedValue7=nil
local distance=math["huge"]
for index, instance in ipairs(cachedGenerators)do
if instance and(instance["Parent"]and not isGeneratorCompleted(instance))then
local rootPart2=instance:FindFirstChild("HumanoidRootPart")or instance:FindFirstChild("Engine")or instance:FindFirstChildOfClass("Part")
if rootPart2 then
local distance2=((rootPart["Position"]-rootPart2["Position"]))["Magnitude"]
if distance2<distance then
distance=distance2 cachedValue7=instance
end
end
end
end
for key, item in pairs(ActiveESP["Generators"])do
if key and(key["Parent"]and not isGeneratorCompleted(key))then
local rootPart2=key:FindFirstChild("HumanoidRootPart")or key:FindFirstChild("Engine")or key:FindFirstChildOfClass("Part")
if rootPart2 then
local distance2=((rootPart["Position"]-rootPart2["Position"]))["Magnitude"]
if distance2<distance then
distance=distance2 cachedValue7=key
end
end
end
end
if distance<10 then
return cachedValue7
end
return nil
end
local instance, currentValue6, currentValue7=nil, nil, nil
local cachedValue7=nil
local cachedValue8=nil
local cachedValue9=nil
local cachedValue10=nil
local conditionMet8=false
local numericValue6=0
local conditionMet9=false
local cachedValue11=nil
local cachedValue12=nil
local numericValue7=0
local conditionMet10=false
local function processValue5()
local child=localPlayer:FindFirstChildOfClass("PlayerGui")
if not child then
return nil
end
for index, instance2 in ipairs(child:GetChildren())do
if instance2:IsA("ScreenGui")then
local controls=instance2:FindFirstChild("Controls")
if controls then
for index2, instance3 in ipairs(controls:GetChildren())do
local name2=instance3["Name"]:lower()
if name2=="action"or name2=="interact"or name2=="space"or name2=="use"then
return instance3
end
end
end
end
end
return nil
end
local function processValue6()task["spawn"](function()pcall(function()VirtualInputManager:SendKeyEvent(true, Enum["KeyCode"]["Space"], false, game)task["wait"](.02)VirtualInputManager:SendKeyEvent(false, Enum["KeyCode"]["Space"], false, game)
end
)pcall(function()
local instance2=cachedValue7 or localPlayer:FindFirstChildOfClass("PlayerGui")
local skillcheckpromptgui=cachedValue8 or(instance2 and instance2:FindFirstChild("SkillCheckPromptGui"))
if skillcheckpromptgui then
local function children(value)
for index, container in ipairs(value:GetChildren())do
if container:IsA("GuiButton")then
if typeof(firesignal)=="function"then
pcall(function()firesignal(container["MouseButton1Click"])
end
)pcall(function()firesignal(container["Activated"])
end
)pcall(function()firesignal(container["MouseButton1Down"])
end
)
end
pcall(function()
local button3=container["AbsolutePosition"]["X"]+(container["AbsoluteSize"]["X"]/2)
local button4=container["AbsolutePosition"]["Y"]+(container["AbsoluteSize"]["Y"]/2)VirtualInputManager:SendMouseButtonEvent(button3, button4, 0, true, game, 1)task["wait"](.01)VirtualInputManager:SendMouseButtonEvent(button3, button4, 0, false, game, 1)
end
)
end
children(container)
end
end
children(skillcheckpromptgui)
end
local button3=processValue5()
if button3 and button3:IsA("GuiButton")then
if typeof(firesignal)=="function"then
pcall(function()firesignal(button3["MouseButton1Click"])
end
)pcall(function()firesignal(button3["Activated"])
end
)pcall(function()firesignal(button3["MouseButton1Down"])
end
)
end
pcall(function()
local button4=button3["AbsolutePosition"]["X"]+(button3["AbsoluteSize"]["X"]/2)
local button5=button3["AbsolutePosition"]["Y"]+(button3["AbsoluteSize"]["Y"]/2)VirtualInputManager:SendMouseButtonEvent(button4, button5, 0, true, game, 1)task["wait"](.01)VirtualInputManager:SendMouseButtonEvent(button4, button5, 0, false, game, 1)
end
)
end
end
)
end
)
end
local function processValue7()
if instance and(instance["Parent"]and(currentValue6 and(currentValue6["Parent"]and(currentValue7 and currentValue7["Parent"]))))then
return true
end
instance, currentValue6, currentValue7=nil, nil, nil
if not cachedValue7 or not cachedValue7["Parent"]then
cachedValue7=localPlayer:FindFirstChildOfClass("PlayerGui")
end
local instance2=cachedValue7
if not instance2 then
return false
end
if not cachedValue8 or not cachedValue8["Parent"]or cachedValue8["Parent"]~=instance2 then
cachedValue8=instance2:FindFirstChild("SkillCheckPromptGui")
end
local instance3=cachedValue8
if not instance3 then
return false
end
instance=instance3:FindFirstChild("Check")
if not instance then
return false
end
currentValue6=instance:FindFirstChild("Line")currentValue7=instance:FindFirstChild("Goal")
if currentValue6 and currentValue7 then
numericValue6=0
return true
end
return false
end
local function updateVisibility()
if not cachedValue7 or not cachedValue7["Parent"]then
cachedValue7=localPlayer:FindFirstChildOfClass("PlayerGui")
end
local instance2=cachedValue7
if not instance2 then
return false
end
if not cachedValue8 or not cachedValue8["Parent"]or cachedValue8["Parent"]~=instance2 then
cachedValue8=instance2:FindFirstChild("SkillCheckPromptGui")
end
local instance3=cachedValue8
if not instance3 or not instance3:IsA("ScreenGui")or not instance3["Enabled"]then
return false
end
local check=instance3:FindFirstChild("Check")
if not check or not check["Visible"]then
return false
end
return true
end
local child=localPlayer:FindFirstChildOfClass("PlayerGui")
if child then
registerConnection(child["ChildAdded"]:Connect(function(name2)
if name2["Name"]=="SkillCheckPromptGui"then
task["wait"](.1)processValue7()
end
end
))registerConnection(child["ChildRemoved"]:Connect(function(name2)
if name2["Name"]=="SkillCheckPromptGui"then
instance, currentValue6, currentValue7=nil, nil, nil
end
end
))
end
processValue7()task["spawn"](function()
while activeLoop do
if cachedValue6 and not settings["InstantSkillCheck"]then
local instance2=cachedValue6
if not instance2 or not instance2["Parent"]then
items12[instance2]=true cachedValue6=nil settings["InstantSkillCheck"]=true
if controlRegistry["InstantSkillCheck"]and controlRegistry["InstantSkillCheck"]["setValue"]then
pcall(function()controlRegistry["InstantSkillCheck"]["setValue"](true)
end
)
end
pcall(saveSettings)showNotification("Skill Check", "Generator completed! Instant Skill Check re-enabled.", "success")
else
local progress2=getGeneratorProgress(instance2)
local conditionMet11=progress2>=100 or isGeneratorCompleted(instance2)
local character3=localPlayer["Character"]
local rootPart=character3 and character3:FindFirstChild("HumanoidRootPart")
local rootPart2=false
if rootPart then
local success2, result=pcall(function()
return(instance2:GetPivot())["Position"]
end
)
if success2 then
rootPart2=((result-rootPart["Position"]))["Magnitude"]<=15
else
local child2=instance2:FindFirstChildOfClass("BasePart")
if child2 then
rootPart2=((child2["Position"]-rootPart["Position"]))["Magnitude"]<=15
end
end
end
local conditionMet12=not rootPart2
if conditionMet12 then
items12[instance2]=true cachedValue6=nil settings["InstantSkillCheck"]=true
if controlRegistry["InstantSkillCheck"]and controlRegistry["InstantSkillCheck"]["setValue"]then
pcall(function()controlRegistry["InstantSkillCheck"]["setValue"](true)
end
)
end
pcall(saveSettings)showNotification("Skill Check", "Walked away from generator! Instant Skill Check re-enabled.", "success")
elseif conditionMet11 then
local currentValue8=instance2 items12[currentValue8]=true cachedValue6=nil task["spawn"](function()task["wait"](1)settings["InstantSkillCheck"]=true
if controlRegistry["InstantSkillCheck"]and controlRegistry["InstantSkillCheck"]["setValue"]then
pcall(function()controlRegistry["InstantSkillCheck"]["setValue"](true)
end
)
end
pcall(saveSettings)showNotification("Skill Check", "Generator completed! Instant Skill Check re-enabled.", "success")
end
)
end
end
end
task["wait"](.4)
end
end
)registerConnection(RunService["RenderStepped"]:Connect(function()
if not settings["AutoSkillCheck"]then
cachedValue9=nil cachedValue10=nil conditionMet8=false conditionMet9=false cachedValue11=nil cachedValue12=nil numericValue7=0 conditionMet10=false
return
end
if not updateVisibility()then
instance, currentValue6, currentValue7=nil, nil, nil cachedValue9=nil cachedValue10=nil conditionMet8=false conditionMet9=false cachedValue11=nil cachedValue12=nil numericValue7=0 conditionMet10=false
return
end
if not instance or not currentValue6 or not currentValue7 then
processValue7()
return
end
local currentValue8=currentValue7["Rotation"]
if cachedValue11~=currentValue8 then
cachedValue11=currentValue8 conditionMet9=false conditionMet10=false calculateValue()
end
if settings["InstantSkillCheck"]then
if players()then
local progress2=character2()
if progress2 then
local progress3=getGeneratorProgress(progress2)
if items12[progress2]~=true then
local currentValue9=items12[progress2]or 0
if progress3>currentValue9 then
items12[progress2]=progress3
end
end
if progress3>=85 and items12[progress2]~=true then
settings["InstantSkillCheck"]=false
if controlRegistry["InstantSkillCheck"]and controlRegistry["InstantSkillCheck"]["setValue"]then
pcall(function()controlRegistry["InstantSkillCheck"]["setValue"](false)
end
)
end
pcall(saveSettings)cachedValue6=progress2 showNotification("Skill Check", "King's Scourge & Progress >= 85%! Disabled Instant Skill Check.", "warning")
return
end
end
end
if not conditionMet9 and not conditionMet10 then
conditionMet9=true conditionMet10=true task["spawn"](function()task["wait"](.1)
if updateVisibility()and(instance and(currentValue6 and currentValue7))then
local currentValue9=currentValue7["Rotation"]%360
if currentValue9<0 then
currentValue9=currentValue9+360
end
local currentValue10=((currentValue9+((numericValue4+numericValue5))/2))%360
local timestamp=tick()+.25 task["spawn"](function()
while tick()<timestamp and(updateVisibility()and currentValue6)do
currentValue6["Rotation"]=currentValue10 RunService["RenderStepped"]:Wait()
end
end
)processValue6()
end
end
)
end
return
end
if not cachedValue9 then
cachedValue9=tick()conditionMet10=false calculateValue()
end
if tick()-cachedValue9<.1 then
return
end
local currentValue9=currentValue6["Rotation"]
local currentValue10=currentValue9%360
local currentValue11=currentValue7["Rotation"]%360
if currentValue10<0 then
currentValue10=currentValue10+360
end
if currentValue11<0 then
currentValue11=currentValue11+360
end
local currentValue12=((currentValue11+numericValue4))%360
local currentValue13=((currentValue11+numericValue5))%360
local conditionMet11
if currentValue12>currentValue13 then
conditionMet11=(currentValue10>=currentValue12 or currentValue10<=currentValue13)
else
conditionMet11=(currentValue10>=currentValue12 and currentValue10<=currentValue13)
end
local currentValue14=conditionMet11
if cachedValue10 then
local currentValue15=cachedValue10%360
if currentValue15<0 then
currentValue15=currentValue15+360
end
local currentValue16=currentValue9-cachedValue10
if currentValue16<-180 then
currentValue16=currentValue16+360
elseif currentValue16>180 then
currentValue16=currentValue16-360
end
if math["abs"](currentValue16)>.05 and math["abs"](currentValue16)<100 then
conditionMet8=true
local conditionMet12=false
if currentValue16>0 then
local currentValue17=((currentValue12-currentValue15))%360
local currentValue18=((currentValue12-currentValue10))%360
if currentValue17<180 and currentValue18>180 then
conditionMet12=true
end
else
local currentValue17=((currentValue15-currentValue13))%360
local currentValue18=((currentValue10-currentValue13))%360
if currentValue17<180 and currentValue18>180 then
conditionMet12=true
end
end
if conditionMet12 then
currentValue14=true
end
end
end
cachedValue10=currentValue9
if not conditionMet8 then
return
end
if currentValue14 and not conditionMet10 then
conditionMet10=true processValue6()
end
end
))
end
function updateParryESP()
local parryrangeesp=settings["ParryRangeESP"]
local character2=localPlayer["Character"]
local rootPart=character2 and character2:FindFirstChild("HumanoidRootPart")
if not settings["MasterESP"]or not parryrangeesp or not rootPart then
if spearConnection then
pcall(function()spearConnection:Destroy()
end
)spearConnection=nil
end
return
end
if not spearConnection or spearConnection["Parent"]==nil then
spearConnection=Instance["new"]("CylinderHandleAdornment")spearConnection["Name"]="VD_ParryRangeESP"spearConnection["Height"]=.05 spearConnection["Color3"]=Color3["fromRGB"](138, 87, 255)spearConnection["Transparency"]=.6 spearConnection["AlwaysOnTop"]=true spearConnection["ZIndex"]=10 spearConnection["CFrame"]=CFrame["new"](0, -3.1, 0)*CFrame["Angles"](math["rad"](90), 0, 0)
end
if spearConnection["Adornee"]~=rootPart then
spearConnection["Adornee"]=rootPart
end
if spearConnection["Parent"]~=rootPart then
spearConnection["Parent"]=rootPart
end
if not spearConnection["Visible"]then
spearConnection["Visible"]=true
end
local parryrange=settings["ParryRange"]or 12
if spearConnection["Radius"]~=parryrange then
spearConnection["Radius"]=parryrange spearConnection["InnerRadius"]=parryrange-.2
end
local conditionMet8=false
if activeHumanoid then
local parryrange2=settings["ParryRange"]or 16
local currentValue6=activeHumanoid()
for index, instance in ipairs(currentValue6)do
local rootPart2=instance:FindFirstChild("HumanoidRootPart")
if rootPart2 then
local distance=((rootPart2["Position"]-rootPart["Position"]))["Magnitude"]
if distance<=parryrange2 then
conditionMet8=true
break
end
end
end
end
if conditionMet8 then
spearConnection["Color3"]=Color3["fromRGB"](50, 255, 100)
else
spearConnection["Color3"]=Color3["fromRGB"](138, 87, 255)
end
end
task["spawn"](function()
while activeLoop do
pcall(updateParryESP)task["wait"](.5)
end
end
)task["spawn"](function()
local cachedValue6=nil
local numericValue4=0
local items12={}
local numericValue5=0
local conditionMet8=false
local timeValue4=0
local conditionMet9=true
local currentValue6=.05
local conditionMet10=true
local conditionMet11=false
local conditionMet12=true
local conditionMet13=true
local conditionMet14=true
local conditionMet15=false
local connection6=false registerConnection(localPlayer["CharacterAdded"]:Connect(function()timeValue4=0
end
))
local function processValue5()
local function conditionMet16(callback, contextValue)
if callback=="ParryCooldown"or callback=="ParryCD"or callback=="ParryMissed"then
if type(contextValue)=="number"then
timeValue4=tick()+contextValue
elseif(callback:lower()):find("miss")and((contextValue==true or contextValue==60))then
timeValue4=numericValue4+60
end
end
end
local connection7=localPlayer["AttributeChanged"]:Connect(conditionMet16)registerConnection(connection7)
local function processValue6(value)
if not value then
return
end
local connection8=value["AttributeChanged"]:Connect(conditionMet16)registerConnection(connection8)
local connection9=value["ChildAdded"]:Connect(function(instance)
if(((instance["Name"]:lower()):find("cooldown")or(instance["Name"]:lower()):find("parry")))and(not instance:IsA("Tool")and(not instance:IsA("Model")and not(instance["Name"]:lower()):find("dagger")))then
task["wait"](.01)
local cachedValue7=nil
if instance:IsA("ValueBase")and type(instance["Value"])=="number"then
cachedValue7=instance["Value"]
else
local value2=instance:GetAttribute("Value")or instance:GetAttribute("Duration")or instance:GetAttribute("Cooldown")
if type(value2)=="number"then
cachedValue7=value2
end
end
if cachedValue7 then
timeValue4=numericValue4+cachedValue7
elseif(instance["Name"]:lower()):find("miss")then
timeValue4=numericValue4+60
end
end
end
)registerConnection(connection9)
end
if localPlayer["Character"]then
task["spawn"](processValue6, localPlayer["Character"])
end
local connection8=localPlayer["CharacterAdded"]:Connect(processValue6)registerConnection(connection8)
end
local function processValue6(value)
return string["match"](tostring(value), "%d+")or""
end
local player, player2, currentValue7, player3, currentValue8, character2, character3 function player()
local character4=localPlayer["Character"]
local child=localPlayer:FindFirstChildOfClass("Backpack")
local items13={}
if character4 then
table["insert"](items13, character4)
end
if child then
table["insert"](items13, child)
end
for index, instance in ipairs(items13)do
local parryingDagger=instance:FindFirstChild("Parrying Dagger")or instance:FindFirstChild("Parry Dagger")
if parryingDagger then
return parryingDagger
end
for index2, instance2 in ipairs(instance:GetChildren())do
local name2=instance2["Name"]:lower()
if string["find"](name2, "parry")or string["find"](name2, "dagger")then
return instance2
end
end
end
return nil
end
function player2()
local equippeditem=localPlayer:GetAttribute("EquippedItem")
if tostring(equippeditem)=="Parrying Dagger"or tostring(equippeditem)=="Parry Dagger"then
return true
end
if player()~=nil then
return true
end
return false
end
function player3()
local character4=localPlayer["Character"]
if character4 then
local parryingDagger=character4:FindFirstChild("Parrying Dagger")or character4:FindFirstChild("Parry Dagger")
if parryingDagger then
return true
end
for index, instance in ipairs(character4:GetChildren())do
local name2=instance["Name"]:lower()
if string["find"](name2, "parry")or string["find"](name2, "dagger")then
return true
end
end
end
return false
end
function currentValue7()
local player4=player()
if player4 and player4["Parent"]~=localPlayer["Character"]then
local character4=localPlayer["Character"]and localPlayer["Character"]:FindFirstChildOfClass("Humanoid")pcall(function()player4["Parent"]=localPlayer["Character"]
if character4 then
task["spawn"](function()character4:EquipTool(player4)
end
)
end
end
)task["wait"](.01)
end
end
local function processValue7()
local success2, result=pcall(function()
local instance=game:GetService("ReplicatedStorage")
local instance2=instance:FindFirstChild("Remotes")
local instance3=instance2 and instance2:FindFirstChild("Items")
local instance4=instance3 and((instance3:FindFirstChild("Parrying Dagger")or instance3:FindFirstChild("Parry Dagger")))
if instance4 then
return instance4:FindFirstChild("parry")or instance4:FindFirstChild("Parry")
end
end
)
if success2 and result then
return result
end
local currentValue9=player()
if currentValue9 then
for index, instance in ipairs(currentValue9:GetDescendants())do
if instance["Name"]=="parry"or instance["Name"]=="Parry"then
return instance
end
end
for index, instance in ipairs(currentValue9:GetDescendants())do
if instance:IsA("RemoteEvent")or instance:IsA("RemoteFunction")then
return instance
end
end
end
local currentValue10=game:GetService("ReplicatedStorage")
for index, instance in ipairs(currentValue10:GetDescendants())do
if instance["Name"]=="parry"and((instance:IsA("RemoteEvent")or instance:IsA("RemoteFunction")))then
return instance
end
end
return nil
end
local connection7=nil
local function processValue8()
if connection7 then
return
end
local instance=player()
local instance2=nil
if instance then
instance2=instance:FindFirstChild("parryResult")or instance:FindFirstChild("ParryResult")
end
if not instance2 then
local instance3=game:GetService("ReplicatedStorage")
local instance4=instance3:FindFirstChild("Remotes")
if instance4 then
local instance5=instance4:FindFirstChild("Items")
if instance5 then
local instance6=instance5:FindFirstChild("Parrying Dagger")or instance5:FindFirstChild("Parry Dagger")
if instance6 then
instance2=instance6:FindFirstChild("parryResult")or instance6:FindFirstChild("ParryResult")
end
end
end
end
if not instance2 then
local instance3=game:GetService("ReplicatedStorage")instance2=instance3:FindFirstChild("parryResult", true)or instance3:FindFirstChild("ParryResult", true)
end
if instance2 and instance2:IsA("RemoteEvent")then
connection7=instance2["OnClientEvent"]:Connect(function(value, contextValue)
local timestamp=tonumber(contextValue)or(value and 90 or 60)timeValue4=tick()+timestamp print(string["format"]("[Auto Parry] Feedback server ricevuto: success=%s, cd=%ss. Sync cooldown: %.1fs", tostring(value), tostring(contextValue), timestamp))
end
)registerConnection(connection7)
end
end
local function readStateValue2()
if cachedValue6 and(cachedValue6["Parent"]and cachedValue6:IsDescendantOf(game))then
return cachedValue6
end
local currentValue9=processValue7()
if currentValue9 then
cachedValue6=currentValue9 pcall(processValue8)
if not conditionMet8 then
conditionMet8=true
end
return cachedValue6
end
return nil
end
task["defer"](readStateValue2)activeCharacter=function()
local items13={}
for index, player4 in ipairs(Players:GetPlayers())do
if player4==localPlayer then
continue
end
local conditionMet16=false
if player4:GetAttribute("Role")=="Killer"or player4:GetAttribute("IsKiller")==true then
conditionMet16=true
elseif player4["Character"]and((player4["Character"]:GetAttribute("Role")=="Killer"or player4["Character"]:GetAttribute("IsKiller")==true))then
conditionMet16=true
end
if not conditionMet16 then
local name2=player4["Team"]
if name2 then
local name3=name2["Name"]:lower()
if name3:find("killer")or name3:find("slasher")or name3:find("hunter")or name3:find("monster")then
conditionMet16=true
elseif not name3:find("survivor")and(not name3:find("lobby")and not name3:find("spectat"))then
conditionMet16=true
end
else
local name3=player4["Name"]:lower()
if name3:find("killer")or name3:find("slasher")or name3:find("hunter")then
conditionMet16=true
end
end
end
if conditionMet16 and(player4["Character"]and player4["Character"]:FindFirstChild("HumanoidRootPart"))then
table["insert"](items13, player4)
end
end
return items13
end
activeHumanoid=function()
local items13={}
local character4=activeCharacter()
for index, player4 in ipairs(character4)do
if player4["Character"]then
table["insert"](items13, player4["Character"])
end
end
local killers=workspace:FindFirstChild("Killers")
if killers then
for index, instance in ipairs(killers:GetChildren())do
if instance:IsA("Model")and(instance:FindFirstChildOfClass("Humanoid")and instance:FindFirstChild("HumanoidRootPart"))then
if not table["find"](items13, instance)then
table["insert"](items13, instance)
end
end
end
end
if items6 then
for index, instance in ipairs(items6)do
if instance and instance["Parent"]then
if not table["find"](items13, instance)then
table["insert"](items13, instance)
end
end
end
end
for index, instance in ipairs(workspace:GetChildren())do
if instance:IsA("Model")and instance~=localPlayer["Character"]then
local name2=instance["Name"]:lower()
if string["find"](name2, "zombie")or string["find"](name2, "slasher")or string["find"](name2, "monster")or string["find"](name2, "killer")or string["find"](name2, "veil")or string["find"](name2, "stalker")or string["find"](name2, "masked")or string["find"](name2, "abysswalker")then
if instance:FindFirstChildOfClass("Humanoid")and instance:FindFirstChild("HumanoidRootPart")then
if not table["find"](items13, instance)then
table["insert"](items13, instance)
end
end
end
end
end
return items13
end
local function readStateValue3(instance)
if not instance then
return false
end
local player4=Players:GetPlayerFromCharacter(instance)
if player4 then
if player4==localPlayer then
return false
end
if player4:GetAttribute("Role")=="Killer"or player4:GetAttribute("IsKiller")==true then
return true
end
if instance:GetAttribute("Role")=="Killer"or instance:GetAttribute("IsKiller")==true then
return true
end
local name2=player4["Team"]
if name2 then
local name3=name2["Name"]:lower()
if name3:find("killer")or name3:find("slasher")or name3:find("hunter")or name3:find("monster")then
return true
elseif not name3:find("survivor")and(not name3:find("lobby")and not name3:find("spectat"))then
return true
end
else
local name3=player4["Name"]:lower()
if name3:find("killer")or name3:find("slasher")or name3:find("hunter")then
return true
end
end
else
if items6 and table["find"](items6, instance)then
return true
end
if instance:IsA("Model")and instance~=localPlayer["Character"]then
local name2=instance["Name"]:lower()
if string["find"](name2, "zombie")or string["find"](name2, "slasher")or string["find"](name2, "monster")or string["find"](name2, "killer")or string["find"](name2, "veil")or string["find"](name2, "stalker")or string["find"](name2, "masked")or string["find"](name2, "abysswalker")then
if instance:FindFirstChildOfClass("Humanoid")and instance:FindFirstChild("HumanoidRootPart")then
return true
end
end
end
end
return false
end
currentValue8=function()
return false
end
local function processValue9(part)
if not part then
return Vector3["new"](0, 0, 0)
end
local success2, result=pcall(function()
return part["AssemblyLinearVelocity"]or part["Velocity"]or Vector3["new"](0, 0, 0)
end
)
return success2 and result or Vector3["new"](0, 0, 0)
end
character2=function(part, position)
local currentValue9=((position["Position"]-part["Position"]))["Unit"]
local transform=part["CFrame"]["LookVector"]
local currentValue10=transform:Dot(currentValue9)
if currentValue10>-0.1 then
return true
end
local distance=processValue9(part)
if distance["Magnitude"]>3 then
local currentValue11=distance["Unit"]
local conditionMet16=currentValue11:Dot(currentValue9)>.3
if conditionMet16 then
return true
end
end
return false
end
local function processValue10(value, instance)
if not instance then
return false
end
local animation=value["Animation"]
if animation then
local animations=instance:FindFirstChild("Animations")
if animations and animation:IsDescendantOf(animations)then
return true
end
local instance2=workspace:FindFirstChild("Jiekyns1122333")
local animations2=instance2 and instance2:FindFirstChild("Animations")
if animations2 and animation:IsDescendantOf(animations2)then
return true
end
local animation2=processValue6(animation["AnimationId"])
if animation2~=""then
if animations then
for index, instance3 in ipairs(animations:GetDescendants())do
if instance3:IsA("Animation")and processValue6(instance3["AnimationId"])==animation2 then
return true
end
end
end
if animations2 then
for index, instance3 in ipairs(animations2:GetDescendants())do
if instance3:IsA("Animation")and processValue6(instance3["AnimationId"])==animation2 then
return true
end
end
end
end
end
return false
end
local function getFeatureState3(value)
return nil
end
local function readStateValue4()
local success2=80 pcall(function()success2=(game:GetService("Stats"))["Network"]["ServerStatsItem"]["Data Ping"]:GetValue()
end
)
return success2
end
character3=function(value, contextValue, instance)
if not settings["AutoParry"]then
return
end
if _G["VD_IsDodgingStalker"]==true or(tick()-((_G["VD_LastDodgeTime"]or 0))<1.5)then
return
end
if not player2()then
return
end
local character4=localPlayer["Character"]
if character4 then
local isKnocked=character4:GetAttribute("Knocked")==true or localPlayer:GetAttribute("Knocked")==true or(getObjectValue and getObjectValue(character4, "Knocked")==true)
local isHooked=character4:GetAttribute("IsHooked")==true or localPlayer:GetAttribute("IsHooked")==true or(getObjectValue and getObjectValue(character4, "IsHooked")==true)
local conditionMet16=character4:GetAttribute("IsCarried")==true or localPlayer:GetAttribute("IsCarried")==true
if isKnocked or isHooked or conditionMet16 then
return
end
end
local conditionMet16=false
if settings["FrenzyParry"]and isFeatureAvailable()then
conditionMet16=true
end
if conditionMet16 and instance then
local conditionMet17=instance:GetAttribute("Frenzy")==true
if not conditionMet17 then
local instance2=Players:GetPlayerFromCharacter(instance)
if instance2 and instance2:GetAttribute("Frenzy")==true then
conditionMet17=true
end
end
if conditionMet17 then
return
end
end
local timestamp=tick()
if conditionMet9 and timestamp<timeValue4 then
return
end
if timestamp-numericValue4<=currentValue6 then
return
end
numericValue4=timestamp print(string["format"]("[Auto Parry Detected] Attack intercepted! Reason: %s | Distance: %.1f studs | Delay: %.2fs", value, contextValue, settings["ParryDelay"]))
if conditionMet11 then
showNotification("Parry Detected", value, "info")
end
task["spawn"](function()
local conditionMet17=false
if conditionMet10 and not player3()then
local player4=player()
if player4 and player4["Parent"]~=localPlayer["Character"]then
conditionMet17=true pcall(function()player4["Parent"]=localPlayer["Character"]
local character5=localPlayer["Character"]and localPlayer["Character"]:FindFirstChildOfClass("Humanoid")
if character5 then
task["spawn"](function()character5:EquipTool(player4)
end
)
end
end
)
end
end
if conditionMet17 then
task["wait"](.015)
end
local instance2=readStateValue2()
if instance2 then
pcall(function()
if instance2:IsA("RemoteEvent")then
instance2:FireServer()
elseif instance2:IsA("RemoteFunction")then
instance2:InvokeServer()
end
end
)
end
pcall(function()
local player4=player()
if player4 and player4["Parent"]==localPlayer["Character"]then
pcall(function()player4:Activate()
end
)
end
task["spawn"](function()
if mouse2press and mouse2release then
pcall(mouse2press)task["wait"](.15)pcall(mouse2release)
else
local button3=game:GetService("VirtualInputManager")
local camera=workspace["CurrentCamera"]
local button4=camera and camera["ViewportSize"]["X"]/2 or 500
local success2=camera and camera["ViewportSize"]["Y"]/2 or 500 pcall(function()button3:SendMouseButtonEvent(button4, success2, 1, true, game, 1)task["wait"](.15)button3:SendMouseButtonEvent(button4, success2, 1, false, game, 1)
end
)
end
end
)
end
)
if settings["ParryDelay"]and settings["ParryDelay"]>0 then
task["wait"](settings["ParryDelay"])
end
print(string["format"]("[Auto Parry Parata] >>> ESEGUITO! Motivo: %s | Distanza: %.1f studs", value, contextValue))
end
)
end
local function findRootPart(instance, contextValue, contextValue2)
if not settings["AutoParry"]then
return
end
if not player2()then
return
end
local character4=localPlayer["Character"]and localPlayer["Character"]:FindFirstChild("HumanoidRootPart")
local rootPart=instance:FindFirstChild("HumanoidRootPart")
if not character4 or not rootPart then
return
end
local parryrange=settings["ParryRange"]or 8.5
local currentValue9=parryrange
if settings["ParryPingCompensation"]then
local currentValue10=readStateValue4()currentValue9=parryrange+(currentValue10*.015)
end
local distance=math["max"](currentValue9, 13)
local distance2=((rootPart["Position"]-character4["Position"]))["Magnitude"]
if distance2<=distance then
local conditionMet16=true
if settings["ParryFacingCheck"]then
conditionMet16=character2(rootPart, character4)
end
if conditionMet16 then
character3(contextValue, distance2, instance)
return
end
end
task["spawn"](function()
local timestamp=tick()
while activeLoop and(tick()-timestamp<.6)do
local character5=localPlayer["Character"]
local rootPart2=character5 and character5:FindFirstChild("HumanoidRootPart")
local rootPart3=instance:FindFirstChild("HumanoidRootPart")
if not rootPart2 or not rootPart3 then
break
end
local distance3=((rootPart3["Position"]-rootPart2["Position"]))["Magnitude"]
if distance3>35 then
break
end
local parryrange2=settings["ParryRange"]or 8.5
local currentValue10=parryrange2
if settings["ParryPingCompensation"]then
local currentValue11=readStateValue4()currentValue10=parryrange2+(currentValue11*.015)
end
local currentValue11=math["max"](currentValue10, 13)
if distance3<=currentValue11 then
local conditionMet16=true
if settings["ParryFacingCheck"]then
conditionMet16=character2(rootPart3, rootPart2)
end
if conditionMet16 then
character3(contextValue, distance3, instance)
break
end
end
task["wait"](.01)
end
end
)
end
local items13={}
local function findRootPart2(instance)
if items13[instance]then
return
end
items13[instance]=true
if not instance:IsA("BasePart")then
items13[instance]=nil
return
end
local character4=localPlayer["Character"]and localPlayer["Character"]:FindFirstChild("HumanoidRootPart")
if not character4 then
items13[instance]=nil
return
end
if not settings["AutoParry"]or not conditionMet13 or not player2()then
items13[instance]=nil
return
end
if instance:IsDescendantOf(localPlayer["Character"])then
items13[instance]=nil
return
end
local parryrange=settings["ParryRange"]or 8.5
local currentValue9=parryrange
if settings["ParryPingCompensation"]then
local currentValue10=readStateValue4()currentValue9=parryrange+(currentValue10*.015)
end
local distance=math["max"](currentValue9, 13)
local distance2=((instance["Position"]-character4["Position"]))["Magnitude"]
if distance2<=distance then
local timestamp=tick()
if timestamp-numericValue5>=1 or#items12==0 then
numericValue5=timestamp items12=activeHumanoid()
end
local currentValue10=items12
local instance2=nil
for index, instance3 in ipairs(currentValue10)do
local rootPart=instance3:FindFirstChild("HumanoidRootPart")
if rootPart then
local distance3=((instance["Position"]-rootPart["Position"]))["Magnitude"]
if distance3<15 then
instance2=instance3
break
end
end
end
if instance2 then
local conditionMet16=true
if settings["ParryFacingCheck"]then
local rootPart=instance2:FindFirstChild("HumanoidRootPart")
if rootPart then
conditionMet16=character2(rootPart, character4)
end
end
if conditionMet16 then
character3("Rilevata Hitbox di Attacco ("..(instance["Name"]..")"), distance2, instance2)items13[instance]=nil
return
end
end
end
task["spawn"](function()
local timestamp=tick()
local timestamp2=tick()
if timestamp2-numericValue5>=1 or#items12==0 then
numericValue5=timestamp2 items12=activeHumanoid()
end
local currentValue10=items12
while activeLoop and((tick()-timestamp<.3)and(instance and instance["Parent"]))do
local character5=localPlayer["Character"]
local rootPart=character5 and character5:FindFirstChild("HumanoidRootPart")
if not rootPart then
break
end
local distance3=((instance["Position"]-rootPart["Position"]))["Magnitude"]
if distance3>30 then
break
end
local parryrange2=settings["ParryRange"]or 8.5
local currentValue11=parryrange2
if settings["ParryPingCompensation"]then
local currentValue12=readStateValue4()currentValue11=parryrange2+(currentValue12*.015)
end
local currentValue12=math["max"](currentValue11, 13)
if distance3<=currentValue12 then
local instance2=nil
for index, instance3 in ipairs(currentValue10)do
local rootPart2=instance3:FindFirstChild("HumanoidRootPart")
if rootPart2 then
local distance4=((instance["Position"]-rootPart2["Position"]))["Magnitude"]
if distance4<15 then
instance2=instance3
break
end
end
end
if instance2 then
local conditionMet16=true
if settings["ParryFacingCheck"]then
local rootPart2=instance2:FindFirstChild("HumanoidRootPart")
if rootPart2 then
conditionMet16=character2(rootPart2, rootPart)
end
end
if conditionMet16 then
character3("Rilevata Hitbox di Attacco ("..(instance["Name"]..")"), distance3, instance2)
break
end
end
end
task["wait"](.01)
end
items13[instance]=nil
end
)
end
local function getFeatureState4(value)
local instance=value["Parent"]
while instance and instance~=workspace do
if instance:IsA("Tool")then
return true
end
instance=instance["Parent"]
end
return false
end
registerConnection(workspace["DescendantAdded"]:Connect(function(instance)
if not settings["AutoParry"]or not conditionMet13 then
return
end
if not instance:IsA("BasePart")then
return
end
local name2=instance["Name"]:lower()
local conditionMet16=false
if string["match"](instance["Name"], "^WallHitboxCollider_%d+$")then
conditionMet16=true
elseif string["find"](name2, "hitbox")or string["find"](name2, "collider")or string["find"](name2, "swing")or string["find"](name2, "slash")or string["find"](name2, "attack")then
if not getFeatureState4(instance)then
conditionMet16=true
end
end
if conditionMet16 then
findRootPart2(instance)
end
end
))
local connections2={}
local function findRootPart3(value, instance)
if connections2[value]then
return
end
connections2[value]=true
local function findRootPart4(name2)pcall(function()
if settings["AutoDodgeVeilSpear"]and((settings["AutoFarmSurvivor"]or settings["AutoFarmAFKTotal"]))then
local character4=localPlayer["Character"]and localPlayer["Character"]:FindFirstChild("HumanoidRootPart")
local rootPart=instance and instance:FindFirstChild("HumanoidRootPart")
if character4 and rootPart then
local distance=((rootPart["Position"]-character4["Position"]))["Magnitude"]
if distance<=150 then
local animation=processValue6(name2["Animation"]["AnimationId"])
local animation2=((name2["Animation"]["Name"]or"")):lower()
local player4=animation2:find("throw")or animation2:find("spear")or animation2:find("launch")or animation2:find("cast")
if not player4 and(((name2["Priority"]==Enum["AnimationPriority"]["Action"]or name2["Priority"]==Enum["AnimationPriority"]["Action2"]))and not name2["Looped"])then
if distance>18 then
local currentValue9=((character4["Position"]-rootPart["Position"]))["Unit"]
local transform=rootPart["CFrame"]["LookVector"]:Dot(currentValue9)
if transform>.3 then
player4=true
end
end
end
if player4 then
local character5=localPlayer["Character"]
local isKnocked=character5 and((character5:GetAttribute("Knocked")==true or localPlayer:GetAttribute("Knocked")==true))
local isHooked=character5 and((character5:GetAttribute("IsHooked")==true or localPlayer:GetAttribute("IsHooked")==true))
if not isKnocked and not isHooked then
if _G["VD_PreemptiveDodge"]then
pcall(_G["VD_PreemptiveDodge"])
end
end
end
end
end
end
end
)
if not settings["AutoParry"]or not conditionMet14 or not player2()then
return
end
local animation=processValue6(name2["Animation"]["AnimationId"])
if animation=="80411309607666"and(settings["IgnoreAbysswalkerLunge"]and isFeatureAvailable())then
return
end
local currentValue9=items4[animation]and not items5[animation]
local conditionMet16=false
if not currentValue9 and not items5[animation]then
local animation2=name2["Priority"]
local conditionMet17=(animation2==Enum["AnimationPriority"]["Action"]or animation2==Enum["AnimationPriority"]["Action2"]or animation2==Enum["AnimationPriority"]["Action3"]or animation2==Enum["AnimationPriority"]["Action4"])
if not name2["Looped"]and conditionMet17 then
conditionMet16=true
end
end
if currentValue9 or conditionMet16 then
if not processValue10(name2, instance)then
local currentValue10=getFeatureState3(animation)
local currentValue11=currentValue9 and("Animazione di Attacco: "..animation)or("Universal Action Attack: "..animation)
if currentValue10 then
currentValue11=currentValue11..(" (Explorer: "..(currentValue10..")"))
end
findRootPart(instance, currentValue11, animation)
end
end
end
local connection8=value["AnimationPlayed"]:Connect(findRootPart4)registerConnection(connection8)pcall(function()
for index, item in ipairs(value:GetPlayingAnimationTracks())do
task["spawn"](findRootPart4, item)
end
end
)task["spawn"](function()
while value and(value["Parent"]and(value:IsDescendantOf(workspace)and activeLoop))do
task["wait"](1)
end
if connection8 then
connection8:Disconnect()
end
connections2[value]=nil
end
)
end
local numericValue6=100
local character4=localPlayer["Character"]
if character4 then
local humanoid=character4:FindFirstChildOfClass("Humanoid")
if humanoid then
numericValue6=humanoid["Health"]
end
end
local function findRootPart4(instance)
if not instance then
return
end
local humanoid=instance:WaitForChild("Humanoid", 5)or instance:FindFirstChildOfClass("Humanoid")
if humanoid then
local health=humanoid["Health"]
local health2 health2=humanoid["HealthChanged"]:Connect(function(value)
if not settings["AutoParry"]or not conditionMet14 then
return
end
if value<health then
local rootPart=instance:FindFirstChild("HumanoidRootPart")
if rootPart then
local currentValue9=activeHumanoid()
for index, instance2 in ipairs(currentValue9)do
local rootPart2=instance2:FindFirstChild("HumanoidRootPart")
if rootPart2 and((rootPart2["Position"]-rootPart["Position"]))["Magnitude"]<18 then
local humanoid2=instance2:FindFirstChildOfClass("Humanoid")
local child=humanoid2 and humanoid2:FindFirstChildOfClass("Animator")
if child then
for index2, item in ipairs(child:GetPlayingAnimationTracks())do
local animation=item["Priority"]
local conditionMet16=(animation==Enum["AnimationPriority"]["Action"]or animation==Enum["AnimationPriority"]["Action2"]or animation==Enum["AnimationPriority"]["Action3"]or animation==Enum["AnimationPriority"]["Action4"])
if not item["Looped"]and conditionMet16 then
local animation2=processValue6(item["Animation"]["AnimationId"])
if animation2~=""and(not items4[animation2]and not items5[animation2])then
items4[animation2]=true print("[Auto Parry Learning] Learned new attack animation from damage: "..animation2)
end
end
end
end
end
end
end
end
health=value
end
)registerConnection(health2)
end
end
if localPlayer["Character"]then
task["spawn"](findRootPart4, localPlayer["Character"])
end
registerConnection(localPlayer["CharacterAdded"]:Connect(function(value)pcall(scanMapObjects)findRootPart4(value)
end
))
local function findRootPart5(instance, instance2)
if not instance:IsA("Tool")then
return
end
if instance:GetAttribute("VD_Hooked")then
return
end
instance:SetAttribute("VD_Hooked", true)
local function findRootPart6(highlight)
if highlight:IsA("Trail")or highlight:IsA("Beam")then
local connection8=(highlight:GetPropertyChangedSignal("Enabled")):Connect(function()
if highlight["Enabled"]and settings["AutoParry"]then
local character5=localPlayer["Character"]
local rootPart=character5 and character5:FindFirstChild("HumanoidRootPart")
local rootPart2=instance2:FindFirstChild("HumanoidRootPart")
if rootPart and rootPart2 then
local distance=((rootPart2["Position"]-rootPart["Position"]))["Magnitude"]
if distance<=14 then
character3("Attivazione Trail Arma ("..(instance["Name"]..")"), distance, instance2)
end
end
end
end
)registerConnection(connection8)
elseif highlight:IsA("BasePart")then
local character5=highlight["Touched"]:Connect(function(value)
if settings["AutoParry"]then
local character6=localPlayer["Character"]
if character6 and value:IsDescendantOf(character6)then
local rootPart=character6:FindFirstChild("HumanoidRootPart")
local rootPart2=instance2:FindFirstChild("HumanoidRootPart")
if rootPart and rootPart2 then
local distance=((rootPart2["Position"]-rootPart["Position"]))["Magnitude"]
if distance<=14 then
character3("Contatto Fisico Arma ("..(instance["Name"]..")"), distance, instance2)
end
end
end
end
end
)registerConnection(character5)
end
end
for index, item in ipairs(instance:GetDescendants())do
task["spawn"](findRootPart6, item)
end
local success2=instance["DescendantAdded"]:Connect(function(value)pcall(findRootPart6, value)
end
)registerConnection(success2)
end
local function processValue11(value)
if not value then
return
end
if not readStateValue3(value)then
return
end
local function processValue12(instance)
if instance:IsA("Humanoid")then
local function processValue13(instance2)
if instance2:IsA("Animator")then
pcall(findRootPart3, instance2, value)
end
end
instance["ChildAdded"]:Connect(processValue13)
local child=instance:FindFirstChildOfClass("Animator")
if child then
pcall(findRootPart3, child, value)
end
elseif instance:IsA("Tool")then
pcall(findRootPart5, instance, value)
end
end
value["ChildAdded"]:Connect(processValue12)
for index, item in ipairs(value:GetChildren())do
pcall(processValue12, item)
end
end
for index, player4 in ipairs(Players:GetPlayers())do
if player4~=localPlayer then
if player4["Character"]then
task["spawn"](processValue11, player4["Character"])
end
registerConnection(player4["CharacterAdded"]:Connect(function(value)processValue11(value)
end
))
end
end
registerConnection(Players["PlayerAdded"]:Connect(function(value)registerConnection(value["CharacterAdded"]:Connect(function(value2)processValue11(value2)
end
))
end
))task["spawn"](function()
while activeLoop do
if settings["AutoParry"]and player2()then
pcall(function()
local character5=localPlayer["Character"]
local rootPart=character5 and character5:FindFirstChild("HumanoidRootPart")
local rootPart2=tick()
if rootPart2-numericValue5>=1 or#items12==0 then
numericValue5=rootPart2 items12=activeHumanoid()
end
local currentValue9=items12
local numericValue7=9999
for index, instance in ipairs(currentValue9)do
local rootPart3=instance:FindFirstChild("HumanoidRootPart")
if rootPart3 then
if rootPart then
local distance=((rootPart3["Position"]-rootPart["Position"]))["Magnitude"]
if distance<numericValue7 then
numericValue7=distance
end
end
end
local humanoid=instance:FindFirstChildOfClass("Humanoid")
local child=humanoid and humanoid:FindFirstChildOfClass("Animator")
if child and readStateValue3(instance)then
findRootPart3(child, instance)
end
end
if numericValue7<=45 and(conditionMet10 and not player3())then
currentValue7()
end
end
)
end
task["wait"](.05)
end
end
)task["spawn"](function()
local remotes=(game:GetService("ReplicatedStorage")):WaitForChild("Remotes", 5)remotes=remotes and remotes:WaitForChild("Attacks", 5)
if not remotes then
return
end
local function findRootPart6(...)
for key=1, select("#", ...), 1 do
local player4=select(key, ...)
if typeof(player4)=="Instance"then
if player4:IsA("Model")and player4:FindFirstChildOfClass("Humanoid")then
return player4
elseif player4:IsA("Player")and player4["Character"]then
return player4["Character"]
end
end
end
local character5=localPlayer["Character"]
local rootPart=character5 and character5:FindFirstChild("HumanoidRootPart")
if rootPart then
local cachedValue7=nil
local timeValue5=30
local timestamp=tick()
if timestamp-numericValue5>=1 or#items12==0 then
numericValue5=timestamp items12=activeHumanoid()
end
for index, instance in ipairs(items12)do
local rootPart2=instance:FindFirstChild("HumanoidRootPart")
if rootPart2 then
local distance=((rootPart2["Position"]-rootPart["Position"]))["Magnitude"]
if distance<timeValue5 then
timeValue5=distance cachedValue7=instance
end
end
end
return cachedValue7
end
return nil
end
local function getFeatureState5(value, ...)
if not settings["AutoParry"]or not conditionMet15 or not player2()then
return
end
local currentValue9=findRootPart6(...)
if not currentValue9 then
return
end
findRootPart(currentValue9, "Remoto di Attacco ("..(value..")"), value)
end
for index, instance in ipairs(remotes:GetChildren())do
if instance:IsA("RemoteEvent")then
registerConnection(instance["OnClientEvent"]:Connect(function(...)pcall(getFeatureState5, instance["Name"], ...)
end
))
end
end
end
)task["spawn"](function()
while activeLoop do
if settings["AutoParry"]and(connection6 and player2())then
pcall(function()
local character5=localPlayer["Character"]
local rootPart=character5 and character5:FindFirstChild("HumanoidRootPart")
if rootPart then
local timestamp=tick()
if timestamp-numericValue5>=1 or#items12==0 then
numericValue5=timestamp items12=activeHumanoid()
end
local currentValue9=items12
for index, instance in ipairs(currentValue9)do
local rootPart2=instance:FindFirstChild("HumanoidRootPart")
if rootPart2 then
local distance=((rootPart2["Position"]-rootPart["Position"]))["Magnitude"]
if distance<=45 and(conditionMet10 and not player3())then
currentValue7()
end
if distance<=9 then
local distance2=processValue9(rootPart2)
if distance2["Magnitude"]>=12 then
local currentValue10=((rootPart["Position"]-rootPart2["Position"]))["Unit"]
local currentValue11=distance2["Unit"]:Dot(currentValue10)
if currentValue11>.75 then
character3("Rincorsa Veloce Killer (Distanza: "..(string["format"]("%.1f", distance)..")"), distance, instance)
end
end
end
end
end
end
end
)
end
task["wait"](.01)
end
end
)
local function getFeatureState5()
local instance=localPlayer:FindFirstChildOfClass("PlayerGui")
if not instance then
return nil
end
local instance2=instance:FindFirstChild("Survivor")
if not instance2 then
return nil
end
local instance3=instance2:FindFirstChild("Gen")
if not instance3 then
return nil
end
local instance4=instance3:FindFirstChild("ItemFrame")
if not instance4 then
return nil
end
return instance4:FindFirstChild("Gui")
end
local function getFeatureState6()
if settings["HideParryUI"]then
cleanupParryUI()
return
end
local timestamp=tick()
local success2=player2()pcall(function()
local instance=getFeatureState5()
if instance then
local label4=instance:FindFirstChild("ParryCooldownLabel")
if not label4 then
label4=Instance["new"]("TextLabel")label4["Name"]="ParryCooldownLabel"label4["Size"]=UDim2["new"](1, 0, 1, 0)label4["Position"]=UDim2["new"](0, 0, 0, 0)label4["BackgroundTransparency"]=1 label4["TextXAlignment"]=Enum["TextXAlignment"]["Center"]label4["TextYAlignment"]=Enum["TextYAlignment"]["Center"]label4["TextScaled"]=true label4["TextStrokeTransparency"]=0 label4["TextStrokeColor3"]=Color3["fromRGB"](0, 0, 0)label4["Parent"]=instance
local uITextSizeConstraint=Instance["new"]("UITextSizeConstraint", label4)uITextSizeConstraint["MaxTextSize"]=13 uITextSizeConstraint["MinTextSize"]=8
end
if not success2 then
label4["Visible"]=false
else
if timestamp<timeValue4 then
local text=math["ceil"](timeValue4-timestamp)label4["Text"]="COOLDOWN\n"..(tostring(text).."s")label4["TextColor3"]=Color3["fromRGB"](255, 60, 60)label4["Font"]=Enum["Font"]["GothamBold"]label4["Visible"]=true
else
label4["Text"]="READY!"label4["TextColor3"]=Color3["fromRGB"](0, 255, 120)label4["Font"]=Enum["Font"]["GothamBold"]label4["Visible"]=true
end
end
end
end
)pcall(function()
local instance=localPlayer:FindFirstChildOfClass("PlayerGui")
local instance2=instance and instance:FindFirstChild("Survivor-mob")
local instance3=instance2 and instance2:FindFirstChild("Controls")
local instance4=instance3 and instance3:FindFirstChild("action")
if instance4 then
local label4=instance4:FindFirstChild("ParryCooldownLabel")
if not label4 then
label4=Instance["new"]("TextLabel")label4["Name"]="ParryCooldownLabel"label4["BackgroundTransparency"]=1 label4["TextXAlignment"]=Enum["TextXAlignment"]["Center"]label4["TextYAlignment"]=Enum["TextYAlignment"]["Center"]label4["TextScaled"]=true label4["TextStrokeTransparency"]=0 label4["TextStrokeColor3"]=Color3["fromRGB"](0, 0, 0)label4["Active"]=false label4["Selectable"]=false label4["Size"]=UDim2["new"](1.2, 0, .4, 0)label4["Position"]=UDim2["new"](-0.1, 0, -0.45, 0)label4["Parent"]=instance4
local uITextSizeConstraint=Instance["new"]("UITextSizeConstraint", label4)uITextSizeConstraint["MaxTextSize"]=14 uITextSizeConstraint["MinTextSize"]=8
end
if not success2 then
label4["Visible"]=false
else
if timestamp<timeValue4 then
local text=math["ceil"](timeValue4-timestamp)label4["Text"]="COOLDOWN: "..(tostring(text).."s")label4["TextColor3"]=Color3["fromRGB"](255, 60, 60)label4["Font"]=Enum["Font"]["GothamBold"]label4["Visible"]=true
else
label4["Text"]="READY!"label4["TextColor3"]=Color3["fromRGB"](0, 255, 120)label4["Font"]=Enum["Font"]["GothamBold"]label4["Visible"]=true
end
end
end
end
)
end
local function cleanupResources2()
local success2=tick()pcall(function()
local instance=localPlayer:FindFirstChildOfClass("PlayerGui")
if not instance then
return
end
local instance2=instance:FindFirstChild("SurvivorPerks")
local flowstatecustomlabel=instance2 and instance2:FindFirstChild("FlowstateCustomLabel")
if flowstatecustomlabel then
pcall(function()flowstatecustomlabel:Destroy()
end
)
end
local instance3=nil
if instance2 then
instance3=instance2:FindFirstChild("Perks")
end
if not instance3 then
local instance4=instance:FindFirstChild("Survivor")
if instance4 then
instance3=instance4:FindFirstChild("Perks")
end
end
if not instance3 then
local instance4=instance:FindFirstChild("Survivor-mob")
if instance4 then
instance3=instance4:FindFirstChild("Perks")or instance4:FindFirstChild("Controls")
end
end
local instance4=nil
if instance3 then
for index, instance5 in ipairs(instance3:GetChildren())do
if instance5:IsA("Frame")or instance5:IsA("GuiObject")then
local instance6=instance5:FindFirstChild("Icon", true)or instance5:FindFirstChildOfClass("ImageLabel")
if instance6 and instance6:IsA("ImageLabel")then
local label4=tostring(instance6["Image"])
if label4:find("108420950668748")then
instance4=instance5
break
end
end
end
end
if not instance4 then
instance4=instance3:FindFirstChild("2")
end
end
if instance4 then
local vdFlowstatefloatingui=instance:FindFirstChild("VD_FlowstateFloatingUI", true)
if vdFlowstatefloatingui then
pcall(function()vdFlowstatefloatingui:Destroy()
end
)
end
local label4=instance4:FindFirstChild("FlowstateCooldownLabel")
if readStateValue()and not settings["HideFlowstateUI"]then
if not label4 then
label4=Instance["new"]("TextLabel")label4["Name"]="FlowstateCooldownLabel"
if isMobileDevice then
label4["Size"]=UDim2["new"](1.2, 0, 0, 14)label4["Position"]=UDim2["new"](-0.1, 0, 1.05, 0)
else
label4["Size"]=UDim2["new"](1.6, 0, 0, 16)label4["Position"]=UDim2["new"](-0.3, 0, -0.4, 0)
end
label4["BackgroundTransparency"]=1 label4["TextXAlignment"]=Enum["TextXAlignment"]["Center"]label4["TextYAlignment"]=Enum["TextYAlignment"]["Center"]label4["TextScaled"]=false label4["TextSize"]=isMobileDevice and 10 or 12 label4["TextStrokeTransparency"]=0 label4["TextStrokeColor3"]=Color3["fromRGB"](0, 0, 0)label4["Parent"]=instance4
end
if success2<timeValue2 then
local text=math["ceil"](timeValue2-success2)label4["Text"]="FLOWSTATE: "..(tostring(text).."s")label4["TextColor3"]=Color3["fromRGB"](255, 60, 60)label4["Font"]=Enum["Font"]["GothamBold"]label4["Visible"]=true
else
label4["Text"]="FLOWSTATE: READY"label4["TextColor3"]=Color3["fromRGB"](0, 255, 120)label4["Font"]=Enum["Font"]["GothamBold"]label4["Visible"]=true
end
else
if label4 then
pcall(function()label4:Destroy()
end
)
end
end
else
if instance3 then
for index, instance5 in ipairs(instance3:GetChildren())do
local flowstatecooldownlabel=instance5:FindFirstChild("FlowstateCooldownLabel")
if flowstatecooldownlabel then
pcall(function()flowstatecooldownlabel:Destroy()
end
)
end
end
end
if readStateValue()and not settings["HideFlowstateUI"]then
local cachedValue7=nil
for index, instance5 in ipairs(instance:GetDescendants())do
if instance5["Name"]=="VD_InfoBanner"and instance5:IsA("Frame")then
cachedValue7=instance5
break
end
end
local label4=instance:FindFirstChild("VD_FlowstateFloatingUI", true)
if not label4 then
label4=Instance["new"]("TextLabel")label4["Name"]="VD_FlowstateFloatingUI"label4["BackgroundTransparency"]=1 label4["TextXAlignment"]=Enum["TextXAlignment"]["Center"]label4["TextYAlignment"]=Enum["TextYAlignment"]["Center"]label4["TextSize"]=isMobileDevice and 11 or 13 label4["TextStrokeTransparency"]=0 label4["TextStrokeColor3"]=Color3["fromRGB"](0, 0, 0)label4["Font"]=Enum["Font"]["GothamBold"]
end
if cachedValue7 and cachedValue7["Visible"]then
pcall(function()cachedValue7["ClipsDescendants"]=false
end
)label4["Parent"]=cachedValue7 label4["AnchorPoint"]=Vector2["new"](.5, 0)label4["Position"]=UDim2["new"](.5, 0, 1, 5)label4["Size"]=UDim2["new"](1.5, 0, 0, 14)
else
local child=(cachedValue7 and cachedValue7["Parent"])or instance:FindFirstChildOfClass("ScreenGui")or instance label4["Parent"]=child label4["AnchorPoint"]=Vector2["new"](.5, 0)label4["Position"]=UDim2["new"](.5, 0, 0, isMobileDevice and 45 or 55)label4["Size"]=UDim2["new"](0, 200, 0, 14)
end
if success2<timeValue2 then
local text=math["ceil"](timeValue2-success2)label4["Text"]="FLOWSTATE: "..(tostring(text).."s")label4["TextColor3"]=Color3["fromRGB"](255, 60, 60)
else
label4["Text"]="FLOWSTATE: READY"label4["TextColor3"]=Color3["fromRGB"](0, 255, 120)
end
label4["Visible"]=true
else
local vdFlowstatefloatingui=instance:FindFirstChild("VD_FlowstateFloatingUI", true)
if vdFlowstatefloatingui then
pcall(function()vdFlowstatefloatingui:Destroy()
end
)
end
end
end
end
)
end
task["spawn"](function()
while activeLoop do
pcall(getFeatureState6)pcall(cleanupResources2)task["wait"](.2)
end
end
)processValue5()
end
)task["spawn"](function()
local connection6=nil
local function readStateValue2(value)
if value then
if not connection6 then
connection6=RunService["Stepped"]:Connect(function()
local character2=localPlayer["Character"]
if character2 then
for index, instance in ipairs(character2:GetDescendants())do
if instance:IsA("BasePart")then
instance["CanCollide"]=false
end
end
end
end
)
end
else
if connection6 then
connection6:Disconnect()connection6=nil
end
end
end
local function readStateValue3()
local equippeditem=localPlayer:GetAttribute("EquippedItem")
if equippeditem=="Twist of Fate"then
return true
end
if Players:GetAttribute("EquippedItem")=="Twist of Fate"then
return true
end
local character2=localPlayer["Character"]
if character2 and((character2:FindFirstChild("Twist of Fate")or character2:FindFirstChild("gun")))then
return true
end
local instance=localPlayer:FindFirstChildOfClass("Backpack")
if instance and instance:FindFirstChild("Twist of Fate")then
return true
end
return false
end
while activeLoop do
if settings["RevolverAutofarm"]and(isFeatureAvailable()and(featureAvailability and featureAvailability["RevolverAutofarm"]))then
pcall(function()
local teamName=localPlayer["Team"]and localPlayer["Team"]["Name"]or""
if teamName=="Survivors"then
local farmstate=_G["VD_FarmState"]["lastSurvivorSpawnTime"]or 0
if farmstate>0 and(tick()-farmstate)>=15 then
if readStateValue3()then
local character2=localPlayer["Character"]
local rootPart=character2 and character2:FindFirstChild("HumanoidRootPart")
local humanoid=character2 and character2:FindFirstChildOfClass("Humanoid")
if rootPart and(humanoid and humanoid["Health"]>0)then
local instance=character2:FindFirstChild("Twist of Fate")
if not instance then
local instance2=localPlayer:FindFirstChildOfClass("Backpack")
local twistOfFate=instance2 and instance2:FindFirstChild("Twist of Fate")
if twistOfFate then
humanoid:EquipTool(twistOfFate)task["wait"](.1)instance=character2:FindFirstChild("Twist of Fate")
end
end
if instance then
local instance2=instance:FindFirstChild("Right Arm")
local gun=instance2 and instance2:FindFirstChild("gun")
if not gun then
gun=instance:FindFirstChild("gun", true)
end
if gun then
local cachedValue6=nil
local items12={}
for index, player in ipairs(Players:GetPlayers())do
if player~=localPlayer then
local conditionMet8=false
if player:GetAttribute("Role")=="Killer"or player:GetAttribute("IsKiller")==true then
conditionMet8=true
elseif player["Character"]and((player["Character"]:GetAttribute("Role")=="Killer"or player["Character"]:GetAttribute("IsKiller")==true))then
conditionMet8=true
else
local name2=player["Team"]
if name2 then
local name3=name2["Name"]:lower()
if name3:find("killer")or name3:find("slasher")then
conditionMet8=true
end
end
end
if conditionMet8 and(player["Character"]and player["Character"]:FindFirstChild("HumanoidRootPart"))then
local humanoid2=player["Character"]:FindFirstChildOfClass("Humanoid")
if humanoid2 and humanoid2["Health"]>0 then
table["insert"](items12, player["Character"])
end
end
end
end
if#items12==0 then
for index, instance3 in ipairs(workspace:GetChildren())do
if instance3:IsA("Model")and instance3~=character2 then
local name2=instance3["Name"]:lower()
if string["find"](name2, "zombie")or string["find"](name2, "slasher")or string["find"](name2, "monster")or string["find"](name2, "killer")then
local humanoid2=instance3:FindFirstChildOfClass("Humanoid")
if humanoid2 and(humanoid2["Health"]>0 and instance3:FindFirstChild("HumanoidRootPart"))then
table["insert"](items12, instance3)
end
end
end
end
end
if#items12>0 then
local instance3=items12[1]
local rootPart2=instance3:FindFirstChild("HumanoidRootPart")
if rootPart2 then
readStateValue2(true)
local transform=rootPart2["Position"]-(rootPart2["CFrame"]["LookVector"]*8)
local vector2=rootPart2["Position"]+Vector3["new"](0, -1, 0)rootPart["CFrame"]=CFrame["lookAt"](transform, vector2)
local distance=((vector2-rootPart["Position"]))["Unit"]
if distance["Magnitude"]==0 or distance["X"]~=distance["X"]then
distance=Vector3["new"](0, 0, -1)
end
local instance4=game:GetService("ReplicatedStorage")
local instance5=instance4:FindFirstChild("Remotes")
local instance6=instance5 and instance5:FindFirstChild("Items")
local instance7=instance6 and instance6:FindFirstChild("Twist of Fate")
local fire=instance7 and instance7:FindFirstChild("Fire")
if not fire then
for index, instance8 in ipairs(instance4:GetDescendants())do
if instance8["Name"]=="Fire"and(instance8["Parent"]and instance8["Parent"]["Name"]=="Twist of Fate")then
fire=instance8
break
end
end
end
if fire then
local vector3=((vector and vector["create"]or Vector3["new"]))(distance["X"], distance["Y"], distance["Z"])fire:FireServer(gun, vector3)
end
end
end
end
end
end
end
else
readStateValue2(false)
end
else
readStateValue2(false)
end
end
)
else
readStateValue2(false)
end
task["wait"](.1)
end
readStateValue2(false)
end
)task["spawn"](function()
local timeValue4=0
while activeLoop do
task["wait"](.1)pcall(function()
local character2=localPlayer["Character"]
if character2 then
local progress2=getObjectValue(character2, "HookedProgress")
if progress2 and tonumber(progress2)then
local currentValue6=tonumber(progress2)
if currentValue6<=3 and currentValue6>0 then
if settings["RevolverAutofarm"]and(isFeatureAvailable()and(featureAvailability and featureAvailability["RevolverAutofarm"]))then
setRevolverAutofarm(false)showNotification("Revolver Autofarm", "Disabled revolver autofarm: HookedProgress reached <= 3.0", "info")
if tick()-timeValue4>3 then
timeValue4=tick()
if activeFarmThread then
pcall(activeFarmThread)
end
end
end
end
end
end
end
)
end
end
)task["spawn"](function()
local currentValue6="Idle"
local cachedValue6=nil
local part=nil
local cachedValue7=nil
local numericValue4=0
local items12={}
local items13={}
local items14={}
local items15={}
local function processValue5(value, contextValue)items15[value]=tick()+((contextValue or 25))
end
local function conditionMet8(value)
return items15[value]and tick()<items15[value]
end
local numericValue5=0
local timeValue4=0
local cachedValue8=nil
local function processValue6(instance)
local instance2=instance:FindFirstChild("ExitLever")
if instance2 then
local main=instance2:FindFirstChild("Main")
if main then
return main
end
end
for index, instance3 in ipairs(instance:GetDescendants())do
if instance3["Name"]=="Main"and instance3["Parent"]["Name"]:find("Lever")then
return instance3
end
end
return nil
end
local function getDistance2(instance)
if not instance then
return false
end
local part2=instance:FindFirstChild("LeftGate", true)
local part3=instance:FindFirstChild("LeftGate-end", true)
if part2 and(part3 and(part2:IsA("BasePart")and part3:IsA("BasePart")))then
local currentValue7=((part2["Position"]-part3["Position"]))["Magnitude"]
local transform=part2["CFrame"]["LookVector"]:Dot(part3["CFrame"]["LookVector"])
if currentValue7<2 and transform>.98 then
return true
end
end
local part4=instance:FindFirstChild("Box", true)
if part4 and(part4:IsA("BasePart")and not part4["CanCollide"])then
return true
end
for index, instance2 in ipairs(instance:GetChildren())do
if instance2:IsA("BasePart")and((instance2["Name"]=="Box"or instance2["Name"]=="Door"or instance2["Name"]=="Gate"or instance2["Name"]=="Bar"or instance2["Name"]=="ExitDoor"))then
if not instance2["CanCollide"]then
return true
end
end
end
if instance:GetAttribute("Opened")==true or instance:GetAttribute("Open")==true or instance:GetAttribute("Opened")=="true"or instance:GetAttribute("Open")=="true"then
return true
end
return false
end
local textValue=""
local numericValue6=0
local function findRootPart()
local cachedValue9=nil
local distance=math["huge"]
local character2=localPlayer["Character"]and localPlayer["Character"]:FindFirstChild("HumanoidRootPart")
if not character2 then
return nil
end
local items16={workspace}
local map=workspace:FindFirstChild("Map")
if map then
items16={map}
end
for index, item in ipairs(items16)do
for index2, instance in ipairs(item:GetDescendants())do
if instance:IsA("BasePart")and((instance["Name"]=="Fininshline"or instance["Name"]=="Finishline"or string["find"](instance["Name"]:lower(), "finishline")or string["find"](instance["Name"]:lower(), "fininshline")))then
local distance2=((instance["Position"]-character2["Position"]))["Magnitude"]
if distance2<distance then
distance=distance2 cachedValue9=instance
end
end
end
end
return cachedValue9
end
local function character2(position)
local character3=localPlayer["Character"]and localPlayer["Character"]:FindFirstChild("HumanoidRootPart")
if not character3 then
return nil
end
if#cachedGates==0 then
return findRootPart()
end
local items16={}
for index, instance in ipairs(cachedGates)do
if instance and(instance["Parent"]and getDistance2(instance))then
table["insert"](items16, instance)
end
end
if#items16==0 then
return nil
end
local items17={}
local items18={}
local items19={workspace}
local map=workspace:FindFirstChild("Map")
if map then
items19={map}
end
for index, item in ipairs(items19)do
for index2, instance in ipairs(item:GetDescendants())do
if instance:IsA("BasePart")and((instance["Name"]=="Fininshline"or instance["Name"]=="Finishline"or string["find"](instance["Name"]:lower(), "finishline")or string["find"](instance["Name"]:lower(), "fininshline")))then
table["insert"](items18, instance)
end
end
end
for index, item in ipairs(items18)do
for index2, instance in ipairs(items16)do
local child=instance:FindFirstChildWhichIsA("BasePart")or instance["PrimaryPart"]
if item:IsDescendantOf(instance)or item:IsDescendantOf(instance["Parent"])or(child and((item["Position"]-child["Position"]))["Magnitude"]<150)then
table["insert"](items17, {["finishLine"]=item, ["gate"]=instance})
break
end
end
end
if#items17==0 then
return findRootPart()
end
local cachedValue9=nil
local currentValue7=-math["huge"]
for index, item in ipairs(items17)do
local currentValue8=item["finishLine"]
local instance=item["gate"]
local child=instance:FindFirstChildWhichIsA("BasePart")or instance["PrimaryPart"]or currentValue8
local numericValue7=0
if position and child then
local distance=((child["Position"]-position))["Magnitude"]
if distance<60 then
numericValue7=numericValue7-10000
else
numericValue7=numericValue7+distance
end
end
local currentValue9=((currentValue8["Position"]-character3["Position"]))["Magnitude"]numericValue7=numericValue7-(currentValue9*.1)
if numericValue7>currentValue7 then
currentValue7=numericValue7 cachedValue9=currentValue8
end
end
return cachedValue9
end
local function findRootPart2(position)
if not position then
return false
end
local character3=localPlayer["Character"]and localPlayer["Character"]:FindFirstChild("HumanoidRootPart")
if not character3 then
return false
end
local currentValue7=PathfindingService:CreatePath({["AgentRadius"]=2, ["AgentHeight"]=5, ["AgentCanJump"]=true})
local success2, result=pcall(function()currentValue7:ComputeAsync(character3["Position"], position["Position"])
end
)
return success2 and currentValue7["Status"]==Enum["PathStatus"]["Success"]
end
local function character3()
local character4=localPlayer["Character"]and localPlayer["Character"]:FindFirstChild("HumanoidRootPart")
if not character4 then
return nil
end
local items16={}
local map=workspace:FindFirstChild("Map")
if map then
for index, instance in ipairs(map:GetDescendants())do
if instance:IsA("BasePart")and((instance["Name"]=="Fininshline"or instance["Name"]=="Finishline"or(instance["Name"]:lower()):find("finishline")or(instance["Name"]:lower()):find("fininshline")))then
table["insert"](items16, instance)
end
end
end
local cachedValue9=nil
local distance=math["huge"]
for index, item in ipairs(items16)do
local currentValue7=PathfindingService:CreatePath({["AgentRadius"]=2, ["AgentHeight"]=5, ["AgentCanJump"]=true})
local success2, result=pcall(function()currentValue7:ComputeAsync(character4["Position"], item["Position"])
end
)
if success2 and currentValue7["Status"]==Enum["PathStatus"]["Success"]then
local distance2=((item["Position"]-character4["Position"]))["Magnitude"]
if distance2<distance then
distance=distance2 cachedValue9=item
end
end
end
return cachedValue9
end
local function character4(position)
local character5=localPlayer["Character"]
local humanoid=character5 and character5:FindFirstChildOfClass("Humanoid")
local rootPart=character5 and character5:FindFirstChild("HumanoidRootPart")
if not humanoid or not rootPart then
return
end
local currentValue7=PathfindingService:CreatePath({["AgentRadius"]=2, ["AgentHeight"]=5;
["AgentCanJump"]=true;
["AgentJumpHeight"]=10;
["AgentMaxSlope"]=45})
local success2, result=pcall(function()currentValue7:ComputeAsync(rootPart["Position"], position)
end
)
if success2 and currentValue7["Status"]==Enum["PathStatus"]["Success"]then
local currentValue8=currentValue7:GetWaypoints()
for index, item in ipairs(currentValue8)do
if not settings["AutoFarmSurvivor"]or currentValue6~="Escaping"then
break
end
humanoid:MoveTo(item["Position"])
if item["Action"]==Enum["PathWaypointAction"]["Jump"]then
humanoid["Jump"]=true
end
local conditionMet9=false
local timestamp=tick()
local connection6 connection6=humanoid["MoveToFinished"]:Connect(function(value)conditionMet9=true
if connection6 then
connection6:Disconnect()
end
end
)
while not conditionMet9 and tick()-timestamp<1.2 do
task["wait"](.05)
end
if connection6 then
connection6:Disconnect()
end
end
else
humanoid:MoveTo(position)
end
end
local function processValue7()
for index, instance in ipairs(cachedGates)do
if instance and(instance["Parent"]and(processValue6(instance)and not getDistance2(instance)))then
return true
end
end
return false
end
local function processValue8(instance)
if not instance then
return false
end
local child=instance:FindFirstChildOfClass("ProximityPrompt")or instance["Parent"]:FindFirstChildOfClass("ProximityPrompt")
if not child then
pcall(function()
for index, instance2 in ipairs(instance["Parent"]:GetDescendants())do
if instance2:IsA("ProximityPrompt")then
child=instance2
break
end
end
end
)
end
if child then
return child["Enabled"]
end
local child2=instance:FindFirstChildOfClass("ClickDetector")or instance["Parent"]:FindFirstChildOfClass("ClickDetector")
if child2 then
return true
end
return nil
end
local function readStateValue2(instance)
if not instance then
return false
end
local instance2=processValue6(instance)
if instance2 then
local currentValue7=processValue8(instance2)
if currentValue7~=nil then
return currentValue7
end
end
if instance:GetAttribute("Powered")==true or instance:GetAttribute("Powered")=="true"then
return true
end
if instance2 and((instance2:GetAttribute("Powered")==true or instance2:GetAttribute("Powered")=="true"))then
return true
end
local count=#cachedGenerators
local numericValue7=0
for index, instance3 in ipairs(cachedGenerators)do
if instance3 and(instance3["Parent"]and isGeneratorCompleted(instance3))then
numericValue7=numericValue7+1
end
end
local currentValue7=count-numericValue7
if count==0 then
return false
end
local conditionMet9=(count>=7)and 2 or 1
return(currentValue7<=conditionMet9)
end
local function processValue9()
local numericValue7=0
local numericValue8=0
for index, player in ipairs(Players:GetPlayers())do
local teamName=player["Team"]
local teamName2=false
if teamName then
if teamName["Name"]=="Survivors"or teamName["Name"]~="Killer"and(teamName["Name"]~="Spectators"and teamName["Name"]~="Spectator")then
teamName2=true
end
else
local name2=player["Name"]:lower()
if not name2:find("killer")and not name2:find("spectator")then
teamName2=true
end
end
if teamName2 then
numericValue8=numericValue8+1
local instance=player["Character"]
if instance then
if instance:GetAttribute("vaultspeed")~=nil or instance:FindFirstChild("vaultspeed")~=nil then
numericValue7=numericValue7+1
end
end
end
end
local farmstate=tick()-((_G["VD_FarmState"]["lastSurvivorSpawnTime"]or 0))
local conditionMet9=false
if farmstate>25 then
conditionMet9=(numericValue7<=1)
else
conditionMet9=(numericValue8<=1)
end
if conditionMet9 then
return true
end
for index, instance in ipairs(cachedGates)do
if instance and(instance["Parent"]and readStateValue2(instance))then
return true
end
end
if#cachedGates==0 then
local count=#cachedGenerators
if count==0 then
return false
end
local numericValue9=0
for index, instance in ipairs(cachedGenerators)do
if instance and(instance["Parent"]and isGeneratorCompleted(instance))then
numericValue9=numericValue9+1
end
end
local currentValue7=count-numericValue9
local conditionMet10=(count>=7)and 2 or 1
return(currentValue7<=conditionMet10)
end
return false
end
local function processValue10(value)
local currentValue7, currentValue8=getNearestKillerInfo()
local currentValue9=character2(currentValue8)
if not currentValue9 then
return false
end
local numericValue7=0
local numericValue8=0
local conditionMet9=false
for index, instance in ipairs(cachedGates)do
if instance and(instance["Parent"]and processValue6(instance))then
numericValue8=numericValue8+1
if getDistance2(instance)then
numericValue7=numericValue7+1 conditionMet9=true
end
end
end
local conditionMet10=(numericValue8>0 and numericValue7>=numericValue8)
local numericValue9=0
for index, player in ipairs(Players:GetPlayers())do
local instance=player["Character"]
if instance then
if instance:GetAttribute("vaultspeed")~=nil or instance:FindFirstChild("vaultspeed")~=nil then
numericValue9=numericValue9+1
end
end
end
local conditionMet11=(numericValue9<=1)
local conditionMet12=conditionMet9 or conditionMet10 or(numericValue8==0)
return conditionMet12
end
local cachedValue9=nil
local cachedValue10=nil
local cachedValue11=nil
local cachedValue12=nil
local cachedValue13=nil
local cachedValue14=nil
local function processValue11()
local success2=game:GetService("ReplicatedStorage")pcall(function()
local remotes=success2:WaitForChild("Remotes", 2)
if remotes then
local generator=remotes:WaitForChild("Generator", 2)
if generator then
local repairevent=generator:WaitForChild("RepairEvent", 2)
if repairevent then
cachedValue9=repairevent
end
end
local carry=remotes:WaitForChild("Carry", 2)
if carry then
local unhookevent=carry:WaitForChild("UnHookEvent", 2)
if unhookevent then
cachedValue10=unhookevent
end
if not cachedValue10 then
for index, instance in ipairs(carry:GetDescendants())do
if string["find"](instance["Name"]:lower(), "unhook")or string["find"](instance["Name"]:lower(), "rescue")then
cachedValue10=instance
break
end
end
end
end
if not cachedValue10 then
for index, instance in ipairs(remotes:GetDescendants())do
if(instance:IsA("RemoteEvent")or instance:IsA("RemoteFunction"))then
local name2=instance["Name"]:lower()
if string["find"](name2, "unhook")or string["find"](name2, "rescue")then
cachedValue10=instance
break
end
end
end
end
local exit=remotes:WaitForChild("Exit", 2)
if exit then
local leverevent=exit:WaitForChild("LeverEvent", 2)
if leverevent then
cachedValue11=leverevent
end
end
end
end
)
end
local function conditionMet9(value)
return items12[value]and tick()<items12[value]
end
local function conditionMet10(value)
return items14[value]and tick()<items14[value]
end
local function processValue12(value, contextValue)items14[value]=tick()+((contextValue or 25))
end
local function findRootPart3()
local items16={}
for index, player in ipairs(Players:GetPlayers())do
if player==localPlayer then
continue
end
local teamName=player["Team"]
local isMatchingTeam=teamName and teamName["Name"]=="Killer"
local conditionMet11=teamName and teamName["Name"]=="Survivors"
if not teamName then
local name2=player["Name"]:lower()
if name2:find("killer")then
isMatchingTeam=true
elseif name2:find("survivor")then
conditionMet11=true
end
end
if isMatchingTeam and(not conditionMet11 and(player["Character"]and player["Character"]:FindFirstChild("HumanoidRootPart")))then
table["insert"](items16, player)
end
end
return items16
end
_G["VD_GetKillers"]=findRootPart3
local function findRootPart4()
local distance=math["huge"]
local startPosition4=nil
local character5=localPlayer["Character"]and localPlayer["Character"]:FindFirstChild("HumanoidRootPart")
if not character5 then
return distance, nil
end
local items16={}
if activeHumanoid then
pcall(function()items16=activeHumanoid()
end
)
end
if not items16 or#items16==0 then
items16={}
for index, player in ipairs(findRootPart3())do
if player["Character"]then
table["insert"](items16, player["Character"])
end
end
end
for index, instance in ipairs(items16)do
if instance and instance["Parent"]then
local rootPart=instance:FindFirstChild("HumanoidRootPart")
if rootPart then
local distance2=((rootPart["Position"]-character5["Position"]))["Magnitude"]
if distance2<distance then
distance=distance2 startPosition4=rootPart["Position"]
end
end
end
end
return distance, startPosition4
end
local function findRootPart5(position)
if not position then
return false
end
for index, player in ipairs(Players:GetPlayers())do
if player~=localPlayer and(player["Character"]and player["Character"]:FindFirstChild("HumanoidRootPart"))then
local distance=((player["Character"]["HumanoidRootPart"]["Position"]-position["Position"]))["Magnitude"]
if distance<4 then
return true
end
end
end
return false
end
local function processValue13(instance)
return instance and(instance:IsA("BasePart")and string["find"](instance["Name"]:lower(), "generatorpoint")~=nil)
end
local function processValue14(instance)
local cachedValue15=nil
for index, instance2 in ipairs(instance:GetChildren())do
if string["find"](instance2["Name"]:lower(), "generatorpoint")then
if not findRootPart5(instance2)then
return instance2
else
cachedValue15=instance2
end
end
end
if cachedValue15 then
return nil
end
local child=instance:FindFirstChildWhichIsA("BasePart")
if child then
if not findRootPart5(child)then
return child
end
end
if instance:IsA("Model")and instance["PrimaryPart"]then
if not findRootPart5(instance["PrimaryPart"])then
return instance["PrimaryPart"]
end
end
return nil
end
local function getDistance3(instance)
if instance:IsA("Model")then
return instance["PrimaryPart"]or instance:FindFirstChildWhichIsA("BasePart")
end
return instance:FindFirstChildWhichIsA("BasePart")
end
local function getDistance4(value, position)
local currentValue7=getDistance3(value)
if currentValue7 then
return((currentValue7["Position"]-position))["Magnitude"]
end
return math["huge"]
end
local function processValue15(position, contextValue)
local map=workspace:FindFirstChild("Map")
if not map then
return false
end
for index, instance in ipairs(map:GetChildren())do
if instance:IsA("Folder")or instance:IsA("Model")then
for index2, instance2 in ipairs(instance:GetChildren())do
if instance2:IsA("Model")and(((instance2["Name"]:lower()):find("^scp")or(instance2["Name"]:lower()):match("^scp%d+$")))then
local child=instance2["PrimaryPart"]or instance2:FindFirstChildWhichIsA("BasePart")
if child then
local distance=((child["Position"]-position))["Magnitude"]
if distance<=contextValue then
return true, instance2
end
end
end
end
end
if instance:IsA("Model")and(((instance["Name"]:lower()):find("^scp")or(instance["Name"]:lower()):match("^scp%d+$")))then
local child=instance["PrimaryPart"]or instance:FindFirstChildWhichIsA("BasePart")
if child then
local distance=((child["Position"]-position))["Magnitude"]
if distance<=contextValue then
return true, instance
end
end
end
end
return false, nil
end
local function getDistance5(value, position, contextValue)
local currentValue7=getDistance3(value)
if not currentValue7 then
return-999999
end
local numericValue7=9999
if position then
numericValue7=((currentValue7["Position"]-position))["Magnitude"]
if numericValue7<45 then
return-999999
end
end
local currentValue8, currentValue9=processValue15(currentValue7["Position"], 15)
if currentValue8 then
return-999999
end
local progress2=getGeneratorProgress(value)
local progress3=(progress2*15)+(numericValue7*2)
if cachedValue6==value then
progress3=progress3+1000
end
if cachedValue7==value then
progress3=progress3+500
end
return progress3
end
local function character5(value)
local character6=localPlayer["Character"]and localPlayer["Character"]:FindFirstChild("HumanoidRootPart")
local rootPart=character6 and character6["Position"]
local startPosition4=nil
local currentValue7=-math["huge"]
for index, instance in ipairs(cachedGenerators)do
if not instance or not instance["Parent"]then
continue
end
if isGeneratorCompleted(instance)then
continue
end
if isGeneratorPaused(instance)then
continue
end
if conditionMet10(instance)then
continue
end
local currentValue8=processValue14(instance)
if not currentValue8 then
continue
end
local currentValue9=getDistance5(instance, value, rootPart)
if currentValue9>currentValue7 then
currentValue7=currentValue9 startPosition4=instance
end
end
return startPosition4
end
local function processValue16()
local items16={}
local currentValue7=os["clock"]()
for index, player in ipairs(Players:GetPlayers())do
if player==localPlayer then
continue
end
local progress2=player["Character"]
if progress2 then
local progress3=getObjectValue(progress2, "HookedProgress")
local isHooked=false
if progress3 and tonumber(progress3)then
local currentValue8=tonumber(progress3)
local currentValue9=items13[player]
if not currentValue9 then
items13[player]={["lastVal"]=currentValue8, ["lastChangeTime"]=0}
else
if currentValue9["lastVal"]~=currentValue8 then
currentValue9["lastVal"]=currentValue8 currentValue9["lastChangeTime"]=currentValue7
end
if currentValue7-currentValue9["lastChangeTime"]<3 then
isHooked=true
end
end
else
items13[player]=nil
end
if isHooked then
table["insert"](items16, player)
end
end
end
return items16
end
local function findRootPart6(player)
local instance=player["Character"]
if not instance then
return nil
end
local rootPart=instance:FindFirstChild("HumanoidRootPart")
if not rootPart then
return nil
end
local cachedValue15=nil
local distance=math["huge"]
for index, instance2 in ipairs(cachedHooks or{})do
if instance2 and instance2["Parent"]then
local distance2=((instance2["Position"]-rootPart["Position"]))["Magnitude"]
if distance2<distance then
distance=distance2 cachedValue15=instance2
end
end
end
return distance<12 and cachedValue15 or nil
end
local function processValue17(position)
local currentValue7=os["clock"]()
for index, player in ipairs(Players:GetPlayers())do
if player==localPlayer then
continue
end
if conditionMet9(player)then
continue
end
local instance=player["Character"]
if instance then
local conditionMet11=false
local cachedValue15=nil
local isHooked=getObjectValue(instance, "IsHooked")
if isHooked~=nil then
if isHooked==true then
conditionMet11=true cachedValue15=findRootPart6(player)
end
else
local progress2=getObjectValue(instance, "HookedProgress")
if progress2 and tonumber(progress2)then
local currentValue8=tonumber(progress2)
local currentValue9=items13[player]
if not currentValue9 then
items13[player]={["initialVal"]=currentValue8, ["lastVal"]=currentValue8, ["lastChangeTime"]=currentValue7;
["firstSeenTime"]=currentValue7, ["decreaseCount"]=0}
else
if currentValue9["lastVal"]~=currentValue8 then
if currentValue8<currentValue9["lastVal"]then
currentValue9["decreaseCount"]=currentValue9["decreaseCount"]+1
else
currentValue9["decreaseCount"]=0 currentValue9["initialVal"]=currentValue8 currentValue9["firstSeenTime"]=currentValue7
end
currentValue9["lastVal"]=currentValue8 currentValue9["lastChangeTime"]=currentValue7
end
if currentValue7-currentValue9["firstSeenTime"]>=1 and(currentValue9["decreaseCount"]>=2 and currentValue8<currentValue9["initialVal"])then
if currentValue7-currentValue9["lastChangeTime"]<3 and(currentValue8>0 and currentValue8<100)then
cachedValue15=findRootPart6(player)
if cachedValue15 then
conditionMet11=true
end
end
end
end
else
items13[player]=nil
end
end
if conditionMet11 and cachedValue15 then
local rootPart=instance:FindFirstChild("HumanoidRootPart")
if rootPart and((not position or((rootPart["Position"]-position))["Magnitude"]>75))then
return cachedValue15, cachedValue15, player
end
end
end
end
return nil, nil, nil
end
local function invokeRemote()
if cachedValue9 then
if part then
pcall(function()cachedValue9:FireServer(part, false)
end
)
end
if cachedValue12 and cachedValue12~=part then
pcall(function()cachedValue9:FireServer(cachedValue12, false)
end
)
end
end
isRepairingRemoteActive=false cachedValue12=nil
end
local function invokeRemote2()
if cachedValue11 then
if part then
pcall(function()cachedValue11:FireServer(part, false)
end
)
end
if cachedValue13 and cachedValue13~=part then
pcall(function()cachedValue11:FireServer(cachedValue13, false)
end
)
end
end
isGateRemoteActive=false cachedValue13=nil
end
local function findRootPart7()invokeRemote()invokeRemote2()part=nil cachedValue6=nil
end
_G["VD_StopAllInteractions"]=findRootPart7 _G["VD_TriggerDodgeChangeGen"]=function()
if currentValue6=="Repairing"and cachedValue6 then
processValue12(cachedValue6, 45)invokeRemote()
local currentValue7, currentValue8=findRootPart4()
local currentValue9=character5(currentValue8)
if currentValue9 then
local part2=processValue14(currentValue9)
if part2 then
local character6=localPlayer["Character"]and localPlayer["Character"]:FindFirstChild("HumanoidRootPart")
if character6 then
character6["CFrame"]=part2["CFrame"]+Vector3["new"](0, 1.5, 0)cachedValue6=currentValue9 part=part2 currentValue6="Repairing"updateStatus("REPAIRING")
if cachedValue9 then
pcall(function()cachedValue9:FireServer(part2, true)
end
)isRepairingRemoteActive=true cachedValue12=part2
end
return true
end
end
end
local conditionMet11=nil pcall(function()
if cachedGates and#cachedGates>0 then
local currentValue10=cachedGates[1]
local part2=processValue6(currentValue10)
if part2 then
conditionMet11=part2["CFrame"]
end
end
if not conditionMet11 and character2 then
conditionMet11=character2()
end
end
)
local character6=localPlayer["Character"]and localPlayer["Character"]:FindFirstChild("HumanoidRootPart")
if character6 and conditionMet11 then
character6["CFrame"]=conditionMet11+Vector3["new"](0, 1.5, 0)
end
cachedValue6=nil part=nil currentValue6="Idle"updateStatus("IDLE")
return false
end
return false
end
local function character6(position)
local character7=localPlayer["Character"]and localPlayer["Character"]:FindFirstChild("HumanoidRootPart")
if not character7 then
return
end
local currentValue7=isRepairingRemoteActive or isGateRemoteActive
if currentValue7 then
invokeRemote()invokeRemote2()task["wait"](.15)
end
lastPreTeleportCFrame=character7["CFrame"]character7["CFrame"]=position
end
local function findRootPart8(value)_G["VD_CurrentFarmState"]=value
if _G["VD_UpdateFarmStatus"]then
pcall(function()_G["VD_UpdateFarmStatus"](value)
end
)
end
end
while activeLoop do
task["wait"](.2)
if _G["VD_DodgeActive"]then
continue
end
if currentValue6~="Repairing"then
timeValue4=0 cachedValue8=nil
end
if not isSurvivorFarmAllowed()then
if currentValue6~="Idle"or isRepairingRemoteActive or isGateRemoteActive then
findRootPart7()currentValue6="Idle"
end
continue
end
if not cachedValue9 or not cachedValue10 or not cachedValue11 then
processValue11()
end
local character7=localPlayer["Character"]and localPlayer["Character"]:FindFirstChild("HumanoidRootPart")
if not character7 then
findRootPart7()currentValue6="Idle"findRootPart8("IDLE")
continue
end
local currentValue7, distance=findRootPart4()
if settings["AutoFleeKiller"]and(currentValue7<35 and distance)then
local cachedValue15=nil
local distance2=-1
for index, instance in ipairs(cachedGenerators)do
if instance and(instance["Parent"]and(not isGeneratorCompleted(instance)and not isGeneratorPaused(instance)))then
local currentValue8=getDistance3(instance)
if currentValue8 then
local distance3=((currentValue8["Position"]-distance))["Magnitude"]
if distance3>distance2 then
local currentValue9=processValue14(instance)
if currentValue9 then
distance2=distance3 cachedValue15=instance
end
end
end
end
end
if cachedValue15 then
local part2=processValue14(cachedValue15)
if part2 then
showNotification("Auto Flee", "Killer too close! Teleported to furthest generator.", "warning")findRootPart7()character6(part2["CFrame"]+Vector3["new"](0, 1.5, 0))cachedValue6=cachedValue15 part=part2 currentValue6="Repairing"findRootPart8("REPAIRING")
if not cachedValue9 then
processValue11()
end
if cachedValue9 then
pcall(function()cachedValue9:FireServer(part2, true)
end
)isRepairingRemoteActive=true cachedValue12=part2
end
continue
end
end
end
if currentValue6=="Repairing"and cachedValue6 then
local conditionMet11=false
if distance then
local currentValue8=getDistance4(cachedValue6, distance)
if currentValue8<60 then
conditionMet11=true
end
end
if not conditionMet11 then
local currentValue8=getDistance3(cachedValue6)
if currentValue8 then
local currentValue9, currentValue10=processValue15(currentValue8["Position"], 15)
if currentValue9 then
conditionMet11=true
end
end
end
if conditionMet11 then
processValue12(cachedValue6, 25)cachedValue7=cachedValue6 invokeRemote()task["wait"](.1)cachedValue6=nil part=nil currentValue6="Idle"findRootPart8("IDLE")
continue
end
end
if currentValue6=="OpeningGate"and currentValue7<40 then
invokeRemote2()task["wait"](.1)
local cachedValue15=nil
local distance2=-1
if distance then
for index, instance in ipairs(cachedGates)do
if instance and(instance["Parent"]and(processValue6(instance)and not getDistance2(instance)))then
local child=instance:FindFirstChildWhichIsA("BasePart")or instance["PrimaryPart"]
if child and distance then
local distance3=((child["Position"]-distance))["Magnitude"]
if distance3>distance2 then
distance2=distance3 cachedValue15=instance
end
end
end
end
end
if cachedValue15 and cachedValue15~=cachedValue6 then
local part2=processValue6(cachedValue15)
if part2 then
if not cachedValue11 then
processValue11()
end
if cachedValue11 then
cachedValue14=cachedValue6 currentValue6="OpeningGate"cachedValue6=cachedValue15 part=part2 character6(part2["CFrame"]+Vector3["new"](0, 2, 0))task["wait"](.2)pcall(function()cachedValue11:FireServer(part2, true)
end
)isGateRemoteActive=true cachedValue13=part2 findRootPart8("OPENINGGATE")
continue
end
end
end
cachedValue6=nil part=nil currentValue6="Idle"findRootPart8("IDLE")
continue
end
if currentValue6=="Idle"then
local currentValue8=character2(distance)
if currentValue8 then
local numericValue7=0
local numericValue8=0
local conditionMet11=false
for index, instance in ipairs(cachedGates)do
if instance and(instance["Parent"]and processValue6(instance))then
numericValue8=numericValue8+1
if getDistance2(instance)then
numericValue7=numericValue7+1 conditionMet11=true
end
end
end
local conditionMet12=(numericValue8>0 and numericValue7>=numericValue8)
local numericValue9=0
for index, player in ipairs(Players:GetPlayers())do
local instance=player["Character"]
if instance then
if instance:GetAttribute("vaultspeed")~=nil or instance:FindFirstChild("vaultspeed")~=nil then
numericValue9=numericValue9+1
end
end
end
local conditionMet13=(numericValue9<=1)
local conditionMet14=conditionMet11 or conditionMet12 or(numericValue8==0)
if conditionMet14 then
local currentValue9, currentValue10, currentValue11=processValue17(distance)
if currentValue9 and currentValue10 then
else
findRootPart7()currentValue6="Escaping"cachedValue6=currentValue8 part=currentValue8 findRootPart8("ESCAPING")
continue
end
end
end
local currentValue9, part2, player=processValue17(distance)
if currentValue9 and part2 then
if not cachedValue10 then
processValue11()
end
findRootPart7()currentValue6="Rescuing"cachedValue6=player part=part2 findRootPart8("RESCUING")
local timestamp=tick()
local conditionMet11=false
while tick()-timestamp<2.5 and activeLoop do
character6(part2["CFrame"]+Vector3["new"](0, 2, 0))
if cachedValue10 then
local name2=part2
if name2["Name"]~="HookPoint"then
local hookpoint=name2["Parent"]and name2["Parent"]:FindFirstChild("HookPoint")
if hookpoint then
name2=hookpoint
else
pcall(function()
for index, instance in ipairs(name2["Parent"]:GetDescendants())do
if instance["Name"]=="HookPoint"then
name2=instance
break
end
end
end
)
end
end
pcall(function()cachedValue10:FireServer(name2)
end
)
end
pcall(function()
local currentValue10=part2["Parent"]
local child=part2:FindFirstChildOfClass("ProximityPrompt")
if not child and currentValue10 then
for index, instance in ipairs(currentValue10:GetDescendants())do
if instance:IsA("ProximityPrompt")then
child=instance
break
end
end
end
if child then
if fireproximityprompt then
fireproximityprompt(child)
end
end
end
)task["wait"](.25)
local isHooked=player["Character"]and((getObjectValue(player["Character"], "IsHooked")==true or player["Character"]:GetAttribute("IsHooked")==true))
if not isHooked then
local progress2=getObjectValue(player["Character"], "HookedProgress")
if not progress2 or tonumber(progress2)==0 then
conditionMet11=true
break
end
end
local currentValue10, currentValue11=findRootPart4()
if currentValue10<50 then
break
end
end
if conditionMet11 then
else
items12[player]=tick()+15
end
findRootPart7()currentValue6="Idle"findRootPart8("IDLE")
continue
end
local currentValue10=processValue9()
if currentValue10 then
local currentValue11, distance2=nil, math["huge"]
for index, instance in ipairs(cachedGates)do
if instance and(instance["Parent"]and(processValue6(instance)and(not getDistance2(instance)and not conditionMet8(instance))))then
local child=instance:FindFirstChildWhichIsA("BasePart")or instance["PrimaryPart"]
if child then
local distance3=((child["Position"]-character7["Position"]))["Magnitude"]
if distance3<distance2 then
distance2=distance3 currentValue11=instance
end
end
end
end
if not currentValue11 then
distance2=math["huge"]
for index, instance in ipairs(cachedGates)do
if instance and(instance["Parent"]and(processValue6(instance)and not getDistance2(instance)))then
local child=instance:FindFirstChildWhichIsA("BasePart")or instance["PrimaryPart"]
if child then
local distance3=((child["Position"]-character7["Position"]))["Magnitude"]
if distance3<distance2 then
distance2=distance3 currentValue11=instance
end
end
end
end
end
if currentValue11 then
local part3=processValue6(currentValue11)
if part3 then
if not cachedValue11 then
processValue11()
end
if cachedValue11 then
findRootPart7()currentValue6="OpeningGate"cachedValue6=currentValue11 part=part3 character6(part3["CFrame"]+Vector3["new"](0, 2, 0))task["wait"](.2)pcall(function()cachedValue11:FireServer(part3, true)
end
)isGateRemoteActive=true cachedValue13=part3 findRootPart8("OPENINGGATE")
continue
end
end
end
end
if not currentValue10 then
local currentValue11=character5(distance)
if currentValue11 then
if not cachedValue9 then
processValue11()
end
if cachedValue9 then
local part3=processValue14(currentValue11)
if part3 then
character6(part3["CFrame"]+Vector3["new"](0, 1.5, 0))currentValue6="Repairing"cachedValue6=currentValue11 part=part3
if cachedValue7==currentValue11 then
cachedValue7=nil
end
settings["AutoSkillCheck"]=true
if processValue13(part3)then
pcall(function()cachedValue9:FireServer(part3, true)
end
)isRepairingRemoteActive=true cachedValue12=part3
else
isRepairingRemoteActive=false
end
findRootPart8("REPAIRING")
else
findRootPart8("IDLE")task["wait"](.5)
end
end
else
findRootPart8("IDLE")task["wait"](1)
end
else
findRootPart8("IDLE")task["wait"](.5)
end
continue
end
if currentValue6=="Repairing"then
if not cachedValue6 or not cachedValue6["Parent"]or isGeneratorCompleted(cachedValue6)or isGeneratorPaused(cachedValue6)then
invokeRemote()task["wait"](.1)cachedValue6=nil part=nil currentValue6="Idle"findRootPart8("IDLE")
continue
end
if timeValue4==0 then
timeValue4=tick()
local character8=localPlayer["Character"]cachedValue8=character8 and character8:GetAttribute("repairing")or nil
elseif tick()-timeValue4>=5 then
local character8=localPlayer["Character"]
local repairing=character8 and character8:GetAttribute("repairing")
local conditionMet11=false
if repairing and repairing~=0 then
if not cachedValue8 or repairing~=cachedValue8 then
conditionMet11=true
end
end
if not conditionMet11 then
invokeRemote()task["wait"](.1)cachedValue6=nil part=nil currentValue6="Idle"findRootPart8("IDLE")timeValue4=0 cachedValue8=nil
continue
else
timeValue4=tick()cachedValue8=repairing
end
end
local currentValue8, currentValue9, currentValue10=processValue17(distance)
if currentValue8 and currentValue9 then
invokeRemote()task["wait"](.1)cachedValue6=nil part=nil currentValue6="Idle"findRootPart8("IDLE")
continue
end
local currentValue11=processValue9()
if currentValue11 and((processValue7()or processValue10(currentValue7)))then
invokeRemote()task["wait"](.1)cachedValue6=nil part=nil currentValue6="Idle"findRootPart8("IDLE")
continue
end
if not processValue13(part)then
local currentValue12=processValue14(cachedValue6)
if processValue13(currentValue12)then
part=currentValue12 isRepairingRemoteActive=false
end
end
local distance2=((character7["Position"]-part["Position"]))["Magnitude"]
if distance2>10 then
character6(part["CFrame"]+Vector3["new"](0, 1.5, 0))task["wait"](.2)distance2=((character7["Position"]-part["Position"]))["Magnitude"]
end
if not cachedValue9 then
processValue11()
end
if cachedValue9 then
if distance2<=10 then
pcall(function()cachedValue9:FireServer(part, true)
end
)isRepairingRemoteActive=true cachedValue12=part
else
if isRepairingRemoteActive then
invokeRemote()
end
end
end
end
if currentValue6=="Escaping"then
local part2=character2(distance)
if part2 then
cachedValue6=part2 part=part2 findRootPart8("ESCAPING")character6(part2["CFrame"])task["wait"](1)
if not settings["AutoFarmAFK"]then
settings["AutoFarmSurvivor"]=false
if _G["VD_SetFarmToggle"]then
pcall(function()_G["VD_SetFarmToggle"](false)
end
)
end
findRootPart7()currentValue6="Idle"findRootPart8("OFF")
else
findRootPart7()currentValue6="Idle"findRootPart8("ESCAPED")
while activeLoop and(localPlayer["Team"]and localPlayer["Team"]["Name"]=="Survivors")do
findRootPart8("ESCAPED")task["wait"](.5)
end
end
showNotification("Escape Triggered", "Teleported to finish line successfully!", "success")
else
local part3=nil
for index, instance in ipairs(cachedGates)do
if instance and(instance["Parent"]and getDistance2(instance))then
part3=instance:FindFirstChildWhichIsA("BasePart")or instance["PrimaryPart"]
if part3 then
break
end
end
end
if part3 then
character6(part3["CFrame"]+Vector3["new"](0, 5, 0))task["wait"](1)
if not settings["AutoFarmAFK"]then
settings["AutoFarmSurvivor"]=false
if _G["VD_SetFarmToggle"]then
pcall(function()_G["VD_SetFarmToggle"](false)
end
)
end
findRootPart7()currentValue6="Idle"findRootPart8("OFF")
else
findRootPart7()currentValue6="Idle"findRootPart8("ESCAPED")
while activeLoop and(localPlayer["Team"]and localPlayer["Team"]["Name"]=="Survivors")do
findRootPart8("ESCAPED")task["wait"](.5)
end
end
showNotification("Escape Triggered", "Teleported to gate fallback successfully!", "success")
else
currentValue6="Idle"findRootPart8("IDLE")
end
end
continue
end
if currentValue6=="OpeningGate"then
if not cachedValue6 or not cachedValue6["Parent"]or getDistance2(cachedValue6)then
invokeRemote2()
if cachedValue6 then
items15[cachedValue6]=nil
end
cachedValue6=nil part=nil currentValue6="Idle"findRootPart8("IDLE")
continue
end
local distance2=((character7["Position"]-part["Position"]))["Magnitude"]
if distance2>10 then
character6(part["CFrame"]+Vector3["new"](0, 1.5, 0))task["wait"](.2)distance2=((character7["Position"]-part["Position"]))["Magnitude"]
end
if not cachedValue11 then
processValue11()
end
if cachedValue11 then
if distance2<=10 then
pcall(function()cachedValue11:FireServer(part, true)
end
)isGateRemoteActive=true cachedValue13=part
else
if isGateRemoteActive then
invokeRemote2()
end
end
end
end
end
end
)task["spawn"](function()
local timeValue4=0
local timeValue5=0
while activeLoop do
task["wait"](.25)
if settings["AutoFleeKiller"] and not settings["AutoFarmSurvivor"] then
local success2, result=pcall(function()
local character2=localPlayer["Character"]
local rootPart=character2 and character2:FindFirstChild("HumanoidRootPart")
if not rootPart then
return
end
local isKnocked=character2:GetAttribute("Knocked")==true or localPlayer:GetAttribute("Knocked")==true
if not isKnocked and getObjectValue then
isKnocked=getObjectValue(character2, "Knocked")==true
end
local isHooked=character2:GetAttribute("IsHooked")==true or localPlayer:GetAttribute("IsHooked")==true
if not isHooked and getObjectValue then
isHooked=getObjectValue(character2, "IsHooked")==true
end
if isKnocked or isHooked then
return
end
local distance=rootPart["Position"]
local distance2=math["huge"]
local startPosition4=nil
for index, player in ipairs((game:GetService("Players")):GetPlayers())do
if player==localPlayer then
continue
end
local name2=player["Team"]
if name2 and(name2["Name"]=="Killer"and player["Character"])then
local rootPart2=player["Character"]:FindFirstChild("HumanoidRootPart")
if rootPart2 then
local distance3=((rootPart2["Position"]-distance))["Magnitude"]
if distance3<distance2 then
distance2=distance3 startPosition4=rootPart2["Position"]
end
end
end
end
if tick()-timeValue5>1.5 then
timeValue5=tick()
local count=cachedGenerators and#cachedGenerators or 0
end
if tick()-timeValue4<3 then
return
end
if distance2<35 and startPosition4 then
local instance=nil
local distance3=-1
if cachedGenerators then
for index, instance2 in ipairs(cachedGenerators)do
if instance2 and instance2["Parent"]then
local conditionMet8=false
local conditionMet9=false
if isGeneratorCompleted then
local success3, result2=pcall(isGeneratorCompleted, instance2)
if success3 then
conditionMet8=result2
end
end
if isGeneratorPaused then
local success3, result2=pcall(isGeneratorPaused, instance2)
if success3 then
conditionMet9=result2
end
end
if not conditionMet8 and not conditionMet9 then
local startPosition5=nil
if instance2:IsA("Model")then
startPosition5=instance2["PrimaryPart"]or instance2:FindFirstChildWhichIsA("BasePart")
else
startPosition5=instance2:FindFirstChildWhichIsA("BasePart")
end
if startPosition5 then
local distance4=((startPosition5["Position"]-startPosition4))["Magnitude"]
if distance4>distance3 then
distance3=distance4 instance=instance2
end
end
end
end
end
end
if instance then
local part=nil
for index, instance2 in ipairs(instance:GetChildren())do
if string["find"](instance2["Name"]:lower(), "generatorpoint")then
part=instance2
break
end
end
if not part then
if instance:IsA("Model")then
part=instance["PrimaryPart"]or instance:FindFirstChildWhichIsA("BasePart")
else
part=instance:FindFirstChildWhichIsA("BasePart")
end
end
if part then
showNotification("Auto Flee", "Killer too close! Teleporting to furthest generator.", "warning")
local vector2=part["CFrame"]+Vector3["new"](0, 1.5, 0)
if safeTeleport then
safeTeleport(vector2)
else
rootPart["CFrame"]=vector2
end
timeValue4=tick()
end
else
end
end
end
)
if not success2 then
warn("[Auto Flee Killer Loop Error] "..tostring(result))
end
end
end
end
)function queueTeleportScript() end
function getTimerSeconds()
local instance=(game:GetService("Players"))["LocalPlayer"]
local instance2=instance and instance:FindFirstChild("PlayerGui")
local instance3=instance2 and instance2:FindFirstChild("Spectator")
local instance4=instance3 and instance3:FindFirstChild("time")
local label4=instance4 and instance4:FindFirstChild("TimerLabel")
if label4 and label4:IsA("TextLabel")then
local text=label4["Text"]
if text then
if string["find"](text:lower(), "not enough players")then
return-1, text
end
local currentValue6, currentValue7=string["match"](text, "(%d+):(%d+)")
if currentValue6 and currentValue7 then
return tonumber(currentValue6)*60+tonumber(currentValue7), text
end
end
end
return nil, nil
end
function serverHop()pcall(queueTeleportScript)
local currentValue6=game:GetService("TeleportService")
local player=game:GetService("Players")
local player2=game:GetService("HttpService")
local player3=game["PlaceId"]
local currentValue7=game["JobId"]
local currentValue8="https://games.roblox.com/v1/games/"..(tostring(player3).."/servers/Public?sortOrder=Asc&limit=100")
local currentValue9="https://games.roproxy.com/v1/games/"..(tostring(player3).."/servers/Public?sortOrder=Asc&limit=100")
local currentValue10=(syn and syn["request"])or(http and http["request"])or http_request or(fluxus and fluxus["request"])or request
local currentValue11, currentValue12=false, nil
if currentValue10 then
local success2, responseBody=pcall(function()
return currentValue10({["Url"]=currentValue8, ["Method"]="GET";
["Headers"]={["User-Agent"]="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36";
["Accept"]="application/json"}})
end
)
if success2 and(responseBody and(responseBody["Body"]and not string["find"](responseBody["Body"], "<!DOCTYPE html>")))then
currentValue11=true currentValue12=responseBody["Body"]
else
end
end
if not currentValue11 then
local success2, result=pcall(function()
return game:HttpGet(currentValue8)
end
)
if success2 and(result and not string["find"](result, "<!DOCTYPE html>"))then
currentValue11=true currentValue12=result
else
end
end
if not currentValue11 and currentValue10 then
local success2, responseBody=pcall(function()
return currentValue10({["Url"]=currentValue9, ["Method"]="GET";
["Headers"]={["User-Agent"]="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36";
["Accept"]="application/json"}})
end
)
if success2 and(responseBody and(responseBody["Body"]and not string["find"](responseBody["Body"], "<!DOCTYPE html>")))then
currentValue11=true currentValue12=responseBody["Body"]
else
end
end
if not currentValue11 then
local success2, result=pcall(function()
return game:HttpGet(currentValue9)
end
)
if success2 and(result and not string["find"](result, "<!DOCTYPE html>"))then
currentValue11=true currentValue12=result
else
end
end
if currentValue11 and currentValue12 then
local success2=nil pcall(function()success2=player2:JSONDecode(currentValue12)
end
)
if success2 and success2["data"]then
local currentValue13=success2["data"]
if#currentValue13>0 then
local currentValue14=currentValue13[1]
local success3="N/A"pcall(function()success3=player2:JSONEncode(currentValue14)
end
)
end
local items12={}
for index, item in ipairs(currentValue13)do
local conditionMet8=(tostring(item["id"])==tostring(currentValue7))
if item["playing"]and(item["maxPlayers"]and not conditionMet8)then
if item["playing"]>=3 and item["playing"]<item["maxPlayers"]then
table["insert"](items12, item)
end
end
end
if#items12==0 then
for index, item in ipairs(currentValue13)do
local conditionMet8=(tostring(item["id"])==tostring(currentValue7))
if item["playing"]and(item["playing"]<item["maxPlayers"]and not conditionMet8)then
table["insert"](items12, item)
end
end
end
if#items12>0 then
table["sort"](items12, function(value, contextValue)
return((value["playing"]or 0))>((contextValue["playing"]or 0))
end
)
local count=math["min"](5, #items12)
local player4=items12[math["random"](1, count)]
if player4 and player4["id"]then
local success3=pcall(function()currentValue6:TeleportToPlaceInstance(player3, player4["id"], player["LocalPlayer"])
end
)
if success3 then
return
end
end
end
else
if not success2 then
else
end
end
else
end
pcall(function()currentValue6:Teleport(player3, player["LocalPlayer"])
end
)
end
task["spawn"](function()
local conditionMet8=false
local timestamp=tick()
local function getFeatureState3(value)_G["VD_CurrentFarmState"]=value
if _G["VD_UpdateFarmStatus"]then
pcall(function()_G["VD_UpdateFarmStatus"](value)
end
)
end
end
local function getFeatureState4(value, callback)
if value==-1 or(callback and string["find"](callback:lower(), "not enough players"))then
local conditionMet9=true
for key=1, 5, 1 do
if not settings["AutoServerHopEscape"]or conditionMet8 then
break
end
getFeatureState3("WAITING (Lobby "..(((5-key)+1).."s)"))task["wait"](1)
local currentValue6, currentValue7=getTimerSeconds()
if not((currentValue6==-1 or(currentValue7 and string["find"](currentValue7:lower(), "not enough players"))))then
conditionMet9=false
break
end
end
if conditionMet9 and(settings["AutoServerHopEscape"]and not conditionMet8)then
return true
end
end
return false
end
while activeLoop do
task["wait"](1)
if settings["AutoServerHopEscape"]then
local timestamp2=tick()-timestamp
if timestamp2<5 then
local label4=screenGui:FindFirstChild("VD_StopHopButton")
if not label4 then
label4=Instance["new"]("TextButton")label4["Name"]="VD_StopHopButton"label4["Size"]=UDim2["new"](0, 200, 0, 40)label4["Position"]=UDim2["new"](.5, -100, .15, 0)label4["BackgroundColor3"]=Color3["fromRGB"](15, 15, 15)label4["BackgroundTransparency"]=.8 label4["Text"]="STOP AUTO HOP"label4["TextColor3"]=Color3["fromRGB"](255, 60, 60)label4["Font"]=Enum["Font"]["GothamBold"]label4["TextSize"]=16 label4["TextStrokeTransparency"]=0 label4["TextStrokeColor3"]=Color3["fromRGB"](0, 0, 0)label4["AutoButtonColor"]=false label4["Active"]=true label4["ZIndex"]=9999
local corner2=Instance["new"]("UICorner", label4)corner2["CornerRadius"]=UDim["new"](0, 8)
local stroke3=Instance["new"]("UIStroke", label4)stroke3["Color"]=Color3["fromRGB"](255, 60, 60)stroke3["Thickness"]=1.5 stroke3["ApplyStrokeMode"]=Enum["ApplyStrokeMode"]["Border"]label4["MouseEnter"]:Connect(function()label4["BackgroundTransparency"]=.5 stroke3["Color"]=Color3["fromRGB"](255, 100, 100)
end
)label4["MouseLeave"]:Connect(function()label4["BackgroundTransparency"]=.8 stroke3["Color"]=Color3["fromRGB"](255, 60, 60)
end
)label4["Parent"]=screenGui label4["MouseButton1Click"]:Connect(function()settings["AutoServerHopEscape"]=false accentgreenColor(false)pcall(saveSettings)getFeatureState3("OFF")showNotification("Auto Hop Disabled", "Server Hop Escape has been disabled.", "info")label4:Destroy()
end
)
end
local currentValue6=game:GetService("UserInputService")
local success2=false pcall(function()
if currentValue6:IsKeyDown(Enum["KeyCode"]["Backspace"])or currentValue6:IsKeyDown(Enum["KeyCode"]["Delete"])then
success2=true
end
end
)
if success2 then
settings["AutoServerHopEscape"]=false accentgreenColor(false)pcall(saveSettings)getFeatureState3("OFF")showNotification("Auto Hop Disabled", "Disabled via cancel key.", "info")
if label4 then
pcall(function()label4:Destroy()
end
)
end
continue
end
getFeatureState3("INITIALIZING ("..(math["ceil"](5-timestamp2).."s) [Press Delete or Red Button to Stop]"))
continue
else
local vdStophopbutton=screenGui:FindFirstChild("VD_StopHopButton")
if vdStophopbutton then
pcall(function()vdStophopbutton:Destroy()
end
)
end
end
if conditionMet8 then
getFeatureState3("ESCAPED (Waiting Hop)")task["wait"](2)
continue
end
local name2=localPlayer["Team"]
local isMatchingTeam=name2 and name2["Name"]=="Survivors"
local character2=localPlayer["Character"]
local rootPart=character2 and character2:FindFirstChild("HumanoidRootPart")
if not((isMatchingTeam and rootPart))then
local currentValue6, currentValue7=getTimerSeconds()
if currentValue6 or currentValue7 then
if getFeatureState4(currentValue6, currentValue7)then
getFeatureState3("HOPPING (Lobby)")serverHop()task["wait"](10)
continue
elseif currentValue6==-1 or(currentValue7 and string["find"](currentValue7:lower(), "not enough players"))then
continue
end
local conditionMet9=(currentValue7=="00:00"or currentValue6==0)
local conditionMet10=(currentValue6 and currentValue6<90)
if conditionMet9 or conditionMet10 then
getFeatureState3("WAITING FOR GAME ("..(tostring(currentValue7)..")"))
else
getFeatureState3("HOPPING (Time: "..(tostring(currentValue7)..")"))serverHop()task["wait"](10)
continue
end
else
getFeatureState3("WAITING FOR TIMER")
end
end
local conditionMet9=false
local name3=localPlayer["Team"]
local isMatchingTeam2=name3 and name3["Name"]=="Survivors"
local character3=localPlayer["Character"]
local rootPart2=character3 and character3:FindFirstChild("HumanoidRootPart")
if isMatchingTeam2 and rootPart2 then
conditionMet9=true
end
if conditionMet9 and(settings["AutoServerHopEscape"]and not conditionMet8)then
local farmstate=_G["VD_FarmState"]["lastSurvivorSpawnTime"]
if((farmstate or 0))==0 then
farmstate=tick()
end
local timeValue4=13
while true do
if not settings["AutoServerHopEscape"]or conditionMet8 then
break
end
local timestamp3=tick()-farmstate
if timestamp3>=timeValue4 then
break
end
local currentValue6=math["ceil"](timeValue4-timestamp3)getFeatureState3("PREPARING ESCAPE ("..(currentValue6.."s)"))task["wait"](.5)
end
if settings["AutoServerHopEscape"]and not conditionMet8 then
getFeatureState3("ESCAPING")
local character4=localPlayer["Character"]
local rootPart3=character4 and character4:FindFirstChild("HumanoidRootPart")
if rootPart3 then
local part=nil
local distance=math["huge"]
for index, instance in ipairs(workspace:GetDescendants())do
if instance:IsA("BasePart")and((instance["Name"]=="Fininshline"or instance["Name"]=="Finishline"or(instance["Name"]:lower()):find("finishline")or(instance["Name"]:lower()):find("fininshline")))then
local distance2=((instance["Position"]-rootPart3["Position"]))["Magnitude"]
if distance2<distance then
distance=distance2 part=instance
end
end
end
if part then
if _G["VD_StopAllInteractions"]then
pcall(_G["VD_StopAllInteractions"])task["wait"](.15)
end
rootPart3["CFrame"]=part["CFrame"]showNotification("Auto Hop Escape", "Teleported to escape line!", "success")conditionMet8=true getFeatureState3("ESCAPED")
else
showNotification("Auto Hop Escape", "Finish Line not found!", "error")getFeatureState3("ESCAPE FAILED")
end
end
if conditionMet8 then
for key=1, 15, 1 do
if not settings["AutoServerHopEscape"]then
break
end
getFeatureState3("POST-ESCAPE HOP ("..(((15-key)+1).."s)"))task["wait"](1)
end
if settings["AutoServerHopEscape"]then
getFeatureState3("HOPPING SERVER")serverHop()task["wait"](10)
end
end
end
end
else
conditionMet8=false
local vdStophopbutton=screenGui:FindFirstChild("VD_StopHopButton")
if vdStophopbutton then
pcall(function()vdStophopbutton:Destroy()
end
)
end
end
end
end
)task["spawn"](function()
while activeLoop do
if settings["AntiWiggle"] then
pcall(function()
local character2=localPlayer:GetAttribute("IsCarrying")==true or(localPlayer["Character"]and localPlayer["Character"]:GetAttribute("IsCarrying")==true)
if character2 then
local player=nil
for index, player2 in ipairs(Players:GetPlayers())do
if player2==localPlayer then
continue
end
local instance=player2["Character"]
if player2:GetAttribute("IsCarried")==true or(instance and instance:GetAttribute("IsCarried")==true)then
player=player2
break
end
end
if player then
local instance=player["Character"]
local remainingcarrytime=player:GetAttribute("RemainingCarryTime")or(instance and instance:GetAttribute("RemainingCarryTime"))or localPlayer:GetAttribute("RemainingCarryTime")or(localPlayer["Character"]and localPlayer["Character"]:GetAttribute("RemainingCarryTime"))
if remainingcarrytime and(type(remainingcarrytime)=="number"and remainingcarrytime<=1)then
local remotes=(((game:GetService("ReplicatedStorage")):WaitForChild("Remotes")):WaitForChild("Carry")):WaitForChild("DropSurvivorEvent")
if remotes then
remotes:FireServer()showNotification("Anti Wiggle", "Auto-dropped survivor to reset wiggle!", "success")
end
end
end
end
end
)
end
task["wait"](.05)
end
end
)_G["VD_KillerFarmState"]=_G["VD_KillerFarmState"]or{}_G["VD_KillerFarmState"]["grabRetries"]=_G["VD_KillerFarmState"]["grabRetries"]or 0 _G["VD_KillerFarmState"]["isHooking"]=_G["VD_KillerFarmState"]["isHooking"]or false _G["VD_KillerFarmState"]["lastHookRemoteTime"]=_G["VD_KillerFarmState"]["lastHookRemoteTime"]or 0 _G["VD_KillerFarmState"]["hookedBlacklist"]=_G["VD_KillerFarmState"]["hookedBlacklist"]or{}_G["VD_KillerFarmState"]["lastGrabTime"]=_G["VD_KillerFarmState"]["lastGrabTime"]or 0 task["spawn"](function()
local startPosition4=nil
local function character2()
local character3=localPlayer["Character"]
local conditionMet8=localPlayer:GetAttribute("IsCarrying")==true or(character3 and character3:GetAttribute("IsCarrying")==true)
if conditionMet8 then
local conditionMet9=false
for index, player in ipairs(Players:GetPlayers())do
if player~=localPlayer then
local instance=player["Character"]
if player:GetAttribute("IsCarried")==true or(instance and instance:GetAttribute("IsCarried")==true)or(getObjectValue and(instance and getObjectValue(instance, "IsCarried")==true))then
conditionMet9=true
break
end
end
end
if not conditionMet9 then
local killerfarmstate=_G["VD_KillerFarmState"]["lastGrabTime"]or 0
if tick()-killerfarmstate>4 then
conditionMet8=false
end
end
end
return conditionMet8
end
local function readStateValue2(instance, contextValue)
local timestamp=tick()
local killerfarmstate=_G["VD_KillerFarmState"]["hookedBlacklist"]
if killerfarmstate[instance]and timestamp<killerfarmstate[instance]then
return true
elseif killerfarmstate[instance]then
killerfarmstate[instance]=nil
end
if instance:GetAttribute("IsOccupied")==true or instance:GetAttribute("Occupied")==true then
return true
end
local instance2=instance["Parent"]
if instance2 then
if instance2:GetAttribute("IsOccupied")==true or instance2:GetAttribute("Occupied")==true then
return true
end
end
for index, player in ipairs(Players:GetPlayers())do
if player==localPlayer or player==contextValue then
continue
end
local instance3=player["Character"]
if not instance3 then
continue
end
local rootPart=instance3:FindFirstChild("HumanoidRootPart")
if not rootPart then
continue
end
local character3=((rootPart["Position"]-((localPlayer["Character"]and(localPlayer["Character"]:FindFirstChild("HumanoidRootPart")and localPlayer["Character"]["HumanoidRootPart"]["Position"])or rootPart["Position"]))))["Magnitude"]
local conditionMet8=player:GetAttribute("IsCarried")==true or instance3:GetAttribute("IsCarried")==true or(getObjectValue and getObjectValue(instance3, "IsCarried")==true)or character3<4
if conditionMet8 then
continue
end
local isHooked=instance3:GetAttribute("IsHooked")==true or player:GetAttribute("IsHooked")==true or(getObjectValue and getObjectValue(instance3, "IsHooked")==true)
local distance=((rootPart["Position"]-instance["Position"]))["Magnitude"]
if isHooked and distance<15 then
return true
end
if not isHooked and distance<8 then
return true
end
end
return false
end
local function getDistance2(position, contextValue)
local cachedValue6=nil
local distance=math["huge"]
for index, instance in ipairs(cachedHooks)do
local hookpoint=instance:IsA("BasePart")and instance or instance["PrimaryPart"]or instance:FindFirstChild("HookPoint", true)or instance:FindFirstChild("Handle", true)or instance:FindFirstChildWhichIsA("BasePart", true)
if hookpoint and not readStateValue2(hookpoint, contextValue)then
local distance2=((hookpoint["Position"]-position))["Magnitude"]
if distance2<distance then
distance=distance2 cachedValue6=hookpoint
end
end
end
return cachedValue6
end
local function character3()
local character4=localPlayer["Character"]and localPlayer["Character"]:FindFirstChild("HumanoidRootPart")
if not character4 then
return nil
end
local cachedValue6=nil
local distance=math["huge"]
for index, player in ipairs(Players:GetPlayers())do
if player==localPlayer then
continue
end
local teamName=player["Team"]
local teamName2=false
if teamName then
if teamName["Name"]=="Survivors"or teamName["Name"]~="Killer"and(teamName["Name"]~="Spectators"and teamName["Name"]~="Spectator")then
teamName2=true
end
else
teamName2=true
end
if teamName2 then
local instance=player["Character"]
local rootPart=instance and instance:FindFirstChild("HumanoidRootPart")
local humanoid=instance and instance:FindFirstChildOfClass("Humanoid")
if rootPart and(humanoid and humanoid["Health"]>0)then
local isHooked=instance:GetAttribute("IsHooked")==true or getObjectValue(instance, "IsHooked")==true
if not isHooked then
local distance2=((rootPart["Position"]-character4["Position"]))["Magnitude"]
if distance2<distance then
distance=distance2 cachedValue6=player
end
end
end
end
end
return cachedValue6
end
local function findRootPart(value)_G["VD_CurrentFarmState"]=value
if _G["VD_UpdateFarmStatus"]then
pcall(function()_G["VD_UpdateFarmStatus"](value)
end
)
end
end
while activeLoop do
local player=.15
if not isKillerFarmAllowed()then
task["wait"](player)
continue
end
local character4=localPlayer["Character"]
local rootPart=character2()
if not rootPart then
player=.08
else
player=.15
end
local success2, result=pcall(function()
local rootPart2=character4 and character4:FindFirstChild("HumanoidRootPart")
if not rootPart2 then
return
end
if rootPart then
if not _G["VD_KillerFarmState"]["wasCarrying"]then
_G["VD_KillerFarmState"]["wasCarrying"]=true task["wait"](2)character4=localPlayer["Character"]rootPart2=character4 and character4:FindFirstChild("HumanoidRootPart")rootPart=character2()
if not rootPart or not rootPart2 then
return
end
end
findRootPart("CARRYING")
if not _G["VD_KillerFarmState"]["isHooking"]then
local instance=getDistance2(rootPart2["Position"], startPosition4)
if instance then
_G["VD_KillerFarmState"]["isHooking"]=true
local distance=instance["Position"]
local distance2=((rootPart2["Position"]-distance))["Magnitude"]
if distance2>4 then
rootPart2["CFrame"]=CFrame["new"](distance+Vector3["new"](0, 1.5, 1.8), distance)pcall(function()workspace["CurrentCamera"]["CFrame"]=CFrame["new"](workspace["CurrentCamera"]["CFrame"]["Position"], distance)
end
)task["wait"](.5)
end
local remotes=((game:GetService("ReplicatedStorage")):WaitForChild("Remotes")):WaitForChild("Carry")
local hookevent=remotes:WaitForChild("HookEvent", 2)
local hookcommit=remotes:WaitForChild("HookCommit", 2)findRootPart("HANGING")
local timestamp=tick()
local killerfarmstate=timestamp-((_G["VD_KillerFarmState"]["lastHookRemoteTime"]or 0))
if killerfarmstate>=2 then
_G["VD_KillerFarmState"]["lastHookRemoteTime"]=timestamp
if hookevent then
pcall(function()hookevent:FireServer(instance)
end
)
end
task["wait"](.15)
if hookcommit then
pcall(function()hookcommit:FireServer(instance)
end
)
end
task["wait"](.15)
end
local instance2=instance["Parent"]
local child=instance:FindFirstChildOfClass("ProximityPrompt")
if not child and instance2 then
child=instance2:FindFirstChildOfClass("ProximityPrompt")
if not child then
for index, instance3 in ipairs(instance2:GetDescendants())do
if instance3:IsA("ProximityPrompt")then
child=instance3
break
end
end
end
end
if child then
pcall(function()fireproximityprompt(child)
end
)task["wait"](.15)
end
local timestamp2=tick()
local conditionMet8=false
while tick()-timestamp2<2 do
local character5=localPlayer["Character"]
local conditionMet9=localPlayer:GetAttribute("IsCarrying")==true or(character5 and character5:GetAttribute("IsCarrying")==true)
if not conditionMet9 then
conditionMet8=true
break
end
task["wait"](.1)
end
if not conditionMet8 then
_G["VD_KillerFarmState"]["hookedBlacklist"][instance]=tick()+8
end
_G["VD_KillerFarmState"]["isHooking"]=false _G["VD_KillerFarmState"]["lastHookRemoteTime"]=0 _G["VD_KillerFarmState"]["grabRetries"]=0
else
findRootPart("IDLE")task["wait"](.5)
end
end
else
_G["VD_KillerFarmState"]["wasCarrying"]=false _G["VD_KillerFarmState"]["isHooking"]=false
local player2=character3()
if player2 then
startPosition4=player2
local instance=player2["Character"]
local rootPart3=instance and instance:FindFirstChild("HumanoidRootPart")
local humanoid=instance and instance:FindFirstChildOfClass("Humanoid")
if rootPart3 and(humanoid and humanoid["Health"]>0)then
local isKnocked=instance:GetAttribute("Knocked")==true or player2:GetAttribute("Knocked")==true
if not isKnocked then
findRootPart("HUNTING")
local frame4=rootPart3["Position"]
local transform=rootPart3["CFrame"]["LookVector"]
local vector2=(Vector3["new"](transform["X"], 0, transform["Z"]))["Unit"]
local success3=frame4-vector2*1.2 rootPart2["CFrame"]=CFrame["new"](success3, frame4)pcall(function()workspace["CurrentCamera"]["CFrame"]=CFrame["new"](workspace["CurrentCamera"]["CFrame"]["Position"], frame4)
end
)
local remotes=((game:GetService("ReplicatedStorage")):WaitForChild("Remotes")):WaitForChild("Attacks")
local lunge=remotes:WaitForChild("Lunge", 2)
local basicattack=remotes:WaitForChild("BasicAttack", 2)
if lunge then
pcall(function()lunge:FireServer()
end
)
end
if basicattack then
pcall(function()basicattack:FireServer()
end
)
end
_G["VD_KillerFarmState"]["grabRetries"]=0
else
findRootPart("CARRYING")rootPart2["CFrame"]=rootPart3["CFrame"]task["wait"](.15)
local remotes=(((game:GetService("ReplicatedStorage")):WaitForChild("Remotes")):WaitForChild("Carry")):WaitForChild("CarrySurvivorEvent", 2)
if remotes then
pcall(function()remotes:FireServer(instance)
end
)
end
task["wait"](.2)
local conditionMet8=localPlayer:GetAttribute("IsCarrying")==true or(character4 and character4:GetAttribute("IsCarrying")==true)
if conditionMet8 then
_G["VD_KillerFarmState"]["lastGrabTime"]=tick()
else
_G["VD_KillerFarmState"]["grabRetries"]=((_G["VD_KillerFarmState"]["grabRetries"]or 0))+1
if((_G["VD_KillerFarmState"]["grabRetries"]or 0))>=3 then
_G["VD_KillerFarmState"]["grabRetries"]=0 task["wait"](.5)
end
end
end
else
findRootPart("IDLE")
end
else
findRootPart("IDLE")
end
end
end
)
if not success2 and result then
warn("[Killer Farm Error]: "..tostring(result))
end
task["wait"](player)
end
end
)do
local cachedValue6=nil
local cachedValue7=nil
local currentValue6=nil refreshMobileFloatingButtons=function()
if not isMobileDevice then
return
end
if mobileFloatingButtons then
for key, item in pairs(mobileFloatingButtons)do
pcall(function()item:Destroy()
end
)
end
table["clear"](mobileFloatingButtons)
end
if settings["MobileButtons"]then
for key, item in pairs(settings["MobileButtons"])do
if item and(item~=""and item~="None")then
pcall(createOrUpdateMobileFloatingButton, key, item)
end
end
end
end
end
function updateMobileAimbotButton()
local revolveraimbot=settings["RevolverAimbot"]["Enabled"]
if revolveraimbot and isMobileDevice then
if not mobileAimbotGui or not mobileAimbotGui["Parent"]then
if mobileAimbotGui then
pcall(function()mobileAimbotGui:Destroy()
end
)
end
local screenGui2=Instance["new"]("ScreenGui")screenGui2["Name"]="VD_MobileAimbotGui"screenGui2["ResetOnSpawn"]=false screenGui2["ZIndexBehavior"]=Enum["ZIndexBehavior"]["Sibling"]pcall(function()screenGui2["Parent"]=guiParent
end
)
if not screenGui2["Parent"]then
screenGui2["Parent"]=billboardParent
end
local button3=Instance["new"]("TextButton")button3["Name"]="AimbotButton"button3["Size"]=UDim2["new"](0, 75, 0, 75)button3["Position"]=UDim2["new"](.8, -37, .55, -37)button3["BackgroundColor3"]=mobileAimbotActive and Color3["fromRGB"](0, 180, 255)or Color3["fromRGB"](0, 0, 0)button3["BackgroundTransparency"]=mobileAimbotActive and.3 or.5 button3["Text"]="AIM"button3["TextColor3"]=Color3["fromRGB"](255, 255, 255)button3["Font"]=Enum["Font"]["GothamBold"]button3["TextSize"]=16 button3["Parent"]=screenGui2
local corner2=Instance["new"]("UICorner")corner2["CornerRadius"]=UDim["new"](.5, 0)corner2["Parent"]=button3
local stroke3=Instance["new"]("UIStroke")stroke3["Thickness"]=2 stroke3["Color"]=Color3["fromRGB"](255, 255, 255)stroke3["Transparency"]=.3 stroke3["Parent"]=button3
local startPosition4=nil
local startPosition5=nil
local conditionMet8=false
local connection6=nil button3["InputBegan"]:Connect(function(input)
if input["UserInputType"]==Enum["UserInputType"]["Touch"]or input["UserInputType"]==Enum["UserInputType"]["MouseButton1"]then
startPosition4=input["Position"]startPosition5=button3["Position"]conditionMet8=false
local connection7 connection7=input["Changed"]:Connect(function()
if input["UserInputState"]==Enum["UserInputState"]["End"]then
startPosition4=nil connection6=nil
if connection7 then
connection7:Disconnect()
end
if not conditionMet8 then
mobileAimbotActive=not mobileAimbotActive
if mobileAimbotActive then
button3["BackgroundColor3"]=Color3["fromRGB"](0, 180, 255)button3["BackgroundTransparency"]=.3
else
button3["BackgroundColor3"]=Color3["fromRGB"](0, 0, 0)button3["BackgroundTransparency"]=.5
end
end
end
end
)
end
end
)button3["InputChanged"]:Connect(function(input)
if input["UserInputType"]==Enum["UserInputType"]["Touch"]or input["UserInputType"]==Enum["UserInputType"]["MouseMovement"]then
connection6=input
end
end
)registerConnection(UserInputService["InputChanged"]:Connect(function(position)
if position==connection6 and startPosition4 then
local distance=position["Position"]-startPosition4
if distance["Magnitude"]>5 then
conditionMet8=true
end
button3["Position"]=UDim2["new"](startPosition5["X"]["Scale"], startPosition5["X"]["Offset"]+distance["X"], startPosition5["Y"]["Scale"], startPosition5["Y"]["Offset"]+distance["Y"])
end
end
))mobileAimbotGui=screenGui2
else
mobileAimbotGui["Enabled"]=true
local aimbotbutton=mobileAimbotGui:FindFirstChild("AimbotButton")
if aimbotbutton then
aimbotbutton["BackgroundColor3"]=mobileAimbotActive and Color3["fromRGB"](0, 180, 255)or Color3["fromRGB"](0, 0, 0)aimbotbutton["BackgroundTransparency"]=mobileAimbotActive and.3 or.5
end
end
else
if mobileAimbotGui then
mobileAimbotGui["Enabled"]=false mobileAimbotActive=false
end
end
end
function getClosestPlayerToMouse()
local cachedValue6=nil
local revolveraimbot=settings["RevolverAimbot"]["Radius"]or 150
local camera=workspace["CurrentCamera"]
if not camera then
return nil
end
local distance=UserInputService:GetMouseLocation()
if isMobileDevice then
distance=Vector2["new"](camera["ViewportSize"]["X"]/2, camera["ViewportSize"]["Y"]/2)
end
local team=localPlayer["Team"]
for index, player in ipairs(Players:GetPlayers())do
if player==localPlayer then
continue
end
if team and player["Team"]==team then
continue
end
local instance=player["Character"]
local humanoid=instance and instance:FindFirstChildOfClass("Humanoid")
local revolveraimbot2=instance and instance:FindFirstChild(settings["RevolverAimbot"]["TargetPart"])or(instance and instance:FindFirstChild("HumanoidRootPart"))
if instance and(humanoid and(humanoid["Health"]>0 and revolveraimbot2))then
local screenPosition, onScreen=camera:WorldToViewportPoint(revolveraimbot2["Position"])
if onScreen then
local distance2=((Vector2["new"](screenPosition["X"], screenPosition["Y"])-distance))["Magnitude"]
if distance2<revolveraimbot then
revolveraimbot=distance2 cachedValue6=revolveraimbot2
end
end
end
end
return cachedValue6
end
function updateFOVCircle()
local revolveraimbot=settings["RevolverAimbot"]["ShowFOV"]
local revolveraimbot2=settings["RevolverAimbot"]["Radius"]or 150
local camera=workspace["CurrentCamera"]
if not camera then
return
end
local currentValue6=UserInputService:GetMouseLocation()
if isMobileDevice then
currentValue6=Vector2["new"](camera["ViewportSize"]["X"]/2, camera["ViewportSize"]["Y"]/2)
end
pcall(function()
if not silentAimTarget or not silentAimTarget["Parent"]then
if silentAimTarget then
pcall(function()silentAimTarget:Destroy()
end
)
end
silentAimTarget=Instance["new"]("ScreenGui")silentAimTarget["Name"]="VD_AimbotFOVScreenGui"silentAimTarget["IgnoreGuiInset"]=true silentAimTarget["ResetOnSpawn"]=false
if isMobileDevice then
silentAimTarget["Parent"]=billboardParent
else
pcall(function()silentAimTarget["Parent"]=guiParent
end
)
if not silentAimTarget["Parent"]then
silentAimTarget["Parent"]=billboardParent
end
end
silentAimConnection=Instance["new"]("Frame")silentAimConnection["AnchorPoint"]=Vector2["new"](.5, .5)silentAimConnection["BackgroundTransparency"]=1 silentAimConnection["Active"]=false silentAimConnection["Selectable"]=false silentAimConnection["Parent"]=silentAimTarget
local corner2=Instance["new"]("UICorner", silentAimConnection)corner2["CornerRadius"]=UDim["new"](.5, 0)
local stroke3=Instance["new"]("UIStroke", silentAimConnection)stroke3["Thickness"]=1.5 stroke3["Color"]=UI["Accent"]stroke3["Transparency"]=.4
end
if revolveraimbot then
silentAimConnection["Position"]=UDim2["new"](0, currentValue6["X"], 0, currentValue6["Y"])silentAimConnection["Size"]=UDim2["new"](0, revolveraimbot2*2, 0, revolveraimbot2*2)silentAimTarget["Enabled"]=true
else
silentAimTarget["Enabled"]=false
end
end
)
end
function updateCrosshair()
local showcrosshair=settings["ShowCrosshair"]or(settings["RevolverAimbot"]and settings["RevolverAimbot"]["ShowCrosshair"])
local crosshairstyle=settings["CrosshairStyle"]or(settings["RevolverAimbot"]and settings["RevolverAimbot"]["CrosshairStyle"])or"Classic"
local crosshaircolor=settings["CrosshairColor"]or Color3["fromRGB"](0, 255, 255)
local crosshairsize=settings["CrosshairSize"]or 10
local success2=crosshairsize/10 pcall(function()
if parryTarget then
pcall(function()parryTarget:Destroy()
end
)parryTarget=nil
end
if not showcrosshair then
return
end
parryTarget=Instance["new"]("ScreenGui")parryTarget["Name"]="VD_CrosshairScreenGui"parryTarget["IgnoreGuiInset"]=true parryTarget["ResetOnSpawn"]=false
if isMobileDevice then
parryTarget["Parent"]=billboardParent
else
pcall(function()parryTarget["Parent"]=guiParent
end
)
if not parryTarget["Parent"]then
parryTarget["Parent"]=billboardParent
end
end
local frame4=Instance["new"]("Frame")frame4["Name"]="CenterContainer"frame4["Size"]=UDim2["new"](0, 0, 0, 0)frame4["Position"]=UDim2["new"](.5, 0, .5, 0)frame4["AnchorPoint"]=Vector2["new"](.5, .5)frame4["BackgroundTransparency"]=1 frame4["Parent"]=parryTarget
local hasParent=(crosshairstyle=="Tactical"or crosshairstyle=="Dot"or crosshairstyle=="Dot & Circle")
local conditionMet8=(crosshairstyle=="Tactical"or crosshairstyle=="Circle"or crosshairstyle=="Dot & Circle")
local conditionMet9=(crosshairstyle=="Tactical"or crosshairstyle=="Classic")
if hasParent then
local currentValue6=math["max"](2, math["round"](3*success2))
local frame5=Instance["new"]("Frame")frame5["Name"]="CenterDot"frame5["Size"]=UDim2["new"](0, currentValue6, 0, currentValue6)frame5["Position"]=UDim2["new"](0, -currentValue6/2, 0, -currentValue6/2)frame5["BackgroundColor3"]=crosshaircolor frame5["BorderSizePixel"]=0 frame5["Parent"]=frame4
local corner2=Instance["new"]("UICorner", frame5)corner2["CornerRadius"]=UDim["new"](.5, 0)
local stroke3=Instance["new"]("UIStroke", frame5)stroke3["Thickness"]=1 stroke3["Color"]=Color3["fromRGB"](0, 0, 0)
end
if conditionMet8 then
local conditionMet10=(crosshairstyle=="Circle")and 12 or 14
local currentValue6=math["max"](6, math["round"](conditionMet10*success2))
local currentValue7=currentValue6+2
local frame5=Instance["new"]("Frame")frame5["Name"]="GapCircle"frame5["Size"]=UDim2["new"](0, currentValue6, 0, currentValue6)frame5["Position"]=UDim2["new"](0, -currentValue6/2, 0, -currentValue6/2)frame5["BackgroundTransparency"]=1 frame5["Parent"]=frame4
local corner2=Instance["new"]("UICorner", frame5)corner2["CornerRadius"]=UDim["new"](.5, 0)
local stroke3=Instance["new"]("UIStroke", frame5)stroke3["Thickness"]=math["max"](1, 1.2*success2)stroke3["Color"]=crosshaircolor
local frame6=Instance["new"]("Frame")frame6["Name"]="ShadowCircle"frame6["Size"]=UDim2["new"](0, currentValue7, 0, currentValue7)frame6["Position"]=UDim2["new"](0, -currentValue7/2, 0, -currentValue7/2)frame6["BackgroundTransparency"]=1 frame6["Parent"]=frame4
local corner3=Instance["new"]("UICorner", frame6)corner3["CornerRadius"]=UDim["new"](.5, 0)
local stroke4=Instance["new"]("UIStroke", frame6)stroke4["Thickness"]=1 stroke4["Color"]=Color3["fromRGB"](0, 0, 0)stroke4["Transparency"]=.5
end
if conditionMet9 then
local currentValue6=math["max"](1, math["round"](1.5*success2))
local currentValue7=currentValue6/2
local items12={}
if crosshairstyle=="Tactical"then
local currentValue8=math["max"](2, math["round"](4*success2))
local layoutPosition=math["max"](4, math["round"](9*success2))items12={{["Size"]=UDim2["new"](0, currentValue6, 0, currentValue8);
["Position"]=UDim2["new"](0, -currentValue7, 0, -((layoutPosition+currentValue8)))}, {["Size"]=UDim2["new"](0, currentValue6, 0, currentValue8), ["Position"]=UDim2["new"](0, -currentValue7, 0, layoutPosition)};
{["Size"]=UDim2["new"](0, currentValue8, 0, currentValue6);
["Position"]=UDim2["new"](0, -((layoutPosition+currentValue8)), 0, -currentValue7)}, {["Size"]=UDim2["new"](0, currentValue8, 0, currentValue6), ["Position"]=UDim2["new"](0, layoutPosition, 0, -currentValue7)}}
else
local currentValue8=math["max"](3, math["round"](8*success2))
local layoutPosition=math["max"](1, math["round"](2*success2))items12={{["Size"]=UDim2["new"](0, currentValue6, 0, currentValue8);
["Position"]=UDim2["new"](0, -currentValue7, 0, -((layoutPosition+currentValue8)))}, {["Size"]=UDim2["new"](0, currentValue6, 0, currentValue8);
["Position"]=UDim2["new"](0, -currentValue7, 0, layoutPosition)}, {["Size"]=UDim2["new"](0, currentValue8, 0, currentValue6), ["Position"]=UDim2["new"](0, -((layoutPosition+currentValue8)), 0, -currentValue7)}, {["Size"]=UDim2["new"](0, currentValue8, 0, currentValue6);
["Position"]=UDim2["new"](0, layoutPosition, 0, -currentValue7)}}
end
for index, item in ipairs(items12)do
local frame5=Instance["new"]("Frame")frame5["Size"]=item["Size"]frame5["Position"]=item["Position"]frame5["BackgroundColor3"]=crosshaircolor frame5["BorderSizePixel"]=0 frame5["Parent"]=frame4
local stroke3=Instance["new"]("UIStroke", frame5)stroke3["Thickness"]=1 stroke3["Color"]=Color3["fromRGB"](0, 0, 0)
end
end
parryTarget["Enabled"]=true
end
)
end
function runAimbot()
local revolveraimbot=settings["RevolverAimbot"]["Enabled"]
if not revolveraimbot then
updateFOVCircle()updateCrosshair()
if isMobileDevice then
updateMobileAimbotButton()
end
spearTarget=nil
return
end
updateFOVCircle()updateCrosshair()
if isMobileDevice then
updateMobileAimbotButton()
end
local conditionMet8=false
if isMobileDevice then
conditionMet8=mobileAimbotActive
else
local revolveraimbot2=settings["RevolverAimbot"]["Key"]or"MouseButton2"
if revolveraimbot2=="MouseButton2"then
conditionMet8=UserInputService:IsMouseButtonPressed(Enum["UserInputType"]["MouseButton2"])
elseif revolveraimbot2=="MouseButton1"then
conditionMet8=UserInputService:IsMouseButtonPressed(Enum["UserInputType"]["MouseButton1"])
else
pcall(function()conditionMet8=UserInputService:IsKeyDown(Enum["KeyCode"][revolveraimbot2])
end
)
end
end
if conditionMet8 then
if not spearTarget or not spearTarget["Parent"]or not spearTarget["Parent"]:FindFirstChildOfClass("Humanoid")or(spearTarget["Parent"]:FindFirstChildOfClass("Humanoid"))["Health"]<=0 then
spearTarget=getClosestPlayerToMouse()
end
if spearTarget then
local camera=workspace["CurrentCamera"]
if camera then
local distance=spearTarget["Position"]
if settings["RevolverAimbot"]["PredictionEnabled"]then
local instance=spearTarget["Parent"]
local rootPart=instance and instance:FindFirstChild("HumanoidRootPart")
if rootPart then
local transform=((camera["CFrame"]["Position"]-distance))["Magnitude"]
local revolveraimbot2=settings["RevolverAimbot"]["BulletVelocity"]or 800
local currentValue6=transform/revolveraimbot2
local currentValue7=rootPart["AssemblyLinearVelocity"]distance=distance+(currentValue7*currentValue6)
end
end
distance=(distance+camera["CFrame"]["RightVector"]*((((settings["RevolverAimbot"]["OffsetX"]or 0))/10)))+camera["CFrame"]["UpVector"]*((((settings["RevolverAimbot"]["OffsetY"]or 0))/10))pcall(function()
local character2=localPlayer["Character"]
local rootPart=character2 and character2:FindFirstChild("HumanoidRootPart")
if rootPart then
local vector2=Vector3["new"](distance["X"], rootPart["Position"]["Y"], distance["Z"])rootPart["CFrame"]=CFrame["new"](rootPart["Position"], vector2)
end
end
)
local transform=CFrame["new"](camera["CFrame"]["Position"], distance)
local revolveraimbot2=settings["RevolverAimbot"]["Smoothness"]or.15
if revolveraimbot2<=0 then
camera["CFrame"]=transform
else
camera["CFrame"]=camera["CFrame"]:Lerp(transform, revolveraimbot2)
end
end
end
else
spearTarget=nil
end
end
RunService:BindToRenderStep("VD_Aimbot", Enum["RenderPriority"]["Camera"]["Value"]+1, runAimbot)
local cachedValue6=nil
local conditionMet8=false
local cachedValue7=nil
local cachedValue8=nil
local function conditionMet9(player)
if player:GetAttribute("Role")=="Killer"or player:GetAttribute("IsKiller")==true then
return true
end
if player["Character"]and((player["Character"]:GetAttribute("Role")=="Killer"or player["Character"]:GetAttribute("IsKiller")==true))then
return true
end
local name2=player["Team"]
if name2 then
local name3=name2["Name"]:lower()
if name3:find("killer")or name3:find("slasher")or name3:find("monster")then
return true
end
end
return false
end
local function getFeatureState3()
local aimassist=settings["AimAssist"]or{}
local distance=aimassist["FOV"]or 150
local rootPart=aimassist["TargetPart"]or"UpperTorso"
local teamName=aimassist["TargetTeam"]or"Both"
local camera=workspace["CurrentCamera"]
if not camera then
return nil
end
local distance2=UserInputService:GetMouseLocation()
if isMobileDevice then
distance2=Vector2["new"](camera["ViewportSize"]["X"]/2, camera["ViewportSize"]["Y"]/2)
end
local cachedValue9=nil
for index, player in ipairs(Players:GetPlayers())do
if player==localPlayer then
continue
end
local teamName2=conditionMet9(player)
if teamName=="Survivors"and teamName2 then
continue
end
if teamName=="Killer"and not teamName2 then
continue
end
local instance=player["Character"]
local humanoid=instance and instance:FindFirstChildOfClass("Humanoid")
local rootPart2=instance and((instance:FindFirstChild(rootPart)or instance:FindFirstChild("HumanoidRootPart")or instance:FindFirstChild("Head")))
if instance and(humanoid and(humanoid["Health"]>0 and rootPart2))then
local screenPosition, onScreen=camera:WorldToViewportPoint(rootPart2["Position"])
if onScreen then
local distance3=((Vector2["new"](screenPosition["X"], screenPosition["Y"])-distance2))["Magnitude"]
if distance3<distance then
distance=distance3 cachedValue9=rootPart2
end
end
end
end
return cachedValue9
end
local cachedValue9=nil
local function getFeatureState4()
local aimassist=settings["AimAssist"]or{}
local currentValue6=aimassist["Enabled"]and aimassist["ShowFOV"]
local currentValue7=aimassist["FOV"]or 150
local camera=workspace["CurrentCamera"]
if not camera then
return
end
local currentValue8=UserInputService:GetMouseLocation()
if isMobileDevice then
currentValue8=Vector2["new"](camera["ViewportSize"]["X"]/2, camera["ViewportSize"]["Y"]/2)
end
local visible2=false
if Drawing and Drawing["new"]then
pcall(function()
if not cachedValue9 then
cachedValue9=Drawing["new"]("Circle")cachedValue9["Thickness"]=1.8 cachedValue9["NumSides"]=64 cachedValue9["Radius"]=currentValue7 cachedValue9["Filled"]=false cachedValue9["Color"]=Color3["fromRGB"](0, 240, 255)cachedValue9["Transparency"]=.8
end
if currentValue6 then
cachedValue9["Position"]=currentValue8 cachedValue9["Radius"]=currentValue7 cachedValue9["Visible"]=true
else
cachedValue9["Visible"]=false
end
visible2=true
end
)
end
if not visible2 then
pcall(function()
if not cachedValue7 or not cachedValue7["Parent"]then
if cachedValue7 then
pcall(function()cachedValue7:Destroy()
end
)
end
cachedValue7=Instance["new"]("ScreenGui")cachedValue7["Name"]="VD_AimAssistFOVScreenGui"cachedValue7["IgnoreGuiInset"]=true cachedValue7["ResetOnSpawn"]=false
local player=guiParent
if not player then
pcall(function()player=gethui()
end
)
end
if not player then
player=localPlayer:FindFirstChildOfClass("PlayerGui")
end
if not player then
player=billboardParent
end
cachedValue7["Parent"]=player cachedValue8=Instance["new"]("Frame")cachedValue8["AnchorPoint"]=Vector2["new"](.5, .5)cachedValue8["BackgroundTransparency"]=1 cachedValue8["Active"]=false cachedValue8["Selectable"]=false cachedValue8["Parent"]=cachedValue7
local corner2=Instance["new"]("UICorner", cachedValue8)corner2["CornerRadius"]=UDim["new"](.5, 0)
local stroke3=Instance["new"]("UIStroke", cachedValue8)stroke3["Thickness"]=1.8 stroke3["Color"]=UI["AccentCyan"]stroke3["Transparency"]=.35
end
if currentValue6 then
cachedValue8["Position"]=UDim2["new"](0, currentValue8["X"], 0, currentValue8["Y"])cachedValue8["Size"]=UDim2["new"](0, currentValue7*2, 0, currentValue7*2)cachedValue7["Enabled"]=true
else
if cachedValue7 then
cachedValue7["Enabled"]=false
end
end
end
)
end
end
local instance=nil
local conditionMet10=false
local function cleanupResources2()
local aimassist=settings["AimAssist"]or{}
local currentValue6=aimassist["Enabled"]
if currentValue6 and isMobileDevice then
if not instance or not instance["Parent"]then
if instance then
pcall(function()instance:Destroy()
end
)
end
local screenGui2=Instance["new"]("ScreenGui")screenGui2["Name"]="VD_MobileAimAssistGui"screenGui2["ResetOnSpawn"]=false screenGui2["ZIndexBehavior"]=Enum["ZIndexBehavior"]["Sibling"]pcall(function()screenGui2["Parent"]=guiParent
end
)
if not screenGui2["Parent"]then
screenGui2["Parent"]=billboardParent
end
local button3=Instance["new"]("TextButton")button3["Name"]="AimAssistButton"button3["Size"]=UDim2["new"](0, 75, 0, 75)button3["Position"]=UDim2["new"](.85, -37, .4, -37)button3["BackgroundColor3"]=conditionMet10 and Color3["fromRGB"](0, 220, 255)or Color3["fromRGB"](15, 15, 25)button3["BackgroundTransparency"]=conditionMet10 and.25 or.5 button3["Text"]="🎯 AIM"button3["TextColor3"]=Color3["fromRGB"](255, 255, 255)button3["Font"]=Enum["Font"]["GothamBold"]button3["TextSize"]=15 button3["Parent"]=screenGui2
local corner2=Instance["new"]("UICorner", button3)corner2["CornerRadius"]=UDim["new"](.5, 0)
local stroke3=Instance["new"]("UIStroke", button3)stroke3["Thickness"]=2 stroke3["Color"]=Color3["fromRGB"](0, 220, 255)stroke3["Transparency"]=.3
local startPosition4=nil
local startPosition5=nil
local conditionMet11=false
local connection6=nil button3["InputBegan"]:Connect(function(input)
if input["UserInputType"]==Enum["UserInputType"]["Touch"]or input["UserInputType"]==Enum["UserInputType"]["MouseButton1"]then
startPosition4=input["Position"]startPosition5=button3["Position"]conditionMet11=false
local connection7 connection7=input["Changed"]:Connect(function()
if input["UserInputState"]==Enum["UserInputState"]["End"]then
startPosition4=nil connection6=nil
if connection7 then
connection7:Disconnect()
end
if not conditionMet11 then
conditionMet10=not conditionMet10 button3["BackgroundColor3"]=conditionMet10 and Color3["fromRGB"](0, 220, 255)or Color3["fromRGB"](15, 15, 25)button3["BackgroundTransparency"]=conditionMet10 and.25 or.5
end
end
end
)
end
end
)button3["InputChanged"]:Connect(function(input)
if input["UserInputType"]==Enum["UserInputType"]["Touch"]or input["UserInputType"]==Enum["UserInputType"]["MouseMovement"]then
connection6=input
end
end
)registerConnection(UserInputService["InputChanged"]:Connect(function(position)
if position==connection6 and startPosition4 then
local distance=position["Position"]-startPosition4
if distance["Magnitude"]>5 then
conditionMet11=true
end
button3["Position"]=UDim2["new"](startPosition5["X"]["Scale"], startPosition5["X"]["Offset"]+distance["X"], startPosition5["Y"]["Scale"], startPosition5["Y"]["Offset"]+distance["Y"])
end
end
))instance=screenGui2
else
instance["Enabled"]=true
local aimassistbutton=instance:FindFirstChild("AimAssistButton")
if aimassistbutton then
aimassistbutton["BackgroundColor3"]=conditionMet10 and Color3["fromRGB"](0, 220, 255)or Color3["fromRGB"](15, 15, 25)aimassistbutton["BackgroundTransparency"]=conditionMet10 and.25 or.5
end
end
else
if instance then
instance["Enabled"]=false conditionMet10=false
end
end
end
registerConnection(UserInputService["InputBegan"]:Connect(function(input, contextValue)
if contextValue or isBindingKey then
return
end
local aimassist=settings["AimAssist"]
if not aimassist or not aimassist["Enabled"]then
return
end
if aimassist["Mode"]=="Toggle"then
local name2=aimassist["Key"]or"MouseButton2"
local conditionMet11=false
if name2=="MouseButton2"and input["UserInputType"]==Enum["UserInputType"]["MouseButton2"]then
conditionMet11=true
elseif name2=="MouseButton1"and input["UserInputType"]==Enum["UserInputType"]["MouseButton1"]then
conditionMet11=true
elseif((input["UserInputType"]==Enum["UserInputType"]["Keyboard"]or input["UserInputType"]==Enum["UserInputType"]["Gamepad1"]))and input["KeyCode"]["Name"]==name2 then
conditionMet11=true
end
if conditionMet11 then
conditionMet8=not conditionMet8 showNotification("Aim Assist", conditionMet8 and"Aim Assist ACTIVATED"or"Aim Assist DEACTIVATED", conditionMet8 and"success"or"info")
end
end
end
))
local function getFeatureState5()
local aimassist=settings["AimAssist"]or{}
if not aimassist["Enabled"]then
getFeatureState4()
if isMobileDevice then
cleanupResources2()
end
cachedValue6=nil
return
end
getFeatureState4()
if isMobileDevice then
cleanupResources2()
end
local conditionMet11=false
if isMobileDevice then
conditionMet11=conditionMet10
elseif aimassist["Mode"]=="Toggle"then
conditionMet11=conditionMet8
else
local button3=aimassist["Key"]or"MouseButton2"
if button3=="MouseButton2"then
conditionMet11=UserInputService:IsMouseButtonPressed(Enum["UserInputType"]["MouseButton2"])
elseif button3=="MouseButton1"then
conditionMet11=UserInputService:IsMouseButtonPressed(Enum["UserInputType"]["MouseButton1"])
else
pcall(function()
if button3:find("Button")or button3:find("DPad")then
conditionMet11=UserInputService:IsGamepadButtonDown(Enum["UserInputType"]["Gamepad1"], Enum["KeyCode"][button3])
else
conditionMet11=UserInputService:IsKeyDown(Enum["KeyCode"][button3])
end
end
)
end
end
if conditionMet11 then
if not cachedValue6 or not cachedValue6["Parent"]or not cachedValue6["Parent"]:FindFirstChildOfClass("Humanoid")or(cachedValue6["Parent"]:FindFirstChildOfClass("Humanoid"))["Health"]<=0 then
cachedValue6=getFeatureState3()
end
if cachedValue6 then
local camera=workspace["CurrentCamera"]
if camera then
local distance=cachedValue6["Position"]
if aimassist["Prediction"]then
local instance2=cachedValue6["Parent"]
local rootPart=instance2 and instance2:FindFirstChild("HumanoidRootPart")
if rootPart then
local transform=((camera["CFrame"]["Position"]-distance))["Magnitude"]
local distance2=transform/1000 distance=distance+(rootPart["AssemblyLinearVelocity"]*distance2)
end
end
local transform=CFrame["new"](camera["CFrame"]["Position"], distance)
local frame4=aimassist["Smoothness"]or.2
if frame4>=.95 then
camera["CFrame"]=transform
else
camera["CFrame"]=camera["CFrame"]:Lerp(transform, frame4)
end
end
end
else
cachedValue6=nil
end
end
RunService:BindToRenderStep("VD_AimAssist", Enum["RenderPriority"]["Camera"]["Value"]+2, getFeatureState5)
local cachedValue10=nil
local items12={}
local function getDistance2(value, contextValue, instance2)
local currentValue6=items12[value]
local timestamp=tick()
local distance=contextValue
if instance2 and(typeof(instance2)=="Instance"and instance2:IsA("BasePart"))then
if currentValue6 and(currentValue6["lastPos"]and((timestamp-currentValue6["time"])>.001 and(timestamp-currentValue6["time"])<.5))then
local distance2=timestamp-currentValue6["time"]distance=((instance2["Position"]-currentValue6["lastPos"]))/distance2
end
end
if contextValue["Magnitude"]<.5 and distance["Magnitude"]<.5 then
if not currentValue6 then
currentValue6={}items12[value]=currentValue6
end
currentValue6["velocity"]=Vector3["new"](0, 0, 0)currentValue6["time"]=timestamp currentValue6["lastPos"]=((instance2 and(typeof(instance2)=="Instance"and instance2:IsA("BasePart"))))and instance2["Position"]or nil
return Vector3["new"](0, 0, 0)
end
if distance["Magnitude"]>60 then
distance=contextValue
end
if contextValue["Magnitude"]>60 then
contextValue=distance["Magnitude"]<=60 and distance or Vector3["new"](0, 0, 0)
end
local distance2=contextValue:Lerp(distance, .5)
if distance2["Magnitude"]>40 then
distance2=distance2["Unit"]*40
end
if not currentValue6 or(timestamp-currentValue6["time"]>.5)then
if not currentValue6 then
currentValue6={}items12[value]=currentValue6
end
currentValue6["velocity"]=distance2 currentValue6["time"]=timestamp currentValue6["lastPos"]=((instance2 and(typeof(instance2)=="Instance"and instance2:IsA("BasePart"))))and instance2["Position"]or nil
return distance2
end
local distance3=.2
local distance4=currentValue6["velocity"]:Lerp(distance2, distance3)
if distance4["Magnitude"]<.2 then
distance4=Vector3["new"](0, 0, 0)
elseif distance4["Magnitude"]>40 then
distance4=distance4["Unit"]*40
end
currentValue6["velocity"]=distance4 currentValue6["time"]=timestamp currentValue6["lastPos"]=((instance2 and(typeof(instance2)=="Instance"and instance2:IsA("BasePart"))))and instance2["Position"]or nil
return distance4
end
local function calculateValue(value, contextValue, contextValue2, contextValue3, contextValue4, contextValue5)
local distance=((contextValue-value))["Magnitude"]/contextValue4
local distance2=contextValue
for key=1, 3, 1 do
distance2=(contextValue+(contextValue2*distance))+(.5*contextValue3)*(distance^2)
local distance3=distance2-value
local vector2=(Vector3["new"](distance3["X"], 0, distance3["Z"]))["Magnitude"]
local distance4=distance3["Y"]
if contextValue5==0 then
distance=distance3["Magnitude"]/contextValue4
else
local currentValue6=.25*(contextValue5^2)
local currentValue7=distance4*contextValue5-(contextValue4^2)
local currentValue8=vector2^2+distance4^2
local currentValue9=currentValue7^2-(4*currentValue6)*currentValue8
if currentValue9>=0 then
local currentValue10=((-currentValue7-math["sqrt"](currentValue9)))/((2*currentValue6))
local currentValue11=((-currentValue7+math["sqrt"](currentValue9)))/((2*currentValue6))
local distance5=-1
if currentValue10>0 and currentValue11>0 then
distance5=math["min"](currentValue10, currentValue11)
elseif currentValue10>0 then
distance5=currentValue10
elseif currentValue11>0 then
distance5=currentValue11
end
if distance5>0 then
distance=math["sqrt"](distance5)
else
distance=distance3["Magnitude"]/contextValue4
end
else
distance=distance3["Magnitude"]/contextValue4
break
end
end
end
local currentValue6=distance2-value
local vector2=Vector3["new"](0, -contextValue5, 0)
local currentValue7=((currentValue6-(.5*vector2)*(distance^2)))/distance
return currentValue7["Unit"], distance2
end
_G["VD_SolveProjectileAim"]=calculateValue _G["VD_GetSmoothedVelocity"]=getDistance2 task["spawn"](function()RunService["Heartbeat"]:Connect(function()
if not((settings["SpearAimbot"]and settings["SpearAimbot"]["Enabled"]))and(not((settings["RevolverSilentAim"]and settings["RevolverSilentAim"]["Enabled"]))and not((settings["SpearSilentAim"]and settings["SpearSilentAim"]["Enabled"])))then
return
end
pcall(function()
for index, player in ipairs(Players:GetPlayers())do
if player~=localPlayer and player["Character"]then
local rootPart=player["Character"]:FindFirstChild("HumanoidRootPart")
if rootPart then
local vector2=rootPart["AssemblyLinearVelocity"]or rootPart["Velocity"]or Vector3["new"](0, 0, 0)getDistance2(player, vector2, rootPart)
end
end
end
end
)
end
)
end
)
local function readStateValue2()
if not settings["SpearAimbot"]or not settings["SpearAimbot"]["Enabled"]or not isFeatureAvailable()then
cachedValue10=nil
return
end
local character2=localPlayer["Character"]
local conditionMet11=false
if character2 and character2:GetAttribute("spearmode")==true then
conditionMet11=true
elseif localPlayer:GetAttribute("spearmode")==true then
conditionMet11=true
end
if not conditionMet11 then
cachedValue10=nil
return
end
local conditionMet12=false
if isMobileDevice then
conditionMet12=true
else
local spearaimbot=settings["SpearAimbot"]["Key"]or"MouseButton2"
if spearaimbot=="MouseButton2"then
conditionMet12=UserInputService:IsMouseButtonPressed(Enum["UserInputType"]["MouseButton2"])
elseif spearaimbot=="MouseButton1"then
conditionMet12=UserInputService:IsMouseButtonPressed(Enum["UserInputType"]["MouseButton1"])
else
pcall(function()conditionMet12=UserInputService:IsKeyDown(Enum["KeyCode"][spearaimbot])
end
)
end
end
if not conditionMet12 then
cachedValue10=nil
return
end
local camera=workspace["CurrentCamera"]
if not camera then
return
end
local distance=UserInputService:GetMouseLocation()
if isMobileDevice then
distance=Vector2["new"](camera["ViewportSize"]["X"]/2, camera["ViewportSize"]["Y"]/2)
end
local spearaimbot=settings["SpearAimbot"]["Radius"]or 150
if not cachedValue10 or not cachedValue10["Parent"]or not cachedValue10["Parent"]:FindFirstChildOfClass("Humanoid")or(cachedValue10["Parent"]:FindFirstChildOfClass("Humanoid"))["Health"]<=0 then
local cachedValue11=nil
local distance2=spearaimbot
local team=localPlayer["Team"]
for index, player in ipairs(Players:GetPlayers())do
if player==localPlayer then
continue
end
if team and player["Team"]==team then
continue
end
local instance2=player["Character"]
local humanoid=instance2 and instance2:FindFirstChildOfClass("Humanoid")
local spearaimbot2=instance2 and((instance2:FindFirstChild(settings["SpearAimbot"]["TargetPart"])or instance2:FindFirstChild("UpperTorso")or instance2:FindFirstChild("Torso")or instance2:FindFirstChild("HumanoidRootPart")))
if instance2 and(humanoid and(humanoid["Health"]>0 and spearaimbot2))then
local screenPosition, onScreen=camera:WorldToViewportPoint(spearaimbot2["Position"])
if onScreen then
local distance3=((Vector2["new"](screenPosition["X"], screenPosition["Y"])-distance))["Magnitude"]
if distance3<distance2 then
distance2=distance3 cachedValue11=spearaimbot2
end
end
end
end
cachedValue10=cachedValue11
end
if cachedValue10 and character2 then
pcall(function()
local instance2=cachedValue10["Parent"]
local rootPart=instance2:FindFirstChild("HumanoidRootPart")or instance2["PrimaryPart"]or instance2:FindFirstChild("Torso")or instance2:FindFirstChild("UpperTorso")
if rootPart then
local rootPart2=character2:FindFirstChild("Head")or character2:FindFirstChild("HumanoidRootPart")
local rootPart3=camera["CFrame"]["Position"]
if rootPart2 then
local vector2=Vector3["new"](1.35, .34, -2.51)rootPart3=rootPart2["CFrame"]:PointToWorldSpace(vector2)
end
local currentValue6=cachedValue10["Position"]
local currentValue7=rootPart["AssemblyLinearVelocity"]
local player=Players:GetPlayerFromCharacter(instance2)
local player2=player and getDistance2(player, currentValue7)or currentValue7
local success2=.04 pcall(function()success2=localPlayer:GetNetworkPing()
end
)
local currentValue8=success2+.05 currentValue6=currentValue6+player2*currentValue8
local vector2=Vector3["new"](0, 0, 0)
local humanoid=instance2:FindFirstChildOfClass("Humanoid")
if humanoid and humanoid["FloorMaterial"]==Enum["Material"]["Air"]then
vector2=Vector3["new"](0, -workspace["Gravity"], 0)
end
local conditionMet13=character2:GetAttribute("special")==true
local spearaimbot2=settings["SpearAimbot"]["Speed"]or 150
local spearaimbot3=settings["SpearAimbot"]["Gravity"]or 98
local currentValue9=spearaimbot2
local currentValue10=spearaimbot3
if spearaimbot2==150 then
currentValue9=conditionMet13 and specialSpearSpeed or normalSpearSpeed
elseif conditionMet13 then
currentValue9=spearaimbot2*(1.1333333333333)
end
if spearaimbot3==98 then
currentValue10=conditionMet13 and specialSpearGravity or normalSpearGravity
elseif conditionMet13 then
currentValue10=spearaimbot3
end
local timestamp=tick()-lastUpdateTime
local clampedValue=math["clamp"](timestamp/1, 0, 1)
local currentValue11=currentValue9*.7333
local currentValue12=currentValue11+((currentValue9-currentValue11))*clampedValue
local frame4, distance2=calculateValue(rootPart3, currentValue6, player2, vector2, currentValue12, currentValue10)
local rootPart4=character2:FindFirstChild("HumanoidRootPart")
if rootPart4 then
local vector3=Vector3["new"](distance2["X"], rootPart4["Position"]["Y"], distance2["Z"])rootPart4["CFrame"]=CFrame["new"](rootPart4["Position"], vector3)
end
local frame5=((distance2-rootPart3))["Magnitude"]
local distance3=rootPart3+frame4*frame5
local transform=CFrame["lookAt"](camera["CFrame"]["Position"], distance3)
local spearaimbot4=settings["SpearAimbot"]["Smoothness"]or.05
if spearaimbot4<=0 then
camera["CFrame"]=transform
else
camera["CFrame"]=camera["CFrame"]:Lerp(transform, spearaimbot4)
end
end
end
)
end
end
RunService:BindToRenderStep("VD_SpearAimbot", Enum["RenderPriority"]["Camera"]["Value"]+1, readStateValue2)
settings["Stalker"]=settings["Stalker"] or {NoCooldown=false,StalkWhileMoving=false,KillGrab=false,InfiniteCorrupt=false,AutoDodge=false,AutoDodgeDistance=15}
do
local part=nil
local timeValue4=0
local tween=nil function updateAbysswalkerCircle(value)timeValue4=tick()
local character2=localPlayer and localPlayer["Character"]
local rootPart=character2 and character2:FindFirstChild("HumanoidRootPart")
if not rootPart then
return
end
if not part or part["Parent"]==nil then
part=Instance["new"]("CylinderHandleAdornment")part["Name"]="VD_AbyssAutoCrouchCircle"part["Height"]=.06 part["Color3"]=(UI and UI["AccentCyan"])or Color3["fromRGB"](0, 220, 255)part["Transparency"]=1 part["AlwaysOnTop"]=true part["ZIndex"]=10 part["CFrame"]=CFrame["new"](0, -3.1, 0)*CFrame["Angles"](math["rad"](90), 0, 0)
end
if part["Adornee"]~=rootPart then
part["Adornee"]=rootPart
end
if part["Parent"]~=rootPart then
part["Parent"]=rootPart
end
part["Radius"]=value part["InnerRadius"]=math["max"](.1, value-.25)part["Visible"]=true
if part["Transparency"]>.45 then
if tween then
pcall(function()tween:Cancel()
end
)
end
tween=TweenService:Create(part, TweenInfo["new"](.3, Enum["EasingStyle"]["Quad"], Enum["EasingDirection"]["Out"]), {["Transparency"]=.45})tween:Play()
end
end
registerConnection(RunService["Heartbeat"]:Connect(function()
if part and(part["Visible"]and timeValue4>0)then
if(tick()-timeValue4)>=3 then
timeValue4=0
if tween then
pcall(function()tween:Cancel()
end
)
end
tween=TweenService:Create(part, TweenInfo["new"](.4, Enum["EasingStyle"]["Quad"], Enum["EasingDirection"]["In"]), {["Transparency"]=1})tween:Play()task["delay"](.42, function()
if part and timeValue4==0 then
part["Visible"]=false
end
end
)
end
end
end
))
end
local function processValue5()
local currentValue6="80411309607666"
local numericValue4=1.5
local numericValue5=1
local connection6=nil
local connection7=nil
local numericValue6=0
local function processValue6()
if isMobileDevice then
pcall(function()
local button3=localPlayer["PlayerGui"]["Survivor-mob"]["Controls"]["crouch"]button3["MouseButton1Down"]:Fire()task["delay"](numericValue5, function()pcall(function()button3["MouseButton1Up"]:Fire()
end
)
end
)
end
)
else
pcall(function()
local currentValue7=game:GetService("VirtualInputManager")currentValue7:SendKeyEvent(true, Enum["KeyCode"]["LeftControl"], false, game)task["delay"](numericValue5, function()pcall(function()currentValue7:SendKeyEvent(false, Enum["KeyCode"]["LeftControl"], false, game)
end
)
end
)
end
)
end
end
local function players()
for index, item in ipairs(Players:GetPlayers())do
if item~=localPlayer then
local success2, result=pcall(getSelectedKiller, item)
if success2 and((tostring(result)):lower()):find("abysswalker")then
return item
end
end
end
return nil
end
local function findRootPart(value)
if not((settings["Stalker"]and(settings["Stalker"]["AutoDodge"]and isFeatureAvailable())))then
return
end
local animation=value["Animation"]and(tostring(value["Animation"]["AnimationId"])):match("%d+")or""
if animation~=currentValue6 then
return
end
_G["VD_IsDodgingStalker"]=true
local player=players()
if not player then
_G["VD_IsDodgingStalker"]=false
return
end
local character2=localPlayer["Character"]
local rootPart=character2 and character2:FindFirstChild("HumanoidRootPart")
local instance2=player["Character"]
local rootPart2=instance2 and instance2:FindFirstChild("HumanoidRootPart")
if not rootPart or not rootPart2 then
_G["VD_IsDodgingStalker"]=false
return
end
task["spawn"](function()
local timestamp=tick()
local isdodgingstalker=false _G["VD_IsDodgingStalker"]=true
local stalker=(settings["Stalker"]and settings["Stalker"]["AutoDodgeDistance"])or 15
while(tick()-timestamp)<numericValue4 and not isdodgingstalker do
local success2, result=pcall(function()
return((rootPart["Position"]-rootPart2["Position"]))["Magnitude"]
end
)
if success2 and result<=stalker then
isdodgingstalker=true processValue6()
end
RunService["Heartbeat"]:Wait()
end
_G["VD_IsDodgingStalker"]=false
end
)
end
local function cleanupResources3(instance2)
if connection7 then
pcall(function()connection7:Disconnect()
end
)
end
connection7=nil
local humanoid=instance2:FindFirstChildOfClass("Humanoid")
local child=humanoid and((humanoid:FindFirstChildOfClass("Animator")or humanoid))
if not child then
local connection8 connection8=instance2["DescendantAdded"]:Connect(function(instance3)
if instance3:IsA("Animator")then
connection8:Disconnect()connection7=instance3["AnimationPlayed"]:Connect(findRootPart)registerConnection(connection7)
end
end
)registerConnection(connection8)
return
end
connection7=child["AnimationPlayed"]:Connect(findRootPart)registerConnection(connection7)connection6=instance2
end
registerConnection(RunService["Heartbeat"]:Connect(function()
if not((settings["Stalker"]and(settings["Stalker"]["AutoDodge"]and(isFeatureAvailable()and(featureAvailability and featureAvailability["Stalker"])))))then
return
end
numericValue6=numericValue6+1
if numericValue6<30 then
return
end
numericValue6=0
local player=players()
if not player then
return
end
local character2=player["Character"]
if character2 and character2~=connection6 then
cleanupResources3(character2)
end
end
))
end
processValue5()do
local player=game:GetService("Players")
local player2=game:GetService("RunService")
local instance2=game:GetService("ReplicatedStorage")
local connection6=game:GetService("UserInputService")
local conditionMet11=true
local player3=false connection6["InputBegan"]:Connect(function(input, contextValue)
if contextValue then
return
end
if input["KeyCode"]~=Enum["KeyCode"]["Q"]then
return
end
local success2=""pcall(function()success2=tostring(getSelectedKiller(localPlayer))
end
)
local currentValue6=success2:lower()
if currentValue6:find("abysswalker")then
if not((settings["Stalker"]and settings["Stalker"]["InfiniteCorrupt"]))then
return
end
pcall(function()
local instance3=game:GetService("ReplicatedStorage")
local instance4=instance3:FindFirstChild("Remotes")
if not instance4 then
return
end
local rootPart=instance4:FindFirstChild("SoundPlayer")
local character2=localPlayer["Character"]and localPlayer["Character"]:FindFirstChild("HumanoidRootPart")
if rootPart and character2 then
rootPart:FireServer("70398808450410", character2, .4, 60)
end
local instance5=instance4:FindFirstChild("Killers")
local instance6=instance5 and instance5:FindFirstChild("Abysswalker")
local corrupt=instance6 and instance6:FindFirstChild("corrupt")
if corrupt then
corrupt:FireServer()
end
end
)
return
end
if not((currentValue6:find("stalker")or currentValue6:find("veil")or currentValue6:find("masked")))then
return
end
if not isFeatureAvailable()then
return
end
local stalker=settings["Stalker"]and(settings["Stalker"]["NoCooldown"]and(isFeatureAvailable()and(featureAvailability and featureAvailability["Stalker"])))
local stalker2=settings["Stalker"]and(settings["Stalker"]["KillGrab"]and(isFeatureAvailable()and(featureAvailability and featureAvailability["Stalker"])))
if not stalker then
return
end
if player3 then
return
end
local character2=localPlayer["Character"]
local rootPart=character2 and character2:FindFirstChild("HumanoidRootPart")
local humanoid=character2 and character2:FindFirstChildOfClass("Humanoid")
local child=humanoid and((humanoid:FindFirstChildOfClass("Animator")or humanoid))
if not rootPart or not child then
return
end
local instance3=instance2:FindFirstChild("Remotes")
if not instance3 then
return
end
player3=true
local animation=nil pcall(function()
local animation2=Instance["new"]("Animation")animation2["AnimationId"]="rbxassetid://77477445889320"animation=child:LoadAnimation(animation2)animation["Priority"]=Enum["AnimationPriority"]["Action"]animation:Play()
end
)
local instance4=instance3:FindFirstChild("Attacks")
local basicattack=instance4 and instance4:FindFirstChild("BasicAttack")
local instance5=instance3:FindFirstChild("Killers")
local instance6=instance5 and instance5:FindFirstChild("Stalker")
local consumeready=instance6 and instance6:FindFirstChild("ConsumeReady")
local grab=instance6 and instance6:FindFirstChild("grab")
local soundplayer=instance3:FindFirstChild("SoundPlayer")
if soundplayer then
pcall(function()soundplayer:FireServer("132736711620405", localPlayer["Character"]["HumanoidRootPart"], .3, 70)
end
)
end
if basicattack then
pcall(function()basicattack:FireServer(true)
end
)
end
if consumeready then
pcall(function()consumeready:FireServer()
end
)
end
if grab then
task["spawn"](function()
local conditionMet12=true
local timestamp=tick()+2
while conditionMet12 and tick()<timestamp do
player2["Heartbeat"]:Wait()
local character3=localPlayer["Character"]
local rootPart2=character3 and character3:FindFirstChild("HumanoidRootPart")
if not rootPart2 then
break
end
local cachedValue11=nil
local distance=math["huge"]
for index, player4 in ipairs(player:GetPlayers())do
if player4~=localPlayer and player4["Character"]then
local rootPart3=player4["Character"]:FindFirstChild("HumanoidRootPart")
local humanoid2=player4["Character"]:FindFirstChildOfClass("Humanoid")
if rootPart3 and(humanoid2 and humanoid2["Health"]>0)then
local distance2=((rootPart3["Position"]-rootPart2["Position"]))["Magnitude"]
if distance2<distance then
distance=distance2 cachedValue11=player4["Character"]
end
end
end
end
if cachedValue11 and distance<=5 then
local currentValue7=stalker2 and 2 or 1
for key=1, currentValue7, 1 do
pcall(function()grab:FireServer(cachedValue11)
end
)
if currentValue7>1 then
task["wait"](.05)
end
end
if animation then
pcall(function()animation:Stop()
end
)
end
conditionMet12=false
break
end
end
if animation then
pcall(function()animation:Stop()
end
)
end
player3=false
end
)
else
task["delay"](.5, function()
if animation then
pcall(function()animation:Stop()
end
)
end
player3=false
end
)
end
end
)task["spawn"](function()
local function processValue6(instance3)
local button3=instance3:FindFirstChild("move2", true)
if not button3 or not button3:IsA("GuiObject")then
local timestamp=tick()
while tick()-timestamp<10 do
button3=instance3:FindFirstChild("move2", true)
if button3 and button3:IsA("GuiObject")then
break
end
task["wait"](.5)
end
end
if not button3 or not button3:IsA("GuiObject")then
return
end
pcall(function()button3["Active"]=true
end
)
local function findRootPart()
local success2=""pcall(function()success2=tostring(getSelectedKiller(localPlayer))
end
)
local currentValue6=success2:lower()
if currentValue6:find("abysswalker")then
if not((settings["Stalker"]and settings["Stalker"]["InfiniteCorrupt"]))then
return
end
pcall(function()
local instance4=game:GetService("ReplicatedStorage")
local instance5=instance4:FindFirstChild("Remotes")
if not instance5 then
return
end
local rootPart=instance5:FindFirstChild("SoundPlayer")
local character2=localPlayer["Character"]and localPlayer["Character"]:FindFirstChild("HumanoidRootPart")
if rootPart and character2 then
rootPart:FireServer("70398808450410", character2, .4, 60)
end
local instance6=instance5:FindFirstChild("Killers")
local instance7=instance6 and instance6:FindFirstChild("Abysswalker")
local corrupt=instance7 and instance7:FindFirstChild("corrupt")
if corrupt then
corrupt:FireServer()
end
end
)
return
end
if not((currentValue6:find("stalker")or currentValue6:find("veil")or currentValue6:find("masked")))then
return
end
if not isFeatureAvailable()then
return
end
local stalker=settings["Stalker"]and(settings["Stalker"]["NoCooldown"]and(isFeatureAvailable()and(featureAvailability and featureAvailability["Stalker"])))
if not stalker then
return
end
if player3 then
return
end
local character2=localPlayer["Character"]
local rootPart=character2 and character2:FindFirstChild("HumanoidRootPart")
local humanoid=character2 and character2:FindFirstChildOfClass("Humanoid")
if not rootPart or not humanoid then
return
end
local child=humanoid:FindFirstChildOfClass("Animator")or humanoid
local instance4=instance2:FindFirstChild("Remotes")
if not instance4 then
return
end
player3=true
local stalker2=settings["Stalker"]and(settings["Stalker"]["KillGrab"]and(isFeatureAvailable()and(featureAvailability and featureAvailability["Stalker"])))
local animation=nil pcall(function()
local animation2=Instance["new"]("Animation")animation2["AnimationId"]="rbxassetid://77477445889320"animation=child:LoadAnimation(animation2)animation["Priority"]=Enum["AnimationPriority"]["Action"]animation:Play()
end
)
local instance5=instance4:FindFirstChild("Attacks")
local basicattack=instance5 and instance5:FindFirstChild("BasicAttack")
local instance6=instance4:FindFirstChild("Killers")
local instance7=instance6 and instance6:FindFirstChild("Stalker")
local consumeready=instance7 and instance7:FindFirstChild("ConsumeReady")
local grab=instance7 and instance7:FindFirstChild("grab")
local soundplayer=instance4:FindFirstChild("SoundPlayer")
if soundplayer then
pcall(function()soundplayer:FireServer("132736711620405", localPlayer["Character"]["HumanoidRootPart"], .3, 70)
end
)
end
if basicattack then
pcall(function()basicattack:FireServer(true)
end
)
end
if consumeready then
pcall(function()consumeready:FireServer()
end
)
end
if grab then
task["spawn"](function()
local conditionMet12=true
local timestamp=tick()+2
while conditionMet12 and tick()<timestamp do
player2["Heartbeat"]:Wait()
local character3=localPlayer["Character"]
local rootPart2=character3 and character3:FindFirstChild("HumanoidRootPart")
if not rootPart2 then
break
end
local character4, distance=nil, math["huge"]
for index, player4 in ipairs(player:GetPlayers())do
if player4~=localPlayer and player4["Character"]then
local rootPart3=player4["Character"]:FindFirstChild("HumanoidRootPart")
local humanoid2=player4["Character"]:FindFirstChildOfClass("Humanoid")
if rootPart3 and(humanoid2 and humanoid2["Health"]>0)then
local distance2=((rootPart3["Position"]-rootPart2["Position"]))["Magnitude"]
if distance2<distance then
distance=distance2 character4=player4["Character"]
end
end
end
end
if character4 and distance<=5 then
local currentValue7=stalker2 and 2 or 1
for key=1, currentValue7, 1 do
pcall(function()grab:FireServer(character4)
end
)
if currentValue7>1 then
task["wait"](.05)
end
end
if animation then
pcall(function()animation:Stop()
end
)
end
conditionMet12=false
break
end
end
if animation then
pcall(function()animation:Stop()
end
)
end
player3=false
end
)
else
task["delay"](.5, function()
if animation then
pcall(function()animation:Stop()
end
)
end
player3=false
end
)
end
end
registerConnection(button3["Activated"]:Connect(findRootPart))pcall(function()registerConnection(button3["MouseButton1Click"]:Connect(findRootPart))
end
)pcall(function()registerConnection(button3["TouchTap"]:Connect(findRootPart))
end
)pcall(function()registerConnection(button3["InputBegan"]:Connect(function(input)
if input["UserInputType"]==Enum["UserInputType"]["Touch"]or input["UserInputType"]==Enum["UserInputType"]["MouseButton1"]then
findRootPart()
end
end
))
end
)
end
local instance3=localPlayer:WaitForChild("PlayerGui", 10)
if not instance3 then
return
end
local slasherMob=instance3:FindFirstChild("Slasher-mob")or instance3:FindFirstChild("Slasher-mo")
if slasherMob then
task["spawn"](processValue6, slasherMob)
end
registerConnection(instance3["ChildAdded"]:Connect(function(name2)
if name2["Name"]=="Slasher-mob"or name2["Name"]=="Slasher-mo"then
task["spawn"](processValue6, name2)
end
end
))
end
)task["spawn"](function()
while conditionMet11 do
task["wait"](.2)
if settings["Stalker"]and settings["Stalker"]["StalkWhileMoving"]then
pcall(function()
local instance3=instance2:FindFirstChild("Remotes")
local instance4=instance3 and instance3:FindFirstChild("Killers")
local instance5=instance4 and instance4:FindFirstChild("Stalker")
local startstalking=instance5 and instance5:FindFirstChild("StartStalking")
if startstalking then
for index, player4 in ipairs(player:GetPlayers())do
if player4~=localPlayer and player4["Character"]then
local humanoid=player4["Character"]:FindFirstChildOfClass("Humanoid")
if humanoid and humanoid["Health"]>0 then
pcall(function()startstalking:FireServer(player4)
end
)
end
end
end
end
end
)
end
end
end
 )
end
task["spawn"](function()
local instance2=game:GetService("Lighting")
if not defaultLightingSettings then
defaultLightingSettings={["FogStart"]=instance2["FogStart"];
["FogEnd"]=instance2["FogEnd"], ["Brightness"]=instance2["Brightness"], ["ClockTime"]=instance2["ClockTime"], ["Ambient"]=instance2["Ambient"], ["OutdoorAmbient"]=instance2["OutdoorAmbient"];
["GlobalShadows"]=instance2["GlobalShadows"]}
end
local items13={}
local function processValue6(instance3)
if not instance3:IsA("Atmosphere")and not instance3:IsA("DepthOfFieldEffect")then
return
end
if table["find"](items13, instance3)then
return
end
table["insert"](items13, instance3)
end
registerConnection(instance2["DescendantAdded"]:Connect(processValue6))
for index, item in ipairs(instance2:GetDescendants())do
processValue6(item)
end
updateVisuals=function()pcall(function()
local function getFeatureState6(name2, name3)
local child=instance2:FindFirstChild(name3)
if not child then
child=Instance["new"](name2)child["Name"]=name3 child["Parent"]=instance2
end
return child
end
local rtxgraphics=settings["RTXGraphics"]and(isFeatureAvailable()and(featureAvailability and featureAvailability["RTXGraphics"]))
local conditionMet11=rtxgraphics or(settings["GraphicsTint"]and settings["GraphicsTint"]~="Default")
if conditionMet11 then
local currentValue6=getFeatureState6("ColorCorrectionEffect", "Helper_ColorCorrection")currentValue6["Enabled"]=true currentValue6["Contrast"]=rtxgraphics and.12 or 0 currentValue6["Saturation"]=rtxgraphics and.15 or 0
if settings["GraphicsTint"]=="Warm"then
currentValue6["TintColor"]=Color3["fromRGB"](255, 240, 220)
elseif settings["GraphicsTint"]=="Cold"then
currentValue6["TintColor"]=Color3["fromRGB"](220, 240, 255)
else
currentValue6["TintColor"]=Color3["fromRGB"](255, 255, 255)
end
else
local helperColorcorrection=instance2:FindFirstChild("Helper_ColorCorrection")
if helperColorcorrection then
helperColorcorrection["Enabled"]=false
end
end
if rtxgraphics then
instance2["Ambient"]=Color3["fromRGB"](35, 30, 45)instance2["OutdoorAmbient"]=Color3["fromRGB"](45, 40, 55)instance2["Brightness"]=2.5 instance2["ExposureCompensation"]=.4 instance2["GlobalShadows"]=true instance2["EnvironmentDiffuseScale"]=1 instance2["EnvironmentSpecularScale"]=1
local currentValue6=getFeatureState6("BloomEffect", "Helper_Bloom")currentValue6["Enabled"]=true currentValue6["Intensity"]=.8 currentValue6["Size"]=24 currentValue6["Threshold"]=.85
local currentValue7=getFeatureState6("SunRaysEffect", "Helper_SunRays")currentValue7["Enabled"]=true currentValue7["Intensity"]=.08 currentValue7["Spread"]=.7
local currentValue8=getFeatureState6("Atmosphere", "Helper_Atmosphere")currentValue8["Density"]=settings["AtmosphereDensity"]or.3 currentValue8["Offset"]=.25 currentValue8["Color"]=Color3["fromRGB"](160, 180, 200)currentValue8["Glare"]=.4 currentValue8["Haze"]=1.5
else
if not settings["FullBright"]and defaultLightingSettings then
instance2["Ambient"]=defaultLightingSettings["Ambient"]instance2["OutdoorAmbient"]=defaultLightingSettings["OutdoorAmbient"]instance2["Brightness"]=defaultLightingSettings["Brightness"]instance2["GlobalShadows"]=defaultLightingSettings["GlobalShadows"]
end
local helperBloom=instance2:FindFirstChild("Helper_Bloom")
if helperBloom then
helperBloom["Enabled"]=false
end
local helperSunrays=instance2:FindFirstChild("Helper_SunRays")
if helperSunrays then
helperSunrays["Enabled"]=false
end
local helperAtmosphere=instance2:FindFirstChild("Helper_Atmosphere")
if helperAtmosphere then
helperAtmosphere["Parent"]=nil
end
end
if settings["CinematicDOF"]and(isFeatureAvailable()and(featureAvailability and featureAvailability["CinematicDOF"]))then
local distance=getFeatureState6("DepthOfFieldEffect", "Helper_DOF")distance["Enabled"]=true distance["FocusDistance"]=25 distance["InFocusRadius"]=15 distance["NearIntensity"]=.1 distance["FarIntensity"]=.65
else
local helperDof=instance2:FindFirstChild("Helper_DOF")
if helperDof then
helperDof["Enabled"]=false
end
end
end
)
end
local conditionMet11=false
local conditionMet12=false
local connection6=game:GetService("RunService")registerConnection(connection6["Heartbeat"]:Connect(function()
if settings["RTXGraphics"]and(isFeatureAvailable()and(featureAvailability and featureAvailability["RTXGraphics"]))then
instance2["Ambient"]=Color3["fromRGB"](35, 30, 45)instance2["OutdoorAmbient"]=Color3["fromRGB"](45, 40, 55)instance2["Brightness"]=2.5 instance2["ExposureCompensation"]=.4 instance2["GlobalShadows"]=true instance2["EnvironmentDiffuseScale"]=1 instance2["EnvironmentSpecularScale"]=1
end
end
))
while activeLoop do
task["wait"](.1)pcall(function()
if settings["FullBright"]then
if instance2["Brightness"]~=2 then
if conditionMet11 then
defaultLightingSettings["Brightness"]=instance2["Brightness"]
end
instance2["Brightness"]=2
end
if instance2["ClockTime"]~=14 then
if conditionMet11 then
defaultLightingSettings["ClockTime"]=instance2["ClockTime"]
end
instance2["ClockTime"]=14
end
local color2=Color3["fromRGB"](255, 255, 255)
if instance2["Ambient"]~=color2 then
if conditionMet11 then
defaultLightingSettings["Ambient"]=instance2["Ambient"]
end
instance2["Ambient"]=color2
end
if instance2["OutdoorAmbient"]~=color2 then
if conditionMet11 then
defaultLightingSettings["OutdoorAmbient"]=instance2["OutdoorAmbient"]
end
instance2["OutdoorAmbient"]=color2
end
if instance2["GlobalShadows"]~=false then
if conditionMet11 then
defaultLightingSettings["GlobalShadows"]=instance2["GlobalShadows"]
end
instance2["GlobalShadows"]=false
end
if not conditionMet11 then
conditionMet11=true
end
else
if conditionMet11 then
instance2["Brightness"]=defaultLightingSettings["Brightness"]instance2["ClockTime"]=defaultLightingSettings["ClockTime"]instance2["Ambient"]=defaultLightingSettings["Ambient"]instance2["OutdoorAmbient"]=defaultLightingSettings["OutdoorAmbient"]instance2["GlobalShadows"]=defaultLightingSettings["GlobalShadows"]conditionMet11=false
else
defaultLightingSettings["Brightness"]=instance2["Brightness"]defaultLightingSettings["ClockTime"]=instance2["ClockTime"]defaultLightingSettings["Ambient"]=instance2["Ambient"]defaultLightingSettings["OutdoorAmbient"]=instance2["OutdoorAmbient"]defaultLightingSettings["GlobalShadows"]=instance2["GlobalShadows"]
end
end
if settings["NoFog"]then
if instance2["FogStart"]~=999999 then
if conditionMet12 then
defaultLightingSettings["FogStart"]=instance2["FogStart"]
end
instance2["FogStart"]=999999
end
if instance2["FogEnd"]~=999999 then
if conditionMet12 then
defaultLightingSettings["FogEnd"]=instance2["FogEnd"]
end
instance2["FogEnd"]=999999
end
for key=#items13, 1, -1 do
local instance3=items13[key]
if not instance3 or not instance3["Parent"]then
table["remove"](items13, key)
else
if instance3:IsA("Atmosphere")then
if not cachedAtmospheres[instance3]then
cachedAtmospheres[instance3]={["Density"]=instance3["Density"];
["Haze"]=instance3["Haze"]}
else
if instance3["Density"]~=0 or instance3["Haze"]~=0 then
cachedAtmospheres[instance3]["Density"]=instance3["Density"]cachedAtmospheres[instance3]["Haze"]=instance3["Haze"]
end
end
if instance3["Density"]~=0 then
instance3["Density"]=0
end
if instance3["Haze"]~=0 then
instance3["Haze"]=0
end
elseif instance3:IsA("DepthOfFieldEffect")then
if cachedDoFs[instance3]==nil then
cachedDoFs[instance3]=instance3["Enabled"]
else
if instance3["Enabled"]~=false then
cachedDoFs[instance3]=instance3["Enabled"]
end
end
if instance3["Enabled"]~=false then
instance3["Enabled"]=false
end
end
end
end
if not conditionMet12 then
conditionMet12=true
end
else
if conditionMet12 then
instance2["FogStart"]=defaultLightingSettings["FogStart"]instance2["FogEnd"]=defaultLightingSettings["FogEnd"]
for key, item in pairs(cachedAtmospheres)do
if key and key["Parent"]then
pcall(function()key["Density"]=item["Density"]key["Haze"]=item["Haze"]
end
)
end
end
table["clear"](cachedAtmospheres)
for key, item in pairs(cachedDoFs)do
if key and key["Parent"]then
pcall(function()key["Enabled"]=item
end
)
end
end
table["clear"](cachedDoFs)conditionMet12=false
else
defaultLightingSettings["FogStart"]=instance2["FogStart"]defaultLightingSettings["FogEnd"]=instance2["FogEnd"]
end
end
end
)
end
end
)task["spawn"](function()
while activeLoop do
task["wait"](1)pcall(function()
if settings["AutoSkillCheck"]and settings["SkillCheckSpeedVal"]then
local character2=localPlayer and localPlayer["Character"]
if character2 then
local skillcheckspeedval=settings["SkillCheckSpeedVal"]or 1 character2:SetAttribute("skillcheckspeed", skillcheckspeedval)character2:SetAttribute("SkillCheckSpeed", skillcheckspeedval)
end
end
end
)
end
end
)
local items13={}
local conditionMet11=false
local timestamp=tick()task["spawn"](function()
while true do
task["wait"](.01)
if#items13>0 then
local timestamp2=tick()
while#items13>0 and items13[1]["sendTime"]<=timestamp2 do
local success2=table["remove"](items13, 1)pcall(function()success2["func"](success2["self"], unpack(success2["args"]))
end
)
end
end
end
end
)
local instance2=nil
local function cleanupResources3()
if instance2 then
pcall(function()instance2:Destroy()
end
)instance2=nil
end
end
local function getFeatureState6()
if not instance2 then
return
end
if not settings["EnableDesyncGhost"]then
cleanupResources3()
return
end
pcall(function()
local accentColor={["Accent"]=UI["Accent"];
["Cyan"]=Color3["fromRGB"](0, 255, 255);
["Purple"]=Color3["fromRGB"](180, 50, 255), ["Green"]=Color3["fromRGB"](0, 255, 120), ["Red"]=Color3["fromRGB"](255, 60, 60), ["Yellow"]=Color3["fromRGB"](255, 220, 0), ["White"]=Color3["fromRGB"](255, 255, 255)}
local desyncghostcolor=accentColor[settings["DesyncGhostColor"]or"Accent"]or UI["Accent"]
local desyncghosttransparency=settings["DesyncGhostTransparency"]or.5
local desyncghostalwaysontop=settings["DesyncGhostAlwaysOnTop"]
if desyncghostalwaysontop==nil then
desyncghostalwaysontop=true
end
local highlight=instance2:FindFirstChild("GhostHighlight")
if highlight then
highlight["FillColor"]=desyncghostcolor highlight["FillTransparency"]=desyncghosttransparency highlight["DepthMode"]=desyncghostalwaysontop and Enum["HighlightDepthMode"]["AlwaysOnTop"]or Enum["HighlightDepthMode"]["Occluded"]
end
end
)
end
local function findRootPart(instance3, position)
if not settings["EnableDesyncGhost"]then
cleanupResources3()
return
end
pcall(function()
local rootPart=instance3:FindFirstChild("HumanoidRootPart")
if not rootPart then
return
end
local accentColor={["Accent"]=UI["Accent"];
["Cyan"]=Color3["fromRGB"](0, 255, 255), ["Purple"]=Color3["fromRGB"](180, 50, 255);
["Green"]=Color3["fromRGB"](0, 255, 120);
["Red"]=Color3["fromRGB"](255, 60, 60), ["Yellow"]=Color3["fromRGB"](255, 220, 0), ["White"]=Color3["fromRGB"](255, 255, 255)}
local desyncghostcolor=accentColor[settings["DesyncGhostColor"]or"Accent"]or UI["Accent"]
local desyncghosttransparency=settings["DesyncGhostTransparency"]or.5
local desyncghostalwaysontop=settings["DesyncGhostAlwaysOnTop"]
if desyncghostalwaysontop==nil then
desyncghostalwaysontop=true
end
if instance2 and instance2["Parent"]then
local transform=rootPart["CFrame"]
for index, instance4 in ipairs(instance2:GetChildren())do
if instance4:IsA("BasePart")then
local originalpartname=instance4:GetAttribute("OriginalPartName")
local part=originalpartname and instance3:FindFirstChild(originalpartname, true)
if part then
local transform2=transform:ToObjectSpace(part["CFrame"])instance4["CFrame"]=position*transform2 instance4["Color"]=desyncghostcolor
end
elseif instance4:IsA("Highlight")then
instance4["FillColor"]=desyncghostcolor instance4["FillTransparency"]=desyncghosttransparency instance4["DepthMode"]=desyncghostalwaysontop and Enum["HighlightDepthMode"]["AlwaysOnTop"]or Enum["HighlightDepthMode"]["Occluded"]
end
end
return
end
cleanupResources3()
local model=Instance["new"]("Model")model["Name"]="DesyncGhost"
local humanoid=Instance["new"]("Humanoid")humanoid["DisplayDistanceType"]=Enum["HumanoidDisplayDistanceType"]["None"]humanoid["Parent"]=model
local transform=rootPart["CFrame"]
for index, instance4 in ipairs(instance3:GetChildren())do
if instance4:IsA("BasePart")and instance4["Name"]~="HumanoidRootPart"then
local part=instance4:Clone()part["Anchored"]=true part["CanCollide"]=false part["CastShadow"]=false part["Transparency"]=.99 part["Color"]=desyncghostcolor part["Material"]=Enum["Material"]["SmoothPlastic"]part:SetAttribute("OriginalPartName", instance4["Name"])
for index2, instance5 in ipairs(part:GetChildren())do
if instance5:IsA("SpecialMesh")then
instance5["TextureId"]=""
else
instance5:Destroy()
end
end
local transform2=transform:ToObjectSpace(instance4["CFrame"])part["CFrame"]=position*transform2 part["Parent"]=model
elseif instance4:IsA("Accessory")then
local part=instance4:FindFirstChild("Handle")
if part and part:IsA("BasePart")then
local part2=part:Clone()part2["Anchored"]=true part2["CanCollide"]=false part2["CastShadow"]=false part2["Transparency"]=.99 part2["Color"]=desyncghostcolor part2["Material"]=Enum["Material"]["SmoothPlastic"]part2:SetAttribute("OriginalPartName", part["Name"])
for index2, instance5 in ipairs(part2:GetChildren())do
if instance5:IsA("SpecialMesh")or instance5:IsA("Mesh")then
pcall(function()instance5["TextureId"]=""
end
)
else
instance5:Destroy()
end
end
local transform2=transform:ToObjectSpace(part["CFrame"])part2["CFrame"]=position*transform2 part2["Parent"]=model
end
end
end
local highlight=Instance["new"]("Highlight")highlight["Name"]="GhostHighlight"highlight["FillColor"]=desyncghostcolor highlight["FillTransparency"]=desyncghosttransparency highlight["OutlineColor"]=Color3["fromRGB"](255, 255, 255)highlight["OutlineTransparency"]=.1 highlight["DepthMode"]=desyncghostalwaysontop and Enum["HighlightDepthMode"]["AlwaysOnTop"]or Enum["HighlightDepthMode"]["Occluded"]highlight["Adornee"]=model highlight["Enabled"]=true highlight["Parent"]=model model["Parent"]=workspace instance2=model
end
)
end
task["spawn"](function()
local currentValue6=game:GetService("RunService")
local conditionMet12=false
while activeLoop do
local currentValue7=currentValue6["Heartbeat"]:Wait()
if((settings["FakeLag"]or settings["Desync"]))and(isFeatureAvailable()and(featureAvailability and featureAvailability["FakeLag"]))then
pcall(function()
local character2=localPlayer["Character"]
local rootPart=character2 and character2:FindFirstChild("HumanoidRootPart")
local humanoid=character2 and character2:FindFirstChildOfClass("Humanoid")
if not rootPart or not humanoid or humanoid["Health"]<=0 then
if conditionMet11 or conditionMet12 then
rootPart["Anchored"]=false conditionMet11=false conditionMet12=false
end
return
end
if settings["Desync"]then
if conditionMet11 then
conditionMet11=false cleanupResources3()
end
if not conditionMet12 then
conditionMet12=true rootPart["Anchored"]=true findRootPart(character2, rootPart["CFrame"])
end
if rootPart["Anchored"]then
local distance=humanoid["MoveDirection"]
if distance["Magnitude"]>0 then
local transform=humanoid["WalkSpeed"]rootPart["CFrame"]=rootPart["CFrame"]+(distance*((transform*currentValue7)))
end
end
elseif settings["FakeLag"]then
if conditionMet12 then
conditionMet12=false cleanupResources3()
end
local fakelagms=math["clamp"](settings["FakeLagMs"]or 200, 50, 1000)
local currentValue8=fakelagms/1000
if not conditionMet11 then
conditionMet11=true timestamp=tick()rootPart["Anchored"]=true findRootPart(character2, rootPart["CFrame"])
end
if rootPart["Anchored"]then
local distance=humanoid["MoveDirection"]
if distance["Magnitude"]>0 then
local transform=humanoid["WalkSpeed"]rootPart["CFrame"]=rootPart["CFrame"]+(distance*((transform*currentValue7)))
end
end
if tick()-timestamp>=currentValue8 then
rootPart["Anchored"]=false cleanupResources3()task["wait"](.08)rootPart["Anchored"]=true findRootPart(character2, rootPart["CFrame"])timestamp=tick()
end
end
end
)
else
if conditionMet11 or conditionMet12 then
pcall(function()
local character2=localPlayer["Character"]
local rootPart=character2 and character2:FindFirstChild("HumanoidRootPart")
if rootPart then
rootPart["Anchored"]=false
end
end
)cleanupResources3()conditionMet11=false conditionMet12=false
end
end
end
pcall(function()
local character2=localPlayer["Character"]
local rootPart=character2 and character2:FindFirstChild("HumanoidRootPart")
if rootPart then
rootPart["Anchored"]=false
end
end
)cleanupResources3()
end
)pcall(function()
local remoteEvent=(Instance["new"]("RemoteEvent"))["FireServer"]
local currentValue6
local currentValue7=checkcaller or function()
return false
end
local currentValue8=newcclosure or function(value)
return value
end
if hasExecutorRestriction or not hookmetamethod or not getnamecallmethod then
task["spawn"](function()task["wait"](1)showNotification("Compatibility Mode", "Network hooks disabled for "..(getExecutorName().." compatibility."), "warning")
end
)
return
end
currentValue6=hookmetamethod(game, "__namecall", currentValue8(function(name2, ...)
local currentValue9 pcall(function()currentValue9=getnamecallmethod()
end
)
if not currentValue9 then
return currentValue6(name2, ...)
end
local items14={...}
local conditionMet12=false
local cachedValue11=nil
local success2, result=pcall(function()
if currentValue9=="FireServer"or currentValue9=="fireServer"then
if typeof(name2)=="Instance"then
if name2["Name"]=="Spearthrow"then
local name3=name2["Parent"]
if name3 and(name3["Name"]=="Veil"and(name3["Parent"]and name3["Parent"]["Name"]=="Killers"))then
if settings["SpearSilentAim"]and(settings["SpearSilentAim"]["Enabled"]and isFeatureAvailable())then
if featureAvailability and featureAvailability["SpearSilentAim"]then
pcall(featureAvailability["SpearSilentAim"], items14)
end
elseif settings["SpearAimbot"]and(settings["SpearAimbot"]["Enabled"]and(cachedValue10 and isFeatureAvailable()))then
local instance3=cachedValue10["Parent"]
local rootPart=instance3:FindFirstChild("HumanoidRootPart")or instance3["PrimaryPart"]or instance3:FindFirstChild("Torso")
local character2=localPlayer["Character"]and((localPlayer["Character"]:FindFirstChild("Head")or localPlayer["Character"]:FindFirstChild("HumanoidRootPart")))
if rootPart and character2 then
local vector2=items14[3]or character2["CFrame"]:PointToWorldSpace(Vector3["new"](1.35, .34, -2.51))
local currentValue10=cachedValue10["Position"]
local vector3=Vector3["new"](0, 0, 0)
local vector4=Vector3["new"](0, 0, 0)
local character3=localPlayer["Character"]
local conditionMet13=character3 and character3:GetAttribute("special")==true
local currentValue11=items14[2]or 150
local spearaimbot=settings["SpearAimbot"]and settings["SpearAimbot"]["Gravity"]or 98
local currentValue12=spearaimbot
if spearaimbot==98 then
currentValue12=conditionMet13 and specialSpearGravity or normalSpearGravity
end
local currentValue13, currentValue14=calculateValue(vector2, currentValue10, vector3, vector4, currentValue11, currentValue12)
if currentValue13 then
items14[1]=currentValue13
end
end
end
end
if settings["FakeLag"]and not currentValue7()then
local fakelagms=math["clamp"](settings["FakeLagMs"]or 200, 50, 1000)table["insert"](items13, {["self"]=name2;
["func"]=remoteEvent;
["args"]=items14, ["sendTime"]=tick()+(fakelagms/1000)})conditionMet12=true cachedValue11=nil
return
end
conditionMet12=true cachedValue11=remoteEvent(name2, unpack(items14))
return
end
if name2["Name"]=="Fire"then
local name3=name2["Parent"]
if name3 and name3["Name"]=="Twist of Fate"then
if settings["RevolverSilentAim"]and(settings["RevolverSilentAim"]["Enabled"]and isFeatureAvailable())then
if featureAvailability and featureAvailability["RevolverSilentAim"]then
pcall(featureAvailability["RevolverSilentAim"], items14)
end
conditionMet12=true cachedValue11=remoteEvent(name2, unpack(items14))
return
end
end
end
if settings["FakeLag"]and not currentValue7()then
local fakelagms=math["clamp"](settings["FakeLagMs"]or 200, 50, 1000)table["insert"](items13, {["self"]=name2;
["func"]=remoteEvent, ["args"]=items14, ["sendTime"]=tick()+(fakelagms/1000)})conditionMet12=true cachedValue11=nil
return
end
end
end
end
)
if not success2 then
return currentValue6(name2, ...)
end
if conditionMet12 then
return cachedValue11
end
return currentValue6(name2, ...)
end
))
end
)do
local cachedValue11=nil
local function processValue6(value)
local timestamp2=tick()
if timestamp2-cachedValue11<1 then
return
end
cachedValue11=timestamp2 _G["VD_LastDodgeTime"]=timestamp2
if _G["VD_TriggerDodgeChangeGen"]then
local success2, result=pcall(_G["VD_TriggerDodgeChangeGen"])
if success2 and result then
showNotification("Spear Dodge", "Veil threw a spear! Switched to another generator.", "warning")
else
showNotification("Spear Dodge", "Veil threw a spear! Fleeing to safe location.", "warning")
end
end
end
_G["VD_PreemptiveDodge"]=function()
local timestamp2=tick()
if timestamp2-runtimeEnabled<1 then
return
end
runtimeEnabled=timestamp2 cachedValue11=timestamp2 processValue6("Preemptive throw animation detected")
end
local function readStateValue3()processValue6("Spear projectile detected")
end
local function readStateValue4()
if not settings["AutoDodgeVeilSpear"]then
return false
end
if not settings["AutoFarmSurvivor"]then
return false
end
local name2=localPlayer["Team"]
if not name2 or name2["Name"]~="Survivors"then
return false
end
local character2=localPlayer["Character"]
if not character2 then
return false
end
local isHooked=getObjectValue(character2, "Knocked")==true or character2:GetAttribute("Knocked")==true
local isHooked2=getObjectValue(character2, "IsHooked")==true or character2:GetAttribute("IsHooked")==true
if isHooked or isHooked2 then
return false
end
return true
end
local function findRootPart2(value)
local instance3=value
while instance3 and instance3~=workspace do
if instance3:IsA("Model")and Players:GetPlayerFromCharacter(instance3)then
return true
end
instance3=instance3["Parent"]
end
return false
end
local items14={}
local function findRootPart3(instance3)
if not instance3 then
return
end
local currentValue6=instance3:IsA("BasePart")or instance3:IsA("Model")
if not currentValue6 then
return
end
if settings["DodgeDebugMode"]then
local character2=localPlayer["Character"]and localPlayer["Character"]:FindFirstChild("HumanoidRootPart")
local rootPart="Unknown"
if character2 then
local success2, result=pcall(function()
local currentValue7=instance3:IsA("Model")and(instance3:GetPivot())["Position"]or instance3["Position"]
return((currentValue7-character2["Position"]))["Magnitude"]
end
)
if success2 and result then
rootPart=string["format"]("%.1f studs", result)
end
end
end
local name2=instance3["Name"]:lower()
if((name2:find("spear")or name2:find("projectile")))and not findRootPart2(instance3)then
table["insert"](items14, instance3)pcall(function()
local character2=localPlayer["Character"]
local part=character2 and((character2:FindFirstChild("Head")or character2:FindFirstChild("HumanoidRootPart")))
local frame4=instance3:IsA("Model")and(instance3:GetPivot())["Position"]or instance3["Position"]
if part and((frame4-part["Position"]))["Magnitude"]<10 then
local transform=part["CFrame"]:PointToObjectSpace(frame4)task["spawn"](function()task["wait"](.015)
if not instance3 or not instance3["Parent"]then
return
end
local currentValue7=instance3:IsA("Model")and(instance3:GetPivot())["Position"]or instance3["Position"]
local currentValue8=((currentValue7-frame4))/.015
local camera=workspace["CurrentCamera"]
if camera then
local transform2=math["acos"](math["clamp"](currentValue8["Unit"]:Dot(camera["CFrame"]["LookVector"]), -1, 1))*((180/math["pi"]))
end
end
)
end
end
)
local conditionMet12=false
local character2=localPlayer["Character"]
if character2 and character2:GetAttribute("special")==true then
conditionMet12=true
end
task["spawn"](function()task["wait"](.02)
if not instance3 or not instance3["Parent"]then
return
end
local currentValue7=instance3:IsA("Model")and(instance3:GetPivot())["Position"]or instance3["Position"]
local timestamp2=tick()task["wait"](.04)
if not instance3 or not instance3["Parent"]then
return
end
local currentValue8=instance3:IsA("Model")and(instance3:GetPivot())["Position"]or instance3["Position"]
local timestamp3=tick()task["wait"](.04)
if not instance3 or not instance3["Parent"]then
return
end
local currentValue9=instance3:IsA("Model")and(instance3:GetPivot())["Position"]or instance3["Position"]
local timestamp4=tick()
local distance=timestamp3-timestamp2
local currentValue10=timestamp4-timestamp3
if distance>.001 and currentValue10>.001 then
local distance2=((currentValue8-currentValue7))/distance
local currentValue11=((currentValue9-currentValue8))/currentValue10
local currentValue12=((currentValue11-distance2))/distance
local distance3=distance2["Magnitude"]
local distance4=.25
if distance3>40 and distance3<300 then
if conditionMet12 then
if distance3>155 then
specialSpearSpeed=specialSpearSpeed*((1-distance4))+distance3*distance4
end
else
if distance3>100 then
normalSpearSpeed=normalSpearSpeed*((1-distance4))+distance3*distance4
end
end
end
local currentValue13=workspace["Gravity"]/2 normalSpearGravity=currentValue13 specialSpearGravity=currentValue13
end
end
)
if readStateValue4()then
local character3=localPlayer["Character"]and localPlayer["Character"]:FindFirstChild("HumanoidRootPart")
if character3 then
local success2, result=pcall(function()
local currentValue7=instance3:IsA("Model")and(instance3:GetPivot())["Position"]or instance3["Position"]
return((currentValue7-character3["Position"]))["Magnitude"]
end
)
if success2 and(result and result<120)then
readStateValue3()
end
end
end
end
if settings["NoStun"]then
local teamName=localPlayer["Team"]
local isMatchingTeam=teamName and teamName["Name"]=="Killer"
if not teamName then
isMatchingTeam=(localPlayer["Name"]:lower()):find("killer")~=nil
end
if isMatchingTeam and name2:find("stun")then
local character2=localPlayer["Character"]and localPlayer["Character"]:FindFirstChild("HumanoidRootPart")
if character2 then
local success2, result=pcall(function()
local currentValue7=instance3:IsA("Model")and(instance3:GetPivot())["Position"]or instance3["Position"]
return((currentValue7-character2["Position"]))["Magnitude"]
end
)
if success2 and(result and result<12)then
pcall(function()instance3:Destroy()
end
)
end
end
end
end
end
registerConnection(workspace["DescendantAdded"]:Connect(function(instance3)
if not activeLoop or not readStateValue4()then
return
end
if((instance3:IsA("BasePart")or instance3:IsA("Model")))and not findRootPart2(instance3)then
local name2=instance3["Name"]:lower()
if name2:find("spear")or name2:find("projectile")then
table["insert"](items14, instance3)
local character2=localPlayer["Character"]and localPlayer["Character"]:FindFirstChild("HumanoidRootPart")
if character2 then
local success2, result=pcall(function()
local currentValue6=instance3:IsA("Model")and(instance3:GetPivot())["Position"]or instance3["Position"]
return((currentValue6-character2["Position"]))["Magnitude"]
end
)
if success2 and(result and result<150)then
processValue6("DescendantAdded spear within "..(tostring(math["floor"](result)).." studs"))
end
end
end
end
pcall(findRootPart3, instance3)
end
))registerConnection(workspace["DescendantRemoving"]:Connect(function(value)
if not activeLoop or not readStateValue4()then
return
end
local itemIndex=table["find"](items14, value)
if itemIndex then
table["remove"](items14, itemIndex)
end
end
))
local connection6 connection6=RunService["Heartbeat"]:Connect(function()
if not activeLoop then
if connection6 then
connection6:Disconnect()
end
return
end
if not readStateValue4()or#items14==0 then
return
end
local character2=localPlayer["Character"]and localPlayer["Character"]:FindFirstChild("HumanoidRootPart")
if not character2 then
return
end
for index, instance3 in ipairs(items14)do
if instance3 and instance3["Parent"]then
local success2, result=pcall(function()
local currentValue6=instance3:IsA("Model")and(instance3:GetPivot())["Position"]or instance3["Position"]
return((currentValue6-character2["Position"]))["Magnitude"]
end
)
if success2 and(result and result<60)then
processValue6("Heartbeat spear within "..(tostring(math["floor"](result)).." studs"))
break
end
end
end
end
)registerConnection(connection6)
local color2={["Cyan"]=Color3["fromRGB"](0, 240, 255);
["Red"]=Color3["fromRGB"](255, 50, 50), ["Green"]=Color3["fromRGB"](50, 255, 50), ["Yellow"]=Color3["fromRGB"](255, 255, 50), ["Purple"]=Color3["fromRGB"](170, 80, 255);
["Orange"]=Color3["fromRGB"](255, 125, 0);
["Pink"]=Color3["fromRGB"](255, 100, 200), ["White"]=Color3["fromRGB"](255, 255, 255)}
local items15={}
local numericValue4=120
local cachedValue12=nil
local part=nil
local highlight=nil
local highlight2=nil
local function players(value)
for index, player in ipairs((game:GetService("Players")):GetPlayers())do
if player["Character"]and value:IsDescendantOf(player["Character"])then
return player
end
end
return nil
end
local function cleanupResources4()cachedValue12=workspace:FindFirstChild("VD_SpearTrajectory")
if cachedValue12 then
pcall(function()cachedValue12:Destroy()
end
)
end
cachedValue12=Instance["new"]("Folder")cachedValue12["Name"]="VD_SpearTrajectory"cachedValue12["Archivable"]=false cachedValue12["Parent"]=workspace items15={}
for key=1, numericValue4, 1 do
local part2=Instance["new"]("Part")part2["Size"]=Vector3["new"](.08, .08, 1)part2["Transparency"]=1 part2["Anchored"]=true part2["CanCollide"]=false part2["CanTouch"]=false part2["CanQuery"]=false part2["CastShadow"]=false part2["Parent"]=cachedValue12
local boxHandleAdornment=Instance["new"]("BoxHandleAdornment")boxHandleAdornment["Name"]="Adorn"boxHandleAdornment["AlwaysOnTop"]=true boxHandleAdornment["Transparency"]=1 boxHandleAdornment["Color3"]=color2[settings["SpearTrajectoryColor"]]or Color3["fromRGB"](0, 240, 255)boxHandleAdornment["Adornee"]=part2 boxHandleAdornment["Parent"]=part2 table["insert"](items15, part2)
end
part=Instance["new"]("Part")part["Size"]=Vector3["new"](.1, .1, .1)part["Transparency"]=1 part["Anchored"]=true part["CanCollide"]=false part["CanTouch"]=false part["CanQuery"]=false part["CastShadow"]=false part["Parent"]=cachedValue12 highlight=Instance["new"]("SphereHandleAdornment")highlight["Name"]="Adorn"highlight["Radius"]=.5 highlight["AlwaysOnTop"]=true highlight["Transparency"]=1 highlight["Color3"]=color2[settings["SpearTrajectoryColor"]]or Color3["fromRGB"](0, 240, 255)highlight["Adornee"]=part highlight["Parent"]=part highlight2=Instance["new"]("SphereHandleAdornment")highlight2["Name"]="AimbotLockAdorn"highlight2["Radius"]=1.2 highlight2["AlwaysOnTop"]=true highlight2["Transparency"]=1 highlight2["Color3"]=Color3["fromRGB"](255, 125, 0)highlight2["Parent"]=cachedValue12
end
pcall(cleanupResources4)
local function processValue7(name2, contextValue, contextValue2, contextValue3)
local screenGui2=Instance["new"]("ScreenGui")screenGui2["Name"]=name2.."_Gui"screenGui2["DisplayOrder"]=99999 screenGui2["ResetOnSpawn"]=false screenGui2["IgnoreGuiInset"]=true
local hasParent=(type(gethui)=="function"and gethui())or guiParent or billboardParent screenGui2["Parent"]=hasParent
local frame4=Instance["new"]("Frame")frame4["Name"]="FOVCircle"frame4["BackgroundTransparency"]=1 frame4["AnchorPoint"]=Vector2["new"](.5, .5)frame4["Position"]=UDim2["new"](.5, 0, .5, 0)frame4["Size"]=UDim2["new"](0, contextValue2*2, 0, contextValue2*2)frame4["Visible"]=contextValue frame4["Parent"]=screenGui2
local stroke3=Instance["new"]("UIStroke")stroke3["Thickness"]=1.5 stroke3["Color"]=contextValue3 stroke3["Transparency"]=.15 stroke3["Parent"]=frame4
local corner2=Instance["new"]("UICorner")corner2["CornerRadius"]=UDim["new"](1, 0)corner2["Parent"]=frame4
local items16={}
local currentValue6=contextValue
local currentValue7=contextValue2
local currentValue8=contextValue3
local currentValue9=.85
local currentValue10=1.5 setmetatable(items16, {["__index"]=function(value, contextValue4)
if contextValue4=="Visible"then
return currentValue6
elseif contextValue4=="Radius"then
return currentValue7
elseif contextValue4=="Color"then
return currentValue8
elseif contextValue4=="Transparency"then
return currentValue9
elseif contextValue4=="Thickness"then
return currentValue10
end
end
, ["__newindex"]=function(value, position, contextValue4)
if position=="Visible"then
currentValue6=contextValue4 frame4["Visible"]=contextValue4
elseif position=="Radius"then
currentValue7=contextValue4 frame4["Size"]=UDim2["new"](0, contextValue4*2, 0, contextValue4*2)
elseif position=="Color"then
currentValue8=contextValue4 stroke3["Color"]=contextValue4
elseif position=="Transparency"then
currentValue9=contextValue4 stroke3["Transparency"]=1-contextValue4
elseif position=="Thickness"then
currentValue10=contextValue4 stroke3["Thickness"]=contextValue4
elseif position=="Position"then
frame4["Position"]=UDim2["new"](0, contextValue4["X"], 0, contextValue4["Y"])
end
end
})function items16.Remove(value)pcall(function()screenGui2:Destroy()
end
)
end
function items16.destroy(value)pcall(function()screenGui2:Destroy()
end
)
end
return items16
end
pcall(function()pcall(function()
if _G["VD_SpearSilentAimFOVCircle"]then
_G["VD_SpearSilentAimFOVCircle"]["Visible"]=false _G["VD_SpearSilentAimFOVCircle"]:Remove()_G["VD_SpearSilentAimFOVCircle"]=nil
end
end
)
local color3={["Cyan"]=Color3["fromRGB"](0, 240, 255), ["Red"]=Color3["fromRGB"](255, 50, 50), ["Green"]=Color3["fromRGB"](50, 255, 50);
["Yellow"]=Color3["fromRGB"](255, 255, 50);
["Purple"]=Color3["fromRGB"](170, 80, 255);
["Orange"]=Color3["fromRGB"](255, 125, 0), ["Pink"]=Color3["fromRGB"](255, 100, 200);
["White"]=Color3["fromRGB"](255, 255, 255)}
local function getFeatureState7()
local spearsilentaim=(settings["SpearSilentAim"]and(settings["SpearSilentAim"]["Enabled"]and settings["SpearSilentAim"]["ShowFOV"]))or false
local spearsilentaim2=(settings["SpearSilentAim"]and settings["SpearSilentAim"]["FOVRadius"])or 240
local spearsilentaim3=settings["SpearSilentAim"]and settings["SpearSilentAim"]["FOVColor"]or"Yellow"
local color4=color3[spearsilentaim3]or Color3["fromRGB"](255, 255, 50)
return processValue7("VD_SpearSilentAimFOV", spearsilentaim, spearsilentaim2, color4)
end
_G["VD_SpearSilentAimFOVCircle"]=getFeatureState7()registerConnection(RunService["RenderStepped"]:Connect(function()pcall(function()
if not _G["VD_SpearSilentAimFOVCircle"]then
_G["VD_SpearSilentAimFOVCircle"]=getFeatureState7()
end
local camera=workspace["CurrentCamera"]
local currentValue6=camera and camera["ViewportSize"]or Vector2["new"](800, 600)_G["VD_SpearSilentAimFOVCircle"]["Position"]=Vector2["new"](currentValue6["X"]/2, currentValue6["Y"]/2)_G["VD_SpearSilentAimFOVCircle"]["Visible"]=(settings["SpearSilentAim"]and(settings["SpearSilentAim"]["Enabled"]and(settings["SpearSilentAim"]["ShowFOV"]and camera~=nil)))or false _G["VD_SpearSilentAimFOVCircle"]["Radius"]=(settings["SpearSilentAim"]and settings["SpearSilentAim"]["FOVRadius"])or 240
local spearsilentaim=settings["SpearSilentAim"]and settings["SpearSilentAim"]["FOVColor"]or"Yellow"_G["VD_SpearSilentAimFOVCircle"]["Color"]=color3[spearsilentaim]or Color3["fromRGB"](255, 255, 50)
end
)
end
))
end
)pcall(function()pcall(function()
if _G["VD_RevolverSilentAimFOVCircle"]then
_G["VD_RevolverSilentAimFOVCircle"]["Visible"]=false _G["VD_RevolverSilentAimFOVCircle"]:Remove()_G["VD_RevolverSilentAimFOVCircle"]=nil
end
end
)
local color3={["Cyan"]=Color3["fromRGB"](0, 240, 255);
["Red"]=Color3["fromRGB"](255, 50, 50);
["Green"]=Color3["fromRGB"](50, 255, 50), ["Yellow"]=Color3["fromRGB"](255, 255, 50);
["Purple"]=Color3["fromRGB"](170, 80, 255), ["Orange"]=Color3["fromRGB"](255, 125, 0);
["Pink"]=Color3["fromRGB"](255, 100, 200), ["White"]=Color3["fromRGB"](255, 255, 255)}
local function getFeatureState7()
local revolversilentaim=(settings["RevolverSilentAim"]and(settings["RevolverSilentAim"]["Enabled"]and settings["RevolverSilentAim"]["ShowFOV"]))or false
local revolversilentaim2=(settings["RevolverSilentAim"]and settings["RevolverSilentAim"]["FOVRadius"])or 200
local revolversilentaim3=settings["RevolverSilentAim"]and settings["RevolverSilentAim"]["FOVColor"]or"Cyan"
local color4=color3[revolversilentaim3]or Color3["fromRGB"](0, 240, 255)
return processValue7("VD_RevolverSilentAimFOV", revolversilentaim, revolversilentaim2, color4)
end
_G["VD_RevolverSilentAimFOVCircle"]=getFeatureState7()registerConnection(RunService["RenderStepped"]:Connect(function()pcall(function()
if not _G["VD_RevolverSilentAimFOVCircle"]then
_G["VD_RevolverSilentAimFOVCircle"]=getFeatureState7()
end
local camera=workspace["CurrentCamera"]
local currentValue6=camera and camera["ViewportSize"]or Vector2["new"](800, 600)_G["VD_RevolverSilentAimFOVCircle"]["Position"]=Vector2["new"](currentValue6["X"]/2, currentValue6["Y"]/2)_G["VD_RevolverSilentAimFOVCircle"]["Visible"]=(settings["RevolverSilentAim"]and(settings["RevolverSilentAim"]["Enabled"]and(settings["RevolverSilentAim"]["ShowFOV"]and camera~=nil)))or false _G["VD_RevolverSilentAimFOVCircle"]["Radius"]=(settings["RevolverSilentAim"]and settings["RevolverSilentAim"]["FOVRadius"])or 200
local revolversilentaim=settings["RevolverSilentAim"]and settings["RevolverSilentAim"]["FOVColor"]or"Cyan"_G["VD_RevolverSilentAimFOVCircle"]["Color"]=color3[revolversilentaim]or Color3["fromRGB"](0, 240, 255)
end
)
end
))
end
)
local function findRootPart4()
if not((settings["SpearTrajectory"]and isFeatureAvailable()))then
return false
end
local character2=localPlayer["Character"]
if character2 and character2:GetAttribute("spearmode")==true then
return true
end
if localPlayer:GetAttribute("spearmode")==true then
return true
end
return false
end
local function camera()
local camera2=workspace["CurrentCamera"]
if not camera2 then
return nil, nil
end
local character2=localPlayer["Character"]
local part2=character2 and((character2:FindFirstChild("Head")or character2:FindFirstChild("HumanoidRootPart")))
if not part2 then
return nil, nil
end
local vector2=Vector3["new"](1.35, .34, -2.51)
local transform=part2["CFrame"]:PointToWorldSpace(vector2)
local numericValue5=500
local raycastParams=RaycastParams["new"]()raycastParams["FilterType"]=Enum["RaycastFilterType"]["Exclude"]
local items16={character2}
if cachedValue12 then
table["insert"](items16, cachedValue12)
end
raycastParams["FilterDescendantsInstances"]=items16
local raycastResult=workspace:Raycast(camera2["CFrame"]["Position"], camera2["CFrame"]["LookVector"]*numericValue5, raycastParams)
local transform2=raycastResult and raycastResult["Position"]or(camera2["CFrame"]["Position"]+camera2["CFrame"]["LookVector"]*numericValue5)
local transform3=camera2["CFrame"]["LookVector"]
if((transform2-transform))["Magnitude"]>3 then
local frame4=((transform2-transform))["Unit"]
if frame4:Dot(camera2["CFrame"]["LookVector"])>.5 then
transform3=frame4
end
end
return transform, transform3
end
local function getFeatureState7(part2)
if not part2 then
return false
end
for index, player in ipairs((game:GetService("Players")):GetPlayers())do
if player~=localPlayer and(player["Character"]and part2:IsDescendantOf(player["Character"]))then
return true
end
end
if settings["SpearTrajectoryNoclip"]and isFeatureAvailable()then
return false
end
if not part2["CanCollide"]then
return false
end
if part2:IsA("BasePart")then
if part2["Transparency"]>=.95 or part2["Name"]=="inviswall"or part2["Name"]=="inviswall1"then
local name2=part2["Name"]:lower()
if name2:find("invis")or name2:find("clip")or name2:find("barrier")or name2:find("trigger")or name2:find("border")or name2:find("zone")or name2=="part"or name2=="block"then
return false
end
end
end
return true
end
local function processValue8(value, contextValue, contextValue2, contextValue3, contextValue4)
local items16={value}
local currentValue6=value
local currentValue7=contextValue*contextValue2
local currentValue8=.02
local numericValue5=120
local raycastParams=RaycastParams["new"]()
if contextValue4 then
local items17={}
for index, player in ipairs((game:GetService("Players")):GetPlayers())do
if player~=localPlayer and player["Character"]then
table["insert"](items17, player["Character"])
end
end
raycastParams["FilterType"]=Enum["RaycastFilterType"]["Include"]raycastParams["FilterDescendantsInstances"]=items17
else
raycastParams["FilterType"]=Enum["RaycastFilterType"]["Exclude"]
local character2={localPlayer["Character"]}
if cachedValue12 then
table["insert"](character2, cachedValue12)
end
raycastParams["FilterDescendantsInstances"]=character2
end
local startPosition4=nil
for key=1, numericValue5, 1 do
local distance=(currentValue6+currentValue7*currentValue8)+((.5*contextValue3)*currentValue8)*currentValue8
local currentValue9=currentValue7+contextValue3*currentValue8
local distance2=((distance-value))["Magnitude"]
if distance2>4 then
local distance3=currentValue6
local distance4=distance-currentValue6
while true do
local raycastResult=workspace:Raycast(distance3, distance4, raycastParams)
if raycastResult then
local currentValue10=raycastResult["Instance"]
if getFeatureState7(currentValue10)then
table["insert"](items16, raycastResult["Position"])startPosition4=raycastResult
break
else
local currentValue11=raycastParams["FilterDescendantsInstances"]table["insert"](currentValue11, currentValue10)raycastParams["FilterDescendantsInstances"]=currentValue11 distance3=raycastResult["Position"]+distance4["Unit"]*.01 distance4=distance-distance3
if distance4["Magnitude"]<=.05 then
break
end
end
else
break
end
end
if startPosition4 then
break
end
end
table["insert"](items16, distance)currentValue6=distance currentValue7=currentValue9
end
return items16, startPosition4
end
local function getFeatureState8()
if not cachedValue12 then
return
end
for index, instance3 in ipairs(items15)do
local adorn=instance3:FindFirstChild("Adorn")
if adorn then
adorn["Transparency"]=1
end
end
if highlight then
highlight["Transparency"]=1
end
if highlight2 then
highlight2["Adornee"]=nil highlight2["Transparency"]=1
end
end
local conditionMet12=false
local connection7 connection7=RunService["RenderStepped"]:Connect(function()
if not activeLoop or not((settings["SpearTrajectory"]and isFeatureAvailable()))then
getFeatureState8()
return
end
if not cachedValue12 or cachedValue12["Parent"]==nil then
pcall(cleanupResources4)
end
local currentValue6=findRootPart4()
if currentValue6 and not conditionMet12 then
lastUpdateTime=tick()
end
conditionMet12=currentValue6
local currentValue7, currentValue8=nil, nil
if currentValue6 then
local frame4, player=camera()
if settings["SpearAimbot"]and(settings["SpearAimbot"]["Enabled"]and(cachedValue10 and isFeatureAvailable()))then
pcall(function()
local instance3=cachedValue10["Parent"]
local rootPart=instance3:FindFirstChild("HumanoidRootPart")or instance3["PrimaryPart"]or instance3:FindFirstChild("Torso")
local character2=localPlayer["Character"]and((localPlayer["Character"]:FindFirstChild("Head")or localPlayer["Character"]:FindFirstChild("HumanoidRootPart")))
if rootPart and character2 then
local vector2=frame4 or character2["CFrame"]:PointToWorldSpace(Vector3["new"](1.35, .34, -2.51))
local currentValue9=cachedValue10["Position"]
local vector3=Vector3["new"](0, 0, 0)
local vector4=Vector3["new"](0, 0, 0)
local character3=localPlayer["Character"]
local conditionMet13=character3 and character3:GetAttribute("special")==true
local spearaimbot=settings["SpearAimbot"]["Speed"]or 150
local speed=spearaimbot
if spearaimbot==150 then
speed=conditionMet13 and specialSpearSpeed or normalSpearSpeed
elseif conditionMet13 then
speed=spearaimbot*(1.1333333333333)
end
local timestamp2=tick()-lastUpdateTime
local clampedValue=math["clamp"](timestamp2/1, 0, 1)
local currentValue10=speed*.7333
local currentValue11=currentValue10+((speed-currentValue10))*clampedValue
local spearaimbot2=settings["SpearAimbot"]["Gravity"]or 98
local currentValue12=spearaimbot2
if spearaimbot2==98 then
currentValue12=conditionMet13 and specialSpearGravity or normalSpearGravity
end
local currentValue13, currentValue14=calculateValue(vector2, currentValue9, vector3, vector4, currentValue11, currentValue12)
if currentValue13 then
player=currentValue13
if hasExecutorRestriction then
pcall(function()
local camera2=workspace["CurrentCamera"]
if camera2 then
camera2["CFrame"]=CFrame["new"](camera2["CFrame"]["Position"], camera2["CFrame"]["Position"]+currentValue13)
end
end
)
end
end
end
end
)
end
if frame4 and player then
local character2=localPlayer["Character"]
local conditionMet13=character2 and character2:GetAttribute("special")==true
local spearaimbot=settings["SpearAimbot"]["Speed"]or 150
local spearaimbot2=settings["SpearAimbot"]["Gravity"]or 98
local currentValue9=spearaimbot
local currentValue10=spearaimbot2
if spearaimbot==150 then
currentValue9=conditionMet13 and specialSpearSpeed or normalSpearSpeed
elseif conditionMet13 then
currentValue9=spearaimbot*(1.1333333333333)
end
if spearaimbot2==98 then
currentValue10=conditionMet13 and specialSpearGravity or normalSpearGravity
elseif conditionMet13 then
currentValue10=spearaimbot2
end
local timestamp2=tick()-lastUpdateTime
local clampedValue=math["clamp"](timestamp2/1, 0, 1)
local currentValue11=currentValue9*.7333
local vector2=currentValue11+((currentValue9-currentValue11))*clampedValue currentValue7, currentValue8=processValue8(frame4, player, vector2, Vector3["new"](0, -currentValue10, 0), conditionMet13)
end
end
if currentValue7 and#currentValue7>1 then
local count=#currentValue7
local conditionMet13=false
if currentValue8 and currentValue8["Instance"]then
local player=players(currentValue8["Instance"])
if player and player~=localPlayer then
conditionMet13=true
end
end
for key=1, numericValue4, 1 do
local part2=items15[key]
if part2 then
local adorn=part2:FindFirstChild("Adorn")
if key<count then
local distance=currentValue7[key]
local distance2=currentValue7[key+1]
local vector2=((distance2-distance))["Magnitude"]part2["Size"]=Vector3["new"](.08, .08, vector2)part2["CFrame"]=CFrame["lookAt"](((distance+distance2))/2, distance2)
if adorn then
adorn["Size"]=Vector3["new"](.08, .08, vector2)adorn["Transparency"]=.35
local speartrajectorycolor=color2[settings["SpearTrajectoryColor"]]or Color3["fromRGB"](0, 240, 255)adorn["Color3"]=conditionMet13 and Color3["fromRGB"](0, 255, 0)or speartrajectorycolor
end
else
if adorn then
adorn["Transparency"]=1
end
end
end
end
if part and highlight then
local currentValue9=currentValue7[count]part["Position"]=currentValue9
if currentValue8 then
highlight["Transparency"]=.25
local speartrajectorycolor=color2[settings["SpearTrajectoryColor"]]or Color3["fromRGB"](0, 240, 255)highlight["Color3"]=conditionMet13 and Color3["fromRGB"](0, 255, 0)or speartrajectorycolor
else
highlight["Transparency"]=1
end
end
if highlight2 then
if cachedValue10 and cachedValue10["Parent"]then
highlight2["Adornee"]=cachedValue10 highlight2["Transparency"]=.45
else
highlight2["Adornee"]=nil highlight2["Transparency"]=1
end
end
else
getFeatureState8()
end
end
)registerConnection(connection7)
end
do
local cachedValue11=nil
local cachedValue12=nil
local connection6=nil
local function character2()pcall(function()
local character3=localPlayer["Character"]
if not character3 then
return
end
local humanoid=character3:FindFirstChildOfClass("Humanoid")
local rootPart=character3:FindFirstChild("HumanoidRootPart")
if not rootPart then
return
end
local conditionMet12=false
for index, instance3 in ipairs(character3:GetDescendants())do
if instance3:IsA("BasePart")and instance3["Anchored"]then
conditionMet12=true instance3["Anchored"]=false
end
end
if conditionMet12 then
end
if humanoid then
if humanoid["PlatformStand"]then
humanoid["PlatformStand"]=false
end
if humanoid["WalkSpeed"]<1 then
humanoid["WalkSpeed"]=16
end
end
end
)
end
local function processValue6()
if connection6 then
task["cancel"](connection6)connection6=nil
end
local teamName=localPlayer["Team"]
local isMatchingTeam=teamName and((teamName["Name"]=="Survivors"or teamName["Name"]=="Killer"))
if not isMatchingTeam then
return
end
connection6=task["delay"](22, function()character2()connection6=nil
end
)
end
registerConnection((localPlayer:GetPropertyChangedSignal("Team")):Connect(function()pcall(processValue6)
end
))registerConnection(localPlayer["CharacterAdded"]:Connect(function()task["wait"](.5)pcall(processValue6)
end
))task["defer"](function()pcall(processValue6)
end
)
end
task["spawn"](function()
local function processValue6(instance3)
if not instance3 or not instance3:IsA("GuiButton")then
return
end
pcall(function()instance3["Active"]=true instance3["ZIndex"]=10
for index, instance4 in ipairs(instance3:GetChildren())do
if instance4:IsA("TextLabel")or instance4:IsA("ImageLabel")or instance4:IsA("Frame")then
instance4["Active"]=false instance4["Selectable"]=false
end
end
end
)
end
local function processValue7()
local playergui=localPlayer:WaitForChild("PlayerGui", 10)
if not playergui then
return
end
local function conditionMet12(instance3)
if instance3["Name"]=="action"and instance3:IsA("GuiButton")then
local conditionMet13=false
local name2=instance3["Parent"]
while name2 do
if name2["Name"]=="Survivor-mob"then
conditionMet13=true
break
end
name2=name2["Parent"]
end
if conditionMet13 then
task["wait"](.1)processValue6(instance3)
end
end
end
for index, item in ipairs(playergui:GetDescendants())do
pcall(conditionMet12, item)
end
registerConnection(playergui["DescendantAdded"]:Connect(function(value)pcall(conditionMet12, value)
end
))
end
pcall(processValue7)
end
)task["spawn"](function()
local function processValue6(value)
if not value then
return""
end
return((value:lower()):gsub("[^%a%d]", "")):gsub("excitment", "excitement")
end
local items14={}
local function conditionMet12(value)
if not value or value==""then
return
end
for index, item in ipairs(items14)do
if item["name"]==value then
return
end
end
table["insert"](items14, {["name"]=value;
["clean"]=processValue6(value)})
end
local items15={"All Seeing Eye", "Containment";
"Deep Wound";
"Eyes Of Hell";
"Exposure Therapy";
"King's Scourge", "Murderous Acrobatics", "Stage Fright";
"Echo Location";
"Crackdown";
"Brutal Strength";
"Play With Your Food";
"Predator";
"Eternal Torment"}
for index, item in ipairs(items15)do
conditionMet12(item)
end
pcall(function()
local instance3=game:GetService("ReplicatedStorage")
local killers={instance3:FindFirstChild("Killers");
instance3:FindFirstChild("ShopKillers"), instance3:FindFirstChild("Perks");
instance3:FindFirstChild("KillerPerks")}
for index, instance4 in ipairs(killers)do
if instance4 then
for index2, instance5 in ipairs(instance4:GetChildren())do
if instance4["Name"]=="Perks"or instance4["Name"]=="KillerPerks"then
conditionMet12(instance5["Name"])
else
local perks=instance5:FindFirstChild("Perks")
if perks then
for index3, instance6 in ipairs(perks:GetChildren())do
conditionMet12(instance6["Name"])
end
end
end
end
end
end
end
)
local name2=getMapName
local function players()
for index, player in ipairs((game:GetService("Players")):GetPlayers())do
local conditionMet13=false
local teamName=player["Team"]
if teamName and((teamName["Name"]=="Killer"or(teamName["Name"]:lower()):find("killer")))then
conditionMet13=true
elseif player:GetAttribute("Role")=="Killer"or player:GetAttribute("IsKiller")==true then
conditionMet13=true
elseif player["Character"]and((player["Character"]:GetAttribute("Role")=="Killer"or player["Character"]:GetAttribute("IsKiller")==true))then
conditionMet13=true
end
if conditionMet13 then
return player
end
end
local currentValue6=-1
local cachedValue11=nil
for index, instance3 in ipairs((game:GetService("Players")):GetPlayers())do
local allowkiller=instance3:GetAttribute("AllowKiller")
if allowkiller==true then
local killerchance=instance3:GetAttribute("KillerChance")or 0
if killerchance>currentValue6 then
currentValue6=killerchance cachedValue11=instance3
end
end
end
return cachedValue11
end
local cachedValue11=nil
local cachedValue12=nil
local items16={}
local numericValue4=0
local function processValue7(instance3, contextValue)
local timestamp2=tick()
if(contextValue and contextValue==cachedValue11)or(not contextValue and(instance3 and instance3==cachedValue12))then
if timestamp2-numericValue4<6 then
return items16
end
end
cachedValue11=contextValue cachedValue12=instance3 numericValue4=timestamp2
local items17={}
local function conditionMet13(value)
if not value or value==""then
return
end
local currentValue6=processValue6(value)
for index, item in ipairs(items14)do
if currentValue6==item["clean"]or currentValue6:find(item["clean"], 1, true)then
if not table["find"](items17, item["name"])then
table["insert"](items17, item["name"])
end
end
end
end
if contextValue then
pcall(function()
for index, instance4 in ipairs(contextValue:GetDescendants())do
if not((instance4:IsA("BasePart")or instance4:IsA("JointInstance")or instance4:IsA("Attachment")or instance4:IsA("Constraint")or instance4:IsA("SpecialMesh")or instance4:IsA("WrapTarget")or instance4:IsA("WrapLayer")))then
conditionMet13(instance4["Name"])
if instance4:IsA("ValueObject")and type(instance4["Value"])=="string"then
conditionMet13(instance4["Value"])
end
end
end
for key, item in pairs(contextValue:GetAttributes())do
conditionMet13(key)
end
end
)
end
if instance3 then
pcall(function()
for key, item in pairs(instance3:GetAttributes())do
conditionMet13(key)
end
local equippedperks=instance3:FindFirstChild("EquippedPerks")or instance3:FindFirstChild("Perks")
if equippedperks then
for index, instance4 in ipairs(equippedperks:GetChildren())do
conditionMet13(instance4["Name"])
if instance4:IsA("ValueObject")and type(instance4["Value"])=="string"then
conditionMet13(instance4["Value"])
end
end
end
end
)
end
items16=items17
return items17
end
local frame4=Instance["new"]("Frame")frame4["Name"]="VD_InfoBanner"frame4["Size"]=UDim2["new"](0, 0, 0, 0)frame4["AutomaticSize"]=Enum["AutomaticSize"]["XY"]frame4["Position"]=UDim2["new"](settings["InfoBannerPositionScaleX"]or.5, settings["InfoBannerPositionOffsetX"]or 0, settings["InfoBannerPositionScaleY"]or 0, settings["InfoBannerPositionOffsetY"]or(isMobileDevice and 6 or 10))frame4["AnchorPoint"]=Vector2["new"](.5, 0)frame4["BackgroundColor3"]=UI["Card"]frame4["BackgroundTransparency"]=.2 frame4["BorderSizePixel"]=0 frame4["Visible"]=settings["ShowInfoBanner"]frame4["ZIndex"]=999 frame4["Parent"]=screenGui
local corner2=Instance["new"]("UICorner", frame4)corner2["CornerRadius"]=UDim["new"](0, 8)
local stroke3=Instance["new"]("UIStroke", frame4)stroke3["Color"]=UI["Accent"]stroke3["Thickness"]=1.2 stroke3["Transparency"]=.3
local padding=Instance["new"]("UIPadding", frame4)padding["PaddingLeft"]=UDim["new"](0, isMobileDevice and 12 or 16)padding["PaddingRight"]=UDim["new"](0, isMobileDevice and 12 or 16)padding["PaddingTop"]=UDim["new"](0, isMobileDevice and 8 or 10)padding["PaddingBottom"]=UDim["new"](0, isMobileDevice and 8 or 10)
local label4=Instance["new"]("TextLabel")label4["Size"]=UDim2["new"](0, 0, 0, 0)label4["AutomaticSize"]=Enum["AutomaticSize"]["XY"]label4["BackgroundTransparency"]=1 label4["RichText"]=true label4["Font"]=Enum["Font"]["GothamMedium"]label4["TextSize"]=isMobileDevice and 10.5 or 13 label4["TextColor3"]=Color3["fromRGB"](240, 240, 245)label4["TextXAlignment"]=isMobileDevice and Enum["TextXAlignment"]["Left"]or Enum["TextXAlignment"]["Center"]label4["ZIndex"]=1000 label4["Parent"]=frame4
local conditionMet13=false
local startPosition4=nil
local startPosition5=nil
local currentValue6=nil frame4["InputBegan"]:Connect(function(input)
if input["UserInputType"]==Enum["UserInputType"]["Touch"]or input["UserInputType"]==Enum["UserInputType"]["MouseButton1"]then
conditionMet13=true startPosition4=input["Position"]startPosition5=frame4["Position"]currentValue6=input
end
end
)frame4["InputChanged"]:Connect(function(input)
if conditionMet13 and((input["UserInputType"]==Enum["UserInputType"]["Touch"]or input["UserInputType"]==Enum["UserInputType"]["MouseMovement"]))then
local layoutPosition=input["Position"]-startPosition4 frame4["Position"]=UDim2["new"](startPosition5["X"]["Scale"], startPosition5["X"]["Offset"]+layoutPosition["X"], startPosition5["Y"]["Scale"], startPosition5["Y"]["Offset"]+layoutPosition["Y"])
end
end
)frame4["InputEnded"]:Connect(function(value)
if value==currentValue6 then
conditionMet13=false currentValue6=nil pcall(function()settings["InfoBannerPositionScaleX"]=frame4["Position"]["X"]["Scale"]settings["InfoBannerPositionOffsetX"]=frame4["Position"]["X"]["Offset"]settings["InfoBannerPositionScaleY"]=frame4["Position"]["Y"]["Scale"]settings["InfoBannerPositionOffsetY"]=frame4["Position"]["Y"]["Offset"]saveSettings()
end
)
end
end
)
while activeLoop do
pcall(function()
local showinfobanner=settings["ShowInfoBanner"]and(isFeatureAvailable()and(featureAvailability and(featureAvailability["InfoBanner"]and(featureAvailability and featureAvailability["InfoBanner"]))))
if not showinfobanner then
if frame4["Visible"]then
frame4["Visible"]=false
end
task["wait"](1.5)
return
end
local currentValue7=name2()
if currentValue7=="Unknown Map"then
currentValue7="Lobby / Voting..."
end
local player=players()
local name3="None"
if player then
name3=player:GetAttribute("SelectedKiller")or player["Name"]
end
local name4=player and player["Character"]
if player and not name4 then
name4=workspace:FindFirstChild(player["Name"])
if not name4 then
for index, instance3 in ipairs(workspace:GetChildren())do
if instance3:IsA("Model")then
if instance3:GetAttribute("Role")=="Killer"or instance3:GetAttribute("IsKiller")==true then
name4=instance3
break
end
end
end
end
end
if name4 and((name3=="None"or name3==player["Name"]))then
local name5=name4["Name"]
if name5~=player["Name"]and name5~="Character"then
name3=name5
end
end
local currentValue8=processValue7(player, name4)
local conditionMet14=#currentValue8>0 and table["concat"](currentValue8, ", ")or"None"
local currentValue9=string["format"]("#%02X%02X%02X", math["floor"](UI["Accent"]["R"]*255), math["floor"](UI["Accent"]["G"]*255), math["floor"](UI["Accent"]["B"]*255))
local items17={}
if settings["InfoBannerShowMap"]then
table["insert"](items17, string["format"]("<font color=\"%s\"><b>MAP:</b></font> <font color=\"#FFFFFF\">%s</font>", currentValue9, currentValue7))
end
if settings["InfoBannerShowKiller"]then
table["insert"](items17, string["format"]("<font color=\"%s\"><b>KILLER:</b></font> <font color=\"#FFFFFF\">%s</font>", currentValue9, tostring(name3)))
end
if settings["InfoBannerShowPerks"]then
table["insert"](items17, string["format"]("<font color=\"%s\"><b>PERKS:</b></font> <font color=\"#FFFFFF\">%s</font>", currentValue9, conditionMet14))
end
if settings["InfoBannerShowFPS"]then
local currentValue10=math["floor"](1/(game:GetService("RunService"))["Heartbeat"]:Wait())table["insert"](items17, string["format"]("<font color=\"#A8E6CF\"><b>FPS:</b></font> <font color=\"#FFFFFF\">%d</font>", currentValue10))
end
if settings["InfoBannerShowPing"]then
local currentValue10=(game:GetService("Stats"))["Network"]["ServerStatsItem"]["Data Ping"]:GetValue()table["insert"](items17, string["format"]("<font color=\"#FFD3B6\"><b>PING:</b></font> <font color=\"#FFFFFF\">%dms</font>", math["floor"](currentValue10)))
end
local displayText=""
if#items17==0 then
displayText="<font color=\"#9CA3AF\"><i>Nothing selected</i></font>"
else
if isMobileDevice then
displayText=table["concat"](items17, "\n")
else
displayText=table["concat"](items17, "    |    ")
end
end
label4["Text"]=displayText
if not frame4["Visible"]then
frame4["Visible"]=true
end
end
)task["wait"](1.5)
end
end
)
local function calculateValue2(position)
local currentValue6, currentValue7=math["huge"], math["huge"]
local currentValue8, currentValue9=-math["huge"], -math["huge"]
local visible2=false
for index, container in ipairs(position:GetChildren())do
if container:IsA("GuiObject")and(container["Name"]:find("^Survivor%d+$")and container["Visible"])then
visible2=true
local currentValue10=container["AbsolutePosition"]-position["AbsolutePosition"]
local currentValue11=container["AbsoluteSize"]
local currentValue12=currentValue10["X"]
local currentValue13=currentValue10["Y"]
local currentValue14=currentValue11["X"]
local currentValue15=currentValue11["Y"]
if currentValue12<currentValue6 then
currentValue6=currentValue12
end
if currentValue13<currentValue7 then
currentValue7=currentValue13
end
if currentValue12+currentValue14>currentValue8 then
currentValue8=currentValue12+currentValue14
end
if currentValue13+currentValue15>currentValue9 then
currentValue9=currentValue13+currentValue15
end
end
end
if visible2 and(currentValue8>currentValue6 and currentValue9>currentValue7)then
return UDim2["new"](0, currentValue6, 0, currentValue7), UDim2["new"](0, currentValue8-currentValue6, 0, currentValue9-currentValue7)
end
return nil, nil
end
task["spawn"](function()
while activeLoop do
task["wait"](.5)pcall(function()
local child=localPlayer:FindFirstChildOfClass("PlayerGui")
if not child then
return
end
local items14={}
local items15={}
for index, instance3 in ipairs(child:GetDescendants())do
if instance3:IsA("GuiObject")and instance3["Name"]:find("^Survivor%d+$")then
local currentValue6=instance3["Parent"]
if currentValue6 and not items15[currentValue6]then
items15[currentValue6]=true table["insert"](items14, currentValue6)
end
end
end
for index, container in ipairs(items14)do
local hideliveplayersmode=settings["HideLivePlayersMode"]or"Normal"
if container:GetAttribute("OrigVisible")==nil then
container:SetAttribute("OrigVisible", container["Visible"])
end
local violencedistrictoverlay=container:FindFirstChild("ViolenceDistrictOverlay")
if hideliveplayersmode=="Normal"then
if container["Visible"]~=container:GetAttribute("OrigVisible")then
container["Visible"]=container:GetAttribute("OrigVisible")
end
for index2, container2 in ipairs(container:GetChildren())do
if container2:IsA("GuiObject")and container2["Name"]:find("^Survivor%d+$")then
local origvisible=container2:GetAttribute("OrigVisible")
if origvisible~=nil then
container2["Visible"]=origvisible container2:SetAttribute("OrigVisible", nil)
end
end
end
container:SetAttribute("CachedOverlayPos", nil)container:SetAttribute("CachedOverlaySize", nil)
if violencedistrictoverlay then
violencedistrictoverlay:Destroy()
end
elseif hideliveplayersmode=="Hide"then
if container["Visible"]then
container["Visible"]=false
end
if violencedistrictoverlay then
violencedistrictoverlay:Destroy()
end
elseif hideliveplayersmode=="Overlay (Logo)"or hideliveplayersmode=="Overlay (Custom)"then
local cachedoverlaypos=container:GetAttribute("CachedOverlayPos")
local cachedoverlaysize=container:GetAttribute("CachedOverlaySize")
if not cachedoverlaypos or not cachedoverlaysize then
local currentValue6, currentValue7=calculateValue2(container)
if currentValue6 and currentValue7 then
container:SetAttribute("CachedOverlayPos", currentValue6)container:SetAttribute("CachedOverlaySize", currentValue7)cachedoverlaypos=currentValue6 cachedoverlaysize=currentValue7
end
end
for index2, container2 in ipairs(container:GetChildren())do
if container2:IsA("GuiObject")and container2["Name"]:find("^Survivor%d+$")then
if container2:GetAttribute("OrigVisible")==nil then
container2:SetAttribute("OrigVisible", container2["Visible"])
end
if container2["Visible"]then
container2["Visible"]=false
end
end
end
if not container["Visible"]then
container["Visible"]=true
end
if not violencedistrictoverlay then
violencedistrictoverlay=Instance["new"]("ImageLabel")violencedistrictoverlay["Name"]="ViolenceDistrictOverlay"violencedistrictoverlay["BackgroundTransparency"]=1 violencedistrictoverlay["ZIndex"]=10 violencedistrictoverlay["ScaleType"]=Enum["ScaleType"]["Fit"]violencedistrictoverlay["Parent"]=container
end
if cachedoverlaypos and cachedoverlaysize then
violencedistrictoverlay["Position"]=cachedoverlaypos violencedistrictoverlay["Size"]=cachedoverlaysize
else
violencedistrictoverlay["Position"]=UDim2["new"](0, 0, 0, 0)violencedistrictoverlay["Size"]=UDim2["new"](1, 0, 1, 0)
end
local currentValue6=loadCachedAsset("https://files.catbox.moe/ada7me.png", "VD_Logo.png", "rbxassetid://117820993260221")
if hideliveplayersmode=="Overlay (Custom)"and(settings["CustomOverlayUrl"]and settings["CustomOverlayUrl"]~="")then
currentValue6=settings["CustomOverlayUrl"]
end
if violencedistrictoverlay["Image"]~=currentValue6 then
violencedistrictoverlay["Image"]=currentValue6
end
end
end
pcall(function()
local hideliveplayersmode=settings["HideLivePlayersMode"]or"Normal"
local conditionMet12=(hideliveplayersmode~="Normal")
local instance3=localPlayer and localPlayer:FindFirstChild("PlayerGui")
if instance3 then
local instance4=instance3:FindFirstChild("Spectator")
local instance5=instance4 and instance4:FindFirstChild("Info")
local instance6=instance5 and instance5:FindFirstChild("Your")
if instance6 then
local label4=instance6:FindFirstChild("Username")or instance6:FindFirstChildOfClass("TextLabel")
if conditionMet12 then
if not instance6["Visible"]then
instance6["Visible"]=true
end
if label4 and label4:IsA("TextLabel")then
if label4["Text"]~="Anonymous"then
if not label4:GetAttribute("OrigUsernameText")then
label4:SetAttribute("OrigUsernameText", label4["Text"])
end
label4["Text"]="Anonymous"
end
end
else
if label4 and label4:IsA("TextLabel")then
local origusernametext=label4:GetAttribute("OrigUsernameText")
if origusernametext then
label4["Text"]=origusernametext label4:SetAttribute("OrigUsernameText", nil)
end
end
end
end
end
if screenGui then
local label4=screenGui:FindFirstChild("SidebarDisplayName", true)
local label5=screenGui:FindFirstChild("SidebarUsername", true)
local sidebaravatar=screenGui:FindFirstChild("SidebarAvatar", true)
local label6=screenGui:FindFirstChild("HomeHeaderName", true)
local homeheaderavatar=screenGui:FindFirstChild("HomeHeaderAvatar", true)
local label7=screenGui:FindFirstChild("WelcomeBackLabel", true)
local welcomebackavatar=screenGui:FindFirstChild("WelcomeBackAvatar", true)
local homeplayerscroll=screenGui:FindFirstChild("HomePlayerScroll", true)
if conditionMet12 then
if label4 and label4["Text"]~="Anonymous User"then
label4["Text"]="Anonymous User"
end
if label5 and label5["Text"]~="@Anonymous"then
label5["Text"]="@Anonymous"
end
if sidebaravatar and sidebaravatar["Image"]~="rbxassetid://0"then
sidebaravatar["Image"]="rbxassetid://0"
end
if label7 and label7["Text"]~="Welcome back, Anonymous User!"then
label7["Text"]="Welcome back, Anonymous User!"
end
if welcomebackavatar and welcomebackavatar["Image"]~="rbxassetid://0"then
welcomebackavatar["Image"]="rbxassetid://0"
end
local currentselectedplayer=_G["VD_CurrentSelectedPlayer"]or localPlayer
if currentselectedplayer==localPlayer or(currentselectedplayer and currentselectedplayer["UserId"]==localPlayer["UserId"])then
if label6 and label6["Text"]~="Anonymous User (@Anonymous)"then
label6["Text"]="Anonymous User (@Anonymous)"
end
if homeheaderavatar and homeheaderavatar["Image"]~="rbxassetid://0"then
homeheaderavatar["Image"]="rbxassetid://0"
end
end
if homeplayerscroll then
for index, instance4 in ipairs(homeplayerscroll:GetChildren())do
if instance4:IsA("TextButton")and instance4:GetAttribute("PlayerName")==localPlayer["Name"]then
local label8=instance4:FindFirstChildOfClass("TextLabel")
local child2=instance4:FindFirstChildOfClass("ImageLabel")
if label8 and label8["Text"]~="Anonymous User"then
label8["Text"]="Anonymous User"
end
if child2 and child2["Image"]~="rbxassetid://0"then
child2["Image"]="rbxassetid://0"
end
end
end
end
else
local name2=localPlayer and localPlayer["DisplayName"]or"User"
local name3=localPlayer and localPlayer["Name"]or"User"
if label4 and label4["Text"]~=name2 then
label4["Text"]=name2
end
if label5 and label5["Text"]~=("@"..name3)then
label5["Text"]="@"..name3
end
if label7 and label7["Text"]~=("Welcome back, "..(name2.."!"))then
label7["Text"]="Welcome back, "..(name2.."!")
end
local currentselectedplayer=_G["VD_CurrentSelectedPlayer"]or localPlayer
if currentselectedplayer==localPlayer or(currentselectedplayer and currentselectedplayer["UserId"]==localPlayer["UserId"])then
local text=name2..(" (@"..(name3..")"))
if label6 and label6["Text"]~=text then
label6["Text"]=text
end
if homeheaderavatar then
local player="rbxthumb://type=AvatarHeadShot&id="..(tostring(localPlayer["UserId"]).."&w=150&h=150")
if homeheaderavatar["Image"]~=player then
homeheaderavatar["Image"]=player
end
end
end
if homeplayerscroll then
for index, instance4 in ipairs(homeplayerscroll:GetChildren())do
if instance4:IsA("TextButton")and instance4:GetAttribute("PlayerName")==localPlayer["Name"]then
local label8=instance4:FindFirstChildOfClass("TextLabel")
local child2=instance4:FindFirstChildOfClass("ImageLabel")
if label8 and label8["Text"]~=name2 then
label8["Text"]=name2
end
if child2 and child2["Image"]=="rbxassetid://0"then
child2["Image"]="rbxthumb://type=AvatarHeadShot&id="..(tostring(localPlayer["UserId"]).."&w=150&h=150")
end
end
end
end
end
end
end
)
end
)
end
end
)
local function getFeatureState7()
if not activeLoop then
return
end
pcall(function()
local camera=workspace["CurrentCamera"]
if not camera then
return
end
local items14={["Normal"]={1;
1}, ["4:3"]={1, .75};
["5:4"]={1;
.703125}, ["16:10"]={1;
.9}, ["21:9"]={.76190476190476;
1}}
local stretchedresolutionmode=settings["StretchedResolutionMode"]or"Normal"
local currentValue6=items14[stretchedresolutionmode]or{1, 1}
local currentValue7, currentValue8=currentValue6[1], currentValue6[2]
local conditionMet12=(settings["FOV"]>120)or(currentValue7~=1)or(currentValue8~=1)
if not conditionMet12 then
if camera["FieldOfView"]~=settings["FOV"]then
camera["FieldOfView"]=settings["FOV"]
end
local transform=camera["CFrame"]
if transform["X"]~=transform["X"]or transform["Y"]~=transform["Y"]or transform["Z"]~=transform["Z"]then
return
end
if transform["RightVector"]["Magnitude"]<.01 or transform["UpVector"]["Magnitude"]<.01 then
return
end
if transform["RightVector"]["Magnitude"]>1.001 or transform["RightVector"]["Magnitude"]<.999 or transform["UpVector"]["Magnitude"]>1.001 or transform["UpVector"]["Magnitude"]<.999 then
camera["CFrame"]=CFrame["fromMatrix"](transform["Position"], transform["RightVector"], transform["UpVector"])
end
else
local fov=math["min"](settings["FOV"], 120)
if camera["FieldOfView"]~=fov then
camera["FieldOfView"]=fov
end
local numericValue4=1
if settings["FOV"]>120 then
local fov2=math["rad"](settings["FOV"]/2)
local currentValue9=math["rad"](fov/2)numericValue4=math["tan"](currentValue9)/math["tan"](fov2)
end
local transform=camera["CFrame"]
if transform["X"]~=transform["X"]or transform["Y"]~=transform["Y"]or transform["Z"]~=transform["Z"]then
return
end
if transform["RightVector"]["Magnitude"]<.01 or transform["UpVector"]["Magnitude"]<.01 then
return
end
local transform2=CFrame["fromMatrix"](transform["Position"], transform["RightVector"], transform["UpVector"])
local currentValue9=numericValue4*currentValue7
local currentValue10=numericValue4*currentValue8
if currentValue9~=currentValue9 or currentValue10~=currentValue10 or currentValue9==0 or currentValue10==0 then
return
end
camera["CFrame"]=transform2*CFrame["new"](0, 0, 0, currentValue9, 0, 0, 0, currentValue10, 0, 0, 0, 1)
end
end
)
end
RunService:BindToRenderStep("VD_CameraStretch", Enum["RenderPriority"]["Camera"]["Value"]+1, getFeatureState7)do
local color2={["Cyan"]=Color3["fromRGB"](0, 240, 255), ["Red"]=Color3["fromRGB"](255, 50, 50), ["Green"]=Color3["fromRGB"](50, 255, 50), ["Yellow"]=Color3["fromRGB"](255, 255, 50), ["Purple"]=Color3["fromRGB"](170, 80, 255);
["Orange"]=Color3["fromRGB"](255, 125, 0);
["Pink"]=Color3["fromRGB"](255, 100, 200);
["White"]=Color3["fromRGB"](255, 255, 255);
["Blue"]=Color3["fromRGB"](0, 100, 255)}
local items14={["gui"]=nil;
["frame"]=nil, ["corners"]={}}setupTargetBoxGui=function()
if items14["gui"]and items14["gui"]["Parent"]then
return
end
local screenGui2=Instance["new"]("ScreenGui")screenGui2["Name"]="VD_SilentAimTargetGui"screenGui2["ResetOnSpawn"]=false screenGui2["IgnoreGuiInset"]=true screenGui2["DisplayOrder"]=999 screenGui2["Parent"]=guiParent items14["gui"]=screenGui2
local frame4=Instance["new"]("Frame")frame4["Name"]="TargetBox"frame4["BackgroundTransparency"]=1 frame4["BorderSizePixel"]=0 frame4["Visible"]=false frame4["Parent"]=screenGui2 items14["frame"]=frame4
local numericValue4=14
local numericValue5=2.5
local function processValue6(name2, position, position2, contextValue)
local frame5=Instance["new"]("Frame")frame5["Name"]=name2 frame5["AnchorPoint"]=position frame5["Position"]=position2 frame5["Size"]=contextValue frame5["BorderSizePixel"]=0 frame5["BackgroundColor3"]=Color3["fromRGB"](255, 50, 50)frame5["Parent"]=frame4
return frame5
end
items14["corners"]={["TL_H"]=processValue6("TL_H", Vector2["new"](0, 0), UDim2["new"](0, -1, 0, -1), UDim2["new"](0, numericValue4, 0, numericValue5));
["TL_V"]=processValue6("TL_V", Vector2["new"](0, 0), UDim2["new"](0, -1, 0, -1), UDim2["new"](0, numericValue5, 0, numericValue4));
["TR_H"]=processValue6("TR_H", Vector2["new"](1, 0), UDim2["new"](1, 1, 0, -1), UDim2["new"](0, numericValue4, 0, numericValue5)), ["TR_V"]=processValue6("TR_V", Vector2["new"](1, 0), UDim2["new"](1, 1, 0, -1), UDim2["new"](0, numericValue5, 0, numericValue4)), ["BL_H"]=processValue6("BL_H", Vector2["new"](0, 1), UDim2["new"](0, -1, 1, 1), UDim2["new"](0, numericValue4, 0, numericValue5));
["BL_V"]=processValue6("BL_V", Vector2["new"](0, 1), UDim2["new"](0, -1, 1, 1), UDim2["new"](0, numericValue5, 0, numericValue4));
["BR_H"]=processValue6("BR_H", Vector2["new"](1, 1), UDim2["new"](1, 1, 1, 1), UDim2["new"](0, numericValue4, 0, numericValue5));
["BR_V"]=processValue6("BR_V", Vector2["new"](1, 1), UDim2["new"](1, 1, 1, 1), UDim2["new"](0, numericValue5, 0, numericValue4))}
end
getSilentAimTarget=function()
if not isFeatureAvailable()then
return nil, nil
end
local character2=localPlayer["Character"]
local camera=workspace["CurrentCamera"]
if not camera or not character2 then
return nil, nil
end
local distance=camera["ViewportSize"]/2
local cachedValue11=nil
local currentValue6=math["huge"]
local cachedValue12=nil
local spearsilentaim=settings["SpearSilentAim"]and(settings["SpearSilentAim"]["Enabled"]and settings["SpearSilentAim"]["TargetHighlightEnabled"])
local revolversilentaim=settings["RevolverSilentAim"]and(settings["RevolverSilentAim"]["Enabled"]and settings["RevolverSilentAim"]["TargetHighlightEnabled"])
if not spearsilentaim and not revolversilentaim then
return nil, nil
end
local success2=nil pcall(function()
for index, instance3 in ipairs(character2:GetChildren())do
if instance3:IsA("Tool")then
success2=instance3["Name"]
break
end
end
end
)
local cachedValue13=nil
if success2=="Twist of Fate"and revolversilentaim then
cachedValue13="Revolver"
elseif success2=="Veil Spear"and spearsilentaim then
cachedValue13="Spear"
else
if spearsilentaim then
cachedValue13="Spear"
elseif revolversilentaim then
cachedValue13="Revolver"
end
end
if not cachedValue13 then
return nil, nil
end
local conditionMet12=(cachedValue13=="Spear")and((settings["SpearSilentAim"]["FOVRadius"]or 240))or(settings["RevolverSilentAim"]["FOVRadius"]or 200)
local isMatchingTeam=(cachedValue13=="Spear")and"Both Teams"or(settings["RevolverSilentAim"]["Target"]or"Both Teams")
local isMatchingTeam2=(cachedValue13=="Spear")and"UpperTorso"or((settings["RevolverAimbot"]and settings["RevolverAimbot"]["TargetPart"])or"UpperTorso")
for index, player in ipairs(Players:GetPlayers())do
if player~=localPlayer and(player["Character"]and player["Character"]:IsA("Model"))then
local teamName=player["Team"]and player["Team"]["Name"]or""
local isMatchingTeam3=(cachedValue13=="Spear")or(isMatchingTeam=="Both Teams")or(isMatchingTeam=="Survivors"and teamName=="Survivors")or(isMatchingTeam=="Killer"and teamName=="Killer")
if isMatchingTeam3 then
local instance3=player["Character"]
local rootPart=instance3:FindFirstChild("HumanoidRootPart")or instance3:FindFirstChild(isMatchingTeam2)or instance3["PrimaryPart"]
local humanoid=instance3:FindFirstChildOfClass("Humanoid")
if rootPart and(humanoid and humanoid["Health"]>0)then
local screenPosition, onScreen=camera:WorldToViewportPoint(rootPart["Position"])
if onScreen and screenPosition["Z"]>0 then
local distance2=((Vector2["new"](screenPosition["X"], screenPosition["Y"])-distance))["Magnitude"]
if distance2<=conditionMet12 and distance2<currentValue6 then
currentValue6=distance2 cachedValue11=instance3 cachedValue12=cachedValue13
end
end
end
end
end
end
return cachedValue11, cachedValue12
end
get2DBoundingBox=function(instance3)
local camera=workspace["CurrentCamera"]
if not camera or not instance3 then
return nil
end
local head=instance3:FindFirstChild("Head")
local rootPart=instance3:FindFirstChild("HumanoidRootPart")or instance3["PrimaryPart"]
if not rootPart then
return nil
end
local vector2=head and(head["Position"]+Vector3["new"](0, .7, 0))or(rootPart["Position"]+Vector3["new"](0, 2.2, 0))
local vector3=rootPart["Position"]-Vector3["new"](0, 2.8, 0)
local screenPosition, onScreen=camera:WorldToViewportPoint(vector2)
local screenPosition2, onScreen2=camera:WorldToViewportPoint(vector3)
local screenPosition3, onScreen3=camera:WorldToViewportPoint(rootPart["Position"])
if not onScreen3 or screenPosition3["Z"]<=0 then
return nil
end
local difference=math["abs"](screenPosition2["Y"]-screenPosition["Y"])
local clampedValue=math["clamp"](difference*.6, 12, 350)
if difference<6 then
return nil
end
return screenPosition3["X"]-(clampedValue/2), screenPosition["Y"], clampedValue, difference
end
updateSilentAimTargetHighlight=function()setupTargetBoxGui()
local success2, result=nil, nil pcall(function()success2, result=getSilentAimTarget()
end
)
if success2 and(result and items14["frame"])then
local currentValue6, currentValue7, currentValue8, currentValue9=get2DBoundingBox(success2)
if currentValue6 and(currentValue7 and(currentValue8 and currentValue9))then
local conditionMet12=(result=="Spear")and settings["SpearSilentAim"]or settings["RevolverSilentAim"]
local conditionMet13=conditionMet12["TargetHighlightColor"]or(result=="Spear"and"Red"or"Cyan")
local conditionMet14=color2[conditionMet13]or(result=="Spear"and Color3["fromRGB"](255, 50, 50)or Color3["fromRGB"](0, 240, 255))items14["frame"]["Position"]=UDim2["new"](0, currentValue6, 0, currentValue7)items14["frame"]["Size"]=UDim2["new"](0, currentValue8, 0, currentValue9)items14["frame"]["BackgroundTransparency"]=1
local clampedValue=math["clamp"](math["floor"](currentValue8*.25), 6, 16)
local currentValue10=items14["corners"]
if currentValue10["TL_H"]then
currentValue10["TL_H"]["Size"]=UDim2["new"](0, clampedValue, 0, 2.5)
end
if currentValue10["TR_H"]then
currentValue10["TR_H"]["Size"]=UDim2["new"](0, clampedValue, 0, 2.5)
end
if currentValue10["BL_H"]then
currentValue10["BL_H"]["Size"]=UDim2["new"](0, clampedValue, 0, 2.5)
end
if currentValue10["BR_H"]then
currentValue10["BR_H"]["Size"]=UDim2["new"](0, clampedValue, 0, 2.5)
end
if currentValue10["TL_V"]then
currentValue10["TL_V"]["Size"]=UDim2["new"](0, 2.5, 0, clampedValue)
end
if currentValue10["TR_V"]then
currentValue10["TR_V"]["Size"]=UDim2["new"](0, 2.5, 0, clampedValue)
end
if currentValue10["BL_V"]then
currentValue10["BL_V"]["Size"]=UDim2["new"](0, 2.5, 0, clampedValue)
end
if currentValue10["BR_V"]then
currentValue10["BR_V"]["Size"]=UDim2["new"](0, 2.5, 0, clampedValue)
end
for key, item in pairs(currentValue10)do
if item then
item["BackgroundColor3"]=conditionMet14 item["BackgroundTransparency"]=0
end
end
items14["frame"]["Visible"]=true
return
end
end
if items14["frame"]and items14["frame"]["Visible"]then
items14["frame"]["Visible"]=false
end
end
registerConnection(RunService["RenderStepped"]:Connect(function()
if updateSilentAimTargetHighlight then
updateSilentAimTargetHighlight()
end
end
))
end

pcall(function()
 applyTheme(settings["Theme"] or "Default")
end)
pcall(function()
 patchMobileControls()
end)
pcall(function()
 toggleUI(true)
end)


--// 功能层：清理、导出与公共接口

_G["VD_GameFeatures"]={
 Settings=settings,
 ActiveESP=ActiveESP,
 ScanMapObjects=scanMapObjects,
 ApplyLocalPlayerModifiers=applyLocalPlayerModifiers,
 ApplyBlockInteractions=applyBlockInteractions,
 ReleaseBlockInteractions=releaseBlockInteractions,
 TeleportToInstance=teleportToInstance,
 UpdatePlayersESP=updatePlayersESP,
 ManageHighlights=manageHighlights,
 UpdateCrosshair=updateCrosshair,
 RunAimbot=runAimbot,
 GetClosestPlayerToMouse=getClosestPlayerToMouse,
 GetSilentAimTarget=getSilentAimTarget,
 UpdateSilentAimTargetHighlight=updateSilentAimTargetHighlight,
 UpdateVisuals=updateVisuals,
 Cleanup=cleanupAll
}

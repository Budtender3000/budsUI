local K, C, L, _ = select(2, ...):unpack()
if IsAddOnLoaded("Stuf") or IsAddOnLoaded("PitBull4") or IsAddOnLoaded("ShadowedUnitFrames") or IsAddOnLoaded("XPerl") then return end

local _G = _G

local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local InCombatLockdown = InCombatLockdown
local MAX_PARTY_MEMBERS = MAX_PARTY_MEMBERS
local GetCVar = GetCVar
local EnhancedFrames = CreateFrame("Frame")

local EnhancedFrames_Style_PlayerFrame
local EnhancedFrames_Style_TargetFrame
local EnhancedFrames_BossTargetFrame_Style
local EnhancedFrames_UpdateTextStringWithValues
local EnhancedFrames_PlayerFrame_ToPlayerArt
local EnhancedFrames_PlayerFrame_ToVehicleArt
local EnhancedFrames_TargetFrame_Update
local EnhancedFrames_Target_Classification
local EnhancedFrames_TargetFrame_CheckFaction
local EnhancedPartyFrames_PartyMemberFrame_ToPlayerArt
local EnhancedPartyFrames_PartyMemberFrame_ToVehicleArt
local EnableEnhancedFrames
local EnhancedFrames_StartUp

-- EVENT LISTENER TO MAKE SURE WE ENABLE THE ADDON AT THE RIGHT TIME
local hasInitialized = false
function EnhancedFrames:PLAYER_ENTERING_WORLD()
	if hasInitialized then return end
	hasInitialized = true

	EnableEnhancedFrames()
	for i = 1, MAX_PARTY_MEMBERS do
		if _G["PartyMemberFrame"..i] then
			EnhancedPartyFrames_PartyMemberFrame_ToPlayerArt(_G["PartyMemberFrame"..i])
		end
	end
end

EnableEnhancedFrames = function()
	-- SPECIFIC STATUS TEXT HOOKS - Use OnUpdate delay to prevent taint
	-- SetValue hooks run DURING Blizzard's frame update
	-- Delay our updates with OnUpdate to run AFTER Blizzard's update chain completes
	
	local updateQueue = {}
	local updateFrame = CreateFrame("Frame")
	updateFrame:Hide()
	updateFrame:SetScript("OnUpdate", function(self)
		for statusBar, _ in pairs(updateQueue) do
			EnhancedFrames_UpdateTextStringWithValues(statusBar)
			updateQueue[statusBar] = nil
		end
		self:Hide()
	end)
	
	local function QueueUpdate(statusBar)
		updateQueue[statusBar] = true
		updateFrame:Show()
	end
	
	if PlayerFrameHealthBar then
		hooksecurefunc(PlayerFrameHealthBar, "SetValue", function(self)
			QueueUpdate(self)
		end)
	end
	if PlayerFrameManaBar then
		hooksecurefunc(PlayerFrameManaBar, "SetValue", function(self)
			QueueUpdate(self)
		end)
	end
	if TargetFrameHealthBar then
		hooksecurefunc(TargetFrameHealthBar, "SetValue", function(self)
			QueueUpdate(self)
		end)
	end
	if TargetFrameManaBar then
		hooksecurefunc(TargetFrameManaBar, "SetValue", function(self)
			QueueUpdate(self)
		end)
	end
	if FocusFrameHealthBar then
		hooksecurefunc(FocusFrameHealthBar, "SetValue", function(self)
			QueueUpdate(self)
		end)
	end
	if FocusFrameManaBar then
		hooksecurefunc(FocusFrameManaBar, "SetValue", function(self)
			QueueUpdate(self)
		end)
	end

	-- HOOK PLAYERFRAME FUNCTIONS
	hooksecurefunc("PlayerFrame_ToPlayerArt", EnhancedFrames_PlayerFrame_ToPlayerArt)
	hooksecurefunc("PlayerFrame_ToVehicleArt", EnhancedFrames_PlayerFrame_ToVehicleArt)

	-- HOOK TARGETFRAME FUNCTIONS
	
	-- Hook global update functions for target frame styling
	hooksecurefunc("TargetFrame_Update", EnhancedFrames_TargetFrame_Update)
	hooksecurefunc("TargetFrame_CheckClassification", EnhancedFrames_Target_Classification)
	hooksecurefunc("TargetFrame_CheckFaction", EnhancedFrames_TargetFrame_CheckFaction)

	-- BOSSFRAME HOOKS REMOVED - Causes taint on Boss2TargetFrame:Hide()
	-- Boss frames will use default Blizzard styling to prevent taint issues
	-- hooksecurefunc("BossTargetFrame_OnLoad", EnhancedFrames_BossTargetFrame_Style)

	hooksecurefunc("PartyMemberFrame_ToPlayerArt", EnhancedPartyFrames_PartyMemberFrame_ToPlayerArt)
	hooksecurefunc("PartyMemberFrame_ToVehicleArt", EnhancedPartyFrames_PartyMemberFrame_ToVehicleArt)

	-- SET UP SOME STYLINGS
	EnhancedFrames_Style_PlayerFrame()
	-- Boss frames are styled via BossTargetFrame_OnLoad hook only, not directly
	-- Direct styling causes taint on Boss2TargetFrame:Hide()
	EnhancedFrames_Style_TargetFrame(TargetFrame)
	EnhancedFrames_Style_TargetFrame(FocusFrame)

	-- UPDATE SOME VALUES
	TextStatusBar_UpdateTextString(PlayerFrame.healthbar)
	TextStatusBar_UpdateTextString(PlayerFrame.manabar)
end

EnhancedFrames_Style_PlayerFrame = function()
	PlayerFrameTexture:SetTexture([[Interface\Addons\]] .. K.Directory .. [[\Media\Unitframes\UI-TargetingFrame]])
	PlayerStatusTexture:SetTexture([[Interface\Addons\]] .. K.Directory .. [[\Media\Unitframes\UI-Player-Status]])

	if InCombatLockdown() then return end
	PlayerName:SetWidth(0.01)
	PlayerFrameHealthBar.capNumericDisplay = true
	PlayerFrameHealthBar:SetSize(116, 29)
	PlayerFrameHealthBar:SetPoint("TOPLEFT", 106, -22)
	PlayerFrameHealthBarText:SetPoint("CENTER", 50, 12)
end

EnhancedFrames_Style_TargetFrame = function(self)
	-- Skip secure frames to prevent taint
	if not self or not self.unit then return end
	local unitType = self.unit
	-- Skip boss frames
	if unitType:match("^boss%d+") then return end
	
	if not InCombatLockdown() then
		local classification = UnitClassification(self.unit)
		if (classification == "minus") then
			self.healthbar:SetHeight(12)
			self.healthbar:SetPoint("TOPLEFT", 7, -41)
			self.healthbar.TextString:SetPoint("CENTER", -50, 4)
			self.deadText:SetPoint("CENTER", -50, 4)
			--self.Background:SetPoint("TOPLEFT", 7, -41)
		else
			self.name:SetPoint("TOPLEFT", 16, -10)

			self.healthbar:SetHeight(29)
			self.healthbar:SetPoint("TOPLEFT", 7, -22)
			self.healthbar.TextString:SetPoint("CENTER", -50, 12)
			self.deadText:SetPoint("CENTER", -50, 12)
			self.nameBackground:Hide()
			--self.Background:SetPoint("TOPLEFT", 7, -22)
		end

		self.healthbar:SetWidth(119)
	end
end

EnhancedFrames_BossTargetFrame_Style = function(self)
	if not self then return end
	
	-- Skip during combat to prevent taint
	if InCombatLockdown() then return end

	if self.borderTexture then
		self.borderTexture:SetTexture([[Interface\Addons\]] .. K.Directory .. [[\Media\Unitframes\UI-UnitFrame-Boss]])
	end

	EnhancedFrames_Style_TargetFrame(self)
end

EnhancedFrames_UpdateTextStringWithValues = function(textStatusBar)
	if not textStatusBar then return end
	
	local textString = textStatusBar.TextString
	if(textString) then
		local value = textStatusBar:GetValue()
		local valueMin, valueMax = textStatusBar:GetMinMaxValues()

		if ((tonumber(valueMax) ~= valueMax or valueMax > 0) and not (textStatusBar.pauseUpdates)) then
			textStatusBar:Show()
			if (value and valueMax > 0 and (GetCVarBool("statusTextPercentage") or textStatusBar.showPercentage) and not textStatusBar.showNumeric) then
				if (value == 0 and textStatusBar.zeroText) then
					textString:SetText(textStatusBar.zeroText)
					textStatusBar.isZero = 1
					textString:Show()
					return
				end
				value = tostring(ceil((value / valueMax) * 100)) .. "%"
				textString:SetText(K.ShortValue(textStatusBar:GetValue()).." - "..value.."")
			elseif (value == 0 and textStatusBar.zeroText) then
				textString:SetText(textStatusBar.zeroText)
				textStatusBar.isZero = 1
				textString:Show()
				return
			else
				textStatusBar.isZero = nil
				if (textStatusBar.capNumericDisplay) then
					value = K.ShortValue(value)
				end

				textString:SetText(value)
			end

			if ((textStatusBar.cvar and GetCVar(textStatusBar.cvar) == "1" and textStatusBar.textLockable) or textStatusBar.forceShow) then
				textString:Show()
			elseif (textStatusBar.lockShow > 0 and (not textStatusBar.forceHideText)) then
				textString:Show()
			else
				textString:Hide()
			end
		else
			textString:Hide()
			textString:SetText("")
			if (not textStatusBar.alwaysShow) then
				textStatusBar:Hide()
			else
				textStatusBar:SetValue(0)
			end
		end
	end
end

EnhancedFrames_PlayerFrame_ToPlayerArt = function(self)
	if not InCombatLockdown() then
		EnhancedFrames_Style_PlayerFrame()
	end
end

EnhancedFrames_PlayerFrame_ToVehicleArt = function(self)
	if InCombatLockdown() then return end
	PlayerFrameHealthBar:SetHeight(12)
	PlayerFrameHealthBarText:SetPoint("CENTER", 50, 3)
end

EnhancedFrames_TargetFrame_Update = function(self)
	-- Skip secure frames to prevent taint
	if not self or not self.unit then return end
	local unitType = self.unit
	-- Skip pet, raid, and boss frames
	if unitType == "pet" or
	   unitType:match("^raid%d+") or unitType:match("^party%d+pet") or unitType:match("^raid%d+pet") or
	   unitType:match("^boss%d+") then
		return
	end
	
	-- Skip during combat to prevent taint
	if InCombatLockdown() then return end
	if not self.healthbar then return end
	-- Set back color of health bar
	-- UnitIsTapDenied doesn't exist in WotLK, use UnitIsTapped and UnitIsTappedByPlayer instead
	if (not UnitPlayerControlled(self.unit) and UnitIsTapped(self.unit) and not UnitIsTappedByPlayer(self.unit)) then
		-- Gray if npc is tapped by other player
		self.healthbar:SetStatusBarColor(0.5, 0.5, 0.5)
	else
		-- Restore normal color
		local r, g, b = UnitSelectionColor(self.unit)
		self.healthbar:SetStatusBarColor(r, g, b)
	end
end

EnhancedFrames_Target_Classification = function(self, forceNormalTexture)
	-- Skip secure frames to prevent taint
	if not self or not self.unit then return end
	local unitType = self.unit
	-- Skip pet, raid, and boss frames
	if unitType == "pet" or
	   unitType:match("^raid%d+") or unitType:match("^party%d+pet") or unitType:match("^raid%d+pet") or
	   unitType:match("^boss%d+") then
		return
	end
	
	-- Skip during combat to prevent taint
	if InCombatLockdown() then return end
	
	local texture
	local classification = UnitClassification(self.unit)
	if (classification == "worldboss" or classification == "elite") then
		texture = [[Interface\Addons\]] .. K.Directory .. [[\Media\Unitframes\UI-TargetingFrame-Elite]]
	elseif (classification == "rareelite") then
		texture = [[Interface\Addons\]] .. K.Directory .. [[\Media\Unitframes\UI-TargetingFrame-Rare-Elite]]
	elseif (classification == "rare") then
		texture = [[Interface\Addons\]] .. K.Directory .. [[\Media\Unitframes\UI-TargetingFrame-Rare]]
	end
	if (texture and not forceNormalTexture) then
		self.borderTexture:SetTexture(texture)
	else
		if (not (classification == "minus")) then
			self.borderTexture:SetTexture([[Interface\Addons\]] .. K.Directory .. [[\Media\Unitframes\UI-TargetingFrame]])
		end
	end

	self.nameBackground:Hide()
end

EnhancedFrames_TargetFrame_CheckFaction = function(self)
	-- Skip secure frames to prevent taint
	if not self or not self.unit then return end
	local unitType = self.unit
	-- Skip pet, raid, and boss frames
	if unitType == "pet" or
	   unitType:match("^raid%d+") or unitType:match("^party%d+pet") or unitType:match("^raid%d+pet") or
	   unitType:match("^boss%d+") then
		return
	end
	
	-- Skip if in combat to avoid taint issues
	if InCombatLockdown() then return end
	
	local factionGroup = UnitFactionGroup(self.unit)
	if (UnitIsPVPFreeForAll(self.unit)) then
		self.pvpIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA")
		self.pvpIcon:Show()
	elseif (factionGroup and UnitIsPVP(self.unit) and UnitIsEnemy("player", self.unit)) then
		self.pvpIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA")
		self.pvpIcon:Show()
	elseif (factionGroup == "Alliance" or factionGroup == "Horde") then
		self.pvpIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..factionGroup)
		self.pvpIcon:Show()
	else
		self.pvpIcon:Hide()
	end

	EnhancedFrames_Style_TargetFrame(self)
end

EnhancedPartyFrames_PartyMemberFrame_ToPlayerArt = function(self)
	if InCombatLockdown() then return end
	
	local name = self:GetName()
	if not name then return end

	local healthBar = _G[name.."HealthBar"]
	if healthBar and healthBar.TextString then
		healthBar.TextString:SetPoint("CENTER", healthBar, "CENTER", 0, 1)
	end

	local nameText = _G[name.."Name"]
	if nameText then
		nameText:SetPoint("TOP", 0, 20)
		nameText:SetFont(C.Media.Font, 10)
	end

	local texture = _G[name.."Texture"]
	if texture then
		texture:SetTexture([[Interface\Addons\]] .. K.Directory .. [[\Media\Unitframes\PartyFrame]])
		texture:SetPoint("TOPLEFT", 0, 6)
	end

	local flash = _G[name.."Flash"]
	if flash then
		flash:SetTexture([[Interface\Addons\]] .. K.Directory .. [[\Media\Unitframes\PartyFrameFlash]])
		flash:SetPoint("TOPLEFT", 0, 6)
	end

	if healthBar then
		healthBar:SetPoint("TOPLEFT", 47, -3)
		healthBar:SetHeight(17)
	end

	local bg = _G[name.."Background"]
	if bg then
		bg:SetSize(70, 24)
		bg:SetPoint("TOPLEFT", 47, -3)
	end
end

-- UPDATE SETTINGS SPECIFIC TO PARTY MEMBER UNIT FRAMES WHEN IN VEHICLES
EnhancedPartyFrames_PartyMemberFrame_ToVehicleArt = function(self)
	if not InCombatLockdown() then
		local name = self:GetName()
		if not name then return end
		local tex = [[Interface\Addons\]] .. K.Directory .. [[\Media\Unitframes\VehiclePartyFrame]]
		local f = _G[name.."VehicleTexture"]
		if f then f:SetTexture(tex) end
	end
end

-- BOOTSTRAP
EnhancedFrames_StartUp = function(self)
	self:SetScript("OnEvent", function(self, event) self[event](self) end)
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

EnhancedFrames_StartUp(EnhancedFrames)

local K, C, L, _ = select(2, ...):unpack()
if C.Unitframe.EnhancedFrames ~= true then return end

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
	-- GENERIC STATUS TEXT HOOK
	hooksecurefunc("TextStatusBar_UpdateTextString", EnhancedFrames_UpdateTextStringWithValues)

	-- HOOK PLAYERFRAME FUNCTIONS
	hooksecurefunc("PlayerFrame_ToPlayerArt", EnhancedFrames_PlayerFrame_ToPlayerArt)
	hooksecurefunc("PlayerFrame_ToVehicleArt", EnhancedFrames_PlayerFrame_ToVehicleArt)

	-- HOOK TARGETFRAME FUNCTIONS
	hooksecurefunc("TargetFrame_CheckDead", EnhancedFrames_TargetFrame_Update)
	hooksecurefunc("TargetFrame_Update", EnhancedFrames_TargetFrame_Update)
	hooksecurefunc("TargetFrame_CheckFaction", EnhancedFrames_TargetFrame_CheckFaction)
	hooksecurefunc("TargetFrame_CheckClassification", EnhancedFrames_Target_Classification)
	-- Removed TargetofTarget_Update hook to prevent taint on TargetFrameToT:Show()

	-- BOSSFRAME HOOKS
	hooksecurefunc("BossTargetFrame_OnLoad", EnhancedFrames_BossTargetFrame_Style)

	hooksecurefunc("PartyMemberFrame_ToPlayerArt", EnhancedPartyFrames_PartyMemberFrame_ToPlayerArt)
	hooksecurefunc("PartyMemberFrame_ToVehicleArt", EnhancedPartyFrames_PartyMemberFrame_ToVehicleArt)

	-- SET UP SOME STYLINGS
	EnhancedFrames_Style_PlayerFrame()
	EnhancedFrames_BossTargetFrame_Style(Boss1TargetFrame)
	EnhancedFrames_BossTargetFrame_Style(Boss2TargetFrame)
	EnhancedFrames_BossTargetFrame_Style(Boss3TargetFrame)
	EnhancedFrames_BossTargetFrame_Style(Boss4TargetFrame)
	EnhancedFrames_Style_TargetFrame(TargetFrame)
	EnhancedFrames_Style_TargetFrame(FocusFrame)

	-- UPDATE SOME VALUES
	TextStatusBar_UpdateTextString(PlayerFrame.healthbar)
	TextStatusBar_UpdateTextString(PlayerFrame.manabar)
end

EnhancedFrames_Style_PlayerFrame = function()
	PlayerFrameTexture:SetTexture("Interface\\Addons\\budsUI\\Media\\Unitframes\\UI-TargetingFrame")
	PlayerStatusTexture:SetTexture("Interface\\Addons\\budsUI\\Media\\Unitframes\\UI-Player-Status")

	if InCombatLockdown() then return end
	PlayerName:SetWidth(0.01)
	PlayerFrameHealthBar.capNumericDisplay = true
	PlayerFrameHealthBar:SetSize(116, 29)
	PlayerFrameHealthBar:SetPoint("TOPLEFT", 106, -22)
	PlayerFrameHealthBarText:SetPoint("CENTER", 50, 12)
end

EnhancedFrames_Style_TargetFrame = function(self)
	if not InCombatLockdown() then
		local classification = UnitClassification(self.unit)
		if (classification == "minus") then
			self.healthbar:SetHeight(12)
			self.healthbar:SetPoint("TOPLEFT", 7, -41)
			self.healthbar.TextString:SetPoint("CENTER", -50, 4)
			self.deadText:SetPoint("CENTER", -50, 4)
			self.Background:SetPoint("TOPLEFT", 7, -41)
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

	if self.borderTexture then
		self.borderTexture:SetTexture("Interface\\Addons\\budsUI\\Media\\Unitframes\\UI-UnitFrame-Boss")
	end

	EnhancedFrames_Style_TargetFrame(self)
end

EnhancedFrames_UpdateTextStringWithValues = function(textStatusBar)
	local textString = textStatusBar.TextString
	if(textString) then
		local value = textStatusBar:GetValue()
		local valueMin, valueMax = textStatusBar:GetMinMaxValues()

		if ((tonumber(valueMax) ~= valueMax or valueMax > 0) and not (textStatusBar.pauseUpdates)) then
			if not InCombatLockdown() then
				textStatusBar:Show()
			end
			if (value and valueMax > 0 and (GetCVarBool("statusTextPercentage") or textStatusBar.showPercentage) and not textStatusBar.showNumeric) then
				if (value == 0 and textStatusBar.zeroText) then
					textString:SetText(textStatusBar.zeroText)
					textStatusBar.isZero = 1
					if not InCombatLockdown() then
						textString:Show()
					end
					return
				end
				value = tostring(ceil((value / valueMax) * 100)) .. "%"
				textString:SetText(K.ShortValue(textStatusBar:GetValue()).." - "..value.."")
			elseif (value == 0 and textStatusBar.zeroText) then
				textString:SetText(textStatusBar.zeroText)
				textStatusBar.isZero = 1
				if not InCombatLockdown() then
					textString:Show()
				end
				return
			else
				textStatusBar.isZero = nil
				if (textStatusBar.capNumericDisplay) then
					value = K.ShortValue(value)
				end

				textString:SetText(value)
			end

			if not InCombatLockdown() then
				if ((textStatusBar.cvar and GetCVar(textStatusBar.cvar) == "1" and textStatusBar.textLockable) or textStatusBar.forceShow) then
					textString:Show()
				elseif (textStatusBar.lockShow > 0 and (not textStatusBar.forceHideText)) then
					textString:Show()
				else
					textString:Hide()
				end
			end
		else
			if not InCombatLockdown() then
				textString:Hide()
			end
			textString:SetText("")
			if (not textStatusBar.alwaysShow) then
				if not InCombatLockdown() then
					textStatusBar:Hide()
				end
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
	-- Skip during combat to prevent taint
	if InCombatLockdown() then return end
	if not self or not self.unit or not self.healthbar then return end
	-- Set back color of health bar
	-- UnitIsTapDenied doesn't exist in WotLK, use UnitIsTapped and UnitIsTappedByPlayer instead
	if (not UnitPlayerControlled(self.unit) and UnitIsTapped(self.unit) and not UnitIsTappedByPlayer(self.unit)) then
		-- Gray if npc is tapped by other player
		self.healthbar:SetStatusBarColor(0.5, 0.5, 0.5)
	end
end

EnhancedFrames_Target_Classification = function(self, forceNormalTexture)
	-- Skip during combat to prevent taint
	if InCombatLockdown() then return end
	
	local texture
	local classification = UnitClassification(self.unit)
	if (classification == "worldboss" or classification == "elite") then
		texture = "Interface\\Addons\\budsUI\\Media\\Unitframes\\UI-TargetingFrame-Elite"
	elseif (classification == "rareelite") then
		texture = "Interface\\Addons\\budsUI\\Media\\Unitframes\\UI-TargetingFrame-Rare-Elite"
	elseif (classification == "rare") then
		texture = "Interface\\Addons\\budsUI\\Media\\Unitframes\\UI-TargetingFrame-Rare"
	end
	if (texture and not forceNormalTexture) then
		self.borderTexture:SetTexture(texture)
	else
		if (not (classification == "minus")) then
			self.borderTexture:SetTexture("Interface\\Addons\\budsUI\\Media\\Unitframes\\UI-TargetingFrame")
		end
	end

	self.nameBackground:Hide()
end

EnhancedFrames_TargetFrame_CheckFaction = function(self)
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
	
	if self.healthbar and self.healthbar.TextString then
		self.healthbar.TextString:SetPoint("CENTER", self.healthbar, "CENTER", 0, 1)
	end

	if self.name then
		self.name:SetPoint("TOP", 0, 20)
		self.name:SetFont(C.Media.Font, 10)
	end

	local name = self:GetName()
	if name then
		local texture = _G[name.."Texture"]
		if texture then
			texture:SetTexture("Interface\\Addons\\budsUI\\Media\\Unitframes\\PartyFrame")
			texture:SetPoint("TOPLEFT", 0, 6)
		end

		local flash = _G[name.."Flash"]
		if flash then
			flash:SetTexture("Interface\\Addons\\budsUI\\Media\\Unitframes\\PartyFrameFlash")
			flash:SetPoint("TOPLEFT", 0, 6)
		end

		if self.healthbar then
			self.healthbar:SetPoint("TOPLEFT", 47, -3)
			self.healthbar:SetHeight(17)
		end

		local bg = _G[name.."Background"]
		if bg then
			bg:SetSize(70, 24)
			bg:SetPoint("TOPLEFT", 47, -3)
		end
	end
end

-- UPDATE SETTINGS SPECIFIC TO PARTY MEMBER UNIT FRAMES WHEN IN VEHICLES
EnhancedPartyFrames_PartyMemberFrame_ToVehicleArt = function(self)
	if not InCombatLockdown() then
		local tex = "Interface\\Addons\\budsUI\\Media\\Unitframes\\VehiclePartyFrame"
		for i = 1, 4 do
			local f = _G["PartyMemberFrame"..i.."VehicleTexture"]
			if f then f:SetTexture(tex) end
		end
	end
end

-- BOOTSTRAP
EnhancedFrames_StartUp = function(self)
	self:SetScript("OnEvent", function(self, event) self[event](self) end)
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

EnhancedFrames_StartUp(EnhancedFrames)

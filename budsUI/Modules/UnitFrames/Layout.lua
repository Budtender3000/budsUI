local K, C, L, _ = select(2, ...):unpack()

local _G = _G
local unpack = unpack
local pairs = pairs
local select = select
local IsAddOnLoaded = IsAddOnLoaded
local CreateFrame = CreateFrame
local UIParent = UIParent
local InCombatLockdown = InCombatLockdown
local hooksecurefunc = hooksecurefunc
local UnitIsPlayer = UnitIsPlayer
local UnitPlayerControlled = UnitPlayerControlled
local UnitClass, GetUnitName = UnitClass, GetUnitName
local CUSTOM_CLASS_COLORS = CUSTOM_CLASS_COLORS
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local UnitIsEnemy = UnitIsEnemy
local UnitIsTappedByPlayer = UnitIsTappedByPlayer
local UnitIsTapped = UnitIsTapped
local UnitReaction = UnitReaction
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitIsConnected = UnitIsConnected

local Unitframes = CreateFrame("Frame", "Unitframes", UIParent)

if C.Unitframe.Enable == true then

	local PlayerAnchor = CreateFrame("Frame", "PlayerFrameAnchor", UIParent)
	if not InCombatLockdown() then
		PlayerAnchor:SetSize(146, 28)
		PlayerAnchor:SetPoint(unpack(C.Position.UnitFrames.Player))
	end

	local TargetAnchor = CreateFrame("Frame", "TargetFrameAnchor", UIParent)
	if not InCombatLockdown() then
		TargetAnchor:SetSize(146, 28)
		TargetAnchor:SetPoint(unpack(C.Position.UnitFrames.Target))
	end

	Unitframes:RegisterEvent("ADDON_LOADED")
	Unitframes:SetScript("OnEvent", function(self, event, addon)
		if (addon ~= "budsUI") then return end
		if not InCombatLockdown() then
			if C.Unitframe.ClassHealth ~= true then

				CUSTOM_FACTION_BAR_COLORS = {
					[1] = {r = 255/255, g = 0/255, b = 0/255},
					[2] = {r = 255/255, g = 0/255, b = 0/255},
					[3] = {r = 255/255, g = 255/255, b = 0/255},
					[4] = {r = 255/255, g = 255/255, b = 0/255},
					[5] = {r = 0/255, g = 255/255, b = 0/255},
					[6] = {r = 0/255, g = 255/255, b = 0/255},
					[7] = {r = 0/255, g = 255/255, b = 0/255},
					[8] = {r = 0/255, g = 255/255, b = 0/255},
				}

				hooksecurefunc("UnitFrame_Update", function(self, isParty)
					-- Skip during combat to prevent taint on secure frames like PetFrame
					if InCombatLockdown() then return end
					if not self.name or not self:IsShown() then return end

					local PET_COLOR = {r = 157/255, g = 197/255, b = 255/255}
					local unit, color = self.unit
					if UnitPlayerControlled(unit) then
						if UnitIsPlayer(unit) then
							color = RAID_CLASS_COLORS[select(2, UnitClass(unit))]
						else
							color = PET_COLOR
						end
					elseif UnitIsDeadOrGhost(unit) or (UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit)) then
						color = GRAY_FONT_COLOR
					else
						color = CUSTOM_FACTION_BAR_COLORS[UnitIsEnemy(unit, "player") and 1 or UnitReaction(unit, "player") or 5]
					end

					if not color then
						color = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)["PRIEST"]
					end

					self.name:SetTextColor(color.r, color.g, color.b)
					if isParty then
						self.name:SetText(GetUnitName(self.overrideName or unit))
					end
				end)
			end

			-- Font Helper
			local function SetUnitFont(fontString, sizeAdj)
				local size = C.Media.Font_Size + (sizeAdj or 0)
				if C.Unitframe.Outline then
					fontString:SetFont(C.Media.Font, size, C.Media.Font_Style)
					fontString:SetShadowOffset(0, -0)
				else
					fontString:SetFont(C.Media.Font, size)
					fontString:SetShadowOffset(K.Mult, -K.Mult)
				end
			end

			-- Unit Name
			for _, FrameNames in pairs({
				PlayerName,
				TargetFrameTextureFrameName,
				FocusFrameTextureFrameName,
			}) do
				SetUnitFont(FrameNames)
			end

			-- Unit HealthBarText
			for _, FrameBarText in pairs({
				PlayerFrameHealthBarText,
				PlayerFrameManaBarText,
				TargetFrameTextureFrameHealthBarText,
				TargetFrameTextureFrameManaBarText,
				FocusFrameTextureFrameHealthBarText,
				FocusFrameTextureFrameManaBarText,
				PetFrameHealthBarText,
				PetFrameManaBarText,
			}) do
				SetUnitFont(FrameBarText)
			end

			-- Party Unit HealthBarText
			for _, PartyBarText in pairs({
				PartyMemberFrame1HealthBarText,
				PartyMemberFrame1ManaBarText,
				PartyMemberFrame2HealthBarText,
				PartyMemberFrame2ManaBarText,
				PartyMemberFrame3HealthBarText,
				PartyMemberFrame3ManaBarText,
				PartyMemberFrame4HealthBarText,
				PartyMemberFrame4ManaBarText,
			}) do
				SetUnitFont(PartyBarText, -3)
			end

			-- Unit LevelText
			for _, LevelText in pairs({
				PlayerLevelText,
				TargetFrameTextureFrameLevelText,
				FocusFrameTextureFrameLevelText,
			}) do
				SetUnitFont(LevelText, 1)
			end


			-- Tweak Party Frame
			for i = 1, MAX_PARTY_MEMBERS do
				_G["PartyMemberFrame"..i]:SetScale(C.Unitframe.Scale)
			end
			PartyMemberBuffTooltip:Kill() -- I personally hate this shit.

			if not InCombatLockdown() then
				-- Tweak Player Frame
				PlayerFrame:SetMovable(true)
				PlayerFrame:ClearAllPoints()
				PlayerFrame:SetPoint("CENTER", PlayerFrameAnchor, "CENTER", -51, 3)
				PlayerFrame:SetMovable(false)
			end

			-- Hide Pet Name.
			PetName:Hide()

			if not InCombatLockdown() then
				-- Tweak Target Frame
				TargetFrame:SetMovable(true)
				TargetFrame:ClearAllPoints()
				TargetFrame:SetPoint("CENTER", TargetFrameAnchor, "CENTER", 51, 3)
				TargetFrame:SetMovable(false)
			end
			-- Tweak Name Background
			TargetFrameNameBackground:SetTexture(0, 0, 0, 0.01)

			-- Tweak Focus Frame
			FocusFrame:ClearAllPoints()
			FocusFrame:SetPoint(unpack(C.Position.UnitFrames.Focus))
			-- Tweak Name Background
			FocusFrameNameBackground:SetTexture(0, 0, 0, 0.01)

			if not InCombatLockdown() then
				for _, FrameScale in pairs({
					PlayerFrame,
					TargetFrame,
					FocusFrame,
				}) do
					FrameScale:SetScale(C.Unitframe.Scale)
				end
			end

			-- Tweak Focus Frame
			FocusFrameToT:SetScale(1.0)
			FocusFrameToT:ClearAllPoints()
			FocusFrameToT:SetPoint("TOP", FocusFrame, "BOTTOM", 34, 35)

			-- Arena Frames Scaling
			local function SetArenaFrames()
				for i = 1, MAX_ARENA_ENEMIES do
					_G["ArenaEnemyFrame"..i]:SetScale(C.Unitframe.Scale)
					ArenaEnemyFrames:SetPoint(unpack(C.Position.UnitFrames.Arena))
				end
			end

			if IsAddOnLoaded("Blizzard_ArenaUI") then
				SetArenaFrames()
			else
				local f = CreateFrame("Frame")
				f:RegisterEvent("ADDON_LOADED")
				f:SetScript("OnEvent", function(self, event, addon)
					if (addon == "Blizzard_ArenaUI") then
						self:UnregisterEvent(event)
						SetArenaFrames()
					end
				end)
			end

			-- RuneFrame
			if K.Class == "DEATHKNIGHT" then
				RuneFrame:ClearAllPoints()
				RuneFrame:SetPoint("TOPLEFT", PlayerFrameManaBar, "BOTTOMLEFT", -1, -5)
				for i = 1, 6 do
					_G["RuneButtonIndividual"..i]:SetScale(C.Unitframe.Scale)
				end
			end

			-- ComboFrame
			if K.Class == "ROGUE" or K.Class == "DRUID" then
				for i = 1, 5 do
					_G["ComboPoint"..i]:SetScale(C.Unitframe.Scale)
				end

				if C.Unitframe.ComboFrame == true then
					ComboFrame:Kill()
				end
			end

			self:UnregisterEvent("ADDON_LOADED")
		end
	end)
end

-- Class Icons
if not InCombatLockdown() then
	if C.Unitframe.ClassIcon == true then
		hooksecurefunc("UnitFramePortrait_Update", function(self)
			if self.portrait then
				if UnitIsPlayer(self.unit) then
					local t = CLASS_ICON_TCOORDS[select(2, UnitClass(self.unit))]
					if t then
						self.portrait:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
						self.portrait:SetTexCoord(unpack(t))
					end
				else
					self.portrait:SetTexCoord(0, 1, 0, 1)
				end
			end
		end)
	end

	-- Class Color Bars
	if C.Unitframe.ClassHealth == true then
		local function colorHealthBar(statusbar, unit)
			local _, class, color
			if UnitIsPlayer(unit) and UnitIsConnected(unit) and unit == statusbar.unit and UnitClass(unit) then
				_, class = UnitClass(unit)
				color = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
				statusbar:SetStatusBarColor(color.r, color.g, color.b)
			end
		end

		hooksecurefunc("UnitFrameHealthBar_Update", colorHealthBar)
		hooksecurefunc("HealthBar_OnValueChanged", function(self)
			colorHealthBar(self, self.unit)
		end)
	end
end
-- Remove Portrait Damage Spam
if C.Unitframe.CombatFeedback == true then
	PlayerHitIndicator:Hide()
	PlayerHitIndicator:SetAlpha(0)
end

-- Remove Group Number Frame
if C.Unitframe.GroupNumber == true then
	PlayerFrameGroupIndicator:Hide()
	PlayerFrameGroupIndicator:SetAlpha(0)
end

-- Remove PvPIcons
if C.Unitframe.PvPIcon == true then
	PlayerPVPIcon:Kill()
	TargetFrameTextureFramePVPIcon:Kill()
	FocusFrameTextureFramePVPIcon:Kill()
	for i = 1, MAX_PARTY_MEMBERS do
		_G["PartyMemberFrame"..i.."PVPIcon"]:Kill()
	end
end
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

-- Layout Constants
local PLAYER_TARGET_X = 51
local PLAYER_TARGET_Y = 3
local FOCUS_TOT_X = 34
local FOCUS_TOT_Y = 35
local RUNE_OFFSET_X = -1
local RUNE_OFFSET_Y = -5

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
			-- UnitFrame_Update hook removed - caused PetFrame taint issues
			
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

			-- Font Strings Configuration
			local unitFramesFontStrings = {
				-- Generic Unit Font
				[1] = {
					PlayerName, TargetFrameTextureFrameName, FocusFrameTextureFrameName,
					PlayerFrameHealthBarText, PlayerFrameManaBarText,
					TargetFrameTextureFrameHealthBarText, TargetFrameTextureFrameManaBarText,
					FocusFrameTextureFrameHealthBarText, FocusFrameTextureFrameManaBarText,
					PetFrameHealthBarText, PetFrameManaBarText
				},
				-- Party Font (Size adjusted)
				[-3] = {
					PartyMemberFrame1HealthBarText, PartyMemberFrame1ManaBarText,
					PartyMemberFrame2HealthBarText, PartyMemberFrame2ManaBarText,
					PartyMemberFrame3HealthBarText, PartyMemberFrame3ManaBarText,
					PartyMemberFrame4HealthBarText, PartyMemberFrame4ManaBarText,
				},
				-- Level Font (Size adjusted)
				[1] = {
					PlayerLevelText, TargetFrameTextureFrameLevelText, FocusFrameTextureFrameLevelText
				}
			}

			for adj, frames in pairs(unitFramesFontStrings) do
				for _, fontString in ipairs(frames) do
					SetUnitFont(fontString, adj)
				end
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
				PlayerFrame:SetPoint("CENTER", PlayerFrameAnchor, "CENTER", -PLAYER_TARGET_X, PLAYER_TARGET_Y)
				PlayerFrame:SetMovable(false)
			end

			-- Hide Pet Name.
			PetName:Hide()

			if not InCombatLockdown() then
				-- Tweak Target Frame
				TargetFrame:SetMovable(true)
				TargetFrame:ClearAllPoints()
				TargetFrame:SetPoint("CENTER", TargetFrameAnchor, "CENTER", PLAYER_TARGET_X, PLAYER_TARGET_Y)
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

			if not InCombatLockdown() then
				-- Tweak Focus Frame ToT (must be protected)
				FocusFrameToT:SetScale(1.0)
				FocusFrameToT:ClearAllPoints()
				FocusFrameToT:SetPoint("TOP", FocusFrame, "BOTTOM", FOCUS_TOT_X, FOCUS_TOT_Y)
			end

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
				RuneFrame:SetPoint("TOPLEFT", PlayerFrameManaBar, "BOTTOMLEFT", RUNE_OFFSET_X, RUNE_OFFSET_Y)
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
			-- Skip secure frames to prevent taint
			if not self or not self.unit then return end
			local unitType = self.unit
			-- Skip pet, ToT, raid, party pet, and boss frames
			if self == PetFrame or self == TargetFrameToT or self == FocusFrameToT or
			   unitType == "pet" or unitType == "targettarget" or unitType == "focustarget" or
			   unitType:match("^raid%d+") or unitType:match("^party%d+pet") or unitType:match("^raid%d+pet") or
			   unitType:match("^boss%d+") then
				return
			end
			
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
			-- Skip secure frames to prevent taint
			-- statusbar is the health bar, not the frame itself
			if not statusbar or not statusbar.unit then return end
			local unitType = statusbar.unit
			-- Skip pet, ToT, raid, and boss frames
			if unitType == "pet" or unitType == "targettarget" or unitType == "focustarget" or
			   unitType:match("^raid%d+") or unitType:match("^party%d+pet") or unitType:match("^raid%d+pet") or
			   unitType:match("^boss%d+") then
				return
			end
			
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
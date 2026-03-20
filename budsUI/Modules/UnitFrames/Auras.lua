local K, C, L, _ = select(2, ...):unpack()
if IsAddOnLoaded("Stuf") or IsAddOnLoaded("PitBull4") or IsAddOnLoaded("ShadowedUnitFrames") or IsAddOnLoaded("XPerl") then return end

local _G = _G
local GetName = GetName
local UnitIsFriend = UnitIsFriend
local hooksecurefunc = hooksecurefunc

-- Initialize aura settings after PLAYER_ENTERING_WORLD to prevent early taint
local auraInit = CreateFrame("Frame")
auraInit:RegisterEvent("PLAYER_ENTERING_WORLD")
auraInit:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_ENTERING_WORLD" then
		TargetFrame.maxBuffs = 16
		TargetFrame.maxDebuffs = 16
		MAX_TARGET_BUFFS = 16
		MAX_TARGET_DEBUFFS = 16
		TargetFrame_UpdateAuras(TargetFrame)
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	end
end)

-- Aura Constants
local AURA_BORDER_SIZE = 8
local AURA_CD_OFFSET = 1.5
local AURA_ROW_WIDTH = 100
local NUM_TOT_AURA_ROWS = 2
local AURA_START_X = 3
local AURA_START_Y = 32
local AURA_OFFSET_Y_DEFAULT = 3
local BEAUTY_NUDGE = 3
local BEAUTY_SPACING = 1

-- AURAS
local function TargetAuraColour(self)
	-- CRITICAL: Only process TargetFrame and FocusFrame, reject everything else immediately
	if self ~= TargetFrame and self ~= FocusFrame then
		return
	end
	
	if not self or not self.unit then return end
	
	-- buffs
	for i = 1, MAX_TARGET_BUFFS do
		local bframe = _G[self:GetName().."Buff"..i]
		local bframecd = _G[self:GetName().."Buff"..i.."Cooldown"]
		local bframecount = _G[self:GetName().."Buff"..i.."Count"]
		if bframe then
			bframe:SetScale(1)
			K.CreateBorder(bframe, AURA_BORDER_SIZE)

			bframecd:ClearAllPoints()
			bframecd:SetPoint("TOPLEFT", bframe, AURA_CD_OFFSET, -AURA_CD_OFFSET)
			bframecd:SetPoint("BOTTOMRIGHT", bframe, -AURA_CD_OFFSET, AURA_CD_OFFSET)

			bframecount:ClearAllPoints()
			bframecount:SetPoint("CENTER", bframe, "BOTTOM", 0, 0)
			bframecount:SetJustifyH("CENTER")
			bframecount:SetFont(C.Media.Font, C.Media.Font_Size - 1, C.Media.Font_Style)
			bframecount:SetDrawLayer("OVERLAY", 7)
		end
	end
	-- debuffs
	for i = 1, MAX_TARGET_DEBUFFS do
		local dframe = _G[self:GetName().."Debuff"..i]
		local dframecd = _G[self:GetName().."Debuff"..i.."Cooldown"]
		local dframecount = _G[self:GetName().."Debuff"..i.."Count"]
		if dframe then
			K.CreateBorder(dframe, AURA_BORDER_SIZE)

			-- border colour
			local dname, _, _, _, dtype = UnitDebuff(self.unit, i)
			if dname then
				local colour = DebuffTypeColor[dtype] or DebuffTypeColor.none
				local auborder = _G[self:GetName().."Debuff"..i.."Border"]
				if auborder then
					auborder:Hide()
					auborder:SetAlpha(0)
				end
				dframe:SetBackdropBorderColor(colour.r, colour.g, colour.b)
			else
				dframe:SetBackdropBorderColor(unpack(C.Media.Border_Color))
			end

			if dframecd then -- pet doesn"t show cd?
				dframecd:ClearAllPoints()
				dframecd:SetPoint("TOPLEFT", dframe, AURA_CD_OFFSET, -AURA_CD_OFFSET)
				dframecd:SetPoint("BOTTOMRIGHT", dframe, -AURA_CD_OFFSET, AURA_CD_OFFSET)
			end

			if dframecount then -- ToT doesn"t show stacks
				dframecount:ClearAllPoints()
				dframecount:SetPoint("CENTER", dframe, "BOTTOM")
				dframecount:SetJustifyH("CENTER")
				dframecount:SetFont(C.Media.Font, C.Media.Font_Size - 1, C.Media.Font_Style)
			end
		end
	end
end

local beauty = _G["!BeautyCase"] or _G["BeautyCase"]

-- reposition
local function TargetAuraPosit(self, auraName, numAuras, numOppositeAuras, largeAuraList, updateFunc, maxRowWidth, offsetX, mirrorAurasVertically)
	-- CRITICAL: Only process TargetFrame and FocusFrame, reject everything else immediately
	if self ~= TargetFrame and self ~= FocusFrame then
		return
	end
	
	if not self or not self.unit or not beauty then return end
	do
		local AURA_OFFSET_Y = C.Unitframe.AuraOffsetY
		local LARGE_AURA_SIZE = C.Unitframe.LargeAuraSize
		local SMALL_AURA_SIZE = C.Unitframe.SmallAuraSize

		local AURA_X_OFFSET = offsetX + 2
		local AURA_Y_OFFSET = 0 -- Initialize offsetY
		local rowWidth = 0 -- Initialize rowWidth
		local firstBuffOnRow = 1 -- Initialize firstBuffOnRow

		for i = 1, numAuras do
			local size = largeAuraList[i] and LARGE_AURA_SIZE or SMALL_AURA_SIZE

			if i == 1 then
				rowWidth = size
				self.auraRows = self.auraRows + 1
			else
				rowWidth = rowWidth + size + offsetX
			end

			if rowWidth > maxRowWidth then
				-- x & y
				updateFunc(self, auraName, i, numOppositeAuras, firstBuffOnRow, size, AURA_X_OFFSET, AURA_Y_OFFSET, mirrorAurasVertically)

				rowWidth = size
				self.auraRows = self.auraRows + 1
				firstBuffOnRow = i
				AURA_Y_OFFSET = AURA_OFFSET_Y

				if self.auraRows > NUM_TOT_AURA_ROWS then maxRowWidth = AURA_ROW_WIDTH end
			else
				updateFunc(self, auraName, i, numOppositeAuras, i - 1, size, AURA_X_OFFSET, AURA_Y_OFFSET, mirrorAurasVertically)
			end
		end

	end
end

-- debuff reposition
local function TargetDebuffPosit(self, debuffName, index, numBuffs, anchorIndex, size, offsetX, offsetY, mirrorVertically)
	-- CRITICAL: Only process TargetFrame and FocusFrame, reject everything else immediately
	if self ~= TargetFrame and self ~= FocusFrame then
		return
	end
	
	if not self or not self.unit then return end
	
	local dbuff = _G[debuffName..index]
	local isFriend = UnitIsFriend("player", self.unit)
	local AURA_START_X = 3
	local AURA_START_Y = 32
	local AURA_OFFSET_Y = 3

	-- for mirroring vertically
	local point, relativePoint
	local startY, auraOffsetY
	if mirrorVertically then
		point = "BOTTOM"
		relativePoint = "TOP"
		startY = -15
		if self.threatNumericIndicator:IsShown() then
			startY = startY + self.threatNumericIndicator:GetHeight()
		end
		offsetY = - offsetY
		auraOffsetY = -AURA_OFFSET_Y
	else
		point = "TOP"
		relativePoint= "BOTTOM"
		startY = AURA_START_Y
		auraOffsetY = AURA_OFFSET_Y
	end

	if index == 1 then
		if isFriend and numBuffs > 0 then
			-- unit is friendly and there are buffs...debuffs start on bottom
			dbuff:SetPoint(point.."LEFT", self.buffs, relativePoint.."LEFT", 0, -offsetY)
		else
			-- unit is not friendly or there are no buffs...debuffs start on top
			-- we nudge this down a bit because of !beautycase
			dbuff:SetPoint(point.."LEFT", self, relativePoint.."LEFT", AURA_START_X, startY - BEAUTY_NUDGE)
		end
		self.debuffs:SetPoint(point.."LEFT", dbuff, point.."LEFT", 0, 0)
		self.debuffs:SetPoint(relativePoint.."LEFT", dbuff, relativePoint.."LEFT", 0, -auraOffsetY)
		if isFriend or (not isFriend and numBuffs == 0) then
			self.spellbarAnchor = dbuff
		end
	elseif anchorIndex ~= (index - 1) then
		-- anchor index is not the previous index...must be a new row
		dbuff:SetPoint(point.."LEFT", _G[debuffName..anchorIndex], relativePoint.."LEFT", 0, -offsetY)
		self.debuffs:SetPoint(relativePoint.."LEFT", dbuff, relativePoint.."LEFT", 0, -auraOffsetY)
		if isFriend or (not isFriend and numBuffs == 0) then
			self.spellbarAnchor = dbuff
		end
	else
		-- anchor index is the previous index
		-- we tighten up the spacing between debuffs by -1px due to !bc
		dbuff:SetPoint(point.."LEFT", _G[debuffName..(index - 1)], point.."RIGHT", offsetX - BEAUTY_SPACING, 0)
	end
end

do
	-- Frame-specific hooks to prevent taint on secure frames like TargetFrameToT and PetFrame
	-- CRITICAL: Do NOT hook Show on TargetFrame/FocusFrame
	-- Show hooks taint the entire frame update chain including TargetFrameToT
	-- This causes "TargetFrameToT:Show()" taint when PvE mobs have no target
	
	-- Create event frame to monitor aura updates
	local auraWatcher = CreateFrame("Frame")
	auraWatcher:RegisterEvent("UNIT_AURA")
	auraWatcher:RegisterEvent("PLAYER_TARGET_CHANGED")
	auraWatcher:RegisterEvent("PLAYER_FOCUS_CHANGED")
	auraWatcher:SetScript("OnEvent", function(self, event, unit)
		-- CRITICAL: Only handle target and focus, never raid/party/pet units
		if event == "UNIT_AURA" then
			if unit ~= "target" and unit ~= "focus" then
				return
			end
		end
		
		if not InCombatLockdown() then
			if (event == "UNIT_AURA" and unit == "target") or event == "PLAYER_TARGET_CHANGED" then
				if TargetFrame and TargetFrame:IsVisible() then
					TargetAuraColour(TargetFrame)
				end
			elseif (event == "UNIT_AURA" and unit == "focus") or event == "PLAYER_FOCUS_CHANGED" then
				if FocusFrame and FocusFrame:IsVisible() then
					TargetAuraColour(FocusFrame)
				end
			end
		end
	end)
	
	-- Removed Show hooks to prevent taint chain:
	-- hooksecurefunc(TargetFrame, "Show", ...) causes taint on TargetFrameToT
	-- hooksecurefunc(FocusFrame, "Show", ...) causes taint on FocusFrameToT
end
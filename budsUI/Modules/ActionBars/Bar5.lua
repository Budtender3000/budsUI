local K, C, L, _ = select(2, ...):unpack()
if C.ActionBar.Enable ~= true then return end

local _G = _G
local CreateFrame = CreateFrame

--	Setup MultiBarBottomRight as bar #5 by Tukz
local bar = CreateFrame("Frame", "Bar5Holder", UIParent)
local size = C.ActionBar.ButtonSize
local space = C.ActionBar.ButtonSpace

K.UpdateBar5 = function()
	local size = C.ActionBar.ButtonSize
	local space = C.ActionBar.ButtonSpace
	local bar = Bar5Holder
	local rightBars = SavedOptionsPerChar.RightBars or C.ActionBar.RightBars
	local bottomBars = SavedOptionsPerChar.BottomBars or C.ActionBar.BottomBars
	local splitBars = SavedOptionsPerChar.SplitBars
	if splitBars == nil then splitBars = C.ActionBar.SplitBars end

	if rightBars < 3 and bottomBars < 3 then
		bar:Hide()
	else
		bar:Show()
	end

	if rightBars < 3 then
		if splitBars == true then
			bar:SetAllPoints(SplitBarLeft)
		else
			bar:SetAllPoints(ActionBarAnchor)
		end
	else
		bar:SetAllPoints(RightActionBarAnchor)
	end

	for i = 1, 12 do
		local b = _G["MultiBarBottomRightButton"..i]
		local b2 = _G["MultiBarBottomRightButton"..i-1]
		b:ClearAllPoints()
		if splitBars == true and rightBars < 3 then
			if i == 1 then
				b:SetPoint("TOPLEFT", SplitBarLeft, "TOPLEFT", 0, 0)
			elseif i == 4 then
				b:SetPoint("BOTTOMLEFT", SplitBarLeft, "BOTTOMLEFT", 0, 0)
			elseif i == 7 then
				b:SetPoint("TOPLEFT", SplitBarRight, "TOPLEFT", 0, 0)
			elseif i == 10 then
				b:SetPoint("BOTTOMLEFT", SplitBarRight, "BOTTOMLEFT", 0, 0)
			else
				b:SetPoint("LEFT", b2, "RIGHT", space, 0)
			end
		else
			if i == 1 then
				if rightBars < 3 then
					b:SetPoint("TOPLEFT", Bar1Holder, 0, 0)
				else
					b:SetPoint("TOPLEFT", RightActionBarAnchor, "TOPLEFT", 0, 0)
				end
			else
				if rightBars < 3 then
					b:SetPoint("LEFT", b2, "RIGHT", space, 0)
				else
					b:SetPoint("TOP", b2, "BOTTOM", 0, -space)
				end
			end
		end
	end
end
K.UpdateBar5()

-- Hide bar
if C.ActionBar.RightBars < 3 and C.ActionBar.BottomBars < 3 then
	bar:Hide()
end
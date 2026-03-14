local K, C, L, _ = select(2, ...):unpack()
if C.ActionBar.Enable ~= true or C.ActionBar.ToggleMode ~= true then return end

local _G = _G

local ToggleBar = CreateFrame("Frame", "ToggleActionbar", UIParent)

local ToggleBarText = function(i, text, plus, neg)
	if plus then
		ToggleBar[i].Text:SetText(text)
		ToggleBar[i].Text:SetTextColor(0.33, 0.59, 0.33)
	elseif neg then
		ToggleBar[i].Text:SetText(text)
		ToggleBar[i].Text:SetTextColor(0.85, 0.27, 0.27)
	end
end

local MainBars = function()
	if SavedOptionsPerChar.BottomBars == 1 then
		ActionBarAnchor:SetHeight(C.ActionBar.ButtonSize)
		ToggleBarText(1, "+ + +", true)
		Bar2Holder:Hide()
		if K.UpdateBar5 then K.UpdateBar5() end
	elseif SavedOptionsPerChar.BottomBars == 2 then
		ActionBarAnchor:SetHeight(C.ActionBar.ButtonSize * 2 + C.ActionBar.ButtonSpace)
		Bar2Holder:Show()
		if K.UpdateBar5 then K.UpdateBar5() end
		if SavedOptionsPerChar.SplitBars == true then
			ToggleBarText(1, "- - -", false, true)
		else
			ToggleBarText(1, "+ + +", true)
		end
	elseif SavedOptionsPerChar.BottomBars == 3 then
		ActionBarAnchor:SetHeight((C.ActionBar.ButtonSize * 3) + (C.ActionBar.ButtonSpace * 2))
		ToggleBarText(1, "- - -", false, true)
		Bar2Holder:Show()
		if K.UpdateBar5 then K.UpdateBar5() end
	end

	if SavedOptionsPerChar.SplitBars == true then
		ToggleBar[3]:SetHeight(ActionBarAnchor:GetHeight())
		ToggleBar[4]:SetHeight(ActionBarAnchor:GetHeight())
		if SavedOptionsPerChar.BottomBars == 1 then
			for i = 1, 3 do
				local b = _G["MultiBarBottomRightButton"..i]
				b:SetAlpha(0)
				b:SetScale(0.000001)
			end
			for i = 7, 9 do
				local b = _G["MultiBarBottomRightButton"..i]
				b:SetAlpha(0)
				b:SetScale(0.000001)
			end
		else
			for i = 1, 3 do
				local b = _G["MultiBarBottomRightButton"..i]
				b:SetAlpha(1)
				b:SetScale(1)
			end
			for i = 7, 9 do
				local b = _G["MultiBarBottomRightButton"..i]
				b:SetAlpha(1)
				b:SetScale(1)
			end
		end
	end
end

local RightBars = function()
	if SavedOptionsPerChar.RightBars == 0 then
		if not C.ActionBar.PetBarHorizontal == true then
			PetActionBarAnchor:ClearAllPoints()
			PetActionBarAnchor:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -18, 320)
		end
		ToggleBar[2]:SetWidth(C.ActionBar.ButtonSize)
		ToggleBarText(2, "< < <", true)
		RightActionBarAnchor:Hide()
		Bar3Holder:Hide()
		Bar4Holder:Hide()
		if K.UpdateBar5 then K.UpdateBar5() end
	elseif SavedOptionsPerChar.RightBars == 1 then
		RightActionBarAnchor:SetWidth(C.ActionBar.ButtonSize)
		if not C.ActionBar.PetBarHorizontal == true then
			PetActionBarAnchor:ClearAllPoints()
			PetActionBarAnchor:SetPoint("RIGHT", RightActionBarAnchor, "LEFT", 0, 0)
		end
		ToggleBar[2]:SetWidth(C.ActionBar.ButtonSize)
		ToggleBarText(2, "> > >", false, true)
		RightActionBarAnchor:Show()
		Bar3Holder:Show()
		Bar4Holder:Hide()
		if K.UpdateBar5 then K.UpdateBar5() end
	elseif SavedOptionsPerChar.RightBars == 2 then
		RightActionBarAnchor:SetWidth(C.ActionBar.ButtonSize * 2 + C.ActionBar.ButtonSpace)
		if not C.ActionBar.PetBarHorizontal == true then
			PetActionBarAnchor:ClearAllPoints()
			PetActionBarAnchor:SetPoint("RIGHT", RightActionBarAnchor, "LEFT", 0, 0)
		end
		ToggleBar[2]:SetWidth(C.ActionBar.ButtonSize * 2 + C.ActionBar.ButtonSpace)
		ToggleBarText(2, "> > >", false, true)
		RightActionBarAnchor:Show()
		Bar3Holder:Show()
		Bar4Holder:Show()
		if K.UpdateBar5 then K.UpdateBar5() end
	elseif SavedOptionsPerChar.RightBars == 3 then
		RightActionBarAnchor:SetWidth((C.ActionBar.ButtonSize * 3) + (C.ActionBar.ButtonSpace * 2))
		if not C.ActionBar.PetBarHorizontal == true then
			PetActionBarAnchor:ClearAllPoints()
			PetActionBarAnchor:SetPoint("RIGHT", RightActionBarAnchor, "LEFT", 0, 0)
		end
		ToggleBar[2]:SetWidth((C.ActionBar.ButtonSize * 3) + (C.ActionBar.ButtonSpace * 2))
		ToggleBarText(2, "> > >", false, true)
		RightActionBarAnchor:Show()
		Bar3Holder:Show()
		Bar4Holder:Show()
		if K.UpdateBar3 then K.UpdateBar3() end
		if K.UpdateBar4 then K.UpdateBar4() end
		if K.UpdateBar5 then K.UpdateBar5() end
	else
		-- Ensure Bar3 and Bar4 layout is correct even for < 3 bars
		if K.UpdateBar3 then K.UpdateBar3() end
		if K.UpdateBar4 then K.UpdateBar4() end
	end
end

local SplitBars = function()
	if SavedOptionsPerChar.SplitBars == true and SavedOptionsPerChar.RightBars ~= 3 then
		if SavedOptionsPerChar.SplitBars == true then
			ToggleBar[3]:ClearAllPoints()
			ToggleBar[3]:SetPoint("BOTTOMLEFT", SplitBarRight, "BOTTOMRIGHT", C.ActionBar.ButtonSpace, 0)
			ToggleBar[4]:ClearAllPoints()
			ToggleBar[4]:SetPoint("BOTTOMRIGHT", SplitBarLeft, "BOTTOMLEFT", -C.ActionBar.ButtonSpace, 0)
			VehicleButtonAnchor:ClearAllPoints()
			VehicleButtonAnchor:SetPoint("BOTTOMRIGHT", SplitBarLeft, "BOTTOMLEFT", -C.ActionBar.ButtonSpace, 0)
			if SavedOptionsPerChar.BottomBars == 2 then
				ToggleBarText(3, "<\n<\n<", false, true)
				ToggleBarText(4, ">\n>\n>", false, true)
			else
				ToggleBarText(3, "<\n<", false, true)
				ToggleBarText(4, ">\n>", false, true)
			end
			Bar5Holder:Show()
		elseif SavedOptionsPerChar.SplitBars == false then
			ToggleBar[3]:ClearAllPoints()
			ToggleBar[3]:SetPoint("BOTTOMLEFT", ActionBarAnchor, "BOTTOMRIGHT", C.ActionBar.ButtonSpace, 0)
			ToggleBar[4]:ClearAllPoints()
			ToggleBar[4]:SetPoint("BOTTOMRIGHT", ActionBarAnchor, "BOTTOMLEFT", -C.ActionBar.ButtonSpace, 0)
			VehicleButtonAnchor:ClearAllPoints()
			VehicleButtonAnchor:SetPoint("BOTTOMRIGHT", ActionBarAnchor, "BOTTOMLEFT", -C.ActionBar.ButtonSpace, 0)
			if SavedOptionsPerChar.BottomBars == 2 then
				ToggleBarText(3, ">\n>\n>", true)
				ToggleBarText(4, "<\n<\n<", true)
			else
				ToggleBarText(3, ">\n>", true)
				ToggleBarText(4, "<\n<", true)
			end
			Bar5Holder:Hide()
			SplitBarLeft:Hide()
			SplitBarRight:Hide()
		end
	end
end

local LockCheck = function(i)
	if SavedOptionsPerChar.BarsLocked == true then
		ToggleBar[i].Text:SetText("U")
		ToggleBar[i].Text:SetTextColor(0.33, 0.59, 0.33)
	elseif SavedOptionsPerChar.BarsLocked == false then
		ToggleBar[i].Text:SetText("L")
		ToggleBar[i].Text:SetTextColor(0.85, 0.27, 0.27)
	else
		ToggleBar[i].Text:SetText("L")
		ToggleBar[i].Text:SetTextColor(0.85, 0.27, 0.27)
	end
	
	if not InCombatLockdown() then
		local locked = SavedOptionsPerChar.BarsLocked == true
		for j = 1, 4 do
			if ToggleBar[j] then
				ToggleBar[j]:EnableMouse(not locked)
			end
		end
	end
end

for i = 1, 5 do
	ToggleBar[i] = CreateFrame("Frame", "ToggleBar"..i, ToggleBar)
	ToggleBar[i]:EnableMouse(true)
	ToggleBar[i]:SetAlpha(0)
	ToggleBar[i].Text = ToggleBar[i]:CreateFontString(nil, "OVERLAY")
	ToggleBar[i].Text:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
	ToggleBar[i].Text:SetPoint("CENTER", 2, 0)

	if i == 1 then
		ToggleBar[i]:CreatePanel("CreateBackdrop", ActionBarAnchor:GetWidth(), C.ActionBar.ButtonSize / 1.5, "BOTTOM", ActionBarAnchor, "TOP", 0, C.ActionBar.ButtonSpace)
		ToggleBarText(i, "- - -", false, true)

		ToggleBar[i]:SetScript("OnMouseDown", function()
			if InCombatLockdown() then K.Print("|cffffff00"..ERR_NOT_IN_COMBAT.."|r") return end
			
			SavedOptionsPerChar.BottomBars = SavedOptionsPerChar.BottomBars + 1
			if SavedOptionsPerChar.BottomBars > 3 then
				SavedOptionsPerChar.BottomBars = 1
			end

			-- Conflict resolution
			if SavedOptionsPerChar.BottomBars == 3 then
				SavedOptionsPerChar.SplitBars = false
				if SavedOptionsPerChar.RightBars == 3 then
					SavedOptionsPerChar.RightBars = 2
					RightBars()
				end
			end

			MainBars()
		end)
		ToggleBar[i]:SetScript("OnEvent", MainBars)
	elseif i == 2 then
		ToggleBar[i]:CreatePanel("CreateBackdrop", RightActionBarAnchor:GetWidth(), C.ActionBar.ButtonSize / 1.5, "TOPRIGHT", RightActionBarAnchor, "BOTTOMRIGHT", 0, -C.ActionBar.ButtonSpace)
		ToggleBar[i]:SetFrameStrata("LOW")
		ToggleBarText(i, "> > >", false, true)

		ToggleBar[i]:SetScript("OnMouseDown", function()
			if InCombatLockdown() then K.Print("|cffffff00"..ERR_NOT_IN_COMBAT.."|r") return end
			
			SavedOptionsPerChar.RightBars = SavedOptionsPerChar.RightBars - 1
			if SavedOptionsPerChar.RightBars < 0 then
				SavedOptionsPerChar.RightBars = 3
			end

			-- Conflict resolution
			if SavedOptionsPerChar.RightBars == 3 then
				SavedOptionsPerChar.SplitBars = false
				if SavedOptionsPerChar.BottomBars == 3 then
					SavedOptionsPerChar.BottomBars = 2
					MainBars()
				end
			end

			RightBars()
		end)
		ToggleBar[i]:SetScript("OnEvent", RightBars)
	elseif i == 3 then
		if SavedOptionsPerChar.SplitBars == true and SavedOptionsPerChar.RightBars ~= 3 then
			ToggleBar[i]:CreatePanel("CreateBackdrop", C.ActionBar.ButtonSize / 1.5, ActionBarAnchor:GetHeight(), "BOTTOMLEFT", SplitBarRight, "BOTTOMRIGHT", C.ActionBar.ButtonSpace, 0)
			ToggleBarText(i, "<\n<", false, true)
			ToggleBar[i]:SetFrameLevel(SplitBarRight:GetFrameLevel() + 1)
		end
	elseif i == 4 then
		if SavedOptionsPerChar.SplitBars == true and SavedOptionsPerChar.RightBars ~= 3 then
			ToggleBar[i]:CreatePanel("CreateBackdrop", C.ActionBar.ButtonSize / 1.5, ActionBarAnchor:GetHeight(), "BOTTOMRIGHT", SplitBarLeft, "BOTTOMLEFT", -C.ActionBar.ButtonSpace, 0)
			ToggleBarText(i, ">\n>", false, true)
			ToggleBar[i]:SetFrameLevel(SplitBarLeft:GetFrameLevel() + 1)
		end
	elseif i == 5 then
		ToggleBar[i]:CreatePanel("CreateBorder", 19, 19, "BOTTOMRIGHT", Minimap, "BOTTOMLEFT", -4, -2)
		ToggleBar[i]:SetBorderSize(10)
		ToggleBar[i].Text:SetPoint("CENTER", 0, 0)

		ToggleBar[i]:SetScript("OnMouseDown", function()
			if InCombatLockdown() then return end

			if SavedOptionsPerChar.BarsLocked == true then
				SavedOptionsPerChar.BarsLocked = false
			elseif SavedOptionsPerChar.BarsLocked == false then
				SavedOptionsPerChar.BarsLocked = true
			end

			LockCheck(i)
		end)
		ToggleBar[i]:SetScript("OnEvent", function() LockCheck(i) end)
	end

	if i == 3 or i == 4 then
		ToggleBar[i]:SetScript("OnMouseDown", function()
			if InCombatLockdown() then K.Print("|cffffff00"..ERR_NOT_IN_COMBAT.."|r") return end

			if SavedOptionsPerChar.SplitBars == false then
				SavedOptionsPerChar.SplitBars = true
				-- Conflict resolution: SplitBars is incompatible with 3 bars on either side
				if SavedOptionsPerChar.BottomBars == 3 then
					SavedOptionsPerChar.BottomBars = 2
					MainBars()
				end
				if SavedOptionsPerChar.RightBars == 3 then
					SavedOptionsPerChar.RightBars = 2
					RightBars()
				end
			else
				SavedOptionsPerChar.SplitBars = false
			end
			SplitBars()
			MainBars() -- Ensure MainBars updates logic for text/visibility
		end)
		ToggleBar[i]:SetScript("OnEvent", SplitBars)
	end

	ToggleBar[i]:RegisterEvent("PLAYER_ENTERING_WORLD")
	ToggleBar[i]:RegisterEvent("PLAYER_REGEN_DISABLED")
	ToggleBar[i]:RegisterEvent("PLAYER_REGEN_ENABLED")

	ToggleBar[i]:SetScript("OnEnter", function()
		if InCombatLockdown() then return end
		if i == 2 then
			K:UIFrameFadeIn(ToggleBar[i], 0.4, ToggleBar[i]:GetAlpha(), 1)
		elseif i == 3 or i == 4 then
			K:UIFrameFadeIn(ToggleBar[3], 0.4, ToggleBar[3]:GetAlpha(), 1)
			K:UIFrameFadeIn(ToggleBar[4], 0.4, ToggleBar[4]:GetAlpha(), 1)
			VehicleButtonAnchor:ClearAllPoints()
			VehicleButtonAnchor:SetPoint("BOTTOMRIGHT", ToggleBar[4], "BOTTOMLEFT", -C.ActionBar.ButtonSpace, 0)
		else
			K:UIFrameFadeIn(ToggleBar[i], 0.4, ToggleBar[i]:GetAlpha(), 1)
		end
	end)

	ToggleBar[i]:SetScript("OnLeave", function()
		if i == 2 then
			K:UIFrameFadeOut(ToggleBar[i], 1, ToggleBar[i]:GetAlpha(), 0)
		elseif i == 3 or i == 4 then
			if InCombatLockdown() then return end
			K:UIFrameFadeOut(ToggleBar[3], 1, ToggleBar[3]:GetAlpha(), 0)
			K:UIFrameFadeOut(ToggleBar[4], 1, ToggleBar[4]:GetAlpha(), 0)
			VehicleButtonAnchor:ClearAllPoints()
			if SavedOptionsPerChar.SplitBars == true then
				VehicleButtonAnchor:SetPoint("BOTTOMRIGHT", SplitBarLeft, "BOTTOMLEFT", -C.ActionBar.ButtonSpace, 0)
			else
				VehicleButtonAnchor:SetPoint("BOTTOMRIGHT", ActionBarAnchor, "BOTTOMLEFT", -C.ActionBar.ButtonSpace, 0)
			end
		else
			K:UIFrameFadeOut(ToggleBar[i], 1, ToggleBar[i]:GetAlpha(), 0)
		end
	end)
end
local K, C, L, _ = select(2, ...):unpack()
if C.ActionBar.Enable ~= true or K.Class ~= "SHAMAN" then return end

-- We just use default totem bar for shaman
-- We parent it to our shapeshift bar.

if K.Class == "SHAMAN" then
	if MultiCastActionBarFrame then
		MultiCastActionBarFrame:SetScript("OnUpdate", nil)
		MultiCastActionBarFrame:SetScript("OnShow", nil)
		MultiCastActionBarFrame:SetScript("OnHide", nil)
		MultiCastActionBarFrame:SetParent(ShiftHolder)
		MultiCastActionBarFrame:ClearAllPoints()
		MultiCastActionBarFrame:SetPoint("BOTTOMLEFT", ShiftHolder, -3, 23)
 
		local pendingTotemButtons = {}
		local totemDeferFrame = CreateFrame("Frame")
		totemDeferFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
		totemDeferFrame:SetScript("OnEvent", function(...)
			for button in pairs(pendingTotemButtons) do
				if button then
					button:SetAllPoints(button.slotButton)
				end
			end
			pendingTotemButtons = {}
		end)

		hooksecurefunc("MultiCastActionButton_Update", function(actionbutton)
			if not InCombatLockdown() then
				actionbutton:SetAllPoints(actionbutton.slotButton)
			else
				pendingTotemButtons[actionbutton] = true
			end
		end)
 
		-- MultiCastActionBarFrame.SetParent = K.Noop
		-- MultiCastActionBarFrame.SetPoint = K.Noop
		-- MultiCastRecallSpellButton.SetPoint = K.Noop
	end
end
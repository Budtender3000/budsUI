local K, C, L, _ = select(2, ...):unpack()
if C.ActionBar.Enable ~= true then return end

local _G = _G
local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame
local UIParent = UIParent

if C.ActionBar.PetBarHide then PetActionBarAnchor:Hide() return end

-- Create bar
local bar = CreateFrame("Frame", "PetHolder", UIParent, "SecureHandlerStateTemplate")
bar:SetAllPoints(PetActionBarAnchor)

bar:RegisterEvent("PET_BAR_HIDE")
bar:RegisterEvent("PET_BAR_UPDATE")
bar:RegisterEvent("PET_BAR_UPDATE_COOLDOWN")
bar:RegisterEvent("PET_BAR_UPDATE_USABLE")
bar:RegisterEvent("PLAYER_CONTROL_GAINED")
bar:RegisterEvent("PLAYER_CONTROL_LOST")
bar:RegisterEvent("PLAYER_FARSIGHT_FOCUS_CHANGED")
bar:RegisterEvent("PLAYER_LOGIN")
bar:RegisterEvent("PLAYER_REGEN_ENABLED")
bar:RegisterEvent("UNIT_AURA")
bar:RegisterEvent("UNIT_FLAGS")
bar:RegisterEvent("UNIT_PET")
bar:SetScript("OnEvent", function(self, event, arg1)
	if event == "PLAYER_LOGIN" then
		-- Setup buttons in PLAYER_LOGIN to avoid taint
		if InCombatLockdown() then return end
		
		for i = 1, 10 do
			local button = _G["PetActionButton"..i]
			button:SetSize(C.ActionBar.ButtonSize, C.ActionBar.ButtonSize)
			button:ClearAllPoints()
			button:SetParent(PetHolder)
			
			if i == 1 then
				if C.ActionBar.PetBarHorizontal == true then
					button:SetPoint("BOTTOMLEFT", 0, 0)
				else
					button:SetPoint("TOPLEFT", 0, 0)
				end
			else
				if C.ActionBar.PetBarHorizontal == true then
					button:SetPoint("LEFT", _G["PetActionButton"..i-1], "RIGHT", C.ActionBar.ButtonSpace, 0)
				else
					button:SetPoint("TOP", _G["PetActionButton"..i-1], "BOTTOM", 0, -C.ActionBar.ButtonSpace)
				end
			end
			button:Show()
			self:SetAttribute("addchild", button)
		end
		
		PetActionBarFrame.showgrid = 1
		RegisterStateDriver(self, "visibility", "[pet,novehicleui,nobonusbar:5] show; hide")
		if K.PetBarUpdate then
			hooksecurefunc("PetActionBar_Update", function()
				if InCombatLockdown() then
					self.needsPetBarUpdate = true
				else
					K.PetBarUpdate()
				end
			end)
		end
	elseif event == "PET_BAR_UPDATE" or (event == "UNIT_PET" and arg1 == "player")
	or event == "PLAYER_CONTROL_LOST" or event == "PLAYER_CONTROL_GAINED" or event == "PLAYER_FARSIGHT_FOCUS_CHANGED" 
	or (event == "UNIT_FLAGS" and arg1 == "pet")
	or (event == "UNIT_AURA" and arg1 == "pet") then
		if K.PetBarUpdate then
			K.PetBarUpdate()
		end
	elseif event == "PET_BAR_UPDATE_COOLDOWN" then
		PetActionBar_UpdateCooldowns()
	elseif event == "PET_BAR_HIDE" or event == "PET_BAR_UPDATE_USABLE" then
		if InCombatLockdown() then
			self.needsStyling = true
		else
			if K.StylePet then
				K.StylePet()
			end
			self.needsStyling = false
		end
	elseif event == "PLAYER_REGEN_ENABLED" then
		if self.needsPetBarUpdate then
			if K.PetBarUpdate then
				K.PetBarUpdate()
			end
			self.needsPetBarUpdate = false
		end
		if self.needsStyling then
			if K.StylePet then
				K.StylePet()
			end
			self.needsStyling = false
		end
	end
end)
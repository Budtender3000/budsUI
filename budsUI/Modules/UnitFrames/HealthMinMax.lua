local K, C, L, _ = select(2, ...):unpack()
if C.Unitframe.Enable ~= true then return end


if C.Unitframe.ClassHealth == false and C.Unitframe.PercentHealth == true then
	hooksecurefunc("HealthBar_OnValueChanged", function(self, value, smooth)
		-- Skip secure frames to prevent taint
		-- self is the health bar, check the unit property
		if not self or not self.unit then return end
		local unitType = self.unit
		-- Skip pet, ToT, raid, and boss frames
		if unitType == "pet" or unitType == "targettarget" or unitType == "focustarget" or
		   unitType:match("^raid%d+") or unitType:match("^party%d+pet") or unitType:match("^raid%d+pet") or
		   unitType:match("^boss%d+") then
			return
		end
		
		if not value then return end
		local r, g, b
		local vMin, vMax = self:GetMinMaxValues()

		if value < vMin or value > vMax then return end

		if (vMax - vMin) > 0 then
			value = (value - vMin)/(vMax - vMin)
		else
			value = 0
		end
		if value > .5 then
			r = (1 - value)*2
			g = 1
		else
			r = 1
			g = value * 2
		end
		b = 0
		self:SetStatusBarColor(r, g, b)
	end)
end
local K, C, L, _ = select(2, ...):unpack()
if C.Unitframe.Enable ~= true then return end


if C.Unitframe.ClassHealth == false and C.Unitframe.PercentHealth == true then
	hooksecurefunc("HealthBar_OnValueChanged", function(self, value, smooth)
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
local K, C, L, _ = select(2, ...):unpack()
if C.Unitframe.Enable ~= true then return end


if C.Unitframe.ClassHealth == false and C.Unitframe.PercentHealth == true then
	local function updateHealthColor(self, value, smooth)
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
	end
	
	-- OnUpdate delay to prevent taint during Blizzard's frame update chain
	local colorQueue = {}
	local colorFrame = CreateFrame("Frame")
	colorFrame:SetScript("OnUpdate", function(self)
		for statusBar, _ in pairs(colorQueue) do
			local value = statusBar:GetValue()
			updateHealthColor(statusBar, value)
			colorQueue[statusBar] = nil
		end
	end)
	
	-- Hook specific frames instead of global function to prevent taint
	if PlayerFrameHealthBar then
		hooksecurefunc(PlayerFrameHealthBar, "SetValue", function(self)
			colorQueue[self] = true
		end)
	end
	if TargetFrameHealthBar then
		hooksecurefunc(TargetFrameHealthBar, "SetValue", function(self)
			colorQueue[self] = true
		end)
	end
	if FocusFrameHealthBar then
		hooksecurefunc(FocusFrameHealthBar, "SetValue", function(self)
			colorQueue[self] = true
		end)
	end
end
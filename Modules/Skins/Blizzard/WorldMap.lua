local K, C, L, _ = select(2, ...):unpack()
if C.Skins.WorldMap ~= true or IsAddOnLoaded("Mapster") == true or IsAddOnLoaded("Aurora") then return end

local floor = math.floor
local select = select
local CreateFrame = CreateFrame
local GetPlayerMapPosition = GetPlayerMapPosition
local IsInInstance = IsInInstance

-- NEEDS TO BE RECODED

local function InitializeMap()
	local WorldMap_Tweak = CreateFrame("Frame")
	WorldMap_Tweak:RegisterEvent("PLAYER_LOGIN")
	WorldMap_Tweak:SetScript("OnEvent", function(self, event, ...)
		-- Execute login logic
	end)
	BlackoutWorld:Hide()
	WorldMapFrame:EnableKeyboard(false)
	WorldMapFrame:EnableMouse(false)
	WorldMapFrame:SetAttribute("UIPanelLayout-area", "center")
	WorldMapFrame:SetAttribute("UIPanelLayout-allowOtherPanels", true)
	UIPanelWindows["WorldMapFrame"] = {area = "center"}
	hooksecurefunc(BlackoutWorld, "Show", function(self)
		self:Hide()
		UIPanelWindows["WorldMapFrame"] = {area = "center"}
		WorldMapFrame:EnableKeyboard(false)
		WorldMapFrame:EnableMouse(false)
		WorldMapFrame:SetAttribute("UIPanelLayout-area", "center")
		WorldMapFrame:SetAttribute("UIPanelLayout-allowOtherPanels", true)
	end)

	hooksecurefunc(WorldMapFrame, "Show", function(self)
		self:SetScale(0.80)
		self:SetAlpha(0.90)
		WorldMapTooltip:SetScale(1/0.80)
	end)
end

if InCombatLockdown() then
	local initFrame = CreateFrame("Frame")
	initFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
	initFrame:SetScript("OnEvent", function(self)
		InitializeMap()
		self:UnregisterAllEvents()
	end)
else
	InitializeMap()
end

local WorldMap_Coords = CreateFrame("Frame", "CoordsFrame", WorldMapFrame)
local Font_Height = select(2, WorldMapQuestShowObjectivesText:GetFont())*1.1
WorldMap_Coords:SetFrameLevel(90)
WorldMap_Coords:FontString("PlayerText", C.Media.Font, Font_Height, C.Media.Font_Style)
WorldMap_Coords:FontString("MouseText", C.Media.Font, Font_Height, C.Media.Font_Style)
WorldMap_Coords.PlayerText:SetTextColor(WorldMapQuestShowObjectivesText:GetTextColor())
WorldMap_Coords.MouseText:SetTextColor(WorldMapQuestShowObjectivesText:GetTextColor())
WorldMap_Coords.PlayerText:SetPoint("BOTTOMLEFT", WorldMapDetailFrame, "BOTTOMLEFT", 5, 5)
WorldMap_Coords.PlayerText:SetText("Player: 0, 0")
WorldMap_Coords.MouseText:SetPoint("BOTTOMLEFT", WorldMap_Coords.PlayerText, "TOPLEFT", 0, 5)
WorldMap_Coords.MouseText:SetText("Mouse: 0, 0")
local timeElapsed = 0

WorldMapFrame:HookScript("OnUpdate", function(self, elapsed)
	timeElapsed = timeElapsed + elapsed

	if timeElapsed >= 0.1 then
		local x, y = GetPlayerMapPosition("player")
		x = floor(100 * x)
		y = floor(100 * y)
		if x ~= 0 and y ~= 0 then
			WorldMap_Coords.PlayerText:SetFormattedText("%s: %d, %d", PLAYER, x, y)
		else
			WorldMap_Coords.PlayerText:SetText(" ")
		end

		local scale = WorldMapDetailFrame:GetEffectiveScale()
		local width = WorldMapDetailFrame:GetWidth()
		local height = WorldMapDetailFrame:GetHeight()
		local centerX, centerY = WorldMapDetailFrame:GetCenter()
		local cursorX, cursorY = GetCursorPosition()
		local adjustedX = (cursorX / scale - (centerX - (width/2))) / width
		local adjustedY = (centerY + (height/2) - cursorY / scale) / height

		if (adjustedX >= 0 and adjustedY >= 0 and adjustedX <= 1 and adjustedY <= 1) then
			adjustedX = floor(100 * adjustedX)
			adjustedY = floor(100 * adjustedY)
			WorldMap_Coords.MouseText:SetFormattedText("%s: %d, %d", MOUSE_LABEL, adjustedX, adjustedY)
		else
			WorldMap_Coords.MouseText:SetText(" ")
		end

		timeElapsed = 0
	end
end)

-- Dropdown on full map is scaled incorrectly
WorldMapContinentDropDownButton:HookScript("OnClick", function() DropDownList1:SetScale(C.General.UIScale) end)
WorldMapZoneDropDownButton:HookScript("OnClick", function(self)
	DropDownList1:SetScale(C.General.UIScale)
	DropDownList1:ClearAllPoints()
	DropDownList1:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 2, -4)
end)
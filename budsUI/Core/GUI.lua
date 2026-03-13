local K, C, L, _ = select(2, ...):unpack()
if not IsAddOnLoaded("budsUI_Config") then return end

local pairs = pairs

-- This Module loads new user settings if budsUI_Config is loaded
-- Initialize Profile System
if not GUIConfigAll then GUIConfigAll = {} end
if not GUIConfigAll.Profiles then 
	GUIConfigAll.Profiles = {} 
	GUIConfigAll.Profiles["Default"] = {}
	GUIConfigAll.Profiles["Budtender Preset"] = {}
	-- Migration: Move old global settings to Budtender Preset profile
	-- Initialize Budtender Preset with hardcoded settings
	GUIConfigAll.Profiles["Budtender Preset"] = {}
	if K.BudtenderPreset then
		for group, options in pairs(K.BudtenderPreset) do
			GUIConfigAll.Profiles["Budtender Preset"][group] = {}
			for option, value in pairs(options) do
				GUIConfigAll.Profiles["Budtender Preset"][group][option] = value
			end
		end
	end
	GUIConfigSettings = nil
end
-- Ensure Budtender Preset is always available (even if wiped)
if not GUIConfigAll.Profiles["Budtender Preset"] or next(GUIConfigAll.Profiles["Budtender Preset"]) == nil then
	GUIConfigAll.Profiles["Budtender Preset"] = {}
	if K.BudtenderPreset then
		for group, options in pairs(K.BudtenderPreset) do
			GUIConfigAll.Profiles["Budtender Preset"][group] = {}
			for option, value in pairs(options) do
				GUIConfigAll.Profiles["Budtender Preset"][group][option] = value
			end
		end
	end
end
if not GUIConfigAll.CharacterMap then GUIConfigAll.CharacterMap = {} end

local realmKey = K.Realm.."-"..K.Name
local activeProfile = GUIConfigAll.CharacterMap[realmKey] or "Default"
if not GUIConfigAll.Profiles[activeProfile] then activeProfile = "Default" end


-- Migration: If this character had "Per Character" settings enabled, move them to a new profile
if GUIConfigAll[K.Realm] and GUIConfigAll[K.Realm][K.Name] == true and GUIConfig then
	local charProfileName = K.Name.."-"..K.Realm
	if not GUIConfigAll.Profiles[charProfileName] then
		GUIConfigAll.Profiles[charProfileName] = {}
		for k, v in pairs(GUIConfig) do
			GUIConfigAll.Profiles[charProfileName][k] = v
		end
	end
	GUIConfigAll.CharacterMap[realmKey] = charProfileName
	GUIConfigAll[K.Realm][K.Name] = nil -- Clean up old flag
	activeProfile = charProfileName
	GUIConfig = nil
end

local profileSettings = GUIConfigAll.Profiles[activeProfile]

-- Load profile settings into C
if profileSettings then
	for group, options in pairs(profileSettings) do
		if C[group] then
			if group == "MoverPositions" then
				-- Special handling for movers: we want to overwrite the entire table
				C[group] = {}
				for option, value in pairs(options) do
					C[group][option] = value
				end
			else
				for option, value in pairs(options) do
					if C[group][option] ~= nil then
						C[group][option] = value
					end
				end
			end
		end
	end
end
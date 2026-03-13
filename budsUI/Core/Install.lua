local K, C, L, _ = select(2, ...):unpack()

local _G = _G
local format = format
local min, max = math.min, math.max
local match = string.match
local unpack, select = unpack, select
local print = print
local CreateFrame = CreateFrame
local IsAddOnLoaded = IsAddOnLoaded
local SetCVar = SetCVar
local ReloadUI = ReloadUI
local ChatFrame_AddMessageGroup = ChatFrame_AddMessageGroup
local ChatFrame_RemoveAllMessageGroups = ChatFrame_RemoveAllMessageGroups
local ChatFrame_AddChannel = ChatFrame_AddChannel
local ChatFrame_RemoveChannel = ChatFrame_RemoveChannel
local ChangeChatColor = ChangeChatColor
local ToggleChatColorNamesByClassGroup = ToggleChatColorNamesByClassGroup
local FCF_ResetChatWindows = FCF_ResetChatWindows
local FCF_SetLocked = FCF_SetLocked
local FCF_DockFrame, FCF_UnDockFrame = FCF_DockFrame, FCF_UnDockFrame
local FCF_OpenNewWindow = FCF_OpenNewWindow
local FCF_SavePositionAndDimensions = FCF_SavePositionAndDimensions
local FCF_GetChatWindowInfo = FCF_GetChatWindowInfo
local FCF_SetWindowName = FCF_SetWindowName
local FCF_StopDragging = FCF_StopDragging
local FCF_SetChatWindowFontSize = FCF_SetChatWindowFontSize
local NUM_CHAT_WINDOWS = NUM_CHAT_WINDOWS
local LOOT, GENERAL, TRADE = LOOT, GENERAL, TRADE

local Install = CreateFrame("Frame", nil, UIParent)

-- Simple Install
local function InstallUI()
	K.SafeSetCVar("ConsolidateBuffs", 0)
	K.SafeSetCVar("ConversationMode", "inline")
	K.SafeSetCVar("RotateMinimap", 0)
	K.SafeSetCVar("ShowAllSpellRanks", 0) -- No one needs this shit.
	K.SafeSetCVar("ShowClassColorInNameplate", 1)
	K.SafeSetCVar("SpamFilter", 0)
	K.SafeSetCVar("UberTooltips", 1)
	K.SafeSetCVar("WholeChatWindowClickable", 0)
	K.SafeSetCVar("alwaysShowActionBars", 1)
	K.SafeSetCVar("autoDismount", 1)
	K.SafeSetCVar("autoQuestProgress", 1)
	K.SafeSetCVar("autoQuestWatch", 1)
	K.SafeSetCVar("buffDurations", 1)
	K.SafeSetCVar("cameraDistanceMax", 50)
	K.SafeSetCVar("chatMouseScroll", 1)
	K.SafeSetCVar("chatStyle", "classic", "chatStyle") -- https://goo.gl/3v6Mwj
	K.SafeSetCVar("colorblindMode", 0)
	K.SafeSetCVar("gameTip", 0)
	K.SafeSetCVar("lockActionBars", 1)
	K.SafeSetCVar("lootUnderMouse", 0)
	K.SafeSetCVar("mapQuestDifficulty", 1)
	K.SafeSetCVar("maxfpsbk", 0)
	K.SafeSetCVar("removeChatDelay", 1)
	K.SafeSetCVar("screenshotQuality", 10)
	K.SafeSetCVar("scriptErrors", 0)
	K.SafeSetCVar("showLootSpam", 1)
	K.SafeSetCVar("showNewbieTips", 0)
	K.SafeSetCVar("showTutorials", 0)
	K.SafeSetCVar("taintLog", 0)
	K.SafeSetCVar("threatWarning", 3)
	K.SafeSetCVar("useUiScale", 1)
	local screenHeight = K.ScreenHeight or tonumber(match(({GetScreenResolutions()})[GetCurrentResolution()] or "", "%d+x(%d+)"))
	if screenHeight and screenHeight > 0 then
		K.SafeSetCVar("uiScale", 768 / screenHeight)
	end
	K.SafeSetCVar("violenceLevel", 5)

	InterfaceOptionsControlsPanelAutoLootKeyDropDown:SetValue("SHIFT")
	InterfaceOptionsControlsPanelAutoLootKeyDropDown:RefreshValue()

	InterfaceOptionsCombatPanelSelfCastKeyDropDown:SetValue("ALT")
	InterfaceOptionsCombatPanelSelfCastKeyDropDown:RefreshValue()

	if C.General.DeveloperMode == true then
		K.SafeSetCVar("scriptErrors", 1)
	end

	FCF_ResetChatWindows()
	FCF_SetLocked(ChatFrame1, 1)
	FCF_DockFrame(ChatFrame2)
	FCF_SetLocked(ChatFrame2, 1)

	FCF_OpenNewWindow(LOOT)
	FCF_DockFrame(ChatFrame3)
	FCF_SetLocked(ChatFrame3, 1)
	ChatFrame3:Show()

	-- Setting chat frames
	if C.Chat.Enable == true and not (select(4, GetAddOnInfo("Prat-3.0")) or select(4, GetAddOnInfo("Chatter"))) then
		for i = 1, NUM_CHAT_WINDOWS do
			local frame = _G[format("ChatFrame%s", i)]
			local chatFrameId = frame:GetID()
			local chatName = FCF_GetChatWindowInfo(chatFrameId)

			-- Move general chat to bottom left
			if i == 1 then
				frame:ClearAllPoints()
				frame:SetPoint(unpack(C.Position.Chat))
			end

			-- Save new default position and dimension
			FCF_SavePositionAndDimensions(frame)
			FCF_StopDragging(frame)

			-- Set default font size
			FCF_SetChatWindowFontSize(nil, frame, 12)

			-- Rename chat tabs.
			if i == 1 then
				FCF_SetWindowName(frame, GENERAL)
			elseif i == 2 then
				FCF_SetWindowName(frame, GUILD_EVENT_LOG)
			elseif i == 3 then
				FCF_SetWindowName(frame, LOOT.." / "..TRADE)
			end
		end

		ChatFrame_RemoveAllMessageGroups(ChatFrame1)
		ChatFrame_AddMessageGroup(ChatFrame1, "SAY")
		ChatFrame_AddMessageGroup(ChatFrame1, "EMOTE")
		ChatFrame_AddMessageGroup(ChatFrame1, "YELL")
		ChatFrame_AddMessageGroup(ChatFrame1, "GUILD")
		ChatFrame_AddMessageGroup(ChatFrame1, "OFFICER")
		ChatFrame_AddMessageGroup(ChatFrame1, "GUILD_ACHIEVEMENT")
		ChatFrame_AddMessageGroup(ChatFrame1, "WHISPER")
		ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_SAY")
		ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_EMOTE")
		ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_YELL")
		ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_BOSS_EMOTE")
		ChatFrame_AddMessageGroup(ChatFrame1, "PARTY")
		ChatFrame_AddMessageGroup(ChatFrame1, "PARTY_LEADER")
		ChatFrame_AddMessageGroup(ChatFrame1, "RAID")
		ChatFrame_AddMessageGroup(ChatFrame1, "RAID_LEADER")
		ChatFrame_AddMessageGroup(ChatFrame1, "RAID_WARNING")
		ChatFrame_AddMessageGroup(ChatFrame1, "BATTLEGROUND")
		ChatFrame_AddMessageGroup(ChatFrame1, "BATTLEGROUND_LEADER")
		ChatFrame_AddMessageGroup(ChatFrame1, "BG_HORDE")
		ChatFrame_AddMessageGroup(ChatFrame1, "BG_ALLIANCE")
		ChatFrame_AddMessageGroup(ChatFrame1, "BG_NEUTRAL")
		ChatFrame_AddMessageGroup(ChatFrame1, "SYSTEM")
		ChatFrame_AddMessageGroup(ChatFrame1, "ERRORS")
		ChatFrame_AddMessageGroup(ChatFrame1, "AFK")
		ChatFrame_AddMessageGroup(ChatFrame1, "DND")
		ChatFrame_AddMessageGroup(ChatFrame1, "IGNORED")
		ChatFrame_AddMessageGroup(ChatFrame1, "ACHIEVEMENT")
		ChatFrame_AddMessageGroup(ChatFrame1, "BN_WHISPER")
		ChatFrame_AddMessageGroup(ChatFrame1, "BN_CONVERSATION")
		ChatFrame_AddMessageGroup(ChatFrame1, "BN_INLINE_TOAST_ALERT")

		ChatFrame_RemoveAllMessageGroups(ChatFrame3)
		ChatFrame_AddMessageGroup(ChatFrame3, "COMBAT_FACTION_CHANGE")
		ChatFrame_AddMessageGroup(ChatFrame3, "SKILL")
		ChatFrame_AddMessageGroup(ChatFrame3, "LOOT")
		ChatFrame_AddMessageGroup(ChatFrame3, "MONEY")
		ChatFrame_AddMessageGroup(ChatFrame3, "COMBAT_XP_GAIN")
		ChatFrame_AddMessageGroup(ChatFrame3, "COMBAT_HONOR_GAIN")
		ChatFrame_AddMessageGroup(ChatFrame3, "COMBAT_GUILD_XP_GAIN")
		ChatFrame_AddChannel(ChatFrame1, GENERAL)
		ChatFrame_RemoveChannel(ChatFrame1, TRADE)
		ChatFrame_AddChannel(ChatFrame3, TRADE)

		-- enable class color automatically on login and each character without doing /configure each time.
		ToggleChatColorNamesByClassGroup(true, "SAY")
		ToggleChatColorNamesByClassGroup(true, "EMOTE")
		ToggleChatColorNamesByClassGroup(true, "YELL")
		ToggleChatColorNamesByClassGroup(true, "GUILD")
		ToggleChatColorNamesByClassGroup(true, "OFFICER")
		ToggleChatColorNamesByClassGroup(true, "GUILD_ACHIEVEMENT")
		ToggleChatColorNamesByClassGroup(true, "ACHIEVEMENT")
		ToggleChatColorNamesByClassGroup(true, "WHISPER")
		ToggleChatColorNamesByClassGroup(true, "PARTY")
		ToggleChatColorNamesByClassGroup(true, "PARTY_LEADER")
		ToggleChatColorNamesByClassGroup(true, "RAID")
		ToggleChatColorNamesByClassGroup(true, "RAID_LEADER")
		ToggleChatColorNamesByClassGroup(true, "RAID_WARNING")
		ToggleChatColorNamesByClassGroup(true, "BATTLEGROUND")
		ToggleChatColorNamesByClassGroup(true, "BATTLEGROUND_LEADER")
		ToggleChatColorNamesByClassGroup(true, "CHANNEL1")
		ToggleChatColorNamesByClassGroup(true, "CHANNEL2")
		ToggleChatColorNamesByClassGroup(true, "CHANNEL3")
		ToggleChatColorNamesByClassGroup(true, "CHANNEL4")
		ToggleChatColorNamesByClassGroup(true, "CHANNEL5")
		ToggleChatColorNamesByClassGroup(true, "CHANNEL6")
		ToggleChatColorNamesByClassGroup(true, "CHANNEL7")
		ToggleChatColorNamesByClassGroup(true, "CHANNEL8")
		ToggleChatColorNamesByClassGroup(true, "CHANNEL9")
		ToggleChatColorNamesByClassGroup(true, "CHANNEL10")
		ToggleChatColorNamesByClassGroup(true, "CHANNEL11")

		-- Adjust Chat Colors
		ChangeChatColor("CHANNEL1", 195/255, 230/255, 232/255) -- General
		ChangeChatColor("CHANNEL2", 232/255, 158/255, 121/255) -- Trade
		ChangeChatColor("CHANNEL3", 232/255, 228/255, 121/255) -- Local Defense
	end

	-- Reset saved variables on char
	SavedPositions = {}
	SavedOptionsPerChar = {}

	-- Set default profile to Default
	if not GUIConfigAll then GUIConfigAll = {} end
	if not GUIConfigAll.CharacterMap then GUIConfigAll.CharacterMap = {} end
	GUIConfigAll.CharacterMap[K.Realm.."-"..K.Name] = "Default"

	SavedOptionsPerChar.Install = true
	SavedOptionsPerChar.AutoInvite = false
	SavedOptionsPerChar.BarsLocked = false
	SavedOptionsPerChar.SplitBars = true
	SavedOptionsPerChar.RightBars = C.ActionBar.RightBars
	SavedOptionsPerChar.BottomBars = C.ActionBar.BottomBars

	StaticPopup_Show("RELOAD_UI")
end

local function DisableUI()
	DisableAddOn("budsUI")
	ReloadUI()
end

-- Install Popups
StaticPopupDialogs["INSTALL_UI"] = {
	text = L_POPUP_INSTALLUI,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = InstallUI,
	OnCancel = function() SavedOptionsPerChar.Install = false end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = false,
	preferredIndex = 3
}

StaticPopupDialogs["RELOAD_UI"] = {
	text = L_POPUP_RELOADUI,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function() ReloadUI() end,
	OnCancel = function() end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = false,
	preferredIndex = 3
}

StaticPopupDialogs["DISABLE_UI"] = {
	text = L_POPUP_DISABLEUI,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = DisableUI,
	showAlert = true,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = true,
	preferredIndex = 3
}

StaticPopupDialogs["RESET_UI"] = {
	text = L_POPUP_RESETUI,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = InstallUI,
	OnCancel = function() SavedOptionsPerChar.Install = true end,
	showAlert = true,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = true,
	preferredIndex = 3
}

StaticPopupDialogs["RESTART_GFX"] = {
	text = L_POPUP_RESTART_GFX,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function() RestartGx() end,
	showAlert = true,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = false,
	preferredIndex = 3
}

SLASH_INSTALLUI1 = "/installui"
SlashCmdList.INSTALLUI = function() StaticPopup_Show("INSTALL_UI") end

SLASH_CONFIGURE1 = "/resetui"
SlashCmdList.CONFIGURE = function() StaticPopup_Show("RESET_UI") end

-- On login function
Install:RegisterEvent("ADDON_LOADED")
Install:SetScript("OnEvent", function(self, event, addon)
	if (addon ~= "budsUI") then
		return
	end

	-- Create empty CVar if they don't exist
	if type(SavedOptions) ~= "table" then SavedOptions = {} end
	if type(SavedPositions) ~= "table" then SavedPositions = {} end
	if type(SavedOptionsPerChar) ~= "table" then SavedOptionsPerChar = {} end
	if SavedOptionsPerChar.AutoInvite == nil then SavedOptionsPerChar.AutoInvite = false end
	if SavedOptionsPerChar.BarsLocked == nil then SavedOptionsPerChar.BarsLocked = false end
	if SavedOptionsPerChar.SplitBars == nil then SavedOptionsPerChar.SplitBars = true end
	if SavedOptionsPerChar.RightBars == nil then SavedOptionsPerChar.RightBars = C.ActionBar.RightBars end
	if SavedOptionsPerChar.BottomBars == nil then SavedOptionsPerChar.BottomBars = C.ActionBar.BottomBars end

	if K.ScreenWidth < 1200 then
		K.SafeSetCVar("useUiScale", 0)
		StaticPopup_Show("DISABLE_UI")
	else
		-- Is this causing crashes?
		if C.General.MultisampleCheck == true then
			local Multisample = GetCVar("gxMultisample")
			if Multisample ~= "1" then
				K.SafeSetCVar("gxMultisample", 1)
				StaticPopup_Show("RESTART_GFX")
			end
		end

		-- Install default if we never ran budsUI on this character
		if not SavedOptionsPerChar.Install then
			StaticPopup_Show("INSTALL_UI")
		end
	end

	-- Welcome message
	if C.General.WelcomeMessage == true then
		print("|cffffe02e"..L_WELCOME_LINE_1..K.Version.." "..K.Client..", "..format("|cff%02x%02x%02x%s|r", K.Color.r * 255, K.Color.g * 255, K.Color.b * 255, K.Name)..".|r")
		print("|cffffe02e"..L_WELCOME_LINE_2_1.."|cffffe02e"..L_WELCOME_LINE_2_2.."|r")
	end

	self:UnregisterEvent("ADDON_LOADED")
end)
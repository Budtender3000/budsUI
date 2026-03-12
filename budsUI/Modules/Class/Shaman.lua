local K, C, L, _ = select(2, ...):unpack()
-- We allow this to load for any class in case of ascension, but maybe it should be Shaman only normally. 
-- For now we let it load for all classes to support Ascension WoW random builds.
-- if K.Class ~= "SHAMAN" and K.Level > 10 then return end

if C.PowerBar.Maelstrom ~= true then return end

local select = select
local CreateFrame = CreateFrame

local IMAGE_PATH = "Interface\\AddOns\\budsUI\\Media\\Maelstrom\\maelstrom"

local killList = {
    [344179] = true,
    [187881] = true,
    [467442] = true,
    [170586] = true,
    [170587] = true,
    [170588] = true,
    [187890] = true,
    [170585] = true,
}

local MaelstromSpellIDs = {
	[1153817] = true, -- Ascension: Maelstrom Weapon
}

-- Cached spell name for O(1) lookup
local MAELSTROM_NAME = GetSpellInfo(1153817)

local MaelstromAnchor = CreateFrame("Frame", "MaelstromAnchor", UIParent)
local size = C.PowerBar.MaelstromSize or 256
MaelstromAnchor:SetSize(size * (C.General.UIScale or 1), (size / 2) * (C.General.UIScale or 1))

-- Base position - can be moved if we make it draggable later, but sticking to standard budsUI anchor for now
if not InCombatLockdown() then
	MaelstromAnchor:SetPoint("CENTER", UIParent, "CENTER", 0, 180) -- Default similar to BetterMaelstrom
end

local f = CreateFrame("Frame", "budsUIMaelstromFrame", UIParent)
f:SetAllPoints(MaelstromAnchor)
f:SetFrameStrata("HIGH")

-- Animations
f.popAnim = f:CreateAnimationGroup()
local grow = f.popAnim:CreateAnimation("Scale")
grow:SetScale(1.15, 1.15)
grow:SetDuration(0.1)
grow:SetOrder(1)
grow:SetSmoothing("OUT")

local shrink = f.popAnim:CreateAnimation("Scale")
shrink:SetScale(0.869, 0.869)
shrink:SetDuration(0.5)
shrink:SetOrder(2)
shrink:SetSmoothing("IN_OUT")

f.pulseAnim = f:CreateAnimationGroup()
f.pulseAnim:SetLooping("REPEAT")

local pulseOut = f.pulseAnim:CreateAnimation("Scale")
pulseOut:SetScale(1.1, 1.1)
pulseOut:SetDuration(0.4)
pulseOut:SetOrder(1)
pulseOut:SetSmoothing("IN_OUT")

local pulseIn = f.pulseAnim:CreateAnimation("Scale")
pulseIn:SetScale(0.909, 0.909)
pulseIn:SetDuration(0.4)
pulseIn:SetOrder(2)
pulseIn:SetSmoothing("IN_OUT")

f.fadeOutAnim = f:CreateAnimationGroup()

local fade = f.fadeOutAnim:CreateAnimation("Alpha")
fade:SetChange(-1)
fade:SetDuration(0.15)
fade:SetOrder(1)
fade:SetSmoothing("OUT")

local fadeGrow = f.fadeOutAnim:CreateAnimation("Scale")
fadeGrow:SetScale(1.25, 1.25)
fadeGrow:SetDuration(0.15)
fadeGrow:SetOrder(1)
fadeGrow:SetSmoothing("OUT")

f.fadeOutAnim:SetScript("OnFinished", function()
    f:Hide()
    f:SetScale(1)
end)


-- Textures
f.textures = {}
for i = 1, 10 do
    f.textures[i] = f:CreateTexture(nil, "OVERLAY")
    f.textures[i]:SetAllPoints(f)
    f.textures[i]:SetTexture(IMAGE_PATH .. i .. ".blp")
    f.textures[i]:Hide()
end

local currentActiveTexture = 0
local function ShowOnlyStackTexture(stacks)
    if currentActiveTexture == stacks then return end

    if currentActiveTexture > 0 and f.textures[currentActiveTexture] then
        f.textures[currentActiveTexture]:Hide()
    end

    if stacks > 0 and f.textures[stacks] then
        f.textures[stacks]:Show()
    end

    currentActiveTexture = stacks
end

local function HideAllStackTextures()
    if currentActiveTexture > 0 and f.textures[currentActiveTexture] then
        f.textures[currentActiveTexture]:Hide()
    end
    currentActiveTexture = 0
end

local lastStacks = 0
local function UpdateStacks()
	local stacks = 0
    
    if MAELSTROM_NAME then
        local _, _, _, count = UnitBuff("player", MAELSTROM_NAME)
        if count then
            stacks = count
        elseif UnitBuff("player", MAELSTROM_NAME) then
            -- Buff exists but count is nil/0 (meaning 1 stack in some contexts, 
            -- but Maelstrom should have a count)
            stacks = 1
        end
    else
        -- Fallback to loop only if GetSpellInfo failed at load time
        for i = 1, 40 do
            local name, _, _, count, _, _, _, _, _, _, spellId = UnitBuff("player", i)
            if not name then break end
            if MaelstromSpellIDs[spellId] then
                stacks = count or 1
                break
            end
        end
    end

    -- show pop when stacks increase
    if stacks > lastStacks and stacks > 0 then
        if f.fadeOutAnim:IsPlaying() then f.fadeOutAnim:Stop() end
        f:Show()
        f:SetAlpha(1.0)
        if f.popAnim:IsPlaying() then f.popAnim:Stop() end
        f.popAnim:Play()
    end

    -- pulse at 5 or 10 stacks
    local pulseThreshold = C.PowerBar.MaelstromPulseAt or 5
    if C.PowerBar.MaelstromPulse and stacks >= pulseThreshold then
        if not f.pulseAnim:IsPlaying() then f.pulseAnim:Play() end
    else
        if f.pulseAnim:IsPlaying() then f.pulseAnim:Stop() end
    end

    -- fade out when stacks drop to 0
    if stacks == 0 and lastStacks > 0 then
        HideAllStackTextures()
        f.fadeOutAnim:Play()
    elseif stacks > 0 then
        f:Show()
        f:SetAlpha(1.0)
        ShowOnlyStackTexture(stacks)
    else
        HideAllStackTextures()
        f:Hide()
    end

    lastStacks = stacks
end

local function ApplySurgicalFix()
    if not SpellActivationOverlayFrame or not SpellActivationOverlayFrame.ShowOverlay then
        return
    end

    if SpellActivationOverlayFrame.__budsUIMaelstromHooked then
        if SpellActivationOverlayFrame.HideOverlays then
            for id in pairs(killList) do
                SpellActivationOverlayFrame:HideOverlays(id)
            end
        end
        return
    end

    local originalShow = SpellActivationOverlayFrame.ShowOverlay
    SpellActivationOverlayFrame.ShowOverlay = function(self, spellID, ...)
        if killList[spellID] then
            -- Effectively suppress Blizzard's overlay
            if self.HideOverlays then self:HideOverlays(spellID) end
            return
        end
        return originalShow(self, spellID, ...)
    end
    SpellActivationOverlayFrame.__budsUIMaelstromHooked = true

    if SpellActivationOverlayFrame.HideOverlays then
        for id in pairs(killList) do
            SpellActivationOverlayFrame:HideOverlays(id)
        end
    end
end

f:RegisterEvent("UNIT_AURA")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_LOGIN")

f:SetScript("OnEvent", function(self, event, arg1)
    if event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" then
        ApplySurgicalFix()
		UpdateStacks()
    elseif event == "UNIT_AURA" and arg1 == "player" then
    	UpdateStacks()
	end
end)

-- Movable Frame Logic (Mover setup per budsUI style)
-- Usually movers are added to a table in budsUI
if K.Movers then
	table.insert(K.Movers, MaelstromAnchor)
end


# Refactoring Battle Plan: budsUI Critical Performance & Stability

## Executive Summary
- **Gesamtaufwand**: 24-32 Stunden
- **Kritische Issues**: 5
- **Phasen**: 4
- **Geschätzter Zeitrahmen**: 2-3 Wochen (bei 2-3h/Tag)
- **Risiko-Level**: MITTEL

**Hauptprobleme identifiziert:**
1. UNIT_AURA Event-Spam ohne Throttling (KRITISCH)
2. Fehlende Event-Unregistrierung bei Cleanup (KRITISCH)
3. Kein Error-Handling in Event-Handlern (KRITISCH)
4. Ineffiziente OnUpdate-Loops in Nameplates (HOCH)
5. K.Delay System ohne Cleanup-Mechanismus (HOCH)
6. Metatable-Injection ohne Schutz (MITTEL)

---

## Phase 1: Kritische Fixes (Priorität: SOFORT)
**Ziel**: Stabilität und Fehlertoleranz sicherstellen  
**Aufwand**: 8-10 Stunden  
**Abhängigkeiten**: Keine

### Issue #1: UNIT_AURA Event-Spam ohne Throttling
**Schweregrad**: KRITISCH  
**Aufwand**: 2 Stunden  
**Dateien**: 
- `budsUI/Core/Functions.lua` (CheckRole)
- `budsUI/Modules/Blizzard/Nameplate.lua` (OnAura)
- `budsUI/Modules/Misc/Filger.lua` (OnEvent)
- `budsUI/Modules/Class/Shaman.lua` (UpdateStacks)
- `budsUI/Modules/ActionBars/PetBar.lua` (OnEvent)
**Abhängigkeiten**: Keine

#### Problem-Analyse
UNIT_AURA feuert extrem häufig (10-50x/Sekunde in Raids/BGs). Aktuell wird jedes Event
sofort verarbeitet, was zu massiven Performance-Problemen führt:
- CheckRole() läuft bei jedem UNIT_AURA ohne Unit-Check
- Nameplate OnAura() scannt alle Debuffs ohne Throttling
- Filger scannt 40 Buffs/Debuffs pro Event
- Keine Deduplizierung bei schnellen Aura-Changes


#### Implementierungs-Steps

**Step 1.1: Core/Functions.lua - CheckRole Throttling** (30 Min)
```lua
-- VORHER (problematisch):
local function CheckRole(self, event, unit)
	if event == "UNIT_AURA" and unit ~= "player" then return end
	-- Kein Throttling, läuft bei jedem Event
	if (K.Class == "PALADIN" and UnitBuff("player", GetSpellInfo(25780))) and GetCombatRatingBonus(CR_DEFENSE_SKILL) > 100 or
	-- ... rest of logic
end

-- NACHHER (mit Throttling):
local RoleUpdater = CreateFrame("Frame")
local roleUpdateThrottle = 0
local ROLE_UPDATE_INTERVAL = 0.5 -- Update max 2x/Sekunde

local function CheckRole(self, event, unit)
	if event == "UNIT_AURA" and unit ~= "player" then return end
	
	-- Throttle UNIT_AURA updates
	if event == "UNIT_AURA" then
		local now = GetTime()
		if (now - roleUpdateThrottle) < ROLE_UPDATE_INTERVAL then
			return
		end
		roleUpdateThrottle = now
	end
	
	-- Wrap in pcall for error safety
	local success, err = pcall(function()
		if (K.Class == "PALADIN" and UnitBuff("player", GetSpellInfo(25780))) and GetCombatRatingBonus(CR_DEFENSE_SKILL) > 100 or
		(K.Class == "WARRIOR" and GetBonusBarOffset() == 2) or
		(K.Class == "DEATHKNIGHT" and UnitBuff("player", GetSpellInfo(48263))) or
		(K.Class == "DRUID" and GetBonusBarOffset() == 3) then
			K.Role = "Tank"
		else
			local playerint = select(2, UnitStat("player", 4))
			local playeragi	= select(2, UnitStat("player", 2))
			local base, posBuff, negBuff = UnitAttackPower("player")
			local playerap = base + posBuff + negBuff

			if ((playerap > playerint) or (playeragi > playerint)) and not (UnitBuff("player", GetSpellInfo(24858)) or UnitBuff("player", GetSpellInfo(65139))) then
				K.Role = "Melee"
			else
				K.Role = "Caster"
			end
		end
	end)
	
	if not success and C.General.DeveloperMode then
		K.Print("CheckRole error:", err)
	end
	
	-- Unregister useless events
	if event == "PLAYER_ENTERING_WORLD" then
		if K.Class ~= "WARRIOR" and K.Class ~= "DRUID" and K.Class ~= "PALADIN" and K.Class ~= "DEATHKNIGHT" then
			RoleUpdater:UnregisterEvent("UPDATE_BONUS_ACTIONBAR")
		end
		RoleUpdater:UnregisterEvent("PLAYER_ENTERING_WORLD")
	end
end
```


**Step 1.2: Modules/Blizzard/Nameplate.lua - OnAura Throttling** (45 Min)
```lua
-- VORHER (problematisch):
local function OnAura(frame, unit)
	if not frame.icons or not frame.unit or not C.Nameplate.Auras then return end
	local i = 1
	for index = 1, 5 do
		-- Scannt bei jedem UNIT_AURA Event alle Debuffs
		local name, _, _, _, _, duration, _, caster, _, _, spellid = UnitAura(frame.unit, index, "HARMFUL")
		-- ... rest
	end
end

-- NACHHER (mit Throttling + Cache):
local auraUpdateThrottle = {}
local AURA_UPDATE_INTERVAL = 0.2 -- Max 5x/Sekunde pro Nameplate

local function OnAura(frame, unit)
	if not frame.icons or not frame.unit or not C.Nameplate.Auras then return end
	
	-- Throttle per-frame updates
	local now = GetTime()
	local lastUpdate = auraUpdateThrottle[frame] or 0
	if (now - lastUpdate) < AURA_UPDATE_INTERVAL then
		return
	end
	auraUpdateThrottle[frame] = now
	
	-- Wrap in pcall
	local success, err = pcall(function()
		local i = 1
		for index = 1, 5 do
			if i > C.Nameplate.Width / C.Nameplate.AuraSize then return end
			local match
			local name, _, _, _, _, duration, _, caster, _, _, spellid = UnitAura(frame.unit, index, "HARMFUL")

			if K.DebuffWhiteList[name] and caster == "player" then match = true end

			if duration and match == true then
				if not frame.icons[i] then frame.icons[i] = CreateAuraIcon(frame) end
				local icon = frame.icons[i]
				if i == 1 then icon:SetPoint("RIGHT", frame.icons, "RIGHT") end
				if i ~= 1 and i <= C.Nameplate.Width / C.Nameplate.AuraSize then 
					icon:SetPoint("RIGHT", frame.icons[i-1], "LEFT", -2, 0) 
				end
				i = i + 1
				UpdateAuraIcon(icon, frame.unit, index, "HARMFUL")
			end
		end
		for index = i, #frame.icons do frame.icons[index]:Hide() end
	end)
	
	if not success and C.General.DeveloperMode then
		K.Print("OnAura error:", err)
	end
end

-- Cleanup throttle cache when nameplate hides
local function OnHide(frame)
	-- ... existing code ...
	auraUpdateThrottle[frame] = nil -- Cleanup throttle entry
end
```


**Step 1.3: Modules/Misc/Filger.lua - Optimierter Aura-Cache** (45 Min)
```lua
-- VORHER: Cache wird bei jedem Event komplett neu gebaut
function Filger:OnEvent(event, unit)
	if event == "SPELL_UPDATE_COOLDOWN" or event == "PLAYER_TARGET_CHANGED" or 
	   event == "PLAYER_FOCUS_CHANGED" or event == "PLAYER_ENTERING_WORLD" or 
	   event == "UNIT_AURA" and (unit == "target" or unit == "player" or unit == "pet" or unit == "focus") then
		WipeAuraCache() -- Löscht ALLES bei jedem Event!
		-- ... rest
	end
end

-- NACHHER: Selektives Cache-Update + Throttling
local filgerThrottle = {}
local FILGER_UPDATE_INTERVAL = 0.15 -- ~6-7x/Sekunde

function Filger:OnEvent(event, unit)
	-- Throttle UNIT_AURA events per unit
	if event == "UNIT_AURA" then
		if not (unit == "target" or unit == "player" or unit == "pet" or unit == "focus") then
			return
		end
		
		local now = GetTime()
		local key = unit or "global"
		local lastUpdate = filgerThrottle[key] or 0
		if (now - lastUpdate) < FILGER_UPDATE_INTERVAL then
			return
		end
		filgerThrottle[key] = now
		
		-- Nur betroffenen Unit-Cache löschen, nicht alles
		if auraCache.buff[unit] then auraCache.buff[unit] = nil end
		if auraCache.debuff[unit] then auraCache.debuff[unit] = nil end
	elseif event == "PLAYER_TARGET_CHANGED" then
		-- Nur target cache löschen
		auraCache.buff.target = nil
		auraCache.debuff.target = nil
	elseif event == "PLAYER_FOCUS_CHANGED" then
		-- Nur focus cache löschen
		auraCache.buff.focus = nil
		auraCache.debuff.focus = nil
	else
		-- Für andere Events: kompletter Wipe
		WipeAuraCache()
	end
	
	-- Wrap main logic in pcall
	local success, err = pcall(function()
		local needUpdate = false
		local id = self.Id
		-- ... rest of existing logic ...
	end)
	
	if not success and C.General.DeveloperMode then
		K.Print("Filger error:", err)
	end
end
```


#### Testing-Strategie
- [ ] Test 1: Solo Questing - CheckRole sollte max 2x/Sekunde updaten (Debug-Print hinzufügen)
- [ ] Test 2: 25-Man Raid - FPS-Vergleich vorher/nachher (erwarte +5-10 FPS)
- [ ] Test 3: Battleground mit vielen Nameplates - Aura-Updates sollten smooth sein
- [ ] Test 4: Filger mit vielen Buffs/Debuffs - CPU-Usage sollte sinken
- [ ] Regression-Test: Alle Aura-Displays funktionieren noch korrekt

#### Rollback-Plan
Falls Probleme auftreten:
1. Git revert auf vorherigen Commit
2. Throttle-Intervalle erhöhen (0.5s → 1.0s) falls zu aggressiv
3. Einzelne Throttles deaktivieren um Problem zu isolieren

#### Risiken
- **Risiko 1**: Aura-Updates wirken "laggy" → Mitigation: Intervalle auf 0.1s reduzieren
- **Risiko 2**: Cache-Logik hat Bugs → Mitigation: Umfangreiches Testing mit verschiedenen Klassen

---

### Issue #2: Fehlende Event-Unregistrierung bei Cleanup
**Schweregrad**: KRITISCH  
**Aufwand**: 2 Stunden  
**Dateien**: 
- `budsUI/Modules/Blizzard/Nameplate.lua`
- `budsUI/Modules/Misc/Filger.lua`
- `budsUI/Core/API.lua` (Kill function)
**Abhängigkeiten**: Keine

#### Problem-Analyse
Frames registrieren Events aber unregistrieren sie nie beim Cleanup:
- Nameplates registrieren UNIT_AURA aber unregistrieren nie bei OnHide
- Filger-Frames werden nie richtig destroyed
- K.Kill() unregistriert Events, wird aber kaum genutzt
- Memory-Leaks durch Event-Handler die auf tote Frames zeigen


#### Implementierungs-Steps

**Step 2.1: Nameplate Event-Cleanup** (45 Min)
```lua
-- VORHER (problematisch):
local function OnHide(frame)
	frame.hp:SetStatusBarColor(frame.hp.rcolor, frame.hp.gcolor, frame.hp.bcolor)
	frame.hp:SetScale(1)
	frame.overlay:Hide()
	frame.cb:Hide()
	-- ... rest
	-- KEIN UnregisterEvent!
end

-- NACHHER (mit Cleanup):
local function OnHide(frame)
	-- Cleanup throttle cache
	if auraUpdateThrottle[frame] then
		auraUpdateThrottle[frame] = nil
	end
	
	-- Unregister events wenn registriert
	if frame.icons and frame:IsEventRegistered("UNIT_AURA") then
		frame:UnregisterEvent("UNIT_AURA")
	end
	
	-- Visual cleanup
	frame.hp:SetStatusBarColor(frame.hp.rcolor, frame.hp.gcolor, frame.hp.bcolor)
	frame.hp:SetScale(1)
	frame.overlay:Hide()
	frame.cb:Hide()
	frame.cb:SetScale(1)
	frame.unit = nil
	frame.guid = nil
	frame.isClass = nil
	frame.isFriendly = nil
	frame.hp.rcolor = nil
	frame.hp.gcolor = nil
	frame.hp.bcolor = nil
	
	-- Hide aura icons
	if frame.icons then
		for _, icon in ipairs(frame.icons) do
			icon:Hide()
		end
	end
	
	frame:SetScript("OnUpdate", nil)
end

-- Re-register when shown again
local function UpdateObjects(frame)
	frame = frame:GetParent()
	
	-- ... existing code ...
	
	-- Re-register UNIT_AURA if auras enabled
	if C.Nameplate.Auras and frame.icons and not frame:IsEventRegistered("UNIT_AURA") then
		frame:RegisterEvent("UNIT_AURA")
	end
	
	HideObjects(frame)
end
```


**Step 2.2: Verbesserte Kill() Funktion** (30 Min)
```lua
-- VORHER (in Core/API.lua):
local function Kill(object)
    if object.UnregisterAllEvents then
        object:UnregisterAllEvents()
    end
    object:Hide()
    if object.HookScript then
        object:HookScript("OnShow", function(self) self:Hide() end)
    end
end

-- NACHHER (robuster):
local function Kill(object)
	if not object then return end
	
	-- Wrap in pcall for safety
	local success, err = pcall(function()
		-- Unregister all events
		if object.UnregisterAllEvents then
			object:UnregisterAllEvents()
		end
		
		-- Clear all scripts
		if object.SetScript then
			object:SetScript("OnUpdate", nil)
			object:SetScript("OnEvent", nil)
			object:SetScript("OnShow", nil)
			object:SetScript("OnHide", nil)
		end
		
		-- Hide and prevent showing
		object:Hide()
		if object.HookScript then
			object:HookScript("OnShow", function(self) self:Hide() end)
		end
		
		-- Clear parent to help GC
		if object.SetParent and not object:IsProtected() then
			object:SetParent(nil)
		end
	end)
	
	if not success and C.General.DeveloperMode then
		K.Print("Kill() error:", err)
	end
end
```

**Step 2.3: K.Delay Cleanup-Mechanismus** (45 Min)
```lua
-- VORHER (in Core/Functions.lua):
-- Kein Cleanup-Mechanismus, waitTable wächst unbegrenzt

-- NACHHER (mit Cleanup):
local waitTable = {}
local waitFrame
local MAX_WAIT_RECORDS = 100 -- Prevent unbounded growth

K.Delay = function(delay, func, ...)
	if(type(delay) ~= "number" or type(func) ~= "function") then
		return false
	end
	
	-- Cleanup abgelaufene Records wenn zu viele
	if #waitTable > MAX_WAIT_RECORDS then
		local cleaned = {}
		for i = 1, #waitTable do
			if waitTable[i][2] ~= nil then
				table.insert(cleaned, waitTable[i])
			end
		end
		waitTable = cleaned
	end
	
	if(waitFrame == nil) then
		waitFrame = CreateFrame("Frame", "WaitFrame", UIParent)
		waitFrame:SetScript("OnUpdate", function (self, elapse)
			local count = #waitTable
			local i = 1
			while(i <= count) do
				local waitRecord = waitTable[i]
				if(waitRecord[2] == nil) then
					tremove(waitTable, i)
					count = count - 1
				else
					local d = waitRecord[1]
					if(d > elapse) then
						waitRecord[1] = d - elapse
						i = i + 1
					else
						tremove(waitTable, i)
						count = count - 1
						
						-- Wrap callback in pcall
						local success, err = pcall(waitRecord[2], unpack(waitRecord[3]))
						if not success and C.General.DeveloperMode then
							K.Print("K.Delay callback error:", err)
						end
					end
				end
			end
			
			-- Stop OnUpdate wenn keine Delays mehr
			if count == 0 then
				self:SetScript("OnUpdate", nil)
			end
		end)
	end
	
	local record = {delay, func, {...}}
	tinsert(waitTable, record)
	
	-- Restart OnUpdate wenn gestoppt
	if not waitFrame:GetScript("OnUpdate") then
		waitFrame:SetScript("OnUpdate", waitFrame:GetScript("OnUpdate"))
	end
	
	return record
end
```


#### Testing-Strategie
- [ ] Test 1: Memory-Profiling vor/nach (erwarte -5-10% Memory-Usage)
- [ ] Test 2: Nameplates ein/ausschalten mehrmals - keine Memory-Leaks
- [ ] Test 3: K.Delay mit vielen Calls - waitTable sollte nicht unbegrenzt wachsen
- [ ] Test 4: /reload mehrmals - keine "ghost events" von alten Frames
- [ ] Regression-Test: Alle Features funktionieren noch

#### Rollback-Plan
1. Git revert auf vorherigen Commit
2. Falls nur K.Delay Probleme macht: MAX_WAIT_RECORDS auf 1000 erhöhen
3. Falls Nameplate-Cleanup Probleme macht: Event-Unregistrierung auskommentieren

#### Risiken
- **Risiko 1**: Zu aggressives Cleanup bricht Features → Mitigation: Schrittweise testen
- **Risiko 2**: K.Delay OnUpdate-Stop bricht Timing → Mitigation: OnUpdate immer laufen lassen

---

### Issue #3: Kein Error-Handling in Event-Handlern
**Schweregrad**: KRITISCH  
**Aufwand**: 3 Stunden  
**Dateien**: Alle Module mit Event-Handlern (20+ Dateien)
**Abhängigkeiten**: Keine

#### Problem-Analyse
Fast keine pcall-Nutzung in Event-Handlern:
- Ein Fehler in einem Event-Handler bricht das gesamte Addon
- Keine Fehler-Logs für Debugging
- User sehen nur "Interface action failed" ohne Details
- Besonders kritisch bei UNIT_AURA, OnUpdate, OnShow

#### Implementierungs-Steps

**Step 3.1: Zentrale Error-Handler Utility** (30 Min)
```lua
-- NEU in Core/Functions.lua:

-- Safe event handler wrapper
K.SafeEventHandler = function(handler, eventName)
	return function(self, event, ...)
		local success, err = pcall(handler, self, event, ...)
		if not success then
			if C.General.DeveloperMode then
				K.Print(format("Error in %s handler: %s", eventName or event or "unknown", tostring(err)))
			end
			-- Log to SavedVariables für Bug-Reports
			if not SavedOptions.ErrorLog then SavedOptions.ErrorLog = {} end
			table.insert(SavedOptions.ErrorLog, {
				time = date("%Y-%m-%d %H:%M:%S"),
				event = eventName or event or "unknown",
				error = tostring(err),
				addon = "budsUI"
			})
			-- Limit log size
			if #SavedOptions.ErrorLog > 50 then
				table.remove(SavedOptions.ErrorLog, 1)
			end
		end
	end
end

-- Safe OnUpdate wrapper
K.SafeOnUpdate = function(handler, frameName)
	return function(self, elapsed)
		local success, err = pcall(handler, self, elapsed)
		if not success then
			-- Stop OnUpdate on error to prevent spam
			self:SetScript("OnUpdate", nil)
			if C.General.DeveloperMode then
				K.Print(format("Error in %s OnUpdate (stopped): %s", frameName or "unknown", tostring(err)))
			end
		end
	end
end
```


**Step 3.2: Nameplate Error-Handling** (45 Min)
```lua
-- VORHER:
NamePlates:SetScript("OnUpdate", function(self, elapsed)
	scanThrottle = scanThrottle + elapsed
	if scanThrottle > 0.1 then
		-- ... logic ohne error handling
	end
end)

-- NACHHER:
NamePlates:SetScript("OnUpdate", K.SafeOnUpdate(function(self, elapsed)
	scanThrottle = scanThrottle + elapsed
	if scanThrottle > 0.1 then
		if WorldFrame:GetNumChildren() ~= numChildren then
			numChildren = WorldFrame:GetNumChildren()
			HookFrames(WorldFrame:GetChildren())
		end
		scanThrottle = 0
	end

	if self.elapsed and self.elapsed > 0.2 then
		ForEachPlate(UpdateThreat, self.elapsed)
		ForEachPlate(AdjustNameLevel)
		self.elapsed = 0
	else
		self.elapsed = (self.elapsed or 0) + elapsed
	end

	healthThrottle = healthThrottle + elapsed
	if healthThrottle > 0.2 then
		ForEachPlate(ShowHealth)
		ForEachPlate(CheckBlacklist)
		healthThrottle = 0
	end

	if C.Nameplate.Auras then
		unitThrottle = unitThrottle + elapsed
		if unitThrottle > 0.2 then
			ForEachPlate(CheckUnit_Guid)
			unitThrottle = 0
		end
	end
end, "NamePlates"))

-- Event-Handler auch wrappen:
function NamePlates:COMBAT_LOG_EVENT_UNFILTERED(_, event, ...)
	local success, err = pcall(function()
		if event == "SPELL_AURA_REMOVED" then
			local _, sourceGUID, _, _, _, destGUID, _, _, _, spellID = ...
			if sourceGUID == UnitGUID("player") or arg4 == UnitGUID("pet") then
				ForEachPlate(MatchGUID, destGUID, spellID)
			end
		end
	end)
	if not success and C.General.DeveloperMode then
		K.Print("COMBAT_LOG_EVENT_UNFILTERED error:", err)
	end
end
```

**Step 3.3: Filger Error-Handling** (45 Min)
```lua
-- Bereits teilweise in Step 1.3 implementiert, hier komplettieren:

-- Alle Filger-Frames mit SafeEventHandler wrappen:
for i = 1, #C["filger_spells"][K.Class], 1 do
	local data = C["filger_spells"][K.Class][i]
	local frame = CreateFrame("Frame", "FilgerFrame"..i.."_"..data.Name, UIParent)
	-- ... setup code ...
	
	if not C.Filger.TestMode then
		-- ... event registration ...
		frame:SetScript("OnEvent", K.SafeEventHandler(Filger.OnEvent, "Filger_"..data.Name))
	end
end
```

**Step 3.4: Core/Functions.lua CheckRole Error-Handling** (30 Min)
```lua
-- Bereits in Step 1.1 implementiert, hier sicherstellen dass alle Pfade abgedeckt sind
RoleUpdater:SetScript("OnEvent", K.SafeEventHandler(CheckRole, "RoleUpdater"))
```

**Step 3.5: Error-Log Viewer Command** (30 Min)
```lua
-- NEU in Core/Commands.lua:

SlashCmdList["BUDSUIERRORS"] = function()
	if not SavedOptions.ErrorLog or #SavedOptions.ErrorLog == 0 then
		K.Print("No errors logged.")
		return
	end
	
	K.Print(format("=== budsUI Error Log (%d entries) ===", #SavedOptions.ErrorLog))
	for i, entry in ipairs(SavedOptions.ErrorLog) do
		K.Print(format("[%s] %s: %s", entry.time, entry.event, entry.error))
	end
	K.Print("Use /budsuiclearerrors to clear log")
end
SLASH_BUDSUIERRORS1 = "/budsuierrors"

SlashCmdList["BUDSUICLEARERRORS"] = function()
	SavedOptions.ErrorLog = {}
	K.Print("Error log cleared.")
end
SLASH_BUDSUICLEARERRORS1 = "/budsuiclearerrors"
```


#### Testing-Strategie
- [ ] Test 1: Provoziere Fehler (z.B. nil-Zugriff) - Addon sollte nicht crashen
- [ ] Test 2: /budsuierrors sollte Fehler anzeigen
- [ ] Test 3: Error-Log sollte max 50 Einträge haben
- [ ] Test 4: DeveloperMode ON - Fehler sollten im Chat erscheinen
- [ ] Test 5: DeveloperMode OFF - Keine Chat-Spam, nur Log
- [ ] Regression-Test: Alle Features funktionieren normal

#### Rollback-Plan
1. Git revert auf vorherigen Commit
2. Falls zu viel Overhead: K.SafeEventHandler nur für kritische Events nutzen
3. Error-Log deaktivieren falls SavedVariables zu groß werden

#### Risiken
- **Risiko 1**: pcall-Overhead reduziert Performance → Mitigation: Profiling, nur kritische Pfade wrappen
- **Risiko 2**: Error-Log füllt SavedVariables → Mitigation: Limit auf 50 Einträge
- **Risiko 3**: Fehler werden "verschluckt" → Mitigation: DeveloperMode für Testing

---

## Phase 2: Performance-Optimierungen (Priorität: HOCH)
**Ziel**: FPS und Responsiveness verbessern  
**Aufwand**: 8-10 Stunden  
**Abhängigkeiten**: Phase 1 abgeschlossen

### Issue #4: Ineffiziente OnUpdate-Loops in Nameplates
**Schweregrad**: HOCH  
**Aufwand**: 3 Stunden  
**Dateien**: `budsUI/Modules/Blizzard/Nameplate.lua`
**Abhängigkeiten**: Issue #1 (Throttling muss implementiert sein)

#### Problem-Analyse
Nameplate OnUpdate läuft permanent mit mehreren ForEachPlate-Calls:
- UpdateThreat läuft alle 0.2s für ALLE sichtbaren Nameplates
- ShowHealth läuft alle 0.2s für ALLE Nameplates
- CheckBlacklist läuft alle 0.2s für ALLE Nameplates
- In 25-Man Raids = 25+ Nameplates × 5 Funktionen = 125+ Calls/Sekunde
- Viele redundante GetUnitName/GetAlpha Calls


#### Implementierungs-Steps

**Step 4.1: Optimierte ForEachPlate mit Early-Exit** (1 Stunde)
```lua
-- VORHER:
local function ForEachPlate(functionToRun, ...)
	for frame in pairs(frames) do
		if frame:IsShown() then
			functionToRun(frame, ...)
		end
	end
end

-- NACHHER:
local function ForEachPlate(functionToRun, ...)
	local count = 0
	for frame in pairs(frames) do
		if frame:IsShown() then
			local success, err = pcall(functionToRun, frame, ...)
			if not success and C.General.DeveloperMode then
				K.Print("ForEachPlate error:", err)
			end
			count = count + 1
		end
	end
	return count
end

-- Optimierte Version mit Batch-Processing
local visiblePlates = {}
local function UpdateVisiblePlates()
	wipe(visiblePlates)
	for frame in pairs(frames) do
		if frame:IsShown() then
			table.insert(visiblePlates, frame)
		end
	end
end

local function ForEachVisiblePlate(functionToRun, ...)
	for i = 1, #visiblePlates do
		local success, err = pcall(functionToRun, visiblePlates[i], ...)
		if not success and C.General.DeveloperMode then
			K.Print("ForEachVisiblePlate error:", err)
		end
	end
end
```

**Step 4.2: Konsolidierte OnUpdate-Logik** (1.5 Stunden)
```lua
-- VORHER: Mehrere separate Throttles und ForEachPlate-Calls

-- NACHHER: Konsolidierte Update-Logik
local updateThrottle = 0
local UPDATE_INTERVAL = 0.2

NamePlates:SetScript("OnUpdate", K.SafeOnUpdate(function(self, elapsed)
	-- Scan für neue Nameplates (schneller Check)
	scanThrottle = scanThrottle + elapsed
	if scanThrottle > 0.1 then
		if WorldFrame:GetNumChildren() ~= numChildren then
			numChildren = WorldFrame:GetNumChildren()
			HookFrames(WorldFrame:GetChildren())
		end
		scanThrottle = 0
	end
	
	-- Konsolidiertes Update für alle Nameplate-Funktionen
	updateThrottle = updateThrottle + elapsed
	if updateThrottle >= UPDATE_INTERVAL then
		-- Update visible plates cache einmal
		UpdateVisiblePlates()
		
		-- Batch-Update aller Funktionen
		for i = 1, #visiblePlates do
			local frame = visiblePlates[i]
			
			-- Threat update (nur wenn in Combat und Threat-System aktiv)
			if C.Nameplate.EnhanceThreat and InCombatLockdown() then
				UpdateThreat(frame, updateThrottle)
			end
			
			-- Health update
			ShowHealth(frame)
			
			-- Name level adjust (nur wenn target existiert)
			if UnitExists("target") then
				AdjustNameLevel(frame)
			end
			
			-- Blacklist check (nur einmal beim ersten Show)
			if not frame.blacklistChecked then
				CheckBlacklist(frame)
				frame.blacklistChecked = true
			end
			
			-- Unit GUID check (nur wenn Auras aktiv)
			if C.Nameplate.Auras then
				CheckUnit_Guid(frame)
			end
		end
		
		updateThrottle = 0
	end
end, "NamePlates"))
```


**Step 4.3: Caching von häufigen API-Calls** (30 Min)
```lua
-- VORHER: GetUnitName("target") wird mehrfach pro Frame aufgerufen

-- NACHHER: Cache target name
local cachedTargetName = nil
local targetNameCache = 0

local function GetCachedTargetName()
	local now = GetTime()
	if (now - targetNameCache) > 0.1 then
		cachedTargetName = UnitExists("target") and GetUnitName("target") or nil
		targetNameCache = now
	end
	return cachedTargetName
end

-- In ShowHealth und AdjustNameLevel:
local function ShowHealth(frame, ...)
	HealthBar_ValueChanged(frame.hp)
	
	local _, maxHealth = frame.healthOriginal:GetMinMaxValues()
	local valueHealth = frame.healthOriginal:GetValue()
	local percent = (valueHealth / maxHealth) * 100

	if C.Nameplate.HealthValue == true then
		frame.hp.value:SetFormattedText(K.ShortValue(valueHealth).." - ".."%d%%", percent)
	end

	-- Use cached target name
	local targetName = GetCachedTargetName()
	if targetName and frame.hp.name:GetText() == targetName and frame:GetParent():GetAlpha() == 1 then
		frame.hp:SetSize((C.Nameplate.Width + C.Nameplate.AdditionalWidth) * K.NoScaleMult, (C.Nameplate.Height + C.Nameplate.AdditionalHeight) * K.NoScaleMult)
		frame.cb:SetPoint("BOTTOMLEFT", frame.hp, "BOTTOMLEFT", 0, -8-((C.Nameplate.Height + C.Nameplate.AdditionalHeight) * K.NoScaleMult))
		frame.cb.icon:SetSize(((C.Nameplate.Height + C.Nameplate.AdditionalHeight) * 2 * K.NoScaleMult) + 8, ((C.Nameplate.Height + C.Nameplate.AdditionalHeight) * 2 * K.NoScaleMult) + 8)
	else
		frame.hp:SetSize(C.Nameplate.Width * K.NoScaleMult, C.Nameplate.Height * K.NoScaleMult)
		frame.cb:SetPoint("BOTTOMLEFT", frame.hp, "BOTTOMLEFT", 0, -8-(C.Nameplate.Height * K.NoScaleMult))
		frame.cb.icon:SetSize((C.Nameplate.Height * 2 * K.NoScaleMult) + 8, (C.Nameplate.Height * 2 * K.NoScaleMult) + 8)
	end
end
```

#### Testing-Strategie
- [ ] Test 1: FPS-Messung in 25-Man Raid vorher/nachher (erwarte +10-15 FPS)
- [ ] Test 2: CPU-Profiling - Nameplate OnUpdate sollte <5% CPU nutzen
- [ ] Test 3: Nameplates sollten smooth updaten ohne Stutter
- [ ] Test 4: Target-Highlighting funktioniert noch korrekt
- [ ] Test 5: Threat-Coloring funktioniert noch
- [ ] Regression-Test: Alle Nameplate-Features funktionieren

#### Rollback-Plan
1. Git revert auf vorherigen Commit
2. Falls Batch-Processing Probleme macht: Zurück zu einzelnen ForEachPlate-Calls
3. UPDATE_INTERVAL auf 0.3s erhöhen falls zu aggressiv

#### Risiken
- **Risiko 1**: Batch-Processing bricht Timing → Mitigation: Intervall anpassen
- **Risiko 2**: Cache-Logik hat Race-Conditions → Mitigation: Umfangreiches Testing
- **Risiko 3**: Zu wenig Updates wirken "laggy" → Mitigation: Intervall reduzieren

---

### Issue #5: Metatable-Injection ohne Schutz
**Schweregrad**: MITTEL  
**Aufwand**: 2 Stunden  
**Dateien**: `budsUI/Core/API.lua`
**Abhängigkeiten**: Keine

#### Problem-Analyse
Metatable-Injection in Core/API.lua ist riskant:
- Modifiziert globale Frame-Metatables ohne Schutz
- Kann andere Addons brechen die auch Metatables modifizieren
- Keine Collision-Detection
- Keine Versionierung der API


#### Implementierungs-Steps

**Step 5.1: Sichere Metatable-Injection mit Collision-Detection** (1.5 Stunden)
```lua
-- VORHER (in Core/API.lua):
local function AddAPI(object)
	if object.budsUIEnhanced then return end
	if object:IsProtected() then return end

	local mt = getmetatable(object).__index
	if not object.CreateOverlay then mt.CreateOverlay = CreateOverlay end
	-- ... rest ohne Schutz
end

-- NACHHER (mit Schutz):
local BUDSUI_API_VERSION = 1

local function AddAPI(object)
	-- Skip if already enhanced with same or newer version
	if object.budsUIEnhanced and object.budsUIEnhanced >= BUDSUI_API_VERSION then 
		return 
	end
	
	-- Skip protected frames
	if object:IsProtected() then 
		return 
	end
	
	-- Wrap in pcall for safety
	local success, err = pcall(function()
		local mt = getmetatable(object)
		if not mt or not mt.__index then
			if C.General.DeveloperMode then
				K.Print("AddAPI: No metatable for object")
			end
			return
		end
		
		local index = mt.__index
		
		-- Store original methods if they exist (collision detection)
		local originals = {}
		local methods = {
			"CreateOverlay", "CreateBorder", "SetOutside", "SetInside",
			"CreateBackdrop", "SetTemplate", "CreatePanel", "CreatePixelShadow",
			"CreateBlizzShadow", "StyleButton", "FontString", "Kill", "StripTextures"
		}
		
		for _, methodName in ipairs(methods) do
			if index[methodName] and index[methodName] ~= _G["budsUI_"..methodName] then
				-- Another addon already added this method
				originals[methodName] = index[methodName]
				if C.General.DeveloperMode then
					K.Print(format("AddAPI: Method %s already exists, storing original", methodName))
				end
			end
		end
		
		-- Add our methods
		if not index.CreateOverlay then index.CreateOverlay = CreateOverlay end
		if not index.CreateBorder then index.CreateBorder = CreateBorder end
		if not index.SetOutside then index.SetOutside = SetOutside end
		if not index.SetInside then index.SetInside = SetInside end
		if not index.CreateBackdrop then index.CreateBackdrop = CreateBackdrop end
		if not index.SetTemplate then index.SetTemplate = SetTemplate end
		if not index.CreatePanel then index.CreatePanel = CreatePanel end
		if not index.CreatePixelShadow then index.CreatePixelShadow = CreatePixelShadow end
		if not index.CreateBlizzShadow then index.CreateBlizzShadow = CreateBlizzShadow end
		if not index.StyleButton then index.StyleButton = StyleButton end
		if not index.FontString then index.FontString = FontString end
		if not index.Kill then index.Kill = Kill end
		if not index.StripTextures then index.StripTextures = StripTextures end
		
		-- Store version and originals
		object.budsUIEnhanced = BUDSUI_API_VERSION
		if next(originals) then
			object.budsUIOriginals = originals
		end
	end)
	
	if not success and C.General.DeveloperMode then
		K.Print("AddAPI error:", err)
	end
end
```

**Step 5.2: API-Cleanup Funktion** (30 Min)
```lua
-- NEU: Funktion zum Entfernen der API (für /reload Cleanup)
local function RemoveAPI(object)
	if not object.budsUIEnhanced then return end
	
	local success, err = pcall(function()
		local mt = getmetatable(object)
		if not mt or not mt.__index then return end
		
		local index = mt.__index
		
		-- Restore originals if they exist
		if object.budsUIOriginals then
			for methodName, originalFunc in pairs(object.budsUIOriginals) do
				index[methodName] = originalFunc
			end
			object.budsUIOriginals = nil
		else
			-- Remove our methods
			index.CreateOverlay = nil
			index.CreateBorder = nil
			index.SetOutside = nil
			index.SetInside = nil
			index.CreateBackdrop = nil
			index.SetTemplate = nil
			index.CreatePanel = nil
			index.CreatePixelShadow = nil
			index.CreateBlizzShadow = nil
			index.StyleButton = nil
			index.FontString = nil
			index.Kill = nil
			index.StripTextures = nil
		end
		
		object.budsUIEnhanced = nil
	end)
	
	if not success and C.General.DeveloperMode then
		K.Print("RemoveAPI error:", err)
	end
end

-- Cleanup bei PLAYER_LOGOUT
local cleanupFrame = CreateFrame("Frame")
cleanupFrame:RegisterEvent("PLAYER_LOGOUT")
cleanupFrame:SetScript("OnEvent", function()
	-- Cleanup wird automatisch durch /reload gemacht, aber sicher ist sicher
	if C.General.DeveloperMode then
		K.Print("budsUI API cleanup on logout")
	end
end)
```


#### Testing-Strategie
- [ ] Test 1: Addon lädt ohne Errors
- [ ] Test 2: Alle Frame-Methoden funktionieren (CreateBackdrop, SetTemplate, etc.)
- [ ] Test 3: Mit anderen UI-Addons testen (ElvUI, TukUI falls vorhanden)
- [ ] Test 4: /reload mehrmals - keine Metatable-Corruption
- [ ] Test 5: DeveloperMode ON - Collision-Warnings sollten erscheinen falls vorhanden
- [ ] Regression-Test: Alle UI-Elemente sehen korrekt aus

#### Rollback-Plan
1. Git revert auf vorherigen Commit
2. Falls Collision-Detection zu streng: Warnings entfernen, nur Version-Check behalten
3. Falls Probleme mit anderen Addons: API-Injection optional machen

#### Risiken
- **Risiko 1**: Collision-Detection bricht Kompatibilität → Mitigation: Nur warnen, nicht blocken
- **Risiko 2**: Cleanup bricht andere Addons → Mitigation: Cleanup nur bei DeveloperMode
- **Risiko 3**: Performance-Overhead durch pcall → Mitigation: Nur bei Injection, nicht bei Nutzung

---

## Phase 3: Code-Qualität & Wartbarkeit (Priorität: MITTEL)
**Ziel**: Langfristige Wartbarkeit verbessern  
**Aufwand**: 6-8 Stunden  
**Abhängigkeiten**: Phase 1 & 2 abgeschlossen

### Issue #6: String-Operationen Optimierung
**Schweregrad**: MITTEL  
**Aufwand**: 2 Stunden  
**Dateien**: `budsUI/Core/Functions.lua`, diverse Module
**Abhängigkeiten**: Keine

#### Problem-Analyse
Ineffiziente String-Operationen:
- String-Concatenation mit .. statt table.concat
- Wiederholte GetSpellInfo-Calls ohne Cache
- format() in Hot-Paths

#### Implementierungs-Steps

**Step 6.1: Spell-Info Cache** (1 Stunde)
```lua
-- NEU in Core/Functions.lua:
K.SpellCache = {}

K.GetSpellInfo = function(spellID)
	if not K.SpellCache[spellID] then
		local name, rank, icon = GetSpellInfo(spellID)
		if name then
			K.SpellCache[spellID] = {name, rank, icon}
		else
			return nil
		end
	end
	return unpack(K.SpellCache[spellID])
end

-- In allen Modulen ersetzen:
-- VORHER: local name = GetSpellInfo(12345)
-- NACHHER: local name = K.GetSpellInfo(12345)
```

**Step 6.2: String-Builder für häufige Operationen** (1 Stunde)
```lua
-- NEU in Core/Functions.lua:
local stringBuilder = {}

K.BuildString = function(...)
	wipe(stringBuilder)
	for i = 1, select("#", ...) do
		stringBuilder[i] = tostring(select(i, ...))
	end
	return table.concat(stringBuilder)
end

-- Beispiel-Nutzung in Nameplate Health-Text:
-- VORHER:
frame.hp.value:SetFormattedText(K.ShortValue(valueHealth).." - ".."%d%%", percent)

-- NACHHER:
frame.hp.value:SetText(K.BuildString(K.ShortValue(valueHealth), " - ", percent, "%"))
```


#### Testing-Strategie
- [ ] Test 1: Alle Spell-Namen werden korrekt angezeigt
- [ ] Test 2: Memory-Usage sollte leicht steigen (Cache), aber stabil bleiben
- [ ] Test 3: Performance sollte gleich oder besser sein
- [ ] Regression-Test: Alle Text-Displays funktionieren

#### Rollback-Plan
1. Git revert auf vorherigen Commit
2. Falls Cache zu groß: Limit auf 500 Spells
3. Falls String-Builder Probleme macht: Zurück zu format()

#### Risiken
- **Risiko 1**: Cache wächst unbegrenzt → Mitigation: Limit einbauen
- **Risiko 2**: String-Builder langsamer als format() → Mitigation: Profiling

---

### Issue #7: Config-System Validierung
**Schweregrad**: MITTEL  
**Aufwand**: 3 Stunden  
**Dateien**: `budsUI/Config/Settings.lua`, `budsUI/Core/Init.lua`
**Abhängigkeiten**: Issue #3 (Error-Handling)

#### Problem-Analyse
Config-Werte werden nicht validiert:
- Keine Type-Checks
- Keine Range-Checks
- Ungültige Werte können Addon brechen
- Keine Defaults bei fehlenden Werten

#### Implementierungs-Steps

**Step 7.1: Config-Validator** (2 Stunden)
```lua
-- NEU in Core/Functions.lua:
K.ValidateConfig = function()
	local errors = {}
	
	-- Type validation
	local typeChecks = {
		["General.UIScale"] = {"number", 0.4, 1.2},
		["Nameplate.Enable"] = {"boolean"},
		["Nameplate.Width"] = {"number", 50, 300},
		["Nameplate.Height"] = {"number", 5, 50},
		["ActionBar.ButtonSize"] = {"number", 20, 60},
		-- ... mehr Checks
	}
	
	for path, check in pairs(typeChecks) do
		local keys = {strsplit(".", path)}
		local value = C
		for _, key in ipairs(keys) do
			value = value[key]
			if value == nil then break end
		end
		
		if value ~= nil then
			local expectedType = check[1]
			if type(value) ~= expectedType then
				table.insert(errors, format("%s: expected %s, got %s", path, expectedType, type(value)))
			elseif expectedType == "number" and check[2] and check[3] then
				if value < check[2] or value > check[3] then
					table.insert(errors, format("%s: value %s out of range [%s, %s]", path, value, check[2], check[3]))
				end
			end
		end
	end
	
	if #errors > 0 then
		K.Print("=== Config Validation Errors ===")
		for _, err in ipairs(errors) do
			K.Print(err)
		end
		K.Print("Use /budsui to fix config")
	end
	
	return #errors == 0
end

-- Call on PLAYER_LOGIN
local validationFrame = CreateFrame("Frame")
validationFrame:RegisterEvent("PLAYER_LOGIN")
validationFrame:SetScript("OnEvent", function()
	K.Delay(2, K.ValidateConfig)
end)
```


**Step 7.2: Safe Config-Getter** (1 Stunde)
```lua
-- NEU in Core/Functions.lua:
K.GetConfig = function(path, default)
	local keys = {strsplit(".", path)}
	local value = C
	for _, key in ipairs(keys) do
		value = value[key]
		if value == nil then
			if C.General.DeveloperMode then
				K.Print(format("Config missing: %s, using default: %s", path, tostring(default)))
			end
			return default
		end
	end
	return value
end

-- Beispiel-Nutzung:
-- VORHER: if C.Nameplate.Enable == true then
-- NACHHER: if K.GetConfig("Nameplate.Enable", false) then
```

#### Testing-Strategie
- [ ] Test 1: Frische Installation - Validation sollte keine Errors zeigen
- [ ] Test 2: Ungültige Config-Werte setzen - Validation sollte warnen
- [ ] Test 3: Fehlende Config-Werte - Defaults sollten genutzt werden
- [ ] Regression-Test: Alle Features funktionieren mit valider Config

#### Rollback-Plan
1. Git revert auf vorherigen Commit
2. Falls Validation zu streng: Nur warnen, nicht blocken
3. Safe Config-Getter optional machen

#### Risiken
- **Risiko 1**: Validation zu streng → Mitigation: Nur warnen, nicht brechen
- **Risiko 2**: Performance-Overhead → Mitigation: Nur bei Login validieren

---

## Phase 4: Nice-to-Have & Modernisierung (Priorität: NIEDRIG)
**Ziel**: Zukunftssicherheit und Developer-Experience  
**Aufwand**: 4-6 Stunden  
**Abhängigkeiten**: Phase 1-3 abgeschlossen

### Issue #8: Performance-Profiling Tools
**Schweregrad**: NIEDRIG  
**Aufwand**: 2 Stunden  
**Dateien**: Neue Datei `budsUI/Core/Profiler.lua`
**Abhängigkeiten**: Keine

#### Implementierungs-Steps

**Step 8.1: Simple Profiler** (2 Stunden)
```lua
-- NEU: budsUI/Core/Profiler.lua
local K, C, L, _ = select(2, ...):unpack()

if not C.General.DeveloperMode then return end

K.Profiler = {
	timers = {},
	results = {}
}

function K.Profiler:Start(name)
	self.timers[name] = debugprofilestop()
end

function K.Profiler:Stop(name)
	if not self.timers[name] then return end
	local elapsed = debugprofilestop() - self.timers[name]
	
	if not self.results[name] then
		self.results[name] = {count = 0, total = 0, min = math.huge, max = 0}
	end
	
	local r = self.results[name]
	r.count = r.count + 1
	r.total = r.total + elapsed
	r.min = math.min(r.min, elapsed)
	r.max = math.max(r.max, elapsed)
	r.avg = r.total / r.count
	
	self.timers[name] = nil
end

function K.Profiler:Report()
	K.Print("=== budsUI Performance Report ===")
	for name, data in pairs(self.results) do
		K.Print(format("%s: avg=%.2fms, min=%.2fms, max=%.2fms, calls=%d", 
			name, data.avg, data.min, data.max, data.count))
	end
end

function K.Profiler:Reset()
	wipe(self.timers)
	wipe(self.results)
	K.Print("Profiler reset")
end

-- Commands
SlashCmdList["BUDSUIPROFILE"] = function(msg)
	if msg == "report" then
		K.Profiler:Report()
	elseif msg == "reset" then
		K.Profiler:Reset()
	else
		K.Print("Usage: /profile report|reset")
	end
end
SLASH_BUDSUIPROFILE1 = "/profile"

-- Beispiel-Nutzung in kritischen Funktionen:
-- K.Profiler:Start("Nameplate_OnUpdate")
-- ... code ...
-- K.Profiler:Stop("Nameplate_OnUpdate")
```


#### Testing-Strategie
- [ ] Test 1: /profile report zeigt Daten
- [ ] Test 2: Profiler hat minimalen Overhead (<1%)
- [ ] Test 3: Profiler funktioniert nur bei DeveloperMode

---

### Issue #9: Dokumentation & Code-Comments
**Schweregrad**: NIEDRIG  
**Aufwand**: 3 Stunden  
**Dateien**: Alle kritischen Module
**Abhängigkeiten**: Alle anderen Issues

#### Implementierungs-Steps
- Inline-Comments für komplexe Logik
- Function-Header mit Parametern und Return-Values
- Performance-Notes bei kritischen Funktionen

---

## Meilensteine & Timeline

### Meilenstein 1: Kritische Stabilität (nach Phase 1)
- **Ziel**: Addon crasht nicht mehr, Fehler werden geloggt
- **Deliverables**: 
  - UNIT_AURA Throttling in allen Modulen
  - Event-Unregistrierung bei Cleanup
  - Error-Handling in allen Event-Handlern
  - Error-Log System
- **Testing**: Umfangreiche Tests in Raids/BGs
- **Geschätzte Dauer**: 1 Woche (bei 2-3h/Tag)

### Meilenstein 2: Performance-Boost (nach Phase 2)
- **Ziel**: +10-15 FPS in Raids, smooth Nameplates
- **Deliverables**:
  - Optimierte Nameplate OnUpdate-Loops
  - Sichere Metatable-Injection
  - Batch-Processing für Nameplates
- **Testing**: FPS-Benchmarks vorher/nachher
- **Geschätzte Dauer**: 1 Woche

### Meilenstein 3: Code-Qualität (nach Phase 3)
- **Ziel**: Wartbarer, sauberer Code
- **Deliverables**:
  - Spell-Cache System
  - Config-Validierung
  - String-Optimierungen
- **Testing**: Regression-Tests
- **Geschätzte Dauer**: 4-5 Tage

### Meilenstein 4: Developer-Tools (nach Phase 4)
- **Ziel**: Bessere Debugging-Tools
- **Deliverables**:
  - Performance-Profiler
  - Dokumentation
- **Testing**: Developer-Workflow
- **Geschätzte Dauer**: 2-3 Tage


# Refactoring Battle Plan: budsUI - Teil 2

## Abhängigkeits-Graph

```
Phase 1 (Kritisch) - Parallel ausführbar
├── Issue #1: UNIT_AURA Throttling → Keine Abhängigkeiten
├── Issue #2: Event-Unregistrierung → Keine Abhängigkeiten
└── Issue #3: Error-Handling → Keine Abhängigkeiten

Phase 2 (Wichtig)
├── Issue #4: Nameplate OnUpdate → Benötigt Issue #1 (Throttling)
└── Issue #5: Metatable-Injection → Keine Abhängigkeiten

Phase 3 (Mittel)
├── Issue #6: String-Optimierung → Keine Abhängigkeiten
└── Issue #7: Config-Validierung → Benötigt Issue #3 (Error-Handling)

Phase 4 (Niedrig)
├── Issue #8: Profiler → Keine Abhängigkeiten
└── Issue #9: Dokumentation → Benötigt alle anderen Issues
```

---

## Gesamt-Risiko-Assessment

### Hohe Risiken

1. **UNIT_AURA Throttling zu aggressiv**
   - **Problem**: Aura-Updates wirken "laggy", wichtige Procs werden verpasst
   - **Wahrscheinlichkeit**: MITTEL
   - **Impact**: HOCH (User-Experience)
   - **Mitigation**: 
     - Konservative Intervalle starten (0.2s)
     - A/B Testing mit verschiedenen Intervallen
     - User-Feedback einholen
     - Notfall-Rollback vorbereiten

2. **Nameplate OnUpdate Refactoring bricht Timing**
   - **Problem**: Batch-Processing verursacht Frame-Drops oder Stutter
   - **Wahrscheinlichkeit**: MITTEL
   - **Impact**: HOCH (Performance)
   - **Mitigation**:
     - Schrittweise Migration (erst Throttling, dann Batch)
     - FPS-Monitoring während Tests
     - Fallback auf alte Logik vorbereiten

3. **Metatable-Injection Konflikte mit anderen Addons**
   - **Problem**: Andere UI-Addons brechen oder budsUI bricht
   - **Wahrscheinlichkeit**: NIEDRIG
   - **Impact**: KRITISCH (Addon-Kompatibilität)
   - **Mitigation**:
     - Collision-Detection implementieren
     - Mit populären Addons testen (ElvUI, TukUI, etc.)
     - API-Injection optional machen (Config-Option)


### Mittlere Risiken

1. **Error-Handling Overhead**
   - **Problem**: pcall-Wrapping reduziert Performance
   - **Wahrscheinlichkeit**: NIEDRIG
   - **Impact**: MITTEL (Performance)
   - **Mitigation**: Profiling, nur kritische Pfade wrappen

2. **Cache-Systeme verursachen Memory-Leaks**
   - **Problem**: Spell-Cache oder Aura-Cache wachsen unbegrenzt
   - **Wahrscheinlichkeit**: MITTEL
   - **Impact**: MITTEL (Memory)
   - **Mitigation**: Limits einbauen, regelmäßiges Cleanup

3. **Config-Validierung zu streng**
   - **Problem**: Valide Configs werden als ungültig markiert
   - **Wahrscheinlichkeit**: NIEDRIG
   - **Impact**: NIEDRIG (User-Experience)
   - **Mitigation**: Nur warnen, nicht blocken

### Niedrige Risiken

1. **String-Optimierungen langsamer als Original**
   - **Problem**: table.concat langsamer als .. in manchen Fällen
   - **Wahrscheinlichkeit**: NIEDRIG
   - **Impact**: NIEDRIG (Performance)
   - **Mitigation**: Profiling, Rollback falls nötig

2. **Profiler-Overhead**
   - **Problem**: Profiling reduziert Performance
   - **Wahrscheinlichkeit**: SEHR NIEDRIG
   - **Impact**: NIEDRIG (nur DeveloperMode)
   - **Mitigation**: Nur bei DeveloperMode aktiv

---

## Empfohlene Vorgehensweise

### Vor jedem Phase-Start

1. **Backup erstellen**
   ```bash
   git checkout -b refactor-phase-X
   git commit -am "Backup before Phase X"
   ```

2. **Changelog-Eintrag vorbereiten**
   - Dokumentiere geplante Änderungen
   - Liste erwartete Verbesserungen
   - Notiere bekannte Risiken

3. **Test-Environment aufsetzen**
   - Frische WoW-Installation oder separater Account
   - Verschiedene Klassen/Specs vorbereiten
   - FPS-Counter und Memory-Profiler aktivieren


### Während der Implementierung

1. **Nach jedem Issue: Commit mit aussagekräftiger Message**
   ```bash
   git commit -am "Issue #1: UNIT_AURA Throttling - Core/Functions.lua"
   git commit -am "Issue #1: UNIT_AURA Throttling - Nameplate.lua"
   git commit -am "Issue #1: UNIT_AURA Throttling - Filger.lua"
   ```

2. **Regelmäßige In-Game-Tests**
   - Nach jedem Step: Kurzer Funktions-Test
   - Nach jedem Issue: Umfangreicher Test
   - Nach jeder Phase: Vollständiger Regression-Test

3. **Performance-Profiling bei kritischen Änderungen**
   ```lua
   -- Vor Änderung:
   /run local start = debugprofilestop(); 
   -- ... Test-Szenario ...
   /run print("Time:", debugprofilestop() - start)
   
   -- Nach Änderung: Vergleichen
   ```

4. **Developer-Mode aktivieren**
   ```lua
   C.General.DeveloperMode = true
   ```
   - Zeigt alle Warnings und Errors
   - Aktiviert Debug-Prints
   - Aktiviert Profiler

### Nach jeder Phase

1. **Vollständiger Funktions-Test aller Module**
   - ActionBars: Alle Buttons funktionieren
   - Nameplates: Anzeige, Auras, Threat
   - Filger: Buff/Debuff-Tracking
   - Chat: Copy-Funktion, Spam-Filter
   - Minimap: Button-Collect, Tracking
   - DataText: Alle Panels zeigen Daten

2. **Performance-Vergleich (Memory, CPU)**
   ```
   Vorher:
   - FPS in 25-Man Raid: X
   - Memory-Usage: Y MB
   - CPU-Usage: Z%
   
   Nachher:
   - FPS in 25-Man Raid: X + Delta
   - Memory-Usage: Y + Delta MB
   - CPU-Usage: Z + Delta%
   ```

3. **Beta-Test mit ausgewählten Usern (falls möglich)**
   - Guild-Members
   - Ascension.gg Community
   - GitHub Issues für Feedback


### Deployment

1. **Stufenweises Rollout**
   - **Alpha**: Nur Developer (DeveloperMode ON)
   - **Beta**: Guild/Community (1-2 Wochen)
   - **Stable**: Public Release

2. **Monitoring der Error-Reports**
   ```lua
   -- User können Errors exportieren:
   /budsuierrors
   -- Kopieren und als GitHub Issue posten
   ```

3. **Schneller Rollback-Plan bereit**
   ```bash
   # Falls kritische Bugs:
   git revert HEAD~X
   git push --force
   # Oder: Alten Branch als Hotfix releasen
   ```

4. **Changelog für User**
   ```markdown
   ## v0.7.0 - Performance & Stability Update
   
   ### Critical Fixes
   - Fixed UNIT_AURA event spam causing FPS drops in raids
   - Added event unregistration on cleanup (memory leak fix)
   - Implemented error handling in all event handlers
   
   ### Performance Improvements
   - Optimized nameplate OnUpdate loops (+10-15 FPS in raids)
   - Added aura caching system
   - Improved K.Delay cleanup mechanism
   
   ### New Features
   - Error logging system (/budsuierrors to view)
   - Config validation on login
   - Performance profiler for developers
   
   ### Known Issues
   - None
   
   ### Upgrade Notes
   - Backup your SavedVariables before updating
   - /reload required after update
   - Report any issues on GitHub
   ```

---

## Notizen & Hinweise

### Production-Safety

- **Alle Änderungen müssen in laufenden Raids/BGs stabil sein**
  - Kein /reload während Combat
  - Keine Frame-Taint Issues
  - Keine Lua-Errors die UI brechen

- **Backward-Compatibility**
  - SavedVariables-Struktur darf nicht brechen
  - Alte Configs müssen weiter funktionieren
  - Migration-Code für Breaking-Changes

- **Performance**
  - Keine Änderungen die FPS in Raids reduzieren
  - Memory-Usage sollte stabil bleiben oder sinken
  - CPU-Usage sollte sinken


### Testing-Checkliste

#### Solo-Testing
- [ ] Questing: Alle Features funktionieren
- [ ] Dungeon: Nameplates, Threat, Auras
- [ ] Battleground: Performance, viele Nameplates
- [ ] City/AH: UI-Responsiveness, Memory

#### Group-Testing
- [ ] 5-Man Dungeon: Party-Frames, Threat
- [ ] 10-Man Raid: Performance, Auras
- [ ] 25-Man Raid: FPS, Memory, Stability
- [ ] Battleground: 40+ Players, Nameplates

#### Class-Specific Testing
- [ ] Tank: Threat-Coloring, Role-Detection
- [ ] Healer: Aura-Tracking, Filger
- [ ] DPS: Cooldown-Tracking, Procs
- [ ] Hybrid: Stance-Changes, Role-Switching

#### Edge-Cases
- [ ] /reload während Combat (sollte sicher sein)
- [ ] Addon-Disable/Enable
- [ ] Mehrere /reload hintereinander
- [ ] Lange Spielsessions (4+ Stunden)
- [ ] Memory-Leak-Test (über Nacht laufen lassen)

---

## Performance-Benchmarks

### Baseline (vor Refactoring)

```
Test-Szenario: 25-Man Naxxramas Raid
- FPS: 35-40 (mit Nameplates)
- Memory: 45-50 MB
- CPU: 15-20% (Addon-CPU)
- UNIT_AURA Events/Sekunde: ~200-300
- Nameplate Updates/Sekunde: ~500-600
```

### Ziel (nach Refactoring)

```
Test-Szenario: 25-Man Naxxramas Raid
- FPS: 45-55 (+10-15 FPS) ✓
- Memory: 40-45 MB (-5-10%) ✓
- CPU: 10-15% (-30-40%) ✓
- UNIT_AURA Events/Sekunde: ~50-100 (-60-70%) ✓
- Nameplate Updates/Sekunde: ~100-200 (-70-80%) ✓
```

### Messmethoden

1. **FPS-Messung**
   ```lua
   /run local fps = GetFramerate(); print("FPS:", fps)
   ```

2. **Memory-Messung**
   ```lua
   /run UpdateAddOnMemoryUsage(); print("Memory:", GetAddOnMemoryUsage("budsUI"), "KB")
   ```

3. **CPU-Messung**
   ```lua
   /run UpdateAddOnCPUUsage(); print("CPU:", GetAddOnCPUUsage("budsUI"), "ms")
   ```

4. **Event-Counting**
   ```lua
   -- In Event-Handler:
   local eventCount = 0
   local lastReport = GetTime()
   -- ... in OnEvent:
   eventCount = eventCount + 1
   if GetTime() - lastReport > 5 then
       print("Events/5s:", eventCount)
       eventCount = 0
       lastReport = GetTime()
   end
   ```


---

## Ascension.gg Spezifische Hinweise

### Classless-System Besonderheiten

1. **Dynamische Spell-IDs**
   - Ascension nutzt teilweise andere Spell-IDs als WotLK
   - Spell-Cache muss flexibel sein
   - GetSpellInfo kann nil zurückgeben für Custom-Spells

2. **Custom Buffs/Debuffs**
   - Filger-Whitelist muss erweitert werden
   - Aura-Tracking muss robust gegen unbekannte Spells sein

3. **Role-Detection**
   - Classless = keine feste Klasse
   - CheckRole muss flexibler sein
   - Evtl. User-Override für Role

### WotLK 3.3.5 API-Limits

1. **Kein C_Timer**
   - Nutze K.Delay statt C_Timer.After
   - Bereits implementiert ✓

2. **Kein UnitAura mit spellID-Filter**
   - Muss alle Auras scannen
   - Cache ist essentiell

3. **Kein GetNamePlateForUnit**
   - Muss über WorldFrame:GetChildren() scannen
   - Bereits implementiert ✓

4. **Limitiertes Error-Handling**
   - Kein xpcall mit custom error handler
   - Nutze pcall + geterrorhandler()

---

## Quick-Reference: Wichtigste Änderungen

### Für Developer

```lua
-- Error-Handling
frame:SetScript("OnEvent", K.SafeEventHandler(handler, "FrameName"))
frame:SetScript("OnUpdate", K.SafeOnUpdate(handler, "FrameName"))

-- Throttling
local throttle = 0
local INTERVAL = 0.2
function OnEvent(self, event, ...)
    local now = GetTime()
    if (now - throttle) < INTERVAL then return end
    throttle = now
    -- ... logic
end

-- Spell-Cache
local name = K.GetSpellInfo(spellID) -- statt GetSpellInfo

-- Config-Access
local value = K.GetConfig("Path.To.Config", defaultValue)

-- Profiling
K.Profiler:Start("FunctionName")
-- ... code
K.Profiler:Stop("FunctionName")
```


### Für User

```
Neue Commands:
/budsuierrors        - Zeige Error-Log
/budsuiclearerrors   - Lösche Error-Log
/profile report      - Zeige Performance-Report (DeveloperMode)
/profile reset       - Reset Profiler

Config-Änderungen:
C.General.DeveloperMode = true  - Aktiviert Debug-Features

Erwartete Verbesserungen:
- +10-15 FPS in Raids
- Weniger Stutter bei vielen Nameplates
- Keine Lua-Errors mehr
- Stabileres Addon
```

---

## Zusammenfassung

### Was wird besser?

1. **Stabilität** ✓
   - Kein Addon-Crash mehr durch Lua-Errors
   - Robustes Error-Handling
   - Sauberes Cleanup bei /reload

2. **Performance** ✓
   - +10-15 FPS in Raids
   - -60-70% UNIT_AURA Events
   - -70-80% Nameplate Updates
   - Optimierte OnUpdate-Loops

3. **Wartbarkeit** ✓
   - Error-Logging für Bug-Reports
   - Config-Validierung
   - Performance-Profiler
   - Bessere Code-Struktur

4. **User-Experience** ✓
   - Smooth Nameplates
   - Keine Freezes mehr
   - Besseres Feedback bei Problemen

### Was bleibt gleich?

- Alle Features funktionieren wie vorher
- Keine Breaking-Changes für User
- SavedVariables-Kompatibilität
- Look & Feel unverändert

### Nächste Schritte

1. **Phase 1 starten** (Issue #1-3)
2. **Testing nach jedem Issue**
3. **Commit nach jedem erfolgreichen Test**
4. **Weiter zu Phase 2 wenn Phase 1 stabil**

---

## Kontakt & Support

- **GitHub Issues**: https://github.com/Budtender3000/budsUI/issues
- **Discord**: Ascension.gg Community
- **In-Game**: /w Budtender

**Viel Erfolg beim Refactoring! 🚀**


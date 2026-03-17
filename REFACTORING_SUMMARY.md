# budsUI Refactoring Battle Plan - Executive Summary

## Übersicht

Dieser Refactoring-Plan adressiert kritische Performance- und Stabilitätsprobleme in budsUI v0.2.0 für WoW 3.3.5 (WotLK) auf Ascension.gg.

**Dokumente:**
- `REFACTORING_BATTLEPLAN.md` - Detaillierte Implementierung (Phase 1-4)
- `REFACTORING_BATTLEPLAN_PART2.md` - Risiko-Assessment, Testing, Deployment

---

## Kritische Issues (SOFORT)

### 1. UNIT_AURA Event-Spam
**Problem**: 200-300 Events/Sekunde in Raids ohne Throttling  
**Lösung**: Throttling auf 0.2s Intervalle (-60-70% Events)  
**Impact**: +5-10 FPS in Raids  
**Aufwand**: 2 Stunden

### 2. Fehlende Event-Unregistrierung
**Problem**: Memory-Leaks durch nicht-unregistrierte Events  
**Lösung**: Cleanup in OnHide, verbesserte Kill() Funktion  
**Impact**: -5-10% Memory-Usage  
**Aufwand**: 2 Stunden

### 3. Kein Error-Handling
**Problem**: Ein Fehler crasht das gesamte Addon  
**Lösung**: K.SafeEventHandler, Error-Logging System  
**Impact**: Stabilität, besseres Debugging  
**Aufwand**: 3 Stunden

---

## Performance-Optimierungen (HOCH)

### 4. Ineffiziente Nameplate OnUpdate-Loops
**Problem**: 500-600 Updates/Sekunde für alle Nameplates  
**Lösung**: Batch-Processing, konsolidierte Update-Logik  
**Impact**: +10-15 FPS in Raids  
**Aufwand**: 3 Stunden

### 5. Unsichere Metatable-Injection
**Problem**: Kann andere Addons brechen  
**Lösung**: Collision-Detection, Versionierung  
**Impact**: Bessere Addon-Kompatibilität  
**Aufwand**: 2 Stunden

---

## Gesamtaufwand & Timeline

- **Phase 1 (Kritisch)**: 8-10 Stunden → 1 Woche
- **Phase 2 (Performance)**: 8-10 Stunden → 1 Woche
- **Phase 3 (Code-Qualität)**: 6-8 Stunden → 4-5 Tage
- **Phase 4 (Nice-to-Have)**: 4-6 Stunden → 2-3 Tage

**Gesamt**: 24-32 Stunden über 2-3 Wochen (bei 2-3h/Tag)

---

## Erwartete Verbesserungen

### Performance
- **FPS**: +10-15 FPS in 25-Man Raids
- **Memory**: -5-10% Memory-Usage
- **CPU**: -30-40% Addon-CPU
- **Events**: -60-70% UNIT_AURA Events

### Stabilität
- Keine Lua-Errors mehr
- Kein Addon-Crash
- Sauberes Cleanup
- Error-Logging für Bug-Reports

### User-Experience
- Smooth Nameplates
- Keine Freezes
- Besseres Feedback bei Problemen

---

## Risiken & Mitigation

### Hohe Risiken
1. **Throttling zu aggressiv** → Konservative Intervalle, A/B Testing
2. **OnUpdate-Refactoring bricht Timing** → Schrittweise Migration
3. **Metatable-Konflikte** → Collision-Detection, Testing mit anderen Addons

### Mittlere Risiken
1. **pcall-Overhead** → Nur kritische Pfade wrappen
2. **Cache-Memory-Leaks** → Limits einbauen
3. **Config-Validierung zu streng** → Nur warnen, nicht blocken

---

## Quick-Start Guide

### 1. Backup erstellen
```bash
git checkout -b refactor-phase-1
git commit -am "Backup before refactoring"
```

### 2. Phase 1 starten (Issue #1)
- Öffne `budsUI/Core/Functions.lua`
- Implementiere CheckRole Throttling (siehe REFACTORING_BATTLEPLAN.md Step 1.1)
- Test: Solo Questing, FPS-Check
- Commit: `git commit -am "Issue #1: UNIT_AURA Throttling - Core/Functions.lua"`

### 3. Weiter mit Issue #1 Steps 1.2-1.3
- Nameplate.lua Throttling
- Filger.lua Cache-Optimierung
- Testing nach jedem Step

### 4. Nach Phase 1: Vollständiger Test
- Alle Testing-Checklisten durchgehen
- Performance-Benchmarks
- Commit: `git commit -am "Phase 1 complete: Critical Fixes"`

### 5. Weiter zu Phase 2
- Nur wenn Phase 1 stabil ist!

---

## Wichtige Commands

```lua
-- Developer-Mode aktivieren
C.General.DeveloperMode = true

-- Error-Log anzeigen
/budsuierrors

-- Performance-Report
/profile report

-- FPS messen
/run print("FPS:", GetFramerate())

-- Memory messen
/run UpdateAddOnMemoryUsage(); print("Memory:", GetAddOnMemoryUsage("budsUI"), "KB")
```

---

## Support & Feedback

- **GitHub**: https://github.com/Budtender3000/budsUI/issues
- **Testing**: Nach jeder Phase Beta-Test mit Community
- **Rollback**: Immer bereit bei kritischen Bugs

**Viel Erfolg! 🚀**


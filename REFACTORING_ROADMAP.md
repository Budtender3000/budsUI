# budsUI Refactoring Roadmap - Visual Guide

## 🎯 Ziel: Stabiles, performantes Addon für Ascension.gg WotLK 3.3.5

---

## 📊 Aktueller Zustand (v0.2.0)

```
Performance in 25-Man Raid:
┌─────────────────────────────────────┐
│ FPS:    ████████░░░░░░░░  35-40     │
│ Memory: ████████████░░░░  45-50 MB  │
│ CPU:    ████████░░░░░░░░  15-20%    │
│ Events: ████████████████  200-300/s │
└─────────────────────────────────────┘

Probleme:
❌ UNIT_AURA Event-Spam
❌ Memory-Leaks
❌ Keine Error-Handling
❌ Ineffiziente OnUpdate-Loops
❌ Unsichere Metatable-Injection
```

---

## 🎯 Ziel-Zustand (v0.7.0)

```
Performance in 25-Man Raid:
┌─────────────────────────────────────┐
│ FPS:    ████████████░░░░  45-55     │
│ Memory: ██████████░░░░░░  40-45 MB  │
│ CPU:    █████░░░░░░░░░░░  10-15%    │
│ Events: ████░░░░░░░░░░░░  50-100/s  │
└─────────────────────────────────────┘

Verbesserungen:
✅ +10-15 FPS
✅ -5-10% Memory
✅ -30-40% CPU
✅ -60-70% Events
✅ Keine Crashes
✅ Error-Logging
```

---

## 🗓️ Zeitplan (2-3 Wochen)

```
Woche 1: Phase 1 - Kritische Fixes
├── Tag 1-2: Issue #1 - UNIT_AURA Throttling
│   ├── Core/Functions.lua (30 Min)
│   ├── Nameplate.lua (45 Min)
│   ├── Filger.lua (45 Min)
│   └── Testing (2 Stunden)
│
├── Tag 3-4: Issue #2 - Event-Unregistrierung
│   ├── Nameplate Cleanup (45 Min)
│   ├── Kill() Funktion (30 Min)
│   ├── K.Delay Cleanup (45 Min)
│   └── Testing (2 Stunden)
│
└── Tag 5-7: Issue #3 - Error-Handling
    ├── SafeEventHandler (30 Min)
    ├── Nameplate Wrapping (45 Min)
    ├── Filger Wrapping (45 Min)
    ├── Error-Log Commands (30 Min)
    └── Testing (3 Stunden)

Woche 2: Phase 2 - Performance
├── Tag 8-10: Issue #4 - Nameplate OnUpdate
│   ├── ForEachPlate Optimierung (1 Stunde)
│   ├── Konsolidierte Update-Logik (1.5 Stunden)
│   ├── API-Call Caching (30 Min)
│   └── Testing (2 Stunden)
│
└── Tag 11-12: Issue #5 - Metatable-Injection
    ├── Collision-Detection (1.5 Stunden)
    ├── Cleanup-Funktion (30 Min)
    └── Testing (2 Stunden)

Woche 3: Phase 3 & 4 - Qualität
├── Tag 13-15: Phase 3 - Code-Qualität
│   ├── Spell-Cache (1 Stunde)
│   ├── String-Builder (1 Stunde)
│   ├── Config-Validator (2 Stunden)
│   └── Testing (2 Stunden)
│
└── Tag 16-18: Phase 4 - Developer-Tools
    ├── Profiler (2 Stunden)
    ├── Dokumentation (3 Stunden)
    └── Final Testing (3 Stunden)
```


---

## 🔄 Workflow pro Issue

```
1. Backup
   └─> git checkout -b issue-X

2. Implementierung
   ├─> Step 1 → Test → Commit
   ├─> Step 2 → Test → Commit
   └─> Step 3 → Test → Commit

3. Testing
   ├─> Solo-Test
   ├─> Dungeon-Test
   ├─> Raid-Test
   └─> Performance-Benchmark

4. Review
   ├─> Code-Review
   ├─> Performance-Check
   └─> Regression-Test

5. Merge
   └─> git merge issue-X → main
```

---

## 📈 Meilensteine

```
M1: Kritische Stabilität (Woche 1)
┌────────────────────────────────────┐
│ ✅ UNIT_AURA Throttling            │
│ ✅ Event-Unregistrierung           │
│ ✅ Error-Handling                  │
│ ✅ Error-Log System                │
│                                    │
│ Deliverable: v0.6.0-alpha          │
│ Status: Intern testen              │
└────────────────────────────────────┘

M2: Performance-Boost (Woche 2)
┌────────────────────────────────────┐
│ ✅ Nameplate OnUpdate optimiert    │
│ ✅ Metatable-Injection sicher      │
│ ✅ +10-15 FPS in Raids             │
│                                    │
│ Deliverable: v0.6.5-beta           │
│ Status: Community-Beta             │
└────────────────────────────────────┘

M3: Code-Qualität (Woche 3)
┌────────────────────────────────────┐
│ ✅ Spell-Cache System              │
│ ✅ Config-Validierung              │
│ ✅ String-Optimierungen            │
│                                    │
│ Deliverable: v0.7.0-rc1            │
│ Status: Release-Candidate          │
└────────────────────────────────────┘

M4: Release (Ende Woche 3)
┌────────────────────────────────────┐
│ ✅ Profiler & Developer-Tools      │
│ ✅ Dokumentation                   │
│ ✅ Alle Tests bestanden            │
│                                    │
│ Deliverable: v0.7.0                │
│ Status: Public Release             │
└────────────────────────────────────┘
```

---

## 🎮 Testing-Matrix

```
┌──────────────┬─────┬─────┬──────┬──────┐
│ Szenario     │ P1  │ P2  │ P3   │ P4   │
├──────────────┼─────┼─────┼──────┼──────┤
│ Solo Quest   │ ✓   │ ✓   │ ✓    │ ✓    │
│ 5-Man Dung   │ ✓   │ ✓   │ ✓    │ ✓    │
│ 10-Man Raid  │ ✓   │ ✓   │ ✓    │ ✓    │
│ 25-Man Raid  │ ✓✓  │ ✓✓  │ ✓✓   │ ✓✓   │
│ Battleground │ ✓   │ ✓✓  │ ✓    │ ✓    │
│ City/AH      │ ✓   │ ✓   │ ✓    │ ✓    │
└──────────────┴─────┴─────┴──────┴──────┘

✓  = Standard-Test
✓✓ = Intensiv-Test mit Benchmarks
```

---

## 🚨 Rollback-Strategie

```
Problem erkannt?
    │
    ├─> Kritisch (Addon crasht)
    │   └─> SOFORT: git revert + Hotfix-Release
    │
    ├─> Hoch (Performance schlechter)
    │   └─> Analyse → Fix → Test → Release
    │
    └─> Mittel/Niedrig (Minor-Bugs)
        └─> GitHub Issue → Fix in nächster Version
```

---

## 📦 Release-Plan

```
v0.6.0-alpha (nach Phase 1)
├─> Intern testen (Developer)
├─> DeveloperMode ON
└─> 2-3 Tage Testing

v0.6.5-beta (nach Phase 2)
├─> Community-Beta (Guild)
├─> Feedback sammeln
└─> 1 Woche Testing

v0.7.0-rc1 (nach Phase 3)
├─> Release-Candidate
├─> Öffentliches Beta
└─> 3-5 Tage Testing

v0.7.0 (nach Phase 4)
├─> Public Release
├─> GitHub Release
└─> Changelog + Upgrade-Guide
```

---

## 🎯 Success-Kriterien

```
Phase 1: ✅ Wenn...
├─> Keine Lua-Errors in 2h Raid
├─> Error-Log funktioniert
└─> Memory-Leaks behoben

Phase 2: ✅ Wenn...
├─> +10 FPS in 25-Man Raid
├─> Smooth Nameplates
└─> Keine Performance-Regression

Phase 3: ✅ Wenn...
├─> Config-Validierung funktioniert
├─> Spell-Cache stabil
└─> Alle Regression-Tests bestanden

Phase 4: ✅ Wenn...
├─> Profiler funktioniert
├─> Dokumentation vollständig
└─> Community-Feedback positiv
```

---

## 🔧 Developer-Checkliste

```
Vor jedem Commit:
□ Code kompiliert ohne Errors
□ Lua-Syntax korrekt
□ In-Game getestet
□ Keine offensichtlichen Bugs
□ Commit-Message aussagekräftig

Vor jedem Phase-Abschluss:
□ Alle Issues der Phase abgeschlossen
□ Alle Tests bestanden
□ Performance-Benchmarks durchgeführt
□ Changelog aktualisiert
□ Git-Tag erstellt

Vor Release:
□ Alle Phasen abgeschlossen
□ Community-Beta erfolgreich
□ Keine kritischen Bugs
□ Dokumentation vollständig
□ GitHub Release vorbereitet
```

---

## 📞 Support-Kanäle

```
Während Refactoring:
├─> GitHub Issues (Bug-Reports)
├─> Discord (Community-Feedback)
└─> In-Game Whisper (Direkt-Support)

Nach Release:
├─> GitHub Issues (primär)
├─> Discord (Community)
└─> README.md (Dokumentation)
```

---

**Let's make budsUI great! 🚀**


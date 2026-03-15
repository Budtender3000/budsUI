# budsUI

<div align="center">
  <img src="budsUI/Media/assets/budsui_logo.png" alt="budsUI Logo" width="400">
  
  ### Modernes UI für World of Warcraft 3.3.5 (WotLK)
  
  [![Version](https://img.shields.io/badge/version-0.6.1-blue.svg)](https://github.com/Budtender3000/budsUI/releases)
  [![WoW](https://img.shields.io/badge/WoW-3.3.5-orange.svg)](https://ascension.gg)
  [![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
  
  **Speziell entwickelt für [Ascension.gg](https://ascension.gg) Classless Server**
</div>

---

## 🎮 Was ist budsUI?

budsUI ist ein vollständiger UI-Ersatz für World of Warcraft 3.3.5, der das veraltete Blizzard-Interface durch ein modernes, anpassbares Design ersetzt. Mit über 100 Konfigurationsoptionen kannst du dein Interface genau nach deinen Wünschen gestalten.

---

## 📸 Screenshots

<div align="center">
  <img src="budsUI/Media/assets/budsui_shot.jpg" alt="budsUI Screenshot" width="49%">
  <img src="budsUI/Media/assets/budsui_shot_worldmap.jpg" alt="budsUI Worldmap" width="49%">
  
  <img src="budsUI/Media/assets/budsui_shot_group.jpg" alt="budsUI Gruppen-Raid" width="99%">
  
  <img src="budsUI/Media/assets/budsui_shot_battleground.jpg" alt="budsUI Schlachtfeld" width="49%">
  <img src="budsUI/Media/assets/budsui_shot_battleground2.jpg" alt="budsUI Schlachtfeld 2" width="49%">
</div>

---
### ✨ Hauptfeatures

- 🎯 **Action Bars** - 5 anpassbare Bars mit Cooldown-Tracking und Range-Anzeige
- 👤 **Unit Frames** - Moderne Spieler-, Target- und Party-Frames
- 💬 **Chat-System** - Verbessertes Chat mit URL-Erkennung und Spam-Filter
- 🗺️ **Minimap** - Kompakte Minimap mit Button-Sammler und Farm-Modus
- 🎒 **Taschen** - Übersichtliche Taschen mit Item-Quality-Glow
- 💡 **Tooltips** - Erweiterte Tooltips mit Item-Level, Spell-IDs und mehr
- ⚡ **Automation** - Auto-Repair, Auto-Invite, Auto-Release und vieles mehr
- 🔔 **Ankündigungen** - Interrupt-, Sapped- und Pull-Countdown-Meldungen
- 🎨 **Skins** - Unterstützung für DBM, Recount, Skada, WeakAuras

---

## 📦 Installation

### Schritt 1: Download
- Lade die neueste Version von [Releases](https://github.com/Budtender3000/budsUI/releases) herunter
- Oder klone das Repository: `git clone https://github.com/Budtender3000/budsUI.git`

### Schritt 2: Installation
1. Entpacke das Archiv
2. Kopiere den `budsUI` Ordner nach `World of Warcraft/Interface/AddOns/`
3. Starte WoW neu

### Schritt 3: Konfiguration (empfohlen)
Für die beste Erfahrung installiere auch **budsUI_Config** für eine grafische Konfigurationsoberfläche:
- Download: [budsUI_Config](https://github.com/Budtender3000/budsUI_Config) (separates Addon)
- Kopiere nach `Interface/AddOns/`

### Schritt 4: Erste Schritte
Beim ersten Login erscheint automatisch der Installations-Wizard, der:
- Optimale UI-Einstellungen konfiguriert
- Chat-Fenster einrichtet
- Standard-Positionen festlegt

---

## 🎮 Verwendung

### Wichtige Befehle

```
/buds              - Öffnet das Konfigurationsmenü
/moveui            - Aktiviert Frame-Positionierung (Drag & Drop)
/moveui reset      - Setzt alle Positionen zurück
/rl                - UI neu laden (nach Änderungen erforderlich)
/installui         - Installations-Wizard erneut ausführen
/resetui           - Alle Einstellungen zurücksetzen
```

### Weitere nützliche Befehle

```
/rc                - Ready Check
/align             - Zeigt Positionierungs-Grid
/frame             - Frame-Inspector (zeigt Frame-Infos unter Cursor)
/boost             - Setzt Grafik auf Minimum (Performance-Modus)
/cc                - Chat leeren
```

[Vollständige Befehlsliste](TECHNICAL_DOCUMENTATION.md#befehle)

---

## ⚙️ Konfiguration

### Via GUI (empfohlen)
Mit installiertem **budsUI_Config**:
1. Tippe `/buds` im Chat
2. Navigiere durch die Kategorien
3. Ändere Einstellungen nach Wunsch
4. Tippe `/rl` um Änderungen zu übernehmen

### Via Lua-Datei
Fortgeschrittene Nutzer können direkt `budsUI/Config/Settings.lua` bearbeiten.

> ⚠️ **Wichtig:** Nach jeder Änderung muss das UI mit `/rl` neu geladen werden!

---

## 🔧 Module

<details>
<summary><b>Action Bars</b> - Anpassbare Aktionsleisten</summary>

- 5 frei positionierbare Bars
- Pet Bar & Shapeshift Bar
- Totem Bar (für Schamanen)
- Range-Färbung (rot = außer Reichweite)
- Cooldown-Text auf Buttons
- Split-Bar-Layout verfügbar

</details>

<details>
<summary><b>Unit Frames</b> - Spieler- und Gruppen-Frames</summary>

> ⚠️ Standardmäßig deaktiviert! Aktiviere in den Einstellungen.

- Spieler, Target, Focus, Pet
- Party & Arena Frames
- Castbars mit Verzögerungsanzeige
- Smooth Health/Power Bars
- Aura-Anzeige

</details>

<details>
<summary><b>Chat</b> - Verbessertes Chat-System</summary>

- Restyled Chat-Frames
- URL-Erkennung und Kopier-Funktion
- Chat-Kopier-Funktion (`/copychat`)
- Spam-Filter
- Whisper-Sounds
- `/tt` Befehl (Tell-to-Target)

</details>

<details>
<summary><b>Minimap</b> - Kompakte Minimap</summary>

- Modernes Design
- Button-Sammler (alle Minimap-Buttons in einem Dropdown)
- Farm-Modus (vergrößerte Minimap)
- Rechtsklick-Menü
- "Wer hat gepingt?"-Anzeige
- **Aktionsleisten-Sperre** - Spezieller Button ("L"/"U") zum Schalten des Leisten-Edit-Modus

</details>

<details>
<summary><b>Tooltips</b> - Erweiterte Tooltips</summary>

- Item-Level-Anzeige
- Spell-IDs
- Item-Count (Anzahl im Inventar)
- Achievement-Fortschritt
- Talent-Spezialisierung
- PvP-Rating
- Instance-Lock-Info

</details>

<details>
<summary><b>Automation</b> - Quality-of-Life-Features</summary>

- Auto-Invite (Keyword: "inv")
- Auto-Release bei Tod
- Auto-Repair (nutzt Guild-Bank wenn verfügbar)
- Auto-Verkauf grauer Items
- Auto-Decline Duels
- Auto-Screenshots bei Achievements
- Combat-Logging

</details>

<details>
<summary><b>Ankündigungen</b> - Automatische Chat-Meldungen</summary>

- Interrupt-Ankündigungen
- "Ich bin gesappt"-Meldung
- Pull-Countdown
- Feast & Portal-Alerts
- Bad-Gear-Warnung

</details>

<details>
<summary><b>Klassen-Module</b> - Klassenspezifische Features</summary>

- **Schamane:** Maelstrom Weapon Stack-Counter mit Animationen
- **Jäger:** Hunter-Utilities

> 💡 Wegen Ascension's Classless-System laden alle Module für alle Klassen

</details>

[Vollständige Modul-Dokumentation](TECHNICAL_DOCUMENTATION.md#module)

---

## ⚠️ Bekannte Einschränkungen

- **Unit Frames sind standardmäßig deaktiviert** - Muss manuell in den Einstellungen aktiviert werden
- **Einstellungen erfordern UI-Reload** - Keine Echtzeit-Änderungen möglich
- **Minimale Bildschirmbreite: 1200px** - Addon deaktiviert sich bei kleineren Auflösungen
- **Ascension.gg-spezifisch** - Einige Features sind auf Ascension zugeschnitten (z.B. Maelstrom Weapon Spell-ID)

---

## 🐛 Probleme melden

Hast du einen Bug gefunden? [Erstelle ein Issue](https://github.com/Budtender3000/budsUI/issues) mit:
- Beschreibung des Problems
- Schritte zur Reproduktion
- Screenshots (falls relevant)
- Lua-Errors (aktiviere mit `/luaerror on`)

---

## 🤝 Mitwirken

Contributions sind willkommen! 

1. Fork das Repository
2. Erstelle einen Feature-Branch (`git checkout -b feature/AmazingFeature`)
3. Commit deine Änderungen (`git commit -m 'Add some AmazingFeature'`)
4. Push zum Branch (`git push origin feature/AmazingFeature`)
5. Öffne einen Pull Request

Für technische Details siehe [TECHNICAL_DOCUMENTATION.md](TECHNICAL_DOCUMENTATION.md)

---

## 📚 Dokumentation

- **[TECHNICAL_DOCUMENTATION.md](TECHNICAL_DOCUMENTATION.md)** - Vollständige technische Dokumentation für Entwickler
- **[CHANGELOG.md](CHANGELOG.md)** - Versionshistorie und Änderungen
- **[INTERVIEW_NOTES.md](INTERVIEW_NOTES.md)** - Detaillierte Code-Analyse

---

## 💖 Credits & Lizenz

### Basiert auf
- **[KkthnxUI](https://github.com/kkthnx-wow/KkthnxUI)** von Josh "Kkthnx" Russell
- **[ShestakUI](https://github.com/Shestak/ShestakUI)** von Shestak
- **[DuffedUI](https://www.tukui.org/forum/viewforum.php?f=42)** von Duffed

### Autor
- **[Budtender3000](https://github.com/Budtender3000)** - Autor: Budtender3000 mit Buds

### Übersetzung
- **Buds** - Übersetzung und Wartung

### Lizenz
Dieses Projekt ist unter der [MIT-Lizenz](LICENSE) lizenziert.

Siehe auch: [Lizenzen der verwendeten Bibliotheken](budsUI/Licenses/)

---

<div align="center">
  
  **Viel Spaß mit budsUI! 🎮**
  
  [⭐ Star das Projekt](https://github.com/Budtender3000/budsUI) • [🐛 Bug melden](https://github.com/Budtender3000/budsUI/issues) • [💬 Discord](https://ascension.gg)
  
</div>

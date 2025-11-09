# Development Scripts

Utility scripts voor development workflow op Mac Mini en MacBook.

## 📋 Overzicht

### Git & Repository Management

#### `commit-push-all.sh` 🚀
**Commit en push alle repositories**
- Scant alle git repositories in Development folder (inclusief nested repos)
- Commit alle uncommitted changes automatisch
- Pusht alles naar GitHub
- Toont overzicht: gecommit, skipped, errors

**Gebruik:**
```bash
./commit-push-all.sh
```

**Wanneer gebruiken:** Als je "commit en push alles" wilt doen - dit script pakt ook nested repositories zoals claude-code-cloud die anders gemist worden.

---

#### `sync-all-repos.sh` 🔄
**Sync alle repositories (pull + push)**
- Pullt nieuwe changes van remote
- Pusht lokale changes naar remote
- **Let op:** Skipt repositories met uncommitted changes (veilige sync)

**Gebruik:**
```bash
./sync-all-repos.sh
```

**Wanneer gebruiken:** Als je wilt synchroniseren tussen MacBook en Mac Mini, maar alleen voor repos die al clean zijn.

---

#### `git-auto-pull-all.sh` 📥
**Automatisch pull alle repositories**
- Pullt alle git repos in Development folder
- Draait automatisch (via cron/LaunchAgent)
- Schrijft naar log: `~/.git-auto-pull.log`

**Wanneer gebruiken:** Wordt automatisch uitgevoerd. Handmatig draaien als je snel alle remote changes wilt binnenhalen.

---

#### `git-status-reminder.sh` 📊
**Check uncommitted/unpushed changes**
- Controleert alle repos op uncommitted changes
- Controleert alle repos op unpushed commits
- Toont reminder met lijst van repos die aandacht nodig hebben

**Gebruik:**
```bash
./git-status-reminder.sh
```

**Wanneer gebruiken:** Voor een quick scan van welke repositories nog gecommit/gepusht moeten worden.

---

#### `commit-gitignore.sh`
**Legacy script** - voegt secrets/ toe aan .gitignore
- Specifieke eenmalige actie
- Waarschijnlijk niet meer nodig

---

### Claude Code Management

#### `attach-claude` 🔌
**Attach aan draaiende Claude Code sessie**
- Verbindt met bestaande tmux sessie `claude-code`
- Gebruik als Claude Code al draait op de achtergrond

**Gebruik:**
```bash
./attach-claude
```

**Wanneer gebruiken:** Als je wilt terugkeren naar een lopende Claude Code sessie.

---

#### `new-claude` ✨
**Start nieuwe Claude Code sessie**
- Start verse Claude Code sessie in tmux
- Sessienaam met timestamp: `claude-code-[timestamp]`
- Start altijd in `$DEV_HOME`

**Gebruik:**
```bash
./new-claude
```

**Wanneer gebruiken:** Als je een nieuwe Claude Code sessie wilt starten (parallel aan bestaande, of als eerste sessie).

---

#### `complete-claude-reinstall.sh` 🔧
**Volledige Claude Code herinstallatie**
- Verwijdert oude installatie
- Installeert verse versie
- Configureert environment

**Wanneer gebruiken:** Bij problemen met Claude Code installatie, of voor major updates.

---

### System Maintenance

#### `check-devssd-ownership.sh` 🔍
**Controleer DevSSD bestandsrechten**
- Verifieert ownership van bestanden op DevSSD
- Detecteert permission problemen
- Voorkomt "permission denied" errors

**Wanneer gebruiken:** Als je permission errors krijgt bij git operaties op DevSSD.

---

#### `cleanup-devssd.sh` 🧹
**Opruimen DevSSD**
- Verwijdert tijdelijke bestanden
- Ruimt caches op
- Houdt DevSSD schoon

**Wanneer gebruiken:** Periodiek, of als DevSSD vol raakt.

---

#### `finish-folder-cleanup.sh`
**Folder cleanup completion**
- Laatste stap van folder reorganisatie
- Waarschijnlijk eenmalig gebruikt

---

### Project-Specifiek

#### `memonic-monthly-extract.sh` 📊
**Memonic maandelijkse data extract**
- Draait automatisch elke maand (1e dag, 03:00)
- Roept Memonic extract API aan
- Schrijft naar `/var/log/memonic-extract.log`

**Wanneer gebruiken:** Automatisch via cron. Handmatig alleen voor test/debug.

---

## 📁 Andere Bestanden

### `README-cleanup.md`
Documentatie over eerdere cleanup acties - archief/referentie.

---

## 💡 Tips

**Meest gebruikte scripts:**
- `commit-push-all.sh` - Als je alles wilt committen en pushen
- `attach-claude` - Terug naar lopende Claude Code sessie
- `new-claude` - Start nieuwe Claude Code sessie

**Automatische scripts** (draaien op achtergrond):
- `git-auto-pull-all.sh` - Automatisch pull
- `memonic-monthly-extract.sh` - Maandelijkse extract

**Verschil commit-push-all vs sync-all-repos:**
- `commit-push-all.sh`: Commit EERST uncommitted changes, dan push alles
- `sync-all-repos.sh`: Skipt repos met uncommitted changes, sync alleen clean repos

---

## 🔧 Onderhoud

**Scripts toevoegen:**
1. Maak script in deze folder
2. `chmod +x script-naam.sh`
3. Update deze README
4. Commit naar scripts repo

**Naamgeving:**
- Gebruik kebab-case: `my-script.sh`
- Beschrijvende namen: `commit-push-all` is duidelijker dan `cpall`
- Voeg `.sh` extensie toe voor shell scripts

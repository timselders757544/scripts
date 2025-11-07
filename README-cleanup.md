# Folder Cleanup Scripts

Scripts om de Development folder reorganisatie af te ronden.

## 📦 Scripts

### 1. `finish-folder-cleanup.sh` - **Start hier!**
Master script dat alles in de juiste volgorde uitvoert.

**Gebruik:**
```bash
bash ~/scripts/finish-folder-cleanup.sh
```

**Wat doet het:**
1. Cleanup DevSSD folders (hernoemen + verwijderen)
2. Commit & push .gitignore update
3. Verificatie eindresultaat

---

### 2. `cleanup-devssd.sh`
DevSSD cleanup op Mac Mini (individueel script).

**Gebruik:**
```bash
bash ~/scripts/cleanup-devssd.sh
```

**Acties:**
- Hernoem `Templates` → `templates`
- Verwijder `Claude` folder
- Verwijder `Issues` folder
- Verwijder `Microdosing` folder
- Pull development-meta updates

---

### 3. `commit-gitignore.sh`
Commit en push .gitignore wijzigingen (individueel script).

**Gebruik:**
```bash
bash ~/scripts/commit-gitignore.sh
```

**Acties:**
- Commit .gitignore updates
- Push naar development-meta repo

---

## ✅ Wat Is Al Gedaan

- ✅ `claude-code-cloud` gecloned naar DevSSD
- ✅ `mcp-servers-macmini` verplaatst naar Mac Mini
- ✅ `mcp-servers-macbook` blijft op MacBook
- ✅ `.claude/` en `Templates/` toegevoegd aan .gitignore

## ⏳ Wat Nog Moet

- ⏳ Templates hernoemen op DevSSD
- ⏳ Oude folders verwijderen (Claude, Issues, Microdosing)
- ⏳ .gitignore committen & pushen
- ⏳ Development meta pullen op Mac Mini

## 🚀 Quick Start

Eén commando voor alles:

```bash
bash ~/scripts/finish-folder-cleanup.sh
```

Dat is het! 🎉

# 🧹 Cleanup Zombie Development Servers

**✅ HUIDIGE STRATEGIE voor Next.js Development Server Management**

**Vervangt:** PM2 (zie [`PM2-README.md`](./PM2-README.md) - deprecated)
**Status:** Actief in gebruik sinds 14 november 2024

---

## Wat doet dit?

Dit script detecteert en verwijdert "zombie" Next.js development servers - processen die blijven draaien met hoog CPU/geheugengebruik na een crash of verkeerde afsluiting.

## Wanneer gebruiken?

Gebruik dit script wanneer je:
- Mac Mini traag vindt draaien
- Merkt dat CPU gebruik hoog is zonder reden
- Meerdere Next.js servers ziet draaien (check met Activity Monitor)
- Development servers wilt opruimen na development sessie

## Gebruik

```bash
/Volumes/DevSSD/Development/scripts/cleanup-zombie-servers.sh
```

Het script:
1. 🔍 Scant naar Next.js processen met hoog CPU gebruik (>10%)
2. 📋 Toont lijst van gevonden zombie processen
3. ❓ Vraagt om bevestiging voordat het killed
4. 🔪 Killed de zombie processen (kill -9)
5. ✅ Toont overzicht van overgebleven servers

## Veiligheid

- Healthy servers (CPU < 10%) worden **NIET** geraakt
- Je moet **bevestigen** voordat processen worden gekilled
- Toont altijd welke processen het wil killen

## Waarom geen PM2?

PM2 werkt **slecht** met Next.js development omdat:
- Next.js draait intern meerdere processen
- Hot reload conflicteert met PM2 restart logic
- Build errors veroorzaken crash loops (zoals de 431 restarts die we zagen)

**Betere aanpak:**
- Development servers handmatig draaien in tmux
- Periodiek cleanup script draaien om zombies op te ruimen
- PM2 alleen voor production-achtige services (dashboards, static servers)

## Automatisch uitvoeren (optioneel)

Om dit script dagelijks automatisch te laten draaien:

```bash
# Add to crontab (runs daily at 8 AM)
0 8 * * * /Volumes/DevSSD/Development/scripts/cleanup-zombie-servers.sh
```

**Waarschuwing:** Dit zal automatisch zonder bevestiging killen. Alleen doen als je weet wat je doet.

## Handmatige check

Om zelf te checken welke servers draaien:

```bash
# Toon alle Node processen met poorten
lsof -i -P | grep LISTEN | grep node

# Toon Next.js servers met CPU/memory
ps aux | grep next-server | grep -v grep
```

## History

- **Nov 14, 2024:** Script gemaakt na 431 PM2 restarts door JSX syntax error
- **Probleem:** PM2 had oude, kapotte versie gecached → crash loop
- **Oplossing:** PM2 verwijderd, handmatig draaien in tmux + cleanup script

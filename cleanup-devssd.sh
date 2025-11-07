#!/bin/bash
# DevSSD Cleanup Script
# Voltooien van folder reorganisatie op Mac Mini DevSSD

echo "🧹 DevSSD Cleanup Script"
echo "========================"
echo ""

# Check Mac Mini connectivity
if ! ping -c 1 100.82.46.123 &>/dev/null; then
  echo "❌ Mac Mini (100.82.46.123) is niet bereikbaar"
  echo "   Zorg dat Mac Mini online is en probeer opnieuw"
  exit 1
fi

echo "✅ Mac Mini bereikbaar"
echo ""

# Run cleanup commands on Mac Mini
echo "📝 Uitvoeren cleanup op DevSSD..."
ssh macmini 'cd /Volumes/DevSSD/Development && \
  echo "1️⃣ Hernoemen Templates → templates..." && \
  mv Templates templates 2>/dev/null && echo "   ✅ Templates hernoemt" || echo "   ⚠️  Templates al lowercase of niet gevonden" && \
  echo "" && \
  echo "2️⃣ Verwijderen Claude folder..." && \
  rm -rf Claude && echo "   ✅ Claude verwijderd" && \
  echo "" && \
  echo "3️⃣ Verwijderen Issues folder..." && \
  rm -rf Issues && echo "   ✅ Issues verwijderd" && \
  echo "" && \
  echo "4️⃣ Verwijderen Microdosing folder..." && \
  rm -rf Microdosing && echo "   ✅ Microdosing verwijderd" && \
  echo "" && \
  echo "5️⃣ Pull development-meta updates..." && \
  git pull && echo "   ✅ Development meta gepulled" && \
  echo "" && \
  echo "✨ DevSSD cleanup voltooid!"'

if [ $? -eq 0 ]; then
  echo ""
  echo "========================"
  echo "✅ Alle DevSSD cleanup acties voltooid!"
  echo ""
  echo "Volgende stap: commit en push .gitignore update op MacBook"
  echo "Run: cd ~/Development && git add .gitignore && git commit -m 'Update .gitignore' && git push"
else
  echo ""
  echo "❌ Er ging iets mis tijdens cleanup"
  echo "   Check de output hierboven voor details"
  exit 1
fi

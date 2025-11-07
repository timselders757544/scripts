#!/bin/bash
# Master script - voltooi alle folder cleanup stappen in de juiste volgorde

echo "🎯 Folder Cleanup - Complete Workflow"
echo "====================================="
echo ""
echo "Dit script voltooit alle resterende cleanup stappen:"
echo "  1. DevSSD cleanup (Templates hernoemen, folders verwijderen)"
echo "  2. Commit & push .gitignore update"
echo "  3. Pull updates op Mac Mini"
echo ""

read -p "Doorgaan? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Afgebroken."
  exit 0
fi

echo ""
echo "=========================================="
echo "STAP 1: DevSSD Cleanup"
echo "=========================================="
bash ~/scripts/cleanup-devssd.sh

if [ $? -ne 0 ]; then
  echo ""
  echo "❌ DevSSD cleanup mislukt - stop hier"
  exit 1
fi

echo ""
echo "=========================================="
echo "STAP 2: Commit .gitignore Update"
echo "=========================================="
bash ~/scripts/commit-gitignore.sh

if [ $? -ne 0 ]; then
  echo ""
  echo "❌ .gitignore commit mislukt - stop hier"
  exit 1
fi

echo ""
echo "=========================================="
echo "STAP 3: Verify Final State"
echo "=========================================="
echo ""
echo "📊 MacBook Development folders:"
ls -1 ~/Development/ | grep -v "^\." | head -15

echo ""
echo "📊 DevSSD Development folders:"
ssh macmini 'ls -1 /Volumes/DevSSD/Development/ | grep -v "^\." | head -15'

echo ""
echo "=========================================="
echo "✨ ALLES VOLTOOID!"
echo "=========================================="
echo ""
echo "Samenvatting:"
echo "  ✅ claude-code-cloud op DevSSD"
echo "  ✅ mcp-servers-macmini verplaatst naar Mac Mini"
echo "  ✅ Templates hernoemt naar lowercase"
echo "  ✅ Oude folders verwijderd (Claude, Issues, Microdosing)"
echo "  ✅ .gitignore bijgewerkt en gesynchroniseerd"
echo ""
echo "Je Development folders zijn nu netjes georganiseerd! 🎉"

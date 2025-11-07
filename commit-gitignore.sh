#!/bin/bash
# Commit and push .gitignore update to development-meta repo

echo "📝 Committing .gitignore update..."
echo ""

cd ~/Development

# Check if there are changes
if git diff --quiet .gitignore; then
  echo "ℹ️  No changes to .gitignore"
  exit 0
fi

# Show what will be committed
echo "Changes to commit:"
git diff .gitignore
echo ""

# Commit and push
git add .gitignore
git commit -m "Update .gitignore: add .claude/ and Templates/

- Add .claude/ to ignore (local cache folder)
- Add Templates/ to handle case-sensitive variants
- Ensures clean meta repo regardless of folder naming

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"

if [ $? -eq 0 ]; then
  echo ""
  echo "✅ Committed to local git"
  echo "📤 Pushing to GitHub..."

  git push

  if [ $? -eq 0 ]; then
    echo ""
    echo "========================"
    echo "✅ .gitignore update gepushed naar GitHub!"
    echo ""
    echo "Volgende stap: Mac Mini pull laten draaien"
    echo "Run: ssh macmini 'cd /Volumes/DevSSD/Development && git pull'"
  else
    echo ""
    echo "❌ Push failed - check je netwerk/GitHub connectie"
    exit 1
  fi
else
  echo ""
  echo "❌ Commit failed"
  exit 1
fi

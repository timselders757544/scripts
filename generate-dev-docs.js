#!/usr/bin/env node

/**
 * Development Documentation Generator
 *
 * Collects all README files from Development folder,
 * generates AI summary via Anthropic API,
 * publishes to HTML page accessible via MacMini Apps
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');
const https = require('https');

// Configuration
const DEV_DIR = '/Volumes/DevSSD/Development';
const OUTPUT_HTML = path.join(DEV_DIR, 'claude-code-cloud/macmini-apps/dev-docs.html');
const SECRETS_ENV = path.join(DEV_DIR, 'secrets/.master.env');

// Colors for console output
const colors = {
  blue: '\x1b[34m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  reset: '\x1b[0m'
};

console.log(`${colors.blue}📚 Development Documentation Generator${colors.reset}\n`);

// Main async function
(async function main() {

// ============================================
// STEP 1: Collect all README files
// ============================================
console.log(`${colors.blue}Step 1/5: Collecting README files...${colors.reset}`);

function findReadmeFiles(dir, fileList = []) {
  const files = fs.readdirSync(dir);

  files.forEach(file => {
    const filePath = path.join(dir, file);
    const stat = fs.statSync(filePath);

    // Skip node_modules, .git, .vercel
    if (file === 'node_modules' || file === '.git' || file === '.vercel') {
      return;
    }

    if (stat.isDirectory()) {
      findReadmeFiles(filePath, fileList);
    } else if (file.match(/^README.*\.(md|txt)$/i)) {
      fileList.push(filePath);
    }
  });

  return fileList;
}

const readmeFiles = findReadmeFiles(DEV_DIR);
console.log(`${colors.green}✓ Found ${readmeFiles.length} README files${colors.reset}\n`);

// ============================================
// STEP 2: Merge all README content
// ============================================
console.log(`${colors.blue}Step 2/5: Merging README content...${colors.reset}`);

const readmeData = readmeFiles.map(filePath => {
  const relativePath = path.relative(DEV_DIR, filePath);
  const dirName = path.dirname(relativePath);
  const projectName = dirName === '.' ? 'Development Root' : dirName;
  const content = fs.readFileSync(filePath, 'utf-8');

  return {
    path: relativePath,
    projectName,
    content,
    fullPath: filePath
  };
});

// Create merged content for AI
const mergedContent = readmeData.map(readme => `
---
## ${readme.projectName}
**File:** \`${readme.path}\`

${readme.content}
`).join('\n');

console.log(`${colors.green}✓ Merged ${readmeData.length} files (${mergedContent.length} chars)${colors.reset}\n`);

// ============================================
// STEP 3: Generate AI Summary via Anthropic API
// ============================================
console.log(`${colors.blue}Step 3/5: Generating AI summary...${colors.reset}`);

// Load API key from secrets
let ANTHROPIC_API_KEY = null;
if (fs.existsSync(SECRETS_ENV)) {
  const envContent = fs.readFileSync(SECRETS_ENV, 'utf-8');
  const match = envContent.match(/ANTHROPIC_API_KEY=(.+)/);
  if (match) {
    ANTHROPIC_API_KEY = match[1].trim();
  }
}

async function generateAISummary() {
  if (!ANTHROPIC_API_KEY) {
    console.log(`${colors.yellow}⚠️  No API key found, skipping AI summary${colors.reset}`);
    return 'AI samenvatting niet beschikbaar (geen API key)';
  }

  const prompt = `Analyseer deze Development folder documentatie en maak een begrijpelijke Nederlandse samenvatting:

1. **Overzicht** (2-3 zinnen): Wat is deze Development folder?
2. **Belangrijkste Projecten**: Korte lijst met wat elk doet (gewone taal, geen jargon)
3. **Hoe Projecten Samenhangen**: Welke delen werken samen?
4. **Handigste Scripts**: Top 5 scripts die je het meest gebruikt
5. **Quick Start**: Als je X wilt, gebruik Y

Schrijf voor iemand die over 6 maanden terugkomt en snel overzicht wil.
Gewone mensentaal, zakelijk maar toegankelijk Nederlands.
Gebruik Markdown formatting (headers, lists, bold).

---

${mergedContent}`;

  const requestBody = JSON.stringify({
    model: 'claude-sonnet-4-20250514',
    max_tokens: 2000,
    messages: [
      {
        role: 'user',
        content: prompt
      }
    ]
  });

  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'api.anthropic.com',
      path: '/v1/messages',
      method: 'POST',
      headers: {
        'x-api-key': ANTHROPIC_API_KEY,
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json',
        'Content-Length': Buffer.byteLength(requestBody)
      }
    };

    const req = https.request(options, (res) => {
      let data = '';

      res.on('data', (chunk) => {
        data += chunk;
      });

      res.on('end', () => {
        try {
          const response = JSON.parse(data);
          if (response.content && response.content[0]) {
            resolve(response.content[0].text);
          } else {
            reject(new Error('Invalid API response'));
          }
        } catch (error) {
          reject(error);
        }
      });
    });

    req.on('error', (error) => {
      reject(error);
    });

    req.write(requestBody);
    req.end();
  });
}

let aiSummary = '';
try {
  aiSummary = await generateAISummary();
  console.log(`${colors.green}✓ AI summary generated${colors.reset}\n`);
} catch (error) {
  console.log(`${colors.yellow}⚠️  Error generating AI summary: ${error.message}${colors.reset}\n`);
  aiSummary = 'AI samenvatting tijdelijk niet beschikbaar';
}

// ============================================
// STEP 4: Convert Markdown to HTML
// ============================================
console.log(`${colors.blue}Step 4/5: Converting markdown to HTML...${colors.reset}`);

// Simple markdown to HTML converter
function markdownToHtml(md) {
  let html = md;

  // Code blocks (```language ... ```)
  html = html.replace(/```(\w+)?\n([\s\S]*?)```/g, '<pre><code>$2</code></pre>');

  // Headers
  html = html.replace(/^### (.+)$/gm, '<h3>$1</h3>');
  html = html.replace(/^## (.+)$/gm, '<h2>$1</h2>');
  html = html.replace(/^# (.+)$/gm, '<h1>$1</h1>');

  // Bold
  html = html.replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>');

  // Inline code
  html = html.replace(/`([^`]+)`/g, '<code>$1</code>');

  // Lists
  html = html.replace(/^- (.+)$/gm, '<li>$1</li>');
  html = html.replace(/(<li>.*<\/li>\n?)+/g, '<ul>$&</ul>');

  // Numbered lists
  html = html.replace(/^\d+\. (.+)$/gm, '<li>$1</li>');

  // Paragraphs (wrap non-tag lines)
  html = html.split('\n').map(line => {
    if (line.trim() === '') return '';
    if (line.match(/^<(h[123]|ul|ol|li|pre|code)/)) return line;
    if (line.match(/<\/(h[123]|ul|ol|li|pre|code)>$/)) return line;
    return `<p>${line}</p>`;
  }).join('\n');

  return html;
}

const aiSummaryHtml = markdownToHtml(aiSummary);

console.log(`${colors.green}✓ Markdown converted to HTML${colors.reset}\n`);

// ============================================
// STEP 5: Generate HTML Page
// ============================================
console.log(`${colors.blue}Step 5/5: Generating HTML page...${colors.reset}`);

const timestamp = new Date().toLocaleString('nl-NL', {
  year: 'numeric',
  month: '2-digit',
  day: '2-digit',
  hour: '2-digit',
  minute: '2-digit',
  second: '2-digit'
});

// Generate README cards HTML
const readmeCardsHtml = readmeData.map((readme, index) => `
<div class="readme-card" id="card-${index}" onclick="toggleReadme('card-${index}')">
    <div class="readme-card-header">
        <div>
            <div class="readme-card-title">📄 ${escapeHtml(readme.projectName)}</div>
            <div class="readme-card-path">${escapeHtml(readme.path)}</div>
        </div>
        <div class="readme-card-toggle">▶</div>
    </div>
    <div class="readme-content">
        <pre>${escapeHtml(readme.content)}</pre>
    </div>
</div>`).join('\n');

function escapeHtml(text) {
  return text
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

const htmlContent = `<!DOCTYPE html>
<html lang="nl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>📚 Development Docs</title>
    <link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>📚</text></svg>">

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Barlow:wght@300;600;700&display=swap" rel="stylesheet">

    <!-- Design System -->
    <link rel="stylesheet" href="../design-system/tokens.css">

    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'Barlow', -apple-system, BlinkMacSystemFont, sans-serif;
            background: #FFFFFF;
            min-height: 100vh;
            padding: 40px 0;
        }

        .container { position: relative; }

        .section-title {
            font-size: 14px;
            font-weight: 300;
            color: #000000;
            letter-spacing: -0.28px;
            margin-bottom: 14px;
            text-align: left;
        }

        /* Hero Summary Card - CCC Dashboard Style */
        .summary-hero {
            display: flex;
            flex-direction: column;
            min-height: 86px;
            background: #E8F4FD;
            border-radius: 7px;
            padding: 24px;
            margin-bottom: 26px;
        }

        .summary-hero-title {
            font-size: 24px;
            font-weight: 600;
            color: #000000;
            letter-spacing: -0.48px;
            line-height: 1.4;
            margin-bottom: 16px;
        }

        .summary-content {
            font-size: 14px;
            font-weight: 400;
            color: #000000;
            letter-spacing: -0.28px;
            line-height: 1.6;
        }

        .summary-content h2 {
            font-size: 16px;
            font-weight: 700;
            margin-top: 16px;
            margin-bottom: 8px;
        }

        .summary-content h3 {
            font-size: 14px;
            font-weight: 600;
            margin-top: 12px;
            margin-bottom: 6px;
        }

        .summary-content ul {
            margin-left: 20px;
            margin-bottom: 12px;
        }

        .summary-content li {
            margin-bottom: 4px;
        }

        .summary-content strong {
            font-weight: 600;
        }

        .summary-content code {
            background: #F4F4F4;
            padding: 2px 6px;
            border-radius: 3px;
            font-size: 13px;
            font-family: 'SF Mono', Monaco, 'Courier New', monospace;
        }

        .summary-content p {
            margin-bottom: 12px;
        }

        /* README Cards */
        .readme-list {
            display: flex;
            flex-direction: column;
            gap: 15px;
            margin-bottom: 26px;
        }

        .readme-card {
            background: #F4F4F4;
            border-radius: 7px;
            padding: 20px 24px;
            cursor: pointer;
            transition: all 0.2s ease;
        }

        .readme-card:hover {
            background: #EBEBEB;
        }

        .readme-card-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .readme-card-title {
            font-size: 14px;
            font-weight: 700;
            color: #000000;
            letter-spacing: -0.28px;
            line-height: 1.4;
        }

        .readme-card-path {
            font-size: 12px;
            font-weight: 300;
            color: #666666;
            letter-spacing: -0.24px;
            margin-top: 4px;
        }

        .readme-card-toggle {
            font-size: 18px;
            color: #000000;
            transition: transform 0.2s ease;
        }

        .readme-card.expanded .readme-card-toggle {
            transform: rotate(90deg);
        }

        .readme-content {
            max-height: 0;
            overflow: hidden;
            transition: max-height 0.3s ease;
            margin-top: 0;
        }

        .readme-card.expanded .readme-content {
            max-height: 50000px;
            margin-top: 16px;
        }

        .readme-content pre {
            background: #FFFFFF;
            border-radius: 4px;
            padding: 12px;
            overflow-x: auto;
            font-size: 13px;
            line-height: 1.5;
            margin: 0;
            white-space: pre-wrap;
            word-wrap: break-word;
        }

        /* Footer */
        .footer {
            text-align: center;
            margin-top: 40px;
            padding: 20px;
            background: #F4F4F4;
            border-radius: 7px;
        }

        .footer-text {
            font-size: 12px;
            color: #666666;
            margin-bottom: 12px;
        }

        .refresh-button {
            background: #000000;
            color: #FFFFFF;
            border: none;
            border-radius: 4px;
            padding: 10px 20px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s ease;
        }

        .refresh-button:hover {
            background: #333333;
            transform: translateY(-1px);
        }

        .refresh-button:disabled {
            opacity: 0.6;
            cursor: not-allowed;
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- Topbar -->
        <div class="topbar">
            <div class="topbar-title">
                <span class="topbar-title-main">📚 Development Docs</span>
            </div>
        </div>

        <!-- AI Summary Hero -->
        <div class="section-title">AI Samenvatting</div>
        <div class="summary-hero">
            <div class="summary-hero-title">🤖 Development Overzicht</div>
            <div class="summary-content">
                ${aiSummaryHtml}
            </div>
        </div>

        <!-- README Index -->
        <div class="section-title">Alle Documentatie (${readmeData.length} bestanden)</div>
        <div class="readme-list">
            ${readmeCardsHtml}
        </div>

        <!-- Footer -->
        <div class="footer">
            <div class="footer-text">Laatst gegenereerd: ${timestamp}</div>
            <button class="refresh-button" onclick="refreshDocs()">🔄 Vernieuw Documentatie</button>
        </div>
    </div>

    <script>
        // Toggle README card expansion
        function toggleReadme(cardId) {
            const card = document.getElementById(cardId);
            card.classList.toggle('expanded');
        }

        // Refresh documentation
        async function refreshDocs() {
            const btn = document.querySelector('.refresh-button');
            btn.textContent = '⏳ Bezig met vernieuwen...';
            btn.disabled = true;

            try {
                // Call the Node.js script
                const response = await fetch('/api/regenerate-docs', { method: 'POST' });

                if (response.ok) {
                    setTimeout(() => {
                        location.reload();
                    }, 1000);
                } else {
                    // Fallback: just reload for now
                    setTimeout(() => {
                        location.reload();
                    }, 2000);
                }
            } catch (error) {
                // Fallback: reload anyway
                setTimeout(() => {
                    location.reload();
                }, 2000);
            }
        }

        // Expand first card by default
        window.addEventListener('DOMContentLoaded', () => {
            const firstCard = document.querySelector('.readme-card');
            if (firstCard) {
                firstCard.classList.add('expanded');
            }
        });
    </script>
</body>
</html>`;

// Write HTML file
fs.writeFileSync(OUTPUT_HTML, htmlContent, 'utf-8');

console.log(`${colors.green}✓ HTML page generated: ${OUTPUT_HTML}${colors.reset}\n`);

console.log(`${colors.green}🎉 Documentation generation complete!${colors.reset}\n`);
console.log(`📍 View at: http://macmini:3000/dev-docs.html\n`);

})(); // End of async main function

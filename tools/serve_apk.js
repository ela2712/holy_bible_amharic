const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = 8080;
const APK_PATH = path.join(__dirname, '..', 'app-release.apk');
const AAB_PATH = path.join(__dirname, '..', 'build', 'app', 'outputs', 'bundle', 'release', 'app-release.aab');

const server = http.createServer((req, res) => {
  if (req.url === '/download' || req.url === '/app-release.apk') {
    if (fs.existsSync(APK_PATH)) {
      const stat = fs.statSync(APK_PATH);
      res.writeHead(200, {
        'Content-Type': 'application/vnd.android.package-archive',
        'Content-Disposition': 'attachment; filename="holy_bible_amharic.apk"',
        'Content-Length': stat.size,
      });
      fs.createReadStream(APK_PATH).pipe(res);
    } else {
      res.writeHead(404, { 'Content-Type': 'text/plain' });
      res.end('APK not found');
    }
  } else if (req.url === '/bundle' || req.url === '/app-release.aab') {
    if (fs.existsSync(AAB_PATH)) {
      const stat = fs.statSync(AAB_PATH);
      res.writeHead(200, {
        'Content-Type': 'application/octet-stream',
        'Content-Disposition': 'attachment; filename="holy_bible_amharic.aab"',
        'Content-Length': stat.size,
      });
      fs.createReadStream(AAB_PATH).pipe(res);
    } else {
      res.writeHead(404, { 'Content-Type': 'text/plain' });
      res.end('App Bundle not found');
    }
  } else {
    const apkStat = fs.existsSync(APK_PATH) ? fs.statSync(APK_PATH) : null;
    const apkSizeMb = apkStat ? (apkStat.size / (1024 * 1024)).toFixed(1) : '0';
    const aabStat = fs.existsSync(AAB_PATH) ? fs.statSync(AAB_PATH) : null;
    const aabSizeMb = aabStat ? (aabStat.size / (1024 * 1024)).toFixed(1) : '0';

    res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
    res.end(`
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>መጽሐፍ ቅዱስ 81 - Mobile Download</title>
        <style>
          body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; background: #0b0f17; color: #fff; text-align: center; padding: 36px 16px; margin: 0; }
          .card { background: #161e2e; max-width: 440px; margin: 0 auto; border-radius: 20px; padding: 32px 24px; box-shadow: 0 16px 40px rgba(0,0,0,0.6); border: 1px solid #283548; }
          h1 { color: #f59e0b; font-size: 26px; margin: 0 0 8px; font-weight: 800; }
          .sub { color: #cbd5e1; font-size: 14px; margin-bottom: 16px; }
          .badge { display: inline-block; background: #1e293b; color: #38bdf8; padding: 4px 14px; border-radius: 20px; font-size: 13px; font-weight: bold; margin-bottom: 24px; border: 1px solid #334155; }
          a.btn-primary { display: block; background: #f59e0b; color: #0b0f17; text-decoration: none; font-weight: 800; font-size: 17px; padding: 16px; border-radius: 14px; transition: background 0.2s; box-shadow: 0 4px 14px rgba(245,158,11,0.35); margin-bottom: 12px; }
          a.btn-primary:hover { background: #d97706; }
          a.btn-secondary { display: block; background: #1e293b; color: #38bdf8; text-decoration: none; font-weight: 700; font-size: 14px; padding: 12px; border-radius: 12px; border: 1px solid #334155; transition: background 0.2s; }
          a.btn-secondary:hover { background: #283548; }
          .steps { text-align: left; margin-top: 28px; border-top: 1px solid #283548; padding-top: 20px; font-size: 13px; color: #cbd5e1; }
          .steps ol { padding-left: 20px; margin: 8px 0; }
          .steps li { margin-bottom: 8px; }
        </style>
      </head>
      <body>
        <div class="card">
          <h1>መጽሐፍ ቅዱስ 81 ቀኖና</h1>
          <div class="sub">Ethiopian Orthodox Tewahedo Bible • 2026 Edition</div>
          <div class="badge">Version 1.0.0 • APK ${apkSizeMb} MB • AAB ${aabSizeMb} MB</div>
          <a class="btn-primary" href="/download">⬇️ Download APK to Phone (${apkSizeMb} MB)</a>
          <a class="btn-secondary" href="/bundle">📦 Download App Bundle .aab (${aabSizeMb} MB)</a>
          <div class="steps">
            <strong>How to install on your phone:</strong>
            <ol>
              <li>Tap the <b>Download APK</b> button above.</li>
              <li>When the download finishes, tap the notification or open your phone's <b>Downloads</b> app.</li>
              <li>Tap <b>Install</b> (if prompted, allow <i>"Install unknown apps"</i> for your browser).</li>
              <li>Open <b>መጽሐፍ ቅዱስ</b> and enjoy the full 81 Canon, Ge'ez, and cross-references offline!</li>
            </ol>
          </div>
        </div>
      </body>
      </html>
    `);
  }
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`Mobile download server running on http://0.0.0.0:${PORT}`);
});


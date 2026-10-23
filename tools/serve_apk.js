const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = 8080;
const APK_PATH = path.join(__dirname, '..', 'app-release.apk');

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
  } else {
    const stat = fs.existsSync(APK_PATH) ? fs.statSync(APK_PATH) : null;
    const sizeMb = stat ? (stat.size / (1024 * 1024)).toFixed(1) : '0';
    res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
    res.end(`
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>መጽሐፍ ቅዱስ - APK Download</title>
        <style>
          body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; background: #0f141c; color: #fff; text-align: center; padding: 40px 20px; }
          .card { background: #1b2332; max-width: 440px; margin: 0 auto; border-radius: 16px; padding: 32px 24px; box-shadow: 0 10px 30px rgba(0,0,0,0.5); border: 1px solid #2d3b50; }
          h1 { color: #f59e0b; font-size: 26px; margin-bottom: 6px; }
          p { color: #94a3b8; font-size: 14px; line-height: 1.5; margin: 8px 0 24px; }
          .badge { display: inline-block; background: #2d3b50; color: #38bdf8; padding: 4px 12px; border-radius: 20px; font-size: 13px; font-weight: bold; margin-bottom: 20px; }
          a.btn { display: block; background: #f59e0b; color: #000; text-decoration: none; font-weight: bold; font-size: 18px; padding: 16px; border-radius: 12px; transition: background 0.2s; box-shadow: 0 4px 14px rgba(245,158,11,0.4); }
          a.btn:hover { background: #d97706; }
          .steps { text-align: left; margin-top: 28px; border-top: 1px solid #2d3b50; padding-top: 20px; font-size: 13px; color: #cbd5e1; }
          .steps ol { padding-left: 20px; margin: 8px 0; }
          .steps li { margin-bottom: 8px; }
        </style>
      </head>
      <body>
        <div class="card">
          <h1>መጽሐፍ ቅዱስ 81</h1>
          <div class="badge">Version 1.0.0 • Release APK (${sizeMb} MB)</div>
          <p>Official Android release build with complete Orthodox 81 Canon, Haile Selassie 1954, and KJV parallel canons.</p>
          <a class="btn" href="/download">⬇️ Download APK to Phone</a>
          <div class="steps">
            <strong>How to install on your Android phone:</strong>
            <ol>
              <li>Tap the <b>Download APK</b> button above.</li>
              <li>When the download finishes, tap the notification or open your phone's <b>Downloads</b> app.</li>
              <li>Tap <b>Install</b> (if prompted, enable <i>"Install unknown apps"</i> for your browser).</li>
              <li>Open <b>መጽሐፍ ቅዱስ</b> and enjoy the full native experience!</li>
            </ol>
          </div>
        </div>
      </body>
      </html>
    `);
  }
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`APK download server running on http://0.0.0.0:${PORT}`);
});

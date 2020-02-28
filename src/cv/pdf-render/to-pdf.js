const puppeteer = require('puppeteer-core');
const dns = require('dns').promises;

const url = process.argv[2];
const target = `/target/${process.argv[3]}`;

// require('fs').mkdirSync(target.replace(/[^/]+\.pdf$/, ''))

console.log(`printing ${url} to ${target}`)

;(async () => {
  try {
    const { address: hostname } = await dns.lookup('host.docker.internal')

    const browser = await puppeteer.connect({
      browserURL: `http://${hostname}:5555`
    });
    const page = await browser.newPage();
    await page.goto(url, {waitUntil: 'networkidle2'});
    await page.pdf({path: target, format: 'A4'});
   
    await browser.close();
  } catch (err) {
    console.error(err);
  }
})();
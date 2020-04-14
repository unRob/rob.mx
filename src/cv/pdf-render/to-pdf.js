const puppeteer = require('puppeteer-core');
const dns = require('dns').promises;
const { URL } = require('url');

const urls = process.argv.slice(2);

;(async () => {
  try {
    const { address: hostname } = await dns.lookup('host.docker.internal')
    
    const browser = await puppeteer.connect({
      browserURL: `http://${hostname}:5555`
    });
    
    for (url_index in urls) {
      const url = urls[url_index];
      const { pathname } = new URL(url)
      const target = `/target${pathname}.pdf`
      console.log(`printing ${url} to ${target}`)

      const page = await browser.newPage();
      await page.goto(url, {waitUntil: 'networkidle2'});
      await page.pdf({path: target, format: 'A4'});
      await page.close();
    }
  } catch (err) {
    console.error(err);
    browser.close();
  }
})();
'use strict';

try {
    require.resolve("puppeteer");
} catch(e) {
    console.error("puppeteer Node library is not installed; will not generate PDF");
    process.exit(e.code);
}

const puppeteer = require('puppeteer');

const createPdf = async() => {
  let browser;
  try {
    browser = await puppeteer.launch({args: ['--no-sandbox', '--disable-setuid-sandbox']});
    const page = await browser.newPage();
    await page.goto(process.argv[2], {waitUntil: 'networkidle2'});
    await page.pdf({
      path: process.argv[3],
      format: 'A4'
    });
  } catch (err) {
      console.log(err.message);
  } finally {
    if (browser) {
      browser.close();
    }
    process.exit();
  }
};
createPdf();

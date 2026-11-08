const assert = require('node:assert/strict');
const path = require('node:path');
const {pathToFileURL} = require('node:url');
const {chromium} = require(process.env.PLAYWRIGHT_MODULE || 'playwright');
(async()=>{
 const browser=await chromium.launch({executablePath:process.env.CHROME_PATH,headless:true});
 try{
  const page=await browser.newPage({viewport:{width:1280,height:850},reducedMotion:'reduce'});
  const errors=[];page.on('pageerror',e=>errors.push(e.message));
  await page.goto(pathToFileURL(path.join(__dirname,'..','Play Sharster Farts.html')).href);
  const action=()=>page.locator('.target');
  await page.locator('#scene').evaluate(img=>img.decode());
  await page.getByRole('button',{name:'Sound off'}).click();
  for(const text of ['Loose Change','Feed vending machine','Baja Mistake','Investigate cone']){
   assert.ok((await action().innerText()).includes(text)); await action().click();
  }
  await action().focus();await page.keyboard.down('Enter');await page.waitForTimeout(350);await page.keyboard.up('Enter');
  assert.match(await page.locator('#note').innerText(),/peek/);
  await action().focus();await page.keyboard.down('Enter');await page.waitForTimeout(2550);await page.keyboard.up('Enter');
  await page.getByRole('button',{name:'Net the Commuter'}).click();
  await page.reload();assert.match(await page.locator('#count').innerText(),/3 \/ 5/);
  await action().click();await action().click();
  await page.getByRole('button',{name:'Pull the plug'}).click();
  await page.getByRole('button',{name:'Whistling…'}).click();
  assert.match(await page.locator('#note').innerText(),/whistled your net away/);
  await page.getByRole('button',{name:'Net Adult Swim'}).click();
  assert.match(await page.locator('#count').innerText(),/5 \/ 5/);
  assert.equal(await page.locator('#objective').innerText(),'Shift complete.');
  await page.getByText('New shift',{exact:true}).click();await page.getByText('Keep playing',{exact:true}).click();assert.equal(await page.locator('li.found').count(),5);
  await page.getByText('New shift',{exact:true}).click();await page.getByText('Start over',{exact:true}).click();
  await page.waitForFunction(()=>document.querySelectorAll('li.found').length===0);
  await page.setViewportSize({width:390,height:760});
  assert.ok(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth));
  assert.deepEqual(errors,[]);
  const touchPage=await browser.newPage({hasTouch:true,isMobile:true,viewport:{width:390,height:760}});
  await touchPage.goto(page.url());
  for(let i=0;i<4;i++) {
    const target=await touchPage.locator('.target').boundingBox();
    await touchPage.touchscreen.tap(target.x+target.width/2,target.y+target.height/2);
  }
  const ctl=await touchPage.context().newCDPSession(touchPage);
  const box=await touchPage.locator('.target').boundingBox();
  await ctl.send('Input.dispatchTouchEvent',{type:'touchStart',touchPoints:[{x:box.x+box.width/2,y:box.y+box.height/2}]});
  await touchPage.getByRole('button',{name:'Net the Commuter'}).waitFor();
  await ctl.send('Input.dispatchTouchEvent',{type:'touchEnd',touchPoints:[]});
  console.log('PASS: catch-to-boss run, whistle timing, cancelled and completed stakeouts, save/reload, reset/cancel, sound, mobile fit and touch hold.');
 }finally{await browser.close()}
})().catch(e=>{console.error(e);process.exitCode=1});

const assert = require("node:assert/strict");
const path = require("node:path");
const {pathToFileURL}=require("node:url");
const {chromium}=require(process.env.PLAYWRIGHT_MODULE || "playwright");
const url=pathToFileURL(path.join(__dirname,"..","Play Sharster Farts.html")).href;

(async()=>{
 const browser=await chromium.launch({executablePath:process.env.CHROME_PATH,headless:true});
 try{
  const page=await browser.newPage({viewport:{width:1280,height:850}});
  const errors=[];page.on("pageerror",e=>errors.push(e.message));
  await page.goto(url);await page.waitForFunction(()=>W>100);
  if(process.env.ARENA_SCREENSHOT)await page.screenshot({path:process.env.ARENA_SCREENSHOT});
  await page.locator("#fire").click();
  assert.match(await page.locator("#callout").innerText(),/Out of gas/);
  await page.locator("#shop").click();
  assert.equal(await page.locator("#buyFood").isDisabled(),true);
  async function smash(kind,index){
    await page.waitForFunction(()=>!blast);
    await page.locator("#eat").click();
    const p=await page.evaluate(([kind,index])=>{
      const o=(kind==="rock"?rocks:bots)[index];
      const [x,y]=project(o.x,o.z,kind==="rock"?.7:1);
      const r=canvas.getBoundingClientRect();return {x:x+r.left,y:y+r.top};
    },[kind,index]);
    await page.mouse.click(p.x,p.y);
    await page.waitForFunction(([kind,index])=>(kind==="rock"?rocks:bots)[index].respawn>clock,[kind,index],{timeout:9000});
  }
  await smash("rock",0);assert.ok(await page.evaluate(()=>progress.money>=2));
  await smash("rock",1);await smash("rock",2);
  await page.locator("#buyFood").click();
  assert.match(await page.locator("#eat").innerText(),/eggs/);
  await smash("bot",1);await page.locator("#buyColon").click();
  assert.equal(await page.evaluate(()=>progress.colon),1);
  await page.reload();assert.equal(await page.evaluate(()=>progress.food+progress.colon),2);
  await page.keyboard.press("e");await page.keyboard.press("Space");
  await page.waitForFunction(()=>blast!==null);
  assert.ok(await page.evaluate(()=>blast.end-blast.from>1.4&&blast.power===2));
  await page.waitForFunction(()=>!blast);
  const before=await page.evaluate(()=>hero.x);
  await page.keyboard.down("d");await page.waitForTimeout(320);await page.keyboard.up("d");
  assert.ok(await page.evaluate(()=>hero.x)>before);
  const mobile=await browser.newPage({viewport:{width:390,height:760},hasTouch:true,isMobile:true});
  await mobile.goto(url);await mobile.locator("#eat").tap();await mobile.locator("#fire").tap();
  await mobile.waitForFunction(()=>progress.money>=2);
  assert.ok(await mobile.evaluate(()=>document.documentElement.scrollWidth<=innerWidth));
  assert.deepEqual(errors,[]);
  console.log("PASS: aim, food, gas consumption, crystal breaks, NPC knockout, currency purchases, longer blasts, reload, keyboard movement, touch play.");
 }finally{await browser.close()}
})().catch(e=>{console.error(e);process.exitCode=1});

const $ = id => document.getElementById(id);
const slots = [
  [1, "Loose Change", "Jingles when startled."],
  [3, "Baja Mistake", "Technically a beverage."],
  [6, "The Commuter", "Employee of the month."],
  [8, "Drain Wayne", "Civil servant. Drain."],
  [10, "Adult Swim", "Whistle included."],
];
const steps = [
  ["lot","Catch the jingling fart.","Click Loose Change as it drifts past your net."],
  ["lot","Make a vending purchase.","Your new fart sounds exactly like exact change."],
  ["lot","Catch what the machine dispensed.","That blue thing certainly isn't a soda."],
  ["lot","Follow the skrrt.","Someone left a traffic cone in the employee lot."],
  ["watch","Give him some privacy.","Take off your shoes. Hold Look away until you hear three skrrts."],
  ["commuter","Net the commuter.","Quick. He's about to clock in."],
  ["lot","Clock in at Stall 6.","The Commuter has a staff key. The pool door needs a shot of Baja."],
  ["pool","Let the drain come to you.","Set your net on the tile. Give Wayne a second to investigate."],
  ["pool","Pull the plug.","Equip Drain Wayne and empty the deeper end."],
  ["ledge","Catch the real lifeguard.","Watch the whistle. Swing while he's taking a breath."],
  ["ledge","Shift complete.","Adult Swim blew the whistle all the way into your binder."],
];
const actions = [
  ["Loose Change",35,58,"wisp"],["Feed vending machine",16,68],["Baja Mistake",27,52,"wisp blue"],
  ["Investigate cone",69,72],["Hold · Look away",50,84],["Net the Commuter",59,73],
  ["Unlock Stall 6",80,62],["Set down net",32,81],["Pull the plug",39,73],["Net Adult Swim",49,26],
];
const storageKey = "sharster.shift.v1";
let phase = 0;
try {
  const saved = Number(localStorage.getItem(storageKey));
  if (Number.isInteger(saved) && saved >= 0 && saved < steps.length) phase = saved;
} catch {}
let timers = [], holding = false, audioContext, sound = false;
let feedbackTimer;
function noise(freq, end, length=.15, type="triangle") {
  if (!sound || !audioContext) return;
  const osc = audioContext.createOscillator(), gain = audioContext.createGain();
  const now = audioContext.currentTime;
  osc.type = type;
  osc.frequency.setValueAtTime(freq,now); osc.frequency.exponentialRampToValueAtTime(end,now+length);
  gain.gain.setValueAtTime(.08,now); gain.gain.exponentialRampToValueAtTime(.001,now+length);
  osc.connect(gain); gain.connect(audioContext.destination); osc.start(); osc.stop(now+length);
}
function flash(words) {
  clearTimeout(feedbackTimer); $("fx").textContent = words;
  feedbackTimer = setTimeout(() => $("fx").textContent = "",1100);
}
function clearTimers(){timers.forEach(clearTimeout); timers=[];holding=false}
function advance(msg) {
  clearTimers(); phase++; try {localStorage.setItem(storageKey,phase)} catch {}
  render(); if(msg) flash(msg);
  noise(180,510);
}
function render() {
  const [scene,objective,note] = steps[phase];
  $("scene").src=SCENES[scene]; $("scene").alt=scene==="lot"?"The closed gas station at dusk":scene==="watch"||scene==="commuter"?"The employee parking bay":"The pool beneath the pool";
  $("stage").classList.toggle("closeup",scene==="watch"||scene==="commuter");
  $("location").textContent=phase<4||phase===6?"Parking Lot 1":phase<6?"Employee parking":"The pool beneath the pool";
  $("folio").textContent=phase<7?"Gas station":"Realm 01";
  $("objective").textContent=objective; $("note").textContent=note;
  const found=slots.filter(([at])=>phase>=at).length;
  $("count").textContent=found+" / 5 collected"; $("entries").replaceChildren();
  slots.forEach(([at,name,flavor],i)=>{
    const item=document.createElement("li"), serial=document.createElement("small"), title=document.createElement("b");
    serial.textContent="SPECIMEN 0"+(i+1);title.textContent=phase>=at?name:"???";
    if(phase>=at){item.className="found"; item.title=flavor}
    item.append(serial,title);$("entries").append(item);
  });
  $("actions").replaceChildren();
  if(phase===10)return;
  const [label,x,y,kind] = actions[phase], btn=document.createElement("button");
  btn.className="target "+(kind||"");btn.textContent=label;btn.style.left=x+"%";btn.style.top=y+"%";$("actions").append(btn);
  if(phase===4){ setupStakeout(btn);return }
  if(phase===9){ setupLifeguard(btn);return }
  btn.onclick=()=>{
    if(phase===7){
      btn.disabled=true;btn.textContent="Stay still…";$("note").textContent="A drain with legs is considering your offer.";
      timers.push(setTimeout(()=>advance("WAYNE ACQUIRED"),1700));return;
    }
    const sounds=["JINGLE!","ka-chunk!","BAJA MISTAKE","he’s due.","","bip","EMPLOYEES ONLY","","glug…","TWEEET!"];
    advance(sounds[phase]);
  };
}
function setupLifeguard(btn){
  let resting=false;
  function cycle(){
    btn.textContent="Whistling…";btn.style.background="#ffb291";resting=false;
    noise(1050,1250,.2,"sine");
    timers.push(setTimeout(()=>{
      resting=true;btn.textContent="Net Adult Swim";btn.style.background="";
    },1250));
    timers.push(setTimeout(cycle,2850));
  }
  cycle();
  btn.onclick=()=>{
    if(resting){advance("TWEEET!");return}
    flash("FOUL.");$("note").textContent="He whistled your net away. Wait for him to inhale.";noise(1220,790,.22);
  };
}
function setupStakeout(btn){
  function start(){
    if(holding)return;holding=true;$("scene").src=SCENES.away;btn.textContent="Keep looking away…";
    [1,2,3].forEach(n=>timers.push(setTimeout(()=>{
      noise(100,40,.23,"sawtooth");flash("skrrt");$("note").textContent=n+" / 3 parking spaces";
    },n*650)));
    timers.push(setTimeout(()=>advance("bip"),2350));
  }
  function stop(){
    if(!holding)return;clearTimers();render();$("note").textContent="He saw you peek. Three spaces, one uninterrupted look away.";
  }
  btn.onpointerdown=e=>{e.preventDefault();btn.setPointerCapture(e.pointerId);start()};
  btn.onpointerup=btn.onpointercancel=btn.onlostpointercapture=stop;
  btn.onkeydown=e=>{if([" ","Enter"].includes(e.key)){e.preventDefault();start()}};
  btn.onkeyup=e=>{if([" ","Enter"].includes(e.key)){e.preventDefault();stop()}};
  btn.onblur=stop;
}
$("sound").onclick=()=>{
  if(!audioContext){const Audio=window.AudioContext||window.webkitAudioContext;if(!Audio)return;audioContext=new Audio()}
  sound=!sound;audioContext.resume().catch(()=>{});$("sound").textContent="Sound "+(sound?"on":"off");
  $("sound").setAttribute("aria-pressed",String(sound));noise(290,390);
};
$("restart").onclick=()=>$("confirm").showModal();
$("confirm").onclose=()=>{
  if($("confirm").returnValue!=="reset")return;
  clearTimers();phase=0;try{localStorage.removeItem(storageKey)}catch{}flash("");render();
};
render();

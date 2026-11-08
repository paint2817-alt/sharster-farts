"""Validate the packaged arena, shared economy, rigs and embedded scripts."""
from pathlib import Path
import json
import xml.etree.ElementTree as ET

root=Path(__file__).resolve().parents[1]
place=ET.parse(root/"Sharster Farts.rbxlx").getroot()
def child(parent,name):
    return next(obj for obj in parent.findall("Item") if obj.findtext("Properties/string[@name='Name']")==name)

world=child(place,"Workspace")
assert child(world,"CanteenSpawn").get("class")=="SpawnLocation"
assert len(child(world,"Shatters").findall("Item"))==16
arena=child(world,"Shatterberg Baseplate")
assert child(arena,"Studded baseplate").findtext("Properties/token[@name='TopSurface']")=="3"
bots=child(world,"Rivals").findall("Item")
assert len(bots)==3
for bot in bots:
    assert bot.findtext("Properties/Ref[@name='PrimaryPart']")==child(bot,"Torso").get("referent")
    assert child(bot,"Head").get("class")=="Part"
storage=child(place,"ReplicatedStorage")
assert child(storage,"ArenaAction").get("class")=="RemoteEvent"
rules=json.loads(child(storage,"ArenaRules").findtext("Properties/string[@name='Value']"))
assert rules==json.loads((root/"rules.json").read_text())
scripts=[(child(child(place,"ServerScriptService"),"Arena"),"Arena.server.lua"),
         (child(child(child(place,"StarterPlayer"),"StarterPlayerScripts"),"ArenaHUD"),"Arena.client.lua")]
for obj,filename in scripts:
    assert obj.findtext("Properties/ProtectedString[@name='Source']")==(root/"src"/filename).read_text(encoding="utf8")
ids=[i.get("referent") for i in place.iter("Item")]
assert len(ids)==len(set(ids))
print("PASS: baseplate, entrance, sixteen Shatters, three NPC rigs, shared economy, remote and both embedded Luau scripts.")

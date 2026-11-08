"""Check serialized structure, references, anchors and embedded Luau source."""
from pathlib import Path
import xml.etree.ElementTree as ET

root = Path(__file__).resolve().parents[1]
place = ET.parse(root / "Sharster Farts.rbxlx").getroot()
def child(parent, name):
    return next(obj for obj in parent.findall("Item") if obj.findtext("Properties/string[@name='Name']") == name)

workspace = child(place, "Workspace")
encounters = child(workspace, "Encounters")
for marker in ("Change","Vending","Baja","ShoeRack","Cone","Commuter","Stall","Wayne","Valve","Lifeguard","PoolEntry"):
    anchor = child(encounters, marker)
    assert anchor.findtext("Properties/bool[@name='Anchored']") == "true"
    assert anchor.find("Properties/CoordinateFrame[@name='CFrame']") is not None
assert child(workspace, "LotSpawn").get("class") == "SpawnLocation"
assert child(workspace, "PoolWater").get("class") == "Part"
assert len(child(workspace, "Reflection").findall("Item")) >= 1
assert child(child(place,"ReplicatedStorage"),"ShiftAction").get("class") == "RemoteEvent"
scripts = [(child(child(place,"ServerScriptService"),"Shift"),"Shift.server.lua","Script"),
           (child(child(child(place,"StarterPlayer"),"StarterPlayerScripts"),"Binder"),"Binder.client.lua","LocalScript")]
for obj, source, kind in scripts:
    assert obj.get("class") == kind
    assert obj.findtext("Properties/ProtectedString[@name='Source']") == (root/"src"/source).read_text(encoding="utf8")
all_ids = [obj.get("referent") for obj in place.iter("Item")]
assert len(all_ids) == len(set(all_ids))
print(f"PASS: {len(all_ids)} unique instances, eleven encounter anchors, spawn, pool, remote, and both matching embedded scripts.")

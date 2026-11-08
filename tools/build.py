"""Build the Studio place and self-contained browser game with Python 3."""
import base64
import json
import math
from pathlib import Path
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
document = ET.Element("roblox", version="4")
for token in ("null", "nil"):
    ET.SubElement(document, "External").text = token
serial = 0

def property_of(item, kind, name, value):
    node = ET.SubElement(item.find("Properties"), kind, name=name)
    if isinstance(value, dict):
        for key, component in value.items():
            ET.SubElement(node, key).text = str(component)
    else:
        node.text = str(value)
    return node

def item(parent, kind, name):
    global serial
    serial += 1
    obj = ET.SubElement(parent, "Item", {"class": kind, "referent": f"RBX{serial}"})
    ET.SubElement(obj, "Properties")
    property_of(obj, "string", "Name", name)
    return obj

def xyz(values):
    return dict(zip("XYZ",values))

def rgb(hex_color):
    return int("ff" + hex_color, 16)

world = item(document, "Workspace", "Workspace")
property_of(world,"bool","StreamingEnabled","false")
scenery = item(world, "Model", "Juniper Service Station")
pool = item(world, "Model", "Municipal Aquatics")
sites = item(world, "Folder", "Encounters")
reflection = item(world, "Model", "Reflection")
cream, teal, orange, dark, blue = "f5dfae","247774","bd542f","263e43","538d9a"

def part(name, pos, size, color, parent=scenery, *, solid=True, transparency=0, kind="Part", shape=1, yaw=0):
    obj = item(parent, kind, name)
    property_of(obj,"Vector3","size",xyz(size))
    c,s = math.cos(yaw),math.sin(yaw)
    rot = dict(zip(("R00","R01","R02","R10","R11","R12","R20","R21","R22"),(c,0,s,0,1,0,-s,0,c)))
    property_of(obj,"CoordinateFrame","CFrame",{**xyz(pos),**rot})
    property_of(obj,"Color3uint8","Color3uint8",rgb(color))
    property_of(obj,"bool","Anchored","true")
    property_of(obj,"bool","CanCollide",str(solid).lower())
    property_of(obj,"token","TopSurface",0)
    property_of(obj,"token","BottomSurface",0)
    if kind == "Part":
        property_of(obj,"token","shape",shape)
    if transparency:
        property_of(obj,"float","Transparency",transparency)
    return obj

def sign(name, words, pos, size, background=teal, foreground=cream, parent=scenery, yaw=0):
    plate = part(name,pos,size,background,parent,yaw=yaw)
    face = item(plate,"SurfaceGui","Lettering")
    property_of(face,"token","Face",2)
    property_of(face,"Vector2","CanvasSize",{"X":max(150,int(size[0]*50)),"Y":int(size[1]*55)})
    letters = item(face,"TextLabel","Sign")
    property_of(letters,"UDim2","Size",{"XS":1,"XO":0,"YS":1,"YO":0})
    property_of(letters,"float","BackgroundTransparency",1)
    property_of(letters,"bool","TextScaled","true")
    property_of(letters,"token","Font",19)
    property_of(letters,"string","Text",words)
    property_of(letters,"Color3","TextColor3",dict(zip("RGB",(int(foreground[k:k+2],16)/255 for k in (0,2,4)))))
    return plate

part("Grass verge",(0,-1.5,4),(210,2,133),"9d9264")
part("Asphalt",(0,-.52,4),(156,1,102),"525858")
for x in range(-65,72,12):
    part("Bay stripe",(x,.03,25),(.22,.08,17),cream)
for x in range(-90,95,16):
    part("Centre line",(x,-.44,62),(8,.07,.28),cream)
part("Road",(0,-.6,62),(208,.25,12),"454d4f")
part("Closed station",(0,5.5,-32),(69,11,14),cream)
part("Roof trim",(0,11.4,-32),(72,1.3,17),orange)
for x in (-26,-16,0,10,24):
    part("Tinted window",(x,6,-24.86),(7,5,.2),"3e6969")
    part("Sill",(x,3.3,-24.65),(7.6,.4,.7),teal)
sign("Fascia","SHARSTER FARTS",(-12,13.5,-24),(43,4,.8),orange)
sign("Closed","CLOSED",(-16,6,-24.57),(4,1.5,.25),dark)
for x in (-45,-15):
    part("Canopy post",(x,5,-5),(1.2,10,1.2),cream)
    part("Pump island",(x,.3,-5),(6,.6,4),cream)
    part("Petrol pump",(x,2.7,-4.2),(2.8,4.3,2),orange)
    sign("Meter","00.00",(x,3.5,-3.12),(2.1,.9,.16),dark)
part("Service canopy",(-30,10.4,-5),(42,1,13),cream)
part("Canopy stripe",(-30,10.8,1.5),(42,.65,.4),orange)
part("Soda machine",(-29,3.2,-20),(5,6.4,3.5),"a63e34")
sign("Vending placard","FIZZ\n25¢",(-29,4,-18.16),(4.4,3.5,.15),orange)
part("Dispensing slot",(-29,1.05,-18.1),(3.1,.7,.2),dark)
part("Shoe rack",(12,.6,14),(6,1.2,2.8),teal)
for x in (10.8,12.3):
    part("Rental sneaker",(x,1.52,14),(1.1,.65,1.9),cream)
sign("Quiet sign","SHOES OFF",(12,3.7,13),(6.5,1.4,.35),teal)
sign("Reserved bay","RESERVED",(34,4,4),(7,1.8,.3),teal)
part("Sign post",(34,1.9,4),(.4,3.8,.4),dark)
part("Bathroom",(47,4.3,-20),(12,8.6,10),teal)
sign("Staff entrance","6",(47,4.2,-14.9),(4.6,7.3,.2),dark)
sign("To pool","MUNICIPAL POOL ↓",(47,9.6,-15),(14,1.9,.35),orange)
spawn = part("LotSpawn",(-9,.12,31),(5,.24,5),dark,world,kind="SpawnLocation")
property_of(spawn,"bool","Neutral","true")
property_of(spawn,"int","Duration",0)

# The pool has a walkable tiled floor and sightlines from the portal to each objective.
part("Aquatics foundation",(0,-1,-173),(85,2,67),"b2c5b0",pool)
part("Tile floor",(0,.1,-174),(64,.2,43),"68acac",pool)
for x in range(-26,28,8):
    part("Lane tile",(x,.23,-174),(.3,.08,40),blue,pool)
part("PoolWater",(0,1.45,-174),(63,.2,42),"4cbbb9",world,solid=False,transparency=.58)
part("Bathhouse back wall",(0,6.5,-203),(84,13,2),"75a6a0",pool)
sign("Aquatics","THE POOL BENEATH THE POOL",(0,10,-201.7),(55,3.6,.5),teal,parent=pool)
for x in (-40,40):
    part("Tiled side wall",(x,2,-173),(1,4,63),cream,pool)
part("Ledge",(17,.65,-189),(13,1.3,5),cream,pool)
part("Valve pipe",(4,2,-190),(2,4,2),orange,pool)
part("Valve crossbar",(4,4,-190),(4,.5,.6),"d54238",pool)
sign("Valve sign","DRAIN",(4,5.2,-191),(5,1,.2),orange,parent=pool)
sign("Ladder sign","RETURN ↑",(-24,4,-150),(7,1.5,.35),teal,parent=pool)
for x in (-26,-23):
    part("Ladder rail",(x,2,-150),(.25,4,.25),dark,pool)
for y in (1,2,3):
    part("Ladder rung",(-24.5,y,-150),(3,.17,.2),dark,pool)
for i,(x,y) in enumerate(((-5,6),(0,8),(5,6),(0,4))):
    part("Lifeguard reflection",(x,y,-197),(9,8,5),"a6d26b",reflection,solid=False,transparency=.23,shape=0)
for x in (-2.5,2.5):
    part("Reflective sunglasses",(x,8.1,-194),(4,1.6,.5),dark,reflection,solid=False)
part("Whistle",(0,4.2,-193.8),(1.8,.8,.6),cream,reflection,solid=False)

anchors = {"Change":(-21,3,7),"Vending":(-29,3,-16),"Baja":(-23,3,-16),
           "ShoeRack":(12,2,16),"Cone":(20,.2,8),"Commuter":(34,1.4,10),
           "Stall":(47,3,-13),"PoolEntry":(-24,1,-147),"Wayne":(-13,1.4,-165),
           "Valve":(4,3,-186),"Lifeguard":(17,2.8,-188)}
for name,position in anchors.items():
    part(name,position,(.4,.4,.4),cream,sites,solid=False,transparency=1)

lighting = item(document,"Lighting","Lighting")
property_of(lighting,"string","TimeOfDay","16:40:00")
property_of(lighting,"float","Brightness",2)
property_of(lighting,"Color3","OutdoorAmbient",{"R":.55,"G":.51,"B":.46})
property_of(lighting,"bool","GlobalShadows","true")
storage = item(document,"ReplicatedStorage","ReplicatedStorage")
item(storage,"RemoteEvent","ShiftAction")
server = item(document,"ServerScriptService","ServerScriptService")
starter = item(document,"StarterPlayer","StarterPlayer")
scripts = item(starter,"StarterPlayerScripts","StarterPlayerScripts")
for parent, cls, name, filename in ((server,"Script","Shift","Shift.server.lua"),(scripts,"LocalScript","Binder","Binder.client.lua")):
    obj = item(parent,cls,name)
    property_of(obj,"ProtectedString","Source",(ROOT/"src"/filename).read_text(encoding="utf8"))
ET.indent(document)
ET.ElementTree(document).write(ROOT/"Sharster Farts.rbxlx",encoding="utf-8",xml_declaration=True)

browser = ROOT/"browser"
scenes = {file.stem:"data:image/jpeg;base64,"+base64.b64encode(file.read_bytes()).decode()
          for file in sorted((browser/"scenes").glob("*.jpg"))}
html = (browser/"game.html").read_text(encoding="utf8")
for token,content in (("/* STYLES */",(browser/"style.css").read_text(encoding="utf8")),
                      ("/* SCENES */",json.dumps(scenes)),("/* GAME */",(browser/"game.js").read_text(encoding="utf8"))):
    html=html.replace(token,content)
(ROOT/"Play Sharster Farts.html").write_text(html,encoding="utf8")
print(f"Built the Studio place ({serial} instances) and offline browser demo ({len(scenes)} scenes).")

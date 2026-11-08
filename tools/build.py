"""Build the Studio place and self-contained browser game with Python 3."""
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
scenery = item(world, "Model", "Shatterberg Baseplate")
shatters = item(world, "Folder", "Shatters")
rivals = item(world, "Folder", "Rivals")
cream, teal, orange, dark = "fff0c6","2e6652","df7542","283d32"

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

base = part("Studded baseplate",(0,-1,0),(120,2,100),"8cb576")
base.find("Properties/token[@name='TopSurface']").text = "3"
for x in range(-48,49,4):
    for z in (-29,29):
        part("Boundary stripe",(x,.07,z),(3.8,.14,.6),cream if x%8==0 else orange)
for z in range(-28,29,4):
    for x in (-50,50):
        part("Boundary stripe",(x,.07,z),(.6,.14,3.8),cream if z%8==0 else orange)
for x in (-13,13):
    part("Gate post",(x,5.5,29),(1,11,1),teal)
sign("Arena sign","SHATTERBERG ARENA",(0,11.2,29),(30,3.4,1),teal)
part("Chili counter",(-21,1.5,39),(15,3,5),orange)
for x in (-28,-14):
    part("Canopy post",(x,4.5,38),(.45,9,.45),teal)
for i in range(8):
    part("Awning",(-28+i*2,8.8,39),(2,1,7),orange if i%2 else cream)
sign("Menu","FREE CHILI",(-21,5.8,39),(11,2,.6),teal)
for x in (-26,-22,-18):
    part("Bowl",(x,3.4,39),(2.4,1.2,2.4),cream,shape=0)
    part("Chili",(x,3.8,39),(2,.5,2),"a64821",shape=0)
spawn=part("CanteenSpawn",(0,.12,39),(6,.24,6),teal,world,kind="SpawnLocation")
property_of(spawn,"bool","Neutral","true")
property_of(spawn,"int","Duration",0)
for i,(x,z) in enumerate(((0,21),(-8,17),(12,17),(-21,21),(24,10),(-37,15),(2,5),(-12,-4),(18,-9),(-32,-8),(37,-13),(0,-20),(30,22),(-26,-21),(42,4),(-42,0))):
    tough=i%4==3
    part(("Hard" if tough else "Small")+str(i+1),(x,2,z),(2.6,3.8,2.6) if tough else (2,2.9,2),"ed9542" if tough else "facb57",shatters,solid=False,yaw=.68)
for name,x,z,color in (("Kevin",-7,9,"b96c96"),("Coach Beans",13,3,"e67e41"),("Todd",-26,-6,"71649f")):
    model=item(rivals,"Model",name)
    for offset in (-.65,.65):
        part("Boot",(x+offset,.65,z),(1.15,1.3,1.15),dark,model,solid=False)
        part("Hand",(x+offset*2.45,2.65,z),(.7,1.5,1),"efbd69",model,solid=False)
    body=part("Torso",(x,2.6,z),(2.5,2.5,1.3),color,model,solid=False)
    property_of(model,"Ref","PrimaryPart",body.get("referent"))
    part("Head",(x,4.65,z),(1.9,1.7,1.6),"f9c674",model,solid=False)
    for offset in (-.4,.4):
        part("Eye",(x+offset,4.8,z-.83),(.18,.22,.08),dark,model,solid=False)

lighting = item(document,"Lighting","Lighting")
property_of(lighting,"string","TimeOfDay","16:40:00")
property_of(lighting,"float","Brightness",2)
property_of(lighting,"Color3","OutdoorAmbient",{"R":.55,"G":.51,"B":.46})
property_of(lighting,"bool","GlobalShadows","true")
storage = item(document,"ReplicatedStorage","ReplicatedStorage")
item(storage,"RemoteEvent","ArenaAction")
settings=item(storage,"StringValue","ArenaRules")
rule_text=(ROOT/"rules.json").read_text(encoding="utf8")
property_of(settings,"string","Value",rule_text)
server = item(document,"ServerScriptService","ServerScriptService")
starter = item(document,"StarterPlayer","StarterPlayer")
scripts = item(starter,"StarterPlayerScripts","StarterPlayerScripts")
for parent, cls, name, filename in ((server,"Script","Arena","Arena.server.lua"),(scripts,"LocalScript","ArenaHUD","Arena.client.lua")):
    obj = item(parent,cls,name)
    property_of(obj,"ProtectedString","Source",(ROOT/"src"/filename).read_text(encoding="utf8"))
ET.indent(document)
ET.ElementTree(document).write(ROOT/"Sharster Farts.rbxlx",encoding="utf-8",xml_declaration=True)

browser = ROOT/"browser"
html = (browser/"game.html").read_text(encoding="utf8")
game = (browser/"game.js").read_text(encoding="utf8")
html = html.replace("/* RULES */",json.dumps(json.loads(rule_text)))
html = html.replace("/* STYLES */",(browser/"style.css").read_text(encoding="utf8")).replace("/* GAME */",game)
(ROOT/"Play Sharster Farts.html").write_text(html,encoding="utf8")
print(f"Built Shatterberg Arena ({serial} instances) and the offline brawler.")

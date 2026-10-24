-- Explicit Meta dispatch, mirroring its declared API without inventing __index.
getFileReader=function()return nil end
local U=require 'B47ANCEDUI/API'
package.loaded['PZAPI/ui/organisms/Window']=true
package.loaded['PZAPI/ui/atoms/Text']=true
local UI={_mt={}};PZAPI={UI=UI}
UI.Texture={_ATOM_UI_CLASS={}}
UI.Texture.setTexture=function(self,value)self.texture=value end
UI.Texture.setSlice9=function()end
local function setColor(self,r,g,b,a)
 self.r,self.g,self.b,self.a=r,g,b,a
 if self.javaObj then self.javaObj.color={r,g,b,a}end
end
local function border(self,r,g,b,a)
 for _,name in ipairs({'leftBorder','rightBorder','topBorder','downBorder'})do self.children[name]:setColor(r,g,b,a)end
end
UI.Panel={setBorderColor=border}
UI.TextButton={onHover=function(self,state)local c=state and .1 or 0;setColor(self,c,c,c,.7);self.hovers=(self.hovers or 0)+1;return nil,'hover',4 end}
UI.ImageButton={onHover=function(self,state)setColor(self,state and .4 or 1,.4,.8,.8);return nil,'image'end}
UI.Window={init=function()end,setCollapsed=function(self,value)self.collapsed=value end}
UI.FishWindow={init=function()end,setCollapsed=UI.Window.setCollapsed}
UI.PrintMedia={init=function()end,setCollapsed=function(self,value)self.printCollapsed=value end}
local function node(values)
 local n={r=0,g=0,b=0,a=.7,setColor=setColor,children={}}
 for key,value in pairs(values or {})do n[key]=value end
 if n._ATOM_UI_CLASS==UI.Texture._ATOM_UI_CLASS then n.setTexture=UI.Texture.setTexture;n.setSlice9=UI.Texture.setSlice9 end
 return setmetatable(n,UI._mt)
end
local function panel(values)
 local n=node(values);n.setBorderColor=border
 for _,name in ipairs({'leftBorder','rightBorder','topBorder','downBorder'})do n.children[name]=node({r=.4,g=.4,b=.4,a=1})end
 return n
end
local function parents(w,parent)
 w.parent=parent
 for _,child in pairs(w.children)do parents(child,w)end
end
local function create(w)
 w.javaObj={onHover=w.onHover,renderUpdate=w.renderUpdate}
 for _,child in pairs(w.children)do create(child)end
end
local function init(w)
 if w.init then w:init()end
 if w.setBorderColor then w:setBorderColor(.4,.4,.4,1)end
 for _,child in pairs(w.children)do init(child)end
end
UI._mt.instantiate=function(self)
 parents(self);create(self);init(self);self.inits=(self.inits or 0)+1
 if self.fail then error('native instantiate failure')end
 return nil,'instantiated',8
end
UI._addChild=function(parent,child)
 parents(child,parent);create(child);init(child);return child,nil,9
end
-- Presentation dependency only; native IS widgets are not part of this fixture.
local P={pack=function(...)return {n=select('#',...),...}end,neutral=function(r,g,b)return r==g and g==b end}
package.loaded['B47ANCEDUI/NativePresentation']=P
package.loaded['B47ANCEDUI/NativePainters']={player=function(w)
 for _=1,64 do if not w then break end;if w.playerNum then return w.playerNum end;w=w.parent end
 return 0
end}
local originalPanel,originalHover=UI.Panel.setBorderColor,UI.TextButton.onHover
local A=require 'B47ANCEDUI/PZAPITheme'
assert(UI._mt.__index==nil,'Fixture/adapter repaired unverified native dispatch')
local updates=0
local w=node({init=UI.Window.init,setCollapsed=UI.Window.setCollapsed,playerNum=1,renderUpdate=function()updates=updates+1;return nil,'update',5 end})
w.children.bar=panel();w.children.body=panel();w.children.bottomBar=panel({a=0})
local button=panel({onHover=UI.TextButton.onHover});w.children.body.children.button=button
local warning=node({r=1,g=0,b=0,text='Native fish condition'});w.children.body.children.condition=warning
local document=panel({r=.8,g=.8,b=.8});w.children.body.children.printMedia=document
local art=panel({onHover=UI.TextButton.onHover});document.children.art=art
assert(w.instantiate==nil,'Meta shape differs from declared installed source')
local _,r,n=UI._mt.instantiate(w);assert(r=='instantiated'and n==8 and w.inits==1)
assert(w.children.bar.r==U.Theme.colors.window.r and w.children.bottomBar.a==0)
assert(warning.r==1 and warning.g==0 and not warning.b47NativeAtom,'Semantic content recoloured')
assert(not document.b47NativeAtom and not art.b47NativeAtom and document.r==.8,'Print content adopted')
local _,hover,hn=button:onHover(true);assert(hover=='hover'and hn==4 and button.hovers==1)
assert(button.javaObj.onHover==button.onHover,'Native callback captured before wrapper')
assert(button.r==U.Theme.colors.hover.r and button.a==.7,'Hover palette not reapplied')
local late=panel();w.children.body.children.late=late
local added,hole,extra=UI._addChild(w.children.body,late);assert(added==late and hole==nil and extra==9 and late.b47NativeAtom)
local lateArt=panel();document.children.lateArt=lateArt;UI._addChild(document,lateArt);assert(not lateArt.b47NativeAtom,'Dynamic document content adopted')
local callback=button.onHover;A.adopt(w);assert(button.onHover==callback,'Repeated adoption stacked callbacks')
assert(UI.Panel.setBorderColor==originalPanel and UI.TextButton.onHover==originalHover,'Template mutated')
local printed=node({init=UI.PrintMedia.init,setCollapsed=UI.PrintMedia.setCollapsed});printed.children.body=panel()
UI._mt.instantiate(printed);assert(printed.children.body.b47NativeAtom,'PrintMedia override rejected')
UI.Inventory={};local inventory=node({super=UI.Inventory})
inventory.children.titlePanel=node({_ATOM_UI_CLASS=UI.Texture._ATOM_UI_CLASS})
inventory.children.icon=node({_ATOM_UI_CLASS=UI.Texture._ATOM_UI_CLASS,texture={}})
UI._mt.instantiate(inventory)
assert(inventory.children.titlePanel.b47NativeAtom and not inventory.children.icon.b47NativeAtom,'Prototype chrome/content boundary failed')
UI.BuildUI={init=function()end,getRecipes=function()error('Presentation called gameplay')end}
local build=node({init=UI.BuildUI.init,getRecipes=UI.BuildUI.getRecipes});build.children.background=node({_ATOM_UI_CLASS=UI.Texture._ATOM_UI_CLASS})
local search=node({_ATOM_UI_CLASS=UI.Texture._ATOM_UI_CLASS,isSearch=false,onHover=function(self)
 if self.isSearch then self:setColor(.46,.36,.08,.7)end
end,onLeftClick=function(self)self.isSearch=true;self:setColor(.46,.36,.08,.7);return nil,'search'end})
build.children.searchButton=search
local snap=node({_ATOM_UI_CLASS=UI.Texture._ATOM_UI_CLASS,r=.12,g=.12,b=.12,onHover=function(self,state)
 if state then self.previous={self.r,self.g,self.b};self:setColor(.24,.24,.24,.7)
 else self:setColor(self.previous[1],self.previous[2],self.previous[3],.7)end
end})
build.children.settingsButton=snap
UI._mt.instantiate(build);assert(build.children.background.b47NativeAtom,'Native build prototype chrome missed')
search:onLeftClick();build:renderUpdate();assert(search.r==U.Theme.colors.selected.r and search.isSearch,'Active native search state lost')
search:onHover(false);assert(search.r==U.Theme.colors.selected.r,'Hover exit erased active search')
snap:onHover(true);snap:onHover(false);U.excludeNativeTheme(build);build:renderUpdate();assert(snap.r==.12,'Native hover snapshot contaminated by theme')
UI.ScrollBarVertical={setBarSize=function()end}
local scrollbar=node({setBarSize=UI.ScrollBarVertical.setBarSize});scrollbar.children.bar=node();local thumb=node({_ATOM_UI_CLASS=UI.Texture._ATOM_UI_CLASS,texture={}})
scrollbar.children.bar.children.mid=thumb;w.children.body.children.scroll=scrollbar;UI._addChild(w.children.body,scrollbar)
local thumbBook=U.StylePresets.set(U.StylePresets.new(),'default','B47ANCEDUI','slider','accent','#123456');local thumbOwner={}
assert(U.StylePresets.preview(1,thumbBook,thumbOwner));w:renderUpdate();assert(thumb.r==0x12/255 and thumb.g==0x34/255,'Thumb ignored slider family')
U.StylePresets.clearPreview(1,thumbOwner)
local provider=node({init=UI.Window.init,setCollapsed=UI.Window.setCollapsed,b47AppearanceScope='OtherMod'});provider.children.body=panel()
UI._mt.instantiate(provider);assert(not provider.children.body.b47NativeAtom and not provider.b47NativeAtomObserver,'Provider ownership ignored')
local unknown=node({init=function()end,setCollapsed=UI.Window.setCollapsed});unknown.children.body=panel()
UI._mt.instantiate(unknown);assert(not unknown.children.body.b47NativeAtom,'Unknown root adopted')
local bad=node({init=UI.Window.init,setCollapsed=UI.Window.setCollapsed,fail=true})
local ok,err=pcall(UI._mt.instantiate,bad);assert(not ok and tostring(err):find('native instantiate failure'),'Native failure swallowed')
local preset=U.StylePresets.set(U.StylePresets.new(),'default','B47ANCEDUI','window','background','#334455');local owner={}
local before=updates
assert(U.StylePresets.preview(1,preset,owner));local _,up,un=w:renderUpdate();assert(up=='update'and un==5 and updates==before+1)
assert(w.children.bar.r==0x33/255,'Live preset not applied')
U.StylePresets.clearPreview(1,owner);w:renderUpdate();assert(w.children.bar.r==U.Theme.colors.window.r,'Preview cancellation stale')
U.excludeNativeTheme(w);w:renderUpdate();assert(w.children.bar.r==0 and w.children.bar.children.leftBorder.r==.4,'Late opt-out left static chrome tinted')
local old=button.r;button:onHover(false);assert(button.r==0,'Opt-out ignored')
U.excludeNativeTheme(w,false);w:renderUpdate();assert(w.children.bar.r==U.Theme.colors.window.r,'Un-exclude not reflected')
print('PASS OFFLINE Atom native Meta dispatch preserved, known roots, callbacks/returns/errors, late children, template identity, transparency and document/semantic exclusions')

local image=node({_ATOM_UI_CLASS=UI.Texture._ATOM_UI_CLASS,texture={},onHover=UI.ImageButton.onHover,enable=false})
w.children.body.children.imageButton=image;UI._addChild(w.children.body,image)
local iconBook=U.StylePresets.set(U.StylePresets.new(),'default','B47ANCEDUI','button','iconDisabled','#123456')
local iconOwner={};assert(U.StylePresets.preview(1,iconBook,iconOwner));w:renderUpdate()
assert(image.r==0x12/255 and image.g==0x34/255,'Disabled native image button missed iconDisabled')
U.StylePresets.clearPreview(1,iconOwner)

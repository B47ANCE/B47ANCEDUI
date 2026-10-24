-- Native-shaped, strict drawing/lifecycle doubles. Offline, not PZ acceptance.
getFileReader=function()return nil end
getFileWriter=function()error('Presentation must not write')end
local U=require 'B47ANCEDUI/API'
local base={}
function base:getWidth()return self.width end
function base:getHeight()return self.height end
function base:getYScroll()return self.scroll or 0 end
function base:getScrollHeight()return self.scrollHeight or self.height end
function base:getScrollAreaHeight()return self.height end
function base:addChild(child)self.children[#self.children+1]=child;child.parent=self;return child,nil,'added'end
for _,method in ipairs({'drawRect','drawRectStatic','drawRectBorder','drawRectBorderStatic','drawTextureScaled','drawTexture'})do
 local name=method
 base[name]=function(self,...)self.draws[#self.draws+1]={name,...}end
end
local function class(name,path)
 local c=setmetatable({Type=name},{__index=base})
 c.prerender=function(self)self.pres=(self.pres or 0)+1;return nil,'pre'end
 c.render=function(self)self.renders=(self.renders or 0)+1;return nil,'render'end
 _G[name]=c;package.loaded[path or 'ISUI/'..name]=c;return c
end
local button=class('ISButton')
button.prerender=function(self)
 self.pres=(self.pres or 0)+1
 local c=self.backgroundColor
 self:drawRect(0,0,self.width,self.height,c.a,c.r,c.g,c.b)
 self:drawRectBorder(0,0,self.width,self.height,1,.4,.4,.4)
 if self.fail then error('button failure')end
 return nil,'button',7
end
class('ISResizableButton','ISUI/ISResizeableButton').prerender=button.prerender
local tip=class('ISToolTip');local invTip=class('ISToolTipInv')
tip.prerender=function(self)self.layouts=(self.layouts or 0)+1;self:drawRect(0,0,self.width,self.height,.8,0,0,0)end
tip.render=function(self)
 self:drawRect(0,0,self.width,self.height,.7,.05,.05,.05)
 self:drawRectBorder(0,0,self.width,self.height,.5,.9,.9,1)
 self.contents=(self.contents or 0)+1;return 'tip'
end
invTip.render=function(self)
 self.measurements=(self.measurements or 0)+1
 self:drawRect(0,0,self.width,self.height,.5,0,0,0)
 self:drawRectBorder(0,0,self.width,self.height,1,.4,.4,.4)
 self.item:DoTooltip(self.tooltip);return 'item'
end
local context=class('ISContextMenu')
context.showTooltip=function(self,option)self.toolTip=option.toolTip;return nil,'shown'end
context.render=function(self)
 self.renders=(self.renders or 0)+1
 self:drawRect(0,-self:getYScroll(),self.width,self.height,1,0,0,0)
 self:drawRectBorderStatic(0,0,self.width,self.height,1,1,1,1)
 self:drawRect(0,20,self.width,self.itemHgt,.8,.5,.5,.5)
 self:drawRect(2,40,7,8,.3,1,0,0) -- semantic marker
 if self.fail then error('context failure')end
 return nil,'context',9
end
local page=class('ISInventoryPage');local pane=class('ISInventoryPane');local bar=class('ISScrollBar')
page.titleBarHeight=function()return 20 end
page.addContainerButton=function(self,b)self.containerButtonPanel:addChild(b);return b,nil,8 end
page.prerender=function(self)
 self.pres=(self.pres or 0)+1
 self:drawRect(0,0,self.width,self.isCollapsed and 20 or self.height,.7,0,0,0)
 self:drawTextureScaled(self.titlebarbkg,2,1,self.width-4,18,1,1,1,1)
 self:drawRect(1,1,self.width-2,18,.73,1,1,1) -- blink
 return nil,'page'
end
page.render=function(self)
 self.renders=(self.renders or 0)+1
 self:drawRectBorder(0,0,self.width,self.height,.9,.4,.4,.4)
 self:drawRectBorder(1,1,self.width-2,self.height-2,.4,.2,1,1) -- controller
 self:drawTextureScaled(self.statusbarbkg,1,self.height-11,self.width-2,10,1,1,1,1)
 self:drawTextureScaled(self.resizeimage,self.width-11,self.height-11,10,10,1,1,1,1)
 return 'page-render'
end
pane.renderdetails=function(self,dragged)
 self.details=(self.details or 0)+1;self.lastDragged=dragged
 self:drawRectStatic(1,0,self.width-2,self.headerHgt,1,0,0,0)
 self:drawRect(1,20,self.width-1,self.itemHgt,.2,1,1,1)
 self:drawRect(self.column2,40,self.column4,self.itemHgt,.02,1,1,1)
 self:drawRect(1,60,self.width-1,self.itemHgt,.2,1,0,0)
 self:drawRect(1,80,self.column4,self.itemHgt,.2,.4,1,.3)
 if self.fail then error('details failure')end
 return nil,'details',dragged
end
pane.updateTooltip=function(self)self.updates=(self.updates or 0)+1;return nil,'updated'end
bar.render=function(self)
 self.renders=(self.renders or 0)+1
 self.barx=5;self.bary=20;self.barwidth=8;self.barheight=24
 self:drawTextureScaled(self.midtex,5,22,9,20,.9,.9,.9,1)
 self:drawTexture(self.uptex,4,0,1,1,1,1)
 if self.fail then error('scroll failure')end
 return 'scroll'
end
local modal=class('ISModalDialog');local rich=class('ISModalRichText')
modal.prerender=function(self)
 self.pres=(self.pres or 0)+1
 self:drawRect(0,0,self.width,self.height,.9,0,0,0)
 self:drawRectBorder(0,0,self.width,self.height,1,.4,.4,.4)
 return nil,'modal'
end
rich.prerender=modal.prerender
local monitor=class('ISConfirmMonitorSettingsDialog')
monitor.Type='ISConfirmMonitorSettings';monitor.prerender=modal.prerender
monitor.update=function(self)self.countdown=self.countdown-1 end
local main=class('MainOptions','OptionScreens/MainOptions')
main.onConfirmModalClick=function()end;main.onConfirmMonitorSettingsClick=function()end
MainScreen={};package.loaded['OptionScreens/MainScreen']=MainScreen
local handlers={}
local function event(name)
 handlers[name]={};return {Add=function(fn)table.insert(handlers[name],fn)end}
end
Events={}
for _,name in ipairs({'OnFillWorldObjectContextMenu','OnFillInventoryObjectContextMenu','OnFillInventoryContextMenuNoItems','OnMainMenuEnter','OnGameStart','OnResetLua','OnCreatePlayer','OnResolutionChange'})do Events[name]=event(name)end
ISPlayerData={};package.loaded['ISUI/PlayerData/ISPlayerData']=ISPlayerData
local function widget(c)
 return setmetatable({width=240,height=160,children={},draws={},x=11,y=13,player=1,font=44,
 backgroundColor={a=.7,r=0,g=0,b=0}}, {__index=c})
end
local P=require 'B47ANCEDUI/NativePresentation'
local C=require 'B47ANCEDUI/NativeContext'
local I=require 'B47ANCEDUI/NativeInventory'
local D=U.NativeDialogs
local function has(w,predicate)
 for _,d in ipairs(w.draws)do if predicate(d)then return true end end
 return false
end
local function color(w,r,g,b)
 return has(w,function(d)return d[1]=='drawRect'and P.equal(d[7],r)and P.equal(d[8],g)and P.equal(d[9],b)end)
end
local originalContextRender=context.render
local root=widget(context);root.itemHgt=24;root.subOptionNums=0;root.instanceMap={}
C.fill(1,root,{},true);assert(not root.b47NativeContext,'Capability probes must not adopt')
C.fill(1,root);assert(root.b47NativeContext and context.render==originalContextRender)
local a,b,c=root:render();assert(a==nil and b=='context'and c==9 and root.renders==1)
assert(color(root,1,0,0),'Semantic marker changed')
local child=widget(context);child.itemHgt=24;root.subOptionNums=1;root.instanceMap={child};root:render()
assert(child.b47NativeContext,'Late class-created submenu missed')
root.instanceMap={widget(context)};root.instanceMap[1].itemHgt=24
C.fill(1,root);assert(root.instanceMap[1].b47NativeContext,'Pooled generation reused')
local foreign=widget(context);foreign.render=function()end
assert(not C.adopt(foreign,0),'Foreign renderer adopted')
root.fail=true;assert(not pcall(root.render,root));assert(rawget(root,'drawRect')==nil and rawget(root,'drawRectBorderStatic')==nil);root.fail=false
local generic=widget(tip);root:showTooltip({toolTip=generic});generic:prerender();generic:render()
assert(generic.layouts==1 and generic.contents==1 and not color(generic,.05,.05,.05),'Visible tooltip render backing not styled')
local nativePane=widget(pane);nativePane.itemHgt=20;nativePane.headerHgt=20;nativePane.column2=30;nativePane.column4=200
nativePane.vscroll=widget(bar);nativePane.vscroll.vertical=true;nativePane.vscroll.midtex={};nativePane.vscroll.uptex={};nativePane:addChild(nativePane.vscroll)
local function inventory(ownPane)
 local w=widget(page);w.buttonSize=20;w.titlebarbkg={};w.statusbarbkg={};w.resizeimage={}
 w.controlsUI=widget(base);w.containerButtonPanel=widget(base)
 w:addChild(w.controlsUI);w:addChild(w.containerButtonPanel)
 w.inventoryPane=ownPane or nativePane;w:addChild(w.inventoryPane)
 return w
end
local inv=inventory();ISPlayerData[2]={playerInventory=inv}
local loot=inventory(widget(pane));ISPlayerData[1]={lootInventory=loot}
I.current();assert(inv.b47NativeInventory and nativePane.b47NativeInventoryPane)
assert(loot.b47NativeInventory and loot.inventoryPane.b47NativeInventoryPane,'Live loot slot not adopted')
local menuAction=function()end;local bt=widget(button);bt.onclick=menuAction;bt.textureColor={r=.2,g=.7,b=.1,a=1};bt.image={}
local image,textureColor=bt.image,bt.textureColor
local added,unused,extra=inv:addContainerButton(bt);assert(added==bt and unused==nil and extra==8 and bt.b47NativeButton)
local font,x,y,width,height=bt.font,bt.x,bt.y,bt.width,bt.height
local _,rv,n=bt:prerender();assert(rv=='button'and n==7)
assert(bt.onclick==menuAction and bt.image==image and bt.textureColor==textureColor and bt.font==font and bt.x==x and bt.y==y and bt.width==width and bt.height==height)
bt.backgroundColor={a=.65,r=1,g=0,b=0};bt.draws={};bt:prerender();assert(color(bt,1,0,0),'Blink/action red changed')
local late=widget(button);inv.controlsUI:addChild(late);assert(late.b47NativeButton,'Late handler button missed')
local _,pr=inv:prerender();assert(pr=='page'and inv.pres==1 and color(inv,1,1,1),'Title blink changed')
inv:render();assert(has(inv,function(d)return d[1]=='drawTextureScaled'and d[2]==inv.resizeimage end),'Resize texture changed')
local _,det,drag=nativePane:renderdetails(true);assert(det=='details'and drag and nativePane.details==1 and nativePane.lastDragged)
assert(color(nativePane,1,0,0)and color(nativePane,.4,1,.3),'Rejected-drop/progress colors changed')
nativePane.fail=true;assert(not pcall(nativePane.renderdetails,nativePane,false));assert(rawget(nativePane,'drawRect')==nil and rawget(nativePane,'drawRectStatic')==nil);nativePane.fail=false
local item=widget(invTip);local engineTip={};item.tooltip=engineTip
item.item={DoTooltip=function(_,value)assert(value==engineTip);item.stats=(item.stats or 0)+1 end}
nativePane.toolRender=item;nativePane:updateTooltip();assert(item.b47NativeTooltip);item:render();assert(item.stats==1 and item.measurements==1)
local scroll=nativePane.vscroll;scroll:render();assert(scroll.barx==5 and scroll.barwidth==8 and scroll.barheight==24 and scroll.renders==1)
assert(has(scroll,function(d)return d[1]=='drawTexture'and d[2]==scroll.uptex end),'Native arrows changed')
scroll.fail=true;assert(not pcall(scroll.render,scroll));assert(rawget(scroll,'drawTextureScaled')==nil);scroll.fail=false
-- Explicit native player indices must not fall back to player zero's preset.
local presets=U.StylePresets
local owner={}
for player,hex in pairs({[0]='#112233',[1]='#445566'})do
 local book=presets.set(presets.new(),'default','B47ANCEDUI','window','background',hex)
 assert(presets.preview(player,book,owner))
end
inv.draws={};inv:prerender();assert(color(inv,0x44/255,0x55/255,0x66/255),'Split-screen player scope lost')
loot.draws={};loot:prerender();assert(color(loot,0x11/255,0x22/255,0x33/255),'Loot inherited another player preset')
ISPlayerData[2].playerInventory=nil;inv.draws={};inv:prerender();assert(color(inv,0,0,0),'Stale native window stayed styled')
local options=widget(main);options.tabs={};MainScreen.instance={mainOptions=options}
local confirmation=widget(modal);confirmation.target=options;confirmation.onclick=main.onConfirmModalClick
confirmation.yes=widget(button);confirmation:addChild(confirmation.yes)
local click=confirmation.onclick;options.modal=confirmation;U.OptionsLifecycle.current();options:prerender()
assert(U.OptionsLifecycle.nativeRenderer(options),'Monitor broke Options renderer identity')
assert(confirmation.b47NativeDialog);confirmation:prerender();assert(confirmation.pres==1 and confirmation.onclick==click and confirmation.width==240)
local mode=widget(monitor);mode.target=options;mode.onclick=main.onConfirmMonitorSettingsClick;mode.countdown=20;options.modal=mode;options:prerender()
assert(mode.b47NativeDialog);mode:update();mode:render();assert(mode.countdown==19 and mode.renders==1)
local alien=widget(modal);alien.target=options;alien.onclick=function()end;options.modal=alien;options:prerender();assert(not alien.b47NativeDialog)
local info=widget(rich);local paused=true;info.destroy=function()paused=false end
ISPlayerData[2].playerInventory=inv;inv.infoRichText=info;inv:prerender();assert(info.b47NativeDialog and paused);info:prerender();assert(paused)
-- Transparent native icon controls stay transparent under an opacity preset.
local book=presets.set(presets.new(),'default','B47ANCEDUI','button','opacity',100)
assert(presets.preview(1,book,owner));bt.backgroundColor={a=0,r=0,g=0,b=0};bt.draws={};bt:prerender()
assert(not has(bt,function(d)return d[1]=='drawRect'and d[6]>0 and d[4]>2 and d[5]>2 end),'Preset filled a transparent icon backing')
book=presets.set(book,'default','B47ANCEDUI','button','borderWidth',0)
assert(presets.preview(1,book,owner));bt.joypadFocused=true;bt.draws={};bt:prerender()
assert(#bt.draws>0,'Zero ordinary border width erased controller focus')
local unstyled=widget(main);unstyled.tabs={};unstyled.render=function()end
local unowned=widget(modal);unowned.target=unstyled;unowned.onclick=main.onConfirmModalClick;unstyled.modal=unowned
MainScreen.instance.mainOptions=unstyled;U.OptionsLifecycle.current();unstyled:prerender();assert(not unowned.b47NativeDialog)
print('PASS OFFLINE native context/pooling/probes, tooltip draw phases, inventory/loot ownership, semantic colors, native delegates/geometry, player presets, dialogs and exception restoration')

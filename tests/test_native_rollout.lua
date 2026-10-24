-- Strict lifecycle/drawing doubles. No production API is added to native types.
getFileReader=function()return nil end
getFileWriter=function()error('Native presentation must not write')end
local U=require 'B47ANCEDUI/API'
local event=function()return {handlers={},Add=function(fn)end}end
Events={OnPreUIDraw=event(),OnMainMenuEnter=event(),OnGameStart=event(),OnFillWorldObjectContextMenu=event(),OnFillInventoryObjectContextMenu=event(),OnFillInventoryContextMenuNoItems=event()}
local base={Type='ISUIElement'};base.__index=base;ISUIElement=base
function base:new(x,y,width,height)
 return setmetatable({x=x,y=y,width=width,height=height,children={},draws={},backgroundColor={r=0,g=0,b=0,a=.8},borderColor={r=.4,g=.4,b=.4,a=1}},self),nil,'constructed'
end
function base:addChild(child)self.children[#self.children+1]=child;child.parent=self;return child,nil,'added'end
function base:getWidth()return self.width end
function base:getHeight()return self.height end
for _,method in ipairs({'drawRect','drawRectStatic','drawRectBorder','drawRectBorderStatic','drawTextureScaled','drawTexture'})do
 local name=method;base[name]=function(self,...)self.draws[#self.draws+1]={name,...}end
end
function base:prerender()
 local bg,edge=self.backgroundColor,self.borderColor
 self:drawRectStatic(0,0,self.width,self.height,bg.a,bg.r,bg.g,bg.b)
 self:drawRectBorderStatic(0,0,self.width,self.height,edge.a,edge.r,edge.g,edge.b)
 self:drawRect(7,9,8,6,.5,1,0,0) -- state/content is native
 if self.fail then error('native draw failure')end
 return nil,'native',42
end
function base:render()return nil,'render'end
local function class(name,parent)
 local c=setmetatable({Type=name},{__index=parent or base});c.__index=c;_G[name]=c;return c
end
for _,name in ipairs({'ISButton','ISResizableButton','ISToolTip','ISToolTipInv','ISContextMenu','ISPanel','ISPanelJoypad','NewGameScreen','LoadGameScreen','ISHealthPanel','ISVehicleMechanics','ISAdminPanelUI','MainOptions','MainScreen','ISComboBoxPopup','ISComboBox','ISTabPanel','ISScrollBar'})do class(name)end
package.loaded['ISUI/ISUIElement']=base
for _,name in ipairs({'ISButton','ISToolTip','ISToolTipInv','ISContextMenu'})do package.loaded['ISUI/'..name]=_G[name]end
package.loaded['ISUI/ISResizeableButton']=ISResizableButton
function ISContextMenu:showTooltip()end
local H=require 'B47ANCEDUI/NativeTheme'
local function widget(c)return c:new(10,20,280,160)end
local function find(w,predicate)for _,draw in ipairs(w.draws)do if predicate(draw)then return true end end end
local root,unused,extra=widget(NewGameScreen);assert(unused==nil and extra=='constructed')
local button=widget(ISButton);button.title='Native action';local cb=function()end;button.onclick=cb
local got,hole,last=root:addChild(button);assert(got==button and hole==nil and last=='added')
H.flush();assert(root.b47NativeTheme and button.b47NativeTheme)
local palette,edge=root.backgroundColor,root.borderColor
local _,result,n=root:prerender();assert(result=='native'and n==42 and root.backgroundColor==palette and root.borderColor==edge)
assert(find(root,function(d)return d[1]=='drawRect'and d[7]==1 and d[8]==0 and d[9]==0 end),'Semantic red changed')
assert(find(root,function(d)return d[7]==U.Theme.colors.window.r and d[8]==U.Theme.colors.window.g end),'Native static frame missed')
assert(button.onclick==cb and button.width==280 and button.height==160 and button.x==10)
root.fail=true;assert(not pcall(root.prerender,root));root.fail=false
assert(root.backgroundColor==palette and root.borderColor==edge and rawget(root,'drawRectStatic')==nil and rawget(root,'drawTextureScaled')==nil,'Exception left borrowed methods/fields')
local late=widget(ISButton);late.title='Late';root:addChild(late);H.flush();assert(late.b47NativeTheme)
local menu=widget(MainScreen);MainScreen.instance=menu;menu.prerender=function()end;menu.b47MenuBackgroundRenderer=menu.prerender
menu.bottomPanel=widget(ISPanel);menu:addChild(menu.bottomPanel)
local navigation=widget(ISButton);navigation.title='Continue';menu.bottomPanel:addChild(navigation)
local load=widget(LoadGameScreen);menu:addChild(load);H.flush()
assert(not menu.b47NativeTheme and not menu.bottomPanel.b47NativeTheme and not navigation.b47NativeTheme and load.b47NativeTheme,'Existing menu layout ownership broken')
local options=widget(MainOptions);local optButton=widget(ISButton);optButton.title='Apply';options:addChild(optButton);H.flush();assert(not options.b47NativeTheme and not optButton.b47NativeTheme,'Options owner preempted')
local unknown=widget(class('ForeignModPanel'));local child=widget(ISButton);child.title='Foreign';unknown:addChild(child);H.flush();assert(not child.b47NativeTheme,'Unknown provider subtree was adopted')
local overridden=widget(ISPanel);overridden.render=function()end;H.flush();assert(not overridden.b47NativeTheme,'Instance custom renderer overwritten')
local provider=widget(ISPanel);provider.b47AppearanceScope='OtherMod';H.flush();assert(not provider.b47NativeTheme,'Provider-scoped tree adopted')
for _,c in ipairs({ISHealthPanel,ISVehicleMechanics,ISAdminPanelUI})do local w=widget(c);H.flush();assert(w.b47NativeTheme,'Audited gameplay/specialist class missed')end
local owner={};local preset=U.StylePresets.set(U.StylePresets.new(),'default','B47ANCEDUI','window','background','#224466')
assert(U.StylePresets.preview(1,preset,owner));root.player=1;root.draws={};root:prerender()
assert(find(root,function(d)return d[7]==0x22/255 and d[8]==0x44/255 and d[9]==0x66/255 end),'Native player field lost')
U.excludeNativeTheme(root);root.draws={};root:prerender();assert(find(root,function(d)return d[1]=='drawRectStatic'and d[7]==0 end),'Live exclusion failed')
U.excludeNativeTheme(root,false)
unknown:addChild(late);late.draws={};late:prerender()
assert(find(late,function(d)return d[1]=='drawRectStatic'and d[7]==0 and d[8]==0 end),'Reparented control bypassed provider barrier')
local transparent=widget(ISPanel);transparent.backgroundColor.a=0;H.flush();transparent.draws={};transparent:prerender()
assert(not find(transparent,function(d)return d[1]=='drawRect'and d[6]>0 and d[4]>100 end),'Transparent panel filled')
-- Native hover also uses the selected-tab texture. Only the real active tab
-- receives an accent underline; renderer/activation/input stay native.
ISTabPanel.tabSelected={};ISTabPanel.tabUnSelected={}
function ISTabPanel:getActiveViewIndex()return 1 end
function ISTabPanel:getTabX()return 0 end
ISTabPanel.render=function(self)
 self:drawTextureScaled(ISTabPanel.tabSelected,0,0,40,19,1,1,1,1)
 self:drawTextureScaled(ISTabPanel.tabSelected,40,0,40,19,.3,1,1,1)
end
local tabs=widget(ISTabPanel);tabs.tabHeight=20;H.flush();tabs:render()
assert(not find(tabs,function(d)return d[2]>=40 and d[3]==17 and d[5]==2 end),'Hover received active underline')
local combo=widget(ISComboBox);combo.player=1;H.flush()
local popup=widget(ISComboBoxPopup);popup.parentCombo=combo
local bg=combo.backgroundColor;local hover=combo.backgroundColorMouseOver
popup.render=function(self)
 self.observedBG=self.parentCombo.backgroundColor
 if self.fail then error('native popup failure')end
 return nil,'popup',9
end
-- An explicit custom renderer must be refused. Use a native class renderer for
-- the shared-popup contract in a fresh instance/class snapshot.
assert(not popup.b47NativeTheme)
ISComboBoxPopup.render=popup.render
local popup2=widget(ISComboBoxPopup);popup2.parentCombo=combo;H.flush()
local _,pr,pn=popup2:render();assert(pr=='popup'and pn==9 and combo.backgroundColor==bg and combo.backgroundColorMouseOver==hover)
assert(popup2.observedBG~=bg,'Native shared popup did not borrow current combo palette')
local other=widget(ISComboBox);U.excludeNativeTheme(other)
popup2.parentCombo=other
local original=other.backgroundColor
-- Native delegate reads its original current owner's palette.
other.backgroundColor=bg
popup2:render();assert(popup2.observedBG==bg,'Excluded shared popup was still loaned a themed owner palette')
other.backgroundColor=original
popup2.parentCombo=combo;popup2.fail=true
assert(not pcall(popup2.render,popup2)and combo.backgroundColor==bg and combo.backgroundColorMouseOver==hover,'Popup exception leaked owner palette')
popup2.fail=false
-- Live native slider dimensions follow preview/Cancel without calling a value
-- setter, resize callback or native paginate again.
local sliderClass=class('ISSliderPanel')
function sliderClass:paginate()self.sliderBarDim={x=0,y=4,w=280,h=2};self.sliderDim={x=2,y=0,w=5,h=10}end
local slider=widget(sliderClass);slider.playerNum=2;slider:paginate();slider.currentValue=37;local valueCallback=function()error('Value changed')end;slider.onValueChange=valueCallback
H.flush();local owner2={};local book=U.StylePresets.set(U.StylePresets.new(),'default','B47ANCEDUI','slider','thumbWidth',17)
assert(U.StylePresets.preview(2,book,owner2));slider:prerender();assert(slider.sliderDim.w==17 and slider.currentValue==37 and slider.onValueChange==valueCallback)
U.StylePresets.clearPreview(2,owner2);slider:prerender();assert(slider.sliderDim.w==5,'Cancel left native slider geometry stale')
ISScrollBar.render=function(self)
 self.barx=self.vertical and 5 or 16;self.bary=self.vertical and 16 or 5;self.barwidth=self.vertical and 8 or 36;self.barheight=self.vertical and 36 or 8
 self:drawTexture(self.uptex,4,0,1,1,1,1)
 self:drawTextureScaled(self.midtex,self.barx,self.bary,self.barwidth,self.barheight,.9,.9,.9,1)
 if self.fail then error('scroll failure')end
 return nil,'scroll',13
end
for _,vertical in ipairs({true,false})do
 local scroll=widget(ISScrollBar);scroll.vertical=vertical;scroll.uptex={};scroll.midtex={};H.flush()
 local _,sr,sn=scroll:render();assert(sr=='scroll'and sn==13 and scroll.barwidth==(vertical and 8 or 36))
 assert(find(scroll,function(d)return d[1]=='drawTexture'and d[2]==scroll.uptex end),'Native scrollbar arrow lost')
 assert(not find(scroll,function(d)return d[1]=='drawTextureScaled'and d[2]==scroll.midtex end),'Scrollbar thumb not themed')
 scroll.fail=true;assert(not pcall(scroll.render,scroll)and rawget(scroll,'drawTextureScaled')==nil,'Scroll error left override')
end
print('PASS OFFLINE broad native lifecycle, deferred/late children, frontend/gameplay/specialist roots, owner guards, palette/error restoration, semantic colour, player presets, tabs and shared dropdowns')

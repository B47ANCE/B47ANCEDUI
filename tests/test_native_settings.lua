-- Contract doubles only. No native rendering/input or game-option persistence proof.
getFileReader=function() return nil end
getFileWriter=function() error('Styling must never write preferences') end
local U=require 'B47ANCEDUI/API';local T=U.Theme
local calls,draws={},{}
local base={}
function base:getWidth() return self.width end
function base:getHeight() return self.height end
function base:drawRect(...) draws[#draws+1]={...} end
function base:drawRectBorder(...) draws[#draws+1]={...} end
function base:drawRectBorderStatic(...) draws[#draws+1]={...} end
function base:drawTextureScaled(...) draws[#draws+1]={...} end
function base:addChild(child) self.children[#self.children+1]=child;child.parent=self;return child end
local function class(name,path)
 local c=setmetatable({Type=name},{__index=base})
 c.prerender=function(self) calls[self]=(calls[self] or 0)+1;return 'native-pre' end
 c.render=function() return 'native-render' end
 _G[name]=c;package.loaded[path or 'ISUI/'..name]=c;return c
end
local panel=class('ISPanel');class('ISPanelJoypad');local button=class('ISButton')
class('ISTextEntryBox');class('ISTickBox');local tabs=class('ISTabPanel')
tabs.tabSelected={};tabs.tabUnSelected={}
function tabs:getActiveViewIndex() for i,v in ipairs(self.viewList) do if v==self.activeView then return i end end end
function tabs:getTabX(index) return 1+(index-1)*121 end
local combo=class('ISComboBox');class('ISVolumeControl');class('ISMegaVolumeControl')
class('ISSliderPanel','RadioCom/ISUIRadio/ISSliderPanel')
ISVolumeControl.render=function(self)
 self:drawRect(10,2,16,self:getHeight()-4,1,.5,.5,.5)
 if self.fail then error('volume failure') end
 return 'native-render'
end
local main=class('MainOptions','OptionScreens/MainOptions')
main.subPanelPreRender=function(self) self.stencil=true;calls[self]=(calls[self] or 0)+1 end
main.subPanelRender=function(self) assert(self.stencil);self.stencil=false end
MainScreen={};package.loaded['OptionScreens/MainScreen']=MainScreen
local handlers={}
local function event() return {Add=function(fn) handlers[#handlers+1]=fn end} end
Events={OnMainMenuEnter=event(),OnGameStart=event(),OnResetLua=event()}
local function widget(c)
 return setmetatable({children={},width=240,height=32,x=23,y=42,font=UIFont.Medium,
  backgroundColor={r=.2,g=.3,b=.4,a=.7},borderColor={r=1,g=1,b=1,a=.5},selected=2,scrollY=-200,
  title='Native title',enable=true,options={'One','Two'},onClickArgs={3,5}}, {__index=c})
end
local function root()
 local r=widget(main);r.tabs=widget(tabs);r.tabs.tabHeight=28;r.tabs.viewList={{name='Display'},{name='Audio'}}
 r.tabs.activeView=r.tabs.viewList[2];r:addChild(r.tabs)
 local p=widget(ISPanelJoypad);p.prerender=main.subPanelPreRender;p.render=main.subPanelRender;r.tabs:addChild(p)
 r.page=p;r.backButton=widget(button);r:addChild(r.backButton)
 return r
end
local shared=widget(ISPanel)
local popupPre,popupRender=shared.prerender,shared.render
shared.prerender=function(self)
 self.lastBackground=self.backgroundColor
 self.lastHighlight=self.parentCombo.backgroundColorMouseOver
 self:drawRectBorderStatic(-1,-1,self:getWidth()+2,self:getHeight()+2,.8,1,1,1)
 if self.fail then error('popup failure') end
 return 'popup-pre'
end
shared.render=function(self) if self.failRender then error('popup render failure') end;return 'popup-render' end
combo.SharedPopup=shared
combo.showPopup=function(self) shared.parentCombo=self;return 'popup-open' end
local r=root();MainScreen.instance={mainOptions=r};local p=r.page
local controls={}
for _,c in ipairs({button,combo,ISTickBox,ISTextEntryBox,ISSliderPanel,ISVolumeControl,ISMegaVolumeControl}) do
 local w=widget(c);p:addChild(w);controls[#controls+1]=w
end
local swatch=widget(button);swatch.title='';p:addChild(swatch);local swatchColor=swatch.backgroundColor
local foreign=widget(panel);foreign.render=function() return 'custom-panel' end
local foreignChild=widget(button);foreign:addChild(foreignChild);p:addChild(foreign)
local customButton=widget(button);customButton.render=function() return 'custom-button' end;p:addChild(customButton)
local nativePre,nativeRender,nativeButtonPre=main.prerender,main.render,button.prerender
local rows={controls[1],controls[2]};p.joypadButtonsY={rows}
local cbCalls=0
local callback=function(owner,w,a,b) assert(owner==p and w==controls[1] and a==3 and b==5);cbCalls=cbCalls+1 end
controls[1].target=p;controls[1].onclick=callback
local originalTab=r.tabs.activeView;local pagePre,pageRender=p.prerender,p.render
local S=require 'B47ANCEDUI/NativeSettings'
assert(r.b47NativeSettingsOwner==r and #handlers==3)
assert(main.prerender==nativePre and main.render==nativeRender and button.prerender==nativeButtonPre)
-- The adapter never stores a replacement native class method.
assert(button.prerender~=controls[1].prerender and panel.render==popupRender)
assert(not foreign.b47NativeSettingsOwner and not foreignChild.b47NativeSettingsOwner and not customButton.b47NativeSettingsOwner)
assert(not swatch.b47NativeSettingsOwner and swatch.backgroundColor==swatchColor)
local wrapped=r.prerender;for _,fn in ipairs(handlers) do fn() end;assert(r.prerender==wrapped)
assert(r:prerender()=='native-pre' and calls[r]==1 and r.backgroundColor.a==.99)
assert(r.backgroundColor.r==T.colors.window.r and r.backgroundColor.g==T.colors.window.g)
for _,w in ipairs(controls) do
 assert(w.b47NativeSettingsOwner==r and w.font==UIFont.Medium and w.width==240 and w.height==32 and w.x==23 and w.y==42)
 assert(w.selected==2 and w.scrollY==-200 and w.options[2]=='Two')
 assert(w:prerender()=='native-pre' and calls[w]==1)
end
assert(controls[1].backgroundColor.r==T.colors.raised.r and controls[2].backgroundColor.r==T.colors.panel.r)
assert(controls[1].borderColor.r==T.colors.border.r and controls[1].textColor.r==T.colors.text.r)
assert(controls[1].backgroundColor~=T.colors.raised and controls[1].backgroundColor~=controls[2].backgroundColor)
controls[1].backgroundColor.r=.99;assert(T.colors.raised.r~=.99);controls[1]:prerender()
assert(p.joypadButtonsY[1]==rows and r.tabs.activeView==originalTab)
p:prerender();assert(p.stencil and calls[p]==1);p:render();assert(not p.stencil)
assert(p.render~=pageRender and p.prerender~=pagePre)
assert(cbCalls==0);controls[1].onclick(controls[1].target,controls[1],unpack(controls[1].onClickArgs));assert(cbCalls==1)
-- Existing native actions remain exact function objects, including their state handling.
local applied,rolledBack=0,0
r.backButton.onclick=function() rolledBack=rolledBack+1 end
r.saveButton=widget(button);r.saveButton.onclick=function() applied=applied+1 end;r:addChild(r.saveButton)
local action=r.saveButton.onclick;r.saveButton:prerender();assert(applied==0 and rolledBack==0)
assert(r.saveButton.onclick==action);r.saveButton.onclick();r.backButton.onclick();assert(applied==1 and rolledBack==1)
-- Late page/control additions use the original addChild result and require no tick walk.
local late=widget(button);assert(p:addChild(late)==late and late.b47NativeSettingsOwner==r)
local unknown=widget(panel);unknown.Type='ForeignPanel';p:addChild(unknown);assert(not unknown.b47NativeSettingsOwner)
local newTabs=widget(tabs);newTabs.tabHeight=28;newTabs.viewList={{name='Display'},{name='Audio'}};newTabs.activeView=newTabs.viewList[1]
r.tabs=newTabs;r:addChild(newTabs);assert(newTabs.b47NativeSettingsOwner==r)
local other=root();assert(S.apply(other) and other.b47NativeSettingsOwner==other)
local fake=widget(main);fake.tabs=widget(tabs);fake.prerender=function() end;assert(not S.apply(fake))
-- Selected/hover tab textures are intercepted only on this native settings instance.
draws={};newTabs:drawTextureScaled(tabs.tabSelected,1,0,120,27,1,1,1,1)
assert(#draws>1 and draws[#draws][4]==2 and tabs.tabSelected~=nil)
draws={};newTabs:drawTextureScaled(tabs.tabSelected,122,0,120,27,.2,1,1,1)
assert(draws[#draws][4]~=2,'Inactive hover gained an active underline')
newTabs.parent=nil;draws={};newTabs:drawTextureScaled(tabs.tabSelected,1,0,120,27,1,1,1,1)
assert(#draws==1 and draws[1][1]==tabs.tabSelected,'Detached tab still adopted');newTabs.parent=r
-- Popup identity/capture/ownership remain native. Temporary palette restores on all paths.
local drop=controls[2];local savedBg,savedBorder=shared.backgroundColor,shared.borderColor
local savedDrawBorder=shared.drawRectBorderStatic
assert(drop:showPopup()=='popup-open' and shared.parentCombo==drop)
assert(shared:prerender()=='popup-pre' and shared:render()=='popup-render')
assert(shared.lastBackground.a==.99 and shared.lastHighlight==drop.backgroundColorMouseOver)
assert(shared.backgroundColor==savedBg and shared.borderColor==savedBorder and shared.selectionColor==nil and shared.drawRectBorderStatic==savedDrawBorder)
shared.fail=true;assert(not pcall(shared.prerender,shared));assert(shared.backgroundColor==savedBg and shared.drawRectBorderStatic==savedDrawBorder);shared.fail=false
shared.failRender=true;assert(not pcall(shared.render,shared));assert(shared.backgroundColor==savedBg and shared.drawRectBorderStatic==savedDrawBorder);shared.failRender=false
local foreignDrop=widget(combo);shared.parentCombo=foreignDrop;shared:prerender()
assert(shared.lastBackground==savedBg and shared.lastHighlight==foreignDrop.backgroundColorMouseOver)
shared.parentCombo=drop
-- Moving the adopted combo outside its options root disables borrowed popup styling.
local origOwner=drop.parent;drop.parent=nil
assert(shared:prerender()=='popup-pre' and shared.lastBackground==savedBg);drop.parent=origOwner
-- Live accents and focus never change values or invoke callbacks.
U.Appearance.setAccent(0,'#336699','B47ANCEDUI')
local slider=controls[5];slider.joypadFocused=true;slider:prerender()
assert(slider.sliderColor.r==.2 and slider.sliderColor.g==.4 and slider.sliderColor.b==.6)
assert(slider.sliderMouseOverColor.r>.2 and slider.selected==2 and cbCalls==1)
controls[1].joypadFocused=true;controls[1]:prerender();assert(controls[1].borderColor.r==.2)
controls[1].joypadFocused=false;controls[1]:prerender();assert(controls[1].borderColor.r==T.colors.border.r)
local tick=controls[3];tick.tickTexture={};draws={};tick:drawTextureScaled(tick.tickTexture,0,0,12,12,1,0,1,0)
assert(draws[1][7]==.2 and draws[1][8]==.4 and draws[1][9]==.6)
tick.enable=false;draws={};tick:drawTextureScaled(tick.tickTexture,0,0,12,12,1,0,1,0)
assert(draws[1][7]==T.colors.disabled.r and tick.enable==false);tick.enable=true
tick.parent=nil;draws={};tick:drawTextureScaled(tick.tickTexture,0,0,12,12,1,0,1,0)
assert(draws[1][7]==0 and draws[1][8]==1);tick.parent=p
-- The transient native volume drawing shim propagates errors and removes itself.
local vol=controls[6];local beforeDraw=vol.drawRect;assert(vol:render()=='native-render' and vol.drawRect==beforeDraw)
vol.fail=true;assert(not pcall(vol.render,vol) and vol.drawRect==beforeDraw);vol.fail=false
vol.parent=nil;draws={};vol:render();assert(draws[1][6]==.5 and vol.backgroundColor.r==.2);vol.parent=p
controls[1].parent=nil;controls[1]:prerender();assert(controls[1].backgroundColor.r==.2)
draws={};controls[1]:drawRect(0,0,240,32,1,.5,.5,.5);assert(#draws==1);controls[1].parent=p
controls[1]:prerender();controls[1].parent=nil
local replacementColor={r=.7,g=.2,b=.8,a=.9};controls[1].backgroundColor=replacementColor
controls[1]:prerender();controls[1]:render();assert(controls[1].backgroundColor==replacementColor,'Detached restoration overwrote the new owner palette')
assert(main.prerender==nativePre and main.render==nativeRender and cbCalls==1)
-- Reproduce deferred Options creation: lifecycle fires before tabs exist.
local deferred=root();local builtTabs=deferred.tabs;deferred.tabs=nil;deferred.children={};builtTabs.parent=nil
deferred.create=function(self)self.tabs=builtTabs;self:addChild(builtTabs);return 'native-created',nil,'tail' end
MainScreen.instance={mainOptions=deferred}
for _,fn in ipairs(handlers) do fn() end
assert(not deferred.b47NativeSettingsOwner,'Fixture unexpectedly built deferred Options')
local first,middle,last=deferred:create()
assert(first=='native-created' and middle==nil and last=='tail','Construction observer changed native returns')
assert(deferred.b47NativeSettingsOwner==deferred and builtTabs.b47NativeSettingsOwner==deferred,'Deferred Options creation left the screen vanilla')
local Lifecycle=U.OptionsLifecycle;local attempts=0
Lifecycle.register('fixture-count',function()attempts=attempts+1 end)
local savedDeferredPre=deferred.prerender;local seen=attempts
for i=1,5 do deferred:prerender() end
assert(attempts==seen and deferred.prerender==savedDeferredPre,'Ready callbacks repeated every frame')
local rebuilt=root().tabs;deferred.tabs=rebuilt;deferred:addChild(rebuilt);deferred:prerender()
assert(rebuilt.b47NativeSettingsOwner==deferred and attempts==seen+1,'Rebuilt tabs not observed')
deferred:prerender();assert(attempts==seen+1)
-- Some deferred builders call a saved construction function inside prerender.
local lazy=root();local lazyTabs=lazy.tabs;lazy.children={};lazy.tabs=nil;lazyTabs.parent=nil
local classPre=main.prerender
main.prerender=function(self,...)
 if self==lazy and not self.tabs then self.tabs=lazyTabs;self:addChild(lazyTabs) end
 return classPre(self,...)
end
MainScreen.instance={mainOptions=lazy};for _,fn in ipairs(handlers)do fn()end
assert(not lazy.b47NativeSettingsOwner)
assert(lazy:prerender()=='native-pre' and lazy.b47NativeSettingsOwner==lazy and lazyTabs.b47NativeSettingsOwner==lazy)
main.prerender=classPre
-- An unknown instance renderer is still guarded after observation.
local guarded=root();guarded.prerender=function()return 'custom-pre',nil,'tail'end
assert(Lifecycle.observe(guarded) and not guarded.b47NativeSettingsOwner)
local a,b,c=guarded:prerender();assert(a=='custom-pre' and b==nil and c=='tail' and not guarded.b47NativeSettingsOwner)
local failure=root();failure.tabs=nil;failure.create=function()error('native construction failure')end
Lifecycle.observe(failure);assert(not pcall(failure.create,failure) and not failure.b47NativeSettingsOwner)
local failedListener
Lifecycle.register('fixture-listener-error',function(owner)if owner==failedListener then error('listener failure')end end)
failedListener=root();local retry=failedListener
assert(not pcall(Lifecycle.observe,retry) and not retry.b47OptionsLifecycle.busy,'Listener failure was swallowed or left observer busy')
failedListener=nil;assert(Lifecycle.observe(retry) and retry.b47NativeSettingsOwner==retry)
package.loaded['B47ANCEDUI/NativeSettings']=nil
assert(require('B47ANCEDUI/NativeSettings')==S and #handlers==3,'Reload stacked lifecycle registrations')
print('PASS OFFLINE native settings instances, geometry/fonts, callbacks/stencil, lifecycle/late children, scoped popup restoration, live accents and native value ownership')

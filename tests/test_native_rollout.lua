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
 self:drawRect(4,0,self.width-5,self.height,.8,0,0,0)
 if self.vertical then self:drawRectBorder(3,0,self.width-4,self.height,.6,.4,.4,.4)
 else self:drawRectBorder(0,3,self.width,self.height-4,.6,.4,.4,.4)end
 self:drawTexture(self.uptex,self.vertical and 4 or 0,self.vertical and 0 or 5,1,1,1,1)
 self:drawTexture(self.downtex,self.vertical and 4 or self.width-20,self.vertical and self.height-20 or 5,1,1,1,1)
 self:drawTextureScaled(self.midtex,self.barx+2,self.bary+2,self.barwidth-4,self.barheight-4,self.scrolling and 1 or self.hover and .95 or .9,.9,.9,1)
 self:drawTexture(self.toptex,self.barx,self.bary,.9,.9,.9,1)
 self:drawTexture(self.bottex,self.barx,self.bary+self.barheight-3,.9,.9,.9,1)
 if self.fail then error('scroll failure')end
 return nil,'scroll',13
end
for _,vertical in ipairs({true,false})do
 local scroll=widget(ISScrollBar);scroll.vertical=vertical
 for _,key in ipairs({'uptex','downtex','toptex','midtex','bottex'})do scroll[key]={}end
 H.flush()
 local _,sr,sn=scroll:render();assert(sr=='scroll'and sn==13 and scroll.barwidth==(vertical and 8 or 36))
 assert(not find(scroll,function(d)return d[1]=='drawTexture'end),'Vanilla scrollbar caps/arrows still drawn')
 assert(not find(scroll,function(d)return d[1]=='drawTextureScaled'and d[2]==scroll.midtex end),'Scrollbar thumb not themed')
 scroll.fail=true;assert(not pcall(scroll.render,scroll)and rawget(scroll,'drawTextureScaled')==nil,'Scroll error left override')
 scroll.fail=false;scroll.draws={};scroll.hover=true;scroll:render()
 assert(find(scroll,function(d)return d[1]=='drawRect'and d[7]==U.Theme.colors.scrollThumbHover.r end),'Thumb hover channel missed')
 local unknownParent=widget(class('ScrollProvider'));unknownParent:addChild(scroll);H.flush();scroll.draws={};scroll:render()
 assert(find(scroll,function(d)return d[1]=='drawTexture'and d[2]==scroll.uptex end),'Custom provider barrier lost')
 local owned=widget(ISPanel);owned.b47Styled=true;owned.b47Kind='panel';owned:addChild(scroll);H.flush();scroll.draws={};scroll:render()
 assert(not find(scroll,function(d)return d[1]=='drawTexture'end),'Public-control native scrollbar missed')
 U.excludeNativeTheme(owned);scroll.draws={};scroll:render()
 assert(find(scroll,function(d)return d[1]=='drawTexture'end),'Scrollbar opt-out ignored')
 U.excludeNativeTheme(owned,false);local outer=widget(ISPanel);outer:addChild(owned);U.excludeNativeTheme(outer);H.flush();scroll.draws={};scroll:render()
 assert(find(scroll,function(d)return d[1]=='drawTexture'end),'Higher ancestor opt-out ignored by API scrollbar')
end
local priorLifecycle=U.OptionsLifecycle
U.OptionsLifecycle={nativeRenderer=function(w)return w==options end}
local optionsScroll=widget(ISScrollBar);optionsScroll.vertical=true;optionsScroll.midtex={};optionsScroll.uptex={}
options:addChild(optionsScroll);H.flush();assert(optionsScroll.b47NativeTheme,'Protected native Options scrollbar missed')
optionsScroll.draws={};optionsScroll:render();assert(not find(optionsScroll,function(d)return d[1]=='drawTexture'end),'Options scrollbar retained vanilla chrome')
local foreignScroll=widget(ISScrollBar);foreignScroll.render=function()end;options:addChild(foreignScroll);H.flush();assert(not foreignScroll.b47NativeTheme,'Custom scrollbar renderer overwritten')
U.OptionsLifecycle=priorLifecycle
local sharedBar=widget(ISScrollBar);sharedBar.vertical=true;sharedBar.midtex={};sharedBar.uptex={};popup2:addChild(sharedBar);H.flush()
U.excludeNativeTheme(combo);sharedBar:render();assert(find(sharedBar,function(d)return d[1]=='drawTexture'end),'Shared dropdown owner opt-out ignored by scrollbar')
U.excludeNativeTheme(combo,false)
local nativeScrollRoot=widget(ISPanel);local movedBar=widget(ISScrollBar);movedBar.vertical=true;movedBar.midtex={};movedBar.uptex={};nativeScrollRoot:addChild(movedBar);H.flush()
local consumer=widget(ISPanel);consumer.b47Styled=true;consumer.b47Kind='panel';consumer.b47AppearanceScope='BarConsumer';consumer:addChild(movedBar);H.flush()
local scopedBook=U.StylePresets.set(U.StylePresets.new(),'default','BarConsumer','scrollbar','scrollThumb','#123456');local scopedOwner={}
assert(U.StylePresets.preview(0,scopedBook,scopedOwner));movedBar.draws={};movedBar:render()
assert(not find(movedBar,function(d)return d[1]=='drawTexture'end),'Native-to-API reparent left stale activation')
assert(find(movedBar,function(d)return d[1]=='drawRect'and U.NativePresentation.equal(d[7],0x12/255)and U.NativePresentation.equal(d[8],0x34/255)end),'Consumer scrollbar preset scope lost')
U.StylePresets.clearPreview(0,scopedOwner)
print('PASS OFFLINE broad native lifecycle, deferred/late children, frontend/gameplay/specialist roots, owner guards, palette/error restoration, semantic colour, player presets, tabs and shared dropdowns')

-- Distinct pressed/disabled/focus channels reach actual native draw calls.
local colors=U.StylePresets.new();local cp=U.StylePresets
for key,value in pairs({disabledBorder='#123456',focusOuter='#234567',pressed='#345678',hover='#AA4433',radius=0})do colors=cp.set(colors,'default','*','button',key,value)end
local colorOwner={};assert(cp.preview(0,colors,colorOwner))
local painters=U.NativePainters
local colorButton=widget(ISButton);colorButton.enable=false
local function borderOnly(self)self:drawRectBorder(0,0,self.width,self.height,1,.4,.4,.4)end
painters.paint(colorButton,borderOnly,'button')
assert(find(colorButton,function(d)return d[1]=='drawRectBorder'and d[7]==0x12/255 and d[8]==0x34/255 end),'Native enable=false missed disabledBorder')
colorButton.joypadFocused=true;colorButton.draws={};painters.paint(colorButton,borderOnly,'button')
assert(find(colorButton,function(d)return d[7]==0x23/255 and d[8]==0x45/255 end),'Disabled border masked controller focus')
colorButton.pressed=true;colorButton.fade={fraction=function()return .5 end};colorButton.backgroundColorMouseOver={r=.4,g=.4,b=.4,a=1};colorButton.draws={}
painters.paint(colorButton,function(self)local c=self.backgroundColorMouseOver;self:drawRect(0,0,self.width,self.height,1,c.r,c.g,c.b)end,'button')
local bg=U.ComponentStyles.color({b47StyleFamily='button'},U.Theme.colors.raised)
assert(find(colorButton,function(d)return math.abs(d[7]-(0x34/255*.5+bg.r*.5))<.000001 end),'Pressed colour lost when hover was nonneutral')
local oldButtonPre=rawget(ISButton,'prerender');ISButton.prerender=borderOnly
local dedicated=widget(ISButton);dedicated.enable=false
assert(U.NativePresentation.button(dedicated,0,function()return true end));dedicated:prerender()
assert(find(dedicated,function(d)return d[7]==0x12/255 and d[8]==0x34/255 end),'Dedicated handler missed disabled border')
ISButton.prerender=oldButtonPre
cp.clearPreview(0,colorOwner)
print('PASS OFFLINE native disabled/focus precedence, colored-hover pressed fade and dedicated button border channels')
local localClass=setmetatable({Type='ModePanel'},ISPanel);localClass.__index=localClass
local mode=widget(localClass);local owner=widget(NewGameScreen);owner.panels={mode};owner:addChild(mode)
local control=widget(ISComboBox);mode:addChild(control);H.flush()
assert(mode.b47NativeTheme and control.b47NativeTheme,'Verified local owner slot did not adopt: '..tostring(owner.b47NativeTheme)..'/'..tostring(mode.b47NativeTheme)..'/'..tostring(control.b47NativeTheme))
local impostor=widget(localClass);local extra=widget(ISComboBox);impostor:addChild(extra);H.flush()
assert(not impostor.b47NativeTheme and not extra.b47NativeTheme,'Matching local type adopted without owner slot')
local selection=widget(ISPanel);selection.selectionColor={r=.7,g=.35,b=.15,a=.3};local original=selection.selectionColor
painters.paint(selection,function(self)local c=self.selectionColor;self:drawRect(0,4,self.width,20,c.a,c.r,c.g,c.b);self:drawRect(7,9,8,6,.5,1,0,0)end,'list')
assert(selection.selectionColor==original and find(selection,function(d)return d[2]==7 and d[7]==1 and d[8]==0 end),'Semantic content or palette identity changed')
assert(find(selection,function(d)return d[2]==0 and d[7]~=.7 end),'Native selection palette stayed orange')
print('PASS OFFLINE known local owner slots, foreign lookalikes, selected-row palette and semantic-content preservation')
-- Literal native row paint must be replaced without recoloring nearby content.
selection.draws={}
local function literal(self)
 self:drawRect(0,8,self.width,20,.3,.7,.35,.15)
 self:drawRect(0,32,self.width-1,20,.3,.7,.35,.15)
 if self.fail then error('row failure')end
end
painters.paint(selection,literal,'list')
assert(selection.draws[1][7]~=.7 and selection.draws[2][7]==.7,'Literal selection match was missing or too broad')
selection.fail=true;assert(not pcall(painters.paint,selection,literal,'list')and rawget(selection,'drawRect')==nil)
selection.fail=false
-- Concrete local owner slots, including identically named Host/Workshop pages.
class('ISScrollingListBox');class('SandboxOptionsScreen');class('WorkshopSubmitScreen');class('ServerSettingsScreen');class('BaseServerSettingsPanel',ISPanelJoypad)
WorkshopSubmitScreen.Type='WorkshopSubmit'
class('CharacterCreationProfession');class('CoopCharacterCreationProfession',CharacterCreationProfession)
local function localType(name,parent)local c=setmetatable({Type=name},parent);c.__index=c;return c end
local function localWidget(name,parent)return widget(localType(name,parent))end
local function attached(owner,field,w)owner[field]=w;owner:addChild(w);return w end
local sandbox=widget(SandboxOptionsScreen)
local list=attached(sandbox,'listbox',localWidget('SandboxOptionsScreenListBox',ISScrollingListBox))
local form=localWidget('SandboxOptionsScreenPanel',ISPanelJoypad);list.items={{item={panel=form}}};sandbox:addChild(form)
local advanced=localWidget('SandboxAdvancedControl',ISPanel);sandbox.controls={advanced};form:addChild(advanced)
local workshop=widget(WorkshopSubmitScreen);local page=attached(workshop,'page2',localWidget('Page2',ISPanelJoypad))
local tags=attached(page,'tags',localWidget('TagsList',ISScrollingListBox))
local load2=widget(LoadGameScreen)
local info=attached(load2,'infoPanel',localWidget('LoadGameScreen_InfoPanel',ISPanelJoypad))
local config=attached(load2,'configPanel',localWidget('LoadGameScreen_ConfigPanel',ISPanelJoypad))
local bad=attached(load2,'other',localWidget('Page2',ISPanelJoypad));load2.infoPanel=bad
local coop=widget(CoopCharacterCreationProfession)
local prof=attached(coop,'listboxProf',localWidget('CharacterCreationProfessionListBox',ISScrollingListBox))
H.flush()
for _,w in ipairs({list,form,advanced,page,tags,config,prof})do assert(w.b47NativeTheme,'Verified local scope missed: '..w.Type)end
assert(not bad.b47NativeTheme and not info.b47NativeTheme,'Wrong local owner slot accepted')
local custom=localWidget('TagsList',ISScrollingListBox);custom.render=function()end;page.tags=custom;page:addChild(custom);H.flush();assert(not custom.b47NativeTheme,'Local instance renderer overwritten')
local host=widget(ServerSettingsScreen)
local edit=attached(host,'pageEdit',localWidget('Page3',ISPanelJoypad))
local newPage=attached(host,'pageNew',localWidget('Page2',BaseServerSettingsPanel))
local columns=localType('MultiColumnPanelJoypad',ISPanelJoypad)
local regions=localWidget('SpawnRegionsPanel',columns);edit.listbox={items={{item={panel=regions}}}};edit:addChild(regions)
local listBase=localType('ServerSettingsScreenBaseListBox',ISScrollingListBox)
local regionList=attached(regions,'listbox',localWidget('SpawnRegionsListBox',listBase))
H.flush();assert(edit.b47NativeTheme and newPage.b47NativeTheme and regions.b47NativeTheme and regionList.b47NativeTheme,'Host owned local scope missed')
assert(regionList.b47NativeTheme.kind=='list','Host list received a frame painter')
local wrong=attached(host,'pageRename',localWidget('Page5',ISPanelJoypad));H.flush();assert(not wrong.b47NativeTheme,'Host Page5 wrong base accepted')
print('PASS OFFLINE literal row matching, full local base chains, Sandbox/Workshop/Load/Coop/Host scopes and foreign renderer/slot guards')
class('RWMElement',ISPanelJoypad)
local radio=widget(RWMElement);radio.fontheightMed=18;radio.buttonTexture={};radio.deviceTexture={};radio.isExpanded=true
local callback=function()end;radio.headerButton={onclick=callback}
local function radioDraw(self)
 self:drawTextureScaled(self.buttonTexture,0,0,self.width,20,1,1,1,1)
 self:drawTextureScaled(self.deviceTexture,0,24,32,32,1,1,1,1)
 self:drawTextureScaled(self.buttonTexture,1,0,self.width,20,1,1,1,1)
 self:drawRect(3,50,12,12,1,0,1,0)
 if self.fail then error('radio draw failure')end
end
painters.paint(radio,radioDraw,'frame')
assert(not find(radio,function(d)return d[1]=='drawTextureScaled'and d[2]==radio.buttonTexture and d[3]==0 end),'Radio header stayed metallic')
assert(find(radio,function(d)return d[2]==radio.deviceTexture end)and find(radio,function(d)return d[2]==radio.buttonTexture and d[3]==1 end),'Radio content texture replaced')
assert(find(radio,function(d)return d[1]=='drawRect'and d[2]==3 and d[8]==1 end)and radio.isExpanded and radio.headerButton.onclick==callback,'Radio input/semantic state changed')
radio.fail=true;assert(not pcall(painters.paint,radio,radioDraw,'frame')and rawget(radio,'drawTextureScaled')==nil,'Radio exception leaked drawing shim')
local ordinary=widget(ISPanel);ordinary.fontheightMed=18;ordinary.buttonTexture=radio.buttonTexture;ordinary.deviceTexture={};painters.paint(ordinary,radioDraw,'frame')
assert(find(ordinary,function(d)return d[2]==ordinary.buttonTexture and d[3]==0 end),'Generic frame header texture replaced')
print('PASS OFFLINE exact native radio header chrome, content/semantic/input preservation and exception restoration')
class('DebugScenarios',ISPanel)
local scenarios=widget(DebugScenarios);scenarios.width=500;scenarios.height=500;scenarios.parent=menu;DebugScenarios.instance=scenarios
scenarios.backgroundColor={r=0,g=.05,b=.1,a=1};scenarios.getMaxDrawHeight=function(self)return self.clip end
scenarios.onMouseMove=callback;local scenarioBackground=scenarios.backgroundColor
local function scenarioDraw(self)
 local h=self:getMaxDrawHeight();if h==-1 then h=self:getHeight()end
 self:drawRectStatic(0,0,self.width,h,1,0,.05,.1)
 self:drawRectBorderStatic(0,0,self.width,h,.7,1,1,1)
 self:drawRectStatic(3,8,20,10,1,0,.05,.1)
 if self.fail then error('scenario failure')end
 return nil,'scenario',19
end
for _,clip in ipairs({40,500,-1})do
 scenarios.clip=clip;scenarios.draws={};local hole,label,n=painters.paint(scenarios,scenarioDraw,'frame')
 assert(hole==nil and label=='scenario'and n==19)
 assert(not find(scenarios,function(d)return d[2]==0 and d[3]==0 and d[7]==0 and d[8]==.05 and d[9]==.1 end),'Scenario native blue backing retained')
 assert(find(scenarios,function(d)return d[2]==3 and d[7]==0 and d[8]==.05 and d[9]==.1 end),'Scenario blue content recolored')
 assert(scenarios.clip==clip and scenarios.width==500 and scenarios.height==500 and scenarios.x==10 and scenarios.onMouseMove==callback and scenarios.backgroundColor==scenarioBackground)
end
scenarios.fail=true;assert(not pcall(painters.paint,scenarios,scenarioDraw,'frame')and rawget(scenarios,'drawRectStatic')==nil and scenarios.backgroundColor==scenarioBackground);scenarios.fail=false
for _,other in ipairs({widget(ISPanel),widget(DebugScenarios),scenarios})do
 other.clip=40;other.getMaxDrawHeight=scenarios.getMaxDrawHeight;other.draws={};other.parent={}
 painters.paint(other,scenarioDraw,'frame')
 assert(find(other,function(d)return d[2]==0 and d[7]==0 and d[8]==.05 and d[9]==.1 end),'Foreign scenario-looking backing adopted')
end
print('PASS OFFLINE exact native Scenarios clipped backing, expansion state/callback/geometry preservation and foreign/error refusal')
class('ISImage',ISPanel)
local artwork=widget(ISImage);artwork.texture={};artwork.onclick=callback
artwork.drawText=function(self,...)self.draws[#self.draws+1]={'text',...}end
local function imageDraw(self)
 local c=self.backgroundColor
 self:drawTexture(self.texture,0,0,c.a,c.r,c.g,c.b)
 self:drawTextureScaled(self.texture,0,0,self.width,self.height,c.a,c.r,c.g,c.b)
 self:drawText('native image label',0,10,c.r,c.g,c.b,c.a)
 self:drawRectBorder(0,0,self.width,self.height,.7,1,1,1)
 if self.fail then error('image failure')end
 return nil,'artwork',23
end
for _,tint in ipairs({1,.4})do
 artwork.backgroundColor={r=tint,g=tint,b=tint,a=.8};artwork.draws={};local original=artwork.backgroundColor
 local hole,label,n=painters.paint(artwork,imageDraw,'frame')
 assert(hole==nil and label=='artwork'and n==23)
 assert(artwork.draws[1][6]==tint and artwork.draws[1][7]==tint and artwork.draws[1][8]==tint,'Native image tint changed')
 assert(artwork.draws[2][8]==tint and artwork.draws[2][9]==tint and artwork.draws[2][10]==tint,'Scaled native image tint changed')
 assert(artwork.draws[3][5]==tint and artwork.backgroundColor==original and artwork.onclick==callback and artwork.width==280)
 artwork.fail=true;assert(not pcall(painters.paint,artwork,imageDraw,'frame')and artwork.backgroundColor==original and rawget(artwork,'drawTextureScaled')==nil);artwork.fail=false
end
print('PASS OFFLINE native image white/grey artwork and label tint, callbacks/geometry and exception restoration')
for _,spec in ipairs({{'ISComponentsListPanel','container'},{'ISWidgetIngredientsInputs','panel'}})do
 local ownerClass=class(spec[1],ISPanel);local slotName=spec[2]
 ownerClass.createChildren=function(self)
  local child=widget(ISPanel);self[slotName]=child;self:addChild(child)
  child.prerender=function(s)s.stencil=(s.stencil or 0)+1;return base.prerender(s)end
  child.render=function(s)s.cleared=(s.cleared or 0)+1;return nil,'clear',29 end
  local action=widget(ISButton);action.title='Native component action';action.onclick=callback;child:addChild(action);self.action=action
  return nil,'children',31
 end
 local owner=widget(ownerClass);owner.usingPlayer={};local using=owner.usingPlayer
 local hole,label,n=owner:createChildren();assert(hole==nil and label=='children'and n==31)
 local child=owner[slotName];H.flush();assert(child.b47NativeTheme and owner.action.b47NativeTheme,'Native stencil subtree excluded')
 child:prerender();local a,b,c=child:render();assert(a==nil and b=='clear'and c==29 and child.stencil==1 and child.cleared==1)
 assert(owner.usingPlayer==using and owner.action.onclick==callback)
 assert(find(child,function(d)return d[7]==U.Theme.colors.window.r and d[8]==U.Theme.colors.window.g end),'Stencil panel not themed')
 child.prerender=function()end;owner.action.draws={};owner.action:prerender()
 assert(find(owner.action,function(d)return d[1]=='drawRectStatic'and d[7]==0 and d[8]==0 end),'Foreign replacement inherited native stencil authority')
 owner:createChildren();H.queue(owner);H.flush();assert(owner[slotName]~=child and owner[slotName].b47NativeTheme,'Rebuilt native stencil not captured')
 local wrapper=ownerClass.createChildren;ownerClass.createChildren=function(self,...)return wrapper(self,...)end
 local foreign=widget(ownerClass);foreign:createChildren();H.flush();assert(not foreign[slotName].b47NativeTheme and not foreign.action.b47NativeTheme,'Foreign builder outputs stamped native')
 ownerClass.createChildren=wrapper
 local detached=widget(ownerClass);detached:createChildren();local orphan=detached[slotName];orphan.parent={};H.flush();assert(not orphan.b47NativeTheme,'Detached native slot adopted')
end
local textured=widget(ISButton);textured.textureBackground={};textured.iconTexture={}
local function textureDraw(self)
 self:drawTextureScaled(self.textureBackground,0,0,self.width,self.height,.6,1,1,1)
 self:drawTextureScaled(self.textureBackground,1,1,8,8,1,1,1,1)
 self:drawTextureScaled(self.iconTexture,0,0,self.width,self.height,1,1,1,1)
end
painters.paint(textured,textureDraw,'button')
assert(#textured.draws==2 and textured.draws[1][3]==1 and textured.draws[2][2]==textured.iconTexture,'Native button background texture/content scope failed')
print('PASS OFFLINE native stencil builder provenance/returns/cleanup, replacement and rebuild boundaries, and native button texture scope')
class('ISStringListView',ISPanel)
local function nativeColour(r,g,b)return {getRedFloat=function()return r end,getGreenFloat=function()return g end,getBlueFloat=function()return b end}end
Colors={Black=nativeColour(0,0,0),DimGray=nativeColour(.41,.41,.41),Crimson=nativeColour(.86,.08,.24),DarkOrange=nativeColour(1,.55,0),
 DarkGreen=nativeColour(0,.39,0),Purple=nativeColour(.5,0,.5),Violet=nativeColour(.93,.51,.93),Magenta=nativeColour(1,0,1),
 MediumBlue=nativeColour(0,0,.8),ForestGreen=nativeColour(.13,.55,.13),Khaki=nativeColour(.94,.9,.55),LemonChiffon=nativeColour(1,.98,.8)}
ISStringListView.drawInfoList=function()end
local codeOwner=widget(ISStringListView);local code=attached(codeOwner,'infoList',widget(ISScrollingListBox))
code.target=codeOwner;code.doDrawItem=ISStringListView.drawInfoList;code.node={keyCol=Colors.Black,valCol=Colors.DarkGreen,expanded=true,isNeedle=true}
code.drawText=function(self,...)self.draws[#self.draws+1]={'text',...}end
local codeRaw=code.drawText;local keyIdentity=code.node.keyCol;local valueIdentity=code.node.valCol
local names={'Black','DimGray','Crimson','DarkOrange','DarkGreen','Purple','Violet','Magenta','MediumBlue','ForestGreen'}
local function codeDraw(self)
 for i,name in ipairs(names)do local c=Colors[name];for j=1,2 do self:drawText(name,10,i*20,c:getRedFloat(),c:getGreenFloat(),c:getBlueFloat(),1,'Code')end end
 for _,name in ipairs({'LemonChiffon','Khaki'})do local c=Colors[name];self:drawRect(0,20,self.width,19,1,c:getRedFloat(),c:getGreenFloat(),c:getBlueFloat())end
 self:drawRectBorder(2,22,40,15,1,0,0,0)
 if self.fail then error('code viewer failure')end
 return nil,'native code',17
end
local hole,label,n=painters.paint(code,codeDraw,'list');assert(hole==nil and label=='native code'and n==17)
for i=1,20 do local d=code.draws[i];assert(d[1]=='text'and d[3]==10 and d[4]==math.ceil(i/2)*20 and d[9]=='Code');assert(math.max(d[5],d[6],d[7])>=.6,'Unreadable code text')end
assert(code.draws[1][5]==U.Theme.colors.text.r and code.draws[9][6]>code.draws[9][5],'Identifier/string palette lost')
assert(code.node.keyCol==keyIdentity and code.node.valCol==valueIdentity and code.node.expanded and code.node.isNeedle and code.drawText==codeRaw,'Code model/input mutated')
assert(not find(code,function(d)return d[1]=='drawRect'and d[7]==1 and d[8]==.98 end),'Light search highlight retained')
code.fail=true;assert(not pcall(painters.paint,code,codeDraw,'list')and code.drawText==codeRaw and rawget(code,'drawRect')==nil);code.fail=false
code.doDrawItem=function()end;code.draws={};painters.paint(code,codeDraw,'list');assert(code.draws[1][5]==0,'Foreign code row renderer recolored')
code.doDrawItem=ISStringListView.drawInfoList;code.target={};code.draws={};painters.paint(code,codeDraw,'list');assert(code.draws[1][5]==0,'Foreign code target recolored')
print('PASS OFFLINE owned code viewer readable syntax/search palette, native model/draw/input preservation, foreign refusal and exception restoration')
class('MultiplayerUI',ISPanelJoypad);class('ISMPTabPanel',ISPanel)
local mp=widget(MultiplayerUI);local mptabs=attached(mp,'tabs',widget(ISMPTabPanel));local page=widget(ISPanel);mptabs:addChild(page)
mp.serverInfoBluePanelColor={r=.05,g=.15,b=.25,a=.8};mp.serverListSelected={r=.7,g=.35,b=.15,a=.6}
mptabs.backgroundColorSelected={r=.7,g=.35,b=.15,a=.9}
local selected=mp.serverListSelected;local blue=mp.serverInfoBluePanelColor;local tabColor=mptabs.backgroundColorSelected
MultiplayerUI.drawAccountListItem=function(self)
 local c=self.parent.parent.parent.serverListSelected;self:drawRect(65,20,self.width-65,30,c.a,c.r,c.g,c.b)
 if self.fail then error('mp row failure')end
 return nil,'native row',19
end
local accounts=widget(ISScrollingListBox);page:addChild(accounts);mp.accountList=accounts;accounts.doDrawItem=MultiplayerUI.drawAccountListItem;accounts.onclick=callback
local hole,label,n=painters.paint(accounts,accounts.doDrawItem,'list');assert(hole==nil and label=='native row'and n==19)
assert(accounts.draws[1][7]==U.Theme.colors.selected.r and mp.serverListSelected==selected and accounts.onclick==callback)
accounts.fail=true;assert(not pcall(painters.paint,accounts,accounts.doDrawItem,'list')and mp.serverListSelected==selected);accounts.fail=false
local function mpDraw(self)local c=self.serverInfoBluePanelColor;self:drawRect(20,30,90,60,c.a,c.r,c.g,c.b);if self.fail then error('mp failure')end;return nil,'native mp'end
painters.paint(mp,mpDraw,'frame');assert(mp.draws[1][7]==U.Theme.colors.raised.r and mp.serverInfoBluePanelColor==blue)
mp.fail=true;assert(not pcall(painters.paint,mp,mpDraw,'frame')and mp.serverInfoBluePanelColor==blue);mp.fail=false
painters.paint(mptabs,function(self)local c=self.backgroundColorSelected;self:drawRect(2,0,40,32,c.a,c.r,c.g,c.b)end,'frame')
assert(mptabs.draws[1][7]==U.Theme.colors.selected.r and mptabs.backgroundColorSelected==tabColor)
mp.accountList=nil;accounts.draws={};painters.paint(accounts,accounts.doDrawItem,'list');assert(accounts.draws[1][7]==selected.r,'Unowned MP row recolored')
class('ModInfoPanel',ISPanelJoypad);ModInfoPanel.Param=class('ModInfoPanelParam',ISPanelJoypad)
local info=widget(ModInfoPanel);local value=widget(ModInfoPanel.Param);value.type='Path';value.borderX=90;value.source='Mods';info:addChild(value);info.Path=value
value.drawText=function(self,...)self.draws[#self.draws+1]={'text',...}end
local textRaw=value.drawText
local function paramDraw(self)
 self:drawText('native value',100,2,.05,.45,.7,.9,'Small')
 self:drawRectBorder(100,15,80,1,.9,.05,.45,.7)
 self:drawText('red compatibility',100,2,.9,0,0,.9,'Small')
 if self.fail then error('param failure')end
 return nil,'native param',27
end
local hole,label,n=painters.paint(value,paramDraw,'frame');assert(hole==nil and label=='native param'and n==27)
assert(value.draws[1][5]==U.Theme.colors.text.r and value.draws[2][7]==U.Theme.colors.accentHover.r and value.draws[3][5]==.9 and value.draws[3][6]==0)
value.fail=true;assert(not pcall(painters.paint,value,paramDraw,'frame')and value.drawText==textRaw);value.fail=false
info.Path=nil;value.draws={};painters.paint(value,paramDraw,'frame');assert(value.draws[1][5]==.05,'Unowned mod metadata recolored')
print('PASS OFFLINE native MP chrome/owned rows and mod-path contrast, status preservation, returns, foreign slots and exception restoration')

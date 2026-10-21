-- Owned input callbacks exercised with UI doubles; native dispatch is a runtime gate.
getText=function(k)return k end
local fontHeight=14
getTextManager=function()return {getFontHeight=function()return fontHeight end,MeasureStringX=function(_,_,t)return #t*7 end}end
Keyboard={KEY_F10=10,KEY_ESCAPE=1,KEY_RETURN=2,KEY_TAB=3,KEY_LEFT=4,KEY_RIGHT=5,KEY_UP=6,KEY_DOWN=7}
Joypad={AButton=1,BButton=2,XButton=3,YButton=4}
local records,writes={},0
getFileReader=function(name,create)
 assert(not create);local text=records[name];if not text then return end
 local lines={};for line in text:gmatch('[^\n]+')do lines[#lines+1]=line end
 local i=0;return {readLine=function()i=i+1;return lines[i]end,close=function()end}
end
local function writer(name,create,append)
 assert(name=='B47ANCEDUI/main-menu-layout.txt' and create and not append)
 return {write=function(_,text)records[name]=text;writes=writes+1 end,close=function()end}
end
getFileWriter=writer
local function extend(class)
 class.initialise=function()end;class.instantiate=function()end
 class.getIsVisible=class.isVisible
 class.getChildren=function(self)return self.children end
 class.addChild=function(self,c)self.children[#self.children+1]=c;c.parent=self end
 class.removeChild=function(self,c)for i,v in ipairs(self.children)do if v==c then table.remove(self.children,i);break end end end
 class.bringToTop=function(self)self.onTop=true end
 class.setCapture=function(self,v)self.capture=v end
 class.drawRect=function()end;class.drawRectBorder=function()end;class.drawText=function()end
 class.drawTextZoomed=function()end;class.drawTextCentre=function()end;class.drawTextureScaled=function()end
end
for _,class in ipairs({ISPanel,ISPanelJoypad,ISButton,ISSliderPanel,ISTextEntryBox,ISComboBox})do extend(class)end
ISButton.setEnable=function(self,v)self.enable=v end
function ISTextEntryBox:new(text,x,y,w,h)
 local s=ISPanel:new(x,y,w,h);setmetatable(s,{__index=self});s.text=text;return s
end
ISTextEntryBox.setText=function(self,text)self.text=text;if self.onTextChangeFunction then self.onTextChangeFunction()end end
ISTextEntryBox.getInternalText=function(self)return self.text end
ISTextEntryBox.focus=function(self)self.focused=true end
ISTextEntryBox.unfocus=function(self)self.focused=false end
ISTextEntryBox.isFocused=function(self)return self.focused end
ISTextEntryBox.setEditable=function(self,v)self.editable=v end
ISPanelJoypad.insertNewLineOfButtons=function(self,...)self.joypadButtonsY[#self.joypadButtonsY+1]={...}end
ISPanelJoypad.restoreJoypadFocus=function(self,data)
 local child=self.joypadButtonsY[self.joypadIndexY or 1][self.joypadIndex or 1]
 self.initialFocus=child;child.joypadFocused=true;child.joyfocus=data
end
ISPanelJoypad.clearJoypadFocus=function(self)
 for _,row in ipairs(self.joypadButtonsY) do for _,b in ipairs(row) do b.joypadFocused=false end end
end
ISPanelJoypad.setJoypadFocus=function(self,child)
 for _,row in ipairs(self.joypadButtonsY) do for i,b in ipairs(row) do b.joypadFocused=b==child;if b==child then self.joypadIndex=i end end end
end
ISPanelJoypad.onJoypadDown=function(self,key)self.delegatedKey=key end
function ISSliderPanel:new(x,y,w,h,target,callback)
 local s=ISPanel:new(x,y,w,h);setmetatable(s,{__index=self});s.target=target;s.callback=callback;return s
end
ISSliderPanel.setValues=function(self,a,b,step)self.minimum=a;self.maximum=b;self.step=step end
ISSliderPanel.setCurrentValue=function(self,v,ignore)self.currentValue=v;if not ignore then self.callback(self.target,v,self)end end
ISSliderPanel.deactivateToolTip=function(self)self.tipClosed=true end
ISSliderPanel.paginate=function(self)self.sliderDim={x=0,y=0,w=5,h=self:getHeight()};self.sliderBarDim={x=0,y=self:getHeight()/2,w=self:getWidth(),h=2}end
ISSliderPanel.setDoButtons=function(self,v)self.doButtons=v;self:paginate()end
ISSliderPanel.onMouseDown=function(self)self.dragInside=true;return true end
ISSliderPanel.onMouseUp=function(self)self.dragInside=false;return true end
ISSliderPanel.onMouseUpOutside=ISSliderPanel.onMouseUp
local modal=false
UIManager={getMillisSinceLastRender=function()return 16 end,isModalVisible=function()return modal end}
local nativeKeys,nativeJoy,nativeCalls=0,0,0
MainScreen={prerender=function(self)nativeCalls=nativeCalls+1;self:drawTextureScaled(self.logoTexture,0,0,600,300,1,1,1,1)end,
 onKeyRelease=function()nativeKeys=nativeKeys+1 end,onJoypadDown=function()nativeJoy=nativeJoy+1 end}
package.loaded['OptionScreens/MainScreen']=MainScreen
ISLabel={onMouseDown=function()end};package.loaded['ISUI/ISLabel']=ISLabel
getTexture=function(path)return {path=path}end;getTimestampMs=function()return 1234 end
getSoundManager=function()return {getMusicVolume=function()return 0 end}end
local gameCallbacks={}
local function gameStart()for _,f in ipairs(gameCallbacks)do f()end end
Events={OnMainMenuEnter={Add=function()end},OnResetLua={Add=function()end},OnGameStart={Add=function(f)gameCallbacks[#gameCallbacks+1]=f end}}
local function makeScreen()
 local s=ISPanel:new(0,0,1920,1080);s.Type='MainScreen';s.prerender=MainScreen.prerender
 s.onKeyRelease=MainScreen.onKeyRelease;s.onJoypadDown=MainScreen.onJoypadDown;s.delay=-1;s.maxMenuItemWidth=240
 s.logoTexture={getWidth=function()return 600 end,getHeight=function()return 300 end}
 s.bottomPanel=ISPanel:new(0,0,300,300);s:addChild(s.bottomPanel)
 for i=1,12 do
  local label=ISPanel:new(0,i*50,250,20);label.Type='ISLabel';label.name='MENU '..i
  label.font=UIFont.Large;label.b47NativeMenu=true;label.b47MenuHasNote=i==8;s.bottomPanel:addChild(label)
 end
 return s
end
local main=makeScreen();MainScreen.instance=main
local data={focus=main};JoypadState={getMainMenuJoypad=function()return data end}
local focusUpdates=0;updateJoypadFocus=function()focusUpdates=focusUpdates+1 end
local B=require 'B47ANCEDUI/MenuBackground';local E=B47ANCEDUI.MenuLayoutEditor
local L=require 'B47ANCEDUI/MenuLayout'
assert(main.b47LayoutButton and main.b47HudLayoutButton and #main.children==3 and not B.apply(main))
assert(MainScreen.prerender~=main.prerender and MainScreen.onKeyRelease~=main.onKeyRelease)
local owned=main.prerender;main:prerender();local defaults=B.rectangles(main)
assert(math.abs(defaults.menu.x-main:getWidth()*.18)<.001 and math.abs(defaults.logo.y-main:getHeight()*.265)<.001,'Editor must begin from the approved built-in placement')
main:onJoypadDown(Joypad.YButton,data);assert(nativeJoy==1,'Vanilla Terms shortcut intercepted')
main:onKeyRelease(99);assert(nativeKeys==1)
main:onKeyRelease(Keyboard.KEY_F10);local state=main.b47LayoutEditing
assert(state and state==E.open(main) and #main.children==4 and data.focus==state.panel)
assert(state.panel.initialFocus==state.menuButton and #state.panel.joypadButtonsY==6,'Initial controller control not visibly focused')
assert(not main.b47LayoutButton.visible and state.root:onMouseDown() and state.root:onMouseDoubleClick())
local frame=state.frames.menu;frame:onMouseDown(30,30);assert(frame.capture)
frame:onMouseMove(70,30);frame:onMouseMoveOutside(10,20);frame:onMouseUpOutside()
local moved=B.rectangles(main)
assert(math.abs(moved.menu.x-defaults.menu.x-80)<.001 and math.abs(moved.menu.y-defaults.menu.y-50)<.001)
assert(moved.logo.x==defaults.logo.x and main.x==0 and main.y==0 and not frame.capture and writes==0)
E.select(main,'logo');local menuX=moved.menu.x;frame=state.frames.logo
frame:onMouseDown(frame:getWidth()-1,frame:getHeight()-1);frame:onMouseMove(80,40);frame:onMouseUp()
local resized=B.rectangles(main);assert(resized.logo.w>defaults.logo.w and math.abs(resized.logo.w/resized.logo.h-2)<.001 and resized.menu.x==menuX)
state.sliders[4]:setCurrentValue(25);assert(math.abs(B.rectangles(main).logo.h/main:getHeight()-.25)<.001)
assert(writes==0,'Editor preview wrote preferences before Save')
state.rows[1].entry:setText('invalid');assert(state.rows[1].dirty)
E.reset(main);assert(not state.draft.menu and not state.draft.logo and B.rectangles(main).menu.x==defaults.menu.x)
assert(not state.rows[1].dirty and not state.rows[1].invalid,'Reset retained a pending numeric edit')
E.select(main,'menu');state.rows[1].entry:setText('60');state.rows[3].entry:setText('10')
assert(E.select(main,'logo') and math.abs(B.rectangles(main).menu.x-main:getWidth()*.6)<.001,'Numeric fields clamped before batch commit')
E.reset(main)
E.select(main,'menu');main:onKeyRelease(Keyboard.KEY_RIGHT);assert(B.rectangles(main).menu.x>defaults.menu.x)
local width=B.rectangles(main).menu.w;isShiftKeyDown=function()return true end
main:onKeyRelease(Keyboard.KEY_RIGHT);assert(B.rectangles(main).menu.w>width);isShiftKeyDown=nil
main:onKeyRelease(Keyboard.KEY_TAB);assert(state.selected=='logo')
main:onKeyRelease(Keyboard.KEY_ESCAPE);assert(state.exitPrompt);state.exitPrompt.discard()
assert(not main.b47LayoutEditing and writes==0 and data.focus==main)
assert(B.rectangles(main).menu.x==defaults.menu.x and #main.children==3)
main:onJoypadDown(Joypad.XButton,data);state=main.b47LayoutEditing
assert(state and nativeJoy==1);state.sliders[1]:setCurrentValue(20);local selected=B.rectangles(main).menu.x
main:onKeyRelease(Keyboard.KEY_RETURN);assert(not main.b47LayoutEditing and writes==1 and L.get().menu and data.focus==main)
assert(math.abs(B.rectangles(main).menu.x-selected)<.001)
main:onKeyRelease(Keyboard.KEY_F10);state=main.b47LayoutEditing;E.reset(main)
getFileWriter=function()error('blocked')end
assert(not E.save(main) and state.saveFailed and main.b47LayoutEditing and L.get().menu)
state.panel:prerender();state.panel:onJoypadDown(Joypad.BButton,data)
assert(state.exitPrompt);state.exitPrompt.discard()
assert(not main.b47LayoutEditing and math.abs(B.rectangles(main).menu.x-selected)<.001)
getFileWriter=writer;main:onKeyRelease(Keyboard.KEY_F10);state=main.b47LayoutEditing
E.reset(main);assert(E.save(main) and not L.get().menu and B.rectangles(main).menu.x==defaults.menu.x)
main:onKeyRelease(Keyboard.KEY_F10);state=main.b47LayoutEditing;frame=state.frames.menu
frame:onMouseDown(4,4);assert(frame.capture)
main:setWidth(1024);main:setHeight(768);fontHeight=42;main:prerender()
assert(not frame.capture and not frame.drag and state.root:getWidth()==1024 and state.panel.y+state.panel:getHeight()<=756)
for _,s in ipairs(state.sliders)do assert(s.y+s:getHeight()<=state.saveButton.y)end
fontHeight=14
E.select(main,'menu');state.sliders[4]:setCurrentValue(20)
for i=13,40 do
 local child=ISPanel:new(0,i*50,200,20);child.Type='ISLabel';child.name='ADDED '..i;child.font=UIFont.Large;child.b47NativeMenu=true;main.bottomPanel:addChild(child)
end
main:prerender();local last=main.bottomPanel.children[40]
assert(last.y+last:getHeight()<=main.bottomPanel:getHeight()+.001 and last.b47MenuScale<1,'Added entries escaped custom area')
fontHeight=42;state.sliders[4]:setCurrentValue(1);main:prerender()
assert(fontHeight*last.b47MenuScale<=last:getHeight()*.65+.001,'Large-font text escaped a compact mod-filled menu row')
fontHeight=14
main.bottomPanel:setVisible(false);main:prerender()
assert(not main.b47LayoutEditing and not main.b47LayoutButton.visible and not state.root.capture)
main.bottomPanel:setVisible(true);main:prerender();assert(main.b47LayoutButton.visible)
main:onKeyRelease(Keyboard.KEY_F10);state=main.b47LayoutEditing
local other={};data.focus=other;modal=true;main:prerender()
assert(not main.b47LayoutEditing and data.focus==other,'Closing editor stole external modal focus')
local count=nativeKeys;main:onKeyRelease(Keyboard.KEY_F10);assert(not main.b47LayoutEditing and nativeKeys==count+1)
modal=false;data.focus=main;main.prerender=function()end
assert(not E.open(main),'Editor opened against a replacement renderer')
main.prerender=owned;E.open(main);state=main.b47LayoutEditing;state.frames.menu:onMouseDown(3,3)
assert(gameStart and state.frames.menu.capture);gameStart()
assert(not main.b47LayoutEditing and not state.frames.menu.capture)
E.open(main);state=main.b47LayoutEditing
local replacement=makeScreen();MainScreen.instance=replacement;assert(B.apply(replacement))
assert(not main.b47LayoutEditing and not state.frames.menu.capture and not E.open(main),'Recreated screen retained old editor')
MainScreen.instance=main;main.inGame=true;main:onKeyRelease(Keyboard.KEY_F10);assert(not main.b47LayoutEditing)
local ingame=makeScreen();ingame.inGame=true;assert(not B.apply(ingame) and not ingame.b47LayoutButton)
assert(records['B47ANCEDUI/appearance/B47ANCEDUI.0.txt']==nil and nativeCalls>0)
print('PASS OFFLINE layout editor drag/resize, Save/Cancel/Reset, keyboard/controller focus, viewport/mod-entry refit and lifecycle guards')

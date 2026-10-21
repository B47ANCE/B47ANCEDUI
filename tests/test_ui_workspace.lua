-- Reuses the native-shaped UI doubles from test_menu_layout_editor.
function ISComboBox:new(x,y,w,h,target,onChange)
 local box=ISPanel:new(x,y,w,h);setmetatable(box,{__index=self});box.options={};box.target=target;box.onChange=onChange;return box
end
ISComboBox.addOption=function(self,label)self.options[#self.options+1]=label end
ISComboBox.hidePopup=function(self)self.expanded=false;self.popupClosed=true end
ISPanel.setScrollHeight=function(self,v)self.scrollHeight=v end
ISPanelJoypad.setScrollHeight=ISPanel.setScrollHeight
local screen=ISPanel:new(0,0,1920,1080);screen.Type='MainScreen';screen.bottomPanel=ISPanel:new(0,0,200,200)
screen.delay=-1;MainScreen.instance=screen
local focus={focus=screen};JoypadState={getMainMenuJoypad=function()return focus end}
local modal=false;UIManager.isModalVisible=function()return modal end
local files={['B47ANCEDUI/in-game-layout.txt']='schema=1\nAbsent.window=.1,.2,.3,.4\n'}
local writes=0
getFileReader=function(name)
 local text=files[name];if not text then return end;local lines={};for line in text:gmatch('[^\n]+')do lines[#lines+1]=line end
 local i=0;return {readLine=function()i=i+1;return lines[i]end,close=function()end}
end
getFileWriter=function(name)
 assert(name=='B47ANCEDUI/in-game-layout.txt','HUD editor wrote another preference file')
 return {write=function(_,text)files[name]=text;writes=writes+1 end,close=function()end}
end
local U=B47ANCEDUI;local R=U.LayoutAssets;local P=require 'B47ANCEDUI/UILayout';local W=U.UILayoutEditor
local disposal=0
R.register('Fixture.aspect',{labelKey='UI_Fixture_Aspect',default={x=.1,y=.1,w=.2,h=.2},aspect=2,resizable=true,
 preview=function(parent)return U.Panel:new(0,0,100,50)end,dispose=function()disposal=disposal+1 end})
R.register('Fixture.failed',{labelKey='UI_Fixture_Failed',default={x=.1,y=.1,w=.1,h=.1},preview=function()error('deliberate fixture failure')end})
local function index(state,id)for i,def in ipairs(state.assets)do if def.id==id then return i end end;error(id)end
local function rect(state,id)return R.resolve(id,screen:getWidth(),screen:getHeight(),state.draft)end
local function typeValue(row,value)row.entry:focus();row.entry:setText(value);row.entry:unfocus()end
local state=W.open(screen);assert(state and state==W.open(screen) and #state.assets==12 and focus.focus==state.panel)
assert(state.frames['Fixture.failed'].previewError and not state.frames['Fixture.failed'].preview)
assert(state.root:onMouseDown() and state.root:onMouseWheel(1) and not ISPlayerData and not getPlayer,'Frontend leaked input or loaded gameplay')
local id='B47ANCEDUI.inventory';local before=rect(state,id);local frame=state.frames[id]
frame.hit:onMouseDown(30,30);frame.hit:onMouseMove(50*state.scale,20*state.scale);frame.hit:onMouseUpOutside()
local moved=rect(state,id);assert(math.abs(moved.x-before.x-50)<.001 and math.abs(moved.y-before.y-20)<.001 and not frame.hit.capture)
frame.hit:onMouseDown(frame:getWidth()-1,frame:getHeight()-1);frame.hit:onMouseMove(30*state.scale,20*state.scale);frame.hit:onMouseUp()
assert(rect(state,id).w>before.w and rect(state,id).h>before.h and writes==0)
-- Pending edits belong to the old target and are applied together before fitting.
typeValue(state.rows[1],'70');typeValue(state.rows[3],'10')
assert(W.select(screen,index(state,'B47ANCEDUI.loot')) and rect(state,id).x>1200 and rect(state,id).w==288)
local loot=rect(state,'B47ANCEDUI.loot');typeValue(state.rows[1],'invalid')
assert(not W.select(screen,index(state,id)) and state.assets[state.selected].id=='B47ANCEDUI.loot' and rect(state,'B47ANCEDUI.loot').x==loot.x)
W.reset(screen);assert(not state.rows[1].dirty and not state.draft[id] and state.draft['Absent.window'])
local tooltip=ISPanel:new(0,0,10,10);state.save.tooltipUI=tooltip
assert(W.save(screen) and writes==1 and disposal==1 and not screen.b47HudEditing and focus.focus==screen)
assert(tooltip.removed and not tooltip.visible,'Editor tooltip leaked outside its removed root')
assert(not P.entry(id) and P.entry('Absent.window') and files['B47ANCEDUI/in-game-layout.txt']:find('Absent.window=',1,true))
state=W.open(screen);W.select(screen,index(state,'Fixture.aspect'))
state.rows[4].slider:setCurrentValue(20);assert(math.abs(rect(state,'Fixture.aspect').h-216)<.001)
typeValue(state.rows[4],'25');assert(W.select(screen,index(state,id)))
assert(math.abs(rect(state,'Fixture.aspect').h-270)<.001 and rect(state,'Fixture.aspect').w/rect(state,'Fixture.aspect').h==2)
W.select(screen,index(state,'B47ANCEDUI.mechanics'));assert(not state.rows[3].enabled and state.rows[4].enabled)
frame=state.frames['B47ANCEDUI.mechanics'];local mech=rect(state,'B47ANCEDUI.mechanics')
frame.hit:onMouseDown(frame:getWidth()/2,frame:getHeight()-1);frame.hit:onMouseMove(100,30*state.scale);frame.hit:onMouseUp()
assert(rect(state,'B47ANCEDUI.mechanics').w==mech.w and rect(state,'B47ANCEDUI.mechanics').h>mech.h)
W.select(screen,index(state,'B47ANCEDUI.clock'));assert(not state.rows[1].enabled and not state.rows[3].enabled)
local clock=rect(state,'B47ANCEDUI.clock');W.key(screen,Keyboard.KEY_RIGHT);assert(not state.draft['B47ANCEDUI.clock'] and rect(state,'B47ANCEDUI.clock').x==clock.x)
state.selector.expanded=true;state.panel:onJoypadDown(Joypad.BButton);assert(screen.b47HudEditing and not state.selector.expanded)
state.selector.expanded=true;W.key(screen,Keyboard.KEY_ESCAPE);assert(screen.b47HudEditing and not state.selector.expanded)
W.select(screen,index(state,id));typeValue(state.rows[1],'21');state.rows[1].entry:focus()
W.key(screen,Keyboard.KEY_RETURN);assert(screen.b47HudEditing and not state.rows[1].entry:isFocused() and writes==1)
local slider=state.rows[1].slider;assert(slider.sliderDim.h>=12 and slider.sliderDim.w==12 and slider.sliderBarDim.y==slider:getHeight()/2-2)
slider:onMouseDown(20,12);assert(slider.capture);slider:onMouseUpOutside();assert(not slider.capture)
frame=state.frames[id];frame.hit:onMouseDown(30,30);screen:setWidth(1024);screen:setHeight(768);state.root:prerender()
assert(not frame.hit.capture and not frame.drag and state.root:getWidth()==1024 and state.panel.y+state.panel:getHeight()<=756)
local other={};focus.focus=other;modal=true;state.root:prerender()
assert(not screen.b47HudEditing and focus.focus==other and writes==1 and disposal==2)
modal=false;focus.focus=screen;state=W.open(screen);state.selector.expanded=true;W.close(screen)
assert(state.selector.popupClosed and disposal==3 and state.root.parent==nil)
-- Actual Options tab preserves native pages/actions and delegates native stencil.
MainOptions={};package.loaded['OptionScreens/MainOptions']=MainOptions
local root=ISPanel:new(0,0,900,700);root.Type='MainOptions';root.tabs={};root.addY=123;root.mainPanel={identity='native'}
local oldPanel=root.mainPanel;local stencil,applied,back=0,0,0
root.apply=function()applied=applied+1 end;root.back=function()back=back+1 end
root.addPage=function(self,title)
 local page=ISPanelJoypad:new(0,0,800,600);page.prerender=function()stencil=stencil+1 end
 self.tabs[#self.tabs+1]={title=title,page=page};self.mainPanel=page;self.addY=0;return page
end
local O=require 'B47ANCEDUI/OptionsInterface'
assert(O.attach(root) and not O.attach(root) and root.mainPanel==oldPanel and root.addY==123 and #root.tabs==1)
local page=root.b47InterfacePage;page:prerender();assert(stencil==1 and page.b47WorkspaceButton.enable)
page.b47WorkspaceButton.onclick();assert(screen.b47HudEditing);W.close(screen)
root.apply();root.back();assert(applied==1 and back==1)
screen.inGame=true;page:prerender();assert(not page.b47WorkspaceButton.enable and not W.open(screen))
print('PASS OFFLINE safe workspace canvas/input, batch edits, reset/provider retention, aspect/axis sizing, popup/focus/cleanup and native Options page ownership')

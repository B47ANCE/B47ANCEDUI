-- Unsaved confirmation regressions using the existing native-shaped UI doubles.
local U=B47ANCEDUI;local C=U.EditorControls;local E=U.MenuLayoutEditor;local W=U.UILayoutEditor
local B=U.MenuBackground;local L=require 'B47ANCEDUI/MenuLayout';local P=require 'B47ANCEDUI/UILayout'
local screen=ISPanel:new(0,0,1920,1080);screen.Type='MainScreen';screen.delay=-1
screen.prerender=MainScreen.prerender;screen.onKeyRelease=MainScreen.onKeyRelease;screen.onJoypadDown=MainScreen.onJoypadDown
screen.logoTexture={getWidth=function()return 600 end,getHeight=function()return 300 end}
screen.bottomPanel=ISPanel:new(0,0,300,300);screen:addChild(screen.bottomPanel)
for i=1,8 do local label=ISPanel:new(0,i*40,200,20);label.Type='ISLabel';label.name='MENU '..i;label.font=UIFont.Large;label.b47NativeMenu=true;screen.bottomPanel:addChild(label)end
MainScreen.instance=screen;local focus={focus=screen};JoypadState={getMainMenuJoypad=function()return focus end}
local modal=false;UIManager.isModalVisible=function()return modal end
local writes=0;getFileWriter=function(name)
 assert(name=='B47ANCEDUI/main-menu-layout.txt' or name=='B47ANCEDUI/in-game-layout.txt')
 return {write=function()writes=writes+1 end,close=function()end}
end
assert(B.apply(screen));local state=E.open(screen)
E.key(screen,Keyboard.KEY_ESCAPE);assert(not screen.b47LayoutEditing and writes==0,'Unchanged menu prompted/wrote')
state=E.open(screen);local initial=state.sliders[1].currentValue;state.sliders[1]:setCurrentValue(initial+1)
state.panel.joypadIndexY=2;state.panel.joypadIndex=2;state.panel:restoreJoypadFocus(focus)
assert(state.sliders[1].joypadFocused)
E.key(screen,Keyboard.KEY_ESCAPE)
assert(screen.b47LayoutEditing==state and state.exitPrompt and writes==0,'Unsaved menu Escape discarded the draft without confirmation')
local prompt=state.exitPrompt;assert(focus.focus==prompt.panel and prompt.selected==1)
local analogValue=state.sliders[1].currentValue
-- Native slider update checks the child's own flags, not the root focus object.
if state.sliders[1].joyfocus and state.sliders[1].joypadFocused then state.sliders[1]:setCurrentValue(analogValue+1) end
assert(not state.sliders[1].joypadFocused and state.sliders[1].currentValue==analogValue,'Underlying analog slider stayed active beneath popup')
state.cancelButton.onclick();assert(state.exitPrompt==prompt,'Duplicate confirmation')
assert(not E.save(screen) and not E.select(screen,'logo') and state.selected=='menu','Popup allowed underlying edit/save')
local value=state.sliders[1].currentValue;E.key(screen,Keyboard.KEY_RIGHT);assert(prompt.selected==2 and state.sliders[1].currentValue==value)
E.key(screen,Keyboard.KEY_ESCAPE);assert(not state.exitPrompt and screen.b47LayoutEditing==state and focus.focus==state.panel)
state.rows[1].entry:focus();state.rows[1].entry:setText('unfinished')
state.cancelButton.onclick();prompt=state.exitPrompt;assert(prompt and not state.rows[1].entry:isFocused())
prompt.keep();assert(state.rows[1].entry:isFocused() and state.rows[1].entry:getInternalText()=='unfinished' and state.rows[1].dirty)
E.key(screen,Keyboard.KEY_ESCAPE);prompt=state.exitPrompt;prompt.discard()
assert(not screen.b47LayoutEditing and writes==0 and focus.focus==screen)
prompt.discard();assert(writes==0,'Stale confirmation callback ran again')
state=E.open(screen);state.rows[1].entry:setText(string.format('%.2f',state.sliders[1].currentValue))
state.cancelButton.onclick();assert(not screen.b47LayoutEditing,'Formatting-equivalent entry counted as unsaved')
state=E.open(screen);state.sliders[1]:setCurrentValue(initial+2);assert(E.save(screen) and writes==1 and not screen.b47LayoutEditing)
state=E.open(screen);local saved=state.sliders[1].currentValue;state.sliders[1]:setCurrentValue(saved+2);state.sliders[1]:setCurrentValue(saved)
E.key(screen,Keyboard.KEY_ESCAPE);assert(not screen.b47LayoutEditing,'Reverted menu draft prompted')
state=E.open(screen);E.reset(screen);state.panel:onJoypadDown(Joypad.BButton);assert(state.exitPrompt)
state.exitPrompt.panel:onJoypadDown(Joypad.AButton);assert(screen.b47LayoutEditing and not state.exitPrompt,'Safe default did not keep editing')
state.panel:onJoypadDown(Joypad.BButton);prompt=state.exitPrompt;prompt.panel:onJoypadDirRight();prompt.panel:onJoypadDown(Joypad.AButton)
assert(not screen.b47LayoutEditing and writes==1 and L.get().menu,'Discard overwrote the saved menu')
-- Switching to the other editor also waits for explicit discard.
state=E.open(screen);state.sliders[2]:setCurrentValue(30);assert(not W.open(screen) and state.exitPrompt and not screen.b47HudEditing)
state.exitPrompt.keep();assert(screen.b47LayoutEditing==state and not screen.b47HudEditing)
W.open(screen);state.exitPrompt.discard();state=screen.b47HudEditing;assert(state and not screen.b47LayoutEditing)
W.close(screen);assert(not screen.b47HudEditing)
state=W.open(screen);local original=state.rows[1].slider.currentValue;state.rows[1].slider:setCurrentValue(original+1)
W.key(screen,Keyboard.KEY_ESCAPE);prompt=state.exitPrompt
assert(screen.b47HudEditing==state and prompt and not W.save(screen) and not W.select(screen,2) and writes==1)
W.key(screen,Keyboard.KEY_RETURN);assert(screen.b47HudEditing==state and not state.exitPrompt,'Enter default discarded HUD')
state.selector.expanded=true;state.panel:onJoypadDown(Joypad.BButton);assert(not state.selector.expanded and not state.exitPrompt)
state.panel:onJoypadDown(Joypad.BButton);assert(state.exitPrompt)
state.exitPrompt.panel:onJoypadDown(Joypad.BButton);assert(not state.exitPrompt and screen.b47HudEditing)
state.rows[1].entry:setText('invalid');state.cancel.onclick();prompt=state.exitPrompt;assert(prompt)
local snapshot=state.draft;W.reset(screen);assert(state.draft==snapshot,'Reset changed a draft beneath confirmation')
prompt.discard();assert(not screen.b47HudEditing and writes==1 and not P.entry('B47ANCEDUI.inventory'))
state=W.open(screen);state.rows[1].slider:setCurrentValue(original+3);assert(W.save(screen) and writes==2 and not screen.b47HudEditing)
state=W.open(screen);state.rows[1].slider:setCurrentValue(original+4)
local writer=getFileWriter;getFileWriter=function()error('fixture denied')end
assert(not W.save(screen) and screen.b47HudEditing==state and not state.exitPrompt)
state.cancel.onclick();assert(state.exitPrompt and writes==2);state.exitPrompt.keep()
assert(C.unsaved(state));getFileWriter=writer;state.cancel.onclick();state.exitPrompt.discard();assert(writes==2)
state=W.open(screen);W.reset(screen);assert(C.unsaved(state));W.key(screen,Keyboard.KEY_ESCAPE);prompt=state.exitPrompt
screen:setWidth(1024);screen:setHeight(768);state.root:prerender();prompt.shield:prerender()
assert(screen.b47HudEditing==state and prompt.shield:getWidth()==1024 and prompt.panel.x>=0)
local other={};focus.focus=other;modal=true;state.root:prerender()
assert(not screen.b47HudEditing and not state.exitPrompt and prompt.shield.parent==nil and focus.focus==other and writes==2)
modal=false;focus.focus=screen;state=E.open(screen);state.rows[2].entry:setText('invalid');state.cancelButton.onclick();prompt=state.exitPrompt
screen.inGame=true;screen:prerender();assert(not screen.b47LayoutEditing and not state.exitPrompt and prompt.shield.parent==nil)
assert(C.unsaved({baseline={},draft={},rows={},status='future',replaceFuture=true}),'Future-schema reset intent was lost')
print('PASS OFFLINE unsaved editor Exit/Cancel/Escape/B, safe popup selection, pending/invalid/reverted fields, switch/save/discard, duplicate/stale/focus and lifecycle cleanup')

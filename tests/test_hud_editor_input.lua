-- User regression: dropdown/canvas input must never become an implicit exit.
local U=B47ANCEDUI;local W=U.UILayoutEditor;local R=U.LayoutAssets;local P=require 'B47ANCEDUI/UILayout'
local C=U.EditorControls
-- Native button press/release semantics, rather than direct callback-only tests.
ISButton.onMouseDown=function(self)self.pressed=true;return true end
ISButton.onMouseUp=function(self)if self.pressed then self.pressed=false;self.onclick(self.target,self)end;return true end
ISButton.onMouseUpOutside=function(self)self.pressed=false end
local screen=ISPanel:new(120,90,1920,1080);screen.Type='MainScreen';screen.bottomPanel=ISPanel:new(0,0,200,200)
MainScreen.instance=screen
local modal,mouseDown=false,false;UIManager.isModalVisible=function()return modal end
isMouseButtonDown=function()return mouseDown end
local focus={focus=screen};JoypadState={getMainMenuJoypad=function()return focus end}
local writes=0;getFileWriter=function()return {write=function()writes=writes+1 end,close=function()end}end
local state=W.open(screen);assert(state)
-- Native popup selection clears expanded before the same Enter release reaches
-- MainScreen. That release is not an explicit Save button activation.
state.selector.expanded=false;W.key(screen,Keyboard.KEY_RETURN)
assert(screen.b47HudEditing==state and writes==0,'Dropdown Enter release saved/closed the HUD editor')
local function index(id)for i,def in ipairs(state.assets)do if def.id==id then return i end end;error(id)end
local function rect(id)return R.resolve(id,screen:getWidth(),screen:getHeight(),state.draft)end
local function down(id,x,y)
 local frame=state.frames[id]
 return state.canvas:onMouseDown(frame.x-state.canvasX+x,frame.y-state.canvasY+y)
end
local function unchanged(before)assert(not C.unsaved({baseline=before,draft=state.draft,rows={}}),'Non-asset click changed draft')end
W.reset(screen)
local id='B47ANCEDUI.inventory';W.select(screen,index(id));local before=rect(id)
local frame=state.frames[id];local clickDraft=P.copy(state.draft)
down(id,frame:getWidth()/2,frame:getHeight()/2);state.canvas:onMouseMove(0,0);state.canvas:onMouseUp();unchanged(clickDraft)
down(id,frame:getWidth()/2,frame:getHeight()/2)
assert(state.drag and state.canvas.capture and not frame.hit.capture)
state.canvas:onMouseMove(30*state.scale,10*state.scale)
state.canvas:onMouseMoveOutside(20*state.scale,15*state.scale);state.canvas:onMouseUpOutside()
assert(math.abs(rect(id).x-before.x-50)<.001 and math.abs(rect(id).y-before.y-25)<.001 and not state.drag and not state.canvas.capture)
down(id,frame:getWidth()/2,frame:getHeight()/2);mouseDown=false;state.root:prerender();assert(not state.drag and not state.canvas.capture,'Lost mouse release retained capture')
-- Direct bottom/right and top/left resize; opposite edges remain fixed.
before=rect(id);frame=state.frames[id];down(id,frame:getWidth()-1,frame:getHeight()-1)
state.canvas:onMouseMove(40*state.scale,20*state.scale);state.canvas:onMouseUp()
assert(math.abs(rect(id).w-before.w-40)<.001 and math.abs(rect(id).h-before.h-20)<.001)
before=rect(id);down(id,1,1);state.canvas:onMouseMove(-20*state.scale,-10*state.scale);state.canvas:onMouseUp()
local after=rect(id);assert(math.abs(after.x+after.w-before.x-before.w)<.001 and math.abs(after.y+after.h-before.y-before.h)<.001)
-- Empty space and out-of-bounds events neither edit nor close, even when dirty.
local blankX,blankY
for x=1,state.canvas:getWidth()-1,19 do
 for y=1,state.canvas:getHeight()-1,19 do
  local hit=false
  for _,f in pairs(state.frames)do
   local lx=x+state.canvasX-f.x;local ly=y+state.canvasY-f.y
   if lx>=0 and ly>=0 and lx<f:getWidth() and ly<f:getHeight()then hit=true;break end
  end
  if not hit then blankX,blankY=x,y;break end
 end
 if blankX then break end
end
assert(blankX,'Fixture lacks blank canvas space');local draft=P.copy(state.draft);local selected=state.selected
state.canvas:onMouseDown(blankX,blankY);state.canvas:onMouseMove(100,100);state.canvas:onMouseUp()
state.canvas:onMouseDoubleClick(blankX,blankY);state.canvas:onRightMouseDown(blankX,blankY)
state.canvas:onMouseDown(-1,10);state.canvas:onMouseMove(100,100);state.canvas:onMouseUpOutside()
state.root:onMouseDown();state.root:onMouseUp();unchanged(draft)
assert(screen.b47HudEditing==state and not state.exitPrompt and state.selected==selected and writes==0)
-- Overlap hit testing follows the visible stacking order, not the selector alone.
local other='B47ANCEDUI.chat';W.select(screen,index(other));frame=state.frames[other]
down(other,frame:getWidth()/2,frame:getHeight()/2);assert(state.drag.definition.id==other);state.canvas:onMouseUp()
-- Native dropdown order: clear expanded, hide captured popup, then callback.
state.selector.expanded=true;state.selector:showPopup();assert(not state.canvas.capture)
modal=true;state.root:prerender();assert(state.selector.expanded and not state.suspended and screen.b47HudEditing==state,'Owned registered popup was treated as an external modal');modal=false
state.canvas:onMouseDown(blankX,blankY);assert(not state.drag)
state.selector.sawMouseDown=true;state.selector.selected=index(id);state.selector.expanded=false;state.selector:hidePopup()
state.selector.onChange(state.selector.target,state.selector)
assert(state.assets[state.selected].id==id and state.popupPointerBlock and not state.selector.sawMouseDown)
draft=P.copy(state.draft);state.save:onMouseUp(2,2);state.save:onMouseDown(2,2);state.save:onMouseUp(2,2)
down(id,30,30);state.canvas:onMouseMove(50,50);state.canvas:onMouseUp();W.key(screen,Keyboard.KEY_RETURN)
assert(screen.b47HudEditing==state and writes==0);unchanged(draft)
mouseDown=true;state.root:prerender();assert(state.popupPointerBlock)
mouseDown=false;state.root:prerender();assert(not state.popupPointerBlock)
-- Cancel and Escape share the exact confirmation component and preserve drafts.
state.cancel:onMouseDown(2,2);state.cancel:onMouseUp(2,2)
local prompt=state.exitPrompt;assert(prompt and prompt.selected==1 and screen.b47HudEditing==state)
W.key(screen,Keyboard.KEY_RETURN);assert(not state.exitPrompt and screen.b47HudEditing==state);unchanged(draft)
W.key(screen,Keyboard.KEY_ESCAPE);prompt=state.exitPrompt;assert(prompt and writes==0)
local foreignFocus={};focus.focus=foreignFocus;modal=true;state.root:prerender()
assert(screen.b47HudEditing==state and state.exitPrompt==prompt and focus.focus==foreignFocus and state.suspended)
W.key(screen,Keyboard.KEY_ESCAPE);assert(state.exitPrompt==prompt and writes==0)
modal=false;state.root:prerender();assert(not state.suspended and state.exitPrompt==prompt);prompt.keep();unchanged(draft)
-- Height-only/fixed-size/reference-only definitions retain their contracts.
W.select(screen,index('B47ANCEDUI.mechanics'));frame=state.frames['B47ANCEDUI.mechanics'];before=rect('B47ANCEDUI.mechanics')
down('B47ANCEDUI.mechanics',frame:getWidth()/2,frame:getHeight()-1);state.canvas:onMouseMove(100*state.scale,10*state.scale);state.canvas:onMouseUp()
assert(rect('B47ANCEDUI.mechanics').w==before.w and rect('B47ANCEDUI.mechanics').h>before.h)
W.select(screen,index('B47ANCEDUI.character'));frame=state.frames['B47ANCEDUI.character'];before=rect('B47ANCEDUI.character')
down('B47ANCEDUI.character',1,1);state.canvas:onMouseMove(10*state.scale,10*state.scale);state.canvas:onMouseUp()
assert(rect('B47ANCEDUI.character').w==before.w and rect('B47ANCEDUI.character').h==before.h)
W.select(screen,index('B47ANCEDUI.clock'));frame=state.frames['B47ANCEDUI.clock'];draft=P.copy(state.draft)
down('B47ANCEDUI.clock',frame:getWidth()/2,frame:getHeight()/2);state.canvas:onMouseMove(50,50);state.canvas:onMouseUp();unchanged(draft)
-- Explicit Save commits once; old root/selector/button callbacks cannot edit a reopened workspace.
local old=state;state.save:onMouseDown(2,2);state.save:onMouseUp(2,2);assert(not screen.b47HudEditing and writes==1)
focus.focus=screen;state=W.open(screen);draft=P.copy(state.draft)
old.canvas:onMouseDown(20,20);old.selector.onChange(old.selector.target,old.selector);old.save.onclick();unchanged(draft)
assert(screen.b47HudEditing==state and writes==1)
state.selector.popup={parentCombo={},visible=true};state.selector.expanded=true;W.close(screen)
assert(state.selector.popup.visible and not state.selector.expanded,'Editor removed another combo popup')
state=W.open(screen);W.key(screen,Keyboard.KEY_ESCAPE);assert(not screen.b47HudEditing and writes==1,'Clean exit prompted or wrote')
state=W.open(screen);state.rows[1].entry:setText('unfinished');W.key(screen,Keyboard.KEY_ESCAPE);assert(state.exitPrompt)
state.exitPrompt.discard();assert(not screen.b47HudEditing and writes==1)
state=W.open(screen);screen.inGame=true;state.root:prerender();assert(not screen.b47HudEditing,'True game teardown leaked editor')
print('PASS OFFLINE HUD input: explicit exits/unsaved popup, native dropdown ordering/click-through, fixed-canvas hit/drag/resize/blank/overlap/outside release, modal drafts, provider limits and stale cleanup; native dispatch NOT TESTED')

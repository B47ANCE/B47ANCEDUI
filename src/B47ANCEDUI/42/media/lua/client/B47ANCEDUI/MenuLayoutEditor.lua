-- Owned main-menu overlay. Native actions and the in-game Esc menu stay native.
require 'B47ANCEDUI/API'
require 'ISUI/ISPanelJoypad'
require 'RadioCom/ISUIRadio/ISSliderPanel'
local L=require 'B47ANCEDUI/MenuLayout'
local C=require 'B47ANCEDUI/EditorControls'
local U=B47ANCEDUI
if U.MenuLayoutEditor then return U.MenuLayoutEditor end
local E={};U.MenuLayoutEditor=E
local sizePanel,change
local function tr(key) return getText('UI_B47ANCEDUI_'..key) end
local function visible(w) return w and (not w.getIsVisible or w:getIsVisible()) end
function E.available(screen)
 return screen and not screen.inGame and not screen.b47HudEditing and screen.b47MenuBackground and visible(screen)
  and (not MainScreen or not MainScreen.instance or MainScreen.instance==screen)
  and screen.prerender==screen.b47MenuBackgroundRenderer
  and visible(screen.bottomPanel) and (screen.delay or 0)<=0
  and not screen.tutorialButton and not screen.checkSavefileModal
  and not (UIManager.isModalVisible and UIManager.isModalVisible())
end
function E.profile(screen)
 local state=screen.b47LayoutEditing
 return state and state.draft or L.get()
end
local function ratio(screen) return screen.logoTexture:getWidth()/screen.logoTexture:getHeight() end
local function resolved(screen) return U.MenuBackground.rectangles(screen) end
local function commit(screen)
 local state=screen.b47LayoutEditing
 return C.commit(state.rows,function(values,changed)
  local rect=resolved(screen)[state.selected];local w,h=screen:getWidth(),screen:getHeight()
  if changed[1] then rect.x=values[1]/100*w end;if changed[2] then rect.y=values[2]/100*h end
  if changed[3] then rect.w=values[3]/100*w end
  if changed[4] then if state.selected=='logo' then if not changed[3] then rect.w=values[4]/100*h*ratio(screen) end else rect.h=values[4]/100*h end end
  change(screen,rect)
 end)
end
local function release(state)
 for _,frame in pairs(state.frames) do frame.drag=nil;frame:setCapture(false) end
 C.release(state.rows)
end
function E.cancel(screen)
 local state=screen.b47LayoutEditing;if not state then return end
 C.dismissExit(state,false)
 release(state);U.Tooltip.dispose(state.root);state.root:setVisible(false);state.root:setCapture(false)
 screen:removeChild(state.root);state.root.parent=nil;screen.b47LayoutEditing=nil
 if E.activeScreen==screen then E.activeScreen=nil end
 if state.joypad and state.joypad.focus==state.panel then
  local previous=state.previousFocus
  state.joypad.focus=previous and not previous.closed and not previous.removed and visible(previous) and previous or nil
  updateJoypadFocus(state.joypad)
 end
 if screen.b47LayoutButton then screen.b47LayoutButton:setVisible(E.available(screen) and true or false) end
end
function E.requestClose(screen,afterClose)
 local state=screen.b47LayoutEditing
 local function close() E.cancel(screen);if afterClose then afterClose() end end
 if not state then close();return true end
 return C.requestExit(state,release,close)
end
function E.ownerChanged(screen)
 if E.activeScreen and (E.activeScreen~=screen or not E.available(E.activeScreen)) then E.cancel(E.activeScreen) end
end
function E.save(screen)
 local state=screen.b47LayoutEditing;if not state or state.exitPrompt then return false end
 if not commit(screen) then state.inputInvalid=true;sizePanel(screen,state);return false end
 if not L.save(state.draft) then state.saveFailed=true;sizePanel(screen,state);return false end
 E.cancel(screen);return true
end
function E.reset(screen)
 local state=screen.b47LayoutEditing;if not state or state.exitPrompt then return end
 release(state);for _,row in ipairs(state.rows) do row.dirty=false end
 state.draft={};state.saveFailed=false;state.inputInvalid=false;E.refresh(screen)
end
change=function(screen,rect)
 local state=screen.b47LayoutEditing
 if not state or state.exitPrompt then return end
 state.draft=L.setRect(state.draft,state.selected,rect,screen:getWidth(),screen:getHeight(),ratio(screen))
 state.saveFailed=false;state.inputInvalid=false;E.refresh(screen)
end
function E.refresh(screen)
 local state=screen.b47LayoutEditing;if not state then return end
 local rects=resolved(screen)
 for kind,frame in pairs(state.frames) do
  local rect=rects[kind];U.Layout.place(frame,rect.x,rect.y,rect.w,rect.h)
 end
 local rect=rects[state.selected];local w,h=screen:getWidth(),screen:getHeight()
 local values={rect.x/w*100,rect.y/h*100,rect.w/w*100,rect.h/h*100}
 for i,row in ipairs(state.rows) do row.sync(values[i]) end
 state.menuButton.b47Selected=state.selected=='menu';state.logoButton.b47Selected=state.selected=='logo'
 if state.saveButton then sizePanel(screen,state) end
end
function E.select(screen,kind)
 local state=screen.b47LayoutEditing;if not state or state.exitPrompt then return false end
 if not commit(screen) then state.inputInvalid=true;sizePanel(screen,state);return false end
 C.release(state.rows);state.selected=kind;E.refresh(screen)
 state.frames[kind]:bringToTop();state.panel:bringToTop()
 return true
end
sizePanel=function(screen,state)
 local w,h=screen:getWidth(),screen:getHeight();local p=state.panel
 local font=getTextManager():getFontHeight(UIFont.Small);local button=math.max(30,font+10)
 local message=state.inputInvalid or state.saveFailed or state.selected=='logo'
 local header=font*2+button+26;local footer=button+24+(message and font+6 or 0)
 local slider=math.min(32,math.max(20,(h-24-header-footer)/4-font-14))
 local row=font+slider+14;local height=header+4*row+footer;local width=math.min(400,w-24)
 U.Layout.place(p,math.max(12,w-width-12),12,width,math.min(height,h-24))
 U.Layout.place(state.menuButton,12,font*2+18,(width-30)/2,button)
 U.Layout.place(state.logoButton,18+(width-30)/2,font*2+18,(width-30)/2,button)
 state.rowY=header;state.rowHeight=row;state.font=font
 for i,control in ipairs(state.rows) do control.layout(12,header+(i-1)*row,width-24,slider) end
 local y=header+4*row;local bw=(width-40)/3
 for i,b in ipairs({state.saveButton,state.cancelButton,state.resetButton}) do U.Layout.place(b,12+(i-1)*(bw+8),y,bw,button) end
 state.messageY=y+button+5
end
function E.open(screen,joypad)
 if screen.b47LayoutEditing then return screen.b47LayoutEditing end
 if not E.available(screen) then return end
 local state={draft=L.get(),baseline=L.get(),selected='menu',frames={},sliders={},rows={}}
 screen.b47LayoutEditing=state;E.activeScreen=screen
 local root=ISPanel:new(0,0,screen:getWidth(),screen:getHeight());root.background=false
 root:initialise();root:instantiate();state.root=root
 -- Full owned overlay consumes clicks outside controls while previewing live text.
 root.onMouseDown=function() return true end;root.onMouseUp=function() return true end
 root.onMouseDoubleClick=function() return true end
 root.onRightMouseDown=function() return true end;root.onRightMouseUp=function() return true end
 root.onMouseWheel=function() return true end
 root.prerender=function(self)
  if not E.available(screen) then E.cancel(screen);return end
  self:drawRect(0,0,self:getWidth(),self:getHeight(),.12,0,0,0)
 end
 for _,kind in ipairs({'logo','menu'}) do
  local frame=ISPanel:new(0,0,1,1);frame.background=false;frame:initialise();frame:instantiate();root:addChild(frame)
  state.frames[kind]=frame
  frame.prerender=function(self)
   C.outline(self,state.selected==kind,true)
  end
  frame.onMouseDown=function(self,x,y)
   if not E.select(screen,kind) then return true end
   local rect=resolved(screen)[kind]
   self.drag={start=rect,dx=0,dy=0,resize=C.edges(self,x,y,true)}
   self:setCapture(true);return true
  end
  local function move(self,dx,dy)
   if state.exitPrompt then return true end
   local drag=self.drag
   if drag then
    drag.dx=drag.dx+dx;drag.dy=drag.dy+dy
    state.draft=L.drag(state.draft,kind,drag.start,drag.dx,drag.dy,drag.resize,screen:getWidth(),screen:getHeight(),ratio(screen))
    state.saveFailed=false;E.refresh(screen)
   end
   return true
  end
  frame.onMouseMove=move;frame.onMouseMoveOutside=move
  local function up(self) self.drag=nil;self:setCapture(false);return true end
  frame.onMouseUp=up;frame.onMouseUpOutside=up
 end
 local p=ISPanelJoypad:new(0,0,1,1);p.playerNum=0;p.b47AppearanceScope='B47ANCEDUI';p.b47AppearanceOpaque=true
 p:initialise();p:instantiate();U.skin(p,'panel');root:addChild(p);state.panel=p
 local function button(label,callback)
  local b=U.Button:new(0,0,1,1,tr(label),p,callback);b.font=UIFont.Small
  b:initialise();b:instantiate();p:addChild(b);return b
 end
 state.menuButton=button('LayoutMenu',function() E.select(screen,'menu') end)
 state.logoButton=button('LayoutLogo',function() E.select(screen,'logo') end)
 for i,key in ipairs({'LayoutX','LayoutY','LayoutWidth','LayoutHeight'}) do
  local row=C.row(p,key,function(value)
   local rect=resolved(screen)[state.selected];local w,h=screen:getWidth(),screen:getHeight()
   if i==1 then rect.x=value/100*w elseif i==2 then rect.y=value/100*h
   elseif i==3 then rect.w=value/100*w
   elseif state.selected=='logo' then rect.w=value/100*h*ratio(screen)
   else rect.h=value/100*h end
   change(screen,rect)
  end)
  state.rows[i]=row;state.sliders[i]=row.slider
 end
 state.saveButton=button('LayoutSave',function() E.save(screen) end)
 state.cancelButton=button('LayoutCancel',function() E.requestClose(screen) end)
 state.resetButton=button('LayoutReset',function() E.reset(screen) end)
 p.joypadButtonsY={};p.allJoypadButtons={};p.joypadButtons={};p.joypadIndexY=1;p.joypadIndex=1
 p:insertNewLineOfButtons(state.menuButton,state.logoButton)
 for _,row in ipairs(state.rows) do p:insertNewLineOfButtons(row.minus,row.slider,row.plus,row.entry) end
 p:insertNewLineOfButtons(state.saveButton,state.cancelButton,state.resetButton)
 local joy=p.onJoypadDown
 p.onJoypadDown=function(self,key,...)
  if state.exitPrompt then return state.exitPrompt.panel:onJoypadDown(key,...) end
  if key==Joypad.BButton then E.requestClose(screen) elseif joy then return joy(self,key,...) end
 end
 local pre=p.prerender
 p.prerender=function(self,...)
  pre(self,...);local R,T=U.Renderer,U.Theme;local width=self:getWidth()-24;local f=state.font
  R.text(self,R.fit(tr('LayoutTitle'),width,UIFont.Small),12,8,T.colors.text,UIFont.Small)
  R.text(self,R.fit(tr('LayoutHelp'),width,UIFont.Small),12,10+f,T.colors.muted,UIFont.Small)
  C.drawRows(self,state.rows)
  local message=state.inputInvalid and 'InvalidPercent' or state.saveFailed and 'LayoutSaveFailed' or state.selected=='logo' and 'LayoutAspect' or nil
  if message then R.text(self,R.fit(tr(message),width,UIFont.Small),12,state.messageY,state.saveFailed and T.colors.needed or T.colors.muted,UIFont.Small) end
 end
 sizePanel(screen,state);screen:addChild(root);root:bringToTop();E.refresh(screen)
 state.width,state.height=screen:getWidth(),screen:getHeight()
 state.joypad=joypad or JoypadState and JoypadState.getMainMenuJoypad()
 if state.joypad then
  state.previousFocus=state.joypad.focus;state.joypad.focus=p;updateJoypadFocus(state.joypad)
  p:restoreJoypadFocus(state.joypad)
 end
 if screen.b47LayoutButton then screen.b47LayoutButton:setVisible(false) end;return state
end
function E.key(screen,key)
 local K=Keyboard;local state=screen.b47LayoutEditing
 if state and not E.available(screen) then E.cancel(screen);state=nil end
 if not state then
  if key==K.KEY_F10 and E.available(screen) then E.open(screen);return true end
  return false
 end
 if C.exitKey(state,key) then return true end
 if key==K.KEY_ESCAPE then E.requestClose(screen)
 elseif C.typing(state.rows) then
  local row=C.typing(state.rows)
  if key==K.KEY_RETURN and row.commit() then row.entry:unfocus();E.refresh(screen) end
 elseif key==K.KEY_RETURN then E.save(screen)
 elseif key==K.KEY_TAB then E.select(screen,state.selected=='menu' and 'logo' or 'menu')
 else
  local dx=key==K.KEY_LEFT and -2 or key==K.KEY_RIGHT and 2 or 0
  local dy=key==K.KEY_UP and -2 or key==K.KEY_DOWN and 2 or 0
  if dx~=0 or dy~=0 then
   local start=resolved(screen)[state.selected]
   state.draft=L.drag(state.draft,state.selected,start,dx,dy,isShiftKeyDown and isShiftKeyDown() or false,screen:getWidth(),screen:getHeight(),ratio(screen))
   state.saveFailed=false;E.refresh(screen)
  end
 end
 return true
end
function E.update(screen)
 local button=screen.b47LayoutButton;if not button then return end
 local state=screen.b47LayoutEditing
 if state and not E.available(screen) then E.cancel(screen);state=nil end
 button:setVisible(not state and E.available(screen) and true or false)
 U.Layout.place(button,12,screen:getHeight()-button:getHeight()-12,math.min(button.b47LayoutWidth,screen:getWidth()-24),button:getHeight())
 if state and (state.width~=screen:getWidth() or state.height~=screen:getHeight()) then
  release(state);state.width,state.height=screen:getWidth(),screen:getHeight()
  U.Layout.place(state.root,0,0,state.width,state.height);sizePanel(screen,state);E.refresh(screen)
 end
end
function E.attach(screen)
 if screen.b47LayoutButton or not screen.addChild then return end
 local button=U.Button.sized('small',0,0,1,tr('EditMenuLayout'),screen,function() E.open(screen) end)
 button.b47LayoutWidth=getTextManager():MeasureStringX(UIFont.Small,tr('EditMenuLayout'))+24
 button:initialise();button:instantiate();button:setTooltip(tr('LayoutShortcut'));screen.b47LayoutButton=button;screen:addChild(button)
 local key=screen.onKeyRelease
 screen.onKeyRelease=function(self,value,...)
  if E.key(self,value) then return end
  if key then return key(self,value,...) end
 end
 local joy=screen.onJoypadDown
 screen.onJoypadDown=function(self,value,data,...)
  if self.b47LayoutEditing and not E.available(self) then E.cancel(self) end
  if self.b47LayoutEditing then return self.b47LayoutEditing.panel:onJoypadDown(value,data,...) end
  if value==Joypad.XButton and E.available(self) then return E.open(self,data) end
  if joy then return joy(self,value,data,...) end
 end
 E.update(screen)
end
if Events and Events.OnGameStart then
 Events.OnGameStart.Add(function() if E.activeScreen then E.activeScreen.b47LayoutEditing.previousFocus=nil;E.cancel(E.activeScreen) end end)
end
return E

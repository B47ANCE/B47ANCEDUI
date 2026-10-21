require 'B47ANCEDUI/HUDPreviews'
require 'B47ANCEDUI/EditorControls'
require 'ISUI/ISPanelJoypad'
require 'ISUI/ISComboBox'
local U=B47ANCEDUI;local P=require 'B47ANCEDUI/UILayout'
local C=U.EditorControls;local R=U.LayoutAssets
if U.UILayoutEditor then return U.UILayoutEditor end
local W={};U.UILayoutEditor=W
local function tr(key) return getText('UI_B47ANCEDUI_'..key) end
local function visible(w) return w and (not w.getIsVisible or w:getIsVisible()) end
function W.available(screen)
 return screen and screen.Type=='MainScreen' and not screen.inGame and visible(screen)
  and (not MainScreen or not MainScreen.instance or MainScreen.instance==screen)
  and not (UIManager.isModalVisible and UIManager.isModalVisible())
end
local function release(state)
 C.release(state.rows)
 for _,frame in pairs(state.frames) do frame.drag=nil;frame.hit:setCapture(false) end
end
function W.close(screen)
 local state=screen.b47HudEditing;if not state then return end
 C.dismissExit(state,false)
 release(state);U.Tooltip.dispose(state.root);state.root:setVisible(false)
 if state.selector.expanded then state.selector:hidePopup();state.selector.expanded=false end
 for _,frame in pairs(state.frames) do
  if frame.definition.dispose and frame.preview then
   local ok,err=pcall(frame.definition.dispose,frame.preview)
   if not ok then print('B47ANCEDUI preview disposal failed: '..frame.definition.id..': '..tostring(err)) end
  end
 end
 screen:removeChild(state.root);state.root.parent=nil;screen.b47HudEditing=nil
 if W.activeScreen==screen then W.activeScreen=nil end
 if state.joypad and state.joypad.focus==state.panel then
  local old=state.previousFocus
  state.joypad.focus=old and not old.removed and not old.closed and visible(old) and old or nil
  updateJoypadFocus(state.joypad)
 end
end
function W.requestClose(screen)
 local state=screen.b47HudEditing;if not state then return true end
 return C.requestExit(state,release,function()W.close(screen)end)
end
local layout,refresh
local function changed(screen,rect)
 local state=screen.b47HudEditing;if not state or state.exitPrompt then return end
 local def=state.assets[state.selected]
 if not def.editable then return end
 state.draft=P.set(state.draft,def.id,rect,screen:getWidth(),screen:getHeight(),def)
 state.error=nil;refresh(screen)
end
local function selectedRect(screen)
 local state=screen.b47HudEditing;return R.resolve(state.assets[state.selected].id,screen:getWidth(),screen:getHeight(),state.draft)
end
local function commit(screen)
 local state=screen.b47HudEditing
 return C.commit(state.rows,function(values,changedFields)
  local rect=selectedRect(screen);local w,h=screen:getWidth(),screen:getHeight()
  if changedFields[1] then rect.x=values[1]/100*w end;if changedFields[2] then rect.y=values[2]/100*h end
  if changedFields[3] then rect.w=values[3]/100*w end;if changedFields[4] then rect.h=values[4]/100*h end
  local def=state.assets[state.selected]
  if def.aspect and changedFields[4] and not changedFields[3] then rect.w=rect.h*def.aspect end
  changed(screen,rect)
 end)
end
function W.select(screen,index)
 local state=screen.b47HudEditing;if not state or state.exitPrompt or not state.assets[index] then return false end
 if not commit(screen) then state.selector.selected=state.selected;state.error='InvalidPercent';return false end
 release(state);state.selected=index;state.selector.selected=index;state.error=nil
 state.frames[state.assets[index].id]:bringToTop();state.panel:bringToTop();refresh(screen)
 return true
end
refresh=function(screen)
 local state=screen.b47HudEditing;if not state then return end
 local sw,sh=screen:getWidth(),screen:getHeight();local scale=state.scale
 for _,def in ipairs(state.assets) do
  local rect=R.resolve(def.id,sw,sh,state.draft);local frame=state.frames[def.id]
  U.Layout.place(frame,state.canvasX+rect.x*scale,state.canvasY+rect.y*scale,rect.w*scale,rect.h*scale)
  if frame.preview then U.Layout.place(frame.preview,0,0,frame:getWidth(),frame:getHeight()) end
  U.Layout.place(frame.hit,0,0,frame:getWidth(),frame:getHeight())
 end
 local def=state.assets[state.selected];local rect=selectedRect(screen)
 for i,value in ipairs({rect.x/sw*100,rect.y/sh*100,rect.w/sw*100,rect.h/sh*100}) do
  state.rows[i].sync(value,def.editable and (i<3 or def.resizable and (i==3 and def.resizeWidth~=false or i==4 and def.resizeHeight~=false)))
 end
end
layout=function(screen)
 local state=screen.b47HudEditing;local w,h=screen:getWidth(),screen:getHeight()
 local font=getTextManager():getFontHeight(UIFont.Small);local button=math.max(30,font+10)
 local pw=math.min(380,math.max(260,w*.28),math.max(180,w-48));local px=w-pw-12
 local header=font*2+button+30;local footer=button+font*2+34
 local control=math.min(32,math.max(20,(h-24-header-footer)/4-font-14))
 local row=font+control+14;local height=header+4*row+footer
 U.Layout.place(state.root,0,0,w,h);U.Layout.place(state.panel,px,12,pw,math.min(height,h-24))
 U.Layout.place(state.selector,12,font*2+18,pw-24,button)
 for i,item in ipairs(state.rows) do item.layout(12,header+(i-1)*row,pw-24,control) end
 local by=header+4*row;local bw=(pw-40)/3
 for i,b in ipairs({state.save,state.cancel,state.reset}) do U.Layout.place(b,12+(i-1)*(bw+8),by,bw,button) end
 state.messageY=by+button+8;state.font=font
 state.scale=math.max(.001,math.min(math.max(1,px-24)/w,math.max(1,h-76)/h))
 state.canvasX=12;state.canvasY=60;state.width=w;state.height=h
 refresh(screen)
end
function W.save(screen)
 local state=screen.b47HudEditing;if not state or state.exitPrompt then return false end
 if not commit(screen) then state.error='InvalidPercent';return false end
 local ok,why=P.save(state.draft,state.replaceFuture)
 if not ok then state.error=why=='future' and 'LayoutFuture' or 'LayoutSaveFailed';return false end
 W.close(screen);return true
end
function W.reset(screen)
 local state=screen.b47HudEditing;if not state or state.exitPrompt then return end
 release(state)
 for _,row in ipairs(state.rows) do row.dirty=false end
 for _,def in ipairs(state.assets) do if def.editable then state.draft[def.id]=nil end end
 state.replaceFuture=true;state.error=nil;refresh(screen)
end
function W.open(screen,joypad)
 if not W.available(screen) then return end
 if screen.b47HudEditing then return screen.b47HudEditing end
 W.attach(screen)
 if screen.b47LayoutEditing then
  U.MenuLayoutEditor.requestClose(screen,function()W.open(screen,joypad)end);return screen.b47HudEditing
 end
 local draft,status=P.get();local assets=R.list();if #assets==0 then return end
 local state={draft=draft,baseline=P.copy(draft),status=status,assets=assets,selected=1,frames={},rows={}}
 screen.b47HudEditing=state;W.activeScreen=screen
 local root=ISPanel:new(0,0,screen:getWidth(),screen:getHeight());root:initialise();root:instantiate();state.root=root
 root.prerender=function(self)
  W.update(screen);if screen.b47HudEditing~=state then return end
  self:drawRect(0,0,self:getWidth(),self:getHeight(),1,0,0,0)
  U.Renderer.text(self,tr('HudEditorTitle'),12,10,U.Theme.colors.text)
  U.Renderer.text(self,U.Renderer.fit(tr('HudPreviewNotice'),math.max(1,state.canvasX+screen:getWidth()*state.scale-12)),12,30,U.Theme.colors.muted)
  U.Renderer.border(self,state.canvasX,state.canvasY,screen:getWidth()*state.scale,screen:getHeight()*state.scale,U.Theme.colors.border)
 end
 for _,name in ipairs({'onMouseDown','onMouseUp','onMouseDoubleClick','onRightMouseDown','onRightMouseUp','onMouseWheel'}) do root[name]=function()return true end end
 for _,def in ipairs(assets) do
  local frame=ISPanel:new(0,0,1,1);frame.background=false;frame.definition=def;frame:initialise();frame:instantiate();root:addChild(frame)
  state.frames[def.id]=frame
  local ok,widget=pcall(def.preview,frame)
  if ok and type(widget)=='table' and (widget.parent==nil or widget.parent==frame) and widget.setWidth and widget.setHeight then
   frame.preview=widget;if widget.parent~=frame then frame:addChild(widget) end
  else
   frame.previewError=true;print('B47ANCEDUI preview unavailable: '..def.id..': '..tostring(widget))
  end
  local hit=ISPanel:new(0,0,1,1);hit.background=false;hit:initialise();hit:instantiate();frame:addChild(hit);frame.hit=hit
  hit.prerender=function(self)
   C.outline(self,state.assets[state.selected].id==def.id,def.editable and def.resizable and def)
   if frame.previewError then U.Renderer.text(self,tr('PreviewUnavailable'),4,4,U.Theme.colors.needed) end
  end
  hit.onMouseDown=function(self,x,y)
   for index,asset in ipairs(assets) do if asset.id==def.id then if not W.select(screen,index) then return true end;break end end
   if def.editable then frame.drag={start=selectedRect(screen),dx=0,dy=0,edge=C.edges(self,x,y,def.resizable and def)};self:setCapture(true) end
   return true
  end
  local function move(self,dx,dy)
   if state.exitPrompt then return true end
   if frame.drag then
    local drag=frame.drag;drag.dx=drag.dx+dx/state.scale;drag.dy=drag.dy+dy/state.scale
    changed(screen,P.drag(drag.start,drag.dx,drag.dy,drag.edge,screen:getWidth(),screen:getHeight(),def))
   end
   return true
  end
  hit.onMouseMove=move;hit.onMouseMoveOutside=move
  local function up(self) frame.drag=nil;self:setCapture(false);return true end
  hit.onMouseUp=up;hit.onMouseUpOutside=up
 end
 local panel=ISPanelJoypad:new(0,0,1,1);panel.b47AppearanceScope='B47ANCEDUI';panel.playerNum=0;panel.b47AppearanceOpaque=true
 panel:initialise();panel:instantiate();U.skin(panel,'panel');root:addChild(panel);state.panel=panel
 local selector=ISComboBox:new(0,0,1,30,panel,function(_,box)W.select(screen,box.selected)end)
 selector:initialise();selector:instantiate();U.Dropdown.style(selector);panel:addChild(selector);state.selector=selector
 for _,def in ipairs(assets) do selector:addOption(getText(def.labelKey)) end;selector.selected=1
 for i,key in ipairs({'LayoutX','LayoutY','LayoutWidth','LayoutHeight'}) do
  state.rows[i]=C.row(panel,key,function(value)
   local rect=selectedRect(screen)
   if i==1 then rect.x=value/100*screen:getWidth() elseif i==2 then rect.y=value/100*screen:getHeight()
   elseif i==3 then rect.w=value/100*screen:getWidth() else
    rect.h=value/100*screen:getHeight();local def=state.assets[state.selected]
    if def.aspect then rect.w=rect.h*def.aspect end
   end
   changed(screen,rect)
  end)
 end
 local function button(key,callback)
  local b=U.Button:new(0,0,1,30,tr(key),panel,callback);b:initialise();b:instantiate();panel:addChild(b);return b
 end
 state.save=button('LayoutSave',function()W.save(screen)end);state.cancel=button('LayoutCancel',function()W.requestClose(screen)end)
 state.reset=button('ResetHudOverrides',function()W.reset(screen)end)
 panel.joypadButtonsY={};panel.allJoypadButtons={};panel.joypadButtons={};panel.joypadIndex=1;panel.joypadIndexY=1
 panel:insertNewLineOfButtons(selector)
 for _,row in ipairs(state.rows) do panel:insertNewLineOfButtons(row.minus,row.slider,row.plus,row.entry) end
 panel:insertNewLineOfButtons(state.save,state.cancel,state.reset)
 local joy=panel.onJoypadDown
 panel.onJoypadDown=function(self,key,...)
  if state.exitPrompt then return state.exitPrompt.panel:onJoypadDown(key,...) end
  if key==Joypad.BButton then
   if selector.expanded then selector:hidePopup();selector.expanded=false else W.requestClose(screen) end
  elseif joy then return joy(self,key,...) end
 end
 local pre=panel.prerender
 panel.prerender=function(self,...)
  pre(self,...);local RR,T=U.Renderer,U.Theme;local width=self:getWidth()-24;local def=assets[state.selected]
  RR.text(self,tr('HudProperties'),12,8,T.colors.text)
  RR.text(self,RR.fit(tr('HudPropertiesHelp'),width),12,10+state.font,T.colors.muted)
  C.drawRows(self,state.rows)
  local info=state.error or (state.status=='future' and not state.replaceFuture and 'LayoutFuture')
   or (not def.editable and 'HudReferenceOnly' or def.resizable and 'HudResizeHelp' or 'HudMoveOnly')
  RR.text(self,RR.fit(tr(info),width),12,state.messageY,state.error and T.colors.needed or T.colors.muted)
  RR.text(self,RR.fit(tr('HudOverridesNotice'),width),12,state.messageY+state.font+3,T.colors.muted)
 end
 layout(screen);screen:addChild(root);root:bringToTop()
 state.joypad=joypad or JoypadState and JoypadState.getMainMenuJoypad()
 if state.joypad then state.previousFocus=state.joypad.focus;state.joypad.focus=panel;updateJoypadFocus(state.joypad);panel:restoreJoypadFocus(state.joypad) end
 return state
end
function W.key(screen,key)
 local state=screen.b47HudEditing;if not state then return false end
 if not W.available(screen) then W.close(screen);return false end
 if C.exitKey(state,key) then return true end
 if state.selector.expanded then
  if key==Keyboard.KEY_ESCAPE then state.selector:hidePopup();state.selector.expanded=false end
  return true
 end
 if key==Keyboard.KEY_ESCAPE then W.requestClose(screen);return true end
 local typing=C.typing(state.rows)
 if typing then if key==Keyboard.KEY_RETURN and typing.commit() then typing.entry:unfocus();refresh(screen) end;return true end
 if key==Keyboard.KEY_RETURN then W.save(screen)
 elseif key==Keyboard.KEY_TAB then W.select(screen,state.selected%#state.assets+1)
 else
  local dx=key==Keyboard.KEY_LEFT and -2 or key==Keyboard.KEY_RIGHT and 2 or 0
  local dy=key==Keyboard.KEY_UP and -2 or key==Keyboard.KEY_DOWN and 2 or 0
  if dx~=0 or dy~=0 then
   local def=state.assets[state.selected];local edge=isShiftKeyDown and isShiftKeyDown() and {right=true,bottom=true} or false
   changed(screen,P.drag(selectedRect(screen),dx,dy,edge,screen:getWidth(),screen:getHeight(),def))
  end
 end
 return true
end
function W.update(screen)
 if W.activeScreen and (W.activeScreen~=screen or not W.available(W.activeScreen)) then W.close(W.activeScreen) end
 local state=screen.b47HudEditing
 if state and (state.width~=screen:getWidth() or state.height~=screen:getHeight()) then release(state);layout(screen) end
 local b=screen.b47HudLayoutButton
 if b then
  b:setVisible(not state and W.available(screen) and visible(screen.bottomPanel) and true or false)
  local previous=screen.b47LayoutButton;local x=previous and previous.x+previous:getWidth()+8 or 12
  U.Layout.place(b,x,screen:getHeight()-b:getHeight()-12,math.min(b.b47Width,math.max(1,screen:getWidth()-x-140)),b:getHeight())
 end
end
function W.attach(screen)
 if screen.b47HudLayoutButton or not screen.addChild then return end
 local b=U.Button.sized('small',0,0,1,tr('EditInGameUI'),screen,function()W.open(screen)end)
 b.b47Width=getTextManager():MeasureStringX(UIFont.Small,tr('EditInGameUI'))+24;b:initialise();b:instantiate()
 screen:addChild(b);screen.b47HudLayoutButton=b
 local key,joy=screen.onKeyRelease,screen.onJoypadDown
 screen.onKeyRelease=function(self,value,...) if W.key(self,value) then return end;if key then return key(self,value,...) end end
 screen.onJoypadDown=function(self,value,...)
  if self.b47HudEditing and not W.available(self) then W.close(self) end
  if self.b47HudEditing then return self.b47HudEditing.panel:onJoypadDown(value,...) end
  if joy then return joy(self,value,...) end
 end
 W.update(screen)
end
if Events and Events.OnGameStart then Events.OnGameStart.Add(function()
 if W.activeScreen then W.activeScreen.b47HudEditing.previousFocus=nil;W.close(W.activeScreen) end
end) end
return W

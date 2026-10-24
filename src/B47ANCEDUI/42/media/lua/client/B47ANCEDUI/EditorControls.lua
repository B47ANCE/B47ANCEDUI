-- Shared owned editor controls; native slider/input behavior remains authoritative.
require 'B47ANCEDUI/API'
require 'RadioCom/ISUIRadio/ISSliderPanel'
local U=B47ANCEDUI;local C={};U.EditorControls=C
local function text(key) return getText('UI_B47ANCEDUI_'..key) end
local function focused(entry) return entry.isFocused and entry:isFocused() end
function C.styleSlider(s)
 s.b47StyleFamily='slider'
 if s.b47EditorSlider then return s end;s.b47EditorSlider=true
 local paginate=s.paginate
 s.paginate=function(self,...)
  paginate(self,...)
  local w,h=self:getWidth(),self:getHeight()
  self.sliderBarDim={x=8,y=h/2-2,w=math.max(1,w-16),h=4}
  self.sliderDim={x=6,y=4,w=12,h=math.max(8,h-8)}
  U.ComponentStyles.captureSlider(self)
 end
 s:setDoButtons(false)
 local down,up,out=s.onMouseDown,s.onMouseUp,s.onMouseUpOutside
 s.onMouseDown=function(self,...)
  if self.disabled then return true end
  if self.b47BeforeDrag then self.b47BeforeDrag() end
  down(self,...);if self.dragInside then self:setCapture(true) end;return true
 end
 s.onMouseUp=function(self,...) up(self,...);self:setCapture(false);return true end
 s.onMouseUpOutside=function(self,...) out(self,...);self:setCapture(false);return true end
 local pre=s.prerender
 s.prerender=function(self,...)
  U.ComponentStyles.restore(self)
  local T,A=U.Theme,U.Appearance
  self.sliderColor=A.color(self,self.disabled and T.colors.disabled or T.colors.accent)
  self.sliderMouseOverColor=A.color(self,T.colors.accentHover)
  self.sliderBarColor=A.color(self,self.joypadFocused and T.colors.selected or T.colors.raised)
  self.sliderBarBorderColor=T.colors.border;self.sliderBorderColor=T.colors.border
  U.ComponentStyles.prepare(self,'slider')
  return pre(self,...)
 end
 return s
end
function C.row(parent,key,onChange)
 local row={key=key,enabled=true}
 row.onChange=onChange
 local s=ISSliderPanel:new(0,0,160,32,parent,function(_,value) row.invalid=false;row.dirty=false;onChange(value) end)
 s:initialise();s:instantiate();s:setValues(0,100,.1,1,true);C.styleSlider(s);parent:addChild(s);row.slider=s
 local entry=U.TextInput:new('0',0,0,72,32);entry:initialise();entry:instantiate();parent:addChild(entry);row.entry=entry
 function row.commit()
  return C.commit({row})
 end
 entry.onTextChangeFunction=function()if not row.syncing then row.dirty=true end end
 entry.onCommandEntered=function() row.commit() end
 s.b47BeforeDrag=function()entry:unfocus()end
 local function button(label,delta)
  local b=U.Button:new(0,0,32,32,label,parent,function()
   if row.enabled and row.commit() then entry:unfocus();s:setCurrentValue((s.currentValue or 0)+delta) end
  end)
  b:initialise();b:instantiate();parent:addChild(b);return b
 end
 row.minus=button('-',-.5);row.plus=button('+',.5)
 function row.sync(value,enabled)
  row.enabled=enabled~=false;s.disabled=not row.enabled;entry:setEditable(row.enabled)
  row.minus:setEnable(row.enabled);row.plus:setEnable(row.enabled);s.currentValue=value
  if not focused(entry) and not row.dirty then
   row.syncing=true;entry:setText(string.format('%.2f',value));row.syncing=false;row.invalid=false;entry.b47Role=nil
  end
 end
 function row.layout(x,y,width,height)
  row.x,row.y=x,y;local font=getTextManager():getFontHeight(UIFont.Small);local controlY=y+font+4
  local button=math.min(32,height);local field=math.min(72,width*.23);local bar=math.max(24,width-2*button-field-18)
  U.Layout.place(row.minus,x,controlY,button,height)
  U.Layout.place(s,x+button+6,controlY,bar,height)
  U.Layout.place(row.plus,x+button+12+bar,controlY,button,height)
  U.Layout.place(entry,x+width-field,controlY,field,height)
  s:paginate() -- Width paginates before height; always refresh final native hit/draw geometry.
 end
 return row
end
function C.drawRows(panel,rows)
 for _,row in ipairs(rows) do
  U.Renderer.text(panel,text(row.key)..' (%)',row.x,row.y,row.enabled and U.Theme.colors.text or U.Theme.colors.disabled,UIFont.Small)
 end
end
function C.commit(rows,apply)
 local values,changed={},{};local any=false
 for i,row in ipairs(rows) do
  local value=row.slider.currentValue or 0
  if row.enabled and row.dirty then
   value=tonumber(row.entry:getInternalText())
   if not value or value~=value or value<0 or value>100 then row.invalid=true;row.entry.b47Role='destructive';return false end
   changed[i]=true;any=true
  end
  values[i]=value
 end
 for _,row in ipairs(rows) do row.dirty=false;row.invalid=false;row.entry.b47Role=nil end
 if any then
  if apply then apply(values,changed)
  else for i,row in ipairs(rows) do if changed[i] then row.onChange(values[i]) end end end
 end
 return true
end
function C.typing(rows) for _,row in ipairs(rows) do if focused(row.entry) then return row end end end
function C.release(rows)
 for _,row in ipairs(rows) do
  local s=row.slider;s.dragInside=false;s.leftPressed=false;s.rightPressed=false;s:setCapture(false)
  if s.deactivateToolTip then s:deactivateToolTip() end
  row.entry:unfocus()
 end
end
local function same(a,b)
 if type(a)~=type(b) then return false end
 if type(a)=='number' then return math.abs(a-b)<.00000001 end
 if type(a)~='table' then return a==b end
 for key,value in pairs(a) do if not same(value,b[key]) then return false end end
 for key in pairs(b) do if a[key]==nil then return false end end
 return true
end
function C.unsaved(state)
 if not same(state.baseline,state.draft) or state.replaceFuture and (state.status=='future' or state.status=='read-error') then return true end
 for _,row in ipairs(state.rows) do
  if row.enabled and row.dirty then
   local value=tonumber(row.entry:getInternalText());local current=row.slider.currentValue or 0
   if not value or value~=value or value<0 or value>100 or not (same(value,current) or same(value,tonumber(string.format('%.2f',current)))) then return true end
  end
 end
 return false
end
function C.dismissExit(state,keep)
 local prompt=state.exitPrompt;if not prompt then return end;state.exitPrompt=nil
 local restoreInput=not state.joypad or state.joypad.focus==prompt.panel
 if state.joypad then prompt.panel:clearJoypadFocus(state.joypad) end
 U.Tooltip.dispose(prompt.shield);prompt.shield:setVisible(false);state.root:removeChild(prompt.shield);prompt.shield.parent=nil
 if state.joypad and state.joypad.focus==prompt.panel then
  state.joypad.focus=state.panel;updateJoypadFocus(state.joypad)
  if keep then state.panel:restoreJoypadFocus(state.joypad) end
 end
 if keep and restoreInput and not (UIManager.isModalVisible and UIManager.isModalVisible()) and prompt.entry and prompt.entry.editable~=false then prompt.entry:focus() end
end
function C.exitKey(state,key)
 local prompt=state.exitPrompt;if not prompt then return false end
 if key==Keyboard.KEY_ESCAPE then prompt.keep()
 elseif key==Keyboard.KEY_LEFT then prompt.choose(1)
 elseif key==Keyboard.KEY_RIGHT then prompt.choose(2)
 elseif key==Keyboard.KEY_TAB then prompt.choose(prompt.selected%2+1)
 elseif key==Keyboard.KEY_RETURN then prompt.activate() end
 return true
end
function C.requestExit(state,release,close)
 if state.exitPrompt then return false end
 if not C.unsaved(state) then close();return true end
 local typing=C.typing(state.rows);release(state);U.Tooltip.dispose(state.root)
 if state.selector and state.selector.expanded then state.selector:hidePopup();state.selector.expanded=false end
 local prompt={entry=typing and typing.entry,selected=1};state.exitPrompt=prompt
 local shield=ISPanel:new(0,0,state.root:getWidth(),state.root:getHeight());shield.background=false
 shield:initialise();shield:instantiate();state.root:addChild(shield);prompt.shield=shield
 for _,name in ipairs({'onMouseDown','onMouseUp','onMouseDoubleClick','onRightMouseDown','onRightMouseUp','onMouseWheel','onMouseMove'}) do shield[name]=function()return true end end
 local panel=ISPanelJoypad:new(0,0,1,1);panel.playerNum=0;panel.b47AppearanceScope='B47ANCEDUI';panel.b47AppearanceOpaque=true
 panel:initialise();panel:instantiate();U.skin(panel,'panel');shield:addChild(panel);prompt.panel=panel
 prompt.keep=function()if state.exitPrompt==prompt then C.dismissExit(state,true) end end
 prompt.discard=function()if state.exitPrompt==prompt then C.dismissExit(state,false);close() end end
 local function button(key,action,role)
  local b=U.Button:new(0,0,1,1,text(key),panel,action);b:initialise();b:instantiate();b.b47Role=role;panel:addChild(b);return b
 end
 prompt.buttons={button('KeepEditing',prompt.keep),button('DiscardChanges',prompt.discard,'destructive')}
 panel.joypadButtonsY={};panel.allJoypadButtons={};panel.joypadButtons={};panel.joypadIndexY=1;panel.joypadIndex=1
 panel:insertNewLineOfButtons(unpack(prompt.buttons))
 prompt.choose=function(index)
  prompt.selected=index
  for i,b in ipairs(prompt.buttons) do b.b47Selected=i==index end
  if state.joypad then panel:setJoypadFocus(prompt.buttons[index],state.joypad) end
 end
 prompt.activate=function()if prompt.selected==2 then prompt.discard() else prompt.keep() end end
 panel.onJoypadDown=function(_,key)if key==Joypad.BButton then prompt.keep() elseif key==Joypad.AButton then prompt.activate() end end
 panel.onJoypadDirLeft=function()prompt.choose(1)end;panel.onJoypadDirRight=function()prompt.choose(2)end
 panel.onJoypadDirUp=function()end;panel.onJoypadDirDown=function()end
 shield.prerender=function(self)
  local width,height=state.root:getWidth(),state.root:getHeight();local font=getTextManager():getFontHeight(UIFont.Small)
  local pw=math.max(1,math.min(520,width-32));local lines=U.Tooltip.wrap(text(state.exitMessageKey or 'UnsavedMessage'),math.max(1,pw-32),UIFont.Small)
  local titleHeight=getTextManager():getFontHeight(UIFont.Medium);local bodyY=24+titleHeight
  local bh=math.max(32,font+12);local ph=bodyY+#lines*(font+4)+16+bh+12
  U.Layout.place(self,0,0,width,height);U.Layout.place(panel,(width-pw)/2,math.max(0,(height-ph)/2),pw,ph)
  for i,b in ipairs(prompt.buttons) do U.Layout.place(b,12+(i-1)*(pw-12)/2,ph-bh-12,(pw-36)/2,bh) end
  prompt.lines=lines;prompt.font=font;prompt.bodyY=bodyY
  self:drawRect(0,0,width,height,.7,0,0,0)
 end
 local pre=panel.prerender
 panel.prerender=function(self,...)
  pre(self,...);U.Renderer.text(self,text('UnsavedTitle'),16,12,U.Theme.colors.text,UIFont.Medium)
  for i,line in ipairs(prompt.lines or {}) do U.Renderer.text(self,line,16,prompt.bodyY+(i-1)*(prompt.font+4),U.Theme.colors.muted) end
 end
 shield:bringToTop();shield:prerender()
 if state.joypad then state.panel:clearJoypadFocus(state.joypad);state.joypad.focus=panel;updateJoypadFocus(state.joypad) end
 prompt.choose(1);return false
end
function C.edges(w,x,y,resizable)
 if not resizable then return false end
 local zone=math.min(12,w:getWidth()/3,w:getHeight()/3)
 local edge={left=x<=zone,right=x>=w:getWidth()-zone,top=y<=zone,bottom=y>=w:getHeight()-zone}
 if type(resizable)=='table' then
  if resizable.resizeWidth==false then edge.left=false;edge.right=false end
  if resizable.resizeHeight==false then edge.top=false;edge.bottom=false end
 end
 return (edge.left or edge.right or edge.top or edge.bottom) and edge or false
end
function C.outline(w,selected,resizable)
 local c=U.Appearance.color(w,U.Theme.colors.accent);local width,height=w:getWidth(),w:getHeight()
 w:drawRectBorder(0,0,width,height,selected and 1 or .4,c.r,c.g,c.b)
 if selected and resizable then
  local size=math.min(10,width/3,height/3)
  for _,p in ipairs({{0,0},{(width-size)/2,0},{width-size,0},{0,(height-size)/2},{width-size,(height-size)/2},{0,height-size},{(width-size)/2,height-size},{width-size,height-size}}) do
   if type(resizable)~='table' or (resizable.resizeWidth~=false or p[1]==(width-size)/2) and (resizable.resizeHeight~=false or p[2]==(height-size)/2) then
    w:drawRect(p[1],p[2],size,size,.9,c.r,c.g,c.b)
   end
  end
 end
end
return C

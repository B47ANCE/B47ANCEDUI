-- An owned, stable inspector edits a live draft. Only Save writes the journal.
require 'B47ANCEDUI/API'
require 'B47ANCEDUI/EditorControls'
require 'ISUI/ISPanelJoypad'
require 'ISUI/ISComboBox'
local U=B47ANCEDUI;local P=U.StylePresets;local S=U.ComponentStyles;local C=U.EditorControls
if U.StyleEditor and U.StyleEditor.implemented then return U.StyleEditor end
local E={implemented=true};U.StyleEditor=E
local function tr(key)return getText('UI_B47ANCEDUI_'..key)end
local function sorted(t)local out={};for k in pairs(t)do out[#out+1]=k end;table.sort(out);return out end
function E.open(owner)
 if not owner then return end
 if E.active and not E.active.closed then return E.active.root end
 local player=U.Appearance.player(owner);local book,status=P.get(player)
 local state={draft=book,baseline=P.copy(book),rows={},owner=owner,player=player,scope='*',family='button',property=P.properties[1],status=status,exitMessageKey='StyleUnsavedMessage'}
 if not P.preview(player,book,state)then E.lastError='preview-owned';return end
 local vw=getPlayerScreenWidth and getPlayerScreenWidth(player)or 1024;local vh=getPlayerScreenHeight and getPlayerScreenHeight(player)or 768
 local left=getPlayerScreenLeft and getPlayerScreenLeft(player)or 0;local top=getPlayerScreenTop and getPlayerScreenTop(player)or 0
 local width,height=math.max(1,math.min(1040,vw-24)),math.max(1,math.min(760,vh-24))
 local root=ISPanelJoypad:new(left+(vw-width)/2,top+(vh-height)/2,width,height)
 root.playerNum=player;root.b47AppearanceScope='B47ANCEDUI';root.b47AppearanceOpaque=true;root.b47StyleSafe=true
 root:initialise();root:instantiate();U.skin(root,'panel');root:setWantKeyEvents(true)
 -- Keep underlying Options tabs/buttons inert even outside the inspector bounds.
 local veil=ISPanel:new(left,top,vw,vh);veil:initialise();veil:instantiate();veil.background=false
 for _,key in ipairs({'onMouseDown','onMouseUp','onMouseDoubleClick','onRightMouseDown','onRightMouseUp','onMouseWheel','onMouseMove'})do veil[key]=function()return true end end
 veil.prerender=function(self)self:drawRect(0,0,self:getWidth(),self:getHeight(),.8,0,0,0)end
 state.veil=veil
 state.root=root;state.panel=root;root.b47StyleState=state
 state.joypad=JoypadState and ((JoypadState.getMainMenuJoypad and JoypadState.getMainMenuJoypad())or JoypadState.players and JoypadState.players[player+1])
 state.previousFocus=state.joypad and state.joypad.focus
 E.active=state
 local font=getTextManager():getFontHeight(UIFont.Small);local bh=math.max(32,font+12);local header=math.max(70,font*3+28)
 local form=ISPanelJoypad:new(12,header,math.max(1,width*.48-18),math.max(1,height-header-bh-28));form:initialise();form:instantiate();form:noBackground();form:setScrollChildren(true);form:addScrollBars();root:addChild(form)
 local preForm,renderForm=form.prerender,form.render
 form.prerender=function(self,...)
  if self.doRightJoystickScrolling then self:doRightJoystickScrolling(20,20)end
  self:setStencilRect(0,0,self:getWidth(),self:getHeight());return preForm(self,...)
 end
 form.render=function(self,...)local result=renderForm(self,...);self:clearStencilRect();return result end
 form.onMouseWheel=function(self,delta)self:setYScroll(self:getYScroll()-delta*40);return true end
 local labels,controls={},{};local y=0
 local function editable()return not state.closed and not state.exitPrompt end
 local function pending(key,text)
  local values=state.draft.pending or {};values[key]=text;state.draft.pending=U._hasEntries(values)and values or nil
 end
 local function addLabel(key)labels[#labels+1]={key=key,y=y};y=y+font+5 end
 local function combo(key)
  addLabel(key);local b=ISComboBox:new(0,y,math.max(1,form:getWidth()-16),bh,root,function()end);b:initialise();b:instantiate();U.Dropdown.style(b);form:addChild(b);controls[#controls+1]=b;y=y+bh+12;return b
 end
 local function entry(key)
  addLabel(key);local b=U.TextInput:new('',0,y,math.max(1,form:getWidth()-16),bh);b:initialise();b:instantiate();form:addChild(b);controls[#controls+1]=b;y=y+bh+12;return b
 end
 local function button(key,callback,parent)
  parent=parent or form;local b=U.Button:new(0,y,math.max(1,form:getWidth()-16),bh,tr(key),root,callback);b:initialise();b:instantiate();parent:addChild(b)
  if parent==form then controls[#controls+1]=b;y=y+bh+10 end;return b
 end
 local preset=combo('StylePreset');local name=entry('StyleName');name:setMaxTextLength(48)
 local duplicate,delete,scope,family,property,value,number,inherit,reset
 local refresh,preview,loadValue
 local function current()return state.scope=='*'and state.draft.active or state.draft.bindings[state.scope]or state.draft.active end
 local function chosen()return state.draft.presets[current()]end
 preview=function()
  if not editable()then return false end
  P.preview(player,state.draft,state);state.error=state.draft.pending and 'StyleInvalid'or nil
 end
 local function valid()return editable()and not state.draft.pending and P.valid(state.draft)end
 duplicate=button('StyleDuplicate',function()
  if not valid()then return end
  local nextBook,key=P.duplicate(state.draft,current(),tr('StyleNewName')..' '..tostring(#sorted(state.draft.presets)))
  if not nextBook then state.error='StyleLimit';return end
  state.draft=nextBook
  if state.scope=='*'then state.draft.active=key else state.draft.bindings[state.scope]=key end
  preview();refresh()
 end)
 delete=button('StyleDelete',function()
  if not valid()then return end
  local nextBook=P.delete(state.draft,current());if nextBook then state.draft=nextBook;preview();refresh()end
 end)
 scope=combo('StyleScope');family=combo('StyleComponent');property=combo('StyleProperty');value=entry('StyleValue');value:setMaxTextLength(32)
 number=ISSliderPanel:new(0,y,math.max(1,form:getWidth()-16),bh,root,function(_,n)
  if state.syncing or not editable()then return end;value:setText(tostring(n));value.onTextChangeFunction()
 end)
 number:initialise();number:instantiate();C.styleSlider(number);form:addChild(number);controls[#controls+1]=number;y=y+bh+12
 inherit=button('StyleInherit',function()
  if not editable()then return end
  pending('value',nil);local nextBook=P.set(state.draft,current(),state.scope,state.family,state.property.id,nil)
  if nextBook then state.draft=nextBook;preview();loadValue()end
 end)
 reset=button('StyleResetComponent',function()
  if not editable()then return end
  pending('value',nil);local values=chosen().values
  if values[state.scope]then values[state.scope][state.family]=nil;if not U._hasEntries(values[state.scope])then values[state.scope]=nil end end
  preview();loadValue()
 end)
 local follow=button('StyleFollowShared',function()
  if state.scope=='*'or not valid()then return end
  state.draft.bindings[state.scope]=nil;preview();refresh()
 end)
 form:setScrollHeight(y+12)
 local area=ISPanelJoypad:new(width*.5,header,math.max(1,width*.5-12),form:getHeight());area:initialise();area:instantiate();area.b47StylePreview=true;root:addChild(area);U.skin(area,'panel')
 area:setScrollChildren(true);area:addScrollBars();area:setScrollHeight(52+bh*6+font*5+120)
 area.onMouseWheel=form.onMouseWheel
 local areaRender=area.render
 area.render=function(self,...)local result=areaRender(self,...);self:clearStencilRect();return result end
 local sample=U.Button:new(18,52,math.max(1,area:getWidth()-36),bh,tr('StyleSampleButton'),area,function()end);sample:initialise();sample:instantiate();area:addChild(sample)
 local sampleSlider=U.Slider:new(18,52+bh+20,math.max(1,area:getWidth()-36),bh,area,function()end);sampleSlider:initialise();sampleSlider:instantiate();sampleSlider:setValues(0,100,1,10);sampleSlider:setCurrentValue(50,true);area:addChild(sampleSlider)
 local sampleInput=U.TextInput:new(tr('StyleSampleInput'),18,52+bh*2+40,math.max(1,area:getWidth()-36),bh);sampleInput:initialise();sampleInput:instantiate();area:addChild(sampleInput)
 local sampleCombo=ISComboBox:new(18,52+bh*3+60,math.max(1,area:getWidth()-36),bh,area,function()end);sampleCombo:initialise();sampleCombo:instantiate();sampleCombo:addOption(tr('StyleSampleChoice'));sampleCombo:addOption(tr('StyleSampleChoice2'));U.Dropdown.style(sampleCombo);area:addChild(sampleCombo)
 local preArea=area.prerender
 area.prerender=function(self,...)
  self:setStencilRect(0,0,self:getWidth(),self:getHeight())
  self.b47StyleFamily=state.family;sample.b47StyleFamily=state.family
  self.b47StylePreviewShared=state.scope=='*'
  sampleSlider.b47AppearanceScope=state.scope=='*'and 'B47ANCEDUI'or state.scope
  self.b47AppearanceScope=sampleSlider.b47AppearanceScope
  preArea(self,...)
  local RR,T=U.Renderer,U.Theme
  RR.text(self,RR.fit(tr('StylePreview'),self:getWidth()-24),12,12,T.colors.text,UIFont.Medium)
  local yy=52+bh*4+80
  if yy+font*5<self:getScrollHeight()then
   RR.row(self,yy,bh,1,true,false);RR.text(self,RR.fit(tr('StyleSampleSelected'),self:getWidth()-24),12,yy+6,T.colors.text)
   U.Progress.draw(self,12,yy+bh+18,self:getWidth()-24,65,100)
   RR.checkbox(self,14,yy+bh+46,'full')
  end
 end
 local function close()
  if state.closed then return end;state.closed=true;C.dismissExit(state,false)
  P.clearPreview(player,state);U.Tooltip.dispose(root)
  for _,box in ipairs({preset,scope,family,property,sampleCombo})do
   if box.expanded then if not box.popup or box.popup.parentCombo==box then box:hidePopup()end;box.expanded=false end
  end
  for _,slider in ipairs({number,sampleSlider})do slider:setCapture(false);if slider.deactivateToolTip then slider:deactivateToolTip()end end
  root:setWantKeyEvents(false);root:setVisible(false);root:removeFromUIManager()
  name:unfocus();value:unfocus();sampleInput:unfocus()
  veil:setVisible(false);veil:removeFromUIManager()
  if state.joypad then
   if state.joypad.focus==root then
    root:clearJoypadFocus(state.joypad)
    local previous=state.previousFocus
    state.joypad.focus=previous and not previous.removed and not previous.closed and previous or nil
    updateJoypadFocus(state.joypad)
   end
  else U.Focus.restore(player,owner)end
  E.active=nil
 end
 local function release()
  for _,slider in ipairs({number,sampleSlider})do
   slider.dragInside=false;slider.leftPressed=false;slider.rightPressed=false;slider:setCapture(false)
   if slider.deactivateToolTip then slider:deactivateToolTip()end
  end
  name:unfocus();value:unfocus();sampleInput:unfocus()
 end
 local function cancel()if not state.closed then C.requestExit(state,release,close)end end
 local function save()
  if not valid()then state.error='StyleInvalid';return false end
  local ok=P.save(player,state.draft)
  if not ok then state.error='StyleSaveFailed';return false end
  close();return true
 end
 local saveButton=button('LayoutSave',save,root);local cancelButton=button('LayoutCancel',cancel,root)
 U.Layout.place(saveButton,12,height-bh-12,(width-36)/2,bh);U.Layout.place(cancelButton,24+(width-36)/2,height-bh-12,(width-36)/2,bh)
 loadValue=function()
  state.syncing=true;local values=chosen().values[state.scope]or {};local explicit=(values[state.family]or {})[state.property.id]
  local descriptor=state.property
  value:setText(explicit==nil and ''or tostring(explicit));value:setTooltip(tr(descriptor.type=='color'and 'StyleHexHelp'or 'StyleNumberHelp'))
  number:setVisible(descriptor.type=='number');number.disabled=descriptor.type~='number'
  if descriptor.type=='number'then number:setValues(descriptor.min,descriptor.max,descriptor.step,descriptor.step*5);number:setCurrentValue(tonumber(explicit)or descriptor.min,true);number:paginate()end
  state.syncing=false
 end
 refresh=function()
  state.syncing=true;preset:clear();state.presetKeys=sorted(state.draft.presets)
  for i,key in ipairs(state.presetKeys)do preset:addOption(state.draft.presets[key].name);if key==current()then preset.selected=i end end
  name:setText(chosen().name);delete:setEnable(current()~='default')
  scope:clear();state.scopes=P.scopes(state.draft)
  for i,key in ipairs(state.scopes)do scope:addOption(key=='*'and tr('StyleShared')or key);if key==state.scope then scope.selected=i end end
  family:clear();for i,key in ipairs(P.families)do family:addOption(tr('StyleFamily_'..key));if key==state.family then family.selected=i end end
  property:clear();state.properties={}
  for _,descriptor in ipairs(P.properties)do if not descriptor.family or descriptor.family==state.family then state.properties[#state.properties+1]=descriptor;property:addOption(tr('StyleProperty_'..descriptor.id))end end
  property.selected=1;state.property=state.properties[1]
  state.presetIndex=preset.selected;state.scopeIndex=scope.selected;state.familyIndex=family.selected;state.propertyIndex=property.selected
  state.syncing=false;loadValue()
 end
 preset.onChange=function()
  if state.syncing then return end
  if not valid()then preset.selected=state.presetIndex;return end
  local key=state.presetKeys[preset.selected]
  if state.scope=='*'then state.draft.active=key else state.draft.bindings[state.scope]=key end
  preview();refresh()
 end
 scope.onChange=function()
  if state.syncing then return end
  if not valid()then scope.selected=state.scopeIndex;return end
  state.scope=state.scopes[scope.selected];refresh()
 end
 family.onChange=function()
  if state.syncing then return end
  if not valid()then family.selected=state.familyIndex;return end
  state.family=P.families[family.selected];refresh()
 end
 property.onChange=function()
  if state.syncing then return end
  if not valid()then property.selected=state.propertyIndex;return end
  state.property=state.properties[property.selected];state.propertyIndex=property.selected;loadValue()
 end
 name.onTextChangeFunction=function()
  if state.syncing or not editable()then return end
  local text=name:getInternalText()
  if #text==0 or #text>48 or text:find('[%z\1-\31\127]')then pending('name',text);state.error='StyleInvalid';return end
  pending('name',nil);chosen().name=text;preview()
 end
 value.onTextChangeFunction=function()
  if state.syncing or not editable()then return end
  local text=value:getInternalText();local v=text~=''and P.value(state.property.id,text)or nil
  if text~=''and v==nil then pending('value',text);state.error='StyleInvalid';return end
  pending('value',nil);local nextBook=P.set(state.draft,current(),state.scope,state.family,state.property.id,v)
  if nextBook then state.draft=nextBook;preview()end
 end
 root.joypadButtonsY={};root.allJoypadButtons={};root.joypadButtons={};root.joypadIndexY=1;root.joypadIndex=1
 for _,control in ipairs(controls)do root:insertNewLineOfButtons(control)end
 root:insertNewLineOfButtons(saveButton,cancelButton)
 root.ensureVisible=function(self)
  local row=self.getVisibleChildren and self:getVisibleChildren(self.joypadIndexY)or self.joypadButtonsY[self.joypadIndexY or 1]
  local child=row and row[self.joypadIndex or 1]
  if not child or child.parent~=form then return end
  local scroll=form:getYScroll()
  if child.y+scroll<0 then form:setYScroll(-child.y)
  elseif child.y+child:getHeight()+scroll>form:getHeight()then form:setYScroll(form:getHeight()-child.y-child:getHeight())end
 end
 root.onJoypadDown=function(self,key,data)
  if state.exitPrompt then return state.exitPrompt.panel:onJoypadDown(key,data)end
  if key==Joypad.BButton then
   for _,box in ipairs({preset,scope,family,property,sampleCombo})do if box.expanded then box:hidePopup();box.expanded=false;return end end
   cancel();return
  end
  return ISPanelJoypad.onJoypadDown(self,key,data)
 end
 root.isKeyConsumed=function(self,key)return not state.closed and self:getIsVisible()and (state.exitPrompt~=nil or key==Keyboard.KEY_ESCAPE)end
 root.onKeyRelease=function(self,key)
  if state.closed then return end
  if C.exitKey(state,key)then return end
  if key==Keyboard.KEY_ESCAPE then
   for _,box in ipairs({preset,scope,family,property,sampleCombo})do if box.expanded then box:hidePopup();box.expanded=false;return end end
   cancel()
  end
 end
 local preRoot=root.prerender
 root.prerender=function(self,...)
  if owner.removed or owner.closed or owner.isReallyVisible and not owner:isReallyVisible()then close();return end
  local sw=getPlayerScreenWidth and getPlayerScreenWidth(player)or vw;local sh=getPlayerScreenHeight and getPlayerScreenHeight(player)or vh
  width,height=math.max(1,math.min(1040,sw-24)),math.max(1,math.min(760,sh-24))
  local sx=getPlayerScreenLeft and getPlayerScreenLeft(player)or left;local sy=getPlayerScreenTop and getPlayerScreenTop(player)or top
  if state.screenWidth~=sw or state.screenHeight~=sh or state.screenLeft~=sx or state.screenTop~=sy then
  state.screenWidth=sw;state.screenHeight=sh;state.screenLeft=sx;state.screenTop=sy
  U.Layout.place(veil,sx,sy,sw,sh)
  U.Layout.place(self,sx+(sw-width)/2,sy+(sh-height)/2,width,height)
  U.Layout.place(form,12,header,width*.48-18,math.max(1,height-header-bh-28))
  U.Layout.place(area,width*.5,header,width*.5-12,form:getHeight())
  for _,control in ipairs(controls)do control:setWidth(math.max(1,form:getWidth()-16))end
  for _,control in ipairs({sample,sampleSlider,sampleInput,sampleCombo})do control:setWidth(math.max(1,area:getWidth()-36))end
  U.Layout.place(saveButton,12,height-bh-12,(width-36)/2,bh);U.Layout.place(cancelButton,24+(width-36)/2,height-bh-12,(width-36)/2,bh)
  end
  preRoot(self,...);U.Renderer.text(self,tr('StyleTitle'),12,12,U.Theme.colors.text,UIFont.Medium)
  local message=state.error or (status~='ok'and status~='missing'and 'StyleProtected'or 'StyleNotice')
  U.Renderer.text(self,U.Renderer.fit(tr(message),self:getWidth()-24),12,32+font,U.Theme.colors.muted)
 end
 local pre=form.prerender
 form.prerender=function(self,...)pre(self,...);for _,label in ipairs(labels)do U.Renderer.text(self,tr(label.key),0,label.y,U.Theme.colors.text)end end
 state.rows={{entry=name,enabled=false},{entry=value,enabled=false}}
 state.preset=preset;state.name=name;state.scopeBox=scope;state.familyBox=family;state.propertyBox=property;state.value=value;state.number=number;state.save=saveButton;state.cancel=cancelButton;state.duplicate=duplicate;state.delete=delete;state.inherit=inherit;state.reset=reset;state.close=close;state.form=form;state.area=area
 refresh();preview();veil:addToUIManager();root:addToUIManager()
 if state.joypad then
  if state.previousFocus and state.previousFocus.clearJoypadFocus then state.previousFocus:clearJoypadFocus(state.joypad)end
  state.joypad.focus=root;updateJoypadFocus(state.joypad);root:restoreJoypadFocus(state.joypad)
 else setJoypadFocus(player,root)end
 return root
end
local function teardown()if E.active then E.active.close()end end
if Events and Events.OnGameStart then Events.OnGameStart.Add(teardown)end
if Events and Events.OnResetLua then Events.OnResetLua.Add(teardown)end
return E

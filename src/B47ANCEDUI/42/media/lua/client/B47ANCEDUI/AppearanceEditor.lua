require 'B47ANCEDUI/Controls'
require 'RadioCom/ISUIRadio/ISSliderPanel'
require 'ISUI/ISPanelJoypad'
local U=B47ANCEDUI
local V={};U.AppearanceEditor=V
local function tr(k) return getText('UI_B47ANCEDUI_'..k) end
function V.open(owner)
 local player=U.Appearance.player(owner)
 local scope=U.Appearance.scope(owner)
 local A={get=function(p) return U.Appearance.get(p,scope) end,set=function(p,v) return U.Appearance.set(p,v,scope) end,save=function(p) return U.Appearance.save(p,scope) end,
  getAccent=function(p) return U.Appearance.getAccent(p,scope) end,setAccent=function(p,v) return U.Appearance.setAccent(p,v,scope) end}
 if owner.b47AppearanceDialog and not owner.b47AppearanceDialog.closed then return owner.b47AppearanceDialog end
 local t=U.Theme.metrics();local vw=getPlayerScreenWidth and getPlayerScreenWidth(player) or 640
 local accentY=10+t.font+4+t.button+10;local hexY=accentY+t.font+4
 local rgbY=hexY+t.button+t.font+8;local row=t.button+6
 local height=rgbY+3*row+t.button+16
 local p=ISPanelJoypad:new(0,0,math.min(480,vw-20),height);p.playerNum=player;p.b47AppearanceScope=scope;p.b47AppearanceOpaque=true
 p:initialise();p:instantiate();U.skin(p,'panel');owner.b47AppearanceDialog=p
 local function save()
  p.saveFailed=not A.save(player);if not p.saveFailed then p.appearanceDirty=false end
  if p.done then p.done:setTooltip(p.saveFailed and tr('SaveFailed') or nil) end
  return not p.saveFailed
 end
 local function close()
  if p.closed then return end
  local acknowledged=p.saveFailed
  if not save() and not acknowledged then return end
  p.closed=true;p:removeFromUIManager();U.Focus.restore(player,owner)
 end
 p.close=close
 local sliders={};p.rgbSliders=sliders;local syncing=false
 local function sync()
  syncing=true;local hex=A.getAccent(player)
  for i,s in ipairs(sliders) do s:setCurrentValue(tonumber(hex:sub(i*2,i*2+1),16),true) end
  if p.hexEntry then p.hexEntry:setText(hex) end
  p.invalidHex=false;syncing=false
 end
 local function makeSlider(x,y,width,min,max,step,shift,callback)
  local s=ISSliderPanel:new(x,y,width,t.button,p,callback);s.playerNum=player;s.b47AppearanceScope=scope
  s:initialise();s:instantiate();s:setValues(min,max,step,shift,true);p:addChild(s);U.skin(s,'panel')
  local pre=s.prerender;s.prerender=function(self,...)
   self.sliderColor=U.Appearance.color(self,U.Theme.colors.accent)
   self.sliderMouseOverColor=U.Appearance.color(self,U.Theme.colors.accentHover)
   pre(self,...)
  end
  for _,method in ipairs({'onMouseUp','onMouseUpOutside'}) do local fn=s[method];s[method]=function(self,...) local result=fn(self,...);if p.appearanceDirty then save() end;return result end end
  return s
 end
 local slider=makeSlider(20,10+t.font+4,p:getWidth()-40,20,100,5,5,function(_,value) A.set(player,value);p.appearanceDirty=true end)
 -- Native step snapping would round the specified 82% design default to 80%.
 -- Preserve its supported public currentValue field until the next user adjustment.
 slider.currentValue=A.get(player);p.slider=slider
 local labelWidth=0
 for _,name in ipairs({'Red','Green','Blue'}) do labelWidth=math.max(labelWidth,getTextManager():MeasureStringX(U.Theme.fonts.body,tr(name)..' 255')) end
 local sliderX=20+labelWidth+12
 for i=1,3 do
  sliders[i]=makeSlider(sliderX,rgbY+(i-1)*row,p:getWidth()-sliderX-20,0,255,1,16,function()
   if syncing then return end
   A.setAccent(player,string.format('#%02X%02X%02X',sliders[1]:getCurrentValue(),sliders[2]:getCurrentValue(),sliders[3]:getCurrentValue()));p.appearanceDirty=true;sync()
  end)
 end
 local entry=U.TextInput:new(A.getAccent(player),20,hexY,p:getWidth()-104,t.button)
 entry.playerNum=player;entry.b47AppearanceScope=scope;entry:initialise();entry:instantiate();p:addChild(entry);p.hexEntry=entry
 if entry.setMaxTextLength then entry:setMaxTextLength(7) end
 entry.target=p;entry.onTextChangeFunction=function()
  if syncing then return end
  local hex=A.setAccent(player,entry:getText());p.invalidHex=hex==nil
  if hex then p.appearanceDirty=true;syncing=true;for i,s in ipairs(sliders) do s:setCurrentValue(tonumber(hex:sub(i*2,i*2+1),16),true) end;syncing=false end
 end
 entry.onCommandEntered=function() entry.onTextChangeFunction();if not p.invalidHex then sync();save() end end
 entry.onLostFocus=function() if not p.invalidHex then save() end end
 sync()
 local reset=U.Button:new(20,p:getHeight()-t.button-16,(p:getWidth()-48)/2,t.button,tr('ResetAppearance'),p,function()
  A.set(player,82);A.setAccent(player,U.Theme.defaultAccent);slider.currentValue=82;sync();save()
 end)
 local done=U.Button:new(28+(p:getWidth()-48)/2,p:getHeight()-t.button-16,(p:getWidth()-48)/2,t.button,tr('Close'),p,close)
 for _,b in ipairs({reset,done}) do b:initialise();b:instantiate();p:addChild(b) end
 p.reset,p.done=reset,done
 local pre=p.prerender;p.prerender=function(self,...)
  pre(self,...);local R,T=U.Renderer,U.Theme
  local percent=tostring(A.get(player))..'%';local valueX=self:getWidth()-20-getTextManager():MeasureStringX(T.fonts.body,percent)
  R.text(self,R.fit(tr('WindowOpacity'),valueX-32),20,10,T.colors.text)
  R.text(self,percent,valueX,10,T.colors.text)
  R.text(self,R.fit(tr('AccentHex'),self:getWidth()-40),20,accentY,T.colors.text)
  R.roundedRect(self,self:getWidth()-64,hexY,44,t.button,T.colors.accent,4)
  if self.saveFailed then R.text(self,R.fit(tr('SaveFailed'),self:getWidth()-40),20,hexY+t.button+4,T.colors.needed)
  elseif self.invalidHex then R.text(self,R.fit(tr('InvalidHex'),self:getWidth()-40),20,hexY+t.button+4,T.colors.needed) end
  for i,name in ipairs({'Red','Green','Blue'}) do R.text(self,tr(name)..' '..tostring(sliders[i]:getCurrentValue()),20,rgbY+(i-1)*row+(t.button-t.font)/2,T.colors.text) end
 end
 p.joypadButtonsY={};p.allJoypadButtons={};p.joypadButtons={};p.joypadIndexY=1;p.joypadIndex=1
 p:insertNewLineOfButtons(slider);p:insertNewLineOfButtons(entry)
 for _,s in ipairs(sliders) do p:insertNewLineOfButtons(s) end
 p:insertNewLineOfButtons(reset,done)
 local joy=p.onJoypadDown;p.onJoypadDown=function(self,key,...) if key==Joypad.BButton then close() elseif joy then joy(self,key,...) end end
 local left=getPlayerScreenLeft and getPlayerScreenLeft(player) or 0;local top=getPlayerScreenTop and getPlayerScreenTop(player) or 0
 p:setX(left+10);p:setY(top+10);U.bounds(p,player);p:addToUIManager();setJoypadFocus(player,p);return p
end
return V

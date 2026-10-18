require 'B47ANCEDUI/Controls'
require 'RadioCom/ISUIRadio/ISSliderPanel'
require 'ISUI/ISPanelJoypad'
local U=B47ANCEDUI
local V={};U.AppearanceEditor=V
local function tr(k) return getText('UI_B47ANCEDUI_'..k) end
function V.open(owner)
 local player=owner.playerNum or 0
 local scope=U.Appearance.scope(owner)
 local A={get=function(p) return U.Appearance.get(p,scope) end,set=function(p,v) return U.Appearance.set(p,v,scope) end,save=function(p) return U.Appearance.save(p,scope) end}
 if owner.b47AppearanceDialog and not owner.b47AppearanceDialog.closed then return owner.b47AppearanceDialog end
 local t=U.Theme.metrics();local vw=getPlayerScreenWidth and getPlayerScreenWidth(player) or 640
 local p=ISPanelJoypad:new(0,0,math.min(480,vw-20),t.header+3*t.button+60);p.playerNum=player;p.b47AppearanceScope=scope;p.b47AppearanceOpaque=true
 p:initialise();p:instantiate();U.skin(p,'panel');owner.b47AppearanceDialog=p
 local function close() if p.closed then return end;p.closed=true;A.save(player);p:removeFromUIManager();U.Focus.restore(player,owner) end
 p.close=close
 local slider=ISSliderPanel:new(20,t.header+8,p:getWidth()-40,t.button,p,function(_,value) A.set(player,value) end)
 slider:initialise();slider:instantiate();slider:setValues(20,100,5,5,true)
 -- Native step snapping would round the specified 82% design default to 80%.
 -- Preserve its supported public currentValue field until the next user adjustment.
 slider.currentValue=A.get(player);p:addChild(slider);p.slider=slider
 local reset=U.Button:new(20,p:getHeight()-t.button-16,(p:getWidth()-48)/2,t.button,tr('ResetAppearance'),p,function()
  A.set(player,82);slider.currentValue=82;A.save(player)
 end)
 local done=U.Button:new(28+(p:getWidth()-48)/2,p:getHeight()-t.button-16,(p:getWidth()-48)/2,t.button,tr('Close'),p,close)
 for _,b in ipairs({reset,done}) do b:initialise();b:instantiate();p:addChild(b) end
 p.reset,p.done=reset,done
 local pre=p.prerender;p.prerender=function(self,...)
  pre(self,...);U.Renderer.text(self,tr('WindowOpacity'),20,10,U.Theme.colors.text)
  U.Renderer.text(self,tostring(A.get(player))..'%',20,t.header+t.button+24,U.Theme.colors.text)
 end
 p.joypadButtonsY={};p.allJoypadButtons={};p.joypadButtons={};p.joypadIndexY=1;p.joypadIndex=1
 p:insertNewLineOfButtons(slider);p:insertNewLineOfButtons(reset,done)
 local joy=p.onJoypadDown;p.onJoypadDown=function(self,key,...) if key==Joypad.BButton then close() elseif joy then joy(self,key,...) end end
 for _,method in ipairs({'onMouseUp','onMouseUpOutside'}) do local fn=slider[method];slider[method]=function(self,...) local result=fn(self,...);A.save(player);return result end end
 local left=getPlayerScreenLeft and getPlayerScreenLeft(player) or 0;local top=getPlayerScreenTop and getPlayerScreenTop(player) or 0
 p:setX(left+10);p:setY(top+10);U.bounds(p,player);p:addToUIManager();setJoypadFocus(player,p);return p
end
return V

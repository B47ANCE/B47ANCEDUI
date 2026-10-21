-- An owned page inside the real native Options screen; native settings stay native.
require 'B47ANCEDUI/API'
require 'B47ANCEDUI/UILayoutEditor'
require 'OptionScreens/MainScreen'
require 'OptionScreens/MainOptions'
local U=B47ANCEDUI;if U.OptionsInterface then return U.OptionsInterface end
local O={};U.OptionsInterface=O
local function tr(key) return getText('UI_B47ANCEDUI_'..key) end
function O.attach(root)
 if not root or root.Type~='MainOptions' or root.b47InterfacePage or not root.tabs or not root.addPage then return false end
 local previous,addY=root.mainPanel,root.addY
 local page=root:addPage(tr('InterfaceTab'));root.mainPanel=previous;root.addY=addY
 root.b47InterfacePage=page;page.b47AppearanceScope='B47ANCEDUI';page.playerNum=0;U.skin(page,'panel')
 local function button(key,callback)
  local b=U.Button:new(0,0,200,32,tr(key),page,callback);b:initialise();b:instantiate();page:addChild(b);return b
 end
 local appearance=button('InterfaceAppearance',function()U.AppearanceEditor.open(page)end)
 local editor=button('EditInGameUI',function()U.UILayoutEditor.open(MainScreen.instance)end)
 page.joypadButtonsY={};page.allJoypadButtons={};page.joypadButtons={};page.joypadIndex=1;page.joypadIndexY=1
 page:insertNewLineOfButtons(appearance);page:insertNewLineOfButtons(editor)
 page.b47AppearanceButton=appearance;page.b47WorkspaceButton=editor
 local pre=page.prerender
 page.prerender=function(self,...)
  local font=getTextManager():getFontHeight(UIFont.Small);local buttonHeight=math.max(32,font+12)
  local width=math.min(640,math.max(1,self:getWidth()-48));local x=(self:getWidth()-width)/2
  local y=24+font*5
  U.Layout.place(appearance,x,y,math.min(320,width),buttonHeight)
  U.Layout.place(editor,x,y+buttonHeight+12,math.min(320,width),buttonHeight)
  editor:setEnable(MainScreen.instance and not MainScreen.instance.inGame and true or false)
  pre(self,...)
  local RR,T=U.Renderer,U.Theme
  RR.text(self,tr('InterfaceTitle'),x,24,T.colors.text,UIFont.Medium)
  RR.text(self,RR.fit(tr('InterfaceLocalNotice'),width),x,30+font*2,T.colors.muted)
  RR.text(self,RR.fit(tr('AccentHex')..' '..U.Appearance.getAccent(0,'B47ANCEDUI'),width),x,34+font*3,T.colors.text)
  RR.text(self,RR.fit(tr(editor.enable and 'InterfaceEditorNotice' or 'InterfaceMenuOnly'),width),x,y+buttonHeight*2+30,T.colors.muted)
  RR.text(self,RR.fit(tr('HudOverridesNotice'),width),x,y+buttonHeight*2+font+34,T.colors.muted)
  self:setScrollHeight(y+buttonHeight*2+font*2+48)
 end
 return true
end
local function current() O.attach(MainScreen.instance and MainScreen.instance.mainOptions or MainOptions.instance) end
Events.OnMainMenuEnter.Add(current);Events.OnGameStart.Add(current);Events.OnResetLua.Add(current);current()
return O

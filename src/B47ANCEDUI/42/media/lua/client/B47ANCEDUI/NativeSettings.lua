require 'B47ANCEDUI/API'
require 'OptionScreens/MainScreen'
require 'OptionScreens/MainOptions'
require 'ISUI/ISTabPanel'
require 'ISUI/ISComboBox'
require 'ISUI/ISTickBox'
require 'ISUI/ISVolumeControl'
require 'ISUI/ISMegaVolumeControl'
require 'RadioCom/ISUIRadio/ISSliderPanel'
local Lifecycle=require 'B47ANCEDUI/OptionsLifecycle'
local U=B47ANCEDUI;local T,R,A=U.Theme,U.Renderer,U.Appearance
if U.NativeSettings then return U.NativeSettings end
local S={};U.NativeSettings=S
local function scoped(w,c) return U.ComponentStyles.color(w,c) end
local function copy(w,c) return T.copy(scoped(w,c)) end
local function native(w,class)
 return class and w.Type==class.Type and w.prerender==class.prerender and w.render==class.render
end
local function owned(w,root)
 for _=1,32 do if w==root then return true end;w=w and w.parent;if not w then return false end end
 return false
end
local function colors(w,kind)
 U.ComponentStyles.restore(w)
 w.borderColor=copy(w,T.colors.border)
 if kind=='root' then w.backgroundColor=T.copy(T.colors.window);w.backgroundColor.a=.99
 elseif kind=='tabs' then w.backgroundColor=T.copy(T.colors.panel);w.backgroundColor.a=0
 elseif kind=='panel' then U.ComponentStyles.prepare(w,kind);return
 else
  w.backgroundColor=copy(w,kind=='button' and T.colors.raised or T.colors.panel)
  w.backgroundColorMouseOver=copy(w,T.colors.hover)
  w.textColor=T.copy(T.colors.text)
 end
 if kind=='tick' then w.choicesColor=T.copy(T.colors.text) end
 if kind=='button' or kind=='combo' or kind=='input' or kind=='volume' then
  if w.joypadFocused then w.borderColor=copy(w,T.colors.accent) end
 end
 if kind=='slider' then
  w.buttonColor=copy(w,T.colors.raised);w.buttonMouseOverColor=copy(w,T.colors.hover)
  w.sliderBarColor=copy(w,w.joypadFocused and T.colors.selected or T.colors.raised);w.sliderBarBorderColor=copy(w,T.colors.border)
  w.sliderColor=copy(w,T.colors.accent);w.sliderMouseOverColor=copy(w,T.colors.accentHover);w.sliderBorderColor=copy(w,T.colors.strong)
 end
 U.ComponentStyles.prepare(w,kind)
end
local function before(w,fn)
 local delegate=w.prerender
 w.prerender=function(self,...)
  fn(self)
  return delegate(self,...)
 end
end
local function tabs(w,root)
 -- Keep native tab ordering, fade, overflow arrows, stencil and hit geometry.
 local draw=w.drawTextureScaled
 w.drawTextureScaled=function(self,tex,x,y,width,height,alpha,...)
  if owned(self,root) and y==0 and height==self.tabHeight-1 and (tex==ISTabPanel.tabSelected or tex==ISTabPanel.tabUnSelected) then
   local selected=tex==ISTabPanel.tabSelected
   local c=copy(self,selected and T.colors.selected or T.colors.raised);c.a=alpha
   R.roundedRect(self,x,y,width,height,c,4)
   local index=self:getActiveViewIndex()
   if selected and index and not self.isDragging and x==self:getTabX(index) then
    local accent=copy(self,T.colors.accent);accent.a=alpha;R.rect(self,x,height-2,width,2,accent)
   end
   return
  end
  return draw(self,tex,x,y,width,height,alpha,...)
 end
end
local popupFields={'backgroundColor','borderColor'}
local function popupFrame(delegate,self,...)
 local combo=self.parentCombo;local root=combo and combo.b47NativeSettingsOwner
 if not root or not owned(combo,root) then return delegate(self,...) end
 -- The native popup is shared with every combo. Borrow its palette for this
 -- draw only; restore even on failure or after another screen takes ownership.
 local saved={};for i,key in ipairs(popupFields) do saved[i]=self[key] end
 self.backgroundColor=copy(combo,T.colors.panel);self.backgroundColor.a=.99
 self.borderColor=copy(combo,T.colors.border)
 local rawBorder=rawget(self,'drawRectBorderStatic');local border=self.drawRectBorderStatic
 self.drawRectBorderStatic=function(popup,x,y,width,height,alpha,red,green,blue,...)
  if x==-1 and y==-1 and width==popup:getWidth()+2 and height==popup:getHeight()+2 then
   local c=scoped(combo,T.colors.border);red,green,blue=c.r,c.g,c.b
  end
  return border(popup,x,y,width,height,alpha,red,green,blue,...)
 end
 local ok,result=pcall(delegate,self,...)
 self.drawRectBorderStatic=rawBorder
 for i,key in ipairs(popupFields) do self[key]=saved[i] end
 if not ok then error(result) end;return result
end
local function combo(w)
 local show=w.showPopup
 w.showPopup=function(self,...)
  local result=show(self,...);local popup=ISComboBox.SharedPopup
  if popup and not popup.b47SettingsPopup and popup.parentCombo==self then
   popup.b47SettingsPopup=true
   local pre,render=popup.prerender,popup.render
   popup.prerender=function(self,...) return popupFrame(pre,self,...) end
   popup.render=function(self,...) return popupFrame(render,self,...) end
  end
  return result
 end
end
local function tick(w,root)
 local draw=w.drawTextureScaled
 w.drawTextureScaled=function(self,tex,x,y,width,height,alpha,red,green,blue,...)
  if owned(self,root) and tex==self.tickTexture then
   local c=scoped(self,self.enable==false and T.colors.disabledText or T.colors.check)
   red,green,blue=c.r,c.g,c.b
  end
  return draw(self,tex,x,y,width,height,alpha,red,green,blue,...)
 end
 local rect,border=w.drawRect,w.drawRectBorder
 w.drawRect=function(self,x,y,width,height,a,r,g,b,...)
  if owned(self,root)and x==self.leftMargin and width==self.boxSize and height==self.boxSize and U.ComponentStyles.properties(self).checkBackground then
   local c=scoped(self,T.colors.checkBackground);r,g,b=c.r,c.g,c.b
  end
  return rect(self,x,y,width,height,a,r,g,b,...)
 end
 w.drawRectBorder=function(self,x,y,width,height,a,r,g,b,...)
  if owned(self,root)and x==self.leftMargin and width==self.boxSize and height==self.boxSize and U.ComponentStyles.properties(self).checkBorder then
   local c=scoped(self,T.colors.checkBorder);r,g,b=c.r,c.g,c.b
  end
  return border(self,x,y,width,height,a,r,g,b,...)
 end
end
local function volume(w,root)
 -- Native volume controls have distinct click/drag/joypad mathematics. Tint
 -- only their neutral drawing; never replace the controls with generic sliders.
 local render=w.render
 w.render=function(self,...)
  if not owned(self,root) then return render(self,...) end
  local raw=rawget(self,'drawRect');local draw=self.drawRect
  self.drawRect=function(control,x,y,width,height,alpha,red,green,blue,...)
   if red==green and green==blue and not (x==0 and y==0 and width==control:getWidth()) then
    local c
    if red==.5 or red==.75 then c=scoped(control,T.colors.accent)
    elseif red>=.3 then c=scoped(control,T.colors.strong)
    else c=T.colors.raised end
    red,green,blue=c.r,c.g,c.b
   end
   return draw(control,x,y,width,height,alpha,red,green,blue,...)
  end
  local ok,result=pcall(render,self,...);self.drawRect=raw
  if not ok then error(result) end;return result
 end
end
local paletteFields={'backgroundColor','backgroundColorMouseOver','borderColor','textColor','choicesColor',
 'buttonColor','buttonMouseOverColor','sliderBarColor','sliderBarBorderColor','sliderColor','sliderMouseOverColor','sliderBorderColor'}
local function rounded(w,root)
 R.round(w,4)
 local rect,border=w.drawRect,w.drawRectBorder
 w.drawRect=function(self,...)
  return (owned(self,root) and rect or self.b47RawRect)(self,...)
 end
 w.drawRectBorder=function(self,...)
  return (owned(self,root) and border or self.b47RawBorder)(self,...)
 end
end
local adopt
local function container(w,root,depth,budget)
 if not w.b47SettingsContainer then
  w.b47SettingsContainer=true
  local add=w.addChild
  if add then w.addChild=function(self,child,...)
   local result=add(self,child,...)
   if owned(self,root) then adopt(child,root,0,{left=4096}) end
   return result
  end end
 end
 for _,child in pairs(w.children or {}) do
  if child.parent==w then adopt(child,root,depth+1,budget) end
 end
end
adopt=function(w,root,depth,budget)
 if not w or depth>16 or budget.left<=0 or not owned(w,root) then return end
 budget.left=budget.left-1
 if w.b47NativeSettingsOwner or w.b47Styled then return end
 local kind
 if w==root then kind='root'
 elseif w==root.tabs and native(w,ISTabPanel) then kind='tabs'
 elseif w.Type=='ISPanelJoypad' and w.prerender==MainOptions.subPanelPreRender and w.render==MainOptions.subPanelRender then kind='panel'
 elseif native(w,ISPanel) or native(w,ISPanelJoypad) then kind='panel'
 elseif native(w,ISButton) then
  -- Empty-title native buttons are live colour swatches. Keep their data colours.
  if w.title=='' then return end
  kind='button'
 elseif native(w,ISComboBox) then kind='combo'
 elseif native(w,ISTickBox) then kind='tick'
 elseif native(w,ISTextEntryBox) then kind='input'
 elseif native(w,ISSliderPanel) then kind='slider'
 elseif native(w,ISVolumeControl) or native(w,ISMegaVolumeControl) then kind='volume'
 else return end -- Custom panels/renderers and their subtrees retain ownership.
 w.b47NativeSettingsOwner=root;w.b47AppearanceScope='B47ANCEDUI'
 w.b47StyleFamily=({root='window',combo='dropdown'})[kind]or kind
 if kind=='slider'then U.ComponentStyles.slider(w,function(self)return owned(self,root)end)end
 local saved,last={},{};for i,key in ipairs(paletteFields) do saved[i]=w[key] end
 local function restore(self)
  for i,key in ipairs(paletteFields) do
   if last[i]~=nil and self[key]==last[i] then self[key]=saved[i] end
  end
  self.b47StyleSaved=nil
  if kind=='slider'then U.ComponentStyles.geometry(self)end
 end
 before(w,function(self)
  if not owned(self,root) then restore(self);return end
  colors(self,kind)
  for i,key in ipairs(paletteFields) do last[i]=self[key] end
  if kind=='root' and self.tabs and not self.tabs.b47NativeSettingsOwner then adopt(self.tabs,root,0,{left=4096}) end
 end)
 if kind=='tabs' then tabs(w,root)
 elseif kind=='combo' then combo(w)
 elseif kind=='tick' then tick(w,root)
 elseif kind=='volume' then volume(w,root) end
 local render=w.render
 w.render=function(self,...)
  if not owned(self,root) then restore(self) end
  return render(self,...)
 end
 if kind=='button' or kind=='combo' or kind=='input' or kind=='volume' then rounded(w,root) end
 if kind=='root' or kind=='panel' or kind=='tabs' then container(w,root,depth,budget) end
end
function S.apply(root)
 if not root or root.Type~='MainOptions' or not root.tabs or root.tabs.Type~='ISTabPanel' then return false end
 if root.b47NativeSettingsOwner==root then
  adopt(root.tabs,root,0,{left=4096});return true
 end
 if not Lifecycle.nativeRenderer(root) then return false end
 adopt(root,root,0,{left=4096});return true
end
Lifecycle.register('native-settings',S.apply)
return S

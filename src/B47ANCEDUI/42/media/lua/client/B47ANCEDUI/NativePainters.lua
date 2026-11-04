-- Native drawing only. All field/method loans end before a return or exception.
local P=require 'B47ANCEDUI/NativePresentation'
local U=B47ANCEDUI
if U.NativePainters then return U.NativePainters end
local N={};U.NativePainters=N
local families={combo='dropdown',input='input',slider='slider',volume='volume',tick='tick',tabs='tabs',list='list',button='button',scroll='scrollbar'}
local fields={backgroundColor='panel',backgroundColorMouseOver='hover',borderColor='border',
 textColor='text',textColorDisabled='disabledText',selectedTextColor='selectedText',choicesColor='text',selectionColor='selected',mouseOverHighlightColor='hover',
 buttonColor='raised',buttonMouseOverColor='hover',sliderBarColor='track',sliderBarBorderColor='trackBorder',
 sliderColor='thumb',sliderMouseOverColor='thumbHover',sliderBorderColor='thumbBorder'}
function N.player(w)
 if w and w.parentCombo then w=w.parentCombo end
 for _=1,64 do
  if not w then break end
  local n=w.playerNum or w.player
  if type(n)=='number' and n>=0 and n<=3 then return n end
  w=w.parentCombo or w.parent
 end
 return 0
end
local function color(canvas,token,a)return P.color(canvas,token,a)end
local function full(w,x,y,width,height)
 return x==0 and y==0 and width==w:getWidth() and height==w:getHeight()
end
-- The native script/object viewer was authored for a light code surface.
-- Keep its node model and syntax categories native; adapt only owned draw calls.
local function codeList(w,kind)
 local p=w.parent
 return kind=='list'and ISStringListView and ISScrollingListBox and getmetatable(w)==ISScrollingListBox
  and p and getmetatable(p)==ISStringListView and p.infoList==w and w.target==p and w.doDrawItem==ISStringListView.drawInfoList
end
local function nativeColor(r,g,b,name)
 local c=Colors and Colors[name]
 return c and P.equal(r,c:getRedFloat())and P.equal(g,c:getGreenFloat())and P.equal(b,c:getBlueFloat())
end
local function multiplayerList(w)
 local owner=w.parent and w.parent.parent and w.parent.parent.parent
 if not MultiplayerUI or not owner or getmetatable(owner)~=MultiplayerUI or getmetatable(w)~=ISScrollingListBox then return end
 if owner.accountList==w and w.doDrawItem==MultiplayerUI.drawAccountListItem
  or owner.internetList==w and w.doDrawItem==MultiplayerUI.drawInternetListItem then return owner end
end
function N.paint(w,delegate,kind,...)
 if kind=='scroll'then return P.scrollbarPaint(w,delegate,N.player(w),...)end
 if kind=='slider'then U.ComponentStyles.geometry(w)end
 local rect,border=w.drawRect,w.drawRectBorder
 if not rect or not border then return delegate(w,...)end
 local canvas=P.canvas(w,N.player(w),families[kind]or 'window',rect,border)
 local code=codeList(w,kind)
 local scenarios=kind=='frame'and DebugScenarios and MainScreen and MainScreen.instance and getmetatable(w)==DebugScenarios
  and w==DebugScenarios.instance and w.parent==MainScreen.instance
 -- Native ISImage uses backgroundColor for its artwork/name tint, not a fill.
 local imageTint=ISImage and getmetatable(w)==ISImage
 local mp=MultiplayerUI and getmetatable(w)==MultiplayerUI
 local mpTabs=ISMPTabPanel and getmetatable(w)==ISMPTabPanel and w.parent and MultiplayerUI
  and getmetatable(w.parent)==MultiplayerUI and w.parent.tabs==w
 local mpList=kind=='list'and multiplayerList(w)
 local param=ModInfoPanel and ModInfoPanel.Param and getmetatable(w)==ModInfoPanel.Param
  and w.parent and getmetatable(w.parent)==ModInfoPanel and w.parent[w.type]==w
  and(w.type=='Homepage'or w.type=='Path')
 local saved,borrowed={},{}
 -- Only conventional neutral presentation fields. Coloured warnings, item
 -- swatches, transparent overlays and live content are not generic chrome.
 for field,token in pairs(fields)do
  local c=w[field]
  local selection=kind=='list'and(field=='selectionColor'or field=='mouseOverHighlightColor'or field=='selectedTextColor')
  local contentTint=imageTint and(field=='backgroundColor'or field=='backgroundColorMouseOver')
  if not contentTint and type(c)=='table'and(selection or P.neutral(c.r,c.g,c.b))then
   saved[field]=c
   if field=='backgroundColor' then token=kind=='button'and 'raised'or kind=='frame'and 'window'or 'panel'end
   borrowed[field]=color(canvas,token,c.a);w[field]=borrowed[field]
  end
 end
 -- These named native palette fields are presentation chrome despite their
 -- coloured defaults. Their current tables/alpha are restored after drawing.
 for field,token in pairs(mp and {serverInfoBluePanelColor='raised'}or mpTabs and {backgroundColorSelected='selected'}or {})do
  local c=w[field]
  if type(c)=='table'then saved[field]=c;borrowed[field]=color(canvas,token,c.a);w[field]=borrowed[field]end
 end
 local mpSelected=mpList and mpList.serverListSelected
 local mpLoan
 if type(mpSelected)=='table'then mpLoan=color(canvas,'selected',mpSelected.a);mpList.serverListSelected=mpLoan end
 local wrappers={}
 for _,name in ipairs({'drawRect','drawRectStatic','drawRectBorder','drawRectBorderStatic'})do
  local raw=w[name]
  if raw then
   local edge=name=='drawRectBorder'or name=='drawRectBorderStatic'
   local fixed=name=='drawRectStatic'or name=='drawRectBorderStatic'
   local c=fixed and P.canvas(w,N.player(w),families[kind]or 'window',w.drawRectStatic or rect,w.drawRectBorderStatic or border)or canvas
   wrappers[name]=function(self,x,y,width,height,a,r,g,b,...)
    if param and edge and x==self.borderX+10 and height==1 and P.equal(r,.05)and P.equal(g,.45)and P.equal(b,.7)then
     local c=color(canvas,'accentHover');r,g,b=c.r,c.g,c.b
    end
    if code and nativeColor(r,g,b,edge and 'Black'or 'Khaki')then
     if edge then return P.edge(c,x,y,width,height,'border',a,0)end
     return P.fill(c,x,y,width,height,'selected',a,0)
    end
    if code and not edge and nativeColor(r,g,b,'LemonChiffon')then return P.fill(c,x,y,width,height,'hover',a,0)end
    local neutral=P.neutral(r,g,b)
    -- Palette loans have already changed RGB. Match the exact borrowed field
    -- as well as original neutral native constants, only in known frame areas.
    for _,v in pairs(borrowed)do if r==v.r and g==v.g and b==v.b then neutral=true;break end end
    local frame=full(self,x,y,width,height)
    if scenarios and x==0 and y==0 and width==self:getWidth()then
     local visible=self:getMaxDrawHeight()
     if visible==-1 then visible=self:getHeight()end
     if height==visible then
      frame=true
      if not edge and r==0 and g==.05 and b==.1 then neutral=true end
     end
    end
    if kind=='list'and not edge and x==0 and width==self:getWidth()and a==.3 and r==.7 and g==.35 and b==.15 then
     return P.fill(c,x,y,width,height,'selected',a,0)
    end
    if kind=='tick'and width==self.boxSize and height==self.boxSize and x==self.leftMargin then
     if edge then return P.edge(c,x,y,width,height,'checkBorder',a,1)end
     if neutral then return P.fill(c,x,y,width,height,'checkBackground',a,1)end
    end
    if kind=='input'and edge and(self.joyfocus or self.joypadFocused)and(x==0 or x==1)and y==x and width==self.width-2*x and height==self.height-2*x then
     return P.edge(c,x,y,width,height,x==0 and 'focusOuter'or 'focusInner',a)
    end
    if kind=='frame' and self.titleBarHeight and x==0 and width==self:getWidth()then
     local title=self:titleBarHeight()
     frame=frame or(y==0 and height==title)or(y==title and height==self:getHeight()-title)
    end
    if frame and not edge and kind=='button'and saved.backgroundColor and self.pressed and U.ComponentStyles.properties(canvas).pressed then
      a,r,g,b=U.ComponentStyles.buttonFill(self,a,r,g,b,canvas)
      return U.Renderer.roundedRect(c,x,y,width,height,{a=a,r=r,g=g,b=b},4)
    end
    if frame and neutral then
     if edge then return P.edge(c,x,y,width,height,self.joypadFocused and 'focusOuter'or ((kind=='button'or kind=='tick')and self.enable==false or kind=='combo'and self.disabled)and 'disabledBorder'or 'border',a)end
     local token=kind=='button'and 'raised'or kind=='frame'and 'window'or 'panel'
     if borrowed.backgroundColorMouseOver and r==borrowed.backgroundColorMouseOver.r and g==borrowed.backgroundColorMouseOver.g then token='hover'end
     return P.fill(c,x,y,width,height,token,a)
    end
    return raw(self,x,y,width,height,a,r,g,b,...)
   end
  end
 end
 if param and w.drawText then
  local text=w.drawText
  wrappers.drawText=function(self,label,x,y,r,g,b,a,...)
   if x==self.borderX+10 and y==2 and P.equal(r,.05)and P.equal(g,.45)and P.equal(b,.7)then
    local c=color(canvas,self.type=='Path'and self.source~='Steam'and 'text'or 'accentHover');r,g,b=c.r,c.g,c.b
   end
   return text(self,label,x,y,r,g,b,a,...)
  end
 end
 if code and w.drawText then
  local text=w.drawText
  wrappers.drawText=function(self,label,x,y,r,g,b,a,...)
   local token
   for name,t in pairs({Black='text',DimGray='muted',Crimson='needed',DarkOrange='warning'})do
    if nativeColor(r,g,b,name)then token=t;break end
   end
   if token then local c=color(canvas,token);r,g,b=c.r,c.g,c.b
   else
    for _,name in ipairs({'DarkGreen','Purple','Violet','Magenta','MediumBlue','ForestGreen'})do
     if nativeColor(r,g,b,name)then r,g,b=.6+.4*r,.6+.4*g,.6+.4*b;break end
    end
   end
   return text(self,label,x,y,r,g,b,a,...)
  end
 end
 local texture=w.drawTextureScaled
 if texture then wrappers.drawTextureScaled=function(self,tex,x,y,width,height,a,r,g,b,...)
  if kind=='button'and tex==self.textureBackground and full(self,x,y,width,height)then return end
  if kind=='frame'and self.Type=='RWMElement'and getmetatable(self)==RWMElement and tex==self.buttonTexture and x==0 and y==0 and width==self:getWidth()and height==self.fontheightMed+2 then
   return P.fill(canvas,x,y,width,height,'titleBackground',a)
  end
  if kind=='tabs' and ISTabPanel and y==0 and height==self.tabHeight-1 and(tex==ISTabPanel.tabSelected or tex==ISTabPanel.tabUnSelected)then
   local selected=tex==ISTabPanel.tabSelected
   P.fill(canvas,x,y,width,height,selected and 'selected'or 'raised',a)
   local index=self:getActiveViewIndex()
   if selected and index and not self.isDragging and x==self:getTabX(index)then P.fill(canvas,x,height-2,width,2,'accent',a,0)end
   return
  end
  if kind=='tick'and tex==self.tickTexture then local c=color(canvas,self.enable==false and 'disabledText'or 'check');r,g,b=c.r,c.g,c.b end
  if kind=='frame' and ((self.titlebarbkg and tex==self.titlebarbkg)or(self.statusbarbkg and tex==self.statusbarbkg))then
   return P.fill(canvas,x,y,width,height,tex==self.titlebarbkg and 'titleBackground'or 'statusBackground',a,0)
  end
  return texture(self,tex,x,y,width,height,a,r,g,b,...)
 end end
 if w.drawText and(kind=='combo'or kind=='tick')then
  local text=w.drawText
  wrappers.drawText=function(self,label,x,y,r,g,b,a,...)
   if P.neutral(r,g,b)and((kind=='combo'and self.disabled)or(kind=='tick'and P.equal(r,.5)))then local c=color(canvas,'disabledText');r,g,b=c.r,c.g,c.b end
   return text(self,label,x,y,r,g,b,a,...)
  end
 end
 if kind=='frame'and w.drawTextCentre and w.title~=nil then
  local text=w.drawTextCentre
  wrappers.drawTextCentre=function(self,label,x,y,r,g,b,a,...)
   if label==self.title and y==1 and x==self:getWidth()/2 and P.neutral(r,g,b)then local c=color(canvas,'titleText');r,g,b=c.r,c.g,c.b end
   return text(self,label,x,y,r,g,b,a,...)
  end
 end
 if kind=='volume'then
  local draw=wrappers.drawRect
  wrappers.drawRect=function(self,x,y,width,height,a,r,g,b,...)
   if P.neutral(r,g,b)and not full(self,x,y,width,height)then
    local c=color(canvas,r>=.5 and 'accent'or 'raised');r,g,b=c.r,c.g,c.b
   end
   return draw(self,x,y,width,height,a,r,g,b,...)
  end
 end
 local result=P.pack(pcall(P.around,w,delegate,wrappers,...))
 if mpLoan and mpList.serverListSelected==mpLoan then mpList.serverListSelected=mpSelected end
 for field,c in pairs(saved)do if w[field]==borrowed[field]then w[field]=c end end
 if not result[1]then error(result[2],0)end
 return unpack(result,2,result.n)
end
function N.adopt(w,kind,active)
 if w.b47NativeTheme then return true end
 local state={kind=kind,pre=w.prerender,render=w.render};w.b47NativeTheme=state
 if kind=='slider'then U.ComponentStyles.slider(w,active)end
 for _,method in ipairs({'prerender','render'})do
  local delegate=w[method]
  if type(delegate)=='function'then
   w[method]=function(self,...)
    if self.parentCombo and(not self.parentCombo.b47NativeTheme or not active(self.parentCombo))then return delegate(self,...)end
    if not active(self)or self.altColor or self.blinkBG then
     if kind=='slider'then U.ComponentStyles.geometry(self)end
     return delegate(self,...)
    end
    if self.parentCombo and self.parentCombo.b47NativeTheme then
     -- Native shared dropdown rows read parentCombo colours, not popup fields.
     local combo=self.parentCombo
     local proxy=P.canvas(combo,N.player(combo),'dropdown',combo.drawRect,combo.drawRectBorder)
     local bg,hover,edge,text=combo.backgroundColor,combo.backgroundColorMouseOver,combo.borderColor,combo.textColor
     combo.backgroundColor=color(proxy,'panel',bg and bg.a)
     combo.backgroundColorMouseOver=color(proxy,'hover',hover and hover.a)
     combo.borderColor=color(proxy,'border',edge and edge.a)
     combo.textColor=color(proxy,'text',text and text.a)
     local result=P.pack(pcall(N.paint,self,delegate,kind,...))
     combo.backgroundColor,combo.backgroundColorMouseOver,combo.borderColor,combo.textColor=bg,hover,edge,text
     if not result[1]then error(result[2],0)end
     return unpack(result,2,result.n)
    end
    return N.paint(self,delegate,kind,...)
   end
  end
 end
 return true
end
return N

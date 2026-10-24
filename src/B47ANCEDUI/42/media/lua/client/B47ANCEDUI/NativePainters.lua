-- Native drawing only. All field/method loans end before a return or exception.
local P=require 'B47ANCEDUI/NativePresentation'
local U=B47ANCEDUI
if U.NativePainters then return U.NativePainters end
local N={};U.NativePainters=N
local families={combo='dropdown',input='input',slider='slider',volume='volume',tick='tick',tabs='tabs',list='list',button='button',scroll='slider'}
local fields={backgroundColor='panel',backgroundColorMouseOver='hover',borderColor='border',
 textColor='text',selectedTextColor='text',choicesColor='text',selectionColor='selected',mouseOverHighlightColor='hover',
 buttonColor='raised',buttonMouseOverColor='hover',sliderBarColor='raised',sliderBarBorderColor='border',
 sliderColor='accent',sliderMouseOverColor='accentHover',sliderBorderColor='strong'}
function N.player(w)
 if w and w.parentCombo then w=w.parentCombo end
 for _=1,64 do
  if not w then break end
  local n=w.playerNum or w.player
  if type(n)=='number' and n>=0 and n<=3 then return n end
  w=w.parent
 end
 return 0
end
local function color(canvas,token,a)return P.color(canvas,token,a)end
local function full(w,x,y,width,height)
 return x==0 and y==0 and width==w:getWidth() and height==w:getHeight()
end
function N.paint(w,delegate,kind,...)
 if kind=='slider'then U.ComponentStyles.geometry(w)end
 local rect,border=w.drawRect,w.drawRectBorder
 if not rect or not border then return delegate(w,...)end
 local canvas=P.canvas(w,N.player(w),families[kind]or 'window',rect,border)
 local saved,borrowed={},{}
 -- Only conventional neutral presentation fields. Coloured warnings, item
 -- swatches, transparent overlays and live content are not generic chrome.
 for field,token in pairs(fields)do
  local c=w[field]
  if type(c)=='table' and P.neutral(c.r,c.g,c.b)then
   saved[field]=c
   if field=='backgroundColor' then token=kind=='button'and 'raised'or kind=='frame'and 'window'or 'panel'end
   borrowed[field]=color(canvas,token,c.a);w[field]=borrowed[field]
  end
 end
 local wrappers={}
 for _,name in ipairs({'drawRect','drawRectStatic','drawRectBorder','drawRectBorderStatic'})do
  local raw=w[name]
  if raw then
   local edge=name=='drawRectBorder'or name=='drawRectBorderStatic'
   local fixed=name=='drawRectStatic'or name=='drawRectBorderStatic'
   local c=fixed and P.canvas(w,N.player(w),families[kind]or 'window',w.drawRectStatic or rect,w.drawRectBorderStatic or border)or canvas
   wrappers[name]=function(self,x,y,width,height,a,r,g,b,...)
    local neutral=P.neutral(r,g,b)
    -- Palette loans have already changed RGB. Match the exact borrowed field
    -- as well as original neutral native constants, only in known frame areas.
    for _,v in pairs(borrowed)do if r==v.r and g==v.g and b==v.b then neutral=true;break end end
    local frame=full(self,x,y,width,height)
    if kind=='frame' and self.titleBarHeight and x==0 and width==self:getWidth()then
     local title=self:titleBarHeight()
     frame=frame or(y==0 and height==title)or(y==title and height==self:getHeight()-title)
    end
    if frame and neutral then
     if edge then return P.edge(c,x,y,width,height,self.joypadFocused and 'accent'or 'border',a)end
     local token=kind=='button'and 'raised'or kind=='frame'and 'window'or 'panel'
     if borrowed.backgroundColorMouseOver and r==borrowed.backgroundColorMouseOver.r and g==borrowed.backgroundColorMouseOver.g then token='hover'end
     return P.fill(c,x,y,width,height,token,a)
    end
    return raw(self,x,y,width,height,a,r,g,b,...)
   end
  end
 end
 local texture=w.drawTextureScaled
 if texture then wrappers.drawTextureScaled=function(self,tex,x,y,width,height,a,r,g,b,...)
  if kind=='tabs' and ISTabPanel and y==0 and height==self.tabHeight-1 and(tex==ISTabPanel.tabSelected or tex==ISTabPanel.tabUnSelected)then
   local selected=tex==ISTabPanel.tabSelected
   P.fill(canvas,x,y,width,height,selected and 'selected'or 'raised',a)
   local index=self:getActiveViewIndex()
   if selected and index and not self.isDragging and x==self:getTabX(index)then P.fill(canvas,x,height-2,width,2,'accent',a,0)end
   return
  end
  if kind=='frame' and ((self.titlebarbkg and tex==self.titlebarbkg)or(self.statusbarbkg and tex==self.statusbarbkg))then
   return P.fill(canvas,x,y,width,height,'raised',a,0)
  end
  if kind=='scroll' and tex==self.midtex then
   return P.fill(canvas,x,y,width,height,self.scrolling and 'accent'or 'strong',a,2)
  end
  return texture(self,tex,x,y,width,height,a,r,g,b,...)
 end end
 if kind=='scroll' and w.drawTexture then
  local draw=w.drawTexture
  wrappers.drawTexture=function(self,tex,x,y,a,r,g,b,...)
   if tex==self.toptex or tex==self.bottex then
    local c=color(canvas,self.scrolling and 'accent'or 'strong');r,g,b=c.r,c.g,c.b
   end
   return draw(self,tex,x,y,a,r,g,b,...)
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
     local bg,hover,edge=combo.backgroundColor,combo.backgroundColorMouseOver,combo.borderColor
     combo.backgroundColor=color(proxy,'panel',bg and bg.a)
     combo.backgroundColorMouseOver=color(proxy,'hover',hover and hover.a)
     combo.borderColor=color(proxy,'border',edge and edge.a)
     local result=P.pack(pcall(N.paint,self,delegate,kind,...))
     combo.backgroundColor,combo.backgroundColorMouseOver,combo.borderColor=bg,hover,edge
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

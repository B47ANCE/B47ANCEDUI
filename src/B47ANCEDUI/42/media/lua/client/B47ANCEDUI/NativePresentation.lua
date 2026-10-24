-- Private presentation adapters. Never change native input, geometry or values.
require 'B47ANCEDUI/API'
require 'ISUI/ISButton'
require 'ISUI/ISResizeableButton'
require 'ISUI/ISToolTip'
require 'ISUI/ISToolTipInv'
local U=B47ANCEDUI
if U.NativePresentation then return U.NativePresentation end
local P={};U.NativePresentation=P
local T,R,S=U.Theme,U.Renderer,U.ComponentStyles
function P.pack(...)return {n=select('#',...),...}end
function P.native(w,class)
 return w and class and not w.b47Styled and w.Type==class.Type and w.prerender==class.prerender and w.render==class.render
end
function P.neutral(r,g,b)return r and g and b and math.abs(r-g)<.0001 and math.abs(r-b)<.0001 end
function P.equal(a,b)return a and b and math.abs(a-b)<.0001 end
-- Temporary draw interception preserves inherited methods and all return values,
-- including nils. Restore before propagating a native exception.
function P.around(w,delegate,wrappers,...)
 local saved={}
 for key,wrapper in pairs(wrappers)do saved[key]={rawget(w,key)};w[key]=wrapper end
 local result=P.pack(pcall(delegate,w,...))
 for key,value in pairs(saved)do w[key]=value[1]end
 if not result[1]then error(result[2],0)end
 return unpack(result,2,result.n)
end
function P.canvas(w,player,family,rect,border)
 return {parent=w,playerNum=player or 0,b47AppearanceScope='B47ANCEDUI',b47StyleFamily=family,
  b47RawRect=function(_,...)return rect(w,...)end,
  b47RawBorder=function(_,...)return border(w,...)end}
end
function P.color(canvas,token,alpha)
 local c=T.copy(S.color(canvas,T.colors[token]))
 if alpha~=nil then c.a=alpha end
 return c
end
function P.fill(canvas,x,y,width,height,token,alpha,radius)
 if alpha~=nil and alpha<=0 then return end
 local c=P.color(canvas,token,alpha)
 if token=='window' or token=='panel' or token=='raised'then
  local inherited=alpha~=nil and alpha or U.Appearance.alpha(canvas)
  c.a=S.number(canvas,'opacity',inherited*100)/100
 end
 return R.roundedRect(canvas,x,y,width,height,c,radius or 4)
end
function P.edge(canvas,x,y,width,height,token,alpha,radius)
 if token=='accent' and S.number(canvas,'borderWidth',1)==0 then
  -- Ordinary borders may be hidden; keyboard/controller focus stays visible.
  local focus={parent=canvas,b47StyleSafe=true,b47RawRect=canvas.b47RawRect,b47RawBorder=canvas.b47RawBorder}
  return R.roundedBorder(focus,x,y,width,height,P.color(canvas,token,alpha),radius or 4)
 end
 return R.roundedBorder(canvas,x,y,width,height,P.color(canvas,token,alpha),radius or 4)
end
local function frame(w,class,player,active,method,family)
 if not P.native(w,class)then return false end
 local delegate=w[method]
 w[method]=function(self,...)
  if not active()then return delegate(self,...)end
  local rect,border=self.drawRect,self.drawRectBorder
  local canvas=P.canvas(self,player,family,rect,border)
  return P.around(self,delegate,{
   drawRect=function(target,x,y,width,height,a,r,g,b,...)
    if x==0 and y==0 and width==target:getWidth() and height==target:getHeight() and P.neutral(r,g,b)then
     return P.fill(canvas,x,y,width,height,'window')
    end
    return rect(target,x,y,width,height,a,r,g,b,...)
   end,
   drawRectBorder=function(target,x,y,width,height,a,r,g,b,...)
    if x==0 and y==0 and width==target:getWidth() and height==target:getHeight() and P.neutral(r,g,b)then
     return P.edge(canvas,x,y,width,height,'border')
    end
    return border(target,x,y,width,height,a,r,g,b,...)
   end},...)
 end
 return true
end
function P.frame(w,class,player,active,method,family)
 return frame(w,class,player,active,method or 'prerender',family or 'window')
end
function P.tooltip(w,player,active)
 if not w then return false end
 if w.b47NativeTooltip then
  w.b47NativeTooltip.player=player;w.b47NativeTooltip.active=active;return true
 end
 local class=w.Type==ISToolTipInv.Type and ISToolTipInv or ISToolTip
 local state={player=player,active=active}
 -- Generic tips paint in both phases; inventory tips surround ObjectTooltip.
 if not P.native(w,class)then return false end
 for _,method in ipairs(class==ISToolTipInv and {'render'}or {'prerender','render'})do
 local delegate=w[method]
 w[method]=function(self,...)
  if not state.active()then return delegate(self,...)end
  local rect,border=self.drawRect,self.drawRectBorder
  local canvas=P.canvas(self,state.player,'tooltip',rect,border)
  return P.around(self,delegate,{
   drawRect=function(target,x,y,width,height,a,r,g,b,...)
    if x==0 and y==0 and width==target:getWidth() and height==target:getHeight() and P.neutral(r,g,b)then return P.fill(canvas,x,y,width,height,'window')end
    return rect(target,x,y,width,height,a,r,g,b,...)
   end,
   drawRectBorder=function(target,x,y,width,height,a,r,g,b,...)
    if x==0 and y==0 and width==target:getWidth() and height==target:getHeight() and (P.neutral(r,g,b)or(class==ISToolTip and P.equal(a,.5)and P.equal(r,.9)and P.equal(g,.9)and b==1))then return P.edge(canvas,x,y,width,height,'border')end
    return border(target,x,y,width,height,a,r,g,b,...)
   end},...)
 end
 end
 w.b47NativeTooltip=state;return true
end
function P.button(w,player,active)
 if not w then return false end
 if w.b47NativeButton then return true end
 local class=w.Type==ISResizableButton.Type and ISResizableButton or ISButton
 if not P.native(w,class)then return false end
 local delegate=w.prerender
 w.prerender=function(self,...)
  if not active() or self.altColor or self.blinkBG then return delegate(self,...)end
  local rect,border=self.drawRect,self.drawRectBorder
  local canvas=P.canvas(self,player,'button',rect,border)
  return P.around(self,delegate,{
   drawRect=function(target,x,y,width,height,a,r,g,b,...)
    if x==0 and y==0 and width==target:getWidth() and height==target:getHeight() and P.neutral(r,g,b)then
     return P.fill(canvas,x,y,width,height,r>=.6 and 'selected' or r>.15 and 'hover' or 'raised',a)
    end
    return rect(target,x,y,width,height,a,r,g,b,...)
   end,
   drawRectBorder=function(target,x,y,width,height,a,r,g,b,...)
    if x==0 and y==0 and width==target:getWidth() and height==target:getHeight() and P.neutral(r,g,b)then return P.edge(canvas,x,y,width,height,self.joypadFocused and 'accent' or 'border',a)end
    return border(target,x,y,width,height,a,r,g,b,...)
   end},...)
 end
 w.b47NativeButton=true;return true
end
return P

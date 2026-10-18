-- Pixel occupancy fixtures test geometry/alpha, not native graphics performance.
local API=require 'B47ANCEDUI/API'
local UI=API.forMod('ThemeFixture')
local plain=UI.Button:new(0,0,90,29,'Original')
assert(plain:getHeight()==29,'Existing explicit dimensions changed')
local last=0
local target={};local callback=function() return 'native' end
for _,size in ipairs({'small','normal','large'}) do
 local b=UI.Button.sized(size,0,0,100,'Action',target,callback,'intent')
 assert(b:getHeight()>last and b.b47AppearanceScope=='ThemeFixture')
 assert(b.b47ButtonSize==size and b.b47Padding>=8)
 assert(b.target==target and b.onclick==callback and b.onClickArgs[1]=='intent','Native callback contract changed')
 last=b:getHeight()
end
assert(not pcall(UI.Button.sized,'huge',0,0,100,'Action'))
local before=UI.Theme.buttonSize('large').height
local manager=getTextManager
getTextManager=function() return {getFontHeight=function() return 36 end} end
assert(UI.Theme.buttonSize('large').height>before,'Large game font clipped')
getTextManager=manager
local T,R=UI.Theme,UI.Renderer
for width=1,40 do for height=1,24 do
 local pixels,calls={},0
 local w={getWidth=function() return width end,getHeight=function() return height end}
 function w:drawRect(x,y,ww,hh,a)
  calls=calls+1
  assert(ww>0 and hh>0 and x>=0 and y>=0 and x+ww<=width and y+hh<=height)
  assert(a==.4,'Opacity changed')
  for xx=x,x+ww-1 do for yy=y,y+hh-1 do
   local key=xx..':'..yy;assert(not pixels[key],'Alpha was layered within a pass');pixels[key]=true
  end end
 end
 function w:drawRectBorder(x,y,ww,hh,a)
  self:drawRect(x,y,ww,1,a)
  if hh>1 then self:drawRect(x,y+hh-1,ww,1,a) end
  if hh>2 then self:drawRect(x,y+1,1,hh-2,a);if ww>1 then self:drawRect(x+ww-1,y+1,1,hh-2,a) end end
 end
 R.roundedRect(w,0,0,width,height,{a=.4,r=1,g=1,b=1},999)
 assert(calls<=17,'Unbounded corner cost')
 local fill=pixels;pixels={};calls=0
 R.roundedBorder(w,0,0,width,height,{a=.4,r=1,g=1,b=1},999)
 assert(calls<=34,'Unbounded border cost')
 for key in pairs(pixels) do assert(fill[key],'Border outside fill') end
end end
local draws={}
local raw=function(_,...) draws[#draws+1]={...} end
local w={drawRect=raw,drawRectBorder=raw,getWidth=function() return 80 end,getHeight=function() return 32 end}
local callback=function() return 'native' end;w.onclick=callback
R.round(w,4);local wrapped=w.drawRect;R.round(w,6)
assert(w.drawRect==wrapped and w.onclick==callback and w.b47RawRect==raw)
w:drawRect(0,8,80,2,.4,1,1,1)
assert(#draws==1 and draws[1][2]==8,'Non-backing geometry changed')
print('PASS OFFLINE three sizes, font scaling, explicit geometry, bounded rounded fill/perimeter, single-pass alpha and instance callback isolation')

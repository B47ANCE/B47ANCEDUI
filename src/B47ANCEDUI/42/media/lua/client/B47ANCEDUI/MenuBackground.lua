-- Local main-menu presentation only. No world RNG, ticks, networking or saves.
require 'B47ANCEDUI/API'
require 'OptionScreens/MainScreen'
local U=B47ANCEDUI
if U.MenuBackground then return U.MenuBackground end
local B={};U.MenuBackground=B
local path='media/ui/B47ANCEDUI/'
local nativePre=MainScreen.prerender
local imageWidth,imageHeight=1672,941
-- Rectangles extend behind the opaque bezels; the artwork supplies rounded masks.
local apertures={{791,157,280,200},{1157,157,278,200},{791,414,280,199},{1157,414,278,199}}
local texture,frames
local function loadArt()
 if texture then return true end
 local art=getTexture(path..'SecurityRoom.png')
 if not art then return false end
 local loaded={}
 for i=1,8 do
  loaded[i]=getTexture(path..'Static'..i..'.png')
  if not loaded[i] then return false end
 end
 texture,frames=art,loaded;return true
end
function B.newSession(seed)
 -- Private Park-Miller generator: never reseed or consume gameplay randomness.
 local value=math.floor(seed)%2147483646+1
 local function random(n) value=(value*16807)%2147483647;return value%n end
 local session={elapsed=0,monitors={}}
 for i=1,4 do
  session.monitors[i]={delay=(i-1)*.19+random(700)/1000,
   boot=1.2+random(1400)/1000,period=7+random(4000)/1000,
   speed=7+random(4),phase=random(8),offset=random(1000)/1000}
 end
 return session
end
function B.sample(m,time)
 local age=time-m.delay
 if age<0 then return 'off',1,0 end
 local frame=(math.floor(age*m.speed)+m.phase)%8+1
 local noise=age<m.boot or (age-m.boot)%m.period<.45
 return noise and 'static' or 'signal',frame,(age*.13+m.offset)%1
end
function B.geometry(width,height)
 local scale=math.min(width/imageWidth,height/imageHeight)
 return (width-imageWidth*scale)/2,(height-imageHeight*scale)/2,scale
end
function B.draw(screen,session,dt)
 session.elapsed=session.elapsed+math.max(0,math.min(tonumber(dt) or 0,100))/1000
 local w,h=screen:getWidth(),screen:getHeight()
 local x,y,s=B.geometry(w,h)
 screen:drawRect(0,0,w,h,1,0,0,0)
 for i,a in ipairs(apertures) do
  local ax,ay,aw,ah=x+a[1]*s,y+a[2]*s,a[3]*s,a[4]*s
  local mode,frame,scan=B.sample(session.monitors[i],session.elapsed)
  screen:drawRect(ax,ay,aw,ah,1,.012,.018,.015)
  if mode~='off' then
   screen:drawTextureScaled(frames[frame],ax,ay,aw,ah,mode=='static' and .26 or .045,1,1,1)
   screen:drawRect(ax,ay+scan*(ah-3*s),aw,3*s,.08,.6,.65,.6)
   if mode=='signal' then
    local font=UIFont.Small
    local text=U.Renderer.fit(getText('UI_B47ANCEDUI_NoSignal'),math.max(0,aw-24*s),font)
    screen:drawTextCentre(text,ax+aw/2,ay+ah/2-getTextManager():getFontHeight(font)/2,.48,.53,.49,1,font)
   end
  end
 end
 screen:drawTextureScaled(texture,x,y,imageWidth*s,imageHeight*s,1,1,1,1)
end
function B.apply(screen)
 if not screen or screen.inGame or screen.b47MenuBackground or not screen.bottomPanel
  or screen.prerender~=nativePre or not loadArt() then return false end
 screen.b47MenuBackground=B.newSession(getTimestampMs())
 screen.prerender=function(self,...)
  if self.inGame then return nativePre(self,...) end
  B.draw(self,self.b47MenuBackground,UIManager.getMillisSinceLastRender())
  local w,h=self:getWidth(),self:getHeight()
  local margin=math.max(16,w*.025)
  local menu=self.bottomPanel
  local menuWidth=math.max(self.maxMenuItemWidth or 0,w*.28)
  local menuHeight=menu:getHeight()
  local top=math.max(margin,h-menuHeight-margin)
  local originalDraw=self.drawTextureScaled
  local previousRaw=rawget(self,'drawTextureScaled')
  -- Only redirect this instance's logo draw during the native prerender call.
  -- Native delay, fading, demo notices and state guards still execute once.
  self.drawTextureScaled=function(owner,tex,tx,ty,tw,th,...)
   if tex==owner.logoTexture then
    local scale=math.max(0,math.min(menuWidth/tex:getWidth(),(top-margin*2)/tex:getHeight()))
    tx,ty,tw,th=margin,margin,tex:getWidth()*scale,tex:getHeight()*scale
   end
   return originalDraw(owner,tex,tx,ty,tw,th,...)
  end
  local ok,result=pcall(nativePre,self,...)
  self.drawTextureScaled=previousRaw
  if not ok then error(result) end
  menu:setX(margin);menu:setY(top);menu:setWidth(menuWidth)
  for _,child in pairs(menu:getChildren()) do
   if child.Type=='ISLabel' then child:setWidth(menuWidth) end
  end
  return result
 end
 return true
end
local function applyCurrent() B.apply(MainScreen.instance) end
Events.OnMainMenuEnter.Add(applyCurrent)
Events.OnResetLua.Add(applyCurrent)
applyCurrent()
return B

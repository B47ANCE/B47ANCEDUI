-- Local main-menu presentation only. No world RNG, ticks, networking or saves.
require 'B47ANCEDUI/API'
require 'OptionScreens/MainScreen'
require 'ISUI/ISLabel'
local U=B47ANCEDUI
if U.MenuBackground then return U.MenuBackground end
local B={};U.MenuBackground=B
local path='media/ui/B47ANCEDUI/'
local nativePre=MainScreen.prerender
local imageWidth,imageHeight=2172,724
-- Rectangles extend behind the opaque bezels; the artwork supplies rounded masks.
local apertures={{739,173,148,101},{946,173,151,102},{739,312,148,100},{946,312,151,99}}
local texture,frames
local function loadArt()
 if texture then return true end
 local art=getTexture(path..'SecurityRoomPanorama.png')
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
   boot=1+random(59001)/1000,
   speed=7+random(4),phase=random(8),offset=random(1000)/1000}
 end
 return session
end
function B.sample(m,time)
 local age=time-m.delay
 if age<0 then return 'off',1,0 end
 local frame=(math.floor(age*m.speed)+m.phase)%8+1
 local noise=age<m.boot
 return noise and 'static' or 'signal',frame,(age*.13+m.offset)%1
end
function B.geometry(width,height)
 -- Uniform cover scaling, focused on the menu/desk group on narrow viewports.
 -- Wider screens reveal the continuous room extension to the right.
 local scale=math.max(width/imageWidth,height/imageHeight)
 local x=math.min(0,math.max(width-imageWidth*scale,width/2-680*scale))
 -- Keep the continuous overhead pipe and lamp visible; ultrawide crops floor.
 return x,0,scale
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
function B.layout(screen,menuWidth,top,bottom)
 if U.NativeMenus then U.NativeMenus.apply(screen) end
 local menu=screen.bottomPanel
 local entries={}
 for _,child in pairs(menu:getChildren()) do
  local actionable=child.Type=='ISLabel' and (child.b47NativeMenu or child.onMouseDown and child.onMouseDown~=ISLabel.onMouseDown)
   or child.Type=='ISButton' and child.onclick
  if actionable and child~=screen.controllerLabel and child~=screen.controllerLabel2 and child~=screen.abutton then
   -- Keep original order independent of positions assigned by this layout.
   if child.b47MenuOrder==nil or child.b47MenuAssignedY and child.y~=child.b47MenuAssignedY then
    child.b47MenuOrder=child.y or 0
   end
   if not child.getIsVisible or child:getIsVisible() then entries[#entries+1]=child end
  end
 end
 table.sort(entries,function(a,b)
  if a.b47MenuOrder~=b.b47MenuOrder then return a.b47MenuOrder<b.b47MenuOrder end
  return tostring(a.internal or a.name or a.title or '')<tostring(b.internal or b.name or b.title or '')
 end)
 if #entries==0 then return end
 local available=math.max(1,bottom-top)
 local noteHeight=math.min(getTextManager():getFontHeight(UIFont.Small)+4,available/(#entries*2))
 local reserved=0
 for _,child in ipairs(entries) do if child.b47MenuHasNote then reserved=reserved+noteHeight end end
 local row=(available-reserved)/#entries
 local zoom=math.min(1.9,screen:getHeight()/600)
 for _,child in ipairs(entries) do
  local font=child.font or UIFont.Large
  local text=child.translation or child.name or child.title or ''
  local width=getTextManager():MeasureStringX(font,text)
  local height=getTextManager():getFontHeight(font)
  zoom=math.min(zoom,(menuWidth-48)/math.max(1,width),row*.65/math.max(1,height))
 end
 zoom=math.max(.05,zoom)
 local cursor=0
 for _,child in ipairs(entries) do
  local text=child.translation or child.name or child.title or ''
  local font=child.font or UIFont.Large
  local scalable=child.b47NativeMenu==true
  child.b47MenuScale=scalable and zoom or nil
  local note=child.b47MenuHasNote and noteHeight or 0
  child.b47MenuPrimaryHeight=note>0 and row or nil
  child.b47MenuNoteHeight=note>0 and note or nil
  local width=note>0 and menuWidth or math.min(menuWidth,math.max(1,getTextManager():MeasureStringX(font,text)*(scalable and zoom or 1)+4))
  child:setX((menuWidth-width)/2);child:setY(cursor)
  child.b47MenuAssignedY=cursor
  child:setWidth(width);child:setHeight(row+note)
  cursor=cursor+row+note
 end
 menu:setHeight(available)
end
function B.apply(screen)
 if not screen or screen.inGame or screen.b47MenuBackground or not screen.bottomPanel
  or screen.prerender~=nativePre or not loadArt() then return false end
 screen.b47MenuBackground=B.newSession(getTimestampMs())
 screen.prerender=function(self,...)
  if self.inGame then return nativePre(self,...) end
  -- Runtime gain only: MainScreenState.exit restores the configured music gain.
  -- Never write saved options or mute world/UI sound categories.
  local sound=getSoundManager()
  if sound and sound:getMusicVolume()~=0 then sound:setMusicVolume(0) end
  B.draw(self,self.b47MenuBackground,UIManager.getMillisSinceLastRender())
  local w,h=self:getWidth(),self:getHeight()
  local margin=math.max(16,w*.025)
  local menu=self.bottomPanel
  local artX,_,artScale=B.geometry(w,h)
  local menuWidth=math.min(math.max(self.maxMenuItemWidth or 0,w*.28),480*artScale)
  local menuX=math.max(margin,math.min(w-menuWidth-margin,artX+260*artScale-menuWidth/2))
  local logoScale=math.min(menuWidth/self.logoTexture:getWidth(),h*.34/self.logoTexture:getHeight())
  local logoHeight=self.logoTexture:getHeight()*logoScale
  local top=margin+logoHeight+margin*.7
  local originalDraw=self.drawTextureScaled
  local previousRaw=rawget(self,'drawTextureScaled')
  -- Only redirect this instance's logo draw during the native prerender call.
  -- Native delay, fading, demo notices and state guards still execute once.
  self.drawTextureScaled=function(owner,tex,tx,ty,tw,th,...)
   if tex==owner.logoTexture then
    tw,th=tex:getWidth()*logoScale,logoHeight
    tx,ty=menuX+(menuWidth-tw)/2,margin
   end
   return originalDraw(owner,tex,tx,ty,tw,th,...)
  end
  local ok,result=pcall(nativePre,self,...)
  self.drawTextureScaled=previousRaw
  if not ok then error(result) end
  menu:setX(menuX);menu:setY(top);menu:setWidth(menuWidth)
  B.layout(self,menuWidth,top,h-margin)
  return result
 end
 return true
end
local function applyCurrent() B.apply(MainScreen.instance) end
Events.OnMainMenuEnter.Add(applyCurrent)
Events.OnResetLua.Add(applyCurrent)
applyCurrent()
return B

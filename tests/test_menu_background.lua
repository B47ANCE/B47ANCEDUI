-- Offline integration fixture: rendering order, lifecycle and native invariants.
local U=require 'B47ANCEDUI/API'
local oldMain,oldEvents,oldTexture,oldClock,oldManager=MainScreen,Events,getTexture,getTimestampMs,UIManager
local events={}
local function event() return {Add=function(f) events[#events+1]=f end} end
Events={OnMainMenuEnter=event(),OnResetLua=event()}
local missing=true
local logo={getWidth=function() return 600 end,getHeight=function() return 300 end}
getTexture=function(p) if missing then return nil end;return {path=p} end
getTimestampMs=function() return 123456789 end
UIManager={getMillisSinceLastRender=function() return 16 end}
local draws,nativeCalls={},0
local throws=false
MainScreen={prerender=function(self)
 nativeCalls=nativeCalls+1
 self:drawTextureScaled(self.logoTexture,0,0,600,300,1,1,1,1)
 if throws then error('native failure') end
 return 'native'
end}
package.loaded['OptionScreens/MainScreen']=MainScreen
local function screen(inGame)
 local label={Type='ISLabel',name='OPTIONS',b47NativeMenu=true,font=UIFont.Large,y=0,width=300,
  setWidth=function(self,w) self.width=w end,setHeight=function(self,h) self.height=h end,
  setX=function(self,x) self.x=x end,setY=function(self,y) self.y=y end}
 local menu={height=420,children={label},getHeight=function(self)return self.height end,
  setX=function(self,x) self.x=x end,setY=function(self,y) self.y=y end,
  setWidth=function(self,w) self.width=w end,setHeight=function(self,h) self.height=h end,getChildren=function(self)return self.children end}
 local s={inGame=inGame,bottomPanel=menu,logoTexture=logo,maxMenuItemWidth=240,
  prerender=MainScreen.prerender,width=1600,height=900}
 function s:getWidth() return self.width end
 function s:getHeight() return self.height end
 function s:drawRect(...) draws[#draws+1]={kind='rect',...} end
 function s:drawTextCentre(...) draws[#draws+1]={kind='text',...} end
 function s:drawTextureScaled(tex,...) draws[#draws+1]={kind='texture',texture=tex,...} end
 return s
end
MainScreen.instance=screen(false)
local B=require 'B47ANCEDUI/MenuBackground'
local main=MainScreen.instance
assert(main.prerender==MainScreen.prerender,'Missing art must keep native rendering')
missing=false
assert(not B.apply(screen(true)),'Esc background must remain native')
local modified=screen(false);modified.prerender=function()end
assert(not B.apply(modified),'Do not overwrite another menu renderer')
assert(B.apply(main) and not B.apply(main))
local wrapped,session,draw=main.prerender,main.b47MenuBackground,main.drawTextureScaled
events[1]();events[2]()
assert(main.prerender==wrapped and main.b47MenuBackground==session,'Do not restart/wrap twice')
assert(#events==2)
local states={}
for i,m in ipairs(session.monitors) do
 states[m.delay..':'..m.phase]=true
 local mode=B.sample(m,m.delay-.001);assert(mode=='off')
 mode=B.sample(m,m.delay+.1);assert(mode=='static')
 mode=B.sample(m,m.delay+m.boot+1);assert(mode=='signal')
 assert(m.boot>=1 and m.boot<=60)
 for _,later in ipairs({1,60,600,3600}) do
  mode=B.sample(m,m.delay+m.boot+later);assert(mode=='signal','Static restarted after initial acquisition')
 end
 for t=0,100,.13 do local _,frame,scan=B.sample(m,t);assert(frame>=1 and frame<=8 and scan>=0 and scan<=1) end
end
local count=0;for _ in pairs(states)do count=count+1 end;assert(count==4)
assert(B.newSession(123456790).monitors[1].delay~=session.monitors[1].delay)
session.elapsed=5
assert(main:prerender()=='native' and nativeCalls==1)
assert(main.drawTextureScaled==draw,'Temporary logo draw override leaked')
local artIndex,logoIndex
for i,d in ipairs(draws)do
 if d.texture and d.texture.path and d.texture.path:find('SecurityRoom') then artIndex=i end
  if d.texture==logo then logoIndex=i;assert(math.abs(d[1]+d[3]/2-264)<.001 and d[3]<=448.001) end
end
assert(draws[1].kind=='rect' and artIndex and logoIndex>artIndex,'Layers in wrong order')
assert(main.bottomPanel.x==40 and main.bottomPanel.y<400)
local item=main.bottomPanel.children[1]
assert(math.abs(item.x+item.width/2-224)<.001 and item.b47MenuScale>1)
-- A later-added item joins without another boot; hidden/removed entries free space.
local extra=screen(false).bottomPanel.children[1]
extra.name='OTHER MOD';extra.y=100;extra.getIsVisible=function(self)return not self.hidden end
main.bottomPanel.children[2]=extra
main:prerender()
local twoHeight=item.height
assert(extra.y>item.y and math.abs(extra.x+extra.width/2-224)<.001)
extra.hidden=true;main:prerender();assert(item.height>twoHeight)
extra.hidden=false;main:prerender();assert(item.height==twoHeight)
main.bottomPanel.children[2]=nil;main:prerender();assert(item.height>twoHeight)
for i=2,40 do
 local e=screen(false).bottomPanel.children[1];e.name='MOD '..i;e.y=i*100
 main.bottomPanel.children[i]=e
end
main:prerender()
local last=main.bottomPanel.children[40]
assert(last.y+last.height<=main.bottomPanel.height+.001 and last.b47MenuScale<1)
for _,size in ipairs({{1280,720},{1024,768},{3440,1440}})do
 local x,y,s=B.geometry(size[1],size[2]);assert(x>=0 and y>=0 and 1672*s<=size[1]+.001 and 941*s<=size[2]+.001)
end
throws=true;assert(not pcall(main.prerender,main));assert(main.drawTextureScaled==draw)
MainScreen,Events,getTexture,getTimestampMs,UIManager=oldMain,oldEvents,oldTexture,oldClock,oldManager
package.loaded['OptionScreens/MainScreen']=oldMain
print('PASS offline background lifecycle, timing, aspect fit, layering, fallback, Esc exclusion and native exception restoration')

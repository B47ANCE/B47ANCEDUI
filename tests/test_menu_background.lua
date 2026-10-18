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
 local label={Type='ISLabel',width=300,setWidth=function(self,w) self.width=w end}
 local menu={height=420,children={label},getHeight=function(self)return self.height end,
  setX=function(self,x) self.x=x end,setY=function(self,y) self.y=y end,
  setWidth=function(self,w) self.width=w end,getChildren=function(self)return self.children end}
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
 mode=B.sample(m,m.delay+m.boot+m.period+.1);assert(mode=='static')
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
 if d.texture==logo then logoIndex=i;assert(d[1]==40 and d[3]<=448.001) end
end
assert(draws[1].kind=='rect' and artIndex and logoIndex>artIndex,'Layers in wrong order')
assert(main.bottomPanel.x==40 and main.bottomPanel.y==440)
assert(math.abs(main.bottomPanel.children[1].width-448)<.001)
for _,size in ipairs({{1280,720},{1024,768},{3440,1440}})do
 local x,y,s=B.geometry(size[1],size[2]);assert(x>=0 and y>=0 and 1672*s<=size[1]+.001 and 941*s<=size[2]+.001)
end
throws=true;assert(not pcall(main.prerender,main));assert(main.drawTextureScaled==draw)
MainScreen,Events,getTexture,getTimestampMs,UIManager=oldMain,oldEvents,oldTexture,oldClock,oldManager
package.loaded['OptionScreens/MainScreen']=oldMain
print('PASS offline background lifecycle, timing, aspect fit, layering, fallback, Esc exclusion and native exception restoration')

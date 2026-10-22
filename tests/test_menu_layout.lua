-- Fixture-only table iterator; the runtime global remains unavailable.
local function next(t)for key,value in pairs(t)do return key,value end end
-- Disposable local preferences only; never reads/writes a real player profile.
local filename='B47ANCEDUI/main-menu-layout.txt'
local files,reads,writes,closed={},0,0,0
getFileReader=function(name,create)
 assert(create==false);if not files[name] then return end
 local lines={};for line in files[name]:gmatch('[^\n]+') do lines[#lines+1]=line end
 local i=0;return {readLine=function() reads=reads+1;i=i+1;return lines[i] end,close=function()closed=closed+1 end}
end
getFileWriter=function(name,create,append)
 assert(name==filename and create and not append)
 return {write=function(_,text) writes=writes+1;files[name]=text end,close=function() closed=closed+1 end}
end
local function reload() package.loaded['B47ANCEDUI/MenuLayout']=nil;return require 'B47ANCEDUI/MenuLayout' end
local L=reload();assert(next(L.get())==nil and writes==0)
files[filename]='schema=1\nmenu=0.1,0.2,0.3,0.4\nlogo=0.6,0.1,0.2\n'
L=reload();local profile=L.get();assert(profile.menu.x==.1 and profile.logo.w==.2)
local oldReads=reads;profile.menu.x=.9;assert(L.get().menu.x==.1 and reads==oldReads,'Cached profile escaped through mutable reference')
for _,text in ipairs({'schema=2\nmenu=0,0,1,1','menu=0,0,1,1','schema=1\nmenu=0,0,1,1,2','schema=1\nmenu=nan,0,1,1','schema=1\nmenu=0,0,1e309,1','schema=1\nlogo=0,0,-1','schema=1\nmenu=-0.1,0,1,1','schema=1\nlogo=0,0,1.1','schema=1\nmenu=os.execute(1)'}) do
 local lines={};for s in text:gmatch('[^\n]+')do lines[#lines+1]=s end
 assert(next(L.parse(lines))==nil,'Invalid/executable profile accepted')
end
local partial=L.parse({'schema=1','menu=0,0,0,1','logo=0.2,0.3,0.4','logo=0,0,1'})
assert(not partial.menu and partial.logo.x==.2,'Valid target did not survive malformed peer/duplicate')
assert(not L.copy({menu={x=0,y=0,w=0/0,h=1}}).menu)
assert(not L.copy({logo={x=0,y=0,w=math.huge}}).logo)
local defaults={menu={x=10,y=20,w=260,h=400},logo={x=30,y=10,w=200,h=100}}
local auto=L.resolve({},defaults,1000,700,2)
assert(auto.menu.x==10 and auto.logo.w==200);auto.logo.w=3;assert(defaults.logo.w==200)
local custom=L.setRect({},'menu',{x=500,y=300,w=300,h=250},1000,700,2)
local both=L.setRect(custom,'logo',{x=20,y=30,w=400,h=20},1000,700,2)
local view=L.resolve(both,defaults,1000,700,2)
assert(view.menu.x==500 and view.menu.h==250 and view.logo.x==20 and view.logo.h==200)
assert(L.resolve(custom,defaults,1000,700,2).logo.x==defaults.logo.x,'Menu move changed untouched logo')
for _,size in ipairs({{1024,768},{1280,720},{1920,1008},{1920,1080},{2560,1440},{3840,2160},{2560,1080},{3440,1440},{5120,1440}}) do
 local w,h=size[1],size[2]
 for _,input in ipairs({both,{menu={x=.99,y=.99,w=.9,h=.9},logo={x=.99,y=.99,w=1}},{menu={x=0,y=0,w=1e-12,h=1e-12},logo={x=0,y=0,w=1e-12}}}) do
  local rects=L.resolve(input,defaults,w,h,2)
  for _,rect in pairs(rects)do assert(rect.x>=0 and rect.y>=0 and rect.w>0 and rect.h>0 and rect.x+rect.w<=w+.001 and rect.y+rect.h<=h+.001) end
  assert(math.abs(rects.logo.w/rects.logo.h-2)<.001)
 end
end
local dragged=L.drag(both,'menu',view.menu,1e6,-1e6,false,1000,700,2)
local rect=L.resolve(dragged,defaults,1000,700,2).menu;assert(rect.x==700 and rect.y==0)
local resized=L.drag(both,'logo',view.logo,-1e6,-1e6,true,1000,700,2)
rect=L.resolve(resized,defaults,1000,700,2).logo;assert(rect.w==100 and rect.h==50)
local zero=L.setRect({},'menu',{x=0,y=0,w=5,h=5},0,0,2);assert(zero.menu.w==1 and zero.menu.h==1)
assert(writes==0,'Live resolution/movement saved per frame')
assert(L.save(both) and writes==1 and not files[filename]:find('function'))
L=reload();assert(math.abs(L.get().logo.w-.4)<1e-8 and math.abs(L.get().menu.y-300/700)<1e-8)
assert(L.save({logo={x=0,y=0,w=1e-12}}));L=reload();assert(L.get().logo.w>0,'Serialization rounded valid positive width to zero')
assert(L.save({}));L=reload();assert(next(L.get())==nil and files[filename]=='schema=1\n','Reset did not restore automatic layout')
assert(L.save(both));local saved=files[filename]
getFileWriter=function()error('denied')end;assert(not L.save({}) and L.get().menu.w==.3)
local didClose=false
getFileWriter=function()return {write=function()error('interrupted')end,close=function()didClose=true end}end
assert(not L.save({}) and didClose and files[filename]==saved and L.get().menu.w==.3)
getFileWriter=function()return {write=function()return false end,close=function()end}end
assert(not L.save({}) and L.get().menu.w==.3)
local count=0
getFileReader=function()return {readLine=function()count=count+1;return string.rep('x',170)end,close=function()closed=closed+1 end}end
L=reload();assert(next(L.get())==nil and count==8)
local before=closed
getFileReader=function()return {readLine=function()error('unreadable')end,close=function()closed=closed+1 end}end
L=reload();assert(next(L.get())==nil and closed==before+1)
package.loaded['B47ANCEDUI/MenuLayout']=nil
print('PASS OFFLINE menu-layout bounded data, independent rects, nine viewport clamps, aspect lock, reload/reset and I/O failures')

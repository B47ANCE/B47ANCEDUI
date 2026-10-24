-- Data and registered geometry contracts; no engine/world objects.
local function model(reader)
 package.loaded['B47ANCEDUI/UILayout']=nil;getFileReader=reader
 return require 'B47ANCEDUI/UILayout'
end
local P=model(nil)
local profile,status=P.parse({'schema=1','Owner.window=.1,.2,.3,.4','Missing.old=.2,.3,.2,.1',
 'bad=nan,0,.2,.2','Bad.zero=0,0,0,.2','../escape=0,0,.1,.1'})
assert(status=='ok' and profile['Owner.window'] and profile['Missing.old'] and not profile.bad and not profile['Bad.zero'])
local clone=P.copy(profile);clone['Owner.window'].x=.9;assert(profile['Owner.window'].x==.1)
assert(select(2,P.parse({'schema=2'}))=='future' and select(2,P.parse({3}))=='invalid')
assert(not P.id('../escape') and not P.id(string.rep('a',97)))
for _,n in ipairs({0/0,math.huge,-math.huge,-1,2})do assert(not P.copy({A={x=n,y=0,w=.1,h=.1}}).A)end
local overflow={'schema=1'};for i=1,129 do overflow[#overflow+1]='A.a'..i..'=0,0,.1,.1'end
assert(select(2,P.parse(overflow))=='read-error')
local writes,closed,text=0,0
getFileWriter=function(name,create,append)
 assert(name=='B47ANCEDUI/in-game-layout.txt' and create and not append)
 return {write=function(_,value)writes=writes+1;text=value end,close=function()closed=closed+1 end}
end
assert(P.save(profile) and writes==1 and closed==1 and text:find('Missing.old=',1,true))
local e=P.entry('Owner.window');e.x=.9;assert(P.entry('Owner.window').x==.1)
getFileWriter=function()return {write=function()error('fixture interrupted')end,close=function()closed=closed+1 end}end
assert(not P.save({}) and P.entry('Owner.window') and closed==2)
local readClosed=false
P=model(function()return {readLine=function()error('fixture unreadable')end,close=function()readClosed=true end}end)
assert(select(2,P.get())=='read-error' and readClosed)
local attempts=0;getFileWriter=function()attempts=attempts+1;return {write=function()end,close=function()end}end
assert(not P.save({}) and attempts==0 and P.save({},true))
P=model(function()error('fixture reader denied')end);assert(select(2,P.get())=='read-error' and not P.save({}))
P=model(function()local i=0;return {readLine=function()i=i+1;return i==1 and 'schema=7' or nil end,close=function()end}end)
assert(select(2,P.get())=='future' and not P.save({}) and P.save({},true))
P=model(nil);local many={};for i=1,129 do many['Owner.a'..i]={x=0,y=0,w=.1,h=.1}end
assert(not P.save(many),'Over-limit profile silently truncated')
local def={minWidth=80,minHeight=40,resizable=true,aspect=2}
local a=P.resolve({x=.9,y=.9,w=.4,h=.4},1000,600,def)
assert(a.w==400 and a.h==200 and a.x==600 and a.y==400)
local b=P.drag(a,50,30,{left=true,top=true},1000,600,def)
assert(math.abs(b.x+b.w-a.x-a.w)<.001 and math.abs(b.y+b.h-a.y-a.h)<.001 and b.w/b.h==2)
local vertical=P.drag({x=20,y=20,w=800,h=600},100,100,{right=true,bottom=true},1920,1080,{resizable=true,resizeWidth=false})
assert(vertical.w==800 and vertical.h==700)
for _,viewport in ipairs({{1024,768},{1920,1080},{3440,1440},{5120,1440},{7680,2160}})do
 local r=P.resolve({x=.9,y=.9,w=.2,h=.3},viewport[1],viewport[2],def)
 assert(r.x>=0 and r.y>=0 and r.x+r.w<=viewport[1] and r.y+r.h<=viewport[2] and r.w/r.h==2)
end
-- Registry keeps definitions isolated and only applies explicit overrides.
require 'B47ANCEDUI/API';local R=B47ANCEDUI.LayoutAssets
local facade=B47ANCEDUI.forMod('Provider').LayoutAssets
local definition={labelKey='UI_Provider_Window',default={x=.1,y=.1,w=.3,h=.3},resizable=true,preview=function()end}
facade.register('window',definition);definition.default.x=.9
assert(R.get('Provider.window').default.x==.1 and not pcall(facade.register,'window',definition))
assert(not pcall(facade.register,'../escape',definition))
local fetched=R.list();fetched[1].default.x=.8;assert(R.get('Provider.window').default.x==.1)
assert(not R.resolve('Provider.window',0,600) and not facade.resolve('window',1000,0/0))
local widget=ISPanel:new(0,0,300,200);widget.minimumWidth=350;widget.minimumHeight=160
assert(not facade.apply('window',widget,0,0,1000,600) and widget.x==0)
getFileWriter=function()return {write=function()end,close=function()end}end
assert(P.save({['Provider.window']={x=.2,y=.2,w=.1,h=.1},['Missing.old']={x=0,y=0,w=.1,h=.1}}))
widget.resizeWidget={resizeFunction=function(target,w,h)assert(target==widget);widget.callback={w,h};target:setWidth(w);target:setHeight(h)end}
assert(facade.apply('window',widget,1000,50,1000,600) and widget.x==1200 and widget.y==170 and widget.width==350 and widget.height==160)
assert(widget.callback[1]==350 and not facade.apply('window',widget,0/0,0,1000,600))
widget.resizeWidget.yonly=true;widget:setWidth(800);assert(facade.apply('window',widget,0,0,1000,600) and widget.width==800)
widget.resizable=false;widget:setHeight(250);assert(facade.apply('window',widget,0,0,1000,600) and widget.height==250)
print('PASS OFFLINE HUD profile bounds/future/error/overflow retention, scaled geometry and scoped provider/native resize contracts')

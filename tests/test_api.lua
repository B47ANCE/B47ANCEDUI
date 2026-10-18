-- Isolated client contract fixtures. Not native rendering or input proof.
UIFont={Small=1,Medium=2,Large=3};Joypad={BButton=1}
getTextManager=function() return {getFontHeight=function() return 14 end,MeasureStringX=function(_,_,s) return #s*7 end} end
local Widget={}
function Widget:new(x,y,w,h,title,target,onclick,...)
 return setmetatable({x=x,y=y,width=w,height=h,title=title,target=target,onclick=onclick,onClickArgs={...},Type='Fixture',children={},playerNum=0},{__index=self})
end
function Widget:prerender() end
function Widget:render() end
function Widget:getWidth() return self.width end
function Widget:getHeight() return self.height end
function Widget:setVisible(v) self.visible=v end
function Widget:isVisible() return self.visible~=false end
function Widget:removeFromUIManager() self.removed=true end
function Widget:setTooltip(t) self.tooltip=t end
function Widget:setAnchorsTBLR(...) self.anchors={...} end
function Widget:setX(v) self.x=v end
function Widget:setY(v) self.y=v end
function Widget:setWidth(v) self.width=v end
function Widget:setHeight(v) self.height=v end
for _,name in ipairs({'ISPanel','ISCollapsableWindowJoypad','ISButton','ISScrollingListBox','ISTextEntryBox','ISModalDialog','ISPanelJoypad','ISSliderPanel'}) do
 _G[name]=setmetatable({},{__index=Widget})
 local path=name=='ISSliderPanel' and 'RadioCom/ISUIRadio/ISSliderPanel' or 'ISUI/'..name
 package.loaded[path]=_G[name]
end
local files={['LegacyOwnerAppearance0.txt']='opacity=65',['LegacyOwnerAppearance1.txt']='opacity=73'}
local closed,writeCount=0,0
getFileReader=function(name,create)
 assert(create==false,'Reading preferences must not create files')
 if files[name]==nil then return end
 return {readLine=function() return files[name] end,close=function() closed=closed+1 end}
end
getFileWriter=function(name)
 return {write=function(_,text) files[name]=text;writeCount=writeCount+1 end,close=function() closed=closed+1 end}
end
local API=require 'B47ANCEDUI/API'
assert(API.apiVersion==1 and API.requireVersion(1)==API)
assert(not pcall(API.requireVersion,2),'Unsupported major accepted')
local options={legacyAppearancePrefix='LegacyOwnerAppearance'}
local owner=API.forMod('Owner',options);local other=API.forMod('Other')
assert(owner==API.forMod('Owner',options),'Repeated registration changed facade')
assert(not pcall(API.forMod,'Owner',{legacyAppearancePrefix='Changed'}))
assert(not pcall(API.forMod,'../Bad') and not pcall(API.forMod,'Valid',{legacyAppearancePrefix='../Bad'}))
assert(owner.Appearance.get(0)==65 and owner.Appearance.get(1)==73 and other.Appearance.get(0)==82)
assert(writeCount==0,'Opening imported preferences must not write')
local button=owner.Button:new(0,0,80,28,'Owned');local nativePre=ISButton.prerender
local styled=button.prerender;owner.skin(button,'button');assert(styled==button.prerender and ISButton.prerender==nativePre)
assert(button.b47AppearanceScope=='Owner')
owner.Appearance.set(0,40)
assert(API.Appearance.alpha(button)==.4 and other.Appearance.get(0)==82 and owner.Appearance.get(1)==73)
local child={parent=button};assert(API.Appearance.scope(child)=='Owner' and API.Appearance.alpha(child)==.4)
assert(owner.Appearance.save(0) and files['B47ANCEDUI/appearance/Owner.0.txt']=='opacity=40\n')
assert(files['LegacyOwnerAppearance0.txt']=='opacity=65','Legacy preference overwritten')
files['B47ANCEDUI/appearance/Reload.0.txt']='opacity=88'
assert(API.forMod('Reload').Appearance.get(0)==88)
for i,value in ipairs({'opacity=nan','opacity=-1','opacity=101','bad'}) do
 local id='Corrupt'..i;files['B47ANCEDUI/appearance/'..id..'.0.txt']=value
 assert(API.forMod(id).Appearance.get(0)==82)
end
owner.Appearance.set(0,0/0);assert(owner.Appearance.get(0)==82)
getFileWriter=function() error('denied') end;assert(owner.Appearance.save(0)==false)
local didClose=false
getFileWriter=function() return {write=function() error('interrupted') end,close=function() didClose=true end} end
assert(owner.Appearance.save(0)==false and didClose,'Interrupted writer leaked')
getFileReader=function() return {readLine=function() error('unreadable') end,close=function() closed=closed+1 end} end
local previous=closed;assert(API.forMod('Unreadable').Appearance.get(0)==82 and closed==previous+1)
assert(B47ANCEDQuartermaster==nil and sendClientCommand==nil,'Standalone UI required gameplay')
print('PASS OFFLINE public API 1, isolated constructors/style, consumer/player scopes, import/defaults/corruption/read/write failure and no gameplay dependency')

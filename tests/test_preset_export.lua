local U=require 'B47ANCEDUI/API';local P=U.StylePresets;local K=require 'B47ANCEDUI/PresetPlugins';local X=require 'B47ANCEDUI/PresetExport'
local files,writes,fail={},0,nil
getTimestampMs=function()return 1780000000000 end
getFileReader=function(path,create)
 assert(not create)
 if fail=='read:'..path then error('denied')end
 local text=files[path];if not text then return end
 local lines={};for line in text:gmatch('([^\n]*)\n')do lines[#lines+1]=line end;local i=0
 return {readLine=function()i=i+1;return lines[i]end,close=function()if fail=='close:'..path then return false end end}
end
getFileWriter=function(path,create,append)
 assert(path:match('^B47ANCEDUI/exports/')and not path:find('%.%.')and create and not append)
 writes=writes+1
 return {write=function(_,text)files[path]=fail=='write:'..path and 'partial\n'or text end,close=function()end}
end
local book=P.new();book=P.set(book,'default','*','all','titleText','#123456')
local before=P.serialize(P.get(0),1);local first=assert(X.export(0,book,'default'))
assert(first.fingerprint==K.fingerprint(files[first.path])and K.parse(files[first.path]))
assert(files['B47ANCEDUI/exports/'..first.id..'.request.txt'],'No completed export request')
assert(P.serialize(P.get(0),1)==before,'Export saved/activated the UI preset')
local second=assert(X.export(0,book,'default'));assert(second.id~=first.id,'New export accidentally updated previous identity')
local previous=assert(X.previous(0,'default'));assert(previous.id==second.id)
assert(not X.export(0,book,'default','update')and not X.export(0,book,'default','update',first.id),'Update did not require explicit expected target')
local changed=P.set(book,'default','*','all','titleText','#ABCDEF')
local updated=assert(X.export(0,changed,'default','update',previous.id));assert(updated.id==second.id and K.parse(files[updated.path]).presets.default.values['*'].all.titleText=='#ABCDEF')
local identity='B47ANCEDUI/exports/identity-0-default.b.txt';local mapping=files[identity]
fail='read:'..identity;local count=writes;assert(not X.export(0,book,'default')and writes==count and files[identity]==mapping);fail=nil
fail='close:'..identity;assert(not X.export(0,book,'default')and writes==count);fail=nil
files[identity]='b47ui-identity=2\n';assert(not X.export(0,book,'default')and writes==count);files[identity]=mapping
local partialID='B47UI.1780000000000.'..K.fingerprint('0:default')..'.3'
fail='write:B47ANCEDUI/exports/'..partialID..'.b47ui.txt'
assert(not X.export(0,book,'default')and not files['B47ANCEDUI/exports/'..partialID..'.request.txt']and files[identity]==mapping);fail=nil
-- A partial new mapping retains the latest valid alternate slot; updates do
-- not rewrite identity files at all.
local nextIdentity='B47ANCEDUI/exports/identity-0-default.a.txt'
fail='write:'..nextIdentity
assert(not X.export(0,book,'default')and X.previous(0,'default').id==second.id)
assert(X.export(0,book,'default','update',second.id),'Update rewrote the identity journal')
fail=nil
local damaged=files[nextIdentity];files[nextIdentity]='b47ui-identity=10\n'
local preserved=writes;assert(not X.export(0,book,'default')and writes==preserved and files[nextIdentity]=='b47ui-identity=10\n','Future identity was overwritten')
files[nextIdentity]=damaged
assert(X.status(updated)=='waiting')
files['B47ANCEDUI/exports/'..updated.id..'.status.txt']='b47ui-stage=1\nid='..updated.id..'\nexport='..updated.fingerprint..'\nstatus=ready\n'
assert(X.status(updated)=='ready');assert(X.status(first)=='waiting')
local handlers={};Events={OnPreUIDraw={Add=function(fn)handlers[fn]=true end,Remove=function(fn)handlers[fn]=nil end}}
local steam=false;getSteamModeActive=function()return steam end
local publication=0;getSteamWorkshopStagedItems=function()publication=publication+1;error('No publication API calls permitted')end
local page={listbox={items={{item={getFolderName=function()return updated.id end}}}}}
page.aboutToShow=function(self)self.shown=true end
page.setVisible=function(self,visible)self.visible=visible end
page.onButtonNext=function(self)self.validated=true end
local workshop={page1=page,page9={setVisible=function()end},fillList=function(self)self.filled=true end,setVisible=function(self,v)self.visible=v end,bringToTop=function(self)self.front=true end}
local menu={setVisible=function(self,v)self.visible=v end}
local options={visible=true,isReallyVisible=function(self)return self.visible end,backButton={}}
options.onOptionMouseDown=function(self,button)assert(button==self.backButton);self.visible=false end
MainScreen={instance={workshopSubmit=workshop,bottomPanel=menu,mainOptions=options}}
assert(not X.openWorkshop(updated));steam=true
assert(X.openWorkshop(updated)and not options.visible and menu.visible==false and workshop.front and page.validated and publication==0)
options.visible=true;options.onOptionMouseDown=function(self)self.modal={}end
assert(X.openWorkshop(updated)and X.pending and not X.openWorkshop(updated),'Pending native Options transition duplicated')
options.modal=nil;options.visible=false
for handler in pairs(handlers)do handler()end
assert(not X.pending and not U._hasEntries(handlers)and publication==0)
print('PASS OFFLINE export verification, new/update identities, reusable-key protection, corrupt/read failures, request/receipt matching, native Steam guards and Options/Workshop handoff; no publication')

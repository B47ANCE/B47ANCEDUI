-- Nonexecuting enabled-mod catalogue and detached local copies. Offline only.
local U=require 'B47ANCEDUI/API';local P=U.StylePresets
local K=require 'B47ANCEDUI/PresetPlugins'
local files,modFiles,writes,closes,mode={}, {},0,0,nil
local function reader(text,path)
 if mode==path..':read'then error('read denied')end
 if not text then return nil end
 local lines={};for line in text:gmatch('([^\n]*)\n')do lines[#lines+1]=line end;local i=0
 return {readLine=function()i=i+1;return lines[i]end,close=function()closes=closes+1;if mode==path..':close'then return false end end}
end
getFileReader=function(path,create)assert(not create);return reader(files[path],path)end
getFileWriter=function(path,create,append)
 assert(create and not append);writes=writes+1
 return {write=function(_,text)files[path]=text end,close=function()end}
end
getModFileReader=function(id,path,create)
 assert(type(id)=='string'and path=='media/B47ANCEDUI/style-pack.txt'and not create)
 return reader(modFiles[id],id)
end
local activated={'One','Two','Future','Broken','Missing','One'}
getActivatedMods=function()return {size=function()return #activated end,get=function(_,i)return activated[i+1]end}end
local book=P.new();book=P.set(book,'default','*','button','pressed','#123456')
book=P.set(book,'default','Consumer','scrollbar','scrollThumb','#ABCDEF')
local plugin=assert(K.encode('OriginalPack','1.0.0',book))
assert(K.parse(plugin).presets.default.values['*'].button.pressed=='#123456')
modFiles.One=plugin;modFiles.Two=plugin
modFiles.Future=plugin:gsub('b47ui%-plugin=1','b47ui-plugin=2',1)
modFiles.Broken=plugin..'os.execute("never run")\n'
local baseline=P.serialize(P.get(0),1);local revision=P.revision(0)
local entries=K.refresh();assert(#entries==2 and #K.issues==2 and entries[1].source~=entries[2].source)
assert(P.serialize(P.get(0),1)==baseline and P.revision(0)==revision and writes==0,'Discovery activated/saved a plugin')
local draft,key=K.use(P.get(0),entries[1],'*');assert(draft and draft.active==key and key~='default')
assert(P.serialize(P.get(0),1)==baseline,'Use saved implicitly')
local again,key2=K.use(draft,entries[1],'*');assert(key2==key and P.serialize(again,1)==P.serialize(draft,1),'Repeated use duplicated the same definition')
draft.presets[key].values['*'].button.pressed='#654321'
assert(entries[1].preset.values['*'].button.pressed=='#123456','Local copy mutated plugin catalogue')
local owner={};assert(P.preview(0,draft,owner));P.clearPreview(0,owner)
assert(P.serialize(P.get(0),1)==baseline,'Cancel changed saved selection')
assert(P.save(0,draft));local saved=P.serialize(P.get(0),1)
activated={};K.refresh();assert(#K.entries==0 and P.serialize(P.get(0),1)==saved,'Removing plugin erased saved copy')
local selected=K.exportBook(draft,key);assert(selected.active=='default'and selected.presets.default.name==draft.presets[key].name and not B47ANCEDUI._hasEntries(selected.bindings))
local exported=assert(K.encode('Detached','1.0.0',selected));local parsed=assert(K.parse(exported));assert(parsed.presets.default.values['*'].button.pressed=='#654321')
local lease={};assert(P.preview(0,P.get(0),lease));local before=P.revision(0)
activated={'One'};K.refresh();assert(P.revision(0)==before,'Refresh broke preview lease');P.clearPreview(0,lease)
mode='One:close';K.refresh();assert(#K.entries==0 and K.issues[1].status=='read-error');mode=nil
local transport=P.copy(book);transport.presets.extra={name='Same display name',values={}};transport.active='extra';transport.bindings.Consumer='extra'
local pack=assert(K.parse(assert(K.encode('Transport','1.0.0',transport))))
assert(pack.presets.extra and P.serialize(P.get(0),1)==saved,'Transport active/binding applied')
assert(not K.parse(exported:gsub('version=1.0.0','1.0.0',1)))
assert(not K.parse(exported:gsub('#654321','#654320',1)))
assert(not K.encode('../Escape','1.0.0',selected)and not K.encode('Okay','01.0.0',selected))
local collision=K.fingerprint;K.fingerprint=function()return 'AAAAAAAA'end
local first,k1=K.use(P.new(),entries[1],'*');local altered=P.copy(entries[1]);altered.preset.name='Different'
local second,k2=K.use(first,altered,'*');assert(k1~=k2 and second.presets[k1].name~=second.presets[k2].name,'Fingerprint collision overwrote a copy');K.fingerprint=collision
local full=P.new();for i=1,15 do full.presets['p'..i]={name='Local '..i,values={}}end
local original=P.serialize(full,1);assert(not K.use(full,entries[1],'*')and P.serialize(full,1)==original,'Capacity failure modified book')
print('PASS OFFLINE enabled data-only plugin catalogue, inactive discovery, limits/errors, transport isolation, detached/repeated copies, collision handling, Save/Cancel and missing-plugin retention')

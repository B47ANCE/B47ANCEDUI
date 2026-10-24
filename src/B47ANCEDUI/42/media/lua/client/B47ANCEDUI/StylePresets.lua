-- Installation-local data, never executable Lua. Two checked journal slots.
require 'B47ANCEDUI/Theme'
local U=B47ANCEDUI;if U.StylePresets then return U.StylePresets end
local S={};U.StylePresets=S
local cache,scopes={}, {B47ANCEDUI=true}
S.families={'all','button','buttonSmall','menuButton','slider','scrollbar','volume','tick','input','dropdown','panel','window','dialog','list','row','tabs','tooltip','text','progress'}
S.properties={
 {id='background',type='color'},{id='hover',type='color'},{id='selected',type='color'},
 {id='border',type='color'},{id='focus',type='color'},{id='text',type='color'},{id='muted',type='color'},
 {id='accent',type='color'},{id='accentHover',type='color'},{id='disabled',type='color'},
 {id='alternate',type='color'},{id='danger',type='color'},{id='warning',type='color'},{id='success',type='color'},
 {id='opacity',type='number',min=20,max=100,step=1}, {id='radius',type='number',min=0,max=8,step=1},
 {id='borderWidth',type='number',min=0,max=3,step=1},
 {id='trackThickness',type='number',min=1,max=12,step=1,family='slider'},
 {id='thumbWidth',type='number',min=4,max=32,step=1,family='slider'},
 {id='thumbHeight',type='number',min=8,max=48,step=1,family='slider'},
}
local extra={};for key in pairs(U.Theme.colorAliases)do extra[#extra+1]=key end;table.sort(extra)
for _,key in ipairs(extra)do S.properties[#S.properties+1]={id=key,type='color'}end
local definitions={};for _,v in ipairs(S.properties)do definitions[v.id]=v end
local function id(v)return type(v)=='string' and #v<=64 and v:match('^[A-Za-z][A-Za-z0-9_.-]*$')~=nil end
function S.scope(v)return v=='*' or id(v)end
local function finite(n)return type(n)=='number' and n==n and n~=math.huge and n~=-math.huge end
local function player(v)return finite(v) and v>=0 and v<=3 and v==math.floor(v) and v or 0 end
function S.copy(t)local out={};for k,v in pairs(t or {})do out[k]=type(v)=='table' and S.copy(v) or v end;return out end
function S.new()return {active='default',bindings={},presets={default={name=getText and getText('UI_B47ANCEDUI_StyleDefault')or 'Default',values={}}}}end
function S.registerScope(scope)assert(id(scope),'Invalid style scope');scopes[scope]=true end
function S.scopes(book)
 local out,seen={'*'},{};for scope in pairs(scopes)do seen[scope]=true end
 for scope in pairs(book and book.bindings or {})do seen[scope]=true end
 for _,preset in pairs(book and book.presets or {})do for scope in pairs(preset.values)do if scope~='*'then seen[scope]=true end end end
 local sorted={};for scope in pairs(seen)do sorted[#sorted+1]=scope end;table.sort(sorted)
 for _,scope in ipairs(sorted)do out[#out+1]=scope end;return out
end
function S.value(property,value)
 local d=definitions[property]
 if not d then return type(value)=='string' and #value>0 and #value<=64 and not value:find('[|\r\n%z]') and value or nil end
 if d.type=='color' then
  local hex=type(value)=='string' and value:match('^#?(%x%x%x%x%x%x)$');return hex and '#'..hex:upper() or nil
 end
 local n=tonumber(value)
 return finite(n) and n>=d.min and n<=d.max and math.abs(n/d.step-math.floor(n/d.step+.5))<.000001 and n or nil
end
function S.valid(book)
 if type(book)~='table' or type(book.presets)~='table' or type(book.bindings)~='table' or not book.presets.default or not book.presets[book.active] then return false end
 local count,fields,bindings=0,0,0
 for key,preset in pairs(book.presets)do
  count=count+1
  if not id(key) or type(preset)~='table' or type(preset.name)~='string' or #preset.name<1 or #preset.name>48 or preset.name:find('[%z\1-\31\127]') or type(preset.values)~='table' then return false end
  for scope,families in pairs(preset.values)do
   if not S.scope(scope) or type(families)~='table'then return false end
   for family,properties in pairs(families)do
    if not id(family) or type(properties)~='table'then return false end
    for key,value in pairs(properties)do
     fields=fields+1;if not id(key) or S.value(key,value)==nil then return false end
    end
   end
  end
 end
 for scope,key in pairs(book.bindings)do bindings=bindings+1;if not id(scope) or not book.presets[key]then return false end end
 return count>0 and count<=16 and fields<=3072 and bindings<=32
end
function S.set(book,key,scope,family,property,value)
 if not S.valid(book) or not book.presets[key] or not S.scope(scope) or not id(family) or not id(property)then return end
 local out=S.copy(book);local v=out.presets[key].values
 if value==nil and not(v[scope]and v[scope][family]and v[scope][family][property]~=nil)then return out end
 v[scope]=v[scope] or {};v[scope][family]=v[scope][family] or {}
 if value~=nil then value=S.value(property,value);if value==nil then return end end
 v[scope][family][property]=value
 if not U._hasEntries(v[scope][family])then v[scope][family]=nil end
 if not U._hasEntries(v[scope])then v[scope]=nil end
 return S.valid(out) and out or nil
end
function S.duplicate(book,key,name)
 if not S.valid(book) or not book.presets[key]then return end
 local out=S.copy(book);local n=1;while out.presets['p'..n]do n=n+1 end
 local new='p'..n;out.presets[new]=S.copy(book.presets[key]);out.presets[new].name=name
 return S.valid(out) and out or nil,new
end
function S.delete(book,key)
 if key=='default' or not S.valid(book) or not book.presets[key]then return end
 local out=S.copy(book);out.presets[key]=nil
 if out.active==key then out.active='default'end
 for scope,v in pairs(out.bindings)do if v==key then out.bindings[scope]=nil end end
 return S.valid(out) and out or nil
end
local function encode(s)return (s:gsub('.',function(c)return string.format('%02X',c:byte())end))end
local function decode(s)
 if #s%2~=0 or s:find('[^%x]')then return end
 return (s:gsub('%x%x',function(c)return string.char(tonumber(c,16))end))
end
local function checksum(s)local a,b=1,0;for i=1,#s do a=(a+s:byte(i))%65521;b=(b+a)%65521 end;return string.format('%08X',b*65536+a)end
local function sorted(t)local keys={};for k in pairs(t)do keys[#keys+1]=k end;table.sort(keys);return keys end
function S.serialize(book,generation)
 if not S.valid(book) or not finite(generation) or generation<1 or generation>1000000000 or generation~=math.floor(generation)then return end
 local lines={'schema=1','generation='..generation,'active='..book.active}
 for _,key in ipairs(sorted(book.presets))do
  local preset=book.presets[key];lines[#lines+1]='preset|'..key..'|'..encode(preset.name)
  for _,scope in ipairs(sorted(preset.values))do for _,family in ipairs(sorted(preset.values[scope]))do for _,property in ipairs(sorted(preset.values[scope][family]))do
   lines[#lines+1]=table.concat({'value',key,encode(scope),family,property,tostring(preset.values[scope][family][property])},'|')
  end end end
 end
 for _,scope in ipairs(sorted(book.bindings))do lines[#lines+1]='bind|'..encode(scope)..'|'..book.bindings[scope]end
 local body=table.concat(lines,'\n')..'\n'
 if #body>262000 or #lines>4094 then return end
 return body..'checksum='..checksum(body)..'\n'
end
function S.parse(text)
 if type(text)~='string' or #text>262144 then return nil,'invalid'end
 local schema=text:match('^schema=([^\n]+)\n');if schema and schema~='1' then return nil,'future'end
 local body,sum=text:match('^(.*\n)checksum=(%x%x%x%x%x%x%x%x)\n$')
 if schema~='1' or not body or checksum(body)~=sum then return nil,'invalid'end
 local book={presets={},bindings={}};local generation;local seen={};local entries=0
 for line in body:gmatch('([^\n]*)\n')do
  entries=entries+1;if entries>4094 or #line>512 or seen[line]then return nil,'invalid'end;seen[line]=true
  if line=='schema=1'then
  elseif line:match('^generation=')then
   if generation then return nil,'invalid'end;generation=tonumber(line:match('^generation=(%d+)$'))
   if not generation then return nil,'invalid'end
  elseif line:match('^active=')then if book.active then return nil,'invalid'end;book.active=line:sub(8)
  elseif line:match('^preset|')then
   local key,name=line:match('^preset|([^|]+)|([^|]+)$');name=name and decode(name)
   if not key or book.presets[key] or not name then return nil,'invalid'end
   book.presets[key]={name=name,values={}}
  elseif line:match('^value|')then
   local key,scope,family,property,value=line:match('^value|([^|]+)|([^|]+)|([^|]+)|([^|]+)|([^|]+)$');scope=scope and decode(scope)
   local preset=book.presets[key];if not preset or not scope or S.value(property,value)==nil then return nil,'invalid'end
   local v=preset.values;v[scope]=v[scope] or {};v[scope][family]=v[scope][family] or {}
   if v[scope][family][property]~=nil then return nil,'invalid'end;v[scope][family][property]=S.value(property,value)
  elseif line:match('^bind|')then
   local scope,key=line:match('^bind|([^|]+)|([^|]+)$');scope=scope and decode(scope)
   if not scope or book.bindings[scope]then return nil,'invalid'end;book.bindings[scope]=key
  else return nil,'invalid'end
 end
 if not generation or not S.serialize(book,generation)then return nil,'invalid'end
 return book,'ok',generation
end
local function file(p,slot)return 'B47ANCEDUI/style-presets.'..p..'.'..slot..'.txt'end
local function read(p,slot)
 if not getFileReader then return nil,'missing'end
 local ok,reader=pcall(getFileReader,file(p,slot),false);if not ok then return nil,'read-error'end
 if not reader then return nil,'missing'end
 local lines,bytes={},0
 local readOK=pcall(function()for _=1,4097 do local l=reader:readLine();if l==nil then break end;assert(type(l)=='string' and #l<=512);bytes=bytes+#l+1;assert(bytes<=262144);lines[#lines+1]=l end end)
 local closed,result=pcall(reader.close,reader);if not readOK or not closed or result==false then return nil,'read-error'end
 return S.parse(table.concat(lines,'\n')..'\n')
end
local function load(p)
 p=player(p);if cache[p]then return cache[p]end
 local a,sa,ga=read(p,'a');local b,sb,gb=read(p,'b');local useB=b and (not a or gb>ga)
 local state={book=S.copy((useB and b or a) or S.new()),slot=useB and 'b' or 'a',generation=(useB and gb or ga) or 0}
 state.status=(sa=='future' or sb=='future')and 'future' or (sa=='read-error' or sb=='read-error')and 'read-error' or (a or b)and 'ok' or (sa=='missing' and sb=='missing')and 'missing' or 'invalid'
 cache[p]=state;return state
end
function S.get(p)local state=load(p);return S.copy(state.book),state.status end
function S.revision(p)return load(p).revision or 0 end
function S.current(p)local state=load(p);return S.copy(state.preview or state.book),state.revision or 0 end
function S.preview(p,book,owner)
 local state=load(p);if state.owner and state.owner~=owner then return false end
 if not S.valid(book)then return false end
 state.owner=owner;state.preview=S.copy(book);state.revision=(state.revision or 0)+1;return true
end
function S.clearPreview(p,owner)
 local state=load(p);if state.owner~=owner then return false end
 state.owner=nil;state.preview=nil;state.revision=(state.revision or 0)+1;return true
end
function S.save(p,book)
 p=player(p);local state=load(p)
 if state.status=='future' or state.status=='read-error' or state.status=='invalid'then return false,state.status end
 local generation=state.generation+1;local text=S.serialize(book,generation);if not text or not getFileWriter then return false,'invalid'end
 local slot=state.slot=='a' and 'b' or 'a';local ok,writer=pcall(getFileWriter,file(p,slot),true,false)
 if not ok or not writer then return false,'write'end
 local wrote,result=pcall(writer.write,writer,text);local closed,closeResult=pcall(writer.close,writer)
 if not wrote or result==false or not closed or closeResult==false then return false,'write'end
 local verify,status,g=read(p,slot)
 if status~='ok' or g~=generation or S.serialize(verify,generation)~=text then return false,'verify'end
 state.book=S.copy(book);state.generation=generation;state.slot=slot;state.status='ok';state.revision=(state.revision or 0)+1
 return true
end
return S

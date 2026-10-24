-- Enabled-mod data catalogue, never executable imports or automatic activation.
local P=require 'B47ANCEDUI/StylePresets'
local U=B47ANCEDUI
if U.PresetPlugins then return U.PresetPlugins end
local K={entries={},issues={}};U.PresetPlugins=K
K.path='media/B47ANCEDUI/style-pack.txt'
function K.identifier(value)return type(value)=='string'and #value<=64 and value:match('^[A-Za-z][A-Za-z0-9_.-]*$')~=nil end
function K.fingerprint(text)
 local a,b=1,0;for i=1,#text do a=(a+text:byte(i))%65521;b=(b+a)%65521 end
 return string.format('%08X',b*65536+a)
end
local function version(value)
 if type(value)~='string'or #value>32 then return false end
 local a,b,c=value:match('^(%d+)%.(%d+)%.(%d+)$')
 return a and not(a:match('^0%d')or b:match('^0%d')or c:match('^0%d'))
end
function K.encode(id,release,book)
 if not K.identifier(id)or not version(release)then return nil,'metadata'end
 local payload=P.serialize(book,1);if not payload then return nil,'invalid'end
 return 'b47ui-plugin=1\nid='..id..'\nversion='..release..'\n'..payload
end
function K.parse(text)
 if type(text)~='string'or #text>262400 then return nil,'invalid'end
 local schema=text:match('^b47ui%-plugin=([^\n]+)\n')
 if schema and schema~='1'then return nil,'future'end
 local id,release,payload=text:match('^b47ui%-plugin=1\nid=([^\n]+)\nversion=([^\n]+)\n(.*)$')
 if not K.identifier(id)or not version(release)then return nil,'invalid'end
 local book,status=P.parse(payload)
 if not book then return nil,status end
 -- Active/bindings/generation are transport validation only, not instructions.
 return {id=id,version=release,presets=P.copy(book.presets)},'ok'
end
local function read(modID)
 local ok,reader=pcall(getModFileReader,modID,K.path,false)
 if not ok then return nil,'read-error'end
 if not reader then return nil,'missing'end
 local lines,bytes={},0
 local good=pcall(function()
  for _=1,4101 do
   local line=reader:readLine();if line==nil then return end
   assert(type(line)=='string'and #line<=512)
   bytes=bytes+#line+1;assert(bytes<=262400);lines[#lines+1]=line
  end
  error('Too many plugin records')
 end)
 local closed,result=pcall(reader.close,reader)
 if not good or not closed or result==false then return nil,'read-error'end
 return K.parse(table.concat(lines,'\n')..'\n')
end
function K.refresh()
 local entries,issues={},{}
 if not getActivatedMods or not getModFileReader then K.entries=entries;K.issues=issues;return entries end
 local ok,mods=pcall(getActivatedMods)
 if not ok or not mods then K.issues={{status='unavailable'}};return K.entries end
 local success=pcall(function()
  local seen={}
  for i=0,math.min(mods:size(),1024)-1 do
   local source=mods:get(i)
   if type(source)=='string'and #source>0 and #source<=128 and not source:find('[%z\r\n]')and not seen[source]then
    seen[source]=true
    local pack,status=read(source)
    if pack then
     local keys={};for key in pairs(pack.presets)do keys[#keys+1]=key end;table.sort(keys)
     for _,key in ipairs(keys)do
      if #entries>=256 then issues[#issues+1]={source=source,status='limit'};break end
      entries[#entries+1]={source=source,pack=pack.id,version=pack.version,key=key,preset=P.copy(pack.presets[key])}
     end
    elseif status~='missing'then issues[#issues+1]={source=source,status=status}end
   end
  end
 end)
 if not success then K.issues={{status='unavailable'}};return K.entries end
 table.sort(entries,function(a,b)
  if a.preset.name~=b.preset.name then return a.preset.name<b.preset.name end
  return a.source..'/'..a.pack..'/'..a.key<b.source..'/'..b.pack..'/'..b.key
 end)
 K.entries=entries;K.issues=issues
 return entries
end
local function payload(preset)
 local one=P.new();one.presets.default=P.copy(preset);return P.serialize(one,1)
end
function K.use(book,entry,scope)
 if not P.valid(book)or type(entry)~='table'or not P.scope(scope)then return nil,'invalid'end
 local text=payload(entry.preset);if not text then return nil,'invalid'end
 local key='pack.'..K.fingerprint((entry.source or '')..'/'..(entry.pack or '')..'/'..(entry.key or '')..'\n'..text)
 local out=P.copy(book);local suffix=0;local root=key
 while out.presets[key]and payload(out.presets[key])~=text do suffix=suffix+1;key=root..'.'..suffix end
 if not out.presets[key]then out.presets[key]=P.copy(entry.preset)end
 if scope=='*'then out.active=key else out.bindings[scope]=key end
 if not P.serialize(out,1)then return nil,'limit'end
 return out,key
end
function K.exportBook(book,key)
 if not P.valid(book)or not book.presets[key]then return nil end
 local out=P.new();out.presets.default=P.copy(book.presets[key])
 return out
end
return K

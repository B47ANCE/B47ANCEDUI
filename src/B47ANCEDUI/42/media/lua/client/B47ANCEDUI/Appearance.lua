-- Client-local per-consumer/per-player appearance; no gameplay state.
require 'B47ANCEDUI/Theme'
local U=B47ANCEDUI;local A={};U.Appearance=A
local values,contexts={},{}
local function valid(n) return type(n)=='number' and n==n and n~=math.huge and n~=-math.huge end
local function identifier(id) return type(id)=='string' and #id<=64 and id:match('^[A-Za-z][A-Za-z0-9_.-]*$')~=nil end
local function playerID(player) return valid(player) and player>=0 and player<=3 and player==math.floor(player) and player or 0 end
function A.scope(w)
 local n=0
 while w and n<32 do if w.b47AppearanceScope then return w.b47AppearanceScope end;w=w.parent;n=n+1 end
 return 'B47ANCEDUI'
end
function A.player(w)
 local n=0
 while w and n<32 do if w.playerNum~=nil then return w.playerNum end;w=w.parent;n=n+1 end
 return 0
end
local function filename(scope,player) return 'B47ANCEDUI/appearance/'..scope..'.'..player..'.txt' end
function A.normalizeAccent(hex)
 if type(hex)~='string' then return end
 local digits=hex:match('^#?(%x%x%x%x%x%x)$')
 return digits and '#'..string.upper(digits) or nil
end
local function read(name)
 if not getFileReader then return end
 local ok,reader=pcall(getFileReader,name,false)
 if not ok or not reader then return end
 local data={}
 local success=pcall(function()
  -- Bounded data, never Lua. Older versions read the first opacity line only.
  for i=1,8 do
   local line=reader:readLine();if line==nil then break end
   if type(line)=='string' and #line<=128 then
    local value=tonumber(line:match('^opacity=(.+)$'))
    if not data.opacity and valid(value) and value>=20 and value<=100 then data.opacity=value end
    data.accent=data.accent or A.normalizeAccent(line:match('^accent=(.+)$'))
   end
  end
 end)
 pcall(reader.close,reader);if success then return data end
end
local function profile(player,scope)
 player=playerID(player);scope=scope or 'B47ANCEDUI';assert(identifier(scope),'Invalid UI appearance scope')
 local key=scope..':'..player
 if values[key]~=nil then return values[key] end
 local data=read(filename(scope,player)) or {};local config=contexts[scope]
 if data.opacity==nil and config and config.legacyAppearancePrefix then
  local legacy=read(config.legacyAppearancePrefix..player..'.txt');data.opacity=legacy and legacy.opacity
 end
 data.opacity=data.opacity or 82;data.accent=data.accent or U.Theme.defaultAccent
 values[key]=data;return data
end
function A.get(player,scope)
 return profile(player,scope).opacity
end
function A.set(player,value,scope)
 player=playerID(player);scope=scope or 'B47ANCEDUI';assert(identifier(scope),'Invalid UI appearance scope')
 value=tonumber(value);if not valid(value) then value=82 end
 value=math.max(20,math.min(100,value));profile(player,scope).opacity=value;return value
end
function A.getAccent(player,scope) return profile(player,scope).accent end
function A.setAccent(player,hex,scope)
 local normalized=A.normalizeAccent(hex);if not normalized then return nil end
 local data=profile(player,scope);data.accent=normalized;data.colors=nil;return normalized
end
function A.color(w,c)
 local T=U.Theme
 if c~=T.colors.accent and c~=T.colors.accentHover and c~=T.colors.selected then return c end
 local data=profile(A.player(w),A.scope(w))
 if data.accent==T.defaultAccent then return c end
 if not data.colors then
  local hex=data.accent;local r,g,b=tonumber(hex:sub(2,3),16)/255,tonumber(hex:sub(4,5),16)/255,tonumber(hex:sub(6,7),16)/255
  data.colors={accent={r=r,g=g,b=b,a=T.colors.accent.a},
   accentHover={r=math.min(1,r+.12),g=math.min(1,g+.12),b=math.min(1,b+.12),a=T.colors.accentHover.a},
   selected={r=.06+r*.16,g=.06+g*.16,b=.06+b*.16,a=T.colors.selected.a}}
 end
 return c==T.colors.accent and data.colors.accent or c==T.colors.accentHover and data.colors.accentHover or data.colors.selected
end
function A.save(player,scope)
 player=playerID(player);scope=scope or 'B47ANCEDUI';assert(identifier(scope),'Invalid UI appearance scope')
 local data=profile(player,scope)
 if not getFileWriter then return false end
 local ok,writer=pcall(getFileWriter,filename(scope,player),true,false)
 if not ok or not writer then return false end
 local text='opacity='..data.opacity..'\n'
 if data.accent~=U.Theme.defaultAccent then text=text..'accent='..data.accent..'\n' end
 local written=pcall(writer.write,writer,text)
 local closed=pcall(writer.close,writer);return written and closed
end
function A.context(scope,options)
 assert(identifier(scope),'Invalid UI consumer ID');options=options or {};local prefix=options.legacyAppearancePrefix
 assert(prefix==nil or identifier(prefix),'Invalid legacy appearance prefix')
 if contexts[scope] then
  assert(contexts[scope].legacyAppearancePrefix==prefix,'UI consumer already registered with different appearance migration')
  return contexts[scope].api
 end
 local api={get=function(player) return A.get(player,scope) end,set=function(player,value) return A.set(player,value,scope) end,save=function(player) return A.save(player,scope) end,
  getAccent=function(player) return A.getAccent(player,scope) end,setAccent=function(player,hex) return A.setAccent(player,hex,scope) end,
  normalizeAccent=A.normalizeAccent,color=A.color,alpha=A.alpha,prepare=A.prepare,player=A.player}
 contexts[scope]={legacyAppearancePrefix=prefix,api=api};return api
end
function A.alpha(w) if w and w.b47AppearanceOpaque then return .94 end;return A.get(A.player(w),A.scope(w))/100 end
function A.prepare(w,kind)
 if kind=='list' then w.selectionColor=U.Theme.copy(A.color(w,U.Theme.colors.selected)) end
 if not w.backgroundColor then return end
 if w.b47AppearanceOpaque then w.backgroundColor.a=.94
 elseif kind=='window' or kind=='panel' and not w.parent then w.backgroundColor.a=A.alpha(w)
 elseif kind=='panel' or kind=='list' then w.backgroundColor.a=0 end
 -- Buttons, inputs, dropdowns and native tooltip frames keep their readable backgrounds.
end
return A

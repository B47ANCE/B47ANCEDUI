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
local function read(name)
 if not getFileReader then return end
 local ok,reader=pcall(getFileReader,name,false)
 if not ok or not reader then return end
 local success,line=pcall(reader.readLine,reader);pcall(reader.close,reader)
 if not success then return end
 local value=tonumber(type(line)=='string' and line:match('^opacity=(.+)$'))
 if valid(value) and value>=20 and value<=100 then return value end
end
function A.get(player,scope)
 player=playerID(player);scope=scope or 'B47ANCEDUI';assert(identifier(scope),'Invalid UI appearance scope')
 local key=scope..':'..player
 if values[key]~=nil then return values[key] end
 local value=read(filename(scope,player));local config=contexts[scope]
 if value==nil and config and config.legacyAppearancePrefix then value=read(config.legacyAppearancePrefix..player..'.txt') end
 values[key]=value or 82;return values[key]
end
function A.set(player,value,scope)
 player=playerID(player);scope=scope or 'B47ANCEDUI';assert(identifier(scope),'Invalid UI appearance scope')
 value=tonumber(value);if not valid(value) then value=82 end
 value=math.max(20,math.min(100,value));values[scope..':'..player]=value;return value
end
function A.save(player,scope)
 player=playerID(player);scope=scope or 'B47ANCEDUI';assert(identifier(scope),'Invalid UI appearance scope')
 if not getFileWriter then return false end
 local ok,writer=pcall(getFileWriter,filename(scope,player),true,false)
 if not ok or not writer then return false end
 local written=pcall(writer.write,writer,'opacity='..A.get(player,scope)..'\n')
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
  alpha=A.alpha,prepare=A.prepare,player=A.player}
 contexts[scope]={legacyAppearancePrefix=prefix,api=api};return api
end
function A.alpha(w) if w and w.b47AppearanceOpaque then return .94 end;return A.get(A.player(w),A.scope(w))/100 end
function A.prepare(w,kind)
 if not w.backgroundColor then return end
 if w.b47AppearanceOpaque then w.backgroundColor.a=.94
 elseif kind=='window' or kind=='panel' and not w.parent then w.backgroundColor.a=A.alpha(w)
 elseif kind=='panel' or kind=='list' then w.backgroundColor.a=0 end
 -- Buttons, inputs, dropdowns and native tooltip frames keep their readable backgrounds.
end
return A

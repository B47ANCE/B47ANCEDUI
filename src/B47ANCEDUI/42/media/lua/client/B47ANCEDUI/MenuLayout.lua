-- Main-menu presentation preferences only; no world, player or server state.
local L={}
local filename='B47ANCEDUI/main-menu-layout.txt'
local cached
local fields={menu={'x','y','w','h'},logo={'x','y','w'}}
local function finite(n) return type(n)=='number' and n==n and n~=math.huge and n~=-math.huge end
local function clamp(n,lo,hi) return math.max(lo,math.min(hi,n)) end
function L.copy(profile)
 local result={}
 if type(profile)~='table' then return result end
 for kind,names in pairs(fields) do
  local value=profile[kind];local good=type(value)=='table'
  if good then
   for _,key in ipairs(names) do
    local n=value[key]
    if not finite(n) or n<0 or n>1 or (key=='w' or key=='h') and n<=0 then good=false;break end
   end
  end
  if good then result[kind]={};for _,key in ipairs(names) do result[kind][key]=value[key] end end
 end
 return result
end
function L.parse(lines)
 if lines[1]~='schema=1' then return {} end
 local result={}
 for i=2,math.min(8,#lines) do
  local line=lines[i]
  if type(line)=='string' and #line<=160 then
   local key,body=line:match('^(%a+)=(.+)$')
   if fields[key] and not result[key] then
    local numbers={};local good=true
    for item in (body..','):gmatch('(.-),') do
     local n=tonumber(item);if not finite(n) then good=false;break end
     numbers[#numbers+1]=n
    end
    if good and #numbers==#fields[key] then
     local value={};for j,name in ipairs(fields[key]) do value[name]=numbers[j] end
     result[key]=L.copy({[key]=value})[key]
    end
   end
  end
 end
 return result
end
function L.get()
 if cached then return L.copy(cached) end
 cached={}
 if not getFileReader then return {} end
 local ok,reader=pcall(getFileReader,filename,false)
 if not ok or not reader then return {} end
 local lines={}
 local success=pcall(function()
  for i=1,8 do
   local line=reader:readLine();if line==nil then break end
   lines[i]=type(line)=='string' and #line<=160 and line or ''
  end
 end)
 pcall(reader.close,reader)
 if success then cached=L.parse(lines) end
 return L.copy(cached)
end
function L.save(profile)
 if type(profile)~='table' or not getFileWriter then return false end
 local value=L.copy(profile);local lines={'schema=1'}
 for _,kind in ipairs({'menu','logo'}) do
  if value[kind] then
   local numbers={}
   for _,key in ipairs(fields[kind]) do numbers[#numbers+1]=string.format('%.9g',value[kind][key]) end
   lines[#lines+1]=kind..'='..table.concat(numbers,',')
  end
 end
 local ok,writer=pcall(getFileWriter,filename,true,false)
 if not ok or not writer then return false end
 local wrote,result=pcall(writer.write,writer,table.concat(lines,'\n')..'\n')
 local closed,closeResult=pcall(writer.close,writer)
 if not wrote or result==false or not closed or closeResult==false then return false end
 cached=value;return true
end
-- Readability minima and viewport limits are internal drawing safeguards.
function L.fit(kind,rect,width,height,ratio)
 width=math.max(1,width);height=math.max(1,height)
 local w,h
 if kind=='logo' then
  ratio=finite(ratio) and ratio>0 and ratio or 1
  local maxWidth=math.min(width,height*ratio)
  w=clamp(rect.w,math.min(100,maxWidth),maxWidth);h=w/ratio
 else
  w=clamp(rect.w,math.min(160,width),width)
  h=clamp(rect.h,math.min(80,height),height)
 end
 return {x=clamp(rect.x,0,width-w),y=clamp(rect.y,0,height-h),w=w,h=h}
end
function L.resolve(profile,defaults,width,height,ratio)
 local value=L.copy(profile);local result={}
 for _,kind in ipairs({'menu','logo'}) do
  local rect=value[kind]
  if rect then
   result[kind]=L.fit(kind,{x=rect.x*width,y=rect.y*height,w=rect.w*width,h=(rect.h or 0)*height},width,height,ratio)
  else
   local original=defaults[kind]
   result[kind]={x=original.x,y=original.y,w=original.w,h=original.h}
  end
 end
 return result
end
function L.setRect(profile,kind,rect,width,height,ratio)
 assert(fields[kind],'Unknown menu layout target')
 width=math.max(1,width);height=math.max(1,height)
 local result=L.copy(profile);local fitted=L.fit(kind,rect,width,height,ratio)
 result[kind]={x=fitted.x/width,y=fitted.y/height,w=fitted.w/width}
 if kind=='menu' then result[kind].h=fitted.h/height end
 return result
end
function L.drag(profile,kind,start,dx,dy,resize,width,height,ratio)
 local rect={x=start.x,y=start.y,w=start.w,h=start.h}
 if resize then
  if kind=='logo' then
   local delta=math.abs(dx)>=math.abs(dy*ratio) and dx or dy*ratio
   rect.w=rect.w+delta
  else rect.w=rect.w+dx;rect.h=rect.h+dy end
 else rect.x=rect.x+dx;rect.y=rect.y+dy end
 return L.setRect(profile,kind,rect,width,height,ratio)
end
return L

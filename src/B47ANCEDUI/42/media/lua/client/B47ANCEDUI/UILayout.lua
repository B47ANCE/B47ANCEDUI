-- Local HUD geometry only, separate from main-menu layout and appearance files.
local P={};local cache,status
local filename='B47ANCEDUI/in-game-layout.txt'
local function finite(n) return type(n)=='number' and n==n and n~=math.huge and n~=-math.huge end
function P.id(id) return type(id)=='string' and #id<=96 and id:match('^[A-Za-z][A-Za-z0-9_.-]*$')~=nil end
local function valid(rect)
 if type(rect)~='table' then return false end
 for _,k in ipairs({'x','y','w','h'}) do
  local n=rect[k];if not finite(n) or n<0 or n>1 or (k=='w' or k=='h') and n<=0 then return false end
 end
 return true
end
function P.copy(profile)
 local result={}
 for id,rect in pairs(type(profile)=='table' and profile or {}) do
  if P.id(id) and valid(rect) then result[id]={x=rect.x,y=rect.y,w=rect.w,h=rect.h} end
 end
 return result
end
function P.parse(lines)
 lines=type(lines)=='table' and lines or {}
 if lines[1]~='schema=1' then return {},type(lines[1])=='string' and lines[1]:match('^schema=') and 'future' or 'invalid' end
 if #lines>129 then return {},'read-error' end
 local result={}
 for i=2,math.min(#lines,129) do
  local line=lines[i]
  if type(line)=='string' and #line<=240 then
   local id,x,y,w,h=line:match('^([A-Za-z][A-Za-z0-9_.-]*)=([^,]+),([^,]+),([^,]+),([^,]+)$')
   local rect={x=tonumber(x),y=tonumber(y),w=tonumber(w),h=tonumber(h)}
   if P.id(id) and not result[id] and valid(rect) then result[id]=rect end
  end
 end
 return result,'ok'
end
function P.get()
 if cache then return P.copy(cache),status end
 cache={};status='missing'
 if not getFileReader then return {},status end
 local ok,reader=pcall(getFileReader,filename,false)
 if not ok then status='read-error';return {},status end
 if not reader then return {},status end
 local lines={};local read=pcall(function()
  for i=1,130 do local line=reader:readLine();if line==nil then break end;lines[i]=type(line)=='string' and #line<=240 and line or '' end
 end)
 pcall(reader.close,reader)
 if read then cache,status=P.parse(lines) else status='read-error' end
 return P.copy(cache),status
end
function P.save(profile,replaceFuture)
 P.get()
 if (status=='future' or status=='read-error') and not replaceFuture then return false,'future' end
 if not getFileWriter then return false,'write' end
 local value=P.copy(profile);local ids={};for id in pairs(value) do ids[#ids+1]=id end;table.sort(ids)
 if #ids>128 then return false,'limit' end
 local lines={'schema=1'}
 for _,id in ipairs(ids) do
  local rect=value[id];local numbers={}
  for _,key in ipairs({'x','y','w','h'}) do numbers[#numbers+1]=string.format('%.9g',rect[key]) end
  lines[#lines+1]=id..'='..table.concat(numbers,',')
 end
 local ok,writer=pcall(getFileWriter,filename,true,false);if not ok or not writer then return false,'write' end
 local wrote,result=pcall(writer.write,writer,table.concat(lines,'\n')..'\n')
 local closed,closeResult=pcall(writer.close,writer)
 if not wrote or result==false or not closed or closeResult==false then return false,'write' end
 cache=value;status='ok';return true
end
function P.entry(id)
 if not cache then P.get() end
 local rect=cache[id];return rect and {x=rect.x,y=rect.y,w=rect.w,h=rect.h} or nil
end
function P.fit(rect,width,height,minWidth,minHeight,aspect)
 width=math.max(1,width);height=math.max(1,height)
 local w=math.max(math.min(minWidth or 80,width),math.min(width,rect.w))
 local h=math.max(math.min(minHeight or 40,height),math.min(height,rect.h))
 if aspect then
  local maxWidth=math.min(width,height*aspect)
  w=math.max(math.min(maxWidth,math.max(minWidth or 80,(minHeight or 40)*aspect)),math.min(w,maxWidth));h=w/aspect
 end
 return {x=math.max(0,math.min(width-w,rect.x)),y=math.max(0,math.min(height-h,rect.y)),w=w,h=h}
end
function P.resolve(rect,width,height,definition)
 return P.fit({x=rect.x*width,y=rect.y*height,w=rect.w*width,h=rect.h*height},width,height,definition.minWidth,definition.minHeight,definition.aspect)
end
function P.set(profile,id,rect,width,height,definition)
 local copy=P.copy(profile);local fit=P.fit(rect,width,height,definition.minWidth,definition.minHeight,definition.aspect)
 copy[id]={x=fit.x/width,y=fit.y/height,w=fit.w/width,h=fit.h/height};return copy
end
function P.drag(start,dx,dy,edge,width,height,definition)
 local rect={x=start.x,y=start.y,w=start.w,h=start.h}
 if edge and definition.resizable then
  if definition.resizeWidth~=false then rect.w=rect.w+(edge.right and dx or edge.left and -dx or 0) end
  if definition.resizeHeight~=false then rect.h=rect.h+(edge.bottom and dy or edge.top and -dy or 0) end
  if definition.aspect and (not edge.left and not edge.right or (edge.top or edge.bottom) and math.abs(dy*definition.aspect)>math.abs(dx)) then rect.w=rect.h*definition.aspect end
  rect=P.fit(rect,width,height,definition.minWidth,definition.minHeight,definition.aspect)
  if edge.left then rect.x=start.x+start.w-rect.w end
  if edge.top then rect.y=start.y+start.h-rect.h end
 else rect.x=rect.x+dx;rect.y=rect.y+dy end
 return P.fit(rect,width,height,definition.minWidth,definition.minHeight,definition.aspect)
end
return P

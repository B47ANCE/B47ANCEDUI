-- One explicit data export. Workshop networking stays in the native uploader.
local K=require 'B47ANCEDUI/PresetPlugins'
local P=B47ANCEDUI.StylePresets
local U=B47ANCEDUI
if U.PresetExport then return U.PresetExport end
local X={};U.PresetExport=X
local function read(path,limit)
 if not getFileReader then return nil,'read-error'end
 local ok,reader=pcall(getFileReader,path,false);if not ok then return nil,'read-error'end
 if not reader then return nil,'missing'end
 local lines,bytes={},0
 local good=pcall(function()for _=1,4101 do local line=reader:readLine();if line==nil then return end;assert(type(line)=='string'and #line<=512);bytes=bytes+#line+1;assert(bytes<=limit);lines[#lines+1]=line end;error('Too many records')end)
 local closed,result=pcall(reader.close,reader)
 if good and closed and result~=false then return table.concat(lines,'\n')..'\n','ok'end
 return nil,'read-error'
end
local function write(path,text)
 if not getFileWriter then return false end
 local ok,writer=pcall(getFileWriter,path,true,false);if not ok or not writer then return false end
 local wrote,value=pcall(writer.write,writer,text);local closed,result=pcall(writer.close,writer)
 return wrote and value~=false and closed and result~=false and read(path,#text+1)==text
end
local function identity(player,key)
 local base='B47ANCEDUI/exports/identity-'..player..'-'..key
 local best,slot,invalid=nil,nil,false
 for _,name in ipairs({'a','b'})do
  local data,status=read(base..'.'..name..'.txt',256)
  if status~='missing'and status~='ok'then return nil,nil,base,'read-error'end
  if data then
   local generation,id,crc=data:match('^b47ui%-identity=1\ngeneration=(%d+)\nid=([A-Za-z][A-Za-z0-9_.-]*)\nchecksum=([0-9A-F]+)\n$')
   local n=tonumber(generation)
   if n and n>=1 and n<=1000000000 and K.identifier(id)and K.fingerprint('b47ui-identity=1\ngeneration='..generation..'\nid='..id..'\n')==crc then
    if not best or n>best.generation then best={id=id,generation=n};slot=name end
   elseif data:match('^b47ui%-identity=(%d+)')and data:match('^b47ui%-identity=(%d+)')~='1'then return nil,nil,base,'future'
   else invalid=true end
  end
 end
 if not best and invalid then return nil,nil,base,'invalid'end
 return best,slot,base,'ok'
end
function X.previous(player,key)
 if type(player)~='number'or player<0 or player>3 or player~=math.floor(player)or not K.identifier(key)then return nil end
 local mapping=identity(player,key);if not mapping then return nil end
 local data=read('B47ANCEDUI/exports/'..mapping.id..'.b47ui.txt',262400)
 local pack=data and K.parse(data)
 if not pack or not pack.presets.default then return nil end
 return {id=mapping.id,name=pack.presets.default.name}
end
function X.export(player,book,key,mode,expectedID)
 if type(player)~='number'or player<0 or player>3 or player~=math.floor(player)then return nil,'invalid'end
 local exported=K.exportBook(book,key);if not exported then return nil,'invalid'end
 -- A stable installation-local ID permits re-export/update of the same pack.
 -- It contains no account, player, save or machine identity.
 local mapping,slot,base,mappingStatus=identity(player,key)
 if mappingStatus~='ok'then return nil,mappingStatus end
 local id=mapping and mapping.id
 if mode=='update'and not id then return nil,'missing'end
 if mode=='update'and id~=expectedID then return nil,'changed'end
 -- New is the safe default. Updating a previous exported item is a distinct
 -- explicit choice, because local preset keys can be reused after deletion.
 if mode~='update'then
  if not getTimestampMs then return nil,'unavailable'end
  local now=getTimestampMs()
  if type(now)~='number'or now~=now or now<0 or now>999999999999999 then return nil,'unavailable'end
  local prefix='B47UI.'..string.format('%.0f',now)..'.'..K.fingerprint(tostring(player)..':'..key)
  id=nil
  for n=1,64 do
   local candidate=prefix..'.'..n
   local _,status=read('B47ANCEDUI/exports/'..candidate..'.b47ui.txt',262400)
   if status=='missing'then id=candidate;break end
   if status~='ok'then return nil,'read-error'end
  end
  if not id then return nil,'limit'end
 end
 local text=K.encode(id,'1.0.0',exported);if not text then return nil,'invalid'end
 local path='B47ANCEDUI/exports/'..id..'.b47ui.txt'
 if not write(path,text)then return nil,'write'end
 if mode~='update'then
  local generation=(mapping and mapping.generation or 0)+1
  if generation>1000000000 then return nil,'limit'end
  local body='b47ui-identity=1\ngeneration='..generation..'\nid='..id..'\n'
  if not write(base..'.'..(slot=='a'and 'b'or 'a')..'.txt',body..'checksum='..K.fingerprint(body)..'\n')then return nil,'write'end
 end
 local fingerprint=K.fingerprint(text)
 if not write('B47ANCEDUI/exports/'..id..'.request.txt','b47ui-export=1\nid='..id..'\nexport='..fingerprint..'\n')then return nil,'write'end
 return {id=id,path=path,name=exported.presets.default.name,fingerprint=fingerprint},'ok'
end
function X.showExports()
 if not Core or not Core.getMyDocumentFolder or not showFolderInDesktop then return false end
 showFolderInDesktop(Core.getMyDocumentFolder()..'/Lua/B47ANCEDUI/exports');return true
end
function X.status(exported)
 if type(exported)~='table'or not K.identifier(exported.id)or not exported.fingerprint then return 'waiting'end
 local text=read('B47ANCEDUI/exports/'..exported.id..'.status.txt',1024)
 if text and text:match('^b47ui%-stage=1\nid='..exported.id:gsub('%.','%%.')..'\nexport='..exported.fingerprint..'\nstatus=ready\n$')then return 'ready'end
 return 'waiting'
end
function X.openWorkshop(exported,joypad)
 if X.pending then return false end
 if not getSteamModeActive or not getSteamModeActive()then return false end
 local screen=MainScreen and MainScreen.instance
 local workshop=screen and screen.workshopSubmit
 if not screen or screen.inGame or not workshop or not workshop.fillList or not workshop.setVisible then return false end
 local options=screen.mainOptions
 if options and options:isReallyVisible()then
  -- Native Back owns option rollback, focus and window visibility.
  if not options.onOptionMouseDown or not options.backButton then return false end
  options:onOptionMouseDown(options.backButton)
  if options:isReallyVisible()then
   if not Events or not Events.OnPreUIDraw or not Events.OnPreUIDraw.Remove or X.pending then return false end
   local function resume()
    if MainScreen.instance~=screen or screen.inGame then Events.OnPreUIDraw.Remove(resume);X.pending=nil;return end
    if options:isReallyVisible()and options.modal then return end
    Events.OnPreUIDraw.Remove(resume);X.pending=nil
    if not options:isReallyVisible()then X.openWorkshop(exported,joypad)end
   end
   X.pending=resume;Events.OnPreUIDraw.Add(resume);return true
  end
 end
 if screen.bottomPanel then screen.bottomPanel:setVisible(false)end
 workshop:fillList();workshop:setVisible(true,joypad)
 if workshop.bringToTop then workshop:bringToTop()end
 local page=workshop.page1
 if exported and page and page.aboutToShow and page.onButtonNext and page.listbox then
  page:aboutToShow(joypad)
  for i,entry in ipairs(page.listbox.items or {})do
   if entry.item and entry.item:getFolderName()==exported.id then
    page.listbox.selected=i
    if workshop.page9 then workshop.page9:setVisible(false)end
    page:setVisible(true,joypad);page:onButtonNext();break
   end
  end
 end
 return true
end
return X

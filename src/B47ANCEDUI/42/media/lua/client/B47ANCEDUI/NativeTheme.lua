-- Audited native instances only. No geometry, input, action or game-state edits.
require 'ISUI/ISUIElement'
local entries=require 'B47ANCEDUI/NativeRegistry'
local N=require 'B47ANCEDUI/NativePainters'
local P=require 'B47ANCEDUI/NativePresentation'
local C=require 'B47ANCEDUI/NativeContext'
local U=B47ANCEDUI
if U.NativeTheme then return U.NativeTheme end
local H={};U.NativeTheme=H
local byType,byName,identities={},{},setmetatable({},{__mode='k'})
for _,entry in ipairs(entries)do
 byName[entry[1]]=entry
 byType[entry[2]]=byType[entry[2]]or {};table.insert(byType[entry[2]],entry)
end
local function resolve(name)
 local value=_G
 for key in name:gmatch('[^.]+')do if type(value)~='table'then return end;value=value[key]end
 return value
end
local function native(w)
 if type(w)~='table'then return end
 local class=getmetatable(w)
 for _,entry in ipairs(byType[w.Type]or {})do
  if resolve(entry[1])==class then
   local identity=identities[class]
   if not identity then identity={pre=class.prerender,render=class.render};identities[class]=identity end
   local state=w.b47NativeTheme
   local menu=w.Type=='MainScreen'and MainScreen and MainScreen.instance==w and w.b47MenuBackgroundRenderer==w.prerender
   if state or menu or(w.prerender==identity.pre and w.render==identity.render)then return entry end
  end
 end
end
local protected={MainOptions=true,ISInventoryPage=true,ISInventoryPane=true}
local function excluded(w)
 for _=1,64 do
  if not w then return false end
  if w.b47NativeThemeExcluded or w.b47Styled or w.b47StyleSafe or w.b47StylePreview or w.b47AppearanceScope or w.b47NativeSettingsOwner or protected[w.Type]then return true end
  if w.parent and w.parent.Type=='MainScreen'and w.parent.bottomPanel==w then return true end
  w=w.parent
 end
 return true
end
local kinds={ISButton='button',ISResizableButton='button',ISComboBox='combo',ISTickBox='tick',ISTextEntryBox='input',
 ISSliderPanel='slider',ISVolumeControl='volume',ISMegaVolumeControl='volume',ISTabPanel='tabs',ISScrollingListBox='list',ISScrollBar='scroll'}
local function kind(entry)
 for _=1,64 do
  if not entry then break end
  if kinds[entry[1]]then return kinds[entry[1]]end
  entry=byName[entry[3]]
 end
 return 'frame'
end
local function active(w)
 if excluded(w)then return false end
 local parent=w.parentCombo or w.parent
 for _=1,64 do
  if not parent then return true end
  if not native(parent)or excluded(parent)then return false end
  parent=parent.parent
 end
 return false
end
local function walk(w,depth,budget)
 if not w or depth>64 or budget.left<=0 or excluded(w)then return end
 budget.left=budget.left-1
 local entry=native(w)
 if not entry then return end -- A consumer/custom renderer owns its entire subtree.
 if w.Type=='ISContextMenu'then C.adopt(w,N.player(w))
 elseif w.Type=='ISToolTip'or w.Type=='ISToolTipInv'then P.tooltip(w,N.player(w),function()return active(w)end)
 elseif w.Type~='MainScreen'and not w.b47NativeButton and not w.b47NativeTooltip and not w.b47NativeContext and not w.b47NativeInventoryScroll then
  if not((kind(entry)=='button')and(w.title==''or w.image))then N.adopt(w,kind(entry),active)end
 end
 for _,child in pairs(w.children or {})do if type(child)=='table'and child.parent==w then walk(child,depth+1,budget)end end
end
function H.adopt(w)return walk(w,0,{left=8192})end
local pending,seen={},setmetatable({},{__mode='k'})
function H.queue(w)
 if type(w)=='table'and not seen[w]then seen[w]=true;pending[#pending+1]=w end
end
function H.flush()
 if #pending==0 then return end
 local batch=pending;pending={};seen=setmetatable({},{__mode='k'})
 local roots={}
 for _,w in ipairs(batch)do
  local root=w
  for _=1,64 do if not root.parent then break end;root=root.parent end
  if not roots[root]then roots[root]=true;H.adopt(root)end
 end
end
-- Construction queues are drained before drawing, after native constructors and
-- existing Options/inventory owners finish. No per-frame tree or world scan.
local new=ISUIElement.new
ISUIElement.new=function(self,...)
 local result=P.pack(new(self,...));H.queue(result[1]);return unpack(result,1,result.n)
end
local add=ISUIElement.addChild
ISUIElement.addChild=function(self,...)
 local result=P.pack(add(self,...));H.queue(self);return unpack(result,1,result.n)
end
Events.OnPreUIDraw.Add(H.flush)
local function current()
 H.queue(MainScreen and MainScreen.instance)
 for player=1,4 do
  local data=ISPlayerData and ISPlayerData[player]
  if data then for _,key in ipairs({'characterInfo','playerInventory','lootInventory','mechanicsUI'})do H.queue(data[key])end end
 end
end
Events.OnMainMenuEnter.Add(current)
Events.OnGameStart.Add(current)
current()
return H

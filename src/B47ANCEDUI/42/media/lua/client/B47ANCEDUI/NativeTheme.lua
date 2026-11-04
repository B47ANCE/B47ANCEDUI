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
local localBases={ModePanel='ISPanel',SandboxOptionsScreenListBox='ISScrollingListBox',SandboxOptionsScreenPanel='ISPanelJoypad',
 SandboxOptionsScreenPresetPanel='ISPanelJoypad',SandboxAdvancedControl='ISPanel',LoadGameScreen_ConfigPanel='ISPanelJoypad',
 LoadGameScreen_InfoPanel='ISPanelJoypad',TagsList='ISScrollingListBox',CharacterCreationProfessionListBox='ISScrollingListBox',
 CharacterCreationProfessionPresetPanel='ISPanelJoypad',CharacterCreationClothingPanel='ISPanelJoypad'}
for i=1,10 do localBases['Page'..i]='ISPanelJoypad'end
-- Host settings and Workshop reuse local PageN names with different bases.
-- Prove the exact screen-owned slot and full class chain before normalizing
-- to the global painter base; a matching type name alone grants no scope.
local serverPanels={ServerSettingsScreenPanel={'ISPanelJoypad'},ServerSettingsScreenGroupBox={'ServerSettingsScreenPanel','ISPanelJoypad'}}
for _,name in ipairs({'SpawnRegionsPanel','ServerSettingsScreenModsPanel','ServerSettingsScreenMapsPanel','ServerSettingsScreenWorkshopPanel','SandboxPresetPanel'})do serverPanels[name]={'MultiColumnPanelJoypad','ISPanelJoypad'}end
local serverLists={SpawnRegionsPanel='SpawnRegionsListBox',ServerSettingsScreenModsPanel='ServerSettingsScreenModsListBox',ServerSettingsScreenMapsPanel='ServerSettingsScreenMapsListBox',ServerSettingsScreenWorkshopPanel='ServerSettingsScreenWorkshopListBox',SandboxPresetPanel='ServerSettingsScreenModsListBox'}
local function serverSlot(w,o)
 if o.Type~='ServerSettingsScreen'then return end
 local slots={{'pageStart','Page1','ISPanelJoypad'},{'pageNew','Page2','BaseServerSettingsPanel'},{'pageEdit','Page3','ISPanelJoypad'},
  {'pageDuplicate','Page4','BaseServerSettingsPanel'},{'pageRename','Page5','BaseServerSettingsPanel'},{'pageDelete','Page6','ISPanelJoypad'}}
 for _,s in ipairs(slots)do if o[s[1]]==w and w.Type==s[2]then return {s[3]},'ISPanelJoypad'end end
 if o.pageSpawnPoints==w and w.Type=='Page7'then return {'MultiColumnPanelJoypad','ISPanelJoypad'},'ISPanelJoypad'end
 local edit=o.pageEdit
 if edit and edit.chooseModsWindow==w and w.Type=='Page3.ChooseModsWindow'then return {'ISPanelJoypad'},'ISPanelJoypad'end
 local function list(owner,field,expected)
  if owner and owner[field]==w and w.Type==expected then return {'ServerSettingsScreenBaseListBox','ISScrollingListBox'},'ISScrollingListBox'end
 end
 local chain,base=list(edit and edit.chooseModsWindow,'listbox','ServerSettingsScreenModsListBox')
 if chain then return chain,base end
 for _,field in ipairs({'profListBox','pointListBox'})do chain,base=list(o.pageSpawnPoints,field,'ServerSettingsScreenMapsListBox');if chain then return chain,base end end
 for _,row in ipairs(edit and edit.listbox and edit.listbox.items or {})do
  local panel=row.item and row.item.panel
  if panel and serverPanels[panel.Type]then
   if panel==w then return serverPanels[panel.Type],'ISPanelJoypad'end
   if panel.Type=='ServerSettingsScreenGroupBox'and panel.contents==w and w.Type=='ServerSettingsScreenPanel'then return {'ISPanelJoypad'},'ISPanelJoypad'end
   chain,base=list(panel,'listbox',serverLists[panel.Type]);if chain then return chain,base end
  end
 end
end
local function derives(class,chain)
 for i,name in ipairs(chain)do
  class=getmetatable(class)
  if not class or class.Type~=name then return false end
  if i==#chain then return class==resolve(name)end
 end
 return false
end
local function slot(w,o)
 local ownerType=({CoopCharacterCreationMain='CharacterCreationMain',CoopCharacterCreationProfession='CharacterCreationProfession'})[o.Type]or o.Type
 if ownerType=='NewGameScreen'and w.Type=='ModePanel'then for _,p in ipairs(o.panels or {})do if p==w then return true end end
 elseif ownerType=='LoadGameScreen'then return o.configPanel==w and w.Type=='LoadGameScreen_ConfigPanel'or o.infoPanel==w and w.Type=='LoadGameScreen_InfoPanel'
 elseif ownerType=='CharacterCreationProfession'then
  for _,key in ipairs({'listboxTraitSelected','listboxTrait','listboxBadTrait','listboxProf'})do if o[key]==w and w.Type=='CharacterCreationProfessionListBox'then return true end end
  return o.presetPanel==w and w.Type=='CharacterCreationProfessionPresetPanel'
 elseif ownerType=='CharacterCreationMain'then return o.clothingPanel==w and w.Type=='CharacterCreationClothingPanel'
 elseif ownerType=='WorkshopSubmit'then
  for i=1,10 do if o['page'..i]==w and w.Type=='Page'..i or i==2 and o.page2 and o.page2.tags==w and w.Type=='TagsList'then return true end end
 elseif ownerType=='SandboxOptionsScreen'then
  if o.listbox==w and w.Type=='SandboxOptionsScreenListBox'or o.presetPanel==w and w.Type=='SandboxOptionsScreenPresetPanel'then return true end
  for _,control in pairs(o.controls or {})do if control==w and w.Type=='SandboxAdvancedControl'then return true end end
  for _,row in ipairs(o.listbox and o.listbox.items or {})do if row.item and row.item.panel==w and w.Type=='SandboxOptionsScreenPanel'then return true end end
 end
 return false
end
-- Two native builders install instance stencil delegates. Capture those exact
-- outputs before painting; a later foreign builder/renderer remains a barrier.
local stencilRecords=setmetatable({},{__mode='k'})
local stencilBuilders=setmetatable({},{__mode='k'})
local function captureStencilBuilders()
 for _,spec in ipairs({{'ISComponentsListPanel','container'},{'ISWidgetIngredientsInputs','panel'}})do
  local class=resolve(spec[1]);local slotName=spec[2]
  if type(class)=='table'and type(class.createChildren)=='function'and not stencilBuilders[class]then
   local delegate=class.createChildren;local wrapper
   wrapper=function(self,...)
    local result=P.pack(delegate(self,...))
    local child=self[slotName]
    if getmetatable(self)==class and self.createChildren==wrapper and class.createChildren==wrapper
     and child and getmetatable(child)==ISPanel and child.parent==self
     and type(rawget(child,'prerender'))=='function'and type(rawget(child,'render'))=='function'then
     stencilRecords[child]={owner=setmetatable({self},{__mode='v'}),class=class,builder=wrapper,slot=slotName,
      pre=child.prerender,render=child.render}
     H.queue(self)
    end
    return unpack(result,1,result.n)
   end
   stencilBuilders[class]=wrapper;class.createChildren=wrapper
  end
 end
end
local native
native=function(w)
 if type(w)~='table'then return end
 local class=getmetatable(w)
 local stencil=stencilRecords[w]
 if stencil then
  local owner=stencil.owner[1]
  if owner and owner[stencil.slot]==w and w.parent==owner and class==ISPanel and getmetatable(owner)==stencil.class
   and owner.createChildren==stencil.builder and stencil.class.createChildren==stencil.builder
   and w.prerender==(stencil.paintPre or stencil.pre)and w.render==(stencil.paintRender or stencil.render)and native(owner)then
   return byName.ISPanel
  end
  return
 end
 for _,entry in ipairs(byType[w.Type]or {})do
  if resolve(entry[1])==class then
   local identity=identities[class]
   if not identity then identity={pre=class.prerender,render=class.render};identities[class]=identity end
   local state=w.b47NativeTheme
   local menu=w.Type=='MainScreen'and MainScreen and MainScreen.instance==w and w.b47MenuBackgroundRenderer==w.prerender
   if state or menu or(w.prerender==identity.pre and w.render==identity.render)then return entry end
  end
 end
 if class and class.Type==w.Type then
  local owner=w.parent
  for _=1,64 do
   if not owner then break end
   local chain,base=serverSlot(w,owner)
   if not chain and localBases[w.Type]and slot(w,owner)then base=localBases[w.Type];chain={base}end
   if chain and derives(class,chain)and native(owner)then
    local identity=identities[class]
    if not identity then identity={pre=class.prerender,render=class.render};identities[class]=identity end
    if w.b47NativeTheme or w.prerender==identity.pre and w.render==identity.render then return {'$local.'..w.Type,w.Type,base}end
    return
   end
   owner=owner.parent
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
-- Options and our public controls retain their own panel painters. Their exact
-- native scrollbar still uses the shared chrome; custom/provider trees do not.
local function scrollActive(w)
 local owned,barrier=false,false
 for _=1,64 do
  if not w then return not barrier end
  if w.b47NativeThemeExcluded or w.b47StyleSafe or w.b47StylePreview then return false end
  if not owned then
   if w.b47Styled and w.b47Kind or w.Type=='MainOptions'and U.OptionsLifecycle and U.OptionsLifecycle.nativeRenderer(w)then owned=true
   elseif not native(w)or w.b47AppearanceScope then barrier=true end
  end
  w=w.parentCombo or w.parent
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
  if not((kind(entry)=='button')and(w.title==''or w.image))then
   local control=kind(entry)
   N.adopt(w,control,control=='scroll'and scrollActive or active)
   local stencil=stencilRecords[w]
   if stencil then stencil.paintPre=w.prerender;stencil.paintRender=w.render end
  end
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
  if w.Type=='ISScrollBar'and not w.b47NativeInventoryScroll and native(w)and scrollActive(w)then N.adopt(w,'scroll',scrollActive)end
  local root=w
  for _=1,64 do if not root.parent then break end;root=root.parent end
  if not roots[root]then roots[root]=true;H.adopt(root)end
 end
end
-- Construction queues are drained before drawing, after native constructors and
-- existing Options/inventory owners finish. No per-frame tree or world scan.
local new=ISUIElement.new
ISUIElement.new=function(self,...)
 captureStencilBuilders()
 local result=P.pack(new(self,...));H.queue(result[1]);return unpack(result,1,result.n)
end
local add=ISUIElement.addChild
ISUIElement.addChild=function(self,...)
 local result=P.pack(add(self,...));H.queue(self);H.queue((...));return unpack(result,1,result.n)
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

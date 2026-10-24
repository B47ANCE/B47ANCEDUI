-- Observe owned Options instances, including construction deferred until draw.
require 'B47ANCEDUI/API'
require 'OptionScreens/MainScreen'
require 'OptionScreens/MainOptions'
local U=B47ANCEDUI;if U.OptionsLifecycle then return U.OptionsLifecycle end
local L={};U.OptionsLifecycle=L
local listeners,order,monitors,monitorOrder={},{},{},{}
local function pack(...)return {n=select('#',...),...}end
local function ready(root,state)
 if state.busy or not root.tabs then return end
 state.busy=true
 local ok,err=pcall(function()
  for _,id in ipairs(order) do
   if state.seen[id]~=root.tabs then
    listeners[id](root)
    state.seen[id]=root.tabs
   end
  end
  for _,id in ipairs(monitorOrder)do monitors[id](root)end
  if listeners['native-settings'] and listeners['interface-page'] then
   local styled=root.b47NativeSettingsOwner==root
   local page=root.b47InterfaceTabs==root.tabs and root.b47InterfacePage~=nil
   if state.reportedTabs~=root.tabs or state.reportedStyle~=styled or state.reportedPage~=page then
    print('B47ANCEDUI Options adapters: styling='..tostring(styled)..', interface='..tostring(page))
    state.reportedTabs=root.tabs;state.reportedStyle=styled;state.reportedPage=page
   end
  end
 end)
 state.busy=false
 if not ok then error(err) end
end
function L.nativeRenderer(root)
 local state=root.b47OptionsLifecycle
 local pre=root.prerender
 if state and pre==state.pre then pre=state.originalPre end
 return pre==MainOptions.prerender and root.render==MainOptions.render
end
function L.observe(root)
 if not root or root.Type~='MainOptions' or type(root.prerender)~='function' then return false end
 local state=root.b47OptionsLifecycle
 if not state then
  state={seen={},originalPre=root.prerender};root.b47OptionsLifecycle=state
  state.pre=function(self,...)
   local result=pack(state.originalPre(self,...))
   ready(self,state)
   return unpack(result,1,result.n)
  end
  root.prerender=state.pre
  if type(root.create)=='function' then
   local create=root.create
   root.create=function(self,...)
    local result=pack(create(self,...))
    ready(self,state)
    return unpack(result,1,result.n)
   end
  end
 end
 ready(root,state);return true
end
function L.current()
 L.observe(MainScreen.instance and MainScreen.instance.mainOptions or MainOptions.instance)
end
function L.register(id,callback)
 assert(not listeners[id],'Duplicate Options lifecycle listener')
 listeners[id]=callback;order[#order+1]=id;L.current()
end
-- Constant-sized observations of known owned fields, after native construction.
function L.monitor(id,callback)
 assert(not monitors[id],'Duplicate Options monitor')
 monitors[id]=callback;monitorOrder[#monitorOrder+1]=id;L.current()
end
Events.OnMainMenuEnter.Add(L.current)
Events.OnGameStart.Add(L.current)
Events.OnResetLua.Add(L.current)
return L

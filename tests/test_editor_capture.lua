-- Exact engine modal semantics: recursive capture, including queued removals.
local C=B47ANCEDUI.EditorControls;local oldUI,oldPopup=UIManager,ISComboBox.SharedPopup
local function list(nodes)return {size=function()return #nodes end,get=function(_,i)return nodes[i+1]end}end
local function node(capture,children)
 local n={capture=capture,children=children or {}}
 function n:isCapture()return self.capture end
 function n:getControls()return list(self.children)end
 function n:isModalVisible()
  if self.capture then return true end
  for _,c in ipairs(self.children)do if c:isModalVisible()then return true end end
  return false
 end
 return n
end
local editor=node(false,{node(true)});local nativeRoot=node(false,{editor})
local popup=node(true);local selector={popup={javaObject=popup}};selector.popup.parentCombo=selector;ISComboBox.SharedPopup=selector.popup
local nodes={nativeRoot,popup}
UIManager={isModalVisible=function()return true end,getUI=function()return list(nodes)end}
assert(not C.foreignModal({javaObject=editor},selector),'Own drag or pending popup removal treated as foreign modal')
selector.expanded=false;assert(not C.foreignModal({javaObject=editor},selector),'Dismissal callback blocked before deferred removal')
selector.popup.parentCombo={};assert(C.foreignModal({javaObject=editor},selector),'Borrowed popup bypassed foreign capture')
selector.popup.parentCombo=selector;nodes[#nodes+1]=node(true)
assert(C.foreignModal({javaObject=editor},selector),'Foreign dialog ignored during owned capture')
nodes[3]={isModalVisible=function()return true end}
assert(C.foreignModal({javaObject=editor},selector),'Unknown engine modal did not fail closed')
UIManager=oldUI;ISComboBox.SharedPopup=oldPopup
print('PASS OFFLINE recursive native capture ownership, deferred popup removal, borrowed popup and foreign/unknown modal guards')

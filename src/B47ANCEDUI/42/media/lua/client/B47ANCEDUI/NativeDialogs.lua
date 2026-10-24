require 'ISUI/ISModalDialog'
require 'ISUI/ISModalRichText'
require 'ISUI/ISConfirmMonitorSettingsDialog'
local P=require 'B47ANCEDUI/NativePresentation'
local L=require 'B47ANCEDUI/OptionsLifecycle'
local U=B47ANCEDUI
if U.NativeDialogs then return U.NativeDialogs end
local D={};U.NativeDialogs=D
function D.adopt(w,class,player,active)
 if not w then return false end
 if w.b47NativeDialog then return true end
 if not P.frame(w,class,player,active,'prerender','dialog')then return false end
 w.b47NativeDialog=true
 -- Exact native buttons only; keep accept/cancel colours, callbacks and focus.
 for _,key in ipairs({'yes','no','ok'})do
  local button=w[key]
  if button then P.button(button,player,function()return active()and button.parent==w end)end
 end
 return true
end
L.monitor('native-dialogs',function(root)
 if root.b47NativeSettingsOwner~=root and not L.nativeRenderer(root)then return end
 local modal=root.modal
 if not modal or modal.target~=root then return end
 local class
 if modal.Type==ISModalDialog.Type and modal.onclick==MainOptions.onConfirmModalClick then class=ISModalDialog
 elseif modal.Type==ISConfirmMonitorSettingsDialog.Type and modal.onclick==MainOptions.onConfirmMonitorSettingsClick then class=ISConfirmMonitorSettingsDialog end
 if class then D.adopt(modal,class,root.playerNum or 0,function()return root.modal==modal end)end
end)
return D

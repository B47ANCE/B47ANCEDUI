-- Public client API. Require this entry point, never another consumer's code.
require 'B47ANCEDUI/Controls'
require 'B47ANCEDUI/Dialog'
require 'B47ANCEDUI/Clipboard'
require 'B47ANCEDUI/LayoutAssets'
local U=B47ANCEDUI
U.AppearanceEditor={open=function(owner) return require('B47ANCEDUI/AppearanceEditor').open(owner) end}
U.StyleEditor={open=function(owner)return require('B47ANCEDUI/StyleEditor').open(owner)end}
U.apiVersion=1
U.version='0.10.0-dev.1'
local styleFamilies={};for _,family in ipairs(U.StylePresets.families)do styleFamilies[family]=true end
U.Styles={
 setFamily=function(widget,family)assert(widget and styleFamilies[family],'Invalid style family');widget.b47StyleFamily=family;return widget end,
 color=function(widget,token,family)return U.ComponentStyles.color(widget,token,family)end,
 number=function(widget,property,fallback,family)return U.ComponentStyles.number(widget,property,fallback,family)end,
}
function U.requireVersion(version)
 assert(version==U.apiVersion,'B47ANCEDUI: unsupported public API version '..tostring(version))
 return U
end
local consumers={}
function U.forMod(id,options)
 local appearance=U.Appearance.context(id,options)
 U.StylePresets.registerScope(id)
 if consumers[id] then return consumers[id] end
 local api=setmetatable({Appearance=appearance,consumerID=id},{__index=U})
 local function own(w) if w then w.b47AppearanceScope=id end;return w end
 function api.skin(w,kind,role) return U.skin(own(w),kind,role) end
 function api.skinChildren(parent) own(parent);return U.skinChildren(parent) end
 for _,key in ipairs({'WindowShell','Panel','Button','MenuButton','IconButton','ScrollList','TextInput','NumberInput','Toggle','Dropdown','Slider'}) do
  local base=U[key];local factory={}
  if base.new then factory.new=function(_,...) return own(base:new(...)) end end
  if base.style then factory.style=function(w,role) return base.style(own(w),role) end end
  if base.sized then factory.sized=function(...) return own(base.sized(...)) end end
  if base.setSize then factory.setSize=function(w,size) return base.setSize(own(w),size) end end
  api[key]=factory
 end
 api.Dialog={decorate=function(dialog,player,owner) return U.Dialog.decorate(own(dialog),player,owner) end,
  confirm=function(player,text,labels,callback,owner) return U.Dialog.confirm(player,text,labels,callback,owner,id) end}
 api.AppearanceEditor={open=function(owner) own(owner);return U.AppearanceEditor.open(owner) end}
 api.StyleEditor={open=function(owner)own(owner);return U.StyleEditor.open(owner)end}
 api.Styles={
  setFamily=function(w,family)return U.Styles.setFamily(own(w),family)end,
  color=function(w,token,family)return U.Styles.color(own(w),token,family)end,
  number=function(w,key,fallback,family)return U.Styles.number(own(w),key,fallback,family)end,
 }
 api.LayoutAssets=U.LayoutAssets.scoped(id)
 api.Tooltip=setmetatable({inspect=function(player,text,owner) return U.Tooltip.inspect(player,text,owner,id) end},{__index=U.Tooltip})
 consumers[id]=api;return api
end
return U

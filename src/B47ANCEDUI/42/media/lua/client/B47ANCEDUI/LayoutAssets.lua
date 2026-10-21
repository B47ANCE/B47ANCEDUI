-- Providers opt in explicitly. No gameplay widget discovery or constructors.
require 'B47ANCEDUI/Theme'
local P=require 'B47ANCEDUI/UILayout'
local R={};B47ANCEDUI.LayoutAssets=R
local definitions,order={},{}
local function finite(n) return type(n)=='number' and n==n and n~=math.huge and n~=-math.huge end
local function viewport(w,h) return finite(w) and finite(h) and w>0 and h>0 end
local function copy(def)
 if not def then return end
 local result={};for k,v in pairs(def) do result[k]=v end
 result.default=P.copy({asset=def.default}).asset;return result
end
function R.register(id,definition)
 assert(P.id(id) and id:find('.',1,true),'Layout asset requires a provider-scoped ID')
 assert(not definitions[id],'Layout asset already registered: '..id)
 assert(#order<64 and type(definition)=='table','Layout asset registration limit/definition')
 assert(type(definition.labelKey)=='string' and definition.labelKey:match('^[A-Za-z][A-Za-z0-9_]+$'),'Localized asset label key required')
 assert(type(definition.preview)=='function' and P.copy({asset=definition.default}).asset,'Safe preview and normalized defaults required')
 assert(definition.dispose==nil or type(definition.dispose)=='function','Invalid preview disposer')
 assert(definition.resize==nil or type(definition.resize)=='function','Invalid owned resize callback')
 for _,key in ipairs({'resizeWidth','resizeHeight'}) do assert(definition[key]==nil or type(definition[key])=='boolean','Invalid resize axis') end
 assert(not (definition.aspect and (definition.resizeWidth==false or definition.resizeHeight==false)),'Aspect requires both resize axes')
 for _,key in ipairs({'minWidth','minHeight','aspect'}) do
  local n=definition[key];assert(n==nil or type(n)=='number' and n==n and n>0 and n<10000,'Invalid layout dimension')
 end
 local def=copy(definition);def.id=id;def.resizable=definition.resizable==true;def.editable=definition.editable~=false
 definitions[id]=def;order[#order+1]=id;return id
end
function R.get(id) return copy(definitions[id]) end
function R.list()
 local result={};for _,id in ipairs(order) do result[#result+1]=copy(definitions[id]) end;return result
end
function R.resolve(id,width,height,profile)
 local def=definitions[id];if not def or not viewport(width,height) then return end
 return P.resolve((profile and profile[id] or not profile and P.entry(id)) or def.default,width,height,def)
end
function R.apply(id,widget,left,top,width,height)
 local def=definitions[id];local saved=P.entry(id)
 if not def or not def.editable or not saved or not widget or not viewport(width,height) or not finite(left) or not finite(top) then return false end
 if not (widget.setX and widget.setY and widget.getWidth and widget.getHeight) then return false end
 local rect=P.resolve(saved,width,height,def)
 if def.resizable and widget.resizable~=false and widget.setWidth and widget.setHeight then
  local minW=math.max(def.minWidth or 80,widget.minimumWidth or 0)
  local minH=math.max(def.minHeight or 40,widget.minimumHeight or 0)
  rect=P.fit(rect,width,height,minW,minH,def.aspect)
  local handle=widget.resizeWidget
  if def.resizeWidth==false or handle and handle.yonly then rect.w=widget:getWidth() end
  if def.resizeHeight==false or handle and handle.xonly then rect.h=widget:getHeight() end
  rect.x=math.max(0,math.min(width-rect.w,rect.x));rect.y=math.max(0,math.min(height-rect.h,rect.y))
  local resize=def.resize or widget.resizeWidget and widget.resizeWidget.resizeFunction
  if resize then resize(widget,rect.w,rect.h) else widget:setWidth(rect.w);widget:setHeight(rect.h) end
 else
  rect.x=math.max(0,math.min(width-widget:getWidth(),rect.x));rect.y=math.max(0,math.min(height-widget:getHeight(),rect.y))
 end
 widget:setX(left+rect.x);widget:setY(top+rect.y);return true
end
function R.scoped(scope)
 local function name(id) assert(P.id(id) and not id:find('.',1,true),'Local asset key required');return scope..'.'..id end
 return {register=function(id,def)return R.register(name(id),def)end,
  resolve=function(id,w,h)return R.resolve(name(id),w,h)end,
  apply=function(id,widget,x,y,w,h)return R.apply(name(id),widget,x,y,w,h)end}
end
return R

-- Atom UI has a separate native lifecycle. Preserve native template/dispatch
-- semantics; never install a fictional __index or replace document content.
require 'PZAPI/ui/atoms/Text'
require 'PZAPI/ui/organisms/Window'
local P=require 'B47ANCEDUI/NativePresentation'
local N=require 'B47ANCEDUI/NativePainters'
local U=B47ANCEDUI
if U.PZAPITheme then return U.PZAPITheme end
local A={};U.PZAPITheme=A
local UI=PZAPI.UI
local function rootOf(w)
 for _=1,64 do if not w or not w.parent then return w end;w=w.parent end
end
local function known(root)
 if not root then return false end
 for _,template in ipairs({UI.Window,UI.FishWindow or false,UI.PrintMedia or false})do
  if template and root.init==template.init and root.setCollapsed==template.setCollapsed then return true end
 end
 if UI.BuildUI and root.init==UI.BuildUI.init and root.getRecipes==UI.BuildUI.getRecipes then return true end
 -- These installed prototype roots have no unique init. Only direct native
 -- template instances qualify; matching shape or a nil init is insufficient.
 if UI.Inventory and root.super==UI.Inventory then return true end
 if UI.playerInventory and root.super==UI.playerInventory then return true end
 return false
end
local function canvas(w,family)return {parent=w,playerNum=N.player(w),b47AppearanceScope='B47ANCEDUI',b47StyleFamily=family}end
local function content(w,root)
 local body=root.children and root.children.body
 local document=body and body.children and body.children.printMedia
 for _=1,64 do
  if not w then return false end
  if w==document or w.b47NativeThemeExcluded or w.b47Styled or w.b47StyleSafe or w.b47AppearanceScope then return true end
  w=w.parent
 end
 return true
end
local function rgba(w)return {r=w.r,g=w.g,b=w.b,a=w.a}end
local function equal(w,c)return w and c and w.r==c.r and w.g==c.g and w.b==c.b end
local borderNames={'leftBorder','rightBorder','topBorder','downBorder'}
local function restore(w)
 local state=w.b47NativeAtom
 if not state then return end
 if equal(w,state.last)then w:setColor(state.base.r,state.base.g,state.base.b,w.a)end
 for name,saved in pairs(state.borders or {})do
  local child=w.children[name]
  if equal(child,saved.last)then child:setColor(saved.base.r,saved.base.g,saved.base.b,child.a)end
 end
 state.last=nil;state.borders=nil
end
local function apply(w)
 local root=rootOf(w)
 if not w.javaObj or not w.b47NativeAtom then return end
 if not known(root)or content(w,root)then restore(w);return end
 local state=w.b47NativeAtom;local kind=state.kind
 if not equal(w,state.last)then state.base=rgba(w)end
 if (kind=='panel'or kind=='button')and not w.isSearch and not P.neutral(state.base.r,state.base.g,state.base.b)then restore(w);return end
 local proxy=canvas(w,kind=='panel'and 'window'or kind=='thumb'and 'scrollbar'or kind=='tab'and 'tabs'or 'button')
 local token=kind=='panel'and 'window'or kind=='thumb'and 'accent'or kind=='image'and(w.b47NativeAtom.hover and 'accentHover'or 'text')or kind=='tab'and(w.selected and 'selected'or 'raised')or w.isSearch and 'selected'or(w.b47NativeAtom.hover and 'hover'or 'raised')
 if kind=='thumb'and U.ComponentStyles.properties(proxy).scrollThumb then token='scrollThumb'end
 if kind=='image'then token=w.enable==false and 'iconDisabled'or w.b47NativeAtom.hover and 'accentHover'or 'icon'end
 if kind=='panel'and root.children then
  local props=U.ComponentStyles.properties(proxy)
  if w==root.children.bar and props.titleBackground then token='titleBackground'elseif w==root.children.bottomBar and props.statusBackground then token='statusBackground'end
 end
 local c=U.ComponentStyles.color(proxy,U.Theme.colors[token])
 -- Live alpha is native state (fade, hover, collapsed/transparent surfaces).
 w:setColor(c.r,c.g,c.b,w.a)
 state.last=rgba(w)
 if w.setBorderColor==UI.Panel.setBorderColor then
  local border=U.ComponentStyles.color(proxy,U.Theme.colors.border)
  state.borders=state.borders or {}
  for _,name in ipairs(borderNames)do
   local child=w.children[name];local saved=state.borders[name]
   if not saved or not equal(child,saved.last)then saved={base=rgba(child)};state.borders[name]=saved end
   child:setColor(border.r,border.g,border.b,child.a);saved.last=rgba(child)
  end
 end
end
local chromeKeys={titlePanel=true,searchPanel=true,searchButton=true,settingsButton=true,filterButton=true,background=true,scrollPanel=true,leftButton=true,rightButton=true}
local function prepare(w,root,depth,key,parent,grandparent)
 if not w or depth>48 or content(w,root)then return end
 local panel=w.setBorderColor==UI.Panel.setBorderColor and P.neutral(w.r,w.g,w.b)
 local button=UI.TextButton and w.onHover==UI.TextButton.onHover
 local image=UI.ImageButton and w.onHover==UI.ImageButton.onHover
 local tab=w.textureSelected and w.textureUnselected and w.setSelected and w.children and w.children.label
 local texture=UI.Texture and w.setTexture==UI.Texture.setTexture and w.setSlice9==UI.Texture.setSlice9
 local chrome=texture and not w.texture and chromeKeys[key]and P.neutral(w.r,w.g,w.b)
 local thumb=texture and grandparent and UI.ScrollBarVertical and grandparent.setBarSize==UI.ScrollBarVertical.setBarSize and(key=='top'or key=='mid'or key=='bottom')
 if (panel or button or image or tab or chrome or thumb)and not w.b47NativeAtom then
  w.b47NativeAtom={kind=button and 'button'or image and 'image'or thumb and 'thumb'or tab and 'tab'or chrome and w.onHover and 'button'or 'panel'}
  root.b47NativeAtomNodes=root.b47NativeAtomNodes or {}
  root.b47NativeAtomNodes[#root.b47NativeAtomNodes+1]=w
  for _,method in ipairs({'onHover','setSelected'})do
   local delegate=w[method]
   if type(delegate)=='function'then w[method]=function(self,value,...)
    -- Native hover helpers may snapshot their current colour for mouse-out.
    -- Lend the native state, so they never capture our persistent tint.
    local state=self.b47NativeAtom
    if equal(self,state.last)then self:setColor(state.base.r,state.base.g,state.base.b,self.a)end
    local result=P.pack(pcall(delegate,self,value,...))
    if method=='onHover'then self.b47NativeAtom.hover=value end
    apply(self)
    if not result[1]then error(result[2],0)end
    return unpack(result,2,result.n)
   end end
  end
 end
 for name,child in pairs(w.children or {})do prepare(child,root,depth+1,name,w,parent)end
end
local function paint(w,root,depth)
 if not w or depth>48 or content(w,root)then return end
 apply(w)
 for _,child in pairs(w.children or {})do paint(child,root,depth+1)end
end
function A.adopt(root)
 if not known(root)or content(root,root)then return false end
 prepare(root,root,0);paint(root,root,0);return true
end
local function observe(root)
 if root.b47NativeAtomObserver then return end
 root.b47NativeAtomObserver=true
 local delegate=root.renderUpdate
 -- A fixed list of adopted chrome nodes, never a per-frame subtree scan.
 -- Resolve live presets on draw: a preview, Cancel or opt-out needs no reopen.
 root.renderUpdate=function(self,...)
  local result={n=0}
  if delegate then result=P.pack(delegate(self,...))end
  for _,node in ipairs(self.b47NativeAtomNodes or {})do apply(node)end
  return unpack(result,1,result.n)
 end
end
local instantiate=UI._mt.instantiate
UI._mt.instantiate=function(self,...)
 if known(self)and not content(self,self)then prepare(self,self,0);observe(self)end
 local result=P.pack(instantiate(self,...))
 A.adopt(self);return unpack(result,1,result.n)
end
local add=UI._addChild
UI._addChild=function(parent,child,...)
 local root=rootOf(parent)
 if known(root)and not content(parent,root)then prepare(child,root,0)end
 local result=P.pack(add(parent,child,...))
 if known(root)and not content(parent,root)then paint(child,root,0)end
 return unpack(result,1,result.n)
end
return A

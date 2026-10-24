-- Resolves presentation tokens without mutating shared defaults or control values.
local P=require 'B47ANCEDUI/StylePresets'
local U=B47ANCEDUI;local T=U.Theme;if U.ComponentStyles then return U.ComponentStyles end
local S={};U.ComponentStyles=S
local cache={};local aliases={combo='dropdown',root='window',label='text',menu='menuButton'}
local colorKeys={window='windowBackground',panel='panelBackground',raised='raisedBackground',row='rowBackground',overlay='overlayBackground',
 alternate='alternate',hover='hover',selected='selected',border='border',strong='focus',text='text',muted='muted',
 accent='accent',accentHover='accentHover',disabled='disabled',destructive='danger',needed='danger',warning='warning',success='success'}
local tokens={};for key,property in pairs(colorKeys)do tokens[T.colors[key]]=property end
for key in pairs(T.colorAliases)do tokens[T.colors[key]]=key end
local fallback={windowBackground='background',panelBackground='background',raisedBackground='background',rowBackground='background',overlayBackground='background'}
for key,base in pairs(T.colorAliases)do if not fallback[key]then fallback[key]=colorKeys[base]or base end end
local function allowed(w)
 for _=1,32 do
  if not w then return true end
  if w.b47StylePreview then return true,w.b47StylePreviewShared end
  if w.b47StyleSafe then return false end
  w=w.parent
 end
 return false
end
function S.family(w,kind)
 local family=kind or w and (w.b47DrawingStyleFamily or w.b47StyleFamily or w.b47Kind)or 'panel'
 if family=='button' and w and w.b47ButtonSize=='small'then return 'buttonSmall'end
 return aliases[family] or family
end
function S.properties(w,kind)
 local permitted,shared=allowed(w)
 if not permitted then return {}end
 local player=U.Appearance and U.Appearance.player(w)or 0
 local scope=shared and '*'or U.Appearance and U.Appearance.scope(w)or 'B47ANCEDUI'
 local family=S.family(w,kind);local revision=P.revision(player)
 local key=scope..':'..family;local pc=cache[player]
 if not pc or pc.revision~=revision then pc={book=P.current(player),revision=revision,values={}};cache[player]=pc end
 if pc.values[key]then return pc.values[key]end
 local book=pc.book
 local preset=book.presets[book.bindings[scope]or book.active];local out={}
 for _,target in ipairs({'*',scope})do
  local values=preset and preset.values[target]or {}
  local groups=family=='scrollbar'and {'all','slider','scrollbar'}or {'all',family}
  for _,group in ipairs(groups)do for property,value in pairs(values[group]or {})do out[property]=value end end
 end
 pc.values[key]=out;return out
end
local function rgba(hex,alpha)return {r=tonumber(hex:sub(2,3),16)/255,g=tonumber(hex:sub(4,5),16)/255,b=tonumber(hex:sub(6,7),16)/255,a=alpha or 1}end
function S.color(w,c,kind)
 local property=tokens[c];local p=property and S.properties(w,kind)or {};local key=property
 for _=1,8 do
  if not key then break end
  if p[key]then
   local out=rgba(p[key],c.a)
   if property=='pressed'and key~='pressed'then out.r=out.r*.5;out.g=out.g*.5;out.b=out.b*.5 end
   return out
  end
  key=fallback[key]
 end
 local base=property and T.colorAliases[property]
 local original=base and T.colors[base]or c
 local inherited=U.Appearance and U.Appearance.color(w,original)or original
 return inherited==original and c or {r=inherited.r,g=inherited.g,b=inherited.b,a=c.a}
end
function S.buttonFill(w,a,r,g,b,canvas)
 canvas=canvas or w
 if not w.pressed or not S.properties(canvas).pressed then return a,r,g,b end
 local fill=S.color(canvas,T.colors.pressed);local bg=canvas~=w and S.color(canvas,T.colors.raised)or w.backgroundColor or T.colors.raised
 local f=w.fade and w.fade.fraction and w.fade:fraction()or 1
 return a,fill.r*f+bg.r*(1-f),fill.g*f+bg.g*(1-f),fill.b*f+bg.b*(1-f)
end
function S.propertyColor(w,property,family)
 local p=S.properties(w,family)
 if p[property]then return rgba(p[property])end
 local alias={background='panel',danger='destructive',focus='strong'}
 return S.color(w,T.colors[property]or T.colors[alias[property]or 'panel'],family)
end
function S.number(w,key,fallback,kind)local value=S.properties(w,kind)[key];return type(value)=='number'and value or fallback end
function S.radius(w,fallback)return S.number(w,'radius',fallback)end
function S.geometry(w)
 local base=w.b47StyleSliderBase;if not base then return end
 local p=not w.b47StyleSliderOwned or w.b47StyleSliderOwned(w)
 p=p and S.properties(w,'slider')or {}
 local bar,thumb=base.bar,base.thumb
 w.sliderBarDim={x=bar.x,y=bar.y,w=bar.w,h=bar.h};w.sliderDim={x=thumb.x,y=thumb.y,w=thumb.w,h=thumb.h}
 if p.trackThickness then w.sliderBarDim.h=math.min(w:getHeight(),p.trackThickness);w.sliderBarDim.y=(w:getHeight()-w.sliderBarDim.h)/2 end
 if p.thumbWidth then w.sliderDim.w=math.min(math.max(1,w:getWidth()),p.thumbWidth)end
 if p.thumbHeight then w.sliderDim.h=math.min(math.max(1,w:getHeight()),p.thumbHeight);w.sliderDim.y=(w:getHeight()-w.sliderDim.h)/2 end
end
function S.captureSlider(w)
 if w.sliderBarDim and w.sliderDim then w.b47StyleSliderBase={bar=P.copy(w.sliderBarDim),thumb=P.copy(w.sliderDim)};S.geometry(w)end
end
function S.slider(w,owned)
 w.b47StyleFamily='slider'
 w.b47StyleSliderOwned=owned
 if w.b47StyleSlider or not w.paginate or w.customPaginate then return end
 w.b47StyleSlider=true;local paginate=w.paginate
 w.paginate=function(self,...)
  local result={paginate(self,...)};S.captureSlider(self);return unpack(result)
 end
 S.captureSlider(w)
end
function S.prepare(w,kind)
 local p=S.properties(w,w.b47StyleFamily or kind)
 if not U._hasEntries(p)then
  if w.b47StyleSliderBase then S.geometry(w)end
  return
 end
 -- Save inherited native palette, so Cancel/removing an override is reversible.
 local map={backgroundColor='background',backgroundColorMouseOver='hover',borderColor='border',textColor='text',
 textColorDisabled='disabledText',selectedTextColor='selectedText',choicesColor='text',selectionColor='selected',sliderBarColor='track',sliderBarBorderColor='trackBorder',
 sliderColor='thumb',sliderMouseOverColor='thumbHover',sliderBorderColor='thumbBorder',buttonColor='raisedBackground',buttonMouseOverColor='hover'}
 w.b47StyleSaved=w.b47StyleSaved or {}
 for field,property in pairs(map)do
  if field=='backgroundColor'then property=kind=='window'and 'windowBackground'or kind=='button'and 'raisedBackground'or 'panelBackground'end
  local resolved=property
  for _=1,8 do if not resolved or p[resolved]then break end;resolved=fallback[resolved]end
  if w[field]and resolved and p[resolved]then
   if not w.b47StyleSaved[field]then w.b47StyleSaved[field]=T.copy(w[field])end
   w[field]=rgba(p[resolved],w[field].a)
  elseif w.b47StyleSaved[field]then w[field]=T.copy(w.b47StyleSaved[field]);w.b47StyleSaved[field]=nil end
 end
 if p.opacity and w.backgroundColor and kind~='menuButton'then
  if not w.b47StyleSaved.backgroundColor then w.b47StyleSaved.backgroundColor=T.copy(w.backgroundColor)end
  -- Native transparent child panels must not gain an opaque backing.
  if w.backgroundColor.a>0 then w.backgroundColor=T.copy(w.backgroundColor);w.backgroundColor.a=p.opacity/100 end
  if S.family(w,w.b47StyleFamily or kind)=='slider'and w.sliderBarColor and w.sliderBarColor.a>0 then
   if not w.b47StyleSaved.sliderBarColor then w.b47StyleSaved.sliderBarColor=T.copy(w.sliderBarColor)end
   w.sliderBarColor=T.copy(w.sliderBarColor);w.sliderBarColor.a=p.opacity/100
  end
 end
 if w.b47StyleSliderBase then S.geometry(w)end
end
function S.restore(w)
 if w.b47StyleSaved then for key,value in pairs(w.b47StyleSaved)do w[key]=T.copy(value)end;w.b47StyleSaved=nil end
end
-- The native combobox popup is shared. Borrow its frame only during draws for
-- an explicitly styled API combo, then restore every field/method on failure.
function S.dropdown(w)
 if w.b47StyleDropdown or not w.showPopup then return end
 w.b47StyleDropdown=true;local show=w.showPopup
 w.showPopup=function(self,...)
  local result=show(self,...);local popup=ISComboBox and ISComboBox.SharedPopup
  if not popup or popup.parentCombo~=self or popup.b47APIStyleFrame then return result end
  popup.b47APIStyleFrame=true
  local function frame(delegate,p,...)
   local combo=p.parentCombo
   if not combo or not combo.b47StyleDropdown then return delegate(p,...)end
   local bg,edge=p.backgroundColor,p.borderColor
   p.backgroundColor=T.copy(S.color(combo,T.colors.panel,'dropdown'));p.backgroundColor.a=S.number(combo,'opacity',99,'dropdown')/100
   p.borderColor=T.copy(S.color(combo,T.colors.border,'dropdown'))
   local raw=rawget(p,'drawRectBorderStatic');local border=p.drawRectBorderStatic
   if border then p.drawRectBorderStatic=function(target,x,y,width,height,alpha,r,g,b,...)
    if x==-1 and y==-1 and width==target:getWidth()+2 and height==target:getHeight()+2 then
     local c=p.borderColor;r,g,b=c.r,c.g,c.b
    end
    return border(target,x,y,width,height,alpha,r,g,b,...)
   end end
   local ok,value=pcall(delegate,p,...)
   p.backgroundColor=bg;p.borderColor=edge;p.drawRectBorderStatic=raw
   if not ok then error(value)end;return value
  end
  local pre,render=popup.prerender,popup.render
  popup.prerender=function(p,...)return frame(pre,p,...)end
  popup.render=function(p,...)return frame(render,p,...)end
  return result
 end
end
return S

require 'B47ANCEDUI/Theme'
local U=B47ANCEDUI;local T=U.Theme;local R={};U.Renderer=R
local function color(w,c) return U.Appearance and U.Appearance.color(w,c) or c end
local corners={}
local function corner(width,height,radius)
 local r=math.max(0,math.min(8,math.floor(radius or 0),math.floor(math.min(width,height)/2)))
 if not corners[r] then
  local offsets={}
  for y=0,r-1 do offsets[y+1]=math.ceil(r-math.sqrt(r*r-(r-y-.5)^2)-.5) end
  corners[r]=offsets
 end
 return r,corners[r]
end
function R.roundedRect(w,x,y,width,height,c,radius)
 c=color(w,c)
 if width<=0 or height<=0 then return end
 local draw=w.b47RawRect or w.drawRect;local r,offsets=corner(width,height,radius)
 for row=0,r-1 do
  local inset=offsets[row+1]
  draw(w,x+inset,y+row,width-2*inset,1,c.a,c.r,c.g,c.b)
  draw(w,x+inset,y+height-row-1,width-2*inset,1,c.a,c.r,c.g,c.b)
 end
 if height>2*r then draw(w,x,y+r,width,height-2*r,c.a,c.r,c.g,c.b) end
end
function R.roundedBorder(w,x,y,width,height,c,radius)
 c=color(w,c)
 if width<=0 or height<=0 then return end
 local draw=w.b47RawRect or w.drawRect;local r,offsets=corner(width,height,radius)
 if r==0 then return (w.b47RawBorder or w.drawRectBorder)(w,x,y,width,height,c.a,c.r,c.g,c.b) end
 for row=0,r-1 do
  local inset=offsets[row+1];local edge=row==0 and width-2*inset or math.max(1,offsets[row]-inset)
  for _,yy in ipairs({y+row,y+height-row-1}) do
   draw(w,x+inset,yy,edge,1,c.a,c.r,c.g,c.b)
   if row>0 and width-2*inset>edge then draw(w,x+width-inset-edge,yy,edge,1,c.a,c.r,c.g,c.b) end
  end
 end
 if height>2*r then
  draw(w,x,y+r,1,height-2*r,c.a,c.r,c.g,c.b)
  if width>1 then draw(w,x+width-1,y+r,1,height-2*r,c.a,c.r,c.g,c.b) end
 end
end
-- Only a styled instance's exact backing bounds are rounded. Native callbacks,
-- textures, stripes, list rows and all other drawing retain their own geometry.
function R.round(w,radius)
 w.b47Radius=radius
 if w.b47RawRect or not w.drawRect or not w.drawRectBorder then return end
 w.b47RawRect=w.drawRect;w.b47RawBorder=w.drawRectBorder
 w.drawRect=function(self,x,y,width,height,a,r,g,b)
  if x==0 and y==0 and width==self:getWidth() and height==self:getHeight() then
   return R.roundedRect(self,x,y,width,height,{a=a,r=r,g=g,b=b},self.b47Radius)
  end
  return self.b47RawRect(self,x,y,width,height,a,r,g,b)
 end
 w.drawRectBorder=function(self,x,y,width,height,a,r,g,b)
  if x==0 and y==0 and width==self:getWidth() and height==self:getHeight() then
   return R.roundedBorder(self,x,y,width,height,{a=a,r=r,g=g,b=b},self.b47Radius)
  end
  return self.b47RawBorder(self,x,y,width,height,a,r,g,b)
 end
end
function R.rect(w,x,y,width,height,c) c=color(w,c);if width>0 and height>0 then w:drawRect(x,y,width,height,c.a,c.r,c.g,c.b) end end
function R.background(w,x,y,width,height,c)
 c=color(w,c)
 if width>0 and height>0 then w:drawRect(x,y,width,height,U.Appearance and U.Appearance.alpha(w) or c.a,c.r,c.g,c.b) end
end
function R.border(w,x,y,width,height,c) c=color(w,c);if width>0 and height>0 then w:drawRectBorder(x,y,width,height,c.a,c.r,c.g,c.b) end end
function R.text(w,text,x,y,c,font) c=color(w,c);w:drawText(tostring(text or ''),x,y,c.r,c.g,c.b,c.a,font or T.fonts.body) end
function R.fit(text,width,font)
 text=tostring(text or '');font=font or T.fonts.body
 local measure=getTextManager();if measure:MeasureStringX(font,text)<=width then return text end
 local suffix='...';local n=#text
 while n>0 do
  n=n-1;while n>0 and string.byte(text,n+1)>=128 and string.byte(text,n+1)<192 do n=n-1 end
  local candidate=string.sub(text,1,n)..suffix
  if measure:MeasureStringX(font,candidate)<=width then return candidate end
 end
 return ''
end
function R.focus(w)
 if w.joypadFocused or w.joyfocus or w.isFocused and w:isFocused() then
  R.roundedBorder(w,1,1,w:getWidth()-2,w:getHeight()-2,T.colors.accent,math.max(0,(w.b47Radius or 0)-1))
  R.roundedBorder(w,2,2,w:getWidth()-4,w:getHeight()-4,T.colors.strong,math.max(0,(w.b47Radius or 0)-2))
 end
end
function R.row(w,y,height,index,selected,hover)
 local c=color(w,selected and T.colors.selected or hover and T.colors.hover or index%2==0 and T.colors.alternate or T.colors.row)
 -- The root owns the single backing pass. Rows add a light contrast overlay,
 -- while the opaque selection stripe stays independent of user opacity.
 local a=U.Appearance and U.Appearance.alpha(w)*.12 or c.a
 w:drawRect(0,y,w:getWidth(),height-1,a,c.r,c.g,c.b)
 if selected then R.rect(w,0,y,3,height-1,T.colors.accent) end
end
function R.checkbox(w,x,y,state)
 R.border(w,x,y,16,16,T.colors.strong)
 if state=='full' then R.text(w,'x',x+3,y-1,T.colors.accent)
 elseif state=='partial' then R.rect(w,x+3,y+7,10,3,T.colors.accent) end
end
function R.icon(w,texture,x,y,size)
 if texture then
  if w.drawTextureScaledAspect then w:drawTextureScaledAspect(texture,x,y,size,size,1,1,1,1)
  else w:drawTextureScaled(texture,x,y,size,size,1,1,1,1) end
 else R.border(w,x+3,y+3,size-6,size-6,T.colors.border) end
end
U.Badge={}
function U.Badge.draw(w,label,x,y,role) R.text(w,label,x,y,T.colors[role] or T.colors.muted,T.fonts.status) end
U.Progress={}
function U.Progress.draw(w,x,y,width,current,target,role)
 R.rect(w,x,y,width,8,T.colors.raised)
 local ratio=target and target>0 and math.min(1,math.max(0,current/target)) or 0
 R.rect(w,x,y,width*ratio,8,T.colors[role] or T.colors.accent)
 R.border(w,x,y,width,8,T.colors.border)
end
U.Tree={indent=function(depth) return 6+(depth or 0)*20 end,checkbox=R.checkbox}
U.Table={}
function U.Table.prepare(list,columns)
 list.b47Columns=columns
 local width=list:getWidth()-T.metrics().scrollbar;local x=8
 for _,c in ipairs(columns) do c.x=x;c.width=math.max(16,width*c.share);c.headerText=R.fit(c.label,c.width-12,T.fonts.body);x=x+c.width end
 for _,entry in ipairs(list.items) do
  entry.b47Cells={}
  for i,c in ipairs(columns) do entry.b47Cells[i]=R.fit(entry.item.cells and entry.item.cells[i] or '',c.width-(i==1 and entry.item.texture and 42 or 12),T.fonts.body) end
 end
end
function U.Table.draw(list,y,entry)
 if y+list:getYScroll()+entry.height<0 or y+list:getYScroll()>=list:getHeight() then return y+entry.height end
 R.row(list,y,entry.height,entry.index,list.selected==entry.index,list.mouseoverselected==entry.index and list:isMouseOver())
 local columns=list.b47Columns
 for i,c in ipairs(columns or {}) do
  local x=c.x;local color=entry.item.role and i==#columns and T.colors[entry.item.role] or T.colors.text
  if i==1 and entry.item.texture then R.icon(list,entry.item.texture,x,y+(entry.height-24)/2,24);x=x+30 end
  R.text(list,entry.b47Cells and entry.b47Cells[i] or '',x,y+(entry.height-T.metrics().font)/2,color)
 end
 return y+entry.height
end
return R

-- Native creation and saved-layout restoration must run before our observers.
require 'ISUI/PlayerData/ISPlayerData'
require 'ISUI/ISInventoryPage'
require 'ISUI/ISInventoryPane'
require 'ISUI/ISScrollBar'
local P=require 'B47ANCEDUI/NativePresentation'
local D=require 'B47ANCEDUI/NativeDialogs'
local U=B47ANCEDUI
if U.NativeInventory then return U.NativeInventory end
local I={};U.NativeInventory=I
local function belongs(w,root)
 for _=1,16 do if w==root then return true end;w=w and w.parent;if not w then return false end end
 return false
end
local function buttons(container,root,player,active)
 if not container or container.b47NativeInventoryButtons then return end
 container.b47NativeInventoryButtons=true
 local function adopt(button)
  P.button(button,player,function()return active()and belongs(button,root)end)
 end
 for _,child in pairs(container.children or {})do adopt(child)end
 -- Native controls panels remove/re-add cached handler buttons when arranged.
 local add=container.addChild
 if add then container.addChild=function(self,child,...)
  local result=P.pack(add(self,child,...));adopt(child);return unpack(result,1,result.n)
 end end
end
local function scrollbar(w,player,active)
 if not P.native(w,ISScrollBar) or w.b47NativeInventoryScroll then return end
 w.b47NativeInventoryScroll=true
 local render=w.render
 w.render=function(self,...)
  if not active()or not self.vertical then return render(self,...)end
  local rect,border,scaled,texture=self.drawRect,self.drawRectBorder,self.drawTextureScaled,self.drawTexture
  local canvas=P.canvas(self,player,'scrollbar',rect,border)
  return P.around(self,render,{
   drawRect=function(target,x,y,width,height,a,r,g,b,...)
    if x==4 and y==0 and width==target.width-5 and height==target.height then return P.fill(canvas,x,y,width,height,'scrollTrack',a,0)end
    return rect(target,x,y,width,height,a,r,g,b,...)
   end,
   drawRectBorder=function(target,x,y,width,height,a,r,g,b,...)
    if x==3 and y==0 and width==target.width-4 and height==target.height then return P.edge(canvas,x,y,width,height,'border',a,0)end
    return border(target,x,y,width,height,a,r,g,b,...)
   end,
   drawTextureScaled=function(target,tex,x,y,width,height,a,r,g,b,...)
    if tex==target.midtex and x==5 and y==target.bary+2 and width==9 and height==target.barheight-4 then return P.fill(canvas,x,y,width,height,self.scrolling and 'scrollThumbHover'or 'scrollThumb',a,0)end
    return scaled(target,tex,x,y,width,height,a,r,g,b,...)
   end,
   drawTexture=function(target,tex,x,y,a,r,g,b,...)
    if x==5 and ((tex==target.toptex and y==target.bary)or(tex==target.bottex and y==target.bary+target.barheight-3))then
     local c=P.color(canvas,self.scrolling and 'scrollThumbHover'or 'scrollThumb');r,g,b=c.r,c.g,c.b
    elseif tex==target.uptex or tex==target.downtex then
     local c=P.color(canvas,'scrollArrow');r,g,b=c.r,c.g,c.b
    end
    return texture(target,tex,x,y,a,r,g,b,...)
   end},...)
 end
end
local function pane(w,root,player,active)
 if not P.native(w,ISInventoryPane)or w.b47NativeInventoryPane or w.renderdetails~=ISInventoryPane.renderdetails then return end
 w.b47NativeInventoryPane=true
 local details=w.renderdetails
 w.renderdetails=function(self,...)
  if not active()then return details(self,...)end
  local rect,static,border=self.drawRect,self.drawRectStatic,self.drawRectBorder
  local canvas=P.canvas(self,player,'row',rect,border)
  local fixed=P.canvas(self,player,'row',static,self.drawRectBorderStatic or border)
  return P.around(self,details,{
   drawRect=function(target,x,y,width,height,a,r,g,b,...)
    if height==target.itemHgt then
     if width==target:getWidth()-1 and r==1 and g==1 and b==1 and (P.equal(a,.2)or P.equal(a,.05))then return P.fill(canvas,x,y,width,height,P.equal(a,.2)and 'selected' or 'hover',a,0)end
     if not target.highlightItem and width==target.column4 and P.neutral(r,g,b)then
      if r==1 and P.equal(a,.02)then return P.fill(canvas,x,y,width,height,'alternate',.12,0)end
      if r==0 and (P.equal(a,.2)or P.equal(a,.4))then return P.fill(canvas,x,y,width,height,'row',a,0)end
     end
    end
    return rect(target,x,y,width,height,a,r,g,b,...)
   end,
   drawRectStatic=function(target,x,y,width,height,a,r,g,b,...)
    if x==0 and y==0 and width==target.column2 and height==target.height and r==0 and g==0 and b==0 and P.equal(a,.6)then return P.fill(fixed,x,y,width,height,'raised',a,0)end
    if x==1 and y==0 and width==target:getWidth()-2 and height==target.headerHgt and r==0 and g==0 and b==0 and a==1 then return P.fill(fixed,x,y,width,height,'panel',a,0)end
    return static(target,x,y,width,height,a,r,g,b,...)
   end},...)
 end
 local update=w.updateTooltip
 w.updateTooltip=function(self,...)
  local result=P.pack(update(self,...));local tip=self.toolRender
  if active()and tip then P.tooltip(tip,player,function()return active()and self.toolRender==tip end)end
  return unpack(result,1,result.n)
 end
 buttons(w,root,player,active);scrollbar(w.vscroll,player,active)
end
function I.adopt(root,player,slot)
 if not P.native(root,ISInventoryPage)or root.b47NativeInventory then return false end
 local function active()
  local data=ISPlayerData and ISPlayerData[player+1]
  return data and data[slot]==root
 end
 root.b47NativeInventory=true
 local pre,render=root.prerender,root.render
 local function paint(delegate,self,...)
  if not active()then return delegate(self,...)end
  local info=self.infoRichText
  if info then D.adopt(info,ISModalRichText,player,function()return active()and self.infoRichText==info end)end
  local rect,border,texture=self.drawRect,self.drawRectBorder,self.drawTextureScaled
  local canvas=P.canvas(self,player,'window',rect,border)
  local title=self:titleBarHeight();local full=self.isCollapsed and title or self:getHeight()
  return P.around(self,delegate,{
   drawRect=function(target,x,y,width,height,a,r,g,b,...)
    if x==0 and y==0 and width==target:getWidth()and height==full and P.neutral(r,g,b)then return P.fill(canvas,x,y,width,height,'window')end
    if x==target:getWidth()-target.buttonSize and y==title and width==target.buttonSize and target.inventoryPane and height==target.inventoryPane.height and P.neutral(r,g,b)then return P.fill(canvas,x,y,width,height,'panel',a,0)end
    return rect(target,x,y,width,height,a,r,g,b,...)
   end,
   drawRectBorder=function(target,x,y,width,height,a,r,g,b,...)
    if P.neutral(r,g,b)then return P.edge(canvas,x,y,width,height,'border',a,0)end
    return border(target,x,y,width,height,a,r,g,b,...)
   end,
   drawTextureScaled=function(target,tex,x,y,width,height,a,r,g,b,...)
    if tex==target.titlebarbkg and x==2 and y==1 and width==target:getWidth()-4 and height==title-2 then return P.fill(canvas,x,y,width,height,'titleBackground',a,0)end
    if tex==target.statusbarbkg and x==1 and width==target:getWidth()-2 and y+height==full-1 then return P.fill(canvas,x,y,width,height,'statusBackground',a,0)end
    return texture(target,tex,x,y,width,height,a,r,g,b,...)
   end},...)
 end
 root.prerender=function(self,...)return paint(pre,self,...)end
 root.render=function(self,...)return paint(render,self,...)end
 buttons(root,root,player,active);buttons(root.controlsUI,root,player,active);buttons(root.containerButtonPanel,root,player,active)
 pane(root.inventoryPane,root,player,active)
 local add=root.addContainerButton
 root.addContainerButton=function(self,...)
  local result=P.pack(add(self,...));local button=result[1]
  if button then P.button(button,player,function()return active()and belongs(button,root)end)end
  return unpack(result,1,result.n)
 end
 return true
end
function I.current()
 for player=0,3 do
  local data=ISPlayerData and ISPlayerData[player+1]
  if data then
   I.adopt(data.playerInventory,player,'playerInventory')
   I.adopt(data.lootInventory,player,'lootInventory')
  end
 end
end
Events.OnCreatePlayer.Add(I.current)
Events.OnGameStart.Add(I.current)
Events.OnResolutionChange.Add(I.current)
return I

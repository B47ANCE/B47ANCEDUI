require 'ISUI/ISContextMenu'
local P=require 'B47ANCEDUI/NativePresentation'
local U=B47ANCEDUI
if U.NativeContext then return U.NativeContext end
local C={};U.NativeContext=C
local function discover(root)
 local state=root.b47NativeContext
 if not state or state.generation==root.subOptionNums then return end
 state.generation=root.subOptionNums
 local count=0
 for _,child in pairs(root.instanceMap or {})do
  count=count+1;if count>256 then break end
  C.adopt(child,state.player,root)
 end
end
function C.adopt(w,player,root)
 if not w then return false end
 root=root or w
 if w.b47NativeContext then w.b47NativeContext.player=player;w.b47NativeContext.root=root;return true end
 if not P.native(w,ISContextMenu)then return false end
 local state={player=player,root=root};w.b47NativeContext=state
 local render=w.render
 w.render=function(self,...)
  discover(state.root)
  local rect,border,static=self.drawRect,self.drawRectBorder,self.drawRectBorderStatic
  local canvas=P.canvas(self,state.player,'list',rect,border)
  local dy=self:getScrollHeight()>self:getScrollAreaHeight() and self.scrollIndicatorHgt or 0
  return P.around(self,render,{
   drawRect=function(target,x,y,width,height,a,r,g,b,...)
    if x==0 and y==dy-target:getYScroll() and width==target.width and height==target.height-dy*2 then return P.fill(canvas,x,y,width,height,'panel')end
    if x==0 and y==dy-target:getYScroll() and width==target.itemHgt-8 and height==target.height-dy*2 and P.equal(a,.25) and P.equal(r,.1) and P.neutral(r,g,b)then return P.fill(canvas,x,y,width,height,'raised',a,0)end
    if x==0 and width==target.width and height==target.itemHgt and P.neutral(r,g,b) and ((P.equal(a,.8)and P.equal(r,.5))or(P.equal(a,.1)and P.equal(r,.05)))then return P.fill(canvas,x,y,width,height,'hover',a,2)end
    return rect(target,x,y,width,height,a,r,g,b,...)
   end,
   drawRectBorderStatic=function(target,x,y,width,height,a,r,g,b,...)
    if x==0 and y==dy and width==target.width and height==target.height-dy*2 then
     -- Static drawing excludes the native content scroll offset.
     local fixed=P.canvas(target,state.player,'list',function(t,xx,yy,...)return rect(t,xx,yy-t:getYScroll(),...)end,static)
     return P.edge(fixed,x,y,width,height,'border')
    end
    return static(target,x,y,width,height,a,r,g,b,...)
   end,
   drawRectBorder=function(target,x,y,width,height,a,r,g,b,...)
    if x==0 and width==target.width and height==target.itemHgt and P.equal(a,.15)and P.equal(r,.9)and P.equal(g,.9)and b==1 then return P.edge(canvas,x,y,width,height,'border',a,2)end
    return border(target,x,y,width,height,a,r,g,b,...)
   end},...)
 end
 local show=w.showTooltip
 w.showTooltip=function(self,...)
  local result=P.pack(show(self,...))
  local tip=self.toolTip
  if tip then P.tooltip(tip,state.player,function()return self.toolTip==tip end)end
  return unpack(result,1,result.n)
 end
 return true
end
function C.fill(player,context,_,test)
 if test or not C.adopt(context,player)then return end
 context.b47NativeContext.generation=nil;discover(context)
end
Events.OnFillWorldObjectContextMenu.Add(C.fill)
Events.OnFillInventoryObjectContextMenu.Add(C.fill)
Events.OnFillInventoryContextMenuNoItems.Add(C.fill)
return C

-- Original host fixture for the public title-plus-status label contract.
-- No external implementation is loaded or copied.
local U=B47ANCEDUI
local oldMain,oldLabel=MainScreen,ISLabel
MainScreen={};ISLabel={onMouseDown=function()end}
local titleDraws,rects,textures,calls,tips={}, {},{},0,0
local live='release fixture';local fail,nativeMode=false,false
local nativeDraws=0
local function widget(screen,internal)
 local w={Type='ISLabel',parent=screen.bottomPanel,internal=internal,font=UIFont.Large,
  name='TUNING',width=240,height=48,x=0,y=0,joypadTexture={},joypadFocused=true}
 function w:getWidth()return self.width end
 function w:getHeight()return self.height end
 function w:setWidth(v)self.width=v end
 function w:setHeight(v)self.height=v end
 function w:setX(v)self.x=v end
 function w:setY(v)self.y=v end
 function w:isMouseOver()return self.hover end
 function w:drawText(...)
  if nativeMode then nativeDraws=nativeDraws+1;return end
  error('Title/status escaped presentation adapter')
 end
 function w:drawTextCentre(...)error('Unexpected centre draw')end
 function w:drawTextZoomed(text,x,y,zoom,r,g,b,a,font)
  titleDraws[#titleDraws+1]={text=text,x=x,y=y,zoom=zoom,r=r,g=g,b=b,a=a,font=font}
 end
 function w:drawRect(x,y,width,height,a,r,g,b)
  rects[#rects+1]={x=x,y=y,width=width,height=height}
 end
 function w:drawTextureScaled(tex,x,y,width,height,...)
  textures[#textures+1]={tex=tex,x=x,y=y,width=width,height=height}
 end
 function w:updateTooltip()tips=tips+1 end
 w.onMouseDown=function(self,x,y)return self.internal,x,y end
 w.prerender=function(self)
  calls=calls+1
  local fullHeight=self:getHeight();self:setHeight(11)
  self:drawRect(-6,0,self:getWidth()+12,11,.3,1,1,1)
  self:drawText(self.name,0,2,1,1,1,1,UIFont.Large)
  self:drawTextureScaled(self.joypadTexture,-36,-10,32,32,1,1,1,1)
  self:drawTextureScaled('unrelated texture',5,6,7,8,.5)
  self:updateTooltip()
  if fail then error('fixture renderer failure') end
  self:setHeight(fullHeight)
  self:drawText(live,0,8,.9,.6,.2,.8,UIFont.Small)
  return 'delegated'
 end
 return w
end
local s={bottomPanel={},b47MenuBackground={},getHeight=function()return 900 end}
local item=widget(s,'PZOPT_MENU');local other=widget(s,'OTHER_MOD')
other.y=100;other.b47NativeMenu=true -- an already adopted normal navigation row
local children={item,other};s.bottomPanel.getChildren=function()return children end
s.bottomPanel.setHeight=function(self,v)self.height=v end
local callback,renderer,draw,centre,rect=item.onMouseDown,item.prerender,item.drawText,item.drawTextCentre,item.drawRect
local texture=item.drawTextureScaled
assert(U.NativeMenus.apply(s)==1 and item.b47NativeMenu and item.b47MenuHasNote,'Optional custom status label was not adopted')
local wrapper=item.prerender
assert(U.NativeMenus.apply(s)==0 and item.prerender==wrapper)
U.MenuBackground.layout(s,400,0,240)
assert(item.b47MenuPrimaryHeight and item.b47MenuNoteHeight>0)
assert(other.y==item.height and math.abs(other.y+other.height-240)<.001,'Status lane did not reserve layout space')
assert(item:prerender()=='delegated' and calls==1 and #textures==2 and tips==1)
assert(#titleDraws==2 and #rects==1,'Only the themed focus underline must remain')
local title,note=titleDraws[1],titleDraws[2]
assert(title.zoom==item.b47MenuScale and title.zoom>1 and title.font==UIFont.Large)
assert(title.y>=0 and title.y+14*title.zoom<=item.b47MenuPrimaryHeight)
assert(note.text==live and note.y>=item.b47MenuPrimaryHeight and note.y+14*note.zoom<=item.height)
assert(note.r==.9 and note.g==.6 and note.a==.8,'Live status semantics lost')
assert(math.abs(title.x+getTextManager():MeasureStringX(title.font,title.text)*title.zoom/2-item.width/2)<.001)
local glyph,otherTexture=textures[1],textures[2]
assert(glyph.tex==item.joypadTexture and glyph.x>=0 and glyph.x+glyph.width<title.x,'Controller glyph must sit beside the centered title')
assert(math.abs(glyph.y+glyph.height/2-item.b47MenuPrimaryHeight/2)<.001,'Controller glyph must follow primary row height')
assert(otherTexture.x==5 and otherTexture.y==6 and otherTexture.width==7 and otherTexture.height==8,'Unrelated texture drawing changed')
assert(item.drawText==draw and item.drawTextCentre==centre and item.drawRect==rect and item.drawTextureScaled==texture)
assert(item.onMouseDown==callback and item:onMouseDown(7,9)=='PZOPT_MENU')
live='downloading fixture 73%';item.hover=true;titleDraws={};rects={};item:prerender()
assert(titleDraws[2].text==live and #rects==1 and rects[1].y<item.b47MenuPrimaryHeight,'Status stale or underline moved below note')
local height=item.height;fail=true
assert(not pcall(item.prerender,item),'Do not suppress renderer errors');fail=false
assert(item.height==height and item.drawText==draw and item.drawTextCentre==centre and item.drawRect==rect and item.drawTextureScaled==texture,'Exception leaked temporary methods/height')
nativeMode=true;s.inGame=true;assert(item:prerender()=='delegated' and nativeDraws==2)
s.inGame=false;s.b47MenuBackground=nil;assert(item:prerender()=='delegated' and nativeDraws==4)
s.b47MenuBackground={};nativeMode=false
for _,mode in ipairs({'unknown','no-background','ingame','wrong-parent'})do
 local scene={bottomPanel={},b47MenuBackground={}}
 local label=widget(scene,mode=='unknown' and 'SOME_CUSTOM_MOD' or 'PZOPT_MENU')
 if mode=='no-background' then scene.b47MenuBackground=nil end
 if mode=='ingame' then scene.inGame=true end
 if mode=='wrong-parent' then label.parent={} end
 scene.bottomPanel.getChildren=function()return {label}end
 local original=label.prerender
 assert(U.NativeMenus.apply(scene)==0 and label.prerender==original,mode)
end
-- Crowded rows shrink the auxiliary line without overflowing neighboring entries.
for i=3,40 do local w=widget(s,'FIXTURE_'..i);w.y=i*100;w.b47NativeMenu=true;children[i]=w end
U.MenuBackground.layout(s,400,0,240);titleDraws={};item:prerender()
assert(titleDraws[2].zoom<1 and titleDraws[2].y+14*titleDraws[2].zoom<=item.height+.001)
local smallGlyph=textures[#textures-1]
assert(smallGlyph.height<=item.b47MenuPrimaryHeight and smallGlyph.y>=0,'Controller glyph overflowed a crowded row')
local last=children[40];assert(last.y+last.height<=240.001)
MainScreen,ISLabel=oldMain,oldLabel
print('PASS OFFLINE optional status-label adapter: title style, live note lane, callback/tooltip ownership, glyph alignment/pass-through, idempotence, scope, crowded layout and exception restoration')

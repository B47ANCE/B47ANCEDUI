local API=require 'B47ANCEDUI/API'
local UI=API.forMod('MenuFixture')
local nativeRender,nativeUp=ISButton.render,ISButton.onMouseUp
local rendered=0
ISButton.render=function(self) rendered=rendered+1;assert(#self.title<=#(self.b47FullTitle or self.title)) end
local input=function() end;ISButton.onMouseUp=input
local target={};local click=function() end
local menu=UI.MenuButton:new(0,0,240,'Continue',target,click,'menu-intent')
assert(menu.onclick==click and menu.target==target and menu.onClickArgs[1]=='menu-intent' and menu.onMouseUp==input)
assert(ISButton.onMouseUp==input and ISButton.render~=menu.render,'Native class was patched')
assert(menu.b47AppearanceScope=='MenuFixture' and menu.b47Kind=='menuButton' and menu.font==UIFont.Large)
assert(menu.height>=56 and menu.height>UI.Theme.buttonSize('normal').height)
assert(menu.displayBackground==false and menu.backgroundColor.a==0 and menu.backgroundColorMouseOver.a==0 and menu.borderColor.a==0 and menu.titleLeft)
local rectangles={}
menu.drawRect=function(_,x,y,w,h,a,r,g,b) rectangles[#rectangles+1]={x=x,y=y,w=w,h=h,a=a,r=r,g=g,b=b} end
menu.drawRectBorder=function(_,x,y,w,h,a) assert(a==0,'Menu drew a visible button border') end
menu:prerender();menu:render();assert(rendered==1 and #rectangles==0,'Idle menu drew button chrome')
UI.Appearance.setAccent(0,'#6090C0')
menu.mouseOver=true;menu.isMouseOver=function() return true end;menu:render()
assert(#rectangles==1 and rectangles[1].h==2 and rectangles[1].w<menu.width)
assert(rectangles[1].r==96/255 and menu.textColor.r==96/255,'Menu did not use scoped live accent')
rectangles={};menu.mouseOver=false;menu.joypadFocused=true;menu:prerender();menu:render()
assert(#rectangles==1 and rectangles[1].h==2,'Controller focus did not use menu underline')
rectangles={};menu.enable=false;menu:render();assert(#rectangles==0,'Disabled item looked interactive')
menu.enable=true;menu:setWidth(36);menu:render()
assert(menu.title=='Continue' and menu.tooltip=='Continue' and rectangles[1].w<=30,'Menu truncation/tooltip lost original title')
local wrapper=menu.render;assert(UI.MenuButton.style(menu)==menu and menu.render==wrapper,'Menu style is not idempotent')
assert(not pcall(UI.MenuButton.style,UI.Button:new(0,0,80,32,'Ordinary')),'Ordinary button silently mixed with menu style')
local manager=getTextManager
getTextManager=function() return {getFontHeight=function() return 60 end} end
assert(UI.Theme.menuMetrics().height>=84,'Large menu font clipped')
getTextManager=manager
ISButton.render=nativeRender;ISButton.onMouseUp=nativeUp
print('PASS OFFLINE separate MenuButton: native callbacks/render delegation, no box, scoped accent, text-only focus, disabled state, truncation and font scaling')

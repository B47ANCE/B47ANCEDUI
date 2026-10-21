-- Native-shaped contract doubles. No engine input/rendering/settings proof.
local U=require 'B47ANCEDUI/API'
getFileReader=function()return nil end
getFileWriter=function()error('Options layout must never write preferences')end
getText=function(key)return key end
local font=14
getTextManager=function()return {getFontHeight=function()return font end,MeasureStringX=function(_,_,s)return #s*font*.5 end}end
Keyboard={KEY_RETURN=28,KEY_ESCAPE=1,KEY_UP=200,KEY_DOWN=208}
Joypad={AButton=0,BButton=1,XButton=2,YButton=3,LBumper=4,RBumper=5}
local W={}
function W:new(x,y,w,h,title,target,onclick)
 return setmetatable({Type=self.Type,x=x,y=y,width=w,height=h,title=title or '',target=target,onclick=onclick,children={},joypadButtonsY={},font=UIFont.Small,scrollY=0,scrollX=0}, {__index=self})
end
function W:initialise()end
function W:instantiate()end
function W:getX()return self.x end
function W:getY()return self.y end
function W:getWidth()return self.width end
function W:getHeight()return self.height end
function W:getAbsoluteX()return self.x+(self.parent and self.parent:getAbsoluteX() or 0)end
function W:setX(v)self.x=v end
function W:setY(v)self.y=v end
function W:setWidth(v)self.width=v end
function W:setHeight(v)self.height=v end
function W:setAnchorsTBLR()end
function W:setVisible(v)self.visible=v end
function W:isVisible()return self.visible~=false end
function W:setTooltip(v)self.tooltip=v end
function W:setTitle(v)self.title=v end
function W:setText(v)self.text=v end
function W:getInternalText()return self.text or '' end
function W:setMaxTextLength(v)self.limit=v end
function W:isFocused()return self.focused==true end
function W:unfocus()self.focused=false end
function W:addChild(w)self.children[#self.children+1]=w;w.parent=self end
function W:removeChild(w)for i,v in ipairs(self.children)do if w==v then table.remove(self.children,i);break end end;w.parent=nil end
function W:noBackground()end
function W:setScrollChildren(v)self.scrollChildren=v end
function W:addScrollBars()self.vscroll=W:new(0,0,14,100);self.vscroll.Type='ISScrollBar';self:addChild(self.vscroll)end
function W:setScrollHeight(v)self.extent=v end
function W:getScrollHeight()return self.extent or self.height end
function W:setScrollWidth(v)self.extentX=v end
function W:getScrollWidth()return self.extentX or self.width end
function W:setYScroll(v)self.scrollY=v end
function W:getYScroll()return self.scrollY end
function W:setXScroll(v)self.scrollX=v end
function W:getXScroll()return self.scrollX end
function W:insertNewLineOfButtons(w)self.joypadButtonsY[#self.joypadButtonsY+1]={w}end
function W:getJoypadFocus()local row=self.joypadButtonsY[self.joypadIndexY or 1];return row and row[self.joypadIndex or 1]end
function W:clearJoypadFocus()self.cleared=true end
function W:restoreJoypadFocus()self.restored=true end
function W:setStencilRect()self.stencil=true end
function W:clearStencilRect()self.stencil=false end
function W:ensureVisible()self.ensureCount=(self.ensureCount or 0)+1 end
function W:onJoypadDown(key)self.lastKey=key end
function W:drawRect()self.draws=(self.draws or 0)+1 end
function W:drawRectBorder()end
function W:drawText(text)self.lastText=text end
function W:drawTextCentre(text)self.lastCentre=text end
function W:prerender()end
function W:render()end
local function class(name)local c=setmetatable({Type=name},{__index=W});_G[name]=c;package.loaded['ISUI/'..name]=c;return c end
class('ISPanelJoypad');class('ISLabel');class('ISButton');class('ISTextEntryBox');class('ISComboBox');class('ISTabPanel')
function ISTextEntryBox:new(text,x,y,w,h)local v=W.new(self,x,y,w,h);v.text=text;return v end
class('ISScrollBar')
function ISScrollBar:new(parent,vertical)local v=W.new(self,0,0,14,14);v.vertical=vertical;return v end
function ISTabPanel:activateViewById(id)
 self.activation=(self.activation or 0)+1
 for _,v in ipairs(self.viewList)do if v.id==id then self.activeView=v end end
 self.nativeActivation=true
end
function ISTabPanel:addView(name,p)local v={id=name,name=name,view=p};self.viewList[#self.viewList+1]=v;self:addChild(p);return v end
function ISTabPanel:removeView(name)for i,v in ipairs(self.viewList)do if v.name==name then table.remove(self.viewList,i);break end end end
MainOptions={Type='MainOptions',onJoypadDownCurrentTab=W.onJoypadDown}
package.loaded['B47ANCEDUI/NativeSettings']=true;package.loaded['B47ANCEDUI/OptionsInterface']=true
local registered
package.loaded['B47ANCEDUI/OptionsLifecycle']={register=function(id,fn)assert(id=='options-layout');registered=fn end}
updateJoypadFocus=function(data)if data.focus then data.focus.joyfocus=data end end
-- Use the actual public factories with native-shaped widgets.
U.Button={new=function(_,...)return ISButton:new(...)end}
U.TextInput={new=function(_,...)return ISTextEntryBox:new(...)end}
local O=require 'B47ANCEDUI/OptionsLayout';local M=U.OptionsLayoutModel
assert(registered==O.attach)
for _,f in ipairs({14,24,32,42})do
 for width=500,2000,23 do for controlWidth=150,500,35 do
  local col=M.columns(width,f,controlWidth)
  if col.stacked then assert(col.summaryW==0 and col.tipW==0)end
 end end
end
local intermediate=M.columns(845,14,210);assert(not intermediate.stacked and intermediate.summaryW==0 and intermediate.tipW==0)
for _,size in ipairs({{1024,768},{1280,720},{1920,1080},{2560,1440},{3440,1440},{3840,2160},{5120,1440}})do
 for _,f in ipairs({14,24,32,42})do
  local c=M.chrome(size[1],size[2],f,{120,150,170})
  assert(c.x>=c.side and c.y>=c.header and c.x+c.w<=size[1] and c.y+c.h<=size[2]-c.footer)
  assert(c.h>0 and c.sidebarH>0)
 end
end
local function root()
 local r=W:new(0,0,1920,1080);r.Type='MainOptions';r.b47NativeSettingsOwner=r
 r.tabs=ISTabPanel:new(0,0,1920,900);r.tabs.tabHeight=28;r.tabs.viewList={};r:addChild(r.tabs)
 r.tabs.b47NativeSettingsOwner=r
 r.backButton=ISButton:new(0,0,120,32,'Back');r.saveButton=ISButton:new(0,0,120,32,'Apply');r.acceptButton=ISButton:new(0,0,120,32,'Accept')
 for _,b in ipairs({r.backButton,r.saveButton,r.acceptButton})do r:addChild(b)end
 r.gameOptions={options={},changed=true}
 r.doLayout=function(self)self.nativeLayouts=(self.nativeLayouts or 0)+1;return 'layout',nil,3 end
 r.onKeyRelease=function(self,k)self.nativeKey=k;self.accepted=k==Keyboard.KEY_RETURN end
 r.prerender=function(self)self.nativePres=(self.nativePres or 0)+1;self:drawTextCentre('UI_optionscreen_gameoption',0,0);if self.fail then error('native failure')end;return 'pre',nil,5 end
 return r
end
local function page(r,name)
 local p=ISPanelJoypad:new(0,0,1920,900);p.b47NativeSettingsOwner=r;p.onJoypadDown=MainOptions.onJoypadDownCurrentTab
 local v=r.tabs:addView(name,p);r.tabs.activeView=r.tabs.activeView or v
 p.prerender=function(self)self.stencil=true end;p.render=function(self)assert(self.stencil);self.stencil=false end
 return p,v
end
local r=root();local p,v=page(r,'UI_optionscreen_display')
local heading=ISLabel:new(50,10,300,24);heading.name='Screen and display';heading.font=UIFont.Medium;p:addChild(heading)
local line=W:new(0,0,1000,2);line.Type='HorizontalLine';p:addChild(line)
local lab=ISLabel:new(100,40,200,24);lab.name='Resolution';p:addChild(lab)
local control=ISComboBox:new(320,40,260,24);control.options={'1920 x 1080'};control.selected=1;control.tooltip='Match the resolution to your display.';p:addChild(control)
r.gameOptions.options={{name='resolution',control=control}}
p.joypadButtonsY={{control}};local originalRows=p.joypadButtonsY
local keys,kv=page(r,'UI_optionscreen_keybinding');local wide=ISButton:new(1500,80,300,28,'Bind');keys:addChild(wide);keys.joypadButtonsY={{wide}}
local foreign,fv=page(r,'Custom tools');local custom=W:new(1700,30,300,80);custom.Type='CustomWidget';foreign:addChild(custom)
local originalKeyX=wide.x;local nativeKeyDown=p.onJoypadDown;local options=r.gameOptions.options
assert(O.attach(r));local s=r.b47OptionsShell
assert(O.attach(r) and r.b47OptionsShell==s and r.tabs.tabHeight==0)
assert(#s.categories==3 and #s.index>=4 and not s.restoreDefaults)
assert(p.b47OptionsRows and #p.b47OptionsRows.cards==1 and not keys.b47OptionsRows and not foreign.b47OptionsRows)
assert(control.parent==p and control.selected==1 and p.joypadButtonsY==originalRows and r.gameOptions.options==options and p.onJoypadDown==nativeKeyDown)
assert(wide.x==originalKeyX and keys.hscroll and keys:getScrollWidth()>=wide.x+wide.width)
assert(custom.x==1700 and custom.parent==foreign and foreign.hscroll)
assert(p:getScrollHeight()>control.y+control.height)
p:prerender();assert(p.stencil and p.draws>0);p:render();assert(not p.stencil)
-- No cumulative offsets; native doLayout and nil-containing returns survive.
local x,y=control.x,control.y;local a,b,c=r:doLayout();assert(a=='layout' and b==nil and c==3 and r.nativeLayouts==1)
assert(control.x==x and control.y==y)
for _,size in ipairs({{1024,768},{1920,1080},{5120,1440}})do
 r.width=size[1];r.height=size[2];O.layout(r)
 for _,action in ipairs({r.backButton,r.saveButton,r.acceptButton})do assert(action.x>=0 and action.y+action.height<=r.height and action.x+action.width<=r.width)end
end
-- Search uses plain tokens, preserves native options, scrolls the existing page.
O.search(r,'resolution');assert(#s.results==1 and s.results[1].control==control)
s.search.focused=true;r:onKeyRelease(Keyboard.KEY_RETURN)
assert(r.tabs.activeView==v and r.tabs.nativeActivation and not r.accepted and not s.search:isFocused())
assert(control.selected==1 and r.gameOptions.changed and r.gameOptions.options==options)
O.search(r,'resolution');s.search.focused=true;s.search:onCommandEntered();r:onKeyRelease(Keyboard.KEY_RETURN);assert(not r.accepted)
O.search(r,'no such option');assert(#s.results==0)
s.search.focused=true;r:onKeyRelease(Keyboard.KEY_ESCAPE);assert(not s.search:isFocused() and r.nativeKey==nil)
r:onKeyRelease(Keyboard.KEY_RETURN);assert(r.accepted)
O.search(r,string.rep('a',500));assert(#s.results==0 and s.search.limit==128)
-- Hidden modal/native footer state is never forced on by layout.
r.modal={};r.backButton:setVisible(false);r.saveButton.enable=false;O.layout(r);r:prerender()
assert(not s.nav:isVisible() and not s.search:isVisible() and not r.backButton:isVisible() and r.saveButton.enable==false)
r.modal=nil;r:prerender();assert(s.nav:isVisible())
-- Sidebar wheel agrees with native pages; boundary focus leaves native rows alone.
s.nav.extent=2000;s.nav:onMouseWheel(1);assert(s.nav.scrollY==-40)
s.nav:onMouseWheel(-1);assert(s.nav.scrollY==0)
s.nav:prerender();assert(s.nav.stencil);s.nav:render();assert(not s.nav.stencil)
local data={focus=p};r.tabs.activeView=v;r.tabs:onJoypadDirUp_Descendant(p,data);assert(data.focus==s.nav and p.cleared)
s.nav:onJoypadDirRight(data);assert(data.focus==p and p.restored)
s.nav:onJoypadDown(Joypad.YButton,data);assert(p.lastKey==Joypad.YButton and originalRows==p.joypadButtonsY)
-- Specialized horizontal reveal keeps far-right controller focus reachable.
r.width=1024;r.height=768;O.layout(r)
keys.joypadIndexY=1;keys.joypadIndex=1;keys:ensureVisible();assert(keys.scrollX<0)
wide:setX(-200);O.layout(r);assert(wide.x>=0);local shifted=wide.x;O.layout(r);assert(wide.x==shifted)
-- Same-count tab replacement and late controls invalidate without a per-frame tree scan.
r.tabs:removeView('Custom tools');local later=page(r,'Later provider');r:prerender();assert(s.categories[3].b47View.name=='Later provider')
local late=ISButton:new(320,200,200,28,'Native action');p:addChild(late);r:prerender();assert(not s.dirty and #s.index>=4)
-- Root title is suppressed narrowly; original method restored on native failure.
local before=r.drawTextCentre;r.fail=true;assert(not pcall(r.prerender,r));assert(r.drawTextCentre==before);r.fail=false
local preA,preB,preC=r:prerender();assert(preA=='pre' and preB==nil and preC==5 and r.lastCentre==nil)
-- Verified native readonly content is retained within cards, not discarded.
local readonly=root();local audio=page(readonly,'UI_optionscreen_audio')
local micLabel=ISLabel:new(100,40,200,24);micLabel.name='Microphone level';audio:addChild(micLabel)
local meter=W:new(320,40,260,24);meter.Type='ISVolumeIndicator';audio:addChild(meter)
local volLabel=ISLabel:new(100,80,200,24);volLabel.name='Voice volume';audio:addChild(volLabel)
local volume=ISComboBox:new(320,80,260,24);audio:addChild(volume)
readonly.gameOptions.options={{name='voiceVolume',control=volume}}
local ui=page(readonly,'UI_optionscreen_UI')
local langLabel=ISLabel:new(100,40,200,24);langLabel.name='Language';ui:addChild(langLabel)
local lang=ISComboBox:new(320,40,260,24);ui:addChild(lang)
readonly.gameOptions.options[#readonly.gameOptions.options+1]={name='language',control=lang}
local pane=W:new(320,90,260,0);pane.Type='ISRichTextPanel';pane.paginate=function(self)self.height=120 end
MainOptions.translatorPane=pane;ui:addChild(pane)
assert(O.attach(readonly) and audio.b47OptionsRows and ui.b47OptionsRows)
pane:paginate();assert(ui:getScrollHeight()>pane.y+pane.height and pane.height==120)
assert(meter.parent==audio and pane.parent==ui and #readonly.gameOptions.options==2)
-- Unknown root/tab renderers and native actions remain out of scope.
local refused=root();refused.tabs.b47NativeSettingsOwner=nil;assert(not O.attach(refused))
-- A native tabs generation rebuild gets a single fresh owned shell.
local replacement=ISTabPanel:new(0,0,1920,900);replacement.viewList={};replacement.b47NativeSettingsOwner=r
r.tabs=replacement;r:addChild(replacement);local rebuilt=page(r,'UI_optionscreen_display')
assert(O.attach(r) and r.b47OptionsShell~=s and s.nav.parent==nil)
assert(O.attach(r) and #r.b47OptionsShell.categories==1)
-- Search results cannot cover the fixed footer at large fonts/720p.
font=42;readonly.width=1280;readonly.height=720;O.layout(readonly)
local rs=readonly.b47OptionsShell
rs.index={};for i=1,12 do rs.index[i]={text='Match '..i,category='Audio',view=v}end
O.search(readonly,'Match')
assert(#rs.results<8)
for _,button in ipairs(rs.resultButtons)do if button:isVisible()then assert(button.y+button.height<=readonly.height-rs.chrome.footer)end end
font=14
print('PASS OFFLINE Options cards/sidebar/search/native identities, 7 resolutions x 4 fonts, footer, native fallback scrolling, controller boundary, modal/Return guards and late discovery; native runtime NOT TESTED')

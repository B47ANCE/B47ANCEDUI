-- Instance-owned Options workspace. Native pages, values and input remain native.
require 'B47ANCEDUI/NativeSettings'
require 'B47ANCEDUI/OptionsInterface'
require 'ISUI/ISLabel'
require 'ISUI/ISScrollBar'
local Life=require 'B47ANCEDUI/OptionsLifecycle'
local M=require 'B47ANCEDUI/OptionsLayoutModel'
local U=B47ANCEDUI;if U.OptionsLayout then return U.OptionsLayout end
local O={};U.OptionsLayout=O
local R,T=U.Renderer,U.Theme
local function tr(k)return getText('UI_B47ANCEDUI_'..k)end
local function pack(...)return {n=select('#',...),...}end
local function place(w,x,y,width,height)U.Layout.place(w,x,y,width,height)end
local function label(w)return w.translation or w.name or w.title or ''end
local function children(page)
 local out={};for _,w in pairs(page.children or {})do if w.parent==page and w~=page.vscroll and w~=page.hscroll then out[#out+1]=w end end
 table.sort(out,function(a,b)return a:getY()==b:getY() and a:getX()<b:getX() or a:getY()<b:getY()end)
 return out
end
local specs={
 {'UI_optionscreen_display','OptionsDisplayHelp','display'},
 {'UI_optionscreen_UI','OptionsUIHelp','ui'},
 {'UI_optionscreen_audio','OptionsAudioHelp','audio'},
 {'UI_optionscreen_keybinding','OptionsKeysHelp','keys'},
 {'UI_optionscreen_accessibility','OptionsAccessHelp','access'},
 {'UI_optionscreen_controller','OptionsControllerHelp','controller'},
 {'UI_optionscreen_multiplayer','OptionsMPHelp','multi'},
}
local function spec(view)
 for _,s in ipairs(specs)do if view.name==getText(s[1])then return s end end
 return {nil,'OptionsOtherHelp','other'}
end
local safe={ISLabel=true,HorizontalLine=true,ISComboBox=true,ISTickBox=true,ISButton=true,
 ISTextEntryBox=true,ISVolumeControl=true,ISMegaVolumeControl=true,ISVolumeIndicator=true,ISPanel=true}
-- Require native GameOption identity as well as recognized native page/widget
-- contracts. Unknown/custom pages retain their native internal presentation.
local function snapshot(root,view)
 local p=view.view;local s=spec(view)
 if not p or p.b47OptionsRows or not s[1] or s[3]=='keys' or s[3]=='controller' then return end
 if p.b47NativeSettingsOwner~=root then return end
 local list=children(p);local controls={}
 for _,option in ipairs(root.gameOptions and root.gameOptions.options or {})do
  local w=option.control
  while w and w.parent and w.parent~=p do w=w.parent end
  if w and w.parent==p then controls[w]=true end
 end
 if not U._hasEntries(controls)then return end
 for _,w in ipairs(list)do
  if not safe[w.Type] and w~=MainOptions.translatorPane then return end
  if w.Type=='ISPanel' and not controls[w] then return end
 end
 local sections,rows={},{};local current
 local function section(title)
  current={title=title,rows={}};sections[#sections+1]=current
 end
 for _,w in ipairs(list)do
  if w.Type=='HorizontalLine' then
   -- Decorative lines remain children; suppress only this known decoration.
  elseif w.Type=='ISLabel' and w.font==UIFont.Medium and not controls[w] then
   section(label(w));current.heading=w
  else
   if not current then section(view.name)end
   local row=rows[w:getY()]
   if not row then row={y=w:getY(),items={},height=0};rows[w:getY()]=row;current.rows[#current.rows+1]=row end
   row.items[#row.items+1]={w=w,x=w:getX(),y=w:getY(),width=w:getWidth(),height=w:getHeight()}
   row.height=math.max(row.height,w:getHeight())
   if w.Type=='ISLabel' then row.label=w elseif controls[w] or w.Type=='ISButton' or w.Type=='ISVolumeIndicator' or w==MainOptions.translatorPane then row.control=w end
  end
 end
 -- A lone helper label must stay with its native row; ambiguous structures fail closed.
 for _,c in ipairs(sections)do for _,row in ipairs(c.rows)do if not row.control then return end end end
 local original={}
 for _,w in ipairs(list)do original[#original+1]={w=w,x=w:getX(),y=w:getY(),width=w:getWidth(),height=w:getHeight()}end
 p.b47OptionsRows={sections=sections,list=list,cards={},root=root,original=original}
 for _,w in ipairs(list)do
  if w==MainOptions.translatorPane and not w.b47OptionsPaginate then
   w.b47OptionsPaginate=true;local paginate=w.paginate
   w.paginate=function(self,...)
    local result=pack(paginate(self,...))
    if root.b47OptionsShell then O.layout(root)end
    return unpack(result,1,result.n)
   end
  end
 end
 for _,w in ipairs(list)do
  if w.Type=='HorizontalLine' and not w.b47OptionsDecoration then
   w.b47OptionsDecoration=true
   local render=w.render;w.render=function(self,...)if not p.b47OptionsRows or not p.b47OptionsRows.active then return render(self,...)end end
  elseif w.Type=='ISLabel' and not w.b47OptionsLabel then
   w.b47OptionsLabel=true
   local pre=w.prerender
   w.prerender=function(self,...)
    if not p.b47OptionsRows or not p.b47OptionsRows.active then return pre(self,...)end
    local raw=rawget(self,'drawText');local draw=self.drawText
    self.drawText=function(me,text,x,y,...)
     return draw(me,R.fit(text,me:getWidth(),me.font),x,y,...)
    end
    local result=pack(pcall(pre,self,...));self.drawText=raw
    if not result[1]then error(result[2])end;return unpack(result,2,result.n)
   end
  end
 end
 if p.b47OptionsCardDraw then return end
 p.b47OptionsCardDraw=true;local pre=p.prerender
 p.prerender=function(self,...)
  local result=pack(pre(self,...)) -- Native stencil and joystick scrolling first.
  local data=self.b47OptionsRows
  if data and data.active then
   for _,c in ipairs(data.cards)do
    R.roundedRect(self,0,c.y,self:getWidth()-16,c.h,T.colors.panel,6)
    R.roundedBorder(self,0,c.y,self:getWidth()-16,c.h,T.colors.border,6)
    if not c.heading then R.text(self,R.fit(c.title,c.titleW,UIFont.Medium),c.x,c.y+c.pad,T.colors.text,UIFont.Medium)end
    if c.summary then R.text(self,tr('OptionsSection'),c.x,c.y+c.pad+getTextManager():getFontHeight(UIFont.Medium)+8,T.colors.muted)end
    if c.tip then
     R.roundedRect(self,c.tipX,c.y+c.pad,c.tipW,c.h-c.pad*2,T.colors.raised,4)
     local yy=c.y+c.pad*2
     for _,line in ipairs(c.tip)do R.text(self,line,c.tipX+c.pad,yy,T.colors.muted);yy=yy+data.font+3 end
    end
   end
  end
  return unpack(result,1,result.n)
 end
end
local function wrapText(text,width,font,limit)
 local lines,line={},''
 text=string.gsub(tostring(text or ''),'<[^>]*>',' ')
 for word in string.gmatch(text,'%S+')do
  local nextLine=line=='' and word or line..' '..word
  if getTextManager():MeasureStringX(font,nextLine)>width and line~='' then
   lines[#lines+1]=R.fit(line,width,font);line=word
   if #lines>=limit-1 then break end
  else line=nextLine end
 end
 if line~=''then lines[#lines+1]=R.fit(line,width,font)end
 return lines
end
local function cards(root,p)
 local d=p.b47OptionsRows;if not d then return end
 local f=getTextManager():getFontHeight(UIFont.Small);d.font=f;d.cards={};d.active=true
 local y=0;local width=p:getWidth()-16
 for _,section in ipairs(d.sections)do
  local controlW=0
  for _,row in ipairs(section.rows)do for _,v in ipairs(row.items)do if v.w~=row.label then controlW=math.max(controlW,v.width)end end end
  controlW=math.min(controlW,width-math.max(14,f)*2)
  local col=M.columns(width,f,controlW);local pad=col.pad
  local card={title=section.title,heading=section.heading,y=y,pad=pad,x=pad,titleW=col.summaryW>0 and col.summaryW or width-pad*2,summary=col.summaryW>0}
  local rowY=y+pad
  if col.summaryW==0 then rowY=rowY+getTextManager():getFontHeight(UIFont.Medium)+pad end
  if section.heading then
   place(section.heading,pad,y+pad,card.titleW,section.heading:getHeight())
   section.heading.originalX=pad
  end
  local tip
  for _,row in ipairs(section.rows)do
   local height=row.control==MainOptions.translatorPane and row.control:getHeight() or row.height
   local h=math.max(height,f+14);local cx=col.controlX
   if col.stacked then
    cx=pad
    if row.label then place(row.label,pad,rowY,width-pad*2,math.max(f+4,row.label:getHeight()));rowY=rowY+math.max(f+6,row.label:getHeight())end
   elseif row.label then
    place(row.label,col.labelX,rowY,col.labelW,h)
   end
   if row.label and not row.label.tooltip then row.label:setTooltip(label(row.label))end
   for _,v in ipairs(row.items)do
    if v.w~=row.label then
     local cw=math.min(v.width,width-pad-cx)
     -- Compound slider panels retain their internal slider/value-label geometry.
     if v.w.Type=='ISPanel' and cw<v.width then
      -- The whole compound is wider than the viewport: keep native pagination
      -- and expose horizontal scrolling rather than crush its nested slider.
      cx=pad;cw=v.width
     end
     local vh=v.w==MainOptions.translatorPane and height or v.height
     place(v.w,cx,rowY+(h-vh)/2,cw,vh)
     tip=tip or (type(v.w.tooltip)=='string' and v.w.tooltip or nil)
    end
   end
   rowY=rowY+h+6
  end
  card.h=math.max(rowY-y+pad,card.summary and f*5+pad*2 or 1)
  if col.tipW>0 and tip then
   card.tipX=col.tipX;card.tipW=col.tipW
   card.tip=wrapText(tip,col.tipW-pad*2,UIFont.Small,math.max(1,math.floor((card.h-pad*4)/(f+3))))
  end
  d.cards[#d.cards+1]=card;y=y+card.h+pad
 end
 p:setScrollHeight(y)
 local extent=p:getWidth()
 for _,w in ipairs(d.list)do extent=math.max(extent,w:getX()+w:getWidth()+16)end
 if extent>p:getWidth() and not p.hscroll then
  p.hscroll=ISScrollBar:new(p,false);p.hscroll:initialise();p:addChild(p.hscroll)
 end
 if p.hscroll then p:setScrollWidth(extent)end
end
local function fallback(root,p)
 if p.Type~='ISPanelJoypad' or p.onJoypadDown~=MainOptions.onJoypadDownCurrentTab then return end
 -- Keep specialized/provider content at its native coordinates. A horizontal
 -- scrollbar and focus reveal make a wider native canvas reachable in the shell.
 if not p.hscroll then
  p.hscroll=ISScrollBar:new(p,false);p.hscroll:initialise();p:addChild(p.hscroll)
 end
 local list=children(p);local left=0
 for _,w in ipairs(list)do left=math.min(left,w:getX())end
 if left<0 then for _,w in ipairs(list)do w:setX(w:getX()-left+16)end end
 local extent=p:getWidth()
 for _,w in ipairs(list)do extent=math.max(extent,w:getX()+w:getWidth()+24)end
 p:setScrollWidth(extent)
 if not p.b47OptionsReveal and p.ensureVisible then
  p.b47OptionsReveal=true;local ensure=p.ensureVisible
  p.ensureVisible=function(self,...)
   local result=pack(ensure(self,...));local w=self:getJoypadFocus()
   if w and w.getAbsoluteX then
    local x=w:getAbsoluteX()-self:getAbsoluteX()-self:getXScroll()
    local scroll=self:getXScroll()
    if x+scroll<16 then scroll=16-x
    elseif x+scroll+w:getWidth()>self:getWidth()-24 then scroll=self:getWidth()-24-x-w:getWidth()end
    self:setXScroll(math.min(0,math.max(self:getWidth()-self:getScrollWidth(),scroll)))
   end
   return unpack(result,1,result.n)
  end
 end
end
local function blocked(root)
 local popup=ISComboBox.SharedPopup
 return root.modal~=nil or MainOptions.setKeybindDialog~=nil or (popup and popup:isVisible())
end
local function activate(root,view)
 if blocked(root)then return end
 local shell=root.b47OptionsShell;local data=shell and shell.nav.joyfocus
 local fromNavigation=data and data.focus==shell.nav
 root.tabs:activateViewById(view.id)
 if fromNavigation then
  shell.nav:clearJoypadFocus(data);shell.search:unfocus()
  data.focus=view.view;updateJoypadFocus(data);view.view:restoreJoypadFocus(data)
 end
end
function O.jump(root,entry)
 if not entry or blocked(root)then return end
 activate(root,entry.view)
 local p=entry.view.view
 if entry.control and p then
  local w=entry.control;while w.parent and w.parent~=p do w=w.parent end
  p:setYScroll(M.scroll(w:getY(),p:getScrollHeight(),p:getHeight()))
  if p.hscroll then p:setXScroll(math.min(0,math.max(p:getWidth()-p:getScrollWidth(),16-w:getX())))end
 end
 root.b47OptionsShell.search:unfocus();root.b47OptionsShell.search:setText('')
 O.search(root,'')
end
function O.search(root,query)
 local s=root.b47OptionsShell;if not s then return end
 local c=s.chrome
 local limit=c and math.max(1,math.min(8,math.floor((root:getHeight()-c.footer-c.header)/(c.button+2))))or 8
 s.results=M.matches(s.index,query,limit);s.resultIndex=1
 for i,b in ipairs(s.resultButtons)do
  local hit=s.results[i];b.b47Hit=hit;b.b47Selected=i==1;b:setVisible(hit~=nil and not blocked(root))
  if hit then b:setTitle(hit.category..'  >  '..hit.text)end
 end
end
local function button(parent,title,callback)
 local b=U.Button:new(0,0,100,32,title,parent,callback);b:initialise();b:instantiate();parent:addChild(b);return b
end
local function icon(w,kind,x,y)
 local c=T.colors.text
 if kind=='display' then R.border(w,x,y,23,16,c);R.rect(w,x+10,y+16,3,5,c);R.rect(w,x+5,y+21,13,2,c)
 elseif kind=='audio' then R.border(w,x+1,y+7,7,10,c);R.border(w,x+8,y+3,7,18,c);R.border(w,x+18,y+6,3,12,c)
 elseif kind=='keys' then R.border(w,x,y+3,24,17,c);for i=0,2 do R.rect(w,x+4+i*6,y+7,3,3,c)end;R.rect(w,x+5,y+14,14,2,c)
 elseif kind=='access' then R.roundedRect(w,x+9,y,7,7,c,3);R.rect(w,x+10,y+9,4,14,c);R.rect(w,x+2,y+10,20,3,c)
 else R.roundedBorder(w,x,y+1,23,22,c,4);R.rect(w,x+6,y+8,11,2,c);R.rect(w,x+6,y+14,11,2,c)end
end
local function navFocus(root,data)
 if blocked(root)then return end
 local s=root.b47OptionsShell;local p=root.tabs.activeView and root.tabs.activeView.view
 if not p or p.onJoypadDown~=MainOptions.onJoypadDownCurrentTab then return end
 s.returnPage=p;p:clearJoypadFocus(data);data.focus=s.nav;updateJoypadFocus(data);s.nav:restoreJoypadFocus(data)
end
local function pageFocus(root,data)
 local p=root.tabs.activeView and root.tabs.activeView.view
 if p then root.b47OptionsShell.search:unfocus();root.b47OptionsShell.nav:clearJoypadFocus(data);data.focus=p;updateJoypadFocus(data);p:restoreJoypadFocus(data)end
end
local function index(root)
 local s=root.b47OptionsShell;s.index={};s.nav.joypadButtonsY={};s.nav.allJoypadButtons={};s.nav.joypadButtons={}
 s.nav:insertNewLineOfButtons(s.search)
 for _,b in ipairs(s.resultButtons)do s.nav:insertNewLineOfButtons(b)end
 for i,view in ipairs(root.tabs.viewList)do
  local b=s.categories[i]
  if not b then
   b=button(s.nav,view.name,function(_,control)activate(root,control.b47View)end);s.categories[i]=b
   b.render=function(self)
    local on=root.tabs.activeView==self.b47View;local c=on and T.colors.selected or self.mouseOver and T.colors.hover or T.colors.window
    R.roundedRect(self,0,0,self:getWidth(),self:getHeight(),c,5)
    if on then R.roundedBorder(self,0,0,self:getWidth(),self:getHeight(),T.colors.accent,5)end
    local ss=spec(self.b47View);icon(self,ss[3],12,15)
    R.text(self,R.fit(self.b47View.name,self:getWidth()-72,UIFont.Medium),48,8,T.colors.text,UIFont.Medium)
    R.text(self,R.fit(tr(ss[2]),self:getWidth()-62),48,12+getTextManager():getFontHeight(UIFont.Medium),T.colors.muted)
    R.text(self,'>',self:getWidth()-20,14,T.colors.muted);R.focus(self)
   end
  end
  b.b47View=view;b:setTooltip(view.name..' - '..tr(spec(view)[2]));b:setVisible(true)
  s.nav:insertNewLineOfButtons(b)
  s.index[#s.index+1]={view=view,text=view.name,category=view.name}
  local p=view.view
  if p and p.b47OptionsRows and s.dirtyPages and s.dirtyPages[p]then
   for _,v in ipairs(p.b47OptionsRows.original)do if v.w.parent==p then place(v.w,v.x,v.y,v.width,v.height)end end
   p.b47OptionsRows.active=false;p.b47OptionsRows=nil
  end
  snapshot(root,view)
  if p and not p.b47OptionsWatch then
   p.b47OptionsWatch=true;local add=p.addChild
   p.addChild=function(self,child,...)
    local result=pack(add(self,child,...));local shell=root.b47OptionsShell
    if shell and child.Type~='ISScrollBar'then shell.dirtyPages=shell.dirtyPages or {};shell.dirtyPages[self]=true;shell.dirty=true end
    return unpack(result,1,result.n)
   end
  end
  local nativeControls={}
  for _,option in ipairs(root.gameOptions and root.gameOptions.options or {})do
   local w=option.control
   while w and w.parent and w.parent~=p do w=w.parent end
   if w and w.parent==p then nativeControls[w]=option.control end
  end
  for _,row in pairs(p and p.b47OptionsRows and p.b47OptionsRows.sections or {})do
   for _,r in ipairs(row.rows)do
    if r.label and r.control then
     s.index[#s.index+1]={view=view,text=label(r.label),category=view.name,control=r.control,tip=type(r.control.tooltip)=='string' and r.control.tooltip or ''}
     nativeControls[r.control]=nil
    end
   end
  end
  -- Native fallback pages are searchable by their actual option labels too.
  for w,control in pairs(nativeControls)do
   for _,l in ipairs(children(p))do
    if l.Type=='ISLabel' and math.abs(l:getY()-w:getY())<2 then
     s.index[#s.index+1]={view=view,text=label(l),category=view.name,control=control};break
    end
   end
  end
 end
 for i=#root.tabs.viewList+1,#s.categories do s.categories[i]:setVisible(false)end
 s.nav.joypadIndex=1;s.nav.joypadIndexY=1;s.nav.joypadButtons=s.nav.joypadButtonsY[1]
 s.viewCount=#root.tabs.viewList
 s.dirty=false;s.dirtyPages={}
end
function O.layout(root)
 local s=root.b47OptionsShell;if not s or s.tabs~=root.tabs then return end
 local f=getTextManager():getFontHeight(UIFont.Small);local widths={}
 for i,b in ipairs({root.backButton,root.saveButton,root.acceptButton})do widths[i]=math.min(root:getWidth()-f*2,math.max(1800,80*f),math.max(120,getTextManager():MeasureStringX(b.font or UIFont.Small,b.title or '')+64))end
 local c=M.chrome(root:getWidth(),root:getHeight(),f,widths);s.chrome=c
 local navHeight=c.sidebarH
 place(s.nav,c.g,c.sidebarY,c.side-c.g,navHeight)
 place(s.search,c.side+c.g, c.g,c.w,c.button) -- Search is root-owned, independent of sidebar scroll.
 local y=0
 for i,b in ipairs(s.categories)do place(b,0,y,s.nav:getWidth()-14,c.categoryH);y=y+c.categoryH+6 end
 s.nav:setScrollHeight(y);U.Layout.scrollbar(s.nav)
 place(root.tabs,c.x,c.y,c.w,c.h)
 for _,v in ipairs(root.tabs.viewList)do
  local p=v.view
  if p then
   if not p.b47OptionsRows and spec(v)[3]=='keys' then
    -- Native key labels are right-anchored but their buttons are not. Keep the
    -- two-column canvas together when the viewport narrows around it.
    for _,w in ipairs(children(p))do w:setAnchorsTBLR(true,false,true,false)end
   end
   place(p,0,0,c.w,c.h);U.Layout.scrollbar(p)
   if p.b47OptionsRows then cards(root,p)else fallback(root,p)end
  end
 end
 local x=c.right;local fy=root:getHeight()-c.footer+c.g
 for i=3,1,-1 do
  local b=({root.backButton,root.saveButton,root.acceptButton})[i]
  if x-widths[i]<c.g then x=c.right;fy=fy+c.button+c.g end
  x=x-widths[i];place(b,x,fy,widths[i],c.button);x=x-c.g
 end
 for i,b in ipairs(s.resultButtons)do place(b,c.x,c.header+(i-1)*(c.button+2),c.w,c.button)end
 O.search(root,s.search:getInternalText())
end
function O.attach(root)
 if not root.tabs or root.tabs.Type~='ISTabPanel' or root.b47NativeSettingsOwner~=root or root.tabs.b47NativeSettingsOwner~=root or not root.backButton or not root.saveButton or not root.acceptButton then return false end
 if root.b47OptionsShell and root.b47OptionsShell.tabs==root.tabs then return true end
 local previous=root.b47OptionsShell
 if previous then
  root:removeChild(previous.nav);root:removeChild(previous.search)
  for _,b in ipairs(previous.resultButtons)do root:removeChild(b)end
 end
 local s={tabs=root.tabs,categories={},resultButtons={},index={},results={}};root.b47OptionsShell=s
 local nav=ISPanelJoypad:new(0,0,200,400);nav:initialise();nav:instantiate();root:addChild(nav);nav:noBackground();nav:setScrollChildren(true);nav:addScrollBars();s.nav=nav
 local navPre,navRender=nav.prerender,nav.render
 nav.prerender=function(self,...)
  self:setStencilRect(0,0,self:getWidth(),self:getHeight())
  return navPre(self,...)
 end
 nav.render=function(self,...)
  local result=pack(pcall(navRender,self,...));self:clearStencilRect()
  if not result[1]then error(result[2])end;return unpack(result,2,result.n)
 end
 nav.onMouseWheel=function(self,delta)self:setYScroll(math.min(0,math.max(self:getHeight()-self:getScrollHeight(),self:getYScroll()-delta*40)));return true end
 local navEnsure=nav.ensureVisible
 nav.ensureVisible=function(self,...)
  local focused=self:getJoypadFocus()
  if focused and focused.parent==self then return navEnsure(self,...)end
 end
 local search=U.TextInput:new('',0,0,300,32);search:initialise();search:instantiate();root:addChild(search);s.search=search
 search:setTooltip(tr('OptionsSearchHelp'));search:setMaxTextLength(128)
 search.onTextChangeFunction=function()O.search(root,search:getInternalText())end
 search.onCommandEntered=function()s.consumeReturn=true;O.jump(root,s.results[s.resultIndex or 1])end
 local pre=search.prerender
 search.prerender=function(self,...)
  pre(self,...)
  if self:getInternalText()=='' and not self:isFocused()then R.text(self,R.fit(tr('OptionsSearch'),self:getWidth()-16),8,6,T.colors.muted)end
 end
 for i=1,8 do local b=button(root,'',function(_,control)O.jump(root,control.b47Hit)end);b:setVisible(false);s.resultButtons[i]=b end
 nav.onJoypadDirRight=function(_,data)pageFocus(root,data)end
 local nativeDown=nav.onJoypadDown
 nav.onJoypadDown=function(self,key,data)
  if key==Joypad.BButton or key==Joypad.XButton or key==Joypad.YButton or key==Joypad.LBumper or key==Joypad.RBumper then
   pageFocus(root,data);local p=root.tabs.activeView.view;return p:onJoypadDown(key,data)
  end
  return nativeDown(self,key,data)
 end
 local tabs=root.tabs;tabs.tabHeight=0;tabs.allowDraggingTabs=false;tabs.allowTornOffTabs=false
 for _,method in ipairs({'addView','removeView'})do
  if tabs[method]then
   local delegate=tabs[method]
   tabs[method]=function(self,...)local result=pack(delegate(self,...));s.dirty=true;return unpack(result,1,result.n)end
  end
 end
 tabs.render=function()end -- Suppress native tab/body chrome; children render separately.
 for _,key in ipairs({'onJoypadDirLeft_Descendant','onJoypadDirUp_Descendant'})do
  local delegate=tabs[key]
  tabs[key]=function(self,descendant,data,...)
   if descendant==self.activeView.view and not blocked(root)then navFocus(root,data);return end
   if delegate then return delegate(self,descendant,data,...)end
  end
 end
 index(root);O.layout(root)
 if not root.b47OptionsShellHooks then
  root.b47OptionsShellHooks=true
  local layout=root.doLayout
  root.doLayout=function(self,...)local result=pack(layout(self,...));O.layout(self);return unpack(result,1,result.n)end
  local key=root.onKeyRelease
  root.onKeyRelease=function(self,code,...)
   local ss=self.b47OptionsShell
   if ss and code==Keyboard.KEY_RETURN and ss.consumeReturn then ss.consumeReturn=false;return end
   if ss and ss.search:isFocused() and not blocked(self)then
    if code==Keyboard.KEY_RETURN then O.jump(self,ss.results[ss.resultIndex or 1]);return end
    if code==Keyboard.KEY_UP or code==Keyboard.KEY_DOWN then
     ss.resultIndex=math.max(1,math.min(#ss.results,(ss.resultIndex or 1)+(code==Keyboard.KEY_UP and -1 or 1)))
     for i,b in ipairs(ss.resultButtons)do b.b47Selected=i==ss.resultIndex end
     return
    end
    if code==Keyboard.KEY_ESCAPE then ss.search:setText('');ss.search:unfocus();O.search(self,'');return end
   end
   return key(self,code,...)
  end
  local preRoot=root.prerender
  root.prerender=function(self,...)
   local raw=rawget(self,'drawTextCentre');local draw=self.drawTextCentre
   self.drawTextCentre=function(w,text,x,y,...)
    if text==getText('UI_optionscreen_gameoption')then return end
    return draw(w,text,x,y,...)
   end
   local result=pack(pcall(preRoot,self,...));self.drawTextCentre=raw
   if not result[1]then error(result[2])end
   local ss=self.b47OptionsShell
   if ss and ss.tabs==self.tabs then
    if ss.dirty or ss.viewCount~=#self.tabs.viewList then index(self);O.layout(self)end
    local c=ss.chrome
    R.rect(self,0,0,self:getWidth(),c.header,T.colors.window)
    R.rect(self,0,self:getHeight()-c.footer,self:getWidth(),c.footer,T.colors.window)
    R.rect(self,0,c.header,self:getWidth(),1,T.colors.border)
    R.rect(self,c.side,c.header,1,self:getHeight()-c.header-c.footer,T.colors.border)
    R.rect(self,0,self:getHeight()-c.footer,self:getWidth(),1,T.colors.border)
    R.text(self,R.fit(tr('OptionsTitle'),c.side-c.g*2,UIFont.Large),c.g,c.g,T.colors.text,UIFont.Large)
    local active=self.tabs.activeView
    if active then
     R.text(self,R.fit(active.name,c.w,UIFont.Medium),c.x,c.header+c.g,T.colors.text,UIFont.Medium)
     R.text(self,R.fit(tr(spec(active)[2]),c.w),c.x,c.header+c.g+getTextManager():getFontHeight(UIFont.Medium)+4,T.colors.muted)
    end
    local visible=not blocked(self) and self.tabs:isVisible();ss.nav:setVisible(visible);ss.search:setVisible(visible)
    for i,b in ipairs(ss.resultButtons)do b:setVisible(visible and ss.results[i]~=nil)end
    if ss.search:getInternalText()~='' and #ss.results==0 then R.text(self,tr('OptionsNoResults'),c.x,c.header+c.g,T.colors.muted)end
   end
   return unpack(result,2,result.n)
  end
 end
 return true
end
Life.register('options-layout',O.attach)
return O

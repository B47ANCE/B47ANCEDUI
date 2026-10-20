-- Presentation adapter for the installed Build 42.21 MainScreen navigation.
-- Keep native labels, actions, state guards, layout and controller references.
require 'B47ANCEDUI/API'
require 'OptionScreens/MainScreen'
require 'ISUI/ISLabel'
local U=B47ANCEDUI
if U.NativeMenus then return U.NativeMenus end
local N={};U.NativeMenus=N
local T,R=U.Theme,U.Renderer
local nativeLabelPre=ISLabel.prerender
local options={latestSaveOption='LATESTSAVE',loadOption='LOAD',tutorialOption='TUTORIAL',
 survivalOption='SOLO',onlineOption='MULTIPLAYER',onlineCoopOption='COOP',
 returnOption='RETURN',scoreOption='SCOREBOARD',inviteOption='INVITE',optionsOption='OPTIONS',
 modsOption='MODS',workshopOption='WORKSHOP',creditOption='CREDITS',exitOption='EXIT',
 quitToDesktopOption='QUIT_TO_DESKTOP'}
local function blocked(screen,label)
 return label.disabled==true or label.enable==false or (screen.delay or 0)>0
  or screen.tutorialButton~=nil or screen.checkSavefileModal~=nil
  or (label.internal=='EXIT' or label.internal=='QUIT_TO_DESKTOP') and isQuitCooldown()
end
local function style(screen,label)
 label.b47NativeMenu=true;label.b47AppearanceScope='B47ANCEDUI';label.playerNum=0
 label.prerender=function(self,...)
  -- The native transition still drives hover audio/state, but no longer a box.
  if self.fade then self.fade:update() end
  local disabled=blocked(screen,self)
  local active=not disabled and (self.joypadFocused or self:isMouseOver())
  local c=U.Appearance.color(self,disabled and T.colors.disabled or active and T.colors.accent or T.colors.text)
  local name,translation=self.name,self.translation
  local r,g,b,a,textColor=self.r,self.g,self.b,self.a,self.textColor
  local full=translation or name or ''
  local zoom=self.b47MenuScale or 1
  local short=R.fit(full,self:getWidth()/zoom,self.font)
  if not self.tooltip or self.tooltip==self.b47NativeMenuFallbackTip then
   self.b47NativeMenuFallbackTip=short~=full and full or nil;self.tooltip=self.b47NativeMenuFallbackTip
  end
  self.name=short;self.translation=nil;self.textColor=nil
  self.r,self.g,self.b,self.a=c.r,c.g,c.b,c.a
  -- Native label owns tooltip and controller glyph drawing. Restore all fields
  -- even on error so callbacks/other code always see the original translated name.
  local oldDraw=rawget(self,'drawText')
  local oldCenter=self.center
  if self.b47MenuScale then self.center=false end
  if zoom~=1 and self.drawTextZoomed then
   self.drawText=function(owner,text,x,y,red,green,blue,alpha,font)
    owner:drawTextZoomed(text,x,(owner:getHeight()-getTextManager():getFontHeight(font)*zoom)/2,zoom,red,green,blue,alpha,font)
   end
  end
  local ok,result=pcall(nativeLabelPre,self,...)
  self.drawText=oldDraw
  self.center=oldCenter
  self.name,self.translation=name,translation
  self.r,self.g,self.b,self.a,self.textColor=r,g,b,a,textColor
  if not ok then error(result) end
  if active then R.menuUnderline(self,0,getTextManager():MeasureStringX(self.font,short)*zoom) end
  return result
 end
end
-- Optional interoperability with a public menu widget, not an external dependency.
-- Keep its renderer running once so its live version/update note stays authoritative.
local function styleStatusLabel(screen,label)
 local delegate=label.prerender
 label.b47NativeMenu=true;label.b47MenuHasNote=true
 label.b47AppearanceScope='B47ANCEDUI';label.playerNum=0
 label.prerender=function(self,...)
  if screen.inGame or not screen.b47MenuBackground then return delegate(self,...) end
  local width,height=self:getWidth(),self:getHeight()
  local fieldHeight=self.height
  local noteHeight=self.b47MenuNoteHeight or math.min(getTextManager():getFontHeight(UIFont.Small)+4,height/3)
  local primaryHeight=self.b47MenuPrimaryHeight or height-noteHeight
  local zoom=self.b47MenuScale or 1
  local full=self.translation or self.name or ''
  local glyphSize=math.min(32,primaryHeight)
  local glyphGap=math.min(UI_BORDER_SPACING or 4,primaryHeight/4)
  local glyphSpace=self.joypadFocused and self.joypadTexture and 2*(glyphSize+glyphGap) or 0
  local short=R.fit(full,math.max(1,width-glyphSpace)/zoom,self.font)
  local titleWidth=getTextManager():MeasureStringX(self.font,short)*zoom
  local titleX=(width-titleWidth)/2
  local disabled=blocked(screen,self)
  local active=not disabled and (self.joypadFocused or self:isMouseOver())
  local c=U.Appearance.color(self,disabled and T.colors.disabled or active and T.colors.accent or T.colors.text)
  if not self.tooltip or self.tooltip==self.b47NativeMenuFallbackTip then
   self.b47NativeMenuFallbackTip=short~=full and full or nil;self.tooltip=self.b47NativeMenuFallbackTip
  end
  local text,centre,rect,zoomed=self.drawText,self.drawTextCentre,self.drawRect,self.drawTextZoomed
  local rawText,rawCentre,rawRect=rawget(self,'drawText'),rawget(self,'drawTextCentre'),rawget(self,'drawRect')
  local texture,rawTexture=self.drawTextureScaled,rawget(self,'drawTextureScaled')
  local function draw(original,owner,value,x,y,red,green,blue,alpha,font)
   if font==self.font and (value==full or value==self.name) then
    return zoomed(owner,short,titleX,(primaryHeight-getTextManager():getFontHeight(font)*zoom)/2,zoom,c.r,c.g,c.b,c.a,font)
   elseif font==UIFont.Small then
    local noteZoom=math.min(1,noteHeight/(getTextManager():getFontHeight(font)+4))
    local fitted=R.fit(value,math.max(1,width-4)/noteZoom,font)
    local noteWidth=getTextManager():MeasureStringX(font,fitted)*noteZoom
    return zoomed(owner,fitted,(width-noteWidth)/2,primaryHeight+(noteHeight-getTextManager():getFontHeight(font)*noteZoom)/2,noteZoom,red,green,blue,alpha,font)
   end
   return original(owner,value,x,y,red,green,blue,alpha,font)
  end
  self.drawText=function(owner,...)return draw(text,owner,...)end
  self.drawTextCentre=function(owner,...)return draw(centre,owner,...)end
  self.drawRect=function(owner,x,y,w,h,...)
   if x<=0 and y==0 and w>=width and h>0 then return end -- native hover backing only
   return rect(owner,x,y,w,h,...)
  end
  self.drawTextureScaled=function(owner,tex,x,y,w,h,...)
   if self.joypadTexture and tex==self.joypadTexture then
    return texture(owner,tex,titleX-glyphGap-glyphSize,(primaryHeight-glyphSize)/2,glyphSize,glyphSize,...)
   end
   return texture(owner,tex,x,y,w,h,...)
  end
  local ok,result=pcall(delegate,self,...)
  self.drawText,self.drawTextCentre,self.drawRect=rawText,rawCentre,rawRect
  self.drawTextureScaled=rawTexture
  if self:getHeight()~=height then self:setHeight(height) end
  self.height=fieldHeight
  if not ok then error(result) end
  if active then R.rect(self,titleX,math.max(0,primaryHeight-6),titleWidth,math.min(2,primaryHeight),T.colors.accent) end
  return result
 end
end
function N.apply(screen)
 if not screen or not screen.bottomPanel then return 0 end
 local count=0
 for field,internal in pairs(options) do
  local label=screen[field]
  if label and not label.b47NativeMenu and not label.b47Styled
   and label.parent==screen.bottomPanel and label.Type=='ISLabel'
   and (label.internal==internal or field=='survivalOption' and label.internal=='APOCALYPSE')
   and label.font==T.fonts.menu
   and label.onMouseDown==MainScreen.onMenuItemMouseDownMainMenu
   and label.prerender==MainScreen.prerenderBottomPanelLabel and label.fade then
   style(screen,label);count=count+1
  end
 end
 -- Main-menu mods commonly append native labels with their own callbacks.
 -- Known native renderers are adopted directly. The public PZOPT_MENU widget has
 -- an audited title-plus-status contract; preserve its custom renderer through a scoped wrapper.
 if not screen.inGame and screen.b47MenuBackground and screen.bottomPanel.getChildren then
  for _,label in pairs(screen.bottomPanel:getChildren()) do
   if label.Type=='ISLabel' and not label.b47NativeMenu and not label.b47Styled
    and label.parent==screen.bottomPanel and label.onMouseDown and label.onMouseDown~=ISLabel.onMouseDown then
    if label.internal=='PZOPT_MENU' and label.font==T.fonts.menu and type(label.prerender)=='function' then
     styleStatusLabel(screen,label);count=count+1
    elseif label.prerender==nativeLabelPre or label.prerender==MainScreen.prerenderBottomPanelLabel then
     style(screen,label);count=count+1
    end
   end
  end
 end
 return count
end
local function applyCurrent() N.apply(MainScreen.instance) end
-- Requiring MainScreen above registers native construction first. Both menu
-- variants are built before these callbacks; repeated dispatch is idempotent.
Events.OnMainMenuEnter.Add(applyCurrent)
Events.OnGameStart.Add(applyCurrent)
Events.OnResetLua.Add(applyCurrent)
applyCurrent()
return N

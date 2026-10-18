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
  self.fade:update()
  local disabled=blocked(screen,self)
  local active=not disabled and (self.joypadFocused or self:isMouseOver())
  local c=U.Appearance.color(self,disabled and T.colors.disabled or active and T.colors.accent or T.colors.text)
  local name,translation=self.name,self.translation
  local r,g,b,a,textColor=self.r,self.g,self.b,self.a,self.textColor
  local full=translation or name or ''
  local short=R.fit(full,self:getWidth(),self.font)
  if not self.tooltip or self.tooltip==self.b47NativeMenuFallbackTip then
   self.b47NativeMenuFallbackTip=short~=full and full or nil;self.tooltip=self.b47NativeMenuFallbackTip
  end
  self.name=short;self.translation=nil;self.textColor=nil
  self.r,self.g,self.b,self.a=c.r,c.g,c.b,c.a
  -- Native label owns tooltip and controller glyph drawing. Restore all fields
  -- even on error so callbacks/other code always see the original translated name.
  local ok,result=pcall(nativeLabelPre,self,...)
  self.name,self.translation=name,translation
  self.r,self.g,self.b,self.a,self.textColor=r,g,b,a,textColor
  if not ok then error(result) end
  if active then R.menuUnderline(self,0,getTextManager():MeasureStringX(self.font,short)) end
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

-- Event/lifecycle/identity contract fixtures, not native engine execution.
local API=require 'B47ANCEDUI/API'
local previousLabel,previousMain,previousEvents,previousCooldown=ISLabel,MainScreen,Events,isQuitCooldown
local previousReader,previousWriter=getFileReader,getFileWriter
getFileReader=function() return nil end
getFileWriter=function() error('Menu drawing must not write settings') end
local function event()
 local callbacks={}
 return {callbacks=callbacks,Add=function(fn) callbacks[#callbacks+1]=fn end,
  fire=function() for _,fn in ipairs(callbacks) do fn() end end}
end
Events={OnMainMenuEnter=event(),OnGameStart=event(),OnResetLua=event()}
local rectangles,nativeCalls,glyphs,tooltips,transitions={},0,0,0,0
local nativeError=false
ISLabel={prerender=function(self)
 nativeCalls=nativeCalls+1
 assert(self.font==UIFont.Large and self.name and self.translation==nil)
 assert(self.r==API.Theme.colors.text.r or self.r==API.Theme.colors.disabled.r or self.r==32/255)
 if self.joypadFocused then glyphs=glyphs+1 end
 if self.tooltip then tooltips=tooltips+1 end
 if nativeError then error('native label failure') end
 return 'native-result'
end}
package.loaded['ISUI/ISLabel']=ISLabel
local clicked={}
MainScreen={onMenuItemMouseDownMainMenu=function(item,x,y)
 clicked[#clicked+1]={item=item,x=x,y=y,internal=item.internal};return 'native-action'
end,prerenderBottomPanelLabel=function() error('Old grey hover box rendered') end}
package.loaded['OptionScreens/MainScreen']=MainScreen
local cooldown=false;isQuitCooldown=function() return cooldown end
local function label(screen,internal)
 local w={parent=screen.bottomPanel,Type='ISLabel',internal=internal,font=UIFont.Large,
  name='Localized '..internal,x=12,y=24,width=280,height=42,r=1,g=1,b=1,a=.9,
  onMouseDown=MainScreen.onMenuItemMouseDownMainMenu,prerender=MainScreen.prerenderBottomPanelLabel,
  fade={update=function() transitions=transitions+1 end}}
 function w:getWidth() return self.width end
 function w:getHeight() return self.height end
 function w:isMouseOver() return self.mouseOver==true end
 function w:drawRect(x,y,width,height,a,r,g,b)
  assert(x>=0 and y>=0 and width<=self.width and height==2,'Non-text menu chrome')
  rectangles[#rectangles+1]={x=x,width=width,a=a,r=r,g=g,b=b}
 end
 return w
end
local fields={latestSaveOption='LATESTSAVE',loadOption='LOAD',survivalOption='SOLO',tutorialOption='TUTORIAL',
 onlineOption='MULTIPLAYER',onlineCoopOption='COOP',optionsOption='OPTIONS',modsOption='MODS',
 workshopOption='WORKSHOP',creditOption='CREDITS',exitOption='EXIT'}
local function screen(spec)
 local s={bottomPanel={},delay=0}
 for name,internal in pairs(spec) do s[name]=label(s,internal) end
 return s
end
local main=screen(fields);MainScreen.instance=main
main.latestSaveOption.visible=false
local original=main.optionsOption
local callback=original.onMouseDown
local nativePre=ISLabel.prerender
local N=require 'B47ANCEDUI/NativeMenus'
assert(main.optionsOption==original and original.onMouseDown==callback and original.b47NativeMenu)
assert(original.x==12 and original.y==24 and original.width==280 and original.height==42)
assert(main.latestSaveOption.visible==false,'Hidden Continue was made visible')
assert(ISLabel.prerender==nativePre and MainScreen.prerenderBottomPanelLabel~=original.prerender)
assert(original.b47AppearanceScope=='B47ANCEDUI' and original.playerNum==0)
assert(original:prerender()=='native-result' and #rectangles==0 and nativeCalls==1 and transitions==1)
assert(original.name=='Localized OPTIONS' and original.r==1 and original.a==.9)
API.Appearance.setAccent(0,'#204060','B47ANCEDUI')
original.mouseOver=true;original:prerender()
assert(#rectangles==1 and rectangles[1].r==32/255 and rectangles[1].g==64/255)
assert(rectangles[1].width<original.width,'Hover mark covered the whole row')
rectangles={};original.mouseOver=false;original.joypadFocused=true;original:prerender()
assert(#rectangles==1 and glyphs==1,'Native controller glyph or focus underline lost')
local rows={{main.survivalOption},{original},{main.exitOption}};main.joypadButtonsY=rows;main.defaultJoypadOption=original
assert(N.apply(main)==0 and main.joypadButtonsY==rows and main.defaultJoypadOption==original)
assert(original:onMouseDown(3,4)=='native-action' and clicked[1].item==original and clicked[1].internal=='OPTIONS')
local wrapper=original.prerender
Events.OnMainMenuEnter.fire();assert(original.prerender==wrapper)
package.loaded['B47ANCEDUI/NativeMenus']=nil
assert(require('B47ANCEDUI/NativeMenus')==N and #Events.OnMainMenuEnter.callbacks==1 and #Events.OnGameStart.callbacks==1)
Events.OnResetLua.fire();assert(original.prerender==wrapper and #Events.OnResetLua.callbacks==1)
-- A new Esc screen is created by the native callback before the adapter callback.
local pauseSpec={returnOption='RETURN',scoreOption='SCOREBOARD',inviteOption='INVITE',optionsOption='OPTIONS',exitOption='EXIT',quitToDesktopOption='QUIT_TO_DESKTOP'}
local pause
table.insert(Events.OnGameStart.callbacks,1,function() pause=screen(pauseSpec);pause.inGame=true;MainScreen.instance=pause end)
Events.OnGameStart.fire()
for field in pairs(pauseSpec) do assert(pause[field].b47NativeMenu,field) end
local quit=pause.quitToDesktopOption;quit.mouseOver=true;cooldown=true;rectangles={};quit:prerender()
assert(#rectangles==0,'Quit cooldown looked active')
cooldown=false;quit:prerender();assert(#rectangles==1)
for _,blocker in ipairs({'delay','tutorialButton','checkSavefileModal'}) do
 pause[blocker]=blocker=='delay' and 10 or {};rectangles={};quit:prerender();assert(#rectangles==0,blocker)
 pause[blocker]=blocker=='delay' and 0 or nil
end
quit.disabled=true;rectangles={};quit:prerender();assert(#rectangles==0);quit.disabled=nil
quit.enable=false;quit:prerender();assert(#rectangles==0);quit.enable=nil
-- Dynamic width and translated text are fitted without mutating native identity.
quit.translation='Localized translated quit label';quit.width=24;quit:prerender()
assert(quit.translation=='Localized translated quit label' and quit.name=='Localized QUIT_TO_DESKTOP')
assert(quit.tooltip==quit.translation and rectangles[1].width<=quit.width and tooltips>0)
quit.width=900;quit:prerender();assert(quit.tooltip==nil,'Fallback tooltip not cleared after resize')
quit.tooltip='Native explanation';quit.width=24;quit:prerender();assert(quit.tooltip=='Native explanation')
nativeError=true;local ok=pcall(quit.prerender,quit);nativeError=false
assert(not ok and quit.translation=='Localized translated quit label' and quit.r==1 and quit.a==.9,'Error leaked temporary drawing fields')
-- Reject unfamiliar ownership, callback, renderer, type, font and command.
for _,change in ipairs({function(w) w.parent={} end,function(w) w.onMouseDown=function() end end,
 function(w) w.prerender=function() end end,function(w) w.Type='ForeignLabel' end,
 function(w) w.font=UIFont.Small end,function(w) w.internal='FOREIGN' end,
 function(w) w.b47Styled=true end,function(w) w.fade=nil end}) do
 local s=screen({optionsOption='OPTIONS'});change(s.optionsOption);assert(N.apply(s)==0)
end
assert(N.apply(nil)==0 and N.apply({})==0)
local demo=screen({survivalOption='APOCALYPSE',tutorialOption='TUTORIAL',exitOption='EXIT'})
assert(N.apply(demo)==3,'Native demo actions not retained')
local fresh=screen(fields);MainScreen.instance=fresh;Events.OnMainMenuEnter.fire()
assert(fresh.optionsOption.b47NativeMenu and fresh.optionsOption~=original)
getFileReader,getFileWriter=previousReader,previousWriter
ISLabel,MainScreen,Events,isQuitCooldown=previousLabel,previousMain,previousEvents,previousCooldown
print('PASS OFFLINE native menu adapter: main/Esc/demo, lifecycle/idempotence, unchanged identities/actions/layout/visibility/controller rows, scoped text focus, cooldown/modal guards, translation/resize/tooltips, error restoration and foreign-style refusal')

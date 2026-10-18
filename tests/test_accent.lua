local API=require 'B47ANCEDUI/API'
local records={};local writes,reads,closed=0,0,0
getFileReader=function(name,create)
 assert(create==false);if not records[name] then return end
 local lines={};for line in records[name]:gmatch('[^\n]+') do lines[#lines+1]=line end;local i=0
 return {readLine=function() i=i+1;reads=reads+1;return lines[i] end,close=function() closed=closed+1 end}
end
getFileWriter=function(name) return {write=function(_,text) records[name]=text;writes=writes+1 end,close=function() end} end
local a=API.forMod('AccentA');local b=API.forMod('AccentB')
assert(a.Appearance.getAccent(0)=='#B0B0B0' and API.Theme.colors.accent.r==176/255)
assert(a.Appearance.setAccent(0,'12aBef')=='#12ABEF')
assert(a.Appearance.getAccent(1)=='#B0B0B0' and b.Appearance.getAccent(0)=='#B0B0B0')
for _,bad in ipairs({'#abc','red','#11223344',' 112233','11223G','../abc','nan',123}) do
 assert(a.Appearance.setAccent(0,bad)==nil and a.Appearance.getAccent(0)=='#12ABEF')
end
assert(writes==0,'Live colour preview writes per change')
a.Appearance.set(0,43);assert(a.Appearance.save(0))
assert(records['B47ANCEDUI/appearance/AccentA.0.txt']=='opacity=43\naccent=#12ABEF\n')
local widget={b47AppearanceScope='AccentA',playerNum=0,drawRect=function(self,x,y,w,h,alpha,r,g,blue) self.last={a=alpha,r=r,g=g,b=blue} end}
API.Renderer.rect(widget,0,0,2,2,API.Theme.colors.accent)
assert(widget.last.r==18/255 and widget.last.g==171/255 and widget.last.b==239/255 and widget.last.a==1)
widget.playerNum=1;API.Renderer.rect(widget,0,0,2,2,API.Theme.colors.accent);assert(widget.last.r==176/255)
widget.playerNum=0
local semantic=API.Theme.colors.needed
assert(API.Appearance.color(widget,semantic)==semantic and API.Appearance.color(widget,API.Theme.colors.text)==API.Theme.colors.text)
assert(API.Theme.colors.accent.r==176/255,'Shared theme was mutated')
local child={parent=widget};assert(API.Appearance.color(child,API.Theme.colors.accent).r==18/255)
a.Appearance.setAccent(0,'#FF0000');assert(API.Appearance.color(child,API.Theme.colors.accent).r==1,'Live preview cache stale')
assert(a.Appearance.save(0))
-- Minimal native-control doubles exercise editor synchronization, not native input.
getText=function(key) return ({UI_B47ANCEDUI_Red='Red',UI_B47ANCEDUI_Green='Green',UI_B47ANCEDUI_Blue='Blue'})[key] or key end
for _,class in ipairs({ISPanelJoypad,ISSliderPanel,ISTextEntryBox}) do
 class.initialise=function() end;class.instantiate=function() end
end
ISPanelJoypad.addChild=function(self,c) c.parent=self;self.children[#self.children+1]=c end
ISPanelJoypad.addToUIManager=function() end
ISPanelJoypad.insertNewLineOfButtons=function(self,...) self.joypadButtonsY[#self.joypadButtonsY+1]={...} end
ISButton.initialise=function() end;ISButton.instantiate=function() end
function ISTextEntryBox:new(text,x,y,w,h) local o=ISPanelJoypad:new(x,y,w,h);setmetatable(o,{__index=self});o.title=text;return o end
function ISTextEntryBox:setText(text) self.title=text end
function ISTextEntryBox:getText() return self.title end
function ISSliderPanel:new(x,y,w,h,target,callback) local o=ISPanelJoypad:new(x,y,w,h);setmetatable(o,{__index=self});o.target=target;o.onValueChange=callback;return o end
function ISSliderPanel:setValues(min,max,step,shift) self.minValue=min;self.maxValue=max;self.stepValue=step;self.shiftValue=shift end
function ISSliderPanel:setCurrentValue(value,ignore) self.currentValue=value;if not ignore then self.onValueChange(self.target,value,self) end end
function ISSliderPanel:getCurrentValue() return self.currentValue end
ISSliderPanel.onMouseUp=function() end;ISSliderPanel.onMouseUpOutside=function() end
local focus;setJoypadFocus=function(_,w) focus=w end
local owner={playerNum=0,b47AppearanceScope='AccentA'}
local panel=API.AppearanceEditor.open(owner)
assert(panel==API.AppearanceEditor.open(owner) and panel.hexEntry:getText()=='#FF0000' and #panel.joypadButtonsY==6)
assert(panel.rgbSliders[1].minValue==0 and panel.rgbSliders[1].maxValue==255 and panel.rgbSliders[1].stepValue==1)
local oldWrites=writes;panel.rgbSliders[2]:setCurrentValue(128)
assert(a.Appearance.getAccent(0)=='#FF8000' and panel.hexEntry:getText()=='#FF8000' and writes==oldWrites)
panel.hexEntry:setText('#0022ff');panel.hexEntry.onTextChangeFunction()
assert(a.Appearance.getAccent(0)=='#0022FF' and panel.rgbSliders[3]:getCurrentValue()==255)
panel.hexEntry:setText('#bad');panel.hexEntry.onTextChangeFunction()
assert(panel.invalidHex and a.Appearance.getAccent(0)=='#0022FF')
panel.rgbSliders[1]:onMouseUp();assert(writes==oldWrites+1)
panel.rgbSliders[2]:onMouseUpOutside();assert(writes==oldWrites+1,'Unchanged outside release wrote again')
panel.reset.onclick();assert(a.Appearance.get(0)==82 and a.Appearance.getAccent(0)=='#B0B0B0' and panel.hexEntry:getText()=='#B0B0B0')
getFileWriter=function() error('blocked') end;panel.close();assert(not panel.closed and panel.saveFailed,'Save failure silently closed editor')
getFileWriter=function(name) return {write=function(_,text) records[name]=text end,close=function() end} end
panel.close();assert(panel.closed and focus==owner)
local manager=getTextManager
getPlayerScreenWidth=function() return 320 end;getPlayerScreenHeight=function() return 540 end
getPlayerScreenLeft=function() return 0 end;getPlayerScreenTop=function() return 0 end
for _,font in ipairs({14,24,32,42}) do
 getTextManager=function() return {getFontHeight=function() return font end,MeasureStringX=function(_,_,text) return #text*font*.5 end} end
 local scaled=API.AppearanceEditor.open({playerNum=1,b47AppearanceScope='AccentScale'..font})
 assert(scaled.width==300 and scaled.height<=520,'Large-font editor exceeds test viewport')
 assert(scaled.rgbSliders[3].y+scaled.rgbSliders[3].height<=scaled.done.y)
 assert(scaled.rgbSliders[1].width>=30 and scaled.hexEntry.width>0)
 scaled.drawRect=function() end
 scaled.drawText=function(self,text,x,y)
  assert(x>=0 and x+getTextManager():MeasureStringX(nil,text)<=self.width,'Editor label exceeds width')
  assert(y>=0 and y+font<=self.height,'Editor label exceeds height')
 end
 scaled:prerender()
 scaled.close()
end
getTextManager=manager
getFileWriter=function() error('still blocked') end
local retry=API.AppearanceEditor.open(owner);retry.close();assert(not retry.closed and retry.saveFailed)
retry.close();assert(retry.closed,'Persistent save failure trapped the player in the editor')
-- Reload only disposable records. Legacy import never imports an accent or writes.
records['B47ANCEDUI/appearance/AccentReload.0.txt']='opacity=61\naccent=#a1b2c3\n'
records['B47ANCEDUI/appearance/AccentPartial.0.txt']='opacity=66\naccent=broken\n'
records['B47ANCEDUI/appearance/AccentOther.0.txt']='opacity=nan\naccent=#778899\n'
records['LegacyAccent0.txt']='opacity=72\naccent=#FF0000\n'
package.loaded['B47ANCEDUI/Appearance']=nil
local Reload=require 'B47ANCEDUI/Appearance'
local re=Reload.context('AccentReload');assert(re.get(0)==61 and re.getAccent(0)=='#A1B2C3')
local partial=Reload.context('AccentPartial');assert(partial.get(0)==66 and partial.getAccent(0)=='#B0B0B0')
local other=Reload.context('AccentOther');assert(other.get(0)==82 and other.getAccent(0)=='#778899')
local old=Reload.context('AccentOld',{legacyAppearancePrefix='LegacyAccent'});assert(old.get(0)==72 and old.getAccent(0)=='#B0B0B0')
local bounded=0
getFileReader=function() return {readLine=function() bounded=bounded+1;return 'unknown=data' end,close=function() end} end
assert(Reload.context('Endless').get(0)==82 and bounded==8)
assert(closed>0 and records['LegacyAccent0.txt']=='opacity=72\naccent=#FF0000\n')
print('PASS OFFLINE grey default, hex validation, scoped live rendering, semantic colour retention, RGB/hex editor sync, save failure, bounded migration and reload')

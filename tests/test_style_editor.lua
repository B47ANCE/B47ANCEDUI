-- Fixture-only table iterator; the runtime global remains unavailable.
local function next(t)for key,value in pairs(t)do return key,value end end
-- Reuses the layout editor native-shaped doubles, plus the new owned inspector.
local files,writes={},0
getFileReader=function(path,create)
 assert(not create);local text=files[path];if not text then return end
 local lines={};for l in text:gmatch('([^\n]*)\n')do lines[#lines+1]=l end;local i=0
 return {readLine=function()i=i+1;return lines[i]end,close=function()end}
end
local function writer(path)
 assert(path:match('^B47ANCEDUI/style%-presets%.0%.[ab]%.txt$'))
 return {write=function(_,text)files[path]=text;writes=writes+1 end,close=function()end}
end
getFileWriter=writer
for _,class in ipairs({ISPanel,ISPanelJoypad})do
 class.noBackground=function(self)self.background=false end
 class.setScrollChildren=function(self,v)self.scrollChildren=v end
 class.addScrollBars=function(self)self.scrollbars=true end
 class.getScrollHeight=function(self)return self.scrollHeight or self.height end
 class.setStencilRect=function(self)self.stencil=true end;class.clearStencilRect=function(self)self.stencil=false end
 class.setWantKeyEvents=function(self,v)self.wantKeyEvents=v end
 class.addToUIManager=function(self)self.added=true end
 class.getYScroll=function(self)return self.scrollY or 0 end
 class.setYScroll=function(self,v)self.scrollY=v end
end
ISTextEntryBox.setMaxTextLength=function(self,n)self.maxLength=n end
ISComboBox.clear=function(self)self.options={};self.selected=1 end
local U=B47ANCEDUI;local P=U.StylePresets;U.forMod('StyleConsumer')
local callbacks={};Events.OnGameStart.Add=function(fn)callbacks[#callbacks+1]=fn end
local E=require 'B47ANCEDUI/StyleEditor'
local owner=ISPanelJoypad:new(0,0,1920,1080);owner.joypadButtonsY={}
local focus={focus=owner};JoypadState={getMainMenuJoypad=function()return focus end,players={{focus={}}}}
local playerFocusCalls=0;setJoypadFocus=function()playerFocusCalls=playerFocusCalls+1 end
UIManager.isModalVisible=function()return false end
local vw,vh,fh=1920,1080,14
getPlayerScreenWidth=function()return vw end;getPlayerScreenHeight=function()return vh end
getPlayerScreenLeft=function()return 100 end;getPlayerScreenTop=function()return 50 end
getTextManager=function()return {getFontHeight=function()return fh end,MeasureStringX=function(_,_,s)return #s*fh*.5 end}end
local function open()local root=assert(E.open(owner));return E.active,root end
local function choose(box,index)box.selected=index;box.onChange(box.target,box)end
local function find(values,value)for i,v in ipairs(values)do if v==value or type(v)=='table'and v.id==value then return i end end;error(value)end
local state,root=open();assert(root.wantKeyEvents and focus.focus==root and root.initialFocus==state.preset and playerFocusCalls==0)
assert(state.veil:onMouseDown()and state.veil:onMouseUp()and state.veil:onMouseWheel(1),'Outside clicks leaked into native Options')
assert(root==E.open(owner)and state.number.disabled and writes==0)
state.value:setText('#123456')
assert(P.current(0).presets.default.values['*'].button.background=='#123456'and P.get(0).presets.default.values['*']==nil)
root:onKeyRelease(Keyboard.KEY_RETURN);assert(E.active==state and writes==0,'Enter implicitly saved')
state.name:setText('');state.value:setText('#654321');assert(not state.save.onclick()and state.draft.pending.name=='','Value edit erased invalid name')
local old=state.propertyBox.selected;choose(state.propertyBox,2);assert(state.propertyBox.selected==old and state.property.id=='background','Invalid edit switched targets')
state.name:setText('Night')
state.preset.expanded=true;root:onKeyRelease(Keyboard.KEY_ESCAPE);assert(not state.preset.expanded and not state.exitPrompt and E.active==state)
state.value:focus();state.cancel.onclick();local prompt=state.exitPrompt;assert(prompt and focus.focus==prompt.panel and not state.value.focused)
local before=P.serialize(P.current(0),1);state.value:setText('#abcdef');state.duplicate.onclick();assert(P.serialize(P.current(0),1)==before and writes==0,'Confirmation allowed an underlying edit')
prompt.keep();assert(not state.exitPrompt and state.value.focused and focus.focus==root)
state.value:setText('#654321')
getFileWriter=function()error('fixture denied')end;assert(not state.save.onclick()and E.active==state and not state.closed and state.error=='StyleSaveFailed')
getFileWriter=writer;assert(state.save.onclick()and state.closed and not E.active and writes==1 and focus.focus==owner and playerFocusCalls==0 and state.veil.removed and not root.wantKeyEvents)
local saved=P.serialize(P.get(0),1);state.save.onclick();state.duplicate.onclick();assert(writes==1 and P.serialize(P.get(0),1)==saved,'Stale callback wrote')
state,root=open();choose(state.familyBox,find(P.families,'slider'));choose(state.propertyBox,find(state.properties,'thumbWidth'))
assert(state.number.visible and state.number.minimum==4 and state.number.maximum==32)
state.number:setCurrentValue(24);assert(P.current(0).presets.default.values['*'].slider.thumbWidth==24)
state.inherit.onclick();assert(not state.draft.presets.default.values['*'].slider)
state.number:setCurrentValue(20);state.reset.onclick();assert(not state.draft.presets.default.values['*'].slider)
choose(state.scopeBox,find(state.scopes,'StyleConsumer'));state.duplicate.onclick()
assert(state.draft.bindings.StyleConsumer=='p1'and state.draft.active=='default')
state.name:setText('Consumer style');state.value:setText('#224466')
state.cancel.onclick();assert(state.exitPrompt);root:onKeyRelease(Keyboard.KEY_ESCAPE);assert(not state.exitPrompt and not state.closed)
state.cancel.onclick();state.exitPrompt.discard();assert(not E.active and P.serialize(P.get(0),1)==saved and writes==1)
-- Stable inspector cannot style itself invisible; samples opt back in.
state,root=open();assert(not next(U.ComponentStyles.properties(root)))
for _,font in ipairs({14,42})do
 state.close();fh=font;vw=1024;vh=720;state,root=open();root:prerender()
 assert(root.x>=100 and root.y>=50 and root.x+root.width<=1124 and root.y+root.height<=770)
 assert(state.form.y+state.form.height<state.save.y and state.area.y+state.area.height<state.save.y)
 root.joypadIndexY=#root.joypadButtonsY-1;root.joypadIndex=1;root:ensureVisible()
 assert(state.form:getYScroll()<0,'Controller could not reveal lower inspector controls')
 state.form:prerender();assert(state.form.stencil);state.form:render();assert(not state.form.stencil)
 state.area:prerender();assert(state.area.stencil);state.area:render();assert(not state.area.stencil)
end
state.value:setText('#334455');local other={};focus.focus=other;state.close();assert(focus.focus==other,'Cleanup stole temporary modal focus')
local lease={};assert(P.preview(0,P.get(0),lease));assert(not E.open(owner)and E.lastError=='preview-owned');P.clearPreview(0,lease)
state=open();state.value:setText('#556677');for _,fn in ipairs(callbacks)do fn()end
assert(state.closed and not E.active and P.serialize(P.get(0),1)==saved and writes==1,'Game lifecycle retained preview or wrote a draft')
print('PASS OFFLINE preset inspector CRUD/scopes/live preview, pending validation/explicit Save, protected exits/stale callbacks, frontend focus/popup ordering, scroll/viewport/stencil and lifecycle cleanup')

-- RGB edits synchronize with hex/inheritance; external choices stay inactive
-- until selected and all workflow changes retain the same unsaved guard.
local K=require 'B47ANCEDUI/PresetPlugins';local X=require 'B47ANCEDUI/PresetExport'
local nativeRefresh=K.refresh;K.refresh=function()return K.entries end
K.entries={{source='FixturePack',id='Fixture',key='default',preset={name='Imported',values={['*']={button={background='#224466'}}}}}}
local unchanged=P.serialize(P.get(0),1)
state,root=open();assert(#state.presetKeys==2 and P.serialize(P.get(0),1)==unchanged)
choose(state.preset,2);assert(state.draft.active~='default'and state.name:getInternalText()=='Imported')
assert(P.serialize(P.get(0),1)==unchanged,'Selecting plugin saved implicitly')
state.rgb[1]:setCurrentValue(255);assert(state.value:getInternalText()=='#FF4466')
state.value:setText('');local red=state.rgb[1].currentValue;assert(red~=255,'Inherit left explicit RGB value')
choose(state.familyBox,find(P.families,'slider'));choose(state.propertyBox,find(state.properties,'thumbWidth'))
assert(state.number.visible and not state.rgb[1].visible)
local oldExport,oldPrevious,oldStatus=X.export,X.previous,X.status
local mode,target;X.previous=function()return {id='Previous',name='Concrete previous name'}end
X.export=function(_,_,_,m,id)mode,target=m,id;return {id='Fixture',fingerprint='12345678'}end
X.status=function()return 'ready'end
choose(state.exportMode,2);assert(state.exportTarget.name=='Concrete previous name')
state.exportButton.onclick();assert(mode=='update'and target=='Previous'and not state.exportStale)
state.name:setText('Changed after export');assert(state.exportStale,'Changed export remained ready')
state.exportMode.expanded=true;root:onKeyRelease(Keyboard.KEY_ESCAPE);assert(not state.exportMode.expanded and not state.exitPrompt)
state.cancel.onclick();assert(state.exitPrompt);state.exitPrompt.discard()
assert(P.serialize(P.get(0),1)==unchanged and writes==1)
X.export,X.previous,X.status=oldExport,oldPrevious,oldStatus;K.refresh=nativeRefresh;K.entries={}
print('PASS OFFLINE inspector RGB/hex synchronization, inherited channels, inactive plugin selection, explicit update target, stale export and unsaved popup ordering')

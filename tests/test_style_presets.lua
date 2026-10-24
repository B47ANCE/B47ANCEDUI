-- Fixture-only table iterator; the runtime global remains unavailable.
local function next(t)for key,value in pairs(t)do return key,value end end
-- Pure Lua/data and control doubles. No engine storage/render/input proof.
local files,writes,fail,readError={},0,nil,nil
getFileReader=function(path,create)
 assert(not create);if readError==path then error('fixture read denied')end
 local text=files[path];if not text then return end
 local lines={};for line in text:gmatch('([^\n]*)\n')do lines[#lines+1]=line end
 local i=0;return {readLine=function()i=i+1;return lines[i]end,close=function()end}
end
getFileWriter=function(path,create,append)
 assert(create and not append);writes=writes+1
 return {write=function(_,text)files[path]=fail=='partial'and text:sub(1,30)or text;if fail=='write'then return false end end,
 close=function()if fail=='close'then return false end end}
end
local function reload()
 B47ANCEDUI.StylePresets=nil;package.loaded['B47ANCEDUI/StylePresets']=nil
 return require 'B47ANCEDUI/StylePresets'
end
require 'B47ANCEDUI/Theme'
local P=reload();local book=P.new()
assert(P.valid(book)and not P.value('future','')and not P.value('opacity',0/0)and not P.value('radius',9))
book=P.set(book,'default','*','button','background','#123456')
book=P.set(book,'default','*','all','text','#ffffff')
book=P.set(book,'default','Consumer','button','background','#abcdef')
book=P.set(book,'default','FutureMod','futureFamily','futureFlag','retained')
local copy,key=P.duplicate(book,'default','Night');assert(key=='p1'and copy.presets[key].name=='Night')
copy.active=key;copy.bindings.Consumer=key
assert(P.serialize(P.parse(P.serialize(copy,1)),1)==P.serialize(copy,1),'Journal must round-trip unknown records')
assert(P.save(0,copy)and writes==1);P=reload();local saved,status=P.get(0);assert(status=='ok'and saved.active==key)
local escaped=P.current(0);escaped.active='broken';assert(P.current(0).active==key,'Mutable cache escaped')
local owner,foreign={},{};local draft=P.set(saved,key,'*','button','text','#AABBCC')
assert(P.preview(0,draft,owner)and not P.preview(0,saved,foreign))
assert(P.current(0).presets[key].values['*'].button.text=='#AABBCC'and P.get(0).presets[key].values['*'].button.text==nil)
assert(not P.clearPreview(0,foreign)and P.clearPreview(0,owner)and P.current(0).presets[key].values['*'].button.text==nil)
assert(P.save(0,draft));fail='partial';assert(not P.save(0,copy));fail=nil;P=reload()
assert(P.get(0).presets[key].values['*'].button.text=='#AABBCC','Interrupted write lost the newest valid slot')
for _,mode in ipairs({'write','close'})do fail=mode;assert(not P.save(0,copy));fail=nil end
local before=writes;files['B47ANCEDUI/style-presets.1.a.txt']='schema=2\n'
P=reload();assert(select(2,P.get(1))=='future'and not P.save(1,P.new())and writes==before)
files['B47ANCEDUI/style-presets.2.a.txt']='bad\n';P=reload()
assert(select(2,P.get(2))=='invalid'and not P.save(2,P.new()))
readError='B47ANCEDUI/style-presets.3.a.txt';P=reload();assert(select(2,P.get(3))=='read-error'and not P.save(3,P.new()));readError=nil
assert(not P.parse(string.rep('x',262145))and not P.parse(P.serialize(copy,1):gsub('active=p1','active=default')))
local d=P.delete(copy,key);assert(d.active=='default'and not d.bindings.Consumer and not P.delete(d,'default'))
for i=1,15 do d=assert(P.duplicate(d,'default','Preset '..i))end
assert(not P.duplicate(d,'default','Overflow'))
local invalid=P.new();invalid.presets.default.name='bad\nname';assert(not P.valid(invalid))
assert(not P.set(book,'default','../Bad','button','opacity',50))
-- Fresh renderer cache with controlled storage. No inherited corrupt profile.
files={};P=reload();local U=require 'B47ANCEDUI/API';local S=U.ComponentStyles;local T=U.Theme
local original=T.copy(T.colors.text);local p=P.new()
p=P.set(p,'default','*','all','text','#112233')
p=P.set(p,'default','*','button','background','#223344')
p=P.set(p,'default','Consumer','button','background','#556677')
p=P.set(p,'default','*','tabs','background','#8899AA')
p=P.set(p,'default','*','slider','thumbWidth',24)
p=P.set(p,'default','*','slider','thumbHeight',40)
p=P.set(p,'default','*','slider','trackThickness',8)
assert(P.preview(0,p,owner))
local b=U.forMod('Consumer').Button:new(4,5,120,30,'Text',{},function()end)
local callback=b.onclick;b:prerender();assert(math.abs(b.backgroundColor.r-0x55/255)<.00001 and b.width==120 and b.x==4 and b.onclick==callback)
b.b47StyleFamily='tabs';b:prerender();assert(math.abs(b.backgroundColor.r-0x88/255)<.00001,'Explicit family lost to generic skin')
local c=S.color(b,T.colors.text);assert(math.abs(c.r-0x11/255)<.00001 and T.colors.text.r==original.r)
local custom={};local facade=U.forMod('Consumer');facade.Styles.setFamily(custom,'button')
assert(custom.b47AppearanceScope=='Consumer'and facade.Styles.color(custom,T.colors.panel).r==0x55/255)
assert(facade.Styles.number(custom,'radius',4)==4 and not pcall(facade.Styles.setFamily,custom,'Typo'))
assert(facade.Styles.number(custom,'background',4)==4,'Numeric resolver returned a color')
local semantic={r=1,g=.4,b=0,a=1};assert(S.color(b,semantic)==semantic,'Arbitrary semantic color changed')
local function paginate(self)self.sliderBarDim={x=15,y=14,w=self.width-30,h=2};self.sliderDim={x=2,y=0,w=5,h=self.height}end
local slider={width=200,height=30,getWidth=function(self)return self.width end,getHeight=function(self)return self.height end,paginate=paginate,currentValue=51,minValue=0,maxValue=100,stepValue=3}
paginate(slider);local attached=true;S.slider(slider,function()return attached end)
slider:paginate();assert(slider.sliderDim.w==24 and slider.sliderDim.h==30 and slider.sliderBarDim.h==8 and slider.sliderBarDim.x==15 and slider.sliderBarDim.w==170 and slider.currentValue==51 and slider.stepValue==3)
attached=false;slider:paginate();assert(slider.sliderDim.w==5 and slider.sliderBarDim.h==2,'Detached native slider retained overrides')
local popup={width=100,height=70,getWidth=function(self)return self.width end,getHeight=function(self)return self.height end,backgroundColor={},borderColor={}}
local oldBG,oldBorder=popup.backgroundColor,popup.borderColor
popup.drawRectBorderStatic=function()end
popup.prerender=function(self)
 if not(self.parentCombo and self.parentCombo.b47StyleDropdown)then assert(self.backgroundColor==oldBG and self.borderColor==oldBorder);return 'foreign-popup'end
 assert(self.backgroundColor.r==0x22/255)
 if self.fail then error('fixture popup render failure')end
 return 'native-popup'
end
popup.render=function()return 'native-render'end
ISComboBox.SharedPopup=popup
local dropdown=ISPanel:new(0,0,100,30);dropdown.b47AppearanceScope='Consumer'
dropdown.showPopup=function(self)popup.parentCombo=self;return 'opened'end
local dp=P.set(p,'default','*','dropdown','background','#223344');assert(P.preview(0,dp,owner))
U.Dropdown.style(dropdown);assert(dropdown:showPopup()=='opened'and popup:prerender()=='native-popup')
assert(popup.backgroundColor==oldBG and popup.borderColor==oldBorder)
popup.fail=true;assert(not pcall(popup.prerender,popup)and popup.backgroundColor==oldBG and popup.borderColor==oldBorder);popup.fail=false
popup.parentCombo={};assert(popup:prerender()=='foreign-popup','Foreign shared popup ownership was styled')
P.clearPreview(0,owner);b:prerender();assert(b.backgroundColor.r==T.colors.raised.r,'Cancel did not restore inherited palette')
local safe={b47StyleSafe=true};b.parent=safe;assert(P.preview(0,p,owner));assert(not next(S.properties(b)))
b.b47StylePreview=true;assert(next(S.properties(b)));P.clearPreview(0,owner)
-- Full backing outlines preserve existing rounded rendering. Explicit primitive
-- families must not be recolored a second time by the owner's panel family.
local fills,borders,last=0,0
ISButton.drawRect=function()fills=fills+1 end
ISButton.drawRectBorder=function(_,x,y,w,h,a,r,g,blue)borders=borders+1;last={r=r,g=g,b=blue}end
local rounded=U.Button:new(0,0,100,32,'Frame');U.Renderer.border(rounded,0,0,100,32,T.colors.border)
assert(fills>0 and borders==0,'Default role border lost its rounded backing')
local explicit=P.set(P.new(),'default','*','panel','border','#FF0000')
assert(P.preview(0,explicit,owner))
local primitive={drawRectBorder=ISButton.drawRectBorder,getWidth=function()return 100 end,getHeight=function()return 32 end,b47StyleFamily='panel'}
U.Renderer.border(primitive,1,1,10,8,T.colors.border,'progress')
assert(last.r==T.colors.border.r and last.g==T.colors.border.g,'Primitive inherited unrelated owner-family border')
P.clearPreview(0,owner)
local noBorder=P.set(P.new(),'default','*','button','borderWidth',0);assert(P.preview(0,noBorder,owner))
fills,borders=0,0;U.Renderer.border(rounded,0,0,100,32,T.colors.border);assert(fills==0 and borders==0)
rounded.joypadFocused=true;U.Renderer.focus(rounded);assert(fills+borders>0,'Border override removed controller focus')
P.clearPreview(0,owner)
local sharedBook=P.set(P.new(),'default','*','button','background','#112233')
sharedBook=P.set(sharedBook,'default','B47ANCEDUI','button','background','#445566')
sharedBook=P.set(sharedBook,'default','*','menuButton','accent','#778899')
assert(P.preview(0,sharedBook,owner))
local previewRoot={b47StylePreview=true,b47StylePreviewShared=true};local previewChild={parent=previewRoot,b47StyleFamily='button'}
assert(S.color(previewChild,T.colors.panel).r==0x11/255,'Shared sample was masked by UI mod overrides')
local line
local nativeLabel={getWidth=function()return 100 end,getHeight=function()return 32 end,drawRect=function(_,x,y,w,h,a,r,g,b)line={r=r,g=g,b=b}end}
U.Renderer.menuUnderline(nativeLabel,3,60);assert(line.r==0x77/255 and line.b==0x99/255,'Native underline lost menu family accent')
P.clearPreview(0,owner)
print('PASS OFFLINE style journals/limits/unknown preservation/failed writes/protected data, preview ownership/copies, scoped inheritance/Cancel and detached slider value/geometry isolation')

local channels=P.new();local channelOwner={};local count=0
for key in pairs(T.colorAliases)do
 count=count+1;channels=assert(P.set(channels,'default','*','all',key,'#123456'))
end
assert(count==39 and P.preview(0,channels,channelOwner))
for key,base in pairs(T.colorAliases)do
 assert(T.colors[key]~=T.colors[base],'Alias shares mutable theme table')
 local c=S.color({},T.colors[key]);assert(c.r==0x12/255 and c.g==0x34/255 and c.b==0x56/255,key)
end
P.clearPreview(0,channelOwner)
local inherited=P.set(P.new(),'default','*','slider','accent','#234567')
inherited=P.set(inherited,'default','*','scrollbar','scrollThumb','#345678')
assert(P.preview(0,inherited,channelOwner))
assert(S.color({b47StyleFamily='scrollbar'},T.colors.scrollThumb).r==0x34/255)
assert(S.color({b47StyleFamily='slider'},T.colors.accent).r==0x23/255)
P.clearPreview(0,channelOwner)
print('PASS OFFLINE all39 additional independent colour channels and scrollbar-specific inheritance')

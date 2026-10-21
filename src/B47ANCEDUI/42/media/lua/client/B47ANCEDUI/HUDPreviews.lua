-- Original static samples built from UI primitives. Never instantiate gameplay HUD.
require 'B47ANCEDUI/API'
local U=B47ANCEDUI;local R,T=U.Renderer,U.Theme
local function preview(key,kind)
 return function(parent)
  local panel=U.Panel:new(0,0,200,120);panel:initialise();panel:instantiate()
  local pre=panel.prerender
  panel.prerender=function(self,...)
   pre(self,...);local w,h=self:getWidth(),self:getHeight();local font=getTextManager():getFontHeight(UIFont.Small)
   R.rect(self,0,0,w,math.min(h,font+10),T.colors.raised)
   R.text(self,R.fit(getText('UI_B47ANCEDUI_'..key),math.max(1,w-12)),6,4,T.colors.text)
   if kind=='clock' then
    if h>font*2+12 then R.text(self,'12:00',8,font+12,T.colors.text) end
   elseif kind=='hotbar' or kind=='equipment' or kind=='moodles' then
    local size=math.max(8,math.min(30,(w-12)/5,h-font-16))
    for i=1,5 do
     local x=kind=='hotbar' and 6+(i-1)*size or 6;local y=font+12+(kind=='hotbar' and 0 or (i-1)*(size+4))
     if y+size<=h-4 then R.border(self,x,y,size-3,size-3,T.colors.strong) end
    end
   elseif kind=='map' then
    for x=12,w-8,24 do R.rect(self,x,font+14,1,math.max(0,h-font-22),T.colors.border) end
    for y=font+14,h-8,24 do R.rect(self,8,y,math.max(0,w-16),1,T.colors.border) end
   else
    local row=font+10
    for i=1,math.min(7,math.floor((h-font-18)/row)) do
     local y=font+12+(i-1)*row
     R.rect(self,6,y,w-12,row-2,i%2==0 and T.colors.alternate or T.colors.row)
     R.text(self,R.fit(getText('UI_B47ANCEDUI_SampleContent'),math.max(1,w-24)),12,y+3,T.colors.muted)
    end
   end
  end
  return panel
 end
end
local specs={
 {'inventory','AssetInventory',.12,.03,.32,.3,true,288,180},
 {'loot','AssetLoot',.48,.03,.32,.3,true,288,180},
 {'character','AssetCharacter',.08,.4,.23,.48,false,160,160},
 {'mechanics','AssetMechanics',.53,.38,.42,.56,true,800,600},
 {'chat','AssetChat',.24,.67,.28,.26,true,200,100},
 {'equipment','AssetEquipment',.01,.08,.07,.35,false,60,100,'equipment'},
 {'hotbar','AssetHotbar',.35,.91,.3,.06,false,180,36,'hotbar'},
 {'minimap','AssetMinimap',.82,.70,.17,.27,false,120,120,'map'},
 {'clock','AssetClock',.84,.03,.14,.08,false,100,50,'clock',false},
 {'moodles','AssetMoodles',.93,.14,.06,.36,false,50,140,'moodles',false},
}
for _,s in ipairs(specs) do
 local id='B47ANCEDUI.'..s[1]
 if not U.LayoutAssets.get(id) then U.LayoutAssets.register(id,{labelKey='UI_B47ANCEDUI_'..s[2],default={x=s[3],y=s[4],w=s[5],h=s[6]},
  resizable=s[7],resizeWidth=s[1]~='mechanics',minWidth=s[8],minHeight=s[9],preview=preview(s[2],s[10]),editable=s[11]~=false}) end
end
return U.LayoutAssets

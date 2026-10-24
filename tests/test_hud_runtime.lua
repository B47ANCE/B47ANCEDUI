-- Native-shaped fixtures only; event registration/dispatch in PZ is untested.
local P=require 'B47ANCEDUI/UILayout';local R=B47ANCEDUI.LayoutAssets
package.loaded['ISUI/PlayerData/ISPlayerData']=true
package.loaded['ISUI/PlayerData/ISPlayerDataObject']=true
package.loaded['Chat/ISChat']=true
local callbacks={};Events={}
for _,name in ipairs({'OnCreatePlayer','OnGameStart','OnResolutionChange','OnChatWindowInit'})do
 callbacks[name]={};Events[name]={Add=function(f)callbacks[name][#callbacks[name]+1]=f end}
end
local nativeHotCalls=0;ISHotbar={setSizeAndPosition=function(self)
 nativeHotCalls=nativeHotCalls+1;self:setWidth(400);self:setX(500);self:setY(900);return 'native-result'
end}
local function widget(kind,w,h)
 local value=ISPanel:new(11,12,w or 300,h or 200);value.Type=kind;value.visible=false;value.pin=true;return value
end
local first={playerInventory=widget('ISInventoryPage'),lootInventory=widget('ISInventoryPage'),
 characterInfo=widget('ISCharacterInfoWindow'),mechanicsUI=widget('ISVehicleMechanics',800,600),
 equipped=widget('ISEquippedItem',80,400),miniMap=widget('ISMiniMapOuter',250,250),playerHotbar=widget('ISHotbar',400,40)}
first.playerHotbar.setSizeAndPosition=ISHotbar.setSizeAndPosition
first.characterInfo.resizable=false;first.mechanicsUI.resizeWidget={yonly=true};first.mechanicsUI.minimumHeight=600
local secondary={playerInventory=widget('ISInventoryPage'),playerHotbar=widget('ISHotbar',400,40)}
secondary.playerHotbar.setSizeAndPosition=ISHotbar.setSizeAndPosition
ISPlayerData={first,secondary};ISChat={instance=widget('ISChat',500,200)}
JoypadState={players={}}
getPlayerScreenLeft=function(player)return player*960 end;getPlayerScreenTop=function()return 0 end
getPlayerScreenWidth=function(player)return player==0 and 1920 or 960 end;getPlayerScreenHeight=function()return 1080 end
local H=require 'B47ANCEDUI/HUDLayoutRuntime'
assert(first.playerInventory.x==11 and not first.playerHotbar.b47LayoutPosition,'Frontend module loading mutated HUD')
H.apply();assert(first.playerInventory.x==11 and not first.miniMap.userPosition)
local profile={}
for _,id in ipairs({'inventory','loot','character','mechanics','equipment','minimap','hotbar','chat'})do
 profile['B47ANCEDUI.'..id]={x=.1,y=.2,w=.4,h=.3}
end
getFileWriter=function()return {write=function()end,close=function()end}end
assert(P.save(profile));H.apply()
assert(first.playerInventory.x==192 and first.playerInventory.width==768 and first.playerInventory.height==324)
assert(first.playerInventory.visible==false and first.playerInventory.pin==true,'Visibility/pin state changed')
assert(first.characterInfo.width==300 and first.equipped.width==80 and first.miniMap.width==250 and first.miniMap.userPosition)
assert(first.mechanicsUI.width==800 and first.mechanicsUI.height==600,'Native mechanics axis/minima ignored')
assert(secondary.playerInventory.x==1056 and secondary.playerInventory.width==384)
assert(ISChat.instance.x==192 and ISChat.instance.width==768)
local owned=first.playerHotbar.setSizeAndPosition;H.apply();assert(first.playerHotbar.setSizeAndPosition==owned and ISHotbar.setSizeAndPosition~=owned)
assert(first.playerHotbar:setSizeAndPosition()=='native-result' and first.playerHotbar.x==192 and first.playerHotbar.width==400)
secondary.playerHotbar:setSizeAndPosition();assert(secondary.playerHotbar.x==1056 and nativeHotCalls==2,'Hotbar closure used another local player viewport')
JoypadState.players[2]={};secondary.playerInventory:setX(10);secondary.playerHotbar:setSizeAndPosition();H.apply()
assert(secondary.playerInventory.x==10 and secondary.playerHotbar.x==500,'Controller layout overridden')
local old=first.playerHotbar;first.playerHotbar=widget('ISHotbar',400,40);first.playerHotbar.setSizeAndPosition=ISHotbar.setSizeAndPosition
old:setSizeAndPosition();assert(old.x==500,'Stale native UI instance retained layout ownership')
for _,f in ipairs(callbacks.OnCreatePlayer)do f(0,{})end
assert(first.playerHotbar.b47LayoutPosition and first.playerHotbar.x==192)
first.playerInventory=widget('AnotherModWindow');H.apply();assert(first.playerInventory.x==11)
assert(P.save({}));first.playerHotbar:setSizeAndPosition();assert(first.playerHotbar.x==500)
for name,list in pairs(callbacks)do assert(#list==1,name..' duplicate event hook')end
print('PASS OFFLINE native HUD explicit overrides, restore order fixtures, minima/axis preservation, local-player/controller/stale-instance guards and hotbar delegate ownership')

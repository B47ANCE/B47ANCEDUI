-- Apply explicit local geometry after native UI construction/restoration only.
require 'B47ANCEDUI/HUDPreviews'
require 'ISUI/PlayerData/ISPlayerData'
require 'ISUI/PlayerData/ISPlayerDataObject'
require 'Chat/ISChat'
local R=B47ANCEDUI.LayoutAssets
local P=require 'B47ANCEDUI/UILayout'
local H={};B47ANCEDUI.HUDLayoutRuntime=H
local fields={inventory={'playerInventory','ISInventoryPage'},loot={'lootInventory','ISInventoryPage'},
 character={'characterInfo','ISCharacterInfoWindow'},mechanics={'mechanicsUI','ISVehicleMechanics'},
 equipment={'equipped','ISEquippedItem'},minimap={'miniMap','ISMiniMapOuter'},hotbar={'playerHotbar','ISHotbar'}}
local function viewport(player)
 return getPlayerScreenLeft(player),getPlayerScreenTop(player),getPlayerScreenWidth(player),getPlayerScreenHeight(player)
end
local function mouse(player) return not (JoypadState and JoypadState.players and JoypadState.players[player+1]) end
local function apply(key,w,player)
 if not mouse(player) then return false end
 return R.apply('B47ANCEDUI.'..key,w,viewport(player))
end
function H.apply()
 for player=0,3 do
  local data=ISPlayerData and ISPlayerData[player+1]
  if data and mouse(player) then
   for key,spec in pairs(fields) do
    local w=data[spec[1]]
    if w and w.Type==spec[2] then
     if key=='hotbar' and P.entry('B47ANCEDUI.hotbar') and ISHotbar and not w.b47LayoutPosition and w.setSizeAndPosition==ISHotbar.setSizeAndPosition then
      w.b47LayoutPosition=true;local native=w.setSizeAndPosition
      w.setSizeAndPosition=function(self,...)
       local result=native(self,...)
       local current=ISPlayerData and ISPlayerData[player+1]
       if current and current.playerHotbar==self then apply('hotbar',self,player) end
       return result
      end
     end
     if apply(key,w,player) and key=='minimap' then w.userPosition=true end
    end
   end
  end
 end
 if ISChat and ISChat.instance and ISChat.instance.Type=='ISChat' then apply('chat',ISChat.instance,0) end
end
-- These native modules register their own create/restore callbacks first.
Events.OnCreatePlayer.Add(H.apply)
Events.OnGameStart.Add(H.apply)
Events.OnResolutionChange.Add(H.apply)
Events.OnChatWindowInit.Add(H.apply)
return H

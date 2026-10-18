-- Shared client presentation library. No application state, networking or mod APIs.
B47ANCEDUI=B47ANCEDUI or {}
local T={};B47ANCEDUI.Theme=T
local function color(r,g,b,a) return {r=r,g=g,b=b,a=a or 1} end
T.colors={window=color(.035,.039,.039,.96),panel=color(.055,.059,.059,.96),raised=color(.09,.098,.098,.98),
 row=color(.055,.059,.059,.94),alternate=color(.075,.082,.082,.94),hover=color(.14,.157,.15,.98),
 selected=color(.17,.17,.17,.98),border=color(.22,.25,.24,.9),strong=color(.46,.52,.49,.96),
 text=color(.91,.93,.92),muted=color(.62,.67,.64),accent=color(176/255,176/255,176/255),accentHover=color(.81,.81,.81),
 needed=color(.82,.42,.39),warning=color(.80,.69,.45),success=color(.53,.72,.58),disabled=color(.39,.43,.41),
 destructive=color(.73,.37,.34),overlay=color(.015,.02,.02,.86)}
T.spacing={xs=4,s=8,m=12,l=18,xl=24};T.borderSize=1;T.corner='rounded';T.radius=6
T.defaultAccent='#B0B0B0'
T.fonts={title=UIFont.Medium,section=UIFont.Medium,body=UIFont.Small,small=UIFont.Small,item=UIFont.Small,status=UIFont.Small}
local cached
function T.metrics()
 local small=getTextManager():getFontHeight(T.fonts.body);local title=getTextManager():getFontHeight(T.fonts.title)
 if cached and cached.font==small and cached.titleFont==title then return cached end
 cached={font=small,titleFont=title,header=math.max(40,title+18),row=math.max(30,small+12),treeRow=math.max(22,small+8),
 button=math.max(28,small+12),tab=math.max(32,small+16),icon=24,treeIcon=18,railIcon=32,railRow=math.max(48,small+28),rail=math.max(180,small*8),scrollbar=17,gap=8}
 return cached
end
-- Returned values are caller-owned. Native font scale determines minimum height.
function T.buttonSize(size)
 -- Compatibility alias only: there is no distinct third button size.
 if size=='large' then size='normal' end
 local specs={small={24,10,8,3,T.fonts.body},normal={32,18,12,4,T.fonts.body}}
 local s=specs[size];assert(s,'B47ANCEDUI: unknown button size '..tostring(size))
 return {id=size,height=math.max(s[1],getTextManager():getFontHeight(s[5])+s[2]),padding=s[3],radius=s[4],font=s[5]}
end
function T.copy(c) return {r=c.r,g=c.g,b=c.b,a=c.a} end
return T

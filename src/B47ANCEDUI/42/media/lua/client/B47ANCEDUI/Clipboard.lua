-- Original editable Lua geometry; no textures, physical props or world mutation.
require 'B47ANCEDUI/Renderer'
local U=B47ANCEDUI;local R=U.Renderer;local A={}
local function c(r,g,b) return {r=r,g=g,b=b,a=1} end
local P={board=c(.35,.25,.15),edge=c(.20,.14,.09),grain=c(.43,.32,.20),paper=c(.94,.92,.82),
 sheet=c(.98,.97,.89),shade=c(.70,.68,.58),ink=c(.17,.20,.23),rule=c(.70,.77,.78),red=c(.74,.43,.40),
 metal=c(.61,.64,.65),metalLight=c(.88,.90,.90),metalDark=c(.28,.31,.33),metalShade=c(.46,.50,.52)}
A.colors={grey=P.paper,white=P.sheet,light=c(.96,.95,.86),shadow=P.rule,black=P.ink,
 muted=c(.37,.36,.30),blue=c(.24,.31,.36),selection=c(.84,.86,.77),selectedText=P.ink}
function A.draw(panel,view,m,title)
 local w,h=panel:getWidth(),panel:getHeight()
 R.rect(panel,0,0,w,h,P.edge);R.rect(panel,3,3,w-6,h-6,P.board)
 for n=0,2 do R.rect(panel,6+n*4,10,1,h-20,P.grain) end
 -- Stacked square-cut sheets, restrained ruling and a red notebook margin.
 R.rect(panel,22,56,w-40,h-70,P.shade);R.rect(panel,20,54,w-40,h-70,P.paper)
 R.rect(panel,18,52,w-40,h-70,P.sheet)
 -- Ruling belongs only to the scrolling table, not the header/details/buttons.
 R.rect(panel,view.left-10,60,1,h-86,P.red)
 -- Spring clamp: rounded hanging loop behind the plate, riveted shoulders,
 -- raised thumb tab and a rolled jaw that actually overlaps the paper at y=52.
 local cw=math.max(148,m.font*5);local x=math.floor((w-cw)/2);local middle=math.floor(w/2)
 R.rect(panel,middle-11,4,22,2,P.metalDark);R.rect(panel,middle-14,6,28,2,P.metalLight)
 R.rect(panel,middle-16,8,3,12,P.metalDark);R.rect(panel,middle+13,8,3,12,P.metalDark)
 R.rect(panel,middle-14,8,1,11,P.metalLight);R.rect(panel,middle+13,8,1,11,P.metalLight)
 R.rect(panel,x+5,21,cw-4,43,P.shade)
 R.rect(panel,x+6,14,cw-12,2,P.metalDark);R.rect(panel,x+2,16,cw-4,4,P.metalDark)
 R.rect(panel,x,20,cw,34,P.metalDark);R.rect(panel,x+2,54,cw-4,6,P.metalDark)
 R.rect(panel,x+6,60,cw-12,2,P.metalDark)
 R.rect(panel,x+5,17,cw-10,3,P.metalLight);R.rect(panel,x+2,20,cw-4,24,P.metal)
 R.rect(panel,x+2,20,2,24,P.metalLight);R.rect(panel,x+cw-4,20,2,24,P.metalShade)
 -- Broad, restrained reflections distinguish the curved jaw from a flat box.
 R.rect(panel,x+2,44,cw-4,3,P.metalShade);R.rect(panel,x+3,47,cw-6,2,P.metalDark)
 R.rect(panel,x+3,49,cw-6,3,P.metalLight);R.rect(panel,x+4,52,cw-8,4,P.metal)
 R.rect(panel,x+5,56,cw-10,3,P.metalShade);R.rect(panel,x+8,59,cw-16,1,P.metalLight)
 R.rect(panel,middle-29,20,58,19,P.metalDark);R.rect(panel,middle-27,18,54,19,P.metalLight)
 R.rect(panel,middle-26,21,52,13,P.metal);R.rect(panel,middle-24,34,48,3,P.metalShade)
 R.rect(panel,middle-22,37,44,2,P.metalLight)
 for _,sx in ipairs({x+16,x+cw-22}) do
  R.rect(panel,sx+1,25,4,6,P.metalDark);R.rect(panel,sx,26,6,4,P.metalDark)
  R.rect(panel,sx+1,26,4,3,P.metalLight);R.rect(panel,sx+2,28,2,2,P.metalShade)
 end
 title=title or getText('UI_B47ANCEDUI_ClipboardTitle')
 R.text(panel,R.fit(title,w-2*view.left),view.left,66,P.ink)
 -- The native resize widget stays active when its ordinary window frame is hidden.
 for band=0,2 do for n=0,band+1 do R.rect(panel,w-9-band*4+n*2,h-6-n*2,2,2,P.metalLight) end end
end
U.Clipboard=A
return A

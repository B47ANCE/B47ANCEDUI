-- Internal, deterministic geometry/search. No settings values or persistence.
require 'B47ANCEDUI/API'
local U=B47ANCEDUI;if U.OptionsLayoutModel then return U.OptionsLayoutModel end
local M={};U.OptionsLayoutModel=M
local function clamp(n,a,b)return math.max(a,math.min(b,n))end
function M.chrome(w,h,f,buttons)
 local g=math.max(12,f);local bh=math.max(34,f+14)
 local side=clamp(w*.23,200,math.max(300,12*f))
 local contentW=math.min(w-side-g*2,math.max(1800,80*f))
 local right=side+g+contentW
 local header=bh+g*2;local footer=bh+g*2
 local used,rows=0,1
 for _,bw in ipairs(buttons)do
  if used>0 and used+bw+g>right-g*2 then rows=rows+1;used=0 end
  used=used+bw+g
 end
 footer=rows*bh+(rows+1)*g
 local bodyY=header+g+f*3
 return {g=g,button=bh,header=header,footer=footer,side=side,
  x=side+g,y=bodyY,w=math.max(1,contentW),right=right,h=math.max(1,h-footer-bodyY-g),
  sidebarY=header+g,sidebarH=math.max(1,h-footer-header-g*2),categoryH=math.max(58,f*3+18)}
end
function M.columns(w,f,control)
 local pad=math.max(14,f);local minLabel=math.max(160,10*f)
 local tips=w>=control+minLabel+math.max(240,15*f)+pad*4
 local tipW=tips and math.min(280,w*.23) or 0
 local summary=w>=control+minLabel+tipW+math.max(210,12*f)+pad*5
 local summaryW=summary and math.min(300,w*.25) or 0
 local cx=w-pad-tipW-(tips and pad or 0)-control
 local labelX=pad+summaryW+(summary and pad or 0)
 local labelW=cx-labelX-pad
 -- Check actual rail widths before stacking rows into their occupied lanes.
 if labelW<minLabel or summaryW==0 then
  summaryW=0;tipW=0;cx=w-pad-control;labelX=pad;labelW=cx-labelX-pad
 end
 return {pad=pad,controlX=cx,labelX=labelX,labelW=labelW,summaryW=summaryW,tipW=tipW,
  stacked=labelW<minLabel,tipX=w-pad-tipW}
end
function M.matches(index,query,limit)
 query=string.lower(string.sub(tostring(query or ''),1,128))
 local out={};if not string.find(query,'%S')then return out end
 for _,entry in ipairs(index)do
  local hay=string.lower(entry.text..' '..(entry.category or '')..' '..(entry.tip or ''))
  local match=true
  for token in string.gmatch(query,'%S+')do if not string.find(hay,token,1,true)then match=false;break end end
  if match then out[#out+1]=entry;if #out>=(limit or 8)then break end end
 end
 return out
end
function M.scroll(y,extent,height)return -clamp(y-16,0,math.max(0,extent-height))end
return M

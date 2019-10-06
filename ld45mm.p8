pico-8 cartridge // http://www.pico-8.com
version 18
__lua__


left,right,up,down,fire1,fire2=0,1,2,3,4,5
black,dark_blue,dark_purple,dark_green,brown,dark_gray,light_gray,white,red,orange,yellow,green,blue,indigo,pink,peach=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

mapH = 127
mapW = 127
focusedOption = 0
offsetX = 64
offsetY = 50
offsetPerOption = 10

function loadGame(param)
 return function()
  load("ld45", "main menu", param)
 end
end

function _init()
 options = {}
 createOption({label="tutorial", onClick=loadGame("tutorial")})
 createOption({label="normal", onClick=loadGame("normal")})
 createOption({label="hardcore", disabled=true, onClick=loadGame("hardcore")})
 createOption({label="exit", onClick=function() extcmd("shutdown") end, offset = 16})
end

function createOption(props)
 local option = {
  label = props.label,
  disabled = props.disabled or false,
  onClick = function(self)
   if not self.disabled then
    -- props.onClick()
    sfx(1)
   else
   sfx(2)
   end
  end,
  offset = props.offset or offsetPerOption
 }
 options[#options + 1] = option
end


function _update()
 if btnp(up) then
  focusedOption -= 1
  sfx(0)
 elseif btnp(down) then
  focusedOption += 1
  sfx(0)
 end
 focusedOption %= #options

 if btnp(fire1) or btnp(fire2) then
  options[focusedOption + 1]:onClick()
 end

end

function _draw()
 cls()
 rectfill(0, 0, mapW, mapH, dark_blue)
 map(0,0,0,0,mapW,mapH)
 local lastOffset = offsetY
 for i=1,#options do
  local option = options[i]
  local w = #(option.label) * 4 - 1
  local x = offsetX - flr(w / 2)
  local y = lastOffset + option.offset
  lastOffset = y

  if i - 1 == focusedOption then
   rectfill(x - 1, y - 1, x + w, y + 5, blue)
  end

  local color = white
  if option.disabled then color = dark_gray end

  print(option.label, x, y, color)
 end
end


__sfx__
000100001d540185200e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a000027050290402b030030302d0202f0503105034050320502e0502005014050100500c700067000570004700037000170000000000000000000000000000000000000000000000000000000000000000000
00040000045500b540075300403002020000100500005000020000100016000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

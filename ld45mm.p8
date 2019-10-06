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

function _init()
 options = {}
 createOption({label="tutorial"})
 createOption({label="normal"})
 createOption({label="harcore", disabled=true})
end

function createOption(props)
 local option = {
  label = props.label,
  name = props.name or props.label,
  disabled = props.disabled or false
 }
 options[#options + 1] = option
end


function _update()
 if btnp(up) then focusedOption -= 1 end
 if btnp(down) then focusedOption += 1 end
 focusedOption %= 3

 if btn(fire1) or btn(fire2) then load("ld45", "main menu") end

end

function _draw()
 cls()
 rectfill(0, 0, mapW, mapH, dark_blue)
 map(0,0,0,0,mapW,mapH)

 for i=1,#options do
  local option = options[i]
  local w = #(option.label) * 4 - 1
  local x = offsetX - flr(w / 2)
  local y = offsetY + i * offsetPerOption

  if i - 1 == focusedOption then
   rectfill(x - 1, y - 1, x + w, y + 5, blue)
  end

  local color = white
  if option.disabled then color = light_gray end

  print(option.label, x, y, white)
 end

 print(focusedOption, 1, 1, white)
end


__gfx__
__gff__
__map__
__sfx__
__music__

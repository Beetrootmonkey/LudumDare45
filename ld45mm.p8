pico-8 cartridge // http://www.pico-8.com
version 18
__lua__


left,right,up,down,fire1,fire2=0,1,2,3,4,5
black,dark_blue,dark_purple,dark_green,brown,dark_gray,light_gray,white,red,orange,yellow,green,blue,indigo,pink,peach=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

mapH = 127
mapW = 127
option = 0

function _init()

end


function _update()
 if btnp(up) then option -= 1 end
 if btnp(down) then option += 1 end
 option %= 3

if btn(fire1) or btn(fire2) then load("ld45", "main menu") end

end

function _draw()
 cls()
 --map(0,0,0,0,mapH,mapW)

 rectfill(43, 63 + option * 10, 83, 69 + option * 10, blue)

 print("option 1", 44, 64, white)
 print("option 2", 44, 74, white)
 print("option 3", 44, 84, white)
end


__gfx__
__gff__
__map__
__sfx__
__music__

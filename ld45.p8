pico-8 cartridge // http://www.pico-8.com
version 18
__lua__


left,right,up,down,fire1,fire2=0,1,2,3,4,5
black,dark_blue,dark_purple,dark_green,brown,dark_gray,light_gray,white,red,orange,yellow,green,blue,indigo,pink,peach=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

p={
 x=36,
 y=36,
 move=function(self, newPos)
  self.x = newPos.x
  self.y = newPos.y
 end,
 canMove=function(self, newPos)
  for i=1,#self.collisionBox do
   local coord = self.collisionBox[i]
   local tile = mget((newPos.x + coord.x) / 8, (newPos.y + coord.y) / 8)
   local isWall = fget(tile, 0) --TRUE auf Flag 0 bedeutet WAND
   if isWall then
    return false
   end
  end
  return true
 end,
 tryMove=function(self, newPos)
  if self:canMove(newPos) then self:move(newPos) end
 end,
 update=function(self, newPos)
    if (btn(left)) then self:tryMove({x=p.x-1, y=p.y}) end
    if (btn(right)) then self:tryMove({x=p.x+1, y=p.y}) end
    if (btn(up)) then self:tryMove({x=p.x, y=p.y-1}) end
    if (btn(down)) then self:tryMove({x=p.x, y=p.y+1}) end
 end,
 draw=function(self)
  pset(self.x, self.y, red)
  for i=1,#self.collisionBox do
   local coord = self.collisionBox[i]
   pset(self.x + coord.x, self.y + coord.y, white)
  end

  local tile = mget(self.x / 8, self.y / 8)
  local isWall = fget(tile, 0) --TRUE auf Flag 0 bedeutet WAND
  print(self.x .. " " .. self.y,0,0,7)
 end,
 collisionBox={
  {x=-2, y=-2},
  {x= 2, y=-2},
  {x=-2, y= 2},
  {x= 2, y= 2}
 }
}

function _init()

  mapH = 127
  mapW = 127

end

function _update()

  p:update()

  local spriteId = mget(nx,ny)
  if(fget(spriteId, 0)) then
    fset(spriteId, 1, true)
  end
end

function _draw()
  cls()
  map(0,0,0,0,mapH,mapW)


  for w=0,mapW do
    for h=0,mapH do
      local x,y = w*8,h*8
      --rectfill(x,y,x+7,y+7,black)
    end
  end

  p:draw()
end


__gfx__
50000005ffffffff5555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ffffffff5555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ffffffff5555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ffffffff5555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ffffffff5555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ffffffff5555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ffffffff5555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
50000005ffffffff5555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
7000000077707070777007707770777000007770777007707770000077707770770000000fffffff555555555555555555555555ffffffffffffffffffffffff
0700000070007070707070707070070000000700700070000700000070700700707000000fffffff555555555555555555555555ffffffffffffffffffffffff
0070000077000700777070707700070000000700770077700700000077000700707000000fffffff555555555555555555555555ffffffffffffffffffffffff
0700000070007070700070707070070000000700700000700700000070700700707000000fffffff555555555555555555555555ffffffffffffffffffffffff
7000000077707070700077007070070000000700777077000700070077707770707000000fffffff55555555ffffffff55555555ffffffffffffffffffffffff
0000000000000000000000000000000000000000000000000000000000000000000000000fffffff55555555ffffffff55555555ffffffffffffffffffffffff
66000660000066600660066066000000666006606060660066000000000000000000000000000000000000000000000000000000000000000000000000000000
60606060000006006000606060600000600060606060606060600000000000000000000000000000000000000000000000000000000000000000000000000000
60606060000006006000606060600000660060606060606060600000000000000000000000000000000000000000000000000000000000000000000000000000
60606060000006006000606060600000600060606060606060600000000000000000000000000000000000000000000000000000000000000000000000000000
60606600000066600660660060600000600066000660606066600000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66606000666066600660666000000660666066606660606066606660000066600000600066606660666060000000066066600000606006606660000000006660
60606000600060606000600000006000606060600600606060606000000060600000600060606060600060000000606060600000606060006000000000000600
66606000660066606660660000006000666066600600606066006600000066600000600066606600660060000000606066000000606066606600000066600600
60006000600060600060600000006000606060000600606060606000000060600000600060606060600060000000606060600000606000606000000000000600
60006660666060606600666000000660606060000600066060606660000060600000666060606660666066600000660060600000066066006660000000006660
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7000000077707070777007707770777000000000777000007770777007707770000077707770770000000fffffffffffffffffffffffffffffffffffffffffff
0700000070007070707070707070070000000000070000000700700070000700000070700700707000000fffffffffffffffffffffffffffffffffffffffffff
0070000077000700777070707700070000007770070000000700770077700700000077000700707000000fffffffffffffffffffffffffffffffffffffffffff
0700000070007070700070707070070000000000070000000700700000700700000070700700707000000fffffffffffffffffffffffffffffffffffffffffff
7000000077707070700077007070070000000000777000000700777077000700070077707770707000000fffffffffffffffffffffffffffffffffffffffffff
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000fffffffffffffffffffffffffffffffffffffffffff
66000660000006606060666066606060666000006660666060006660000000000000000000000000000000000000000000000000000000000000000000000000
60606060000060606060060060606060060000006000060060006000000000000000000000000000000000000000000000000000000000000000000000000000
60606060000060606060060066606060060000006600060060006600000000000000000000000000000000000000000000000000000000000000000000000000
60606060000060606060060060006060060000006000060060006000000000000000000000000000000000000000000000000000000000000000000000000000
60606600000066000660060060000660060000006000666066606660000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70000000700077707070777007707770777000007770077007700000707077707770700000000000777000000770770077700000777070707770777007700000
07000000070070007070707070707070070000007000707070700000707007007770700000000000707000007070707070000000707070700700070070700000
00700000007077000700777070707700070000007700707070700000777007007070700000007770777000007070707077000000770070700700070070700000
07000000070070007070700070707070070000007000707070700000707007007070700000000000700000007070707070000000707070700700070070700000
70000000700077707070700077007070070000007000770077000700707007007070777000000000700000007700707077707770777007700700070077000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0ee0e0e0ee00eee0eee0e0e00000eee0eee0eee00ee0eee000000000000000000000000000000000000000000000000000000000000000000000000000000000
e000e0e0e0e00e00e0e0e0e00000e000e0e0e0e0e0e0e0e000000000000000000000000000000000000000000000000000000000000000000000000000000000
eee0eee0e0e00e00eee00e000000ee00ee00ee00e0e0ee0000000000000000000000000000000000000000000000000000000000000000000000000000000000
00e000e0e0e00e00e0e0e0e00000e000e0e0e0e0e0e0e0e000000000000000000000000000000000000000000000000000000000000000000000000000000000
ee00eee0e0e00e00e0e0e0e00000eee0e0e0e0e0ee00e0e000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06606060660066606660606000006660666066600660666000006600666066606660000006000000060000000000000000000000000000000000000000000000
60006060606006006060606000006000606060606060606000006060600060606060000060000000600000000000000000000000000000000000000000000000
66606660606006006660060000006600660066006060660000006060660066606600000000006660000000000000000000000000000000000000000000000000
00600060606006006060606000006000606060606060606000006060600060606060000000000000000000000000000000000000000000000000000000000000
66006660606006006060606000006660606060606600606000006060666060606060000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70000000700077707070777007707770777000007770077007700000707077707770700000000000000000000000000000000000000000000000000000000000
07000000070070007070707070707070070000007000707070700000707007007770700000000000000000000000000000000000000000000000000000000000
00700000007077000700777070707700070000007700707070700000777007007070700000000000000000000000000000000000000000000000000000000000
07000000070070007070700070707070070000007000707070700000707007007070700000000000000000000000000000000000000000000000000000000000
70000000700077707070700077007070070000007000770077000700707007007070777000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0ee0e0e0ee00eee0eee0e0e00000eee0eee0eee00ee0eee000000000000000000000000000000000000000000000000000000000000000000000000000000000
e000e0e0e0e00e00e0e0e0e00000e000e0e0e0e0e0e0e0e000000000000000000000000000000000000000000000000000000000000000000000000000000000
eee0eee0e0e00e00eee00e000000ee00ee00ee00e0e0ee0000000000000000000000000000000000000000000000000000000000000000000000000000000000
00e000e0e0e00e00e0e0e0e00000e000e0e0e0e0e0e0e0e000000000000000000000000000000000000000000000000000000000000000000000000000000000
ee00eee0e0e00e00e0e0e0e00000eee0e0e0e0e0ee00e0e000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70000000777070707770077077707770000077700770077000007070777077707000000000007770000007707700777000007770707077707770077000000000
07000000700070707070707070700700000070007070707000007070070077707000000000007070000070707070700000007070707007000700707000000000
00700000770007007770707077000700000077007070707000007770070070707000000077707770000070707070770000007700707007000700707000000000
07000000700070707000707070700700000070007070707000007070070070707000000000007000000070707070700000007070707007000700707000000000
70000000777070707000770070700700000070007700770007007070070070707770000000007000000077007070777077707770077007000700770000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66606000666066600660666000000660666066606660606066606660000066600000600066606660666060000000666066606660066066600000000000000000
60606000600060606000600000006000606060600600606060606000000060600000600060606060600060000000600006006060600006000000000000000000
66606000660066606660660000006000666066600600606066006600000066600000600066606600660060000000660006006600666006000000000000000000
60006000600060600060600000006000606060000600606060606000000060600000600060606060600060000000600006006060006006000000000000000000
60006660666060606600666000000660606060000600066060606660000060600000666060606660666066600000600066606060660006000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70000000777070707770077077707770000077700770077000007070777077707000000077707770077077700000707077707770700000000000000000000555
07000000700070707070707070700700000070007070707000007070070077707000000007007000700007000000707007007770700000000000000000000555
00700000770007007770707077000700000077007070707000007770070070707000000007007700777007000000777007007070700000000000000000000555
07000000700070707000707070700700000070007070707000007070070070707000000007007000007007000000707007007070700000000000000000000555
70000000777070707000770070700700000070007700770007007070070070707770000007007770770007000700707007007070777000000000000000000fff
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000fff
66606000666066600660666000000660666066606660606066606660000066600000600066606660666060000000666066606660066066600000000000000000
60606000600060606000600000006000606060600600606060606000000060600000600060606060600060000000600006006060600006000000000000000000
66606000660066606660660000006000666066600600606066006600000066600000600066606600660060000000660006006600666006000000000000000000
60006000600060600060600000006000606060000600606060606000000060600000600060606060600060000000600006006060006006000000000000000000
60006660666060606600666000000660606060000600066060606660000060600000666060606660666066600000600066606060660006000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70000000777070707770077077707770000070007700707077700000777077700000777077700770777000007070777077707000000000000fffffffffffffff
07000000700070707070707070700700000070007070707070000000707070700000070070007000070000007070070077707000000000000fffffffffffffff
00700000770007007770707077000700000070007070777077700000777077700000070077007770070000007770070070707000000000000fffffffffffffff
07000000700070707000707070700700000070007070007000700000700070700000070070000070070000007070070070707000000000000fffffffffffffff
70000000777070707000770070700700000077707770007077700700700077700000070077707700070007007070070070707770000000000fffffffffffffff
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000fffffffffffffff
66606000666066600660666000000660666066606660606066606660000066600000600066606660666060000000666066606660066066600000000000000000
60606000600060606000600000006000606060600600606060606000000060600000600060606060600060000000600006006060600006000000000000000000
66606000660066606660660000006000666066600600606066006600000066600000600066606600660060000000660006006600666006000000000000000000
60006000600060600060600000006000606060000600606060606000000060600000600060606060600060000000600006006060006006000000000000000000
60006660666060606600666000000660606060000600066060606660000060600000666060606660666066600000600066606060660006000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70000000077077707070777000007000770070707770000077707770000077707700077000000555ffffffffffffffffffffffffffffffff55555555ffffffff
07000000700070707070700000007000707070707000000070707070000070707070700000000555ffffffffffffffffffffffffffffffff55555555ffffffff
00700000777077707070770000007000707077707770000077707770000077707070700000000555ffffffffffffffffffffffffffffffff55555555ffffffff
07000000007070707770700000007000707000700070000070007070000070007070707000000555ffffffffffffffffffffffffffffffff55555555ffffffff
70000000770070700700777000007770777000707770070070007770070070007070777000000fffffffffffffffffff55555555ffffffffffffffffffffffff
00000000000000000000000000000000000000000000000000000000000000000000000000000fffffffffffffffffff55555555ffffffffffffffffffffffff
90909990999099009990990009900000000090009990999099909000000099900990000099909000999099009090000000000000000000000000000000000000
90909090909090900900909090000900000090009090909090009000000009009000000090909000909090909090000000000000000000000000000000000000
90909990990090900900909090000000000090009990990099009000000009009990000099009000999090909900000000000000000000000000000000000000
99909090909090900900909090900900000090009090909090009000000009000090000090909000909090909090000000000000000000000000000000000000
99909090909090909990909099900000000099909090999099909990000099909900000099909990909090909090000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aaa0a0a0aa0000000aa0aaa0aaa0aaa00000aaa0aa00aa000000a0a00aa0aaa00000aaa0aaa00000aaa00aa000000aa0aaa0aaa0aaa0a0a0aaa0aaa000000000
a0a0a0a0a0a00000a000a0a0a0a00a000000a0a0a0a0a0a00000a0a0a000a0000000a00000a000000a00a0a00000a000a0a0a0a00a00a0a0a0a0a00000000000
aa00a0a0a0a00000a000aaa0aa000a000000aaa0a0a0a0a00000a0a0aaa0aa000000aa0000a000000a00a0a00000a000aaa0aaa00a00a0a0aa00aa0000000000
a0a0a0a0a0a00000a000a0a0a0a00a000000a0a0a0a0a0a00000a0a000a0a0000000a00000a000000a00a0a00000a000a0a0a0000a00a0a0a0a0a00000000000
a0a00aa0a0a000000aa0a0a0a0a00a000000a0a0a0a0aaa000000aa0aa00aaa00000a00000a000000a00aa0000000aa0a0a0a0000a000aa0a0a0aaa000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06606660606066606600000060006600606066600000666066600000666066000660000000000000000000000000000000000000000000000000000000000000
60006060606060006060000060006060606060000000606060600000606060606000000000000000000000000000000000000000000000000000000000000000
66606660606066006060000060006060666066600000666066600000666060606000000000000000000000000000000000000000000000000000000000000000
00606060666060006060000060006060006000600000600060600000600060606060000000000000000000000000000000000000000000000000000000000000
66006060060066606660000066606660006066600600600066600600600060606660000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__gff__
0000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0202020202020202020202020201010102010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020102020102020102020201010102010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202010102010102010102010201010102010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201010101010101010101010101010102010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201010201010101010101010101010102010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201010201010101010201010101010102010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201010101010101010101010101010102010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201010101010101010101010101010102010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201020201010101010202020202020102010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201020202020201010201010101010102010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201010101010101010202010202020202010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201010101010101010201010101010102010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010202020202010102010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010201010101020102010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010201010102010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

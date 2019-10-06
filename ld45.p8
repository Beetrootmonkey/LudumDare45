pico-8 cartridge // http://www.pico-8.com
version 18
__lua__


left,right,up,down,fire1,fire2=0,1,2,3,4,5
black,dark_blue,dark_purple,dark_green,brown,dark_gray,light_gray,white,red,orange,yellow,green,blue,indigo,pink,peach=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

mapH = 127
mapW = 127

visibleTiles={}

function getKeyFromPos(pos)
 return pos.x .. " " .. pos.y
end

function isTileVisible(pos)
 return visibleTiles[getKeyFromPos(pos)] == true
end

function revealTile(pos, level)
 local tile = mget(pos.x, pos.y)
 if tile == nil then
  return
 end

 local lvl = 0
 if fget(tile, 1) then lvl += 1 end
 if fget(tile, 2) then lvl += 2 end

 if level >= lvl then
  visibleTiles[getKeyFromPos(pos)] = true
  if tile >= 64 and tile < 128 then
   printh("tile:" .. tile .. "->" .. tile + 16 * (level - lvl))
   printh("level:" .. lvl)
   mset(pos.x, pos.y, tile + 16 * (level - lvl))
  end
 end
end

function createPlayer()
 return {
  x=36,
  y=36,
  speed=1,
  ammo=0,
  lastMoveSfx = 0,
  move=function(self, newPos)
   self.x = newPos.x
   self.y = newPos.y

   if(t() - 0.15 > self.lastMoveSfx) then
    self.lastMoveSfx = t()
    sfx(0)
   end
  end,
  canMove=function(self, newPos)
   for i=1,#self.collisionBox do
    local coord = self.collisionBox[i]
    local tile = mget((newPos.x + coord.x) / 8, (newPos.y + coord.y) / 8)
    local isWall = fget(tile, 0) --TRUE auf Flag 0 bedeutet WAND
    if isWall then return false end
   end
   return true
  end,
  tryMove=function(self, newPos)
   if self:canMove(newPos) then self:move(newPos) end
  end,
  getDirection=function(self)
   local dir = {x=0,y=0}
   local isWalking = false
   if btn(left) then
   dir.x = -1
   self.lookingRight = false
   isWalking = true
   elseif btn(right) then
    dir.x = 1
    self.lookingRight = true
    isWalking = true
   end
   if btn(up) then
    dir.y = -1
    self.lookingDown = false
    isWalking = true
   elseif btn( down) then
    dir.y = 1
    self.lookingDown = true
    isWalking = true
   end

   if isWalking then
    self.walking += 0.5
    self.walking %= 4
   else
    self.walking = 0
   end

   return dir
  end,
  onCollision=function(self, other) end,
  update=function(self, newPos)
     local dir = self:getDirection()
     if not(dir.x == 0 and dir.y == 0) then
      self.direction = dir

      for i=1,self.speed do
       local newPos = {x=self.x+dir.x, y=self.y+dir.y}
       local newPosX = {x=self.x+dir.x, y=self.y}
       local newPosY = {x=self.x, y=self.y+dir.y}

       if not self:canMove(newPos) then
        self:onCollision()
       end
       if self:canMove(newPos) then
        self:move(newPos)
       elseif self:canMove(newPosX) and dir.x ~= 0 then
        self:move(newPosX)
       elseif self:canMove(newPosY) and dir.y ~= 0 then
        self:move(newPosY)
       else
        break
       end

       local item = items[getKeyFromPos({x=flr(newPos.x / 8),y=flr(newPos.y / 8)})]
       if item ~= nil and item ~= 0 then
        item:onCollision(self)
       end
      end
     end
  end,
  offset={x=-3,y=-5},
  draw=function(self)

  if self.lookingRight then
   if self.lookingDown then
    spr(21 + flr(self.walking), self.x + self.offset.x, self.y + self.offset.y)
   else
    spr(37 + flr(self.walking), self.x + self.offset.x, self.y + self.offset.y)
   end
  else
   if self.lookingDown then
    spr(21 + flr(self.walking), self.x + self.offset.x - 1, self.y + self.offset.y, 1, 1, true)
   else
    spr(37 + flr(self.walking), self.x + self.offset.x - 1, self.y + self.offset.y, 1, 1, true)
   end
  end

   -- pset(self.x, self.y, red)
   -- for i=1,#self.collisionBox do
   --  local coord = self.collisionBox[i]
   --  pset(self.x + coord.x, self.y + coord.y, white)
   -- end
   -- for i=1,3 do
   --  pset(self.x + self.direction.x * i, self.y + self.direction.y * i, green)
   -- end
  end,
  collisionBox={
   {x=-2, y=-2},
   {x= 2, y=-2},
   {x=-2, y= 2},
   {x= 2, y= 2}
  },
  direction={x=0,y=1},
  lookingRight=true,
  lookingDown=true,
  walking=0,
  level=0
 }
end

function createProjectile(x, y, dir, level)
 local projectile = createPlayer()
 projectile.x = x
 projectile.y = y
 projectile.isAlive = true
 projectile.speed = 2
 projectile.spawnPoint = {x=x,y=y}
 projectile.level = level
 projectile.collisionBox={
  {x=-1, y=-1},
  {x= 1, y=-1},
  {x=-1, y= 1},
  {x= 1, y= 1}
 }
 projectile.onCollision=function(self)
  for i=-1,1 do
   for j=-1,1 do
    local tilePos = {x=flr(projectile.x/8) + i, y=flr(projectile.y/8) + j}
    revealTile(tilePos, self.level)
   end
  end
  projectile.isAlive = false
  sfx(1)
 end
 projectile.move=function(self, newPos)
  self.x = newPos.x
  self.y = newPos.y
 end
 projectile.update=function(self, newPos)
  local range = 2 --Reichweite in Tiles
  if abs(self.x - self.spawnPoint.x) > range * 8 or abs(self.y - self.spawnPoint.y) > range * 8 then
   self.isAlive = false
   sfx(1)
   self:onCollision()
   return
  end

    local dir = self:getDirection()
    if not(dir.x == 0 and dir.y == 0) then
     self.direction = dir

     for i=1,self.speed do
      local newPos = {x=self.x+dir.x, y=self.y+dir.y}
      local newPosX = {x=self.x+dir.x, y=self.y}
      local newPosY = {x=self.x, y=self.y+dir.y}

      -- local tilePos = {x=flr(self.x/8), y=flr(self.y/8)}
      -- revealTile(tilePos, self.level)

      if not self:canMove(newPos) then
       self:onCollision()
      end
      if self:canMove(newPos) then
       self:move(newPos)
      elseif self:canMove(newPosX) and dir.x ~= 0 then
       self:move(newPosX)
      elseif self:canMove(newPosY) and dir.y ~= 0 then
       self:move(newPosY)
      else
       break
      end
     end
    end
 end
 projectile.draw=function(self)
  local color = blue
  if self.level == 1 then
   color = green
  elseif self.level == 2 then
   color = red
  elseif self.level == 3 then
   color = yellow
  end
  rectfill(self.x - 1, self.y - 1, self.x + 1, self.y + 1, color)
  -- for i=1,#self.collisionBox do
  --  local coord = self.collisionBox[i]
  --  pset(self.x + coord.x, self.y + coord.y, white)
  -- end
  -- for i=1,3 do
  --  pset(self.x + self.direction.x * i, self.y + self.direction.y * i, green)
  -- end
 end
 projectile.direction = {x=dir.x,y=dir.y}
 projectile.getDirection=function(self)
  return self.direction
 end
 projectiles[#projectiles + 1] = projectile
end

function createPowerup(x, y, level)
 local item = {
  x=x,
  y=y,
  isAlive=true,
  level=level,
  onCollision=function(self, other)
   if self.level > other.level then other.level = self.level end
   self.isAlive = false
   other.ammo += 10
   sfx(1)
  end,
  draw=function(self)
   spr(48 + self.level, self.x * 8, self.y * 8)
  end
 }
 items[getKeyFromPos({x=item.x,y=item.y})] = item
end

function _init()
 p=createPlayer()
 projectiles={}
 items={}
 for j=0, mapH-1 do
  for i=0, mapW-1 do
   local tile = mget(i, j)
   if tile == 0 then
    mset(i, j, 71)
   elseif tile >= 48 and tile <= 52 then
    createPowerup(i, j, tile - 48)
    mset(i, j, 71)
   end
  end
 end
end

function _update()

 camera(p.x - 64, p.y - 64)

  p:update()
  for i=1,#projectiles do
   local projectile = projectiles[i]
   if (projectile ~= 0) then
    projectile:update()
    if not projectile.isAlive then
     projectiles[i] = 0
    end
   end
  end

  local key, value = next(items)
  while value do
   if value ~= 0 and not value.isAlive then
    items[key] = 0
   end
   key, value = next(items, key)
  end

  if btnp(fire1) and p.ammo > 0 then
   p.ammo -= 1
   createProjectile(p.x, p.y, p.direction, p.level)
  end
end

function _draw()
 cls()
 map(0,0,0,0,mapH,mapW)

cameraX=peek(0x5f28)+peek(0x5f29)*256
cameraY=peek(0x5f2a)+peek(0x5f2b)*256

-- rect(cameraX, cameraY, cameraX + 128, cameraY + 128, green)

for j=flr((cameraY) / 8), flr((cameraY + 128) / 8) do
 for i=flr((cameraX) / 8), flr((cameraX + 128) / 8) do
  local x,y = i * 8, j * 8
  if not isTileVisible({x=i,y=j}) then
   rectfill(x, y, x + 7, y + 7, white)
  end
  local item = items[getKeyFromPos({x=i,y=j})]
  if item ~= nil and item ~= 0 then item:draw() end
 end
end

--map(16,0,0,0,mapH,mapW)

 p:draw()
 for i=1,#projectiles do
  local projectile = projectiles[i]
   if (projectile ~= 0) then projectile:draw() end
 end

 print("ammo:" .. p.ammo, cameraX, cameraY, green)
 print("level:" .. p.level, cameraX, cameraY + 6, green)
end


__gfx__
50000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
50000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000ffff0000ffff0000ffff0000ffff0000ffff00000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000004f1f10004f1f10004f1f10004f1f10004f1f100000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000004dfff0004dfff0004dfff0004dfff0004dfff00000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000dfff000dffffd000dfff0000fdff0000dfff00000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000010010000100000000001000000010000100000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000ffff0000ffff0000ffff0000ffff0000ffff00000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000044ff000044ff000044ff000044ff000044ff00000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000044fd000044fd000044fd000044fd000044fd00000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000fffd0000ffdf0000fffd0000ffffd000fffd00000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000010010000100000000001000000010000100000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00dddd0000dddd0000dddd0000dddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d1111d00d3333d00d2222d00d9999d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0dd11cd00dd33bd00dd22ed00dd99ad0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d6dccd00d6dbbd00d6deed00d6daad0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d66c6d00d66b6d00d66e6d00d66a6d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d6666d00d6666d00d6666d00d6666d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00dddd0000dddd0000dddd0000dddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1ccccccc5c5555d0cccccccc0000001c00000000c1100000555555d0111111110000000000000000000000000000000000000000000000000000000000000000
1ccccccc5dddcdc0111111110000011c00000000c10000005d1111d0111111110000000000000000000000000000000000000000000000000000000000000000
1ccccccc5cdcddd0010101010000001c00000000c1100000511cc110111111110000000000000000000000000000000000000000000000000000000000000000
1111111100cccc00000000000000011c00000000c100000001cccc10111111110000000000000000000000000000000000000000000000000000000000000000
ccc1ccccc55cc555000000000000001c00000000c110000051111115111111110000000000000000000000000000000000000000000000000000000000000000
ccc1ccccdcc05cdd000000000000011c10101010c1000000d111551d111111110000000000000000000000000000000000000000000000000000000000000000
ccc1ccccddc05ddd000000000000001c11111111c1100000d111511d111111110000000000000000000000000000000000000000000000000000000000000000
1111111100000000000000000000011cccccccccc100000001111110111111110000000000000000000000000000000000000000000000000000000000000000
3bbbbbbb5b5555d0bbbbbbbb0000003b00000000b3300000555555d0333333330000000000000000000000000000000000000000000000000000000000000000
3bbbbbbb5dddbdb0333333330000033b00000000b30000005d3333d0333333330000000000000000000000000000000000000000000000000000000000000000
3bbbbbbb5bdbddd0030303030000003b00000000b3300000533bb330333333330000000000000000000000000000000000000000000000000000000000000000
3333333300bbbb00000000000000033b00000000b300000003bbbb30333333330000000000000000000000000000000000000000000000000000000000000000
bbb3bbbbb55bb555000000000000003b00000000b330000053333335333333330000000000000000000000000000000000000000000000000000000000000000
bbb3bbbbdbb05bdd000000000000033b30303030b3000000d333553d333333330000000000000000000000000000000000000000000000000000000000000000
bbb3bbbbddb05ddd000000000000003b33333333b3300000d333533d333333330000000000000000000000000000000000000000000000000000000000000000
3333333300000000000000000000033bbbbbbbbbb300000003333330333333330000000000000000000000000000000000000000000000000000000000000000
2eeeeeee5e5555d0eeeeeeee0000002e00000000e2200000555555d0222222220000000000000000000000000000000000000000000000000000000000000000
2eeeeeee5dddede0222222220000022e00000000e20000005d2222d0222222220000000000000000000000000000000000000000000000000000000000000000
2eeeeeee5ededdd0020202020000002e00000000e2200000522ee220222222220000000000000000000000000000000000000000000000000000000000000000
2222222200eeee00000000000000022e00000000e200000002eeee20222222220000000000000000000000000000000000000000000000000000000000000000
eee2eeeee55ee555000000000000002e00000000e220000052222225222222220000000000000000000000000000000000000000000000000000000000000000
eee2eeeedee05edd000000000000022e20202020e2000000d222552d222222220000000000000000000000000000000000000000000000000000000000000000
eee2eeeedde05ddd000000000000002e22222222e2200000d222522d222222220000000000000000000000000000000000000000000000000000000000000000
2222222200000000000000000000022eeeeeeeeee200000002222220222222220000000000000000000000000000000000000000000000000000000000000000
9aaaaaaa5a5555d0aaaaaaaa0000009a00000000a9900000555555d0999999990000000000000000000000000000000000000000000000000000000000000000
9aaaaaaa5dddada0999999990000099a00000000a90000005d9999d0999999990000000000000000000000000000000000000000000000000000000000000000
9aaaaaaa5adaddd0090909090000009a00000000a9900000599aa990999999990000000000000000000000000000000000000000000000000000000000000000
9999999900aaaa00000000000000099a00000000a900000009aaaa90999999990000000000000000000000000000000000000000000000000000000000000000
aaa9aaaaa55aa555000000000000009a00000000a990000059999995999999990000000000000000000000000000000000000000000000000000000000000000
aaa9aaaadaa05add000000000000099a90909090a9000000d999559d999999990000000000000000000000000000000000000000000000000000000000000000
aaa9aaaadda05ddd000000000000009a99999999a9900000d999599d999999990000000000000000000000000000000000000000000000000000000000000000
9999999900000000000000000000099aaaaaaaaaa900000009999990999999990000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010101010101000000000000000000030303030303030200000000000000000505050505050504000000000000000007070707070707060000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
4040404040404040404050505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404040404000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4000000000000000000000005050505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4000300031003200330000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7070000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7070700000000000000000006060606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7070707000000000000000006060606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7070707070707000000000606060606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7070707070707070606060606060606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010100000102000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001d6101d6101c6201c6201c6201c6201962019620176201561012610106100f6100b610086100760004600026000160000600086000860008600076000760006600016000060000000000000000000000
0010002016005020051200503003050050b0030200512003040050c00307005020030c005100030800503003000050e003080050400303005090030300509003020050a00304005050030500505003050051a003
__music__
03 02424344


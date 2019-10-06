pico-8 cartridge // http://www.pico-8.com
version 18
__lua__


left,right,up,down,fire1,fire2=0,1,2,3,4,5
black,dark_blue,dark_purple,dark_green,brown,dark_gray,light_gray,white,red,orange,yellow,green,blue,indigo,pink,peach=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

mapH = 127
mapW = 127

function isTileVisible(pos)
 return not mget(pos.x + 16, pos.y) == 3
end

function revealTile(pos)
 mset(pos.x + 16, pos.y, 0)
end

function createPlayer()
 return {
  x=36,
  y=36,
  speed=1,
  move=function(self, newPos)
   self.x = newPos.x
   self.y = newPos.y
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
   if btn(left) then
   dir.x = -1
   self.lookingRight = false
   elseif btn(right) then
    dir.x = 1
    self.lookingRight = true
   end
   if btn(up) then
    dir.y = -1
    self.lookingDown = false
   elseif btn( down) then
    dir.y = 1
    self.lookingDown = true
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
        self.walking += 0.5
       elseif self:canMove(newPosX) then
        self:move(newPosX)
        self.walking += 0.5
       elseif self:canMove(newPosY) then
        self:move(newPosY)
        self.walking += 0.5
       else
       self.walking = 0
        break
       end
       self.walking %= 4
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
   print(self.x .. " " .. self.y,0,0,7)
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
  walking=0
 }
end

function createProjectile(x, y, dir)
 local projectile = createPlayer()
 projectile.x = x
 projectile.y = y
 projectile.isAlive = true
 projectile.speed = 2
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
    revealTile(tilePos)
   end
  end
  projectile.isAlive = false
 end
 projectile.draw=function(self)
  rectfill(self.x - 1, self.y - 1, self.x + 1, self.y + 1, red)
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

p=createPlayer()
projectiles={}



function _init()

end

function _update()

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

  if btnp(fire1) then
   createProjectile(p.x, p.y, p.direction)
  end
end

function _draw()
  cls()
  map(0,0,0,0,mapH,mapW)
  map(16,0,0,0,mapH,mapW)

  p:draw()
  for i=1,#projectiles do
   local projectile = projectiles[i]
    if (projectile ~= 0) then projectile:draw() end
  end
  local count = 0
  for i=1,#projectiles do
   local projectile = projectiles[i]
    if (projectile ~= 0) then count+=1 end
  end
  local countAlive = 0
  for i=1,#projectiles do
   local projectile = projectiles[i]
    if (projectile ~= 0 and projectile.isAlive) then countAlive+=1 end
  end
  local countDead = 0
  for i=1,#projectiles do
   local projectile = projectiles[i]
    if (projectile ~= 0 and not projectile.isAlive) then countDead+=1 end
  end
  -- print("total:" .. count,0,6,7)
  -- print("size: " .. #projectiles,0,12,7)
  -- print("alive:" .. countAlive,0,18,7)
  -- print("dead: " .. countDead,0,24,7)
end


__gfx__
50000005ffffffff5555555511111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ffffffff5555555511111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ffffffff5555555511111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ffffffff5555555511111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ffffffff5555555511111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ffffffff5555555511111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ffffffff5555555511111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
50000005ffffffff5555555511111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
__gff__
0000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0202020202020202020202020202020203030303030303030303030303030303010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020102020102020102020201010203030303030303030303030303030303010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202010102010102010102010201010203030303030303030303030303030303010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201010101010101010101010101010203030303030303030303030303030303010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201010201010101010101010101010203030303030303030303030303030303010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201010201010101010201010101010203030303030303030303030303030303010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201010101010101010101010101010203030303030303030303030303030303010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201010101010101010101010101010203030303030303030303030303030303010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201020201010101010202020202010203030303030303030303030303030303010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201020202020201010201010101010203030303030303030303030303030303010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201010101010101010202010202020203030303030303030303030303030303010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201010101010101010201010101010203030303030303030303030303030303010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201010101010101010202020202010203030303030303030303030303030303010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201010101010101010201010101010203030303030303030303030303030303010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201010101010101010101020202010203030303030303030303030303030303010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020203030303030303030303030303030303010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

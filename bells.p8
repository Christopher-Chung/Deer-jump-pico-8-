pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

function _init()
 palt(0,false)
 palt(5,true)
 size = 8
 highscore = 0
 numbells = 10
 reset()
end

function reset()
 velx = 0
 vely = 0
 is_launched = false
 dead = false
 deerx = 50
 deery = 95
 deadt = 0
 scrolly = 0
 difference = 0
 lastpos = 0
 jumpt = 0
 jump = false
 used = {}
 snows = {}
 for i=1,6 do
  snows[i] = generatesnow()
 end
 bells = generatebells()
 score = 0
 drawscore()
end

function generatebells()
 local bl = {}
 bl[1] = make_bell(rnd(128 - 16),65+rnd(4))
 used[1] = true
 for i = 2,numbells do
  local loc = bl[i-1].x - 50 + rnd(100)
  while (loc <= 0 or loc >= 112) do
   loc = bl[i-1].x - 50 + rnd(100)
  end
  bl[i] = make_bell(loc,100 - (35*i+rnd(4)))
  used[i] = true
 end
 lastpos = numbells
 return bl
end

function make_bell(absx,absy)
	local b = {}
	b.x = absx
 b.y = absy
	return b
end

function drawbell()
 for i = 1,numbells do
  if (bells[i].y <= scrolly + 128 and bells[i].y >= scrolly and used[i]) then
   spr(19,bells[i].x,bells[i].y-scrolly,2,2)
  end
 end
end

function drawcloud()
 sspr(40,8,24,16,40,7,66,44)
 sspr(40,8,24,16,0,5,63,42)
 sspr(40,8,24,16,70,6,57,35)
end

function _draw()
 cls(7)
 rectfill(0,0,128,128,12)
 drawcloud()
 for i=1,6 do
  circfill(snows[i].x,snows[i].y,2,7)
 end
 drawbell()
 drawscore()
 if (dead and deadt > 50) then
  print("press z to restart",30,30,1)
 else
  if jump then
   spr(24,deerx-8, deery-8,2,2,velx>0 or deerx==128-size,false)
  else
   spr(17, deerx-8, deery-8,2,2,velx>0 or deerx==128-size,false)
  end
  if (not is_launched) then
   print("press z to launch",32,30,1)
  end
 end
end

function updatebell()
 if jump then
  jumpt += 1
 end
 if (jumpt >= 18 and jump) then
  jump = false
 end
 for i = 1,numbells do
  if (bells[i].y > scrolly + 128 or not used[i]) then
   local loc = bells[lastpos].x - 50 + rnd(100)
   while (loc <= 0 or loc >= 112) do
    loc = bells[lastpos].x - 50 + rnd(100)
   end
   bells[i] = make_bell(loc,bells[lastpos].y-35+rnd(4))
   used[i] = true
   lastpos = i
  end
 end
end

function contact(p)
 local realy = bells[p].y-scrolly
 local realx = bells[p].x
 if abs(deery-realy) >= 13 then return false
 end
 if abs(deerx-realx) >= 12 then return false
 end
 return true
end

function _update60()
 updatesnows()
 if (dead) then
  deadt+=1
  if (btnp(4) and deadt > 50) then
   reset()
   dead=false
  end
 else
  updatebell()
  if deerx+velx < size then
   velx = 0
   deerx = size
  elseif deerx+velx > 128-size then
   velx = 0
   deerx = 128-size
  else
   deerx += velx
  end

  if (is_launched) then

   if deery+vely < 98 then
    difference = deery + vely-98
    scrolly += difference
    score = flr(-scrolly/10)
    deery = 98
   end

   if deery+vely > 128+size then
    --die
    sfx(0)
    highscore = max(flr(-scrolly/10),highscore)
    dead = true

   else
    deery += vely
   end

   --contact will bells
   for i=1,numbells do
    if (contact(i) and used[i]) then
     jumpt = 0
     jump = true
     sfx(1)
     used[i] = false
     vely -= 0.4
     if vely <= -1 then
      vely = -1
     end
    end
   end

   --gravity
   vely += 0.01

  else
   if (btnp(4)) then
    jumpt = 0
    jump = true
    is_launched = true
    vely -= 0.8
   end
  end

  if (btnp(0)) then
   velx = 0.1*velx-0.8
  end

  if (btnp(1)) then
   velx = 0.1*velx+0.8
  end
 end
end

function drawscore()
 rectfill(55,0,128,10,14)
 rectfill(0,0,55,10,15)
 print("high score: "..highscore,60,3,11)
 print("score: "..score,8,3,2)
end

function generatesnow()
 local snw = {}
 if (rnd(1) > 0.5) then
  snw.x=0
  snw.vx=rnd(0.8)
 else
  snw.x=128
  snw.vx=rnd(0.5)-0.5
 end
 snw.y=rnd(70)
 snw.vy=rnd(0.9)+0.2
 return snw
end

function updatesnows()
 for i= 1,6 do
  local snw = snows[i]
  snw.x+=snw.vx
  snw.y+=snw.vy
  if (snw.x <= 0 or snw.y >= 128) then
   snows[i] = generatesnow()
  end
 end
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000555555555555555555555555555555555555555555555555555555555555555555555555000000000000000000000000000000000000000000000000
00000000555555555555555555555559955555555555555555555555555555555555555555555555000000000000000000000000000000000000000000000000
0000000099555995555555555555599aa99555555555555555555555555555559955599555555555000000000000000000000000000000000000000000000000
00000000999999955555555555599aaaaaa995555555555577777555555555559999999555555555000000000000000000000000000000000000000000000000
000000005509055555555555559aaaaaaaaaa9555555557766666775557755555509055555555555000000000000000000000000000000000000000000000000
000000005599955555599555559aaaaaaaaaa9555555577666666667776677555599955555599555000000000000000000000000000000000000000000000000
000000005540999999994555559aaaaaaaaaa9555566767666666666666667555540999999994555000000000000000000000000000000000000000000000000
000000005554999999995555559aaaaaaaaaa9555566667666666666666666655554999999995555000000000000000000000000000000000000000000000000
000000005554999999995555559aaaaaaaaaa9555666666666666666666666555554999999995555000000000000000000000000000000000000000000000000
00000000555499444499555559aaaaaaaaaaaa955556666666666666666655555554994444995555000000000000000000000000000000000000000000000000
00000000554995555449955559aaaaaaaaaaaa955555566666666666666655555549955554499555000000000000000000000000000000000000000000000000
00000000555499905544955559aaaaaaaaaaaa955555555666666655655555555549555555449555000000000000000000000000000000000000000000000000
0000000055554055509955559aaaaaaaaaaaaaa95555555555555555555555555499555555549555000000000000000000000000000000000000000000000000
0000000055555555554555559aaaaaaaaaaaaaa95555555555555555555555555095555555509555000000000000000000000000000000000000000000000000
000000005555555550555555599aaaaaaaaaa9955555555555555555555555555505555555550555000000000000000000000000000000000000000000000000
00000000555555555555555555599999999995555555555555555555555555555555555555555555000000000000000000000000000000000000000000000000
__sfx__
010d000032051300512e0512d0512b051290512605123051200511f05100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010600001d05021050240550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

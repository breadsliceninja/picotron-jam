--[[pod_format="raw",created="2024-03-24 00:48:06",modified="2026-02-07 02:03:39",revision=62]]
-- testing
function _init()
	player = {
		x = 16*4,
		y = 16*4,
		sx = 0,
		sy = 0,
		smax = 5
	}
	-- acceleration
	a = 0.03
end

function _update()
	-- called each frame (60 times)
	
	-- left
	if btn(0) then
		player.sx -= a
		player.x -= 1 
	end
	-- right
	if btn(1) then
		player.x += 1
		player.sx += a
	end
	-- up
	if btn(2) then
		player.sy -= a
--		player.y -= 1
	end
	-- down
	if btn(3) then
		player.sy += a
	end
	
	if not (
		btn(0) or
		btn(1) or
		btn(2) or
		btn(3)
		)
	 then
	 -- 0.95 for that luigi wavedash feel
		player.sx *= 0.9
		player.sy *= 0.5
	end
	
	player.x += mid(-player.smax, player.sx, player.smax)
	
end

function _draw()
	-- draw graphics teehee
	-- each tile is 16x16
	cls()
	map()
	spr(1,player.x, player.y)
	
end
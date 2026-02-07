--[[pod_format="raw",created="2024-03-24 00:48:06",modified="2026-02-07 03:42:31",revision=125]]
-- testing
include "movement.lua"
function _init()
	poke(0x5f5c, 255) -- diasable key repeat
	p = {
		x = 16*4,
		y = 16*4,
		sx = 0,
		sy = 0,
		smax = 3
	}
	-- acceleration
	a = 0.3
end

function _update()
	-- called each frame (60 times)
	move_player()
	
end

function _draw()
	-- draw graphics teehee
	-- each tile is 16x16
	cls()
	map()
	spr(9,p.x, p.y)
	
end
--[[pod_format="raw",created="2024-03-24 00:48:06",modified="2026-02-07 07:36:10",revision=151]]
-- testing
include "movement.lua"
include "math.lua"
function _init()
	poke(0x5f5c, 255) -- diasable key repeat
	p = {
		x = 16*4,
		y = 16*4,
		vx = 0,
		vy = 0,
		smax = 3,
		width = 32,
		height = 32,
		-- x and y offsets
		x_off = 4,
		y_off = 4
	}
	-- box
	b = {
		x = 16*8,
		y = 16*8,
		width = 32,
		height = 32
	}
	-- collision blocks
	c = {4,}
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
	print(math.floor(p.x), p.x, p.y-16)
	print(math.floor(p.y), p.x+16, p.y-16)

	spr(12,b.x, b.y)
	print(math.floor(b.x), b.x, b.y-16)
	print(math.floor(b.y), b.x+16, b.y-16)

end
--[[pod_format="raw",created="2024-03-24 00:48:06",modified="2026-02-07 10:16:18",revision=164]]
-- testing
include "movement.lua"
function _init()
	poke(0x5f5c, 255) -- diasable key repeat
	anim_dly = 14
	p = {
		x = 16*4,
		y = 16*4,
		vx = 0,
		vy = 0,
		smax = 3,
		width = 32,
		height = 32,
		x_offset = 4,
		y_offset = 4,
		facing = "down",
		anim_t = anim_dly,
		anim_alt = false,
	}
	-- collision blocks
	c = {4,}
	-- acceleration
	a = 0.3
	-- animation
	facing_sprites = {
		up = 20,
		down = 16,
		left = 18,
		right = 18,
	}
end

function _update()
	-- called each frame (60 times)
	move_player()
	
	p.anim_t -= 1
	if p.anim_t <= 0 then
		p.anim_alt = not p.anim_alt
		p.anim_t = anim_dly
	end
	
end

function _draw()
	-- draw graphics teehee
	-- each tile is 16x16
	cls()
	map()
	local p_sprite = facing_sprites[p.facing]
	if (
		p.anim_alt and 
		(btn(0) or btn(1) or btn(2) or btn(3))
	) then
		p_sprite += 1
	end
	spr(p_sprite,p.x, p.y, p.facing == "left")
	
end

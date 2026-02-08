--[[pod_format="raw",created="2024-03-24 00:48:06",modified="2026-02-08 04:11:58",revision=252]]
-- testing
include "movement.lua"
function _init()
	-- DEBUG
	show_hbox = false
	
	normal = 0
	poke(0x5f5c, 255) -- diasable key repeat
	anim_dly = 14 -- walk cycle speed
	dash_dly = 24
	dash_spd = 5
	invul_dly = 90
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
		is_dashing = false,
		dash_t = 0,
		hp = 3,
		invul_t = 0,
		hbox = {
			x = 9,
			y = 10,
			w = 13,
			h = 19,
		}
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
	-- camera
	cam = {
		offset_x = 0,
		offset_y = 0,
		target_offset_x = 0,
		target_offset_y = 0,
	}
	-- world & stairs
	world = {
		parallax_offset = 1, -- size of tile parallax offset between layers
		do_stair_climb = false, -- are we currently climbing stairs
		current_map = nil,
		previous_map = nil,
		next_map = nil
	}
	
	base_layer = fetch("map/0.map")
	next_layer = fetch("map/1.map")
	
	world.current_map = base_layer[1].bmp
	world.previous_map = nil
	world.next_map = next_layer[1].bmp
end

function calc_new_camera_bounds()
	screen_width = 480
	screen_height = 270
	
	screen_buffer_x = screen_width/4
	screen_buffer_y = screen_height/4
	
	if world.do_stair_climb then return end
	
	player_screen_pos_x = p.x + cam.offset_x
	player_screen_pos_y = p.y + cam.offset_y
	
	if player_screen_pos_x < screen_buffer_x then
		cam.target_offset_x -= player_screen_pos_x - screen_buffer_x
	end
	
	if player_screen_pos_x > screen_width - screen_buffer_x then
		cam.target_offset_x += (screen_width - screen_buffer_x) - player_screen_pos_x
	end
	
	if player_screen_pos_y < screen_buffer_y then
		cam.target_offset_y -= player_screen_pos_y - screen_buffer_y
	end
	
	if player_screen_pos_y > screen_height - screen_buffer_y then
		cam.target_offset_y += (screen_height - screen_buffer_y) - player_screen_pos_y
	end
end

function _update()
	-- called each frame (60 times)
	move_player()
	calc_new_camera_bounds()
	
	if p.anim_t > 0 then
		p.anim_t -= 1
		if p.anim_t <= 0 then
			p.anim_alt = not p.anim_alt
			p.anim_t = anim_dly
		end
	end
	
	if p.dash_t > 0 then
		p.dash_t -= 1
	end
	
	if p.invul_t > 0 then
		p.invul_t -= 1
	end
end

function math.lerp(a,b,t)
	return a + ((b - a) * t);
end

function math.clamp(n, low, high)
	return math.min(math.max(n, low), high)
end

function _draw()
	-- draw graphics teehee
	-- each tile is 16x16
	cls()
	
	-- Update camera
	cam.offset_x = math.lerp(cam.offset_x, cam.target_offset_x, 0.5)
	cam.offset_y = math.lerp(cam.offset_y, cam.target_offset_y, 0.5)
	
	if world.previous_map then
		map(world.previous_map, 0, 0,
			cam.offset_x + 0,
			cam.offset_y + world.parallax_offset * 16)
	end
	
	-- Stair climbing logic, overrides all other camera and map rendering logic
	if world.do_stair_climb then
	   start_y = 9
	   end_y = 5
	   player_progress = math.clamp((start_y - p.y/16) / (start_y - end_y), 0.0, 1.0)
		
		-- The bottom level has to move 1.x tiles for every 1 tile scrolled in order
		-- to achieve the eventual offset between the level
		overlap_scroll = 3
		new_layer_y_offset = math.lerp(0, overlap_scroll, player_progress)
		old_layer_y_offset = math.lerp(0, overlap_scroll + world.parallax_offset,
												player_progress)
		map(0, 0, cam.offset_x, cam.offset_y + old_layer_y_offset * 16)
		
		if player_progress > 0.3 then
			map(world.next_map, 0, 0,
				cam.offset_x + 0,
				cam.offset_y + new_layer_y_offset * 16)
		end
		
		if player_progress >= 1.0 then
			memmap(world.next_map, 0x100000)
			world.do_stair_climb = false
			
			-- Update maps
			world.previous_map = world.current_map
			world.current_map = world.next_map
			world.next_map = nil -- probably fix this at some point
			
			-- Update camera offset
			cam.offset_x += 0
			cam.offset_y += 16 * overlap_scroll
			cam.target_offset_x = cam.offset_x
			cam.target_offset_y = cam.offset_y
			
			-- Update player location
			p.y -= 16 * overlap_scroll
		end
	else
		-- Just render the map normally, no funny business
		map(0, 0, cam.offset_x, cam.offset_y)
	end
	
	-- Check if we are on stairs and initiate a climb
	player_center = mget((p.x + (p.width/2))/16, (p.y + (p.height/2))/16);
	if not world.do_stair_climb and player_center == 7 then
		world.do_stair_climb = true
	end
	
	-- player animation
	local p_sprite = facing_sprites[p.facing]
	if (p.is_dashing) then
		p_sprite = 25
	else
		-- set walk frame
		if (
			p.anim_alt and 
			(btn(0) or btn(1) or btn(2) or btn(3))
		) then
			p_sprite += 1
		end
	end
	if p.invul_t > 0 and p.invul_t % 30 < 8 then
--		pal(14, 6) 
		pal(21, 14)
	end
	spr(p_sprite, cam.offset_x + p.x, cam.offset_y + p.y, p.facing == "left")
	pal()
	
	-- ui
	print("HP: " .. p.hp, 10, 10, 7)
	
	-- debug
	if show_hbox then
		local x1 = p.x + p.hbox.x + cam.offset_x
		local y1 = p.y + p.hbox.y + cam.offset_y
		rect(x1, y1, x1 + p.hbox.w, y1 + p.hbox.h, 8)
	end
end

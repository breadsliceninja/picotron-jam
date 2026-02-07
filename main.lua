--[[pod_format="raw",created="2024-03-24 00:48:06",modified="2026-02-07 10:21:21",revision=264]]
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
	-- camera
	cam = {
		-- "real" offset (read from these ones)
		offset_x = 0,
		offset_y = 0,
		-- desired offset (set these ones)
		target_offset_x = 0,
		target_offset_y = 0,
	}
	
	-- world & stairs
	world = {
		do_stair_climb = false, -- are we currently climbing stairs
		stair_climb_start_y = nil,
		stair_climb_end_y = nil,
		current_map = nil,
		previous_map = nil,
		previous_previous_map = nil, -- this is dumb
		next_map = nil,
		parallax = {
			-- multiplier for parallax offset between layers
			multiplier = 0.9,
		}
	}
	
	screen_width = 480
	screen_height = 270
	
	base_layer = fetch("map/0.map")
	next_layer = fetch("map/1.map")
	layer_after = fetch("map/2.map")
	
	world.current_map = base_layer[1].bmp
	world.previous_map = nil
	world.next_map = next_layer[1].bmp
end

function calc_new_camera_bounds()	
	screen_buffer_x = screen_width/3
	screen_buffer_y = screen_height/3
	
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
	
	p.anim_t -= 1
	if p.anim_t <= 0 then
		p.anim_alt = not p.anim_alt
		p.anim_t = anim_dly
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
	
	-- Set clip to prevent drawing underlayers behind current layer
	local clip_rect_x = max(cam.offset_x, 0)
	local clip_rect_y = max(cam.offset_y, 0)
	clip(clip_rect_x, clip_rect_y, screen_width, screen_height)
	
	-- Update camera
	cam.offset_x = math.lerp(cam.offset_x, cam.target_offset_x, 0.5)
	cam.offset_y = math.lerp(cam.offset_y, cam.target_offset_y, 0.5)
	
	if world.previous_previous_map then
		map(world.previous_previous_map, 0, 0,
			cam.offset_x * world.parallax.multiplier ^ 2,
			cam.offset_y * world.parallax.multiplier ^ 2)
	end
	
	if world.previous_map then
		map(world.previous_map, 0, 0,
			cam.offset_x * world.parallax.multiplier,
			cam.offset_y * world.parallax.multiplier)
	end
	
	-- Stair climbing logic, overrides all other camera and map rendering logic
	if world.do_stair_climb then
	   local start_y = world.stair_climb_start_y
	   local end_y = world.stair_climb_end_y
	   local player_progress = math.clamp((start_y - p.y/16) / (start_y - end_y), 0.0, 1.0)
	   
	   -- The bottom level has to move 1.x tiles for every 1 tile scrolled in order
		-- to achieve the eventual offset between the level
		local overlap_scroll = 3
		
		local new_layer_y_offset = math.lerp(0, overlap_scroll, player_progress)
		local old_layer_y_offset = math.lerp(0, overlap_scroll * world.parallax.multiplier, player_progress)
		map(0, 0, cam.offset_x, cam.offset_y + old_layer_y_offset * 16)
		
		if player_progress > 0.5 then
			map(world.next_map, 0, 0,
				cam.offset_x + 0,
				cam.offset_y + new_layer_y_offset * 16)
		end
		
		if player_progress >= 1.0 then
			memmap(world.next_map, 0x100000)
			world.do_stair_climb = false
			
			-- Update maps
			world.previous_previous_map = world.previous_map
			world.previous_map = world.current_map
			world.current_map = world.next_map
			world.next_map = layer_after[1].bmp -- probably fix this at some point
			
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
	
	-- Render black borders for +5 outside the toplevel map
	
	
	-- Check if we are on stairs and initiate a climb
	player_center = mget((p.x + (p.width/2))/16, (p.y + (p.height/2))/16);
	if not world.do_stair_climb and player_center == 7 then
		world.do_stair_climb = true
		world.stair_climb_start_y = (p.y + (p.height/2))/16
		world.stair_climb_end_y = world.stair_climb_start_y - 4
	end
	
	local p_sprite = facing_sprites[p.facing]
	if (
		p.anim_alt and 
		(btn(0) or btn(1) or btn(2) or btn(3))
	) then
		p_sprite += 1
	end
	spr(p_sprite, cam.offset_x + p.x, cam.offset_y + p.y, p.facing == "left")
end

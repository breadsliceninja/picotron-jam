--[[pod_format="raw",created="2026-02-08 04:54:22",modified="2026-02-08 04:55:57",revision=4]]
include "movement.lua"
include "enemy.lua"
include "particle.lua"
include "box_detection.lua"

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
		-- x and y offsets
		x_off = 2,
		y_off = 2,
		facing = "down",
		anim_t = anim_dly,
		anim_alt = false,
		particles = {},
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
	-- box
	b = {
		x = 16*8,
		y = 16*8,
		width = 32,
		height = 32,
		-- solved is when the box is in the right place
		-- 0 for false, 1 for true
		solved = 0
	}

	-- collision blocks (TODO: use flags actually)
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
	
	level = 1
	
	-- Level 1
	fox1 = create_fox(5*16, 5*16)
	fox2 = create_fox(12*16, 12*16)
	-- Level 2
	fox3 = create_fox(7*16, 3*16)
	fox4 = create_fox(14*16, 14*16)
	fox5 = create_fox(2*16, 1*16)
	fox6 = create_fox(9*16, 11*16)
	-- Level 3
	fox7 = create_fox(1*16, 2*16)
	fox8 = create_fox(12*16, 12*16)
	fox9 = create_fox(5*16, 5*16)
	fox10 = create_fox(12*16, 12*16)
	fox11 = create_fox(5*16, 5*16)
	fox12 = create_fox(12*16, 12*16)
	
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
	detect_box_solve()
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
	
	if math.abs(p.vx) > 0.1 or math.abs(p.vy) > 0.1 then
		config = create_particle_config()
		config.x = p.x + p.x_off + (p.width/2)
		config.y = p.y + p.y_off + p.height - 4
		config.vx = -p.vx
		config.vy = -2
		config.colour = 22
		config.radius = 1
		emit_particles(p.particles, 2, config)
	end
	
	process_particles(p.particles)
	
	-- Level 1
	if level == 1 then
		process_fox(fox1)
		process_fox(fox2)
	end
	
	-- Level 2
	if level == 2 then
		process_fox(fox3)
		process_fox(fox4)
		process_fox(fox5)
		process_fox(fox6)
	end
	
	-- Level 3
	if level == 3 then
		process_fox(fox7)
		process_fox(fox8)
		process_fox(fox9)
		process_fox(fox10)
		process_fox(fox11)
		process_fox(fox12)
	end
end

function math.lerp(a,b,t)
	return a + ((b - a) * t);
end

function math.clamp(n, low, high)
	return math.min(math.max(n, low), high)
end

function draw_foxes()
		-- Level 1
	if level == 1 then
		draw_fox(fox1)
		draw_fox(fox2)
	end
	
	-- Level 2
	if level == 2 then
		draw_fox(fox3)
		draw_fox(fox4)
		draw_fox(fox5)
		draw_fox(fox6)
	end
	
	-- Level 3
	if level == 3 then
		draw_fox(fox7)
		draw_fox(fox8)
		draw_fox(fox9)
		draw_fox(fox10)
		draw_fox(fox11)
		draw_fox(fox12)
	end
end

function _draw()
	-- draw graphics teehee
	-- each tile is 16x16
	cls()

	
	local cube_coords = {
		--  Front face
    -1.0, -1.0,  1.0,
     1.0, -1.0,  1.0,
     1.0,  1.0,  1.0,
    -1.0,  1.0,  1.0,
     -- Back face
    -1.0, -1.0, -1.0,
     1.0, -1.0, -1.0,
     1.0,  1.0, -1.0,
    -1.0,  1.0, -1.0
	}
	
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
		
		draw_foxes()
		
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
			
			level += 1
			
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
		draw_foxes()
	end
	
	-- Render black borders for +5 outside the toplevel map
	
	-- Particles!!
	draw_particles(p.particles)
	
	-- Check if we are on stairs and initiate a climb
	player_center = mget((p.x + (p.width/2))/16, (p.y + (p.height/2))/16);
	if not world.do_stair_climb and player_center == 7 then
		world.do_stair_climb = true
		world.stair_climb_start_y = (p.y + (p.height/2))/16
		world.stair_climb_end_y = world.stair_climb_start_y - 4
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

	-- TODO - fix box with levels 
	spr(56,cam.offset_x + b.x, cam.offset_y + b.y)
	print(b.x,cam.offset_x + 0,cam.offset_y + 0)
	print(b.x+b.width,cam.offset_x + 0,cam.offset_y + 16)
	print(b.y,cam.offset_x + 0,cam.offset_y + 32)
	print(b.y+b.height,cam.offset_x + 0,cam.offset_y + 48)

end

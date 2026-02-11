--[[pod_format="raw",created="2026-02-08 07:38:29",modified="2026-02-11 09:29:12",revision=191]]
include "movement.lua"
include "enemy.lua"
include "particle.lua"
include "box_detection.lua"

function _init()
	-- DEBUG
	show_hbox = false	
	show_menu = true
	COLLISION_DEBUG = true
--	sfx_i,spd = 1,2
--	local addr=0x3200+(68*sfx_i)+64+1
--	poke(m em_addr,spd)

	-- sfx (for channel and sfx)
	-- note: channels
	SFX_DASH = 0
	SFX_WALL_HIT = 1
	SFX_BOX_PUSH = 2
	box_push_last_frame = false
	box_push_try = false
	box_push_try_last_frame = false

	normal = 0
	poke(0x5f5c, 255) -- diasable key repeat
	anim_dly = 14 -- walk cycle speed
	dash_dly = 24
	dash_spd = 5
	invul_dly = 90
	song = "menu"
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
		},
		push_box = false
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
	
	level_solved = 0

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
	fox1 = create_fox(22*16, 10*16)
	fox2 = create_fox(23*16, 19*16)
	-- Level 2
	fox3 = create_fox(22*16, 7 *16)
	fox4 = create_fox(13*16, 14*16)
	fox5 = create_fox(3*16, 11*16)
	fox6 = create_fox(18*16, 22*16)
	-- Level 3
	fox7 = create_fox(1*16, 2*16)
	-- Level 3
	fox8 = create_fox(23*16, 13*16)
	fox9 = create_fox(19*16, 9*16)
	fox10 = create_fox(28*16, 3*16)
	fox11 = create_fox(12*16, 0)
	fox12 = create_fox(1*16, 0)
	
	-- Level 1
	box1 = {
		x = 22*16,
		y = 4*16,
		width = 32, height = 32,
		solved = 0, on_track = 1
	}

	box2 = {
		x = 16*8,
		y = 16*25,
		width = 32, height = 32,
		solved = 0, on_track = 1
	}
	
	box3 = {
		x = 15*16,
		y = 16*16,
		width = 32, height = 32,
		solved = 0, on_track = 1
	}

	box4 = {
		x = 16*32,
		y = 16*32,
		width = 32, height = 32,
		solved = 0, on_track = 1
	}

	level1_boxes = {}
	table.insert(level1_boxes, box1)
	
	level2_boxes = {}
	table.insert(level2_boxes, box2)
	
	level3_boxes = {}
	table.insert(level3_boxes, box3)

	level4_boxes = {}
	table.insert(level4_boxes, box4)

	level_boxes = {}
	table.insert(level_boxes, level1_boxes)
	table.insert(level_boxes, level2_boxes)
	table.insert(level_boxes, level3_boxes)
	table.insert(level_boxes, level4_boxes)

	b = box1
	
	screen_width = 480
	screen_height = 270
	
	base_layer = fetch("map/0.map")
	next_layer = fetch("map/1.map")
	layer_after = fetch("map/2.map")
	final_layer = fetch("map/3.map")
	
	world.current_map = base_layer
	world.previous_map = nil
	world.next_map = next_layer
	
	local names = {
		"Ollie Hogue",
		"Matthew Jakeman",
		"Bodhi Tuladhar"
	}
	local permutations = {
		{1,2,3},
		{1,3,2},
		{2,1,3},
		{2,3,1},
		{3,2,1},
		{3,1,2}
	}
	
	math.randomseed()
	local selection = permutations[math.ceil((math.random() * 100) % 6)]
	name1 = names[selection[1]]
	name2 = names[selection[2]]
	name3 = names[selection[3]]
	
	menu_anim_counter = 0
	menu_debounce_counter = 0
	menu_particles = {}
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
	
	if show_menu then return end
	if song == "menu" then
		music(0, 1000)
		song = "level"
	end
	-- called each frame (60 times)
	move_player()
	detect_box_solve()
	calc_new_camera_bounds()
	all_boxes_solved()

	
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
		process_fox(fox7)
	end
	
	-- Level 3
	if level == 3 then
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
		draw_fox(fox7)
	end
	
	-- Level 3
	if level == 3 then
		draw_fox(fox8)
		draw_fox(fox9)
		draw_fox(fox10)
		draw_fox(fox11)
		draw_fox(fox12)
	end
end

function draw_box(box)
	spr(56,cam.offset_x + box.x, cam.offset_y + box.y)
	if b.solved == 1 then
		spr(40, cam.offset_x + box.x + 8, cam.offset_y + box.y - 20)
	end
end


function draw_boxes()
	for i = 1,#level_boxes[level] do
		draw_box(level_boxes[level][i])
	end
end
function _draw()
	-- draw graphics teehee
	-- each tile is 16x16
	cls()
	
	if show_menu then
		menu_anim_counter += 1
		menu_debounce_counter += 1
		
		SCENE_1 = 1600
		SCENE_1_CHECK_1 = 120
		SCENE_1_CHECK_2 = 400
		SCENE_1_CHECK_3 = 700
		SCENE_2 = 2000
		
		if menu_anim_counter < SCENE_1 then
			cls(21)
			print("A small rabbit goes on a quest...", 160, 40, 7)
			
			rectfill(40, 60, screen_width - 40, 140, 0)
			
			if menu_anim_counter < SCENE_1_CHECK_1 then
				local rabbit_sprite_idx = ((menu_anim_counter % 32) > 16) and 18 or 19
				spr(rabbit_sprite_idx, 120, 90)
			elseif menu_anim_counter > SCENE_1_CHECK_1 and menu_anim_counter < SCENE_1_CHECK_2 then
				local rabbit_sprite_idx = ((menu_anim_counter % 32) > 16) and 16 or 17
				spr(rabbit_sprite_idx, 120, 90)
				
				local fox_sprite_idx = ((menu_anim_counter % 64) > 32) and 22 or 23
				spr(fox_sprite_idx, 340, 80, true)
			elseif menu_anim_counter > SCENE_1_CHECK_2 then
				
				x_time = (menu_anim_counter - SCENE_1_CHECK_2)/(SCENE_1_CHECK_3 - SCENE_1_CHECK_2)
				x_progress = math.lerp(0, 100, math.min(x_time, 1.0))
				
				if menu_anim_counter < SCENE_1_CHECK_3 then
					config = create_particle_config()
					config.x = 120 + x_progress + 8
					config.y = 90 + p.y_off + p.height - 4
					config.vx = -4
					config.vy = -1
					config.colour = 21
					config.radius = 1
					if ((menu_anim_counter % 4) > 2) then
						emit_particles(menu_particles, 1, config)
					end
				end
				
				process_particles(menu_particles)
				draw_particles(menu_particles)
				
				local rabbit_sprite_idx = ((menu_anim_counter % 32) > 16) and 18 or 19
				spr(rabbit_sprite_idx, 120 + x_progress, 90)
				
				local fox_sprite_idx = ((menu_anim_counter % 64) > 32) and 22 or 23
				spr(fox_sprite_idx, 340, 80, true)
				
				spr(60, 160+100, 90)
				spr(60, 160+100+16, 90)
				spr(60, 160+100, 90+16)
				spr(60, 160+100+16, 90+16)
				
				spr(56, 160 + x_progress, 90)
				
				if menu_anim_counter > SCENE_1_CHECK_3 then
					spr(40, 260, 72)
					
					if menu_anim_counter > SCENE_1_CHECK_3 + 20 then
						spr(4, 84, 60)
						spr(5, 100, 60)
						spr(6, 116, 60)
						spr(4, 132, 60)
					end
					
					if menu_anim_counter > SCENE_1_CHECK_3 + 40 then
						spr(4, 84, 76)
						spr(5, 100, 76)
						spr(6, 116, 76)
						spr(4, 132, 76)
					end
					
					if menu_anim_counter > SCENE_1_CHECK_3 + 60 then
						spr(4, 84, 92)
						spr(5, 100, 92)
						spr(6, 116, 92)
						spr(4, 132, 92)
					end
					
					if menu_anim_counter > SCENE_1_CHECK_3 + 80 then
						spr(4, 132, 108)
						spr(7, 116, 108)
						spr(7, 100, 108)
						spr(4, 84, 108)
					end
				end
			end
			
			if menu_anim_counter > SCENE_1_CHECK_1 then
				print("The young rabbit must evade terrifying foes...", 80, 160, 7)
			end
			
			if menu_anim_counter > SCENE_1_CHECK_2 then
				print("...pushing boxes to collect keys...", 160, 180, 7)
			end
			
			if menu_anim_counter > SCENE_1_CHECK_3 then
				print("...unlocking the treacherous way to the top.", 220, 200, 7)
			end
		elseif menu_anim_counter > SCENE_1 then
			cls(18)
			rectfill(204, 48, 204+64, 48+11, 25)
			print("Carrot Tower", 206, 50, 7)
			
			local rabbit_sprite_idx = ((menu_anim_counter % 32) > 16) and 18 or 19
			spr(rabbit_sprite_idx, 220, 110)
			
			if ((menu_anim_counter % 96) > 48) then
				rectfill(188, 178, 188+97, 178+11, 0)
				print("Press Space to Play", 190, 180, 7)
			end
			rectfill(78, 218, 78+325, 218+11, 0)
			print("Copyright (c) 2026 - "..name1..", "..name2..", "..name3, 80, 220, 7)
		end
		
		if key("space") and menu_debounce_counter > 10 then
			if menu_anim_counter < SCENE_1_CHECK_1 then
				menu_anim_counter = SCENE_1_CHECK_1
				menu_debounce_counter = 0
			elseif menu_anim_counter < SCENE_1_CHECK_2 then
				menu_anim_counter = SCENE_1_CHECK_2
				menu_debounce_counter = 0
			elseif menu_anim_counter < SCENE_1_CHECK_3 then
				menu_anim_counter = SCENE_1_CHECK_3
				menu_debounce_counter = 0
			elseif menu_anim_counter < SCENE_1 then
				menu_anim_counter = SCENE_1
				menu_debounce_counter = 0
			elseif menu_anim_counter < SCENE_2 then
				menu_anim_counter = SCENE_2
				menu_debounce_counter = 0
			else
				show_menu = false
			end	
		end

		return
	end
	
	-- Set clip to prevent drawing underlayers behind current layer
	local clip_rect_x = cam.offset_x
	local clip_rect_y = cam.offset_y
	clip(clip_rect_x, clip_rect_y, world.current_map[1].bmp:width()*16, world.current_map[1].bmp:height()*16)
	
	-- Update camera
	cam.offset_x = math.lerp(cam.offset_x, cam.target_offset_x, 0.5)
	cam.offset_y = math.lerp(cam.offset_y, cam.target_offset_y, 0.5)
	
	if world.previous_previous_map then
		map(world.previous_previous_map[1].bmp, 0, 0,
			cam.offset_x * world.parallax.multiplier ^ 2,
			cam.offset_y * world.parallax.multiplier ^ 2)
	end
	
	if world.previous_map then
		map(world.previous_map[1].bmp, 0, 0,
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
		if b.solved == 1 then
			map(world.current_map[2].bmp, 0, 0, cam.offset_x, cam.offset_y + old_layer_y_offset * 16)
		end
		
		draw_foxes()
		
		if player_progress > 0.5 then
			map(world.next_map[1].bmp, 0, 0,
				cam.offset_x + 0,
				cam.offset_y + new_layer_y_offset * 16)
		end
		
		if player_progress >= 1.0 then
			memmap(world.next_map[1].bmp, 0x100000)
			world.do_stair_climb = false
			
			level += 1
			
			-- Update maps
			world.previous_previous_map = world.previous_map
			world.previous_map = world.current_map
			world.current_map = world.next_map

			if level == 2 then
				world.next_map = layer_after -- probably fix this at some point
			elseif level == 3 then
				world.next_map = final_layer
			else
				world.next_map = nil
			end

			b = level_boxes[level][1]
			b.solved=0
			
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
		
		if b.solved == 1 then
			map(world.current_map[2].bmp, 0, 0, cam.offset_x, cam.offset_y)
		end
		draw_foxes()
	end
	
	-- Particles!!
	draw_particles(p.particles)
	
	-- Check if we are on stairs and initiate a climb
	player_center = mget((p.x + (p.width/2))/16, (p.y + (p.height/2))/16);
	if not world.do_stair_climb and player_center == 15 then
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
	-- print("HP: " .. p.hp, 10, 10, 7)
	clip()
	if p.hp > 0 then
		for i = 0,p.hp-1
		do
			spr(41, 4+20*i, 4)
		end
	else
		print("You died! x(", 4, 4, 8)
		print("HP: " .. p.hp, 4, 15, 8)
	end
	
	-- debug
	if show_hbox then
		local x1 = p.x + p.hbox.x + cam.offset_x
		local y1 = p.y + p.hbox.y + cam.offset_y
		rect(x1, y1, x1 + p.hbox.w, y1 + p.hbox.h, 8)
	end

	-- TODO - fix box with levels 
	if show_hbox then
		print(box1.solved, 0+ cam.offset_x, 0 + cam.offset_y)
		print(tostr(fget(7,0)), 0+ cam.offset_x, 0 + cam.offset_y+16)
	end
	draw_boxes()
	
	if COLLISION_DEBUG then
		local x = p.x
		local y = p.y
		corners = {
			mget(x/16, (y-1)/16),
			mget(((x+p.width)/16), (((y))/16)),
			mget((x/16), ((y+p.height-1)/16)),
			mget(((x+p.width)/16), ((y+p.height)/16)),
		}
		midpoints = {
			mget((x+p.width/2)/16, y/16), --top middle
			mget((x+p.width/2)/16, (y+p.height)/16), --bottom middle
			mget(((x+p.width)/16), ((y+p.height/2)/16)), -- right middle
			mget(((x)/16), ((y+p.height/2)/16)), -- left middle
		}
		a1 = fget(corners[1],0)
		b1 = fget(corners[2],0)
		c1 = fget(corners[3],0)
		d1 = fget(corners[4],0)
		e1 = fget(midpoints[1],0)
		f1 = fget(midpoints[2],0)
		g1 = fget(midpoints[3],0)
		h1 = fget(midpoints[4],0)
		print(tostr(a1), 0+cam.offset_x, 0+cam.offset_y)
		print(tostr(b1), 0+cam.offset_x, 16+cam.offset_y)
		print(tostr(c1), 0+cam.offset_x, 32+cam.offset_y)
		print(tostr(d1), 0+cam.offset_x, 48+cam.offset_y)
		print(tostr(e1), 0+cam.offset_x, 64+0+cam.offset_y)
		print(tostr(f1), 0+cam.offset_x, 64+16+cam.offset_y)
		print(tostr(g1), 0+cam.offset_x, 64+32+cam.offset_y)
		print(tostr(h1), 0+cam.offset_x, 64+48+cam.offset_y)
--		print(tostr(p.x), -32+p.x+cam.offset_x, p.y+cam.offset_y)
--		print(tostr(b.x), -32+p.x+cam.offset_x, p.y+16+cam.offset_y)
		print(tostr(box_push_try), -32+p.x+cam.offset_x, p.y+cam.offset_y)
		print(tostr(box_push_try_last_frame), -32+p.x+cam.offset_x, p.y+16+cam.offset_y)
	end	
end
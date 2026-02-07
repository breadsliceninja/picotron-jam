--[[pod_format="raw",created="2024-03-24 00:48:06",modified="2026-02-07 07:58:45",revision=427]]
-- testing
include "movement.lua"
function _init()
	poke(0x5f5c, 255) -- diasable key repeat
	p = {
		x = 16*4,
		y = 16*4,
		vx = 0,
		vy = 0,
		smax = 3,
		width = 32,
		height = 32
	}
	-- collision blocks
	c = {4,}
	-- acceleration
	a = 0.3
	
	-- camera
	cam = {
		offset_x = 0,
		offset_y = 0
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

function _update()
	-- called each frame (60 times)
	move_player()
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
		map(0, 0, 0, old_layer_y_offset * 16)
		
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
	
	spr(9, cam.offset_x + p.x, cam.offset_y + p.y)
end
--[[pod_format="raw",created="2026-02-08 00:37:43",modified="2026-02-08 04:38:27",revision=379]]
-- turning speed
-- field of view
-- dash out of fov, then it gets confused and starts searching
-- launches projectiles with short cooldown

FOX_IDLE = 0
FOX_SPOTTED = 1
FOX_TRACKING = 2
FOX_CONFUSED = 3
FOX_FIRE_PROJECTILE = 4

SPRITE_SIDE = 23
SPRITE_UP = 24
SPRITE_DOWN = 22

FOV_SEARCHING = 135
FOV_SPOTTED = 5

DIST_SEARCHING = 8*16
DIST_SPOTTED = 16*16

ANIM_SPOTTED_DURATION = 10
ANIM_LOSE_FOCUS_DURATION = 100
ANIM_FIRE_PROJECTILE_DURATION = 30
ANIM_FIRE_PROJECTILE_COOLDOWN = 200

BURST_SIZE = 20

function create_fox(x,y)
	return {
		x = x,
		y = y,
		view_current_angle = 0,
		view_fov = FOV_SEARCHING,
		view_distance = DIST_SEARCHING,
		view_rotate_speed = 1,
		sprite_x_offset = 16,
		sprite_y_offset = 38,
		state = FOX_IDLE,
		time_counter = 0,
		projectile_counter = 0,
		particle_system = {},
	}
end

function process_fox(fox)
	if fox.state == FOX_IDLE then
		fox.view_fov = FOV_SEARCHING
		fox.view_distance = DIST_SEARCHING
		fox.view_current_angle += fox.view_rotate_speed
		if fox.view_current_angle > 180 then
			fox.view_current_angle -= 360
		end
		
		-- Check if player is in range for more than 300ms
		local angle_to_player = calc_angle_to_player(fox)
		local lower_bound_angle = fox.view_current_angle - fox.view_fov / 2
		local upper_bound_angle = fox.view_current_angle + fox.view_fov / 2
		local dist_to_player = calc_distance_to_player(fox)
		
		if angle_to_player > lower_bound_angle and
			angle_to_player < upper_bound_angle and
			dist_to_player < fox.view_distance then
			fox.state = FOX_SPOTTED
			fox.time_counter = 0
			fox.proj_counter = 0
		end
	end
	
	if fox.state == FOX_SPOTTED then
		fox.time_counter += 1
		
		-- Play ! animation
		fox.view_fov = math.lerp(fox.view_fov, FOV_SPOTTED, fox.time_counter/ANIM_SPOTTED_DURATION)
		fox.view_distance = math.lerp(fox.view_distance, DIST_SPOTTED, fox.time_counter/ANIM_SPOTTED_DURATION)
		
		fox.view_current_angle = calc_angle_to_player(fox)
		
		if fox.time_counter > ANIM_SPOTTED_DURATION then
			fox.time_counter = 0
			fox.state = FOX_TRACKING
		end
	end
	
	if fox.state == FOX_TRACKING then
		fox.view_fov = FOV_SPOTTED
		fox.view_distance = DIST_SPOTTED
		fox.proj_counter += 1
		
		if fox.proj_counter > (ANIM_FIRE_PROJECTILE_DURATION * BURST_SIZE) then
			fox.proj_counter = -ANIM_FIRE_PROJECTILE_COOLDOWN
		end
		
		fox.view_current_angle = calc_angle_to_player(fox)
		
		local distance_to_player = calc_distance_to_player(fox)
		if distance_to_player > DIST_SPOTTED then
			fox.time_counter += 1
			
			if fox.time_counter > ANIM_LOSE_FOCUS_DURATION then
				fox.state = FOX_IDLE
				fox.time_counter = 0
			end
		else
			fox.time_counter = 0
			
			if fox.proj_counter > 0 and fox.proj_counter % ANIM_FIRE_PROJECTILE_DURATION == 0 then
				local fox_center_x = fox.x + fox.sprite_x_offset
				local fox_head_y = fox.y + 20
		
				local player_center_x = p.x + p.x_offset
				local player_center_y = p.y + p.y_offset
				
				local dir_x = player_center_x - fox_center_x
				local dir_y = player_center_y - fox_head_y
				
				local magnitude = sqrt(dir_x^2 + dir_y^2)
				local norm_dir_x = dir_x / magnitude
				local norm_dir_y = dir_y / magnitude
				
				local config = create_particle_config()
				config.x = fox_center_x
				config.y = fox_head_y
				config.vx = 1 * norm_dir_x
				config.vy = 1 * norm_dir_y
				config.colour = 8
				config.alt_colour = 9
				config.colour_change_duration = 32
				config.radius = 4
				config.glow_radius = 5
				config.glow_colour = 10
				config.size_decay = 1.0
				config.lifespan = 500
				config.friction = 1.0
				config.randomness = 0.2
				emit_particles(fox.particle_system, 1, config)
			end
		end
	end
	
	process_particles(fox.particle_system)
end

function calc_angle_to_player(fox)
	local fox_center_x = fox.x + fox.sprite_x_offset
	local fox_center_y = fox.y + fox.sprite_y_offset
		
	local player_center_x = p.x + p.x_offset
	local player_center_y = p.y + p.y_offset
		
	local y_offset = fox_center_y - player_center_y
	local x_offset = fox_center_x - player_center_x
		
	return math.deg(math.atan(y_offset, -x_offset)) + 90
end

function calc_distance_to_player(fox)
	local fox_center_x = fox.x + fox.sprite_x_offset
	local fox_center_y = fox.y + fox.sprite_y_offset
		
	local player_center_x = p.x + p.x_offset
	local player_center_y = p.y + p.y_offset
		
	return sqrt((fox_center_x - player_center_x) ^ 2 + (fox_center_y - player_center_y) ^ 2)
end

function draw_fox(fox)
	local center_x = cam.offset_x + fox.x + fox.sprite_x_offset
	local center_y = cam.offset_y + fox.y + fox.sprite_y_offset
	
	local triangle_y_upper = center_y + fox.view_distance
		* math.cos(math.rad(fox.view_current_angle - (fox.view_fov/2)))
	local triangle_x_upper = center_x + fox.view_distance
		* math.sin(math.rad(fox.view_current_angle - (fox.view_fov/2)))
		
	local triangle_y_lower = center_y + fox.view_distance
		* math.cos(math.rad(fox.view_current_angle + (fox.view_fov/2)))
	local triangle_x_lower = center_x + fox.view_distance
		* math.sin(math.rad(fox.view_current_angle + (fox.view_fov/2)))
		
	local triangle_y_midpoint = center_y + fox.view_distance
		* math.cos(math.rad(fox.view_current_angle))
	local triangle_x_midpoint = center_x + fox.view_distance
		* math.sin(math.rad(fox.view_current_angle))
	
	local contained_diagonal = math.floor(fox.view_current_angle / 90) * 90 + 45
	local diagonal_distance = sqrt(2 * (fox.view_distance ^ 2))
	
	local diagonal_y_extent = center_y + diagonal_distance * math.cos(math.rad(contained_diagonal))
	local diagonal_x_extent = center_x + diagonal_distance * math.sin(math.rad(contained_diagonal))
	
	local rect_min_x = min(min(triangle_x_upper, triangle_x_lower), diagonal_x_extent)
	local rect_min_y = min(min(triangle_y_upper, triangle_y_lower), diagonal_y_extent)
	local rect_max_x = max(max(triangle_x_upper, triangle_x_lower), diagonal_x_extent)
	local rect_max_y = max(max(triangle_y_upper, triangle_y_lower), diagonal_y_extent)
	
	local line_col = (fox.state == FOX_TRACKING) and 8 or 7
	
	if fox.state == FOX_TRACKING and fox.time_counter != 0 then
		line_col = (fox.time_counter % 16 < 8) and 10 or 8
	end
	
	if fox.state == FOX_TRACKING and fox.proj_counter < 0 then
		line_col = 18
	end
	
--	rectfill(rect_min_x, rect_min_y, rect_max_x, rect_max_y, 9)
	clip(rect_min_x, rect_min_y, rect_max_x - rect_min_x, rect_max_y - rect_min_y)
	
	circ(center_x, center_y, fox.view_distance, line_col)
	
	clip()
	
--	line(center_x, center_y, triangle_x_midpoint, triangle_y_midpoint, 5)
--	line(center_x, center_y, diagonal_x_extent, diagonal_y_extent, 6)
	line(center_x, center_y, triangle_x_upper, triangle_y_upper, line_col)
	line(center_x, center_y, triangle_x_lower, triangle_y_lower, line_col)
	
	draw_particles(fox.particle_system)
	
	if fox.view_current_angle > 45 and fox.view_current_angle <= 135 then
		spr(SPRITE_SIDE, cam.offset_x + fox.x, cam.offset_y + fox.y)
	elseif fox.view_current_angle > 135 and fox.view_current_angle <= 225 then
		spr(SPRITE_UP, cam.offset_x + fox.x, cam.offset_y + fox.y)
	elseif fox.view_current_angle > 225 and fox.view_current_angle <= 315 then
		spr(SPRITE_SIDE, cam.offset_x + fox.x, cam.offset_y + fox.y, true)
	else
		spr(SPRITE_DOWN, cam.offset_x + fox.x, cam.offset_y + fox.y)
	end
	
	if fox.state != FOX_IDLE then
		if fox.proj_counter < 0 then
			print("Zzz",
				cam.offset_x + fox.x + fox.sprite_x_offset - 4,
				cam.offset_y + fox.y - 12,
				18)
		else
			print("!!",
				cam.offset_x + fox.x + fox.sprite_x_offset - 4,
				cam.offset_y + fox.y - 12,
				8)
		end
	end
end
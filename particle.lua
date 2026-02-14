--[[pod_format="raw",created="2026-02-08 02:53:23",modified="2026-02-14 23:04:46",revision=193]]
MAX_PARTICLES = 1000

function create_particle_config()
	return {
		x = 0,
		y = 0,
		radius = 4,
		colour = 4,
		alt_colour = 4,
		colour_change_duration = 1,
		glow_colour = 7,
		glow_radius = -1,
		lifespan = 20,
		vx = 5,
		vy = 5,
		friction = 0.9,
		size_decay = 0.995,
		randomness = 1.0
	}
end

-- system is just an array
function emit_particles(system, n, config)
	local n_particles = #system
	if n_particles + n > MAX_PARTICLES then
		n = min(MAX_PARTICLES, MAX_PARTICLES - n_particles)
	end
	for i = n_particles, n_particles+n
	do
		system[i] = {
			x = config.x,
			y = config.y,
			radius = config.radius,
			colour = config.colour,
			alt_colour = config.alt_colour,
			colour_change_duration = config.colour_change_duration,
			glow_radius = config.glow_radius,
			glow_colour = config.glow_colour,
			lifespan = config.lifespan,
			size_decay = config.size_decay,
			vx = config.vx + config.randomness * (math.random() - 0.5),
			vy = config.vy + config.randomness * (math.random() - 0.5),
			friction = config.friction
		}
	end
end

function process_particles(system, is_collidable)
	-- Clear Table
	local new_index = 1
	for i = 1, #system
	do
		local particle = system[i]
		-- update the particle
		particle.lifespan -= 1
		
		particle.x += particle.vx
		particle.y += particle.vy
		
		particle.vx *= particle.friction
		particle.vy *= particle.friction
		
		particle.radius *= particle.size_decay
		particle.radius = max(particle.radius, 1)
		
		-- Check Collision
		if is_collidable then
			-- player
			local p_left = p.x + p.hbox.x
			local p_right = p_left + p.hbox.w
			local p_top = p.y + p.hbox.y
			local p_bottom = p_top + p.hbox.h
			
			-- collider
			local c_left = particle.x - particle.radius
			local c_right = particle.x + particle.radius
			local c_top = particle.y - particle.radius
			local c_bottom = particle.y + particle.radius
				
			if p_left < c_right and
				p_right > c_left and
				p_top < c_bottom and
				p_bottom > c_top
			then
				hurt_player()
				particle.lifespan = -1	
			end
			
			-- box
			for i = 1,#level_boxes[level] do
				local b = level_boxes[level][i]
				local b_left = b.x
				local b_right = b.x + b.width
				local b_top = b.y
				local b_bottom = b.y + b.height
				
				if b_left < c_right and
					b_right > c_left and
					b_top < c_bottom and
					b_bottom > c_top
				then
					-- particle.lifespan = -1
					particle.vx *= -1
					particle.vy *= -1	
				end
			end
		end
		
		if particle.lifespan > 0 then
			system[new_index] = particle
			new_index += 1
		end
	end
	
	for k = new_index, #system do
   	system[k] = nil
	end
end

function draw_particles(system)
	for i = 1, #system
	do
		local particle = system[i]
		local use_alt_colour = (particle.lifespan % particle.colour_change_duration) < (particle.colour_change_duration / 2)
		local colour = use_alt_colour and particle.colour or particle.alt_colour
		
		if show_hbox then
			local c_left = particle.x - particle.radius
			local c_right = particle.x + particle.radius
			local c_top = particle.y - particle.radius
			local c_bottom = particle.y + particle.radius
			
			rectfill(cam.offset_x + c_left, cam.offset_y + c_top, cam.offset_x + c_right, cam.offset_y + c_bottom)
		end
		
		if particle.glow_radius > 0 then
			circfill(
				cam.offset_x + particle.x,
				cam.offset_y + particle.y,
				particle.glow_radius, particle.glow_colour)
		end
		
		circfill(
			cam.offset_x + particle.x,
			cam.offset_y + particle.y,
			particle.radius, colour)
	end
end
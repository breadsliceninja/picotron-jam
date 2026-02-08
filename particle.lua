--[[pod_format="raw",created="2026-02-08 02:53:23",modified="2026-02-08 03:39:37",revision=130]]
MAX_PARTICLES = 1000

function create_particle_config()
	return {
		x = 0,
		y = 0,
		radius = 4,
		colour = 4,
		lifespan = 20,
		vx = 5,
		vy = 5,
		friction = 0.9
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
			lifespan = config.lifespan,
			vx = config.vx + (math.random() - 0.5),
			vy = config.vy + (math.random() - 0.5),
			friction = config.friction
		}
	end
end

function process_particles(system)
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
		circfill(
			cam.offset_x + particle.x - particle.radius,
			cam.offset_y + particle.y - particle.radius,
			particle.radius, particle.colour)
	end
end
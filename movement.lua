--[[pod_format="raw",created="2026-02-07 02:41:15",modified="2026-02-08 04:10:35",revision=128]]
function move_player()
    START_SPEED = 1
	-- left
	if (
			btnp(0) and 
			not btn(1) and 
			not btn(2) and
			not btn(3) 
		)
		then
		p.vx = -START_SPEED 
	elseif btnp(0) or btn(0) then
		p.vx -= a
		p.facing = "left"
	end
	-- right
	if (
			btnp(1) and 
			not btn(0) and 
			not btn(2) and
			not btn(3) 
		)
		then
		p.vx = START_SPEED
	elseif btnp(1) or btn(1) then
		p.vx += a
		p.facing = "right"
	end
	-- up (if up and no other keys)
	if (
			btnp(2) and 
			not btn(0) and 
			not btn(1) and
			not btn(3) 
		)
		then
		p.vy = -START_SPEED 
	elseif btnp(2) or btn(2) then
		p.vy -= a
		p.facing = "up"
	end
	-- down
	if (
			btnp(3) and 
			not btn(0) and 
			not btn(1) and
			not btn(2) 
		)
		then
		p.vy = START_SPEED 
	elseif btnp(3) or btn(3) then
		p.vy += a
		p.facing = "down"
	end
	
	-- start walk frame
	if btnp(0) or btnp(1) or btnp(2) or btnp(3) then
		p.anim_alt = true
		p.anim_t = anim_dly
	end
	
	-- dash
	if btnp(4) and p.dash_t <= 0 then
		local n_pressed = 0
		if btn(0) then
			p.vx = -dash_spd
			n_pressed += 1
		end
		if btn(1) then
			p.vx = dash_spd
			n_pressed += 1
		end
		if btn(2) then
			p.vy = -dash_spd
			n_pressed += 1
		end
		if btn(3) then
			p.vy = dash_spd
			n_pressed += 1
		end
		if n_pressed > 0 then
			p.is_dashing = true
			p.dash_t = dash_dly
		end
		if n_pressed > 1 then
			p.vx /= sqrt(2)
			p.vy /= sqrt(2)
		end
--		if (abs(p.vx) != 0) p.vx = dash_spd * sgn(p.vx)
--		if (abs(p.vy) != 0) p.vy = dash_spd * sgn(p.vy)
	end

	-- deccelerate
	local decc = (p.is_dashing) and 0.94 or 0.90
	p.vx *= decc
	p.vy *= decc
	if (abs(p.vx) < 0.1) p.vx = 0
	if (abs(p.vy) < 0.1) p.vy = 0
	
	
	if p.is_dashing then
		if p.dash_t <= 10 then
			p.is_dashing = false
		end
	else
		-- cap speed
		p.vx = mid(-p.smax, p.vx, p.smax)
		p.vy = mid(-p.smax, p.vy, p.smax)
	end
	
	 -- fix diagonal movemment
--	normal = sqrt(p.vx^2 + p.vy^2)
--	if normal != 0 then
--		p.vx = p.vx -- * abs(p.vx/normal)
--		p.vy = p.vy -- * abs(p.vy/normal)
--	end

	proposed_x = p.x + p.vx
	proposed_y = p.y + p.vy
	
	-- spike collision
	local x1 = p.x + p.hbox.x
	local y1 = p.y + p.hbox.y
	if 
		p.invul_t <= 0 and (
		fget(mget((x1 + p.hbox.w)/16, y1/16), 1) or
		fget(mget(x1/16, y1/16), 1) or
		fget(mget(x1/16, (y1 + p.hbox.h)/16), 1) or
		fget(mget((x1 + p.hbox.w)/16, (y1 + p.hbox.h)/16), 1) --or
--		fget(mget((x1 + p.hbox.w/2)/16, (y1 + p.hbox.h/2)/16), 1)
		)
	then
		hurt_player()
	end
	
	-- left tile checking...
	if proposed_x > p.x then
		if fget(mget((p.width + proposed_x)/16, p.y/16), 0) then
			-- collision
			p.x = (math.floor(proposed_x/16))*16
			if (p.is_dashing) p.vx = -p.vx
		else
			p.x = proposed_x
		end
	end
	--right
	if proposed_x < p.x then
		if fget(mget(proposed_x/16, p.y/16), 0) then
			-- collision
			p.x = (math.ceil(proposed_x/16))*16
			if (p.is_dashing) p.vx = -p.vx
		else
			p.x = proposed_x
		end
	end
	-- up
	if proposed_y <= p.y then
		if fget(mget(p.x/16, proposed_y/16), 0) then
			-- collision
			p.y = (math.ceil(proposed_y/16))*16
			if (p.is_dashing) p.vy = -p.vy
		else
			p.y = proposed_y
		end
	end
	-- down
	if proposed_y >= p.y then
		if fget(mget(p.x/16, (proposed_y+p.height)/16), 0) then
			-- collision
			p.y = (math.floor(proposed_y/16))*16
			if (p.is_dashing) p.vy = -p.vy
		else
			p.y = proposed_y
		end
	end


--	if proposed_x <= p.x and mget((proposed_x)/16, p.y/16) != 4 then
--		p.x = proposed_x
--	end 
--	-- above/below tile checking
--	if proposed_y >= p.y and mget(p.x/16, (proposed_y + p.height)/16) != 4 then
--		p.y = proposed_y
--	end
--	if proposed_y <= p.y and mget(p.x/16, p.y/16) != 4 then
--		p.y = proposed_y
--	end	
--	p.x += mid(-p.smax, p.vx, p.smax)
--	p.y += mid(-p.smax, p.vy, p.smax)
end

function hurt_player()
	if (p.is_dashing) return
	p.hp -= 1
	if p.hp <= 0 then
		-- TODO: kill player
	end
	p.invul_t = invul_dly
end
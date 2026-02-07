--[[pod_format="raw",created="2026-02-07 02:41:15",modified="2026-02-07 04:47:49",revision=82]]
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
	elseif btn(0) then
		p.vx -= a
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
	elseif btn(1) then
		p.vx += a
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
	elseif btn(2) then
		p.vy -= a
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
	elseif btn(3) then
		p.vy += a
	end


	p.vx *= 0.90
	p.vy *= 0.90
	-- if not moving left or right, deccel x axis
--	if not (
--		btn(0) or
--		btn(1) or
--		btn(2) or
--		btn(3)
--		)
--	 then
--	 -- 0.95 for that luigi wavedash feel
--		p.vx *= 0.85
--		p.vy *= 0.85
--	end
	
	proposed_x = p.x + mid(-p.smax, p.vx, p.smax)
	proposed_y = p.y + mid(-p.smax, p.vy, p.smax)
	-- left/right tile checking...
	if proposed_x > p.x then
		if mget((p.width + proposed_x)/16, p.y/16) != 4 then
			p.x = proposed_x
		else
			p.x = (math.floor(proposed_x/16))*16
		end
	end
	if proposed_x < p.x then
		if mget(proposed_x/16, p.y/16) != 4 then
			p.x = proposed_x
		else
			p.x = (math.ceil(proposed_x/16))*16
		end
	end
	
	if proposed_y <= p.y then
		if mget(p.x/16, proposed_y/16) != 4 then
			p.y = proposed_y
		else
			p.y = (math.ceil(proposed_y/16))*16
		end
	end
	if proposed_y >= p.y then
		if mget(p.x/16, (proposed_y+p.height)/16) != 4 then
			p.y = proposed_y
		else
			p.y = (math.floor(proposed_y/16))*16
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
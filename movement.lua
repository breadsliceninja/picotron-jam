--[[pod_format="raw",created="2026-02-07 02:41:15",modified="2026-02-07 06:47:13",revision=7]]
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
		p.sx = -START_SPEED 
	elseif btnp(0) or btn(0) then
		p.sx -= a
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
		p.sx = START_SPEED
	elseif btnp(1) or btn(1) then
		p.sx += a
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
		p.sy = -START_SPEED 
	elseif btnp(2) or btn(2) then
		p.sy -= a
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
		p.sy = START_SPEED 
	elseif btnp(3) or btn(3) then
		p.sy += a
		p.facing = "down"
	end
	
	if btnp(0) or btnp(1) or btnp(2) or btnp(3) then
		p.anim_alt = true
		p.anim_t = anim_dly
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
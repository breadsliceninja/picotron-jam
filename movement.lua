--[[pod_format="raw",created="2026-02-07 02:41:15",modified="2026-02-08 03:07:04",revision=19]]
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
	
	if btnp(0) or btnp(1) or btnp(2) or btnp(3) then
		p.anim_alt = true
		p.anim_t = anim_dly
	end

	-- 0.95 for that luigi wavedash feel
	p.vx *= 0.90
	p.vy *= 0.90
	
	proposed_x = p.x + mid(-p.smax, p.vx, p.smax)
	proposed_y = p.y + mid(-p.smax, p.vy, p.smax)
	-- get proposed borders around the character
	-- used for collision against walls
	-- assumes top left pixel of sprite
	p_right	=	proposed_x - p.x_off + p.width 
	p_left 	= 	proposed_x + p.x_off
	p_up 		=  proposed_y + p.y_off
	p_down 	= 	proposed_y - p.y_off + p.height

	-- note: currently only supports one box (grimace emoji)
	b_up_border 	= b.y
	b_down_border 	= b.y + b.height
	b_right_border 	= b.x + b.width
	b_left_border 	= b.x
	
	BOX_PUSH_SPEED = 1

	-- if top of player edge is lower than top of box edge

	-- RIGHT
	if proposed_x > p.x then
		-- if right edge is NOT hitting collision map block, move		
		if mget((p_right)/16, (p.y+p.y_off)/16) != 4 then
			-- box collision
			if p_right >= b_left_border and -- if going right 'into' the box
				p.x < b_left_border and  	 -- but currently to the left of the box
				p.y + p.height - p.y_off > b.y and 	 -- bottom of player lower than top of box
				p.y + p.y_off < (b.y + b.height) then -- top edge of player above bottom edge of box
				
				b.x = b.x + min(mid(-p.smax, p.vx, p.smax), BOX_PUSH_SPEED)
				p.x = b.x - b.width + p.x_off 
			else
				p.x = proposed_x
			end
		else
			p.x = ((math.floor(proposed_x/16))*16)+p.x_off 
		end
	end
	-- LEFT
	if proposed_x < p.x then
		if mget(p_left/16, (p.y+p.y_off)/16) != 4 then
			-- box collision
			if proposed_x + p.x_off <= (b_right_border) and -- if new right going INTO box
				p.x > b_right_border - p.x_off and          -- but currently to the right of box
				p.y + p.height - p.y_off > b.y and 	 -- bottom of player lower than top of box
				p.y < (b.y + b.height) - p.y_off then 
				-- top edge of player above bottom edge of box
--				 
				b.x = b.x + max(mid(-p.smax, p.vx, p.smax), - BOX_PUSH_SPEED)
				p.x = b.x + b.width - (p.x_off+1) + 2
			else
				p.x = proposed_x
			end
		else
			p.x = ((math.ceil((proposed_x)/16))*16) - p.x_off
		end
	end
	-- UP
	if proposed_y < p.y then
		if mget((p.x+p.x_off)/16, (p_up)/16) != 4 then
			if proposed_y + p.y_off < b.y + p.height and -- if new right going INTO box
				p.y + p.y_off > b.y + b.height and						-- and player bottom edge above box top edge
				p.x + p.x_off < b_left_border + b.width and 			-- left edge is to the left of box right border
				p.x + p.width - p.x_off > b_left_border         	-- but currently to the right of box
				then
				b.y = b.y - min(abs(mid(-p.smax, p.vy, p.smax)), BOX_PUSH_SPEED)
				p.y = b.y + b.height - (p.y_off-1)
			else
				p.y = proposed_y
			end
		else
			p.y = (math.ceil(proposed_y/16))*16 - p.y_off
		end
	end
	-- down
	if proposed_y > p.y then
	
		if mget((p.x+p.x_off)/16, (p_down)/16) != 4 then
			if proposed_y + p.height - p.y_off >= (b_up_border) and -- if new right going INTO box
				p.y + p.height - p.y_off < b.y and						-- and player bottom edge above box top edge
				p.x + p.x_off < b_left_border + b.width and 			-- left edge is to the left of box right border
				p.x + p.width - p.x_off > b_left_border         	-- but currently to the right of box
				then
				b.y = b.y + min(mid(-p.smax, p.vy, p.smax), BOX_PUSH_SPEED)
				p.y = b.y - b.height + (p.y_off-1)
			else
				p.y = proposed_y
			end
		else
			p.y = ((math.floor(proposed_y/16))*16)+p.y_off
		end
	end
	-- p.vx *= 0.90
	-- p.vy *= 0.90
	
	-- proposed_x = p.x + mid(-p.smax, p.vx, p.smax)
	-- proposed_y = p.y + mid(-p.smax, p.vy, p.smax)
	-- left/right tile checking...
	-- if proposed_x > p.x then
	-- 	if mget((p.width + proposed_x)/16, p.y/16) != 4 then
	-- 		p.x = proposed_x
	-- 	else
	-- 		p.x = (math.floor(proposed_x/16))*16
	-- 	end
	-- end
	-- if proposed_x < p.x then
	-- 	if mget(proposed_x/16, p.y/16) != 4 then
	-- 		p.x = proposed_x
	-- 	else
	-- 		p.x = (math.ceil(proposed_x/16))*16
	-- 	end
	-- end
	
	-- if proposed_y <= p.y then
	-- 	if mget(p.x/16, proposed_y/16) != 4 then
	-- 		p.y = proposed_y
	-- 	else
	-- 		p.y = (math.ceil(proposed_y/16))*16
	-- 	end
	-- end
	-- if proposed_y >= p.y then
	-- 	if mget(p.x/16, (proposed_y+p.height)/16) != 4 then
	-- 		p.y = proposed_y
	-- 	else
	-- 		p.y = (math.floor(proposed_y/16))*16
	-- 	end
	-- end

end

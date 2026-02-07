--[[pod_format="raw",created="2026-02-07 02:41:15",modified="2026-02-07 23:26:49",revision=441]]
include "math.lua"
-- Handles Movement and Collision
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

	-- 0.95 for that luigi wavedash feel
	p.vx *= 0.90
	p.vy *= 0.90
	
	proposed_x = p.x + mid(-p.smax, p.vx, p.smax)
	proposed_y = p.y + mid(-p.smax, p.vy, p.smax)
	-- get proposed borders around the character
	-- used for collision against walls
	-- assumes top left pixel of sprite
	p_right	=	proposed_x - p.x_offset + p.width 
	p_left 	= 	proposed_x + p.x_offset
	p_up 		=  proposed_y + p.y_offset
	p_down 	= 	proposed_y - p.y_offset + p.height

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
		if mget((p_right)/16, (p.y+p.y_offset)/16) != 4 then
			-- box collision
			if p_right >= b_left_border and -- if going right 'into' the box
				p.x <= b_left_border and  	 -- but currently to the left of the box
				p.y + p.height - p.y_offset >= b.y and 	 -- bottom of player lower than top of box
				p.y + p.y_offset <= (b.y + b.height) then -- top edge of player above bottom edge of box
				
				b.x = b.x + min(mid(-p.smax, p.vx, p.smax), BOX_PUSH_SPEED)
				p.x = b.x - b.width + p.x_offset 
			else
				p.x = proposed_x
			end
		else
			p.x = ((math.floor(proposed_x/16))*16)+p.x_offset 
		end
	end
	-- LEFT
	if proposed_x < p.x then
		if mget(p_left/16, (p.y+p.y_offset)/16) != 4 then
			-- box collision

			if proposed_x + 4 <= (b_right_border) and -- if new right going INTO box
				p.x >= b_right_border - 4 and          -- but currently to the right of box
				p.y + p.height - p.y_offset >= b.y and 	 -- bottom of player lower than top of box
				p.y <= (b.y + b.height) - p.y_offset then -- top edge of player above bottom edge of box
--				 
				b.x = b.x + max(mid(-p.smax, p.vx, p.smax), - BOX_PUSH_SPEED)
				p.x = b.x + b.width - 3
			else
				p.x = proposed_x
			end
		else
			p.x = ((math.ceil((proposed_x)/16))*16) - p.x_offset
		end
	end
	-- UP
	if proposed_y < p.y then
		if mget((p.x+p.x_offset)/16, (p_up)/16) != 4 then
			p.y = proposed_y
		else
			p.y = (math.ceil(proposed_y/16))*16 - p.y_offset
		end
	end
	if proposed_y > p.y then
		if mget((p.x+p.x_offset)/16, (p_down)/16) != 4 then
			p.y = proposed_y
		else
			p.y = ((math.floor(proposed_y/16))*16)+p.y_offset
		end
	end
	
	-- BOX PUSHING...
	
end
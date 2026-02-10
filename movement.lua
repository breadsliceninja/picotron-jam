--[[pod_format="raw",created="2026-02-09 09:26:36",modified="2026-02-10 09:54:40",revision=80]]
include "box_detection.lua"
include "detect_walls.lua"
include "math.lua"
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
	
	proposed_x = p.x + p.vx
	proposed_y = p.y + p.vy
	
	-- spike collision
	local x1 = p.x + p.hbox.x
	local y1 = p.y + p.hbox.y
	if 
		p.invul_t <= 0 and (
		fget(mget((x1 + p.hbox.w)/16, y1/16), 3) or
		fget(mget(x1/16, y1/16), 3) or
		fget(mget(x1/16, (y1 + p.hbox.h)/16), 3) or
		fget(mget((x1 + p.hbox.w)/16, (y1 + p.hbox.h)/16), 3) --or
--		fget(mget((x1 + p.hbox.w/2)/16, (y1 + p.hbox.h/2)/16), 1)
		)
	then
		hurt_player()
	end
	
	-- get proposed borders around the character
	-- used for collision against walls
	-- assumes top left pixel of sprite
	p_right	=	proposed_x + p.width - p.x_off  
	p_left 	= 	proposed_x + p.x_off
	p_up 		=  proposed_y + p.y_off
	p_down 	= 	proposed_y + p.height - p.y_off 

	-- note: currently only supports one box (grimace emoji)
	b_up_border 	= b.y
	b_down_border 	= b.y + b.height
	b_right_border 	= b.x + b.width
	b_left_border 	= b.x
	
	BOX_PUSH_SPEED = 1

	-- if top of player edge is lower than top of box edge
	-- is the acceleration causing the issue?
	change_x = true
	change_y = true
	if detect_walls(p.x, proposed_y) then
		change_y = false
	end
	if detect_walls(proposed_x, p.y) then
		change_x = false
	end
	if not detect_walls(proposed_x, proposed_y) then
		change_x = true
		change_y = true
	end

	-- BOX COLLISION | RIGHT
	-- RIGHT
	
--			-- box collision
--	corners = {
--		mget(x/16, y/16),							-- top left
--		mget(((x+p.width-1)/16), ((y)/16)),	-- top right
--		mget((x/16), ((y+p.height-1)/16)),					-- bottom left
--		mget(((x+p.width-1)/16), ((y+p.height-1)/16)),	-- bottom right
--	}
	local box_pushed_x = false
	local box_pushed_y = false
	if proposed_x > p.x and 
		(p.x+p.width-1) > b_left_border and -- if going right 'into' the box
		p.x < b_right_border-b.width/2 and  	 -- but currently to the left of the box
		p.y + p.height - p.y_off > b.y and 	 -- bottom of player lower than top of box
		p.y + p.y_off < (b.y + b.height) then -- top edge of player above bottom edge of box
--				
		proposed_bx = b.x + min(mid(-p.smax, p.vx, p.smax), BOX_PUSH_SPEED)
		on_track(proposed_bx, b.y)
		if b.on_track == 1 then
			box_pushed_x = true
			b.x = proposed_bx
			p.x = b.x - b.width + p.x_off
		else -- if want to push onto box but box end of track, don't move
			proposed_x = p.x 
		end
	end

	if proposed_x > p.x then
		if fget(mget((p_right)/16, (p.y+p.y_off)/16), 0) then
--			p.x = ((math.floor(proposed_x/16))*16)+p.x_off 
			if (p.is_dashing) p.vx = -p.vx
		end
	end
	-- LEFT
	if proposed_x < p.x then
			-- box collision
			if proposed_x + p.x_off < (b_right_border) and -- if new right going INTO box
				p.x > b_right_border - p.x_off and          -- but currently to the right of box
				p.y + p.height - p.y_off > b.y and 	 -- bottom of player lower than top of box
				p.y < (b.y + b.height) - p.y_off then 
				-- top edge of player above bottom edge of box
				proposed_bx = b.x + max(mid(-p.smax, p.vx, p.smax), - BOX_PUSH_SPEED)
				on_track(proposed_bx, b.y)
				if b.on_track == 1 then
					box_pushed_x = true
					b.x = proposed_bx
					p.x = b.x + b.width 
				else
					proposed_x = p.x
				end
			end
		if fget(mget(p_left/16, (p.y+p.y_off)/16), 0) then
--			p.x = ((math.ceil((proposed_x)/16))*16) - p.x_off
			if (p.is_dashing) p.vx = -p.vx
		end
	end
--	-- UP
	if proposed_y < p.y then
		if proposed_y + p.y_off < b.y + p.height and -- if new right going INTO box
			p.y + p.y_off > b.y + b.height and						-- and player bottom edge above box top edge
			p.x + p.x_off < b_left_border + b.width and 			-- left edge is to the left of box right border
			p.x + p.width - p.x_off > b_left_border         	-- but currently to the right of box
			then
			proposed_by = b.y - min(abs(mid(-p.smax, p.vy, p.smax)), BOX_PUSH_SPEED)
			on_track(b.x, proposed_by)
			if b.on_track == 1 then
				box_pushed_y = true
				b.y = proposed_by
				p.y = b.y + b.height - (p.y_off-1)
			else
				proposed_y = p.y 			
			end	
		end
		if fget(mget((p.x+p.x_off)/16, (p_up)/16), 0) then
--			p.y = (math.ceil(proposed_y/16))*16 - p.y_off
			if (p.is_dashing) p.vy = -p.vy
		end
	end
--	-- down
	if proposed_y > p.y then
	
		
		if proposed_y + p.height - p.y_off >= (b_up_border) and -- if new right going INTO box
			p.y + p.height - p.y_off < b.y and						-- and player bottom edge above box top edge
			p.x + p.x_off < b_left_border + b.width and 			-- left edge is to the left of box right border
			p.x + p.width - p.x_off > b_left_border         	-- but currently to the right of box
			then
			
			proposed_by = b.y + min(mid(-p.smax, p.vy, p.smax), BOX_PUSH_SPEED)
			on_track(b.x, proposed_by)
			if b.on_track == 1 then
				box_pushed_y = true
				b.y = proposed_by
				p.y = b.y - b.height + (p.y_off-1)
			else
				proposed_y = p.y 
			end		

		end
		if fget(mget((p.x+p.x_off)/16, (p_down)/16), 0) then
--			p.y = ((math.floor(proposed_y/16))*16)+p.y_off
			if (p.is_dashing) p.vy = -p.vy
		end
	end

	if not box_pushed_x then
		if change_x then
			p.x = proposed_x
		end
	end
	if not box_pushed_y then
		if change_y then
			p.y = proposed_y
		end
	end
end

function hurt_player()
	if (p.is_dashing) return
	p.hp -= 1
	if p.hp <= 0 then
		-- TODO: kill player
	end
	p.invul_t = invul_dly
end

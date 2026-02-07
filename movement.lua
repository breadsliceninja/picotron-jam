--[[pod_format="raw",created="2026-02-07 02:41:15",modified="2026-02-07 02:41:15",revision=0]]
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
	elseif btn(0) then
		p.sx -= a
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
	elseif btn(1) then
		p.sx += a
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
	elseif btn(2) then
		p.sy -= a
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
	elseif btn(3) then
		p.sy += a
	end


	p.sx *= 0.90
	p.sy *= 0.90
	-- if not moving left or right, deccel x axis
--	if not (
--		btn(0) or
--		btn(1) or
--		btn(2) or
--		btn(3)
--		)
--	 then
--	 -- 0.95 for that luigi wavedash feel
--		p.sx *= 0.85
--		p.sy *= 0.85
--	end
	
	
	p.x += mid(-p.smax, p.sx, p.smax)
	p.y += mid(-p.smax, p.sy, p.smax)

end
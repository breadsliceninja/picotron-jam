--[[pod_format="raw",created="2026-02-08 02:15:28",modified="2026-02-08 05:29:23",revision=69]]
function detect_box_solve() 
	corners = {
		mget(b.x/16, b.y/16),
		mget(((b.x+b.width-1)/16), ((b.y)/16)),
		mget((b.x/16), ((b.y+b.height-1)/16)),
		mget(((b.x+b.width-1)/16), ((b.y+b.height-1)/16)),
	}
	
	if fget(corners[1],2) and
		fget(corners[2],2) and
		fget(corners[3],2) and
		fget(corners[4],2) then
			b.solved = 123
	end
	
end

function on_track(pbx, pby) 
	-- pbx = proposed box x, same for y
	corners = {
		mget(pbx/16, pby/16),
		mget(((pbx+b.width-1)/16), (pby/16)),
		mget((pbx/16), ((pby+b.height-1)/16)),
		mget(((pbx+b.width-1)/16), ((pby+b.height-1)/16)),
	}
	if not fget(corners[1], 1) or
		not fget(corners[2], 1) or
		not fget(corners[3], 1) or
		not fget(corners[4], 1) then
			b.on_track = 0
			return false
		end
	b.on_track=1
	return true
end
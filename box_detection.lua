--[[pod_format="raw",created="2026-02-08 02:15:28",modified="2026-02-08 02:15:38",revision=3]]
function detect_box_solve() 
	if mget((b.x/16), (b.y/16)) == 60 and
		mget(((b.x+b.width)/16), (b.y/16)) == 60 and
		mget((b.x/16), ((b.y+b.height)/16)) == 60 and
		mget(((b.x+b.width)/16), ((b.y+b.height)/16)) == 60 
		then
		b.solved = 1
	end
end
--[[pod_format="raw",created="2026-02-09 09:26:29",modified="2026-02-12 08:55:23",revision=21]]
include "math.lua"
function detect_walls(x,y)
    
   -- round x and y to each int
   local x = math.floor(x + 0.5)
   local y = math.floor(y + 0.5)

   -- what map tile is each corner on?   
	corners = {
		mget(x/16, y/16),							-- top left
		mget(((x+p.width-1)/16), ((y)/16)),	-- top right
		mget((x/16), ((y+p.height-1)/16)),					-- bottom left
		mget(((x+p.width-1)/16), ((y+p.height-1)/16)),	-- bottom right
	}
	midpoints = {
		mget((x+p.width/2)/16, y/16), --top middle
		mget((x+p.width/2)/16, (y+p.height-1)/16), --bottom middle
		mget(((x+p.width-1)/16), ((y+p.height/2)/16)), -- right middle
		mget(((x)/16), ((y+p.height/2)/16)), -- left middle
	}
	
	if fget(corners[1],0) or
		fget(corners[2],0) or
		fget(corners[3],0) or
		fget(corners[4],0) or
		fget(midpoints[1],0) or
		fget(midpoints[2],0) or
		fget(midpoints[3],0) or
  		fget(midpoints[4],0)
	 	then
			return true
	end
	return false
end

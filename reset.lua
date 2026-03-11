--[[pod_format="raw",created="2026-03-11 06:49:52",modified="2026-03-11 07:19:59",revision=9]]

function reset_player()
    p.hp = PLAYER_MAX_HEALTH
    p.invul_t = 0 -- invul_dly
    -- set spawn point
    if level == 1 then
        p.x= 64
        p.y =64
    end
    if level == 2 then
        p.x= 272
        p.y =48
    end
    if level == 3 then
        p.x= 160
        p.y =160
    end
end

function reset_box()
    b.solved = 0
    b.x = b.start_x
    b.y = b.start_y
end

function reset_foxes()
    foxes = {
        fox1,
        fox2,
        fox3,
        fox4,
        fox5,
        fox6,
        fox7,
        fox8,
        fox9,
        fox10,
        fox11,
        fox12,
    }
    for i = 1, 12 do
        foxes[i].state = FOX_IDLE
        foxes[i].particle_system = {}  
    end
end
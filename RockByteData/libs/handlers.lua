local _Module = {
    _VERSION = '0.1.0',
    _NAME = 'lib_hdl'
}

local RB_G = require('libs.global')
local RB_U = require('libs.utils')
local util_tbl = require('utils.table')
local util_bas = require('utils.base')
local util_str = require('utils.string')
local util_log = require('utils.logger')
local util_tim = require('utils.time')

function _Module.test(feat)
    -- print("[DBG]", feat.value, unpack({1000, true, "nihao"}))
    RB_U.notify('测试中', RB_G.lvl.INF)
    print('------')
    local uni_tbl = {}
    RB_U.control_npcs(function(data)
        local hash = ped.get_ped_relationship_group_hash(data.ped.id)
        local key = string.format('0x%08x | %010d', hash, hash)
        if not uni_tbl[key] then
            uni_tbl[key] = 0
        end
        uni_tbl[key] = uni_tbl[key] + 1
    end, {
        include_player = true
    })

    RB_U.notify('加载' .. RB_G.cra_typ[feat.value + 1] .. "", RB_G.lvl.INF)
    RB_U.notify('TEST MESSAGE CONTENT, RED NOTIFY', RB_G.lvl.ERR)
    RB_U.notify('TEST MESSAGE CONTENT, YELLOW NOTIFY', RB_G.lvl.WRN)
    RB_U.notify('TEST MESSAGE CONTENT, GREEN NOTIFY', RB_G.lvl.SUC)
    RB_U.notify('TEST MESSAGE CONTENT, BLUE NOTIFY', RB_G.lvl.INF)
    RB_U.notify('TEST MESSAGE CONTENT, PURPLE NOTIFY', RB_G.lvl.DBG)
end

function _Module.loop(feat)
    if not feat.on then
        return
    end
    -- local is_online = network.is_session_started()
    system.yield(RB_G.cfgs:get('MNTR', 'sleep'))
    RB_G.ply.onl = {}
    local god_count = player.player_count() - 1
    for ply_i = 0, RB_G.max_player do
        local ply_info = RB_U.get_player_info_base(ply_i)
        ply_info.status = RB_U.get_player_info_status(ply_i)
        ply_info.mod = RB_U.get_player_info_modder(ply_i)
        local old_ply_info = RB_G.ply.inf[ply_info.name]
        if ply_i == player.player_id() or ply_info.scid <= 0 then
            -- RB_U.menu_set_property(string.format(RB_G.menu_player_keys, ply_i), {
            --     hidden = true
            -- })
            goto continue
        end
        -- RB_U.menu_set_property(string.format(RB_G.menu_player_keys, ply_i), {
        --     hidden = false
        -- })

        RB_G.ply.inf[ply_info.name] = ply_info
        RB_G.ply.onl[ply_info.name] = ply_i
        -- RB_U.menu_set_property(string.format(RB_G.menu_player_keys, ply_i), {
        --     name = ply_info.name
        -- })
        local ply_name = player.get_player_name(ply_i)

        if not RB_G.cfgs:get('MNTR', 'modder_monitor_enable') then
            goto continue
        end
        -- 全局监控部分
        -- if util_tbl.is_empty(RB_G.ply.inf[ply_info.name]) then
        --     RB_G.ply.inf[ply_name] = {
        --         is_idle = false,
        --         is_idle_location = false,
        --         is_god_frist = -1,
        --         mods_flag = 0,
        --         mods_text = {}
        --     }
        -- end
        local ply_is_idle_moved = old_ply_info ~= nil and ply_info.coords == old_ply_info.coords and
                                      old_ply_info.heading == ply_info.heading

        ply_info.marks = {} -- 用来保存用户状态标记
        ply_info.god_log = old_ply_info and old_ply_info.god_log or -1

        -- -- 下面部分是玩家判断部分
        -- -- 玩家标记处理
        if ply_info.status.god then
            god_count = god_count - 1
            table.insert(ply_info.marks, 'G') -- 玩家处于无敌状态
        end
        if (ply_info.coords.z == -180 or ply_info.coords.z == -190 or ply_is_idle_moved) and not ply_info.status.visible then
            RB_G.ply.inf[ply_name].is_idle = true
            ply_info.god_log = os.time()
            if not util_tbl.contains(ply_info.marks, 'I') then
                table.insert(ply_info.marks, 'I') -- 在加载中
            end
            goto continue
        elseif ply_info.status.interior_id ~= 0 or ply_info.status.dead or god_count <= 0 then
            -- 在建筑物中或已死亡跳过作弊检测
            -- 任务部分官方无敌场景状态（佩里克岛进大门、出大门卡住的时候无敌，DC在安全区长廊步行的时候会无敌）
            ply_info.god_log = os.time()
            goto continue
        end

        -- -- 下面部分是作弊检测
        if ply_info.status.god then
            if ply_info.god_log < 0 then
                ply_info.god_log = os.time()
            end
            if os.time() - ply_info.god_log > 30 then
                player.set_player_as_modder(ply_i, RB_G.mod_flg_t2v.GOD_FLAG)
                ply_info.god_log = 9007199254740992
            end
        end

        RB_G.ply.inf[ply_name].mod = RB_U.get_player_info_modder(ply_i)
        local mod_info = RB_G.ply.inf[ply_name].mod
        if RB_G.cfgs:get('MNTR', 'log_enable') and mod_info.is_mod then
            local flags_str = table.concat(mod_info.texts, ', ')
            local plyer_union = string.format('%s[SCID:%s][IP:%s]', ply_name, ply_info.scid, ply_info.ip)
            local hash_str = plyer_union .. flags_str
            if not RB_G.ply_mod_hsh[hash_str] then
                RB_G.ply_mod_hsh[hash_str] = true
                if RB_G.log_obj['modder_monitor'] == nil then
                    RB_G.log_obj['modder_monitor'] = util_log:new('modder_monitor', RB_G.paths.logs)
                end
                RB_G.log_obj['modder_monitor']:log(string.format('检测到 %s 作弊,作弊标记为: %s', plyer_union,
                    flags_str))
            end
        end
        ::continue::
    end
    return HANDLER_CONTINUE
end

function _Module.onli_2prc(feat, pid)
    if player.player_id() == pid then
        RB_U.notify('你正在对自己进行恶意操作!本次操作取消', RB_G.lvl.WRN)
        return
    end
    RB_U.notify('开始操作,请稍后', RB_G.lvl.INF)
    RB_U.send_script_event_by_name(RB_G.eve.nme.send_to_perico_island, pid,
        {pid, RB_G.eve.n2h.send_to_perico_island, 0, 0})
    RB_U.notify('操作完成', RB_G.lvl.SUC)
end

function _Module.onli_2par(feat, pid)
    if player.player_id() == pid then
        RB_U.notify('你正在对自己进行恶意操作!本次操作取消', RB_G.lvl.WRN)
        return
    end
    RB_U.notify('开始操作,请稍后', RB_G.lvl.INF)
    RB_U.send_script_event_by_name(RB_G.eve.nme.send_to_eclipse, pid, {pid, pid, -1, 0, 128, 1, 1, 20})
    RB_U.notify('操作完成', RB_G.lvl.SUC)
end

function _Module.onli_tp2m(feat, pid)
    if player.player_id() == pid then
        RB_U.notify('你正在对自己进行恶意操作!本次操作取消', RB_G.lvl.WRN)
        return
    end
    RB_U.notify('开始操作,请稍后', RB_G.lvl.INF)
    local player_ped = player.get_player_ped(pid)

    local coords = RB_U.gen_player_front_coords(player.player_id())
    local resu = RB_U.teleport(player_ped, v3(coords.x, coords.y, coords.z))
    -- local resu = RB_U.teleport(player_ped, v3(coords.x, coords.y, coords.z), {
    --     before_teleport = function(entity_id, coords, kwargs)
    --         return RB_U.request_control_of_entity(entity_id)
    --     end,
    --     after_teleport = function(entity_id, coords, kwargs)
    --         return RB_U.request_control_of_entity(entity_id)
    --     end
    -- })
    if not resu then
        RB_U.notify(
            '当前无法控制目标.若目标距离过远请观战后传送,目标距离过远,目标不在载具中,目标有控制防护',
            RB_G.lvl.WRN)
        return
    end
    RB_U.notify('操作完成', RB_G.lvl.SUC)
end

function _Module.onli_cras(feat, pid)
    if player.player_id() == pid then
        RB_U.notify('你正在对自己进行恶意操作!本次操作取消', RB_G.lvl.WRN)
        return
    end
    RB_U.notify('开始操作,请稍后', RB_G.lvl.INF)
    RB_U.notify('加载' .. RB_G.cra_typ[feat.value + 1] .. "模块", RB_G.lvl.INF)
    RB_U["game_crashes_" .. RB_G.cra_typ[feat.value + 1]](pid)
    RB_U.notify('操作完成,请耐心等待15秒', RB_G.lvl.SUC)
end

-- -- 原版鬼崩，使用后重启脚本、切换战局自己也会崩溃
-- function _Module.onli_cras(feat, data)
--     RB_U.notify('开始操作,请稍后', RB_G.lvl.INF)
--     local self_player = {id = player.player_id()}
--     self_player.ped = player.get_player_ped(self_player.id)
--     self_player.coords = player.get_player_coords(self_player.id)
--     local targ_player = {id = data.ply_id}
--     targ_player.ped = player.get_player_ped(targ_player.id)
--     targ_player.coords = player.get_player_coords(targ_player.id)

--     if not RB_U.request_model(1784254509) then
--         RB_U.notify('操作失败!请稍后重试', RB_G.lvl.WRN)
--     end
--     local vehicle_id = vehicle.create_vehicle(1784254509, self_player.coords, 1,
--                                               true, false)
--     -- streaming.set_model_as_no_longer_needed(1784254509)
--     network.has_control_of_entity(vehicle_id)
--     entity.set_entity_visible(vehicle_id, false)
--     entity.set_entity_god_mode(vehicle_id, true)
--     network.request_control_of_entity(vehicle_id)
--     entity.attach_entity_to_entity(vehicle_id, self_player.ped, 0,
--                                    v3(0, 0, -10), v3(0.0, 0, 0.0), true, false,
--                                    false, 0, true)
--     system.wait(300)

--     for i = 1, 30 do
--         targ_player.coords = player.get_player_coords(targ_player.id)
--         targ_player.coords.z = targ_player.coords.z - 10
--         entity.set_entity_coords_no_offset(self_player.ped, targ_player.coords)
--         system.wait(50)
--     end
--     entity.set_entity_coords_no_offset(
--         player.get_player_ped(player.player_id()), self_player.coords)

--     RB_U.notify('操作完成,稍等10秒目标游戏将崩溃', RB_G.lvl.SUC)
-- end

-- 好像没用
-- function _Module.onli_set_god(feat, data)
--     RB_U.notify('开始操作,请稍后', RB_G.lvl.INF)
--     local player_ped = player.get_player_ped(data.ply_id)
--     if not RB_U.request_control_of_entity(player_ped) then
--         RB_U.notify('当前无法控制目标', RB_G.lvl.WRN)
--         return
--     end
--     entity.set_entity_god_mode(player_ped, true)
--     if not RB_U.request_control_of_entity(player_ped) then
--         RB_U.notify('操作失败', RB_G.lvl.WRN)
--         return
--     end
--     RB_U.notify('操作完成', RB_G.lvl.SUC)
-- end

-- 好像没用
-- function _Module.onli_teleport2mycar(feat, data)
--     local player_ped = player.get_player_ped(data.ply_id)
--     if not network.request_control_of_entity(player_ped) then
--         RB_U.notify('当前无法控制目标', RB_G.lvl.WRN)
--         return
--     end
--     local self_ped_id = player.get_player_ped(player.player_id())
--     if not ped.is_ped_in_any_vehicle(self_ped_id) then
--         RB_U.notify('请坐上车后再尝试', RB_G.lvl.WRN)
--         return
--     end
--     local vehicle_id = ped.get_vehicle_ped_is_using(self_ped_id)
--     if not vehicle.is_vehicle_full(vehicle_id) then
--         RB_U.notify('车辆已满员', RB_G.lvl.WRN)
--         return
--     end
--     network.request_control_of_entity(vehicle_id)
--     ped.set_ped_into_vehicle(player_ped, vehicle_id,
--                              vehicle.get_free_seat(vehicle_id))
--     RB_U.notify('操作完成', RB_G.lvl.SUC)
-- end

function _Module.mntr_swtc(feat)
    RB_G.cfgs:set('MNTR', 'modder_monitor_enable', feat.on)
    return HANDLER_CONTINUE
end

function _Module.mntr_disp(feat)
    RB_G.cfgs:set('MNTR', 'display', feat.on)
    if RB_G.cfgs:get('MNTR', 'display') then
        local player_number = 0
        for ply_name, v in util_tbl.pairs_sort_by_val(RB_G.ply.onl) do
            local play_inf = RB_G.ply.inf[ply_name]
            local text_layout = RB_U.text_layout:new(RB_G.cfgs:get('MNTR', 'size'), RB_G.cfgs:get('MNTR', 'col_number'),
                RB_G.cfgs:get('MNTR', 'col_height'))
            ui.set_text_color(RB_G.cfgs:get('MNTR', 'red'), RB_G.cfgs:get('MNTR', 'green'),
                RB_G.cfgs:get('MNTR', 'blue'), RB_G.cfgs:get('MNTR', 'alpha'))
            ui.set_text_font(0)
            ui.set_text_wrap(0, 2)
            ui.set_text_outline(true)
            if play_inf.mod.is_mod then
                ui.set_text_color(255, 0, 0, 255)
            end

            local name_prefix = ''
            if not util_tbl.is_empty(play_inf.marks) then
                table.sort(play_inf.marks)
                name_prefix = '[' .. table.concat(play_inf.marks) .. ']'
            end
            text_layout:draw(name_prefix .. ply_name, player_number % RB_G.cfgs:get('MNTR', 'col_number'),
                player_number // RB_G.cfgs:get('MNTR', 'col_number'))
            player_number = player_number + 1
        end
    end
    return HANDLER_CONTINUE
end

function _Module.mntr_mlog(feat)
    RB_G.cfgs:set('MNTR', 'log_enable', feat.on)
end

function _Module.mntr_size(feat)
    RB_G.cfgs:set('MNTR', 'size', feat.value)
end

function _Module.mntr_coln(feat)
    RB_G.cfgs:set('MNTR', 'col_number', feat.value)
end

function _Module.mntr_heig(feat)
    RB_G.cfgs:set('MNTR', 'col_height', feat.value)
end

function _Module.mntr_red(feat)
    RB_G.cfgs:set('MNTR', 'red', feat.value)
end

function _Module.mntr_gren(feat)
    RB_G.cfgs:set('MNTR', 'green', feat.value)
end

function _Module.mntr_blue(feat)
    RB_G.cfgs:set('MNTR', 'blue', feat.value)
end

function _Module.mntr_alph(feat)
    RB_G.cfgs:set('MNTR', 'alpha', feat.value)
end

function _Module.mntr_slep(feat)
    RB_G.cfgs:set('MNTR', 'sleep', feat.value)
end

function _Module.tele_auto(feat)
    RB_G.cfgs:set('TELE', 'auto_teleport', feat.on)
    if not RB_G.cfgs:get('TELE', 'auto_teleport') then
        return
    end
    local coord = ui.get_waypoint_coord()

    if coord.x >= 7500 or coord.x < -6500 or coord.y >= 9500 or coord.y < -6000 then
        -- 检测是否超出地图坐标，避免误传送
        system.yield(500)
        return HANDLER_CONTINUE
    end
    RB_U.teleport(player.get_player_ped(player.player_id()), coord)
    RB_G.last_teleport_time = os.time()
    return HANDLER_CONTINUE
end

function _Module.tele_fowr(feat)
    RB_G.cfgs:set('TELE', 'flash_distance', feat.value)

    local player_id = player.player_id()
    local coords = RB_U.gen_player_front_coords(player_id)
    coords.z = coords.z + 1
    RB_U.teleport(player.get_player_ped(player_id), coords)
    RB_U.notify('操作完成', RB_G.lvl.SUC)
end

function _Module.tele_kosa(feat)
    RB_U.teleport(player.get_player_ped(player.player_id()), v3(1561, 386, -49))
    RB_U.notify('操作完成!如果未提前呼叫虎鲸,任务面板无法加载', RB_G.lvl.SUC)
end

function _Module.wrld_ctrl_rang(feat)
    RB_G.cfgs:set('WRLD', 'control_range', feat.value)
end

function _Module.wrld_npcs_kill(feat)
    RB_G.cfgs:set('WRLD', 'npcs_kill', feat.on)
    if not RB_G.cfgs:get('WRLD', 'npcs_kill') then
        return
    end
    RB_U.control_npcs(function(data)
        ped.set_ped_health(data.ped.id, 0)
    end)
    return HANDLER_CONTINUE
end

function _Module.wrld_npcs_remo(feat)
    RB_G.cfgs:set('WRLD', 'npcs_remove', feat.on)
    if not RB_G.cfgs:get('WRLD', 'npcs_remove') then
        return
    end
    RB_U.control_npcs(function(data)
        RB_U.teleport(data.ped.id, v3(4500, 8000, 2), {
            with_vehicle = false,
            delay = 0
        })
    end)
    return HANDLER_CONTINUE
end

function _Module.wrld_npcs_t2me(feat)
    RB_G.cfgs:set('WRLD', 'npcs_teleport_to_me', feat.on)
    if not RB_G.cfgs:get('WRLD', 'npcs_teleport_to_me') then
        return
    end
    local before_loop = function(data)
        data.to_coords = RB_U.gen_player_front_coords(player.player_id())
    end
    local control = function(data)
        RB_U.teleport(data.ped.id, data.to_coords, {
            with_vehicle = false,
            delay = 0
        })
    end
    RB_U.control_npcs(control, {
        before_loop = before_loop
    })
    return HANDLER_CONTINUE
end

function _Module.wrld_npcs_frze(feat)
    RB_G.cfgs:set('WRLD', 'npcs_freeze', feat.on)
    if not RB_G.cfgs:get('WRLD', 'npcs_freeze') then
        return
    end
    RB_U.control_npcs(function(data)
        ped.clear_ped_tasks_immediately(data.ped.id)
    end)
    return HANDLER_CONTINUE
end

function _Module.wrld_objs_tele(feat)
    RB_G.cfgs:set('WRLD', 'objects_teleport', feat.on)
    if not RB_G.cfgs:get('WRLD', 'objects_teleport') then
        return
    end
    local before_loop = function(data)
        data.to_coords = RB_U.gen_player_front_coords(player.player_id())
    end
    local control = function(data)
        RB_U.teleport(data.object.id, data.to_coords, {
            with_vehicle = false,
            delay = 0
        })
    end
    RB_U.control_objects(control, {
        before_loop = before_loop
    })
    return HANDLER_CONTINUE
end

-- function _Module.wrld_comb(feat)
--     -- 设置NPC战斗方式，没作用
--     RB_G.cfgs:set('WRLD', 'combat_ability', feat.value)
--     RB_G.cfgs:set('WRLD', 'combat_ability_on', feat.on)
--     if not RB_G.cfgs:get('WRLD', 'combat_ability_on') then return end
--     RB_U.control_npcs(function(ped_idx, ped_id)
--         ped.set_ped_combat_ability(ped_id,
--                                    RB_G.cfgs:get('WRLD', 'combat_ability'))
--     end)
--     system.yield(100)
--     return HANDLER_CONTINUE
-- end

-- function _Module.wrld_accu(feat)
--     -- 设置NPC精准度，但好像没作用
--     RB_G.cfgs:set('WRLD', 'accuracy', feat.value)
--     RB_G.cfgs:set('WRLD', 'accuracy_on', feat.on)
--     if not RB_G.cfgs:get('WRLD', 'accuracy_on') then return end
--     RB_U.control_npcs(function(ped_idx, ped_id)
--         ped.set_ped_accuracy(ped_id, RB_G.cfgs:get('WRLD', 'accuracy'))
--     end)
--     system.yield(100)
--     return HANDLER_CONTINUE
-- end

function _Module.stat_addt(feat)
    if feat.value == 0 then
        RB_U.notify(
            '如果你是第一次知道这个东西或者你不知道这个东西的作用和后果请不要继续.乱改时间有可能导致封号!\n修改方式是在原来在线时间的基础上增加指定的在线时长.该操作会修改这两个值"GTA在线模式中花费的时间"和当前"角色使用时间"',
            RB_G.lvl.INF, {
                seconds = 30
            })
        return
    end
    local time_ms = {3600000, 3600000 * 24, 3600000 * 24 * 7, 3600000 * 24 * 30, 3600000 * 24 * 30 * 3,
                     3600000 * 24 * 30 * 6, 3600000 * 24 * 30 * 12}
    local playing_ms
    local mp_total_ms
    if not RB_U.control_stats(function(args)
        playing_ms = args.get_u64(args.hash('MP_PLAYING_TIME', {
            is_mp = false
        })) + time_ms[feat.value]
        args.set_u64(args.hash('MP_PLAYING_TIME', {
            is_mp = false
        }), playing_ms, 1)
        mp_total_ms = args.get_u64(args.hash('TOTAL_PLAYING_TIME')) + time_ms[feat.value]
        args.set_u64(args.hash('TOTAL_PLAYING_TIME'), mp_total_ms, 1)
        return true
    end) then
        return
    end
    local playing_time = util_tim.date2string(util_tim.ms2date(playing_ms, {
        only = {util_tim.day, util_tim.hor, util_tim.min, util_tim.sec}
    }))
    local mp_total_time = util_tim.date2string(util_tim.ms2date(mp_total_ms, {
        only = {util_tim.day, util_tim.hor, util_tim.min, util_tim.sec}
    }))
    RB_U.notify(string.format(
        '操作成功!\n当前游戏在线时间为: %s\n当前角色使用时间为: %s\n请使用ALT+F4并等待右下角圆圈消失后完成保存',
        playing_time, mp_total_time), RB_G.lvl.SUC)
end

function _Module.stat_rdct(feat)
    if feat.value == 0 then
        RB_U.notify(
            '如果你是第一次知道这个东西或者你不知道这个东西的作用和后果请不要继续, 乱改时间有可能导致封号!\n修改方式是在原来在线时间的基础上减少指定的在线时长. 该操作会修改这两个值 "GTA在线模式中花费的时间" 和当前 "角色使用时间"',
            RB_G.lvl.INF, {
                seconds = 30
            })
        return
    end
    local time_ms = {3600000, 3600000 * 24, 3600000 * 24 * 7, 3600000 * 24 * 30, 3600000 * 24 * 30 * 3,
                     3600000 * 24 * 30 * 6, 3600000 * 24 * 30 * 12}
    local playing_ms
    local mp_total_ms
    if not RB_U.control_stats(function(args)
        local cur_playing_ms = args.get_u64(args.hash('MP_PLAYING_TIME', {
            is_mp = false
        }))
        if cur_playing_ms < time_ms[feat.value] then
            RB_U.notify('当前在线时长不足! 你到底懂不懂这是什么?', RB_G.lvl.WRN)
            return
        end
        playing_ms = cur_playing_ms - time_ms[feat.value]
        args.set_u64(args.hash('MP_PLAYING_TIME', {
            is_mp = false
        }), playing_ms, 1)
        mp_total_ms = args.get_u64(args.hash('TOTAL_PLAYING_TIME')) - time_ms[feat.value]
        args.set_u64(args.hash('TOTAL_PLAYING_TIME'), mp_total_ms, 1)
        return true
    end) then
        return
    end
    local playing_time = util_tim.date2string(util_tim.ms2date(playing_ms, {
        only = {util_tim.day, util_tim.hor, util_tim.min, util_tim.sec}
    }))
    local mp_total_time = util_tim.date2string(util_tim.ms2date(mp_total_ms, {
        only = {util_tim.day, util_tim.hor, util_tim.min, util_tim.sec}
    }))
    RB_U.notify(string.format(
        '操作成功!\n当前游戏在线时间为: %s\n当前角色使用时间为: %s\n请使用ALT+F4并等待右下角圆圈消失后完成保存',
        playing_time, mp_total_time), RB_G.lvl.SUC)
end

function _Module.char_judg_swtc(feat)
    RB_G.cfgs:set('CHAR', 'chat_judge_enable', feat.on)
    if RB_G.cfgs:get('CHAR', 'chat_judge_enable') then
        RB_G.eve_lis.chat_judge = event.add_event_listener("chat", function(eve)
            for _, value in ipairs(RB_G.jud_kws) do
                if value ~= '' and util_str.contains(eve.body, value, true) then
                    if RB_G.cfgs:get('CHAR', 'chat_judge_type') == 0 then
                        RB_U.game_crashes_kek(eve.player)
                    elseif RB_G.cfgs:get('CHAR', 'chat_judge_type') == 1 then
                        RB_U.game_crashes_mmt(eve.player)
                    else
                        RB_U.notify(string.format('未知的审判方式! 取消操作',
                            player.get_player_name(eve.player), value), RB_G.lvl.SUC)
                        break
                    end
                    if _Module.char_judg_noti then
                        RB_U.notify(string.format('聊天审判玩家: %s, 触发规则: %s',
                            player.get_player_name(eve.player), value), RB_G.lvl.SUC)
                    end
                    break
                end
            end
        end)
    else
        event.remove_event_listener("chat", RB_G.eve_lis.chat_judge)
    end
end

function _Module.char_judg_type(feat)
    RB_G.cfgs:set('CHAR', 'chat_judge_type', feat.value)
end

function _Module.char_judg_noti(feat)
    RB_G.cfgs:set('CHAR', 'chat_judge_notice', feat.on)
end

function _Module.char_judg_keys_add(feat)
    local respone, data = nil, nil
    while true do
        respone, data = input.get("输入新的审判关键字", "", 20, 0)
        if respone == 1 then
            system.yield(100)
        elseif respone == 2 then
            return
        else
            break
        end
    end
    table.insert(RB_G.jud_kws, data)
    _Module.refresh_chat_judge_keywords()
end

function _Module.char_warn_msgs(feat)
    RB_U.notify('不确定这个功能要不要添加, 做人可能低调点好', RB_G.lvl.INF)
end

function _Module.char_warn_glob(feat)
    RB_U.notify('不确定这个功能要不要添加, 做人可能低调点好', RB_G.lvl.INF)
end

function _Module.char_judg_keys_hand(feat)
    if feat.value == 0 then
        local respone, data = nil, nil
        while true do
            respone, data = input.get('输入新的审判关键字', RB_G.jud_kws[feat.data.index], 20, 0)
            if respone == 1 then
                system.yield(100)
            elseif respone == 2 then
                return
            else
                break
            end
        end
        RB_G.jud_kws[feat.data.index] = data
    elseif feat.value == 1 then
        local tmp_keys = {}
        for index, value in ipairs(RB_G.jud_kws) do
            if index ~= feat.data.index then
                table.insert(tmp_keys, value)
            end
        end
        RB_G.jud_kws = tmp_keys
    end
    _Module.refresh_chat_judge_keywords()
end

function _Module.heis_part_paym(feat)
    local respone, data = nil, nil
    while true do
        respone, data = input.get('输入分红百分比', '85', 10, 0)
        if respone == 1 then
            system.yield(100)
        elseif respone == 2 then
            return
        else
            break
        end
    end
    local payment = tonumber(data)
    script.set_global_i(1934631 + 3008 + 1, payment)
end

function _Module.heis_diam_paym(feat)
    local respone, data = nil, nil
    while true do
        respone, data = input.get('输入分红百分比', '85', 10, 0)
        if respone == 1 then
            system.yield(100)
        elseif respone == 2 then
            return
        else
            break
        end
    end
    local payment = tonumber(data)
    for i = 1, player.player_count() do
        script.set_global_i(1966718 + 2325 + i, payment)
    end
end

function _Module.heis_peri_paym(feat)
    local respone, data = nil, nil
    while true do
        respone, data = input.get('输入分红百分比', '85', 10, 0)
        if respone == 1 then
            system.yield(100)
        elseif respone == 2 then
            return
        else
            break
        end
    end
    local payment = tonumber(data)
    for i = 1, player.player_count() do
        script.set_global_i(1973496 + 823 + 56 + i, payment)
    end
end

function _Module.heis_doom_paym(feat)
    local respone, data = nil, nil
    while true do
        respone, data = input.get('输入分红百分比', '85', 10, 0)
        if respone == 1 then
            system.yield(100)
        elseif respone == 2 then
            return
        else
            break
        end
    end
    local payment = tonumber(data)
    for i = 1, player.player_count() do
        script.set_global_i(1962755 + 812 + 50 + i, payment)
    end
end

function _Module.refresh_chat_judge_keywords()
    for index, _ in ipairs(RB_G.menu.char_judg_keys) do
        menu.delete_feature(RB_G.menu.char_judg_keys[index].id)
        RB_G.menu.char_judg_keys[index] = nil
    end
    for index, value in ipairs(RB_G.jud_kws) do
        RB_G.menu.char_judg_keys[index] = menu.add_feature(value, 'action_value_str', RB_G.menu.char_judg.id,
            _Module.char_judg_keys_hand)
        RB_G.menu.char_judg_keys[index].data = {
            index = index,
            value = value
        }
        RB_G.menu.char_judg_keys[index]:set_str_data({'修改', '删除'})
    end
end

function _Module.sett_save(feat)
    RB_G.cfgs:set('CHAR', 'chat_judge_keywords', table.concat(RB_G.jud_kws, ', '))
    RB_G.cfgs:save()
    RB_U.notify('设置保存成功', RB_G.lvl.SUC)
end

return _Module

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
local util_num = require('utils.number')

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
            -- RB_U.menu_set(string.format(RB_G.menu_player_keys, ply_i), {
            --     hidden = true
            -- })
            goto continue
        end

        RB_G.ply.inf[ply_info.name] = ply_info
        RB_G.ply.onl[ply_info.name] = ply_i
        local ply_name = ply_info.name
        -- RB_U.menu_set(string.format(RB_G.menu_player_keys, ply_i), {
        --     hidden = false
        --     name = ply_info.name
        -- })

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

function _Module.online_to_cayo(feat, pid)
    if player.player_id() == pid then
        RB_U.notify('你正在对自己进行恶意操作!本次操作取消', RB_G.lvl.WRN)
        return
    end
    RB_U.notify('开始操作,请稍后', RB_G.lvl.INF)
    RB_U.send_script_event_by_name(RB_G.eve.nme.send_to_perico_island, pid,
        { pid, RB_G.eve.n2h.send_to_perico_island, 0, 0 })
    RB_U.notify('操作完成', RB_G.lvl.SUC)
end

function _Module.online_to_apartment(feat, pid)
    if player.player_id() == pid then
        RB_U.notify('你正在对自己进行恶意操作!本次操作取消', RB_G.lvl.WRN)
        return
    end
    RB_U.notify('开始操作,请稍后', RB_G.lvl.INF)
    RB_U.send_script_event_by_name(RB_G.eve.nme.send_to_eclipse, pid, { pid, pid, -1, 0, 128, 1, 1, 20 })
    RB_U.notify('操作完成', RB_G.lvl.SUC)
end

function _Module.online_teleport2me(feat, pid)
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

function _Module.online_remove_god(feat, pid)
    -- 未经实验函数
    if player.player_id() == pid then
        RB_U.notify('你正在对自己进行恶意操作!本次操作取消', RB_G.lvl.WRN)
        return
    end
    while feat.on do
        RB_U.send_script_event(801199324, pid, { pid, 869796886, 0 })
        system.yield(10)
    end
end

function _Module.online_crashes(feat, pid)
    if player.player_id() == pid then
        RB_U.notify('你正在对自己进行恶意操作!本次操作取消', RB_G.lvl.WRN)
        return
    end
    RB_U.notify('加载' .. RB_G.cra_typ[feat.value + 1] .. "模块", RB_G.lvl.INF)
    if not RB_U["game_crashes_" .. RB_G.cra_typ[feat.value + 1]](pid) then
        return
    end
    RB_U.notify('操作完成,请耐心等待15秒', RB_G.lvl.SUC)
end

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
end

function _Module.wrld_objs_tele_me(feat)
    local control = function(data)
        if RB_G.world.pickup_log[data.object.id] and os.time() - RB_G.world.pickup_log[data.object.id] < 15 then -- 避免15s内传送到相同的物品
            return true
        end
        if data.object.id < 2 then -- 避免传送到自己身上的物品处
            return true
        end
        -- data.object.coords.x = data.object.coords.x + 2
        -- data.object.coords.y = data.object.coords.y + 2
        data.object.coords.z = data.object.coords.z + 2
        RB_U.teleport(data.player.ped, data.object.coords, {
            delay = 0
        })
        RB_G.world.pickup_log[data.object.id] = os.time()
        return false
    end
    RB_U.control_objects(control)
end

function _Module.stat_addt(feat)
    if feat.value == 0 then
        RB_U.notify(
            '如果你是第一次知道这个东西或者你不知道这个东西的作用和后果请不要继续.乱改时间有可能导致封号!\n修改方式是在原来在线时间的基础上增加指定的在线时长.该操作会修改这两个值"GTA在线模式中花费的时间"和当前"角色使用时间"',
            RB_G.lvl.INF, {
            seconds = 30
        })
        return
    end
    local time_ms = { 3600000, 3600000 * 24, 3600000 * 24 * 7, 3600000 * 24 * 30, 3600000 * 24 * 30 * 3,
        3600000 * 24 * 30 * 6, 3600000 * 24 * 30 * 12 }
    local playing_ms
    local mp_total_ms
    if not RB_U.control_stats(function(args)
        playing_ms = args.get_u64(args.hash('MP_PLAYING_TIME', {
            is_mp = false
        })) + time_ms[feat.value]
        args.set_u64(args.hash('MP_PLAYING_TIME', {
            is_mp = false
        }), playing_ms, 1)
        mp_total_ms = args.get_u64('TOTAL_PLAYING_TIME') + time_ms[feat.value]
        args.set_u64('TOTAL_PLAYING_TIME', mp_total_ms, 1)
        return true
    end) then
        return
    end
    local playing_time = util_tim.date2string(util_tim.ms2date(playing_ms, {
        only = { util_tim.day, util_tim.hor, util_tim.min, util_tim.sec }
    }))
    local mp_total_time = util_tim.date2string(util_tim.ms2date(mp_total_ms, {
        only = { util_tim.day, util_tim.hor, util_tim.min, util_tim.sec }
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
    local time_ms = { 3600000, 3600000 * 24, 3600000 * 24 * 7, 3600000 * 24 * 30, 3600000 * 24 * 30 * 3,
        3600000 * 24 * 30 * 6, 3600000 * 24 * 30 * 12 }
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
        mp_total_ms = args.get_u64('TOTAL_PLAYING_TIME') - time_ms[feat.value]
        args.set_u64('TOTAL_PLAYING_TIME', mp_total_ms, 1)
        return true
    end) then
        return
    end
    local playing_time = util_tim.date2string(util_tim.ms2date(playing_ms, {
        only = { util_tim.day, util_tim.hor, util_tim.min, util_tim.sec }
    }))
    local mp_total_time = util_tim.date2string(util_tim.ms2date(mp_total_ms, {
        only = { util_tim.day, util_tim.hor, util_tim.min, util_tim.sec }
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

function _Module.heist_apartment_cut(feat)
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
    script.set_global_i(1937645, payment)
end

function _Module.heist_casino_cut(feat)
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
        script.set_global_i(1969065 + i, payment)
    end
end

function _Module.heist_doomsday_cut(feat)
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
        script.set_global_i(1963625 + i, payment)
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
        RB_G.menu.char_judg_keys[index]:set_str_data({ '修改', '删除' })
    end
end

function _Module.heist_cayo_cut(feat)
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
        script.set_global_i(1974404 + i, payment)
    end
end

function _Module.heist_cayo_mode(feat)
    RB_G.cfgs:set('HEIST', 'cayo_mode', feat.value)
    RB_G.cfgs:set('HEIST', 'cayo_mode_on', feat.on)
end

function _Module.heist_cayo_pretask(feat)
    RB_G.cfgs:set('HEIST', 'cayo_pretask_on', feat.on)
end

function _Module.heist_cayo_target(feat)
    RB_G.cfgs:set('HEIST', 'cayo_target', feat.value)
    RB_G.cfgs:set('HEIST', 'cayo_target_on', feat.on)
end

function _Module.heist_cayo_c_cash(feat)
    -- local old_number = RB_G.cfgs:get('HEIST', 'cayo_cash_c_number')
    -- local old_on = RB_G.cfgs:get('HEIST', 'cayo_cash_c_on')
    -- if RB_U.is_cayo_point_over_c() then
    --     feat.value = old_number
    --     feat.on = old_on
    --     RB_G.cfgs:set('HEIST', 'cayo_cash_c_number', old_number)
    --     RB_G.cfgs:set('HEIST', 'cayo_cash_c_on', old_on)
    --     return
    -- end
    RB_G.cfgs:set('HEIST', 'cayo_cash_c_number', feat.value)
    RB_G.cfgs:set('HEIST', 'cayo_cash_c_on', feat.on)
end

function _Module.heist_cayo_i_cash(feat)
    -- local old_number = RB_G.cfgs:get('HEIST', 'cayo_cash_i_number')
    -- local old_on = RB_G.cfgs:get('HEIST', 'cayo_cash_i_on')
    -- if RB_U.is_cayo_point_over_i() then
    --     feat.value = old_number
    --     feat.on = old_on
    --     RB_G.cfgs:set('HEIST', 'cayo_cash_i_number', old_number)
    --     RB_G.cfgs:set('HEIST', 'cayo_cash_i_on', old_on)
    --     return
    -- end
    RB_G.cfgs:set('HEIST', 'cayo_cash_i_number', feat.value)
    RB_G.cfgs:set('HEIST', 'cayo_cash_i_on', feat.on)
end

function _Module.heist_cayo_weed(feat)
    -- local old_number = RB_G.cfgs:get('HEIST', 'cayo_weed_number')
    -- local old_on = RB_G.cfgs:get('HEIST', 'cayo_weed_on')
    -- RB_G.cfgs:set('HEIST', 'cayo_weed_number', feat.value)
    -- RB_G.cfgs:set('HEIST', 'cayo_weed_on', feat.on)
    -- if RB_U.is_cayo_point_over_i() then
    --     feat.value = old_number
    --     feat.on = old_on
    --     RB_G.cfgs:set('HEIST', 'cayo_weed_number', old_number)
    --     RB_G.cfgs:set('HEIST', 'cayo_weed_on', old_on)
    --     return
    -- end
    RB_G.cfgs:set('HEIST', 'cayo_weed_number', feat.value)
    RB_G.cfgs:set('HEIST', 'cayo_weed_on', feat.on)
end

function _Module.heist_cayo_coke(feat)
    -- local old_number = RB_G.cfgs:get('HEIST', 'cayo_coke_number')
    -- local old_on = RB_G.cfgs:get('HEIST', 'cayo_coke_on')
    -- RB_G.cfgs:set('HEIST', 'cayo_coke_number', feat.value)
    -- RB_G.cfgs:set('HEIST', 'cayo_coke_on', feat.on)
    -- if RB_U.is_cayo_point_over_i() then
    --     feat.value = old_number
    --     feat.on = old_on
    --     RB_G.cfgs:set('HEIST', 'cayo_coke_number', old_number)
    --     RB_G.cfgs:set('HEIST', 'cayo_coke_on', old_on)
    --     return
    -- end
    RB_G.cfgs:set('HEIST', 'cayo_coke_number', feat.value)
    RB_G.cfgs:set('HEIST', 'cayo_coke_on', feat.on)
end

function _Module.heist_cayo_gold(feat)
    -- local old_number = RB_G.cfgs:get('HEIST', 'cayo_gold_number')
    -- local old_on = RB_G.cfgs:get('HEIST', 'cayo_gold_on')
    -- if RB_U.is_cayo_point_over_c() then
    --     feat.value = old_number
    --     feat.on = old_on
    --     RB_G.cfgs:set('HEIST', 'cayo_gold_number', old_number)
    --     RB_G.cfgs:set('HEIST', 'cayo_gold_on', old_on)
    --     return
    -- end
    RB_G.cfgs:set('HEIST', 'cayo_gold_number', feat.value)
    RB_G.cfgs:set('HEIST', 'cayo_gold_on', feat.on)
end

function _Module.heist_cayo_paint(feat)
    RB_G.cfgs:set('HEIST', 'cayo_paint_number', feat.value)
    RB_G.cfgs:set('HEIST', 'cayo_paint_on', feat.on)
end

function _Module.heist_cayo_vehicle(feat)
    RB_G.cfgs:set('HEIST', 'cayo_vehicle', feat.value)
    RB_G.cfgs:set('HEIST', 'cayo_vehicle_on', feat.on)
end

function _Module.heist_cayo_weapon(feat)
    RB_G.cfgs:set('HEIST', 'cayo_weapon', feat.value)
    RB_G.cfgs:set('HEIST', 'cayo_weapon_on', feat.on)
end

function _Module.heist_cayo_truck(feat)
    RB_G.cfgs:set('HEIST', 'cayo_truck', feat.value)
    RB_G.cfgs:set('HEIST', 'cayo_truck_on', feat.on)
end

function _Module.heist_cayo_disturb(feat)
    RB_G.cfgs:set('HEIST', 'cayo_disturb_on', feat.on)
end

function _Module.heist_cayo_interest(feat)
    RB_G.cfgs:set('HEIST', 'cayo_interest_on', feat.on)
end

function _Module.heist_cayo_enable(feat)
    -- 这个函数逻辑搞得太复杂了，短期不再继续修改
    RB_U.notify('操作中请稍后', RB_G.lvl.INF)
    local is_exit = false
    RB_U.control_stats(function(args)
        if args.get_int('H4_PROGRESS', 0) % 2 == 0 then
            is_exit = true
        end
    end)
    if is_exit then
        RB_U.notify('请支付准备任务金额后再使用', RB_G.lvl.WRN)
        return
    end

    if RB_U.is_cayo_point_over_c() or RB_U.is_cayo_point_over_i() then
        RB_U.notify('操作取消!请修正数据后继续', RB_G.lvl.WRN)
        return
    end
    RB_G.heist.cayo.second_i.log = 0
    RB_G.heist.cayo.second_c.log = 0
    local is_edited = false
    if RB_G.cfgs:get('HEIST', 'cayo_mode_on') then
        RB_U.control_stats(function(args)
            local h4_pro = args.get_int('H4_PROGRESS', 0)
            if RB_G.cfgs:get('HEIST', 'cayo_mode') == 0 then
                return args.set_int('H4_PROGRESS', h4_pro & 126975, true)
            elseif RB_G.cfgs:get('HEIST', 'cayo_mode') == 1 then
                return args.set_int('H4_PROGRESS', h4_pro | 4096, true)
            end
        end)
        is_edited = true
    end
    if RB_G.cfgs:get('HEIST', 'cayo_pretask_on') then
        RB_U.control_stats(function(args)
            local h4_mis = args.get_int('H4_MISSIONS', 0)
            args.set_int('H4_MISSIONS', h4_mis | 3841, true)
        end)
        is_edited = true
    end
    if RB_G.cfgs:get('HEIST', 'cayo_target_on') then
        RB_U.control_stats(function(args)
            return args.set_int('H4CNF_TARGET', RB_G.cfgs:get('HEIST', 'cayo_target'), true)
        end)
        is_edited = true
    end
    -- 花了三天来设计，感觉有点不值
    -- 豪宅外最大放置情况：16777215 -> 111111111111111111111111
    -- 豪宅内最大放置情况：255 -> 11111111
    -- 豪宅内画作最大放置情况：127 -> 1111111
    -- 豪宅外正常放置个数：8-16
    -- 豪宅内正常放置个数：3-6
    -- 豪宅内正常画作个数：2-4
    -- 说明：-1解锁所有点位，推测实际应该是uint型
    if RB_G.cfgs:get('HEIST', 'cayo_cash_c_on') then
        RB_U.mod_cayo_point(RB_G.cfgs:get('HEIST', 'cayo_cash_c_number') * 2, 'H4LOOT_CASH_C', RB_G.heist.cayo.second_c)
        is_edited = true
    end
    if RB_G.cfgs:get('HEIST', 'cayo_gold_on') then
        RB_U.mod_cayo_point(RB_G.cfgs:get('HEIST', 'cayo_gold_number') * 2, 'H4LOOT_GOLD_C', RB_G.heist.cayo.second_c)
        is_edited = true
    end
    if RB_G.cfgs:get('HEIST', 'cayo_cash_i_on') then
        RB_U.mod_cayo_point(RB_G.cfgs:get('HEIST', 'cayo_cash_i_number') * 3, 'H4LOOT_CASH_I', RB_G.heist.cayo.second_i)
        is_edited = true
    end
    if RB_G.cfgs:get('HEIST', 'cayo_weed_on') then
        RB_U.mod_cayo_point(RB_G.cfgs:get('HEIST', 'cayo_weed_number') * 3, 'H4LOOT_WEED_I', RB_G.heist.cayo.second_i)
        is_edited = true
    end
    if RB_G.cfgs:get('HEIST', 'cayo_coke_on') then
        RB_U.mod_cayo_point(RB_G.cfgs:get('HEIST', 'cayo_coke_number') * 3, 'H4LOOT_COKE_I', RB_G.heist.cayo.second_i)
        is_edited = true
    end
    if RB_G.cfgs:get('HEIST', 'cayo_paint_on') then
        RB_U.mod_cayo_point(RB_G.cfgs:get('HEIST', 'cayo_paint_number') * 3, 'H4LOOT_PAINT', RB_G.heist.cayo.second_i)
        is_edited = true
    end
    if RB_G.cfgs:get('HEIST', 'cayo_vehicle_on') then
        RB_U.control_stats(function(args)
            local vehicle = { 2, 132, 8, 144, 32, 64, 254 }
            local h4_mis = args.get_int('H4_MISSIONS', 0)
            return args.set_int('H4_MISSIONS', h4_mis | vehicle[RB_G.cfgs:get('HEIST', 'cayo_vehicle') + 1], true)
        end)
        is_edited = true
    end
    if RB_G.cfgs:get('HEIST', 'cayo_weapon_on') then
        RB_U.control_stats(function(args)
            local h4_mis = args.get_int('H4_MISSIONS', 0)
            args.set_int('H4_MISSIONS', h4_mis | 4096, true)
            local h4_pro = args.get_int('H4_PROGRESS', 0)
            args.set_int('H4_PROGRESS', h4_pro | 16384, true)
            return args.set_int('H4CNF_WEAPONS', RB_G.cfgs:get('HEIST', 'cayo_weapon') + 1, true)
        end)
        is_edited = true
    end
    if RB_G.cfgs:get('HEIST', 'cayo_truck_on') then
        RB_U.control_stats(function(args)
            return args.set_int('H4CNF_TROJAN', RB_G.cfgs:get('HEIST', 'cayo_truck') + 1, true)
        end)
        is_edited = true
    end
    if RB_G.cfgs:get('HEIST', 'cayo_interest_on') then
        RB_U.control_stats(function(args)
            args.set_int('H4CNF_BS_GEN', 126975, true)
            args.set_int('H4CNF_BS_ABIL', 63, true)
        end)
        is_edited = true
    end
    if RB_G.cfgs:get('HEIST', 'cayo_disturb_on') then
        RB_U.control_stats(function(args)
            local h4_mis = args.get_int('H4_MISSIONS', 0)
            args.set_int('H4_MISSIONS', h4_mis | 57344, true)
            local h4_pro = args.get_int('H4_PROGRESS', 0)
            args.set_int('H4_PROGRESS', h4_pro | 16384, true)
            args.set_int('H4CNF_WEP_DISRP', 3, true)
            args.set_int('H4CNF_ARM_DISRP', 3, true)
            args.set_int('H4CNF_HEL_DISRP', 3, true)
        end)
        is_edited = true
    end
    if not is_edited then
        RB_U.notify('无任何修改,本次操作取消', RB_G.lvl.WRN)
        return
    end
    RB_U.fix_cayo_point()
    RB_U.notify('操作成功,如果控制面板未刷新请重新进入虎鲸', RB_G.lvl.SUC)
end

function _Module.setting_reset(feat, kwargs)
    kwargs = kwargs or {}
    kwargs.enforce = kwargs.enforce == nil and true or kwargs.enforce
    for _, val in ipairs({ { 'PROG', 'debug', false }, { 'TELE', 'flash_distance', 3 }, { 'TELE', 'auto_teleport', false },
        { 'MNTR', 'modder_monitor_enable', false }, { 'MNTR', 'display', false },
        { 'MNTR', 'log_enable', false }, { 'MNTR', 'size', 12 }, { 'MNTR', 'col_number', 16 },
        { 'MNTR', 'col_height', 1.5 }, { 'MNTR', 'red', 255 }, { 'MNTR', 'green', 255 },
        { 'MNTR', 'blue', 255 }, { 'MNTR', 'alpha', 255 }, { 'MNTR', 'sleep', 5000 },
        { 'WRLD', 'npcs_kill', false }, { 'WRLD', 'npcs_remove', false }, { 'WRLD', 'accuracy', 50 },
        { 'WRLD', 'accuracy_on', false }, { 'WRLD', 'npcs_freeze', false },
        { 'WRLD', 'npcs_teleport_to_me', false }, { 'WRLD', 'combat_ability', 0 },
        { 'WRLD', 'combat_ability_on', false }, { 'WRLD', 'control_range', 100 },
        { 'CHAR', 'chat_judge_notice', true }, { 'CHAR', 'chat_judge_type', 0 },
        { 'CHAR', 'chat_judge_keywords', 'www%., GTA%d%d%d, 刷金, q群, 售后, 微信, 淘宝, vx' },
        { 'HEIST', 'cayo_mode', 0 }, { 'HEIST', 'cayo_mode_on', false }, { 'HEIST', 'cayo_target', 0 },
        { 'HEIST', 'cayo_target_on', false }, { 'HEIST', 'cayo_cash_c_number', 0 },
        { 'HEIST', 'cayo_cash_c_on', false }, { 'HEIST', 'cayo_cash_i_number', 0 },
        { 'HEIST', 'cayo_cash_i_on', false }, { 'HEIST', 'cayo_weed_number', 0 },
        { 'HEIST', 'cayo_weed_on', false }, { 'HEIST', 'cayo_coke_number', 0 },
        { 'HEIST', 'cayo_coke_on', false }, { 'HEIST', 'cayo_gold_number', 0 },
        { 'HEIST', 'cayo_gold_on', false }, { 'HEIST', 'cayo_paint_number', 0 },
        { 'HEIST', 'cayo_paint_on', false }, { 'HEIST', 'cayo_vehicle', 0 },
        { 'HEIST', 'cayo_vehicle_on', false }, { 'HEIST', 'cayo_weapon', 0 },
        { 'HEIST', 'cayo_weapon_on', false }, { 'HEIST', 'cayo_truck', 0 },
        { 'HEIST', 'cayo_truck_on', false }, { 'HEIST', 'cayo_pretask_on', false },
        { 'HEIST', 'cayo_disturb_on', false }, { 'HEIST', 'cayo_interest_on', false } }) do
        if RB_G.cfgs:get(val[1], val[2]) == nil or kwargs.enforce then
            RB_G.cfgs:set(val[1], val[2], val[3])
        end
    end
    if kwargs.enforce then
        RB_G.cfgs:save()
    end
    RB_U.notify('设置配置成功,请重新加载脚本', RB_G.lvl.SUC)
end

function _Module.setting_save(feat)
    RB_G.cfgs:set('CHAR', 'chat_judge_keywords', table.concat(RB_G.jud_kws, ', '))
    RB_G.cfgs:save()
    RB_U.notify('设置保存成功', RB_G.lvl.SUC)
end

-- -- 原版鬼崩，使用后重启脚本、切换战局自己也会崩溃
-- function _Module.online_crashes(feat, data)
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
-- function _Module.online_set_god(feat, data)
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
-- function _Module.online_teleport2mycar(feat, data)
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

return _Module

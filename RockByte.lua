if __ROCKBITE_VERSION then
    menu.notify('菜单已经在运行,请勿重复加载', 'RB-WRN-取消初始化', 5, 0x0080ff)
    return
end

__ROCKBITE_VERSION = '0.1.8'

-- todo: 在线时长修改
-- todo: 聊天审批

collectgarbage("incremental", 100)
math.randomseed(math.floor(os.clock()) + os.time())

local paths = {
    take1_home = utils.get_appdata_path('PopstarDevs', '2Take1Menu')
}

paths.home = paths.take1_home .. '\\scripts\\RockByteData'
paths.utils = paths.home .. '\\utils'
paths.logs = paths.home .. '\\logs'
paths.configs = paths.home .. '\\configs.ini'
paths.libs = paths.home .. '\\libs'

-- 加载模块路径
if not (package.path or ''):find(paths.home .. '\\?.lua;') then
    package.path = paths.home .. '\\?.lua;' .. package.path
end
-- for i, v in ipairs({
--     table.concat({paths.libs, '\\?.lua;'}),
--     table.concat({paths.utils, '\\?.lua;'})
-- }) do
--     if not (package.path or ''):find(v, 1, true) then
--         package.path = table.concat({v, package.path})
--     end
-- end

local util_ini = nil
local util_bas = nil
local util_str = nil
local util_num = nil
local RB_G = nil
local RB_U = nil
local RB_H = nil

do -- 确保每个被加载一次，每次需要一个库时，都有与其他库相同的环境。
    local original_require = require
    require = function(name)
        local lib = package.loaded[name] or original_require(name)
        if not lib then
            print(string.format('an error occurred. loading the "%s" module.', name))

            local err = select(3, loadfile(table.concat({paths.home, '\\', string.gsub(name, '%.', '\\'), '.lua'}))) -- 2take1的自定义require函数不允许获得错误。
            error(err)
        end
        if not package.loaded[name] then
            package.loaded[name] = lib
        end
        return package.loaded[name]
    end

    util_bas = require('utils.base')
    util_ini = require('utils.ini')
    util_str = require('utils.string')
    util_num = require('utils.number')
    RB_G = require('libs.global')
    RB_U = require('libs.utils')
    RB_H = require('libs.handlers')

    require = original_require
end

-- 初始化配置文件
RB_G.cfgs = util_ini:new(paths.configs)
RB_H.setting_reset(nil, {
    enforce = false
})

-- 目录记录到全局变量中
for k, v in pairs(paths) do
    if type(v) == 'string' then
        RB_G.paths[k] = v
        if k ~= 'configs' then
            RB_U.dirs_auto_maker(v)
        end
    end
end

-- 菜单绑定
RB_U.menus_add({'main', 'RockByte', 'parent', 0}, {'loop', '监控循环', 'toggle', 0, RB_H.loop})
RB_G.menu.loop.hidden = true
RB_G.menu.loop.on = true

RB_U.menus_add({'test', '测试菜单', 'action', RB_G.menu.main.id, function(feat)
    RB_U.notify('测试中,这个按钮无任何实际用处,日常测试用,请玩家忽略', RB_G.lvl.INF)

    RB_U.control_stats(function(args)
        util_bas.print('H4CNF_BS_GEN:', util_num.to_bin(args.get_int('H4CNF_BS_GEN', 0)), 'H4CNF_BS_ENTR:',
            util_num.to_bin(args.get_int('H4CNF_BS_ENTR', 0)), 'H4CNF_BS_ABIL:',
            util_num.to_bin(args.get_int('H4CNF_BS_ABIL', 0)), 'H4CNF_APPROACH:',
            util_num.to_bin(args.get_int('H4CNF_APPROACH', 0)), 'H4CNF_WEP_DISRP:',
            util_num.to_bin(args.get_int('H4CNF_WEP_DISRP', 0)), 'H4CNF_ARM_DISRP:',
            util_num.to_bin(args.get_int('H4CNF_ARM_DISRP', 0)), 'H4CNF_HEL_DISRP:',
            util_num.to_bin(args.get_int('H4CNF_HEL_DISRP', 0)), 'H4CNF_GRAPPEL:',
            util_num.to_bin(args.get_int('H4CNF_GRAPPEL', 0)), 'H4CNF_UNIFORM:',
            util_num.to_bin(args.get_int('H4CNF_UNIFORM', 0)), 'H4CNF_BOLTCUT:',
            util_num.to_bin(args.get_int('H4CNF_BOLTCUT', 0)), 'H4CNF_TROJAN:',
            util_num.to_bin(args.get_int('H4CNF_TROJAN', 0)), 'H4_MISSIONS:',
            util_num.to_bin(args.get_int('H4_MISSIONS', 0)), 'H4_PROGRESS:',
            util_num.to_bin(args.get_int('H4_PROGRESS', 0)), 'H4CNF_TARGET:',
            util_num.to_bin(args.get_int('H4CNF_TARGET', 0)), 'H4CNF_WEAPONS:',
            util_num.to_bin(args.get_int('H4CNF_WEAPONS', 0)), 'H4_PLAYTHROUGH_STATUS:',
            util_num.to_bin(args.get_int('H4_PLAYTHROUGH_STATUS', 0)))
    end)

    RB_U.notify('TEST MESSAGE CONTENT, RED NOTIFY', RB_G.lvl.ERR)
    RB_U.notify('TEST MESSAGE CONTENT, YELLOW NOTIFY', RB_G.lvl.WRN)
    RB_U.notify('TEST MESSAGE CONTENT, GREEN NOTIFY', RB_G.lvl.SUC)
    RB_U.notify('TEST MESSAGE CONTENT, BLUE NOTIFY', RB_G.lvl.INF)
    RB_U.notify('TEST MESSAGE CONTENT, PURPLE NOTIFY', RB_G.lvl.DBG)
end})
-- RB_G.menu.test:set_str_data(RB_G.cra_typ)

RB_U.menus_add({'mntr', '作弊监控', 'parent', 'main'},
    {'mntr_swtc', '开启监控', 'toggle', 'mntr', RB_H.mntr_swtc},
    {'mntr_disp', '实时显示', 'toggle', 'mntr', RB_H.mntr_disp},
    {'mntr_mlog', '记录日志', 'toggle', 'mntr', RB_H.mntr_mlog},
    {'mntr_coln', '每行玩家个数', 'autoaction_value_i', 'mntr', RB_H.mntr_coln},
    {'mntr_size', '字体大小', 'autoaction_value_i', 'mntr', RB_H.mntr_size},
    {'mntr_heig', '行高倍数', 'autoaction_value_f', 'mntr', RB_H.mntr_heig},
    {'mntr_red', 'RD', 'autoaction_value_i', 'mntr', RB_H.mntr_red},
    {'mntr_gren', 'GN', 'autoaction_value_i', 'mntr', RB_H.mntr_gren},
    {'mntr_blue', 'BU', 'autoaction_value_i', 'mntr', RB_H.mntr_blue},
    {'mntr_alph', '不透明度', 'autoaction_value_i', 'mntr', RB_H.mntr_alph},
    {'mntr_slep', '检测间隔ms', 'autoaction_value_i', 'mntr', RB_H.mntr_slep})
RB_G.menu.mntr_swtc.on = RB_G.cfgs:get('MNTR', 'modder_monitor_enable')
RB_G.menu.mntr_disp.on = RB_G.cfgs:get('MNTR', 'display')
RB_G.menu.mntr_mlog.on = RB_G.cfgs:get('MNTR', 'log_enable')
RB_G.menu.mntr_coln.min = 4
RB_G.menu.mntr_coln.max = 32
RB_G.menu.mntr_coln.mod = 4
RB_G.menu.mntr_coln.value = RB_G.cfgs:get('MNTR', 'col_number')
RB_G.menu.mntr_size.min = 6
RB_G.menu.mntr_size.max = 36
RB_G.menu.mntr_size.mod = 2
RB_G.menu.mntr_size.value = RB_G.cfgs:get('MNTR', 'size')
RB_G.menu.mntr_heig.min = 1
RB_G.menu.mntr_heig.max = 3
RB_G.menu.mntr_heig.mod = 0.5
RB_G.menu.mntr_heig.value = RB_G.cfgs:get('MNTR', 'col_height')
RB_G.menu.mntr_red.min = 0
RB_G.menu.mntr_red.max = 255
RB_G.menu.mntr_red.mod = 5
RB_G.menu.mntr_red.value = RB_G.cfgs:get('MNTR', 'red')
RB_G.menu.mntr_gren.min = 0
RB_G.menu.mntr_gren.max = 255
RB_G.menu.mntr_gren.mod = 5
RB_G.menu.mntr_gren.value = RB_G.cfgs:get('MNTR', 'green')
RB_G.menu.mntr_blue.min = 0
RB_G.menu.mntr_blue.max = 255
RB_G.menu.mntr_blue.mod = 5
RB_G.menu.mntr_blue.value = RB_G.cfgs:get('MNTR', 'blue')
RB_G.menu.mntr_alph.min = 0
RB_G.menu.mntr_alph.max = 255
RB_G.menu.mntr_alph.mod = 5
RB_G.menu.mntr_alph.value = RB_G.cfgs:get('MNTR', 'alpha')
RB_G.menu.mntr_slep.min = 1000
RB_G.menu.mntr_slep.max = 20000
RB_G.menu.mntr_slep.mod = 1000
RB_G.menu.mntr_slep.value = RB_G.cfgs:get('MNTR', 'sleep')

RB_U.menus_add({'tele', '传送选项', 'parent', 'main'},
    {'tele_auto', '自动传标记点', 'toggle', 'tele', RB_H.tele_auto},
    {'tele_fowr', '向前闪现', 'action_value_i', 'tele', RB_H.tele_fowr},
    {'tele_kosa', '传送到虎鲸', 'action', 'tele', RB_H.tele_kosa})
RB_G.menu.tele_auto.on = RB_G.cfgs:get('TELE', 'auto_teleport')
RB_G.menu.tele_fowr.min = 1
RB_G.menu.tele_fowr.max = 25
RB_G.menu.tele_fowr.mod = 2
RB_G.menu.tele_fowr.value = RB_G.cfgs:get('TELE', 'flash_distance')

RB_U.menus_add({'wrld', '世界选项', 'parent', 'main'},
    {'wrld_ctrl_rang', '控制范围', 'autoaction_value_f', 'wrld', RB_H.wrld_ctrl_rang},
    {'wrld_npcs_kill', 'NPC自动死亡', 'toggle', 'wrld', RB_H.wrld_npcs_kill},
    {'wrld_npcs_remo', 'NPC自动移除', 'toggle', 'wrld', RB_H.wrld_npcs_remo},
    {'wrld_npcs_t2me', 'NPC自动传送面前', 'toggle', 'wrld', RB_H.wrld_npcs_t2me},
    {'wrld_npcs_frze', 'NPC自动冻结', 'toggle', 'wrld', RB_H.wrld_npcs_frze},
    {'wrld_objs_tele', '物品传送面前', 'action', 'wrld', RB_H.wrld_objs_tele},
    {'wrld_objs_tele_me', '随机传送到可拾取物品旁', 'action', 'wrld', RB_H.wrld_objs_tele_me})
RB_G.menu.wrld_ctrl_rang.min = 25
RB_G.menu.wrld_ctrl_rang.max = 500
RB_G.menu.wrld_ctrl_rang.mod = 25
RB_G.menu.wrld_ctrl_rang.value = RB_G.cfgs:get('WRLD', 'control_range')
RB_G.menu.wrld_npcs_kill.on = RB_G.cfgs:get('WRLD', 'npcs_kill')
RB_G.menu.wrld_npcs_remo.on = RB_G.cfgs:get('WRLD', 'npcs_remove')
RB_G.menu.wrld_npcs_t2me.on = RB_G.cfgs:get('WRLD', 'npcs_teleport_to_me')
RB_G.menu.wrld_npcs_frze.on = RB_G.cfgs:get('WRLD', 'npcs_freeze')

RB_U.menus_add({'stat', '统计选项', 'parent', 'main'},
    {'stat_addt', '增加在线时长', 'action_value_str', 'stat', RB_H.stat_addt},
    {'stat_rdct', '减少在线时长', 'action_value_str', 'stat', RB_H.stat_rdct})
RB_G.menu.stat_addt:set_str_data({'先按确定看说明', '1hor', '1day', '1wek', '1mon', '3mon', '6mon', '1yer'})
RB_G.menu.stat_rdct:set_str_data({'先按确定看说明', '1hor', '1day', '1wek', '1mon', '3mon', '6mon', '1yer'})

RB_U.menus_add({'chat', '聊天选项', 'parent', 'main'}, {'char_warn', '警告喊话', 'parent', 'chat'},
    {'char_judg', '聊天审判', 'parent', 'chat'},
    {'char_judg_swtc', '开启审判', 'toggle', 'char_judg', RB_H.char_judg_swtc},
    {'char_judg_type', '崩溃方式', 'autoaction_value_str', 'char_judg', RB_H.char_judg_type},
    {'char_judg_noti', '是否通知', 'toggle', 'char_judg', RB_H.char_judg_noti},
    {'char_judg_keys_add', '添加关键字', 'action', 'char_judg', RB_H.char_judg_keys_add},
    {'char_warn_swtc', '开启警告', 'action', 'char_warn', RB_H.char_warn_swtc},
    {'char_warn_msgs', '短信喊话', 'action', 'char_warn', RB_H.char_warn_msgs},
    {'char_warn_glob', '公屏喊话', 'action', 'char_warn', RB_H.char_warn_glob})
RB_G.menu.char_judg_swtc.on = RB_G.cfgs:get('CHAR', 'chat_judge_enable')
RB_G.menu.char_judg_type:set_str_data({'kek', 'mmt'})
RB_G.menu.char_judg_type.value = RB_G.cfgs:get('CHAR', 'chat_judge_type')
RB_G.menu.char_judg_noti.on = RB_G.cfgs:get('CHAR', 'chat_judge_notice')
RB_G.menu.char_judg_keys = {}
RB_G.jud_kws = util_str.split(RB_G.cfgs:get('CHAR', 'chat_judge_keywords'), ', ')
RB_H.refresh_chat_judge_keywords()

RB_U.menus_add({'heist', '抢劫选项', 'parent', 'main'}, {'heist_apartment', '公寓抢劫', 'parent', 'heist'},
    {'heist_apartment_cut', '修改分红', 'action', 'heist_apartment', RB_H.heist_apartment_cut},
    {'heist_casino', '名钻赌场', 'parent', 'heist'},
    {'heist_casino_cut', '修改分红', 'action', 'heist_casino', RB_H.heist_casino_cut},
    {'heist_cayo', '佩里科岛', 'parent', 'heist'},
    {'heist_cayo_cut', '修改分红', 'action', 'heist_cayo', RB_H.heist_cayo_cut},
    {'heist_cayo_mode', '模式', 'value_str', 'heist_cayo', RB_H.heist_cayo_mode},
    {'heist_cayo_target', '目标', 'value_str', 'heist_cayo', RB_H.heist_cayo_target},
    {'heist_cayo_c_cash', '现金数量(内)', 'value_str', 'heist_cayo', RB_H.heist_cayo_c_cash},
    {'heist_cayo_i_cash', '现金数量(外)', 'value_str', 'heist_cayo', RB_H.heist_cayo_i_cash},
    {'heist_cayo_weed', '大麻数量', 'value_str', 'heist_cayo', RB_H.heist_cayo_weed},
    {'heist_cayo_coke', '古柯数量', 'value_str', 'heist_cayo', RB_H.heist_cayo_coke},
    {'heist_cayo_gold', '黄金数量', 'value_str', 'heist_cayo', RB_H.heist_cayo_gold},
    {'heist_cayo_paint', '画作数量', 'value_str', 'heist_cayo', RB_H.heist_cayo_paint},
    {'heist_cayo_vehicle', '接近载具', 'value_str', 'heist_cayo', RB_H.heist_cayo_vehicle},
    {'heist_cayo_weapon', '武器', 'value_str', 'heist_cayo', RB_H.heist_cayo_weapon},
    {'heist_cayo_truck', '卡车位置', 'value_str', 'heist_cayo', RB_H.heist_cayo_truck},
    {'heist_cayo_interest', '侦察兴趣点', 'toggle', 'heist_cayo', RB_H.heist_cayo_interest},
    {'heist_cayo_disturb', '全部干扰', 'toggle', 'heist_cayo', RB_H.heist_cayo_disturb},
    {'heist_cayo_enable', '确认修改', 'action', 'heist_cayo', RB_H.heist_cayo_enable},
    {'heist_doomsday', '末日豪劫', 'parent', 'heist'},
    {'heist_doomsday_cut', '修改分红', 'action', 'heist_doomsday', RB_H.heist_doomsday_cut})
RB_U.menus_set({'heist_cayo_mode', {
    str_data = {'普通', '困难'},
    value = RB_G.cfgs:get('HEIST', 'cayo_mode'),
    on = RB_G.cfgs:get('HEIST', 'cayo_mode_on')
}}, {'heist_cayo_target', {
    str_data = {'西西米托龙舌兰', '红宝石项链', '不记名债券', '粉钻', '玛德拉索文件',
                '猎豹雕像'},
    value = RB_G.cfgs:get('HEIST', 'cayo_target'),
    on = RB_G.cfgs:get('HEIST', 'cayo_target_on')
}}, {'heist_cayo_c_cash', {
    str_data = {'默认', '2', '4', '6', '8'},
    value = RB_G.cfgs:get('HEIST', 'cayo_cash_c_number'),
    on = RB_G.cfgs:get('HEIST', 'cayo_cash_c_on'),
    threaded = false
}}, {'heist_cayo_i_cash', {
    str_data = {'默认', '3', '6', '9', '12', '15', '18', '21', '24'},
    value = RB_G.cfgs:get('HEIST', 'cayo_cash_i_number'),
    on = RB_G.cfgs:get('HEIST', 'cayo_cash_i_on'),
    threaded = false
}}, {'heist_cayo_weed', {
    str_data = {'默认', '3', '6', '9', '12', '15', '18', '21', '24'},
    value = RB_G.cfgs:get('HEIST', 'cayo_weed_number'),
    on = RB_G.cfgs:get('HEIST', 'cayo_weed_on'),
    threaded = false
}}, {'heist_cayo_coke', {
    str_data = {'默认', '3', '6', '9', '12', '15', '18', '21', '24'},
    value = RB_G.cfgs:get('HEIST', 'cayo_coke_number'),
    on = RB_G.cfgs:get('HEIST', 'cayo_coke_on'),
    threaded = false
}}, {'heist_cayo_gold', {
    str_data = {'默认', '2', '4', '6', '8'},
    value = RB_G.cfgs:get('HEIST', 'cayo_gold_number'),
    on = RB_G.cfgs:get('HEIST', 'cayo_gold_on'),
    threaded = false
}}, {'heist_cayo_paint', {
    str_data = {'默认', '1', '3', '5', '7'},
    value = RB_G.cfgs:get('HEIST', 'cayo_paint_number'),
    on = RB_G.cfgs:get('HEIST', 'cayo_paint_on'),
    threaded = false
}}, {'heist_cayo_vehicle', {
    str_data = {'虎鲸', '阿尔科诺斯特', '梅杜莎', '隐形歼灭者', '巡逻艇', '长鳍', '全部可用'},
    value = RB_G.cfgs:get('HEIST', 'cayo_vehicle'),
    on = RB_G.cfgs:get('HEIST', 'cayo_vehicle_on')
}}, {'heist_cayo_weapon', {
    str_data = {'侵略者', '阴谋者', '神枪手', '破坏者', '神射手'},
    value = RB_G.cfgs:get('HEIST', 'cayo_weapon'),
    on = RB_G.cfgs:get('HEIST', 'cayo_weapon_on')
}}, {'heist_cayo_truck', {
    str_data = {'机场', '北船坞', '主码头-东', '主码头-西', '豪宅门口'},
    value = RB_G.cfgs:get('HEIST', 'cayo_truck'),
    on = RB_G.cfgs:get('HEIST', 'cayo_truck_on')
}}, {'heist_cayo_disturb', {
    on = RB_G.cfgs:get('HEIST', 'cayo_disturb_on')
}}, {'heist_cayo_interest', {
    on = RB_G.cfgs:get('HEIST', 'cayo_interest_on')
}})

RB_U.menus_add({'setting', '菜单设置', 'parent', 'main'},
    {'setting_reset', '重置设置', 'action', 'setting', RB_H.setting_reset},
    {'setting_save', '保存设置', 'action', 'setting', RB_H.setting_save})
RB_U.menu_set('setting_reset', {
    data = {
        enforce = true
    }
})

local pf_id = menu.add_player_feature('RockByte', 'parent', 0).id
menu.add_player_feature('传送佩里科岛', 'action', pf_id, RB_H.online_to_cayo)
menu.add_player_feature('传送日蚀公寓', 'action', pf_id, RB_H.online_to_apartment)
menu.add_player_feature('移除无敌', 'toggle', pf_id, RB_H.online_remove_god)
menu.add_player_feature('到我面前(目标在载具中有效)', 'action', pf_id, RB_H.online_teleport2me)
menu.add_player_feature('游戏崩溃', 'action_value_str', pf_id, RB_H.online_crashes):set_str_data(RB_G.cra_typ)

-- RB_U.menu_add('onli', '在线玩家', 'parent', 'main')
-- for ply_i = 0, RB_G.max_player do
--     local p_keys = string.format(RB_G.menu_player_keys, ply_i)
--     local p_feat_keys = string.format(RB_G.menu_player_feat_keys, ply_i)
--     RB_U.menus_add({p_keys, p_keys, 'parent', RB_G.menu.onli.id},
--                     {p_feat_keys .. '.to_perico', '传送佩里科岛', 'action', p_keys, RB_H.online_to_cayo},
--                     {p_feat_keys .. '.to_partment', '传送日蚀公寓', 'action', p_keys, RB_H.online_to_apartment},
--                     {p_feat_keys .. '.teleport2me', '到我面前(目标在载具中有效)', 'action', p_keys,
--                      RB_H.online_teleport2me}, {p_feat_keys .. '.game_crashes', '游戏崩溃', 'action', p_keys, RB_H.online_crashes})
--     local data = {
--         ply_id = ply_i
--     }
--     RB_U.menus_set({{p_feat_keys .. '.to_perico', {
--         threaded = false,
--         data = data
--     }, {p_feat_keys .. '.to_partment', {
--         threaded = false,
--         data = data
--     }}, {p_feat_keys .. '.teleport2me', {
--         threaded = false,
--         data = data
--     }}, {p_feat_keys .. '.game_crashes', {
--         threaded = false,
--         data = data,
--         str_data = RB_G.cra_typ
--     }}}})
--     -- 该函数好像不起作用
--     -- local set_god = menu.add_feature('设置无敌', 'action',
--     --                                  RB_G.menu.online_play[ply_i].id,
--     --                                  RB_H.online_set_god)
--     -- -- 该函数好像不起作用
--     -- local teleport2mycar = menu.add_feature('到我车里', 'action',
--     --                                         RB_G.menu.online_play[ply_i].id,
--     --                                         RB_H.online_teleport2mycar)
-- end

-- -- 该函数好像不起作用
-- RB_G.menu.wrld_comb = menu.add_feature('NPC战斗方式', 'value_i',
--                                      'wrld', RB_H.wrld_comb)
-- RB_G.menu.wrld_comb.min = 0
-- RB_G.menu.wrld_comb.max = 100
-- RB_G.menu.wrld_comb.mod = 1
-- RB_G.menu.wrld_comb.value = RB_G.cfgs:get('WRLD', 'combat_ability')
-- RB_G.menu.wrld_comb.on = RB_G.cfgs:get('WRLD', 'combat_ability_on')
-- -- 该函数好像不起作用
-- RB_G.menu.wrld_accu = menu.add_feature('NPC射击精准', 'value_i',
--                                      'wrld', RB_H.wrld_accu)
-- RB_G.menu.wrld_accu.min = 0
-- RB_G.menu.wrld_accu.max = 100
-- RB_G.menu.wrld_accu.mod = 5
-- RB_G.menu.wrld_accu.value = RB_G.cfgs:get('WRLD', 'accuracy')
-- RB_G.menu.wrld_accu.on = RB_G.cfgs:get('WRLD', 'accuracy_on')

RB_U.notify('RockByte_v' .. __ROCKBITE_VERSION .. ' 加载成功!', RB_G.lvl.SUC)
RB_U.notify('日志目录: script\\RockByteData\\Logs', RB_G.lvl.SUC)

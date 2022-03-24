if __ROCKBITE_VERSION then
    menu.notify('菜单已经在运行,请勿重复加载', 'RB-WRN-取消初始化', 5, 0x0080ff)
    return
end

__ROCKBITE_VERSION = '0.1.5'

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
local RB_G = nil
local RB_U = nil
local RB_H = nil

do -- 确保每个被加载一次，每次需要一个库时，都有与其他库相同的环境。
    local original_require = require
    require = function(name)
        local lib = package.loaded[name] or original_require(name)
        if not lib then
            print(string.format('an error occurred loading the "%s" module.', name))

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
    RB_G = require('libs.global')
    RB_U = require('libs.utils')
    RB_H = require('libs.handlers')

    require = original_require
end

-- 初始化配置文件
RB_G.cfgs = util_ini:new(paths.configs)
for _, val in ipairs({{'PROG', 'debug', false}, {'TELE', 'flash_distance', 3}, {'TELE', 'auto_teleport', false},
                      {'MNTR', 'modder_monitor_enable', false}, {'MNTR', 'display', false},
                      {'MNTR', 'log_enable', true}, {'MNTR', 'size', 12}, {'MNTR', 'col_number', 16},
                      {'MNTR', 'col_height', 1.5}, {'MNTR', 'red', 255}, {'MNTR', 'green', 255}, {'MNTR', 'blue', 255},
                      {'MNTR', 'alpha', 255}, {'MNTR', 'sleep', 5000}, {'WRLD', 'npcs_kill', false},
                      {'WRLD', 'npcs_remove', false}, {'WRLD', 'accuracy', 50}, {'WRLD', 'accuracy_on', false},
                      {'WRLD', 'npcs_freeze', false}, {'WRLD', 'npcs_teleport_to_me', false},
                      {'WRLD', 'combat_ability', 0}, {'WRLD', 'combat_ability_on', false},
                      {'WRLD', 'control_range', 100}, {'WRLD', 'objects_teleport', false},
                      {'CHAR', 'chat_judge_notice', true}, {'CHAR', 'chat_judge_type', 0},
                      {'CHAR', 'chat_judge_keywords', 'www%., GTA%d%d%d, 刷金, q群, 售后, 微信, 淘宝, vx'}}) do
    if RB_G.cfgs:get(val[1], val[2]) == nil then
        RB_G.cfgs:set(val[1], val[2], val[3])
    end
end

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
RB_G.menu.main = menu.add_feature('RockByte', 'parent', 0)
RB_U.menu_binding({ -- {'test', '测试菜单', 'action_value_str', RB_G.menu.main.id, RB_H.test},
{'onli', '在线玩家', 'parent', RB_G.menu.main.id}, {'wrld', '世界选项', 'parent', RB_G.menu.main.id},
{'tele', '传送选项', 'parent', RB_G.menu.main.id}, {'stat', '统计选项', 'parent', RB_G.menu.main.id},
{'mntr', '作弊监控', 'parent', RB_G.menu.main.id}, {'chat', '聊天选项', 'parent', RB_G.menu.main.id},
{'sett', '菜单设置', 'parent', RB_G.menu.main.id}, {'loop', '监控循环', 'toggle', 0, RB_H.loop}})
RB_G.menu.loop.hidden = true
RB_G.menu.loop.on = true

RB_G.menu.test:set_str_data(RB_G.cra_typ)

RB_U.menu_binding({{'mntr_swtc', '开启监控', 'toggle', RB_G.menu.mntr.id, RB_H.mntr_swtc},
                   {'mntr_disp', '实时显示', 'toggle', RB_G.menu.mntr.id, RB_H.mntr_disp},
                   {'mntr_mlog', '记录日志', 'toggle', RB_G.menu.mntr.id, RB_H.mntr_mlog},
                   {'mntr_coln', '每行玩家个数', 'autoaction_value_i', RB_G.menu.mntr.id, RB_H.mntr_coln},
                   {'mntr_size', '字体大小', 'autoaction_value_i', RB_G.menu.mntr.id, RB_H.mntr_size},
                   {'mntr_heig', '行高倍数', 'autoaction_value_f', RB_G.menu.mntr.id, RB_H.mntr_heig},
                   {'mntr_red', 'RD', 'autoaction_value_i', RB_G.menu.mntr.id, RB_H.mntr_red},
                   {'mntr_gren', 'GN', 'autoaction_value_i', RB_G.menu.mntr.id, RB_H.mntr_gren},
                   {'mntr_blue', 'BU', 'autoaction_value_i', RB_G.menu.mntr.id, RB_H.mntr_blue},
                   {'mntr_alph', '不透明度', 'autoaction_value_i', RB_G.menu.mntr.id, RB_H.mntr_alph},
                   {'mntr_slep', '检测间隔ms', 'autoaction_value_i', RB_G.menu.mntr.id, RB_H.mntr_slep},
                   {'tele_auto', '自动传标记点', 'toggle', RB_G.menu.tele.id, RB_H.tele_auto},
                   {'tele_fowr', '向前闪现', 'action_value_i', RB_G.menu.tele.id, RB_H.tele_fowr},
                   {'tele_kosa', '传送到虎鲸', 'action', RB_G.menu.tele.id, RB_H.tele_kosa},
                   {'wrld_ctrl_rang', '控制范围', 'autoaction_value_f', RB_G.menu.wrld.id, RB_H.wrld_ctrl_rang},
                   {'wrld_npcs_kill', 'NPC自动死亡', 'toggle', RB_G.menu.wrld.id, RB_H.wrld_npcs_kill},
                   {'wrld_npcs_remo', 'NPC自动移除', 'toggle', RB_G.menu.wrld.id, RB_H.wrld_npcs_remo},
                   {'wrld_npcs_t2me', 'NPC自动传送面前', 'toggle', RB_G.menu.wrld.id, RB_H.wrld_npcs_t2me},
                   {'wrld_npcs_frze', 'NPC自动冻结', 'toggle', RB_G.menu.wrld.id, RB_H.wrld_npcs_frze},
                   {'wrld_objs_tele', '物品自动传送面前', 'toggle', RB_G.menu.wrld.id, RB_H.wrld_objs_tele},
                   {'stat_addt', '增加在线时长', 'action_value_str', RB_G.menu.stat.id, RB_H.stat_addt},
                   {'stat_rdct', '减少在线时长', 'action_value_str', RB_G.menu.stat.id, RB_H.stat_rdct},
                   {'char_warn', '警告喊话', 'parent', RB_G.menu.chat.id},
                   {'char_judg', '聊天审判', 'parent', RB_G.menu.chat.id},
                   {'sett_save', '保存设置', 'action', RB_G.menu.sett.id, RB_H.sett_save}})

RB_U.menu_binding({{'char_judg_swtc', '开启审判', 'toggle', RB_G.menu.char_judg.id, RB_H.char_judg_swtc},
                   {'char_judg_type', '崩溃方式', 'autoaction_value_str', RB_G.menu.char_judg.id,
                    RB_H.char_judg_type},
                   {'char_judg_noti', '是否通知', 'toggle', RB_G.menu.char_judg.id, RB_H.char_judg_noti},
                   {'char_judg_keys_add', '添加关键字', 'action', RB_G.menu.char_judg.id, RB_H.char_judg_keys_add},
                   {'char_judg_swtc', '开启警告', 'action', RB_G.menu.char_warn.id, RB_H.char_judg_swtc},
                   {'char_warn_msgs', '短信喊话', 'action', RB_G.menu.char_warn.id, RB_H.char_warn_msgs},
                   {'char_warn_glob', '公屏喊话', 'action', RB_G.menu.char_warn.id, RB_H.char_warn_glob}})

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

RB_G.menu.tele_auto.on = RB_G.cfgs:get('TELE', 'auto_teleport')
RB_G.menu.tele_fowr.min = 1
RB_G.menu.tele_fowr.max = 25
RB_G.menu.tele_fowr.mod = 2
RB_G.menu.tele_fowr.value = RB_G.cfgs:get('TELE', 'flash_distance')

RB_G.menu.wrld_ctrl_rang.min = 25
RB_G.menu.wrld_ctrl_rang.max = 500
RB_G.menu.wrld_ctrl_rang.mod = 25
RB_G.menu.wrld_ctrl_rang.value = RB_G.cfgs:get('WRLD', 'control_range')
RB_G.menu.wrld_npcs_kill.on = RB_G.cfgs:get('WRLD', 'npcs_kill')
RB_G.menu.wrld_npcs_remo.on = RB_G.cfgs:get('WRLD', 'npcs_remove')
RB_G.menu.wrld_npcs_t2me.on = RB_G.cfgs:get('WRLD', 'npcs_teleport_to_me')
RB_G.menu.wrld_npcs_frze.on = RB_G.cfgs:get('WRLD', 'npcs_freeze')
RB_G.menu.wrld_objs_tele.on = RB_G.cfgs:get('WRLD', 'objects_teleport')

RB_G.menu.stat_addt:set_str_data({'先按确定看说明', '1hor', '1day', '1wek', '1mon', '3mon', '6mon', '1yer'})
RB_G.menu.stat_rdct:set_str_data({'先按确定看说明', '1hor', '1day', '1wek', '1mon', '3mon', '6mon', '1yer'})

RB_G.menu.char_judg_swtc.on = RB_G.cfgs:get('CHAR', 'chat_judge_enable')
RB_G.menu.char_judg_type:set_str_data({'kek', 'mmt'})
RB_G.menu.char_judg_type.value = RB_G.cfgs:get('CHAR', 'chat_judge_type')
RB_G.menu.char_judg_noti.on = RB_G.cfgs:get('CHAR', 'chat_judge_notice')

RB_G.menu.char_judg_keys = {}
RB_G.jud_kws = util_str.split(RB_G.cfgs:get('CHAR', 'chat_judge_keywords'), ', ')
RB_H.refresh_chat_judge_keywords()

RB_G.menu.onli_play = {}
for ply_i = 0, RB_G.max_player do
    RB_G.menu.onli_play[ply_i] = menu.add_feature('player_' .. ply_i, 'parent', RB_G.menu.onli.id)
    local to_perico = menu.add_feature('传送佩里科岛', 'action', RB_G.menu.onli_play[ply_i].id, RB_H.onli_2prc)
    local to_partment = menu.add_feature('日蚀公寓传送', 'action', RB_G.menu.onli_play[ply_i].id, RB_H.onli_2par)
    local teleport2me = menu.add_feature('到我面前(目标在载具中有效)', 'action',
        RB_G.menu.onli_play[ply_i].id, RB_H.onli_tp2m)
    local game_crashes = menu.add_feature('游戏崩溃', 'action_value_str', RB_G.menu.onli_play[ply_i].id,
        RB_H.onli_cras)
    -- 该函数好像不起作用
    -- local set_god = menu.add_feature('设置无敌', 'action',
    --                                  RB_G.menu.onli_play[ply_i].id,
    --                                  RB_H.onli_set_god)
    -- -- 该函数好像不起作用
    -- local teleport2mycar = menu.add_feature('到我车里', 'action',
    --                                         RB_G.menu.onli_play[ply_i].id,
    --                                         RB_H.onli_teleport2mycar)
    to_perico.data = {
        ply_id = ply_i
    }
    to_perico.threaded = false
    to_partment.data = {
        ply_id = ply_i
    }
    to_partment.threaded = false
    teleport2me.data = {
        ply_id = ply_i
    }
    teleport2me.threaded = false
    game_crashes.data = {
        ply_id = ply_i
    }
    game_crashes.threaded = false
    game_crashes:set_str_data(RB_G.cra_typ)
    -- set_god.data = {player_i = ply_i}
    -- set_god.threaded = false
    -- teleport2mycar.data = {player_i = ply_i}
    -- teleport2mycar.threaded = false
end

-- -- 该函数好像不起作用
-- RB_G.menu.wrld_comb = menu.add_feature('NPC战斗方式', 'value_i',
--                                      RB_G.menu.wrld.id, RB_H.wrld_comb)
-- RB_G.menu.wrld_comb.min = 0
-- RB_G.menu.wrld_comb.max = 100
-- RB_G.menu.wrld_comb.mod = 1
-- RB_G.menu.wrld_comb.value = RB_G.cfgs:get('WRLD', 'combat_ability')
-- RB_G.menu.wrld_comb.on = RB_G.cfgs:get('WRLD', 'combat_ability_on')
-- -- 该函数好像不起作用
-- RB_G.menu.wrld_accu = menu.add_feature('NPC射击精准', 'value_i',
--                                      RB_G.menu.wrld.id, RB_H.wrld_accu)
-- RB_G.menu.wrld_accu.min = 0
-- RB_G.menu.wrld_accu.max = 100
-- RB_G.menu.wrld_accu.mod = 5
-- RB_G.menu.wrld_accu.value = RB_G.cfgs:get('WRLD', 'accuracy')
-- RB_G.menu.wrld_accu.on = RB_G.cfgs:get('WRLD', 'accuracy_on')

RB_U.notify('RockByte_v' .. __ROCKBITE_VERSION .. ' 加载成功!', RB_G.lvl.SUC)
RB_U.notify('日志目录: script\\RockByteData\\Logs', RB_G.lvl.SUC)

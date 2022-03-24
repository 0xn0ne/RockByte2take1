local _Module = {
    _VERSION = '0.1.0',
    _NAME = 'lib_glb'
}

_Module.menu = {}
_Module.cfgs = {}
_Module.paths = {}
_Module.max_player = 32
_Module.last_teleport_time = -1

_Module.lvl = {
    SUC = 'SUC',
    ERR = 'ERR',
    WRN = 'WRN',
    INF = 'INF',
    DBG = 'DBG'
}

_Module.clr = {
    wh = 0xffffff,
    bk = 0x000000,
    gn = 0x00ff00,
    rd = 0x0000ff,
    ye = 0x0088ff,
    bu = 0xffdd00,
    vt = 0xff007f
}

_Module.clr[_Module.lvl.SUC] = _Module.clr.gn
_Module.clr[_Module.lvl.ERR] = _Module.clr.rd
_Module.clr[_Module.lvl.WRN] = _Module.clr.ye
_Module.clr[_Module.lvl.INF] = _Module.clr.bu
_Module.clr[_Module.lvl.DBG] = _Module.clr.vt

_Module.log_obj = {}

_Module.mod_flg_t2v = {
    GOD_FLAG = -1
}
_Module.mod_flg_i2v = {}
local i = 0
repeat
    local val = 1 << i
    _Module.mod_flg_i2v[#_Module.mod_flg_i2v + 1] = val
    _Module.mod_flg_t2v[player.get_modder_flag_text(val)] = val
    i = i + 1
until 1 << i == player.get_modder_flag_ends()
_Module.ply = {
    onl = {},
    inf = {}
}
_Module.ply_mod_hsh = {}
for key, val in pairs(_Module.mod_flg_t2v) do
    if val < 0 then
        _Module.mod_flg_t2v.GOD_FLAG = player.add_modder_flag(key)
    end
end
_Module.ply_god_log = {}

_Module.sta_typ = {
    int = 'int',
    flo = 'float',
    bol = 'bool',
    i64 = 'i64',
    u64 = 'u64'
}

_Module.ped_typ = {
    player_0 = 0,
    player_1 = 1,
    player_2 = 3,
    civmale = 4,
    civfemale = 5,
    cop = 6,
    unknown_7 = 7,
    unknown_12 = 12, -- gang member?
    unknown_19 = 19,
    medic = 20,
    fireman = 21,
    unknown_22 = 22,
    unknown_25 = 25,
    unknown_26 = 26,
    swat = 27,
    animal = 28,
    army = 29
}
_Module.ped = {}
_Module.ped.fri_hsh = {}
_Module.ped.enm_hsh = {}
_Module.ped.enm_unk = {}

-- 0xb0423aa0 | 2957130400 -- 医生
-- 0xa49e591c | 2761840924 -- 警察
-- 0x90c7da60 | 2429016672 -- LOST黑帮
-- 0xfade4843 | 4208871491 -- 无关系
-- 0x47033600 | 1191392768 -- 女性居民
-- 0x02b8fa80 | 0045677184 -- 男性居民

-- 0x3933433b | 0959660859 -- 未知？收银员？可交互对象？
-- 0x052570d6 | 0086339798 -- 未知
-- 0x670b535c | 1728795484 -- 未知
-- 0xbe8b825f | 3196813919 -- 未知
-- 0xedab1ce2 | 3987414242 -- 未知？玩家？自己？
-- 0x4ac7dc4b | 1254612043 -- 未知？梅里韦瑟？军队？
-- 0xd291d2ee | 3532772078 -- 未知
-- 0x437242f3 | 1131561715 -- 未知
-- 0x11e560b3 | 0300245171 -- 未知，DC抢劫任务待入侵手机人员
-- 0xcda7e028 | 3450331176 -- 未知，进入DC出现
-- 0xeb47d4e0 | 3947353312 -- 8 --  未知，DC获取武器子任务，杀死梅里韦瑟探员获取时间表出现
-- 0x04bfda51 | 0079682129 -- 1 -- 未知，佩里克岛出现
-- 0x2801779c | 0671184796 -- 19 -- 未知，敌人？佩里克岛出现
-- 0xf50b51b7 | 4111159735 -- 未知，朋友？
-- 0xddf4f3b9 | 3723817913 -- 在线玩家？CEO组队出现

-- 0x666540de | 1717911774 -- 1 -- 各个抢劫终章买家?
-- 0x5606f42e | 1443296302 -- 敌人
-- 0x40f22e1d | 1089613341 -- 客户？友军？
-- 0xb65f1459 | 3059684441 -- 特警？

-- PLAYER = 0x6F0783F5
-- SECURITY_GUARD = 0xF50B51B7
-- PRIVATE_SECURITY = 0xA882EB57
-- FIREMAN = 0xFC2CA767
-- GANG_1 = 0x4325F88A
-- GANG_2 = 0x11DE95FC
-- GANG_9 = 0x8DC30DC3
-- GANG_10 = 0x0DBF2731
-- AMBIENT_GANG_MEXICAN = 0x11A9A7E3
-- AMBIENT_GANG_FAMILY = 0x45897C40
-- AMBIENT_GANG_BALLAS = 0xC26D562A
-- AMBIENT_GANG_MARABUNTE = 0x7972FFBD
-- AMBIENT_GANG_CULT = 0x783E3868
-- AMBIENT_GANG_SALVA = 0x936E7EFB
-- AMBIENT_GANG_WEICHENG = 0x6A3B9F86
-- AMBIENT_GANG_HILLBILLY = 0xB3598E9C
-- DEALER = 0x8296713E
-- HATES_PLAYER = 0x84DCFAAD
-- HEN = 0xC01035F9
-- WILD_ANIMAL = 0x7BEA6617
-- SHARK = 0x229503C8
-- COUGAR = 0xCE133D78
-- SPECIAL = 0xD9D08749
-- MISSION2 = 0x80401068
-- MISSION3 = 0x49292237
-- MISSION4 = 0x5B4DC680
-- MISSION5 = 0x270A5DFA
-- MISSION6 = 0x392C823E
-- MISSION7 = 0x024F9485
-- MISSION8 = 0x14CAB97B
-- ARMY = 0xE3D976F3
-- GUARD_DOG = 0x522B964A
-- AGGRESSIVE_INVESTIGATE = 0xEB47D4E0
-- PRISONER = 0x7EA26372
-- DOMESTIC_ANIMAL = 0x72F30F6E
-- DEER = 0x31E50E10

_Module.eve_lis = {}
_Module.jud_kws = {}

_Module.eve = {}
_Module.eve.nme = {
    disown_personal_vehicle = 'disown_personal_vehicle',
    vehicle_emp = 'vehicle_emp',
    destroy_personal_vehicle = 'destroy_personal_vehicle',
    kick_out_of_vehicle = 'kick_out_of_vehicle',
    remove_wanted_level = 'remove_wanted_level',
    give_otr_or_ghost_organization = 'give_otr_or_ghost_organization',
    block_passive = 'block_passive',
    send_to_mission = 'send_to_mission',
    send_to_perico_island = 'send_to_perico_island',
    send_to_eclipse = 'send_to_eclipse',
    apartment_invite = 'apartment_invite',
    ceo_ban = 'ceo_ban',
    dismiss_or_terminate_from_ceo = 'dismiss_or_terminate_from_ceo',
    insurance_notification = 'insurance_notification',
    transaction_error = 'transaction_error',
    ceo_money = 'ceo_money',
    bounty = 'bounty'
}

_Module.eve.n2h = {
    disown_personal_vehicle = -520925154,
    vehicle_emp = -2042927980,
    destroy_personal_vehicle = -1026787486,
    kick_out_of_vehicle = 578856274,
    remove_wanted_level = -91354030,
    give_otr_or_ghost_organization = -391633760,
    block_passive = 1114091621,
    send_to_mission = 2020588206,
    send_to_perico_island = -621279188,
    send_to_eclipse = 603406648,
    apartment_invite = 603406648,
    ceo_ban = -764524031,
    dismiss_or_terminate_from_ceo = 248967238,
    insurance_notification = 802133775,
    transaction_error = -1704141512,
    ceo_money = 1890277845,
    bounty = 1294995624
}

_Module.cra_typ = {"kek", "mmt"}

_Module.eve.crs = {
    kek = {962740265, -1386010354, 2112408256, 677240627}
}

return _Module

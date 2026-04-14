----------------------------------------------------------
-- Credits: L
----------------------------------------------------------
local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local TS = KUI:GetModule("TeamStats")

TS.VERSION_BOSSES = { -13322, "吉", -13418, "乌", -13784, "艾" }

local RES = {
    {
        tab = "Overview",
        ids = { 7399, -13449, -13781},
        widths = { 70, 50, 50 },
        names = { "Big Secret", "S2 Master", "S3 Master"},
        tips = { "Total number of epic key copies (including old versions)", "'Battle of Azeroth' key stone master: the second season (all 15 floors limited time)", "'Hegemony Azeroth' Conqueror Keystone: Third Season (full 15-story limit)"}
    },
  }

  local INSTANCES = {
    {
        bosses = {
            { "Champion of the Light", 13329, 13330, {13331,-13292} },
            { "Grong", 13333, 13334, {13336,-13293} },
            { "Flamefist and the Illuminated", 13355, 13356, {13357,-13295} },
            { "Opulence", 13359, 13361, {13362,-13299} },
            { "Conclave of the Chosen", 13364, 13365, {13366,-13300} },
            { "King Rastakhan", 13368, 13369, {13370,-13311} },
            { "High Tinker Mekkatorque", 13372, 13373, {13374,-13312} },
            { "Stormwall Blockade", 13376, 13377, {13378,-13313} },
            { "Lady Jaina Proudmoore", 13380, 13381, {13382,-13314} },
        },
        diff = { "N BoD", "H BoD", "M BoD", },
        tab = "Battle of Dazar'alor",
    },
    {
      bosses = {
        { "Uu'Nat, Harbringer of the Void", 13411, 13412, 13413, },
        { "The Restless Cabal", 13405, 13406, 13407, },
      },
      diff = { "N CoS", "H CoS", "M CoS", },
      tab = "Crucible of Storms",
    },
    {
      bosses = {
        { "Abyssal Commander Sivara", 13588, 13589, { 13590, -13726, }, },
        { "Radiance of Azshara", 13596, 13597, { 13598, -13727, }, },
        { "Blackwater Behemoth", 13592, 13593, { 13594, -13728, }, },
        { "Lord Ashvane", 13601, 13602, { 13603, -13729, }, },
        { "Orgozoa", 13605, 13606, { 13607, -13730, }, },
        { "The Queen's Court", 13609, 13610, { 13611, -13731, }, },
        { "Za'qul", 13613, 13614, { 13615, -13732, }, },
        { "Queen Azshara", 13617, 13618, { 13619, -13733, }, },
      },
      diff = { "N EP", "H EP", "M EP", },
      tab = "Eternal Palace",
    },
}

local TABS = {}

for ord, tab in next, RES do
    local one = { ids = {}, names = {}, tips = {}, tab = tab.tab, widths = {} }
    for i = 1, #tab.ids do
        if tab.names[i] and #tab.names[i] > 0 then
            one.ids[i] = tab.ids[i]
            one.names[i] = tab.names[i]
            one.tips[i] = tab.tips[i]
            one.widths[i] = tab.widths[i]
        end
    end

    for i, ins in ipairs(INSTANCES) do
        for j, diff in ipairs(ins.diff) do
            if diff and #diff > 0 then
                local bosses = {}
                for k = 1, #ins.bosses do
                    bosses[k] = ins.bosses[k][j + 1]
                end
                table.insert(one.ids, bosses)
                table.insert(one.names, diff)
            end
        end
    end
    tinsert(TABS, one)
end

local tip = "The number of times to complete the epic copy, pay attention to the difficulty of ordinary epic (non-keystone), because Blizzard's BUG, so many copies are not allowed"
table.insert(TABS, {
    tab = "Epic copy number",
    ids = { 12749, 12752, 12763, 12768, 12773, 12776, 12779, 12745, 12782, 12785 },
    widths = { 40, 40, 40, 40, 40, 40, 40, 40, 40, },
    tips = { tip, tip, tip, tip, tip, tip, tip, tip, tip, tip, tip, tip, tip,  },
    names = { "阿塔", "自由", "诸王", "风暴", "围攻", "神庙", "暴富", "地渊", "监狱", "庄园"},
})

table.insert(TABS, {
    tab = "千钧一发",
    any_done = true,
    ids = {
        {-13785}, {-13419}, {-13323}, {-12535},
        {-12111}, {-11875}, {-11192}, {-11580}, {-11191},
        {-10045}, {-9443}, {-9442},
        {-8401, -8400}, {-8260}, {-8238}, {-7487}, {-7486}, {-7485},
    },
    widths = { 36, 36, 36, 36, 36, 36, 36, 36, 36, 36, 36, 36, 36, 36, 36, 36, 36, 36, 36, 36, 36, 36, },
    tips = {
        "千钧一发：艾萨拉", "千钧一发：乌纳特", "千钧一发：吉安娜", "千钧一发：戈霍恩",
        "千钧一发：阿古斯", "千钧一发：基尔加丹", "千钧一发：古尔丹", "千钧一发：海拉", "千钧一发：萨维斯",
        "千钧一发：黑暗之门（阿克蒙德）", "千钧一发：黑手的熔炉", "千钧一发：元首之陨",
        "千钧一发：加尔鲁什·地狱咆哮（10人或25人）", "千钧一发：莱登", "千钧一发：雷神",
        "千钧一发：惧之煞", "千钧一发：大女皇夏柯希尔", "千钧一发：皇帝的意志",
    },
    names = { "艾萨", "乌纳", "珍娜", "戈霍", "阿古", "基丹", "古尔", "海拉", "萨维", "阿克", "黑手", "悬槌", "小吼", "莱登", "雷神", "永春", "恐心", "魔古" },
})

TS.TABS = TABS
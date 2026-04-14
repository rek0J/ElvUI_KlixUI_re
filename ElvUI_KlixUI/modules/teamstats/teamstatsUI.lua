----------------------------------------------------------
-- Credits: L
----------------------------------------------------------
local KUI, T, E, L, V, P, G = unpack(select(2, ...))
local TS = KUI:GetModule("TeamStats")
local S = E:GetModule('Skins')

TS.FRAME_NAME = "TeamStatsFrame"
local names = {}

local MIN_WIDTH = 400

local f = WW:Frame(TS.FRAME_NAME, UIParent, "ButtonFrameTemplate"):TOP(0, -40):SetSize(728, 450):Hide():SetAlpha(0.95):SetMovable(true):SetToplevel(true)
f:SetResizable(true):SetMinResize(MIN_WIDTH, 200):SetMaxResize(728, 1000):SetClampedToScreen(true)
ButtonFrameTemplate_HidePortrait(f())
CoreUIMakeMovable(f())
table.insert(UISpecialFrames, TS.FRAME_NAME)

f.portrait:SetTexture("Interface\\FriendsFrame\\FriendsFrameScrollIcon")
f.TitleText:SetText(L["TitleText"])

TS.DEFAULT_COL_WIDTH = 48
TS.INNER_OFFSETY = -48
TS.INSET_BORDER = {4, 3, 4, 3}
TS.COLUMN_BUTTON_HEIGHT = 20

WW(f.Inset):TL(4, TS.INNER_OFFSETY):un()

local animateText = {
    [L["StatusGetting"]] = {},
    [L["StatusCannotGet"]] = {},
}

function TS:SetStatusText(text)
    for k, v in pairs(animateText) do
        if (k == text) then
            v.count = ((v.count or 0) + 1) % 4
            if (v[v.count]) then
                text = v[v.count]
            else
                for i = 1, v.count do text = text .. "." end
                v[v.count] = text
            end
        end
    end
    f.status = f.status or f:CreateFontString(nil, "ARTWORK", "GameFontHighlight"):BL(8, 8):un()
    f.status:SetText(text)
end

function TS.SetTab(index)
    CoreUIKeepCorner(f, "TOPLEFT")
    f.tabIdx = index
    
    local tab = TS.TABS[index]
    
    local TAB_OFFSET = -1
    local left = 2
    local header_id = 0
    for i, col in ipairs(TS.cols) do
        if col.header then
            header_id = header_id + 1
            local btn = f.headers[header_id]
            if header_id > #tab.ids + TS.NUM_FIX_HEADERS then
                btn:Hide()
            else
                if header_id > TS.NUM_FIX_HEADERS then
                    local bossId = header_id - TS.NUM_FIX_HEADERS
                    btn.ids = tab.ids[bossId]
                    btn:Show()
                    btn:SetText(tab.names[bossId])
                    btn.tooltipTitle = tab.names[bossId]
                    btn.tooltipText = tab.tips[bossId] or
                        type(btn.ids) == "table" and type(btn.ids[1]) == "table" and "The epic copy kill progress format is the current character progress (the battle network account progress). \n For example: 5(8)/10 means that this character has killed 5 M bosses, but his Battle.net has 8 M leaders."
                        or "Shows the number of days the achievement was reached, or the progress of the copy and the total number of kills"
                    
                    col.width = tab.widths and tab.widths[bossId] or TS.DEFAULT_COL_WIDTH
                end
            end
            
            local width = 0
            for j = 1, col.headerSpan or 1 do
                local includeCol = TS.cols[i + j - 1]
                width = width + includeCol.width + includeCol.offset[1]
            end
            WW(btn):BL("$parentInset", "TL", left, 1 - 22):un()
            btn.width = width - TAB_OFFSET
            btn:SetWidth(btn.width)
        end
        left = left + col.offset[1] + col.width
    end
    
    local minWidth
    for i = 1, #f.scroll.buttons do
        local btn = f.scroll.buttons[i]
        local left = 0
        for j, col in ipairs(TS.cols) do
            if j > TS.NUM_FIX_COLUMNS + #tab.ids then
                btn.widgets[j]:Hide()
                btn.widgets[j].ids = nil
            elseif j > TS.NUM_FIX_COLUMNS then
                left = left + col.offset[1]
                btn.widgets[j]:SetPoint("LEFT", btn, "LEFT", left, col.offset[2])
                left = left + col.width
                btn.widgets[j].right = left
                btn.widgets[j]:SetWidth(col.width + 1)
                
                btn.widgets[j]:Show()
                minWidth = btn.widgets[j].right
                btn.widgets[j].ids = TS.TABS[f.tabIdx].ids[j - TS.NUM_FIX_COLUMNS]
            else
                left = left + col.offset[1] + col.width
            end
        end
    end
    minWidth = minWidth and minWidth + 35
    f:SetMinResize(max(minWidth, MIN_WIDTH), select(2, f:GetMinResize()))
    f:SetMaxResize(max(minWidth, MIN_WIDTH), select(2, f:GetMaxResize()))
    f:SetWidth(max(minWidth, MIN_WIDTH))
    RunOnNextFrame(function()f.scroll.scrollChild:SetWidth(f.scroll:GetWidth()) end)
    f.scroll.update()
end

local function GetAchievementOrStaticText(player, ids)
    local stats = player.stats
    if not ids then return "" end
    if type(ids) == "table" then
        if type(ids[1]) == "table" then
            TS.tmptbl = TS.tmptbl or {}
            local progress = wipe(TS.tmptbl)
            local total = 0
            for _, tt in ipairs(ids) do
                for i, id in ipairs(tt) do
                    progress[i] = progress[i] or 0
                    local down = stats and stats[TS.mirror[id]] or 0
                    if down > 0 then progress[i] = progress[i] + 1 end
                    if id > 0 then total = total + down end
                end
            end
            for i = 2, #ids[1] do
                if progress[i] ~= progress[1] then
                    for j = 2, #ids[1] do progress[j] = "(" .. progress[j] .. ")" end
                    return table.concat(progress), #ids, total
                end
            end
            return progress[1], #ids, total
        
        else
            local total, progress = 0, 0
            for _, id in ipairs(ids) do
                local down = stats and stats[TS.mirror[id]] or 0
                if down > 0 then
                    progress = progress + 1
                    total = total + down
                end
            end
            return progress, #ids, total
        end
    else
        local statId = TS.mirror[ids]
        if not player.compared then
            return "?"
        else
            local today = floor(time() / 86400)
            local text = stats and stats[statId] or 0
            if ids < 0 and text > 0 then
                return (today - text) .. "天"
            elseif text == 0 then
                return "-"
            else
                return tostring(text)
            end
        end
    end
end

function TS.CreateButtons(f)
    local btnScan = f:Button("$parentBtn1", "MagicButtonTemplate"):SetSize(80, 22):SetText(L["BtnRescanText"])
    btnScan:SetScript("OnClick", function()
        local count = 0
        for i = 1, #names do
            local player = TS.db.players[names[i]]
            if player.selected then
                player.inspected = false
                player.gsGot = false
                if true or IsControlKeyDown() or IsAltKeyDown() then player.compared = nil end
                count = count + 1
            end
        end
        if count > 0 then
            U1Message("Started reacquisition " .. count .. " member information")
            TS:UIUpdate()
            TS:StartCheckTimer(0.5)
        else
            U1Message("Please select at least one member")
        end
    end)
    CoreUIEnableTooltip(btnScan(), L["BtnRescanTipTitle"], L["BtnRescanTip"])
    
    local btnLink = f:Button("$parentBtn2", "MagicButtonTemplate"):SetSize(80, 22):SetText(L["BtnLinkText"])
    btnLink:SetScript("OnClick", function()
        local t = {}
        local realmName = GetRealmName()
        for i = 1, #names do
            table.insert(t, EncodeURL(names[i]:gsub("%-" .. realmName, "")))
        end
        f.linkCopyDialog:Show()
        f.linkCopyDialog.eb:SetText("http://product.game.163.com/wowteamstats/stat.jsp?r=" .. EncodeURL(realmName) .. "&gs=1&i=icc25&n=" .. table.concat(t, ","))
        f.linkCopyDialog.eb:HighlightText()
    end)
    CoreUIEnableTooltip(btnLink(), L["BtnLinkTipTitle"], L["BtnLinkTip"])
    
    local annLine = {}
    local function GetPlayerAnnText(name)
        local tab = TS.TABS[f.tabIdx]
        table.wipe(annLine)
        local player = TS.db.players[name]
        if player and player.selected and (player.gsGot or player.compared) then
            tinsert(annLine, "★")
            tinsert(annLine, player.name)
            tinsert(annLine, " ")
            tinsert(annLine, player.talent1)
            tinsert(annLine, " ")
            tinsert(annLine, "装等")
            tinsert(annLine, player.gsGot and player.bad and "*" or "")
            tinsert(annLine, player.gsGot and player.gs or "未知")
            
            if (player.compared) then
                
                for i, ids in ipairs(tab.ids) do
                    if type(ids) == "table" then
                        local progress, max, total = GetAchievementOrStaticText(player, ids)
                        if progress and progress ~= 0 then
                            tinsert(annLine, " ")
                            tinsert(annLine, tab.names[i])
                            tinsert(annLine, tab.any_done and "★" or "" .. progress .. "/" .. max .. "(" .. total .. ")")
                        end
                    else
                        local text = GetAchievementOrStaticText(player, ids)
                        if text ~= "?" and text ~= "-" then
                            tinsert(annLine, " ")
                            tinsert(annLine, tab.names[i])
                            tinsert(annLine, "")
                            tinsert(annLine, text)
                        end
                    end
                end
            else
                tinsert(annLine, "")
            end
            return table.concat(annLine, "")
        end
    end
    
    StaticPopupDialogs["TEAMSTATS_ANN"] = {preferredIndex = 3,
        text = L["BtnAnnPopupText"],
        button1 = TEXT(YES),
        button2 = TEXT(CANCEL),
        OnAccept = function(self)
            local tab = TS.TABS[f.tabIdx]
            SendChatMessage("[member information statistics] - " .. tab.tab .. "：", self.data)
            for i = 1, #names do
                local line = GetPlayerAnnText(names[i])
                if line then
                    SendChatMessage(line, self.data)
                end
            end
        end,
        timeout = 0,
        hideOnEscape = 1,
        whileDead = 1,
        exclusive = 1,
    }
    local btnAnn = f:Button("$parentBtn3", "MagicButtonTemplate"):SetSize(80, 22):SetText(L["BtnAnnText"])
    btnAnn:SetScript("OnClick", function(self)
        local count = 0
        for i = 1, #names do
            local player = TS.db.players[names[i]]
            if player and player.selected then count = count + 1 end
        end
        if (count == 0) then print(L["BtnAnnNoSelect"]) return end
        local channel = "SAY"
        if (IsInGroup()) then
            if (IsInRaid()) then
                channel = "RAID"
            else
                channel = "PARTY"
            end
        end
        
        local chatFrame = GetCVar("chatStyle") == "im" and SELECTED_CHAT_FRAME or DEFAULT_CHAT_FRAME
        local eb = chatFrame and chatFrame.editBox
        if eb and eb:IsVisible() and count == 1 then
            for i = 1, #names do
                local line = GetPlayerAnnText(names[i])
                if line then
                    eb:Insert(GetPlayerAnnText(names[i]))
                    break
                end
            end
            eb:HighlightText()
            eb:SetFocus()
            return
        elseif eb and eb:IsVisible() then
            local chatType = eb:GetAttribute("chatType")
            channel = (chatType == "RAID" or chatType == "PARTY" or chatType == "SAY" or chatType == "INSTANCE") and chatType or channel
        end
        local channelName = channel == "RAID" and "raid" or channel == "PARTY" and "party" or "say"
        StaticPopup_Show("TEAMSTATS_ANN", count, channelName, channel)
    end)
    CoreUIEnableTooltip(btnAnn(), L["BtnAnnTipTitle"], L["BtnAnnTip"])
    
    local btnClean = f:Button("$parentBtn4", "MagicButtonTemplate"):SetSize(80, 22):SetText("Clean up leaving the team")
    btnClean:SetScript("OnClick", function()
        for k, v in pairs(TS.names) do
            if not v then
                TS.names[k] = nil
            end
        end
        TS:UIUpdateNames()
    end)
    
    CoreUIAnchor(f, "BOTTOMRIGHT", "BOTTOMRIGHT", 0, 0, "RIGHT", "LEFT", 0, 0, btnClean, btnScan, btnAnn)
    btnScan:On("Load"):un()
    btnClean:On("Load"):un()
    btnAnn:On("Load"):un()
    
    local drop = f:Button("$parentDropdown", "UIDropDownMenuTemplate", "dropmenu"):TOPLEFT(-10, -22)
    local text = drop.Text
    local button = _G["TeamStatsFrameDropdownButton"]
    drop:StripTextures()
    text:ClearAllPoints()
    text:SetPoint("RIGHT", button, "LEFT", -2, 0)
    drop:CreateBackdrop("Transparent")
    drop.backdrop:SetPoint("TOPLEFT", 50, 0)
    drop.backdrop:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)

    local info = {}
    local function drop_select(f)
        TS.SetTab(f.value)
        UIDropDownMenu_SetSelectedValue(f.owner, f.value)
    end
    
    UIDropDownMenu_Initialize(drop(), function(frame, level)
        info.isNotRadio = true
        info.owner = frame
        info.func = drop_select
        
        for i, v in ipairs(TS.TABS) do
            info.text = v.tab
            info.value = i
            info.checked = nil
            UIDropDownMenu_AddButton(info)
        end
    end)
    UIDropDownMenu_SetSelectedValue(drop(), f().tabIdx or 1)
    
    local btnPrev = f:Button("$parentBtnPrev", nil, "btnPrev")
        :SetSize(32, 32)
        :SetNormalTexture [[Interface\Buttons\UI-SpellbookIcon-PrevPage-Up]]
        :SetPushedTexture [[Interface\Buttons\UI-SpellbookIcon-PrevPage-Down]]
        :SetDisabledTexture [[Interface\Buttons\UI-SpellbookIcon-PrevPage-Disabled]]
        :SetHighlightTexture([[Interface\Buttons\UI-Common-MouseHilight]], "ADD")
    
    local btnNext = f:Button("$parentBtnNext", nil, "btnNext")
        :SetSize(32, 32)
        :SetNormalTexture [[Interface\Buttons\UI-SpellbookIcon-NextPage-Up]]
        :SetPushedTexture [[Interface\Buttons\UI-SpellbookIcon-NextPage-Down]]
        :SetDisabledTexture [[Interface\Buttons\UI-SpellbookIcon-NextPage-Disabled]]
        :SetHighlightTexture([[Interface\Buttons\UI-Common-MouseHilight]], "ADD")

    btnNext.dir = 1
    btnPrev.dir = -1
    
    local dropdownMenu = drop()
    UIDropDownMenu_SetWidth(dropdownMenu, 180)
    btnPrev():SetPoint("TOPLEFT", dropdownMenu, "TOPRIGHT", -10, 0)
    btnNext():SetPoint("TOPLEFT", btnPrev(), "TOPRIGHT", 0, 0)
    
    local on_click = function(btn)
        local min, max = 1, #TS.TABS
        local cur = f.tabIdx
        
        local next = cur + btn.dir
        if (next < min) then
            next = min
        elseif (next > max) then
            next = max
        end
        
        TS.SetTab(next)
        UIDropDownMenu_SetSelectedValue(dropdownMenu, next)
        UIDropDownMenu_SetText(dropdownMenu, TS.TABS[next].tab)
    end
    
    btnNext:SetScript("OnClick", on_click)
    btnPrev:SetScript("OnClick", on_click)
end

local BossCountTextCreator = function(col, btn, idx)
    local text = btn:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall"):SetWordWrap(false):SetSize(col.width + 1, 28)
    --text:SetFontHeight(14)
    return text
end

local BossCountTextUpdater = function(line, widget, idx, colIdx)
    local text, r, g, b = "", 1, 1, 1
    local ids = widget.ids
    if type(ids) == "table" then
        local progress, max, total = GetAchievementOrStaticText(line.player, ids)
        local tab = TS.TABS[f.tabIdx]
        if progress == 0 then
            text, r, g, b = "-", 1, 0.2, 0.2
        elseif tab.any_done then
            text = "|cff7fff7f★|r"
        elseif type(progress) == "string" and progress:find("^0%([0-9]+%)") then
            text = "|cffff7f7f" .. progress .. "|r/" .. max
        else
            text = "|cff7fff7f" .. progress .. "|r/" .. max
        end
    else
        text = GetAchievementOrStaticText(line.player, ids)
        if text == "?" then
            r, g, b = 0.5, 0.5, 0.5
        elseif text == "-" then
            r, g, b = 1, 0.2, 0.2
        elseif text == "1" then
            r, g, b = 1, 0.5, 0
        else
            r, g, b = 0.5, 1, 0.5
        end
    end
    widget:SetText(text)
    widget:SetTextColor(r, g, b)
end

local currSort = nil
local function compare(n1, n2, prop)
    if TS.names[n1] and not TS.names[n2] then return true, nil, true end
    if TS.names[n2] and not TS.names[n1] then return false, nil, true end
    local p1 = TS.db.players[n1]
    local p2 = TS.db.players[n2]
    if p1 == nil and p2 == nil then return n1 < n2 end
    if p1 == nil and p2 ~= nil then return false, nil, true end
    if p1 ~= nil and p2 == nil then return true, nil, true end
    local v1, v2
    if prop == "realm" then
        v1 = select(3, n1:find("%-(.+)$"))
        v2 = select(3, n2:find("%-(.+)$"))
    else
        v1, v2 = p1[prop], p2[prop]
    end
    if v1 == v2 then return n1 < n2, true end
    if v1 == nil and v2 ~= nil then return false, nil, true end
    if v1 ~= nil and v2 == nil then return true, nil, true end
    return v1 < v2
end
local sortFuncs = {
    [2] = function(a, b)
        local r, equal, force = compare(a, b, "realm")
        if equal then
            r, equal, force = compare(a, b, "name")
        end
        if currSort > 0 or force then return r else return not r end
    end,
    [3] = function(a, b)
        local r, equal, force = compare(a, b, "class")
        if equal then
            r, equal, force = compare(a, b, "talent1")
        end
        if currSort > 0 or force then return r else return not r end
    end,
    [4] = function(a, b)
        local r, equal, force = compare(a, b, "gs")
        if currSort > 0 or force then return r else return not r end
    end,
    [5] = function(a, b)
        local r, equal, force = compare(a, b, "health")
        if currSort > 0 or force then return r else return not r end
    end,
}

local function sortNames(self)
    local id = self.id
    if sortFuncs[id] then
        if (currSort == id) then currSort = -id else currSort = id end
        table.sort(names, sortFuncs[id])
        f.scroll.update()
    end
end

function TS.SetupColumns(f)
    local targetBtnOnEnter = function(self)
        for n, v in pairs(TS.db.players) do
            if v == self.line.player then
                self.tooltipText = n
                CoreUIShowTooltip(self, "ANCHOR_LEFT")
                break
            end
        end
        self.line:LockHighlight()
    end
    local targetBtnOnLeave = function(self)
        if GameTooltip:GetOwner() == self then GameTooltip:Hide() end
        self.line:UnlockHighlight()
    end
    local legendBtnOnEnter = function(self)
        self.line:LockHighlight()
        if not self._link then return end
        ShoppingTooltip1:SetOwner(self, "ANCHOR_LEFT")
        ShoppingTooltip1:SetHyperlink(self._link)
        ShoppingTooltip1:Show()
    end
    local legendBtnOnLeave = function(self)
        if ShoppingTooltip1:GetOwner() == self then ShoppingTooltip1:Hide() end
        self.line:UnlockHighlight()
    end
    TS.cols = {
        {
            header = function(btn, col)
                local cb = WW(btn):CheckButton(nil, "UICheckButtonTemplate"):SetSize(24, 24):BL(0, -3):un()
                CoreUIEnableTooltip(cb, "Select all / Cancel all", "Select players to post announcements")
                cb:SetScript("OnClick", function(self)
                    local state = self:GetChecked()
                    for i = 1, #names do
                        if TS.db.players[names[i]] then
                            TS.db.players[names[i]].selected = state
                        end
                    end
                    f.scroll.update()
                end)
            end,
            headerSpan = 1,
            width = 20,
            offset = {1, -2},
            create = function(col, b, idx)
                TS.UIPlayerSelected = TS.UIPlayerSelected or function(self)self:GetParent().player.selected = self:GetChecked() end
                return b:CheckButton(nil, "UICheckButtonTemplate"):SetSize(col.width, 20):SetScript("OnClick", TS.UIPlayerSelected)
            end,
            layout = function(parent) end,
            update = function(line, widget, idx, colIdx)
                widget:SetChecked(not not line.player.selected)
            end,
        },
        {
            header = L["HeaderPlayerName"],
            headerSpan = 2,
            width = 100,
            create = function(col, btn, idx) return btn:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall"):SetJustifyH("CENTER"):SetSize(col.width, 24) end,
            update = function(line, widget, idx, colIdx)
                if (not InCombatLockdown()) then
                    local target = line.target
                    if not target then
                        target = CreateFrame("Button", nil, UIParent, "SecureActionButtonTemplate")
                        target.line = line
                        target:SetAttribute("type", "macro")
                        target:SetFrameStrata("HIGH")
                        line.target = target
                        target:SetScript("OnEnter", targetBtnOnEnter)
                        target:SetScript("OnLeave", targetBtnOnLeave)
                    end
                    local target = line.target
                    target:ClearAllPoints()
                    target:SetParent(line)
                    target:SetPoint("TOPLEFT", line, "TOPLEFT", TS.cols[1].width + 2, 0)
                    target:SetPoint("BOTTOMRIGHT", line, 0, 0)
                    if line.player.name then
                        target:SetAttribute("macrotext", "/target " .. line.player.name)
                    end
                    target:Show()
                end
                if TS.names[names[idx]] then
                    CoreUISetTextWithClassColor(widget, line.player.name, line.player.class)
                else
                    if not line.player.name then
                        widget:SetText(names[idx]:gsub("%-.+$", ""))
                    else
                        widget:SetText(line.player.name)
                    end
                    widget:SetTextColor(0.5, 0.5, 0.5)
                end
            end
        },
        {
            -- Server
            width = 40,
            create = function(col, btn, idx) return btn:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall"):SetJustifyH("CENTER"):SetSize(col.width, 24) end,
            update = function(line, widget, idx, colIdx)
                widget:SetText(names[idx]:gsub("^.+%-", ""))
                widget:SetText("-" .. string.utf8sub(names[idx]:gsub("^.+%-", ""), 1, 2))
                if TS.names[names[idx]] then
                    widget:SetTextColor(1, 0.82, 0)
                else
                    widget:SetTextColor(0.5, 0.5, 0.5)
                end
            end,
        },
        {
            -- Career
            width = 16,
            header = L["HeaderClass"],
            headerSpan = 2,
            offset = {3, -2},
            create = function(col, btn, idx) return btn:Texture(nil, "ARTWORK", "Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes"):SetSize(16, 16) end,
            update = function(line, widget, idx, colIdx)
                local icon = line.player.class and CLASS_ICON_TCOORDS[line.player.class]
                if icon then widget:SetAlpha(1)widget:SetTexCoord(unpack(icon)) else widget:SetAlpha(0) end
            end,
        },
        {
			-- Talent text
            width = 40,
            create = function(col, btn, idx) return btn:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall"):SetJustifyH("CENTER"):SetSize(col.width, 24) end,
            update = function(line, widget, idx, colIdx)
                local player = line.player
                local talent = player.talent1
                CoreUISetTextWithClassColor(widget, talent and talent:sub(1, 6) or (player.inspected and "无" or "?"), line.player.class)
                if not player.inspected then widget:SetTextColor(0.5, 0.5, 0.5, 1) end
            end,
        },
        {
            header = L["HeaderGS"],
            headerSpan = 1,
            width = 50,
            tip = "Average item level of the current equipment",
            create = function(col, btn, idx) return btn:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall"):SetJustifyH("CENTER"):SetSize(col.width, 24) end,
            update = function(line, widget, idx, colIdx)
                local player = line.player
                widget:SetText(player.gs and format("%s%.1f", (player.bad and "|cffffd200*|r" or ""), player.gs) or "?")
                local r, b, g = U1GetInventoryLevelColor(player.gs)
                if not player.gsGot then widget:SetTextColor(0.5, 0.5, 0.5, 1) else widget:SetTextColor(r, b, g) end
            end
        },
        {
            header = "Jewelry",
            headerSpan = 1,
            width = 55,
            tip = "Number of inserted gems / total number of gems holes Number of top gems + number of high gems + number of other gems \n \n Number of enchanted equipment / total number of enchanted equipment Missing parts \n\n belt punching counts an enchantment",
            create = function(col, btn, idx) return btn:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall"):SetJustifyH("CENTER"):SetSize(col.width, 24) end,
            update = function(line, widget, idx, colIdx)
                local player = line.player
                if (player.gem_info) then
                    widget:SetText(player.gem_info)
                else
                    widget:SetText("?")
                end
                if not player.gsGot then widget:SetTextColor(0.5, 0.5, 0.5) else widget:SetTextColor(1, 1, 1) end
            end
        },
        {
            header = "Lead the trend",
            headerSpan = 1,
            width = 70,
            tip = "The current version of the relevant copy of the achievement, shared with the battle network, cross-role. Green is there, red is no",
            create = function(col, btn, idx) return btn:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall"):SetJustifyH("CENTER"):SetSize(col.width, 24) end,
            update = function(line, widget, idx, colIdx)
                local player = line.player
                if not player.compared then
                    widget:SetText("?")
                    widget:SetTextColor(0.5, 0.5, 0.5)
                else
                    local VBOSSES = TS.VERSION_BOSSES
                    local stats = player.stats
                    local s = ""
                    for i = 1, #VBOSSES, 2 do
                        local id, bossname = VBOSSES[i], VBOSSES[i + 1]
                        local statId = TS.mirror[id]
                        local text = stats and stats[statId] or 0
                        s = s .. (text > 0 and "|cff7fff7f" or "|cffff7f7f") .. bossname .. "|r"
                    end
                    widget:SetText(s)
                end
            end
        },
    }
    
    TS.NUM_FIX_COLUMNS = #TS.cols
    
    local MAX_INFOS = 0 for _, v in next, TS.TABS do MAX_INFOS = max(MAX_INFOS, #v.ids) end
    for i = 1, MAX_INFOS do table.insert(TS.cols, {width = TS.DEFAULT_COL_WIDTH, header = true, create = BossCountTextCreator, update = BossCountTextUpdater, }) end
    local defaultOffset = {1, 0} for i, col in ipairs(TS.cols) do if not col.offset then col.offset = defaultOffset end end
    
    
    f.headers = {}
    local TAB_OFFSET = -1
    local left = 2
    for i, col in ipairs(TS.cols) do
        if i > TS.NUM_FIX_COLUMNS and not TS.NUM_FIX_HEADERS then TS.NUM_FIX_HEADERS = #f.headers end
        
        if col.header then
            local id = #f.headers + 1
            local btn = TplColumnButton(f, nil, TS.COLUMN_BUTTON_HEIGHT):SetScript("OnClick", sortNames):un()
            btn:StripTextures()
            WW(btn:GetFontString()):un()
            btn.id = id
            table.insert(f.headers, btn)
            local width = 0
            for j = 1, col.headerSpan or 1 do
                local includeCol = TS.cols[i + j - 1]
                width = width + includeCol.width + includeCol.offset[1]
            end
            WW(btn):BL("$parentInset", "TL", left, 1 - 22):un()
            if type(col.header) == "string" then
                btn:SetText(col.header)
            elseif type(col.header) == "function" then
                col.header(btn, col)
            end
            btn.width = width - TAB_OFFSET
            
            btn:SetWidth(btn.width)
            
            if i > TS.NUM_FIX_COLUMNS then
                CoreUIEnableTooltip(btn)
            elseif col.tip then
                CoreUIEnableTooltip(btn, type(col.header) == "string" and col.header or "Description", col.tip)
            end
        end
        left = left + col.offset[1] + col.width
    end
end

function TS.CreateScroll(f)
    local BUTTON_HEIGHT = 24
    local SCROLLBAR_WIDTH = 16
    local SCROLLBAR_OFFX = 3
    
    local scroll = CoreUICreateHybridStep1(nil, f(), nil, nil, true)
    WW(scroll):Key("scroll"):TL("$parentInset", TS.INSET_BORDER[1], -TS.INSET_BORDER[3] - TS.COLUMN_BUTTON_HEIGHT):BR("$parentInset", -TS.INSET_BORDER[2] - SCROLLBAR_WIDTH - SCROLLBAR_OFFX, TS.INSET_BORDER[4]):un()
    scroll.scrollBar.doNotHide = true
    S:HandleScrollBar(scroll.scrollBar)
    scroll.creator = function(self, index, name)
        local button = WW:Button(name, self.scrollChild):SetHeight(BUTTON_HEIGHT):LEFT():RIGHT()
            :Texture(nil, "BACKGROUND", "Interface\\GuildFrame\\GuildFrame"):SetParentKey("stripe"):ALL():up()
            :Texture(nil, nil, "Interface\\FriendsFrame\\UI-FriendsFrame-HighlightBar"):ToTexture("Highlight", "ADD"):ALL():up()
        button:SetID(index)
        button.widgets = {}
        local left = 0
        for idx, col in ipairs(TS.cols) do
            left = left + col.offset[1]
            local widget = col:create(button, idx)
            widget:LEFT(button, left, col.offset[2])
            left = left + col.width
            widget.right = left
            widget.index = idx
            button.widgets[idx] = widget:un()
        end
        
        return button:un()
    end
    
    scroll.getNumFunc = function() return #names end
    
    scroll.updateFunc = function(self, btn, id)
        btn.player = TS.db.players[names[id]]
        btn.player_name = names[id]
        for j = 1, #TS.cols do
            local col = TS.cols[j]
            if col.update then
                col.update(btn, btn.widgets[j], id, j)
            end
        end
        if (mod(id, 2) == 0) then
            btn.stripe:SetTexCoord(0.36230469, 0.38183594, 0.95898438, 0.99804688)
        else
            btn.stripe:SetTexCoord(0.51660156, 0.53613281, 0.88281250, 0.92187500)
        end
    end
    
    CoreUICreateHybridStep2(scroll, 0, 0, "TOPLEFT", "TOPLEFT", -1)
    f:SetScript("OnSizeChanged", CoreUICreateHybridButtonsOnSizeChanged)
end

function TS:UIUpdateNames()
    table.wipe(names)
    for name, _ in pairs(TS.names) do
        table.insert(names, name)
    end
    if (currSort) then
        table.sort(names, sortFuncs[abs(currSort)])
    end
    if f():IsVisible() then
        f.scroll.update()
    end
end

function TS:UIUpdate(flashing)
    if f():IsVisible() then
        f.scroll.update()
    else
        if flashing then UICoreFrameFlash(LibDBIcon10_TeamStats.icon, 0.5, 0.5, -1, 1, 0, 0) end
    end
end

function TeamStatsUI_CreateMinimapButton()
    local ldb = LibStub("LibDataBroker-1.1"):NewDataObject("TeamStats", {
        type = "launcher",
        label = "Team information statistics",
        icon = "Interface\\Icons\\Spell_Deathknight_UnholyPresence",
        iconCoords = {0.08, 0.92, 0.08, 0.92},
        OnClick = function(self, button)CoreUIShowOrHide(TeamStatsFrame, not TeamStatsFrame:IsVisible()) end,
    })
    LibStub("LibDBIcon-1.0"):Register("TeamStats", ldb, TeamStatsDB)
    CoreUIEnableTooltip(LibDBIcon10_TeamStats, L["MiniTipTitle"], L["MiniTip"])
    TeamStatsUI_CreateMinimapButton = nil
end

function TeamStatsUI_CreateLinkCopyDialog(main)
    local dialog = main:Frame("$parentLinkCopyDialog", "BasicFrameTemplate", "linkCopyDialog"):CENTER():SetSize(300, 80):SetFrameStrata("DIALOG"):Hide()
    dialog:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall"):SetText(L["CopyDialogTitleText"]):TL(10, -30)
    local dialogBox = dialog:EditBox(nil, "InputBoxTemplate", "eb"):BOTTOMLEFT(10, 5):RIGHT(-10, 0):SetHeight(20)
    dialogBox:SetScript("OnEscapePressed", function(self)self:GetParent():Hide() end)
    dialog.TitleText:SetText(L["BtnLinkText"])
end

function TeamStatsUI_CreateInfoDialog(main)
    local name
    local d = CoreUICreateDialog(name, main, 300, 200):CENTER():Hide()
    d.title:SetText("Friendly reminder")
    d.content = d:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall"):TL(20, -30):BR(-20, 0):SetJustifyV("TOP"):SetJustifyH("LEFT"):un()
    d.content:SetText("In order not to affect the normal game, the plugin gets a maximum of one player's achievement data every 5 seconds, and the player must be in the field of view. However, we provide a way to query the web and read the hero list directly. Show now, no need to wait! Please click on the web query button below.")
    local cb = TplCheckButton(d):SetSize(26):BL(20, 15):un()
    cb.text:SetText("Do not remind again")
    cb.func = function(self)
        TS.db.noRemind = self:GetChecked()
    end
    cb.tooltipText = "Check this box will no longer appear this prompt"
    local close = d:Button(nil, "UIPanelButtonTemplate"):SetText("I know"):SetSize(80, 26):BR(-20, 15):un()
    close:SetScript("OnClick", function(self)self:GetParent():Hide() end)
    
    local mask = d:Frame("MASK"):EnableMouse(true):TL(f, 0, 0):BR(f, 0, 0):SetFrameLevel(0)
    mask:CreateTexture():SetTexture(0, 0, 0, 0.5):TL():BR():up():un()
    
    main.infoDialog = d
    return d
end

function TS:LoadTeamStatsUI()
    TS.CreateButtons(f)
    TS.SetupColumns(f)
    TS.CreateScroll(f)
    TeamStatsUI_CreateLinkCopyDialog(f)
    CoreUICreateResizeButton(f(), "BOTTOMRIGHT", "BOTTOMRIGHT", 0, 0)
    CoreUIRegisterSlash("TeamStats", "/ts", "/teamstats", function()TeamStatsFrame:Show() end)
    
    TS.CreateButtons = nil
    TS.SetupColumns = nil
    TS.CreateScroll = nil
    TeamStatsUI_CreateInfoDialog = nil
    TeamStatsUI_CreateLinkCopyDialog = nil
    
    
    f:SetScript("OnShow", function(self)
        if (self.infoDialog and not TS.db.noRemind) then
            self.infoDialog:Show()
        end
        LibDBIcon10_TeamStats.icon.showWhenDone = 1
        UICoreFrameFlashStop(LibDBIcon10_TeamStats.icon)
        TS.SetTab(self.tabIdx or 1)
        self.scroll.update()
    end)
    
    local hideTargetButtons = function()
        if InCombatLockdown() then return end
        for _, line in next, f.scroll.buttons do
            if line.target then
                line.target:SetParent(nil)
                line.target:ClearAllPoints()
                line.target:Hide()
            end
        end
    end
    local ef = CoreOnEvent("PLAYER_REGEN_ENABLED", function() if f:IsVisible() then f.scroll.update() end end, true)
    CoreOnEvent("PLAYER_REGEN_DISABLED", hideTargetButtons, ef)
    f:SetScript("OnHide", hideTargetButtons)
    
	-- Make the frame look like KlixUI!
    _G["TeamStatsFrame"]:StripTextures()
    _G["TeamStatsFrame"]:Styling()
    _G["TeamStatsFrame"]:SetTemplate("Transparent")
    S:HandleButton(_G["TeamStatsFrameBtn1"])
    S:HandleButton(_G["TeamStatsFrameBtn3"])
    S:HandleButton(_G["TeamStatsFrameBtn4"])
    S:HandleNextPrevButton(_G["TeamStatsFrameDropdownButton"])
    S:HandleNextPrevButton(_G["TeamStatsFrameBtnPrev"], "left")
    S:HandleNextPrevButton(_G["TeamStatsFrameBtnNext"], "right")
    S:HandleCloseButton(_G["TeamStatsFrameCloseButton"])
end

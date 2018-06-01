---
--- Created by tanqiang.
--- DateTime: 2018/5/10 10:10
---
local ModuleCache = ModuleCache
local gamelogic = require("package.biji.module.tablebiji.gamelogic")
local tableEx   = require("package.biji.module.tablebijisix.table_ex")
local list      = require("list")
local class = require("lib.middleclass")
local HandPokers = class('HandPokers')

local combinations = { }
local _paixing = { }

function HandPokers:initialize(module)
    self.module = module
    self.view = module.view
    self.modelData = module.modelData
    self.isJoinAfterStart = nil
    self.waitPlayingFinishFunsQueue = list:new()
    self.player = { };
    self.player.XiPai = { }
    for i = 1, 11 do
        self.player.XiPai[i] = false
        -- 1,三清;2,全黑;3,全红;4,双顺清;5,三顺清;6,双三条;7,全三条;8,四个头(1);9,四个头(2);10,连顺;11,清连顺;12,三顺子
    end
    self.pokersNum = 9
    self.exchangePoker = { }

    self.modelData.matchPokers = {}
    for i = 1, 3 do
        self.modelData.matchPokers[i] = {}
    end
end

--保存手牌
function HandPokers:setOringinalServerPokers(pokers)
    self.oringinalServerPokers = { }
    self.isComparing = false;
    for i = 1, #pokers do
        self.oringinalServerPokers[i] = { }
        self.oringinalServerPokers[i].Color = pokers[i].Color
        self.oringinalServerPokers[i].Number = pokers[i].Number
    end
end

--- 保存手牌
--- @param handPokers
--- @param isFirst true代表新发牌
function HandPokers:setPokersInHand(handPokers, isFirst)
    self:checkHandPokersInOringinalPokers(handPokers)
    self.view:showDealTable(true);
    if (self.modelData ~= nil) then
        self.modelData.selectList = { };
    end
    self.handPokers = { };
    if (isFirst) then
        self:clearAllMatchingData()
        self.oringinalPokers = { };
    end
    for j = 1, #handPokers do
        local poker = { }
        poker.Color = handPokers[j].Color;
        poker.Number = tonumber(handPokers[j].Number);
        poker.selected = false;
        poker.showed = false;
        table.insert(self.handPokers, poker);
        if (isFirst) then
            table.insert(self.oringinalPokers, poker);
        end
    end
    self:sortPoker(self.handPokers, true);
    if (isFirst) then
        self.pokersInDesc = { };
        local onFinish = function()
            self:setDealBtnActive();
        end
        self:sortPoker(self.oringinalPokers, true);
        for key, v in ipairs(self.oringinalPokers) do
            table.insert(self.pokersInDesc, v);
        end
        self:sortPoker(self.pokersInDesc, false);
        self.mask = gamelogic.PokerToMask(self.pokersInDesc);
        self.view:setSelfImageActive(false);
        self:checkHandPokersInOringinalPokers(self.oringinalPokers)
        self.view:refreshPokersInHand(self.oringinalPokers, isFirst, onFinish); --todo
    else
        self:checkHandPokersInOringinalPokers(self.handPokers)
        self.view:refreshPokersInHand(self.handPokers, isFirst);
    end
    local _index = 1;
    for key, v in ipairs(self.handPokers) do
        v.gameObject = self.view.inHandPokers[_index]["gameobject"];
        v.image = self.view.inHandPokers[_index]["image"];
        self.view:refreshCardSelect(v);
        _index = _index + 1;
        if (isFirst) then
            self.isJoinAfterStart = false;
        end
    end

    if (not isFirst) then
        self:setDealBtnActive();
    end
end

--清理配牌相关数据
function HandPokers:clearMatchingTable()
    for i = 1, #self.modelData.matchPokers do
        self.modelData.matchPokers[i] = {}
    end
    for i = 1, 3 do
        self.view:showMatchingPokers(i, false);
    end
    self.view:setExchangeHintActive(false); --后期需要设置
end

--重置比牌数据
function HandPokers:clearAllMatchingData()
    self.modelData.selectList = { };
    for i = 1, #self.modelData.matchPokers do
        self.modelData.matchPokers[i] = {}
    end
    self.handPokers = { };
    self.oringinalPokers = { };
    self.pokersInDesc = { };-- 发给服务器的数据
end

--取消所有已经配置在牌道上的牌
function HandPokers:resetMatchAll()
    for i = 1, #self.modelData.matchPokers do
        if #self.modelData.matchPokers[i] ~= 0 then
            self:cancelMatchByIndex(i)
        end
    end
end

-- 排序
function HandPokers:checkedSequence(err_no, pokers)
    self:checkHandPokersInOringinalPokers(pokers)
    local error = tonumber(err_no);
    local pai = { };
    if (error == 0) then
        -- 与服务器交互后
        for i = 1, #self.modelData.matchPokers do
            table.insert(pai, self.modelData.matchPokers[i]);
        end
        self.player.Poker = self.pokersInDesc;
        self.player.Pai = pai;
        gamelogic.ComputeXiPai(self.player.Pai, self.player.Poker, self.player.XiPai, self.maskXiPai);
        return;
    end

    local function set_match_pokers_data(_datatable, _index)
        for j = 1, 3 do
            _datatable[j].Color = pokers[j +(_index - 1) * 3].Color;
            _datatable[j].Number = tonumber(pokers[j +(_index - 1) * 3].Number);
            _datatable[j].selected = false;
            _datatable[j].showed = false;
        end
    end

    for i = 1, #self.modelData.matchPokers do
        set_match_pokers_data(self.modelData.matchPokers[i], i)
        table.insert(pai, self.modelData.matchPokers[i])
        self.view:setMatchingShow(i, self.modelData.matchPokers[i], false)
    end
    self.player.Poker = self.pokersInDesc;
    self.player.Pai = pai;
end

-- 检测牌是否合法
function HandPokers:checkHandPokersInOringinalPokers(needCheckPokers)
    if not needCheckPokers then
        print("needCheckPokers is nil")
        return
    end

    local inOringinalPokers = true
    if #needCheckPokers < 11 then
        local handPokersCount = { }
        local keyTmp = nil
        for i = 1, #needCheckPokers do
            -- 需要过滤重复的牌
            keyTmp = needCheckPokers[i].Number .. "_" .. needCheckPokers[i].Color
            handPokersCount[keyTmp] =(handPokersCount[keyTmp] or 0) + 1
            if handPokersCount[keyTmp] > 1 then
                inOringinalPokers = false
                break
            end
            for j = 1, #self.oringinalServerPokers do
                if needCheckPokers[i].Color == self.oringinalServerPokers[j].Color and needCheckPokers[i].Number == self.oringinalServerPokers[j].Number then
                    inOringinalPokers = true
                    break
                else
                    inOringinalPokers = false
                end
            end
        end
    else
        inOringinalPokers = false
    end

    if #needCheckPokers > 0 and not inOringinalPokers then
        if ModuleCache.GameManager.isEditor then
            ModuleCache.GameSDKInterface:PauseEditorApplication(true)
        else
            ModuleCache.GameManager.logout()
        end
        print_table(needCheckPokers, "牌型数据错误，触发断线重连")
        ModuleCache.GameSDKInterface:BuglyPrintLog(5, "牌型数据错误，触发断线重连")
        if self.oringinalServerPokers then
            log_table(self.oringinalServerPokers)
            log_table(needCheckPokers)
        end
        -- 故意设置错误代码好上报Bugly
        local test = kjkd > 0
    end
end


-- 排序  sortType排序类型
function HandPokers:sortPoker(poker, flag)
    if poker and #poker == 0 then
        return
    end
    self:checkHandPokersInOringinalPokers(poker);
    table.sort(poker, function (a, b)
        if self.view.currentSortType == self.view.SORT_POKER_TYPE.SIZE then
            if a.Number == b.Number then
                return a.Color > b.Color
            end
            return a.Number > b.Number
        elseif self.view.currentSortType == self.view.SORT_POKER_TYPE.COLOR then
            if (a.Color == b.Color) or a.Number == 15 or b.Number == 15 then
                return a.Number > b.Number
            end
            return a.Color > b.Color
        end
    end)
    self:checkHandPokersInOringinalPokers(poker)
end

--选择单张牌
function HandPokers:onSelectPokerClick(obj)
    self.lastSelectPoker = obj
    self:selectPoker(obj)
end

-- 选择的牌
function HandPokers:selectPoker(obj)
    if obj == nil then return end
    local count = #self.modelData.selectList;
    self.selectindex = 1;
    for key, v in ipairs(self.handPokers) do
        if (v.image.gameObject == obj) then
            if v.selected then
                if count <= 0 then return end
                v.selected = false;
                for key2, v2 in ipairs(self.modelData.selectList) do
                    if v.image.gameObject == v2.image.gameObject then
                        table.remove(self.modelData.selectList, key2);
                        break;
                    end
                end
            else
                if (count >= 3) then return end
                v.selected = true;
                table.insert(self.modelData.selectList, v);
            end
            if (#self.exchangePoker <= 0 or self.exchangePoker[1].indexMatch == 5) then
                self.view:refreshCardSelect(v, true);
            end
            break;
        end
    end
end

--取消选中的手牌
function HandPokers:cancelSelectPokers()
    self.lastSelectPoker = nil
    if #self.modelData.selectList <= 0 then return end
    for i = 1, #self.modelData.selectList do
        local handIndex = tableEx.keyof(self.handPokers, self.modelData.selectList[i])
        if handIndex ~= nil then
            self.handPokers[handIndex].selected = false
            self.view:refreshCardSelect(self.handPokers[handIndex], false);
        end
    end
    self.modelData.selectList = {}
end

--根据按钮提示 自动选牌
function HandPokers:showSelectPokersTips(obj)
    local paixingType =  tableEx.keyof(self.view.buttons_by_type, obj)
    if paixingType == nil then return end
    local _typepokers = self:setTypePokers(paixingType)
    if not _typepokers or #_typepokers ~= 3 then
        return;
    end

    if #self.modelData.selectList <= 3 then
        for key, v in ipairs(self.modelData.selectList) do
            v.selected = false;
            self.view:refreshCardSelect(v, false);
        end
    end
    self.modelData.selectList = { };
    local _pokers = self.handPokers;
    for key, v in ipairs(_typepokers) do
        for _key1, v1 in ipairs(_pokers) do
            if v.Number == v1.Number and v.Color == v1.Color then
                v1.selected = true;
                table.insert(self.modelData.selectList, v1);
                self.view:refreshCardSelect(v1, true);
                break;
            end
        end
    end

end

-- 根据点击提示按钮设置牌型提示
function HandPokers:setTypePokers(paixingType)
    local _restpokers = { };
    local _pokers = self.handPokers;
    for key, v in ipairs(_pokers) do
        if (not v.showed) then
            table.insert(_restpokers, v);
        end
    end
    if (self.restcount ~= #_restpokers) then
        self.restcount = #_restpokers;
        self.lastPaixingType = nil;
        combinations = { };
        local gpos = { }
        gamelogic.CombinePoker(_restpokers, combinations, gpos);

        local gpai = { }
        for i = 1, #combinations do
            local res, value = gamelogic.ComputePaixing(combinations[i], self.mask)
            combinations[i].px = res
            combinations[i].value = value
            gpai[gpos[i]] = i
            if res ~= 1 then
                local temp
                if res == 5 then
                    -- 同花顺也属于同花和顺子
                    for j = 1, 3 do
                        temp = #_paixing[res - j] + 1
                        _paixing[res - j][temp] = combinations[i]
                    end
                else
                    temp = #_paixing[res - 1] + 1
                    _paixing[res - 1][temp] = combinations[i]
                end
            end
        end
        for i = 1, 5 do
            gamelogic.SortPai(_paixing[i], true)
        end
    end
    if self.lastPaixingType ~= paixingType then
        self.selectindex = 1;
        self.lastPaixingType = paixingType;
    else
        self.selectindex = self.selectindex + 1;
    end

    local _count = #_paixing[paixingType]
    if _count ~= 0 then
        if self.selectindex > _count then
            self.selectindex = 1;
        end
        return _paixing[paixingType][self.selectindex];
    end
    return nil
end

-- 设置整个牌的界面显示
function HandPokers:setDealBtnActive(isFirst)
    local _restpokers = { };
    local pokers = { };
    -- 手上的牌
    for key, v in ipairs(self.handPokers) do
        local poker = { };
        poker.Number = v.Number;
        poker.Color = v.Color
        table.insert(pokers, poker);
    end
    local _pokers = pokers;
    self:sortPoker(_pokers, false);
    for key, v in ipairs(_pokers) do
        if (not v.showed) then
            table.insert(_restpokers, v);
        end
    end

    self.restcount = #_restpokers;
    self.btnname = "";
    combinations = { };
    local gpos = { }
    gamelogic.CombinePoker(_restpokers, combinations, gpos);
    _paixing = { };
    for _, v in pairs(self.view.PAIXING_TYPE) do
        _paixing[v] = { }
    end
    local gpai = { }
    for i = 1, #combinations do
        local res, value = gamelogic.ComputePaixing(combinations[i], self.mask)
        combinations[i].px = res
        combinations[i].value = value
        gpai[gpos[i]] = i
        if res ~= 1 then
            local temp
            if res == 5 then
                -- 同花顺也属于同花和顺子
                for j = 1, 3 do
                    temp = #_paixing[res - j] + 1
                    _paixing[res - j][temp] = combinations[i]
                end
            else
                temp = #_paixing[res - 1] + 1
                _paixing[res - 1][temp] = combinations[i]
            end
        end
    end

    for _, v in pairs(self.view.PAIXING_TYPE) do
        gamelogic.SortPai(_paixing[v], true)
        self.view:setDealBtnActive(v, (#_paixing[v] ~= 0) and true or false)
    end
end

--检查是否可以提交配牌
function HandPokers:checkIsCanSubmitPokers()
    local pokers = { };
    for i = 1, #self.modelData.matchPokers do
        for _, v in ipairs(self.modelData.matchPokers[i]) do
            local poker = { };
            poker.Color = v.Color;
            poker.Number = v.Number;
            table.insert(pokers, poker);
        end
        if #self.modelData.matchPokers[i] ~= 3 then
            ModuleCache.ModuleManager.show_public_module("textprompt"):show_center_tips("未完成配牌！")
            return nil
        end
    end
    return pokers
end

--取消某道牌
function HandPokers:cancelMatchByIndex(index)
    self:cancel_all_change_poker()
    if self.modelData.matchPokers[index] == nil then return end
    for _, v in ipairs(self.modelData.matchPokers[index]) do
        v.showed = true;
        v.selected = false;
        local poker = { };
        poker.Number = v.Number;
        poker.Color = v.Color;
        poker.showed = v.showed;
        poker.selected = v.selected;
        poker.gameObject = v.gameObject;
        poker.image = v.image;
        table.insert(self.handPokers, poker);
        self.view:refreshCardSelect(v, false);
    end
    self.modelData.matchPokers[index] = { };
    self:setPokersInHand(self.handPokers, false)
    self.view:showMatchingPokers(index);
    self.view:showCloseMatchBtn(index, false);
    self.view:showEnterMatchBtn(false)
    self.view:setExchangeHintActive(false)
end

--取消选中更换的牌
function HandPokers:cancel_all_change_poker()
    --首先取消掉选中的牌
    for i = 1, #self.exchangePoker do
        self.view:setExchangePokerColor(self.exchangePoker[i].indexMatch, self.exchangePoker[i].index, false);
    end
    self.exchangePoker = {}
end


--- 点击配牌窗口
--- @param index 配牌选项
--- @param isFastMatching 是否为快速配牌，也就是推荐配牌
function HandPokers:setMatchByIndex( index )
    if #self.modelData.selectList ~= 3 then return end

    local function get_poker(pokerData)
        local poker = { };
        poker.Number = pokerData.Number;
        poker.Color = pokerData.Color;
        poker.showed = pokerData.showed;
        poker.selected = pokerData.selected;
        poker.gameObject = pokerData.gameObject;
        poker.image = pokerData.image;
        return poker
    end

    local fullIndex = 0;
    for i = 1, #self.modelData.matchPokers do
        if #self.modelData.matchPokers[i] ~= 0 then
            fullIndex = i
        end
    end

    local function show_match_poker(_matchData, _index)
        if _matchData == nil or #_matchData ~= 0 then return end
        for key, v in ipairs(self.modelData.selectList) do
            v.showed = false;
            v.selected = false;
            local poker = get_poker(v)
            table.insert(_matchData, poker);
            for k, value in ipairs(self.handPokers) do
                if (v.Number == value.Number and v.Color == value.Color) then
                    table.remove(self.handPokers, k);
                end
            end
        end
        self:sortPoker(_matchData, false);
        self:setPokersInHand(self.handPokers, false);
        self.view:setMatchingShow(index, _matchData, fullIndex == 0 and true or false)
        self.modelData.selectList = { };
        self.view:showMatchingPokers(_index, true);
    end

    show_match_poker(self.modelData.matchPokers[index], index)

    local curMatchPokerCount = 0
    for i = 1, #self.modelData.matchPokers do
        curMatchPokerCount = curMatchPokerCount + #self.modelData.matchPokers[i]
    end
    -- 最后一道牌 自动配置
    if (curMatchPokerCount == 6 and self.pokersNum == 9) then
        -- 出现大BUG了，因为最后的手牌不是3张了
        if self.handPokers and #self.handPokers ~= 3 then
            if self.modelData.bullfightClient.clientConnected then
                TableManagerPoker:heartbeat_timeout_reconnect_game_server()
                return
            end
        end

        local function set_null_match_pokers(_matchData, _matchIndex)
            if (#_matchData ~= 0) then return end
            local count = 0;
            for key, v in ipairs(self.handPokers) do
                v.showed = false;
                v.selected = false;
                local poker = get_poker(v)
                table.insert(_matchData, poker);
                local _index = tonumber(v.gameObject.name) + 1;
                --self.view:PlayAnimHandToMatch(_index, 1, count + 1); TODO
                count = count + 1;
            end
            self:sortPoker(_matchData, false);
            self.view:setMatchingShow(_matchIndex, _matchData, false);
            self.view:showMatchingPokers(_matchIndex, true);
        end
        for i = 1, #self.modelData.matchPokers do
            set_null_match_pokers(self.modelData.matchPokers[i], i)
        end
        self.handPokers = { };
        self:setPokersInHand(self.handPokers, false)
    end

    local isMatchOver = true
    for i = 1, #self.modelData.matchPokers do
        if self.modelData.matchPokers[i] == nil then
            return
        end
        isMatchOver = isMatchOver and #self.modelData.matchPokers[i] == 3
    end
    self.view:showEnterMatchBtn(isMatchOver)
    if (isMatchOver) then
        local pokers = { };
        local function set_match_poker(_matchData)
            for _, v in ipairs(_matchData) do
                local poker = { };
                poker.Color = v.Color;
                poker.Number = v.Number;
                table.insert(pokers, poker);
            end
        end
        for i = 1, #self.modelData.matchPokers do
            set_match_poker(self.modelData.matchPokers[i])
        end

        local isNeedToChange = self:localCheckSequence();
        if (isNeedToChange) then
            self.module:subscibe_time_event(3, false, 0):OnComplete( function(t)
                if (#self.handPokers > 0) then
                    return;
                end
                self.view:setExchangeHintActive(true);
            end )
        else
            self.view:setExchangeHintActive(true);
        end;
    end
    self:setDealBtnActive();
end

-- 配牌
function HandPokers:onClickPokersOnMatch(obj)
    if obj == nil then return end
    if (obj.transform.parent.name ~= "pokersOnMatch" and obj.transform.parent.parent.name ~= "pockers") then
        return;
    end
    self.view:setExchangeHintActive(false);
    local index;

    if (obj.transform.parent.name == "pokersOnMatch") then
        index = tonumber(obj.name) + 1;
    end
    --local curMatch = { };
    -- 1代表第一道牌，2代表第二道牌，3代表第三道牌，4代表第10张牌，5代表手牌
    local indexMatch = 0;
    if (obj.transform.parent.parent.gameObject.name == "match_1") then
        indexMatch = 1
    elseif (obj.transform.parent.parent.gameObject.name == "match_2") then
        indexMatch = 2;
    elseif (obj.transform.parent.parent.gameObject.name == "match_3") then
        indexMatch = 3;
    end
    local curMatch =  indexMatch ~= 0 and self.modelData.matchPokers[indexMatch] or {}

    if (obj.transform.parent.parent.gameObject.name == "pockers") then
        -- 当选中手牌时indexMatch为5
        index = tonumber(obj.transform.parent.gameObject.name) + 1;
        indexMatch = 5;
        curMatch = self.handPokers;
        if (#self.modelData.selectList > 1) then
            self.exchangePoker = { };
            return;
        end
    end

    if (#self.exchangePoker == 0) then
        -- 当未选中牌时
        local poker = { };
        if (obj.transform.parent.parent.gameObject.name == "pockers") then
            if #self.modelData.selectList ~= 1 then return end
            poker.index = self:getSelectedPokerIndex()
            poker.indexMatch = indexMatch
            poker.Number = self.modelData.selectList[1].Number
            poker.Color = self.modelData.selectList[1].Color
        else
            if (#self.modelData.selectList > 1) then return end
            poker.index = index;
            poker.indexMatch = indexMatch;
            poker.Number = curMatch[index].Number;
            poker.Color = curMatch[index].Color;
        end
        table.insert(self.exchangePoker, poker);
        self.view:setExchangePokerColor(indexMatch, index, true);
    elseif (#self.exchangePoker == 1) then
        -- 当选中牌时
        local oldIndexMatch = self.exchangePoker[1].indexMatch;
        local oldIndex = self.exchangePoker[1].index;
        if (indexMatch == oldIndexMatch) then
            self.exchangePoker = { };
            self.view:setExchangePokerColor(oldIndexMatch, oldIndex, false);
            return;
        end
        self.isExchangeFinish = false;
        local poker = { };
        poker.index = index;
        poker.indexMatch = indexMatch;
        poker.Number = curMatch[index].Number;
        poker.Color = curMatch[index].Color;
        curMatch[index].Color = self.exchangePoker[1].Color;
        curMatch[index].Number = self.exchangePoker[1].Number;
        if (indexMatch <= 3) then
            self:sortPoker(curMatch, false);
            self:checkHandPokersInOringinalPokers(curMatch);
            self.view:setMatchingShow(indexMatch, curMatch, 0, false);
        end
        if (indexMatch == 5) then
            self:setPokersInHand(curMatch, false);
        end
        local oldMatch = { };
        local oldIndexMatch = self.exchangePoker[1].indexMatch;
        local oldIndex = self.exchangePoker[1].index;
        if (oldIndexMatch == 1 or oldIndexMatch == 2 or oldIndexMatch == 3) then
            oldMatch = self.modelData.matchPokers[oldIndexMatch]
        elseif (self.pokersNum == 10 and oldIndexMatch == 4) then
            table.insert(oldMatch, self.tenthPoker)
        elseif (oldIndexMatch == 5) then
            oldMatch = self.handPokers;
        end
        self.view:setExchangePokerColor(oldIndexMatch, oldIndex, false);
        oldMatch[oldIndex].Color = poker.Color;
        oldMatch[oldIndex].Number = poker.Number;
        self:sortPoker(oldMatch, false);
        if (oldIndexMatch ~= 5) then
            self.view:setMatchingShow(self.exchangePoker[1].indexMatch, oldMatch, 0, false);
        else
            self:setPokersInHand(self.handPokers, false);
        end
        -- 如果已经放了三道牌上去
        local isThreeMatch = true
        for i = 1, #self.modelData.matchPokers do
            if #self.modelData.matchPokers[i] ~= 3 then
                isThreeMatch = false
                break
            end
        end
        if isThreeMatch then self:localCheckSequence() end
        self.exchangePoker = { };
    end
end

function HandPokers:getSelectedPokerIndex()
    for i = 1, #self.handPokers do
        if (self.handPokers[i].selected) then
            return i;
        end
    end
    return -1;
end

--- 本地排序三道牌
function HandPokers:localCheckSequence()
    local matches = { };
    local pokers = { };
    local mask = { };
    local function clone_match_pokers_data(_matchData, _index)
        for j = 1, 3 do
            local poker = { };
            poker.Color = _matchData[j].Color;
            poker.Number = _matchData[j].Number;
            mask[poker.Number * 4 + poker.Color] = true;
            table.insert(matches[_index], poker);
        end
        matches[_index]["index"] = _index;
    end

    for i = 1, 3 do
        matches[i] = { };
        clone_match_pokers_data(self.modelData.matchPokers[i], i)
    end
    gamelogic.SortHBTPai(matches, mask)

    local needToChange = false;
    for i = 1, 3 do
        local srcIndex = matches[i]["index"];
        local desIndex = i;
        if (srcIndex ~= desIndex) then
            needToChange = true;
        end
    end
    if (needToChange) then
        -- 自动变牌
        self.view:setErrHintActive(true);
    end

    for i = 1, 3 do
        for j = 1, 3 do
            table.insert(pokers, matches[i][j])
        end
    end

    self:checkedSequence(1, pokers);
    return needToChange;
end


return HandPokers
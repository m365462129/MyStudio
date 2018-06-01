--- 三公结算界面
--- Created by 袁海洲
--- DateTime: 2017/11/28 11:31
---
-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================

local TableResultView = Class('tableResultView', View)

local ModuleCache = ModuleCache

local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponentWithPath = ModuleCache.ComponentUtil.GetComponentWithPath

function TableResultView:initialize(...)
    -- 初始View
    View.initialize(self, "sangong/module/tableresult/sangong_tableresult.prefab", "SanGong_TableResult", 1)

    self.buttonBack = GetComponentWithPath(self.root, "Center/Buttons/ButtonBack", ComponentTypeName.Button)
    self.buttonShare = GetComponentWithPath(self.root, "Center/Buttons/ButtonShare", ComponentTypeName.Button)
    self.buttonOnceMore = GetComponentWithPath(self.root, "Center/Buttons/ButtonOnceMore", ComponentTypeName.Button)

    self.textRoomNum = GetComponentWithPath(self.root, "Title/TextRoomNum", ComponentTypeName.Text)
    self.textTime = GetComponentWithPath(self.root, "Title/TimeNum", ComponentTypeName.Text)
    self.textHallNum = GetComponentWithPath(self.root, "Title/HallNum", ComponentTypeName.Text)

    self.goPlayersRoot = GetComponentWithPath(self.root, "Center/Players", ComponentTypeName.Transform).gameObject

    self.resultInfos = {}
    for i=1,6 do
        local root = GetComponentWithPath(self.goPlayersRoot, tostring(i), ComponentTypeName.Transform).gameObject
        table.insert(self.resultInfos,self:InitResultInfo(root))
        ModuleCache.ComponentUtil.SafeSetActive(root, false)
    end
end

function TableResultView:on_view_init()

end

function TableResultView:get_result_share_data()

end

function TableResultView:refreshRoomInfo(roomNum,name,curRoundNum,totalRoundNum,startTime,endTime)
    self.textRoomNum.text = "房号:"..roomNum.."  "..name.."  第"..curRoundNum.."/"..totalRoundNum.."局";
    local startTimeText = os.date("%Y-%m-%d %H:%M:%S", tonumber(startTime))
    local endTimeText = os.date("%Y-%m-%d %H:%M:%S",  tonumber(endTime))
    self.textTime.text = "开始 "..startTimeText.."\n结束 "..endTimeText
    self.textHallNum.gameObject:SetActive(self.modelData.roleData.HallID > 0)
    if(self.modelData.roleData.HallID > 0) then
        self.textHallNum.text = "圈号:"..self.modelData.roleData.HallID
    end
end

function TableResultView:InitResultInfo(resultInfoRoot)
    local resultInfo = {}
    resultInfo.root = resultInfoRoot
    resultInfo.textID = GetComponentWithPath(resultInfo.root, "Role/ID/TextID", ComponentTypeName.Text)
    resultInfo.textName = GetComponentWithPath(resultInfo.root, "Role/Name/TextName", ComponentTypeName.Text)
    resultInfo.headImage = GetComponentWithPath(resultInfo.root, "Role/Avatar/Avatar/Image", ComponentTypeName.Image)
    resultInfo.imageRoomCreator =  GetComponentWithPath(resultInfo.root, "Role/ImageRoomCreator", ComponentTypeName.Image)
    resultInfo.imageWinner =  GetComponentWithPath(resultInfo.root, "Role/ImageWinner", ComponentTypeName.Image)
    resultInfo.imageDisbander =  GetComponentWithPath(resultInfo.root, "Role/ImageDisbander", ComponentTypeName.Image)

    resultInfo.textWinCount = GetComponentWithPath(resultInfo.root, "DetailScore/WinCount/value", ComponentTypeName.Text)
    resultInfo.textLoseCount = GetComponentWithPath(resultInfo.root, "DetailScore/LoseCount/value", ComponentTypeName.Text)
    resultInfo.textSanGongCount = GetComponentWithPath(resultInfo.root, "DetailScore/SanGongCount/value", ComponentTypeName.Text)
    resultInfo.textSanZhangCount = GetComponentWithPath(resultInfo.root, "DetailScore/SanZhangCount/value", ComponentTypeName.Text)

    resultInfo.textGreenScore = GetComponentWithPath(resultInfo.root, "TotalScore/greenScore","TextWrap")
    resultInfo.textRedScore = GetComponentWithPath(resultInfo.root, "TotalScore/redScore","TextWrap")

    return resultInfo
end

function TableResultView:refreshPlayerResultInfo(data,index)
    local resultInfo = self.resultInfos[index]

    ModuleCache.ComponentUtil.SafeSetActive(resultInfo.root,true)

    resultInfo.textID.text = "ID:"..data.player_id

    --resultInfo.textName.text = playerData.nickname
    --resultInfo.headImage = playerData.headImg

    self:get_userinfo(data.player_id, function(err, playerinfo)
        if(err)then
            --self:get_userinfo(data.player_id)
            resultInfo.textName.text = ""
            resultInfo.headImage.sprite = nil
            return
        end
        resultInfo.textName.text = playerinfo.nickname
        self:startDownLoadHeadIcon(resultInfo.headImage ,playerinfo.headImg, function (sprite )
        end)
    end)

    local score = data.score  --总积分
    if score < 0  or score == 0 then
        resultInfo.textGreenScore.text =  tostring(score)
    else
        resultInfo.textRedScore.text =  "+"..score
    end

    resultInfo.textWinCount.text  = tostring(data.win_cnt)  --胜利次数
    resultInfo.textLoseCount.text = tostring(data.lost_cnt ) --失败次数
    resultInfo.textSanGongCount.text = tostring(data.triple_cnt) --三公次数
    resultInfo.textSanZhangCount.text = tostring(data.triple_3_cnt) --三张三次数

    local current_score = data.current_score  --本局积分
    local multiple = data.multiple  --倍数
    local cards = data.cards --手牌
    local card_type = data.card_type --手牌类型
end

---设置大赢家标志
function TableResultView:SetWinerTag(index,state)
    local resultInfo = self.resultInfos[index]
    ModuleCache.ComponentUtil.SafeSetActive(resultInfo.imageWinner.gameObject, state)
end
---设置房间解散者标记
function TableResultView:SetDisbanderTag(index,state)
    local resultInfo = self.resultInfos[index]
    ModuleCache.ComponentUtil.SafeSetActive(resultInfo.imageDisbander.gameObject, state)
end
---设置房主标志
function TableResultView:SetRoomCreator(index,state)
    local resultInfo = self.resultInfos[index]
    ModuleCache.ComponentUtil.SafeSetActive(resultInfo.imageRoomCreator.gameObject, state)
end
---获取玩家信息
function TableResultView:get_userinfo(playerId, callback)
    local requestData = {
        baseUrl = ModuleCache.GameManager.netAdress.httpCurApiUrl .. "user/info?",
        params = {
            uid = playerId,
        },
        cacheDataKey = "user/info?uid=" .. playerId
    }
    self:http_get(requestData, function(wwwOperation)
        local www = wwwOperation.www;
        local retData = ModuleCache.Json.decode(www.text)
        if retData.ret and retData.ret == 0 then    --OK
            callback(nil, retData.data)
        else
            callback(retData.ret, nil)
        end
    end, function(error)
        print(error.error)
        callback(error.error, nil)
    end, function(cacheDataText)
        local retData = ModuleCache.Json.decode(cacheDataText)
        if retData.ret and retData.ret == 0 then    --OK
            callback(nil, retData.data)
        else
            callback(retData.ret, nil)
        end
    end)
end
---下载头像
function TableResultView:startDownLoadHeadIcon(targetImage, url, callback)
    ModuleCache.TextureCacheManager.loadTexFromCacheOrDownload(url, function(err, tex)
        if(err) then
            print('error down load '.. url .. 'failed:' .. err.error)
            if string.find(err.error, 'Network Timeout') and string.find(err.error, 'http') == 1 then
                if(self)then
                    --self:startDownLoadHeadIcon(targetImage, url, callback)
                end
            end
        else
            if targetImage then
                targetImage.sprite = tex
            end
            if(callback)then
                callback(tex)
            end
            -- ModuleCache.CustomerUtil.AttachTexture2Image(targetImage, tex)
        end
    end)
end

return TableResultView
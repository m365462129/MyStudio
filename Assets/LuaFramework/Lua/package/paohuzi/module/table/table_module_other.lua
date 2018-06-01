local TableModule = PaoHuZi_TableModule

local ModuleCache = ModuleCache
local ModuleManager = ModuleCache.ModuleManager

local PlayerView = require("package.paohuzi.module.table.player_view")
local CardCtrlView = require("package.paohuzi.module.table.cardctrl_view")
local HandCardView = require("package.paohuzi.module.table.handcard_view")
local SoundManager = require("package.paohuzi.module.table.sound_manager")

local Manager = require("package.public.module.function_manager")
local TableUtilPaoHuZi = require("package.paohuzi.module.tablebase.table_util")



local ComponentUtil = ModuleCache.ComponentUtil
local DoTween = DG.Tweening.DOTween

local UnityEngine = UnityEngine
local Input = UnityEngine.Input


function TableModule:init_other()
    local key = string.format("%s_LocationSetting",ModuleCache.GameManager.curGameId)
    if UnityEngine.PlayerPrefs.HasKey(key) then
        local curLocationSetting = UnityEngine.PlayerPrefs.GetInt(key)
        SoundManager.location_setttingPuTong = curLocationSetting
    else
        SoundManager.location_setttingPuTong = nil
    end


    self:subscibe_package_event("Event_RoomSetting_location_settting", function(eventHead, eventData)
        local key = string.format("%s_LocationSetting",ModuleCache.GameManager.curGameId)
        local curLocationSetting = UnityEngine.PlayerPrefs.GetInt(key)
        SoundManager.location_setttingPuTong = curLocationSetting

        print(SoundManager.location_setttingPuTong)
    end)

    self:InitActivity_module()
end

--- 字牌设置
function TableModule:SetZP_ZPPaiLeiStart()
    local zipaiz = UnityEngine.PlayerPrefs.GetInt("ZP_ZPPaiLei" .. AppData.Game_Name, -1)
    if zipaiz == -1 then
        if AppData.Game_Name == "GLZP" then
            self:SetZP_ZPPaiLei(3)
        end

        if AppData.Game_Name == "XXZP" then
            self:SetZP_ZPPaiLei(2)
        end

        if AppData.Game_Name == "LDZP" then
            self:SetZP_ZPPaiLei(2)
        end

        if AppData.Game_Name == "DYZP" then
            self:SetZP_ZPPaiLei(1)
        end
    end
    local zipaiz = UnityEngine.PlayerPrefs.GetInt("ZP_ZPPaiLei" .. AppData.Game_Name, 1)
    DataPaoHuZi.ZP_ZPPaiLei = zipaiz


    local bg1 = Manager.FindObject(self.view.chuzhangObj, "Image/1")
    local bg2 = Manager.FindObject(self.view.chuzhangObj, "Image/2")

    self.view.FaPaiTeXiao1:SetActive(false)
    self.view.FaPaiTeXiao2:SetActive(false)
    bg1:SetActive(false)
    bg2:SetActive(false)

    if zipaiz == 3 then
        self.view.FaPaiTeXiao = self.view.FaPaiTeXiao1
        self.view.PaiBeiMen1.gameObject:SetActive(true)
        self.view.PaiBeiMen2.gameObject:SetActive(false)
        bg2:SetActive(true)
    else
        self.view.FaPaiTeXiao = self.view.FaPaiTeXiao2
        self.view.PaiBeiMen1.gameObject:SetActive(false)
        self.view.PaiBeiMen2.gameObject:SetActive(true)
        bg1:SetActive(true)
    end


 
end

function TableModule:InitActivity_module()
    local object = 
    {
    buttonActivity=self.view.ButtonActivity,
    spriteRedPoint = self.view.spriteRedPoint
    }
    ModuleCache.ModuleManager.show_public_module("activity", object);
end

function TableModule:Event_RoomSetting_ZiPaiSheZhi()
    
    self:SetZP_ZPPaiLeiStart()
    

    -- 小结算和 大结算阶段不能换牌... 否则容易引起更大的问题
    if DataPaoHuZi.Msg_Table_GameStateNTF and DataPaoHuZi.Msg_Table_GameStateNTF.result ~= 0 then
        return
    end

    --local obj = UnityEngine.GameObject.Find("HeNanMJ_WindowRoomSetting(Clone)")
    --if obj == nil then
    --    return
    --end

    --self:bind_handcard_v iew()
    DataPaoHuZi.booIsLoadAll_ZiPai = true
    DataPaoHuZi.chuzhangValue = nil
    table.insert(self.gameStateTable, DataPaoHuZi.Msg_Table_GameStateNTF)
    self:start_lua_coroutine(
        function()
            coroutine.wait(0.8)
            DataPaoHuZi.booIsLoadAll_ZiPai = nil
        end
    )
    local text = string.format("%s %s", self.view.txtRoomID.text, self.view.txtJushu.text)
end

function TableModule:SetZP_ZPPaiLei(zipai)
    UnityEngine.PlayerPrefs.SetInt("ZP_ZPPaiLei" .. AppData.Game_Name, zipai)
end

function TableModule:check_activity_is_open(callback)
    
end


-- 防作弊 匹配
function TableModule:fangzuobiPiPei()
    local ruleInfo = TableUtilPaoHuZi.convert_rule(TableManager.phzTableData.Rule)
    if ruleInfo.baseScore and ruleInfo.isPrivateRoom ~= true then
        


        local function func1()
            self.view.buttonWarning.gameObject:SetActive(false)
            self.view.ImageAnticheat.gameObject:SetActive(true)
            self.view.RightBtn.gameObject:SetActive(false)
            self.view.txtRoomID.gameObject:SetActive(false)
            for j = 1, 3 do
                if self.playersView[j] and self.playersView[j].seatIndex ~= 1 then
                    self.playersView[j].seat.FangZuoBi.gameObject:SetActive(true)
                    self.playersView[j].seat.name.gameObject:SetActive(false)
                    self.playersView[j].seat.score.gameObject:SetActive(false)
                    
                elseif self.playersView[j] and self.playersView[j].seatIndex == 1 then
                    self.playersView[j].seat.FangZuoBi.gameObject:SetActive(false)
                    self.playersView[j].seat.name.gameObject:SetActive(true)
                end
            end
        end

        local function func2()
            for j = 1, 3 do
                self.playersView[j].seat.FangZuoBi.gameObject:SetActive(false)
                self.playersView[j].seat.name.gameObject:SetActive(true)
                self.playersView[j].seat.score.gameObject:SetActive(true)
            end
            self.view.ImageAnticheat.gameObject:SetActive(false)
            self.view.RightBtn.gameObject:SetActive(true)
            self.view.txtRoomID.gameObject:SetActive(true)
            self.view.buttonWarning.gameObject:SetActive(true)
        end

        self.fangzuobiCoroutine = self:start_lua_coroutine(function ()
            func1()
            while not DataPaoHuZi.Msg_Table_GameStateNTF do
                self.view.buttonWarning.gameObject:SetActive(false)
                coroutine.wait(0.1)
            end
            func2()
            self.fangzuobiCoroutine = nil
        end)

        self.Msg_Table_GameStateNTFFunc = function ()
            if not DataPaoHuZi.Msg_Table_GameStateNTF then
                func1()
            else
                if DataPaoHuZi.Msg_Table_GameStateNTF.result == 0 then
                    func2()
                else
                    func1()
                end
            end
        end
    end
end


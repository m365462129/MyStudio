-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local View = require('core.mvvm.view_base')
-- ==========================================================================

local JoinRoomView = Class('joinRoomView', View)

local ModuleCache = ModuleCache

local ComponentTypeName = ModuleCache.ComponentTypeName
local GetComponent = ModuleCache.ComponentManager.GetComponent

function JoinRoomView:initialize(...)
    -- 初始View
    View.initialize(self, "henanmj/module/joinroom/henanmj_windowjoinroom.prefab", "HeNanMJ_WindowJoinRoom", 1)

    local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
    self.buttonClose = GetComponentWithPath(self.root, "closeBtn", ComponentTypeName.Button)
    self.roomNumTextArray = {}
    for i=1,6 do
        self.roomNumTextArray[i] = GetComponentWithPath(self.root, "Center/RoomNumInputPanel/RoomNum/InputedNums/text" .. i, ComponentTypeName.Text)
    end

    self.keyboardMap = {}
    for i=0,10 do
        self.keyboardMap[i] = GetComponentWithPath(self.root, "Center/RoomNumInputPanel/KeyBoard/Keys/Key" .. i, ComponentTypeName.Button)
    end
    self.keyboardMap.buttonClean = GetComponentWithPath(self.root, "Center/RoomNumInputPanel/KeyBoard/Keys/Key*", ComponentTypeName.Button)
    self.keyboardMap.buttonDelete = GetComponentWithPath(self.root, "Center/RoomNumInputPanel/KeyBoard/Keys/Key#", ComponentTypeName.Button)
    self.goldTextNum = GetComponentWithPath(self.root, "Center/RoomNumInputPanel/RoomNum/TextNum", ComponentTypeName.Text)
    self.stateSwitcher = ModuleCache.ComponentManager.GetComponent(self.root, "UIStateSwitcher")

    self.museumToggles= {}
    self.museumToggles[1] = GetComponentWithPath(self.root, "Title_museum/1", ComponentTypeName.Toggle)
    self.museumToggles[2] = GetComponentWithPath(self.root, "Title_museum/2", ComponentTypeName.Toggle)

    self.nameInput = GetComponentWithPath(self.root,"Center/CreateMuseumPanel/name/InputField",ComponentTypeName.InputField)
    self.idInput = GetComponentWithPath(self.root,"Center/CreateMuseumPanel/id/InputField",ComponentTypeName.InputField)
    self.wxNumInput = GetComponentWithPath(self.root,"Center/CreateMuseumPanel/wxNum/InputField",ComponentTypeName.InputField)
end

function JoinRoomView:on_view_init()

end

function JoinRoomView:refreshPlayMode()
    local GetComponentWithPath = ModuleCache.ComponentManager.GetComponentWithPath
    local playMode = ModuleCache.PlayModeUtil.getInfoByIdAndLocation(ModuleCache.GameManager.curGameId,ModuleCache.GameManager.curLocation)

    holder  = GetComponentWithPath(self.root, "closeBtn", "SpriteHolder")
    local imageCloseBtnBg = GetComponent(holder.gameObject, ComponentTypeName.Image)
    self:SetImageSpriteByGameId(imageCloseBtnBg,holder,playMode.color)
end

function JoinRoomView:refreshRoomNumText(strRoomNum)    
    local len = #strRoomNum    
    for i=1, #self.roomNumTextArray do                
        if(i <= len) then
	        local strNum = string.sub(strRoomNum,i,i)            
            self.roomNumTextArray[i].text = strNum
            self.roomNumTextArray[i].gameObject:SetActive(true)
        else
            self.roomNumTextArray[i].gameObject:SetActive(false)
        end        
    end
end

function JoinRoomView:refreshGoldNumText(strNum)
    self.goldTextNum.text = strNum
end


return JoinRoomView
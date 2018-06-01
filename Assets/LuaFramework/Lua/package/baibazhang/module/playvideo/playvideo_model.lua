-- ========================== 默认依赖 =======================================
local Class = require("lib.middleclass")
local Model = require("core.mvvm.model_base")
-- ==========================================================================

-- 
local PlayVideoModel = Class("playVideoModel", Model)

function PlayVideoModel:initialize(...)
    self.adContent = nil        --广告语的数据
    Model.initialize(self, ...)    
end

function PlayVideoModel:request_get_adcontent()

end 

function  PlayVideoModel:request_bind_invitecode(inviteCode)
    
end


return PlayVideoModel
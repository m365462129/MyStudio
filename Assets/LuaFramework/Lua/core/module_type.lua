--===============================================================================================--
--data: 2016.11
--author: dred
--desc: 模块的注册类，映射模块之间的关系   约定大于配置。  本意是希望支持智能提示，暂时没用到
--===============================================================================================--


local ModuleType = {

    bullfight = {

    },

    runfast = {

    }
}

ModuleType.Hall = {
    Hall = {
        "hall_module", "hall_view", "hall_model"
    },
    Login = { "login_module", "long_view" }
}


return ModuleType
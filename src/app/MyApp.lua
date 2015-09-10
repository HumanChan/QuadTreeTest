
require("config")
require("cocos.init")
require("framework.init")

require("app.const.GlobalConst")

local MyApp = class("MyApp", cc.mvc.AppBase)

function MyApp:ctor()
    MyApp.super.ctor(self)
end

function MyApp:run()
	self:newRandomSeed()
	display.addSpriteFrames("bullets.plist", "bullets.png")
    self:enterScene("MainScene")
end

--添加随机数种子
function MyApp:newRandomSeed()
    local socket = require("socket") 
    local function get_seed()  
        local t = string.format("%f", socket.gettime())  
        local st = string.sub(t, string.find(t, "%.") + 1, -1)   
        return tonumber(string.reverse(st))  
    end  
    math.randomseed(get_seed()) 
end

return MyApp

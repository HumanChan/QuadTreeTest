
local BaseObj = class("BaseObj",function()
    return display.newNode()
end)

function BaseObj:ctor()
	self.info = {}
	self.info.lastIndex = 0
	self.info.nowIndex = 0
end

function BaseObj:getInfo()
	return self.info
end

function BaseObj:getRect()
	return cc.rect(0,0,0,0)
end

return BaseObj
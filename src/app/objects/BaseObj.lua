
local BaseObj = class("BaseObj",function()
    return display.newNode()
end)

function BaseObj:ctor()
	self.info = {}
	self.info.node = nil  --所在四叉树节点
	self.info.lastIndex = 0  --上一帧所在节点的象限
	self.info.nowIndex = 0  --当前帧所在节点的象限
end

function BaseObj:getInfo()
	return self.info
end

function BaseObj:getRect()
	return cc.rect(0,0,0,0)
end

function BaseObj:setNode(node)
	self.info.node = node
end

return BaseObj
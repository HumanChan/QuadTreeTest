
local BulletObj = class("BulletObj",require("app.objects.BaseObj"))


function BulletObj:ctor(key)
	BulletObj.super.ctor(self,"BulletObj")
	self.key = key
    local n = math.random(1,4)
    self.efNode = display.newNode():addTo(self)
	self.facade = display.newSprite("#b"..n..".png"):addTo(self)
	self:setBox()
	self:setMoveData()


	self.rect = display.newRect(cc.rect(0-self.cw, 0-self.ch, self.w, self.h),
        {fillColor = cc.c4f(1,0,0,1), borderColor = cc.c4f(0,1,0,1), borderWidth = 1})
	self.efNode:addChild(self.rect)
	self.rect:setVisible(false)
end

function BulletObj:setMoveData()
	local k = {-1,1}
	local rx = math.random(0,display.width)
	local ry = math.random(BOTTOM_HEIGHT,display.height)
	self.spx = math.random(150,500) * k[math.random(1,2)]
	self.spy = math.random(150,500) * k[math.random(1,2)]
	self:setRotation(-math.deg(cc.pToAngleSelf(cc.p(self.spx,self.spy))))
	self:setPosition(rx,ry)
end

function BulletObj:setBox()
	self.box = self.facade:getBoundingBox()
	self.w = self.box.width
	self.h = self.box.height
	self.cw = self.w*0.5
	self.ch = self.h*0.5
end

function BulletObj:getRect()
	local x,y = self:getPosition()
	return cc.rect(x-self.cw,y-self.ch,self.w,self.h)
end

function BulletObj:setTouch(callback)
    if callback then
        self.callback = callback
        self:setTouchEnabled(true)
        self:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self,self.onTouch))
    end
end

function BulletObj:onTouch(touch, event)
    if self.callback then
        self.callback(self)
    end
end

function BulletObj:setRectVisible(isVisible)
	self.rect:setVisible(isVisible)
end

function BulletObj:update(dt)
	local px,py = self:getPosition()
	px = px + self.spx*dt
	py = py + self.spy*dt
	self:setPosition(px,py)
	if px < 0 or px > display.width or py < BOTTOM_HEIGHT or py > display.height then
		self:setMoveData()
	end
end

return BulletObj
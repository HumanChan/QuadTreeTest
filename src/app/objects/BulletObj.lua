
local BulletObj = class("BulletObj",require("app.objects.BaseObj"))


function BulletObj:ctor(key)
	BulletObj.super.ctor(self,"BulletObj")
	self.key = key
    local n = math.random(1,4)
	self.facade = display.newSprite("#b"..n..".png"):addTo(self)
	self:setBox()
	self:setMoveData()
end

function BulletObj:setMoveData()
	local k = {-1,1}
	local rx = math.random(0,display.width)
	local ry = math.random(0,display.height)
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

function BulletObj:update(dt)
	local px,py = self:getPosition()
	px = px + self.spx*dt
	py = py + self.spy*dt
	self:setPosition(px,py)
	if px < 0 or px > display.width or py < 0 or py > display.height then
		self:setMoveData()
	end
end

return BulletObj
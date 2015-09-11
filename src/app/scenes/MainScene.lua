
local scheduler = require("framework.scheduler")
local Quadtree = require("app.utils.Quadtree")
local BulletObj = require("app.objects.BulletObj")

local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
    self.bulletList = {}

    for i=1,30 do
        local bullet = BulletObj.new(i)
        self:addChild(bullet)
        table.insert(self.bulletList,bullet)
    end

    self.checkFlag = 1  --1|普通N^2碰撞检测  2|四叉树碰撞检测
    if self.checkFlag ~= 1 then
        self.quad = Quadtree.create(1,cc.rect(0,0,display.width,display.height))
        for i=1,#self.bulletList do
            local b = self.bulletList[i]
            self.quad:insertObj(b)
        end
    end
end

function MainScene:update(dt)
    for i=1,#self.bulletList do
        local b1 = self.bulletList[i]
        b1:update(dt)
        if self.checkFlag == 1 then
            self:normalUpdate(b1,dt)
        else
            self:quadTreeUpdate(b1,dt)
        end
    end
end

function MainScene:normalUpdate(b1,dt)
    -- local t = os.clock()
    for j=1,#self.bulletList do
        local b2 = self.bulletList[j]
        if b1.key ~= b2.key then --碰撞检测
            if cc.rectIntersectsRect(b1:getRect(),b2:getRect()) then
                print("子弹"..b1.key.." 撞击了 子弹"..b2.key)
        end
        end
    end
    -- print(os.clock()-t)
end

function MainScene:refreshQuad()
    -- self.quad:clear()
    -- for i=1,#self.bulletList do
    --     local b = self.bulletList[i]
    --     self.quad:insertObj(b)
    -- end
    self.quad:refresh(self.quad)
end

function MainScene:quadTreeUpdate(b1,dt)
    local t = os.clock()
    self:refreshQuad()
    local checkList = {}
    self.quad:retrive(b1,checkList)
    for i=1,#checkList do
        local b2 = checkList[i]
        if b1.key ~= b2.key then --碰撞检测
            if cc.rectIntersectsRect(b1:getRect(),b2:getRect()) then
                print("子弹"..b1.key.." 撞击了 子弹"..b2.key)
        end
        end
    end
    -- print(os.clock()-t)
end

function MainScene:onEnter()
    self.gameScheduler = scheduler.scheduleUpdateGlobal(function(dt)
        self:update(dt)
    end)
end

function MainScene:onExit()
    scheduler.unscheduleGlobal(self.gameScheduler)
end

return MainScene

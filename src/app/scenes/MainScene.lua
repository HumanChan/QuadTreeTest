
local scheduler = require("framework.scheduler")
local Quadtree = require("app.utils.Quadtree")
local BulletObj = require("app.objects.BulletObj")
local SimpleButton = require("app.component.SimpleButton")

local CHECK_TYPE = {"不检测碰撞","普通N^2检测","四叉树检测"}
local GRID_FLAG = {"打开格子","关闭格子"}
local BOX_FLAG = {"开包围盒","关包围盒"}

local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
    self.checkFlag = 0  --1|普通N^2碰撞检测  2|四叉树碰撞检测  0|不检测
    self.showGrid = 0
    self.pow = 1
    self.boxFlag = 0
    self.updateFlag = true

    self.bulletList = {}
    for i=1,10 do
        local bullet = BulletObj.new(i)
        self:addChild(bullet)
        local callback = function(bullet)
            print("bulletID : "..bullet.key)
            local info = bullet:getInfo()
            local pathList = {}
            info.node:getPath(pathList)
            for i=1,#pathList do
                print(pathList[i])
            end
        end
        bullet:setTouch(callback)
        table.insert(self.bulletList,bullet)
    end
    --创建按钮
    self:createMenu()
end

function MainScene:update(dt)
    for i=1,#self.bulletList do
        local b1 = self.bulletList[i]
        b1:update(dt)
        if self.checkFlag == 1 then
            self:normalUpdate(b1,dt)
        elseif self.checkFlag == 2 then
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
                b1:setMoveData()
                b2:setMoveData()
                return
            end
        end
    end
    -- print(os.clock()-t)
end

function MainScene:resetQuad()
    self.quad = Quadtree.create(1,cc.rect(0,0,display.width,display.height))
    self.quad:split()
    for i=1,#self.bulletList do
        local b = self.bulletList[i]
        self.quad:insertObj(b)
    end
>>>>>>> 6013af22915442043cdd15c967484751e203cd7b
end

function MainScene:refreshQuad()
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
                b1:setMoveData()
                b2:setMoveData()
                return
            end
        end
    end
    -- print(os.clock()-t)
end

function MainScene:createMenu()
    self.checkLab = display.newTTFLabel({
                        text = CHECK_TYPE[self.checkFlag+1],
                        font = "arial",
                        size = fontSize,
                        color = cc.c3b(255, 255, 255),
                        align = cc.TEXT_ALIGNMENT_CENTER
                    }):addTo(self):pos(display.cx,display.height-50)    

    local btn1 = SimpleButton.new({
        width = 120,height = 40,
        des = "检测方式" , callback = handler(self,self.onChangeCheckFlag)
    }):addTo(self):pos(display.cx,50)

    self.btn2 = SimpleButton.new({
        width = 120,height = 40,
        des = GRID_FLAG[self.showGrid+1] , callback = handler(self,self.onChangeGridFlag)
    }):addTo(self):pos(display.cx+160,50)

    local btn3 = SimpleButton.new({
        width = 25,height = 25,
        des = "+" , callback = handler(self,self.addPow)
    }):addTo(self):pos(display.cx+260,70)

    local btn4 = SimpleButton.new({
        width = 25,height = 25,
        des = "-" , callback = handler(self,self.subPow)
    }):addTo(self):pos(display.cx+260,30)

    self.btn5 = SimpleButton.new({
        width = 120,height = 40,
        des = BOX_FLAG[self.boxFlag+1] , callback = handler(self,self.onChangeBoxFlag)
    }):addTo(self):pos(display.cx-160,50)

    self.btn6 = SimpleButton.new({
        width = 40,height = 40,
        des = "关" , callback = handler(self,self.onChangeUpdateFlag)
    }):addTo(self):pos(display.cx-260,50)
end

function MainScene:onChangeUpdateFlag()
    if self.updateFlag == true then
        self.updateFlag = false
        self.btn6:changeDes("开")
    else
        self.updateFlag = true
        self.btn6:changeDes("关")
    end
end

function MainScene:onChangeCheckFlag()
    self.checkFlag = self.checkFlag + 1
    if self.checkFlag > 2 then 
        self.checkFlag = 0
    end
    if self.checkFlag == 2 then
        self:resetQuad()
    end
    self.checkLab:setString(CHECK_TYPE[self.checkFlag+1])
end

function MainScene:onChangeGridFlag()
    self.showGrid = self.showGrid + 1
    if self.showGrid > 1 then 
        self.showGrid = 0
    end
    self:drawGrid(self.showGrid,self.pow)
    self.btn2:changeDes(GRID_FLAG[self.showGrid+1])
end

function MainScene:onChangeBoxFlag()
    self.boxFlag = self.boxFlag + 1
    if self.boxFlag > 1 then 
        self.boxFlag = 0
    end
    local visible = false
    if self.boxFlag == 1 then
        visible = true
    end
    for i=1,#self.bulletList do
        local bullet = self.bulletList[i]
        bullet:setRectVisible(visible)
    end
    self.btn5:changeDes(BOX_FLAG[self.boxFlag+1])
end

function MainScene:addPow()
    self.pow = self.pow + 1
    if self.pow > 5 then self.pow = 5 end
    self:drawGrid(false)
    self:drawGrid(self.showGrid,self.pow)
end

function MainScene:subPow()
    self.pow = self.pow - 1
    if self.pow < 1 then self.pow = 1 end
    self:drawGrid(false)
    self:drawGrid(self.showGrid,self.pow)
end

function MainScene:drawGrid(showGrid,pow)
    if showGrid == 1 then
        if self.drawNode == nil then
            if pow and pow > 5 then pow = 5 end
            local pow_ = pow or 1
            --画线框
            local mapMaxW = display.width
            local mapMaxH = display.height
            local x = math.pow(2,pow_)
            local boxW = display.width/x
            local boxH = (display.height-BOTTOM_HEIGHT)/x
            self.drawNode = cc.DrawNode:create()
            self:addChild(self.drawNode, 10)
            local color = cc.c4f(255,1,1,1)

            for var=0, mapMaxW do
                self.drawNode:drawLine( cc.p(var*boxW, BOTTOM_HEIGHT), cc.p(var*boxW, mapMaxH), color)
            end
            for var=0, mapMaxH do
                self.drawNode:drawLine( cc.p(0, BOTTOM_HEIGHT+var*boxH), cc.p(mapMaxW, BOTTOM_HEIGHT+var*boxH), color)
            end
        end
    else
        if self.drawNode then
            self.drawNode:removeFromParent()
            self.drawNode = nil
        end
    end
end

function MainScene:onEnter()
    self.gameScheduler = scheduler.scheduleUpdateGlobal(function(dt)
        if self.updateFlag then
            self:update(dt)
        end
    end)
end

function MainScene:onExit()
    scheduler.unscheduleGlobal(self.gameScheduler)
end

return MainScene

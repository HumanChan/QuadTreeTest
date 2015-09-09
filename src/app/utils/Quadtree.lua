

local Quadtree = class("Quadtree",function()
    return {}
end)

function Quadtree:ctor()

end

function Quadtree.create(level,bounds,parent,index)
    local quadTree = Quadtree.new()

    quadTree.MAX_OBJECTS = 10
    quadTree.MAX_LEVELS = 6

    quadTree.level = level
    ------------------------
    quadTree.bounds = bounds
    quadTree.x = bounds.x
    quadTree.y = bounds.y
    quadTree.width = bounds.width
    quadTree.height = bounds.height
    quadTree.cw = bounds.width*0.5
    quadTree.ch = bounds.height*0.5
    quadTree.xMid = bounds.x + quadTree.cw
    quadTree.yMid = bounds.y + quadTree.ch
    ------------------------
    quadTree.objects = {}
    quadTree.nodes = {}
    quadTree.parent = parent
    quadTree.index = index or 0
    return quadTree
end


----------------
--节点分割
--4 1
--3 2
function Quadtree:split()
    local subWidth = self.cw
    local subHeight = self.ch
    local x = self.x
    local y = self.y

    local node1 = Quadtree.create(self.level+1,cc.rect(x+subWidth,y+subHeight,subWidth,subHeight),self,1)
    local node2 = Quadtree.create(self.level+1,cc.rect(x+subWidth,y,subWidth,subHeight),self,2)
    local node3 = Quadtree.create(self.level+1,cc.rect(x,y,subWidth,subHeight),self,3)
    local node4 = Quadtree.create(self.level+1,cc.rect(x,y+subHeight,subWidth,subHeight),self,4)

    table.insert(self.nodes,node1)
    table.insert(self.nodes,node2)
    table.insert(self.nodes,node3)
    table.insert(self.nodes,node4)
end

function Quadtree:getIndex(rect)
    local index = -1

    local xMid = self.x + self.cw
    local yMid = self.y + self.ch

    local topFlag = rect.y > yMid
    local bottomFlag = rect.y + rect.height < yMid

    if ( rect.x > xMid ) then
        if topFlag then
            index = 1
        elseif bottomFlag then
            index = 2
        end
    elseif ( rect.x + rect.width <xMid ) then
        if topFlag then
            index = 4
        elseif bottomFlag then
            index = 3
        end
    end

    return index
end

function Quadtree:insertObj(object)
    local rect = object:getRect()

    if self.nodes[1] ~= nil then
        local index = self:getIndex(rect)
        if index ~= -1 then
            self.nodes[index]:insertObj(object)
            return
        end
    end
    local on = table.nums(self.objects)+1
    self.objects[on..""] = object
    
    if on > self.MAX_OBJECTS and self.level < self.MAX_LEVELS then
        self:split()
        for key,obj in pairs(self.objects) do
            local index_ = self:getIndex(obj:getRect())
            if index_ ~= -1 then
                self.nodes[index_]:insertObj(obj)
                self.objects[key] = nil
            end
        end
    end
end

function Quadtree:retrive(object,rtList)
    local rect = object:getRect()
    local index = self:getIndex(rect)

    if index ~= -1 and self.nodes[1] ~= nil then
        self.nodes[index]:retrive(object,rtList)
    end
    for key,obj in pairs(self.objects) do
        table.insert(rtList,obj)
    end

    return rtList
end

function Quadtree:clear()
    self.objects = {}
    for i=1,#self.nodes do
        if self.nodes[i] ~= nil then
            self.nodes[i]:clear()
            self.nodes[i] = nil
        end
    end
end

function Quadtree:isInner(rect,bounds)
    return rect.x >= bounds.x and rect.x + rect.width <= bounds.width and
        rect.y >= bounds.y and rect.y + rect.height <= bounds.height
end

function Quadtree:refresh(root)
    for key,obj in pairs(self.objects) do
        local rect = obj:getRect()

        if self:isInner(rect,self.bounds) == false then
            if root then
                root:insertObj(obj)
                self.objects[key] = nil
            end
        else
            if self.nodes[1] then
                local index = self:getIndex(rect)
                if index ~= -1 then
                    self.nodes[index]:insertObj(obj)
                    self.objects[key] = nil
                end
            end
        end
    end

    for i=1,#self.nodes do
        self.nodes[i]:refresh(root)
    end

end


return Quadtree
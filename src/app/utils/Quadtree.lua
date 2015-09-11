

local Quadtree = class("Quadtree",function()
    return {}
end)

function Quadtree:ctor()
    self.MAX_OBJECTS = 10
    self.MAX_LEVELS = 5
end

function Quadtree.create(level,bounds,parent,index)
    local quadTree = Quadtree.new()

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
    local x = self.x
    local y = self.y

    local node1 = Quadtree.create(self.level+1,cc.rect(self.xMid,self.yMid,self.cw,self.ch),self,1)
    local node2 = Quadtree.create(self.level+1,cc.rect(self.xMid,y,self.cw,self.ch),self,2)
    local node3 = Quadtree.create(self.level+1,cc.rect(x,y,self.cw,self.ch),self,3)
    local node4 = Quadtree.create(self.level+1,cc.rect(x,self.yMid,self.cw,self.ch),self,4)

    table.insert(self.nodes,node1)
    table.insert(self.nodes,node2)
    table.insert(self.nodes,node3)
    table.insert(self.nodes,node4)
end

function Quadtree:getIndex(rect)
    local index = 1
    local left = rect.x <= self.xMid
    local top = rect.y >= self.yMid
    if left then
        if top then
            index = 4
        else
            index = 3
        end
    else
        if not top then
            index = 2
        end
    end
    return index
end

function Quadtree:getPath(rtList)
    local info = "{level:"..self.level.."|index:"..self.index.."}"
    table.insert(rtList,info)
    if self.parent then
        self.parent:getPath(rtList)
    end
end

function Quadtree:hasChild()
    return self.nodes[1] ~= nil
end

function Quadtree:insertObj(object)
    local rect = object:getRect()

    if self:hasChild() then
        local index = self:getIndex(rect)
        self.nodes[index]:insertObj(object)
        return
    end
    table.insert(self.objects,object)
    object:setNode(self)

    if #self.objects > self.MAX_OBJECTS and self.level < self.MAX_LEVELS then
        self:split()
        for i=1,#self.objects do
            local obj = self.objects[i]
            local index_ = self:getIndex(obj:getRect())
            self.nodes[index_]:insertObj(obj)
        end
        self.objects = {}
    end
end

function Quadtree:retrive(object,rtList)
    local rect = object:getRect()
    local index = self:getIndex(rect)

    if self:hasChild() then
        return self.nodes[index]:retrive(object,rtList)
    end
    for i=1,#self.objects do
        table.insert(rtList,self.objects[i])
    end
    return rtList
end

function Quadtree:clear()
    self.objects = {}
    for i=1,#self.nodes do
        self.nodes[i]:clear()
        self.nodes[i] = nil
    end
end

function Quadtree:isInner(rect)
    return rect.x >= self.x and rect.x <= self.x+self.width and
        rect.y >= self.y and rect.y <= self.y+self.height
end

function Quadtree:refresh(root)
    if self:hasChild() then
        for i=1,#self.nodes do
            self.nodes[i]:refresh(root)
        end
        return
    end

    local j = 0
    for i=1,#self.objects do
        j = j + 1
        local obj = self.objects[j]
        local rect = obj:getRect()
        if self:isInner(rect) == false then
            if root then
                table.remove(self.objects,j)
                j = j - 1
                root:insertObj(obj)
            end
        end
    end
end


return Quadtree
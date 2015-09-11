

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
    local index = -1

    local topFlag = rect.y > self.yMid
    local bottomFlag = rect.y + rect.height < self.yMid

    if ( rect.x > self.xMid ) then
        if topFlag then
            index = 1
        elseif bottomFlag then
            index = 2
        end
    elseif ( rect.x + rect.width < self.xMid ) then
        if topFlag then
            index = 4
        elseif bottomFlag then
            index = 3
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

function Quadtree:insertObj(object)
    local rect = object:getRect()

    if self.nodes[1] ~= nil then
        local index = self:getIndex(rect)
        if index ~= -1 then
            self.nodes[index]:insertObj(object)
            return
        end
    end
    table.insert(self.objects,object)
    object:setNode(self)

    if #self.objects > self.MAX_OBJECTS and self.level < self.MAX_LEVELS then
        self:split()
        local j = 0
        for i=1,#self.objects do
            j = j + 1
            local obj = self.objects[j]
            local index_ = self:getIndex(obj:getRect())
            if index_ ~= -1 then
                self.nodes[index_]:insertObj(obj)
                table.remove(self.objects,j)
                j = j - 1
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
    for i=1,#self.objects do
        table.insert(rtList,self.objects[i])
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
    local j = 0
    for i=1,#self.objects do
        j = j + 1
        local obj = self.objects[j]
        local rect = obj:getRect()
        if self:isInner(rect,self.bounds) == false then
            if root then
                root:insertObj(obj)
                table.remove(self.objects,j)
                j = j - 1
            end
        else
            if self.nodes[1] then
                local index = self:getIndex(rect)
                if index ~= -1 then
                    self.nodes[index]:insertObj(obj)
                    table.remove(self.objects,j)
                    j = j - 1
                end
            end
        end

    end

    for i=1,#self.nodes do
        self.nodes[i]:refresh(root)
    end

end


return Quadtree
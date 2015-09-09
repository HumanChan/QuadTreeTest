
------------------
--队列数据结构

local List = {}

function List.new()
	return {first=0, last=-1}
end

function List.pushFront(list,value)
	list.first = list.first - 1
	list[list.first] = value
end

function List.pushBack(list,value)
	list.last = list.last + 1
	list[list.last] = value
end


function List.popFront(list)
	local first=list.first
	if first > list.last then 
		error("List is empty!")
	end
	local value = list[first]
	list[first] = nil
	list.first = first + 1
	return value
end

function List.popBack(list)
	local last=list.last
	if last < list.first then 
		error("List is empty!")
	end
	local value = list[last]
	list[last] = nil
	list.last = last - 1
	return value
end

return List


local SimpleButton = class("SimpleButton",function()
	return display.newNode()
end)

-------------------
--params [table]
--params.width , params.height , params.des , params.fontSize , params.callback
function SimpleButton:ctor(params)
	local width = params.width or 100
	local height = params.height or 50
	local des = params.des or "Button"
	local fontSize = params.fontSize or 24
	self.callback = params.callback

	local rect = display.newRect(cc.rect(0, 0, width, height),
    	{fillColor = cc.c4f(1,1,1,1), borderColor = cc.c4f(1,1,1,1), borderWidth = 1})
	self:addChild(rect)

	self.label = display.newTTFLabel({
	    text = des,
	    font = "arial",
	    size = fontSize,
	    color = cc.c3b(0, 0, 0),
	    align = cc.TEXT_ALIGNMENT_CENTER
	}):addTo(self):pos(0.5*width,0.5*height)

	self:setAnchorPoint(cc.p(0.5,0.5))
	self:setContentSize(width,height)
    if self.callback then
        self:setTouchEnabled(true)
        self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
	        if event.name == "began" then
	        	self:setScale(1.1)
	            self:onTouch(event)
	        elseif event.name == "moved" then
	        elseif event.name == "ended" then
	        	self:setScale(1.0)
	        end
	        return true
	    end)
    end
end

function SimpleButton:onTouch(touch, event)
    self.callback(self)
end

function SimpleButton:changeDes(des)
	if des then
		self.label:setString(des)
	end
end

return SimpleButton
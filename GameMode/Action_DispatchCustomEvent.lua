local Action_DispatchCustomEvent = {}

--[[------------------------------------------派发自定义事件------------------------------------------------------]]--
local Action_DispatchCustomEvent = 
{
    CustomEvent = "";
}

function Action_DispatchCustomEvent:Execute()
    print("Action_DispatchCustomEvent:Execute");
    
    if self.CustomEvent ~= "" then
        LuaQuickFireEvent(self.CustomEvent, self);
    end
	
	return true;
end

return Action_DispatchCustomEvent
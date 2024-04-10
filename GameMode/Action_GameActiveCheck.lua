--[[------------------------------------------游戏激活检测------------------------------------------------------]]--

local Action_GameActiveCheck = 
{
	CustomEventName = "";
}

function Action_GameActiveCheck:Execute()
	print("Action_GameActiveCheck:Execute");

	self.bEnableActionTick = true;

	return true;
end

function Action_GameActiveCheck:Update(deltaTime)
	if BurstMode.PlayerNum > 0 then
		self.bEnableActionTick = false;

		print("Action_GameActiveCheck:Update SendEvent GameActive!"); 

		if self.CustomEventName ~= "" then
            LuaQuickFireEvent(self.CustomEventName, self);
        end
	end
end

return Action_GameActiveCheck

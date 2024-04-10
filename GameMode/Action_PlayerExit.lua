local Action_PlayerExit = {}

--[[------------------------------------------玩家离开------------------------------------------------------]]--

local Action_PlayerExit = 
{
	CustomEventName = "";
}

function Action_PlayerExit:Execute(ExitPlayer)
	print(string.format("Action_PlayerExit:Execute ExitPlayer[%s]", tostring(ExitPlayer and ExitPlayer.PlayerName)));

	if ExitPlayer == nil then return false end

	BurstMode.PlayerNum = BurstMode.PlayerNum - 1;

	if BurstMode.PlayerNum == 0 then
		print("Action_PlayerExit:Execute SendEvent GameEnd!"); 
		if self.CustomEventName ~= "" then
			LuaQuickFireEvent(self.CustomEventName, self);
		end
	end

	return true;
end

return Action_PlayerExit

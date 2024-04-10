--[[------------------------------------------进入小局结束阶段------------------------------------------------------]]--

local Action_EnterRoundFinishedState = {}

function Action_EnterRoundFinishedState:Execute()
	print("Action_EnterRoundFinishedState:Execute");
	
	BurstMode:SetCurrentRoundState(BurstMode.RoundStateType.FinishedState);

	return true;
end

return Action_EnterRoundFinishedState;
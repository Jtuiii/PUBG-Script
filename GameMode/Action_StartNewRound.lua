local Action_StartNewRound = {}

--[[------------------------------------------开始新的一轮------------------------------------------------------]]--

local Action_StartNewRound = 
{
	CustomEventName = "";
}

function Action_StartNewRound:Execute()
	print("Action_StartNewRound:Execute");

	BurstMode:SetCurrentRound(BurstMode.CurrentRound + 1);

	if self.CustomEventName ~= "" then
		LuaQuickFireEvent(self.CustomEventName, self);
	end

	UnrealNetwork.CallUnrealRPC_Multicast(UGCGameSystem.GameState ,"MulticastRPC_StartNewRound");

	return true
end

return Action_StartNewRound;

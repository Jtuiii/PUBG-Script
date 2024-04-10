local Action_RoundFightStateEnd = {}

local Action_RoundFightStateEnd = 
{
    CustomEventName = "";
}

--[[------------------------------------------进入小局战斗阶段------------------------------------------------------]]--

function Action_RoundFightStateEnd:Execute()
	print("Action_RoundFightStateEnd:Execute");
    BurstMode.CurrentRoundEndReason = BurstMode.RoundEndReasonType.Timeout;

    if self.CustomEventName ~= "" then
        LuaQuickFireEvent(self.CustomEventName, self);
    end

	return true;
end

return Action_RoundFightStateEnd;
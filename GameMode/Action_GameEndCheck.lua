local Action_GameEndCheck = {}

--[[------------------------------------------游戏结束检测------------------------------------------------------]]--
local Action_GameEndCheck = 
{
	CustomEventName_GameEnd = "";
	CustomEventName_StartNewRound = "";
}


function Action_GameEndCheck:Execute()
	print("Action_GameEndCheck:Execute");

	print(string.format( "Action_GameEndCheck:Execute CurrentRound[%d]", BurstMode.CurrentRound));

	local TopTeamScore = 0;
	
	for TeamID, TeamScore in pairs(BurstMode.TeamScoreData) do  
		if TeamScore > TopTeamScore then
			TopTeamScore =  TeamScore;
		end
	end

	if TopTeamScore < BurstMode.WinScore then
		print("Action_GameEndCheck:Execute SendEvent StartNewRound!"); 
		if self.CustomEventName_StartNewRound ~= "" then
			LuaQuickFireEvent(self.CustomEventName_StartNewRound, self);
		end
	else
		print("Action_GameEndCheck:Execute SendEvent GameEnd!"); 
		if self.CustomEventName_GameEnd ~= "" then
			LuaQuickFireEvent(self.CustomEventName_GameEnd, self);
		end
	end
	
	return true;
end



return Action_GameEndCheck
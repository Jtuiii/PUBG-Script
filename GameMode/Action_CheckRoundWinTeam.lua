--[[------------------------------------------检测小局胜利队伍------------------------------------------------------]]--

local Action_CheckRoundWinTeam = {}

function Action_CheckRoundWinTeam:Execute()
	print("Action_CheckRoundWinTeam:Execute");

	print(string.format( "Action_CheckRoundWinTeam.Execute CurrentRoundEndReason[%s]", BurstMode.CurrentRoundEndReason));

	local WinTeam = -1;

	--超时或者炸弹被拆除  警方胜
	if BurstMode.CurrentRoundEndReason == BurstMode.RoundEndReasonType.Timeout or BurstMode.CurrentRoundEndReason == BurstMode.RoundEndReasonType.BombRemoved then
		WinTeam = BurstMode.CampTeamIDTable.Police;
	--团灭 另一方获胜
	elseif BurstMode.CurrentRoundEndReason == BurstMode.RoundEndReasonType.CampAllDead then

		if BurstMode.AllDeadTeamID == BurstMode.CampTeamIDTable.Police then
			WinTeam = BurstMode.CampTeamIDTable.Terrorist;
		elseif BurstMode.AllDeadTeamID == BurstMode.CampTeamIDTable.Terrorist then
			WinTeam = BurstMode.CampTeamIDTable.Police;
		end

	--炸弹爆炸 贼方胜
	elseif BurstMode.CurrentRoundEndReason == BurstMode.RoundEndReasonType.BombExploded then
		WinTeam = BurstMode.CampTeamIDTable.Terrorist;
	end

	print(string.format( "Action_CheckRoundWinTeam.Execute WinTeam[%d]", WinTeam));

	BurstMode:AddTeamScore(WinTeam, 1);

	if UGCGameSystem.GameState ~= nil then
		UnrealNetwork.CallUnrealRPC_Multicast(UGCGameSystem.GameState ,"MulticastRPC_RoundEnd", WinTeam);
	else
		print("Error: Action_CheckRoundWinTeam:Execut GameState is nil!");
	end

	return true;
end

return Action_CheckRoundWinTeam;
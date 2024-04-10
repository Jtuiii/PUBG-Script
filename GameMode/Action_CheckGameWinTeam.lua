--[[------------------------------------------检测比赛胜利队伍------------------------------------------------------]]--
local Action_CheckGameWinTeam = {}


function Action_CheckGameWinTeam:Execute()
	print("Action_CheckGameWinTeam:Execute");
	local PoliceScore = BurstMode.TeamScoreData[BurstMode.CampTeamIDTable.Police];
	local TerroristScore = BurstMode.TeamScoreData[BurstMode.CampTeamIDTable.Terrorist];

	local WinTeam = -1;

	if PoliceScore > TerroristScore then
		WinTeam = BurstMode.CampTeamIDTable.Police;
	else
		WinTeam = BurstMode.CampTeamIDTable.Terrorist;
	end

	UnrealNetwork.CallUnrealRPC_Multicast(UGCGameSystem.GameState ,"MulticastRPC_GameEnd", WinTeam);

	self:SendBattleResult();

	return true;
end


function Action_CheckGameWinTeam:SendBattleResult()

	print("Action_CheckGameWinTeam:SendBattleResult");

	local TeamModeComponentClass = ScriptGameplayStatics.FindClass("TeamModeComponent");

	print("Action_CheckGameWinTeam:SendBattleResult  Test01");

	local TeamModeComponent = ScriptGameplayStatics.FindComponent(UGCGameSystem.GameMode, TeamModeComponentClass);

	print("Action_CheckGameWinTeam:SendBattleResult  Test02");

	if TeamModeComponent == nil then
		print("Error: Action_CheckGameWinTeam:Execute TeamModeComponent is nil!");
		return false;
	end

	local PlayerStringKeys = {};

	print("Action_CheckGameWinTeam:SendBattleResult  Test03");

	local TeamIDs = totable(TeamModeComponent:GetTeamIDs());

	print("Action_CheckGameWinTeam:SendBattleResult  Test04");

	print(string.format("Action_CheckGameWinTeam:Execute #TeamIDs[%d]", #TeamIDs));

	for _, TeamID in ipairs(TeamIDs) do
		local TeamPlayerKeys = totable(TeamModeComponent:GetTeamPlayerKeys(TeamID));
		
		print(string.format("Action_CheckGameWinTeam:Execute TeamID[%d], #TeamPlayerKeys[%d]", TeamID, #TeamPlayerKeys));

		for _, TeamPlayerKey in ipairs(TeamPlayerKeys) do
			table.insert(PlayerStringKeys, TeamPlayerKey);
		end
	end

	print(string.format("Action_CheckGameWinTeam:Execute #PlayerStringKeys[%d]", #PlayerStringKeys));

	for i, Key in ipairs(PlayerStringKeys) do
		print(string.format("Action_CheckGameWinTeam:Execute call SendPlayerBattleResults[%d]", Key));
		UGCGameSystem.SendPlayerSettlement(Key);
	end

	--UGCBlueprintFunctionLibrary.SendPlayerBattleResults(PlayerKeys);
end

return Action_CheckGameWinTeam

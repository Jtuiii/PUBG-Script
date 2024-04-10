local Action_TeamAllDeadCheck = {}

--[[------------------------------------------团灭检测------------------------------------------------------]]--

local Action_TeamAllDeadCheck = 
{
	CustomEventName = "";
	StateChangeEventName = "";
}

function Action_TeamAllDeadCheck:Execute(VictimKey, KillerKey)
	--[[local args = {...};

	log_tree("Action_TeamAllDeadCheck:Execute :", args);

	local VictimerKey = args[3];
	local KillerKey = args[4];]]
	
	print(string.format( "Action_TeamAllDeadCheck:Execute VictimKey[%u], KillerKey[%u]", VictimKey, KillerKey));

	local VictimState = UGCGameSystem.GameMode:FindPlayerStateWithPlayerKey(VictimKey, "Normal");

	if VictimState == nil then
		print("Action_TeamAllDeadCheck VictimState is nil!");
		return false;
	end

	local TeamModeComponentClass = ScriptGameplayStatics.FindClass("TeamModeComponent");

	local TeamModeComponent = ScriptGameplayStatics.FindComponent(UGCGameSystem.GameMode, TeamModeComponentClass);

	if TeamModeComponent == nil then
		print("Error: Action_TeamAllDeadCheck:Execute TeamModeComponent is nil!");
		return false;
	end

	local TeamPlayerKeys = totable(TeamModeComponent:GetTeamPlayerKeys(VictimState.TeamID));

	local IsTeammateAllDead = true;

	for i, TeamPlayerKey in ipairs(TeamPlayerKeys) do
		local TeamPlayerState = UGCGameSystem.GameMode:FindPlayerStateWithPlayerKey(TeamPlayerKey, "Normal");

		if TeamPlayerState ~= nil then
			if TeamPlayerState:IsAlive() then
				IsTeammateAllDead = false;
				break;
			end
		else
			print(string.format( "Error: Action_TeamAllDeadCheck:Execute TeamPlayerState[%u] is nil!", TeamPlayerKey));
		end
	end

	if IsTeammateAllDead then
		print(string.format( "Action_TeamAllDeadCheck:Execute TeammateAllDead! TeamID[%d]", VictimState.TeamID));

		BurstMode.AllDeadTeamID = VictimState.TeamID;
		BurstMode.CurrentRoundEndReason = BurstMode.RoundEndReasonType.CampAllDead;
		if self.CustomEventName ~= "" then
			LuaQuickFireEvent(self.CustomEventName, self);
		end
		if self.StateChangeEventName ~= "" then
			LuaQuickFireEvent(self.StateChangeEventName, self);
		end
	end

	return true;
end

return Action_TeamAllDeadCheck
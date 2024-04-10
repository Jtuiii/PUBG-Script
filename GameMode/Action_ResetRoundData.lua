--[[------------------------------------------重置对局数据------------------------------------------------------]]--

local Action_ResetRoundData = {}

function Action_ResetRoundData:Execute()
	print("Action_ResetRoundData:Execute");

	if BurstMode.BombItem then
		BurstMode.BombItem:K2_DestroyActor();
		BurstMode.BombItem = nil;
	end
	
	BurstMode.CurrentRoundEndReason = BurstMode.RoundEndReasonType.None;
	BurstMode.AllDeadTeamID = -1;

	BurstMode.CurrentRoundState = BurstMode.RoundStateType.None;

	if UGCGameSystem.GameState then
		UGCGameSystem.GameState.CurrentRoundState = BurstMode.CurrentRoundState;
		UGCGameSystem.GameState.ReadyStateRemainTime = nil;
		UGCGameSystem.GameState.FightingStateRemainTime = BurstMode.FightingStateTime;
	end

	local PlayerTombBoxClass = ScriptGameplayStatics.FindClass("PlayerTombBox");

	local PlayerTombBoxs = totable(ScriptGameplayStatics.GetActorsOfClass(self, PlayerTombBoxClass));

	--清空死亡盒子
	for i, PlayerTombBox in ipairs(PlayerTombBoxs) do  
		if PlayerTombBox ~= nil then
			PlayerTombBox:K2_DestroyActor();
		end
	end

	return true
end


return Action_ResetRoundData

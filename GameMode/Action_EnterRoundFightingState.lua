local Action_EnterRoundFightingState = {}

--[[------------------------------------------进入小局战斗阶段------------------------------------------------------]]--

function Action_EnterRoundFightingState:Execute()
	print("Action_EnterRoundFightingState:Execute");
	
	BurstMode:SetCurrentRoundState(BurstMode.RoundStateType.FightingState);
	local PlayerControllers = totable(ScriptGameplayStatics.GetPlayerControllers(self));
	--所有玩家进入战斗状态
	for i, PlayerController in ipairs(PlayerControllers) do
		PlayerController:Fight();
	end

	local AIControllers = totable(STExtraGameplayStatics.GetFakePlayerAIControllers(self));
	--所有AI接触冻结状态
	for i, AIController in ipairs(AIControllers) do	
		print(string.format("Action_EnterRoundFightingState:Execute   call ResumeBehaviorTree Playerkey[%d]", AIController.PlayerKey))
		UGCBlueprintFunctionLibrary.ResumeBehaviorTree(AIController)
	end


	--self.EnterStateTime = GameplayStatics.GetRealTimeSeconds(self);

	--self.bEnableActionTick = true;

	return true;
end

--[[function Action_EnterRoundFightingState:Update(deltaTime)
	if BurstMode.CurrentRoundState ~= BurstMode.RoundStateType.FightingState  then
		self.bEnableActionTick = false;
		print(string.format("Error: Action_EnterRoundFightingState:Update  CurrentState[%s] != FightingState!", BurstMode.CurrentRoundState));
		return;
	end

	if BurstMode.BombItem ~= nil and BurstMode.BombItem.LocalParam.CurrentState == BombItemConfig.StateType.Installed then
		self.bEnableActionTick = false;
		print("Action_EnterRoundFightingState:Update BombState is Installed, StopTimer!"); 
		return;
	end

	local CurrentRealTime = GameplayStatics.GetRealTimeSeconds(self);
	local RemainTime = BurstMode.FightingStateTime - (CurrentRealTime - self.EnterStateTime);

	if UGCGameSystem.GameState ~= nil then
		UGCGameSystem.GameState.FightingStateRemainTime = math.ceil(RemainTime);
	end

	if RemainTime <= 0 then
		self.bEnableActionTick = false;

		BurstMode.CurrentRoundEndReason = BurstMode.RoundEndReasonType.Timeout;

		print("Action_EnterRoundFightingState:Update SendEvent EnterRoundFinishedState!"); 
		if self.CustomEventName ~= "" then
			LuaQuickFireEvent(self.CustomEventName, self);
		end
	end
end]]--

return Action_EnterRoundFightingState;
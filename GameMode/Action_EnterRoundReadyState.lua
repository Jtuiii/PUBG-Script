local Action_EnterRoundReadyState = {}

--[[------------------------------------------进入小局准备阶段------------------------------------------------------]]--

local Action_EnterRoundReadyState = 
{
	CustomEventName = "";
}

function Action_EnterRoundReadyState:Execute()
	print("Action_EnterRoundReadyState:Execute");

	-- BurstMode:SetCurrentRoundState(BurstMode.RoundStateType.ReadyState);

	-- self.EnterStateTime = GameplayStatics.GetRealTimeSeconds(self);

	-- self.bEnableActionTick = true;

	-- if UGCGameSystem.GameState ~= nil then
	-- 	UGCGameSystem.GameState.ReadyStateRemainTime = math.ceil(BurstMode.ReadyStateTime);
	-- end

	local AIControllers = totable(STExtraGameplayStatics.GetFakePlayerAIControllers(self));
	--所有AI进入冻结状态
	for i, AIController in ipairs(AIControllers) do
		print(string.format("Action_EnterRoundReadyState:Execute   call PauseBehaviorTree Playerkey[%d]", AIController.PlayerKey))
		UGCBlueprintFunctionLibrary.PauseBehaviorTree(AIController)
	end


	return true;
end

-- function Action_EnterRoundReadyState:Update(deltaTime)
-- 	if BurstMode.CurrentRoundState ~= BurstMode.RoundStateType.ReadyState then
-- 		self.bEnableActionTick = false;
-- 		print(string.format("Error: Action_EnterRoundReadyState:Update  CurrentState[%s] != ReadyState!", BurstMode.CurrentRoundState));
-- 		return;
-- 	end
-- 	local CurrentRealTime = GameplayStatics.GetRealTimeSeconds(self);
-- 	local RemainTime = BurstMode.ReadyStateTime - (CurrentRealTime - self.EnterStateTime);
	
-- 	if UGCGameSystem.GameState ~= nil then
-- 		UGCGameSystem.GameState.ReadyStateRemainTime = math.ceil(RemainTime);
-- 	end

-- 	if RemainTime <= 0 then
-- 		self.bEnableActionTick = false;
-- 		print("Action_EnterRoundReadyState:Update SendEvent EnterRoundFightingState");
-- 		if self.CustomEventName ~= "" then
--             LuaQuickFireEvent(self.CustomEventName, self);
--         end
-- 	end
-- end

return Action_EnterRoundReadyState;

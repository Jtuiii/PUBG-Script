-- 爆破模式AI控制器
local BP_TestFakeAIC = {}

BP_TestFakeAIC.DataMemory = {}

function BP_TestFakeAIC:ReceiveBeginPlay()
    --print("BP_TestFakeAIC::ReceiveBeginPlay");
    self.PrimaryActorTick.bCanEverTick = true;
    self.DataMemory.TestCount = 1

	if self:HasAuthority() then
		UGCBlueprintFunctionLibrary.PauseBehaviorTree(self)
	end
end

function BP_TestFakeAIC:ReceiveEndPlay()
    --print("BP_TestFakeAIC::ReceiveEndPlay");
end

function BP_TestFakeAIC:ReceiveTick(DeltaSeconds)
    --print("BP_TestFakeAIC::ReceiveTick");
    -- TODO: 因为AI作为第一个贼出生不会生成炸弹，这里手动生成一下
    -- 这不是正式逻辑，后面需要修改
    if not BurstMode.BombItem and self.DataMemory.TestCount then
        self.DataMemory.TestCount = self.DataMemory.TestCount + 1 
        if self.DataMemory.TestCount == 2 then
            self.DataMemory.TestCount = nil
            self:Execute()
        end
	end
	--local CurPawn = K2_GetPawn();
	--if CurPawn then
		--print("Pawn Loc " .. tostring(CurPawn:K2_GetActorLocation()));
	--end
end

function BP_TestFakeAIC:ReceiveAIPhaseChange(Phase)
	--print("BP_TestFakeAIC::ReceiveAIPhaseChange " .. tostring(Phase));
end

function BP_TestFakeAIC:ReceiveAttacked(InstigatorController, InstigatorPawn)
	print(string.format("BP_TestFakeAIC::ReceiveAttacked: %s %s", InstigatorController, InstigatorPawn));
end

function BP_TestFakeAIC:ModifyDamage(Damage, VictimActor, DamageCauser)
	-- local RetDamage = VictimActor.bIsAI and Damage * 0.5 or Damage * 0.3
	local RetDamage = Damage * 0.2
	print(string.format("BP_TestFakeAIC:ModifyDamage, Damage[%f], RetDamage[%f]", Damage, RetDamage))
	return RetDamage
end

function BP_TestFakeAIC:Execute()
	--print("Action_BombAllocation:Execute");

	local TeamModeComponentClass = ScriptGameplayStatics.FindClass("TeamModeComponent");

	local TeamModeComponent = ScriptGameplayStatics.FindComponent(UGCGameSystem.GameMode, TeamModeComponentClass);

	if TeamModeComponent == nil then
		--print("Error: Action_BombAllocation:Execute TeamModeComponent is nil!");
		return false;
	end

	local TerroristPlayerKeys = TeamModeComponent:GetTeamPlayerKeys(BurstMode.CampTeamIDTable.Terrorist);
	local PlayerKeysNum = TerroristPlayerKeys:Num()
	if PlayerKeysNum <= 0 then
		--print("Error: Action_BombAllocation:Execute #TerroristPlayerKeys <= 0!");
		return false;
	end
	
	local SelectedPlayerKey = TerroristPlayerKeys[math.random(PlayerKeysNum)];

	local SelectedCharacter = ScriptGameplayStatics.GetCharacterByPlayerKey(self, SelectedPlayerKey);

	if SelectedCharacter == nil then
		--print(string.format("Error: Action_BombAllocation:Execute SelectedCharacter is nil! SelectedPlayerKey[%u]", SelectedPlayerKey));
		return;
	end

	--print(string.format("Action_BombAllocation:Execute SelectedCharacter[%s]", SelectedCharacter.PlayerName));

	BurstMode:CreateBombItem();

	if BurstMode.BombItem == nil then
		--print("Error: Action_BombAllocation:Execute BurstMode.BombItem is null!");
		return false;
	end

	--临时代码，解决LUA参数复用BUG
	BurstMode.BombItem.LocalParam.CurrentState = BombItemConfig.StateType.None;

	BurstMode.BombItem:PickUp(SelectedCharacter);

	return true;
end

return BP_TestFakeAIC;

--[[------------------------------------------炸弹发放------------------------------------------------------]]--

local Action_BombAllocation = {}

function Action_BombAllocation:Execute()
	print("Action_BombAllocation:Execute");

	local TeamModeComponentClass = ScriptGameplayStatics.FindClass("TeamModeComponent");

	local TeamModeComponent = ScriptGameplayStatics.FindComponent(UGCGameSystem.GameMode, TeamModeComponentClass);

	if TeamModeComponent == nil then
		print("Error: Action_BombAllocation:Execute TeamModeComponent is nil!");
		return false;
	end

	local TerroristPlayerKeys = totable(TeamModeComponent:GetTeamPlayerKeys(BurstMode.CampTeamIDTable.Terrorist));

	local RealTerroristPlayerKeys = {};

	for _, PlayerKey in ipairs(TerroristPlayerKeys) do
		local PlayerState = UGCGameSystem.GameMode:FindPlayerStateWithPlayerKey(PlayerKey, "Normal");
		if PlayerState and PlayerState.bAIPlayer == false then
			table.insert(RealTerroristPlayerKeys, PlayerKey);
		end
	end

	if #RealTerroristPlayerKeys <= 0 then
		print("Error: Action_BombAllocation:Execute #RealTerroristPlayerKeys <= 0!");
		return false;
	end
	
	local SelectedPlayerKey = RealTerroristPlayerKeys[math.random(#RealTerroristPlayerKeys)];

	local SelectedCharacter = ScriptGameplayStatics.GetCharacterByPlayerKey(self, SelectedPlayerKey);

	if SelectedCharacter == nil then
		print(string.format("Error: Action_BombAllocation:Execute SelectedCharacter is nil! SelectedPlayerKey[%u]", SelectedPlayerKey));
		return;
	end

	print(string.format("Action_BombAllocation:Execute SelectedCharacter[%s]", SelectedCharacter.PlayerName));

	BurstMode:CreateBombItem();

	if BurstMode.BombItem == nil then
		print("Error: Action_BombAllocation:Execute BurstMode.BombItem is null!");
		return false;
	end

	--临时代码，解决LUA参数复用BUG
	BurstMode.BombItem.LocalParam.CurrentState = BombItemConfig.StateType.None;

	BurstMode.BombItem:PickUp(SelectedCharacter);

	return true;
end

return Action_BombAllocation;
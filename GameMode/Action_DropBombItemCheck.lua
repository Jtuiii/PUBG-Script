--[[------------------------------------------掉落炸弹检测------------------------------------------------------]]--

local Action_DropBombItemCheck = {}

function Action_DropBombItemCheck:Execute(...)
	local args = {...};

	log_tree("Action_DropBombItemCheck:Execute :", args);

	local VictimKey = args[1];
	local KillerKey = args[2];

	if BurstMode.BombItem == nil then 
		print("Error: Action_DropBombItemCheck:Execute BombItem is nil!");
		return false;
	end

	local BombOwnerPawn = BurstMode.BombItem.LocalParam.OwnerPawn;

	print(string.format("Action_DropBombItemCheck:Execute BombOwnerPawn[%s]", tostring(BombOwnerPawn and BombOwnerPawn.PlayerName)));

	if BombOwnerPawn ~= nil and  BombOwnerPawn.PlayerKey == VictimKey  then
		BurstMode.BombItem:Drop();
	end

	return true;
end

return Action_DropBombItemCheck

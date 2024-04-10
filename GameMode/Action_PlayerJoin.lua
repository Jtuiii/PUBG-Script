--[[------------------------------------------玩家加入------------------------------------------------------]]--

local Action_PlayerJoin = {}

function Action_PlayerJoin:Execute(NewPlayer)
	print(string.format("Action_PlayerJoin:Execute NewPlayer[%s]", tostring(NewPlayer and NewPlayer.PlayerName)));

	if NewPlayer == nil then return true end

	BurstMode.PlayerNum = BurstMode.PlayerNum + 1;

	return true;
end


return Action_PlayerJoin

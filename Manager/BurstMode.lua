--[[------------------------------------------爆破模式数据管理中心------------------------------------------------------]]--
BurstMode = BurstMode or {}

--[[------------------------------------------配置数据------------------------------------------------------]]--
--阶段类型
BurstMode.RoundStateType = 
{
	None          = "None",
	ReadyState    = "ReadyState",		--准备阶段
	FightingState = "FightingState",	--战斗阶段
	FinishedState = "FinishedState"		--结束阶段
};

--小局结束原因类型
BurstMode.RoundEndReasonType = 
{
    None 			= "None",
    Timeout 		= "Timeout",    	--超时
    CampAllDead 	= "CampAllDead",    --团灭
    BombExploded 	= "BombExploded",   --炸弹爆炸
    BombRemoved 	= "BombRemoved",    --炸弹移除
}

--阵营队伍ID表
BurstMode.CampTeamIDTable = 
{
	Police 		= 2,	--警
    Terrorist 	= 1,   	--贼
};

--获胜分数
BurstMode.WinScore = 2;

-- --准备阶段时间
-- BurstMode.ReadyStateTime = 15;
--战斗阶段时间
BurstMode.FightingStateTime = 300;

--炸弹Actor蓝图路径
BurstMode.BombActorClassPath = UGCMapInfoLib.GetRootLongPackagePath().. "Asset/Blueprint/BombItem.BombItem_C";

--[[------------------------------------------动态数据------------------------------------------------------]]--
--玩家数量
BurstMode.PlayerNum = 0;
--当前局数
BurstMode.CurrentRound = 0;
--当前阶段
BurstMode.CurrentRoundState = BurstMode.RoundStateType.None;

--小局结束原因
BurstMode.CurrentRoundEndReason = BurstMode.RoundEndReasonType.None;
--团灭队伍ID
BurstMode.AllDeadTeamID = -1;

--队伍分数
BurstMode.TeamScoreData = 
{
    [BurstMode.CampTeamIDTable.Police] 		= 0,
    [BurstMode.CampTeamIDTable.Terrorist] 	= 0,
};

--炸弹Actor对象
BurstMode.BombItem = nil;

--[[------------------------------------------方法------------------------------------------------------]]--
--设置当前轮数
function BurstMode:SetCurrentRound(CurrentRound)
	print(string.format("BurstMode:SetCurrentRound CurrentRound[%s]", CurrentRound));

	self.CurrentRound = CurrentRound;
	
	if UGCGameSystem.GameState ~= nil then
		UGCGameSystem.GameState.CurrentRound = CurrentRound;
	else
		print("Error: BurstMode:SetCurrentRoundState UGCGameSystem.GameState ~= nil!"); 
	end
end

--设置当前轮阶段
function BurstMode:SetCurrentRoundState(NewRoundState)
	print(string.format("BurstMode:SetCurrentRoundState LastRoundState[%s] NewRoundState[%s]", self.CurrentRoundState, NewRoundState));

	self.CurrentRoundState = NewRoundState;
	
	if UGCGameSystem.GameState ~= nil then
		UGCGameSystem.GameState.CurrentRoundState = NewRoundState;
	else
		print("Error: BurstMode:SetCurrentRoundState UGCGameSystem.GameState ~= nil!"); 
	end
end

--增加队伍分数
function BurstMode:AddTeamScore(TeamID, Score)
	print(string.format("BurstMode:AddTeamScore TeamID[%d], Score[%d]", TeamID, Score));

	self.TeamScoreData[TeamID] = self.TeamScoreData[TeamID] + 1;

	if UGCGameSystem.GameState ~= nil then
		UGCGameSystem.GameState.TeamScoreData[TeamID] = self.TeamScoreData[TeamID];
	else
		print("Error: BurstMode:AddTeamScore UGCGameSystem.GameState ~= nil!"); 
	end
end

--创建炸弹
function BurstMode:CreateBombItem()
	print("BurstMode:CreateBombItem");

	if self.BombItem ~= nil then
		print("Error: BurstMode:CreateBombItem BombItem ~= nil!"); 
		return self.BombItem;
	end

	print(string.format("BurstMode:CreateBombItem BombActorClassPath[%s]",self.BombActorClassPath)); 

	local BombItemClass = UE.LoadClass(self.BombActorClassPath);

	if BombItemClass == nil then
		print(string.format("Error: BurstMode:CreateBombItem BombItemClass is nil! BombActorClassPath[%s]",self.BombActorClassPath)); 
		return nil;
	end

	self.BombItem =  ScriptGameplayStatics.SpawnActor(UGCGameSystem.GameMode, BombItemClass, Vector.New(0, 0, 0), Rotator.New(0, 0, 0));

	print(string.format("BurstMode:CreateBombItem BombItem[%s]", tostring(self.BombItem))); 

	return self.BombItem;
end

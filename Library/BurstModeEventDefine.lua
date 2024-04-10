--爆破模式事件
BurstModeEventType = BurstModeEventType or {}; 

BurstModeEventType.CurrentStateChange = 1;                  --当前阶段 改变
BurstModeEventType.ReadyStateRemainTimeChange = 2;          --准备阶段剩余时间 改变
BurstModeEventType.FightingStateRemainTimeChange = 3;       --战斗阶段剩余时间 改变
BurstModeEventType.BombExplodeRemainTimeChange = 4;         --炸弹爆炸剩余时间 改变
BurstModeEventType.StartNewRound = 5;                       --开始新的一轮
BurstModeEventType.RoundEnd = 6;                            --本轮结束
BurstModeEventType.GameEnd = 7;                             --游戏结束
BurstModeEventType.BombInstalled = 8;                       --炸弹已安装
BurstModeEventType.BombRemoved = 9;                         --炸弹已移除
BurstModeEventType.BombExploded = 10;                       --炸弹已爆炸
BurstModeEventType.TeamScoreChange = 11;                    --队伍分数 改变


BurstModeEventType.PlayerIsBombOwnerChange = 101;           --玩家 是否炸弹携带者 改变
BurstModeEventType.PlayerIsInBombInstallAreaChange = 102;   --玩家 是否进入炸弹安装区 改变
BurstModeEventType.PlayerIsInBombRemoveAreaChange = 103;    --玩家 是否进入炸弹拆除区 改变
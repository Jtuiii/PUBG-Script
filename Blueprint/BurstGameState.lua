---@class BurstGameState_C:BP_UGCGameState_C
--Edit Below--
require("Script.Manager.BurstMode");
require("Script.Manager.UIManager");
require("Script.Library.UGCEventSystem");
require("Script.Library.BurstModeEventDefine");

--GameState
local BurstGameState = {}

BurstGameState.CurrentRound = BurstMode.CurrentRound;
BurstGameState.CurrentRoundState = BurstMode.CurrentRoundState;
BurstGameState.ReadyStateRemainTime = nil;
BurstGameState.FightingStateRemainTime = BurstMode.FightingStateTime;
BurstGameState.TeamScoreData = BurstMode.TeamScoreData;


function BurstGameState:GetReplicatedProperties()
    return 
    "CurrentRoundState",
    "ReadyStateRemainTime", 
    "FightingStateRemainTime",
    "TeamScoreData";
end


function BurstGameState:ReceiveBeginPlay()
    print("BurstGameState:ReceiveBeginPlay 111");
    
    if UGCGameSystem.GameState == nil then
        print("BurstGameState:ReceiveBeginPlay UGCGameSystem.GameState is nil");
        UGCGameSystem.GameState = self;
    end

    if UGCGameSystem.GameMode == nil then
        print("BurstGameState:ReceiveBeginPlay UGCGameSystem.GameMode is nil");
        UGCGameSystem.GameMode = GameplayStatics.GetGameMode(self);
    end

    require("Script.Manager.BurstMode");
    require("Script.Manager.UIManager");
    require("Script.Library.UGCEventSystem");
    require("Script.Library.BurstModeEventDefine");

    if UGCEventSystem == nil then
        print("BurstGameState:ReceiveBeginPlay UGCEventSystem is nil");
    end

    UGCEventSystem = UGCEventSystem;

    --屏蔽死亡盒子
    self.IsShowDeadBox = false;

    if self:HasAuthority() then 
    else
        --Client.EnterBattle(GameFrontendHUD, );
        GameFrontendHUD:SwitchGameStatus("Fighting", "");
        self:InitBurstModeUI();
    end
end

function BurstGameState:ReceiveEndPlay()
    print("BurstGameState:ReceiveEndPlay");

    UGCGameSystem.GameState = nil;

    BurstModeEventType = nil;
    UGCEventSystem = nil;

    BurstMode = nil;
    UIManager = nil;

    package.loaded["Script.Manager.BurstMode"] = nil;
    package.loaded["Script.Manager.UIManager"] = nil;
    package.loaded["Script.Library.UGCEventSystem"] = nil;
    package.loaded["Script.Library.BurstModeEventDefine"] = nil;
end

--[[
function BurstGameState:ReceiveTick(DeltaSeconds)
    if self:HasAuthority() then return end
    
end
]]

--属性同步OnRep

function BurstGameState:OnRep_CurrentRoundState()
    print(string.format( "BurstGameState:OnRep_CurrentRoundState[%s]", self.CurrentRoundState));

    BurstMode.CurrentRoundState = self.CurrentRoundState;

    UGCEventSystem:SendEvent(BurstModeEventType.CurrentStateChange, self.CurrentRoundState);
end

function BurstGameState:OnRep_ReadyStateRemainTime()
    print(string.format( "BurstGameState:OnRep_ReadyStateRemainTime[%s]", tostring(self.ReadyStateRemainTime)));

    if self.ReadyStateRemainTime == nil then return end;

    UGCEventSystem:SendEvent(BurstModeEventType.ReadyStateRemainTimeChange, self.ReadyStateRemainTime);
end

function BurstGameState:OnRep_FightingStateRemainTime()
    print(string.format( "BurstGameState:OnRep_FightingStateRemainTime[%d]", self.FightingStateRemainTime));

    UGCEventSystem:SendEvent(BurstModeEventType.FightingStateRemainTimeChange, self.FightingStateRemainTime);
end

function BurstGameState:OnRep_TeamScoreData()
    log_tree("BurstGameState:OnRep_TeamScoreData ", self.TeamScoreData);

    BurstMode.TeamScoreData = self.TeamScoreData;

    UGCEventSystem:SendEvent(BurstModeEventType.TeamScoreChange, self.TeamScoreData);
end


--流程控制 RPC
function BurstGameState:MulticastRPC_SendEvent(EventType, ...)
    print("BurstGameState:MulticastRPC_SendEvent");

    UGCEventSystem:SendEvent(EventType, ...);
end


--广播通知-开始新的一轮
function BurstGameState:MulticastRPC_StartNewRound()
    print("BurstGameState:MulticastRPC_StartNewRound");

    UGCEventSystem:SendEvent(BurstModeEventType.StartNewRound);
end

--广播通知-本轮结束
function BurstGameState:MulticastRPC_RoundEnd(RoundWinTeamID)
    print(string.format("BurstGameState:MulticastRPC_RoundEnd[%d]", RoundWinTeamID));

    UGCEventSystem:SendEvent(BurstModeEventType.RoundEnd, RoundWinTeamID);
end

--广播通知-游戏结束
function BurstGameState:MulticastRPC_GameEnd(WinTeamID)
    print(string.format("BurstGameState:MulticastRPC_GameEnd[%d]", WinTeamID));

    UGCEventSystem:SendEvent(BurstModeEventType.GameEnd, WinTeamID);
end

--初始化爆破模式UI
function BurstGameState:InitBurstModeUI()
    print("BurstGameState:InitBurstModeUI");

    local MainControlPanel = GameBusinessManager.GetWidgetFromName(ingame, "MainControlPanelTochButton_C");
    
    --隐藏部分不需要的UI
    if MainControlPanel ~= nil then
        local MainControlBaseUI = MainControlPanel.MainControlBaseUI;
        MainControlBaseUI.NavigatorPanel:SetVisibility(ESlateVisibility.Collapsed);
        MainControlBaseUI.CanvasPanelSurviveKill:SetVisibility(ESlateVisibility.Collapsed);
        MainControlBaseUI.SignalReceivingAreaTIPS_UIBP:SetVisibility(ESlateVisibility.Collapsed);
        MainControlBaseUI.CircleChasingProgress:SetVisibility(ESlateVisibility.Collapsed);
        MainControlBaseUI.SurviveInfoPanel:SetVisibility(ESlateVisibility.Collapsed);
    else
        print("Error: BurstGameState:InitBurstModeUI MainControlPanel == nil!");
    end

    local PlayerController = GameplayStatics.GetPlayerController(self, 0);

    if PlayerController == nil then
        print("Error: BurstGameState:InitBurstModeUI PlayerController == nil!");
        return false;
    end

    if UIManager.BurstModePanelWidget ~= nil then
        print("Error: BurstGameState:InitBurstModeUI UIManager.BurstModePanelWidget ~= nil!");
        return false;
    end

    UIManager.CreateBurstModePanelWidget(PlayerController);
end

return BurstGameState;
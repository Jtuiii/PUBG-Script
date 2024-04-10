---@class BurstModeMainUI_C:UserWidget
---@field NewAnimation_1 UWidgetAnimation
---@field BombExplodeCountDownBox UCanvasPanel
---@field Button_BackToLobby UButton
---@field Button_InstallBomb UButton
---@field Button_RemoveBomb UButton
---@field Image_5 UImage
---@field Image_6 UImage
---@field Image_Result UImage
---@field LosePanel UCanvasPanel
---@field Panel_BattleTips UCanvasPanel
---@field ReadyStateReamainTimePanel UCanvasPanel
---@field ResultPanel UCanvasPanel
---@field Text_BattleTipsContent UTextBlock
---@field Text_BattleTipsPlayerName UTextBlock
---@field Text_BlueTeamScore UTextBlock
---@field Text_FightingStateRemainTime UTextBlock
---@field Text_ReadyStateRemainTime UTextBlock
---@field Text_RedTeamScore UTextBlock
---@field WinPanel UCanvasPanel
--Edit Below--
--炸弹安装UI面板

local BurstModeMainUI = 
{
}

BurstModeMainUI.LocalParam = {};

function BurstModeMainUI:Construct()
    print("BurstModeMainUI:Construct");

    self:InitUI();
    self:InitBindEvent();
end

function BurstModeMainUI:Tick()
    if self.LocalParam.ShowBattleTipsRealTime ~= nil then
        local CurrentRealTime = GameplayStatics.GetRealTimeSeconds(self);
        if CurrentRealTime - self.LocalParam.ShowBattleTipsRealTime >= 3 then
            self:HideBattleTips();
            self.LocalParam.ShowBattleTipsRealTime = nil;
        end
    end
end


--初始化UI
function BurstModeMainUI:InitUI()
    print("BurstModeMainUI:InitUI");

    --self:SetCurrentRound(1);
    self:SetTeamScore(BurstMode.CampTeamIDTable.Police, 0);
    self:SetTeamScore(BurstMode.CampTeamIDTable.Terrorist, 0);

    self:NewRoundResetUI();
end

function BurstModeMainUI:InitBindEvent()
    print("BurstModeMainUI:InitBindEvent");

    --事件系统添加监听
    UGCEventSystem:AddListener(BurstModeEventType.ReadyStateRemainTimeChange, self.OnReadyStateRemainTimeChange, self);
    UGCEventSystem:AddListener(BurstModeEventType.FightingStateRemainTimeChange, self.OnFightingStateRemainTimeChange, self);
    UGCEventSystem:AddListener(BurstModeEventType.BombExplodeRemainTimeChange, self.OnBombExplodeRemainTimeChange, self);
    UGCEventSystem:AddListener(BurstModeEventType.StartNewRound, self.OnStartNewRound, self);
    UGCEventSystem:AddListener(BurstModeEventType.RoundEnd, self.OnRoundEnd, self);
    UGCEventSystem:AddListener(BurstModeEventType.GameEnd, self.OnGameEnd, self);
    UGCEventSystem:AddListener(BurstModeEventType.BombInstalled, self.OnBombInstalled, self);
    UGCEventSystem:AddListener(BurstModeEventType.BombRemoved, self.OnBombRemoved, self);
    UGCEventSystem:AddListener(BurstModeEventType.BombExploded, self.OnBombExploded, self);
    UGCEventSystem:AddListener(BurstModeEventType.TeamScoreChange, self.OnTeamScoreChange, self);
    UGCEventSystem:AddListener(BurstModeEventType.PlayerIsBombOwnerChange, self.OnPlayerIsBombOwnerChange, self);
    UGCEventSystem:AddListener(BurstModeEventType.PlayerIsInBombInstallAreaChange, self.OnPlayerIsInBombInstallAreaChange, self);
    UGCEventSystem:AddListener(BurstModeEventType.PlayerIsInBombRemoveAreaChange, self.OnPlayerIsInBombRemoveAreaChange, self);

    --控件事件绑定
    self.Button_InstallBomb.OnClicked:Add(self.Button_InstallBomb_OnClicked, self);
    self.Button_RemoveBomb.OnClicked:Add(self.Button_RemoveBomb_OnClicked, self);
    self.Button_BackToLobby.OnClicked:Add(self.Button_BackToLobby_OnClicked, self);

end

--新的一轮重置UI
function BurstModeMainUI:NewRoundResetUI()
    print("BurstModeMainUI:NewRoundResetUI");

    self.Button_InstallBomb:SetVisibility(ESlateVisibility.Collapsed);
    self.Button_RemoveBomb:SetVisibility(ESlateVisibility.Collapsed);
    self.ReadyStateReamainTimePanel:SetVisibility(ESlateVisibility.Collapsed);
    self.ResultPanel:SetVisibility(ESlateVisibility.Collapsed);
    self.BombExplodeCountDownBox:SetVisibility(ESlateVisibility.Collapsed);
    self.Panel_BattleTips:SetVisibility(ESlateVisibility.Collapsed);

    self.WinPanel:SetVisibility(ESlateVisibility.Collapsed);
    self.LosePanel:SetVisibility(ESlateVisibility.Collapsed);

    -- self:SetReadyStateRemainTime(BurstMode.ReadyStateTime);
    self:SetFightingStateRemainTime(BurstMode.FightingStateTime);
end


--安装炸弹按钮-按下
function BurstModeMainUI:Button_InstallBomb_OnClicked()
    print("BurstModeMainUI:Button_InstallBomb_OnClicked");

    local PlayerController = GameplayStatics.GetPlayerController(self, 0);

    if PlayerController == nil then
        print("BurstModeMainUI:Button_InstallBomb_OnClicked PlayerController is nil");
        return;
    end

    --请求安装炸弹
    UnrealNetwork.CallUnrealRPC(PlayerController, PlayerController, "ServerRPC_InstallBomb");
end

--移除炸弹按钮-按下
function BurstModeMainUI:Button_RemoveBomb_OnClicked()
    print("BurstModeMainUI:Button_RemoveBomb_OnClicked");

    local PlayerController = GameplayStatics.GetPlayerController(self, 0);

    if PlayerController == nil then
        print("BurstModeMainUI:Button_RemoveBomb_OnClicked PlayerController is nil");
        return;
    end

    --请求安装炸弹
    UnrealNetwork.CallUnrealRPC(PlayerController, PlayerController, "ServerRPC_RemoveBomb");
end

--返回大厅按钮-按下
function BurstModeMainUI:Button_BackToLobby_OnClicked()
    print("BurstModeMainUI:Button_BackToLobby_OnClicked");

    local PlayerController = GameplayStatics.GetPlayerController(self, 0);

    if PlayerController then
        PlayerController:ExitGame();
    else
        print("BurstModeMainUI:Button_BackToLobby_OnClicked PlayerController is nil");
    end

    LobbySystem.ReturnToLobby();
end


--设置准备阶段剩余时间
function BurstModeMainUI:SetReadyStateRemainTime(RemainTime)
    print(string.format("BurstModeMainUI:SetReadyStateRemainTime RemainTime[%d]", RemainTime));

    self.Text_ReadyStateRemainTime:SetText(string.format("%d", RemainTime));
end

--设置战斗阶段剩余时间
function BurstModeMainUI:SetFightingStateRemainTime(RemainTime)
    print(string.format("BurstModeMainUI:SetFightingStateRemainTime RemainTime[%d]", RemainTime));

    local Min = math.floor(RemainTime / 60);
    local Sec = RemainTime % 60;

    local RemainTimeString = string.format("%d%d:%d%d", math.floor(Min/10), Min%10, math.floor(Sec/10), Sec%10);

    print(string.format("BurstModeMainUI:SetFightingStateRemainTime RemainTimeString[%s]", RemainTimeString));

    self.Text_FightingStateRemainTime:SetText(RemainTimeString);
end

--设置队伍分数
function BurstModeMainUI:SetTeamScore(TeamID, Score)
    print(string.format("BurstModeMainUI:SetTeamScore TeamID[%d], Score[%d]", TeamID, Score));
    
    if TeamID == BurstMode.CampTeamIDTable.Police then
        self.Text_RedTeamScore:SetText(tostring(math.floor(Score)));
    elseif TeamID == BurstMode.CampTeamIDTable.Terrorist then
        self.Text_BlueTeamScore:SetText(tostring(math.floor(Score)));
    end
end

function BurstModeMainUI:ShowBattleTips(PlayerName, Content)
    print(string.format("BurstModeMainUI:ShowBattleTips PlayerName[%s], Content[%s]", PlayerName, Content));
    
    --[[if self.LocalParam.BattleTipsTimerDelegate ~= nil then
        KismetSystemLibrary.K2_ClearTimer(self, "HideBattleTips");
    end

    KismetSystemLibrary.K2_SetTimer(self, "HideBattleTips", 3, false);]]

    self.LocalParam.ShowBattleTipsRealTime = GameplayStatics.GetRealTimeSeconds(self);

    self.Panel_BattleTips:SetVisibility(ESlateVisibility.SelfHitTestInvisible);

    self.Text_BattleTipsPlayerName:SetText(tostring(PlayerName));
    self.Text_BattleTipsContent:SetText(tostring(Content));
end

function BurstModeMainUI:HideBattleTips()
    print("BurstModeMainUI:HideBattleTips");

    self.Panel_BattleTips:SetVisibility(ESlateVisibility.Collapsed);
end

--[[------------------------------------------事件通知------------------------------------------------------]]--

function BurstModeMainUI:OnReadyStateRemainTimeChange(ReadyStateRemainTime)
    print(string.format("BurstModeMainUI:OnReadyStateRemainTimeChange ReadyStateRemainTime[%d]", ReadyStateRemainTime));

    if ReadyStateRemainTime > 0 then
        self.ReadyStateReamainTimePanel:SetVisibility(ESlateVisibility.SelfHitTestInvisible);
    else
        self.ReadyStateReamainTimePanel:SetVisibility(ESlateVisibility.Collapsed);
	end

    self:SetReadyStateRemainTime(ReadyStateRemainTime);
end

function BurstModeMainUI:OnFightingStateRemainTimeChange(FightingStateRemainTime)
    print(string.format("BurstModeMainUI:OnFightingStateRemainTimeChange FightingStateRemainTime[%d]", FightingStateRemainTime));

    self:SetFightingStateRemainTime(FightingStateRemainTime);
end

function BurstModeMainUI:OnBombExplodeRemainTimeChange(ExplodeRemainTime)
    print(string.format("BurstModeMainUI:OnBombExplodeRemainTimeChange ExplodeRemainTime[%d]", ExplodeRemainTime));

    --爆炸倒计时特效
    if ExplodeRemainTime > 0 then
        self.BombExplodeCountDownBox:SetVisibility(ESlateVisibility.SelfHitTestInvisible);
    else
        self.BombExplodeCountDownBox:SetVisibility(ESlateVisibility.Collapsed);
	end

    self:SetFightingStateRemainTime(ExplodeRemainTime);
end


function BurstModeMainUI:OnStartNewRound()
    print("BurstModeMainUI:OnStartNewRound");

    self:NewRoundResetUI();
end

function BurstModeMainUI:OnRoundEnd(RoundWinTeamID)
    print(string.format("BurstModeMainUI:OnRoundEnd RoundWinTeamID[%d]", RoundWinTeamID));

    local PlayerController = GameplayStatics.GetPlayerController(self, 0);

    if PlayerController == nil then
        print("Error: BurstModeMainUI:OnRoundEnd PlayerController is nil!")
    end

    self.ResultPanel:SetVisibility(ESlateVisibility.SelfHitTestInvisible);

    if PlayerController.TeamID == RoundWinTeamID then
        FuncUtil.SetImageWithPath(self.Image_Result, UIManager.ImagePath_RoundWin);
    else
        FuncUtil.SetImageWithPath(self.Image_Result, UIManager.ImagePath_RoundFail);
    end
end

function BurstModeMainUI:OnGameEnd(WinTeamID)
    print(string.format("BurstModeMainUI:OnGameEnd WinTeamID[%d]", WinTeamID));

    local PlayerController = GameplayStatics.GetPlayerController(self, 0);

    if PlayerController == nil then
        print("Error: BurstModeMainUI:OnRoundEnd PlayerController is nil!")
    end

    local MainControlPanel = GameBusinessManager.GetWidgetFromName(ingame, "MainControlPanelTochButton_C");
    
    --隐藏部分不需要的UI
    if MainControlPanel ~= nil then
        MainControlPanel:UIMsg_HideAllUIAfterDeadTipsShow();
    else
        print("Error: BurstModeMainUI:OnGameEnd MainControlPanel == nil!");
    end

    self.Button_BackToLobby:SetVisibility(ESlateVisibility.Visible);
    self.ResultPanel:SetVisibility(ESlateVisibility.Collapsed);

    if PlayerController.TeamID == WinTeamID then
        print("BurstModeMainUI:OnGameEnd Win");
        self.WinPanel:SetVisibility(ESlateVisibility.SelfHitTestInvisible);
        self.LosePanel:SetVisibility(ESlateVisibility.Collapsed);
        --FuncUtil.SetImageWithPath(self.Image_Result, UIManager.ImagePath_GameWin);
    else
        print("BurstModeMainUI:OnGameEnd Lose");
        self.WinPanel:SetVisibility(ESlateVisibility.Collapsed);
        self.LosePanel:SetVisibility(ESlateVisibility.SelfHitTestInvisible);
        --FuncUtil.SetImageWithPath(self.Image_Result, UIManager.ImagePath_GameFail);
    end
end

function BurstModeMainUI:OnBombInstalled(InstallerPawn)
    print(string.format("BurstModeMainUI:OnBombInstalled InstallerPawn[%s]", tostring(InstallerPawn and InstallerPawn.PlayerName)));

    if InstallerPawn == nil then return end;

    self:ShowBattleTips(InstallerPawn.PlayerName, "设置炸弹");
    self.Button_InstallBomb:SetVisibility(ESlateVisibility.Collapsed);
end


function BurstModeMainUI:OnBombRemoved(RemoverPawn)
    print(string.format("BurstModeMainUI:OnBombRemoved RemoverPawn[%s]", tostring(RemoverPawn and RemoverPawn.PlayerName)));

    if RemoverPawn == nil then return end;

    self:ShowBattleTips(RemoverPawn.PlayerName, "拆除炸弹");
end

function BurstModeMainUI:OnBombExploded()
    print("BurstModeMainUI:OnBombExploded");

    self:ShowBattleTips("蓝队", "爆破成功");
end

function BurstModeMainUI:OnTeamScoreChange(TeamScoreData)
    log_tree("BurstModeMainUI:OnTeamScoreChange ", TeamScoreData);

    for TeamID, TeamScore in pairs(TeamScoreData) do  
		self:SetTeamScore(TeamID, TeamScore);
	end
end

function BurstModeMainUI:OnPlayerIsBombOwnerChange(PlayerPawn, IsBombOwner)
    print(string.format("BurstModeMainUI:OnPlayerIsBombOwnerChange PlayerPawn[%s], IsBombOwner[%s]", tostring(PlayerPawn and PlayerPawn.PlayerName), IsBombOwner));

    if PlayerPawn == nil then return end;

    if IsBombOwner then
        self:ShowBattleTips(PlayerPawn.PlayerName, "已获得炸弹！");
    end

    if PlayerPawn.IsBombOwner and PlayerPawn.IsInBombInstallArea then
        self.Button_InstallBomb:SetVisibility(ESlateVisibility.Visible);
    else
        self.Button_InstallBomb:SetVisibility(ESlateVisibility.Collapsed);
    end
end

function BurstModeMainUI:OnPlayerIsInBombInstallAreaChange(PlayerPawn, IsInBombInstallArea)
    print(string.format("BurstModeMainUI:OnPlayerIsInBombInstallAreaChange 111 PlayerPawn[%s], IsInBombInstallArea[%s]", tostring(PlayerPawn and PlayerPawn.PlayerName), IsInBombInstallArea));

    if PlayerPawn == nil then 
        print("BurstModeMainUI:OnPlayerIsInBombInstallAreaChange PlayerPawn is nil");
        return;
    else
        print("BurstModeMainUI:OnPlayerIsInBombInstallAreaChange PlayerPawn is not nil");
    end

    if PlayerPawn.IsBombOwner and PlayerPawn.IsInBombInstallArea then
        print("BurstModeMainUI:OnPlayerIsInBombInstallAreaChange set Visible");
        self.Button_InstallBomb:SetVisibility(ESlateVisibility.Visible);
    else
        print("BurstModeMainUI:OnPlayerIsInBombInstallAreaChange set Collapsed");
        self.Button_InstallBomb:SetVisibility(ESlateVisibility.Collapsed);
    end
end

function BurstModeMainUI:OnPlayerIsInBombRemoveAreaChange(PlayerPawn, IsInBombRemoveArea)
    print(string.format("BurstModeMainUI:OnPlayerIsInBombRemoveAreaChange PlayerPawn[%s], IsInBombRemoveArea[%s]", tostring(PlayerPawn and PlayerPawn.PlayerName), IsInBombRemoveArea));

    if PlayerPawn == nil then return end;

    if PlayerPawn.TeamID == BurstMode.CampTeamIDTable.Police and PlayerPawn.IsInBombRemoveArea then
        self.Button_RemoveBomb:SetVisibility(ESlateVisibility.Visible);
    else
        self.Button_RemoveBomb:SetVisibility(ESlateVisibility.Collapsed);
    end
end

return BurstModeMainUI;

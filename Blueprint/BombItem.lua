--背包道具-炸弹

--[[------------------------------------------炸弹配置数据------------------------------------------------------]]--
BombItemConfig = BombItemConfig or {};
BombItemConfig.StateType = 
{
    None =          "None",
    InBackPack =    "InBackPack",   --背包里（在玩家身上）
    Dropped =       "Dropped",      --已掉落
    Installed =     "Installed",    --已安装
    Removed =       "Removed",      --已移除
    Exploded =      "Exploded",     --已爆炸
}

--附加插槽
BombItemConfig.InBackPackStateSocketName = "MeleeWeapon";
BombItemConfig.InstallingStateSocketName = "WeaponSocket_1";

--炸弹动画蒙太奇路径
BombItemConfig.InstallingMontagePath = "/Game/Arts_Player/Characters/Animation/Shared_Anim/Healing_Boosting/Signal_Combat_Stand_Big_Montage.Signal_Combat_Stand_Big_Montage";
BombItemConfig.RemovingMontagePath = "/Game/Arts_Player/Characters/Animation/Shared_Anim/Healing_Boosting/Signal_Combat_Stand_Big_Montage.Signal_Combat_Stand_Big_Montage";

--安装所需时间
BombItemConfig.InstallTime = 3.0;
--拆除所需时间
BombItemConfig.RemoveTime = 3.0;
--爆炸所需时间
BombItemConfig.ExplodeTime = 60.0;

--[[------------------------------------------炸弹逻辑------------------------------------------------------]]--
local BombItem = {}

BombItem.LocalParam = {};

--当前状态
BombItem.LocalParam.CurrentState = BombItemConfig.StateType.None;
--携带者
BombItem.LocalParam.OwnerPawn = nil;
--安装者
BombItem.LocalParam.InstallerPawn = nil;
--拆除者
BombItem.LocalParam.RemoverPawn = nil;
--安装时间戳
BombItem.LocalParam.InstallTimestamp = nil;
--移除时间戳
BombItem.LocalParam.RemoveTimestamp = nil;
--引爆时间戳
BombItem.LocalParam.InstalledTimestamp = nil;
--爆炸剩余时间
BombItem.ExplodeRemainTime = nil;

--trigger事件
local BombEvent = {}
BombEvent.BombInstalledEvent = "BombInstalled";
BombEvent.BombRemovedEvent = "BombRemoved";
BombEvent.BombExplodedEvent = "BombExploded";

function BombItem:GetReplicatedProperties()
    return 
    "ExplodeRemainTime";
end

function BombItem:OnRep_ExplodeRemainTime()
    print(string.format("BombItem:OnRep_ExplodeRemainTime[%s]", tostring(self.ExplodeRemainTime)));

    if self.ExplodeRemainTime == nil then return end;

    UGCEventSystem:SendEvent(BurstModeEventType.BombExplodeRemainTimeChange, self.ExplodeRemainTime);
end

function BombItem:UserConstructionScript()
    print("BombItem:UserConstructionScript");

    self.PrimaryActorTick.bCanEverTick = true;
    self.bAllowBPReceiveTickEvent = true;

end

function BombItem:ReceiveBeginPlay()
    print("BombItem:ReceiveBeginPlay");

    if self:HasAuthority() then
        self.TriggerBox_Pickup:SetCollisionEnabled(ECollisionEnabled.NoCollision);
        self.TriggerBox_Remove:SetCollisionEnabled(ECollisionEnabled.NoCollision);
    
        self.TriggerBox_Pickup.OnComponentBeginOverlap:Add(self.OnPickUpBox_BeginOverlap, self);
        --self.TriggerBox_Pickup.OnComponentEndOverlap:Add(self.OnPickUpBox_BeginOverlap, self);
    
        self.TriggerBox_Remove.OnComponentBeginOverlap:Add(self.OnRemoveBox_BeginOverlap, self);
        self.TriggerBox_Remove.OnComponentEndOverlap:Add(self.OnRemoveBox_EndOverlap, self);
    end

    local ParticleSystemComponentClass = ScriptGameplayStatics.FindClass("ParticleSystemComponent");

    if ParticleSystemComponentClass then
        local InstalledEffect = self:GetComponentByClass(ParticleSystemComponentClass);
        if InstalledEffect then
            print(string.format("BombItem:ReceiveBeginPlay InstalledEffect[%s]", tostring(KismetSystemLibrary.GetObjectName(InstalledEffect))));
        else
            print("Error: BombItemScript:ReceiveBeginPlay InstalledEffect is nil!");
        end
    else
        print("Error: BombItemScript:ReceiveBeginPlay ParticleSystemComponentClass is nil!");
    end
end

function BombItem:ReceiveTick(DeltaSeconds)
    if self:HasAuthority() then
        --安装倒计时
        if self.LocalParam.CurrentState == BombItemConfig.StateType.InBackPack and self.LocalParam.InstallerPawn then
            local CurrentRealTime = GameplayStatics.GetRealTimeSeconds(self);
            local InstallRemainTime = BombItemConfig.InstallTime - (CurrentRealTime - self.LocalParam.InstallTimestamp);
    
            if InstallRemainTime <= 0 then
                self:Installed();
            end
        end
        
        --移除倒计时
        if self.LocalParam.CurrentState == BombItemConfig.StateType.Installed and self.LocalParam.RemoverPawn then
            local CurrentRealTime = GameplayStatics.GetRealTimeSeconds(self);
            local RemoveRemainTime = BombItemConfig.RemoveTime - (CurrentRealTime - self.LocalParam.RemoveTimestamp);
    
            if RemoveRemainTime <= 0 then
                self:Removed();
            end
        end

        --爆炸倒计时
        if self.LocalParam.CurrentState == BombItemConfig.StateType.Installed then
            local CurrentRealTime = GameplayStatics.GetRealTimeSeconds(self);
            local ExplodeRemainTime = BombItemConfig.ExplodeTime - (CurrentRealTime - self.LocalParam.InstalledTimestamp);
    
            self.ExplodeRemainTime = math.ceil(ExplodeRemainTime);
            print("BombItem:ReceiveTick ExplodeRemainTime = "..tostring(self.ExplodeRemainTime));
            if ExplodeRemainTime <= 0 then
                self:Exploded();
            end
        end
    end
end

--[[
function BombItem:RecevieEndPlay()
    print("BombItem:RecevieEndPlay");
end
]]

--拾取范围检测盒-Overlap
function BombItem:OnPickUpBox_BeginOverlap(OverlappedComp, Other, OtherComp, OtherBodyIndex, bFromSweep, SweepResult)
    if self.LocalParam.CurrentState ~= BombItemConfig.StateType.Dropped then
        print(string.format("Error: BombItem:OnPickUpBox_BeginOverlap CurrentState[%s]!", self.LocalParam.CurrentState));
        return;
    end

    print(string.format("BombItem:OnPickUpBox_BeginOverlap Other[%s]", GetObjectFullName(Other)));
    
    print(string.format("BombItem:OnPickUpBox_BeginOverlap Other[%s]", tostring(Other and Other.PlayerName)));

    if Other == nil then return end

    print(string.format("BombItem:OnPickUpBox_BeginOverlap TeamID[%d], IsAlive[%s]", Other.TeamID, Other:IsAlive()));

    if Other.TeamID == BurstMode.CampTeamIDTable.Terrorist and Other:IsAlive() then
        self:PickUp(Other);
    end
end

function BombItem:OnPickUpBox_EndOverlap(OverlappedComp, Other, OtherComp, OtherBodyIndex)
    --print("BombItem:OnPickUpBox_EndOverlap");
end

--拆除范围检测盒-Overlap
function BombItem:OnRemoveBox_BeginOverlap(OverlappedComp, Other, OtherComp, OtherBodyIndex, bFromSweep, SweepResult)
    if self.LocalParam.CurrentState ~= BombItemConfig.StateType.Installed then
        print(string.format("Error: BombItem:OnRemoveBox_BeginOverlap CurrentState[%s]!", self.LocalParam.CurrentState));
        return;
    end

    print(string.format("BombItem:OnRemoveBox_BeginOverlap Other[%s]", tostring(Other and Other.PlayerName)));

    print(string.format("BombItem:OnPickUpBox_BeginOverlap TeamID[%d], IsAlive[%s]", Other.TeamID, Other:IsAlive()));

    if Other.TeamID == BurstMode.CampTeamIDTable.Police and Other:IsAlive() then
        Other.IsInBombRemoveArea = true;
    end
end

function BombItem:OnRemoveBox_EndOverlap(OverlappedComp, Other, OtherComp, OtherBodyIndex)
    print("BombItem:OnRemoveBox_EndOverlap");

    if Other.IsInBombRemoveArea then
        Other.IsInBombRemoveArea = false;
    end
end

--拾取炸弹（DS）
function BombItem:PickUp(PickerPawn)
    print(string.format("BombItem:PickUp  Picker[%s]", tostring(PickerPawn and PickerPawn.PlayerName)));

    if PickerPawn == nil then return false end

    if self.LocalParam.CurrentState ~= BombItemConfig.StateType.None and self.LocalParam.CurrentState ~= BombItemConfig.StateType.Dropped then
        print(string.format("Error: BombItem:PickUp CurrentState[%s]!", self.LocalParam.CurrentState));
        return false;
    end

    self:K2_AttachToComponent(PickerPawn.Mesh, BombItemConfig.InBackPackStateSocketName);
    self:K2_SetActorRelativeLocation(Vector.New());

    self.LocalParam.OwnerPawn = PickerPawn;
    self.LocalParam.CurrentState = BombItemConfig.StateType.InBackPack;

    self.TriggerBox_Pickup:SetCollisionEnabled(ECollisionEnabled.NoCollision);

    self.LocalParam.OwnerPawn.IsBombOwner = true;
    PickerPawn.IsBombOwner = true;
    
    return true;
end

--炸弹掉落（DS）
function BombItem:Drop()
    print(string.format("BombItem:Drop  Owner[%s]", tostring(self.LocalParam.OwnerPawn and self.LocalParam.OwnerPawn.PlayerName)));

    if self.LocalParam.OwnerPawn == nil then return false end
    
    if self.LocalParam.CurrentState ~= BombItemConfig.StateType.InBackPack then 
        print(string.format( "Error: BombItem:Drop CurrentState[%s]!", self.LocalParam.CurrentState));
        return;
    end

    self:K2_DetachFromActor();
    local ItemDropLocation = self.LocalParam.OwnerPawn:GetRandomPutDownLocation();

    self:K2_SetActorLocation(ItemDropLocation);

    self.LocalParam.OwnerPawn.IsBombOwner = false;
    self.LocalParam.OwnerPawn = nil;
    self.LocalParam.CurrentState = BombItemConfig.StateType.Dropped;

    self.TriggerBox_Pickup:SetCollisionEnabled(ECollisionEnabled.QueryOnly);
end

--安装炸弹（DS）
function BombItem:Install(InstallerPawn)
    print(string.format("BombItem:Install Installer[%s]", tostring(InstallerPawn and InstallerPawn.PlayerName)));

    --安装中不能再次安装
    if self.LocalParam.InstallerPawn ~= nil then
        print(string.format( "BombItem:Remove Bomb Installing! Installer[%s]", self.LocalParam.InstallerPawn.PlayerName));
        return false;
    end

    if InstallerPawn == nil or InstallerPawn ~= self.LocalParam.OwnerPawn then
        print(string.format( "Error: BombItem:Install OwnerPawn[%s]",  tostring(self.LocalParam.OwnerPawn or self.LocalParam.OwnerPawn.PlayerName)));
        return false;
    end
    
    if self.LocalParam.CurrentState ~= BombItemConfig.StateType.InBackPack then 
        print(string.format( "Error: BombItem:Install CurrentState[%s]!", self.LocalParam.CurrentState))
        return false;
    end

    self.LocalParam.InstallerPawn = InstallerPawn;
    self.LocalParam.InstallTimestamp =  GameplayStatics.GetRealTimeSeconds(self);

    --强行进入站立状态并打断其他所有状态
    self.LocalParam.InstallerPawn:SwitchPoseState(ESTEPoseState.Stand);
    for PawnState = 0, EPawnState.__MAX - 1 do
    
        if InstallerPawn:HasState(PawnState) and PawnState ~= EPawnState.Stand then
            print(string.format( "BombItem:Install Leave PawnState[%d]!", PawnState));
            InstallerPawn:LeaveState(PawnState);
        end
    end

    self.LocalParam.InstallerPawn.StateEnterHandler:Add(self.OnPawnStateChange, self);
    

    self:K2_AttachToComponent(self.LocalParam.OwnerPawn.Mesh, BombItemConfig.InstallingStateSocketName);

    UnrealNetwork.CallUnrealRPC_Multicast(self,"MulticastRPC_Install", self.LocalParam.InstallerPawn);
    
    --测试用
    --self:Installed();

    return true;
end

function BombItem:OnPawnStateChange(PawnState)
    print(string.format("BombItem:OnPawnStateChange PawnState[%d]", PawnState or -1));

    if self.LocalParam.InstallerPawn then
        self:BreakInstall();
    elseif self.LocalParam.RemoverPawn then
        self:BreakRemove();
    end
end

--安装炸弹（Client）
function BombItem:MulticastRPC_Install(InstallerPawn)
    print(string.format("BombItem:MulticastRPC_Install Installer[%s]",tostring(InstallerPawn and InstallerPawn.PlayerName)));

    if self:HasAuthority() then
        print("BombItem:MulticastRPC_Install  Server");
        return false;
    end

    if InstallerPawn == nil then return false end

    local InstallMontage = UE.LoadObject(BombItemConfig.InstallingMontagePath);

    if InstallMontage ~= nil then
        InstallerPawn:PlayAnimMontage(InstallMontage, 1.0, "InstallMontage");
        print("BombItem:MulticastRPC_Install PlayAnimMontage");
    else
        print(string.format("Error: BombItem:MulticastRPC_Install InstallMontage[%s] is nill", BombItemConfig.InstallingMontagePath));
    end
end

--已安装炸弹（DS）
function BombItem:Installed()
    print(string.format("BombItem:Installed Installer[%s]",tostring(self.LocalParam.InstallerPawn and self.LocalParam.InstallerPawn.PlayerName)));

    if self.LocalParam.InstallerPawn == nil then return false end

    UnrealNetwork.CallUnrealRPC_Multicast(self, "MulticastRPC_Installed", self.LocalParam.InstallerPawn);

    self:K2_DetachFromActor();

    local InstallLocation = self.LocalParam.OwnerPawn:GetRandomPutDownLocation();
    self:K2_SetActorLocation(InstallLocation);

    self.LocalParam.CurrentState = BombItemConfig.StateType.Installed;
    self.LocalParam.InstalledTimestamp = GameplayStatics.GetRealTimeSeconds(self);

    self.TriggerBox_Remove:SetCollisionEnabled(ECollisionEnabled.QueryOnly);

    self.LocalParam.InstallerPawn.StateEnterHandler:Remove(self.OnPawnStateChange, self);

    self.LocalParam.InstallerPawn = nil;
    self.LocalParam.InstallTimestamp = nil;
    self.LocalParam.OwnerPawn.IsBombOwner = false;
    self.LocalParam.OwnerPawn = nil;
    
    LuaQuickFireEvent(BombEvent.BombInstalledEvent, self);

    return true;
end

--已安装炸弹（Client）
function BombItem:MulticastRPC_Installed(InstallerPawn)
    print(string.format("BombItem:MulticastRPC_Installed Installer[%s]",tostring(InstallerPawn and InstallerPawn.PlayerName)));

    if InstallerPawn == nil then return false end

    local InstallMontage = UE.LoadObject(BombItemConfig.InstallingMontagePath);

    if InstallMontage == nil then
        print(string.format("Error: BombItem:MulticastRPC_Installed InstallMontage[%s] is nill", BombItemConfig.InstallingMontagePath));
        return false;
    end

    if InstallerPawn:Montage_IsPlaying(InstallMontage) then
        InstallerPawn:StopAnimMontage(InstallMontage);
        print("BombItem:MulticastRPC_Installed StopInstallMontage");
    end

    UGCEventSystem:SendEvent(BurstModeEventType.BombInstalled, InstallerPawn);
end

--拆除炸弹（DS）
function BombItem:Remove(RemoverPawn)
    print(string.format("BombItem:Remove Remover[%s]", tostring(RemoverPawn and RemoverPawn.PlayerName)));

    --拆除中不能再次拆除
    if self.LocalParam.RemoverPawn ~= nil then
        print(string.format( "BombItem:Remove Bomb Removing! RemoverPawn[%s]", self.LocalParam.RemoverPawn.PlayerName));
        return false;
    end
        
    if RemoverPawn == nil then return false end

    if self.LocalParam.CurrentState ~= BombItemConfig.StateType.Installed then 
        print(string.format( "Error: BombItem:Remove CurrentState[%s]!", self.LocalParam.CurrentState))
        return false;
    end

    self.LocalParam.RemoveTimestamp =  GameplayStatics.GetRealTimeSeconds(self);
    self.LocalParam.RemoverPawn = RemoverPawn;
    self.LocalParam.RemoverPawn.StateEnterHandler:Add(self.OnPawnStateChange, self);

    UnrealNetwork.CallUnrealRPC_Multicast(self,"MulticastRPC_Remove", RemoverPawn);

    return true;
end


--拆除炸弹（Client）
function BombItem:MulticastRPC_Remove(RemoverPawn)
    print(string.format("BombItem:MulticastRPC_Remove Remover[%s]", tostring(RemoverPawn and RemoverPawn.PlayerName)));

    if RemoverPawn == nil then return false end

    local RemoveMontage = UE.LoadObject(BombItemConfig.RemovingMontagePath);

    if RemoveMontage ~= nil then
        RemoverPawn:PlayAnimMontage(RemoveMontage, 1.0, "InstallMontage");
        print("BombItem:MulticastRPC_Remove PlayAnimMontage");
    else
        print(string.format("Error: BombItem:MulticastRPC_Remove InstallMontage[%s] is nill", BombItemConfig.RemovingMontagePath));
    end
end


--已拆除炸弹(DS)
function BombItem:Removed()
    print(string.format("BombItem:Removed Remover[%s]", tostring(self.LocalParam.RemoverPawn and self.LocalParam.RemoverPawn.PlayerName)));

    if self.LocalParam.RemoverPawn == nil then return false end

    if self.LocalParam.CurrentState ~= BombItemConfig.StateType.Installed then 
        print(string.format( "Error: BombItem:Remove CurrentState[%s]!", self.LocalParam.CurrentState))
        return false;
    end

    UnrealNetwork.CallUnrealRPC_Multicast(self,"MulticastRPC_Removed", self.LocalParam.RemoverPawn);

    self.LocalParam.RemoverPawn.StateEnterHandler:Remove(self.OnPawnStateChange, self);
    self.LocalParam.RemoverPawn = nil;
    self.LocalParam.RemoveTimestamp = nil;
    self.LocalParam.CurrentState = BombItemConfig.StateType.Removed;
    self.TriggerBox_Remove:SetCollisionEnabled(ECollisionEnabled.NoCollision);

    self:SetActorHiddenInGame(true);

    BurstMode.CurrentRoundEndReason = BurstMode.RoundEndReasonType.BombRemoved;
    LuaQuickFireEvent(BombEvent.BombRemovedEvent, self);
    return true;
end

--已拆除炸弹(Client)
function BombItem:MulticastRPC_Removed(RemoverPawn)
    print(string.format("BombItem:MulticastRPC_Removed Remover[%s]", tostring(RemoverPawn and RemoverPawn.PlayerName)));

    if RemoverPawn == nil then return false end

    local RemoveMontage = UE.LoadObject(BombItemConfig.RemovingMontagePath);

    if RemoveMontage == nil then
        print(string.format("Error: BombItem:MulticastRPC_Removed RemoveMontage[%s] is nill", BombItemConfig.RemovingMontagePath));
        return false;
    end

    if RemoverPawn:Montage_IsPlaying(RemoveMontage) then
        RemoverPawn:StopAnimMontage(RemoveMontage);
        print("BombItem:MulticastRPC_Removed StopRemoveMontage");
    end

    UGCEventSystem:SendEvent(BurstModeEventType.BombRemoved, RemoverPawn);
end


--爆炸（DS）
function BombItem:Exploded()
    print("BombItem:Exploded");

    if self.LocalParam.CurrentState ~= BombItemConfig.StateType.Installed then 
        print(string.format( "Error: BombItem:Exploded CurrentState[%s]!", self.LocalParam.CurrentState))
        return false;
    end

    if self.LocalParam.RemoverPawn ~= nil then 
        self.LocalParam.RemoverPawn.StateEnterHandler:Remove(self.OnPawnStateChange, self);
        self.LocalParam.RemoverPawn = nil;
    end

    UnrealNetwork.CallUnrealRPC_Multicast(self,"MulticastRPC_Exploded");

    self.LocalParam.CurrentState = BombItemConfig.StateType.Exploded;
    self.TriggerBox_Remove:SetCollisionEnabled(ECollisionEnabled.NoCollision);

    self:SetActorHiddenInGame(true);
    
    BurstMode.CurrentRoundEndReason = BurstMode.RoundEndReasonType.BombExploded;
    LuaQuickFireEvent(BombEvent.BombExplodedEvent, self);
end

--爆炸(Client)
function BombItem:MulticastRPC_Exploded()
    print("BombItem:MulticastRPC_Exploded");

    UGCEventSystem:SendEvent(BurstModeEventType.BombExploded);
end


--中断安装（DS）
function BombItem:BreakInstall()
    print(string.format("BombItem:BreakInstall Installer[%s]",tostring(self.LocalParam.InstallerPawn and self.LocalParam.InstallerPawn.PlayerName)));

    if self.LocalParam.InstallerPawn == nil then return false end

    self:K2_AttachToComponent(self.LocalParam.InstallerPawn.Mesh, BombItemConfig.InBackPackStateSocketName);
    self:K2_SetActorRelativeLocation(Vector.New());

    UnrealNetwork.CallUnrealRPC_Multicast(self,"MulticastRPC_BreakInstall", self.LocalParam.InstallerPawn);

    self.LocalParam.InstallerPawn.StateEnterHandler:Remove(self.OnPawnStateChange, self);
    self.LocalParam.InstallerPawn = nil;
    self.LocalParam.InstallTimestamp = nil;
    
    return true;
end


--中断安装（Client）
function BombItem:MulticastRPC_BreakInstall(InstallerPawn)
    print(string.format("BombItem:MulticastRPC_BreakInstall Installer[%s]",tostring(InstallerPawn and InstallerPawn.PlayerName)));

    if InstallerPawn == nil then return false end

    local InstallMontage = UE.LoadObject(BombItemConfig.InstallingMontagePath);

    if InstallMontage == nil then
        print(string.format("Error: BombItem:MulticastRPC_BreakInstall InstallMontage[%s] is nill", BombItemConfig.InstallingMontagePath));
        return false;
    end

    if InstallerPawn:Montage_IsPlaying(InstallMontage) then
        InstallerPawn:StopAnimMontage(InstallMontage);
        print("BombItem:MulticastRPC_BreakInstall StopInstallMontage");
    end

    return true;
end

--中断拆除（DS）
function BombItem:BreakRemove()
    print(string.format("BombItem:BreakRemove Remover[%s]",tostring(self.LocalParam.RemoverPawn and self.LocalParam.RemoverPawn.PlayerName)));

    if self.LocalParam.RemoverPawn == nil then return false end

    UnrealNetwork.CallUnrealRPC_Multicast(self,"MulticastRPC_BreakRemove", self.LocalParam.RemoverPawn);

    self.LocalParam.RemoverPawn.StateEnterHandler:Remove(self.OnPawnStateChange, self);
    self.LocalParam.RemoverPawn = nil;
    self.LocalParam.RemoveTimestamp = nil;
    
    return true;
end


--中断拆除（Client）
function BombItem:MulticastRPC_BreakRemove(RemoverPawn)
    print(string.format("BombItem:MulticastRPC_BreakRemove Removeer[%s]",tostring(RemoverPawn and RemoverPawn.PlayerName)));

    if RemoverPawn == nil then return false end

    local RemoveMontage = UE.LoadObject(BombItemConfig.RemovingMontagePath);

    if RemoveMontage == nil then
        print(string.format("Error: BombItem:MulticastRPC_BreakRemove RemoveMontage[%s] is nill", BombItemConfig.RemovingMontagePath));
        return false;
    end

    if RemoverPawn:Montage_IsPlaying(RemoveMontage) then
        RemoverPawn:StopAnimMontage(RemoveMontage);
        print("BombItem:MulticastRPC_BreakRemove StopRemoveMontage");
    end

    return true;
end

return BombItem;

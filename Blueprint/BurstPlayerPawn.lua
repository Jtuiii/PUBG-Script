require("Script.Library.BurstModeEventDefine")
require("Script.Library.UGCEventSystem")

---@class BurstPlayerPawn_C:BP_PlayerPawn_C
--Edit Below--
--玩家角色

local BurstPlayerPawn = 
{
    IsBombOwner = false,
    IsInBombInstallArea = false,
    IsInBombRemoveArea = false;
}

--是否炸弹携带者
BurstPlayerPawn.IsBombOwner = false;

--是否进入炸弹安装区域
BurstPlayerPawn.IsInBombInstallArea = false;

--是否进入炸弹拆除区域
BurstPlayerPawn.IsInBombRemoveArea = false;

--目前设计是进入战斗后才发放炸弹，暂不需要清理设计
--[[
function BurstPlayerPawn:ReceiveDestroyed()
    print(string.format("BurstPlayerPawn:ReceiveDestroyed[%s]", self.PlayerName));
    
    if self:HasAuthority() then
        --处理准备阶段发放的炸弹，后面重置玩家Destroyed后Attach的Pawn更换的问题
        if BurstMode.BombItem ~= nil and BurstMode.BombItem.LocalParam.OwnerPawn == self then
            print("BurstPlayerPawn:ReceiveDestroyed BombItem Destroy!");
            BurstMode.BombItem:K2_DestroyActor();
            BurstMode.BombItem = nil;
        end
    end
end
]]

function BurstPlayerPawn:GetReplicatedProperties()
    return 
    "IsBombOwner",
    "IsInBombInstallArea",
    "IsInBombRemoveArea";
end

function BurstPlayerPawn:OnRep_IsBombOwner()
    print(string.format("BurstPlayerPawn:OnRep_IsBombOwner[%s] IsBombOwner[%s]", self.PlayerName, self.IsBombOwner));

    --self.IsBombOwner = true;
    local PlayerController = GameplayStatics.GetPlayerController(self, 0);

    if self.IsBombOwner then
        if PlayerController ~= nil and self:GetPlayerControllerSafety() == PlayerController then
            UGCEventSystem:SendEvent(BurstModeEventType.PlayerIsBombOwnerChange, self, self.IsBombOwner);
        end
    end
end

function BurstPlayerPawn:OnRep_IsInBombInstallArea()
    print(string.format("BurstPlayerPawn:OnRep_IsInBombInstallArea[%s] IsInBombInstallArea[%s]", self.PlayerName, self.IsInBombInstallArea));

    local PlayerController = GameplayStatics.GetPlayerController(self, 0);

    if UGCEventSystem == nil then
        require("Script.Library.UGCEventSystem");
        UGCEventSystem = UGCEventSystem;
    end

    if PlayerController ~= nil and self:GetPlayerControllerSafety() == PlayerController then
        UGCEventSystem:SendEvent(BurstModeEventType.PlayerIsInBombInstallAreaChange, self, self.IsInBombInstallArea);
    end
end

function BurstPlayerPawn:OnRep_IsInBombRemoveArea()
    print(string.format("BurstPlayerPawn:OnRep_IsInBombRemoveArea[%s] IsInBombRemoveArea[%s]", self.PlayerName, self.IsInBombRemoveArea));

    local PlayerController = GameplayStatics.GetPlayerController(self, 0);

    if PlayerController ~= nil and self:GetPlayerControllerSafety() == PlayerController then
        UGCEventSystem:SendEvent(BurstModeEventType.PlayerIsInBombRemoveAreaChange, self, self.IsInBombRemoveArea);
    end
end

return BurstPlayerPawn;

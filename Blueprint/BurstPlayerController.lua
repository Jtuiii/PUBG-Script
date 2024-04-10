
--角色控制器
local BurstPlayerController = 
{
}


--注册Server RPC
function BurstPlayerController:GetAvailableServerRPCs()
    return "ServerRPC_InstallBomb","ServerRPC_RemoveBomb";
end


--DS端-请求安装炸弹
function BurstPlayerController:ServerRPC_InstallBomb()
    print("BurstPlayerController::ServerRPC_InstallBomb");

    if self:HasAuthority() == false then
        print("Error: BurstPlayerController::ServerRPC_InstallBomb Not Server!");
        return;
    end

    local PlayerPawn = self:GetPlayerCharacterSafety();

    if PlayerPawn == nil then
        print("Error: BurstPlayerController::ServerRPC_InstallBomb PlayerPawn is nil!");
        return;
    end

    if PlayerPawn.IsBombOwner == false or PlayerPawn.IsInBombInstallArea == false or PlayerPawn:IsAlive() == false then
        print(string.format("Warning: BurstPlayerController:ServerRPC_InstallBomb IsBombOwner[%s], IsInBombInstallArea[%s], IsAlive[%s]", 
        PlayerPawn.IsBombOwner, PlayerPawn.IsInBombInstallArea, PlayerPawn:IsAlive()));
        return;
    end

    if BurstMode.BombItem ~= nil then
        BurstMode.BombItem:Install(PlayerPawn);
    else
        print("Error: BurstPlayerController:ServerRPC_InstallBomb BombItem is nil!");
    end
end

--DS端-请求移除炸弹
function BurstPlayerController:ServerRPC_RemoveBomb()
    print("BurstPlayerController::ServerRPC_RemoveBomb");

    if self:HasAuthority() == false then
        print("Error: BurstPlayerController::ServerRPC_RemoveBomb Not Server!");
        return;
    end

    local PlayerPawn = self:GetPlayerCharacterSafety();

    if PlayerPawn == nil then
        print("Error: BurstPlayerController::ServerRPC_RemoveBomb PlayerPawn is nil!");
        return;
    end

    if self.TeamID ~= BurstMode.CampTeamIDTable.Police or PlayerPawn.IsInBombRemoveArea == false or PlayerPawn:IsAlive() == false  then
        print(string.format("Error: BurstPlayerController:ServerRPC_RemoveBomb TeamID[%d], IsInBombRemoveArea[%s], IsAlive[%s]", 
        self.TeamID, PlayerPawn.IsInBombRemoveArea, PlayerPawn:IsAlive()));
        return;
    end

    if BurstMode.BombItem ~= nil then
        BurstMode.BombItem:Remove(PlayerPawn);
    else
        print("Error: BurstPlayerController:ServerRPC_RemoveBomb BurstMode.BombItem is nil!");
    end
end


return BurstPlayerController;


--角色出生点管理器
local BurstPlayerStartConmponent = 
{
}


function BurstPlayerStartConmponent:GetUGCModePlayerStart(Controller)
   -- print(string.format("BurstPlayerStartConmponent:GetUGCModePlayerStart Controller[%s]", tostring(Controller and Controller.PlayerName)));

    if Controller == nil then return nil end

    if self.PlayerStartData == nil then
        print("Error: BurstPlayerStartConmponent:GetUGCModePlayerStart PlayerStartData is nil!");
        return nil;
    end

    local BornIDToPlayerStartsMap = self.PlayerStartData:GetBornIDToPlayerStartsMap();

    local TeamId = Controller.PlayerTeamId or Controller.TeamID
    local TeamPlayerStartData = BornIDToPlayerStartsMap[TeamId];

    if TeamPlayerStartData == nil then
        print("Error: BurstPlayerStartConmponent:GetUGCModePlayerStart TeamPlayerStartData is nil!");
        return nil;
    end

    local TeamPlayerStarts = TeamPlayerStartData.PlayerStarts;

    --print(string.format("BurstPlayerStartConmponent:GetUGCModePlayerStart TeamID[%d] #TeamPlayerStarts[%d]", TeamId, TeamPlayerStarts:Num()));

    local PreferredPlayerStarts = {};

    for i = 1, TeamPlayerStarts:Num() do
        local PlayerStart = TeamPlayerStarts[i]
        --print("SurgeliTest: BurstPlayerStartConmponent:GetUGCModePlayerStart for #TeamPlayerStarts");
        
        if PlayerStart ~= nil and PlayerStart:IsMarkOccupied() == false then
            table.insert(PreferredPlayerStarts, PlayerStart);
        end
    end

    if #PreferredPlayerStarts == 0 then
        PreferredPlayerStarts = TeamPlayerStarts;
    end

    local SelectedPlayerStart = PreferredPlayerStarts[math.random(#PreferredPlayerStarts)];

    if SelectedPlayerStart ~= nil then
        --print(string.format("BurstPlayerStartConmponent:GetUGCModePlayerStart SelectedPlayerStart[%s] BornID[%d]", 
        --KismetSystemLibrary.GetObjectName(SelectedPlayerStart), SelectedPlayerStart.PlayerBornPointID));
        
        --SelectedPlayerStart:SetMarkOccupied();
        return SelectedPlayerStart;
    else
        print(string.format( "Error: BurstPlayerStartConmponent:GetUGCModePlayerStart SelectedPlayerStart is nil! #PreferredPlayerStarts[%d]", #PreferredPlayerStarts));
    end

    return nil;
end


return BurstPlayerStartConmponent;

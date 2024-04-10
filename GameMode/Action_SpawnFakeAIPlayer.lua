--[[------------------------------------------生成假人AI------------------------------------------------------]]--
local Action_SpawnFakeAIPlayer = {}

local MAX_PLAYER_PER_TEAM = 4

local function FillTeamWithFakeAIPlayer(TeamModeComponent, TeamID)
    local TerroristPlayerKeys = TeamModeComponent:GetTeamPlayerKeys(TeamID);
    local PlayerKeysNum = TerroristPlayerKeys:Num()
    print(string.format("TeamID: %d, num: %d, max_num: %d", TeamID, PlayerKeysNum, MAX_PLAYER_PER_TEAM))
    for i = PlayerKeysNum + 1, MAX_PLAYER_PER_TEAM do
        local AIPlayerKey = ScriptGameplayStatics.GetRandomAIPlayerKey()
        print("FillTeamWithFakeAIPlayer, AIPlayerKey = " .. tostring(AIPlayerKey))
        TeamModeComponent:SetAITeamIDCache(AIPlayerKey, TeamID)
        UGCGameSystem.GameMode:NotifyNewAIPlayerEnter(AIPlayerKey)
    end
end

function Action_SpawnFakeAIPlayer:Execute()
    print("Action_SpawnFakeAIPlayer:Execute")
    
    if UGCGameSystem.GameMode == nil then
        print("Action_SpawnFakeAIPlayer:Execute UGCGameSystem.GameMode is nil")
        UGCGameSystem.GameMode = GameplayStatics.GetGameMode(self);
    end
    

	local TeamModeComponentClass = ScriptGameplayStatics.FindClass("TeamModeComponent")
    local TeamModeComponent = ScriptGameplayStatics.FindComponent(UGCGameSystem.GameMode, TeamModeComponentClass)
	if TeamModeComponent == nil then
		print("Error: Action_SpawnFakeAIPlayer:Execute TeamModeComponent is nil!")
		return false
    end
    
    FillTeamWithFakeAIPlayer(TeamModeComponent, BurstMode.CampTeamIDTable.Police)
    FillTeamWithFakeAIPlayer(TeamModeComponent, BurstMode.CampTeamIDTable.Terrorist)

	return true
end

return Action_SpawnFakeAIPlayer

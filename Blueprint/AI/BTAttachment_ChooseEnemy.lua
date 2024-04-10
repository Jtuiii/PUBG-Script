local BTAttachment_ChooseEnemy = {}

local function SqureF(x)
	return x * x
end

local function GetDistanceSq(vec1, vec2)
	return SqureF(vec1.X - vec2.X) + SqureF(vec1.Y - vec2.Y) + SqureF(vec1.Z - vec2.Z)
end

function BTAttachment_ChooseEnemy:ReceiveTickAI(OwnerController, ControlledPawn, DeltaSeconds)
    local CharacterClass = ScriptGameplayStatics.FindClass("STExtraBaseCharacter")
	local Characters = ScriptGameplayStatics.GetActorsOfClass(self, CharacterClass)
	-- print(string.format("BTAttachment_ChooseEnemy: Characters[%d]", #Characters))
	
	local CurrentTarget = BTFunctionLibrary.GetBlackboardValueAsObject(self, self.OutTargetEnemyActor)
	local SenseRadiusSq = SqureF(self.SenseRadius or 1000)
	
	local MinDistSq = math.huge
	local TargetCharacter = nil

	local PawnLoc = ControlledPawn:K2_GetActorLocation()

	for i = 1, Characters:Num() do
		local Character = Characters[i]
		-- print(string.format("BTAttachment_ChooseEnemy: CharactersName[%s], TeamID[%d]", Character.PlayerName, Character.TeamID))
		if Character ~= nil and
			Character ~= ControlledPawn and
			Character:IsAlive() and
			Character.TeamID ~= ControlledPawn.TeamID then
			local DistSq = GetDistanceSq(PawnLoc, Character:K2_GetActorLocation())
			if DistSq <= SenseRadiusSq and ScriptGameplayStatics.IsTargetVisibility(ControlledPawn, Character) then
				if Character == CurrentTarget then return end -- old target
				if DistSq < MinDistSq then
					MinDistSq = DistSq
					TargetCharacter = Character
				end
			end
		end
	end

	if TargetCharacter ~= CurrentTarget then
		-- print(string.format("BTAttachment_ChooseEnemy:SetTargetEnemy, New[%s]", TargetCharacter and TargetCharacter.PlayerName or ""))
		BTFunctionLibrary.SetBlackboardValueAsObject(self, self.OutTargetEnemyActor, TargetCharacter)
	end
end

return BTAttachment_ChooseEnemy
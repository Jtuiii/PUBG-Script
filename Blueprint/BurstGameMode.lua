---@class BurstGameMode_C:BP_UGCGameBase_C
--Edit Below--
local BurstGameMode = {}; 
-- function BurstGameMode:ReceiveBeginPlay()

-- end
-- function BurstGameMode:ReceiveTick(DeltaTime)

-- end
-- function BurstGameMode:ReceiveEndPlay()
 
-- end


function BurstGameMode:LuaModifyDamage(Damage, DamageType, InstigatorPlayerState, VictimPlayerState)
    print(string.format("BurstGameMode:LuaModifyDamage    DamageType[%d]", DamageType))

    if DamageType == EDamageType.MeleeDamage and InstigatorPlayerState.TeamID == VictimPlayerState.TeamID then
        print(string.format("BurstGameMode:LuaModifyDamage    ingore MeleeDamage "))
        return 0
    end

    return Damage
end

return BurstGameMode;
-- 添加装备
local BTTask_AddEquipment = {}

function BTTask_AddEquipment:ReceiveExecuteAI(OwnerController, ControlledPawn)
	local AIEquipSpawnGroupList = self.AIEquipSpawnGroup.AIEquipSpawnGroupList
	if AIEquipSpawnGroupList:Num() < 1 then
		print("BTTask_AddEquipment: AIEquipSpawnGroupList is null")
		self:FinishExecute(false)
		return
	end

	local AIEquipSpawnItems = AIEquipSpawnGroupList[1].Item
	local SpawnItemsNum = AIEquipSpawnItems:Num()
	if SpawnItemsNum < 1 then
		print("BTTask_AddEquipment: AIEquipSpawnItems is null")
		self:FinishExecute(false)
		return
	end
	
	for i = 1, SpawnItemsNum do
		local item = AIEquipSpawnItems[i]
		local defineID = BackpackUtils.GenerateItemDefineIDByItemTableIDWithRandomInstanceID(item.ItemSpecificID)
		local pickupInfo = CreateStruct("BattleItemPickupInfo")
		pickupInfo.Count = item.Count;
		local result = OwnerController.BackpackComponent:PickupItem(defineID, pickupInfo, EBattleItemPickupReason.Manually)
		if result then
			print(string.format("BTTask_AddEquipment: AI Name[%s] PickupItem[%d] Count[%d]", ControlledPawn.PlayerName, item.ItemSpecificID, item.Count))
		else
			print("BTTask_AddEquipment Failed")
			self:FinishExecute(false)
			return
		end
	end
	self:FinishExecute(true)
end

return BTTask_AddEquipment

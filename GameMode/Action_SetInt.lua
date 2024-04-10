local Action_SetInt = {}

local Action_SetInt = 
{
    PropertyName = "";
    Value = 0;
}


function Action_SetInt:Execute(...)
    print(string.format("Action_SetInt:Execute PropertyName[%s], Value[%d]", self.PropertyName, self.Value));

    UGCGameSystem.GameState[self.PropertyName] = self.Value;

	return true;
end

return Action_SetInt
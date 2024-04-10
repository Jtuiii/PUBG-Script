local Action_SetState = {}

local Action_SetState = 
{
    StateName = "";
}

function Action_SetState:Execute(...)
    print(string.format("Action_SetState:Execute StateName[%s]", self.StateName));

    if StateName ~= "" then
        BurstMode:SetCurrentRoundState(StateName);
    end
	return true;
end

return Action_SetState
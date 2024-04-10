local Action_Timer = {}

--[[------------------------------------------定时器------------------------------------------------------]]--
local Action_Timer = 
{
    Time = 0;
    StartEvent = "";
    UpdateEvent = "";
    EndEvent = "";
    StopEvent = "";
    TickTime = 1;
}

function Action_Timer:Execute()
    print(string.format("Action_Timer:Execute Time[%d]",self.Time));
    self.StartTime = GameplayStatics.GetRealTimeSeconds(self);
    self.bEnableActionTick = true;

    if self.StartEvent ~= "" then
        LuaQuickFireEvent(self.StartEvent, self);
    end

    if self.UpdateEvent ~= "" then
        LuaQuickFireEvent(self.UpdateEvent, self, self.Time);
    end
    if self.StopEvent ~= "" then
        LuaRegisterEvent(self.StopEvent, self, "Stop");
    end

    return true;
end

function Action_Timer:Update(deltaTime)
    local NowTime = GameplayStatics.GetRealTimeSeconds(self);
    local RemainTime = self.Time - (NowTime - self.StartTime);

    print("Action_Timer:Update");

    if RemainTime < 0 then
        RemainTime = 0;
    end

    local CurRemainTime = math.ceil(RemainTime);
    if self.UpdateEvent ~= "" then
        LuaQuickFireEvent(self.UpdateEvent, self, CurRemainTime);
    end

    if RemainTime <= 0 then
        self:End();
    end
end

function Action_Timer:End()
    print("Action_Timer:End");
    self.bEnableActionTick = false;
    if self.EndEvent ~= "" then
        LuaQuickFireEvent(self.EndEvent, self);
    end

    if self.StopEvent ~= "" then
        LuaUnRegisterEvent(self.StopEvent, self);
    end
end

function Action_Timer:Stop()
    print("Action_Timer:Stop");
    if self.StopEvent ~= "" then
        self.bEnableActionTick = false;
    end
end

return Action_Timer;

UGCEventSystem = UGCEventSystem or 
{
    Events = {};
};

--添加监听
function UGCEventSystem:AddListener(EventType, Func, Object)
    if EventType == nil or Func == nil then
        print("Error: UGCEventSystem:AddListener EventType or Func is nil!");
        return;
    end

    local FuncData = {};
    FuncData.Object = Object;
    FuncData.Func = Func;

    if self.Events[EventType]==nil then
        local NewEventFuncs={};
        table.insert(NewEventFuncs ,FuncData);
        self.Events[EventType] = NewEventFuncs;
        print(string.format("UGCEventSystem:AddListener Succeed! self[%s], EventType[%s], Func[%s]", tostring(self), tostring(EventType), tostring(Func)));
    else
        table.insert(self.Events[EventType], FuncData)
        print(string.format("UGCEventSystem:AddListener Succeed! EventType[%s], Func[%s]", tostring(EventType), tostring(Func)));
    end
end
--移除监听
function UGCEventSystem:RemoveListener(EventType, Func, Object)
    if EventType == nil or Func == nil then
        print("Error: UGCEventSystem:AddListener EventType or Func is nil!");
        return;
    end
    local EventFuncs = self.Events[EventType];
    if EventFuncs ~= nil then
        for i, FuncData in pairs(EventFuncs) do
            if FuncData.Func == Func and FuncData.Object == Object then
                EventType[i] = nil;
            end
        end
    end
end

--派发事件
function UGCEventSystem:SendEvent(EventType, ...)
    print(string.format("UGCEventSystem:SendEvent self[%s], EventType[%d]", tostring(self), EventType));
    if EventType ~= nil then
        local EventFuncs = self.Events[EventType];
        if EventFuncs ~= nil then
            for i, FuncData in pairs(EventFuncs) do
                if FuncData.Object ~= nil then
                    FuncData.Func(FuncData.Object, ...);
                else
                    FuncData.Func(...);
                end
            end
        else
            print(string.format("UGCEventSystem:SendEvent EventFuncs[%d] is nil!", EventType));
        end
    end
end

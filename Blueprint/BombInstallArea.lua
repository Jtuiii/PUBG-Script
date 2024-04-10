local BombInstallArea = {}; 

function BombInstallArea:ReceiveBeginPlay()
    print(string.format("BombInstallArea:ReceiveBeginPlay IsServer[%s]", self:HasAuthority()));

    if self:HasAuthority() then
        self.TriggerBox.OnComponentBeginOverlap:Add(self.OnBeginOverlap, self);
        self.TriggerBox.OnComponentEndOverlap:Add(self.OnEndOverlap, self);
    end
end

function BombInstallArea:OnBeginOverlap(OverlappedComp, Other, OtherComp, OtherBodyIndex, bFromSweep, SweepResult)
    print("BombInstallArea:OnBeginOverlap");
    
    if Other and Other.TeamID == BurstMode.CampTeamIDTable.Terrorist then
        print(string.format("BombInstallArea:OnBeginOverlap Player[%s] In BombInstallArea!", Other.PlayerName));
        Other.IsInBombInstallArea = true;
    end
end

function BombInstallArea:OnEndOverlap(OverlappedComp, Other, OtherComp, OtherBodyIndex)
    print("BombInstallArea:OnEndOverlap");

    if Other and Other.TeamID == BurstMode.CampTeamIDTable.Terrorist then
        print(string.format("BombInstallArea:OnEndOverlap Player[%s] In BombInstallArea!", Other.PlayerName));
        Other.IsInBombInstallArea = false;
    end
end

return BombInstallArea;
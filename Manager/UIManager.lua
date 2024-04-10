--[[------------------------------------------UI管理器------------------------------------------------------]]--
UIManager = UIManager or {}

--[[------------------------------------------配置数据------------------------------------------------------]]--

--炸弹安装面板UI路径
UIManager.BurstModePanelClassPath = UGCMapInfoLib.GetRootLongPackagePath().. "Asset/UI/BurstModeMainUI.BurstModeMainUI_C";

UIManager.ImagePath_RoundWin = "/Game/Arts/UI/NoAtlas/BlastingNoAtlas/Blasting_icon_huiheshengli.Blasting_icon_huiheshengli";
UIManager.ImagePath_RoundFail = "/Game/Arts/UI/NoAtlas/BlastingNoAtlas/Blasting_icon_huiheshibai.Blasting_icon_huiheshibai";
UIManager.ImagePath_GameWin = "/Game/Arts/UI/NoAtlas/BlastingNoAtlas/Blasting_icon_yingdebisai.Blasting_icon_yingdebisai";
UIManager.ImagePath_GameFail = "/Game/Arts/UI/NoAtlas/BlastingNoAtlas/Blasting_icon_jieshu.Blasting_icon_jieshu";

--[[------------------------------------------动态数据------------------------------------------------------]]--
UIManager.BurstModePanelWidget = nil;


--[[------------------------------------------方法------------------------------------------------------]]--

--创建爆破模式UI
function UIManager.CreateBurstModePanelWidget(PlayerController)
	print("UIManager:CreateBurstModePanelWidget");

    local BurstModePanelClass = UE.LoadClass(UIManager.BurstModePanelClassPath);

    if BurstModePanelClass ~= nil then
        UIManager.BurstModePanelWidget = UserWidget.NewWidgetObjectBP(PlayerController, BurstModePanelClass);
        if UIManager.BurstModePanelWidget ~= nil then
            UIManager.BurstModePanelWidget:AddToViewport();
        else
            print("Error: UIManager:CreateBurstModePanelWidget BurstModePanelWidget == nil!"); 
        end
    else
        print("Error: UIManager:CreateBurstModePanelWidget BurstModePanelClass == nil!"); 
    end

	return UIManager.BurstModePanelWidget;
end

--显示提示
function UIManager.DisplayTips(WorldObject, TipsContent)
    print(string.format( "UIManager:DisplayTips[%s]", TipsContent));

    local PlayerController = GameplayStatics.GetPlayerController(WorldObject, 0);

    if PlayerController == nil then
        print("Error: UIManager:DisplayTips PlayerController == nil!");
        return;
    end

    PlayerController:DisplayGameTipWithMsgIDAndString(1, TipsContent);
end


//=============================================================================
// KFGFxStartGameContainer_FindGame
//=============================================================================
// 
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Zane Gholson 1/27/2015
//=============================================================================

class KFGFxStartGameContainer_FindGame extends KFGFxObject_Container
	config(UI);

var KFGFxMenu_StartGame StartMenu;

struct SWhatsNew
{
    var string ImageURL;
    var string TextField;
    var string RedirectURL;
	var string PSNProductId;
};

var array<SWhatsNew> WhatsNewItems;
var const private config array<SWhatsNew> PS4WhatsNewItems;
var const private config array<SWhatsNew> PS4WhatsNewItemsFreeTrial;
var array<SWhatsNew> PS4ActiveWhatsNewItems;

var localized string MultiplayerString;
var localized string CreateGameString;
var localized string SoloString;
var localized string TutorialString;

var bool bTrialNewsActive;
var OnlineSubsystem OnlineSub;
//==============================================================
// Initialization
//==============================================================
function Initialize( KFGFxObject_Menu NewParentMenu )
{
    super.Initialize( NewParentMenu );
    StartMenu = KFGFxMenu_StartGame( NewParentMenu );
	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
    LocalizeMenu();
    SetWhatsNewItems();

    if( class'KFGameEngine'.static.IsSoloPlayDisabled())
    {
        DisableSoloButton();
    }
}

function DisableSoloButton()
{
    local GFxObject SoloButton;

    SoloButton = GetObject("soloOfflineButton");
    if(SoloButton != none)
    {
        SoloButton.SetBool("enabled", false);
    }
}

function CheckNewsState()
{
	if (Class'WorldInfo'.Static.IsConsoleBuild(CONSOLE_Orbis) && OnlineSub != none)
	{
		if (OnlineSub.IsGameOwned() && bTrialNewsActive)
		{
			SetWhatsNewItems();
		}
	}
}

function SetWhatsNewItems()
{
    local GFxObject DataObject;
    local GFxObject DataArray;
	local GFxObject WhatsNewButton;
    local int i, index;
	local bool bLoggedIn;

	WhatsNewButton = GetObject( "whatsNewButton" );

    DataArray = CreateArray();
    if(Class'WorldInfo'.Static.IsConsoleBuild())
    {
		bLoggedIn = OnlineSub.PlayerInterface.GetLoginStatus( GetLP().ControllerId ) == LS_LoggedIn;
		PS4ActiveWhatsNewItems.Length = 0;

		WhatsNewButton.SetVisible( bLoggedIn && OnlineSub.CanCheckFreeTrialState());
																		//if we don't own the game, show the buy the game news item
		if (Class'WorldInfo'.Static.IsConsoleBuild(CONSOLE_Orbis) && !OnlineSub.IsGameOwned())
		{
			bTrialNewsActive = true;
			for (i = 0; i < PS4WhatsNewItemsFreeTrial.length; i++)
			{
				// Only show store items if we are logged in
				DataObject = CreateObject("Object");
				DataObject.SetString("label", Localize("WhatsNewMessages", PS4WhatsNewItemsFreeTrial[i].TextField, "KFGame"));
				DataObject.SetString("imageURL", PS4WhatsNewItemsFreeTrial[i].ImageURL);
				DataObject.SetString("redirectURL", "OpenStore");
				DataArray.SetElementObject(PS4ActiveWhatsNewItems.Length, DataObject);
				PS4ActiveWhatsNewItems.AddItem(PS4WhatsNewItemsFreeTrial[i]);
			}
		}
		else
		{
			bTrialNewsActive = false;
			for (i = 0; i < PS4WhatsNewItems.length; i++)
			{

				// When Summer Sideshow is off, we don't want to link to the time limited SS item.
				if (class'KFGameEngine'.static.GetSeasonalEventId() == 0)
				{
					if (PS4WhatsNewItems[i].TextField == "FeaturedEventItem")
					{
						continue;
					}
				}

				// Only show store items if we are logged in
				if (bLoggedIn || PS4WhatsNewItems[i].PSNProductId == "")
				{
					DataObject = CreateObject("Object");
					DataObject.SetString("label", Localize("WhatsNewMessages", PS4WhatsNewItems[i].TextField, "KFGame"));
					DataObject.SetString("imageURL", PS4WhatsNewItems[i].ImageURL);
					DataObject.SetString("redirectURL", PS4WhatsNewItems[i].RedirectURL);
					DataArray.SetElementObject(PS4ActiveWhatsNewItems.Length, DataObject);
					PS4ActiveWhatsNewItems.AddItem(PS4WhatsNewItems[i]);
				}
			}
		}
        
    }
    else
    {
        index = 0;
        for (i = 0; i < WhatsNewItems.length; i++)
        {
            if (class'WorldInfo'.static.isEosBuild() && WhatsNewItems[i].TextField == "Jaegorhorn") continue; 
			if (!class'WorldInfo'.static.isEosBuild() && WhatsNewItems[i].TextField == "PS4Key") continue;
            DataObject = CreateObject("Object");
            DataObject.SetString("label", Localize("WhatsNewMessages",WhatsNewItems[i].TextField,"KFGame"));
            DataObject.SetString("imageURL",WhatsNewItems[i].ImageURL);
            DataObject.SetString("redirectURL",WhatsNewItems[i].RedirectURL);
            DataArray.SetElementObject(index++, DataObject);
        }
    }
    
    SetObject("whatsNew", DataArray);
}

function LocalizeMenu()
{
    local GFxObject TextObject;
    TextObject = CreateObject("Object");
    // Localize static text
    TextObject.SetString("home",StartMenu.FindGameString);  
    TextObject.SetString("multiplayer",MultiplayerString);  
	TextObject.SetString("createGame", CreateGameString);
	
	TextObject.SetString("news", StartMenu.NewsPageString);
    TextObject.SetString("serverBrowser",StartMenu.ServerBrowserString);    
    TextObject.SetString("solo",SoloString);    
    TextObject.SetString("tutorial",TutorialString);
    SetObject("localizedText", TextObject);
}

DefaultProperties
{
// Latest Update
    WhatsNewItems.Add((ImageURL="img://UI_WhatsNew.UI_WhatsNew_Halloween_InfernalInsurrection_Event", Textfield="LatestUpdate", RedirectURL="http://www.tripwireinteractive.com/redirect/KF2LatestUpdate/")) 
// Featured Time Limited Item
      WhatsNewItems.Add((ImageURL="img://UI_WhatsNew.UI_WhatsNew_Halloween_PremiumTicket", Textfield="FeaturedEventItem", RedirectURL="https://store.steampowered.com/buyitem/232090/4928"))
// Featured Weapon Skin Bundle
    WhatsNewItems.Add((ImageURL="img://UI_WhatsNew.UI_WhatsNew_Fall_JaegerMKIII", Textfield="FeaturedItemBundle", RedirectURL="https://store.steampowered.com/buyitem/232090/8464"))
// Featured Cosmetic Bundle
    WhatsNewItems.Add((ImageURL="img://UI_WhatsNew.UI_WhatsNew_Apocalypse", Textfield="FeaturedItemBundle", RedirectURL="https://store.steampowered.com/buyitem/232090/8465"))
// Featured Cosmetic Bundle
    WhatsNewItems.Add((ImageURL="img://UI_WhatsNew.UI_WhatsNew_WW1", Textfield="FeaturedItemBundle", RedirectURL="https://store.steampowered.com/buyitem/232090/8466"))
// Featured Weapon Bundle
    WhatsNewItems.Add((ImageURL="img://UI_WhatsNew.UI_WhatsNew_Fall_Minigun", Textfield="FeaturedItemBundle", RedirectURL="https://store.steampowered.com/buyitem/232090/8467"))
// Featured Weapon Bundle
    WhatsNewItems.Add((ImageURL="img://UI_WhatsNew.UI_WhatsNew_Fall_MineReconstructor", Textfield="FeaturedItemBundle", RedirectURL="https://store.steampowered.com/buyitem/232090/8468"))
// Featured Weapon Bundle
    WhatsNewItems.Add((ImageURL="img://UI_WhatsNew.UI_WhatsNew_Fall_InfernalInsurrection_Bundle", Textfield="FeaturedItemBundle", RedirectURL="https://store.steampowered.com/buyitem/232090/8469"))
// Featured Cosmetic Bundle
    WhatsNewItems.Add((ImageURL="img://UI_WhatsNew.UI_WhatsNew_Halloween_FullGearInfernalInsurrection", Textfield="FeaturedItemBundle", RedirectURL="https://store.steampowered.com/buyitem/232090/8463"))
// Featured Outfit Bundle
    WhatsNewItems.Add((ImageURL="img://UI_WhatsNew.UI_WhatsNew_Fall_ReaperOutfit", Textfield="FeaturedItemBundle", RedirectURL="https://store.steampowered.com/buyitem/232090/8462"))
// Epic Horzine key
	WhatsNewItems.Add((ImageURL="img://UI_WhatsNew_PS4.UI_WhatsNew_PS4Key", Textfield="PS4Key", RedirectURL="https://store.steampowered.com/buyitem/232090/4303"))

// Misc Community Links
    WhatsNewItems.Add((ImageURL="img://UI_WhatsNew.UI_WhatsNew_CommunityHub", Textfield="Jaegorhorn", RedirectURL="https://steamcommunity.com/app/232090"))    
    WhatsNewItems.Add((ImageURL="img://UI_WhatsNew.UI_WhatsNew_CommunityForums", Textfield="Forums", RedirectURL="http://forums.tripwireinteractive.com/"))
    WhatsNewItems.Add((ImageURL="img://UI_WhatsNew.UI_WhatsNew_Survey", Textfield="Survey", RedirectURL="http://www.tripwireinteractive.com/redirect/KF2Survey/"))
    WhatsNewItems.Add((ImageURL="img://UI_WhatsNew.UI_WhatsNew_CommunityIssue", Textfield="CommunityTracker", RedirectURL="https://trello.com/b/ZOwMRlcW/killing-floor-2-community-issue-roadmap"))
    WhatsNewItems.Add((ImageURL="img://UI_WhatsNew.UI_WhatsNew_Merch", Textfield="Merch", RedirectURL="http://www.tripwireinteractive.com/redirect/shop/"))
    WhatsNewItems.Add((ImageURL="img://UI_WhatsNew_PS4.UI_WhatsNew_KFUncovered", Textfield="Uncovered", RedirectURL="https://www.youtube.com/watch?v=fTdfedt9B48/"))
}
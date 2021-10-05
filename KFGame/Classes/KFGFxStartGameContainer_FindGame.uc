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
    /** Used for those entitlements which does not have a "linked" Playfab item (like Armory Season Pass 2021)*/
	var bool bPlayfabItemPairedUp;

    structdefaultproperties
   {
      bPlayfabItemPairedUp=true
   }
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
    FillWhatsNew();
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
            `log("label"@WhatsNewItems[i].TextField);
            DataObject.SetString("imageURL",WhatsNewItems[i].ImageURL);
            `log("imageURL"@WhatsNewItems[i].ImageURL);
            DataObject.SetString("redirectURL",WhatsNewItems[i].RedirectURL);
            `log("redirectURL"@WhatsNewItems[i].RedirectURL);
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

function FillWhatsNew()
{
    local SWhatsNew item;
    WhatsNewItems.Remove(0, WhatsNewItems.Length);
// Latest Update
    item = SetWhatsNewItem("img://UI_WhatsNew.UI_WhatsNew_Halloween_DayOfTheZED_Event", "LatestUpdate", "http://www.tripwireinteractive.com/redirect/KF2LatestUpdate/");
    WhatsNewItems.AddItem(item);
// KF2 Armory Season Pass 2021
    item = SetWhatsNewItem("img://UI_WhatsNew.UI_WhatsNew_Spring_Armory_Season_Pass", "ArmorySeasonPass", "https://store.steampowered.com/app/1524820/Killing_Floor_2__Armory_Season_Pass");
    WhatsNewItems.AddItem(item);
// Featured Time Limited Item
    item = SetWhatsNewItem("img://UI_WhatsNew.UI_WhatsNew_Halloween_PremiumTicket", "FeaturedEventItem", "https://store.steampowered.com/buyitem/232090/4928");
    WhatsNewItems.AddItem(item);
// Featured Full Gear
    item=SetWhatsNewItem("img://UI_WhatsNew.UI_WhatsNew_Halloween_FullGearBundle_DoZ", "FeaturedItemBundle", "https://store.steampowered.com/buyitem/232090/9119");
    WhatsNewItems.AddItem(item);
// Featured Cosmetic Bundle
    item = SetWhatsNewItem("img://UI_WhatsNew.UI_WhatsNew_Halloween_DoZ_Cosmetics", "FeaturedItemBundle", "https://store.steampowered.com/buyitem/232090/9120");
    WhatsNewItems.AddItem(item);
// Featured Weapon Skin Bundle
    item = SetWhatsNewItem("img://UI_WhatsNew.UI_WhatsNew_Halloween_Hellmark", "FeaturedItemBundle", "https://store.steampowered.com/buyitem/232090/9121");
    WhatsNewItems.AddItem(item);
// Featured Cosmetic Bundle
    item = SetWhatsNewItem("img://UI_WhatsNew.UI_WhatsNew_Halloween_Vietnam","FeaturedItemBundle","https://store.steampowered.com/buyitem/232090/9122");
    WhatsNewItems.AddItem(item);
// Featured Weapon Bundle
    item = SetWhatsNewItem("img://UI_WhatsNew.UI_WhatsNew_Halloween_PiranhaPistol", "FeaturedItemBundle", "https://store.steampowered.com/buyitem/232090/9123");
    WhatsNewItems.AddItem(item);
// Featured Weapon Bundle
    item=SetWhatsNewItem("img://UI_WhatsNew.UI_WhatsNew_Halloween_CorrupterCarbine", "FeaturedItemBundle", "https://store.steampowered.com/buyitem/232090/9124");
    WhatsNewItems.AddItem(item);
// Featured Weapon Bundle
    item=SetWhatsNewItem("img://UI_WhatsNew.UI_WhatsNew_halloween_Weaponsbundle", "FeaturedItemBundle", "https://store.steampowered.com/buyitem/232090/9125");
    WhatsNewItems.AddItem(item);
// Misc Community Links
    item=SetWhatsNewItem("img://UI_WhatsNew.UI_WhatsNew_CommunityHub", "Jaegorhorn", "https://steamcommunity.com/app/232090");
    WhatsNewItems.AddItem(item);
    item=SetWhatsNewItem("img://UI_WhatsNew.UI_WhatsNew_CommunityForums", "Forums", "http://forums.tripwireinteractive.com/");
    WhatsNewItems.AddItem(item);
    item=SetWhatsNewItem("img://UI_WhatsNew.UI_WhatsNew_Survey", "Survey", "http://www.tripwireinteractive.com/redirect/KF2Survey/");
    WhatsNewItems.AddItem(item);
    item=SetWhatsNewItem("img://UI_WhatsNew.UI_WhatsNew_CommunityIssue", "CommunityTracker", "http://www.killingfloor2.com/roadmap");
    WhatsNewItems.AddItem(item);
    item=SetWhatsNewItem("img://UI_WhatsNew.UI_WhatsNew_Merch", "Merch", "http://www.tripwireinteractive.com/redirect/shop/");
    WhatsNewItems.AddItem(item);
    item=SetWhatsNewItem("img://UI_WhatsNew_PS4.UI_WhatsNew_KFUncovered", "Uncovered", "https://www.youtube.com/watch?v=fTdfedt9B48/");
    WhatsNewItems.AddItem(item);

}

function SWhatsNew  SetWhatsNewItem(string image, string TextField, string URL)
{
    local SWhatsNew item;
    item.ImageURL = image;
    item.Textfield = TextField;
    item.RedirectURL = URL;
    
    return item;
}

DefaultProperties
{
}
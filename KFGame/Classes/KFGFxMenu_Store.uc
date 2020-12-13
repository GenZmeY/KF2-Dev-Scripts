//=============================================================================
// KFGFxMenu_Store
//=============================================================================
// 
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  Zane Gholson -  09/17/2015
//=============================================================================

class KFGFxMenu_Store extends KFGFxObject_Menu
	native(UI);

`include(KFProfileSettings.uci)

var localized string ExitKF2;

/** Caches a local reference to the online subsystem */
var OnlineSubsystem				OnlineSub;

var KFGFxStoreContainer_Main 	MainContainer;
var KFGFxStoreContainer_Details DetailsContainer;
var KFGFxStoreContainer_Cart	CartContainer;

var GFxObject AddCartButton;

struct StoreItem
{
	var int 	SKU;
	var string 	ItemDesciption;
	var string 	IconLocation;
	var string 	ItemName;
	var float 	ItemPrice;
	var name 	ItemType;
};

var localized string StoreString;

enum ETitleStoreIconLocation
{
	ETSIL_BottomLeft,
	ETSIL_BottomCenter,
	ETSIL_BottomRight
};

native function bool ShowSystemStoreIcon(ETitleStoreIconLocation location);
native function bool HideSystemStoreIcon();

function InitializeMenu( KFGFxMoviePlayer_Manager InManager )
{
	super.InitializeMenu( InManager );

	LocalizeText();
	OnlineSub =  Class'GameEngine'.static.GetOnlineSubsystem();

	if( class'WorldInfo'.static.IsConsoleBuild() || class'WorldInfo'.static.IsEOSBuild() )
	{
		class'GameEngine'.static.GetPlayfabInterface().AddInventoryReadCompleteDelegate( OnReadPlayfabInventoryComplete );
	}
	else if( OnlineSub != none )
	{
		OnlineSub.AddOnInventoryReadCompleteDelegate(OnInventoryReadComplete);
	}
}

function OnOpen()
{
	local KFProfileSettings ProfileSettings;
	local bool bHasTabbedToStore;

	if( class'WorldInfo'.static.IsConsoleBuild( CONSOLE_Orbis ) )
	{
		CheckForEmptyStore();
	}

	if( class'WorldInfo'.static.IsConsoleBuild() || class'WorldInfo'.static.IsEOSBuild() )
	{
		class'GameEngine'.static.GetPlayfabInterface().AddInventoryReadCompleteDelegate( OnReadPlayfabInventoryComplete );
	}
	else if( OnlineSub != none )
	{
		OnlineSub.AddOnInventoryReadCompleteDelegate(OnInventoryReadComplete);
	}
	
	ProfileSettings = Manager.CachedProfile;
	bHasTabbedToStore = ProfileSettings != none ? ProfileSettings.GetProfileInt(KFID_HasTabbedToStore) != 0 : false;
	if( Class'KFGameEngine'.static.IsSalesEventActive() && ProfileSettings != none && !bHasTabbedToStore )
	{
		ProfileSettings.SetProfileSettingValueInt(KFID_HasTabbedToStore, 1);
	}
	else if( !Class'KFGameEngine'.static.IsSalesEventActive() && Class'KFGameEngine'.static.IsSalesEventChecked() && ProfileSettings != none )
	{
		ProfileSettings.SetProfileSettingValueInt(KFID_HasTabbedToStore, 0);
	}

	RefreshItemList();

//	ShowSystemStoreIcon(ETSIL_BottomCenter);
}

function OnClose()
{
	if( class'WorldInfo'.static.IsConsoleBuild() || class'WorldInfo'.static.IsEOSBuild() )
	{
		class'GameEngine'.static.GetPlayfabInterface().ClearInventoryReadCompleteDelegate( OnReadPlayfabInventoryComplete );
	}
	else if( OnlineSub != none )
	{
		OnlineSub.ClearOnInventoryReadCompleteDelegate(OnInventoryReadComplete);
	}

//	HideSystemStoreIcon();
}

function OnInventoryReadComplete()
{
	RefreshItemList();
}

function OnReadPlayfabInventoryComplete( bool bSuccess )
{
	if( bSuccess )
	{
		RefreshItemList();
	}
	else
	{
		Manager.DelayedOpenPopup(ENotification, EDPPID_Misc, class'KFCommon_LocalizedStrings'.default.NoticeString, class'KFCommon_LocalizedStrings'.default.FailedToReachInventoryServerString, class'KFCommon_LocalizedStrings'.default.OKString);
	}
}

function RefreshItemList()
{
	if(MainContainer != none)
	{
		MainContainer.SendItems(OnlineSub.ItemPropertiesList);
	}
}

function LocalizeText()
{
	local GFxObject LocalizedObject;

	LocalizedObject = CreateObject( "Object" );
	
	LocalizedObject.SetString("store", class'WorldInfo'.static.IsConsoleBuild(CONSOLE_Durango) ? ConsoleLocalize("StoreStringXB1") : StoreString); 

	SetObject("localizedText", LocalizedObject);
}

event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{

	switch(WidgetName)
	{		
		case ('storeMainContainer'):
			if ( MainContainer == none )
			{
			    MainContainer = KFGFxStoreContainer_Main(Widget);
				MainContainer.Initialize( self );
				MainContainer.SendItems(OnlineSub.ItemPropertiesList);
		    }
         break;
        case ('storeCart'):
			if ( CartContainer == none )
			{
			    CartContainer = KFGFxStoreContainer_Cart(Widget);
				CartContainer.Initialize( self );
		    }
         break;
        case ('itemDetails'):
			if ( DetailsContainer == none )
			{
			    DetailsContainer = KFGFxStoreContainer_Details(Widget);
				DetailsContainer.Initialize( self );
				AddCartButton = DetailsContainer.GetObject("addCartButton");
		    }
         break;
    }

    return true;
}

function Callback_StoreSectionChanged(int FilterIndex)
{
	MainContainer.UpdateFilter(FilterIndex); 
}

function Callback_AddToCartClicked(int ItemSKU)
{
	local ItemProperties StoreItemDetails;

	if (OnlineSub != none)
	{
		StoreItemDetails = OnlineSub.ItemPropertiesList[OnlineSub.ItemPropertiesList.Find('Definition', ItemSKU)];

		if (class'WorldInfo'.static.IsConsoleBuild())
		{
			if (StoreItemDetails.SignedOfferId != "")
			{
				if (class'WorldInfo'.static.IsConsoleBuild(CONSOLE_Durango))
				{
					OnlineSub.PlayerInterfaceEx.ShowProductDetailsUI(GetLP().ControllerId, StoreItemDetails.ProductID);
				}
				else
				{
					OnlineSub.OpenMarketPlaceSearch(StoreItemDetails);
				}
			}
		}
		else if (StoreItemDetails.Price == "")
		{
			OnlineSub.OpenMarketPlaceSearch(StoreItemDetails);
		}
		else
		{
			OnlineSub.OpenItemPurchaseOverlay(ItemSKU);
		}
	}
}


function CallBack_ItemDetailsClicked(int ItemDefinition)
{
	local ItemProperties StoreItemDetails;
	
	StoreItemDetails = OnlineSub.ItemPropertiesList[OnlineSub.ItemPropertiesList.Find('Definition', ItemDefinition)];
	if(StoreItemDetails.Price == "")
	{
		AddCartButton.SetString("label", class'KFGFxStoreContainer_Details'.default.LookUpOnMarketString);
	}
	else
	{
		AddCartButton.SetString("label", class'KFGFxStoreContainer_Details'.default.AddToCartString@StoreItemDetails.Price );
	}
	SetObject("storeItemDetails", CreateStoreItem(StoreItemDetails));

	//@SABER_EGS_BEGIN
	if ( class'WorldInfo'.static.IsEOSBuild())
	{
		// Ownded durable items marked with special price "double space" or empty price		
		AddCartButton.SetVisible(StoreItemDetails.Price != "  " && StoreItemDetails.Price != "");
	}
	//@SABER_EGS_END

	if( class'WorldInfo'.static.IsConsoleBuild() )
	{
		if (StoreItemDetails.Price != "")
		{
			AddCartButton.SetString("label", class'KFGFxStoreContainer_Details'.default.AddToCartString);
			AddCartButton.SetVisible(true);
		}
		else
		{
			AddCartButton.SetString("label", "");
			AddCartButton.SetVisible(false);
		}
	}
}

function GFxObject CreateStoreItem(ItemProperties DesiredStoreItem)
{
	local GFxObject DataObject;

	DataObject = CreateObject( "Object" );
				
	DataObject.SetString("label", DesiredStoreItem.Name);
	DataObject.SetString("description", DesiredStoreItem.Description);
	DataObject.SetString("price", class'WorldInfo'.static.IsConsoleBuild() ? "" : DesiredStoreItem.Price);
	DataObject.SetString("imageURL", "img://"$DesiredStoreItem.IconURL);
	DataObject.SetString("imageURLLarge", "img://"$DesiredStoreItem.IconURLLarge);
	DataObject.SetInt("SKU", DesiredStoreItem.Definition);

	return DataObject;
}


function CheckForEmptyStore()
{
	local int i;

	// Check existing inventory for at least one PSN item. If none exist, throw up empty store dialog
	for( i = 0; i < OnlineSub.ItemPropertiesList.Length; i++ )
	{
		if( OnlineSub.ItemPropertiesList[i].SignedOfferId != "" )
		{
			return;
		}
	}

	// Only show this message if the player is logged in
	if( OnlineSub.PlayerInterface.GetLoginStatus(0) == LS_LoggedIn )
	{
		// 0 is code for SCE_MSG_DIALOG_SYSMSG_TYPE_TRC_EMPTY_STORE
		OnlineSub.PlayerInterfaceEx.ShowCustomErrorUI(0);
	}
}



defaultproperties
{
	SubWidgetBindings.Add((WidgetName="itemDetails",WidgetClass=class'KFGFxStoreContainer_Details'))
	SubWidgetBindings.Add((WidgetName="storeCart",WidgetClass=class'KFGFxStoreContainer_Cart'))
	SubWidgetBindings.Add((WidgetName="storeMainContainer",WidgetClass=class'KFGFxStoreContainer_Main'))
}
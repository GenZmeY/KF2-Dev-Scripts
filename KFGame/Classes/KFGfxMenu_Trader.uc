//=============================================================================
// KFGFxMenu_Trader
//=============================================================================
// This is the manager class for the trader menu and has access to all the
// different KFGFxTraderComp_ classes. It receives all the calls from
// actionscript and tells the components accordingly. The array, "OwnedItemList"
// is a local list of all the ammo and items that our player has bought, sold
// or already owend. Upon closing the menu, this class will tell the server
// to update the player with the final items
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Greg Felber 8/6/2013
//=============================================================================

class KFGFxMenu_Trader extends KFGFxObject_Menu
	config(Game)
	DependsOn(KFGFxObject_TraderItems)
	native(UI);

`include(KFProfileSettings.uci)

enum EItemType
{
  	EIT_Weapon,
  	EIT_Armor,
  	EIT_NonSellable,
  	EIT_Grenade,
};

struct native SItemInformation
{
	/** True if this item is being used to hold secondary ammo info */
	var bool bIsSecondaryAmmo;
    /** Holds the final values for the owned item */
	var int SpareAmmoCount, MaxSpareAmmo, MaxSecondaryAmmo, SellPrice, SecondaryAmmoCount;
	var int MagazineCapacity;
	/** The dosh built up during an autofill for this item */
	var int AutoFillDosh, AmmoPricePerMagazine;
	/** Holds trader and default weapon information such as prices and stats */
	var STraderItem DefaultItem;

	var int ItemUpgradeLevel;

	StructDefaultProperties
	{
		ItemUpgradeLevel=0;
	}
};

var KFPlayerController MyKFPC;
var KFPlayerReplicationInfo MyKFPRI;
var KFInventoryManager MyKFIM;

var KFGFxTraderContainer_GameInfo GameInfoContainer; 	// Controls the timer, wave count and close button
var KFGFxTraderContainer_Filter FilterContainer;  // The filter list
var KFGFxTraderContainer_Store ShopContainer; // Items to buy
var KFGFxTraderContainer_PlayerInventory PlayerInventoryContainer; // Items you own
var KFGFxTraderContainer_PlayerInfo PlayerInfoContainer; // Your character info
var KFGFxTraderContainer_ItemDetails ItemDetails; // The center pane with weapon info
var KFGFxTraderContainer_ErrorMessage ErrorMessageContainer;

var bool bGenericItemSelected; //used to keep track of the state of the details menu in between opening and closing menu
var STraderItem LastDefaultItemInfo;
var SItemInformation LastItemInfo;

var localized string ExitMenuString;

var int PrevArmor;

// This exists to tell us whether our selected index is for the shop or the players inventory
enum TraderList
{
    TL_Shop,
    TL_Player
};

enum TabIndices
{
    TI_Perks,
    TI_Type,
    TI_Favorites,
    TI_All,
};

var TabIndices CurrentTab;

var int CurrentFilterIndex;

/** The selected list determines if we are buying or selling a currently selected item */
var byte SelectedList;
/** An items index ine either our inventory or the shopps the list*/
var byte SelectedItemIndex;

/** Stores the class name of every item we've favorited into kfgame.ini */
var array<name> FavoritedItems;

/** This tells us if we are able to buy or sell the currently selected item */
var bool bCanBuyOrSellItem;

var KFPerk LastPerkClass;

var array<SItemInformation> OwnedItemList;

//==============================================================
// Initialization
//==============================================================
function InitializeMenu( KFGFxMoviePlayer_Manager InManager )
{
	super.InitializeMenu(InManager);

	SetString("exitMenuString", ExitMenuString);
	SetString("exitPromptString", ExitMenuString);
	SetString("backPromptString",Localize("KFGFxWidget_ButtonPrompt","CancelString","KFGame"));
	LocalizeText();
}

function OnR3Pressed()
{
	//do nothing (handled via AS3)
}

function LocalizeText()
{
	local GFxObject TextObject;

	TextObject = CreateObject("Object");

	TextObject.SetString("favoriteString"	, 	Class'KFGFxTraderContainer_ItemDetails'.default.FavoriteString);
	TextObject.SetString("unFavoriteString"	, 	Class'KFGFxTraderContainer_ItemDetails'.default.UnfavoriteString);
	TextObject.SetString("changePerkString"	, 	Class'KFGFxTraderContainer_PlayerInventory'.default.ChangePerkString);
	//TextObject.SetString("autoTradeString"	, 	Omelette Du Fromage); //not used at the moment
	TextObject.SetString("selectString"		, 	Class'KFGFxWidget_ButtonPrompt'.default.ConfirmString);
	TextObject.SetString("autoFillString"		, 	Class'KFGFxTraderContainer_PlayerInventory'.default.AutoFillString);
	TextObject.SetString("upgradeString"	,	Class'KFGFxTraderContainer_ItemDetails'.default.UpgradeString);

	SetObject("localizeCentralPrompts", TextObject);
}

function OnOpen()
{
	local int i;
	local name weaponName;

	MyKFPC = KFPlayerController ( GetPC() );

	if (MyKFPC == none)
	{
		return;
	}

	MyKFPC.GetPurchaseHelper().Initialize();

	MyKFPRI = KFPlayerReplicationInfo( GetPC().PlayerReplicationInfo );
    MyKFIM = KFInventoryManager( GetPC().Pawn.InvManager );

    CurrentTab = TI_Perks;
    CurrentFilterIndex = GetPerkIndex();

	FavoritedItems.Remove(0, FavoritedItems.Length);
	for(i = 0; i < MyKFPC.MyGFxManager.CachedProfile.FavoriteWeapons.Length; ++i)
	{
		weaponName  = name(MyKFPC.MyGFxManager.CachedProfile.FavoriteWeapons[i]);
		FavoritedItems.AddItem( weaponName );
	}

	if( MyKFPC.Pawn != none || MyKFPC.PlayerReplicationInfo != none )
	{
		MyKFPC.CloseTraderMenu();
	}

	RefreshItemComponents(true);

	if( PlayerInventoryContainer != none )
	{
		PlayerInventoryContainer.UpdateLock();
	}

	if ( ShopContainer != None )
	{
		ShopContainer.OnTraderReopened();
	}

	MyKFPC.bClientTraderMenuOpen = true;
	UpdatePlayerInfo();
}

/** Ties the GFxClikWidget variables to the .swf components and handles events */
event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
	// `log("Trader Widget: " @WidgetName @" : " @WidgetPath);

	switch(WidgetName)
	{
		case ('gameInfoContainer'):
			if( GameInfoContainer == none )
			{
			    GameInfoContainer = KFGFxTraderContainer_GameInfo( Widget );
			    GameInfoContainer.Initialize( self );
	  			GameInfoContainer.SetDosh(MyKFPC.GetPurchaseHelper().TotalDosh);
	  			GameInfoContainer.SetCurrentWeight(MyKFPC.GetPurchaseHelper().TotalBlocks, MyKFPC.GetPurchaseHelper().MaxBlocks);
		    }
   		break;
		case ('filterContainer'):
			if( FilterContainer == none )
			{
			    FilterContainer = KFGFxTraderContainer_Filter( Widget );
			    FilterContainer.SetTabsData();
		    }
        break;
		case ('shopContainer'):
			if( ShopContainer == none )
			{
			    ShopContainer = KFGFxTraderContainer_Store( Widget );
			    ShopContainer.Initialize( self );
			    CurrentTab = TI_Perks;
			    CurrentFilterIndex = GetPerkIndex();
				RefreshShopItemList( TI_Perks,  CurrentFilterIndex );
		    }
		break;
		case ('playerInventoryContainer'):
			if( PlayerInventoryContainer == none )
			{
			    PlayerInventoryContainer = KFGFxTraderContainer_PlayerInventory( Widget );
   			    PlayerInventoryContainer.Initialize( self );
			    PlayerInventoryContainer.RefreshPlayerInventory();
		    }
		break;
		case ('playerInfoContainer'):
			if( PlayerInfoContainer == none )
			{
				PlayerInfoContainer = KFGFxTraderContainer_PlayerInfo( Widget );
   			    PlayerInfoContainer.Initialize( self );
			}
		break;
		case ('itemDetailsContainer'):
			if( ItemDetails == none )
			{
			    ItemDetails = KFGFxTraderContainer_ItemDetails( Widget );
			    ItemDetails.Initialize( self );
		    }
		break;
		case ('errorMessage'):
			if (ErrorMessageContainer == none)
			{
				ErrorMessageContainer = KFGFxTraderContainer_ErrorMessage(Widget);
				ErrorMessageContainer.Initialize(self);
			}
		break;
	}

	return true;
}

function int GetPerkIndex()
{
	return MyKFPC.PerkList.Find('PerkClass', MyKFPC.CurrentPerk.Class);
}

//==============================================================
// Closing
//==============================================================

event OnClose()
{
	MyKFIM.ServerCloseTraderMenu();
	if(MyKFPC.MyGFxHUD.WeaponSelectWidget != none)
	{
		MyKFPC.MyGFxHUD.WeaponSelectWidget.RefreshWeaponSelect();
	}

    OwnedItemList.length = 0;
	MyKFPC.GetPurchaseHelper().TotalDosh = 0;
	super.OnClose();

	MyKFPC.bClientTraderMenuOpen = false;
}

//==============================================================
// Trader Functions
//==============================================================
function OneSecondLoop()
{
	local KFPawn_Human KFP;

	if( GameInfoContainer != none )
	{
	 	GameInfoContainer.UpdateTraderTimer();
	}

	// update armor amount if pawn gains armor while in trader (e.g. from medic heal skills)
	KFP = KFPawn_Human( MyKFPC.Pawn );
	if( KFP != none && PrevArmor != KFP.Armor )
	{
		MyKFPC.GetPurchaseHelper().ArmorItem.SpareAmmoCount = KFP.Armor;
		PrevArmor = KFP.Armor;

		RefreshItemComponents();
	}
}

function UpdatePlayerInfo()
{
	if( MyKFPC != none && PlayerInfoContainer != none )
	{
		PlayerInfoContainer.SetPerkInfo();
		PlayerInfoContainer.SetPerkList();
		if(LastPerkClass != MyKFPC.CurrentPerk)
		{
			LastPerkClass = MyKFPC.CurrentPerk;
			OnPerkChanged(GetPerkIndex());
		}

		RefreshItemComponents();
	}
}

/** Called when we have been given a weapon while in the trader menu */
function GiveExternalWeapon(KFWeapon KFW)
{
	local int i;

	// Check if we own this weapon
	for ( i = 0; i < OwnedItemList.Length; i++ )
	{
		if( OwnedItemList[i].DefaultItem.ClassName == KFW.class.name )
		{
			return;
		}
	}

	// Only add the item to our owned list if we have the capacity to carry it
	if( MyKFPC.GetPurchaseHelper().TotalBlocks + KFW.GetModifiedWeightValue() > MyKFPC.GetPurchaseHelper().MaxBlocks )
	{
		if( MyKFPC.Pawn != none )
		{
			// Throw it if we can't carry
			MyKFPC.Pawn.TossInventory(KFW);
		}
	}
	else
	{
		MyKFPC.GetPurchaseHelper().AddBlocks(KFW.GetModifiedWeightValue());
		MyKFPC.GetPurchaseHelper().SetWeaponInformation(KFW);
		RefreshItemComponents();
	}
}

//==============================================================
// Item details updates
//==============================================================

function SetTraderItemDetails(int ItemIndex)
{
	local STraderItem SelectedItem;
	local bool bCanAfford, bCanBuyItem, bCanCarry;
	SelectedList = TL_Shop;
    if (ItemDetails != none && ShopContainer != none)
    {
    	if (MyKFPC.GetPurchaseHelper().TraderItems.SaleItems.length >= 0 && ItemIndex < MyKFPC.GetPurchaseHelper().TraderItems.SaleItems.length)
    	{
			SelectedItemIndex = ItemIndex;
			SelectedItem = MyKFPC.GetPurchaseHelper().TraderItems.SaleItems[ItemIndex];

			bCanAfford = MyKFPC.GetPurchaseHelper().GetCanAfford( MyKFPC.GetPurchaseHelper().GetAdjustedBuyPriceFor(SelectedItem) );
			bCanCarry = MyKFPC.GetPurchaseHelper().CanCarry( SelectedItem );

			if (!bCanAfford || !bCanCarry)
			{
				
				bCanBuyItem = false;
			}
			else
			{
				bCanBuyItem = true;
			}

			PurchaseError(!bCanAfford, !bCanCarry);

			ItemDetails.SetShopItemDetails(SelectedItem, MyKFPC.GetPurchaseHelper().GetAdjustedBuyPriceFor(SelectedItem), bCanCarry, bCanBuyItem);
			bCanBuyOrSellItem = bCanBuyItem;
		}
		else
		{
			ItemDetails.SetVisible(false);
		}
	}
}

function SetPlayerItemDetails(int ItemIndex)
{
	local STraderItem SelectedItem;

	SelectedList = TL_Player;
    if( ItemDetails != none && ItemIndex < OwnedItemList.length)
    {
    	bGenericItemSelected = false;
		SelectedItemIndex = ItemIndex;
		SelectedItem = OwnedItemList[ItemIndex].DefaultItem;
		ItemDetails.SetPlayerItemDetails(SelectedItem, OwnedItemList[ItemIndex].SellPrice, OwnedItemList[ItemIndex].ItemUpgradeLevel);
		bCanBuyOrSellItem = MyKFPC.GetPurchaseHelper().IsSellable(SelectedItem);
		PurchaseError(false, false);//clear it
	}
}

function SetGenericItemDetails(out STraderItem DefaultItemInfo, out SItemInformation ItemInfo)
{
	SelectedList = TL_Player;
    if( ItemDetails != none )
    {
    	LastItemInfo = ItemInfo;
    	LastDefaultItemInfo = DefaultItemInfo;
    	bGenericItemSelected = true;
		//SelectedItemIndex = ItemIndex;
		ItemDetails.SetPlayerItemDetails(DefaultItemInfo, ItemInfo.SellPrice, INDEX_NONE);
		bCanBuyOrSellItem = MyKFPC.GetPurchaseHelper().IsSellable(DefaultItemInfo);
	}
}

/** Decrement the SelectedItemIndex if we bought or sold the last item in its list */
function SetNewSelectedIndex(int ListLength)
{
	if (SelectedItemIndex >= ListLength)
	{
		if (SelectedItemIndex != 0)
		{
    		SelectedItemIndex--;
		}
	}
}

//==============================================================
// Inventory Update Functions - Buying Weapons and Ammo
//==============================================================
function OnPerkChanged(int PerkIndex)
{
	if(CurrentTab == TI_Perks)
	{
		CurrentFilterIndex = PerkIndex;
		RefreshShopItemList(CurrentTab, CurrentFilterIndex);
	}
}

function RefreshItemComponents(optional bool bInitOwnedItems=false)
{
    if( PlayerInventoryContainer != none && PlayerInfoContainer != none )
    {
    	if(bInitOwnedItems)
    	{
    		MyKFPC.GetPurchaseHelper().InitializeOwnedItemList();
    	}
    	OwnedItemList = MyKFPC.GetPurchaseHelper().OwnedItemList;
	    PlayerInventoryContainer.RefreshPlayerInventory();
	    RefreshShopItemList(CurrentTab, CurrentFilterIndex);
	  	GameInfoContainer.UpdateGameInfo();
	  	GameInfoContainer.SetDosh(MyKFPC.GetPurchaseHelper().TotalDosh);
	  	GameInfoContainer.SetCurrentWeight(MyKFPC.GetPurchaseHelper().TotalBlocks, MyKFPC.GetPurchaseHelper().MaxBlocks);

	  	if(SelectedList == TL_Shop)
	  	{
	  		SetTraderItemDetails(SelectedItemIndex);
	  	}
	  	else if(bGenericItemSelected)
	  	{
	  		SetGenericItemDetails(LastDefaultItemInfo, LastItemInfo);
	  	}
	  	else
	  	{
	  		SetPlayerItemDetails(SelectedItemIndex);
	  	}
	}
}

/** TODO add different filters to this function */
function RefreshShopItemList( TabIndices TabIndex, byte FilterIndex )
{
	if (ShopContainer != none && FilterContainer != none)
	{
		switch (TabIndex)
		{
			case (TI_Perks):
				ShopContainer.RefreshWeaponListByPerk(FilterIndex, MyKFPC.GetPurchaseHelper().TraderItems.SaleItems);
				FilterContainer.SetPerkFilterData(FilterIndex);
			break;
			case (TI_Type):
				ShopContainer.RefreshItemsByType(FilterIndex, MyKFPC.GetPurchaseHelper().TraderItems.SaleItems);
				FilterContainer.SetTypeFilterData(FilterIndex);
			break;
			case (TI_Favorites):
				ShopContainer.RefreshFavoriteItems(MyKFPC.GetPurchaseHelper().TraderItems.SaleItems);
				FilterContainer.ClearFilters();
			break;
			case (TI_All):
				ShopContainer.RefreshAllItems(MyKFPC.GetPurchaseHelper().TraderItems.SaleItems);
				FilterContainer.ClearFilters();
			break;
		}
		FilterContainer.SetInt("selectedTab", TabIndex);
		FilterContainer.SetInt("selectedFilter", FilterIndex);

		if(SelectedList == TL_Shop)
		{
			if( SelectedItemIndex >= MyKFPC.GetPurchaseHelper().TraderItems.SaleItems.length )
			{
				SelectedItemIndex = MyKFPC.GetPurchaseHelper().TraderItems.SaleItems.length - 1;
			}

			SetTraderItemDetails(SelectedItemIndex);
			ShopContainer.SetSelectedIndex(SelectedItemIndex);
		}
  	}
}

function bool GetIsFavorite(name ClassName)
{
	local byte i;
	for (i = 0; i < FavoritedItems.length; i++)
	{
		if (ClassName == FavoritedItems[i])
		{
			return true;
		}
	}
	return false;
}

/** Add or remove the current selected item from the favorites list */
function ToggleFavorite(name ClassName)
{
	local byte i;
	local bool bUnfavoriteItem;
	for (i = 0; i < FavoritedItems.length; i++)
	{
		if (ClassName == FavoritedItems[i])
		{
			FavoritedItems.Remove(i, 1);
			bUnfavoriteItem = true;
			Manager.CachedProfile.UnFavoriteWeapon(ClassName);
			break;
		}
	}

	if (!bUnfavoriteItem)
	{
		FavoritedItems.AddItem(ClassName);
		Manager.CachedProfile.FavoriteWeapon(ClassName);
	}

	SaveConfig();
}

/** Modifies blocks required for the UI (e.g. in the case of dualies) */
simulated function int GetDisplayedBlocksRequiredFor( const out STraderItem Item, optional int OverrideLevelValue = INDEX_NONE)
{
	return MyKFIM.GetDisplayedBlocksRequiredFor( Item, OverrideLevelValue );
}

simulated function PurchaseError(bool bCannotAfford, bool bCannotCarry)
{
	if (ErrorMessageContainer != none) {
		if (bCannotAfford)
		{
			ErrorMessageContainer.SetWarningMessage(ErrorMessageContainer.CannotAffordString);
		}
		else if (bCannotCarry)
		{
			ErrorMessageContainer.SetWarningMessage(ErrorMessageContainer.CannotCarryString);
		}
		else
		{
			//clear it
			ErrorMessageContainer.SetWarningMessage("");
		}
		
	}
}

//==============================================================
// ActionScript Callbacks - Trader and Player Inventory
//==============================================================

function Callback_BuyOrSellItem()
{
	local STraderItem ShopItem;
	local SItemInformation ItemInfo;
	
	if (bCanBuyOrSellItem)
	{
		if (SelectedList == TL_Shop)
		{
			ShopItem = MyKFPC.GetPurchaseHelper().TraderItems.SaleItems[SelectedItemIndex];

			MyKFPC.GetPurchaseHelper().PurchaseWeapon(ShopItem);
			SetNewSelectedIndex(MyKFPC.GetPurchaseHelper().TraderItems.SaleItems.length);
	    	SetTraderItemDetails(SelectedItemIndex);
	    	ShopContainer.ActionScriptVoid("itemBought");
		}
		else
		{
			`log("Callback_BuyOrSellItem: SelectedItemIndex="$SelectedItemIndex, MyKFIM.bLogInventory);
			ItemInfo = OwnedItemList[SelectedItemIndex];
			`log("Callback_BuyOrSellItem: ItemInfo="$ItemInfo.DefaultItem.ClassName, MyKFIM.bLogInventory);
			MyKFPC.GetPurchaseHelper().SellWeapon(ItemInfo, SelectedItemIndex);

	   	    SetNewSelectedIndex(OwnedItemList.length);
			SetPlayerItemDetails(SelectedItemIndex);
			PlayerInventoryContainer.ActionScriptVoid("itemSold");
		}
	}
	else if( SelectedList == TL_Shop )
	{
		ShopItem = MyKFPC.GetPurchaseHelper().TraderItems.SaleItems[SelectedItemIndex];

		MyKFPC.PlayTraderSelectItemDialog( !MyKFPC.GetPurchaseHelper().GetCanAfford( MyKFPC.GetPurchaseHelper().GetAdjustedBuyPriceFor(ShopItem) ), !MyKFPC.GetPurchaseHelper().CanCarry( ShopItem ) );
	}
	RefreshItemComponents();
}

function Callback_FavoriteItem()
{
	if (SelectedList == TL_Shop)
	{
		ToggleFavorite(MyKFPC.GetPurchaseHelper().TraderItems.SaleItems[SelectedItemIndex].ClassName);
		if (CurrentTab == TI_Favorites)
		{
			SetNewSelectedIndex(MyKFPC.GetPurchaseHelper().TraderItems.SaleItems.length);
		}
		SetTraderItemDetails(SelectedItemIndex);
	}
	else
	{
		ToggleFavorite(OwnedItemList[SelectedItemIndex].DefaultItem.ClassName);
		SetPlayerItemDetails(SelectedItemIndex);
	}
	RefreshItemComponents();
}
//==============================================================
// ActionScript Callbacks - Trader Inventory
//==============================================================
function Callback_FilterChanged(int FilterIndex)
{
    CurrentFilterIndex = FilterIndex;
	RefreshShopItemList(CurrentTab, CurrentFilterIndex);
}

function Callback_TabChanged(int TabIndex)
{
	CurrentTab = TabIndices(TabIndex);
	if(CurrentTab == TI_Perks && MyKFPRI != none)
	{
		CurrentFilterIndex = GetPerkIndex();
	}
	else
	{
		CurrentFilterIndex = 0;
	}
	RefreshShopItemList(CurrentTab, CurrentFilterIndex);
}

//==============================================================
// ActionScript Callbacks - Player Inventory
//==============================================================
function Callback_UpgradeItem()
{
	local SItemInformation ItemInfo;
	local KFAutoPurchaseHelper PurchaseHelper;

	//only relevant in the player inventory
	if (SelectedList == TL_Player)
	{
		PurchaseHelper = MyKFPC.GetPurchaseHelper();
		if (PurchaseHelper.UpgradeWeapon(SelectedItemIndex))
		{
			ItemInfo = PurchaseHelper.OwnedItemList[SelectedItemIndex];
			PurchaseHelper.OwnedItemList[SelectedItemIndex].ItemUpgradeLevel++;
			// SellPrice is updated in UpgradeWeapon, but client-side upgrade level is set here,
			// so update the sellprice again, now that we've updated the upgrade level
			PurchaseHelper.OwnedItemList[SelectedItemIndex].SellPrice =
				PurchaseHelper.GetAdjustedSellPriceFor(ItemInfo.DefaultItem);
			RefreshItemComponents();
			ShopContainer.ActionScriptVoid("itemBought");
			class'KFMusicStingerHelper'.static.PlayWeaponUpgradeStinger(MyKFPC);
		}
	}
}

function Callback_BuyGrenade()
{
	if( PlayerInventoryContainer != none )
    {
		MyKFPC.GetPurchaseHelper().BuyGrenade();
		RefreshItemComponents();
	}
}

function Callback_FillGrenades()
{
	if (PlayerInventoryContainer != none)
    {
		MyKFPC.GetPurchaseHelper().FillAmmo(MyKFPC.GetPurchaseHelper().GrenadeItem, true);
		RefreshItemComponents();
	}
}

function Callback_FillArmor()
{
	if (PlayerInventoryContainer != none)
    {
		MyKFPC.GetPurchaseHelper().FillArmor();
		RefreshItemComponents();
	}
}

function Callback_FillAmmo(int ItemIndex)
{
	local SItemInformation ItemInfo;

	ItemInfo = OwnedItemList[ItemIndex];
	MyKFPC.GetPurchaseHelper().FillAmmo(ItemInfo);
	MyKFPC.GetPurchaseHelper().OwnedItemList[ItemIndex] = ItemInfo;
	RefreshItemComponents();
}

function Callback_BuyMagazine(int ItemIndex)
{
    MyKFPC.GetPurchaseHelper().BuyMagazine(ItemIndex);
	RefreshItemComponents();
}

function Callback_AutoFill(int ItemIndex)
{
    MyKFPC.GetPurchaseHelper().StartAutoFill();
    RefreshItemComponents();
}

//==============================================================
// ActionScript Callbacks - Weapon Details
//==============================================================

function Callback_ShopItemSelected(int ItemIndex)
{
	SetTraderItemDetails(ItemIndex);
}

function Callback_PlayerItemSelected(int ItemIndex)
{
	SetPlayerItemDetails(ItemIndex);
}

function Callback_ArmorItemSelected()
{
	SetGenericItemDetails(MyKFPC.GetPurchaseHelper().ArmorItem.DefaultItem, MyKFPC.GetPurchaseHelper().ArmorItem);
}

function Callback_GrenadeItemSelected()
{
	SetGenericItemDetails(MyKFPC.GetPurchaseHelper().GrenadeItem.DefaultItem, MyKFPC.GetPurchaseHelper().GrenadeItem);
}

//==============================================================
// Player Info
//==============================================================

function Callback_PerkChanged(int PerkIndex)
{
	if( MyKFPRI.NetPerkIndex != PerkIndex )
	{
		MyKFPC.RequestPerkChange(PerkIndex);

		if( MyKFPC.CanUpdatePerkInfo() )
		{
			MyKFPC.SetHaveUpdatePerk(true);

			// re-initialize and refresh to reflect current carry weight (can change by perk)
			MyKFPC.GetPurchaseHelper().Initialize(false);
			RefreshItemComponents();
		}

		Manager.CachedProfile.SetProfileSettingValueInt(KFID_SavedPerkIndex, PerkIndex);
	}

	if( PlayerInventoryContainer != none )
	{
		PlayerInventoryContainer.UpdateLock();
	}
	UpdatePlayerInfo();

	// Refresht he UI
	RefreshItemComponents();
}

//==============================================================
// ActionScript Callbacks - Header
//==============================================================
function Callback_Close()
{
	Manager.CloseMenus();
}

defaultproperties
{
	SubWidgetBindings.Add((WidgetName="gameInfoContainer",WidgetClass=class'KFGFxTraderContainer_GameInfo'))
	SubWidgetBindings.Add((WidgetName="filterContainer",WidgetClass=class'KFGFxTraderContainer_Filter'))
	SubWidgetBindings.Add((WidgetName="shopContainer",WidgetClass=class'KFGFxTraderContainer_Store'))
	SubWidgetBindings.Add((WidgetName="playerInfoContainer",WidgetClass=class'KFGFxTraderContainer_PlayerInfo'))
	SubWidgetBindings.Add((WidgetName="playerInventoryContainer",WidgetClass=class'KFGFxTraderContainer_PlayerInventory'))
	SubWidgetBindings.Add((WidgetName="itemDetailsContainer",WidgetClass=class'KFGFxTraderContainer_ItemDetails'))
	SubWidgetBindings.Add((WidgetName = "errorMessage",WidgetClass = class'KFGFxTraderContainer_ErrorMessage'))
	
}

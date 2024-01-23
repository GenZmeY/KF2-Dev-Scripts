//=============================================================================
// KFGFxTraderContainer_Store
//=============================================================================
// This class holds all of the functions and variables corresponding to the
// traders inventory list ( Items you can buy ). This class will perform a
// single call to actionscript to pass the "ItemDataArray" to the flash file.
// This array contains all the weapon names, prices, and descriptions.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Greg Felber 8/13/2013
//=============================================================================

class KFGFxTraderContainer_Store extends KFGFxObject_Container
	DependsOn(KFGFxObject_TraderItems);

var KFGFxMenu_Trader MyTraderMenu; // Reference to the movie player that owns us

var array< STraderItem > SlotsItemList;	// The Trader Item Info for each Item slot

var localized string TraderString;

var KFPlayerController KFPC;

//==============================================================
// Initialization
//==============================================================
function Initialize( KFGFxObject_Menu NewParentMenu )
{
	super.Initialize( NewParentMenu );
	KFPC = KFPlayerController(GetPC());
	MyTraderMenu = KFGFxMenu_Trader( NewParentMenu );
	SetString("shopHeaderName", TraderString);
	LocalizeContainer();
	GetPC().SetTimer(0.1f, false,'DelayedRefresh', self);
}

function LocalizeContainer()
{
	local GFxOBject LocalizedObject;

	LocalizedObject = CreateObject("Object");

	//Prompt strings
	LocalizedObject.SetString("buyPrompt", Localize("KFGFxTraderContainer_ItemDetails", "BuyString", "KFGame"));

	SetObject("localizeStrings", LocalizedObject);
}



//@todo Hack to get around AS clearing the weapon list once it's populated
function DelayedRefresh()
{
	MyTraderMenu.RefreshShopItemList(MyTraderMenu.CurrentTab, MyTraderMenu.CurrentFilterIndex);	
	SetSelectedIndex(0);
}

/** called each time trader UI is opened after initial */
function OnTraderReopened()
{
}

//==============================================================
// Update Item List
//==============================================================
function SetSelectedIndex( int SelectedIndex )
{
	SetInt( "selectedIndex", SelectedIndex );
}

// Grab the list of perk weapons that we do not already own and set their information
function RefreshWeaponListByPerk(byte FilterIndex, const out array<STraderItem> ItemList)
{
 	local int i, SlotIndex;
	local GFxObject ItemDataArray; // This array of information is sent to ActionScript to update the Item data
	local array<STraderItem> OnPerkWeapons, SecondaryWeapons, OffPerkWeapons;
	local class<KFPerk> TargetPerkClass;
	local bool bDebug;
	bDebug = false;
	if(FilterIndex == 255 || FilterIndex == INDEX_NONE)
	{
		return;
	}
	if (KFPC != none)
	{
		if(FilterIndex < KFPC.PerkList.Length)
		{
			TargetPerkClass = KFPC.PerkList[FilterIndex].PerkClass;
		}
		else
		{
			TargetPerkClass = none;
		}

		SlotIndex = 0;
	    ItemDataArray = CreateArray();

		for (i = 0; i < ItemList.Length; i++)
		{			
			if ( IsItemFiltered(ItemList[i], bDebug) )
			{
				continue; // Skip this item if it's in our inventory
			}
			
			if ( ItemList[i].AssociatedPerkClasses.length > 0
						&& ItemList[i].AssociatedPerkClasses[0] != none
						&& (FilterIndex >= KFPC.PerkList.Length || ItemList[i].AssociatedPerkClasses.Find(TargetPerkClass) == INDEX_NONE ) )
			{
				continue; // filtered by perk
			}

			if(ItemList[i].AssociatedPerkClasses.length > 0)
			{
				switch (ItemList[i].AssociatedPerkClasses.Find(TargetPerkClass))
				{
					case 0: //primary perk
						if(OnPerkWeapons.length == 0 && MyTraderMenu.SelectedList == TL_Shop)
						{
							if(GetInt( "currentSelectedIndex" ) == 0)
							{
								MyTraderMenu.SetTraderItemDetails(i);
							}
						}
						OnPerkWeapons.AddItem(ItemList[i]);
						break;
				
					case 1: //secondary perk
						SecondaryWeapons.AddItem(ItemList[i]);
						break;
				
					default: //off perk
						OffPerkWeapons.AddItem(ItemList[i]);
						break;
				}
			}
		}

		for (i = 0; i < OnPerkWeapons.length; i++)
		{
			SetItemInfo(ItemDataArray, OnPerkWeapons[i], SlotIndex);
			SlotIndex++;	
		}

		for (i = 0; i < SecondaryWeapons.length; i++)
		{
			SetItemInfo(ItemDataArray, SecondaryWeapons[i], SlotIndex);
			SlotIndex++;
		}

		for (i = 0; i < OffPerkWeapons.length; i++)
		{
			SetItemInfo(ItemDataArray, OffPerkWeapons[i], SlotIndex);
			SlotIndex++;
		}		

		SetObject("shopData", ItemDataArray);
	}
}

function RefreshItemsByType(byte FilterIndex, const out array<STraderItem> ItemList)
{
 	local int i, SlotIndex;
	local GFxObject ItemDataArray; // This array of information is sent to ActionScript to update the Item data

    SlotIndex = 0;
	
    ItemDataArray = CreateArray();

	for (i = 0; i < ItemList.Length; i++)
	{
		if ( IsItemFiltered(ItemList[i]) || !(FilterIndex == ItemList[i].TraderFilter || FilterIndex == ItemList[i].AltTraderFilter) )
		{
			continue; // Skip this item if it's in our inventory
		}
		else
		{
			SetItemInfo(ItemDataArray, ItemList[i], SlotIndex);
			SlotIndex++;
		}
	}

	SetObject("shopData", ItemDataArray);
}

// Grab the list of perk weapons that we do not already own and set their information
function RefreshFavoriteItems(const out array<STraderItem> ItemList)
{
 	local int i, SlotIndex;
	local GFxObject ItemDataArray; // This array of information is sent to ActionScript to update the Item data

    SlotIndex = 0;

    ItemDataArray = CreateArray();

	for (i = 0; i < ItemList.Length; i++)
	{
		if ( IsItemFiltered(ItemList[i]) || !MyTraderMenu.GetIsFavorite(ItemList[i].ClassName) )
		{
			continue; // Skip this item if it's in our inventory
		}
		else
		{
			SetItemInfo(ItemDataArray, ItemList[i], SlotIndex);
			SlotIndex++;
		}
	}

	SetObject("shopData", ItemDataArray);
}

// Grab the list of perk weapons that we do not already own and set their information
function RefreshAllItems(out array<STraderItem> ItemList)
{
 	local int i, SlotIndex;
	local GFxObject ItemDataArray; // This array of information is sent to ActionScript to update the Item data

    SlotIndex = 0;
    ItemDataArray = CreateArray();

	for (i = 0; i < ItemList.Length; i++)
	{
		if ( IsItemFiltered(ItemList[i]) )
		{
			continue; // Skip this item if it's in our inventory
		}
		else
		{
			SetItemInfo(ItemDataArray, ItemList[i], SlotIndex);
			SlotIndex++;
		}
	}

	SetObject("shopData", ItemDataArray);
}

function SetItemInfo(out GFxObject ItemDataArray, STraderItem TraderItem, int SlotIndex)
{
	local GFxObject SlotObject;
	local string ItemTexPath;
	local string IconPath;
	local string SecondaryIconPath;
	local bool bCanAfford, bCanCarry;
	local int AdjustedBuyPrice, ItemUpgradeLevel;

	SlotObject = CreateObject( "Object" );

	ItemTexPath = "img://"$TraderItem.WeaponDef.static.GetImagePath();
	if( TraderItem.AssociatedPerkClasses.length > 0 && TraderItem.AssociatedPerkClasses[0] != none)
	{

		IconPath = "img://"$TraderItem.AssociatedPerkClasses[0].static.GetPerkIconPath();
		if( TraderItem.AssociatedPerkClasses.length > 1 )
		{
			SecondaryIconPath = "img://"$TraderItem.AssociatedPerkClasses[1].static.GetPerkIconPath();
		}
	}
	else
	{
		IconPath = "img://"$class'KFGFxObject_TraderItems'.default.OffPerkIconPath;
	}
	SlotObject.SetString("buyText", Localize("KFGFxTraderContainer_ItemDetails", "BuyString", "KFGame"));

	SlotObject.SetInt("itemID", TraderItem.ItemID);
	SlotObject.SetString("weaponSource", ItemTexPath);
	SlotObject.SetString( "perkIconSource", IconPath );
	SlotObject.SetString( "perkSecondaryIconSource", SecondaryIconPath );

	SlotObject.SetString( "weaponName", TraderItem.WeaponDef.static.GetItemName() );
	SlotObject.SetString( "weaponType", TraderItem.WeaponDef.static.GetItemCategory() );

	ItemUpgradeLevel = TraderItem.SingleClassName != '' ?
		KFPC.GetPurchaseHelper().GetItemUpgradeLevelByClassName(TraderItem.SingleClassName) :
		INDEX_None;
	SlotObject.SetInt("weaponWeight", MyTraderMenu.GetDisplayedBlocksRequiredFor(TraderItem, ItemUpgradeLevel));

	AdjustedBuyPrice = KFPC.GetPurchaseHelper().GetAdjustedBuyPriceFor(TraderItem);

	SlotObject.SetInt( "weaponCost",  AdjustedBuyPrice );

	bCanAfford = KFPC.GetPurchaseHelper().GetCanAfford(AdjustedBuyPrice);
	bCanCarry = KFPC.GetPurchaseHelper().CanCarry(TraderItem, ItemUpgradeLevel);

	SlotObject.SetBool("bCanAfford", bCanAfford);
	SlotObject.SetBool("bCanCarry", bCanCarry);
	
	ItemDataArray.SetElementObject( SlotIndex, SlotObject );
}

/** returns true if this item should not be displayed */
function bool IsItemFiltered(STraderItem Item, optional bool bDebug)
{
	local bool bUses9mm;
	
	if(!class'GameEngine'.Static.IsGameFullyInstalled() && Item.WeaponDef.default.IsPlayGoHidden)
	{
		if (bDebug)
		{
			`log("is not fully installed this weapon is not available");
		}
		return true;
	}

	if (KFPC.GetPurchaseHelper().IsInOwnedItemList(Item.ClassName))
	{
		if (bDebug)
		{
			`log("Item is owned");
		}
		return true;
	}
	if ( KFPC.GetPurchaseHelper().IsInOwnedItemList(Item.DualClassName) )
	{
		if (bDebug)
		{
			`log("dual Item is owned");
		}
		return true;
	}
	if (!KFPC.GetPurchaseHelper().IsSellable(Item))
	{
		if (bDebug)
		{
			`log("Item is not sellable");
		}
		return true;
	}
	if (Item.WeaponDef.default.SharedUnlockId != SCU_None && !class'KFUnlockManager'.static.IsSharedContentUnlocked(Item.WeaponDef.default.SharedUnlockId))
	{
		if (bDebug)
		{
			`log("Item is not unlocked");
		}
		return true;
	}
	if ( Item.WeaponDef.default.PlatformRestriction != PR_All && class'KFUnlockManager'.static.IsPlatformRestricted( Item.WeaponDef.default.PlatformRestriction ) )
	{
		if (bDebug)
		{
			`log("Item is platform restricted");
		}
		return true;
	}

	bUses9mm = Has9mmGun();
	if (bUses9mm && (Item.ClassName == 'KFWeap_HRG_93r' || Item.ClassName == 'KFWeap_HRG_93r_Dual'))
	{
		if (bDebug)
		{
			`log("9mm owned, skip HRG_93");
		}
		return true;
	}

	if (!bUses9mm && (Item.ClassName == 'KFWeap_Pistol_9mm' || Item.ClassName == 'KFWeap_Pistol_Dual9mm'))
	{
		if (bDebug)
		{
			`log("HRG_93R owned, skip 9mm");
		}
		return true;
	}

   	return false;
}

simulated function bool Has9mmGun()
{
	local SItemInformation Item;

	foreach KFPC.GetPurchaseHelper().OwnedItemList(Item)
	{
		if (Item.DefaultItem.ClassName == 'KFWeap_Pistol_9mm' || Item.DefaultItem.ClassName == 'KFWeap_Pistol_Dual9mm')
		{
			return true;
		}
	}
	return false;
}
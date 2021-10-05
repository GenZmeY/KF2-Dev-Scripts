//=============================================================================
// KFAutoPurchaseHeler
//=============================================================================
// Hold logic for auto purchase
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================

class KFAutoPurchaseHelper extends Object within KFPlayerController
dependson(KFGFxMenu_Trader)
native(UI);

var KFPlayerReplicationInfo MyKFPRI;
var KFInventoryManager MyKFIM;

var KFGFxObject_TraderItems TraderItems;

var array<SItemInformation> OwnedItemList;
var SItemInformation GrenadeItem;
var SItemInformation ArmorItem;

var int TotalDosh; // The total amount of dosh we have
var bool bPendingDoshUpdate; // Set this to true if we spent money but haven't received acknowledgement from the server
var int TotalBlocks; // The total amount of blocks that our inventory takes up, plus any transactions
var byte MaxBlocks;  // The maximum number of blocks available

var int PrevArmor;

var int CostPerAutofillCycle;
var int DoshBuffer;

var int ArmorMagSize; // Percentage of armor bought individually

function Initialize(optional bool bInitOwnedItems = true)
{
	if( Pawn != none && PlayerReplicationInfo != none )
	{
		MyKFPRI = KFPlayerReplicationInfo( PlayerReplicationInfo );
		MyKFIM = KFInventoryManager( Pawn.InvManager );

		if( MyKFPRI != none && MyKFIM != none )
		{
			// Grab the weapons in our inventory and add them to a stored array called OwnedItemList
			if (bInitOwnedItems)
			{
				InitializeOwnedItemList();
			}
			TotalBlocks = MyKFIM.CurrentCarryBlocks;
			TotalDosh = MyKFPRI.Score;
			MaxBlocks = MyKFIM.MaxCarryBlocks;
		}
	}
}

/*************************
@Name - Auto purchase
**************************/
function DoAutoPurchase()
{
	local int PotentialDosh, i;
	local Array <STraderItem> OnPerkWeapons;
	local STraderItem TopTierWeapon;
	local int ItemIndex;
	local bool bSecondaryWeaponPurchased;
	local bool bUpgradeSuccess;
	local bool bAutoFillPurchasedItem;
	local string AutoFillMessageString;

	GetTraderItems();

	if(CurrentPerk.AutoBuyLoadOutPath.length == 0)
	{
		`log("!!!Autobuy load out path not set!!!");
		return;
	}

	for (i = 0; i < CurrentPerk.AutoBuyLoadOutPath.length; i++)
	{
		ItemIndex = TraderItems.SaleItems.Find('WeaponDef', CurrentPerk.AutoBuyLoadOutPath[i]);
		if(ItemIndex != INDEX_NONE)
		{
			OnPerkWeapons.AddItem(TraderItems.SaleItems[ItemIndex]);
		}
	}

	SellOffPerkWeapons();

	TopTierWeapon = GetTopTierWeapon(OnPerkWeapons);
	//can I afford my top teir without selling my current weapon?
	if(!DoIOwnThisWeapon(TopTierWeapon) && GetCanAfford( GetAdjustedBuyPriceFor(TopTierWeapon) + DoshBuffer ) && CanCarry( TopTierWeapon ) )
	{
		bUpgradeSuccess = AttemptUpgrade(TotalDosh, OnPerkWeapons, true);
	}
	else
	{
		PotentialDosh = GetPotentialDosh();
		bUpgradeSuccess = AttemptUpgrade(PotentialDosh+TotalDosh, OnPerkWeapons);
	}

	bAutoFillPurchasedItem = StartAutoFill();
	if(DoIOwnThisWeapon(TopTierWeapon))
	{
		while(AttemptToPurchaseNextLowerTier(TotalDosh, OnPerkWeapons))
		{
			bSecondaryWeaponPurchased = true;
			AttemptToPurchaseNextLowerTier(TotalDosh, OnPerkWeapons);
		}
	}

	MyKFIM.ServerCloseTraderMenu();

	if(bUpgradeSuccess)
	{
		AutoFillMessageString = class'KFCommon_LocalizedStrings'.default.WeaponUpgradeComepleteString;
	}
	else if(bSecondaryWeaponPurchased)
	{
		AutoFillMessageString = class'KFCommon_LocalizedStrings'.default.SecondaryWeaponPurchasedString;
	}
	else if(bAutoFillPurchasedItem)
	{
		AutoFillMessageString = class'KFCommon_LocalizedStrings'.default.AutoFillCompleteString;
	}
	else
	{
		AutoFillMessageString = class'KFCommon_LocalizedStrings'.default.NoItemsPurchasedString;
	}


	if(MyGFxHUD != none)
	{
		MyGFxHUD.ShowNonCriticalMessage( class'KFCommon_LocalizedStrings'.default.AutoTradeCompleteString$AutoFillMessageString );
	}
}

function bool AttemptToPurchaseNextLowerTier(int UseableDosh, const out Array <STraderItem>OnPerkWeapons)
{
	local int LastAfforableItemIndex;
	local STraderItem TempTraderItem;

	LastAfforableItemIndex = GetLastAffordableItemIndex(UseableDosh, OnPerkWeapons);
	if(LastAfforableItemIndex != INDEX_NONE)
	{
		TempTraderItem = OnPerkWeapons[LastAfforableItemIndex];
		PurchaseWeapon(TempTraderItem);

		StartAutoFill();
		return true;
	}
	return false;
}

function STraderItem GetTopTierWeapon(const out Array <STraderItem>OnPerkWeapons)
{
	local STraderItem HighestValuedWeapon;

	HighestValuedWeapon = GetHighValuedOnPerkWeapon(OnPerkWeapons);

	return HighestValuedWeapon;
}

function bool AttemptUpgrade(int UseableDosh, const out Array<STraderItem> OnPerkWeapons, optional bool bHaveTopTier)
{
	local STraderItem TempTraderItem;
	local bool bUpgradeSuccess;
	local int LastAfforableItemIndex;
	local SItemInformation MyHighestValuedWeapon;

	MyHighestValuedWeapon = GetHighValuedWeapon(OwnedItemList);

	LastAfforableItemIndex = GetLastAffordableItemIndex(UseableDosh, OnPerkWeapons, MyHighestValuedWeapon);

	if(LastAfforableItemIndex != INDEX_NONE)
	{
		TempTraderItem = OnPerkWeapons[LastAfforableItemIndex];

		if(MyHighestValuedWeapon.DefaultItem.WeaponDef.default.BuyPrice < TempTraderItem.WeaponDef.default.BuyPrice)
		{
			//Sell on perk weapons
			if(!bHaveTopTier)
			{
				SellOnPerkWeapons();
			}
			PurchaseWeapon(TempTraderItem);
			bUpgradeSuccess = true;
		}
	}
	return bUpgradeSuccess;
}

function int GetLastAffordableItemIndex(int UseableDosh, const out Array <STraderItem>OnPerkWeapons, optional SItemInformation TradeInItem)
{
	local int LastAfforableItemIndex, i;
	local STraderItem TempTraderItem;
	local int TradeInItemWeight;
	TradeInItemWeight = MyKFIM.GetDisplayedBlocksRequiredFor(TradeInItem.DefaultItem);
	LastAfforableItemIndex = INDEX_NONE;

	//figure out which weapon we can afford
	for (i = 0; i < OnPerkWeapons.length; i++)
	{
		TempTraderItem = OnPerkWeapons[i];
		if(UseableDosh > GetAdjustedBuyPriceFor(TempTraderItem) + DoshBuffer )
		{
			if(!DoIOwnThisWeapon(TempTraderItem) && !( (TotalBlocks - TradeInItemWeight + MyKFIM.GetDisplayedBlocksRequiredFor(TempTraderItem)) > MaxBlocks) && !IsInOwnedItemList(TempTraderItem.DualClassName))
			{
				LastAfforableItemIndex = i;
			}
		}
		else
		{
			break;
		}
	}
	return LastAfforableItemIndex;
}

function STraderItem GetHighValuedOnPerkWeapon(const out array<STraderItem> ItemList)
{
	local STraderItem HighestValuedWeapon;
	local int i;

	for (i = 0; i < ItemList.length; i++)
	{
		if( HighestValuedWeapon.WeaponDef == none || ItemList[i].WeaponDef.default.BuyPrice > HighestValuedWeapon.WeaponDef.default.BuyPrice)
		{
			HighestValuedWeapon = ItemList[i];
		}
	}

	return HighestValuedWeapon;
}

function SItemInformation GetHighValuedWeapon(const out array<SItemInformation> ItemList)
{
	local SItemInformation HighestValuedWeapon;
	local int i;

	for (i = 0; i < ItemList.length; i++)
	{
		if(ItemList[i].DefaultItem.BlocksRequired == -1)
		{
			continue;
		}

		if( HighestValuedWeapon.DefaultItem.WeaponDef == none || ItemList[i].DefaultItem.WeaponDef.default.BuyPrice > HighestValuedWeapon.DefaultItem.WeaponDef.default.BuyPrice)
		{
			HighestValuedWeapon = ItemList[i];
		}
	}

	return HighestValuedWeapon;
}

function SellOnPerkWeapons()
{
	local int i;

	for (i = 0; i < OwnedItemList.length; i++)
	{
		if( OwnedItemList[i].DefaultItem.AssociatedPerkClasses.length > 0 && OwnedItemList[i].DefaultItem.AssociatedPerkClasses[0] == CurrentPerk.Class && OwnedItemList[i].DefaultItem.BlocksRequired != -1)
		{
			SellWeapon(OwnedItemList[i], i);
			i=-1;
		}
	}
}

function SellOffPerkWeapons()
{
	local int i;

	for (i = 0; i < OwnedItemList.length; i++)
	{
		if( OwnedItemList[i].DefaultItem.AssociatedPerkClasses[0] != CurrentPerk.Class && OwnedItemList[i].DefaultItem.BlocksRequired != -1 && OwnedItemList[i].SellPrice != 0 )
		{
			if(CurrentPerk.ShouldAutosellWeapon(OwnedItemList[i].DefaultItem.WeaponDef))
			{
				SellWeapon(OwnedItemList[i], i);
				i=-1;
			}
		}
	}
}

function bool DoIOwnThisWeapon(const out STraderItem TraderItem)
{
	return OwnedItemList.Find('DefaultItem', TraderItem) != INDEX_NONE;
}

function int GetPotentialDosh()
{
	local int PotentialDosh, i;

	for (i = 0; i <OwnedItemList.length; i++)
	{
		if(OwnedItemList[i].SellPrice != 0)
		{
			PotentialDosh += OwnedItemList[i].SellPrice;
		}
	}

	return PotentialDosh;
}
/******************
@Name - Trader Items
*******************/
function bool bCanPurchase(STraderItem SelectedItem, optional bool bReturnError = true)
{
	local bool bCanAfford, bCanCarry, bNotOwned;

	bCanAfford = GetCanAfford( GetAdjustedBuyPriceFor(SelectedItem) );
	bCanCarry = CanCarry( SelectedItem );
    bNotOwned = !DoIOwnThisWeapon(SelectedItem);

	if (MyGfxManager != none && MyGfxManager.TraderMenu != none && bReturnError)
	{
		MyGFxManager.TraderMenu.PurchaseError(!bCanAfford, !bCanCarry);
	}

	return bCanCarry && bCanAfford && bNotOwned;
}

// Checks if we can have enough dosh to buy this item
function bool GetCanAfford(int BuyPrice)
{
	if (BuyPrice > TotalDosh)
	{
		return false;
	}
	return true;
}

// Checks if we can have enough blocks to hold this item
function bool CanCarry(const out STraderItem Item, optional int OverrideLevelValue = INDEX_NONE)
{
	if (TotalBlocks + MyKFIM.GetDisplayedBlocksRequiredFor(Item, OverrideLevelValue) > MaxBlocks)
	{
    	return false;
	}
	return true;
}

function bool CanUpgrade(STraderItem SelectedItem, out int CanCarryIndex, out int bCanAffordIndex, optional bool bPlayDialog)
{
	local bool bCanAfford, bCanCarry;
	local int UpgradePrice;
	local int ItemUpgradeLevel;
	local KFPlayerController MyKFPC;
	local int AddedWeightBlocks;

	MyKFPC = Outer;

	ItemUpgradeLevel = GetItemUpgradeLevelByClassName(SelectedItem.ClassName);
	if (ItemUpgradeLevel == INDEX_NONE || !(ItemUpgradeLevel < SelectedItem.WeaponDef.default.UpgradePrice.length))
	{
		`log("Item at max level");
		return false;
	}
	UpgradePrice = SelectedItem.WeaponDef.static.GetUpgradePrice(ItemUpgradeLevel);
	bCanAfford = GetCanAfford(UpgradePrice);
	AddedWeightBlocks = SelectedItem.WeaponUpgradeWeight[ItemUpgradeLevel + 1] - SelectedItem.WeaponUpgradeWeight[ItemUpgradeLevel];
	bCanCarry = !(TotalBlocks + AddedWeightBlocks > MaxBlocks);
	//bCanUpgrade = MyKFIM.ItemEligableForUpgrade(SelectedItem);
	if (bPlayDialog)
	{
		MyKFPC.PlayTraderSelectItemDialog(!bCanAfford, !bCanCarry);
	}
	CanCarryIndex = bCanCarry ? 1 : 0;
	bCanAffordIndex = bCanAfford ? 1 : 0;
	return bCanAfford && bCanCarry;
}

function PurchaseWeapon(STraderItem ShopItem)
{
	local int ItemUpgradeLevel;

	if(!bCanPurchase(ShopItem, true))
	{
		return;
	}

	ItemUpgradeLevel = ShopItem.SingleClassName != '' ?
		GetItemUpgradeLevelByClassName(ShopItem.SingleClassName) :
		INDEX_None;

	AddDosh(-GetAdjustedBuyPriceFor(ShopItem));
	AddBlocks(MyKFIM.GetWeaponBlocks(ShopItem, ItemUpgradeLevel));
	AddWeaponToOwnedItemList(ShopItem);
}

function SellWeapon(SItemInformation ItemInfo, optional int SelectedItemIndex = -1)
{
	AddDosh(GetAdjustedSellPriceFor(ItemInfo.DefaultItem));
   	AddBlocks( -MyKFIM.GetDisplayedBlocksRequiredFor(ItemInfo.DefaultItem) );

   	if(SelectedItemIndex != INDEX_NONE)
   	{
   		RemoveWeaponFromOwnedItemList( SelectedItemIndex );
   	}
}

function bool UpgradeWeapon(int OwnedItemIndex)
{
	local byte ItemIndex;
	local STraderItem DefaultItemInfo;
	local SItemInformation ItemInfo;
	local int Test1, Test2; //place holder ints

	ItemInfo = OwnedItemList[OwnedItemIndex];
	DefaultItemInfo = ItemInfo.DefaultItem;

	if (ItemInfo.bIsSecondaryAmmo || !CanUpgrade(DefaultItemInfo, Test1, Test2, true))
	{
		`log("cannot upgrade");
		return false;
	}

	TraderItems.GetItemIndicesFromArche(ItemIndex, DefaultItemInfo.ClassName);

	MyKFIM.BuyUpgrade(ItemIndex, ItemInfo.ItemUpgradeLevel);
	OwnedItemList[OwnedItemIndex].SellPrice = GetAdjustedSellPriceFor(DefaultItemInfo);
	if (MyGfxManager != none && MyGfxManager.TraderMenu != none)
	{
		MyGfxManager.TraderMenu.OwnedItemList = OwnedItemList;
	}
	return true;
}

/******************
@Name - Player Inventory
*******************/
function int GetFillArmorCost()
{
	// local float ArmorPercentage, FillCost, ArmorPricePerPercent;

	// ArmorPercentage = (float() / float(ArmorItem.MaxSpareAmmo)) * 100.f;
	// ArmorPricePerPercent = ArmorItem.AmmoPricePerMagazine;
	// FillCost = FCeil( (ArmorItem.SpareAmmoCount - ArmorItem.MaxSpareAmmo) * ArmorItem.AmmoPricePerMagazine );

	return FCeil( (ArmorItem.MaxSpareAmmo - ArmorItem.SpareAmmoCount) * ArmorItem.AmmoPricePerMagazine );
}

function int GetChunkArmorCost()
{
	return FCeil ( FMin(ArmorItem.MaxSpareAmmo - ArmorItem.SpareAmmoCount, ArmorMagSize) * ArmorItem.AmmoPricePerMagazine );
}

function int FillArmor( )
{
	local float ArmorPricePerPercent, FillCost;
	local float PercentBoughtUnit, PercentArmorBought;
	local int ActualArmorPointsAvailable;

	FillCost = GetFillArmorCost();
	ActualArmorPointsAvailable = ArmorItem.MaxSpareAmmo - ArmorItem.SpareAmmoCount;

	PercentBoughtUnit = float(ActualArmorPointsAvailable) / float(ArmorItem.MaxSpareAmmo);
	PercentArmorBought = PercentBoughtUnit * 100.f;

	// Buy as much armor as we possibly can
    if (FillCost > TotalDosh)
    {
   		ArmorPricePerPercent = ArmorItem.AmmoPricePerMagazine;

        // Because we are using ints this will round down and we can get how much we actually spent
    	PercentArmorBought = TotalDosh / ArmorPricePerPercent;
    	PercentBoughtUnit = PercentArmorBought / 100.f;
		FillCost = ArmorPricePerPercent * PercentArmorBought;
    }

    PercentArmorBought = (PercentArmorBought > 0.f && PercentArmorBought < 1.f) ? 1.f : PercentArmorBought;
    ArmorItem.SpareAmmoCount = FMin( float(ArmorItem.SpareAmmoCount) + (PercentBoughtUnit * float(ArmorItem.MaxSpareAmmo)), float(ArmorItem.MaxSpareAmmo) );

	BoughtAmmo(PercentArmorBought, FillCost, EIT_Armor);
	return FillCost;
}

function int BuyArmorMag( )
{
	local float ArmorPricePerPercent;
	local float ChunkCost;
	local float ArmorAvailable;
	local float PercentArmorBought;
	local float ArmorAmmountBought;

	ArmorAvailable     = (1 - float(ArmorItem.SpareAmmoCount) / ArmorItem.MaxSpareAmmo) * 100;
	ArmorAmmountBought = ArmorMagSize;
    PercentArmorBought = ArmorMagSize * 100.0f / ArmorItem.MaxSpareAmmo;

	if (ArmorAvailable < PercentArmorBought)
		return FillArmor();

	ChunkCost = ArmorAmmountBought * ArmorItem.AmmoPricePerMagazine;
	// Buy as much armor as we possibly can
    if (ChunkCost > TotalDosh)
    {
   		ArmorPricePerPercent = ArmorItem.AmmoPricePerMagazine;

        // Because we are using ints this will round down and we can get how much we actually spent
    	PercentArmorBought = TotalDosh / ArmorPricePerPercent;
		ChunkCost = ArmorPricePerPercent * PercentArmorBought;
		ArmorAmmountBought = ArmorItem.MaxSpareAmmo * PercentArmorBought / 100;
    }

    PercentArmorBought = (PercentArmorBought > 0.f && PercentArmorBought < 1.f) ? 1.f : PercentArmorBought;
	ArmorItem.SpareAmmoCount = FMin(ArmorItem.SpareAmmoCount + ArmorAmmountBought, ArmorItem.MaxSpareAmmo);

	BoughtAmmo(PercentArmorBought, ChunkCost, EIT_Armor);
	return ChunkCost;
}


function bool AttemptBuyArmorChunk( out int InAutoFillDosh )
{
	local float PercentArmorBought;
	local int ArmorPricePerPercent;
	local int ChunkCost;
	local int ActualArmorPointsAvailable;

	ActualArmorPointsAvailable = ArmorItem.MaxSpareAmmo - ArmorItem.SpareAmmoCount;

	ArmorPricePerPercent = ArmorItem.AmmoPricePerMagazine;
	PercentArmorBought   = 0;

	if( ArmorItem.SpareAmmoCount < ArmorItem.MaxSpareAmmo )
	{
	    // Because we are using int's this will round down and we can get how much we actually spent
		PercentArmorBought = FMin(CostPerAutofillCycle / ArmorPricePerPercent, float(ActualArmorPointsAvailable));
		ChunkCost          = ArmorPricePerPercent * PercentArmorBought;

		if( InAutoFillDosh < ChunkCost )
		{
			PercentArmorBought = FMin(InAutoFillDosh / ArmorPricePerPercent, float(ActualArmorPointsAvailable));
			ChunkCost          = ArmorPricePerPercent * PercentArmorBought;
		}

		InAutoFillDosh -= ChunkCost;

        PercentArmorBought = (PercentArmorBought > 0.f && PercentArmorBought < 1.f) ? 1.f : PercentArmorBought;
	    ArmorItem.SpareAmmoCount = FMin(ArmorItem.SpareAmmoCount + PercentArmorBought, ArmorItem.MaxSpareAmmo);
		BoughtAmmo(PercentArmorBought, ChunkCost, EIT_Armor);
	}
	
	return (PercentArmorBought > 0);
}

//grenade

function int GetFillGrenadeCost( )
{
	local int AmmoCount, MaxAmmoCount;
    local float MissingAmmo, PricePerMag;

	AmmoCount = GrenadeItem.SpareAmmoCount;
	MaxAmmoCount = GrenadeItem.MaxSpareAmmo;
	PricePerMag = GrenadeItem.AmmoPricePerMagazine;

	MissingAmmo = MaxAmmoCount - AmmoCount;
	// Use FCeil so you can never buy ammo for 0 Do$h on an int conversion
    return FCeil(MissingAmmo * PricePerMag);
}

function int BuyGrenade( )
{
	local int MagAmmoCost;
	MagAmmoCost = 0;
    if( (GrenadeItem.MaxSpareAmmo - GrenadeItem.SpareAmmoCount) > 0 )
    {
        MagAmmoCost = GrenadeItem.AmmoPricePerMagazine;

        GrenadeItem.SpareAmmoCount += 1;

		BoughtAmmo(1, MagAmmoCost, EIT_Grenade);
    }
    return MagAmmoCost;
}

// Ammo
//@todo give item information rather than index
function int BuySecondaryAmmoMag( out SItemInformation ItemInfo  )
{
	local int MagAmmoCost;
	local int MagSpaceAvailable;
	local int AddedAmmo;
    local float AmmoCostScale;
    local KFGameReplicationInfo KFGRI;

    KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
    if (KFGRI != none)
    {
        AmmoCostScale = KFGRI.GameAmmoCostScale;
    }
    else
    {
        AmmoCostScale = 1.0;
    }

	MagAmmoCost = 0;
    MagSpaceAvailable = ItemInfo.MaxSecondaryAmmo - ItemInfo.SecondaryAmmoCount;
    if( MagSpaceAvailable > 0 )
    {
        MagAmmoCost = AmmoCostScale * ItemInfo.DefaultItem.WeaponDef.default.SecondaryAmmoMagPrice;

        // Don't charge them full price if they don't buy a full mag's worth of ammo
        // or we can only afford part of a magazine
        if( (MagSpaceAvailable < ItemInfo.DefaultItem.WeaponDef.default.SecondaryAmmoMagSize) || (TotalDosh < MagAmmoCost) )
        {
            return FillAmmo( ItemInfo );
        }

        AddedAmmo = ItemInfo.DefaultItem.WeaponDef.default.SecondaryAmmoMagSize;

        ItemInfo.SecondaryAmmoCount += AddedAmmo;
        ItemInfo.SecondaryAmmoCount = Min( ItemInfo.MaxSecondaryAmmo, ItemInfo.SecondaryAmmoCount );

		BoughtAmmo(AddedAmmo, MagAmmoCost, EIT_Weapon, ItemInfo.DefaultItem.ClassName, ItemInfo.bIsSecondaryAmmo);
    }

    return MagAmmoCost;
}

function int BuyMagazine( int ItemSlotIndex  )
{
	local SItemInformation ItemInfo;
	local int MagCost;

    ItemInfo = OwnedItemList[ ItemSlotIndex ];

	if( ItemInfo.bIsSecondaryAmmo )
	{
		MagCost = BuySecondaryAmmoMag( ItemInfo );
	}
	else
	{
		MagCost = BuyItemMagazine( ItemInfo );
	}

	OwnedItemList[ ItemSlotIndex ] = ItemInfo;
	return MagCost;
}

function int BuyItemMagazine( out SItemInformation ItemInfo )
{
	local int MagAmmoCost;
	local int MagSpaceAvailable;

	MagAmmoCost = 0;
    MagSpaceAvailable = ItemInfo.MaxSpareAmmo - ItemInfo.SpareAmmoCount;

    if( MagSpaceAvailable > 0 )
    {
        MagAmmoCost = ItemInfo.AmmoPricePerMagazine;

        // Don't charge them full price if they don't buy a full mag's worth of ammo
        // or we can only afford part of a magazine
        if( (MagSpaceAvailable < ItemInfo.DefaultItem.MagazineCapacity) || (TotalDosh < MagAmmoCost) )
        {
        	return FillAmmo( ItemInfo );
        }


        ItemInfo.SpareAmmoCount += ItemInfo.DefaultItem.MagazineCapacity;
        ItemInfo.SpareAmmoCount = Min( ItemInfo.MaxSpareAmmo, ItemInfo.SpareAmmoCount );

		BoughtAmmo(ItemInfo.DefaultItem.MagazineCapacity, MagAmmoCost, EIT_Weapon, ItemInfo.DefaultItem.ClassName, ItemInfo.bIsSecondaryAmmo);
    }

    return MagAmmoCost;
}

function float FillAmmo( out SItemInformation ItemInfo, optional bool bIsGrenade )
{
	local float MissingAmmo, MagSize;
	local float FillAmmoCost, PricePerMag;
    local float PricePerRound;
    local float AmmoCostScale;
    local KFGameReplicationInfo KFGRI;

    KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
    if (KFGRI != none)
    {
        AmmoCostScale = KFGRI.GameAmmoCostScale;
    }
    else
    {
        AmmoCostScale = 1.0;
    }

    if( ItemInfo.bIsSecondaryAmmo )
    {
		MagSize = ItemInfo.DefaultItem.WeaponDef.default.SecondaryAmmoMagSize;
		PricePerMag = AmmoCostScale * ItemInfo.DefaultItem.WeaponDef.default.SecondaryAmmoMagPrice;
		MissingAmmo = ItemInfo.MaxSecondaryAmmo - ItemInfo.SecondaryAmmoCount;
		FillAmmoCost = GetFillAmmoCost(ItemInfo);
    }
    else
    {
		MagSize = ItemInfo.DefaultItem.MagazineCapacity;
		PricePerMag = ItemInfo.AmmoPricePerMagazine;
		MissingAmmo = ItemInfo.MaxSpareAmmo - ItemInfo.SpareAmmoCount;
    	FillAmmoCost = ( bIsGrenade ) ? GetFillGrenadeCost() : GetFillAmmoCost(ItemInfo);
    }

	// If we cannot fill all our ammo, fill as much as possible
	if ( FillAmmoCost > TotalDosh )
	{
	    PricePerRound = ( bIsGrenade ) ? PricePerMag : PricePerMag / MagSize;
	    MissingAmmo = FFloor(TotalDosh / PricePerRound);
	    FillAmmoCost = FCeil(MissingAmmo * PricePerRound);
	}

	if( ItemInfo.bIsSecondaryAmmo )
    {
    	ItemInfo.SecondaryAmmoCount += MissingAmmo;
	}
	else
	{
		ItemInfo.SpareAmmoCount += MissingAmmo;
	}

	if( bIsGrenade )
    {
		BoughtAmmo(MissingAmmo, FillAmmoCost, EIT_Grenade);
    }
    else
    {
		BoughtAmmo(MissingAmmo, FillAmmoCost, EIT_Weapon, ItemInfo.DefaultItem.ClassName, ItemInfo.bIsSecondaryAmmo);
    }

    return FillAmmoCost;
}


//Refresh player inventory
/** Returns the cost to refill this items ammo */
function int GetFillAmmoCost( out SItemInformation ItemInfo )
{
	local int AmmoCount, MaxAmmoCount;
    local float MissingAmmo, PricePerMag, MagSize, PricePerRound;
    local float AmmoCostScale;
    local KFGameReplicationInfo KFGRI;

    KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
    if (KFGRI != none)
    {
        AmmoCostScale = KFGRI.GameAmmoCostScale;
    }
    else
    {
        AmmoCostScale = 1.0;
    }

    if( ItemInfo.bIsSecondaryAmmo )
    {
    	AmmoCount = ItemInfo.SecondaryAmmoCount;
    	MaxAmmoCount = ItemInfo.MaxSecondaryAmmo;
    	PricePerMag = AmmoCostScale * ItemInfo.DefaultItem.WeaponDef.default.SecondaryAmmoMagPrice;
    	MagSize = ItemInfo.DefaultItem.WeaponDef.default.SecondaryAmmoMagSize;
    }
    else
    {
    	AmmoCount = ItemInfo.SpareAmmoCount;
    	MaxAmmoCount = ItemInfo.MaxSpareAmmo;
    	PricePerMag = ItemInfo.AmmoPricePerMagazine;
    	MagSize = ItemInfo.DefaultItem.MagazineCapacity;
    }

    if( MagSize <= 0 )
    {
        return 0;
    }

	MissingAmmo = MaxAmmoCount - AmmoCount;
    PricePerRound = PricePerMag / MagSize;

	// Use FCeil so you can never buy ammo for 0 Do$h on an int conversion
    return FCeil(MissingAmmo * PricePerRound);
}

// auto fill
// Change the look of the button dependant on if we can afford it, or are at max capacity
function bool AttemptAutoFillOnItem( out SItemInformation ItemInfo, out int InAutoFillDosh, int Price )
{
	local int DoshSpent;

	DoshSpent = Min(InAutoFillDosh, CostPerAutofillCycle);
    InAutoFillDosh -= DoshSpent;
    ItemInfo.AutoFillDosh += DoshSpent;
    return ( ItemInfo.AutoFillDosh >= Price );
}


/** Take all dosh out of current weapons and pool it back into AutoFillDosh for the final cycle */
function RePoolAutoFillDosh( out int AutoFillDosh )
{
	local byte i;
	// If we could not buy anything else, clear all cached dosh and buy whatevers possible
	for (i = 0; i < OwnedItemList.Length; i++)
	{
		AutoFillDosh += OwnedItemList[ i ].AutoFillDosh;
		OwnedItemList[ i ].AutoFillDosh = 0;
	}
	AutoFillDosh += ArmorItem.AutoFillDosh;
	ArmorItem.AutoFillDosh = 0;

	AutoFillDosh += GrenadeItem.AutoFillDosh;
	GrenadeItem.AutoFillDosh = 0;
}

/** Empty out any cached dosh in weapons once we've finished autofilling */
function ClearAutoFillDosh()
{
	local byte i;
	// If we could not buy anything else, clear all cached dosh and buy whatevers possible
	for (i = 0; i < OwnedItemList.Length; i++)
	{
		OwnedItemList[ i ].AutoFillDosh = 0;
	}
	ArmorItem.AutoFillDosh = 0;
	GrenadeItem.AutoFillDosh = 0;
}


function bool AutoFillOwnedItems( out int AutoFillDosh, bool bLastCycle )
{
	local int i, PricePerMag, AmmoCount, MaxAmmoCount;
	local SItemInformation ItemInfo;
    local float AmmoCostScale;
    local KFGameReplicationInfo KFGRI;

    KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
    if (KFGRI != none)
    {
        AmmoCostScale = KFGRI.GameAmmoCostScale;
    }
    else
    {
        AmmoCostScale = 1.0;
    }

	for (i = 0; i < OwnedItemList.Length; i++)
	{
		ItemInfo = OwnedItemList[ i ];
	    if( ItemInfo.bIsSecondaryAmmo )
	    {
			PricePerMag = AmmoCostScale * ItemInfo.DefaultItem.WeaponDef.default.SecondaryAmmoMagPrice;
	    	AmmoCount = ItemInfo.SecondaryAmmoCount;
	    	MaxAmmoCount = ItemInfo.MaxSecondaryAmmo;
	    }
	    else
	    {
	   		PricePerMag = ItemInfo.AmmoPricePerMagazine;
	    	AmmoCount = ItemInfo.SpareAmmoCount;
	    	MaxAmmoCount = ItemInfo.MaxSpareAmmo;
	    }

	    // Only buy ammo if we are missing any
	    if ( AmmoCount < MaxAmmoCount )
		{
			if( bLastCycle )
			{
				AutoFillDosh -= FillAmmo( ItemInfo );
			}
	  	 	else if( AttemptAutoFillOnItem(ItemInfo, AutoFillDosh, PricePerMag) )
			{
				ItemInfo.AutoFillDosh -= BuyMagazine(i);
				OwnedItemList[ i ].AutoFillDosh = ItemInfo.AutoFillDosh;
				return true;
			}
			OwnedItemList[ i ] = ItemInfo;
		}
	}
	return false;
}

function bool StartAutoFill()
{
	local int AutoFillDosh;
	local bool bBoughtSomething;
	local bool bLastCycle;
	local bool bAutoFillPurchasedItem;

	bLastCycle = false;
	AutoFillDosh = TotalDosh;
	// try and buy items until we cannot afford anything else or we've bought everything
	while( true )
	{
		// Tries to buy ammo for the highest priority weapon with missing ammo, unless we're on the last cycle in which case buy for all weapons
		bBoughtSomething = AutoFillOwnedItems(AutoFillDosh, bLastCycle);

		// Fill armor
		if( ArmorItem.SpareAmmoCount < ArmorItem.MaxSpareAmmo )
		{
			if( bLastCycle )
			{
				AutoFillDosh -= FillArmor();
			}
			else if( AttemptBuyArmorChunk( AutoFillDosh ) )
			{
				bBoughtSomething = true;
			}
		}

		// Fill grenades
		if( GrenadeItem.SpareAmmoCount < GrenadeItem.MaxSpareAmmo )
		{
			if( bLastCycle )
			{
				AutoFillDosh -= FillAmmo(GrenadeItem, true);
			}
		    else if( AttemptAutoFillOnItem(GrenadeItem, AutoFillDosh, GrenadeItem.AmmoPricePerMagazine) )
			{
				GrenadeItem.AutoFillDosh -= BuyGrenade();
				bBoughtSomething = true;
			}
		}

		if( bLastCycle )
		{
			break;
		}
		else if( !bBoughtSomething )
		{
			// buy whatever we can with our last cycle
			if( !bLastCycle )
			{
				// Return all accumulated dosh from weapons to AutoFillDosh
				RePoolAutoFillDosh(AutoFillDosh);
				bLastCycle = true;
			}
		}
		if(	!bAutoFillPurchasedItem )
		{
			bAutoFillPurchasedItem = bBoughtSomething;
		}
		bBoughtSomething = false;
	}

	ClearAutoFillDosh();
	return bAutoFillPurchasedItem;
}

//This is for external use of the UI.  DO NOT use this in the menu. -ZG
function Int GetAutoFillCost()
{
	local byte SlotIndex;
	local int FillAmmoCost, AutoFillCost;
   	local SItemInformation ItemInfo;

	AutoFillCost += GetFillArmorCost();
	AutoFillCost += GetFillGrenadeCost();

	// Iterate through all the items to get the auto fill cost, and update the items
	// for the page we are currently on
   	for ( SlotIndex = 0; SlotIndex < OwnedItemList.Length; SlotIndex++ )
	{
		ItemInfo = OwnedItemList[SlotIndex];
		FillAmmoCost = GetFillAmmoCost(ItemInfo);
		AutoFillCost += FillAmmoCost;
	}

	return AutoFillCost;
}

/******************
@Name - General
*******************/

function InitializeOwnedItemList()
{
   	local Inventory Inv;
   	local KFWeapon KFW;
	local KFPawn_Human KFP;
    local bool AllowGrenades;

    OwnedItemList.length = 0;

	TraderItems = KFGameReplicationInfo( WorldInfo.GRI ).TraderItems;
    AllowGrenades = KFGameReplicationInfo( WorldInfo.GRI ).bAllowGrenadePurchase;

	KFP = KFPawn_Human( Pawn );
    if( KFP != none )
    {
		// init armor purchase values
		ArmorItem.SpareAmmoCount = KFP.Armor;
		ArmorItem.MaxSpareAmmo = KFP.GetMaxArmor();
	   	ArmorItem.AmmoPricePerMagazine = TraderItems.ArmorPrice * CurrentPerk.GetArmorDiscountMod();
	   	ArmorItem.DefaultItem.WeaponDef = TraderItems.ArmorDef;

		// init grenade purchase values
		GrenadeItem.SpareAmmoCount = MyKFIM.GrenadeCount;
		GrenadeItem.MaxSpareAmmo = AllowGrenades ? KFP.GetPerk().MaxGrenadeCount : 0;
	   	GrenadeItem.AmmoPricePerMagazine = TraderItems.GrenadePrice;
	   	GrenadeItem.DefaultItem.WeaponDef = CurrentPerk.GetGrenadeWeaponDef();

		// @temp: fill in stuff that is normally serialized in the archetype
		GrenadeItem.DefaultItem.AssociatedPerkClasses[0] = CurrentPerk.Class;

		for ( Inv = MyKFIM.InventoryChain; Inv != none; Inv = Inv.Inventory )
		{
			KFW = KFWeapon( Inv );
			if( KFW != none )
			{
				// Set the weapon information and add it to the OwnedItemList
				SetWeaponInformation( KFW );
	     	}
		}

		if(MyGfxManager != none && MyGfxManager.TraderMenu != none)
		{
			MyGfxManager.TraderMenu.OwnedItemList = OwnedItemList;
		}
	}
}


/** returns true if item can be bought/sold at trader */
function bool IsSellable(const out STraderItem TraderItem)
{
	return (TraderItem.WeaponDef != None && TraderItem.WeaponDef.default.BuyPrice > 0);
}


/** Called from KFGFxTraderContainer_Store */
simulated function int GetAdjustedBuyPriceFor( const out STraderItem ShopItem )
{
	return MyKFIM.GetAdjustedBuyPriceFor( ShopItem, OwnedItemList );
}

simulated function int GetAdjustedSellPriceFor(const out STraderItem ShopItem)
{
	return MyKFIM.GetAdjustedSellPriceFor(ShopItem, OwnedItemList);
}

simulated function int GetAdjustedUpgradePriceFor(const out STraderItem ItemInfo, int UpgradeLevel)
{
	return MyKFIM.GetAdjustedUpgradePriceFor(ItemInfo, UpgradeLevel);
}

simulated function int GetItemUpgradeLevelByClassName(name ClassName)
{
	local int i;
	local name OwnedItemClassName;

	for (i = 0; i < OwnedItemList.Length; i++)
	{
		OwnedItemClassName = OwnedItemList[i].DefaultItem.ClassName;
		if (OwnedItemClassName == '')
		{
			`warn("Owned item with Class NAME_None");
			continue;
		}
		else if (OwnedItemClassName == ClassName)
		{
			return OwnedItemList[i].ItemUpgradeLevel;
		}
	}

	return 0;
}

function bool IsInOwnedItemList( name ItemName )
{
	local int i;
	local name OwnedItemClassName;

	for (i = 0; i < OwnedItemList.Length; i++)
	{
		OwnedItemClassName = OwnedItemList[i].DefaultItem.ClassName;
		if ( OwnedItemClassName == '' )
		{
			`warn("Owned item with Class NAME_None");
			continue;
		}
     	else if ( OwnedItemClassName == ItemName )
     	{
     	 	return true;
     	}
   	}

   	return false;
}

function AddDosh( int AddedDosh )
{
	TotalDosh = Max( TotalDosh + AddedDosh, 0 );

	if(Role < ROLE_Authority)
	{
		bPendingDoshUpdate = true;
		// If we have not heard anything back form the server, update the clients dosh value
		SetTimer(2.0f, false, nameof(UpdateCurrentDosh), self);
	}
}

simulated function NotifyDoshChanged()
{
    // If we've spent dosh just prior to receiving an update, keep our client value and wait for the next server update
	if( bPendingDoshUpdate )
	{
		bPendingDoshUpdate = false;
		if(MyKFPRI.Score != TotalDosh)
		{
			return;
		}
	}

	UpdateCurrentDosh();
}

simulated function UpdateCurrentDosh()
{
	// If we receive dosh outside of the menu update our TotalDosh and refresh the menus
	TotalDosh = Max( MyKFPRI.Score, 0 );
	if(MyGfxManager != none && MyGfxManager.TraderMenu != none)
	{
		MyGfxManager.TraderMenu.RefreshItemComponents();
	}

	bPendingDoshUpdate = false;
	ClearTimer(nameof(UpdateCurrentDosh), self);
}

function BoughtAmmo(float AmountPurchased, int Price, EItemType ItemType, optional name ClassName, optional bool bIsSecondaryAmmo)
{
	local byte ItemIndex;
    AddDosh( -Price );

    if( ItemType == EIT_Weapon )
    {
        // Get the proper weapon prices from the servers trader archetype
    	TraderItems.GetItemIndicesFromArche(ItemIndex, ClassName);
    }

	MyKFIM.BuyAmmo( AmountPurchased, ItemType, ItemIndex, bIsSecondaryAmmo );
}


function SetWeaponInformation( KFWeapon KFW )
{
	local int i;

	for (i = 0; i < TraderItems.SaleItems.Length; i++)
	{
    	if( KFW.Class.name == TraderItems.SaleItems[i].ClassName )
    	{
    		SetWeaponInfo(KFW, TraderItems.SaleItems[i]);
    		return;
    	}
    }
}

/** Add a currently owned item to the "OwnedItemList" on initialization */
function SetWeaponInfo(const KFWeapon KFW, STraderItem DefaultItem)
{
   	local SItemInformation WeaponInfo;
    local float AmmoCostScale;
    local KFGameReplicationInfo KFGRI;

    KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
    if (KFGRI != none)
    {
        AmmoCostScale = KFGRI.GameAmmoCostScale;
    }
    else
    {
        AmmoCostScale = 1.0;
    }

   	// Include current magazine ammo in spare ammo count
	WeaponInfo.SpareAmmoCount = KFW.GetTotalAmmoAmount(0);
	// Max spare ammo already includes perk modifications and magazine capacity
	WeaponInfo.MaxSpareAmmo = KFW.GetMaxAmmoAmount(0);
	WeaponInfo.MagazineCapacity = KFW.MagazineCapacity[0];
	WeaponInfo.SecondaryAmmoCount = KFW.GetTotalAmmoAmount(1);
	WeaponInfo.MaxSecondaryAmmo = KFW.GetMaxAmmoAmount(1);
	WeaponInfo.DefaultItem = DefaultItem;
	WeaponInfo.ItemUpgradeLevel = KFW.CurrentWeaponUpgradeIndex;

	WeaponInfo.AmmoPricePerMagazine = AmmoCostScale * DefaultItem.WeaponDef.default.AmmoPricePerMag;
	WeaponInfo.SellPrice = GetAdjustedSellPriceFor(DefaultItem);

    AddItemByPriority( WeaponInfo );

   	// if adding a dual, remove the related single
   	if( DefaultItem.SingleClassName != '' )
   	{
   		RemoveWeaponFromOwnedItemList( , DefaultItem.SingleClassName, true );
   	}
}


// We've bought a new item, add its information to our owned item list
function int AddWeaponToOwnedItemList( STraderItem DefaultItem, optional bool bDoNotBuy, optional int OverrideItemUpgradeLevel = INDEX_NONE )
{
	local SItemInformation WeaponInfo;
	local byte ItemIndex;
	local int  AddedWeaponIndex, OwnedSingleIdx, SingleDualAmmoDiff;
	local bool bAddingDual;
    local float AmmoCostScale;
    local KFGameReplicationInfo KFGRI;

    KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
    if (KFGRI != none)
    {
        AmmoCostScale = KFGRI.GameAmmoCostScale;
    }
    else
    {
        AmmoCostScale = 1.0;
    }

	// Magazine capacity affects both spare ammo and max spare ammo. modify this first
   	WeaponInfo.MagazineCapacity = DefaultItem.MagazineCapacity;
	CurrentPerk.ModifyMagSizeAndNumber( none, WeaponInfo.MagazineCapacity, DefaultItem.AssociatedPerkClasses,, DefaultItem.ClassName );

	// Newly bought weapons need to have their default values modified by the current perk
	WeaponInfo.MaxSpareAmmo = DefaultItem.MaxSpareAmmo;
	CurrentPerk.ModifyMaxSpareAmmoAmount(none, WeaponInfo.MaxSpareAmmo, DefaultItem);
	WeaponInfo.MaxSpareAmmo +=  WeaponInfo.MagazineCapacity;

	WeaponInfo.SpareAmmoCount = DefaultItem.InitialSpareMags * DefaultItem.MagazineCapacity;
	CurrentPerk.ModifySpareAmmoAmount(none, WeaponInfo.SpareAmmoCount, DefaultItem);
	WeaponInfo.SpareAmmoCount += WeaponInfo.MagazineCapacity;

	// if adding a dual, adjust the displayed ammo count to reflect ammo of single
	bAddingDual = DefaultItem.SingleClassName != '';
	if( bAddingDual )
	{
		for( OwnedSingleIdx = 0; OwnedSingleIdx < OwnedItemList.Length; ++OwnedSingleIdx )
		{
			if( OwnedItemList[OwnedSingleIdx].DefaultItem.ClassName == DefaultItem.SingleClassName )
			{
				SingleDualAmmoDiff = OwnedItemList[OwnedSingleIdx].SpareAmmoCount - WeaponInfo.SpareAmmoCount;
                SingleDualAmmoDiff = Max(0, SingleDualAmmoDiff); //If buying a dual, always have it be minimum starting ammo capacity

                //If the new weapon has more when adding a dual, we're boosting it to the new full amount.  Set UI info properly
                if (WeaponInfo.SpareAmmoCount > OwnedItemList[OwnedSingleIdx].SpareAmmoCount)
                {
                    OwnedItemList[OwnedSingleIdx].SpareAmmoCount = WeaponInfo.SpareAmmoCount;
                }
                //Otherwise we're going to maintain ammo and want the weapon info to match intended
                else
                {
                    //If rounding is causing problems, make sure our current ammo is never over the new max in the UI
                    WeaponInfo.SpareAmmoCount = Min(OwnedItemList[OwnedSingleIdx].SpareAmmoCount, WeaponInfo.MaxSpareAmmo);
                }

				WeaponInfo.ItemUpgradeLevel = OwnedItemList[OwnedSingleIdx].ItemUpgradeLevel;
				break;
			}
		}
	}

	// allow perk to set spare ammo to max (uses different params than ModifySpareAmmoAmount)
	// mostly just used for firebug
	CurrentPerk.MaximizeSpareAmmoAmount( DefaultItem.AssociatedPerkClasses, WeaponInfo.SpareAmmoCount, DefaultItem.MaxSpareAmmo + DefaultItem.MagazineCapacity );

	WeaponInfo.SecondaryAmmoCount = DefaultItem.InitialSecondaryAmmo;
	CurrentPerk.ModifyMagSizeAndNumber( none, WeaponInfo.MagazineCapacity, DefaultItem.AssociatedPerkClasses, true, DefaultItem.ClassName );
	CurrentPerk.ModifySpareAmmoAmount( none, WeaponInfo.SecondaryAmmoCount, DefaultItem, true );

	WeaponInfo.MaxSecondaryAmmo = DefaultItem.MaxSecondaryAmmo;
	CurrentPerk.ModifyMaxSpareAmmoAmount( none, WeaponInfo.MaxSecondaryAmmo, DefaultItem, true );

	WeaponInfo.AmmoPricePerMagazine = AmmoCostScale * DefaultItem.WeaponDef.default.AmmoPricePerMag;
   	WeaponInfo.SellPrice = GetAdjustedSellPriceFor(DefaultItem);

	WeaponInfo.DefaultItem = DefaultItem;

	if(OverrideItemUpgradeLevel > INDEX_NONE)
	{
		WeaponInfo.ItemUpgradeLevel = OverrideItemUpgradeLevel;
	}

   	AddedWeaponIndex = AddItemByPriority( WeaponInfo );

	TraderItems.GetItemIndicesFromArche(ItemIndex, DefaultItem.ClassName);

	if (!bDoNotBuy)
	{
		// Tell the server to buy the weapon using its trader archetype info
		MyKFIM.ServerBuyWeapon(ItemIndex, WeaponInfo.ItemUpgradeLevel);
	}
	else
	{
		// Tell the server to add the weapon (without buying) using its trader archetype info
		MyKFIM.ServerAddTransactionItem(ItemIndex, WeaponInfo.ItemUpgradeLevel);
		AddBlocks(MyKFIM.GetWeaponBlocks(DefaultItem, WeaponInfo.ItemUpgradeLevel));
	}

	// if adding a dual, set its transaction ammo (given at trader close) to reflect the single it's replacing
	if (bAddingDual)
	{
		AddTransactionAmmo(ItemIndex, SingleDualAmmoDiff /*+ WeaponInfo.MagazineCapacity/2*/, false);
		RemoveWeaponFromOwnedItemList(, DefaultItem.SingleClassName, true);
	}

   	return AddedWeaponIndex;
}

/** Removes item from owned list and sells it, if applicable */
function RemoveWeaponFromOwnedItemList( optional int OwnedListIdx = INDEX_NONE, optional name ClassName, optional bool bDoNotSell )
{
	local SItemInformation ItemInfo;
	local byte ItemIndex;
	local int SingleOwnedIndex;

	if( OwnedListIdx == INDEX_NONE && ClassName != '' )
	{
		for( OwnedListIdx = 0; OwnedListIdx < OwnedItemList.length; ++OwnedListIdx )
		{
			if( OwnedItemList[OwnedListIdx].DefaultItem.ClassName == ClassName )
			{
				break;
			}
		}
	}

	if( OwnedListIdx >= OwnedItemList.length )
	{
		return;
	}

	ItemInfo = OwnedItemList[OwnedListIdx];

	if( !bDoNotSell )
	{
		// Sell the weapon from our inventory immediately
		TraderItems.GetItemIndicesFromArche( ItemIndex, ItemInfo.DefaultItem.ClassName );
		MyKFIM.ServerSellWeapon(ItemIndex);
	}
	else
	{
		// Remove the weapon from our inventory immediately (without selling)
		AddBlocks(-MyKFIM.GetDisplayedBlocksRequiredFor(ItemInfo.DefaultItem));
		TraderItems.GetItemIndicesFromArche( ItemIndex, ItemInfo.DefaultItem.ClassName );
		MyKFIM.ServerRemoveTransactionItem( ItemIndex );
	}

	// If we try to sell a weapons secondary ammo slot
	if( OwnedItemList[OwnedListIdx].bIsSecondaryAmmo )
	{
		OwnedItemList.Remove( OwnedListIdx, 1 );
		if( OwnedListIdx - 1 >= 0 )
    	{
    		OwnedItemList.Remove( OwnedListIdx - 1, 1 );
    	}
	}
	// If the weapon we're selling uses secondary ammo, remove the secondary ammo listing also
	else if( OwnedItemList[OwnedListIdx].DefaultItem.WeaponDef.static.UsesSecondaryAmmo() )
	{
    	if( OwnedListIdx + 1 < OwnedItemList.Length )
    	{
    		OwnedItemList.Remove( OwnedListIdx + 1, 1 );
			OwnedItemList.Remove( OwnedListIdx, 1 );
    	}
	}
	else
	{
		OwnedItemList.Remove( OwnedListIdx, 1 );
	}
	//now selling duals as we buy them; together.

	// add a single to owned items when removing a dual
	//if( ItemInfo.DefaultItem.SingleClassName != '' )
	if( ItemInfo.DefaultItem.SingleClassName == 'KFWeap_Pistol_9mm' )
	{
		// When removing a dual, always add a single to the owned list so that it shows up in the player inventory UI.
		// If we don't own the single, then also buy it (add it to the transaction list).

		if( TraderItems.GetItemIndicesFromArche( ItemIndex, ItemInfo.DefaultItem.SingleClassName) )
		{
			SingleOwnedIndex = AddWeaponToOwnedItemList( TraderItems.SaleItems[ItemIndex], true, ItemInfo.ItemUpgradeLevel);

			// modify default single ammo based on how much ammo dual had when sold
            //      The now new single gun will spawn with default ammo.  We need to correct that down
            //      to the correct amount.  Account for differences in max spare ammo caused by perks.
			AddTransactionAmmo( ItemIndex, ItemInfo.SpareAmmoCount - (ItemInfo.MaxSpareAmmo / 2.0) + ((ItemInfo.MaxSpareAmmo / 2.0) - OwnedItemList[SingleOwnedIndex].SpareAmmoCount), false );

			// update the values in the trader UI
			OwnedItemList[SingleOwnedIndex].SpareAmmoCount = ItemInfo.SpareAmmoCount;
		}
	}

	if(MyGfxManager != none && MyGfxManager.TraderMenu != none)
	{
		MyGfxManager.TraderMenu.OwnedItemList = OwnedItemList;
	}
}

function MergeSingleIntoDual(SItemInformation ExistingDual, SItemInformation NewSingle)
{
    ExistingDual.SpareAmmoCount = Min(ExistingDual.SpareAmmoCount + NewSingle.SpareAmmoCount, ExistingDual.MaxSpareAmmo);
    ExistingDual.SecondaryAmmoCount = Min(ExistingDual.SecondaryAmmoCount + NewSingle.SecondaryAmmoCount, ExistingDual.MaxSecondaryAmmo);
}

function int AddItemByPriority( out SItemInformation WeaponInfo )
{
	local byte i;
	local byte WeaponGroup, WeaponPriority;
	local byte BestIndex;

	BestIndex = 0;
	WeaponGroup = WeaponInfo.DefaultItem.InventoryGroup;
	WeaponPriority = WeaponInfo.DefaultItem.GroupPriority;
	for( i = 0; i < OwnedItemList.length; i++ )
	{
        //Receiving a single for a dual we already own (Ex: Weapon thrown at the player)
        if (WeaponInfo.DefaultItem.DualClassName == OwnedItemList[i].DefaultItem.ClassName)
        {
            MergeSingleIntoDual(OwnedItemList[i], WeaponInfo);
            return i;
        }

		// If the weapon belongs in the group prior to the current weapon, we've found the spot
		if( WeaponGroup < OwnedItemList[i].DefaultItem.InventoryGroup )
		{
			BestIndex = i;
			break;
		}
		else if( WeaponGroup == OwnedItemList[i].DefaultItem.InventoryGroup )
		{
			if( WeaponPriority > OwnedItemList[i].DefaultItem.GroupPriority )
			{
				// if the weapon is in the same group but has a higher priority, we've found the spot
				BestIndex = i;
				break;
			}
			else if( WeaponPriority == OwnedItemList[i].DefaultItem.GroupPriority &&
				WeaponInfo.DefaultItem.AssociatedPerkClasses.Find(CurrentPerk.Class) != INDEX_NONE )
			{
				// if the weapons have the same priority give the slot to the on perk weapon
				BestIndex = i;
				break;
			}
		}
		else
		{
			// Covers the case if this weapon is the only item in the last group
			BestIndex = i + 1;
		}
	}
	OwnedItemList.InsertItem( BestIndex, WeaponInfo );

	// Add secondary ammo immediately after the main weapon
	if( WeaponInfo.DefaultItem.WeaponDef.static.UsesSecondaryAmmo() )
   	{
   		WeaponInfo.bIsSecondaryAmmo = true;
		WeaponInfo.SellPrice = 0;
		OwnedItemList.InsertItem( BestIndex + 1, WeaponInfo );
   	}

	if( MyGfxManager != none && MyGfxManager.TraderMenu != none )
	{
		MyGfxManager.TraderMenu.OwnedItemList = OwnedItemList;
	}

   	return BestIndex;
}

function AddBlocks( int AddedBlocks )
{
	TotalBlocks = Max( TotalBlocks + AddedBlocks, 0 );
}

function GetTraderItems()
{
	TraderItems = KFGameReplicationInfo( WorldInfo.GRI ).TraderItems;
	Initialize();
}

native private final function AddTransactionAmmo( byte ItemIndex, int Amount, bool bSecondaryAmmo );

DefaultProperties
{
	//defaults
	CostPerAutofillCycle=10
	DoshBuffer=150
	ArmorMagSize=25.0f;
}
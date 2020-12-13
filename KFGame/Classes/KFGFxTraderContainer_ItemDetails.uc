//=============================================================================
// KFGFxTraderContainer_ItemDetails
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Author 8/23/2013
//=============================================================================

class KFGFxTraderContainer_ItemDetails extends KFGFxObject_Container
	DependsOn(KFGFxObject_TraderItems);

/** The maximum RPM value, used for scaling the stats bar */
var const float MAX_RPM;
/** The maximum number of objects that can be penetrated value, used for scaling the stats bar */
var const float MAX_PENETRATION;

var KFGFxMenu_Trader MyTraderMenu;

var localized string DamageTitle, FireRateTitle, RangeTitle, PenetrationTitle, BlockTitle, ParryTitle;
var localized string AccuracyTitle, CapacityTitle, MagTitle;
var localized string HealAmountTitle, HealRechargeTitle;

var localized string BuyString, SellString, CannotSellString, CannotBuyString;
var localized string FavoriteString, UnfavoriteString;
var localized string UpgradeCostString, UpgradeString;

var GFxObject DetailsContainer;

/** Max stat values used to calculate stat bars */
const WeaponStatMax_Damage = 820.f;
const WeaponStatMax_FireRate = 800.f;
const WeaponStatMax_Penetration = 4.f;
const WeaponStatMax_Range = 100.f;
const WeaponStatMax_Block = 1.f;
const WeaponStatMax_Parry = 10.f;
const WeaponStatMax_HealAmount = 50.f;
const WeaponStatMax_HealRechargeSpeed = 10.f; // charge per second

var KFPlayerController KFPC;

function Initialize( KFGFxObject_Menu NewParentMenu )
{
	super.Initialize( NewParentMenu );
	MyTraderMenu = KFGFxMenu_Trader( NewParentMenu );

	DetailsContainer = GetObject("detailedStats");
	KFPC = KFPlayerController(GetPC());
	LocalizeContainer();
}

function LocalizeContainer()
{
	local GFxObject LocalizedObject;

 	LocalizedObject = CreateObject("Object");

 	LocalizedObject.SetString("damageTitle", DamageTitle);
 	LocalizedObject.SetString("fireRateTitle", FireRateTitle);
 	LocalizedObject.SetString("penetrationTitle", PenetrationTitle);
 	LocalizedObject.SetString("accuracyTitle", AccuracyTitle);
 	LocalizedObject.SetString("capacityTitle", CapacityTitle);
 	LocalizedObject.SetString("magTitle", MagTitle);

	LocalizedObject.SetString("upgradeCost", UpgradeCostString);

	LocalizedObject.SetString("favorite", UpgradeString);
 	LocalizedObject.SetString("unfavorite", UnfavoriteString);

 	SetObject("localizeContainer", LocalizedObject);
}

function SetDetailsVisible(string DetailName, bool bVisible)
{
	if(DetailsContainer != none)
	{
		DetailsContainer.GetObject(DetailName$"Title").SetVisible(bVisible);
		DetailsContainer.GetObject(DetailName$"Bar").SetVisible(bVisible);
		DetailsContainer.GetObject(DetailName$"Value").SetVisible(false);
	}
}

function SetDetailsText(string DetailName, string NewName)
{
	if(DetailsContainer != none)
	{
		DetailsContainer.GetObject(DetailName$"Title").SetString("text", NewName);
	}
}

function SetShopItemDetails(out STraderItem TraderItem, int ItemPrice, bool bCanCarry, bool bCanBuy)
{
	local GFxObject ItemData;
 	ItemData = CreateObject("Object");

 	ItemData.SetInt("price", ItemPrice);
 	ItemData.SetBool("bUsingBuyLabel", true);

	ItemData.SetString("buyOrSellLabel", BuyString);
	ItemData.SetString("cannotBuyOrSellLabel", CannotBuyString);

 	ItemData.SetBool("bCanCarry", bCanCarry);
 	ItemData.SetBool("bCanBuyOrSell", bCanBuy);

 	ItemData.SetBool("bCanFavorite", true);
	ItemData.SetBool("bCanUpgrade", false);

 	SetGenericItemDetails(TraderItem, ItemData);
}

function SetPlayerItemDetails(out STraderItem TraderItem, int ItemPrice, optional int UpgradeLevel = INDEX_NONE)
{
	local GFxObject ItemData;
	local int CanAffordIndex, CanCarryIndex;

	KFPC.GetPurchaseHelper().CanUpgrade(TraderItem, CanCarryIndex, CanAffordIndex);

	ItemData = CreateObject("Object");

	ItemData.SetInt("price", ItemPrice);
	ItemData.SetBool("bUsingBuyLabel", false);

	ItemData.SetString("buyOrSellLabel", SellString);
	ItemData.SetString("cannotBuyOrSellLabel", CannotSellString);

	ItemData.SetBool("bCanUpgrade", true);
	ItemData.SetBool("bCanBuyUpgrade", CanAffordIndex > 0);
	ItemData.SetBool("bCanCarryUpgrade", CanCarryIndex > 0);

	if (UpgradeLevel > INDEX_NONE)
	{
		if (TraderItem.WeaponDef.static.GetUpgradePrice(UpgradeLevel) == INDEX_NONE)
		{
			ItemData.SetInt("upgradePrice", 0);
			ItemData.SetInt("upgradeWeight", 0);
			ItemData.SetBool("bCanUpgrade", false);
		}
		else
		{
			ItemData.SetInt("upgradePrice", TraderItem.WeaponDef.static.GetUpgradePrice(UpgradeLevel));
			ItemData.SetInt("upgradeWeight", TraderItem.WeaponUpgradeWeight[UpgradeLevel + 1] - TraderItem.WeaponUpgradeWeight[UpgradeLevel]);
		}
	}
	else
	{
		ItemData.SetInt("upgradePrice", 0);
		ItemData.SetInt("upgradeWeight", 0);
	}
	ItemData.SetInt("weaponTier", UpgradeLevel);

	ItemData.SetBool("bCanCarry", true);
	ItemData.SetBool("bCanBuyOrSell", KFPC.GetPurchaseHelper().IsSellable(TraderItem));
	ItemData.SetBool("bHideStats", (TraderItem.WeaponStats.Length == 0));

	ItemData.SetBool("bCanFavorite", true);//KFPC.GetPurchaseHelper().IsSellable(TraderItem));

	SetGenericItemDetails(TraderItem, ItemData, UpgradeLevel);
}

function string GetLocalizedStatString( TraderWeaponStat Stat )
{
	switch( Stat )
	{
	case TWS_Damage:
		return DamageTitle;

	case TWS_RateOfFire:
		return FireRateTitle;

	case TWS_Range:
		return RangeTitle;

	case TWS_Penetration:
		return PenetrationTitle;

	case TWS_Block:
		return BlockTitle;

	case TWS_Parry:
		return ParryTitle;

	case TWS_MagazineSize:
		return MagTitle;

	case TWS_AmmoCapacity:
		return CapacityTitle;

	case TWS_HealAmount:
		return HealAmountTitle;

	case TWS_RechargeTime:
		return HealRechargeTitle;
	};

	return "";
}

function float GetStatMax( TraderWeaponStat Stat )
{
	switch( Stat )
	{
	case TWS_Damage:
		return WeaponStatMax_Damage;

	case TWS_RateOfFire:
		return WeaponStatMax_FireRate;

	case TWS_Range:
		return WeaponStatMax_Range;

	case TWS_Penetration:
		return WeaponStatMax_Penetration;

	case TWS_Block:
		return WeaponStatMax_Block;

	case TWS_Parry:
		return WeaponStatMax_Parry;

	// case TWS_MagazineSize:
	// 	return MagTitle;

	// case TWS_AmmoCapacity:
	// 	return CapacityTitle;

	case TWS_HealAmount:
		return WeaponStatMax_HealAmount;

	case TWS_RechargeTime:
		return WeaponStatMax_HealRechargeSpeed;
	};

	return 1.f;
}

function SetGenericItemDetails(const out STraderItem TraderItem, out GFxObject ItemData, optional int UpgradeLevel = INDEX_NONE)
{
	local KFPerk CurrentPerk;
	local int FinalMaxSpareAmmoCount;
	local int FinalMagazineCapacity;
	local Float DamageValue;
	local Float NextDamageValue;

	//@todo: rename flash objects to something more generic, like stat0text, stat0bar, etc.
	if( TraderItem.WeaponStats.Length >= TWS_Damage && TraderItem.WeaponStats.length > 0)
	{
		DamageValue = TraderItem.WeaponStats[TWS_Damage].StatValue * (UpgradeLevel > INDEX_NONE ? TraderItem.WeaponUpgradeDmgMultiplier[UpgradeLevel] : 1.0f);
		SetDetailsVisible("damage", true);
		SetDetailsText("damage", GetLocalizedStatString(TraderItem.WeaponStats[TWS_Damage].StatType));
		ItemData.SetInt("damageValue", DamageValue);
		ItemData.SetInt("damagePercent", (FMin(DamageValue / GetStatMax(TraderItem.WeaponStats[TWS_Damage].StatType), 1.f) ** 0.5f) * 100.f);

		if (UpgradeLevel + 1 < ArrayCount(TraderItem.WeaponUpgradeDmgMultiplier))
		{
			NextDamageValue = TraderItem.WeaponStats[TWS_Damage].StatValue * TraderItem.WeaponUpgradeDmgMultiplier[UpgradeLevel + 1];
			ItemData.SetInt("damageUpgradePercent", (FMin(NextDamageValue / GetStatMax(TraderItem.WeaponStats[TWS_Damage].StatType), 1.f) ** 0.5f) * 100.f);

		}
		else
		{
			NextDamageValue = DamageValue;
			ItemData.SetInt("damageUpgradePercent", (FMin(DamageValue / GetStatMax(TraderItem.WeaponStats[TWS_Damage].StatType), 1.f) ** 0.5f) * 100.f);
		}
		//`log("THIS IS THE old DAMAGE VALUE: " @((FMin(DamageValue / GetStatMax(TraderItem.WeaponStats[TWS_Damage].StatType), 1.f) ** 0.5f) * 100.f));
		//`log("THIS IS THE NEXT DAMAGE VALUE: " @((FMin(NextDamageValue / GetStatMax(TraderItem.WeaponStats[TWS_Damage].StatType), 1.f) ** 0.5f) * 100.f));
	}
	else
	{
		SetDetailsVisible("damage", false);
	}

	if( TraderItem.WeaponStats.Length >= TWS_Penetration )
	{

		SetDetailsVisible("penetration", true);
		SetDetailsText("penetration", GetLocalizedStatString(TraderItem.WeaponStats[TWS_Penetration].StatType));
		if(TraderItem.TraderFilter != FT_Melee)
		{
			ItemData.SetInt("penetrationValue", TraderItem.WeaponStats[TWS_Penetration].StatValue);
			ItemData.SetInt("penetrationPercent", (FMin(TraderItem.WeaponStats[TWS_Penetration].StatValue / GetStatMax(TraderItem.WeaponStats[TWS_Penetration].StatType), 1.f) ** 0.5f) * 100.f);
		}
		else
		{
			SetDetailsVisible("penetration", false);
		}
	}
	else
	{
		SetDetailsVisible("penetration", false);
	}

	if( TraderItem.WeaponStats.Length >= TWS_RateOfFire )
	{
		SetDetailsVisible("fireRate", true);
		SetDetailsText("fireRate", GetLocalizedStatString(TraderItem.WeaponStats[TWS_RateOfFire].StatType));
		if(TraderItem.TraderFilter != FT_Melee)
		{
			ItemData.SetInt("fireRateValue", TraderItem.WeaponStats[TWS_RateOfFire].StatValue);
			ItemData.SetInt("fireRatePercent", FMin(TraderItem.WeaponStats[TWS_RateOfFire].StatValue / GetStatMax(TraderItem.WeaponStats[TWS_RateOfFire].StatType), 1.f) * 100.f);
		}
		else
		{
			SetDetailsVisible("fireRate", false);
		}
	}
	else
	{
		SetDetailsVisible("fireRate", false);
	}

	//actually range?
	if( TraderItem.WeaponStats.Length >= TWS_Range )
	{
		SetDetailsVisible("accuracy", true);
		SetDetailsText("accuracy", GetLocalizedStatString(TraderItem.WeaponStats[TWS_Range].StatType));
		ItemData.SetInt("accuracyValue", TraderItem.WeaponStats[TWS_Range].StatValue);
		ItemData.SetInt("accuracyPercent", FMin(TraderItem.WeaponStats[TWS_Range].StatValue / GetStatMax(TraderItem.WeaponStats[TWS_Range].StatType), 1.f) * 100.f);

	}
	else
	{
		SetDetailsVisible("accuracy", false);
	}

 	ItemData.SetString("type", TraderItem.WeaponDef.static.GetItemName());
 	ItemData.SetString("name", TraderItem.WeaponDef.static.GetItemCategory());
 	ItemData.SetString("description", TraderItem.WeaponDef.static.GetItemDescription());

	CurrentPerk = KFPlayerController(GetPC()).CurrentPerk;
	if( CurrentPerk != none )
	{
		FinalMaxSpareAmmoCount = TraderItem.MaxSpareAmmo;
		FinalMagazineCapacity = TraderItem.MagazineCapacity;

		CurrentPerk.ModifyMagSizeAndNumber(none, FinalMagazineCapacity, TraderItem.AssociatedPerkClasses,, TraderItem.ClassName);

		// When a perk calculates total available weapon ammo, it expects MaxSpareAmmo+MagazineCapacity
		CurrentPerk.ModifyMaxSpareAmmoAmount(none, FinalMaxSpareAmmoCount, TraderItem,);
		FinalMaxSpareAmmoCount += FinalMagazineCapacity;
	}
	else
	{
		FinalMaxSpareAmmoCount = TraderItem.MaxSpareAmmo;
		FinalMagazineCapacity = TraderItem.MagazineCapacity;
	}

 	ItemData.SetInt("ammoCapacity", FinalMaxSpareAmmoCount);
 	ItemData.SetInt("magSizeValue", FinalMagazineCapacity);

	ItemData.SetInt("weight", MyTraderMenu.GetDisplayedBlocksRequiredFor(TraderItem));

	ItemData.SetBool("bIsFavorite", MyTraderMenu.GetIsFavorite(TraderItem.ClassName));

 	ItemData.SetString("texturePath", "img://"$TraderItem.WeaponDef.static.GetImagePath());
 	if( TraderItem.AssociatedPerkClasses.length > 0 && TraderItem.AssociatedPerkClasses[0] != none )
 	{
 		ItemData.SetString("perkIconPath", "img://"$TraderItem.AssociatedPerkClasses[0].static.GetPerkIconPath());
 		//secondary perk icon
 		if( TraderItem.AssociatedPerkClasses.length > 1 )
 		{
 			ItemData.SetString("perkIconPathSecondary", "img://"$TraderItem.AssociatedPerkClasses[1].static.GetPerkIconPath());
 		}
	}
	else
	{
		ItemData.SetString("perkIconPath", "img://"$class'KFGFxObject_TraderItems'.default.OffPerkIconPath);
	}

 	SetObject("itemData", ItemData);
}

defaultproperties
{
	MAX_RPM=1000
	MAX_PENETRATION=5
}


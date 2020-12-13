//=============================================================================
// KFWeaponDefinition
//=============================================================================
// A lightweight container for basic weapon properties that can be safely
// accessed without a weapon actor (UI, remote clients).
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFWeaponDefinition extends Object
	abstract
	native;

/** weapon class path for DLO */
var string WeaponClassPath;

//used to load in the 3rd person attachment preview
var string AttachmentArchtypePath;

/** Path to the UI thumbnail texture */
var protected string ImagePath;

/** The cost of this weapon ( Sold for .75 this amount ) */
var(Trader) int BuyPrice;
/** Price per magazine */
var(Trader) int AmmoPricePerMag;

/** The cost to upgrade this weapon. */
var(Trader) array<int> UpgradePrice;
/** The added dosh to sell an upgraded weapon. */
var(Trader) array<int> UpgradeSellPrice;

/** How much ammo you will receive for buying a "mag" (or making one purchase) of secondary ammo */
var(Trader) int SecondaryAmmoMagSize;
/** Price to fill the secondary ammo */
var(Trader) int SecondaryAmmoMagPrice;

/** Id for shared unlock if applicable */
var(Trader) ESharedContentUnlock SharedUnlockId;

/** The platform restriction for the weapon */
var(Trader) EPlatformRestriction PlatformRestriction;

/** Theoretical maximum effective range for a weapon. Range is 0-100. */
var() byte EffectiveRange;

/** Returns Gfx image path for this item def */
static function string GetImagePath()
{
	return default.ImagePath;
}

static function string GetItemName()
{
	return GetItemLocalization("ItemName");
}

static function string GetItemCategory()
{
	return GetItemLocalization("ItemCategory");
}

static function string GetItemDescription()
{
	return GetItemLocalization("ItemDescription");
}

static function string GetItemLocalization(string KeyName)
{
	local array<string> Strings;
	ParseStringIntoArray(default.WeaponClassPath, Strings, ".", true);
	return Localize(Strings[1], KeyName, Strings[0]);
}

static function bool UsesAmmo()
{
	return default.AmmoPricePerMag > 0;
}

static function bool UsesSecondaryAmmo()
{
	return default.SecondaryAmmoMagPrice > 0;
}

static function int GetUpgradePrice(int UpgradeTier)
{
	if (UpgradeTier >= 0 && UpgradeTier < default.UpgradePrice.length)
	{
		return default.UpgradePrice[UpgradeTier];
	}

	return INDEX_NONE;
}

static function int GetUpgradeSellPrice(int UpgradeTier)
{
	if (UpgradeTier >= 0 && UpgradeTier < default.UpgradePrice.length)
	{
		return default.UpgradeSellPrice[UpgradeTier];
	}

	return INDEX_NONE;
}

static function int GetTotalUpgradePrice(int UpgradeTier)
{
	local int i, TotalPrice;

	TotalPrice = INDEX_NONE;
	if (UpgradeTier >= 0 && UpgradeTier < default.UpgradePrice.length)
	{
		TotalPrice = 0;
		for (i = 0; i <= UpgradeTier; i++)
		{
			TotalPrice += default.UpgradePrice[UpgradeTier];
		}
	}

	return TotalPrice;
}

DefaultProperties
{
	WeaponClassPath=""

	//UpgradePrice[0]=450
	//UpgradePrice[1]=550
	//UpgradePrice[2]=600
	//UpgradePrice[3]=1000

	//UpgradeSellPrice[0]=337
	//UpgradeSellPrice[1]=750
	//UpgradeSellPrice[2]=1200
	//UpgradeSellPrice[3]=1950
}

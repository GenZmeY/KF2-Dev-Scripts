//=============================================================================
// KFGFxTraderContainer_PlayerInventory
//=============================================================================
// This class holds all of the functions and variables corresponding to the
// players inventory list ( What you currently own ). This class will add
// and remove local item references to the array "OwnedItemList." The player
// will not receive any changed values to his inventory until the menu is
// closed and the the server is told to update the new purchases
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Greg Felber 8/14/2013
//=============================================================================

class KFGFxTraderContainer_PlayerInventory extends KFGFxObject_Container
	DependsOn(KFGFxObject_TraderItems)
	DependsOn(KFGFxMenu_Trader);

enum EButtonStates
{
  	BS_Enabled,
  	BS_MaxCapacity,
  	BS_CantAfford
};

var KFGFxMenu_Trader MyTraderMenu; // Reference to the movie player that owns us

var localized string FillString, MagString, AutoFillString, BuyGrenadeString, ChangePerkString;
var localized string ArmorString;
var KFPlayerController KFPC;
var Float LowAmmoPercentThreshold;
//==============================================================
// Initialization
//==============================================================
function Initialize( KFGFxObject_Menu NewParentMenu )
{
	super.Initialize( NewParentMenu );
	KFPC = KFPlayerController(GetPC());
	MyTraderMenu = KFGFxMenu_Trader( NewParentMenu );
	LocalizeContainer();
	UpdateLock();
}

function LocalizeContainer()
{
	local GFxOBject LocalizedObject;

 	LocalizedObject = CreateObject("Object");

 	LocalizedObject.SetString("autoFill", AutoFillString);
 	LocalizedObject.SetString("armorLabel", FillString);
 	LocalizedObject.SetString("fillLabel", FillString);
 	LocalizedObject.SetString("magLabel", MagString);
 	LocalizedObject.SetString("changePerk", ChangePerkString);
 	LocalizedObject.SetString("grenadeLabel", BuyGrenadeString);

	LocalizedObject.SetString("armorBuyLabel",  class'KFAutoPurchaseHelper'.default.ArmorMagSize$"X");

	//Prompt strings
	LocalizedObject.SetString("sellPrompt", Localize("KFGFxTraderContainer_ItemDetails", "SellString", "KFGame"));
	LocalizedObject.SetString("perkPrompt", Localize("KFGFxTraderContainer_PlayerInventory", "PerkPrompt", "KFGameConsole"));

	SetObject("localizeStrings", LocalizedObject);
}

//Updates the ablility to change the perk
function UpdateLock()
{
	if (KFPC != none)
	{
		SetBool("perkChangeLocked", !KFPC.CanUpdatePerkInfo());
	}
}

//==============================================================
// Update Item List
//==============================================================
// Grab all the items currently in our inventory chain, and add them to the inventory list
function RefreshPlayerInventory()
{
	local byte MagSize, SlotIndex;
	local float PricePerRound;
	local int AmmoCount, MaxAmmoCount, PricePerMag;
	local int FillAmmoCost, BlocksRequired, AutoFillCost;
	local string TextureLocation;
	local GFxObject InfoSlot, MagSlot, FillSlot, SellSlot;
	local GFxObject InfoDataProvider, FillDataProvider, MagDataProvider, SellDataProvider;	// This array of information is sent to ActionScript to update the item data
   	local SItemInformation ItemInfo;

	InfoDataProvider = CreateArray();
	FillDataProvider = CreateArray();
	MagDataProvider = CreateArray();
	SellDataProvider = CreateArray();

	SetArmorInfo(KFPC.GetPurchaseHelper().ArmorItem, AutoFillCost);
	SetGrenadeInfo(KFPC.GetPurchaseHelper().GrenadeItem, AutoFillCost);

	// Iterate through all the items to get the auto fill cost, and update the items
	// for the page we are currently on
   	for ( SlotIndex = 0; SlotIndex < MyTraderMenu.OwnedItemList.Length; SlotIndex++ )
	{
		InfoSlot = CreateObject("Object");
		MagSlot = CreateObject("Object");
		FillSlot = CreateObject("Object");
		SellSlot = CreateObject("Object");

		ItemInfo = MyTraderMenu.OwnedItemList[SlotIndex];
		FillAmmoCost = KFPC.GetPurchaseHelper().GetFillAmmoCost(ItemInfo);

	    if( ItemInfo.bIsSecondaryAmmo )
		{
			TextureLocation = ItemInfo.DefaultItem.SecondaryAmmoImagePath;
			AmmoCount = ItemInfo.SecondaryAmmoCount;
			MaxAmmoCount = ItemInfo.MaxSecondaryAmmo;
			MagSize = ItemInfo.DefaultItem.WeaponDef.default.SecondaryAmmoMagSize;
			PricePerMag = ItemInfo.DefaultItem.WeaponDef.default.SecondaryAmmoMagPrice;
			PricePerRound = ( MagSize > 0 ) ? float(PricePerMag) / float(MagSize) : 0.f;
			BlocksRequired = -1; // This will hide the weight and

			SetItemInfo( InfoSlot, ItemInfo.DefaultItem.WeaponDef, "SecondaryAmmo", TextureLocation, AmmoCount, MaxAmmoCount, BlocksRequired, true );
			SetMagInfo( MagSlot, AmmoCount, MaxAmmoCount, MagSize, PricePerMag, PricePerRound, FillAmmoCost );
			SetFillInfo( FillSlot, AmmoCount, MaxAmmoCount, PricePerRound, FillAmmoCost, AutoFillCost );
		}
		else
		{
			// @temp: Use LastPerkClass to determine correct knife image
			TextureLocation = ItemInfo.DefaultItem.WeaponDef.static.GetImagePath();
			AmmoCount = ItemInfo.SpareAmmoCount;
			MaxAmmoCount = ItemInfo.MaxSpareAmmo;
			MagSize = ItemInfo.MagazineCapacity;
			PricePerMag = ItemInfo.AmmoPricePerMagazine;
			PricePerRound = ( MagSize > 0 ) ? float(PricePerMag) / float(MagSize) : 0.f;
			BlocksRequired = MyTraderMenu.GetDisplayedBlocksRequiredFor(ItemInfo.DefaultItem, ItemInfo.ItemUpgradeLevel);

			SetItemInfo( InfoSlot, ItemInfo.DefaultItem.WeaponDef, "ItemName", TextureLocation, AmmoCount, MaxAmmoCount, BlocksRequired, false, KFPC.GetPurchaseHelper().GetItemUpgradeLevelByClassName(ItemInfo.DefaultItem.ClassName) );
			SetMagInfo( MagSlot, AmmoCount, MaxAmmoCount, MagSize, PricePerMag, PricePerRound, FillAmmoCost );
			SetFillInfo( FillSlot, AmmoCount, MaxAmmoCount, PricePerRound, FillAmmoCost, AutoFillCost );
		}

		SetSellInfo(SellSlot, ItemInfo.SellPrice, ItemInfo.SellPrice > 0);

		InfoDataProvider.SetElementObject( SlotIndex, InfoSlot );
		MagDataProvider.SetElementObject( SlotIndex, MagSlot );
		FillDataProvider.SetElementObject( SlotIndex, FillSlot );
		SellDataProvider.SetElementObject( SlotIndex, SellSlot );
	}

	SetAutoFill(AutoFillCost);

	SetObject("itemData", InfoDataProvider);
	SetObject("magData", MagDataProvider);
	SetObject("fillData", FillDataProvider);
	SetObject("sellData", SellDataProvider);

}

function SetArmorInfo(out SItemInformation ArmorInfo, out int AutoFillCost)
{
	local GFxObject SlotObject;
	local int FillCost, ChunkCost;
	local int ButtonState;

	FillCost = KFPC.GetPurchaseHelper().GetFillArmorCost();
	ChunkCost = KFPC.GetPurchaseHelper().GetChunkArmorCost();

	SlotObject = CreateObject( "Object" );

	SlotObject.SetInt("magCost", ChunkCost);
	SlotObject.SetInt("cost", FillCost);

	SlotObject.SetString("itemName", ArmorString);
	SlotObject.SetString("itemSource", "img://"$ArmorInfo.DefaultItem.WeaponDef.static.GetImagePath());
	SlotObject.SetString("itemAmmo",  ArmorInfo.SpareAmmoCount$"/"$ArmorInfo.MaxSpareAmmo);
	SlotObject.SetBool("lowAmmo", (ArmorInfo.MaxSpareAmmo > 0) ? (float(ArmorInfo.SpareAmmoCount) / float(ArmorInfo.MaxSpareAmmo)) <= LowAmmoPercentThreshold : false);

	ButtonState = GetButtonState( ArmorInfo.AmmoPricePerMagazine, ArmorInfo.SpareAmmoCount, ArmorInfo.MaxSpareAmmo );
	SlotObject.Setint("buttonState", ButtonState );
	SlotObject.Setint("magButtonState", ButtonState );

	SetObject("armorInfo", SlotObject);
	AutoFillCost += FillCost;
}

function SetGrenadeInfo(out SItemInformation GrenadeInfo, out int AutoFillCost)
{
	local GFxObject SlotObject;
	local int FillCost;
	local int MagCost;
	local int ButtonState;
	local int AmmoPricePerMagazine;

    AmmoPricePerMagazine = GrenadeInfo.AmmoPricePerMagazine;

	SlotObject = CreateObject("Object");
	SlotObject.SetString("itemSource", "img://" $ GrenadeInfo.DefaultItem.WeaponDef.static.GetImagePath());
	SlotObject.SetString("itemName", GrenadeInfo.DefaultItem.WeaponDef.static.GetItemName());

	FillCost = KFPC.GetPurchaseHelper().GetFillGrenadeCost();
	MagCost = (GrenadeInfo.SpareAmmoCount != GrenadeInfo.MaxSpareAmmo) ? GrenadeInfo.AmmoPricePerMagazine : 0;
	SlotObject.SetInt("magCost", MagCost);
	SlotObject.SetInt("fillCost", FillCost);
	SlotObject.SetBool("lowAmmo", (GrenadeInfo.MaxSpareAmmo > 0) ? (float(GrenadeInfo.SpareAmmoCount) / float(GrenadeInfo.MaxSpareAmmo)) <= LowAmmoPercentThreshold : false);
	SlotObject.SetString("itemAmmo", GrenadeInfo.SpareAmmoCount $"/"$GrenadeInfo.MaxSpareAmmo);
	ButtonState = GetButtonState(AmmoPricePerMagazine, GrenadeInfo.SpareAmmoCount, GrenadeInfo.MaxSpareAmmo);

	SlotObject.Setint("magButtonState", ButtonState);
	SlotObject.Setint("fillButtonState", ButtonState);

	SetObject("grenadeInfo", SlotObject);
	AutoFillCost += FillCost;
}

function SetItemInfo(out GFxObject InfoSlot, class<KFWeaponDefinition> WeaponDef, string ItemKeyString, string TextureLocation, int AmmoCount, int MaxAmmoCount, int BlocksRequired, optional bool bSecondaryAmmo, optional int UpgradeLevel )
{
	local string ItemTexPath;

    InfoSlot.SetString( "itemName", WeaponDef.static.GetItemLocalization(ItemKeyString) );
    InfoSlot.SetString( "itemAmmo", AmmoCount $"/" $MaxAmmoCount);
    InfoSlot.Setint( "itemWeight", BlocksRequired );
	InfoSlot.Setint("weaponTier", UpgradeLevel);

    InfoSlot.SetBool("lowAmmo", (MaxAmmoCount > 0) ? (float(AmmoCount) / float(MaxAmmoCount)) <= LowAmmoPercentThreshold : false );
    InfoSlot.SetBool("isSubAmmo", bSecondaryAmmo );

    ItemTexPath = "img://"$TextureLocation;
    InfoSlot.SetString( "itemSource", ItemTexPath );
}

function SetMagInfo(out GFxObject MagSlot, int AmmoCount, int MaxAmmoCount, byte AmmoMagSize, int PricePerMag, float PricePerRound, int FillAmmoCost)
{
	local int MagCost;
	local bool bBuyPartialMag;

	bBuyPartialMag = AmmoCount + AmmoMagSize > MaxAmmoCount;
    MagCost = ( bBuyPartialMag ) ? FillAmmoCost : PricePerMag;

   	MagSlot.SetString("label", MagString);
	MagSlot.SetInt("buttonValue", MagCost);
    MagSlot.SetInt("buttonState", GetButtonState( PricePerRound, AmmoCount, MaxAmmoCount));
}

function SetFillInfo(out GFxObject FillSlot, int AmmoCount, int MaxAmmoCount, float PricePerRound, int FillAmmoCost, out int AutoFillCost)
{
    FillSlot.SetString("label", FillString);
	FillSlot.SetInt("buttonValue", FillAmmoCost);
	FillSlot.SetInt("buttonState", GetButtonState( PricePerRound, AmmoCount, MaxAmmoCount ));

    AutoFillCost += FillAmmoCost;
}

// Sell list data being added to trader menu, setup the data - HSL
function SetSellInfo(out GFxObject SellSlot, int SellPrice, bool bCanSell)
{
	SellSlot.SetString("label", Localize("KFGFxTraderContainer_ItemDetails", "SellString", "KFGame"));
	SellSlot.SetInt("buttonValue", SellPrice);
	SellSlot.SetBool("buttonState", bCanSell);
}


function SetAutoFill(int AutoFillCost)
{
	local GFxObject AutoFillObject;

    AutoFillObject = CreateObject("Object");

	AutoFillObject.SetInt("buttonValue", AutoFillCost);
	// Only disable this button if we have all the ammo
	AutoFillObject.SetInt("buttonState", GetButtonState(0, 0, AutoFillCost));

	SetObject("autoFillCost", AutoFillObject);
}

// Change the look of the button dependant on if we can afford it, or are at max capacity
function int GetButtonState( float Price, int SpareAmmoCount, int MaxSpareAmmoCount )
{
	if ( SpareAmmoCount >= MaxSpareAmmoCount )
	{
	 	return BS_MaxCapacity;
	}
	else if ( KFPC.GetPurchaseHelper().TotalDosh < Price )
	{
	 	return BS_CantAfford;
	}

	return BS_Enabled;
}

DefaultProperties
{
	LowAmmoPercentThreshold=0.5f
}
//=============================================================================
// KFGFxHUD_WeaponSelectWidget
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Greg Felber 5/20/2014
//=============================================================================


class KFGFxHUD_WeaponSelectWidget extends GFxObject;

const MAX_WEAPON_GROUPS = 4;
var bool bChangingWeapons;
var localized string			PrimaryString;
var localized string			EquiptmentString;
var localized string			MeleeString;
var localized string			SecondaryString;
var localized string 			ThrowString;

var string ThrowGBA;

/** How many weapons were in the inventory last time we counted */
var byte LastRefreshInvCount;

function InitializeObject()
{
	SetWeaponCategories();
	SetString("throwString", ThrowString);
	SetThowButton();
}

simulated function RefreshWeaponSelect()
{
	local byte i;	
	for (i = 0; i < MAX_WEAPON_GROUPS; i++)
	{
		UpdateWeaponGroupOnHUD(i);
	}
	SetThowButton();
}

function SetThowButton()
{
	local KFPlayerInput KFPI;
	local KeyBind BoundKey;

	KFPI = KFPlayerInput(GetPC().PlayerInput);

	if(KFPI != none)
	{
		KFPI.GetKeyBindFromCommand(BoundKey, ThrowGBA, false);

		SetString("throwButton", String(BoundKey.Name) );
	}
}

simulated function UpdateWeaponGroupOnHUD( byte GroupIndex )
{
   	local Inventory Inv;
   	local KFWeapon KFW;
	local array<KFWeapon> WeaponGroup;

	if ( GetPC().Pawn == none || GetPC().Pawn.InvManager == none )
	{
		return;
	}

	for ( Inv = GetPC().Pawn.InvManager.InventoryChain; Inv != none; Inv = Inv.Inventory )
	{
		KFW = KFWeapon( Inv );
		if ( KFW != none && KFW.InventoryGroup == GroupIndex )
		{
			WeaponGroup.AddItem(KFW);
		}
	}

	SetWeaponGroupList(WeaponGroup, GroupIndex);
}

simulated function SetWeaponGroupList(out array<KFWeapon> WeaponList, byte GroupIndex)
{
	local byte i;
	local GFxObject DataProvider;
	local GFxObject TempObj;
	local bool bUsesAmmo;
	

	DataProvider = CreateArray();
	if ( DataProvider == None )
	{
		return; // gfx has been shut down
	}

	for (i = 0; i < WeaponList.length; i++)
	{
	    TempObj = CreateObject( "Object" );
		if (WeaponList[i].CurrentWeaponUpgradeIndex > 0)
		{
			TempObj.SetString("weaponName", WeaponList[i].ItemName);
		}
		else
		{
			TempObj.SetString("weaponName", WeaponList[i].ItemName );
		}
		TempObj.SetInt("weaponTier", WeaponList[i].CurrentWeaponUpgradeIndex);
	    TempObj.SetString( "texturePath",  "img://"$PathName(WeaponList[i].WeaponSelectTexture));
		TempObj.SetInt( "ammoCount", WeaponList[i].AmmoCount[0]);
		TempObj.SetInt( "spareAmmoCount", WeaponList[i].SpareAmmoCount[0]);
		//secondary ammo shenanigans
		TempObj.SetBool("bUsesSecondaryAmmo", WeaponList[i].UsesSecondaryAmmo()&&WeaponList[i].bCanRefillSecondaryAmmo);
		TempObj.SetBool("bEnabled", WeaponList[i].HasAnyAmmo());
		if(WeaponList[i].UsesSecondaryAmmo() && WeaponList[i].bCanRefillSecondaryAmmo)
		{
			TempObj.SetBool("bCanRefillSecondaryAmmo", WeaponList[i].SpareAmmoCapacity[1] > 0);
			TempObj.SetInt( "secondaryAmmoCount", WeaponList[i].AmmoCount[1]);
			TempObj.SetInt( "secondarySpareAmmoCount", WeaponList[i].SpareAmmoCount[1]);
		}

		TempObj.SetBool( "throwable", WeaponList[i].CanThrow());

		bUsesAmmo = (WeaponList[i].static.UsesAmmo());
		TempObj.SetBool( "bUsesAmmo", bUsesAmmo);
	    DataProvider.SetElementObject( i, TempObj );
	}

	SetWeaponList(DataProvider, GroupIndex);
}

simulated function SetWeaponList( GFxObject WeaponList, int GroupIndex )
{
	ActionScriptVoid("setWeaponList");
}

function SetSelectedWeapon( int GroupIndex, int SelectedIndex)
{
	if (!KFPlayerInput(GetPC().PlayerInput).bQuickWeaponSelect && !bChangingWeapons)
	{
		bChangingWeapons = true; 
	}

	SendWeaponIndex(GroupIndex, SelectedIndex);
}

/** Find KFWeapon instance from highlight */
function Weapon GetSelectedWeapon()
{
	return GetPC().Pawn.InvManager.PendingWeapon;
}

function UpdateIndex()
{
	ActionScriptVoid("updateIndex");
	bChangingWeapons = false;
}

function Hide()
{
	SetWeaponSwitchStayOpen(false);
    Fadeout();
}

function SetWeaponCategories( )
{
	local GFxObject CategoriesObj;

	CategoriesObj = CreateObject( "Object" );

	CategoriesObj.SetString( "Primary", PrimaryString );
	CategoriesObj.SetString( "Backup",  SecondaryString );
	CategoriesObj.SetString( "Melee",  MeleeString );
	CategoriesObj.SetString( "Equipment",  EquiptmentString );

	SetObject("weaponCategories", CategoriesObj);
}

function SendWeaponIndex( int GroupIndex, int SelectedIndex )
{
	ActionScriptVoid("setSelectedIndex");
}

function ShowOnlyHUDGroup( byte GroupIndex )
{
	UpdateWeaponGroupOnHUD(GroupIndex);
	ActionScriptVoid("showOnlyHUDGroup");
}

function ShowAllHUDGroups()
{
	ActionScriptVoid("showAllHUDGroups");
}

/** 
 * Timer to catch inventory changes while menu is open.  Can't rely on
 * events since the InventoryChain doesn't have a replicated event 
 */
function RefreshTimer()
{
	local Inventory Inv;
	local int InvCount;
	local KFInventoryManager KFIM;

	for ( Inv = GetPC().Pawn.InvManager.InventoryChain; Inv != none; Inv = Inv.Inventory )
	{
		InvCount++;
	}

	// RefreshWeaponSelect is not cheap, so only update if we gained or lost a weapon
	if ( InvCount != LastRefreshInvCount )
	{
		RefreshWeaponSelect();

		// Make sure that we have a valid selection
		if( GetPC().Pawn.InvManager != none )
		{
			KFIM = KFInventoryManager( GetPC().Pawn.InvManager );
			if( KFIM != none )
			{
				KFIM.UpdateHUD();
			}
		}
	}
	LastRefreshInvCount = InvCount;
}

function SetWeaponSwitchStayOpen(bool bStayOpen)
{
	local Inventory Inv;

	if ( bStayOpen )
	{
		LastRefreshInvCount = 0;
		for ( Inv = GetPC().Pawn.InvManager.InventoryChain; Inv != none; Inv = Inv.Inventory )
		{
			LastRefreshInvCount++;
		}
		GetPC().SetTimer(0.33f, true, nameof(RefreshTimer), self);
	}
	else
	{
		GetPC().ClearTimer(nameof(RefreshTimer), self);
	}

	SetBool("bStayOpen", bStayOpen);
}

function FadeOut()
{
	bChangingWeapons = false;
}

DefaultProperties
{
	ThrowGBA="GBA_AltFire_Gamepad"
}

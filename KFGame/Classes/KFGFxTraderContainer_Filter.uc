//=============================================================================
// KFGFxComponent_TraderFilter
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Greg Felber 8/12/2013
//=============================================================================

class KFGFxTraderContainer_Filter extends KFGFxObject_Container;

var localized array<string> TabsArray;
var localized array<string> WeaponTypeStrings;
var localized string OffPerkString;

var array<string> TabIconPaths;
var array<string> WeaponTypePath;

function ClearFilters()
{
	SetString("filterText", "");
	SetBool("filterVisibliity", false);
}

function SetPerkFilterData(byte FilterIndex)
{
 	local int i;
	local GFxObject DataProvider;
	local GFxObject FilterObject;
	local KFPlayerController KFPC;
	local KFPlayerReplicationInfo KFPRI;

	SetBool("filterVisibliity", true);

    KFPC = KFPlayerController( GetPC() );
	if ( KFPC != none )
	{
		KFPRI = KFPlayerReplicationInfo(KFPC.PlayerReplicationInfo);
		if ( KFPRI != none )
		{
			SetInt("selectedIndex", KFPRI.NetPerkIndex);

			// Set the title of this filter based on either the perk or the off perk string
			if( FilterIndex < KFPC.PerkList.Length )
			{
				SetString("filterText", KFPC.PerkList[FilterIndex].PerkClass.default.PerkName);
			}
			else
			{
				SetString("filterText", OffPerkString);
			}

		   	DataProvider = CreateArray();
			for (i = 0; i < KFPC.PerkList.Length; i++)
			{
				FilterObject = CreateObject( "Object" );
				FilterObject.SetString("source",  "img://"$KFPC.PerkList[i].PerkClass.static.GetPerkIconPath());
				FilterObject.SetBool("isMyPerk",  KFPC.PerkList[i].PerkClass == KFPC.CurrentPerk.class);
			    DataProvider.SetElementObject( i, FilterObject );
			}

			FilterObject = CreateObject( "Object" );
			FilterObject.SetString("source",  "img://"$class'KFGFxObject_TraderItems'.default.OffPerkIconPath);
			DataProvider.SetElementObject( i, FilterObject );

			SetObject( "filterSource", DataProvider );
    	}
    }
}

function SetTypeFilterData(byte FilterIndex)
{
 	local int i;
	local GFxObject DataProvider;
	local GFxObject FilterObject;

	SetBool("filterVisibliity", true);
	SetString("filterText", WeaponTypeStrings[FilterIndex]);

   	DataProvider = CreateArray();
	for (i = 0; i < WeaponTypePath.Length; i++)
	{
		FilterObject = CreateObject( "Object" );
		FilterObject.SetString("source",  "img://"$WeaponTypePath[i]);
	    DataProvider.SetElementObject( i, FilterObject );
	}

	SetObject( "filterSource", DataProvider );
}

function SetTabsData()
{
 	local int i;
	local GFxObject DataProvider;
	local GFxObject FilterObject;
	local KFPlayerController KFPC;
	local KFPlayerReplicationInfo KFPRI;

    KFPC = KFPlayerController( GetPC() );
	if (KFPC != none)
	{
		KFPRI = KFPlayerReplicationInfo(KFPC.PlayerReplicationInfo);
		if (KFPRI != none)
		{
		   	DataProvider = CreateArray();
			for (i = 0; i < TabsArray.Length; i++)
			{
				FilterObject = CreateObject( "Object" );
				FilterObject.SetString("label", TabsArray[i]);
				FilterObject.SetString("source",  "img://"$TabIconPaths[i]);
			    DataProvider.SetElementObject( i, FilterObject );
			}

			SetObject("tabInfo", DataProvider);
    	}
    }
}

DefaultProperties
{
	TabIconPaths.Add("UI_TraderMenu_TEX.UI_WeaponSelect_Trader_Perk");
	TabIconPaths.Add("UI_TraderMenu_TEX.UI_WeaponSelect_Trader_Type");
	TabIconPaths.Add("UI_TraderMenu_TEX.UI_WeaponSelect_Trader_Favorites");
	TabIconPaths.Add("UI_TraderMenu_TEX.UI_WeaponSelect_Trader_All");

	WeaponTypePath.Add("UI_WeaponType_TEX.UI_WeaponType_Pistol")
	WeaponTypePath.Add("UI_WeaponType_TEX.UI_WeaponType_Shotgun")
	WeaponTypePath.Add("UI_WeaponType_TEX.UI_WeaponType_Rifle")
	WeaponTypePath.Add("UI_WeaponType_TEX.UI_WeaponType_Projectile")
	WeaponTypePath.Add("UI_WeaponType_TEX.UI_WeaponType_Flame")
	WeaponTypePath.Add("UI_WeaponType_TEX.UI_WeaponType_Electric")
	WeaponTypePath.Add("UI_WeaponType_TEX.UI_WeaponType_Explosive")
	WeaponTypePath.Add("UI_WeaponType_TEX.UI_WeaponType_Assault")
	WeaponTypePath.Add("UI_WeaponType_TEX.UI_WeaponType_Melee")
	WeaponTypePath.Add("UI_WeaponType_TEX.UI_WeaponType_SMG")
}
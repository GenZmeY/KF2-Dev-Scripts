//=============================================================================
// KFGFxPerksContainer_Details
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Author 12/10/2013
//=============================================================================

class KFGFxPerksContainer_Details extends KFGFxPerksContainer;

var localized string ExperienceString, ObjectivesString, PerkBonusesString, BasicLoadoutString;

function Initialize( KFGFxObject_Menu NewParentMenu )
{
	super.Initialize( NewParentMenu );
	LocalizeContainer();
}

function  LocalizeContainer()
{
	GetObject("objectivesTitleTextField").SetString("text", ObjectivesString);
	GetObject("perkBonusTextField").SetString("text", PerkBonusesString);
	GetObject("basicLoadoutTextField").SetString("text", BasicLoadoutString);
}

function UpdateDetailsInternal(class<KFPerk> PerkClass, KFPlayerController KFPC, byte WeaponIdx, byte GrenadeIdx)
{
	local GFxObject DetailsProvider;
	local array<string> WeaponNames;
	local array<string> WeaponSources;
	local int i;

	DetailsProvider = CreateObject( "Object" );

	DetailsProvider.SetString( "ExperienceMessage", ExperienceString @ KFPC.GetPerkXP(PerkClass) );

	if(PerkClass.default.PrimaryWeaponDef != none)
	{
		AddWeaponInfo(WeaponNames, WeaponSources, PerkClass.static.GetPrimaryWeaponName(WeaponIdx), PerkClass.static.GetPrimaryWeaponImagePath(WeaponIdx));
	}

	if(PerkClass.default.SecondaryWeaponDef != none)
	{
		AddWeaponInfo(WeaponNames, WeaponSources, PerkClass.default.SecondaryWeaponDef.static.GetItemName(), PerkClass.default.SecondaryWeaponDef.static.GetImagePath());
	}
	if(PerkClass.default.KnifeWeaponDef != none)
	{
		AddWeaponInfo(WeaponNames, WeaponSources, PerkClass.default.KnifeWeaponDef.static.GetItemName(), PerkClass.default.KnifeWeaponDef.static.GetImagePath());
	}
	if(PerkClass.default.GrenadeWeaponDef != none)
	{
		AddWeaponInfo(WeaponNames, WeaponSources, PerkClass.static.GetGrenadeWeaponName(GrenadeIdx), PerkClass.static.GetGrenadeWeaponImagePath(GrenadeIdx));
	}
	
	for (i = 0; i < WeaponNames.length; i++)
	{
		DetailsProvider.SetString( "WeaponName" $ i, WeaponNames[i] );		
		DetailsProvider.SetString( "WeaponImage" $ i, "img://"$WeaponSources[i] );			
	}

	DetailsProvider.SetString( "EXPAction1", PerkClass.default.EXPAction1 );
	DetailsProvider.SetString( "EXPAction2", PerkClass.default.EXPAction2 );		

	DetailsProvider.SetBool("ShowPrimaryWeaponSelectors", PerkClass.static.CanChoosePrimaryWeapon());
	DetailsProvider.SetBool("ShowGrenadeSelectors", PerkClass.static.CanChooseGrenade());

	SetObject( "detailsData", DetailsProvider );
}

function UpdateDetails(class<KFPerk> PerkClass, byte SelectedSkills[`MAX_PERK_SKILLS], bool IsChoosingPrev, bool IsChoosingNext)
{
	local KFPlayerController KFPC;
	local byte WeaponIdx, GrenadeIdx;

	KFPC = KFPlayerController( GetPC() );  

	if ( KFPC == none)
	{
		return;
	}

	WeaponIdx = 0;
	GrenadeIdx = 0;

	UpdateAndGetCurrentWeaponIndexes(PerkClass, KFPC, WeaponIdx, GrenadeIdx, SelectedSkills, IsChoosingPrev, IsChoosingNext);

	UpdateDetailsInternal(PerkClass, KFPC, WeaponIdx, GrenadeIdx);
}

function AddWeaponInfo(out array<string> WeaponNames, out array<string> WeaponSources, string WeaponName, string WeaponSource)
{
	WeaponNames.AddItem(WeaponName);
	WeaponSources.AddItem(WeaponSource);
}


function UpdatePassives(Class<KFPerk> PerkClass)
{
	local GFxObject PassivesProvider;
	local GFxObject PassiveObject;
	local KFPlayerController KFPC;
	local array<string> PassiveValues, Increments;
	local byte i;
	KFPC = KFPlayerController( GetPC() );

  	if ( KFPC != none )
  	{
		PerkClass.static.GetPassiveStrings( PassiveValues, Increments, KFPC.GetPerkLevelFromPerkList(PerkClass));

		PassivesProvider = CreateArray();
		for ( i = 0; i < PassiveValues.length; i++ )
	   	{
            PassiveObject = CreateObject( "Object" );
		    PassiveObject.SetString( "PassiveTitle", PerkClass.default.Passives[i].Title );
		    PassiveObject.SetString( "PerkBonusModifier", Increments[i]); 
		    PassiveObject.SetString( "PerkBonusAmount", PassiveValues[i] );
		    PassivesProvider.SetElementObject( i, PassiveObject );
	    }
    }

    SetObject( "passivesData", PassivesProvider );
}

function UpdateAndGetCurrentWeaponIndexes(class<KFPerk> PerkClass, KFPlayerController KFPC, out byte WeaponIdx, out byte GrenadeIdx
											, byte SelectedSkills[`MAX_PERK_SKILLS], bool IsChoosingPrev, bool IsChoosingNext)
{
	if (PerkClass.Name == 'KFPerk_Survivalist')
	{
		WeaponIdx = KFPC.CurrentPerk.SetWeaponSelectedIndex(KFPC.SurvivalPerkWeapIndex);
		GrenadeIdx = KFPC.CurrentPerk.SetGrenadeSelectedIndexUsingSkills(KFPC.SurvivalPerkGrenIndex, SelectedSkills, IsChoosingPrev, IsChoosingNext);
	}
}

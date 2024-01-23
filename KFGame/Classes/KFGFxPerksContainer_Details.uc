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

function bool CanChooseWeapons(KFPlayerController KFPC)
{
	local KFGameReplicationInfo KFGRI;

	KFGRI = KFGameReplicationInfo(KFPC.WorldInfo.GRI);

	if (KFPC != none)
	{
		if (KFPC.Pawn.IsAliveAndWell() == false
			|| KFPC.PlayerReplicationInfo.bIsSpectator
			|| KFPC.PlayerReplicationInfo.bOnlySpectator)
		{
			return true;
		}
	}

	if (KFGRI != none)
	{
		if (KFGRI.WaveNum == 0)
		{
			if (KFGRI.bWaveStarted)
			{
				return false;
			}
		}
		else
		{
			return false;
		}
	}

	return true;
}

function UpdateDetailsInternal(class<KFPerk> PerkClass, KFPlayerController KFPC, byte WeaponIdx, byte SecondaryWeaponIdx, byte GrenadeIdx)
{
	local GFxObject DetailsProvider;
	local array<string> WeaponNames;
	local array<string> WeaponSources;
	local int i;
	local bool CanIChooseWeapons;

	DetailsProvider = CreateObject( "Object" );

	DetailsProvider.SetString( "ExperienceMessage", ExperienceString @ KFPC.GetPerkXP(PerkClass) );

	if(PerkClass.default.PrimaryWeaponDef != none)
	{
		AddWeaponInfo(WeaponNames, WeaponSources, PerkClass.static.GetPrimaryWeaponName(WeaponIdx), PerkClass.static.GetPrimaryWeaponImagePath(WeaponIdx));
	}

	if(PerkClass.default.SecondaryWeaponPaths.Length > 0)
	{
		AddWeaponInfo(WeaponNames, WeaponSources, PerkClass.static.GetSecondaryWeaponName(SecondaryWeaponIdx), PerkClass.static.GetSecondaryWeaponImagePath(SecondaryWeaponIdx));
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

	CanIChooseWeapons = CanChooseWeapons(KFPC);

	DetailsProvider.SetBool("ShowPrimaryWeaponSelectors", CanIChooseWeapons && PerkClass.static.CanChoosePrimaryWeapon());
	DetailsProvider.SetBool("ShowSecondaryWeaponSelectors", CanIChooseWeapons && PerkClass.static.CanChooseSecondaryWeapon());

	DetailsProvider.SetBool("ShowGrenadeSelectors", PerkClass.static.CanChooseGrenade());

	SetObject( "detailsData", DetailsProvider );
}

function UpdateDetails(class<KFPerk> PerkClass, byte SelectedSkills[`MAX_PERK_SKILLS], bool IsChoosingPrev, bool IsChoosingNext, bool UpdateUI)
{
	local KFPlayerController KFPC;
	local byte WeaponIdx, SecondaryWeaponIdx, GrenadeIdx;

	KFPC = KFPlayerController( GetPC() );  

	if ( KFPC == none)
	{
		return;
	}

	WeaponIdx = 0;
	SecondaryWeaponIdx = 0;
	GrenadeIdx = 0;

	UpdateAndGetCurrentWeaponIndexes(PerkClass, KFPC, WeaponIdx, SecondaryWeaponIdx, GrenadeIdx, SelectedSkills, IsChoosingPrev, IsChoosingNext);

	if (UpdateUI)
	{
		UpdateDetailsInternal(PerkClass, KFPC, WeaponIdx, SecondaryWeaponIdx, GrenadeIdx);
	}
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

function UpdateAndGetCurrentWeaponIndexes(class<KFPerk> PerkClass, KFPlayerController KFPC, out byte WeaponIdx, out byte SecondaryWeaponIdx, out byte GrenadeIdx
											, byte SelectedSkills[`MAX_PERK_SKILLS], bool IsChoosingPrev, bool IsChoosingNext)
{
	local KFGameReplicationInfo KFGRI;

	KFGRI = KFGameReplicationInfo(KFPC.WorldInfo.GRI);

	SecondaryWeaponIdx = PerkClass.static.GetSecondaryWeaponSelectedIndex(KFPC.SurvivalPerkSecondaryWeapIndex);

	if (KFPC.CurrentPerk.Class.Name == PerkClass.Name)
	{
		KFPC.CurrentPerk.StartingSecondaryWeaponClassIndex = SecondaryWeaponIdx;
	}

	if (PerkClass.Name == 'KFPerk_Survivalist')
	{
		WeaponIdx = PerkClass.static.GetWeaponSelectedIndex(KFPC.SurvivalPerkWeapIndex);
		GrenadeIdx = PerkClass.static.GetGrenadeSelectedIndexUsingSkills(KFPC.SurvivalPerkGrenIndex, SelectedSkills, IsChoosingPrev, IsChoosingNext);

		if (KFPC.CurrentPerk.Class.Name == PerkClass.Name)
		{
			KFPerk_Survivalist(KFPC.CurrentPerk).StartingWeaponClassIndex = WeaponIdx;
			KFPerk_Survivalist(KFPC.CurrentPerk).StartingGrenadeClassIndex = GrenadeIdx;

			// If we are in no gameplay time insta change
			if (!KFGRI.bWaveIsActive || KFPC.PlayerReplicationInfo.bIsSpectator)
			{
				KFPerk_Survivalist(KFPC.CurrentPerk).UpdateCurrentGrenade();
			}
		}
	}
}

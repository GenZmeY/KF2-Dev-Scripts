//=============================================================================
// KFGFxPerksContainer_Skills
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Author 12/11/2013
//=============================================================================

class KFGFxPerksContainer_Skills extends KFGFxPerksContainer
	DependsOn(KFPerk) DependsOn(KFGFxMenu_Perks);

var const int MAX_SLOTS;

var localized string ConfigureSkillsString, BackButtonString;

function Initialize( KFGFxObject_Menu NewParentMenu )
{
	super.Initialize( NewParentMenu );
	LocalizeContainer();
}

function  LocalizeContainer()
{
	GetObject("confirmButton").SetString("label", BackButtonString);
	GetObject("titleTextfield").SetString("text", ConfigureSkillsString);
}

function UpdateSkills( class<KFPerk> PerkClass, const out byte SelectedSkills[`MAX_PERK_SKILLS] )
{
	local KFPlayerController KFPC;
	local bool bShouldUnlock;
	local byte i, j, UnlockLevel;
	local GFxObject DataProvider,TempObj;
	local int PerkLevel;

  	KFPC = KFPlayerController( GetPC() );
	
	DataProvider = CreateArray();

    for ( i = 0; i < `MAX_PERK_SKILLS; i++ )
	{
		TempObj = CreateObject( "Object" );
        TempObj.SetString( "label", PerkClass.default.SkillCatagories[i] );
		UnlockLevel = class'KFPerk'.const.RANK_1_LEVEL + ( class'KFPerk'.const.UNLOCK_INTERVAL * i );
		TempObj.SetString( "unlockLevel", LevelString@ UnlockLevel );
		PerkLevel = KFPC.GetPerkLevelFromPerkList( PerkClass );
		bShouldUnlock = ( UnlockLevel <= PerkLevel );
		TempObj.SetBool( "bUnlocked", bShouldUnlock );
		TempObj.SetInt( "selectedSkill", SelectedSkills[i] );

		for (j = 0; j < MAX_SLOTS; j++)
		{
			TempObj.SetObject("skill"$j,  GetSkillObject(i, j, bShouldUnlock, PerkClass));	
		}

		DataProvider.SetElementObject( i, TempObj );
	}
	
	SetObject("skillList", DataProvider);
}

function UpdateTierUnlockState(class<KFPerk> PerkClass)
{
	local byte bTierUnlocked;
	local int PerkLevel;
	local KFPlayerController KFPC;

	if(PerkClass == none)
	{
		return;
	}

	KFPC = KFPlayerController(GetPC());

	PerkLevel = KFPC.GetPerkLevelFromPerkList( PerkClass );

	class'KFPerk'.static.LoadTierUnlockFromConfig(PerkClass, bTierUnlocked, PerkLevel);
	if( bool(bTierUnlocked) )
	{
		class'KFPerk'.static.SaveTierUnlockToConfig(PerkClass, 0, PerkLevel);
	}
}

function GFxObject GetSkillObject(byte TierIndex, byte SkillIndex, bool bShouldUnlock, class<KFPerk> PerkClass)
{
	local GFxObject SkillObject;
	local string SkillName, SkillDescription;
	local string IconPath;
	local int PerkSkillIndex;
	local array<PerkSkill> PerkSkillArr;

	PerkSkillArr = PerkClass.default.PerkSkills;
	PerkSkillIndex = (TierIndex * 2) + (SkillIndex);	

	if(PerkSkillIndex < PerkClass.Default.PerkSkills.length )
	{
		SkillObject = CreateObject( "Object" );
		SkillName = Localize(String(PerkClass.Name), PerkSkillArr[PerkSkillIndex].Name, "KFGame");
		SkillObject.SetString("label", SkillName);
		SkillDescription = Localize(String(PerkClass.Name), PerkSkillArr[PerkSkillIndex].Name$"Description", "KFGame");
		SkillObject.SetString("description", SkillDescription);

		if(bShouldUnlock)
		{
			IconPath = PerkSkillArr[PerkSkillIndex].IconPath;
		}
		else
		{
			IconPath =  KFGFxMenu_Perks(ParentMenu).LockIconPath;
		}
	}

	if(IconPath == "")
	{
		IconPath = PerkClass.static.GetPerkIconPath();
	}

	SkillObject.SetString("iconSource", "img://"$IconPath);
	return SkillObject;
}

defaultproperties()
{
	MAX_SLOTS=2
}

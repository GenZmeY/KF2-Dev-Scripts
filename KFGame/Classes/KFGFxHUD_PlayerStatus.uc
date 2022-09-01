//=============================================================================
// KFGFxInGameHUD_PlayerStatus
//=============================================================================
// HUD container that stores information about the player's pawn (Health, armor, etc)
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Alex Quick 5/15/2014
//=============================================================================

class KFGFxHUD_PlayerStatus extends GFxObject;

/** Cached KFPlayerController */
var KFPlayerController 				MyPC;
var KFGameReplicationinfo 			KFGRI;
var KFPawn_Human                    MyHumanPawn;
var KFInventoryManager              MyInventoryManager;
// Player's perk type as of the last tick.
var class<KFPerk>					LastPerkClass;
// The experience level of the player's perk as of the last tick.
var int                             LastPerkLevel;
// Player's health as of last tick.
var int 							LastHealth;
// Player's armor amount as of the last tick.
var int								LastArmor;
// Percentage of full ammo the player's healer had as of the last tick. (0-1, where 1 is full)
var float                           LastHealerAmmoPct;

var int                             LastEXPValue;

var localized string EXPString;

var float LastUpdateTime;

function InitializeHUD()
{
	MyPC = KFPlayerController(GetPC());    
    LocalizeText();
}

function LocalizeText()
{
    SetString("expString", EXPString);
}

function TickHud(float DeltaTime)
{
	UpdatePerk();
	UpdateHealth();
	UpdateArmor();
	UpdateHealer();
	UpdateGlobalDamage();

    LastUpdateTime = MyPC.WorldInfo.TimeSeconds;
}

function ShowActiveIndicators( array<ActiveSkill> ActiveSkills )
{
    local byte i;
    local GFxObject DataProvider;
    local GFxObject TempObj;

    DataProvider = CreateArray();

    for (i = 0; i < ActiveSkills.length; i++)
    {
        //Corresponding AS3 class reads string off of the object to load in icon
        TempObj = CreateObject( "Object" );
        TempObj.SetString( "iconPath", "img://" $ActiveSkills[i].IconPath );
        TempObj.SetInt( "Multiplier", ActiveSkills[i].Multiplier );
        TempObj.SetFloat( "MaxDuration", ActiveSkills[i].MaxDuration );
        TempObj.SetFloat( "Duration", ActiveSkills[i].Duration );
        DataProvider.SetElementObject( i, TempObj );
    }

    SetObject("activeEffects", DataProvider);
}

function ClearBuffIcons()
{
    local GFxObject DataProvider;

    DataProvider = CreateArray();

    SetObject("activeEffects", DataProvider);
}

function UpdateHealer(optional bool bForce)
{
	local float CurrentHealerAmmoPct;

	if( MyPC.Pawn != none && MyPC.Pawn.IsAliveAndWell() )
	{
        if( MyInventoryManager == none )
        {
            MyInventoryManager = KFInventoryManager(MyPC.Pawn.InvManager);
        }
        if( MyInventoryManager != none && MyInventoryManager.HealerWeapon != none)
        {
            CurrentHealerAmmoPct = FClamp(float(MyInventoryManager.HealerWeapon.AmmoCount[0]) / float(MyInventoryManager.HealerWeapon.MagazineCapacity[0]),0.f,1.f);
        }
	}
	else if(MyInventoryManager != none)
	{
		MyInventoryManager = none;
	}
	
	// Update the Healer charge amount
	if( LastHealerAmmoPct != CurrentHealerAmmoPct || bForce)
	{
		
        SetInt("playerHealerCharge" , int(CurrentHealerAmmoPct * 100.f));
        LastHealerAmmoPct = CurrentHealerAmmoPct;
	}
}

function UpdatePerk()
{
    local byte CurrentPerkLevel;
    local int CurrentPerkEXP;
	local GFxObject PerkIconObject;
    
    if( MyPC == none || MyPC.CurrentPerk == none )
    {
        return;
    }

    CurrentPerkLevel = MYPC.GetLevel();
    CurrentPerkEXP = MyPC.GetPerkXP(MyPC.CurrentPerk.Class);

    // Update the perk class.
    if( ( LastPerkClass != MyPC.CurrentPerk.Class ) || ( LastPerkLevel != CurrentPerkLevel ) )
	{
		PerkIconObject = CreateObject("Object");
		PerkIconObject.SetString("perkIcon", "img://"$MyPC.CurrentPerk.GetPerkIconPath());
		PerkIconObject.SetString("prestigeIcon", MyPC.CurrentPerk.GetPrestigeIconPath(MYPC.GetPerkPrestigeLevelFromPerkList(MyPC.CurrentPerk.Class)));

		SetObject("playerPerkIcon", PerkIconObject);
		//SetString("playerPerkIcon" , "img://"$ MyPC.CurrentPerk.GetPerkIconPath());
        if(LastPerkLevel != CurrentPerkLevel)
        {    
            if(LastPerkClass != none && LastPerkClass == MyPC.CurrentPerk.Class)
            {
                 UpdateXP(CurrentPerkEXP, MyPC.GetPerkLevelProgressPercentage(MyPC.CurrentPerk.Class, CurrentPerkEXP), true, MyPC.CurrentPerk.Class);
            }
            else
            {
                SetBool("bXPInit", false);
            } 
        }
        LastPerkClass = MyPC.CurrentPerk.class;

        SetInt("playerPerkLevel" , CurrentPerkLevel);
        LastPerkLevel = CurrentPerkLevel;
        SetInt("playerPerkXPPercent", MyPC.GetPerkLevelProgressPercentage(LastPerkClass) );
        LastEXPValue = CurrentPerkEXP;
	}
}

function UpdateHealth()
{
    if( MyPC.Pawn != MyHumanPawn )
    {
        MyHumanPawn = KFPawn_Human( MyPC.Pawn );
    }
    if( MyHumanPawn == none )
    {
        LastHealth = 0;
        SetInt("playerHealth" , LastHealth);
	}
	else if( LastHealth != MyHumanPawn.Health )
	{
        if(MyHumanPawn.Health < 0)
        {
            SetInt("playerHealth" , 0);
        }
        else
        {
            SetInt("playerHealth" , MyHumanPawn.Health);
        }
        LastHealth = MyHumanPawn.Health;
	}
}

function UpdateArmor()
{
    if( MyPC.Pawn != MyHumanPawn )
    {
        MyHumanPawn = KFPawn_Human( MyPC.Pawn );
    }
    if( MyHumanPawn == none )
    {
        LastArmor = 0;
        SetInt("playerArmor" , LastArmor);
	}
	else if( LastArmor != MyHumanPawn.Armor )
	{
        SetInt("playerArmor" , MyHumanPawn.Armor);
        LastArmor = MyHumanPawn.Armor;
	}
}

function UpdateXP(int XPDelta, int XPPercent, bool bLevelUp, Class<KFPerk> PerkClass)
{
    local bool bIsCurrentPerk;

    SetBool("bLevelUp", bLevelUp);

    bIsCurrentPerk = PerkClass == MyPC.CurrentPerk.Class;
    if(bIsCurrentPerk)
    {
        SetInt("playerPerkXPPercent", MyPC.GetPerkLevelProgressPercentage(PerkClass));
    }
    if(!bLevelUp && MyPC.GetPerkLevelFromPerkList(PerkClass) < `MAX_PERK_LEVEL)
    {
        ShowXPBark( XPDelta, "img://"$PerkClass.Static.GetPerkIconPath(), bIsCurrentPerk );
    }
}

function ShowXPBark( int DeltaXP, string iconPath, bool bIsCurrentPerk )
{
    ActionScriptVoid("showXPBark");
}

function UpdateGlobalDamage()
{
    if(KFGRI == none)
    {
        KFGRI = KFGameReplicationInfo(GetPC().WorldInfo.GRI);
    }
    else
    {
        SetBool("waveApplyingDamage", KFGRI.IsGlobalDamage());
    }
}

DefaultProperties
{
    LastUpdateTime = 0.f;
}

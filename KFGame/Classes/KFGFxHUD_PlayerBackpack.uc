//=============================================================================
// KFGFxInGameHUD_PlayerBackpack
//=============================================================================
// HUD container that stores information about the player's Weapon & Equipment, dosh, etc.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Alex Quick 5/15/2014
//=============================================================================

class KFGFxHUD_PlayerBackpack extends GFxObject;

/** Cached KFPlayerController */
var KFPlayerController 				MyKFPC;
// Player's dosh amount as of the last tick
var int								LastDosh;
// Number of bullets in the  current magazine
var int 							LastSpareAmmo;
var int                             LastMagazineAmmo;
var bool                            bUsesAmmo;
// string used for alternate display in ammo section
var string							LastSpecialAmmo;
//
var int                             LastFlashlightBattery;
//
var int                             LastGrenades;
var int                             LastSavedBuild;

var int                             LastMaxWeight;
var int                             LastWeight;
// Amount of secondary ammo
var byte                            LastSecondaryAmmo;
var int                             LastSecondarySpareAmmo;
var bool                            bWasUsingAltFireMode;
var bool                            bUsesSecondaryAmmo;
var bool							bUsesGrenadesAsSecondaryAmmo;
var bool                            bUsesSecondaryAmmoAltHUD;

var transient bool                  bLastDoshVisibility;

var class<KFPerk> LastPerkClass;
var KFWeapon LastWeapon;

var KFInventoryManager MyKFInvManager;

var ASColorTransform DefaultColor;
var ASColorTransform RedColor;
var name OldState;

var transient byte LastGrenadeIndex;

function InitializeHUD()
{
	MyKFPC = KFPlayerController(GetPC());

    if( MyKFPC.Pawn != none && MyKFPC.Pawn.InvManager != none )
    {
        MyKFInvManager = KFInventoryManager(MyKFPC.Pawn.InvManager);
    }

    DefaultColor = GetObject("secondaryAmmoContainer").GetColorTransform();
    RedColor = GetObject("FlashlightContainer").GetColorTransform();
}

function TickHud(float DeltaTime)
{
    UpdateDosh();
    UpdateGrenades();
    UpdateWeapon();
    UpdateFlashlight();   
    UpdateWeight();
}

function UpdateWeight()
{
    if( MyKFPC.Pawn != none && MyKFPC.Pawn.InvManager != none )
    {
        MyKFInvManager = KFInventoryManager(MyKFPC.Pawn.InvManager);    

        if(MyKFInvManager != none && (LastMaxWeight != MyKFInvManager.MaxCarryBlocks || LastWeight != MyKFInvManager.CurrentCarryBlocks))
        {
            SetString("WeightText", MyKFInvManager.CurrentCarryBlocks$"/"$MyKFInvManager.MaxCarryBlocks);

            LastMaxWeight = MyKFInvManager.MaxCarryBlocks;
            LastWeight = MyKFInvManager.CurrentCarryBlocks;
        }
    }
}

function UpdateDosh()
{
    local int CurrentDosh;
    local int DeltaDosh;
    local bool bCanUseDosh;

    bCanUseDosh = MyKFPC.CanUseDosh();
    
    if (bCanUseDosh != bLastDoshVisibility)
    {
        UpdateDoshVisibility(bCanUseDosh);
        bLastDoshVisibility = bCanUseDosh;
    }

    if (!bCanUseDosh)
    {
        return;
    }

    if (MyKFPC.PlayerReplicationInfo != none)
    {
        CurrentDosh = MyKFPC.PlayerReplicationInfo.Score;

        // Update the dosh
        if (CurrentDosh != LastDosh )
        {
            DeltaDosh = CurrentDosh - LastDosh;
            SetInt("backpackDosh" ,DeltaDosh);
            LastDosh = CurrentDosh;
        }
    } 
}

function UpdateDoshVisibility(bool visible)
{
    if (visible)
    {
        SetBool("DoshSetVisibility", true);
    }
    else
    {
        SetBool("DoshSetVisibility", false);
    }
}

function UpdateGrenades()
{
    local int CurrentGrenades;

	if(MyKFPC == None)
	{
		return;
	}
    
    if(MyKFInvManager != none)
    {
        CurrentGrenades = MyKFInvManager.GrenadeCount;
    }
    
    //Update the icon the for grenade type.
    if(MyKFPC.CurrentPerk != none)
    {
        if( LastPerkClass != MyKFPC.CurrentPerk.Class || 
            LastSavedBuild != MyKFPC.CurrentPerk.GetSavedBuild() )
        {
            SetString("backpackGrenadeType", "img://" $ MyKFPC.CurrentPerk.GetGrenadeImagePath());
            LastPerkClass = MyKFPC.CurrentPerk.Class;
            LastSavedBuild = MyKFPC.CurrentPerk.GetSavedBuild();
            LastGrenadeIndex = MyKFPC.CurrentPerk.GetGrenadeSelectedIndex();
        } 
        else if (MyKFPC.CurrentPerk.GetGrenadeSelectedIndex() != LastGrenadeIndex)
        {
            SetString("backpackGrenadeType", "img://" $ MyKFPC.CurrentPerk.GetGrenadeImagePath());
            LastGrenadeIndex = MyKFPC.CurrentPerk.GetGrenadeSelectedIndex();
        }
    }
    // Update the grenades count value
    if(CurrentGrenades != LastGrenades)
	{
        SetInt("backpackGrenades" , CurrentGrenades);
        LastGrenades = CurrentGrenades;
	}
}

function UpdateWeapon()
{
	local int CurrentSpareAmmo;
	local int CurrentMagazineAmmo;
    local byte CurrentSecondaryAmmo;
    local int CurrentSecondarySpareAmmo;
	local string CurrentSpecialAmmo;
    local KFWeapon CurrentWeapon;
    local ASColorTransform ColorChange;
    local name StateName;
	local bool ForceSecondaryWeaponIconUpdate;

    if(MyKFPC != none && MyKFPC.Pawn != none && MyKFPC.Pawn.Weapon != none )
    {
        CurrentWeapon = KFWeapon(MyKFPC.Pawn.Weapon);
        if(CurrentWeapon != none)
        {
            // If we changed weapons
            if( LastWeapon == none || LastWeapon != CurrentWeapon )
            {
                LastWeapon = CurrentWeapon;
                RefreshWeapon(CurrentWeapon);
				ForceSecondaryWeaponIconUpdate = true;
            }
            else if( bWasUsingAltFireMode != CurrentWeapon.bUseAltFireMode )
            {
                UpdateFireModeIcon(CurrentWeapon);
            }

            if (bUsesAmmo)
            {
                // Update the ammo in the weapon's magazine
                CurrentMagazineAmmo = CurrentWeapon.AmmoCount[0];

                if ( CurrentMagazineAmmo != LastMagazineAmmo )
            	{
                    SetInt("weaponMagazineAmmo" , CurrentMagazineAmmo);
                    LastMagazineAmmo  = CurrentMagazineAmmo;
            	}

                // Update the spare ammo (whatever is not in the magazine)
                CurrentSpareAmmo = CurrentWeapon.GetSpareAmmoForHUD();
                if ( CurrentSpareAmmo != LastSpareAmmo )
            	{
                    SetInt("backpackStoredAmmo" , CurrentSpareAmmo);
                    LastSpareAmmo  = CurrentSpareAmmo;
            	}

                /**
                    Reusing this variable for showing the dosh icon for doshinegun.
                    Only FAMAS uses bUsesSecondaryAmmoAltHUD and for it bUsesSecondaryAmmo is true
                 */
                if (!bUsesSecondaryAmmo && CurrentWeapon.bUsesSecondaryAmmoAltHUD)
                {
                    SetBool("doshAmmoIcon", true);
                }
            }
			else
			{
				// if the weapon doesn't use ammo, let them display a special string in that section
				CurrentSpecialAmmo = CurrentWeapon.GetSpecialAmmoForHUD();
				if (CurrentSpecialAmmo != LastSpecialAmmo)
				{
					SetString("specialAmmoString", CurrentSpecialAmmo);
				}
			}

			// always reset the last special ammo since setting a new string turns the default "---" off
			LastSpecialAmmo = CurrentSpecialAmmo;
            StateName = CurrentWeapon.GetStateName();
            if (bUsesSecondaryAmmo)
            {
                CurrentSecondaryAmmo = CurrentWeapon.GetSecondaryAmmoForHUD();

				// Update the amount of ammo
                if (!bUsesSecondaryAmmoAltHUD)
                {
                    if (CurrentSecondaryAmmo != LastSecondaryAmmo)
                    {
                        SetInt("secondaryAmmo" , CurrentSecondaryAmmo);
                        LastSecondaryAmmo = CurrentSecondaryAmmo;
                    }
                }
				else
                {
                    if (CurrentSecondaryAmmo != LastSecondaryAmmo)
                    {
                        SetInt("secondaryAltAmmo" , CurrentSecondaryAmmo);
                        LastSecondaryAmmo = CurrentSecondaryAmmo;
                    }

                    CurrentSecondarySpareAmmo = CurrentWeapon.GetSecondarySpareAmmoForHUD();
                    if (CurrentSecondarySpareAmmo != LastSecondarySpareAmmo)
                    {
                        SetInt("secondaryAltSpareAmmo", CurrentSecondarySpareAmmo);
                        LastSecondarySpareAmmo = CurrentSecondarySpareAmmo;
                    }
                }

				// Force the color of the background if we detect a weapon change and the weapon doesn't use secondary ammo
				if( !bUsesGrenadesAsSecondaryAmmo && ForceSecondaryWeaponIconUpdate )
				{
					GetObject("secondaryAmmoContainer").SetColorTransform(DefaultColor);
				}

				// Update the aspect of the icon
                if ( bUsesGrenadesAsSecondaryAmmo && StateName != OldState)
                {
                    OldState = StateName;
                    if(CurrentWeapon.HasToReloadSecondaryAmmoForHUD())
                    {
                        ColorChange.Add = MakeLinearColor(0.65f,0.23f,0.00f,0.2f);
                        GetObject("secondaryAmmoContainer").SetColorTransform(ColorChange);
                        SetString("secondaryIcon", "img://"$CurrentWeapon.SecondaryAmmoTexture.GetPackageName()$".UI_FireModeSelect_BulletSingleProhibited");

                    }
                    else
                    {
                        SetString("secondaryIcon", "img://"$CurrentWeapon.SecondaryAmmoTexture.GetPackageName()$"."$CurrentWeapon.SecondaryAmmoTexture);
                        GetObject("secondaryAmmoContainer").SetColorTransform(DefaultColor);
                    }
                }
            }
        }
    }
}

function UpdateFireModeIcon( KFWeapon CurrentWeapon )
{
    local byte NewFireModeIndex;

    NewFireModeIndex = CurrentWeapon.bUseAltFireMode ? CurrentWeapon.ALTFIRE_FIREMODE : CurrentWeapon.DEFAULT_FIREMODE;
     // Update Fire Mode Icons
    if( Len(CurrentWeapon.FireModeIconPaths[NewFireModeIndex]) > 0)
    {
        SetString("firemodeIcon", "img://"$CurrentWeapon.FireModeIconPaths[NewFireModeIndex].GetPackageName()$"."$CurrentWeapon.FireModeIconPaths[NewFireModeIndex]);
    }
    bWasUsingAltFireMode = CurrentWeapon.bUseAltFireMode;
}

function RefreshWeapon(KFWeapon CurrentWeapon)
{
    bUsesAmmo = CurrentWeapon.UsesAmmo();
    SetBool("bUsesAmmo", bUsesAmmo);

    bUsesSecondaryAmmo = CurrentWeapon.UsesSecondaryAmmo();
    bUsesSecondaryAmmoAltHUD = bUsesSecondaryAmmo && CurrentWeapon.bUsesSecondaryAmmoAltHUD;
	bUsesGrenadesAsSecondaryAmmo = CurrentWeapon.UsesGrenadesAsSecondaryAmmo();

    if (bUsesSecondaryAmmoAltHUD)
    {
        SetBool("bUsesSecondaryAmmoAlt", bUsesSecondaryAmmoAltHUD);
    }
    else
    {
        SetBool("bUsesSecondaryAmmo", bUsesSecondaryAmmo);
    }

    if( bUsesSecondaryAmmo )
    {
        SetString("secondaryIcon", "img://"$CurrentWeapon.SecondaryAmmoTexture.GetPackageName()$"."$CurrentWeapon.SecondaryAmmoTexture);
    }
    UpdateFireModeIcon(CurrentWeapon);
}

function UpdateFlashlight()
{
	local KFPawn_Human MyKFP;
    local int CurrentFlashlightBattery;
    if(MyKFPC != none &&  MyKFPC.Pawn != none)
    {
        MyKFP = KFPawn_Human(MyKFPC.Pawn);
        if ( MyKFP != none )
        {
            CurrentFlashlightBattery = MyKFP.BatteryCharge;
            if ( CurrentFlashlightBattery != LastFlashlightBattery )
            {
                SetFlashlightBattery(CurrentFlashlightBattery, MyKFP.bFlashlightOn);
                LastFlashlightBattery = CurrentFlashlightBattery;
            }
        }
    }
}

function SetFlashlightBattery( int BatteryCharge, bool bIsOn )
{
    ActionscriptVoid( "setFlashlightBattery" );
}

DefaultProperties
{
    LastMaxWeight=-1   
    LastWeight=-1
    bLastDoshVisibility=true
    LastGrenadeIndex=0
    LastSecondaryAmmo=255
}

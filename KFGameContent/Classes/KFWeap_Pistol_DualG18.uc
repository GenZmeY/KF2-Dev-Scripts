//=============================================================================
// KFWeap_Pistol_DualG18
//=============================================================================
// An Glock 18 Pistol Dual
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// Fernando Ferrando @ Saber Interactive
//=============================================================================

/* 
	TODO LIST [LOOK FOR TAG (WHATS BEFORE THE : IN THE INDICATED FILE)] OK = DONE || XX = NOT DONE
		BASE DAMAGE 
		OK	DEFAULT MODE DAMAGE : KFWeap_Pistol_SingleG18.uc 
		OK	BASH MODE DAMAGE : KFWeap_Pistol_SingleG18.uc 

		DAMAGE TYPES
		OK	DEFAULT MODE TYPE DAMAGE : KFWeap_Pistol_SingleG18.uc 
		OK	BASH MODE TYPE DAMAGE : KFWeap_Pistol_SingleG18.uc 

		FIRE RATE
		OK	Single Default Firemode (Automatic) firerate :  KFWeap_Pistol_SingleG18.uc

		RANGE
		OK	Default Firemode (Automatic) range : KFWeapDef_Pistol_SingleG18.uc 

		PENETRATION
		OK	Default Firemode (Automatic) penetration : KFWeap_Pistol_SingleG18.uc

		DUAL-WIELDABLE
		OK	Dual-wieldable yes : KFWeap_Pistol_SingleG18.uc

		MAGAZINE SIZE
		OK	Magazine ammount : KFWeap_Pistol_SingleG18.uc

		SPARE AMMO CAPACITY
		OK	spare ammo Ammount : KFWeap_Pistol_SingleG18.uc

		STARTING SPARE MAGAZINES
		OK	starting spare magazines Ammount :  KFWeap_Pistol_SingleG18.uc

		AMMO BOX PICKUP SCALE
		XX	Ammount:
		
		RELOAD SPEED
	
		XX	[Single Standard]
				Full Reload
					Full Length Animation - ??? seconds
					Interrupt - ??? seconds

				Half Reload
					Full Length Animation - ??? seconds
					Interrupt - ??? seconds

		XX	[Single Elite]
				Full Reload
					Full Length Animation - ??? seconds
					Interrupt - ??? seconds

				Half Reload
					Full Length Animation - ??? seconds
					Interrupt - ??? seconds

		WEIGHT

		OK	Weight Ammount :  KFWeap_Pistol_SingleG18.uc

		WEAPON TRADER PRICE
		OK	Weapon Price : KFWeapDef_Pistol_SingleG18.uc

		AMMO TRADER PRICE
		OK	Ammo Price :  KFWeapDef_Pistol_SingleG18.uc

		WEAPON TIER
		XX	Tier : 

		FIRE MODE DEFAULT
		OK	FireMode Automatic : KFWeap_Pistol_SingleG18.uc

		AFFLICTIONS
		OK	afflictions Default Firemode (Automatic) : KFDT_Ballistic_SingleG18.uc
		OK	afflictions Bash Firemode : KFDT_Ballistic_SingleG18.uc

		PERKS
		OK	Main Perk : KFWeap_Pistol_SingleG18.uc

		WEAPON UPGRADE
		XX	Upgrades:


 */

class KFWeap_Pistol_DualG18 extends KFWeap_DualBase;

simulated state WeaponFiring
{
	simulated function BeginState(Name PrevStateName)
	{
		local KFPerk InstigatorPerk;

		InstigatorPerk = GetPerk();
		if( InstigatorPerk != none )
		{
			SetZedTimeResist( InstigatorPerk.GetZedTimeModifier(self) );
		}
		if (  bLoopingFireSnd.Length > 0 )
		{
			StartLoopingFireSound(CurrentFireMode);
		}

		super.BeginState(PrevStateName);
	}

	simulated function FireAmmunition()
    {
    	bFireFromRightWeapon = !bFireFromRightWeapon;
        Super.FireAmmunition();
	}

	simulated function EndState(Name NextStateName)
	{
		super.EndState(NextStateName);

		ClearZedTimeResist();

		// Simulate weapon firing effects on the local client
		if( WorldInfo.NetMode == NM_Client )
		{
			Instigator.WeaponStoppedFiring(self, false);
		}

		if ( bPlayingLoopingFireSnd )
		{
			StopLoopingFireSound(CurrentFireMode);
		}
	}
}

/**
 * This function returns the world location for spawning the visual effects
 *
 * Overridden to allow for left weapon location
 */
simulated event vector GetMuzzleLoc()
{
    local Rotator ViewRotation;
	if( bFireFromRightWeapon )
	{

		if( Instigator != none )
		{
				ViewRotation = Instigator.GetViewRotation();

				// Add in the free-aim rotation
				if ( KFPlayerController(Instigator.Controller) != None )
				{	
					ViewRotation += KFPlayerController(Instigator.Controller).WeaponBufferRotation;
				}

			if( bUsingSights )
			{
				return Instigator.GetWeaponStartTraceLocation() + (FireOffset >> ViewRotation);
			}
			else
			{
				return Instigator.GetPawnViewLocation() + (FireOffset >> ViewRotation);
			}

		}
		return Location;
	}
	else
	{
		return GetLeftMuzzleLoc();
	}
}

defaultproperties
{

	SingleClass=class'KFWeap_Pistol_G18C'

    // FOV
	MeshFOV=96
	MeshIronSightFOV=77
    PlayerIronSightFOV=77

	//RecoilBlendOutRatio=0
	FireTweenTime=0.03
	// Depth of field 
	DOF_FG_FocalRadius=40
	DOF_FG_MaxNearBlurSize=3.5

	// Zooming/Position 
	IronSightPosition=(X=-3,Y=0,Z=0)
	PlayerViewOffset=(X=-15,Y=0,Z=0)
	
	// Controls the rotation when Hans(the bastard) grabs you
	QuickWeaponDownRotation=(Pitch=-14192,Yaw=-6000,Roll=16384)

	FireOffset=(X=17,Y=4.0,Z=-3)
	LeftFireOffset=(X=17,Y=-4,Z=-3)

	// Content 
	PackageKey="Dual_G18C"
	FirstPersonMeshName="WEP_1P_Dual_G18C_MESH.Wep_1stP_Dual_G18C_Rig"
	FirstPersonAnimSetNames(0)="WEP_1P_Dual_G18C_ANIM.WEP_1st_Dual_G18C_ANIM"
	PickupMeshName="wep_3p_dual_g18c_mesh.Wep_3rdP_Dual_G18C_Pickup"
	AttachmentArchetypeName="WEP_Dual_G18C_ARCH.Wep_Dual_g18c_3P"
	MuzzleFlashTemplateName="WEP_Dual_G18C_ARCH.Wep_Dual_G18C_MuzzleFlash"
    
	// Ammo
	MagazineCapacity[0]=66 //Magazine ammount
	SpareAmmoCapacity[0]=462 //spare ammo Ammount
	InitialSpareMags[0]=2//3 //starting spare magazines Ammount
	bCanBeReloaded=true
	bReloadFromMagazine=true

	bHasFireLastAnims=true

	// Recoil
	maxRecoilPitch=260 //220 //165 //150 //100
	minRecoilPitch=200 //165 //125 //112 //75
	maxRecoilYaw=85
	minRecoilYaw=-85
	RecoilRate=0.045
	RecoilMaxYawLimit=500
	RecoilMinYawLimit=65035
	RecoilMaxPitchLimit=900
	RecoilMinPitchLimit=65035
	RecoilISMaxYawLimit=100
	RecoilISMinYawLimit=65435
	RecoilISMaxPitchLimit=375
	RecoilISMinPitchLimit=65460
	IronSightMeshFOVCompensationScale=1.65
	WalkingRecoilModifier=1.1
	JoggingRecoilModifier=1.2

	// DEFAULT_FIREMODE
	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletAuto'
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponFiring //DEFAULT MODE DAMAGE
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_InstantHit
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Bullet_G18c'
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Ballistic_G18c' //DEFAULT MODE TYPE DAMAGE
	FireInterval(DEFAULT_FIREMODE)=+0.05 ‬ // 1200 RPM //Default Firemode (Automatic) firerate
	Spread(DEFAULT_FIREMODE)=0.06
	InstantHitDamage(DEFAULT_FIREMODE)=37 //39 //41 // DEFAULT MODE DAMAGE
	PenetrationPower(DEFAULT_FIREMODE)=0.0 //Default Firemode (Automatic) & Altfire Firemode (Single Fire) penetration
	PenetrationDamageReductionCurve(DEFAULT_FIREMODE)=(Points=((InVal=0.f,OutVal=0.f),(InVal=1.f, OutVal=1.f))) //Default Firemode (Automatic) & Altfire Firemode (Single Fire) penetration

	//ALT_FIREMODE
	FireModeIconPaths(ALTFIRE_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletAuto'
	FiringStatesArray(ALTFIRE_FIREMODE)=WeaponFiring //DEFAULT MODE DAMAGE
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_InstantHit
	WeaponProjectiles(ALTFIRE_FIREMODE)=class'KFProj_Bullet_G18c'
	InstantHitDamageTypes(ALTFIRE_FIREMODE)=class'KFDT_Ballistic_G18c' //DEFAULT MODE TYPE DAMAGE
	FireInterval(ALTFIRE_FIREMODE)=+0.05 ‬ // 1200 RPM //Default Firemode (Automatic) firerate
	Spread(ALTFIRE_FIREMODE)=0.06
	InstantHitDamage(ALTFIRE_FIREMODE)=37 //39 //41 // DEFAULT MODE DAMAGE
	PenetrationPower(ALTFIRE_FIREMODE)=0.0 //Default Firemode (Automatic) & Altfire Firemode (Single Fire) penetration
	PenetrationDamageReductionCurve(ALTFIRE_FIREMODE)=(Points=((InVal=0.f,OutVal=0.f),(InVal=1.f, OutVal=1.f))) //Default Firemode (Automatic) & Altfire Firemode (Single Fire) penetration

	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_G18C' //BASH MODE TYPE DAMAGE
	InstantHitDamage(BASH_FIREMODE)=25 //BASH MODE DAMAGE
	PenetrationPower(BASH_FIREMODE)=0.0 //Default Firemode (Automatic) & Altfire Firemode (Single Fire) penetration
	PenetrationDamageReductionCurve(BASH_FIREMODE)=(Points=((InVal=0.f,OutVal=0.f),(InVal=1.f, OutVal=1.f))) //Default Firemode (Automatic) & Altfire Firemode (Single Fire) penetration

	//Sounds
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_G18c.Play_WEP_G18c_Auto_3P_Loop', FirstPersonCue=AkEvent'WW_WEP_G18c.Play_WEP_G18c_Auto_Loop')
	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_SA_MedicSMG.Play_SA_MedicSMG_Handling_DryFire'

	// Advanced (High RPM) Fire Effects
	bLoopingFireAnim(DEFAULT_FIREMODE)=false
	bLoopingFireSnd(DEFAULT_FIREMODE)=true
	WeaponFireLoopEndSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_G18c.Play_WEP_G18c_Fire_3P_EndLoop', FirstPersonCue=AkEvent'WW_WEP_G18c.Play_WEP_G18c_Fire_1P_EndLoop')

	//Sounds
	WeaponFireSnd(ALTFIRE_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_G18c.Play_WEP_G18c_Auto_3P_Loop', FirstPersonCue=AkEvent'WW_WEP_G18c.Play_WEP_G18c_Auto_Loop')
	WeaponDryFireSnd(ALTFIRE_FIREMODE)=AkEvent'WW_WEP_SA_MedicSMG.Play_SA_MedicSMG_Handling_DryFire'

	// Advanced (High RPM) Fire Effects
	bLoopingFireAnim(ALTFIRE_FIREMODE)=false
	bLoopingFireSnd(ALTFIRE_FIREMODE)=true
	WeaponFireLoopEndSnd(ALTFIRE_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_G18c.Play_WEP_G18c_Fire_3P_EndLoop', FirstPersonCue=AkEvent'WW_WEP_G18c.Play_WEP_G18c_Fire_1P_EndLoop')

	WeaponFireSnd(2)=(DefaultCue=AkEvent'WW_WEP_G18c.Play_WEP_G18c_Fire_3P_Single', FirstPersonCue=AkEvent'WW_WEP_G18c.Play_WEP_G18c_Fire_1P_Single')
	SingleFireSoundIndex=2

	// Attachments 
	bHasIronSights=true
	bHasFlashlight=true



	AssociatedPerkClasses(0)=class'KFPerk_Gunslinger' //Main Perk

	// Inventory 
	InventorySize=8 //Weight Ammount
	GroupPriority=100
	bCanThrow=true
	bDropOnDeath=true
	WeaponSelectTexture=Texture2D'WEP_UI_Dual_G18C_TEX.UI_WeaponSelect_Dual_G18C'
	bIsBackupWeapon=false

	// Custom animations
	IdleFidgetAnims=(Guncheck_v1, Guncheck_v2, Guncheck_v3)

	//FireSightedAnims=(Shoot_Iron, Shoot_Iron2, Shoot_Iron3)

	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.125f), (Stat=EWUS_Damage1, Scale=1.125f), (Stat=EWUS_Weight, Add=2)))
	//WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.25f), (Stat=EWUS_Weight, Add=2)))
	//WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.2f)))
	//WeaponUpgrades[2]=(Stats=((Stat=EWUS_Damage0, Scale=1.4f)))
	//WeaponUpgrades[3]=(Stats=((Stat=EWUS_Damage0, Scale=1.6f)))
	//WeaponUpgrades[4]=(Stats=((Stat=EWUS_Damage0, Scale=1.8f)))
	//WeaponUpgrades[5]=(Stats=((Stat=EWUS_Damage0, Scale=2.0f)))

}


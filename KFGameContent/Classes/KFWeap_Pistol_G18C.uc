//=============================================================================
// KFWeap_Pistol_G18C
//=============================================================================
// An Glock 18 Pistol
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// Fernando Ferrando @ Saber Interactive
//=============================================================================

/* 
	TODO LIST [LOOK FOR TAG (WHATS BEFORE THE : IN THE INDICATED FILE)] OK = DONE || XX = NOT DONE
		BASE DAMAGE 
		OK	DEFAULT & ALT MODE DAMAGE DAMAGE : KFWeap_Pistol_G18C.uc 
		OK	BASH MODE DAMAGE : KFWeap_Pistol_G18C.uc 

		DAMAGE TYPES
		OK	DEFAULT & ALT MODE TYPE DAMAGE : KFWeap_Pistol_G18C.uc 
		OK	BASH MODE TYPE DAMAGE : KFWeap_Pistol_G18C.uc 

		FIRE RATE
		OK	Single Default Firemode (Automatic) firerate :  KFWeap_Pistol_G18C.uc
		OK	Single Altfire Firemode (Single Fire) firerate :  KFWeap_Pistol_G18C.uc

		RANGE
		OK	Default Firemode (Automatic) & Altfire Firemode (Single Fire) range : KFWeapDef_Pistol_G18C.uc 

		PENETRATION
		OK	Default Firemode (Automatic) & Altfire Firemode (Single Fire) penetration : KFWeap_Pistol_G18C.uc

		DUAL-WIELDABLE
		OK	Dual-wieldable yes : KFWeap_Pistol_G18C.uc

		MAGAZINE SIZE
		OK	Magazine ammount : KFWeap_Pistol_G18C.uc

		SPARE AMMO CAPACITY
		OK	spare ammo Ammount : KFWeap_Pistol_G18C.uc

		STARTING SPARE MAGAZINES
		OK	starting spare magazines Ammount :  KFWeap_Pistol_G18C.uc

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

		OK	Weight Ammount :  KFWeap_Pistol_G18C.uc

		WEAPON TRADER PRICE
		OK	Weapon Price : KFWeapDef_Pistol_G18C.uc

		AMMO TRADER PRICE
		OK	Ammo Price :  KFWeapDef_Pistol_G18C.uc

		WEAPON TIER
		XX	Tier : 

		FIRE MODE DEFAULT
		OK	FireMode Automatic : KFWeap_Pistol_G18C.uc

		FIRE MODE ALT
		OK	FireMode Single : KFWeap_Pistol_G18C.uc


		AFFLICTIONS
		OK	afflictions Default Firemode (Automatic)  & Altfire Firemode (Single Fire) : KFDT_Ballistic_G18C.uc
		OK	afflictions Bash Firemode : KFDT_Ballistic_G18C.uc

		PERKS
		OK	Main Perk : KFWeap_Pistol_G18C.uc

		WEAPON UPGRADE
		XX	Upgrades:

		ADD TO CHEATMANAGER (https://www.notion.so/C-mo-a-adir-un-Weapon-be997fefdede49858315a4e48e15a8ab)
		XX	Added to cheat :
		
		ADD TO SKINS
		XX Added to Skins :

		ADD TO DAILY EVENTS
		XX Added to daily events : 

 */

class KFWeap_Pistol_G18C extends KFWeap_PistolBase;

defaultproperties
{
	InventoryGroup=IG_Secondary

    // FOV [FFERRANDO NEEDS TO BE UPDATED TO G18]
	MeshFOV=96
	MeshIronSightFOV=55 //77
    PlayerIronSightFOV=77

	// Depth of field [FFERRANDO NEEDS TO BE UPDATED TO G18]
	DOF_FG_FocalRadius=40
	DOF_FG_MaxNearBlurSize=3.5

	// Zooming/Position [FFERRANDO NEEDS TO BE UPDATED TO G18]
	PlayerViewOffset=(X=-15,Y=12,Z=-6)
	IronSightPosition=(X=0,Y=-0.12,Z=-0.1) //(X=-3,Y=-0.38,Z=-0.2)
	
	// Content [FFERRANDO NEEDS TO BE UPDATED TO G18]
	PackageKey="G18C"
	FirstPersonMeshName="WEP_1P_G18C_MESH.Wep_1stP_G18C_Rig"
	FirstPersonAnimSetNames(0)="WEP_1P_G18C_ANIM.WEP_1st_G18C_Anim"
	PickupMeshName="WEP_3P_G18C_MESH.Wep_G18C_Pickup"
	AttachmentArchetypeName="WEP_G18C_ARCH.Wep_G18C_3P"
	MuzzleFlashTemplateName="WEP_G18C_ARCH.Wep_G18C_MuzzleFlash"

	// Ammo
	MagazineCapacity[0]=33 //Magazine ammount
	SpareAmmoCapacity[0]=462 //spare ammo Ammount
	InitialSpareMags[0]=4 //starting spare magazines Ammount
	bCanBeReloaded=true
	bReloadFromMagazine=true

	bHasFireLastAnims=true
	BonesToLockOnEmpty=(RW_Bolt)

	// Recoil
	maxRecoilPitch=300 //220 //165 //150 //100
	minRecoilPitch=225 //165 //125 //112 //75
	maxRecoilYaw=85
	minRecoilYaw=-85
	RecoilRate=0.045
	RecoilMaxYawLimit=500
	RecoilMinYawLimit=65035
	RecoilMaxPitchLimit=900
	RecoilMinPitchLimit=65035
	RecoilISMaxYawLimit=100
	RecoilISMinYawLimit=65435
	RecoilISMaxPitchLimit=37
	RecoilISMinPitchLimit=65460
	IronSightMeshFOVCompensationScale=1.65
	WalkingRecoilModifier=1.1
	JoggingRecoilModifier=1.2

	// DEFAULT_FIREMODE
	FireOffset=(X=85,Y=12,Z=-7)
	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletAuto'
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponFiring //FireMode Automatic
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_InstantHit
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Bullet_G18C'
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Ballistic_G18C' //DEFAULT & ALT MODE TYPE DAMAGE
	FireInterval(DEFAULT_FIREMODE)=+0.075 // 800 RPM //Single Default Firemode (Automatic) firerate
	Spread(DEFAULT_FIREMODE)=0.06
	InstantHitDamage(DEFAULT_FIREMODE)=37 //39 //41 // DEFAULT & ALT MODE DAMAGE DAMAGE
	PenetrationPower(DEFAULT_FIREMODE)=0.0 //Default Firemode (Automatic) & Altfire Firemode (Single Fire) penetration
	PenetrationDamageReductionCurve(DEFAULT_FIREMODE)=(Points=((InVal=0.f,OutVal=0.f),(InVal=1.f, OutVal=1.f))) //Default Firemode (Automatic) & Altfire Firemode (Single Fire) penetration

	// ALT_FIREMODE
	FireModeIconPaths(ALTFIRE_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletSingle'
	FiringStatesArray(ALTFIRE_FIREMODE)=WeaponSingleFiring //FireMode single
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_InstantHit
	WeaponProjectiles(ALTFIRE_FIREMODE)=class'KFProj_Bullet_G18c'
	InstantHitDamageTypes(ALTFIRE_FIREMODE)=class'KFDT_Ballistic_G18c' //DEFAULT & ALT MODE TYPE DAMAGE
	FireInterval(ALTFIRE_FIREMODE)=+0.175 // 343 RPM //Single Altfire Firemode (Single Fire) firerate
	InstantHitDamage(ALTFIRE_FIREMODE)=37 //39 //41 //DEFAULT & ALT MODE DAMAGE DAMAGE
	Spread(ALTFIRE_FIREMODE)=0.015
	PenetrationPower(ALTFIRE_FIREMODE)=0.0 //Default Firemode (Automatic) & Altfire Firemode (Single Fire) penetration
	PenetrationDamageReductionCurve(ALTFIRE_FIREMODE)=(Points=((InVal=0.f,OutVal=0.f),(InVal=1.f, OutVal=1.f))) //Default Firemode (Automatic) & Altfire Firemode (Single Fire) penetration
    
	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_G18C' //BASH MODE TYPE DAMAGE
	InstantHitDamage(BASH_FIREMODE)=25 //BASH MODE DAMAGE
	PenetrationPower(BASH_FIREMODE)=0.0 //Default Firemode (Automatic) & Altfire Firemode (Single Fire) penetration
	PenetrationDamageReductionCurve(BASH_FIREMODE)=(Points=((InVal=0.f,OutVal=0.f),(InVal=1.f, OutVal=1.f))) //Default Firemode (Automatic) & Altfire Firemode (Single Fire) penetration

	//Sounds
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_G18c.Play_WEP_G18c_Auto_3P_Loop', FirstPersonCue=AkEvent'WW_WEP_G18c.Play_WEP_G18c_Auto_Loop')
	WeaponFireSnd(ALTFIRE_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_G18c.Play_WEP_G18c_Fire_3P_Single', FirstPersonCue=AkEvent'WW_WEP_G18c.Play_WEP_G18c_Fire_1P_Single')
	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_SA_MedicSMG.Play_SA_MedicSMG_Handling_DryFire'
	WeaponDryFireSnd(ALTFIRE_FIREMODE)=AkEvent'WW_WEP_SA_MedicDart.Play_WEP_SA_Medic_Dart_DryFire'

	// Advanced (High RPM) Fire Effects
	bLoopingFireAnim(DEFAULT_FIREMODE)=true
	bLoopingFireSnd(DEFAULT_FIREMODE)=true
	WeaponFireLoopEndSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_G18c.Play_WEP_G18c_Fire_3P_EndLoop', FirstPersonCue=AkEvent'WW_WEP_G18c.Play_WEP_G18c_Fire_1P_EndLoop')
	SingleFireSoundIndex=ALTFIRE_FIREMODE

	// Attachments [FFERRANDO NEEDS TO BE RECHECKED FOR G18]
	bHasIronSights=true
	bHasFlashlight=true

	AssociatedPerkClasses(0)=class'KFPerk_Gunslinger' //Main Perk

	// Inventory [FFERRANDO NEEDS TO BE RECHECKED FOR G18]
	InventorySize=4 //Weight Ammount
	GroupPriority=100
	bCanThrow=true
	bDropOnDeath=true
	WeaponSelectTexture=Texture2D'wep_ui_g18c_tex.UI_WeaponSelect_g18c'
	bIsBackupWeapon=false

    //DUAL CLASS DECLARATION [FFERRANDO NEEDS TO BE UPDATED TO G18]
	DualClass=class'KFWeap_Pistol_DualG18' //Dual-wieldable yes



	// Custom animations
	IdleFidgetAnims=(Guncheck_v1, Guncheck_v2, Guncheck_v3)

	//FireSightedAnims=(Shoot_Iron, Shoot_Iron2, Shoot_Iron3)

	///???????
	//bHasFireLastAnims=true
	
	///???????
	//BonesToLockOnEmpty=(RW_Bolt, RW_Bullets1)

	
	//[FFERRANDO NEEDS TO BE UPDATED TO G18]
	// Weapon Upgrade stat boosts. Setting weight to 0 because single 9MM cannot be sold.
	//WeaponUpgrades[1]=(IncrementDamage=1.2f,IncrementWeight=0)
	//WeaponUpgrades[2]=(IncrementDamage=1.4f,IncrementWeight=0) //1
	//WeaponUpgrades[3]=(IncrementDamage=1.6f,IncrementWeight=0) //1
	//WeaponUpgrades[4]=(IncrementDamage=1.8f,IncrementWeight=0) //2
	//WeaponUpgrades[5]=(IncrementDamage=2.0f,IncrementWeight=0) //3
	
	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.125f), (Stat=EWUS_Damage1, Scale=1.125f), (Stat=EWUS_Weight, Add=1)))
	//WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.25f), (Stat=EWUS_Weight, Add=1)))
	//WeaponUpgrades[2]=(Stats=((Stat=EWUS_Damage0, Scale=1.4f)))
	//WeaponUpgrades[3]=(Stats=((Stat=EWUS_Damage0, Scale=1.6f)))
	//WeaponUpgrades[4]=(Stats=((Stat=EWUS_Damage0, Scale=1.8f)))
	//WeaponUpgrades[5]=(Stats=((Stat=EWUS_Damage0, Scale=2.0f)))

}


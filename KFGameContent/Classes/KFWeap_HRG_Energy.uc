//=============================================================================
// KFWeap_HRG_Energy
//=============================================================================
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
//=============================================================================

class KFWeap_HRG_Energy extends KFWeap_PistolBase;

`define HRG_ENERGY_MIC_LED_INDEX_1 0
`define HRG_ENERGY_MIC_SCREEN_INDEX 1
`define HRG_ENERGY_MIC_LED_INDEX_2 2

/*********************************************************************************************
 @name Optics UI
********************************************************************************************* */
var class<KFGFxWorld_MedicOptics> OpticsUIClass;
var KFGFxWorld_MedicOptics OpticsUI;

/** The last updated value for our ammo - Used to know when to update our optics ammo */
var byte StoredPrimaryAmmo;
var byte StoredSecondaryAmmo;

var transient float AltFireMaxShots;

/** Modifier applied to the alt fire animation */
var float SecondaryFireAnimRateModifier;

/** Material colors applied to different fire modes */
var LinearColor DefaultFireMaterialColor;
var LinearColor AltFireMaterialColor;

/** How much recoil the altfire should do */
var protected const float AltFireRecoilScale;

simulated event PreBeginPlay()
{
	super.PreBeginPlay();
	AltFireMaxShots = MagazineCapacity[DEFAULT_FIREMODE] / AmmoCost[ALTFIRE_FIREMODE];
}

simulated function Activate()
{
	super.Activate();
	UpdateMaterial(bUseAltFireMode ? ALTFIRE_FIREMODE : DEFAULT_FIREMODE);
}

simulated function UpdateMaterial(byte FireMode)
{
	local LinearColor MatColor;
	MatColor = FireMode == DEFAULT_FIREMODE ? DefaultFireMaterialColor : AltFireMaterialColor;

	if( WeaponMICs.Length > `HRG_ENERGY_MIC_LED_INDEX_1 )
	{
		WeaponMICs[`HRG_ENERGY_MIC_LED_INDEX_1].SetVectorParameterValue('Vector_GlowColor', MatColor);
	}

	if (WeaponMICs.Length > `HRG_ENERGY_MIC_SCREEN_INDEX)
	{
		WeaponMICs[`HRG_ENERGY_MIC_SCREEN_INDEX].SetVectorParameterValue('Color_override', MatColor);
	}

	if( WeaponMICs.Length > `HRG_ENERGY_MIC_LED_INDEX_2 )
	{
		WeaponMICs[`HRG_ENERGY_MIC_LED_INDEX_2].SetVectorParameterValue('Vector_GlowColor', MatColor);
	}
}

/**
  * Check target locking - server-side only
  * HealAmmo Regen client and server
  */
simulated event Tick( FLOAT DeltaTime )
{
	if (Instigator != none && Instigator.weapon == self)
	{
		UpdateOpticsUI();
	}

	Super.Tick(DeltaTime);
}

/*********************************************************************************************
 @name Optics UI
********************************************************************************************* */

/** Get our optics movie from the inventory once our InvManager is created */
reliable client function ClientWeaponSet(bool bOptionalSet, optional bool bDoNotActivate)
{
	local KFInventoryManager KFIM;

	super.ClientWeaponSet(bOptionalSet, bDoNotActivate);

	if (OpticsUI == none)
	{
		KFIM = KFInventoryManager(InvManager);
		if (KFIM != none)
		{
			//Create the screen's UI piece
			OpticsUI = KFGFxWorld_MedicOptics(KFIM.GetOpticsUIMovie(OpticsUIClass));
		}
	}
}

function ItemRemovedFromInvManager()
{
	local KFInventoryManager KFIM;
	local KFWeap_MedicBase KFW;

	Super.ItemRemovedFromInvManager();

	if (OpticsUI != none)
	{
		KFIM = KFInventoryManager(InvManager);
		if (KFIM != none)
		{
			// @todo future implementation will have optics in base weapon class
			foreach KFIM.InventoryActors(class'KFWeap_MedicBase', KFW)
			{
				// This is not a MedicBase, no need to check against itself
				if(KFW.OpticsUI.Class == OpticsUI.class)
				{
					// A different weapon is still using this optics class
					return;
				}
			}

			//Create the screen's UI piece
			KFIM.RemoveOpticsUIMovie(OpticsUI.class);

			OpticsUI.Close();
			OpticsUI = none;
		}
	}
}

/** Unpause our optics movie and reinitialize our ammo when we equip the weapon */
simulated function AttachWeaponTo(SkeletalMeshComponent MeshCpnt, optional Name SocketName)
{
	super.AttachWeaponTo(MeshCpnt, SocketName);

	if (OpticsUI != none)
	{
		OpticsUI.SetPause(false);
		OpticsUI.ClearLockOn();
		UpdateOpticsUI(true);
		OpticsUI.SetShotPercentCost( AmmoCost[ALTFIRE_FIREMODE]);
	}
}

/** Pause the optics movie once we unequip the weapon so it's not playing in the background */
simulated function DetachWeapon()
{
	local Pawn OwnerPawn;
	super.DetachWeapon();

	OwnerPawn = Pawn(Owner);
	if( OwnerPawn != none && OwnerPawn.Weapon == self )
	{
		if (OpticsUI != none)
		{
			OpticsUI.SetPause();
		}
	}
}

/**
 * Update our displayed ammo count if it's changed
 */
simulated function UpdateOpticsUI(optional bool bForceUpdate)
{
	if (OpticsUI != none && OpticsUI.OpticsContainer != none)
	{
		if (AmmoCount[DEFAULT_FIREMODE] != StoredPrimaryAmmo || bForceUpdate)
		{
			StoredPrimaryAmmo = AmmoCount[DEFAULT_FIREMODE];
			OpticsUI.SetPrimaryAmmo(StoredPrimaryAmmo);

			if(AmmoCount[DEFAULT_FIREMODE] < AmmoCost[ALTFIRE_FIREMODE])
			{
				OpticsUI.SetHealerCharge(0);
			}
			else
			{
				OpticsUI.SetHealerCharge((AmmoCount[DEFAULT_FIREMODE] / AmmoCost[ALTFIRE_FIREMODE]) / AltFireMaxShots * 100);
			}
		}

		if(OpticsUI.MinPercentPerShot != AmmoCost[ALTFIRE_FIREMODE])
		{
			OpticsUI.SetShotPercentCost( AmmoCost[ALTFIRE_FIREMODE] );
		}
	}
}

/** Healing charge doesn't count as ammo for purposes of inventory management (e.g. switching) */
simulated function bool HasAnyAmmo()
{
	return HasSpareAmmo() || HasAmmo(DEFAULT_FIREMODE) || HasSpareAmmo(ALTFIRE_FIREMODE) || HasAmmo(ALTFIRE_FIREMODE);
}

simulated function StartFire(byte FireModeNum)
{
	if (FireModeNum == DEFAULT_FIREMODE && bUseAltFireMode)
	{
		if (AmmoCount[FireModeNum] < AmmoCost[ALTFIRE_FIREMODE] && SpareAmmoCount[FireModeNum] > 0)
		{
			BeginFire(RELOAD_FIREMODE);
			return;
		}
	}

	super.StartFire(FireModeNum);
}

simulated function AltFireMode()
{
	if ( !Instigator.IsLocallyControlled()  )
	{
		return;
	}

	if ( !bUseAltFireMode && SpareAmmoCount[0] + AmmoCount[0] < AmmoCost[1] )
	{
		return;
	}

	super.AltFireMode();
	UpdateMaterial(bUseAltFireMode ? ALTFIRE_FIREMODE : DEFAULT_FIREMODE);

	NotifyAltFireUsage();
}

/** Overriden to use WeaponAnimSeqNode */
simulated function PlayWeaponAnimation(name Sequence, float fDesiredDuration, optional bool bLoop, optional SkeletalMeshComponent SkelMesh)
{
	local float DesiredRate;

	if ( Mesh != none && Instigator != none && WorldInfo.NetMode != NM_DedicatedServer )
	{
		if ( WeaponAnimSeqNode != None )
		{
			if (WeaponAnimSeqNode.AnimSeq == None || WeaponAnimSeqNode.AnimSeq.SequenceName != Sequence)
			{
				WeaponAnimSeqNode.SetAnim(Sequence);
			}

			if(fDesiredDuration > 0.0 && WeaponAnimSeqNode.AnimSeq.RateScale > 0.0)
			{
				DesiredRate = WeaponAnimSeqNode.AnimSeq.SequenceLength / (fDesiredDuration * WeaponAnimSeqNode.AnimSeq.RateScale);
				WeaponAnimSeqNode.PlayAnim(bLoop, DesiredRate);
			}
			else
			{
				WeaponAnimSeqNode.PlayAnim(bLoop, DefaultAnimSpeed);
			}
		}
	}
}

/**
 * PlayFireEffects Is the root function that handles all of the effects associated with
 * a weapon.  This function creates the 1st person effects.  It should only be called
 * on a locally controlled player.
 */
simulated function PlayFireEffects( byte FireModeNum, optional vector HitLocation )
{
	local name WeaponFireAnimName;
	local KFPerk CurrentPerk;
	local float TempTweenTime, AdjustedAnimLength;
	
	// If we have stopped the looping fire sound to play single fire sounds for zed time
	// start the looping sound back up again when the time is back above zed time speed
	if( FireModeNum < bLoopingFireSnd.Length && bLoopingFireSnd[FireModeNum] && !bPlayingLoopingFireSnd )
    {
        StartLoopingFireSound(FireModeNum);
    }

	PlayFiringSound(CurrentFireMode);

	if( Instigator != none )
	{
		// Tell our pawn about any changes in animation speed
		UpdateWeaponAttachmentAnimRate( GetThirdPersonAnimRate() );

		if( Instigator.IsLocallyControlled() )
		{
			if( Instigator.IsFirstPerson() )
			{
				if ( !bPlayingLoopingFireAnim )
				{
					WeaponFireAnimName = GetWeaponFireAnim(FireModeNum);

					if ( WeaponFireAnimName != '' )
					{
						AdjustedAnimLength = MySkelMesh.GetAnimLength(WeaponFireAnimName);
						TempTweenTime = FireTweenTime;

						if (FireModeNum == ALTFIRE_FIREMODE)
						{
							AdjustedAnimLength *= SecondaryFireAnimRateModifier;
						}

						CurrentPerk = GetPerk();
						if( CurrentPerk != none )
						{
							CurrentPerk.ModifyRateOfFire( AdjustedAnimLength, self );

							// We need to unlock the slide if we fire from zero ammo while uber ammo is active
							if( EmptyMagBlendNode != none
								&& BonesToLockOnEmpty.Length > 0
								&& AmmoCount[GetAmmoType(FireModeNum)] == 0
								&& CurrentPerk.GetIsUberAmmoActive(self) )
							{
								EmptyMagBlendNode.SetBlendTarget( 0, 0 );
								TempTweenTime = 0.f;
							}
						}

						PlayAnimation(WeaponFireAnimName, AdjustedAnimLength,, TempTweenTime);
					}
				}

				// Start muzzle flash effect
				CauseMuzzleFlash(FireModeNum);
			}

			HandleRecoil();
			ShakeView();

			if (AmmoCount[0] == 0 && ForceReloadTimeOnEmpty > 0)
			{
				SetTimer(ForceReloadTimeOnEmpty, false, nameof(ForceReload));
			}
		}
	}
}

simulated function ModifyRecoil( out float CurrentRecoilModifier )
{
	if( CurrentFireMode == ALTFIRE_FIREMODE )
	{
		CurrentRecoilModifier *= AltFireRecoilScale;
	}

	super.ModifyRecoil( CurrentRecoilModifier );
}

simulated function NotifyAltFireUsage()
{
	local KFPawn_Human KFPH;

	// Notify 3P to change material.
	KFPH = KFPawn_Human(Instigator);
	if (KFPH != none)
	{
		KFPH.SetUsingAltFireMode(bUseAltFireMode, true);
		KFPH.bNetDirty = true;
	}
}

simulated state WeaponEquipping
{
	simulated function BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);
	//	 NotifyAltFireUsage();
		if (WorldInfo.NetMode == NM_Client || WorldInfo.NetMode == NM_Standalone)
		{
			SetTimer(1.0f, false, nameof(NotifyAltFireUsage));
		}
	}
}

/** Returns animation to play based on reload type and status */
simulated function name GetReloadAnimName( bool bTacticalReload )
{
	return bTacticalReload ? ReloadNonEmptyMagEliteAnim : ReloadNonEmptyMagAnim;
}

simulated function ConsumeAmmo( byte FireModeNum )
{
	super.ConsumeAmmo(FireModeNum);

	if( bUseAltFireMode && SpareAmmoCount[0] + AmmoCount[0] < AmmoCost[1] )
	{
		bUseAltFireMode = false;
		UpdateMaterial(DEFAULT_FIREMODE);
		NotifyAltFireUsage();
	}
}

defaultproperties
{
	// Inventory
	InventoryGroup=IG_Secondary
	InventorySize=4
	GroupPriority=125
	bCanThrow=true
	bDropOnDeath=true
	WeaponSelectTexture=Texture2D'WEP_UI_HRG_Energy_TEX.UI_WeaponSelect_HRG_Energy'
	SecondaryAmmoTexture=Texture2D'UI_SecondaryAmmo_TEX.MedicDarts'
	AssociatedPerkClasses(0)=class'KFPerk_Gunslinger'

	// Shooting Animations
	FireSightedAnims[0]=Shoot_Iron
	FireSightedAnims[1]=Shoot_Iron2
	FireSightedAnims[2]=Shoot_Iron3

    // FOV
	MeshFOV=86
	MeshIronSightFOV=77
    PlayerIronSightFOV=77

	// Depth of field
	DOF_FG_FocalRadius=40
	DOF_FG_MaxNearBlurSize=3.5

	// Zooming/Position
	PlayerViewOffset=(X=29.0,Y=13,Z=-4)

	//Content
	PackageKey="HRG_Energy"
	FirstPersonMeshName="WEP_1P_HRG_Energy_MESH.Wep_1stP_HRG_Energy_Rig"
	FirstPersonAnimSetNames(0)="WEP_1P_HRG_Energy_ANIM.WEP_1P_HRG_Energy_ANIM"
	PickupMeshName="wep_3p_HRG_Energy_mesh.Wep_HRG_Energy_Pickup"
	AttachmentArchetypeName="WEP_HRG_Energy_ARCH.Wep_HRG_Energy_3P"
	MuzzleFlashTemplateName="WEP_HRG_Energy_ARCH.Wep_HRG_Energy_MuzzleFlash"

	OpticsUIClass=class'KFGFxWorld_MedicOptics'

   	// Zooming/Position
	IronSightPosition=(X=15,Y=0,Z=0)

	// Ammo
	MagazineCapacity[0]=15
	SpareAmmoCapacity[0]=120 //135
	InitialSpareMags[0]=2
	bCanBeReloaded=true
	bReloadFromMagazine=true

	MagazineCapacity[1]=0
	bCanRefillSecondaryAmmo=false

	// Recoil
	maxRecoilPitch=475 //250
	minRecoilPitch=425 //200
	maxRecoilYaw=130 //100
	minRecoilYaw=-130 //-100
	RecoilRate=0.07
	RecoilMaxYawLimit=500
	RecoilMinYawLimit=65035
	RecoilMaxPitchLimit=900
	RecoilMinPitchLimit=65035
	RecoilISMaxYawLimit=50
	RecoilISMinYawLimit=65485
	RecoilISMaxPitchLimit=250
	RecoilISMinPitchLimit=65485
	AltFireRecoilScale=2.0f

	// DEFAULT_FIREMODE
	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletSingle'
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_InstantHit
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Bullet_HRG_Energy'
	FireInterval(DEFAULT_FIREMODE)=+0.175 //342 RPM
	PenetrationPower(DEFAULT_FIREMODE)=1.0
	InstantHitDamage(DEFAULT_FIREMODE)=80 //90.0 //125.0
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Ballistic_HRG_Energy_Primary'
	Spread(DEFAULT_FIREMODE)=0.015
	FireOffset=(X=20,Y=4.0,Z=-3)

	// ALTFIRE_FIREMODE
	FireModeIconPaths(ALTFIRE_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_Electricity'
	FiringStatesArray(ALTFIRE_FIREMODE)=WeaponFiring
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_InstantHit
	FireInterval(ALTFIRE_FIREMODE)=+0.705 //85 RPM
	WeaponProjectiles(ALTFIRE_FIREMODE)=class'KFProj_Bullet_HRG_Energy_Secondary'
	InstantHitDamageTypes(ALTFIRE_FIREMODE)=class'KFDT_Ballistic_HRG_Energy_Secondary'
	InstantHitMomentum(ALTFIRE_FIREMODE)=1.0
	PenetrationPower(ALTFIRE_FIREMODE)=3.0
	InstantHitDamage(ALTFIRE_FIREMODE)=120.0 // 300.0 //475.0
	PenetrationDamageReductionCurve(ALTFIRE_FIREMODE)=(Points=((InVal=0.f,OutVal=0.f),(InVal=1.f, OutVal=1.f)))
	AmmoCost(ALTFIRE_FIREMODE)=3

	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_HRG_Energy'
	InstantHitDamage(BASH_FIREMODE)=26

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'ww_wep_hrg_energy.Play_WEP_HRG_Energy_3P_Shoot', FirstPersonCue=AkEvent'ww_wep_hrg_energy.Play_WEP_HRG_Energy_1P_Shoot')
	WeaponFireSnd(ALTFIRE_FIREMODE)=(DefaultCue=AkEvent'ww_wep_hrg_energy.Play_WEP_HRG_Energy_3P_ShootAlt', FirstPersonCue=AkEvent'ww_wep_hrg_energy.Play_WEP_HRG_Energy_1P_ShootAlt')
	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_SA_MedicPistol.Play_SA_MedicPistol_Handling_DryFire'
	WeaponDryFireSnd(ALTFIRE_FIREMODE)=AkEvent'WW_WEP_SA_MedicDart.Play_WEP_SA_Medic_Dart_DryFire'

	// Attachments
	bHasIronSights=true
	bHasFlashlight=false

	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.15f), (Stat=EWUS_Damage1, Scale=1.15f), (Stat=EWUS_Weight, Add=1)))
	
	SecondaryFireAnimRateModifier = 2.0f;

	DefaultFireMaterialColor=(R=0.90f,G=0.26f,B=0.0f)
	AltFireMaterialColor=(R=0.7f,G=0.04f,B=0.9f)

	NumBloodMapMaterials=3
//	bForceHandleImpacts=true;
}

//=============================================================================
// KFWeap_Bow_CompoundBow
//=============================================================================
// A Bow that can alternate between Sharp and Cryo arrows.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//	- Tulio Beloqui (Saber Interactive)
//=============================================================================

class KFWeap_Bow_CompoundBow extends KFWeapon;

/** Charge Level Props **/
var float MaxChargeTime;
var float ValueIncreaseTime;
var float StateMaxChargeTime;
var float StateValueIncreaseTime;

var transient float ChargeTime;
var transient float MaxChargeLevel;
var transient bool bIsFullyCharged;


/** Flag to check if we are still firing in the CompoundBowCharge state in order to check for interrupts when we are making the reload animation  */
var transient bool bHasArrowBeenFired;
/** Name to check from where we come from at active state begin play in order to prevent it to go from active to ironsights if a reload is pending  */
//var transient Name sPreviousStateName;


/** The FireMode to start fire after the Reload is complete
**  Used to keep charging the CompoundBow while reloading */
var byte StartFireModeAfterReload;

/** True if we are reloading after running out of ammo **/
var bool bReloadingFromEmptyMag;

/** The increase of the damage applied in each charge level **/
var float DmgIncreasePerCharge;

/** Array for holding the speeds applied to the projectile based on the charge level. See GetChargeLevel() **/
var	array<float> ArrowSpeedPerCharge;

/** How much to increase the wait time to force a reload, this value will be added to FireInterval **/
var() float		ForceReloadTime;

/** The partcile FX to display for the Cryo Projectile **/
var ParticleSystem CryoProjectileEffectOn;
var ParticleSystem CryoProjectileEffectOff;
var transient KFParticleSystemComponent CryoProjectilePSC;

/** The Sound FX to play for the Cryo Projectile **/
var() AkEvent CryoProjectileSoundEffectOn;
var() AkEvent CryoProjectileSoundEffectOff;

/** Anims for Iron, Idle and ShootLoop transitions **/
var(Animations) const editconst name IdleToIronSightAnim;
var(Animations) const editconst name IronSightToIdleAnim;
var(Animations) const editconst name IronSightShootToShootAnim;
var(Animations) const editconst name ShootToIronSightShootAnim;

const ArrowSocketName = 'RW_Weapon';

/** Returns a value between 0 and ArrowSpeedPerCharge size - 1. **/
simulated function int GetChargeLevel()
{
	local float Level;
	Level = Min(ChargeTime / StateValueIncreaseTime, MaxChargeLevel);
	return Min (Level, ArrowSpeedPerCharge.Length - 1);
}

/** Returns trader filter index based on weapon type (copied from Crossbow) */
static simulated event EFilterTypeUI GetTraderFilter()
{
    return FT_Projectile;
}

simulated function ConsumeAmmo (byte FireModeNum)
{
	super.ConsumeAmmo (FireModeNum);

	if (Role == ROLE_Authority || bAllowClientAmmoTracking)
	{
		if (FireModeNum == DEFAULT_FIREMODE || FireModeNum == ALTFIRE_FIREMODE)
		{
			bReloadingFromEmptyMag = (SpareAmmoCount[GetAmmoType (FireModeNum)] == 0);
		}
	}
}

/** Return true if this weapon should play the fire last animation for this shoot animation */
simulated function bool ShouldPlayFireLast(byte FireModeNum)
{
    if( SpareAmmoCount[GetAmmoType(FireModeNum)] == 0 )
    {
        return true;
    }
	
    return false;
}

/** Returns animation to play based on reload type and status */
simulated function name GetReloadAnimName (bool bTacticalReload)
{
    if( AmmoCount[GetAmmoType(CurrentFireMode)] > 0 )
	{
		// Disable half-reloads for now.  This can happen if server gets out
		// of sync, but choosing the wrong animation will just make it worse!
		`warn("Compound Bow reloading with non-empty mag");
	}

	if (bReloadingFromEmptyMag)
	{
		return bTacticalReload ? ReloadEmptyMagEliteAnim : ReloadEmptyMagAnim;
	}

	return bTacticalReload ? ReloadNonEmptyMagEliteAnim : ReloadNonEmptyMagAnim;
}

simulated function SetIronSights (bool bNewIronSights)
{
	local KFPawn_Human P;

	Super.SetIronSights(bNewIronSights);

	P = KFPawn_Human(Instigator);

	if (P != none && P.IsLocallyControlled())
	{
		P.SetIronSights(bNewIronSights, true);
		KFPawn(Instigator).bNetDirty = true;
	}
}

simulated function AltFireMode ()
{
	local KFPawn_Human P;

	super.AltFireMode ();
	
	// LocalPlayer Only
	if ( !Instigator.IsLocallyControlled()  )
	{
		return;
	}

	if( WorldInfo.NetMode == NM_DedicatedServer )
	{
		return;
	}
	
	if (bUseAltFireMode)
	{
		CryoProjectilePSC.DeactivateSystem();
		CryoProjectilePSC.SetTemplate(CryoProjectileEffectOn);
		CryoProjectilePSC.ActivateSystem();
		WeaponPlayFireSound (CryoProjectileSoundEffectOn, CryoProjectileSoundEffectOn);
	}
	else
	{
		CryoProjectilePSC.DeactivateSystem();
		CryoProjectilePSC.SetTemplate(CryoProjectileEffectOff);
		CryoProjectilePSC.ActivateSystem();
		WeaponPlayFireSound (CryoProjectileSoundEffectOff, CryoProjectileSoundEffectOff);
	}
	
	P = KFPawn_Human (Instigator);
	if (P != none)
	{
		P.SetUsingAltFireMode (bUseAltFireMode, true);
		P.bNetDirty = true;
	}
}

simulated function AttachWeaponTo (SkeletalMeshComponent MeshCpnt, optional Name SocketName)
{
	super.AttachWeaponTo (MeshCpnt, SocketName);

	if (CryoProjectilePSC == none)
	{
		CryoProjectilePSC = new(self) class'KFParticleSystemComponent';
		CryoProjectilePSC.SetDepthPriorityGroup(SDPG_Foreground);
		CryoProjectilePSC.SetTickGroup(TG_PostUpdateWork);
		CryoProjectilePSC.SetFOV(MySkelMesh.FOV);
		
		MySkelMesh.AttachComponentToSocket (CryoProjectilePSC, ArrowSocketName);
	}

	if (bUseAltFireMode)
	{
		CryoProjectilePSC.SetTemplate(CryoProjectileEffectOn);
		CryoProjectilePSC.ActivateSystem();
		WeaponPlayFireSound (CryoProjectileSoundEffectOn, CryoProjectileSoundEffectOn);
	}
}

/**
 * Detach weapon from skeletal mesh
 */
simulated function DetachWeapon()
{
	if (CryoProjectilePSC != none)
	{
		CryoProjectilePSC.DeactivateSystem ();
		MySkelMesh.DetachComponent (CryoProjectilePSC);
		CryoProjectilePSC = none;
	}
	
    super.DetachWeapon();
}

/**
 * Adjust the FOV for the first person weapon and arms.
 */
simulated event SetFOV( float NewFOV )
{
	super.SetFOV(NewFOV);

	if (CryoProjectilePSC != none)
	{
		CryoProjectilePSC.SetFOV(NewFOV);
	}
}

/**
* Apply the rate of fire modifier to the reload animation as well (for Marksman Perk Skill)
**/
simulated function float GetReloadRateScale ()
{
	local KFPerk CurrentPerk;
	local float AnimRate;
	
	CurrentPerk = GetPerk();
	AnimRate = super.GetReloadRateScale ();
	
	if (CurrentPerk != none)
	{
		CurrentPerk.ModifyRateOfFire( AnimRate, self );
	}

	return AnimRate;
}

/**
 * Starts playing looping FireAnim and FireSnd
 * Adjust the fire rate (for Sharpshooter Perk skill, Marksman)
 */
simulated function StartLoopingFireEffects(byte FireModeNum, optional bool bForceAnim)
{
	local KFPerk CurrentPerk;
	local float AdjustedAnimLength;
	local name WeaponFireAnimName;

	if ( bForceAnim || (FireModeNum < bLoopingFireAnim.Length && bLoopingFireAnim[FireModeNum]) )
	{
		// If available, try to play loop start anim
		WeaponFireAnimName = GetLoopStartFireAnim(FireModeNum);
		if ( WeaponFireAnimName != '' )
		{
			AdjustedAnimLength = MySkelMesh.GetAnimLength(WeaponFireAnimName);
			CurrentPerk = GetPerk();

			if (CurrentPerk != none)
			{
				CurrentPerk.ModifyRateOfFire( AdjustedAnimLength, self );
			}

			PlayAnimation(WeaponFireAnimName, AdjustedAnimLength, FALSE, FireTweenTime, 0.f);
		}
		// Otherwise go straight to the looping animation
		else
		{
			WeaponFireAnimName = GetLoopingFireAnim(FireModeNum);
			PlayAnimation(WeaponFireAnimName, MySkelMesh.GetAnimLength(WeaponFireAnimName), TRUE, FireTweenTime);
		}

		bPlayingLoopingFireAnim = true;
	}

	StartLoopingFireSound(FireModeNum);
}

/**
 * Stops playing looping FireAnim and FireSnd
 * Adjust the fire rate (for Sharpshooter Perk skill, Marksman)
 */
simulated function StopLoopingFireEffects(byte FireModeNum)
{
	local KFPerk CurrentPerk;
	local float AdjustedAnimLength;
	local name LoopEndFireAnim;

	if ( bPlayingLoopingFireAnim )
	{
		LoopEndFireAnim = GetLoopEndFireAnim(FireModeNum);	
		if ( LoopEndFireAnim != '' )
		{
			AdjustedAnimLength = MySkelMesh.GetAnimLength(LoopEndFireAnim);
			CurrentPerk = GetPerk();
			
			if (CurrentPerk != none)
			{
				CurrentPerk.ModifyRateOfFire( AdjustedAnimLength, self );
			}

			PlayAnimation(LoopEndFireAnim, AdjustedAnimLength);
		}
		else
		{
			ClearTimer(nameof(OnAnimEnd));	// needed for loopstart anim to return to idle
		}
		bPlayingLoopingFireAnim = false;
	}

	StopLoopingFireSound( FireModeNum );
}

simulated function CauseMuzzleFlash(byte FireModeNum)
{
	return;
}

/** Charging functionality inspired by HuskCannon fire ball **/
simulated function StartFire(byte FiremodeNum)
{
	/** Do not allow StartFire if we are either:
	*	a)charging (RefireCheckTimer) or
	*	b) we are forcing a Reload after shooting or still in Reloading state.
	**/
	if (FireModeNum == DEFAULT_FIREMODE || FireModeNum == ALTFIRE_FIREMODE || FireModeNum == GRENADE_FIREMODE || FireModeNum == BASH_FIREMODE)
	{
		if (IsTimerActive('RefireCheckTimer') || IsTimerActive(nameOf(ForceReload)) || IsInState('Reloading'))
		{
			if (FireModeNum == DEFAULT_FIREMODE || FireModeNum == ALTFIRE_FIREMODE)
			{
				StartFireModeAfterReload = FireModeNum;
			}

			return;
		}
	}

	super.StartFire(FiremodeNum);
}

simulated function StopFire (byte FireModeNum)
{
	StartFireModeAfterReload = FIREMODE_NONE;
	super.StopFire (FireModeNum);
}

simulated function OnStartFire()
{
	local KFPawn PawnInst;
	PawnInst = KFPawn(Instigator);

	if (PawnInst != none)
	{
		PawnInst.OnStartFire();
	}
}

simulated function float GetForceReloadDelay()
{
	return ForceReloadTime;
}

/** Don't sprint until we've finished our forced reload */
simulated function bool AllowSprinting()
{
	return !IsTimerActive( nameOf(ForceReload) );
}

/** ActiveIronSight and Active States to play Idle to Iron - Iron to Idle animations  **/
simulated state Active
{
	simulated function BeginState(Name PreviousStateName)
	{
		if (IsTimerActive('Timer_StopFireEffects'))
		{
			return;
		}	
		super.BeginState(PreviousStateName);
	}

	simulated function ZoomIn(bool bAnimateTransition, float ZoomTimeToGo)
	{
		if (IsTimerActive('Timer_StopFireEffects'))
		{
			return;
		}
		GotoState('ActiveIronSight');
	}
}

simulated state ActiveIronSight extends Active
{
	simulated function ZoomOut(bool bAnimateTransition, float ZoomTimeToGo)
	{
		ZoomTimeToGo = MySkelMesh.GetAnimLength(IronSightToIdleAnim);

		Global.ZoomOut( true, ZoomTimeToGo );

		PlayAnimation( IronSightToIdleAnim, ZoomTime, false );

		GotoState('Active');
	}

	simulated function BeginState( Name PreviousStateName )
	{
		//bHasArrowBeenFired
		local float ZoomTimeToGo;

		ZoomTimeToGo = MySkelMesh.GetAnimLength(IdleToIronSightAnim);

		Global.ZoomIn( true, ZoomTimeToGo );

		PlayAnimation( IdleToIronSightAnim, ZoomTime, false );
	}
}

simulated state CompoundBowCharge extends WeaponSingleFireAndReload
{
	// No need to replace FireAmmunition, global.FireAmmunition is called instead.
    simulated function FireAmmunition()
    {}

    //Store start fire time so we don't have to timer this
    simulated event BeginState(Name PreviousStateName)
    {
		local KFPerk CurrentPerk;

        super.BeginState(PreviousStateName);

		StateMaxChargeTime = MaxChargeTime;
		StateValueIncreaseTime = ValueIncreaseTime;

		CurrentPerk = GetPerk();
		if (CurrentPerk != none)
		{
			CurrentPerk.ModifyRateOfFire( StateMaxChargeTime, self );
			CurrentPerk.ModifyRateOfFire( StateValueIncreaseTime, self );
		}

		ChargeTime = 0;
		MaxChargeLevel = int(StateMaxChargeTime / StateValueIncreaseTime);
		bIsFullyCharged = false;
		bHasArrowBeenFired = false;
		global.OnStartFire();
    }

	simulated function bool ShouldRefire()
	{
		// ignore how much ammo is left (super/global counts ammo)
		return StillFiring(CurrentFireMode);
	}

    simulated event Tick(float DeltaTime)
    {
		global.Tick(DeltaTime);

		if (bIsFullyCharged)
		{
			return;
		}

		// Don't charge unless we're holding down the button
		if (PendingFire(CurrentFireMode))
		{
			ChargeTime += DeltaTime;
		}
		
		if (ChargeTime >= StateMaxChargeTime)
		{
			bIsFullyCharged = true;
		}
    }

    simulated event EndState(Name NextStateName)
    {
		ClearZedTimeResist();
        ClearPendingFire(CurrentFireMode);
		ClearTimer(nameof(RefireCheckTimer));

		KFPawn(Instigator).bHasStartedFire = false;
		KFPawn(Instigator).bNetDirty = true;

		if (bUsingSights)
    	{
		// do this locally and replicate to avoid sync errors w/ bIronSightOnBringUp
			if ( Instigator.IsLocallyControlled() )
			{
				SetIronSights(false);
			}
    	}
	}

	simulated function PutDownWeapon()
	{
		ChargeTime = 0;
		bIsFullyCharged = false;
		global.PutDownWeapon();
	}
	
	simulated function HandleFinishedFiring ()
	{
		super.FireAmmunition ();
		bHasArrowBeenFired = true;

		if (bPlayingLoopingFireAnim)
		{
			StopLoopingFireEffects(CurrentFireMode);
		}

		if (MuzzleFlash != none)
		{
			SetTimer(MuzzleFlash.MuzzleFlash.Duration, false, 'Timer_StopFireEffects');
		}
		else
		{
			SetTimer(0.3f, false, 'Timer_StopFireEffects');
		}

		NotifyWeaponFinishedFiring(CurrentFireMode);
		
		
		super.HandleFinishedFiring ();

		
	}

	/** override ZoomIn and ZoomOut for Idle to Iron animations **/
	simulated function ZoomIn(bool bAnimateTransition, float ZoomTimeToGo)
	{
		if (bHasArrowBeenFired || !bIsFullyCharged)
		{
			return;
		}
		if (IsTimerActive('Timer_StopFireEffects'))
		{
			return;
		}	
		ZoomTimeToGo = MySkelMesh.GetAnimLength(ShootToIronSightShootAnim);

		Global.ZoomIn( true, ZoomTimeToGo );

		PlayAnimation( ShootToIronSightShootAnim, ZoomTime, false );
	}

	simulated function ZoomOut (bool bAnimateTransition, float ZoomTimeToGo)
	{		
		if (IsTimerActive('Timer_StopFireEffects'))
		{
			return;
		}	
		ZoomTimeToGo = MySkelMesh.GetAnimLength(IronSightShootToShootAnim);

		Global.ZoomOut( true, ZoomTimeToGo );

		PlayAnimation( IronSightShootToShootAnim, ZoomTime, false );
	}
}

simulated function Timer_StopFireEffects()
{
	// Simulate weapon firing effects on the local client
	if (WorldInfo.NetMode == NM_Client)
	{
		Instigator.WeaponStoppedFiring(self, false);
	}

	ClearFlashCount();
	ClearFlashLocation();
}

/** Override Reloading state to give an accurate GetWeaponStateId() for 3rdP **/
simulated state Reloading
{
	simulated function byte GetWeaponStateId ()
	{
		local KFPerk Perk;
		local bool bTacticalReload;

		Perk = GetPerk ();
		bTacticalReload = (Perk != None && Perk.GetUsingTactialReload (self));

		if (bReloadingFromEmptyMag)
		{
			return bTacticalReload ? WEP_ReloadEmpty_Elite : WEP_ReloadEmpty;
		}

		return bTacticalReload ? WEP_Reload_Elite : WEP_Reload;
	}

	simulated function ReloadComplete()
	{
		super.ReloadComplete ();

		if (StartFireModeAfterReload != FIREMODE_NONE)
		{
			SetTimer(0.01f, true, 'Timer_StartFireAfterReload');
		}
	}
}

simulated function Timer_StartFireAfterReload()
{
	if (IsTimerActive('Timer_StopFireEffects'))
	{
		return;
	}
	
	ClearTimer('Timer_StartFireAfterReload');
	if (StartFireModeAfterReload != FIREMODE_NONE)
	{
		super.StartFire (StartFireModeAfterReload);
	}
}

simulated function int GetModifiedDamage(byte FireModeNum, optional vector RayDir)
{
	local int ModifiedDamage;

	ModifiedDamage = super.GetModifiedDamage(FireModeNum, RayDir);

	if (FireModeNum == DEFAULT_FIREMODE || FireModeNum == ALTFIRE_FIREMODE)
	{
		ModifiedDamage = ModifiedDamage * (1.f + DmgIncreasePerCharge * GetChargeLevel() );
	}

	return ModifiedDamage;
}

simulated function KFProjectile SpawnProjectile(class<KFProjectile> KFProjClass, vector RealStartLoc, vector AimDir)
{
	local KFProjectile SpawnedProjectile;
    local int Level;
	local float SpeedCharge;

	SpawnedProjectile = Super.SpawnProjectile(KFProjClass, RealStartLoc, AimDir);

	if (SpawnedProjectile != none && (CurrentFireMode == DEFAULT_FIREMODE || CurrentFireMode == ALTFIRE_FIREMODE))
	{
		Level = GetChargeLevel ();
		SpeedCharge = ArrowSpeedPerCharge[Level];

		SpawnedProjectile.MaxSpeed = SpeedCharge;
		SpawnedProjectile.Speed = SpeedCharge;
		SpawnedProjectile.TerminalVelocity = SpeedCharge;

		// give the effect of a shoot without charge for the first and second level:
		if (Level == 0 || level == 1)
		{
			SpawnedProjectile.SetPhysics (PHYS_Falling);
		}

		// Call init once again to update the Projectile's Velocity
		SpawnedProjectile.Init (AimDir);
	}

	return SpawnedProjectile;
}

/**
 * See Pawn.ProcessInstantHit
 * @param DamageReduction: Custom KF parameter to handle penetration damage reduction
 */
simulated function ProcessInstantHitEx(byte FiringMode, ImpactInfo Impact, optional int NumHits, optional out float out_PenetrationVal, optional int ImpactNum )
{
    local KFPerk InstigatorPerk;

    InstigatorPerk = GetPerk();
    if( InstigatorPerk != none )
    {
        InstigatorPerk.UpdatePerkHeadShots( Impact, InstantHitDamageTypes[FiringMode], ImpactNum );
    }

    super.ProcessInstantHitEx( FiringMode, Impact, NumHits, out_PenetrationVal, ImpactNum );
}

simulated function ANIMNOTIFY_LockBolt()
{
	// Consider us empty after every shot so the arrow gets hidden
	EmptyMagBlendNode.SetBlendTarget(1, 0);
}

defaultproperties
{
	// Inventory / Grouping
	InventoryGroup=IG_Primary
	InventorySize=8
	GroupPriority=125

	// Charge props
    MaxChargeTime=0.50664 //ShootLoop_Start[20] Time Length
    ValueIncreaseTime=0.2
	DmgIncreasePerCharge=0.5

	ArrowSpeedPerCharge(0)=4000.0
	ArrowSpeedPerCharge(1)=10000.0
	ArrowSpeedPerCharge(2)=15000.0

	StartFireModeAfterReload=FIREMODE_NONE

    // FOV / Position
    MeshFOV=86
	MeshIronSightFOV=52
    PlayerIronSightFOV=70
	PlayerViewOffset=(X=0,Y=0,Z=0)
	IronSightPosition=(X=0,Y=0,Z=0)

	WeaponSelectTexture=Texture2D'WEP_UI_CompoundBow_TEX.UI_WeaponSelect_Compound_Bow'
   	AssociatedPerkClasses(0)=class'KFPerk_Sharpshooter'

	// AI warning system
	bWarnAIWhenAiming=true
    MaxAIWarningDistSQ=4000000
	AimWarningDelay=(X=0.4f, Y=0.8f)
	AimWarningCooldown=0.0f

	// Content
	PackageKey="CompoundBow"
	FirstPersonMeshName="WEP_1P_CompoundBow_MESH.Wep_1stP_CompoundBow_Rig"
	FirstPersonAnimSetNames(0)="WEP_1P_CompoundBow_ANIM.Wep_1stP_CompoundBow_Anim"
	PickupMeshName="WEP_3P_CompoundBow_MESH.Wep_3rdP_CompoundBow_Pickup"
	AttachmentArchetypeName="WEP_CompoundBow_ARCH.Wep_CompoundBow_3P"
	MuzzleFlashTemplateName="WEP_CompoundBow_ARCH.Wep_CompoundBow_MuzzleFlash"

	// Ammo
	MagazineCapacity[0]=1
	SpareAmmoCapacity[0]=35 //30
	InitialSpareMags[0]=11 //10
	AmmoPickupScale[0]=4.0 //3.0

	// Recoil
	maxRecoilPitch=200
	minRecoilPitch=150
	maxRecoilYaw=100
	minRecoilYaw=-100
	RecoilRate=0.06
	RecoilMaxYawLimit=500
	RecoilMinYawLimit=65035
	RecoilMaxPitchLimit=900
	RecoilMinPitchLimit=64785
	RecoilISMaxYawLimit=50
	RecoilISMinYawLimit=65485
	RecoilISMaxPitchLimit=375
	RecoilISMinPitchLimit=65460

	bCanBeReloaded=true
	bReloadFromMagazine=true

	// Animation
	FireAnim=None
	FireSightedAnims[0]=None
	FireLastAnim=None
	FireLastSightedAnim=None

	bLoopingFireAnim(DEFAULT_FIREMODE)=true
	bLoopingFireAnim(ALTFIRE_FIREMODE)=true

	bHasFireLastAnims=true
	BonesToLockOnEmpty=(RW_Weapon)
	
	IdleToIronSightAnim=Idle_To_Iron
	IronSightToIdleAnim=Iron_To_Idle
	IronSightShootToShootAnim=ShootLoop_Iron_To_ShootLoop
	ShootToIronSightShootAnim=ShootLoop_To_ShootLoop_Iron

	ForceReloadTime=0.1

	// DEFAULT_FIREMODE
	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletArrow'
	FiringStatesArray(DEFAULT_FIREMODE)=CompoundBowCharge
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_Projectile
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Bolt_CompoundBowSharp'
	InstantHitDamage(DEFAULT_FIREMODE)=250.0
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Piercing_CompoundBowSharpImpact'
	PenetrationPower(DEFAULT_FIREMODE)=5.0
	FireInterval(DEFAULT_FIREMODE)=0.2 // For this weapon, this is not the fire rate, but the time when the auto reload anim kicks in
	Spread(DEFAULT_FIREMODE)=0.007 //0.007
	FireOffset=(X=25,Y=2.0,Z=-4.0)

	// ALT_FIREMODE
	FireModeIconPaths(ALTFIRE_FIREMODE)=Texture2D'wep_ui_cryogun_tex.UI_FireModeSelect_Cryogun'
	FiringStatesArray(ALTFIRE_FIREMODE)=CompoundBowCharge
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_Projectile
	WeaponProjectiles(ALTFIRE_FIREMODE)=class'KFProj_Bolt_CompoundBowCryo'
	InstantHitDamage(ALTFIRE_FIREMODE)=50.0
	InstantHitDamageTypes(ALTFIRE_FIREMODE)=class'KFDT_Piercing_CompoundBowCryoImpact'
	PenetrationPower(ALTFIRE_FIREMODE)=0.0
	FireInterval(ALTFIRE_FIREMODE)=0.2 // For this weapon, this is not the fire rate, but the time when the auto reload anim kicks in
	Spread(ALTFIRE_FIREMODE)=0.007 //0.007

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_SA_CompoundBow.CompoundBow_Fire_3P', FirstPersonCue=AkEvent'WW_WEP_SA_CompoundBow.CompoundBow_Fire_1P')
	WeaponFireSnd(ALTFIRE_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_SA_CompoundBow.CompoundBow_Fire_3P', FirstPersonCue=AkEvent'WW_WEP_SA_CompoundBow.CompoundBow_Fire_1P')

	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_SA_Crossbow.Play_WEP_SA_Crossbow_DryFire'
	WeaponDryFireSnd(ALTFIRE_FIREMODE)=AkEvent'WW_WEP_SA_Crossbow.Play_WEP_SA_Crossbow_DryFire'

	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Pirecing_CompoundBow'
	InstantHitDamage(BASH_FIREMODE)=100

	// Attachments
	bHasIronSights=true
	bHasFlashlight=false

	// Just like the launchers, this weapon has mag size of 1 and force reload which
	// causes significant ammo sync issues.  This fix is far from perfect, but it helps.
	bAllowClientAmmoTracking=true
		
	CryoProjectileEffectOn=ParticleSystem'WEP_CompoundBow_EMIT.FX_Compound_Bow_Cryo_Idle_1P'
	CryoProjectileEffectOff=ParticleSystem'WEP_CompoundBow_EMIT.FX_Compound_Bow_Cryo_ToggleOff'
	
	CryoProjectileSoundEffectOn=AkEvent'WW_WEP_SA_CompoundBow.CompoundBow_Cryo_On'
	CryoProjectileSoundEffectOff=AkEvent'WW_WEP_SA_CompoundBow.CompoundBow_Cryo_Off'
}

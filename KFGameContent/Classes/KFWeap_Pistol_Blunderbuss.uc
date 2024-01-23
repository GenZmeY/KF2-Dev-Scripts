//=============================================================================
// KFWeap_Pistol_Blunderbuss
//=============================================================================
// A pistol that can shoot explosive cannonballs and shard shotgun projectiles.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2020 Tripwire Interactive LLC
//	- Tulio Beloqui (Saber Interactive)
//=============================================================================

class KFWeap_Pistol_Blunderbuss extends KFWeap_PistolBase;

/** List of spawned cannon balls */
var array<KFProj_Cannonball_Blunderbuss> DeployedCannonballs;

/** Same as DeployedCannonballs.Length, but replicated because cannon balls are only tracked on server */
var int NumDeployedCannonballs;

/** set in the state to control the spawned projectiles **/
var bool bDeployedCannonball;

/** flag indicating that the cannonball was detonated **/
var bool bCannonballWasDetonated;

/** flag indicating that the cannonbal was converted to a time bomb and should not be converted again if it is in mid air **/
var bool bCannonballConvertedToTimeBomb;

/** flag indicating that the player released the button and the cannonbal can't be configured as a timed bomb **/
var bool bForceStandardCannonbal;

/** Amount of time we hold the fire button on this fire state, used in BlunderbussDeployAndDetonate **/
var transient float FireHoldTime;

/** Amount of time we should pass with the fire button on hold to trigger a timed explosion, used in BlunderbussDeployAndDetonate **/
var transient float TimedDetonationThresholdTime;

/** The server can block client shots in some cases **/
var transient bool bWaitingForServer;

var(Animations) const editconst	name		FireLoopStartLastSightedAnim;
var(Animations) const editconst	name		FireLoopStartLastAnim;
var(Animations) const editconst	name		FireLoopLastSightedAnim;

var bool bLastAnim;

replication
{
	if (bNetDirty)
		bDeployedCannonball, NumDeployedCannonballs, bCannonballWasDetonated;

}

static simulated event EFilterTypeUI GetTraderFilter()
{
	return FT_Explosive;
}

simulated function AltFireMode()
{
	if ( !Instigator.IsLocallyControlled() )
	{
		return;
	}

	StartFire(ALTFIRE_FIREMODE);
}

simulated function Projectile ProjectileFire()
{
	local Projectile P;
	local KFProj_Cannonball_Blunderbuss Cannonball;
	
	P = super.ProjectileFire();
	Cannonball = KFProj_Cannonball_Blunderbuss(P);

	if (Cannonball != none)
	{
		DeployedCannonballs.AddItem(Cannonball);
		NumDeployedCannonballs = DeployedCannonballs.Length;
		bForceNetUpdate = true;
	}

	return P;
}

/** Removes a charge from the list using either an index or an actor and updates NumDeployedCannonballs */
function RemoveDeployedCannonball(optional int CannonballIndex = INDEX_NONE, optional Actor CannonballActor)
{
	if (CannonballIndex == INDEX_NONE)
	{
		if (CannonballActor != none)
		{
			CannonballIndex = DeployedCannonballs.Find(CannonballActor);
		}
	}

	if (CannonballIndex != INDEX_NONE)
	{
		DeployedCannonballs.Remove(CannonballIndex, 1);
		NumDeployedCannonballs = DeployedCannonballs.Length;
		bForceNetUpdate = true;
	}
}

simulated function StartFire(byte FireModeNum)
{
	if(bWaitingForServer && FireModeNum <= 1)
	{
		return;
	}
	super.StartFire(FireModeNum);
}

simulated function EndFire(byte FireModeNum)
{
	//if(PendingFire(DEFAULT_FIREMODE)) return;
	bForceStandardCannonbal = true;
	super.EndFire(FireModeNum);
}

simulated function ResetFireState()
{
	FireHoldTime = 0;
	bForceStandardCannonbal = false;
	bCannonballWasDetonated = false;
	bCannonballConvertedToTimeBomb = false;
}

/*********************************************************************************************
 * State WeaponSingleFiring (Alt Fire)
 * Fire must be released between every shot.
 *********************************************************************************************/

simulated state WeaponSingleFiring
{
	simulated function FireAmmunition()
	{
		Super.FireAmmunition();
		if(Role != Role_Authority)
		{
			bWaitingForServer = true;
		}
	}

	simulated function bool ShouldRefire()
	{
		return Super.ShouldRefire() && !bWaitingForServer;
	}
}

/*********************************************************************************************
 * State Reloading
 * State the weapon is in when it is being reloaded
*********************************************************************************************/
simulated state Active
{
	simulated function BeginState( name PreviousStateName )
	{
		super.BeginState( PreviousStateName );
		
		if (Role == ROLE_Authority)
		{
			ClientResetFire();
		}
	}
}

/*********************************************************************************************
 * State BlunderbussDeployAndDetonate
 * The weapon is in this state while holding fire button for the CannonBall fire
*********************************************************************************************/

simulated state BlunderbussDeployAndDetonate extends WeaponSingleFiring
{
    simulated event BeginState(Name PreviousStateName)
    { 
		if( !IsTimerActive('TryDetonateCannonBall') )
		{
			SetTimer( 0.05f, true, nameof(TryDetonateCannonBall) );
		}

		Super.BeginState(PreviousStateName);
		ResetFireState();
	}

    simulated event EndState(Name NextStateName)
    {
		local int iNumOfCannonballs, i;
		
		if (Role == ROLE_Authority)
		{
			iNumOfCannonballs = DeployedCannonballs.Length;
			for(i=0; i < iNumOfCannonballs; i++)
			{
				DeployedCannonballs[0].Detonate();
			}
		}
		
		bDeployedCannonball = false;

		ClearTimer( nameof(TryDetonateCannonBall) );
		Super.EndState(NextStateName);
	}

	simulated function PutDownWeapon()
	{
		local KFProj_Cannonball_Blunderbuss Cannonball;
 
		if (Role == ROLE_Authority && bDeployedCannonball && DeployedCannonballs.Length > 0)
		{
			Cannonball = DeployedCannonballs[DeployedCannonballs.Length - 1];
			if (Cannonball.bIsTimedExplosive)
			{
				Cannonball.Detonate();
				bCannonballWasDetonated = true;
			}
		}

		if(Role == ROLE_Authority)
		{
			ClientResetFire();
			bDeployedCannonball = false;
		}

		global.PutDownWeapon();
	}
	
	simulated function TryDetonateCannonBall()
	{
		if( bCannonballWasDetonated || bWeaponPutDown || ShouldRefire() )
		{
			return;
		}

		DetonateCannonball();
	}

    simulated event Tick(float DeltaTime)
    {
		local KFProj_Cannonball_Blunderbuss Cannonball;

		global.Tick(DeltaTime);

		// Timed bomb is not allowed if we press the button after releasing it
		if(Role == ROLE_Authority && bForceStandardCannonbal && !bCannonballConvertedToTimeBomb)
		{
			bDeployedCannonball = false;
			bNetDirty=true;
			return;
		}

		// Don't charge unless we're holding down the button
		if (PendingFire(CurrentFireMode) && FireHoldTime < TimedDetonationThresholdTime)
		{
			FireHoldTime += DeltaTime;
		}

		if (Role == ROLE_Authority)
		{
			// Double check, this should not be empty:
			if (DeployedCannonballs.Length > 0)
			{
				Cannonball = DeployedCannonballs[DeployedCannonballs.Length - 1];
				
				// make sure we mark it as timed exploside only once!
				if (!Cannonball.bIsTimedExplosive && FireHoldTime >= TimedDetonationThresholdTime && !bCannonballConvertedToTimeBomb)
				{
					bCannonballConvertedToTimeBomb = true;
					Cannonball.bIsTimedExplosive = true;
					Cannonball.bNetDirty = true;
				}
			}
		}
    }
	
    simulated function FireAmmunition()
    {
		if (!bDeployedCannonball)
		{
			if(Role != Role_Authority)
			{
				bWaitingForServer = true;
			}

			super.FireAmmunition();
			ResetFireState();
			bNetDirty=true;
		}
		
		bDeployedCannonball = true;

		// re-set the pending fire, so we can still be in this state until release the fire button
		SetPendingFire(CurrentFireMode);
	}
	
	simulated function bool ShouldRefire()
	{
		return !bCannonballWasDetonated && StillFiring(CurrentFireMode);
	}

	simulated function DetonateCannonball ()
	{
		local KFProj_Cannonball_Blunderbuss Cannonball;

		if (Role == ROLE_Authority)
		{
			// Double check, this should be not empty:
			if (bDeployedCannonball && DeployedCannonballs.Length > 0)
			{
				Cannonball = DeployedCannonballs[DeployedCannonballs.Length - 1];
				if (Cannonball.bIsTimedExplosive)
				{
					Cannonball.Detonate();
					bCannonballWasDetonated = true;
					
					ClientResetFireInterval();
					if( IsTimerActive('RefireCheckTimer') )
					{
						ClearTimer( nameof(RefireCheckTimer) );
					}
					SetTimer( GetFireInterval(0), true, nameof(RefireCheckTimer) );
					bDeployedCannonball = false;
				}
			}
		}
	}

	simulated function HandleFinishedFiring ()
	{
		if (Role == ROLE_Authority)
		{
			// auto switch weapon when out of ammo and after detonating the last deployed ball
			if (!HasAnyAmmo() && NumDeployedCannonballs == 0)
			{
				if (CanSwitchWeapons())
				{
					Instigator.Controller.ClientSwitchToBestWeapon(false);
				}
			}
		}

		super.HandleFinishedFiring();
	}
}

reliable client function ClientResetFire()
{
	bWaitingForServer = false;
}

reliable client function ClientResetFireInterval()
{
	if( IsTimerActive('RefireCheckTimer') )
	{
		ClearTimer( nameof(RefireCheckTimer) );
	}
	SetTimer( GetFireInterval(0), true, nameof(RefireCheckTimer) );
}

simulated function HandleProjectileImpact(byte ProjectileFireMode, ImpactInfo Impact, optional float PenetrationValue)
{
	// Blunderbuss projectile detection is handled in the server to avoid collision sync problems
	if(Instigator != None && Instigator.Role == ROLE_Authority)
	{
		ProcessInstantHitEx(ProjectileFireMode, Impact,, PenetrationValue, 0);
	}
}

simulated function KFProjectile SpawnAllProjectiles(class<KFProjectile> KFProjClass, vector RealStartLoc, vector AimDir)
{
	local KFPerk InstigatorPerk;

	if (CurrentFireMode == ALTFIRE_FIREMODE)
	{
		InstigatorPerk = GetPerk();
		if (InstigatorPerk != none)
		{
			Spread[CurrentFireMode] = default.Spread[CurrentFireMode] * InstigatorPerk.GetTightChokeModifier();
		}
	}

	return super.SpawnAllProjectiles(KFProjClass, RealStartLoc, AimDir);
}

/** Get name of the animation to play for PlayFireEffects */
simulated function name GetLoopStartFireAnim(byte FireModeNum)
{
	if ( bUsingSights )
	{
		if(AmmoCount[GetAmmoType(FireModeNum)] <= 1 && FireModeNum == DEFAULT_FIREMODE)
		{
			return FireLoopStartLastSightedAnim;
		}
		else
		{
			return FireLoopStartSightedAnim;
		}
	}

	if(AmmoCount[GetAmmoType(FireModeNum)] <= 1 && FireModeNum == DEFAULT_FIREMODE)
	{
		return FireLoopStartLastAnim;
	}
	else
	{ 
		return FireLoopStartAnim;
	}
}

/** Get name of the animation to play for PlayFireEffects */
simulated function name GetLoopingFireAnim(byte FireModeNum)
{
	// scoped-sight anims
	if( bUsingScopePosition )
	{
		return FireLoopScopedAnim;
	}
	// ironsights animations
	else if ( bUsingSights )
	{
		if(AmmoCount[GetAmmoType(FireModeNum)] < 1 && FireModeNum == DEFAULT_FIREMODE)
		{
			return FireLoopLastSightedAnim;
		}
		else
		{
			return FireLoopSightedAnim;
		}
	}

	return FireLoopAnim;
}

defaultproperties
{

	//Custom Anims
	FireLoopStartLastSightedAnim=ShootLoop_Iron_Start_Last;
	FireLoopStartLastAnim=ShootLoop_Start_Last;
	FireLoopLastSightedAnim=ShootLoop_Iron_Last;

    // Revolver
	bRevolver=true
	bUseDefaultResetOnReload=false
	CylinderRotInfo=(Inc=120.0, Time=0.2)

	// Inventory
	InventoryGroup=IG_Primary
	InventorySize=7
	GroupPriority=100
	bCanThrow=true
	bDropOnDeath=true
	WeaponSelectTexture=Texture2D'WEP_UI_Blunderbuss_TEX.UI_WeaponSelect_BlunderBluss'
	bIsBackupWeapon=false

	// Gameplay
	TimedDetonationThresholdTime=0.01f

	// FOV
	MeshFOV=86
	MeshIronSightFOV=75
	PlayerIronSightFOV=75
	PlayerSprintFOV=95

	// Depth of field
	DOF_bOverrideEnvironmentDOF=true
	DOF_SharpRadius=500.0
	DOF_FocalRadius=1000.0
	DOF_MinBlurSize=0.0
	DOF_MaxNearBlurSize=2.0
	DOF_MaxFarBlurSize=0.0
	DOF_ExpFalloff=1.0
	DOF_MaxFocalDistance=2000.0

	DOF_BlendInSpeed=1.0
	DOF_BlendOutSpeed=1.0

	DOF_FG_FocalRadius=50
	DOF_FG_SharpRadius=0
	DOF_FG_MinBlurSize=0
	DOF_FG_MaxNearBlurSize=3
	DOF_FG_ExpFalloff=1

	// Zooming/Position
	PlayerViewOffset=(X=-15,Y=12,Z=-6)
	IronSightPosition=(X=-3,Y=0.145,Z=0)

	// Content
	PackageKey="Blunderbuss"
    FirstPersonMeshName="WEP_1P_Blunderbuss_MESH.Wep_1stP_Blunderbuss_Rig"
	FirstPersonAnimSetNames(0)="WEP_1P_Blunderbuss_ANIM.Wep_1stP_Blunderbuss_Anim"
	PickupMeshName="WEP_3P_Blunderbuss_MESH.Wep_3rdP_Blunderbuss_Pickup"
	AttachmentArchetypeName="WEP_Blunderbuss_ARCH.Wep_Blunderbuss_3P"
	MuzzleFlashTemplateName="WEP_Blunderbuss_ARCH.Wep_Blunderbuss_MuzzleFlash"
	Begin Object Name=FirstPersonMesh
		// new anim tree with skelcontrol to rotate cylinders
		AnimTreeTemplate=AnimTree'CHR_1P_Arms_ARCH.WEP_1stP_Animtree_Master_Revolver'
	End Object

	// Ammo
	MagazineCapacity[0]=3
	SpareAmmoCapacity[0]=39
	InitialSpareMags[0]=4
	bCanBeReloaded=true
	bReloadFromMagazine=true

	// Recoil
	maxRecoilPitch=900
	minRecoilPitch=775
	maxRecoilYaw=500
	minRecoilYaw=-500
	RecoilRate=0.085
	RecoilBlendOutRatio=1.1
	RecoilMaxYawLimit=500
	RecoilMinYawLimit=65035
	RecoilMaxPitchLimit=1500
	RecoilMinPitchLimit=64785
	RecoilISMaxYawLimit=50
	RecoilISMinYawLimit=65485
	RecoilISMaxPitchLimit=500
	RecoilISMinPitchLimit=65485

	// DEFAULT_FIREMODE
	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_Grenade'
	FiringStatesArray(DEFAULT_FIREMODE)=BlunderbussDeployAndDetonate
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_Projectile
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Cannonball_Blunderbuss'
	FireInterval(DEFAULT_FIREMODE)=+0.69 // 86 RPM
	InstantHitDamage(DEFAULT_FIREMODE)=300.0
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Ballistic_BlunderbussImpact'
	PenetrationPower(DEFAULT_FIREMODE)=0
	Spread(DEFAULT_FIREMODE)=0.015
	bLoopingFireAnim(DEFAULT_FIREMODE)=true
	FireOffset=(X=39,Y=5,Z=-5)

	// ALT_FIREMODE
	FireModeIconPaths(ALTFIRE_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletSingle'
	FiringStatesArray(ALTFIRE_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_Projectile
	WeaponProjectiles(ALTFIRE_FIREMODE)=class'KFProj_Nail_Blunderbuss'
	FireInterval(ALTFIRE_FIREMODE)=+0.69 // 86 RPM
	InstantHitDamage(ALTFIRE_FIREMODE)=50.0
	InstantHitDamageTypes(ALTFIRE_FIREMODE)=class'KFDT_Ballistic_BlunderbussShards'
	PenetrationPower(ALTFIRE_FIREMODE)=2.0
	Spread(ALTFIRE_FIREMODE)=0.175
	NumPellets(ALTFIRE_FIREMODE)=10

	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_Blunderbuss'
	InstantHitDamage(BASH_FIREMODE)=26

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_Blunderbuss.Play_WEP_Blunderbuss_Fire_3P_01', FirstPersonCue=AkEvent'WW_WEP_Blunderbuss.Play_WEP_Blunderbuss_Fire_1P_01')
	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_SA_9mm.Play_WEP_SA_9mm_Handling_DryFire'

	WeaponFireSnd(ALTFIRE_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_Blunderbuss.Play_WEP_Blunderbuss_Fire_3P_01', FirstPersonCue=AkEvent'WW_WEP_Blunderbuss.Play_WEP_Blunderbuss_Fire_1P_01')
	WeaponDryFireSnd(ALTFIRE_FIREMODE)=AkEvent'WW_WEP_SA_9mm.Play_WEP_SA_9mm_Handling_DryFire'

	// Attachments
	bHasIronSights=true
	bHasFlashlight=true

    AssociatedPerkClasses(0)=class'KFPerk_Demolitionist'
    AssociatedPerkClasses(1)=class'KFPerk_Support'

	// Custom animations
	FireSightedAnims=(Shoot_Iron)
	IdleFidgetAnims=(Guncheck_v1, Guncheck_v2, Guncheck_v3)

	bHasFireLastAnims=true
	BonesToLockOnEmpty=(RW_Hammer, RW_Frizzen)

	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.15f), (Stat=EWUS_Damage1, Scale=1.15f), (Stat=EWUS_Weight, Add=1)))
}
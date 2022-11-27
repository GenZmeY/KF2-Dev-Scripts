//=============================================================================
// KFWeap_ZedMKIII
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================

class KFWeap_ZedMKIII extends KFWeap_RifleBase;

/** Number of shots required in a row before firing a rocket */
var const byte NumBulletsBeforeRocket;
/** Minimum distance a target can be from the crosshair to be considered for lock on */
var const float MinTargetDistFromCrosshairSQ;
/** Dot product FOV that targets need to stay within to maintain a target lock */
var const float MaxLockMaintainFOVDotThreshold;
/** Time interval for updating radar positions */
var const float RadarUpdateEntitiesTime;
/** Distance the radar can track enemies */
var const float MaxRadarDistance;
/** Speed at which the radar moves (rad/sec) */
var const float RadarSpeed;
/** */
var const byte RadarTargetSize;

var transient array<KFPawn_Monster> EnemiesInRadar;
var transient byte NumShotsFired;
var transient float PrevAngle;
var transient bool bRequiresRadarClear;

var class<KFGFxWorld_WeaponRadar> RadarUIClass;
var KFGFxWorld_WeaponRadar RadarUI;

var const float MaxTargetAngle;
var transient float CosTargetAngle;

var transient bool LastShotIsRocket;
var WeaponFireSndInfo NormalFireSound;
var WeaponFireSndInfo RocketFireSound;

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	CosTargetAngle = Cos(MaxTargetAngle * DegToRad);
}

simulated function AltFireMode()
{

}

/**
* Given an potential target TA determine if we can lock on to it.  By default only allow locking on
* to pawns.
*/
simulated function bool CanLockOnTo(Actor TA)
{
	Local KFPawn PawnTarget;

	PawnTarget = KFPawn(TA);

	// Make sure the pawn is legit, isn't dead, and isn't already at full health
	if ((TA == None) || !TA.bProjTarget || TA.bDeleteMe || (PawnTarget == None) ||
		(TA == Instigator) || (PawnTarget.Health <= 0) || 
		!HasAmmo(DEFAULT_FIREMODE))
	{
		return false;
	}

	// Make sure and only lock onto players on the same team
	return !WorldInfo.GRI.OnSameTeam(Instigator, TA);
}

/** Finds a new lock on target */
simulated function bool FindTarget( out KFPawn RecentlyLocked )
{
	local KFPawn P, BestTargetLock;
	local byte TeamNum;
	local vector AimStart, AimDir, TargetLoc, Projection, DirToPawn, LinePoint;
	local Actor HitActor;
	local float PointDistSQ, Score, BestScore, TargetSizeSQ;

	TeamNum   = Instigator.GetTeamNum();
	AimStart  = GetSafeStartTraceLocation();
	AimDir    = vector( GetAdjustedAim(AimStart) );
	BestScore = 0.f;

	foreach WorldInfo.AllPawns( class'KFPawn', P )
	{
		if (!CanLockOnTo(P))
		{
			continue;
		}
		// Want alive pawns and ones we already don't have locked
		if( P != none && P.IsAliveAndWell() && P.GetTeamNum() != TeamNum )
		{
			TargetLoc  = GetLockedTargetLoc( P );
			Projection = TargetLoc - AimStart;
			DirToPawn  = Normal( Projection );

			// Filter out pawns too far from center
			
			if( AimDir dot DirToPawn < CosTargetAngle )
			{
				continue;
			}

			// Check to make sure target isn't too far from center
            PointDistToLine( TargetLoc, AimDir, AimStart, LinePoint );
            PointDistSQ = VSizeSQ( LinePoint - P.Location );

			TargetSizeSQ = P.GetCollisionRadius() * 2.f;
			TargetSizeSQ *= TargetSizeSQ;

            // Make sure it's not obstructed
            HitActor = class'KFAIController'.static.ActorBlockTest(self, TargetLoc, AimStart,, true, true);
            if( HitActor != none && HitActor != P )
            {
            	continue;
            }

            // Distance from target has much more impact on target selection score
            Score = VSizeSQ( Projection ) + PointDistSQ;
            if( BestScore == 0.f || Score < BestScore )
            {
            	BestTargetLock = P;
            	BestScore = Score;
            }
		}
	}

	if( BestTargetLock != none )
	{
		RecentlyLocked = BestTargetLock;

		// Plays sound/FX when locking on to a new target
		// PlayTargetLockOnEffects();

		return true;
	}

	RecentlyLocked = none;

	return false;
}

/** Adjusts our destination target impact location */
static simulated function vector GetLockedTargetLoc( Pawn P )
{
	// Go for the chest, but just in case we don't have something with a chest bone we'll use collision and eyeheight settings
	if( P.Mesh.SkeletalMesh != none && P.Mesh.bAnimTreeInitialised )
	{
		if( P.Mesh.MatchRefBone('Spine2') != INDEX_NONE )
		{
			return P.Mesh.GetBoneLocation( 'Spine2' );
		}
		else if( P.Mesh.MatchRefBone('Spine1') != INDEX_NONE )
		{
			return P.Mesh.GetBoneLocation( 'Spine1' );
		}
		
		return P.Mesh.GetPosition() + ((P.CylinderComponent.CollisionHeight + (P.BaseEyeHeight  * 0.5f)) * vect(0,0,1)) ;
	}

	// General chest area, fallback
	return P.Location + ( vect(0,0,1) * P.BaseEyeHeight * 0.75f );	
}

simulated function PlayFireEffects( byte FireModeNum, optional vector HitLocation )
{
	if (LastShotIsRocket)
	{
		super.PlayFireEffects(ALTFIRE_FIREMODE, HitLocation);

		WeaponPlayFireSound(WeaponFireSnd[ALTFIRE_FIREMODE].DefaultCue, WeaponFireSnd[ALTFIRE_FIREMODE].FirstPersonCue);

		return;
	}

	super.PlayFireEffects(FireModeNum, HitLocation);
}

simulated function Projectile ProjectileFire()
{
	if (CurrentFireMode == DEFAULT_FIREMODE || CurrentFireMode == ALTFIRE_FIREMODE)
	{
		if (NumShotsFired >= NumBulletsBeforeRocket)
		{
			WeaponFireSnd[ALTFIRE_FIREMODE]=RocketFireSound;
			CurrentFireMode = ALTFIRE_FIREMODE;
			NumShotsFired = 0;
			LastShotIsRocket = true;
		}
		else
		{
			WeaponFireSnd[ALTFIRE_FIREMODE]=NormalFireSound;
			CurrentFireMode = DEFAULT_FIREMODE;
			++NumShotsFired;
			LastShotIsRocket = false;
		}
	}

	return super.ProjectileFire();
}

/** Spawn projectile is called once for each rocket fired. In burst mode it will cycle through targets until it runs out */
simulated function KFProjectile SpawnProjectile( class<KFProjectile> KFProjClass, vector RealStartLoc, vector AimDir )
{
	local KFProj_Rocket_ZedMKIII RocketProj;
	local KFPawn TargetPawn;

    if ( CurrentFireMode == ALTFIRE_FIREMODE )
	{
		FindTarget(TargetPawn);

		RocketProj = KFProj_Rocket_ZedMKIII( super.SpawnProjectile( class<KFProjectile>(WeaponProjectiles[CurrentFireMode]) , RealStartLoc, AimDir) );

		if( RocketProj != none )
		{
			// We'll aim our rocket at a target here otherwise we will spawn a dumbfire rocket at the end of the function
			if ( TargetPawn != none)
			{
				//Seek to new target, then remove it
				RocketProj.SetLockedTarget( TargetPawn );
			}
		}

		// Resetting the firemode to default.
		CurrentFireMode = DEFAULT_FIREMODE;

		return RocketProj;
	}

   	return super.SpawnProjectile( KFProjClass, RealStartLoc, AimDir );
}

/*********************************************************************************************
 * state WeaponFiring
 * This is the default Firing State.  It's performed on both the client and the server.
 *********************************************************************************************/
simulated state WeaponFiring
{
	// Reset num shots fired when stop shooting
	simulated event EndState( Name NextStateName)
	{
		super.EndState(NextStateName);

		NumShotsFired = 0;
	}
}

/*********************************************************************************************
 * Radar implementation
 *********************************************************************************************/

simulated state WeaponEquipping
{
	simulated function BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);

		PrevAngle = 0.0f;

	 	if (WorldInfo.NetMode == NM_Client || WorldInfo.NetMode == NM_Standalone)
		{
			StartRadar();
		}
	}
} 

simulated state WeaponPuttingDown
{
	simulated function BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);

	 	if (WorldInfo.NetMode == NM_Client || WorldInfo.NetMode == NM_Standalone)
		{
			StopRadar();
		}
	}
}

simulated function StartRadar()
{
	SetTimer(RadarUpdateEntitiesTime, true, nameof(UpdateRadarEntities));
}

simulated function StopRadar()
{
	ClearTimer(nameof(UpdateRadarEntities));
	EnemiesInRadar.Length = 0;
}

simulated function UpdateRadarEntities()
{
	local KFPawn_Monster KFPM;
	local int RadarIndex;
	local bool bIsAlive;

	bIsAlive = false;

	// Get nearby enemies
	foreach CollidingActors(class'KFPawn_Monster', KFPM, MaxRadarDistance, Location, true)
	{
		RadarIndex = FindEnemyTrackedByRadar(KFPM);
		bIsAlive = KFPM.IsAliveAndWell();

		if (RadarIndex == INDEX_NONE)
		{
			if (bIsAlive)
			{
				EnemiesInRadar.AddItem(KFPM);
			}
		}
		else if(!bIsAlive)
		{
			EnemiesInRadar.RemoveItem(KFPM);
		}
	}
}

simulated function int FindEnemyTrackedByRadar(KFPawn_Monster KFPM)
{
	local int i;

	for (i = 0; i < EnemiesInRadar.Length; ++i)
	{
		if (KFPM == EnemiesInRadar[i] )
		{
			return i;
		}
	}

	return INDEX_NONE;
}

simulated function Tick(float Delta)
{
	local float DistanceSqrd;
	local vector Distance, ScreenDirection, UILocation;
	local rotator ViewRotation;
	local int i;
	local array<vector> RadarElements;

	super.Tick(Delta);

	if (RadarUI != none)
	{
		if (bRequiresRadarClear)
		{
			RadarUI.Clear();
		}

		if (EnemiesInRadar.Length == 0)
		{
			if (bRequiresRadarClear)
			{
				bRequiresRadarClear = false;
			}

			return;
		}

		ViewRotation = Rotation;
		ViewRotation.Yaw  *= -1;
		ViewRotation.Pitch = 0;
		ViewRotation.Roll  = 0;

		RadarElements.Length = 0;

		for (i = EnemiesInRadar.Length - 1; i >= 0; --i)
		{
			if (!EnemiesInRadar[i].IsAliveAndWell())
			{
				EnemiesInRadar.Remove(i, 1);
				continue;
			}

			Distance = EnemiesInRadar[i].Location - Location;
			DistanceSqrd = VSizeSQ(Distance);

			if (DistanceSqrd > MaxRadarDistance * MaxRadarDistance)
			{
				EnemiesInRadar.Remove(i, 1);
				continue;
			}

			Distance.Z = 0;
			ScreenDirection = Distance >> ViewRotation;

			UILocation.X = ScreenDirection.Y / MaxRadarDistance;
			UILocation.Y = ScreenDirection.X / MaxRadarDistance;

			RadarElements.AddItem(UILocation);
		}

		if (RadarElements.length > 0)
		{
			RadarUI.AddRadarElements(RadarElements);
			bRequiresRadarClear = true;
		}
	}
}

/** Radar UI */
reliable client function ClientWeaponSet(bool bOptionalSet, optional bool bDoNotActivate)
{
	local KFInventoryManager KFIM;

	super.ClientWeaponSet(bOptionalSet, bDoNotActivate);

	if (RadarUI == none && RadarUIClass != none)
	{
		KFIM = KFInventoryManager(InvManager);
		if (KFIM != none)
		{
			//Create the screen's UI piece
			RadarUI = KFGFxWorld_WeaponRadar(KFIM.GetRadarUIMovie(RadarUIClass));
		}
	}
}

function ItemRemovedFromInvManager()
{
	local KFInventoryManager KFIM;

	Super.ItemRemovedFromInvManager();

	if (RadarUI != none)
	{
		KFIM = KFInventoryManager(InvManager);
		if (KFIM != none)
		{
			//Create the screen's UI piece
			KFIM.RemoveRadarUIMovie(RadarUI.class);

			RadarUI.Close();
			RadarUI = none;
		}
	}
}

/** */

defaultproperties
{
    // FOV
	MeshFOV=70
	MeshIronSightFOV=30 //52
    PlayerIronSightFOV=70

	// Depth of field
	DOF_FG_FocalRadius=85
	DOF_FG_MaxNearBlurSize=2.5

	// Zooming/Position
	IronSightPosition=(X=14,Y=0.05,Z=-0.5) // x=-8,Y=0.01,Z=0.85
	PlayerViewOffset=(X=22,Y=12,Z=-2.5)

	// Content
	PackageKey="ZedMKIII"
	FirstPersonMeshName="WEP_1P_ZEDMKIII_MESH.Wep_1stP_ZEDMKIII_Rig"
	FirstPersonAnimSetNames(0)="WEP_1P_ZEDMKIII_ANIM.Wep_1stP_ZEDMKIII_Anim"
	PickupMeshName="WEP_3P_ZEDMKIII_MESH.Wep_3rdP_ZEDMKIII_Pickup"
	AttachmentArchetypeName = "WEP_ZEDMKIII_ARCH.Wep_ZEDMKIII_3P"
	MuzzleFlashTemplateName="WEP_ZEDMKIII_ARCH.Wep_ZEDMKIII_MuzzleFlash"

	// Ammo
	MagazineCapacity[0]=100
	SpareAmmoCapacity[0]=400
	InitialSpareMags[0]=1
	bCanBeReloaded=true
	bReloadFromMagazine=true

    bCanRefillSecondaryAmmo=0

	// Recoil
	maxRecoilPitch=125
	minRecoilPitch=100
	maxRecoilYaw=120
	minRecoilYaw=-100
	RecoilRate=0.085
	RecoilMaxYawLimit=500
	RecoilMinYawLimit=65035
	RecoilMaxPitchLimit=900
	RecoilMinPitchLimit=65035
	RecoilISMaxYawLimit=75
	RecoilISMinYawLimit=65460
	RecoilISMaxPitchLimit=375
	RecoilISMinPitchLimit=65460
	IronSightMeshFOVCompensationScale=4.0

	// Inventory
	InventorySize=9
	GroupPriority=125
	WeaponSelectTexture=Texture2D'wep_ui_zedmkiii_tex.UI_WeaponSelect_ZEDMKIII'

	// DEFAULT_FIREMODE
	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletAuto'
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponFiring
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_Projectile
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Bullet_ZedMKIII'
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Microwave_ZedMKIII'
	
    // ALT_FIREMODE
	FiringStatesArray(ALTFIRE_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_Projectile
    WeaponProjectiles(ALTFIRE_FIREMODE)=class'KFProj_Rocket_ZedMKIII'
	InstantHitDamage(ALTFIRE_FIREMODE)=100
	InstantHitDamageTypes(ALTFIRE_FIREMODE)=class'KFDT_Ballistic_ZedMKIII_Rocket'
	Spread(ALTFIRE_FIREMODE)=0.025
	AmmoCost(ALTFIRE_FIREMODE)=1

    FireInterval(DEFAULT_FIREMODE)=0.15 // 400 RPM //0.12 // 500 RPM //+0.1 // 600 RPM
	Spread(DEFAULT_FIREMODE)=0.0085
	PenetrationPower(DEFAULT_FIREMODE)=4.0
	InstantHitDamage(DEFAULT_FIREMODE)=50.0
	FireOffset=(X=30,Y=8,Z=-15)

	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_ZedMKIII'
	InstantHitDamage(BASH_FIREMODE)=27

	// Fire Effects
	NormalFireSound=(DefaultCue=AkEvent'WW_WEP_ZEDMKIII.Play_WEP_ZEDMKIII_Shoot_Single_3P', FirstPersonCue=AkEvent'WW_WEP_ZEDMKIII.Play_WEP_ZEDMKIII_Shoot_Single_1P')
	RocketFireSound=(DefaultCue=AkEvent'WW_WEP_ZEDMKIII.Play_WEP_ZEDMKIII_Shoot_Rocket_3P', FirstPersonCue=AkEvent'WW_WEP_ZEDMKIII.Play_WEP_ZEDMKIII_Shoot_Rocket_1P')

	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_ZEDMKIII.Play_WEP_ZEDMKIII_Shoot_LP_3P', FirstPersonCue=AkEvent'WW_WEP_ZEDMKIII.Play_WEP_ZEDMKIII_Shoot_LP_1P')
	WeaponFireSnd(ALTFIRE_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_ZEDMKIII.Play_WEP_ZEDMKIII_Shoot_Single_3P', FirstPersonCue=AkEvent'WW_WEP_ZEDMKIII.Play_WEP_ZEDMKIII_Shoot_Single_1P')
	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_ZEDMKIII.Play_WEP_ZEDMKIII_Handling_DryFire'
	WeaponDryFireSnd(ALTFIRE_FIREMODE)=AkEvent'WW_WEP_ZEDMKIII.Play_WEP_ZEDMKIII_Handling_DryFire'

	// Advanced (High RPM) Fire Effects
	bLoopingFireAnim(DEFAULT_FIREMODE)=true
	bLoopingFireSnd(DEFAULT_FIREMODE)=true
	WeaponFireLoopEndSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_ZEDMKIII.Play_WEP_ZEDMKIII_Shoot_LP_End_3P', FirstPersonCue=AkEvent'WW_WEP_ZEDMKIII.Play_WEP_ZEDMKIII_Shoot_LP_End_1P')
	SingleFireSoundIndex=ALTFIRE_FIREMODE

	// Attachments
	bHasIronSights=true
	bHasFlashlight=false

	AssociatedPerkClasses(0)=class'KFPerk_Demolitionist'

    NumBulletsBeforeRocket=6
    NumShotsFired=0
    MinTargetDistFromCrosshairSQ=2500.0f
	MaxLockMaintainFOVDotThreshold=0.36f

	RadarUpdateEntitiesTime=0.1f
	MaxRadarDistance=2000
	RadarSpeed=2.0f
	RadarTargetSize=10.0f

	RadarUIClass=class'KFGFxWorld_WeaponRadar'

    NumBloodMapMaterials=2
	bRequiresRadarClear=false

	MaxTargetAngle=10

	LastShotIsRocket=false
}

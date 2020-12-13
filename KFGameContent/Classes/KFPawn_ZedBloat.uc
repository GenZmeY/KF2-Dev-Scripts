//=============================================================================
// KFPawn_ZedBloat
//=============================================================================
// Bloat
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFPawn_ZedBloat extends KFPawn_Monster;

/** Socket used to attach puke effect */
var protected const name PukeSocketName;

/** How far away the bloat's vomit can damage enemies */
var protected const float VomitRange;

/** At a base level how much damage this zed's vomit will do */
var protected const int VomitDamage;

/** Any pawn in this range will take damage when the bloat explodes */
var protected const float ExplodeRange;

/** Set to TRUE when bloat has exploded */
var protected bool bHasExploded;

/** Projectile to spawn for puke mine attack */
var protected const class<KFProjectile> PukeMineProjectileClass;

/** Rotation offsets to use when spawning our 3 puke mins on death */
var protected array<rotator> DeathPukeMineRotations;

/** Number of puke mines to spawn when bloat is killed, as long as it wasn't obliterated */
var protected byte NumPukeMinesToSpawnOnDeath;

/** Pre-death location and rotation */
var protected vector OldLocation;
var protected rotator OldRotation;

/** Set to TRUE when a non-explosive hitzone was injured */
var transient protected bool bWasDismembered;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	// Set the number of puke mines we're allowed to spawn on death
	if( WorldInfo.Game != none )
	{
		NumPukeMinesToSpawnOnDeath = class<KFDifficulty_Bloat>(DifficultySettings).static.GetPukeMinesToSpawnOnDeath( self, WorldInfo.Game );
	}
}

/** Script AnimNotify which makes the Bloat begin to discharge vomit */
function ANIMNOTIFY_PukeAttack()
{
	Puke();
}

/** Guess */
function Puke()
{
	local Pawn P;
	local Vector PukeLocation, PukeDirection;
	local Rotator PukeRotation;
	local vector HitLocation, HitNormal, EndTrace, Momentum;
	local Actor HitActor;

	Mesh.GetSocketWorldLocationAndRotation( 'PukeSocket', PukeLocation, PukeRotation );

	PukeDirection  = Vector(Rotation);
	PukeDirection.Z = 0.f;
	foreach WorldInfo.AllPawns(class'Pawn', P, PukeLocation, VomitRange)
	{
		if( CanPukeOnTarget(P, PukeLocation, PukeDirection) )
		{
        	DealPukeDamage( P, PukeLocation );
		}
	}

	// Extra handling for fracture mesh actors, etc
	EndTrace = PukeLocation + PukeDirection*VomitRange;
	HitActor = Trace( HitLocation, HitNormal, EndTrace, PukeLocation, true, vect(10,10,10) );
	if( HitActor != none && HitActor.bCanBeDamaged && Pawn(HitActor) == none )
	{
		Momentum = EndTrace - PukeLocation;
		Momentum.Z = 0.f;
		Momentum = Normal(Momentum);
		HitActor.TakeDamage( VomitDamage, Controller, HitLocation, Momentum, class'KFDT_BloatPuke',, self );
	}
}

function DealPukeDamage( Pawn Victim, Vector Origin )
{
	local Vector VectToEnemy;

	VectToEnemy = Victim.Location - Origin;
	VectToEnemy.Z = 0.f;
	VectToEnemy = Normal( VectToEnemy );

	Victim.TakeDamage( GetRallyBoostDamage(VomitDamage), Controller, Victim.Location, VectToEnemy, class'KFDT_BloatPuke',, self );
}

function bool CanPukeOnTarget( Pawn PukeTarget, Vector PukeLocation, Vector PukeDirection)
{
	local Vector VectToEnemy;
	local Box ActorBox;

	if( PukeTarget != none )
	{
		VectToEnemy = PukeTarget.Location - PukeLocation;
		VectToEnemy.Z = 0.f;
		VectToEnemy = Normal( VectToEnemy );

		PukeTarget.GetComponentsBoundingBox( ActorBox );

		if( ( !PukeTarget.bWorldGeometry || PukeTarget.bCanBeDamaged ) &&
			ActorBox.Min.Z < PukeLocation.Z && VectToEnemy dot PukeDirection > 0.5f )  // (0.5 = vomitarc)
		{
			// use the bounding box for the world trace to account for meshes with way off center origins
			if( PukeTarget.FastTrace( (ActorBox.Min + ActorBox.Max) * 0.5, PukeLocation,, true) )
			{
				return true;
			}
		}
	}

	return false;
}

/** Override so you can always injure a bloats stomach and cause an explosion */
function bool CanInjureHitZone(class<DamageType> DamageType, int HitZoneIdx)
{
	if( HitExplosiveBone( HitZones[HitZoneIdx].BoneName ) )
	{
		return true;
	}

	if( super.CanInjureHitZone(DamageType, HitZoneIdx) )
	{
		bWasDismembered = true;
		return true;
	}

	return false;
}

/** Overridden to only return TRUE if a non-explosive bone was hit */
simulated function bool HasInjuredHitZones()
{
	return bWasDismembered || IsHeadless();
}

/** This pawn has died. */
function bool Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	OldLocation = Location;
	OldRotation = Rotation;

	return super.Died( Killer, damageType, HitLocation );
}

// Override to deal explosive damage for the killing shot of an explosive bone
function TakeHitZoneDamage(float Damage, class<DamageType> DamageType, int HitZoneIdx, vector InstigatorLocation)
{
	local int HitZoneIndex;
	local name HitBoneName;

	super.TakeHitZoneDamage( Damage, DamageType, HitZoneIdx, InstigatorLocation );

	// Only deal explosive damage on the killing shot
	if( Role == ROLE_Authority && bPlayedDeath && !bHasExploded && TimeOfDeath == WorldInfo.TimeSeconds )
	{
		HitZoneIndex = HitFxInfo.HitBoneIndex;
		if ( HitZoneIndex != 255 && (InjuredHitZones & (1 << HitZoneIndex)) > 0 )	// INDEX_None -> 255 after byte conversion
		{
			HitBoneName = HitZones[HitZoneIndex].BoneName;
			if( HitExplosiveBone(HitBoneName) )
		    {
		    	DealExplosionDamage();
		    	bHasExploded = true;

		    	// Spawn some puke mines
		    	SpawnPukeMinesOnDeath();

		    	SoundGroupArch.PlayObliterationSound(self, false);
		    }
		}
	}
}

/** Check if the bone we hit can cause an explosion */
function bool HitExplosiveBone( name HitBoneName )
{
	local byte JointIndex;
	local KFCharacterInfo_Monster MonsterInfo;

    MonsterInfo = GetCharacterMonsterInfo();
	if ( MonsterInfo != none )
	{
		for( JointIndex = 0; JointIndex < MonsterInfo.GoreJointSettings.length; JointIndex++ )
		{
			if( MonsterInfo.GoreJointSettings[JointIndex].HitBoneName == HitBoneName &&
				MonsterInfo.GoreJointSettings[JointIndex].HitExplosionGore.length > 0 )
			{
				return true;
			}
		}
	}

	return false;
}

function DealExplosionDamage()
{
   	local Pawn P;
   	local vector HitLocation, HitNormal;
    local Actor HitActor;

	// @note - At low ranges CollidingActors (no VisibleCollidingActors) is okay,
	// but AllPawns is constant and much faster 99% of the time.
	foreach WorldInfo.AllPawns( class'Pawn', P, Location, ExplodeRange )
	{
		if ( P != Instigator )
		{
			// Trace to make sure there are no obstructions. ie acquiring someone through a wall
			HitActor = Instigator.Trace(HitLocation, HitNormal, P.Location, Location, true);
			if ( HitActor == none || HitActor == P )
			{
				DealPukeDamage(P, Location);
			}
		}
	}
}

/** Spawns a puke mine at the specified location and rotation. Network: SERVER */
function SpawnPukeMine( vector SpawnLocation, rotator SpawnRotation )
{
	local KFProjectile PukeMine;

	PukeMine = Spawn( PukeMineProjectileClass, ,, SpawnLocation, SpawnRotation,, true );
	if( PukeMine != none )
	{
		PukeMine.Init( vector(SpawnRotation) );
	}
}

/** Spawns several puke mines when dying */
function SpawnPukeMinesOnDeath()
{
	local int i;

	// Spawn puke mines
	while( NumPukeMinesToSpawnOnDeath > 0 && DeathPukeMineRotations.Length > 0 )
	{
		i = Rand( DeathPukeMineRotations.Length );
		SpawnPukeMine( OldLocation, Normalize(OldRotation + DeathPukeMineRotations[i]) );
		DeathPukeMineRotations.Remove( i, 1 );

		--NumPukeMinesToSpawnOnDeath;
	}
}

/**
 * Dialog
 **/

/** Returns (hardcoded) dialog event ID for when trader gives advice to player who was killed by this zed type */
static function int GetTraderAdviceID()
{
	return 41;//TRAD_AdviceBloat
}

DefaultProperties
{
	LocalizationKey=KFPawn_ZedBloat
	Begin Object Name=KFPawnSkeletalMeshComponent
		// Enabling kinematic for physics interaction while alive.  (see also MinDistFactorForKinematicUpdate)
		bUpdateKinematicBonesFromAnimation=true
		bPerBoneMotionBlur=false
	End Object

	// ---------------------------------------------
	// Stats
	XPValues(0)=17
	XPValues(1)=22
	XPValues(2)=30
	XPValues(3)=34

	//BaseEyeHeight=1.f
	// ---------------------------------------------
	// Content
	MonsterArchPath="ZED_ARCH.ZED_Bloat_Archetype"
	PawnAnimInfo=KFPawnAnimInfo'ZED_Bloat_ANIM.Bloat_AnimGroup'
	DifficultySettings=class'KFDifficulty_Bloat'

	// ---------------------------------------------
	// Special Moves
	Begin Object Name=SpecialMoveHandler_0
		SpecialMoveClasses(SM_Evade)=class'KFSM_Evade'
		SpecialMoveClasses(SM_Evade_Fear)=class'KFSM_Evade_Fear'
		SpecialMoveClasses(SM_Block)=class'KFSM_Block'
	End Object

	// for reference: Vulnerability=(default, head, legs, arms, special)
	IncapSettings(AF_Stun)=		(Vulnerability=(0.5, 1.0, 0.5, 0.5, 0.5), Cooldown=5.0,  Duration=1.5)
	IncapSettings(AF_Knockdown)=(Vulnerability=(1.0),	                  Cooldown=1.0)
	IncapSettings(AF_Stumble)=	(Vulnerability=(0.4),	                  Cooldown=1.0)
	IncapSettings(AF_GunHit)=	(Vulnerability=(0.35),	                  Cooldown=0.1)
	IncapSettings(AF_MeleeHit)=	(Vulnerability=(2.0),	                  Cooldown=0.3)
	IncapSettings(AF_Poison)=	(Vulnerability=(0.15),	                  Cooldown=20.5, Duration=5.0)
	IncapSettings(AF_Microwave)=(Vulnerability=(4.0),	                  Cooldown=5.0,  Duration=8.0)
	IncapSettings(AF_FirePanic)=(Vulnerability=(1),		                  Cooldown=5.0,	 Duration=3.7) //duration 8
	IncapSettings(AF_EMP)=		(Vulnerability=(2.5),                     Cooldown=5.0,  Duration=3.0)
	IncapSettings(AF_Freeze)=	(Vulnerability=(1.0),                     Cooldown=3.0,  Duration=2.0)
    IncapSettings(AF_Snare)=	(Vulnerability=(1.0, 2.0, 1.0, 1.0),      Cooldown=5.5,  Duration=3.0)
    IncapSettings(AF_Bleed)=    (Vulnerability=(1.0))

	Begin Object Name=Afflictions_0
		FireFullyCharredDuration=3.5
	End Object

	ParryResistance=3

	// ---------------------------------------------
	// Gameplay
	VomitRange=350.f
	VomitDamage=12
	ExplodeRange=500.f
	Begin Object Name=MeleeHelper_0
		BaseDamage=14.f
		MaxHitRange=250.f
		MomentumTransfer=25000.f
		MyDamageType=class'KFDT_Slashing_ZedWeak'
	End Object

	Health=405
	HeadlessBleedOutTime=6.f
	// Override Head GoreHealth (aka HeadHealth)
    HitZones[HZI_HEAD]=(ZoneName=head, BoneName=Head, Limb=BP_Head, GoreHealth=75, DmgScale=1.0001, SkinID=1)
	HitZones.Add((ZoneName=rknife, BoneName=RightForearm, Limb=BP_RightArm, GoreHealth=20, DmgScale=0.2, SkinID=2))
	HitZones.Add((ZoneName=lknife, BoneName=LeftForearm, Limb=BP_LeftArm, GoreHealth=20, DmgScale=0.2, SkinID=2))
	DoshValue=17
	Mass=130.f

	// Penetration
    PenetrationResistance=3.0

    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Submachinegun', 	DamageScale=(0.35)))  //0.25
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_AssaultRifle', 	DamageScale=(0.35)))  //0.25
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Shotgun', 	        DamageScale=(0.25)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Handgun', 	        DamageScale=(0.35)))  //0.2
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Rifle', 	        DamageScale=(0.30)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_Slashing', 	                DamageScale=(0.3)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Bludgeon', 	                DamageScale=(0.3)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Fire', 	                    DamageScale=(1.0)))  //1.2 //1.6
	DamageTypeModifiers.Add((DamageType=class'KFDT_Microwave', 	                DamageScale=(0.8)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Explosive', 	                DamageScale=(0.5)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Piercing', 	                DamageScale=(0.25)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Toxic', 		                DamageScale=(0.25)))

	//Special Case damage resistance
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_9mm',              DamageScale=(0.65)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_AR15',             DamageScale=(0.40)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_HRGTeslauncher',   DamageScale=(0.58)))

	// ---------------------------------------------
	// Block Settings
	MinBlockFOV=0.1f

	// ---------------------------------------------
	// Movement / Physics
	Begin Object Name=CollisionCylinder
		CollisionRadius=+0055.000000 // Mesh is pulled back by 20 UU
	End Object

	RotationRate=(Pitch=50000,Yaw=20000,Roll=50000)
	GroundSpeed=150.0f
	SprintSpeed=210.0f   //260
	PhysRagdollImpulseScale=1.5f
	KnockdownImpulseScale=2f //1.5

	// ---------------------------------------------
	// AI / Navigation
	ControllerClass=class'KFAIController_ZedBloat'
	BumpDamageType=class'KFDT_NPCBump_Large'
	DamageRecoveryTimeHeavy=0.85f
	DamageRecoveryTimeMedium=1.0f

	// ---------------------------------------------
	// Puke Mines
	PukeMineProjectileClass=class'KFGameContent.KFProj_BloatPukeMine'
	DeathPukeMineRotations(0)=(Pitch=7000,Yaw=10480,Roll=0)
	DeathPukeMineRotations(1)=(Pitch=7000,Yaw=32767,Roll=0)
	DeathPukeMineRotations(2)=(Pitch=7000,Yaw=-10480,Roll=0)

	// ---------------------------------------------

`if(`notdefined(ShippingPC))
	DebugRadarTexture=Texture2D'UI_ZEDRadar_TEX.MapIcon_Bloat';
`endif

	// ---------------------------------------------
	// Spawning
    MinSpawnSquadSizeType=EST_Large

    bIsBloatClass=true
}

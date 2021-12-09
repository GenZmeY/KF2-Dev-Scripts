//=============================================================================
// KFPawn_Monster
//=============================================================================
// Base pawn class for Zeds
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Andrew "Strago" Ladenberger
//=============================================================================

class KFPawn_Monster extends KFPawn
	abstract
	nativereplication
	native(Pawn)
	dependson(KFPawnAnimInfo, KFPawnVoiceGroup, KFPawnVoiceGroupEventData, KFSpawnVolume, KFHeadShotEffectList);

`include(KFGame\KFGameAnalytics.uci);
`include(KFGame\KFMatchStats.uci);

/************************************
 * @name	General info for AAR/Stats
 ************************************/

var bool bLargeZed;
var bool bVersusZed;

/************************************
 * @name	Content
 ************************************/

 /** Path for DLO of the MonsterArch */
var const string MonsterArchPath;
/**
 * Default content loaded by this pawn.  Private, use GetCharacterMonsterInfo()
 * NOTE: DO NOT statically reference in defaults as it needs to be loaded dynamically
 */
var private const KFCharacterInfo_Monster CharacterMonsterArch;

var transient bool bArchLoaded;

/** List of variants that this pawn can be spawned as */
var const array<class<KFPawn_Monster> > ElitePawnClass;

/** Custom third person camera offsets */
var() ViewOffsetData	ThirdPersonViewOffset;

/** Randomized color index from the monster arch if it exists for this zed */
var int RandomColorIdx;

/** List of static attachments from the character info */
var array<StaticMeshComponent> StaticAttachList;

/*********************************************************************************************
 * @name	Combat
********************************************************************************************* */

/** The chance that this monster pawn will sprint */
var(Combat) float	SprintChance;
var(Combat) bool	bCanGrabAttack;
/** Odds (0-1) of evaluating whether to do a grab attack instead of a basic melee attack */
var(Combat) float	GrabAttackFrequency;
var(Combat) bool	bCanMeleeAttack;
var(Combat) bool 	bHasExtraSprintJumpVelocity;

/** The amount to scale this Zed's damage based on difficulty */
var(Combat) float	DifficultyDamageMod;

/** GameInfo based damage resistance modifier cached at spawn time (0: Ignore, 1: Standard) */
var(Combat) float 	GameResistancePct;

/** Time until death after head is taken off */
var(Combat) float	HeadlessBleedOutTime;
/** Enables crippled animation and behavior state */
var	repnotify bool	bIsHeadless;

/** If > 0, clientside head injury gore can be applied while still alive */
var byte MaxHeadChunkGoreWhileAlive;

/** Object that manages melee attacks, and stores default damage */
var(Weapon) instanced KFMeleeHelperAI MeleeAttackHelper;

var protected 	bool 	bHasReducedMeleeDamage;

/** Total dosh this monster is worth on kill */
var private const	int		DoshValue;
/** XP this monster is worth (per difficulty) */
var private const 	float	XPValues[4];
/** List of sockets representing weakpoint zone locations */
var() array<name> WeakSpotSocketNames;

/** Heal after die */
var int	HealByKill;
var int	HealByAssistance;

/** WWL Hat attach name*/
var name ZEDCowboyHatAttachName;


/**
 * Information on resistant or vulnerable damage types
 * @todo: This is all static data so we should consider moving to the archetype
*/
struct native DamageModifierInfo
{
    /** A damage type to modify damage to this zed when it is received */
	var() class<DamageType> DamageType;
	/** Damage scale for this damage type. Additional array elements (MAX:4) can be used to modify for higher game difficulties */
    var() array<float> DamageScale;

	structdefaultproperties
	{
        DamageScale=(1.f)
	}
};

/** These damage types cause this zed to receive increased damage */
var  array<DamageModifierInfo> DamageTypeModifiers;
/** Additional damage type modifiers that can override the defaults */
var  array<DamageModifierInfo> LiveDamageTypeModifiers;

/** Special move cooldown info */
struct native SpecialMoveCooldownInfo
{
	var float CooldownTime;
	var transient float LastUsedTime;
	var ESpecialMove SMHandle;

	/** Used by UI */
	var Texture2D SpecialMoveIcon;
	var int Charges;

	var string NameLocalizationKey;
	var bool bShowOnHud;

	structdefaultproperties
	{
		SMHandle=SM_None
		bShowOnHud=true
		LastUsedTime=0.f
		SpecialMoveIcon=Texture2D'UI_Widgets.MenuBarWidget_SWF_IF'
		Charges=-1
	}
};

/** The amount to scale damage dealt by the fleshpound */
var float ZedBumpDamageScale;

var protected bool bShowHealth;

/** Set only while inside AdjustDamage when calculating extra head explosion damage*/
var transient bool bCheckingExtraHeadDamage;

/** Base human-controlled melee damage */
var(Combat) float HumanBaseMeleeDamage;

/** Contains balance settings per game difficulty */
var class<KFMonsterDifficultyInfo> DifficultySettings;

struct native WeakPoint
{
	var name BoneName;
	var vector Offset;
};


/*********************************************************************************************
 * @name	Player-controlled
********************************************************************************************* */

/*
 * Move list classification used by MoveListGamepadScheme
 * Must be aligned firemode
 * -- label w/ default bind for readability
 */
enum EPlayerZedGamepadMove
{
	ZGM_Attack_R2, 		// firemode 0 -- R2
	ZGM_Block_R1,  		// firemode 1 -- R1
	ZGM_Melee_Square,  	// firemode 2 -- Square
	ZGM_Special_R3, 	// firemode 3 -- R3
	ZGM_Explosive_Ll,	// firemode 4 -- L1
	ZGM_Attack_L2, 		// firemode 5 -- L2
	ZGM_Melee_Triangle, // firemode 6 -- Triangle
};

/* For gamepads remap the controls by type (aligned to EPlayerZedGamepadMove) */
var array<ESpecialMove> MoveListGamepadScheme;

/** Cooldown times for each special move ability */
var array<SpecialMoveCooldownInfo> SpecialMoveCooldowns;

/** Flag set after executing a jump */
var bool bJumped;

var transient float LastAttackHumanWarningTime;

/*********************************************************************************************
 * @name	Hit Reactions
********************************************************************************************* */

/** Settings for the slowed down incapacitation effect */
const SLOW_SPEED_MOD = 0.8f;

/** Resistance value for special move reaction to being parried */
var byte ParryResistance;

/** true if we currently incap poisoned */
var repnotify bool 	bIsPoisoned;
/** Is microwave panic active? (server only) */
var bool 			bMicrowavePanicked;

struct native RepInflateParams
{
	var byte RepInflateMatParam;
	var bool bHasToIgniteFlames;
	var int Count;
};

var repnotify RepInflateParams RepInflateMatParams;


/** Replicated material parameter */
var repnotify byte	RepInflateMatParam;

/** If true, jumping on this pawn triggers ragdoll knockdown */
var bool bKnockdownWhenJumpedOn;

/** Cached health before taking damage for status effect resistance */
var transient int OldHealth;

/** Server-controlled disable of the gore mesh while alive */
var bool bDisableGoreMeshWhileAlive;

/** Whether or not to explode on death (set by server) */
var bool bUseExplosiveDeath;

/** Inflate on damage (LERP between none and full inflation based on health) */
var bool bUseDamageInflation;

/** Max damage inflation value */
var float ZeroHealthInflation;

/** Rate of inflation per second when inflating from damage, up to current intended */
var float DamageInflationRate;

/** Rate of deflation per second for damage inflation */
var float DamageDeflationRate;

/** Intended inflation. If a pawn is still inflating, this will be higher */
var float IntendedDamageInflationPercent;

/** Current inflation percent stored as float */
var float DamageInflationPercent;

/** Current replicated damage inflation */
var repnotify byte RepDamageInflateParam;

/** Gravity value to use on inflate death */
var float InflateDeathGravity;

/** Timer after death until inflation explosion */
var float InflationExplosionTimer;

/** Deflate value when affected by bleed */
var repnotify byte RepBleedInflateMatParam;

// Base emitter to use for incap effect
var const ParticleSystem BleedIncapFX;

// PSC attached to effected pawn when incap is in effect
var ParticleSystemComponent BleedIncapPSC;

/*********************************************************************************************
 * @name	Anim Tree Controls
********************************************************************************************* */

/* Plays panicked animation (e.g. On Fire, Poisoned) */
var bool bPlayPanicked;
/* Plays shambling animation (e.g. Headless, EMP) */
var bool bPlayShambling;

/** Cached anim nodes */
var KFAnim_RandomScripted WalkBlendList;
var KFAnim_Movement MovementAnimNode;

/*********************************************************************************************
 * @name	Special Abilities
********************************************************************************************* */


/** Struct containing block settings, used on a per-difficulty basis */
struct native sBlockInfo
{
	/** Chance of blocking an attack */
	var float Chance;
	/** Time from the start of a block until the zed unblocks again */
	var float Duration;
	/** Maximum number of attacks that can be blocked before the block is broken */
	var float MaxBlocks;
	/** Cooldown duration from the end of the last block */
	var float Cooldown;
	/** How much damage to accumulate (as a percentage of maximum health) before attempting to trigger a block */
	var float DamagedHealthPctToTrigger;
	/** How much to mitigate melee damage when blocking */
	var float MeleeDamageModifier;
	/** How much to mitigate non-melee damage when blocking */
	var float DamageModifier;
	/** How much to scale incap/affliction power by when blocking */
	var float AfflictionModifier;
	/** How much to multiply the chance by when in a solo game */
	var float SoloChanceMultiplier;

	structdefaultproperties
	{
		Chance=0.f
		MeleeDamageModifier=1.f
		DamageModifier=1.f
		AfflictionModifier=1.f
	}
};

var protected transient sBlockInfo DifficultyBlockSettings;

/** Minimum FOV angle attacks must fall in to be blocked */
var protected const float MinBlockFOV;

/** Whether this zed is blocking attacks */
var transient bool bIsBlocking;

/** Multiplier applied to sprint speed when blocking */
var protected const float BlockSprintSpeedModifier;

/** The last time a successful block ended */
var transient float LastBlockTime;

/** Multiplier applied to the vortex attraction force */
var protected float VortexAttracionModifier;

var				float	KnockedDownBySonicWaveOdds;
var 			bool 	bCloakOnMeleeEnd;
var				bool	bIsCloakingSpottedByLP;
var	repnotify	bool	bIsCloakingSpottedByTeam;
var				float	LastSpottedStatusUpdate;
/** The most recent controller that made the pawn visible for other players */
var 			KFPlayerController	LastStoredCC;
/** Rage flags */
var				bool 	bCanRage;
var repnotify	bool	bIsEnraged;

var	transient	bool	bRageAfterPanic;

/** Particle system component for player alpha rally effect */
var transient 	ParticleSystemComponent RallyPSC;

/** Particle system components attached to the hands when rallied */
var transient	ParticleSystemComponent RallyHandPSCs[2];

/** AI rally buff variables */
struct native sRallyInfo
{
	/** Whether this AI can rally in this difficulty */
	var bool bCanRally;
	/** Whether rally causes this AI to sprint */
	var bool bCauseSprint;
	/** How long the rally buff lasts for */
	var float RallyBuffTime;
	/** How much to modify incoming (taken) damage */
	var float TakenDamageModifier;
	/** How much to modify outgoing (dealt) damage */
	var float DealtDamageModifier;

	structdefaultproperties
	{
		bCanRally=true
		bCauseSprint=false
		RallyBuffTime=10.f
		TakenDamageModifier=1.f
		DealtDamageModifier=1.f
	}
};

var protected transient sRallyInfo DifficultyRallySettings;

/*********************************************************************************************
 * @name	Perks
********************************************************************************************* */

var private 	bool 	bIsStalkerClass;
var private		bool 	bIsCrawlerClass;
var private		bool 	bIsFleshpoundClass;
var private		bool 	bIsClotClass;
var private		bool 	bIsBloatClass;

/*********************************************************************************************
 * @name	Movement
********************************************************************************************* */

/** The difficulty adjusted original GroundSpeed for this character */
var transient float	NormalGroundSpeed;
/** The difficulty adjusted original SprintSpeed for this character */
var transient float	NormalSprintSpeed;
/** The random ground speed modifier that is applied whent this character is initialized */
var transient float	InitialGroundSpeedModifier;
/** Time interval for HiddenGroundSpeed check */
var	transient float	LastAISpeedCheckTime;
/** The last time this Zed was network relevant to someone, or had line of sight to someone */
var	transient float	LastLOSOrRelevantTime;
/** When true, will attempt to match player speed while in pursuit. Use only if you want to allow upperbody attacks while moving. */
var	bool		bMatchEnemySpeed;
/** Match enemy speed while in pursuit if enemy distance <= this value */
var	float		MatchEnemySpeedAtDistance;
/** Minimum speed of enemy required for me to begin matching speed */
var	float		MinimumEnemySpeedToMatch;
var	float		PursuitSpeedScale;
/** Scales distance threshold that enemy is considered reached */
var	float		ReachedEnemyThresholdScale;
/** Instead of scaling, will just use this value for reached checks, if value > 0 and using walking physics */
var	float		ReachedGoalThresh_Walking;
/** Instead of scaling, will just use this value for reached checks, if value > 0 and using spider physics */
var float		ReachedGoalThresh_Spider;
var	float		LastBumpTime;
/** Used as an optimization for zeds and limits how frequently NotifyBump will be called */
var float		BumpFrequency;
/** Set internally if pawn's collision size was modified at start of a jump */
var bool		bRestoreCollisionOnLand;

/** Damage type applied to destructible actors when bumped */
var class<KFDamageType> BumpDamageType;

/** Damagetype applied to human players when hitting them in mid-air */
var class<KFDamageType> JumpBumpDamageType;

/** Footstep shakes activated in footstep sound animnotify */
var protected float FootstepCameraShakeInnerRadius;
var protected float FootstepCameraShakeOuterRadius;
var CameraShake FootstepCameraShake;

/** A ground speed this pawn has been set to blend to */
var float DesiredAdjustedGroundSpeed;
/** A sprint speed this pawn has been set to blend to */
var float DesiredAdjustedSprintSpeed;
/** The rate to transition speeds when blending to new movement speeds */
var float SpeedAdjustTransitionRate;

var AkComponent SprintAkComponent;
var AkComponent HeadShotAkComponent;
var AkEvent StartSprintingSound;
var AkEvent SprintLoopingSound;
var AkEvent StopSprintingSound;

var bool bPlayingSprintLoop;

var bool bSprintOverride;

/*********************************************************************************************
 * @name	Dismemberment / Gore
********************************************************************************************* */

/** The explosion effect should only be played once */
var transient bool bPlayedExplosionEffect;

/** Information regardint the currently attached gore chunks */
struct native AttachedGoreChunkInfo
{
	var int AttachmentIndex;
	var StaticMeshComponent AttachedComponent;
};

/** The currently attached gore chunks */
var transient array<AttachedGoreChunkInfo> AttachedGoreChunks;

/** Keeps track of the number of head chunks removed for the ZED */
var transient int NumHeadChunksRemoved;

/** Keep track of the head bones that have already been broken */
var transient array<Name> BrokenHeadBones;

/** How often to check for napalm infections */
//var protected const float NapalmCheckInterval;

/** Last time we checked for a napalm infection upon taking damage */
var transient protected float LastNapalmInfectCheckTime;

/** Is there a chanced that we explode when we die? Set by the firebug's Zed shrapnel skill */
var bool bCouldTurnIntoShrapnel;

/** We explode into a toxic cloud when we die? Set by the field medic's Zed zedative skill */
var bool bCouldTurnIntoToxicExplosion;

/** Gameplay-facing disable of head destruction */
var bool bDisableHeadless;

var array<name> BonesToHidePostAsyncWork;
var array<name> BonesToShowPostAsyncWork;

/*********************************************************************************************
 * @name	Dialog
********************************************************************************************* */
var transient int		DeadHorseHitStreakAmt;
var transient float		LastDeadHorseHitTime;

/*********************************************************************************************
 * @name	Debug
********************************************************************************************* */

var bool				bDebug_DrawOverheadInfo;
var bool				bDebug_DrawSprintingOverheadInfo;
var const bool			bDebug_UseIconForShowingSprintingOverheadInfo;
var bool				bDebug_SpawnedThroughCheat;

/*********************************************************************************************
 * @name	Door Navigation
********************************************************************************************* */

var float			    DefaultCollisionRadius;

var KFTrigger_ChokePoint  CurrentChokePointTrigger;

var bool                bReducedZedOnZedPinchPointCollisionStateActive;
var const float			CollisionRadiusForReducedZedOnZedPinchPointCollisionState;

/*********************************************************************************************
 * @name	Spawning
********************************************************************************************* */

/** When spawning in a spawn volume, the squad type as to be at least this big (can be bigger
*   if there are other zeds in the spawn squad that are larger). */
var() ESquadType MinSpawnSquadSizeType;

/*********************************************************************************************
 * @name	Achievements
********************************************************************************************* */
var protected const int OnDeathAchievementID;
var protected bool bOnDeathAchivementbDisabled;

/*********************************************************************************************
* @name	Armor
********************************************************************************************* */

/** Armor component to handle armor damage and detachment. */
var class<KFZedArmorInfo> ArmorInfoClass;
var KFZedArmorInfo ArmorInfo;

//Byte array of armor percentages, replicated to clients
var repnotify byte RepArmorPct[3];

//Bit field for the status of the armor zones.  1 = attached
var repnotify byte ArmorZoneStatus;
var byte PreviousArmorZoneStatus;

//Hit FX overrides for hitting armor
var const int OverrideArmorFXIndex;

/*********************************************************************************************
 * @name	Parasite Weapon
********************************************************************************************* */
var array<KFProjectile> ParasiteSeeds;

// Max num of seeds in this character
var byte MaxNumSeeds;

/*********************************************************************************************
 * @name	Tiny skull Weakly vfx
********************************************************************************************* */

`define TINY_SKULL_MAX_WEAKPOINTS 10
var transient array<ParticleSystemComponent> WeakPointVFXComponents;
var repnotify WeakPoint WeakPoints_TS[`TINY_SKULL_MAX_WEAKPOINTS];
var ParticleSystem WeakPointParticleTemplate;

/*********************************************************************************************
 * @name	Delegates
********************************************************************************************* */

/** Declaration for attach/detach gore chunk delegates */
simulated delegate bool GoreChunkAttachmentCriteria();
simulated delegate bool GoreChunkDetachmentCriteria();

replication
{
	// Replicated to ALL
	if (bNetDirty)
		bIsHeadless, bIsPoisoned, bPlayPanicked, bPlayShambling, MaxHeadChunkGoreWhileAlive,
		RepInflateMatParams, RepInflateMatParam, RepDamageInflateParam, RepBleedInflateMatParam, bDisableGoreMeshWhileAlive,
        bDisableHeadless, InflateDeathGravity, InflationExplosionTimer, bUseDamageInflation, bUseExplosiveDeath, WeakPoints_TS;
	if ( bNetDirty && bCanCloak )
		bIsCloakingSpottedByTeam;
	if ( bNetDirty && bCanRage )
		bIsEnraged;
	if (Role == ROLE_Authority)
		ArmorZoneStatus, RepArmorPct;
}

cpptext
{
	// Actor
	INT* GetOptimizedRepList( BYTE* InDefault, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Channel );
	virtual void TickSpecial( FLOAT DeltaSeconds );
	virtual void TickAuthoritative( FLOAT DeltaSeconds );

	// AI / navigation
	virtual UBOOL IgnoreBlockingBy( const AActor *Other) const;
	virtual void NotifyBump( AActor *Other, UPrimitiveComponent* OtherComp, const FVector &HitNormal );
	virtual FLOAT MaxSpeedModifier();
	virtual void UpdateAISuperSpeed();
	virtual void UpdateAIPursuitSpeed();
	virtual UBOOL IsGlider();
	virtual UBOOL ReachThresholdTest( const FVector &TestPosition, const FVector &Dest, AActor* GoalActor, FLOAT UpThresholdAdjust, FLOAT DownThresholdAdjust, FLOAT ThresholdAdjust );
	virtual void HandleSerpentineMovement(FVector& out_Direction, FLOAT Distance, const FVector& Dest);
	virtual INT ModifyCostForReachSpec(UReachSpec* Spec, INT Cost);
	virtual void NotifyBumpLevel(AActor* Wall, const FVector &HitLocation, const FVector& HitNormal);
	virtual void OnRigidBodyCollision(const FRigidBodyCollisionInfo& MyInfo, const FRigidBodyCollisionInfo& OtherInfo, const FCollisionImpactData& RigidCollisionData);
	virtual UBOOL ShouldTrace(UPrimitiveComponent* Primitive,AActor *SourceActor, DWORD TraceFlags);
	virtual void physicsRotation(FLOAT deltaTime, FVector OldVelocity);
}

native function bool SpiderPhysicsWallAdjust( vector HitNormal, actor HitActor );
/** Tells the monster whether or not it should shrink its collision cylinder when going through a choke point */
native function SetChokePointCollision( bool bUseChokeCollision );
/** Checks if we are our current location encroaches any world geometry */
native function bool CheckEncroachingWorldGeometry();

native function float GetGravityZ();

/**
 * Check on various replicated data and act accordingly.
 */
simulated event ReplicatedEvent(name VarName)
{
	switch( VarName )
	{
	case nameof(bIsHeadless):
		StopAkEventsOnBone( 'head' );
        // No more auto aiming to this zed
        bCanBeAdheredTo=false;
        bCanBeFrictionedTo=false;
		break;

	case nameof(bIsPoisoned):
		AfflictionHandler.ToggleEffects(AF_Poison, bIsPoisoned);
		break;

	case nameof(RepInflateMatParams):
		KFAffliction_Microwave(AfflictionHandler.Afflictions[AF_Microwave]).bHasToSpawnFire = RepInflateMatParams.bHasToIgniteFlames;
		AfflictionHandler.UpdateMaterialParameter(AF_Microwave, GetCurrentInflation());
		break;

    case nameof(RepBleedInflateMatParam):
        AfflictionHandler.UpdateMaterialParameter(AF_Bleed, ByteToFloat(RepBleedInflateMatParam));
		UpdateBleedIncapFX();
        break;

	case nameof(Controller):
		// Set audio switch based on AI or player-controlled
		SetSwitch( 'Player_Zed', IsHumanControlled() ? 'Player' : 'NotPlayer' );
		break;

	case nameof(bEmpDisrupted):
		if( bEmpDisrupted )
		{
			// If this pawn was disrupted, put all of its moves on cooldown
			PutAllMovesOnCooldown();
		}
		break;

    case nameof(RepDamageInflateParam):
        HandleDamageInflation();
        break;

	case nameof(RepArmorPct):
		if(ArmorInfo != none)
		{
			ArmorInfo.UpdateArmorPieces();
		}
		break;

	case nameof(ArmorZoneStatus):
		if (ArmorInfo != none)
		{
			ArmorInfo.UpdateArmorPieces();
		}
		break;

	case nameof(bIsEnraged):
		SetEnraged(bIsEnraged);
		break;
	
	case nameof(WeakPoints_TS):
		SpawnWeakpointVFX();
		break;
	}

	super.ReplicatedEvent( VarName );
}

/*********************************************************************************************
 * @name	Static
********************************************************************************************* */

// returns the zed's score/dosh value
simulated static function int GetDoshValue()
{
	return default.DoshValue;
}

simulated static function float GetXPValue(byte Difficulty)
{
	return default.XPValues[Difficulty];
}

/** Gets the actual classes used for spawning. Can be overridden to replace this monster with another */
static event class<KFPawn_Monster> GetAIPawnClassToSpawn()
{
	local WorldInfo WI;

	WI = class'WorldInfo'.static.GetWorldInfo();
	if (default.ElitePawnClass.length > 0 && default.DifficultySettings != none && fRand() < default.DifficultySettings.static.GetSpecialSpawnChance(KFGameReplicationInfo(WI.GRI)))
	{
		return default.ElitePawnClass[Rand(default.ElitePawnClass.length)];
	}

	return default.class;
}

/** Load content archetype when map loads */
native static final function PreloadContent();
/** Called if preload was not called before 1st spawn */
native private function LastChanceLoad();

/*********************************************************************************************
 * @name	Constructors, Destructors, and Loading
********************************************************************************************* */

/** Called immediately before gameplay begins */
simulated event PreBeginPlay()
{
	local KFPawn_Monster KFPM;
	local bool bArchAlreadyLoaded;

	CheckShouldAlwaysBeRelevant(); //these guys could be alive already so this is unreliable

	DefaultCollisionRadius = CylinderComponent.default.CollisionRadius;

	Super.PreBeginPlay();

	// Check if the global data was initialized
	if( WorldInfo.NetMode != NM_DedicatedServer && ( WorldInfo.GRI == none || WorldInfo.GRI.GameClass == none ) )
	{
		`log("Preload global data not initialized");
		bArchAlreadyLoaded = false;
		foreach WorldInfo.AllPawns( class'KFPawn_Monster', KFPM )
		{
			if( KFPM != self && KFPM.class == class && KFPM.bArchLoaded )
			{
				`log("Archetype already loaded for class"@class);
				bArchAlreadyLoaded = true;
				bArchLoaded = true;
			}
		}

		if( !bArchAlreadyLoaded )
		{
			`log("Initializing first archetype for class"@class);
			LastChanceLoad();
			bArchLoaded = true;
		}
	}

	// If we don't have an archetype select one
	if ( CharacterArch == None )
	{
		// Preload should have been called already, but if not do it now!
		if ( CharacterMonsterArch == None )
		{
			LastChanceLoad();
		}

		if ( CharacterMonsterArch != None )
		{
			SetCharacterArch(CharacterMonsterArch);
		}
	}

	if ( CharacterArch == None )
	{
		`warn("Failed to find character info for KFMonsterPawn!");
		Destroy();
	}
	NormalGroundSpeed = default.GroundSpeed;
	NormalSprintSpeed = default.SprintSpeed;

	if (ArmorInfoClass != none)
	{
		ArmorInfo = new(self) ArmorInfoClass;
	}
}

simulated event CheckShouldAlwaysBeRelevant()
{
	local KFGameReplicationInfo KFGRI;

	// Set to always relevant if we're the last few remaining
	KFGRI = KFGameReplicationInfo( WorldInfo.GRI );
	if( KFGRI != none && KFGRI.AIRemaining <= class'KFGameInfo'.static.GetNumAlwaysRelevantZeds() )
	{
		bAlwaysRelevant = true;
	}
}

/** Called immediately after gameplay begins */
simulated event PostBeginPlay()
{
	local KFGameReplicationInfo KFGRI;

	super.PostBeginPlay();

	// Set our (Network: ALL) difficulty-based settings
	KFGRI = KFGameReplicationInfo( WorldInfo.GRI );
	if( KFGRI != none )
	{
		SetRallySettings( DifficultySettings.static.GetRallySettings(self, KFGRI) );
		SetZedTimeSpeedScale( DifficultySettings.static.GetZedTimeSpeedScale(self, KFGRI) );
	}

	if( (WorldInfo.NetMode != NM_Client) && IsABoss() )
	{
		`AnalyticsLog(("boss_spawn", None, Class.Name));
	}

	if (IsABoss())
	{
		class'KFPawn_MonsterBoss'.static.SetupHealthBar(self);
	}

	if (ArmorInfo != none)
	{
		ArmorInfo.InitArmor();
	}
}

simulated function SetMeshLightingChannels(LightingChannelContainer NewLightingChannels)
{
	local int i;

	super.SetMeshLightingChannels(NewLightingChannels);

	for (i = 0; i < StaticAttachList.Length; ++i)
	{
		if (StaticAttachList[i] != none)
		{
			StaticAttachList[i].SetLightingChannels(NewLightingChannels);
		}
	}
}

//update the portrait when we get a PRI
simulated function NotifyTeamChanged()
{
	if(CharacterArch != none)
	{
		CharacterArch.SetCharacterFromArch( self, KFPlayerReplicationInfo(PlayerReplicationInfo) );
	}
}

/** Called from Possessed event when this controller has taken control of a Pawn */
function PossessedBy( Controller C, bool bVehicleTransition )
{
	local string NPCName;
	local KFPlayerReplicationInfo KFPRI;
	local KFGameReplicationInfo KFGRI;

	Super.PossessedBy( C, bVehicleTransition );

	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);

	/** Set MyKFAIC for convenience to avoid casting */
	if( KFAIController(C) != none )
	{
		MyKFAIC = KFAIController( C );

		// If AI Zed has spawned during trader time, should be killed immediately.
		if (!(bDebug_SpawnedThroughCheat || WorldInfo.Game.GetStateName() == 'DebugSuspendWave') && KFGRI != none && !KFGRI.bWaveIsActive)
		{
			Suicide();
			return;
		}
	}

	bReducedZedOnZedPinchPointCollisionStateActive = false;
	//CollisionRadiusBeforeReducedZedOnZedPinchPointCollisionState = CollisionCylinderReducedPercentForSameTeamCollision;

	// Turn off air control for AI because it can mess up landing.
`if(`notdefined(ShippingPC))
	if( IsHumanControlled() || MyKFAIC.bIsSimulatedPlayerController )
`else
	if( IsHumanControlled() )
`endif
	{
		KFPRI = KFPlayerReplicationInfo(C.PlayerReplicationInfo);
		if(KFPRI != none)
		{
			KFPRI.PlayerHealth 	= Health;
			KFPRI.PlayerHealthPercent = FloatToByte( float(Health) / float(HealthMax) );
			SetCharacterArch(CharacterMonsterArch, true);
		}

		if( Role == ROLE_Authority )
		{
			LastAttackHumanWarningTime = WorldInfo.TimeSeconds;
		}
	}
	else
	{
		AirControl = AIAirControl;
	}

	KFGameInfo(WorldInfo.Game).SetMonsterDefaults( self );

	if( MyKFAIC != none && MyKFAIC.PlayerReplicationInfo != None )
	{
		NPCName = string(self);
		NPCName = Repl(NPCName,"KFPawn_Zed","",false);
		PlayerReplicationInfo.PlayerName = NPCName;
		MyKFAIC.PlayerReplicationInfo.PlayerName = NPCName;
	}

	// Set our (Network: Server) difficulty-based settings
	if( KFGRI != none )
	{
		SetBlockSettings( DifficultySettings.static.GetBlockSettings(self, KFGRI) );

		// Set any AI-specific difficulty settings
		if( MyKFAIC != none )
		{
			MyKFAIC.EvadeOnDamageSettings = DifficultySettings.static.GetEvadeOnDamageSettings( self, KFGRI );
		}
	}

	// Set audio switch based on AI or player-controlled
`if(`notdefined(ShippingPC))
	SetSwitch( 'Player_Zed', (IsHumanControlled() || (MyKFAIC != none && MyKFAIC.bIsSimulatedPlayerController)) ? 'Player' : 'NotPlayer' );
`else
	SetSwitch( 'Player_Zed', IsHumanControlled() ? 'Player' : 'NotPlayer' );
`endif
}

/*
simulated event FellOutOfWorld(class<DamageType> dmgType)
{
	local string Msg;

	`warn( self$" FELL OUT OF WORLD!" );
	if( Health > 0 )
	{
		msg = WorldInfo.TimeSeconds@self@GetFuncName()@"fell out of world! Current location:"@Location;
		if( MyKFAIC != None )
		{
			msg = msg@"Controller:"@MyKFAIC@"active command:"@MyKFAIC.GetActiveCommand();
			if( MyKFAIC.MoveTarget != none )
			{
				msg = msg@"MoveTarget:"@MyKFAIC.MoveTarget;
			}
		}
		`warn( msg );
	}
	super.FellOutOfWorld(dmgType);
}*/ //log spam

event BaseChange()
{
	if( IsAliveAndWell() && MyKFAIC != none )
	{
		if( MyKFAIC.NotifyBaseChange( Base, Floor ) )
		{
			return;
		}
	}

	super.BaseChange();
}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	Super.PostInitAnimTree(SkelComp);

	WalkBlendList = KFAnim_RandomScripted(SkelComp.FindAnimNode('WalkRandomList'));

	// Cache all AnimNodeSlots.
	foreach SkelComp.AllAnimNodes(class'KFAnim_Movement', MovementAnimNode)
	{
		break;
	}
}

/** Initialize GoreHealth (Server only) */
function ApplySpecialZoneHealthMod(float HealthMod)
{
    //Update head
	HitZones[HZI_HEAD].GoreHealth = default.HitZones[HZI_HEAD].GoreHealth * HealthMod;
    HitZones[HZI_HEAD].MaxGoreHealth = HitZones[HZI_HEAD].GoreHealth;
}

function SetShieldScale(float InScale)
{
	if (ArmorInfo != none)
	{
		ArmorInfo.SetShieldScale(InScale);
	}
}

/** Used by the Versus takeover code to determine if this zed can be taken over */
function bool CanTakeOver()
{
	local KFVersusNoTakeoverVolume KFNTV;

	if( bVersusZed || IsDoingSpecialMove() || IsHeadless() || !IsAliveAndWell() )
	{
		return false;
	}

	foreach TouchingActors( class'KFVersusNoTakeoverVolume', KFNTV )
	{
		return false;
	}

	return true;
}

simulated event Tick(float DeltaTime)
{
	super.Tick(DeltaTime);

	if (WorldInfo.NetMode != NM_DedicatedServer && IsAliveAndWell())
	{
		if (bIsSprinting && VSizeSQ(Velocity) > 40000.f)
		{
			if (!bPlayingSprintLoop)
			{
				if (StartSprintingSound != none && !SprintAkComponent.IsPlaying(StartSprintingSound))
				{
					SprintAkComponent.PlayEvent(StartSprintingSound, true, true);
				}
			}

			if(SprintLoopingSound != none && !SprintAkComponent.IsPlaying(SprintLoopingSound))
			{
				SprintAkComponent.PlayEvent(SprintLoopingSound, true, true);
				bPlayingSprintLoop = true;
			}
		}
		else if (bPlayingSprintLoop && (!bIsSprinting || VSizeSQ(Velocity) <= 40000.f))
		{
			if (SprintLoopingSound != none && SprintAkComponent.IsPlaying(SprintLoopingSound))
			{
				SprintAkComponent.StopEvents();
				bPlayingSprintLoop = false;
			}

			if (StopSprintingSound != none && !SprintAkComponent.IsPlaying(StopSprintingSound))
			{
				SprintAkComponent.PlayEvent(StopSprintingSound, true, true);
			}
		}
	}
}

/*********************************************************************************************
 * @name	Character Info Methods
********************************************************************************************* */

simulated function SetCharacterArch(KFCharacterInfoBase Info, optional bool bForce)
{
	super.SetCharacterArch(Info, bForce);
	PlayExtraVFX('AlwaysOn');
}

native function KFCharacterInfo_Monster GetCharacterMonsterInfo();

/** If true, assign custom player controlled skin when available */
simulated event bool UsePlayerControlledZedSkin()
{
	return bVersusZed;
}

/*********************************************************************************************
 * @name	Movement Methods
********************************************************************************************* */

function float GetBlockingSprintSpeedModifier()
{
	return BlockSprintSpeedModifier;
}

/** Set a desired movement speed adjustment that will blend in over time */
function AdjustMovementSpeed( float SpeedAdjust )
{
    DesiredAdjustedGroundSpeed = default.GroundSpeed * SpeedAdjust * InitialGroundSpeedModifier;

    if( IsDoingSpecialMove() )
    {
	    DesiredAdjustedSprintSpeed = fMax( default.SprintSpeed * SpeedAdjust * InitialGroundSpeedModifier * SpecialMoves[SpecialMove].GetSprintSpeedModifier(), DesiredAdjustedGroundSpeed );
	}
	else
	{
	    DesiredAdjustedSprintSpeed = fMax( default.SprintSpeed * SpeedAdjust * InitialGroundSpeedModifier, DesiredAdjustedGroundSpeed );
	}

	if (bPlayPanicked)
	{
		// Make sure groundspeed is in "walk" range so animtree can play correct panic anim
		DesiredAdjustedGroundSpeed = Min(DesiredAdjustedGroundSpeed, MovementAnimNode.Constraints[1]);
	}

    NormalGroundSpeed = DesiredAdjustedGroundSpeed;
	NormalSprintSpeed = DesiredAdjustedSprintSpeed;
}

/** Overridden to cause slight camera shakes when walking. */
simulated event PlayFootStepSound(int FootDown)
{
	if( WorldInfo.NetMode == NM_DedicatedServer )
	{
		return;
	}

	Super.PlayFootStepSound(FootDown);

	// The Zed has footstep notifies in one or more of his Idle anim sequences, where it kind of shuffles his foot as he shifts his weight.
	// Changed the IsDoingLatentMoveCheck() to a velocity check, so player-controlled zeds trigger camera shake as well.
	if( Physics == PHYS_Walking
		&& Base != none
		&& Mesh.RootMotionMode == RMM_Ignore
		&& FootstepCameraShake != none
		&& VSizeSQ(Velocity) >= 10000.f )
	{
		class'Camera'.static.PlayWorldCameraShake(FootstepCameraShake, self, Location, FootstepCameraShakeInnerRadius, FootstepCameraShakeOuterRadius, 1.3f, true);
	}
}

event SpiderBumpLevel( vector HitLocation, vector HitNormal, optional actor Wall );

simulated event Bump( Actor Other, PrimitiveComponent OtherComp, Vector HitNormal )
{
	Super.Bump( Other, OtherComp, HitNormal );

	if( SpecialMove != SM_None )
	{
		SpecialMoves[SpecialMove].NotifyBump( Other, HitNormal );
	}

	// Check for a midair bump
    if( Physics == Phys_Falling && JumpBumpDamageType != none && Other.GetTeamNum() != GetTeamNum() && VSizeSq2D(Velocity) > Square(GroundSpeed * 1.1) )
    {
		Other.TakeDamage( MeleeAttackHelper.BaseDamage,	Controller,	Other.Location,	Normal(Velocity), JumpBumpDamageType );
	}
}


/** Called from AICommand_MoveToGoal, notifies us that we've bumped another KFPawn */
function HandleMonsterBump( KFPawn_Monster Other, Vector HitNormal )
{
	local KFPlayerController KFPC;

	if( !Other.IsNapalmInfected() && CanNapalmInfect(KFPC) )
	{
		InfectWithNapalm( Other, KFPC );
	}
}

/** Override to handle special berserker functionality */
event HitWall( vector HitNormal, actor Wall, PrimitiveComponent WallComp )
{
    local KFDoorActor Door;

    if (IsHumanControlled())
    {
        if (!Wall.bStatic && IsAliveAndWell())
        {
            Door = KFDoorActor(Wall);
            if (Door != none)
            {
                TryDestroyDoor(Door);
            }
        }
    }

	`AILog_Ext( GetFuncName()$"() Wall: "$Wall, 'BumpEvent', MyKFAIC );
	// Call our special notification
	NotifyCollideWithActor(HitNormal, Wall);
	Super.HitWall(HitNormal, Wall, WallComp);
}

/** Allows pawn to handle door bump events instead of controller */
function bool HandleAIDoorBump(KFDoorActor Door)
{
    return TryDestroyDoor(Door);
}

/** Destroy unwelded doors instantly when there are few players remaining if I'm a boss */
function bool TryDestroyDoor(KFDoorActor Door)
{
    if (IsABoss() && Door != none && !Door.bIsDoorOpen && !Door.bIsDestroyed && Door.WeldIntegrity == 0 && CanObliterateDoors())
    {
        Door.IncrementHitCount(self);
        Door.DestroyDoor(Controller);
        return true;
    }

    return false;
}

/** Determines if this pawn can plow through doors */
function bool CanObliterateDoors()
{
    // We only want the kool-aid man effect if we're sprinting
    if (IsABoss() && !bIsSprinting)
    {
        return false;
    }

    // Only allow door obliteration if there is one player remaining in a multiplayer game
    return true;
}

/** Notification that Zed collided with an actor */
function bool NotifyCollideWithActor( Vector HitNormal, Actor Other )
{
	local KFDestructibleActor KFDA;

	if( !Other.bStatic && IsHumanControlled() )
	{
		KFDA = KFDestructibleActor( Other );
		if( KFDA != none )
		{
			HandleDestructibleBump( KFDA, HitNormal );
		}
	}

	`AILog_Ext( GetFuncName()$"() Other: "$Other, 'BumpEvent', MyKFAIC );
	return false;
}

function HandleDestructibleBump( KFDestructibleActor Destructible, vector HitNormal )
{
	Destructible.BumpedByMonster( self, HitNormal );
}

simulated event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
	if( MyKFAIC != none )
	{
		MyKFAIC.Touch( Other, OtherComp, HitLocation, HitNormal);
	}
	Super.Touch(Other, OtherComp, HitLocation, HitNormal);
}

function SetSprinting( bool bNewSprintStatus )
{
	if( MyKFAIC != none )
	{
		if( !MyKFAIC.CanSetSprinting(bNewSprintStatus) && !bSprintOverride)
		{
			return;
		}
	}

	// Disallow sprinting if blocking
	if( bIsBlocking && IsHumanControlled() )
	{
		if( bIsSprinting )
		{
			bNewSprintStatus = false;
		}
		else
		{
			return;
		}
	}

	super.SetSprinting(bNewSprintStatus);
}

/** Haven't seen this happen in a long time - logging it in case it does occur again */
event StuckOnPawn (Pawn OtherPawn)
{
	JumpOffPawn();
	if( MyKFAIC != none )
	{
		`AILog_Ext( self$" StuckOnPawn event at "$Location$" Base: "$Base,, MyKFAIC );
		MyKFAIC.DumpCommandStack();
		MyKFAIC.DumpCommandHistory();
	}
}

/** Monster jumped */
function bool DoJump( bool bUpdating )
{
    local vector JumpVelocity;
    local rotator ViewRotation;
    local vector ViewDirection;

    if (bCanJump)
    {
        if (IsHumanControlled())
        {
            if (IsDoingSpecialMove())
            {
                return false;
            }

            ViewRotation = GetViewRotation();
            ViewDirection = Normal(Vector(ViewRotation));

            if (bJumpCapable && !bIsCrouched && !bWantsToCrouch && (Physics == PHYS_Walking || Physics == PHYS_Ladder || Physics == PHYS_Spider))
            {
                if (Physics == PHYS_Spider)
                    `if(`__TW_PATHFINDING_)
                    Velocity = Velocity + (GetJumpZ() * Floor);
                `else
                    Velocity = GetJumpZ() * Floor;
                `endif
                else if (Physics == PHYS_Ladder)
                    Velocity.Z = 0;
                else if (bIsWalking)
                {
                    Velocity.Z = default.JumpZ;
                }
                else
                {
                    if (bIsSprinting && bHasExtraSprintJumpVelocity)
                    {
                        JumpVelocity = GetSprintJumpVelocity(ViewDirection);
                        JumpVelocity.Z = GetJumpZ();
                        Velocity += JumpVelocity;
                    }
                    else
                    {
                        Velocity.Z = GetJumpZ();
                    }
                }
                if (Base != None && !Base.bWorldGeometry && Base.Velocity.Z > 0.f)
                {
                    Velocity.Z += Base.Velocity.Z;
                }
                SetPhysics(PHYS_Falling);
                bJumped = true;
                return true;
            }
            return false;
        }
        else
        {
            return super.DoJump(bUpdating);
        }
    }
}

/** Returns the Z force used for a jump. Different move/physics states can return different values. */
simulated function float GetJumpZ()
{
	return JumpZ;
}

/** Returns the sprint jump velocity, used in modifying jump mechanics while sprinting */
simulated function vector GetSprintJumpVelocity( vector ViewDirection )
{
	return ViewDirection * GetJumpZ() * GetDirectionalJumpScale();
}

/** Determines how much a directional jump's velocity is scaled */
simulated function float GetDirectionalJumpScale()
{
	return 1.f;
}

/** Overridden to access specific bumping damage types like the fleshpounds enraged hit */
function class<KFDamageType> GetBumpAttackDamageType();

/** Overridden to prevent falling damage for Zeds */
function TakeFallingDamage()
{
}

event Landed( vector HitNormal, Actor FloorActor )
{
	local Controller StoredLastHitBy;
	local int SMIndex;

	StoredLastHitBy = LastHitBy;

	if( bRestoreCollisionOnLand )
	{
		bRestoreCollisionOnLand = false;
		SetCollisionSize( default.CylinderComponent.CollisionRadius, default.CylinderComponent.CollisionHeight );
		FitCollision();
	}

	if( IsHumanControlled() )
	{
		if( bJumped && IsLocallyControlled() )
		{
			SMIndex = SpecialMoveCooldowns.Find( 'SMHandle', SM_Jump );
			if( SMIndex != INDEX_NONE )
			{
				SpecialMoveCooldowns[SMIndex].LastUsedTime = WorldInfo.TimeSeconds;
			}
		}

		bJumped = false;
	}

	super.Landed( HitNormal, FloorActor );

	LastHitBy = StoredLastHitBy;
}

function SetMovementPhysics()
{
	// do not change when in special move - special move will reset when it's ready
	if( Physics == PHYS_None && IsDoingSpecialMove() )
         return;

    super.SetMovementPhysics();
}

/** Implements bKnockdownWhenJumpedOn */
function CrushedBy(Pawn OtherPawn)
{
	local KFGameInfo KFGI;
	local KFPlayerController_WeeklySurvival KFPC_WS;
	local KFPawn_Human KFPH;
	local KFPlayerController KFPC;
	local KFPlayerReplicationInfo KFPRI;

	KFPH = KFPawn_Human(OtherPawn);

	if (KFPH != none)
	{
		/*
		 * For summer season event, we wanto to know if we stomp a zed.
		 * Adding the notify here will prevent more network data.
		 * DmgType_Crushed is enough for it, no need to add the goompa.
		 */
		KFPC = KFPlayerController(KFPH.Controller);
		if (KFPC != none)
		{
			KFPC.NotifyHitGiven(class'DmgType_Crushed');
		}
		
		///

		KFGI = KFGameInfo(WorldInfo.Game);
		if (KFGI != none) // Only for players
		{
			if (KFGI.OutbreakEvent.ActiveEvent.bGoompaJumpEnabled)
			{
				OtherPawn.Velocity = OtherPawn.Velocity * vect(1,1,0);
				OtherPawn.AddVelocity( vect(0,0,1) * KFGI.OutbreakEvent.ActiveEvent.GoompaJumpImpulse, Instigator.Location, none);
				TakeDamage( KFGI.OutbreakEvent.ActiveEvent.GoompaJumpDamage, OtherPawn.Controller,Location, vect(0,0,0) , class'KFDT_GoompaStomp');

				KFPC_WS = KFPlayerController_WeeklySurvival(OtherPawn.Controller);
				if(KFPC_WS != none)
				{
					KFPC_WS.UpdateGoompaStreak();
				}

				// Registering awards information.
				`RecordAARIntStat(KFPC, STOMP_GIVEN, 1);
				KFPRI = KFPlayerReplicationInfo(KFPC.PlayerReplicationInfo);
				if (KFPRI != none)
				{
					KFPRI.ZedStomps++;
				}

				return;
			}
		}
	}
	

	Super.CrushedBy(OtherPawn);

	if ( bKnockdownWhenJumpedOn
		// Still alive after crush damage
		&& Health > 0
		// Not emerging
		&& !IsDoingSpecialMove(SM_Emerge)
		// Actually above and not a side-swipe
		&& ((OtherPawn.Location.Z - Location.Z) > (OtherPawn.CylinderComponent.CollisionHeight + CylinderCOmponent.CollisionHeight))
		// Opposing team; player only
		&& !IsHumanControlled()
		&& GetTeamNum() != OtherPawn.GetTeamNum()
		)
	{
		HandleAfflictionsOnHit(OtherPawn.Controller, vect(1,1,1), class'KFDT_Knockdown', OtherPawn);
	}
}

/** Sets the speed scale this zed will use in zed time */
simulated function SetZedTimeSpeedScale( float SpeedScale )
{
	if( SpeedScale > 0.f )
	{
		bMovesFastInZedTime = true;
		ZedTimeSpeedScale = SpeedScale;
	}
	else
	{
		bMovesFastInZedTime = false;
	}
}

/*********************************************************************************************
 * @name	Combat Methods
********************************************************************************************* */

/** Override to handle cloaking */
native function bool IsValidEnemyTargetFor(const PlayerReplicationInfo PRI, bool bNoPRIisEnemy);

/** Is test location within charge range? */
native function bool InChargeRange( const Vector TestLocation );
/** Is test location within melee range? */
native function bool InMeleeRange( const Vector TestLocation, optional name AttackTag );
native function bool InAttackTagRange( const name AttackTag, const Vector TestLocation );
native function bool InAnyAttackTagRange( const Vector TestLocation, out name outAttackTag );
/** SERVER ONLY: Gets current enemy, to avoid having to get it from the controller */
native function KFPawn GetEnemy();
/** Checks to see if area between CheckLocation and pawn is clear for combat */
native final function bool IsLocationValidForCombat( KFPawn CheckPawn, const vector CheckLocation );

/** Used by subclass to implement rage mode */
simulated function bool SetEnraged(bool bNewEnraged)
{
	if (!bCanRage)
	{
		return false;
	}

	if (Role == ROLE_Authority)
	{
		if (bNewEnraged == bIsEnraged)
		{
			return false;
		}

		if (bNewEnraged && ShouldBeWandering())
		{
			bRageAfterPanic = true;
			return false;
		}

		bIsEnraged = bNewEnraged;

		// End blocking on rage
		if (IsDoingSpecialMove(SM_Block))
		{
			EndSpecialMove();
		}

		// Sprint right away if we're AI
		if (!IsHumanControlled())
		{
			SetSprinting(bNewEnraged);
		}
	}

	if (WorldInfo.NetMode != NM_DedicatedServer && !IsHumanControlled())
	{
		if (bNewEnraged)
		{
			PlayExtraVFX('Enraged');
		}
		else
		{
			StopExtraVFX('Enraged');
		}
	}

	return true;
}

/** Used by subclass to check rage mode */
simulated event bool IsEnraged();

/** Notify the AI controller that we've taken damage from a friendly */
function NotifyFriendlyAIDamageTaken( Controller DamagerController, int Damage, Actor DamageCauser, class<KFDamageType> DamageType )
{
    if( MyKFAIC != none )
    {
    	MyKFAIC.NotifyFriendlyAIDamageTaken( DamagerController, Damage, DamageCauser, DamageType );
    }
}

/** Notification called from Pawn animation, by KFAnimNotify_MeleeImpact.
 *  Network: Server Only
 */
simulated function MeleeImpactNotify(KFAnimNotify_MeleeImpact Notify)
{
	if ( MeleeAttackHelper != None )
	{
		MeleeAttackHelper.bHasAlreadyHit = false; // reset attack
		MeleeAttackHelper.MeleeImpactNotify(Notify);
	}

	// check to see if our enemy was killed
	if ( MyKFAIC != none && MyKFAIC.Enemy != None && MyKFAIC.Enemy.Health <= 0 )
	{
		ClearHeadTrackTarget(Controller.Enemy);
		// TODO: Below command aborts could be problematic, but this code is pretty old- keep an eye on it
		MyKFAIC.AbortCommand( None, class'AICommand_Attack_Grab' );
		MyKFAIC.AbortCommand( None, class'AICommand_Attack_Melee' );
		// Start up a taunt kill special move (used when enemy killed, as opposed to regular taunts)
		class'AICommand_TauntEnemy'.static.Taunt( KFAIController( Controller ),, TAUNT_EnemyKilled );
	}
}

/** Called from MeleeHelper when damage is done to another pawn */
function NotifyMeleeDamageDealt();

/** Am I within range to perform an attack in the AttackTag category? (see PawnAnimInfo) */
event bool IsInAttackTagRange( vector TestLocation, name AttackTag )
{
	local vector2D MinMaxRange;
	local float DistSq;

	if( MyKFAIC == none || PawnAnimInfo == none )
	{
		MinMaxRange = PawnAnimInfo.GetAttackRangeByName( AttackTag );
		DistSq = VSizeSq( TestLocation - Location );

		if( (DistSq > (MinMaxRange.X * MinMaxRange.X)) && (DistSq < (MinMaxRange.Y * MinMaxRange.Y)) )
		{
			return true;
		}
	}
	return false;
}

/** Am I within range to perform any attack in my PawnAnimInfo?  */
event bool IsInAnyAttackTagRange( vector TestLocation, out name outAttackTag )
{
	local int idx;

	if( MyKFAIC == none || PawnAnimInfo == none )
	{
		outAttackTag = '';
		return false;
	}

	for( idx = 0; idx < PawnAnimInfo.Attacks.Length; idx++ )
	{
		if( PawnAnimInfo.Attacks[idx].Tag == '' || PawnAnimInfo.Attacks[idx].Chance <= 0.f )
		{
			continue;
		}
		if( IsInAttackTagRange(TestLocation, PawnAnimInfo.Attacks[idx].Tag) )
		{
			outAttackTag = PawnAnimInfo.Attacks[idx].Tag;
			return true;
		}
	}

	outAttackTag = '';
	return false;
}

/**
 * Network: Local Player
 *
 * @param	FireModeNum		fire mode number
 */
simulated function StartPlayerZedMove(ESpecialMove Move)
{
    local byte SMFlags;

	if( Move != SM_None )
	{
		// Make sure attack is off cooldown
		if( GetSpecialMoveCooldownTimeRemaining(Move) > 0.f )
		{
			return;
		}

		// Tell our currently-running special move to retrigger the button press if it was released mid-move
		if( SpecialMove == Move )
		{
			SpecialMoves[SpecialMove].SpecialMoveButtonRetriggered();
		}
	    else if( CanDoSpecialMove(Move) )
	    {
	    	SMFlags = SpecialMoveHandler.SpecialMoveClasses[Move].static.PackFlagsBase(self);
			DoSpecialMove(Move, true, InteractionPawn, SMFlags);
			if ( Role < ROLE_Authority && IsDoingSpecialMove(Move) )
			{
				ServerDoSpecialMove(Move, true, InteractionPawn, SMFlags);
			}
		}
	}
}

/**
 * Network: Local Player
 *
 * @param	FireModeNum		fire mode number
 */
simulated function StopPlayerZedMove(ESpecialMove Move)
{
	if( !IsDoingSpecialMove() )
	{
		return;
	}

    // notify move that button has been released (for held moves)
	if( SpecialMove == Move )
	{
		SpecialMoves[Move].SpecialMoveButtonReleased();
	}
}

/** Called from KFSpecialMove::SpecialMoveEnded */
simulated function NotifySpecialMoveEnded( KFSpecialMove FinishedMove, ESpecialMove SMHandle )
{
	local int SMIndex;

	if( IsHumanControlled() && IsLocallyControlled() )
	{
		SMIndex = SpecialMoveCooldowns.Find( 'SMHandle', SMHandle );
		if( SMIndex != INDEX_NONE )
		{
			SpecialMoveCooldowns[SMIndex].LastUsedTime = WorldInfo.TimeSeconds;
		}
	}
}

/** Returns cooldown time of a special move */
function float GetSpecialMoveCooldownPercent( const out SpecialMoveCooldownInfo Cooldown )
{
	local float CDTime;

	if( Cooldown.SMHandle != SM_None)
	{
		if( Cooldown.LastUsedTime > 0.f && Cooldown.CooldownTime > 0.f )
		{
			CDTime = (!bEmpDisrupted) ? Cooldown.CooldownTime : AfflictionHandler.GetAfflictionDuration(AF_EMP);
			return fClamp( (WorldInfo.TimeSeconds - Cooldown.LastUsedTime) / CDTime, 0.f, 1.f );
		}
	}

	return 1.f;
}

/** Returns amount of time remaining in cooldown */
function float GetSpecialMoveCooldownTimeRemaining( ESpecialMove SMHandle )
{
	local float CDTime;
	local int i;

	i = SpecialMoveCooldowns.Find( 'SMHandle', SMHandle );
	if( i != INDEX_NONE )
	{
		if( SpecialMoveCooldowns[i].LastUsedTime > 0.f && SpecialMoveCooldowns[i].CooldownTime > 0.f )
		{
			CDTime = (!bEmpDisrupted) ? SpecialMoveCooldowns[i].CooldownTime : AfflictionHandler.GetAfflictionDuration(AF_EMP);
			return CDTime - fMin( WorldInfo.TimeSeconds - SpecialMoveCooldowns[i].LastUsedTime, CDTime );
		}

		// if 1st use or no cooldown set return 0 remaining time
		return 0.f;
	}

	return 100.f; // invalid move
}

/** Allows access to the cooldowns array without being able to modify it */
simulated function array<SpecialMoveCooldownInfo> GetSpecialMoveCooldowns()
{
	return SpecialMoveCooldowns;
}

/** Puts all moves on this pawn on cooldown */
function PutAllMovesOnCooldown()
{
	local int i;

	if( IsHumanControlled() && IsLocallyControlled() )
	{
		for( i = 0; i < SpecialMoveCooldowns.Length; ++i )
		{
			if( SpecialMoveCooldowns[i].SMHandle != SM_None )
			{
				SpecialMoveCooldowns[i].LastUsedTime = WorldInfo.TimeSeconds;
			}
		}
	}
}

/** Returns TRUE if we should use adjusted controller sensitivity */
simulated function bool UseAdjustedControllerSensitivity();

/** Returns TRUE if this zed can block attacks */
function bool CanBlock()
{
	// Make sure this zed is allowed to block first
	if( Physics == PHYS_Walking
			&& CanDoSpecialMove(SM_Block)
			&& IsCombatCapable() )
	{
		// Check chance
		if( fRand() > DifficultyBlockSettings.Chance * (WorldInfo.Game.NumPlayers == 1 ? DifficultyBlockSettings.SoloChanceMultiplier : 1.f) )
		{
			return false;
		}

		// Return cooldown status
		return `TimeSince(LastBlockTime) >= DifficultyBlockSettings.Cooldown;
	}

	return false;
}

/** Returns the block settings for the current difficulty */
simulated function SetBlockSettings( const sBlockInfo NewBlockSettings )
{
	DifficultyBlockSettings = NewBlockSettings;
}

/** Returns the block settings for the current difficulty */
simulated function sBlockInfo GetBlockSettings()
{
	return DifficultyBlockSettings;
}

/** Returns the minimum field of view required to detect a block */
simulated function float GetMinBlockFOV()
{
	return MinBlockFOV;
}

/** Reduce affliction power when blocking */
simulated function AdjustAffliction( out float AfflictionPower )
{
	if( Role == ROLE_Authority && bIsBlocking )
	{
		AfflictionPower *= DifficultyBlockSettings.AfflictionModifier;
	}

	super.AdjustAffliction( AfflictionPower );
}

/** Used by subclasses to determine if the boss icon can be rendered */
function bool ShouldDrawBossIcon()
{
    return false;
}

/*********************************************************************************************
 * @name	Damage/Death Methods
********************************************************************************************* */

/*
 * PlayDying() is called upon death
 * Network: ALL
 */
simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
    local KFPlayerController KFPC;
    local string ClassName;
	local ParticleSystemComponent WeakPointPSC;

	Timer_EndRallyBoost();

	super.PlayDying(DamageType, HitLoc);

    //Shared functionality for boss death
    if (IsABoss() && KFGameReplicationInfo(WorldInfo.GRI).ShouldSetBossCamOnBossDeath())
    {
        KFPC = KFPlayerController(GetALocalPlayerController());
        if(KFPC != none)
        {
            KFPC.SetBossCamera( self );
        }

        //@HSL_BEGIN - JRO - 5/17/2016 - PS4 Activity Feeds
        ClassName = string(Class.Name);
        ClassName -= '_Versus';
        class'GameEngine'.static.GetOnlineSubsystem().PlayerInterfaceEx.PostActivityFeedBossKill(GetLocalizedName(), ClassName, WorldInfo.GetMapName(true));
        //@HSL_END
    }

    if (bUseExplosiveDeath)
    {
        PlayExplosiveDeath();
    }

    if (bUseDamageInflation)
    {
        PlayInflationDeath();
    }

	UpdateBleedIncapFX();

	StopExtraVFX(`NAME_NONE);

	if (WeakPointVFXComponents.Length > 0)
	{
		foreach WeakPointVFXComponents(WeakPointPSC)
		{
			WeakPointPSC.DeactivateSystem();
		}

		WeakPointVFXComponents.Length = 0;
	}
}

simulated function PlayInflationDeath()
{
    local int Idx;

    for (Idx = 0; Idx < Mesh.PhysicsAssetInstance.Bodies.Length; ++Idx)
    {
        Mesh.PhysicsAssetInstance.Bodies[Idx].CustomGravityFactor = InflateDeathGravity;

        if (InflationExplosionTimer > 0)
        {
            SetTimer(InflationExplosionTimer, false, 'InflationExplode');
        }
    }
}

simulated function PlayExplosiveDeath()
{
    local KFGoreManager GoreManager;

    GoreManager = KFGoreManager(WorldInfo.MyGoreEffectManager);
    if (GoreManager != none && GoreManager.AllowMutilation())
    {
        HandlePartialGoreAndGibs(class'KFDT_Explosive_Sacrifice', Location, vect(0, 0, 0), 'hips', true);
        GoreManager.SpawnObliterationBloodEffect(self);
    }
    else
    {
        HandlePartialGoreAndGibs(class'KFDT_Explosive_Sacrifice', Location, vect(0, 0, 0), 'hips', false);
    }
}

simulated function InflationExplode()
{
    local int Idx;

    RepDamageInflateParam = 0.f;
    bUseDamageInflation = false;

    for (Idx = 0; Idx < Mesh.PhysicsAssetInstance.Bodies.Length; ++Idx)
    {
        Mesh.PhysicsAssetInstance.Bodies[Idx].CustomGravityFactor = 1.0;
    }

    PlayExplosiveDeath();

    if ( WorldInfo.NetMode != NM_DedicatedServer )
    {
		UpdateVisualInflation(GetCurrentInflation() * 2.0);
    }
}

State Dying
{
    event OnSleepRBPhysics()
    {
        local int i;

        // Shrink shadow cull distance when dead. We don't do this for characters because they
        // have extra cosmetics and custom head components. Must reattach component so render data gets updated.
		Mesh.PerObjectShadowCullDistance *= 0.6;
		ReattachComponent(Mesh);

        //Reattach monster PACs
        for (i = 0; i < `MAX_COSMETIC_ATTACHMENTS; ++i)
        {
            if (ThirdPersonAttachments[i] != None)
            {
                ThirdPersonAttachments[i].PerObjectShadowCullDistance *= 0.6;
                ReattachComponent(ThirdPersonAttachments[i]);
            }
        }

        Super.OnSleepRBPhysics();
    }
	event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
	{
		local KFPawn_Human KFPH;
		super.TakeDamage( Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitInfo, DamageCauser );

		if( InstigatedBy != none && InstigatedBy.Pawn != none )
		{
			// beat dead horse
			KFPH = KFPawn_Human( InstigatedBy.Pawn );
			if( KFPH != none )
			{
				`DialogManager.PlayBeatDeadHorseDialog( KFPH, self );
			}
		}
	}

	simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
	{
		local PlayerController PC;
		local matrix HeadMatrix;
		local vector HeadLoc;
		//local rotator HeadRot;

		PC = GetALocalPlayerController();

		if( PC != none && !PC.IsSpectating() && PC.ViewTarget == self )
		{
			HeadMatrix = Mesh.GetBoneMatrix( Mesh.MatchRefBone('head') );
			HeadLoc = MatrixGetOrigin( HeadMatrix );
			//HeadMatrix = MakeRotationMatrix( rot(0, -16383, 16383) ) * HeadMatrix;
			//HeadRot = MatrixGetRotator( HeadMatrix );
			//DrawDebugLine(HeadLoc, HeadLoc + 100*vector(HeadRot), 0, 255, 0);

			//out_CamLoc = VInterpTo( out_CamLoc, HeadLoc, fDeltaTime, 10.0 );
			out_CamRot = RInterpTo( out_CamRot, rotator(HeadLoc - out_CamLoc), fDeltaTime, 10.0 );

			return true;
		}

		return Global.CalcCamera( fDeltaTime, out_CamLoc, out_CamRot, out_FOV );
	}
};

/**
 * Don't allow headshots to be counted for any purpose if we were headless before entering the takedamage state
 * NOTE: This addresses an issue with low gore where the head is not hidden after a headless event, allowing headshots
 * to count when they shouldn't.
 */
function bool CanCountHeadshots()
{
	return !bIsHeadless;
}

event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	local KFPawn_Human HumanInstigator;
	local KFAIController_Monster AIMonster;
	local class<KFDamageType> KFDT;
	local KFPlayerController KFPC;
	local KFPerk InstigatorPerk;
	local KfPlayerReplicationInfo KFPRI;
	local KFAIController KFAIC;
	local KFPawn_Monster KFPM;
	local float NapalmCheckDist;

	AIMonster = KFAIController_Monster(InstigatedBy);
	KFDT = class<KFDamageType>(DamageType);
	KFPC = KFPlayerController(InstigatedBy);
	if( KFPC != none )
	{
		InstigatorPerk = KFPC.GetPerk();

		KFAIC = KFAIController(Controller);

		if( KFAIC != none && KFAIC.TimeFirstSawPlayer == 0 )
		{
            // If we took damage, count that as "seeing a player" for our purposes
            KFAIC.TimeFirstSawPlayer = Worldinfo.TimeSeconds;
        }
	}

	if( AIMonster != none && KFDT != none && !KFDT.default.bIgnoreZedOnZedScaling )
	{
		// Deal extra damage to other zeds if we have over 100 health
		if( Health >= 100 )
		{
			Damage *= ( 2 - (HealthMax - Health ) / HealthMax );
		}
	}

	if( Damage > 0 && InstigatorPerk != none && KFDT != none )
	{
		bCouldTurnIntoShrapnel = InstigatorPerk.CouldBeZedShrapnel( KFDT );
		bCouldTurnIntoToxicExplosion = InstigatorPerk.CouldBeZedToxicCloud( KFDT );
	}

	super.TakeDamage( Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitInfo, DamageCauser );

	if( InstigatedBy != none && InstigatedBy.Pawn != none )
	{
		HumanInstigator = KFPawn_Human( InstigatedBy.Pawn );
		if( HumanInstigator != none )
		{
			HumanInstigator.ResetIdleStartTime();
		}
	}

	if( Damage > 0
		&& InstigatedBy != none
		&& DamageCauser != none
		&& KFDT != none
		&& KFDT.default.DoT_Type == DOT_Fire
		&& KFDT != class'KFDT_Fire_Napalm'
		&& WorldInfo.RealTimeSeconds - LastNapalmInfectCheckTime > 0.25f )
	{
		if( KFPC != none
			&& KFPC.GetPerk() != none
			&& KFPC.GetPerk().CanSpreadNapalm()
			&& class'KFPerk'.static.IsDamageTypeOnThisPerk(KFDT, class'KFPerk_Firebug') )
		{
			NapalmCheckDist = Square( CylinderComponent.CollisionRadius * class'KFPerk_Firebug'.static.GetNapalmCheckCollisionScale() );
			foreach WorldInfo.AllPawns( class'KFPawn_Monster', KFPM, Location )
			{
				if( KFPM != self && KFPM.IsAliveAndWell() && !KFPM.IsNapalmInfected() )
				{
					if( VSizeSQ(Location - KFPM.Location) > NapalmCheckDist )
					{
						continue;
					}

					InfectWithNapalm( KFPM, KFPC );
				}
			}

			LastNapalmInfectCheckTime = WorldInfo.RealTimeSeconds;

			// Make sure we're infected
			if( !IsNapalmInfected() )
			{
				InfectWithNapalm( self, KFPC );
			}
		}
	}

	KFPRI = KFPlayerReplicationInfo( PlayerReplicationInfo );
	if( KFPRI != none )
	{
		KFPRI.PlayerHealth = Health;
		KFPRI.PlayerHealthPercent = FloatToByte( float(Health) / float(HealthMax) );
	}

    if (bUseDamageInflation)
    {
        IntendedDamageInflationPercent = float(Health) / float(HealthMax);
    }
}

function AdjustDamageForArmor(out int InDamage, Controller InstigatedBy, class<DamageType> DamageType,
	TraceHitInfo HitInfo, Actor DamageCauser)
{
	local vector DamageSource;

	// Let armor handle the full, unadjusted damage first
	if (ArmorInfo != none)
	{
		//If the damage doesn't have a bone hit source, it's likely AoE.  Split over all remaining armor evenly.
		if (HitInfo.BoneName != '')
		{
			if (InstigatedBy != none && InstigatedBy.Pawn != none)
			{
				DamageSource = InstigatedBy.Pawn.Location;
			}
			else if (KFWeapon(DamageCauser) != none)
			{
				DamageSource = KFWeapon(DamageCauser).GetMuzzleLoc();
			}
			else
			{
				DamageSource = DamageCauser.Location;
			}

			ArmorInfo.AdjustBoneDamage(InDamage, HitInfo.BoneName, DamageSource, DamageType);
		}
		else
		{
			ArmorInfo.AdjustNonBoneDamage(InDamage, DamageType);
		}

		`log(self @ GetFuncName() @ " After armor adjustment Damage=" $ InDamage @ "Zone=" $ HitInfo.BoneName @ "DamageType=" $ DamageType, bLogTakeDamage);
	}
}

function AdjustDamageForInstigator(out int InDamage, Controller InstigatedBy, class<DamageType> DamageType, Actor DamageCauser, int HitZoneIdx)
{
	local KFPlayerController KFPC;
	local KFPawn_Human KFPH;
	local KFPerk InstigatorPerk;
	local KFPowerUp InstigatorPowerUp;
	local KFGameInfo KFGI;
	local float TempDamage;

	// Let the instigator's perk adjust the damage
	KFPC = KFPlayerController(InstigatedBy);
	if (KFPC != none)
	{
		InstigatorPerk = KFPC.GetPerk();
		if (InstigatorPerk != none)
		{
			InstigatorPerk.ModifyDamageGiven(InDamage, DamageCauser, self, KFPC, class<KFDamageType>(DamageType), HitZoneIdx);
		}
		
		InstigatorPowerUp = KFPC.GetPowerUp();
		if(InstigatorPowerUp != none)
		{
			InstigatorPowerUp.ModifyDamageGiven(InDamage, DamageCauser, self, KFPC, class<KFDamageType>(DamageType), HitZoneIdx);
		}

		KFGI = KFGameInfo(WorldInfo.Game);
		if(KFGI != none && KFGI.OutbreakEvent != none)
		{
			KFGI.ModifyDamageGiven(InDamage, DamageCauser, self, KFPC, class<KFDamageType>(DamageType), HitZoneIdx);
		}

		if( KFPC.Pawn != none )
		{
			KFPH = KFPawn_Human(KFPC.Pawn);
			if( KFPH != none )
			{
				TempDamage = InDamage;
				TempDamage *= KFPH.GetHealingDamageBoostModifier();
				InDamage = FCeil( TempDamage );
			}
		}
	}
}

/** Disable falling damage, apply blocking modifier */
function AdjustDamage(out int InDamage, out vector Momentum, Controller InstigatedBy, vector HitLocation, class<DamageType> DamageType, TraceHitInfo HitInfo, Actor DamageCauser)
{
	local int HitZoneIdx;
	local int ExtraHeadDamage;
	local class<KFDamageType> KFDT;

	// Cached hit params
	HitZoneIdx = HitZones.Find('ZoneName', HitInfo.BoneName);

	AdjustDamageForInstigator(InDamage, InstigatedBy, DamageType, DamageCauser, HitZoneIdx);

	AdjustDamageForArmor(InDamage, InstigatedBy, DamageType, HitInfo, DamageCauser);

	Super.AdjustDamage(InDamage, Momentum, InstigatedBy, HitLocation, DamageType, HitInfo, DamageCauser);

	if( DamageType.default.bCausedByWorld && ClassIsChildOf(DamageType, class'KFDT_Falling') )
	{
		InDamage = 0;
		return;
	}

	// start with damage type resistance/vulnerability
	InDamage *= GetDamageTypeModifier(DamageType);

	// Applies rally damage resistance
	GetRallyBoostResistance( InDamage );

	// Apply blocking modifier
	ApplyBlockingDamageModifier( InDamage, InstigatedBy, DamageType );

	// NVCHANGE_BEGIN - RLS - Debugging Effects
	if( WorldInfo.Game != none && KFGameInfo(WorldInfo.Game).bNVAlwaysHeadshot )
	{
		HitZoneIdx = HZI_HEAD;
	}
	// NVCHANGE_BEGIN - RLS - Debugging Effects

	// Do extra damage on blowing the head off
	if( !bCheckingExtraHeadDamage && HitZoneIdx == HZI_Head &&
        HitZones[HZI_Head].GoreHealth > 0 && InDamage > HitZones[HZI_Head].GoreHealth )
	{
        KFDT = class<KFDamageType>(DamageType);

		// For certain weapons do even more damage on blowing the head off
        if( KFDT != none )
        {
            InDamage *= KFDT.default.HeadDestructionDamageScale;
        }

        ExtraHeadDamage = InDamage + HealthMax * 0.25;

        bCheckingExtraHeadDamage = true;
        AdjustDamage( ExtraHeadDamage, Momentum, InstigatedBy, HitLocation, DamageType, HitInfo, DamageCauser );
        bCheckingExtraHeadDamage = false;

        InDamage += ExtraHeadDamage;
	}

	// register damage to divide up money/XP/Score.  This is done here instead of NotifyTakeHit,
	// so that it's called on the killing blow
	if( !bCheckingExtraHeadDamage && InstigatedBy != none )
	{
		AddTakenDamage( InstigatedBy, FMin(Health, InDamage), DamageCauser, class<KFDamageType>(DamageType) );
	}

	// If the head has been dismembered reduce damage to 1 (non-zero so play hit is called).
	// Since zed is bleeding out already this is not as big of a issue.
	if ( HitZoneIdx == HZI_HEAD && bIsHeadless )
	{
		InDamage = 1;
	}

	// Never allow damage to reach zero if coming from opposing team
	if( InstigatedBy == none || InstigatedBy.GetTeamNum() != GetTeamNum() )
	{
		InDamage = Max( InDamage, 1 );
	}

	`log(self @ "Adjusted Monster Damage=" $ InDamage, bLogTakeDamage);
}

/** Returns damage multiplier for an incoming damage type @todo: c++?*/
function float GetDamageTypeModifier(class<DamageType> DT)
{
	local int i;
	local int DifficultyIdx;
	local float DamageModifier;

	if ( LiveDamageTypeModifiers.Length > 0 )
	{
		AppendLiveDamageTypeModifiers();
	}

	// reverse iteration so that most specific damage type can be last on the array
	for (i = DamageTypeModifiers.Length - 1; i >= 0; --i)
	{
		if ( ClassIsChildOf(DT, DamageTypeModifiers[i].DamageType) )
		{
			// If specified assign difficulty based value
			if ( WorldInfo.Game != None && DamageTypeModifiers[i].DamageScale.Length > 1 )
			{
				DifficultyIdx = Min(WorldInfo.Game.GetModifiedGameDifficulty(), DamageTypeModifiers[i].DamageScale.Length);
				DamageModifier = DamageTypeModifiers[i].DamageScale[DifficultyIdx];
			}
			else
			{
				DamageModifier = DamageTypeModifiers[i].DamageScale[0];
			}

			// for resistances only, allow game info to modify (e.g. num players)
			if ( DamageModifier < 1.f )
			{
				DamageModifier = FMax(Lerp(1.f, DamageModifier, GameResistancePct),  0.f);
			}

			`log(self@"Scaling damage taken from"@DT@"by"@DamageModifier, bLogTakeDamage);
			return DamageModifier;
		}
	}

	return 1.f;
}

/** Append (one-time) damage type modifiers from the live balance into the damage modifiers array */
function AppendLiveDamageTypeModifiers()
{
	local int i;

	for (i = 0; i < LiveDamageTypeModifiers.Length; i++)
	{
		if ( LiveDamageTypeModifiers[i].DamageType != None )
		{
			DamageTypeModifiers.AddItem(LiveDamageTypeModifiers[i]);
		}
		else
		{
			break; // finished once we find an empty entry
		}
	}

	LiveDamageTypeModifiers.Length = 0;
}

/** Applies the blocking damage modifier to incoming damage */
function ApplyBlockingDamageModifier( out int Damage, Controller InstigatedBy, class<DamageType> damageType )
{
	local vector DamageDirNormal;

	if( !bIsBlocking || Damage <= 0 || InstigatedBy == none || InstigatedBy.Pawn == none || InstigatedBy.GetTeamNum() == GetTeamNum() )
	{
		return;
	}

	// Only block attacks that come from the front
	DamageDirNormal = Normal( InstigatedBy.Pawn.Location - Location );
	if( DamageDirNormal dot vector(Rotation) > MinBlockFOV )
	{
		// Melee damage first
		if( ClassIsChildOf(damageType, class'KFDT_Bludgeon') || ClassIsChildOf(damageType, class'KFDT_Slashing') )
		{
			Damage = int( float(Damage) * DifficultyBlockSettings.MeleeDamageModifier );
		}
		else
		{
			Damage = int( float(Damage) * DifficultyBlockSettings.DamageModifier );
		}
	}
}

event bool HealDamage(int Amount, Controller Healer, class<DamageType> DamageType, optional bool bRepairArmor=true, optional bool bMessageHealer=true)
{
	`DialogManager.PlaySpotZedHealingDialog( self );
	Super.HealDamage(Amount, Healer, DamageType);
	return true;
}

/** Is this monster effected by a melee damage debuff? */
function bool HasReducedMeleeDamage()
{
	return bHasReducedMeleeDamage;
}

/** sends any notifications to anything that needs to know this pawn has taken damage */
function NotifyTakeHit(Controller InstigatedBy, vector HitLocation, int Damage, class<DamageType> DamageType, vector Momentum, Actor DamageCauser)
{
	local KFPawn_Human KFPH_Instigator;
	local KFGameInfo KFGI;

	Super.NotifyTakeHit(InstigatedBy, HitLocation, Damage, DamageType, Momentum, DamageCauser);

	// continuous damage check needs to happen before we set LastPainTime and LastHitBy for current hit
	if( InstigatedBy != none && InstigatedBy.Pawn != none )
	{
		KFPH_Instigator = KFPawn_Human( InstigatedBy.Pawn );
		if( KFPH_Instigator != none )
		{
			`DialogManager.PlayDamageZedContinuousDialog( KFPH_Instigator, self );
		}
	}

	// Allow special move to react to TakeHit/TakeDamage
	if( SpecialMove != SM_None )
	{
		SpecialMoves[SpecialMove].NotifyOwnerTakeHit(class<KFDamageType>(damageType), HitLocation, Normal(Momentum), InstigatedBy);
	}

	KFGI = KFGameInfo(WorldInfo.Game);
	if (KFGI != none)
	{
		KFGI.NotifyTakeHit(self, InstigatedBy, HitLocation, Damage, DamageType, Momentum, DamageCauser);
	}

	`AILog_Ext(GetFuncName()$"() Instigator:"$InstigatedBy$" DT: "$DamageType, 'Damage', MyKFAIC);
}

function PlayHit(float Damage, Controller InstigatedBy, vector HitLocation, class<DamageType> damageType, vector Momentum, TraceHitInfo HitInfo)
{
	local KFPawn_Human KFPH_Instigator;

	if (ArmorInfo != none && ArmorInfo.LastTakeDamageTime == WorldInfo.TimeSeconds)
	{
		AdjustPlayHitForArmor(Damage, HitInfo);
	}

	super.PlayHit( Damage, InstigatedBy, HitLocation, damageType, Momentum, HitInfo );

	// play damage zed dialog after Afflictions happen in super
	if( InstigatedBy != none && InstigatedBy.Pawn != none )
	{
		KFPH_Instigator = KFPawn_Human( InstigatedBy.Pawn );
		if( KFPH_Instigator != none )
		{
			`DialogManager.PlayDamagedZedDialog( KFPH_Instigator, self, DamageType );
		}
	}
}

function AdjustPlayHitForArmor(out float InDamage, out TraceHitInfo InHitInfo)
{
	InDamage = 1;
	InHitInfo.BoneName = 'KBArmor';
}

/** Called before, and in addition to, NotifyTakeHit(), but processes melee specifically (Server only) */
function NotifyMeleeTakeHit(Controller InstigatedBy, vector HitLocation);

/** Delayed death from lethal damage */
function BleedOutTimer()
{
	if ( !bPlayedDeath )
	{
		`log(GetFuncName() @ "LastHitBy" @ LastHitBy, bLogTakeDamage);
		Died(LastHitBy, class'KFDT_Bleeding', Location);
	}
}

function float GetVortexAttractionModifier ()
{
	return VortexAttracionModifier;
}

/** Applies the rally buff and spawns a rally effect */
simulated function bool Rally(
							KFPawn 			RallyInstigator,
							ParticleSystem 	RallyEffect,
							name 			EffectBoneName,
							vector			EffectOffset,
							ParticleSystem	AltRallyEffect,
							name 			AltEffectBoneNames[2],
							vector 			AltEffectOffset,
							optional bool	bSkipEffects=false
						)
{
	local sRallyInfo RallyInfo;
    local KFAIController KFAIC;
    local bool bStartedBoostRally;

	local Name SocketBoneName;
	local Name AltSocketBoneName;

    GetDifficultyRallyInfo( RallyInfo );

    if( !RallyInfo.bCanRally || !IsAliveAndWell() )
    {
    	return false;
    }

	if( RallyInfo.DealtDamageModifier > 1.f )
	{
		if( !IsTimerActive(nameOf(Timer_EndRallyBoost)) )
		{
			SetTimer( RallyInfo.RallyBuffTime, false, nameOf(Timer_EndRallyBoost) );
			bStartedBoostRally = true;
		}
	}

    if( Role == ROLE_Authority && Controller != none && RallyInfo.bCauseSprint )
    {
	    KFAIC = KFAIController( Controller );

	    KFAIC.SetSprintingDisabled( false );
	    KFAIC.SetCanSprint( true );
	    KFAIC.bDefaultCanSprint = true;
	    KFAIC.bCanSprintWhenDamaged = true;
	    KFAIC.bForceFrustration = true;

	    // Trigger sprint/rage immediately
	    SetSprinting( true );
	    SetEnraged( true );

        if (KFGameInfo(WorldInfo.Game) != none)
        {
            KFGameInfo(WorldInfo.Game).NotifyRally(self);
        }
	}

	if( !bSkipEffects && WorldInfo.NetMode != NM_DedicatedServer )
	{
		if( RallyPSC != none )
		{
			RallyPSC.DeactivateSystem();
			DetachComponent( RallyPSC );
		}

		RallyPSC = WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment( RallyEffect, Mesh, EffectBoneName, false, EffectOffset );

		// Spawn player rally particle systems and attach them
		if( bStartedBoostRally )
		{
			SocketBoneName = Mesh.GetSocketBoneName(AltEffectBoneNames[0]);
			if (SocketBoneName != '' && SocketBoneName != 'None')
			{
				RallyHandPSCs[0] = WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment( AltRallyEffect, Mesh, AltEffectBoneNames[0], true, AltEffectOffset );
			}

			AltSocketBoneName = Mesh.GetSocketBoneName(AltEffectBoneNames[1]);
			if (AltSocketBoneName != '' && AltSocketBoneName != 'None')
			{
				RallyHandPSCs[1] = WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment( AltRallyEffect, Mesh, AltEffectBoneNames[1], true, AltEffectOffset );
			}
		}
	}

    return true;
}

/** Ends the rally boost and cancels effects */
simulated function Timer_EndRallyBoost()
{
	if( RallyHandPSCs[0] != none && RallyHandPSCs[0].bIsActive )
	{
		RallyHandPSCs[0].DeactivateSystem();
	}
	if( RallyHandPSCs[1] != none && RallyHandPSCs[1].bIsActive )
	{
		RallyHandPSCs[1].DeactivateSystem();
	}
}

/** Sets the difficulty-based rally settings for this pawn */
simulated function SetRallySettings( sRallyInfo NewRallyInfo )
{
	DifficultyRallySettings = NewRallyInfo;
}

/** Returns the difficulty-based rally settings */
simulated function GetDifficultyRallyInfo( out sRallyInfo RallyInfo )
{
	RallyInfo = DifficultyRallySettings;
}

/** Applies the rally damage boost if applicable */
simulated function int GetRallyBoostDamage( int NewDamage )
{
	local sRallyInfo RallyInfo;

	GetDifficultyRallyInfo( RallyInfo );
	return NewDamage * ( IsTimerActive(nameOf(Timer_EndRallyBoost)) ? RallyInfo.DealtDamageModifier : 1.f );
}

/** Applies the rally damage reduction if applicable */
simulated function int GetRallyBoostResistance( int NewDamage )
{
	local sRallyInfo RallyInfo;

	GetDifficultyRallyInfo( RallyInfo );
	return NewDamage * ( IsTimerActive(nameOf(Timer_EndRallyBoost)) ? RallyInfo.TakenDamageModifier : 1.f );
}

function bool Died(Controller Killer, class<DamageType> DamageType, vector HitLocation)
{
	local KFPlayerController KFPC;
	local KFPerk InstigatorPerk;
	local int i;

	if ( super.Died(Killer, damageType, HitLocation) )
	{
	 	if( Killer != none && Killer.Pawn != none && KFPawn_Human(Killer.Pawn) != none )
		{
			`DialogManager.PlayKilledZedDialog( KFPawn_Human(Killer.Pawn), self, DamageType, IsDoingSpecialMove(SM_Knockdown) || IsDoingSpecialMove(SM_RecoverFromRagdoll) );
		}

		if( bCouldTurnIntoShrapnel )
		{
			if( Killer != none )
			{
				KFPC = KFPlayerController(Killer);
				if( KFPC != none )
				{
					InstigatorPerk = KFPC.GetPerk();
					if( InstigatorPerk != none && InstigatorPerk.ShouldShrapnel() )
					{
						ShrapnelExplode( Killer, InstigatorPerk );
					}
				}
			}
		}

		if( bCouldTurnIntoToxicExplosion )
		{
			if( Killer != none )
			{
				KFPC = KFPlayerController(Killer);
				if( KFPC != none )
				{
					InstigatorPerk = KFPC.GetPerk();
					if( InstigatorPerk != none && InstigatorPerk.IsZedativeActive() )
					{
						InstigatorPerk.ToxicCloudExplode( Killer, self );
					}
				}
			}
		}

		if (ParasiteSeeds.Length > 0)
		{
			for (i = 0; i < ParasiteSeeds.Length; ++i)
			{
				ParasiteSeeds[i].Explode(Location - (vect(0,0,1) * GetCollisionHeight()), vect(0,0,1) >> ParasiteSeeds[i].Rotation);
			}

			ParasiteSeeds.Remove(0, ParasiteSeeds.Length);
		}

        OnZedDied(Killer);

        return true;
	}

	return false;
}

/** Handle any subclassed functionality for when a zed dies */
function OnZedDied(Controller Killer);

/** Handle this pawn being destroyed
*/
simulated event Destroyed()
{
    // Kill any affliction sounds/effects when this pawn is destroyed
    AfflictionHandler.Shutdown();
	super.Destroyed();
}

event OnRigidBodyLinearConstraintViolated(name StretchedBoneName)
{
	local KFGoreManager GoreManager;

	`log("Linear constraint violated, hiding bone " @ StretchedBoneName);

	GoreManager = KFGoreManager(WorldInfo.MyGoreEffectManager);
	if( GoreManager != none && GoreManager.AllowMutilation() )
	{
		if( !bIsGoreMesh )
		{
			SwitchToGoreMesh();
		}

		if( bIsGoreMesh )
		{
			GoreManager.CrushBone( self, StretchedBoneName );
			return;
		}
	}

	// no gore fallback
	mesh.HideBoneByName(StretchedBoneName, PBO_Term);
}

protected simulated function ResetHealthVisibilty()
{
	bShowHealth = false;
}

simulated function bool CanShowHealth()
{
	return bShowHealth;
}

simulated function bool IsNapalmInfected()
{
	return DamageOverTimeArray.Find('DamageType', class'KFDT_Fire_Napalm') != INDEX_NONE;
}

function bool CanNapalmInfect( out KFPlayerController NapalmInstigator )
{
	local int DoTIndex;
	local KFPlayerController KFPC;
	local KFPerk InstigatorPerk;

	if( DamageOverTimeArray.Length > 0 )
	{
		DoTIndex = DamageOverTimeArray.Find( 'DoT_Type', class'KFDT_Fire'.default.DoT_Type );
		if( DoTIndex != INDEX_NONE && DamageOverTimeArray[DoTIndex].InstigatedBy != none )
		{
			KFPC = KFPlayerController( DamageOverTimeArray[DoTIndex].InstigatedBy );
			if( KFPC != none )
			{
				InstigatorPerk = KFPC.GetPerk();
				if( InstigatorPerk != none && InstigatorPerk.CanSpreadNapalm() )
		        {
		        	NapalmInstigator = KFPC;
		        	return true;
				}
			}
		}
	}

	NapalmInstigator = none;
	return false;
}

function InfectWithNapalm( KFPawn_Monster KFPM, KFPlayerController KFPC )
{
	if( KFPC != none )
	{
		KFPM.TakeDamage( class'KFPerk_Firebug'.static.GetNapalmDamage(),
						 KFPC,
						 vect(0,0,0),
						 vect(0,0,0),
						 class'KFDT_Fire_Napalm',,
						 KFPC );
	}
}

/**
 * @brief Spawns a radioactive cloud that hurts other Zeds
 *
 * @param Killer The monster's killer (that had the shrapnel skill enabled)
 */
function ShrapnelExplode( Controller Killer, KFPerk InstigatorPerk )
{
	local KFExplosionActorReplicated ExploActor;
	local Actor InstigatorActor;
	local GameExplosion	ExplosionTemplate;

	if ( Role < ROLE_Authority )
	{
		return;
	}

	InstigatorActor = Killer.Pawn != none ? Killer.Pawn : Killer;

	// explode using the given template
	ExploActor = Spawn(class'KFExplosionActorReplicated', InstigatorActor,, Location,,, true);
	if( ExploActor != None )
	{
		ExploActor.InstigatorController = Killer;

		if( Killer.Pawn != none )
		{
			ExploActor.Instigator = Killer.Pawn;
		}

		if( InstigatorPerk != none )
		{
			ExplosionTemplate = InstigatorPerk.GetExplosionTemplate();
			ExploActor.Explode( ExplosionTemplate );
		}
	}
}

/*********************************************************************************************
 * @name	Injuries & Status Effects
********************************************************************************************* */

/** Called to set any visual inflation that needs to occur */
simulated function UpdateVisualInflation(float InflationAmount)
{
	local MaterialInstanceConstant MIC;
	local int i, j;

	//Turn off inflation entirely if we're in gore mode
	if (bIsGoreMesh)
	{
		InflationAmount = 0.f;
	}

	//Base character MICs
	foreach CharacterMICs(MIC)
	{
		MIC.SetScalarParameterValue('Scalar_Inflate', InflationAmount);
	}

	//Update MICs in any active PACs
	for (i = 0; i < `MAX_COSMETIC_ATTACHMENTS; ++i)
	{
		if (ThirdPersonAttachments[i] != none)
		{
			for (j = 0; j < ThirdPersonAttachments[i].Materials.Length; ++j)
			{
				MIC = MaterialInstanceConstant(ThirdPersonAttachments[i].GetMaterial(j));
				if (MIC != none)
				{
					MIC.SetScalarParameterValue('Scalar_Inflate', InflationAmount);
				}
			}
		}
	}

	//Update MICs in any active static attachments
	for (i = 0; i < StaticAttachList.Length; ++i)
	{
		if (StaticAttachList[i] != none)
		{
			for (j = 0; j < StaticAttachList[i].Materials.Length; ++j)
			{
				MIC = MaterialInstanceConstant(StaticAttachList[i].GetMaterial(j));
				if (MIC != none)
				{
					MIC.SetScalarParameterValue('Scalar_Inflate', InflationAmount);
				}
			}
		}
	}
}

/** Called on server when pawn should has been crippled (e.g. Headless) */
function CauseHeadTrauma(float BleedOutTime=5.f)
{
	if ( !bIsHeadless && !bPlayedDeath && !bDisableHeadless )
	{
    	if( MyKFAIC != none && KFGameInfo(WorldInfo.Game) != none && MyKFAIC.TimeFirstSawPlayer >= 0 )
    	{
            KFGameInfo(WorldInfo.Game).GameConductor.HandleZedKill( FMax(`TimeSince(MyKFAIC.TimeFirstSawPlayer),0.0));
    	   	// Set this so we know we already logged a kill for our pawn
            MyKFAIC.TimeFirstSawPlayer = -1;
    	}

        bPlayShambling = true;
		bIsHeadless = true;

		if( MyKFAIC != none )
		{
			MyKFAIC.SetSprintingDisabled(true);
		}

        // No more auto aiming to this zed
        bCanBeAdheredTo=false;
        bCanBeFrictionedTo=false;

		StopAkEventsOnBone( 'head' );

		// insti-kill while doing a root motion SM (uninterruptable)
		if ( IsDoingSpecialMove() && Mesh.RootMotionMode == RMM_Accel )
		{
			Died(LastHitBy, class'DamageType', Location);
		}
		// initiate ragdoll knockdown while sprinting
		else if ( bIsSprinting && FRand() < 0.25f )
		{
			Knockdown(Velocity, vect(1,1,1));
		}

		// initiate the "headless wander" AICommand
		if( IsAliveAndWell() && MyKFAIC != none )
		{
            // Only allow headless wander if were doing an SM that allows a wander interupt
            // otherwise wait until the end of the move
			if ( SpecialMove == SM_None || !SpecialMoves[SpecialMove].bCanOnlyWanderAtEnd )
			{
				MyKFAIC.DoHeadlessWander();
			}
		}

		if ( BleedOutTime > 0 )
		{
			SetTimer(BleedOutTime, false, nameof(BleedOutTimer));
		}
	}
}

/**
*  SERVER ONLY - Update any AI or animation behaviors based on state
*/
function OnStackingAfflictionChanged(byte Id)
{
    local bool bShouldBeWandering, bWasWandering;

    bWasWandering = (bPlayShambling || bPlayPanicked);

	bPlayShambling = bEmpPanicked || bIsHeadless;
	bPlayPanicked = bFirePanicked || bIsPoisoned || bMicrowavePanicked;

	bShouldBeWandering = (bPlayShambling || bPlayPanicked);

	if( !bWasWandering && bShouldBeWandering )
	{
		CausePanicWander();
	}
	else if( bWasWandering )
	{
		EndPanicWander();
	}
}

/** Called on server when pawn should do EMP Wandering */
function CausePanicWander()
{
	if ( !bIsHeadless && !bPlayedDeath )
	{
		// if bCanOnlyWanderAtEnd is true, do not begin to wander until the current special move has ended
		if ( SpecialMove != SM_None && SpecialMoves[SpecialMove].bCanOnlyWanderAtEnd )
		{
			return;
		}

		if (IsEnraged())
		{
			bRageAfterPanic = true;
			SetEnraged(false);
		}

		if( MyKFAIC != none )
		{
			MyKFAIC.SetSprintingDisabled(true);
		}

		// initiate the "EMP wander" AICommand
		if( IsAliveAndWell() && MyKFAIC != none )
		{
			MyKFAIC.DoPanicWander();
		}
	}
}

/** Called on server when pawn should stop doing EMP Wandering */
function EndPanicWander()
{
	if( MyKFAIC != none )
	{
		MyKFAIC.SetSprintingDisabled(false);
	}

	// stop the "EMP wander" AICommand
	if( IsAliveAndWell() && MyKFAIC != none )
	{
		MyKFAIC.EndPanicWander();
	}

	if (bRageAfterPanic)
	{
		bRageAfterPanic = false;
		SetEnraged(true);
	}
}

/** Returns true if a stacking incap is set that will cause a zed to wander */
simulated function bool ShouldBeWandering()
{
	return bPlayShambling || bPlayPanicked;
}

/** Returns true if a stacking incap is set that will cause a zed to wander */
simulated function bool IsHeadless()
{
	return bIsHeadless;
}

/** Returns true if a stacking incap is set that will prevent or interrupt a
* zed from using its special abilities (Ex Husk Flamethrower) */
simulated function bool IsImpaired()
{
	return bPlayPanicked || bEmpDisrupted || (bPlayShambling && !bIsHeadless);
}

/** Reapply active gameplay related MIC params (e.g. when switching to the gore mesh) */
simulated function UpdateGameplayMICParams()
{
	if ( AfflictionHandler != None )
	{
		AfflictionHandler.ToggleEffects(AF_Poison, bIsPoisoned);

		// Turn off inflated if we are using the gore mic
        if( bIsGoreMesh )
	    {
            AfflictionHandler.UpdateMaterialParameter(AF_Microwave, 0.f);
        }
    }
	super.UpdateGameplayMICParams();
}

/** Called when a melee attack has been parried by another pawn */
function bool NotifyAttackParried(Pawn InstigatedBy, byte InParryStrength)
{
	if ( InParryStrength < ParryResistance  )
    {
		return FALSE; // resisted
    }

	return Super.NotifyAttackParried(InstigatedBy, InParryStrength);
}

/*********************************************************************************************
 * @name	Special Moves
********************************************************************************************* */

/** Cloaking & Spotted */
function SetCloaked(bool bNewCloaking)
{
	if( bNewCloaking )
	{
		ClearBloodDecals();
    }
}

function CallOutCloaking( optional KFPlayerController CallOutController );

/** Notification when a melee special move ends */
function MeleeSpecialMoveEnded();

/** Cause a physics knockdown (e.g. SM_Emerge) */
function ANIMNOTIFY_Knockdown()
{
	// notify emerge anim to end with a ragdoll knockdown
	if ( SpecialMove == SM_Emerge )
	{
		//Knockdown(Velocity, vect(1,1,1));
		KFSM_Emerge(SpecialMoves[SM_Emerge]).bDoKnockdown = true;
	}
}

/** Called from melee special move when it's interrupted */
function NotifyAnimInterrupt( optional AnimNodeSequence SeqNode );

/** Sends message to local players using ClientMessage */
function Msg( string MsgTxt )
{
	MessagePlayer( MsgTxt );
}

function float GetCircleStrafeDuration()
{
	return 0.f;
}

function float GetStepBackInCombatOdds()
{
	return 0.12f;
}

function Pawn GetPawnToLookAt( optional bool bRequireLOS )
{
	local Pawn P;
	local array<Pawn> InterestingPawns;

	for( P = WorldInfo.PawnList; P != none; P = P.NextPawn )
	{
		if( P != self && P.IsAliveAndWell() && ( !bRequireLOS || LineOfSightTo( P ) ) )
		{
			InterestingPawns.AddItem( P );
		}
	}

	if( InterestingPawns.Length > 0 )
	{
		return InterestingPawns[ Rand(InterestingPawns.Length) ];
	}

	return None;
}

/*********************************************************************************************
 * @name	HeadTracking
********************************************************************************************* */

simulated function bool LookAtPawn( optional Pawn P, optional float Strength=0.5f )
{
	if( IK_Look_Head == none )
	{
		IK_Look_Head		= SkelControlLookAt(Mesh.FindSkelControl('HeadLook'));
		//IK_Look_Spine		= SkelControlLookAt(Mesh.FindSkelControl('SpineLook'));
	}

	if( IK_Look_Head != none )
	{
		if( P == none )
		{
			P = GetPawnToLookAt( true );
		}

		if( P != none )
		{
		//	if( IK_Look_Head.CanLookAtPoint( P.Location + ( vect(0,0,1) * P.BaseEyeHeight ) ) )
		//	{
				bIsHeadTrackingActive = true;
				`AILog_Ext( GetFuncName()@P, 'HeadTracking', MyKFAIC );
				SetHeadTrackTarget( P, vect(0,0,1) * P.BaseEyeHeight, Strength, false );
				return true;
		//	}
		}
	}
	return false;
}

simulated function StopLookingAtPawn( optional Pawn P )
{
	if( bCanHeadTrack && bIsHeadTrackingActive && MyLookAtInfo.LookAtTarget != none )
	{
		if( P == none )
		{
			P = Pawn( MyLookAtInfo.LookAtTarget );
		}
		if( P != none )
		{
			`AILog_Ext( GetFuncName()@P, 'HeadTracking', MyKFAIC );
			ClearHeadTrackTarget( P );
		}
	}
}

/*********************************************************************************************
 * @name	Effects / Gore
********************************************************************************************* */

/**
 *  Performs the actual gore LOD switch, and optionally switches physics asset upon death
 *
 * 	@param   GoreLODIndex		 LOD index for the gore LOD
 */
native final simulated function bool SwitchToGoreMesh();

/** Called when SwitchToGoreMesh is successful */
simulated event NotifyGoreMeshActive()
{
    // Need to reset material params since our MIC was reassigned to the gore mesh
	UpdateGameplayMICParams();

	if ( SpecialMove != SM_None )
	{
		SpecialMoves[SpecialMove].OnGoreMeshSwap();
	}
}

/** Returns n closest bones to the TestLocation that belong to the physics asset of the mesh */
simulated function GetClosestHitBones(int NumBones, vector TestLocation, out array<name> OutHitBoneList)
{
	local int i;
	local array<name> SearchList;

	// Add bones in the physics asset to the search list
	for( i=0; i<mesh.PhysicsAsset.BodySetup.length; i++ )
	{
		SearchList.AddItem(mesh.PhysicsAsset.BodySetup[i].BoneName);
	}

	mesh.FindClosestBones(TestLocation, NumBones, OutHitBoneList, SearchList);
}

simulated event RigidBodyCollision( PrimitiveComponent HitComponent, PrimitiveComponent OtherComponent,
					const out CollisionImpactData RigidCollisionData, int ContactIndex )
{
	local int i;
	local KFGoreManager GoreManager;
	local RigidBodyContactInfo ContactInfo;

	GoreManager = KFGoreManager(WorldInfo.MyGoreEffectManager);

	if( GoreManager != none && `TimeSince(LastGibCollisionTime) > GoreManager.GetTimeBetweenGibBloodSplats() )
	{
		LastGibCollisionTime = WorldInfo.TimeSeconds;;

		if ( OtherComponent != none && OtherComponent.Owner != none && !OtherComponent.Owner.IsA('KFPawn') ) // Skip pawn-on-pawn collisions
	    {
		    SoundGroupArch.PlayRigidBodyCollisionSound( self, RigidCollisionData.ContactInfos[ContactIndex].ContactPosition );

		    for( i=0; i<RigidCollisionData.ContactInfos.length; i++ )
			{
				ContactInfo = RigidCollisionData.ContactInfos[i];
				GoreManager.LeaveAPersistentBloodSplat(ContactInfo.ContactPosition, -ContactInfo.ContactNormal);
				//DrawDebugCoordinateSystem(ContactInfo.ContactPosition, rotator(-ContactInfo.ContactNormal), 10, true);
			}
	    }
	}
}

/** plays clientside hit effects using the data in HitFxInfo */
simulated function PlayTakeHitEffects( vector HitDirection, vector HitLocation, optional bool bUseHitImpulse = true)
{
	local class<KFDamageType> DmgType;
	local name HitZoneName, HitBoneName;
	local int HitZoneIndex;

	// NVCHANGE_BEGIN - RLS - Debugging Effects
	if( WorldInfo.Game != none && KFGameInfo(WorldInfo.Game).bNVAlwaysHeadshot )
	{
		HitFxInfo.HitBoneIndex = HZI_HEAD;
	}
	// NVCHANGE_BEGIN - RLS - Debugging Effects

	// Cached hit params
	DmgType = HitFxInfo.DamageType;

	HitZoneIndex = HitFxInfo.HitBoneIndex;
	if ( HitZoneIndex != 255 && HitZoneIndex <= HitZones.Length)	// INDEX_None -> 255 after byte conversion
	{
		HitZoneName = HitZones[HitZoneIndex].ZoneName;
		HitBoneName = HitZones[HitZoneIndex].BoneName;
	}

	if( DmgType != none )
	{
		// If TornOff hasn't been called yet on client, PlayDying now before hit reactions
		if ( bTearOff && !bPlayedDeath )
		{
			PlayDying(HitDamageType,TakeHitLocation);
		}

		if ( bPlayedDeath )
		{
			PlayDeadHitEffects(HitLocation, HitDirection, HitZoneIndex, HitZoneName, HitBoneName, DmgType, bUseHitImpulse);
		}
		else
		{
			PlayLivingHitEffects(HitLocation, HitDirection, HitZoneIndex, HitZoneName, HitBoneName, DmgType, bUseHitImpulse);
		}
	}

	if( !bPlayedDeath )
	{
		bShowHealth = true;
		SetTimer( 2.f, false, nameOf(ResetHealthVisibilty) );
	}

	Super.PlayTakeHitEffects( HitDirection, HitLocation, bUseHitImpulse );
}

/** Plays hit effects on dead zeds, this includes dismemberment and obliteration */
simulated function PlayDeadHitEffects(vector HitLocation, vector HitDirection, int HitZoneIndex, name HitZoneName, name HitBoneName, class<KFDamageType> DmgType, optional bool bUseHitImpulse)
{
	local class<KFProj_PinningBullet> PinProjectileClass;
	local KFPawn DeadPawn;
	local KFGoreManager GoreManager;
	local bool bIsDismemberingHit;
	local bool bWasObliterated;

	// If ragdoll and gore is not allowed for dead bodies, check the time of death
	// to see when the pawn died, and skip if he has been dead for a while
	if( bAllowRagdollAndGoreOnDeadBodies || `TimeSince(TimeOfDeath) <= 3.f )
	{
		// If this zone is 'injured' try to dismember it
		if ( (InjuredHitZones & (1 << HitZoneIndex)) > 0 && !HitZones[HitZoneIndex].bPlayedInjury )
		{
			bIsDismemberingHit = PlayDismemberment(HitZoneIndex, DmgType, HitDirection );

	    	// If there was no dismemberment, explode head instead
	    	if  ( !bIsDismemberingHit && (InjuredHitZones & (1 << HZI_Head)) > 0 )
    		{
    			PlayHeadAsplode();
    			// Set bIsDismemberingHit to true to add an impulse to the neck
    			bIsDismemberingHit = true;
    		}
	    }

		GoreManager = KFGoreManager(WorldInfo.MyGoreEffectManager);
		// If the gore manager doesn't allow mutilation, then we don't allow anything other than basic effects.
		if(GoreManager.AllowMutilation() && HitFxInfo.bObliterated && `TimeSince(TimeOfDeath) < 0.25f && !bUseDamageInflation)
		{
			bWasObliterated = true;
			bIsDismemberingHit = true;
			HandlePartialGoreAndGibs(DmgType, HitLocation, HitDirection, HitBoneName, true);

			GoreManager = KFGoreManager(WorldInfo.MyGoreEffectManager);
			GoreManager.SpawnObliterationBloodEffect(self);
		}
		else
		{
	        // Handle damage types from projectiles that can pin zeds to walls
	        PinProjectileClass = DmgType.static.GetPinProjectileClass();
			if( PinProjectileClass != none )
			{
			   DeadPawn = self;
	           PinProjectileClass.static.CreatePin(DeadPawn, HitLocation, HitDirection, HitBoneName);
			}

            HandlePartialGoreAndGibs(DmgType, HitLocation, HitDirection, HitBoneName, false);
        }

		// Apply an impulse to attached limbs and ragdoll
		HandleRagdollImpulseEffects( HitLocation, HitDirection, HitZoneName, HitBoneName, DmgType, bIsDismemberingHit, bUseHitImpulse );
	}

	// Play blood effects. Apply more blood if this was a dismembering hit
	ApplyBloodDecals(HitZoneIndex, HitLocation, HitDirection, HitZoneName, HitBoneName, DmgType, bIsDismemberingHit, bWasObliterated);
}

/** Apply impulse to the dead ragdolls bones  */
simulated function HandleRagdollImpulseEffects( vector HitLocation, vector HitDirection, name HitZoneName, name HitBoneName, class<KFDamageType> DmgType, bool bIsDismemberingHit, optional bool bUseHitImpulse )
{
	local vector ImpulseDir, ParentImpulseDir;
	local float ImpulseScale, ParentImpulseScale;
	local name RBBoneName;
	local name HitBoneParentName;

	// Allow damage type to modify the impulse for a dismembering hit
	ImpulseDir = HitDirection;
	ParentImpulseDir = HitDirection;
	ImpulseScale = 1.f;
	ParentImpulseScale = 1.f;

	if( bIsDismemberingHit )
	{
        DmgType.static.ModifyDismembermentHitImpulse(self, HitZoneName, ImpulseDir, HitDirection, ParentImpulseDir, ImpulseScale, ParentImpulseScale);
	}

	if( HitBoneName != '')
	{
		// Get the rigidbody bone that matches the hit bone name
		RBBoneName = GetRBBoneFromBoneName(HitBoneName);
	}

	// Apply impulse to hit bone. This can be for an alive zed (on death shot) or a dismembered limb
	// In case of explosives, this applies an impulse to the body and not the gibs.
	// Impulse to the gibs is handled separately in CauseGibsAndApplyImpulse()
    if (bUseHitImpulse)
    {
        ApplyRagdollImpulse(DmgType, HitLocation, ImpulseDir, RBBoneName, ImpulseScale);

        // Apply another impulse to parent bone when a limb gets dismembered for the first time. Skip if parent is the root bone.
        if (bIsDismemberingHit && ParentImpulseScale > 0)
        {
            HitBoneParentName = mesh.GetParentBone(HitBoneName);

            // Add additional force if we blew the head off if needed
            if ((HitBoneName == 'head' || HitBoneParentName == 'neck') && DmgType != none)
            {
                ParentImpulseScale *= DmgType.default.HeadDestructionImpulseForceScale;
            }

            // Grab the rigid body bone name so we know which one to apply RB force to
            HitBoneParentName = GetRBBoneFromBoneName(HitBoneParentName);

            // Do not apply an additional impulse to the parent bone on for a dismembering shot if it'st he same as oru RB bone
            if (RBBoneName != HitBoneParentName && Mesh.PhysicsAsset.FindBodyIndex(HitBoneParentName) != INDEX_NONE)
            {
                ApplyRagdollImpulse(DmgType, HitLocation, ParentImpulseDir, HitBoneParentName, ParentImpulseScale);
            }
        }
    }
}

/** Hit effects for a living zed */
simulated function PlayLivingHitEffects(vector HitLocation, vector HitDirection, int HitZoneIndex, name HitZoneName, name HitBoneName, class<KFDamageType> DmgType, optional bool bUseHitImpulse)
{
	if ( !TryPlayHitReactionAnim(HitDirection, DmgType, HitZoneIndex)
		&& PawnAnimInfo.bCanPlayPhysicsHitReactions
		&& ActorEffectIsRelevant(HitFXInstigator, false) )
	{
		// Play Physics Body Impact.
		PlayPhysicsBodyImpact(HitLocation, HitDirection, DmgType, HitBoneName);
	}

	// NVCHANGE_BEGIN - RLS - Debugging Effects
	if( WorldInfo.Game != none && KFGameInfo(WorldInfo.Game).bNVAlwaysHeadshot )
	{
		HitZoneIndex = HZI_HEAD;
	}
	// NVCHANGE_BEGIN - RLS - Debugging Effects

	if( HitZoneIndex == HZI_Head )
	{
		// If head is dismembered (InitPartialKinematics was called), do impulse
		if ( bUseHitImpulse && Mesh.PhysicsWeight == 1.f && bIsHeadless )
		{
			ApplyRagdollImpulse(DmgType, HitLocation, HitDirection, HeadBoneName, 1.f);
		}

		ApplyHeadChunkGore(DmgType, HitLocation, HitDirection);
	}

	// Play blood effects. Apply more blood if this was a dismembering hit
	ApplyBloodDecals(HitZoneIndex, HitLocation, HitDirection, HitZoneName, HitBoneName, DmgType, false, false);
}

simulated function PlayDyingSound()
{
	if( ClassIsChildOf(HitDamageType, class'KFDT_Bleeding') )
	{
		SoundGroupArch.PlayBleedoutDyingSound( self );
	}
	else if( bHasBrokenConstraints && !HasMouth() )
	{
		// if we have no head or mouth...
		SoundGroupArch.PlayMouthlessDyingSound( self );
	}
	else
	{
		super.PlayDyingSound();
	}
}

simulated function PlayHitZoneGoreSounds( name HitBoneName, vector HitLocation )
{
    if( SoundGroupArch.ShouldPlayCleaveSound(HitBoneName) )
    {
        SoundGroupArch.PlayCleaveSound( self, HitLocation );
    }
    else
    {
        SoundGroupArch.PlayDismembermentSounds( self, HitLocation );
    }
}

/**
 * Return true if we've already broken the input head bone
 *
 * @param	BoneName	the head bone to check to see if we've already broken it.
 */
simulated function bool HeadBoneAlreadyBroken(name BoneName)
{
    if( BrokenHeadBones.Find(BoneName) != INDEX_NONE )
    {
        return true;
    }

    return false;
}

/**
 * Return true if we've already broken the input head bone
 *
 * @param	BoneName	the head bone to add to the broken head bone array.
 */
simulated function AddBrokenHeadBone(name BoneName)
{
    if( BrokenHeadBones.Find(BoneName) == INDEX_NONE )
    {
        BrokenHeadBones.AddItem(BoneName);
    }

    return;
}

/**
 * Return true if this pawn is ok with having the input head bone be broken
 *
 * @param	BoneName	the head bone to check to see if we all it to break.
 */
simulated function bool ShouldAllowHeadBoneToBreak(name BoneName)
{
    if( !bPlayedDeath && !bIsHeadless && !bTearOff )
    {
		if ( NumHeadChunksRemoved >= MaxHeadChunkGoreWhileAlive )
		{
			return false;
		}

		// Don't allow both sides of the front of the face (both eyes) to be blown
		// off, or both sides of the back of the head and the jaw while the zed is alive and not headless
		if( (BoneName == 'Gore_FrontL' && BrokenHeadBones.Find('Gore_FrontR') != INDEX_NONE)
			|| (BoneName == 'Gore_FrontR' && BrokenHeadBones.Find('Gore_FrontL') != INDEX_NONE)
			|| (BoneName == 'Gore_BackL' && BrokenHeadBones.Find('Gore_Jaw') != INDEX_NONE && BrokenHeadBones.Find('Gore_BackR') != INDEX_NONE)
			|| (BoneName == 'Gore_BackR' && BrokenHeadBones.Find('Gore_Jaw') != INDEX_NONE && BrokenHeadBones.Find('Gore_BackL') != INDEX_NONE)
			|| (BoneName == 'Gore_Jaw' && BrokenHeadBones.Find('Gore_BackR') != INDEX_NONE && BrokenHeadBones.Find('Gore_BackL') != INDEX_NONE) )
		{
			return false;
		}
	}

    return true;
}

/** Update metadata required by gore chunk attachments */
simulated function UpdateGoreChunkData(name BoneName)
{
	if( BoneName == 'Gore_FrontL' ||
		BoneName == 'Gore_FrontR' ||
		BoneName == 'Gore_BackL'  ||
		BoneName == 'Gore_BackR'  /*||
		BoneName == 'Gore_Jaw'*/ )
	{
  		NumHeadChunksRemoved++;
	}
}

/** Implementation of delegate function used to determine whether to attach the skull gore chunk.
	The skull gore chunk is used only when one or two head chunks are removed */
simulated function bool ShouldAttachSkullChunk()
{
	return NumHeadChunksRemoved < 3;
}

/** Implementation of delegate function used to determine whether to detach the skull gore chunk.
	If attached, the skull gore chunk is detached when more than 2 head chunks are removed */
simulated function bool ShouldDetachSkullChunk()
{
	return NumHeadChunksRemoved >= 3 && (bPlayedDeath || bIsHeadless || bTearOff);
}

/** Handles the gore chunks to be attached to the pawn body when a limb is dismembered or gibbed */
simulated function HandleGoreChunkAttachments(name DismemberedBone)
{
	local int AttachmentIndex, ChunkRef;
	local StaticMeshComponent AttachComp;
	local KFCharacterInfo_Monster MonsterInfo;
	local AttachedGoreChunkInfo ChunkInfo;
	local KFGoreChunkAttachmentInfo CurrentChunk;

	// Update information that is required by the attachment/detachment code
	UpdateGoreChunkData(DismemberedBone);

	MonsterInfo = GetCharacterMonsterInfo();

	if( MonsterInfo != none )
	{
		for( AttachmentIndex = 0; AttachmentIndex < MonsterInfo.GoreChunkAttachments.length; AttachmentIndex++ )
		{
			CurrentChunk = MonsterInfo.GoreChunkAttachments[AttachmentIndex];

			if( CurrentChunk.DismemberedBoneList.Find(DismemberedBone) != INDEX_NONE )
			{
				// Search for it in the currently attached chunks list
				ChunkRef = AttachedGoreChunks.Find('AttachmentIndex', AttachmentIndex);

				if( CurrentChunk.ShouldAttachGoreChunk(self) && ChunkRef == INDEX_NONE )
				{
					// Create and intialize the attachment component
					AttachComp = new(self) class'StaticMeshComponent';
					AttachComp.SetStaticMesh(CurrentChunk.StaticMesh);
					AttachComp.SetLightingChannels(PawnLightingChannel);
					AttachComp.CastShadow=true;
					AttachComp.bCastDynamicShadow=true;
					AttachComp.bAllowPerObjectShadowBatching=true;

                    //Big head mode specific fix.  Increase cull distance for this situation
                    if (CurrentChunk.SocketName == 'Head_Attach' && CurrentHeadScale > 1.f)
                    {
                        AttachComp.SetCullDistance(1000 * CurrentHeadScale);
                    }
                    else
                    {
                        AttachComp.SetCullDistance(1000);
                    }

					AttachComp.SetShadowParent(mesh);
					AttachComp.bAllowApproximateOcclusion=True;
					AttachComp.SetTraceBlocking(False,False);
					AttachComp.SetActorCollision(False,False);

					// Attach chunk to socket in the pawn mesh
					mesh.AttachComponentToSocket(AttachComp, CurrentChunk.SocketName);

					// Add it to the list of currently active gore attachments
					ChunkInfo.AttachmentIndex = AttachmentIndex;
					ChunkInfo.AttachedComponent = AttachComp;
					AttachedGoreChunks.AddItem(ChunkInfo);
				}
				else if( CurrentChunk.ShouldDetachGoreChunk(self) && ChunkRef != INDEX_NONE )
				{
					AttachComp = AttachedGoreChunks[ChunkRef].AttachedComponent;

					// Detach the chunk from the mesh
					mesh.DetachComponent(AttachComp);

					// Remove it from the list of currently active gore attachments
					AttachedGoreChunks.Remove(ChunkRef, 1);
				}
			}
		}
	}
}

/** Calculate type of hit reaction animation from damage info */
simulated function bool TryPlayHitReactionAnim(vector HitDirection, class<KFDamageType> damageType, byte HitZoneIdx)
{
	local EPawnOctant AnimDir;
	local EHitReactionAnimType HitReactionType;
	local EHitZoneBodyPart BodyPart;
	local bool bOnlyAdditiveHits;

	if( damageType == none || ActorTimeSince(NextHitReactionAnim_ActorTime) < 0 )
	{
		return false;
	}

	// cannot play hit reaction anims during special moves
	if ( IsDoingSpecialMove() )
	{
		bOnlyAdditiveHits = true;
		if ( !SpecialMoves[SpecialMove].bAllowHitReactions )
		{
			return false;
		}
	}

	// Set the limb used for incap effects
	BodyPart = (HitZoneIdx != 255 && HitZoneIdx < HitZones.Length) ? HitZones[HitZoneIdx].Limb : BP_Torso;

	HitReactionType = HIT_Light;
	// If we're moving (e.g. DoPauseAI wasn't called because of incap cooldown) don't try hard/medium
	// This is not 100% reliable, but worst case we get a reasonable upper body blend while moving
	bOnlyAdditiveHits = bOnlyAdditiveHits || VSizeSq(Velocity) > 50.f;

	if ( !bOnlyAdditiveHits )
	{
		HitReactionType = EHitReactionAnimType(AfflictionHandler.GetPredictedHitReaction(DamageType, BodyPart));
	}

	switch (BodyPart)
	{
	case BP_LeftArm:
		AnimDir = CalcOctagonRegion(Rotation, -HitDirection);
		if ( AnimDir == DIR_Forward || AnimDir == DIR_ForwardLeft || AnimDir == DIR_ForwardRight )
			AnimDir = DIR_ForwardLeft;
		else
			AnimDir = DIR_BackwardLeft;
		break;
	case BP_RightArm:
		AnimDir = CalcOctagonRegion(Rotation, -HitDirection);
		if ( AnimDir == DIR_Forward || AnimDir == DIR_ForwardLeft || AnimDir == DIR_ForwardRight )
			AnimDir = DIR_ForwardRight;
		else
			AnimDir = DIR_BackwardRight;
		break;
	default:
		AnimDir = CalcOctagonRegion(Rotation, -HitDirection);
		break;
	}

	// Play animation
	return PawnAnimInfo.PlayHitReactionAnim(self, HitReactionType, AnimDir);
}

/** plays clientside hit effects using the data in HitFxInfo */
simulated function ApplyBloodDecals(int HitZoneIndex, vector HitLocation, vector HitDirection, name HitZoneName, name HitBoneName, class<KFDamageType> DmgType, bool bIsDismemberingHit, bool bWasObliterated)
{
	local KFGoreManager GoreManager;

	GoreManager = KFGoreManager(WorldInfo.MyGoreEffectManager);

	if( DmgType != none && GoreManager != none )
	{
		// Spawn wound decal on the damaged pawn
		if( !bWasObliterated && !bIsCloaking )
		{
		GoreManager.LeaveABodyWoundDecal(self, HitLocation, HitDirection, HitZoneName, HitBoneName, DmgType);
		}

        // Spawn blood splatter decal effect behind the damaged pawn
		if ( DmgType.default.bShouldSpawnBloodSplat )
		{
			GoreManager.LeaveABloodSplatterDecal(self, HitLocation, HitDirection);
		}

		// Spawn persistent blood splatters
		if( DmgType.default.bShouldSpawnPersistentBlood )
		{
             GoreManager.CausePersistentBlood(self, DmgType, HitLocation, HitDirection, HitZoneIndex, bIsDismemberingHit, bWasObliterated);
		}
	}
}

/**
 *	Gibbing, partial gore and gib impusle effects handled here.
 *
 *  @param	ObliterateGibs	If true this function will rip apart all limbs. If false, the default behavior is to select random bones to rip apart.
*/
simulated function HandlePartialGoreAndGibs(
	class<KFDamageType> DmgType,
	vector HitLocation,
	vector HitDirection,
	name HitBoneName,
	bool ObliterateGibs)
{
	local KFGoreManager GoreManager;
	local KFCharacterInfo_Monster MonsterInfo;

	GoreManager = KFGoreManager(WorldInfo.MyGoreEffectManager);

	if( DmgType != none && GoreManager != none )
	{
		if( GoreManager.AllowMutilation() )
		{
			// Enable alternate bone weighting and gore skeleton
			if( !bIsGoreMesh )
			{
				SwitchToGoreMesh();
			}

			// Apply gore only if we were able to successfully switch to the gore mesh
			if( bIsGoreMesh )
			{
				MonsterInfo = GetCharacterMonsterInfo();
				// Try to apply exlosion gore first
				if(ObliterateGibs)
				{
					ApplyObliterationFxGore( GoreManager, MonsterInfo, DmgType );
				}
				else
				if( HitFxInfo.bRadialDamage)
				{
					ApplyRadialFxGore( GoreManager, MonsterInfo, DmgType );
				}
				else
				{
					ApplyTakeHitFxGore( GoreManager, MonsterInfo, DmgType, HitLocation, HitDirection, HitBoneName );
				}
			}
    	}
	}
}

/**
 *	Apply any gibbing from radial damage
 *
 *  @param	ObliterateGibs	If true this function will rip apart all limbs. If false, the default behavior is to select random bones to rip apart.
*/
simulated function ApplyRadialFxGore( KFGoreManager GoreManager, KFCharacterInfo_Monster MonsterInfo, class<KFDamageType> DmgType )
{
	local array<name> OutGibBoneList;
	local float NormalizedDistanceScale;
	local vector ExplosionOrigin;
	local int NumGibs;

	// Try to apply exlosion gore first
	if( DmgType.default.bCanGib)
	{
		ExplosionOrigin = HitFxRadialInfo.RadiusHurtOrigin;

		// Use distance from explosion along with some randomization to figure out
		// how many joints to dismember. Distance based calculation is skipped after 10 meters.
		NormalizedDistanceScale = VSize(Location - ExplosionOrigin)/1000.f;
		NumGibs = FCeil(FMax(1.f - NormalizedDistanceScale, 0.f) * rand(10)) + rand(3);
		NumGibs *= MonsterInfo.ExplosionGibScale;

		GetClosestHitBones(NumGibs, ExplosionOrigin, OutGibBoneList);

		// Gib-ify!
		// Spawn exlosion PS at the root bone
		GoreManager.CauseGibsAndApplyImpulse(
			self,
			DmgType,
			ExplosionOrigin,
			OutGibBoneList,
			MonsterInfo.ExplosionEffectTemplate,
			mesh.GetBoneLocation(mesh.GetBoneName(0)));
	}
}

/**
 *	This function will dismember all rigid body bones in the mesh.
*/
simulated function ApplyObliterationFxGore( KFGoreManager GoreManager, KFCharacterInfo_Monster MonsterInfo, class<KFDamageType> DmgType )
{
	local array<name> OutGibBoneList;
	local vector ObliterationLocation;
	local int MaxNumGibs;

	if( DmgType.default.MaxObliterationGibs > 0 )
	{
		MaxNumGibs = DmgType.default.MaxObliterationGibs;
	}
	else
	{
		// Allowed to disconnect 100 bones (basically, all bones.)
		MaxNumGibs = 100;
	}

	// Try to apply exlosion gore first
	if( DmgType.default.bCanGib)
	{
		// Origin is the point where the explosive went off
		if(HitFxInfo.bRadialDamage == true)
		{
			ObliterationLocation = HitFxRadialInfo.RadiusHurtOrigin;
		}
		else if( DmgType.default.bUseHitLocationForGibImpulses )
		{
			ObliterationLocation = HitFxInfo.HitLocation;
			if( DmgType.default.bPointImpulseTowardsOrigin )
			{
				ObliterationLocation -= DecodeUnitVector(HitFxInfo.EncodedHitDirection) * DmgType.default.ImpulseOriginScale;
			}
			else
			{
				ObliterationLocation.Z = Location.Z - CylinderComponent.CollisionHeight * 0.25f;
			}
		}
		else
		{
			ObliterationLocation = self.Location;
		}

		GetClosestHitBones(MaxNumGibs, ObliterationLocation, OutGibBoneList);

		// Gib-ify!
		// Spawn exlosion PS at the root bone
		GoreManager.CauseGibsAndApplyImpulse(
			self,
			DmgType,
			ObliterationLocation,
			OutGibBoneList,
			MonsterInfo.ExplosionEffectTemplate,
			mesh.GetBoneLocation(mesh.GetBoneName(0)));
	}
}

/** Apply any gore or breaks from non radial damage */
simulated function ApplyTakeHitFxGore(
	KFGoreManager GoreManager,
	KFCharacterInfo_Monster MonsterInfo,
	class<KFDamageType> DmgType,
	vector HitLocation,
	vector HitDirection,
	name HitBoneName)
{
	local array<name> OutGibBoneList;
	local int JointIndex, ExplosionBreakIdx, BoneIdx;
	local vector ExplosionOrigin;
	local name GibBone;

	// Apply partial gore (if supported)
	GoreManager.ConditionalApplyPartialGore(self, DmgType, HitLocation, HitDirection, HitBoneName);

	// Apply any hit explosion gore specified for this bone
	for( JointIndex = 0; JointIndex < MonsterInfo.GoreJointSettings.length; JointIndex++ )
	{
		if( MonsterInfo.GoreJointSettings[JointIndex].HitBoneName == HitBoneName )
		{
			for( ExplosionBreakIdx = 0;
				 ExplosionBreakIdx < MonsterInfo.GoreJointSettings[JointIndex].HitExplosionGore.length;
				 ExplosionBreakIdx++ )
			{
				if( MonsterInfo.GoreJointSettings[JointIndex].HitExplosionGore[ExplosionBreakIdx].ConstrainToDamageGroups.length == 0 ||
				  	MonsterInfo.GoreJointSettings[JointIndex].HitExplosionGore[ExplosionBreakIdx].ConstrainToDamageGroups.Find(DGT_None) != INDEX_None ||
					MonsterInfo.GoreJointSettings[JointIndex].HitExplosionGore[ExplosionBreakIdx].ConstrainToDamageGroups.Find(DmgType.default.GoreDamageGroup) != INDEX_None)
				{
					// Origin is the place of hit
					ExplosionOrigin = mesh.GetBoneLocation(HitBoneName);

					// Only include bones that haven't been gibbed/broken already
					for( BoneIdx = 0;
						 BoneIdx < MonsterInfo.GoreJointSettings[JointIndex].HitExplosionGore[ExplosionBreakIdx].BreakBones.length;
						 BoneIdx++ )
					{
                        GibBone = MonsterInfo.GoreJointSettings[JointIndex].HitExplosionGore[ExplosionBreakIdx].BreakBones[BoneIdx].BoneName;
				        if( !mesh.IsBrokenConstraint(GibBone) )
        				{
                        	OutGibBoneList.AddItem(GibBone);
				        }
					}

					// Gib-ify!
					GoreManager.CauseGibsAndApplyImpulse(
						self,
						DmgType,
						ExplosionOrigin,
						OutGibBoneList,
						MonsterInfo.GoreJointSettings[JointIndex].HitExplosionGore[ExplosionBreakIdx].ParticleSystemTemplate,
						ExplosionOrigin,
						HitBoneName);
				}
			}
		}
	}
}

/** Gibbing and partial gore effects handled here */
simulated function ApplyHeadChunkGore(class<KFDamageType> DmgType, vector HitLocation, vector HitDirection)
{
	local KFGoreManager GoreManager;

	if( bCanCloak && IsAliveAndWell() )
	{
		return;
	}

	GoreManager = KFGoreManager(WorldInfo.MyGoreEffectManager);

	if( DmgType != none && GoreManager != none )
	{
		if( GoreManager.AllowMutilation() )
		{
			// Enable alternate bone weighting and gore skeleton
			if( !bIsGoreMesh )
			{
				SwitchToGoreMesh();
			}

			if ( !bPlayedDeath )
			{
				// @hack: force all gore as if it was a handgun so we only get head chunks
				DmgType = class'KFDT_Ballistic';
				GoreManager.ConditionalApplyPartialGore(self, DmgType, HitLocation, HitDirection, HitZones[HZI_HEAD].BoneName);
			}
    	}
	}
}

/** Reliably play any gore effects related to a zone/limb being dismembered */
simulated function HitZoneInjured(optional int HitZoneIdx=INDEX_None)
{
    // --------------------------------------------------------------
	// Network: Server (Also called on clients after TearOff)
	// --------------------------------------------------------------
	if ( Role == ROLE_Authority && HitZoneIdx != INDEX_None )
	{
		if ( HitZoneIdx == HZI_Head )
		{
			CauseHeadTrauma();
		}

		// replicate to all clients
		InjuredHitZones = InjuredHitZones | (1 << HitZoneIdx);
	}

	// Play living head explosion effects. Some effects use the clientside HitFX system (e.g. PlayDismemberment),
	// but this should be used when we need a reliably replicated effect.
	if  (WorldInfo.NetMode != NM_DedicatedServer && (!bTearOff && !bPlayedDeath))
	{
        if ( (InjuredHitZones & (1 << HZI_Head)) > 0 && !bDisableHeadless)
		{
			// Use HitFxInfo for "best guess" DT and CreationTime to fallback
			// on HeadAsplode when coming into relevancy.
			if ( `TimeSince(CreationTime) > 1.f )
			{
				PlayDismemberment(HZI_Head, HitFxInfo.DamageType);
			}

	    	// If there was no dismemberment, explode head instead
	    	if  ( !HitZones[HZI_Head].bPlayedInjury )
	    	{
				PlayHeadAsplode();
			}
		}
	}
}

simulated function PlayHeadAsplode()
{
	local KFGoreManager GoreManager;
	local name BoneName;

	if( HitZones[HZI_Head].bPlayedInjury )
	{
		return;
	}

	// make sure this doesn't happen after death so that normal HitFX/Gore path is followed.  Using
	// bTearOff since bPlayDying may not be set yet on the client
	// Let the head be blown off for a short time still after death
	if ( (bTearOff || bPlayedDeath) && TimeOfDeath > 0 && `TimeSince(TimeOfDeath) > 0.75 )
	{
		return;
	}

    // Enable alternate bone weighting and gore skeleton
	GoreManager = KFGoreManager(WorldInfo.MyGoreEffectManager);
	if( GoreManager != none && GoreManager.AllowHeadless() )
	{
		if( !bIsGoreMesh && !bDisableHeadless )
		{
			SwitchToGoreMesh();
		}
	}

	// Apply mutilation gore only if we were able to successfully switch to the gore mesh
	if( bIsGoreMesh && GoreManager != none )
	{
        BoneName = HitZones[HZI_Head].BoneName;
		GoreManager.CrushBone( self, BoneName );
        SoundGroupArch.PlayHeadPopSounds( self, mesh.GetBoneLocation(BoneName) );
		HitZones[HZI_Head].bPlayedInjury = true;
	}

	// Play headshot effects regardless of dismemberment, because the user deserves to see
	// their FX even if their gore settings do not allow dismemberment.
	SpawnHeadShotFX(KFPlayerReplicationInfo(HitFxInfo.DamagerPRI));
}

/** Dismember this hit zone if it's not dismembered already
* InDmgType and HitDirection are only ever used on the client after a death shot
*/
simulated function bool PlayDismemberment(int InHitZoneIndex, class<KFDamageType> InDmgType, optional vector HitDirection)
{
	local KFGoreManager GoreManager;
	local name BreakBoneName;

	// Bail out if the hit zone has already been dismembered
	if( HitZones[InHitZoneIndex].bPlayedInjury )
	{
		return false;
	}

	// This hit zone was injured (see CanInjureHitZone), but shouldn't be dismembered
	if ( !InDmgType.static.CanDismemberHitZone( HitZones[InHitZoneIndex].ZoneName ) )
	{
		return false;
	}

    // Enable alternate bone weighting and gore skeleton
	GoreManager = KFGoreManager(WorldInfo.MyGoreEffectManager);
	if( GoreManager != none && GoreManager.AllowMutilation() )
	{
		if( !bIsGoreMesh )
		{
			SwitchToGoreMesh();
		}

	    // Apply mutilation gore only if we were able to successfully switch to the gore mesh
		if( bIsGoreMesh )
		{
			// Get the bone to dismember from the hit zone
			BreakBoneName = HitZones[InHitZoneIndex].BoneName;
			// If we're dead, allow damage type to override the bone
			if ( Health <= 0 && !IsZero(HitDirection) )
			{
				InDmgType.static.GetBoneToDismember(self, HitDirection, HitZones[InHitZoneIndex].ZoneName, BreakBoneName);
			}
			// Dismember

			GoreManager.CauseDismemberment(self, BreakBoneName, InDmgType);
			if (InHitZoneIndex == HZI_HEAD)
			{
				SpawnHeadShotFX(KFPlayerReplicationInfo(HitFxInfo.DamagerPRI));
			}
			PlayHitZoneGoreSounds(BreakBoneName, mesh.GetBoneLocation(BreakBoneName));
			HitZones[InHitZoneIndex].bPlayedInjury = true;

			// If we're still alive (non-ragdoll), start partial physics ragdoll
			// Note: bPlayedDeath may not be set yet on client, so use Health
			if ( Health > 0 && bHasBrokenConstraints )
			{
				InitPartialKinematics();
			}
			return true;
		}
	}
	return false;
}

/** Apply damage to a specific zone (useful for gore effects) */
function TakeHitZoneDamage(float Damage, class<DamageType> DamageType, int HitZoneIdx, vector InstigatorLocation)
{
	local float HeadHealthPercentage;

	if (HitZoneIdx > HitZones.Length)
	{
		return;
	}

	Super.TakeHitZoneDamage(Damage, DamageType, HitZoneIdx, InstigatorLocation);

	// When GoreHealth <= 0, check to see if this weapon can dismember limbs
	if ( HitZones[HitZoneIdx].GoreHealth <= 0 && CanInjureHitZone(DamageType, HitZoneIdx) )
	{
		HitZoneInjured(HitZoneIdx);
	}

	// Handle head injuries
	if ( HitZoneIdx == HZI_Head )
	{
		// Based on head health, calculate number of head chunks we're allowed to remove
		if( !bPlayedDeath && !bIsHeadless && !bTearOff )
		{
			HeadHealthPercentage = GetHeadHealthPercent();
			if( HeadHealthPercentage > 0.5 )
			{
				MaxHeadChunkGoreWhileAlive = 1;
			}
			else if ( HeadHealthPercentage > 0.25 )
			{
				MaxHeadChunkGoreWhileAlive = 2;
			}
			else if ( HeadHealthPercentage > 0.0 )
			{
				MaxHeadChunkGoreWhileAlive = 3;
			}
		}
	}
}

/** Returns the percentage of head health remaining on this zed */
function float GetHeadHealthPercent()
{
	local float HeadHealth, HeadHealthMax;

	HeadHealth = float(HitZones[HZI_Head].GoreHealth);
	HeadHealthMax = float(HitZones[HZI_Head].MaxGoreHealth);

	return HeadHealth / HeadHealthMax;
}

/** Called by KFPawnAnimInfo when determining whether an attack can be performed */
simulated function bool ShouldPlayHeadlessMeleeAnims()
{
	return bIsHeadless || bEmpPanicked;
}

/** Generally used to determine which/whether dialog/voice events should be played */
simulated event bool HasMouth()
{
	if( !bHasBrokenConstraints )
	{
		return true;
	}

	return !Mesh.IsBrokenConstraint( 'head' ) && !Mesh.IsBoneHidden( Mesh.MatchRefBone('gore_jaw') );
}

/** Breaks all joint constraints using dependent gore system */
simulated function ForceBreakAllConstraints()
{
	local int i;
	local KFGoreManager GoreManager;

	bHasBrokenConstraints = TRUE;

	// Enable alternate bone weighting and gore skeleton
	GoreManager = KFGoreManager(WorldInfo.MyGoreEffectManager);
	if( GoreManager == none )
	{
		return;
	}

	if( GoreManager.AllowMutilation() )
	{
		if( !bIsGoreMesh )
		{
			SwitchToGoreMesh();
		}

		for( i = 0; i < CharacterMonsterArch.GoreJointSettings.length; i++ )
		{
			if ( !CharacterMonsterArch.GoreJointSettings[i].bNonBreakableJoint )
			{
				GoreManager.BreakConstraint( self, CharacterMonsterArch.GoreJointSettings[i].HitBoneName );
			}
		}
	}
}

function NotifyMeleeAttackFinished();

/** Checks if we're able to reduce or restore our collision size if we're going through
*  a choke point and we have a large collision cylinder */
simulated function ChokePointTimer()
{
	if( !IsTimerActive(nameof(ChokePointTimer)) )
	{
		SetTimer(0.3f, true, nameof(ChokePointTimer), self);
	}

	if( CurrentChokePointTrigger != none )
	{
		// Check if we want to restore our collision
		if( CurrentChokePointTrigger.CanRestoreChokeCollision(self) )
		{
			// If our enemy has entered the choke point and we can fit in the geometry, retore our collision
			if( CylinderComponent.CollisionRadius < CylinderComponent.default.CollisionRadius
					 && !CheckEncroachingWorldGeometry() )
			{
				SetChokePointCollision(false);
			}
		}
		// if our collision is too large to fit through this chokepiont, reduce it
		else if( CylinderComponent.CollisionRadius > CurrentChokePointTrigger.MaxCollisionRadius )
		{
			SetChokePointCollision(true);
		}
	}
	// if we are out of a chokepoint and can restore our collision, do so
	else if( !CheckEncroachingWorldGeometry() )
	{
		// Only restore collision if it's been reduced
		if( CylinderComponent.CollisionRadius < CylinderComponent.default.CollisionRadius )
		{
			SetChokePointCollision(false);
		}
		ClearTimer(nameof(ChokePointTimer), self);
	}
}

event SetDamageInflation(float NewInflation)
{
    RepDamageInflateParam = FloatToByte(NewInflation);
    SetHeadScale(1.0 + (GetCurrentInflation() / 2.0), CurrentHeadScale);
    HandleDamageInflation();
}

simulated function float GetCurrentInflation()
{
	local float CurrentInflation;
	CurrentInflation = FClamp(ByteToFloat(RepInflateMatParams.RepInflateMatParam) + ByteToFloat(RepInflateMatParams.RepInflateMatParam) - ByteToFloat(RepBleedInflateMatParam), -1.0, 1.0);
	//`log("*** Inflation" @ CurrentInflation);
    //RepInflateMatParam - From microwave affliction
    //RepDamageInflateParam - From modes where gametype modifies size (Shrinky Dinky, Beefcake, etc)
    //RepBleedInflateMatParam - From bleed affliction, set to negative here so we don't lose precision in byte conversion
    return CurrentInflation;
}

simulated function HandleDamageInflation()
{
    if ( WorldInfo.NetMode != NM_DedicatedServer )
    {
        UpdateVisualInflation(GetCurrentInflation() * 2.0);
    }
}

simulated function UpdateBleedIncapFX()
{
	local float CurrentStrength;
	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		CurrentStrength = ByteToFloat(RepBleedInflateMatParam);
		//We've gone past the threshold, create a PSC
		if ((CurrentStrength != 0 && IsAliveAndWell()) && BleedIncapPSC == none)
		{
			BleedIncapPSC = WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(BleedIncapFX, Mesh, class'KFSM_Stunned'.default.DazedFXSocketName, true);
			if (BleedIncapPSC != none)
			{
				BleedIncapPSC.SetAbsolute(false, true, false);
				BleedIncapPSC.SetRotation(rotator(vect(0, 0, 1)) + class'KFSM_Stunned'.default.DazedFXRelativeRotation);
			}
		}
		//We've underrun the threshold, remove PSC
		else if ((CurrentStrength == 0 || !IsAliveAndWell()) && BleedIncapPSC != none)
		{
			BleedIncapPSC.DeactivateSystem();
			DetachComponent(BleedIncapPSC);
			BleedIncapPSC = none;
		}
	}
}

private final simulated function SpawnHeadShotFX(KFPlayerReplicationInfo DamagerPRI)
{
	local KFPlayerController KFPC;
	local HeadshotEffect SHeadshotEffect;
	local vector SpawnVector;

	if (DamagerPRI != none)
	{
		if (WorldInfo.NetMode != NM_DedicatedServer)
		{
			KFPC = KFPlayerController(WorldInfo.GetALocalPlayerController());

			if (KFPC == none || (KFPC.bHideRemotePlayerHeadshotEffects && DamagerPRI != KFPC.PlayerReplicationInfo))
			{
				return;
			}
			SHeadshotEffect = class'KFHeadShotEffectList'.static.GetUnlockedHeadshotEffect(DamagerPRI.GetHeadShotEffectID());
			if (SHeadshotEffect.Id != INDEX_NONE && SHeadshotEffect.EffectPS != none)
			{
				Mesh.GetSocketWorldLocationAndRotation(class'KFSM_Stunned'.default.DazedFXSocketName, SpawnVector);
				WorldInfo.MyEmitterPool.SpawnEmitter(SHeadshotEffect.EffectPS, SpawnVector);
				HeadShotAkComponent.PlayEvent(SHeadshotEffect.HeadshotSoundEffect, true, true);
			}
		}
	}
}

/*********************************************************************************************
 * @name	Ephemeral Stats tracking
********************************************************************************************* */
static function bool IsLargeZed(){ return default.bLargeZed; }

static event bool IsABoss(){ return false; }

/*********************************************************************************************
 * @name	Perk related
********************************************************************************************* */
simulated event UpdateSpottedStatus();
static function bool IsStalkerClass(){ return default.bIsStalkerClass; }
static function bool IsCrawlerClass(){ return default.bIsCrawlerClass; }
static function bool IsFleshpoundClass(){ return default.bIsFleshpoundClass; }
static function bool IsClotClass(){ return default.bIsClotClass; }
static function bool IsBloatClass(){ return default.bIsBloatClass; }

function float GetPerkDoTScaler( optional Controller InstigatedBy, optional class<KFDamageType> KFDT )
{
	local KFPlayerController KFPC;
	local KFPerk InstigatorPerk;
	local float DoTScaler;

	DoTScaler = 1.f;

	if( InstigatedBy != none )
	{
		KFPC = KFPlayerController(InstigatedBy);
		if( KFPC != none )
		{
			InstigatorPerk = KFPC.GetPerk();
			if( InstigatorPerk != none )
			{
				DoTScaler += InstigatorPerk.GetDoTScalerAdditions(KFDT);
			}
		}
	}

	return DoTScaler;
}

/*********************************************************************************************
 * @name	Overhead Debug Text
********************************************************************************************* */

/**
 * Sets debug text rendering
 * @param	bTurnOn	true to enable, false to disable over-NPC-head debug text rendering
 */
function SetDebugTextRendering( bool bTurnOn )
{
	local PlayerController PC;
	local KFHUDBase KFHud;

	bDebug_DrawOverheadInfo	= bTurnOn;

	// final local player's hud object
	ForEach LocalPlayerControllers(class'PlayerController', PC)
	{
		KFHud = KFHUDBase(PC.MyHUD);
	}

	if ( KFHud != None )
	{
		// Add self to player HUD PostRenderedActor list
		KFHud.SetPostRenderingFor(bTurnOn, self);
	}
}

/** Called by HUD for actors in HUD's PostRenderedActor list */
simulated event PostRenderFor( PlayerController PC, Canvas Canvas, vector CameraPosition, vector CameraDir )
{
	local KFHUDBase PCHUD;
	local bool bShowAllCategories;
	local vector2d ScreenPos;

	PCHUD = KFHUDBase(PC.myHUD );

    if( PCHUD.ShouldDisplayDebug('All') || PCHUD.ShouldDisplayDebug('AllVerbose') )
	{
		bShowAllCategories = true;
	}

	if( MyKFAIC != none )
	{
		if( bShowAllCategories || PCHUD.ShouldDisplayDebug('AIMovement') || PCHUD.ShouldDisplayDebug('AIPathing') )
		{
            MyKFAIC.DrawDebugOverheadMovementPhaseData( PCHUD, ScreenPos );
        }
		if( bShowAllCategories || PCHUD.ShouldDisplayDebug('BehaviorTree') )
		{
            MyKFAIC.DrawBehaviorTreeIconOverhead( PCHUD );
        }
	}

	if( PC != none && PC.myHUD != none && bDebug_DrawOverheadInfo )
	{
		// Note: HUD type will either be KFHUDBase or KFDebugCameraHUD (for ToggleDebugCamera mode) which is a KFHDUBase subclass.
		// ...will need to make sure any other similar code works for both types.
		PCHUD = KFHUDBase(PC.myHUD );
		if( PCHUD != none )
		{
			DrawDebugOverheadText( PCHUD, ScreenPos );
		}
	}
	else if( PC != none && PC.myHUD != none && bDebug_DrawSprintingOverheadInfo )
	{
		PCHUD = KFHUDBase(PC.myHUD );
		if( PCHUD != none )
		{
			DrawDebugOverheadSprintingText( PCHUD );
		}
	}
}

function DrawDebugOverheadText( KFHUDBase HUD, Out Vector2d ScreenPos )
{
	local Texture2D			Icon;
	local PlayerController	PC;
	local Canvas			Canvas;
	local Vector			CameraLoc, ScreenLoc;
	local Rotator			CameraRot;
	local float				X, Y;
	local float				DOT;
	local array<string>     OverheadTexts;
	local array<Color>      OverheadColors;
	local int i;

	if( !IsAliveAndWell() )
	{
		return;
	}

	Canvas = HUD.Canvas;
	ScreenLoc = Canvas.Project( Location + vect(0,0,1) * GetCollisionHeight() * 1.5f );
	if( ScreenLoc.X < 0 || ScreenLoc.X >= HUD.Canvas.ClipX || ScreenLoc.Y < 0 && ScreenLoc.Y >= HUD.Canvas.ClipY )
	{
		return;
	}

	PC = HUD.PlayerOwner;
	Canvas.SetDrawColor(0,255,64);
	OverheadColors[OverheadColors.Length] = MakeColor(0,255,64);

	PC.GetPlayerViewPoint( CameraLoc, CameraRot );
	Dot = vector( CameraRot ) dot ( Location - CameraLoc );
	if( Dot < 0.5f )
	{
		return;
	}
	// Draw Icon (need some unique Zed icons)
	Icon = Texture2D'ENG_EditorResources_TEX.AI.S_AI';
	if (Icon != None)
	{
		Canvas.SetPos( ScreenLoc.X - Icon.SizeX / 2, ScreenLoc.Y - Icon.SizeY / 2, ScreenLoc.Z );
		Canvas.DrawTexture( Icon, 1.f );
		X = ScreenLoc.X + Icon.SizeX/2 + 5;
		Y = ScreenLoc.Y - Icon.SizeY/2;
	}
	else
	{
		X = ScreenLoc.X;
		Y = ScreenLoc.Y;
	}

	if( ScreenPos.X == 0 && ScreenPos.Y == 0 )
	{
        Canvas.SetPos( X, Y );
	}
	else
	{
        Canvas.SetPos( ScreenPos.X, ScreenPos.Y );
	}

	Canvas.Font = class'Engine'.Static.GetSmallFont();

    GetOverheadDebugText( HUD, OverheadTexts, OverheadColors );

	// Draw the AI Command info, etc
    if( MyKFAIC != none )
	{
		MyKFAIC.GetCommandStack( HUD, OverheadTexts, OverheadColors );
	}

	for (i = 0; i < OverheadTexts.length; i++)
	{
		// Set custom color if it exists
        if( OverheadColors[i] != MakeColor(0,0,0,0) )
		{
            Canvas.SetDrawColor(OverheadColors[i].R, OverheadColors[i].G, OverheadColors[i].B, 255);
		}
		else
		{
            Canvas.SetDrawColor(0, 255, 64, 255);
		}

        Canvas.DrawText(OverheadTexts[i]);
	}

	ScreenPos.X = Canvas.CurX;
	ScreenPos.Y = Canvas.CurY;

	if( HUD.ShouldDisplayDebug('AIMovement') )
	{
	   DrawDebugSphere( Location - vect(0,0,1) * (GetCollisionHeight() - MaxStepHeight), 8, 10, 255, 255, 0, FALSE); // Yellow = MaxStepHeight
	   DrawDebugSphere( Location + vect(0,0,1) * MaxJumpHeight, 15, 10, 0, 255, 0, FALSE); // Green = MaxJumpHeight
	}

}

function DrawDebugOverheadSprintingText( KFHUDBase HUD )
{
	local Texture2D			moveTypeIcon;
	local PlayerController	plyCtrl;
	local Canvas			displayCanvas;
	local Vector			plyCameraLoc, plyScreenLoc;
	local Rotator			plyCameraRot;
	local String			displayStr;
	local float				displayX, displayY;
	local float				infrontDOT;
	local Color			    newTextColor;

	if( !IsAliveAndWell() )
	{
		return;
	}

	displayCanvas = HUD.Canvas;
	plyScreenLoc = displayCanvas.Project( Location + vect(0,0,1) * GetCollisionHeight() * 1.5f );
	if( plyScreenLoc.X < 0 || plyScreenLoc.X >= HUD.Canvas.ClipX || plyScreenLoc.Y < 0 && plyScreenLoc.Y >= HUD.Canvas.ClipY )
	{
		return;
	}

	plyCtrl = HUD.PlayerOwner;
	displayCanvas.SetDrawColor(255,255,255);

	plyCtrl.GetPlayerViewPoint( plyCameraLoc, plyCameraRot );
	infrontDOT = vector( plyCameraRot ) dot ( Location - plyCameraLoc );
	if( infrontDOT < 0.5f )
	{
		return;
	}

	if( bDebug_UseIconForShowingSprintingOverheadInfo )
	{
		if( bIsSprinting )
		{
			moveTypeIcon = MyKFAIC.MyAIDirector.GetDebugIsSprintingIcon();
		}
		else
		{
			moveTypeIcon = MyKFAIC.MyAIDirector.GetDebugIsWalkingIcon();
		}
	}
	else
	{
		moveTypeIcon = none;
		if( bIsSprinting )
		{
			displayStr = "S";
			newTextColor = class'HUD'.default.RedColor;
		}
		else
		{
			displayStr = "W";
			newTextColor = class'HUD'.default.GreenColor;
		}
	}


	if (moveTypeIcon != None)
	{
		displayCanvas.SetPos( plyScreenLoc.X - moveTypeIcon.SizeX / 2, plyScreenLoc.Y - moveTypeIcon.SizeY / 2, plyScreenLoc.Z );
		displayCanvas.DrawTexture( moveTypeIcon, 1.f );
		displayX = plyScreenLoc.X + moveTypeIcon.SizeX/2 + 5;
		displayY = plyScreenLoc.Y - moveTypeIcon.SizeY/2;
	}
	else
	{
		displayX = plyScreenLoc.X - GetCollisionRadius();
		displayY = plyScreenLoc.Y;
	}
	displayCanvas.SetPos( displayX, displayY );


	if( Len(displayStr) > 0 )
	{
		displayCanvas.Font = MyKFAIC.MyAIDirector.GetAiDebugScreenLargeFont();
		class'KFAIController'.static.DrawDebugText( HUD, displayStr, newTextColor );
	}
}

simulated function GetOverheadDebugText( KFHUDBase HUD, out array<string> OverheadTexts, out array<Color> OverheadColors )
{
	local string DebugText;
	local KFGameInfo KFGI;
	local float HealthMod;
	local float HeadHealthMod;
	local bool bShowAll, bShowAllVerbose;

	if( HUD.ShouldDisplayDebug('All') )
	{
		bShowAll = true;
	}

	if( HUD.ShouldDisplayDebug('AllVerbose') )
	{
		bShowAll = true;
        bShowAllVerbose = true;
	}

    KFGI = KFGameInfo(WorldInfo.Game);
	if ( KFGI != none )
	{
        KFGI.DifficultyInfo.GetAIHealthModifier(self, KFGI.GetModifiedGameDifficulty(), KFGI.GetLivingPlayerCount(), HealthMod, HeadHealthMod);
	    if( bShowAllVerbose || HUD.ShouldDisplayDebug('ZedHealthVerbose') )
        {
    	    DebugText = " Health: "$Health
                $" HeadHealth: "$HitZones[HZI_HEAD].GoreHealth$"\n"
    			$" Starting Health: "$HealthMod*default.Health
    			$" Starting HeadHealth: "$HeadHealthMod*Default.HitZones[HZI_HEAD].GoreHealth$"\n"
    			$" Health Modifier: "$HealthMod
    			$" Default Health: "$default.Health
    			$" Default HeadHealth: "$Default.HitZones[HZI_HEAD].GoreHealth;
		}
	    else if( bShowAll || HUD.ShouldDisplayDebug('ZedHealth') )
        {
    	    DebugText = " Health: "$Health
                $" HeadHealth: "$HitZones[HZI_HEAD].GoreHealth
                $" HeadHealth %: "$(HitZones[HZI_HEAD].GoreHealth/(HeadHealthMod*Default.HitZones[HZI_HEAD].GoreHealth) * 100);
		}
	}

    OverheadTexts[OverheadTexts.Length] = DebugText;

    if( bShowAll || HUD.ShouldDisplayDebug('AITargeting') )
    {
		if( MyKFAIC != none )
		{
    	    DebugText = "---------- AI Targeting ----------\n";

    		if ( MyKFAIC.Enemy != None )
    		{
    			 DebugText = DebugText@"ENEMY: "$MyKFAIC.Enemy.GetHumanReadableName()$" Enemy Dist: "$VSize(MyKFAIC.Enemy.Location - Location)$"\n";
    		}
    		else
    		{
    			DebugText = DebugText@"ENEMY: NO Enemy "$"\n";
    		}


    		if( MyKFAIC.Focus != none )
    		{
    			DebugText = DebugText@"FOCUS: "$MyKFAIC.Focus$"\n";
    			DrawDebugLine(Mesh.GetBoneLocation(HeadBoneName), MyKFAIC.Focus.Location, 255, 255, 0, FALSE);  // Yellow = focus
    		}
    		if( MyKFAIC.GetFocalPoint() != vect(0,0,0) )
    		{
    			DrawDebugLine(Mesh.GetBoneLocation(HeadBoneName), MyKFAIC.GetFocalPoint(), 255, 255, 0, FALSE);  // Yellow = focal point
    		}
            OverheadTexts[OverheadTexts.Length] = DebugText;
		}
	}

    if( bShowAll || HUD.ShouldDisplayDebug('AIMovement') )
    {
	    DebugText = "---------- AI MOVEMENT ----------\n";
	    DebugText = DebugText$"Velocity: "$VSize(Velocity)$" X: "$Velocity.X$" Y: "$Velocity.Y$" Z: "$Velocity.Z$" UU/S, "$VSize(Velocity)/100$"\n";
	    DebugText = DebugText$"Acceleration: "$VSize(Acceleration)$" X: "$Acceleration.X$" Y: "$Acceleration.Y$" Z: "$Acceleration.Z$" Physics: "$GetPhysicsName()$"\n";
	    //DebugText = DebugText$"SuperSpeed: "$IsUsingSuperSpeed()$" LastLOSOrRelevantTime: "$`TimeSince(LastLOSOrRelevantTime)$" LastRenderTime: "$`TimeSince(Mesh.LastRenderTime)$"\n";
	    DebugText = DebugText$"SuperSpeed: "$IsUsingSuperSpeed()$" LastLOSOrRelevantTime: "$`TimeSince(LastLOSOrRelevantTime)$" LastRenderTime: "$`TimeSince(LastRenderTime)$"\n";
		if( MyKFAIC != none )
		{
			if( MyKFAIC.bPreparingMove )
			{
				DebugText = DebugText@"bPreparingMove:"$MyKFAIC.bPreparingMove;
			}

			//DebugText = DebugText@"AICommand: "$MyKFAIC.GetActiveCommand();
		}
        OverheadTexts[OverheadTexts.Length] = DebugText;
	}
}

/**
 * Dialog
 **/

/** Returns (hardcoded) dialog event ID for when players kills this zed type */
function int GetKillerDialogID()
{
	return 65;//KILL_Generic
}

/** Returns (hardcoded) dialog event ID for when players spots this zed type */
function int GetSpotterDialogID()
{
	return 125;//SPOTZ_Generic
}

function UpdateDeadHorseStreak( bool bStillActive)
{
	if( bStillActive )
    {
        DeadHorseHitStreakAmt++;
    }
    else
    {
        DeadHorseHitStreakAmt = 1;
    }

    LastDeadHorseHitTime = WorldInfo.TimeSeconds;
}

/** Returns (hardcoded) trader advice dialog ID */
static function int GetTraderAdviceID()
{
	return -1;
}

/** Play sounds when jumping and landing */
function PlayLeapedDialog();
function PlayLandedDialog();

function MotivatePlayerToAttack( float Percentage, class<DamageType> AntiGriefDamageTypeClass )
{
    local PlayerController PC;

    PC = PlayerController(Controller);
    if( PC != none && WorldInfo.TimeSeconds - LastAttackHumanWarningTime > 9 )
    {
        PC.ReceiveLocalizedMessage( class'KFLocalMessage_Priority', GMT_AttackHumanPlayers );
        LastAttackHumanWarningTime = WorldInfo.TimeSeconds;
    }

    TakeDamage( int(float(HealthMax) * 0.05f), none, Location + vRand()*5.f, vRand(), AntiGriefDamageTypeClass );
}

/*********************************************************************************************
 * @name    UI / Localization
 ********************************************************************************************* */
/**Looks up and returns localized name */
static function string GetLocalizedName()
{
	local string MonsterName;

	//check if we have a seasonal variant
	MonsterName = Localize("Zeds", String(default.LocalizationKey) $ GetSeasonalLocalizationSuffix(), "KFGame");

	//Has a question mark in it, which would indicate failure. return default.
	if (InStr(MonsterName, "?") >= 0)
	{
		MonsterName = Localize("Zeds", String(default.LocalizationKey), "KFGame");
	}

    return MonsterName;
}

static function string GetSeasonalLocalizationSuffix()
{
	//Remove any year information, just get 1s digit
	switch (class'KFGameEngine'.static.GetSeasonalEventID() % 10)
	{
	case SEI_Spring:
		return "_Spring";
	case SEI_Summer:
		return "_Summer";
	case SEI_Fall:
		return "_Fall";
	case SEI_Winter:
		return "_Winter";
	default:
		return "";
	}

	return "";
}

/*********************************************************************************************
* @name   Armor
********************************************************************************************* */

function ZedExplodeArmor(int ArmorZoneIdx, name ArmorZoneName)
{
	if (ArmorInfo != none)
	{
		ArmorInfo.ExplodeArmor(ArmorZoneIdx);
	}
}

/*********************************************************************************************
* @name   Armor
********************************************************************************************* */
server reliable function AddParasiteSeed(KFProjectile Proj)
{
	local int i;

	if (Role < ROLE_AUTHORITY)
		return;

	if (ParasiteSeeds.Length >= MaxNumSeeds)
	{
		for (i = 0; i < ParasiteSeeds.Length - (MaxNumSeeds-1); ++i)
		{
			ParasiteSeeds[i].Detonate();
		}

		ParasiteSeeds.Remove(0, ParasiteSeeds.Length - (MaxNumSeeds-1));	
	}

	ParasiteSeeds.AddItem(Proj);
}

simulated function SpawnWeakPointVFX()
{
	local int i;
	local ParticleSystemComponent VFXComponent;

	if (WeakPointParticleTemplate != none && WeakPointVFXComponents.Length == 0)
	{
		for (i = 0; i < `TINY_SKULL_MAX_WEAKPOINTS; ++i)
		{
			if (WeakPoints_TS[i].BoneName == '')
				return;
			
			VFXComponent = new(self) class'ParticleSystemComponent';
			VFXComponent.SetTemplate( WeakPointParticleTemplate );
			Mesh.AttachComponent( VFXComponent, WeakPoints_TS[i].BoneName, WeakPoints_TS[i].Offset );
			VFXComponent.ActivateSystem();
			WeakPointVFXComponents.AddItem(VFXComponent);
		}
	}
}

simulated function ServerSpawnWeakPointVFX(array<WeakPoint> WeakPoints)
{
	local int i;

	if (WeakPoints.Length == 0)
		return;

	for (i = 0; i < WeakPoints.Length; ++i)
	{
		WeakPoints_TS[i] = WeakPoints[i];
	}

	if (WorldInfo.NetMode == NM_Standalone)
	{
		SpawnWeakPointVFX();
	}
	else
	{
		bNetDirty = true;
	}
}

/*********************************************************************************************
 * @name   Achievements
 ********************************************************************************************* */

native protected function bool ShouldGrandOnDeathAchievement();
native protected function int GetZedOnDeathAchievement();
native function DisablebOnDeathAchivement();

DefaultProperties
{
	// ---------------------------------------------
	// AI / Navigation
	PeripheralVision=-1.f // 360
	Alertness=1.f
	SightRadius=16384.f
	ControllerClass=class'KFGame.KFAIController_Monster'
	PursuitSpeedScale=1.f
	PathSearchType=PST_Constraint
	AccelConvergeFalloffDistance=400.f
	bAllowAccelSmoothing=false
	MatchEnemySpeedAtDistance=200.f
	MinimumEnemySpeedToMatch=280.f
	bModifyReachSpecCost=true
	bDebug_DrawSprintingOverheadInfo=false

	LedgeCheckThreshold=350.0f
	bDebug_UseIconForShowingSprintingOverheadInfo=true
	CollisionRadiusForReducedZedOnZedPinchPointCollisionState=1

	Begin Object Name=KFPawnSkeletalMeshComponent
		WireframeColor=(R=255,G=255,B=0,A=255)
		bUseAsOccluder=TRUE
	End Object

	// ---------------------------------------------
	// Special Moves
	Begin Object Name=SpecialMoveHandler_0
		SpecialMoveClasses(SM_MeleeAttack)		 =class'KFGame.KFSM_MeleeAttack'
		SpecialMoveClasses(SM_MeleeAttackDoor)	 =class'KFSM_DoorMeleeAttack'
		SpecialMoveClasses(SM_GrappleAttack)		 =class'KFGame.KFSM_GrappleCombined'
		SpecialMoveClasses(SM_Stumble)			 =class'KFGame.KFSM_Stumble'
		SpecialMoveClasses(SM_RecoverFromRagdoll)=class'KFGame.KFSM_RecoverFromRagdoll'
		SpecialMoveClasses(SM_Knockdown)		 =class'KFSM_RagdollKnockdown'
		SpecialMoveClasses(SM_DeathAnim)		 =class'KFSM_DeathAnim'
		SpecialMoveClasses(SM_Stunned)			 =class'KFSM_Stunned'
		SpecialMoveClasses(SM_Frozen)			 =class'KFSM_Frozen'
		SpecialMoveClasses(SM_Taunt)			 =class'KFGame.KFSM_Zed_Taunt'
		SpecialMoveClasses(SM_WalkingTaunt)		 =class'KFGame.KFSM_Zed_WalkingTaunt'
        SpecialMoveClasses(SM_BossTheatrics)	 =class'KFGame.KFSM_Zed_Boss_Theatrics'
	End Object

	IncapSettings(AF_Poison)=(Cooldown=5.0, Duration=5.0,)
	IncapSettings(AF_Microwave)=(Cooldown=5.0, Duration=5.0,)
	IncapSettings(AF_Freeze)=(Cooldown=5.0)
	IncapSettings(AF_Snare)=(Cooldown=5.0, Duration=5.0,)

	// ---------------------------------------------
	// Movement / Physics
	bCanCrouch=false
	AccelRate=+02048.000000
	JumpZ=750.f
	HiddenGroundSpeed=600.f	// same speed for all monsters
	bCanStrafe=true
	MaxJumpHeight=128.f
	MaxTurningRadius=64.f
	BumpDamageType=class'KFDT_NPCBump'
	BumpFrequency=0.5f
	bLimitFallAccel=TRUE
	SpeedAdjustTransitionRate=200.f
	InitialGroundSpeedModifier=1.0

	// ---------------------------------------------
	// Spawning
    MinSpawnSquadSizeType=EST_Small

	// ---------------------------------------------
	// Gameplay
	DifficultySettings=class'KFMonsterDifficultyInfo'

	Begin Object Class=KFMeleeHelperAI Name=MeleeHelper_0
		MaxHitRange=180.f
		BaseDamage=6.f
	End Object
	MeleeAttackHelper=MeleeHelper_0

	bHasExtraSprintJumpVelocity=false
	bCanRage=false
	bCanGrabAttack=false
	bCanMeleeAttack=true
	ReachedEnemyThresholdScale=1.f
	ZedBumpDamageScale=1.f
	HeadlessBleedOutTime=5.f
	ParryResistance=1
	DifficultyDamageMod=1.0
	GameResistancePct=1.f

	//NapalmCheckInterval=0.5f

	// Blocking
	MinBlockFOV=0.1f
	BlockSprintSpeedModifier=0.75f

	bIsStalkerClass=false
	bIsCrawlerClass=false
	bIsFleshpoundclass=false
	bIsClotClass=false
	bIsBloatClass=false

    bDisableGoreMeshWhileAlive=false

    DamageInflationPercent = 1.0
    IntendedDamageInflationPercent = 1.0
    DamageInflationRate=1.0
    RandomColorIdx=-1

	bCanBePinned=true

	// ---------------------------------------------
	// Hit Zones
	HitZones.Empty
	HitZones.Add((ZoneName=head,	  BoneName=Head,		 Limb=BP_Head, GoreHealth=20, DmgScale=1.1, SkinID=1))
	HitZones.Add((ZoneName=neck,	  BoneName=Neck,		 Limb=BP_Head, GoreHealth=20))
	HitZones.Add((ZoneName=chest,     BoneName=Spine2,		 Limb=BP_Torso, GoreHealth=150))
	HitZones.Add((ZoneName=heart,	  BoneName=Spine2,		 Limb=BP_Special, GoreHealth=150))
	HitZones.Add((ZoneName=lupperarm, BoneName=LeftArm,		 Limb=BP_LeftArm, GoreHealth=50))
	HitZones.Add((ZoneName=lforearm,  BoneName=LeftForearm,  Limb=BP_LeftArm, GoreHealth=15))
	HitZones.Add((ZoneName=lhand,     BoneName=LeftForearm,	 Limb=BP_LeftArm, GoreHealth=20))
	HitZones.Add((ZoneName=rupperarm, BoneName=RightArm,	 Limb=BP_RightArm, GoreHealth=50))
	HitZones.Add((ZoneName=rforearm,  BoneName=RightForearm, Limb=BP_RightArm, GoreHealth=15))
	HitZones.Add((ZoneName=rhand,	  BoneName=RightForearm, Limb=BP_RightArm, GoreHealth=20))
	HitZones.Add((ZoneName=stomach,	  BoneName=Spine1,		 Limb=BP_Torso, GoreHealth=150))
	HitZones.Add((ZoneName=abdomen,	  BoneName=Hips,		 Limb=BP_Torso, GoreHealth=150))
	HitZones.Add((ZoneName=lthigh,	  BoneName=LeftUpLeg,	 Limb=BP_LeftLeg, GoreHealth=75))
	HitZones.Add((ZoneName=lcalf,	  BoneName=LeftLeg,		 Limb=BP_LeftLeg, GoreHealth=25))
	HitZones.Add((ZoneName=lfoot,	  BoneName=LeftLeg,		 Limb=BP_LeftLeg, GoreHealth=15))
	HitZones.Add((ZoneName=rthigh,	  BoneName=RightUpLeg,	 Limb=BP_RightLeg, GoreHealth=75))
	HitZones.Add((ZoneName=rcalf,	  BoneName=RightLeg,	 Limb=BP_RightLeg, GoreHealth=25))
	HitZones.Add((ZoneName=rfoot,	  BoneName=RightLeg,	 Limb=BP_RightLeg, GoreHealth=15))

	// Pad the arrays so we can modify them with the live update system if needed
	LiveDamageTypeModifiers.Add(())
	LiveDamageTypeModifiers.Add(())
	LiveDamageTypeModifiers.Add(())
	LiveDamageTypeModifiers.Add(())
	LiveDamageTypeModifiers.Add(())
	LiveDamageTypeModifiers.Add(())
	LiveDamageTypeModifiers.Add(())
	LiveDamageTypeModifiers.Add(())
	LiveDamageTypeModifiers.Add(())
	LiveDamageTypeModifiers.Add(())
	LiveDamageTypeModifiers.Add(())
	LiveDamageTypeModifiers.Add(())
	LiveDamageTypeModifiers.Add(())
	LiveDamageTypeModifiers.Add(())
	LiveDamageTypeModifiers.Add(())
	LiveDamageTypeModifiers.Add(())

	WeakSpotSocketNames.Add(FX_Dazed) // Head

	// List of BodySetups turned to phycsi for arm injury
	ArmPhysicsBoneList=("RightShoulder","RightArm","RightForeArm","RightHand")

	BleedIncapFX=ParticleSystem'FX_Gameplay_EMIT_THREE.FX_Incap_Bleed_01'

	// ---------------------------------------------
	// Animation
	bCanHeadTrack=true

`if(`notdefined(ShippingPC))
	DebugRadarTexture=Texture2D'GP_Debug.SineWaveMarker_TEX';
	`endif
		OnDeathAchievementID = INDEX_NONE

	bKnockdownWhenJumpedOn = True

	// ---------------------------------------------
    // sounds
	Begin Object Class=AkComponent name=SprintAkComponent0
		BoneName=dummy
		bStopWhenOwnerDestroyed=true
		bForceOcclusionUpdateInterval=true
		OcclusionUpdateInterval=0.2f
	End Object
    SprintAkComponent=SprintAkComponent0
    Components.Add(SprintAkComponent0)

	Begin Object Class=AkComponent name=HeadshotAkComponent0
		bStopWhenOwnerDestroyed=false
	End Object
    HeadShotAkComponent=HeadshotAkComponent0
    Components.Add(HeadshotAkComponent0)

	bSprintOverride=false

	VortexAttracionModifier=1.0f
	MaxNumSeeds=1

	ZEDCowboyHatAttachName=HEAD_Attach

	WeakPointParticleTemplate=ParticleSystem'FX_Gameplay_EMIT.FX_Weak_Indicator'
}

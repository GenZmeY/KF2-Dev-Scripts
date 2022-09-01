//=============================================================================
// KFAIController_ZedFleshpound
//=============================================================================
// Base controller for the Fleshpound
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFAIController_ZedFleshpound extends KFAIController_Monster
	native(AI);

/*********************************************************************************************
* Charge Related, this is mostly temporary - only Location & directcharge might be
* necessary
**********************************************************************************************/

/** Last time			charge actor/location was updated */
var float				LastChargeStuckCheckTime;
var vector				LastChargeStuckCheckLocation;
var float				ChargeStuckCheckInterval;
var int					ChargeStuckCount;
var float				ChargeStuckCheckDistance;
var bool				bReadyToBecomeEnraged;
var float				LastKickClotTime;


/*********************************************************************************************
* Combat Related
********************************************************************************************* */

/** Set to true when seeing assigned enemy for the first time - starts frustration timer */
var bool	bSawEnemy;

var instanced KFAIPluginRage_Fleshpound RagePlugin;
var class<KFAIPluginRage_Fleshpound> RagePluginClass;

var array<float> 		SpawnRagedChance;

/*********************************************************************************************
* Debug
********************************************************************************************* */

var bool	bDebugLeaveTargetAngleThreshold;
/** Location of charge actor when info was gathered */
var Vector ChargePivot;

cpptext
{
	virtual void Initialize();
	virtual UBOOL Tick(FLOAT DeltaTime, enum ELevelTick TickType);
	virtual UBOOL ShouldIgnoreNavigationBlockingFor(const AActor* Other);
}

/*********************************************************************************************
* Base
**********************************************************************************************/

event Possess( Pawn inPawn, bool bVehicleTransition )
{
	super.Possess(inPawn, bVehicleTransition);

	DoSpawnRageCheck();
}

native function CleanUp(optional bool bBeingDestroyed);

/** Override to tick plugins */
simulated function Tick( FLOAT DeltaTime )
{
	Super.Tick(DeltaTime);

	if( RagePlugin != none )
	{
		RagePlugin.TickRage();
	}
}

function bool AmIAllowedToSuicideWhenStuck()
{
	return false;
}

/*********************************************************************************************
* Movement
**********************************************************************************************/

/**
 * Testing mostly duplicated from KFAICMC, with additional check for charge. Was going to change this more to make other
 * FleshPound specific considerations
 */
event bool FindNewEnemy()
{
	local Pawn BestEnemy;
	local float BestDist, NewDist;
	local Controller         C;
	local Pawn PotentialEnemy;

	BestEnemy = none;

	if (BestEnemy == none)
	{
		foreach WorldInfo.AllControllers( class'Controller', C )
		{
			if( C.Pawn == none || !C.Pawn.IsAliveAndWell() || Pawn.IsSameTeam( C.Pawn ) ||
				!C.Pawn.CanAITargetThisPawn(self) )
			{
				continue;
			}

			PotentialEnemy = C.Pawn;
			NewDist = VSizeSq( PotentialEnemy.Location - Pawn.Location );

			if( BestEnemy == none )
			{
				BestEnemy = PotentialEnemy;
				BestDist = NewDist;
			}

			else if( BestEnemy != none )
			{
				if( (BestDist > NewDist) || (NumberOfZedsTargetingPawn( PotentialEnemy ) < NumberOfZedsTargetingPawn( BestEnemy )) )
				{
					BestEnemy = PotentialEnemy;
					BestDist = NewDist;
				}
			}
		}
	}

	if( Enemy != none && BestEnemy != none && BestEnemy == Enemy )
	{
		return false;
	}

	if( BestEnemy != none )
	{
		ChangeEnemy( BestEnemy );

		return HasValidEnemy();;
	}

	return false;
}

/** End rage if we hit a target with our attack */
function NotifyMeleeDamageDealt()
{
	super.NotifyMeleeDamageDealt();

	if( RagePlugin != none )
	{
		// unless fp was stumbled (e.g. successful parry), or attacked a door, end rage
		if ( MyKFPawn.SpecialMove != SM_Stumble && MyKFPawn.SpecialMove != SM_MeleeAttackDoor )
		{
			RagePlugin.EndRage();
		}
	}
}

function NotifyTakeHit( Controller InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum )
{
	super.NotifyTakeHit( InstigatedBy, HitLocation, Damage, damageType, Momentum );

	if( RagePlugin != none && InstigatedBy != self )
	{
		RagePlugin.AccumulatedDOT += Damage;
	}
}

event AttitudeStateChanged( name NewState )
{
	if( MyKFPawn == none )
	{
		return;
	}

	switch( NewState )
	{
		case 'Enraged':
			MyKFPawn.SetEnraged( true );
			break;
		case 'Normal':
			//MyBlackBoard.SetWSPropFloat(WSKP_AccumulatedDamage, 0);
			MyKFPawn.SetEnraged( false );
			break;
	}
}

function bool CanEvadeGrenade()
{
	return !IsEnraged() && super.CanEvadeGrenade();
}

/** True if my KFP is enraged */
simulated event bool IsEnraged()
{
	return( MyKFPawn != none && MyKFPawn.IsEnraged() );
}

/** Fleshpounds only sprint when Enraged */
function bool ShouldSprint()
{
	return IsEnraged();
}

/** Called from KFPawn_Monster::SetSprinting() */
function bool CanSetSprinting( bool bNewSprintStatus )
{
	return !bNewSprintStatus || MyKFPawn.IsEnraged();
}

/** Fleshpounds aren't concerned with steering away from other KFPawn_Monster classes */
simulated function StartSteering()
{
}

function RestoreCollisionSize()
{
	Pawn.SetCollisionSize( 36,  Pawn.default.CylinderComponent.CollisionHeight );
}

/*********************************************************************************************
* Sight/Hearing
********************************************************************************************* */

/** Overridden to begin getting frustrated after seeing current enemy */
event SeePlayer( Pawn Seen )
{
	// Start the rage plugin timer (or rage immediately, depending on how long it's been since seeing the player)
	if( !bSawEnemy && Seen == Enemy )
	{
		bSawEnemy = true;
		`AILog( GetFuncName()$" Just saw my enemy for first time, starting RageFrustrationTimer", 'SeePlayer' );
		RagePlugin.StartRageTimer(true);
	}

	super.SeePlayer( Seen );
}

/** Overridden to reset frustration when enemy changes */
event bool SetEnemy( Pawn NewEnemy )
{
	local bool bNewEnemySet;

	bNewEnemySet = super.SetEnemy( NewEnemy );

	// If enemy changed, reset frustration related properties
	if( bNewEnemySet )
	{
		`AILog( GetFuncName()$" Just started targeting a new enemy ("$NewEnemy$"), clearing RageFrustrationTimer", 'SeePlayer' );
		bSawEnemy = false;
		EnableSeePlayer();
		RagePlugin.StartRageTimer();
	}

	return bNewEnemySet;
}

/*********************************************************************************************
* Combat
**********************************************************************************************/

function bool CanAttackDestructibles()
{
	return !IsEnraged() && super.CanAttackDestructibles();
}

/*********************************************************************************************
* Enraged!
********************************************************************************************* */

function DoSpawnRageCheck()
{
	local KFGameInfo KFGI;

	KFGI = KFGameInfo( WorldInfo.Game );

	if(KFGI == none)
	{
		return;
	}

	if(FRand() <= SpawnRagedChance[int(KFGI.GetModifiedGameDifficulty())])
	{
		//FP SMASH!!
        SpawnEnraged();
	}
}

function bool SpawnEnraged()
{
    RagePlugin.DoSpawnRage();
    return true;
}

/** Start up the pre-charge Taunt */
function DoRageTauntAt( optional KFPawn Target )
{
	if( Role == ROLE_Authority )
	{
		`DialogManager.PlaySpotEnragedDialog( MyKFPawn );
	}

	`AILog( GetFuncName()$"() at "$Target, 'Command_Rage' );
	class'AICommand_TauntEnemy'.static.Taunt( self, Enemy, TAUNT_Enraged );
}

/** Notification that the Fleshpound's enraged mode has changed */
function NotifyEnraged( bool bEnraged )
{
	if( CachedAICommandList != none )
	{
		CachedAICommandList.NotifyCombatBehaviorChange( 'Enraged', bEnraged );
	}
	else
	{
		`warn( Pawn$" became enraged with no AICommand!" );
	}
}

/** Frustration mode should not change sprint settings on FP */
function UpdateSprintFrustration( optional byte bForceFrustrationState=255 )
{
}

DefaultProperties
{
	// ---------------------------------------------
	// AI / Navigation
    bCanTeleportCloser=false
	RotationRate=(Pitch=50000,Yaw=50000,Roll=50000)
	SprintWithinEnemyRange=(X=0,Y=1500.f)
	//MinHitWall=1.f = no hitwall
	MinHitWall=-0.42
	ChargeStuckCheckDistance=10.0f
	ChargeStuckCheckInterval=0.25f
	bUseRunOverWarning=true
	MinRunOverSpeed=360.f
	MinRunOverWarningAim=0.85f
	EvadeGrenadeChance=0.6f
	FrustrationThreshold=0

	//DefaultBehavior="FleshpoundMain2"
	//UsedETQQueries[ENQ_EnemySelection]="BaseZedEnemySelection"

	// ---------------------------------------------
	// Combat
	DefaultCommandClass=class'AICommand_Base_Fleshpound'
	bIsProbingMeleeRangeEvents=true
	MeleeCommandClass=class'AICommand_Base_Fleshpound'
	bCanDoHeavyBump=true

	RagePluginClass=class'KFAIPluginRage_Fleshpound'

    // ---------------------------------------------
    // Danger Evasion Settings
    DangerEvadeSettings.Empty

	//Aim Blocks
	DangerEvadeSettings(0)={(ClassName="KFWeap_Rifle_Winchester1894",
								Cooldowns=(0.5, 0.4, 0.3, 0.2), // Normal, Hard, Suicidal, HoE
								BlockChances=(0.1, 0.2, 0.7, 0.85))}
	DangerEvadeSettings(1)={(ClassName="KFWeap_Bow_Crossbow",
								Cooldowns=(0.5, 0.4, 0.3, 0.2), // Normal, Hard, Suicidal, HoE
								BlockChances=(0.1, 0.2, 0.7, 0.85))}
	DangerEvadeSettings(2)={(ClassName="KFWeap_Rifle_M14EBR",
								Cooldowns=(0.5, 0.4, 0.3, 0.2), // Normal, Hard, Suicidal, HoE
								BlockChances=(0.1, 0.2, 0.7, 0.85))}
	DangerEvadeSettings(3)={(ClassName="KFWeap_Rifle_RailGun",
								Cooldowns=(0.5, 0.4, 0.3, 0.2), // Normal, Hard, Suicidal, HoE
								BlockChances=(0.1, 0.2, 0.7, 0.85))}
	DangerEvadeSettings(4)={(ClassName="KFWeap_Bow_CompoundBow",
								Cooldowns=(0.5, 0.4, 0.3, 0.2), // Normal, Hard, Suicidal, HoE
								BlockChances=(0.1, 0.2, 0.7, 0.85))}

	// ---------------------------------------------
	// Debug
	bDebugLeaveTargetAngleThreshold=false
	bNotifyApex=true

	TeleportCooldown=10.0
	HiddenRelocateTeleportThreshold=7.0
	LowIntensityAttackCooldown=5.0

	SpawnRagedChance(`DIFFICULTY_NORMAL)=0.0f
	SpawnRagedChance(`DIFFICULTY_HARD)=0.0f
	SpawnRagedChance(`DIFFICULTY_SUICIDAL)=0.2f //0.5
	SpawnRagedChance(`DIFFICULTY_HELLONEARTH)=0.33f //0.75
}

//=============================================================================
// KFMeleeHelperAI
//=============================================================================
// Manages melee attack related functionality for AI controlled pawns
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Andrew "Strago" Ladenberger
//=============================================================================
class KFMeleeHelperAI extends KFMeleeHelperBase within Actor
	native;

/** The default damage applied to each melee hit **/
var() float						BaseDamage;
/** Default DamageType class */
var() const class<KFDamageType> MyDamageType;
/** How much base physics push force an attack will cause */
var() float						MomentumTransfer;

/** Struct to keep track of the actors we hit with the move and when it happened */
struct native SwipeHitActorData
{
	/** The actor who was hit */
	var transient KFPawn HitActor;
	/** Last time the actor was hit */
	var transient float LastHitTime;
};

/** List of actors hit by a swipe attack (see UpdateStabbedActors) */
var transient array<SwipeHitActorData> SwipedActors;
/** If set, track all swiped actors to prevent giving damage too frequently */
var bool bTrackSwipeHits;

/** Door damage multiplier for player zed (versus) attacks */
var float PlayerDoorDamageMultiplier;
/** Swipe FOV used by player controlled zeds */
var float PlayerControlledFOV;
/** Scale factor for player controlled melee impact camera shake */
var float MeleeImpactCamScale;

/*********************************************************************************************
 * Player ping compensation
 *********************************************************************************************/

struct native DelayedMeleeInfo
{
	var Pawn	Victim;
	var int		Damage;
	var float	Momentum;
	var float	TimeOfDamage;
	var class<KFDamageType> DamageType;
};

/** Cached damage values */
var array<DelayedMeleeInfo> PendingDamage;

/** Upper limit (in ms) for Ping compensation */
var int		MaxPingCompensation;
/** Artificial fudge factor to find the sweet spot for online play */
var float	PingCompensationScale;

cpptext
{
	void TickPingCompensation(AWorldInfo*	WorldInfo);
}

/*********************************************************************************************
 * Common (Public)
 *********************************************************************************************/

/**
 * Deals melee damage to a target actor
 * @param Victim			Target actor to recieve damage
 * @param Damage			Damage to apply if this attack is successful
 * @param HitLocation		Location to apply damage to on the target actor
 * @param MomentumScalar	Momentum transfer to apply if this attack is successful
 * @param DamageType		DamageType to apply if this attack is successful
 */
function ApplyMeleeDamage(Actor Victim, int Damage, optional float InMomentum=1.f, optional class<KFDamageType> InDamageType, optional vector HitLocation)
{
	local vector HitDirection;
	local KFPawn_Monster InstigatorPawn;

	// Make sure we're doing _some_ damage
	Damage = Max(Damage, 1);

	InstigatorPawn = KFPawn_Monster(Instigator);
	if ( InstigatorPawn != none )
	{
		// Notify pawn
		InstigatorPawn.NotifyMeleeDamageDealt();
		
		// Notify AIC.  After TakeDamage so we can review damage results
		if( InstigatorPawn.MyKFAIC != none )
		{
			InstigatorPawn.MyKFAIC.NotifyMeleeDamageDealt();
		}

		// Apply rally boost damage
		Damage = InstigatorPawn.GetRallyBoostDamage( Damage );
	}

	// Bump the hit location so that TakeHitInfo will always replicate
	if ( IsZero(HitLocation) )
	{
		HitLocation = Victim.Location;
		HitLocation.Z += FRand();
	}
	HitDirection = Normal(HitLocation - Instigator.Location);

	// After modifiers are applied, ensure damage is never zero
	Victim.TakeDamage( Damage, Instigator.Controller, HitLocation, HitDirection * InMomentum, InDamageType,, Outer );

	// play camera shake, etc...
	PlayMeleeHitEffects(Victim, HitLocation, HitDirection);

	`log(Victim$"**** Melee attack!  BaseDamage="@BaseDamage@", ModifiedDamage="@Damage, bLogMelee);
}

/** Simplified version of RateMeleeVictim designed for any actor type */
function bool ShouldDealDamageToEnemy(Actor Target, optional float Range=MaxHitRange)
{
	local Vector VectToEnemy, HitLoc, HitNormal;
	local Actor HitActor;
	local TraceHitInfo	HitInfo;
	local vector TraceOffset;

	// Enemy must not be too far
	VectToEnemy = Target.Location - Location;
	if( VSizeSq(VectToEnemy) > Square(Range) )
	{
		return FALSE;
	}

	// must be somewhat facing enemy
	if( Normal(VectToEnemy) dot Vector(Instigator.Rotation) < 0.0f )
	{
		return FALSE;
	}

	// Trace world and block iff block actors is set (ignore CanBecomeDynamic actors)
	HitActor = Trace(HitLoc, HitNormal, Target.Location, Location, false,, HitInfo, TRACEFLAG_Blocking);
	if( HitActor != None && HitInfo.HitComponent != None && HitInfo.HitComponent.BlockActors && (HitActor.bWorldGeometry || HitActor.bGameRelevant) )
	{
		// Try again at the EyeHeight - Both must fail to obstruct damage
		TraceOffset = Instigator.BaseEyeHeight * vect(0,0,1);
		HitActor = Trace(HitLoc, HitNormal, Target.Location + TraceOffset, Location + TraceOffset, false,, HitInfo, TRACEFLAG_Blocking);
		if( HitActor != None && HitInfo.HitComponent != None && HitInfo.HitComponent.BlockActors && (HitActor.bWorldGeometry || HitActor.bGameRelevant) )
		{
			return FALSE;
		}
	}

	return TRUE;
}

/*********************************************************************************************
 * Area Hit Detection
 *********************************************************************************************/

/**
 * Do damage to multiple targets around the character
 * @param Damage			Damage to apply if this attack is successful
 * @param MomentumScalar	Momentum transfer to apply if this attack is successful
 * @param DamageType		DamageType to apply if this attack is successful
 * @param Range				Maximum range for hit detection
 * @param InFOVCosine		Maximum FOV for hit detection.  If 0, allows any angle (360 degrees)
 * @param bPlayersOnly		If true, skip non-player controlled pawns
 */
function bool DoAreaImpact(
			 int				 Damage,
	optional float				 MomentumScalar=1.f,
	optional class<KFDamageType> DamageType=MyDamageType,
	optional float				 Range=MaxHitRange,
	optional float				 InFOVCosine=0.f,
	optional bool				 bPlayersOnly)
{
	local KFPawn KFP;
	local bool bFoundHit;

	// @note - At low ranges CollidingActors (no VisibleCollidingActors) is okay,
	// but AllPawns is constant and much faster 99% of the time.
	foreach WorldInfo.AllPawns( class'KFPawn', KFP, Location, Range )
	{
		if ( bPlayersOnly && !KFP.IsHumanControlled() )
			continue;

        if ( RateMeleeVictim(KFP, Location, Location + Normal(Vector(Instigator.Rotation)) * Range, Range, InFOVCosine) > 0.f )
		{
			ApplyMeleeDamage(KFP, Damage, MomentumScalar, DamageType);
			bFoundHit = true;
		}
	}

	return bFoundHit;
}

/*********************************************************************************************
 * Player (non-AI) zed for versus mode
 *********************************************************************************************/

/** 
 * Default hit detection for player controlled zeds in Versus mode 
 * @return TRUE if Pawn (not world) was hit for use by zed-time
 */
function bool DoPlayerControlledImpact(int Damage,
	optional float				 MomentumScalar=1.f,
	optional class<KFDamageType> DamageType=MyDamageType)
{
	local bool bHitPawn;

	bHitPawn = DoAreaImpact(Damage, MomentumScalar, DamageType,, PlayerControlledFOV);
	if ( !bHitPawn )
	{
		DoPlayerWorldTrace(Damage, MomentumScalar, MyDamageType);
	}

	return bHitPawn;
}

/** 
 * A simplified forward trace to hit world geometry and other destructibles.
 * @see also KFMeleeHelperWeapon::DoWeaponInstantTrace()) 
 */
function bool DoPlayerWorldTrace(int Damage,
	optional float				 MomentumScalar=1.f,
	optional class<KFDamageType> DamageType=MyDamageType)
{
	local vector			StartTrace, EndTrace;
	local vector			HitLocation, HitNormal;
	local Actor				HitActor;

	StartTrace	= GetMeleeStartTraceLocation();
	EndTrace	= StartTrace + vector(GetMeleeAimRotation()) * MaxHitRange;

 	// There is no weapon to trace from, so we added a custom non-recursive trace that hits
 	// actors (e.g. destructibles) and world geoemtry (e.g. doors), but not pawns.
	HitActor = TraceNoPawns(HitLocation, HitNormal, EndTrace, StartTrace);

	if( HitActor != None )
	{
		if ( HitActor.bCanBeDamaged && HitActor.IsA('KFDoorActor') )
		{
			Damage *= PlayerDoorDamageMultiplier;
		}
		ApplyMeleeDamage(HitActor, Damage, MomentumScalar, DamageType, HitLocation);
		return true;
	}

	return false;
}

/**
 * Replicate (serverside hit detection) camera shake for human instigator 
 */
simulated function PlayMeleeHitEffects(Actor Target, vector HitLocation, vector HitDirection, optional bool bShakeInstigatorCamera=true)
{
	Super.PlayMeleeHitEffects(Target, HitLocation, HitDirection);

	// local player controlled effects
	if( bShakeInstigatorCamera && Instigator.IsHumanControlled() )
	{
		PlayerController(Instigator.Controller).ClientPlayCameraShake(MeleeImpactCamShake, MeleeImpactCamScale, true, CAPS_UserDefined, rotator(-HitDirection));
	}
}

/*********************************************************************************************
 * Anim Notify Handling
 *********************************************************************************************/

/** Notification called from KFAnimNotify_MeleeImpact. */
function MeleeImpactNotify(KFAnimNotify_MeleeImpact Notify)
{
	local KFAIController KFAIC;
	local float DoorDamageScale;
	local float MomentumScalar;
	local bool bDealtDmg;
	local class<KFDamageType> CurrentDamageType;

	if ( Instigator == None || (Instigator.Role < ROLE_Authority && !Instigator.IsLocallyControlled()) )
	{
		return; // AutomonmousProxy in Versus, but doesn't work with CSHD
	}

	MomentumScalar = Notify.bCanDoKnockback ? Notify.MomentumTransferScale * MomentumTransfer : 1.f;

	KFAIC = KFAIController(Instigator.Controller);
	// TODO: Get more accurate target from MeleeAttack command

	CurrentDamageType = Notify.CustomDamageType != none ? Notify.CustomDamageType : MyDamageType;

	if( KFAIC != none && (KFAIC.DoorEnemy != none || KFAIC.ActorEnemy != none) )
	{
		// Scale door damage based on number of attackers
		if( KFAIC.DoorEnemy != none )
		{
			DoorDamageScale = KFAIC.DoorEnemy.GetAIDoorDamageScale();
		}
		bDealtDmg = CheckEnemyImpact((Notify.DamageScale * BaseDamage) * DoorDamageScale, MomentumScalar, CurrentDamageType);
	}
	else if ( Notify.bDoAreaDamage )
	{
		bDealtDmg = DoAreaImpact(Notify.DamageScale * BaseDamage, MomentumScalar, CurrentDamageType);
	}
	else if ( Notify.bDoSwipeDamage )
	{
		bDealtDmg = DoSwipeImpact(Notify.DamageScale * BaseDamage, Notify.SwipeDirection, MomentumScalar,,, CurrentDamageType);
	}
	else if( Instigator.IsHumanControlled() )
	{
		// Before you ask, yes you can be a human in the "AI" helper.  This is a simplification for third person player
		// zeds in versus mode.  For Area/Swipe the same hit detection will work (ish) for both.
		bDealtDmg = DoPlayerControlledImpact(Notify.DamageScale * BaseDamage, MomentumScalar, CurrentDamageType);
	}
	else
	{
		bDealtDmg = CheckEnemyImpact(Notify.DamageScale * BaseDamage, MomentumScalar, CurrentDamageType, Notify.AttackReachOverride > 0.f ?  Notify.AttackReachOverride : MaxHitRange );
	}

	if ( bDealtDmg && Notify.bCanCauseZedTime )
	{
		KFGameInfo(WorldInfo.Game).DramaticEvent(0.03);
	}
}

/** Do damage directly to AI Controller Enemy
 * @param Damage			Damage to apply if this attack is successful
 * @param MomentumScalar	Momentum transfer to apply if this attack is successful
 * @param DamageType		DamageType to apply if this attack is successful
 * @param Range				Maximum range for hit detection
 */
protected function bool CheckEnemyImpact(int Damage,
	float MomentumScalar,
	class<KFDamageType> InDamageType=MyDamageType,
	optional float AttackReachOverride=MaxHitRange)
{
	local KFAIController AIC;

	AIC = KFAIController(Instigator.Controller);

	if ( AIC != None )
	{
		if ( AIC.Enemy != None && ShouldDealDamageToEnemy(AIC.Enemy, AttackReachOverride) )
		{
			ResolvePawnMeleeDamage(AIC.Enemy, Damage, MomentumScalar, InDamageType);
			return true;
		}
		else if ( AIC.DoorEnemy != None && (VSizeSq(Location - AIC.DoorEnemy.Location) < Square(500)) )
		{
			ApplyMeleeDamage(AIC.DoorEnemy, Damage, MomentumScalar, InDamageType);
			return true;
		}
		else if ( AIC.ActorEnemy != None && (VSizeSq(Location - AIC.ActorEnemy.Location) < Square(500)) )
		{
			// Apply damage to KFDestructibleActors, see KFDestructibleActor.TakeDamage() where there's special
			// handling to insta-kill the destructible if the attacker is a NPC with the destructible as the
			// NPC's ActorEnemy.
			if( KFDestructibleActor(AIC.ActorEnemy) != none )
			{
				ApplyMeleeDamage(AIC.ActorEnemy, Damage, MomentumScalar, InDamageType);
				return true;
			}
		}
	}

	return false;
}

/*********************************************************************************************
 * Swipe Hit Detection
 *********************************************************************************************/

/** A modified Cone hit detection that keeps track of all actors that have been hit
 * @param Damage			Damage to apply if this attack is successful
 * @param SwipeDir			Direction to use for hit detection
 * @param MomentumScalar	Momentum transfer to apply if this attack is successful
 * @param DamageType		DamageType to apply if this attack is successful
 * @param Range				Maximum range for hit detection
 * @param bPlayersOnly		If true, skip non-player controlled pawns
 */
protected function bool DoSwipeImpact(
			 int					Damage,
	optional EPawnOctant			SwipeDir=DIR_Forward,
	optional float					MomentumScalar=1.f,
	optional float					Range=MaxHitRange,
	optional bool					bPlayersOnly,
	optional class<KFDamageType> 	InDamageType=MyDamageType)
{
	local Pawn P;
	local vector HitLoc, HitNorm;
	local Actor HitActor;
	local vector ConeDir, ConeStart;
	local float ConeRange;
	local bool bFoundHit;

	// initialize cone collision
	ConeDir = GetSwipeVector(SwipeDir);
	ConeStart = Location + vect(0,0,32);
	ConeRange = Range; // VSize(BladeEnd - BladeStart)

	if ( bLogMelee )
	{
		// draw swipe trace
		DrawDebugCone(ConeStart, ConeDir, ConeRange, Acos(0.7071f), Acos(0.7071f), 16, MakeColor(64,64,64,0), TRUE);
	}

	// @perf - AllPawns is ~ 10X faster than VisibleCollidingActors, 10X TraceActors, 2X CollidingActors
	// - Use AllPawns when we only need pawn collision (fixed cost at any range)
	// - Use CollidingActors when we need to hit pawns and/or world objects
	// - Use TraceActors sparingly! (may give better results than CollidingActors)
	// - Avoid VisibleCollidingActors (RateMeleeVictim handles this)
	foreach WorldInfo.AllPawns( class'Pawn', P, Location, ConeRange )
	{
		if ( P == Instigator || P.bTearOff )
			continue;
		if ( bPlayersOnly && !P.IsHumanControlled() )
			continue;

		// Make sure victim is in FOV
		if( Normal2D(P.Location - ConeStart) dot ConeDir < 0.7071f )
		{
			`log(GetFuncName()@"rejected:"@P$", dot:"@Normal(P.Location - ConeStart) dot ConeDir, bLogMelee);
			continue;
		}

		// Don't let them melee the target through a wall
		HitActor = Trace( HitLoc, HitNorm, P.Location + (P.BaseEyeHeight * vect(0,0,1)), Location, false,,, TRACEFLAG_Blocking );	
		// KAssets block non-actor traces even if they're not world geometry. Double check that what we've actually hit
		// is really world geometry, or is at least GameRelevant. -MattF
		if( HitActor != none && HitActor != P && (HitActor.bWorldGeometry || HitActor.bGameRelevant) )
		{
			`log(GetFuncName()@"rejected:"@P$", melee obstruction:"@HitActor, bLogMelee);
			continue;
		}

		ProcessSwipeHit(P, Damage, MomentumScalar, InDamageType);
		bFoundHit = true;
	}

	// For versus players: Do swipe detection normally, then for each forward direction 
	// apply a simple line trace to hit world geometry and destructibles.
	if ( !bFoundHit && SwipeDir == DIR_Forward && Instigator.IsHumanControlled() )
	{
		DoPlayerWorldTrace(Damage, MomentumScalar, MyDamageType);
	}

	if ( bLogMelee && bFoundHit )
	{
		// draw swipe hit
		DrawDebugCone(ConeStart, ConeDir, ConeRange, Acos(0.7071f), Acos(0.7071f), 16, MakeColor(255,0,0,255), TRUE);
	}

	return bFoundHit;
}

/** Returns hard-coded normal vectors for each 8-way swipe direction */
protected function vector GetSwipeVector(EPawnOctant SwipeDir)
{
	local rotator R;

	switch (SwipeDir)
	{
		case DIR_ForwardLeft:	R = rot(0,-8192,0); break;
		case DIR_Left:			R = rot(0,-16384,0); break;
		case DIR_BackwardLeft:	R = rot(0,-24576,0); break;
		case DIR_ForwardRight:	R = rot(0,8192,0); break;
		case DIR_Backward:		R = rot(0,32768,0); break;
		case DIR_BackwardRight: R = rot(0,24576,0); break;
		case DIR_Right:			R = rot(0,16384,0); break;
	}

	return vector(Rotation + R);
}

/**
 * DoSwipeFire found a hit, now cause damage to it.
 * @param A				 - the actor that was hit in the swipe
 * @param Damage		 - amount of damage to apply if successful
 * @param InHitLoc		 - Location of hit detection result
 * @param MomentumScalar - Amount of momentum to apply if successful
 * @param DamageType	 - DamageType to apply if successful
 */
protected function ProcessSwipeHit(Actor A, int Damage, float MomentumScalar, class<KFDamageType> InDamageType)
{
	local KFPawn Victim;
	local int ListIdx;

	Victim = KFPawn(A);

	if (Victim == None )
	{
		return;
	}

	// Track player hits to ignore overlaps in hit detection
	if ( bTrackSwipeHits && A.IsA('KFPawn_Human') )
	{
		// See if this actor is already in the list
		ListIdx = SwipedActors.Find('HitActor', Victim);

		// Not in the list
		if (ListIdx == INDEX_NONE)
		{
			// Add this actor to the list and mark them for damage
			ListIdx = SwipedActors.Add(1);
			SwipedActors[ListIdx].HitActor = Victim;
			SwipedActors[ListIdx].LastHitTime = WorldInfo.TimeSeconds;
		}
		// In the list so see if we need to reset the time and do damage
		else if ( `TimeSince(SwipedActors[ListIdx].LastHitTime) > 0.25f )
		{
			SwipedActors[ListIdx].LastHitTime = WorldInfo.TimeSeconds;
		}
		else
		{
			//`log("Swipe damage ignored (interval too short)"@A);
			return;
		}
	}

	ResolvePawnMeleeDamage(Victim, Damage, MomentumScalar, InDamageType);
}

/*********************************************************************************************
 * Ping Compensation for Parry/Block
 *********************************************************************************************/

/** handle ping compensation before dealing damage */
protected function ResolvePawnMeleeDamage(Pawn Victim, int Damage, float Momentum, class<KFDamageType> InDamageType)
{
	local DelayedMeleeInfo NewDmgInfo;
	local float RealDeltaSeconds;
	local float PingCompensation;

	if ( Instigator.Role < ROLE_Authority )
	{
		return; // how did we get here?
	}

	// Do not apply ping compensation to player instigated damage!
	if ( Instigator.IsHumanControlled() )
	{
		ApplyMeleeDamage(Victim, Damage, Momentum, InDamageType);
		return;
	}

	// If necessary, apply ping compensation
	if ( Victim.PlayerReplicationInfo != None && Victim.Weapon != None &&
		ClassIsChildOf(Victim.Weapon.Class, class'KFWeap_MeleeBase') )
	{
		// Calculate delay.  Half-ping for anim to reach client and half again for parry key press to reach server
		PingCompensation = Min(Victim.PlayerReplicationInfo.Ping * `PING_SCALE, MaxPingCompensation) / 1000.f;

		// artifically reduce the delay to balance parry timing vs. AI reaction time
		PingCompensation *= PingCompensationScale;

		// "round" (div by 2) to the closest frame on the server
		RealDeltaSeconds = WorldInfo.DeltaSeconds / WorldInfo.TimeDilation;
		PingCompensation -= (RealDeltaSeconds / 2.f);

		if ( PingCompensation > 0 )
		{
			NewDmgInfo.Victim = Victim;
			NewDmgInfo.Damage = Damage;
			NewDmgInfo.Momentum = Momentum;
			NewDmgInfo.TimeOfDamage = WorldInfo.RealTimeSeconds + PingCompensation;
			NewDmgInfo.DamageType = InDamageType;
			PendingDamage.AddItem(NewDmgInfo);
			return;
		}
	}

	ApplyMeleeDamage(Victim, Damage, Momentum, InDamageType);
}

/** Called from C++ when ping compensation expires */
event ApplyDelayedPawnDamage(int i)
{
	local KFGameReplicationInfo KFGRI;

	// If the damage dealer is now dead, don't allow damage after trader/respawn.
	if ( !Instigator.IsAliveAndWell() )
	{
		KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
		if ( KFGRI != None && KFGRI.bTraderIsOpen )
		{
			return;
		}
	}

	ApplyMeleeDamage(PendingDamage[i].Victim, PendingDamage[i].Damage, PendingDamage[i].Momentum, PendingDamage[i].DamageType);
}

defaultproperties
{
	DefaultFOVCosine=0.f
	MyDamageType=class'KFDT_Slashing'

	bTrackSwipeHits=true
	MaxPingCompensation=200
	PingCompensationScale=0.5f

	PlayerControlledFOV=0.05f
	PlayerDoorDamageMultiplier=10.0f
	MeleeImpactCamScale=1.f
}
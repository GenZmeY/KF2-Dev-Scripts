//=============================================================================
// KFMeleeHelperWeapon
//=============================================================================
// Manages melee attack related functionality for 1st person weapons
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFMeleeHelperWeapon extends KFMeleeHelperBase within KFWeapon
	config(Game);

/*********************************************************************************************
 * Directional Attacks
 *********************************************************************************************/

/** If set, plays 8-way directional animations */
var() bool	bUseDirectionalMelee;
/** Count each time ChooseBestAttack is called.  Used to alternate direction */
var transient byte ChooseAtkCount;

enum EMeleeAttackType
{
	ATK_Normal,
	ATK_Combo,
	ATK_DrawStrike,
};

/** Attack settings that should be initialized before calling BeginMeleeAttack */
var private EPawnOctant			NextAttackDir;
var private EMeleeAttackType	NextAttackType;

/** Direction of the last played attack */
var EPawnOctant			CurrentAttackDir;

/*********************************************************************************************
 * Combo (aka Chain) Attacks
 *********************************************************************************************/

/** attack anim variant settings */
var() bool bHasChainAttacks;

/** 4-way directional combo chain sequence */
var() array<EPawnOctant> ChainSequence_F;
var() array<EPawnOctant> ChainSequence_B;
var() array<EPawnOctant> ChainSequence_L;
var() array<EPawnOctant> ChainSequence_R;

/** Cached chain attack sequence currently in use */
var array<EPawnOctant>  AttackChainSequence;
/** Index into the currently playing attack chain sequence */
var byte			    CurrentAtkChainIdx;
/** Number of attacks played in this sequence */
var int					NumChainedAttacks;

/** Last time MeleeAnimTimer was called */
var transient float LastMeleeAnimEnd_ActorTime;
/** Set when InitAttackSequence is called during an attack to change direction of the next attack */
var transient bool bResetChainSequence;

/*********************************************************************************************
 * Notify & Timing
 *********************************************************************************************/

/** Should use timer instead of anim notifies for melee hits? */
var() bool bUseMeleeHitTimer;

/** Time (after melee starts) before traces for impact start occuring */
var() float InitialImpactDelay;
/** Time (after impact checks start) to retry impacts */
var() float ImpactRetryDuration;
/** World time to stop retrying traces for melee impact */
var() float ImpactComplete_ActorTime;

/** Stores whether or not an impact has happened this attack */
var bool bHitEnemyThisAttack;

/*********************************************************************************************
 * Animation / FX
 *********************************************************************************************/

/** Scale animation playrate by fatigue level */
var InterpCurveFloat FatigueCurve;

/** Scale parameter for ClientPlayCameraShake */
var float MeleeImpactCamShakeScale;

/*********************************************************************************************
 * Anim Notify / Impact Timing
 *********************************************************************************************/

simulated function EPawnOctant GetNextAttackDir()
{
	return NextAttackDir;
}

simulated function SetNextAttackDir(EPawnOctant _nextAttackDir)
{
	NextAttackDir = _nextAttackDir;
}

/** Notification called from KFAnimNotify_MeleeImpact. */
simulated function MeleeImpactNotify(KFAnimNotify_MeleeImpact_1P Notify)
{
	local bool bResult;

	if ( !bHasAlreadyHit && !bUseMeleeHitTimer )
	{
		// Check impacts for players first
		bResult = MeleeAttackImpact();
		// If no impact with player occurs
		if( !bResult && Instigator.Role == ROLE_Authority )
		{
			// Check for impact with world/destructibles
			bResult = MeleeAttackDestructibles();
		}

		bHasAlreadyHit = bResult;
	}
}

/**
 *	Function handles checking for all types of melee impacts
 */
simulated function bool MeleeImpactTimer()
{
	local bool bResult;

	if ( bUseMeleeHitTimer )
	{
		// If this is the start first check of a melee attack
		if( ImpactComplete_ActorTime < 0.f )
		{
			// Update the window of time to repeat checks for impact
			ImpactComplete_ActorTime = GetActorTimeSeconds() + ImpactRetryDuration;
		}
		// If window has expired - FAIL
		if( GetActorTimeSeconds() > ImpactComplete_ActorTime )
		{
			return FALSE;
		}
	}

	// Check impacts for players first
	bResult = MeleeAttackImpact();
	// If no impact with player occurs
	if( !bResult && Instigator.Role == ROLE_Authority )
	{
		// Check for impact with world/destructibles
		bResult = MeleeAttackDestructibles();
	}

	// If no impact has occured
	if( !bResult && bUseMeleeHitTimer )
	{
		// Set timer to retry impact
		SetTimer(0.1, FALSE, nameof(MeleeImpactTimer), self);
	}

	return bResult;
}

/**
 * Main hit detection and resolution for melee attacks
 * Network: Local Player
 */
simulated function bool MeleeAttackImpact()
{
	local Array<ImpactInfo>	ImpactList;
	local int				Idx;
	//local ImpactInfo		RealImpact;
	local vector			StartTrace, EndTrace;
	local bool				bHasAnyHit;

	// local player only for clientside hit detection
	if ( Instigator == None || !Instigator.IsLocallyControlled() )
	{
		return false;
	}

	StartTrace	= GetMeleeStartTraceLocation();
	EndTrace	= StartTrace + vector(GetMeleeAimRotation()) * MaxHitRange;

	CalcWeaponMeleeAttack(StartTrace, EndTrace, ImpactList);
	bHasAnyHit = ImpactList.length > 0;

	for (Idx = 0; Idx < ImpactList.Length; Idx++)
	{
		ProcessMeleeHit(CurrentFireMode, ImpactList[Idx]);
	}

	if ( Instigator.Role < ROLE_Authority )
	{
		SendClientImpactList(CurrentFireMode, ImpactList);
	}

	return bHasAnyHit;
}

/*********************************************************************************************
 * FOV (aka Area, Cone) Hit Detection
 *********************************************************************************************/

/**
 * CalcWeaponMeleeAttack: Simulate an instant hit melee attack.
 * This doesn't deal any damage nor trigger any effect. It just simulates a shot and returns
 * the hit information, to be post-processed later.
 */
simulated function ImpactInfo CalcWeaponMeleeAttack(vector StartTrace, vector EndTrace, optional out array<ImpactInfo> ImpactList, optional vector Extent)
{
	local KFPawn 						KFPOwner;
	local KFSM_InteractionPawnFollower 	FollowerSM;
	local Pawn							BestVictim;
	local ImpactInfo					CurrentImpact;
	local array<Pawn>					VictimList;
	local vector						RayDir;

	// nudge impact direction (momentum) based on attack type
	RayDir = GetAdjustedRayDir(EndTrace - StartTrace);

	// If an enemy pawn has engaged us in an interaction special move, try to target them first
	KFPOwner = KFPawn( Instigator );
	if( KFPOwner.IsDoingSpecialMove() )
	{
		FollowerSM = KFSM_InteractionPawnFollower( KFPOwner.SpecialMoves[KFPOwner.SpecialMove] );
		if( FollowerSM != none
			&& FollowerSM.Leader != none
			&& RateMeleeVictim(FollowerSM.Leader, StartTrace, EndTrace, MaxHitRange, DefaultFOVCosine) > -1.f )
		{
			BestVictim = FollowerSM.Leader;
		}
	}

	// Find nearby pawn targets - in the future we may want to calculate multiple victim impacts
	if( BestVictim == none )
	{
		BestVictim = FindVictimByFOV(StartTrace, EndTrace);
	}

	if ( BestVictim != None )
	{
		VictimList[0] = BestVictim;
		CalcVictimImpactList(VictimList, StartTrace, EndTrace, RayDir, ImpactList);
	}
	else if ( Instigator.Weapon != None )
	{
		DoWeaponInstantTrace(StartTrace, EndTrace, CurrentImpact);
		if( CurrentImpact.HitActor != None )
		{
			// Check for world geometry or CanBeDamaged (e.g. ragdolls, destructibles)
			if ( CurrentImpact.HitActor == WorldInfo
				|| CurrentImpact.HitActor.bBlockActors
				|| CurrentImpact.HitActor.bCanBeDamaged	)
			{
				CurrentImpact.RayDir = RayDir;
				ImpactList[ImpactList.Length] = CurrentImpact;
			}
		}

		`log(WorldInfo.TimeSeconds @ GetFuncName() @ "HitWallCheck, HitActor:" @ CurrentImpact.HitActor, bLogMelee && CurrentImpact.HitActor != None);
	}

	if( bLogMelee )
	{
		DrawDebugLine(StartTrace, EndTrace, 128, 0, 0, TRUE);
		DrawDebugLine(StartTrace, StartTrace + RayDir * 100, 0, 128, 0, TRUE);
		// while debugging melee flush the lines after some inactivity
		SetTimer(10.f, false, nameof(FlushPersistentDebugLines));
	}

	return CurrentImpact;
}

/** Converts a KFPawn list into a ImpactInfo list */
simulated function CalcVictimImpactList(array<Pawn> VictimList, vector StartTrace, vector EndTrace, vector RayDir, optional out array<ImpactInfo> ImpactList)
{
	local ImpactInfo HitZoneImpact;
	local int i;

	for ( i = 0; i < VictimList.Length; i++ )
	{
		if ( TraceMeleeAttackHitZones(VictimList[i], StartTrace, EndTrace, HitZoneImpact) )
		{
			HitZoneImpact.RayDir = RayDir; // not set by TraceAllPhysicsAssetInteractions
			ImpactList[ImpactList.Length] = HitZoneImpact;
			`log(GetFuncName()@"HitZone:"$ImpactList[0].HitInfo.BoneName@"DmgScale:"$VSize(RayDir)@"HitActor:"$VictimList[i], bLogMelee);
		}
		else
		{
			`log(GetFuncName()@"HitVictimCheck missed all hit zones");	// should never happen
		}
	}
}

/** Calculate a new Impact RayDir for a given AttackType.  Used by FOV-style
 * collision to simulate directional attack momentum.
 */
simulated function vector GetAdjustedRayDir(vector ImpactRayDir)
{
	local rotator R;

	if ( bUseDirectionalMelee )
	{
		switch ( CurrentAttackDir )
		{
			case DIR_Forward:		R = rot(-8192, 0,	 0);	 break;
			case DIR_ForwardLeft:	R = rot(-8192,-8192, 0);	 break;
			case DIR_ForwardRight:	R = rot(-8192, 8192, 0);	 break;
			case DIR_Backward:		R = rot( 8192, 0,	 0);	 break;
			case DIR_BackwardLeft:  R = rot( 8192,-8192, 0);	 break;
			case DIR_BackwardRight:	R = rot( 8192, 8192, 0);	 break;
			case DIR_Left:			R = rot( 0,	  -8192, 0);	 break;
			case DIR_Right:			R = rot( 0,	   8192, 0);	 break;
		}

		return vector(rotator(ImpactRayDir) + R);
	}

	return Normal(ImpactRayDir);
}

/*********************************************************************************************
 * Hitbox Collision Detection
 *********************************************************************************************/

/** Recieve collision event and register impact with CSHD */
event ProcessHitboxCollision(Actor HitActor, vector StartTrace, vector EndTrace, vector HitLocation, vector HitNormal, const out TraceHitInfo HitInfo, optional out ImpactInfo Impact)
{
	local Array<ImpactInfo>	ImpactList;
	local ImpactInfo HitZoneImpact;
	local int Idx;

	if ( Instigator != None && Instigator.IsLocallyControlled() )
	{
		Super.ProcessHitboxCollision(HitActor, StartTrace, EndTrace, HitLocation, HitNormal, HitInfo, Impact);
		ImpactList[0] = Impact;

		// Trace physics asset hit zones
		if ( HitActor.IsA('KFPawn') )
		{
			if ( TraceMeleeAttackHitZones(KFPawn(HitActor), StartTrace, EndTrace, HitZoneImpact, HitInfo.BoneName) )
			{
				HitZoneImpact.RayDir = Impact.RayDir; // TraceAllPhysicsAssetInteractions doesn't set RayDir
				ImpactList[0] = HitZoneImpact;
			}
			else
			{
				`log(GetFuncName()@"missed hit zone... continuing with hitbox TraceInfo");
			}

			// encode damage scale based on fan collision into the raydir
			ImpactList[0].RayDir *= GetDamageScaleByAngle(HitLocation);
		}

		for (Idx = 0; Idx < ImpactList.Length; Idx++)
		{
			ProcessMeleeHit(CurrentFireMode, ImpactList[Idx]);
		}

		if ( Instigator.Role < ROLE_Authority )
		{
			SendClientImpactList(CurrentFireMode, ImpactList);
		}
	}
}

/** Called when a hitbox notify starts to allow script to perform a custom world trace */
event InitWorldTraceForHitboxCollision()
{
	SetTimer(0.1, false, nameof(HitboxSimpleWorldTrace), self);
}

/** Performs a simple forward trace if bHitboxPawnsOnly=TRUE */
function bool HitboxSimpleWorldTrace()
{
	local vector			StartTrace, EndTrace;
	local ImpactInfo		CurrentImpact;
	local array<ImpactInfo> ImpactList;
	local int				Idx;

	// local player only for clientside hit detection
	if ( Instigator == None || !Instigator.IsLocallyControlled() )
	{
		return false;
	}

	StartTrace	= GetMeleeStartTraceLocation();
	EndTrace	= StartTrace + vector(GetMeleeAimRotation()) * MaxHitRange;

	DoWeaponInstantTrace(StartTrace, EndTrace, CurrentImpact);
	if( CurrentImpact.HitActor != None )
	{
		// Check for world geometry and other destructibles
		if ( CurrentImpact.HitActor.bWorldGeometry || (CurrentImpact.HitActor.bCanBeDamaged && !CurrentImpact.HitActor.IsA('Pawn')) )
		{
			CurrentImpact.RayDir = GetAdjustedRayDir(EndTrace - StartTrace);
			ImpactList[ImpactList.Length] = CurrentImpact;

			for (Idx = 0; Idx < ImpactList.Length; Idx++)
			{
				ProcessMeleeHit(CurrentFireMode, ImpactList[Idx]);
			}

			if ( Instigator.Role < ROLE_Authority )
			{
				SendClientImpactList(CurrentFireMode, ImpactList);
			}

			`log(GetFuncName()@CurrentImpact.HitActor, bLogMelee);
			return true;
		}
	}

	return false;
}

/*********************************************************************************************
 * Weapon melee state (e.g. MeleeAttackBasic) animation and timing
 *********************************************************************************************/

/** Called from state MeleeAtacking */
simulated function BeginMeleeAttack(optional bool bIsChainAttack)
{
	local Pawn P;
	local KFPawn_Monster KFPM;
	local vector Projection;
	local float MeleeDuration;

    // Don't let a weak zed grab us when we just melee attacked
    // Ramm - commented out, too exploitable
    // SetWeakZedGrabCooldownOnPawn(0.5);

	// initialize attack settings
	bHasAlreadyHit = false;
	bHitEnemyThisAttack = false;

    // Let the playercontroller know we did an attack
    if ( Instigator != None && Instigator.Controller != none &&
        KFPlayerController(Instigator.Controller) != none )
    {
        KFPlayerController(Instigator.Controller).AddShotsFired(1);
    }

	// Clear reset flag (see InitAttackSequence, ContinueMeleeAttack)
	bResetChainSequence = false;

	// save the direction of this attack
	CurrentAttackDir = (CurrentFireMode == BASH_FIREMODE || CurrentFireMode == CUSTOM_FIREMODE ) ? DIR_None : NextAttackDir;

	// Notify enemy pawns of melee strike
	if( WorldInfo.NetMode != NM_Client )
	{
		foreach WorldInfo.AllPawns( class'Pawn', P )
		{
			if( P.GetTeamNum() != Instigator.GetTeamNum() && P.IsAliveAndWell() && !P.IsHumanControlled() )
			{
				Projection = Instigator.Location - P.Location;
				if( VSizeSQ(Projection) <= Square(MaxHitRange + P.CylinderComponent.CollisionRadius) )
				{
					KFPM = KFPawn_Monster( P );
					if( KFPM != none && KFPM.MyKFAIC != none )
					{
						KFPM.MyKFAIC.ReceiveMeleeWarning( CurrentAttackDir, Projection, Instigator );
					}
				}
			}
		}
	}

	// Select and play attack animation
	MeleeDuration = PlayMeleeAttackAnimation();

	if ( MeleeDuration > 0.f )
	{
		// @hack: Add current DeltaSeconds to timer.  This fixes an off-by-one frame issue that can
		// that can cause the timer to interrupt animation at low framerate.  This is particularly
		// bad for melee when using impact anim notifies.
		SetTimer(MeleeDuration + WorldInfo.DeltaSeconds, FALSE, nameof(MeleeCheckTimer), self);

		// set the timer to check for hits
		if( bUseMeleeHitTimer && InitialImpactDelay > 0.f )
		{
			// Clear complete time so it is intialized properly
			ImpactComplete_ActorTime = -1.f;
			SetTimer(InitialImpactDelay, FALSE, nameof(MeleeImpactTimer), self);
		}
	}
	else
	{
		`warn("MeleeDuration is zero!!!");
		SetTimer(0.001, false, nameof(HandleFinishedFiring));
	}
}

/** Plays the melee attack animations and returns the interrupt time */
simulated function float PlayMeleeAttackAnimation()
{
	local name MeleeAnimName;
	local float InterruptTime, Rate;

	// Calc Reload Duration
	MeleeAnimName = GetMeleeAnimName(NextAttackDir, NextAttackType);

	InterruptTime = MySkelMesh.GetAnimInterruptTime(MeleeAnimName);
	Rate = EvalInterpCurveFloat(FatigueCurve, NumChainedAttacks);

	if ( InterruptTime > 0.f )
	{
		// Call back into weapon (rather than direct to 'PlayAnimation') so it can choose to override
		PlayMeleeAnimation(MeleeAnimName, Rate, GetMeleeBlendInTime());
	}

	return InterruptTime * Rate;
}

/** Returns the desired blend in time for this melee attack animation */
simulated function float GetMeleeBlendInTime()
{
	// Chain attack anims go offscreen, so we need to disable blending for the next action
	if ( bHasChainAttacks )
	{
		// This can sometimes happen when AtkType != MAT_Combo.  LastRenderTime will catch it most of the time.
		if ( NextAttackType == ATK_Combo || `TimeSince(LastRenderTime) > 0.f )
		{
			return 0.f;
		}
	}

	return 0.1f;
}

/**
 * Returns the type of melee attack we want to perform
 * Network: Local Player
 */
simulated function EPawnOctant ChooseAttackDir()
{
	local vector MoveDir;
	local EPawnOctant AttackDir;

	ChooseAtkCount++;

	// Prefer to use acceleration, but if the player only has velocity use that.
	// This allows the player to let go off the movement keys just before an attack.
	MoveDir = (IsZero(Instigator.Acceleration)) ? Instigator.Velocity : Instigator.Acceleration;

	if ( Instigator == None || !bUseDirectionalMelee || IsZero(MoveDir) )
	{
		if ( bUseDirectionalMelee )
		{
			// alternate left and right
			return ((ChooseAtkCount & 1) > 0) ? DIR_Left : DIR_Right;
		}

		return DIR_None;
	}

	// Get desired attack direction.  This is reasonbly close on server/client, but it could still use
	// a little work to sync perfectly.  To see why run with pktlag and spin around like a crazy person.
	AttackDir = class'KFPawn'.static.CalcQuadRegion(Instigator.GetViewRotation(), MoveDir);

	// reverse left/right so that we're moving in the direction of the attack
	switch ( AttackDir )
	{
	case DIR_Left: return DIR_Right;
	case DIR_Right: return DIR_Left;
	}

	return AttackDir;
}

/** Sets the type of attack when StartFire is called */
simulated function InitAttackSequence(EPawnOctant NewAtkDir, EMeleeAttackType NewAtkType)
{
	`log(Instigator@"SetNextAttackType:"@NewAtkDir, bLogMelee);

	CurrentAtkChainIdx = 0;
	NumChainedAttacks = 0;
	NextAttackDir = NewAtkDir;
	NextAttackType = NewAtkType;

	// initialize chain attack sequence
	if ( bUseDirectionalMelee )
	{
		AttackChainSequence.Length = 0;

		if ( NewAtkType == ATK_DrawStrike )
		{
			AttackChainSequence = ChainSequence_R;
		}
		else
		{
			switch (NextAttackDir)
			{
			case DIR_Forward:			AttackChainSequence = ChainSequence_F; break;
			case DIR_ForwardLeft:		AttackChainSequence = ChainSequence_F; break;
			case DIR_ForwardRight:		AttackChainSequence = ChainSequence_F; break;
			case DIR_Backward:			AttackChainSequence = ChainSequence_B; break;
			case DIR_Left:				AttackChainSequence = ChainSequence_L; break;
			case DIR_Right:				AttackChainSequence = ChainSequence_R; break;
			}
		}

		bResetChainSequence = IsMeleeing();
	}

	// If the player uses a default melee attack within a short time of another attack, use combo anims
	if ( NewAtkType == ATK_Normal && !IsMeleeing() )
	{
		if ( LastMeleeAnimEnd_ActorTime > 0.f && ActorTimeSince(LastMeleeAnimEnd_ActorTime) < 0.1f )
		{
			NextAttackType = ATK_Combo;
		}
	}
}

/** see Weapon::RefireCheckTimer() */
simulated function MeleeCheckTimer()
{
	ClearTimer(nameof(MeleeCheckTimer), self);

	LastMeleeAnimEnd_ActorTime = GetActorTimeSeconds();

	if ( IsMeleeing() )
	{
		// if switching to another weapon, abort firing and put down right away
		if( bWeaponPutDown )
		{
			`LogInv("Weapon put down requested during fire, put it down now");
			PutDownWeapon();
			return;
		}

		// If weapon should keep on firing, then do not leave state and fire again.
		if( bHasChainAttacks && ShouldContinueMelee(NumChainedAttacks) )
		{
			ContinueMeleeAttack();
			return;
		}

		// Otherwise we're done firing
		HandleFinishedFiring();
	}
}

/** Called from state ShouldRefire */
simulated function ContinueMeleeAttack()
{
	// increment attack sequence
	if ( bUseDirectionalMelee && AttackChainSequence.Length > 0 )
	{
		NumChainedAttacks++;

		// increment sequence unless it's been reset/interrupted
		if ( !bResetChainSequence )
		{
			NextAttackDir = AttackChainSequence[CurrentAtkChainIdx];
			CurrentAtkChainIdx = (CurrentAtkChainIdx + 1) % AttackChainSequence.Length;
		}

		`log("IncrementAttackSequence ChainIdx="$CurrentAtkChainIdx@"Direction="$NextAttackDir, bLogMelee);
	}

	// these attacks always play combo attack anims
	NextAttackType = ATK_Combo;

	BeginMeleeAttack(true);

	// If this attack is our last attack in the sequence, clear pending fire.
	if( PendingFire(CurrentFireMode) && !ShouldContinueMelee(NumChainedAttacks) )
	{
		ClearPendingFire(CurrentFireMode);
	}
}

/*********************************************************************************************
 * Damage & Hit FX
 *********************************************************************************************/

/**
 * @see ProcessInstantHit
 * Network: LocalPlayer and Server
 */
simulated function ProcessMeleeHit(byte FiringMode, ImpactInfo Impact)
{
	local KActorFromStatic NewKActor;
	local StaticMeshComponent HitStaticMesh;
	local FracturedStaticMeshActor FracActor;
	local KFPawn HitPawn;
	local vector Momentum;

	if ( Impact.HitActor != None )
	{
		if ( Impact.HitActor.bWorldGeometry )
		{
			HitStaticMesh = StaticMeshComponent(Impact.HitInfo.HitComponent);
			if ( (HitStaticMesh != None) && HitStaticMesh.CanBecomeDynamic() )
			{
				NewKActor = class'KActorFromStatic'.Static.MakeDynamic(HitStaticMesh);
				if ( NewKActor != None )
				{
					Impact.HitActor = NewKActor;
				}
			}

			// Fracture meshes if we hit them
			if( bAllowMeleeToFracture )
			{
				FracActor = FracturedStaticMeshActor(Impact.HitActor);
				if(FracActor != None)
				{
					class'KFMeleeHelperBase'.static.MeleeFractureMeshImpact( FracActor, Impact.HitLocation, Impact.HitNormal );
				}
			}
		}

		// Notify pawn of melee damage. Similar to NotifyTakeHit, but before AdjustDamage is called.
		HitPawn = KFPawn(Impact.HitActor);
		if ( HitPawn != None )
		{
			if( !bHitEnemyThisAttack && HitPawn.GetTeamNum() != Instigator.GetTeamNum() )
			{
                // Let the playercontroller know we did hit with this attack
                if ( Instigator != None && Instigator.Controller != none &&
                    KFPlayerController(Instigator.Controller) != none )
                {
                    KFPlayerController(Instigator.Controller).AddShotsHit(1);
                }

                bHitEnemyThisAttack = true;
			}

            HitPawn.NotifyMeleeTakeHit(Instigator.Controller, Impact.HitLocation);
		}

		// Get momentum transfer from the owning weapon
		Momentum = Normal(Impact.RayDir) * InstantHitMomentum[FiringMode];

		// play effects before doing damage, because doing damage can change the actor (e.g. destructibles) and result in incorrect sounds
		PlayMeleeHitEffects(Impact.HitActor, Impact.HitLocation, Impact.RayDir);
		
		PawnTakeDamage(Impact, FiringMode, Momentum);

		// notify weapon for custom code
		NotifyMeleeCollision(Impact.HitActor, Impact.HitLocation);
	}
}

simulated function PawnTakeDamage(ImpactInfo Impact,byte FiringMode, vector Momentum)
{
		Impact.HitActor.TakeDamage( GetMeleeDamage(FiringMode, Impact.RayDir), Instigator.Controller,
						Impact.HitLocation, Momentum,
						GetDamageType(FiringMode), Impact.HitInfo, Outer );
}

/** returns the damage type to use for this attack */
simulated function class<DamageType> GetDamageType(byte FiringMode)
{
	// Use the FiringMode to determine type of attack
	return InstantHitDamageTypes[FiringMode];
}

/** Get damage scale adjusted to impact angle */
simulated function float GetDamageScaleByAngle(vector HitLoc)
{
	local float DotResult;
	local vector Origin;
	local vector Aim;

	if ( Instigator == None || !Instigator.IsLocallyControlled() )
	{
		return 1.f;
	}

	Origin = GetMeleeStartTraceLocation();
	Aim = vector(Instigator.GetBaseAimRotation());

	switch ( CurrentAttackDir )
	{
		case DIR_Left:
		case DIR_Right:
			// for horizontal attacks do 50-75% damage
			DotResult = 0.75f * Normal2D(Aim) dot Normal2D(HitLoc - Origin);
			return FMax(DotResult, 0.50f);
	}

	return 1.f;
}

/**
 * Called by ProcessMeleeHit to spawn effects
 * Network: Local Player and Server
 */
simulated function PlayMeleeHitEffects(Actor Target, vector HitLocation, vector HitDirection, optional bool bShakeInstigatorCamera=true)
{
	// @note: Skipping super().  No victim camera shake is intentional

	if( WorldInfo.NetMode != NM_DedicatedServer )
	{
		// first person (local) fire effects
		if ( Instigator.IsFirstPerson() )
		{
			PlayerController(Instigator.Controller).ClientPlayCameraShake(MeleeImpactCamShake, MeleeImpactCamShakeScale, true, CAPS_UserDefined, rotator(-HitDirection));

			if ( Target.IsA('Pawn') )
			{
				AddBlood(0.01f, 0.1f);
			}
		}

		// If we hit a pawn we can skip the Tracing code in PlayImpactEffects.  Pawn FX are handled in
		// PlayHit and this prevents incorrect (world) FX from playing if the trace is bad.
		if ( !(Target.bCanBeDamaged && Target.IsA('Pawn')) )
		{
			// Use ImpactEffectManager to material based world impacts
			`ImpactEffectManager.PlayImpactEffects(HitLocation, Instigator, HitDirection, WorldImpactEffects);
		}
	}
}

defaultproperties
{
	bAllowMeleeToFracture=true
	bHitboxPawnsOnly=true

	// damage settings
	InitialImpactDelay=0.2
	ImpactRetryDuration=0.2

	// default chain attack sequences
	ChainSequence_F=(DIR_Left, DIR_ForwardRight, DIR_ForwardLeft, DIR_ForwardRight, DIR_ForwardLeft)
	ChainSequence_B=(DIR_BackwardRight, DIR_ForwardLeft, DIR_BackwardLeft, DIR_ForwardRight, DIR_Left, DIR_Right, DIR_Left)
	ChainSequence_L=(DIR_Right, DIR_Left, DIR_ForwardRight, DIR_ForwardLeft, DIR_Right, DIR_Left)
	ChainSequence_R=(DIR_Left, DIR_Right, DIR_ForwardLeft, DIR_ForwardRight, DIR_Left, DIR_Right)

	FatigueCurve=(Points=((InVal=2.f,OutVal=1.f),(InVal=15.f, OutVal=1.5f)))

	WorldImpactEffects=KFImpactEffectInfo'FX_Impacts_ARCH.Blunted_melee_impact'
	MeleeImpactCamShakeScale=1.f
}

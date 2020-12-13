//=============================================================================
// KFSM_Husk_FlameThrowerAttack
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFSM_Husk_FlameThrowerAttack extends KFSM_PlaySingleAnim;

/** The Archetype to spawn for our fire spray actors. */
var KFSprayActor 	                    FlameSprayArchetype;
var KFSprayActor					    MyFlameSpray;
/** Emitter to play when firing stops. */
var ParticleSystemComponent             PSC_EndSpray;
/** Replicated flag to turn off the flamethrower effect on clients. */
var bool                     	 		bFlameThrowerActive;

/** Pilot light sound play event */
var AkEvent                             FlameAttackPlayEvent;

/** Pilot light sound stop event */
var AkEvent	                            FlameAttackStopEvent;

protected function bool InternalCanDoSpecialMove()
{
	local vector HitLocation, HitNormal;
	local Actor HitActor;

	if( KFPOwner.IsHumanControlled() )
	{
		return KFPOwner.IsCombatCapable();
	}

	if( AIOwner == none || AIOwner.MyKFPawn == none || AIOwner.Enemy == none )
	{
		return false;
	}

	if( !KFPOwner.IsCombatCapable() )
	{
		return false;
	}

    // Make sure we have line of sight
	HitActor = PawnOwner.Trace(HitLocation, HitNormal, AIOwner.Enemy.Location, PawnOwner.Location, true);
	if ( HitActor != None && HitActor != AIOwner.Enemy )
	{
		return false;
	}

	return super.InternalCanDoSpecialMove();
}

function SpecialMoveStarted( bool bForced, name PrevMove )
{
	super.SpecialMoveStarted( bForced, PrevMove );	

	if( AIOwner != none )
	{
		`AILog_Ext( self@"started for"@AIOwner, 'Husk', AIOwner );
		AIOwner.AIZeroMovementVariables();
	}
}

/** Turns the flamethrower on */
simulated function TurnOnFlamethrower()
{
	local KFPawn_ZedHusk HuskOwner;

	HuskOwner = KFPawn_ZedHusk( PawnOwner );

	if( HuskOwner == none || !HuskOwner.IsAliveAndWell() || bFlameThrowerActive )
	{
		return;
	}

    if( MyFlameSpray == none )
    {
    	MyFlameSpray = HuskOwner.Spawn(FlameSprayArchetype.Class, HuskOwner,, HuskOwner.Location, HuskOwner.Rotation, FlameSprayArchetype, TRUE);

    	// Use a particular ImpactProjectileClass that will scale damage by difficulty
    	MyFlameSpray.ImpactProjectileClass = class'KFProj_HuskGroundFire';
    	MyFlameSpray.OwningKFPawn = HuskOwner;
    	MyFlameSpray.SetBase(HuskOwner,, HuskOwner.Mesh, MyFlameSpray.SpraySocketName );

    	if( HuskOwner.WorldInfo.NetMode != NM_DedicatedServer && PSC_EndSpray != None )
    	{
    		if( PSC_EndSpray != None)
        	{
        		PSC_EndSpray.SetTemplate(MyFlameSpray.SprayEndEffect);
        	}
            HuskOwner.Mesh.AttachComponentToSocket( PSC_EndSpray, MyFlameSpray.SpraySocketName );
    	}


    	if( HuskOwner.Role < ROLE_Authority )
    	{
            // Set these to be visual only as we do the damage on the server versions
        	MyFlameSpray.bVisualOnly=true;
    	}
	}

	bFlameThrowerActive = true;

    if( HuskOwner.Role == ROLE_Authority || HuskOwner.IsLocallyControlled() )
    {
        HuskOwner.SetWeaponAmbientSound(FlameAttackPlayEvent);
    }

	if( MyFlameSpray != none )
	{
		// Apply rally boost damage
		MyFlameSpray.SprayDamage.X = HuskOwner.GetRallyBoostDamage( MyFlameSpray.default.SprayDamage.X );
		MyFlameSpray.SprayDamage.Y = HuskOwner.GetRallyBoostDamage( MyFlameSpray.default.SprayDamage.Y );

		// Start flames
		MyFlameSpray.BeginSpray();
	}
}

function SpecialMoveEnded(Name PrevMove, Name NextMove)
{
	TurnOffFlamethrower();

	super.SpecialMoveEnded( PrevMove, NextMove );

	if( AIOwner != none )
	{
		`AILog_Ext( self@"ended for"@AIOwner, 'Husk', AIOwner );
	}
}

/** Turns the flamethrower off */
simulated function TurnOffFlamethrower()
{
	local KFPawn_ZedHusk HuskOwner;

	HuskOwner = KFPawn_ZedHusk( PawnOwner );

	if( HuskOwner == none || !bFlameThrowerActive )
	{
		return;
	}

    bFlameThrowerActive = false;

    if( HuskOwner.Role == ROLE_Authority || HuskOwner.IsLocallyControlled() )
    {
    	HuskOwner.SetWeaponAmbientSound(FlameAttackStopEvent);
    }

	// play end-of-firing poof.  will stop itself.
	if( PSC_EndSpray != None )
	{
		PSC_EndSpray.ActivateSystem();
	}

	if( MyFlameSpray != none )
	{
		MyFlameSpray.DetachAndFinish();
	}
}

/**
 * Can a new special move override this one before it is finished?
 * This is only if CanDoSpecialMove() == TRUE && !bForce when starting it.
 */
function bool CanOverrideMoveWith( Name NewMove )
{
	if ( bCanBeInterrupted && (NewMove == 'KFSM_Stunned' || NewMove == 'KFSM_Stumble' || NewMove == 'KFSM_Knockdown' || NewMove == 'KFSM_Frozen') )
	{
		return TRUE; // for NotifyAttackParried
	}
	return FALSE;
}

DefaultProperties
{
	// SpecialMove
	Handle=KFSM_Husk_FlameThrowerAttack
	bDisableSteering=false
	bDisableMovement=true
	bDisableTurnInPlace=true
   	bCanBeInterrupted=true
   	bUseCustomRotationRate=true
   	CustomRotationRate=(Pitch=66000,Yaw=100000,Roll=66000)
   	CustomTurnInPlaceAnimRate=2.f

   	// Animation
	AnimName=Player_Flame
	AnimStance=EAS_FullBody

	// Flamethrower
	FlameSprayArchetype=SprayActor_Flame'zed_husk_arch.Husk_Flamethrower_Flame'

	Begin Object Class=ParticleSystemComponent Name=FlameEndSpray0
		bAutoActivate=FALSE
		TickGroup=TG_PostUpdateWork
	End Object
	PSC_EndSpray=FlameEndSpray0

	FlameAttackPlayEvent=AkEvent'WW_ZED_Husk.ZED_Husk_SFX_Flamethrower_LP'
    FlameAttackStopEvent=AkEvent'WW_ZED_Husk.ZED_Husk_SFX_Flamethrower_Stop'
}

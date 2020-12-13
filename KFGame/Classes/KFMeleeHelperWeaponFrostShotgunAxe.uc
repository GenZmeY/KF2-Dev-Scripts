//=============================================================================
// KFMeleeHelperWeapon
//=============================================================================
// Manages melee attack related functionality for 1st person weapons
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFMeleeHelperWeaponFrostShotgunAxe extends KFMeleeHelperWeapon
	config(Game);

var bool bIcedEnemy;
var ParticleSystem ChargedEffect;
var ParticleSystemComponent FullyChargedPSC;
var AkEvent oFrozenSound;
var AkEvent oHitSoundAkEvent;

simulated function PawnTakeDamage(ImpactInfo Impact,byte FiringMode, vector Momentum)
{
	local int InstantDamage;

	bIcedEnemy = false;
	if(Impact.HitActor.IsA('KFPawn_Monster'))
	{
		if(KFPawn_Monster(Impact.HitActor).IsDoingSpecialMove(SM_Frozen))
		{
			bIcedEnemy = true;
		}
	}
 	InstantDamage = GetMeleeDamage(FiringMode, Impact.RayDir);
	Impact.HitActor.TakeDamage(InstantDamage, Instigator.Controller,
		Impact.HitLocation, Momentum,
		GetDamageType(FiringMode), Impact.HitInfo, Outer );

}

simulated function bool IsEnemyIced(){
	return bIcedEnemy;
}


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
	CurrentAttackDir = ( CurrentFireMode == CUSTOM_FIREMODE ) ? DIR_None : GetNextAttackDir();

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
				if(KFPawn_Monster(Target).IsDoingSpecialMove(SM_Frozen))
				{

					if( IsZero(HitDirection) && Instigator != none )
					{
						HitDirection = Normal(Instigator.Location - HitLocation);
					}

					WorldInfo.MyEmitterPool.SpawnEmitter(ChargedEffect, HitLocation, rotator(HitDirection), Target);
					Instigator.PlayAkEvent(oFrozenSound);
					Instigator.PlayAkEvent(oHitSoundAkEvent);
				}
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
	oFrozenSound=AkEvent'WW_WEP_SA_CompoundBow.Play_Arrow_Impact_Cryo'
	oHitSoundAkEvent=AkEvent'WW_WEP_FrostFang.Play_FrostFang_Base_Impact'
	ChargedEffect=ParticleSystem'WEP_Frost_Shotgun_Axe_EMIT.FX_FrostFang_Melee_ImpactFrozen_01';
	HitboxBoneName=RW_Weapon
}

//=============================================================================
// KFSM_Stunned
//=============================================================================
// Used to stop a zed from moving and play a stunned and wakeup animation
// for a random amount of time
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Greg Felber 2/5/2014
//=============================================================================
class KFSM_Stunned extends KFSpecialMove;

var	name		StunnedAnim;
var	array<name>	WakeupAnims;

var float StunDuration;

var vector2D PlayerStunDurationRange;
var vector2D StunDurationRange;

/** Socket to attach our dazed/stunned effect */
var name DazedFXSocketName;
var rotator DazedFXRelativeRotation;
var transient ParticleSystemComponent DazedPSC;

/** Notification called when Special Move starts */
function SpecialMoveStarted(bool bForced, Name PrevMove )
{
	super.SpecialMoveStarted( bForced, PrevMove );
	DoStun();
}

/** Stop the movement and play the stun animation for all clients */
function DoStun()
{
	if( KFPOwner.Role == ROLE_Authority )
	{
		// Disable Movement by using the DefaultAICommandClass to call LockdownAI()
		if( KFPOwner.IsHumanControlled() )
		{
			StunDuration = KFPOwner.IncapSettings[AF_Stun].Duration > 0 ? KFPOwner.IncapSettings[AF_Stun].Duration : RandRange( PlayerStunDurationRange.X, PlayerStunDurationRange.Y );
		}			
		else
		{
			StunDuration = KFPOwner.IncapSettings[AF_Stun].Duration > 0 ? KFPOwner.IncapSettings[AF_Stun].Duration : RandRange( StunDurationRange.X, StunDurationRange.Y );		
		}

		KFPOwner.SetTimer( StunDuration, false, nameof(DoWakeup), self );
	}

	// We still want to preserve Z velocity, and not stop in mid-air
	KFPOwner.Velocity.X = 0.f;
	KFPOwner.Velocity.Y = 0.f;
	KFPOwner.Acceleration = vect(0,0,0);
	PlaySpecialMoveAnim( StunnedAnim, EAS_FullBody, 0.4f, 0.3f, 1.f, true );

	// Spawn the dazed particle effect
	if( KFPOwner.WorldInfo.NetMode != NM_DedicatedServer )
	{
		DazedPSC = AttachDazedEffect( KFPawn_Monster(KFPOwner) );
	}
}

/** Wakeup the zed once the servers timer has finished */
function DoWakeup()
{
	// replicate to all clients
	if( KFPOwner.Role == ROLE_Authority )
	{
		KFPOwner.SpecialMoveFlags = 1;
		KFPOwner.ReplicatedSpecialMove.Flags = 1;
        PlayWakeupAnimation();
	}
}

/* Play a random wakeup animation */
function PlayWakeupAnimation()
{
	local byte WakeupIndex;

	WakeupIndex = Rand( WakeupAnims.Length );
	PlaySpecialMoveAnim( WakeupAnims[WakeupIndex], EAS_FullBody, 0.2f, 0.3f, 1.f, false );

	// Deactivate dazed particle effect
	if( DazedPSC != none )
	{
		DazedPSC.DeactivateSystem();
	}
}

/* Play the wakeup animation for all clients */
function SpecialMoveFlagsUpdated()
{
	PlayWakeupAnimation();
}

/** Notification called when Special Move starts when ReplicatedSpecialMove changes*/
function SpecialMoveEnded(Name PrevMove, Name NextMove)
{
	super.SpecialMoveEnded( PrevMove, NextMove );

	// Make sure dazed particle effect is always deactivated
	if( DazedPSC != none && DazedPSC.bIsActive )
	{
		DazedPSC.DeactivateSystem();
	}
}

/** Attaches the dazed effect to a monster pawn */
static function ParticleSystemComponent AttachDazedEffect( KFPawn_Monster KFPM )
{
	local ParticleSystemComponent PSC;
	local KFCharacterInfo_Monster MonsterArch;

	if( KFPM != none )
	{
		MonsterArch = KFPM.GetCharacterMonsterInfo();
		if( MonsterArch != none && MonsterArch.DazedEffectTemplate != none && KFPM.WorldInfo.MyEmitterPool != none )
		{
			PSC = KFPM.WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment( MonsterArch.DazedEffectTemplate, KFPM.Mesh, default.DazedFXSocketName, true );
			if( PSC != none )
			{
				PSC.SetAbsolute( false, true, false );
				PSC.SetRotation( rotator(vect(0,0,1)) + default.DazedFXRelativeRotation );
				return PSC;
			}
		}
	}

	return none;
}

defaultproperties
{
	Handle=KFSM_Stunned

	StunnedAnim=Stun_Loop_V1
	WakeupAnims.Add(Stun_Wakeup_V1)
	WakeupAnims.Add(Stun_Wakeup_V2)
	WakeupAnims.Add(Stun_Wakeup_V3)

	StunDurationRange=(X=2.f, Y=4.f)
	PlayerStunDurationRange=(X=1.f, Y=1.5f)

	bAllowHitReactions=true
	bDisableMovement=TRUE
	bLockPawnRotation=TRUE

	DefaultAICommandClass=class'KFGame.AICommand_PushedBySM'
	bDisablesWeaponFiring=true
	bCanOnlyWanderAtEnd=true

	DazedFXSocketName=FX_Dazed
	DazedFXRelativeRotation=( Yaw=0,Pitch=16384,Roll=0 )
}
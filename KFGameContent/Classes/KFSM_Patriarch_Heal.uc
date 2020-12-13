//=============================================================================
// KFSM_Patriarch_Heal
//=============================================================================
// Patriarch's minigun barrage attack
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFSM_Patriarch_Heal extends KFSM_PlaySingleAnim;

/** Cached reference to pawn */
var KFPawn_ZedPatriarch MyPatPawn;

/** Current battle phase (0-3) */
var int BattlePhase;

/** Heal animation names */
var array<Name> HealAnimNames;

/** Pack the animation type we'll be using (changes depending on battle phase) */
static function byte PackSMFlags( int inBattlePhase )
{
	return inBattlePhase - 1;
}

/** Notification called when Special Move starts */
function SpecialMoveStarted( bool bForced, Name PrevMove )
{
	MyPatPawn = KFPawn_ZedPatriarch(KFPOwner);

	BattlePhase = MyPatPawn.SpecialMoveFlags;
	AnimName = HealAnimNames[BattlePhase];

	Super.SpecialMoveStarted( bForced,PrevMove );

	MyPatPawn.SetTimer( KFSkeletalMeshComponent(MyPatPawn.Mesh).GetAnimInterruptTime(AnimName), false, nameOf(DoHeal), self );
	MyPatPawn.RotationRate = rot(0,0,0);
}

function DoHeal()
{
	local float HealPercent;
	local int HealAmount, MyDifficulty;

	if( MyPatPawn != None && MyPatPawn.WorldInfo.Game != None )
	{
		// Set our difficulty and phase-based heal amount
		MyDifficulty = MyPatPawn.WorldInfo.Game.GetModifiedGameDifficulty();
		HealPercent = MyPatPawn.BattlePhases[BattlePhase].HealAmounts[MyDifficulty];

		// Randomly scale heal amount by +/-5%
		HealPercent *= 1.0 + ( fRand() < 0.5f ?  float(-Rand(50))*0.001f : float(Rand(50))*0.001f );

		// Amount to heal up to is a percentage of max health
		HealAmount = int( float(MyPatPawn.HealthMax) * (HealPercent - MyPatPawn.GetHealthPercentage()) );

		//`log("HealPercent:"@HealPercent);
		//`log("HealAmount:"@HealAmount);
		//`log("HealTotal:"@HealAmount+MyPatPawn.Health@"/"@MyPatPawn.HealthMax);

		// Perform heal
		if( HealAmount > 0 )
		{
			MyPatPawn.HealDamage( HealAmount, MyPatPawn.Controller, class'KFDT_Healing' );
			MyPatPawn.DisablebOnDeathAchivement();
		}

		// Exit flee and heal phase
		MyPatPawn.SetFleeAndHealMode( false );
	}

	// Play a material effect on the syringe
	if( MyPatPawn.WorldInfo.NetMode != NM_DedicatedServer )
	{
		MyPatPawn.ActiveSyringe = MyPatPawn.CurrentSyringeMeshNum;
		MyPatPawn.SyringeInjectTimeRemaining = MyPatPawn.SyringeInjectTimeDuration;
	}
}

/** Special move ended */
function SpecialMoveEnded( Name PrevMove, Name NextMove )
{
	if( MyPatPawn != none )
	{
		MyPatPawn.RotationRate = MyPatPawn.default.RotationRate;
		MyPatPawn.ClearTimer( nameOf(DoHeal) );
	}

	super.SpecialMoveEnded( PrevMove, NextMove );

	MyPatPawn = None;
}

DefaultProperties
{
	// SpecialMove
	Handle=KFSM_Patriarch_Heal
	bDisableTurnInPlace=true
	bDisableMovement=true
   	bUseRootmotion=true
   	bCanBeInterrupted=false

	// Animation
	HealAnimNames(0)=Heal_V1
	HealAnimNames(1)=Heal_V2
	HealAnimNames(2)=Heal_V3

	BlendInTime=0.15f
	BlendOutTime=0.1f
}
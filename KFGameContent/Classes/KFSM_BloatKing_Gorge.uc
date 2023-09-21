//=============================================================================
// KFSM_BloatKing_Gorge
//=============================================================================
// Bloat King gorge move. Pulls in friendly + enemy with different effects
//      on contact with the Bloat.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================
class KFSM_BloatKing_Gorge extends KFSM_PlaySingleAnim;

//Cached bloat reference
var KFPawn_ZedBloatKing BloatPawn;

//Ranges of the attack
var const float GorgeAttackRangeSq;
var const float GorgeHumanAttackRangeSq;

//Angle range that players/zeds have to be in for this to be a valid time to start
var const float GorgeMinAttackAngle;

//Amount of time to take before next attempted gorge after using the ability
var const Vector2D GorgeAttackCooldown[4];

//Amount of time to take between checks if starting the move was not valid
var const float GorgeAttackCheckDelay;

//amount of time to wait to start the pull when the special move starts
var const float GorgePullDelay;

//List of actors we're already pulling
var array<KFPawn> PullList;
var array<KFPawn> PulledList;

//Special move to do to the person being grabbed
var ESpecialMove FollowerSpecialMove;
var ESpecialMove ZedFollowerSpecialMove;

//Rate the pulled pawn moves towards the Bloat
var float GorgePullRate;

//Gorge release offset
var float GorgeReleaseOffset;

//Damage per-difficulty for human interaction
var float GorgeBaseDamage[4];

//Track whether pull is now valid
var bool bPullActive;

// List of pawns that need to be killed
var array<KFPawn> GorgeHitList;

// List of pawns that have to be removed as victims on next tick
//		SpecialMoveEnded happens in async tick work, so we can't change physics in that time
var array<KFPawn> DeferredRemovalList;

/** Contains a list of particle systems spawned during the move */
var protected array<ParticleSystemComponent> AnimParticles;

static function float GetGorgeCooldown(KFPawn InPawn, int Difficulty)
{
    return Lerp(default.GorgeAttackCooldown[Difficulty].X, default.GorgeAttackCooldown[Difficulty].Y, InPawn.GetHealthPercentage());
}

function SpecialMoveStarted(bool bForced, Name PrevMove)
{
    super.SpecialMoveStarted(bForced, PrevMove);

    BloatPawn = KFPawn_ZedBloatKing(KFPOwner);
	PulledList.Length = 0;
    KFPOwner.SetTimer(GorgePullDelay, false, 'StartGorgePull', self);
}

/** Called from KFPawn::OnAnimNotifyParticleSystemSpawned() */
function OnAnimNotifyParticleSystemSpawned( const AnimNotify_PlayParticleEffect AnimNotifyData, ParticleSystemComponent PSC )
{
	local AnimSequence AnimSeq;

	if (AnimNotifyData.Outer != none)
	{
		AnimSeq = AnimSequence(AnimNotifyData.Outer);
		if (AnimSeq != none && string(AnimSeq.SequenceName) ~= string(AnimName)) // string conversion so we don't have case mismatches
		{
			AnimParticles.AddItem( PSC );
		}
	}
}

function StartGorgePull()
{
    if (KFPOwner.Role == ROLE_Authority)
    {
		bPullActive = true;
    }
}

function SpecialMoveEnded(Name PrevMove, Name NextMove)
{
    local KFPawn PullPawn;
	local int i;

	bPullActive = false;

	for (i = PullList.Length - 1; i >= 0; --i)
	{
		PullPawn = PullList[i];
		if (KFPawn_Human(PullPawn) != none)
		{
			RemoveVictim(PullPawn, false);
		}
		else
		{
			DeferredRemovalList.AddItem(PullPawn);
		}
	}
	PullList.Length = 0;

	for (i = 0; i < AnimParticles.Length; ++i)
	{
		AnimParticles[i].DeactivateSystem();
	}
	AnimParticles.Length = 0;

	Super.SpecialMoveEnded(PrevMove, NextMove);
}

function PlayAnimation()
{
	local float Duration;

	Duration = PlaySpecialMoveAnim(AnimName, AnimStance, BlendInTime, BlendOutTime, 1.f, bLoopAnim);
	KFPOwner.SetTimer(Duration + 2.f, false, 'Timeout', self);
}

function Timeout()
{
	BloatPawn.EndSpecialMove();
}

function Tick(float DeltaTime)
{
	local KFPawn TestPawn;
	local KFPawn_Monster MonsterToKill;

    super.Tick(DeltaTime);

	if(KFPOwner.Role == ROLE_Authority)
	{
		if (GorgeHitList.length > 0)
		{
			foreach GorgeHitList(TestPawn)
			{
				if (TestPawn == none || !TestPawn.IsAliveAndWell())
				{
					continue;
				}

				MonsterToKill = KFPawn_Monster(TestPawn);
				if (MonsterToKill != none)
				{
					MonsterToKill.KilledBy(KFPOwner);
				}
				else
				{
					TestPawn.TakeDamage(GorgeBaseDamage[KFPOwner.WorldInfo.Game.GetModifiedGameDifficulty()], KFPOwner.Controller, TestPawn.Location, vect(0, 0, 0), class'KFDT_Bludgeon_BloatKingGorge');
				}
			}
			GorgeHitList.length = 0;
		}

		if (DeferredRemovalList.Length > 0)
		{
			foreach DeferredRemovalList(TestPawn)
			{
				RemoveVictim(TestPawn, false);
			}

			DeferredRemovalList.Length = 0;
		}

		if (bPullActive)
		{
			FindNewVictims();
		}
	}
    UpdateVictims(DeltaTime);
}

function FindNewVictims()
{
    local KFPawn PullPawn;
    local vector ViewDirection, ToTarget;
    local vector Extent, HitLocation, HitNormal;
    local Actor HitActor;
    local float DotAngle, ToTargetRange;

    if (BloatPawn.GorgeTrigger != None)
    {
        ViewDirection = Vector(KFPOwner.Rotation);
        foreach BloatPawn.GorgeTrigger.TouchingActors(class'KFPawn', PullPawn)
        {
            //Not currently being pulled, and not pulled within this cycle
            if (PullList.Find(PullPawn) == INDEX_NONE && PulledList.Find(PullPawn) == INDEX_NONE)
            {
                //Can target enemy and friendly, but they must be alive and can be filtered by class type
                //They must not already be grabbed
                //They must not already be in the current intended follower move
                if (!PullPawn.IsAliveAndWell() || !IsValidPullClass(PullPawn) || !PullPawn.CanBeGrabbed(KFPOwner, true, true) || PullPawn.IsDoingSpecialMove(FollowerSpecialMove))
                {
                    continue;
                }

                ToTarget = PullPawn.Location - KFPOwner.Location;
				ToTargetRange = VSizeSq(ToTarget);

                //Check distance.  If out of range, ignore this potential target.
				if (PullPawn.IsHumanControlled() && ToTargetRange > default.GorgeHumanAttackRangeSq)
				{
					continue;
				}
                else if (ToTargetRange > default.GorgeAttackRangeSq)
                {
                    continue;
                }

                if (!KFPOwner.IsHumanControlled())
                {
                    // Set our extent
                    Extent.X = KFPOwner.GetCollisionRadius() * 0.5f;
                    Extent.Y = Extent.X;
                    Extent.Z = KFPOwner.GetCollisionHeight() * 0.5f;

                    // trace for obstructions (already checked if IsHumanControlled())
                    HitActor = KFPOwner.Trace(HitLocation, HitNormal, PullPawn.Location, KFPOwner.Location, true, Extent);
                    if (HitActor != None && HitActor != PullPawn)
                    {
                        continue;
                    }
                }

                // Within field of view and not behind geometry
                DotAngle = ViewDirection dot Normal(ToTarget);
                if (DotAngle > default.GorgeMinAttackAngle && KFPOwner.FastTrace(PullPawn.Location, KFPOwner.Location))
                {
                    AddNewVictim(PullPawn);
                }
            }
        }
    }
}

static function bool IsValidPullClass(KFPawn PullPawn)
{
	local KFPawn_Monster MonsterPawn;

	MonsterPawn = KFPawn_Monster(PullPawn);

	if (PullPawn.class == class'KFPawn_ZedBloatKingSubspawn'
		|| MonsterPawn != none && MonsterPawn.IsABoss()
		|| PullPawn.class == class'KFPawn_HRG_Warthog'
		|| PullPawn.class == class'KFPawn_AutoTurret')
	{
		return false;
	}

	return true;
}

function UpdateVictims(float DeltaTime)
{
    local KFPawn CurrentPawn;
    local Vector MoveVector, SocketLocation;
	local Rotator SocketRotation;
    local int i;
	local bool bIsHuman;

	KFPOwner.Mesh.GetSocketWorldLocationAndRotation('PukeSocket', SocketLocation, SocketRotation);
    for (i = 0; i < 11; ++i)
    {
        CurrentPawn = BloatPawn.PullVictims[i];
        if (CurrentPawn != None)
        {
			bIsHuman = CurrentPawn.IsA('KFPawn_Human');
            //Reached end, stop pull and do things
            if (VSizeSq(CurrentPawn.Location - KFPOwner.Location) < GorgeReleaseOffset * GorgeReleaseOffset)
            {
                RemoveVictim(CurrentPawn, true);
            }
            //else keep pulling
            else
            {
				//Scoot humans along the ground
				if (bIsHuman)
				{
					MoveVector = (GorgePullRate * DeltaTime) * Normal(KFPOwner.Location - CurrentPawn.Location);
				}
				//Bring zeds towards mouth
				else
				{
					MoveVector = (GorgePullRate * DeltaTime) * Normal(SocketLocation - CurrentPawn.Location);
				}
                CurrentPawn.SetLocation(CurrentPawn.Location + MoveVector);
            }
        }
    }
}

function AddNewVictim(KFPawn NewVictim)
{
    //Found a target, so we're good to start the move
    PullList.AddItem(NewVictim);
    PulledList.RemoveItem(NewVictim);
    StartPullingPawn(NewVictim);

    if (BloatPawn.Role == ROLE_Authority)
    {
        BloatPawn.AddGorgeVictim(NewVictim);
    }
}

function RemoveVictim(KFPawn OldVictim, bool bReachedEnd = false)
{
	PullList.RemoveItem(OldVictim);
	PulledList.AddItem(OldVictim);

	if (BloatPawn.Role == ROLE_Authority)
	{
		BloatPawn.RemoveGorgeVictim(OldVictim);
		if (bReachedEnd && KFPawn_Monster(OldVictim) != none)
		{
			BloatPawn.SpawnPoopMonster();
		}
	}
	StopPullingPawn(OldVictim, bReachedEnd);
}

function StartPullingPawn(KFPawn NewVictim)
{
    if (NewVictim != None)
    {
        if (KFPOwner.Role == ROLE_Authority)
        {
			//Monster types use a different special move and also turn on explosive death from
			//	the Inflate weekly for special effects reasons.
			if (KFPawn_Monster(NewVictim) != none)
			{
				NewVictim.DoSpecialMove(ZedFollowerSpecialMove, true, KFPOwner);
				KFPawn_Monster(NewVictim).bUseExplosiveDeath = true;
			}
			else
			{
				NewVictim.DoSpecialMove(FollowerSpecialMove, true, KFPOwner);
			}
        }
    }
}

function StopPullingPawn(KFPawn OldVictim, bool bReachedEnd = true)
{
    local KFPawn_Monster MonsterVictim;

    if (OldVictim != None)
    {
        MonsterVictim = KFPawn_Monster(OldVictim);
        OldVictim.EndSpecialMove();

        if (KFPOwner.Role == ROLE_Authority)
		{
			if (MonsterVictim != None)
			{
				//Kill if this is a gorge finisher
				if (bReachedEnd)
				{
					GorgeHitList.AddItem(MonsterVictim);
				}
				//Otherwise turn off explosive death
				else
				{
					MonsterVictim.bUseExplosiveDeath = false;
				}
			}
			else
			{
				if(bReachedEnd)
				{
					GorgeHitList.AddItem(OldVictim);
				}
			}
		}
    }
}

function bool CanOverrideMoveWith(Name NewMove)
{
	if (NewMove == 'KFSM_Knockdown')
	{
		return TRUE;
	}

	return FALSE;
}

defaultproperties
{
    //Special Move
    Handle=KFSM_BloatKing_Gorge
    AnimName=Atk_Gorge
    AnimStance=EAS_FullBody
    bDisableSteering=true
    bDisableMovement=true
    bDisableTurnInPlace=true
	bLockPawnRotation=true
    bCanBeInterrupted=true
    CustomRotationRate=(Pitch=0, Yaw=0, Roll=0)

    //Gorge Specific
	//These are (0% health, 100% health)
    GorgeAttackCooldown[0]=(X=8.0,Y=11.0)   //normal //x35 y45
    GorgeAttackCooldown[1]=(X=8.0,Y=11.0)   //hard   //x25 y35
    GorgeAttackCooldown[2]=(X=7.0,Y=10.0)   //Suicidal //x15 y25
    GorgeAttackCooldown[3]=(X=6.0,Y=9.0)    //HOE   //x10 y15
    GorgeAttackCheckDelay=5.0
    GorgePullDelay=0.01 //0.91 0.61
    FollowerSpecialMove=SM_BloatKingGorgeVictim
	ZedFollowerSpecialMove=SM_GorgeZedVictim,
    GorgePullRate=300.0 //UU pur sec //1000  //375
    GorgeReleaseOffset=135 //300
    GorgeBaseDamage[0]=30      //normal
    GorgeBaseDamage[1]=40        //hard
    GorgeBaseDamage[2]=50       //Suicidal
    GorgeBaseDamage[3]=50       //HOE

    //1000 * 1000 - Squaring distance for performance
    //Also update the value in KFTrigger_BloatKingGorge or there may be some issues with first-frame spawn collision
    GorgeAttackRangeSq=490000		//490k = 700UU
	GorgeHumanAttackRangeSq=450000	//250k = 500UU 250000
    GorgeMinAttackAngle=0.77f
}
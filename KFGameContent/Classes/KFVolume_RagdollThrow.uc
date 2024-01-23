//=============================================================================
// KFvolume_RagdollThrow
//=============================================================================
// Volume for ragdolling and throwing a pawn in a specified direction.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
// Dan Weiss
//=============================================================================

class KFvolume_RagdollThrow extends KFDynamicPhysicsVolume
    placeable;

struct HitTracking
{
    var Actor HitActor;
    var float HitTime;
};

//Track hits to avoid doing multiple hits in a short period of time
var array<HitTracking> TrackedHits;

//Rate that limits how often a single zed can be hit
var() float RateLimiter;

//Whether or not to knockdown zeds
var() bool bKnockdownZeds;

//Whether or not to use a fixed direction for the throw. Uses Vector from center of Volume if false
var() bool bFixedThrowVector;

//Vector to use for throwing a zed in a fixed direction
var() Vector ThrowDirection <EditCondition=bFixedThrowVector>;

//List of classes to exclude from being hit
var() array<class<KFPawn> > HitExclusionList;

//Hard exclusion for anything listed as a boss (useful for weekly events where we may have non-boss bosses)
var() bool bExcludeAnyBoss;

simulated event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
    local KFPawn_Human KFPH;
    local KFPawn_Monster KFPM;
    local Vector HitDirection;
    local int LastHitIdx;
    local HitTracking NewHit;

    super.Touch(Other, OtherComp, HitLocation, HitNormal);

    if (Role != ROLE_Authority)
    {
        return;
    }

    LastHitIdx = TrackedHits.Find('HitActor', Other);

    //Remove any tracked hits that have gone beyond the tracked limiter time
    if (LastHitIdx != INDEX_NONE)
    {
        if (`TimeSince(TrackedHits[LastHitIdx].HitTime) < RateLimiter)
        {
            return;
        }

        TrackedHits.Remove(LastHitIdx, 1);
    }

    //Check for classes excluded from being hit
    if(IsActorExcluded(Other))
    {
        return;
    }

    KFPH = KFPawn_Human(Other);
    KFPM = KFPawn_Monster(Other);

    if (KFPH != none || KFPM != none)
    {
        if (bFixedThrowVector)
        {
            HitDirection = Normal(ThrowDirection);
        }
        else
        {
            HitDirection = Other.Location - Location;
            HitDirection.Z = DamageType.default.KDeathUpKick;
            HitDirection = Normal(HitDirection);
        }

        //Humans can't ragdoll, simply throw them
        if (KFPH != none)
        {
            KFPH.HandleMomentum(HitDirection * DamageType.default.KDamageImpulse, HitLocation, DamageType);
        }
        else if (KFPM != none)
        {
            //Catch any boss exclusions, including weekly non-boss bosses
            if (bExcludeAnyBoss && KFPM.IsABoss())
            {
                return;
            }

            //If zeds can be knocked down, use that and have the damage impulse be based on the intended direction, otherwise just throw
            if (bKnockdownZeds)
            {
                KFPM.Knockdown(HitDirection * DamageType.default.KDamageImpulse, vect(1, 1, 1), , , , DamageType.default.KDamageImpulse * HitDirection, Location);
            }
            else
            {
                KFPM.HandleMomentum(HitDirection * DamageType.default.KDamageImpulse, HitLocation, DamageType);
            }
        }

        //Add tracked hit to engage limiter
        NewHit.HitActor = Other;
        NewHit.HitTime = WorldInfo.TimeSeconds;
        TrackedHits.AddItem(NewHit);
    }
}

simulated function CausePainTo(Actor Other)
{
	if(!IsActorExcluded(Other))
	{
		super.CausePainTo(Other);
	}
}

simulated function bool IsActorExcluded(Actor Other)
{
	return HitExclusionList.Find(Other.class) != INDEX_NONE;
}

defaultproperties
{
    RateLimiter=0.1
    bKnockdownZeds=true
    bExcludeAnyBoss=true
}

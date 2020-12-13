//=============================================================================
// KFMGA_Rollercoaster
//=============================================================================
// Specific implementation of the animated trap type with extensions for the
//      rollercoaster trap.  Mostly deals with timing of turning on damage
//      volumes, as well as the left/right movement of the trap.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Dan Weiss
//=============================================================================

class KFMGA_Rollercoaster extends KFMGA_AnimatedTrap;

/** Amount of time to move to the end position.  Cached from base class MovementTime */
var float MovementStartTime;

/** Amount of time to take to move back to the starting position.  If this is zero, gets set to match MovementTime */
var() float MovementBackTime;

/** Button to move left */
var() KFTrigger_MinigameButton MoveLeftButton;

/** Button to move right */
var() KFTrigger_MinigameButton MoveRightButton;

/** Which direction the coaster is travelling. Used to trigger client movement */
var repnotify int MoveDirection;

/** Default movement vector, cached from base class MovementVector */
var Vector CachedMovementVector;

/** Move vector in the opposite direction. If this is the zero vector, gets set to -MovementDirection */
var() Vector RightMoveVector;

/** Move time in the opposite direction.  If this is zero, gets set to match MovementTime */
var() float RightMovementTime;

/** Move back time in the opposite direction.  If this is zero, gets set to match MovementBackTime */
var() float RightMovementBackTime;

/** Physics volumes for the two ends of the coaster car.  Enabling/disabling in code to time better compared to Kismet, while leaving LD option for location and setup intact. */
var() KFDynamicPhysicsVolume LeftPhysicsVolume;
var() KFDynamicPhysicsVolume RightPhysicsVolume;

replication
{
    if (bNetDirty)
        MoveDirection;
}

simulated event PostBeginPlay()
{
    super.PostBeginPlay();

    //Cache off some values from base class
    MovementStartTime = MovementTime;
    CachedMovementVector = MovementVector;

    //Verify safe defaults on server/client
    if (MovementBackTime <= 0.f)
    {
        MovementBackTime = MovementTime;
    }

    if (VSize(RightMoveVector) <= 0.f)
    {
        RightMoveVector = -MovementVector;
    }

    if (RightMovementTime <= 0.f)
    {
        RightMovementTime = MovementTime;
    }

    if (RightMovementBackTime <= 0.f)
    {
        RightMovementBackTime = MovementBackTime;
    }

    if (LeftPhysicsVolume != none)
    {
        LeftPhysicsVolume.SetCollisionType(COLLIDE_NoCollision);
    }

    if (RightPhysicsVolume != none)
    {
        RightPhysicsVolume.SetCollisionType(COLLIDE_NoCollision);
    }
}

function bool CanBeActivated(KFTrigger_MinigameButton ActivationSource)
{
    return !bActivated;
}

/** Client activation is being handled a bit different due to need to know direction to move.
 *  For the rollercoaster, intercept bActivated and only respond to it if deactivating.
 */
simulated event ReplicatedEvent(name VarName)
{
    if (VarName == 'bActivated')
    {
        if (!bActivated)
        {
            PlayDeactivation();
        }
    }
    else if (VarName == 'MoveDirection')
    {
        if (MoveDirection >= 0)
        {
            PlayActivation();
        }
    }
    else
    {
        super.ReplicatedEvent(VarName);
    }
}

/** Big change from base implementation is that we're modifying MovementTime and MovementVector
 *      manually in the next handful of functions.  The original values are cached off at the start
 *      of play for reuse later, based on direction we're moving the rollercoaster trap.
 */
function Activated(KFTrigger_MinigameButton ActivationSource)
{
    if (!bActivated)
    {
        if (ActivationSource == MoveLeftButton)
        {
            MoveDirection = 0;
            if (LeftPhysicsVolume != none)
            {
                LeftPhysicsVolume.SetCollisionType(COLLIDE_TouchAll);
            }
        }
        else if (ActivationSource == MoveRightButton)
        {
            MoveDirection = 1;
            if (RightPhysicsVolume != none)
            {
                RightPhysicsVolume.SetCollisionType(COLLIDE_TouchAll);
            }
        }
    }    

    super.Activated(ActivationSource);
}

function Deactivated()
{
    super.Deactivated();

    if (bActivated)
    {
        MoveDirection = -1;
    }
}

simulated function PlayActivationIdle()
{
    MovementTime = MoveDirection == 0 ? MovementStartTime : RightMovementTime;
    super.PlayActivationIdle();
}

simulated function PlayDeactivation()
{
    MovementTime = MoveDirection == 0 ? MovementBackTime : RightMovementBackTime;
    super.PlayDeactivation();
}

simulated function SetMoveActivationCurve()
{
    //Left
    if (MoveDirection == 0)
    {
        MovementVector = CachedMovementVector;
    }
    //Right
    else
    {
        MovementVector = RightMoveVector;
    }
    super.SetMoveActivationCurve();
}

simulated state Moving
{
    //Reset linked physics volumes, regardless of direction moved
    simulated function EndMovement()
    {
        if (LeftPhysicsVolume != none)
        {
            LeftPhysicsVolume.SetCollisionType(COLLIDE_NoCollision);
        }

        if (RightPhysicsVolume != none)
        {
            RightPhysicsVolume.SetCollisionType(COLLIDE_NoCollision);
        }

        super.EndMovement();
    }
}

defaultproperties
{
    MoveDirection = -1
}
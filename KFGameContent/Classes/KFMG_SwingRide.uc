//=============================================================================
// KFMG_SwingRide
//=============================================================================
// Custom code for swing ride minigame. Rotates in code to avoid Matinee
//      client/server desync issues doing it directly in the level.  Client
//      simulates movement to reduce hitching caused by lower server tick rate.
//
// Note: Ticking enabled while rotation is occuring.  Otherwise uses optimized
//      setup from the skeletal actor base class.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Dan Weiss
//=============================================================================

class KFMG_SwingRide extends SkeletalMeshActor
    placeable
    implements(KFInterface_MinigameActor);

/** Amount of time to full speed */
var() float SpinUpTime;

/** Amount of time from deactivation to full stop */
var() float SpinDownTime;

/** Amount of rotation per second (in Rotator units) */
var() float RotationPerSecond;

/** Trigger to start client simulation */
var repnotify bool bSwingActive;

/** Curves for bringing the ride up to speed and to stop */
var InterpCurveFloat SpinUpCurve;
var InterpCurveFloat SpinDownCurve;

replication
{
    if (bNetDirty)
        bSwingActive;
}

simulated event ReplicatedEvent(name VarName)
{
    super.ReplicatedEvent(VarName);

    if (VarName == 'bSwingActive')
    {
        if (bSwingActive)
        {
            Activated(none);
        }
        else
        {
            Deactivated();
        }
    }
}

/** Whether this is in a valid state */
function bool CanBeActivated(KFTrigger_MinigameButton ActivationSource)
{
    return true;
}

/** Called on rigged games to check whether a target at a specific bone can be played */
simulated event bool CanPlayAkEvent(Actor inOwner, name BoneName)
{
    return true;
}

/** Setup accel curves here.  Since they're dynamic based on times, poke around in code to get the values you want */
simulated function SetSpinUpCurve()
{
    SpinUpCurve.Points.Length = 4;

    SpinUpCurve.Points[0].InVal = 0;
    SpinUpCurve.Points[0].OutVal = 0;
    SpinUpCurve.Points[0].InterpMode = CIM_CurveAuto;

    SpinUpCurve.Points[1].InVal = 0.25 * SpinUpTime;
    SpinUpCurve.Points[1].OutVal = RotationPerSecond * 0.15f;
    SpinUpCurve.Points[1].InterpMode = CIM_CurveAuto;

    SpinUpCurve.Points[2].InVal = 0.75 * SpinUpTime;
    SpinUpCurve.Points[2].OutVal = RotationPerSecond * 0.85f;
    SpinUpCurve.Points[2].InterpMode = CIM_CurveAuto;

    SpinUpCurve.Points[3].InVal = SpinUpTime;
    SpinUpCurve.Points[3].OutVal = RotationPerSecond;
    SpinUpCurve.Points[3].InterpMode = CIM_CurveAuto;
}

simulated function SetSpinDownCurve()
{
    SpinDownCurve.Points.Length = 4;

    SpinDownCurve.Points[0].InVal = 0;
    SpinDownCurve.Points[0].OutVal = RotationPerSecond;
    SpinDownCurve.Points[0].InterpMode = CIM_CurveAuto;

    SpinDownCurve.Points[1].InVal = 0.25 * SpinDownTime;
    SpinDownCurve.Points[1].OutVal = RotationPerSecond * 0.85f;
    SpinDownCurve.Points[1].InterpMode = CIM_CurveAuto;

    SpinDownCurve.Points[2].InVal = 0.75 * SpinDownTime;
    SpinDownCurve.Points[2].OutVal = RotationPerSecond * 0.15f;
    SpinDownCurve.Points[2].InterpMode = CIM_CurveAuto;

    SpinDownCurve.Points[3].InVal = SpinDownTime;
    SpinDownCurve.Points[3].OutVal = 0;
    SpinDownCurve.Points[3].InterpMode = CIM_CurveAuto;
}

simulated function Activated(KFTrigger_MinigameButton ActivationSource)
{
    SetTickIsDisabled(false);
    bSwingActive = true;
    SetSpinUpCurve();
    SetTimer(SpinUpTime, false, 'EnableFullRide');
    GoToState('SpinUp');
}

simulated function Deactivated()
{
    if (IsInState('Active') || IsInState('SpinUp'))
    {
        bSwingActive = false;
        SetTimer(SpinDownTime, false, 'RideStopped');
        SetSpinDownCurve();
        GoToState('SpinDown');
    }    
}

/** Default state, do nothing */
auto simulated state Stopped
{
    simulated event BeginState(Name PreviousStateName)
    {
        super.BeginState(PreviousStateName);

        SetTickIsDisabled(true);
    }
}

/** Spin up state.  Accelerate fake rotation up to full speed */
simulated state SpinUp
{
    simulated event Tick(float DeltaTime)
    {
        local Rotator NewRotation;
        global.Tick(DeltaTime);

        NewRotation = Rotation;
        NewRotation.Yaw = (NewRotation.Yaw + (EvalInterpCurveFloat(SpinUpCurve, GetTimerCount('EnableFullRide')) * DeltaTime)) % 65536;

        SetRotation(NewRotation);
    }

    simulated function EnableFullRide()
    {
        GoToState('Active');
    }

    /** Don't allow activation while it's spinning up or spinning down */
    function bool CanBeActivated(KFTrigger_MinigameButton ActivationSource)
    {
        return false;
    }
}

/** Active state.  Maintain rotation until ride is shut down */
simulated state Active
{
    simulated event Tick(float DeltaTime)
    {
        local Rotator NewRotation;
        global.Tick(DeltaTime);

        NewRotation = Rotation;
        NewRotation.Yaw = (NewRotation.Yaw + (RotationPerSecond * DeltaTime)) % 65536;

        SetRotation(NewRotation);
    }
}

/** Spin down state.  Decelerate fake rotation until stopped */
function RideStopped();
simulated state SpinDown
{
    simulated event Tick(float DeltaTime)
    {
        local Rotator NewRotation;
        global.Tick(DeltaTime);

        NewRotation = Rotation;
        NewRotation.Yaw = (NewRotation.Yaw + (EvalInterpCurveFloat(SpinDownCurve, GetTimerCount('RideStopped')) * DeltaTime)) % 65536;

        SetRotation(NewRotation);
    }

    simulated function RideStopped()
    {
        GoToState('Stopped');
    }

    /** Don't allow activation while it's spinning up or spinning down */
    function bool CanBeActivated(KFTrigger_MinigameButton ActivationSource)
    {
        return false;
    }
}

defaultproperties
{
    SpinUpTime = 1.5f
    SpinDownTime = 1.5f

    RemoteRole = ROLE_SimulatedProxy
    NetPriority = +00002.500000
    bUpdateSimulatedPosition = true
    bAlwaysRelevant = true
}
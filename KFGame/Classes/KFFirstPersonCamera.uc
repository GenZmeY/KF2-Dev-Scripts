//=============================================================================
// KFFirstPersonCamera
//=============================================================================
// Camera class for viewing actors in first-person
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// It Was Me
//=============================================================================
class KFFirstPersonCamera extends GameCameraBase
	config(Camera);

/** Expected to fill in OutVT with new camera pos/loc/fov. */
function UpdateCamera(Pawn P, GamePlayerCamera CameraActor, float DeltaTime, out TViewTarget OutVT)
{
	if( P == None && OutVT.Target != None )
	{
		OutVT.Target.GetActorEyesViewPoint( OutVT.POV.Location, OutVT.POV.Rotation );
	}
	// give pawn chance to hijack the camera and do it's own thing.
	else if( (P != None) && !P.CalcCamera(DeltaTime, OutVT.POV.Location, OutVT.POV.Rotation, OutVT.POV.FOV) )
	{
		PlayerUpdateCamera(P,CameraActor, DeltaTime, OutVT);
	}

	PlayerCamera.ApplyCameraModifiers(DeltaTime, OutVT.POV);

	// if we had to reset camera interpolation, then turn off flag once it's been processed.
	bResetCameraInterpolation = FALSE;
}

/** Internal camera updating code */
protected function PlayerUpdateCamera(Pawn P, GamePlayerCamera CameraActor, float DeltaTime, out TViewTarget OutVT)
{
	local vector Loc;
	local rotator Rot;

	OutVT.Target.GetActorEyesViewPoint(Loc, Rot);

	// only smooth if we're viewing another client's pawn (e.g. spectating)
	if( OutVT.Target.Role == ROLE_SimulatedProxy )
	{
		OutVT.POV.Location = VInterpTo( OutVT.POV.Location, Loc, DeltaTime, 30.0 );
		OutVT.POV.Rotation = RInterpTo( OutVT.POV.Rotation, Rot, DeltaTime, 30.0 );
	}
	else
	{
		OutVT.POV.Location = Loc;
		OutVT.POV.Rotation = Rot;
	}
}

defaultproperties
{
}

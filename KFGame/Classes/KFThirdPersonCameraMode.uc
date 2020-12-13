//=============================================================================
// KFThirdPersonCameraMode
//=============================================================================
// Camera mode for third person
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFThirdPersonCameraMode extends GameThirdPersonCameraMode_Default
	config(Camera);

/** Copy view offset and invert Y-Axis */
simulated function InvertViewOffset()
{
	local ViewOffsetData NewViewOffset;

	NewViewOffset = ViewOffset;
	NewViewOffset.OffsetHigh.Y *= -1;
	NewViewOffset.OffsetMid.Y *= -1;
	NewViewOffset.OffsetLow.Y *= -1;

	bInterpViewOffsetOnlyForCamTransition = default.bInterpViewOffsetOnlyForCamTransition;
	BlendTime = default.BlendTime;

	// reset accumulated interp speed (see bInterpViewOffsetOnlyForCamTransition)
	ViewOffsetInterp = 1.f / BlendTime;

	SetViewOffset( NewViewOffset );
}

static function ViewOffsetData GetDefaultOffset()
{
	return default.ViewOffset;
}

defaultproperties
{
	ViewOffset={(
		OffsetHigh=(X=-96,Y=56,Z=16),
		OffsetLow=(X=-120,Y=48,Z=16),
		OffsetMid=(X=-120,Y=48,Z=0),
		)}
}


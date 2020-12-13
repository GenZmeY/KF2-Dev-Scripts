//=============================================================================
// KFThirdPersonCamera
//=============================================================================
// Camera for third person
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFThirdPersonCamera extends GameThirdPersonCamera
	config(Camera);

var bool bInvertY;

/** Used to change view offset per zed */
simulated function SetViewOffset( ViewOffsetData NewViewOffset, optional bool bInterpolate, optional float InterpTime )
{
	if( bInterpolate )
	{
		ThirdPersonCamDefault.bInterpViewOffsetOnlyForCamTransition = false;
		ThirdPersonCamDefault.BlendTime = InterpTime;
	}
	else
	{
		ThirdPersonCamDefault.bInterpViewOffsetOnlyForCamTransition = true;
	    ThirdPersonCamDefault.BlendTime = ThirdPersonCamDefault.default.BlendTime;
	}

	if ( bInvertY )
	{
		NewViewOffset.OffsetHigh.Y *= -1;
		NewViewOffset.OffsetMid.Y *= -1;
		NewViewOffset.OffsetLow.Y *= -1;
	}

    ThirdPersonCamDefault.SetViewOffset( NewViewOffset );	
}

/** Access protected member ThirdPersonCamDefault */
simulated function InvertViewOffset(bool bNewInvertY)
{
	if ( bInvertY != bNewInvertY )
	{
		bInvertY = bNewInvertY;
		KFThirdPersonCameraMode(ThirdPersonCamDefault).InvertViewOffset();
	}
}

defaultproperties
{
	ThirdPersonCamDefaultClass=class'KFThirdPersonCameraMode'
}
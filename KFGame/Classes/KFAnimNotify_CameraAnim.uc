//=============================================================================
// KFAnimNotify_ViewShake
//=============================================================================
// Anim notify to play local player camera animations
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Andrew "Strago" Ladenberger
//=============================================================================

class KFAnimNotify_CameraAnim extends AnimNotify
	native(Anim);

/** Reference to the CameraAnim to play in conjunction with this animation. */
var(Camera)			CameraAnim	CameraAnim;
/** True to loop the CameraAnim, false for a one-off. */
var(Camera)			bool		bLoopCameraAnim;
/** True to randomize the CameraAnims start position, so it doesn't look the same every time.  Ignored if bLoopCameraAnim is false. */
var(Camera)			bool		bRandomizeCameraAnimLoopStartTime;
/** "Intensity" multiplier applied to the camera anim. */
var(Camera)			float		CameraAnimScale;
/** How fast to playback the camera anim. */
var(Camera)			float		CameraAnimPlayRate;
/** How long to blend in the camera anim. */
var(Camera)			float		CameraAnimBlendInTime;
/** How long to blend out the camera anim. */
var(Camera)			float		CameraAnimBlendOutTime;

cpptext
{
	// AnimNotify interface.
	virtual void Notify( class UAnimNodeSequence* NodeSeq );
}

defaultproperties
{
	NotifyColor=(R=255,G=64,B=255)

	CameraAnimPlayRate=1.f
	CameraAnimScale=1.f
	CameraAnimBlendInTime=0.2f
	CameraAnimBlendOutTime=0.2f
}
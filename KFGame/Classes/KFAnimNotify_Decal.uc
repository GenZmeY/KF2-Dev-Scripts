//=============================================================================
// KFAnimNotify_Decal
//=============================================================================
// Based on GOW3 GearAnimNotify_GearDecal
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFAnimNotify_Decal extends AnimNotify
	native(Anim);

struct native DecalData
{
	/** Used internally for validate the struct contains useful data */
	var bool bIsValid;
	/** Material and any other properties that are needed for impact decals */
	var() MaterialInterface DecalMaterial;	
	/** Width of the decal **/
	var() float Width;
	/** Height of the decal **/
	var() float Height;
	/** Thickness of the decal (used to calculate the nearplane/farplane values) **/
	var() float Thickness;

	/** Whether to skip this decal entirely when perf is slow */
	var() bool bSkip_ForSlowPerf;

	structdefaultproperties
	{
		Width=6.0f
		Height=6.0f
		Thickness=10.0f
	}
};

// Optimization
var() bool			  bIgnoreIfActorHidden;
/** BoneName or SocketName to use */
var() Name			  BoneOrSocketName;
/** Relative Location for Trace Direction */
var() Vector		  RelativeLocation;
/** Relative Rotation for Trace Direction */
var() Rotator		  RelativeRotation;
/** How far to trace in the specified direction */
var() float			  TraceDistance;
/** The material to use for the decal */
var() DecalData		  Decal;
/** Will only trace straight down regardless of bone or socket orientation */
var() bool			  bOnlyTraceDown;

/** Arrow Component to visualize in editor */
var editoronly ArrowComponent MyArrowComponent;

cpptext
{
	// AnimNotify interface.
	virtual void Notify( class UAnimNodeSequence* NodeSeq );
	virtual FString GetEditorComment() { return TEXT("Decal"); }
}

event SpawnDecal( Actor Owner, vector TraceLocation, vector TraceDir )
{
	local Actor HitActor;
	local vector HitLocation, HitNormal;
	local TraceHitInfo HitInfo;	

	//Owner.DrawDebugLine( TraceLocation, TraceLocation + TraceDir * TraceDistance, 0, 255, 0, TRUE );
	if( Owner.WorldInfo.MyDecalManager != none && (!Owner.WorldInfo.bDropDetail || !Decal.bSkip_ForSlowPerf) )
	{
		//Owner.DrawDebugSphere( TraceLocation, 24, 8, 0, 255, 0, TRUE );
		if( bOnlyTraceDown )
		{
			TraceDir.X = 0;
			TraceDir.Y = 0;
			TraceDir.Z = -1;

		}
		//Owner.DrawDebugSphere( TraceLocation, 32, 8, 255, 0, 0, true );
		//Owner.DrawDebugLine( TraceLocation, TraceLocation + TraceDir * TraceDistance, 0, 255, 0, true );
		HitActor = Owner.Trace(HitLocation, HitNormal, TraceLocation + TraceDir * TraceDistance, TraceLocation, false,, HitInfo);
		if( HitActor != None )
		{
			CreateDecal( Owner, Decal, HitActor, HitLocation, HitNormal, HitInfo );
		}
	}
}

/** Helper for SpawnExplosionDecal() to perform the actual creation of the object */
simulated function DecalComponent CreateDecal(Actor Owner, const out DecalData outDecalData, Actor HitActor, vector HitLocation, vector HitNormal, const out TraceHitInfo HitInfo)
{
	local DecalComponent DC;

 	if( Owner.WorldInfo.MyDecalManager != none )
 	{
		DC = Owner.WorldInfo.MyDecalManager.SpawnDecal( outDecalData.DecalMaterial, HitLocation, rotator(-HitNormal), outDecalData.Width, outDecalData.Height, outDecalData.Thickness, true);
	}

	return DC;
}

defaultproperties
{
	bIgnoreIfActorHidden=true
	TraceDistance=128.f
	bOnlyTraceDown=true
	// To visualize in editor
	Begin Object Class=ArrowComponent Name=ArrowComponent0
		bTreatAsASprite=True
		HiddenGame=true
	End Object
	MyArrowComponent=ArrowComponent0
}

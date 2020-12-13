/**
 * Copyright 1998-2013 Epic Games, Inc. All Rights Reserved.
 *
 * Used to affect reverb settings in the game and editor.
 */
class ReverbVolume extends Volume
	native
	placeable
	dontsortcategories(ReverbVolume)
	hidecategories(Advanced, Attachment, Collision, Volume, Toggle);

/**
 * Indicates a reverb preset to use.
 */
enum ReverbPreset
{
    REVERB_Default,
    REVERB_Bathroom,
    REVERB_StoneRoom,
    REVERB_Auditorium,
    REVERB_ConcertHall,
    REVERB_Cave,
    REVERB_Hallway,
    REVERB_StoneCorridor,
    REVERB_Alley,
    REVERB_Forest,
    REVERB_City,
    REVERB_Mountains,
    REVERB_Quarry,
    REVERB_Plain,
    REVERB_ParkingLot,
    REVERB_SewerPipe,
    REVERB_Underwater,
    REVERB_SmallRoom,
    REVERB_MediumRoom,
    REVERB_LargeRoom,
    REVERB_MediumHall,
    REVERB_LargeHall,
    REVERB_Plate,
};

/** Struct encapsulating settings for reverb effects. */
struct native ReverbSettings
{
	var() bool			bApplyReverb<ToolTip=Whether to apply the reverb settings below>;

	/** The reverb preset to employ. */
	var() ReverbPreset	ReverbType;

	/** Volume level of the reverb affect. */
	var() float			Volume;

	/** Time to fade from the current reverb settings into this setting, in seconds. */
	var() float			FadeTime;

	structdefaultproperties
	{
		bApplyReverb=true
		ReverbType=REVERB_Default
		Volume=0.5
		FadeTime=2.0
	}
};

/** Struct encapsulating settings for interior areas. */
//@warning: manually mirrored in UnActorComponent.h
struct InteriorSettings
{
	var	  bool			bIsWorldInfo;

	var() float			ExteriorVolume;
	var() float			ExteriorTime;

	var() float			ExteriorLPF;
	var() float			ExteriorLPFTime;

	var() float			InteriorVolume;
	var() float			InteriorTime;

	var() float			InteriorLPF;
	var() float			InteriorLPFTime;

	structdefaultproperties
	{
		bIsWorldInfo=false
		ExteriorVolume=1.0f
		ExteriorTime=0.5f
		InteriorVolume=1.0f
		InteriorTime=0.5f
		ExteriorLPF=1.0f
		ExteriorLPFTime=0.5f
		InteriorLPF=1.0f
		InteriorLPFTime=0.5f
	}
};

/**
 * Priority of this volume. In the case of overlapping volumes the one with the highest priority
 * is chosen. The order is undefined if two or more overlapping volumes have the same priority.
 */
var() float Priority;
/** whether this volume is currently enabled and able to affect sounds */
var(Toggle) bool bEnabled;

/** Reverb settings to use for this volume. */
var(UAudio) ReverbSettings Settings;
/** Interior settings used for this volume */
var(UAudio) InteriorSettings AmbientZoneSettings;

/** Next volume in linked listed, sorted by priority in descending order. */
var const noimport transient ReverbVolume NextLowerPriorityVolume;

cpptext
{
	/**
	 * Removes the reverb volume to world info's list of reverb volumes.
	 */
	virtual void ClearComponents();

	/**
	 * callback for changed property
	 */
	virtual void PostEditChangeProperty(FPropertyChangedEvent& PropertyChangedEvent);

#if __TW_WWISE_
    /**
     * applies reverb settings to active AkComponents
     */
	virtual void SetEnvironmentalEffects(){}

    /**
     * returns name of associated environment
     */
	virtual FName GetEnvironmentName(){ return NAME_None; }

	/**
	 * returns scalar for occlusion within same volume
	 */
	virtual float GetIntraVolumeOcclusionScalar(){ return 1.f; }
#endif // __TW_WWISE_

protected:
	/**
	 * Adds the reverb volume to world info's list of reverb volumes.
	 */
	virtual void UpdateComponentsInternal( UBOOL bCollisionUpdate = FALSE );
public:
}

replication
{
	if (bNetDirty)
		bEnabled;
}

`if(`__TW_WWISE_)
// Implemented in subclasses
simulated function float GetEnvironmentEchoDistance(){return 2500.0;} // 25 meters
`endif //__TW_WWISE_

defaultproperties
{
	Begin Object Name=BrushComponent0
		CollideActors=False
		BlockActors=False
		BlockZeroExtent=False
		BlockNonZeroExtent=False
		BlockRigidBody=False
	End Object

	bColored=True
	BrushColor=(R=255,G=255,B=0,A=255)

	bEnabled=true
	bCollideActors=False
	bBlockActors=False
	bProjTarget=False
	SupportedEvents.Empty
	SupportedEvents(0)=class'SeqEvent_Touch'
}

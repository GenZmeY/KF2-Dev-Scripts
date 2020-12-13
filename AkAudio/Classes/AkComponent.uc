class AkComponent extends ActorComponent
	native
	collapsecategories
	hidecategories(Object)
	hidecategories(ActorComponent)
	editinlinenew;

var()	Name		BoneName;
var     AkEvent     AutoPlayEvent;

/** Stop sound when owner is destroyed */
var		bool		bStopWhenOwnerDestroyed;

`if(`__TW_WWISE_)
/** Whether this component is part of the audio device component pool (set to true in UAkAudioDevice::GetPooledAkComponent) */
var 	transient	const 	bool	bPooled;
/** Whether this component is ready to be returned to pool. Gets set on the audio thread, while component actually gets returned on the main thread. */
var 	transient	const	bool	bWaitingToReturnToPool;
/** Whether sound should follow owner position */
var     transient	const 	bool 	bFollowOwnerPosition;
/** Whether events being played are modified based on listener distance */
var     transient			bool	bUpdateDistanceToListener;
/** Whether events being played are modified based on relative velocity to listener (e.g. for Doppler) */
var     transient			bool    bUpdateRelativeVelocityToListener;

/** Whether this component is forced to use its own OcclusionUpdateInterval (set in defaultproperties) or can adopt a posted event's interval */
var							bool	bForceOcclusionUpdateInterval; // JDR: can't be transient because we set this in default properties
/** How often to update occlusion or obstruction. Zero means never update. Is set per posted event unless bForceOcclusionUpdateInterval is true. */
var     					float	OcclusionUpdateInterval; // JDR: can't be transient because we set this in default properties
/** last time we updated occlusion */
var     transient 			float	LastOcclusionUpdateTime;
/** whether we were occluded the last time we checked */
var		transient			bool	bWasOccluded;

/** Maximum attenuation value of all events played on this component (gets reset when/if component is returned to component pool)*/
var transient				float	MaxAttenuationValue;

/** The specific location to play this sound. Bone locations specified in BoneName will override this. If not specified plays from the attached actor's location */
var	    transient			vector	Location;
/** The relative location to play this sound on based on the location of the actor this component is attached to. Directly setting the location will override this */
var	    transient			vector	RelativeLocation;

/** AK::SoundEngine::Query calls (such as GetPosition (of game object)) can take milliseconds (bad).
  * Instead, just cache each game object's (AkComponent) position at the same time that it's passed off to the SoundEngine (in SetObjectPosition).
  */
var		transient 			vector	CachedObjectPosition;

/** AkEvent to play when this AKComponent stops playing */
var     transient			AkEvent StopPlayEvent;

/** Filled by AkEvents when they're posted. Reset when/if component is returned to pool */
var 	transient   		array<name> 	CustomRTPCNames;

/** Stops all events being played on this component */
native function StopEvents();

/** Play the given event directly on this component (doesn't go through PlaySoundBase, requires custom replication if desired) */
native function PlayEvent( AkEvent in_Event, optional bool bIsSpatialized, optional bool bIsOccluded, optional bool bDoNotCheckOcclusion );

/** Sets a real-time parameter control on this component */
native function SetRTPCValue( string RTPCString, float RTPCValue );

/** Checks if this component is playing any event, or a specific event if one is provided */
native function bool IsPlaying( optional AkEvent Event );

`endif // __TW_WWISE_

cpptext
{
	// Object interface.
	virtual void Serialize(FArchive& Ar);
	virtual void Attach();
	virtual void Detach( UBOOL bWillReattach = FALSE );
	virtual void FinishDestroy();
	virtual void ShutdownAfterError();

	// Methods
	void UnregisterGameObject();
	void Stop();

#if __TW_WWISE_
	// determines if this component should check occlusion
	virtual bool ShouldUpdateOcclusion();
	// determines if the listener is witin the max attenuation range of the component
	virtual bool ListenerWithinMaxRange( INT ListenerIndex = 0 );
	// checks occlusion (AudioComponent::CheckOcclusion)
	virtual void UpdateOcclusion( INT ListenerIndex = 0);
#endif // __TW_WWISE_
}

defaultproperties
{
`if(`__TW_WWISE_)
    bFollowOwnerPosition=True
`endif
}

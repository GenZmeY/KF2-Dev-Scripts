class AkEvent extends AkBaseSoundObject
	native;

var() AkBank RequiredBank;

/** The range at which the sound has attenuated completely (-1: no sound; 0: 2D; 3D otherwise) */
var(TW)     const float   MaxAudibleDistance<EditCondition=bOverrideMaxAudibleDistance>;
/** (Advanced) Check this flag to be able to modify MaxAudibleDistance instead of using the "MaxAttenuation" value from WWise */
var(TW)     const bool    bOverrideMaxAudibleDistance;

/** How long this event plays for */
var(TW) editconst float   Duration;

/** Whether the sound is modified by the distance to listener */
var(TW)     const bool    bUseListenerDistance;

/** Whether to use the environment this event is played in to determine what sound Wwise should play */
var(TW)     const bool    bUseEnvironmentReverbSwitchGroup;

/** Whether to have the Doppler effect applied */
var(TW)     const bool    bUseDoppler;

/** Forces this event to be played at a location (using a pooled component) when played from WwiseClientHearSound */
var(TW)     const bool    bForceHearSoundLocational;

/** Whether this event needs its occlusion updated over time */
var(TW)     const bool    bNeedsOcclusionUpdates<EditCondition=!bNeverOcclude>;
/** How often to update occlusion or obstruction on owning component. Zero means never check. */
var         const float   OcclusionUpdateInterval;
/** If set, skip occlusion trace for updates (overrides bNeedsOcclusionUpdates) AND the initial audible test */
var(TW)     const bool    bNeverOcclude;

/** Whether this event is a background music track or not (used to set up exit cue callback) */
var(TW)     const bool    bIsMusicTrack;

struct native EventSwitchInfo
{ 
    var()   name    SwitchGroupName;
    var     name    SwitchName;
};

struct native EventRTPCInfo
{
    var()   name    RTPCName;
    var     float   RTPCValue;
};

/** Add a tag if you want this event to use a specific Wwise game sync (switch/RTPC).
  * In script, you will then have to check for the tag and add a game sync to the
  * appropriate custom array.
  */
var(TW)         array<Name> CustomTags;
var transient   array<EventSwitchInfo>  CustomSwitches;
var transient   array<EventRTPCInfo> CustomRTPCs;

/** Whether to use advanced sound functionality with the sound
 *  having a rotational direction, and able to play dynamic
 *  echo sounds
 */
var(Advanced) bool bUseAdvancedSoundFunctionality;

/** Left Front Echo Sound */
var(Advanced) AkEvent EchoFront<EditCondition=bUseAdvancedSoundFunctionality>;
/** Right Front Echo Sound */
var(Advanced) AkEvent EchoLeft<EditCondition=bUseAdvancedSoundFunctionality>;
/** Left Rear Echo Sound */
var(Advanced) AkEvent EchoRight<EditCondition=bUseAdvancedSoundFunctionality>;
/** Right Rear Echo Sound */
var(Advanced) AkEvent EchoRear<EditCondition=bUseAdvancedSoundFunctionality>;
/** Mono Echo Sound */
var(Advanced) AkEvent EchoMono<EditCondition=bUseAdvancedSoundFunctionality>;

cpptext
{
	virtual void PostLoad();
	void FixRequiredBank();

	UBOOL IsAudible( const FVector& SourceLocation, const FVector& ListenerLocation, AActor* SourceActor, INT& bIsOccluded, UBOOL bCheckOcclusion );

	UBOOL LoadBank();

#if __TW_WWISE_ && WITH_EDITOR
    void GenerateDefaultSettings();
    void GenerateMaxAudibleDistance();
    void GenerateMaxDuration();
#endif
};

simulated function SetCustomRTPC( name RTPCName, float RTPCValue )
{
    local int RTPCIdx;

    RTPCIdx = CustomRTPCs.Find( 'RTPCName', RTPCName );
    if( RTPCIdx == INDEX_NONE )
    {
        CustomRTPCs.Add( 1 );
        RTPCIdx = CustomRTPCs.Length - 1;
        CustomRTPCs[RTPCIdx].RTPCName = RTPCName;
    }

    CustomRTPCs[RTPCIdx].RTPCValue = RTPCValue;
}

defaultproperties
{
	MaxAudibleDistance=4000.0
    OcclusionUpdateInterval=0.2
}

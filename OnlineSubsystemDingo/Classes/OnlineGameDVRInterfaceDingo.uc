/**
 * Class that implements a Dingo version of the GameDVR interface
 */
class OnlineGameDVRInterfaceDingo extends Object within OnlineSubsystemDingo
	native
	implements(OnlineGameDVRInterface)
	config(Engine);

/** The owning subsystem that this object is providing an implementation for */
var OnlineSubsystemDingo OwningSubsystem;

/** Is the game rendering a Kinect RGB stream to the screen? */
var transient bool bIsRenderingKinectRGB;

/** Is recording enabled? */
var transient bool bIsEventRecordingEnabled;

struct native DVRClip
{
	var init string						ClipName;
	var bool							bDidEndCapture;
	var native hatpointer				ClipCapture{Windows::Xbox::Media::Capture::ApplicationClipCapture};
	var native hatpointer				CachedClip{Windows::Xbox::Media::Capture::ApplicationClip};

	structcpptext
	{
		FDVRClip(const FString& InClipName)
		: ClipName(InClipName), bDidEndCapture(FALSE), ClipCapture(nullptr), CachedClip(nullptr) {}
	}
};

struct native DVRClipCache
{
	/** Indicates the state of the async read */
	var EOnlineEnumerationReadState		ReadState;
	var init array<DVRClip>				DVRClips;

	structcpptext
	{
		FDVRClipCache() : ReadState(OERS_NotStarted) {}

		FDVRClip& FindOrAddClip(const FString& ClipName)
		{
			// Find an existing entry for this clip
			for (INT ClipIdx = 0; ClipIdx < DVRClips.Num(); ++ClipIdx)
			{
				if (DVRClips(ClipIdx).ClipName == ClipName)
				{
					return DVRClips(ClipIdx);
				}
			}

			// Add a new entry
			FDVRClip NewClip(ClipName);
			return DVRClips(DVRClips.AddItem(NewClip));
		}
	}
};

/** Cache of user's DVR clips */
var native map{QWORD, FDVRClipCache}	UserDVRClipCache;

/** Since the static array of dynamic array syntax appears to be broken */
struct native PerUserGameDVRDelegates
{
	/** the array of delegates for notifying when the read of a user's recorded clips has completed */
	var array<delegate<OnReadRecordedClipsComplete> > ReadRecordedClipsDelegates;
	/** the array of delegates for notifying when the read of a user's recorded clips has completed */
	var array<delegate<OnRecordEventComplete> >		  RecordEventCompleteDelegates;
};

/** Per user array of array of delegates */
var PerUserGameDVRDelegates PerUserDelegates[`MAX_NUM_PLAYERS];

/** Enable recording events */
native function EnableRecording();

/** Disable recording events */
native function DisableRecording();

/** Read a player's list of recorded clips */
native function bool ReadRecordedClips(byte LocalUserNum);

/**
 * Called when the async read of a user's recorded clips completes 
 */
delegate OnReadRecordedClipsComplete(bool bWasSuccessful, byte LocalUserNum);

/*
 * Clears out all cached clips that have been recorded or read
 */
native function ClearCachedRecordedClips(byte LocalUserNum);

/**
 * Sets the delegate used to notify the gameplay code that the read of a user's recorded clips has completed
 */
function AddReadRecordedClipsCompleteDelegate(byte LocalUserNum, delegate<OnReadRecordedClipsComplete> ReadRecordedClipsCompleteDelegate)
{
	// Make sure the user is valid
	if (LocalUserNum >= 0 && LocalUserNum < ArrayCount(PerUserDelegates))
	{
		`AddUniqueItemToArray(PerUserDelegates[LocalUserNum].ReadRecordedClipsDelegates, ReadRecordedClipsCompleteDelegate);
	}
	else
	{
		`warn("Invalid index ("$LocalUserNum$") passed to AddReadRecordedClipsCompleteDelegate()");
	}
}

/**
 * Clears the delegate used to notify the gameplay code that the read of a user's recorded clips has completed
 */
function ClearReadRecordedClipsCompleteDelegate(byte LocalUserNum, delegate<OnReadRecordedClipsComplete> ReadRecordedClipsCompleteDelegate)
{
	// Make sure the user is valid
	if (LocalUserNum >= 0 && LocalUserNum < ArrayCount(PerUserDelegates))
	{
		PerUserDelegates[LocalUserNum].ReadRecordedClipsDelegates.RemoveItem(ReadRecordedClipsCompleteDelegate);
	}
	else
	{
		`warn("Invalid index ("$LocalUserNum$") passed to ClearReadRecordedClipsCompleteDelegate()");
	}
}

/** Begin recording an event with the given name */
native function bool BeginRecordingEvent(byte LocalUserNum,string EventName);

/**
 * Called when the async storage of a recorded clip completes
 */
delegate OnRecordEventComplete(bool bWasSuccessful, byte LocalUserNum, string EventName);

/**
 * Sets the delegate used to notify the gameplay code that the async storage of a recorded clip completes
 */
function AddRecordEventCompleteDelegate(byte LocalUserNum, delegate<OnRecordEventComplete> RecordEventCompleteDelegate)
{
	// Make sure the user is valid
	if (LocalUserNum >= 0 && LocalUserNum < ArrayCount(PerUserDelegates))
	{
		`AddUniqueItemToArray(PerUserDelegates[LocalUserNum].RecordEventCompleteDelegates, RecordEventCompleteDelegate);
	}
	else
	{
		`warn("Invalid index ("$LocalUserNum$") passed to AddRecordEventCompleteDelegate()");
	}
}

/**
 * Clears the delegate used to notify the gameplay code that the async storage of a recorded clip completes
 */
function ClearRecordEventCompleteDelegate(byte LocalUserNum, delegate<OnRecordEventComplete> RecordEventCompleteDelegate)
{
	// Make sure the user is valid
	if (LocalUserNum >= 0 && LocalUserNum < ArrayCount(PerUserDelegates))
	{
		PerUserDelegates[LocalUserNum].RecordEventCompleteDelegates.RemoveItem(RecordEventCompleteDelegate);
	}
	else
	{
		`warn("Invalid index ("$LocalUserNum$") passed to ClearRecordEventCompleteDelegate()");
	}
}

/** End recording an event with the given name */
native function bool EndRecordingEvent(byte LocalUserNum,string EventName);

/** Record an event that just finished, capturing the the timespan given by the duration parameter */
native function bool RecordPreviousTimespan(byte LocalUserNum,string EventName, float Duration);

/** Cancels the recording of an event with the given name */
native function bool CancelRecordingEvent(byte LocalUserNum,string EventName);

event SetIsRenderingKinectRGB(bool bInIsRenderingKinectRGB)
{
	bIsRenderingKinectRGB = bInIsRenderingKinectRGB;
}

defaultproperties
{
	bIsRenderingKinectRGB=FALSE
	bIsEventRecordingEnabled=TRUE
}

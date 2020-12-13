/**
 * This interface provides accessors to the platform specific Game DVR methods.
 */
interface OnlineGameDVRInterface	dependson(OnlineSubsystem);

/** Enable recording events */
function EnableRecording();

/** Disable recording events */
function DisableRecording();

/** Read a player's list of recorded clips */
function bool ReadRecordedClips(byte LocalUserNum);

/**
 * Called when the async read of a user's recorded clips completes 
 */
delegate OnReadRecordedClipsComplete(bool bWasSuccessful, byte LocalUserNum);

/*
 * Clears out all cached clips that have been recorded or read
 */
function ClearCachedRecordedClips(byte LocalUserNum);

/**
 * Sets the delegate used to notify the gameplay code that the read of a user's recorded clips has completed
 */
function AddReadRecordedClipsCompleteDelegate(byte LocalUserNum, delegate<OnReadRecordedClipsComplete> ReadRecordedClipsCompleteDelegate);

/**
 * Clears the delegate used to notify the gameplay code that the read of a user's recorded clips has completed
 */
function ClearReadRecordedClipsCompleteDelegate(byte LocalUserNum, delegate<OnReadRecordedClipsComplete> ReadRecordedClipsCompleteDelegate);

/** Begin recording an event with the given name */
function bool BeginRecordingEvent(byte LocalUserNum,string EventName);

/**
 * Called when the async storage of a recorded clip completes
 */
delegate OnRecordEventComplete(bool bWasSuccessful, byte LocalUserNum, string EventName);

/**
 * Sets the delegate used to notify the gameplay code that the async storage of a recorded clip completes
 */
function AddRecordEventCompleteDelegate(byte LocalUserNum, delegate<OnRecordEventComplete> RecordEventCompleteDelegate);

/**
 * Clears the delegate used to notify the gameplay code that the async storage of a recorded clip completes
 */
function ClearRecordEventCompleteDelegate(byte LocalUserNum, delegate<OnRecordEventComplete> RecordEventCompleteDelegate);

/** End recording an event with the given name */
function bool EndRecordingEvent(byte LocalUserNum,string EventName);

/** Record an event that just finished, capturing the the timespan given by the duration paramter */
function bool RecordPreviousTimespan(byte LocalUserNum,string EventName, float Duration);

/** Cancels the recording of an event with the given name */
function bool CancelRecordingEvent(byte LocalUserNum,string EventName);
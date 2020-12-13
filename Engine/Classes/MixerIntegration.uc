//=============================================================================
// MixerIntegration
//=============================================================================
// Platform interface plugin for Microsoft's Mixer service integration.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================

class MixerIntegration extends PlatformInterfaceBase
    native(PlatformInterface);

//Control whether or not Mixer is spun up when the interactive state switches to disabled.  Controlled in native.
var bool bStartMixer;

cpptext
{
#if WITH_MIXER
    void HandleMixerEvent(void* Event);
    void HandleButtonEvent(void* ButtonEvent);
    void HandleErrorEvent(void* ErrorEvent);
    void HandleStateChangeEvent(void* StateChangeEvent);
    void HandleUserStateChangeEvent(void* StateChangeEvent);
#endif
}

//Called when Mixer is ready to begin using interactivity
delegate MixerStartupComplete();

//Called when a user hits a button.  Key/Val pairs passed as array ref to avoid struct copy costs
delegate HandleMixerButtonEvent(string ControlId, string TransactionId, string Username, out array<string> MetaKeys, out array<string> MetaProps);

//Get list of groups that need to be built over the lifetime of interactivity
delegate GetGroupBuildList(out array<string> GroupsToBuild);

//Get the current default scene being used for new users joining the stream
delegate GetIntendedDefaultScene(out string DefaultSceneName);

/**
* Perform any initialization
*/
native event Init();

/**
 * Whether or not the Mixer functionality is enabled and running
 */
native static function bool IsMixerInteractionEnabled();

/**
 * Do the Mixer tick to pick up new interaction events
 */
native function TickMixer();

/**
 * Start interactive session for a specific user number
 */
native function StartInteractiveSession(byte UserNum);

/**
 * Stop any currently active interactive session
 */
native function StopInteractiveSession();

/**
 * Sets a specific scene to be active.  Can specify a group
 */
native function SetSceneActive(string SceneName, optional string GroupName = "default");

/*
 * Send Mixer the results of an event
 */
native function SendMixerEventResult(string ControlId, string TransactionId, int ResultVal, int Cooldown);

/**
 * Create an empty participant group to be used later
 */
native function CreateParticipantGroup(string GroupName);

/**
 * Move all users to a specified group.  Used for match startup and end to move all users to default groups for the game state.
 */
native function MoveAllUsersToGroup(string GroupName);

/**
 * Move a specified user to a specified group.  If the group doesn't exist, it will create it and set the appropriate scene.
 */
native function MoveUserToGroup(string Username, string GroupName);

/**
* Used for debug purposes.  Force the intended live scene to a different version from the shipped variant
*/
native static function ForceMixerScene(string VersionNumber, string ShareCode);
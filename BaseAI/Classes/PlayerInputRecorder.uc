//=============================================================================
// AnimationProxy
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class PlayerInputRecorder extends Object
	native(Tools);

static native noexport final function StartRecording(string Filename);
static native noexport final function StopRecording();
static native noexport final function Replay(string Filename);
static native noexport final function StopReplay();

cpptext
{
#if HASEDITOR
	// to be specialized in Platforms' drivers
	template<typename TJoystickInfo, typename TXInputState>
	static void Replay(TJoystickInfo&, TXInputState&);

	// to be specialized in Platforms' drivers
	template<typename TJoystickInfo, typename TXInputState>
	static void Record(TJoystickInfo&, TXInputState&);

	// to be defined in Platforms' drivers
	static void FlushInputRecBuffer(UBOOL bFinalize);

	static UBOOL IsRecording();
	static UBOOL IsReplaying();

	static void StopReplay();
	static void OnReplayingStop();

	static UBOOL ReadInRecordedPlayerInput(UBOOL bFinishing = FALSE);

	enum
	{
		kInputRecordBufferSize = 128
	};

protected:
	static FString CurrentFileName;
	static UBOOL bIsInputRecording;
	static UBOOL bIsInputReplaying;
	static INT Version;
	static INT ReplayIndex;
#endif // HASEDITOR
};
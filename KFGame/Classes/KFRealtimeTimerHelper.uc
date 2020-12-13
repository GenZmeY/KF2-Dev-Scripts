//=============================================================================
// KFRealtimeTimerHelper
//=============================================================================
// Helper actor to use for timers. Slimmed down native tick only ticks timers
// and nothing else. Will not even call script tick event, process state
// changes or physics, or really much else at all. Exists on both client and
// server, but as their own separate instances. Does not replicate.
//
// @NOTE: Timers will ignore WorldInfo.TimeDilation and tick all the time
// regardless if game is paused. Timers that require pausing must be dealt with
// on an individual basis.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//  - Zane Gholson 12/11/2013 - MattF Renamed & Updated 10/11/2016
//=============================================================================
class KFRealtimeTimerHelper extends Actor
	native;

cpptext
{
	virtual UBOOL Tick( FLOAT DeltaTime, enum ELevelTick TickType );
}

reliable client function ClientStopNetworkedVoice()
{
	local KFPlayerController KFPC;

	if( WorldInfo.NetMode != NM_DedicatedServer )
	{
		KFPC = KFPlayerController(GetALocalPlayerController());
		if( KFPC != none )
		{
			KFPC.ClientStopNetworkedVoice();
		}
	}
}

event Destroyed()
{
	ClearAllTimers();

	super.Destroyed();
}

DefaultProperties
{
	TickGroup=TG_DuringAsyncWork
	RemoteRole=ROLE_None
	bAlwaysTick=true
	bTickIsDisabled=false
	bHidden=true
	bMovable=false
}
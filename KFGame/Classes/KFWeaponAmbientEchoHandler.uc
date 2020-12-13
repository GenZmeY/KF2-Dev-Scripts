class KFWeaponAmbientEchoHandler extends Object
	within KFPawn;

enum EEchoDirection
{
    EED_Front,
    EED_Right,
    EED_Left,
    EED_Rear,
    EED_Max
};

struct native EchoSet
{
	/** Components to play events on */
    var AkComponent Components[4];

    /** Echo events to play */
    var AKEvent     Events[4];

    /** Time that echo should start playing (allows for delay) */
    var float       EchoStartTimes[4];

    /** Time that echo should stop playing (allows for delay) */
    var float       EchoStopTimes[4];

    /** Whether echo loop has been started (bool arrays aren't allowed) */
    var byte        Started[4];

    /** Whether echo loop has been stopped (bool arrays aren't allowed) */
    var byte        Stopped[4];
};

/** Array of currently-playing looping echo sounds (each set has four direction echoes) */
var array< EchoSet > EchoSets;

/**
 * Starts the chain of starting/stopping looping echo sounds for looping fire weapons
 * On fire, a set of four directional echoes is grabbed from the audio device, and each echo is given a delay time to start
 * On stop fire, each echo is given a delay time to stop, and then they are returned to the audio device
 * @param NewAmbientSound the sound that was played that we want to handle echoes for
 */
simulated function HandleEchoes(AkEvent NewAmbientSound)
{
    if ( WorldInfo.NetMode == NM_DedicatedServer )
    {
        return;
    }

    StopAllEchoes();

    if ( NewAmbientSound != None)
    {
        StartEchoSet( NewAmbientSound );
    }
}

/*
 * Create a set of four directional echoes and give them a start delay based on location within reverb volume
 */
simulated function StartEchoSet( AkEvent NewAmbientSound )
{
    local vector FrontLocation, RightLocation, LeftLocation, RearLocation, ViewLocation;
    local float EchoDistance, EchoDelay, ViewDist;
	local PlayerController LocalPC;
	local rotator ViewRotation;
	local ReverbVolume EchoVolume;
	local int EchoIdx;

	LocalPC = GetALocalPlayerController();
	if( LocalPC != none )
	{
		LocalPC.GetPlayerViewPoint( ViewLocation, ViewRotation );
	}
	else
	{
		`log(GetFuncName()@"called with no local PC!");
		return;
	}

    ViewDist = VSizeSq(ViewLocation-Location);

    class'KFReverbVolume'.static.CalculateEchoVolumeAndDistance( WorldInfo, Location, EchoVolume, EchoDistance );

    EchoSets.Add( 1 );

    // Play all 4 positional echoes if the listener is within the echo distance
    if( EchoDistance == 0 || (ViewDist < EchoDistance * EchoDistance) )
    {
        // For the purposes of placing the echo locations, we need an echo distance of at least 1.0
        if( EchoDistance < 1.0 )
        {
            EchoDistance = 1.0;
        }

	    class'KFReverbVolume'.static.CalculateEchoLocationAndDelay( EchoVolume, Location, vect(1,0,0) >> Rotation, EchoDistance, FrontLocation, EchoDelay );
	    DelayedStartEcho( EED_Front, FrontLocation, NewAmbientSound.EchoFront, WorldInfo.TimeSeconds + EchoDelay );
	    class'KFReverbVolume'.static.CalculateEchoLocationAndDelay( EchoVolume, Location, vect(0,-1,0) >> Rotation, EchoDistance, LeftLocation, EchoDelay );
	    DelayedStartEcho( EED_Left, LeftLocation, NewAmbientSound.EchoRight, WorldInfo.TimeSeconds + EchoDelay );
	    class'KFReverbVolume'.static.CalculateEchoLocationAndDelay( EchoVolume, Location, vect(0,1,0) >> Rotation, EchoDistance, RightLocation, EchoDelay );
	    DelayedStartEcho( EED_Right, RightLocation, NewAmbientSound.EchoLeft, WorldInfo.TimeSeconds + EchoDelay );
	    class'KFReverbVolume'.static.CalculateEchoLocationAndDelay( EchoVolume, Location, vect(-1,0,0) >> Rotation, EchoDistance, RearLocation, EchoDelay );
	    DelayedStartEcho( EED_Rear, RearLocation, NewAmbientSound.EchoRear, WorldInfo.TimeSeconds + EchoDelay );

        //FlushPersistentDebugLines();
        //DrawDebugSphere( FrontLocation, 8, 10, 255, 0, 0, true );
        //DrawDebugSphere( LeftLocation, 8, 10, 255, 0, 0, true );
        //DrawDebugSphere( RightLocation, 8, 10, 255, 0, 0, true );
        //DrawDebugSphere( RearLocation, 8, 10, 255, 0, 0, true );
    }
    else
    {
        // Set the echo to play based on the looping fire sound that was played
        DelayedStartEcho( EED_Front, Location, NewAmbientSound.EchoMono, WorldInfo.TimeSeconds + EchoDelay );

		// "stop" the rest so that echo set is removed in tick
		EchoIdx = EchoSets.Length - 1;
		EchoSets[EchoIdx].Stopped[EED_Left] = 1;
		EchoSets[EchoIdx].Stopped[EED_Right] = 1;
		EchoSets[EchoIdx].Stopped[EED_Rear] = 1;
    }

    if( EchoDelay == 0 )
    {
    	// possibly start echoes now instead of next frame
    	TickEchoes();
    }
}

/*
 * Sets up single echo and gives it an AkComponent from the audio device
 */
simulated function DelayedStartEcho( EEchoDirection EDir, vector EchoLocation, AkEvent EchoSound, float EchoStartTime )
{
    local int EchoSetIndex;
    local KFPlayerController LocalKFPC;

    LocalKFPC = KFPlayerController( GetALocalPlayerController() );
    if( LocalKFPC != none )
    {
        EchoSetIndex = EchoSets.Length - 1;
        EchoSets[ EchoSetIndex ].Components[ EDir ] = LocalKFPC.GetPooledAkComponent();
        EchoSets[ EchoSetIndex ].Components[ EDir ].Location = EchoLocation;
        EchoSets[ EchoSetIndex ].Components[ EDir ].bStopWhenOwnerDestroyed = true;
        EchoSets[ EchoSetIndex ].Events[ EDir ] = EchoSound;
        EchoSets[ EchoSetIndex ].EchoStartTimes[ EDir ] = EchoStartTime;
    }
}

/*
 * Determines when all direction echoes for an echo set should stop being played
 */
simulated function StopEchoSet( optional int EchoSetIndex = -1, optional bool bStopImmediate = false )
{
    local float EchoDistance, EchoDelay;
    local ReverbVolume EchoVolume;
    local vector EchoLocation;

	if( EchoSetIndex < 0 )
	{
		EchoSetIndex = EchoSets.Length - 1;
	}

	if( EchoSetIndex < 0 || EchoSetIndex >= EchoSets.Length )
	{
	   return;
	}

	if( bStopImmediate )
	{
	    // stop echoes now instead of next frame
		StopEcho(EchoSetIndex, EED_Front);
		StopEcho(EchoSetIndex, EED_Left);
		StopEcho(EchoSetIndex, EED_Right);
		StopEcho(EchoSetIndex, EED_Rear);

        EchoSets.Remove( EchoSetIndex, 1 );
	}
	else
	{
	    class'KFReverbVolume'.static.CalculateEchoVolumeAndDistance( WorldInfo, Location, EchoVolume, EchoDistance );
	    class'KFReverbVolume'.static.CalculateEchoLocationAndDelay( EchoVolume, Location, vect(1,0,0) >> Rotation, EchoDistance, EchoLocation, EchoDelay );
	    EchoSets[ EchoSetIndex ].EchoStopTimes[ EED_Front ] = WorldInfo.TimeSeconds + EchoDelay;
	    class'KFReverbVolume'.static.CalculateEchoLocationAndDelay( EchoVolume, Location, vect(0,-1,0) >> Rotation, EchoDistance, EchoLocation, EchoDelay );
	    EchoSets[ EchoSetIndex ].EchoStopTimes[ EED_Left ] = WorldInfo.TimeSeconds + EchoDelay;
	    class'KFReverbVolume'.static.CalculateEchoLocationAndDelay( EchoVolume, Location, vect(0,1,0) >> Rotation, EchoDistance, EchoLocation, EchoDelay );
	    EchoSets[ EchoSetIndex ].EchoStopTimes[ EED_Right ] = WorldInfo.TimeSeconds + EchoDelay;
	    class'KFReverbVolume'.static.CalculateEchoLocationAndDelay( EchoVolume, Location, vect(-1,0,0) >> Rotation, EchoDistance, EchoLocation, EchoDelay );
	    EchoSets[ EchoSetIndex ].EchoStopTimes[ EED_Rear ] = WorldInfo.TimeSeconds + EchoDelay;
	}
}

/*
 * Determines stop time for all echoes in all echo sets
 @param bImmediate - tells echoes to stop immediately, otherwise they will stop after a delay determined by the reverb volume
 */
simulated function StopAllEchoes( optional bool bImmediate )
{
    local int i;

    for( i = EchoSets.Length - 1; i >= 0; i-- )
    {
        // stop/delay stop all echo sets that haven't been scheduled to stop, in case there are more than one (could happen due to flaky server connection)
        if( bImmediate || EchoSets[i].EchoStopTimes[EED_Front] == 0 )
        {
            StopEchoSet( i, bImmediate );
        }
    }
}

/*
 * Updates echo sets (starts them after start delay, stops them after stop delay, cleans them up when finished)
 */
simulated function TickEchoes()
{
	local int i, j, NumStoppedEchoes;
    local float WorldTimeSeconds;

    WorldTimeSeconds = WorldInfo.TimeSeconds;

    for( i = 0; i < EchoSets.Length; ++i )
    {
    	NumStoppedEchoes = 0;
        for( j = 0; j < EED_Max; ++j )
        {
            if( EchoSets[i].Stopped[j] == 0 )
            {
                if( EchoSets[i].Started[j] == 0 && EchoSets[i].EchoStartTimes[j] > 0 && WorldTimeSeconds > EchoSets[i].EchoStartTimes[j] )
                {
                    StartEcho( i , j );
                }
                else if( EchoSets[i].Started[j] > 0 && EchoSets[i].EchoStopTimes[j] > 0 && WorldTimeSeconds > EchoSets[i].EchoStopTimes[j] )
                {
                    StopEcho( i , j );
                    ++NumStoppedEchoes;
                }
            }
            else
            {
            	++NumStoppedEchoes;
            }
        }

        // if all echoes in an echo set have been stopped, then the set is finished -- remove it
        if( NumStoppedEchoes == EED_Max )
        {
        	EchoSets.Remove( i--, 1 );
        }
    }
}

/*
 * Plays a single echo
 */
simulated function StartEcho( int EchoSetIndex, int EchoIndex )
{
    EchoSets[ EchoSetIndex ].Started[ EchoIndex ] = 1;
    EchoSets[ EchoSetIndex ].Components[ EchoIndex ].PlayEvent( EchoSets[EchoSetIndex].Events[EchoIndex] );
}

/*
 * Stops a single echo
 */
simulated function StopEcho( int EchoSetIndex, int EchoIndex )
{
    EchoSets[ EchoSetIndex ].Stopped[ EchoIndex ] = 1;
    if( EchoSets[EchoSetIndex].Components[EchoIndex] != none )
    {
        EchoSets[ EchoSetIndex ].Components[ EchoIndex ].StopEvents();
    }
}

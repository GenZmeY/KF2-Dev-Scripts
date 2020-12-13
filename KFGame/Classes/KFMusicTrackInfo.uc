//=============================================================================
// KFMusicTrackInfo
//=============================================================================
// Describes a KF2 music track (start/stop event, song info, etc.)
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - It Was I
//=============================================================================
class KFMusicTrackInfo extends Object
	native
	hidecategories(Object);

/** track to play (with vocals) */
var() AkEvent StandardTrack;
/** track to play (without vocals) */
var() AkEvent InstrumentalTrack;
/** event to stop both standard and instrumental tracks */
var() AkEvent StopEvent;
/** determines the minimum allowable game intensity for this track */
var() byte MinGameIntensityLevel<ClampMin=0|ClampMax=10>;
/** determines the maximum allowable game intensity for this track */
var() byte MaxGameIntensityLevel<ClampMin=0|ClampMax=10>;
/** whether this track should loop */
var() bool bLoop;
/** Name of track */
var() name TrackName;
/** Name of performing artist */
var() name ArtistName;
/** Name of album from which track comes */
var() name AlbumName;

defaultproperties
{
	MinGameIntensityLevel=0
	MaxGameIntensityLevel=10
}
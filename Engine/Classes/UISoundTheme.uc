/**
 * Copyright 1998-2013 Epic Games, Inc. All Rights Reserved.
 */
class UISoundTheme extends Object
	native(UserInterface);


/** Maps an event name to a sound.  When an event comes in to the UISceneTheme, if it can be found in the bindings array, then the corresponding SoundCue will be played */
struct native SoundEventMapping
{
	/** Name of the event that corresponds to the sound cue below. */
	var()   name        SoundEventName;
	
	/** Sound to play when the the above event is received. */
`if(`__TW_WWISE_)
	var() AkBaseSoundObject SoundToPlay;
`else
	var()   SoundCue    SoundToPlay;
`endif //__TW_WWISE_
};

/** List of the event bindings for this sound theme.  Usually, these will be specified by a designer in an archetype in the editor, or in the defaultproperties */
var() array<SoundEventMapping>    SoundEventBindings;

/** Called when an event (focus change, click, etc) is fired from the UI */
event ProcessSoundEvent(name SoundEventName, optional PlayerController SoundOwner)
{
	local int EventIndex;

	// Find an entry in the bindings array to match this sound event, or warn if we can't find one.
	EventIndex = SoundEventBindings.Find('SoundEventName', SoundEventName);
	if( EventIndex != INDEX_NONE )
	{
`if(`__TW_WWISE_)

`else
		`log("ProcessSoundEvent - Sound Event: "$SoundEventName$", Sound Theme: "$self$", Sound: "$SoundEventBindings[EventIndex].SoundToPlay,, 'DevGFxUI');
`endif //__TW_WWISE_
		if( SoundOwner != None )
		{
			// If there's a specific PlayerOwner, use it to play the sound
`if(`__TW_WWISE_)
			SoundOwner.PlaySoundBase( SoundEventBindings[EventIndex].SoundToPlay, TRUE, TRUE, TRUE );
`else
			SoundOwner.PlaySound( SoundEventBindings[EventIndex].SoundToPlay, TRUE, TRUE, TRUE );
`endif //__TW_WWISE_
		}
		else
		{
			// Default implementation:  Play the sound via the WorldInfo, which assumes the sound is not attenuated / spatialised
`if(`__TW_WWISE_)
			class'WorldInfo'.static.GetWorldInfo().PlaySoundBase( SoundEventBindings[EventIndex].SoundToPlay, TRUE, TRUE, TRUE );
`else
			class'WorldInfo'.static.GetWorldInfo().PlaySound( SoundEventBindings[EventIndex].SoundToPlay, TRUE, TRUE, TRUE );
`endif //__TW_WWISE_
		}
	}
	else
	{
`if(`__TW_WWISE_)

`else
		`log(self$": ProcessSoundEvent - Unable to find a binding for event: "$SoundEventName);
`endif //__TW_WWISE_
	}
}

defaultproperties
{
}

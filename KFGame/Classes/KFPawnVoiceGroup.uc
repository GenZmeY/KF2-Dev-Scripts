//=============================================================================
// KFPawnVoiceGroup
//=============================================================================
// Class that contains a character's dialog content
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Jeff Robinson
//=============================================================================

class KFPawnVoiceGroup extends Object
    abstract
    dependson(KFPawnVoiceGroupEventData)
    hidecategories(Object);

/** Class that contains data about how/when this character should use dialog */
var class<KFPawnVoiceGroupEventData> EventDataClass;

struct DialogEventLineInfo
{
    /** Line and possible response to play during a wave */
    var AkEvent   DefaultAudioCue;
    /** Line and possible response to play during trader, if applicable */
    var AkEvent   TraderTimeAudioCue;
};

/** Actual events for each possible piece of dialog, defined in KFGameContent for each character */
var array< DialogEventLineInfo > DialogEvents;

/** For debugging only */
var array< string > DialogEventNames;

static function string GetEventName( int EventID )
{
`if(`notdefined(ShippingPC))
    if( EventID >= 0 && EventID < default.DialogEventNames.length )
    {
        return default.DialogEventNames[ EventID ];
    }
    
    return "INVALID_EVENT";
`endif

    return "Event" @ EventID;
}

/** Gets AkEvent for a given ID */
static function AkEvent GetDialogAkEvent( int EventID, bool bIsTraderTime )
{
    if( bIsTraderTime && default.DialogEvents[EventID].TraderTimeAudioCue != none )
    {
        return default.DialogEvents[EventID].TraderTimeAudioCue;
    }
    
    return default.DialogEvents[EventID].DefaultAudioCue;
}

/** Gets info struct for a given event ID */
static function DialogEventInfo GetDialogEventInfo( int EventID )
{
    return default.EventDataClass.default.Events[EventID];
}

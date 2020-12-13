//=============================================================================
// KFPawnVoiceGroupEventData
//=============================================================================
// Class that contains information about how/when dialog can be used
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Jeff Robinson
//=============================================================================

class KFPawnVoiceGroupEventData extends Object;

`include(KFGame/KFGameDialog.uci)

enum ECooldownCategory
{
	ECC_Act,
	ECC_KillEnemy,
	ECC_DamEnemy,
	ECC_DamFriendly,
	ECC_SpotEnemy,
	ECC_Situ,
	ECC_Resp,
	ECC_TTime,
	ECC_HighZ
};

struct DialogEventInfo
{
	var int 							EventID;
    /** event priority (0 is lowest), higher priority events will interrupt lower priority events */
    var byte                          	Priority;
    /** Likelihood of being picked among events of the same priority */
    var byte							Weight;
    /** Likelihood of being played once picked */
    var float						    Chance;
    /** how long before this event can be triggered again */
    var float                         	CoolDownTime;
    /** radius within which cooldowntime is enforced */
    var float                         	CoolDownRadius;
    /** delay before playing (can be used for responses to other dialog events) */
    var float							Delay;
    /** maximum distance for activation */
    var float							Radius;
    /** maximum FOV for activation */
    var float							FOV;
    /** whether this event can be played when the player is the only one alive or in the game */
    var bool							bCanPlayAlone;
    /** this event won't play if any event within CooldownRadius with the same CoolDownCategory is cooling-down */
    var int								CoolDownCategory;
	/** this event won't be replicated to all clients */
    var bool							bOnlyPlayLocally;
    /** this event will be sent to a client but won't be played if the client has the "Minimize Battle Chatter" checkbox checked */
    var byte                            bCanBeMinimized;
    /** Whether this event can interrupt other events of the same priority */
    var bool                            bCanInterruptEqualPriority;

    StructDefaultProperties
    {
    	EventID=-1
    	Priority=0
    	Weight=1
    	Chance=0.5
        CoolDownTime=3.0
        CoolDownRadius=1000.0
        Delay=0.0
        Radius=1000
        FOV=`FOV45
        bCanPlayAlone=true
        CoolDownCategory=255
		bOnlyPlayLocally=false
        bCanBeMinimized=1
        bCanInterruptEqualPriority=false
    }
};

/** Array of info for each piece of dialog */
var array< DialogEventInfo > Events;

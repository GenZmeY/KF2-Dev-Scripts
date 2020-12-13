//=============================================================================
// KFMutator
//=============================================================================
// Base mutator class for KF2
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// Jeff Robinson
//Enjoy modding and want to join the community?  
//Discord: https://discord.gg/UjApa
//Tripwire Forums: http://forums.tripwireinteractive.com/forum/killing-floor-2/killing-floor-2-modifications/general-modding-discussion-ad
//=============================================================================
class KFMutator extends Mutator
	abstract;

var transient KFGameInfo MyKFGI;

/**
 * This function can be used to parse the command line parameters when a server
 * starts up
 */
function InitMutator(string Options, out string ErrorMessage)
{
	MyKFGI = KFGameInfo( WorldInfo.Game );
	super.InitMutator( Options, ErrorMessage );
}

/************
 * Trader
 ***********/

/** Allows mutator to modify which trader opens next, if any */
function ModifyNextTraderIndex( out byte NextTraderIndex )
{
`if(`__TW_SDK_)
	if( NextMutator != None )
	{
		NextMutator.ModifyNextTraderIndex( NextTraderIndex );
	}
`endif
}

/**********
 * Zeds / AI
 **********/

/** Allows mutator to modify AI pawn*/
function ModifyAI( Pawn AIPawn )
{
`if(`__TW_SDK_)
	if( NextMutator != none )
	{
		NextMutator.ModifyAI( AIPawn );
	}
`endif
}

/** Allows mutator to modify an AI's target enemy upon choosing one */
function ModifyAIEnemy( AIController AI, Pawn Enemy )
{
`if(`__TW_SDK_)
	if( NextMutator != none )
	{
		NextMutator.ModifyAIEnemy( AI, Enemy );
	}
`endif
}

/************
 * Gameplay
 ***********/

/** Allows mutator to modify how likely, how long, and how frequently zed time occurs (zed time scalar and blend-out can be set in InitMutator) */
function ModifyZedTime( out float out_TimeSinceLastEvent, out float out_ZedTimeChance, out float out_Duration )
{
`if(`__TW_SDK_)
	if( NextMutator != none )
    {
    	NextMutator.ModifyZedTime( out_TimeSinceLastEvent, out_ZedTimeChance, out_Duration );
    }
`endif
}

/************
 * Pickups
 ***********/

/** Allows mutator to modify the initial state of all pickup factories */
function ModifyPickupFactories()
{
`if(`__TW_SDK_)
	if( NextMutator != None )
	{
		NextMutator.ModifyPickupFactories();
	}
`endif
}

/** Allows mutator to modify a newly activated pickup factory */
function ModifyActivatedPickupFactory( PickupFactory out_ActivatedFactory, out float out_RespawnDelay )
{
`if(`__TW_SDK_)
	if( NextMutator != None )
	{
		NextMutator.ModifyActivatedPickupFactory( out_ActivatedFactory, out_RespawnDelay );
	}
`endif
}

//=============================================================================
// KFSeqAct_SetTrader
//=============================================================================
// Action that sets the next trader to a specific KFTraderTrigger
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
// - Matt "Squirrlz" Farber
//=============================================================================
class KFSeqAct_SetTrader extends SequenceAction;

/** When TRUE, the game will automatically select the next random trader when the Clear input is used */
var() bool bAutoSetNextTraderWhenClearing;

event Activated()
{
	local SeqVar_Object ObjVar;
	local KFTraderTrigger Trader;
	local KFGameInfo KFGI;
	
	if( InputLinks[0].bHasImpulse )
	{
		// Grab our trader
		foreach LinkedVariables( class'SeqVar_Object', ObjVar, "Trader Trigger" )
		{
			Trader = KFTraderTrigger( ObjVar.GetObjectValue() );
			break;
		}

		// Sanity
		if( Trader == none )
		{
			return;
		}

		// Set in gameinfo
		KFGI = KFGameInfo( class'WorldInfo'.static.GetWorldInfo().Game );
		if( KFGI != none )
		{
			KFGI.ScriptedTrader = Trader;
			KFGI.SetupNextTrader();
		}
	}
	else if( InputLinks[1].bHasImpulse )
	{
		// Clear from gameinfo
		KFGI = KFGameInfo( class'WorldInfo'.static.GetWorldInfo().Game );
		if( KFGI != none )
		{
			KFGI.ScriptedTrader = none;
			if( bAutoSetNextTraderWhenClearing )
			{
				KFGI.SetupNextTrader();
			}
		}
	}
}

DefaultProperties
{
	ObjCategory="Killing Floor"
	ObjName="Set Trader"

	InputLinks(0)=(LinkDesc="Set")
	InputLinks(1)=(LinkDesc="Clear")
	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Trader Trigger",PropertyName="",MaxVars=1)
	bCallHandler=false
}
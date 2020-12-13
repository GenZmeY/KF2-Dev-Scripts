//=============================================================================
// PluginBase
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class PluginBase extends Object
	abstract
	native(Plugin);

var PlugInOwnerInterface PlugInOwner;
var const public{private} bool bIsPluginEnabled;

var bool bAborted;
var bool bFailure;
var bool bSuccess;

var BaseAiPlugInHistory OwnersAiPlugInHistory;
var string HistoryString;

/** Exiting status of this plugin */
var() transient string StatusStr;

cpptext
{
	FORCEINLINE UBOOL IsPluginEnabled() const
	{
		return bIsPluginEnabled;
	}

	virtual void CleanUp(UBOOL bBeingDestroyed) {}
}

native function DisablePlugin();
native function EnablePlugin();

simulated function DrawDebugToHud( HUD HUD, name Category );


event ScriptInitialize()
{
	bAborted = false;
	bFailure = false;
	bSuccess = false;
}

event DrawDebug(HUD H, Name Category);

/*********************************************************************************************
* Debugging
********************************************************************************************* */

/** Update command history (debugging) */
function UpdateCommandHistory()
{
	local int i;

	if( PlugInOwner != none )
	{
		if( OwnersAiPlugInHistory == none )
		{
			OwnersAiPlugInHistory = PlugInOwner.GetAiPlugInHistory();
		}

		for( i = 0; i < OwnersAiPlugInHistory.PlugInHistory.Length; i++ )
		{
			if( OwnersAiPlugInHistory.PlugInHistory[i].PlugInName != "" && OwnersAiPlugInHistory.PlugInHistory[i].PlugInName == string(name) )
			{
				if( bAborted)
				{
					OwnersAiPlugInHistory.PlugInHistory[i].bAborted = true;
				}
				if( bFailure)
				{
					OwnersAiPlugInHistory.PlugInHistory[i].bFailure = true;
				}
				if( bSuccess )
				{
					OwnersAiPlugInHistory.PlugInHistory[i].bSuccess = true;
				}
		
				UpdateHistoryString( "Status: " $ StatusStr );
				//HistoryString = "Status: "$Status;
				OwnersAiPlugInHistory.PlugInHistory[i].Duration =  PlugInOwner.GetTimeSince(OwnersAiPlugInHistory.PlugInHistory[i].TimeStamp);
				OwnersAiPlugInHistory.PlugInHistory[i].VerboseString = HistoryString;
			}
		}
	}
}

/** Update the command's HistoryString, which is output when DumpCommandHistory() is called */
function UpdateHistoryString( string AddString )
{

	if( PlugInOwner != none )
	{
		if( OwnersAiPlugInHistory == none )
		{
			OwnersAiPlugInHistory = PlugInOwner.GetAiPlugInHistory();
		}

		if( OwnersAiPlugInHistory.PlugInHistoryNum > 0 )
		{
			HistoryString = HistoryString$" "$AddString;
		}
	}

}

/** Used when dumping command history to log file */
event string GetDebugVerboseText()
{
	return HistoryString;
}

defaultproperties
{
	bIsPluginEnabled=true
	HistoryString="[I]"
}
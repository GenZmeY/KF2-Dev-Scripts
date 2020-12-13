//=============================================================================
// KFSeqAct_SetTraderVolumeIgnore
//=============================================================================
// Action that sets a volume to be used when determining if the trader trail
// is shown or not.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================
class KFSeqAct_SetTraderVolumeIgnore extends SequenceAction
	dependsOn(KFSeqAct_ShowPath);

/**
 * Leave at VCT_None to always attempt to show the path to all human players.
 * If this is set to VCT_InVolume, it will only show the path to players inside the linked volume.
 * If this is set to VCT_NotInVolume, it will only show the path to players NOT in the linked volume.
 */
var() eVolumeCheckType VolumeCheckType;

event Activated()
{
	local SeqVar_Object ObjVar;
	local Volume Volume;
	local KFGameReplicationInfo KFGRI;
	
	if( InputLinks[0].bHasImpulse )
	{
		// Grab our trader
		foreach LinkedVariables( class'SeqVar_Object', ObjVar, "Volume" )
		{
			Volume = Volume( ObjVar.GetObjectValue() );
			break;
		}

		// Sanity
		if( Volume == none )
		{
			return;
		}

		// Set in gamereplicationinfo
		KFGRI = KFGameReplicationInfo( class'WorldInfo'.static.GetWorldInfo().GRI );
		if( KFGRI != none )
		{
			KFGRI.TraderVolume = Volume;
			KFGRI.TraderVolumeCheckType = VolumeCheckType;
		}
	}
	else if( InputLinks[1].bHasImpulse )
	{
		// Clear from gamereplicationinfo
		KFGRI = KFGameReplicationInfo( class'WorldInfo'.static.GetWorldInfo().GRI );
		if( KFGRI != none )
		{
			KFGRI.TraderVolume = none;
			KFGRI.TraderVolumeCheckType = 0;
		}
	}
}

static function bool IsActorInVolume( Actor TestActor, Volume TestVolume )
{
	local Actor A;

	// Use actor base class to avoid casting
	foreach TestActor.TouchingActors( class'Actor', A )	
	{
		if( A == TestVolume )
		{
			return true;
		}
	}

	return TestVolume.Encompasses( TestActor );
}

DefaultProperties
{
	ObjCategory="Killing Floor"
	ObjName="Set Trader Volume Settings"

	InputLinks(0)=(LinkDesc="Set")
	InputLinks(1)=(LinkDesc="Clear")
	VariableLinks.Empty()
	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Volume",MaxVars=1)

	VolumeCheckType=VCT_None
	bCallHandler=false
}
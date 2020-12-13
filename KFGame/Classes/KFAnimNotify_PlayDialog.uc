//=============================================================================
// KFAnimNotify_PlayDialog
//=============================================================================
// Notify to play a dialog event by ID.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFAnimNotify_PlayDialog extends AnimNotify_Scripted;

/** ID number of the dialog event to play */
var() int DialogID;

/** Plays a dialog event using the owning pawn */
event Notify( Actor Owner, AnimNodeSequence AnimSeqInstigator )
{
	if( Owner.Role == ROLE_Authority && Owner.WorldInfo.Game != none )
	{
		KFGameInfo(Owner.WorldInfo.Game).DialogManager.PlayDialogEvent( KFPawn(Owner), DialogID );
	}
}

defaultproperties
{
	//defaults
}
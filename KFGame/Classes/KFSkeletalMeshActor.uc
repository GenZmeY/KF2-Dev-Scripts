//=============================================================================
// KFSkeletalMeshActor
//=============================================================================
// Custom placeable SkeletalMeshActor class
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Andrew "Strago" Ladenberger
//=============================================================================
class KFSkeletalMeshActor extends SkeletalMeshActor
	placeable;

/** If set, will SetMaterial clientside instead of replicating */
var() bool bClientsideKismetSetMaterial;

simulated function OnSetMaterial(SeqAct_SetMaterial Action)
{
	if ( !bClientsideKismetSetMaterial )
	{
		Super.OnSetMaterial(Action);
		return;
	}

	SkeletalMeshComponent.SetMaterial( Action.MaterialIndex, Action.NewMaterial );
}

defaultproperties
{
}

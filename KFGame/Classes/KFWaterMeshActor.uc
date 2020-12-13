//=============================================================================
// KFWaterMeshActor
//=============================================================================
// A custom StaticMeshActor with bWorldGeometry == FALSE, so that
// we can use touch events for pass through hit effects
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
// - Andrew "Strago" Ladenberger
//=============================================================================
class KFWaterMeshActor extends StaticMeshActor;

defaultproperties
{
	bWorldGeometry=false
	bBlockActors=false
	bProjTarget=true

	Begin Object Name=StaticMeshComponent0		
		BlockActors=false
		BlockNonZeroExtent=false
		BlockRigidBody=false
		bBlockFootPlacement=false
	End Object
}

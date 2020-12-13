//=============================================================================
// KFKAsset
//=============================================================================
// Base class for all placeable KAssets in KF
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Andrew "Strago" Ladenberger
//=============================================================================
class KFKAsset extends KAsset	
	deprecated;

defaultproperties
{
	// RB/SkelComp Optimization
	Begin Object Name=KAssetSkelMeshComponent
		bUpdateSkelWhenNotRendered=false
	End Object
}

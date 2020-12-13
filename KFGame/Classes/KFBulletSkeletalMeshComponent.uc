//=============================================================================
// KFBulletSkeletalMeshComponent
//=============================================================================
// Used to set bullets visible and invisible based on their fired and reload 
// state
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
// Based on KFSkeletalMeshComponent 
// - Zane Gholson
//=============================================================================

class KFBulletSkeletalMeshComponent extends KFSkeletalMeshComponent;

var SkeletalMesh UnusedBulletMeshTemplate;
var SkeletalMesh UsedBulletMeshTemplate;

enum BulletState
{
	BS_Unused,
	BS_Used,
	BS_Unloaded,
};

var private BulletState _CurrentBulletState;

simulated function SetBulletState(BulletState NewBulletState)
{
	if(_CurrentBulletState == NewBulletState)
	{
		return;
	}
	_CurrentBulletState = NewBulletState;
	Switch(NewBulletState)
	{
		case BS_Unused:
			SetSkeletalMesh(UnusedBulletMeshTemplate);
			SetHidden(False);
			//with payload / unused
			break;
		case BS_Used:
			SetHidden(False);
			SetSkeletalMesh(UsedBulletMeshTemplate);
			//no payload / used
			break;
		case BS_Unloaded:
			SetHidden(true);
			//invisible - "I THREW IT ON THE GROUND!"
			break;
	}
}

simulated function BulletState GetBulletShellState()
{
	return _CurrentBulletState;
}
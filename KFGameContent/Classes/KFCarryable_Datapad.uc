//=============================================================================
// KFCarryable_Datapad
//=============================================================================
// A data pad that can be carried by players
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================
class KFCarryable_Datapad extends KFCarryableObject_Collectible;

var() AkEvent PersistentSoundLoop;
var() AKEvent PersistentSoundStop;

simulated state WeaponEquipping
{
	// when picked up, start the persistent sound
	simulated event BeginState(Name PreviousStateName)
	{
		local KFPawn InstigatorPawn;

		super.BeginState(PreviousStateName);

		if (Instigator != none)
		{
			InstigatorPawn = KFPawn(Instigator);
			if (InstigatorPawn != none)
			{
				InstigatorPawn.PlayWeaponSoundEvent(PersistentSoundLoop);
			}
		}
	}
}

simulated state Inactive
{
	// when dropped, destroyed, etc, play the stop on the persistent sound
	simulated event BeginState(Name PreviousStateName)
	{
		local KFPawn InstigatorPawn;

		super.BeginState(PreviousStateName);

		if (Instigator != none)
		{
			InstigatorPawn = KFPawn(Instigator);
			if (InstigatorPawn != none)
			{
				InstigatorPawn.PlayWeaponSoundEvent(PersistentSoundStop);
			}
		}
	}
}

defaultproperties
{
	PlayerViewOffset=(X=0,Y=6,Z=0)
	
	// Content
	PackageKey="Datapad"
	FirstPersonMeshName="WEP_1P_Datapad_MESH.WEP_1stP_Datapad_Rig"	
	FirstPersonAnimSetNames(0)="WEP_1P_Datapad_ANIM.Wep_1stP_datapad_Anim"
	PickupMeshName="WEP_3P_Datapad_MESH.Wep_3rdP_Horzine_Datapad_Static_Pickuo"
	AttachmentArchetypeName="WEP_Datapad_ARCH.Wep_Datapad_3P"

	PersistentSoundLoop=AkEvent'WW_WEP_Datapad.Play_WEP_Datapad_Hold_LP'
	PersistentSoundStop=AkEvent'WW_WEP_Datapad.Stop_WEP_Datapad_Hold_LP'

	WeaponSelectTexture=Texture2D'WEP_UI_Datapad_TEX.UI_WeaponSelect_Datapad'
}
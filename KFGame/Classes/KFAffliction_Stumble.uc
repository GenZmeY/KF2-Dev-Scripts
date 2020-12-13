//=============================================================================
// KFAffliction_Stun
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFAffliction_Stumble extends KFAfflictionBase;

function byte GetSpecialMoveFlags()
{
	local byte HitZoneIdx;

	// Is this a leg stumble?
	HitZoneIdx = PawnOwner.HitFxInfo.HitBoneIndex;
	if (HitZoneIdx < PawnOwner.HitZones.Length)
	{
		switch(PawnOwner.HitZones[HitZoneIdx].Limb)
		{
		case BP_LeftLeg:
			return Class'KFSM_Stumble'.static.PackLegHitSMFlags(
				PawnOwner, PawnOwner.HitFxInfo.EncodedHitDirection, true);

		case BP_RightLeg:
			return Class'KFSM_Stumble'.static.PackLegHitSMFlags(
				PawnOwner, PawnOwner.HitFxInfo.EncodedHitDirection, false);
		}
	}

	return class'KFSM_Stumble'.static.PackBodyHitSMFlags(PawnOwner, PawnOwner.HitFxInfo.EncodedHitDirection);
}

defaultproperties
{
	SpecialMove=SM_Stumble
}

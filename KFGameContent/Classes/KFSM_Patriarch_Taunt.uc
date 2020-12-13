//=============================================================================
// KFSM_Zed_Taunt
//=============================================================================
// Play a taunt animation sequence
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFSM_Patriarch_Taunt extends KFSM_Zed_Taunt;

/** Overloaded to support multiple phases */
static function byte PackSMFlags( KFPawn P, byte InTauntType )
{
	local byte Variant;
	local KFPawnAnimInfo PAI;

	PAI = P.PawnAnimInfo;
	Variant = 255;
	// Get the number of taunt anims from the AnimInfo class
	switch ( InTauntType )
	{
	case TAUNT_Enraged:
		if( PAI.TauntEnragedAnims.Length > 0 )
		{
			Variant = KFPawn_ZedPatriarch(P).CurrentBattlePhase-2;
		}
		break;
	case TAUNT_EnemyKilled:
		if( PAI.TauntKillAnims.Length > 0 )
		{
			Variant = Rand(PAI.TauntKillAnims.Length);
		}
		break;
	case TAUNT_Standard:
		if( PAI.TauntAnims.Length > 0 )
		{
			Variant = Rand(PAI.TauntAnims.Length);
		}
		break;
	}

	if ( Variant != 255 )
	{
		return InTauntType + (Variant << 4);
	}
	else
	{
		return 255;
	}
}

defaultproperties
{
	Handle=KFSM_Patriarch_Taunt
	BlendInTime=0.1f
	BlendOutTime=0.15f
	bCanBeInterrupted=false
}
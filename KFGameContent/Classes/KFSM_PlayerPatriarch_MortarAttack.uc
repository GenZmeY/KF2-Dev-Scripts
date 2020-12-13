//=============================================================================
// KFSM_PlayerPatriarch_MortarAttack
//=============================================================================
// Player-controlled Patriarch's mortar attack
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFSM_PlayerPatriarch_MortarAttack extends KFSM_Patriarch_MortarAttack;

/** Restrictions for doing mortar attack */
protected function bool InternalCanDoSpecialMove()
{
	local KFPawn_ZedPatriarch_Versus MyPatPawnV;

	MyPatPawnV = KFPawn_ZedPatriarch_Versus( KFPOwner );

	// Clear mortar targets first 
	MyPatPawnV.ClearMortarTargets();

	if( MyPatPawnV.IsLocallyControlled() && !MyPatPawnV.CollectMortarTargets(true, true) )
	{
		MyPatPawnV.MyKFPC.MyGFxHUD.ShowNonCriticalMessage( MyPatPawnV.NoMortarTargetsMsg );
		return false;
	}

	return super.InternalCanDoSpecialMove();
}

defaultproperties
{
	Handle=KFSM_PlayerPatriarch_MortarAttack
	//AnimName=Mortar_Shoot
	//BarrageFireAnimName=Mortar_rapidfire
	LoadAnimNames[0]=Mortar_TO_LoadP
}
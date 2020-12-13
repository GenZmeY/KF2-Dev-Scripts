//=============================================================================
// KFDT_Freeze_FreezeGrenade
//=============================================================================
// Freeze damage from freeze grenade
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// Jeff Robinson
//=============================================================================

class KFDT_Freeze_FreezeGrenade extends KFDT_Freeze
	abstract
	hidedropdown;

/** Play damage type specific impact effects when taking damage */
static function PlayImpactHitEffects( KFPawn P, vector HitLocation, vector HitDirection, byte HitZoneIndex, optional Pawn HitInstigator )
{
	local float ParamValue;
    local int MICIndex;

    MICIndex = 0;
    if (P.GetCharacterInfo() != none)
    {
        MICIndex = P.GetCharacterInfo().GoreFXMICIdx;
    }

	// If we're dead and not already frozen (prevents re-shattering)
	if ( P.bPlayedDeath 
		&& P.CharacterMICs.Length > MICIndex 
		&& P.CharacterMICs[MICIndex].GetScalarParameterValue('Scalar_Ice', ParamValue))
	{
		if (ParamValue == 0)
		{
			PlayShatter(P, false, `TimeSinceEx(P, P.TimeOfDeath) > 0.5f, HitDirection * default.KDeathVel);
			return;
		}
	}

	Super.PlayImpactHitEffects(P, HitLocation, HitDirection, HitZoneIndex, HitInstigator);
}

defaultproperties
{
	FreezePower=150 //100
	MeleeHitPower=100
	KDeathVel=300
	
	WeaponDef=class'KFWeapDef_Grenade_Sharpshooter'
}

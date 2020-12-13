//=============================================================================
// KFDT_Piercing
//=============================================================================
// Sharp or high velocity objects designed to pass through enemies
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFDT_Piercing extends KFDamageType
	abstract;

/** Allows the damage type to customize exactly which hit zones it can dismember */
static simulated function bool CanDismemberHitZone(name InHitZoneName)
{
    switch (InHitZoneName)
    {
    case 'lhand':
    case 'rhand':
    case 'lfoot':
    case 'rfoot':
    case 'lforearm':
    case 'rforearm':
    case 'lcalf':
    case 'rcalf':
    case 'lthigh':
    case 'rthigh':
    case 'head':
        return true;
    }

    return false;
}

defaultproperties
{
	KDamageImpulse=300

	EffectGroup=FXG_Piercing
}

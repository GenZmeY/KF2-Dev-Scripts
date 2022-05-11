//=============================================================================
// KFDT_Blast_HRG_CranialPopper
//=============================================================================
// Damage caused by the cranial popper alternate fire
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
//=============================================================================

class KFDT_Blast_HRG_CranialPopper extends KFDT_Ballistic_Rifle
	abstract
	hidedropdown;


static simulated function bool CanDismemberHitZone( name InHitZoneName )
{
    switch ( InHitZoneName )
    {
    case 'head':
        return false; //true to dismember
    }

    return false;
}

/**
* Allows the damage type to customize exactly which hit zones it can dismember while the zed is alive
*/
//static simulated function bool CanDismemberHitZoneWhileAlive(name InHitZoneName)
//{
//    switch ( InHitZoneName )
//    {
//    case 'head':
//        return true;
//    }
//
//    return false;
//}


DefaultProperties
{
	// This weapon uses radial impulses
	RadialDamageImpulse=1500
	KDamageImpulse=0
	KDeathUpKick=500.0
	KDeathVel=300

	// unreal physics momentum
	bExtraMomentumZ=True
	
	KnockdownPower=0
	StunPower=250
	StumblePower=0
	GunHitPower=0
	MeleeHitPower=0
	EMPPower=0

	//bCanObliterate=true
	//ObliterationHealthThreshold=-75
	//ObliterationDamageThreshold=100
	bCanGib=true
	GoreDamageGroup=DGT_Obliteration

	WeaponDef=class'KFWeapDef_HRG_CranialPopper'
	ModifierPerkList(0)=class'KFPerk_Sharpshooter'
}

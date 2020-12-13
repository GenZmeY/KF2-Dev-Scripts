//=============================================================================
// KFDT_Fire_FlareGun
//=============================================================================
// Damage caused by heat and combustion
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================
class KFDT_Fire_FlareGun extends KFDT_Ballistic_Handgun
	abstract;

// Damage type to use for the burning damage over time
var class<KFDamageType> BurnDamageType;

/** Called when damage is dealt to apply additional damage type (e.g. Damage Over Time) */
static function ApplySecondaryDamage( KFPawn Victim, int DamageTaken, optional Controller InstigatedBy )
{	
	// Overriden to specific a different damage type to do the burn damage over
	// time. We do this so we don't get shotgun pellet impact sounds/fx during
	// the DOT burning.
    if ( default.BurnDamageType.default.DoT_Type != DOT_None )
    {
        Victim.ApplyDamageOverTime(DamageTaken, InstigatedBy, default.BurnDamageType);
    }
}

defaultproperties
{
	WeaponDef=class'KFWeapDef_FlareGun'
	ModifierPerkList(0)=class'KFPerk_Firebug'
    ModifierPerkList(1)=class'KFPerk_Gunslinger'
    ModifierPerkList(2)=class'KFPerk_Sharpshooter'

	EffectGroup=FXG_Flare
	BurnDamageType=class'KFDT_Fire_FlareGunDoT'
	CameraLensEffectTemplate=class'KFCameraLensEmit_Fire'

	KDamageImpulse=1000
	KDeathUpKick=120
	KDeathVel=10

	BurnPower=30 //2.5 //15.5
	KnockdownPower=15
	StumblePower=100//50
	GunHitPower=150
}
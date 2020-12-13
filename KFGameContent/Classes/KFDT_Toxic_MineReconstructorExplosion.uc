//=============================================================================
// KFDT_Toxic_MedicGrenade
//=============================================================================
// Toxic Dart DamageType
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// Greg Felber
//=============================================================================

class KFDT_Toxic_MineReconstructorExplosion extends KFDT_Toxic
	abstract
	hidedropdown;

/** Called when damage is dealt to apply additional damage type (e.g. Damage Over Time) */
static function ApplySecondaryDamage( KFPawn Victim, int DamageTaken, optional Controller InstigatedBy )
{	
	// Overriden to specific a different damage type 
    if ( class'KFDT_Mine_Reconstructor_BileExplosionDoT'.default.DoT_Type != DOT_None )
    {
        Victim.ApplyDamageOverTime(DamageTaken, InstigatedBy, class'KFDT_Mine_Reconstructor_BileExplosionDoT');
    }
}

defaultproperties
{
	StumblePower=200 //400;
	PoisonPower=60;
	MicrowavePower=50;
	KnockdownPower=50 //150;

	EffectGroup=FXG_Toxic

	bHasToSpawnMicrowaveFire=false;

	DoT_Duration=4.0 //5.0 //1.7
	DoT_Interval=1.0 //1.0 //0.4
	DoT_DamageScale=0.1 //1.5

	ModifierPerkList(0)=class'KFPerk_FieldMedic'
	WeaponDef=class'KFWeapDef_Mine_Reconstructor'
}

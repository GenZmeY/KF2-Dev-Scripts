//=============================================================================
// KFDT_Toxic_MineReconstructorImpact
//=============================================================================
// Toxic damage type for the Mine reconstructor direct hit
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
// fferrando@saber3d
//=============================================================================

class KFDT_Toxic_MineReconstructorImpact extends KFDT_Ballistic_Shell
    abstract
    hidedropdown;




static simulated function bool CanDismemberHitZone( name InHitZoneName )
{
	return false;
}

/** Called when damage is dealt to apply additional damage type (e.g. Damage Over Time) */
static function ApplySecondaryDamage( KFPawn Victim, int DamageTaken, optional Controller InstigatedBy )
{
	local class<KFDamageType> ToxicDT;

	ToxicDT = class'KFDT_Ballistic_Assault_Medic'.static.GetMedicToxicDmgType( DamageTaken, InstigatedBy );
  	if ( ToxicDT != None )
    { 
        Victim.ApplyDamageOverTime(DamageTaken, InstigatedBy, ToxicDT);
    }
}

defaultproperties
{
	//override dot as the impact has no dot
	DoT_Type=DOT_NONE

	EffectGroup=FXG_Toxic


	MicrowavePower=18;
	PoisonPower=25;
	StumblePower=150;
	KnockdownPower=12;
	GunHitPower=100;

	bHasToSpawnMicrowaveFire=false;

	// physics impact
	ModifierPerkList(0)=class'KFPerk_FieldMedic'
	WeaponDef=class'KFWeapDef_Mine_Reconstructor'
}
 
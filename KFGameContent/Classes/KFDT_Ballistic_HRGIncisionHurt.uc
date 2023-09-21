//=============================================================================
// KFDT_Ballistic_HRGIncisionHurt
//=============================================================================
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================

class KFDT_Ballistic_HRGIncisionHurt extends KFDT_Ballistic_Rifle
	abstract;

/** Allows the damage type to map a hit zone to a different bone for dismemberment purposes. */
static simulated function GetBoneToDismember(KFPawn_Monster InPawn, vector HitDirection, name InHitZoneName, out name OutBoneName)
{
	local KFCharacterInfo_Monster MonsterInfo;

	MonsterInfo = InPawn.GetCharacterMonsterInfo();
    if ( MonsterInfo != none )
	{
		// Randomly pick the left or right shoulder to dismember
		if( InHitZoneName == 'chest')
		{
			OutBoneName = Rand(2) == 0 ? MonsterInfo.SpecialMeleeDismemberment.LeftShoulderBoneName : MonsterInfo.SpecialMeleeDismemberment.RightShoulderBoneName;
		}
	}
}

/** Allows the damage type to customize exactly which hit zones it can dismember */
static simulated function bool CanDismemberHitZone( name InHitZoneName )
{
    switch ( InHitZoneName )
	{
		case 'lupperarm':
		case 'rupperarm':
		case 'chest':
		case 'heart':
	 		return true;
	}

	return false;
}

defaultproperties
{
	GoreDamageGroup=DGT_Shotgun

	KDamageImpulse=7500
	KDeathUpKick=2500
	KDeathVel=500

	EMPPower=50
	StumblePower=400
	GunHitPower=300
	MeleeHitPower=100

	WeaponDef=class'KFWeapDef_HRGIncision'
	ModifierPerkList(0)=class'KFPerk_FieldMedic'

	EffectGroup=FXG_Electricity
}

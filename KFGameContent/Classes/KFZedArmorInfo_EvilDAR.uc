//=============================================================================
// KFZedArmorInfo_EvilDAR
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFZedArmorInfo_EvilDAR extends KFZedArmorInfo;

function AdjustBoneDamage(out int InDamage, name BoneName, Vector DamagerSource, class<DamageType> DamageType)
{
	local byte PrevArmorZoneStatus;
	local int UpdatedZones;

	PrevArmorZoneStatus = PreviousArmorZoneStatus;
	super.AdjustBoneDamage(InDamage, BoneName, DamagerSource, DamageType);

	// EDAR has no head, only head armor, so blow off his "head" when his head armor is blown off
	UpdatedZones = ArmorZoneStatus ^ PrevArmorZoneStatus;
	if (bool(UpdatedZones & (1 << 0)))
	{
		HitZones[HZI_Head].GoreHealth = 0;
	}
}

simulated function UpdateArmorPiece(int PieceIdx)
{
	super.UpdateArmorPiece(PieceIdx);

	switch (ArmorZones[PieceIdx].ArmorZoneName)
	{
	case 'head':
		Mesh.DetachComponent(StaticAttachList[0]);
		DetachComponent(StaticAttachList[0]);
		StaticAttachList.Remove(0, 1);
		break;

	case 'front':
		DetachComponent(ThirdPersonAttachments[0]);
		ThirdPersonAttachments[0] = none;
		break;
	}
}

defaultproperties
{
	ArmorScale=1.f

	ArmorZones.Add({(
		ArmorZoneName=head,
		AffectedHitZones=(head),
		bAffectedByFrontDamage=true,
		bAffectedByBackDamage=true,
		SocketName=FX_Armor_Head,
		ArmorHealth=600,
		ExplosionSFXTemplate=AkEvent'WW_ZED_Evil_DAR.Play_ZED_EvilDAR_SFX_Headshot',
		ZoneIcon=None)})
	ArmorZones.Add({(
		ArmorZoneName=front,
		AffectedHitZones=(chest,heart,stomach,abdomen),
		bAffectedByFrontDamage=true,
		bAffectedByBackDamage=false,
		SocketName=FX_Armor_Chest,
		ArmorHealth=52,
		ExplosionSFXTemplate=AkEvent'WW_ZED_Evil_DAR.Play_ZED_EvilDAR_SFX_Jetpack_Damaged',
		ZoneIcon=None)})

	ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Submachinegun', 	DamageScale=(1.05))) //0.75
    ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_AssaultRifle', 	DamageScale=(1.05)))
    ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Shotgun', 	    DamageScale=(1.2)))
    ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Handgun', 	    DamageScale=(1.0)))  //0.7
    ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Rifle', 	        DamageScale=(1.0)))  //0.75
    ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Slashing', 	                DamageScale=(1.25)))  //0.75
	ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Bludgeon', 	                DamageScale=(1.25)))  //0.85
	ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Fire', 	                    DamageScale=(1.5))) //0.5 //0.75
	ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Microwave', 	            DamageScale=(3.25))) //0.85 //2.0
	ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Explosive', 				DamageScale=(2.5))) //0.6
	ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Piercing', 	                DamageScale=(0.85))) //0.5
	ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Toxic', 	                DamageScale=(0.05))) //0.25

	//special case
	ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Bleeding_Hemogoblin', 	    DamageScale=(5.0)))
	ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Toxic_HRGHealthrower',      DamageScale=(1.2)))
}

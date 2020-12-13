//=============================================================================
// KFZedArmorInfo_ClotKing
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFZedArmorInfo_ClotKing extends KFZedArmorInfo;

simulated function UpdateArmorPiece(int PieceIdx)
{
	super.UpdateArmorPiece(PieceIdx);

	switch (ArmorZones[PieceIdx].ArmorZoneName)
	{
	case 'head':
		Mesh.DetachComponent(StaticAttachList[0]);
		DetachComponent(StaticAttachList[0]);
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
		ArmorHealth=450,
		ObliterateDmgThreshold=125,
		ExplosionSFXTemplate=AkEvent'WW_ZED_Abomination.Play_Abomination_Small_Armor_Explo',
		ZoneIcon=None)})
	ArmorZones.Add({(
		ArmorZoneName=front,
		AffectedHitZones=(chest,heart,stomach,abdomen),
		bAffectedByFrontDamage=true,
		bAffectedByBackDamage=false,
		SocketName=FX_Armor_Chest,
		ArmorHealth=500,
		ExplosionSFXTemplate=AkEvent'WW_ZED_Abomination.Play_Abomination_Large_Armor_Explo',
		ZoneIcon=None)})

	// ---------------------------------------------
	// Resistance & Vulnerability
	ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Submachinegun', 	DamageScale=(1.5)))  //3.0
	ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_AssaultRifle', 	DamageScale=(1.0)))
	ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Shotgun', 	    DamageScale=(1.0)))
	ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Handgun', 	    DamageScale=(1.01)))
	ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Rifle', 	        DamageScale=(1.0)))  //0.76
	ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Slashing', 	                DamageScale=(0.85))) //0.75
	ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Bludgeon', 	                DamageScale=(0.9))) //0.75
	ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Fire', 	                    DamageScale=(3.0)))
	ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Microwave', 	            DamageScale=(0.25)))
	ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Explosive', 	            DamageScale=(1.0)))
	ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Piercing', 	                DamageScale=(1.0)))
	ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Toxic', 	                DamageScale=(1.0))) //0.88
	
	//special case
	ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Bleeding_Hemogoblin', 	    DamageScale=(5.0)))
}

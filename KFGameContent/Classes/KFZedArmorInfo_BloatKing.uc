//=============================================================================
// KFZedArmorInfo_BloatKing
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFZedArmorInfo_BloatKing extends KFZedArmorInfo;

simulated function UpdateArmorPiece(int PieceIdx)
{
	local int i;

	super.UpdateArmorPiece(PieceIdx);

	switch (ArmorZones[PieceIdx].ArmorZoneName)
	{
	case 'head':
		// King bloat uses 2 static attachments for the head piece.
		// Assume these are slot 0, 1 for future possible holiday purposes.
		// Min at list length in case there are fewer than default meshes.
		for (i = Min(1, StaticAttachList.Length - 1); i >= 0; --i)
		{
			Mesh.DetachComponent(StaticAttachList[i]);
			DetachComponent(StaticAttachList[i]);
			StaticAttachList.Remove(i, 1);
		}
		break;

	case 'front':
	case 'back':
		DetachComponent(ThirdPersonAttachments[PieceIdx]);
		ThirdPersonAttachments[PieceIdx] = none;
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
		ArmorHealth=1100,
		ExplosionSFXTemplate=AkEvent'WW_ZED_Abomination.Play_Abomination_Small_Armor_Explo',
		ZoneIcon=Texture2D'zed_bloatking_ui.BloatKing_Head_Armor')})
	ArmorZones.Add({(
		ArmorZoneName=front,
		AffectedHitZones=(chest,heart,stomach,abdomen),
		bAffectedByFrontDamage=true,
		bAffectedByBackDamage=false,
		SocketName=FX_Armor_Chest,
		ArmorHealth=4800,
		ExplosionSFXTemplate=AkEvent'WW_ZED_Abomination.Play_Abomination_Large_Armor_Explo',
		ZoneIcon=Texture2D'zed_bloatking_ui.BloatKing_Chest_Armor')})
	ArmorZones.Add({(
		ArmorZoneName=back,
		AffectedHitZones=(chest,heart,stomach,abdomen),
		bAffectedByFrontDamage=false,
		bAffectedByBackDamage=true,
		SocketName=FX_Armor_Back,
		ArmorHealth=3600,
		ExplosionSFXTemplate=AkEvent'WW_ZED_Abomination.Play_Abomination_Large_Armor_Explo',
		ZoneIcon=Texture2D'zed_bloatking_ui.BloatKing_Back_Armor')})

	// Resistant damage types
    ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Submachinegun',			DamageScale=(0.5)))
    ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_AssaultRifle',			DamageScale=(0.5)))
    ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Shotgun',					DamageScale=(0.4)))
    ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Handgun',					DamageScale=(0.5)))
    ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Rifle',					DamageScale=(0.5)))
    ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Slashing',							DamageScale=(1.0)))
    ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Bludgeon',							DamageScale=(1.0)))
    ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Fire',								DamageScale=(1.0)))
    ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Microwave',							DamageScale=(0.9)))
    ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Explosive',							DamageScale=(0.4)))
    ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Piercing',							DamageScale=(0.5)))
    ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Toxic',								DamageScale=(0.05))
    ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Toxic_BloatKingFart',				DamageScale=(0.00)))
    ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Toxic_BloatKingPukeMine',			DamageScale=(0.0)))
    ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Toxic_BloatKingSubspawnExplosion',  DamageScale=(25.0)))
    
    //Special cases
    ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Toxic_HRGHealthrower',				DamageScale=(1.2)))
	ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Bleeding_Hemogoblin', 	            DamageScale=(1.0)))
    ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Shrink_ShrinkRayGun',				DamageScale=(5.0)))
}

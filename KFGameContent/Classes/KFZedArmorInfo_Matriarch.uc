//=============================================================================
// KFZedArmorInfo_Matriarch
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================
class KFZedArmorInfo_Matriarch extends KFZedArmorInfo;

simulated function UpdateArmorPiece(int PieceIdx)
{
	super.UpdateArmorPiece(PieceIdx);

	switch (ArmorZones[PieceIdx].ArmorZoneName)
	{
	case 'head':
		DetachComponent(ThirdPersonAttachments[0]);
		ThirdPersonAttachments[0] = none;
		break;

	case 'claw':
		Mesh.DetachComponent(StaticAttachList[0]);
		DetachComponent(StaticAttachList[0]);
		StaticAttachList.length = 0;
		break;
	};
}

defaultproperties
{
	//@TODO: adjust content references for matriarch

    ArmorZones.Add({(
		ArmorZoneName=head,
		AffectedHitZones=(dome),
		bAffectedByFrontDamage=true,
		bAffectedByBackDamage=false,
		SocketName=FX_Armor_Chest,
		ArmorHealth=1750,
		ExplosionSFXTemplate=AkEvent'WW_ZED_Matriarch.Play_Matriarch_SFX_Armor_Break_Large',
		BonesToHideOnExplode=(Dome_Main),
		ZoneIcon=Texture2D'zed_bloatking_ui.BloatKing_Head_Armor')})
	ArmorZones.Add({(
		ArmorZoneName=claw,
		AffectedHitZones=(lhandcap, lforearm),
		bAffectedByFrontDamage=true,
		bAffectedByBackDamage=true,
		SocketName=FX_Gun_Cap,
		ArmorHealth=1750,
		ExplosionSFXTemplate=AkEvent'WW_ZED_Matriarch.Play_Matriarch_SFX_Armor_Break_Small',
		BonesToShowOnExplode=(LeftHandMain),
		BonesToHideOnExplode=(LeftHandCap),
		ZoneIcon=Texture2D'ZED_Matriarch_UI.Matriarch_ArmCanon')})

	ArmorScale=1.f

	// Resistant damage types
    ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Submachinegun', 	DamageScale=(0.5)))
    ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_AssaultRifle', 	DamageScale=(0.5)))
    ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Shotgun', 	    DamageScale=(0.4)))
    ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Handgun', 	    DamageScale=(0.5)))
    ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Rifle', 	        DamageScale=(0.5)))
    ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Slashing', 	                DamageScale=(1.0)))
	ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Bludgeon', 	                DamageScale=(1.0)))
	ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Fire', 	                    DamageScale=(0.5)))
	ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Microwave', 	            DamageScale=(0.9)))
	ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Explosive', 	            DamageScale=(0.4)))
	ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Piercing', 	                DamageScale=(0.5)))
	ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Toxic', 	                DamageScale=(0.05)))
    //special case
    ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_MicrowaveRifle',	DamageScale=(0.7)))
    ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Toxic_HRGHealthrower',		DamageScale=(0.5)))
    ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Shrink_ShrinkRayGun',		DamageScale=(5.0)))
    ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Blast_HRG_CranialPopper',	DamageScale=(0.0)))
    ArmorDamageTypeModifiers.Add((DamageType=class'KFDT_Piercing_HRG_CranialPopper',DamageScale=(2.0)))
}

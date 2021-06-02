//=============================================================================
// KFGameReplicationInfo_WeeklySurvival
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================

class KFGameReplicationInfo_WeeklySurvival extends KFGameReplicationInfo;

struct SBrokeTraderPickupItem
{
	/** Weapons available for spawning */
	var() array<class<KFWeaponDefinition> > WeaponClasses;
};

var() array<SBrokeTraderPickupItem> BrokenTraderItemPickups;

simulated function array<int> GetKFSeqEventLevelLoadedIndices()
{
	local array<int> ActivateIndices;

	ActivateIndices[0] = 7;

	return ActivateIndices;
}

simulated function OverrideWeaponPickups(out KFPickupFactory_Item ItemFactory)
{
	local int Idx;
    local ItemPickup Pickup;

	if (ItemFactory == none)
		return;

	if ( BrokenTraderItemPickups.Length == 0 || WaveNum > BrokenTraderItemPickups.Length )
		return;

	ItemFactory.ItemPickups.Remove(0, ItemFactory.ItemPickups.Length);
	
	for(Idx = 0; Idx < BrokenTraderItemPickups[WaveNum-1].WeaponClasses.Length; Idx++)
	{
		Pickup.ItemClass = class<KFWeapon> (DynamicLoadObject(BrokenTraderItemPickups[WaveNum-1].WeaponClasses[Idx].default.WeaponClassPath, class'Class'));
		ItemFactory.ItemPickups.AddItem(Pickup);
	}
}

simulated function NotifyWaveStart()
{
    local KFPickupFactory_Item ItemFactory;

	if (WorldInfo.NetMode == NM_Client && bIsBrokenTrader)
	{
		foreach AllActors(class'KFPickupFactory_Item', ItemFactory)
		{
			OverrideWeaponPickups(ItemFactory);
			ItemFactory.SetPickupMesh();
		}
	}
   
	super.NotifyWaveStart();
}

DefaultProperties
{
	BrokenTraderItemPickups={(
							(WeaponClasses={(
								class'KFGame.KFWeapDef_9mmDual',
								class'KFGame.KFWeapDef_Crovel',
								class'KFGame.KFWeapDef_MB500',
								class'KFGame.KFWeapDef_MedicPistol',
								class'KFGame.KFWeapDef_HX25',
								class'KFGame.KFWeapDef_CaulkBurn',
								class'KFGame.KFWeapDef_Remington1858Dual',
								class'KFGame.KFWeapDef_Winchester1894',
								class'KFGame.KFWeapDef_MP7',
								class'KFGame.KFWeapDef_AR15'
							)}),
							(WeaponClasses={(
								class'KFGame.KFWeapDef_Nailgun',
								class'KFGame.KFWeapDef_Katana',
								class'KFGame.KFWeapDef_ChainBat',
								class'KFGame.KFWeapDef_FireAxe',
								class'KFGame.KFWeapDef_Bullpup',
								class'KFGame.KFWeapDef_Thompson',
								class'KFGame.KFWeapDef_DoubleBarrel',
								class'KFGame.KFWeapDef_HZ12',
								class'KFGame.KFWeapDef_DragonsBreath',
								class'KFGame.KFWeapDef_MedicSMG',
								class'KFGame.KFWeapDef_Healthrower_HRG',
								class'KFGame.KFWeapDef_M79',
								class'KFGame.KFWeapDef_FlareGunDual',
								class'KFGame.KFWeapDef_Mac10',
								class'KFGame.KFWeapDef_HRGScorcher',
								class'KFGame.KFWeapDef_Colt1911Dual',
								class'KFGame.KFWeapDef_HRGWinterbite',
								class'KFGame.KFWeapDef_CenterfireMB464',
								class'KFGame.KFWeapDef_Crossbow',
								class'KFGame.KFWeapDef_MP5RAS'
								)}),
							(WeaponClasses={(
								class'KFGame.KFWeapDef_Nailgun',
								class'KFGame.KFWeapDef_Katana',
								class'KFGame.KFWeapDef_ChainBat',
								class'KFGame.KFWeapDef_FireAxe',
								class'KFGame.KFWeapDef_Bullpup',
								class'KFGame.KFWeapDef_Thompson',
								class'KFGame.KFWeapDef_DoubleBarrel',
								class'KFGame.KFWeapDef_HZ12',
								class'KFGame.KFWeapDef_DragonsBreath',
								class'KFGame.KFWeapDef_MedicSMG',
								class'KFGame.KFWeapDef_Healthrower_HRG',
								class'KFGame.KFWeapDef_M79',
								class'KFGame.KFWeapDef_FlareGunDual',
								class'KFGame.KFWeapDef_Mac10',
								class'KFGame.KFWeapDef_HRGScorcher',
								class'KFGame.KFWeapDef_Colt1911Dual',
								class'KFGame.KFWeapDef_HRGWinterbite',
								class'KFGame.KFWeapDef_CenterfireMB464',
								class'KFGame.KFWeapDef_Crossbow',
								class'KFGame.KFWeapDef_MP5RAS'
								)}),
							(WeaponClasses={(
								class'KFGame.KFWeapDef_MedicBat',
								class'KFGame.KFWeapDef_Pulverizer',
								class'KFGame.KFWeapDef_Rifle_FrostShotgunAxe',
								class'KFGame.KFWeapDef_AK12',
								class'KFGame.KFWeapDef_MKB42',
								class'KFGame.KFWeapDef_M16M203',
								class'KFGame.KFWeapDef_M4',
								class'KFGame.KFWeapDef_SW500Dual_HRG',
								class'KFGame.KFWeapDef_MedicShotgun',
								class'KFGame.KFWeapDef_Hemogoblin',
								class'KFGame.KFWeapDef_Mine_Reconstructor',
								class'KFGame.KFWeapDef_SealSqueal',
								class'KFGame.KFWeapDef_FlameThrower',
								class'KFGame.KFWeapDef_HRGIncendiaryRifle',
								class'KFGame.KFWeapDef_ChiappaRhinoDual',
								class'KFGame.KFWeapDef_DeagleDual',
								class'KFGame.KFWeapDef_M14EBR',
								class'KFGame.KFWeapDef_HRG_SonicGun',
								class'KFGame.KFWeapDef_MosinNagant',
								class'KFGame.KFWeapDef_P90',
								class'KFGame.KFWeapDef_Nailgun_HRG',
								class'KFGame.KFWeapDef_HK_UMP',
								class'KFGame.KFWeapDef_FreezeThrower',
								class'KFGame.KFWeapDef_HRG_Kaboomstick',
								class'KFGame.KFWeapDef_FAMAS'
								)}),
							(WeaponClasses={(
								class'KFGame.KFWeapDef_MedicBat',
								class'KFGame.KFWeapDef_Rifle_FrostShotgunAxe',
								class'KFGame.KFWeapDef_M16M203',
								class'KFGame.KFWeapDef_M4',
								class'KFGame.KFWeapDef_MedicShotgun',
								class'KFGame.KFWeapDef_FlameThrower',
								class'KFGame.KFWeapDef_HRGIncendiaryRifle',
								class'KFGame.KFWeapDef_DeagleDual',
								class'KFGame.KFWeapDef_HRG_SonicGun',
								class'KFGame.KFWeapDef_MosinNagant',
								class'KFGame.KFWeapDef_HK_UMP',
								class'KFGame.KFWeapDef_FreezeThrower',
								class'KFGame.KFWeapDef_HRG_Kaboomstick',
								class'KFGame.KFWeapDef_FAMAS',
								class'KFGame.KFWeapDef_Eviscerator',
								class'KFGame.KFWeapDef_FNFal',
								class'KFGame.KFWeapDef_MedicRifle',
								class'KFGame.KFWeapDef_ElephantGun',
								class'KFGame.KFWeapDef_Seeker6',
								class'KFGame.KFWeapDef_HuskCannon',
								class'KFGame.KFWeapDef_SW500Dual',
								class'KFGame.KFWeapDef_Kriss',
								class'KFGame.KFWeapDef_HRG_EMP_ArcGenerator'
								)}),
							(WeaponClasses={(
								class'KFGame.KFWeapDef_HRGTeslauncher',
								class'KFGame.KFWeapDef_Eviscerator',
								class'KFGame.KFWeapDef_MaceAndShield',
								class'KFGame.KFWeapDef_PowerGloves',
								class'KFGame.KFWeapDef_SCAR',
								class'KFGame.KFWeapDef_Stoner63A',
								class'KFGame.KFWeapDef_MedicRifle',
								class'KFGame.KFWeapDef_FNFal',
								class'KFGame.KFWeapDef_AA12',
								class'KFGame.KFWeapDef_ElephantGun',
								class'KFGame.KFWeapDef_Blunderbuss',
								class'KFGame.KFWeapDef_HRGIncision',
								class'KFGame.KFWeapDef_HRG_Vampire',
								class'KFGame.KFWeapDef_RPG7',
								class'KFGame.KFWeapDef_Seeker6',
								class'KFGame.KFWeapDef_HuskCannon',
								class'KFGame.KFWeapDef_MicrowaveGun',
								class'KFGame.KFWeapDef_SW500Dual',
								class'KFGame.KFWeapDef_AF2011Dual',
								class'KFGame.KFWeapDef_Pistol_DualG18',
								class'KFGame.KFWeapDef_RailGun',
								class'KFGame.KFWeapDef_G18',
								class'KFGame.KFWeapDef_Kriss',
								class'KFGame.KFWeapDef_HRG_EMP_ArcGenerator',
								class'KFGame.KFWeapDef_AbominationAxe',
								class'KFGame.KFWeapDef_Minigun',
								class'KFGame.KFWeapDef_MedicRifleGrenadeLauncher',
								class'KFGame.KFWeapDef_MicrowaveRifle',
								class'KFGame.KFWeapDef_CompoundBow',
								class'KFGame.KFWeapDef_M99',
								class'KFGame.KFWeapDef_LazerCutter',
								class'KFGame.KFWeapDef_HRG_BlastBrawlers',
								class'KFGame.KFWeapDef_ThermiteBore',
								class'KFGame.KFWeapDef_HRG_BarrierRifle'
								)}),
							(WeaponClasses={(
								class'KFGame.KFWeapDef_HRGTeslauncher',
								class'KFGame.KFWeapDef_Eviscerator',
								class'KFGame.KFWeapDef_MaceAndShield',
								class'KFGame.KFWeapDef_PowerGloves',
								class'KFGame.KFWeapDef_SCAR',
								class'KFGame.KFWeapDef_Stoner63A',
								class'KFGame.KFWeapDef_MedicRifle',
								class'KFGame.KFWeapDef_FNFal',
								class'KFGame.KFWeapDef_AA12',
								class'KFGame.KFWeapDef_ElephantGun',
								class'KFGame.KFWeapDef_Blunderbuss',
								class'KFGame.KFWeapDef_HRGIncision',
								class'KFGame.KFWeapDef_HRG_Vampire',
								class'KFGame.KFWeapDef_RPG7',
								class'KFGame.KFWeapDef_Seeker6',
								class'KFGame.KFWeapDef_HuskCannon',
								class'KFGame.KFWeapDef_MicrowaveGun',
								class'KFGame.KFWeapDef_SW500Dual',
								class'KFGame.KFWeapDef_AF2011Dual',
								class'KFGame.KFWeapDef_Pistol_DualG18',
								class'KFGame.KFWeapDef_RailGun',
								class'KFGame.KFWeapDef_G18',
								class'KFGame.KFWeapDef_Kriss',
								class'KFGame.KFWeapDef_HRG_EMP_ArcGenerator',
								class'KFGame.KFWeapDef_AbominationAxe',
								class'KFGame.KFWeapDef_Minigun',
								class'KFGame.KFWeapDef_MedicRifleGrenadeLauncher',
								class'KFGame.KFWeapDef_MicrowaveRifle',
								class'KFGame.KFWeapDef_CompoundBow',
								class'KFGame.KFWeapDef_M99',
								class'KFGame.KFWeapDef_LazerCutter',
								class'KFGame.KFWeapDef_HRG_BlastBrawlers',
								class'KFGame.KFWeapDef_ThermiteBore',
								class'KFGame.KFWeapDef_HRG_BarrierRifle'
								)}),
							(WeaponClasses={(
								class'KFGame.KFWeapDef_HRGTeslauncher',
								class'KFGame.KFWeapDef_Eviscerator',
								class'KFGame.KFWeapDef_MaceAndShield',
								class'KFGame.KFWeapDef_PowerGloves',
								class'KFGame.KFWeapDef_SCAR',
								class'KFGame.KFWeapDef_Stoner63A',
								class'KFGame.KFWeapDef_MedicRifle',
								class'KFGame.KFWeapDef_FNFal',
								class'KFGame.KFWeapDef_AA12',
								class'KFGame.KFWeapDef_ElephantGun',
								class'KFGame.KFWeapDef_Blunderbuss',
								class'KFGame.KFWeapDef_HRGIncision',
								class'KFGame.KFWeapDef_HRG_Vampire',
								class'KFGame.KFWeapDef_RPG7',
								class'KFGame.KFWeapDef_Seeker6',
								class'KFGame.KFWeapDef_HuskCannon',
								class'KFGame.KFWeapDef_MicrowaveGun',
								class'KFGame.KFWeapDef_SW500Dual',
								class'KFGame.KFWeapDef_AF2011Dual',
								class'KFGame.KFWeapDef_Pistol_DualG18',
								class'KFGame.KFWeapDef_RailGun',
								class'KFGame.KFWeapDef_G18',
								class'KFGame.KFWeapDef_Kriss',
								class'KFGame.KFWeapDef_HRG_EMP_ArcGenerator',
								class'KFGame.KFWeapDef_AbominationAxe',
								class'KFGame.KFWeapDef_Minigun',
								class'KFGame.KFWeapDef_MedicRifleGrenadeLauncher',
								class'KFGame.KFWeapDef_MicrowaveRifle',
								class'KFGame.KFWeapDef_CompoundBow',
								class'KFGame.KFWeapDef_M99',
								class'KFGame.KFWeapDef_LazerCutter',
								class'KFGame.KFWeapDef_HRG_BlastBrawlers',
								class'KFGame.KFWeapDef_ThermiteBore',
								class'KFGame.KFWeapDef_HRG_BarrierRifle'
								)})
						)}
}

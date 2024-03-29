//=============================================================================
// KFWeaponSkinList
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFWeaponSkinList extends Object
	abstract
    native;

struct native WeaponSkin
{
	/** Steam item Id */
	var int 	Id;

	/** Material DLO Paths */
	var array<string> 	MIC_1P;
	var string 			MIC_3P;
	var string  		MIC_Pickup;

	/** Basic Info about associated weapon */
	var class<KFWeaponDefinition> WeaponDef;

	var bool bNeedsCodeUpdates;
};

enum EWeaponSkinType
{
	WST_FirstPerson,
	WST_ThirdPerson,
	WST_Pickup,
};

var const array<WeaponSkin> Skins;

/** Returns material given a weapon skin item Id */
static native function array<MaterialInterface> GetWeaponSkin(int ItemId, EWeaponSkinType Type);
static native function array<string> GetWeaponSkinPaths(int ItemId, EWeaponSkinType Type);

/** Inventory UI, read / write skin equip */
static native function SaveWeaponSkin(class<KFWeaponDefinition> WeaponDef, int ID);
static native function bool IsSkinEquip(class<KFWeaponDefinition> WeaponDef, int ID);

static native function bool SkinNeedsCodeUpdates(int SkinId);

defaultproperties
{
//Anodized Hazard AR15
	Skins.Add((Id=3001, Weapondef=class'KFWeapDef_AR15', MIC_1P=("WEP_SkinSet01_MAT.anodizedhazard_ar15.AnodizedHazard_AR15_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_MAT.anodizedhazard_ar15.AnodizedHazard_AR15_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_MAT.anodizedhazard_ar15.AnodizedHazard_AR15_3P_Pickup_MIC"))
 	Skins.Add((Id=3002, Weapondef=class'KFWeapDef_AR15', MIC_1P=("WEP_SkinSet01_MAT.anodizedhazard_ar15.AnodizedHazard_AR15_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet01_MAT.anodizedhazard_ar15.AnodizedHazard_AR15_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet01_MAT.anodizedhazard_ar15.AnodizedHazard_AR15_3P_Pickup_MIC"))
	Skins.Add((Id=3003, Weapondef=class'KFWeapDef_AR15', MIC_1P=("WEP_SkinSet01_MAT.anodizedhazard_ar15.AnodizedHazard_AR15_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet01_MAT.anodizedhazard_ar15.AnodizedHazard_AR15_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet01_MAT.anodizedhazard_ar15.AnodizedHazard_AR15_3P_Pickup_MIC"))

//Airlock 9mm
	Skins.Add((Id=3004, Weapondef=class'KFWeapDef_9mm', MIC_1P=("WEP_SkinSet01_MAT.airlock_9mm.Airlock_9MM_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_MAT.airlock_9mm.Airlock_9MM_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_MAT.airlock_9mm.Airlock_9MM_3P_Pickup_MIC"))
 	Skins.Add((Id=3005, Weapondef=class'KFWeapDef_9mm', MIC_1P=("WEP_SkinSet01_MAT.airlock_9mm.Airlock_9MM_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet01_MAT.airlock_9mm.Airlock_9MM_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet01_MAT.airlock_9mm.Airlock_9MM_3P_Pickup_MIC"))
	Skins.Add((Id=3006, Weapondef=class'KFWeapDef_9mm', MIC_1P=("WEP_SkinSet01_MAT.airlock_9mm.Airlock_9MM_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet01_MAT.airlock_9mm.Airlock_9MM_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet01_MAT.airlock_9mm.Airlock_9MM_3P_Pickup_MIC"))

//Aeronaut Bullpup
	Skins.Add((Id=3007, Weapondef=class'KFWeapDef_Bullpup', MIC_1P=("WEP_SkinSet01_MAT.aeronaut_bullpup.Aeronaut_Bullpup_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_MAT.aeronaut_bullpup.Aeronaut_Bullpup_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_MAT.aeronaut_bullpup.Aeronaut_Bullpup_3P_Pickup_MIC"))
	Skins.Add((Id=3008, Weapondef=class'KFWeapDef_Bullpup', MIC_1P=("WEP_SkinSet01_MAT.aeronaut_bullpup.Aeronaut_Bullpup_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet01_MAT.aeronaut_bullpup.Aeronaut_Bullpup_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet01_MAT.aeronaut_bullpup.Aeronaut_Bullpup_3P_Pickup_MIC"))
	Skins.Add((Id=3009, Weapondef=class'KFWeapDef_Bullpup', MIC_1P=("WEP_SkinSet01_MAT.aeronaut_bullpup.Aeronaut_Bullpup_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet01_MAT.aeronaut_bullpup.Aeronaut_Bullpup_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet01_MAT.aeronaut_bullpup.Aeronaut_Bullpup_3P_Pickup_MIC"))

//Woodland AA12
	Skins.Add((Id=3010, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSetPSN03_MAT.woodland_aa12.Woodland_AA12_1P_Mint_MIC"), MIC_3P="WEP_SkinSetPSN03_MAT.woodland_aa12.Woodland_AA12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSetPSN03_MAT.woodland_aa12.Woodland_AA12_3P_Pickup_MIC"))
 	Skins.Add((Id=3011, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSetPSN03_MAT.woodland_aa12.Woodland_AA12_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSetPSN03_MAT.woodland_aa12.Woodland_AA12_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSetPSN03_MAT.woodland_aa12.Woodland_AA12_3P_Pickup_MIC"))
	Skins.Add((Id=3012, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSetPSN03_MAT.woodland_aa12.Woodland_AA12_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSetPSN03_MAT.woodland_aa12.Woodland_AA12_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSetPSN03_MAT.woodland_aa12.Woodland_AA12_3P_Pickup_MIC"))

//Woodland Boomstick
	Skins.Add((Id=3013, Weapondef=class'KFWeapDef_DoubleBarrel', MIC_1P=("WEP_SkinSetPSN03_MAT.woodland_doublebarrel.Woodland_DoubleBarrel_1P_Mint_MIC"), MIC_3P="WEP_SkinSetPSN03_MAT.woodland_doublebarrel.Woodland_DoubleBarrel_3P_Mint_MIC", MIC_Pickup="WEP_SkinSetPSN03_MAT.woodland_doublebarrel.Woodland_DoubleBarrel_3P_Pickup_MIC"))
 	Skins.Add((Id=3014, Weapondef=class'KFWeapDef_DoubleBarrel', MIC_1P=("WEP_SkinSetPSN03_MAT.woodland_doublebarrel.Woodland_DoubleBarrel_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSetPSN03_MAT.woodland_doublebarrel.Woodland_DoubleBarrel_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSetPSN03_MAT.woodland_doublebarrel.Woodland_DoubleBarrel_3P_Pickup_MIC"))
	Skins.Add((Id=3015, Weapondef=class'KFWeapDef_DoubleBarrel', MIC_1P=("WEP_SkinSetPSN03_MAT.woodland_doublebarrel.Woodland_DoubleBarrel_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSetPSN03_MAT.woodland_doublebarrel.Woodland_DoubleBarrel_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSetPSN03_MAT.woodland_doublebarrel.Woodland_DoubleBarrel_3P_Pickup_MIC"))

//Woodland L85A2
	Skins.Add((Id=3016, Weapondef=class'KFWeapDef_Bullpup', MIC_1P=("WEP_SkinSetPSN03_MAT.woodland_bullpup.Woodland_Bullpup_1P_Mint_MIC"), MIC_3P="WEP_SkinSetPSN03_MAT.woodland_bullpup.Woodland_Bullpup_3P_Mint_MIC", MIC_Pickup="WEP_SkinSetPSN03_MAT.woodland_bullpup.Woodland_Bullpup_3P_Pickup_MIC"))
 	Skins.Add((Id=3017, Weapondef=class'KFWeapDef_Bullpup', MIC_1P=("WEP_SkinSetPSN03_MAT.woodland_bullpup.Woodland_Bullpup_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSetPSN03_MAT.woodland_bullpup.Woodland_Bullpup_3P_Mint_MIC", MIC_Pickup="WEP_SkinSetPSN03_MAT.woodland_bullpup.Woodland_Bullpup_3P_Pickup_MIC"))
	Skins.Add((Id=3018, Weapondef=class'KFWeapDef_Bullpup', MIC_1P=("WEP_SkinSetPSN03_MAT.woodland_bullpup.Woodland_Bullpup_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSetPSN03_MAT.woodland_bullpup.Woodland_Bullpup_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSetPSN03_MAT.woodland_bullpup.Woodland_Bullpup_3P_Pickup_MIC"))

//Woodland Scar
	Skins.Add((Id=3019, Weapondef=class'KFWeapDef_SCAR', MIC_1P=("WEP_SkinSetPSN03_MAT.woodland_scar.Woodland_SCAR_1P_Mint_MIC"), MIC_3P="WEP_SkinSetPSN03_MAT.woodland_scar.Woodland_SCAR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSetPSN03_MAT.woodland_scar.Woodland_SCAR_3P_Pickup_MIC"))
	Skins.Add((Id=3020, Weapondef=class'KFWeapDef_SCAR', MIC_1P=("WEP_SkinSetPSN03_MAT.woodland_scar.Woodland_SCAR_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSetPSN03_MAT.woodland_scar.Woodland_SCAR_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSetPSN03_MAT.woodland_scar.Woodland_SCAR_3P_Pickup_MIC"))
	Skins.Add((Id=3021, Weapondef=class'KFWeapDef_SCAR', MIC_1P=("WEP_SkinSetPSN03_MAT.woodland_scar.Woodland_SCAR_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSetPSN03_MAT.woodland_scar.Woodland_SCAR_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSetPSN03_MAT.woodland_scar.Woodland_SCAR_3P_Pickup_MIC"))

//Arachnid Nailgun
	Skins.Add((Id=3022, Weapondef=class'KFWeapDef_NailGun', MIC_1P=("WEP_SkinSetPSN01_MAT.arachnid_nailgun.Arachnid_NailGun_1P_Mint_MIC"), MIC_3P="WEP_SkinSetPSN01_MAT.arachnid_nailgun.Arachnid_NailGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSetPSN01_MAT.arachnid_nailgun.Arachnid_NailGun_3P_Pickup_MIC"))
	Skins.Add((Id=3023, Weapondef=class'KFWeapDef_NailGun', MIC_1P=("WEP_SkinSetPSN01_MAT.arachnid_nailgun.Arachnid_NailGun_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSetPSN01_MAT.arachnid_nailgun.Arachnid_NailGun_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSetPSN01_MAT.arachnid_nailgun.Arachnid_NailGun_3P_Pickup_MIC"))
	Skins.Add((Id=3024, Weapondef=class'KFWeapDef_NailGun', MIC_1P=("WEP_SkinSetPSN01_MAT.arachnid_nailgun.Arachnid_NailGun_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSetPSN01_MAT.arachnid_nailgun.Arachnid_NailGun_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSetPSN01_MAT.arachnid_nailgun.Arachnid_NailGun_3P_Pickup_MIC"))

//Bloated 9mm
	Skins.Add((Id=3025, Weapondef=class'KFWeapDef_9mm', MIC_1P=("WEP_SkinSetPSN01_MAT.bloated_9mm.Bloated_9mm_1P_Mint_MIC"), MIC_3P="WEP_SkinSetPSN01_MAT.bloated_9mm.Bloated_9mm_3P_Mint_MIC", MIC_Pickup="WEP_SkinSetPSN01_MAT.bloated_9mm.Bloated_9mm_3P_Pickup_MIC"))
	Skins.Add((Id=3026, Weapondef=class'KFWeapDef_9mm', MIC_1P=("WEP_SkinSetPSN01_MAT.bloated_9mm.Bloated_9mm_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSetPSN01_MAT.bloated_9mm.Bloated_9mm_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSetPSN01_MAT.bloated_9mm.Bloated_9mm_3P_Pickup_MIC"))
	Skins.Add((Id=3027, Weapondef=class'KFWeapDef_9mm', MIC_1P=("WEP_SkinSetPSN01_MAT.bloated_9mm.Bloated_9mm_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSetPSN01_MAT.bloated_9mm.Bloated_9mm_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSetPSN01_MAT.bloated_9mm.Bloated_9mm_3P_Pickup_MIC"))

//Monster Killer M4
	Skins.Add((Id=3028, Weapondef=class'KFWeapDef_M4', MIC_1P=("WEP_SkinSet01_MAT.monsterkiller_m4.MonsterKiller_M4_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_MAT.monsterkiller_m4.MonsterKiller_M4_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_MAT.monsterkiller_m4.MonsterKiller_M4_3P_Pickup_MIC"))
	Skins.Add((Id=3029, Weapondef=class'KFWeapDef_M4', MIC_1P=("WEP_SkinSet01_MAT.monsterkiller_m4.MonsterKiller_M4_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet01_MAT.monsterkiller_m4.MonsterKiller_M4_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet01_MAT.monsterkiller_m4.MonsterKiller_M4_3P_Pickup_MIC"))
	Skins.Add((Id=3030, Weapondef=class'KFWeapDef_M4', MIC_1P=("WEP_SkinSet01_MAT.monsterkiller_m4.MonsterKiller_M4_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet01_MAT.monsterkiller_m4.MonsterKiller_M4_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet01_MAT.monsterkiller_m4.MonsterKiller_M4_3P_Pickup_MIC"))

//Grave Digger Crovel
	Skins.Add((Id=3031, Weapondef=class'KFWeapDef_Crovel', MIC_1P=("WEP_SkinSetPSN01_MAT.gravedigger_crovel.GraveDigger_Crovel_1P_Mint_MIC"), MIC_3P="WEP_SkinSetPSN01_MAT.gravedigger_crovel.GraveDigger_Crovel_3P_Mint_MIC", MIC_Pickup="WEP_SkinSetPSN01_MAT.gravedigger_crovel.GraveDigger_Crovel_3P_Pickup_MIC"))
	Skins.Add((Id=3032, Weapondef=class'KFWeapDef_Crovel', MIC_1P=("WEP_SkinSetPSN01_MAT.gravedigger_crovel.GraveDigger_Crovel_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSetPSN01_MAT.gravedigger_crovel.GraveDigger_Crovel_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSetPSN01_MAT.gravedigger_crovel.GraveDigger_Crovel_3P_Pickup_MIC"))
	Skins.Add((Id=3033, Weapondef=class'KFWeapDef_Crovel', MIC_1P=("WEP_SkinSetPSN01_MAT.gravedigger_crovel.GraveDigger_Crovel_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSetPSN01_MAT.gravedigger_crovel.GraveDigger_Crovel_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSetPSN01_MAT.gravedigger_crovel.GraveDigger_Crovel_3P_Pickup_MIC"))

//Clot Commando Scar
	Skins.Add((Id=3036, Weapondef=class'KFWeapDef_SCAR', MIC_1P=("WEP_SkinSetPSN01_MAT.clotcommando_scar.ClotCommando_SCAR_1P_Mint_MIC"), MIC_3P="WEP_SkinSetPSN01_MAT.clotcommando_scar.ClotCommando_SCAR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSetPSN01_MAT.clotcommando_scar.ClotCommando_SCAR_3P_Pickup_MIC"))
	Skins.Add((Id=3035, Weapondef=class'KFWeapDef_SCAR', MIC_1P=("WEP_SkinSetPSN01_MAT.clotcommando_scar.ClotCommando_SCAR_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSetPSN01_MAT.clotcommando_scar.ClotCommando_SCAR_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSetPSN01_MAT.clotcommando_scar.ClotCommando_SCAR_3P_Pickup_MIC"))
	Skins.Add((Id=3034, Weapondef=class'KFWeapDef_SCAR', MIC_1P=("WEP_SkinSetPSN01_MAT.clotcommando_scar.ClotCommando_SCAR_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSetPSN01_MAT.clotcommando_scar.ClotCommando_SCAR_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSetPSN01_MAT.clotcommando_scar.ClotCommando_SCAR_3P_Pickup_MIC"))

//Shark Teeth Double Barrel
	Skins.Add((Id=3039, Weapondef=class'KFWeapDef_DoubleBarrel', MIC_1P=("WEP_SkinSet01_MAT.sharkteeth_doublebarrel.SharkTeeth_DoubleBarrel_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_MAT.sharkteeth_doublebarrel.SharkTeeth_DoubleBarrel_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_MAT.sharkteeth_doublebarrel.SharkTeeth_DoubleBarrel_3P_Pickup_MIC"))
	Skins.Add((Id=3038, Weapondef=class'KFWeapDef_DoubleBarrel', MIC_1P=("WEP_SkinSet01_MAT.sharkteeth_doublebarrel.SharkTeeth_DoubleBarrel_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet01_MAT.sharkteeth_doublebarrel.SharkTeeth_DoubleBarrel_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet01_MAT.sharkteeth_doublebarrel.SharkTeeth_DoubleBarrel_3P_Pickup_MIC"))
	Skins.Add((Id=3037, Weapondef=class'KFWeapDef_DoubleBarrel', MIC_1P=("WEP_SkinSet01_MAT.sharkteeth_doublebarrel.SharkTeeth_DoubleBarrel_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet01_MAT.sharkteeth_doublebarrel.SharkTeeth_DoubleBarrel_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet01_MAT.sharkteeth_doublebarrel.SharkTeeth_DoubleBarrel_3P_Pickup_MIC"))

//Tiger RPG7
	Skins.Add((Id=3042, Weapondef=class'KFWeapDef_RPG7', MIC_1P=("WEP_SkinSetPSN03_MAT.tiger_rpg7.Tiger_RPG7_1P_Mint_MIC"), MIC_3P="WEP_SkinSetPSN03_MAT.tiger_rpg7.Tiger_RPG7_3P_Mint_MIC", MIC_Pickup="WEP_SkinSetPSN03_MAT.tiger_rpg7.Tiger_RPG7_3P_Pickup_MIC"))
	Skins.Add((Id=3041, Weapondef=class'KFWeapDef_RPG7', MIC_1P=("WEP_SkinSetPSN03_MAT.tiger_rpg7.Tiger_RPG7_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSetPSN03_MAT.tiger_rpg7.Tiger_RPG7_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSetPSN03_MAT.tiger_rpg7.Tiger_RPG7_3P_Pickup_MIC"))
	Skins.Add((Id=3040, Weapondef=class'KFWeapDef_RPG7', MIC_1P=("WEP_SkinSetPSN03_MAT.tiger_rpg7.Tiger_RPG7_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSetPSN03_MAT.tiger_rpg7.Tiger_RPG7_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSetPSN03_MAT.tiger_rpg7.Tiger_RPG7_3P_Pickup_MIC"))

//Tiger M79
	Skins.Add((Id=3046, Weapondef=class'KFWeapDef_M79', MIC_1P=("WEP_SkinSetPSN03_MAT.tiger_m79.Tiger_M79_1P_Mint_MIC"), MIC_3P="WEP_SkinSetPSN03_MAT.tiger_m79.Tiger_M79_3P_Mint_MIC", MIC_Pickup="WEP_SkinSetPSN03_MAT.tiger_m79.Tiger_M79_3P_Pickup_MIC"))
	Skins.Add((Id=3045, Weapondef=class'KFWeapDef_M79', MIC_1P=("WEP_SkinSetPSN03_MAT.tiger_m79.Tiger_M79_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSetPSN03_MAT.tiger_m79.Tiger_M79_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSetPSN03_MAT.tiger_m79.Tiger_M79_3P_Pickup_MIC"))
	Skins.Add((Id=3044, Weapondef=class'KFWeapDef_M79', MIC_1P=("WEP_SkinSetPSN03_MAT.tiger_m79.Tiger_M79_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSetPSN03_MAT.tiger_m79.Tiger_M79_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSetPSN03_MAT.tiger_m79.Tiger_M79_3P_Pickup_MIC"))

//Tiger HX25
	Skins.Add((Id=3049, Weapondef=class'KFWeapDef_HX25', MIC_1P=("WEP_SkinSetPSN03_MAT.tiger_hx25.Tiger_HX25_1P_Mint_MIC"), MIC_3P="WEP_SkinSetPSN03_MAT.tiger_hx25.Tiger_HX25_3P_Mint_MIC", MIC_Pickup="WEP_SkinSetPSN03_MAT.tiger_hx25.Tiger_HX25_3P_Pickup_MIC"))
	Skins.Add((Id=3048, Weapondef=class'KFWeapDef_HX25', MIC_1P=("WEP_SkinSetPSN03_MAT.tiger_hx25.Tiger_HX25_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSetPSN03_MAT.tiger_hx25.Tiger_HX25_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSetPSN03_MAT.tiger_hx25.Tiger_HX25_3P_Pickup_MIC"))
	Skins.Add((Id=3047, Weapondef=class'KFWeapDef_HX25', MIC_1P=("WEP_SkinSetPSN03_MAT.tiger_hx25.Tiger_HX25_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSetPSN03_MAT.tiger_hx25.Tiger_HX25_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSetPSN03_MAT.tiger_hx25.Tiger_HX25_3P_Pickup_MIC"))

//Tiger AK12
	Skins.Add((Id=3052, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSetPSN03_MAT.tiger_ak12.Tiger_AK12_1P_Mint_MIC"), MIC_3P="WEP_SkinSetPSN03_MAT.tiger_ak12.Tiger_AK12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSetPSN03_MAT.tiger_ak12.Tiger_AK12_3P_Pickup_MIC"))
	Skins.Add((Id=3051, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSetPSN03_MAT.tiger_ak12.Tiger_AK12_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSetPSN03_MAT.tiger_ak12.Tiger_AK12_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSetPSN03_MAT.tiger_ak12.Tiger_AK12_3P_Pickup_MIC"))
	Skins.Add((Id=3050, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSetPSN03_MAT.tiger_ak12.Tiger_AK12_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSetPSN03_MAT.tiger_ak12.Tiger_AK12_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSetPSN03_MAT.tiger_ak12.Tiger_AK12_3P_Pickup_MIC"))

//Skull Cracker Pulverizer
	Skins.Add((Id=3055, Weapondef=class'KFWeapDef_Pulverizer', MIC_1P=("WEP_SkinSetPSN01_MAT.skullcracker_pulverizer.SkullCracker_Pulverizer_1P_Mint_MIC"), MIC_3P="WEP_SkinSetPSN01_MAT.skullcracker_pulverizer.SkullCracker_Pulverizer_3P_Mint_MIC", MIC_Pickup="WEP_SkinSetPSN01_MAT.skullcracker_pulverizer.SkullCracker_Pulverizer_3P_Pickup_MIC"))
	Skins.Add((Id=3054, Weapondef=class'KFWeapDef_Pulverizer', MIC_1P=("WEP_SkinSetPSN01_MAT.skullcracker_pulverizer.SkullCracker_Pulverizer_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSetPSN01_MAT.skullcracker_pulverizer.SkullCracker_Pulverizer_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSetPSN01_MAT.skullcracker_pulverizer.SkullCracker_Pulverizer_3P_Pickup_MIC"))
	Skins.Add((Id=3053, Weapondef=class'KFWeapDef_Pulverizer', MIC_1P=("WEP_SkinSetPSN01_MAT.skullcracker_pulverizer.SkullCracker_Pulverizer_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSetPSN01_MAT.skullcracker_pulverizer.SkullCracker_Pulverizer_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSetPSN01_MAT.skullcracker_pulverizer.SkullCracker_Pulverizer_3P_Pickup_MIC"))

//Fleshpounder AA12
	Skins.Add((Id=3058, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSetPSN01_MAT.fleshpounder_aa12.Fleshpounder_AA12_1P_Mint_MIC"), MIC_3P="WEP_SkinSetPSN01_MAT.fleshpounder_aa12.Fleshpounder_AA12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSetPSN01_MAT.fleshpounder_aa12.Fleshpounder_AA12_3P_Pickup_MIC"))
	Skins.Add((Id=3057, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSetPSN01_MAT.fleshpounder_aa12.Fleshpounder_AA12_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSetPSN01_MAT.fleshpounder_aa12.Fleshpounder_AA12_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSetPSN01_MAT.fleshpounder_aa12.Fleshpounder_AA12_3P_Pickup_MIC"))
	Skins.Add((Id=3056, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSetPSN01_MAT.fleshpounder_aa12.Fleshpounder_AA12_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSetPSN01_MAT.fleshpounder_aa12.Fleshpounder_AA12_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSetPSN01_MAT.fleshpounder_aa12.Fleshpounder_AA12_3P_Pickup_MIC"))

//Horzine Elite Blue SCAR
	Skins.Add((Id=3064, Weapondef=class'KFWeapDef_SCAR', MIC_1P=("WEP_SkinSet01_MAT.horzineeliteblue_scar.HorzineEliteBlue_SCAR_1P_Mint_MIC", "WEP_SkinSet01_MAT.horzineeliteblue_scar.HorzineEliteBlue_SCAR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_MAT.horzineeliteblue_scar.HorzineEliteBlue_SCAR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_MAT.horzineeliteblue_scar.HorzineEliteBlue_SCAR_3P_Pickup_MIC"))
	Skins.Add((Id=3063, Weapondef=class'KFWeapDef_SCAR', MIC_1P=("WEP_SkinSet01_MAT.horzineeliteblue_scar.HorzineEliteBlue_SCAR_1P_FieldTested_MIC", "WEP_SkinSet01_MAT.horzineeliteblue_scar.HorzineEliteBlue_SCAR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_MAT.horzineeliteblue_scar.HorzineEliteBlue_SCAR_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet01_MAT.horzineeliteblue_scar.HorzineEliteBlue_SCAR_3P_Pickup_MIC"))
	Skins.Add((Id=3062, Weapondef=class'KFWeapDef_SCAR', MIC_1P=("WEP_SkinSet01_MAT.horzineeliteblue_scar.HorzineEliteBlue_SCAR_1P_BattleScarred_MIC", "WEP_SkinSet01_MAT.horzineeliteblue_scar.HorzineEliteBlue_SCAR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_MAT.horzineeliteblue_scar.HorzineEliteBlue_SCAR_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet01_MAT.horzineeliteblue_scar.HorzineEliteBlue_SCAR_3P_Pickup_MIC"))

//Horzine Elite Red SCAR
	Skins.Add((Id=3061, Weapondef=class'KFWeapDef_SCAR', MIC_1P=("WEP_SkinSet01_MAT.horzineelitered_scar.HorzineEliteRed_SCAR_1P_Mint_MIC", "WEP_SkinSet01_MAT.horzineelitered_scar.HorzineEliteRed_SCAR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_MAT.horzineelitered_scar.HorzineEliteRed_SCAR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_MAT.horzineelitered_scar.HorzineEliteRed_SCAR_3P_Pickup_MIC"))
	Skins.Add((Id=3060, Weapondef=class'KFWeapDef_SCAR', MIC_1P=("WEP_SkinSet01_MAT.horzineelitered_scar.HorzineEliteRed_SCAR_1P_FieldTested_MIC", "WEP_SkinSet01_MAT.horzineelitered_scar.HorzineEliteRed_SCAR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_MAT.horzineelitered_scar.HorzineEliteRed_SCAR_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet01_MAT.horzineelitered_scar.HorzineEliteRed_SCAR_3P_Pickup_MIC"))
	Skins.Add((Id=3059, Weapondef=class'KFWeapDef_SCAR', MIC_1P=("WEP_SkinSet01_MAT.horzineelitered_scar.HorzineEliteRed_SCAR_1P_BattleScarred_MIC", "WEP_SkinSet01_MAT.horzineelitered_scar.HorzineEliteRed_SCAR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_MAT.horzineelitered_scar.HorzineEliteRed_SCAR_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet01_MAT.horzineelitered_scar.HorzineEliteRed_SCAR_3P_Pickup_MIC"))

//Horzine Elite White SCAR
	Skins.Add((Id=3613, Weapondef=class'KFWeapDef_SCAR', MIC_1P=("WEP_SkinSet03_MAT.horzineelitewhite_scar.HorzineEliteWhite_SCAR_1P_Mint_MIC", "WEP_SkinSet03_MAT.horzineelitewhite_scar.HorzineEliteWhite_SCAR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet03_MAT.horzineelitewhite_scar.HorzineEliteWhite_SCAR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet03_MAT.horzineelitewhite_scar.HorzineEliteWhite_SCAR_3P_Pickup_MIC"))
	Skins.Add((Id=3612, Weapondef=class'KFWeapDef_SCAR', MIC_1P=("WEP_SkinSet03_MAT.horzineelitewhite_scar.HorzineEliteWhite_SCAR_1P_FieldTested_MIC", "WEP_SkinSet03_MAT.horzineelitewhite_scar.HorzineEliteWhite_SCAR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet03_MAT.horzineelitewhite_scar.HorzineEliteWhite_SCAR_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet03_MAT.horzineelitewhite_scar.HorzineEliteWhite_SCAR_3P_Pickup_MIC"))
	Skins.Add((Id=3611, Weapondef=class'KFWeapDef_SCAR', MIC_1P=("WEP_SkinSet03_MAT.horzineelitewhite_scar.HorzineEliteWhite_SCAR_1P_BattleScarred_MIC", "WEP_SkinSet03_MAT.horzineelitewhite_scar.HorzineEliteWhite_SCAR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet03_MAT.horzineelitewhite_scar.HorzineEliteWhite_SCAR_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet03_MAT.horzineelitewhite_scar.HorzineEliteWhite_SCAR_3P_Pickup_MIC"))

//Horzine Elite Green SCAR
	Skins.Add((Id=3616, Weapondef=class'KFWeapDef_SCAR', MIC_1P=("WEP_SkinSet03_MAT.horzineelitegreen_scar.HorzineEliteGreen_SCAR_1P_Mint_MIC", "WEP_SkinSet03_MAT.horzineelitegreen_scar.HorzineEliteGreen_SCAR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet03_MAT.horzineelitegreen_scar.HorzineEliteGreen_SCAR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet03_MAT.horzineelitegreen_scar.HorzineEliteGreen_SCAR_3P_Pickup_MIC"))
	Skins.Add((Id=3615, Weapondef=class'KFWeapDef_SCAR', MIC_1P=("WEP_SkinSet03_MAT.horzineelitegreen_scar.HorzineEliteGreen_SCAR_1P_FieldTested_MIC", "WEP_SkinSet03_MAT.horzineelitegreen_scar.HorzineEliteGreen_SCAR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet03_MAT.horzineelitegreen_scar.HorzineEliteGreen_SCAR_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet03_MAT.horzineelitegreen_scar.HorzineEliteGreen_SCAR_3P_Pickup_MIC"))
	Skins.Add((Id=3614, Weapondef=class'KFWeapDef_SCAR', MIC_1P=("WEP_SkinSet03_MAT.horzineelitegreen_scar.HorzineEliteGreen_SCAR_1P_BattleScarred_MIC", "WEP_SkinSet03_MAT.horzineelitegreen_scar.HorzineEliteGreen_SCAR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet03_MAT.horzineelitegreen_scar.HorzineEliteGreen_SCAR_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet03_MAT.horzineelitegreen_scar.HorzineEliteGreen_SCAR_3P_Pickup_MIC"))

//Horzine Elite Blue L85A2
	Skins.Add((Id=3619, Weapondef=class'KFWeapDef_Bullpup', MIC_1P=("WEP_SkinSet03_MAT.horzineeliteblue_l85a2.HorzineEliteBlue_L85A2_1P_Mint_MIC", "WEP_SkinSet03_MAT.horzineeliteblue_l85a2.HorzineEliteBlue_L85A2_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet03_MAT.horzineeliteblue_l85a2.HorzineEliteBlue_L85A2_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet03_MAT.horzineeliteblue_l85a2.HorzineEliteBlue_L85A2_3P_Pickup_MIC"))
	Skins.Add((Id=3618, Weapondef=class'KFWeapDef_Bullpup', MIC_1P=("WEP_SkinSet03_MAT.horzineeliteblue_l85a2.HorzineEliteBlue_L85A2_1P_FieldTested_MIC", "WEP_SkinSet03_MAT.horzineeliteblue_l85a2.HorzineEliteBlue_L85A2_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet03_MAT.horzineeliteblue_l85a2.HorzineEliteBlue_L85A2_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet03_MAT.horzineeliteblue_l85a2.HorzineEliteBlue_L85A2_3P_Pickup_MIC"))
	Skins.Add((Id=3617, Weapondef=class'KFWeapDef_Bullpup', MIC_1P=("WEP_SkinSet03_MAT.horzineeliteblue_l85a2.HorzineEliteBlue_L85A2_1P_BattleScarred_MIC", "WEP_SkinSet03_MAT.horzineeliteblue_l85a2.HorzineEliteBlue_L85A2_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet03_MAT.horzineeliteblue_l85a2.HorzineEliteBlue_L85A2_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet03_MAT.horzineeliteblue_l85a2.HorzineEliteBlue_L85A2_3P_Pickup_MIC"))

//Horzine Elite Red L85A2
	Skins.Add((Id=3622, Weapondef=class'KFWeapDef_Bullpup', MIC_1P=("WEP_SkinSet03_MAT.horzineelitered_l85a2.HorzineEliteRed_L85A2_1P_Mint_MIC", "WEP_SkinSet03_MAT.horzineelitered_l85a2.HorzineEliteRed_L85A2_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet03_MAT.horzineelitered_l85a2.HorzineEliteRed_L85A2_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet03_MAT.horzineelitered_l85a2.HorzineEliteRed_L85A2_3P_Pickup_MIC"))
	Skins.Add((Id=3621, Weapondef=class'KFWeapDef_Bullpup', MIC_1P=("WEP_SkinSet03_MAT.horzineelitered_l85a2.HorzineEliteRed_L85A2_1P_FieldTested_MIC", "WEP_SkinSet03_MAT.horzineelitered_l85a2.HorzineEliteRed_L85A2_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet03_MAT.horzineelitered_l85a2.HorzineEliteRed_L85A2_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet03_MAT.horzineelitered_l85a2.HorzineEliteRed_L85A2_3P_Pickup_MIC"))
	Skins.Add((Id=3620, Weapondef=class'KFWeapDef_Bullpup', MIC_1P=("WEP_SkinSet03_MAT.horzineelitered_l85a2.HorzineEliteRed_L85A2_1P_BattleScarred_MIC", "WEP_SkinSet03_MAT.horzineelitered_l85a2.HorzineEliteRed_L85A2_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet03_MAT.horzineelitered_l85a2.HorzineEliteRed_L85A2_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet03_MAT.horzineelitered_l85a2.HorzineEliteRed_L85A2_3P_Pickup_MIC"))

//Horzine Elite White L85A2
	Skins.Add((Id=3625, Weapondef=class'KFWeapDef_Bullpup', MIC_1P=("WEP_SkinSet03_MAT.horzineelitewhite_l85a2.HorzineEliteWhite_L85A2_1P_Mint_MIC", "WEP_SkinSet03_MAT.horzineelitewhite_l85a2.HorzineEliteWhite_L85A2_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet03_MAT.horzineelitewhite_l85a2.HorzineEliteWhite_L85A2_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet03_MAT.horzineelitewhite_l85a2.HorzineEliteWhite_L85A2_3P_Pickup_MIC"))
	Skins.Add((Id=3624, Weapondef=class'KFWeapDef_Bullpup', MIC_1P=("WEP_SkinSet03_MAT.horzineelitewhite_l85a2.HorzineEliteWhite_L85A2_1P_FieldTested_MIC", "WEP_SkinSet03_MAT.horzineelitewhite_l85a2.HorzineEliteWhite_L85A2_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet03_MAT.horzineelitewhite_l85a2.HorzineEliteWhite_L85A2_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet03_MAT.horzineelitewhite_l85a2.HorzineEliteWhite_L85A2_3P_Pickup_MIC"))
	Skins.Add((Id=3623, Weapondef=class'KFWeapDef_Bullpup', MIC_1P=("WEP_SkinSet03_MAT.horzineelitewhite_l85a2.HorzineEliteWhite_L85A2_1P_BattleScarred_MIC", "WEP_SkinSet03_MAT.horzineelitewhite_l85a2.HorzineEliteWhite_L85A2_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet03_MAT.horzineelitewhite_l85a2.HorzineEliteWhite_L85A2_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet03_MAT.horzineelitewhite_l85a2.HorzineEliteWhite_L85A2_3P_Pickup_MIC"))

//Horzine Elite Green L85A2
	Skins.Add((Id=3628, Weapondef=class'KFWeapDef_Bullpup', MIC_1P=("WEP_SkinSet03_MAT.horzineelitegreen_l85a2.HorzineEliteGreen_L85A2_1P_Mint_MIC", "WEP_SkinSet03_MAT.horzineelitegreen_l85a2.HorzineEliteGreen_L85A2_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet03_MAT.horzineelitegreen_l85a2.HorzineEliteGreen_L85A2_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet03_MAT.horzineelitegreen_l85a2.HorzineEliteGreen_L85A2_3P_Pickup_MIC"))
	Skins.Add((Id=3627, Weapondef=class'KFWeapDef_Bullpup', MIC_1P=("WEP_SkinSet03_MAT.horzineelitegreen_l85a2.HorzineEliteGreen_L85A2_1P_FieldTested_MIC", "WEP_SkinSet03_MAT.horzineelitegreen_l85a2.HorzineEliteGreen_L85A2_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet03_MAT.horzineelitegreen_l85a2.HorzineEliteGreen_L85A2_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet03_MAT.horzineelitegreen_l85a2.HorzineEliteGreen_L85A2_3P_Pickup_MIC"))
	Skins.Add((Id=3626, Weapondef=class'KFWeapDef_Bullpup', MIC_1P=("WEP_SkinSet03_MAT.horzineelitegreen_l85a2.HorzineEliteGreen_L85A2_1P_BattleScarred_MIC", "WEP_SkinSet03_MAT.horzineelitegreen_l85a2.HorzineEliteGreen_L85A2_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet03_MAT.horzineelitegreen_l85a2.HorzineEliteGreen_L85A2_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet03_MAT.horzineelitegreen_l85a2.HorzineEliteGreen_L85A2_3P_Pickup_MIC"))

//CyberBone Katana
	Skins.Add((Id=3070, Weapondef=class'KFWeapDef_Katana', MIC_1P=("WEP_SkinSet01_MAT.cyberbone_katana.CyberBone_Katana_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_MAT.cyberbone_katana.CyberBone_Katana_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_MAT.cyberbone_katana.CyberBone_Katana_3P_Pickup_MIC"))
	Skins.Add((Id=3069, Weapondef=class'KFWeapDef_Katana', MIC_1P=("WEP_SkinSet01_MAT.cyberbone_katana.CyberBone_Katana_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet01_MAT.cyberbone_katana.CyberBone_Katana_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet01_MAT.cyberbone_katana.CyberBone_Katana_3P_Pickup_MIC"))
	Skins.Add((Id=3068, Weapondef=class'KFWeapDef_Katana', MIC_1P=("WEP_SkinSet01_MAT.cyberbone_katana.CyberBone_Katana_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet01_MAT.cyberbone_katana.CyberBone_Katana_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet01_MAT.cyberbone_katana.CyberBone_Katana_3P_Pickup_MIC"))

//CyberBone AA12
	Skins.Add((Id=3076, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet01_MAT.cyberbone_aa12.CyberBone_AA12_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_MAT.cyberbone_aa12.CyberBone_AA12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_MAT.cyberbone_aa12.CyberBone_AA12_3P_Pickup_MIC"))
	Skins.Add((Id=3075, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet01_MAT.cyberbone_aa12.CyberBone_AA12_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet01_MAT.cyberbone_aa12.CyberBone_AA12_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet01_MAT.cyberbone_aa12.CyberBone_AA12_3P_Pickup_MIC"))
	Skins.Add((Id=3074, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet01_MAT.cyberbone_aa12.CyberBone_AA12_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet01_MAT.cyberbone_aa12.CyberBone_AA12_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet01_MAT.cyberbone_aa12.CyberBone_AA12_3P_Pickup_MIC"))

//CyberBone AK12
	Skins.Add((Id=3073, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet01_MAT.cyberbone_ak12.CyberBone_AK12_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_MAT.cyberbone_ak12.CyberBone_AK12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_MAT.cyberbone_ak12.CyberBone_AK12_3P_Pickup_MIC"))
	Skins.Add((Id=3072, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet01_MAT.cyberbone_ak12.CyberBone_AK12_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet01_MAT.cyberbone_ak12.CyberBone_AK12_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet01_MAT.cyberbone_ak12.CyberBone_AK12_3P_Pickup_MIC"))
	Skins.Add((Id=3071, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet01_MAT.cyberbone_ak12.CyberBone_AK12_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet01_MAT.cyberbone_ak12.CyberBone_AK12_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet01_MAT.cyberbone_ak12.CyberBone_AK12_3P_Pickup_MIC"))

//CyberBone AR15
	Skins.Add((Id=3079, Weapondef=class'KFWeapDef_AR15', MIC_1P=("WEP_SkinSet01_MAT.cyberbone_ar15.CyberBone_AR15_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_MAT.cyberbone_ar15.CyberBone_AR15_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_MAT.cyberbone_ar15.CyberBone_AR15_3P_Pickup_MIC"))
	Skins.Add((Id=3078, Weapondef=class'KFWeapDef_AR15', MIC_1P=("WEP_SkinSet01_MAT.cyberbone_ar15.CyberBone_AR15_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet01_MAT.cyberbone_ar15.CyberBone_AR15_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet01_MAT.cyberbone_ar15.CyberBone_AR15_3P_Pickup_MIC"))
	Skins.Add((Id=3077, Weapondef=class'KFWeapDef_AR15', MIC_1P=("WEP_SkinSet01_MAT.cyberbone_ar15.CyberBone_AR15_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet01_MAT.cyberbone_ar15.CyberBone_AR15_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet01_MAT.cyberbone_ar15.CyberBone_AR15_3P_Pickup_MIC"))

//CyberBone Support Knife
	Skins.Add((Id=3344, Weapondef=class'KFWeapDef_Knife_Support', MIC_1P=("WEP_SkinSet01_MAT.cyberbone_supportknife.CyberBone_SupportKnife_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_MAT.cyberbone_supportknife.CyberBone_SupportKnife_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_MAT.cyberbone_supportknife.CyberBone_SupportKnife_3P_Pickup_MIC"))
	Skins.Add((Id=3343, Weapondef=class'KFWeapDef_Knife_Support', MIC_1P=("WEP_SkinSet01_MAT.cyberbone_supportknife.CyberBone_SupportKnife_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet01_MAT.cyberbone_supportknife.CyberBone_SupportKnife_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet01_MAT.cyberbone_supportknife.CyberBone_SupportKnife_3P_Pickup_MIC"))
	Skins.Add((Id=3342, Weapondef=class'KFWeapDef_Knife_Support', MIC_1P=("WEP_SkinSet01_MAT.cyberbone_supportknife.CyberBone_SupportKnife_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet01_MAT.cyberbone_supportknife.CyberBone_SupportKnife_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet01_MAT.cyberbone_supportknife.CyberBone_SupportKnife_3P_Pickup_MIC"))

//Stories of War AA12
	Skins.Add((Id=3094, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet01_MAT.storiesofwar_aa12.StoriesOfWar_AA12_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_MAT.storiesofwar_aa12.StoriesOfWar_AA12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_MAT.storiesofwar_aa12.StoriesOfWar_AA12_3P_Pickup_MIC"))
	Skins.Add((Id=3093, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet01_MAT.storiesofwar_aa12.StoriesOfWar_AA12_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet01_MAT.storiesofwar_aa12.StoriesOfWar_AA12_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet01_MAT.storiesofwar_aa12.StoriesOfWar_AA12_3P_Pickup_MIC"))
	Skins.Add((Id=3092, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet01_MAT.storiesofwar_aa12.StoriesOfWar_AA12_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet01_MAT.storiesofwar_aa12.StoriesOfWar_AA12_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet01_MAT.storiesofwar_aa12.StoriesOfWar_AA12_3P_Pickup_MIC"))

//Stories of War AK12
	Skins.Add((Id=3112, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet01_MAT.storiesofwar_ak12.StoriesOfWar_AK12_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_MAT.storiesofwar_ak12.StoriesOfWar_AK12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_MAT.storiesofwar_ak12.StoriesOfWar_AK12_3P_Pickup_MIC"))
	Skins.Add((Id=3111, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet01_MAT.storiesofwar_ak12.StoriesOfWar_AK12_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet01_MAT.storiesofwar_ak12.StoriesOfWar_AK12_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet01_MAT.storiesofwar_ak12.StoriesOfWar_AK12_3P_Pickup_MIC"))
	Skins.Add((Id=3110, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet01_MAT.storiesofwar_ak12.StoriesOfWar_AK12_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet01_MAT.storiesofwar_ak12.StoriesOfWar_AK12_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet01_MAT.storiesofwar_ak12.StoriesOfWar_AK12_3P_Pickup_MIC"))

//Stories of War Dragons Breath
	Skins.Add((Id=3088, Weapondef=class'KFWeapDef_DragonsBreath', MIC_1P=("WEP_SkinSet01_MAT.storiesofwar_dragonsbreath.StoriesOfWar_DragonsBreath_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_MAT.storiesofwar_dragonsbreath.StoriesOfWar_DragonsBreath_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_MAT.storiesofwar_dragonsbreath.StoriesOfWar_DragonsBreath_3P_Pickup_MIC"))
	Skins.Add((Id=3087, Weapondef=class'KFWeapDef_DragonsBreath', MIC_1P=("WEP_SkinSet01_MAT.storiesofwar_dragonsbreath.StoriesOfWar_DragonsBreath_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet01_MAT.storiesofwar_dragonsbreath.StoriesOfWar_DragonsBreath_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet01_MAT.storiesofwar_dragonsbreath.StoriesOfWar_DragonsBreath_3P_Pickup_MIC"))
	Skins.Add((Id=3086, Weapondef=class'KFWeapDef_DragonsBreath', MIC_1P=("WEP_SkinSet01_MAT.storiesofwar_dragonsbreath.StoriesOfWar_DragonsBreath_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet01_MAT.storiesofwar_dragonsbreath.StoriesOfWar_DragonsBreath_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet01_MAT.storiesofwar_dragonsbreath.StoriesOfWar_DragonsBreath_3P_Pickup_MIC"))

//Stories of War M4
	Skins.Add((Id=3082, Weapondef=class'KFWeapDef_M4', MIC_1P=("WEP_SkinSet01_MAT.storiesofwar_m4.StoriesOfWar_M4_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_MAT.storiesofwar_m4.StoriesOfWar_M4_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_MAT.storiesofwar_m4.StoriesOfWar_M4_3P_Pickup_MIC"))
	Skins.Add((Id=3081, Weapondef=class'KFWeapDef_M4', MIC_1P=("WEP_SkinSet01_MAT.storiesofwar_m4.StoriesOfWar_M4_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet01_MAT.storiesofwar_m4.StoriesOfWar_M4_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet01_MAT.storiesofwar_m4.StoriesOfWar_M4_3P_Pickup_MIC"))
	Skins.Add((Id=3080, Weapondef=class'KFWeapDef_M4', MIC_1P=("WEP_SkinSet01_MAT.storiesofwar_m4.StoriesOfWar_M4_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet01_MAT.storiesofwar_m4.StoriesOfWar_M4_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet01_MAT.storiesofwar_m4.StoriesOfWar_M4_3P_Pickup_MIC"))

//Stories of War M79
	Skins.Add((Id=3091, Weapondef=class'KFWeapDef_M79', MIC_1P=("WEP_SkinSet01_MAT.storiesofwar_m79.StoriesOfWar_M79_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_MAT.storiesofwar_m79.StoriesOfWar_M79_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_MAT.storiesofwar_m79.StoriesOfWar_M79_3P_Pickup_MIC"))
	Skins.Add((Id=3090, Weapondef=class'KFWeapDef_M79', MIC_1P=("WEP_SkinSet01_MAT.storiesofwar_m79.StoriesOfWar_M79_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet01_MAT.storiesofwar_m79.StoriesOfWar_M79_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet01_MAT.storiesofwar_m79.StoriesOfWar_M79_3P_Pickup_MIC"))
	Skins.Add((Id=3089, Weapondef=class'KFWeapDef_M79', MIC_1P=("WEP_SkinSet01_MAT.storiesofwar_m79.StoriesOfWar_M79_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet01_MAT.storiesofwar_m79.StoriesOfWar_M79_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet01_MAT.storiesofwar_m79.StoriesOfWar_M79_3P_Pickup_MIC"))

//Stories of War RPG7
	Skins.Add((Id=3097, Weapondef=class'KFWeapDef_RPG7', MIC_1P=("WEP_SkinSet01_MAT.storiesofwar_rpg7.StoriesOfWar_RPG7_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_MAT.storiesofwar_rpg7.StoriesOfWar_RPG7_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_MAT.storiesofwar_rpg7.StoriesOfWar_RPG7_3P_Pickup_MIC"))
	Skins.Add((Id=3096, Weapondef=class'KFWeapDef_RPG7', MIC_1P=("WEP_SkinSet01_MAT.storiesofwar_rpg7.StoriesOfWar_RPG7_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet01_MAT.storiesofwar_rpg7.StoriesOfWar_RPG7_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet01_MAT.storiesofwar_rpg7.StoriesOfWar_RPG7_3P_Pickup_MIC"))
	Skins.Add((Id=3095, Weapondef=class'KFWeapDef_RPG7', MIC_1P=("WEP_SkinSet01_MAT.storiesofwar_rpg7.StoriesOfWar_RPG7_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet01_MAT.storiesofwar_rpg7.StoriesOfWar_RPG7_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet01_MAT.storiesofwar_rpg7.StoriesOfWar_RPG7_3P_Pickup_MIC"))

//Stories of War SCAR
	Skins.Add((Id=3085, Weapondef=class'KFWeapDef_SCAR', MIC_1P=("WEP_SkinSet01_MAT.storiesofwar_scar.StoriesOfWar_SCAR_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_MAT.storiesofwar_scar.StoriesOfWar_SCAR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_MAT.storiesofwar_scar.StoriesOfWar_SCAR_3P_Pickup_MIC"))
	Skins.Add((Id=3084, Weapondef=class'KFWeapDef_SCAR', MIC_1P=("WEP_SkinSet01_MAT.storiesofwar_scar.StoriesOfWar_SCAR_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet01_MAT.storiesofwar_scar.StoriesOfWar_SCAR_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet01_MAT.storiesofwar_scar.StoriesOfWar_SCAR_3P_Pickup_MIC"))
	Skins.Add((Id=3083, Weapondef=class'KFWeapDef_SCAR', MIC_1P=("WEP_SkinSet01_MAT.storiesofwar_scar.StoriesOfWar_SCAR_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet01_MAT.storiesofwar_scar.StoriesOfWar_SCAR_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet01_MAT.storiesofwar_scar.StoriesOfWar_SCAR_3P_Pickup_MIC"))

//Dragonfire Caulk N Burn
	Skins.Add((Id=3100, Weapondef=class'KFWeapDef_CaulkBurn', MIC_1P=("WEP_SkinSet01_MAT.dragonfire_caulknburn.Dragonfire_CaulkNBurn_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_MAT.dragonfire_caulknburn.Dragonfire_CaulkNBurn_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_MAT.dragonfire_caulknburn.Dragonfire_CaulkNBurn_3P_Pickup_MIC"))
	Skins.Add((Id=3099, Weapondef=class'KFWeapDef_CaulkBurn', MIC_1P=("WEP_SkinSet01_MAT.dragonfire_caulknburn.Dragonfire_CaulkNBurn_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet01_MAT.dragonfire_caulknburn.Dragonfire_CaulkNBurn_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet01_MAT.dragonfire_caulknburn.Dragonfire_CaulkNBurn_3P_Pickup_MIC"))
	Skins.Add((Id=3098, Weapondef=class'KFWeapDef_CaulkBurn', MIC_1P=("WEP_SkinSet01_MAT.dragonfire_caulknburn.Dragonfire_CaulkNBurn_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet01_MAT.dragonfire_caulknburn.Dragonfire_CaulkNBurn_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet01_MAT.dragonfire_caulknburn.Dragonfire_CaulkNBurn_3P_Pickup_MIC"))

//Dragonfire Dragons Breath
	Skins.Add((Id=3106, Weapondef=class'KFWeapDef_DragonsBreath', MIC_1P=("WEP_SkinSet01_MAT.dragonfire_dragonsbreath.Dragonfire_DragonsBreath_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_MAT.dragonfire_dragonsbreath.Dragonfire_DragonsBreath_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_MAT.dragonfire_dragonsbreath.Dragonfire_DragonsBreath_3P_Pickup_MIC"))
	Skins.Add((Id=3105, Weapondef=class'KFWeapDef_DragonsBreath', MIC_1P=("WEP_SkinSet01_MAT.dragonfire_dragonsbreath.Dragonfire_DragonsBreath_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet01_MAT.dragonfire_dragonsbreath.Dragonfire_DragonsBreath_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet01_MAT.dragonfire_dragonsbreath.Dragonfire_DragonsBreath_3P_Pickup_MIC"))
	Skins.Add((Id=3104, Weapondef=class'KFWeapDef_DragonsBreath', MIC_1P=("WEP_SkinSet01_MAT.dragonfire_dragonsbreath.Dragonfire_DragonsBreath_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet01_MAT.dragonfire_dragonsbreath.Dragonfire_DragonsBreath_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet01_MAT.dragonfire_dragonsbreath.Dragonfire_DragonsBreath_3P_Pickup_MIC"))

//Dragonfire Firebug Knife
	Skins.Add((Id=3109, Weapondef=class'KFWeapDef_Knife_Firebug', MIC_1P=("WEP_SkinSet01_MAT.dragonfire_firebugknife.Dragonfire_FirebugKnife_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_MAT.dragonfire_firebugknife.Dragonfire_FirebugKnife_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_MAT.dragonfire_firebugknife.Dragonfire_FirebugKnife_3P_Pickup_MIC"))
	Skins.Add((Id=3108, Weapondef=class'KFWeapDef_Knife_Firebug', MIC_1P=("WEP_SkinSet01_MAT.dragonfire_firebugknife.Dragonfire_FirebugKnife_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet01_MAT.dragonfire_firebugknife.Dragonfire_FirebugKnife_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet01_MAT.dragonfire_firebugknife.Dragonfire_FirebugKnife_3P_Pickup_MIC"))
	Skins.Add((Id=3107, Weapondef=class'KFWeapDef_Knife_Firebug', MIC_1P=("WEP_SkinSet01_MAT.dragonfire_firebugknife.Dragonfire_FirebugKnife_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet01_MAT.dragonfire_firebugknife.Dragonfire_FirebugKnife_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet01_MAT.dragonfire_firebugknife.Dragonfire_FirebugKnife_3P_Pickup_MIC"))

//Dragonfire Flamethrower
	Skins.Add((Id=3103, Weapondef=class'KFWeapDef_FlameThrower', MIC_1P=("WEP_SkinSet01_MAT.dragonfire_flamethrower.Dragonfire_Flamethrower_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_MAT.dragonfire_flamethrower.Dragonfire_Flamethrower_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_MAT.dragonfire_flamethrower.Dragonfire_Flamethrower_3P_Pickup_MIC"))
	Skins.Add((Id=3102, Weapondef=class'KFWeapDef_FlameThrower', MIC_1P=("WEP_SkinSet01_MAT.dragonfire_flamethrower.Dragonfire_Flamethrower_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet01_MAT.dragonfire_flamethrower.Dragonfire_Flamethrower_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet01_MAT.dragonfire_flamethrower.Dragonfire_Flamethrower_3P_Pickup_MIC"))
	Skins.Add((Id=3101, Weapondef=class'KFWeapDef_FlameThrower', MIC_1P=("WEP_SkinSet01_MAT.dragonfire_flamethrower.Dragonfire_Flamethrower_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet01_MAT.dragonfire_flamethrower.Dragonfire_Flamethrower_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet01_MAT.dragonfire_flamethrower.Dragonfire_Flamethrower_3P_Pickup_MIC"))

//The Peacemaker M79
	Skins.Add((Id=3324, Weapondef=class'KFWeapDef_M79', MIC_1P=("WEP_SkinSet01_MAT.thepeacemaker_m79.ThePeacemaker_M79_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_MAT.thepeacemaker_m79.ThePeacemaker_M79_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_MAT.thepeacemaker_m79.ThePeacemaker_M79_3P_Pickup_MIC"))
	Skins.Add((Id=3323, Weapondef=class'KFWeapDef_M79', MIC_1P=("WEP_SkinSet01_MAT.thepeacemaker_m79.ThePeacemaker_M79_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet01_MAT.thepeacemaker_m79.ThePeacemaker_M79_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet01_MAT.thepeacemaker_m79.ThePeacemaker_M79_3P_Pickup_MIC"))
	Skins.Add((Id=3322, Weapondef=class'KFWeapDef_M79', MIC_1P=("WEP_SkinSet01_MAT.thepeacemaker_m79.ThePeacemaker_M79_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet01_MAT.thepeacemaker_m79.ThePeacemaker_M79_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet01_MAT.thepeacemaker_m79.ThePeacemaker_M79_3P_Pickup_MIC"))

//Rusted Death MB500
	Skins.Add((Id=3067, Weapondef=class'KFWeapDef_MB500', MIC_1P=("WEP_SkinSetPSN01_MAT.rusteddeath_mb500.RustedDeath_MB500_1P_Mint_MIC"), MIC_3P="WEP_SkinSetPSN01_MAT.rusteddeath_mb500.RustedDeath_MB500_3P_Mint_MIC", MIC_Pickup="WEP_SkinSetPSN01_MAT.rusteddeath_mb500.RustedDeath_MB500_3P_Pickup_MIC"))
	Skins.Add((Id=3066, Weapondef=class'KFWeapDef_MB500', MIC_1P=("WEP_SkinSetPSN01_MAT.rusteddeath_mb500.RustedDeath_MB500_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSetPSN01_MAT.rusteddeath_mb500.RustedDeath_MB500_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSetPSN01_MAT.rusteddeath_mb500.RustedDeath_MB500_3P_Pickup_MIC"))
	Skins.Add((Id=3065, Weapondef=class'KFWeapDef_MB500', MIC_1P=("WEP_SkinSetPSN01_MAT.rusteddeath_mb500.RustedDeath_MB500_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSetPSN01_MAT.rusteddeath_mb500.RustedDeath_MB500_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSetPSN01_MAT.rusteddeath_mb500.RustedDeath_MB500_3P_Pickup_MIC"))

//Stories of War AR15
	Skins.Add((Id=3347, Weapondef=class'KFWeapDef_AR15', MIC_1P=("WEP_SkinSet01_MAT.storiesofwar_ar15.StoriesOfWar_AR15_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_MAT.storiesofwar_ar15.StoriesOfWar_AR15_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_MAT.storiesofwar_ar15.StoriesOfWar_AR15_3P_Pickup_MIC"))
	Skins.Add((Id=3346, Weapondef=class'KFWeapDef_AR15', MIC_1P=("WEP_SkinSet01_MAT.storiesofwar_ar15.StoriesOfWar_AR15_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet01_MAT.storiesofwar_ar15.StoriesOfWar_AR15_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet01_MAT.storiesofwar_ar15.StoriesOfWar_AR15_3P_Pickup_MIC"))
	Skins.Add((Id=3345, Weapondef=class'KFWeapDef_AR15', MIC_1P=("WEP_SkinSet01_MAT.storiesofwar_ar15.StoriesOfWar_AR15_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet01_MAT.storiesofwar_ar15.StoriesOfWar_AR15_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet01_MAT.storiesofwar_ar15.StoriesOfWar_AR15_3P_Pickup_MIC"))

//Conatainment AR15
	Skins.Add((Id=3269, Weapondef=class'KFWeapDef_AR15', MIC_1P=("WEP_SkinSet01_MAT.containment_ar15.Containment_AR15_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_MAT.containment_ar15.Containment_AR15_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_MAT.containment_ar15.Containment_AR15_3P_Pickup_MIC"))
	Skins.Add((Id=3268, Weapondef=class'KFWeapDef_AR15', MIC_1P=("WEP_SkinSet01_MAT.containment_ar15.Containment_AR15_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet01_MAT.containment_ar15.Containment_AR15_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet01_MAT.containment_ar15.Containment_AR15_3P_Pickup_MIC"))
	Skins.Add((Id=3267, Weapondef=class'KFWeapDef_AR15', MIC_1P=("WEP_SkinSet01_MAT.containment_ar15.Containment_AR15_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet01_MAT.containment_ar15.Containment_AR15_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet01_MAT.containment_ar15.Containment_AR15_3P_Pickup_MIC"))

//Putrid Bile M79
	Skins.Add((Id=3272, Weapondef=class'KFWeapDef_M79', MIC_1P=("WEP_SkinSet01_MAT.putridbile_m79.PutridBile_M79_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_MAT.putridbile_m79.PutridBile_M79_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_MAT.putridbile_m79.PutridBile_M79_3P_Pickup_MIC"))
	Skins.Add((Id=3271, Weapondef=class'KFWeapDef_M79', MIC_1P=("WEP_SkinSet01_MAT.putridbile_m79.PutridBile_M79_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet01_MAT.putridbile_m79.PutridBile_M79_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet01_MAT.putridbile_m79.PutridBile_M79_3P_Pickup_MIC"))
	Skins.Add((Id=3270, Weapondef=class'KFWeapDef_M79', MIC_1P=("WEP_SkinSet01_MAT.putridbile_m79.PutridBile_M79_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet01_MAT.putridbile_m79.PutridBile_M79_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet01_MAT.putridbile_m79.PutridBile_M79_3P_Pickup_MIC"))

//Heat Dragons Breath
	Skins.Add((Id=3296, Weapondef=class'KFWeapDef_DragonsBreath', MIC_1P=("WEP_SkinSet01_MAT.heat_dragonsbreath.Heat_DragonsBreath_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_MAT.heat_dragonsbreath.Heat_DragonsBreath_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_MAT.heat_dragonsbreath.Heat_DragonsBreath_3P_Pickup_MIC"))
	Skins.Add((Id=3295, Weapondef=class'KFWeapDef_DragonsBreath', MIC_1P=("WEP_SkinSet01_MAT.heat_dragonsbreath.Heat_DragonsBreath_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet01_MAT.heat_dragonsbreath.Heat_DragonsBreath_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet01_MAT.heat_dragonsbreath.Heat_DragonsBreath_3P_Pickup_MIC"))
	Skins.Add((Id=3294, Weapondef=class'KFWeapDef_DragonsBreath', MIC_1P=("WEP_SkinSet01_MAT.heat_dragonsbreath.Heat_DragonsBreath_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet01_MAT.heat_dragonsbreath.Heat_DragonsBreath_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet01_MAT.heat_dragonsbreath.Heat_DragonsBreath_3P_Pickup_MIC"))

//Heat Double Barrel
	Skins.Add((Id=3299, Weapondef=class'KFWeapDef_DoubleBarrel', MIC_1P=("WEP_SkinSet01_MAT.heat_doublebarrel.Heat_DoubleBarrel_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_MAT.heat_doublebarrel.Heat_DoubleBarrel_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_MAT.heat_doublebarrel.Heat_DoubleBarrel_3P_Pickup_MIC"))
	Skins.Add((Id=3298, Weapondef=class'KFWeapDef_DoubleBarrel', MIC_1P=("WEP_SkinSet01_MAT.heat_doublebarrel.Heat_DoubleBarrel_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet01_MAT.heat_doublebarrel.Heat_DoubleBarrel_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet01_MAT.heat_doublebarrel.Heat_DoubleBarrel_3P_Pickup_MIC"))
	Skins.Add((Id=3297, Weapondef=class'KFWeapDef_DoubleBarrel', MIC_1P=("WEP_SkinSet01_MAT.heat_doublebarrel.Heat_DoubleBarrel_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet01_MAT.heat_doublebarrel.Heat_DoubleBarrel_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet01_MAT.heat_doublebarrel.Heat_DoubleBarrel_3P_Pickup_MIC"))

//Precious AR15
	Skins.Add((Id=3289, Weapondef=class'KFWeapDef_AR15', MIC_1P=("WEP_SkinSet01_P01_MAT.precious_ar15.Precious_AR15_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_P01_MAT.precious_ar15.Precious_AR15_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_P01_MAT.precious_ar15.Precious_AR15_3P_Pickup_MIC"))

//Precious Caulk N Burn
	Skins.Add((Id=3290, Weapondef=class'KFWeapDef_CaulkBurn', MIC_1P=("WEP_SkinSet01_P01_MAT.precious_caulknburn.Precious_CaulkNBurn_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_P01_MAT.precious_caulknburn.Precious_CaulkNBurn_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_P01_MAT.precious_caulknburn.Precious_CaulkNBurn_3P_Pickup_MIC"))

//Precious Crovel
	Skins.Add((Id=3291, Weapondef=class'KFWeapDef_Crovel', MIC_1P=("WEP_SkinSet01_P01_MAT.precious_crovel.Precious_Crovel_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_P01_MAT.precious_crovel.Precious_Crovel_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_P01_MAT.precious_crovel.Precious_Crovel_3P_Pickup_MIC"))

//Precious HX25
	Skins.Add((Id=3292, Weapondef=class'KFWeapDef_HX25', MIC_1P=("WEP_SkinSet01_P01_MAT.precious_hx25.Precious_HX25_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_P01_MAT.precious_hx25.Precious_HX25_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_P01_MAT.precious_hx25.Precious_HX25_3P_Pickup_MIC"))

//Precious MB500
	Skins.Add((Id=3293, Weapondef=class'KFWeapDef_MB500', MIC_1P=("WEP_SkinSet01_P01_MAT.precious_mb500.Precious_MB500_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_P01_MAT.precious_mb500.Precious_MB500_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_P01_MAT.precious_mb500.Precious_MB500_3P_Pickup_MIC"))

//Precious Medic Pistol
	Skins.Add((Id=3335, Weapondef=class'KFWeapDef_MedicPistol', MIC_1P=("WEP_SkinSet01_P01_MAT.precious_medicpistol.Precious_MedicPistol_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_P01_MAT.precious_medicpistol.Precious_MedicPistol_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_P01_MAT.precious_medicpistol.Precious_MedicPistol_3P_Pickup_MIC"))

//Precious Remington 1858
	Skins.Add((Id=3303, Weapondef=class'KFWeapDef_Remington1858', MIC_1P=("WEP_SkinSet01_P01_MAT.precious_remington1858.Precious_Remington_1858_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_P01_MAT.precious_remington1858.Precious_Remington_1858_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_P01_MAT.precious_remington1858.Precious_Remington_1858_3P_Pickup_MIC"))

//Precious 9mm
	Skins.Add((Id=3422, Weapondef=class'KFWeapDef_9mm', MIC_1P=("WEP_SkinSet01_P01_MAT.precious_9mm.Precious_9MM_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_P01_MAT.precious_9mm.Precious_9MM_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_P01_MAT.precious_9mm.Precious_9MM_3P_Pickup_MIC"))

//Precious Double Barrel
	Skins.Add((Id=3423, Weapondef=class'KFWeapDef_DoubleBarrel', MIC_1P=("WEP_SkinSet01_P01_MAT.precious_doublebarrel.Precious_DoubleBarrel_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_P01_MAT.precious_doublebarrel.Precious_DoubleBarrel_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_P01_MAT.precious_doublebarrel.Precious_DoubleBarrel_3P_Pickup_MIC"))

//Precious M4
	Skins.Add((Id=3424, Weapondef=class'KFWeapDef_M4', MIC_1P=("WEP_SkinSet01_P01_MAT.precious_m4shotgun.Precious_M4Shotgun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_P01_MAT.precious_m4shotgun.Precious_M4Shotgun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_P01_MAT.precious_m4shotgun.Precious_M4Shotgun_3P_Pickup_MIC"))

//Precious AA12
	Skins.Add((Id=3425, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet01_P01_MAT.precious_aa12.Precious_AA12_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_P01_MAT.precious_aa12.Precious_AA12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_P01_MAT.precious_aa12.Precious_AA12_3P_Pickup_MIC"))

//Precious Support Knife
	Skins.Add((Id=3426, Weapondef=class'KFWeapDef_Knife_Support', MIC_1P=("WEP_SkinSet01_P01_MAT.precious_supportknife.Precious_SupportKnife_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_P01_MAT.precious_supportknife.Precious_SupportKnife_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_P01_MAT.precious_supportknife.Precious_SupportKnife_3P_Pickup_MIC"))

//Precious L85A2
	Skins.Add((Id=3427, Weapondef=class'KFWeapDef_Bullpup', MIC_1P=("WEP_SkinSet01_P01_MAT.precious_l85a2.Precious_L85A2_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_P01_MAT.precious_l85a2.Precious_L85A2_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_P01_MAT.precious_l85a2.Precious_L85A2_3P_Pickup_MIC"))

//Precious SCAR
	Skins.Add((Id=3428, Weapondef=class'KFWeapDef_SCAR', MIC_1P=("WEP_SkinSet01_P01_MAT.precious_scar.Precious_SCAR_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_P01_MAT.precious_scar.Precious_SCAR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_P01_MAT.precious_scar.Precious_SCAR_3P_Pickup_MIC"))

//Precious Nail Gun
	Skins.Add((Id=3429, Weapondef=class'KFWeapDef_NailGun', MIC_1P=("WEP_SkinSet01_P01_MAT.precious_nailgun.Precious_NailGun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_P01_MAT.precious_nailgun.Precious_NailGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_P01_MAT.precious_nailgun.Precious_NailGun_3P_Pickup_MIC"))

//Precious Pulverizer
	Skins.Add((Id=3430, Weapondef=class'KFWeapDef_Pulverizer', MIC_1P=("WEP_SkinSet01_P01_MAT.precious_pulverizer.Precious_Pulverizer_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_P01_MAT.precious_pulverizer.Precious_Pulverizer_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_P01_MAT.precious_pulverizer.Precious_Pulverizer_3P_Pickup_MIC"))

//Precious Sawblade
	Skins.Add((Id=3431, Weapondef=class'KFWeapDef_Eviscerator', MIC_1P=("WEP_SkinSet01_P01_MAT.precious_sawblade.Precious_SawBlade_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_P01_MAT.precious_sawblade.Precious_SawBlade_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_P01_MAT.precious_sawblade.Precious_SawBlade_3P_Pickup_MIC"))

//Precious M79
	Skins.Add((Id=3432, Weapondef=class'KFWeapDef_M79', MIC_1P=("WEP_SkinSet01_P01_MAT.precious_m79.Precious_M79_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_P01_MAT.precious_m79.Precious_M79_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_P01_MAT.precious_m79.Precious_M79_3P_Pickup_MIC"))

//Precious RPG7
	Skins.Add((Id=3433, Weapondef=class'KFWeapDef_RPG7', MIC_1P=("WEP_SkinSet01_P01_MAT.precious_rpg7.Precious_RPG7_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_P01_MAT.precious_rpg7.Precious_RPG7_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_P01_MAT.precious_rpg7.Precious_RPG7_3P_Pickup_MIC"))

//Precious Flamethrower
	Skins.Add((Id=3434, Weapondef=class'KFWeapDef_FlameThrower', MIC_1P=("WEP_SkinSet01_P01_MAT.precious_flamethrower.Precious_Flamethrower_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_P01_MAT.precious_flamethrower.Precious_Flamethrower_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_P01_MAT.precious_flamethrower.Precious_Flamethrower_3P_Pickup_MIC"))

//Precious Microwave Gun
	Skins.Add((Id=3435, Weapondef=class'KFWeapDef_MicrowaveGun', MIC_1P=("WEP_SkinSet01_P01_MAT.precious_microwavegun.Precious_MicrowaveGun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_P01_MAT.precious_microwavegun.Precious_MicrowaveGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_P01_MAT.precious_microwavegun.Precious_MicrowaveGun_3P_Pickup_MIC"))

//Precious Dragons Breath
	Skins.Add((Id=3436, Weapondef=class'KFWeapDef_DragonsBreath', MIC_1P=("WEP_SkinSet01_P01_MAT.precious_dragonsbreath.Precious_DragonsBreath_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_P01_MAT.precious_dragonsbreath.Precious_DragonsBreath_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_P01_MAT.precious_dragonsbreath.Precious_DragonsBreath_3P_Pickup_MIC"))

//Precious Desert Eagle
	Skins.Add((Id=3437, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet01_P01_MAT.precious_deagle.Precious_Deagle_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_P01_MAT.precious_deagle.Precious_Deagle_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_P01_MAT.precious_deagle.Precious_Deagle_3P_Pickup_MIC"))

//Precious M1911
	Skins.Add((Id=3438, Weapondef=class'KFWeapDef_Colt1911', MIC_1P=("WEP_SkinSet01_P01_MAT.precious_m1911.Precious_M1911_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_P01_MAT.precious_m1911.Precious_M1911_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_P01_MAT.precious_m1911.Precious_M1911_3P_Pickup_MIC"))

//Precious SW500
	Skins.Add((Id=3439, Weapondef=class'KFWeapDef_SW500', MIC_1P=("WEP_SkinSet01_P01_MAT.precious_sw500.Precious_SW500_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_P01_MAT.precious_sw500.Precious_SW500_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_P01_MAT.precious_sw500.Precious_SW500_3P_Pickup_MIC"))

//Precious Demo Knife
	Skins.Add((Id=3440, Weapondef=class'KFWeapDef_Knife_Demo', MIC_1P=("WEP_SkinSet01_P01_MAT.precious_demoknife.Precious_DemoKnife_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_P01_MAT.precious_demoknife.Precious_DemoKnife_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_P01_MAT.precious_demoknife.Precious_DemoKnife_3P_Pickup_MIC"))

//Precious Firebug Knife
	Skins.Add((Id=3441, Weapondef=class'KFWeapDef_Knife_Firebug', MIC_1P=("WEP_SkinSet01_P01_MAT.precious_firebugknife.Precious_FirebugKnife_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_P01_MAT.precious_firebugknife.Precious_FirebugKnife_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_P01_MAT.precious_firebugknife.Precious_FirebugKnife_3P_Pickup_MIC"))

//Precious Medic SMG
	Skins.Add((Id=3448, Weapondef=class'KFWeapDef_MedicSMG', MIC_1P=("WEP_SkinSet01_P01_MAT.precious_medicpistol.Precious_MedicPistol_1P_Mint_MIC", "WEP_SkinSet01_P01_MAT.precious_medicsmg.Precious_MedicSMG_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_P01_MAT.precious_medicsmg.Precious_MedicSMG_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_P01_MAT.precious_medicsmg.Precious_MedicSMG_3P_Pickup_MIC"))

//Precious Medic Knife
	Skins.Add((Id=3449, Weapondef=class'KFWeapDef_Knife_Medic', MIC_1P=("WEP_SkinSet01_P01_MAT.precious_medicknife.Precious_MedicKnife_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_P01_MAT.precious_medicknife.Precious_MedicKnife_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_P01_MAT.precious_medicknife.Precious_MedicKnife_3P_Pickup_MIC"))

//Precious Medic Shotgun
	Skins.Add((Id=3450, Weapondef=class'KFWeapDef_MedicShotgun', MIC_1P=("WEP_SkinSet01_P01_MAT.precious_medicpistol.Precious_MedicPistol_1P_Mint_MIC", "WEP_SkinSet01_P01_MAT.precious_medicshotgun.Precious_MedicShotgun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_P01_MAT.precious_medicshotgun.Precious_MedicShotgun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_P01_MAT.precious_medicshotgun.Precious_MedicShotgun_3P_Pickup_MIC"))

//Precious AK12
	Skins.Add((Id=3459, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet01_P01_MAT.precious_ak12.Precious_AK12_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_P01_MAT.precious_ak12.Precious_AK12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_P01_MAT.precious_ak12.Precious_AK12_3P_Pickup_MIC"))

//Precious Commando Knife
	Skins.Add((Id=3460, Weapondef=class'KFWeapDef_Knife_Commando', MIC_1P=("WEP_SkinSet01_P01_MAT.precious_commandoknife.Precious_CommandoKnife_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_P01_MAT.precious_commandoknife.Precious_CommandoKnife_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_P01_MAT.precious_commandoknife.Precious_CommandoKnife_3P_Pickup_MIC"))

//Precious Gunslinger Knife
	Skins.Add((Id=3461, Weapondef=class'KFWeapDef_Knife_Gunslinger', MIC_1P=("WEP_SkinSet01_P01_MAT.precious_gunslingerknife.Precious_GunslingerKnife_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_P01_MAT.precious_gunslingerknife.Precious_GunslingerKnife_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_P01_MAT.precious_gunslingerknife.Precious_GunslingerKnife_3P_Pickup_MIC"))

//Precious Berserker Knife
	Skins.Add((Id=3462, Weapondef=class'KFWeapDef_Knife_Berserker', MIC_1P=("WEP_SkinSet01_P01_MAT.precious_berserkerknife.Precious_BerserkerKnife_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_P01_MAT.precious_berserkerknife.Precious_BerserkerKnife_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_P01_MAT.precious_berserkerknife.Precious_BerserkerKnife_3P_Pickup_MIC"))

//Precious C4
	Skins.Add((Id=3463, Weapondef=class'KFWeapDef_C4', MIC_1P=("WEP_SkinSet01_P01_MAT.precious_c4.Precious_C4_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_P01_MAT.precious_c4.Precious_C4_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_P01_MAT.precious_c4.Precious_C4_3P_Pickup_MIC"))

//Precious Medic Assault
	Skins.Add((Id=3467, Weapondef=class'KFWeapDef_MedicRifle', MIC_1P=("WEP_SkinSet01_P01_MAT.precious_medicassault.Precious_MedicAssault_1P_Mint_MIC", "WEP_SkinSet01_P01_MAT.precious_medicpistol.Precious_MedicPistol_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_P01_MAT.precious_medicassault.Precious_MedicAssault_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_P01_MAT.precious_medicassault.Precious_MedicAssault_3P_Pickup_MIC"))

//Precious Healer
	Skins.Add((Id=3451, Weapondef=class'KFWeapDef_Healer', MIC_1P=("WEP_SkinSet01_P01_MAT.precious_healer.Precious_Healer_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_P01_MAT.precious_healer.Precious_Healer_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_P01_MAT.precious_healer.Precious_Healer_3P_Pickup_MIC"))

//Precious Welder
	Skins.Add((Id=3452, Weapondef=class'KFWeapDef_Welder', MIC_1P=("WEP_SkinSet01_P01_MAT.precious_welder.Precious_Welder_1P_Mint_MIC"), MIC_3P="WEP_SkinSet01_P01_MAT.precious_welder.Precious_Welder_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet01_P01_MAT.precious_welder.Precious_Welder_3P_Pickup_MIC"))

//Precious Mace and Shield
	Skins.Add((Id=4560, Weapondef=class'KFWeapDef_MaceAndShield', MIC_1P=("WEP_SkinSet08_MAT.precious_maceshield.Precious_Mace_1P_Mint_MIC", "WEP_SkinSet08_MAT.precious_maceshield.Precious_Shield_1P_Mint_MIC"), MIC_3P="WEP_SkinSet08_MAT.precious_maceshield.Precious_MaceShield_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet08_MAT.precious_maceshield.Precious_MaceShield_3P_Pickup_MIC"))

//Precious Kriss
	Skins.Add((Id=4595, Weapondef=class'KFWeapDef_Kriss', MIC_1P=("WEP_SkinSet09_MAT.precious_kriss.Precious_Kriss_1P_Mint_MIC", "WEP_SkinSet09_MAT.precious_kriss.Precious_Kriss_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet09_MAT.precious_kriss.Precious_Kriss_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet09_MAT.precious_kriss.Precious_Kriss_3P_Pickup_MIC"))

//Precious Crossbow
	Skins.Add((Id=4596, Weapondef=class'KFWeapDef_Crossbow', MIC_1P=("WEP_SkinSet09_MAT.precious_crossbow.Precious_Crossbow_1P_Mint_MIC"), MIC_3P="WEP_SkinSet09_MAT.precious_crossbow.Precious_Crossbow_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet09_MAT.precious_crossbow.Precious_Crossbow_3P_Pickup_MIC"))

//Precious Winchester 1894
	Skins.Add((Id=4597, Weapondef=class'KFWeapDef_Winchester1894', MIC_1P=("WEP_SkinSet09_MAT.precious_lar.Precious_LAR_1P_Mint_MIC"), MIC_3P="WEP_SkinSet09_MAT.precious_lar.Precious_LAR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet09_MAT.precious_lar.Precious_LAR_3P_Pickup_MIC"))

//Precious MP5RAS
	Skins.Add((Id=4787, Weapondef=class'KFWeapDef_MP5RAS', MIC_1P=("WEP_SkinSet10_MAT.precious_mp5ras.Precious_MP5RAS_1P_Mint_MIC"), MIC_3P="WEP_SkinSet10_MAT.precious_mp5ras.Precious_MP5RAS_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet10_MAT.precious_mp5ras.Precious_MP5RAS_3P_Pickup_MIC"))

//Precious MP7
	Skins.Add((Id=4788, Weapondef=class'KFWeapDef_MP7', MIC_1P=("WEP_SkinSet10_MAT.precious_mp7.Precious_MP7_1P_Mint_MIC"), MIC_3P="WEP_SkinSet10_MAT.precious_mp7.Precious_MP7_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet10_MAT.precious_mp7.Precious_MP7_3P_Pickup_MIC"))

//Precious P90
	Skins.Add((Id=4789, Weapondef=class'KFWeapDef_P90', MIC_1P=("WEP_SkinSet10_MAT.precious_p90.Precious_P90_1P_Mint_MIC"), MIC_3P="WEP_SkinSet10_MAT.precious_p90.Precious_P90_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet10_MAT.precious_p90.Precious_P90_3P_Pickup_MIC"))

//Precious M14EBR
	Skins.Add((Id=4793, Weapondef=class'KFWeapDef_M14EBR', MIC_1P=("WEP_SkinSet10_MAT.precious_m14ebr.Precious_M14EBR_1P_Mint_MIC"), MIC_3P="WEP_SkinSet10_MAT.precious_m14ebr.Precious_M14EBR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet10_MAT.precious_m14ebr.Precious_M14EBR_3P_Pickup_MIC"))

//Precious Railgun
	Skins.Add((Id=4794, Weapondef=class'KFWeapDef_RailGun', MIC_1P=("WEP_SkinSet10_MAT.precious_railgun.Precious_RailGun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet10_MAT.precious_railgun.Precious_RailGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet10_MAT.precious_railgun.Precious_RailGun_3P_Pickup_MIC"))

//Precious FlareGun
	Skins.Add((Id=4803, Weapondef=class'KFWeapDef_FlareGun', MIC_1P=("WEP_SkinSet11_MAT.precious_flaregun.Precious_FlareGun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet11_MAT.precious_flaregun.Precious_FlareGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet11_MAT.precious_flaregun.Precious_FlareGun_3P_Pickup_MIC"))

//Precious M16 M203
	Skins.Add((Id=4984, Weapondef=class'KFWeapDef_M16M203', MIC_1P=("WEP_SkinSet12_MAT.precious_m16m203.Precious_M16_1P_Mint_MIC", "WEP_SkinSet12_MAT.precious_m16m203.Precious_M203_1P_Mint_MIC"), MIC_3P="WEP_SkinSet12_MAT.precious_m16m203.Precious_M16M203_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet12_MAT.precious_m16m203.Precious_M16M203_3P_Pickup_MIC"))

//Precious Katana
	Skins.Add((Id=5054, Weapondef=class'KFWeapDef_Katana', MIC_1P=("WEP_SkinSet15_MAT.precious_katana.Precious_Katana_1P_Mint_MIC"), MIC_3P="WEP_SkinSet15_MAT.precious_katana.Precious_Katana_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet15_MAT.precious_katana.Precious_Katana_3P_Pickup_MIC"))

//Precious HZ12
	Skins.Add((Id=5140, Weapondef=class'KFWeapDef_HZ12', MIC_1P=("WEP_SkinSet14_MAT.precious_hz12.Precious_HZ12_1P_Mint_MIC"), MIC_3P="WEP_SkinSet14_MAT.precious_hz12.Precious_HZ12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet14_MAT.precious_hz12.Precious_HZ12_3P_Pickup_MIC"))

//Precious Stoner 63A
	Skins.Add((Id=5141, Weapondef=class'KFWeapDef_Stoner63A', MIC_1P=("WEP_SkinSet14_MAT.precious_stoner63a.Precious_Stoner63A_1P_Mint_MIC", "WEP_SkinSet14_MAT.precious_stoner63a.Precious_Stoner63A_Receiver_1P_Mint_MIC"), MIC_3P="WEP_SkinSet14_MAT.precious_stoner63a.Precious_Stoner63a_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet14_MAT.precious_stoner63a.Precious_Stoner63a_3P_Pickup_MIC"))

//Precious Freeze Thrower
	Skins.Add((Id=5377, Weapondef=class'KFWeapDef_FreezeThrower', MIC_1P=("WEP_SkinSet_CryoGun_MAT.Precious_CryoGun_1P_ID1_Mint_MIC", "WEP_SkinSet_CryoGun_MAT.Precious_CryoGun_1P_ID2_Mint_MIC"), MIC_3P="WEP_SkinSet_CryoGun_MAT.Precious_CryoGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_CryoGun_MAT.Precious_CryoGun_3P_Pickup_MIC"))

//Blood Camo Remington 1858
	Skins.Add((Id=3306, Weapondef=class'KFWeapDef_Remington1858', MIC_1P=("WEP_SkinSet02_MAT.bloodcamo_remington1858.BloodCamo_Remington1858_1P_Mint_MIC"), MIC_3P="WEP_SkinSet02_MAT.bloodcamo_remington1858.BloodCamo_Remington1858_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet02_MAT.bloodcamo_remington1858.BloodCamo_Remington1858_3P_Pickup_MIC"))
	Skins.Add((Id=3305, Weapondef=class'KFWeapDef_Remington1858', MIC_1P=("WEP_SkinSet02_MAT.bloodcamo_remington1858.BloodCamo_Remington1858_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet02_MAT.bloodcamo_remington1858.BloodCamo_Remington1858_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet02_MAT.bloodcamo_remington1858.BloodCamo_Remington1858_3P_Pickup_MIC"))
	Skins.Add((Id=3304, Weapondef=class'KFWeapDef_Remington1858', MIC_1P=("WEP_SkinSet02_MAT.bloodcamo_remington1858.BloodCamo_Remington1858_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet02_MAT.bloodcamo_remington1858.BloodCamo_Remington1858_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet02_MAT.bloodcamo_remington1858.BloodCamo_Remington1858_3P_Pickup_MIC"))

//Constitution Remington 1858
	Skins.Add((Id=3309, Weapondef=class'KFWeapDef_Remington1858', MIC_1P=("WEP_SkinSet02_MAT.constitution_remington1858.Constitution_Remington1858_1P_Mint_MIC"), MIC_3P="WEP_SkinSet02_MAT.constitution_remington1858.Constitution_Remington1858_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet02_MAT.constitution_remington1858.Constitution_Remington1858_3P_Pickup_MIC"))
	Skins.Add((Id=3308, Weapondef=class'KFWeapDef_Remington1858', MIC_1P=("WEP_SkinSet02_MAT.constitution_remington1858.Constitution_Remington1858_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet02_MAT.constitution_remington1858.Constitution_Remington1858_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet02_MAT.constitution_remington1858.Constitution_Remington1858_3P_Pickup_MIC"))
	Skins.Add((Id=3307, Weapondef=class'KFWeapDef_Remington1858', MIC_1P=("WEP_SkinSet02_MAT.constitution_remington1858.Constitution_Remington1858_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet02_MAT.constitution_remington1858.Constitution_Remington1858_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet02_MAT.constitution_remington1858.Constitution_Remington1858_3P_Pickup_MIC"))

//Dosh MB500
	Skins.Add((Id=3312, Weapondef=class'KFWeapDef_MB500', MIC_1P=("WEP_SkinSet02_MAT.dosh_mb500.Dosh_MB500_1P_Mint_MIC"), MIC_3P="WEP_SkinSet02_MAT.dosh_mb500.Dosh_MB500_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet02_MAT.dosh_mb500.Dosh_MB500_3P_Pickup_MIC"))
	Skins.Add((Id=3311, Weapondef=class'KFWeapDef_MB500', MIC_1P=("WEP_SkinSet02_MAT.dosh_mb500.Dosh_MB500_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet02_MAT.dosh_mb500.Dosh_MB500_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet02_MAT.dosh_mb500.Dosh_MB500_3P_Pickup_MIC"))
	Skins.Add((Id=3310, Weapondef=class'KFWeapDef_MB500', MIC_1P=("WEP_SkinSet02_MAT.dosh_mb500.Dosh_MB500_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet02_MAT.dosh_mb500.Dosh_MB500_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet02_MAT.dosh_mb500.Dosh_MB500_3P_Pickup_MIC"))

//Dosh L85A2
	Skins.Add((Id=3315, Weapondef=class'KFWeapDef_Bullpup', MIC_1P=("WEP_SkinSet02_MAT.dosh_l85a2.Dosh_L85A2_1P_Mint_MIC"), MIC_3P="WEP_SkinSet02_MAT.dosh_l85a2.Dosh_L85A2_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet02_MAT.dosh_l85a2.Dosh_L85A2_3P_Pickup_MIC"))
	Skins.Add((Id=3314, Weapondef=class'KFWeapDef_Bullpup', MIC_1P=("WEP_SkinSet02_MAT.dosh_l85a2.Dosh_L85A2_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet02_MAT.dosh_l85a2.Dosh_L85A2_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet02_MAT.dosh_l85a2.Dosh_L85A2_3P_Pickup_MIC"))
	Skins.Add((Id=3313, Weapondef=class'KFWeapDef_Bullpup', MIC_1P=("WEP_SkinSet02_MAT.dosh_l85a2.Dosh_L85A2_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet02_MAT.dosh_l85a2.Dosh_L85A2_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet02_MAT.dosh_l85a2.Dosh_L85A2_3P_Pickup_MIC"))

//Snakeskin SW500
	Skins.Add((Id=3318, Weapondef=class'KFWeapDef_SW500', MIC_1P=("WEP_SkinSet02_MAT.snakeskin_sw_500.Snakeskin_SW_1P_Mint_MIC"), MIC_3P="WEP_SkinSet02_MAT.snakeskin_sw_500.Snakeskin_SW_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet02_MAT.snakeskin_sw_500.Snakeskin_SW_3P_Pickup_MIC"))
	Skins.Add((Id=3317, Weapondef=class'KFWeapDef_SW500', MIC_1P=("WEP_SkinSet02_MAT.snakeskin_sw_500.Snakeskin_SW_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet02_MAT.snakeskin_sw_500.Snakeskin_SW_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet02_MAT.snakeskin_sw_500.Snakeskin_SW_3P_Pickup_MIC"))
	Skins.Add((Id=3316, Weapondef=class'KFWeapDef_SW500', MIC_1P=("WEP_SkinSet02_MAT.snakeskin_sw_500.Snakeskin_SW_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet02_MAT.snakeskin_sw_500.Snakeskin_SW_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet02_MAT.snakeskin_sw_500.Snakeskin_SW_3P_Pickup_MIC"))

//Snakeskin AA12
	Skins.Add((Id=3321, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet02_MAT.snakeskingreen_aa12.SnakeskinGreen_AA12_1P_Mint_MIC"), MIC_3P="WEP_SkinSet02_MAT.snakeskingreen_aa12.SnakeskinGreen_AA12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet02_MAT.snakeskingreen_aa12.SnakeskinGreen_AA12_3P_Pickup_MIC"))
	Skins.Add((Id=3320, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet02_MAT.snakeskingreen_aa12.SnakeskinGreen_AA12_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet02_MAT.snakeskingreen_aa12.SnakeskinGreen_AA12_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet02_MAT.snakeskingreen_aa12.SnakeskinGreen_AA12_3P_Pickup_MIC"))
	Skins.Add((Id=3319, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet02_MAT.snakeskingreen_aa12.SnakeskinGreen_AA12_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet02_MAT.snakeskingreen_aa12.SnakeskinGreen_AA12_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet02_MAT.snakeskingreen_aa12.SnakeskinGreen_AA12_3P_Pickup_MIC"))

//Circuit HX25
	Skins.Add((Id=3327, Weapondef=class'KFWeapDef_HX25', MIC_1P=("WEP_SkinSet02_MAT.circuit_hx25.Circuit_HX25_1P_Mint_MIC"), MIC_3P="WEP_SkinSet02_MAT.circuit_hx25.Circuit_HX25_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet02_MAT.circuit_hx25.Circuit_HX25_3P_Pickup_MIC"))
	Skins.Add((Id=3326, Weapondef=class'KFWeapDef_HX25', MIC_1P=("WEP_SkinSet02_MAT.circuit_hx25.Circuit_HX25_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet02_MAT.circuit_hx25.Circuit_HX25_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet02_MAT.circuit_hx25.Circuit_HX25_3P_Pickup_MIC"))
	Skins.Add((Id=3325, Weapondef=class'KFWeapDef_HX25', MIC_1P=("WEP_SkinSet02_MAT.circuit_hx25.Circuit_HX25_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet02_MAT.circuit_hx25.Circuit_HX25_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet02_MAT.circuit_hx25.Circuit_HX25_3P_Pickup_MIC"))

//Circuit Glow HX25
	Skins.Add((Id=3330, Weapondef=class'KFWeapDef_HX25', MIC_1P=("WEP_SkinSet02_MAT.circuitglow_hx25.CircuitGlow_HX25_1P_Mint_MIC"), MIC_3P="WEP_SkinSet02_MAT.circuitglow_hx25.CircuitGlow_HX25_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet02_MAT.circuitglow_hx25.CircuitGlow_HX25_3P_Pickup_MIC"))
	Skins.Add((Id=3329, Weapondef=class'KFWeapDef_HX25', MIC_1P=("WEP_SkinSet02_MAT.circuitglow_hx25.CircuitGlow_HX25_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet02_MAT.circuitglow_hx25.CircuitGlow_HX25_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet02_MAT.circuitglow_hx25.CircuitGlow_HX25_3P_Pickup_MIC"))
	Skins.Add((Id=3328, Weapondef=class'KFWeapDef_HX25', MIC_1P=("WEP_SkinSet02_MAT.circuitglow_hx25.CircuitGlow_HX25_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet02_MAT.circuitglow_hx25.CircuitGlow_HX25_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet02_MAT.circuitglow_hx25.CircuitGlow_HX25_3P_Pickup_MIC"))

//Glow Text Katana
	Skins.Add((Id=3333, Weapondef=class'KFWeapDef_Katana', MIC_1P=("WEP_SkinSet02_MAT.glowtext_katana.GlowText_Katana_1P_Mint_MIC"), MIC_3P="WEP_SkinSet02_MAT.glowtext_katana.GlowText_Katana_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet02_MAT.glowtext_katana.GlowText_Katana_3P_Pickup_MIC"))
	Skins.Add((Id=3332, Weapondef=class'KFWeapDef_Katana', MIC_1P=("WEP_SkinSet02_MAT.glowtext_katana.GlowText_Katana_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet02_MAT.glowtext_katana.GlowText_Katana_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet02_MAT.glowtext_katana.GlowText_Katana_3P_Pickup_MIC"))
	Skins.Add((Id=3331, Weapondef=class'KFWeapDef_Katana', MIC_1P=("WEP_SkinSet02_MAT.glowtext_katana.GlowText_Katana_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet02_MAT.glowtext_katana.GlowText_Katana_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet02_MAT.glowtext_katana.GlowText_Katana_3P_Pickup_MIC"))

//Carbon Fiber Medic Pistol
	Skins.Add((Id=3338, Weapondef=class'KFWeapDef_MedicPistol', MIC_1P=("WEP_SkinSet02_MAT.carbonfiber_medicpistol.CarbonFiber_MedicPistol_1P_Mint_MIC"), MIC_3P="WEP_SkinSet02_MAT.carbonfiber_medicpistol.CarbonFiber_MedicPistol_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet02_MAT.carbonfiber_medicpistol.CarbonFiber_MedicPistol_3P_Pickup_MIC"))
	Skins.Add((Id=3337, Weapondef=class'KFWeapDef_MedicPistol', MIC_1P=("WEP_SkinSet02_MAT.carbonfiber_medicpistol.CarbonFiber_MedicPistol_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet02_MAT.carbonfiber_medicpistol.CarbonFiber_MedicPistol_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet02_MAT.carbonfiber_medicpistol.CarbonFiber_MedicPistol_3P_Pickup_MIC"))
	Skins.Add((Id=3336, Weapondef=class'KFWeapDef_MedicPistol', MIC_1P=("WEP_SkinSet02_MAT.carbonfiber_medicpistol.CarbonFiber_MedicPistol_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet02_MAT.carbonfiber_medicpistol.CarbonFiber_MedicPistol_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet02_MAT.carbonfiber_medicpistol.CarbonFiber_MedicPistol_3P_Pickup_MIC"))

//Carbon Fiber Medic SMG
	Skins.Add((Id=3341, Weapondef=class'KFWeapDef_MedicSMG', MIC_1P=("WEP_SkinSet02_MAT.carbonfiber_medicpistol.CarbonFiber_MedicPistol_1P_Mint_MIC", "WEP_SkinSet02_MAT.carbonfiber_medicsmg.CarbonFiber_MedicSMG_1P_Mint_MIC"), MIC_3P="WEP_SkinSet02_MAT.carbonfiber_medicsmg.CarbonFiber_MedicSMG_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet02_MAT.carbonfiber_medicsmg.CarbonFiber_MedicSMG_3P_Pickup_MIC"))
	Skins.Add((Id=3340, Weapondef=class'KFWeapDef_MedicSMG', MIC_1P=("WEP_SkinSet02_MAT.carbonfiber_medicpistol.CarbonFiber_MedicPistol_1P_FieldTested_MIC", "WEP_SkinSet02_MAT.carbonfiber_medicsmg.CarbonFiber_MedicSMG_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet02_MAT.carbonfiber_medicsmg.CarbonFiber_MedicSMG_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet02_MAT.carbonfiber_medicsmg.CarbonFiber_MedicSMG_3P_Pickup_MIC"))
	Skins.Add((Id=3339, Weapondef=class'KFWeapDef_MedicSMG', MIC_1P=("WEP_SkinSet02_MAT.carbonfiber_medicpistol.CarbonFiber_MedicPistol_1P_BattleScarred_MIC", "WEP_SkinSet02_MAT.carbonfiber_medicsmg.CarbonFiber_MedicSMG_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet02_MAT.carbonfiber_medicsmg.CarbonFiber_MedicSMG_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet02_MAT.carbonfiber_medicsmg.CarbonFiber_MedicSMG_3P_Pickup_MIC"))

//Tactical Desert Eagle
	Skins.Add((Id=3361, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet03_MAT.tactical_deagle.Tactical_Deagle_1P_Mint_MIC"), MIC_3P="WEP_SkinSet03_MAT.tactical_deagle.Tactical_Deagle_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet03_MAT.tactical_deagle.Tactical_Deagle_3P_Pickup_MIC"))
	Skins.Add((Id=3360, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet03_MAT.tactical_deagle.Tactical_Deagle_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet03_MAT.tactical_deagle.Tactical_Deagle_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet03_MAT.tactical_deagle.Tactical_Deagle_3P_Pickup_MIC"))
	Skins.Add((Id=3359, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet03_MAT.tactical_deagle.Tactical_Deagle_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet03_MAT.tactical_deagle.Tactical_Deagle_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet03_MAT.tactical_deagle.Tactical_Deagle_3P_Pickup_MIC"))

//Tactical 9mm
	Skins.Add((Id=3364, Weapondef=class'KFWeapDef_9mm', MIC_1P=("WEP_SkinSet03_MAT.tactical_9mm.Tactical_9mm_1P_Mint_MIC"), MIC_3P="WEP_SkinSet03_MAT.tactical_9mm.Tactical_9mm_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet03_MAT.tactical_9mm.Tactical_9mm_3P_Pickup_MIC"))
	Skins.Add((Id=3363, Weapondef=class'KFWeapDef_9mm', MIC_1P=("WEP_SkinSet03_MAT.tactical_9mm.Tactical_9mm_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet03_MAT.tactical_9mm.Tactical_9mm_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet03_MAT.tactical_9mm.Tactical_9mm_3P_Pickup_MIC"))
	Skins.Add((Id=3362, Weapondef=class'KFWeapDef_9mm', MIC_1P=("WEP_SkinSet03_MAT.tactical_9mm.Tactical_9mm_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet03_MAT.tactical_9mm.Tactical_9mm_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet03_MAT.tactical_9mm.Tactical_9mm_3P_Pickup_MIC"))

//Tactical M1911
	Skins.Add((Id=3367, Weapondef=class'KFWeapDef_Colt1911', MIC_1P=("WEP_SkinSet03_MAT.tactical_m1911.Tactical_M1911_1P_Mint_MIC"), MIC_3P="WEP_SkinSet03_MAT.tactical_m1911.Tactical_M1911_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet03_MAT.tactical_m1911.Tactical_M1911_3P_Pickup_MIC"))
	Skins.Add((Id=3366, Weapondef=class'KFWeapDef_Colt1911', MIC_1P=("WEP_SkinSet03_MAT.tactical_m1911.Tactical_M1911_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet03_MAT.tactical_m1911.Tactical_M1911_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet03_MAT.tactical_m1911.Tactical_M1911_3P_Pickup_MIC"))
	Skins.Add((Id=3365, Weapondef=class'KFWeapDef_Colt1911', MIC_1P=("WEP_SkinSet03_MAT.tactical_m1911.Tactical_M1911_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet03_MAT.tactical_m1911.Tactical_M1911_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet03_MAT.tactical_m1911.Tactical_M1911_3P_Pickup_MIC"))

//Tactical AR15
	Skins.Add((Id=3370, Weapondef=class'KFWeapDef_AR15', MIC_1P=("WEP_SkinSet03_MAT.tactical_ar15.Tactical_AR15_1P_Mint_MIC"), MIC_3P="WEP_SkinSet03_MAT.tactical_ar15.Tactical_AR15_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet03_MAT.tactical_ar15.Tactical_AR15_3P_Pickup_MIC"))
	Skins.Add((Id=3369, Weapondef=class'KFWeapDef_AR15', MIC_1P=("WEP_SkinSet03_MAT.tactical_ar15.Tactical_AR15_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet03_MAT.tactical_ar15.Tactical_AR15_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet03_MAT.tactical_ar15.Tactical_AR15_3P_Pickup_MIC"))
	Skins.Add((Id=3368, Weapondef=class'KFWeapDef_AR15', MIC_1P=("WEP_SkinSet03_MAT.tactical_ar15.Tactical_AR15_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet03_MAT.tactical_ar15.Tactical_AR15_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet03_MAT.tactical_ar15.Tactical_AR15_3P_Pickup_MIC"))

//Tactical SW500
	Skins.Add((Id=3444, Weapondef=class'KFWeapDef_SW500', MIC_1P=("WEP_SkinSet03_MAT.tactical_sw500.Tactical_SW500_1P_Mint_MIC"), MIC_3P="WEP_SkinSet03_MAT.tactical_sw500.Tactical_SW500_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet03_MAT.tactical_sw500.Tactical_SW500_3P_Pickup_MIC"))
	Skins.Add((Id=3443, Weapondef=class'KFWeapDef_SW500', MIC_1P=("WEP_SkinSet03_MAT.tactical_sw500.Tactical_SW500_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet03_MAT.tactical_sw500.Tactical_SW500_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet03_MAT.tactical_sw500.Tactical_SW500_3P_Pickup_MIC"))
	Skins.Add((Id=3442, Weapondef=class'KFWeapDef_SW500', MIC_1P=("WEP_SkinSet03_MAT.tactical_sw500.Tactical_SW500_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet03_MAT.tactical_sw500.Tactical_SW500_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet03_MAT.tactical_sw500.Tactical_SW500_3P_Pickup_MIC"))

//Street Punks Caulk N Burn
	Skins.Add((Id=3373, Weapondef=class'KFWeapDef_CaulkBurn', MIC_1P=("WEP_SkinSet03_MAT.streetpunks_caulknburn.StreetPunks_CaulkNBurn_1P_Mint_MIC"), MIC_3P="WEP_SkinSet03_MAT.streetpunks_caulknburn.StreetPunks_CaulkNBurn_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet03_MAT.streetpunks_caulknburn.StreetPunks_CaulkNBurn_3P_Pickup_MIC"))
	Skins.Add((Id=3372, Weapondef=class'KFWeapDef_CaulkBurn', MIC_1P=("WEP_SkinSet03_MAT.streetpunks_caulknburn.StreetPunks_CaulkNBurn_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet03_MAT.streetpunks_caulknburn.StreetPunks_CaulkNBurn_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet03_MAT.streetpunks_caulknburn.StreetPunks_CaulkNBurn_3P_Pickup_MIC"))
	Skins.Add((Id=3371, Weapondef=class'KFWeapDef_CaulkBurn', MIC_1P=("WEP_SkinSet03_MAT.streetpunks_caulknburn.StreetPunks_CaulkNBurn_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet03_MAT.streetpunks_caulknburn.StreetPunks_CaulkNBurn_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet03_MAT.streetpunks_caulknburn.StreetPunks_CaulkNBurn_3P_Pickup_MIC"))

//Street Punks Commando Knife
	Skins.Add((Id=3376, Weapondef=class'KFWeapDef_Knife_Commando', MIC_1P=("WEP_SkinSet03_MAT.streetpunks_commandoknife.StreetPunks_CommandoKnife_1P_Mint_MIC"), MIC_3P="WEP_SkinSet03_MAT.streetpunks_commandoknife.StreetPunks_CommandoKnife_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet03_MAT.streetpunks_commandoknife.StreetPunks_CommandoKnife_3P_Pickup_MIC"))
	Skins.Add((Id=3375, Weapondef=class'KFWeapDef_Knife_Commando', MIC_1P=("WEP_SkinSet03_MAT.streetpunks_commandoknife.StreetPunks_CommandoKnife_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet03_MAT.streetpunks_commandoknife.StreetPunks_CommandoKnife_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet03_MAT.streetpunks_commandoknife.StreetPunks_CommandoKnife_3P_Pickup_MIC"))
	Skins.Add((Id=3374, Weapondef=class'KFWeapDef_Knife_Commando', MIC_1P=("WEP_SkinSet03_MAT.streetpunks_commandoknife.StreetPunks_CommandoKnife_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet03_MAT.streetpunks_commandoknife.StreetPunks_CommandoKnife_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet03_MAT.streetpunks_commandoknife.StreetPunks_CommandoKnife_3P_Pickup_MIC"))

//Street Punks AR15
	Skins.Add((Id=3379, Weapondef=class'KFWeapDef_AR15', MIC_1P=("WEP_SkinSet03_MAT.streetpunks_ar15.StreetPunks_AR15_1P_Mint_MIC"), MIC_3P="WEP_SkinSet03_MAT.streetpunks_ar15.StreetPunks_AR15_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet03_MAT.streetpunks_ar15.StreetPunks_AR15_3P_Pickup_MIC"))
	Skins.Add((Id=3378, Weapondef=class'KFWeapDef_AR15', MIC_1P=("WEP_SkinSet03_MAT.streetpunks_ar15.StreetPunks_AR15_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet03_MAT.streetpunks_ar15.StreetPunks_AR15_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet03_MAT.streetpunks_ar15.StreetPunks_AR15_3P_Pickup_MIC"))
	Skins.Add((Id=3377, Weapondef=class'KFWeapDef_AR15', MIC_1P=("WEP_SkinSet03_MAT.streetpunks_ar15.StreetPunks_AR15_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet03_MAT.streetpunks_ar15.StreetPunks_AR15_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet03_MAT.streetpunks_ar15.StreetPunks_AR15_3P_Pickup_MIC"))

//Street Punks 9mm
	Skins.Add((Id=3382, Weapondef=class'KFWeapDef_9mm', MIC_1P=("WEP_SkinSet03_MAT.streetpunks_9mm.StreetPunks_9mm_1P_Mint_MIC"), MIC_3P="WEP_SkinSet03_MAT.streetpunks_9mm.StreetPunks_9mm_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet03_MAT.streetpunks_9mm.StreetPunks_9mm_3P_Pickup_MIC"))
	Skins.Add((Id=3381, Weapondef=class'KFWeapDef_9mm', MIC_1P=("WEP_SkinSet03_MAT.streetpunks_9mm.StreetPunks_9mm_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet03_MAT.streetpunks_9mm.StreetPunks_9mm_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet03_MAT.streetpunks_9mm.StreetPunks_9mm_3P_Pickup_MIC"))
	Skins.Add((Id=3380, Weapondef=class'KFWeapDef_9mm', MIC_1P=("WEP_SkinSet03_MAT.streetpunks_9mm.StreetPunks_9mm_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet03_MAT.streetpunks_9mm.StreetPunks_9mm_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet03_MAT.streetpunks_9mm.StreetPunks_9mm_3P_Pickup_MIC"))

//Street Punks MB500
	Skins.Add((Id=3385, Weapondef=class'KFWeapDef_MB500', MIC_1P=("WEP_SkinSet03_MAT.streetpunks_mb500.StreetPunks_MB500_1P_Mint_MIC"), MIC_3P="WEP_SkinSet03_MAT.streetpunks_mb500.StreetPunks_MB500_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet03_MAT.streetpunks_mb500.StreetPunks_MB500_3P_Pickup_MIC"))
	Skins.Add((Id=3384, Weapondef=class'KFWeapDef_MB500', MIC_1P=("WEP_SkinSet03_MAT.streetpunks_mb500.StreetPunks_MB500_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet03_MAT.streetpunks_mb500.StreetPunks_MB500_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet03_MAT.streetpunks_mb500.StreetPunks_MB500_3P_Pickup_MIC"))
	Skins.Add((Id=3383, Weapondef=class'KFWeapDef_MB500', MIC_1P=("WEP_SkinSet03_MAT.streetpunks_mb500.StreetPunks_MB500_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet03_MAT.streetpunks_mb500.StreetPunks_MB500_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet03_MAT.streetpunks_mb500.StreetPunks_MB500_3P_Pickup_MIC"))

//Street Punks AK12
	Skins.Add((Id=3455, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet03_MAT.streetpunks_ak12.StreetPunks_AK12_1P_Mint_MIC"), MIC_3P="WEP_SkinSet03_MAT.streetpunks_ak12.StreetPunks_AK12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet03_MAT.streetpunks_ak12.StreetPunks_AK12_3P_Pickup_MIC"))
	Skins.Add((Id=3454, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet03_MAT.streetpunks_ak12.StreetPunks_AK12_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet03_MAT.streetpunks_ak12.StreetPunks_AK12_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet03_MAT.streetpunks_ak12.StreetPunks_AK12_3P_Pickup_MIC"))
	Skins.Add((Id=3453, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet03_MAT.streetpunks_ak12.StreetPunks_AK12_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet03_MAT.streetpunks_ak12.StreetPunks_AK12_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet03_MAT.streetpunks_ak12.StreetPunks_AK12_3P_Pickup_MIC"))

//Street Punks Desert Eagle
	Skins.Add((Id=3458, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet03_MAT.streetpunks_deagle.StreetPunks_Deagle_1P_Mint_MIC"), MIC_3P="WEP_SkinSet03_MAT.streetpunks_deagle.StreetPunks_Deagle_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet03_MAT.streetpunks_deagle.StreetPunks_Deagle_3P_Pickup_MIC"))
	Skins.Add((Id=3457, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet03_MAT.streetpunks_deagle.StreetPunks_Deagle_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet03_MAT.streetpunks_deagle.StreetPunks_Deagle_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet03_MAT.streetpunks_deagle.StreetPunks_Deagle_3P_Pickup_MIC"))
	Skins.Add((Id=3456, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet03_MAT.streetpunks_deagle.StreetPunks_Deagle_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet03_MAT.streetpunks_deagle.StreetPunks_Deagle_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet03_MAT.streetpunks_deagle.StreetPunks_Deagle_3P_Pickup_MIC"))

//Emergency Issue Caulk N Burn
	Skins.Add((Id=3388, Weapondef=class'KFWeapDef_CaulkBurn', MIC_1P=("WEP_SkinSet03_MAT.emergencyissue_caulknburn.EmergencyIssue_CaulkNBurn_1P_Mint_MIC"), MIC_3P="WEP_SkinSet03_MAT.emergencyissue_caulknburn.EmergencyIssue_CaulkNBurn_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet03_MAT.emergencyissue_caulknburn.EmergencyIssue_CaulkNBurn_3P_Pickup_MIC"))
	Skins.Add((Id=3387, Weapondef=class'KFWeapDef_CaulkBurn', MIC_1P=("WEP_SkinSet03_MAT.emergencyissue_caulknburn.EmergencyIssue_CaulkNBurn_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet03_MAT.emergencyissue_caulknburn.EmergencyIssue_CaulkNBurn_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet03_MAT.emergencyissue_caulknburn.EmergencyIssue_CaulkNBurn_3P_Pickup_MIC"))
	Skins.Add((Id=3386, Weapondef=class'KFWeapDef_CaulkBurn', MIC_1P=("WEP_SkinSet03_MAT.emergencyissue_caulknburn.EmergencyIssue_CaulkNBurn_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet03_MAT.emergencyissue_caulknburn.EmergencyIssue_CaulkNBurn_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet03_MAT.emergencyissue_caulknburn.EmergencyIssue_CaulkNBurn_3P_Pickup_MIC"))

//Emergency Issue 9mm
	Skins.Add((Id=3391, Weapondef=class'KFWeapDef_9mm', MIC_1P=("WEP_SkinSet03_MAT.emergencyissue_9mm.EmergencyIssue_9mm_1P_Mint_MIC"), MIC_3P="WEP_SkinSet03_MAT.emergencyissue_9mm.EmergencyIssue_9mm_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet03_MAT.emergencyissue_9mm.EmergencyIssue_9mm_3P_Pickup_MIC"))
	Skins.Add((Id=3390, Weapondef=class'KFWeapDef_9mm', MIC_1P=("WEP_SkinSet03_MAT.emergencyissue_9mm.EmergencyIssue_9mm_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet03_MAT.emergencyissue_9mm.EmergencyIssue_9mm_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet03_MAT.emergencyissue_9mm.EmergencyIssue_9mm_3P_Pickup_MIC"))
	Skins.Add((Id=3389, Weapondef=class'KFWeapDef_9mm', MIC_1P=("WEP_SkinSet03_MAT.emergencyissue_9mm.EmergencyIssue_9mm_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet03_MAT.emergencyissue_9mm.EmergencyIssue_9mm_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet03_MAT.emergencyissue_9mm.EmergencyIssue_9mm_3P_Pickup_MIC"))

//Emergency Issue Desert Eagle
	Skins.Add((Id=3394, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet03_MAT.emergencyissue_deagle.EmergencyIssue_Deagle_1P_Mint_MIC"), MIC_3P="WEP_SkinSet03_MAT.emergencyissue_deagle.EmergencyIssue_Deagle_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet03_MAT.emergencyissue_deagle.EmergencyIssue_Deagle_3P_Pickup_MIC"))
	Skins.Add((Id=3393, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet03_MAT.emergencyissue_deagle.EmergencyIssue_Deagle_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet03_MAT.emergencyissue_deagle.EmergencyIssue_Deagle_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet03_MAT.emergencyissue_deagle.EmergencyIssue_Deagle_3P_Pickup_MIC"))
	Skins.Add((Id=3392, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet03_MAT.emergencyissue_deagle.EmergencyIssue_Deagle_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet03_MAT.emergencyissue_deagle.EmergencyIssue_Deagle_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet03_MAT.emergencyissue_deagle.EmergencyIssue_Deagle_3P_Pickup_MIC"))

//Emergency Issue Nailgun
	Skins.Add((Id=3412, Weapondef=class'KFWeapDef_NailGun', MIC_1P=("WEP_SkinSet03_MAT.emergencyissue_nailgun.EmergencyIssue_NailGun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet03_MAT.emergencyissue_nailgun.EmergencyIssue_NailGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet03_MAT.emergencyissue_nailgun.EmergencyIssue_NailGun_3P_Pickup_MIC"))
	Skins.Add((Id=3411, Weapondef=class'KFWeapDef_NailGun', MIC_1P=("WEP_SkinSet03_MAT.emergencyissue_nailgun.EmergencyIssue_NailGun_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet03_MAT.emergencyissue_nailgun.EmergencyIssue_NailGun_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet03_MAT.emergencyissue_nailgun.EmergencyIssue_NailGun_3P_Pickup_MIC"))
	Skins.Add((Id=3410, Weapondef=class'KFWeapDef_NailGun', MIC_1P=("WEP_SkinSet03_MAT.emergencyissue_nailgun.EmergencyIssue_NailGun_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet03_MAT.emergencyissue_nailgun.EmergencyIssue_NailGun_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet03_MAT.emergencyissue_nailgun.EmergencyIssue_NailGun_3P_Pickup_MIC"))

//Emergency Issue MB500
	Skins.Add((Id=3415, Weapondef=class'KFWeapDef_MB500', MIC_1P=("WEP_SkinSet03_MAT.emergencyissue_mb500.EmergencyIssue_MB500_1P_Mint_MIC"), MIC_3P="WEP_SkinSet03_MAT.emergencyissue_mb500.EmergencyIssue_MB500_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet03_MAT.emergencyissue_mb500.EmergencyIssue_MB500_3P_Pickup_MIC"))
	Skins.Add((Id=3414, Weapondef=class'KFWeapDef_MB500', MIC_1P=("WEP_SkinSet03_MAT.emergencyissue_mb500.EmergencyIssue_MB500_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet03_MAT.emergencyissue_mb500.EmergencyIssue_MB500_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet03_MAT.emergencyissue_mb500.EmergencyIssue_MB500_3P_Pickup_MIC"))
	Skins.Add((Id=3413, Weapondef=class'KFWeapDef_MB500', MIC_1P=("WEP_SkinSet03_MAT.emergencyissue_mb500.EmergencyIssue_MB500_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet03_MAT.emergencyissue_mb500.EmergencyIssue_MB500_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet03_MAT.emergencyissue_mb500.EmergencyIssue_MB500_3P_Pickup_MIC"))

//Emergency Issue Flamethrower
	Skins.Add((Id=3418, Weapondef=class'KFWeapDef_FlameThrower', MIC_1P=("WEP_SkinSet03_MAT.emergencyissue_flamethrower.EmergencyIssue_Flamethrower_1P_Mint_MIC"), MIC_3P="WEP_SkinSet03_MAT.emergencyissue_flamethrower.EmergencyIssue_Flamethrower_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet03_MAT.emergencyissue_flamethrower.EmergencyIssue_Flamethrower_3P_Pickup_MIC"))
	Skins.Add((Id=3417, Weapondef=class'KFWeapDef_FlameThrower', MIC_1P=("WEP_SkinSet03_MAT.emergencyissue_flamethrower.EmergencyIssue_Flamethrower_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet03_MAT.emergencyissue_flamethrower.EmergencyIssue_Flamethrower_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet03_MAT.emergencyissue_flamethrower.EmergencyIssue_Flamethrower_3P_Pickup_MIC"))
	Skins.Add((Id=3416, Weapondef=class'KFWeapDef_FlameThrower', MIC_1P=("WEP_SkinSet03_MAT.emergencyissue_flamethrower.EmergencyIssue_Flamethrower_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet03_MAT.emergencyissue_flamethrower.EmergencyIssue_Flamethrower_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet03_MAT.emergencyissue_flamethrower.EmergencyIssue_Flamethrower_3P_Pickup_MIC"))

//Emergency Issue Microwave Gun
	Skins.Add((Id=3421, Weapondef=class'KFWeapDef_MicrowaveGun', MIC_1P=("WEP_SkinSet03_MAT.emergencyissue_microwavegun.EmergencyIssue_MicrowaveGun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet03_MAT.emergencyissue_microwavegun.EmergencyIssue_MicrowaveGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet03_MAT.emergencyissue_microwavegun.EmergencyIssue_MicrowaveGun_3P_Pickup_MIC"))
	Skins.Add((Id=3420, Weapondef=class'KFWeapDef_MicrowaveGun', MIC_1P=("WEP_SkinSet03_MAT.emergencyissue_microwavegun.EmergencyIssue_MicrowaveGun_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet03_MAT.emergencyissue_microwavegun.EmergencyIssue_MicrowaveGun_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet03_MAT.emergencyissue_microwavegun.EmergencyIssue_MicrowaveGun_3P_Pickup_MIC"))
	Skins.Add((Id=3419, Weapondef=class'KFWeapDef_MicrowaveGun', MIC_1P=("WEP_SkinSet03_MAT.emergencyissue_microwavegun.EmergencyIssue_MicrowaveGun_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet03_MAT.emergencyissue_microwavegun.EmergencyIssue_MicrowaveGun_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet03_MAT.emergencyissue_microwavegun.EmergencyIssue_MicrowaveGun_3P_Pickup_MIC"))

//Emergency Issue Sawblade
	Skins.Add((Id=3466, Weapondef=class'KFWeapDef_Eviscerator', MIC_1P=("WEP_SkinSet03_MAT.emergencyissue_sawblade.EmergencyIssue_SawBlade_1P_Mint_MIC"), MIC_3P="WEP_SkinSet03_MAT.emergencyissue_sawblade.EmergencyIssue_SawBlade_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet03_MAT.emergencyissue_sawblade.EmergencyIssue_SawBlade_3P_Pickup_MIC"))
	Skins.Add((Id=3465, Weapondef=class'KFWeapDef_Eviscerator', MIC_1P=("WEP_SkinSet03_MAT.emergencyissue_sawblade.EmergencyIssue_SawBlade_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet03_MAT.emergencyissue_sawblade.EmergencyIssue_SawBlade_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet03_MAT.emergencyissue_sawblade.EmergencyIssue_SawBlade_3P_Pickup_MIC"))
	Skins.Add((Id=3464, Weapondef=class'KFWeapDef_Eviscerator', MIC_1P=("WEP_SkinSet03_MAT.emergencyissue_sawblade.EmergencyIssue_SawBlade_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet03_MAT.emergencyissue_sawblade.EmergencyIssue_SawBlade_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet03_MAT.emergencyissue_sawblade.EmergencyIssue_SawBlade_3P_Pickup_MIC"))

//Emergency Issue Pulverizer
	Skins.Add((Id=3589, Weapondef=class'KFWeapDef_Pulverizer', MIC_1P=("WEP_SkinSet03_MAT.emergencyissue_pulverizer.EmergencyIssue_Pulverizer_1P_Mint_MIC"), MIC_3P="WEP_SkinSet03_MAT.emergencyissue_pulverizer.EmergencyIssue_Pulverizer_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet03_MAT.emergencyissue_pulverizer.EmergencyIssue_Pulverizer_3P_Pickup_MIC"))
	Skins.Add((Id=3588, Weapondef=class'KFWeapDef_Pulverizer', MIC_1P=("WEP_SkinSet03_MAT.emergencyissue_pulverizer.EmergencyIssue_Pulverizer_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet03_MAT.emergencyissue_pulverizer.EmergencyIssue_Pulverizer_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet03_MAT.emergencyissue_pulverizer.EmergencyIssue_Pulverizer_3P_Pickup_MIC"))
	Skins.Add((Id=3587, Weapondef=class'KFWeapDef_Pulverizer', MIC_1P=("WEP_SkinSet03_MAT.emergencyissue_pulverizer.EmergencyIssue_Pulverizer_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet03_MAT.emergencyissue_pulverizer.EmergencyIssue_Pulverizer_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet03_MAT.emergencyissue_pulverizer.EmergencyIssue_Pulverizer_3P_Pickup_MIC"))

//Predator MB500
	Skins.Add((Id=3397, Weapondef=class'KFWeapDef_MB500', MIC_1P=("WEP_SkinSet03_MAT.predator_mb500.Predator_MB500_1P_Mint_MIC"), MIC_3P="WEP_SkinSet03_MAT.predator_mb500.Predator_MB500_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet03_MAT.predator_mb500.Predator_MB500_3P_Pickup_MIC"))
	Skins.Add((Id=3396, Weapondef=class'KFWeapDef_MB500', MIC_1P=("WEP_SkinSet03_MAT.predator_mb500.Predator_MB500_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet03_MAT.predator_mb500.Predator_MB500_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet03_MAT.predator_mb500.Predator_MB500_3P_Pickup_MIC"))
	Skins.Add((Id=3395, Weapondef=class'KFWeapDef_MB500', MIC_1P=("WEP_SkinSet03_MAT.predator_mb500.Predator_MB500_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet03_MAT.predator_mb500.Predator_MB500_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet03_MAT.predator_mb500.Predator_MB500_3P_Pickup_MIC"))

//Predator HX25
	Skins.Add((Id=3400, Weapondef=class'KFWeapDef_HX25', MIC_1P=("WEP_SkinSet03_MAT.predator_hx25.Predator_HX25_1P_Mint_MIC"), MIC_3P="WEP_SkinSet03_MAT.predator_hx25.Predator_HX25_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet03_MAT.predator_hx25.Predator_HX25_3P_Pickup_MIC"))
	Skins.Add((Id=3399, Weapondef=class'KFWeapDef_HX25', MIC_1P=("WEP_SkinSet03_MAT.predator_hx25.Predator_HX25_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet03_MAT.predator_hx25.Predator_HX25_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet03_MAT.predator_hx25.Predator_HX25_3P_Pickup_MIC"))
	Skins.Add((Id=3398, Weapondef=class'KFWeapDef_HX25', MIC_1P=("WEP_SkinSet03_MAT.predator_hx25.Predator_HX25_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet03_MAT.predator_hx25.Predator_HX25_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet03_MAT.predator_hx25.Predator_HX25_3P_Pickup_MIC"))

//Predator AK12
	Skins.Add((Id=3403, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet03_MAT.predator_ak12.Predator_AK12_1P_Mint_MIC"), MIC_3P="WEP_SkinSet03_MAT.predator_ak12.Predator_AK12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet03_MAT.predator_ak12.Predator_AK12_3P_Pickup_MIC"))
	Skins.Add((Id=3402, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet03_MAT.predator_ak12.Predator_AK12_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet03_MAT.predator_ak12.Predator_AK12_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet03_MAT.predator_ak12.Predator_AK12_3P_Pickup_MIC"))
	Skins.Add((Id=3401, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet03_MAT.predator_ak12.Predator_AK12_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet03_MAT.predator_ak12.Predator_AK12_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet03_MAT.predator_ak12.Predator_AK12_3P_Pickup_MIC"))

//Predator L85A2
	Skins.Add((Id=3406, Weapondef=class'KFWeapDef_Bullpup', MIC_1P=("WEP_SkinSet03_MAT.predator_l85a2.Predator_L85A2_1P_Mint_MIC"), MIC_3P="WEP_SkinSet03_MAT.predator_l85a2.Predator_L85A2_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet03_MAT.predator_l85a2.Predator_L85A2_3P_Pickup_MIC"))
	Skins.Add((Id=3405, Weapondef=class'KFWeapDef_Bullpup', MIC_1P=("WEP_SkinSet03_MAT.predator_l85a2.Predator_L85A2_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet03_MAT.predator_l85a2.Predator_L85A2_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet03_MAT.predator_l85a2.Predator_L85A2_3P_Pickup_MIC"))
	Skins.Add((Id=3404, Weapondef=class'KFWeapDef_Bullpup', MIC_1P=("WEP_SkinSet03_MAT.predator_l85a2.Predator_L85A2_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet03_MAT.predator_l85a2.Predator_L85A2_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet03_MAT.predator_l85a2.Predator_L85A2_3P_Pickup_MIC"))

//Carcass AA12
	Skins.Add((Id=3409, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet03_MAT.carcass_aa12.Carcass_AA12_1P_Mint_MIC"), MIC_3P="WEP_SkinSet03_MAT.carcass_aa12.Carcass_AA12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet03_MAT.carcass_aa12.Carcass_AA12_3P_Pickup_MIC"))
	Skins.Add((Id=3408, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet03_MAT.carcass_aa12.Carcass_AA12_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet03_MAT.carcass_aa12.Carcass_AA12_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet03_MAT.carcass_aa12.Carcass_AA12_3P_Pickup_MIC"))
	Skins.Add((Id=3407, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet03_MAT.carcass_aa12.Carcass_AA12_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet03_MAT.carcass_aa12.Carcass_AA12_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet03_MAT.carcass_aa12.Carcass_AA12_3P_Pickup_MIC"))

//Horzine First Encounter MB500
	Skins.Add((Id=3447, Weapondef=class'KFWeapDef_MB500', MIC_1P=("WEP_SkinSet03_MAT.horzinefe_mb500.HorzineFE_MB500_1P_Mint_MIC"), MIC_3P="WEP_SkinSet03_MAT.horzinefe_mb500.HorzineFE_MB500_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet03_MAT.horzinefe_mb500.HorzineFE_MB500_3P_Pickup_MIC"))
	Skins.Add((Id=3446, Weapondef=class'KFWeapDef_MB500', MIC_1P=("WEP_SkinSet03_MAT.horzinefe_mb500.HorzineFE_MB500_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet03_MAT.horzinefe_mb500.HorzineFE_MB500_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet03_MAT.horzinefe_mb500.HorzineFE_MB500_3P_Pickup_MIC"))
	Skins.Add((Id=3445, Weapondef=class'KFWeapDef_MB500', MIC_1P=("WEP_SkinSet03_MAT.horzinefe_mb500.HorzineFE_MB500_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet03_MAT.horzinefe_mb500.HorzineFE_MB500_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet03_MAT.horzinefe_mb500.HorzineFE_MB500_3P_Pickup_MIC"))

//Flesh Pulverizer
	Skins.Add((Id=3645, Weapondef=class'KFWeapDef_Pulverizer', MIC_1P=("WEP_SkinSet03_MAT.flesh_pulverizer.Flesh_Pulverizer_1P_Mint_MIC"), MIC_3P="WEP_SkinSet03_MAT.flesh_pulverizer.Flesh_Pulverizer_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet03_MAT.flesh_pulverizer.Flesh_Pulverizer_3P_Pickup_MIC"))
	Skins.Add((Id=3644, Weapondef=class'KFWeapDef_Pulverizer', MIC_1P=("WEP_SkinSet03_MAT.flesh_pulverizer.Flesh_Pulverizer_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet03_MAT.flesh_pulverizer.Flesh_Pulverizer_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet03_MAT.flesh_pulverizer.Flesh_Pulverizer_3P_Pickup_MIC"))
	Skins.Add((Id=3643, Weapondef=class'KFWeapDef_Pulverizer', MIC_1P=("WEP_SkinSet03_MAT.flesh_pulverizer.Flesh_Pulverizer_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet03_MAT.flesh_pulverizer.Flesh_Pulverizer_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet03_MAT.flesh_pulverizer.Flesh_Pulverizer_3P_Pickup_MIC"))

//Vertebrae HX25
	Skins.Add((Id=3682, Weapondef=class'KFWeapDef_HX25', MIC_1P=("WEP_SkinSet03_MAT.vertebrae_hx25.Vertebrae_HX25_1P_Mint_MIC"), MIC_3P="WEP_SkinSet03_MAT.vertebrae_hx25.Vertebrae_HX25_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet03_MAT.vertebrae_hx25.Vertebrae_HX25_3P_Pickup_MIC"))
	Skins.Add((Id=3681, Weapondef=class'KFWeapDef_HX25', MIC_1P=("WEP_SkinSet03_MAT.vertebrae_hx25.Vertebrae_HX25_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet03_MAT.vertebrae_hx25.Vertebrae_HX25_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet03_MAT.vertebrae_hx25.Vertebrae_HX25_3P_Pickup_MIC"))
	Skins.Add((Id=3680, Weapondef=class'KFWeapDef_HX25', MIC_1P=("WEP_SkinSet03_MAT.vertebrae_hx25.Vertebrae_HX25_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet03_MAT.vertebrae_hx25.Vertebrae_HX25_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet03_MAT.vertebrae_hx25.Vertebrae_HX25_3P_Pickup_MIC"))

//Spray Can SCAR
	Skins.Add((Id=3729, Weapondef=class'KFWeapDef_SCAR', MIC_1P=("WEP_SkinSet03_MAT.spraycan_scar.SprayCan_SCAR_1P_Mint_MIC"), MIC_3P="WEP_SkinSet03_MAT.spraycan_scar.SprayCan_SCAR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet03_MAT.spraycan_scar.SprayCan_SCAR_3P_Pickup_MIC"))
	Skins.Add((Id=3728, Weapondef=class'KFWeapDef_SCAR', MIC_1P=("WEP_SkinSet03_MAT.spraycan_scar.SprayCan_SCAR_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet03_MAT.spraycan_scar.SprayCan_SCAR_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet03_MAT.spraycan_scar.SprayCan_SCAR_3P_Pickup_MIC"))
	Skins.Add((Id=3727, Weapondef=class'KFWeapDef_SCAR', MIC_1P=("WEP_SkinSet03_MAT.spraycan_scar.SprayCan_SCAR_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet03_MAT.spraycan_scar.SprayCan_SCAR_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet03_MAT.spraycan_scar.SprayCan_SCAR_3P_Pickup_MIC"))

//Leviathan AK12
	Skins.Add((Id=3732, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet03_MAT.leviathan_ak12.Leviathan_AK12_1P_Mint_MIC"), MIC_3P="WEP_SkinSet03_MAT.leviathan_ak12.Leviathan_AK12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet03_MAT.leviathan_ak12.Leviathan_AK12_3P_Pickup_MIC"))
	Skins.Add((Id=3731, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet03_MAT.leviathan_ak12.Leviathan_AK12_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet03_MAT.leviathan_ak12.Leviathan_AK12_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet03_MAT.leviathan_ak12.Leviathan_AK12_3P_Pickup_MIC"))
	Skins.Add((Id=3730, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet03_MAT.leviathan_ak12.Leviathan_AK12_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet03_MAT.leviathan_ak12.Leviathan_AK12_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet03_MAT.leviathan_ak12.Leviathan_AK12_3P_Pickup_MIC"))

//Horzine Elite Blue AK12
	Skins.Add((Id=3781, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet04_MAT.horzineeliteblue_ak12.HorzineEliteBlue_AK12_1P_Mint_MIC", "WEP_SkinSet04_MAT.horzineeliteblue_ak12.HorzineEliteBlue_AK12_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet04_MAT.horzineeliteblue_ak12.HorzineEliteBlue_AK12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet04_MAT.horzineeliteblue_ak12.HorzineEliteBlue_AK12_3P_Pickup_MIC"))
	Skins.Add((Id=3780, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet04_MAT.horzineeliteblue_ak12.HorzineEliteBlue_AK12_1P_FieldTested_MIC", "WEP_SkinSet04_MAT.horzineeliteblue_ak12.HorzineEliteBlue_AK12_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet04_MAT.horzineeliteblue_ak12.HorzineEliteBlue_AK12_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet04_MAT.horzineeliteblue_ak12.HorzineEliteBlue_AK12_3P_Pickup_MIC"))
	Skins.Add((Id=3779, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet04_MAT.horzineeliteblue_ak12.HorzineEliteBlue_AK12_1P_BattleScarred_MIC", "WEP_SkinSet04_MAT.horzineeliteblue_ak12.HorzineEliteBlue_AK12_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet04_MAT.horzineeliteblue_ak12.HorzineEliteBlue_AK12_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet04_MAT.horzineeliteblue_ak12.HorzineEliteBlue_AK12_3P_Pickup_MIC"))

//Horzine Elite Red AK12
	Skins.Add((Id=3784, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet04_MAT.horzineelitered_ak12.HorzineEliteRed_AK12_1P_Mint_MIC", "WEP_SkinSet04_MAT.horzineelitered_ak12.HorzineEliteRed_AK12_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet04_MAT.horzineelitered_ak12.HorzineEliteRed_AK12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet04_MAT.horzineelitered_ak12.HorzineEliteRed_AK12_3P_Pickup_MIC"))
	Skins.Add((Id=3783, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet04_MAT.horzineelitered_ak12.HorzineEliteRed_AK12_1P_FieldTested_MIC", "WEP_SkinSet04_MAT.horzineelitered_ak12.HorzineEliteRed_AK12_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet04_MAT.horzineelitered_ak12.HorzineEliteRed_AK12_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet04_MAT.horzineelitered_ak12.HorzineEliteRed_AK12_3P_Pickup_MIC"))
	Skins.Add((Id=3782, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet04_MAT.horzineelitered_ak12.HorzineEliteRed_AK12_1P_BattleScarred_MIC", "WEP_SkinSet04_MAT.horzineelitered_ak12.HorzineEliteRed_AK12_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet04_MAT.horzineelitered_ak12.HorzineEliteRed_AK12_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet04_MAT.horzineelitered_ak12.HorzineEliteRed_AK12_3P_Pickup_MIC"))

//Horzine Elite White AK12
	Skins.Add((Id=3787, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet04_MAT.horzineelitewhite_ak12.HorzineEliteWhite_AK12_1P_Mint_MIC", "WEP_SkinSet04_MAT.horzineelitewhite_ak12.HorzineEliteWhite_AK12_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet04_MAT.horzineelitewhite_ak12.HorzineEliteWhite_AK12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet04_MAT.horzineelitewhite_ak12.HorzineEliteWhite_AK12_3P_Pickup_MIC"))
	Skins.Add((Id=3786, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet04_MAT.horzineelitewhite_ak12.HorzineEliteWhite_AK12_1P_FieldTested_MIC", "WEP_SkinSet04_MAT.horzineelitewhite_ak12.HorzineEliteWhite_AK12_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet04_MAT.horzineelitewhite_ak12.HorzineEliteWhite_AK12_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet04_MAT.horzineelitewhite_ak12.HorzineEliteWhite_AK12_3P_Pickup_MIC"))
	Skins.Add((Id=3785, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet04_MAT.horzineelitewhite_ak12.HorzineEliteWhite_AK12_1P_BattleScarred_MIC", "WEP_SkinSet04_MAT.horzineelitewhite_ak12.HorzineEliteWhite_AK12_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet04_MAT.horzineelitewhite_ak12.HorzineEliteWhite_AK12_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet04_MAT.horzineelitewhite_ak12.HorzineEliteWhite_AK12_3P_Pickup_MIC"))

//Horzine Elite Green AK12
	Skins.Add((Id=3790, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet04_MAT.horzineelitegreen_ak12.HorzineEliteGreen_AK12_1P_Mint_MIC", "WEP_SkinSet04_MAT.horzineelitegreen_ak12.HorzineEliteGreen_AK12_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet04_MAT.horzineelitegreen_ak12.HorzineEliteGreen_AK12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet04_MAT.horzineelitegreen_ak12.HorzineEliteGreen_AK12_3P_Pickup_MIC"))
	Skins.Add((Id=3789, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet04_MAT.horzineelitegreen_ak12.HorzineEliteGreen_AK12_1P_FieldTested_MIC", "WEP_SkinSet04_MAT.horzineelitegreen_ak12.HorzineEliteGreen_AK12_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet04_MAT.horzineelitegreen_ak12.HorzineEliteGreen_AK12_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet04_MAT.horzineelitegreen_ak12.HorzineEliteGreen_AK12_3P_Pickup_MIC"))
	Skins.Add((Id=3788, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet04_MAT.horzineelitegreen_ak12.HorzineEliteGreen_AK12_1P_BattleScarred_MIC", "WEP_SkinSet04_MAT.horzineelitegreen_ak12.HorzineEliteGreen_AK12_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet04_MAT.horzineelitegreen_ak12.HorzineEliteGreen_AK12_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet04_MAT.horzineelitegreen_ak12.HorzineEliteGreen_AK12_3P_Pickup_MIC"))

//Horzine First Encounter Healer
	Skins.Add((Id=3793, Weapondef=class'KFWeapDef_Healer', MIC_1P=("WEP_SkinSet04_MAT.horzinefe_healer.HorzineFE_Healer_1P_Mint_MIC"), MIC_3P="WEP_SkinSet04_MAT.horzinefe_healer.HorzineFE_Healer_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet04_MAT.horzinefe_healer.HorzineFE_Healer_3P_Pickup_MIC"))
	Skins.Add((Id=3792, Weapondef=class'KFWeapDef_Healer', MIC_1P=("WEP_SkinSet04_MAT.horzinefe_healer.HorzineFE_Healer_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet04_MAT.horzinefe_healer.HorzineFE_Healer_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet04_MAT.horzinefe_healer.HorzineFE_Healer_3P_Pickup_MIC"))
	Skins.Add((Id=3791, Weapondef=class'KFWeapDef_Healer', MIC_1P=("WEP_SkinSet04_MAT.horzinefe_healer.HorzineFE_Healer_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet04_MAT.horzinefe_healer.HorzineFE_Healer_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet04_MAT.horzinefe_healer.HorzineFE_Healer_3P_Pickup_MIC"))

//Horzine First Encounter Welder
	Skins.Add((Id=3796, Weapondef=class'KFWeapDef_Welder', MIC_1P=("WEP_SkinSet04_MAT.horzinefe_welder.HorzineFE_Welder_1P_Mint_MIC"), MIC_3P="WEP_SkinSet04_MAT.horzinefe_welder.HorzineFE_Welder_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet04_MAT.horzinefe_welder.HorzineFE_Welder_3P_Pickup_MIC"))
	Skins.Add((Id=3795, Weapondef=class'KFWeapDef_Welder', MIC_1P=("WEP_SkinSet04_MAT.horzinefe_welder.HorzineFE_Welder_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet04_MAT.horzinefe_welder.HorzineFE_Welder_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet04_MAT.horzinefe_welder.HorzineFE_Welder_3P_Pickup_MIC"))
	Skins.Add((Id=3794, Weapondef=class'KFWeapDef_Welder', MIC_1P=("WEP_SkinSet04_MAT.horzinefe_welder.HorzineFE_Welder_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet04_MAT.horzinefe_welder.HorzineFE_Welder_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet04_MAT.horzinefe_welder.HorzineFE_Welder_3P_Pickup_MIC"))

//Horzine First Encounter AA12
	Skins.Add((Id=3799, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet04_MAT.horzinefe_aa12.HorzineFE_AA12_1P_Mint_MIC"), MIC_3P="WEP_SkinSet04_MAT.horzinefe_aa12.HorzineFE_AA12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet04_MAT.horzinefe_aa12.HorzineFE_AA12_3P_Pickup_MIC"))
	Skins.Add((Id=3798, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet04_MAT.horzinefe_aa12.HorzineFE_AA12_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet04_MAT.horzinefe_aa12.HorzineFE_AA12_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet04_MAT.horzinefe_aa12.HorzineFE_AA12_3P_Pickup_MIC"))
	Skins.Add((Id=3797, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet04_MAT.horzinefe_aa12.HorzineFE_AA12_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet04_MAT.horzinefe_aa12.HorzineFE_AA12_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet04_MAT.horzinefe_aa12.HorzineFE_AA12_3P_Pickup_MIC"))

//Elite Unit Medic Pistol
	Skins.Add((Id=3670, Weapondef=class'KFWeapDef_MedicPistol', MIC_1P=("WEP_SkinSet05_MAT.eliteunit_medicpistol.EliteUnit_MedicPistol_1P_Mint_MIC"), MIC_3P="WEP_SkinSet05_MAT.eliteunit_medicpistol.EliteUnit_MedicPistol_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet05_MAT.eliteunit_medicpistol.EliteUnit_MedicPistol_3P_Pickup_MIC"))
	Skins.Add((Id=3669, Weapondef=class'KFWeapDef_MedicPistol', MIC_1P=("WEP_SkinSet05_MAT.eliteunit_medicpistol.EliteUnit_MedicPistol_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet05_MAT.eliteunit_medicpistol.EliteUnit_MedicPistol_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet05_MAT.eliteunit_medicpistol.EliteUnit_MedicPistol_3P_Pickup_MIC"))
	Skins.Add((Id=3668, Weapondef=class'KFWeapDef_MedicPistol', MIC_1P=("WEP_SkinSet05_MAT.eliteunit_medicpistol.EliteUnit_MedicPistol_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet05_MAT.eliteunit_medicpistol.EliteUnit_MedicPistol_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet05_MAT.eliteunit_medicpistol.EliteUnit_MedicPistol_3P_Pickup_MIC"))

//Elite Unit Medic SMG
	Skins.Add((Id=3673, Weapondef=class'KFWeapDef_MedicSMG', MIC_1P=("WEP_SkinSet05_MAT.eliteunit_medicpistol.EliteUnit_MedicPistol_1P_Mint_MIC", "WEP_SkinSet05_MAT.eliteunit_medicsmg.EliteUnit_MedicSMG_1P_Mint_MIC"), MIC_3P="WEP_SkinSet05_MAT.eliteunit_medicsmg.EliteUnit_MedicSMG_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet05_MAT.eliteunit_medicsmg.EliteUnit_MedicSMG_3P_Pickup_MIC"))
	Skins.Add((Id=3672, Weapondef=class'KFWeapDef_MedicSMG', MIC_1P=("WEP_SkinSet05_MAT.eliteunit_medicpistol.EliteUnit_MedicPistol_1P_FieldTested_MIC", "WEP_SkinSet05_MAT.eliteunit_medicsmg.EliteUnit_MedicSMG_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet05_MAT.eliteunit_medicsmg.EliteUnit_MedicSMG_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet05_MAT.eliteunit_medicsmg.EliteUnit_MedicSMG_3P_Pickup_MIC"))
	Skins.Add((Id=3671, Weapondef=class'KFWeapDef_MedicSMG', MIC_1P=("WEP_SkinSet05_MAT.eliteunit_medicpistol.EliteUnit_MedicPistol_1P_BattleScarred_MIC", "WEP_SkinSet05_MAT.eliteunit_medicsmg.EliteUnit_MedicSMG_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet05_MAT.eliteunit_medicsmg.EliteUnit_MedicSMG_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet05_MAT.eliteunit_medicsmg.EliteUnit_MedicSMG_3P_Pickup_MIC"))

//Elite Unit Medic Shotgun
	Skins.Add((Id=3676, Weapondef=class'KFWeapDef_MedicShotgun', MIC_1P=("WEP_SkinSet05_MAT.eliteunit_medicpistol.EliteUnit_MedicPistol_1P_Mint_MIC", "WEP_SkinSet05_MAT.eliteunit_medicshotgun.EliteUnit_MedicShotgun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet05_MAT.eliteunit_medicshotgun.EliteUnit_MedicShotgun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet05_MAT.eliteunit_medicshotgun.EliteUnit_MedicShotgun_3P_Pickup_MIC"))
	Skins.Add((Id=3675, Weapondef=class'KFWeapDef_MedicShotgun', MIC_1P=("WEP_SkinSet05_MAT.eliteunit_medicpistol.EliteUnit_MedicPistol_1P_FieldTested_MIC", "WEP_SkinSet05_MAT.eliteunit_medicshotgun.EliteUnit_MedicShotgun_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet05_MAT.eliteunit_medicshotgun.EliteUnit_MedicShotgun_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet05_MAT.eliteunit_medicshotgun.EliteUnit_MedicShotgun_3P_Pickup_MIC"))
	Skins.Add((Id=3674, Weapondef=class'KFWeapDef_MedicShotgun', MIC_1P=("WEP_SkinSet05_MAT.eliteunit_medicpistol.EliteUnit_MedicPistol_1P_BattleScarred_MIC", "WEP_SkinSet05_MAT.eliteunit_medicshotgun.EliteUnit_MedicShotgun_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet05_MAT.eliteunit_medicshotgun.EliteUnit_MedicShotgun_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet05_MAT.eliteunit_medicshotgun.EliteUnit_MedicShotgun_3P_Pickup_MIC"))

//Elite Unit Medic Assault
	Skins.Add((Id=3679, Weapondef=class'KFWeapDef_MedicRifle', MIC_1P=("WEP_SkinSet05_MAT.eliteunit_medicassault.EliteUnit_MedicAssault_1P_Mint_MIC", "WEP_SkinSet05_MAT.eliteunit_medicpistol.EliteUnit_MedicPistol_1P_Mint_MIC"), MIC_3P="WEP_SkinSet05_MAT.eliteunit_medicassault.EliteUnit_MedicAssault_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet05_MAT.eliteunit_medicassault.EliteUnit_MedicAssault_3P_Pickup_MIC"))
	Skins.Add((Id=3678, Weapondef=class'KFWeapDef_MedicRifle', MIC_1P=("WEP_SkinSet05_MAT.eliteunit_medicassault.EliteUnit_MedicAssault_1P_FieldTested_MIC", "WEP_SkinSet05_MAT.eliteunit_medicpistol.EliteUnit_MedicPistol_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet05_MAT.eliteunit_medicassault.EliteUnit_MedicAssault_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet05_MAT.eliteunit_medicassault.EliteUnit_MedicAssault_3P_Pickup_MIC"))
	Skins.Add((Id=3677, Weapondef=class'KFWeapDef_MedicRifle', MIC_1P=("WEP_SkinSet05_MAT.eliteunit_medicassault.EliteUnit_MedicAssault_1P_BattleScarred_MIC", "WEP_SkinSet05_MAT.eliteunit_medicpistol.EliteUnit_MedicPistol_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet05_MAT.eliteunit_medicassault.EliteUnit_MedicAssault_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet05_MAT.eliteunit_medicassault.EliteUnit_MedicAssault_3P_Pickup_MIC"))

//Elite Unit Medic Knife
	Skins.Add((Id=4138, Weapondef=class'KFWeapDef_Knife_Medic', MIC_1P=("WEP_SkinSet05_MAT.eliteunit_scalpel.EliteUnit_Scalpel_1P_Mint_MIC"), MIC_3P="WEP_SkinSet05_MAT.eliteunit_scalpel.EliteUnit_Scalpel_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet05_MAT.eliteunit_scalpel.EliteUnit_Scalpel_3P_Pickup_MIC"))
	Skins.Add((Id=4137, Weapondef=class'KFWeapDef_Knife_Medic', MIC_1P=("WEP_SkinSet05_MAT.eliteunit_scalpel.EliteUnit_Scalpel_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet05_MAT.eliteunit_scalpel.EliteUnit_Scalpel_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet05_MAT.eliteunit_scalpel.EliteUnit_Scalpel_3P_Pickup_MIC"))
	Skins.Add((Id=4136, Weapondef=class'KFWeapDef_Knife_Medic', MIC_1P=("WEP_SkinSet05_MAT.eliteunit_scalpel.EliteUnit_Scalpel_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet05_MAT.eliteunit_scalpel.EliteUnit_Scalpel_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet05_MAT.eliteunit_scalpel.EliteUnit_Scalpel_3P_Pickup_MIC"))

//Elite Unit Healer
	Skins.Add((Id=4187, Weapondef=class'KFWeapDef_Healer', MIC_1P=("WEP_SkinSet05_MAT.eliteunit_healer.EliteUnit_Healer_1P_Mint_MIC"), MIC_3P="WEP_SkinSet05_MAT.eliteunit_healer.EliteUnit_Healer_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet05_MAT.eliteunit_healer.EliteUnit_Healer_3P_Pickup_MIC"))
	Skins.Add((Id=4186, Weapondef=class'KFWeapDef_Healer', MIC_1P=("WEP_SkinSet05_MAT.eliteunit_healer.EliteUnit_Healer_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet05_MAT.eliteunit_healer.EliteUnit_Healer_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet05_MAT.eliteunit_healer.EliteUnit_Healer_3P_Pickup_MIC"))
	Skins.Add((Id=4185, Weapondef=class'KFWeapDef_Healer', MIC_1P=("WEP_SkinSet05_MAT.eliteunit_healer.EliteUnit_Healer_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet05_MAT.eliteunit_healer.EliteUnit_Healer_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet05_MAT.eliteunit_healer.EliteUnit_Healer_3P_Pickup_MIC"))

//Elite Unit Green Medic Pistol
	Skins.Add((Id=4190, Weapondef=class'KFWeapDef_MedicPistol', MIC_1P=("WEP_SkinSet06_MAT.eliteunitgreen_medicpistol.EliteUnitGreen_MedicPistol_1P_Mint_MIC"), MIC_3P="WEP_SkinSet06_MAT.eliteunitgreen_medicpistol.EliteUnitGreen_MedicPistol_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet06_MAT.eliteunitgreen_medicpistol.EliteUnitGreen_MedicPistol_3P_Pickup_MIC"))
	Skins.Add((Id=4189, Weapondef=class'KFWeapDef_MedicPistol', MIC_1P=("WEP_SkinSet06_MAT.eliteunitgreen_medicpistol.EliteUnitGreen_MedicPistol_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet06_MAT.eliteunitgreen_medicpistol.EliteUnitGreen_MedicPistol_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet06_MAT.eliteunitgreen_medicpistol.EliteUnitGreen_MedicPistol_3P_Pickup_MIC"))
	Skins.Add((Id=4188, Weapondef=class'KFWeapDef_MedicPistol', MIC_1P=("WEP_SkinSet06_MAT.eliteunitgreen_medicpistol.EliteUnitGreen_MedicPistol_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet06_MAT.eliteunitgreen_medicpistol.EliteUnitGreen_MedicPistol_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet06_MAT.eliteunitgreen_medicpistol.EliteUnitGreen_MedicPistol_3P_Pickup_MIC"))

//Elite Unit Green Medic SMG
	Skins.Add((Id=4193, Weapondef=class'KFWeapDef_MedicSMG', MIC_1P=("WEP_SkinSet06_MAT.eliteunitgreen_medicpistol.EliteUnitGreen_MedicPistol_1P_Mint_MIC", "WEP_SkinSet06_MAT.eliteunitgreen_medicsmg.EliteUnitGreen_MedicSMG_1P_Mint_MIC"), MIC_3P="WEP_SkinSet06_MAT.eliteunitgreen_medicsmg.EliteUnitGreen_MedicSMG_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet06_MAT.eliteunitgreen_medicsmg.EliteUnitGreen_MedicSMG_3P_Pickup_MIC"))
	Skins.Add((Id=4192, Weapondef=class'KFWeapDef_MedicSMG', MIC_1P=("WEP_SkinSet06_MAT.eliteunitgreen_medicpistol.EliteUnitGreen_MedicPistol_1P_FieldTested_MIC", "WEP_SkinSet06_MAT.eliteunitgreen_medicsmg.EliteUnitGreen_MedicSMG_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet06_MAT.eliteunitgreen_medicsmg.EliteUnitGreen_MedicSMG_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet06_MAT.eliteunitgreen_medicsmg.EliteUnitGreen_MedicSMG_3P_Pickup_MIC"))
	Skins.Add((Id=4191, Weapondef=class'KFWeapDef_MedicSMG', MIC_1P=("WEP_SkinSet06_MAT.eliteunitgreen_medicpistol.EliteUnitGreen_MedicPistol_1P_BattleScarred_MIC", "WEP_SkinSet06_MAT.eliteunitgreen_medicsmg.EliteUnitGreen_MedicSMG_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet06_MAT.eliteunitgreen_medicsmg.EliteUnitGreen_MedicSMG_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet06_MAT.eliteunitgreen_medicsmg.EliteUnitGreen_MedicSMG_3P_Pickup_MIC"))

//Elite Unit Red Medic Shotgun
	Skins.Add((Id=4196, Weapondef=class'KFWeapDef_MedicShotgun', MIC_1P=("WEP_SkinSet06_MAT.eliteunitred_medicpistol.EliteUnitRed_MedicPistol_1P_Mint_MIC", "WEP_SkinSet06_MAT.eliteunitred_medicshotgun.EliteUnitRed_MedicShotgun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet06_MAT.eliteunitred_medicshotgun.EliteUnitRed_MedicShotgun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet06_MAT.eliteunitred_medicshotgun.EliteUnitRed_MedicShotgun_3P_Pickup_MIC"))
	Skins.Add((Id=4195, Weapondef=class'KFWeapDef_MedicShotgun', MIC_1P=("WEP_SkinSet06_MAT.eliteunitred_medicpistol.EliteUnitRed_MedicPistol_1P_FieldTested_MIC", "WEP_SkinSet06_MAT.eliteunitred_medicshotgun.EliteUnitRed_MedicShotgun_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet06_MAT.eliteunitred_medicshotgun.EliteUnitRed_MedicShotgun_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet06_MAT.eliteunitred_medicshotgun.EliteUnitRed_MedicShotgun_3P_Pickup_MIC"))
	Skins.Add((Id=4194, Weapondef=class'KFWeapDef_MedicShotgun', MIC_1P=("WEP_SkinSet06_MAT.eliteunitred_medicpistol.EliteUnitRed_MedicPistol_1P_BattleScarred_MIC", "WEP_SkinSet06_MAT.eliteunitred_medicshotgun.EliteUnitRed_MedicShotgun_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet06_MAT.eliteunitred_medicshotgun.EliteUnitRed_MedicShotgun_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet06_MAT.eliteunitred_medicshotgun.EliteUnitRed_MedicShotgun_3P_Pickup_MIC"))

//Elite Unit Red Medic Assault
	Skins.Add((Id=4199, Weapondef=class'KFWeapDef_MedicRifle', MIC_1P=("WEP_SkinSet06_MAT.eliteunitred_medicassault.EliteUnitRed_MedicAssault_1P_Mint_MIC", "WEP_SkinSet06_MAT.eliteunitred_medicpistol.EliteUnitRed_MedicPistol_1P_Mint_MIC"), MIC_3P="WEP_SkinSet06_MAT.eliteunitred_medicassault.EliteUnitRed_MedicAssault_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet06_MAT.eliteunitred_medicassault.EliteUnitRed_MedicAssault_3P_Pickup_MIC"))
	Skins.Add((Id=4198, Weapondef=class'KFWeapDef_MedicRifle', MIC_1P=("WEP_SkinSet06_MAT.eliteunitred_medicassault.EliteUnitRed_MedicAssault_1P_FieldTested_MIC", "WEP_SkinSet06_MAT.eliteunitred_medicpistol.EliteUnitRed_MedicPistol_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet06_MAT.eliteunitred_medicassault.EliteUnitRed_MedicAssault_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet06_MAT.eliteunitred_medicassault.EliteUnitRed_MedicAssault_3P_Pickup_MIC"))
	Skins.Add((Id=4197, Weapondef=class'KFWeapDef_MedicRifle', MIC_1P=("WEP_SkinSet06_MAT.eliteunitred_medicassault.EliteUnitRed_MedicAssault_1P_BattleScarred_MIC", "WEP_SkinSet06_MAT.eliteunitred_medicpistol.EliteUnitRed_MedicPistol_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet06_MAT.eliteunitred_medicassault.EliteUnitRed_MedicAssault_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet06_MAT.eliteunitred_medicassault.EliteUnitRed_MedicAssault_3P_Pickup_MIC"))

//SWAT AA12
	Skins.Add((Id=3975, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet05_MAT.swat_aa12.SWAT_AA12_1P_Mint_MIC"), MIC_3P="WEP_SkinSet05_MAT.swat_aa12.SWAT_AA12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet05_MAT.swat_aa12.SWAT_AA12_3P_Pickup_MIC"))
	Skins.Add((Id=3974, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet05_MAT.swat_aa12.SWAT_AA12_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet05_MAT.swat_aa12.SWAT_AA12_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet05_MAT.swat_aa12.SWAT_AA12_3P_Pickup_MIC"))
	Skins.Add((Id=3973, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet05_MAT.swat_aa12.SWAT_AA12_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet05_MAT.swat_aa12.SWAT_AA12_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet05_MAT.swat_aa12.SWAT_AA12_3P_Pickup_MIC"))

//SWAT AK12
	Skins.Add((Id=3978, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet05_MAT.swat_ak12.SWAT_AK12_1P_Mint_MIC"), MIC_3P="WEP_SkinSet05_MAT.swat_ak12.SWAT_AK12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet05_MAT.swat_ak12.SWAT_AK12_3P_Pickup_MIC"))
	Skins.Add((Id=3977, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet05_MAT.swat_ak12.SWAT_AK12_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet05_MAT.swat_ak12.SWAT_AK12_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet05_MAT.swat_ak12.SWAT_AK12_3P_Pickup_MIC"))
	Skins.Add((Id=3976, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet05_MAT.swat_ak12.SWAT_AK12_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet05_MAT.swat_ak12.SWAT_AK12_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet05_MAT.swat_ak12.SWAT_AK12_3P_Pickup_MIC"))

//SWAT MB500
	Skins.Add((Id=3981, Weapondef=class'KFWeapDef_MB500', MIC_1P=("WEP_SkinSet05_MAT.swat_mb500.SWAT_MB500_1P_Mint_MIC"), MIC_3P="WEP_SkinSet05_MAT.swat_mb500.SWAT_MB500_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet05_MAT.swat_mb500.SWAT_MB500_3P_Pickup_MIC"))
	Skins.Add((Id=3980, Weapondef=class'KFWeapDef_MB500', MIC_1P=("WEP_SkinSet05_MAT.swat_mb500.SWAT_MB500_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet05_MAT.swat_mb500.SWAT_MB500_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet05_MAT.swat_mb500.SWAT_MB500_3P_Pickup_MIC"))
	Skins.Add((Id=3979, Weapondef=class'KFWeapDef_MB500', MIC_1P=("WEP_SkinSet05_MAT.swat_mb500.SWAT_MB500_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet05_MAT.swat_mb500.SWAT_MB500_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet05_MAT.swat_mb500.SWAT_MB500_3P_Pickup_MIC"))

//SWAT 9mm
	Skins.Add((Id=3984, Weapondef=class'KFWeapDef_9mm', MIC_1P=("WEP_SkinSet05_MAT.swat_9mm.SWAT_9mm_1P_Mint_MIC"), MIC_3P="WEP_SkinSet05_MAT.swat_9mm.SWAT_9mm_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet05_MAT.swat_9mm.SWAT_9mm_3P_Pickup_MIC"))
	Skins.Add((Id=3983, Weapondef=class'KFWeapDef_9mm', MIC_1P=("WEP_SkinSet05_MAT.swat_9mm.SWAT_9mm_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet05_MAT.swat_9mm.SWAT_9mm_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet05_MAT.swat_9mm.SWAT_9mm_3P_Pickup_MIC"))
	Skins.Add((Id=3982, Weapondef=class'KFWeapDef_9mm', MIC_1P=("WEP_SkinSet05_MAT.swat_9mm.SWAT_9mm_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet05_MAT.swat_9mm.SWAT_9mm_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet05_MAT.swat_9mm.SWAT_9mm_3P_Pickup_MIC"))

//SWAT SCAR
	Skins.Add((Id=3987, Weapondef=class'KFWeapDef_SCAR', MIC_1P=("WEP_SkinSet05_MAT.swat_scar.SWAT_SCAR_1P_Mint_MIC"), MIC_3P="WEP_SkinSet05_MAT.swat_scar.SWAT_SCAR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet05_MAT.swat_scar.SWAT_SCAR_3P_Pickup_MIC"))
	Skins.Add((Id=3986, Weapondef=class'KFWeapDef_SCAR', MIC_1P=("WEP_SkinSet05_MAT.swat_scar.SWAT_SCAR_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet05_MAT.swat_scar.SWAT_SCAR_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet05_MAT.swat_scar.SWAT_SCAR_3P_Pickup_MIC"))
	Skins.Add((Id=3985, Weapondef=class'KFWeapDef_SCAR', MIC_1P=("WEP_SkinSet05_MAT.swat_scar.SWAT_SCAR_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet05_MAT.swat_scar.SWAT_SCAR_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet05_MAT.swat_scar.SWAT_SCAR_3P_Pickup_MIC"))

//SWAT Pulverizer
	Skins.Add((Id=4128, Weapondef=class'KFWeapDef_Pulverizer', MIC_1P=("WEP_SkinSet05_MAT.swat_pulverizer.SWAT_Pulverizer_1P_Mint_MIC"), MIC_3P="WEP_SkinSet05_MAT.swat_pulverizer.SWAT_Pulverizer_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet05_MAT.swat_pulverizer.SWAT_Pulverizer_3P_Pickup_MIC"))
	Skins.Add((Id=4127, Weapondef=class'KFWeapDef_Pulverizer', MIC_1P=("WEP_SkinSet05_MAT.swat_pulverizer.SWAT_Pulverizer_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet05_MAT.swat_pulverizer.SWAT_Pulverizer_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet05_MAT.swat_pulverizer.SWAT_Pulverizer_3P_Pickup_MIC"))
	Skins.Add((Id=4126, Weapondef=class'KFWeapDef_Pulverizer', MIC_1P=("WEP_SkinSet05_MAT.swat_pulverizer.SWAT_Pulverizer_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet05_MAT.swat_pulverizer.SWAT_Pulverizer_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet05_MAT.swat_pulverizer.SWAT_Pulverizer_3P_Pickup_MIC"))

//Human Popcorn Microwave Gun
	Skins.Add((Id=3990, Weapondef=class'KFWeapDef_MicrowaveGun', MIC_1P=("WEP_SkinSetPSN02_MAT.humanpopcorn_microwavegun.HumanPopcorn_MicrowaveGun_1P_Mint_MIC"), MIC_3P="WEP_SkinSetPSN02_MAT.humanpopcorn_microwavegun.HumanPopcorn_MicrowaveGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSetPSN02_MAT.humanpopcorn_microwavegun.HumanPopcorn_MicrowaveGun_3P_Pickup_MIC"))
	Skins.Add((Id=3989, Weapondef=class'KFWeapDef_MicrowaveGun', MIC_1P=("WEP_SkinSetPSN02_MAT.humanpopcorn_microwavegun.HumanPopcorn_MicrowaveGun_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSetPSN02_MAT.humanpopcorn_microwavegun.HumanPopcorn_MicrowaveGun_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSetPSN02_MAT.humanpopcorn_microwavegun.HumanPopcorn_MicrowaveGun_3P_Pickup_MIC"))
	Skins.Add((Id=3988, Weapondef=class'KFWeapDef_MicrowaveGun', MIC_1P=("WEP_SkinSetPSN02_MAT.humanpopcorn_microwavegun.HumanPopcorn_MicrowaveGun_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSetPSN02_MAT.humanpopcorn_microwavegun.HumanPopcorn_MicrowaveGun_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSetPSN02_MAT.humanpopcorn_microwavegun.HumanPopcorn_MicrowaveGun_3P_Pickup_MIC"))

//Clot Cola AA12
	Skins.Add((Id=3993, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSetPSN02_MAT.clotcola_aa12.ClotCola_AA12_1P_Mint_MIC"), MIC_3P="WEP_SkinSetPSN02_MAT.clotcola_aa12.ClotCola_AA12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSetPSN02_MAT.clotcola_aa12.ClotCola_AA12_3P_Pickup_MIC"))
	Skins.Add((Id=3992, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSetPSN02_MAT.clotcola_aa12.ClotCola_AA12_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSetPSN02_MAT.clotcola_aa12.ClotCola_AA12_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSetPSN02_MAT.clotcola_aa12.ClotCola_AA12_3P_Pickup_MIC"))
	Skins.Add((Id=3991, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSetPSN02_MAT.clotcola_aa12.ClotCola_AA12_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSetPSN02_MAT.clotcola_aa12.ClotCola_AA12_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSetPSN02_MAT.clotcola_aa12.ClotCola_AA12_3P_Pickup_MIC"))

//Junkyard Racer L85A2
	Skins.Add((Id=3996, Weapondef=class'KFWeapDef_Bullpup', MIC_1P=("WEP_SkinSetPSN02_MAT.junkyardracer_l85a2.JunkyardRacer_L85A2_1P_Mint_MIC"), MIC_3P="WEP_SkinSetPSN02_MAT.junkyardracer_l85a2.JunkyardRacer_L85A2_3P_Mint_MIC", MIC_Pickup="WEP_SkinSetPSN02_MAT.junkyardracer_l85a2.JunkyardRacer_L85A2_3P_Pickup_MIC"))
	Skins.Add((Id=3995, Weapondef=class'KFWeapDef_Bullpup', MIC_1P=("WEP_SkinSetPSN02_MAT.junkyardracer_l85a2.JunkyardRacer_L85A2_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSetPSN02_MAT.junkyardracer_l85a2.JunkyardRacer_L85A2_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSetPSN02_MAT.junkyardracer_l85a2.JunkyardRacer_L85A2_3P_Pickup_MIC"))
	Skins.Add((Id=3994, Weapondef=class'KFWeapDef_Bullpup', MIC_1P=("WEP_SkinSetPSN02_MAT.junkyardracer_l85a2.JunkyardRacer_L85A2_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSetPSN02_MAT.junkyardracer_l85a2.JunkyardRacer_L85A2_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSetPSN02_MAT.junkyardracer_l85a2.JunkyardRacer_L85A2_3P_Pickup_MIC"))

//Junkyard Racer Remington 1858
	Skins.Add((Id=3999, Weapondef=class'KFWeapDef_Remington1858', MIC_1P=("WEP_SkinSetPSN02_MAT.junkyardracer_remington1858.JunkyardRacer_Remington1858_1P_Mint_MIC"), MIC_3P="WEP_SkinSetPSN02_MAT.junkyardracer_remington1858.JunkyardRacer_Remington1858_3P_Mint_MIC", MIC_Pickup="WEP_SkinSetPSN02_MAT.junkyardracer_remington1858.JunkyardRacer_Remington1858_3P_Pickup_MIC"))
	Skins.Add((Id=3998, Weapondef=class'KFWeapDef_Remington1858', MIC_1P=("WEP_SkinSetPSN02_MAT.junkyardracer_remington1858.JunkyardRacer_Remington1858_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSetPSN02_MAT.junkyardracer_remington1858.JunkyardRacer_Remington1858_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSetPSN02_MAT.junkyardracer_remington1858.JunkyardRacer_Remington1858_3P_Pickup_MIC"))
	Skins.Add((Id=3997, Weapondef=class'KFWeapDef_Remington1858', MIC_1P=("WEP_SkinSetPSN02_MAT.junkyardracer_remington1858.JunkyardRacer_Remington1858_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSetPSN02_MAT.junkyardracer_remington1858.JunkyardRacer_Remington1858_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSetPSN02_MAT.junkyardracer_remington1858.JunkyardRacer_Remington1858_3P_Pickup_MIC"))

//Junkyard Racer Winchester 1894
	Skins.Add((Id=4002, Weapondef=class'KFWeapDef_Winchester1894', MIC_1P=("WEP_SkinSetPSN02_MAT.junkyardracer_winchester1894.JunkyardRacer_Winchester1894_1P_Mint_MIC"), MIC_3P="WEP_SkinSetPSN02_MAT.junkyardracer_winchester1894.JunkyardRacer_Winchester1894_3P_Mint_MIC", MIC_Pickup="WEP_SkinSetPSN02_MAT.junkyardracer_winchester1894.JunkyardRacer_Winchester1894_3P_Pickup_MIC"))
	Skins.Add((Id=4001, Weapondef=class'KFWeapDef_Winchester1894', MIC_1P=("WEP_SkinSetPSN02_MAT.junkyardracer_winchester1894.JunkyardRacer_Winchester1894_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSetPSN02_MAT.junkyardracer_winchester1894.JunkyardRacer_Winchester1894_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSetPSN02_MAT.junkyardracer_winchester1894.JunkyardRacer_Winchester1894_3P_Pickup_MIC"))
	Skins.Add((Id=4000, Weapondef=class'KFWeapDef_Winchester1894', MIC_1P=("WEP_SkinSetPSN02_MAT.junkyardracer_winchester1894.JunkyardRacer_Winchester1894_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSetPSN02_MAT.junkyardracer_winchester1894.JunkyardRacer_Winchester1894_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSetPSN02_MAT.junkyardracer_winchester1894.JunkyardRacer_Winchester1894_3P_Pickup_MIC"))

//Tripwire Gunner 9mm
	Skins.Add((Id=4005, Weapondef=class'KFWeapDef_9mm', MIC_1P=("WEP_SkinSetPSN02_MAT.tripwiregunner_9mm.TripwireGunner_9mm_1P_Mint_MIC"), MIC_3P="WEP_SkinSetPSN02_MAT.tripwiregunner_9mm.TripwireGunner_9mm_3P_Mint_MIC", MIC_Pickup="WEP_SkinSetPSN02_MAT.tripwiregunner_9mm.TripwireGunner_9mm_3P_Pickup_MIC"))
	Skins.Add((Id=4004, Weapondef=class'KFWeapDef_9mm', MIC_1P=("WEP_SkinSetPSN02_MAT.tripwiregunner_9mm.TripwireGunner_9mm_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSetPSN02_MAT.tripwiregunner_9mm.TripwireGunner_9mm_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSetPSN02_MAT.tripwiregunner_9mm.TripwireGunner_9mm_3P_Pickup_MIC"))
	Skins.Add((Id=4003, Weapondef=class'KFWeapDef_9mm', MIC_1P=("WEP_SkinSetPSN02_MAT.tripwiregunner_9mm.TripwireGunner_9mm_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSetPSN02_MAT.tripwiregunner_9mm.TripwireGunner_9mm_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSetPSN02_MAT.tripwiregunner_9mm.TripwireGunner_9mm_3P_Pickup_MIC"))

//Gunner Classic 9mm
	Skins.Add((Id=4008, Weapondef=class'KFWeapDef_9mm', MIC_1P=("WEP_SkinSetPSN02_MAT.gunnerclassic_9mm.GunnerClassic_9mm_1P_Mint_MIC"), MIC_3P="WEP_SkinSetPSN02_MAT.gunnerclassic_9mm.GunnerClassic_9mm_3P_Mint_MIC", MIC_Pickup="WEP_SkinSetPSN02_MAT.gunnerclassic_9mm.GunnerClassic_9mm_3P_Pickup_MIC"))
	Skins.Add((Id=4007, Weapondef=class'KFWeapDef_9mm', MIC_1P=("WEP_SkinSetPSN02_MAT.gunnerclassic_9mm.GunnerClassic_9mm_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSetPSN02_MAT.gunnerclassic_9mm.GunnerClassic_9mm_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSetPSN02_MAT.gunnerclassic_9mm.GunnerClassic_9mm_3P_Pickup_MIC"))
	Skins.Add((Id=4006, Weapondef=class'KFWeapDef_9mm', MIC_1P=("WEP_SkinSetPSN02_MAT.gunnerclassic_9mm.GunnerClassic_9mm_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSetPSN02_MAT.gunnerclassic_9mm.GunnerClassic_9mm_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSetPSN02_MAT.gunnerclassic_9mm.GunnerClassic_9mm_3P_Pickup_MIC"))

//Outmoded Healer
	Skins.Add((Id=4125, Weapondef=class'KFWeapDef_Healer', MIC_1P=("WEP_SkinSetPSN02_MAT.outmoded_healer.Outmoded_Healer_1P_Mint_MIC"), MIC_3P="WEP_SkinSetPSN02_MAT.outmoded_healer.Outmoded_Healer_3P_Mint_MIC", MIC_Pickup="WEP_SkinSetPSN02_MAT.outmoded_healer.Outmoded_Healer_3P_Pickup_MIC"))
	Skins.Add((Id=4124, Weapondef=class'KFWeapDef_Healer', MIC_1P=("WEP_SkinSetPSN02_MAT.outmoded_healer.Outmoded_Healer_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSetPSN02_MAT.outmoded_healer.Outmoded_Healer_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSetPSN02_MAT.outmoded_healer.Outmoded_Healer_3P_Pickup_MIC"))
	Skins.Add((Id=4123, Weapondef=class'KFWeapDef_Healer', MIC_1P=("WEP_SkinSetPSN02_MAT.outmoded_healer.Outmoded_Healer_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSetPSN02_MAT.outmoded_healer.Outmoded_Healer_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSetPSN02_MAT.outmoded_healer.Outmoded_Healer_3P_Pickup_MIC"))

//Victorian AA12
	Skins.Add((Id=4038, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet06_MAT.victorian_aa12.Victorian_AA12_1P_Mint_MIC"), MIC_3P="WEP_SkinSet06_MAT.victorian_aa12.Victorian_AA12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet06_MAT.victorian_aa12.Victorian_AA12_3P_Pickup_MIC"))
	Skins.Add((Id=4037, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet06_MAT.victorian_aa12.Victorian_AA12_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet06_MAT.victorian_aa12.Victorian_AA12_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet06_MAT.victorian_aa12.Victorian_AA12_3P_Pickup_MIC"))
	Skins.Add((Id=4036, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet06_MAT.victorian_aa12.Victorian_AA12_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet06_MAT.victorian_aa12.Victorian_AA12_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet06_MAT.victorian_aa12.Victorian_AA12_3P_Pickup_MIC"))

//Victorian Double Barrel
	Skins.Add((Id=4047, Weapondef=class'KFWeapDef_DoubleBarrel', MIC_1P=("WEP_SkinSet06_MAT.victorian_doublebarrel.Victorian_DoubleBarrel_1P_Mint_MIC"), MIC_3P="WEP_SkinSet06_MAT.victorian_doublebarrel.Victorian_DoubleBarrel_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet06_MAT.victorian_doublebarrel.Victorian_DoubleBarrel_3P_Pickup_MIC"))
 	Skins.Add((Id=4046, Weapondef=class'KFWeapDef_DoubleBarrel', MIC_1P=("WEP_SkinSet06_MAT.victorian_doublebarrel.Victorian_DoubleBarrel_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet06_MAT.victorian_doublebarrel.Victorian_DoubleBarrel_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet06_MAT.victorian_doublebarrel.Victorian_DoubleBarrel_3P_Pickup_MIC"))
	Skins.Add((Id=4045, Weapondef=class'KFWeapDef_DoubleBarrel', MIC_1P=("WEP_SkinSet06_MAT.victorian_doublebarrel.Victorian_DoubleBarrel_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet06_MAT.victorian_doublebarrel.Victorian_DoubleBarrel_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet06_MAT.victorian_doublebarrel.Victorian_DoubleBarrel_3P_Pickup_MIC"))

//Victorian M4
	Skins.Add((Id=4050, Weapondef=class'KFWeapDef_M4', MIC_1P=("WEP_SkinSet06_MAT.victorian_m4.Victorian_M4_1P_Mint_MIC"), MIC_3P="WEP_SkinSet06_MAT.victorian_m4.Victorian_M4_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet06_MAT.victorian_m4.Victorian_M4_3P_Pickup_MIC"))
	Skins.Add((Id=4049, Weapondef=class'KFWeapDef_M4', MIC_1P=("WEP_SkinSet06_MAT.victorian_m4.Victorian_M4_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet06_MAT.victorian_m4.Victorian_M4_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet06_MAT.victorian_m4.Victorian_M4_3P_Pickup_MIC"))
	Skins.Add((Id=4048, Weapondef=class'KFWeapDef_M4', MIC_1P=("WEP_SkinSet06_MAT.victorian_m4.Victorian_M4_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet06_MAT.victorian_m4.Victorian_M4_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet06_MAT.victorian_m4.Victorian_M4_3P_Pickup_MIC"))

//Victorian MB500
	Skins.Add((Id=4044, Weapondef=class'KFWeapDef_MB500', MIC_1P=("WEP_SkinSet06_MAT.victorian_mb500.Victorian_MB500_1P_Mint_MIC"), MIC_3P="WEP_SkinSet06_MAT.victorian_mb500.Victorian_MB500_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet06_MAT.victorian_mb500.Victorian_MB500_3P_Pickup_MIC"))
	Skins.Add((Id=4043, Weapondef=class'KFWeapDef_MB500', MIC_1P=("WEP_SkinSet06_MAT.victorian_mb500.Victorian_MB500_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet06_MAT.victorian_mb500.Victorian_MB500_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet06_MAT.victorian_mb500.Victorian_MB500_3P_Pickup_MIC"))
	Skins.Add((Id=4042, Weapondef=class'KFWeapDef_MB500', MIC_1P=("WEP_SkinSet06_MAT.victorian_mb500.Victorian_MB500_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet06_MAT.victorian_mb500.Victorian_MB500_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet06_MAT.victorian_mb500.Victorian_MB500_3P_Pickup_MIC"))

//Victorian Support Knife
	Skins.Add((Id=4041, Weapondef=class'KFWeapDef_Knife_Support', MIC_1P=("WEP_SkinSet06_MAT.victorian_supportknife.Victorian_SupportKnife_1P_Mint_MIC"), MIC_3P="WEP_SkinSet06_MAT.victorian_supportknife.Victorian_SupportKnife_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet06_MAT.victorian_supportknife.Victorian_SupportKnife_3P_Pickup_MIC"))
	Skins.Add((Id=4040, Weapondef=class'KFWeapDef_Knife_Support', MIC_1P=("WEP_SkinSet06_MAT.victorian_supportknife.Victorian_SupportKnife_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet06_MAT.victorian_supportknife.Victorian_SupportKnife_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet06_MAT.victorian_supportknife.Victorian_SupportKnife_3P_Pickup_MIC"))
	Skins.Add((Id=4039, Weapondef=class'KFWeapDef_Knife_Support', MIC_1P=("WEP_SkinSet06_MAT.victorian_supportknife.Victorian_SupportKnife_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet06_MAT.victorian_supportknife.Victorian_SupportKnife_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet06_MAT.victorian_supportknife.Victorian_SupportKnife_3P_Pickup_MIC"))

//Opulence SCAR
	Skins.Add((Id=4220, Weapondef=class'KFWeapDef_SCAR', MIC_1P=("WEP_SkinSet06_MAT.opulence_scar.Opulence_SCAR_1P_Mint_MIC"), MIC_3P="WEP_SkinSet06_MAT.opulence_scar.Opulence_SCAR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet06_MAT.opulence_scar.Opulence_SCAR_3P_Pickup_MIC"))
	Skins.Add((Id=4219, Weapondef=class'KFWeapDef_SCAR', MIC_1P=("WEP_SkinSet06_MAT.opulence_scar.Opulence_SCAR_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet06_MAT.opulence_scar.Opulence_SCAR_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet06_MAT.opulence_scar.Opulence_SCAR_3P_Pickup_MIC"))
	Skins.Add((Id=4218, Weapondef=class'KFWeapDef_SCAR', MIC_1P=("WEP_SkinSet06_MAT.opulence_scar.Opulence_SCAR_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet06_MAT.opulence_scar.Opulence_SCAR_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet06_MAT.opulence_scar.Opulence_SCAR_3P_Pickup_MIC"))

//Horzine Elite Blue 9mm
	Skins.Add((Id=4331, Weapondef=class'KFWeapDef_9mm', MIC_1P=("WEP_SkinSetEA01_MAT.horzineeliteblue_9mm.HorzineEliteBlue_9mm_1P_Mint_MIC"), MIC_3P="WEP_SkinSetEA01_MAT.horzineeliteblue_9mm.HorzineEliteBlue_9mm_3P_Mint_MIC", MIC_Pickup="WEP_SkinSetEA01_MAT.horzineeliteblue_9mm.HorzineEliteBlue_9mm_3P_Pickup_MIC"))

//Horzine Elite Green 9mm
	Skins.Add((Id=4334, Weapondef=class'KFWeapDef_9mm', MIC_1P=("WEP_SkinSetEA01_MAT.horzineelitegreen_9mm.HorzineEliteGreen_9mm_1P_Mint_MIC"), MIC_3P="WEP_SkinSetEA01_MAT.horzineelitegreen_9mm.HorzineEliteGreen_9mm_3P_Mint_MIC", MIC_Pickup="WEP_SkinSetEA01_MAT.horzineelitegreen_9mm.HorzineEliteGreen_9mm_3P_Pickup_MIC"))

//Horzine Elite Red 9mm
	Skins.Add((Id=4337, Weapondef=class'KFWeapDef_9mm', MIC_1P=("WEP_SkinSetEA01_MAT.horzineelitered_9mm.HorzineEliteRed_9mm_1P_Mint_MIC"), MIC_3P="WEP_SkinSetEA01_MAT.horzineelitered_9mm.HorzineEliteRed_9mm_3P_Mint_MIC", MIC_Pickup="WEP_SkinSetEA01_MAT.horzineelitered_9mm.HorzineEliteRed_9mm_3P_Pickup_MIC"))

//Horzine Elite White 9mm
	Skins.Add((Id=4340, Weapondef=class'KFWeapDef_9mm', MIC_1P=("WEP_SkinSetEA01_MAT.horzineelitewhite_9mm.HorzineEliteWhite_9mm_1P_Mint_MIC"), MIC_3P="WEP_SkinSetEA01_MAT.horzineelitewhite_9mm.HorzineEliteWhite_9mm_3P_Mint_MIC", MIC_Pickup="WEP_SkinSetEA01_MAT.horzineelitewhite_9mm.HorzineEliteWhite_9mm_3P_Pickup_MIC"))

//Horzine Elite Blue Deagle
	Skins.Add((Id=4384, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet07_MAT.horzineeliteblue_deagle.HorzineEliteBlue_Deagle_1P_Mint_MIC"), MIC_3P="WEP_SkinSet07_MAT.horzineeliteblue_deagle.HorzineEliteBlue_Deagle_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet07_MAT.horzineeliteblue_deagle.HorzineEliteBlue_Deagle_3P_Pickup_MIC"))
	Skins.Add((Id=4383, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet07_MAT.horzineeliteblue_deagle.HorzineEliteBlue_Deagle_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet07_MAT.horzineeliteblue_deagle.HorzineEliteBlue_Deagle_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet07_MAT.horzineeliteblue_deagle.HorzineEliteBlue_Deagle_3P_Pickup_MIC"))
	Skins.Add((Id=4382, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet07_MAT.horzineeliteblue_deagle.HorzineEliteBlue_Deagle_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet07_MAT.horzineeliteblue_deagle.HorzineEliteBlue_Deagle_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet07_MAT.horzineeliteblue_deagle.HorzineEliteBlue_Deagle_3P_Pickup_MIC"))

//Horzine Elite Green Deagle
	Skins.Add((Id=4387, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet07_MAT.horzineelitegreen_deagle.HorzineEliteGreen_Deagle_1P_Mint_MIC"), MIC_3P="WEP_SkinSet07_MAT.horzineelitegreen_deagle.HorzineEliteGreen_Deagle_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet07_MAT.horzineelitegreen_deagle.HorzineEliteGreen_Deagle_3P_Pickup_MIC"))
	Skins.Add((Id=4386, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet07_MAT.horzineelitegreen_deagle.HorzineEliteGreen_Deagle_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet07_MAT.horzineelitegreen_deagle.HorzineEliteGreen_Deagle_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet07_MAT.horzineelitegreen_deagle.HorzineEliteGreen_Deagle_3P_Pickup_MIC"))
	Skins.Add((Id=4385, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet07_MAT.horzineelitegreen_deagle.HorzineEliteGreen_Deagle_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet07_MAT.horzineelitegreen_deagle.HorzineEliteGreen_Deagle_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet07_MAT.horzineelitegreen_deagle.HorzineEliteGreen_Deagle_3P_Pickup_MIC"))

//Horzine Elite Red Deagle
	Skins.Add((Id=4390, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet07_MAT.horzineelitered_deagle.HorzineEliteRed_Deagle_1P_Mint_MIC"), MIC_3P="WEP_SkinSet07_MAT.horzineelitered_deagle.HorzineEliteRed_Deagle_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet07_MAT.horzineelitered_deagle.HorzineEliteRed_Deagle_3P_Pickup_MIC"))
	Skins.Add((Id=4389, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet07_MAT.horzineelitered_deagle.HorzineEliteRed_Deagle_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet07_MAT.horzineelitered_deagle.HorzineEliteRed_Deagle_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet07_MAT.horzineelitered_deagle.HorzineEliteRed_Deagle_3P_Pickup_MIC"))
	Skins.Add((Id=4388, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet07_MAT.horzineelitered_deagle.HorzineEliteRed_Deagle_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet07_MAT.horzineelitered_deagle.HorzineEliteRed_Deagle_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet07_MAT.horzineelitered_deagle.HorzineEliteRed_Deagle_3P_Pickup_MIC"))

//Horzine Elite White Deagle
	Skins.Add((Id=4393, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet07_MAT.horzineelitewhite_deagle.HorzineEliteWhite_Deagle_1P_Mint_MIC"), MIC_3P="WEP_SkinSet07_MAT.horzineelitewhite_deagle.HorzineEliteWhite_Deagle_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet07_MAT.horzineelitewhite_deagle.HorzineEliteWhite_Deagle_3P_Pickup_MIC"))
	Skins.Add((Id=4392, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet07_MAT.horzineelitewhite_deagle.HorzineEliteWhite_Deagle_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet07_MAT.horzineelitewhite_deagle.HorzineEliteWhite_Deagle_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet07_MAT.horzineelitewhite_deagle.HorzineEliteWhite_Deagle_3P_Pickup_MIC"))
	Skins.Add((Id=4391, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet07_MAT.horzineelitewhite_deagle.HorzineEliteWhite_Deagle_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet07_MAT.horzineelitewhite_deagle.HorzineEliteWhite_Deagle_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet07_MAT.horzineelitewhite_deagle.HorzineEliteWhite_Deagle_3P_Pickup_MIC"))

//Tactical AA12
	Skins.Add((Id=4460, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet07_MAT.tactical_aa12.Tactical_AA12_1P_Mint_MIC"), MIC_3P="WEP_SkinSet07_MAT.tactical_aa12.Tactical_AA12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet07_MAT.tactical_aa12.Tactical_AA12_3P_Pickup_MIC"))
 	Skins.Add((Id=4459, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet07_MAT.tactical_aa12.Tactical_AA12_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet07_MAT.tactical_aa12.Tactical_AA12_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet07_MAT.tactical_aa12.Tactical_AA12_3P_Pickup_MIC"))
	Skins.Add((Id=4458, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet07_MAT.tactical_aa12.Tactical_AA12_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet07_MAT.tactical_aa12.Tactical_AA12_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet07_MAT.tactical_aa12.Tactical_AA12_3P_Pickup_MIC"))

//Tactical AK12
	Skins.Add((Id=4463, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet07_MAT.tactical_ak12.Tactical_AK12_1P_Mint_MIC", "WEP_SkinSet07_MAT.tactical_ak12.Tactical_AK12_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet07_MAT.tactical_ak12.Tactical_AK12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet07_MAT.tactical_ak12.Tactical_AK12_3P_Pickup_MIC"))
	Skins.Add((Id=4462, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet07_MAT.tactical_ak12.Tactical_AK12_1P_FieldTested_MIC", "WEP_SkinSet07_MAT.tactical_ak12.Tactical_AK12_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet07_MAT.tactical_ak12.Tactical_AK12_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet07_MAT.tactical_ak12.Tactical_AK12_3P_Pickup_MIC"))
	Skins.Add((Id=4461, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet07_MAT.tactical_ak12.Tactical_AK12_1P_BattleScarred_MIC", "WEP_SkinSet07_MAT.tactical_ak12.Tactical_AK12_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet07_MAT.tactical_ak12.Tactical_AK12_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet07_MAT.tactical_ak12.Tactical_AK12_3P_Pickup_MIC"))

//Tactical L85A2
	Skins.Add((Id=4466, Weapondef=class'KFWeapDef_Bullpup', MIC_1P=("WEP_SkinSet07_MAT.tactical_l85a2.Tactical_L85A2_1P_Mint_MIC", "WEP_SkinSet07_MAT.tactical_l85a2.Tactical_L85A2_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet07_MAT.tactical_l85a2.Tactical_L85A2_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet07_MAT.tactical_l85a2.Tactical_L85A2_3P_Pickup_MIC"))
	Skins.Add((Id=4465, Weapondef=class'KFWeapDef_Bullpup', MIC_1P=("WEP_SkinSet07_MAT.tactical_l85a2.Tactical_L85A2_1P_FieldTested_MIC", "WEP_SkinSet07_MAT.tactical_l85a2.Tactical_L85A2_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet07_MAT.tactical_l85a2.Tactical_L85A2_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet07_MAT.tactical_l85a2.Tactical_L85A2_3P_Pickup_MIC"))
	Skins.Add((Id=4464, Weapondef=class'KFWeapDef_Bullpup', MIC_1P=("WEP_SkinSet07_MAT.tactical_l85a2.Tactical_L85A2_1P_BattleScarred_MIC", "WEP_SkinSet07_MAT.tactical_l85a2.Tactical_L85A2_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet07_MAT.tactical_l85a2.Tactical_L85A2_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet07_MAT.tactical_l85a2.Tactical_L85A2_3P_Pickup_MIC"))

//Tactical MB500
	Skins.Add((Id=4469, Weapondef=class'KFWeapDef_MB500', MIC_1P=("WEP_SkinSet07_MAT.tactical_mb500.Tactical_MB500_1P_Mint_MIC"), MIC_3P="WEP_SkinSet07_MAT.tactical_mb500.Tactical_MB500_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet07_MAT.tactical_mb500.Tactical_MB500_3P_Pickup_MIC"))
	Skins.Add((Id=4468, Weapondef=class'KFWeapDef_MB500', MIC_1P=("WEP_SkinSet07_MAT.tactical_mb500.Tactical_MB500_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet07_MAT.tactical_mb500.Tactical_MB500_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet07_MAT.tactical_mb500.Tactical_MB500_3P_Pickup_MIC"))
	Skins.Add((Id=4467, Weapondef=class'KFWeapDef_MB500', MIC_1P=("WEP_SkinSet07_MAT.tactical_mb500.Tactical_MB500_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet07_MAT.tactical_mb500.Tactical_MB500_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet07_MAT.tactical_mb500.Tactical_MB500_3P_Pickup_MIC"))

//Tactical Medic Assault
	Skins.Add((Id=4472, Weapondef=class'KFWeapDef_MedicRifle', MIC_1P=("WEP_SkinSet07_MAT.tactical_medicassault.Tactical_MedicAssault_1P_Mint_MIC", "WEP_SkinSet07_MAT.tactical_medicassault.Tactical_MedicPistol_1P_Mint_MIC"), MIC_3P="WEP_SkinSet07_MAT.tactical_medicassault.Tactical_MedicAssault_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet07_MAT.tactical_medicassault.Tactical_MedicAssault_3P_Pickup_MIC"))
	Skins.Add((Id=4471, Weapondef=class'KFWeapDef_MedicRifle', MIC_1P=("WEP_SkinSet07_MAT.tactical_medicassault.Tactical_MedicAssault_1P_FieldTested_MIC", "WEP_SkinSet07_MAT.tactical_medicassault.Tactical_MedicPistol_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet07_MAT.tactical_medicassault.Tactical_MedicAssault_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet07_MAT.tactical_medicassault.Tactical_MedicAssault_3P_Pickup_MIC"))
	Skins.Add((Id=4470, Weapondef=class'KFWeapDef_MedicRifle', MIC_1P=("WEP_SkinSet07_MAT.tactical_medicassault.Tactical_MedicAssault_1P_BattleScarred_MIC", "WEP_SkinSet07_MAT.tactical_medicassault.Tactical_MedicPistol_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet07_MAT.tactical_medicassault.Tactical_MedicAssault_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet07_MAT.tactical_medicassault.Tactical_MedicAssault_3P_Pickup_MIC"))

//Tactical SCAR
	Skins.Add((Id=4475, Weapondef=class'KFWeapDef_SCAR', MIC_1P=("WEP_SkinSet07_MAT.tactical_scar.Tactical_SCAR_1P_Mint_MIC", "WEP_SkinSet07_MAT.tactical_scar.Tactical_SCAR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet07_MAT.tactical_scar.Tactical_SCAR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet07_MAT.tactical_scar.Tactical_SCAR_3P_Pickup_MIC"))
	Skins.Add((Id=4474, Weapondef=class'KFWeapDef_SCAR', MIC_1P=("WEP_SkinSet07_MAT.tactical_scar.Tactical_SCAR_1P_FieldTested_MIC", "WEP_SkinSet07_MAT.tactical_scar.Tactical_SCAR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet07_MAT.tactical_scar.Tactical_SCAR_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet07_MAT.tactical_scar.Tactical_SCAR_3P_Pickup_MIC"))
	Skins.Add((Id=4473, Weapondef=class'KFWeapDef_SCAR', MIC_1P=("WEP_SkinSet07_MAT.tactical_scar.Tactical_SCAR_1P_BattleScarred_MIC", "WEP_SkinSet07_MAT.tactical_scar.Tactical_SCAR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet07_MAT.tactical_scar.Tactical_SCAR_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet07_MAT.tactical_scar.Tactical_SCAR_3P_Pickup_MIC"))

//Circuit Mace and Shield
	Skins.Add((Id=4544, Weapondef=class'KFWeapDef_MaceAndShield', MIC_1P=("WEP_SkinSet08_MAT.circuit_maceshield.Circuit_Mace_1P_Mint_MIC", "WEP_SkinSet08_MAT.circuit_maceshield.Circuit_Shield_1P_Mint_MIC"), MIC_3P="WEP_SkinSet08_MAT.circuit_maceshield.Circuit_MaceShield_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet08_MAT.circuit_maceshield.Circuit_MaceShield_3P_Pickup_MIC"))
	Skins.Add((Id=4543, Weapondef=class'KFWeapDef_MaceAndShield', MIC_1P=("WEP_SkinSet08_MAT.circuit_maceshield.Circuit_Mace_1P_FieldTested_MIC", "WEP_SkinSet08_MAT.circuit_maceshield.Circuit_Shield_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet08_MAT.circuit_maceshield.Circuit_MaceShield_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet08_MAT.circuit_maceshield.Circuit_MaceShield_3P_Pickup_MIC"))
	Skins.Add((Id=4542, Weapondef=class'KFWeapDef_MaceAndShield', MIC_1P=("WEP_SkinSet08_MAT.circuit_maceshield.Circuit_Mace_1P_BattleScarred_MIC", "WEP_SkinSet08_MAT.circuit_maceshield.Circuit_Shield_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet08_MAT.circuit_maceshield.Circuit_MaceShield_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet08_MAT.circuit_maceshield.Circuit_MaceShield_3P_Pickup_MIC"))

//USA Mace and Shield
	Skins.Add((Id=4547, Weapondef=class'KFWeapDef_MaceAndShield', MIC_1P=("WEP_SkinSet08_MAT.usa_maceshield.USA_Mace_1P_Mint_MIC", "WEP_SkinSet08_MAT.usa_maceshield.USA_Shield_1P_Mint_MIC"), MIC_3P="WEP_SkinSet08_MAT.usa_maceshield.USA_MaceShield_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet08_MAT.usa_maceshield.USA_MaceShield_3P_Pickup_MIC"))
	Skins.Add((Id=4546, Weapondef=class'KFWeapDef_MaceAndShield', MIC_1P=("WEP_SkinSet08_MAT.usa_maceshield.USA_Mace_1P_FieldTested_MIC", "WEP_SkinSet08_MAT.usa_maceshield.USA_Shield_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet08_MAT.usa_maceshield.USA_MaceShield_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet08_MAT.usa_maceshield.USA_MaceShield_3P_Pickup_MIC"))
	Skins.Add((Id=4545, Weapondef=class'KFWeapDef_MaceAndShield', MIC_1P=("WEP_SkinSet08_MAT.usa_maceshield.USA_Mace_1P_BattleScarred_MIC", "WEP_SkinSet08_MAT.usa_maceshield.USA_Shield_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet08_MAT.usa_maceshield.USA_MaceShield_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet08_MAT.usa_maceshield.USA_MaceShield_3P_Pickup_MIC"))

//Zed Hazard Mace and Shield
	Skins.Add((Id=4550, Weapondef=class'KFWeapDef_MaceAndShield', MIC_1P=("WEP_SkinSet08_MAT.zedhazard_maceshield.ZedHazard_Mace_1P_Mint_MIC", "WEP_SkinSet08_MAT.zedhazard_maceshield.ZedHazard_Shield_1P_Mint_MIC"), MIC_3P="WEP_SkinSet08_MAT.zedhazard_maceshield.ZedHazard_MaceShield_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet08_MAT.zedhazard_maceshield.ZedHazard_MaceShield_3P_Pickup_MIC"))
	Skins.Add((Id=4549, Weapondef=class'KFWeapDef_MaceAndShield', MIC_1P=("WEP_SkinSet08_MAT.zedhazard_maceshield.ZedHazard_Mace_1P_FieldTested_MIC", "WEP_SkinSet08_MAT.zedhazard_maceshield.ZedHazard_Shield_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet08_MAT.zedhazard_maceshield.ZedHazard_MaceShield_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet08_MAT.zedhazard_maceshield.ZedHazard_MaceShield_3P_Pickup_MIC"))
	Skins.Add((Id=4548, Weapondef=class'KFWeapDef_MaceAndShield', MIC_1P=("WEP_SkinSet08_MAT.zedhazard_maceshield.ZedHazard_Mace_1P_BattleScarred_MIC", "WEP_SkinSet08_MAT.zedhazard_maceshield.ZedHazard_Shield_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet08_MAT.zedhazard_maceshield.ZedHazard_MaceShield_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet08_MAT.zedhazard_maceshield.ZedHazard_MaceShield_3P_Pickup_MIC"))

//Warning Mace and Shield
	Skins.Add((Id=4553, Weapondef=class'KFWeapDef_MaceAndShield', MIC_1P=("WEP_SkinSet08_MAT.warning_maceshield.Warning_Mace_1P_Mint_MIC", "WEP_SkinSet08_MAT.warning_maceshield.Warning_Shield_1P_Mint_MIC"), MIC_3P="WEP_SkinSet08_MAT.warning_maceshield.Warning_MaceShield_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet08_MAT.warning_maceshield.Warning_MaceShield_3P_Pickup_MIC"))
	Skins.Add((Id=4552, Weapondef=class'KFWeapDef_MaceAndShield', MIC_1P=("WEP_SkinSet08_MAT.warning_maceshield.Warning_Mace_1P_FieldTested_MIC", "WEP_SkinSet08_MAT.warning_maceshield.Warning_Shield_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet08_MAT.warning_maceshield.Warning_MaceShield_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet08_MAT.warning_maceshield.Warning_MaceShield_3P_Pickup_MIC"))
	Skins.Add((Id=4551, Weapondef=class'KFWeapDef_MaceAndShield', MIC_1P=("WEP_SkinSet08_MAT.warning_maceshield.Warning_Mace_1P_BattleScarred_MIC", "WEP_SkinSet08_MAT.warning_maceshield.Warning_Shield_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet08_MAT.warning_maceshield.Warning_MaceShield_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet08_MAT.warning_maceshield.Warning_MaceShield_3P_Pickup_MIC"))

//Batcat Mace and Shield
	Skins.Add((Id=4556, Weapondef=class'KFWeapDef_MaceAndShield', MIC_1P=("WEP_SkinSet08_MAT.batcat_maceshield.Batcat_Mace_1P_Mint_MIC", "WEP_SkinSet08_MAT.batcat_maceshield.Batcat_Shield_1P_Mint_MIC"), MIC_3P="WEP_SkinSet08_MAT.batcat_maceshield.Batcat_MaceShield_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet08_MAT.batcat_maceshield.Batcat_MaceShield_3P_Pickup_MIC"))
	Skins.Add((Id=4555, Weapondef=class'KFWeapDef_MaceAndShield', MIC_1P=("WEP_SkinSet08_MAT.batcat_maceshield.Batcat_Mace_1P_FieldTested_MIC", "WEP_SkinSet08_MAT.batcat_maceshield.Batcat_Shield_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet08_MAT.batcat_maceshield.Batcat_MaceShield_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet08_MAT.batcat_maceshield.Batcat_MaceShield_3P_Pickup_MIC"))
	Skins.Add((Id=4554, Weapondef=class'KFWeapDef_MaceAndShield', MIC_1P=("WEP_SkinSet08_MAT.batcat_maceshield.Batcat_Mace_1P_BattleScarred_MIC", "WEP_SkinSet08_MAT.batcat_maceshield.Batcat_Shield_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet08_MAT.batcat_maceshield.Batcat_MaceShield_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet08_MAT.batcat_maceshield.Batcat_MaceShield_3P_Pickup_MIC"))

//Guillotine Mace and Shield
	Skins.Add((Id=4559, Weapondef=class'KFWeapDef_MaceAndShield', MIC_1P=("WEP_SkinSet08_MAT.guillotine_maceshield.Guillotine_Mace_1P_Mint_MIC", "WEP_SkinSet08_MAT.guillotine_maceshield.Guillotine_Shield_1P_Mint_MIC"), MIC_3P="WEP_SkinSet08_MAT.guillotine_maceshield.Guillotine_MaceShield_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet08_MAT.guillotine_maceshield.Guillotine_MaceShield_3P_Pickup_MIC"))
	Skins.Add((Id=4558, Weapondef=class'KFWeapDef_MaceAndShield', MIC_1P=("WEP_SkinSet08_MAT.guillotine_maceshield.Guillotine_Mace_1P_FieldTested_MIC", "WEP_SkinSet08_MAT.guillotine_maceshield.Guillotine_Shield_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet08_MAT.guillotine_maceshield.Guillotine_MaceShield_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet08_MAT.guillotine_maceshield.Guillotine_MaceShield_3P_Pickup_MIC"))
	Skins.Add((Id=4557, Weapondef=class'KFWeapDef_MaceAndShield', MIC_1P=("WEP_SkinSet08_MAT.guillotine_maceshield.Guillotine_Mace_1P_BattleScarred_MIC", "WEP_SkinSet08_MAT.guillotine_maceshield.Guillotine_Shield_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet08_MAT.guillotine_maceshield.Guillotine_MaceShield_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet08_MAT.guillotine_maceshield.Guillotine_MaceShield_3P_Pickup_MIC"))

//Deepstrike 9mm
	Skins.Add((Id=4359, Weapondef=class'KFWeapDef_9mm', MIC_1P=("WEP_SkinSet09_MAT.deepstrike_9mm.Deepstrike_9mm_1P_Mint_MIC"), MIC_3P="WEP_SkinSet09_MAT.deepstrike_9mm.Deepstrike_9mm_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet09_MAT.deepstrike_9mm.Deepstrike_9mm_3P_Pickup_MIC"))
 	Skins.Add((Id=4358, Weapondef=class'KFWeapDef_9mm', MIC_1P=("WEP_SkinSet09_MAT.deepstrike_9mm.Deepstrike_9mm_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet09_MAT.deepstrike_9mm.Deepstrike_9mm_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet09_MAT.deepstrike_9mm.Deepstrike_9mm_3P_Pickup_MIC"))
	Skins.Add((Id=4357, Weapondef=class'KFWeapDef_9mm', MIC_1P=("WEP_SkinSet09_MAT.deepstrike_9mm.Deepstrike_9mm_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet09_MAT.deepstrike_9mm.Deepstrike_9mm_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet09_MAT.deepstrike_9mm.Deepstrike_9mm_3P_Pickup_MIC"))

//Deepstrike Crossbow
	Skins.Add((Id=4362, Weapondef=class'KFWeapDef_Crossbow', MIC_1P=("WEP_SkinSet09_MAT.deepstrike_crossbow.Deepstrike_Crossbow_1P_Mint_MIC", "WEP_SkinSet09_MAT.deepstrike_crossbow.Deepstrike_Crossbow_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet09_MAT.deepstrike_crossbow.Deepstrike_Crossbow_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet09_MAT.deepstrike_crossbow.Deepstrike_Crossbow_3P_Pickup_MIC"))
 	Skins.Add((Id=4361, Weapondef=class'KFWeapDef_Crossbow', MIC_1P=("WEP_SkinSet09_MAT.deepstrike_crossbow.Deepstrike_Crossbow_1P_FieldTested_MIC", "WEP_SkinSet09_MAT.deepstrike_crossbow.Deepstrike_Crossbow_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet09_MAT.deepstrike_crossbow.Deepstrike_Crossbow_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet09_MAT.deepstrike_crossbow.Deepstrike_Crossbow_3P_Pickup_MIC"))
	Skins.Add((Id=4360, Weapondef=class'KFWeapDef_Crossbow', MIC_1P=("WEP_SkinSet09_MAT.deepstrike_crossbow.Deepstrike_Crossbow_1P_BattleScarred_MIC", "WEP_SkinSet09_MAT.deepstrike_crossbow.Deepstrike_Crossbow_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet09_MAT.deepstrike_crossbow.Deepstrike_Crossbow_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet09_MAT.deepstrike_crossbow.Deepstrike_Crossbow_3P_Pickup_MIC"))

//Deepstrike Desert Eagle
	Skins.Add((Id=4365, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet09_MAT.deepstrike_deagle.Deepstrike_Deagle_1P_Mint_MIC"), MIC_3P="WEP_SkinSet09_MAT.deepstrike_deagle.Deepstrike_Deagle_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet09_MAT.deepstrike_deagle.Deepstrike_Deagle_3P_Pickup_MIC"))
 	Skins.Add((Id=4364, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet09_MAT.deepstrike_deagle.Deepstrike_Deagle_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet09_MAT.deepstrike_deagle.Deepstrike_Deagle_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet09_MAT.deepstrike_deagle.Deepstrike_Deagle_3P_Pickup_MIC"))
	Skins.Add((Id=4363, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet09_MAT.deepstrike_deagle.Deepstrike_Deagle_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet09_MAT.deepstrike_deagle.Deepstrike_Deagle_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet09_MAT.deepstrike_deagle.Deepstrike_Deagle_3P_Pickup_MIC"))

//Deepstrike Winchester 1894
	Skins.Add((Id=4368, Weapondef=class'KFWeapDef_Winchester1894', MIC_1P=("WEP_SkinSet09_MAT.deepstrike_lar.Deepstrike_LAR_1P_Mint_MIC"), MIC_3P="WEP_SkinSet09_MAT.deepstrike_lar.Deepstrike_LAR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet09_MAT.deepstrike_lar.Deepstrike_LAR_3P_Pickup_MIC"))
 	Skins.Add((Id=4367, Weapondef=class'KFWeapDef_Winchester1894', MIC_1P=("WEP_SkinSet09_MAT.deepstrike_lar.Deepstrike_LAR_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet09_MAT.deepstrike_lar.Deepstrike_LAR_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet09_MAT.deepstrike_lar.Deepstrike_LAR_3P_Pickup_MIC"))
	Skins.Add((Id=4366, Weapondef=class'KFWeapDef_Winchester1894', MIC_1P=("WEP_SkinSet09_MAT.deepstrike_lar.Deepstrike_LAR_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet09_MAT.deepstrike_lar.Deepstrike_LAR_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet09_MAT.deepstrike_lar.Deepstrike_LAR_3P_Pickup_MIC"))

//Deepstrike M79
	Skins.Add((Id=4371, Weapondef=class'KFWeapDef_M79', MIC_1P=("WEP_SkinSet09_MAT.deepstrike_m79.Deepstrike_M79_1P_Mint_MIC"), MIC_3P="WEP_SkinSet09_MAT.deepstrike_m79.Deepstrike_M79_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet09_MAT.deepstrike_m79.Deepstrike_M79_3P_Pickup_MIC"))
 	Skins.Add((Id=4370, Weapondef=class'KFWeapDef_M79', MIC_1P=("WEP_SkinSet09_MAT.deepstrike_m79.Deepstrike_M79_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet09_MAT.deepstrike_m79.Deepstrike_M79_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet09_MAT.deepstrike_m79.Deepstrike_M79_3P_Pickup_MIC"))
	Skins.Add((Id=4369, Weapondef=class'KFWeapDef_M79', MIC_1P=("WEP_SkinSet09_MAT.deepstrike_m79.Deepstrike_M79_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet09_MAT.deepstrike_m79.Deepstrike_M79_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet09_MAT.deepstrike_m79.Deepstrike_M79_3P_Pickup_MIC"))

//Deepstrike RPG7
	Skins.Add((Id=4374, Weapondef=class'KFWeapDef_RPG7', MIC_1P=("WEP_SkinSet09_MAT.deepstrike_rpg7.Deepstrike_RPG7_1P_Mint_MIC"), MIC_3P="WEP_SkinSet09_MAT.deepstrike_rpg7.Deepstrike_RPG7_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet09_MAT.deepstrike_rpg7.Deepstrike_RPG7_3P_Pickup_MIC"))
 	Skins.Add((Id=4373, Weapondef=class'KFWeapDef_RPG7', MIC_1P=("WEP_SkinSet09_MAT.deepstrike_rpg7.Deepstrike_RPG7_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet09_MAT.deepstrike_rpg7.Deepstrike_RPG7_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet09_MAT.deepstrike_rpg7.Deepstrike_RPG7_3P_Pickup_MIC"))
	Skins.Add((Id=4372, Weapondef=class'KFWeapDef_RPG7', MIC_1P=("WEP_SkinSet09_MAT.deepstrike_rpg7.Deepstrike_RPG7_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet09_MAT.deepstrike_rpg7.Deepstrike_RPG7_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet09_MAT.deepstrike_rpg7.Deepstrike_RPG7_3P_Pickup_MIC"))

//Deepstrike SCAR
	Skins.Add((Id=4377, Weapondef=class'KFWeapDef_SCAR', MIC_1P=("WEP_SkinSet09_MAT.deepstrike_scar.Deepstrike_SCAR_1P_Mint_MIC", "WEP_SkinSet09_MAT.deepstrike_scar.Deepstrike_SCAR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet09_MAT.deepstrike_scar.Deepstrike_SCAR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet09_MAT.deepstrike_scar.Deepstrike_SCAR_3P_Pickup_MIC"))
 	Skins.Add((Id=4376, Weapondef=class'KFWeapDef_SCAR', MIC_1P=("WEP_SkinSet09_MAT.deepstrike_scar.Deepstrike_SCAR_1P_FieldTested_MIC", "WEP_SkinSet09_MAT.deepstrike_scar.Deepstrike_SCAR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet09_MAT.deepstrike_scar.Deepstrike_SCAR_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet09_MAT.deepstrike_scar.Deepstrike_SCAR_3P_Pickup_MIC"))
	Skins.Add((Id=4375, Weapondef=class'KFWeapDef_SCAR', MIC_1P=("WEP_SkinSet09_MAT.deepstrike_scar.Deepstrike_SCAR_1P_BattleScarred_MIC", "WEP_SkinSet09_MAT.deepstrike_scar.Deepstrike_SCAR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet09_MAT.deepstrike_scar.Deepstrike_SCAR_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet09_MAT.deepstrike_scar.Deepstrike_SCAR_3P_Pickup_MIC"))

//Horzine Elite Blue Kriss
	Skins.Add((Id=4572, Weapondef=class'KFWeapDef_Kriss', MIC_1P=("WEP_SkinSet09_MAT.horzineeliteblue_kriss.HorzineEliteBlue_Kriss_1P_Mint_MIC", "WEP_SkinSet09_MAT.horzineeliteblue_kriss.HorzineEliteBlue_Kriss_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet09_MAT.horzineeliteblue_kriss.HorzineEliteBlue_Kriss_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet09_MAT.horzineeliteblue_kriss.HorzineEliteBlue_Kriss_3P_Pickup_MIC"))
 	Skins.Add((Id=4571, Weapondef=class'KFWeapDef_Kriss', MIC_1P=("WEP_SkinSet09_MAT.horzineeliteblue_kriss.HorzineEliteBlue_Kriss_1P_FieldTested_MIC", "WEP_SkinSet09_MAT.horzineeliteblue_kriss.HorzineEliteBlue_Kriss_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet09_MAT.horzineeliteblue_kriss.HorzineEliteBlue_Kriss_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet09_MAT.horzineeliteblue_kriss.HorzineEliteBlue_Kriss_3P_Pickup_MIC"))
	Skins.Add((Id=4570, Weapondef=class'KFWeapDef_Kriss', MIC_1P=("WEP_SkinSet09_MAT.horzineeliteblue_kriss.HorzineEliteBlue_Kriss_1P_BattleScarred_MIC", "WEP_SkinSet09_MAT.horzineeliteblue_kriss.HorzineEliteBlue_Kriss_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet09_MAT.horzineeliteblue_kriss.HorzineEliteBlue_Kriss_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet09_MAT.horzineeliteblue_kriss.HorzineEliteBlue_Kriss_3P_Pickup_MIC"))

//Horzine Elite Green Kriss
	Skins.Add((Id=4575, Weapondef=class'KFWeapDef_Kriss', MIC_1P=("WEP_SkinSet09_MAT.horzineelitegreen_kriss.HorzineEliteGreen_Kriss_1P_Mint_MIC", "WEP_SkinSet09_MAT.horzineelitegreen_kriss.HorzineEliteGreen_Kriss_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet09_MAT.horzineelitegreen_kriss.HorzineEliteGreen_Kriss_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet09_MAT.horzineelitegreen_kriss.HorzineEliteGreen_Kriss_3P_Pickup_MIC"))
 	Skins.Add((Id=4574, Weapondef=class'KFWeapDef_Kriss', MIC_1P=("WEP_SkinSet09_MAT.horzineelitegreen_kriss.HorzineEliteGreen_Kriss_1P_FieldTested_MIC", "WEP_SkinSet09_MAT.horzineelitegreen_kriss.HorzineEliteGreen_Kriss_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet09_MAT.horzineelitegreen_kriss.HorzineEliteGreen_Kriss_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet09_MAT.horzineelitegreen_kriss.HorzineEliteGreen_Kriss_3P_Pickup_MIC"))
	Skins.Add((Id=4573, Weapondef=class'KFWeapDef_Kriss', MIC_1P=("WEP_SkinSet09_MAT.horzineelitegreen_kriss.HorzineEliteGreen_Kriss_1P_BattleScarred_MIC", "WEP_SkinSet09_MAT.horzineelitegreen_kriss.HorzineEliteGreen_Kriss_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet09_MAT.horzineelitegreen_kriss.HorzineEliteGreen_Kriss_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet09_MAT.horzineelitegreen_kriss.HorzineEliteGreen_Kriss_3P_Pickup_MIC"))

//Horzine Elite Red Kriss
	Skins.Add((Id=4578, Weapondef=class'KFWeapDef_Kriss', MIC_1P=("WEP_SkinSet09_MAT.horzineelitered_kriss.HorzineEliteRed_Kriss_1P_Mint_MIC", "WEP_SkinSet09_MAT.horzineelitered_kriss.HorzineEliteRed_Kriss_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet09_MAT.horzineelitered_kriss.HorzineEliteRed_Kriss_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet09_MAT.horzineelitered_kriss.HorzineEliteRed_Kriss_3P_Pickup_MIC"))
 	Skins.Add((Id=4577, Weapondef=class'KFWeapDef_Kriss', MIC_1P=("WEP_SkinSet09_MAT.horzineelitered_kriss.HorzineEliteRed_Kriss_1P_FieldTested_MIC", "WEP_SkinSet09_MAT.horzineelitered_kriss.HorzineEliteRed_Kriss_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet09_MAT.horzineelitered_kriss.HorzineEliteRed_Kriss_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet09_MAT.horzineelitered_kriss.HorzineEliteRed_Kriss_3P_Pickup_MIC"))
	Skins.Add((Id=4576, Weapondef=class'KFWeapDef_Kriss', MIC_1P=("WEP_SkinSet09_MAT.horzineelitered_kriss.HorzineEliteRed_Kriss_1P_BattleScarred_MIC", "WEP_SkinSet09_MAT.horzineelitered_kriss.HorzineEliteRed_Kriss_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet09_MAT.horzineelitered_kriss.HorzineEliteRed_Kriss_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet09_MAT.horzineelitered_kriss.HorzineEliteRed_Kriss_3P_Pickup_MIC"))

//Horzine Elite White Kriss
	Skins.Add((Id=4581, Weapondef=class'KFWeapDef_Kriss', MIC_1P=("WEP_SkinSet09_MAT.horzineelitewhite_kriss.HorzineEliteWhite_Kriss_1P_Mint_MIC", "WEP_SkinSet09_MAT.horzineelitewhite_kriss.HorzineEliteWhite_Kriss_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet09_MAT.horzineelitewhite_kriss.HorzineEliteWhite_Kriss_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet09_MAT.horzineelitewhite_kriss.HorzineEliteWhite_Kriss_3P_Pickup_MIC"))
 	Skins.Add((Id=4580, Weapondef=class'KFWeapDef_Kriss', MIC_1P=("WEP_SkinSet09_MAT.horzineelitewhite_kriss.HorzineEliteWhite_Kriss_1P_FieldTested_MIC", "WEP_SkinSet09_MAT.horzineelitewhite_kriss.HorzineEliteWhite_Kriss_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet09_MAT.horzineelitewhite_kriss.HorzineEliteWhite_Kriss_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet09_MAT.horzineelitewhite_kriss.HorzineEliteWhite_Kriss_3P_Pickup_MIC"))
	Skins.Add((Id=4579, Weapondef=class'KFWeapDef_Kriss', MIC_1P=("WEP_SkinSet09_MAT.horzineelitewhite_kriss.HorzineEliteWhite_Kriss_1P_BattleScarred_MIC", "WEP_SkinSet09_MAT.horzineelitewhite_kriss.HorzineEliteWhite_Kriss_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet09_MAT.horzineelitewhite_kriss.HorzineEliteWhite_Kriss_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet09_MAT.horzineelitewhite_kriss.HorzineEliteWhite_Kriss_3P_Pickup_MIC"))

//Industrial Crossbow
	Skins.Add((Id=4720, Weapondef=class'KFWeapDef_Crossbow', MIC_1P=("WEP_SkinSet10_MAT.industrial_crossbow.Industrial_Crossbow_1P_Mint_MIC", "WEP_SkinSet10_MAT.industrial_crossbow.Industrial_Crossbow_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet10_MAT.industrial_crossbow.Industrial_Crossbow_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet10_MAT.industrial_crossbow.Industrial_Crossbow_3P_Pickup_MIC"))
 	Skins.Add((Id=4719, Weapondef=class'KFWeapDef_Crossbow', MIC_1P=("WEP_SkinSet10_MAT.industrial_crossbow.Industrial_Crossbow_1P_FieldTested_MIC", "WEP_SkinSet10_MAT.industrial_crossbow.Industrial_Crossbow_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet10_MAT.industrial_crossbow.Industrial_Crossbow_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet10_MAT.industrial_crossbow.Industrial_Crossbow_3P_Pickup_MIC"))
	Skins.Add((Id=4718, Weapondef=class'KFWeapDef_Crossbow', MIC_1P=("WEP_SkinSet10_MAT.industrial_crossbow.Industrial_Crossbow_1P_BattleScarred_MIC", "WEP_SkinSet10_MAT.industrial_crossbow.Industrial_Crossbow_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet10_MAT.industrial_crossbow.Industrial_Crossbow_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet10_MAT.industrial_crossbow.Industrial_Crossbow_3P_Pickup_MIC"))

//Shredder (Industrial) Kriss
	Skins.Add((Id=4723, Weapondef=class'KFWeapDef_Kriss', MIC_1P=("WEP_SkinSet10_MAT.industrial_kriss.Industrial_Kriss_1P_Mint_MIC"), MIC_3P="WEP_SkinSet10_MAT.industrial_kriss.Industrial_Kriss_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet10_MAT.industrial_kriss.Industrial_Kriss_3P_Pickup_MIC"))
 	Skins.Add((Id=4722, Weapondef=class'KFWeapDef_Kriss', MIC_1P=("WEP_SkinSet10_MAT.industrial_kriss.Industrial_Kriss_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet10_MAT.industrial_kriss.Industrial_Kriss_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet10_MAT.industrial_kriss.Industrial_Kriss_3P_Pickup_MIC"))
	Skins.Add((Id=4721, Weapondef=class'KFWeapDef_Kriss', MIC_1P=("WEP_SkinSet10_MAT.industrial_kriss.Industrial_Kriss_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet10_MAT.industrial_kriss.Industrial_Kriss_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet10_MAT.industrial_kriss.Industrial_Kriss_3P_Pickup_MIC"))

//Industrial M14EBR
	Skins.Add((Id=4726, Weapondef=class'KFWeapDef_M14EBR', MIC_1P=("WEP_SkinSet10_MAT.industrial_m14ebr.Industrial_M14EBR_1P_Mint_MIC", "WEP_SkinSet10_MAT.industrial_m14ebr.Industrial_M14EBR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet10_MAT.industrial_m14ebr.Industrial_M14EBR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet10_MAT.industrial_m14ebr.Industrial_M14EBR_3P_Pickup_MIC"))
 	Skins.Add((Id=4725, Weapondef=class'KFWeapDef_M14EBR', MIC_1P=("WEP_SkinSet10_MAT.industrial_m14ebr.Industrial_M14EBR_1P_FieldTested_MIC", "WEP_SkinSet10_MAT.industrial_m14ebr.Industrial_M14EBR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet10_MAT.industrial_m14ebr.Industrial_M14EBR_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet10_MAT.industrial_m14ebr.Industrial_M14EBR_3P_Pickup_MIC"))
	Skins.Add((Id=4724, Weapondef=class'KFWeapDef_M14EBR', MIC_1P=("WEP_SkinSet10_MAT.industrial_m14ebr.Industrial_M14EBR_1P_BattleScarred_MIC", "WEP_SkinSet10_MAT.industrial_m14ebr.Industrial_M14EBR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet10_MAT.industrial_m14ebr.Industrial_M14EBR_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet10_MAT.industrial_m14ebr.Industrial_M14EBR_3P_Pickup_MIC"))

//Industrial MP5RAS
	Skins.Add((Id=4729, Weapondef=class'KFWeapDef_MP5RAS', MIC_1P=("WEP_SkinSet10_MAT.industrial_mp5ras.Industrial_MP5RAS_1P_Mint_MIC"), MIC_3P="WEP_SkinSet10_MAT.industrial_mp5ras.Industrial_MP5RAS_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet10_MAT.industrial_mp5ras.Industrial_MP5RAS_3P_Pickup_MIC"))
 	Skins.Add((Id=4728, Weapondef=class'KFWeapDef_MP5RAS', MIC_1P=("WEP_SkinSet10_MAT.industrial_mp5ras.Industrial_MP5RAS_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet10_MAT.industrial_mp5ras.Industrial_MP5RAS_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet10_MAT.industrial_mp5ras.Industrial_MP5RAS_3P_Pickup_MIC"))
	Skins.Add((Id=4727, Weapondef=class'KFWeapDef_MP5RAS', MIC_1P=("WEP_SkinSet10_MAT.industrial_mp5ras.Industrial_MP5RAS_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet10_MAT.industrial_mp5ras.Industrial_MP5RAS_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet10_MAT.industrial_mp5ras.Industrial_MP5RAS_3P_Pickup_MIC"))

//Jackhammer (Industrial) MP7
	Skins.Add((Id=4732, Weapondef=class'KFWeapDef_MP7', MIC_1P=("WEP_SkinSet10_MAT.industrial_mp7.Industrial_MP7_1P_Mint_MIC", "WEP_SkinSet10_MAT.industrial_mp7.Industrial_MP7_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet10_MAT.industrial_mp7.Industrial_MP7_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet10_MAT.industrial_mp7.Industrial_MP7_3P_Pickup_MIC"))
 	Skins.Add((Id=4731, Weapondef=class'KFWeapDef_MP7', MIC_1P=("WEP_SkinSet10_MAT.industrial_mp7.Industrial_MP7_1P_FieldTested_MIC", "WEP_SkinSet10_MAT.industrial_mp7.Industrial_MP7_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet10_MAT.industrial_mp7.Industrial_MP7_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet10_MAT.industrial_mp7.Industrial_MP7_3P_Pickup_MIC"))
	Skins.Add((Id=4730, Weapondef=class'KFWeapDef_MP7', MIC_1P=("WEP_SkinSet10_MAT.industrial_mp7.Industrial_MP7_1P_BattleScarred_MIC", "WEP_SkinSet10_MAT.industrial_mp7.Industrial_MP7_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet10_MAT.industrial_mp7.Industrial_MP7_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet10_MAT.industrial_mp7.Industrial_MP7_3P_Pickup_MIC"))

//Buzzsaw (Industrial) P90
	Skins.Add((Id=4735, Weapondef=class'KFWeapDef_P90', MIC_1P=("WEP_SkinSet10_MAT.industrial_p90.Industrial_P90_1P_Mint_MIC", "WEP_SkinSet10_MAT.industrial_p90.Industrial_P90_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet10_MAT.industrial_p90.Industrial_P90_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet10_MAT.industrial_p90.Industrial_P90_3P_Pickup_MIC"))
 	Skins.Add((Id=4734, Weapondef=class'KFWeapDef_P90', MIC_1P=("WEP_SkinSet10_MAT.industrial_p90.Industrial_P90_1P_FieldTested_MIC", "WEP_SkinSet10_MAT.industrial_p90.Industrial_P90_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet10_MAT.industrial_p90.Industrial_P90_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet10_MAT.industrial_p90.Industrial_P90_3P_Pickup_MIC"))
	Skins.Add((Id=4733, Weapondef=class'KFWeapDef_P90', MIC_1P=("WEP_SkinSet10_MAT.industrial_p90.Industrial_P90_1P_BattleScarred_MIC", "WEP_SkinSet10_MAT.industrial_p90.Industrial_P90_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet10_MAT.industrial_p90.Industrial_P90_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet10_MAT.industrial_p90.Industrial_P90_3P_Pickup_MIC"))

//High Voltage (Industrial) Railgun
	Skins.Add((Id=4738, Weapondef=class'KFWeapDef_RailGun', MIC_1P=("WEP_SkinSet10_MAT.industrial_railgun.Industrial_RailGun_1P_Mint_MIC", "WEP_SkinSet10_MAT.industrial_railgun.Industrial_RailGun_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet10_MAT.industrial_railgun.Industrial_RailGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet10_MAT.industrial_railgun.Industrial_RailGun_3P_Pickup_MIC"))
 	Skins.Add((Id=4737, Weapondef=class'KFWeapDef_RailGun', MIC_1P=("WEP_SkinSet10_MAT.industrial_railgun.Industrial_RailGun_1P_FieldTested_MIC", "WEP_SkinSet10_MAT.industrial_railgun.Industrial_RailGun_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet10_MAT.industrial_railgun.Industrial_RailGun_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet10_MAT.industrial_railgun.Industrial_RailGun_3P_Pickup_MIC"))
	Skins.Add((Id=4736, Weapondef=class'KFWeapDef_RailGun', MIC_1P=("WEP_SkinSet10_MAT.industrial_railgun.Industrial_RailGun_1P_BattleScarred_MIC", "WEP_SkinSet10_MAT.industrial_railgun.Industrial_RailGun_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet10_MAT.industrial_railgun.Industrial_RailGun_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet10_MAT.industrial_railgun.Industrial_RailGun_3P_Pickup_MIC"))

//Industrial SW500
	Skins.Add((Id=4741, Weapondef=class'KFWeapDef_SW500', MIC_1P=("WEP_SkinSet10_MAT.industrial_sw500.Industrial_SW500_1P_Mint_MIC"), MIC_3P="WEP_SkinSet10_MAT.industrial_sw500.Industrial_SW500_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet10_MAT.industrial_sw500.Industrial_SW500_3P_Pickup_MIC"))
	Skins.Add((Id=4740, Weapondef=class'KFWeapDef_SW500', MIC_1P=("WEP_SkinSet10_MAT.industrial_sw500.Industrial_SW500_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet10_MAT.industrial_sw500.Industrial_SW500_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet10_MAT.industrial_sw500.Industrial_SW500_3P_Pickup_MIC"))
	Skins.Add((Id=4739, Weapondef=class'KFWeapDef_SW500', MIC_1P=("WEP_SkinSet10_MAT.industrial_sw500.Industrial_SW500_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet10_MAT.industrial_sw500.Industrial_SW500_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet10_MAT.industrial_sw500.Industrial_SW500_3P_Pickup_MIC"))

//DigiCam Orange FlareGun
	Skins.Add((Id=4809, Weapondef=class'KFWeapDef_FlareGun', MIC_1P=("WEP_SkinSet11_MAT.digicam_flaregun.DigiCam_FlareGun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet11_MAT.digicam_flaregun.DigiCam_FlareGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet11_MAT.digicam_flaregun.DigiCam_FlareGun_3P_Pickup_MIC"))
	Skins.Add((Id=4808, Weapondef=class'KFWeapDef_FlareGun', MIC_1P=("WEP_SkinSet11_MAT.digicam_flaregun.DigiCam_FlareGun_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet11_MAT.digicam_flaregun.DigiCam_FlareGun_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet11_MAT.digicam_flaregun.DigiCam_FlareGun_3P_Pickup_MIC"))
	Skins.Add((Id=4807, Weapondef=class'KFWeapDef_FlareGun', MIC_1P=("WEP_SkinSet11_MAT.digicam_flaregun.DigiCam_FlareGun_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet11_MAT.digicam_flaregun.DigiCam_FlareGun_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet11_MAT.digicam_flaregun.DigiCam_FlareGun_3P_Pickup_MIC"))

//Fine China FlareGun
	Skins.Add((Id=4812, Weapondef=class'KFWeapDef_FlareGun', MIC_1P=("WEP_SkinSet11_MAT.finechina_flaregun.FineChina_FlareGun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet11_MAT.finechina_flaregun.FineChina_FlareGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet11_MAT.finechina_flaregun.FineChina_FlareGun_3P_Pickup_MIC"))
	Skins.Add((Id=4811, Weapondef=class'KFWeapDef_FlareGun', MIC_1P=("WEP_SkinSet11_MAT.finechina_flaregun.FineChina_FlareGun_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet11_MAT.finechina_flaregun.FineChina_FlareGun_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet11_MAT.finechina_flaregun.FineChina_FlareGun_3P_Pickup_MIC"))
	Skins.Add((Id=4810, Weapondef=class'KFWeapDef_FlareGun', MIC_1P=("WEP_SkinSet11_MAT.finechina_flaregun.FineChina_FlareGun_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet11_MAT.finechina_flaregun.FineChina_FlareGun_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet11_MAT.finechina_flaregun.FineChina_FlareGun_3P_Pickup_MIC"))

//Guillotine FlareGun
	Skins.Add((Id=4818, Weapondef=class'KFWeapDef_FlareGun', MIC_1P=("WEP_SkinSet11_MAT.guillotine_flaregun.Guillotine_FlareGun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet11_MAT.guillotine_flaregun.Guillotine_FlareGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet11_MAT.guillotine_flaregun.Guillotine_FlareGun_3P_Pickup_MIC"))
	Skins.Add((Id=4817, Weapondef=class'KFWeapDef_FlareGun', MIC_1P=("WEP_SkinSet11_MAT.guillotine_flaregun.Guillotine_FlareGun_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet11_MAT.guillotine_flaregun.Guillotine_FlareGun_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet11_MAT.guillotine_flaregun.Guillotine_FlareGun_3P_Pickup_MIC"))
	Skins.Add((Id=4816, Weapondef=class'KFWeapDef_FlareGun', MIC_1P=("WEP_SkinSet11_MAT.guillotine_flaregun.Guillotine_FlareGun_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet11_MAT.guillotine_flaregun.Guillotine_FlareGun_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet11_MAT.guillotine_flaregun.Guillotine_FlareGun_3P_Pickup_MIC"))

//Koi FlareGun
	Skins.Add((Id=4821, Weapondef=class'KFWeapDef_FlareGun', MIC_1P=("WEP_SkinSet11_MAT.koi_flaregun.Koi_FlareGun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet11_MAT.koi_flaregun.Koi_FlareGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet11_MAT.koi_flaregun.Koi_FlareGun_3P_Pickup_MIC"))
	Skins.Add((Id=4820, Weapondef=class'KFWeapDef_FlareGun', MIC_1P=("WEP_SkinSet11_MAT.koi_flaregun.Koi_FlareGun_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet11_MAT.koi_flaregun.Koi_FlareGun_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet11_MAT.koi_flaregun.Koi_FlareGun_3P_Pickup_MIC"))
	Skins.Add((Id=4819, Weapondef=class'KFWeapDef_FlareGun', MIC_1P=("WEP_SkinSet11_MAT.koi_flaregun.Koi_FlareGun_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet11_MAT.koi_flaregun.Koi_FlareGun_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet11_MAT.koi_flaregun.Koi_FlareGun_3P_Pickup_MIC"))

//Flame Blue FlareGun
	Skins.Add((Id=4824, Weapondef=class'KFWeapDef_FlareGun', MIC_1P=("WEP_SkinSet11_MAT.flameblue_flaregun.FlameBlue_FlareGun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet11_MAT.flameblue_flaregun.FlameBlue_FlareGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet11_MAT.flameblue_flaregun.FlameBlue_FlareGun_3P_Pickup_MIC"))
	Skins.Add((Id=4823, Weapondef=class'KFWeapDef_FlareGun', MIC_1P=("WEP_SkinSet11_MAT.flameblue_flaregun.FlameBlue_FlareGun_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet11_MAT.flameblue_flaregun.FlameBlue_FlareGun_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet11_MAT.flameblue_flaregun.FlameBlue_FlareGun_3P_Pickup_MIC"))
	Skins.Add((Id=4822, Weapondef=class'KFWeapDef_FlareGun', MIC_1P=("WEP_SkinSet11_MAT.flameblue_flaregun.FlameBlue_FlareGun_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet11_MAT.flameblue_flaregun.FlameBlue_FlareGun_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet11_MAT.flameblue_flaregun.FlameBlue_FlareGun_3P_Pickup_MIC"))

//Flame Orange FlareGun
	Skins.Add((Id=4806, Weapondef=class'KFWeapDef_FlareGun', MIC_1P=("WEP_SkinSet11_MAT.flameorange_flaregun.FlameOrange_FlareGun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet11_MAT.flameorange_flaregun.FlameOrange_FlareGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet11_MAT.flameorange_flaregun.FlameOrange_FlareGun_3P_Pickup_MIC"))
	Skins.Add((Id=4805, Weapondef=class'KFWeapDef_FlareGun', MIC_1P=("WEP_SkinSet11_MAT.flameorange_flaregun.FlameOrange_FlareGun_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet11_MAT.flameorange_flaregun.FlameOrange_FlareGun_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet11_MAT.flameorange_flaregun.FlameOrange_FlareGun_3P_Pickup_MIC"))
	Skins.Add((Id=4804, Weapondef=class'KFWeapDef_FlareGun', MIC_1P=("WEP_SkinSet11_MAT.flameorange_flaregun.FlameOrange_FlareGun_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet11_MAT.flameorange_flaregun.FlameOrange_FlareGun_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet11_MAT.flameorange_flaregun.FlameOrange_FlareGun_3P_Pickup_MIC"))

//Flame Red FlareGun
	Skins.Add((Id=4815, Weapondef=class'KFWeapDef_FlareGun', MIC_1P=("WEP_SkinSet11_MAT.flamered_flaregun.FlameRed_FlareGun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet11_MAT.flamered_flaregun.FlameRed_FlareGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet11_MAT.flamered_flaregun.FlameRed_FlareGun_3P_Pickup_MIC"))
	Skins.Add((Id=4814, Weapondef=class'KFWeapDef_FlareGun', MIC_1P=("WEP_SkinSet11_MAT.flamered_flaregun.FlameRed_FlareGun_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet11_MAT.flamered_flaregun.FlameRed_FlareGun_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet11_MAT.flamered_flaregun.FlameRed_FlareGun_3P_Pickup_MIC"))
	Skins.Add((Id=4813, Weapondef=class'KFWeapDef_FlareGun', MIC_1P=("WEP_SkinSet11_MAT.flamered_flaregun.FlameRed_FlareGun_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet11_MAT.flamered_flaregun.FlameRed_FlareGun_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet11_MAT.flamered_flaregun.FlameRed_FlareGun_3P_Pickup_MIC"))

//Snow Camo Freeze Thrower
	Skins.Add((Id=4829, Weapondef=class'KFWeapDef_FreezeThrower', MIC_1P=("WEP_SkinSet_CryoGun_MAT.X01_Cryogun_1P_ID1_Mint_MIC", "WEP_SkinSet_CryoGun_MAT.X01_Cryogun_1P_ID2_Mint_Mic"), MIC_3P="WEP_SkinSet_CryoGun_MAT.X01_Cryogun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_CryoGun_MAT.X01_Cryogun_3P_Pickup_MIC"))
	Skins.Add((Id=4828, Weapondef=class'KFWeapDef_FreezeThrower', MIC_1P=("WEP_SkinSet_CryoGun_MAT.X01_Cryogun_1P_ID1_FieldTested_MIC", "WEP_SkinSet_CryoGun_MAT.X01_Cryogun_1P_ID2_FieldTested_Mic"), MIC_3P="WEP_SkinSet_CryoGun_MAT.X01_Cryogun_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet_CryoGun_MAT.X01_Cryogun_3P_Pickup_MIC"))
	Skins.Add((Id=4827, Weapondef=class'KFWeapDef_FreezeThrower', MIC_1P=("WEP_SkinSet_CryoGun_MAT.X01_Cryogun_1P_ID1_BattleScarred_MIC", "WEP_SkinSet_CryoGun_MAT.X01_Cryogun_1P_ID2_BattleScarred_Mic"), MIC_3P="WEP_SkinSet_CryoGun_MAT.X01_Cryogun_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet_CryoGun_MAT.X01_Cryogun_3P_Pickup_MIC"))

//Blood Camo Freeze Thrower
	Skins.Add((Id=4832, Weapondef=class'KFWeapDef_FreezeThrower', MIC_1P=("WEP_SkinSet_CryoGun_MAT.X02_Cryogun_1P_ID1_Mint_MIC", "WEP_SkinSet_CryoGun_MAT.X02_Cryogun_1P_ID2_Mint_Mic"), MIC_3P="WEP_SkinSet_CryoGun_MAT.X02_Cryogun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_CryoGun_MAT.X02_Cryogun_3P_Pickup_MIC"))
	Skins.Add((Id=4831, Weapondef=class'KFWeapDef_FreezeThrower', MIC_1P=("WEP_SkinSet_CryoGun_MAT.X02_Cryogun_1P_ID1_FieldTested_MIC", "WEP_SkinSet_CryoGun_MAT.X02_Cryogun_1P_ID2_FieldTested_Mic"), MIC_3P="WEP_SkinSet_CryoGun_MAT.X02_Cryogun_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet_CryoGun_MAT.X02_Cryogun_3P_Pickup_MIC"))
	Skins.Add((Id=4830, Weapondef=class'KFWeapDef_FreezeThrower', MIC_1P=("WEP_SkinSet_CryoGun_MAT.X02_Cryogun_1P_ID1_BattleScarred_MIC", "WEP_SkinSet_CryoGun_MAT.X02_Cryogun_1P_ID2_BattleScarred_Mic"), MIC_3P="WEP_SkinSet_CryoGun_MAT.X02_Cryogun_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet_CryoGun_MAT.X02_Cryogun_3P_Pickup_MIC"))

//Minus Zero Blue Freeze Thrower
	Skins.Add((Id=4835, Weapondef=class'KFWeapDef_FreezeThrower', MIC_1P=("WEP_SkinSet_CryoGun_MAT.X03_Cryogun_1P_ID1_Mint_MIC", "WEP_SkinSet_CryoGun_MAT.X03_Cryogun_1P_ID2_Mint_Mic"), MIC_3P="WEP_SkinSet_CryoGun_MAT.X03_Cryogun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_CryoGun_MAT.X03_Cryogun_3P_Pickup_MIC"))
	Skins.Add((Id=4834, Weapondef=class'KFWeapDef_FreezeThrower', MIC_1P=("WEP_SkinSet_CryoGun_MAT.X03_Cryogun_1P_ID1_FieldTested_MIC", "WEP_SkinSet_CryoGun_MAT.X03_Cryogun_1P_ID2_FieldTested_Mic"), MIC_3P="WEP_SkinSet_CryoGun_MAT.X03_Cryogun_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet_CryoGun_MAT.X03_Cryogun_3P_Pickup_MIC"))
	Skins.Add((Id=4833, Weapondef=class'KFWeapDef_FreezeThrower', MIC_1P=("WEP_SkinSet_CryoGun_MAT.X03_Cryogun_1P_ID1_BattleScarred_MIC", "WEP_SkinSet_CryoGun_MAT.X03_Cryogun_1P_ID2_BattleScarred_Mic"), MIC_3P="WEP_SkinSet_CryoGun_MAT.X03_Cryogun_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet_CryoGun_MAT.X03_Cryogun_3P_Pickup_MIC"))

//Minus Zero Red Freeze Thrower
	Skins.Add((Id=4838, Weapondef=class'KFWeapDef_FreezeThrower', MIC_1P=("WEP_SkinSet_CryoGun_MAT.X04_Cryogun_1P_ID1_Mint_MIC", "WEP_SkinSet_CryoGun_MAT.X04_Cryogun_1P_ID2_Mint_Mic"), MIC_3P="WEP_SkinSet_CryoGun_MAT.X04_Cryogun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_CryoGun_MAT.X04_Cryogun_3P_Pickup_MIC"))
	Skins.Add((Id=4837, Weapondef=class'KFWeapDef_FreezeThrower', MIC_1P=("WEP_SkinSet_CryoGun_MAT.X04_Cryogun_1P_ID1_FieldTested_MIC", "WEP_SkinSet_CryoGun_MAT.X04_Cryogun_1P_ID2_FieldTested_Mic"), MIC_3P="WEP_SkinSet_CryoGun_MAT.X04_Cryogun_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet_CryoGun_MAT.X04_Cryogun_3P_Pickup_MIC"))
	Skins.Add((Id=4836, Weapondef=class'KFWeapDef_FreezeThrower', MIC_1P=("WEP_SkinSet_CryoGun_MAT.X04_Cryogun_1P_ID1_BattleScarred_MIC", "WEP_SkinSet_CryoGun_MAT.X04_Cryogun_1P_ID2_BattleScarred_Mic"), MIC_3P="WEP_SkinSet_CryoGun_MAT.X04_Cryogun_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet_CryoGun_MAT.X04_Cryogun_3P_Pickup_MIC"))

//Anodized Ice Multi-color Freeze Thrower
	Skins.Add((Id=4841, Weapondef=class'KFWeapDef_FreezeThrower', MIC_1P=("WEP_SkinSet_CryoGun_MAT.X05_Cryogun_1P_ID1_Mint_MIC", "WEP_SkinSet_CryoGun_MAT.X05_Cryogun_1P_ID2_Mint_Mic"), MIC_3P="WEP_SkinSet_CryoGun_MAT.X05_Cryogun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_CryoGun_MAT.X05_Cryogun_3P_Pickup_MIC"))
	Skins.Add((Id=4840, Weapondef=class'KFWeapDef_FreezeThrower', MIC_1P=("WEP_SkinSet_CryoGun_MAT.X05_Cryogun_1P_ID1_FieldTested_MIC", "WEP_SkinSet_CryoGun_MAT.X05_Cryogun_1P_ID2_FieldTested_Mic"), MIC_3P="WEP_SkinSet_CryoGun_MAT.X05_Cryogun_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet_CryoGun_MAT.X05_Cryogun_3P_Pickup_MIC"))
	Skins.Add((Id=4839, Weapondef=class'KFWeapDef_FreezeThrower', MIC_1P=("WEP_SkinSet_CryoGun_MAT.X05_Cryogun_1P_ID1_BattleScarred_MIC", "WEP_SkinSet_CryoGun_MAT.X05_Cryogun_1P_ID2_BattleScarred_Mic"), MIC_3P="WEP_SkinSet_CryoGun_MAT.X05_Cryogun_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet_CryoGun_MAT.X05_Cryogun_3P_Pickup_MIC"))

//Anodized Ice Blue Freeze Thrower
	Skins.Add((Id=4844, Weapondef=class'KFWeapDef_FreezeThrower', MIC_1P=("WEP_SkinSet_CryoGun_MAT.X06_Cryogun_1P_ID1_Mint_MIC", "WEP_SkinSet_CryoGun_MAT.X06_Cryogun_1P_ID2_Mint_Mic"), MIC_3P="WEP_SkinSet_CryoGun_MAT.X06_Cryogun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_CryoGun_MAT.X06_Cryogun_3P_Pickup_MIC"))
	Skins.Add((Id=4843, Weapondef=class'KFWeapDef_FreezeThrower', MIC_1P=("WEP_SkinSet_CryoGun_MAT.X06_Cryogun_1P_ID1_FieldTested_MIC", "WEP_SkinSet_CryoGun_MAT.X06_Cryogun_1P_ID2_FieldTested_Mic"), MIC_3P="WEP_SkinSet_CryoGun_MAT.X06_Cryogun_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet_CryoGun_MAT.X06_Cryogun_3P_Pickup_MIC"))
	Skins.Add((Id=4842, Weapondef=class'KFWeapDef_FreezeThrower', MIC_1P=("WEP_SkinSet_CryoGun_MAT.X06_Cryogun_1P_ID1_BattleScarred_MIC", "WEP_SkinSet_CryoGun_MAT.X06_Cryogun_1P_ID2_BattleScarred_Mic"), MIC_3P="WEP_SkinSet_CryoGun_MAT.X06_Cryogun_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet_CryoGun_MAT.X06_Cryogun_3P_Pickup_MIC"))

//Anodized Ice Red Freeze Thrower
	Skins.Add((Id=4847, Weapondef=class'KFWeapDef_FreezeThrower', MIC_1P=("WEP_SkinSet_CryoGun_MAT.X07_Cryogun_1P_ID1_Mint_MIC", "WEP_SkinSet_CryoGun_MAT.X07_Cryogun_1P_ID2_Mint_Mic"), MIC_3P="WEP_SkinSet_CryoGun_MAT.X07_Cryogun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_CryoGun_MAT.X07_Cryogun_3P_Pickup_MIC"))
	Skins.Add((Id=4846, Weapondef=class'KFWeapDef_FreezeThrower', MIC_1P=("WEP_SkinSet_CryoGun_MAT.X07_Cryogun_1P_ID1_FieldTested_MIC", "WEP_SkinSet_CryoGun_MAT.X07_Cryogun_1P_ID2_FieldTested_Mic"), MIC_3P="WEP_SkinSet_CryoGun_MAT.X07_Cryogun_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet_CryoGun_MAT.X07_Cryogun_3P_Pickup_MIC"))
	Skins.Add((Id=4845, Weapondef=class'KFWeapDef_FreezeThrower', MIC_1P=("WEP_SkinSet_CryoGun_MAT.X07_Cryogun_1P_ID1_BattleScarred_MIC", "WEP_SkinSet_CryoGun_MAT.X07_Cryogun_1P_ID2_BattleScarred_Mic"), MIC_3P="WEP_SkinSet_CryoGun_MAT.X07_Cryogun_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet_CryoGun_MAT.X07_Cryogun_3P_Pickup_MIC"))

//Minus Zero Green Freeze Thrower
	Skins.Add((Id=4850, Weapondef=class'KFWeapDef_FreezeThrower', MIC_1P=("WEP_SkinSet_CryoGun_MAT.X08_Cryogun_1P_ID1_Mint_MIC", "WEP_SkinSet_CryoGun_MAT.X08_Cryogun_1P_ID2_Mint_Mic"), MIC_3P="WEP_SkinSet_CryoGun_MAT.X08_Cryogun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_CryoGun_MAT.X08_Cryogun_3P_Pickup_MIC"))
	Skins.Add((Id=4849, Weapondef=class'KFWeapDef_FreezeThrower', MIC_1P=("WEP_SkinSet_CryoGun_MAT.X08_Cryogun_1P_ID1_FieldTested_MIC", "WEP_SkinSet_CryoGun_MAT.X08_Cryogun_1P_ID2_FieldTested_Mic"), MIC_3P="WEP_SkinSet_CryoGun_MAT.X08_Cryogun_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet_CryoGun_MAT.X08_Cryogun_3P_Pickup_MIC"))
	Skins.Add((Id=4848, Weapondef=class'KFWeapDef_FreezeThrower', MIC_1P=("WEP_SkinSet_CryoGun_MAT.X08_Cryogun_1P_ID1_BattleScarred_MIC", "WEP_SkinSet_CryoGun_MAT.X08_Cryogun_1P_ID2_BattleScarred_Mic"), MIC_3P="WEP_SkinSet_CryoGun_MAT.X08_Cryogun_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet_CryoGun_MAT.X08_Cryogun_3P_Pickup_MIC"))

//Vietnam AK12
	Skins.Add((Id=4970, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet12_MAT.vietnam_ak12.Vietnam_AK12_1P_Mint_MIC", "WEP_SkinSet12_MAT.vietnam_ak12.Vietnam_AK12_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet12_MAT.vietnam_ak12.Vietnam_AK12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet12_MAT.vietnam_ak12.Vietnam_AK12_3P_Pickup_MIC"))
	Skins.Add((Id=4969, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet12_MAT.vietnam_ak12.Vietnam_AK12_1P_FieldTested_MIC", "WEP_SkinSet12_MAT.vietnam_ak12.Vietnam_AK12_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet12_MAT.vietnam_ak12.Vietnam_AK12_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet12_MAT.vietnam_ak12.Vietnam_AK12_3P_Pickup_MIC"))
	Skins.Add((Id=4968, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet12_MAT.vietnam_ak12.Vietnam_AK12_1P_BattleScarred_MIC", "WEP_SkinSet12_MAT.vietnam_ak12.Vietnam_AK12_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet12_MAT.vietnam_ak12.Vietnam_AK12_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet12_MAT.vietnam_ak12.Vietnam_AK12_3P_Pickup_MIC"))

//Vietnam L85A2
	Skins.Add((Id=4964, Weapondef=class'KFWeapDef_Bullpup', MIC_1P=("WEP_SkinSet12_MAT.vietnam_l85a2.Vietnam_L85A2_1P_Mint_MIC", "WEP_SkinSet12_MAT.vietnam_l85a2.Vietnam_L85A2_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet12_MAT.vietnam_l85a2.Vietnam_L85A2_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet12_MAT.vietnam_l85a2.Vietnam_L85A2_3P_Pickup_MIC"))
	Skins.Add((Id=4963, Weapondef=class'KFWeapDef_Bullpup', MIC_1P=("WEP_SkinSet12_MAT.vietnam_l85a2.Vietnam_L85A2_1P_FieldTested_MIC", "WEP_SkinSet12_MAT.vietnam_l85a2.Vietnam_L85A2_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet12_MAT.vietnam_l85a2.Vietnam_L85A2_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet12_MAT.vietnam_l85a2.Vietnam_L85A2_3P_Pickup_MIC"))
	Skins.Add((Id=4962, Weapondef=class'KFWeapDef_Bullpup', MIC_1P=("WEP_SkinSet12_MAT.vietnam_l85a2.Vietnam_L85A2_1P_BattleScarred_MIC", "WEP_SkinSet12_MAT.vietnam_l85a2.Vietnam_L85A2_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet12_MAT.vietnam_l85a2.Vietnam_L85A2_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet12_MAT.vietnam_l85a2.Vietnam_L85A2_3P_Pickup_MIC"))

//Vietnam M14EBR
	Skins.Add((Id=4973, Weapondef=class'KFWeapDef_M14EBR', MIC_1P=("WEP_SkinSet12_MAT.vietnam_m14ebr.Vietnam_M14EBR_1P_Mint_MIC", "WEP_SkinSet12_MAT.vietnam_m14ebr.Vietnam_M14EBR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet12_MAT.vietnam_m14ebr.Vietnam_M14EBR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet12_MAT.vietnam_m14ebr.Vietnam_M14EBR_3P_Pickup_MIC"))
	Skins.Add((Id=4972, Weapondef=class'KFWeapDef_M14EBR', MIC_1P=("WEP_SkinSet12_MAT.vietnam_m14ebr.Vietnam_M14EBR_1P_FieldTested_MIC", "WEP_SkinSet12_MAT.vietnam_m14ebr.Vietnam_M14EBR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet12_MAT.vietnam_m14ebr.Vietnam_M14EBR_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet12_MAT.vietnam_m14ebr.Vietnam_M14EBR_3P_Pickup_MIC"))
	Skins.Add((Id=4971, Weapondef=class'KFWeapDef_M14EBR', MIC_1P=("WEP_SkinSet12_MAT.vietnam_m14ebr.Vietnam_M14EBR_1P_BattleScarred_MIC", "WEP_SkinSet12_MAT.vietnam_m14ebr.Vietnam_M14EBR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet12_MAT.vietnam_m14ebr.Vietnam_M14EBR_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet12_MAT.vietnam_m14ebr.Vietnam_M14EBR_3P_Pickup_MIC"))

//Vietnam M1911
	Skins.Add((Id=4961, Weapondef=class'KFWeapDef_Colt1911', MIC_1P=("WEP_SkinSet12_MAT.vietnam_m1911.Vietnam_M1911_1P_Mint_MIC"), MIC_3P="WEP_SkinSet12_MAT.vietnam_m1911.Vietnam_M1911_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet12_MAT.vietnam_m1911.Vietnam_M1911_3P_Pickup_MIC"))
	Skins.Add((Id=4960, Weapondef=class'KFWeapDef_Colt1911', MIC_1P=("WEP_SkinSet12_MAT.vietnam_m1911.Vietnam_M1911_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet12_MAT.vietnam_m1911.Vietnam_M1911_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet12_MAT.vietnam_m1911.Vietnam_M1911_3P_Pickup_MIC"))
	Skins.Add((Id=4959, Weapondef=class'KFWeapDef_Colt1911', MIC_1P=("WEP_SkinSet12_MAT.vietnam_m1911.Vietnam_M1911_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet12_MAT.vietnam_m1911.Vietnam_M1911_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet12_MAT.vietnam_m1911.Vietnam_M1911_3P_Pickup_MIC"))

//Vietnam M4
	Skins.Add((Id=4967, Weapondef=class'KFWeapDef_M4', MIC_1P=("WEP_SkinSet12_MAT.vietnam_m4.Vietnam_M4_1P_Mint_MIC"), MIC_3P="WEP_SkinSet12_MAT.vietnam_m4.Vietnam_M4_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet12_MAT.vietnam_m4.Vietnam_M4_3P_Pickup_MIC"))
	Skins.Add((Id=4966, Weapondef=class'KFWeapDef_M4', MIC_1P=("WEP_SkinSet12_MAT.vietnam_m4.Vietnam_M4_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet12_MAT.vietnam_m4.Vietnam_M4_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet12_MAT.vietnam_m4.Vietnam_M4_3P_Pickup_MIC"))
	Skins.Add((Id=4965, Weapondef=class'KFWeapDef_M4', MIC_1P=("WEP_SkinSet12_MAT.vietnam_m4.Vietnam_M4_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet12_MAT.vietnam_m4.Vietnam_M4_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet12_MAT.vietnam_m4.Vietnam_M4_3P_Pickup_MIC"))

//Vietnam RPG7
	Skins.Add((Id=4958, Weapondef=class'KFWeapDef_RPG7', MIC_1P=("WEP_SkinSet12_MAT.vietnam_rpg7.Vietnam_RPG7_1P_Mint_MIC"), MIC_3P="WEP_SkinSet12_MAT.vietnam_rpg7.Vietnam_RPG7_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet12_MAT.vietnam_rpg7.Vietnam_RPG7_3P_Pickup_MIC"))
	Skins.Add((Id=4957, Weapondef=class'KFWeapDef_RPG7', MIC_1P=("WEP_SkinSet12_MAT.vietnam_rpg7.Vietnam_RPG7_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet12_MAT.vietnam_rpg7.Vietnam_RPG7_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet12_MAT.vietnam_rpg7.Vietnam_RPG7_3P_Pickup_MIC"))
	Skins.Add((Id=4956, Weapondef=class'KFWeapDef_RPG7', MIC_1P=("WEP_SkinSet12_MAT.vietnam_rpg7.Vietnam_RPG7_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet12_MAT.vietnam_rpg7.Vietnam_RPG7_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet12_MAT.vietnam_rpg7.Vietnam_RPG7_3P_Pickup_MIC"))

//Vietnam Winchester 1894
	Skins.Add((Id=4955, Weapondef=class'KFWeapDef_Winchester1894', MIC_1P=("WEP_SkinSet12_MAT.vietnam_winchester1894.Vietnam_Winchester1894_1P_Mint_MIC"), MIC_3P="WEP_SkinSet12_MAT.vietnam_winchester1894.Vietnam_Winchester1894_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet12_MAT.vietnam_winchester1894.Vietnam_Winchester1894_3P_Pickup_MIC"))
	Skins.Add((Id=4954, Weapondef=class'KFWeapDef_Winchester1894', MIC_1P=("WEP_SkinSet12_MAT.vietnam_winchester1894.Vietnam_Winchester1894_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet12_MAT.vietnam_winchester1894.Vietnam_Winchester1894_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet12_MAT.vietnam_winchester1894.Vietnam_Winchester1894_3P_Pickup_MIC"))
	Skins.Add((Id=4953, Weapondef=class'KFWeapDef_Winchester1894', MIC_1P=("WEP_SkinSet12_MAT.vietnam_winchester1894.Vietnam_Winchester1894_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet12_MAT.vietnam_winchester1894.Vietnam_Winchester1894_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet12_MAT.vietnam_winchester1894.Vietnam_Winchester1894_3P_Pickup_MIC"))

//Vietnam M16 M203
	Skins.Add((Id=4983, Weapondef=class'KFWeapDef_M16M203', MIC_1P=("WEP_SkinSet12_MAT.vietnam_m16m203.Vietnam_M16_1P_Mint_MIC", "WEP_SkinSet12_MAT.vietnam_m16m203.Vietnam_M203_1P_Mint_MIC"), MIC_3P="WEP_SkinSet12_MAT.vietnam_m16m203.Vietnam_M16M203_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet12_MAT.vietnam_m16m203.Vietnam_M16M203_3P_Pickup_MIC"))
	Skins.Add((Id=4982, Weapondef=class'KFWeapDef_M16M203', MIC_1P=("WEP_SkinSet12_MAT.vietnam_m16m203.Vietnam_M16_1P_FieldTested_MIC", "WEP_SkinSet12_MAT.vietnam_m16m203.Vietnam_M203_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet12_MAT.vietnam_m16m203.Vietnam_M16M203_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet12_MAT.vietnam_m16m203.Vietnam_M16M203_3P_Pickup_MIC"))
	Skins.Add((Id=4981, Weapondef=class'KFWeapDef_M16M203', MIC_1P=("WEP_SkinSet12_MAT.vietnam_m16m203.Vietnam_M16_1P_BattleScarred_MIC", "WEP_SkinSet12_MAT.vietnam_m16m203.Vietnam_M203_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet12_MAT.vietnam_m16m203.Vietnam_M16M203_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet12_MAT.vietnam_m16m203.Vietnam_M16M203_3P_Pickup_MIC"))

//Vietnam RPG7 - Rising Storm Digital Deluxe
	Skins.Add((Id=5017, Weapondef=class'KFWeapDef_RPG7', MIC_1P=("WEP_SkinSet12_MAT.vietnam_rpg7.Vietnam_RPG7_1P_Mint_MIC"), MIC_3P="WEP_SkinSet12_MAT.vietnam_rpg7.Vietnam_RPG7_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet12_MAT.vietnam_rpg7.Vietnam_RPG7_3P_Pickup_MIC"))

//Vietnam M16 M203 - Rising Storm Digital Deluxe
	Skins.Add((Id=5021, Weapondef=class'KFWeapDef_M16M203', MIC_1P=("WEP_SkinSet12_MAT.vietnam_m16m203.Vietnam_M16_1P_Mint_MIC", "WEP_SkinSet12_MAT.vietnam_m16m203.Vietnam_M203_1P_Mint_MIC"), MIC_3P="WEP_SkinSet12_MAT.vietnam_m16m203.Vietnam_M16M203_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet12_MAT.vietnam_m16m203.Vietnam_M16M203_3P_Pickup_MIC"))

//Vietnam M1911 - Rising Storm Digital Deluxe
	Skins.Add((Id=5022, Weapondef=class'KFWeapDef_Colt1911', MIC_1P=("WEP_SkinSet12_MAT.vietnam_m1911.Vietnam_M1911_1P_Mint_MIC"), MIC_3P="WEP_SkinSet12_MAT.vietnam_m1911.Vietnam_M1911_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet12_MAT.vietnam_m1911.Vietnam_M1911_3P_Pickup_MIC"))

//Vietnam Winchester 1894 - Rising Storm Digital Deluxe
	Skins.Add((Id=5023, Weapondef=class'KFWeapDef_Winchester1894', MIC_1P=("WEP_SkinSet12_MAT.vietnam_winchester1894.Vietnam_Winchester1894_1P_Mint_MIC"), MIC_3P="WEP_SkinSet12_MAT.vietnam_winchester1894.Vietnam_Winchester1894_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet12_MAT.vietnam_winchester1894.Vietnam_Winchester1894_3P_Pickup_MIC"))

//Junkyard AA12
	Skins.Add((Id=4614, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet13_MAT.junkyard_aa12.Junkyard_AA12_1P_Mint_MIC"), MIC_3P="WEP_SkinSet13_MAT.junkyard_aa12.Junkyard_AA12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet13_MAT.junkyard_aa12.Junkyard_AA12_3P_Pickup_MIC"))
 	Skins.Add((Id=4613, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet13_MAT.junkyard_aa12.Junkyard_AA12_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet13_MAT.junkyard_aa12.Junkyard_AA12_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet13_MAT.junkyard_aa12.Junkyard_AA12_3P_Pickup_MIC"))
	Skins.Add((Id=4612, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet13_MAT.junkyard_aa12.Junkyard_AA12_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet13_MAT.junkyard_aa12.Junkyard_AA12_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet13_MAT.junkyard_aa12.Junkyard_AA12_3P_Pickup_MIC"))

//Junkyard AK12
	Skins.Add((Id=4617, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet13_MAT.junkyard_ak12.Junkyard_AK12_1P_Mint_MIC", "WEP_SkinSet13_MAT.junkyard_ak12.Junkyard_AK12_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet13_MAT.junkyard_ak12.Junkyard_AK12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet13_MAT.junkyard_ak12.Junkyard_AK12_3P_Pickup_MIC"))
	Skins.Add((Id=4616, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet13_MAT.junkyard_ak12.Junkyard_AK12_1P_FieldTested_MIC", "WEP_SkinSet13_MAT.junkyard_ak12.Junkyard_AK12_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet13_MAT.junkyard_ak12.Junkyard_AK12_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet13_MAT.junkyard_ak12.Junkyard_AK12_3P_Pickup_MIC"))
	Skins.Add((Id=4615, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet13_MAT.junkyard_ak12.Junkyard_AK12_1P_BattleScarred_MIC", "WEP_SkinSet13_MAT.junkyard_ak12.Junkyard_AK12_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet13_MAT.junkyard_ak12.Junkyard_AK12_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet13_MAT.junkyard_ak12.Junkyard_AK12_3P_Pickup_MIC"))

//Junkyard Kriss
	Skins.Add((Id=4620, Weapondef=class'KFWeapDef_Kriss', MIC_1P=("WEP_SkinSet13_MAT.junkyard_kriss.Junkyard_Kriss_1P_Mint_MIC", "WEP_SkinSet13_MAT.junkyard_kriss.Junkyard_Kriss_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet13_MAT.junkyard_kriss.Junkyard_Kriss_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet13_MAT.junkyard_kriss.Junkyard_Kriss_3P_Pickup_MIC"))
	Skins.Add((Id=4619, Weapondef=class'KFWeapDef_Kriss', MIC_1P=("WEP_SkinSet13_MAT.junkyard_kriss.Junkyard_Kriss_1P_FieldTested_MIC", "WEP_SkinSet13_MAT.junkyard_kriss.Junkyard_Kriss_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet13_MAT.junkyard_kriss.Junkyard_Kriss_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet13_MAT.junkyard_kriss.Junkyard_Kriss_3P_Pickup_MIC"))
	Skins.Add((Id=4618, Weapondef=class'KFWeapDef_Kriss', MIC_1P=("WEP_SkinSet13_MAT.junkyard_kriss.Junkyard_Kriss_1P_BattleScarred_MIC", "WEP_SkinSet13_MAT.junkyard_kriss.Junkyard_Kriss_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet13_MAT.junkyard_kriss.Junkyard_Kriss_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet13_MAT.junkyard_kriss.Junkyard_Kriss_3P_Pickup_MIC"))

//Junkyard L85A2
	Skins.Add((Id=4623, Weapondef=class'KFWeapDef_Bullpup', MIC_1P=("WEP_SkinSet13_MAT.junkyard_l85a2.Junkyard_L85A2_1P_Mint_MIC", "WEP_SkinSet13_MAT.junkyard_l85a2.Junkyard_L85A2_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet13_MAT.junkyard_l85a2.Junkyard_L85A2_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet13_MAT.junkyard_l85a2.Junkyard_L85A2_3P_Pickup_MIC"))
	Skins.Add((Id=4622, Weapondef=class'KFWeapDef_Bullpup', MIC_1P=("WEP_SkinSet13_MAT.junkyard_l85a2.Junkyard_L85A2_1P_FieldTested_MIC", "WEP_SkinSet13_MAT.junkyard_l85a2.Junkyard_L85A2_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet13_MAT.junkyard_l85a2.Junkyard_L85A2_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet13_MAT.junkyard_l85a2.Junkyard_L85A2_3P_Pickup_MIC"))
	Skins.Add((Id=4621, Weapondef=class'KFWeapDef_Bullpup', MIC_1P=("WEP_SkinSet13_MAT.junkyard_l85a2.Junkyard_L85A2_1P_BattleScarred_MIC", "WEP_SkinSet13_MAT.junkyard_l85a2.Junkyard_L85A2_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet13_MAT.junkyard_l85a2.Junkyard_L85A2_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet13_MAT.junkyard_l85a2.Junkyard_L85A2_3P_Pickup_MIC"))

//Junkyard M14EBR
	Skins.Add((Id=4638, Weapondef=class'KFWeapDef_M14EBR', MIC_1P=("WEP_SkinSet13_MAT.junkyard_m14ebr.Junkyard_M14EBR_1P_Mint_MIC", "WEP_SkinSet13_MAT.junkyard_m14ebr.Junkyard_M14EBR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet13_MAT.junkyard_m14ebr.Junkyard_M14EBR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet13_MAT.junkyard_m14ebr.Junkyard_M14EBR_3P_Pickup_MIC"))
	Skins.Add((Id=4637, Weapondef=class'KFWeapDef_M14EBR', MIC_1P=("WEP_SkinSet13_MAT.junkyard_m14ebr.Junkyard_M14EBR_1P_FieldTested_MIC", "WEP_SkinSet13_MAT.junkyard_m14ebr.Junkyard_M14EBR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet13_MAT.junkyard_m14ebr.Junkyard_M14EBR_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet13_MAT.junkyard_m14ebr.Junkyard_M14EBR_3P_Pickup_MIC"))
	Skins.Add((Id=4636, Weapondef=class'KFWeapDef_M14EBR', MIC_1P=("WEP_SkinSet13_MAT.junkyard_m14ebr.Junkyard_M14EBR_1P_BattleScarred_MIC", "WEP_SkinSet13_MAT.junkyard_m14ebr.Junkyard_M14EBR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet13_MAT.junkyard_m14ebr.Junkyard_M14EBR_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet13_MAT.junkyard_m14ebr.Junkyard_M14EBR_3P_Pickup_MIC"))

//Junkyard M16 M203
	Skins.Add((Id=4987, Weapondef=class'KFWeapDef_M16M203', MIC_1P=("WEP_SkinSet13_MAT.junkyard_m16m203.Junkyard_M16_1P_Mint_MIC", "WEP_SkinSet13_MAT.junkyard_m16m203.Junkyard_M203_1P_Mint_MIC"), MIC_3P="WEP_SkinSet13_MAT.junkyard_m16m203.Junkyard_M16M203_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet13_MAT.junkyard_m16m203.Junkyard_M16M203_3P_Pickup_MIC"))
	Skins.Add((Id=4986, Weapondef=class'KFWeapDef_M16M203', MIC_1P=("WEP_SkinSet13_MAT.junkyard_m16m203.Junkyard_M16_1P_FieldTested_MIC", "WEP_SkinSet13_MAT.junkyard_m16m203.Junkyard_M203_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet13_MAT.junkyard_m16m203.Junkyard_M16M203_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet13_MAT.junkyard_m16m203.Junkyard_M16M203_3P_Pickup_MIC"))
	Skins.Add((Id=4985, Weapondef=class'KFWeapDef_M16M203', MIC_1P=("WEP_SkinSet13_MAT.junkyard_m16m203.Junkyard_M16_1P_BattleScarred_MIC", "WEP_SkinSet13_MAT.junkyard_m16m203.Junkyard_M203_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet13_MAT.junkyard_m16m203.Junkyard_M16M203_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet13_MAT.junkyard_m16m203.Junkyard_M16M203_3P_Pickup_MIC"))

//Junkyard M4
	Skins.Add((Id=4626, Weapondef=class'KFWeapDef_M4', MIC_1P=("WEP_SkinSet13_MAT.junkyard_m4.Junkyard_M4_1P_Mint_MIC"), MIC_3P="WEP_SkinSet13_MAT.junkyard_m4.Junkyard_M4_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet13_MAT.junkyard_m4.Junkyard_M4_3P_Pickup_MIC"))
 	Skins.Add((Id=4625, Weapondef=class'KFWeapDef_M4', MIC_1P=("WEP_SkinSet13_MAT.junkyard_m4.Junkyard_M4_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet13_MAT.junkyard_m4.Junkyard_M4_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet13_MAT.junkyard_m4.Junkyard_M4_3P_Pickup_MIC"))
	Skins.Add((Id=4624, Weapondef=class'KFWeapDef_M4', MIC_1P=("WEP_SkinSet13_MAT.junkyard_m4.Junkyard_M4_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet13_MAT.junkyard_m4.Junkyard_M4_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet13_MAT.junkyard_m4.Junkyard_M4_3P_Pickup_MIC"))

//Junkyard MP5RAS
	Skins.Add((Id=4629, Weapondef=class'KFWeapDef_MP5RAS', MIC_1P=("WEP_SkinSet13_MAT.junkyard_mp5ras.Junkyard_MP5RAS_1P_Mint_MIC"), MIC_3P="WEP_SkinSet13_MAT.junkyard_mp5ras.Junkyard_MP5RAS_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet13_MAT.junkyard_mp5ras.Junkyard_MP5RAS_3P_Pickup_MIC"))
 	Skins.Add((Id=4628, Weapondef=class'KFWeapDef_MP5RAS', MIC_1P=("WEP_SkinSet13_MAT.junkyard_mp5ras.Junkyard_MP5RAS_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet13_MAT.junkyard_mp5ras.Junkyard_MP5RAS_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet13_MAT.junkyard_mp5ras.Junkyard_MP5RAS_3P_Pickup_MIC"))
	Skins.Add((Id=4627, Weapondef=class'KFWeapDef_MP5RAS', MIC_1P=("WEP_SkinSet13_MAT.junkyard_mp5ras.Junkyard_MP5RAS_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet13_MAT.junkyard_mp5ras.Junkyard_MP5RAS_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet13_MAT.junkyard_mp5ras.Junkyard_MP5RAS_3P_Pickup_MIC"))

//Junkyard SCAR
	Skins.Add((Id=4632, Weapondef=class'KFWeapDef_SCAR', MIC_1P=("WEP_SkinSet13_MAT.junkyard_scar.Junkyard_SCAR_1P_Mint_MIC", "WEP_SkinSet13_MAT.junkyard_scar.Junkyard_SCAR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet13_MAT.junkyard_scar.Junkyard_SCAR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet13_MAT.junkyard_scar.Junkyard_SCAR_3P_Pickup_MIC"))
	Skins.Add((Id=4631, Weapondef=class'KFWeapDef_SCAR', MIC_1P=("WEP_SkinSet13_MAT.junkyard_scar.Junkyard_SCAR_1P_FieldTested_MIC", "WEP_SkinSet13_MAT.junkyard_scar.Junkyard_SCAR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet13_MAT.junkyard_scar.Junkyard_SCAR_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet13_MAT.junkyard_scar.Junkyard_SCAR_3P_Pickup_MIC"))
	Skins.Add((Id=4630, Weapondef=class'KFWeapDef_SCAR', MIC_1P=("WEP_SkinSet13_MAT.junkyard_scar.Junkyard_SCAR_1P_BattleScarred_MIC", "WEP_SkinSet13_MAT.junkyard_scar.Junkyard_SCAR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet13_MAT.junkyard_scar.Junkyard_SCAR_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet13_MAT.junkyard_scar.Junkyard_SCAR_3P_Pickup_MIC"))

//Junkyard Winchester 1894
	Skins.Add((Id=4635, Weapondef=class'KFWeapDef_Winchester1894', MIC_1P=("WEP_SkinSet13_MAT.junkyard_winchester1894.Junkyard_Winchester1894_1P_Mint_MIC"), MIC_3P="WEP_SkinSet13_MAT.junkyard_winchester1894.Junkyard_Winchester1894_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet13_MAT.junkyard_winchester1894.Junkyard_Winchester1894_3P_Pickup_MIC"))
 	Skins.Add((Id=4634, Weapondef=class'KFWeapDef_Winchester1894', MIC_1P=("WEP_SkinSet13_MAT.junkyard_winchester1894.Junkyard_Winchester1894_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet13_MAT.junkyard_winchester1894.Junkyard_Winchester1894_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet13_MAT.junkyard_winchester1894.Junkyard_Winchester1894_3P_Pickup_MIC"))
	Skins.Add((Id=4633, Weapondef=class'KFWeapDef_Winchester1894', MIC_1P=("WEP_SkinSet13_MAT.junkyard_winchester1894.Junkyard_Winchester1894_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet13_MAT.junkyard_winchester1894.Junkyard_Winchester1894_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet13_MAT.junkyard_winchester1894.Junkyard_Winchester1894_3P_Pickup_MIC"))

//Headshot Weekly Centerfire
	Skins.Add((Id=4933, Weapondef=class'KFWeapDef_CenterfireMB464', MIC_1P=("WEP_1P_Centerfire_MAT.Wep_1stP_Centerfire_Zombie_MIC"), MIC_3P="WEP_3P_Centerfire_MAT.Wep_3rdP_Centerfire_Zombie_MIC", MIC_Pickup="WEP_3P_Centerfire_MAT.Wep_3rdP_Centerfire_Zombie_Pickup_MIC"))

//Horzine Elite White MP5RAS
	Skins.Add((Id=5033, Weapondef=class'KFWeapDef_MP5RAS', MIC_1P=("WEP_SkinSet15_MAT.horzineelitewhite_mp5ras.HorzineEliteWhite_MP5RAS_1P_Mint_MIC"), MIC_3P="WEP_SkinSet15_MAT.horzineelitewhite_mp5ras.HorzineEliteWhite_MP5RAS_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet15_MAT.horzineelitewhite_mp5ras.HorzineEliteWhite_MP5RAS_3P_Pickup_MIC"))
 	Skins.Add((Id=5032, Weapondef=class'KFWeapDef_MP5RAS', MIC_1P=("WEP_SkinSet15_MAT.horzineelitewhite_mp5ras.HorzineEliteWhite_MP5RAS_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet15_MAT.horzineelitewhite_mp5ras.HorzineEliteWhite_MP5RAS_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet15_MAT.horzineelitewhite_mp5ras.HorzineEliteWhite_MP5RAS_3P_Pickup_MIC"))
	Skins.Add((Id=5031, Weapondef=class'KFWeapDef_MP5RAS', MIC_1P=("WEP_SkinSet15_MAT.horzineelitewhite_mp5ras.HorzineEliteWhite_MP5RAS_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet15_MAT.horzineelitewhite_mp5ras.HorzineEliteWhite_MP5RAS_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet15_MAT.horzineelitewhite_mp5ras.HorzineEliteWhite_MP5RAS_3P_Pickup_MIC"))

//Horzine Elite Black MP5RAS
	Skins.Add((Id=5036, Weapondef=class'KFWeapDef_MP5RAS', MIC_1P=("WEP_SkinSet15_MAT.horzineeliteblack_mp5ras.HorzineEliteBlack_MP5RAS_1P_Mint_MIC"), MIC_3P="WEP_SkinSet15_MAT.horzineeliteblack_mp5ras.HorzineEliteBlack_MP5RAS_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet15_MAT.horzineeliteblack_mp5ras.HorzineEliteBlack_MP5RAS_3P_Pickup_MIC"))
 	Skins.Add((Id=5035, Weapondef=class'KFWeapDef_MP5RAS', MIC_1P=("WEP_SkinSet15_MAT.horzineeliteblack_mp5ras.HorzineEliteBlack_MP5RAS_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet15_MAT.horzineeliteblack_mp5ras.HorzineEliteBlack_MP5RAS_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet15_MAT.horzineeliteblack_mp5ras.HorzineEliteBlack_MP5RAS_3P_Pickup_MIC"))
	Skins.Add((Id=5034, Weapondef=class'KFWeapDef_MP5RAS', MIC_1P=("WEP_SkinSet15_MAT.horzineeliteblack_mp5ras.HorzineEliteBlack_MP5RAS_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet15_MAT.horzineeliteblack_mp5ras.HorzineEliteBlack_MP5RAS_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet15_MAT.horzineeliteblack_mp5ras.HorzineEliteBlack_MP5RAS_3P_Pickup_MIC"))

//Horzine Elite Green MP5RAS
	Skins.Add((Id=5039, Weapondef=class'KFWeapDef_MP5RAS', MIC_1P=("WEP_SkinSet15_MAT.horzineelitegreen_mp5ras.HorzineEliteGreen_MP5RAS_1P_Mint_MIC"), MIC_3P="WEP_SkinSet15_MAT.horzineelitegreen_mp5ras.HorzineEliteGreen_MP5RAS_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet15_MAT.horzineelitegreen_mp5ras.HorzineEliteGreen_MP5RAS_3P_Pickup_MIC"))
 	Skins.Add((Id=5038, Weapondef=class'KFWeapDef_MP5RAS', MIC_1P=("WEP_SkinSet15_MAT.horzineelitegreen_mp5ras.HorzineEliteGreen_MP5RAS_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet15_MAT.horzineelitegreen_mp5ras.HorzineEliteGreen_MP5RAS_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet15_MAT.horzineelitegreen_mp5ras.HorzineEliteGreen_MP5RAS_3P_Pickup_MIC"))
	Skins.Add((Id=5037, Weapondef=class'KFWeapDef_MP5RAS', MIC_1P=("WEP_SkinSet15_MAT.horzineelitegreen_mp5ras.HorzineEliteGreen_MP5RAS_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet15_MAT.horzineelitegreen_mp5ras.HorzineEliteGreen_MP5RAS_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet15_MAT.horzineelitegreen_mp5ras.HorzineEliteGreen_MP5RAS_3P_Pickup_MIC"))

//Horzine Elite Blue MP5RAS
	Skins.Add((Id=5042, Weapondef=class'KFWeapDef_MP5RAS', MIC_1P=("WEP_SkinSet15_MAT.horzineeliteblue_mp5ras.HorzineEliteBlue_MP5RAS_1P_Mint_MIC"), MIC_3P="WEP_SkinSet15_MAT.horzineeliteblue_mp5ras.HorzineEliteBlue_MP5RAS_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet15_MAT.horzineeliteblue_mp5ras.HorzineEliteBlue_MP5RAS_3P_Pickup_MIC"))
 	Skins.Add((Id=5041, Weapondef=class'KFWeapDef_MP5RAS', MIC_1P=("WEP_SkinSet15_MAT.horzineeliteblue_mp5ras.HorzineEliteBlue_MP5RAS_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet15_MAT.horzineeliteblue_mp5ras.HorzineEliteBlue_MP5RAS_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet15_MAT.horzineeliteblue_mp5ras.HorzineEliteBlue_MP5RAS_3P_Pickup_MIC"))
	Skins.Add((Id=5040, Weapondef=class'KFWeapDef_MP5RAS', MIC_1P=("WEP_SkinSet15_MAT.horzineeliteblue_mp5ras.HorzineEliteBlue_MP5RAS_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet15_MAT.horzineeliteblue_mp5ras.HorzineEliteBlue_MP5RAS_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet15_MAT.horzineeliteblue_mp5ras.HorzineEliteBlue_MP5RAS_3P_Pickup_MIC"))

//Horzine Elite Red MP5RAS
	Skins.Add((Id=5045, Weapondef=class'KFWeapDef_MP5RAS', MIC_1P=("WEP_SkinSet15_MAT.horzineelitered_mp5ras.HorzineEliteRed_MP5RAS_1P_Mint_MIC"), MIC_3P="WEP_SkinSet15_MAT.horzineelitered_mp5ras.HorzineEliteRed_MP5RAS_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet15_MAT.horzineelitered_mp5ras.HorzineEliteRed_MP5RAS_3P_Pickup_MIC"))
 	Skins.Add((Id=5044, Weapondef=class'KFWeapDef_MP5RAS', MIC_1P=("WEP_SkinSet15_MAT.horzineelitered_mp5ras.HorzineEliteRed_MP5RAS_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet15_MAT.horzineelitered_mp5ras.HorzineEliteRed_MP5RAS_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet15_MAT.horzineelitered_mp5ras.HorzineEliteRed_MP5RAS_3P_Pickup_MIC"))
	Skins.Add((Id=5043, Weapondef=class'KFWeapDef_MP5RAS', MIC_1P=("WEP_SkinSet15_MAT.horzineelitered_mp5ras.HorzineEliteRed_MP5RAS_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet15_MAT.horzineelitered_mp5ras.HorzineEliteRed_MP5RAS_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet15_MAT.horzineelitered_mp5ras.HorzineEliteRed_MP5RAS_3P_Pickup_MIC"))

//Halloween 9mm
	Skins.Add((Id=5115, Weapondef=class'KFWeapDef_9mm', MIC_1P=("WEP_SkinSet14_MAT.halloween_9mm.Halloween_9MM_1P_Mint_MIC"), MIC_3P="WEP_SkinSet14_MAT.halloween_9mm.Halloween_9MM_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet14_MAT.halloween_9mm.Halloween_9MM_3P_Pickup_MIC"))
 	Skins.Add((Id=5114, Weapondef=class'KFWeapDef_9mm', MIC_1P=("WEP_SkinSet14_MAT.halloween_9mm.Halloween_9MM_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet14_MAT.halloween_9mm.Halloween_9MM_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet14_MAT.halloween_9mm.Halloween_9MM_3P_Pickup_MIC"))
	Skins.Add((Id=5113, Weapondef=class'KFWeapDef_9mm', MIC_1P=("WEP_SkinSet14_MAT.halloween_9mm.Halloween_9MM_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet14_MAT.halloween_9mm.Halloween_9MM_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet14_MAT.halloween_9mm.Halloween_9MM_3P_Pickup_MIC"))

//Halloween Crossbow
	Skins.Add((Id=5118, Weapondef=class'KFWeapDef_Crossbow', MIC_1P=("WEP_SkinSet14_MAT.halloween_crossbow.Halloween_Crossbow_1P_Mint_MIC"), MIC_3P="WEP_SkinSet14_MAT.halloween_crossbow.Halloween_Crossbow_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet14_MAT.halloween_crossbow.Halloween_Crossbow_3P_Pickup_MIC"))
 	Skins.Add((Id=5117, Weapondef=class'KFWeapDef_Crossbow', MIC_1P=("WEP_SkinSet14_MAT.halloween_crossbow.Halloween_Crossbow_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet14_MAT.halloween_crossbow.Halloween_Crossbow_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet14_MAT.halloween_crossbow.Halloween_Crossbow_3P_Pickup_MIC"))
	Skins.Add((Id=5116, Weapondef=class'KFWeapDef_Crossbow', MIC_1P=("WEP_SkinSet14_MAT.halloween_crossbow.Halloween_Crossbow_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet14_MAT.halloween_crossbow.Halloween_Crossbow_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet14_MAT.halloween_crossbow.Halloween_Crossbow_3P_Pickup_MIC"))

//Halloween Flamethrower
	Skins.Add((Id=5121, Weapondef=class'KFWeapDef_FlameThrower', MIC_1P=("WEP_SkinSet14_MAT.halloween_flamethrower.Halloween_Flamethrower_1P_Mint_MIC"), MIC_3P="WEP_SkinSet14_MAT.halloween_flamethrower.Halloween_Flamethrower_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet14_MAT.halloween_flamethrower.Halloween_Flamethrower_3P_Pickup_MIC"))
 	Skins.Add((Id=5120, Weapondef=class'KFWeapDef_FlameThrower', MIC_1P=("WEP_SkinSet14_MAT.halloween_flamethrower.Halloween_Flamethrower_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet14_MAT.halloween_flamethrower.Halloween_Flamethrower_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet14_MAT.halloween_flamethrower.Halloween_Flamethrower_3P_Pickup_MIC"))
	Skins.Add((Id=5119, Weapondef=class'KFWeapDef_FlameThrower', MIC_1P=("WEP_SkinSet14_MAT.halloween_flamethrower.Halloween_Flamethrower_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet14_MAT.halloween_flamethrower.Halloween_Flamethrower_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet14_MAT.halloween_flamethrower.Halloween_Flamethrower_3P_Pickup_MIC"))

//Halloween Healer
	Skins.Add((Id=5124, Weapondef=class'KFWeapDef_Healer', MIC_1P=("WEP_SkinSet14_MAT.halloween_healer.Halloween_Healer_1P_Mint_MIC"), MIC_3P="WEP_SkinSet14_MAT.halloween_healer.Halloween_Healer_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet14_MAT.halloween_healer.Halloween_Healer_3P_Pickup_MIC"))
 	Skins.Add((Id=5123, Weapondef=class'KFWeapDef_Healer', MIC_1P=("WEP_SkinSet14_MAT.halloween_healer.Halloween_Healer_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet14_MAT.halloween_healer.Halloween_Healer_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet14_MAT.halloween_healer.Halloween_Healer_3P_Pickup_MIC"))
	Skins.Add((Id=5122, Weapondef=class'KFWeapDef_Healer', MIC_1P=("WEP_SkinSet14_MAT.halloween_healer.Halloween_Healer_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet14_MAT.halloween_healer.Halloween_Healer_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet14_MAT.halloween_healer.Halloween_Healer_3P_Pickup_MIC"))

//Halloween HZ12
	Skins.Add((Id=5127, Weapondef=class'KFWeapDef_HZ12', MIC_1P=("WEP_SkinSet14_MAT.halloween_hz12.Halloween_HZ12_1P_Mint_MIC"), MIC_3P="WEP_SkinSet14_MAT.halloween_hz12.Halloween_HZ12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet14_MAT.halloween_hz12.Halloween_HZ12_3P_Pickup_MIC"))
 	Skins.Add((Id=5126, Weapondef=class'KFWeapDef_HZ12', MIC_1P=("WEP_SkinSet14_MAT.halloween_hz12.Halloween_HZ12_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet14_MAT.halloween_hz12.Halloween_HZ12_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet14_MAT.halloween_hz12.Halloween_HZ12_3P_Pickup_MIC"))
	Skins.Add((Id=5125, Weapondef=class'KFWeapDef_HZ12', MIC_1P=("WEP_SkinSet14_MAT.halloween_hz12.Halloween_HZ12_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet14_MAT.halloween_hz12.Halloween_HZ12_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet14_MAT.halloween_hz12.Halloween_HZ12_3P_Pickup_MIC"))

//Halloween Katana
	Skins.Add((Id=5130, Weapondef=class'KFWeapDef_Katana', MIC_1P=("WEP_SkinSet14_MAT.halloween_katana.Halloween_Katana_1P_Mint_MIC"), MIC_3P="WEP_SkinSet14_MAT.halloween_katana.Halloween_Katana_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet14_MAT.halloween_katana.Halloween_Katana_3P_Pickup_MIC"))
 	Skins.Add((Id=5129, Weapondef=class'KFWeapDef_Katana', MIC_1P=("WEP_SkinSet14_MAT.halloween_katana.Halloween_Katana_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet14_MAT.halloween_katana.Halloween_Katana_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet14_MAT.halloween_katana.Halloween_Katana_3P_Pickup_MIC"))
	Skins.Add((Id=5128, Weapondef=class'KFWeapDef_Katana', MIC_1P=("WEP_SkinSet14_MAT.halloween_katana.Halloween_Katana_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet14_MAT.halloween_katana.Halloween_Katana_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet14_MAT.halloween_katana.Halloween_Katana_3P_Pickup_MIC"))

//Halloween Kriss
	Skins.Add((Id=5133, Weapondef=class'KFWeapDef_Kriss', MIC_1P=("WEP_SkinSet14_MAT.halloween_kriss.Halloween_Kriss_1P_Mint_MIC"), MIC_3P="WEP_SkinSet14_MAT.halloween_kriss.Halloween_Kriss_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet14_MAT.halloween_kriss.Halloween_Kriss_3P_Pickup_MIC"))
 	Skins.Add((Id=5132, Weapondef=class'KFWeapDef_Kriss', MIC_1P=("WEP_SkinSet14_MAT.halloween_kriss.Halloween_Kriss_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet14_MAT.halloween_kriss.Halloween_Kriss_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet14_MAT.halloween_kriss.Halloween_Kriss_3P_Pickup_MIC"))
	Skins.Add((Id=5131, Weapondef=class'KFWeapDef_Kriss', MIC_1P=("WEP_SkinSet14_MAT.halloween_kriss.Halloween_Kriss_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet14_MAT.halloween_kriss.Halloween_Kriss_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet14_MAT.halloween_kriss.Halloween_Kriss_3P_Pickup_MIC"))

//Halloween M79
	Skins.Add((Id=5136, Weapondef=class'KFWeapDef_M79', MIC_1P=("WEP_SkinSet14_MAT.halloween_m79.Halloween_M79_1P_Mint_MIC"), MIC_3P="WEP_SkinSet14_MAT.halloween_m79.Halloween_M79_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet14_MAT.halloween_m79.Halloween_M79_3P_Pickup_MIC"))
 	Skins.Add((Id=5135, Weapondef=class'KFWeapDef_M79', MIC_1P=("WEP_SkinSet14_MAT.halloween_m79.Halloween_M79_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet14_MAT.halloween_m79.Halloween_M79_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet14_MAT.halloween_m79.Halloween_M79_3P_Pickup_MIC"))
	Skins.Add((Id=5134, Weapondef=class'KFWeapDef_M79', MIC_1P=("WEP_SkinSet14_MAT.halloween_m79.Halloween_M79_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet14_MAT.halloween_m79.Halloween_M79_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet14_MAT.halloween_m79.Halloween_M79_3P_Pickup_MIC"))

//Halloween Stoner 63A
	Skins.Add((Id=5139, Weapondef=class'KFWeapDef_Stoner63A', MIC_1P=("WEP_SkinSet14_MAT.halloween_stoner63a.Halloween_Stoner63a_1P_Mint_MIC", "WEP_SkinSet14_MAT.halloween_stoner63a.Halloween_Stoner63a_Receiver_1P_Mint_MIC"), MIC_3P="WEP_SkinSet14_MAT.halloween_stoner63a.Halloween_Stoner63a_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet14_MAT.halloween_stoner63a.Halloween_Stoner63a_3P_Pickup_MIC"))
 	Skins.Add((Id=5138, Weapondef=class'KFWeapDef_Stoner63A', MIC_1P=("WEP_SkinSet14_MAT.halloween_stoner63a.Halloween_Stoner63a_1P_FieldTested_MIC", "WEP_SkinSet14_MAT.halloween_stoner63a.Halloween_Stoner63a_Receiver_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet14_MAT.halloween_stoner63a.Halloween_Stoner63a_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet14_MAT.halloween_stoner63a.Halloween_Stoner63a_3P_Pickup_MIC"))
	Skins.Add((Id=5137, Weapondef=class'KFWeapDef_Stoner63A', MIC_1P=("WEP_SkinSet14_MAT.halloween_stoner63a.Halloween_Stoner63a_1P_BattleScarred_MIC", "WEP_SkinSet14_MAT.halloween_stoner63a.Halloween_Stoner63a_Receiver_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet14_MAT.halloween_stoner63a.Halloween_Stoner63a_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet14_MAT.halloween_stoner63a.Halloween_Stoner63a_3P_Pickup_MIC"))

//Neon MB500
	Skins.Add((Id=5160, Weapondef=class'KFWeapDef_MB500', MIC_1P=("WEP_SkinSet16_MAT.neon_mb500.Neon_MB500_1P_Mint_MIC"), MIC_3P="WEP_SkinSet16_MAT.neon_mb500.Neon_MB500_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet16_MAT.neon_mb500.Neon_MB500_3P_Pickup_MIC"))
 	Skins.Add((Id=5159, Weapondef=class'KFWeapDef_MB500', MIC_1P=("WEP_SkinSet16_MAT.neon_mb500.Neon_MB500_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet16_MAT.neon_mb500.Neon_MB500_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet16_MAT.neon_mb500.Neon_MB500_3P_Pickup_MIC"))
	Skins.Add((Id=5158, Weapondef=class'KFWeapDef_MB500', MIC_1P=("WEP_SkinSet16_MAT.neon_mb500.Neon_MB500_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet16_MAT.neon_mb500.Neon_MB500_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet16_MAT.neon_mb500.Neon_MB500_3P_Pickup_MIC"))

//Neon Railgun
	Skins.Add((Id=5163, Weapondef=class'KFWeapDef_RailGun', MIC_1P=("WEP_SkinSet16_MAT.neon_railgun.Neon_Railgun_1P_Mint_MIC", "WEP_SkinSet16_MAT.neon_railgun.Neon_Railgun_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet16_MAT.neon_railgun.Neon_Railgun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet16_MAT.neon_railgun.Neon_Railgun_3P_Pickup_MIC"))
 	Skins.Add((Id=5162, Weapondef=class'KFWeapDef_RailGun', MIC_1P=("WEP_SkinSet16_MAT.neon_railgun.Neon_Railgun_1P_FieldTested_MIC", "WEP_SkinSet16_MAT.neon_railgun.Neon_Railgun_Scope_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet16_MAT.neon_railgun.Neon_Railgun_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet16_MAT.neon_railgun.Neon_Railgun_3P_Pickup_MIC"))
	Skins.Add((Id=5161, Weapondef=class'KFWeapDef_RailGun', MIC_1P=("WEP_SkinSet16_MAT.neon_railgun.Neon_Railgun_1P_BattleScarred_MIC", "WEP_SkinSet16_MAT.neon_railgun.Neon_Railgun_Scope_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet16_MAT.neon_railgun.Neon_Railgun_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet16_MAT.neon_railgun.Neon_Railgun_3P_Pickup_MIC"))

//Neon RPG7
	Skins.Add((Id=5166, Weapondef=class'KFWeapDef_RPG7', MIC_1P=("WEP_SkinSet16_MAT.neon_rpg7.Neon_RPG7_1P_Mint_MIC"), MIC_3P="WEP_SkinSet16_MAT.neon_rpg7.Neon_RPG7_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet16_MAT.neon_rpg7.Neon_RPG7_3P_Pickup_MIC"))
 	Skins.Add((Id=5165, Weapondef=class'KFWeapDef_RPG7', MIC_1P=("WEP_SkinSet16_MAT.neon_rpg7.Neon_RPG7_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet16_MAT.neon_rpg7.Neon_RPG7_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet16_MAT.neon_rpg7.Neon_RPG7_3P_Pickup_MIC"))
	Skins.Add((Id=5164, Weapondef=class'KFWeapDef_RPG7', MIC_1P=("WEP_SkinSet16_MAT.neon_rpg7.Neon_RPG7_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet16_MAT.neon_rpg7.Neon_RPG7_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet16_MAT.neon_rpg7.Neon_RPG7_3P_Pickup_MIC"))

//Neon Scar
	Skins.Add((Id=5169, Weapondef=class'KFWeapDef_SCAR', MIC_1P=("WEP_SkinSet16_MAT.neon_scar.Neon_SCAR_1P_Mint_MIC", "WEP_SkinSet16_MAT.neon_scar.Neon_SCAR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet16_MAT.neon_scar.Neon_SCAR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet16_MAT.neon_scar.Neon_SCAR_3P_Pickup_MIC"))
 	Skins.Add((Id=5168, Weapondef=class'KFWeapDef_SCAR', MIC_1P=("WEP_SkinSet16_MAT.neon_scar.Neon_SCAR_1P_FieldTested_MIC", "WEP_SkinSet16_MAT.neon_scar.Neon_SCAR_Scope_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet16_MAT.neon_scar.Neon_SCAR_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet16_MAT.neon_scar.Neon_SCAR_3P_Pickup_MIC"))
	Skins.Add((Id=5167, Weapondef=class'KFWeapDef_SCAR', MIC_1P=("WEP_SkinSet16_MAT.neon_scar.Neon_SCAR_1P_BattleScarred_MIC", "WEP_SkinSet16_MAT.neon_scar.Neon_SCAR_Scope_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet16_MAT.neon_scar.Neon_SCAR_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet16_MAT.neon_scar.Neon_SCAR_3P_Pickup_MIC"))

//Neon M1911
	Skins.Add((Id=5172, Weapondef=class'KFWeapDef_Colt1911', MIC_1P=("WEP_SkinSet16_MAT.neon_m1911.Neon_M1911_1P_Mint_MIC"), MIC_3P="WEP_SkinSet16_MAT.neon_m1911.Neon_M1911_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet16_MAT.neon_m1911.Neon_M1911_3P_Pickup_MIC"))
 	Skins.Add((Id=5171, Weapondef=class'KFWeapDef_Colt1911', MIC_1P=("WEP_SkinSet16_MAT.neon_m1911.Neon_M1911_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet16_MAT.neon_m1911.Neon_M1911_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet16_MAT.neon_m1911.Neon_M1911_3P_Pickup_MIC"))
	Skins.Add((Id=5170, Weapondef=class'KFWeapDef_Colt1911', MIC_1P=("WEP_SkinSet16_MAT.neon_m1911.Neon_M1911_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet16_MAT.neon_m1911.Neon_M1911_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet16_MAT.neon_m1911.Neon_M1911_3P_Pickup_MIC"))

//Neon Katana
	Skins.Add((Id=5175, Weapondef=class'KFWeapDef_Katana', MIC_1P=("WEP_SkinSet16_MAT.neon_katana.Neon_Katana_1P_Mint_MIC"), MIC_3P="WEP_SkinSet16_MAT.neon_katana.Neon_Katana_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet16_MAT.neon_katana.Neon_Katana_3P_Pickup_MIC"))
 	Skins.Add((Id=5174, Weapondef=class'KFWeapDef_Katana', MIC_1P=("WEP_SkinSet16_MAT.neon_katana.Neon_Katana_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet16_MAT.neon_katana.Neon_Katana_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet16_MAT.neon_katana.Neon_Katana_3P_Pickup_MIC"))
	Skins.Add((Id=5173, Weapondef=class'KFWeapDef_Katana', MIC_1P=("WEP_SkinSet16_MAT.neon_katana.Neon_Katana_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet16_MAT.neon_katana.Neon_Katana_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet16_MAT.neon_katana.Neon_Katana_3P_Pickup_MIC"))

//Neon Dragonsbreath
	Skins.Add((Id=5178, Weapondef=class'KFWeapDef_DragonsBreath', MIC_1P=("WEP_SkinSet16_MAT.neon_dragonsbreath.Neon_DragonsBreath_1P_Mint_MIC"), MIC_3P="WEP_SkinSet16_MAT.neon_dragonsbreath.Neon_DragonsBreath_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet16_MAT.neon_dragonsbreath.Neon_DragonsBreath_3P_Pickup_MIC"))
 	Skins.Add((Id=5177, Weapondef=class'KFWeapDef_DragonsBreath', MIC_1P=("WEP_SkinSet16_MAT.neon_dragonsbreath.Neon_DragonsBreath_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet16_MAT.neon_dragonsbreath.Neon_DragonsBreath_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet16_MAT.neon_dragonsbreath.Neon_DragonsBreath_3P_Pickup_MIC"))
	Skins.Add((Id=5176, Weapondef=class'KFWeapDef_DragonsBreath', MIC_1P=("WEP_SkinSet16_MAT.neon_dragonsbreath.Neon_DragonsBreath_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet16_MAT.neon_dragonsbreath.Neon_DragonsBreath_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet16_MAT.neon_dragonsbreath.Neon_DragonsBreath_3P_Pickup_MIC"))

//Neon Kriss
	Skins.Add((Id=5181, Weapondef=class'KFWeapDef_Kriss', MIC_1P=("WEP_SkinSet16_MAT.neon_kriss.Neon_KRISS_1P_Mint_MIC", "WEP_SkinSet16_MAT.neon_kriss.Neon_KRISS_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet16_MAT.neon_kriss.Neon_KRISS_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet16_MAT.neon_kriss.Neon_KRISS_3P_Pickup_MIC"))
 	Skins.Add((Id=5180, Weapondef=class'KFWeapDef_Kriss', MIC_1P=("WEP_SkinSet16_MAT.neon_kriss.Neon_KRISS_1P_FieldTested_MIC", "WEP_SkinSet16_MAT.neon_kriss.Neon_KRISS_Sight_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet16_MAT.neon_kriss.Neon_KRISS_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet16_MAT.neon_kriss.Neon_KRISS_3P_Pickup_MIC"))
	Skins.Add((Id=5179, Weapondef=class'KFWeapDef_Kriss', MIC_1P=("WEP_SkinSet16_MAT.neon_kriss.Neon_KRISS_1P_BattleScarred_MIC", "WEP_SkinSet16_MAT.neon_kriss.Neon_KRISS_Sight_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet16_MAT.neon_kriss.Neon_KRISS_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet16_MAT.neon_kriss.Neon_KRISS_3P_Pickup_MIC"))

//Vault Pink MP7
	Skins.Add((Id=5291, Weapondef=class'KFWeapDef_MP7', MIC_1P=("WEP_SkinSet17_MAT.cute_mp7.Vault_Cute_MP7_1P_Mint_MIC", "WEP_SkinSet17_MAT.cute_mp7.Vault_Cute_MP7_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet17_MAT.cute_mp7.Vault_Cute_MP7_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet17_MAT.cute_mp7.Vault_Cute_MP7_3P_Pickup_MIC"))
 	Skins.Add((Id=5290, Weapondef=class'KFWeapDef_MP7', MIC_1P=("WEP_SkinSet17_MAT.cute_mp7.Vault_Cute_MP7_1P_FieldTested_MIC", "WEP_SkinSet17_MAT.cute_mp7.Vault_Cute_MP7_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet17_MAT.cute_mp7.Vault_Cute_MP7_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet17_MAT.cute_mp7.Vault_Cute_MP7_3P_Pickup_MIC"))
	Skins.Add((Id=5289, Weapondef=class'KFWeapDef_MP7', MIC_1P=("WEP_SkinSet17_MAT.cute_mp7.Vault_Cute_MP7_1P_BattleScarred_MIC", "WEP_SkinSet17_MAT.cute_mp7.Vault_Cute_MP7_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet17_MAT.cute_mp7.Vault_Cute_MP7_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet17_MAT.cute_mp7.Vault_Cute_MP7_3P_Pickup_MIC"))

//Vault Honorable Death AK12
	Skins.Add((Id=5294, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet17_MAT.horror_ak12.Vault_Horror_AK12_1P_Mint_MIC"), MIC_3P="WEP_SkinSet17_MAT.horror_ak12.Vault_Horror_AK12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet17_MAT.horror_ak12.Vault_Horror_AK12_3P_Pickup_MIC"))
	Skins.Add((Id=5293, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet17_MAT.horror_ak12.Vault_Horror_AK12_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet17_MAT.horror_ak12.Vault_Horror_AK12_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet17_MAT.horror_ak12.Vault_Horror_AK12_3P_Pickup_MIC"))
	Skins.Add((Id=5292, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet17_MAT.horror_ak12.Vault_Horror_AK12_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet17_MAT.horror_ak12.Vault_Horror_AK12_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet17_MAT.horror_ak12.Vault_Horror_AK12_3P_Pickup_MIC"))

//Vault Blue Camo Crovel
	Skins.Add((Id=5297, Weapondef=class'KFWeapDef_Crovel', MIC_1P=("WEP_SkinSet17_MAT.military_crovel.Vault_Military_Crovel_1P_Mint_MIC"), MIC_3P="WEP_SkinSet17_MAT.military_crovel.Vault_Military_Crovel_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet17_MAT.military_crovel.Vault_Military_Crovel_3P_Pickup_MIC"))
	Skins.Add((Id=5296, Weapondef=class'KFWeapDef_Crovel', MIC_1P=("WEP_SkinSet17_MAT.military_crovel.Vault_Military_Crovel_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet17_MAT.military_crovel.Vault_Military_Crovel_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet17_MAT.military_crovel.Vault_Military_Crovel_3P_Pickup_MIC"))
	Skins.Add((Id=5295, Weapondef=class'KFWeapDef_Crovel', MIC_1P=("WEP_SkinSet17_MAT.military_crovel.Vault_Military_Crovel_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet17_MAT.military_crovel.Vault_Military_Crovel_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet17_MAT.military_crovel.Vault_Military_Crovel_3P_Pickup_MIC"))

//Vault Sci Fi Caulk N Burn
	Skins.Add((Id=5300, Weapondef=class'KFWeapDef_CaulkBurn', MIC_1P=("WEP_SkinSet17_MAT.scifi_caulknburn.Vault_SciFi_CaulkNBurn_1P_Mint_MIC"), MIC_3P="WEP_SkinSet17_MAT.scifi_caulknburn.Vault_SciFi_CaulkNBurn_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet17_MAT.scifi_caulknburn.Vault_SciFi_CaulkNBurn_3P_Pickup_MIC"))
	Skins.Add((Id=5299, Weapondef=class'KFWeapDef_CaulkBurn', MIC_1P=("WEP_SkinSet17_MAT.scifi_caulknburn.Vault_SciFi_CaulkNBurn_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet17_MAT.scifi_caulknburn.Vault_SciFi_CaulkNBurn_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet17_MAT.scifi_caulknburn.Vault_SciFi_CaulkNBurn_3P_Pickup_MIC"))
	Skins.Add((Id=5298, Weapondef=class'KFWeapDef_CaulkBurn', MIC_1P=("WEP_SkinSet17_MAT.scifi_caulknburn.Vault_SciFi_CaulkNBurn_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet17_MAT.scifi_caulknburn.Vault_SciFi_CaulkNBurn_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet17_MAT.scifi_caulknburn.Vault_SciFi_CaulkNBurn_3P_Pickup_MIC"))

//Vault GG AA12
	Skins.Add((Id=5303, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet17_MAT.sports_aa12.Vault_Sports_AA12_1P_Mint_MIC"), MIC_3P="WEP_SkinSet17_MAT.sports_aa12.Vault_Sports_AA12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet17_MAT.sports_aa12.Vault_Sports_AA12_3P_Pickup_MIC"))
	Skins.Add((Id=5302, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet17_MAT.sports_aa12.Vault_Sports_AA12_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet17_MAT.sports_aa12.Vault_Sports_AA12_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet17_MAT.sports_aa12.Vault_Sports_AA12_3P_Pickup_MIC"))
	Skins.Add((Id=5301, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet17_MAT.sports_aa12.Vault_Sports_AA12_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet17_MAT.sports_aa12.Vault_Sports_AA12_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet17_MAT.sports_aa12.Vault_Sports_AA12_3P_Pickup_MIC"))

//Vault Vosh 9MM
	Skins.Add((Id=5379, Weapondef=class'KFWeapDef_9mm', MIC_1P=("WEP_SkinSet_VaultVosh_MAT.9mm.VaultVosh_9mm_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh_MAT.9mm.VaultVosh_9mm_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh_MAT.9mm.VaultVosh_9mm_3P_Pickup_MIC"))

//Vault Vosh Berserker Knife
	Skins.Add((Id=5380, Weapondef=class'KFWeapDef_Knife_Berserker', MIC_1P=("WEP_SkinSet_VaultVosh_MAT.berserkerknife.VaultVosh_BerserkerKnife_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh_MAT.berserkerknife.VaultVosh_BerserkerKnife_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh_MAT.berserkerknife.VaultVosh_BerserkerKnife_3P_Pickup_MIC"))

//Vault Vosh Commando Knife
	Skins.Add((Id=5381, Weapondef=class'KFWeapDef_Knife_Commando', MIC_1P=("WEP_SkinSet_VaultVosh_MAT.commandoknife.VaultVosh_CommandoKnife_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh_MAT.commandoknife.VaultVosh_CommandoKnife_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh_MAT.commandoknife.VaultVosh_CommandoKnife_3P_Pickup_MIC"))

//Vault Vosh Demo Knife
	Skins.Add((Id=5382, Weapondef=class'KFWeapDef_Knife_Demo', MIC_1P=("WEP_SkinSet_VaultVosh_MAT.demoknife.VaultVosh_DemoKnife_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh_MAT.demoknife.VaultVosh_DemoKnife_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh_MAT.demoknife.VaultVosh_DemoKnife_3P_Pickup_MIC"))

//Vault Vosh Firebug Knife
	Skins.Add((Id=5383, Weapondef=class'KFWeapDef_Knife_Firebug', MIC_1P=("WEP_SkinSet_VaultVosh_MAT.firebugknife.VaultVosh_FireBugKnife_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh_MAT.firebugknife.VaultVosh_FireBugKnife_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh_MAT.firebugknife.VaultVosh_FireBugKnife_3P_Pickup_MIC"))

//Vault Vosh Gunslinger Knife
	Skins.Add((Id=5384, Weapondef=class'KFWeapDef_Knife_Gunslinger', MIC_1P=("WEP_SkinSet_VaultVosh_MAT.gunslingerknife.VaultVosh_GunslingerKnife_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh_MAT.gunslingerknife.VaultVosh_GunslingerKnife_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh_MAT.gunslingerknife.VaultVosh_GunslingerKnife_3P_Pickup_MIC"))

//Vault Vosh Healer
	Skins.Add((Id=5385, Weapondef=class'KFWeapDef_Healer', MIC_1P=("WEP_SkinSet_VaultVosh_MAT.Healer.VaultVosh_Healer_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh_MAT.Healer.VaultVosh_Healer_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh_MAT.Healer.VaultVosh_Healer_3P_Pickup_MIC"))

//Vault Vosh Medic Knife
	Skins.Add((Id=5386, Weapondef=class'KFWeapDef_Knife_Medic', MIC_1P=("WEP_SkinSet_VaultVosh_MAT.medicknife.VaultVosh_MedicKnife_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh_MAT.medicknife.VaultVosh_MedicKnife_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh_MAT.medicknife.VaultVosh_MedicKnife_3P_Pickup_MIC"))

//Vault Vosh Sharpshooter Knife
	Skins.Add((Id=5387, Weapondef=class'KFWeapDef_Knife_Sharpshooter', MIC_1P=("WEP_SkinSet_VaultVosh_MAT.sharpshooterknife.VaultVosh_SharpshooterKnife_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh_MAT.sharpshooterknife.VaultVosh_SharpshooterKnife_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh_MAT.sharpshooterknife.VaultVosh_SharpshooterKnife_3P_Pickup_MIC"))

//Vault Vosh Support Knife
	Skins.Add((Id=5388, Weapondef=class'KFWeapDef_Knife_Support', MIC_1P=("WEP_SkinSet_VaultVosh_MAT.supportknife.VaultVosh_SupportKnife_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh_MAT.supportknife.VaultVosh_SupportKnife_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh_MAT.supportknife.VaultVosh_SupportKnife_3P_Pickup_MIC"))

//Vault Vosh SWAT Knife
	Skins.Add((Id=5389, Weapondef=class'KFWeapDef_Knife_SWAT', MIC_1P=("WEP_SkinSet_VaultVosh_MAT.swatknife.VaultVosh_SwatKnife_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh_MAT.swatknife.VaultVosh_SwatKnife_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh_MAT.swatknife.VaultVosh_SwatKnife_3P_Pickup_MIC"))

//Vault Vosh Welder
	Skins.Add((Id=5390, Weapondef=class'KFWeapDef_Welder', MIC_1P=("WEP_SkinSet_VaultVosh_MAT.Welder.VaultVosh_Welder_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh_MAT.Welder.VaultVosh_Welder_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh_MAT.Welder.VaultVosh_Welder_3P_Pickup_MIC"))

//Vault Blue Camo Remington 1858
	Skins.Add((Id=5527, Weapondef=class'KFWeapDef_Remington1858', MIC_1P=("WEP_SkinSet_VaultVosh_MAT.1858.VaultErdlBlue_1858_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh_MAT.1858.VaultErdlBlue_1858_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh_MAT.1858.VaultErdlBlue_1858_3P_Pickup_MIC"))
	Skins.Add((Id=5526, Weapondef=class'KFWeapDef_Remington1858', MIC_1P=("WEP_SkinSet_VaultVosh_MAT.1858.VaultErdlBlue_1858_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet_VaultVosh_MAT.1858.VaultErdlBlue_1858_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh_MAT.1858.VaultErdlBlue_1858_3P_Pickup_MIC"))
	Skins.Add((Id=5525, Weapondef=class'KFWeapDef_Remington1858', MIC_1P=("WEP_SkinSet_VaultVosh_MAT.1858.VaultErdlBlue_1858_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet_VaultVosh_MAT.1858.VaultErdlBlue_1858_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh_MAT.1858.VaultErdlBlue_1858_3P_Pickup_MIC"))

//Vault Blue Camo Winchester 1894
	Skins.Add((Id=5530, Weapondef=class'KFWeapDef_Winchester1894', MIC_1P=("WEP_SkinSet_VaultVosh_MAT.1894.VaultErdlBlue_1894_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh_MAT.1894.VaultErdlBlue_1894_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh_MAT.1894.VaultErdlBlue_1894_3P_Pickup_MIC"))
	Skins.Add((Id=5529, Weapondef=class'KFWeapDef_Winchester1894', MIC_1P=("WEP_SkinSet_VaultVosh_MAT.1894.VaultErdlBlue_1894_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet_VaultVosh_MAT.1894.VaultErdlBlue_1894_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh_MAT.1894.VaultErdlBlue_1894_3P_Pickup_MIC"))
	Skins.Add((Id=5528, Weapondef=class'KFWeapDef_Winchester1894', MIC_1P=("WEP_SkinSet_VaultVosh_MAT.1894.VaultErdlBlue_1894_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet_VaultVosh_MAT.1894.VaultErdlBlue_1894_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh_MAT.1894.VaultErdlBlue_1894_3P_Pickup_MIC"))

//Vault Blue Camo AR15
	Skins.Add((Id=5533, Weapondef=class'KFWeapDef_AR15', MIC_1P=("WEP_SkinSet_VaultVosh_MAT.AR15.VaultErdlBlue_AR15_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh_MAT.AR15.VaultErdlBlue_AR15_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh_MAT.AR15.VaultErdlBlue_AR15_3P_Pickup_MIC"))
	Skins.Add((Id=5532, Weapondef=class'KFWeapDef_AR15', MIC_1P=("WEP_SkinSet_VaultVosh_MAT.AR15.VaultErdlBlue_AR15_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet_VaultVosh_MAT.AR15.VaultErdlBlue_AR15_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh_MAT.AR15.VaultErdlBlue_AR15_3P_Pickup_MIC"))
	Skins.Add((Id=5531, Weapondef=class'KFWeapDef_AR15', MIC_1P=("WEP_SkinSet_VaultVosh_MAT.AR15.VaultErdlBlue_AR15_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet_VaultVosh_MAT.AR15.VaultErdlBlue_AR15_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh_MAT.AR15.VaultErdlBlue_AR15_3P_Pickup_MIC"))

//Vault Blue Camo HX25
	Skins.Add((Id=5536, Weapondef=class'KFWeapDef_HX25', MIC_1P=("WEP_SkinSet_VaultVosh_MAT.hx25.VaultErdlBlue_HX25_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh_MAT.hx25.VaultErdlBlue_HX25_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh_MAT.hx25.VaultErdlBlue_HX25_3P_Pickup_MIC"))
	Skins.Add((Id=5535, Weapondef=class'KFWeapDef_HX25', MIC_1P=("WEP_SkinSet_VaultVosh_MAT.hx25.VaultErdlBlue_HX25_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet_VaultVosh_MAT.hx25.VaultErdlBlue_HX25_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh_MAT.hx25.VaultErdlBlue_HX25_3P_Pickup_MIC"))
	Skins.Add((Id=5534, Weapondef=class'KFWeapDef_HX25', MIC_1P=("WEP_SkinSet_VaultVosh_MAT.hx25.VaultErdlBlue_HX25_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet_VaultVosh_MAT.hx25.VaultErdlBlue_HX25_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh_MAT.hx25.VaultErdlBlue_HX25_3P_Pickup_MIC"))

//Vault Blue Camo MB500
	Skins.Add((Id=5539, Weapondef=class'KFWeapDef_MB500', MIC_1P=("WEP_SkinSet_VaultVosh_MAT.MB500.VaultErdlBlue_MB500_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh_MAT.MB500.VaultErdlBlue_MB500_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh_MAT.MB500.VaultErdlBlue_MB500_3P_Pickup_MIC"))
	Skins.Add((Id=5538, Weapondef=class'KFWeapDef_MB500', MIC_1P=("WEP_SkinSet_VaultVosh_MAT.MB500.VaultErdlBlue_MB500_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet_VaultVosh_MAT.MB500.VaultErdlBlue_MB500_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh_MAT.MB500.VaultErdlBlue_MB500_3P_Pickup_MIC"))
	Skins.Add((Id=5537, Weapondef=class'KFWeapDef_MB500', MIC_1P=("WEP_SkinSet_VaultVosh_MAT.MB500.VaultErdlBlue_MB500_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet_VaultVosh_MAT.MB500.VaultErdlBlue_MB500_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh_MAT.MB500.VaultErdlBlue_MB500_3P_Pickup_MIC"))

//Vault Blue Camo Medic Pistol
	Skins.Add((Id=5542, Weapondef=class'KFWeapDef_MedicPistol', MIC_1P=("WEP_SkinSet_VaultVosh_MAT.medicpistol.VaultErdlBlue_MedicPistol_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh_MAT.medicpistol.VaultErdlBlue_MedicPistol_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh_MAT.medicpistol.VaultErdlBlue_MedicPistol_3P_Pickup_MIC"))
	Skins.Add((Id=5541, Weapondef=class'KFWeapDef_MedicPistol', MIC_1P=("WEP_SkinSet_VaultVosh_MAT.medicpistol.VaultErdlBlue_MedicPistol_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet_VaultVosh_MAT.medicpistol.VaultErdlBlue_MedicPistol_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh_MAT.medicpistol.VaultErdlBlue_MedicPistol_3P_Pickup_MIC"))
	Skins.Add((Id=5540, Weapondef=class'KFWeapDef_MedicPistol', MIC_1P=("WEP_SkinSet_VaultVosh_MAT.medicpistol.VaultErdlBlue_MedicPistol_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet_VaultVosh_MAT.medicpistol.VaultErdlBlue_MedicPistol_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh_MAT.medicpistol.VaultErdlBlue_MedicPistol_3P_Pickup_MIC"))

//Vault Green Camo Medic Pistol
	Skins.Add((Id=5545, Weapondef=class'KFWeapDef_MedicPistol', MIC_1P=("WEP_SkinSet_VaultVosh_MAT.medicpistol.VaultErdlGreen_MedicPistol_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh_MAT.medicpistol.VaultErdlGreen_MedicPistol_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh_MAT.medicpistol.VaultErdlGreen_MedicPistol_3P_Pickup_MIC"))
	Skins.Add((Id=5544, Weapondef=class'KFWeapDef_MedicPistol', MIC_1P=("WEP_SkinSet_VaultVosh_MAT.medicpistol.VaultErdlGreen_MedicPistol_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet_VaultVosh_MAT.medicpistol.VaultErdlGreen_MedicPistol_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh_MAT.medicpistol.VaultErdlGreen_MedicPistol_3P_Pickup_MIC"))
	Skins.Add((Id=5543, Weapondef=class'KFWeapDef_MedicPistol', MIC_1P=("WEP_SkinSet_VaultVosh_MAT.medicpistol.VaultErdlGreen_MedicPistol_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet_VaultVosh_MAT.medicpistol.VaultErdlGreen_MedicPistol_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh_MAT.medicpistol.VaultErdlGreen_MedicPistol_3P_Pickup_MIC"))

//Vault Orange Camo Medic Pistol
	Skins.Add((Id=5548, Weapondef=class'KFWeapDef_MedicPistol', MIC_1P=("WEP_SkinSet_VaultVosh_MAT.medicpistol.VaultErdlOrange_MedicPistol_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh_MAT.medicpistol.VaultErdlOrange_MedicPistol_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh_MAT.medicpistol.VaultErdlOrange_MedicPistol_3P_Pickup_MIC"))
	Skins.Add((Id=5547, Weapondef=class'KFWeapDef_MedicPistol', MIC_1P=("WEP_SkinSet_VaultVosh_MAT.medicpistol.VaultErdlOrange_MedicPistol_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet_VaultVosh_MAT.medicpistol.VaultErdlOrange_MedicPistol_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh_MAT.medicpistol.VaultErdlOrange_MedicPistol_3P_Pickup_MIC"))
	Skins.Add((Id=5546, Weapondef=class'KFWeapDef_MedicPistol', MIC_1P=("WEP_SkinSet_VaultVosh_MAT.medicpistol.VaultErdlOrange_MedicPistol_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet_VaultVosh_MAT.medicpistol.VaultErdlOrange_MedicPistol_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh_MAT.medicpistol.VaultErdlOrange_MedicPistol_3P_Pickup_MIC"))

//Vault Blue Camo MP7
	Skins.Add((Id=5551, Weapondef=class'KFWeapDef_MP7', MIC_1P=("WEP_SkinSet_VaultVosh_MAT.mp7.VaultErdlBlue_MP7_1P_Mint_MIC", "WEP_SkinSet_VaultVosh_MAT.mp7.VaultErdlBlue_MP7_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh_MAT.mp7.VaultErdlBlue_MP7_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh_MAT.mp7.VaultErdlBlue_MP7_3P_Pickup_MIC"))
	Skins.Add((Id=5550, Weapondef=class'KFWeapDef_MP7', MIC_1P=("WEP_SkinSet_VaultVosh_MAT.mp7.VaultErdlBlue_MP7_1P_FieldTested_MIC", "WEP_SkinSet_VaultVosh_MAT.mp7.VaultErdlBlue_MP7_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh_MAT.mp7.VaultErdlBlue_MP7_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh_MAT.mp7.VaultErdlBlue_MP7_3P_Pickup_MIC"))
	Skins.Add((Id=5549, Weapondef=class'KFWeapDef_MP7', MIC_1P=("WEP_SkinSet_VaultVosh_MAT.mp7.VaultErdlBlue_MP7_1P_BattleScarred_MIC", "WEP_SkinSet_VaultVosh_MAT.mp7.VaultErdlBlue_MP7_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh_MAT.mp7.VaultErdlBlue_MP7_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh_MAT.mp7.VaultErdlBlue_MP7_3P_Pickup_MIC"))

//Vault Vosh Crovel
	Skins.Add((Id=5652, Weapondef=class'KFWeapDef_Crovel', MIC_1P=("WEP_SkinSet_VaultVosh02_MAT.vosh_crovel.Vault_Vosh_Crovel_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh02_MAT.vosh_crovel.Vault_Vosh_Crovel_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh02_MAT.vosh_crovel.Vault_Vosh_Crovel_3P_Pickup_MIC"))

//Vault Vosh AR15
	Skins.Add((Id=5657, Weapondef=class'KFWeapDef_AR15', MIC_1P=("WEP_SkinSet_VaultVosh02_MAT.vosh_ar15.Vault_Vosh_AR15_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh02_MAT.vosh_ar15.Vault_Vosh_AR15_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh02_MAT.vosh_ar15.Vault_Vosh_AR15_3P_Pickup_MIC"))

//Vault Vosh MB500
	Skins.Add((Id=5656, Weapondef=class'KFWeapDef_MB500', MIC_1P=("WEP_SkinSet_VaultVosh02_MAT.vosh_mb500.Vault_Vosh_MB500_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh02_MAT.vosh_mb500.Vault_Vosh_MB500_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh02_MAT.vosh_mb500.Vault_Vosh_MB500_3P_Pickup_MIC"))

//Vault Vosh Medic Pistol
	Skins.Add((Id=5658, Weapondef=class'KFWeapDef_MedicPistol', MIC_1P=("WEP_SkinSet_VaultVosh02_MAT.vosh_medic_pistol.Vault_Vosh_Medic_Pistol_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh02_MAT.vosh_medic_pistol.Vault_Vosh_Medic_Pistol_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh02_MAT.vosh_medic_pistol.Vault_Vosh_Medic_Pistol_3P_Pickup_MIC"))

//Vault Vosh HX25
	Skins.Add((Id=5659, Weapondef=class'KFWeapDef_HX25', MIC_1P=("WEP_SkinSet_VaultVosh02_MAT.vosh_hx25_pistol.Vault_Vosh_HX25_Pistol_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh02_MAT.vosh_hx25_pistol.Vault_Vosh_HX25_Pistol_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh02_MAT.vosh_hx25_pistol.Vault_Vosh_HX25_Pistol_3P_Pickup_MIC"))

//Vault Vosh Caulk Burn
	Skins.Add((Id=5660, Weapondef=class'KFWeapDef_CaulkBurn', MIC_1P=("WEP_SkinSet_VaultVosh02_MAT.vosh_caulkburn.Vault_Vosh_CaulkBurn_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh02_MAT.vosh_caulkburn.Vault_Vosh_CaulkBurn_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh02_MAT.vosh_caulkburn.Vault_Vosh_CaulkBurn_3P_Pickup_MIC"))

//Vault Vosh Remington 1858
	Skins.Add((Id=5661, Weapondef=class'KFWeapDef_Remington1858', MIC_1P=("WEP_SkinSet_VaultVosh02_MAT.vosh_remington1858.Vault_Vosh_Remington_1858_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh02_MAT.vosh_remington1858.Vault_Vosh_Remington_1858_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh02_MAT.vosh_remington1858.Vault_Vosh_Remington_1858_3P_Pickup_MIC"))

//Vault Vosh Winchester 1894
	Skins.Add((Id=5662, Weapondef=class'KFWeapDef_Winchester1894', MIC_1P=("WEP_SkinSet_VaultVosh02_MAT.vosh_winchester1894.Vault_Vosh_Winchester_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh02_MAT.vosh_winchester1894.Vault_Vosh_Winchester_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh02_MAT.vosh_winchester1894.Vault_Vosh_Winchester_3P_Pickup_MIC"))

//Vault Vosh MP7
	Skins.Add((Id=5663, Weapondef=class'KFWeapDef_MP7', MIC_1P=("WEP_SkinSet_VaultVosh02_MAT.vosh_mp7.Vault_Vosh_MP7_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh02_MAT.vosh_mp7.Vault_Vosh_MP7_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh02_MAT.vosh_mp7.Vault_Vosh_MP7_3P_Pickup_MIC"))

//Black Golden Healer
	Skins.Add((Id=5905, Weapondef=class'KFWeapDef_Healer', MIC_1P=("WEP_SkinSet18_MAT.blackgolden_healer.BlackGolden_Healer_1P_Mint_MIC"), MIC_3P="WEP_SkinSet18_MAT.blackgolden_healer.BlackGolden_Healer_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet18_MAT.blackgolden_healer.BlackGolden_Healer_3P_Pickup_MIC"))
	Skins.Add((Id=5904, Weapondef=class'KFWeapDef_Healer', MIC_1P=("WEP_SkinSet18_MAT.blackgolden_healer.BlackGolden_Healer_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet18_MAT.blackgolden_healer.BlackGolden_Healer_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet18_MAT.blackgolden_healer.BlackGolden_Healer_3P_Pickup_MIC"))
	Skins.Add((Id=5903, Weapondef=class'KFWeapDef_Healer', MIC_1P=("WEP_SkinSet18_MAT.blackgolden_healer.BlackGolden_Healer_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet18_MAT.blackgolden_healer.BlackGolden_Healer_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet18_MAT.blackgolden_healer.BlackGolden_Healer_3P_Pickup_MIC"))

//Black Golden Welder
	Skins.Add((Id=5908, Weapondef=class'KFWeapDef_Welder', MIC_1P=("WEP_SkinSet18_MAT.blackgolden_welder.BlackGolden_Welder_1P_Mint_MIC"), MIC_3P="WEP_SkinSet18_MAT.blackgolden_welder.BlackGolden_Welder_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet18_MAT.blackgolden_welder.BlackGolden_Welder_3P_Pickup_MIC"))
	Skins.Add((Id=5907, Weapondef=class'KFWeapDef_Welder', MIC_1P=("WEP_SkinSet18_MAT.blackgolden_welder.BlackGolden_Welder_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet18_MAT.blackgolden_welder.BlackGolden_Welder_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet18_MAT.blackgolden_welder.BlackGolden_Welder_3P_Pickup_MIC"))
	Skins.Add((Id=5906, Weapondef=class'KFWeapDef_Welder', MIC_1P=("WEP_SkinSet18_MAT.blackgolden_welder.BlackGolden_Welder_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet18_MAT.blackgolden_welder.BlackGolden_Welder_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet18_MAT.blackgolden_welder.BlackGolden_Welder_3P_Pickup_MIC"))

//Black Golden Berserker Knife
	Skins.Add((Id=5911, Weapondef=class'KFWeapDef_Knife_Berserker', MIC_1P=("WEP_SkinSet18_MAT.blackgolden_berserkerknife.BlackGolden_BerserkerKnife_1P_Mint_MIC"), MIC_3P="WEP_SkinSet18_MAT.blackgolden_berserkerknife.BlackGolden_BerserkerKnife_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet18_MAT.blackgolden_berserkerknife.BlackGolden_BerserkerKnife_3P_Pickup_MIC"))
	Skins.Add((Id=5910, Weapondef=class'KFWeapDef_Knife_Berserker', MIC_1P=("WEP_SkinSet18_MAT.blackgolden_berserkerknife.BlackGolden_BerserkerKnife_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet18_MAT.blackgolden_berserkerknife.BlackGolden_BerserkerKnife_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet18_MAT.blackgolden_berserkerknife.BlackGolden_BerserkerKnife_3P_Pickup_MIC"))
	Skins.Add((Id=5909, Weapondef=class'KFWeapDef_Knife_Berserker', MIC_1P=("WEP_SkinSet18_MAT.blackgolden_berserkerknife.BlackGolden_BerserkerKnife_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet18_MAT.blackgolden_berserkerknife.BlackGolden_BerserkerKnife_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet18_MAT.blackgolden_berserkerknife.BlackGolden_BerserkerKnife_3P_Pickup_MIC"))

//Black Golden Katana
	Skins.Add((Id=5914, Weapondef=class'KFWeapDef_Katana', MIC_1P=("WEP_SkinSet18_MAT.blackgolden_katana.BlackGolden_Katana_1P_Mint_MIC"), MIC_3P="WEP_SkinSet18_MAT.blackgolden_katana.BlackGolden_Katana_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet18_MAT.blackgolden_katana.BlackGolden_Katana_3P_Pickup_MIC"))
	Skins.Add((Id=5913, Weapondef=class'KFWeapDef_Katana', MIC_1P=("WEP_SkinSet18_MAT.blackgolden_katana.BlackGolden_Katana_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet18_MAT.blackgolden_katana.BlackGolden_Katana_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet18_MAT.blackgolden_katana.BlackGolden_Katana_3P_Pickup_MIC"))
	Skins.Add((Id=5912, Weapondef=class'KFWeapDef_Katana', MIC_1P=("WEP_SkinSet18_MAT.blackgolden_katana.BlackGolden_Katana_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet18_MAT.blackgolden_katana.BlackGolden_Katana_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet18_MAT.blackgolden_katana.BlackGolden_Katana_3P_Pickup_MIC"))

//Black Golden Sawblade
	Skins.Add((Id=5917, Weapondef=class'KFWeapDef_Eviscerator', MIC_1P=("WEP_SkinSet18_MAT.blackgolden_sawblade.BlackGolden_Sawblade_1P_Mint_MIC"), MIC_3P="WEP_SkinSet18_MAT.blackgolden_sawblade.BlackGolden_Sawblade_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet18_MAT.blackgolden_sawblade.BlackGolden_Sawblade_3P_Pickup_MIC"))
	Skins.Add((Id=5916, Weapondef=class'KFWeapDef_Eviscerator', MIC_1P=("WEP_SkinSet18_MAT.blackgolden_sawblade.BlackGolden_Sawblade_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet18_MAT.blackgolden_sawblade.BlackGolden_Sawblade_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet18_MAT.blackgolden_sawblade.BlackGolden_Sawblade_3P_Pickup_MIC"))
	Skins.Add((Id=5915, Weapondef=class'KFWeapDef_Eviscerator', MIC_1P=("WEP_SkinSet18_MAT.blackgolden_sawblade.BlackGolden_Sawblade_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet18_MAT.blackgolden_sawblade.BlackGolden_Sawblade_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet18_MAT.blackgolden_sawblade.BlackGolden_Sawblade_3P_Pickup_MIC"))

//Black Golden Zweihander
	Skins.Add((Id=5920, Weapondef=class'KFWeapDef_Zweihander', MIC_1P=("WEP_SkinSet18_MAT.blackgolden_zweihander.BlackGolden_Zweihander_1P_Mint_MIC"), MIC_3P="WEP_SkinSet18_MAT.blackgolden_zweihander.BlackGolden_Zweihander_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet18_MAT.blackgolden_zweihander.BlackGolden_Zweihander_3P_Pickup_MIC"))
	Skins.Add((Id=5919, Weapondef=class'KFWeapDef_Zweihander', MIC_1P=("WEP_SkinSet18_MAT.blackgolden_zweihander.BlackGolden_Zweihander_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet18_MAT.blackgolden_zweihander.BlackGolden_Zweihander_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet18_MAT.blackgolden_zweihander.BlackGolden_Zweihander_3P_Pickup_MIC"))
	Skins.Add((Id=5918, Weapondef=class'KFWeapDef_Zweihander', MIC_1P=("WEP_SkinSet18_MAT.blackgolden_zweihander.BlackGolden_Zweihander_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet18_MAT.blackgolden_zweihander.BlackGolden_Zweihander_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet18_MAT.blackgolden_zweihander.BlackGolden_Zweihander_3P_Pickup_MIC"))

//Black Golden Pulverizer
	Skins.Add((Id=5923, Weapondef=class'KFWeapDef_Pulverizer', MIC_1P=("WEP_SkinSet18_MAT.blackgolden_pulverizer.BlackGolden_Pulverizer_1P_Mint_MIC"), MIC_3P="WEP_SkinSet18_MAT.blackgolden_pulverizer.BlackGolden_Pulverizer_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet18_MAT.blackgolden_pulverizer.BlackGolden_Pulverizer_3P_Pickup_MIC"))
	Skins.Add((Id=5922, Weapondef=class'KFWeapDef_Pulverizer', MIC_1P=("WEP_SkinSet18_MAT.blackgolden_pulverizer.BlackGolden_Pulverizer_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet18_MAT.blackgolden_pulverizer.BlackGolden_Pulverizer_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet18_MAT.blackgolden_pulverizer.BlackGolden_Pulverizer_3P_Pickup_MIC"))
	Skins.Add((Id=5921, Weapondef=class'KFWeapDef_Pulverizer', MIC_1P=("WEP_SkinSet18_MAT.blackgolden_pulverizer.BlackGolden_Pulverizer_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet18_MAT.blackgolden_pulverizer.BlackGolden_Pulverizer_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet18_MAT.blackgolden_pulverizer.BlackGolden_Pulverizer_3P_Pickup_MIC"))

//Black Golden Crovel
	Skins.Add((Id=5926, Weapondef=class'KFWeapDef_Crovel', MIC_1P=("WEP_SkinSet18_MAT.blackgolden_crovel.BlackGolden_Crovel_1P_Mint_MIC"), MIC_3P="WEP_SkinSet18_MAT.blackgolden_crovel.BlackGolden_Crovel_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet18_MAT.blackgolden_crovel.BlackGolden_Crovel_3P_Pickup_MIC"))
	Skins.Add((Id=5925, Weapondef=class'KFWeapDef_Crovel', MIC_1P=("WEP_SkinSet18_MAT.blackgolden_crovel.BlackGolden_Crovel_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet18_MAT.blackgolden_crovel.BlackGolden_Crovel_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet18_MAT.blackgolden_crovel.BlackGolden_Crovel_3P_Pickup_MIC"))
	Skins.Add((Id=5924, Weapondef=class'KFWeapDef_Crovel', MIC_1P=("WEP_SkinSet18_MAT.blackgolden_crovel.BlackGolden_Crovel_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet18_MAT.blackgolden_crovel.BlackGolden_Crovel_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet18_MAT.blackgolden_crovel.BlackGolden_Crovel_3P_Pickup_MIC"))

//Black Golden 9MM
	Skins.Add((Id=5929, Weapondef=class'KFWeapDef_9mm', MIC_1P=("WEP_SkinSet18_MAT.blackgolden_9mm.BlackGolden_9MM_1P_Mint_MIC"), MIC_3P="WEP_SkinSet18_MAT.blackgolden_9mm.BlackGolden_9MM_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet18_MAT.blackgolden_9mm.BlackGolden_9MM_3P_Pickup_MIC"))
	Skins.Add((Id=5928, Weapondef=class'KFWeapDef_9mm', MIC_1P=("WEP_SkinSet18_MAT.blackgolden_9mm.BlackGolden_9MM_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet18_MAT.blackgolden_9mm.BlackGolden_9MM_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet18_MAT.blackgolden_9mm.BlackGolden_9MM_3P_Pickup_MIC"))
	Skins.Add((Id=5927, Weapondef=class'KFWeapDef_9mm', MIC_1P=("WEP_SkinSet18_MAT.blackgolden_9mm.BlackGolden_9MM_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet18_MAT.blackgolden_9mm.BlackGolden_9MM_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet18_MAT.blackgolden_9mm.BlackGolden_9MM_3P_Pickup_MIC"))

//Black Golden Nailgun
	Skins.Add((Id=5932, Weapondef=class'KFWeapDef_NailGun', MIC_1P=("WEP_SkinSet18_MAT.blackgolden_nailshotgun.BlackGolden_NailShotgun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet18_MAT.blackgolden_nailshotgun.BlackGolden_NailShotgun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet18_MAT.blackgolden_nailshotgun.BlackGolden_NailShotgun_3P_Pickup_MIC"))
	Skins.Add((Id=5931, Weapondef=class'KFWeapDef_NailGun', MIC_1P=("WEP_SkinSet18_MAT.blackgolden_nailshotgun.BlackGolden_NailShotgun_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet18_MAT.blackgolden_nailshotgun.BlackGolden_NailShotgun_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet18_MAT.blackgolden_nailshotgun.BlackGolden_NailShotgun_3P_Pickup_MIC"))
	Skins.Add((Id=5930, Weapondef=class'KFWeapDef_NailGun', MIC_1P=("WEP_SkinSet18_MAT.blackgolden_nailshotgun.BlackGolden_NailShotgun_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet18_MAT.blackgolden_nailshotgun.BlackGolden_NailShotgun_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet18_MAT.blackgolden_nailshotgun.BlackGolden_NailShotgun_3P_Pickup_MIC"))

//Heirloom Dragonsbreath
	Skins.Add((Id=5935, Weapondef=class'KFWeapDef_DragonsBreath', MIC_1P=("WEP_SkinSet18_MAT.heirloom_dragonsbreath.Heirloom_Dragonsbreath_1P_Mint_MIC"), MIC_3P="WEP_SkinSet18_MAT.heirloom_dragonsbreath.Heirloom_Dragonsbreath_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet18_MAT.heirloom_dragonsbreath.Heirloom_Dragonsbreath_3P_Pickup_MIC"))
	Skins.Add((Id=5934, Weapondef=class'KFWeapDef_DragonsBreath', MIC_1P=("WEP_SkinSet18_MAT.heirloom_dragonsbreath.Heirloom_Dragonsbreath_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet18_MAT.heirloom_dragonsbreath.Heirloom_Dragonsbreath_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet18_MAT.heirloom_dragonsbreath.Heirloom_Dragonsbreath_3P_Pickup_MIC"))
	Skins.Add((Id=5933, Weapondef=class'KFWeapDef_DragonsBreath', MIC_1P=("WEP_SkinSet18_MAT.heirloom_dragonsbreath.Heirloom_Dragonsbreath_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet18_MAT.heirloom_dragonsbreath.Heirloom_Dragonsbreath_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet18_MAT.heirloom_dragonsbreath.Heirloom_Dragonsbreath_3P_Pickup_MIC"))

//Heirloom Flaregun
	Skins.Add((Id=5938, Weapondef=class'KFWeapDef_FlareGun', MIC_1P=("WEP_SkinSet18_MAT.heirloom_spitfire.Heirloom_Spitfire_1P_Mint_MIC"), MIC_3P="WEP_SkinSet18_MAT.heirloom_spitfire.Heirloom_Spitfire_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet18_MAT.heirloom_spitfire.Heirloom_Spitfire_3P_Pickup_MIC"))
	Skins.Add((Id=5937, Weapondef=class'KFWeapDef_FlareGun', MIC_1P=("WEP_SkinSet18_MAT.heirloom_spitfire.Heirloom_Spitfire_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet18_MAT.heirloom_spitfire.Heirloom_Spitfire_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet18_MAT.heirloom_spitfire.Heirloom_Spitfire_3P_Pickup_MIC"))
	Skins.Add((Id=5936, Weapondef=class'KFWeapDef_FlareGun', MIC_1P=("WEP_SkinSet18_MAT.heirloom_spitfire.Heirloom_Spitfire_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet18_MAT.heirloom_spitfire.Heirloom_Spitfire_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet18_MAT.heirloom_spitfire.Heirloom_Spitfire_3P_Pickup_MIC"))

//Heirloom M1911
	Skins.Add((Id=5941, Weapondef=class'KFWeapDef_Colt1911', MIC_1P=("WEP_SkinSet18_MAT.heirloom_m1911.Heirloom_M1911_1P_Mint_MIC"), MIC_3P="WEP_SkinSet18_MAT.heirloom_m1911.Heirloom_M1911_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet18_MAT.heirloom_m1911.Heirloom_M1911_3P_Pickup_MIC"))
	Skins.Add((Id=5940, Weapondef=class'KFWeapDef_Colt1911', MIC_1P=("WEP_SkinSet18_MAT.heirloom_m1911.Heirloom_M1911_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet18_MAT.heirloom_m1911.Heirloom_M1911_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet18_MAT.heirloom_m1911.Heirloom_M1911_3P_Pickup_MIC"))
	Skins.Add((Id=5939, Weapondef=class'KFWeapDef_Colt1911', MIC_1P=("WEP_SkinSet18_MAT.heirloom_m1911.Heirloom_M1911_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet18_MAT.heirloom_m1911.Heirloom_M1911_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet18_MAT.heirloom_m1911.Heirloom_M1911_3P_Pickup_MIC"))

//Heirloom Remington 1858
	Skins.Add((Id=5944, Weapondef=class'KFWeapDef_Remington1858', MIC_1P=("WEP_SkinSet18_MAT.heirloom_remington1858.Heirloom_Remington1858_1P_Mint_MIC"), MIC_3P="WEP_SkinSet18_MAT.heirloom_remington1858.Heirloom_Remington1858_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet18_MAT.heirloom_remington1858.Heirloom_Remington1858_3P_Pickup_MIC"))
	Skins.Add((Id=5943, Weapondef=class'KFWeapDef_Remington1858', MIC_1P=("WEP_SkinSet18_MAT.heirloom_remington1858.Heirloom_Remington1858_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet18_MAT.heirloom_remington1858.Heirloom_Remington1858_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet18_MAT.heirloom_remington1858.Heirloom_Remington1858_3P_Pickup_MIC"))
	Skins.Add((Id=5942, Weapondef=class'KFWeapDef_Remington1858', MIC_1P=("WEP_SkinSet18_MAT.heirloom_remington1858.Heirloom_Remington1858_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet18_MAT.heirloom_remington1858.Heirloom_Remington1858_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet18_MAT.heirloom_remington1858.Heirloom_Remington1858_3P_Pickup_MIC"))

//Heirloom RPG
	Skins.Add((Id=5947, Weapondef=class'KFWeapDef_RPG7', MIC_1P=("WEP_SkinSet18_MAT.heirloom_rpg7.Heirloom_RPG7_1P_Mint_MIC"), MIC_3P="WEP_SkinSet18_MAT.heirloom_rpg7.Heirloom_RPG7_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet18_MAT.heirloom_rpg7.Heirloom_RPG7_3P_Pickup_MIC"))
	Skins.Add((Id=5946, Weapondef=class'KFWeapDef_RPG7', MIC_1P=("WEP_SkinSet18_MAT.heirloom_rpg7.Heirloom_RPG7_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet18_MAT.heirloom_rpg7.Heirloom_RPG7_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet18_MAT.heirloom_rpg7.Heirloom_RPG7_3P_Pickup_MIC"))
	Skins.Add((Id=5945, Weapondef=class'KFWeapDef_RPG7', MIC_1P=("WEP_SkinSet18_MAT.heirloom_rpg7.Heirloom_RPG7_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet18_MAT.heirloom_rpg7.Heirloom_RPG7_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet18_MAT.heirloom_rpg7.Heirloom_RPG7_3P_Pickup_MIC"))

//Heirloom Winchester 1894
	Skins.Add((Id=5950, Weapondef=class'KFWeapDef_Winchester1894', MIC_1P=("WEP_SkinSet18_MAT.heirloom_winchester1894.Heirloom_Winchester1894_1P_Mint_MIC"), MIC_3P="WEP_SkinSet18_MAT.heirloom_winchester1894.Heirloom_Winchester1894_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet18_MAT.heirloom_winchester1894.Heirloom_Winchester1894_3P_Pickup_MIC"))
	Skins.Add((Id=5949, Weapondef=class'KFWeapDef_Winchester1894', MIC_1P=("WEP_SkinSet18_MAT.heirloom_winchester1894.Heirloom_Winchester1894_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet18_MAT.heirloom_winchester1894.Heirloom_Winchester1894_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet18_MAT.heirloom_winchester1894.Heirloom_Winchester1894_3P_Pickup_MIC"))
	Skins.Add((Id=5948, Weapondef=class'KFWeapDef_Winchester1894', MIC_1P=("WEP_SkinSet18_MAT.heirloom_winchester1894.Heirloom_Winchester1894_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet18_MAT.heirloom_winchester1894.Heirloom_Winchester1894_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet18_MAT.heirloom_winchester1894.Heirloom_Winchester1894_3P_Pickup_MIC"))

//Precious HK UMP
	Skins.Add((Id=5951, Weapondef=class'KFWeapDef_HK_UMP', MIC_1P=("WEP_SkinSet18_MAT.precious_hk_ump.Precious_HK_UMP_1P_Mint_MIC"), MIC_3P="WEP_SkinSet18_MAT.precious_hk_ump.Precious_HK_UMP_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet18_MAT.precious_hk_ump.Precious_HK_UMP_3P_Pickup_MIC"))

//Precious Husk Cannon
	Skins.Add((Id=5952, Weapondef=class'KFWeapDef_HuskCannon', MIC_1P=("WEP_SkinSet18_MAT.precious_huskcannon.Precious_HuskCannon_1P_Mint_MIC"), MIC_3P="WEP_SkinSet18_MAT.precious_huskcannon.Precious_HuskCannon_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet18_MAT.precious_huskcannon.Precious_HuskCannon_3P_Pickup_MIC"))

//Precious Hemogoblin
	Skins.Add((Id=5953, Weapondef=class'KFWeapDef_Hemogoblin', MIC_1P=("WEP_SkinSet18_MAT.precious_bleeder.Precious_Bleeder_1P_Mint_MIC"), MIC_3P="WEP_SkinSet18_MAT.precious_bleeder.Precious_Bleeder_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet18_MAT.precious_bleeder.Precious_Bleeder_3P_Pickup_MIC"))

//Precious Seeker Six
	Skins.Add((Id=5954, Weapondef=class'KFWeapDef_Seeker6', MIC_1P=("WEP_SkinSet18_MAT.precious_seekersix.Precious_SeekerSix_1P_Mint_MIC"), MIC_3P="WEP_SkinSet18_MAT.precious_seekersix.Precious_SeekerSix_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet18_MAT.precious_seekersix.Precious_SeekerSix_3P_Pickup_MIC"))

//Precious AF2011
	Skins.Add((Id=5955, Weapondef=class'KFWeapDef_AF2011', MIC_1P=("WEP_SkinSet18_MAT.precious_af2001.Precious_AF2001_1P_Mint_MIC"), MIC_3P="WEP_SkinSet18_MAT.precious_af2001.Precious_AF2001_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet18_MAT.precious_af2001.Precious_AF2001_3P_Pickup_MIC"))

//Precious Mac 10
	Skins.Add((Id=5956, Weapondef=class'KFWeapDef_Mac10', MIC_1P=("WEP_SkinSet18_MAT.precious_mac10.Precious_MAC10_1P_Mint_MIC"), MIC_3P="WEP_SkinSet18_MAT.precious_mac10.Precious_MAC10_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet18_MAT.precious_mac10.Precious_MAC10_3P_Pickup_MIC"))

//Vietnam Stoner 63A
	Skins.Add((Id=5959, Weapondef=class'KFWeapDef_Stoner63A', MIC_1P=("WEP_SkinSet18_MAT.vietnam_stoner.Vietnam_Stoner_Lower_1P_Mint_MIC", "WEP_SkinSet18_MAT.vietnam_stoner.Vietnam_Stoner_Upper_1P_Mint_MIC"), MIC_3P="WEP_SkinSet18_MAT.vietnam_stoner.Vietnam_Stoner_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet18_MAT.vietnam_stoner.Vietnam_Stoner_3P_Pickup_MIC"))
	Skins.Add((Id=5958, Weapondef=class'KFWeapDef_Stoner63A', MIC_1P=("WEP_SkinSet18_MAT.vietnam_stoner.Vietnam_Stoner_Lower_1P_FieldTested_MIC", "WEP_SkinSet18_MAT.vietnam_stoner.Vietnam_Stoner_Upper_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet18_MAT.vietnam_stoner.Vietnam_Stoner_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet18_MAT.vietnam_stoner.Vietnam_Stoner_3P_Pickup_MIC"))
	Skins.Add((Id=5957, Weapondef=class'KFWeapDef_Stoner63A', MIC_1P=("WEP_SkinSet18_MAT.vietnam_stoner.Vietnam_Stoner_Lower_1P_BattleScarred_MIC", "WEP_SkinSet18_MAT.vietnam_stoner.Vietnam_Stoner_Upper_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet18_MAT.vietnam_stoner.Vietnam_Stoner_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet18_MAT.vietnam_stoner.Vietnam_Stoner_3P_Pickup_MIC"))

//Junkyard Boomstick
	Skins.Add((Id=5962, Weapondef=class'KFWeapDef_DoubleBarrel', MIC_1P=("WEP_SkinSet18_MAT.junkyard_boomstick.Junkyard_Boomstick_1P_Mint_MIC"), MIC_3P="WEP_SkinSet18_MAT.junkyard_boomstick.Junkyard_Boomstick_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet18_MAT.junkyard_boomstick.Junkyard_Boomstick_3P_Pickup_MIC"))
	Skins.Add((Id=5961, Weapondef=class'KFWeapDef_DoubleBarrel', MIC_1P=("WEP_SkinSet18_MAT.junkyard_boomstick.Junkyard_Boomstick_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet18_MAT.junkyard_boomstick.Junkyard_Boomstick_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet18_MAT.junkyard_boomstick.Junkyard_Boomstick_3P_Pickup_MIC"))
	Skins.Add((Id=5960, Weapondef=class'KFWeapDef_DoubleBarrel', MIC_1P=("WEP_SkinSet18_MAT.junkyard_boomstick.Junkyard_Boomstick_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet18_MAT.junkyard_boomstick.Junkyard_Boomstick_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet18_MAT.junkyard_boomstick.Junkyard_Boomstick_3P_Pickup_MIC"))

//Horzine Elite White Medic Assault
	Skins.Add((Id=5965, Weapondef=class'KFWeapDef_MedicRifle', MIC_1P=("WEP_SkinSet18_MAT.horzineelitewhite_medicassault.HorzineEliteWhite_MedicAssault_1P_Mint_MIC", "WEP_SkinSet18_MAT.horzineelitewhite_medicassault.HorzineEliteWhite_MedicPistol_1P_Mint_MIC"), MIC_3P="WEP_SkinSet18_MAT.horzineelitewhite_medicassault.HorzineEliteWhite_MedicAssault_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet18_MAT.horzineelitewhite_medicassault.HorzineEliteWhite_MedicAssault_3P_Pickup_MIC"))
	Skins.Add((Id=5964, Weapondef=class'KFWeapDef_MedicRifle', MIC_1P=("WEP_SkinSet18_MAT.horzineelitewhite_medicassault.HorzineEliteWhite_MedicAssault_1P_FieldTested_MIC", "WEP_SkinSet18_MAT.horzineelitewhite_medicassault.HorzineEliteWhite_MedicPistol_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet18_MAT.horzineelitewhite_medicassault.HorzineEliteWhite_MedicAssault_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet18_MAT.horzineelitewhite_medicassault.HorzineEliteWhite_MedicAssault_3P_Pickup_MIC"))
	Skins.Add((Id=5963, Weapondef=class'KFWeapDef_MedicRifle', MIC_1P=("WEP_SkinSet18_MAT.horzineelitewhite_medicassault.HorzineEliteWhite_MedicAssault_1P_BattleScarred_MIC", "WEP_SkinSet18_MAT.horzineelitewhite_medicassault.HorzineEliteWhite_MedicPistol_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet18_MAT.horzineelitewhite_medicassault.HorzineEliteWhite_MedicAssault_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet18_MAT.horzineelitewhite_medicassault.HorzineEliteWhite_MedicAssault_3P_Pickup_MIC"))

//Horzine Elite Black Medic Assault
	Skins.Add((Id=5968, Weapondef=class'KFWeapDef_MedicRifle', MIC_1P=("WEP_SkinSet18_MAT.horzineeliteblack_medicassault.HorzineEliteBlack_MedicAssault_1P_Mint_MIC", "WEP_SkinSet18_MAT.horzineeliteblack_medicassault.HorzineEliteBlack_MedicPistol_1P_Mint_MIC"), MIC_3P="WEP_SkinSet18_MAT.horzineeliteblack_medicassault.HorzineEliteBlack_MedicAssault_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet18_MAT.horzineeliteblack_medicassault.HorzineEliteBlack_MedicAssault_3P_Pickup_MIC"))
	Skins.Add((Id=5967, Weapondef=class'KFWeapDef_MedicRifle', MIC_1P=("WEP_SkinSet18_MAT.horzineeliteblack_medicassault.HorzineEliteBlack_MedicAssault_1P_FieldTested_MIC", "WEP_SkinSet18_MAT.horzineeliteblack_medicassault.HorzineEliteBlack_MedicPistol_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet18_MAT.horzineeliteblack_medicassault.HorzineEliteBlack_MedicAssault_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet18_MAT.horzineeliteblack_medicassault.HorzineEliteBlack_MedicAssault_3P_Pickup_MIC"))
	Skins.Add((Id=5966, Weapondef=class'KFWeapDef_MedicRifle', MIC_1P=("WEP_SkinSet18_MAT.horzineeliteblack_medicassault.HorzineEliteBlack_MedicAssault_1P_BattleScarred_MIC", "WEP_SkinSet18_MAT.horzineeliteblack_medicassault.HorzineEliteBlack_MedicPistol_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet18_MAT.horzineeliteblack_medicassault.HorzineEliteBlack_MedicAssault_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet18_MAT.horzineeliteblack_medicassault.HorzineEliteBlack_MedicAssault_3P_Pickup_MIC"))

//Horzine Elite Blue Medic Assault
	Skins.Add((Id=5971, Weapondef=class'KFWeapDef_MedicRifle', MIC_1P=("WEP_SkinSet18_MAT.horzineeliteblue_medicassault.HorzineEliteBlue_MedicAssault_1P_Mint_MIC", "WEP_SkinSet18_MAT.horzineeliteblue_medicassault.HorzineEliteBlue_MedicPistol_1P_Mint_MIC"), MIC_3P="WEP_SkinSet18_MAT.horzineeliteblue_medicassault.HorzineEliteBlue_MedicAssault_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet18_MAT.horzineeliteblue_medicassault.HorzineEliteBlue_MedicAssault_3P_Pickup_MIC"))
	Skins.Add((Id=5970, Weapondef=class'KFWeapDef_MedicRifle', MIC_1P=("WEP_SkinSet18_MAT.horzineeliteblue_medicassault.HorzineEliteBlue_MedicAssault_1P_FieldTested_MIC", "WEP_SkinSet18_MAT.horzineeliteblue_medicassault.HorzineEliteBlue_MedicPistol_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet18_MAT.horzineeliteblue_medicassault.HorzineEliteBlue_MedicAssault_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet18_MAT.horzineeliteblue_medicassault.HorzineEliteBlue_MedicAssault_3P_Pickup_MIC"))
	Skins.Add((Id=5969, Weapondef=class'KFWeapDef_MedicRifle', MIC_1P=("WEP_SkinSet18_MAT.horzineeliteblue_medicassault.HorzineEliteBlue_MedicAssault_1P_BattleScarred_MIC", "WEP_SkinSet18_MAT.horzineeliteblue_medicassault.HorzineEliteBlue_MedicPistol_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet18_MAT.horzineeliteblue_medicassault.HorzineEliteBlue_MedicAssault_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet18_MAT.horzineeliteblue_medicassault.HorzineEliteBlue_MedicAssault_3P_Pickup_MIC"))

//Horzine Elite Green Medic Assault
	Skins.Add((Id=5974, Weapondef=class'KFWeapDef_MedicRifle', MIC_1P=("WEP_SkinSet18_MAT.horzineelitegreen_medicassault.HorzineEliteGreen_MedicAssault_1P_Mint_MIC", "WEP_SkinSet18_MAT.horzineelitegreen_medicassault.HorzineEliteGreen_MedicPistol_1P_Mint_MIC"), MIC_3P="WEP_SkinSet18_MAT.horzineelitegreen_medicassault.HorzineEliteGreen_MedicAssault_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet18_MAT.horzineelitegreen_medicassault.HorzineEliteGreen_MedicAssault_3P_Pickup_MIC"))
	Skins.Add((Id=5973, Weapondef=class'KFWeapDef_MedicRifle', MIC_1P=("WEP_SkinSet18_MAT.horzineelitegreen_medicassault.HorzineEliteGreen_MedicAssault_1P_FieldTested_MIC", "WEP_SkinSet18_MAT.horzineelitegreen_medicassault.HorzineEliteGreen_MedicPistol_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet18_MAT.horzineelitegreen_medicassault.HorzineEliteGreen_MedicAssault_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet18_MAT.horzineelitegreen_medicassault.HorzineEliteGreen_MedicAssault_3P_Pickup_MIC"))
	Skins.Add((Id=5972, Weapondef=class'KFWeapDef_MedicRifle', MIC_1P=("WEP_SkinSet18_MAT.horzineelitegreen_medicassault.HorzineEliteGreen_MedicAssault_1P_BattleScarred_MIC", "WEP_SkinSet18_MAT.horzineelitegreen_medicassault.HorzineEliteGreen_MedicPistol_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet18_MAT.horzineelitegreen_medicassault.HorzineEliteGreen_MedicAssault_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet18_MAT.horzineelitegreen_medicassault.HorzineEliteGreen_MedicAssault_3P_Pickup_MIC"))

//Horzine Elite Red Medic Assault
	Skins.Add((Id=5977, Weapondef=class'KFWeapDef_MedicRifle', MIC_1P=("WEP_SkinSet18_MAT.horzineelitered_medicassault.HorzineEliteRed_MedicAssault_1P_Mint_MIC", "WEP_SkinSet18_MAT.horzineelitered_medicassault.HorzineEliteRed_MedicPistol_1P_Mint_MIC"), MIC_3P="WEP_SkinSet18_MAT.horzineelitered_medicassault.HorzineEliteRed_MedicAssault_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet18_MAT.horzineelitered_medicassault.HorzineEliteRed_MedicAssault_3P_Pickup_MIC"))
	Skins.Add((Id=5976, Weapondef=class'KFWeapDef_MedicRifle', MIC_1P=("WEP_SkinSet18_MAT.horzineelitered_medicassault.HorzineEliteRed_MedicAssault_1P_FieldTested_MIC", "WEP_SkinSet18_MAT.horzineelitered_medicassault.HorzineEliteRed_MedicPistol_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet18_MAT.horzineelitered_medicassault.HorzineEliteRed_MedicAssault_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet18_MAT.horzineelitered_medicassault.HorzineEliteRed_MedicAssault_3P_Pickup_MIC"))
	Skins.Add((Id=5975, Weapondef=class'KFWeapDef_MedicRifle', MIC_1P=("WEP_SkinSet18_MAT.horzineelitered_medicassault.HorzineEliteRed_MedicAssault_1P_BattleScarred_MIC", "WEP_SkinSet18_MAT.horzineelitered_medicassault.HorzineEliteRed_MedicPistol_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet18_MAT.horzineelitered_medicassault.HorzineEliteRed_MedicAssault_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet18_MAT.horzineelitered_medicassault.HorzineEliteRed_MedicAssault_3P_Pickup_MIC"))

//Vault Vosh C4
	Skins.Add((Id=6002, Weapondef=class'KFWeapDef_C4', MIC_1P=("WEP_SkinSet_VaultVosh03_MAT.vosh_c4.Vault_Vosh_C4_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh03_MAT.vosh_c4.Vault_Vosh_C4_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh03_MAT.vosh_c4.Vault_Vosh_C4_3P_Pickup_MIC"))

//Vault Vosh Crossbow
	Skins.Add((Id=6003, Weapondef=class'KFWeapDef_Crossbow', MIC_1P=("WEP_SkinSet_VaultVosh03_MAT.vosh_crossbow.Vault_Vosh_Crossbow_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh03_MAT.vosh_crossbow.Vault_Vosh_Crossbow_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh03_MAT.vosh_crossbow.Vault_Vosh_Crossbow_3P_Pickup_MIC"))

//Vault Vosh Boomstick
	Skins.Add((Id=6004, Weapondef=class'KFWeapDef_DoubleBarrel', MIC_1P=("WEP_SkinSet_VaultVosh03_MAT.vosh_double_barrell.Vault_Vosh_Double_Barrel_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh03_MAT.vosh_double_barrell.Vault_Vosh_Double_Barrel_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh03_MAT.vosh_double_barrell.Vault_Vosh_Double_Barrel_3P_Pickup_MIC"))

//Vault Vosh Dragonsbreath
	Skins.Add((Id=6005, Weapondef=class'KFWeapDef_DragonsBreath', MIC_1P=("WEP_SkinSet_VaultVosh03_MAT.vosh_dragonsbreath.Vault_Vosh_DragonsBreath_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh03_MAT.vosh_dragonsbreath.Vault_Vosh_DragonsBreath_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh03_MAT.vosh_dragonsbreath.Vault_Vosh_DragonsBreath_3P_Pickup_MIC"))

//Vault Vosh L85A2
	Skins.Add((Id=6006, Weapondef=class'KFWeapDef_Bullpup', MIC_1P=("WEP_SkinSet_VaultVosh03_MAT.vosh_l85a2.Vault_Vosh_L85A2_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh03_MAT.vosh_l85a2.Vault_Vosh_L85A2_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh03_MAT.vosh_l85a2.Vault_Vosh_L85A2_3P_Pickup_MIC"))

//Vault Vosh M1911
	Skins.Add((Id=6007, Weapondef=class'KFWeapDef_Colt1911', MIC_1P=("WEP_SkinSet_VaultVosh03_MAT.vosh_m1911.Vault_Vosh_M1911_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh03_MAT.vosh_m1911.Vault_Vosh_M1911_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh03_MAT.vosh_m1911.Vault_Vosh_M1911_3P_Pickup_MIC"))

//Vault Vosh Medic SMG
	Skins.Add((Id=6008, Weapondef=class'KFWeapDef_MedicSMG', MIC_1P=("WEP_SkinSet_VaultVosh02_MAT.vosh_medic_pistol.Vault_Vosh_Medic_Pistol_1P_Mint_MIC", "WEP_SkinSet_VaultVosh03_MAT.vosh_medic_smg.Vault_Vosh_Medic_SMG_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh03_MAT.vosh_medic_smg.Vault_Vosh_Medic_SMG_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh03_MAT.vosh_medic_smg.Vault_Vosh_Medic_SMG_3P_Pickup_MIC"))

//Vault Vosh MP5RAS
	Skins.Add((Id=6009, Weapondef=class'KFWeapDef_MP5RAS', MIC_1P=("WEP_SkinSet_VaultVosh03_MAT.vosh_mp5ras.Vault_Vosh_MP5RAS_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh03_MAT.vosh_mp5ras.Vault_Vosh_MP5RAS_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh03_MAT.vosh_mp5ras.Vault_Vosh_MP5RAS_3P_Pickup_MIC"))

//Vault Vosh Nailgun
	Skins.Add((Id=6010, Weapondef=class'KFWeapDef_NailGun', MIC_1P=("WEP_SkinSet_VaultVosh03_MAT.vosh_nailgun.Vault_Vosh_Nail_Shotgun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh03_MAT.vosh_nailgun.Vault_Vosh_Nail_Shotgun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh03_MAT.vosh_nailgun.Vault_Vosh_Nail_Shotgun_3P_Pickup_MIC"))

//Prestige Berserker Knife
	Skins.Add((Id=6011, Weapondef=class'KFWeapDef_Knife_Berserker', MIC_1P=("WEP_SkinSet_Prestige01_MAT.knives.Prestige_Berserker_Knife_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_Prestige01_MAT.knives.Prestige_Berserker_Knife_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_Prestige01_MAT.knives.Prestige_Berserker_Knife_3P_Pickup_MIC"))

//Prestige Commando Knife
	Skins.Add((Id=6012, Weapondef=class'KFWeapDef_Knife_Commando', MIC_1P=("WEP_SkinSet_Prestige01_MAT.knives.Prestige_Commando_Knife_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_Prestige01_MAT.knives.Prestige_Commando_Knife_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_Prestige01_MAT.knives.Prestige_Commando_Knife_3P_Pickup_MIC"))

//Prestige Demo Knife
	Skins.Add((Id=6013, Weapondef=class'KFWeapDef_Knife_Demo', MIC_1P=("WEP_SkinSet_Prestige01_MAT.knives.Prestige_Demo_Knife_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_Prestige01_MAT.knives.Prestige_Demo_Knife_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_Prestige01_MAT.knives.Prestige_Demo_Knife_3P_Pickup_MIC"))

//Prestige Firebug Knife
	Skins.Add((Id=6014, Weapondef=class'KFWeapDef_Knife_Firebug', MIC_1P=("WEP_SkinSet_Prestige01_MAT.knives.Prestige_Firebug_Knife_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_Prestige01_MAT.knives.Prestige_Firebug_Knife_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_Prestige01_MAT.knives.Prestige_Firebug_Knife_3P_Pickup_MIC"))

//Prestige Gunslinger Knife
	Skins.Add((Id=6015, Weapondef=class'KFWeapDef_Knife_Gunslinger', MIC_1P=("WEP_SkinSet_Prestige01_MAT.knives.Prestige_Gunslinger_Knife_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_Prestige01_MAT.knives.Prestige_Gunslinger_Knife_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_Prestige01_MAT.knives.Prestige_Gunslinger_Knife_3P_Pickup_MIC"))

//Prestige Medic Knife
	Skins.Add((Id=6016, Weapondef=class'KFWeapDef_Knife_Medic', MIC_1P=("WEP_SkinSet_Prestige01_MAT.knives.Prestige_Medic_Knife_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_Prestige01_MAT.knives.Prestige_Medic_Knife_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_Prestige01_MAT.knives.Prestige_Medic_Knife_3P_Pickup_MIC"))

//Prestige Sharpshooter Knife
	Skins.Add((Id=6017, Weapondef=class'KFWeapDef_Knife_Sharpshooter', MIC_1P=("WEP_SkinSet_Prestige01_MAT.knives.Prestige_Sharpshooter_Knife_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_Prestige01_MAT.knives.Prestige_Sharpshooter_Knife_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_Prestige01_MAT.knives.Prestige_Sharpshooter_Knife_3P_Pickup_MIC"))

//Prestige Support Knife
	Skins.Add((Id=6018, Weapondef=class'KFWeapDef_Knife_Support', MIC_1P=("WEP_SkinSet_Prestige01_MAT.knives.Prestige_Support_Knife_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_Prestige01_MAT.knives.Prestige_Support_Knife_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_Prestige01_MAT.knives.Prestige_Support_Knife_3P_Pickup_MIC"))

//Prestige SWAT Knife
	Skins.Add((Id=6019, Weapondef=class'KFWeapDef_Knife_SWAT', MIC_1P=("WEP_SkinSet_Prestige01_MAT.knives.Prestige_SWAT_Knife_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_Prestige01_MAT.knives.Prestige_SWAT_Knife_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_Prestige01_MAT.knives.Prestige_SWAT_Knife_3P_Pickup_MIC"))

//Prestige Survivalist Knife
	Skins.Add((Id=6029, Weapondef=class'KFWeapDef_Knife_Survivalist', MIC_1P=("WEP_SkinSet_Prestige01_MAT.knives.Prestige_Survivalist_Knife_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_Prestige01_MAT.knives.Prestige_Survivalist_Knife_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_Prestige01_MAT.knives.Prestige_Survivalist_Knife_3P_Pickup_MIC"))

//Neon AA12
    Skins.Add((Id=6053, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet20_MAT.neon_aa12.Neon_AA12_1P_Mint_MIC"), MIC_3P="WEP_SkinSet20_MAT.neon_aa12.Neon_AA12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet20_MAT.neon_aa12.Neon_AA12_3P_Pickup_MIC"))
    Skins.Add((Id=6052, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet20_MAT.neon_aa12.Neon_AA12_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet20_MAT.neon_aa12.Neon_AA12_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet20_MAT.neon_aa12.Neon_AA12_3P_Pickup_MIC"))
    Skins.Add((Id=6051, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet20_MAT.neon_aa12.Neon_AA12_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet20_MAT.neon_aa12.Neon_AA12_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet20_MAT.neon_aa12.Neon_AA12_3P_Pickup_MIC"))

//Neon Flamethrower
    Skins.Add((Id=6056, Weapondef=class'KFWeapDef_FlameThrower', MIC_1P=("WEP_SkinSet20_MAT.neon_flamethrower.Neon_Flamethrower_1P_Mint_MIC"), MIC_3P="WEP_SkinSet20_MAT.neon_flamethrower.Neon_Flamethrower_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet20_MAT.neon_flamethrower.Neon_Flamethrower_3P_Pickup_MIC"))
    Skins.Add((Id=6055, Weapondef=class'KFWeapDef_FlameThrower', MIC_1P=("WEP_SkinSet20_MAT.neon_flamethrower.Neon_Flamethrower_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet20_MAT.neon_flamethrower.Neon_Flamethrower_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet20_MAT.neon_flamethrower.Neon_Flamethrower_3P_Pickup_MIC"))
    Skins.Add((Id=6054, Weapondef=class'KFWeapDef_FlameThrower', MIC_1P=("WEP_SkinSet20_MAT.neon_flamethrower.Neon_Flamethrower_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet20_MAT.neon_flamethrower.Neon_Flamethrower_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet20_MAT.neon_flamethrower.Neon_Flamethrower_3P_Pickup_MIC"))

//Neon Hemoglobin
    Skins.Add((Id=6059, Weapondef=class'KFWeapDef_Hemogoblin', MIC_1P=("WEP_SkinSet20_MAT.neon_bleeder.Neon_Bleeder_1P_Mint_MIC", "WEP_SkinSet20_MAT.neon_bleeder.Neon_Bleeder_sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet20_MAT.neon_bleeder.Neon_Bleeder_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet20_MAT.neon_bleeder.Neon_Bleeder_3P_Pickup_MIC"))
    Skins.Add((Id=6058, Weapondef=class'KFWeapDef_Hemogoblin', MIC_1P=("WEP_SkinSet20_MAT.neon_bleeder.Neon_Bleeder_1P_FieldTested_MIC", "WEP_SkinSet20_MAT.neon_bleeder.Neon_Bleeder_Sight_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet20_MAT.neon_bleeder.Neon_Bleeder_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet20_MAT.neon_bleeder.Neon_Bleeder_3P_Pickup_MIC"))
    Skins.Add((Id=6057, Weapondef=class'KFWeapDef_Hemogoblin', MIC_1P=("WEP_SkinSet20_MAT.neon_bleeder.Neon_Bleeder_1P_BattleScarred_MIC", "WEP_SkinSet20_MAT.neon_bleeder.Neon_Bleeder_Sight_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet20_MAT.neon_bleeder.Neon_Bleeder_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet20_MAT.neon_bleeder.Neon_Bleeder_3P_Pickup_MIC"))

//Neon M14EBR
    Skins.Add((Id=6062, Weapondef=class'KFWeapDef_M14EBR', MIC_1P=("WEP_SkinSet20_MAT.neon_m14ebr.Neon_M14EBR_1P_Mint_MIC", "WEP_SkinSet20_MAT.neon_m14ebr.Neon_M14EBR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet20_MAT.neon_m14ebr.Neon_M14EBR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet20_MAT.neon_m14ebr.Neon_M14EBR_3P_Pickup_MIC"))
    Skins.Add((Id=6061, Weapondef=class'KFWeapDef_M14EBR', MIC_1P=("WEP_SkinSet20_MAT.neon_m14ebr.Neon_M14EBR_1P_FieldTested_MIC", "WEP_SkinSet20_MAT.neon_m14ebr.Neon_M14EBR_Scope_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet20_MAT.neon_m14ebr.Neon_M14EBR_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet20_MAT.neon_m14ebr.Neon_M14EBR_3P_Pickup_MIC"))
    Skins.Add((Id=6060, Weapondef=class'KFWeapDef_M14EBR', MIC_1P=("WEP_SkinSet20_MAT.neon_m14ebr.Neon_M14EBR_1P_BattleScarred_MIC", "WEP_SkinSet20_MAT.neon_m14ebr.Neon_M14EBR_Scope_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet20_MAT.neon_m14ebr.Neon_M14EBR_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet20_MAT.neon_m14ebr.Neon_M14EBR_3P_Pickup_MIC"))

//Neon Microwave Gun
    Skins.Add((Id=6065, Weapondef=class'KFWeapDef_MicrowaveGun', MIC_1P=("WEP_SkinSet20_MAT.neon_microwavegun.Neon_Microwavegun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet20_MAT.neon_microwavegun.Neon_Microwavegun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet20_MAT.neon_microwavegun.Neon_Microwavegun_3P_Pickup_MIC"))
    Skins.Add((Id=6064, Weapondef=class'KFWeapDef_MicrowaveGun', MIC_1P=("WEP_SkinSet20_MAT.neon_microwavegun.Neon_Microwavegun_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet20_MAT.neon_microwavegun.Neon_Microwavegun_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet20_MAT.neon_microwavegun.Neon_Microwavegun_3P_Pickup_MIC"))
    Skins.Add((Id=6063, Weapondef=class'KFWeapDef_MicrowaveGun', MIC_1P=("WEP_SkinSet20_MAT.neon_microwavegun.Neon_Microwavegun_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet20_MAT.neon_microwavegun.Neon_Microwavegun_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet20_MAT.neon_microwavegun.Neon_Microwavegun_3P_Pickup_MIC"))

//Neon Seeker Six
    Skins.Add((Id=6068, Weapondef=class'KFWeapDef_Seeker6', MIC_1P=("WEP_SkinSet20_MAT.neon_seekersix.Neon_SeekerSix_1P_Mint_MIC", "WEP_SkinSet20_MAT.neon_seekersix.Neon_SeekerSix_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet20_MAT.neon_seekersix.Neon_SeekerSix_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet20_MAT.neon_seekersix.Neon_SeekerSix_3P_Pickup_MIC"))
    Skins.Add((Id=6067, Weapondef=class'KFWeapDef_Seeker6', MIC_1P=("WEP_SkinSet20_MAT.neon_seekersix.Neon_SeekerSix_1P_FieldTested_MIC", "WEP_SkinSet20_MAT.neon_seekersix.Neon_SeekerSix_Sight_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet20_MAT.neon_seekersix.Neon_SeekerSix_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet20_MAT.neon_seekersix.Neon_SeekerSix_3P_Pickup_MIC"))
    Skins.Add((Id=6066, Weapondef=class'KFWeapDef_Seeker6', MIC_1P=("WEP_SkinSet20_MAT.neon_seekersix.Neon_SeekerSix_1P_BattleScarred_MIC", "WEP_SkinSet20_MAT.neon_seekersix.Neon_SeekerSix_Sight_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet20_MAT.neon_seekersix.Neon_SeekerSix_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet20_MAT.neon_seekersix.Neon_SeekerSix_3P_Pickup_MIC"))

//Neon Stoner 63A
    Skins.Add((Id=6071, Weapondef=class'KFWeapDef_Stoner63a', MIC_1P=("WEP_SkinSet20_MAT.neon_stoner63a.Neon_Stoner63a_1P_Mint_MIC", "WEP_SkinSet20_MAT.neon_stoner63a.Neon_Stoner63a_Upper_1P_Mint_MIC"), MIC_3P="WEP_SkinSet20_MAT.neon_stoner63a.Neon_Stoner63a_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet20_MAT.neon_stoner63a.Neon_Stoner63a_3P_Pickup_MIC"))
    Skins.Add((Id=6070, Weapondef=class'KFWeapDef_Stoner63a', MIC_1P=("WEP_SkinSet20_MAT.neon_stoner63a.Neon_Stoner63a_1P_FieldTested_MIC", "WEP_SkinSet20_MAT.neon_stoner63a.Neon_Stoner63a_Upper_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet20_MAT.neon_stoner63a.Neon_Stoner63a_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet20_MAT.neon_stoner63a.Neon_Stoner63a_3P_Pickup_MIC"))
    Skins.Add((Id=6069, Weapondef=class'KFWeapDef_Stoner63a', MIC_1P=("WEP_SkinSet20_MAT.neon_stoner63a.Neon_Stoner63a_1P_BattleScarred_MIC", "WEP_SkinSet20_MAT.neon_stoner63a.Neon_Stoner63a_Upper_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet20_MAT.neon_stoner63a.Neon_Stoner63a_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet20_MAT.neon_stoner63a.Neon_Stoner63a_3P_Pickup_MIC"))

//Neon Heckler & Koch UMP
    Skins.Add((Id=6074, Weapondef=class'KFWeapDef_HK_UMP', MIC_1P=("WEP_SkinSet20_MAT.neon_hk_ump.Neon_HK_UMP_1P_Mint_MIC", "WEP_SkinSet20_MAT.neon_hk_ump.Neon_HK_UMP_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet20_MAT.neon_hk_ump.Neon_HK_UMP_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet20_MAT.neon_hk_ump.Neon_HK_UMP_3P_Pickup_MIC"))
    Skins.Add((Id=6073, Weapondef=class'KFWeapDef_HK_UMP', MIC_1P=("WEP_SkinSet20_MAT.neon_hk_ump.Neon_HK_UMP_1P_FieldTested_MIC", "WEP_SkinSet20_MAT.neon_hk_ump.Neon_HK_UMP_Sight_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet20_MAT.neon_hk_ump.Neon_HK_UMP_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet20_MAT.neon_hk_ump.Neon_HK_UMP_3P_Pickup_MIC"))
    Skins.Add((Id=6072, Weapondef=class'KFWeapDef_HK_UMP', MIC_1P=("WEP_SkinSet20_MAT.neon_hk_ump.Neon_HK_UMP_1P_BattleScarred_MIC", "WEP_SkinSet20_MAT.neon_hk_ump.Neon_HK_UMP_Sight_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet20_MAT.neon_hk_ump.Neon_HK_UMP_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet20_MAT.neon_hk_ump.Neon_HK_UMP_3P_Pickup_MIC"))

//Neon RGB AA12
    Skins.Add((Id=6177, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet20_MAT.neonrgb_aa12.NeonRGB_AA12_1P_Mint_MIC"), MIC_3P="WEP_SkinSet20_MAT.neonrgb_aa12.NeonRGB_AA12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet20_MAT.neonrgb_aa12.NeonRGB_AA12_3P_Pickup_MIC"))

//Neon RGB Flamethrower
    Skins.Add((Id=6178, Weapondef=class'KFWeapDef_FlameThrower', MIC_1P=("WEP_SkinSet20_MAT.neonrgb_flamethrower.NeonRGB_Flamethrower_1P_Mint_MIC"), MIC_3P="WEP_SkinSet20_MAT.neonrgb_flamethrower.NeonRGB_Flamethrower_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet20_MAT.neonrgb_flamethrower.NeonRGB_Flamethrower_3P_Pickup_MIC"))

//Neon RGB Hemoglobin
    Skins.Add((Id=6179, Weapondef=class'KFWeapDef_Hemogoblin', MIC_1P=("WEP_SkinSet20_MAT.neonrgb_bleeder.NeonRGB_Bleeder_1P_Mint_MIC", "WEP_SkinSet20_MAT.neonrgb_bleeder.NeonRGB_Bleeder_sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet20_MAT.neonrgb_bleeder.NeonRGB_Bleeder_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet20_MAT.neonrgb_bleeder.NeonRGB_Bleeder_3P_Pickup_MIC"))

//Neon RGB M14EBR
    Skins.Add((Id=6180, Weapondef=class'KFWeapDef_M14EBR', MIC_1P=("WEP_SkinSet20_MAT.neonrgb_m14ebr.NeonRGB_M14EBR_1P_Mint_MIC", "WEP_SkinSet20_MAT.neonrgb_m14ebr.NeonRGB_M14EBR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet20_MAT.neonrgb_m14ebr.NeonRGB_M14EBR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet20_MAT.neonrgb_m14ebr.NeonRGB_M14EBR_3P_Pickup_MIC"))

//Neon RGB Microwave Gun
    Skins.Add((Id=6182, Weapondef=class'KFWeapDef_MicrowaveGun', MIC_1P=("WEP_SkinSet20_MAT.neonrgb_microwavegun.NeonRGB_Microwavegun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet20_MAT.neonrgb_microwavegun.NeonRGB_Microwavegun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet20_MAT.neonrgb_microwavegun.NeonRGB_Microwavegun_3P_Pickup_MIC"))

//Neon RGB Seeker Six
    Skins.Add((Id=6181, Weapondef=class'KFWeapDef_Seeker6', MIC_1P=("WEP_SkinSet20_MAT.neonrgb_seekersix.NeonRGB_SeekerSix_1P_Mint_MIC", "WEP_SkinSet20_MAT.neonrgb_seekersix.NeonRGB_SeekerSix_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet20_MAT.neonrgb_seekersix.NeonRGB_SeekerSix_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet20_MAT.neonrgb_seekersix.NeonRGB_SeekerSix_3P_Pickup_MIC"))

//Neon RGB Stoner 63A
    Skins.Add((Id=6184, Weapondef=class'KFWeapDef_Stoner63a', MIC_1P=("WEP_SkinSet20_MAT.neonrgb_stoner63a.NeonRGB_Stoner63a_1P_Mint_MIC", "WEP_SkinSet20_MAT.neonrgb_stoner63a.NeonRGB_Stoner63a_Upper_1P_Mint_MIC"), MIC_3P="WEP_SkinSet20_MAT.neonrgb_stoner63a.NeonRGB_Stoner63a_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet20_MAT.neonrgb_stoner63a.NeonRGB_Stoner63a_3P_Pickup_MIC"))

//Neon RGB Heckler & Koch UMP
    Skins.Add((Id=6183, Weapondef=class'KFWeapDef_HK_UMP', MIC_1P=("WEP_SkinSet20_MAT.neonrgb_hk_ump.NeonRGB_HK_UMP_1P_Mint_MIC", "WEP_SkinSet20_MAT.neonrgb_hk_ump.NeonRGB_HK_UMP_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet20_MAT.neonrgb_hk_ump.NeonRGB_HK_UMP_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet20_MAT.neonrgb_hk_ump.NeonRGB_HK_UMP_3P_Pickup_MIC"))

//Bluefire AK12
    Skins.Add((Id=6092, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("wep_skinset19_mat.bluefire_ak12.Bluefire_AK12_1P_Mint_MIC", "wep_skinset19_mat.bluefire_ak12.Bluefire_AK12_Sight_1P_Mint_MIC"), MIC_3P="wep_skinset19_mat.bluefire_ak12.Bluefire_AK12_3P_Mint_MIC", MIC_Pickup="wep_skinset19_mat.bluefire_ak12.Bluefire_AK12_3P_Pickup_MIC"))
    Skins.Add((Id=6091, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("wep_skinset19_mat.bluefire_ak12.Bluefire_AK12_1P_FieldTested_MIC", "wep_skinset19_mat.bluefire_ak12.Bluefire_AK12_Sight_1P_Mint_MIC"), MIC_3P="wep_skinset19_mat.bluefire_ak12.Bluefire_AK12_3P_FieldTested_MIC", MIC_Pickup="wep_skinset19_mat.bluefire_ak12.Bluefire_AK12_3P_Pickup_MIC"))
    Skins.Add((Id=6090, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("wep_skinset19_mat.bluefire_ak12.Bluefire_AK12_1P_BattleScarred_MIC", "wep_skinset19_mat.bluefire_ak12.Bluefire_AK12_Sight_1P_Mint_MIC"), MIC_3P="wep_skinset19_mat.bluefire_ak12.Bluefire_AK12_3P_BattleScarred_MIC", MIC_Pickup="wep_skinset19_mat.bluefire_ak12.Bluefire_AK12_3P_Pickup_MIC"))

//Bluefire Centerfire
    Skins.Add((Id=6095, Weapondef=class'KFWeapDef_CenterfireMB464', MIC_1P=("wep_skinset19_mat.bluefire_centerfire.Bluefire_Centerfire_1P_Mint_MIC"), MIC_3P="wep_skinset19_mat.bluefire_centerfire.Bluefire_Centerfire_3P_Mint_MIC", MIC_Pickup="wep_skinset19_mat.bluefire_centerfire.Bluefire_Centerfire_3P_Pickup_MIC"))
    Skins.Add((Id=6094, Weapondef=class'KFWeapDef_CenterfireMB464', MIC_1P=("wep_skinset19_mat.bluefire_centerfire.Bluefire_Centerfire_1P_FieldTested_MIC"), MIC_3P="wep_skinset19_mat.bluefire_centerfire.Bluefire_Centerfire_3P_FieldTested_MIC", MIC_Pickup="wep_skinset19_mat.bluefire_centerfire.Bluefire_Centerfire_3P_Pickup_MIC"))
    Skins.Add((Id=6093, Weapondef=class'KFWeapDef_CenterfireMB464', MIC_1P=("wep_skinset19_mat.bluefire_centerfire.Bluefire_Centerfire_1P_BattleScarred_MIC"), MIC_3P="wep_skinset19_mat.bluefire_centerfire.Bluefire_Centerfire_3P_BattleScarred_MIC", MIC_Pickup="wep_skinset19_mat.bluefire_centerfire.Bluefire_Centerfire_3P_Pickup_MIC"))

//Bluefire Freeze Thrower
    Skins.Add((Id=6098, Weapondef=class'KFWeapDef_FreezeThrower', MIC_1P=("WEP_SkinSet19_MAT.bluefire_cryogun.Bluefire_CryoGun_1P_Mint_MIC", "WEP_SkinSet19_MAT.bluefire_cryogun.Bluefire_CryoGunMain_1P_Mint_MIC"), MIC_3P="wep_skinset19_mat.bluefire_cryogun.Bluefire_CryoGun_3P_Mint_MIC", MIC_Pickup="wep_skinset19_mat.bluefire_cryogun.Bluefire_CryoGun_3P_Pickup_MIC"))
    Skins.Add((Id=6097, Weapondef=class'KFWeapDef_FreezeThrower', MIC_1P=("WEP_SkinSet19_MAT.bluefire_cryogun.Bluefire_CryoGun_1P_FieldTested_MIC", "WEP_SkinSet19_MAT.bluefire_cryogun.Bluefire_CryoGunMain_1P_FieldTested_MIC"), MIC_3P="wep_skinset19_mat.bluefire_cryogun.Bluefire_CryoGun_3P_FieldTested_MIC", MIC_Pickup="wep_skinset19_mat.bluefire_cryogun.Bluefire_CryoGun_3P_Pickup_MIC"))
    Skins.Add((Id=6096, Weapondef=class'KFWeapDef_FreezeThrower', MIC_1P=("WEP_SkinSet19_MAT.bluefire_cryogun.Bluefire_CryoGun_1P_BattleScarred_MIC", "WEP_SkinSet19_MAT.bluefire_cryogun.Bluefire_CryoGunMain_1P_BattleScarred_MIC"), MIC_3P="wep_skinset19_mat.bluefire_cryogun.Bluefire_CryoGun_3P_BattleScarred_MIC", MIC_Pickup="wep_skinset19_mat.bluefire_cryogun.Bluefire_CryoGun_3P_Pickup_MIC"))

//Bluefire Hemoglobin
    Skins.Add((Id=6101, Weapondef=class'KFWeapDef_Hemogoblin', MIC_1P=("wep_skinset19_mat.bluefire_bleeder.Bluefire_Bleeder_1P_Mint_MIC", "wep_skinset19_mat.bluefire_bleeder.Bluefire_Bleeder_Sight_1P_Mint_MIC"), MIC_3P="wep_skinset19_mat.bluefire_bleeder.Bluefire_Bleeder_3P_Mint_MIC", MIC_Pickup="wep_skinset19_mat.bluefire_bleeder.Bluefire_Bleeder_3P_Pickup_MIC"))
    Skins.Add((Id=6100, Weapondef=class'KFWeapDef_Hemogoblin', MIC_1P=("wep_skinset19_mat.bluefire_bleeder.Bluefire_Bleeder_1P_FieldTested_MIC", "wep_skinset19_mat.bluefire_bleeder.Bluefire_Bleeder_Sight_1P_Mint_MIC"), MIC_3P="wep_skinset19_mat.bluefire_bleeder.Bluefire_Bleeder_3P_FieldTested_MIC", MIC_Pickup="wep_skinset19_mat.bluefire_bleeder.Bluefire_Bleeder_3P_Pickup_MIC"))
    Skins.Add((Id=6099, Weapondef=class'KFWeapDef_Hemogoblin', MIC_1P=("wep_skinset19_mat.bluefire_bleeder.Bluefire_Bleeder_1P_BattleScarred_MIC", "wep_skinset19_mat.bluefire_bleeder.Bluefire_Bleeder_Sight_1P_Mint_MIC"), MIC_3P="wep_skinset19_mat.bluefire_bleeder.Bluefire_Bleeder_3P_BattleScarred_MIC", MIC_Pickup="wep_skinset19_mat.bluefire_bleeder.Bluefire_Bleeder_3P_Pickup_MIC"))

//Bluefire M1911
    Skins.Add((Id=6104, Weapondef=class'KFWeapDef_Colt1911', MIC_1P=("wep_skinset19_mat.bluefire_m1911.Bluefire_M1911_1P_Mint_MIC"), MIC_3P="wep_skinset19_mat.bluefire_m1911.Bluefire_M1911_3P_Mint_MIC", MIC_Pickup="wep_skinset19_mat.bluefire_m1911.Bluefire_M1911_3P_Pickup_MIC"))
    Skins.Add((Id=6103, Weapondef=class'KFWeapDef_Colt1911', MIC_1P=("wep_skinset19_mat.bluefire_m1911.Bluefire_M1911_1P_FieldTested_MIC"), MIC_3P="wep_skinset19_mat.bluefire_m1911.Bluefire_M1911_3P_FieldTested_MIC", MIC_Pickup="wep_skinset19_mat.bluefire_m1911.Bluefire_M1911_3P_Pickup_MIC"))
    Skins.Add((Id=6102, Weapondef=class'KFWeapDef_Colt1911', MIC_1P=("wep_skinset19_mat.bluefire_m1911.Bluefire_M1911_1P_BattleScarred_MIC"), MIC_3P="wep_skinset19_mat.bluefire_m1911.Bluefire_M1911_3P_BattleScarred_MIC", MIC_Pickup="wep_skinset19_mat.bluefire_m1911.Bluefire_M1911_3P_Pickup_MIC"))

//Bluefire M4
    Skins.Add((Id=6107, Weapondef=class'KFWeapDef_M4', MIC_1P=("wep_skinset19_mat.bluefire_m4.Bluefire_M4_1P_Mint_MIC"), MIC_3P="wep_skinset19_mat.bluefire_m4.Bluefire_M4_3P_Mint_MIC", MIC_Pickup="wep_skinset19_mat.bluefire_m4.Bluefire_M4_3P_Pickup_MIC"))
    Skins.Add((Id=6106, Weapondef=class'KFWeapDef_M4', MIC_1P=("wep_skinset19_mat.bluefire_m4.Bluefire_M4_1P_FieldTested_MIC"), MIC_3P="wep_skinset19_mat.bluefire_m4.Bluefire_M4_3P_FieldTested_MIC", MIC_Pickup="wep_skinset19_mat.bluefire_m4.Bluefire_M4_3P_Pickup_MIC"))
    Skins.Add((Id=6105, Weapondef=class'KFWeapDef_M4', MIC_1P=("wep_skinset19_mat.bluefire_m4.Bluefire_M4_1P_BattleScarred_MIC"), MIC_3P="wep_skinset19_mat.bluefire_m4.Bluefire_M4_3P_BattleScarred_MIC", MIC_Pickup="wep_skinset19_mat.bluefire_m4.Bluefire_M4_3P_Pickup_MIC"))

//Bluefire M79
    Skins.Add((Id=6110, Weapondef=class'KFWeapDef_M79', MIC_1P=("wep_skinset19_mat.bluefire_m79.Bluefire_M79_1P_Mint_MIC"), MIC_3P="wep_skinset19_mat.bluefire_m79.Bluefire_M79_3P_Mint_MIC", MIC_Pickup="wep_skinset19_mat.bluefire_m79.Bluefire_M79_3P_Pickup_MIC"))
    Skins.Add((Id=6109, Weapondef=class'KFWeapDef_M79', MIC_1P=("wep_skinset19_mat.bluefire_m79.Bluefire_M79_1P_FieldTested_MIC"), MIC_3P="wep_skinset19_mat.bluefire_m79.Bluefire_M79_3P_FieldTested_MIC", MIC_Pickup="wep_skinset19_mat.bluefire_m79.Bluefire_M79_3P_Pickup_MIC"))
    Skins.Add((Id=6108, Weapondef=class'KFWeapDef_M79', MIC_1P=("wep_skinset19_mat.bluefire_m79.Bluefire_M79_1P_BattleScarred_MIC"), MIC_3P="wep_skinset19_mat.bluefire_m79.Bluefire_M79_3P_BattleScarred_MIC", MIC_Pickup="wep_skinset19_mat.bluefire_m79.Bluefire_M79_3P_Pickup_MIC"))

//Bluefire MP7
    Skins.Add((Id=6113, Weapondef=class'KFWeapDef_MP7', MIC_1P=("wep_skinset19_mat.bluefire_mp7.Bluefire_MP7_1P_Mint_MIC", "wep_skinset19_mat.bluefire_mp7.Bluefire_MP7_Sight_1P_Mint_MIC"), MIC_3P="wep_skinset19_mat.bluefire_mp7.Bluefire_MP7_3P_Mint_MIC", MIC_Pickup="wep_skinset19_mat.bluefire_mp7.Bluefire_MP7_3P_Pickup_MIC"))
    Skins.Add((Id=6112, Weapondef=class'KFWeapDef_MP7', MIC_1P=("wep_skinset19_mat.bluefire_mp7.Bluefire_MP7_1P_FieldTested_MIC", "wep_skinset19_mat.bluefire_mp7.Bluefire_MP7_Sight_1P_Mint_MIC"), MIC_3P="wep_skinset19_mat.bluefire_mp7.Bluefire_MP7_3P_FieldTested_MIC", MIC_Pickup="wep_skinset19_mat.bluefire_mp7.Bluefire_MP7_3P_Pickup_MIC"))
    Skins.Add((Id=6111, Weapondef=class'KFWeapDef_MP7', MIC_1P=("wep_skinset19_mat.bluefire_mp7.Bluefire_MP7_1P_BattleScarred_MIC", "wep_skinset19_mat.bluefire_mp7.Bluefire_MP7_Sight_1P_Mint_MIC"), MIC_3P="wep_skinset19_mat.bluefire_mp7.Bluefire_MP7_3P_BattleScarred_MIC", MIC_Pickup="wep_skinset19_mat.bluefire_mp7.Bluefire_MP7_3P_Pickup_MIC"))

//Bluefire Railgun
    Skins.Add((Id=6116, Weapondef=class'KFWeapDef_Railgun', MIC_1P=("wep_skinset19_mat.bluefire_railgun.Bluefire_Railgun_1P_Mint_MIC", "wep_skinset19_mat.bluefire_railgun.Bluefire_Railgun_Sight_1P_Mint_MIC"), MIC_3P="wep_skinset19_mat.bluefire_railgun.Bluefire_Railgun_3P_Mint_MIC", MIC_Pickup="wep_skinset19_mat.bluefire_railgun.Bluefire_Railgun_3P_Pickup_MIC"))
    Skins.Add((Id=6115, Weapondef=class'KFWeapDef_Railgun', MIC_1P=("wep_skinset19_mat.bluefire_railgun.Bluefire_Railgun_1P_FieldTested_MIC", "wep_skinset19_mat.bluefire_railgun.Bluefire_Railgun_Sight_1P_Mint_MIC"), MIC_3P="wep_skinset19_mat.bluefire_railgun.Bluefire_Railgun_3P_FieldTested_MIC", MIC_Pickup="wep_skinset19_mat.bluefire_railgun.Bluefire_Railgun_3P_Pickup_MIC"))
    Skins.Add((Id=6114, Weapondef=class'KFWeapDef_Railgun', MIC_1P=("wep_skinset19_mat.bluefire_railgun.Bluefire_Railgun_1P_BattleScarred_MIC", "wep_skinset19_mat.bluefire_railgun.Bluefire_Railgun_Sight_1P_Mint_MIC"), MIC_3P="wep_skinset19_mat.bluefire_railgun.Bluefire_Railgun_3P_BattleScarred_MIC", MIC_Pickup="wep_skinset19_mat.bluefire_railgun.Bluefire_Railgun_3P_Pickup_MIC"))

//Bluefire RPG-7
    Skins.Add((Id=6119, Weapondef=class'KFWeapDef_RPG7', MIC_1P=("wep_skinset19_mat.bluefire_rpg7.Bluefire_RPG7_1P_Mint_MIC"), MIC_3P="wep_skinset19_mat.bluefire_rpg7.Bluefire_RPG7_3P_Mint_MIC", MIC_Pickup="wep_skinset19_mat.bluefire_rpg7.Bluefire_RPG7_3P_Pickup_MIC"))
    Skins.Add((Id=6118, Weapondef=class'KFWeapDef_RPG7', MIC_1P=("wep_skinset19_mat.bluefire_rpg7.Bluefire_RPG7_1P_FieldTested_MIC"), MIC_3P="wep_skinset19_mat.bluefire_rpg7.Bluefire_RPG7_3P_FieldTested_MIC", MIC_Pickup="wep_skinset19_mat.bluefire_rpg7.Bluefire_RPG7_3P_Pickup_MIC"))
    Skins.Add((Id=6117, Weapondef=class'KFWeapDef_RPG7', MIC_1P=("wep_skinset19_mat.bluefire_rpg7.Bluefire_RPG7_1P_BattleScarred_MIC"), MIC_3P="wep_skinset19_mat.bluefire_rpg7.Bluefire_RPG7_3P_BattleScarred_MIC", MIC_Pickup="wep_skinset19_mat.bluefire_rpg7.Bluefire_RPG7_3P_Pickup_MIC"))

//Bluefire Seeker Six
    Skins.Add((Id=6122, Weapondef=class'KFWeapDef_Seeker6', MIC_1P=("wep_skinset19_mat.bluefire_seekersix.Bluefire_SeekerSix_1P_Mint_MIC", "wep_skinset19_mat.bluefire_seekersix.Bluefire_SeekerSix_Sight_1P_Mint_MIC"), MIC_3P="wep_skinset19_mat.bluefire_seekersix.Bluefire_SeekerSix_3P_Mint_MIC", MIC_Pickup="wep_skinset19_mat.bluefire_seekersix.Bluefire_SeekerSix_3P_Pickup_MIC"))
    Skins.Add((Id=6121, Weapondef=class'KFWeapDef_Seeker6', MIC_1P=("wep_skinset19_mat.bluefire_seekersix.Bluefire_SeekerSix_1P_FieldTested_MIC", "wep_skinset19_mat.bluefire_seekersix.Bluefire_SeekerSix_Sight_1P_Mint_MIC"), MIC_3P="wep_skinset19_mat.bluefire_seekersix.Bluefire_SeekerSix_3P_FieldTested_MIC", MIC_Pickup="wep_skinset19_mat.bluefire_seekersix.Bluefire_SeekerSix_3P_Pickup_MIC"))
    Skins.Add((Id=6120, Weapondef=class'KFWeapDef_Seeker6', MIC_1P=("wep_skinset19_mat.bluefire_seekersix.Bluefire_SeekerSix_1P_BattleScarred_MIC", "wep_skinset19_mat.bluefire_seekersix.Bluefire_SeekerSix_Sight_1P_Mint_MIC"), MIC_3P="wep_skinset19_mat.bluefire_seekersix.Bluefire_SeekerSix_3P_BattleScarred_MIC", MIC_Pickup="wep_skinset19_mat.bluefire_seekersix.Bluefire_SeekerSix_3P_Pickup_MIC"))

//Bluefire VLAD-1000 Nailgun
    Skins.Add((Id=6125, Weapondef=class'KFWeapDef_NailGun', MIC_1P=("wep_skinset19_mat.bluefire_nailgun.Bluefire_Nailgun_1P_Mint_MIC"), MIC_3P="wep_skinset19_mat.bluefire_nailgun.Bluefire_Nailgun_3P_Mint_MIC", MIC_Pickup="wep_skinset19_mat.bluefire_nailgun.Bluefire_Nailgun_3P_Pickup_MIC"))
    Skins.Add((Id=6124, Weapondef=class'KFWeapDef_NailGun', MIC_1P=("wep_skinset19_mat.bluefire_nailgun.Bluefire_Nailgun_1P_FieldTested_MIC"), MIC_3P="wep_skinset19_mat.bluefire_nailgun.Bluefire_Nailgun_3P_FieldTested_MIC", MIC_Pickup="wep_skinset19_mat.bluefire_nailgun.Bluefire_Nailgun_3P_Pickup_MIC"))
    Skins.Add((Id=6123, Weapondef=class'KFWeapDef_NailGun', MIC_1P=("wep_skinset19_mat.bluefire_nailgun.Bluefire_Nailgun_1P_BattleScarred_MIC"), MIC_3P="wep_skinset19_mat.bluefire_nailgun.Bluefire_Nailgun_3P_BattleScarred_MIC", MIC_Pickup="wep_skinset19_mat.bluefire_nailgun.Bluefire_Nailgun_3P_Pickup_MIC"))

//Horzine First Encounter AK12
    Skins.Add((Id=6128, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("wep_skinset19_mat.horzinefe_ak12.HorzineFE_AK12_1P_Mint_MIC", "wep_skinset19_mat.horzinefe_ak12.HorzineFE_AK12_Scope_1P_Mint_MIC"), MIC_3P="wep_skinset19_mat.horzinefe_ak12.HorzineFE_AK12_3P_Mint_MIC", MIC_Pickup="wep_skinset19_mat.horzinefe_ak12.HorzineFE_AK12_3P_Pickup_MIC"))
    Skins.Add((Id=6127, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("wep_skinset19_mat.horzinefe_ak12.HorzineFE_AK12_1P_FieldTested_MIC", "wep_skinset19_mat.horzinefe_ak12.HorzineFE_AK12_Scope_1P_Mint_MIC"), MIC_3P="wep_skinset19_mat.horzinefe_ak12.HorzineFE_AK12_3P_FieldTested_MIC", MIC_Pickup="wep_skinset19_mat.horzinefe_ak12.HorzineFE_AK12_3P_Pickup_MIC"))
    Skins.Add((Id=6126, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("wep_skinset19_mat.horzinefe_ak12.HorzineFE_AK12_1P_BattleScarred_MIC", "wep_skinset19_mat.horzinefe_ak12.HorzineFE_AK12_Scope_1P_Mint_MIC"), MIC_3P="wep_skinset19_mat.horzinefe_ak12.HorzineFE_AK12_3P_BattleScarred_MIC", MIC_Pickup="wep_skinset19_mat.horzinefe_ak12.HorzineFE_AK12_3P_Pickup_MIC"))

//Horzine First Encounter Centerfire
    Skins.Add((Id=6131, Weapondef=class'KFWeapDef_CenterfireMB464', MIC_1P=("wep_skinset19_mat.horzinefe_centerfire.HorzineFE_Centerfire_1P_Mint_MIC"), MIC_3P="wep_skinset19_mat.horzinefe_centerfire.HorzineFE_Centerfire_3P_Mint_MIC", MIC_Pickup="wep_skinset19_mat.horzinefe_centerfire.HorzineFE_Centerfire_3P_Pickup_MIC"))
    Skins.Add((Id=6130, Weapondef=class'KFWeapDef_CenterfireMB464', MIC_1P=("wep_skinset19_mat.horzinefe_centerfire.HorzineFE_Centerfire_1P_FieldTested_MIC"), MIC_3P="wep_skinset19_mat.horzinefe_centerfire.HorzineFE_Centerfire_3P_FieldTested_MIC", MIC_Pickup="wep_skinset19_mat.horzinefe_centerfire.HorzineFE_Centerfire_3P_Pickup_MIC"))
    Skins.Add((Id=6129, Weapondef=class'KFWeapDef_CenterfireMB464', MIC_1P=("wep_skinset19_mat.horzinefe_centerfire.HorzineFE_Centerfire_1P_BattleScarred_MIC"), MIC_3P="wep_skinset19_mat.horzinefe_centerfire.HorzineFE_Centerfire_3P_BattleScarred_MIC", MIC_Pickup="wep_skinset19_mat.horzinefe_centerfire.HorzineFE_Centerfire_3P_Pickup_MIC"))

//Horzine First Encounter Boomstick
    Skins.Add((Id=6134, Weapondef=class'KFWeapDef_DoubleBarrel', MIC_1P=("wep_skinset19_mat.horzinefe_boomstick.HorzineFE_Boomstick_1P_Mint_MIC"), MIC_3P="wep_skinset19_mat.horzinefe_boomstick.HorzineFE_Boomstick_3P_Mint_MIC", MIC_Pickup="wep_skinset19_mat.horzinefe_boomstick.HorzineFE_Boomstick_3P_Pickup_MIC"))
    Skins.Add((Id=6133, Weapondef=class'KFWeapDef_DoubleBarrel', MIC_1P=("wep_skinset19_mat.horzinefe_boomstick.HorzineFE_Boomstick_1P_FieldTested_MIC"), MIC_3P="wep_skinset19_mat.horzinefe_boomstick.HorzineFE_Boomstick_3P_FieldTested_MIC", MIC_Pickup="wep_skinset19_mat.horzinefe_boomstick.HorzineFE_Boomstick_3P_Pickup_MIC"))
    Skins.Add((Id=6132, Weapondef=class'KFWeapDef_DoubleBarrel', MIC_1P=("wep_skinset19_mat.horzinefe_boomstick.HorzineFE_Boomstick_1P_BattleScarred_MIC"), MIC_3P="wep_skinset19_mat.horzinefe_boomstick.HorzineFE_Boomstick_3P_BattleScarred_MIC", MIC_Pickup="wep_skinset19_mat.horzinefe_boomstick.HorzineFE_Boomstick_3P_Pickup_MIC"))

//Horzine First Encounter HZ12
    Skins.Add((Id=6140, Weapondef=class'KFWeapDef_HZ12', MIC_1P=("wep_skinset19_mat.horzinefe_hz12.HorzineFE_HZ12_1P_Mint_MIC"), MIC_3P="wep_skinset19_mat.horzinefe_hz12.HorzineFE_HZ12_3P_Mint_MIC", MIC_Pickup="wep_skinset19_mat.horzinefe_hz12.HorzineFE_HZ12_3P_Pickup_MIC"))
    Skins.Add((Id=6139, Weapondef=class'KFWeapDef_HZ12', MIC_1P=("wep_skinset19_mat.horzinefe_hz12.HorzineFE_HZ12_1P_FieldTested_MIC"), MIC_3P="wep_skinset19_mat.horzinefe_hz12.HorzineFE_HZ12_3P_FieldTested_MIC", MIC_Pickup="wep_skinset19_mat.horzinefe_hz12.HorzineFE_HZ12_3P_Pickup_MIC"))
    Skins.Add((Id=6138, Weapondef=class'KFWeapDef_HZ12', MIC_1P=("wep_skinset19_mat.horzinefe_hz12.HorzineFE_HZ12_1P_BattleScarred_MIC"), MIC_3P="wep_skinset19_mat.horzinefe_hz12.HorzineFE_HZ12_3P_BattleScarred_MIC", MIC_Pickup="wep_skinset19_mat.horzinefe_hz12.HorzineFE_HZ12_3P_Pickup_MIC"))

//Horzine First Encounter Kriss SMG
    Skins.Add((Id=6137, Weapondef=class'KFWeapDef_Kriss', MIC_1P=("wep_skinset19_mat.horzinefe_kriss.HorzineFE_Kriss_1P_Mint_MIC", "wep_skinset19_mat.horzinefe_kriss.HorzineFE_KRISS_Sight_1P_Mint_MIC"), MIC_3P="wep_skinset19_mat.horzinefe_kriss.HorzineFE_Kriss_3P_Mint_MIC", MIC_Pickup="wep_skinset19_mat.horzinefe_kriss.HorzineFE_Kriss_3P_Pickup_MIC"))
    Skins.Add((Id=6136, Weapondef=class'KFWeapDef_Kriss', MIC_1P=("wep_skinset19_mat.horzinefe_kriss.HorzineFE_Kriss_1P_FieldTested_MIC", "wep_skinset19_mat.horzinefe_kriss.HorzineFE_KRISS_Sight_1P_Mint_MIC"), MIC_3P="wep_skinset19_mat.horzinefe_kriss.HorzineFE_Kriss_3P_FieldTested_MIC", MIC_Pickup="wep_skinset19_mat.horzinefe_kriss.HorzineFE_Kriss_3P_Pickup_MIC"))
    Skins.Add((Id=6135, Weapondef=class'KFWeapDef_Kriss', MIC_1P=("wep_skinset19_mat.horzinefe_kriss.HorzineFE_Kriss_1P_BattleScarred_MIC", "wep_skinset19_mat.horzinefe_kriss.HorzineFE_KRISS_Sight_1P_Mint_MIC"), MIC_3P="wep_skinset19_mat.horzinefe_kriss.HorzineFE_Kriss_3P_BattleScarred_MIC", MIC_Pickup="wep_skinset19_mat.horzinefe_kriss.HorzineFE_Kriss_3P_Pickup_MIC"))

//Horzine First Encounter M14EBR
    Skins.Add((Id=6143, Weapondef=class'KFWeapDef_M14EBR', MIC_1P=("wep_skinset19_mat.horzinefe_m14ebr.HorzineFE_M14EBR_1P_Mint_MIC", "wep_skinset19_mat.horzinefe_m14ebr.HorzineFE_M14EBR_Scope_1P_Mint_MIC"), MIC_3P="wep_skinset19_mat.horzinefe_m14ebr.HorzineFE_M14EBR_3P_Mint_MIC", MIC_Pickup="wep_skinset19_mat.horzinefe_m14ebr.HorzineFE_M14EBR_3P_Pickup_MIC"))
    Skins.Add((Id=6142, Weapondef=class'KFWeapDef_M14EBR', MIC_1P=("wep_skinset19_mat.horzinefe_m14ebr.HorzineFE_M14EBR_1P_FieldTested_MIC", "wep_skinset19_mat.horzinefe_m14ebr.HorzineFE_M14EBR_Scope_1P_Mint_MIC"), MIC_3P="wep_skinset19_mat.horzinefe_m14ebr.HorzineFE_M14EBR_3P_FieldTested_MIC", MIC_Pickup="wep_skinset19_mat.horzinefe_m14ebr.HorzineFE_M14EBR_3P_Pickup_MIC"))
    Skins.Add((Id=6141, Weapondef=class'KFWeapDef_M14EBR', MIC_1P=("wep_skinset19_mat.horzinefe_m14ebr.HorzineFE_M14EBR_1P_BattleScarred_MIC", "wep_skinset19_mat.horzinefe_m14ebr.HorzineFE_M14EBR_Scope_1P_Mint_MIC"), MIC_3P="wep_skinset19_mat.horzinefe_m14ebr.HorzineFE_M14EBR_3P_BattleScarred_MIC", MIC_Pickup="wep_skinset19_mat.horzinefe_m14ebr.HorzineFE_M14EBR_3P_Pickup_MIC"))

//Horzine First Encounter M79
    Skins.Add((Id=6146, Weapondef=class'KFWeapDef_M79', MIC_1P=("wep_skinset19_mat.horzinefe_m79.HorzineFE_M79_1P_Mint_MIC"), MIC_3P="wep_skinset19_mat.horzinefe_m79.HorzineFE_M79_3P_Mint_MIC", MIC_Pickup="wep_skinset19_mat.horzinefe_m79.HorzineFE_M79_3P_Pickup_MIC"))
    Skins.Add((Id=6145, Weapondef=class'KFWeapDef_M79', MIC_1P=("wep_skinset19_mat.horzinefe_m79.HorzineFE_M79_1P_FieldTested_MIC"), MIC_3P="wep_skinset19_mat.horzinefe_m79.HorzineFE_M79_3P_FieldTested_MIC", MIC_Pickup="wep_skinset19_mat.horzinefe_m79.HorzineFE_M79_3P_Pickup_MIC"))
    Skins.Add((Id=6144, Weapondef=class'KFWeapDef_M79', MIC_1P=("wep_skinset19_mat.horzinefe_m79.HorzineFE_M79_1P_BattleScarred_MIC"), MIC_3P="wep_skinset19_mat.horzinefe_m79.HorzineFE_M79_3P_BattleScarred_MIC", MIC_Pickup="wep_skinset19_mat.horzinefe_m79.HorzineFE_M79_3P_Pickup_MIC"))

//Horzine First Encounter MAC 10
    Skins.Add((Id=6149, Weapondef=class'KFWeapDef_Mac10', MIC_1P=("wep_skinset19_mat.horzinefe_mac10.HorzineFE_MAC10_1P_Mint_MIC"), MIC_3P="wep_skinset19_mat.horzinefe_mac10.HorzineFE_MAC10_3P_Mint_MIC", MIC_Pickup="wep_skinset19_mat.horzinefe_mac10.HorzineFE_MAC10_3P_Pickup_MIC"))
    Skins.Add((Id=6148, Weapondef=class'KFWeapDef_Mac10', MIC_1P=("wep_skinset19_mat.horzinefe_mac10.HorzineFE_MAC10_1P_FieldTested_MIC"), MIC_3P="wep_skinset19_mat.horzinefe_mac10.HorzineFE_MAC10_3P_FieldTested_MIC", MIC_Pickup="wep_skinset19_mat.horzinefe_mac10.HorzineFE_MAC10_3P_Pickup_MIC"))
    Skins.Add((Id=6147, Weapondef=class'KFWeapDef_Mac10', MIC_1P=("wep_skinset19_mat.horzinefe_mac10.HorzineFE_MAC10_1P_BattleScarred_MIC"), MIC_3P="wep_skinset19_mat.horzinefe_mac10.HorzineFE_MAC10_3P_BattleScarred_MIC", MIC_Pickup="wep_skinset19_mat.horzinefe_mac10.HorzineFE_MAC10_3P_Pickup_MIC"))

//Horzine First Encounter MP5RAS
    Skins.Add((Id=6152, Weapondef=class'KFWeapDef_MP5RAS', MIC_1P=("WEP_SkinSet19_MAT.horzinefe_mp5ras.HorzineFE_MP5RAS_1P_Mint_MIC"), MIC_3P="WEP_SkinSet19_MAT.horzinefe_mp5ras.HorzineFE_MP5RAS_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet19_MAT.horzinefe_mp5ras.HorzineFE_MP5RAS_3P_Pickup_MIC"))
    Skins.Add((Id=6151, Weapondef=class'KFWeapDef_MP5RAS', MIC_1P=("WEP_SkinSet19_MAT.horzinefe_mp5ras.HorzineFE_MP5RAS_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet19_MAT.horzinefe_mp5ras.HorzineFE_MP5RAS_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet19_MAT.horzinefe_mp5ras.HorzineFE_MP5RAS_3P_Pickup_MIC"))
    Skins.Add((Id=6150, Weapondef=class'KFWeapDef_MP5RAS', MIC_1P=("WEP_SkinSet19_MAT.horzinefe_mp5ras.HorzineFE_MP5RAS_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet19_MAT.horzinefe_mp5ras.HorzineFE_MP5RAS_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet19_MAT.horzinefe_mp5ras.HorzineFE_MP5RAS_3P_Pickup_MIC"))

//Horzine First Encounter RPG-7
    Skins.Add((Id=6155, Weapondef=class'KFWeapDef_RPG7', MIC_1P=("wep_skinset19_mat.horzinefe_rpg7.HorzineFE_RPG7_1P_Mint_MIC"), MIC_3P="wep_skinset19_mat.horzinefe_rpg7.HorzineFE_RPG7_3P_Mint_MIC", MIC_Pickup="wep_skinset19_mat.horzinefe_rpg7.HorzineFE_RPG7_3P_Pickup_MIC"))
    Skins.Add((Id=6154, Weapondef=class'KFWeapDef_RPG7', MIC_1P=("wep_skinset19_mat.horzinefe_rpg7.HorzineFE_RPG7_1P_FieldTested_MIC"), MIC_3P="wep_skinset19_mat.horzinefe_rpg7.HorzineFE_RPG7_3P_FieldTested_MIC", MIC_Pickup="wep_skinset19_mat.horzinefe_rpg7.HorzineFE_RPG7_3P_Pickup_MIC"))
    Skins.Add((Id=6153, Weapondef=class'KFWeapDef_RPG7', MIC_1P=("wep_skinset19_mat.horzinefe_rpg7.HorzineFE_RPG7_1P_BattleScarred_MIC"), MIC_3P="wep_skinset19_mat.horzinefe_rpg7.HorzineFE_RPG7_3P_BattleScarred_MIC", MIC_Pickup="wep_skinset19_mat.horzinefe_rpg7.HorzineFE_RPG7_3P_Pickup_MIC"))

//Horzine First Encounter Scar
    Skins.Add((Id=6158, Weapondef=class'KFWeapDef_Scar', MIC_1P=("wep_skinset19_mat.horzinefe_scar.HorzineFE_SCAR_1P_Mint_MIC", "wep_skinset19_mat.horzinefe_scar.HorzineFE_SCAR_Scope_1P_Mint_MIC"), MIC_3P="wep_skinset19_mat.horzinefe_scar.HorzineFE_SCAR_3P_Mint_MIC", MIC_Pickup="wep_skinset19_mat.horzinefe_scar.HorzineFE_SCAR_3P_Pickup_MIC"))
    Skins.Add((Id=6157, Weapondef=class'KFWeapDef_Scar', MIC_1P=("wep_skinset19_mat.horzinefe_scar.HorzineFE_SCAR_1P_FieldTested_MIC", "wep_skinset19_mat.horzinefe_scar.HorzineFE_SCAR_Scope_1P_Mint_MIC"), MIC_3P="wep_skinset19_mat.horzinefe_scar.HorzineFE_SCAR_3P_FieldTested_MIC", MIC_Pickup="wep_skinset19_mat.horzinefe_scar.HorzineFE_SCAR_3P_Pickup_MIC"))
    Skins.Add((Id=6156, Weapondef=class'KFWeapDef_Scar', MIC_1P=("wep_skinset19_mat.horzinefe_scar.HorzineFE_SCAR_1P_BattleScarred_MIC", "wep_skinset19_mat.horzinefe_scar.HorzineFE_SCAR_Scope_1P_Mint_MIC"), MIC_3P="wep_skinset19_mat.horzinefe_scar.HorzineFE_SCAR_3P_BattleScarred_MIC", MIC_Pickup="wep_skinset19_mat.horzinefe_scar.HorzineFE_SCAR_3P_Pickup_MIC"))

//Horzine First Encounter Heckler & Koch UMP
    Skins.Add((Id=6161, Weapondef=class'KFWeapDef_HK_UMP', MIC_1P=("wep_skinset19_mat.horzinefe_hk_ump.HorzineFE_HK_UMP_1P_Mint_MIC", "wep_skinset19_mat.horzinefe_hk_ump.HorzineFE_HK_UMP_Sight_1P_Mint_MIC"), MIC_3P="wep_skinset19_mat.horzinefe_hk_ump.HorzineFE_HK_UMP_3P_Mint_MIC", MIC_Pickup="wep_skinset19_mat.horzinefe_hk_ump.HorzineFE_HK_UMP_3P_Pickup_MIC"))
    Skins.Add((Id=6160, Weapondef=class'KFWeapDef_HK_UMP', MIC_1P=("wep_skinset19_mat.horzinefe_hk_ump.HorzineFE_HK_UMP_1P_FieldTested_MIC", "wep_skinset19_mat.horzinefe_hk_ump.HorzineFE_HK_UMP_Sight_1P_Mint_MIC"), MIC_3P="wep_skinset19_mat.horzinefe_hk_ump.HorzineFE_HK_UMP_3P_FieldTested_MIC", MIC_Pickup="wep_skinset19_mat.horzinefe_hk_ump.HorzineFE_HK_UMP_3P_Pickup_MIC"))
    Skins.Add((Id=6159, Weapondef=class'KFWeapDef_HK_UMP', MIC_1P=("wep_skinset19_mat.horzinefe_hk_ump.HorzineFE_HK_UMP_1P_BattleScarred_MIC", "wep_skinset19_mat.horzinefe_hk_ump.HorzineFE_HK_UMP_Sight_1P_Mint_MIC"), MIC_3P="wep_skinset19_mat.horzinefe_hk_ump.HorzineFE_HK_UMP_3P_BattleScarred_MIC", MIC_Pickup="wep_skinset19_mat.horzinefe_hk_ump.HorzineFE_HK_UMP_3P_Pickup_MIC"))

//Horzine Elite Black HMTech-101 Pistol
    Skins.Add((Id=6164, Weapondef=class'KFWeapDef_MedicPistol', MIC_1P=("WEP_SkinSet18_MAT.horzineeliteblack_medicassault.HorzineEliteBlack_MedicPistol_1P_Mint_MIC"), MIC_3P="WEP_SkinSet18_MAT.horzineeliteblack_medicassault.HorzineEliteBlack_MedicPistol_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet18_MAT.horzineeliteblack_medicassault.HorzineEliteBlack_MedicPistol_3P_Pickup_MIC"))
    Skins.Add((Id=6163, Weapondef=class'KFWeapDef_MedicPistol', MIC_1P=("WEP_SkinSet18_MAT.horzineeliteblack_medicassault.HorzineEliteBlack_MedicPistol_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet18_MAT.horzineeliteblack_medicassault.HorzineEliteBlack_MedicPistol_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet18_MAT.horzineeliteblack_medicassault.HorzineEliteBlack_MedicPistol_3P_Pickup_MIC"))
    Skins.Add((Id=6162, Weapondef=class'KFWeapDef_MedicPistol', MIC_1P=("WEP_SkinSet18_MAT.horzineeliteblack_medicassault.HorzineEliteBlack_MedicPistol_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet18_MAT.horzineeliteblack_medicassault.HorzineEliteBlack_MedicPistol_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet18_MAT.horzineeliteblack_medicassault.HorzineEliteBlack_MedicPistol_3P_Pickup_MIC"))

//Horzine Elite Blue HMTech-101 Pistol
    Skins.Add((Id=6167, Weapondef=class'KFWeapDef_MedicPistol', MIC_1P=("WEP_SkinSet18_MAT.horzineeliteblue_medicassault.HorzineEliteBlue_MedicPistol_1P_Mint_MIC"), MIC_3P="WEP_SkinSet18_MAT.horzineeliteblue_medicassault.HorzineEliteBlue_MedicPistol_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet18_MAT.horzineeliteblue_medicassault.HorzineEliteBlue_MedicPistol_3P_Pickup_MIC"))
    Skins.Add((Id=6166, Weapondef=class'KFWeapDef_MedicPistol', MIC_1P=("WEP_SkinSet18_MAT.horzineeliteblue_medicassault.HorzineEliteBlue_MedicPistol_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet18_MAT.horzineeliteblue_medicassault.HorzineEliteBlue_MedicPistol_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet18_MAT.horzineeliteblue_medicassault.HorzineEliteBlue_MedicPistol_3P_Pickup_MIC"))
    Skins.Add((Id=6165, Weapondef=class'KFWeapDef_MedicPistol', MIC_1P=("WEP_SkinSet18_MAT.horzineeliteblue_medicassault.HorzineEliteBlue_MedicPistol_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet18_MAT.horzineeliteblue_medicassault.HorzineEliteBlue_MedicPistol_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet18_MAT.horzineeliteblue_medicassault.HorzineEliteBlue_MedicPistol_3P_Pickup_MIC"))

//Horzine Elite Green HMTech-101 Pistol
    Skins.Add((Id=6170, Weapondef=class'KFWeapDef_MedicPistol', MIC_1P=("WEP_SkinSet18_MAT.horzineelitegreen_medicassault.HorzineEliteGreen_MedicPistol_1P_Mint_MIC"), MIC_3P="WEP_SkinSet18_MAT.horzineelitegreen_medicassault.HorzineEliteGreen_MedicPistol_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet18_MAT.horzineelitegreen_medicassault.HorzineEliteGreen_MedicPistol_3P_Pickup_MIC"))
    Skins.Add((Id=6169, Weapondef=class'KFWeapDef_MedicPistol', MIC_1P=("WEP_SkinSet18_MAT.horzineelitegreen_medicassault.HorzineEliteGreen_MedicPistol_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet18_MAT.horzineelitegreen_medicassault.HorzineEliteGreen_MedicPistol_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet18_MAT.horzineelitegreen_medicassault.HorzineEliteGreen_MedicPistol_3P_Pickup_MIC"))
    Skins.Add((Id=6168, Weapondef=class'KFWeapDef_MedicPistol', MIC_1P=("WEP_SkinSet18_MAT.horzineelitegreen_medicassault.HorzineEliteGreen_MedicPistol_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet18_MAT.horzineelitegreen_medicassault.HorzineEliteGreen_MedicPistol_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet18_MAT.horzineelitegreen_medicassault.HorzineEliteGreen_MedicPistol_3P_Pickup_MIC"))

//Horzine Elite Red HMTech-101 Pistol
    Skins.Add((Id=6173, Weapondef=class'KFWeapDef_MedicPistol', MIC_1P=("WEP_SkinSet18_MAT.horzineelitered_medicassault.HorzineEliteRed_MedicPistol_1P_Mint_MIC"), MIC_3P="WEP_SkinSet18_MAT.horzineelitered_medicassault.HorzineEliteRed_MedicPistol_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet18_MAT.horzineelitered_medicassault.HorzineEliteRed_MedicPistol_3P_Pickup_MIC"))
    Skins.Add((Id=6172, Weapondef=class'KFWeapDef_MedicPistol', MIC_1P=("WEP_SkinSet18_MAT.horzineelitered_medicassault.HorzineEliteRed_MedicPistol_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet18_MAT.horzineelitered_medicassault.HorzineEliteRed_MedicPistol_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet18_MAT.horzineelitered_medicassault.HorzineEliteRed_MedicPistol_3P_Pickup_MIC"))
    Skins.Add((Id=6171, Weapondef=class'KFWeapDef_MedicPistol', MIC_1P=("WEP_SkinSet18_MAT.horzineelitered_medicassault.HorzineEliteRed_MedicPistol_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet18_MAT.horzineelitered_medicassault.HorzineEliteRed_MedicPistol_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet18_MAT.horzineelitered_medicassault.HorzineEliteRed_MedicPistol_3P_Pickup_MIC"))

//Horzine Elite White HMTech-101 Pistol
    Skins.Add((Id=6176, Weapondef=class'KFWeapDef_MedicPistol', MIC_1P=("WEP_SkinSet18_MAT.horzineelitewhite_medicassault.HorzineEliteWhite_MedicPistol_1P_Mint_MIC"), MIC_3P="WEP_SkinSet18_MAT.horzineelitewhite_medicassault.HorzineEliteWhite_MedicPistol_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet18_MAT.horzineelitewhite_medicassault.HorzineEliteWhite_MedicPistol_3P_Pickup_MIC"))
    Skins.Add((Id=6175, Weapondef=class'KFWeapDef_MedicPistol', MIC_1P=("WEP_SkinSet18_MAT.horzineelitewhite_medicassault.HorzineEliteWhite_MedicPistol_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet18_MAT.horzineelitewhite_medicassault.HorzineEliteWhite_MedicPistol_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet18_MAT.horzineelitewhite_medicassault.HorzineEliteWhite_MedicPistol_3P_Pickup_MIC"))
    Skins.Add((Id=6174, Weapondef=class'KFWeapDef_MedicPistol', MIC_1P=("WEP_SkinSet18_MAT.horzineelitewhite_medicassault.HorzineEliteWhite_MedicPistol_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet18_MAT.horzineelitewhite_medicassault.HorzineEliteWhite_MedicPistol_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet18_MAT.horzineelitewhite_medicassault.HorzineEliteWhite_MedicPistol_3P_Pickup_MIC"))

//Precious Centerfire
	Skins.Add((Id=6220, Weapondef=class'KFWeapDef_CenterfireMB464', MIC_1P=("WEP_SkinSet19_MAT.precious_centerfire.Precious_Centerfire_1P_Mint_MIC"), MIC_3P="WEP_SkinSet19_MAT.precious_centerfire.Precious_Centerfire_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet19_MAT.precious_centerfire.Precious_Centerfire_3P_Pickup_MIC"))

//Prestige 1858 Revolver
    Skins.Add((Id=6288, Weapondef=class'KFWeapDef_Remington1858', MIC_1P=("WEP_SkinSet_Prestige02_MAT.tier01.Prestige_Gunslinger_Remington1858_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_Prestige02_MAT.tier01.Prestige_Gunslinger_Remington1858_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_Prestige02_MAT.tier01.Prestige_Gunslinger_Remington1858_3P_Pickup_MIC"))

//Prestige AR15
    Skins.Add((Id=6285, Weapondef=class'KFWeapDef_AR15', MIC_1P=("WEP_SkinSet_Prestige02_MAT.tier01.Prestige_Commando_AR15_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_Prestige02_MAT.tier01.Prestige_Commando_AR15_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_Prestige02_MAT.tier01.Prestige_Commando_AR15_3P_Pickup_MIC"))

//Prestige Caulk n Burn
    Skins.Add((Id=6287, Weapondef=class'KFWeapDef_CaulkBurn', MIC_1P=("WEP_SkinSet_Prestige02_MAT.tier01.Prestige_Firebug_CaulkNBurn_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_Prestige02_MAT.tier01.Prestige_Firebug_CaulkNBurn_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_Prestige02_MAT.tier01.Prestige_Firebug_CaulkNBurn_3P_Pickup_MIC"))

//Prestige Crovel
    Skins.Add((Id=6284, Weapondef=class'KFWeapDef_Crovel', MIC_1P=("WEP_SkinSet_Prestige02_MAT.tier01.Prestige_Berserker_Crovel_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_Prestige02_MAT.tier01.Prestige_Berserker_Crovel_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_Prestige02_MAT.tier01.Prestige_Berserker_Crovel_3P_Pickup_MIC"))

//Prestige Freeze Thrower
    Skins.Add((Id=6293, Weapondef=class'KFWeapDef_FreezeThrower', MIC_1P=("WEP_SkinSet_Prestige02_MAT.tier01.Prestige_Survivalist_CryoGun_ID1_1P_Mint_MIC", "WEP_SkinSet_Prestige02_MAT.tier01.Prestige_Survivalist_CryoGun_ID2_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_Prestige02_MAT.tier01.Prestige_Survivalist_CryoGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_Prestige02_MAT.tier01.Prestige_Survivalist_CryoGun_3P_Pickup_MIC"))

//Prestige HMTech-101 Pistol
    Skins.Add((Id=6289, Weapondef=class'KFWeapDef_MedicPistol', MIC_1P=("WEP_SkinSet_Prestige02_MAT.tier01.Prestige_Medic_MedicPistol_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_Prestige02_MAT.tier01.Prestige_Medic_MedicPistol_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_Prestige02_MAT.tier01.Prestige_Medic_MedicPistol_3P_Pickup_MIC"))

//Prestige HX25
    Skins.Add((Id=6286, Weapondef=class'KFWeapDef_HX25', MIC_1P=("WEP_SkinSet_Prestige02_MAT.tier01.Prestige_Demo_HX25_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_Prestige02_MAT.tier01.Prestige_Demo_HX25_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_Prestige02_MAT.tier01.Prestige_Demo_HX25_3P_Pickup_MIC"))

//Prestige MP7
    Skins.Add((Id=6292, Weapondef=class'KFWeapDef_MP7', MIC_1P=("WEP_SkinSet_Prestige02_MAT.tier01.Prestige_SWAT_MP7_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_Prestige02_MAT.tier01.Prestige_SWAT_MP7_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_Prestige02_MAT.tier01.Prestige_SWAT_MP7_3P_Pickup_MIC"))

//Prestige SG 500
    Skins.Add((Id=6291, Weapondef=class'KFWeapDef_MB500', MIC_1P=("WEP_SkinSet_Prestige02_MAT.tier01.Prestige_Support_MB500_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_Prestige02_MAT.tier01.Prestige_Support_MB500_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_Prestige02_MAT.tier01.Prestige_Support_MB500_3P_Pickup_MIC"))

//Prestige Winchester 1894
    Skins.Add((Id=6290, Weapondef=class'KFWeapDef_Winchester1894', MIC_1P=("WEP_SkinSet_Prestige02_MAT.tier01.Prestige_Sharpshooter_Winchester1894_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_Prestige02_MAT.tier01.Prestige_Sharpshooter_Winchester1894_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_Prestige02_MAT.tier01.Prestige_Sharpshooter_Winchester1894_3P_Pickup_MIC"))

//Neon 9MM
    Skins.Add((Id=6296, Weapondef=class'KFWeapDef_9mm', MIC_1P=("WEP_SkinSet21_MAT.neon_9mm.Neon_9MM_1P_Mint_MIC"), MIC_3P="WEP_SkinSet21_MAT.neon_9mm.Neon_9MM_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet21_MAT.neon_9mm.Neon_9MM_3P_Pickup_MIC"))
    Skins.Add((Id=6295, Weapondef=class'KFWeapDef_9mm', MIC_1P=("WEP_SkinSet21_MAT.neon_9mm.Neon_9MM_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet21_MAT.neon_9mm.Neon_9MM_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet21_MAT.neon_9mm.Neon_9MM_3P_Pickup_MIC"))
    Skins.Add((Id=6294, Weapondef=class'KFWeapDef_9mm', MIC_1P=("WEP_SkinSet21_MAT.neon_9mm.Neon_9MM_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet21_MAT.neon_9mm.Neon_9MM_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet21_MAT.neon_9mm.Neon_9MM_3P_Pickup_MIC"))

//Neon AF2011-A1
    Skins.Add((Id=6299, Weapondef=class'KFWeapDef_AF2011', MIC_1P=("WEP_SkinSet21_MAT.neon_af2011.Neon_AF2011_1P_Mint_MIC"), MIC_3P="WEP_SkinSet21_MAT.neon_af2011.Neon_AF2011_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet21_MAT.neon_af2011.Neon_AF2011_3P_Pickup_MIC"))
    Skins.Add((Id=6298, Weapondef=class'KFWeapDef_AF2011', MIC_1P=("WEP_SkinSet21_MAT.neon_af2011.Neon_AF2011_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet21_MAT.neon_af2011.Neon_AF2011_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet21_MAT.neon_af2011.Neon_AF2011_3P_Pickup_MIC"))
    Skins.Add((Id=6297, Weapondef=class'KFWeapDef_AF2011', MIC_1P=("WEP_SkinSet21_MAT.neon_af2011.Neon_AF2011_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet21_MAT.neon_af2011.Neon_AF2011_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet21_MAT.neon_af2011.Neon_AF2011_3P_Pickup_MIC"))

//Neon AK12
    Skins.Add((Id=6302, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet21_MAT.neon_ak12.Neon_AK12_1P_Mint_MIC", "WEP_SkinSet21_MAT.neon_ak12.Neon_AK12_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet21_MAT.neon_ak12.Neon_AK12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet21_MAT.neon_ak12.Neon_AK12_3P_Pickup_MIC"))
    Skins.Add((Id=6301, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet21_MAT.neon_ak12.Neon_AK12_1P_FieldTested_MIC", "WEP_SkinSet21_MAT.neon_ak12.Neon_AK12_Sight_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet21_MAT.neon_ak12.Neon_AK12_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet21_MAT.neon_ak12.Neon_AK12_3P_Pickup_MIC"))
    Skins.Add((Id=6300, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet21_MAT.neon_ak12.Neon_AK12_1P_BattleScarred_MIC", "WEP_SkinSet21_MAT.neon_ak12.Neon_AK12_Sight_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet21_MAT.neon_ak12.Neon_AK12_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet21_MAT.neon_ak12.Neon_AK12_3P_Pickup_MIC"))

//Neon Centerfire
    Skins.Add((Id=6305, Weapondef=class'KFWeapDef_CenterfireMB464', MIC_1P=("WEP_SkinSet21_MAT.neon_centerfire.Neon_Centerfire_1P_Mint_MIC"), MIC_3P="WEP_SkinSet21_MAT.neon_centerfire.Neon_Centerfire_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet21_MAT.neon_centerfire.Neon_Centerfire_3P_Pickup_MIC"))
    Skins.Add((Id=6304, Weapondef=class'KFWeapDef_CenterfireMB464', MIC_1P=("WEP_SkinSet21_MAT.neon_centerfire.Neon_Centerfire_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet21_MAT.neon_centerfire.Neon_Centerfire_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet21_MAT.neon_centerfire.Neon_Centerfire_3P_Pickup_MIC"))
    Skins.Add((Id=6303, Weapondef=class'KFWeapDef_CenterfireMB464', MIC_1P=("WEP_SkinSet21_MAT.neon_centerfire.Neon_Centerfire_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet21_MAT.neon_centerfire.Neon_Centerfire_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet21_MAT.neon_centerfire.Neon_Centerfire_3P_Pickup_MIC"))

//Neon Doomstick
    Skins.Add((Id=6308, Weapondef=class'KFWeapDef_ElephantGun', MIC_1P=("WEP_SkinSet21_MAT.neon_quadbarrel.Neon_QuadBarrel_Main_1P_Mint_MIC", "WEP_SkinSet21_MAT.neon_quadbarrel.Neon_QuadBarrel_Barrel_1P_Mint_MIC"), MIC_3P="WEP_SkinSet21_MAT.neon_quadbarrel.Neon_QuadBarrel_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet21_MAT.neon_quadbarrel.Neon_QuadBarrel_3P_Pickup_MIC"))
    Skins.Add((Id=6307, Weapondef=class'KFWeapDef_ElephantGun', MIC_1P=("WEP_SkinSet21_MAT.neon_quadbarrel.Neon_QuadBarrel_Main_1P_FieldTested_MIC", "WEP_SkinSet21_MAT.neon_quadbarrel.Neon_QuadBarrel_Barrel_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet21_MAT.neon_quadbarrel.Neon_QuadBarrel_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet21_MAT.neon_quadbarrel.Neon_QuadBarrel_3P_Pickup_MIC"))
    Skins.Add((Id=6306, Weapondef=class'KFWeapDef_ElephantGun', MIC_1P=("WEP_SkinSet21_MAT.neon_quadbarrel.Neon_QuadBarrel_Main_1P_BattleScarred_MIC", "WEP_SkinSet21_MAT.neon_quadbarrel.Neon_QuadBarrel_Barrel_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet21_MAT.neon_quadbarrel.Neon_QuadBarrel_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet21_MAT.neon_quadbarrel.Neon_QuadBarrel_3P_Pickup_MIC"))

//Neon Husk Cannon
    Skins.Add((Id=6311, Weapondef=class'KFWeapDef_HuskCannon', MIC_1P=("WEP_SkinSet21_MAT.neon_huskcannon.Neon_HuskCannon_1P_Mint_MIC", "WEP_SkinSet21_MAT.neon_huskcannon.Neon_HuskCannon_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet21_MAT.neon_huskcannon.Neon_HuskCannon_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet21_MAT.neon_huskcannon.Neon_HuskCannon_3P_Pickup_MIC"))
    Skins.Add((Id=6310, Weapondef=class'KFWeapDef_HuskCannon', MIC_1P=("WEP_SkinSet21_MAT.neon_huskcannon.Neon_HuskCannon_1P_FieldTested_MIC", "WEP_SkinSet21_MAT.neon_huskcannon.Neon_HuskCannon_Sight_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet21_MAT.neon_huskcannon.Neon_HuskCannon_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet21_MAT.neon_huskcannon.Neon_HuskCannon_3P_Pickup_MIC"))
    Skins.Add((Id=6309, Weapondef=class'KFWeapDef_HuskCannon', MIC_1P=("WEP_SkinSet21_MAT.neon_huskcannon.Neon_HuskCannon_1P_BattleScarred_MIC", "WEP_SkinSet21_MAT.neon_huskcannon.Neon_HuskCannon_Sight_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet21_MAT.neon_huskcannon.Neon_HuskCannon_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet21_MAT.neon_huskcannon.Neon_HuskCannon_3P_Pickup_MIC"))

//Neon M16 M203
    Skins.Add((Id=6314, Weapondef=class'KFWeapDef_M16M203', MIC_1P=("WEP_SkinSet21_MAT.neon_m16m203.Neon_M16_1P_Mint_MIC", "WEP_SkinSet21_MAT.neon_m16m203.Neon_M203_1P_Mint_MIC"), MIC_3P="WEP_SkinSet21_MAT.neon_m16m203.Neon_M16_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet21_MAT.neon_m16m203.Neon_M16_3P_Pickup_MIC"))
    Skins.Add((Id=6313, Weapondef=class'KFWeapDef_M16M203', MIC_1P=("WEP_SkinSet21_MAT.neon_m16m203.Neon_M16_1P_FieldTested_MIC", "WEP_SkinSet21_MAT.neon_m16m203.Neon_M203_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet21_MAT.neon_m16m203.Neon_M16_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet21_MAT.neon_m16m203.Neon_M16_3P_Pickup_MIC"))
    Skins.Add((Id=6312, Weapondef=class'KFWeapDef_M16M203', MIC_1P=("WEP_SkinSet21_MAT.neon_m16m203.Neon_M16_1P_BattleScarred_MIC", "WEP_SkinSet21_MAT.neon_m16m203.Neon_M203_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet21_MAT.neon_m16m203.Neon_M16_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet21_MAT.neon_m16m203.Neon_M16_3P_Pickup_MIC"))

//Neon M99
    Skins.Add((Id=6317, Weapondef=class'KFWeapDef_M99', MIC_1P=("WEP_SkinSet21_MAT.neon_m99.Neon_M99_1P_Mint_MIC", "WEP_SkinSet21_MAT.neon_m99.Neon_M99_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet21_MAT.neon_m99.Neon_M99_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet21_MAT.neon_m99.Neon_M99_3P_Pickup_MIC"))
    Skins.Add((Id=6316, Weapondef=class'KFWeapDef_M99', MIC_1P=("WEP_SkinSet21_MAT.neon_m99.Neon_M99_1P_FieldTested_MIC", "WEP_SkinSet21_MAT.neon_m99.Neon_M99_Scope_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet21_MAT.neon_m99.Neon_M99_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet21_MAT.neon_m99.Neon_M99_3P_Pickup_MIC"))
    Skins.Add((Id=6315, Weapondef=class'KFWeapDef_M99', MIC_1P=("WEP_SkinSet21_MAT.neon_m99.Neon_M99_1P_BattleScarred_MIC", "WEP_SkinSet21_MAT.neon_m99.Neon_M99_Scope_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet21_MAT.neon_m99.Neon_M99_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet21_MAT.neon_m99.Neon_M99_3P_Pickup_MIC"))

//Neon P90
    Skins.Add((Id=6320, Weapondef=class'KFWeapDef_P90', MIC_1P=("WEP_SkinSet21_MAT.neon_p90.Neon_P90_1P_Mint_MIC", "WEP_SkinSet21_MAT.neon_p90.Neon_P90_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet21_MAT.neon_p90.Neon_P90_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet21_MAT.neon_p90.Neon_P90_3P_Pickup_MIC"))
    Skins.Add((Id=6319, Weapondef=class'KFWeapDef_P90', MIC_1P=("WEP_SkinSet21_MAT.neon_p90.Neon_P90_1P_FieldTested_MIC", "WEP_SkinSet21_MAT.neon_p90.Neon_P90_Sight_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet21_MAT.neon_p90.Neon_P90_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet21_MAT.neon_p90.Neon_P90_3P_Pickup_MIC"))
    Skins.Add((Id=6318, Weapondef=class'KFWeapDef_P90', MIC_1P=("WEP_SkinSet21_MAT.neon_p90.Neon_P90_1P_BattleScarred_MIC", "WEP_SkinSet21_MAT.neon_p90.Neon_P90_Sight_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet21_MAT.neon_p90.Neon_P90_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet21_MAT.neon_p90.Neon_P90_3P_Pickup_MIC"))

//Neon Static Strikers
    Skins.Add((Id=6323, Weapondef=class'KFWeapDef_PowerGloves', MIC_1P=("WEP_SkinSet21_MAT.neon_staticstrikers.Neon_StaticStrikers_1P_Mint_MIC"), MIC_3P="WEP_SkinSet21_MAT.neon_staticstrikers.Neon_StaticStrikers_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet21_MAT.neon_staticstrikers.Neon_StaticStrikers_3P_Pickup_MIC"))
    Skins.Add((Id=6322, Weapondef=class'KFWeapDef_PowerGloves', MIC_1P=("WEP_SkinSet21_MAT.neon_staticstrikers.Neon_StaticStrikers_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet21_MAT.neon_staticstrikers.Neon_StaticStrikers_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet21_MAT.neon_staticstrikers.Neon_StaticStrikers_3P_Pickup_MIC"))
    Skins.Add((Id=6321, Weapondef=class'KFWeapDef_PowerGloves', MIC_1P=("WEP_SkinSet21_MAT.neon_staticstrikers.Neon_StaticStrikers_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet21_MAT.neon_staticstrikers.Neon_StaticStrikers_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet21_MAT.neon_staticstrikers.Neon_StaticStrikers_3P_Pickup_MIC"))

//Neon RGB 9MM
    Skins.Add((Id=6324, Weapondef=class'KFWeapDef_9mm', MIC_1P=("WEP_SkinSet21_MAT.neonrgb_9mm.NeonRGB_9MM_1P_Mint_MIC"), MIC_3P="WEP_SkinSet21_MAT.neonrgb_9mm.NeonRGB_9MM_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet21_MAT.neonrgb_9mm.NeonRGB_9MM_3P_Pickup_MIC"))

//Neon RGB AF2011-A1
    Skins.Add((Id=6325, Weapondef=class'KFWeapDef_AF2011', MIC_1P=("WEP_SkinSet21_MAT.neonrgb_af2011.NeonRGB_AF2011_1P_Mint_MIC"), MIC_3P="WEP_SkinSet21_MAT.neonrgb_af2011.NeonRGB_AF2011_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet21_MAT.neonrgb_af2011.NeonRGB_AF2011_3P_Pickup_MIC"))

//Neon RGB AK12
    Skins.Add((Id=6326, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet21_MAT.neonrgb_ak12.NeonRGB_AK12_1P_Mint_MIC", "WEP_SkinSet21_MAT.neonrgb_ak12.NeonRGB_AK12_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet21_MAT.neonrgb_ak12.NeonRGB_AK12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet21_MAT.neonrgb_ak12.NeonRGB_AK12_3P_Pickup_MIC"))

//Neon RGB Centerfire
    Skins.Add((Id=6327, Weapondef=class'KFWeapDef_CenterfireMB464', MIC_1P=("WEP_SkinSet21_MAT.neonrgb_centerfire.NeonRGB_Centerfire_1P_Mint_MIC"), MIC_3P="WEP_SkinSet21_MAT.neonrgb_centerfire.NeonRGB_Centerfire_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet21_MAT.neonrgb_centerfire.NeonRGB_Centerfire_3P_Pickup_MIC"))

//Neon RGB Doomstick
    Skins.Add((Id=6328, Weapondef=class'KFWeapDef_ElephantGun', MIC_1P=("WEP_SkinSet21_MAT.neonrgb_quadbarrel.NeonRGB_QuadBarrel_Main_1P_Mint_MIC", "WEP_SkinSet21_MAT.neonrgb_quadbarrel.NeonRGB_QuadBarrel_Barrel_1P_Mint_MIC"), MIC_3P="WEP_SkinSet21_MAT.neonrgb_quadbarrel.NeonRGB_QuadBarrel_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet21_MAT.neonrgb_quadbarrel.NeonRGB_QuadBarrel_3P_Pickup_MIC"))

//Neon RGB Husk Cannon
    Skins.Add((Id=6329, Weapondef=class'KFWeapDef_HuskCannon', MIC_1P=("WEP_SkinSet21_MAT.neonrgb_huskcannon.NeonRGB_HuskCannon_1P_Mint_MIC", "WEP_SkinSet21_MAT.neonrgb_huskcannon.NeonRGB_HuskCannon_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet21_MAT.neonrgb_huskcannon.NeonRGB_HuskCannon_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet21_MAT.neonrgb_huskcannon.NeonRGB_HuskCannon_3P_Pickup_MIC"))

//Neon RGB M16 M203
    Skins.Add((Id=6330, Weapondef=class'KFWeapDef_M16M203', MIC_1P=("WEP_SkinSet21_MAT.neonrgb_m16m203.NeonRGB_M16_1P_Mint_MIC", "WEP_SkinSet21_MAT.neonrgb_m16m203.NeonRGB_M203_1P_Mint_MIC"), MIC_3P="WEP_SkinSet21_MAT.neonrgb_m16m203.NeonRGB_M16_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet21_MAT.neonrgb_m16m203.NeonRGB_M16_3P_Pickup_MIC"))

//Neon RGB M99
    Skins.Add((Id=6331, Weapondef=class'KFWeapDef_M99', MIC_1P=("WEP_SkinSet21_MAT.neonrgb_m99.NeonRGB_M99_1P_Mint_MIC", "WEP_SkinSet21_MAT.neonrgb_m99.NeonRGB_M99_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet21_MAT.neonrgb_m99.NeonRGB_M99_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet21_MAT.neonrgb_m99.NeonRGB_M99_3P_Pickup_MIC"))

//Neon RGB P90
    Skins.Add((Id=6332, Weapondef=class'KFWeapDef_P90', MIC_1P=("WEP_SkinSet21_MAT.neonrgb_p90.NeonRGB_P90_1P_Mint_MIC", "WEP_SkinSet21_MAT.neonrgb_p90.NeonRGB_P90_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet21_MAT.neonrgb_p90.NeonRGB_P90_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet21_MAT.neonrgb_p90.NeonRGB_P90_3P_Pickup_MIC"))

//Neon RGB Static Strikers
    Skins.Add((Id=6333, Weapondef=class'KFWeapDef_PowerGloves', MIC_1P=("WEP_SkinSet21_MAT.neonrgb_staticstrikers.NeonRGB_StaticStrikers_1P_Mint_MIC"), MIC_3P="WEP_SkinSet21_MAT.neonrgb_staticstrikers.NeonRGB_StaticStrikers_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet21_MAT.neonrgb_staticstrikers.NeonRGB_StaticStrikers_3P_Pickup_MIC"))

//Vault Vosh AK12
    Skins.Add((Id=6334, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet_VaultVosh04_MAT.vosh_ak12.Vault_Vosh_AK12_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh04_MAT.vosh_ak12.Vault_Vosh_AK12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh04_MAT.vosh_ak12.Vault_Vosh_AK12_3P_Pickup_MIC"))

//Vault Vosh Desert Eagle
    Skins.Add((Id=6335, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet_VaultVosh04_MAT.vosh_deagle.Vault_Vosh_Deagle_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh04_MAT.vosh_deagle.Vault_Vosh_Deagle_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh04_MAT.vosh_deagle.Vault_Vosh_Deagle_3P_Pickup_MIC"))

//Vault Vosh Flamethrower
    Skins.Add((Id=6336, Weapondef=class'KFWeapDef_FlameThrower', MIC_1P=("WEP_SkinSet_VaultVosh04_MAT.vosh_flamethrower.Vault_Vosh_Flamethrower_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh04_MAT.vosh_flamethrower.Vault_Vosh_Flamethrower_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh04_MAT.vosh_flamethrower.Vault_Vosh_Flamethrower_3P_Pickup_MIC"))

//Vault Vosh Freeze Thrower
    Skins.Add((Id=6337, Weapondef=class'KFWeapDef_FreezeThrower', MIC_1P=("WEP_SkinSet_VaultVosh04_MAT.vosh_cryogun.Vault_Vosh_Cryogun_ID1_1P_Mint_MIC", "WEP_SkinSet_VaultVosh04_MAT.vosh_cryogun.Vault_Vosh_Cryogun_ID2_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh04_MAT.vosh_cryogun.Vault_Vosh_Cryogun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh04_MAT.vosh_cryogun.Vault_Vosh_Cryogun_3P_Pickup_MIC"))

//Vault Vosh HMTech-301 Shotgun
    Skins.Add((Id=6338, Weapondef=class'KFWeapDef_MedicShotgun', MIC_1P=("WEP_SkinSet_VaultVosh02_MAT.vosh_medic_pistol.Vault_Vosh_Medic_Pistol_1P_Mint_MIC", "WEP_SkinSet_VaultVosh04_MAT.vosh_medicshotgun.Vault_Vosh_MedicShotgun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh04_MAT.vosh_medicshotgun.Vault_Vosh_MedicShotgun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh04_MAT.vosh_medicshotgun.Vault_Vosh_MedicShotgun_3P_Pickup_MIC"))

//Vault Vosh M14EBR
    Skins.Add((Id=6339, Weapondef=class'KFWeapDef_M14EBR', MIC_1P=("WEP_SkinSet_VaultVosh04_MAT.vosh_m14ebr.Vault_Vosh_M14EBR_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh04_MAT.vosh_m14ebr.Vault_Vosh_M14EBR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh04_MAT.vosh_m14ebr.Vault_Vosh_M14EBR_3P_Pickup_MIC"))

//Vault Vosh M4
    Skins.Add((Id=6340, Weapondef=class'KFWeapDef_M4', MIC_1P=("WEP_SkinSet_VaultVosh04_MAT.vosh_m4.Vault_Vosh_M4Shotgun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh04_MAT.vosh_m4.Vault_Vosh_M4Shotgun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh04_MAT.vosh_m4.Vault_Vosh_M4Shotgun_3P_Pickup_MIC"))

//Vault Vosh M79
    Skins.Add((Id=6341, Weapondef=class'KFWeapDef_M79', MIC_1P=("WEP_SkinSet_VaultVosh04_MAT.vosh_m79.Vault_Vosh_M79_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh04_MAT.vosh_m79.Vault_Vosh_M79_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh04_MAT.vosh_m79.Vault_Vosh_M79_3P_Pickup_MIC"))

//Vault Vosh P90
    Skins.Add((Id=6342, Weapondef=class'KFWeapDef_P90', MIC_1P=("WEP_SkinSet_VaultVosh04_MAT.vosh_p90.Vault_Vosh_P90_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh04_MAT.vosh_p90.Vault_Vosh_P90_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh04_MAT.vosh_p90.Vault_Vosh_P90_3P_Pickup_MIC"))

//Vault Vosh Pulverizer
    Skins.Add((Id=6343, Weapondef=class'KFWeapDef_Pulverizer', MIC_1P=("WEP_SkinSet_VaultVosh04_MAT.vosh_pulverizer.Vault_Vosh_Pulverizer_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh04_MAT.vosh_pulverizer.Vault_Vosh_Pulverizer_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh04_MAT.vosh_pulverizer.Vault_Vosh_Pulverizer_3P_Pickup_MIC"))

//Neon MAC 10
    Skins.Add((Id=6346, Weapondef=class'KFWeapDef_Mac10', MIC_1P=("WEP_SkinSet21_MAT.neon_mac10.Neon_MAC10_1P_Mint_MIC"), MIC_3P="WEP_SkinSet21_MAT.neon_mac10.Neon_MAC10_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet21_MAT.neon_mac10.Neon_MAC10_3P_Pickup_MIC"))
    Skins.Add((Id=6345, Weapondef=class'KFWeapDef_Mac10', MIC_1P=("WEP_SkinSet21_MAT.neon_mac10.Neon_MAC10_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet21_MAT.neon_mac10.Neon_MAC10_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet21_MAT.neon_mac10.Neon_MAC10_3P_Pickup_MIC"))
    Skins.Add((Id=6344, Weapondef=class'KFWeapDef_Mac10', MIC_1P=("WEP_SkinSet21_MAT.neon_mac10.Neon_MAC10_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet21_MAT.neon_mac10.Neon_MAC10_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet21_MAT.neon_mac10.Neon_MAC10_3P_Pickup_MIC"))

//Neon RGB MAC 10
    Skins.Add((Id=6347, Weapondef=class'KFWeapDef_Mac10', MIC_1P=("WEP_SkinSet21_MAT.neonrgb_mac10.NeonRGB_MAC10_1P_Mint_MIC"), MIC_3P="WEP_SkinSet21_MAT.neonrgb_mac10.NeonRGB_MAC10_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet21_MAT.neonrgb_mac10.NeonRGB_MAC10_3P_Pickup_MIC"))

//Halloween MKB42
    Skins.Add((Id=6456, Weapondef=class'KFWeapDef_MKB42', MIC_1P=("WEP_SkinSet_Halloween_MAT.hans_mkb42h.WEP_1P_Halloween_MKB42H_MIC"), MIC_3P="WEP_SkinSet_Halloween_MAT.hans_mkb42h.WEP_3P_Halloween_MKB42H_MIC", MIC_Pickup="WEP_SkinSet_Halloween_MAT.hans_mkb42h.WEP_3P_Halloween_MKB42H_Pickup_MIC"))

//Neon HMTech-101 Pistol
    Skins.Add((Id=6485, Weapondef=class'KFWeapDef_MedicPistol', MIC_1P=("WEP_SkinSet22_MAT.neon_medicpistol.Neon_MedicPistol_1P_Mint_MIC"), MIC_3P="WEP_SkinSet22_MAT.neon_medicpistol.Neon_MedicPistol_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet22_MAT.neon_medicpistol.Neon_MedicPistol_3P_Pickup_MIC"))
    Skins.Add((Id=6484, Weapondef=class'KFWeapDef_MedicPistol', MIC_1P=("WEP_SkinSet22_MAT.neon_medicpistol.Neon_MedicPistol_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet22_MAT.neon_medicpistol.Neon_MedicPistol_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet22_MAT.neon_medicpistol.Neon_MedicPistol_3P_Pickup_MIC"))
    Skins.Add((Id=6483, Weapondef=class'KFWeapDef_MedicPistol', MIC_1P=("WEP_SkinSet22_MAT.neon_medicpistol.Neon_MedicPistol_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet22_MAT.neon_medicpistol.Neon_MedicPistol_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet22_MAT.neon_medicpistol.Neon_MedicPistol_3P_Pickup_MIC"))

//Neon HMTech-201 SMG
    Skins.Add((Id=6488, Weapondef=class'KFWeapDef_MedicSMG', MIC_1P=("WEP_SkinSet22_MAT.neon_medicpistol.Neon_MedicPistol_1P_Mint_MIC", "WEP_SkinSet22_MAT.neon_medicsmg.Neon_MedicSMG_1P_Mint_MIC"), MIC_3P="WEP_SkinSet22_MAT.neon_medicsmg.Neon_MedicSMG_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet22_MAT.neon_medicsmg.Neon_MedicSMG_3P_Pickup_MIC"))
    Skins.Add((Id=6487, Weapondef=class'KFWeapDef_MedicSMG', MIC_1P=("WEP_SkinSet22_MAT.neon_medicpistol.Neon_MedicPistol_1P_FieldTested_MIC", "WEP_SkinSet22_MAT.neon_medicsmg.Neon_MedicSMG_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet22_MAT.neon_medicsmg.Neon_MedicSMG_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet22_MAT.neon_medicsmg.Neon_MedicSMG_3P_Pickup_MIC"))
    Skins.Add((Id=6486, Weapondef=class'KFWeapDef_MedicSMG', MIC_1P=("WEP_SkinSet22_MAT.neon_medicpistol.Neon_MedicPistol_1P_BattleScarred_MIC", "WEP_SkinSet22_MAT.neon_medicsmg.Neon_MedicSMG_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet22_MAT.neon_medicsmg.Neon_MedicSMG_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet22_MAT.neon_medicsmg.Neon_MedicSMG_3P_Pickup_MIC"))

//Neon HMTech-301 Shotgun
    Skins.Add((Id=6491, Weapondef=class'KFWeapDef_MedicShotgun', MIC_1P=("WEP_SkinSet22_MAT.neon_medicpistol.Neon_MedicPistol_1P_Mint_MIC", "WEP_SkinSet22_MAT.neon_medicshotgun.Neon_MedicShotgun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet22_MAT.neon_medicshotgun.Neon_MedicShotgun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet22_MAT.neon_medicshotgun.Neon_MedicShotgun_3P_Pickup_MIC"))
    Skins.Add((Id=6490, Weapondef=class'KFWeapDef_MedicShotgun', MIC_1P=("WEP_SkinSet22_MAT.neon_medicpistol.Neon_MedicPistol_1P_FieldTested_MIC", "WEP_SkinSet22_MAT.neon_medicshotgun.Neon_MedicShotgun_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet22_MAT.neon_medicshotgun.Neon_MedicShotgun_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet22_MAT.neon_medicshotgun.Neon_MedicShotgun_3P_Pickup_MIC"))
    Skins.Add((Id=6489, Weapondef=class'KFWeapDef_MedicShotgun', MIC_1P=("WEP_SkinSet22_MAT.neon_medicpistol.Neon_MedicPistol_1P_BattleScarred_MIC", "WEP_SkinSet22_MAT.neon_medicshotgun.Neon_MedicShotgun_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet22_MAT.neon_medicshotgun.Neon_MedicShotgun_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet22_MAT.neon_medicshotgun.Neon_MedicShotgun_3P_Pickup_MIC"))

//Neon HMTech-401 Assault Rifle
    Skins.Add((Id=6497, Weapondef=class'KFWeapDef_MedicRifle', MIC_1P=("WEP_SkinSet22_MAT.neon_medicassault.Neon_MedicAssault_1P_Mint_MIC", "WEP_SkinSet22_MAT.neon_medicpistol.Neon_MedicPistol_1P_Mint_MIC"), MIC_3P="WEP_SkinSet22_MAT.neon_medicassault.Neon_MedicAssault_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet22_MAT.neon_medicassault.Neon_MedicAssault_3P_Pickup_MIC"))
    Skins.Add((Id=6496, Weapondef=class'KFWeapDef_MedicRifle', MIC_1P=("WEP_SkinSet22_MAT.neon_medicassault.Neon_MedicAssault_1P_FieldTested_MIC", "WEP_SkinSet22_MAT.neon_medicpistol.Neon_MedicPistol_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet22_MAT.neon_medicassault.Neon_MedicAssault_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet22_MAT.neon_medicassault.Neon_MedicAssault_3P_Pickup_MIC"))
    Skins.Add((Id=6495, Weapondef=class'KFWeapDef_MedicRifle', MIC_1P=("WEP_SkinSet22_MAT.neon_medicassault.Neon_MedicAssault_1P_BattleScarred_MIC", "WEP_SkinSet22_MAT.neon_medicpistol.Neon_MedicPistol_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet22_MAT.neon_medicassault.Neon_MedicAssault_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet22_MAT.neon_medicassault.Neon_MedicAssault_3P_Pickup_MIC"))

//Neon HMTech-501 Grenade Rifle
    Skins.Add((Id=6500, Weapondef=class'KFWeapDef_MedicRifleGrenadeLauncher', MIC_1P=("WEP_SkinSet22_MAT.neon_medicgrenaderifle.Neon_MedicGrenadeRifle_1P_Mint_MIC"), MIC_3P="WEP_SkinSet22_MAT.neon_medicgrenaderifle.Neon_MedicGrenadeRifle_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet22_MAT.neon_medicgrenaderifle.Neon_MedicGrenadeRifle_3P_Pickup_MIC"))
    Skins.Add((Id=6499, Weapondef=class'KFWeapDef_MedicRifleGrenadeLauncher', MIC_1P=("WEP_SkinSet22_MAT.neon_medicgrenaderifle.Neon_MedicGrenadeRifle_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet22_MAT.neon_medicgrenaderifle.Neon_MedicGrenadeRifle_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet22_MAT.neon_medicgrenaderifle.Neon_MedicGrenadeRifle_3P_Pickup_MIC"))
    Skins.Add((Id=6498, Weapondef=class'KFWeapDef_MedicRifleGrenadeLauncher', MIC_1P=("WEP_SkinSet22_MAT.neon_medicgrenaderifle.Neon_MedicGrenadeRifle_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet22_MAT.neon_medicgrenaderifle.Neon_MedicGrenadeRifle_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet22_MAT.neon_medicgrenaderifle.Neon_MedicGrenadeRifle_3P_Pickup_MIC"))

//Neon MKb.42
    Skins.Add((Id=6503, Weapondef=class'KFWeapDef_MKB42', MIC_1P=("WEP_SkinSet22_MAT.neon_mkb42.Neon_MKB42_1P_Mint_MIC"), MIC_3P="WEP_SkinSet22_MAT.neon_mkb42.Neon_MKB42_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet22_MAT.neon_mkb42.Neon_MKB42_3P_Pickup_MIC"))
    Skins.Add((Id=6502, Weapondef=class'KFWeapDef_MKB42', MIC_1P=("WEP_SkinSet22_MAT.neon_mkb42.Neon_MKB42_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet22_MAT.neon_mkb42.Neon_MKB42_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet22_MAT.neon_mkb42.Neon_MKB42_3P_Pickup_MIC"))
    Skins.Add((Id=6501, Weapondef=class'KFWeapDef_MKB42', MIC_1P=("WEP_SkinSet22_MAT.neon_mkb42.Neon_MKB42_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet22_MAT.neon_mkb42.Neon_MKB42_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet22_MAT.neon_mkb42.Neon_MKB42_3P_Pickup_MIC"))

//Neon 500 Magnum Revolver
    Skins.Add((Id=6506, Weapondef=class'KFWeapDef_SW500', MIC_1P=("WEP_SkinSet22_MAT.neon_sw500.Neon_SW500_1P_Mint_MIC"), MIC_3P="WEP_SkinSet22_MAT.neon_sw500.Neon_SW500_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet22_MAT.neon_sw500.Neon_SW500_3P_Pickup_MIC"))
    Skins.Add((Id=6505, Weapondef=class'KFWeapDef_SW500', MIC_1P=("WEP_SkinSet22_MAT.neon_sw500.Neon_SW500_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet22_MAT.neon_sw500.Neon_SW500_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet22_MAT.neon_sw500.Neon_SW500_3P_Pickup_MIC"))
    Skins.Add((Id=6504, Weapondef=class'KFWeapDef_SW500', MIC_1P=("WEP_SkinSet22_MAT.neon_sw500.Neon_SW500_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet22_MAT.neon_sw500.Neon_SW500_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet22_MAT.neon_sw500.Neon_SW500_3P_Pickup_MIC"))

//Neon Freeze Thrower
    Skins.Add((Id=6509, Weapondef=class'KFWeapDef_FreezeThrower', MIC_1P=("WEP_SkinSet22_MAT.neon_cryogun.Neon_CryoGun_ID1_1P_Mint_MIC", "WEP_SkinSet22_MAT.neon_cryogun.Neon_CryoGun_ID2_1P_Mint_MIC"), MIC_3P="WEP_SkinSet22_MAT.neon_cryogun.Neon_CryoGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet22_MAT.neon_cryogun.Neon_CryoGun_3P_Pickup_MIC"))
    Skins.Add((Id=6508, Weapondef=class'KFWeapDef_FreezeThrower', MIC_1P=("WEP_SkinSet22_MAT.neon_cryogun.Neon_CryoGun_ID1_1P_FieldTested_MIC", "WEP_SkinSet22_MAT.neon_cryogun.Neon_CryoGun_ID2_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet22_MAT.neon_cryogun.Neon_CryoGun_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet22_MAT.neon_cryogun.Neon_CryoGun_3P_Pickup_MIC"))
    Skins.Add((Id=6507, Weapondef=class'KFWeapDef_FreezeThrower', MIC_1P=("WEP_SkinSet22_MAT.neon_cryogun.Neon_CryoGun_ID1_1P_BattleScarred_MIC", "WEP_SkinSet22_MAT.neon_cryogun.Neon_CryoGun_ID2_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet22_MAT.neon_cryogun.Neon_CryoGun_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet22_MAT.neon_cryogun.Neon_CryoGun_3P_Pickup_MIC"))

//Neon M4
    Skins.Add((Id=6512, Weapondef=class'KFWeapDef_M4', MIC_1P=("WEP_SkinSet22_MAT.neon_m4.Neon_M4_1P_Mint_MIC"), MIC_3P="WEP_SkinSet22_MAT.neon_m4.Neon_M4_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet22_MAT.neon_m4.Neon_M4_3P_Pickup_MIC"))
    Skins.Add((Id=6511, Weapondef=class'KFWeapDef_M4', MIC_1P=("WEP_SkinSet22_MAT.neon_m4.Neon_M4_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet22_MAT.neon_m4.Neon_M4_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet22_MAT.neon_m4.Neon_M4_3P_Pickup_MIC"))
    Skins.Add((Id=6510, Weapondef=class'KFWeapDef_M4', MIC_1P=("WEP_SkinSet22_MAT.neon_m4.Neon_M4_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet22_MAT.neon_m4.Neon_M4_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet22_MAT.neon_m4.Neon_M4_3P_Pickup_MIC"))

//Neon Bone Crusher
    Skins.Add((Id=6515, Weapondef=class'KFWeapDef_MaceAndShield', MIC_1P=("WEP_SkinSet22_MAT.neon_maceandshield.Neon_Mace_1P_Mint_MIC", "WEP_SkinSet22_MAT.neon_maceandshield.Neon_Shield_1P_Mint_MIC"), MIC_3P="WEP_SkinSet22_MAT.neon_maceandshield.Neon_MaceAndShield_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet22_MAT.neon_maceandshield.Neon_MaceAndShield_3P_Pickup_MIC"))
    Skins.Add((Id=6514, Weapondef=class'KFWeapDef_MaceAndShield', MIC_1P=("WEP_SkinSet22_MAT.neon_maceandshield.Neon_Mace_1P_FieldTested_MIC", "WEP_SkinSet22_MAT.neon_maceandshield.Neon_Shield_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet22_MAT.neon_maceandshield.Neon_MaceAndShield_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet22_MAT.neon_maceandshield.Neon_MaceAndShield_3P_Pickup_MIC"))
    Skins.Add((Id=6513, Weapondef=class'KFWeapDef_MaceAndShield', MIC_1P=("WEP_SkinSet22_MAT.neon_maceandshield.Neon_Mace_1P_BattleScarred_MIC", "wep_skinset22_mat.neon_maceandshield.Neon_Shield_1P_BattleScarredd_MIC"), MIC_3P="WEP_SkinSet22_MAT.neon_maceandshield.Neon_MaceAndShield_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet22_MAT.neon_maceandshield.Neon_MaceAndShield_3P_Pickup_MIC"))

//Neon RGB HMTech-101 Pistol
    Skins.Add((Id=6473, Weapondef=class'KFWeapDef_MedicPistol', MIC_1P=("WEP_SkinSet22_MAT.neonrgb_medicpistol.NeonRGB_MedicPistol_1P_Mint_MIC"), MIC_3P="WEP_SkinSet22_MAT.neonrgb_medicpistol.NeonRGB_MedicPistol_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet22_MAT.neonrgb_medicpistol.NeonRGB_MedicPistol_3P_Pickup_MIC"))

//Neon RGB HMTech-201 SMG
    Skins.Add((Id=6474, Weapondef=class'KFWeapDef_MedicSMG', MIC_1P=("WEP_SkinSet22_MAT.neonrgb_medicpistol.NeonRGB_MedicPistol_1P_Mint_MIC", "WEP_SkinSet22_MAT.neonrgb_medicsmg.NeonRGB_MedicSMG_1P_Mint_MIC"), MIC_3P="WEP_SkinSet22_MAT.neonrgb_medicsmg.NeonRGB_MedicSMG_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet22_MAT.neonrgb_medicsmg.NeonRGB_MedicSMG_3P_Pickup_MIC"))

//Neon RGB HMTech-301 Shotgun
    Skins.Add((Id=6475, Weapondef=class'KFWeapDef_MedicShotgun', MIC_1P=("WEP_SkinSet22_MAT.neonrgb_medicpistol.NeonRGB_MedicPistol_1P_Mint_MIC", "WEP_SkinSet22_MAT.neonrgb_medicshotgun.NeonRGB_MedicShotgun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet22_MAT.neonrgb_medicshotgun.NeonRGB_MedicShotgun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet22_MAT.neonrgb_medicshotgun.NeonRGB_MedicShotgun_3P_Pickup_MIC"))

//Neon RGB HMTech-401 Assault Rifle
    Skins.Add((Id=6476, Weapondef=class'KFWeapDef_MedicRifle', MIC_1P=("WEP_SkinSet22_MAT.neonrgb_medicassault.NeonRGB_MedicAssault_1P_Mint_MIC", "WEP_SkinSet22_MAT.neonrgb_medicpistol.NeonRGB_MedicPistol_1P_Mint_MIC"), MIC_3P="WEP_SkinSet22_MAT.neonrgb_medicassault.NeonRGB_MedicAssault_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet22_MAT.neonrgb_medicassault.NeonRGB_MedicAssault_3P_Pickup_MIC"))

//Neon RGB HMTech-501 Grenade Rifle
    Skins.Add((Id=6477, Weapondef=class'KFWeapDef_MedicRifleGrenadeLauncher', MIC_1P=("WEP_SkinSet22_MAT.neonrgb_medicgrenaderifle.NeonRGB_MedicGrenadeRifle_1P_Mint_MIC"), MIC_3P="WEP_SkinSet22_MAT.neonrgb_medicgrenaderifle.NeonRGB_MedicGrenadeRifle_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet22_MAT.neonrgb_medicgrenaderifle.NeonRGB_MedicGrenadeRifle_3P_Pickup_MIC"))

//Neon RGB MKb.42
    Skins.Add((Id=6478, Weapondef=class'KFWeapDef_MKB42', MIC_1P=("WEP_SkinSet22_MAT.neonrgb_mkb42.NeonRGB_MKB42_1P_Mint_MIC"), MIC_3P="WEP_SkinSet22_MAT.neonrgb_mkb42.NeonRGB_MKB42_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet22_MAT.neonrgb_mkb42.NeonRGB_MKB42_3P_Pickup_MIC"))

//Neon RGB 500 Magnum Revolver
    Skins.Add((Id=6479, Weapondef=class'KFWeapDef_SW500', MIC_1P=("WEP_SkinSet22_MAT.neonrgb_sw500.NeonRGB_SW500_1P_Mint_MIC"), MIC_3P="WEP_SkinSet22_MAT.neonrgb_sw500.NeonRGB_SW500_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet22_MAT.neonrgb_sw500.NeonRGB_SW500_3P_Pickup_MIC"))

//Neon RGB Freeze Thrower
    Skins.Add((Id=6480, Weapondef=class'KFWeapDef_FreezeThrower', MIC_1P=("WEP_SkinSet22_MAT.neonrgb_cryogun.NeonRGB_CryoGun_ID1_1P_Mint_MIC", "WEP_SkinSet22_MAT.neonrgb_cryogun.NeonRGB_CryoGun_ID2_1P_Mint_MIC"), MIC_3P="WEP_SkinSet22_MAT.neonrgb_cryogun.NeonRGB_CryoGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet22_MAT.neonrgb_cryogun.NeonRGB_CryoGun_3P_Pickup_MIC"))

//Neon RGB M4
    Skins.Add((Id=6481, Weapondef=class'KFWeapDef_M4', MIC_1P=("WEP_SkinSet22_MAT.neonrgb_m4.NeonRGB_M4_1P_Mint_MIC"), MIC_3P="WEP_SkinSet22_MAT.neonrgb_m4.NeonRGB_M4_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet22_MAT.neonrgb_m4.NeonRGB_M4_3P_Pickup_MIC"))

//Neon RGB Bone Crusher
    Skins.Add((Id=6482, Weapondef=class'KFWeapDef_MaceAndShield', MIC_1P=("WEP_SkinSet22_MAT.neonrgb_maceandshield.NeonRGB_Mace_1P_Mint_MIC", "WEP_SkinSet22_MAT.neonrgb_maceandshield.NeonRGB_Shield_1P_Mint_MIC"), MIC_3P="WEP_SkinSet22_MAT.neonrgb_maceandshield.NeonRGB_MaceAndShield_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet22_MAT.neonrgb_maceandshield.NeonRGB_MaceAndShield_3P_Pickup_MIC"))

//Prestige Katana
    Skins.Add((Id=6462, Weapondef=class'KFWeapDef_Katana', MIC_1P=("WEP_SkinSet_Prestige03_MAT.tier02.Prestige_Berserker_Katana_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_Prestige03_MAT.tier02.Prestige_Berserker_Katana_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_Prestige03_MAT.tier02.Prestige_Berserker_Katana_3P_Pickup_MIC"))

//Prestige L85A2
    Skins.Add((Id=6463, Weapondef=class'KFWeapDef_Bullpup', MIC_1P=("WEP_SkinSet_Prestige03_MAT.tier02.Prestige_Commando_L85A2_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_Prestige03_MAT.tier02.Prestige_Commando_L85A2_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_Prestige03_MAT.tier02.Prestige_Commando_L85A2_3P_Pickup_MIC"))

//Prestige M79
    Skins.Add((Id=6464, Weapondef=class'KFWeapDef_M79', MIC_1P=("WEP_SkinSet_Prestige03_MAT.tier02.Prestige_Demolition_M79_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_Prestige03_MAT.tier02.Prestige_Demolition_M79_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_Prestige03_MAT.tier02.Prestige_Demolition_M79_3P_Pickup_MIC"))

//Prestige Dragonsbreath
    Skins.Add((Id=6465, Weapondef=class'KFWeapDef_Dragonsbreath', MIC_1P=("WEP_SkinSet_Prestige03_MAT.tier02.Prestige_Firebug_Dragonsbreath_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_Prestige03_MAT.tier02.Prestige_Firebug_Dragonsbreath_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_Prestige03_MAT.tier02.Prestige_Firebug_Dragonsbreath_3P_Pickup_MIC"))

//Prestige M1911
    Skins.Add((Id=6466, Weapondef=class'KFWeapDef_Colt1911', MIC_1P=("WEP_SkinSet_Prestige03_MAT.tier02.Prestige_Gunslinger_M1911_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_Prestige03_MAT.tier02.Prestige_Gunslinger_M1911_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_Prestige03_MAT.tier02.Prestige_Gunslinger_M1911_3P_Pickup_MIC"))

//Prestige HMTech-201 SMG
    Skins.Add((Id=6468, Weapondef=class'KFWeapDef_MedicSMG', MIC_1P=("WEP_SkinSet_Prestige02_MAT.tier01.Prestige_Medic_MedicPistol_1P_Mint_MIC", "WEP_SkinSet_Prestige03_MAT.tier02.Prestige_Medic_MedicSMG_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_Prestige03_MAT.tier02.Prestige_Medic_MedicSMG_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_Prestige03_MAT.tier02.Prestige_Medic_MedicSMG_3P_Pickup_MIC"))

//Prestige Crossbow
    Skins.Add((Id=6469, Weapondef=class'KFWeapDef_Crossbow', MIC_1P=("WEP_SkinSet_Prestige03_MAT.tier02.Prestige_Sharpshooter_Crossbow_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_Prestige03_MAT.tier02.Prestige_Sharpshooter_Crossbow_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_Prestige03_MAT.tier02.Prestige_Sharpshooter_Crossbow_3P_Pickup_MIC"))

//Prestige Boomstick
    Skins.Add((Id=6470, Weapondef=class'KFWeapDef_DoubleBarrel', MIC_1P=("WEP_SkinSet_Prestige03_MAT.tier02.Prestige_Support_Boomstick_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_Prestige03_MAT.tier02.Prestige_Support_Boomstick_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_Prestige03_MAT.tier02.Prestige_Support_Boomstick_3P_Pickup_MIC"))

//Prestige Tommy Gun
    Skins.Add((Id=6471, Weapondef=class'KFWeapDef_Thompson', MIC_1P=("WEP_SkinSet_Prestige03_MAT.tier02.Prestige_Survivalist_TommyGun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_Prestige03_MAT.tier02.Prestige_Survivalist_TommyGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_Prestige03_MAT.tier02.Prestige_Survivalist_TommyGun_3P_Pickup_MIC"))

//Prestige MP5RAS
    Skins.Add((Id=6472, Weapondef=class'KFWeapDef_MP5RAS', MIC_1P=("WEP_SkinSet_Prestige03_MAT.tier02.Prestige_SWAT_MP5RAS_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_Prestige03_MAT.tier02.Prestige_SWAT_MP5RAS_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_Prestige03_MAT.tier02.Prestige_SWAT_MP5RAS_3P_Pickup_MIC"))

//Christmas BattleAxe
	Skins.Add((Id=5378, Weapondef=class'KFWeapDef_AbominationAxe', MIC_1P=("WEP_1P_KrampusAxe_MAT.Wep_1stP_KrampusAxe_MIC"), MIC_3P="WEP_3P_KrampusAxe_MAT.WEP_3P_KrampusAxe_MIC", MIC_Pickup="WEP_3P_KrampusAxe_MAT.WEP_3P_KrampusAxe_Pickup_MIC"))

//Vault Vosh AA12
	Skins.Add((Id=6614, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet_VaultVosh05_MAT.vosh_aa12.Vault_Vosh_AA12_1P_Mint_MIC"), MIC_3P="WEP_skinset_vaultvosh05_mat.vosh_aa12.Vault_Vosh_AA12_3P_Mint_MIC", MIC_Pickup="WEP_skinset_vaultvosh05_mat.vosh_aa12.Vault_Vosh_AA12_3P_Pickup_MIC"))

//Vault Vosh Sawblade
	Skins.Add((Id=6607, Weapondef=class'KFWeapDef_Eviscerator', MIC_1P=("WEP_SkinSet_VaultVosh05_MAT.vosh_sawblade.Vosh_Vault_SawBlade_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh05_MAT.vosh_sawblade.Vosh_Vault_SawBlade_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh05_MAT.vosh_sawblade.Vault_Vosh_sawblade_3P_Pickup_MIC"))

//Vault Vosh HMTech-401 Assault Rifle
    Skins.Add((Id=6612, Weapondef=class'KFWeapDef_MedicRifle', MIC_1P=("WEP_skinset_vaultvosh05_mat.vosh_medic_assault.Vault_Vosh_Medic_Assault_1P_Mint_MIC", "WEP_SkinSet_VaultVosh02_MAT.vosh_medic_pistol.Vault_Vosh_Medic_Pistol_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh05_MAT.vosh_medic_assault.Vault_Vosh_Medic_Assault_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh05_MAT.vosh_medic_assault.Vault_Vosh_Medic_Assault_3P_Pickup_MIC"))

//Vault Vosh Kriss
	Skins.Add((Id=6615, Weapondef=class'KFWeapDef_Kriss', MIC_1P=("WEP_SkinSet_VaultVosh05_MAT.vosh_kriss.Vault_Vosh_KRISS_1P_Mint_MIC", "WEP_1P_KRISS_MAT.Wep_1stP_KRISS_Reddot_MIC"), MIC_3P="WEP_SkinSet_VaultVosh05_MAT.vosh_kriss.Vault_Vosh_KRISS_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh05_MAT.vosh_kriss.Vault_Vosh_KRISS_3P_Pickup_MIC"))

//Vault Vosh Microwave Gun
	Skins.Add((Id=6610, Weapondef=class'KFWeapDef_MicrowaveGun', MIC_1P=("WEP_SkinSet_VaultVosh05_MAT.vosh_microwave_gun.Vault_Vosh_Microwave_Gun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh05_MAT.vosh_microwave_gun.Vault_Vosh_Microwave_Gun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh05_MAT.vosh_microwave_gun.Vault_Vosh_Microwave_Gun_3P_Pickup_MIC"))

//Vault Vosh SCAR
	Skins.Add((Id=6608, Weapondef=class'KFWeapDef_SCAR', MIC_1P=("WEP_SkinSet_VaultVosh05_MAT.vosh_scar.Vault_Vosh_SCAR_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh05_MAT.vosh_scar.Vault_Vosh_SCAR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh05_MAT.vosh_scar.Vault_Vosh_SCAR_3P_Pickup_MIC"))

//Vault Vosh Railgun
	Skins.Add((Id=6613, Weapondef=class'KFWeapDef_RailGun', MIC_1P=("WEP_SkinSet_VaultVosh05_MAT.vosh_railgun.Vault_Vosh_RailGun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh05_MAT.vosh_railgun.Vault_Vosh_RailGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh05_MAT.vosh_railgun.Vault_Vosh_RailGun_3P_Pickup_MIC"))

//Vault Vosh RPG7
	Skins.Add((Id=6609, Weapondef=class'KFWeapDef_RPG7', MIC_1P=("WEP_SkinSet_VaultVosh05_MAT.vosh_rpg7.Vault_Vosh_RPG7_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh05_MAT.vosh_rpg7.Vault_Vosh_RPG7_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh05_MAT.vosh_rpg7.Vault_Vosh_RPG7_3P_Pickup_MIC"))

//Vault Vosh SW500
	Skins.Add((Id=6611, Weapondef=class'KFWeapDef_SW500', MIC_1P=("WEP_SkinSet_VaultVosh05_MAT.vosh_sw500.Vault_Vosh_SW_500_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh05_MAT.vosh_sw500.Vault_Vosh_SW_500_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh05_MAT.vosh_sw500.Vault_Vosh_SW_500_3P_Pickup_MIC"))

//Precious Medic Bat
	Skins.Add((Id=6871, Weapondef=class'KFWeapDef_MedicBat', MIC_1P=("WEP_1P_Medic_Bat_SKIN_MAT.Wep_1P_Skin_Precious_Medic_Bat_MIC"), MIC_3P="WEP_1P_Medic_Bat_SKIN_MAT.Wep_3P_Skin_Precious_Medic_Bat_MIC", MIC_Pickup="WEP_1P_Medic_Bat_SKIN_MAT.Precious_Medic_Bat_3P_Pickup_MIC"))

//Neon AR15
    Skins.Add((Id=6904, Weapondef=class'KFWeapDef_AR15', MIC_1P=("WEP_SkinSet24_MAT.neon_ar15.Neon_AR15_1P_Mint_MIC"), MIC_3P="WEP_SkinSet24_MAT.neon_ar15.Neon_AR15_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet24_MAT.neon_ar15.Neon_AR15_3P_Pickup_MIC"))
    Skins.Add((Id=6903, Weapondef=class'KFWeapDef_AR15', MIC_1P=("WEP_SkinSet24_MAT.neon_ar15.Neon_AR15_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet24_MAT.neon_ar15.Neon_AR15_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet24_MAT.neon_ar15.Neon_AR15_3P_Pickup_MIC"))
    Skins.Add((Id=6902, Weapondef=class'KFWeapDef_AR15', MIC_1P=("WEP_SkinSet24_MAT.neon_ar15.Neon_AR15_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet24_MAT.neon_ar15.Neon_AR15_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet24_MAT.neon_ar15.Neon_AR15_3P_Pickup_MIC"))

//Neon BattleAxe
    Skins.Add((Id=6907, Weapondef=class'KFWeapDef_AbominationAxe', MIC_1P=("WEP_SkinSet24_MAT.neon_krampusaxe.Neon_KrampusAxe_1P_Mint_MIC"), MIC_3P="WEP_SkinSet24_MAT.neon_krampusaxe.Neon_KrampusAxe_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet24_MAT.neon_krampusaxe.Neon_KrampusAxe_3P_Pickup_MIC"))
    Skins.Add((Id=6906, Weapondef=class'KFWeapDef_AbominationAxe', MIC_1P=("WEP_SkinSet24_MAT.neon_krampusaxe.Neon_KrampusAxe_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet24_MAT.neon_krampusaxe.Neon_KrampusAxe_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet24_MAT.neon_krampusaxe.Neon_KrampusAxe_3P_Pickup_MIC"))
    Skins.Add((Id=6905, Weapondef=class'KFWeapDef_AbominationAxe', MIC_1P=("WEP_SkinSet24_MAT.neon_krampusaxe.Neon_KrampusAxe_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet24_MAT.neon_krampusaxe.Neon_KrampusAxe_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet24_MAT.neon_krampusaxe.Neon_KrampusAxe_3P_Pickup_MIC"))

//Neon C4
    Skins.Add((Id=6910, Weapondef=class'KFWeapDef_C4', MIC_1P=("WEP_SkinSet24_MAT.neon_c4.Neon_C4_1P_Mint_MIC"), MIC_3P="WEP_SkinSet24_MAT.neon_c4.Neon_C4_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet24_MAT.neon_c4.Neon_C4_3P_Pickup_MIC"))
    Skins.Add((Id=6909, Weapondef=class'KFWeapDef_C4', MIC_1P=("WEP_SkinSet24_MAT.neon_c4.Neon_C4_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet24_MAT.neon_c4.Neon_C4_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet24_MAT.neon_c4.Neon_C4_3P_Pickup_MIC"))
    Skins.Add((Id=6908, Weapondef=class'KFWeapDef_C4', MIC_1P=("WEP_SkinSet24_MAT.neon_c4.Neon_C4_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet24_MAT.neon_c4.Neon_C4_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet24_MAT.neon_c4.Neon_C4_3P_Pickup_MIC"))

//Neon Crossbow
    Skins.Add((Id=6913, Weapondef=class'KFWeapDef_Crossbow', MIC_1P=("WEP_SkinSet24_MAT.neon_crossbow.Neon_Crossbow_1P_Mint_MIC", "WEP_SkinSet24_MAT.neon_crossbow.Neon_Crossbow_Optic_1P_Mint_MIC"), MIC_3P="WEP_SkinSet24_MAT.neon_crossbow.Neon_Crossbow_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet24_MAT.neon_crossbow.Neon_Crossbow_3P_Pickup_MIC"))
    Skins.Add((Id=6912, Weapondef=class'KFWeapDef_Crossbow', MIC_1P=("WEP_SkinSet24_MAT.neon_crossbow.Neon_Crossbow_1P_FieldTested_MIC", "WEP_SkinSet24_MAT.neon_crossbow.Neon_Crossbow_Optic_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet24_MAT.neon_crossbow.Neon_Crossbow_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet24_MAT.neon_crossbow.Neon_Crossbow_3P_Pickup_MIC"))
    Skins.Add((Id=6911, Weapondef=class'KFWeapDef_Crossbow', MIC_1P=("WEP_SkinSet24_MAT.neon_crossbow.Neon_Crossbow_1P_BattleScarred_MIC", "WEP_SkinSet24_MAT.neon_crossbow.Neon_Crossbow_Optic_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet24_MAT.neon_crossbow.Neon_Crossbow_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet24_MAT.neon_crossbow.Neon_Crossbow_3P_Pickup_MIC"))

//Neon Desert Eagle
    Skins.Add((Id=6916, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet24_MAT.neon_deagle.Neon_Deagle_1P_Mint_MIC"), MIC_3P="WEP_SkinSet24_MAT.neon_deagle.Neon_Deagle_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet24_MAT.neon_deagle.Neon_Deagle_3P_Pickup_MIC"))
    Skins.Add((Id=6915, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet24_MAT.neon_deagle.Neon_Deagle_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet24_MAT.neon_deagle.Neon_Deagle_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet24_MAT.neon_deagle.Neon_Deagle_3P_Pickup_MIC"))
    Skins.Add((Id=6914, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet24_MAT.neon_deagle.Neon_Deagle_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet24_MAT.neon_deagle.Neon_Deagle_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet24_MAT.neon_deagle.Neon_Deagle_3P_Pickup_MIC"))

//Neon Fire Axe
    Skins.Add((Id=6919, Weapondef=class'KFWeapDef_FireAxe', MIC_1P=("WEP_SkinSet24_MAT.neon_fireaxe.Neon_Fireaxe_1P_Mint_MIC"), MIC_3P="WEP_SkinSet24_MAT.neon_fireaxe.Neon_FireAxe_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet24_MAT.neon_fireaxe.Neon_FireAxe_3P_Pickup_MIC"))
    Skins.Add((Id=6918, Weapondef=class'KFWeapDef_FireAxe', MIC_1P=("WEP_SkinSet24_MAT.neon_fireaxe.Neon_Fireaxe_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet24_MAT.neon_fireaxe.Neon_FireAxe_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet24_MAT.neon_fireaxe.Neon_FireAxe_3P_Pickup_MIC"))
    Skins.Add((Id=6917, Weapondef=class'KFWeapDef_FireAxe', MIC_1P=("WEP_SkinSet24_MAT.neon_fireaxe.Neon_Fireaxe_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet24_MAT.neon_fireaxe.Neon_FireAxe_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet24_MAT.neon_fireaxe.Neon_FireAxe_3P_Pickup_MIC"))

//Neon FN FAL
    Skins.Add((Id=6922, Weapondef=class'KFWeapDef_FNFAL', MIC_1P=("WEP_SkinSet24_MAT.neon_fnfal.Neon_FNFAL_1P_Mint_MIC", "WEP_SkinSet24_MAT.neon_fnfal.Neon_FNFAL_Optic_1P_Mint_MIC"), MIC_3P="WEP_SkinSet24_MAT.neon_fnfal.Neon_FNFAL_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet24_MAT.neon_fnfal.Neon_FNFAL_3P_Pickup_MIC"))
    Skins.Add((Id=6921, Weapondef=class'KFWeapDef_FNFAL', MIC_1P=("WEP_SkinSet24_MAT.neon_fnfal.Neon_FNFAL_1P_FieldTested_MIC", "WEP_SkinSet24_MAT.neon_fnfal.Neon_FNFAL_Optic_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet24_MAT.neon_fnfal.Neon_FNFAL_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet24_MAT.neon_fnfal.Neon_FNFAL_3P_Pickup_MIC"))
    Skins.Add((Id=6920, Weapondef=class'KFWeapDef_FNFAL', MIC_1P=("WEP_SkinSet24_MAT.neon_fnfal.Neon_FNFAL_1P_BattleScarred_MIC", "WEP_SkinSet24_MAT.neon_fnfal.Neon_FNFAL_Optic_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet24_MAT.neon_fnfal.Neon_FNFAL_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet24_MAT.neon_fnfal.Neon_FNFAL_3P_Pickup_MIC"))

//Neon M32
    Skins.Add((Id=6925, Weapondef=class'KFWeapDef_M32', MIC_1P=("WEP_SkinSet24_MAT.neon_m32.Neon_M32_1P_Mint_MIC", "WEP_SkinSet24_MAT.neon_m32.Neon_M32_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet24_MAT.neon_m32.Neon_M32_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet24_MAT.neon_m32.Neon_M32_3P_Pickup_MIC"))
    Skins.Add((Id=6924, Weapondef=class'KFWeapDef_M32', MIC_1P=("WEP_SkinSet24_MAT.neon_m32.Neon_M32_1P_FieldTested_MIC", "WEP_SkinSet24_MAT.neon_m32.Neon_M32_Sight_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet24_MAT.neon_m32.Neon_M32_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet24_MAT.neon_m32.Neon_M32_3P_Pickup_MIC"))
    Skins.Add((Id=6923, Weapondef=class'KFWeapDef_M32', MIC_1P=("WEP_SkinSet24_MAT.neon_m32.Neon_M32_1P_BattleScarred_MIC", "WEP_SkinSet24_MAT.neon_m32.Neon_M32_Sight_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet24_MAT.neon_m32.Neon_M32_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet24_MAT.neon_m32.Neon_M32_3P_Pickup_MIC"))

//Neon MP7
    Skins.Add((Id=6928, Weapondef=class'KFWeapDef_MP7', MIC_1P=("WEP_SkinSet24_MAT.neon_mp7.Neon_MP7_1P_Mint_MIC", "WEP_SkinSet24_MAT.neon_mp7.Neon_MP7_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet24_MAT.neon_mp7.Neon_MP7_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet24_MAT.neon_mp7.Neon_MP7_3P_Pickup_MIC"))
    Skins.Add((Id=6927, Weapondef=class'KFWeapDef_MP7', MIC_1P=("WEP_SkinSet24_MAT.neon_mp7.Neon_MP7_1P_FieldTested_MIC", "WEP_SkinSet24_MAT.neon_mp7.Neon_MP7_Sight_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet24_MAT.neon_mp7.Neon_MP7_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet24_MAT.neon_mp7.Neon_MP7_3P_Pickup_MIC"))
    Skins.Add((Id=6926, Weapondef=class'KFWeapDef_MP7', MIC_1P=("WEP_SkinSet24_MAT.neon_mp7.Neon_MP7_1P_BattleScarred_MIC", "WEP_SkinSet24_MAT.neon_mp7.Neon_MP7_Sight_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet24_MAT.neon_mp7.Neon_MP7_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet24_MAT.neon_mp7.Neon_MP7_3P_Pickup_MIC"))

//Neon Tommy Gun
    Skins.Add((Id=6931, Weapondef=class'KFWeapDef_Thompson', MIC_1P=("WEP_SkinSet24_MAT.neon_tommygun.Neon_TommyGun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet24_MAT.neon_tommygun.Neon_TommyGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet24_MAT.neon_tommygun.Neon_TommyGun_3P_Pickup_MIC"))
    Skins.Add((Id=6930, Weapondef=class'KFWeapDef_Thompson', MIC_1P=("WEP_SkinSet24_MAT.neon_tommygun.Neon_TommyGun_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet24_MAT.neon_tommygun.Neon_TommyGun_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet24_MAT.neon_tommygun.Neon_TommyGun_3P_Pickup_MIC"))
    Skins.Add((Id=6929, Weapondef=class'KFWeapDef_Thompson', MIC_1P=("WEP_SkinSet24_MAT.neon_tommygun.Neon_TommyGun_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet24_MAT.neon_tommygun.Neon_TommyGun_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet24_MAT.neon_tommygun.Neon_TommyGun_3P_Pickup_MIC"))

//Neon RGB AR15
    Skins.Add((Id=6892, Weapondef=class'KFWeapDef_AR15', MIC_1P=("WEP_SkinSet24_MAT.neonrgb_ar15.NeonRGB_AR15_1P_Mint_MIC"), MIC_3P="WEP_SkinSet24_MAT.neonrgb_ar15.NeonRGB_AR15_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet24_MAT.neonrgb_ar15.NeonRGB_AR15_3P_Pickup_MIC"))

//Neon RGB BattleAxe
    Skins.Add((Id=6893, Weapondef=class'KFWeapDef_AbominationAxe', MIC_1P=("WEP_SkinSet24_MAT.neonrgb_krampusaxe.NeonRGB_KrampusAxe_1P_Mint_MIC"), MIC_3P="WEP_SkinSet24_MAT.neonrgb_krampusaxe.NeonRGB_KrampusAxe_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet24_MAT.neonrgb_krampusaxe.NeonRGB_KrampusAxe_3P_Pickup_MIC"))

//Neon RGB C4
    Skins.Add((Id=6894, Weapondef=class'KFWeapDef_C4', MIC_1P=("WEP_SkinSet24_MAT.neonrgb_c4.NeonRGB_C4_1P_Mint_MIC"), MIC_3P="WEP_SkinSet24_MAT.neonrgb_c4.NeonRGB_C4_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet24_MAT.neonrgb_c4.NeonRGB_C4_3P_Pickup_MIC"))

//Neon RGB Crossbow
    Skins.Add((Id=6895, Weapondef=class'KFWeapDef_Crossbow', MIC_1P=("WEP_SkinSet24_MAT.neonrgb_crossbow.NeonRGB_Crossbow_1P_Mint_MIC", "WEP_SkinSet24_MAT.neonrgb_crossbow.NeonRGB_Crossbow_Optic_1P_Mint_MIC"), MIC_3P="WEP_SkinSet24_MAT.neonrgb_crossbow.NeonRGB_Crossbow_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet24_MAT.neonrgb_crossbow.NeonRGB_Crossbow_3P_Pickup_MIC"))

//Neon RGB Desert Eagle
    Skins.Add((Id=6896, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet24_MAT.neonrgb_deagle.NeonRGB_Deagle_1P_Mint_MIC"), MIC_3P="WEP_SkinSet24_MAT.neonrgb_deagle.NeonRGB_Deagle_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet24_MAT.neonrgb_deagle.NeonRGB_Deagle_3P_Pickup_MIC"))

//Neon RGB Fire Axe
    Skins.Add((Id=6897, Weapondef=class'KFWeapDef_FireAxe', MIC_1P=("WEP_SkinSet24_MAT.neonrgb_fireaxe.NeonRGB_Fireaxe_1P_Mint_MIC"), MIC_3P="WEP_SkinSet24_MAT.neonrgb_fireaxe.NeonRGB_FireAxe_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet24_MAT.neonrgb_fireaxe.NeonRGB_FireAxe_3P_Pickup_MIC"))

//Neon RGB FN FAL
    Skins.Add((Id=6898, Weapondef=class'KFWeapDef_FNFAL', MIC_1P=("WEP_SkinSet24_MAT.neonrgb_fnfal.NeonRGB_FNFAL_1P_Mint_MIC", "WEP_SkinSet24_MAT.neonrgb_fnfal.NeonRGB_FNFAL_Optic_1P_Mint_MIC"), MIC_3P="WEP_SkinSet24_MAT.neonrgb_fnfal.NeonRGB_FNFAL_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet24_MAT.neonrgb_fnfal.NeonRGB_FNFAL_3P_Pickup_MIC"))

//Neon RGB M32
    Skins.Add((Id=6899, Weapondef=class'KFWeapDef_M32', MIC_1P=("WEP_SkinSet24_MAT.neonrgb_m32.NeonRGB_M32_1P_Mint_MIC", "WEP_SkinSet24_MAT.neonrgb_m32.NeonRGB_M32_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet24_MAT.neonrgb_m32.NeonRGB_M32_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet24_MAT.neonrgb_m32.NeonRGB_M32_3P_Pickup_MIC"))

//Neon RGB MP7
    Skins.Add((Id=6900, Weapondef=class'KFWeapDef_MP7', MIC_1P=("WEP_SkinSet24_MAT.neonrgb_mp7.NeonRGB_MP7_1P_Mint_MIC", "WEP_SkinSet24_MAT.neonrgb_mp7.NeonRGB_MP7_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet24_MAT.neonrgb_mp7.NeonRGB_MP7_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet24_MAT.neonrgb_mp7.NeonRGB_MP7_3P_Pickup_MIC"))

//Neon RGB Tommy Gun
    Skins.Add((Id=6901, Weapondef=class'KFWeapDef_Thompson', MIC_1P=("WEP_SkinSet24_MAT.neonrgb_tommygun.NeonRGB_TommyGun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet24_MAT.neonrgb_tommygun.NeonRGB_TommyGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet24_MAT.neonrgb_tommygun.NeonRGB_TommyGun_3P_Pickup_MIC"))

//Synthwave 9MM
    Skins.Add((Id=6934, Weapondef=class'KFWeapDef_9mm', MIC_1P=("WEP_SkinSet23_MAT.synthwave_9mm.Synthwave_9MM_1P_Mint_MIC"), MIC_3P="WEP_SkinSet23_MAT.synthwave_9mm.Synthwave_9MM_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet23_MAT.synthwave_9mm.Synthwave_9MM_3P_Pickup_MIC"))
    Skins.Add((Id=6933, Weapondef=class'KFWeapDef_9mm', MIC_1P=("WEP_SkinSet23_MAT.synthwave_9mm.Synthwave_9MM_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet23_MAT.synthwave_9mm.Synthwave_9MM_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet23_MAT.synthwave_9mm.Synthwave_9MM_3P_Pickup_MIC"))
    Skins.Add((Id=6932, Weapondef=class'KFWeapDef_9mm', MIC_1P=("WEP_SkinSet23_MAT.synthwave_9mm.Synthwave_9MM_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet23_MAT.synthwave_9mm.Synthwave_9MM_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet23_MAT.synthwave_9mm.Synthwave_9MM_3P_Pickup_MIC"))

//Synthwave AK12
    Skins.Add((Id=6937, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet23_MAT.synthwave_ak12.Synthwave_AK12_1P_Mint_MIC"), MIC_3P="WEP_SkinSet23_MAT.synthwave_ak12.Synthwave_AK12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet23_MAT.synthwave_ak12.Synthwave_AK12_3P_Pickup_MIC"))
    Skins.Add((Id=6936, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet23_MAT.synthwave_ak12.Synthwave_AK12_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet23_MAT.synthwave_ak12.Synthwave_AK12_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet23_MAT.synthwave_ak12.Synthwave_AK12_3P_Pickup_MIC"))
    Skins.Add((Id=6935, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet23_MAT.synthwave_ak12.Synthwave_AK12_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet23_MAT.synthwave_ak12.Synthwave_AK12_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet23_MAT.synthwave_ak12.Synthwave_AK12_3P_Pickup_MIC"))

//Synthwave Desert Eagle
    Skins.Add((Id=6940, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet23_MAT.synthwave_deagle.Synthwave_Deagle_1P_Mint_MIC"), MIC_3P="WEP_SkinSet23_MAT.synthwave_deagle.Synthwave_Deagle_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet23_MAT.synthwave_deagle.Synthwave_Deagle_3P_Pickup_MIC"))
    Skins.Add((Id=6939, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet23_MAT.synthwave_deagle.Synthwave_Deagle_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet23_MAT.synthwave_deagle.Synthwave_Deagle_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet23_MAT.synthwave_deagle.Synthwave_Deagle_3P_Pickup_MIC"))
    Skins.Add((Id=6938, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet23_MAT.synthwave_deagle.Synthwave_Deagle_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet23_MAT.synthwave_deagle.Synthwave_Deagle_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet23_MAT.synthwave_deagle.Synthwave_Deagle_3P_Pickup_MIC"))

//Synthwave HMTech Healer
    Skins.Add((Id=6943, Weapondef=class'KFWeapDef_Healer', MIC_1P=("WEP_SkinSet23_MAT.synthwave_healer.Synthwave_Healer_1P_Mint_MIC"), MIC_3P="WEP_SkinSet23_MAT.synthwave_healer.Synthwave_Healer_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet23_MAT.synthwave_healer.Synthwave_Healer_3P_Pickup_MIC"))
    Skins.Add((Id=6942, Weapondef=class'KFWeapDef_Healer', MIC_1P=("WEP_SkinSet23_MAT.synthwave_healer.Synthwave_Healer_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet23_MAT.synthwave_healer.Synthwave_Healer_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet23_MAT.synthwave_healer.Synthwave_Healer_3P_Pickup_MIC"))
    Skins.Add((Id=6941, Weapondef=class'KFWeapDef_Healer', MIC_1P=("WEP_SkinSet23_MAT.synthwave_healer.Synthwave_Healer_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet23_MAT.synthwave_healer.Synthwave_Healer_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet23_MAT.synthwave_healer.Synthwave_Healer_3P_Pickup_MIC"))

//Synthwave Kriss SMG
    Skins.Add((Id=6946, Weapondef=class'KFWeapDef_Kriss', MIC_1P=("WEP_SkinSet23_MAT.synthwave_kriss.Synthwave_KRISS_1P_Mint_MIC"), MIC_3P="WEP_SkinSet23_MAT.synthwave_kriss.Synthwave_KRISS_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet23_MAT.synthwave_kriss.Synthwave_KRISS_3P_Pickup_MIC"))
    Skins.Add((Id=6945, Weapondef=class'KFWeapDef_Kriss', MIC_1P=("WEP_SkinSet23_MAT.synthwave_kriss.Synthwave_KRISS_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet23_MAT.synthwave_kriss.Synthwave_KRISS_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet23_MAT.synthwave_kriss.Synthwave_KRISS_3P_Pickup_MIC"))
    Skins.Add((Id=6944, Weapondef=class'KFWeapDef_Kriss', MIC_1P=("WEP_SkinSet23_MAT.synthwave_kriss.Synthwave_KRISS_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet23_MAT.synthwave_kriss.Synthwave_KRISS_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet23_MAT.synthwave_kriss.Synthwave_KRISS_3P_Pickup_MIC"))

//Synthwave Pulverizer
    Skins.Add((Id=6949, Weapondef=class'KFWeapDef_Pulverizer', MIC_1P=("WEP_SkinSet23_MAT.synthwave_pulverizer.Synthwave_Pulverizer_1P_Mint_MIC"), MIC_3P="WEP_SkinSet23_MAT.synthwave_pulverizer.Synthwave_Pulverizer_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet23_MAT.synthwave_pulverizer.Synthwave_Pulverizer_3P_Pickup_MIC"))
    Skins.Add((Id=6948, Weapondef=class'KFWeapDef_Pulverizer', MIC_1P=("WEP_SkinSet23_MAT.synthwave_pulverizer.Synthwave_Pulverizer_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet23_MAT.synthwave_pulverizer.Synthwave_Pulverizer_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet23_MAT.synthwave_pulverizer.Synthwave_Pulverizer_3P_Pickup_MIC"))
    Skins.Add((Id=6947, Weapondef=class'KFWeapDef_Pulverizer', MIC_1P=("WEP_SkinSet23_MAT.synthwave_pulverizer.Synthwave_Pulverizer_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet23_MAT.synthwave_pulverizer.Synthwave_Pulverizer_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet23_MAT.synthwave_pulverizer.Synthwave_Pulverizer_3P_Pickup_MIC"))

//Synthwave Scar
    Skins.Add((Id=6952, Weapondef=class'KFWeapDef_Scar', MIC_1P=("WEP_SkinSet23_MAT.synthwave_scar.Synthwave_SCAR_1P_Mint_MIC"), MIC_3P="WEP_SkinSet23_MAT.synthwave_scar.Synthwave_SCAR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet23_MAT.synthwave_scar.Synthwave_SCAR_3P_Pickup_MIC"))
    Skins.Add((Id=6951, Weapondef=class'KFWeapDef_Scar', MIC_1P=("WEP_SkinSet23_MAT.synthwave_scar.Synthwave_SCAR_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet23_MAT.synthwave_scar.Synthwave_SCAR_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet23_MAT.synthwave_scar.Synthwave_SCAR_3P_Pickup_MIC"))
    Skins.Add((Id=6950, Weapondef=class'KFWeapDef_Scar', MIC_1P=("WEP_SkinSet23_MAT.synthwave_scar.Synthwave_SCAR_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet23_MAT.synthwave_scar.Synthwave_SCAR_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet23_MAT.synthwave_scar.Synthwave_SCAR_3P_Pickup_MIC"))

//Yin Yang 9mm
    Skins.Add((Id=4310, Weapondef=class'KFWeapDef_9mm', MIC_1P=("WEP_SkinSet23_MAT.yinyang_9mm.YinYang_9MM_1P_Mint_MIC"), MIC_3P="WEP_SkinSet23_MAT.yinyang_9mm.YinYang_9MM_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet23_MAT.yinyang_9mm.YinYang_9MM_3P_Pickup_MIC"))
    Skins.Add((Id=4309, Weapondef=class'KFWeapDef_9mm', MIC_1P=("WEP_SkinSet23_MAT.yinyang_9mm.YinYang_9MM_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet23_MAT.yinyang_9mm.YinYang_9MM_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet23_MAT.yinyang_9mm.YinYang_9MM_3P_Pickup_MIC"))
    Skins.Add((Id=4308, Weapondef=class'KFWeapDef_9mm', MIC_1P=("WEP_SkinSet23_MAT.yinyang_9mm.YinYang_9MM_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet23_MAT.yinyang_9mm.YinYang_9MM_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet23_MAT.yinyang_9mm.YinYang_9MM_3P_Pickup_MIC"))

//Yin Yang Boomstick
    Skins.Add((Id=4313, Weapondef=class'KFWeapDef_DoubleBarrel', MIC_1P=("WEP_SkinSet23_MAT.yinyang_boomstick.YinYang_Boomstick_1P_Mint_MIC"), MIC_3P="WEP_SkinSet23_MAT.yinyang_boomstick.YinYang_Boomstick_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet23_MAT.yinyang_boomstick.YinYang_Boomstick_3P_Pickup_MIC"))
    Skins.Add((Id=4312, Weapondef=class'KFWeapDef_DoubleBarrel', MIC_1P=("WEP_SkinSet23_MAT.yinyang_boomstick.YinYang_Boomstick_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet23_MAT.yinyang_boomstick.YinYang_Boomstick_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet23_MAT.yinyang_boomstick.YinYang_Boomstick_3P_Pickup_MIC"))
    Skins.Add((Id=4311, Weapondef=class'KFWeapDef_DoubleBarrel', MIC_1P=("WEP_SkinSet23_MAT.yinyang_boomstick.YinYang_Boomstick_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet23_MAT.yinyang_boomstick.YinYang_Boomstick_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet23_MAT.yinyang_boomstick.YinYang_Boomstick_3P_Pickup_MIC"))

//Yin Yang Dragonsbreath
    Skins.Add((Id=4325, Weapondef=class'KFWeapDef_Dragonsbreath', MIC_1P=("WEP_SkinSet23_MAT.yinyang_dragonsbreath.YinYang_DragonsBreath_1P_Mint_MIC"), MIC_3P="WEP_SkinSet23_MAT.yinyang_dragonsbreath.YinYang_DragonsBreath_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet23_MAT.yinyang_dragonsbreath.YinYang_DragonsBreath_3P_Pickup_MIC"))
    Skins.Add((Id=4324, Weapondef=class'KFWeapDef_Dragonsbreath', MIC_1P=("WEP_SkinSet23_MAT.yinyang_dragonsbreath.YinYang_DragonsBreath_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet23_MAT.yinyang_dragonsbreath.YinYang_DragonsBreath_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet23_MAT.yinyang_dragonsbreath.YinYang_DragonsBreath_3P_Pickup_MIC"))
    Skins.Add((Id=4323, Weapondef=class'KFWeapDef_Dragonsbreath', MIC_1P=("WEP_SkinSet23_MAT.yinyang_dragonsbreath.YinYang_DragonsBreath_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet23_MAT.yinyang_dragonsbreath.YinYang_DragonsBreath_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet23_MAT.yinyang_dragonsbreath.YinYang_DragonsBreath_3P_Pickup_MIC"))

//Yin Yang Katana
    Skins.Add((Id=4316, Weapondef=class'KFWeapDef_Katana', MIC_1P=("WEP_SkinSet23_MAT.yinyang_katana.YinYang_Katana_1P_Mint_MIC"), MIC_3P="WEP_SkinSet23_MAT.yinyang_katana.YinYang_Katana_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet23_MAT.yinyang_katana.YinYang_Katana_3P_Pickup_MIC"))
    Skins.Add((Id=4315, Weapondef=class'KFWeapDef_Katana', MIC_1P=("WEP_SkinSet23_MAT.yinyang_katana.YinYang_Katana_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet23_MAT.yinyang_katana.YinYang_Katana_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet23_MAT.yinyang_katana.YinYang_Katana_3P_Pickup_MIC"))
    Skins.Add((Id=4314, Weapondef=class'KFWeapDef_Katana', MIC_1P=("WEP_SkinSet23_MAT.yinyang_katana.YinYang_Katana_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet23_MAT.yinyang_katana.YinYang_Katana_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet23_MAT.yinyang_katana.YinYang_Katana_3P_Pickup_MIC"))

//Yin Yang M1911
    Skins.Add((Id=6967, Weapondef=class'KFWeapDef_Colt1911', MIC_1P=("WEP_SkinSet23_MAT.yinyang_m1911.YinYang_M1911_1P_Mint_MIC"), MIC_3P="WEP_SkinSet23_MAT.yinyang_m1911.YinYang_M1911_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet23_MAT.yinyang_m1911.YinYang_M1911_3P_Pickup_MIC"))
    Skins.Add((Id=6966, Weapondef=class'KFWeapDef_Colt1911', MIC_1P=("WEP_SkinSet23_MAT.yinyang_m1911.YinYang_M1911_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet23_MAT.yinyang_m1911.YinYang_M1911_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet23_MAT.yinyang_m1911.YinYang_M1911_3P_Pickup_MIC"))
    Skins.Add((Id=6965, Weapondef=class'KFWeapDef_Colt1911', MIC_1P=("WEP_SkinSet23_MAT.yinyang_m1911.YinYang_M1911_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet23_MAT.yinyang_m1911.YinYang_M1911_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet23_MAT.yinyang_m1911.YinYang_M1911_3P_Pickup_MIC"))

//Yin Yang M79
    Skins.Add((Id=4322, Weapondef=class'KFWeapDef_M79', MIC_1P=("WEP_SkinSet23_MAT.yinyang_m79.YinYang_M79_1P_Mint_MIC"), MIC_3P="WEP_SkinSet23_MAT.yinyang_m79.YinYang_M79_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet23_MAT.yinyang_m79.YinYang_M79_3P_Pickup_MIC"))
    Skins.Add((Id=4321, Weapondef=class'KFWeapDef_M79', MIC_1P=("WEP_SkinSet23_MAT.yinyang_m79.YinYang_M79_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet23_MAT.yinyang_m79.YinYang_M79_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet23_MAT.yinyang_m79.YinYang_M79_3P_Pickup_MIC"))
    Skins.Add((Id=4320, Weapondef=class'KFWeapDef_M79', MIC_1P=("WEP_SkinSet23_MAT.yinyang_m79.YinYang_M79_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet23_MAT.yinyang_m79.YinYang_M79_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet23_MAT.yinyang_m79.YinYang_M79_3P_Pickup_MIC"))

//Yin Yang 500 Magnum Revolver
    Skins.Add((Id=6973, Weapondef=class'KFWeapDef_SW500', MIC_1P=("WEP_SkinSet23_MAT.yinyang_sw500.YinYang_SW500_1P_Mint_MIC"), MIC_3P="WEP_SkinSet23_MAT.yinyang_sw500.YinYang_SW500_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet23_MAT.yinyang_sw500.YinYang_SW500_3P_Pickup_MIC"))
    Skins.Add((Id=6972, Weapondef=class'KFWeapDef_SW500', MIC_1P=("WEP_SkinSet23_MAT.yinyang_sw500.YinYang_SW500_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet23_MAT.yinyang_sw500.YinYang_SW500_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet23_MAT.yinyang_sw500.YinYang_SW500_3P_Pickup_MIC"))
    Skins.Add((Id=6971, Weapondef=class'KFWeapDef_SW500', MIC_1P=("WEP_SkinSet23_MAT.yinyang_sw500.YinYang_SW500_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet23_MAT.yinyang_sw500.YinYang_SW500_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet23_MAT.yinyang_sw500.YinYang_SW500_3P_Pickup_MIC"))

//Yin Yang Winchester 1894
    Skins.Add((Id=4319, Weapondef=class'KFWeapDef_Winchester1894', MIC_1P=("WEP_SkinSet23_MAT.yinyang_winchester.YinYang_Winchester_1P_Mint_MIC"), MIC_3P="WEP_SkinSet23_MAT.yinyang_winchester.YinYang_Winchester_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet23_MAT.yinyang_winchester.YinYang_Winchester_3P_Pickup_MIC"))
    Skins.Add((Id=4318, Weapondef=class'KFWeapDef_Winchester1894', MIC_1P=("WEP_SkinSet23_MAT.yinyang_winchester.YinYang_Winchester_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet23_MAT.yinyang_winchester.YinYang_Winchester_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet23_MAT.yinyang_winchester.YinYang_Winchester_3P_Pickup_MIC"))
    Skins.Add((Id=4317, Weapondef=class'KFWeapDef_Winchester1894', MIC_1P=("WEP_SkinSet23_MAT.yinyang_winchester.YinYang_Winchester_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet23_MAT.yinyang_winchester.YinYang_Winchester_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet23_MAT.yinyang_winchester.YinYang_Winchester_3P_Pickup_MIC"))

//Prestige Pulverizer
    Skins.Add((Id=6776, Weapondef=class'KFWeapDef_Pulverizer', MIC_1P=("WEP_SkinSet_Prestige04_MAT.tier03.Prestige_Berserker_Pulverizer_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_Prestige04_MAT.tier03.Prestige_Berserker_Pulverizer_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_Prestige04_MAT.tier03.Prestige_Berserker_Pulverizer_3P_Pickup_MIC"))

//Prestige AK12
    Skins.Add((Id=6873, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet_Prestige04_MAT.tier03.Prestige_Commando_AK12_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_Prestige04_MAT.tier03.Prestige_Commando_AK12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_Prestige04_MAT.tier03.Prestige_Commando_AK12_3P_Pickup_MIC"))

//Prestige M16 M203
    Skins.Add((Id=6772, Weapondef=class'KFWeapDef_M16M203', MIC_1P=("WEP_SkinSet_Prestige04_MAT.tier03.Prestige_Demolition_M16_1P_Mint_MIC", "WEP_SkinSet_Prestige04_MAT.tier03.Prestige_Demolition_M203_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_Prestige04_MAT.tier03.Prestige_Demolition_M16M203_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_Prestige04_MAT.tier03.Prestige_Demolition_M16M203_3P_Pickup_MIC"))

//Prestige Flamethrower
    Skins.Add((Id=6769, Weapondef=class'KFWeapDef_FlameThrower', MIC_1P=("WEP_SkinSet_Prestige04_MAT.tier03.Prestige_Firebug_Flamethrower_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_Prestige04_MAT.tier03.Prestige_Firebug_Flamethrower_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_Prestige04_MAT.tier03.Prestige_Firebug_Flamethrower_3P_Pickup_MIC"))

//Prestige Desert Eagle
    Skins.Add((Id=6768, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet_Prestige04_MAT.tier03.Prestige_Gunslinger_Deagle_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_Prestige04_MAT.tier03.Prestige_Gunslinger_Deagle_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_Prestige04_MAT.tier03.Prestige_Gunslinger_Deagle_3P_Pickup_MIC"))

//Prestige HMTech-301 Shotgun
    Skins.Add((Id=6774, Weapondef=class'KFWeapDef_MedicShotgun', MIC_1P=("WEP_SkinSet_Prestige02_MAT.tier01.Prestige_Medic_MedicPistol_1P_Mint_MIC", "WEP_SkinSet_Prestige04_MAT.tier03.Prestige_Medic_MedicShotgun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_Prestige04_MAT.tier03.Prestige_Medic_MedicShotgun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_Prestige04_MAT.tier03.Prestige_Medic_MedicShotgun_3P_Pickup_MIC"))

//Prestige M14EBR
    Skins.Add((Id=6771, Weapondef=class'KFWeapDef_M14EBR', MIC_1P=("WEP_SkinSet_Prestige04_MAT.tier03.Prestige_Sharpshooter_M14EBR_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_Prestige04_MAT.tier03.Prestige_Sharpshooter_M14EBR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_Prestige04_MAT.tier03.Prestige_Sharpshooter_M14EBR_3P_Pickup_MIC"))

//Prestige M4
    Skins.Add((Id=6773, Weapondef=class'KFWeapDef_M4', MIC_1P=("WEP_SkinSet_Prestige04_MAT.tier03.Prestige_Support_M4_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_Prestige04_MAT.tier03.Prestige_Support_M4_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_Prestige04_MAT.tier03.Prestige_Support_M4_3P_Pickup_MIC"))

//Prestige VLAD-1000 Nailgun
    Skins.Add((Id=6775, Weapondef=class'KFWeapDef_NailGun', MIC_1P=("WEP_SkinSet_Prestige04_MAT.tier03.Prestige_Survivalist_Nailgun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_Prestige04_MAT.tier03.Prestige_Survivalist_Nailgun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_Prestige04_MAT.tier03.Prestige_Survivalist_Nailgun_3P_Pickup_MIC"))

//Prestige Heckler & Koch UMP
    Skins.Add((Id=6770, Weapondef=class'KFWeapDef_HK_UMP', MIC_1P=("WEP_SkinSet_Prestige04_MAT.tier03.Prestige_SWAT_HK_UMP_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_Prestige04_MAT.tier03.Prestige_SWAT_HK_UMP_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_Prestige04_MAT.tier03.Prestige_SWAT_HK_UMP_3P_Pickup_MIC"))

//Vault Vosh Heckler & Koch UMP
    Skins.Add((Id=6882, Weapondef=class'KFWeapDef_HK_UMP', MIC_1P=("WEP_SkinSet_VaultVosh06_MAT.vosh_hk_ump.Vault_Vosh_HK_UMP_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh06_MAT.vosh_hk_ump.Vault_Vosh_HK_UMP_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh06_MAT.vosh_hk_ump.Vault_Vosh_HK_UMP_3P_Pickup_MIC"))

//Vault Vosh Katana
    Skins.Add((Id=6883, Weapondef=class'KFWeapDef_Katana', MIC_1P=("WEP_SkinSet_VaultVosh06_MAT.vosh_katana.Vault_Vosh_Katana_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh06_MAT.vosh_katana.Vault_Vosh_Katana_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh06_MAT.vosh_katana.Vault_Vosh_Katana_3P_Pickup_MIC"))

//Vault Vosh HZ12
    Skins.Add((Id=6884, Weapondef=class'KFWeapDef_HZ12', MIC_1P=("WEP_SkinSet_VaultVosh06_MAT.vosh_hz12.Vault_Vosh_HZ12_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh06_MAT.vosh_hz12.Vault_Vosh_HZ12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh06_MAT.vosh_hz12.Vault_Vosh_HZ12_3P_Pickup_MIC"))

//Vault Vosh Husk Cannon
    Skins.Add((Id=6885, Weapondef=class'KFWeapDef_HuskCannon', MIC_1P=("WEP_SkinSet_VaultVosh06_MAT.vosh_huskcannon.Vault_Vosh_HuskCannon_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh06_MAT.vosh_huskcannon.Vault_Vosh_HuskCannon_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh06_MAT.vosh_huskcannon.Vault_Vosh_HuskCannon_3P_Pickup_MIC"))

//Vault Vosh Spitfire
    Skins.Add((Id=6886, Weapondef=class'KFWeapDef_Flaregun', MIC_1P=("WEP_SkinSet_VaultVosh06_MAT.vosh_flaregun.Vault_Vosh_FlareGun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh06_MAT.vosh_flaregun.Vault_Vosh_FlareGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh06_MAT.vosh_flaregun.Vault_Vosh_FlareGun_3P_Pickup_MIC"))

//Vault Vosh Fire Axe
    Skins.Add((Id=6887, Weapondef=class'KFWeapDef_FireAxe', MIC_1P=("WEP_SkinSet_VaultVosh06_MAT.vosh_fireaxe.Vault_Vosh_FireAxe_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh06_MAT.vosh_fireaxe.Vault_Vosh_FireAxe_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh06_MAT.vosh_fireaxe.Vault_Vosh_FireAxe_3P_Pickup_MIC"))

//Vault Vosh Centerfire
    Skins.Add((Id=6888, Weapondef=class'KFWeapDef_CenterfireMB464', MIC_1P=("WEP_SkinSet_VaultVosh06_MAT.vosh_centerfire.Vault_Vosh_Centerfire_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh06_MAT.vosh_centerfire.Vault_Vosh_Centerfire_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh06_MAT.vosh_centerfire.Vault_Vosh_Centerfire_3P_Pickup_MIC"))

//Vault Vosh Bone Crusher
    Skins.Add((Id=6889, Weapondef=class'KFWeapDef_MaceAndShield', MIC_1P=("WEP_SkinSet_VaultVosh06_MAT.vosh_maceandshield.Vault_Vosh_Mace_1P_Mint_MIC", "WEP_SkinSet_VaultVosh06_MAT.vosh_maceandshield.Vault_Vosh_Shield_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh06_MAT.vosh_maceandshield.Vault_Vosh_MaceAndShield_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh06_MAT.vosh_maceandshield.Vault_Vosh_MaceAndShield_3P_Pickup_MIC"))

//Vault Vosh Hemogoblin
    Skins.Add((Id=6890, Weapondef=class'KFWeapDef_Hemogoblin', MIC_1P=("WEP_SkinSet_VaultVosh06_MAT.vosh_bleeder.Vault_Vosh_Bleeder_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh06_MAT.vosh_bleeder.Vault_Vosh_Bleeder_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh06_MAT.vosh_bleeder.Vault_Vosh_Bleeder_3P_Pickup_MIC"))

//Vault Vosh AF2011-A1
    Skins.Add((Id=6891, Weapondef=class'KFWeapDef_AF2011', MIC_1P=("WEP_SkinSet_VaultVosh06_MAT.vosh_af2011.Vault_Vosh_AF2011_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh06_MAT.vosh_af2011.Vault_Vosh_AF2011_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh06_MAT.vosh_af2011.Vault_Vosh_AF2011_3P_Pickup_MIC"))

//Prestige Eviscerator
    Skins.Add((Id=7158, Weapondef=class'KFWeapDef_Eviscerator', MIC_1P=("wep_skinset_prestige05_mat.tier04.Prestige_Berserker_SawBlade_1P_Mint_MIC"), MIC_3P="wep_skinset_prestige05_mat.tier04.Prestige_Berserker_SawBlade_3P_Mint_MIC", MIC_Pickup="wep_skinset_prestige05_mat.tier04.Prestige_Berserker_SawBlade_3P_Pickup_MIC"))

//Prestige Scar
    Skins.Add((Id=7159, Weapondef=class'KFWeapDef_Scar', MIC_1P=("wep_skinset_prestige05_mat.tier04.Prestige_Commando_SCAR_1P_Mint_MIC"), MIC_3P="wep_skinset_prestige05_mat.tier04.Prestige_Commando_SCAR_3P_Mint_MIC", MIC_Pickup="wep_skinset_prestige05_mat.tier04.Prestige_Commando_SCAR_3P_Pickup_MIC"))

//Prestige RPG-7
    Skins.Add((Id=7160, Weapondef=class'KFWeapDef_RPG7', MIC_1P=("wep_skinset_prestige05_mat.tier04.Prestige_Demolition_RPG7_1P_Mint_MIC"), MIC_3P="wep_skinset_prestige05_mat.tier04.Prestige_Demolition_RPG7_3P_Mint_MIC", MIC_Pickup="wep_skinset_prestige05_mat.tier04.Prestige_Demolition_RPG7_3P_Pickup_MIC"))

//Prestige Microwave Gun
    Skins.Add((Id=7161, Weapondef=class'KFWeapDef_MicrowaveGun', MIC_1P=("wep_skinset_prestige05_mat.tier04.Prestige_Firebug_MicrowaveGun_1P_Mint_MIC"), MIC_3P="wep_skinset_prestige05_mat.tier04.Prestige_Firebug_MicrowaveGun_3P_Mint_MIC", MIC_Pickup="wep_skinset_prestige05_mat.tier04.Prestige_Firebug_MicrowaveGun_3P_Pickup_MIC"))

//Prestige 500 Magnum Revolver
    Skins.Add((Id=7163, Weapondef=class'KFWeapDef_SW500', MIC_1P=("wep_skinset_prestige05_mat.tier04.Prestige_Gunslinger_SW500_1P_Mint_MIC"), MIC_3P="wep_skinset_prestige05_mat.tier04.Prestige_Gunslinger_SW500_3P_Mint_MIC", MIC_Pickup="wep_skinset_prestige05_mat.tier04.Prestige_Gunslinger_SW500_3P_Pickup_MIC"))

//Prestige HMTech-401 Assault Rifle
    Skins.Add((Id=7164, Weapondef=class'KFWeapDef_MedicRifle', MIC_1P=("wep_skinset_prestige05_mat.tier04.Prestige_Medic_MedicAssault_1P_Mint_MIC", "WEP_SkinSet_Prestige02_MAT.tier01.Prestige_Medic_MedicPistol_1P_Mint_MIC" ), MIC_3P="wep_skinset_prestige05_mat.tier04.Prestige_Medic_MedicAssault_3P_Mint_MIC", MIC_Pickup="wep_skinset_prestige05_mat.tier04.Prestige_Medic_MedicAssault_3P_Pickup_MIC"))

//Prestige Railgun
    Skins.Add((Id=7165, Weapondef=class'KFWeapDef_Railgun', MIC_1P=("wep_skinset_prestige05_mat.tier04.Prestige_Sharpshooter_Railgun_1P_Mint_MIC", "wep_skinset_prestige05_mat.tier04.Prestige_Sharpshooter_Railgun_Scope_1P_Mint_MIC"), MIC_3P="wep_skinset_prestige05_mat.tier04.Prestige_Sharpshooter_Railgun_3P_Mint_MIC", MIC_Pickup="wep_skinset_prestige05_mat.tier04.Prestige_Sharpshooter_Railgun_3P_Pickup_MIC"))

//Prestige AA12
    Skins.Add((Id=7166, Weapondef=class'KFWeapDef_AA12', MIC_1P=("wep_skinset_prestige05_mat.tier04.Prestige_Support_AA12_1P_Mint_MIC"), MIC_3P="wep_skinset_prestige05_mat.tier04.Prestige_Support_AA12_3P_Mint_MIC", MIC_Pickup="wep_skinset_prestige05_mat.tier04.Prestige_Support_AA12_3P_Pickup_MIC"))

//Prestige Killerwatt
    Skins.Add((Id=7167, Weapondef=class'KFWeapDef_LazerCutter', MIC_1P=("wep_skinset_prestige05_mat.tier04.Prestige_Survivalist_LaserCutter_Scope_1P_Mint_MIC", "wep_skinset_prestige05_mat.tier04.Prestige_Survivalist_LaserCutter_1P_Mint_MIC"), MIC_3P="wep_skinset_prestige05_mat.tier04.Prestige_Survivalist_LaserCutter_3P_Mint_MIC", MIC_Pickup="wep_skinset_prestige05_mat.tier04.Prestige_Survivalist_LaserCutter_3P_Pickup_MIC"))

//Prestige Kriss SMG
    Skins.Add((Id=7168, Weapondef=class'KFWeapDef_Kriss', MIC_1P=("wep_skinset_prestige05_mat.tier04.Prestige_SWAT_KRISS_1P_Mint_MIC", "wep_skinset_prestige05_mat.tier04.Prestige_SWAT_KRISS_Scope_1P_Mint_MIC"), MIC_3P="wep_skinset_prestige05_mat.tier04.Prestige_SWAT_KRISS_3P_Mint_MIC", MIC_Pickup="wep_skinset_prestige05_mat.tier04.Prestige_SWAT_KRISS_3P_Pickup_MIC"))

//Vault Vosh FN FAL
    Skins.Add((Id=7169, Weapondef=class'KFWeapDef_FNFAL', MIC_1P=("wep_skinset_vaultvosh07_mat.vosh_fnfal.Vault_Vosh_FNFAL_1P_Mint_MIC"), MIC_3P="wep_skinset_vaultvosh07_mat.vosh_fnfal.Vault_Vosh_FNFAL_3P_Mint_MIC", MIC_Pickup="wep_skinset_vaultvosh07_mat.vosh_fnfal.Vault_Vosh_FNFAL_3P_Pickup_MIC"))

//Vault Vosh BattleAxe
    Skins.Add((Id=7170, Weapondef=class'KFWeapDef_AbominationAxe', MIC_1P=("wep_skinset_vaultvosh07_mat.vosh_krampusaxe.Vault_Vosh_KrampusAxe_1P_Mint_MIC"), MIC_3P="wep_skinset_vaultvosh07_mat.vosh_krampusaxe.Vault_Vosh_KrampusAxe_3P_Mint_MIC", MIC_Pickup="wep_skinset_vaultvosh07_mat.vosh_krampusaxe.Vault_Vosh_KrampusAxe_3P_Pickup_MIC"))

//Vault Vosh M16 M203
    Skins.Add((Id=7171, Weapondef=class'KFWeapDef_M16M203', MIC_1P=("wep_skinset_vaultvosh07_mat.vosh_m16m203.Vault_Vosh_M16_1P_Mint_MIC", "wep_skinset_vaultvosh07_mat.vosh_m16m203.Vault_Vosh_M203_1P_Mint_MIC"), MIC_3P="wep_skinset_vaultvosh07_mat.vosh_m16m203.Vault_Vosh_M16M203_3P_Mint_MIC", MIC_Pickup="wep_skinset_vaultvosh07_mat.vosh_m16m203.Vault_Vosh_M16M203_3P_Pickup_MIC"))

//Vault Vosh M32
    Skins.Add((Id=7172, Weapondef=class'KFWeapDef_M32', MIC_1P=("wep_skinset_vaultvosh07_mat.Vosh_M32.Vault_Vosh_M32_1P_Mint_MIC"), MIC_3P="wep_skinset_vaultvosh07_mat.Vosh_M32.Vault_Vosh_M32_3P_Mint_MIC", MIC_Pickup="wep_skinset_vaultvosh07_mat.Vosh_M32.Vault_Vosh_M32_3P_Pickup_MIC"))

//Vault Vosh MAC 10
    Skins.Add((Id=7173, Weapondef=class'KFWeapDef_Mac10', MIC_1P=("wep_skinset_vaultvosh07_mat.vosh_mac10.Vault_Vosh_MAC10_1P_Mint_MIC"), MIC_3P="wep_skinset_vaultvosh07_mat.vosh_mac10.Vault_Vosh_MAC10_3P_Mint_MIC", MIC_Pickup="wep_skinset_vaultvosh07_mat.vosh_mac10.Vault_Vosh_MAC10_3P_Pickup_MIC"))

//Dragon & Koi Crovel
    Skins.Add((Id=7174, Weapondef=class'KFWeapDef_Crovel', MIC_1P=("wep_skinset_dragonkoi01_mat.dragonkoi_crovel.DragonKoi_Crovel_1P_Mint_MIC"), MIC_3P="wep_skinset_dragonkoi01_mat.dragonkoi_crovel.DragonKoi_Crovel_3P_Mint_MIC", MIC_Pickup="wep_skinset_dragonkoi01_mat.dragonkoi_crovel.DragonKoi_Crovel_3P_Pickup_MIC"))

//Dragon & Koi AR15
    Skins.Add((Id=7175, Weapondef=class'KFWeapDef_AR15', MIC_1P=("wep_skinset_dragonkoi01_mat.dragonkoi_ar15.DragonKoi_AR15_1P_Mint_MIC"), MIC_3P="wep_skinset_dragonkoi01_mat.dragonkoi_ar15.DragonKoi_AR15_3P_Mint_MIC", MIC_Pickup="wep_skinset_dragonkoi01_mat.dragonkoi_ar15.DragonKoi_AR15_3P_Pickup_MIC"))

//Dragon & Koi HX25
    Skins.Add((Id=7176, Weapondef=class'KFWeapDef_HX25', MIC_1P=("wep_skinset_dragonkoi01_mat.dragonkoi_hx25.DragonKoi_HX25_1P_Mint_MIC"), MIC_3P="wep_skinset_dragonkoi01_mat.dragonkoi_hx25.DragonKoi_HX25_3P_Mint_MIC", MIC_Pickup="wep_skinset_dragonkoi01_mat.dragonkoi_hx25.DragonKoi_HX25_3P_Pickup_MIC"))

//Dragon & Koi Caulk n Burn
    Skins.Add((Id=7177, Weapondef=class'KFWeapDef_CaulkBurn', MIC_1P=("wep_skinset_dragonkoi01_mat.dragonkoi_caulknburn.DragonKoi_CaulknBurn_1P_Mint_MIC"), MIC_3P="wep_skinset_dragonkoi01_mat.dragonkoi_caulknburn.DragonKoi_CaulknBurn_3P_Mint_MIC", MIC_Pickup="wep_skinset_dragonkoi01_mat.dragonkoi_caulknburn.DragonKoi_CaulknBurn_3P_Pickup_MIC"))

//Dragon & Koi 1858 Revolver
    Skins.Add((Id=7178, Weapondef=class'KFWeapDef_Remington1858', MIC_1P=("wep_skinset_dragonkoi01_mat.dragonkoi_remington1858.DragonKoi_Remington1858_1P_Mint_MIC"), MIC_3P="wep_skinset_dragonkoi01_mat.dragonkoi_remington1858.DragonKoi_Remington1858_3P_Mint_MIC", MIC_Pickup="wep_skinset_dragonkoi01_mat.dragonkoi_remington1858.DragonKoi_Remington1858_3P_Pickup_MIC"))

//Dragon & Koi HMTech-101 Pistol
    Skins.Add((Id=7179, Weapondef=class'KFWeapDef_MedicPistol', MIC_1P=("wep_skinset_dragonkoi01_mat.dragonkoi_medicpistol.DragonKoi_MedicPistol_1P_Mint_MIC"), MIC_3P="wep_skinset_dragonkoi01_mat.dragonkoi_medicpistol.DragonKoi_MedicPistol_3P_Mint_MIC", MIC_Pickup="wep_skinset_dragonkoi01_mat.dragonkoi_medicpistol.DragonKoi_MedicPistol_3P_Pickup_MIC"))

//Dragon & Koi Winchester 1894
    Skins.Add((Id=7180, Weapondef=class'KFWeapDef_Winchester1894', MIC_1P=("wep_skinset_dragonkoi01_mat.dragonkoi_winchester.DragonKoi_Winchester_1P_Mint_MIC"), MIC_3P="wep_skinset_dragonkoi01_mat.dragonkoi_winchester.DragonKoi_Winchester_3P_Mint_MIC", MIC_Pickup="wep_skinset_dragonkoi01_mat.dragonkoi_winchester.DragonKoi_Winchester_3P_Pickup_MIC"))

//Dragon & Koi SG 500
    Skins.Add((Id=7181, Weapondef=class'KFWeapDef_MB500', MIC_1P=("wep_skinset_dragonkoi01_mat.dragonkoi_mb500.DragonKoi_MB500_1P_Mint_MIC"), MIC_3P="wep_skinset_dragonkoi01_mat.dragonkoi_mb500.DragonKoi_MB500_3P_Mint_MIC", MIC_Pickup="wep_skinset_dragonkoi01_mat.dragonkoi_mb500.DragonKoi_MB500_3P_Pickup_MIC"))

//Dragon & Koi MP7
    Skins.Add((Id=7182, Weapondef=class'KFWeapDef_MP7', MIC_1P=("wep_skinset_dragonkoi01_mat.dragonkoi_mp7.DragonKoi_MP7_1P_Mint_MIC", "wep_skinset_dragonkoi01_mat.dragonkoi_mp7.DragonKoi_MP7_Sight_1P_MIC"), MIC_3P="wep_skinset_dragonkoi01_mat.dragonkoi_mp7.DragonKoi_MP7_3P_Mint_MIC", MIC_Pickup="wep_skinset_dragonkoi01_mat.dragonkoi_mp7.DragonKoi_MP7_3P_Pickup_MIC"))

//Dragon & Koi 9MM
    Skins.Add((Id=7183, Weapondef=class'KFWeapDef_9mm', MIC_1P=("wep_skinset_dragonkoi01_mat.dragonkoi_9mm.DragonKoi_9mm_1P_Mint_MIC"), MIC_3P="wep_skinset_dragonkoi01_mat.dragonkoi_9mm.DragonKoi_9mm_3P_Mint_MIC", MIC_Pickup="wep_skinset_dragonkoi01_mat.dragonkoi_9mm.DragonKoi_9mm_3P_Pickup_MIC"))

//Dragon & Koi Katana
    Skins.Add((Id=7184, Weapondef=class'KFWeapDef_Katana', MIC_1P=("wep_skinset_dragonkoi01_mat.dragonkoi_katana.DragonKoi_Katana_1P_Mint_MIC"), MIC_3P="wep_skinset_dragonkoi01_mat.dragonkoi_katana.DragonKoi_Katana_3P_Mint_MIC", MIC_Pickup="wep_skinset_dragonkoi01_mat.dragonkoi_katana.DragonKoi_Katana_3P_Pickup_MIC"))

//Dragon & Koi L85A2
    Skins.Add((Id=7185, Weapondef=class'KFWeapDef_Bullpup', MIC_1P=("wep_skinset_dragonkoi01_mat.dragonkoi_l85a2.DragonKoi_L85A2_1P_Mint_MIC", "wep_skinset_dragonkoi01_mat.dragonkoi_l85a2.DragonKoi_L85A2_Sight_1P_Mint_MIC"), MIC_3P="wep_skinset_dragonkoi01_mat.dragonkoi_l85a2.DragonKoi_L85A2_3P_Mint_MIC", MIC_Pickup="wep_skinset_dragonkoi01_mat.dragonkoi_l85a2.DragonKoi_L85A2_3P_Pickup_MIC"))

//Dragon & Koi M79
    Skins.Add((Id=7186, Weapondef=class'KFWeapDef_M79', MIC_1P=("wep_skinset_dragonkoi01_mat.dragonkoi_m79.DragonKoi_M79_1P_Mint_MIC"), MIC_3P="wep_skinset_dragonkoi01_mat.dragonkoi_m79.DragonKoi_M79_3P_Mint_MIC", MIC_Pickup="wep_skinset_dragonkoi01_mat.dragonkoi_m79.DragonKoi_M79_3P_Pickup_MIC"))

//Dragon & Koi Spitfire
    Skins.Add((Id=7238, Weapondef=class'KFWeapDef_Flaregun', MIC_1P=("wep_skinset_dragonkoi01_mat.dragonkoi_flaregun.DragonKoi_FlareGun_1P_Mint_MIC"), MIC_3P="wep_skinset_dragonkoi01_mat.dragonkoi_flaregun.DragonKoi_FlareGun_3P_Mint_MIC", MIC_Pickup="wep_skinset_dragonkoi01_mat.dragonkoi_flaregun.DragonKoi_FlareGun_3P_Pickup_MIC"))

//Dragon & Koi M1911
    Skins.Add((Id=7188, Weapondef=class'KFWeapDef_Colt1911', MIC_1P=("wep_skinset_dragonkoi01_mat.dragonkoi_m1911.DragonKoi_M1911_1P_Mint_MIC"), MIC_3P="wep_skinset_dragonkoi01_mat.dragonkoi_m1911.DragonKoi_M1911_3P_Mint_MIC", MIC_Pickup="wep_skinset_dragonkoi01_mat.dragonkoi_m1911.DragonKoi_M1911_3P_Pickup_MIC"))

//Dragon & Koi HMTech-201 SMG
    Skins.Add((Id=7189, Weapondef=class'KFWeapDef_MedicSMG', MIC_1P=("wep_skinset_dragonkoi01_mat.dragonkoi_medicpistol.DragonKoi_MedicPistol_1P_Mint_MIC", "wep_skinset_dragonkoi01_mat.dragonkoi_medicsmg.DragonKoi_MedicSMG_1P_Mint_MIC"), MIC_3P="wep_skinset_dragonkoi01_mat.dragonkoi_medicsmg.DragonKoi_MedicSMG_3P_Mint_MIC", MIC_Pickup="wep_skinset_dragonkoi01_mat.dragonkoi_medicsmg.DragonKoi_MedicSMG_3P_Pickup_MIC"))

//Dragon & Koi Crossbow
    Skins.Add((Id=7190, Weapondef=class'KFWeapDef_Crossbow', MIC_1P=("wep_skinset_dragonkoi01_mat.dragonkoi_crossbow.DragonKoi_Crossbow_1P_Mint_MIC"), MIC_3P="wep_skinset_dragonkoi01_mat.dragonkoi_crossbow.DragonKoi_Crossbow_3P_Mint_MIC", MIC_Pickup="wep_skinset_dragonkoi01_mat.dragonkoi_crossbow.DragonKoi_Crossbow_3P_Pickup_MIC"))

//Dragon & Koi Boomstick
    Skins.Add((Id=7191, Weapondef=class'KFWeapDef_DoubleBarrel', MIC_1P=("wep_skinset_dragonkoi01_mat.dragonkoi_doublebarrel.DragonKoi_DoubleBarrel_1P_Mint_MIC"), MIC_3P="wep_skinset_dragonkoi01_mat.dragonkoi_doublebarrel.DragonKoi_DoubleBarrel_3P_Mint_MIC", MIC_Pickup="wep_skinset_dragonkoi01_mat.dragonkoi_doublebarrel.DragonKoi_DoubleBarrel_3P_Pickup_MIC"))

//Dragon & Koi Tommy Gun
    Skins.Add((Id=7192, Weapondef=class'KFWeapDef_Thompson', MIC_1P=("wep_skinset_dragonkoi01_mat.dragonkoi_tommygun.DragonKoi_TommyGun_1P_Mint_MIC"), MIC_3P="wep_skinset_dragonkoi01_mat.dragonkoi_tommygun.DragonKoi_TommyGun_3P_Mint_MIC", MIC_Pickup="wep_skinset_dragonkoi01_mat.dragonkoi_tommygun.DragonKoi_TommyGun_3P_Pickup_MIC"))

//Dragon & Koi MP5RAS
    Skins.Add((Id=7193, Weapondef=class'KFWeapDef_MP5RAS', MIC_1P=("wep_skinset_dragonkoi01_mat.dragonkoi_mp5ras.DragonKoi_MP5RAS_1P_Mint_MIC"), MIC_3P="wep_skinset_dragonkoi01_mat.dragonkoi_mp5ras.DragonKoi_MP5RAS_3P_Mint_MIC", MIC_Pickup="wep_skinset_dragonkoi01_mat.dragonkoi_mp5ras.DragonKoi_MP5RAS_3P_Pickup_MIC"))

//Steampunk Tommy Gun
    Skins.Add((Id=7196, Weapondef=class'KFWeapDef_Thompson', MIC_1P=("WEP_SkinSet25_MAT.steampunk_tommygun.Steampunk_TommyGun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet25_MAT.steampunk_tommygun.Steampunk_TommyGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet25_MAT.steampunk_tommygun.Steampunk_TommyGun_3P_Pickup_MIC"))
    Skins.Add((Id=7195, Weapondef=class'KFWeapDef_Thompson', MIC_1P=("WEP_SkinSet25_MAT.steampunk_tommygun.Steampunk_TommyGun_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet25_MAT.steampunk_tommygun.Steampunk_TommyGun_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet25_MAT.steampunk_tommygun.Steampunk_TommyGun_3P_Pickup_MIC"))
    Skins.Add((Id=7194, Weapondef=class'KFWeapDef_Thompson', MIC_1P=("WEP_SkinSet25_MAT.steampunk_tommygun.Steampunk_TommyGun_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet25_MAT.steampunk_tommygun.Steampunk_TommyGun_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet25_MAT.steampunk_tommygun.Steampunk_TommyGun_3P_Pickup_MIC"))

//Steampunk Dragonsbreath
    Skins.Add((Id=7199, Weapondef=class'KFWeapDef_Dragonsbreath', MIC_1P=("WEP_SkinSet25_MAT.steampunk_dragonsbreath.Steampunk_Dragonsbreath_1P_Mint_MIC"), MIC_3P="WEP_SkinSet25_MAT.steampunk_dragonsbreath.Steampunk_DragonsBreath_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet25_MAT.steampunk_dragonsbreath.Steampunk_DragonsBreath_3P_Pickup_MIC"))
    Skins.Add((Id=7198, Weapondef=class'KFWeapDef_Dragonsbreath', MIC_1P=("WEP_SkinSet25_MAT.steampunk_dragonsbreath.Steampunk_Dragonsbreath_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet25_MAT.steampunk_dragonsbreath.Steampunk_DragonsBreath_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet25_MAT.steampunk_dragonsbreath.Steampunk_DragonsBreath_3P_Pickup_MIC"))
    Skins.Add((Id=7197, Weapondef=class'KFWeapDef_Dragonsbreath', MIC_1P=("WEP_SkinSet25_MAT.steampunk_dragonsbreath.Steampunk_Dragonsbreath_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet25_MAT.steampunk_dragonsbreath.Steampunk_DragonsBreath_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet25_MAT.steampunk_dragonsbreath.Steampunk_DragonsBreath_3P_Pickup_MIC"))

//Steampunk 500 Magnum Revolver
    Skins.Add((Id=7202, Weapondef=class'KFWeapDef_SW500', MIC_1P=("WEP_SkinSet25_MAT.steampunk_sw500.Steampunk_SW500_1P_Mint_MIC"), MIC_3P="WEP_SkinSet25_MAT.steampunk_sw500.Steampunk_SW500_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet25_MAT.steampunk_sw500.Steampunk_SW500_3P_Pickup_MIC"))
    Skins.Add((Id=7201, Weapondef=class'KFWeapDef_SW500', MIC_1P=("WEP_SkinSet25_MAT.steampunk_sw500.Steampunk_SW500_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet25_MAT.steampunk_sw500.Steampunk_SW500_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet25_MAT.steampunk_sw500.Steampunk_SW500_3P_Pickup_MIC"))
    Skins.Add((Id=7200, Weapondef=class'KFWeapDef_SW500', MIC_1P=("WEP_SkinSet25_MAT.steampunk_sw500.Steampunk_SW500_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet25_MAT.steampunk_sw500.Steampunk_SW500_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet25_MAT.steampunk_sw500.Steampunk_SW500_3P_Pickup_MIC"))

//Steampunk Winchester 1894
    Skins.Add((Id=7205, Weapondef=class'KFWeapDef_Winchester1894', MIC_1P=("WEP_SkinSet25_MAT.steampunk_winchester.Steampunk_Winchester_1P_Mint_MIC"), MIC_3P="WEP_SkinSet25_MAT.steampunk_winchester.Steampunk_Winchester_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet25_MAT.steampunk_winchester.Steampunk_Winchester_3P_Pickup_MIC"))
    Skins.Add((Id=7204, Weapondef=class'KFWeapDef_Winchester1894', MIC_1P=("WEP_SkinSet25_MAT.steampunk_winchester.Steampunk_Winchester_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet25_MAT.steampunk_winchester.Steampunk_Winchester_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet25_MAT.steampunk_winchester.Steampunk_Winchester_3P_Pickup_MIC"))
    Skins.Add((Id=7203, Weapondef=class'KFWeapDef_Winchester1894', MIC_1P=("WEP_SkinSet25_MAT.steampunk_winchester.Steampunk_Winchester_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet25_MAT.steampunk_winchester.Steampunk_Winchester_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet25_MAT.steampunk_winchester.Steampunk_Winchester_3P_Pickup_MIC"))

//Steampunk M79
    Skins.Add((Id=7208, Weapondef=class'KFWeapDef_M79', MIC_1P=("WEP_SkinSet25_MAT.steampunk_m79.Steampunk_M79_1P_Mint_MIC"), MIC_3P="WEP_SkinSet25_MAT.steampunk_m79.Steampunk_M79_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet25_MAT.steampunk_m79.Steampunk_M79_3P_Pickup_MIC"))
    Skins.Add((Id=7207, Weapondef=class'KFWeapDef_M79', MIC_1P=("WEP_SkinSet25_MAT.steampunk_m79.Steampunk_M79_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet25_MAT.steampunk_m79.Steampunk_M79_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet25_MAT.steampunk_m79.Steampunk_M79_3P_Pickup_MIC"))
    Skins.Add((Id=7206, Weapondef=class'KFWeapDef_M79', MIC_1P=("WEP_SkinSet25_MAT.steampunk_m79.Steampunk_M79_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet25_MAT.steampunk_m79.Steampunk_M79_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet25_MAT.steampunk_m79.Steampunk_M79_3P_Pickup_MIC"))

//Steampunk Zweihander
    Skins.Add((Id=7211, Weapondef=class'KFWeapDef_Zweihander', MIC_1P=("WEP_SkinSet25_MAT.steampunk_zweihander.Steampunk_Zweihander_1P_Mint_MIC"), MIC_3P="WEP_SkinSet25_MAT.steampunk_zweihander.Steampunk_Zweihander_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet25_MAT.steampunk_zweihander.Steampunk_Zweihander_3P_Pickup_MIC"))
    Skins.Add((Id=7210, Weapondef=class'KFWeapDef_Zweihander', MIC_1P=("WEP_SkinSet25_MAT.steampunk_zweihander.Steampunk_Zweihander_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet25_MAT.steampunk_zweihander.Steampunk_Zweihander_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet25_MAT.steampunk_zweihander.Steampunk_Zweihander_3P_Pickup_MIC"))
    Skins.Add((Id=7209, Weapondef=class'KFWeapDef_Zweihander', MIC_1P=("WEP_SkinSet25_MAT.steampunk_zweihander.Steampunk_Zweihander_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet25_MAT.steampunk_zweihander.Steampunk_Zweihander_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet25_MAT.steampunk_zweihander.Steampunk_Zweihander_3P_Pickup_MIC"))

//Steampunk MP5RAS
    Skins.Add((Id=7214, Weapondef=class'KFWeapDef_MP5RAS', MIC_1P=("WEP_SkinSet25_MAT.steampunk_mp5ras.Steampunk_MP5RAS_1P_Mint_MIC"), MIC_3P="WEP_SkinSet25_MAT.steampunk_mp5ras.Steampunk_MP5RAS_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet25_MAT.steampunk_mp5ras.Steampunk_MP5RAS_3P_Pickup_MIC"))
    Skins.Add((Id=7213, Weapondef=class'KFWeapDef_MP5RAS', MIC_1P=("WEP_SkinSet25_MAT.steampunk_mp5ras.Steampunk_MP5RAS_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet25_MAT.steampunk_mp5ras.Steampunk_MP5RAS_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet25_MAT.steampunk_mp5ras.Steampunk_MP5RAS_3P_Pickup_MIC"))
    Skins.Add((Id=7212, Weapondef=class'KFWeapDef_MP5RAS', MIC_1P=("WEP_SkinSet25_MAT.steampunk_mp5ras.Steampunk_MP5RAS_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet25_MAT.steampunk_mp5ras.Steampunk_MP5RAS_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet25_MAT.steampunk_mp5ras.Steampunk_MP5RAS_3P_Pickup_MIC"))

//Steampunk AA12
    Skins.Add((Id=7217, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet25_MAT.steampunk_aa12.Steampunk_AA12_1P_Mint_MIC"), MIC_3P="WEP_SkinSet25_MAT.steampunk_aa12.Steampunk_AA12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet25_MAT.steampunk_aa12.Steampunk_AA12_3P_Pickup_MIC"))
    Skins.Add((Id=7216, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet25_MAT.steampunk_aa12.Steampunk_AA12_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet25_MAT.steampunk_aa12.Steampunk_AA12_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet25_MAT.steampunk_aa12.Steampunk_AA12_3P_Pickup_MIC"))
    Skins.Add((Id=7215, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet25_MAT.steampunk_aa12.Steampunk_AA12_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet25_MAT.steampunk_aa12.Steampunk_AA12_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet25_MAT.steampunk_aa12.Steampunk_AA12_3P_Pickup_MIC"))

//Steampunk MAC 10
    Skins.Add((Id=7220, Weapondef=class'KFWeapDef_Mac10', MIC_1P=("WEP_SkinSet25_MAT.steampunk_mac10.Steampunk_MAC10_1P_Mint_MIC"), MIC_3P="WEP_SkinSet25_MAT.steampunk_mac10.Steampunk_MAC10_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet25_MAT.steampunk_mac10.Steampunk_MAC10_3P_Pickup_MIC"))
    Skins.Add((Id=7219, Weapondef=class'KFWeapDef_Mac10', MIC_1P=("WEP_SkinSet25_MAT.steampunk_mac10.Steampunk_MAC10_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet25_MAT.steampunk_mac10.Steampunk_MAC10_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet25_MAT.steampunk_mac10.Steampunk_MAC10_3P_Pickup_MIC"))
    Skins.Add((Id=7218, Weapondef=class'KFWeapDef_Mac10', MIC_1P=("WEP_SkinSet25_MAT.steampunk_mac10.Steampunk_MAC10_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet25_MAT.steampunk_mac10.Steampunk_MAC10_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet25_MAT.steampunk_mac10.Steampunk_MAC10_3P_Pickup_MIC"))

//Steampunk M99
    Skins.Add((Id=7223, Weapondef=class'KFWeapDef_M99', MIC_1P=("WEP_SkinSet25_MAT.steampunk_m99.Steampunk_M99_1P_Mint_MIC", "WEP_SkinSet25_MAT.steampunk_m99.Steampunk_M99_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet25_MAT.steampunk_m99.Steampunk_M99_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet25_MAT.steampunk_m99.Steampunk_M99_3P_Pickup_MIC"))
    Skins.Add((Id=7222, Weapondef=class'KFWeapDef_M99', MIC_1P=("WEP_SkinSet25_MAT.steampunk_m99.Steampunk_M99_1P_FieldTested_MIC", "WEP_SkinSet25_MAT.steampunk_m99.Steampunk_M99_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet25_MAT.steampunk_m99.Steampunk_M99_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet25_MAT.steampunk_m99.Steampunk_M99_3P_Pickup_MIC"))
    Skins.Add((Id=7221, Weapondef=class'KFWeapDef_M99', MIC_1P=("WEP_SkinSet25_MAT.steampunk_m99.Steampunk_M99_1P_BattleScarred_MIC", "WEP_SkinSet25_MAT.steampunk_m99.Steampunk_M99_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet25_MAT.steampunk_m99.Steampunk_M99_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet25_MAT.steampunk_m99.Steampunk_M99_3P_Pickup_MIC"))

//Steampunk Desert Eagle
    Skins.Add((Id=7226, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet25_MAT.steampunk_deagle.Steampunk_Deagle_1P_Mint_MIC"), MIC_3P="WEP_SkinSet25_MAT.steampunk_deagle.Steampunk_Deagle_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet25_MAT.steampunk_deagle.Steampunk_Deagle_3P_Pickup_MIC"))
    Skins.Add((Id=7225, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet25_MAT.steampunk_deagle.Steampunk_Deagle_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet25_MAT.steampunk_deagle.Steampunk_Deagle_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet25_MAT.steampunk_deagle.Steampunk_Deagle_3P_Pickup_MIC"))
    Skins.Add((Id=7224, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet25_MAT.steampunk_deagle.Steampunk_Deagle_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet25_MAT.steampunk_deagle.Steampunk_Deagle_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet25_MAT.steampunk_deagle.Steampunk_Deagle_3P_Pickup_MIC"))

//Steampunk Tommy Gun
    Skins.Add((Id=7227, Weapondef=class'KFWeapDef_Thompson', MIC_1P=("WEP_SkinSet25_MAT.royal_tommygun.Royal_TommyGun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet25_MAT.royal_tommygun.Royal_TommyGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet25_MAT.royal_tommygun.Royal_TommyGun_3P_Pickup_MIC"))

//Steampunk Dragonsbreath
    Skins.Add((Id=7228, Weapondef=class'KFWeapDef_Dragonsbreath', MIC_1P=("WEP_SkinSet25_MAT.royal_dragonsbreath.Royal_Dragonsbreath_1P_Mint_MIC"), MIC_3P="WEP_SkinSet25_MAT.royal_dragonsbreath.Royal_DragonsBreath_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet25_MAT.royal_dragonsbreath.Royal_DragonsBreath_3P_Pickup_MIC"))

//Steampunk 500 Magnum Revolver
    Skins.Add((Id=7229, Weapondef=class'KFWeapDef_SW500', MIC_1P=("WEP_SkinSet25_MAT.royal_sw500.Royal_SW500_1P_Mint_MIC"), MIC_3P="WEP_SkinSet25_MAT.royal_sw500.Royal_SW500_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet25_MAT.royal_sw500.Royal_SW500_3P_Pickup_MIC"))

//Steampunk Winchester 1894
    Skins.Add((Id=7230, Weapondef=class'KFWeapDef_Winchester1894', MIC_1P=("WEP_SkinSet25_MAT.royal_winchester.Royal_Winchester_1P_Mint_MIC"), MIC_3P="WEP_SkinSet25_MAT.royal_winchester.Royal_Winchester_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet25_MAT.royal_winchester.Royal_Winchester_3P_Pickup_MIC"))

//Steampunk M79
    Skins.Add((Id=7231, Weapondef=class'KFWeapDef_M79', MIC_1P=("WEP_SkinSet25_MAT.royal_m79.Royal_M79_1P_Mint_MIC"), MIC_3P="WEP_SkinSet25_MAT.royal_m79.Royal_M79_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet25_MAT.royal_m79.Royal_M79_3P_Pickup_MIC"))

//Steampunk Zweihander
    Skins.Add((Id=7232, Weapondef=class'KFWeapDef_Zweihander', MIC_1P=("WEP_SkinSet25_MAT.royal_zweihander.Royal_Zweihander_1P_Mint_MIC"), MIC_3P="WEP_SkinSet25_MAT.royal_zweihander.Royal_Zweihander_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet25_MAT.royal_zweihander.Royal_Zweihander_3P_Pickup_MIC"))

//Steampunk MP5RAS
    Skins.Add((Id=7233, Weapondef=class'KFWeapDef_MP5RAS', MIC_1P=("WEP_SkinSet25_MAT.royal_mp5ras.Royal_MP5RAS_1P_Mint_MIC"), MIC_3P="WEP_SkinSet25_MAT.royal_mp5ras.Royal_MP5RAS_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet25_MAT.royal_mp5ras.Royal_MP5RAS_3P_Pickup_MIC"))

//Steampunk AA12
    Skins.Add((Id=7234, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet25_MAT.royal_aa12.Royal_AA12_1P_Mint_MIC"), MIC_3P="WEP_SkinSet25_MAT.royal_aa12.Royal_AA12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet25_MAT.royal_aa12.Royal_AA12_3P_Pickup_MIC"))

//Steampunk MAC 10
    Skins.Add((Id=7235, Weapondef=class'KFWeapDef_Mac10', MIC_1P=("WEP_SkinSet25_MAT.royal_mac10.Royal_MAC10_1P_Mint_MIC"), MIC_3P="WEP_SkinSet25_MAT.royal_mac10.Royal_MAC10_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet25_MAT.royal_mac10.Royal_MAC10_3P_Pickup_MIC"))

//Steampunk M99
    Skins.Add((Id=7236, Weapondef=class'KFWeapDef_M99', MIC_1P=("WEP_SkinSet25_MAT.royal_m99.Royal_M99_1P_Mint_MIC", "WEP_SkinSet25_MAT.royal_m99.Royal_M99_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet25_MAT.royal_m99.Royal_M99_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet25_MAT.royal_m99.Royal_M99_3P_Pickup_MIC"))

//Steampunk Desert Eagle
    Skins.Add((Id=7237, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet25_MAT.royal_deagle.Royal_Deagle_1P_Mint_MIC"), MIC_3P="WEP_SkinSet25_MAT.royal_deagle.Royal_Deagle_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet25_MAT.royal_deagle.Royal_Deagle_3P_3P_Pickup_MIC"))

//Beyond Horizon Kriss
    Skins.Add((Id=7444, Weapondef=class'KFWeapDef_Kriss', MIC_1P=("WEP_SkinSet26_MAT.space_kriss.Space_Kriss_1P_Mint_MIC", "WEP_SkinSet26_MAT.space_kriss.Space_Kriss_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet26_MAT.space_kriss.Space_Kriss_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet26_MAT.space_kriss.Space_Kriss_3P_Pickup_MIC"))
    Skins.Add((Id=7443, Weapondef=class'KFWeapDef_Kriss', MIC_1P=("WEP_SkinSet26_MAT.space_kriss.Space_Kriss_1P_FieldTested_MIC", "WEP_SkinSet26_MAT.space_kriss.Space_Kriss_Sight_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet26_MAT.space_kriss.Space_Kriss_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet26_MAT.space_kriss.Space_Kriss_3P_Pickup_MIC"))
    Skins.Add((Id=7442, Weapondef=class'KFWeapDef_Kriss', MIC_1P=("WEP_SkinSet26_MAT.space_kriss.Space_Kriss_1P_BattleScarred_MIC", "WEP_SkinSet26_MAT.space_kriss.Space_Kriss_Sight_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet26_MAT.space_kriss.Space_Kriss_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet26_MAT.space_kriss.Space_Kriss_3P_Pickup_MIC"))

//Beyond Horizon Scar
    Skins.Add((Id=7447, Weapondef=class'KFWeapDef_Scar', MIC_1P=("WEP_SkinSet26_MAT.space_scar.Space_Scar_1P_Mint_MIC", "WEP_SkinSet26_MAT.space_scar.Space_Scar_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet26_MAT.space_scar.Space_SCAR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet26_MAT.space_scar.Space_SCAR_3P_Pickup_MIC"))
    Skins.Add((Id=7446, Weapondef=class'KFWeapDef_Scar', MIC_1P=("WEP_SkinSet26_MAT.space_scar.Space_Scar_1P_FieldTested_MIC", "WEP_SkinSet26_MAT.space_scar.Space_Scar_Scope_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet26_MAT.space_scar.Space_SCAR_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet26_MAT.space_scar.Space_SCAR_3P_Pickup_MIC"))
    Skins.Add((Id=7445, Weapondef=class'KFWeapDef_Scar', MIC_1P=("WEP_SkinSet26_MAT.space_scar.Space_Scar_1P_BattleScarred_MIC", "WEP_SkinSet26_MAT.space_scar.Space_Scar_Scope_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet26_MAT.space_scar.Space_SCAR_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet26_MAT.space_scar.Space_SCAR_3P_Pickup_MIC"))

//Beyond Horizon Static Strikers
    Skins.Add((Id=7450, Weapondef=class'KFWeapDef_PowerGloves', MIC_1P=("WEP_SkinSet26_MAT.space_staticstrikers.Space_StaticStrikers_1P_Mint_MIC"), MIC_3P="WEP_SkinSet26_MAT.space_staticstrikers.Space_StaticStrikers_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet26_MAT.space_staticstrikers.Space_StaticStrikers_3P_Pickup_MIC"))
    Skins.Add((Id=7449, Weapondef=class'KFWeapDef_PowerGloves', MIC_1P=("WEP_SkinSet26_MAT.space_staticstrikers.Space_StaticStrikers_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet26_MAT.space_staticstrikers.Space_StaticStrikers_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet26_MAT.space_staticstrikers.Space_StaticStrikers_3P_Pickup_MIC"))
    Skins.Add((Id=7448, Weapondef=class'KFWeapDef_PowerGloves', MIC_1P=("WEP_SkinSet26_MAT.space_staticstrikers.Space_StaticStrikers_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet26_MAT.space_staticstrikers.Space_StaticStrikers_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet26_MAT.space_staticstrikers.Space_StaticStrikers_3P_Pickup_MIC"))

//Beyond Horizon RPG-7
    Skins.Add((Id=7453, Weapondef=class'KFWeapDef_RPG7', MIC_1P=("WEP_SkinSet26_MAT.space_rpg7.Space_RPG7_1P_Mint_MIC"), MIC_3P="WEP_SkinSet26_MAT.space_rpg7.Space_RPG7_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet26_MAT.space_rpg7.Space_RPG7_3P_Pickup_MIC"))
    Skins.Add((Id=7452, Weapondef=class'KFWeapDef_RPG7', MIC_1P=("WEP_SkinSet26_MAT.space_rpg7.Space_RPG7_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet26_MAT.space_rpg7.Space_RPG7_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet26_MAT.space_rpg7.Space_RPG7_3P_Pickup_MIC"))
    Skins.Add((Id=7451, Weapondef=class'KFWeapDef_RPG7', MIC_1P=("WEP_SkinSet26_MAT.space_rpg7.Space_RPG7_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet26_MAT.space_rpg7.Space_RPG7_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet26_MAT.space_rpg7.Space_RPG7_3P_Pickup_MIC"))

//Beyond Horizon Flamethrower
    Skins.Add((Id=7456, Weapondef=class'KFWeapDef_FlameThrower', MIC_1P=("WEP_SkinSet26_MAT.space_flamethrower.Space_Flamethrower_1P_Mint_MIC"), MIC_3P="WEP_SkinSet26_MAT.space_flamethrower.Space_Flamethrower_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet26_MAT.space_flamethrower.Space_Flamethrower_3P_Pickup_MIC"))
    Skins.Add((Id=7455, Weapondef=class'KFWeapDef_FlameThrower', MIC_1P=("WEP_SkinSet26_MAT.space_flamethrower.Space_Flamethrower_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet26_MAT.space_flamethrower.Space_Flamethrower_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet26_MAT.space_flamethrower.Space_Flamethrower_3P_Pickup_MIC"))
    Skins.Add((Id=7454, Weapondef=class'KFWeapDef_FlameThrower', MIC_1P=("WEP_SkinSet26_MAT.space_flamethrower.Space_Flamethrower_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet26_MAT.space_flamethrower.Space_Flamethrower_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet26_MAT.space_flamethrower.Space_Flamethrower_3P_Pickup_MIC"))

//Beyond Horizon M99
    Skins.Add((Id=7459, Weapondef=class'KFWeapDef_M99', MIC_1P=("WEP_SkinSet26_MAT.space_m99.Space_M99_1P_Mint_MIC", "WEP_SkinSet26_MAT.space_m99.Space_M99_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet26_MAT.space_m99.Space_M99_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet26_MAT.space_m99.Space_M99_3P_Pickup_MIC"))
    Skins.Add((Id=7458, Weapondef=class'KFWeapDef_M99', MIC_1P=("WEP_SkinSet26_MAT.space_m99.Space_M99_1P_FieldTested_MIC", "WEP_SkinSet26_MAT.space_m99.Space_M99_Scope_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet26_MAT.space_m99.Space_M99_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet26_MAT.space_m99.Space_M99_3P_Pickup_MIC"))
    Skins.Add((Id=7457, Weapondef=class'KFWeapDef_M99', MIC_1P=("WEP_SkinSet26_MAT.space_m99.Space_M99_1P_BattleScarred_MIC", "WEP_SkinSet26_MAT.space_m99.Space_M99_Scope_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet26_MAT.space_m99.Space_M99_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet26_MAT.space_m99.Space_M99_3P_Pickup_MIC"))

//Beyond Horizon Killerwatt
    Skins.Add((Id=7462, Weapondef=class'KFWeapDef_LazerCutter', MIC_1P=("WEP_SkinSet26_MAT.space_lasercutter.Space_LaserCutter_Scope_1P_Mint_MIC", "WEP_SkinSet26_MAT.space_lasercutter.Space_LaserCutter_1P_Mint_MIC", "WEP_SkinSet26_MAT.space_lasercutter.Space_LaserCutter_1P_Mint_MIC", "WEP_1P_Optics_Lense_MAT.Wep_1stP_Laser_Cutter_Optic_MIC", "WEP_SkinSet26_MAT.space_lasercutter.FX_LaserCutter_Beam_MIC"), MIC_3P="WEP_SkinSet26_MAT.space_lasercutter.Space_LaserCutter_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet26_MAT.space_lasercutter.Space_LaserCutter_3P_Pickup_MIC"))
    Skins.Add((Id=7461, Weapondef=class'KFWeapDef_LazerCutter', MIC_1P=("WEP_SkinSet26_MAT.space_lasercutter.Space_LaserCutter_Scope_1P_FieldTested_MIC", "WEP_SkinSet26_MAT.space_lasercutter.Space_LaserCutter_1P_FieldTested_MIC", "WEP_SkinSet26_MAT.space_lasercutter.Space_LaserCutter_1P_FieldTested_MIC", "WEP_1P_Optics_Lense_MAT.Wep_1stP_Laser_Cutter_Optic_MIC", "WEP_SkinSet26_MAT.space_lasercutter.FX_LaserCutter_Beam_MIC"), MIC_3P="WEP_SkinSet26_MAT.space_lasercutter.Space_LaserCutter_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet26_MAT.space_lasercutter.Space_LaserCutter_3P_Pickup_MIC"))
    Skins.Add((Id=7460, Weapondef=class'KFWeapDef_LazerCutter', MIC_1P=("WEP_SkinSet26_MAT.space_lasercutter.Space_LaserCutter_Scope_1P_BattleScarred_MIC", "WEP_SkinSet26_MAT.space_lasercutter.Space_LaserCutter_1P_BattleScarred_MIC", "WEP_SkinSet26_MAT.space_lasercutter.Space_LaserCutter_1P_BattleScarred_MIC", "WEP_1P_Optics_Lense_MAT.Wep_1stP_Laser_Cutter_Optic_MIC", "WEP_SkinSet26_MAT.space_lasercutter.FX_LaserCutter_Beam_MIC"), MIC_3P="WEP_SkinSet26_MAT.space_lasercutter.Space_LaserCutter_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet26_MAT.space_lasercutter.Space_LaserCutter_3P_Pickup_MIC"))

//Beyond Horizon Helios Rifle
    Skins.Add((Id=7465, Weapondef=class'KFWeapDef_MicrowaveRifle', MIC_1P=("WEP_SkinSet26_MAT.space_microwaveassault.Space_MicrowaveAssault_1P_Mint_MIC"), MIC_3P="WEP_SkinSet26_MAT.space_microwaveassault.Space_MicrowaveAssault_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet26_MAT.space_microwaveassault.Space_MicrowaveAssault_3P_Pickup_MIC"))
    Skins.Add((Id=7464, Weapondef=class'KFWeapDef_MicrowaveRifle', MIC_1P=("WEP_SkinSet26_MAT.space_microwaveassault.Space_MicrowaveAssault_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet26_MAT.space_microwaveassault.Space_MicrowaveAssault_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet26_MAT.space_microwaveassault.Space_MicrowaveAssault_3P_Pickup_MIC"))
    Skins.Add((Id=7463, Weapondef=class'KFWeapDef_MicrowaveRifle', MIC_1P=("WEP_SkinSet26_MAT.space_microwaveassault.Space_MicrowaveAssault_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet26_MAT.space_microwaveassault.Space_MicrowaveAssault_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet26_MAT.space_microwaveassault.Space_MicrowaveAssault_3P_Pickup_MIC"))

//Beyond Horizon HMTech-401 Assault Rifle
    Skins.Add((Id=7468, Weapondef=class'KFWeapDef_MedicRifle', MIC_1P=("WEP_SkinSet26_MAT.space_medicset.Space_MedicAssault_1P_Mint_MIC", "WEP_SkinSet26_MAT.space_medicset.Space_MedicPistol_1P_Mint_MIC", "WEP_SkinSet26_MAT.space_medicoptics.Wep_Medic_Assault_Optic_PM_MIC"), MIC_3P="WEP_SkinSet26_MAT.space_medicset.Space_MedicAssault_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet26_MAT.space_medicset.Space_MedicAssault_3P_Pickup_MIC"))
    Skins.Add((Id=7467, Weapondef=class'KFWeapDef_MedicRifle', MIC_1P=("WEP_SkinSet26_MAT.space_medicset.Space_MedicAssault_1P_FieldTested_MIC", "WEP_SkinSet26_MAT.space_medicset.Space_MedicPistol_1P_FieldTested_MIC", "WEP_SkinSet26_MAT.space_medicoptics.Wep_Medic_Assault_Optic_PM_MIC"), MIC_3P="WEP_SkinSet26_MAT.space_medicset.Space_MedicAssault_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet26_MAT.space_medicset.Space_MedicAssault_3P_Pickup_MIC"))
    Skins.Add((Id=7466, Weapondef=class'KFWeapDef_MedicRifle', MIC_1P=("WEP_SkinSet26_MAT.space_medicset.Space_MedicAssault_1P_BattleScarred_MIC", "WEP_SkinSet26_MAT.space_medicset.Space_MedicPistol_1P_BattleScarred_MIC", "WEP_SkinSet26_MAT.space_medicoptics.Wep_Medic_Assault_Optic_PM_MIC"), MIC_3P="WEP_SkinSet26_MAT.space_medicset.Space_MedicAssault_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet26_MAT.space_medicset.Space_MedicAssault_3P_Pickup_MIC"))

//Beyond Horizon HMTech-301 Shotgun
    Skins.Add((Id=7471, Weapondef=class'KFWeapDef_MedicShotgun', MIC_1P=("WEP_SkinSet26_MAT.space_medicset.Space_MedicPistol_1P_Mint_MIC", "WEP_SkinSet26_MAT.space_medicset.Space_MedicShotgun_1P_Mint_MIC", "WEP_SkinSet26_MAT.space_medicoptics.Wep_Medic_Shotgun_Optic_PM_MIC"), MIC_3P="WEP_SkinSet26_MAT.space_medicset.Space_MedicShotgun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet26_MAT.space_medicset.Space_MedicShotgun_3P_Pickup_MIC"))
    Skins.Add((Id=7470, Weapondef=class'KFWeapDef_MedicShotgun', MIC_1P=("WEP_SkinSet26_MAT.space_medicset.Space_MedicPistol_1P_FieldTested_MIC", "WEP_SkinSet26_MAT.space_medicset.Space_MedicShotgun_1P_FieldTested_MIC", "WEP_SkinSet26_MAT.space_medicoptics.Wep_Medic_Shotgun_Optic_PM_MIC"), MIC_3P="WEP_SkinSet26_MAT.space_medicset.Space_MedicShotgun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet26_MAT.space_medicset.Space_MedicShotgun_3P_Pickup_MIC"))
    Skins.Add((Id=7469, Weapondef=class'KFWeapDef_MedicShotgun', MIC_1P=("WEP_SkinSet26_MAT.space_medicset.Space_MedicPistol_1P_BattleScarred_MIC", "WEP_SkinSet26_MAT.space_medicset.Space_MedicShotgun_1P_BattleScarred_MIC", "WEP_SkinSet26_MAT.space_medicoptics.Wep_Medic_Shotgun_Optic_PM_MIC"), MIC_3P="WEP_SkinSet26_MAT.space_medicset.Space_MedicShotgun_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet26_MAT.space_medicset.Space_MedicShotgun_3P_Pickup_MIC"))

//Beyond Horizon HMTech-201 SMG
    Skins.Add((Id=7474, Weapondef=class'KFWeapDef_MedicSMG', MIC_1P=("WEP_SkinSet26_MAT.space_medicset.Space_MedicPistol_1P_Mint_MIC", "WEP_SkinSet26_MAT.space_medicset.Space_MedicSMG_1P_Mint_MIC", "WEP_SkinSet26_MAT.space_medicoptics.Wep_Medic_SMG_Optic_PM_MIC"), MIC_3P="WEP_SkinSet26_MAT.space_medicset.Space_MedicSMG_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet26_MAT.space_medicset.Space_MedicSMG_3P_Pickup_MIC"))
    Skins.Add((Id=7473, Weapondef=class'KFWeapDef_MedicSMG', MIC_1P=("WEP_SkinSet26_MAT.space_medicset.Space_MedicPistol_1P_FieldTested_MIC", "WEP_SkinSet26_MAT.space_medicset.Space_MedicSMG_1P_FieldTested_MIC", "WEP_SkinSet26_MAT.space_medicoptics.Wep_Medic_SMG_Optic_PM_MIC"), MIC_3P="WEP_SkinSet26_MAT.space_medicset.Space_MedicSMG_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet26_MAT.space_medicset.Space_MedicSMG_3P_Pickup_MIC"))
    Skins.Add((Id=7472, Weapondef=class'KFWeapDef_MedicSMG', MIC_1P=("WEP_SkinSet26_MAT.space_medicset.Space_MedicPistol_1P_BattleScarred_MIC", "WEP_SkinSet26_MAT.space_medicset.Space_MedicSMG_1P_BattleScarred_MIC", "WEP_SkinSet26_MAT.space_medicoptics.Wep_Medic_SMG_Optic_PM_MIC"), MIC_3P="WEP_SkinSet26_MAT.space_medicset.Space_MedicSMG_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet26_MAT.space_medicset.Space_MedicSMG_3P_Pickup_MIC"))

//Beyond Horizon HMTech-101 Pistol
    Skins.Add((Id=7477, Weapondef=class'KFWeapDef_MedicPistol', MIC_1P=("WEP_SkinSet26_MAT.space_medicset.Space_MedicPistolOnly_1P_Mint_MIC", "WEP_SkinSet26_MAT.space_medicoptics.Wep_Medic_Pistol_Optic_PM_MIC"), MIC_3P="WEP_SkinSet26_MAT.space_medicset.Space_MedicPistol_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet26_MAT.space_medicset.Space_MedicPistol_3P_Pickup_MIC"))
    Skins.Add((Id=7476, Weapondef=class'KFWeapDef_MedicPistol', MIC_1P=("WEP_SkinSet26_MAT.space_medicset.Space_MedicPistolOnly_1P_FieldTested_MIC", "WEP_SkinSet26_MAT.space_medicoptics.Wep_Medic_Pistol_Optic_PM_MIC"), MIC_3P="WEP_SkinSet26_MAT.space_medicset.Space_MedicPistol_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet26_MAT.space_medicset.Space_MedicPistol_3P_Pickup_MIC"))
    Skins.Add((Id=7475, Weapondef=class'KFWeapDef_MedicPistol', MIC_1P=("WEP_SkinSet26_MAT.space_medicset.Space_MedicPistolOnly_1P_BattleScarred_MIC", "WEP_SkinSet26_MAT.space_medicoptics.Wep_Medic_Pistol_Optic_PM_MIC"), MIC_3P="WEP_SkinSet26_MAT.space_medicset.Space_MedicPistol_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet26_MAT.space_medicset.Space_MedicPistol_3P_Pickup_MIC"))

//Beyond Horizon Pulverizer
    Skins.Add((Id=7480, Weapondef=class'KFWeapDef_Pulverizer', MIC_1P=("WEP_SkinSet26_MAT.space_pulverizer.Space_Pulverizer_1P_Mint_MIC"), MIC_3P="WEP_SkinSet26_MAT.space_pulverizer.Space_Pulverizer_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet26_MAT.space_pulverizer.Space_Pulverizer_3P_Pickup_MIC"))
    Skins.Add((Id=7479, Weapondef=class'KFWeapDef_Pulverizer', MIC_1P=("WEP_SkinSet26_MAT.space_pulverizer.Space_Pulverizer_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet26_MAT.space_pulverizer.Space_Pulverizer_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet26_MAT.space_pulverizer.Space_Pulverizer_3P_Pickup_MIC"))
    Skins.Add((Id=7478, Weapondef=class'KFWeapDef_Pulverizer', MIC_1P=("WEP_SkinSet26_MAT.space_pulverizer.Space_Pulverizer_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet26_MAT.space_pulverizer.Space_Pulverizer_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet26_MAT.space_pulverizer.Space_Pulverizer_3P_Pickup_MIC"))

//Beyond Horizon Kriss
    Skins.Add((Id=7481, Weapondef=class'KFWeapDef_Kriss', MIC_1P=("WEP_SkinSet26_MAT.spaceelite_kriss.SpaceElite_Kriss_1P_Mint_MIC", "WEP_SkinSet26_MAT.spaceelite_kriss.SpaceElite_Kriss_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet26_MAT.spaceelite_kriss.SpaceElite_Kriss_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet26_MAT.spaceelite_kriss.SpaceElite_Kriss_3P_Pickup_MIC"))

//Beyond Horizon Scar
    Skins.Add((Id=7482, Weapondef=class'KFWeapDef_Scar', MIC_1P=("WEP_SkinSet26_MAT.spaceelite_scar.SpaceElite_Scar_1P_Mint_MIC", "WEP_SkinSet26_MAT.spaceelite_scar.SpaceElite_Scar_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet26_MAT.spaceelite_scar.SpaceElite_SCAR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet26_MAT.spaceelite_scar.SpaceElite_SCAR_3P_Pickup_MIC"))

//Beyond Horizon Static Strikers
    Skins.Add((Id=7483, Weapondef=class'KFWeapDef_PowerGloves', MIC_1P=("WEP_SkinSet26_MAT.spaceelite_staticstrikers.SpaceElite_StaticStrikers_1P_Mint_MIC"), MIC_3P="WEP_SkinSet26_MAT.spaceelite_staticstrikers.SpaceElite_StaticStrikers_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet26_MAT.spaceelite_staticstrikers.SpaceElite_StaticStrikers_3P_Pickup_MIC"))

//Beyond Horizon RPG-7
    Skins.Add((Id=7484, Weapondef=class'KFWeapDef_RPG7', MIC_1P=("WEP_SkinSet26_MAT.spaceelite_rpg7.SpaceElite_RPG7_1P_Mint_MIC"), MIC_3P="WEP_SkinSet26_MAT.spaceelite_rpg7.SpaceElite_RPG7_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet26_MAT.spaceelite_rpg7.SpaceElite_RPG7_3P_Pickup_MIC"))

//Beyond Horizon Flamethrower
    Skins.Add((Id=7485, Weapondef=class'KFWeapDef_FlameThrower', MIC_1P=("WEP_SkinSet26_MAT.spaceelite_flamethrower.SpaceElite_Flamethrower_1P_Mint_MIC"), MIC_3P="WEP_SkinSet26_MAT.spaceelite_flamethrower.SpaceElite_Flamethrower_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet26_MAT.spaceelite_flamethrower.SpaceElite_Flamethrower_3P_Pickup_MIC"))

//Beyond Horizon M99
    Skins.Add((Id=7486, Weapondef=class'KFWeapDef_M99', MIC_1P=("WEP_SkinSet26_MAT.spaceelite_m99.SpaceElite_M99_1P_Mint_MIC", "WEP_SkinSet26_MAT.spaceelite_m99.SpaceElite_M99_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet26_MAT.spaceelite_m99.SpaceElite_M99_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet26_MAT.spaceelite_m99.SpaceElite_M99_3P_Pickup_MIC"))

//Beyond Horizon Killerwatt
    Skins.Add((Id=7487, Weapondef=class'KFWeapDef_LazerCutter', MIC_1P=("WEP_SkinSet26_MAT.spaceelite_lasercutter.SpaceElite_LaserCutter_Scope_1P_Mint_MIC", "WEP_SkinSet26_MAT.spaceelite_lasercutter.SpaceElite_LaserCutter_1P_Mint_MIC", "WEP_SkinSet26_MAT.spaceelite_lasercutter.SpaceElite_LaserCutter_1P_Mint_MIC", "WEP_1P_Optics_Lense_MAT.Wep_1stP_Laser_Cutter_Optic_MIC", "WEP_SkinSet26_MAT.space_lasercutter.FX_LaserCutter_Beam_MIC"), MIC_3P="WEP_SkinSet26_MAT.spaceelite_lasercutter.SpaceElite_LaserCutter_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet26_MAT.spaceelite_lasercutter.SpaceElite_LaserCutter_3P_Pickup_MIC"))

//Beyond Horizon Helios Rifle
    Skins.Add((Id=7488, Weapondef=class'KFWeapDef_MicrowaveRifle', MIC_1P=("WEP_SkinSet26_MAT.spaceelite_microwaveassault.SpaceElite_MicrowaveAssault_1P_Mint_MIC"), MIC_3P="WEP_SkinSet26_MAT.spaceelite_microwaveassault.SpaceElite_MicrowaveAssault_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet26_MAT.spaceelite_microwaveassault.SpaceElite_MicrowaveAssault_3P_Pickup_MIC"))

//Beyond Horizon HMTech-101 Pistol
    Skins.Add((Id=7489, Weapondef=class'KFWeapDef_MedicPistol', MIC_1P=("WEP_SkinSet26_MAT.spaceelite_medicset.SpaceElite_MedicPistolOnly_1P_Mint_MIC", "WEP_SkinSet26_MAT.space_medicoptics.Wep_Medic_Pistol_Optic_PM_MIC"), MIC_3P="WEP_SkinSet26_MAT.spaceelite_medicset.SpaceElite_MedicPistol_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet26_MAT.spaceelite_medicset.SpaceElite_MedicPistol_3P_Pickup_MIC"))

//Beyond Horizon HMTech-201 SMG
    Skins.Add((Id=7490, Weapondef=class'KFWeapDef_MedicSMG', MIC_1P=("WEP_SkinSet26_MAT.spaceelite_medicset.SpaceElite_MedicPistol_1P_Mint_MIC", "WEP_SkinSet26_MAT.spaceelite_medicset.SpaceElite_MedicSMG_1P_Mint_MIC", "WEP_SkinSet26_MAT.space_medicoptics.Wep_Medic_SMG_Optic_PM_MIC"), MIC_3P="WEP_SkinSet26_MAT.spaceelite_medicset.SpaceElite_MedicSMG_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet26_MAT.spaceelite_medicset.SpaceElite_MedicSMG_3P_Pickup_MIC"))

//Beyond Horizon HMTech-301 Shotgun
    Skins.Add((Id=7491, Weapondef=class'KFWeapDef_MedicShotgun', MIC_1P=("WEP_SkinSet26_MAT.spaceelite_medicset.SpaceElite_MedicPistol_1P_Mint_MIC", "WEP_SkinSet26_MAT.spaceelite_medicset.SpaceElite_MedicShotgun_1P_Mint_MIC", "WEP_SkinSet26_MAT.space_medicoptics.Wep_Medic_Shotgun_Optic_PM_MIC"), MIC_3P="WEP_SkinSet26_MAT.spaceelite_medicset.SpaceElite_MedicShotgun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet26_MAT.spaceelite_medicset.SpaceElite_MedicShotgun_3P_Pickup_MIC"))

//Beyond Horizon HMTech-401 Assault Rifle
    Skins.Add((Id=7492, Weapondef=class'KFWeapDef_MedicRifle', MIC_1P=("WEP_SkinSet26_MAT.spaceelite_medicset.SpaceElite_MedicAssault_1P_Mint_MIC", "WEP_SkinSet26_MAT.spaceelite_medicset.SpaceElite_MedicPistol_1P_Mint_MIC", "WEP_SkinSet26_MAT.space_medicoptics.Wep_Medic_Assault_Optic_PM_MIC"), MIC_3P="WEP_SkinSet26_MAT.spaceelite_medicset.SpaceElite_MedicAssault_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet26_MAT.spaceelite_medicset.SpaceElite_MedicAssault_3P_Pickup_MIC"))

//Beyond Horizon Pulverizer
    Skins.Add((Id=7493, Weapondef=class'KFWeapDef_Pulverizer', MIC_1P=("WEP_SkinSet26_MAT.spaceelite_pulverizer.SpaceElite_Pulverizer_1P_Mint_MIC"), MIC_3P="WEP_SkinSet26_MAT.spaceelite_pulverizer.SpaceElite_Pulverizer_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet26_MAT.spaceelite_pulverizer.SpaceElite_Pulverizer_3P_Pickup_MIC"))

//Vault Vosh Killerwatt
    Skins.Add((Id=7494, Weapondef=class'KFWeapDef_LazerCutter', MIC_1P=("WEP_SkinSet_VaultVosh08_MAT.vosh_lasercutter.Vault_Vosh_LaserCutter_Scope_1P_Mint_MIC", "WEP_SkinSet_VaultVosh08_MAT.vosh_lasercutter.Vault_Vosh_LaserCutter_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh08_MAT.vosh_lasercutter.Vault_Vosh_LaserCutter_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh08_MAT.vosh_lasercutter.Vault_Vosh_LaserCutter_3P_Pickup_MIC"))

//Vault Vosh Helios Rifle
    Skins.Add((Id=7495, Weapondef=class'KFWeapDef_MicrowaveRifle', MIC_1P=("WEP_SkinSet_VaultVosh08_MAT.vosh_microwaveassault.Vault_Vosh_MicrowaveAssault_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh08_MAT.vosh_microwaveassault.Vault_Vosh_MicrowaveAssault_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh08_MAT.vosh_microwaveassault.Vault_Vosh_MicrowaveAssault_3P_Pickup_MIC"))

//Vault Vosh Seal Squeal
    Skins.Add((Id=7496, Weapondef=class'KFWeapDef_SealSqueal', MIC_1P=("WEP_SkinSet_VaultVosh08_MAT.vosh_sealsqueal.Vault_Vosh_SealSqueal_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh08_MAT.vosh_sealsqueal.Vault_Vosh_SealSqueal_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh08_MAT.vosh_sealsqueal.Vault_Vosh_SealSqueal_3P_Pickup_MIC"))

//Vault Vosh Medic Bat
    Skins.Add((Id=7497, Weapondef=class'KFWeapDef_MedicBat', MIC_1P=("WEP_SkinSet_VaultVosh08_MAT.vosh_medicbat.Vault_Vosh_MedicBat_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh08_MAT.vosh_medicbat.Vault_Vosh_MedicBat_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh08_MAT.vosh_medicbat.Vault_Vosh_MedicBat_3P_Pickup_MIC"))

//Vault Vosh Chiappa Rhino
    Skins.Add((Id=7498, Weapondef=class'KFWeapDef_ChiappaRhino', MIC_1P=("WEP_SkinSet_VaultVosh08_MAT.vosh_chiapparhino.Vault_Vosh_ChiappaRhino_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh08_MAT.vosh_chiapparhino.Vault_Vosh_ChiappaRhino_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh08_MAT.vosh_chiapparhino.Vault_Vosh_ChiappaRhino_3P_Pickup_MIC"))

//Vault Vosh Ion Sword
    Skins.Add((Id=7499, Weapondef=class'KFWeapDef_IonThruster', MIC_1P=("WEP_SkinSet_VaultVosh08_MAT.vosh_ionsword.Vault_Vosh_IonSword_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh08_MAT.vosh_ionsword.Vault_Vosh_IonSword_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh08_MAT.vosh_ionsword.Vault_Vosh_IonSword_3P_Pickup_MIC"))

//Dragon & Koi Scar
    Skins.Add((Id=7500, Weapondef=class'KFWeapDef_Scar', MIC_1P=("WEP_SkinSet_DragonKoi_04_MAT.dragonkoi_scar.DragonKoi_SCAR_1P_Mint_MIC", "WEP_SkinSet_DragonKoi04_MAT.dragonkoi_scar.DragonKoi_SCAR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_DragonKoi_04_MAT.dragonkoi_scar.DragonKoi_SCAR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_DragonKoi_04_MAT.dragonkoi_scar.DragonKoi_SCAR_3P_Pickup_MIC"))

//Dragon & Koi RPG-7
    Skins.Add((Id=7501, Weapondef=class'KFWeapDef_RPG7', MIC_1P=("WEP_SkinSet_DragonKoi_04_MAT.dragonkoi_rpg7.DragonKoi_RPG7_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_DragonKoi_04_MAT.dragonkoi_rpg7.DragonKoi_RPG7_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_DragonKoi_04_MAT.dragonkoi_rpg7.DragonKoi_RPG7_3P_Pickup_MIC"))

//Dragon & Koi Microwave Gun
    Skins.Add((Id=7502, Weapondef=class'KFWeapDef_MicrowaveGun', MIC_1P=("WEP_SkinSet_DragonKoi_04_MAT.dragonkoi_microwavegun.DragonKoi_MicrowaveGun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_DragonKoi_04_MAT.dragonkoi_microwavegun.DragonKoi_MicrowaveGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_DragonKoi_04_MAT.dragonkoi_microwavegun.DragonKoi_MicrowaveGun_3P_Pickup_MIC"))

//Dragon & Koi 500 Magnum Revolver
    Skins.Add((Id=7503, Weapondef=class'KFWeapDef_SW500', MIC_1P=("WEP_SkinSet_DragonKoi_04_MAT.dragonkoi_sw500.DragonKoi_SW500_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_DragonKoi_04_MAT.dragonkoi_sw500.DragonKoi_SW500_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_DragonKoi_04_MAT.dragonkoi_sw500.DragonKoi_SW500_3P_Pickup_MIC"))

//Dragon & Koi Railgun
    Skins.Add((Id=7504, Weapondef=class'KFWeapDef_Railgun', MIC_1P=("WEP_SkinSet_DragonKoi_04_MAT.dragonkoi_railgun.DragonKoi_Railgun_1P_Mint_MIC", "WEP_SkinSet_DragonKoi_04_MAT.dragonkoi_railgun.DragonKoi_Railgun_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_DragonKoi_04_MAT.dragonkoi_railgun.DragonKoi_Railgun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_DragonKoi_04_MAT.dragonkoi_railgun.DragonKoi_Railgun_3P_Pickup_MIC"))

//Dragon & Koi HMTech-401 Assault Rifle
    Skins.Add((Id=7505, Weapondef=class'KFWeapDef_MedicRifle', MIC_1P=("WEP_SkinSet_DragonKoi_04_MAT.dragonkoi_medicassault.DragonKoi_MedicAssault_1P_Mint_MIC", "WEP_SkinSet_DragonKoi01_MAT.dragonkoi_medicpistol.DragonKoi_MedicPistol_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_DragonKoi_04_MAT.dragonkoi_medicassault.DragonKoi_MedicAssault_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_DragonKoi_04_MAT.dragonkoi_medicassault.DragonKoi_MedicAssault_3P_Pickup_MIC"))

//Dragon & Koi AA12
    Skins.Add((Id=7506, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet_DragonKoi_04_MAT.dragonkoi_aa12.DragonKoi_AA12_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_DragonKoi_04_MAT.dragonkoi_aa12.DragonKoi_AA12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_DragonKoi_04_MAT.dragonkoi_aa12.DragonKoi_AA12_3P_Pickup_MIC"))

//Dragon & Koi Killerwatt
    Skins.Add((Id=7507, Weapondef=class'KFWeapDef_LazerCutter', MIC_1P=("WEP_SkinSet_DragonKoi_04_MAT.dragonkoi_lasercutter.DragonKoi_LaserCutter_Scope_1P_Mint_MIC", "WEP_SkinSet_DragonKoi_04_MAT.dragonkoi_lasercutter.DragonKoi_LaserCutter_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_DragonKoi_04_MAT.dragonkoi_lasercutter.DragonKoi_LaserCutter_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_DragonKoi_04_MAT.dragonkoi_lasercutter.DragonKoi_LaserCutter_3P_Pickup_MIC"))

//Dragon & Koi Kriss
    Skins.Add((Id=7508, Weapondef=class'KFWeapDef_Kriss', MIC_1P=("WEP_SkinSet_DragonKoi_04_MAT.dragonkoi_kriss.DragonKoi_KRISS_1P_Mint_MIC", "WEP_SkinSet_DragonKoi_04_MAT.dragonkoi_kriss.DragonKoi_Kriss_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_DragonKoi_04_MAT.dragonkoi_kriss.DragonKoi_KRISS_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_DragonKoi_04_MAT.dragonkoi_kriss.DragonKoi_Kriss_3P_Pickup_MIC"))

//Dragon & Koi Eviscerator
    Skins.Add((Id=7509, Weapondef=class'KFWeapDef_Eviscerator', MIC_1P=("WEP_SkinSet_DragonKoi_04_MAT.dragonkoi_sawblade.DragonKoi_SawBlade_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_DragonKoi_04_MAT.dragonkoi_sawblade.DragonKoi_SawBlade_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_DragonKoi_04_MAT.dragonkoi_sawblade.DragonKoi_SawBlade_3P_Pickup_MIC"))

//Dragon & Koi M4
    Skins.Add((Id=7510, Weapondef=class'KFWeapDef_M4', MIC_1P=("WEP_SkinSet_DragonKoi_03_MAT.dragonkoi_m4.DragonKoi_M4_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_DragonKoi_03_MAT.dragonkoi_m4.DragonKoi_M4_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_DragonKoi_03_MAT.dragonkoi_m4.DragonKoi_M4_3P_Pickup_MIC"))

//Dragon & Koi P90
    Skins.Add((Id=7511, Weapondef=class'KFWeapDef_P90', MIC_1P=("WEP_SkinSet_DragonKoi_03_MAT.dragonkoi_p90.DragonKoi_P90_1P_Mint_MIC", "WEP_SkinSet_DragonKoi_03_MAT.dragonkoi_p90.DragonKoi_P90_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_DragonKoi_03_MAT.dragonkoi_p90.DragonKoi_P90_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_DragonKoi_03_MAT.dragonkoi_p90.DragonKoi_P90_3P_Pickup_MIC"))

//Dragon & Koi Freeze Thrower
    Skins.Add((Id=7512, Weapondef=class'KFWeapDef_FreezeThrower', MIC_1P=("WEP_SkinSet_DragonKoi_03_MAT.dragonkoi_cryogun.DragonKoi_Cryogun_ID1_1P_Mint_MIC", "WEP_SkinSet_DragonKoi_03_MAT.dragonkoi_cryogun.DragonKoi_Cryogun_ID2_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_DragonKoi_03_MAT.dragonkoi_cryogun.DragonKoi_Cryogun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_DragonKoi_03_MAT.dragonkoi_cryogun.DragonKoi_CryoGun_3P_Pickup_MIC"))

//Dragon & Koi M14EBR
    Skins.Add((Id=7513, Weapondef=class'KFWeapDef_M14EBR', MIC_1P=("WEP_SkinSet_DragonKoi_03_MAT.dragonkoi_m14ebr.DragonKoi_M14EBR_1P_Mint_MIC", "WEP_SkinSet_DragonKoi_03_MAT.dragonkoi_m14ebr.DragonKoi_M14EBR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_DragonKoi_03_MAT.dragonkoi_m14ebr.DragonKoi_M14EBR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_DragonKoi_03_MAT.dragonkoi_m14ebr.DragonKoi_M14EBR_3P_Pickup_MIC"))

//Dragon & Koi HMTech-301 Shotgun
    Skins.Add((Id=7514, Weapondef=class'KFWeapDef_MedicShotgun', MIC_1P=("WEP_SkinSet_DragonKoi01_MAT.dragonkoi_medicpistol.DragonKoi_MedicPistol_1P_Mint_MIC", "WEP_SkinSet_DragonKoi_03_MAT.dragonkoi_medicshotgun.DragonKoi_MedicShotgun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_DragonKoi_03_MAT.dragonkoi_medicshotgun.DragonKoi_MedicShotgun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_DragonKoi_03_MAT.dragonkoi_medicshotgun.DragonKoi_MedicShotgun_3P_Pickup_MIC"))

//Dragon & Koi Desert Eagle
    Skins.Add((Id=7515, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet_DragonKoi_03_MAT.dragonkoi_deagle.DragonKoi_Deagle_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_DragonKoi_03_MAT.dragonkoi_deagle.DragonKoi_Deagle_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_DragonKoi_03_MAT.dragonkoi_deagle.DragonKoi_Deagle_3P_Pickup_MIC"))

//Dragon & Koi Flamethrower
    Skins.Add((Id=7516, Weapondef=class'KFWeapDef_FlameThrower', MIC_1P=("WEP_SkinSet_DragonKoi_03_MAT.dragonkoi_flamethrower.DragonKoi_Flamethrower_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_DragonKoi_03_MAT.dragonkoi_flamethrower.DragonKoi_Flamethrower_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_DragonKoi_03_MAT.dragonkoi_flamethrower.DragonKoi_Flamethrower_3P_Pickup_MIC"))

//Dragon & Koi M16 M203
    Skins.Add((Id=7517, Weapondef=class'KFWeapDef_M16M203', MIC_1P=("WEP_SkinSet_DragonKoi_03_MAT.dragonkoi_m16m203.DragonKoi_M16_1P_Mint_MIC", "WEP_SkinSet_DragonKoi_03_MAT.dragonkoi_m16m203.DragonKoi_M203_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_DragonKoi_03_MAT.dragonkoi_m16m203.DragonKoi_M16M203_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_DragonKoi_03_MAT.dragonkoi_m16m203.DragonKoi_M16M203_3P_Pickup_MIC"))

//Dragon & Koi AK12
    Skins.Add((Id=7518, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet_DragonKoi_03_MAT.dragonkoi_ak12.DragonKoi_AK12_1P_Mint_MIC", "WEP_SkinSet_DragonKoi_03_MAT.dragonkoi_ak12.DragonKoi_AK12_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_DragonKoi_03_MAT.dragonkoi_ak12.DragonKoi_AK12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_DragonKoi_03_MAT.dragonkoi_ak12.DragonKoi_AK12_3P_Pickup_MIC"))

//Dragon & Koi Pulverizer
    Skins.Add((Id=7519, Weapondef=class'KFWeapDef_Pulverizer', MIC_1P=("WEP_SkinSet_DragonKoi_03_MAT.dragonkoi_pulverizer.DragonKoi_Pulverizer_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_DragonKoi_03_MAT.dragonkoi_pulverizer.DragonKoi_Pulverizer_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_DragonKoi_03_MAT.dragonkoi_pulverizer.DragonKoi_Pulverizer_3P_Pickup_MIC"))

//Standard Ion Sword
    Skins.Add((Id=7715, Weapondef=class'KFWeapDef_IonThruster', MIC_1P=("WEP_1P_Ion_Sword_MAT.Wep_1stP_Ion_Sword_MIC"), MIC_3P="WEP_3P_Ion_Sword_MAT.Wep_3rdP_Ion_Sword_MIC", MIC_Pickup="WEP_3P_Ion_Sword_MAT.Wep_3rdP_Ion_Sword_Pickup_MIC"))

//Dosh Royale Ion Sword
    Skins.Add((Id=7716, Weapondef=class'KFWeapDef_IonThruster', MIC_1P=("WEP_1P_Ion_Sword_MAT.Wep_1st_Ion_Sword_DoshRoyale_MIC"), MIC_3P="WEP_3P_Ion_Sword_MAT.Wep_3rdP_Ion_Sword_DoshRoyale_MIC", MIC_Pickup="WEP_3P_Ion_Sword_MAT.Wep_3rdP_Ion_Sword_DoshRoyale_Pickup_MIC"))

//Lightning Ion Sword
    Skins.Add((Id=7717, Weapondef=class'KFWeapDef_IonThruster', MIC_1P=("WEP_1P_Ion_Sword_MAT.Wep_1st_Ion_Sword_Lightning_MIC"), MIC_3P="WEP_3P_Ion_Sword_MAT.Wep_3rdP_Ion_Sword_Lightning_MIC", MIC_Pickup="WEP_3P_Ion_Sword_MAT.Wep_3rdP_Ion_Sword_Lightning_Pickup_MIC"))

//Lucifer Ion Sword
    Skins.Add((Id=7718, Weapondef=class'KFWeapDef_IonThruster', MIC_1P=("WEP_1P_Ion_Sword_MAT.Wep_1st_Ion_Sword_Lucifer_MIC"), MIC_3P="WEP_3P_Ion_Sword_MAT.Wep_3rdP_Ion_Sword_Lucifer_MIC", MIC_Pickup="WEP_3P_Ion_Sword_MAT.Wep_3rdP_Ion_Sword_Lucifer_Pickup_MIC"))

//Royal Shock Ion Sword
    Skins.Add((Id=7719, Weapondef=class'KFWeapDef_IonThruster', MIC_1P=("WEP_1P_Ion_Sword_MAT.Wep_1st_Ion_Sword_RoyalShock_MIC"), MIC_3P="WEP_3P_Ion_Sword_MAT.Wep_3rdP_Ion_Sword_RoyalShock_MIC", MIC_Pickup="WEP_3P_Ion_Sword_MAT.Wep_3rdP_Ion_Sword_RoyalShock_Pickup_MIC"))

//Shatter Ion Sword
    Skins.Add((Id=7720, Weapondef=class'KFWeapDef_IonThruster', MIC_1P=("WEP_1P_Ion_Sword_MAT.Wep_1st_Ion_Sword_Shatter_MIC"), MIC_3P="WEP_3P_Ion_Sword_MAT.Wep_3rdP_Ion_Sword_Shatter_MIC", MIC_Pickup="WEP_3P_Ion_Sword_MAT.Wep_3rdP_Ion_Sword_Shatter_Pickup_MIC"))

//Standard Chiappa Rhino
    Skins.Add((Id=7704, Weapondef=class'KFWeapDef_ChiappaRhino', MIC_1P=("wep_1p_chiapparhino_mat.WEP_1P_ChiappaRhino_MIC"), MIC_3P="WEP_3P_ChiappoRhino_MAT.WEP_3P_ChiappaRhino_MIC", MIC_Pickup="WEP_3P_ChiappoRhino_MAT.3P_Pickup_ChiappaRhino_MIC"))

//Dosh Royale Chiappa Rhino
    Skins.Add((Id=7705, Weapondef=class'KFWeapDef_ChiappaRhino', MIC_1P=("wep_1p_chiapparhino_mat.WEP_1P_ChiappaRhinos_DoshRoyale_MIC"), MIC_3P="WEP_3P_ChiappoRhino_MAT.WEP_3P_ChiappaRhino_DoshRoyale_MIC", MIC_Pickup="WEP_3P_ChiappoRhino_MAT.3P_Pickup_ChiappaRhino_DoshRoyale_MIC"))

//Lightning Chiappa Rhino
    Skins.Add((Id=7706, Weapondef=class'KFWeapDef_ChiappaRhino', MIC_1P=("wep_1p_chiapparhino_mat.WEP_1P_ChiappaRhinos_Lightning_MIC"), MIC_3P="WEP_3P_ChiappoRhino_MAT.WEP_3P_ChiappaRhino_Lightning_MIC", MIC_Pickup="WEP_3P_ChiappoRhino_MAT.3P_Pickup_ChiappaRhino_Lightning_MIC"))

//Lucifer Chiappa Rhino
    Skins.Add((Id=7707, Weapondef=class'KFWeapDef_ChiappaRhino', MIC_1P=("wep_1p_chiapparhino_mat.WEP_1P_ChiappaRhinos_Lucifer_MIC"), MIC_3P="WEP_3P_ChiappoRhino_MAT.WEP_3P_ChiappaRhino_Lucifer_MIC", MIC_Pickup="WEP_3P_ChiappoRhino_MAT.3P_Pickup_ChiappaRhino_Lucifer_MIC"))

//Royal Shock Chiappa Rhino
    Skins.Add((Id=7708, Weapondef=class'KFWeapDef_ChiappaRhino', MIC_1P=("wep_1p_chiapparhino_mat.WEP_1P_ChiappaRhinos_RoyalShock_MIC"), MIC_3P="WEP_3P_ChiappoRhino_MAT.WEP_3P_ChiappaRhino_RoyalShock_MIC", MIC_Pickup="WEP_3P_ChiappoRhino_MAT.3P_Pickup_ChiappaRhino_RoyalShock_MIC"))

//Shatter Chiappa Rhino
    Skins.Add((Id=7709, Weapondef=class'KFWeapDef_ChiappaRhino', MIC_1P=("wep_1p_chiapparhino_mat.WEP_1P_ChiappaRhinos_Shatter_MIC"), MIC_3P="WEP_3P_ChiappoRhino_MAT.WEP_3P_ChiappaRhino_Shatter_MIC", MIC_Pickup="WEP_3P_ChiappoRhino_MAT.3P_Pickup_ChiappaRhino_Shatter_MIC"))

//Jaeger Kriss
    Skins.Add((Id=7786, Weapondef=class'KFWeapDef_Kriss', MIC_1P=("WEP_SkinSet27_MAT.jaeger_kriss.Jaeger_Kriss_1P_BattleScarred_MIC", "WEP_SkinSet27_MAT.jaeger_kriss.Jaeger_Kriss_Sight_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet27_MAT.jaeger_kriss.Jaeger_Kriss_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet27_MAT.jaeger_kriss.Jaeger_Kriss_3P_Pickup_MIC"))
    Skins.Add((Id=7787, Weapondef=class'KFWeapDef_Kriss', MIC_1P=("WEP_SkinSet27_MAT.jaeger_kriss.Jaeger_Kriss_1P_FieldTested_MIC", "WEP_SkinSet27_MAT.jaeger_kriss.Jaeger_Kriss_Sight_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet27_MAT.jaeger_kriss.Jaeger_Kriss_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet27_MAT.jaeger_kriss.Jaeger_Kriss_3P_Pickup_MIC"))
    Skins.Add((Id=7788, Weapondef=class'KFWeapDef_Kriss', MIC_1P=("WEP_SkinSet27_MAT.jaeger_kriss.Jaeger_Kriss_1P_Mint_MIC", "WEP_SkinSet27_MAT.jaeger_kriss.Jaeger_Kriss_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet27_MAT.jaeger_kriss.Jaeger_Kriss_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet27_MAT.jaeger_kriss.Jaeger_Kriss_3P_Pickup_MIC"))

//Jaeger Scar
    Skins.Add((Id=7789, Weapondef=class'KFWeapDef_Scar', MIC_1P=("WEP_SkinSet27_MAT.jaeger_scar.jaeger_SCAR_1P_BattleScarred_MIC", "WEP_SkinSet27_MAT.jaeger_scar.jaeger_SCAR_Scope_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet27_MAT.jaeger_scar.Jaeger_SCAR_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet27_MAT.jaeger_scar.Jaeger_SCAR_3P_Pickup_MIC"))
    Skins.Add((Id=7790, Weapondef=class'KFWeapDef_Scar', MIC_1P=("WEP_SkinSet27_MAT.jaeger_scar.jaeger_SCAR_1P_FieldTested_MIC", "WEP_SkinSet27_MAT.jaeger_scar.jaeger_SCAR_Scope_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet27_MAT.jaeger_scar.Jaeger_SCAR_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet27_MAT.jaeger_scar.Jaeger_SCAR_3P_Pickup_MIC"))
    Skins.Add((Id=7791, Weapondef=class'KFWeapDef_Scar', MIC_1P=("WEP_SkinSet27_MAT.jaeger_scar.jaeger_SCAR_1P_Mint_MIC", "WEP_SkinSet27_MAT.jaeger_scar.jaeger_SCAR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet27_MAT.jaeger_scar.Jaeger_SCAR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet27_MAT.jaeger_scar.Jaeger_SCAR_3P_Pickup_MIC"))

//Jaeger Doomstick
    Skins.Add((Id=7792, Weapondef=class'KFWeapDef_ElephantGun', MIC_1P=("WEP_SkinSet27_MAT.jaeger_quadbarrel.jaeger_QuadBarrel_Main_1P_BattleScarred_MIC", "WEP_SkinSet27_MAT.jaeger_quadbarrel.jaeger_QuadBarrel_Barrel_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet27_MAT.jaeger_quadbarrel.Jaeger_QuadBarrel_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet27_MAT.jaeger_quadbarrel.Jaeger_QuadBarrel_3P_Pickup_MIC"))
    Skins.Add((Id=7793, Weapondef=class'KFWeapDef_ElephantGun', MIC_1P=("WEP_SkinSet27_MAT.jaeger_quadbarrel.jaeger_QuadBarrel_Main_1P_FieldTested_MIC", "WEP_SkinSet27_MAT.jaeger_quadbarrel.jaeger_QuadBarrel_Barrel_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet27_MAT.jaeger_quadbarrel.Jaeger_QuadBarrel_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet27_MAT.jaeger_quadbarrel.Jaeger_QuadBarrel_3P_Pickup_MIC"))
    Skins.Add((Id=7794, Weapondef=class'KFWeapDef_ElephantGun', MIC_1P=("WEP_SkinSet27_MAT.jaeger_quadbarrel.jaeger_QuadBarrel_Main_1P_Mint_MIC", "WEP_SkinSet27_MAT.jaeger_quadbarrel.jaeger_QuadBarrel_Barrel_1P_Mint_MIC"), MIC_3P="WEP_SkinSet27_MAT.jaeger_quadbarrel.Jaeger_QuadBarrel_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet27_MAT.jaeger_quadbarrel.Jaeger_QuadBarrel_3P_Pickup_MIC"))

//Jaeger Helios Rifle
    Skins.Add((Id=7795, Weapondef=class'KFWeapDef_MicrowaveRifle', MIC_1P=("WEP_SkinSet27_MAT.jaeger_microwaveassault.Jaeger_MicrowaveAssault_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet27_MAT.jaeger_microwaveassault.Jaeger_MicrowaveAssault_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet27_MAT.jaeger_microwaveassault.Jaeger_MicrowaveAssault_3P_Pickup_MIC"))
    Skins.Add((Id=7796, Weapondef=class'KFWeapDef_MicrowaveRifle', MIC_1P=("WEP_SkinSet27_MAT.jaeger_microwaveassault.Jaeger_MicrowaveAssault_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet27_MAT.jaeger_microwaveassault.Jaeger_MicrowaveAssault_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet27_MAT.jaeger_microwaveassault.Jaeger_MicrowaveAssault_3P_Pickup_MIC"))
    Skins.Add((Id=7797, Weapondef=class'KFWeapDef_MicrowaveRifle', MIC_1P=("WEP_SkinSet27_MAT.jaeger_microwaveassault.Jaeger_MicrowaveAssault_1P_Mint_MIC"), MIC_3P="WEP_SkinSet27_MAT.jaeger_microwaveassault.Jaeger_MicrowaveAssault_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet27_MAT.jaeger_microwaveassault.Jaeger_MicrowaveAssault_3P_Pickup_MIC"))

//Jaeger Desert Eagle
    //BattleScarred
    Skins.Add((Id=7798, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet27_MAT.jaeger_deagle.Jaeger_Deagle_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet27_MAT.jaeger_deagle.Jaeger_Deagle_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet27_MAT.jaeger_deagle.Jaeger_Deagle_3P_Pickup_MIC"))
    
    //Field Tested
    Skins.Add((Id=7799, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet27_MAT.jaeger_deagle.Jaeger_Deagle_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet27_MAT.jaeger_deagle.Jaeger_Deagle_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet27_MAT.jaeger_deagle.Jaeger_Deagle_3P_Pickup_MIC"))
    
    //Mint
    Skins.Add((Id=7800, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet27_MAT.jaeger_deagle.Jaeger_Deagle_1P_Mint_MIC"), MIC_3P="WEP_SkinSet27_MAT.jaeger_deagle.Jaeger_Deagle_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet27_MAT.jaeger_deagle.Jaeger_Deagle_3P_Pickup_MIC"))

//Jaeger P90
    //BattleScarred
    Skins.Add((Id=7804, Weapondef=class'KFWeapDef_P90', MIC_1P=("WEP_SkinSet27_MAT.jaeger_p90.jaeger_P90_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet27_MAT.jaeger_p90.Jaeger_P90_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet27_MAT.jaeger_p90.Jaeger_P90_3P_Pickup_MIC"))
    
    //Field Tested
    Skins.Add((Id=7805, Weapondef=class'KFWeapDef_P90', MIC_1P=("WEP_SkinSet27_MAT.jaeger_p90.jaeger_P90_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet27_MAT.jaeger_p90.Jaeger_P90_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet27_MAT.jaeger_p90.Jaeger_P90_3P_Pickup_MIC"))

    //Mint
    Skins.Add((Id=7806, Weapondef=class'KFWeapDef_P90', MIC_1P=("WEP_SkinSet27_MAT.jaeger_p90.jaeger_P90_1P_Mint_MIC"), MIC_3P="WEP_SkinSet27_MAT.jaeger_p90.Jaeger_P90_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet27_MAT.jaeger_p90.Jaeger_P90_3P_Pickup_MIC"))

//Jaeger Desert Eagle BattleScarred
    Skins.Add((Id=8031, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet27_MAT.jaeger_deagle.Jaeger_Deagle_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet27_MAT.jaeger_deagle.Jaeger_Deagle_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet27_MAT.jaeger_deagle.Jaeger_Deagle_3P_Pickup_MIC"))
    
//Jaeger Desert Eagle Field Tested    
    Skins.Add((Id=8032, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet27_MAT.jaeger_deagle.Jaeger_Deagle_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet27_MAT.jaeger_deagle.Jaeger_Deagle_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet27_MAT.jaeger_deagle.Jaeger_Deagle_3P_Pickup_MIC"))
    
//Jaeger Desert Eagle Mint
    Skins.Add((Id=8033, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet27_MAT.jaeger_deagle.Jaeger_Deagle_1P_Mint_MIC"), MIC_3P="WEP_SkinSet27_MAT.jaeger_deagle.Jaeger_Deagle_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet27_MAT.jaeger_deagle.Jaeger_Deagle_3P_Pickup_MIC"))

//Jaeger FN FAL
    Skins.Add((Id=7801, Weapondef=class'KFWeapDef_FNFAL', MIC_1P=("WEP_SkinSet27_MAT.jaeger_fnfal.Jaeger_FNFAL_1P_BattleScarred_MIC", "WEP_SkinSet27_MAT.jaeger_fnfal.Jaeger_FNFAL_Scope_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet27_MAT.jaeger_fnfal.Jaeger_FNFAL_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet27_MAT.jaeger_fnfal.Jaeger_FNFAL_3P_Pickup_MIC"))
    Skins.Add((Id=7802, Weapondef=class'KFWeapDef_FNFAL', MIC_1P=("WEP_SkinSet27_MAT.jaeger_fnfal.Jaeger_FNFAL_1P_FieldTested_MIC", "WEP_SkinSet27_MAT.jaeger_fnfal.Jaeger_FNFAL_Scope_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet27_MAT.jaeger_fnfal.Jaeger_FNFAL_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet27_MAT.jaeger_fnfal.Jaeger_FNFAL_3P_Pickup_MIC"))
    Skins.Add((Id=7803, Weapondef=class'KFWeapDef_FNFAL', MIC_1P=("WEP_SkinSet27_MAT.jaeger_fnfal.Jaeger_FNFAL_1P_Mint_MIC", "WEP_SkinSet27_MAT.jaeger_fnfal.Jaeger_FNFAL_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet27_MAT.jaeger_fnfal.Jaeger_FNFAL_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet27_MAT.jaeger_fnfal.Jaeger_FNFAL_3P_Pickup_MIC"))

//Jaeger P90 BattleScarred
    Skins.Add((Id=8034, Weapondef=class'KFWeapDef_P90', MIC_1P=("WEP_SkinSet27_MAT.jaeger_p90.jaeger_P90_1P_BattleScarred_MIC", "WEP_SkinSet27_MAT.jaeger_p90.jaeger_P90_Sight_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet27_MAT.jaeger_p90.Jaeger_P90_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet27_MAT.jaeger_p90.Jaeger_P90_3P_Pickup_MIC"))
    
//Jaeger P90 Field Tested
    Skins.Add((Id=8035, Weapondef=class'KFWeapDef_P90', MIC_1P=("WEP_SkinSet27_MAT.jaeger_p90.jaeger_P90_1P_FieldTested_MIC", "WEP_SkinSet27_MAT.jaeger_p90.jaeger_P90_Sight_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet27_MAT.jaeger_p90.Jaeger_P90_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet27_MAT.jaeger_p90.Jaeger_P90_3P_Pickup_MIC"))
    
//Jaeger P90 Mint
    Skins.Add((Id=8036, Weapondef=class'KFWeapDef_P90', MIC_1P=("WEP_SkinSet27_MAT.jaeger_p90.jaeger_P90_1P_Mint_MIC", "WEP_SkinSet27_MAT.jaeger_p90.jaeger_P90_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet27_MAT.jaeger_p90.Jaeger_P90_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet27_MAT.jaeger_p90.Jaeger_P90_3P_Pickup_MIC"))

//Jaeger Pulverizer
    Skins.Add((Id=7807, Weapondef=class'KFWeapDef_Pulverizer', MIC_1P=("WEP_SkinSet27_MAT.jaeger_pulverizer.Jaeger_Pulverizer_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet27_MAT.jaeger_pulverizer.Jaeger_Pulverizer_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet27_MAT.jaeger_pulverizer.Jaeger_Pulverizer_3P_Pickup_MIC"))
    Skins.Add((Id=7808, Weapondef=class'KFWeapDef_Pulverizer', MIC_1P=("WEP_SkinSet27_MAT.jaeger_pulverizer.Jaeger_Pulverizer_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet27_MAT.jaeger_pulverizer.Jaeger_Pulverizer_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet27_MAT.jaeger_pulverizer.Jaeger_Pulverizer_3P_Pickup_MIC"))
    Skins.Add((Id=7809, Weapondef=class'KFWeapDef_Pulverizer', MIC_1P=("WEP_SkinSet27_MAT.jaeger_pulverizer.Jaeger_Pulverizer_1P_Mint_MIC"), MIC_3P="WEP_SkinSet27_MAT.jaeger_pulverizer.Jaeger_Pulverizer_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet27_MAT.jaeger_pulverizer.Jaeger_Pulverizer_3P_Pickup_MIC"))

//Jaeger Microwave Gun
    Skins.Add((Id=7810, Weapondef=class'KFWeapDef_MicrowaveGun', MIC_1P=("WEP_SkinSet27_MAT.jaeger_microwavegun.jaeger_MicrowaveGun_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet27_MAT.jaeger_microwavegun.Jaeger_MicrowaveGun_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet27_MAT.jaeger_microwavegun.Jaeger_MicrowaveGun_3P_Pickup_MIC"))
    Skins.Add((Id=7811, Weapondef=class'KFWeapDef_MicrowaveGun', MIC_1P=("WEP_SkinSet27_MAT.jaeger_microwavegun.jaeger_MicrowaveGun_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet27_MAT.jaeger_microwavegun.Jaeger_MicrowaveGun_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet27_MAT.jaeger_microwavegun.Jaeger_MicrowaveGun_3P_Pickup_MIC"))
    Skins.Add((Id=7812, Weapondef=class'KFWeapDef_MicrowaveGun', MIC_1P=("WEP_SkinSet27_MAT.jaeger_microwavegun.jaeger_MicrowaveGun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet27_MAT.jaeger_microwavegun.Jaeger_MicrowaveGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet27_MAT.jaeger_microwavegun.Jaeger_MicrowaveGun_3P_Pickup_MIC"))

//Jaeger Killerwatt
    Skins.Add((Id=7813, Weapondef=class'KFWeapDef_LazerCutter', MIC_1P=("WEP_SkinSet27_MAT.jaeger_lasercutter.Jaeger_LaserCutter_Sight_1P_BattleScarred_MIC", "WEP_SkinSet27_MAT.jaeger_lasercutter.Jaeger_LaserCutter_1P_BattleScarred_MIC", "WEP_SkinSet27_MAT.jaeger_lasercutter.Jaeger_LaserCutter_1P_BattleScarred_MIC", "WEP_1P_Optics_Lense_MAT.Wep_1stP_Laser_Cutter_Optic_MIC", "WEP_SkinSet26_MAT.space_lasercutter.FX_LaserCutter_Beam_MIC"), MIC_3P="WEP_SkinSet27_MAT.jaeger_lasercutter.Jaeger_LaserCutter_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet27_MAT.jaeger_lasercutter.Jaeger_LaserCutter_3P_Pickup_MIC"))
    Skins.Add((Id=7814, Weapondef=class'KFWeapDef_LazerCutter', MIC_1P=("WEP_SkinSet27_MAT.jaeger_lasercutter.Jaeger_LaserCutter_Sight_1P_FieldTested_MIC", "WEP_SkinSet27_MAT.jaeger_lasercutter.Jaeger_LaserCutter_1P_FieldTested_MIC", "WEP_SkinSet27_MAT.jaeger_lasercutter.Jaeger_LaserCutter_1P_FieldTested_MIC", "WEP_1P_Optics_Lense_MAT.Wep_1stP_Laser_Cutter_Optic_MIC", "WEP_SkinSet26_MAT.space_lasercutter.FX_LaserCutter_Beam_MIC"), MIC_3P="WEP_SkinSet27_MAT.jaeger_lasercutter.Jaeger_LaserCutter_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet27_MAT.jaeger_lasercutter.Jaeger_LaserCutter_3P_Pickup_MIC"))
    Skins.Add((Id=7815, Weapondef=class'KFWeapDef_LazerCutter', MIC_1P=("WEP_SkinSet27_MAT.jaeger_lasercutter.Jaeger_LaserCutter_Sight_1P_Mint_MIC", "WEP_SkinSet27_MAT.jaeger_lasercutter.Jaeger_LaserCutter_1P_Mint_MIC", "WEP_SkinSet27_MAT.jaeger_lasercutter.Jaeger_LaserCutter_1P_Mint_MIC", "WEP_1P_Optics_Lense_MAT.Wep_1stP_Laser_Cutter_Optic_MIC", "WEP_SkinSet26_MAT.space_lasercutter.FX_LaserCutter_Beam_MIC"), MIC_3P="WEP_SkinSet27_MAT.jaeger_lasercutter.Jaeger_LaserCutter_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet27_MAT.jaeger_lasercutter.Jaeger_LaserCutter_3P_Pickup_MIC"))

//Jaeger Hemogoblin
    Skins.Add((Id=7816, Weapondef=class'KFWeapDef_Hemogoblin', MIC_1P=("WEP_SkinSet27_MAT.jaeger_bleeder.Jaeger_Bleeder_1P_BattleScarred_MIC", "WEP_SkinSet27_MAT.jaeger_bleeder.Jaeger_Bleeder_Scope_1P_BattleScarred_MIC"), MIC_3P="WEP_SkinSet27_MAT.jaeger_bleeder.Jaeger_Bleeder_3P_BattleScarred_MIC", MIC_Pickup="WEP_SkinSet27_MAT.jaeger_bleeder.Jaeger_Bleeder_3P_Pickup_MIC"))
    Skins.Add((Id=7817, Weapondef=class'KFWeapDef_Hemogoblin', MIC_1P=("WEP_SkinSet27_MAT.jaeger_bleeder.Jaeger_Bleeder_1P_FieldTested_MIC", "WEP_SkinSet27_MAT.jaeger_bleeder.Jaeger_Bleeder_Scope_1P_FieldTested_MIC"), MIC_3P="WEP_SkinSet27_MAT.jaeger_bleeder.Jaeger_Bleeder_3P_FieldTested_MIC", MIC_Pickup="WEP_SkinSet27_MAT.jaeger_bleeder.Jaeger_Bleeder_3P_Pickup_MIC"))
    Skins.Add((Id=7818, Weapondef=class'KFWeapDef_Hemogoblin', MIC_1P=("WEP_SkinSet27_MAT.jaeger_bleeder.Jaeger_Bleeder_1P_Mint_MIC", "WEP_SkinSet27_MAT.jaeger_bleeder.Jaeger_Bleeder_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet27_MAT.jaeger_bleeder.Jaeger_Bleeder_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet27_MAT.jaeger_bleeder.Jaeger_Bleeder_3P_Pickup_MIC"))

//Jaeger Dynamic Kriss
    Skins.Add((Id=7825, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Kriss', MIC_1P=("WEP_SkinSet27_MAT.dynamic_kriss.Dynamic_Kriss_1P_Mint_MIC", "WEP_SkinSet27_MAT.dynamic_kriss.Dynamic_Kriss_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet27_MAT.dynamic_kriss.Dynamic_Kriss_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet27_MAT.dynamic_kriss.Dynamic_Kriss_3P_Pickup_MIC"))

//Jaeger Dynamic SCAR
    Skins.Add((Id=7827, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_SCAR', MIC_1P=("WEP_SkinSet27_MAT.dynamic_scar.Dynamic_SCAR_1P_Mint_MIC", "WEP_SkinSet27_MAT.dynamic_scar.Dynamic_SCAR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet27_MAT.dynamic_scar.Dynamic_SCAR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet27_MAT.dynamic_scar.Dynamic_SCAR_3P_Pickup_MIC"))

//Jaeger Dynamic Doomstick
    Skins.Add((Id=7828, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_ElephantGun', MIC_1P=("WEP_SkinSet27_MAT.dynamic_quadbarrel.Dynamic_QuadBarrel_Main_1P_Mint_MIC", "WEP_SkinSet27_MAT.dynamic_quadbarrel.Dynamic_QuadBarrel_Barrel_1P_Mint_MIC"), MIC_3P="WEP_SkinSet27_MAT.dynamic_quadbarrel.Dynamic_QuadBarrel_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet27_MAT.dynamic_quadbarrel.Dynamic_QuadBarrel_3P_Pickup_MIC"))

//Jaeger Dynamic Helios Rifle
    Skins.Add((Id=7829, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MicrowaveRifle', MIC_1P=("WEP_SkinSet27_MAT.dynamic_microwaveassault.Dynamic_MicrowaveAssault_1P_Mint_MIC"), MIC_3P="WEP_SkinSet27_MAT.dynamic_microwaveassault.Dynamic_MicrowaveAssault_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet27_MAT.dynamic_microwaveassault.Dynamic_MicrowaveAssault_3P_Pickup_MIC"))

//Jaeger Dynamic Desert Eagle
    Skins.Add((Id=7830, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet27_MAT.dynamic_deagle.Dynamic_Deagle_1P_Mint_MIC"), MIC_3P="WEP_SkinSet27_MAT.dynamic_deagle.Dynamic_Deagle_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet27_MAT.dynamic_deagle.Dynamic_Deagle_3P_Pickup_MIC"))

//Jaeger Dynamic FN FAL
    Skins.Add((Id=7831, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_FNFAL', MIC_1P=("WEP_SkinSet27_MAT.dynamic_fnfal.Dynamic_FNFAL_1P_Mint_MIC", "WEP_SkinSet27_MAT.dynamic_fnfal.Dynamic_FNFAL_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet27_MAT.dynamic_fnfal.Dynamic_FNFAL_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet27_MAT.dynamic_fnfal.Dynamic_FNFAL_3P_Pickup_MIC"))

//Jaeger Dynamic P90
    Skins.Add((Id=7832, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_P90', MIC_1P=("WEP_SkinSet27_MAT.dynamic_p90.Dynamic_P90_1P_Mint_MIC", "WEP_SkinSet27_MAT.dynamic_p90.Dynamic_P90_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet27_MAT.dynamic_p90.Dynamic_P90_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet27_MAT.dynamic_p90.Dynamic_P90_3P_Pickup_MIC"))

//Jaeger Dynamic Pulverizer
    Skins.Add((Id=7833, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Pulverizer', MIC_1P=("WEP_SkinSet27_MAT.dynamic_pulverizer.Dynamic_Pulverizer_1P_Mint_MIC"), MIC_3P="WEP_SkinSet27_MAT.dynamic_pulverizer.Dynamic_Pulverizer_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet27_MAT.dynamic_pulverizer.Dynamic_Pulverizer_3P_Pickup_MIC"))

//Jaeger Dynamic Microwave Gun
    Skins.Add((Id=7834, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MicrowaveGun', MIC_1P=("WEP_SkinSet27_MAT.dynamic_microwavegun.Dynamic_MicrowaveGun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet27_MAT.dynamic_microwavegun.Dynamic_MicrowaveGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet27_MAT.dynamic_microwavegun.Dynamic_MicrowaveGun_3P_Pickup_MIC"))

//Jaeger Dynamic Killerwatt
    Skins.Add((Id=7835, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_LazerCutter', MIC_1P=("WEP_SkinSet27_MAT.dynamic_lasercutter.Dynamic_LaserCutter_Sight_1P_Mint_MIC", "WEP_SkinSet27_MAT.dynamic_lasercutter.Dynamic_LaserCutter_1P_Mint_MIC", "WEP_SkinSet27_MAT.dynamic_lasercutter.Dynamic_LaserCutter_1P_Mint_MIC", "WEP_1P_Optics_Lense_MAT.Wep_1stP_Laser_Cutter_Optic_MIC", "WEP_SkinSet26_MAT.space_lasercutter.FX_LaserCutter_Beam_MIC"), MIC_3P="WEP_SkinSet27_MAT.dynamic_lasercutter.Dynamic_LaserCutter_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet27_MAT.dynamic_lasercutter.Dynamic_LaserCutter_3P_Pickup_MIC"))

//Jaeger Dynamic Hemogoblin
    Skins.Add((Id=7836, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Hemogoblin', MIC_1P=("WEP_SkinSet27_MAT.dynamic_bleeder.Dynamic_Bleeder_1P_Mint_MIC", "WEP_SkinSet27_MAT.dynamic_bleeder.Dynamic_Bleeder_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet27_MAT.dynamic_bleeder.Dynamic_Bleeder_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet27_MAT.dynamic_bleeder.Dynamic_Bleeder_3P_Pickup_MIC"))

//Foster's Favorites AK12
    Skins.Add((Id=7837, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet_Mr_Fosters_MAT.mrfosters_ak12.MrFosters_AK12_1P_Mint_MIC", "WEP_SkinSet_Mr_Fosters_MAT.mrfosters_ak12.MrFosters_AK12_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_Mr_Fosters_MAT.mrfosters_ak12.MrFosters_AK12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_Mr_Fosters_MAT.mrfosters_ak12.MrFosters_AK12_3P_Pickup_MIC"))

//Foster's Favorites AA12
    Skins.Add((Id=7838, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet_Mr_Fosters_MAT.mrfosters_aa12.MrFosters_AA12_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_Mr_Fosters_MAT.mrfosters_aa12.MrFosters_AA12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_Mr_Fosters_MAT.mrfosters_aa12.MrFosters_AA12_3P_Pickup_MIC"))

//Foster's Favorites M14EBR
    Skins.Add((Id=7839, Weapondef=class'KFWeapDef_M14EBR', MIC_1P=("WEP_SkinSet_Mr_Fosters_MAT.mrfosters_m14ebr.MrFosters_M14EBR_1P_Mint_MIC", "WEP_SkinSet_MrFosters_MAT.mrfosters_m14ebr.MrFosters_M14EBR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_Mr_Fosters_MAT.mrfosters_m14ebr.MrFosters_M14EBR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_Mr_Fosters_MAT.mrfosters_m14ebr.MrFosters_M14EBR_3P_Pickup_MIC"))

//Foster's Favorites M4
    Skins.Add((Id=7840, Weapondef=class'KFWeapDef_M4', MIC_1P=("WEP_SkinSet_Mr_Fosters_MAT.mrfosters_m4.MrFosters_M4_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_Mr_Fosters_MAT.mrfosters_m4.MrFosters_M4_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_Mr_Fosters_MAT.mrfosters_m4.MrFosters_M4_3P_Pickup_MIC"))

//Foster's Favorites Desert Eagle
    Skins.Add((Id=7841, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet_Mr_Fosters_MAT.mrfosters_deagle.MrFosters_Deagle_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_Mr_Fosters_MAT.mrfosters_deagle.MrFosters_Deagle_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_Mr_Fosters_MAT.mrfosters_deagle.MrFosters_Deagle_3P_Pickup_MIC"))

//Foster's Favorites Boomstick
    Skins.Add((Id=7842, Weapondef=class'KFWeapDef_DoubleBarrel', MIC_1P=("WEP_SkinSet_Mr_Fosters_MAT.mrfosters_doublebarrel.MrFosters_DoubleBarrel_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_Mr_Fosters_MAT.mrfosters_doublebarrel.MrFosters_DoubleBarrel_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_Mr_Fosters_MAT.mrfosters_doublebarrel.MrFosters_DoubleBarrel_3P_Pickup_MIC"))

//Foster's Favorites P90
    Skins.Add((Id=7843, Weapondef=class'KFWeapDef_P90', MIC_1P=("WEP_SkinSet_Mr_Fosters_MAT.mrfosters_p90.MrFosters_P90_1P_Mint_MIC", "WEP_SkinSet_Mr_Fosters_MAT.mrfosters_p90.MrFosters_P90_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_Mr_Fosters_MAT.mrfosters_p90.MrFosters_P90_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_Mr_Fosters_MAT.mrfosters_p90.MrFosters_P90_3P_Pickup_MIC"))

//Foster's Favorites Kriss
    Skins.Add((Id=7844, Weapondef=class'KFWeapDef_Kriss', MIC_1P=("WEP_SkinSet_Mr_Fosters_MAT.mrfosters_kriss.MrFosters_KRISS_1P_Mint_MIC", "WEP_SkinSet_Mr_Fosters_MAT.mrfosters_kriss.MrFosters_Kriss_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_Mr_Fosters_MAT.mrfosters_kriss.MrFosters_KRISS_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_Mr_Fosters_MAT.mrfosters_kriss.MrFosters_Kriss_3P_Pickup_MIC"))

//Vault Vosh HMTech-501 Grenade Rifle
    Skins.Add((Id=7846, Weapondef=class'KFWeapDef_MedicRifleGrenadeLauncher', MIC_1P=("WEP_SkinSet_VaultVosh09_MAT.vosh_medicgrenadelauncher.Vault_Vosh_MedicGrenadeRifle_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh09_MAT.vosh_medicgrenadelauncher.Vault_Vosh_MedicGrenadeRifle_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh09_MAT.vosh_medicgrenadelauncher.Vault_Vosh_MedicGrenadeRifle_3P_Pickup_MIC"))

//Vault Vosh MKb.42
    Skins.Add((Id=7847, Weapondef=class'KFWeapDef_MKB42', MIC_1P=("WEP_SkinSet_VaultVosh09_MAT.vosh_mkb42.Vault_Vosh_MKB42_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh09_MAT.vosh_mkb42.Vault_Vosh_MKB42_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh09_MAT.vosh_mkb42.Vault_Vosh_MKB42_3P_Pickup_MIC"))

//Vault Vosh Doomstick
    Skins.Add((Id=7848, Weapondef=class'KFWeapDef_ElephantGun', MIC_1P=("WEP_SkinSet_VaultVosh09_MAT.vosh_quadbarrel.Vault_Vosh_Quadbarrel_1P_Mint_MIC", "WEP_SkinSet_VaultVosh09_MAT.vosh_quadbarrel.Vault_Vosh_Quadbarrel_Barrel_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh09_MAT.vosh_quadbarrel.Vault_Vosh_Quadbarrel_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh09_MAT.vosh_quadbarrel.Vault_Vosh_QuadBarrel_3P_Pickup_MIC"))

//Vault Vosh Seeker Six
    Skins.Add((Id=7849, Weapondef=class'KFWeapDef_Seeker6', MIC_1P=("WEP_SkinSet_VaultVosh09_MAT.vosh_seekersix.Vault_Vosh_SeekerSix_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh09_MAT.vosh_seekersix.Vault_Vosh_SeekerSix_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh09_MAT.vosh_seekersix.Vault_Vosh_SeekerSix_3P_Pickup_MIC"))

// Mosin Nagant Standard
    Skins.Add((Id=7856, Weapondef=class'KFWeapDef_MosinNagant', MIC_1P=("WEP_1P_Mosin_MAT.Wep_1stP_Mosin_MIC"), MIC_3P="WEP_3P_Mosin_MAT.WEP_3P_Mosin_MIC", MIC_Pickup="WEP_3P_Mosin_MAT.WEP_3P_Mosin_Pickup_MIC"))

// Mosin Nagant Camouflage
    Skins.Add((Id=7857, Weapondef=class'KFWeapDef_MosinNagant', MIC_1P=("WEP_1P_Mosin_MAT.WEP_1P_Mosin_Camo_MIC"), MIC_3P="WEP_3P_Mosin_MAT.WEP_3P_Mosin_Camo_MIC", MIC_Pickup="WEP_3P_Mosin_MAT.WEP_3P_Mosin_Camo_Pickup_MIC"))

// Mosin Nagant Filigree
    Skins.Add((Id=7858, Weapondef=class'KFWeapDef_MosinNagant', MIC_1P=("WEP_1P_Mosin_MAT.WEP_1P_Mosin_Filigree_MIC"), MIC_3P="WEP_3P_Mosin_MAT.WEP_3P_Mosin_Filigree_MIC", MIC_Pickup="WEP_3P_Mosin_MAT.WEP_3P_Mosin_Filigree_Pickup_MIC"))

// Mosin Nagant Filigree Silver
    Skins.Add((Id=7859, Weapondef=class'KFWeapDef_MosinNagant', MIC_1P=("WEP_1P_Mosin_MAT.WEP_1P_Mosin_Filigree02_MIC"), MIC_3P="WEP_3P_Mosin_MAT.WEP_3P_Mosin_Filigree02_MIC", MIC_Pickup="WEP_3P_Mosin_MAT.WEP_3P_Mosin_Filigree02_Pickup_MIC"))

// Mosin Nagant Green
    Skins.Add((Id=7860, Weapondef=class'KFWeapDef_MosinNagant', MIC_1P=("WEP_1P_Mosin_MAT.WEP_1P_Mosin_Green_MIC"), MIC_3P="WEP_3P_Mosin_MAT.WEP_3P_Mosin_Green_MIC", MIC_Pickup="WEP_3P_Mosin_MAT.WEP_3P_Mosin_Green_Pickup_MIC"))

// Mosin Nagant Winter
    Skins.Add((Id=7861, Weapondef=class'KFWeapDef_MosinNagant', MIC_1P=("WEP_1P_Mosin_MAT.WEP_1P_Mosin_Winter_MIC"), MIC_3P="WEP_3P_Mosin_MAT.WEP_3P_Mosin_Winter_MIC", MIC_Pickup="WEP_3P_Mosin_MAT.WEP_3P_Mosin_Winter_Pickup_MIC"))

// Riot Shield and G18 Standard
    Skins.Add((Id=7850, Weapondef=class'KFWeapDef_G18', MIC_1P=("WEP_1P_RiotShield_MAT.WEP_1stp_Glock18c_MIC", "WEP_1P_RiotShield_MAT.WEP_1stp_RiotShield_MIC", "WEP_1P_RiotShield_MAT.Wep_1stp_Glass"), MIC_3P="WEP_3P_RiotShield_MAT.Wep_3rdp_RiotShield_MIC", MIC_Pickup="WEP_3P_RiotShield_MAT.Wep_3rdp_RiotShield_Pickup_MIC"))

// Riot Shield and G18 Desert
    Skins.Add((Id=7851, Weapondef=class'KFWeapDef_G18', MIC_1P=("WEP_1P_RiotShield_MAT.g18c.WEP_1P_G18C_Desert_MIC", "WEP_1P_RiotShield_MAT.Riotshield.WEP_1P_RiotShield_Desert_MIC", "WEP_1P_RiotShield_MAT.Wep_1stp_Glass"), MIC_3P="WEP_3P_RiotShield_MAT.WEP_3P_RiotShield_Desert_MIC", MIC_Pickup="WEP_3P_RiotShield_MAT.WEP_3P_RiotShield_Desert_Pickup_MIC"))

// Riot Shield and G18 Forest
    Skins.Add((Id=7852, Weapondef=class'KFWeapDef_G18', MIC_1P=("WEP_1P_RiotShield_MAT.g18c.WEP_1P_G18C_Forest_MIC", "WEP_1P_RiotShield_MAT.Riotshield.WEP_1P_RiotShield_Forest_MIC", "WEP_1P_RiotShield_MAT.Wep_1stp_Glass"), MIC_3P="WEP_3P_RiotShield_MAT.WEP_3P_RiotShield_Forest_MIC", MIC_Pickup="WEP_3P_RiotShield_MAT.WEP_3P_RiotShield_Forest_Pickup_MIC"))

// Riot Shield and G18 VIGIL
    Skins.Add((Id=7853, Weapondef=class'KFWeapDef_G18', MIC_1P=("WEP_1P_RiotShield_MAT.g18c.WEP_1P_G18C_VIGIL_MIC", "WEP_1P_RiotShield_MAT.Riotshield.WEP_1P_RiotShield_VIGIL_MIC", "WEP_1P_RiotShield_MAT.Wep_1stp_Glass"), MIC_3P="WEP_3P_RiotShield_MAT.WEP_3P_RiotShield_VIGIL_MIC", MIC_Pickup="WEP_3P_RiotShield_MAT.WEP_3P_RiotShield_VIGIL_Pickup_MIC"))

// Riot Shield and G18 Winter
    Skins.Add((Id=7854, Weapondef=class'KFWeapDef_G18', MIC_1P=("WEP_1P_RiotShield_MAT.g18c.WEP_1P_G18C_Winter_MIC", "WEP_1P_RiotShield_MAT.Riotshield.WEP_1P_RiotShield_Winter_MIC", "WEP_1P_RiotShield_MAT.Wep_1stp_Glass"), MIC_3P="WEP_3P_RiotShield_MAT.WEP_3P_RiotShield_Winter_MIC", MIC_Pickup="WEP_3P_RiotShield_MAT.WEP_3P_RiotShield_Winter_Pickup_MIC"))

// Riot Shield and G18 SWAT
    Skins.Add((Id=7855, Weapondef=class'KFWeapDef_G18', MIC_1P=("WEP_1P_RiotShield_MAT.g18c.WEP_1P_G18C_SWAT_MIC", "WEP_1P_RiotShield_MAT.Riotshield.WEP_1P_RiotShield_SWAT_MIC", "WEP_1P_RiotShield_MAT.Wep_1stp_Glass"), MIC_3P="WEP_3P_RiotShield_MAT.WEP_3P_RiotShield_SWAT_MIC", MIC_Pickup="WEP_3P_RiotShield_MAT.WEP_3P_RiotShield_SWAT_Pickup_MIC"))

//Vault Vosh Chainbat
    Skins.Add((Id=8037, Weapondef=class'KFWeapDef_ChainBat', MIC_1P=("WEP_SkinSet_VaultVosh10_MAT.vosh_chainbat.Vault_Vosh_Chainbat_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh10_MAT.vosh_chainbat.Vault_Vosh_Chainbat_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh10_MAT.vosh_chainbat.Vault_Vosh_Chainbat_3P_Pickup_MIC"))

//Vault Vosh Static Strikers
    Skins.Add((Id=8038, Weapondef=class'KFWeapDef_PowerGloves', MIC_1P=("WEP_SkinSet_VaultVosh10_MAT.vosh_staticstrikers.Vault_Vosh_StaticStrikers_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh10_MAT.vosh_staticstrikers.Vault_Vosh_StaticStrikers_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh10_MAT.vosh_staticstrikers.Vault_Vosh_StaticStrikers_3P_Pickup_MIC"))

//Vault Vosh Stoner 63A
    Skins.Add((Id=8039, Weapondef=class'KFWeapDef_Stoner63A', MIC_1P=("WEP_SkinSet_VaultVosh10_MAT.vosh_stoner63a.Vault_Vosh_Stoner63a_1P_MIC", "WEP_SkinSet_VaultVosh10_MAT.vosh_stoner63a.Vault_Vosh_Stoner63a_Receiver_1P_MIC"), MIC_3P="WEP_SkinSet_VaultVosh10_MAT.vosh_stoner63a.Vault_Vosh_Stoner63A_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh10_MAT.vosh_stoner63a.Vault_Vosh_Stoner63A_3P_Pickup_MIC"))

//Vault Vosh Tommy Gun
    Skins.Add((Id=8040, Weapondef=class'KFWeapDef_Thompson', MIC_1P=("WEP_SkinSet_VaultVosh10_MAT.vosh_thompson.Vault_Vosh_Thompson_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh10_MAT.vosh_thompson.Vault_Vosh_Thompson_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh10_MAT.vosh_thompson.Vault_Vosh_Thompson_3P_Pickup_MIC"))

//Vault Vosh Zweihander
    Skins.Add((Id=8041, Weapondef=class'KFWeapDef_Zweihander', MIC_1P=("WEP_SkinSet_VaultVosh10_MAT.vosh_zweihander.Vault_Vosh_Zweihander_1P_Mint_MIC"), MIC_3P="WEP_SkinSet_VaultVosh10_MAT.vosh_zweihander.Vault_Vosh_Zweihander_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet_VaultVosh10_MAT.vosh_zweihander.Vault_Vosh_Zweihander_3P_Pickup_MIC"))

//Jaeger Dynamic AF2011
    Skins.Add((Id=8089, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_AF2011', MIC_1P=("WEP_SkinSet28_MAT.dynamic_af2011.Dynamic_AF2011_1P_Mint_MIC"), MIC_3P="WEP_SkinSet28_MAT.dynamic_af2011.Dynamic_AF2011_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet28_MAT.dynamic_af2011.Dynamic_AF2011_3P_Pickup_MIC"))

//Jaeger Dynamic AK12
    Skins.Add((Id=8090, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet28_MAT.dynamic_ak12.Dynamic_AK12_1P_Mint_MIC", "WEP_SkinSet28_MAT.dynamic_ak12.Dynamic_AK12_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet28_MAT.dynamic_ak12.Dynamic_AK12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet28_MAT.dynamic_ak12.Dynamic_AK12_3P_Pickup_MIC"))

//Jaeger Dynamic HK UMP
    Skins.Add((Id=8091, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HK_UMP', MIC_1P=("WEP_SkinSet28_MAT.dynamic_hk_ump.Dynamic_HK_UMP_1P_Mint_MIC", "WEP_SkinSet28_MAT.dynamic_hk_ump.Dynamic_HK_UMP_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet28_MAT.dynamic_hk_ump.Dynamic_HK_UMP_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet28_MAT.dynamic_hk_ump.Dynamic_HK_UMP_3P_Pickup_MIC"))

//Jaeger Dynamic HZ12
    Skins.Add((Id=8092, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HZ12', MIC_1P=("WEP_SkinSet28_MAT.dynamic_hz12.Dynamic_HZ12_1P_Mint_MIC"), MIC_3P="WEP_SkinSet28_MAT.dynamic_hz12.Dynamic_HZ12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet28_MAT.dynamic_hz12.Dynamic_HZ12_3P_Pickup_MIC"))

//Jaeger Dynamic M16M203
    Skins.Add((Id=8093, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_M16M203', MIC_1P=("WEP_SkinSet28_MAT.dynamic_m16m203.Dynamic_M16_1P_Mint_MIC", "WEP_SkinSet28_MAT.dynamic_m16m203.Dynamic_M203_1P_Mint_MIC"), MIC_3P="WEP_SkinSet28_MAT.dynamic_m16m203.Dynamic_M16M203_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet28_MAT.dynamic_m16m203.Dynamic_M16M203_3P_Pickup_MIC"))

//Jaeger Dynamic M1911
    Skins.Add((Id=8094, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Colt1911', MIC_1P=("WEP_SkinSet28_MAT.dynamic_m1911.Dynamic_M1911_1P_Mint_MIC"), MIC_3P="WEP_SkinSet28_MAT.dynamic_m1911.Dynamic_M1911_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet28_MAT.dynamic_m1911.Dynamic_M1911_3P_Pickup_MIC"))

//Jaeger Dynamic Mac 10
    Skins.Add((Id=8095, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Mac10', MIC_1P=("WEP_SkinSet28_MAT.dynamic_mac10.Dynamic_MAC10_1P_Mint_MIC"), MIC_3P="WEP_SkinSet28_MAT.dynamic_mac10.Dynamic_MAC10_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet28_MAT.dynamic_mac10.Dynamic_MAC10_3P_Pickup_MIC"))

//Jaeger Dynamic HMTech-501 Grenade Rifle
    Skins.Add((Id=8096, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MedicRifleGrenadeLauncher', MIC_1P=("WEP_SkinSet28_MAT.dynamic_medicgrenaderifle.Dynamic_MedicGrenadeRifle_1P_Mint_MIC"), MIC_3P="WEP_SkinSet28_MAT.dynamic_medicgrenaderifle.Dynamic_MedicGrenadeRifle_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet28_MAT.dynamic_medicgrenaderifle.Dynamic_MedicGrenadeRifle_3P_Pickup_MIC"))

//Jaeger Dynamic SW500
    Skins.Add((Id=8097, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_SW500', MIC_1P=("WEP_SkinSet28_MAT.dynamic_sw500.Dynamic_SW500_1P_Mint_MIC"), MIC_3P="WEP_SkinSet28_MAT.dynamic_sw500.Dynamic_SW500_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet28_MAT.dynamic_sw500.Dynamic_SW500_3P_Pickup_MIC"))

//Jaeger Dynamic Tommy Gun
    Skins.Add((Id=8098, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Thompson', MIC_1P=("WEP_SkinSet28_MAT.dynamic_tommygun.Dynamic_TommyGun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet28_MAT.dynamic_tommygun.Dynamic_TommyGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet28_MAT.dynamic_tommygun.Dynamic_TommyGun_3P_Pickup_MIC"))

//Jaeger Dynamic AA12
    Skins.Add((Id=8099, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet28_MAT.dynamic_aa12.Dynamic_AA12_1P_Mint_MIC"), MIC_3P="WEP_SkinSet28_MAT.dynamic_aa12.Dynamic_AA12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet28_MAT.dynamic_aa12.Dynamic_AA12_3P_Pickup_MIC"))

//Jaeger Dynamic RGB AF2011
    Skins.Add((Id=8100, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_AF2011', MIC_1P=("WEP_SkinSet28_MAT.dynamicrgb_af2011.DynamicRGB_AF2011_1P_Mint_MIC"), MIC_3P="WEP_SkinSet28_MAT.dynamicrgb_af2011.DynamicRGB_AF2011_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet28_MAT.dynamicrgb_af2011.DynamicRGB_AF2011_3P_Pickup_MIC"))

//Jaeger Dynamic RGB AK12
    Skins.Add((Id=8101, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet28_MAT.dynamicrgb_ak12.DynamicRGB_AK12_1P_Mint_MIC", "WEP_SkinSet28_MAT.dynamicrgb_ak12.DynamicRGB_AK12_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet28_MAT.dynamicrgb_ak12.DynamicRGB_AK12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet28_MAT.dynamicrgb_ak12.DynamicRGB_AK12_3P_Pickup_MIC"))

//Jaeger Dynamic RGB HK UMP
    Skins.Add((Id=8102, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HK_UMP', MIC_1P=("WEP_SkinSet28_MAT.dynamicrgb_hk_ump.DynamicRGB_HK_UMP_1P_Mint_MIC", "WEP_SkinSet28_MAT.dynamicrgb_hk_ump.DynamicRGB_HK_UMP_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet28_MAT.dynamicrgb_hk_ump.DynamicRGB_HK_UMP_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet28_MAT.dynamicrgb_hk_ump.DynamicRGB_HK_UMP_3P_Pickup_MIC"))

//Jaeger Dynamic RGB HZ12
    Skins.Add((Id=8103, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HZ12', MIC_1P=("WEP_SkinSet28_MAT.dynamicrgb_hz12.DynamicRGB_HZ12_1P_Mint_MIC"), MIC_3P="WEP_SkinSet28_MAT.dynamicrgb_hz12.DynamicRGB_HZ12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet28_MAT.dynamicrgb_hz12.DynamicRGB_HZ12_3P_Pickup_MIC"))

//Jaeger Dynamic RGB M16M203
    Skins.Add((Id=8104, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_M16M203', MIC_1P=("WEP_SkinSet28_MAT.dynamicrgb_m16m203.DynamicRGB_M16_1P_Mint_MIC", "WEP_SkinSet28_MAT.dynamicrgb_m16m203.DynamicRGB_M203_1P_Mint_MIC"), MIC_3P="WEP_SkinSet28_MAT.dynamicrgb_m16m203.DynamicRGB_M16M203_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet28_MAT.dynamicrgb_m16m203.DynamicRGB_M16M203_3P_Pickup_MIC"))

//Jaeger Dynamic RGB M1911
    Skins.Add((Id=8105, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Colt1911', MIC_1P=("WEP_SkinSet28_MAT.dynamicrgb_m1911.DynamicRGB_M1911_1P_Mint_MIC"), MIC_3P="WEP_SkinSet28_MAT.dynamicrgb_m1911.DynamicRGB_M1911_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet28_MAT.dynamicrgb_m1911.DynamicRGB_M1911_3P_Pickup_MIC"))

//Jaeger Dynamic RGB Mac 10
    Skins.Add((Id=8106, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Mac10', MIC_1P=("WEP_SkinSet28_MAT.dynamicrgb_mac10.DynamicRGB_MAC10_1P_Mint_MIC"), MIC_3P="WEP_SkinSet28_MAT.dynamicrgb_mac10.DynamicRGB_MAC10_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet28_MAT.dynamicrgb_mac10.DynamicRGB_MAC10_3P_Pickup_MIC"))

//Jaeger Dynamic RGB HMTech-501 Grenade Rifle
    Skins.Add((Id=8107, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MedicRifleGrenadeLauncher', MIC_1P=("WEP_SkinSet28_MAT.dynamicrgb_medicgrenaderifle.DynamicRGB_MedicGrenadeRifle_1P_Mint_MIC"), MIC_3P="WEP_SkinSet28_MAT.dynamicrgb_medicgrenaderifle.DynamicRGB_MedicGrenadeRifle_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet28_MAT.dynamicrgb_medicgrenaderifle.DynamicRGB_MedicGrenadeRifle_3P_Pickup_MIC"))

//Jaeger Dynamic RGB SW500
    Skins.Add((Id=8108, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_SW500', MIC_1P=("WEP_SkinSet28_MAT.dynamicrgb_sw500.DynamicRGB_SW500_1P_Mint_MIC"), MIC_3P="WEP_SkinSet28_MAT.dynamicrgb_sw500.DynamicRGB_SW500_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet28_MAT.dynamicrgb_sw500.DynamicRGB_SW500_3P_Pickup_MIC"))

//Jaeger Dynamic RGB Tommy Gun
    Skins.Add((Id=8109, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Thompson', MIC_1P=("WEP_SkinSet28_MAT.dynamicrgb_tommygun.DynamicRGB_TommyGun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet28_MAT.dynamicrgb_tommygun.DynamicRGB_TommyGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet28_MAT.dynamicrgb_tommygun.DynamicRGB_TommyGun_3P_Pickup_MIC"))

//Jaeger Dynamic RGB AA12
    Skins.Add((Id=8110, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet28_MAT.dynamicrgb_aa12.DynamicRGB_AA12_1P_Mint_MIC"), MIC_3P="WEP_SkinSet28_MAT.dynamicrgb_aa12.DynamicRGB_AA12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet28_MAT.dynamicrgb_aa12.DynamicRGB_AA12_3P_Pickup_MIC"))

//Spectre HRG Dynamic HRG Freeze Thrower (HealThrower)
    Skins.Add((Id=8135, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Healthrower_HRG', MIC_1P=("WEP_SkinSet29_MAT.spectre_hrgcryogun.Spectre_HRGCryoGun_Alt_1P_Mint_MIC", "WEP_SkinSet29_MAT.spectre_hrgcryogun.Spectre_HRGCryoGun_Main_1P_Mint_MIC"), MIC_3P="WEP_SkinSet29_MAT.spectre_hrgcryogun.Spectre_HRGCryoGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet29_MAT.spectre_hrgcryogun.Spectre_HRGCryoGun_3P_Pickup_MIC"))

//Spectre HRG Dynamic HRG FlareGun (Winterbites)
    Skins.Add((Id=8136, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HRGWinterbite', MIC_1P=("WEP_SkinSet29_MAT.spectre_hrgflaregun.Spectre_HRGFlaregun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet29_MAT.spectre_hrgflaregun.Spectre_HRGFlaregun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet29_MAT.spectre_hrgflaregun.Spectre_HRGFlaregun_3P_Pickup_MIC"))

//Spectre HRG Dynamic HRG Nailgun
    Skins.Add((Id=8137, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_NailGun_HRG', MIC_1P=("WEP_SkinSet29_MAT.spectre_hrgnailgun.Spectre_HRGNailgun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet29_MAT.spectre_hrgnailgun.Spectre_HRGNailgun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet29_MAT.spectre_hrgnailgun.Spectre_HRGNailgun_3P_Pickup_MIC"))

//Spectre HRG Dynamic HRG Railgun (Incision)
    Skins.Add((Id=8138, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HRGIncision', MIC_1P=("WEP_SkinSet29_MAT.spectre_hrgrailgun.Spectre_HRGRailgun_1P_Mint_MIC", "WEP_SkinSet29_MAT.spectre_hrgrailgun.Spectre_HRGRailgun_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet29_MAT.spectre_hrgrailgun.Spectre_HRGRailgun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet29_MAT.spectre_hrgrailgun.Spectre_HRGRailgun_3P_Pickup_MIC"))

//Spectre HRG Dynamic HRG SW500
    Skins.Add((Id=8139, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_SW500_HRG', MIC_1P=("WEP_SkinSet29_MAT.spectre_hrgsw500.Spectre_HRGSW500_1P_Mint_MIC"), MIC_3P="WEP_SkinSet29_MAT.spectre_hrgsw500.Spectre_HRGSW500_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet29_MAT.spectre_hrgsw500.Spectre_HRGSW500_3P_Pickup_MIC"))

//Spectre HRG Dynamic Chroma HRG Freeze Thrower (HealThrower)
    Skins.Add((Id=8140, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Healthrower_HRG', MIC_1P=("WEP_SkinSet29_MAT.spectrechroma_hrgcryogun.SpectreChroma_HRGCryoGun_Alt_1P_Mint_MIC", "WEP_SkinSet29_MAT.spectrechroma_hrgcryogun.SpectreChroma_HRGCryoGun_Main_1P_Mint_MIC"), MIC_3P="WEP_SkinSet29_MAT.spectrechroma_hrgcryogun.SpectreChroma_HRGCryoGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet29_MAT.spectrechroma_hrgcryogun.SpectreChroma_HRGCryoGun_3P_Pickup_MIC"))

//Spectre HRG Dynamic Chroma HRG FlareGun (Winterbites)
    Skins.Add((Id=8141, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HRGWinterbite', MIC_1P=("WEP_SkinSet29_MAT.spectrechroma_hrgflaregun.SpectreChroma_HRGFlaregun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet29_MAT.spectrechroma_hrgflaregun.SpectreChroma_HRGFlaregun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet29_MAT.spectrechroma_hrgflaregun.SpectreChroma_HRGFlaregun_3P_Pickup_MIC"))

//Spectre HRG Dynamic Chroma HRG Nailgun
    Skins.Add((Id=8142, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_NailGun_HRG', MIC_1P=("WEP_SkinSet29_MAT.spectrechroma_hrgnailgun.SpectreChroma_HRGNailgun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet29_MAT.spectrechroma_hrgnailgun.SpectreChroma_HRGNailgun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet29_MAT.spectrechroma_hrgnailgun.SpectreChroma_HRGNailgun_3P_Pickup_MIC"))

//Spectre HRG Dynamic Chroma HRG Railgun (Incision)
    Skins.Add((Id=8143, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HRGIncision', MIC_1P=("WEP_SkinSet29_MAT.spectrechroma_hrgrailgun.SpectreChroma_HRGRailgun_1P_Mint_MIC", "WEP_SkinSet29_MAT.spectrechroma_hrgrailgun.SpectreChroma_HRGRailgun_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet29_MAT.spectrechroma_hrgrailgun.SpectreChroma_HRGRailgun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet29_MAT.spectrechroma_hrgrailgun.SpectreChroma_HRGRailgun_3P_Pickup_MIC"))

//Spectre HRG Dynamic Chroma HRG SW500
    Skins.Add((Id=8144, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_SW500_HRG', MIC_1P=("WEP_SkinSet29_MAT.spectrechroma_hrgsw500.SpectreChroma_HRGSW500_1P_Mint_MIC"), MIC_3P="WEP_SkinSet29_MAT.spectrechroma_hrgsw500.SpectreChroma_HRGSW500_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet29_MAT.spectrechroma_hrgsw500.SpectreChroma_HRGSW500_3P_Pickup_MIC"))

// Camo Compound Bow
	Skins.Add((Id=8145, Weapondef=class'KFWeapDef_CompoundBow', MIC_1P=("WEP_SkinSet30_MAT.Wep_1stP_CompoundBow_Camo_MIC"), MIC_3P="WEP_SkinSet30_MAT.Wep_3rdP_CompoundBow_Camo_MIC", MIC_Pickup="WEP_SkinSet30_MAT.Wep_3rdP_CompoundBow_Camo_Pickup_MIC"))

// Carbon Compound Bow
	Skins.Add((Id=8146, Weapondef=class'KFWeapDef_CompoundBow', MIC_1P=("WEP_SkinSet30_MAT.Wep_1stP_CompoundBow_Carbon_MIC"), MIC_3P="WEP_SkinSet30_MAT.Wep_3rdP_CompoundBow_Carbon_MIC", MIC_Pickup="WEP_SkinSet30_MAT.Wep_3rdP_CompoundBow_Carbon_Pickup_MIC"))

// Gore Compound Bow
	Skins.Add((Id=8147, Weapondef=class'KFWeapDef_CompoundBow', MIC_1P=("WEP_SkinSet30_MAT.Wep_1stP_CompoundBow_Gore_MIC"), MIC_3P="WEP_SkinSet30_MAT.Wep_3rdP_CompoundBow_Gore_MIC", MIC_Pickup="WEP_SkinSet30_MAT.Wep_3rdP_CompoundBow_Gore_Pickup_MIC"))

// Snow Ops Compound Bow
	Skins.Add((Id=8148, Weapondef=class'KFWeapDef_CompoundBow', MIC_1P=("WEP_SkinSet30_MAT.Wep_1stP_CompoundBow_SnowOps_MIC"), MIC_3P="WEP_SkinSet30_MAT.Wep_3rdP_CompoundBow_SnowOps_MIC", MIC_Pickup="WEP_SkinSet30_MAT.Wep_3rdP_CompoundBow_SnowOps_Pickup_MIC"))

// Sticker Stricker Compound Bow
	Skins.Add((Id=8149, Weapondef=class'KFWeapDef_CompoundBow', MIC_1P=("WEP_SkinSet30_MAT.Wep_1stP_CompoundBow_StickerStriker_MIC"), MIC_3P="WEP_SkinSet30_MAT.Wep_3rdP_CompoundBow_StickerStriker_MIC", MIC_Pickup="WEP_SkinSet30_MAT.Wep_3rdP_CompoundBow_StickerStriker_Pickup_MIC"))

// Standard Compound Bow
	Skins.Add((Id=8169, Weapondef=class'KFWeapDef_CompoundBow', MIC_1P=("WEP_SkinSet30_MAT.Wep_1stP_CompoundBow_MIC"), MIC_3P="WEP_SkinSet30_MAT.Wep_3rdP_CompoundBow_MIC", MIC_Pickup="WEP_SkinSet30_MAT.Wep_CompoundBow_Pickup_MIC"))

//Neon Killerwatt
    Skins.Add((Id=8191, Weapondef=class'KFWeapDef_LazerCutter', MIC_1P=("WEP_SkinSet31_MAT.neon_lasercutter.Neon_LaserCutter_Optic_1P_Mint_MIC", "WEP_SkinSet31_MAT.neon_lasercutter.Neon_LaserCutter_1P_Mint_MIC"), MIC_3P="WEP_SkinSet31_MAT.neon_lasercutter.Neon_LaserCutter_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet31_MAT.neon_lasercutter.Neon_LaserCutter_3P_Pickup_MIC")) 

//Neon Seal Squeal
    Skins.Add((Id=8192, Weapondef=class'KFWeapDef_SealSqueal', MIC_1P=("WEP_SkinSet31_MAT.neon_sealsqueal.Neon_SealSqueal_1P_Mint_MIC"), MIC_3P="WEP_SkinSet31_MAT.neon_sealsqueal.Neon_SealSqueal_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet31_MAT.neon_sealsqueal.Neon_SealSqueal_3P_Pickup_MIC")) 

//Neon Winchester 1894
    Skins.Add((Id=8193, Weapondef=class'KFWeapDef_Winchester1894', MIC_1P=("WEP_SkinSet31_MAT.neon_winchester.Neon_Winchester_1P_Mint_MIC"), MIC_3P="WEP_SkinSet31_MAT.neon_winchester.Neon_Winchester_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet31_MAT.neon_winchester.Neon_Winchester_3P_Pickup_MIC")) 

//Neon Helios Rifle
    Skins.Add((Id=8194, Weapondef=class'KFWeapDef_MicrowaveRifle', MIC_1P=("WEP_SkinSet31_MAT.neon_microwaveassault.Neon_MicrowaveAssault_1P_Mint_MIC"), MIC_3P="WEP_SkinSet31_MAT.neon_microwaveassault.Neon_MicrowaveAssault_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet31_MAT.neon_microwaveassault.Neon_MicrowaveAssault_3P_Pickup_MIC")) 

//Neon Spitfire
    Skins.Add((Id=8195, Weapondef=class'KFWeapDef_Flaregun', MIC_1P=("WEP_SkinSet31_MAT.neon_flaregun.Neon_FlareGun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet31_MAT.neon_flaregun.Neon_FlareGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet31_MAT.neon_flaregun.Neon_FlareGun_3P_Pickup_MIC")) 

//Neon VLAD-1000 Nailgun
    Skins.Add((Id=8196, Weapondef=class'KFWeapDef_NailGun', MIC_1P=("WEP_SkinSet31_MAT.neon_nailgun.Neon_Nailgun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet31_MAT.neon_nailgun.Neon_Nailgun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet31_MAT.neon_nailgun.Neon_Nailgun_3P_Pickup_MIC")) 

//Neon L85A2
    Skins.Add((Id=8197, Weapondef=class'KFWeapDef_Bullpup', MIC_1P=("WEP_SkinSet31_MAT.neon_l85a2.Neon_L85A2_1P_Mint_MIC", "WEP_SkinSet31_MAT.neon_l85a2.Neon_L85A2_Optic_1P_Mint_MIC"), MIC_3P="WEP_SkinSet31_MAT.neon_l85a2.Neon_L85A2_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet31_MAT.neon_l85a2.Neon_L85A2_3P_Pickup_MIC")) 

//Neon Pulverizer
    Skins.Add((Id=8198, Weapondef=class'KFWeapDef_Pulverizer', MIC_1P=("WEP_SkinSet31_MAT.neon_pulverizer.Neon_Pulverizer_1P_Mint_MIC"), MIC_3P="WEP_SkinSet31_MAT.neon_pulverizer.Neon_Pulverizer_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet31_MAT.neon_pulverizer.Neon_Pulverizer_3P_Pickup_MIC")) 

//Neon M79
    Skins.Add((Id=8199, Weapondef=class'KFWeapDef_M79', MIC_1P=("WEP_SkinSet31_MAT.neon_m79.Neon_M79_1P_Mint_MIC"), MIC_3P="WEP_SkinSet31_MAT.neon_m79.Neon_M79_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet31_MAT.neon_m79.Neon_M79_3P_Pickup_MIC")) 

//Neon Hemoclobber
    Skins.Add((Id=8200, Weapondef=class'KFWeapDef_MedicBat', MIC_1P=("WEP_SkinSet31_MAT.neon_medicbat.Neon_MedicBat_1P_Mint_MIC"), MIC_3P="WEP_SkinSet31_MAT.neon_medicbat.Neon_MedicBat_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet31_MAT.neon_medicbat.Neon_MedicBat_3P_Pickup_MIC")) 

//Neon RGB Killerwatt
    Skins.Add((Id=8201, Weapondef=class'KFWeapDef_LazerCutter', MIC_1P=("WEP_SkinSet31_MAT.neonrgb_lasercutter.NeonRGB_LaserCutter_Optic_1P_Mint_MIC", "WEP_SkinSet31_MAT.neonrgb_lasercutter.NeonRGB_LaserCutter_1P_Mint_MIC"), MIC_3P="WEP_SkinSet31_MAT.neonrgb_lasercutter.NeonRGB_LaserCutter_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet31_MAT.neonrgb_lasercutter.NeonRGB_LaserCutter_3P_Pickup_MIC")) 

//Neon RGB Seal Squeal
    Skins.Add((Id=8202, Weapondef=class'KFWeapDef_SealSqueal', MIC_1P=("WEP_SkinSet31_MAT.neonrgb_sealsqueal.NeonRGB_SealSqueal_1P_Mint_MIC"), MIC_3P="WEP_SkinSet31_MAT.neonrgb_sealsqueal.NeonRGB_SealSqueal_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet31_MAT.neonrgb_sealsqueal.NeonRGB_SealSqueal_3P_Pickup_MIC")) 

//Neon RGB Winchester 1894
    Skins.Add((Id=8203, Weapondef=class'KFWeapDef_Winchester1894', MIC_1P=("WEP_SkinSet31_MAT.neonrgb_winchester.NeonRGB_Winchester_1P_Mint_MIC"), MIC_3P="WEP_SkinSet31_MAT.neonrgb_winchester.NeonRGB_Winchester_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet31_MAT.neonrgb_winchester.NeonRGB_Winchester_3P_Pickup_MIC")) 

//Neon RGB Helios Rifle
    Skins.Add((Id=8204, Weapondef=class'KFWeapDef_MicrowaveRifle', MIC_1P=("WEP_SkinSet31_MAT.neonrgb_microwaveassault.NeonRGB_MicrowaveAssault_1P_Mint_MIC"), MIC_3P="WEP_SkinSet31_MAT.neonrgb_microwaveassault.NeonRGB_MicrowaveAssault_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet31_MAT.neonrgb_microwaveassault.NeonRGB_MicrowaveAssault_3P_Pickup_MIC")) 

//Neon RGB Spitfire
    Skins.Add((Id=8205, Weapondef=class'KFWeapDef_Flaregun', MIC_1P=("WEP_SkinSet31_MAT.neonrgb_flaregun.NeonRGB_FlareGun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet31_MAT.neonrgb_flaregun.NeonRGB_FlareGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet31_MAT.neonrgb_flaregun.NeonRGB_FlareGun_3P_Pickup_MIC")) 

//Neon RGB VLAD-1000 Nailgun
    Skins.Add((Id=8206, Weapondef=class'KFWeapDef_NailGun', MIC_1P=("WEP_SkinSet31_MAT.neonrgb_nailgun.NeonRGB_Nailgun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet31_MAT.neonrgb_nailgun.NeonRGB_Nailgun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet31_MAT.neonrgb_nailgun.NeonRGB_Nailgun_3P_Pickup_MIC")) 

//Neon RGB L85A2
    Skins.Add((Id=8207, Weapondef=class'KFWeapDef_Bullpup', MIC_1P=("WEP_SkinSet31_MAT.neonrgb_l85a2.NeonRGB_L85A2_1P_Mint_MIC", "WEP_SkinSet31_MAT.neonrgb_l85a2.NeonRGB_L85A2_Optic_1P_Mint_MIC"), MIC_3P="WEP_SkinSet31_MAT.neonrgb_l85a2.NeonRGB_L85A2_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet31_MAT.neonrgb_l85a2.NeonRGB_L85A2_3P_Pickup_MIC")) 

//Neon RGB Pulverizer
    Skins.Add((Id=8208, Weapondef=class'KFWeapDef_Pulverizer', MIC_1P=("WEP_SkinSet31_MAT.neonrgb_pulverizer.NeonRGB_Pulverizer_1P_Mint_MIC"), MIC_3P="WEP_SkinSet31_MAT.neonrgb_pulverizer.NeonRGB_Pulverizer_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet31_MAT.neonrgb_pulverizer.NeonRGB_Pulverizer_3P_Pickup_MIC")) 

//Neon RGB M79
    Skins.Add((Id=8209, Weapondef=class'KFWeapDef_M79', MIC_1P=("WEP_SkinSet31_MAT.neonrgb_m79.NeonRGB_M79_1P_Mint_MIC"), MIC_3P="WEP_SkinSet31_MAT.neonrgb_m79.NeonRGB_M79_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet31_MAT.neonrgb_m79.NeonRGB_M79_3P_Pickup_MIC")) 

//Neon RGB Hemoclobber
    Skins.Add((Id=8210, Weapondef=class'KFWeapDef_MedicBat', MIC_1P=("WEP_SkinSet31_MAT.neonrgb_medicbat.NeonRGB_MedicBat_1P_Mint_MIC"), MIC_3P="WEP_SkinSet31_MAT.neonrgb_medicbat.NeonRGB_MedicBat_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet31_MAT.neonrgb_medicbat.NeonRGB_MedicBat_3P_Pickup_MIC")) 
	
//Blunderbuss Standard
    Skins.Add((Id=8299, Weapondef=class'KFWeapDef_Blunderbuss', MIC_1P=("wep_1p_blunderbuss_mat.Wep_1stP_Blunderbuss_MIC"), MIC_3P="WEP_3P_Blunderbuss_MAT.Wep_3rdP_Blunderbuss_MIC", MIC_Pickup="WEP_3P_Blunderbuss_MAT.Wep_Blunderbuss_Pickup_MIC")) 
	
//Blunderbuss Rotten
    Skins.Add((Id=8300, Weapondef=class'KFWeapDef_Blunderbuss', MIC_1P=("wep_skinset33_mat.Wep_1stP_Blunderbuss_Rotten_MIC"), MIC_3P="wep_skinset33_mat.Wep_3rdP_Blunderbuss_Rotten_MIC", MIC_Pickup="wep_skinset33_mat.Wep_3rdP_Blunderbuss_Rotten_Pickup_MIC")) 

//Blunderbuss Goldenboy
    Skins.Add((Id=8301, Weapondef=class'KFWeapDef_Blunderbuss', MIC_1P=("wep_skinset33_mat.Wep_1stP_Blunderbuss_Goldenboy_MIC"), MIC_3P="wep_skinset33_mat.Wep_3rdP_Blunderbuss_Goldenboy_MIC", MIC_Pickup="wep_skinset33_mat.Wep_3rdP_Blunderbuss_Goldenboy_Pickup_MIC")) 

//Blunderbuss Inferno
    Skins.Add((Id=8302, Weapondef=class'KFWeapDef_Blunderbuss', MIC_1P=("wep_skinset33_mat.Wep_1stP_Blunderbuss_Inferno_MIC"), MIC_3P="wep_skinset33_mat.Wep_3rdP_Blunderbuss_Inferno_MIC", MIC_Pickup="wep_skinset33_mat.Wep_3rdP_Blunderbuss_Inferno_Pickup_MIC")) 

//Blunderbuss Jeque
    Skins.Add((Id=8303, Weapondef=class'KFWeapDef_Blunderbuss', MIC_1P=("wep_skinset33_mat.Wep_1stP_Blunderbuss_Jeque_MIC"), MIC_3P="wep_skinset33_mat.Wep_3rdP_Blunderbuss_Jeque_MIC", MIC_Pickup="wep_skinset33_mat.Wep_3rdP_Blunderbuss_Jeque_Pickup_MIC")) 

//Blunderbuss Silver
    Skins.Add((Id=8304, Weapondef=class'KFWeapDef_Blunderbuss', MIC_1P=("wep_skinset33_mat.Wep_1stP_Blunderbuss_Silver_MIC"), MIC_3P="wep_skinset33_mat.Wep_3rdP_Blunderbuss_Silver_MIC", MIC_Pickup="wep_skinset33_mat.Wep_3rdP_Blunderbuss_Silver_Pickup_MIC")) 

//Glock18c Standard
    Skins.Add((Id=8293, Weapondef=class'KFWeapDef_Pistol_G18C', MIC_1P=("WEP_1P_Dual_G18C_MAT.Wep_1stP_Dual_G18C_MIC"), MIC_3P="wep_3p_dual_g18c_mat.Wep_3rdP_Dual_G18C_MIC", MIC_Pickup="wep_3p_dual_g18c_mat.Wep_Dual_G18C_Pickup_MIC")) 

//Glock18c Peppermint
    Skins.Add((Id=8294, Weapondef=class'KFWeapDef_Pistol_G18C', MIC_1P=("wep_skinset32_mat.Wep_1stP_Dual_G18C_Peppermint_MIC"), MIC_3P="WEP_SkinSet32_MAT.Wep_3rdP_Dual_G18C_Peppermint_MIC", MIC_Pickup="WEP_SkinSet32_MAT.Wep_3rdP_Dual_G18C_Peppermint_Pickup_MIC")) 

//Glock18c Gold Swat
    Skins.Add((Id=8295, Weapondef=class'KFWeapDef_Pistol_G18C', MIC_1P=("wep_skinset32_mat.Wep_1stP_Dual_G18C_Swat_MIC"), MIC_3P="WEP_SkinSet32_MAT.Wep_3rdP_Dual_G18C_Swat_MIC", MIC_Pickup="WEP_SkinSet32_MAT.Wep_3rdP_Dual_G18C_Swat_Pickup_MIC")) 

//Glock18c Bumblebee
    Skins.Add((Id=8296, Weapondef=class'KFWeapDef_Pistol_G18C', MIC_1P=("wep_skinset32_mat.Wep_1stP_Dual_G18C_Bumblebee_MIC"), MIC_3P="WEP_SkinSet32_MAT.Wep_3rdP_Dual_G18C_Bumblebee_MIC", MIC_Pickup="WEP_SkinSet32_MAT.Wep_3rdP_Dual_G18C_Bumblebee_Pickup_MIC")) 

//Glock18c Camo
    Skins.Add((Id=8297, Weapondef=class'KFWeapDef_Pistol_G18C', MIC_1P=("wep_skinset32_mat.Wep_1stP_Dual_G18C_Camo_MIC"), MIC_3P="WEP_SkinSet32_MAT.Wep_3rdP_Dual_G18C_Camo_MIC", MIC_Pickup="WEP_SkinSet32_MAT.Wep_3rdP_Dual_G18C_Camo_Pickup_MIC")) 

//Glock18c Gore
    Skins.Add((Id=8298, Weapondef=class'KFWeapDef_Pistol_G18C', MIC_1P=("wep_skinset32_mat.Wep_1stP_Dual_G18C_Gore_MIC"), MIC_3P="WEP_SkinSet32_MAT.Wep_3rdP_Dual_G18C_Gore_MIC", MIC_Pickup="WEP_SkinSet32_MAT.Wep_3rdP_Dual_G18C_Gore_Pickup_MIC")) 

//Vault Stars HMTech-101
    Skins.Add((Id=8305, Weapondef=class'KFWeapDef_MedicPistol', MIC_1P=("wep_skinset_vaultstars01_mat.Vault_Stars_1stP_Medic_Pistol_MIC"), MIC_3P="wep_skinset_vaultstars01_mat.Vault_Stars_3rdP_Medic_Pistol_MIC", MIC_Pickup="wep_skinset_vaultstars01_mat.Vault_Stars_3rdP_Medic_Pistol_Pickup_MIC")) 
	
//Vault Stars MKB42H
    Skins.Add((Id=8306, Weapondef=class'KFWeapDef_MKB42', MIC_1P=("wep_skinset_vaultstars01_mat.Vault_Stars_1stP_MKB42H_MIC"), MIC_3P="wep_skinset_vaultstars01_mat.Vault_Stars_3rdP_MKB42H_MIC", MIC_Pickup="wep_skinset_vaultstars01_mat.Vault_Stars_3rdP_MKB42H_Pickup_MIC")) 

//Vault Stars Tommy Gun
    Skins.Add((Id=8307, Weapondef=class'KFWeapDef_Thompson', MIC_1P=("wep_skinset_vaultstars01_mat.Vault_Stars_1stP_Thompson_MIC"), MIC_3P="wep_skinset_vaultstars01_mat.Vault_Stars_3rdP_Thompson_MIC", MIC_Pickup="wep_skinset_vaultstars01_mat.Vault_Stars_3rdP_Thompson_Pickup_MIC")) 

//Vault Stars Boomstick
    Skins.Add((Id=8308, Weapondef=class'KFWeapDef_DoubleBarrel', MIC_1P=("wep_skinset_vaultstars01_mat.Vault_Stars_1stP_Double_Barrel_MIC"), MIC_3P="wep_skinset_vaultstars01_mat.Vault_Stars_3rdP_Double_Barrel_MIC", MIC_Pickup="wep_skinset_vaultstars01_mat.Vault_Stars_3rdP_Double_Barrel_Pickup_MIC")) 

//Vault Stars M99
    Skins.Add((Id=8309, Weapondef=class'KFWeapDef_M99', MIC_1P=("wep_skinset_vaultstars01_mat.Vault_Stars_1stP_M99_MIC", "wep_skinset_vaultstars01_mat.Vault_Stars_1stP_M99_Scope_MIC"), MIC_3P="wep_skinset_vaultstars01_mat.Vault_Stars_3rdP_M99_MIC", MIC_Pickup="wep_skinset_vaultstars01_mat.Vault_Stars_3rdP_M99_Pickup_MIC")) 
	
//Vault Stars M1911
    Skins.Add((Id=8422, Weapondef=class'KFWeapDef_Colt1911', MIC_1P=("wep_skinset_vaultstars02_mat.Vault_Stars_1stP_Dual_M1911_MIC"), MIC_3P="wep_skinset_vaultstars02_mat.Vault_Stars_3rdP_Dual_M1911_MIC", MIC_Pickup="wep_skinset_vaultstars02_mat.Vault_Stars_3rdP_Dual_M1911_Pickup_MIC")) 
	
//Vault Stars AA12
    Skins.Add((Id=8425, Weapondef=class'KFWeapDef_AA12', MIC_1P=("wep_skinset_vaultstars02_mat.Vault_Stars_1stP_aa12_MIC"), MIC_3P="wep_skinset_vaultstars02_mat.Vault_Stars_3rdP_aa12_MIC", MIC_Pickup="wep_skinset_vaultstars02_mat.Vault_Stars_3rdP_aa12_Pickup_MIC")) 
	
//Vault Stars AK12
    Skins.Add((Id=8423, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("wep_skinset_vaultstars02_mat.Vault_Stars_1stP_ak112_MIC", "wep_skinset_vaultstars02_mat.Vault_Stars_1stP_ak112_kobra_MIC"), MIC_3P="wep_skinset_vaultstars02_mat.Vault_Stars_3rdP_ak112_MIC", MIC_Pickup="wep_skinset_vaultstars02_mat.Vault_Stars_3rdP_ak112_Pickup_MIC")) 
	
//Vault Stars Crovel
    Skins.Add((Id=8426, Weapondef=class'KFWeapDef_Crovel', MIC_1P=("wep_skinset_vaultstars02_mat.Vault_Stars_1stP_Crovel_MIC"), MIC_3P="wep_skinset_vaultstars02_mat.Vault_Stars_3rdP_Crovel_MIC", MIC_Pickup="wep_skinset_vaultstars02_mat.Vault_Stars_3rdP_Crovel_Pickup_MIC")) 
	
//Vault Stars MP5RAS
    Skins.Add((Id=8424, Weapondef=class'KFWeapDef_MP5RAS', MIC_1P=("wep_skinset_vaultstars02_mat.Vault_Stars_1stP_MP5RAS_MIC"), MIC_3P="wep_skinset_vaultstars02_mat.Vault_Stars_3rdP_MP5RAS_MIC", MIC_Pickup="wep_skinset_vaultstars02_mat.Vault_Stars_3rdP_MP5RAS_Pickup_MIC")) 

//Jaeger Dynamic Dragonsbreath
    Skins.Add((Id=8338, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Dragonsbreath', MIC_1P=("WEP_SkinSet34_MAT.dynamic_dragonsbreath.Dynamic_Dragonsbreath_1P_Mint_MIC"), MIC_3P="WEP_SkinSet34_MAT.dynamic_dragonsbreath.Dynamic_Dragonsbreath_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet34_MAT.dynamic_dragonsbreath.Dynamic_Dragonsbreath_3P_Pickup_MIC")) 

//Jaeger Dynamic MKb.42
    Skins.Add((Id=8339, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MKB42', MIC_1P=("WEP_SkinSet34_MAT.dynamic_mkb42.Dynamic_MKB42_1P_Mint_MIC"), MIC_3P="WEP_SkinSet34_MAT.dynamic_mkb42.Dynamic_MKB42_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet34_MAT.dynamic_mkb42.Dynamic_MKB42_3P_Pickup_MIC")) 

//Jaeger Dynamic Seal Squeal
    Skins.Add((Id=8340, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_SealSqueal', MIC_1P=("WEP_SkinSet34_MAT.dynamic_sealsqueal.Dynamic_SealSqueal_1P_Mint_MIC"), MIC_3P="WEP_SkinSet34_MAT.dynamic_sealsqueal.Dynamic_SealSqueal_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet34_MAT.dynamic_sealsqueal.Dynamic_SealSqueal_3P_Pickup_MIC")) 

//Jaeger Dynamic M32
    Skins.Add((Id=8341, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_M32', MIC_1P=("WEP_SkinSet34_MAT.dynamic_m32.Dynamic_M32_1P_Mint_MIC", "WEP_SkinSet34_MAT.dynamic_m32.Dynamic_M32_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet34_MAT.dynamic_m32.Dynamic_M32_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet34_MAT.dynamic_m32.Dynamic_M32_3P_Pickup_MIC")) 

//Jaeger Dynamic RPG-7
    Skins.Add((Id=8342, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_RPG7', MIC_1P=("WEP_SkinSet34_MAT.dynamic_rpg7.Dynamic_RPG7_1P_Mint_MIC"), MIC_3P="WEP_SkinSet34_MAT.dynamic_rpg7.Dynamic_RPG7_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet34_MAT.dynamic_rpg7.Dynamic_RPG7_3P_Pickup_MIC")) 

//Jaeger Dynamic VLAD-1000 Nailgun
    Skins.Add((Id=8343, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_NailGun', MIC_1P=("WEP_SkinSet34_MAT.dynamic_nailgun.Dynamic_Nailgun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet34_MAT.dynamic_nailgun.Dynamic_Nailgun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet34_MAT.dynamic_nailgun.Dynamic_Nailgun_3P_Pickup_MIC")) 

//Jaeger Dynamic M99
    Skins.Add((Id=8344, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_M99', MIC_1P=("WEP_SkinSet34_MAT.dynamic_m99.Dynamic_M99_1P_Mint_MIC", "WEP_SkinSet34_MAT.dynamic_m99.Dynamic_M99_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet34_MAT.dynamic_m99.Dynamic_M99_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet34_MAT.dynamic_m99.Dynamic_M99_3P_Pickup_MIC")) 

//Jaeger Dynamic Boomstick
    Skins.Add((Id=8345, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_DoubleBarrel', MIC_1P=("WEP_SkinSet34_MAT.dynamic_doublebarrel.Dynamic_DoubleBarrel_1P_Mint_MIC"), MIC_3P="WEP_SkinSet34_MAT.dynamic_doublebarrel.Dynamic_DoubleBarrel_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet34_MAT.dynamic_doublebarrel.Dynamic_DoubleBarrel_3P_Pickup_MIC")) 

//Jaeger Dynamic Flamethrower
    Skins.Add((Id=8346, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_FlameThrower', MIC_1P=("WEP_SkinSet34_MAT.dynamic_flamethrower.Dynamic_Flamethrower_1P_Mint_MIC"), MIC_3P="WEP_SkinSet34_MAT.dynamic_flamethrower.Dynamic_Flamethrower_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet34_MAT.dynamic_flamethrower.Dynamic_Flamethrower_3P_Pickup_MIC")) 

//Jaeger Dynamic Eviscerator
    Skins.Add((Id=8347, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Eviscerator', MIC_1P=("WEP_SkinSet34_MAT.dynamic_sawblade.Dynamic_SawBlade_1P_Mint_MIC"), MIC_3P="WEP_SkinSet34_MAT.dynamic_sawblade.Dynamic_SawBlade_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet34_MAT.dynamic_sawblade.Dynamic_SawBlade_3P_Pickup_MIC")) 

//Jaeger Dynamic RGB Dragonsbreath
    Skins.Add((Id=8348, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Dragonsbreath', MIC_1P=("WEP_SkinSet34_MAT.dynamicrgb_dragonsbreath.DynamicRGB_Dragonsbreath_1P_Mint_MIC"), MIC_3P="WEP_SkinSet34_MAT.dynamicrgb_dragonsbreath.DynamicRGB_Dragonsbreath_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet34_MAT.dynamicrgb_dragonsbreath.DynamicRGB_Dragonsbreath_3P_Pickup_MIC")) 

//Jaeger Dynamic RGB MKb.42
    Skins.Add((Id=8349, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MKB42', MIC_1P=("WEP_SkinSet34_MAT.dynamicrgb_mkb42.DynamicRGB_MKB42_1P_Mint_MIC"), MIC_3P="WEP_SkinSet34_MAT.dynamicrgb_mkb42.DynamicRGB_MKB42_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet34_MAT.dynamicrgb_mkb42.DynamicRGB_MKB42_3P_Pickup_MIC")) 

//Jaeger Dynamic RGB Seal Squeal
    Skins.Add((Id=8350, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_SealSqueal', MIC_1P=("WEP_SkinSet34_MAT.dynamicrgb_sealsqueal.DynamicRGB_SealSqueal_1P_Mint_MIC"), MIC_3P="WEP_SkinSet34_MAT.dynamicrgb_sealsqueal.DynamicRGB_SealSqueal_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet34_MAT.dynamicrgb_sealsqueal.DynamicRGB_SealSqueal_3P_Pickup_MIC")) 

//Jaeger Dynamic RGB M32
    Skins.Add((Id=8351, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_M32', MIC_1P=("WEP_SkinSet34_MAT.dynamicrgb_m32.DynamicRGB_M32_1P_Mint_MIC", "WEP_SkinSet34_MAT.dynamicrgb_m32.DynamicRGB_M32_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet34_MAT.dynamicrgb_m32.DynamicRGB_M32_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet34_MAT.dynamicrgb_m32.DynamicRGB_M32_3P_Pickup_MIC")) 

//Jaeger Dynamic RGB RPG-7
    Skins.Add((Id=8352, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_RPG7', MIC_1P=("WEP_SkinSet34_MAT.dynamicrgb_rpg7.DynamicRGB_RPG7_1P_Mint_MIC"), MIC_3P="WEP_SkinSet34_MAT.dynamicrgb_rpg7.DynamicRGB_RPG7_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet34_MAT.dynamicrgb_rpg7.DynamicRGB_RPG7_3P_Pickup_MIC")) 

//Jaeger Dynamic RGB VLAD-1000 Nailgun
    Skins.Add((Id=8353, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_NailGun', MIC_1P=("WEP_SkinSet34_MAT.dynamicrgb_nailgun.DynamicRGB_Nailgun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet34_MAT.dynamicrgb_nailgun.DynamicRGB_Nailgun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet34_MAT.dynamicrgb_nailgun.DynamicRGB_Nailgun_3P_Pickup_MIC")) 

//Jaeger Dynamic RGB M99
    Skins.Add((Id=8354, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_M99', MIC_1P=("WEP_SkinSet34_MAT.dynamicrgb_m99.DynamicRGB_M99_1P_Mint_MIC", "WEP_SkinSet34_MAT.dynamicrgb_m99.DynamicRGB_M99_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet34_MAT.dynamicrgb_m99.DynamicRGB_M99_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet34_MAT.dynamicrgb_m99.DynamicRGB_M99_3P_Pickup_MIC")) 

//Jaeger Dynamic RGB Boomstick
    Skins.Add((Id=8355, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_DoubleBarrel', MIC_1P=("WEP_SkinSet34_MAT.dynamicrgb_doublebarrel.DynamicRGB_DoubleBarrel_1P_Mint_MIC"), MIC_3P="WEP_SkinSet34_MAT.dynamicrgb_doublebarrel.DynamicRGB_DoubleBarrel_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet34_MAT.dynamicrgb_doublebarrel.DynamicRGB_DoubleBarrel_3P_Pickup_MIC")) 

//Jaeger Dynamic RGB Flamethrower
    Skins.Add((Id=8356, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_FlameThrower', MIC_1P=("WEP_SkinSet34_MAT.dynamicrgb_flamethrower.DynamicRGB_Flamethrower_1P_Mint_MIC"), MIC_3P="WEP_SkinSet34_MAT.dynamicrgb_flamethrower.DynamicRGB_Flamethrower_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet34_MAT.dynamicrgb_flamethrower.DynamicRGB_Flamethrower_3P_Pickup_MIC")) 

//Jaeger Dynamic RGB Eviscerator
    Skins.Add((Id=8357, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Eviscerator', MIC_1P=("WEP_SkinSet34_MAT.dynamicrgb_sawblade.DynamicRGB_SawBlade_1P_Mint_MIC"), MIC_3P="WEP_SkinSet34_MAT.dynamicrgb_sawblade.DynamicRGB_SawBlade_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet34_MAT.dynamicrgb_sawblade.DynamicRGB_SawBlade_3P_Pickup_MIC")) 

//Minigun Standard
    Skins.Add((Id=8478, Weapondef=class'KFWeapDef_Minigun', MIC_1P=("wep_1p_minigun_mat.Wep_1stP_Minigun_MIC"), MIC_3P="WEP_3P_Minigun_MAT.Wep_3rdP_Minigun_MIC", MIC_Pickup="WEP_3P_Minigun_MAT.Wep_3rdP_Minigun_Pickup_MIC")) 

//Minigun Biohazard
    Skins.Add((Id=8479, Weapondef=class'KFWeapDef_Minigun', MIC_1P=("wep_skinset35_mat.Wep_1stP_Minigun_Biohazard_MIC"), MIC_3P="wep_skinset35_mat.Wep_3rdP_Minigun_Biohazard_MIC", MIC_Pickup="wep_skinset35_mat.Wep_3rdP_Minigun_Biohazard_Pickup_MIC")) 

//Minigun Bling Boy
    Skins.Add((Id=8480, Weapondef=class'KFWeapDef_Minigun', MIC_1P=("wep_skinset35_mat.Wep_1stP_Minigun_BlingBoy_MIC"), MIC_3P="wep_skinset35_mat.Wep_3rdP_Minigun_BlingBoy_MIC", MIC_Pickup="wep_skinset35_mat.Wep_3rdP_Minigun_BlingBoy_Pickup_MIC")) 

//Minigun Deep Blue
    Skins.Add((Id=8481, Weapondef=class'KFWeapDef_Minigun', MIC_1P=("wep_skinset35_mat.Wep_1stP_Minigun_DeepBlue_MIC"), MIC_3P="wep_skinset35_mat.Wep_3rdP_Minigun_DeepBlue_MIC", MIC_Pickup="wep_skinset35_mat.Wep_3rdP_Minigun_DeepBlue_Pickup_MIC")) 

//Minigun Gore
    Skins.Add((Id=8482, Weapondef=class'KFWeapDef_Minigun', MIC_1P=("wep_skinset35_mat.Wep_1stP_Minigun_Gore_MIC"), MIC_3P="wep_skinset35_mat.Wep_3rdP_Minigun_Gore_MIC", MIC_Pickup="wep_skinset35_mat.Wep_3rdP_Minigun_Gore_Pickup_MIC")) 

//Minigun Veteran
    Skins.Add((Id=8483, Weapondef=class'KFWeapDef_Minigun', MIC_1P=("wep_skinset35_mat.Wep_1stP_Minigun_Veteran_MIC"), MIC_3P="wep_skinset35_mat.Wep_3rdP_Minigun_Veteran_MIC", MIC_Pickup="wep_skinset35_mat.Wep_3rdP_Minigun_Veteran_Pickup_MIC")) 
	
//Mine Reconstructor Standard
    Skins.Add((Id=8472, Weapondef=class'KFWeapDef_Mine_Reconstructor', MIC_1P=("wep_1p_mine_reconstructor_mat.Wep_1stP_HMTech_Mine_Reconstructor_MIC"), MIC_3P="WEP_3P_Mine_Reconstructor_MAT.Wep_3rdP_HMTech_Mine_Reconstructor_MIC", MIC_Pickup="WEP_3P_Mine_Reconstructor_MAT.Wep_3rdP_Mine_Reconstructor_Pickup_MIC")) 

//Mine Reconstructor Gore
    Skins.Add((Id=8473, Weapondef=class'KFWeapDef_Mine_Reconstructor', MIC_1P=("wep_skinset36_mat.Wep_1stP_MineReconstructor_Gore_MIC"), MIC_3P="wep_skinset36_mat.Wep_3rdP_MineReconstructor_Gore_MIC", MIC_Pickup="wep_skinset36_mat.Wep_3rdP_MineReconstructor_Gore_Pickup_MIC")) 

//Mine Reconstructor Lap Prototype
    Skins.Add((Id=8474, Weapondef=class'KFWeapDef_Mine_Reconstructor', MIC_1P=("wep_skinset36_mat.Wep_1stP_MineReconstructor_LabPrototype_MIC"), MIC_3P="wep_skinset36_mat.Wep_3rdP_MineReconstructor_LabPrototype_MIC", MIC_Pickup="wep_skinset36_mat.Wep_3rdP_MineReconstructor_LabPrototype_Pickup_MIC")) 

//Mine Reconstructor Camo
    Skins.Add((Id=8475, Weapondef=class'KFWeapDef_Mine_Reconstructor', MIC_1P=("wep_skinset36_mat.Wep_1stP_MineReconstructor_Camo_MIC"), MIC_3P="wep_skinset36_mat.Wep_3rdP_MineReconstructor_Camo_MIC", MIC_Pickup="wep_skinset36_mat.Wep_3rdP_MineReconstructor_Camo_Pickup_MIC")) 

//Mine Reconstructor Rusty
    Skins.Add((Id=8476, Weapondef=class'KFWeapDef_Mine_Reconstructor', MIC_1P=("wep_skinset36_mat.Wep_1stP_MineReconstructor_Rusty_MIC"), MIC_3P="wep_skinset36_mat.Wep_3rdP_MineReconstructor_Rusty_MIC", MIC_Pickup="wep_skinset36_mat.Wep_3rdP_MineReconstructor_Rusty_Pickup_MIC")) 

//Mine Reconstructor Wastelander
    Skins.Add((Id=8477, Weapondef=class'KFWeapDef_Mine_Reconstructor', MIC_1P=("wep_skinset36_mat.Wep_1stP_MineReconstructor_Wastelander_MIC"), MIC_3P="wep_skinset36_mat.Wep_3rdP_MineReconstructor_Wastelander_MIC", MIC_Pickup="wep_skinset36_mat.Wep_3rdP_MineReconstructor_Wastelander_Pickup_MIC")) 

//IceBreaker Sub Zero AK12
    Skins.Add((Id=8510, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet38_MAT.winter_ak12.Winter_AK12_1P_Mint_MIC", "WEP_SkinSet38_MAT.winter_ak12.Winter_AK12_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet38_MAT.winter_ak12.Winter_AK12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet38_MAT.winter_ak12.Winter_AK12_3P_Pickup_MIC")) 

//IceBreaker Sub Zero Boomstick
    Skins.Add((Id=8511, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_DoubleBarrel', MIC_1P=("WEP_SkinSet38_MAT.winter_doublebarrel.Winter_DoubleBarrel_1P_Mint_MIC"), MIC_3P="WEP_SkinSet38_MAT.winter_doublebarrel.Winter_DoubleBarrel_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet38_MAT.winter_doublebarrel.Winter_DoubleBarrel_3P_Pickup_MIC")) 

//IceBreaker Sub Zero Desert Eagle
    Skins.Add((Id=8512, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet38_MAT.winter_deagle.Winter_Deagle_1P_Mint_MIC"), MIC_3P="WEP_SkinSet38_MAT.winter_deagle.Winter_Deagle_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet38_MAT.winter_deagle.Winter_Deagle_3P_Pickup_MIC")) 

//IceBreaker Sub Zero Dragonsbreath
    Skins.Add((Id=8513, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Dragonsbreath', MIC_1P=("WEP_SkinSet38_MAT.winter_dragonsbreath.Winter_Dragonsbreath_1P_Mint_MIC"), MIC_3P="WEP_SkinSet38_MAT.winter_dragonsbreath.Winter_Dragonsbreath_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet38_MAT.winter_dragonsbreath.Winter_Dragonsbreath_3P_Pickup_MIC")) 

//IceBreaker Sub Zero Hemoclobber
    Skins.Add((Id=8514, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MedicBat', MIC_1P=("WEP_SkinSet38_MAT.winter_medicbat.Winter_MedicBat_1P_Mint_MIC"), MIC_3P="WEP_SkinSet38_MAT.winter_medicbat.Winter_MedicBat_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet38_MAT.winter_medicbat.Winter_MedicBat_3P_Pickup_MIC")) 

//IceBreaker Sub Zero Kriss
    Skins.Add((Id=8515, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Kriss', MIC_1P=("WEP_SkinSet38_MAT.winter_kriss.Winter_Kriss_1P_Mint_MIC", "WEP_SkinSet38_MAT.winter_kriss.Winter_Kriss_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet38_MAT.winter_kriss.Winter_Kriss_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet38_MAT.winter_kriss.Winter_Kriss_3P_Pickup_MIC")) 

//IceBreaker Sub Zero M79
    Skins.Add((Id=8516, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_M79', MIC_1P=("wep_skinset38_mat.winter_m79.Winter_M79_1P_Mint_MIC"), MIC_3P="WEP_SkinSet38_MAT.winter_m79.Winter_M79_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet38_MAT.winter_m79.Winter_M79_3P_Pickup_MIC")) 

//IceBreaker Sub Zero M99
    Skins.Add((Id=8517, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_M99', MIC_1P=("WEP_SkinSet38_MAT.winter_m99.Winter_M99_1P_Mint_MIC", "WEP_SkinSet38_MAT.winter_m99.Winter_M99_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet38_MAT.winter_m99.Winter_m99_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet38_MAT.winter_m99.Winter_M99_3P_Pickup_MIC")) 

//IceBreaker Sub Zero Pulverizer
    Skins.Add((Id=8518, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Pulverizer', MIC_1P=("WEP_SkinSet38_MAT.winter_pulverizer.Winter_Pulverizer_1P_Mint_MIC"), MIC_3P="WEP_SkinSet38_MAT.winter_pulverizer.Winter_Pulverizer_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet38_MAT.winter_pulverizer.Winter_Pulverizer_3P_Pickup_MIC")) 

//IceBreaker Sub Zero RPG-7
    Skins.Add((Id=8519, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_RPG7', MIC_1P=("WEP_SkinSet38_MAT.winter_rpg7.Winter_RPG7_1P_Mint_MIC"), MIC_3P="WEP_SkinSet38_MAT.winter_rpg7.Winter_RPG7_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet38_MAT.winter_rpg7.Winter_RPG7_3P_Pickup_MIC")) 

//IceBreaker Precious AK12
    Skins.Add((Id=8520, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet38_MAT.wintergold_ak12.WinterGold_AK12_1P_Mint_MIC", "WEP_SkinSet38_MAT.wintergold_ak12.WinterGold_AK12_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet38_MAT.wintergold_ak12.WinterGold_AK12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet38_MAT.wintergold_ak12.WinterGold_AK12_3P_Pickup_MIC")) 

//IceBreaker Precious Boomstick
    Skins.Add((Id=8521, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_DoubleBarrel', MIC_1P=("WEP_SkinSet38_MAT.wintergold_doublebarrel.WinterGold_DoubleBarrel_1P_Mint_MIC"), MIC_3P="WEP_SkinSet38_MAT.wintergold_doublebarrel.WinterGold_DoubleBarrel_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet38_MAT.wintergold_doublebarrel.WinterGold_DoubleBarrel_3P_Pickup_MIC")) 

//IceBreaker Precious Desert Eagle
    Skins.Add((Id=8522, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet38_MAT.wintergold_deagle.WinterGold_Deagle_1P_Mint_MIC"), MIC_3P="WEP_SkinSet38_MAT.wintergold_deagle.WinterGold_Deagle_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet38_MAT.wintergold_deagle.WinterGold_Deagle_3P_Pickup_MIC")) 

//IceBreaker Precious Dragonsbreath
    Skins.Add((Id=8523, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Dragonsbreath', MIC_1P=("WEP_SkinSet38_MAT.wintergold_dragonsbreath.WinterGold_Dragonsbreath_1P_Mint_MIC"), MIC_3P="WEP_SkinSet38_MAT.wintergold_dragonsbreath.WinterGold_Dragonsbreath_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet38_MAT.wintergold_dragonsbreath.WinterGold_Dragonsbreath_3P_Pickup_MIC")) 

//IceBreaker Precious Hemoclobber
    Skins.Add((Id=8524, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MedicBat', MIC_1P=("WEP_SkinSet38_MAT.wintergold_medicbat.WinterGold_MedicBat_1P_Mint_MIC"), MIC_3P="WEP_SkinSet38_MAT.wintergold_medicbat.WinterGold_MedicBat_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet38_MAT.wintergold_medicbat.WinterGold_MedicBat_3P_Pickup_MIC")) 

//IceBreaker Precious Kriss
    Skins.Add((Id=8525, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Kriss', MIC_1P=("WEP_SkinSet38_MAT.wintergold_kriss.WinterGold_Kriss_1P_Mint_MIC", "WEP_SkinSet38_MAT.wintergold_kriss.WinterGold_Kriss_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet38_MAT.wintergold_kriss.WinterGold_Kriss_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet38_MAT.wintergold_kriss.WinterGold_Kriss_3P_Pickup_MIC")) 

//IceBreaker Precious M79
    Skins.Add((Id=8526, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_M79', MIC_1P=("wep_skinset38_mat.wintergold_m79.WinterGold_M79_1P_Mint_MIC"), MIC_3P="WEP_SkinSet38_MAT.wintergold_m79.WinterGold_M79_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet38_MAT.wintergold_m79.WinterGold_M79_3P_Pickup_MIC")) 

//IceBreaker Precious M99
    Skins.Add((Id=8527, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_M99', MIC_1P=("WEP_SkinSet38_MAT.wintergold_m99.WinterGold_M99_1P_Mint_MIC", "WEP_SkinSet38_MAT.wintergold_m99.WinterGold_M99_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet38_MAT.wintergold_m99.WinterGold_m99_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet38_MAT.wintergold_m99.WinterGold_M99_3P_Pickup_MIC")) 

//IceBreaker Precious Pulverizer
    Skins.Add((Id=8528, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Pulverizer', MIC_1P=("WEP_SkinSet38_MAT.wintergold_pulverizer.WinterGold_Pulverizer_1P_Mint_MIC"), MIC_3P="WEP_SkinSet38_MAT.wintergold_pulverizer.WinterGold_Pulverizer_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet38_MAT.wintergold_pulverizer.WinterGold_Pulverizer_3P_Pickup_MIC")) 

//IceBreaker Precious RPG-7
    Skins.Add((Id=8529, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_RPG7', MIC_1P=("WEP_SkinSet38_MAT.wintergold_rpg7.WinterGold_RPG7_1P_Mint_MIC"), MIC_3P="WEP_SkinSet38_MAT.wintergold_rpg7.WinterGold_RPG7_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet38_MAT.wintergold_rpg7.WinterGold_RPG7_3P_Pickup_MIC")) 

//Spectre Dynamic HRG Arc Generator
    Skins.Add((Id=8530, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HRG_EMP_ArcGenerator', MIC_1P=("WEP_SkinSet37_MAT.spectre_hrgarcgenerator.Spectre_HRGArcGenerator_1P_Mint_MIC"), MIC_3P="WEP_SkinSet37_MAT.spectre_hrgarcgenerator.Spectre_HRGArcGenerator_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet37_MAT.spectre_hrgarcgenerator.Spectre_HRGArcGenerator_3P_Pickup_MIC")) 

//Spectre Dynamic HRG Scorcher
    Skins.Add((Id=8531, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HRGScorcher', MIC_1P=("WEP_SkinSet37_MAT.spectre_hrgscorcher.Spectre_HRGScorcher_1P_Mint_MIC"), MIC_3P="WEP_SkinSet37_MAT.spectre_hrgscorcher.Spectre_HRGScorcher_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet37_MAT.spectre_hrgscorcher.Spectre_HRGScorcher_3P_Pickup_MIC")) 

//Spectre Dynamic HRG Kaboomstick
    Skins.Add((Id=8532, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HRG_Kaboomstick', MIC_1P=("WEP_SkinSet37_MAT.spectre_hrgkaboomstick.Spectre_HRGKaboomstick_1P_Mint_MIC"), MIC_3P="WEP_SkinSet37_MAT.spectre_hrgkaboomstick.Spectre_HRGKaboomstick_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet37_MAT.spectre_hrgkaboomstick.Spectre_HRGKaboomstick_3P_Pickup_MIC")) 

//Spectre Dynamic HRG Teslauncher
    Skins.Add((Id=8533, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HRGTeslauncher', MIC_1P=("WEP_SkinSet37_MAT.spectre_hrgteslauncher.Spectre_HRGTesLauncher_1P_Mint_MIC"), MIC_3P="WEP_SkinSet37_MAT.spectre_hrgteslauncher.Spectre_HRGTesLauncher_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet37_MAT.spectre_hrgteslauncher.Spectre_HRGTesLauncher_3P_Pickup_MIC")) 

//Spectre Dynamic HRG Incendiary Rifle
    Skins.Add((Id=8534, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HRGIncendiaryRifle', MIC_1P=("WEP_SkinSet37_MAT.spectre_hrgincendiaryrifle.Spectre_HRGIncendiaryRifle_1P_Mint_MIC", "WEP_SkinSet37_MAT.spectre_hrgincendiaryrifle.Spectre_HRGIncendiaryRifleM203_1P_Mint_MIC"), MIC_3P="WEP_SkinSet37_MAT.spectre_hrgincendiaryrifle.Spectre_HRGIncendiaryRifle_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet37_MAT.spectre_hrgincendiaryrifle.Spectre_HRGIncendiaryRifle_3P_Pickup_MIC")) 

//Spectre Dynamic HRG Vampire
    Skins.Add((Id=8535, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HRG_Vampire', MIC_1P=("WEP_SkinSet37_MAT.spectre_hrgvampire.Spectre_HRGVampire_1P_Mint_MIC", "WEP_SkinSet37_MAT.spectre_hrgvampire.Spectre_HRGVampire_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet37_MAT.spectre_hrgvampire.Spectre_HRGVampire_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet37_MAT.spectre_hrgvampire.Spectre_HRGVampire_3P_Pickup_MIC")) 

//Spectre Dynamic Chroma HRG Arc Generator
    Skins.Add((Id=8536, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HRG_EMP_ArcGenerator', MIC_1P=("WEP_SkinSet37_MAT.spectrechroma_hrgarcgenerator.SpectreChroma_HRGArcGenerator_1P_Mint_MIC"), MIC_3P="WEP_SkinSet37_MAT.spectrechroma_hrgarcgenerator.SpectreChroma_HRGArcGenerator_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet37_MAT.spectrechroma_hrgarcgenerator.SpectreChroma_HRGArcGenerator_3P_Pickup_MIC")) 

//Spectre Dynamic Chroma HRG Scorcher
    Skins.Add((Id=8537, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HRGScorcher', MIC_1P=("WEP_SkinSet37_MAT.spectrechroma_hrgscorcher.SpectreChroma_HRGScorcher_1P_Mint_MIC"), MIC_3P="WEP_SkinSet37_MAT.spectrechroma_hrgscorcher.SpectreChroma_HRGScorcher_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet37_MAT.spectrechroma_hrgscorcher.SpectreChroma_HRGScorcher_3P_Pickup_MIC")) 

//Spectre Dynamic Chroma HRG Kaboomstick
    Skins.Add((Id=8538, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HRG_Kaboomstick', MIC_1P=("WEP_SkinSet37_MAT.spectrechroma_hrgkaboomstick.SpectreChroma_HRGKaboomstick_1P_Mint_MIC"), MIC_3P="WEP_SkinSet37_MAT.spectrechroma_hrgkaboomstick.SpectreChroma_HRGKaboomstick_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet37_MAT.spectrechroma_hrgkaboomstick.SpectreChroma_HRGKaboomstick_3P_Pickup_MIC")) 

//Spectre Dynamic Chroma HRG Teslauncher
    Skins.Add((Id=8539, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HRGTeslauncher', MIC_1P=("WEP_SkinSet37_MAT.spectrechroma_hrgteslauncher.SpectreChroma_HRGTesLauncher_1P_Mint_MIC"), MIC_3P="WEP_SkinSet37_MAT.spectrechroma_hrgteslauncher.SpectreChroma_HRGTesLauncher_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet37_MAT.spectrechroma_hrgteslauncher.SpectreChroma_HRGTesLauncher_3P_Pickup_MIC")) 

//Spectre Dynamic Chroma HRG Incendiary Rifle
    Skins.Add((Id=8540, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HRGIncendiaryRifle', MIC_1P=("WEP_SkinSet37_MAT.spectrechroma_hrgincendiaryrifle.SpectreChroma_HRGIncendiaryRifle_1P_Mint_MIC", "WEP_SkinSet37_MAT.spectrechroma_hrgincendiaryrifle.SpectreChroma_HRGIncendiaryRifleM203_1P_Mint_MIC"), MIC_3P="WEP_SkinSet37_MAT.spectrechroma_hrgincendiaryrifle.SpectreChroma_HRGIncendiaryRifle_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet37_MAT.spectrechroma_hrgincendiaryrifle.SpectreChroma_HRGIncendiaryRifle_3P_Pickup_MIC")) 

//Spectre Dynamic Chroma HRG Vampire
    Skins.Add((Id=8541, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HRG_Vampire', MIC_1P=("WEP_SkinSet37_MAT.spectrechroma_hrgvampire.SpectreChroma_HRGVampire_1P_Mint_MIC", "WEP_SkinSet37_MAT.spectrechroma_hrgvampire.SpectreChroma_HRGVampire_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet37_MAT.spectrechroma_hrgvampire.SpectreChroma_HRGVampire_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet37_MAT.spectrechroma_hrgvampire.SpectreChroma_HRGVampire_3P_Pickup_MIC")) 

//8609  Frost Fang | Standard
    Skins.Add((Id=8609, Weapondef=class'KFWeapDef_Rifle_FrostShotgunAxe', MIC_1P=("WEP_1P_Frost_Shotgun_Axe_MAT.WEP_1stP_Frost_Shotgun_MIC"), MIC_3P="WEP_3P_Frost_Shotgun_Axe_MAT.Wep_3rdP_Frost_Shotgun_MIC", MIC_Pickup="WEP_3P_Frost_Shotgun_Axe_MAT.Wep_3rdP_Frost_Shotgun_Pickup_MIC")) 
//8610  Frost Fang | Wood
    Skins.Add((Id=8610, Weapondef=class'KFWeapDef_Rifle_FrostShotgunAxe', MIC_1P=("WEP_SkinSet39_MAT.Wep_1stP_Frost_Shotgun_Wood_MIC"), MIC_3P="WEP_SkinSet39_MAT.Wep_3rdP_Frost_Shotgun_Wood_MIC", MIC_Pickup="WEP_SkinSet39_MAT.Wep_3rdP_Frost_Shotgun_Wood_Pickup_MIC")) 
//8611  Frost Fang | Cabala
    Skins.Add((Id=8611, Weapondef=class'KFWeapDef_Rifle_FrostShotgunAxe', MIC_1P=("WEP_SkinSet39_MAT.Wep_1stP_Frost_Shotgun_Cabala_MIC"), MIC_3P="WEP_SkinSet39_MAT.Wep_3stP_Frost_Shotgun_Cabala_MIC", MIC_Pickup="WEP_SkinSet39_MAT.Wep_3stP_Frost_Shotgun_Cabala_Pickup_MIC")) 
//8612  Frost Fang | Runic
    Skins.Add((Id=8612, Weapondef=class'KFWeapDef_Rifle_FrostShotgunAxe', MIC_1P=("WEP_SkinSet39_MAT.Wep_1stP_Frost_Shotgun_Runic_MIC"), MIC_3P="WEP_SkinSet39_MAT.Wep_3stP_Frost_Shotgun_Runic_MIC", MIC_Pickup="WEP_SkinSet39_MAT.Wep_3rdP_Frost_Shotgun_Runic_Pickup_MIC")) 
//8613  Frost Fang | Deco Ice
    Skins.Add((Id=8613, Weapondef=class'KFWeapDef_Rifle_FrostShotgunAxe', MIC_1P=("WEP_SkinSet39_MAT.Wep_1stP_Frost_Shotgun_DecoIce_MIC"), MIC_3P="WEP_SkinSet39_MAT.Wep_3stP_Frost_Shotgun_DecoIce_MIC", MIC_Pickup="WEP_SkinSet39_MAT.Wep_3rdP_Frost_Shotgun_DecoIce_Pickup_MIC")) 
//8614  Frost Fang | Burned Land
    Skins.Add((Id=8614, Weapondef=class'KFWeapDef_Rifle_FrostShotgunAxe', MIC_1P=("WEP_SkinSet39_MAT.Wep_1stP_Frost_Shotgun_BurnedLand_MIC"), MIC_3P="WEP_SkinSet39_MAT.Wep_3stP_Frost_Shotgun_BurnedLand_MIC", MIC_Pickup="WEP_SkinSet39_MAT.Wep_3rdP_Frost_Shotgun_BurnedLand_Pickup_MIC")) 

//Neon Caulk n Burn
    Skins.Add((Id=8654, Weapondef=class'KFWeapDef_CaulkBurn', MIC_1P=("WEP_SkinSet40_MAT.neon_caulkburn.Neon_CaulkBurn_1P_Mint_MIC"), MIC_3P="WEP_SkinSet40_MAT.neon_caulkburn.Neon_CaulkBurn_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet40_MAT.neon_caulkburn.Neon_CaulkBurn_3P_Pickup_MIC")) 

//Neon Crovel
    Skins.Add((Id=8655, Weapondef=class'KFWeapDef_Crovel', MIC_1P=("WEP_SkinSet40_MAT.neon_crovel.Neon_Crovel_1P_Mint_MIC"), MIC_3P="WEP_SkinSet40_MAT.neon_crovel.Neon_Crovel_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet40_MAT.neon_crovel.Neon_Crovel_3P_Pickup_MIC")) 

//Neon HX25
    Skins.Add((Id=8656, Weapondef=class'KFWeapDef_HX25', MIC_1P=("WEP_SkinSet40_MAT.neon_hx25.Neon_HX25_1P_Mint_MIC"), MIC_3P="WEP_SkinSet40_MAT.neon_hx25.Neon_HX25_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet40_MAT.neon_hx25.Neon_HX25_3P_Pickup_MIC")) 

//Neon MP5RAS
    Skins.Add((Id=8657, Weapondef=class'KFWeapDef_MP5RAS', MIC_1P=("WEP_SkinSet40_MAT.neon_mp5ras.Neon_MP5RAS_1P_Mint_MIC"), MIC_3P="WEP_SkinSet40_MAT.neon_mp5ras.Neon_MP5RAS_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet40_MAT.neon_mp5ras.Neon_MP5RAS_3P_Pickup_MIC")) 

//Neon 1858 Revolver
    Skins.Add((Id=8658, Weapondef=class'KFWeapDef_Remington1858', MIC_1P=("WEP_SkinSet40_MAT.neon_remington1858.Neon_Remington1858_1P_Mint_MIC"), MIC_3P="WEP_SkinSet40_MAT.neon_remington1858.Neon_Remington1858_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet40_MAT.neon_remington1858.Neon_Remington1858_3P_Pickup_MIC")) 

//Neon Eviscerator
    Skins.Add((Id=8659, Weapondef=class'KFWeapDef_Eviscerator', MIC_1P=("WEP_SkinSet40_MAT.neon_sawblade.Neon_SawBlade_1P_Mint_MIC"), MIC_3P="WEP_SkinSet40_MAT.neon_sawblade.Neon_SawBlade_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet40_MAT.neon_sawblade.Neon_SawBlade_3P_Pickup_MIC")) 

//Neon Berserker Knife
    Skins.Add((Id=8660, Weapondef=class'KFWeapDef_Knife_Berserker', MIC_1P=("WEP_SkinSet40_MAT.neon_berserkerknife.Neon_BerserkerKnife_1P_Mint_MIC"), MIC_3P="WEP_SkinSet40_MAT.neon_berserkerknife.Neon_BerserkerKnife_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet40_MAT.neon_berserkerknife.Neon_BerserkerKnife_3P_Pickup_MIC")) 

//Neon KF-BAR
    Skins.Add((Id=8661, Weapondef=class'KFWeapDef_Knife_Commando', MIC_1P=("WEP_SkinSet40_MAT.neon_commandoknife.Neon_CommandoKnife_1P_Mint_MIC"), MIC_3P="WEP_SkinSet40_MAT.neon_commandoknife.Neon_CommandoKnife_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet40_MAT.neon_commandoknife.Neon_CommandoKnife_3P_Pickup_MIC")) 

//Neon Demo Knife
    Skins.Add((Id=8662, Weapondef=class'KFWeapDef_Knife_Demo', MIC_1P=("WEP_SkinSet40_MAT.neon_demoknife.Neon_DemoKnife_1P_Mint_MIC"), MIC_3P="WEP_SkinSet40_MAT.neon_demoknife.Neon_DemoKnife_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet40_MAT.neon_demoknife.Neon_DemoKnife_3P_Pickup_MIC")) 

//Neon Firemans Knife
    Skins.Add((Id=8663, Weapondef=class'KFWeapDef_Knife_Firebug', MIC_1P=("WEP_SkinSet40_MAT.neon_firebugknife.Neon_FirebugKnife_1P_Mint_MIC"), MIC_3P="WEP_SkinSet40_MAT.neon_firebugknife.Neon_FirebugKnife_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet40_MAT.neon_firebugknife.Neon_FirebugKnife_3P_Pickup_MIC")) 

//Neon Gunslinger Knife
    Skins.Add((Id=8664, Weapondef=class'KFWeapDef_Knife_Gunslinger', MIC_1P=("WEP_SkinSet40_MAT.neon_gunslingerknife.Neon_GunslingerKnife_1P_Mint_MIC"), MIC_3P="WEP_SkinSet40_MAT.neon_gunslingerknife.Neon_GunslingerKnife_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet40_MAT.neon_gunslingerknife.Neon_GunslingerKnife_3P_Pickup_MIC")) 

//Neon HMTech-001 Scalpel
    Skins.Add((Id=8665, Weapondef=class'KFWeapDef_Knife_Medic', MIC_1P=("WEP_SkinSet40_MAT.neon_medicknife.Neon_MedicKnife_1P_Mint_MIC"), MIC_3P="WEP_SkinSet40_MAT.neon_medicknife.Neon_MedicKnife_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet40_MAT.neon_medicknife.Neon_MedicKnife_3P_Pickup_MIC")) 

//Neon Kukri
    Skins.Add((Id=8666, Weapondef=class'KFWeapDef_Knife_Sharpshooter', MIC_1P=("WEP_SkinSet40_MAT.neon_sharpshooterknife.Neon_SharpshooterKnife_1P_Mint_MIC"), MIC_3P="WEP_SkinSet40_MAT.neon_sharpshooterknife.Neon_SharpshooterKnife_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet40_MAT.neon_sharpshooterknife.Neon_SharpshooterKnife_3P_Pickup_MIC")) 

//Neon Support Knife
    Skins.Add((Id=8667, Weapondef=class'KFWeapDef_Knife_Support', MIC_1P=("WEP_SkinSet40_MAT.neon_supportknife.Neon_SupportKnife_1P_Mint_MIC"), MIC_3P="WEP_SkinSet40_MAT.neon_supportknife.Neon_SupportKnife_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet40_MAT.neon_supportknife.Neon_SupportKnife_3P_Pickup_MIC")) 

//Neon Gore Shiv
    Skins.Add((Id=8668, Weapondef=class'KFWeapDef_Knife_Survivalist', MIC_1P=("WEP_SkinSet40_MAT.neon_survivalistknife.Neon_SurvivalistKnife_1P_Mint_MIC"), MIC_3P="WEP_SkinSet40_MAT.neon_survivalistknife.Neon_SurvivalistKnife_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet40_MAT.neon_survivalistknife.Neon_SurvivalistKnife_3P_Pickup_MIC")) 

//Neon Tactical Knife
    Skins.Add((Id=8669, Weapondef=class'KFWeapDef_Knife_SWAT', MIC_1P=("WEP_SkinSet40_MAT.neon_swatknife.Neon_SWATKnife_1P_Mint_MIC"), MIC_3P="WEP_SkinSet40_MAT.neon_swatknife.Neon_SWATKnife_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet40_MAT.neon_swatknife.Neon_SWATKnife_3P_Pickup_MIC")) 

//NeonRGB Caulk n Burn
    Skins.Add((Id=8670, Weapondef=class'KFWeapDef_CaulkBurn', MIC_1P=("WEP_SkinSet40_MAT.neonrgb_caulkburn.NeonRGB_CaulkBurn_1P_Mint_MIC"), MIC_3P="WEP_SkinSet40_MAT.neonrgb_caulkburn.NeonRGB_CaulkBurn_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet40_MAT.neonrgb_caulkburn.NeonRGB_CaulkBurn_3P_Pickup_MIC")) 

//NeonRGB Crovel
    Skins.Add((Id=8671, Weapondef=class'KFWeapDef_Crovel', MIC_1P=("WEP_SkinSet40_MAT.neonrgb_crovel.NeonRGB_Crovel_1P_Mint_MIC"), MIC_3P="WEP_SkinSet40_MAT.neonrgb_crovel.NeonRGB_Crovel_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet40_MAT.neonrgb_crovel.NeonRGB_Crovel_3P_Pickup_MIC")) 

//NeonRGB HX25
    Skins.Add((Id=8672, Weapondef=class'KFWeapDef_HX25', MIC_1P=("WEP_SkinSet40_MAT.neonrgb_hx25.NeonRGB_HX25_1P_Mint_MIC"), MIC_3P="WEP_SkinSet40_MAT.neonrgb_hx25.NeonRGB_HX25_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet40_MAT.neonrgb_hx25.NeonRGB_HX25_3P_Pickup_MIC")) 

//NeonRGB MP5RAS
    Skins.Add((Id=8673, Weapondef=class'KFWeapDef_MP5RAS', MIC_1P=("WEP_SkinSet40_MAT.neonrgb_mp5ras.NeonRGB_MP5RAS_1P_Mint_MIC"), MIC_3P="WEP_SkinSet40_MAT.neonrgb_mp5ras.NeonRGB_MP5RAS_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet40_MAT.neonrgb_mp5ras.NeonRGB_MP5RAS_3P_Pickup_MIC")) 

//NeonRGB 1858 Revolver
    Skins.Add((Id=8674, Weapondef=class'KFWeapDef_Remington1858', MIC_1P=("WEP_SkinSet40_MAT.neonrgb_remington1858.NeonRGB_Remington1858_1P_Mint_MIC"), MIC_3P="WEP_SkinSet40_MAT.neonrgb_remington1858.NeonRGB_Remington1858_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet40_MAT.neonrgb_remington1858.NeonRGB_Remington1858_3P_Pickup_MIC")) 

//NeonRGB Eviscerator
    Skins.Add((Id=8675, Weapondef=class'KFWeapDef_Eviscerator', MIC_1P=("WEP_SkinSet40_MAT.neonrgb_sawblade.NeonRGB_SawBlade_1P_Mint_MIC"), MIC_3P="WEP_SkinSet40_MAT.neonrgb_sawblade.NeonRGB_SawBlade_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet40_MAT.neonrgb_sawblade.NeonRGB_SawBlade_3P_Pickup_MIC")) 

//NeonRGB Berserker Knife
    Skins.Add((Id=8676, Weapondef=class'KFWeapDef_Knife_Berserker', MIC_1P=("WEP_SkinSet40_MAT.neonrgb_berserkerknife.NeonRGB_BerserkerKnife_1P_Mint_MIC"), MIC_3P="WEP_SkinSet40_MAT.neonrgb_berserkerknife.NeonRGB_BerserkerKnife_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet40_MAT.neonrgb_berserkerknife.NeonRGB_BerserkerKnife_3P_Pickup_MIC")) 

//NeonRGB KF-BAR
    Skins.Add((Id=8677, Weapondef=class'KFWeapDef_Knife_Commando', MIC_1P=("WEP_SkinSet40_MAT.neonrgb_commandoknife.NeonRGB_CommandoKnife_1P_Mint_MIC"), MIC_3P="WEP_SkinSet40_MAT.neonrgb_commandoknife.NeonRGB_CommandoKnife_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet40_MAT.neonrgb_commandoknife.NeonRGB_CommandoKnife_3P_Pickup_MIC")) 

//NeonRGB Demo Knife
    Skins.Add((Id=8678, Weapondef=class'KFWeapDef_Knife_Demo', MIC_1P=("WEP_SkinSet40_MAT.neonrgb_demoknife.NeonRGB_DemoKnife_1P_Mint_MIC"), MIC_3P="WEP_SkinSet40_MAT.neonrgb_demoknife.NeonRGB_DemoKnife_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet40_MAT.neonrgb_demoknife.NeonRGB_DemoKnife_3P_Pickup_MIC")) 

//NeonRGB Firemans Knife
    Skins.Add((Id=8679, Weapondef=class'KFWeapDef_Knife_Firebug', MIC_1P=("WEP_SkinSet40_MAT.neonrgb_firebugknife.NeonRGB_FirebugKnife_1P_Mint_MIC"), MIC_3P="WEP_SkinSet40_MAT.neonrgb_firebugknife.NeonRGB_FirebugKnife_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet40_MAT.neonrgb_firebugknife.NeonRGB_FirebugKnife_3P_Pickup_MIC")) 

//NeonRGB Gunslinger Knife
    Skins.Add((Id=8680, Weapondef=class'KFWeapDef_Knife_Gunslinger', MIC_1P=("WEP_SkinSet40_MAT.neonrgb_gunslingerknife.NeonRGB_GunslingerKnife_1P_Mint_MIC"), MIC_3P="WEP_SkinSet40_MAT.neonrgb_gunslingerknife.NeonRGB_GunslingerKnife_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet40_MAT.neonrgb_gunslingerknife.NeonRGB_GunslingerKnife_3P_Pickup_MIC")) 

//NeonRGB HMTech-001 Scalpel
    Skins.Add((Id=8681, Weapondef=class'KFWeapDef_Knife_Medic', MIC_1P=("WEP_SkinSet40_MAT.neonrgb_medicknife.NeonRGB_MedicKnife_1P_Mint_MIC"), MIC_3P="WEP_SkinSet40_MAT.neonrgb_medicknife.NeonRGB_MedicKnife_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet40_MAT.neonrgb_medicknife.NeonRGB_MedicKnife_3P_Pickup_MIC")) 

//NeonRGB Kukri
    Skins.Add((Id=8682, Weapondef=class'KFWeapDef_Knife_Sharpshooter', MIC_1P=("WEP_SkinSet40_MAT.neonrgb_sharpshooterknife.NeonRGB_SharpshooterKnife_1P_Mint_MIC"), MIC_3P="WEP_SkinSet40_MAT.neonrgb_sharpshooterknife.NeonRGB_SharpshooterKnife_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet40_MAT.neonrgb_sharpshooterknife.NeonRGB_SharpshooterKnife_3P_Pickup_MIC")) 

//NeonRGB Support Knife
    Skins.Add((Id=8683, Weapondef=class'KFWeapDef_Knife_Support', MIC_1P=("WEP_SkinSet40_MAT.neonrgb_supportknife.NeonRGB_SupportKnife_1P_Mint_MIC"), MIC_3P="WEP_SkinSet40_MAT.neonrgb_supportknife.NeonRGB_SupportKnife_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet40_MAT.neonrgb_supportknife.NeonRGB_SupportKnife_3P_Pickup_MIC")) 

//NeonRGB Gore Shiv
    Skins.Add((Id=8684, Weapondef=class'KFWeapDef_Knife_Survivalist', MIC_1P=("WEP_SkinSet40_MAT.neonrgb_survivalistknife.NeonRGB_SurvivalistKnife_1P_Mint_MIC"), MIC_3P="WEP_SkinSet40_MAT.neonrgb_survivalistknife.NeonRGB_SurvivalistKnife_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet40_MAT.neonrgb_survivalistknife.NeonRGB_SurvivalistKnife_3P_Pickup_MIC")) 

//NeonRGB Tactical Knife
    Skins.Add((Id=8685, Weapondef=class'KFWeapDef_Knife_SWAT', MIC_1P=("WEP_SkinSet40_MAT.neonrgb_swatknife.NeonRGB_SWATKnife_1P_Mint_MIC"), MIC_3P="WEP_SkinSet40_MAT.neonrgb_swatknife.NeonRGB_SWATKnife_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet40_MAT.neonrgb_swatknife.NeonRGB_SWATKnife_3P_Pickup_MIC")) 

//GravityImploder Standard
    Skins.Add((Id=8778, Weapondef=class'KFWeapDef_GravityImploder', MIC_1P=("WEP_1P_Gravity_Imploder_MAT.Wep_1stP_Gravity_Imploder_MIC"), MIC_3P="WEP_3P_Gravity_Imploder_MAT.Wep_3rdP_Gravity_Imploder_MIC", MIC_Pickup="WEP_3p_Gravity_Imploder_MAT.Wep_3rdP_Gravity_Imploder_Pickup_MIC")) 

//GravityImploder Area51
	Skins.Add((Id=8779, Weapondef=class'KFWeapDef_GravityImploder', MIC_1P=("WEP_SkinSet41_MAT.WEP_SkinSet_1stP_Gravity_Imploder_Area51_MIC"), MIC_3P="WEP_SkinSet41_MAT.Wep_SkinSet_3rdP_Gravity_Imploder_Area51_MIC", MIC_Pickup="WEP_SkinSet41_MAT.Wep_3rdP_Gravity_Imploder_Pickup_Area51_MIC"));

//GravityImploder Banzai
	Skins.Add((Id=8780, Weapondef=class'KFWeapDef_GravityImploder', MIC_1P=("WEP_SkinSet41_MAT.WEP_SkinSet_1stP_Gravity_Imploder_Banzai_MIC"), MIC_3P="WEP_SkinSet41_MAT.Wep_SkinSet_3rdP_Gravity_Imploder_Banzai_MIC", MIC_Pickup="WEP_SkinSet41_MAT.Wep_3rdP_Gravity_Imploder_Pickup_Banzai_MIC"));

//GravityImploder Jungle
	Skins.Add((Id=8781, Weapondef=class'KFWeapDef_GravityImploder', MIC_1P=("WEP_SkinSet41_MAT.WEP_SkinSet_1stP_Gravity_Imploder_Cambodia_MIC"), MIC_3P="WEP_SkinSet41_MAT.Wep_SkinSet_3rdP_Gravity_Imploder_Cambodia_MIC", MIC_Pickup="WEP_SkinSet41_MAT.Wep_3rdP_Gravity_Imploder_Pickup_Cambodia_MIC"));

//GravityImploder High Tech
	Skins.Add((Id=8782, Weapondef=class'KFWeapDef_GravityImploder', MIC_1P=("WEP_SkinSet41_MAT.WEP_SkinSet_1stP_Gravity_Imploder_HighTech_MIC"), MIC_3P="WEP_SkinSet41_MAT.Wep_SkinSet_3rdP_Gravity_Imploder_HighTech_MIC", MIC_Pickup="WEP_SkinSet41_MAT.Wep_3rdP_Gravity_Imploder_Pickup_HighTech_MIC"));

//GravityImploder Rust
 	Skins.Add((Id=8783, Weapondef=class'KFWeapDef_GravityImploder', MIC_1P=("WEP_SkinSet41_MAT.WEP_SkinSet_1stP_Gravity_Imploder_Rust_MIC"), MIC_3P="WEP_SkinSet41_MAT.Wep_SkinSet_3rdP_Gravity_Imploder_Rust_MIC", MIC_Pickup="WEP_SkinSet41_MAT.Wep_3rdP_Gravity_Imploder_Pickup_Rust_MIC"));

//Coliseum Zweihander
 	Skins.Add((Id=8791, Weapondef=class'KFWeapDef_Zweihander', MIC_1P=("WEP_SkinSet42_MAT.coliseum_zweihander.Coliseum_Zweihander_1P_Mint_MIC"), MIC_3P="WEP_SkinSet42_MAT.coliseum_zweihander.Coliseum_Zweihander_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet42_MAT.coliseum_zweihander.Coliseum_Zweihander_3P_Pickup_MIC"));

//Famas Standard
    Skins.Add((Id=8934, Weapondef=class'KFWeapDef_FAMAS', MIC_1P=("WEP_1P_Famas_MAT.Wep_1stP_Famas_MIC"), MIC_3P="WEP_3P_Famas_MAT.Wep_3rdP_Famas_MIC", MIC_Pickup="WEP_3P_Famas_MAT.Wep_3rdP_Famas_Pickup_MIC"));

//Famas Flourished
	Skins.Add((Id=8935, Weapondef=class'KFWeapDef_FAMAS', MIC_1P=("WEP_SkinSet45_MAT.Wep_1stP_Famas_Flourished_MIC"), MIC_3P="WEP_SkinSet45_MAT.Wep_3rdP_Famas_Flourished_MIC", MIC_Pickup="WEP_SkinSet45_MAT.Wep_3rdP_Famas_Pickup_Flourished_MIC"));

//Famas Jagged Wars
	Skins.Add((Id=8936, Weapondef=class'KFWeapDef_FAMAS', MIC_1P=("WEP_SkinSet45_MAT.Wep_1stP_Famas_JaggedWars_MIC"), MIC_3P="WEP_SkinSet45_MAT.Wep_3rdP_Famas_JaggedWars_MIC", MIC_Pickup="WEP_SkinSet45_MAT.Wep_3rdP_Famas_Pickup_JaggedWars_MIC"));

//Famas Japped
	Skins.Add((Id=8937, Weapondef=class'KFWeapDef_FAMAS', MIC_1P=("WEP_SkinSet45_MAT.Wep_1stP_Famas_Japped_MIC"), MIC_3P="WEP_SkinSet45_MAT.Wep_3rdP_Famas_Japped_MIC", MIC_Pickup="WEP_SkinSet45_MAT.Wep_3rdP_Famas_Pickup_Japped_MIC"));

//Famas Skull Candy
	Skins.Add((Id=8938, Weapondef=class'KFWeapDef_FAMAS', MIC_1P=("WEP_SkinSet45_MAT.Wep_1stP_Famas_SkullCandy_MIC"), MIC_3P="WEP_SkinSet45_MAT.Wep_3rdP_Famas_SkullCandy_MIC", MIC_Pickup="WEP_SkinSet45_MAT.Wep_3rdP_Famas_Pickup_SkullCandy_MIC"));

//Famas Turfed
 	Skins.Add((Id=8939, Weapondef=class'KFWeapDef_FAMAS', MIC_1P=("WEP_SkinSet45_MAT.Wep_1stP_Famas_Turfed_MIC"), MIC_3P="WEP_SkinSet45_MAT.Wep_3rdP_Famas_Turfed_MIC", MIC_Pickup="WEP_SkinSet45_MAT.Wep_3rdP_Famas_Pickup_Turfed_MIC"));

//Thermite Standard
    Skins.Add((Id=8940, Weapondef=class'KFWeapDef_ThermiteBore', MIC_1P=("WEP_1P_Thermite_MAT.Wep_1P_Thermite_MIC"), MIC_3P="WEP_3P_Thermite_MAT.WEP_3P_Thermite_MIC", MIC_Pickup="WEP_3p_Gravity_Imploder_MAT.Wep_3rdP_Gravity_Imploder_Pickup_MIC")) 

//Thermite Japped
	Skins.Add((Id=8941, Weapondef=class'KFWeapDef_ThermiteBore', MIC_1P=("WEP_SkinSet46_MAT.Wep_1stP_Thermite_Japped_MIC"), MIC_3P="WEP_SkinSet46_MAT.Wep_3rdP_Thermite_Japped_MIC", MIC_Pickup="WEP_SkinSet46_MAT.Wep_3rdP_Thermite_Pickup_Japped_MIC"));

//Thermite Much Danger
	Skins.Add((Id=8942, Weapondef=class'KFWeapDef_ThermiteBore', MIC_1P=("WEP_SkinSet46_MAT.Wep_1stP_Thermite_MuchDanger_MIC"), MIC_3P="WEP_SkinSet46_MAT.Wep_3rdP_Thermite_MuchDanger_MIC", MIC_Pickup="WEP_SkinSet46_MAT.Wep_3rdP_Thermite_Pickup_MuchDanger_MIC"));

//Thermite Not Liandri
	Skins.Add((Id=8943, Weapondef=class'KFWeapDef_ThermiteBore', MIC_1P=("WEP_SkinSet46_MAT.Wep_1stP_Thermite_NotLiandri_MIC"), MIC_3P="WEP_SkinSet46_MAT.Wep_3rdP_Thermite_NotLiandri_MIC", MIC_Pickup="WEP_SkinSet46_MAT.Wep_3rdP_Thermite_Pickup_NotLiandri_MIC"));

//Thermite Rusted
	Skins.Add((Id=8944, Weapondef=class'KFWeapDef_ThermiteBore', MIC_1P=("WEP_SkinSet46_MAT.Wep_1stP_Thermite_Rusted_MIC"), MIC_3P="WEP_SkinSet46_MAT.Wep_3rdP_Thermite_Rusted_MIC", MIC_Pickup="WEP_SkinSet46_MAT.Wep_3rdP_Thermite_Pickup_Rusted_MIC"));

//Thermite Thunder Jaws
 	Skins.Add((Id=8945, Weapondef=class'KFWeapDef_ThermiteBore', MIC_1P=("WEP_SkinSet46_MAT.Wep_1stP_Thermite_ThunderJaws_MIC"), MIC_3P="WEP_SkinSet46_MAT.Wep_3rdP_Thermite_ThunderJaws_MIC", MIC_Pickup="WEP_SkinSet46_MAT.Wep_3rdP_Thermite_Pickup_ThunderJaws_MIC"));

//Corrupter Carbine Standard
 	Skins.Add((Id=9132, Weapondef=class'KFWeapDef_ParasiteImplanter', MIC_1P=("WEP_1P_ParasiteImplanter_MAT.Wep_1stP_ParasiteImplanter_PM", "WEP_1P_ParasiteImplanter_MAT.Wep_1stP_ParasiteImplanter_scope_PM"), MIC_3P="WEP_3P_ParasiteImplanter_MAT.Wep_3P_ParasiteImplanter_PM", MIC_Pickup="WEP_3P_ParasiteImplanter_MAT.WEP_3rdP_ParasiteImplanter_MIC"));

//Corrupter Carbine Radioactive
 	Skins.Add((Id=9133, Weapondef=class'KFWeapDef_ParasiteImplanter', MIC_1P=("wep_skinset49_mat.Wep_ParasiteBody_Radioactive_PM", "wep_skinset49_mat.Wep_ParasiteScope_Radioactive_PM"), MIC_3P="wep_skinset49_mat.Wep_3rd_Parasite_Radioactive_PM", MIC_Pickup="wep_skinset49_mat.Wep_3rd_Parasite_Pickup_Radioactive_PM"));

//Corrupter Carbine Icy
 	Skins.Add((Id=9134, Weapondef=class'KFWeapDef_ParasiteImplanter', MIC_1P=("wep_skinset49_mat.Wep_ParasiteBody_Icy_PM", "wep_skinset49_mat.Wep_ParasiteScope_Icy_PM"), MIC_3P="wep_skinset49_mat.Wep_3rd_Parasite_Icy_PM", MIC_Pickup="wep_skinset49_mat.Wep_3rd_Parasite_Pickup_Icy_PM"));

//Corrupter Carbine Danger
 	Skins.Add((Id=9135, Weapondef=class'KFWeapDef_ParasiteImplanter', MIC_1P=("wep_skinset49_mat.Wep_ParasiteBody_Deathranger_PM", "wep_skinset49_mat.Wep_ParasiteScope_Deathranger_PM"), MIC_3P="wep_skinset49_mat.Wep_3rd_Parasite_Deathranger_PM", MIC_Pickup="wep_skinset49_mat.Wep_3rd_Parasite_Pickup_Deathranger_PM"));

//Corrupter Carbine Lush
 	Skins.Add((Id=9136, Weapondef=class'KFWeapDef_ParasiteImplanter', MIC_1P=("wep_skinset49_mat.Wep_ParasiteBody_Lush_PM", "wep_skinset49_mat.Wep_ParasiteScope_Lush_PM"), MIC_3P="wep_skinset49_mat.Wep_3rd_Parasite_Lush_PM", MIC_Pickup="wep_skinset49_mat.Wep_3rd_Parasite_Pickup_Lush_PM"));

//Corrupter Carbine Lightning
 	Skins.Add((Id=9137, Weapondef=class'KFWeapDef_ParasiteImplanter', MIC_1P=("wep_skinset49_mat.Wep_ParasiteBody_Bluelightning_PM", "wep_skinset49_mat.Wep_ParasiteScope_Bluelightning_PM"), MIC_3P="wep_skinset49_mat.Wep_3rd_Parasite_Bluelightning_PM", MIC_Pickup="wep_skinset49_mat.Wep_3rd_Parasite_Pickup_Bluelightning_PM"));

//Piranha Standard
 	Skins.Add((Id=9126, Weapondef=class'KFWeapDef_BladedPistol', MIC_1P=("wep_1p_bladedpistol_mat.Wep_1stP_BladedPistol_MIC"), MIC_3P="wep_3p_bladedpistol_mat.WEP_3P_BladedPistol_MIC", MIC_Pickup="wep_3p_bladedpistol_mat.3P_Pickup_BladedPistol_MIC"));

//Piranha Reptilian
 	Skins.Add((Id=9127, Weapondef=class'KFWeapDef_BladedPistol', MIC_1P=("wep_skinset50_mat.Wep_Bladed_Reptilian_PM"), MIC_3P="wep_skinset50_mat.3rd_Wep_Bladed_Reptilian_PM", MIC_Pickup="wep_skinset50_mat.3rd_Wep_Bladed_Pickup_Reptilian_PM"));

//Piranha Phoenix
 	Skins.Add((Id=9128, Weapondef=class'KFWeapDef_BladedPistol', MIC_1P=("wep_skinset50_mat.Wep_Bladed_Phoenix_PM"), MIC_3P="wep_skinset50_mat.3rd_Wep_Bladed_Phoenix_PM", MIC_Pickup="wep_skinset50_mat.3rd_Wep_Bladed_Pickup_Phoenix_PM"));

//Piranha Copper
 	Skins.Add((Id=9129, Weapondef=class'KFWeapDef_BladedPistol', MIC_1P=("wep_skinset50_mat.Wep_Bladed_Angrycopper_PM"), MIC_3P="wep_skinset50_mat.3rd_Wep_Bladed_Angrycopper_PM", MIC_Pickup="wep_skinset50_mat.3rd_Wep_Bladed_Pickup_Angrycopper_PM"));

//Piranha Blade
 	Skins.Add((Id=9130, Weapondef=class'KFWeapDef_BladedPistol', MIC_1P=("wep_skinset50_mat.Wep_Bladed_Killerblade_PM"), MIC_3P="wep_skinset50_mat.3rd_Wep_Bladed_Killerblade_PM", MIC_Pickup="wep_skinset50_mat.3rd_Wep_Bladed_Pickup_Killerblade_PM"));

//Piranha Rusty
 	Skins.Add((Id=9131, Weapondef=class'KFWeapDef_BladedPistol', MIC_1P=("wep_skinset50_mat.Wep_Bladed_Rustynightmare_PM"), MIC_3P="wep_skinset50_mat.3rd_Wep_Bladed_Rustynightmare_PM", MIC_Pickup="wep_skinset50_mat.3rd_Wep_Bladed_Pickup_Rustynightmare_PM"));

//Doshinegun Standard
 	Skins.Add((Id=9275, Weapondef=class'KFWeapDef_Doshinegun', MIC_1P=("WEP_1P_Doshinegun_MAT.Wep_1stP_Doshinegun_MIC", "WEP_1P_Doshinegun_MAT.Wep_1stP_Doshinegun_Mag_MIC"), MIC_3P="wep_3p_doshinegun_mat.WEP_3P_Doshinegun_MIC", MIC_Pickup="wep_3p_doshinegun_mat.WEP_Pickup_Doshinegun_MIC"));

//Doshinegun Baroque
 	Skins.Add((Id=9279, Weapondef=class'KFWeapDef_Doshinegun', MIC_1P=("wep_skinset53_mat.Wep_Doshinegun_baroque_body_PM", "wep_skinset53_mat.Wep_Doshinegun_baroque_mag_PM"), MIC_3P="WEP_SkinSet53_MAT.Wep_Doshinegun_baroque_3P_PM", MIC_Pickup="WEP_SkinSet53_MAT.Wep_Doshinegun_Baroque_3P_Pickup_MIC"));

//Doshinegun Diamond
 	Skins.Add((Id=9277, Weapondef=class'KFWeapDef_Doshinegun', MIC_1P=("wep_skinset53_mat.Wep_Doshinegun_diamond_body_PM", "wep_skinset53_mat.Wep_Doshinegun_diamond_mag_PM"), MIC_3P="WEP_SkinSet53_MAT.Wep_Doshinegun_diamond_3P_PM", MIC_Pickup="WEP_SkinSet53_MAT.Wep_Doshinegun_Diamond_3P_Pickup_MIC"));

//Doshinegun Dosh
 	Skins.Add((Id=9278, Weapondef=class'KFWeapDef_Doshinegun', MIC_1P=("wep_skinset53_mat.Wep_Doshinegun_dosh_body_PM", "wep_skinset53_mat.Wep_Doshinegun_dosh_mag_PM"), MIC_3P="WEP_SkinSet53_MAT.Wep_Doshinegun_dosh_3P_PM", MIC_Pickup="WEP_SkinSet53_MAT.Wep_Doshinegun_Dosh_3P_Pickup_MIC"));

//Doshinegun Golden Tiger
 	Skins.Add((Id=9280, Weapondef=class'KFWeapDef_Doshinegun', MIC_1P=("wep_skinset53_mat.Wep_Doshinegun_tiger_body_PM", "wep_skinset53_mat.Wep_Doshinegun_tiger_mag_PM"), MIC_3P="WEP_SkinSet53_MAT.Wep_Doshinegun_tiger_3P_PM", MIC_Pickup="WEP_SkinSet53_MAT.Wep_Doshinegun_Tiger_3P_Pickup_MIC"));

//Doshinegun Koi Dream
 	Skins.Add((Id=9276, Weapondef=class'KFWeapDef_Doshinegun', MIC_1P=("wep_skinset53_mat.Wep_Doshinegun_koidream_body_PM", "wep_skinset53_mat.Wep_Doshinegun_koidream_mag_PM"), MIC_3P="WEP_SkinSet53_MAT.Wep_Doshinegun_koidream_3P_PM", MIC_Pickup="WEP_SkinSet53_MAT.Wep_Doshinegun_koidream_3P_Pickup_MIC"));

//Sentinel Standard
    Skins.Add((Id=9284, Weapondef=class'KFWeapDef_AutoTurret', MIC_1P=("wep_1p_autoturret_mat.Wep_1P_AutoTurret_MIC","Wep_1P_AutoTurret_MAT.Wep_1P_Remote_MIC"), MIC_3P="WEP_3P_AutoTurret_MAT.WEP_3P_AutoTurret_MIC", MIC_Pickup="wep_3p_autoturret_mat.3P_Pickup_AutoTurret_MIC")) 

//Sentinel 1942
	Skins.Add((Id=9285, Weapondef=class'KFWeapDef_AutoTurret', MIC_1P=("WEP_SkinSet54_MAT.Wep_1P_1942_AutoTurret_MIC","WEP_SkinSet54_MAT.Wep_1P_1942_Remote_MIC"), MIC_3P="wep_skinset54_mat.Wep_3P_1942_AutoTurret_MIC", MIC_Pickup="wep_skinset54_mat.Wep_3P_1942_AutoTurrent_Pickup_MIC")) 

//Sentinel Black Bird
	Skins.Add((Id=9286, Weapondef=class'KFWeapDef_AutoTurret', MIC_1P=("WEP_SkinSet54_MAT.Wep_1P_BlackBird_AutoTurret_MIC","WEP_SkinSet54_MAT.Wep_1P_BlackBird_Remote_MIC"), MIC_3P="wep_skinset54_mat.Wep_3P_BlackBird_AutoTurret_MIC", MIC_Pickup="wep_skinset54_mat.Wep_3P_BlackBird_AutoTurrent_Pickup_MIC")) 

//Sentinel Hades
	Skins.Add((Id=9287, Weapondef=class'KFWeapDef_AutoTurret', MIC_1P=("WEP_SkinSet54_MAT.Wep_1P_Hades_AutoTurret_MIC","WEP_SkinSet54_MAT.Wep_1P_Hades_Remote_MIC"), MIC_3P="wep_skinset54_mat.Wep_3P_Hades_AutoTurret_MIC", MIC_Pickup="wep_skinset54_mat.Wep_3P_Hades_AutoTurrent_Pickup_MIC")) 

//Sentinel Ice Storm
	Skins.Add((Id=9288, Weapondef=class'KFWeapDef_AutoTurret', MIC_1P=("WEP_SkinSet54_MAT.Wep_1P_IceStorm_AutoTurret_MIC","WEP_SkinSet54_MAT.Wep_1P_IceStorm_Remote_MIC"), MIC_3P="wep_skinset54_mat.Wep_3P_IceStorm_AutoTurret_MIC", MIC_Pickup="wep_skinset54_mat.Wep_3P_IceStorm_AutoTurrent_Pickup_MIC")) 

//Sentinel Shock
 	Skins.Add((Id=9289, Weapondef=class'KFWeapDef_AutoTurret', MIC_1P=("WEP_SkinSet54_MAT.Wep_1P_Shock_AutoTurret_MIC","WEP_SkinSet54_MAT.Wep_1P_Shock_Remote_MIC"), MIC_3P="wep_skinset54_mat.Wep_3P_Shock_AutoTurret_MIC", MIC_Pickup="wep_skinset54_mat.Wep_3P_Shock_AutoTurrent_Pickup_MIC")) 

//Reducto Ray Standard
    Skins.Add((Id=9290, Weapondef=class'KFWeapDef_ShrinkRayGun', MIC_1P=("wep_1p_shrinkray_gun_mat.Wep_1P_ShrinkRay_Gun_MIC","WEP_1P_ShrinkRay_Gun_MAT.WEP_ShrinkRay_Glass_MIC"), MIC_3P="wep_3p_shrinkray_gun_mat.WEP_3P_ShrinkRay_Gun_MIC", MIC_Pickup="wep_3p_shrinkray_gun_mat.3P_Pickup_ShrinkRay_Gun_MIC")) 

//Reducto Ray Atomic Love
    Skins.Add((Id=9291, Weapondef=class'KFWeapDef_ShrinkRayGun', MIC_1P=("wep_skinset55_mat.Wep_1P_AtomicLove_ShrinkRay_Gun_MIC","WEP_1P_ShrinkRay_Gun_MAT.WEP_ShrinkRay_Glass_MIC"), MIC_3P="wep_skinset55_mat.Wep_3P_AtomicLove_ShrinkRay_Gun_MIC", MIC_Pickup="wep_skinset55_mat.Wep_3P_AtomicLove_ShrinkRay_Pickup_MIC")) 

//Reducto Ray Destructor
    Skins.Add((Id=9292, Weapondef=class'KFWeapDef_ShrinkRayGun', MIC_1P=("wep_skinset55_mat.Wep_1P_Destructor_ShrinkRay_Gun_MIC","WEP_1P_ShrinkRay_Gun_MAT.WEP_ShrinkRay_Glass_MIC"), MIC_3P="wep_skinset55_mat.Wep_3P_Destructor_ShrinkRay_Gun_MIC", MIC_Pickup="wep_skinset55_mat.Wep_3P_Destructor_ShrinkRay_Pickup_MIC")) 

//Reducto Ray Heavy Metal
    Skins.Add((Id=9293, Weapondef=class'KFWeapDef_ShrinkRayGun', MIC_1P=("wep_skinset55_mat.Wep_1P_HeavyMetal_ShrinkRay_Gun_MIC","WEP_1P_ShrinkRay_Gun_MAT.WEP_ShrinkRay_Glass_MIC"), MIC_3P="wep_skinset55_mat.Wep_3P_HeavyMetal_ShrinkRay_Gun_MIC", MIC_Pickup="wep_skinset55_mat.Wep_3P_HeavyMetal_ShrinkRay_Pickup_MIC")) 

//Reducto Ray HellsFury
    Skins.Add((Id=9294, Weapondef=class'KFWeapDef_ShrinkRayGun', MIC_1P=("wep_skinset55_mat.Wep_1P_HellsFury_ShrinkRay_Gun_MIC","WEP_1P_ShrinkRay_Gun_MAT.WEP_ShrinkRay_Glass_MIC"), MIC_3P="wep_skinset55_mat.Wep_3P_HellsFury_ShrinkRay_Gun_MIC", MIC_Pickup="wep_skinset55_mat.Wep_3P_HellsFury_ShrinkRay_Pickup_MIC")) 

//Reducto Ray Lucky Strike
    Skins.Add((Id=9295, Weapondef=class'KFWeapDef_ShrinkRayGun', MIC_1P=("wep_skinset55_mat.Wep_1P_LuckyStrike_ShrinkRay_Gun_MIC","WEP_1P_ShrinkRay_Gun_MAT.WEP_ShrinkRay_Glass_MIC"), MIC_3P="wep_skinset55_mat.Wep_3P_LuckyStrike_ShrinkRay_Gun_MIC", MIC_Pickup="wep_skinset55_mat.Wep_3P_LuckyStrike_ShrinkRay_Pickup_MIC")) 

//Blood Sickle Standard
    Skins.Add((Id=9478, Weapondef=class'KFWeapDef_Scythe', MIC_1P=("wep_1p_scythe_mat.Wep_1stP_Scythe_MIC"), MIC_3P="WEP_3P_Scythe_MAT.WEP_3P_Scythe_MIC", MIC_Pickup="wep_3p_scythe_mat.WEP_3P_ScythePickup_MIC")) 

//Blood Sickle Bloodbath
	Skins.Add((Id=9473, Weapondef=class'KFWeapDef_Scythe', MIC_1P=("WEP_SkinSet65_MAT.Wep_1P_Bloodbath_Scythe_MIC"), MIC_3P="WEP_SkinSet65_MAT.Wep_3P_Bloodbath_Scythe_MIC", MIC_Pickup="WEP_SkinSet65_MAT.Wep_3P_Bloodbath_Scythe_Pickup_MIC")) 

//Blood Sickle Butchery
	Skins.Add((Id=9474, Weapondef=class'KFWeapDef_Scythe', MIC_1P=("WEP_SkinSet65_MAT.Wep_1P_Butchery_Scythe_MIC"), MIC_3P="WEP_SkinSet65_MAT.Wep_3P_Butchery_Scythe_MIC", MIC_Pickup="WEP_SkinSet65_MAT.Wep_3P_Butchery_Scythe_Pickup_MIC")) 

//Blood Sickle Carousel
	Skins.Add((Id=9475, Weapondef=class'KFWeapDef_Scythe', MIC_1P=("WEP_SkinSet65_MAT.Wep_1P_Carousel_Scythe_MIC"), MIC_3P="WEP_SkinSet65_MAT.Wep_3P_Carousel_Scythe_MIC", MIC_Pickup="WEP_SkinSet65_MAT.Wep_3P_Caurel_Scythe_Pickup_MIC")) 

//Blood Sickle Hunter
	Skins.Add((Id=9477, Weapondef=class'KFWeapDef_Scythe', MIC_1P=("WEP_SkinSet65_MAT.Wep_1P_Hunter_Scythe_MIC"), MIC_3P="WEP_SkinSet65_MAT.Wep_3P_Hunter_Scythe_MIC", MIC_Pickup="WEP_SkinSet65_MAT.Wep_3P_Hunter_Scythe_Pickup_MIC")) 

//Blood Sickle Reaper
 	Skins.Add((Id=9476, Weapondef=class'KFWeapDef_Scythe', MIC_1P=("WEP_SkinSet65_MAT.Wep_1P_Reaper_Scythe_MIC"), MIC_3P="WEP_SkinSet65_MAT.Wep_3P_Reaper_Scythe_MIC", MIC_Pickup="WEP_SkinSet65_MAT.Wep_3P_Reaper_Scythe_Pickup_MIC")) 

//G36C Standard
    Skins.Add((Id=9484, Weapondef=class'KFWeapDef_G36C', MIC_1P=("wep_1p_g36c_mat.Wep_1stP_G36C_MIC","wep_1p_g36c_mat.Wep_1stP_G36C_Scope_MIC"), MIC_3P="wep_3p_g36c_mat.Wep_3rdP_G36C_MIC", MIC_Pickup="wep_3p_g36c_mat.3P_Pickup_G36C_MIC")) 

//G36C Aftermath
    Skins.Add((Id=9481, Weapondef=class'KFWeapDef_G36C', MIC_1P=("wep_skinset64_mat.Wep_1P_Aftermatch_G36C_MIC","wep_skinset64_mat.Wep_1P_Aftermatch_Scope_G36C_MIC"), MIC_3P="wep_skinset64_mat.Wep_3P_Aftermatch_G36C_MIC", MIC_Pickup="wep_skinset64_mat.Wep_3P_Aftermatch_G36C_Pickup_MIC")) 

//G36C Dazzle
    Skins.Add((Id=9483, Weapondef=class'KFWeapDef_G36C', MIC_1P=("wep_skinset64_mat.Wep_1P_Dazzle_G36C_MIC","wep_skinset64_mat.Wep_1P_Dazzle_Scope_G36C_MIC"), MIC_3P="wep_skinset64_mat.Wep_3P_Dazzle_G36C_MIC", MIC_Pickup="wep_skinset64_mat.Wep_3P_Dazzle_G36C_Pickup_MIC")) 

//G36C Icepack
    Skins.Add((Id=9480, Weapondef=class'KFWeapDef_G36C', MIC_1P=("wep_skinset64_mat.Wep_1P_Icepack_G36C_MIC","wep_skinset64_mat.Wep_1P_Icepack_Scope_G36C_MIC"), MIC_3P="wep_skinset64_mat.Wep_3P_Icepack_G36C_MIC", MIC_Pickup="wep_skinset64_mat.Wep_3P_Icepack_G36C_Pickup_MIC")) 

//G36C Jungle
    Skins.Add((Id=9482, Weapondef=class'KFWeapDef_G36C', MIC_1P=("wep_skinset64_mat.Wep_1P_Jungle_G36C_MIC","wep_skinset64_mat.Wep_1P_Jungle_Scope_G36C_MIC"), MIC_3P="wep_skinset64_mat.Wep_3P_Jungle_G36C_MIC", MIC_Pickup="wep_skinset64_mat.Wep_3P_Jungle_G36C_Pickup_MIC")) 

//G36C Sahara
    Skins.Add((Id=9479, Weapondef=class'KFWeapDef_G36C', MIC_1P=("wep_skinset64_mat.Wep_1P_Sahara_G36C_MIC","wep_skinset64_mat.Wep_1P_Sahara_Scope_G36C_MIC"), MIC_3P="wep_skinset64_mat.Wep_3P_Sahara_G36C_MIC", MIC_Pickup="wep_skinset64_mat.Wep_3P_Sahara_G36C_Pickup_MIC")) 

//HVStormCannon Standard
    Skins.Add((Id=9569, Weapondef=class'KFWeapDef_HVStormCannon', MIC_1P=("WEP_1P_HVStormCannon_MAT.Wep_1P_HVStormCannon_MIC","WEP_1P_HVStormCannon_MAT.Wep_1P_HVStormCannon_Scope_MIC"), MIC_3P="wep_3p_hvstormcannon_mat.WEP_3P_HVStormCannon_MIC", MIC_Pickup="wep_3p_hvstormcannon_mat.3P_Pickup_HVStormCannon_MIC"))

//HVStormCannon Lost Planet
    Skins.Add((Id=9570, Weapondef=class'KFWeapDef_HVStormCannon', MIC_1P=("wep_skinset70_mat.Wep_1P_StormCannon_LostPlanet_MIC","wep_skinset70_mat.Wep_1P_StormCannon_LostPlanet_Scope_MIC"), MIC_3P="wep_skinset70_mat.Wep_3P_StormCannon_LostPlanet_MIC", MIC_Pickup="wep_skinset70_mat.Wep_3P_StormCannon_LostPlanet_Pickup_MIC"))

//HVStormCannon Morph
    Skins.Add((Id=9571, Weapondef=class'KFWeapDef_HVStormCannon', MIC_1P=("wep_skinset70_mat.Wep_1P_StormCannon_Xeno_MIC","wep_skinset70_mat.Wep_1P_StormCannon_Xeno_Scope_MIC"), MIC_3P="wep_skinset70_mat.Wep_3P_StormCannon_Xeno_MIC", MIC_Pickup="wep_skinset70_mat.Wep_3P_StormCannon_Xeno_Pickup_MIC"))

//HVStormCannon Rebel
    Skins.Add((Id=9572, Weapondef=class'KFWeapDef_HVStormCannon', MIC_1P=("wep_skinset70_mat.Wep_1P_StormCannon_Rebel_MIC","wep_skinset70_mat.Wep_1P_StormCannon_Rebel_Scope_MIC"), MIC_3P="wep_skinset70_mat.Wep_3P_StormCannon_Rebel_MIC", MIC_Pickup="wep_skinset70_mat.Wep_3P_StormCannon_Rebel_Pickup_MIC"))

//HVStormCannon Space Man
    Skins.Add((Id=9573, Weapondef=class'KFWeapDef_HVStormCannon', MIC_1P=("wep_skinset70_mat.Wep_1P_StormCannon_SpaceMan_MIC","wep_skinset70_mat.Wep_1P_StormCannon_SpaceMan_Scope_MIC"), MIC_3P="wep_skinset70_mat.Wep_3P_StormCannon_SpaceMan_MIC", MIC_Pickup="wep_skinset70_mat.Wep_3P_StormCannon_SpaceMan_Pickup_MIC"))

//HVStormCannon Tycho
    Skins.Add((Id=9574, Weapondef=class'KFWeapDef_HVStormCannon', MIC_1P=("wep_skinset70_mat.Wep_1P_StormCannon_Tycho_MIC","wep_skinset70_mat.Wep_1P_StormCannon_Tycho_Scope_MIC"), MIC_3P="wep_skinset70_mat.Wep_3P_StormCannon_Tycho_MIC", MIC_Pickup="wep_skinset70_mat.Wep_3P_StormCannon_Tycho_Pickup_MIC"))

//ZEDMKIII Standard
    Skins.Add((Id=9575, Weapondef=class'KFWeapDef_ZedMKIII', MIC_1P=("WEP_1P_ZEDMKIII_MAT.Wep_1stP_ZEDMKIII_MIC"), MIC_3P="Wep_3P_ZEDMKIII_MAT.Wep_3rdP_ZEDMKIII_MIC", MIC_Pickup="wep_3p_zedmkiii_mat.Wep_3rdP_ZEDMKIII_Pickup_MIC")) 

//ZEDMKIII Army
    Skins.Add((Id=9576, Weapondef=class'KFWeapDef_ZedMKIII', MIC_1P=("WEP_SkinSet71_MAT.Wep_1P_ZEDMKIII_Army_MIC"), MIC_3P="WEP_SkinSet71_MAT.Wep_3P_ZEDMKIII_Army_MIC", MIC_Pickup="WEP_SkinSet71_MAT.Wep_3P_ZEDMKIII_Army_Pickup_MIC")) 

//ZEDMKIII Delux
    Skins.Add((Id=9577, Weapondef=class'KFWeapDef_ZedMKIII', MIC_1P=("WEP_SkinSet71_MAT.Wep_1P_ZEDMKIII_Deluxe_MIC"), MIC_3P="WEP_SkinSet71_MAT.Wep_3P_ZEDMKIII_Deluxe_MIC", MIC_Pickup="WEP_SkinSet71_MAT.Wep_3P_ZEDMKIII_Deluxe_MIC")) 

//ZEDMKIII Ice Storm
    Skins.Add((Id=9578, Weapondef=class'KFWeapDef_ZedMKIII', MIC_1P=("WEP_SkinSet71_MAT.Wep_1P_ZEDMKIII_Ice_MIC"), MIC_3P="WEP_SkinSet71_MAT.Wep_3P_ZEDMKIII_Ice_MIC", MIC_Pickup="WEP_SkinSet71_MAT.Wep_3P_ZEDMKIII_Ice_Pickup_MIC")) 

//ZEDMKIII Industrial
    Skins.Add((Id=9579, Weapondef=class'KFWeapDef_ZedMKIII', MIC_1P=("WEP_SkinSet71_MAT.Wep_1P_ZEDMKIII_Industrial_MIC"), MIC_3P="WEP_SkinSet71_MAT.Wep_3P_ZEDMKIII_Industrial_MIC", MIC_Pickup="WEP_SkinSet71_MAT.Wep_3P_ZEDMKIII_Industrial_Pickup_MIC")) 

//ZEDMKIII Tiger
    Skins.Add((Id=9580, Weapondef=class'KFWeapDef_ZedMKIII', MIC_1P=("WEP_SkinSet71_MAT.Wep_1P_ZEDMKIII_Tiger_MIC"), MIC_3P="WEP_SkinSet71_MAT.Wep_3P_ZEDMKIII_Tiger_MIC", MIC_Pickup="WEP_SkinSet71_MAT.Wep_3P_ZEDMKIII_Tiger_MIC"))

//BeyondHorizon AA12
    Skins.Add((Id=8845, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet43_MAT.space_aa12.Space_AA12_1P_Mint_MIC"), MIC_3P="WEP_SkinSet43_MAT.space_aa12.Space_AA12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet43_MAT.space_aa12.Space_AA12_3P_Pickup_MIC")) 

//BeyondHorizon AK12
    Skins.Add((Id=8846, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet43_MAT.space_ak12.Space_AK12_1P_Mint_MIC", "WEP_SkinSet43_MAT.space_ak12.Space_AK12_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet43_MAT.space_ak12.Space_AK12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet43_MAT.space_ak12.Space_AK12_3P_Pickup_MIC")) 

//BeyondHorizon Desert Eagle
    Skins.Add((Id=8847, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet43_MAT.space_deagle.Space_Deagle_1P_Mint_MIC"), MIC_3P="WEP_SkinSet43_MAT.space_deagle.Space_Deagle_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet43_MAT.space_deagle.Space_Deagle_3P_Pickup_MIC")) 

//BeyondHorizon Doomstick
    Skins.Add((Id=8848, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_ElephantGun', MIC_1P=("WEP_SkinSet43_MAT.space_quadbarrel.Space_QuadBarrel_Main_1P_Mint_MIC", "WEP_SkinSet43_MAT.space_quadbarrel.Space_QuadBarrel_Barrel_1P_Mint_MIC"), MIC_3P="WEP_SkinSet43_MAT.space_quadbarrel.Space_QuadBarrel_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet43_MAT.space_quadbarrel.Space_QuadBarrel_3P_Pickup_MIC")) 

//BeyondHorizon Hemoclobber
    Skins.Add((Id=8849, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MedicBat', MIC_1P=("WEP_SkinSet43_MAT.space_medicbat.Space_MedicBat_1P_Mint_MIC"), MIC_3P="WEP_SkinSet43_MAT.space_medicbat.Space_MedicBat_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet43_MAT.space_medicbat.Space_MedicBat_3P_Pickup_MIC")) 

//BeyondHorizon HMTech-501 Grenade Rifle
    Skins.Add((Id=8850, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MedicRifleGrenadeLauncher', MIC_1P=("WEP_SkinSet43_MAT.space_medicgrenadelauncher.Space_MedicGrenadeLauncher_1P_Mint_MIC"), MIC_3P="WEP_SkinSet43_MAT.space_medicgrenadelauncher.Space_MedicGrenadeLauncher_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet43_MAT.space_medicgrenadelauncher.Space_MedicGrenadeLauncher_3P_Pickup_MIC")) 

//BeyondHorizon M32
    Skins.Add((Id=8851, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_M32', MIC_1P=("WEP_SkinSet43_MAT.space_m32.Space_M32_1P_Mint_MIC", "WEP_SkinSet43_MAT.space_m32.Space_M32_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet43_MAT.space_m32.Space_M32_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet43_MAT.space_m32.Space_M32_3P_Pickup_MIC")) 

//BeyondHorizon MAC 10
    Skins.Add((Id=8852, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Mac10', MIC_1P=("WEP_SkinSet43_MAT.space_mac10.Space_MAC10_1P_Mint_MIC"), MIC_3P="WEP_SkinSet43_MAT.space_mac10.Space_MAC10_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet43_MAT.space_mac10.Space_MAC10_3P_Pickup_MIC")) 

//BeyondHorizon Microwave Gun
    Skins.Add((Id=8853, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MicrowaveGun', MIC_1P=("WEP_SkinSet43_MAT.space_microwavegun.Space_MicrowaveGun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet43_MAT.space_microwavegun.Space_MicrowaveGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet43_MAT.space_microwavegun.Space_MicrowaveGun_3P_Pickup_MIC")) 

//BeyondHorizon P90
    Skins.Add((Id=8854, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_P90', MIC_1P=("WEP_SkinSet43_MAT.space_p90.Space_P90_1P_Mint_MIC", "WEP_SkinSet43_MAT.space_p90.Space_P90_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet43_MAT.space_p90.Space_P90_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet43_MAT.space_p90.Space_P90_3P_Pickup_MIC")) 

//BeyondHorizon AA12
    Skins.Add((Id=8855, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet43_MAT.spaceelite_aa12.SpaceElite_AA12_1P_Mint_MIC"), MIC_3P="WEP_SkinSet43_MAT.spaceelite_aa12.SpaceElite_AA12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet43_MAT.spaceelite_aa12.SpaceElite_AA12_3P_Pickup_MIC")) 

//BeyondHorizon AK12
    Skins.Add((Id=8856, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet43_MAT.spaceelite_ak12.SpaceElite_AK12_1P_Mint_MIC", "WEP_SkinSet43_MAT.spaceelite_ak12.SpaceElite_AK12_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet43_MAT.spaceelite_ak12.SpaceElite_AK12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet43_MAT.spaceelite_ak12.SpaceElite_AK12_3P_Pickup_MIC")) 

//BeyondHorizon Desert Eagle
    Skins.Add((Id=8857, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet43_MAT.spaceelite_deagle.SpaceElite_Deagle_1P_Mint_MIC"), MIC_3P="WEP_SkinSet43_MAT.spaceelite_deagle.SpaceElite_Deagle_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet43_MAT.spaceelite_deagle.SpaceElite_Deagle_3P_Pickup_MIC")) 

//BeyondHorizon Doomstick
    Skins.Add((Id=8858, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_ElephantGun', MIC_1P=("WEP_SkinSet43_MAT.spaceelite_quadbarrel.SpaceElite_QuadBarrel_Main_1P_Mint_MIC", "WEP_SkinSet43_MAT.spaceelite_quadbarrel.SpaceElite_QuadBarrel_Barrel_1P_Mint_MIC"), MIC_3P="WEP_SkinSet43_MAT.spaceelite_quadbarrel.SpaceElite_QuadBarrel_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet43_MAT.spaceelite_quadbarrel.SpaceElite_QuadBarrel_3P_Pickup_MIC")) 

//BeyondHorizon Hemoclobber
    Skins.Add((Id=8859, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MedicBat', MIC_1P=("WEP_SkinSet43_MAT.spaceelite_medicbat.SpaceElite_MedicBat_1P_Mint_MIC"), MIC_3P="WEP_SkinSet43_MAT.spaceelite_medicbat.SpaceElite_MedicBat_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet43_MAT.spaceelite_medicbat.SpaceElite_MedicBat_3P_Pickup_MIC")) 

//BeyondHorizon HMTech-501 Grenade Rifle
    Skins.Add((Id=8860, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MedicRifleGrenadeLauncher', MIC_1P=("WEP_SkinSet43_MAT.spaceelite_medicgrenadelauncher.SpaceElite_MedicGrenadeLauncher_1P_Mint_MIC"), MIC_3P="WEP_SkinSet43_MAT.spaceelite_medicgrenadelauncher.SpaceElite_MedicGrenadeLauncher_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet43_MAT.spaceelite_medicgrenadelauncher.SpaceElite_MedicGrenadeLauncher_3P_Pickup_MIC")) 

//BeyondHorizon M32
    Skins.Add((Id=8861, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_M32', MIC_1P=("WEP_SkinSet43_MAT.spaceelite_m32.SpaceElite_M32_1P_Mint_MIC", "WEP_SkinSet43_MAT.spaceelite_m32.SpaceElite_M32_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet43_MAT.spaceelite_m32.SpaceElite_M32_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet43_MAT.spaceelite_m32.SpaceElite_M32_3P_Pickup_MIC")) 

//BeyondHorizon MAC 10
    Skins.Add((Id=8862, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Mac10', MIC_1P=("WEP_SkinSet43_MAT.spaceelite_mac10.SpaceElite_MAC10_1P_Mint_MIC"), MIC_3P="WEP_SkinSet43_MAT.spaceelite_mac10.SpaceElite_MAC10_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet43_MAT.spaceelite_mac10.SpaceElite_MAC10_3P_Pickup_MIC")) 

//BeyondHorizon Microwave Gun
    Skins.Add((Id=8863, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MicrowaveGun', MIC_1P=("WEP_SkinSet43_MAT.spaceelite_microwavegun.SpaceElite_MicrowaveGun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet43_MAT.spaceelite_microwavegun.SpaceElite_MicrowaveGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet43_MAT.spaceelite_microwavegun.SpaceElite_MicrowaveGun_3P_Pickup_MIC")) 

//BeyondHorizon P90
    Skins.Add((Id=8864, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_P90', MIC_1P=("WEP_SkinSet43_MAT.spaceelite_p90.SpaceElite_P90_1P_Mint_MIC", "WEP_SkinSet43_MAT.spaceelite_p90.SpaceElite_P90_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet43_MAT.spaceelite_p90.SpaceElite_P90_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet43_MAT.spaceelite_p90.SpaceElite_P90_3P_Pickup_MIC")) 

//Scavenger AK12
	Skins.Add((Id=8921, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("wep_skinset44_mat.scavenger_ak12.Scavenger_AK12_1P_Mint_MIC", "wep_skinset44_mat.scavenger_ak12.Scavenger_AK12_Scope_1P_Mint_MIC"), MIC_3P="wep_skinset44_mat.scavenger_ak12.Scavenger_AK12_3P_Mint_MIC", MIC_Pickup="wep_skinset44_mat.scavenger_ak12.Scavenger_AK12_3P_Pickup_MIC")) 

//Infernal Elite Kriss
	Skins.Add((Id=9081, Weapondef=class'KFWeapDef_Kriss', MIC_1P=("wep_skinset47_mat.elite_kriss.Elite_Kriss_1P_Mint_MIC", "wep_skinset47_mat.elite_kriss.Elite_Kriss_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet47_MAT.elite_kriss.Elite_Kriss_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet47_MAT.elite_kriss.Elite_Kriss_3P_Pickup_MIC")) 

//Hellmark Magma Katana
    Skins.Add((Id=8991, Weapondef=class'KFWeapDef_Katana', MIC_1P=("WEP_SkinSet48_MAT.hellblade_katana.Hellblade_Katana_1P_Mint_MIC"), MIC_3P="WEP_SkinSet48_MAT.hellblade_katana.Hellblade_Katana_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet48_MAT.hellblade_katana.Hellblade_Katana_3P_Pickup_MIC")) 

//Hellmark Magma BattleAxe
    Skins.Add((Id=8992, Weapondef=class'KFWeapDef_AbominationAxe', MIC_1P=("WEP_SkinSet48_MAT.hellblade_krampusaxe.Hellblade_KrampusAxe_1P_Mint_MIC"), MIC_3P="WEP_SkinSet48_MAT.hellblade_krampusaxe.Hellblade_KrampusAxe_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet48_MAT.hellblade_krampusaxe.Hellblade_KrampusAxe_3P_Pickup_MIC")) 

//Hellmark Magma Fire Axe
    Skins.Add((Id=8993, Weapondef=class'KFWeapDef_FireAxe', MIC_1P=("WEP_SkinSet48_MAT.hellblade_fireaxe.Hellblade_FireAxe_1P_Mint_MIC"), MIC_3P="WEP_SkinSet48_MAT.hellblade_fireaxe.Hellblade_FireAxe_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet48_MAT.hellblade_fireaxe.Hellblade_FireAxe_3P_Pickup_MIC")) 

//Hellmark Magma Bone Crusher
    Skins.Add((Id=8994, Weapondef=class'KFWeapDef_MaceAndShield', MIC_1P=("WEP_SkinSet48_MAT.hellblade_maceshield.Hellblade_Mace_1P_Mint_MIC", "WEP_SkinSet48_MAT.hellblade_maceshield.Hellblade_Shield_1P_Mint_MIC"), MIC_3P="WEP_SkinSet48_MAT.hellblade_maceshield.Hellblade_MaceAndShield_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet48_MAT.hellblade_maceshield.Hellblade_MaceAndShield_3P_Pickup_MIC")) 

//Hellmark Magma Pulverizer
    Skins.Add((Id=8995, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Pulverizer', MIC_1P=("WEP_SkinSet48_MAT.hellblade_pulverizer.Hellblade_Pulverizer_1P_Mint_MIC"), MIC_3P="WEP_SkinSet48_MAT.hellblade_pulverizer.Hellblade_Pulverizer_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet48_MAT.hellblade_pulverizer.Hellblade_Pulverizer_3P_Pickup_MIC")) 

//Hellmark Magma Dragonsbreath
    Skins.Add((Id=8996, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Dragonsbreath', MIC_1P=("WEP_SkinSet48_MAT.hellblade_dragonsbreath.Hellblade_Dragonsbreath_1P_Mint_MIC"), MIC_3P="WEP_SkinSet48_MAT.hellblade_dragonsbreath.Hellblade_Dragonsbreath_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet48_MAT.hellblade_dragonsbreath.Hellblade_Dragonsbreath_3P_Pickup_MIC")) 

//Hellmark Magma 500 Magnum Revolver
    Skins.Add((Id=8997, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_SW500', MIC_1P=("WEP_SkinSet48_MAT.hellblade_sw500.Hellblade_SW500_1P_Mint_MIC"), MIC_3P="WEP_SkinSet48_MAT.hellblade_sw500.Hellblade_SW500_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet48_MAT.hellblade_sw500.Hellblade_SW500_3P_Pickup_MIC")) 

//Hellmark Magma RPG-7
    Skins.Add((Id=8998, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_RPG7', MIC_1P=("WEP_SkinSet48_MAT.hellblade_rpg7.Hellblade_RPG7_1P_Mint_MIC"), MIC_3P="WEP_SkinSet48_MAT.hellblade_rpg7.Hellblade_RPG7_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet48_MAT.hellblade_rpg7.Hellblade_RPG7_3P_Pickup_MIC")) 

//Hellmark Magma Doomstick
    Skins.Add((Id=8999, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_ElephantGun', MIC_1P=("WEP_SkinSet48_MAT.hellblade_quadbarrel.Hellblade_QuadBarrel_Main_1P_Mint_MIC", "WEP_SkinSet48_MAT.hellblade_quadbarrel.Hellblade_QuadBarrel_Barrel_1P_Mint_MIC"), MIC_3P="WEP_SkinSet48_MAT.hellblade_quadbarrel.Hellblade_QuadBarrel_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet48_MAT.hellblade_quadbarrel.Hellblade_QuadBarrel_3P_Pickup_MIC")) 

//Hellmark Magma Hemoclobber
    Skins.Add((Id=9000, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MedicBat', MIC_1P=("WEP_SkinSet48_MAT.hellblade_medicbat.Hellblade_MedicBat_1P_Mint_MIC"), MIC_3P="WEP_SkinSet48_MAT.hellblade_medicbat.Hellblade_MedicBat_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet48_MAT.hellblade_medicbat.Hellblade_MedicBat_3P_Pickup_MIC")) 

//Hellmark Thunder Katana
    Skins.Add((Id=9001, Weapondef=class'KFWeapDef_Katana', MIC_1P=("WEP_SkinSet48_MAT.thunder_katana.Thunder_Katana_1P_Mint_MIC"), MIC_3P="WEP_SkinSet48_MAT.thunder_katana.Thunder_Katana_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet48_MAT.thunder_katana.Thunder_Katana_3P_Pickup_MIC")) 

//Hellmark Thunder BattleAxe
    Skins.Add((Id=9002, Weapondef=class'KFWeapDef_AbominationAxe', MIC_1P=("WEP_SkinSet48_MAT.thunder_krampusaxe.Thunder_KrampusAxe_1P_Mint_MIC"), MIC_3P="WEP_SkinSet48_MAT.thunder_krampusaxe.Thunder_KrampusAxe_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet48_MAT.thunder_krampusaxe.Thunder_KrampusAxe_3P_Pickup_MIC")) 

//Hellmark Thunder Fire Axe
    Skins.Add((Id=9003, Weapondef=class'KFWeapDef_FireAxe', MIC_1P=("WEP_SkinSet48_MAT.thunder_fireaxe.Thunder_FireAxe_1P_Mint_MIC"), MIC_3P="WEP_SkinSet48_MAT.thunder_fireaxe.Thunder_FireAxe_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet48_MAT.thunder_fireaxe.Thunder_FireAxe_3P_Pickup_MIC")) 

//Hellmark Thunder Bone Crusher
    Skins.Add((Id=9004, Weapondef=class'KFWeapDef_MaceAndShield', MIC_1P=("WEP_SkinSet48_MAT.thunder_maceshield.Thunder_Mace_1P_Mint_MIC", "WEP_SkinSet48_MAT.thunder_maceshield.Thunder_Shield_1P_Mint_MIC"), MIC_3P="WEP_SkinSet48_MAT.thunder_maceshield.Thunder_MaceAndShield_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet48_MAT.thunder_maceshield.Thunder_MaceAndShield_3P_Pickup_MIC")) 

//Hellmark Thunder Pulverizer
    Skins.Add((Id=9005, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Pulverizer', MIC_1P=("WEP_SkinSet48_MAT.thunder_pulverizer.Thunder_Pulverizer_1P_Mint_MIC"), MIC_3P="WEP_SkinSet48_MAT.thunder_pulverizer.Thunder_Pulverizer_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet48_MAT.thunder_pulverizer.Thunder_Pulverizer_3P_Pickup_MIC")) 

//Hellmark Thunder Dragonsbreath
    Skins.Add((Id=9006, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Dragonsbreath', MIC_1P=("WEP_SkinSet48_MAT.thunder_dragonsbreath.Thunder_Dragonsbreath_1P_Mint_MIC"), MIC_3P="WEP_SkinSet48_MAT.thunder_dragonsbreath.Thunder_Dragonsbreath_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet48_MAT.thunder_dragonsbreath.Thunder_Dragonsbreath_3P_Pickup_MIC")) 

//Hellmark Thunder 500 Magnum Revolver
    Skins.Add((Id=9007, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_SW500', MIC_1P=("WEP_SkinSet48_MAT.thunder_sw500.Thunder_SW500_1P_Mint_MIC"), MIC_3P="WEP_SkinSet48_MAT.thunder_sw500.Thunder_SW500_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet48_MAT.thunder_sw500.Thunder_SW500_3P_Pickup_MIC")) 

//Hellmark Thunder RPG-7
    Skins.Add((Id=9008, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_RPG7', MIC_1P=("WEP_SkinSet48_MAT.thunder_rpg7.Thunder_RPG7_1P_Mint_MIC"), MIC_3P="WEP_SkinSet48_MAT.thunder_rpg7.Thunder_RPG7_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet48_MAT.thunder_rpg7.Thunder_RPG7_3P_Pickup_MIC")) 

//Hellmark Thunder Doomstick
    Skins.Add((Id=9009, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_ElephantGun', MIC_1P=("WEP_SkinSet48_MAT.thunder_quadbarrel.Thunder_QuadBarrel_Main_1P_Mint_MIC", "WEP_SkinSet48_MAT.thunder_quadbarrel.Thunder_QuadBarrel_Barrel_1P_Mint_MIC"), MIC_3P="WEP_SkinSet48_MAT.thunder_quadbarrel.Thunder_QuadBarrel_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet48_MAT.thunder_quadbarrel.Thunder_QuadBarrel_3P_Pickup_MIC")) 

//Hellmark Thunder Hemoclobber
    Skins.Add((Id=9010, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MedicBat', MIC_1P=("WEP_SkinSet48_MAT.thunder_medicbat.Thunder_MedicBat_1P_Mint_MIC"), MIC_3P="WEP_SkinSet48_MAT.thunder_medicbat.Thunder_MedicBat_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet48_MAT.thunder_medicbat.Thunder_MedicBat_3P_Pickup_MIC")) 

//Alchemist Toxic Boomstick
    Skins.Add((Id=9178, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_DoubleBarrel', MIC_1P=("WEP_SkinSet51_MAT.toxic_doublebarrel.Toxic_DoubleBarrel_1P_Mint_MIC"), MIC_3P="WEP_SkinSet51_MAT.toxic_doublebarrel.Toxic_DoubleBarrel_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet51_MAT.toxic_doublebarrel.Toxic_DoubleBarrel_3P_Pickup_MIC")) 

//Alchemist Toxic Caulk n Burn
    Skins.Add((Id=9179, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_CaulkBurn', MIC_1P=("WEP_SkinSet51_MAT.toxic_caulkburn.Toxic_CaulkBurn_1P_Mint_MIC"), MIC_3P="WEP_SkinSet51_MAT.toxic_caulkburn.Toxic_CaulkBurn_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet51_MAT.toxic_caulkburn.Toxic_CaulkBurn_3P_Pickup_MIC")) 

//Alchemist Toxic Desert Eagle
    Skins.Add((Id=9180, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet51_MAT.toxic_deagle.Toxic_Deagle_1P_Mint_MIC"), MIC_3P="WEP_SkinSet51_MAT.toxic_deagle.Toxic_Deagle_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet51_MAT.toxic_deagle.Toxic_Deagle_3P_Pickup_MIC")) 

//Alchemist Toxic Flamethrower
    Skins.Add((Id=9181, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_FlameThrower', MIC_1P=("WEP_SkinSet51_MAT.toxic_flamethrower.Toxic_Flamethrower_1P_Mint_MIC"), MIC_3P="WEP_SkinSet51_MAT.toxic_flamethrower.Toxic_Flamethrower_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet51_MAT.toxic_flamethrower.Toxic_Flamethrower_3P_Pickup_MIC")) 

//Alchemist Toxic HMTech-501 Grenade Rifle
    Skins.Add((Id=9182, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MedicRifleGrenadeLauncher', MIC_1P=("WEP_SkinSet51_MAT.toxic_medicgrenadelauncher.Toxic_MedicGrenadeLauncher_1P_Mint_MIC"), MIC_3P="WEP_SkinSet51_MAT.toxic_medicgrenadelauncher.Toxic_MedicGrenadeLauncher_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet51_MAT.toxic_medicgrenadelauncher.Toxic_MedicGrenadeLauncher_3P_Pickup_MIC")) 

//Alchemist Toxic M32
    Skins.Add((Id=9183, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_M32', MIC_1P=("WEP_SkinSet51_MAT.toxic_m32.Toxic_M32_1P_Mint_MIC", "WEP_SkinSet51_MAT.toxic_m32.Toxic_M32_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet51_MAT.toxic_m32.Toxic_M32_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet51_MAT.toxic_m32.Toxic_M32_3P_Pickup_MIC")) 

//Alchemist Toxic P90
    Skins.Add((Id=9184, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_P90', MIC_1P=("WEP_SkinSet51_MAT.toxic_p90.Toxic_P90_1P_Mint_MIC", "WEP_SkinSet51_MAT.toxic_p90.Toxic_P90_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet51_MAT.toxic_p90.Toxic_P90_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet51_MAT.toxic_p90.Toxic_P90_3P_Pickup_MIC")) 

//Alchemist Toxic RPG-7
    Skins.Add((Id=9185, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_RPG7', MIC_1P=("WEP_SkinSet51_MAT.toxic_rpg7.Toxic_RPG7_1P_Mint_MIC"), MIC_3P="WEP_SkinSet51_MAT.toxic_rpg7.Toxic_RPG7_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet51_MAT.toxic_rpg7.Toxic_RPG7_3P_Pickup_MIC")) 

//Alchemist Toxic Scar
    Skins.Add((Id=9186, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Scar', MIC_1P=("WEP_SkinSet51_MAT.toxic_scar.Toxic_SCAR_1P_Mint_MIC", "WEP_SkinSet51_MAT.toxic_scar.Toxic_SCAR_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet51_MAT.toxic_scar.Toxic_SCAR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet51_MAT.toxic_scar.Toxic_SCAR_3P_Pickup_MIC")) 

//Alchemist Toxic Spitfire
    Skins.Add((Id=9187, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Flaregun', MIC_1P=("WEP_SkinSet51_MAT.toxic_flaregun.Toxic_FlareGun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet51_MAT.toxic_flaregun.Toxic_FlareGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet51_MAT.toxic_flaregun.Toxic_FlareGun_3P_Pickup_MIC")) 

//Alchemist Blaze Boomstick
    Skins.Add((Id=9188, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_DoubleBarrel', MIC_1P=("WEP_SkinSet51_MAT.fire_doublebarrel.Fire_DoubleBarrel_1P_Mint_MIC"), MIC_3P="WEP_SkinSet51_MAT.fire_doublebarrel.Fire_DoubleBarrel_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet51_MAT.fire_doublebarrel.Fire_DoubleBarrel_3P_Pickup_MIC")) 

//Alchemist Blaze Caulk n Burn
    Skins.Add((Id=9189, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_CaulkBurn', MIC_1P=("WEP_SkinSet51_MAT.fire_caulkburn.Fire_CaulkBurn_1P_Mint_MIC"), MIC_3P="WEP_SkinSet51_MAT.fire_caulkburn.Fire_CaulkBurn_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet51_MAT.fire_caulkburn.Fire_CaulkBurn_3P_Pickup_MIC")) 

//Alchemist Blaze Desert Eagle
    Skins.Add((Id=9190, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet51_MAT.fire_deagle.Fire_Deagle_1P_Mint_MIC"), MIC_3P="WEP_SkinSet51_MAT.fire_deagle.Fire_Deagle_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet51_MAT.fire_deagle.Fire_Deagle_3P_Pickup_MIC")) 

//Alchemist Blaze Flamethrower
    Skins.Add((Id=9191, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_FlameThrower', MIC_1P=("WEP_SkinSet51_MAT.fire_flamethrower.Fire_Flamethrower_1P_Mint_MIC"), MIC_3P="WEP_SkinSet51_MAT.fire_flamethrower.Fire_Flamethrower_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet51_MAT.fire_flamethrower.Fire_Flamethrower_3P_Pickup_MIC")) 

//Alchemist Blaze HMTech-501 Grenade Rifle
    Skins.Add((Id=9192, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MedicRifleGrenadeLauncher', MIC_1P=("WEP_SkinSet51_MAT.fire_medicgrenadelauncher.Fire_MedicGrenadeLauncher_1P_Mint_MIC"), MIC_3P="WEP_SkinSet51_MAT.fire_medicgrenadelauncher.Fire_MedicGrenadeLauncher_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet51_MAT.fire_medicgrenadelauncher.Fire_MedicGrenadeLauncher_3P_Pickup_MIC")) 

//Alchemist Blaze M32
    Skins.Add((Id=9193, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_M32', MIC_1P=("WEP_SkinSet51_MAT.fire_m32.Fire_M32_1P_Mint_MIC", "WEP_SkinSet51_MAT.fire_m32.Fire_M32_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet51_MAT.fire_m32.Fire_M32_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet51_MAT.fire_m32.Fire_M32_3P_Pickup_MIC")) 

//Alchemist Blaze P90
    Skins.Add((Id=9194, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_P90', MIC_1P=("WEP_SkinSet51_MAT.fire_p90.Fire_P90_1P_Mint_MIC", "WEP_SkinSet51_MAT.fire_p90.Fire_P90_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet51_MAT.fire_p90.Fire_P90_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet51_MAT.fire_p90.Fire_P90_3P_Pickup_MIC")) 

//Alchemist Blaze RPG-7
    Skins.Add((Id=9195, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_RPG7', MIC_1P=("WEP_SkinSet51_MAT.fire_rpg7.Fire_RPG7_1P_Mint_MIC"), MIC_3P="WEP_SkinSet51_MAT.fire_rpg7.Fire_RPG7_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet51_MAT.fire_rpg7.Fire_RPG7_3P_Pickup_MIC")) 

//Alchemist Blaze Scar
    Skins.Add((Id=9196, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Scar', MIC_1P=("WEP_SkinSet51_MAT.fire_scar.Fire_SCAR_1P_Mint_MIC", "WEP_SkinSet51_MAT.fire_scar.Fire_SCAR_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet51_MAT.fire_scar.Fire_SCAR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet51_MAT.fire_scar.Fire_SCAR_3P_Pickup_MIC")) 

//Alchemist Blaze Spitfire
    Skins.Add((Id=9197, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Flaregun', MIC_1P=("WEP_SkinSet51_MAT.fire_flaregun.Fire_FlareGun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet51_MAT.fire_flaregun.Fire_FlareGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet51_MAT.fire_flaregun.Fire_FlareGun_3P_Pickup_MIC")) 

//XMas Sweet Boomstick
    Skins.Add((Id=9198, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_DoubleBarrel', MIC_1P=("WEP_SkinSet52_MAT.sweet_doublebarrel.Sweet_DoubleBarrel_1P_Mint_MIC"), MIC_3P="WEP_SkinSet52_MAT.sweet_doublebarrel.Sweet_DoubleBarrel_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet52_MAT.sweet_doublebarrel.Sweet_DoubleBarrel_3P_Pickup_MIC")) 

//XMas Sweet Caulk n Burn
    Skins.Add((Id=9199, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_CaulkBurn', MIC_1P=("WEP_SkinSet52_MAT.sweet_caulkburn.Sweet_CaulkBurn_1P_Mint_MIC"), MIC_3P="WEP_SkinSet52_MAT.sweet_caulkburn.Sweet_CaulkBurn_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet52_MAT.sweet_caulkburn.Sweet_CaulkBurn_3P_Pickup_MIC")) 

//XMas Sweet Desert Eagle
    Skins.Add((Id=9200, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet52_MAT.sweet_deagle.Sweet_Deagle_1P_Mint_MIC"), MIC_3P="WEP_SkinSet52_MAT.sweet_deagle.Sweet_Deagle_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet52_MAT.sweet_deagle.Sweet_Deagle_3P_Pickup_MIC")) 

//XMas Sweet Flamethrower
    Skins.Add((Id=9201, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_FlameThrower', MIC_1P=("WEP_SkinSet52_MAT.sweet_flamethrower.Sweet_Flamethrower_1P_Mint_MIC"), MIC_3P="WEP_SkinSet52_MAT.sweet_flamethrower.Sweet_Flamethrower_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet52_MAT.sweet_flamethrower.Sweet_Flamethrower_3P_Pickup_MIC")) 

//XMas Sweet HMTech-501 Grenade Rifle
    Skins.Add((Id=9202, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MedicRifleGrenadeLauncher', MIC_1P=("WEP_SkinSet52_MAT.sweet_medicgrenadelauncher.Sweet_MedicGrenadeLauncher_1P_Mint_MIC"), MIC_3P="WEP_SkinSet52_MAT.sweet_medicgrenadelauncher.Sweet_MedicGrenadeLauncher_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet52_MAT.sweet_medicgrenadelauncher.Sweet_MedicGrenadeLauncher_3P_Pickup_MIC")) 

//XMas Sweet M32
    Skins.Add((Id=9203, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_M32', MIC_1P=("WEP_SkinSet52_MAT.sweet_m32.Sweet_M32_1P_Mint_MIC", "WEP_SkinSet52_MAT.sweet_m32.Sweet_M32_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet52_MAT.sweet_m32.Sweet_M32_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet52_MAT.sweet_m32.Sweet_M32_3P_Pickup_MIC")) 

//XMas Sweet P90
    Skins.Add((Id=9204, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_P90', MIC_1P=("WEP_SkinSet52_MAT.sweet_p90.Sweet_P90_1P_Mint_MIC", "WEP_SkinSet52_MAT.sweet_p90.Sweet_P90_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet52_MAT.sweet_p90.Sweet_P90_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet52_MAT.sweet_p90.Sweet_P90_3P_Pickup_MIC")) 

//XMas Sweet RPG-7
    Skins.Add((Id=9205, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_RPG7', MIC_1P=("WEP_SkinSet52_MAT.sweet_rpg7.Sweet_RPG7_1P_Mint_MIC"), MIC_3P="WEP_SkinSet52_MAT.sweet_rpg7.Sweet_RPG7_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet52_MAT.sweet_rpg7.Sweet_RPG7_3P_Pickup_MIC")) 

//XMas Sweet Scar
    Skins.Add((Id=9206, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Scar', MIC_1P=("WEP_SkinSet52_MAT.sweet_scar.Sweet_SCAR_1P_Mint_MIC", "WEP_SkinSet52_MAT.sweet_scar.Sweet_SCAR_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet52_MAT.sweet_scar.Sweet_SCAR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet52_MAT.sweet_scar.Sweet_SCAR_3P_Pickup_MIC")) 

//XMas Sweet Spitfire
    Skins.Add((Id=9207, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Flaregun', MIC_1P=("WEP_SkinSet52_MAT.sweet_flaregun.Sweet_FlareGun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet52_MAT.sweet_flaregun.Sweet_FlareGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet52_MAT.sweet_flaregun.Sweet_FlareGun_3P_Pickup_MIC")) 

//XMas Sour Boomstick
    Skins.Add((Id=9208, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_DoubleBarrel', MIC_1P=("WEP_SkinSet52_MAT.sour_doublebarrel.Sour_DoubleBarrel_1P_Mint_MIC"), MIC_3P="WEP_SkinSet52_MAT.sour_doublebarrel.Sour_DoubleBarrel_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet52_MAT.sour_doublebarrel.Sour_DoubleBarrel_3P_Pickup_MIC")) 

//XMas Sour Caulk n Burn
    Skins.Add((Id=9209, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_CaulkBurn', MIC_1P=("WEP_SkinSet52_MAT.sour_caulkburn.Sour_CaulkBurn_1P_Mint_MIC"), MIC_3P="WEP_SkinSet52_MAT.sour_caulkburn.Sour_CaulkBurn_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet52_MAT.sour_caulkburn.Sour_CaulkBurn_3P_Pickup_MIC")) 

//XMas Sour Desert Eagle
    Skins.Add((Id=9210, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet52_MAT.sour_deagle.Sour_Deagle_1P_Mint_MIC"), MIC_3P="WEP_SkinSet52_MAT.sour_deagle.Sour_Deagle_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet52_MAT.sour_deagle.Sour_Deagle_3P_Pickup_MIC")) 

//XMas Sour Flamethrower
    Skins.Add((Id=9211, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_FlameThrower', MIC_1P=("WEP_SkinSet52_MAT.sour_flamethrower.Sour_Flamethrower_1P_Mint_MIC"), MIC_3P="WEP_SkinSet52_MAT.sour_flamethrower.Sour_Flamethrower_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet52_MAT.sour_flamethrower.Sour_Flamethrower_3P_Pickup_MIC")) 

//XMas Sour HMTech-501 Grenade Rifle
    Skins.Add((Id=9212, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MedicRifleGrenadeLauncher', MIC_1P=("WEP_SkinSet52_MAT.sour_medicgrenadelauncher.Sour_MedicGrenadeLauncher_1P_Mint_MIC"), MIC_3P="WEP_SkinSet52_MAT.sour_medicgrenadelauncher.Sour_MedicGrenadeLauncher_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet52_MAT.sour_medicgrenadelauncher.Sour_MedicGrenadeLauncher_3P_Pickup_MIC")) 

//XMas Sour M32
    Skins.Add((Id=9213, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_M32', MIC_1P=("WEP_SkinSet52_MAT.sour_m32.Sour_M32_1P_Mint_MIC", "WEP_SkinSet52_MAT.sour_m32.Sour_M32_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet52_MAT.sour_m32.Sour_M32_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet52_MAT.sour_m32.Sour_M32_3P_Pickup_MIC")) 

//XMas Sour P90
    Skins.Add((Id=9214, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_P90', MIC_1P=("WEP_SkinSet52_MAT.sour_p90.Sour_P90_1P_Mint_MIC", "WEP_SkinSet52_MAT.sour_p90.Sour_P90_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet52_MAT.sour_p90.Sour_P90_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet52_MAT.sour_p90.Sour_P90_3P_Pickup_MIC")) 

//XMas Sour RPG-7
    Skins.Add((Id=9215, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_RPG7', MIC_1P=("WEP_SkinSet52_MAT.sour_rpg7.Sour_RPG7_1P_Mint_MIC"), MIC_3P="WEP_SkinSet52_MAT.sour_rpg7.Sour_RPG7_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet52_MAT.sour_rpg7.Sour_RPG7_3P_Pickup_MIC")) 

//XMas Sour Scar
    Skins.Add((Id=9216, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Scar', MIC_1P=("WEP_SkinSet52_MAT.sour_scar.Sour_SCAR_1P_Mint_MIC", "WEP_SkinSet52_MAT.sour_scar.Sour_SCAR_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet52_MAT.sour_scar.Sour_SCAR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet52_MAT.sour_scar.Sour_SCAR_3P_Pickup_MIC")) 

//XMas Sour Spitfire
    Skins.Add((Id=9217, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Flaregun', MIC_1P=("WEP_SkinSet52_MAT.sour_flaregun.Sour_FlareGun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet52_MAT.sour_flaregun.Sour_FlareGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet52_MAT.sour_flaregun.Sour_FlareGun_3P_Pickup_MIC")) 

//Neon Boomstick
    Skins.Add((Id=9335, Weapondef=class'KFWeapDef_DoubleBarrel', MIC_1P=("wep_skinset56_mat.neon_doublebarrel.Neon_DoubleBarrel_1P_Mint_MIC"), MIC_3P="wep_skinset56_mat.neon_doublebarrel.Neon_DoubleBarrel_3P_Mint_MIC", MIC_Pickup="wep_skinset56_mat.neon_doublebarrel.Neon_DoubleBarrel_3P_Pickup_MIC")) 

//Neon HZ12
    Skins.Add((Id=9336, Weapondef=class'KFWeapDef_HZ12', MIC_1P=("wep_skinset56_mat.neon_hz12.Neon_HZ12_1P_Mint_MIC"), MIC_3P="wep_skinset56_mat.neon_hz12.Neon_HZ12_3P_Mint_MIC", MIC_Pickup="wep_skinset56_mat.neon_hz12.Neon_HZ12_3P_Pickup_MIC")) 

//Neon HRG Beluga Beat
    Skins.Add((Id=9337, Weapondef=class'KFWeapDef_HRG_SonicGun', MIC_1P=("wep_skinset56_mat.neon_hrgsonicgun.Neon_HRGSonicGun_1P_Mint_MIC"), MIC_3P="wep_skinset56_mat.neon_hrgsonicgun.Neon_HRGSonicGun_3P_Mint_MIC", MIC_Pickup="wep_skinset56_mat.neon_hrgsonicgun.Neon_HRGSonicGun_3P_Pickup_MIC")) 

//Neon Zweihander
    Skins.Add((Id=9338, Weapondef=class'KFWeapDef_Zweihander', MIC_1P=("wep_skinset56_mat.neon_zweihander.Neon_Zweihander_1P_Mint_MIC"), MIC_3P="wep_skinset56_mat.neon_zweihander.Neon_Zweihander_3P_Mint_MIC", MIC_Pickup="wep_skinset56_mat.neon_zweihander.Neon_Zweihander_3P_Pickup_MIC")) 

//Neon RGB Boomstick
    Skins.Add((Id=9339, Weapondef=class'KFWeapDef_DoubleBarrel', MIC_1P=("wep_skinset56_mat.neonrgb_doublebarrel.NeonRGB_DoubleBarrel_1P_Mint_MIC"), MIC_3P="wep_skinset56_mat.neonrgb_doublebarrel.NeonRGB_DoubleBarrel_3P_Mint_MIC", MIC_Pickup="wep_skinset56_mat.neonrgb_doublebarrel.NeonRGB_DoubleBarrel_3P_Pickup_MIC")) 

//Neon RGB HZ12
    Skins.Add((Id=9340, Weapondef=class'KFWeapDef_HZ12', MIC_1P=("wep_skinset56_mat.neonrgb_hz12.NeonRGB_HZ12_1P_Mint_MIC"), MIC_3P="wep_skinset56_mat.neonrgb_hz12.NeonRGB_HZ12_3P_Mint_MIC", MIC_Pickup="wep_skinset56_mat.neonrgb_hz12.NeonRGB_HZ12_3P_Pickup_MIC")) 

//Neon RGB HRG Beluga Beat
    Skins.Add((Id=9341, Weapondef=class'KFWeapDef_HRG_SonicGun', MIC_1P=("wep_skinset56_mat.neonrgb_hrgsonicgun.NeonRGB_HRGSonicGun_1P_Mint_MIC"), MIC_3P="wep_skinset56_mat.neonrgb_hrgsonicgun.NeonRGB_HRGSonicGun_3P_Mint_MIC", MIC_Pickup="wep_skinset56_mat.neonrgb_hrgsonicgun.NeonRGB_HRGSonicGun_3P_Pickup_MIC")) 

//Neon RGB Zweihander
    Skins.Add((Id=9342, Weapondef=class'KFWeapDef_Zweihander', MIC_1P=("wep_skinset56_mat.neonrgb_zweihander.NeonRGB_Zweihander_1P_Mint_MIC"), MIC_3P="wep_skinset56_mat.neonrgb_zweihander.NeonRGB_Zweihander_3P_Mint_MIC", MIC_Pickup="wep_skinset56_mat.neonrgb_zweihander.NeonRGB_Zweihander_3P_Pickup_MIC")) 

//Classic Mint 9MM
    Skins.Add((Id=9343, Weapondef=class'KFWeapDef_9mm', MIC_1P=("wep_skinset57_mat.classic_9mm.Classic_9MM_1P_Mint_MIC"), MIC_3P="wep_skinset57_mat.classic_9mm.Classic_9MM_3P_Mint_MIC", MIC_Pickup="wep_skinset57_mat.classic_9mm.Classic_9MM_3P_Pickup_MIC")) 

//Classic Mint AA12
    Skins.Add((Id=9344, Weapondef=class'KFWeapDef_AA12', MIC_1P=("wep_skinset57_mat.classic_aa12.Classic_AA12_1P_Mint_MIC"), MIC_3P="wep_skinset57_mat.classic_aa12.Classic_AA12_3P_Mint_MIC", MIC_Pickup="wep_skinset57_mat.classic_aa12.Classic_AA12_3P_Pickup_MIC")) 

//Classic Mint Boomstick
    Skins.Add((Id=9345, Weapondef=class'KFWeapDef_DoubleBarrel', MIC_1P=("wep_skinset57_mat.classic_doublebarrel.Classic_DoubleBarrel_1P_Mint_MIC"), MIC_3P="wep_skinset57_mat.classic_doublebarrel.Classic_DoubleBarrel_3P_Mint_MIC", MIC_Pickup="wep_skinset57_mat.classic_doublebarrel.Classic_DoubleBarrel_3P_Pickup_MIC")) 

//Classic Mint M1911
    Skins.Add((Id=9346, Weapondef=class'KFWeapDef_Colt1911', MIC_1P=("wep_skinset57_mat.classic_m1911.Classic_M1911_1P_Mint_MIC"), MIC_3P="wep_skinset57_mat.classic_m1911.Classic_M1911_3P_Mint_MIC", MIC_Pickup="wep_skinset57_mat.classic_m1911.Classic_M1911_3P_Pickup_MIC")) 

//Classic Precious 9MM
    Skins.Add((Id=9347, Weapondef=class'KFWeapDef_9mm', MIC_1P=("wep_skinset57_mat.standard_9mm.Standard_9MM_1P_Mint_MIC"), MIC_3P="wep_skinset57_mat.standard_9mm.Standard_9MM_3P_Mint_MIC", MIC_Pickup="wep_skinset57_mat.standard_9mm.Standard_9MM_3P_Pickup_MIC")) 

//Classic Precious AA12
    Skins.Add((Id=9348, Weapondef=class'KFWeapDef_AA12', MIC_1P=("wep_skinset57_mat.standard_aa12.Standard_AA12_1P_Mint_MIC"), MIC_3P="wep_skinset57_mat.standard_aa12.Standard_AA12_3P_Mint_MIC", MIC_Pickup="wep_skinset57_mat.standard_aa12.Standard_AA12_3P_Pickup_MIC")) 

//Classic Precious Boomstick
    Skins.Add((Id=9349, Weapondef=class'KFWeapDef_DoubleBarrel', MIC_1P=("wep_skinset57_mat.standard_doublebarrel.Standard_DoubleBarrel_1P_Mint_MIC"), MIC_3P="wep_skinset57_mat.standard_doublebarrel.Standard_DoubleBarrel_3P_Mint_MIC", MIC_Pickup="wep_skinset57_mat.standard_doublebarrel.Standard_DoubleBarrel_3P_Pickup_MIC")) 

//Classic Precious M1911
    Skins.Add((Id=9350, Weapondef=class'KFWeapDef_Colt1911', MIC_1P=("wep_skinset57_mat.standard_m1911.Standard_M1911_1P_Mint_MIC"), MIC_3P="wep_skinset57_mat.standard_m1911.Standard_M1911_3P_Mint_MIC", MIC_Pickup="wep_skinset57_mat.standard_m1911.Standard_M1911_3P_Pickup_MIC")) 

//Chameleon Dynamic Desert Eagle
    Skins.Add((Id=9351, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("wep_skinset58_mat.chameleon_deagle.Chameleon_Deagle_1P_Mint_MIC"), MIC_3P="WEP_SkinSet58_MAT.chameleon_deagle.Chameleon_Deagle_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet58_MAT.chameleon_deagle.Chameleon_Deagle_3P_Pickup_MIC")) 

//Chameleon Dynamic Katana
    Skins.Add((Id=9352, Weapondef=class'KFWeapDef_Katana', MIC_1P=("wep_skinset58_mat.chameleon_katana.Chameleon_Katana_1P_Mint_MIC"), MIC_3P="WEP_SkinSet58_MAT.chameleon_katana.Chameleon_Katana_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet58_MAT.chameleon_katana.Chameleon_Katana_3P_Pickup_MIC")) 

//Chameleon Dynamic Kriss SMG
    Skins.Add((Id=9353, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Kriss', MIC_1P=("wep_skinset58_mat.chameleon_kriss.Chameleon_Kriss_1P_Mint_MIC", "wep_skinset58_mat.chameleon_kriss.Chameleon_Kriss_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet58_MAT.chameleon_kriss.Chameleon_Kriss_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet58_MAT.chameleon_kriss.Chameleon_Kriss_3P_Pickup_MIC")) 

//Chameleon Dynamic RPG-7
    Skins.Add((Id=9354, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_RPG7', MIC_1P=("wep_skinset58_mat.chameleon_rpg7.Chameleon_RPG7_1P_Mint_MIC"), MIC_3P="WEP_SkinSet58_MAT.chameleon_rpg7.Chameleon_RPG7_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet58_MAT.chameleon_rpg7.Chameleon_RPG7_3P_Pickup_MIC")) 

//Chameleon Dynamic RGB Desert Eagle
    Skins.Add((Id=9355, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("wep_skinset58_mat.chameleonrgb_deagle.ChameleonRGB_Deagle_1P_Mint_MIC"), MIC_3P="WEP_SkinSet58_MAT.chameleonrgb_deagle.ChameleonRGB_Deagle_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet58_MAT.chameleonrgb_deagle.ChameleonRGB_Deagle_3P_Pickup_MIC")) 

//Chameleon Dynamic RGB Katana
    Skins.Add((Id=9356, Weapondef=class'KFWeapDef_Katana', MIC_1P=("wep_skinset58_mat.chameleonrgb_katana.ChameleonRGB_Katana_1P_Mint_MIC"), MIC_3P="WEP_SkinSet58_MAT.chameleonrgb_katana.ChameleonRGB_Katana_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet58_MAT.chameleonrgb_katana.ChameleonRGB_Katana_3P_Pickup_MIC")) 

//Chameleon Dynamic RGB Kriss SMG
    Skins.Add((Id=9357, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Kriss', MIC_1P=("wep_skinset58_mat.chameleonrgb_kriss.ChameleonRGB_Kriss_1P_Mint_MIC", "wep_skinset58_mat.chameleonrgb_kriss.ChameleonRGB_Kriss_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet58_MAT.chameleonrgb_kriss.ChameleonRGB_Kriss_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet58_MAT.chameleonrgb_kriss.ChameleonRGB_Kriss_3P_Pickup_MIC")) 

//Chameleon Dynamic RGB RPG-7
    Skins.Add((Id=9358, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_RPG7', MIC_1P=("wep_skinset58_mat.chameleonrgb_rpg7.ChameleonRGB_RPG7_1P_Mint_MIC"), MIC_3P="WEP_SkinSet58_MAT.chameleonrgb_rpg7.ChameleonRGB_RPG7_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet58_MAT.chameleonrgb_rpg7.ChameleonRGB_RPG7_3P_Pickup_MIC")) 

//Deep Sea Antique AA12
    Skins.Add((Id=9298, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet59_MAT.deepsea_aa12.DeepSea_AA12_1P_Mint_MIC"), MIC_3P="WEP_SkinSet59_MAT.deepsea_aa12.DeepSea_AA12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet59_MAT.deepsea_aa12.DeepSea_AA12_3P_Pickup_MIC")) 

//Deep Sea Aqua AA12
    Skins.Add((Id=9299, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet59_MAT.deepsea_aa12.DeepSeaAqua_AA12_1P_Mint_MIC"), MIC_3P="WEP_SkinSet59_MAT.deepsea_aa12.DeepSeaAqua_AA12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet59_MAT.deepsea_aa12.DeepSeaAqua_AA12_3P_Pickup_MIC")) 

//Deep Sea Coral AA12
    Skins.Add((Id=9300, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet59_MAT.deepsea_aa12.DeepSeaCoral_AA12_1P_Mint_MIC"), MIC_3P="WEP_SkinSet59_MAT.deepsea_aa12.DeepSeaCoral_AA12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet59_MAT.deepsea_aa12.DeepSeaCoral_AA12_3P_Pickup_MIC")) 

//Deep Sea Pearl AA12
    Skins.Add((Id=9301, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet59_MAT.deepsea_aa12.DeepSeaPearl_AA12_1P_Mint_MIC"), MIC_3P="WEP_SkinSet59_MAT.deepsea_aa12.DeepSeaPearl_AA12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet59_MAT.deepsea_aa12.DeepSeaPearl_AA12_3P_Pickup_MIC")) 

//Deep Sea Black Seal AA12
    Skins.Add((Id=9302, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet59_MAT.deepsea_aa12.DeepSeaBlackSeal_AA12_1P_Mint_MIC"), MIC_3P="WEP_SkinSet59_MAT.deepsea_aa12.DeepSeaBlackSeal_AA12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet59_MAT.deepsea_aa12.DeepSeaBlackSeal_AA12_3P_Pickup_MIC")) 

//Deep Sea Precious AA12
    Skins.Add((Id=9303, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet59_MAT.deepsea_aa12.DeepSeaPrecious_AA12_1P_Mint_MIC"), MIC_3P="WEP_SkinSet59_MAT.deepsea_aa12.DeepSeaPrecious_AA12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet59_MAT.deepsea_aa12.DeepSeaPrecious_AA12_3P_Pickup_MIC")) 

//Deep Sea Antique FN FAL
    Skins.Add((Id=9304, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_FNFAL', MIC_1P=("WEP_SkinSet59_MAT.deepsea_fnfal.DeepSea_FNFAL_1P_Mint_MIC", "WEP_SkinSet59_MAT.deepsea_fnfal.DeepSea_FNFAL_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet59_MAT.deepsea_fnfal.DeepSea_FNFAL_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet59_MAT.deepsea_fnfal.DeepSea_FNFAL_3P_Pickup_MIC")) 

//Deep Sea Aqua FN FAL
    Skins.Add((Id=9305, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_FNFAL', MIC_1P=("WEP_SkinSet59_MAT.deepsea_fnfal.DeepSeaAqua_FNFAL_1P_Mint_MIC", "WEP_SkinSet59_MAT.deepsea_fnfal.DeepSeaAqua_FNFAL_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet59_MAT.deepsea_fnfal.DeepSeaAqua_FNFAL_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet59_MAT.deepsea_fnfal.DeepSeaAqua_FNFAL_3P_Pickup_MIC")) 

//Deep Sea Coral FN FAL
    Skins.Add((Id=9306, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_FNFAL', MIC_1P=("WEP_SkinSet59_MAT.deepsea_fnfal.DeepSeaCoral_FNFAL_1P_Mint_MIC", "WEP_SkinSet59_MAT.deepsea_fnfal.DeepSeaCoral_FNFAL_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet59_MAT.deepsea_fnfal.DeepSeaCoral_FNFAL_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet59_MAT.deepsea_fnfal.DeepSeaCoral_FNFAL_3P_Pickup_MIC")) 

//Deep Sea Pearl FN FAL
    Skins.Add((Id=9307, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_FNFAL', MIC_1P=("WEP_SkinSet59_MAT.deepsea_fnfal.DeepSeaPearl_FNFAL_1P_Mint_MIC", "WEP_SkinSet59_MAT.deepsea_fnfal.DeepSeaPearl_FNFAL_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet59_MAT.deepsea_fnfal.DeepSeaPearl_FNFAL_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet59_MAT.deepsea_fnfal.DeepSeaPearl_FNFAL_3P_Pickup_MIC")) 

//Deep Sea Black Seal FN FAL
    Skins.Add((Id=9308, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_FNFAL', MIC_1P=("WEP_SkinSet59_MAT.deepsea_fnfal.DeepSeaBlackSeal_FNFAL_1P_Mint_MIC", "WEP_SkinSet59_MAT.deepsea_fnfal.DeepSeaBlackSeal_FNFAL_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet59_MAT.deepsea_fnfal.DeepSeaBlackSeal_FNFAL_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet59_MAT.deepsea_fnfal.DeepSeaBlackSeal_FNFAL_3P_Pickup_MIC")) 

//Deep Sea Precious FN FAL
    Skins.Add((Id=9309, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_FNFAL', MIC_1P=("WEP_SkinSet59_MAT.deepsea_fnfal.DeepSeaPrecious_FNFAL_1P_Mint_MIC", "WEP_SkinSet59_MAT.deepsea_fnfal.DeepSeaPrecious_FNFAL_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet59_MAT.deepsea_fnfal.DeepSeaPrecious_FNFAL_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet59_MAT.deepsea_fnfal.DeepSeaPrecious_FNFAL_3P_Pickup_MIC")) 

//Deep Sea Antique M14EBR
    Skins.Add((Id=9310, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_M14EBR', MIC_1P=("WEP_SkinSet59_MAT.deepsea_m14ebr.DeepSea_M14EBR_1P_Mint_MIC", "WEP_SkinSet59_MAT.deepsea_m14ebr.DeepSea_M14EBR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet59_MAT.deepsea_m14ebr.DeepSea_M14EBR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet59_MAT.deepsea_m14ebr.DeepSea_M14EBR_3P_Pickup_MIC")) 

//Deep Sea Aqua M14EBR
    Skins.Add((Id=9311, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_M14EBR', MIC_1P=("WEP_SkinSet59_MAT.deepsea_m14ebr.DeepSeaAqua_M14EBR_1P_Mint_MIC", "WEP_SkinSet59_MAT.deepsea_m14ebr.DeepSeaAqua_M14EBR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet59_MAT.deepsea_m14ebr.DeepSeaAqua_M14EBR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet59_MAT.deepsea_m14ebr.DeepSeaAqua_M14EBR_3P_Pickup_MIC")) 

//Deep Sea Coral M14EBR
    Skins.Add((Id=9312, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_M14EBR', MIC_1P=("WEP_SkinSet59_MAT.deepsea_m14ebr.DeepSeaCoral_M14EBR_1P_Mint_MIC", "WEP_SkinSet59_MAT.deepsea_m14ebr.DeepSeaCoral_M14EBR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet59_MAT.deepsea_m14ebr.DeepSeaCoral_M14EBR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet59_MAT.deepsea_m14ebr.DeepSeaCoral_M14EBR_3P_Pickup_MIC")) 

//Deep Sea Pearl M14EBR
    Skins.Add((Id=9313, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_M14EBR', MIC_1P=("WEP_SkinSet59_MAT.deepsea_m14ebr.DeepSeaPearl_M14EBR_1P_Mint_MIC", "WEP_SkinSet59_MAT.deepsea_m14ebr.DeepSeaPearl_M14EBR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet59_MAT.deepsea_m14ebr.DeepSeaPearl_M14EBR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet59_MAT.deepsea_m14ebr.DeepSeaPearl_M14EBR_3P_Pickup_MIC")) 

//Deep Sea Black Seal M14EBR
    Skins.Add((Id=9314, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_M14EBR', MIC_1P=("WEP_SkinSet59_MAT.deepsea_m14ebr.DeepSeaBlackSeal_M14EBR_1P_Mint_MIC", "WEP_SkinSet59_MAT.deepsea_m14ebr.DeepSeaBlackSeal_M14EBR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet59_MAT.deepsea_m14ebr.DeepSeaBlackSeal_M14EBR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet59_MAT.deepsea_m14ebr.DeepSeaBlackSeal_M14EBR_3P_Pickup_MIC")) 

//Deep Sea Precious M14EBR
    Skins.Add((Id=9315, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_M14EBR', MIC_1P=("WEP_SkinSet59_MAT.deepsea_m14ebr.DeepSeaPrecious_M14EBR_1P_Mint_MIC", "WEP_SkinSet59_MAT.deepsea_m14ebr.DeepSeaPrecious_M14EBR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet59_MAT.deepsea_m14ebr.DeepSeaPrecious_M14EBR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet59_MAT.deepsea_m14ebr.DeepSeaPrecious_M14EBR_3P_Pickup_MIC")) 

//Deep Sea Antique MAC 10
    Skins.Add((Id=9316, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Mac10', MIC_1P=("WEP_SkinSet59_MAT.deepsea_mac10.DeepSea_MAC10_1P_Mint_MIC"), MIC_3P="WEP_SkinSet59_MAT.deepsea_mac10.DeepSea_MAC10_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet59_MAT.deepsea_mac10.DeepSea_MAC10_3P_Pickup_MIC")) 

//Deep Sea Aqua MAC 10
    Skins.Add((Id=9317, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Mac10', MIC_1P=("WEP_SkinSet59_MAT.deepsea_mac10.DeepSeaAqua_MAC10_1P_Mint_MIC"), MIC_3P="WEP_SkinSet59_MAT.deepsea_mac10.DeepSeaAqua_MAC10_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet59_MAT.deepsea_mac10.DeepSeaAqua_MAC10_3P_Pickup_MIC")) 

//Deep Sea Coral MAC 10
    Skins.Add((Id=9318, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Mac10', MIC_1P=("WEP_SkinSet59_MAT.deepsea_mac10.DeepSeaCoral_MAC10_1P_Mint_MIC"), MIC_3P="WEP_SkinSet59_MAT.deepsea_mac10.DeepSeaCoral_MAC10_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet59_MAT.deepsea_mac10.DeepSeaCoral_MAC10_3P_Pickup_MIC")) 

//Deep Sea Pearl MAC 10
    Skins.Add((Id=9319, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Mac10', MIC_1P=("WEP_SkinSet59_MAT.deepsea_mac10.DeepSeaPearl_MAC10_1P_Mint_MIC"), MIC_3P="WEP_SkinSet59_MAT.deepsea_mac10.DeepSeaPearl_MAC10_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet59_MAT.deepsea_mac10.DeepSeaPearl_MAC10_3P_Pickup_MIC")) 

//Deep Sea Black Seal MAC 10
    Skins.Add((Id=9320, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Mac10', MIC_1P=("WEP_SkinSet59_MAT.deepsea_mac10.DeepSeaBlackSeal_MAC10_1P_Mint_MIC"), MIC_3P="WEP_SkinSet59_MAT.deepsea_mac10.DeepSeaBlackSeal_MAC10_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet59_MAT.deepsea_mac10.DeepSeaBlackSeal_MAC10_3P_Pickup_MIC")) 

//Deep Sea Precious MAC 10
    Skins.Add((Id=9321, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Mac10', MIC_1P=("WEP_SkinSet59_MAT.deepsea_mac10.DeepSeaPrecious_MAC10_1P_Mint_MIC"), MIC_3P="WEP_SkinSet59_MAT.deepsea_mac10.DeepSeaPrecious_MAC10_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet59_MAT.deepsea_mac10.DeepSeaPrecious_MAC10_3P_Pickup_MIC")) 

//Deep Sea Antique MP5RAS
    Skins.Add((Id=9322, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MP5RAS', MIC_1P=("WEP_SkinSet59_MAT.deepsea_mp5ras.DeepSea_MP5RAS_1P_Mint_MIC"), MIC_3P="WEP_SkinSet59_MAT.deepsea_mp5ras.DeepSea_MP5RAS_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet59_MAT.deepsea_mp5ras.DeepSea_MP5RAS_3P_Pickup_MIC")) 

//Deep Sea Aqua MP5RAS
    Skins.Add((Id=9323, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MP5RAS', MIC_1P=("WEP_SkinSet59_MAT.deepsea_mp5ras.DeepSeaAqua_MP5RAS_1P_Mint_MIC"), MIC_3P="WEP_SkinSet59_MAT.deepsea_mp5ras.DeepSeaAqua_MP5RAS_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet59_MAT.deepsea_mp5ras.DeepSeaAqua_MP5RAS_3P_Pickup_MIC")) 

//Deep Sea Coral MP5RAS
    Skins.Add((Id=9324, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MP5RAS', MIC_1P=("WEP_SkinSet59_MAT.deepsea_mp5ras.DeepSeaCoral_MP5RAS_1P_Mint_MIC"), MIC_3P="WEP_SkinSet59_MAT.deepsea_mp5ras.DeepSeaCoral_MP5RAS_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet59_MAT.deepsea_mp5ras.DeepSeaCoral_MP5RAS_3P_Pickup_MIC")) 

//Deep Sea Pearl MP5RAS
    Skins.Add((Id=9325, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MP5RAS', MIC_1P=("WEP_SkinSet59_MAT.deepsea_mp5ras.DeepSeaPearl_MP5RAS_1P_Mint_MIC"), MIC_3P="WEP_SkinSet59_MAT.deepsea_mp5ras.DeepSeaPearl_MP5RAS_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet59_MAT.deepsea_mp5ras.DeepSeaPearl_MP5RAS_3P_Pickup_MIC")) 

//Deep Sea Black Seal MP5RAS
    Skins.Add((Id=9326, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MP5RAS', MIC_1P=("WEP_SkinSet59_MAT.deepsea_mp5ras.DeepSeaBlackSeal_MP5RAS_1P_Mint_MIC"), MIC_3P="WEP_SkinSet59_MAT.deepsea_mp5ras.DeepSeaBlackSeal_MP5RAS_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet59_MAT.deepsea_mp5ras.DeepSeaBlackSeal_MP5RAS_3P_Pickup_MIC")) 

//Deep Sea Precious MP5RAS
    Skins.Add((Id=9327, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MP5RAS', MIC_1P=("WEP_SkinSet59_MAT.deepsea_mp5ras.DeepSeaPrecious_MP5RAS_1P_Mint_MIC"), MIC_3P="WEP_SkinSet59_MAT.deepsea_mp5ras.DeepSeaPrecious_MP5RAS_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet59_MAT.deepsea_mp5ras.DeepSeaPrecious_MP5RAS_3P_Pickup_MIC")) 

//Deep Sea Antique RPG-7
    Skins.Add((Id=9328, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_RPG7', MIC_1P=("WEP_SkinSet59_MAT.deepsea_rpg7.DeepSea_RPG7_1P_Mint_MIC"), MIC_3P="WEP_SkinSet59_MAT.deepsea_rpg7.DeepSea_RPG7_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet59_MAT.deepsea_rpg7.DeepSea_RPG7_3P_Pickup_MIC")) 

//Deep Sea Aqua RPG-7
    Skins.Add((Id=9329, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_RPG7', MIC_1P=("WEP_SkinSet59_MAT.deepsea_rpg7.DeepSeaAqua_RPG7_1P_Mint_MIC"), MIC_3P="WEP_SkinSet59_MAT.deepsea_rpg7.DeepSeaAqua_RPG7_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet59_MAT.deepsea_rpg7.DeepSeaAqua_RPG7_3P_Pickup_MIC")) 

//Deep Sea Coral RPG-7
    Skins.Add((Id=9330, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_RPG7', MIC_1P=("WEP_SkinSet59_MAT.deepsea_rpg7.DeepSeaCoral_RPG7_1P_Mint_MIC"), MIC_3P="WEP_SkinSet59_MAT.deepsea_rpg7.DeepSeaCoral_RPG7_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet59_MAT.deepsea_rpg7.DeepSeaCoral_RPG7_3P_Pickup_MIC")) 

//Deep Sea Pearl RPG-7
    Skins.Add((Id=9331, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_RPG7', MIC_1P=("WEP_SkinSet59_MAT.deepsea_rpg7.DeepSeaPearl_RPG7_1P_Mint_MIC"), MIC_3P="WEP_SkinSet59_MAT.deepsea_rpg7.DeepSeaPearl_RPG7_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet59_MAT.deepsea_rpg7.DeepSeaPearl_RPG7_3P_Pickup_MIC")) 

//Deep Sea Black Seal RPG-7
    Skins.Add((Id=9332, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_RPG7', MIC_1P=("WEP_SkinSet59_MAT.deepsea_rpg7.DeepSeaBlackSeal_RPG7_1P_Mint_MIC"), MIC_3P="WEP_SkinSet59_MAT.deepsea_rpg7.DeepSeaBlackSeal_RPG7_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet59_MAT.deepsea_rpg7.DeepSeaBlackSeal_RPG7_3P_Pickup_MIC")) 

//Deep Sea Precious RPG-7
    Skins.Add((Id=9333, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_RPG7', MIC_1P=("WEP_SkinSet59_MAT.deepsea_rpg7.DeepSeaPrecious_RPG7_1P_Mint_MIC"), MIC_3P="WEP_SkinSet59_MAT.deepsea_rpg7.DeepSeaPrecious_RPG7_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet59_MAT.deepsea_rpg7.DeepSeaPrecious_RPG7_3P_Pickup_MIC")) 

//Plague Doctor Mint Tommy Gun
    Skins.Add((Id=9388, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Thompson', MIC_1P=("WEP_SkinSet62_MAT.plague_tommygun.Plague_TommyGun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet62_MAT.plague_tommygun.Plague_TommyGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet62_MAT.plague_tommygun.Plague_TommyGun_3P_Pickup_MIC")) 

//Plague Doctor Sterling Tommy Gun
    Skins.Add((Id=9389, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Thompson', MIC_1P=("WEP_SkinSet62_MAT.plague_tommygun.PlagueSterling_TommyGun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet62_MAT.plague_tommygun.PlagueSterling_TommyGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet62_MAT.plague_tommygun.PlagueSterling_TommyGun_3P_Pickup_MIC")) 

//Plague Doctor Obsidian Tommy Gun
    Skins.Add((Id=9390, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Thompson', MIC_1P=("WEP_SkinSet62_MAT.plague_tommygun.PlagueObsidian_TommyGun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet62_MAT.plague_tommygun.PlagueObsidian_TommyGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet62_MAT.plague_tommygun.PlagueObsidian_TommyGun_3P_Pickup_MIC")) 

//Plague Doctor Volcanic Tommy Gun
    Skins.Add((Id=9391, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Thompson', MIC_1P=("WEP_SkinSet62_MAT.plague_tommygun.PlagueVolcanic_TommyGun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet62_MAT.plague_tommygun.PlagueVolcanic_TommyGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet62_MAT.plague_tommygun.PlagueVolcanic_TommyGun_3P_Pickup_MIC")) 

//Plague Doctor Emerald Tommy Gun
    Skins.Add((Id=9392, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Thompson', MIC_1P=("WEP_SkinSet62_MAT.plague_tommygun.PlagueEmerald_TommyGun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet62_MAT.plague_tommygun.PlagueEmerald_TommyGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet62_MAT.plague_tommygun.PlagueEmerald_TommyGun_3P_Pickup_MIC")) 

//Plague Doctor Precious Tommy Gun
    Skins.Add((Id=9393, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Thompson', MIC_1P=("WEP_SkinSet62_MAT.plague_tommygun.PlaguePrecious_TommyGun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet62_MAT.plague_tommygun.PlaguePrecious_TommyGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet62_MAT.plague_tommygun.PlaguePrecious_TommyGun_3P_Pickup_MIC")) 

//Plague Doctor Mint M79
    Skins.Add((Id=9394, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_M79', MIC_1P=("WEP_SkinSet62_MAT.plague_m79.Plague_M79_1P_Mint_MIC"), MIC_3P="WEP_SkinSet62_MAT.plague_m79.Plague_M79_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet62_MAT.plague_m79.Plague_M79_3P_Pickup_MIC")) 

//Plague Doctor Sterling M79
    Skins.Add((Id=9395, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_M79', MIC_1P=("WEP_SkinSet62_MAT.plague_m79.PlagueSterling_M79_1P_Mint_MIC"), MIC_3P="WEP_SkinSet62_MAT.plague_m79.PlagueSterling_M79_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet62_MAT.plague_m79.PlagueSterling_M79_3P_Pickup_MIC")) 

//Plague Doctor Obsidian M79
    Skins.Add((Id=9396, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_M79', MIC_1P=("WEP_SkinSet62_MAT.plague_m79.PlagueObsidian_M79_1P_Mint_MIC"), MIC_3P="WEP_SkinSet62_MAT.plague_m79.PlagueObsidian_M79_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet62_MAT.plague_m79.PlagueObsidian_M79_3P_Pickup_MIC")) 

//Plague Doctor Volcanic M79
    Skins.Add((Id=9397, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_M79', MIC_1P=("WEP_SkinSet62_MAT.plague_m79.PlagueVolcanic_M79_1P_Mint_MIC"), MIC_3P="WEP_SkinSet62_MAT.plague_m79.PlagueVolcanic_M79_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet62_MAT.plague_m79.PlagueVolcanic_M79_3P_Pickup_MIC")) 

//Plague Doctor Emerald M79
    Skins.Add((Id=9398, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_M79', MIC_1P=("WEP_SkinSet62_MAT.plague_m79.PlagueEmerald_M79_1P_Mint_MIC"), MIC_3P="WEP_SkinSet62_MAT.plague_m79.PlagueEmerald_M79_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet62_MAT.plague_m79.PlagueEmerald_M79_3P_Pickup_MIC")) 

//Plague Doctor Precious M79
    Skins.Add((Id=9399, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_M79', MIC_1P=("WEP_SkinSet62_MAT.plague_m79.PlaguePrecious_M79_1P_Mint_MIC"), MIC_3P="WEP_SkinSet62_MAT.plague_m79.PlaguePrecious_M79_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet62_MAT.plague_m79.PlaguePrecious_M79_3P_Pickup_MIC")) 

//Plague Doctor Mint Desert Eagle
    Skins.Add((Id=9400, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet62_MAT.plague_deagle.Plague_Deagle_1P_Mint_MIC"), MIC_3P="WEP_SkinSet62_MAT.plague_deagle.Plague_Deagle_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet62_MAT.plague_deagle.Plague_Deagle_3P_Pickup_MIC")) 

//Plague Doctor Sterling Desert Eagle
    Skins.Add((Id=9401, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet62_MAT.plague_deagle.PlagueSterling_Deagle_1P_Mint_MIC"), MIC_3P="WEP_SkinSet62_MAT.plague_deagle.PlagueSterling_Deagle_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet62_MAT.plague_deagle.PlagueSterling_Deagle_3P_Pickup_MIC")) 

//Plague Doctor Obsidian Desert Eagle
    Skins.Add((Id=9402, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet62_MAT.plague_deagle.PlagueObsidian_Deagle_1P_Mint_MIC"), MIC_3P="WEP_SkinSet62_MAT.plague_deagle.PlagueObsidian_Deagle_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet62_MAT.plague_deagle.PlagueObsidian_Deagle_3P_Pickup_MIC")) 

//Plague Doctor Volcanic Desert Eagle
    Skins.Add((Id=9403, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet62_MAT.plague_deagle.PlagueVolcanic_Deagle_1P_Mint_MIC"), MIC_3P="WEP_SkinSet62_MAT.plague_deagle.PlagueVolcanic_Deagle_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet62_MAT.plague_deagle.PlagueVolcanic_Deagle_3P_Pickup_MIC")) 

//Plague Doctor Emerald Desert Eagle
    Skins.Add((Id=9404, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet62_MAT.plague_deagle.PlagueEmerald_Deagle_1P_Mint_MIC"), MIC_3P="WEP_SkinSet62_MAT.plague_deagle.PlagueEmerald_Deagle_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet62_MAT.plague_deagle.PlagueEmerald_Deagle_3P_Pickup_MIC")) 

//Plague Doctor Precious Desert Eagle
    Skins.Add((Id=9405, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet62_MAT.plague_deagle.PlaguePrecious_Deagle_1P_Mint_MIC"), MIC_3P="WEP_SkinSet62_MAT.plague_deagle.PlaguePrecious_Deagle_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet62_MAT.plague_deagle.PlaguePrecious_Deagle_3P_Pickup_MIC")) 

//Plague Doctor Mint Crossbow
    Skins.Add((Id=9406, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Crossbow', MIC_1P=("WEP_SkinSet62_MAT.plague_crossbow.Plague_Crossbow_1P_Mint_MIC", "WEP_SkinSet62_MAT.plague_crossbow.Plague_Crossbow_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet62_MAT.plague_crossbow.Plague_Crossbow_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet62_MAT.plague_crossbow.Plague_Crossbow_3P_Pickup_MIC")) 

//Plague Doctor Sterling Crossbow
    Skins.Add((Id=9407, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Crossbow', MIC_1P=("WEP_SkinSet62_MAT.plague_crossbow.PlagueSterling_Crossbow_1P_Mint_MIC", "WEP_SkinSet62_MAT.plague_crossbow.PlagueSterling_Crossbow_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet62_MAT.plague_crossbow.PlagueSterling_Crossbow_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet62_MAT.plague_crossbow.PlagueSterling_Crossbow_3P_Pickup_MIC")) 

//Plague Doctor Obsidian Crossbow
    Skins.Add((Id=9408, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Crossbow', MIC_1P=("WEP_SkinSet62_MAT.plague_crossbow.PlagueObsidian_Crossbow_1P_Mint_MIC", "WEP_SkinSet62_MAT.plague_crossbow.PlagueObsidian_Crossbow_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet62_MAT.plague_crossbow.PlagueObsidian_Crossbow_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet62_MAT.plague_crossbow.PlagueObsidian_Crossbow_3P_Pickup_MIC")) 

//Plague Doctor Volcanic Crossbow
    Skins.Add((Id=9409, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Crossbow', MIC_1P=("WEP_SkinSet62_MAT.plague_crossbow.PlagueVolcanic_Crossbow_1P_Mint_MIC", "WEP_SkinSet62_MAT.plague_crossbow.PlagueVolcanic_Crossbow_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet62_MAT.plague_crossbow.PlagueVolcanic_Crossbow_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet62_MAT.plague_crossbow.PlagueVolcanic_Crossbow_3P_Pickup_MIC")) 

//Plague Doctor Emerald Crossbow
    Skins.Add((Id=9410, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Crossbow', MIC_1P=("WEP_SkinSet62_MAT.plague_crossbow.PlagueEmerald_Crossbow_1P_Mint_MIC", "WEP_SkinSet62_MAT.plague_crossbow.PlagueEmerald_Crossbow_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet62_MAT.plague_crossbow.PlagueEmerald_Crossbow_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet62_MAT.plague_crossbow.PlagueEmerald_Crossbow_3P_Pickup_MIC")) 

//Plague Doctor Precious Crossbow
    Skins.Add((Id=9411, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Crossbow', MIC_1P=("WEP_SkinSet62_MAT.plague_crossbow.PlaguePrecious_Crossbow_1P_Mint_MIC", "WEP_SkinSet62_MAT.plague_crossbow.PlaguePrecious_Crossbow_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet62_MAT.plague_crossbow.PlaguePrecious_Crossbow_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet62_MAT.plague_crossbow.PlaguePrecious_Crossbow_3P_Pickup_MIC")) 

//Plague Doctor Mint Doomstick
    Skins.Add((Id=9412, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_ElephantGun', MIC_1P=("WEP_SkinSet62_MAT.plague_quadbarrel.Plague_QuadBarrel_Main_1P_Mint_MIC", "WEP_SkinSet62_MAT.plague_quadbarrel.Plague_QuadBarrel_Barrel_1P_Mint_MIC"), MIC_3P="WEP_SkinSet62_MAT.plague_quadbarrel.Plague_QuadBarrel_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet62_MAT.plague_quadbarrel.Plague_QuadBarrel_3P_Pickup_MIC")) 

//Plague Doctor Sterling Doomstick
    Skins.Add((Id=9413, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_ElephantGun', MIC_1P=("WEP_SkinSet62_MAT.plague_quadbarrel.PlagueSterling_QuadBarrel_Main_1P_Mint_MIC", "WEP_SkinSet62_MAT.plague_quadbarrel.PlagueSterling_QuadBarrel_Barrel_1P_Mint_MIC"), MIC_3P="WEP_SkinSet62_MAT.plague_quadbarrel.PlagueSterling_QuadBarrel_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet62_MAT.plague_quadbarrel.PlagueSterling_QuadBarrel_3P_Pickup_MIC")) 

//Plague Doctor Obsidian Doomstick
    Skins.Add((Id=9414, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_ElephantGun', MIC_1P=("WEP_SkinSet62_MAT.plague_quadbarrel.PlagueObsidian_QuadBarrel_Main_1P_Mint_MIC", "WEP_SkinSet62_MAT.plague_quadbarrel.PlagueObsidian_QuadBarrel_Barrel_1P_Mint_MIC"), MIC_3P="WEP_SkinSet62_MAT.plague_quadbarrel.PlagueObsidian_QuadBarrel_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet62_MAT.plague_quadbarrel.PlagueObsidian_QuadBarrel_3P_Pickup_MIC")) 

//Plague Doctor Volcanic Doomstick
    Skins.Add((Id=9415, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_ElephantGun', MIC_1P=("WEP_SkinSet62_MAT.plague_quadbarrel.PlagueVolcanic_QuadBarrel_Main_1P_Mint_MIC", "WEP_SkinSet62_MAT.plague_quadbarrel.PlagueVolcanic_QuadBarrel_Barrel_1P_Mint_MIC"), MIC_3P="WEP_SkinSet62_MAT.plague_quadbarrel.PlagueVolcanic_QuadBarrel_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet62_MAT.plague_quadbarrel.PlagueVolcanic_QuadBarrel_3P_Pickup_MIC")) 

//Plague Doctor Emerald Doomstick
    Skins.Add((Id=9416, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_ElephantGun', MIC_1P=("WEP_SkinSet62_MAT.plague_quadbarrel.PlagueEmerald_QuadBarrel_Main_1P_Mint_MIC", "WEP_SkinSet62_MAT.plague_quadbarrel.PlagueEmerald_QuadBarrel_Barrel_1P_Mint_MIC"), MIC_3P="WEP_SkinSet62_MAT.plague_quadbarrel.PlagueEmerald_QuadBarrel_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet62_MAT.plague_quadbarrel.PlagueEmerald_QuadBarrel_3P_Pickup_MIC")) 

//Plague Doctor Precious Doomstick
    Skins.Add((Id=9417, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_ElephantGun', MIC_1P=("WEP_SkinSet62_MAT.plague_quadbarrel.PlaguePrecious_QuadBarrel_Main_1P_Mint_MIC", "WEP_SkinSet62_MAT.plague_quadbarrel.PlaguePrecious_QuadBarrel_Barrel_1P_Mint_MIC"), MIC_3P="WEP_SkinSet62_MAT.plague_quadbarrel.PlaguePrecious_QuadBarrel_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet62_MAT.plague_quadbarrel.PlaguePrecious_QuadBarrel_3P_Pickup_MIC")) 

//Plague Doctor Mint Dragonsbreath
    Skins.Add((Id=9418, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Dragonsbreath', MIC_1P=("WEP_SkinSet62_MAT.plague_dragonsbreath.Plague_Dragonsbreath_1P_Mint_MIC"), MIC_3P="WEP_SkinSet62_MAT.plague_dragonsbreath.Plague_Dragonsbreath_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet62_MAT.plague_dragonsbreath.Plague_Dragonsbreath_3P_Pickup_MIC")) 

//Plague Doctor Sterling Dragonsbreath
    Skins.Add((Id=9419, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Dragonsbreath', MIC_1P=("WEP_SkinSet62_MAT.plague_dragonsbreath.PlagueSterling_Dragonsbreath_1P_Mint_MIC"), MIC_3P="WEP_SkinSet62_MAT.plague_dragonsbreath.PlagueSterling_Dragonsbreath_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet62_MAT.plague_dragonsbreath.PlagueSterling_Dragonsbreath_3P_Pickup_MIC")) 

//Plague Doctor Obsidian Dragonsbreath
    Skins.Add((Id=9420, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Dragonsbreath', MIC_1P=("WEP_SkinSet62_MAT.plague_dragonsbreath.PlagueObsidian_Dragonsbreath_1P_Mint_MIC"), MIC_3P="WEP_SkinSet62_MAT.plague_dragonsbreath.PlagueObsidian_Dragonsbreath_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet62_MAT.plague_dragonsbreath.PlagueObsidian_Dragonsbreath_3P_Pickup_MIC")) 

//Plague Doctor Volcanic Dragonsbreath
    Skins.Add((Id=9421, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Dragonsbreath', MIC_1P=("WEP_SkinSet62_MAT.plague_dragonsbreath.PlagueVolcanic_Dragonsbreath_1P_Mint_MIC"), MIC_3P="WEP_SkinSet62_MAT.plague_dragonsbreath.PlagueVolcanic_Dragonsbreath_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet62_MAT.plague_dragonsbreath.PlagueVolcanic_Dragonsbreath_3P_Pickup_MIC")) 

//Plague Doctor Emerald Dragonsbreath
    Skins.Add((Id=9422, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Dragonsbreath', MIC_1P=("WEP_SkinSet62_MAT.plague_dragonsbreath.PlagueEmerald_Dragonsbreath_1P_Mint_MIC"), MIC_3P="WEP_SkinSet62_MAT.plague_dragonsbreath.PlagueEmerald_Dragonsbreath_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet62_MAT.plague_dragonsbreath.PlagueEmerald_Dragonsbreath_3P_Pickup_MIC")) 

//Plague Doctor Precious Dragonsbreath
    Skins.Add((Id=9423, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Dragonsbreath', MIC_1P=("WEP_SkinSet62_MAT.plague_dragonsbreath.PlaguePrecious_Dragonsbreath_1P_Mint_MIC"), MIC_3P="WEP_SkinSet62_MAT.plague_dragonsbreath.PlaguePrecious_Dragonsbreath_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet62_MAT.plague_dragonsbreath.PlaguePrecious_Dragonsbreath_3P_Pickup_MIC")) 

//Chameleon Dynamic AA12
    Skins.Add((Id=9441, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet60_MAT.chameleon_aa12.Chameleon_AA12_1P_Mint_MIC"), MIC_3P="WEP_SkinSet60_MAT.chameleon_aa12.Chameleon_AA12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet60_MAT.chameleon_aa12.Chameleon_AA12_3P_Pickup_MIC")) 

//Chameleon Dynamic Flamethrower
    Skins.Add((Id=9442, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_FlameThrower', MIC_1P=("WEP_SkinSet60_MAT.chameleon_flamethrower.Chameleon_Flamethrower_1P_Mint_MIC"), MIC_3P="WEP_SkinSet60_MAT.chameleon_flamethrower.Chameleon_Flamethrower_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet60_MAT.chameleon_flamethrower.Chameleon_Flamethrower_3P_Pickup_MIC")) 

//Chameleon Dynamic M99
    Skins.Add((Id=9443, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_M99', MIC_1P=("WEP_SkinSet60_MAT.chameleon_m99.Chameleon_M99_1P_Mint_MIC", "WEP_SkinSet60_MAT.chameleon_m99.Chameleon_M99_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet60_MAT.chameleon_m99.Chameleon_M99_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet60_MAT.chameleon_m99.Chameleon_M99_3P_Pickup_MIC")) 

//Chameleon Dynamic SCAR
    Skins.Add((Id=9444, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_SCAR', MIC_1P=("WEP_SkinSet60_MAT.chameleon_scar.Chameleon_SCAR_1P_Mint_MIC", "WEP_SkinSet60_MAT.chameleon_scar.Chameleon_SCAR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet60_MAT.chameleon_scar.Chameleon_SCAR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet60_MAT.chameleon_scar.Chameleon_SCAR_3P_Pickup_MIC")) 

//Chameleon Dynamic RGB AA12
    Skins.Add((Id=9445, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet60_MAT.chameleonrgb_aa12.ChameleonRGB_AA12_1P_Mint_MIC"), MIC_3P="WEP_SkinSet60_MAT.chameleonrgb_aa12.ChameleonRGB_AA12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet60_MAT.chameleonrgb_aa12.ChameleonRGB_AA12_3P_Pickup_MIC")) 

//Chameleon Dynamic RGB Flamethrower
    Skins.Add((Id=9446, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_FlameThrower', MIC_1P=("WEP_SkinSet60_MAT.chameleonrgb_flamethrower.ChameleonRGB_Flamethrower_1P_Mint_MIC"), MIC_3P="WEP_SkinSet60_MAT.chameleonrgb_flamethrower.ChameleonRGB_Flamethrower_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet60_MAT.chameleonrgb_flamethrower.ChameleonRGB_Flamethrower_3P_Pickup_MIC")) 

//Chameleon Dynamic RGB M99
    Skins.Add((Id=9447, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_M99', MIC_1P=("WEP_SkinSet60_MAT.chameleonrgb_m99.ChameleonRGB_M99_1P_Mint_MIC", "WEP_SkinSet60_MAT.chameleonrgb_m99.ChameleonRGB_M99_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet60_MAT.chameleonrgb_m99.ChameleonRGB_M99_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet60_MAT.chameleonrgb_m99.ChameleonRGB_M99_3P_Pickup_MIC")) 

//Chameleon Dynamic RGB SCAR
    Skins.Add((Id=9448, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_SCAR', MIC_1P=("WEP_SkinSet60_MAT.chameleonrgb_scar.ChameleonRGB_SCAR_1P_Mint_MIC", "WEP_SkinSet60_MAT.chameleonrgb_scar.ChameleonRGB_SCAR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet60_MAT.chameleonrgb_scar.ChameleonRGB_SCAR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet60_MAT.chameleonrgb_scar.ChameleonRGB_SCAR_3P_Pickup_MIC")) 

//Classic Mint AK12
    Skins.Add((Id=9433, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet61_MAT.classic_ak12.Classic_AK12_1P_Mint_MIC"), MIC_3P="WEP_SkinSet61_MAT.classic_ak12.Classic_AK12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet61_MAT.classic_ak12.Classic_AK12_3P_Pickup_MIC")) 

//Classic Mint Desert Eagle
    Skins.Add((Id=9434, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet61_MAT.classic_deagle.Classic_Deagle_1P_Mint_MIC"), MIC_3P="WEP_SkinSet61_MAT.classic_deagle.Classic_Deagle_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet61_MAT.classic_deagle.Classic_Deagle_3P_Pickup_MIC")) 

//Classic Mint M14EBR
    Skins.Add((Id=9435, Weapondef=class'KFWeapDef_M14EBR', MIC_1P=("WEP_SkinSet61_MAT.classic_m14ebr.Classic_M14EBR_1P_Mint_MIC"), MIC_3P="WEP_SkinSet61_MAT.classic_m14ebr.Classic_M14EBR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet61_MAT.classic_m14ebr.Classic_M14EBR_3P_Pickup_MIC")) 

//Classic Mint Kriss
    Skins.Add((Id=9436, Weapondef=class'KFWeapDef_Kriss', MIC_1P=("WEP_SkinSet61_MAT.classic_kriss.Classic_Kriss_1P_Mint_MIC"), MIC_3P="WEP_SkinSet61_MAT.classic_kriss.Classic_Kriss_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet61_MAT.classic_kriss.Classic_Kriss_3P_Pickup_MIC")) 

//Classic Precious AK12
    Skins.Add((Id=9437, Weapondef=class'KFWeapDef_Ak12', MIC_1P=("WEP_SkinSet61_MAT.standard_ak12.Standard_AK12_1P_Mint_MIC"), MIC_3P="WEP_SkinSet61_MAT.standard_ak12.Standard_AK12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet61_MAT.standard_ak12.Standard_AK12_3P_Pickup_MIC")) 

//Classic Precious Desert Eagle
    Skins.Add((Id=9438, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet61_MAT.standard_deagle.Standard_Deagle_1P_Mint_MIC"), MIC_3P="WEP_SkinSet61_MAT.standard_deagle.Standard_Deagle_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet61_MAT.standard_deagle.Standard_Deagle_3P_Pickup_MIC")) 

//Classic Precious M14EBR
    Skins.Add((Id=9439, Weapondef=class'KFWeapDef_M14EBR', MIC_1P=("WEP_SkinSet61_MAT.standard_m14ebr.Standard_M14EBR_1P_Mint_MIC"), MIC_3P="WEP_SkinSet61_MAT.standard_m14ebr.Standard_M14EBR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet61_MAT.standard_m14ebr.Standard_M14EBR_3P_Pickup_MIC")) 

//Classic Precious Kriss
    Skins.Add((Id=9440, Weapondef=class'KFWeapDef_Kriss', MIC_1P=("WEP_SkinSet61_MAT.standard_kriss.Standard_Kriss_1P_Mint_MIC"), MIC_3P="WEP_SkinSet61_MAT.standard_kriss.Standard_Kriss_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet61_MAT.standard_kriss.Standard_Kriss_3P_Pickup_MIC")) 

//Xeno Dynamic M4
    Skins.Add((Id=9425, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_M4', MIC_1P=("wep_skinset63_mat.xeno_m4.Xeno_M4_1P_Mint_MIC"), MIC_3P="WEP_SkinSet63_MAT.xeno_m4.Xeno_M4_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet63_MAT.xeno_m4.Xeno_M4_3P_Pickup_MIC")) 

//Xeno Dynamic Heckler & Koch UMP
    Skins.Add((Id=9426, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HK_UMP', MIC_1P=("WEP_SkinSet63_MAT.xeno_hk_ump.Xeno_HK_UMP_1P_Mint_MIC", "WEP_SkinSet63_MAT.xeno_hk_ump.Xeno_HK_UMP_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet63_MAT.xeno_hk_ump.Xeno_HK_UMP_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet63_MAT.xeno_hk_ump.Xeno_HK_UMP_3P_Pickup_MIC")) 

//Xeno Dynamic Centerfire
    Skins.Add((Id=9427, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_CenterfireMB464', MIC_1P=("WEP_SkinSet63_MAT.xeno_centerfire.Xeno_Centerfire_1P_Mint_MIC"), MIC_3P="WEP_SkinSet63_MAT.xeno_centerfire.Xeno_Centerfire_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet63_MAT.xeno_centerfire.Xeno_Centerfire_3P_Pickup_MIC")) 

//Xeno Dynamic Hemoclobber
    Skins.Add((Id=9428, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MedicBat', MIC_1P=("WEP_SkinSet63_MAT.xeno_medicbat.Xeno_MedicBat_1P_Mint_MIC"), MIC_3P="WEP_SkinSet63_MAT.xeno_medicbat.Xeno_MedicBat_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet63_MAT.xeno_medicbat.Xeno_MedicBat_3P_Pickup_MIC")) 

//Xeno Dynamic RGB M4
    Skins.Add((Id=9429, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_M4', MIC_1P=("WEP_SkinSet63_MAT.xenorgb_m4.XenoRGB_M4_1P_Mint_MIC"), MIC_3P="WEP_SkinSet63_MAT.xenorgb_m4.XenoRGB_M4_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet63_MAT.xenorgb_m4.XenoRGB_M4_3P_Pickup_MIC")) 

//Xeno Dynamic RGB Heckler & Koch UMP
    Skins.Add((Id=9430, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HK_UMP', MIC_1P=("WEP_SkinSet63_MAT.xenorgb_hk_ump.XenoRGB_HK_UMP_1P_Mint_MIC", "WEP_SkinSet63_MAT.xenorgb_hk_ump.XenoRGB_HK_UMP_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet63_MAT.xenorgb_hk_ump.XenoRGB_HK_UMP_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet63_MAT.xenorgb_hk_ump.XenoRGB_HK_UMP_3P_Pickup_MIC")) 

//Xeno Dynamic RGB Centerfire
    Skins.Add((Id=9431, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_CenterfireMB464', MIC_1P=("WEP_SkinSet63_MAT.xenorgb_centerfire.XenoRGB_Centerfire_1P_Mint_MIC"), MIC_3P="WEP_SkinSet63_MAT.xenorgb_centerfire.XenoRGB_Centerfire_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet63_MAT.xenorgb_centerfire.XenoRGB_Centerfire_3P_Pickup_MIC")) 

//Xeno Dynamic RGB Hemoclobber
    Skins.Add((Id=9432, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MedicBat', MIC_1P=("WEP_SkinSet63_MAT.xenorgb_medicbat.XenoRGB_MedicBat_1P_Mint_MIC"), MIC_3P="WEP_SkinSet63_MAT.xenorgb_medicbat.XenoRGB_MedicBat_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet63_MAT.xenorgb_medicbat.XenoRGB_MedicBat_3P_Pickup_MIC")) 

//Chameleon Dynamic Heckler & Koch UMP
    Skins.Add((Id=9485, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HK_UMP', MIC_1P=("wep_skinset68_mat.chameleon_hk_ump.Chameleon_HK_UMP_1P_Mint_MIC", "wep_skinset68_mat.chameleon_hk_ump.Chameleon_HK_UMP_Sight_1P_Mint_MIC"), MIC_3P="wep_skinset68_mat.chameleon_hk_ump.Chameleon_HK_UMP_3P_Mint_MIC", MIC_Pickup="wep_skinset68_mat.chameleon_hk_ump.Chameleon_HK_UMP_3P_Pickup_MIC")) 

//Chameleon Dynamic Helios Rifle
    Skins.Add((Id=9486, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MicrowaveRifle', MIC_1P=("wep_skinset68_mat.chameleon_microwaveassault.Chameleon_MicrowaveAssault_1P_Mint_MIC"), MIC_3P="wep_skinset68_mat.chameleon_microwaveassault.Chameleon_MicrowaveAssault_3P_Mint_MIC", MIC_Pickup="wep_skinset68_mat.chameleon_microwaveassault.Chameleon_MicrowaveAssault_3P_Pickup_MIC")) 

//Chameleon Dynamic HMTech-501 Grenade Rifle
    Skins.Add((Id=9487, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MedicRifleGrenadeLauncher', MIC_1P=("wep_skinset68_mat.chameleon_medicgrenadelauncher.Chameleon_MedicGrenadeLauncher_1P_Mint_MIC"), MIC_3P="wep_skinset68_mat.chameleon_medicgrenadelauncher.Chameleon_MedicGrenadeLauncher_3P_Mint_MIC", MIC_Pickup="wep_skinset68_mat.chameleon_medicgrenadelauncher.Chameleon_MedicGrenadeLauncher_3P_Pickup_MIC")) 

//Chameleon Dynamic M32
    Skins.Add((Id=9488, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_M32', MIC_1P=("wep_skinset68_mat.chameleon_m32.Chameleon_M32_1P_Mint_MIC", "wep_skinset68_mat.chameleon_m32.Chameleon_M32_Sight_1P_Mint_MIC"), MIC_3P="wep_skinset68_mat.chameleon_m32.Chameleon_M32_3P_Mint_MIC", MIC_Pickup="wep_skinset68_mat.chameleon_m32.Chameleon_M32_3P_Pickup_MIC")) 

//Chameleon Dynamic RGB Heckler & Koch UMP
    Skins.Add((Id=9489, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HK_UMP', MIC_1P=("wep_skinset68_mat.chameleonrgb_hk_ump.ChameleonRGB_HK_UMP_1P_Mint_MIC", "wep_skinset68_mat.chameleonrgb_hk_ump.ChameleonRGB_HK_UMP_Sight_1P_Mint_MIC"), MIC_3P="wep_skinset68_mat.chameleonrgb_hk_ump.ChameleonRGB_HK_UMP_3P_Mint_MIC", MIC_Pickup="wep_skinset68_mat.chameleonrgb_hk_ump.ChameleonRGB_HK_UMP_3P_Pickup_MIC")) 

//Chameleon Dynamic RGB Helios Rifle
    Skins.Add((Id=9490, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MicrowaveRifle', MIC_1P=("wep_skinset68_mat.chameleonrgb_microwaveassault.ChameleonRGB_MicrowaveAssault_1P_Mint_MIC"), MIC_3P="wep_skinset68_mat.chameleonrgb_microwaveassault.ChameleonRGB_MicrowaveAssault_3P_Mint_MIC", MIC_Pickup="wep_skinset68_mat.chameleonrgb_microwaveassault.ChameleonRGB_MicrowaveAssault_3P_Pickup_MIC")) 

//Chameleon Dynamic RGB HMTech-501 Grenade Rifle
    Skins.Add((Id=9491, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MedicRifleGrenadeLauncher', MIC_1P=("wep_skinset68_mat.chameleonrgb_medicgrenadelauncher.ChameleonRGB_MedicGrenadeLauncher_1P_Mint_MIC"), MIC_3P="wep_skinset68_mat.chameleonrgb_medicgrenadelauncher.ChameleonRGB_MedicGrenadeLauncher_3P_Mint_MIC", MIC_Pickup="wep_skinset68_mat.chameleonrgb_medicgrenadelauncher.ChameleonRGB_MedicGrenadeLauncher_3P_Pickup_MIC")) 

//Chameleon Dynamic RGB M32
    Skins.Add((Id=9492, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_M32', MIC_1P=("wep_skinset68_mat.chameleonrgb_m32.ChameleonRGB_M32_1P_Mint_MIC", "wep_skinset68_mat.chameleonrgb_m32.ChameleonRGB_M32_Sight_1P_Mint_MIC"), MIC_3P="wep_skinset68_mat.chameleonrgb_m32.ChameleonRGB_M32_3P_Mint_MIC", MIC_Pickup="wep_skinset68_mat.chameleonrgb_m32.ChameleonRGB_M32_3P_Pickup_MIC")) 

//Medieval Mint BattleAxe
    Skins.Add((Id=9494, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_AbominationAxe', MIC_1P=("WEP_SkinSet67_MAT.medieval_krampusaxe.Medieval_KrampusAxe_1P_Mint_MIC"), MIC_3P="WEP_SkinSet67_MAT.medieval_krampusaxe.Medieval_KrampusAxe_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet67_MAT.medieval_krampusaxe.Medieval_KrampusAxe_3P_Pickup_MIC")) 

//Medieval Mint Boomstick
    Skins.Add((Id=9495, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_DoubleBarrel', MIC_1P=("WEP_SkinSet67_MAT.medieval_doublebarrel.Medieval_DoubleBarrel_1P_Mint_MIC"), MIC_3P="WEP_SkinSet67_MAT.medieval_doublebarrel.Medieval_DoubleBarrel_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet67_MAT.medieval_doublebarrel.Medieval_DoubleBarrel_3P_Pickup_MIC")) 

//Medieval Mint Pulverizer
    Skins.Add((Id=9496, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Pulverizer', MIC_1P=("WEP_SkinSet67_MAT.medieval_pulverizer.Medieval_Pulverizer_1P_Mint_MIC"), MIC_3P="WEP_SkinSet67_MAT.medieval_pulverizer.Medieval_Pulverizer_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet67_MAT.medieval_pulverizer.Medieval_Pulverizer_3P_Pickup_MIC")) 

//Medieval Mint RPG-7
    Skins.Add((Id=9497, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_RPG7', MIC_1P=("WEP_SkinSet67_MAT.medieval_rpg7.Medieval_RPG7_1P_Mint_MIC"), MIC_3P="WEP_SkinSet67_MAT.medieval_rpg7.Medieval_RPG7_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet67_MAT.medieval_rpg7.Medieval_RPG7_3P_Pickup_MIC")) 

//Medieval Precious BattleAxe
    Skins.Add((Id=9498, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_AbominationAxe', MIC_1P=("WEP_SkinSet67_MAT.medievalgold_krampusaxe.MedievalGold_KrampusAxe_1P_Mint_MIC"), MIC_3P="WEP_SkinSet67_MAT.medievalgold_krampusaxe.MedievalGold_KrampusAxe_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet67_MAT.medievalgold_krampusaxe.MedievalGold_KrampusAxe_3P_Pickup_MIC")) 

//Medieval Precious Boomstick
    Skins.Add((Id=9499, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_DoubleBarrel', MIC_1P=("WEP_SkinSet67_MAT.medievalgold_DoubleBarrel.MedievalGold_DoubleBarrel_1P_Mint_MIC"), MIC_3P="WEP_SkinSet67_MAT.medievalgold_DoubleBarrel.MedievalGold_DoubleBarrel_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet67_MAT.medievalgold_DoubleBarrel.MedievalGold_DoubleBarrel_3P_Pickup_MIC")) 

//Medieval Precious Pulverizer
    Skins.Add((Id=9500, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Pulverizer', MIC_1P=("WEP_SkinSet67_MAT.medievalgold_pulverizer.MedievalGold_Pulverizer_1P_Mint_MIC"), MIC_3P="WEP_SkinSet67_MAT.medievalgold_pulverizer.MedievalGold_Pulverizer_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet67_MAT.medievalgold_pulverizer.MedievalGold_Pulverizer_3P_Pickup_MIC")) 

//Medieval Precious RPG-7
    Skins.Add((Id=9501, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_RPG7', MIC_1P=("WEP_SkinSet67_MAT.medievalgold_rpg7.MedievalGold_RPG7_1P_Mint_MIC"), MIC_3P="WEP_SkinSet67_MAT.medievalgold_rpg7.MedievalGold_RPG7_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet67_MAT.medievalgold_rpg7.MedievalGold_RPG7_3P_Pickup_MIC")) 

//Tacticool Dynamic AA12
    Skins.Add((Id=9544, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet66_MAT.tacticool_aa12.Tacticool_AA12_1P_Mint_MIC"), MIC_3P="WEP_SkinSet66_MAT.tacticool_aa12.Tacticool_AA12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet66_MAT.tacticool_aa12.Tacticool_AA12_3P_Pickup_MIC")) 

//Tacticool Dynamic M99
    Skins.Add((Id=9545, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_M99', MIC_1P=("WEP_SkinSet66_MAT.tacticool_m99.Tacticool_M99_1P_Mint_MIC", "WEP_SkinSet66_MAT.tacticool_m99.Tacticool_M99_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet66_MAT.tacticool_m99.Tacticool_M99_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet66_MAT.tacticool_m99.Tacticool_M99_3P_Pickup_MIC")) 

//Tacticool Dynamic MP5RAS
    Skins.Add((Id=9546, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MP5RAS', MIC_1P=("WEP_SkinSet66_MAT.tacticool_mp5ras.Tacticool_MP5RAS_1P_Mint_MIC"), MIC_3P="WEP_SkinSet66_MAT.tacticool_mp5ras.Tacticool_MP5RAS_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet66_MAT.tacticool_mp5ras.Tacticool_MP5RAS_3P_Pickup_MIC")) 

//Tacticool Dynamic SCAR
    Skins.Add((Id=9547, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_SCAR', MIC_1P=("WEP_SkinSet66_MAT.tacticool_scar.Tacticool_SCAR_1P_Mint_MIC", "WEP_SkinSet66_MAT.tacticool_scar.Tacticool_SCAR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet66_MAT.tacticool_scar.Tacticool_SCAR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet66_MAT.tacticool_scar.Tacticool_SCAR_3P_Pickup_MIC")) 

//Tacticool Dynamic Precious AA12
    Skins.Add((Id=9548, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_AA12', MIC_1P=("WEP_SkinSet66_MAT.tacticool_aa12.TacticoolPrecious_AA12_1P_Mint_MIC"), MIC_3P="WEP_SkinSet66_MAT.tacticool_aa12.TacticoolPrecious_AA12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet66_MAT.tacticool_aa12.TacticoolPrecious_AA12_3P_Pickup_MIC")) 

//Tacticool Dynamic Precious M99
    Skins.Add((Id=9549, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_M99', MIC_1P=("WEP_SkinSet66_MAT.tacticool_m99.TacticoolPrecious_M99_1P_Mint_MIC", "WEP_SkinSet66_MAT.tacticool_m99.TacticoolPrecious_M99_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet66_MAT.tacticool_m99.TacticoolPrecious_M99_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet66_MAT.tacticool_m99.TacticoolPrecious_M99_3P_Pickup_MIC")) 

//Tacticool Dynamic Precious MP5RAS
    Skins.Add((Id=9550, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MP5RAS', MIC_1P=("WEP_SkinSet66_MAT.tacticool_mp5ras.TacticoolPrecious_MP5RAS_1P_Mint_MIC"), MIC_3P="WEP_SkinSet66_MAT.tacticool_mp5ras.TacticoolPrecious_MP5RAS_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet66_MAT.tacticool_mp5ras.TacticoolPrecious_MP5RAS_3P_Pickup_MIC")) 

//Tacticool Dynamic Precious SCAR
    Skins.Add((Id=9551, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_SCAR', MIC_1P=("WEP_SkinSet66_MAT.tacticool_scar.TacticoolPrecious_SCAR_1P_Mint_MIC", "WEP_SkinSet66_MAT.tacticool_scar.TacticoolPrecious_SCAR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet66_MAT.tacticool_scar.TacticoolPrecious_SCAR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet66_MAT.tacticool_scar.TacticoolPrecious_SCAR_3P_Pickup_MIC")) 

//Retro Arcade P90
    Skins.Add((Id=9504, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_P90', MIC_1P=("WEP_SkinSet69_MAT.retro_p90.RetroConsole_P90_1P_Mint_MIC", "WEP_SkinSet69_MAT.retro_p90.RetroConsole_P90_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet69_MAT.retro_p90.RetroConsole_P90_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet69_MAT.retro_p90.RetroConsole_P90_3P_Pickup_MIC")) 

//Retro Light Noir P90
    Skins.Add((Id=9505, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_P90', MIC_1P=("WEP_SkinSet69_MAT.retro_p90.RetroLightNoir_P90_1P_Mint_MIC", "WEP_SkinSet69_MAT.retro_p90.RetroLightNoir_P90_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet69_MAT.retro_p90.RetroLightNoir_P90_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet69_MAT.retro_p90.RetroLightNoir_P90_3P_Pickup_MIC")) 

//Retro Dark Noir P90
    Skins.Add((Id=9506, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_P90', MIC_1P=("WEP_SkinSet69_MAT.retro_p90.RetroDarkNoir_P90_1P_Mint_MIC", "WEP_SkinSet69_MAT.retro_p90.RetroDarkNoir_P90_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet69_MAT.retro_p90.RetroDarkNoir_P90_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet69_MAT.retro_p90.RetroDarkNoir_P90_3P_Pickup_MIC")) 

//Retro Cyber P90
    Skins.Add((Id=9507, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_P90', MIC_1P=("WEP_SkinSet69_MAT.retro_p90.RetroCyber_P90_1P_Mint_MIC", "WEP_SkinSet69_MAT.retro_p90.RetroCyber_P90_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet69_MAT.retro_p90.RetroCyber_P90_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet69_MAT.retro_p90.RetroCyber_P90_3P_Pickup_MIC")) 

//Retro Synth P90
    Skins.Add((Id=9508, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_P90', MIC_1P=("WEP_SkinSet69_MAT.retro_p90.RetroSynth_P90_1P_Mint_MIC", "WEP_SkinSet69_MAT.retro_p90.RetroSynth_P90_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet69_MAT.retro_p90.RetroSynth_P90_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet69_MAT.retro_p90.RetroSynth_P90_3P_Pickup_MIC")) 

//Retro Precious P90
    Skins.Add((Id=9509, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_P90', MIC_1P=("WEP_SkinSet69_MAT.retro_p90.RetroPrecious_P90_1P_Mint_MIC", "WEP_SkinSet69_MAT.retro_p90.RetroPrecious_P90_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet69_MAT.retro_p90.RetroPrecious_P90_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet69_MAT.retro_p90.RetroPrecious_P90_3P_Pickup_MIC")) 

//Retro Arcade Static Strikers
    Skins.Add((Id=9510, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_PowerGloves', MIC_1P=("WEP_SkinSet69_MAT.retro_staticstrikers.RetroConsole_StaticStrikers_1P_Mint_MIC"), MIC_3P="WEP_SkinSet69_MAT.retro_staticstrikers.RetroConsole_StaticStrikers_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet69_MAT.retro_staticstrikers.RetroConsole_StaticStrikers_3P_Pickup_MIC")) 

//Retro Light Noir Static Strikers
    Skins.Add((Id=9511, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_PowerGloves', MIC_1P=("WEP_SkinSet69_MAT.retro_staticstrikers.RetroLightNoir_StaticStrikers_1P_Mint_MIC"), MIC_3P="WEP_SkinSet69_MAT.retro_staticstrikers.RetroLightNoir_StaticStrikers_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet69_MAT.retro_staticstrikers.RetroLightNoir_StaticStrikers_3P_Pickup_MIC")) 

//Retro Dark Noir Static Strikers
    Skins.Add((Id=9512, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_PowerGloves', MIC_1P=("WEP_SkinSet69_MAT.retro_staticstrikers.RetroDarkNoir_StaticStrikers_1P_Mint_MIC"), MIC_3P="WEP_SkinSet69_MAT.retro_staticstrikers.RetroDarkNoir_StaticStrikers_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet69_MAT.retro_staticstrikers.RetroDarkNoir_StaticStrikers_3P_Pickup_MIC")) 

//Retro Cyber Static Strikers
    Skins.Add((Id=9513, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_PowerGloves', MIC_1P=("WEP_SkinSet69_MAT.retro_staticstrikers.RetroCyber_StaticStrikers_1P_Mint_MIC"), MIC_3P="WEP_SkinSet69_MAT.retro_staticstrikers.RetroCyber_StaticStrikers_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet69_MAT.retro_staticstrikers.RetroCyber_StaticStrikers_3P_Pickup_MIC")) 

//Retro Synth Static Strikers
    Skins.Add((Id=9514, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_PowerGloves', MIC_1P=("WEP_SkinSet69_MAT.retro_staticstrikers.RetroSynth_StaticStrikers_1P_Mint_MIC"), MIC_3P="WEP_SkinSet69_MAT.retro_staticstrikers.RetroSynth_StaticStrikers_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet69_MAT.retro_staticstrikers.RetroSynth_StaticStrikers_3P_Pickup_MIC")) 

//Retro Precious Static Strikers
    Skins.Add((Id=9515, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_PowerGloves', MIC_1P=("WEP_SkinSet69_MAT.retro_staticstrikers.RetroPrecious_StaticStrikers_1P_Mint_MIC"), MIC_3P="WEP_SkinSet69_MAT.retro_staticstrikers.RetroPrecious_StaticStrikers_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet69_MAT.retro_staticstrikers.RetroPrecious_StaticStrikers_3P_Pickup_MIC")) 

//Retro Arcade HZ12
    Skins.Add((Id=9516, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HZ12', MIC_1P=("WEP_SkinSet69_MAT.retro_hz12.RetroConsole_HZ12_1P_Mint_MIC"), MIC_3P="WEP_SkinSet69_MAT.retro_hz12.RetroConsole_HZ12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet69_MAT.retro_hz12.RetroConsole_HZ12_3P_Pickup_MIC")) 

//Retro Light Noir HZ12
    Skins.Add((Id=9517, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HZ12', MIC_1P=("WEP_SkinSet69_MAT.retro_hz12.RetroLightNoir_HZ12_1P_Mint_MIC"), MIC_3P="WEP_SkinSet69_MAT.retro_hz12.RetroLightNoir_HZ12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet69_MAT.retro_hz12.RetroLightNoir_HZ12_3P_Pickup_MIC")) 

//Retro Dark Noir HZ12
    Skins.Add((Id=9518, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HZ12', MIC_1P=("WEP_SkinSet69_MAT.retro_hz12.RetroDarkNoir_HZ12_1P_Mint_MIC"), MIC_3P="WEP_SkinSet69_MAT.retro_hz12.RetroDarkNoir_HZ12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet69_MAT.retro_hz12.RetroDarkNoir_HZ12_3P_Pickup_MIC")) 

//Retro Cyber HZ12
    Skins.Add((Id=9519, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HZ12', MIC_1P=("WEP_SkinSet69_MAT.retro_hz12.RetroCyber_HZ12_1P_Mint_MIC"), MIC_3P="WEP_SkinSet69_MAT.retro_hz12.RetroCyber_HZ12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet69_MAT.retro_hz12.RetroCyber_HZ12_3P_Pickup_MIC")) 

//Retro Synth HZ12
    Skins.Add((Id=9520, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HZ12', MIC_1P=("WEP_SkinSet69_MAT.retro_hz12.RetroSynth_HZ12_1P_Mint_MIC"), MIC_3P="WEP_SkinSet69_MAT.retro_hz12.RetroSynth_HZ12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet69_MAT.retro_hz12.RetroSynth_HZ12_3P_Pickup_MIC")) 

//Retro Precious HZ12
    Skins.Add((Id=9521, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HZ12', MIC_1P=("WEP_SkinSet69_MAT.retro_hz12.RetroPrecious_HZ12_1P_Mint_MIC"), MIC_3P="WEP_SkinSet69_MAT.retro_hz12.RetroPrecious_HZ12_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet69_MAT.retro_hz12.RetroPrecious_HZ12_3P_Pickup_MIC")) 

//Retro Arcade Microwave Gun
    Skins.Add((Id=9522, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MicrowaveGun', MIC_1P=("WEP_SkinSet69_MAT.retro_microwavegun.RetroConsole_MicrowaveGun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet69_MAT.retro_microwavegun.RetroConsole_MicrowaveGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet69_MAT.retro_microwavegun.RetroConsole_MicrowaveGun_3P_Pickup_MIC")) 

//Retro Light Noir Microwave Gun
    Skins.Add((Id=9523, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MicrowaveGun', MIC_1P=("WEP_SkinSet69_MAT.retro_microwavegun.RetroLightNoir_MicrowaveGun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet69_MAT.retro_microwavegun.RetroLightNoir_MicrowaveGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet69_MAT.retro_microwavegun.RetroLightNoir_MicrowaveGun_3P_Pickup_MIC")) 

//Retro Dark Noir Microwave Gun
    Skins.Add((Id=9524, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MicrowaveGun', MIC_1P=("WEP_SkinSet69_MAT.retro_microwavegun.RetroDarkNoir_MicrowaveGun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet69_MAT.retro_microwavegun.RetroDarkNoir_MicrowaveGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet69_MAT.retro_microwavegun.RetroDarkNoir_MicrowaveGun_3P_Pickup_MIC")) 

//Retro Cyber Microwave Gun
    Skins.Add((Id=9525, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MicrowaveGun', MIC_1P=("WEP_SkinSet69_MAT.retro_microwavegun.RetroCyber_MicrowaveGun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet69_MAT.retro_microwavegun.RetroCyber_MicrowaveGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet69_MAT.retro_microwavegun.RetroCyber_MicrowaveGun_3P_Pickup_MIC")) 

//Retro Synth Microwave Gun
    Skins.Add((Id=9526, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MicrowaveGun', MIC_1P=("WEP_SkinSet69_MAT.retro_microwavegun.RetroSynth_MicrowaveGun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet69_MAT.retro_microwavegun.RetroSynth_MicrowaveGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet69_MAT.retro_microwavegun.RetroSynth_MicrowaveGun_3P_Pickup_MIC")) 

//Retro Precious Microwave Gun
    Skins.Add((Id=9527, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MicrowaveGun', MIC_1P=("WEP_SkinSet69_MAT.retro_microwavegun.RetroPrecious_MicrowaveGun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet69_MAT.retro_microwavegun.RetroPrecious_MicrowaveGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet69_MAT.retro_microwavegun.RetroPrecious_MicrowaveGun_3P_Pickup_MIC")) 

//Retro Arcade Helios Rifle
    Skins.Add((Id=9528, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MicrowaveRifle', MIC_1P=("WEP_SkinSet69_MAT.retro_microwaveassault.RetroConsole_MicrowaveAssault_1P_Mint_MIC"), MIC_3P="WEP_SkinSet69_MAT.retro_microwaveassault.RetroConsole_MicrowaveAssault_3P_Mint_M", MIC_Pickup="WEP_SkinSet69_MAT.retro_microwaveassault.RetroConsole_MicrowaveAssault_3P_Pickup_MIC")) 

//Retro Light Noir Helios Rifle
    Skins.Add((Id=9529, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MicrowaveRifle', MIC_1P=("WEP_SkinSet69_MAT.retro_microwaveassault.RetroLightNoir_MicrowaveAssault_1P_Mint_MIC"), MIC_3P="WEP_SkinSet69_MAT.retro_microwaveassault.RetroLightNoir_MicrowaveAssault_3P_Mint_M", MIC_Pickup="WEP_SkinSet69_MAT.retro_microwaveassault.RetroLightNoir_MicrowaveAssault_3P_Pickup_MIC")) 

//Retro Dark Noir Helios Rifle
    Skins.Add((Id=9530, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MicrowaveRifle', MIC_1P=("WEP_SkinSet69_MAT.retro_microwaveassault.RetroDarkNoir_MicrowaveAssault_1P_Mint_MIC"), MIC_3P="WEP_SkinSet69_MAT.retro_microwaveassault.RetroDarkNoir_MicrowaveAssault_3P_Mint_M", MIC_Pickup="WEP_SkinSet69_MAT.retro_microwaveassault.RetroDarkNoir_MicrowaveAssault_3P_Pickup_MIC")) 

//Retro Cyber Helios Rifle
    Skins.Add((Id=9531, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MicrowaveRifle', MIC_1P=("WEP_SkinSet69_MAT.retro_microwaveassault.RetroCyber_MicrowaveAssault_1P_Mint_MIC"), MIC_3P="WEP_SkinSet69_MAT.retro_microwaveassault.RetroCyber_MicrowaveAssault_3P_Mint_M", MIC_Pickup="WEP_SkinSet69_MAT.retro_microwaveassault.RetroCyber_MicrowaveAssault_3P_Pickup_MIC")) 

//Retro Synth Helios Rifle
    Skins.Add((Id=9532, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MicrowaveRifle', MIC_1P=("WEP_SkinSet69_MAT.retro_microwaveassault.RetroSynth_MicrowaveAssault_1P_Mint_MIC"), MIC_3P="WEP_SkinSet69_MAT.retro_microwaveassault.RetroSynth_MicrowaveAssault_3P_Mint_M", MIC_Pickup="WEP_SkinSet69_MAT.retro_microwaveassault.RetroSynth_MicrowaveAssault_3P_Pickup_MIC")) 

//Retro Precious Helios Rifle
    Skins.Add((Id=9533, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MicrowaveRifle', MIC_1P=("WEP_SkinSet69_MAT.retro_microwaveassault.RetroPrecious_MicrowaveAssault_1P_Mint_MIC"), MIC_3P="WEP_SkinSet69_MAT.retro_microwaveassault.RetroPrecious_MicrowaveAssault_3P_Mint_M", MIC_Pickup="WEP_SkinSet69_MAT.retro_microwaveassault.RetroPrecious_MicrowaveAssault_3P_Pickup_MIC")) 

//Retro Arcade Railgun
    Skins.Add((Id=9534, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Railgun', MIC_1P=("WEP_SkinSet69_MAT.retro_railgun.RetroConsole_Railgun_1P_Mint_MIC", "WEP_SkinSet69_MAT.retro_railgun.RetroConsole_Railgun_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet69_MAT.retro_railgun.RetroConsole_Railgun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet69_MAT.retro_railgun.RetroConsole_Railgun_3P_Pickup_MIC")) 

//Retro Light Noir Railgun
    Skins.Add((Id=9535, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Railgun', MIC_1P=("WEP_SkinSet69_MAT.retro_railgun.RetroLightNoir_Railgun_1P_Mint_MIC", "WEP_SkinSet69_MAT.retro_railgun.RetroLightNoir_Railgun_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet69_MAT.retro_railgun.RetroLightNoir_Railgun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet69_MAT.retro_railgun.RetroLightNoir_Railgun_3P_Pickup_MIC")) 

//Retro Dark Noir Railgun
    Skins.Add((Id=9536, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Railgun', MIC_1P=("WEP_SkinSet69_MAT.retro_railgun.RetroDarkNoir_Railgun_1P_Mint_MIC", "WEP_SkinSet69_MAT.retro_railgun.RetroDarkNoir_Railgun_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet69_MAT.retro_railgun.RetroDarkNoir_Railgun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet69_MAT.retro_railgun.RetroDarkNoir_Railgun_3P_Pickup_MIC")) 

//Retro Cyber Railgun
    Skins.Add((Id=9537, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Railgun', MIC_1P=("WEP_SkinSet69_MAT.retro_railgun.RetroCyber_Railgun_1P_Mint_MIC", "WEP_SkinSet69_MAT.retro_railgun.RetroCyber_Railgun_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet69_MAT.retro_railgun.RetroCyber_Railgun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet69_MAT.retro_railgun.RetroCyber_Railgun_3P_Pickup_MIC")) 

//Retro Synth Railgun
    Skins.Add((Id=9538, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Railgun', MIC_1P=("WEP_SkinSet69_MAT.retro_railgun.RetroSynth_Railgun_1P_Mint_MIC", "WEP_SkinSet69_MAT.retro_railgun.RetroSynth_Railgun_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet69_MAT.retro_railgun.RetroSynth_Railgun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet69_MAT.retro_railgun.RetroSynth_Railgun_3P_Pickup_MIC")) 

//Retro Precious Railgun
    Skins.Add((Id=9539, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Railgun', MIC_1P=("WEP_SkinSet69_MAT.retro_railgun.RetroPrecious_Railgun_1P_Mint_MIC", "WEP_SkinSet69_MAT.retro_railgun.RetroPrecious_Railgun_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet69_MAT.retro_railgun.RetroPrecious_Railgun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet69_MAT.retro_railgun.RetroPrecious_Railgun_3P_Pickup_MIC")) 

//Jaeger Dynamic M14EBR
    Skins.Add((Id=9582, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_M14EBR', MIC_1P=("WEP_SkinSet72_MAT.dynamic_m14ebr.Dynamic_M14EBR_1P_Mint_MIC", "WEP_SkinSet72_MAT.dynamic_m14ebr.Dynamic_M14EBR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet72_MAT.dynamic_m14ebr.Dynamic_M14EBR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet72_MAT.dynamic_m14ebr.Dynamic_M14EBR_3P_Pickup_MIC")) 

//Jaeger Dynamic Seeker Six
    Skins.Add((Id=9583, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Seeker6', MIC_1P=("WEP_SkinSet72_MAT.dynamic_seekersix.Dynamic_SeekerSix_1P_Mint_MIC", "WEP_SkinSet72_MAT.dynamic_seekersix.Dynamic_SeekerSix_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet72_MAT.dynamic_seekersix.Dynamic_SeekerSix_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet72_MAT.dynamic_seekersix.Dynamic_SeekerSix_3P_Pickup_MIC")) 

//Jaeger Dynamic Railgun
    Skins.Add((Id=9584, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Railgun', MIC_1P=("WEP_SkinSet72_MAT.dynamic_railgun.Dynamic_Railgun_1P_Mint_MIC", "WEP_SkinSet72_MAT.dynamic_railgun.Dynamic_Railgun_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet72_MAT.dynamic_railgun.Dynamic_Railgun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet72_MAT.dynamic_railgun.Dynamic_Railgun_3P_Pickup_MIC")) 

//Jaeger Dynamic MP5RAS
    Skins.Add((Id=9585, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MP5RAS', MIC_1P=("WEP_SkinSet72_MAT.dynamic_mp5ras.Dynamic_MP5RAS_1P_Mint_MIC"), MIC_3P="WEP_SkinSet72_MAT.dynamic_mp5ras.Dynamic_MP5RAS_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet72_MAT.dynamic_mp5ras.Dynamic_MP5RAS_3P_Pickup_MIC")) 

//Jaeger Dynamic RGB M14EBR
    Skins.Add((Id=9586, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_M14EBR', MIC_1P=("WEP_SkinSet72_MAT.dynamicrgb_m14ebr.DynamicRGB_M14EBR_1P_Mint_MIC", "WEP_SkinSet72_MAT.dynamicrgb_m14ebr.DynamicRGB_M14EBR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet72_MAT.dynamicrgb_m14ebr.DynamicRGB_M14EBR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet72_MAT.dynamicrgb_m14ebr.DynamicRGB_M14EBR_3P_Pickup_MIC")) 

//Jaeger Dynamic RGB Seeker Six
    Skins.Add((Id=9587, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Seeker6', MIC_1P=("WEP_SkinSet72_MAT.dynamicrgb_seekersix.DynamicRGB_SeekerSix_1P_Mint_MIC", "WEP_SkinSet72_MAT.dynamicrgb_seekersix.DynamicRGB_SeekerSix_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet72_MAT.dynamicrgb_seekersix.DynamicRGB_SeekerSix_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet72_MAT.dynamicrgb_seekersix.DynamicRGB_SeekerSix_3P_Pickup_MIC")) 

//Jaeger Dynamic RGB Railgun
    Skins.Add((Id=9588, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Railgun', MIC_1P=("WEP_SkinSet72_MAT.dynamicrgb_railgun.DynamicRGB_Railgun_1P_Mint_MIC", "WEP_SkinSet72_MAT.dynamicrgb_railgun.DynamicRGB_Railgun_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet72_MAT.dynamicrgb_railgun.DynamicRGB_Railgun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet72_MAT.dynamicrgb_railgun.DynamicRGB_Railgun_3P_Pickup_MIC")) 

//Jaeger Dynamic RGB MP5RAS
    Skins.Add((Id=9589, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MP5RAS', MIC_1P=("WEP_SkinSet72_MAT.dynamicrgb_mp5ras.DynamicRGB_MP5RAS_1P_Mint_MIC"), MIC_3P="WEP_SkinSet72_MAT.dynamicrgb_mp5ras.DynamicRGB_MP5RAS_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet72_MAT.dynamicrgb_mp5ras.DynamicRGB_MP5RAS_3P_Pickup_MIC")) 

//Junkyard Mint RPG-7
    Skins.Add((Id=9590, Weapondef=class'KFWeapDef_RPG7', MIC_1P=("WEP_SkinSet73_MAT.junkyard_rpg7.Junkyard_RPG7_1P_Mint_MIC"), MIC_3P="WEP_SkinSet73_MAT.junkyard_rpg7.Junkyard_RPG7_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet73_MAT.junkyard_rpg7.Junkyard_RPG7_3P_Pickup_MIC")) 

//Junkyard Mint M99
    Skins.Add((Id=9591, Weapondef=class'KFWeapDef_M99', MIC_1P=("WEP_SkinSet73_MAT.junkyard_m99.Junkyard_M99_1P_Mint_MIC", "WEP_SkinSet73_MAT.junkyard_m99.Junkyard_M99_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet73_MAT.junkyard_m99.Junkyard_M99_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet73_MAT.junkyard_m99.Junkyard_M99_3P_Pickup_MIC")) 

//Junkyard Mint Heckler & Koch UMP
    Skins.Add((Id=9592, Weapondef=class'KFWeapDef_HK_UMP', MIC_1P=("WEP_SkinSet73_MAT.junkyard_hk_ump.Junkyard_HK_UMP_1P_Mint_MIC", "WEP_SkinSet73_MAT.junkyard_hk_ump.Junkyard_HK_UMP_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet73_MAT.junkyard_hk_ump.Junkyard_HK_UMP_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet73_MAT.junkyard_hk_ump.Junkyard_HK_UMP_3P_Pickup_MIC")) 

//Junkyard Mint FN FAL
    Skins.Add((Id=9593, Weapondef=class'KFWeapDef_FNFAL', MIC_1P=("WEP_SkinSet73_MAT.junkyard_fnfal.Junkyard_FNFAL_1P_Mint_MIC", "WEP_SkinSet73_MAT.junkyard_fnfal.Junkyard_FNFAL_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet73_MAT.junkyard_fnfal.Junkyard_FNFAL_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet73_MAT.junkyard_fnfal.Junkyard_FNFAL_3P_Pickup_MIC")) 

//Junkyard Precious RPG-7
    Skins.Add((Id=9594, Weapondef=class'KFWeapDef_RPG7', MIC_1P=("WEP_SkinSet73_MAT.junkyardprecious_rpg7.JunkyardPrecious_RPG7_1P_Mint_MIC"), MIC_3P="WEP_SkinSet73_MAT.junkyardprecious_rpg7.JunkyardPrecious_RPG7_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet73_MAT.junkyardprecious_rpg7.JunkyardPrecious_RPG7_3P_Pickup_MIC")) 

//Junkyard Precious M99
    Skins.Add((Id=9595, Weapondef=class'KFWeapDef_M99', MIC_1P=("WEP_SkinSet73_MAT.junkyardprecious_m99.JunkyardPrecious_M99_1P_Mint_MIC", "WEP_SkinSet73_MAT.junkyardprecious_m99.JunkyardPrecious_M99_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet73_MAT.junkyardprecious_m99.JunkyardPrecious_M99_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet73_MAT.junkyardprecious_m99.JunkyardPrecious_M99_3P_Pickup_MIC")) 

//Junkyard Precious Heckler & Koch UMP
    Skins.Add((Id=9596, Weapondef=class'KFWeapDef_HK_UMP', MIC_1P=("WEP_SkinSet73_MAT.junkyardprecious_hk_ump.JunkyardPrecious_HK_UMP_1P_Mint_MIC", "WEP_SkinSet73_MAT.junkyardprecious_hk_ump.JunkyardPrecious_HK_UMP_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet73_MAT.junkyardprecious_hk_ump.JunkyardPrecious_HK_UMP_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet73_MAT.junkyardprecious_hk_ump.JunkyardPrecious_HK_UMP_3P_Pickup_MIC")) 

//Junkyard Precious FN FAL
    Skins.Add((Id=9597, Weapondef=class'KFWeapDef_FNFAL', MIC_1P=("WEP_SkinSet73_MAT.junkyardprecious_fnfal.JunkyardPrecious_FNFAL_1P_Mint_MIC", "WEP_SkinSet73_MAT.junkyardprecious_fnfal.JunkyardPrecious_FNFAL_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet73_MAT.junkyardprecious_fnfal.JunkyardPrecious_FNFAL_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet73_MAT.junkyardprecious_fnfal.JunkyardPrecious_FNFAL_3P_Pickup_MIC")) 

//Predator Forest M16 M203
    Skins.Add((Id=9637, Weapondef=class'KFWeapDef_M16M203', MIC_1P=("WEP_SkinSet74_MAT.camo_m16m203.Camo_M16_1P_Mint_MIC", "WEP_SkinSet74_MAT.camo_m16m203.Camo_M203_1P_Mint_MIC"), MIC_3P="WEP_SkinSet74_MAT.camo_m16m203.Camo_M16M203_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet74_MAT.camo_m16m203.Camo_M16M203_3P_Pickup_MIC")) 

//Predator Forest M79
    Skins.Add((Id=9638, Weapondef=class'KFWeapDef_M79', MIC_1P=("WEP_SkinSet74_MAT.camo_m79.Camo_M79_1P_Mint_MIC"), MIC_3P="WEP_SkinSet74_MAT.camo_m79.Camo_M79_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet74_MAT.camo_m79.Camo_M79_3P_Pickup_MIC")) 

//Predator Forest Kriss SMG
    Skins.Add((Id=9639, Weapondef=class'KFWeapDef_Kriss', MIC_1P=("WEP_SkinSet74_MAT.camo_kriss.Camo_Kriss_1P_Mint_MIC", "WEP_SkinSet74_MAT.camo_kriss.Camo_Kriss_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet74_MAT.camo_kriss.Camo_Kriss_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet74_MAT.camo_kriss.Camo_Kriss_3P_Pickup_MIC")) 

//Predator Forest 9MM
    Skins.Add((Id=9640, Weapondef=class'KFWeapDef_9mm', MIC_1P=("WEP_SkinSet74_MAT.camo_9mm.Camo_9MM_1P_Mint_MIC"), MIC_3P="WEP_SkinSet74_MAT.camo_9mm.Camo_9MM_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet74_MAT.camo_9mm.Camo_9MM_3P_Pickup_MIC")) 

//Predator Desert M16 M203
    Skins.Add((Id=9641, Weapondef=class'KFWeapDef_M16M203', MIC_1P=("WEP_SkinSet74_MAT.camodesert_m16m203.CamoDesert_M16_1P_Mint_MIC", "WEP_SkinSet74_MAT.camodesert_m16m203.CamoDesert_M203_1P_Mint_MIC"), MIC_3P="WEP_SkinSet74_MAT.camodesert_m16m203.CamoDesert_M16M203_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet74_MAT.camo_m16m203.CamoDesert_M16M203_3P_Pickup_MIC")) 

//Predator Desert M79
    Skins.Add((Id=9642, Weapondef=class'KFWeapDef_M79', MIC_1P=("WEP_SkinSet74_MAT.camodesert_m79.CamoDesert_M79_1P_Mint_MIC"), MIC_3P="WEP_SkinSet74_MAT.camodesert_m79.CamoDesert_M79_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet74_MAT.camo_m79.CamoDesert_M79_3P_Pickup_MIC")) 

//Predator Desert Kriss SMG
    Skins.Add((Id=9643, Weapondef=class'KFWeapDef_Kriss', MIC_1P=("WEP_SkinSet74_MAT.camodesert_kriss.CamoDesert_Kriss_1P_Mint_MIC", "WEP_SkinSet74_MAT.camodesert_kriss.CamoDesert_Kriss_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet74_MAT.camodesert_kriss.CamoDesert_Kriss_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet74_MAT.camo_kriss.CamoDesert_Kriss_3P_Pickup_MIC")) 

//Predator Desert 9MM
    Skins.Add((Id=9644, Weapondef=class'KFWeapDef_9mm', MIC_1P=("WEP_SkinSet74_MAT.camodesert_9mm.CamoDesert_9MM_1P_Mint_MIC"), MIC_3P="WEP_SkinSet74_MAT.camodesert_9mm.CamoDesert_9MM_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet74_MAT.camo_9mm.CamoDesert_9MM_3P_Pickup_MIC")) 

//Stingray Infantry Heckler & Koch UMP
    Skins.Add((Id=9601, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HK_UMP', MIC_1P=("WEP_SkinSet75_MAT.diver_hk_ump.DiverVar1_HK_UMP_1P_Mint_MIC", "WEP_SkinSet75_MAT.diver_hk_ump.DiverVar1_HK_UMP_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet75_MAT.diver_hk_ump.DiverVar1_HK_UMP_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet75_MAT.diver_hk_ump.DiverVar1_HK_UMP_3P_Pickup_MIC")) 

//Stingray Navy Heckler & Koch UMP
    Skins.Add((Id=9602, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HK_UMP', MIC_1P=("WEP_SkinSet75_MAT.diver_hk_ump.DiverVar2_HK_UMP_1P_Mint_MIC", "WEP_SkinSet75_MAT.diver_hk_ump.DiverVar2_HK_UMP_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet75_MAT.diver_hk_ump.DiverVar2_HK_UMP_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet75_MAT.diver_hk_ump.DiverVar2_HK_UMP_3P_Pickup_MIC")) 

//Stingray Engineer Heckler & Koch UMP
    Skins.Add((Id=9603, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HK_UMP', MIC_1P=("WEP_SkinSet75_MAT.diver_hk_ump.DiverVar3_HK_UMP_1P_Mint_MIC", "WEP_SkinSet75_MAT.diver_hk_ump.DiverVar3_HK_UMP_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet75_MAT.diver_hk_ump.DiverVar3_HK_UMP_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet75_MAT.diver_hk_ump.DiverVar3_HK_UMP_3P_Pickup_MIC")) 

//Stingray Artillery Heckler & Koch UMP
    Skins.Add((Id=9604, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HK_UMP', MIC_1P=("WEP_SkinSet75_MAT.diver_hk_ump.DiverVar4_HK_UMP_1P_Mint_MIC", "WEP_SkinSet75_MAT.diver_hk_ump.DiverVar4_HK_UMP_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet75_MAT.diver_hk_ump.DiverVar4_HK_UMP_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet75_MAT.diver_hk_ump.DiverVar4_HK_UMP_3P_Pickup_MIC")) 

//Stingray Engineer Heckler & Koch UMP
    Skins.Add((Id=9605, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HK_UMP', MIC_1P=("WEP_SkinSet75_MAT.diver_hk_ump.DiverVar3_HK_UMP_1P_Mint_MIC", "WEP_SkinSet75_MAT.diver_hk_ump.DiverVar3_HK_UMP_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet75_MAT.diver_hk_ump.DiverVar3_HK_UMP_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet75_MAT.diver_hk_ump.DiverVar3_HK_UMP_3P_Pickup_MIC")) 

//Stingray Precious Heckler & Koch UMP
    Skins.Add((Id=9606, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HK_UMP', MIC_1P=("WEP_SkinSet75_MAT.diver_hk_ump.DiverPrecious_HK_UMP_1P_Mint_MIC", "WEP_SkinSet75_MAT.diver_hk_ump.DiverPrecious_HK_UMP_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet75_MAT.diver_hk_ump.DiverPrecious_HK_UMP_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet75_MAT.diver_hk_ump.DiverPrecious_HK_UMP_3P_Pickup_MIC")) 

//Stingray Infantry Hemoclobber
    Skins.Add((Id=9607, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MedicBat', MIC_1P=("WEP_SkinSet75_MAT.diver_medicbat.DiverVar1_MedicBat_1P_Mint_MIC"), MIC_3P="WEP_SkinSet75_MAT.diver_medicbat.DiverVar1_MedicBat_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet75_MAT.diver_medicbat.DiverVar1_MedicBat_3P_Pickup_MIC")) 

//Stingray Navy Hemoclobber
    Skins.Add((Id=9608, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MedicBat', MIC_1P=("WEP_SkinSet75_MAT.diver_medicbat.DiverVar2_MedicBat_1P_Mint_MIC"), MIC_3P="WEP_SkinSet75_MAT.diver_medicbat.DiverVar2_MedicBat_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet75_MAT.diver_medicbat.DiverVar2_MedicBat_3P_Pickup_MIC")) 

//Stingray Engineer Hemoclobber
    Skins.Add((Id=9609, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MedicBat', MIC_1P=("WEP_SkinSet75_MAT.diver_medicbat.DiverVar3_MedicBat_1P_Mint_MIC"), MIC_3P="WEP_SkinSet75_MAT.diver_medicbat.DiverVar3_MedicBat_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet75_MAT.diver_medicbat.DiverVar3_MedicBat_3P_Pickup_MIC")) 

//Stingray Artillery Hemoclobber
    Skins.Add((Id=9610, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MedicBat', MIC_1P=("WEP_SkinSet75_MAT.diver_medicbat.DiverVar4_MedicBat_1P_Mint_MIC"), MIC_3P="WEP_SkinSet75_MAT.diver_medicbat.DiverVar4_MedicBat_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet75_MAT.diver_medicbat.DiverVar4_MedicBat_3P_Pickup_MIC")) 

//Stingray Logistic Hemoclobber
    Skins.Add((Id=9611, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MedicBat', MIC_1P=("WEP_SkinSet75_MAT.diver_medicbat.DiverVar5_MedicBat_1P_Mint_MIC"), MIC_3P="WEP_SkinSet75_MAT.diver_medicbat.DiverVar5_MedicBat_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet75_MAT.diver_medicbat.DiverVar5_MedicBat_3P_Pickup_MIC")) 

//Stingray Precious Hemoclobber
    Skins.Add((Id=9612, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MedicBat', MIC_1P=("WEP_SkinSet75_MAT.diver_medicbat.DiverPrecious_MedicBat_1P_Mint_MIC"), MIC_3P="WEP_SkinSet75_MAT.diver_medicbat.DiverPrecious_MedicBat_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet75_MAT.diver_medicbat.DiverPrecious_MedicBat_3P_Pickup_MIC")) 

//Stingray Infantry SCAR
    Skins.Add((Id=9613, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_SCAR', MIC_1P=("WEP_SkinSet75_MAT.diver_scar.DiverVar1_SCAR_1P_Mint_MIC", "WEP_SkinSet75_MAT.diver_scar.DiverVar1_SCAR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet75_MAT.diver_scar.DiverVar1_SCAR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet75_MAT.diver_scar.DiverVar1_SCAR_3P_Pickup_MIC")) 

//Stingray Navy SCAR
    Skins.Add((Id=9614, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_SCAR', MIC_1P=("WEP_SkinSet75_MAT.diver_scar.DiverVar2_SCAR_1P_Mint_MIC", "WEP_SkinSet75_MAT.diver_scar.DiverVar2_SCAR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet75_MAT.diver_scar.DiverVar2_SCAR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet75_MAT.diver_scar.DiverVar2_SCAR_3P_Pickup_MIC")) 

//Stingray Engineer SCAR
    Skins.Add((Id=9615, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_SCAR', MIC_1P=("WEP_SkinSet75_MAT.diver_scar.DiverVar3_SCAR_1P_Mint_MIC", "WEP_SkinSet75_MAT.diver_scar.DiverVar3_SCAR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet75_MAT.diver_scar.DiverVar3_SCAR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet75_MAT.diver_scar.DiverVar3_SCAR_3P_Pickup_MIC")) 

//Stingray Artillery SCAR
    Skins.Add((Id=9616, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_SCAR', MIC_1P=("WEP_SkinSet75_MAT.diver_scar.DiverVar4_SCAR_1P_Mint_MIC", "WEP_SkinSet75_MAT.diver_scar.DiverVar4_SCAR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet75_MAT.diver_scar.DiverVar4_SCAR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet75_MAT.diver_scar.DiverVar4_SCAR_3P_Pickup_MIC")) 

//Stingray Logistic SCAR
    Skins.Add((Id=9617, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_SCAR', MIC_1P=("WEP_SkinSet75_MAT.diver_scar.DiverVar5_SCAR_1P_Mint_MIC", "WEP_SkinSet75_MAT.diver_scar.DiverVar5_SCAR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet75_MAT.diver_scar.DiverVar5_SCAR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet75_MAT.diver_scar.DiverVar5_SCAR_3P_Pickup_MIC")) 

//Stingray Precious SCAR
    Skins.Add((Id=9618, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_SCAR', MIC_1P=("WEP_SkinSet75_MAT.diver_scar.DiverPrecious_SCAR_1P_Mint_MIC", "WEP_SkinSet75_MAT.diver_scar.DiverPrecious_SCAR_Scope_1P_Mint_MIC"), MIC_3P="WEP_SkinSet75_MAT.diver_scar.DiverPrecious_SCAR_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet75_MAT.diver_scar.DiverPrecious_SCAR_3P_Pickup_MIC")) 

//Stingray Infantry M4
    Skins.Add((Id=9619, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_M4', MIC_1P=("WEP_SkinSet75_MAT.diver_m4.DiverVar1_M4_1P_Mint_MIC"), MIC_3P="WEP_SkinSet75_MAT.diver_m4.DiverVar1_M4_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet75_MAT.diver_m4.DiverVar1_M4_3P_Pickup_MIC")) 

//Stingray Navy M4
    Skins.Add((Id=9620, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_M4', MIC_1P=("WEP_SkinSet75_MAT.diver_m4.DiverVar2_M4_1P_Mint_MIC"), MIC_3P="WEP_SkinSet75_MAT.diver_m4.DiverVar2_M4_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet75_MAT.diver_m4.DiverVar2_M4_3P_Pickup_MIC")) 

//Stingray Engineer M4
    Skins.Add((Id=9621, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_M4', MIC_1P=("WEP_SkinSet75_MAT.diver_m4.DiverVar3_M4_1P_Mint_MIC"), MIC_3P="WEP_SkinSet75_MAT.diver_m4.DiverVar3_M4_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet75_MAT.diver_m4.DiverVar3_M4_3P_Pickup_MIC")) 

//Stingray Artillery M4
    Skins.Add((Id=9622, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_M4', MIC_1P=("WEP_SkinSet75_MAT.diver_m4.DiverVar4_M4_1P_Mint_MIC"), MIC_3P="WEP_SkinSet75_MAT.diver_m4.DiverVar4_M4_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet75_MAT.diver_m4.DiverVar4_M4_3P_Pickup_MIC")) 

//Stingray Logistic M4
    Skins.Add((Id=9623, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_M4', MIC_1P=("WEP_SkinSet75_MAT.diver_m4.DiverVar5_M4_1P_Mint_MIC"), MIC_3P="WEP_SkinSet75_MAT.diver_m4.DiverVar5_M4_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet75_MAT.diver_m4.DiverVar5_M4_3P_Pickup_MIC")) 

//Stingray Precious M4
    Skins.Add((Id=9624, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_M4', MIC_1P=("WEP_SkinSet75_MAT.diver_m4.DiverPrecious_M4_1P_Mint_MIC"), MIC_3P="WEP_SkinSet75_MAT.diver_m4.DiverPrecious_M4_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet75_MAT.diver_m4.DiverPrecious_M4_3P_Pickup_MIC")) 

//Stingray Infantry Desert Eagle
    Skins.Add((Id=9625, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet75_MAT.diver_deagle.DiverVar1_Deagle_1P_Mint_MIC"), MIC_3P="WEP_SkinSet75_MAT.diver_deagle.DiverVar1_Deagle_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet75_MAT.diver_deagle.DiverVar1_Deagle_3P_Pickup_MIC")) 

//Stingray Navy Desert Eagle
    Skins.Add((Id=9626, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet75_MAT.diver_deagle.DiverVar2_Deagle_1P_Mint_MIC"), MIC_3P="WEP_SkinSet75_MAT.diver_deagle.DiverVar2_Deagle_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet75_MAT.diver_deagle.DiverVar2_Deagle_3P_Pickup_MIC")) 

//Stingray Engineer Desert Eagle
    Skins.Add((Id=9627, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet75_MAT.diver_deagle.DiverVar3_Deagle_1P_Mint_MIC"), MIC_3P="WEP_SkinSet75_MAT.diver_deagle.DiverVar3_Deagle_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet75_MAT.diver_deagle.DiverVar3_Deagle_3P_Pickup_MIC")) 

//Stingray Artillery Desert Eagle
    Skins.Add((Id=9628, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet75_MAT.diver_deagle.DiverVar4_Deagle_1P_Mint_MIC"), MIC_3P="WEP_SkinSet75_MAT.diver_deagle.DiverVar4_Deagle_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet75_MAT.diver_deagle.DiverVar4_Deagle_3P_Pickup_MIC")) 

//Stingray Logistic Desert Eagle
    Skins.Add((Id=9629, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet75_MAT.diver_deagle.DiverVar5_Deagle_1P_Mint_MIC"), MIC_3P="WEP_SkinSet75_MAT.diver_deagle.DiverVar5_Deagle_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet75_MAT.diver_deagle.DiverVar5_Deagle_3P_Pickup_MIC")) 

//Stingray Precious Desert Eagle
    Skins.Add((Id=9630, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet75_MAT.diver_deagle.DiverPrecious_Deagle_1P_Mint_MIC"), MIC_3P="WEP_SkinSet75_MAT.diver_deagle.DiverPrecious_Deagle_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet75_MAT.diver_deagle.DiverPrecious_Deagle_3P_Pickup_MIC")) 

//Stingray Infantry Pulverizer
    Skins.Add((Id=9631, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Pulverizer', MIC_1P=("WEP_SkinSet75_MAT.diver_pulverizer.DiverVar1_Pulverizer_1P_Mint_MIC"), MIC_3P="WEP_SkinSet75_MAT.diver_pulverizer.DiverVar1_Pulverizer_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet75_MAT.diver_pulverizer.DiverVar1_Pulverizer_3P_Pickup_MIC")) 

//Stingray Navy Pulverizer
    Skins.Add((Id=9632, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Pulverizer', MIC_1P=("WEP_SkinSet75_MAT.diver_pulverizer.DiverVar2_Pulverizer_1P_Mint_MIC"), MIC_3P="WEP_SkinSet75_MAT.diver_pulverizer.DiverVar2_Pulverizer_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet75_MAT.diver_pulverizer.DiverVar2_Pulverizer_3P_Pickup_MIC")) 

//Stingray Engineer Pulverizer
    Skins.Add((Id=9633, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Pulverizer', MIC_1P=("WEP_SkinSet75_MAT.diver_pulverizer.DiverVar3_Pulverizer_1P_Mint_MIC"), MIC_3P="WEP_SkinSet75_MAT.diver_pulverizer.DiverVar3_Pulverizer_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet75_MAT.diver_pulverizer.DiverVar3_Pulverizer_3P_Pickup_MIC")) 

//Stingray Artillery Pulverizer
    Skins.Add((Id=9634, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Pulverizer', MIC_1P=("WEP_SkinSet75_MAT.diver_pulverizer.DiverVar4_Pulverizer_1P_Mint_MIC"), MIC_3P="WEP_SkinSet75_MAT.diver_pulverizer.DiverVar4_Pulverizer_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet75_MAT.diver_pulverizer.DiverVar4_Pulverizer_3P_Pickup_MIC")) 

//Stingray Logistic Pulverizer
    Skins.Add((Id=9635, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Pulverizer', MIC_1P=("WEP_SkinSet75_MAT.diver_pulverizer.DiverVar5_Pulverizer_1P_Mint_MIC"), MIC_3P="WEP_SkinSet75_MAT.diver_pulverizer.DiverVar5_Pulverizer_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet75_MAT.diver_pulverizer.DiverVar5_Pulverizer_3P_Pickup_MIC")) 

//Stingray Precious Pulverizer
    Skins.Add((Id=9636, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Pulverizer', MIC_1P=("WEP_SkinSet75_MAT.diver_pulverizer.DiverPrecious_Pulverizer_1P_Mint_MIC"), MIC_3P="WEP_SkinSet75_MAT.diver_pulverizer.DiverPrecious_Pulverizer_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet75_MAT.diver_pulverizer.DiverPrecious_Pulverizer_3P_Pickup_MIC")) 

//Contamination Zone Precious Healer
    Skins.Add((Id=9659, Weapondef=class'KFWeapDef_Healer', MIC_1P=("WEP_SkinSet77_MAT.contamination_healer.Contamination_Healer_1P_Mint_MIC"), MIC_3P="WEP_SkinSet77_MAT.contamination_healer.Contamination_Healer_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet77_MAT.contamination_healer.Contamination_Healer_3P_Pickup_MIC")) 
	
//Contamination Zone Precious Welder
    Skins.Add((Id=9658, Weapondef=class'KFWeapDef_Welder', MIC_1P=("WEP_SkinSet77_MAT.contamination_welder.Contamination_Welder_1P_Mint_MIC"), MIC_3P="WEP_SkinSet77_MAT.contamination_welder.Contamination_Welder_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet77_MAT.contamination_welder.Contamination_Welder_3P_Pickup_MIC")) 

//S12 Shockgun Standard
    Skins.Add((Id=9666, Weapondef=class'KFWeapDef_Shotgun_S12', MIC_1P=("WEP_1P_Saiga12_MAT.Wep_1stP_Saiga12_MIC"), MIC_3P="WEP_3P_Saiga12_MAT.WEP_3P_Saiga12_MIC", MIC_Pickup="WEP_3P_Saiga12_MAT.3P_Pickup_Saiga12_MIC"))

//S12 Shockgun Guppy
    Skins.Add((Id=9667, Weapondef=class'KFWeapDef_Shotgun_S12', MIC_1P=("WEP_SkinSet76_MAT.Wep_1stP_Saiga12_Guppy_MIC"), MIC_3P="WEP_SkinSet76_MAT.WEP_3P_Saiga12_Guppy_MIC", MIC_Pickup="WEP_SkinSet76_MAT.Weo_3P_Pickup_Saiga12_Guppy_MIC")) 

//S12 Shockgun Lux
    Skins.Add((Id=9668, Weapondef=class'KFWeapDef_Shotgun_S12', MIC_1P=("WEP_SkinSet76_MAT.Wep_1stP_Saiga12_Lux_MIC"), MIC_3P="WEP_SkinSet76_MAT.WEP_3P_Saiga12_Lux_MIC", MIC_Pickup="WEP_SkinSet76_MAT.Wep_3P_Pickup_Saiga12_Lux_MIC")) 

//S12 Shockgun Navy Camo
    Skins.Add((Id=9669, Weapondef=class'KFWeapDef_Shotgun_S12', MIC_1P=("WEP_SkinSet76_MAT.Wep_1stP_Saiga12_Ocean_MIC"), MIC_3P="WEP_SkinSet76_MAT.WEP_3P_Saiga12_Ocean_MIC", MIC_Pickup="WEP_SkinSet76_MAT.Wep_3P_Pickup_Saiga12_Ocean_MIC")) 

//S12 Shockgun Showstopper
    Skins.Add((Id=9670, Weapondef=class'KFWeapDef_Shotgun_S12', MIC_1P=("WEP_SkinSet76_MAT.Wep_1stP_Saiga12_Racing_MIC"), MIC_3P="WEP_SkinSet76_MAT.WEP_3P_Saiga12_Racing_MIC", MIC_Pickup="WEP_SkinSet76_MAT.Wep_3P_Pickup_Saiga12_Racing_MIC")) 

//S12 Shockgun Tiger
    Skins.Add((Id=9671, Weapondef=class'KFWeapDef_Shotgun_S12', MIC_1P=("WEP_SkinSet76_MAT.Wep_1stP_Saiga12_Tiger_MIC"), MIC_3P="WEP_SkinSet76_MAT.WEP_3P_Saiga12_Tiger_MIC", MIC_Pickup="WEP_SkinSet76_MAT.Wep_3P_Pickup_Saiga12_Tiger_MIC")) 

//MG3 Shredder Standard
    Skins.Add((Id=9755, Weapondef=class'KFWeapDef_MG3', MIC_1P=("wep_1p_mg3_mat.Wep_1stP_MG3_MIC"), MIC_3P="wep_3p_mg3_mat.Wep_3rdP_MG3_MIC", MIC_Pickup="wep_3p_mg3_mat.3P_Pickup_MG3_MIC"))

//MG3 Shredder Antique
    Skins.Add((Id=9756, Weapondef=class'KFWeapDef_MG3', MIC_1P=("wep_skinset82_mat.MG3_Antique_1P_MIC"), MIC_3P="WEP_SkinSet82_MAT.WEP_3P_MG3_Antique_MIC", MIC_Pickup="WEP_SkinSet82_MAT.WEP_3P_MG3_Antique_Pickup_MIC")) 

//MG3 Shredder Arctic
    Skins.Add((Id=9757, Weapondef=class'KFWeapDef_MG3', MIC_1P=("wep_skinset82_mat.MG3_Arctic_1P_MIC"), MIC_3P="WEP_SkinSet82_MAT.WEP_3P_MG3_Arctic_MIC", MIC_Pickup="WEP_SkinSet82_MAT.WEP_3P_MG3_Arctic_Pickup_MIC")) 

//MG3 Shredder Desert
    Skins.Add((Id=9758, Weapondef=class'KFWeapDef_MG3', MIC_1P=("wep_skinset82_mat.MG3_Desert_1P_MIC"), MIC_3P="WEP_SkinSet82_MAT.WEP_3P_MG3_Desert_MIC", MIC_Pickup="WEP_SkinSet82_MAT.WEP_3P_MG3_Desert_Pickup_MIC")) 

//MG3 Shredder Filigree
    Skins.Add((Id=9759, Weapondef=class'KFWeapDef_MG3', MIC_1P=("wep_skinset82_mat.MG3_Filigree_1P_MIC"), MIC_3P="WEP_SkinSet82_MAT.WEP_3P_MG3_Filigree_MIC", MIC_Pickup="WEP_SkinSet82_MAT.WEP_3P_MG3_Filigree_Pickup_MIC")) 

//MG3 Shredder Forest
    Skins.Add((Id=9760, Weapondef=class'KFWeapDef_MG3', MIC_1P=("wep_skinset82_mat.MG3_Forest_1P_MIC"), MIC_3P="WEP_SkinSet82_MAT.WEP_3P_MG3_Forest_MIC", MIC_Pickup="WEP_SkinSet82_MAT.WEP_3P_MG3_Forest_Pickup_MIC")) 

//Chameleon Dynamic 500 Magnum Revolver
    Skins.Add((Id=9674, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_SW500', MIC_1P=("WEP_SkinSet79_MAT.chameleon_sw500.Chameleon_SW500_1P_Mint_MIC"), MIC_3P="WEP_SkinSet79_MAT.chameleon_sw500.Chameleon_SW500_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet79_MAT.chameleon_sw500.Chameleon_SW500_3P_Pickup_MIC")) 

//Chameleon Dynamic Doomstick
    Skins.Add((Id=9675, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_ElephantGun', MIC_1P=("WEP_SkinSet79_MAT.chameleon_quadbarrel.Chameleon_QuadBarrel_Main_1P_Mint_MIC", "WEP_SkinSet79_MAT.chameleon_quadbarrel.Chameleon_QuadBarrel_Barrel_1P_Mint_MIC"), MIC_3P="WEP_SkinSet79_MAT.chameleon_quadbarrel.Chameleon_QuadBarrel_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet79_MAT.chameleon_quadbarrel.Chameleon_QuadBarrel_3P_Pickup_MIC")) 

//Chameleon Dynamic Hemoclobber
    Skins.Add((Id=9676, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MedicBat', MIC_1P=("WEP_SkinSet79_MAT.chameleon_medicbat.Chameleon_MedicBat_1P_Mint_MIC"), MIC_3P="WEP_SkinSet79_MAT.chameleon_medicbat.Chameleon_MedicBat_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet79_MAT.chameleon_medicbat.Chameleon_MedicBat_3P_Pickup_MIC")) 

//Chameleon Dynamic P90
    Skins.Add((Id=9677, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_P90', MIC_1P=("WEP_SkinSet79_MAT.chameleon_p90.Chameleon_P90_1P_Mint_MIC", "WEP_SkinSet79_MAT.chameleon_p90.Chameleon_P90_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet79_MAT.chameleon_p90.Chameleon_P90_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet79_MAT.chameleon_p90.Chameleon_P90_3P_Pickup_MIC")) 

//Chameleon Dynamic RGB 500 Magnum Revolver
    Skins.Add((Id=9678, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_SW500', MIC_1P=("WEP_SkinSet79_MAT.chameleonrgb_sw500.ChameleonRGB_SW500_1P_Mint_MIC"), MIC_3P="WEP_SkinSet79_MAT.chameleonrgb_sw500.ChameleonRGB_SW500_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet79_MAT.chameleonrgb_sw500.ChameleonRGB_SW500_3P_Pickup_MIC")) 

//Chameleon Dynamic RGB Doomstick
    Skins.Add((Id=9679, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_ElephantGun', MIC_1P=("WEP_SkinSet79_MAT.chameleonrgb_quadbarrel.ChameleonRGB_QuadBarrel_Main_1P_Mint_MIC", "WEP_SkinSet79_MAT.chameleonrgb_quadbarrel.ChameleonRGB_QuadBarrel_Barrel_1P_Mint_MIC"), MIC_3P="WEP_SkinSet79_MAT.chameleonrgb_quadbarrel.ChameleonRGB_QuadBarrel_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet79_MAT.chameleonrgb_quadbarrel.ChameleonRGB_QuadBarrel_3P_Pickup_MIC")) 

//Chameleon Dynamic RGB Hemoclobber
    Skins.Add((Id=9680, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MedicBat', MIC_1P=("WEP_SkinSet79_MAT.chameleonrgb_medicbat.ChameleonRGB_MedicBat_1P_Mint_MIC"), MIC_3P="WEP_SkinSet79_MAT.chameleonrgb_medicbat.ChameleonRGB_MedicBat_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet79_MAT.chameleonrgb_medicbat.ChameleonRGB_MedicBat_3P_Pickup_MIC")) 

//Chameleon Dynamic RGB P90
    Skins.Add((Id=9681, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_P90', MIC_1P=("WEP_SkinSet79_MAT.chameleonrgb_p90.ChameleonRGB_P90_1P_Mint_MIC", "WEP_SkinSet79_MAT.chameleonrgb_p90.ChameleonRGB_P90_Sight_1P_Mint_MIC"), MIC_3P="WEP_SkinSet79_MAT.chameleonrgb_p90.ChameleonRGB_P90_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet79_MAT.chameleonrgb_p90.ChameleonRGB_P90_3P_Pickup_MIC")) 

//Medieval Dynamic 500 Magnum Revolver
    Skins.Add((Id=9711, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_SW500', MIC_1P=("WEP_SkinSet80_MAT.medieval_sw500.Medieval_SW500_1P_Mint_MIC"), MIC_3P="WEP_SkinSet80_MAT.medieval_sw500.Medieval_SW500_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet80_MAT.medieval_sw500.Medieval_SW500_3P_Pickup_MIC")) 

//Medieval Dynamic Dragonsbreath
    Skins.Add((Id=9708, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Dragonsbreath', MIC_1P=("WEP_SkinSet80_MAT.medieval_dragonsbreath.Medieval_Dragonsbreath_1P_Mint_MIC"), MIC_3P="WEP_SkinSet80_MAT.medieval_dragonsbreath.Medieval_Dragonsbreath_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet80_MAT.medieval_dragonsbreath.Medieval_Dragonsbreath_3P_Pickup_MIC")) 

//Medieval Dynamic M79
    Skins.Add((Id=9709, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_M79', MIC_1P=("WEP_SkinSet80_MAT.medieval_m79.Medieval_M79_1P_Mint_MIC"), MIC_3P="WEP_SkinSet80_MAT.medieval_m79.Medieval_M79_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet80_MAT.medieval_m79.Medieval_M79_3P_Pickup_MIC")) 

//Medieval Dynamic Tommy Gun
    Skins.Add((Id=9710, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Thompson', MIC_1P=("WEP_SkinSet80_MAT.medieval_tommygun.Medieval_TommyGun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet80_MAT.medieval_tommygun.Medieval_TommyGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet80_MAT.medieval_tommygun.Medieval_TommyGun_3P_Pickup_MIC")) 

//Medieval Dynamic Precious 500 Magnum Revolver
    Skins.Add((Id=9712, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_SW500', MIC_1P=("WEP_SkinSet80_MAT.medievalgold_sw500.MedievalGold_SW500_1P_Mint_MIC"), MIC_3P="WEP_SkinSet80_MAT.medievalgold_sw500.MedievalGold_SW500_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet80_MAT.medievalgold_sw500.MedievalGold_SW500_3P_Pickup_MIC")) 

//Medieval Dynamic Precious Dragonsbreath
    Skins.Add((Id=9713, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Dragonsbreath', MIC_1P=("WEP_SkinSet80_MAT.medievalgold_dragonsbreath.MedievalGold_Dragonsbreath_1P_Mint_MIC"), MIC_3P="WEP_SkinSet80_MAT.medievalgold_dragonsbreath.MedievalGold_Dragonsbreath_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet80_MAT.medievalgold_dragonsbreath.MedievalGold_Dragonsbreath_3P_Pickup_MIC")) 

//Medieval Dynamic Precious M79
    Skins.Add((Id=9714, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_M79', MIC_1P=("WEP_SkinSet80_MAT.medievalgold_m79.MedievalGold_M79_1P_Mint_MIC"), MIC_3P="WEP_SkinSet80_MAT.medievalgold_m79.MedievalGold_M79_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet80_MAT.medievalgold_dragonsbreath.MedievalGold_M79_3P_Pickup_MIC")) 

//Medieval Dynamic Precious Tommy Gun
    Skins.Add((Id=9715, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Thompson', MIC_1P=("WEP_SkinSet80_MAT.medievalgold_tommygun.MedievalGold_TommyGun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet80_MAT.medievalgold_tommygun.MedievalGold_TommyGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet80_MAT.medievalgold_tommygun.MedievalGold_TommyGun_3P_Pickup_MIC")) 

//Spectre HRG 93R
    Skins.Add((Id=9682, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HRG_93R', MIC_1P=("WEP_SkinSet78_MAT.spectre_hrg93r.Spectre_HRG93R_1P_Mint_MIC"), MIC_3P="WEP_SkinSet78_MAT.spectre_hrg93r.Spectre_HRG93R_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet78_MAT.spectre_hrg93r.Spectre_HRG93R_3P_Pickup_MIC")) 

//Spectre HRG Ballistic Bouncer
    Skins.Add((Id=9683, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HRG_BallisticBouncer', MIC_1P=("WEP_SkinSet78_MAT.spectre_hrgballisticbouncer.Spectre_HRGBallisticBouncer_1P_Mint_MIC"), MIC_3P="WEP_SkinSet78_MAT.spectre_hrgballisticbouncer.Spectre_HRGBallisticBouncer_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet78_MAT.spectre_hrgballisticbouncer.Spectre_HRGBallisticBouncer_3P_Pickup_MIC")) 

//Spectre HRG Bastion
    Skins.Add((Id=9684, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HRG_BarrierRifle', MIC_1P=("WEP_SkinSet78_MAT.spectre_hrgbarrierrifle.Spectre_HRGBarrierRifle_1P_Mint_MIC", "WEP_SkinSet78_MAT.spectre_hrgbarrierrifle.Spectre_HRGBarrierRifle_Receiver_1P_Mint_MIC", "WEP_SkinSet78_MAT.spectre_hrgbarrierrifle.Spectre_HRGBarrierRifle_Extra_1P_Mint_MIC"), MIC_3P="WEP_SkinSet78_MAT.spectre_hrgbarrierrifle.Spectre_HRGBarrierRifle_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet78_MAT.spectre_hrgbarrierrifle.Spectre_HRGBarrierRifle_3P_Pickup_MIC")) 

//Spectre HRG Beluga Beat
    Skins.Add((Id=9685, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HRG_SonicGun', MIC_1P=("WEP_SkinSet78_MAT.spectre_hrgsonicgun.Spectre_HRGSonicGun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet78_MAT.spectre_hrgsonicgun.Spectre_HRGSonicGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet78_MAT.spectre_hrgsonicgun.Spectre_HRGSonicGun_3P_Pickup_MIC")) 

//Spectre HRG Blast Brawlers
    Skins.Add((Id=9686, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HRG_BlastBrawlers', MIC_1P=("WEP_SkinSet78_MAT.spectre_hrgblastbrawlers.Spectre_HRGBlastBrawlers_1P_Mint_MIC", "WEP_SkinSet78_MAT.spectre_hrgblastbrawlers.Spectre_HRGBlastBrawlers_Extra_1P_Mint_MIC"), MIC_3P="WEP_SkinSet78_MAT.spectre_hrgblastbrawlers.Spectre_HRGBlastBrawlers_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet78_MAT.spectre_hrgblastbrawlers.Spectre_HRGBlastBrawlers_3P_Pickup_MIC")) 

//Spectre HRG Crossboom
    Skins.Add((Id=9687, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HRG_Crossboom', MIC_1P=("WEP_SkinSet78_MAT.spectre_hrgcrossboom.Spectre_HRGCrossboom_1P_Mint_MIC"), MIC_3P="WEP_SkinSet78_MAT.spectre_hrgcrossboom.Spectre_HRGCrossboom_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet78_MAT.spectre_hrgcrossboom.Spectre_HRGCrossboom_3P_Pickup_MIC")) 

//Spectre HRG Disrupter
    Skins.Add((Id=9688, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HRG_Energy', MIC_1P=("WEP_SkinSet78_MAT.spectre_hrgenergy.Spectre_HRGEnergy_1P_Mint_MIC", "WEP_1P_HRG_Energy_MAT.Wep_Energy_Pistol_Optic_PM_MIC", "WEP_SkinSet78_MAT.spectre_hrgenergy.Spectre_HRGEnergy_Extra_1P_Mint_MIC"), MIC_3P="WEP_SkinSet78_MAT.spectre_hrgenergy.Spectre_HRGEnergy_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet78_MAT.spectre_hrgenergy.Spectre_HRGEnergy_3P_Pickup_MIC")) 

//Spectre HRG Dragonsblaze
    Skins.Add((Id=9689, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HRG_Dragonbreath', MIC_1P=("WEP_SkinSet78_MAT.spectre_hrgmegadragonsbreath.Spectre_HRGMegaDragonsbreath_1P_Mint_MIC", "WEP_SkinSet78_MAT.spectre_hrgmegadragonsbreath.Spectre_HRGMegaDragonsbreath_Barrel_1P_Mint_MIC", "WEP_SkinSet78_MAT.spectre_hrgmegadragonsbreath.Spectre_HRGMegaDragonsbreath_Loader_1P_Mint_MIC"), MIC_3P="WEP_SkinSet78_MAT.spectre_hrgmegadragonsbreath.Spectre_HRGMegaDragonsbreath_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet78_MAT.spectre_hrgmegadragonsbreath.Spectre_HRGMegaDragonsbreath_3P_Pickup_MIC")) 

//Spectre HRG Head Hunter
    Skins.Add((Id=9690, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HRG_CranialPopper', MIC_1P=("WEP_SkinSet78_MAT.spectre_hrgcranialpopper.Spectre_HRGCranialPopper_1P_Mint_MIC", "WEP_SkinSet78_MAT.spectre_hrgcranialpopper.Spectre_HRGCranialPopper_Optic_1P_Mint_MIC"), MIC_3P="WEP_SkinSet78_MAT.spectre_hrgcranialpopper.Spectre_HRGCranialPopper_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet78_MAT.spectre_hrgcranialpopper.Spectre_HRGCranialPopper_3P_Pickup_MIC")) 

//Spectre HRG Locust
    Skins.Add((Id=9691, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HRG_Locust', MIC_1P=("WEP_SkinSet78_MAT.spectre_hrglocust.Spectre_HRGLocust_1P_Mint_MIC", "WEP_SkinSet78_MAT.spectre_hrglocust.Spectre_HRGLocust_Optic_1P_Mint_MIC"), MIC_3P="WEP_SkinSet78_MAT.spectre_hrglocust.Spectre_HRGLocust_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet78_MAT.spectre_hrglocust.Spectre_HRGLocust_3P_Pickup_MIC")) 

//Spectre HRG Medic Missile
    Skins.Add((Id=9692, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HRG_MedicMissile', MIC_1P=("WEP_SkinSet78_MAT.spectre_hrgmedicmissile.Spectre_HRGMedicMissile_1P_Mint_MIC"), MIC_3P="WEP_SkinSet78_MAT.spectre_hrgmedicmissile.Spectre_HRGMedicMissile_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet78_MAT.spectre_hrgmedicmissile.Spectre_HRGMedicMissile_3P_Pickup_MIC")) 

//Spectre HRG Stunner
    Skins.Add((Id=9693, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HRG_Stunner', MIC_1P=("WEP_SkinSet78_MAT.spectre_hrgstunner.Spectre_HRGStunner_1P_Mint_MIC"), MIC_3P="WEP_SkinSet78_MAT.spectre_hrgstunner.Spectre_HRGStunner_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet78_MAT.spectre_hrgstunner.Spectre_HRGStunner_3P_Pickup_MIC")) 

//Spectre HRG Tommy Boom
    Skins.Add((Id=9694, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HRG_Boomy', MIC_1P=("WEP_SkinSet78_MAT.spectre_hrgboomy.Spectre_HRGBoomy_1P_Mint_MIC"), MIC_3P="WEP_SkinSet78_MAT.spectre_hrgboomy.Spectre_HRGBoomy_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet78_MAT.spectre_hrgboomy.Spectre_HRGBoomy_3P_Pickup_MIC")) 

//Spectre Chroma HRG 93R
    Skins.Add((Id=9695, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HRG_93R', MIC_1P=("WEP_SkinSet78_MAT.spectrechroma_hrg93r.SpectreChroma_HRG93R_1P_Mint_MIC"), MIC_3P="WEP_SkinSet78_MAT.spectrechroma_hrg93r.SpectreChroma_HRG93R_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet78_MAT.spectrechroma_hrg93r.SpectreChroma_HRG93R_3P_Pickup_MIC")) 

//Spectre Chroma HRG Ballistic Bouncer
    Skins.Add((Id=9696, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HRG_BallisticBouncer', MIC_1P=("WEP_SkinSet78_MAT.spectrechroma_hrgballisticbouncer.SpectreChroma_HRGBallisticBouncer_1P_Mint_MIC"), MIC_3P="WEP_SkinSet78_MAT.spectrechroma_hrgballisticbouncer.SpectreChroma_HRGBallisticBouncer_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet78_MAT.spectrechroma_hrgballisticbouncer.SpectreChroma_HRGBallisticBouncer_3P_Pickup_MIC")) 

//Spectre Chroma HRG Bastion
    Skins.Add((Id=9697, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HRG_BarrierRifle', MIC_1P=("WEP_SkinSet78_MAT.spectrechroma_hrgbarrierrifle.SpectreChroma_HRGBarrierRifle_1P_Mint_MIC", "WEP_SkinSet78_MAT.spectrechroma_hrgbarrierrifle.SpectreChroma_HRGBarrierRifle_Receiver_1P_Mint_MIC", "WEP_SkinSet78_MAT.spectrechroma_hrgbarrierrifle.SpectreChroma_HRGBarrierRifle_Extra_1P_Mint_MIC"), MIC_3P="WEP_SkinSet78_MAT.spectrechroma_hrgbarrierrifle.SpectreChroma_HRGBarrierRifle_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet78_MAT.spectrechroma_hrgbarrierrifle.SpectreChroma_HRGBarrierRifle_3P_Pickup_MIC")) 

//Spectre Chroma HRG Beluga Beat
    Skins.Add((Id=9698, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HRG_SonicGun', MIC_1P=("WEP_SkinSet78_MAT.spectrechroma_hrgsonicgun.SpectreChroma_HRGSonicGun_1P_Mint_MIC"), MIC_3P="WEP_SkinSet78_MAT.spectrechroma_hrgsonicgun.SpectreChroma_HRGSonicGun_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet78_MAT.spectrechroma_hrgsonicgun.SpectreChroma_HRGSonicGun_3P_Pickup_MIC")) 

//Spectre Chroma HRG Blast Brawlers
    Skins.Add((Id=9699, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HRG_BlastBrawlers', MIC_1P=("WEP_SkinSet78_MAT.spectrechroma_hrgblastbrawlers.SpectreChroma_HRGBlastBrawlers_1P_Mint_MIC", "WEP_SkinSet78_MAT.spectrechroma_hrgblastbrawlers.SpectreChroma_HRGBlastBrawlers_Extra_1P_Mint_MIC"), MIC_3P="WEP_SkinSet78_MAT.spectrechroma_hrgblastbrawlers.SpectreChroma_HRGBlastBrawlers_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet78_MAT.spectrechroma_hrgblastbrawlers.SpectreChroma_HRGBlastBrawlers_3P_Pickup_MIC")) 

//Spectre Chroma HRG Crossboom
    Skins.Add((Id=9700, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HRG_Crossboom', MIC_1P=("WEP_SkinSet78_MAT.spectrechroma_hrgcrossboom.SpectreChroma_HRGCrossboom_1P_Mint_MIC"), MIC_3P="WEP_SkinSet78_MAT.spectrechroma_hrgcrossboom.SpectreChroma_HRGCrossboom_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet78_MAT.spectrechroma_hrgcrossboom.SpectreChroma_HRGCrossboom_3P_Pickup_MIC")) 

//Spectre Chroma HRG Disrupter
    Skins.Add((Id=9701, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HRG_Energy', MIC_1P=("WEP_SkinSet78_MAT.spectrechroma_hrgenergy.SpectreChroma_HRGEnergy_1P_Mint_MIC", "WEP_1P_HRG_Energy_MAT.Wep_Energy_Pistol_Optic_PM_MIC", "WEP_SkinSet78_MAT.spectrechroma_hrgenergy.SpectreChroma_HRGEnergy_Extra_1P_Mint_MIC"), MIC_3P="WEP_SkinSet78_MAT.spectrechroma_hrgenergy.SpectreChroma_HRGEnergy_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet78_MAT.spectrechroma_hrgenergy.SpectreChroma_HRGEnergy_3P_Pickup_MIC")) 

//Spectre Chroma HRG Dragonsblaze
    Skins.Add((Id=9702, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HRG_Dragonbreath', MIC_1P=("WEP_SkinSet78_MAT.spectrechroma_hrgmegadragonsbreath.SpectreChroma_HRGMegaDragonsbreath_1P_Mint_MIC", "WEP_SkinSet78_MAT.spectrechroma_hrgmegadragonsbreath.SpectreChroma_HRGMegaDragonsbreath_Barrel_1P_Mint_MIC", "WEP_SkinSet78_MAT.spectrechroma_hrgmegadragonsbreath.SpectreChroma_HRGMegaDragonsbreath_Loader_1P_Mint_MIC"), MIC_3P="WEP_SkinSet78_MAT.spectrechroma_hrgmegadragonsbreath.SpectreChroma_HRGMegaDragonsbreath_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet78_MAT.spectrechroma_hrgmegadragonsbreath.SpectreChroma_HRGMegaDragonsbreath_3P_Pickup_MIC")) 

//Spectre Chroma HRG Head Hunter
    Skins.Add((Id=9703, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HRG_CranialPopper', MIC_1P=(  "WEP_SkinSet78_MAT.spectrechroma_hrgcranialpopper.SpectreChroma_HRGCranialPopper_1P_Mint_MIC", "WEP_SkinSet78_MAT.spectrechroma_hrgcranialpopper.SpectreChroma_HRGCranialPopper_Optic_1P_Mint_MIC"), MIC_3P="WEP_SkinSet78_MAT.spectrechroma_hrgcranialpopper.SpectreChroma_HRGCranialPopper_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet78_MAT.spectrechroma_hrgcranialpopper.SpectreChroma_HRGCranialPopper_3P_Pickup_MIC")) 

//Spectre Chroma HRG Locust
    Skins.Add((Id=9704, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HRG_Locust', MIC_1P=("WEP_SkinSet78_MAT.spectrechroma_hrglocust.SpectreChroma_HRGLocust_1P_Mint_MIC", "WEP_SkinSet78_MAT.spectrechroma_hrglocust.SpectreChroma_HRGLocust_Optic_1P_Mint_MIC"), MIC_3P="WEP_SkinSet78_MAT.spectrechroma_hrglocust.SpectreChroma_HRGLocust_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet78_MAT.spectrechroma_hrglocust.SpectreChroma_HRGLocust_3P_Pickup_MIC")) 

//Spectre Chroma HRG Medic Missile
    Skins.Add((Id=9705, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HRG_MedicMissile', MIC_1P=("WEP_SkinSet78_MAT.spectrechroma_hrgmedicmissile.SpectreChroma_HRGMedicMissile_1P_Mint_MIC"), MIC_3P="WEP_SkinSet78_MAT.spectrechroma_hrgmedicmissile.SpectreChroma_HRGMedicMissile_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet78_MAT.spectrechroma_hrgmedicmissile.SpectreChroma_HRGMedicMissile_3P_Pickup_MIC")) 

//Spectre Chroma HRG Stunner
    Skins.Add((Id=9706, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HRG_Stunner', MIC_1P=("WEP_SkinSet78_MAT.spectrechroma_hrgstunner.SpectreChroma_HRGStunner_1P_Mint_MIC"), MIC_3P="WEP_SkinSet78_MAT.spectrechroma_hrgstunner.SpectreChroma_HRGStunner_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet78_MAT.spectrechroma_hrgstunner.SpectreChroma_HRGStunner_3P_Pickup_MIC")) 

//Spectre Chroma HRG Tommy Boom
    Skins.Add((Id=9707, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_HRG_Boomy', MIC_1P=("WEP_SkinSet78_MAT.spectrechroma_hrgboomy.SpectreChroma_HRGBoomy_1P_Mint_MIC"), MIC_3P="WEP_SkinSet78_MAT.spectrechroma_hrgboomy.SpectreChroma_HRGBoomy_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet78_MAT.spectrechroma_hrgboomy.SpectreChroma_HRGBoomy_3P_Pickup_MIC")) 

//Bounty Hunt Deagle
    Skins.Add((Id=9753, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_Deagle', MIC_1P=("WEP_SkinSet81_MAT.BountyHunt.BountyHunt_Deagle_1P_Mint_MIC"), MIC_3P="WEP_SkinSet81_MAT.BountyHunt.BountyHunt_Deagle_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet81_MAT.BountyHunt.BountyHunt_Deagle_3P_Pickup_MIC")) 

//Voltar MKB42
    Skins.Add((Id=9754, bNeedsCodeUpdates = true, Weapondef=class'KFWeapDef_MKB42', MIC_1P=("WEP_SkinSet81_MAT.hans_mkb42.Hans_MKB42_1P_Mint_MIC"), MIC_3P="WEP_SkinSet81_MAT.hans_mkb42.Hans_MKB42_3P_Mint_MIC", MIC_Pickup="WEP_SkinSet81_MAT.hans_mkb42.Hans_MKB42_3P_Pickup_MIC")) 
}
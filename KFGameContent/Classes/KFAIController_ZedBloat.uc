//=============================================================================
// KFAIController_ZedBloat
//=============================================================================
// The mighty Bloat.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFAIController_ZedBloat extends KFAIController_Monster;

DefaultProperties
{
	// ---------------------------------------------
	// AI / Navigation
    bCanTeleportCloser=false
	SprintWithinEnemyRange=(X=520.f,Y=1200.f)
	EvadeGrenadeChance=0.6f

	// ---------------------------------------------
	// Combat
	bIsProbingMeleeRangeEvents=true
	bCanStrikeThroughEnemies=true
	LowIntensityAttackCooldown=3.0

	// ---------------------------------------------
	// Danger Evasion Settings
	DangerEvadeSettings.Empty
	DangerEvadeSettings(0)={(ClassName="KFProj_CaulkNBurn_GroundFire",
								Cooldowns=(3.0, 1.0, 1.0,  1.0), // Normal, Hard, Suicidal, HoE 
								EvadeChances=(0.2, 0.2, 0.3, 0.4),
								ReactionDelayRanges={((X=0.3, Y=0.5), (X=0.3, Y=0.5), (X=0.3, Y=0.5), (X=0.3, Y=0.5))},
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(1)={(ClassName="KFProj_FlameThrower_GroundFire",
								Cooldowns=(3.0, 1.0, 1.0,  1.0), // Normal, Hard, Suicidal, HoE  
								EvadeChances=(0.2, 0.2, 0.3, 0.4),
								ReactionDelayRanges={((X=0.3, Y=0.5), (X=0.3, Y=0.5), (X=0.3, Y=0.5), (X=0.3, Y=0.5))},
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(2)={(ClassName="KFWeap_Flame_CaulkBurn",
								Cooldowns=(2.5, 2.5, 2.5,  2.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.2, 0.2, 0.3, 0.4),
								ReactionDelayRanges={((X=0.3, Y=0.5), (X=0.3, Y=0.5), (X=0.3, Y=0.5), (X=0.3, Y=0.5))},
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(3)={(ClassName="KFWeap_Flame_Flamethrower",
							    Cooldowns=(2.5, 2.5, 2.5,  2.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.2, 0.2, 0.3, 0.4),
								ReactionDelayRanges={((X=0.3, Y=0.5), (X=0.3, Y=0.5), (X=0.3, Y=0.5), (X=0.3, Y=0.5))},
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(4)={(ClassName="KFWeap_Beam_Microwave",
							    Cooldowns=(2.5, 2.5, 2.5,  2.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.2, 0.2, 0.3, 0.4),
								ReactionDelayRanges={((X=0.3, Y=0.5), (X=0.3, Y=0.5), (X=0.3, Y=0.5), (X=0.3, Y=0.5))},
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(5)={(ClassName="KFProj_Flame_HRGIncendiaryRifle",
							    Cooldowns=(2.5, 2.5, 2.5,  2.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.2, 0.2, 0.3, 0.4),
								ReactionDelayRanges={((X=0.3, Y=0.5), (X=0.3, Y=0.5), (X=0.3, Y=0.5), (X=0.3, Y=0.5))},
								SoloChanceMultiplier=1.0)}

	//Aim Blocks
	DangerEvadeSettings(6)={(ClassName="KFWeap_Rifle_Winchester1894",
								Cooldowns=(0.5, 0.4, 0.3, 0.2), // Normal, Hard, Suicidal, HoE
								BlockChances=(0.1, 0.2, 0.7, 0.85))}
	DangerEvadeSettings(7)={(ClassName="KFWeap_Bow_Crossbow",
								Cooldowns=(0.5, 0.4, 0.3, 0.2), // Normal, Hard, Suicidal, HoE
								BlockChances=(0.1, 0.2, 0.7, 0.85))}
	DangerEvadeSettings(8)={(ClassName="KFWeap_Rifle_M14EBR",
								Cooldowns=(0.5, 0.4, 0.3, 0.2), // Normal, Hard, Suicidal, HoE
								BlockChances=(0.1, 0.2, 0.7, 0.85))}
	DangerEvadeSettings(9)={(ClassName="KFWeap_Rifle_RailGun",
								Cooldowns=(0.5, 0.4, 0.3, 0.2), // Normal, Hard, Suicidal, HoE
								BlockChances=(0.1, 0.2, 0.7, 0.85))}
	DangerEvadeSettings(10)={(ClassName="KFWeap_Bow_CompoundBow",
								Cooldowns=(0.5, 0.4, 0.3, 0.2), // Normal, Hard, Suicidal, HoE
								BlockChances=(0.1, 0.2, 0.7, 0.85))}
}
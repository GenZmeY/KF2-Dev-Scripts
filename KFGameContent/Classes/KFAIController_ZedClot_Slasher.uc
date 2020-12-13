//=============================================================================
// KFAIController_ZedClot_Slasher
//=============================================================================
// Slasher clot
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFAIController_ZedClot_Slasher extends KFAIController_ZedClot;

DefaultProperties
{
	// ---------------------------------------------
	// AI / Navigation
	SprintWithinEnemyRange=(X=120.f,Y=700.f)
	EvadeGrenadeChance=0.6f
	RunOverEvadeDelayScale=0.5f

	// ---------------------------------------------
	// Danger Evasion Settings
	DangerEvadeSettings.Empty

	DangerEvadeSettings(0)={(ClassName="KFProj_Bullet_Pellet",
								Cooldowns=(3.0, 1.0, 0.5, 0.1), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.1, 0.4, 0.75, 0.9),
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.00))},
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(1)={(ClassName="KFProj_Nail_Nailgun",
								Cooldowns=(3.0, 1.0, 0.5, 0.1), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.1, 0.4, 0.75, 0.9),
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.00))},
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(2)={(ClassName="KFProj_Bullet_DragonsBreath",
								Cooldowns=(3.0, 1.0, 0.5, 0.1), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.1, 0.4, 0.75, 0.9),
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.00))},
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(3)={(ClassName="KFProj_HighExplosive_M79",
								Cooldowns=(3.0, 1.0, 0.5, 0.1), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.1, 0.4, 0.75, 0.9),
								ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.05))},
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(4)={(ClassName="KFProj_HighExplosive_M32",
								Cooldowns=(3.0, 1.0, 0.5, 0.1), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.1, 0.4, 0.75, 0.9),
								ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.05))},
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(5)={(ClassName="KFProj_Rocket_RPG7",
								Cooldowns=(3.0, 1.0, 0.5, 0.1), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.1, 0.4, 0.75, 0.9),
								ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.05))},
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(6)={(ClassName="KFDT_Explosive_M16M203",
								Cooldowns=(3.0, 1.0, 0.1,  0.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.0, 0.5, 0.9, 1.0),
								ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.05))},
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(7)={(ClassName="KFDT_Explosive_HRGIncendiaryRifle",
								Cooldowns=(3.0, 1.0, 0.1,  0.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.0, 0.5, 0.9, 1.0),
								ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.05))},
								SoloChanceMultiplier=1.0)}


	//shooting fire
	DangerEvadeSettings(8)={(ClassName="KFProj_CaulkNBurn_GroundFire",
								Cooldowns=(3.0, 2.0, 1.5,  1.0), // Normal, Hard, Suicidal, HoE 
								EvadeChances=(0.4, 0.5, 0.6, 0.7),
								ReactionDelayRanges={((X=0.3, Y=0.5), (X=0.3, Y=0.5), (X=0.3, Y=0.5), (X=0.3, Y=0.5))},
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(9)={(ClassName="KFProj_FlameThrower_GroundFire",
								Cooldowns=(3.0, 2.0, 1.5,  1.0), // Normal, Hard, Suicidal, HoE  
								EvadeChances=(0.4, 0.5, 0.6, 0.7),
								ReactionDelayRanges={((X=0.3, Y=0.5), (X=0.3, Y=0.5), (X=0.3, Y=0.5), (X=0.3, Y=0.5))},
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(10)={(ClassName="KFWeap_Flame_CaulkBurn",
								Cooldowns=(3.0, 2.0, 1.5,  1.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.4, 0.5, 0.6, 0.7),
								ReactionDelayRanges={((X=0.3, Y=0.5), (X=0.3, Y=0.5), (X=0.3, Y=0.5), (X=0.3, Y=0.5))},
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(11)={(ClassName="KFWeap_Flame_Flamethrower",
							    Cooldowns=(3.0, 2.0, 1.5,  1.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.4, 0.5, 0.6, 0.7),
								ReactionDelayRanges={((X=0.3, Y=0.5), (X=0.3, Y=0.5), (X=0.3, Y=0.5), (X=0.3, Y=0.5))},
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(12)={(ClassName="KFWeap_Beam_Microwave",
							    Cooldowns=(3.0, 2.0, 1.5,  1.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.4, 0.5, 0.6, 0.7),
								ReactionDelayRanges={((X=0.3, Y=0.5), (X=0.3, Y=0.5), (X=0.3, Y=0.5), (X=0.3, Y=0.5))},
								SoloChanceMultiplier=1.0)}


    //Aimed weapons it dodges //sharpshooter
    DangerEvadeSettings(13)={(ClassName="KFWeap_Bow_Crossbow",
                                Cooldowns=(2.3, 2.3, 2.3, 1.3), // Normal, Hard, Suicidal, HoE
                                EvadeChances=(0.08, 0.1, 0.2, 0.35),
                                ForcedEvadeChances={((FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
                                ReactionDelayRanges={((X=0.0, Y=0.15), (X=0.0, Y=0.15), (X=0.0, Y=0.15), (X=0.0, Y=0.15))},
                                SoloChanceMultiplier=1.0)}  
    DangerEvadeSettings(14)={(ClassName="KFWeap_Rifle_M14EBR",
                                Cooldowns=(2.3, 2.3, 2.3, 1.3), // Normal, Hard, Suicidal, HoE
                                EvadeChances=(0.08, 0.1, 0.2, 0.35),
                                ForcedEvadeChances={((FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
                                ReactionDelayRanges={((X=0.0, Y=0.15), (X=0.0, Y=0.15), (X=0.0, Y=0.15), (X=0.0, Y=0.15))},
                                SoloChanceMultiplier=1.0)}
    DangerEvadeSettings(15)={(ClassName="KFWeap_Rifle_Winchester1894",
                                Cooldowns=(2.3, 2.3, 2.3, 1.3), // Normal, Hard, Suicidal, HoE
                                EvadeChances=(0.08, 0.1, 0.2, 0.35),
                                ForcedEvadeChances={((FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
                                ReactionDelayRanges={((X=0.0, Y=0.15), (X=0.0, Y=0.15), (X=0.0, Y=0.15), (X=0.0, Y=0.15))},
                                SoloChanceMultiplier=1.0)}
    DangerEvadeSettings(16)={(ClassName="KFWeap_Rifle_RailGun",
                                Cooldowns=(2.3, 2.3, 2.3, 1.3), // Normal, Hard, Suicidal, HoE
                                EvadeChances=(0.08, 0.1, 0.2, 0.35),
                                ForcedEvadeChances={((FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
                                ReactionDelayRanges={((X=0.0, Y=0.15), (X=0.0, Y=0.15), (X=0.0, Y=0.15), (X=0.0, Y=0.15))},
                                SoloChanceMultiplier=1.0)}

	//Grenades
	DangerEvadeSettings(17)={(ClassName="KFProj_FragGrenade",
								Cooldowns=(3.0, 1.0, 0.1, 0.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.1, 0.2, 0.5, 0.8),
								ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.05))},
								SoloChanceMultiplier=1.0)}	
	DangerEvadeSettings(18)={(ClassName="KFProj_MolotovGrenade",
								Cooldowns=(3.0, 1.0, 0.1, 0.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.1, 0.2, 0.5, 0.8),
								ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.05))},
								SoloChanceMultiplier=1.0)}	
	DangerEvadeSettings(19)={(ClassName="KFProj_DynamiteGrenade",
								Cooldowns=(3.0, 1.0, 0.1, 0.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.1, 0.2, 0.5, 0.8),
								ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.05))},
								SoloChanceMultiplier=1.0)}	
	DangerEvadeSettings(20)={(ClassName="KFProj_NailBombGrenade",
								Cooldowns=(3.0, 1.0, 0.1, 0.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.1, 0.2, 0.5, 0.8),
								ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.05))},
								SoloChanceMultiplier=1.0)}	
	DangerEvadeSettings(21)={(ClassName="KFProj_HEGrenade",
								Cooldowns=(3.0, 1.0, 0.1, 0.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.1, 0.2, 0.5, 0.8),
								ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.05))},
								SoloChanceMultiplier=1.0)}	

	// Ground Fire
	DangerEvadeSettings(22)={(ClassName="KFProj_Flame_HRGIncendiaryRifle",
								Cooldowns=(3.0, 2.0, 1.5,  1.0), // Normal, Hard, Suicidal, HoE 
								EvadeChances=(0.4, 0.5, 0.6, 0.7),
								ReactionDelayRanges={((X=0.3, Y=0.5), (X=0.3, Y=0.5), (X=0.3, Y=0.5), (X=0.3, Y=0.5))},
								SoloChanceMultiplier=1.0)}
}
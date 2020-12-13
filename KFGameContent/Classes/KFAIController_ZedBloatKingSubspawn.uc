//=============================================================================
// KFAIController_ZedBloatKingSubspawn
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================
// Base controller for the BK poop monster.  Streaks toward a target and
//		explodes its matter all over.
//=============================================================================

class KFAIController_ZedBloatKingSubspawn extends KFAIController_Monster;

/** Squared radius at which the poop monster will attempt to explode */
var const float ExplosionRadiusSq;

/** Cached pawn reference */
var KFPawn_ZedBloatKingSubspawn PoopPawn;

event Possess(Pawn inPawn, bool bVehicleTransition)
{
	super.Possess(inPawn, bVehicleTransition);

	PoopPawn = KFPawn_ZedBloatKingSubspawn(inPawn);
}

simulated function Tick(float DeltaTime)
{
	super.Tick(DeltaTime);

	if (Role == ROLE_Authority)
	{
		CheckMeleeTargetExplosion();
	}
}

//This guy never melees, skip this functionality
function bool CanDoStrike()
{
	return false;
}

function CheckMeleeTargetExplosion()
{
	local Vector ToTarget;
	if (Enemy == none || PoopPawn.IsDoingSpecialMove(SM_Custom1))
	{
		return;
	}

	ToTarget = Enemy.Location - MyKFPawn.Location;

	if (VSizeSq(ToTarget) < ExplosionRadiusSq)
	{
		if (PoopPawn != none)
		{
			class'AICommand_BloatKingSubspawn_Explode'.static.StartExplode(self);
		}
	}
}

defaultproperties
{
	ExplosionRadiusSq=62500 //300uu=3m squared for performance
	// ---------------------------------------------
	// Combat
	MeleeCommandClass=class'AICommand_Base_Zed'
	DefaultCommandClass=class'AICommand_Base_Zed'
	bIsProbingMeleeRangeEvents=true
	// ---------------------------------------------
	// AI / Navigation
	SprintWithinEnemyRange=(X=600.f,Y=1200.f)
	bEvadeOnRunOverWarning=true

	 // ---------------------------------------------
    // Danger Evasion Settings
	DangerEvadeSettings.Empty

	DangerEvadeSettings(0)={(ClassName="KFProj_Bullet_Pellet",
								Cooldowns=(3.0, 1.0, 0.1,  0.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.6, 0.5, 0.3, 0.2),
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.00))},
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(1)={(ClassName="KFProj_Nail_Nailgun",
								Cooldowns=(3.0, 1.0, 0.1,  0.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.6, 0.5, 0.3, 0.2),
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.00))},
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(2)={(ClassName="KFProj_Bullet_DragonsBreath",
								Cooldowns=(3.0, 1.0, 0.1,  0.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.6, 0.5, 0.3, 0.2),
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.00))},
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(3)={(ClassName="KFProj_HighExplosive_M79",
								Cooldowns=(3.0, 1.0, 0.1,  0.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.6, 0.5, 0.3, 0.2),
								ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.05))},
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(4)={(ClassName="KFProj_HighExplosive_M32",
								Cooldowns=(3.0, 1.0, 0.1,  0.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.6, 0.5, 0.3, 0.2),
								ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.05))},
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(5)={(ClassName="KFProj_Rocket_RPG7",
								Cooldowns=(3.0, 1.0, 0.1,  0.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.6, 0.5, 0.3, 0.2),
								ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.05))},
								SoloChanceMultiplier=1.0)}

	//shooting fire
	DangerEvadeSettings(6)={(ClassName="KFProj_CaulkNBurn_GroundFire",
								Cooldowns=(3.0, 1.0, 1.0,  1.0), // Normal, Hard, Suicidal, HoE 
								EvadeChances=(0.2, 0.2, 0.3, 0.4),
								ReactionDelayRanges={((X=0.3, Y=0.5), (X=0.3, Y=0.5), (X=0.3, Y=0.5), (X=0.3, Y=0.5))},
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(7)={(ClassName="KFProj_FlameThrower_GroundFire",
								Cooldowns=(3.0, 1.0, 1.0,  1.0), // Normal, Hard, Suicidal, HoE  
								EvadeChances=(0.2, 0.2, 0.3, 0.4),
								ReactionDelayRanges={((X=0.3, Y=0.5), (X=0.3, Y=0.5), (X=0.3, Y=0.5), (X=0.3, Y=0.5))},
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(8)={(ClassName="KFWeap_Flame_CaulkBurn",
								Cooldowns=(2.5, 2.5, 2.5,  2.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.2, 0.2, 0.3, 0.4),
								ReactionDelayRanges={((X=0.3, Y=0.5), (X=0.3, Y=0.5), (X=0.3, Y=0.5), (X=0.3, Y=0.5))},
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(9)={(ClassName="KFWeap_Flame_Flamethrower",
							    Cooldowns=(2.5, 2.5, 2.5,  2.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.2, 0.2, 0.3, 0.4),
								ReactionDelayRanges={((X=0.3, Y=0.5), (X=0.3, Y=0.5), (X=0.3, Y=0.5), (X=0.3, Y=0.5))},
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(10)={(ClassName="KFWeap_Beam_Microwave",
							    Cooldowns=(2.5, 2.5, 2.5,  2.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.2, 0.2, 0.3, 0.4),
								ReactionDelayRanges={((X=0.3, Y=0.5), (X=0.3, Y=0.5), (X=0.3, Y=0.5), (X=0.3, Y=0.5))},
								SoloChanceMultiplier=1.0)}

	//Grenades
	DangerEvadeSettings(11)={(ClassName="KFProj_FragGrenade",
								Cooldowns=(3.0, 1.0, 0.1,  0.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.2, 0.4, 0.6, 0.8),   
								ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
								ReactionDelayRanges={((X=0.0, Y=0.5), (X=0.0, Y=0.3), (X=0.0, Y=0.15), (X=0.0, Y=0.05))},
								SoloChanceMultiplier=1.0)}	
	DangerEvadeSettings(12)={(ClassName="KFProj_MolotovGrenade",
								Cooldowns=(3.0, 1.0, 0.1,  0.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.2, 0.4, 0.6, 0.8),
								ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
								ReactionDelayRanges={((X=0.0, Y=0.5), (X=0.0, Y=0.3), (X=0.0, Y=0.15), (X=0.0, Y=0.05))},
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(13)={(ClassName="KFProj_DynamiteGrenade",
								Cooldowns=(3.0, 1.0, 0.1,  0.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.2, 0.4, 0.6, 0.8),
								ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
								ReactionDelayRanges={((X=0.0, Y=0.5), (X=0.0, Y=0.3), (X=0.0, Y=0.15), (X=0.0, Y=0.05))},
								SoloChanceMultiplier=1.0)}	
	DangerEvadeSettings(14)={(ClassName="KFProj_NailBombGrenade",
								Cooldowns=(3.0, 1.0, 0.1,  0.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.2, 0.4, 0.6, 0.8),
								ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
								ReactionDelayRanges={((X=0.0, Y=0.5), (X=0.0, Y=0.3), (X=0.0, Y=0.15), (X=0.0, Y=0.05))},
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(15)={(ClassName="KFProj_HEGrenade",
								Cooldowns=(3.0, 1.0, 0.1,  0.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.2, 0.4, 0.6, 0.8),
								ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
								ReactionDelayRanges={((X=0.0, Y=0.5), (X=0.0, Y=0.3), (X=0.0, Y=0.15), (X=0.0, Y=0.05))},
								SoloChanceMultiplier=1.0)}

	// Ground Fire
	DangerEvadeSettings(16)={(ClassName="KFProj_Flame_HRGIncendiaryRifle",
								Cooldowns=(3.0, 1.0, 1.0,  1.0), // Normal, Hard, Suicidal, HoE 
								EvadeChances=(0.2, 0.2, 0.3, 0.4),
								ReactionDelayRanges={((X=0.3, Y=0.5), (X=0.3, Y=0.5), (X=0.3, Y=0.5), (X=0.3, Y=0.5))},
								SoloChanceMultiplier=1.0)}
}
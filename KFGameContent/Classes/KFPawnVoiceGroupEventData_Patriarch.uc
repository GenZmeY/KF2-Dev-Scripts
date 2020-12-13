//=============================================================================
// KFPawnVoiceGroupEventData_Patriarch
//=============================================================================
// Class that contains information about how/when dialog can be used
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFPawnVoiceGroupEventData_Patriarch extends KFPawnVoiceGroupEventData;

`include(KFGame/KFGameDialog.uci)

defaultproperties
{
	Events[`BOSS_TauntBase]=        (EventID=`BOSS_TauntBase,	    Priority=3, Weight=1, 	Chance=1.00,	CoolDownTime=20.00,							bCanBeMinimized=0,					bCanInterruptEqualPriority=true)
	Events[`BOSS_Taunt_LT50]=       (EventID=`BOSS_Taunt_LT50,	    Priority=3, Weight=1, 	Chance=1.00,	CoolDownTime=20.00, 						bCanBeMinimized=0)
	Events[`BOSS_Taunt_LT25]=       (EventID=`BOSS_Taunt_LT25,	    Priority=3, Weight=1, 	Chance=1.00,	CoolDownTime=20.00, 						bCanBeMinimized=0)
	Events[`BOSS_Challenge]=        (EventID=`BOSS_Challenge,	    Priority=2, Weight=1, 	Chance=1.00,	CoolDownTime=12.00,							bCanBeMinimized=0)
	Events[`BOSS_LoseTarget]=       (EventID=`BOSS_LoseTarget,	    Priority=2, Weight=1, 	Chance=1.00,	CoolDownTime=8.00,							bCanBeMinimized=0)

	// Not technically used as dialog, this is triggered by KFAnimNotify_ZedVoiceAkEvent with bTreatAsDialog set to true
	Events[`BOSS_Melee]=            (EventID=`BOSS_Melee,	        Priority=1, Weight=1, 	Chance=1.00,	CoolDownTime=0.00,							bCanBeMinimized=0)

	Events[`BOSS_TakeDmgBase]=      (EventID=`BOSS_TakeDmgBase,	    Priority=2, Weight=1, 	Chance=1.00,	CoolDownTime=3.00,							bCanBeMinimized=0)
	Events[`BOSS_TakeDmg_LT25]=     (EventID=`BOSS_TakeDmg_LT25,	Priority=2, Weight=1, 	Chance=1.00,	CoolDownTime=3.00,							bCanBeMinimized=0)
	Events[`BOSS_Death]=            (EventID=`BOSS_Death,	        Priority=1, Weight=1, 	Chance=1.00,	CoolDownTime=0.00,							bCanBeMinimized=0)
	Events[`BOSS_KillBase]=         (EventID=`BOSS_KillBase,	    Priority=1, Weight=1, 	Chance=1.00,	CoolDownTime=3.00,							bCanBeMinimized=0)
	Events[`BOSS_Jump]=             (EventID=`BOSS_Jump,	        Priority=2, Weight=1, 	Chance=1.00,	CoolDownTime=3.00,							bCanBeMinimized=0)
	Events[`BOSS_Land]=             (EventID=`BOSS_Land,	        Priority=2, Weight=1, 	Chance=1.00,	CoolDownTime=3.00,							bCanBeMinimized=0)

	// Minigun
	Events[`PATTY_MinigunWarn]=		(EventID=`PATTY_MinigunWarn, 	Priority=1, Weight=1, 	Chance=0.50,	CoolDownTime=0.00,							bCanBeMinimized=0)
	Events[`PATTY_MinigunAttack]=	(EventID=`PATTY_MinigunAttack,	Priority=1, Weight=1, 	Chance=1.00,	CoolDownTime=0.00,							bCanBeMinimized=0)
	Events[`PATTY_MinigunKill]=		(EventID=`PATTY_MinigunKill,	Priority=1, Weight=1, 	Chance=1.00,	CoolDownTime=3.00,							bCanBeMinimized=0)
	
	// Missile
	Events[`PATTY_MissileWarn]=		(EventID=`PATTY_MissileWarn,	Priority=1, Weight=1, 	Chance=0.50,	CoolDownTime=0.00,							bCanBeMinimized=0)
	Events[`PATTY_MissileKill]=		(EventID=`PATTY_MissileKill,	Priority=1, Weight=1, 	Chance=1.00,	CoolDownTime=3.00,							bCanBeMinimized=0)
	
	// Mortar
	Events[`PATTY_MortarWarn]=		(EventID=`PATTY_MortarWarn,		Priority=1, Weight=1, 	Chance=0.50,	CoolDownTime=6.00,							bCanBeMinimized=0)
	Events[`PATTY_MortarKill]=		(EventID=`PATTY_MortarKill,		Priority=1, Weight=1, 	Chance=1.00,	CoolDownTime=3.00,							bCanBeMinimized=0)

	// Tentacle
	Events[`BOSS_Grab]=             (EventID=`BOSS_Grab,	        Priority=1, Weight=1, 	Chance=0.90,	CoolDownTime=0.00,							bCanBeMinimized=0,					bCanInterruptEqualPriority=true)
	Events[`PATTY_TentaclePull]= 	(EventID=`PATTY_TentaclePull, 	Priority=1, Weight=1, 	Chance=1.00,	CoolDownTime=0.00,							bCanBeMinimized=0)
	Events[`PATTY_TentacleKill]= 	(EventID=`PATTY_TentacleKill,	Priority=1, Weight=1, 	Chance=1.00,	CoolDownTime=3.00,							bCanBeMinimized=0)

	// Leg kick
	Events[`PATTY_LegKick]=			(EventID=`PATTY_LegKick,		Priority=1, Weight=1, 	Chance=1.00,	CoolDownTime=5.00,							bCanBeMinimized=0)	

	// Charge attack
	Events[`PATTY_ChargeAttack]=	(EventID=`PATTY_ChargeAttack,	Priority=1, Weight=1, 	Chance=1.00,	CoolDownTime=5.00,							bCanBeMinimized=0)	

	// Whirlwind attack
	Events[`PATTY_WhirlwindAttack]=	(EventID=`PATTY_WhirlwindAttack,Priority=1, Weight=1, 	Chance=1.00,	CoolDownTime=5.00,							bCanBeMinimized=0)	

	// Paternal instinct
	Events[`PATTY_ChildKilled]=		(EventID=`PATTY_ChildKilled,	Priority=1, Weight=1, 	Chance=1.00,	CoolDownTime=3.00,							bCanBeMinimized=0,					bCanInterruptEqualPriority=true)

	// Flame panicked
	Events[`PATTY_OnFire]=			(EventID=`PATTY_OnFire,			Priority=1, Weight=1, 	Chance=1.00,	CoolDownTime=5.00,							bCanBeMinimized=0,					bCanInterruptEqualPriority=true)

	// Battle phases
	Events[`PATTY_NextBattlePhase1]= (EventID=`PATTY_NextBattlePhase1,Priority=1, Weight=1, 	Chance=1.00,	CoolDownTime=3.00,		Delay=0.f,			bCanBeMinimized=0)
	Events[`PATTY_NextBattlePhase2]= (EventID=`PATTY_NextBattlePhase2,Priority=1, Weight=1, 	Chance=1.00,	CoolDownTime=3.00,		Delay=0.f,			bCanBeMinimized=0)
	Events[`PATTY_NextBattlePhase3]= (EventID=`PATTY_NextBattlePhase3,Priority=1, Weight=1, 	Chance=1.00,	CoolDownTime=3.00,		Delay=0.f,			bCanBeMinimized=0)

	// Heal
	Events[`PATTY_Heal1]= 			(EventID=`PATTY_Heal1,			Priority=1, Weight=1, 	Chance=1.00,	CoolDownTime=3.00,		Delay=0.f,			bCanBeMinimized=0)
	Events[`PATTY_Heal2]= 			(EventID=`PATTY_Heal2,			Priority=1, Weight=1, 	Chance=1.00,	CoolDownTime=3.00,		Delay=0.f,			bCanBeMinimized=0)
	Events[`PATTY_Heal3]= 			(EventID=`PATTY_Heal3,			Priority=1, Weight=1, 	Chance=1.00,	CoolDownTime=3.00,		Delay=0.f,			bCanBeMinimized=0)
}
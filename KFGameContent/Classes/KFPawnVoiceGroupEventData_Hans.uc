//=============================================================================
// KFPawnVoiceGroupEventData_Hans
//=============================================================================
// Class that contains information about how/when dialog can be used
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Jeff Robinson
//=============================================================================

class KFPawnVoiceGroupEventData_Hans extends KFPawnVoiceGroupEventData;

`include(KFGame/KFGameDialog.uci)

defaultproperties
{
	Events[`BOSS_TauntBase]=        (EventID=`BOSS_TauntBase,	    Priority=3, Weight=1, 	Chance=0.25,	CoolDownTime=24.00,							bCanBeMinimized=0,					bCanInterruptEqualPriority=true)
	Events[`BOSS_Taunt_LT50]=       (EventID=`BOSS_Taunt_LT50,	    Priority=3, Weight=1, 	Chance=0.25,	CoolDownTime=24.00, 						bCanBeMinimized=0)
	Events[`BOSS_Taunt_LT25]=       (EventID=`BOSS_Taunt_LT25,	    Priority=3, Weight=1, 	Chance=0.25,	CoolDownTime=24.00, 						bCanBeMinimized=0)
	Events[`BOSS_Challenge]=        (EventID=`BOSS_Challenge,	    Priority=2, Weight=1, 	Chance=1.00,	CoolDownTime=6.00,							bCanBeMinimized=0)
	Events[`BOSS_LoseTarget]=       (EventID=`BOSS_LoseTarget,	    Priority=2, Weight=1, 	Chance=1.00,	CoolDownTime=6.00,							bCanBeMinimized=0)

	// Not technically used as dialog, this is triggered by KFAnimNotify_ZedVoiceAkEvent with bTreatAsDialog set to true
	Events[`BOSS_Melee]=            (EventID=`BOSS_Melee,	        Priority=1, Weight=1, 	Chance=1.00,	CoolDownTime=0.00,							bCanBeMinimized=0)

	// paralyze
	Events[`BOSS_Grab]=             (EventID=`BOSS_Grab,	        Priority=1, Weight=1, 	Chance=0.90,	CoolDownTime=0.00,							bCanBeMinimized=0,					bCanInterruptEqualPriority=true)
	// drain
	Events[`BOSS_Heal]=             (EventID=`BOSS_Heal,	        Priority=1, Weight=1, 	Chance=0.90,	CoolDownTime=0.00,		Delay=1.f,			bCanBeMinimized=0,					bCanInterruptEqualPriority=true)

	Events[`BOSS_TakeDmgBase]=      (EventID=`BOSS_TakeDmgBase,	    Priority=2, Weight=1, 	Chance=1.00,	CoolDownTime=1.00,							bCanBeMinimized=0)
	Events[`BOSS_TakeDmg_LT25]=     (EventID=`BOSS_TakeDmg_LT25,	Priority=2, Weight=1, 	Chance=1.00,	CoolDownTime=1.00,							bCanBeMinimized=0)
	Events[`BOSS_Death]=            (EventID=`BOSS_Death,	        Priority=1, Weight=1, 	Chance=1.00,	CoolDownTime=0.00,							bCanBeMinimized=0)
	Events[`BOSS_KillBase]=         (EventID=`BOSS_KillBase,	    Priority=1, Weight=1, 	Chance=1.00,	CoolDownTime=3.00,							bCanBeMinimized=0)
	Events[`BOSS_Jump]=             (EventID=`BOSS_Jump,	        Priority=2, Weight=1, 	Chance=1.00,	CoolDownTime=0.00,							bCanBeMinimized=0)
	Events[`BOSS_Land]=             (EventID=`BOSS_Land,	        Priority=2, Weight=1, 	Chance=1.00,	CoolDownTime=0.00,							bCanBeMinimized=0)

	Events[`HANS_Taunt_LT25_RO2]=   (EventID=`HANS_Taunt_LT25_RO2,	Priority=3, Weight=1, 	Chance=0.25,	CoolDownTime=24.00,							bCanBeMinimized=0)
	Events[`HANS_SprintToward]=     (EventID=`HANS_SprintToward,	Priority=2, Weight=1, 	Chance=0.50,	CoolDownTime=6.00,		Radius=1000.00,		bCanBeMinimized=0,					bCanInterruptEqualPriority=true)
	Events[`HANS_DrawGuns]=         (EventID=`HANS_DrawGuns,	    Priority=1, Weight=1, 	Chance=0.50,	CoolDownTime=0.00,							bCanBeMinimized=0)
	Events[`HANS_DmgGuns]=          (EventID=`HANS_DmgGuns,	        Priority=2, Weight=1, 	Chance=0.30,	CoolDownTime=5.00,							bCanBeMinimized=0)
	Events[`HANS_KillGuns]=         (EventID=`HANS_KillGuns,	    Priority=1, Weight=1, 	Chance=1.00,	CoolDownTime=0.00,							bCanBeMinimized=0)
	Events[`HANS_Frenzy]=           (EventID=`HANS_Frenzy,	        Priority=1, Weight=1, 	Chance=1.00,	CoolDownTime=0.00,							bCanBeMinimized=0)
	Events[`HANS_KillFrenzy]=       (EventID=`HANS_KillFrenzy,	    Priority=1, Weight=1, 	Chance=1.00,	CoolDownTime=0.00,							bCanBeMinimized=0)
	Events[`HANS_GasToss]=          (EventID=`HANS_GasToss,	        Priority=1, Weight=1, 	Chance=0.50,	CoolDownTime=3.00,							bCanBeMinimized=0)
	Events[`HANS_GasBarrage]=       (EventID=`HANS_GasBarrage,	    Priority=1, Weight=1, 	Chance=1.00,	CoolDownTime=0.00,							bCanBeMinimized=0)
	Events[`HANS_KillGas]=          (EventID=`HANS_KillGas,	        Priority=1, Weight=1, 	Chance=1.00,	CoolDownTime=0.00,							bCanBeMinimized=0)
	Events[`HANS_SmokeToss]=        (EventID=`HANS_SmokeToss,	    Priority=2, Weight=1, 	Chance=1.00,	CoolDownTime=3.00,							bCanBeMinimized=0)
	Events[`HANS_SmokeBarrage]=     (EventID=`HANS_SmokeBarrage,	Priority=1, Weight=1, 	Chance=1.00,	CoolDownTime=0.00,							bCanBeMinimized=0,					bCanInterruptEqualPriority=true)
	Events[`HANS_HuntTaunt]=        (EventID=`HANS_HuntTaunt,	    Priority=2, Weight=1, 	Chance=0.50,	CoolDownTime=8.00,							bCanBeMinimized=0,					bCanInterruptEqualPriority=true)
	Events[`HANS_NadeToss]=         (EventID=`HANS_NadeToss,	    Priority=1, Weight=1, 	Chance=1.00,	CoolDownTime=3.00,							bCanBeMinimized=0)
	Events[`HANS_NadeBarrage]=      (EventID=`HANS_NadeBarrage,	    Priority=1, Weight=1, 	Chance=1.00,	CoolDownTime=0.00,							bCanBeMinimized=0)
	Events[`HANS_KillNade]=         (EventID=`HANS_KillNade,	    Priority=1, Weight=1, 	Chance=1.00,	CoolDownTime=3.00,							bCanBeMinimized=0)

	Events[`HANS_NextBattlePhase1]= (EventID=`HANS_NextBattlePhase1,Priority=1, Weight=1, 	Chance=1.00,	CoolDownTime=3.00,		Delay=0.f,			bCanBeMinimized=0)
	Events[`HANS_NextBattlePhase2]= (EventID=`HANS_NextBattlePhase2,Priority=1, Weight=1, 	Chance=1.00,	CoolDownTime=3.00,		Delay=0.f,			bCanBeMinimized=0)
	Events[`HANS_NextBattlePhase3]= (EventID=`HANS_NextBattlePhase3,Priority=1, Weight=1, 	Chance=1.00,	CoolDownTime=3.00,		Delay=0.f,			bCanBeMinimized=0)
	Events[`HANS_AOE]= 				(EventID=`HANS_AOE,				Priority=1, Weight=1, 	Chance=0.50,	CoolDownTime=3.00,		Delay=0.f,			bCanBeMinimized=0)

	//@todo: These always play (are never interrupted), so they function more as ambient audio than dialog (triggered in KFPawn_ZedHans::PostBeginPlay/TakeDamage/HealDamage),
	// but that could change if it's annoying
	//Events[`HANS_AmbBreathe]=       (EventID=`HANS_AmbBreathe,	    Priority=5, Weight=1, 	Chance=100.00,	CoolDownTime=0.00)
	//Events[`HANS_AmbBreathe_LT25]=	(EventID=`HANS_AmbBreathe_LT25, Priority=5, Weight=1, 	Chance=100.00,	CoolDownTime=0.00)
}

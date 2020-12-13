//=============================================================================
// KFPawnVoiceGroupEventData_Matriarch
//=============================================================================
// Class that contains information about how/when dialog can be used
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================

class KFPawnVoiceGroupEventData_Matriarch extends KFPawnVoiceGroupEventData;

`include(KFGame/KFGameDialog.uci)

defaultproperties
{
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

	Events[`MATTY_Taunt_Phase1]={(
		EventID=`MATTY_Taunt_Phase1,
		Priority=3,
		Weight=1,
		Chance=1,
		CooldownTime=20,
		bCanBeMinimized=0
	)}
	Events[`MATTY_Taunt_Phase2]={(
		EventID=`MATTY_Taunt_Phase2,
		Priority=3,
		Weight=1,
		Chance=1,
		CooldownTime=20,
		bCanBeMinimized=0
	)}
	Events[`MATTY_Taunt_Phase3]={(
		EventID=`MATTY_Taunt_Phase3,
		Priority=3,
		Weight=1,
		Chance=1,
		CooldownTime=20,
		bCanBeMinimized=0
	)}
	Events[`MATTY_TauntPilotCompartDestroyed]={(
		EventID=`MATTY_TauntPilotCompartDestroyed,
		Priority=0,
		Weight=1,
		Chance=1,
		CooldownTime=3,
		bCanBeMinimized=0
	)}
	Events[`MATTY_TauntPowerClawDestroyed]={(
		EventID=`MATTY_TauntPowerClawDestroyed,
		Priority=0,
		Weight=1,
		Chance=1,
		CooldownTime=3,
		bCanBeMinimized=0
	)}
	Events[`MATTY_NextBattlePhase1]={(
		EventID=`MATTY_NextBattlePhase1,
		Priority=0,
		Weight=1,
		Chance=1,
		CooldownTime=3,
		bCanBeMinimized=0,
		bCanInterruptEqualPriority=true
	)}
	Events[`MATTY_NextBattlePhase2]={(
		EventID=`MATTY_NextBattlePhase2,
		Priority=0,
		Weight=1,
		Chance=1,
		CooldownTime=3,
		bCanBeMinimized=0,
		bCanInterruptEqualPriority=true
	)}
	Events[`MATTY_NextBattlePhase3]={(
		EventID=`MATTY_NextBattlePhase3,
		Priority=0,
		Weight=1,
		Chance=1,
		CooldownTime=3,
		bCanBeMinimized=0,
		bCanInterruptEqualPriority=true
	)}
	Events[`MATTY_DeadEDAR]={(
		EventID=`MATTY_DeadEDAR,
		Priority=1,
		Weight=1,
		Chance=1,
		CooldownTime=10,
		bCanBeMinimized=0
	)}
	Events[`MATTY_ScorpionWhipWarning]={(
		EventID=`MATTY_ScorpionWhipWarning,
		Priority=1,
		Weight=1,
		Chance=1,
		CooldownTime=0,
		bCanBeMinimized=0
	)}
	Events[`MATTY_ScorpionWhipAttack]={(
		EventID=`MATTY_ScorpionWhipAttack,
		Priority=1,
		Weight=1,
		Chance=1,
		CooldownTime=0,
		bCanBeMinimized=0,
		bCanInterruptEqualPriority=true
	)}
	//This is not used
	Events[`MATTY_ScorpionWhipKill]={(
		EventID=`MATTY_ScorpionWhipKill,
		Priority=3,
		Weight=1,
		Chance=0,
		CooldownTime=0,
		bCanBeMinimized=0
	)}
	Events[`MATTY_TeslaBlastWarning]={(
		EventID=`MATTY_TeslaBlastWarning,
		Priority=1,
		Weight=1,
		Chance=1.0,
		CooldownTime=0,
		bCanBeMinimized=0,
		bCanInterruptEqualPriority=true
	)}
	Events[`MATTY_TeslaBlastKill]={(
		EventID=`MATTY_TeslaBlastKill,
		Priority=1,
		Weight=1,
		Chance=1,
		CooldownTime=0,
		bCanBeMinimized=0,
		bCanInterruptEqualPriority=true
	)}
	//This is not used
	Events[`MATTY_SweepingClawAttack]={(
		EventID=`MATTY_SweepingClawAttack,
		Priority=3,
		Weight=1,
		Chance=0,
		CooldownTime=0,
		bCanBeMinimized=0
	)}
	//This is not used
	Events[`MATTY_SweepingClawKill]={(
		EventID=`MATTY_SweepingClawKill,
		Priority=3,
		Weight=1,
		Chance=0,
		CooldownTime=0,
		bCanBeMinimized=0
	)}
	Events[`MATTY_PlasmaCannonWarning]={(
		EventID=`MATTY_PlasmaCannonWarning,
		Priority=1,
		Weight=1,
		Chance=1.0,
		CooldownTime=0,
		bCanBeMinimized=0,
		bCanInterruptEqualPriority=true
	)}
	//This is not used
	Events[`MATTY_PlasmaCannonAttack]={(
		EventID=`MATTY_PlasmaCannonAttack,
		Priority=3,
		Weight=1,
		Chance=0,
		CooldownTime=0,
		bCanBeMinimized=0
	)}
	Events[`MATTY_PlasmaCannonKill]={(
		EventID=`MATTY_PlasmaCannonKill,
		Priority=1,
		Weight=1,
		Chance=1,
		CooldownTime=3,
		bCanBeMinimized=0,
		bCanInterruptEqualPriority=true
	)}
	Events[`MATTY_LightningStormWarning]={(
		EventID=`MATTY_LightningStormWarning,
		Priority=1,
		Weight=1,
		Chance=1,
		CooldownTime=0,
		bCanBeMinimized=0,
		bCanInterruptEqualPriority=true
	)}
	Events[`MATTY_LightningStormKill]={(
		EventID=`MATTY_LightningStormKill,
		Priority=1,
		Weight=1,
		Chance=1,
		CooldownTime=3,
		bCanBeMinimized=0,
		bCanInterruptEqualPriority=true
	)}
	Events[`MATTY_WarningSirenWarning]={(
		EventID=`MATTY_WarningSirenWarning,
		Priority=1,
		Weight=1,
		Chance=1,
		CooldownTime=0,
		bCanBeMinimized=0
	)}
	Events[`MATTY_WarningSirenKill]={(
		EventID=`MATTY_WarningSirenKill,
		Priority=1,
		Weight=1,
		Chance=1,
		CooldownTime=3,
		bCanBeMinimized=0,
		bCanInterruptEqualPriority=true
	)}
	// This is not used
	Events[`MATTY_ShieldActivate]={(
		EventID=`MATTY_ShieldActivate,
		Priority=3,
		Weight=1,
		Chance=0,
		CooldownTime=3,
		bCanBeMinimized=0
	)}
	// This is not used
	Events[`MATTY_Cloak]={(
		EventID=`MATTY_Cloak,
		Priority=3,
		Weight=1,
		Chance=0,
		CooldownTime=0,
		bCanBeMinimized=0
	)}
	// This is not used
	Events[`MATTY_ChargeAttack]={(
		EventID=`MATTY_ChargeAttack,
		Priority=3,
		Weight=1,
		Chance=0,
		CooldownTime=0,
		bCanBeMinimized=0
	)}
	Events[`MATTY_OnFire]={(
		EventID=`MATTY_OnFire,
		Priority=1,
		Weight=1,
		Chance=1,
		CooldownTime=5,
		bCanBeMinimized=0,
		bCanInterruptEqualPriority=true
	)}
	Events[`MATTY_Taunt_Phase4]={(
		EventID=`MATTY_Taunt_Phase4,
		Priority=3,
		Weight=1,
		Chance=1,
		CooldownTime=20,
		bCanBeMinimized=0
	)}
}

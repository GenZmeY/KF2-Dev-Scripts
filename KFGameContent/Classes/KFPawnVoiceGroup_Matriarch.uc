class KFPawnVoiceGroup_Matriarch extends KFPawnVoiceGroup;

`include(KFGame/KFGameDialog.uci)

defaultproperties
{
	EventDataClass=class'KFPawnVoiceGroupEventData_Matriarch'

	//DialogEvents[`BOSS_TauntBase]=(DefaultAudioCue=AkEvent'WW_VOX_Matriarch.Play_VOX_MAT_Taunt_Base')
	//DialogEvents[`BOSS_Taunt_LT50]=(DefaultAudioCue=AkEvent'WW_VOX_CHR_Patriarch.Play_Patriarch_Taunt_50')
	//DialogEvents[`BOSS_Taunt_LT25]=(DefaultAudioCue=AkEvent'WW_VOX_CHR_Patriarch.Play_Patriarch_Taunt_25')
	DialogEvents[`BOSS_Challenge]=(DefaultAudioCue=AkEvent'WW_VOX_Matriarch.Play_VOX_MAT_Challenge_Base')
	DialogEvents[`BOSS_LoseTarget]=(DefaultAudioCue=AkEvent'WW_VOX_Matriarch.Play_VOX_MAT_LostSight_Base')

	// Not technically used as dialog, this is triggered by KFAnimNotify_ZedVoiceAkEvent with bTreatAsDialog set to true
	//DialogEvents[`BOSS_Melee]=(DefaultAudioCue=AkEvent'WW_VOX_NPC_HansVolter.Play_HANS_Melee_Base')

	//DialogEvents[`BOSS_TakeDmgBase]=(DefaultAudioCue=AkEvent'WW_VOX_Matriarch.Play_VOX_MAT_HurtLight_Base')
	DialogEvents[`BOSS_TakeDmg_LT25]=(DefaultAudioCue=AkEvent'WW_VOX_Matriarch.Play_VOX_MAT_HurtBad_Base')
	DialogEvents[`BOSS_Death]=(DefaultAudioCue=AkEvent'WW_VOX_Matriarch.Play_VOX_MAT_Death_Base')
	DialogEvents[`BOSS_KillBase]=(DefaultAudioCue=AkEvent'WW_VOX_Matriarch.Play_VOX_MAT_KillPlayer_Base')
	DialogEvents[`BOSS_Jump]=(DefaultAudioCue=AkEvent'WW_VOX_Matriarch.Play_VOX_MAT_Jump_Base')
	DialogEvents[`BOSS_Land]=(DefaultAudioCue=AkEvent'WW_VOX_Matriarch.Play_VOX_MAT_Landing_Base')

	DialogEvents[`MATTY_Taunt_Phase1]=(DefaultAudioCue=AkEvent'WW_VOX_Matriarch.Play_VOX_MAT_Taunt_Base')
	DialogEvents[`MATTY_Taunt_Phase2]=(DefaultAudioCue=AkEvent'WW_VOX_Matriarch.Play_VOX_MAT_TauntP2_Base')
	DialogEvents[`MATTY_Taunt_Phase3]=(DefaultAudioCue=AkEvent'WW_VOX_Matriarch.Play_VOX_MAT_TauntP3_Base')
	DialogEvents[`MATTY_TauntPilotCompartDestroyed]=(DefaultAudioCue=AkEvent'WW_VOX_Matriarch.Play_VOX_MAT_TauntPilotCompartDestroyed_Base')
	DialogEvents[`MATTY_TauntPowerClawDestroyed]=(DefaultAudioCue=AkEvent'WW_VOX_Matriarch.Play_VOX_MAT_TauntPowerClawDestroyed_Base')
	DialogEvents[`MATTY_NextBattlePhase1]=(DefaultAudioCue=AkEvent'WW_VOX_Matriarch.Play_VOX_MAT_TauntP2Start_Base')
	DialogEvents[`MATTY_NextBattlePhase2]=(DefaultAudioCue=AkEvent'WW_VOX_Matriarch.Play_VOX_MAT_TauntP3Start_Base')
	DialogEvents[`MATTY_NextBattlePhase3]=(DefaultAudioCue=AkEvent'WW_VOX_Matriarch.Play_VOX_MAT_TauntP4Start_Base')
	DialogEvents[`MATTY_DeadEDAR]=(DefaultAudioCue=AkEvent'WW_VOX_Matriarch.Play_VOX_MAT_DeadEDAR_Base')
	DialogEvents[`MATTY_ScorpionWhipWarning]=(DefaultAudioCue=AkEvent'WW_VOX_Matriarch.Play_VOX_MAT_ScorpionWhipWarning_Base')
	DialogEvents[`MATTY_ScorpionWhipAttack]=(DefaultAudioCue=AkEvent'WW_VOX_Matriarch.Play_VOX_MAT_ScorpionWhipAttack_Base')
	DialogEvents[`MATTY_ScorpionWhipKill]=(DefaultAudioCue=AkEvent'WW_VOX_Matriarch.Play_VOX_MAT_ScorpionWhipKill_Base')
	DialogEvents[`MATTY_TeslaBlastWarning]=(DefaultAudioCue=AkEvent'WW_VOX_Matriarch.Play_VOX_MAT_TeslaBlastWarning_Base')
	DialogEvents[`MATTY_TeslaBlastKill]=(DefaultAudioCue=AkEvent'WW_VOX_Matriarch.Play_VOX_MAT_TeslaBlastKill_Base')
	DialogEvents[`MATTY_SweepingClawAttack]=(DefaultAudioCue=AkEvent'WW_VOX_Matriarch.Play_VOX_MAT_SweepingClawAttack_Base')
	DialogEvents[`MATTY_SweepingClawKill]=(DefaultAudioCue=AkEvent'WW_VOX_Matriarch.Play_VOX_MAT_SweepingClawKill_Base')
	DialogEvents[`MATTY_PlasmaCannonWarning]=(DefaultAudioCue=AkEvent'WW_VOX_Matriarch.Play_VOX_MAT_PlasmaCannonWarning_Base')
	DialogEvents[`MATTY_PlasmaCannonAttack]=(DefaultAudioCue=AkEvent'WW_VOX_Matriarch.Play_VOX_MAT_PlasmaCannonAttack_Base')
	DialogEvents[`MATTY_PlasmaCannonKill]=(DefaultAudioCue=AkEvent'WW_VOX_Matriarch.Play_VOX_MAT_PlasmaCannonKill_Base')
	DialogEvents[`MATTY_LightningStormWarning]=(DefaultAudioCue=AkEvent'WW_VOX_Matriarch.Play_VOX_MAT_LightningStrikeWarning_Base')
	DialogEvents[`MATTY_LightningStormKill]=(DefaultAudioCue=AkEvent'WW_VOX_Matriarch.Play_VOX_MAT_LightningStrikeKill_Base')
	DialogEvents[`MATTY_WarningSirenWarning]=(DefaultAudioCue=AkEvent'WW_VOX_Matriarch.Play_VOX_MAT_WarningSirenWarning_Base')
	DialogEvents[`MATTY_WarningSirenKill]=(DefaultAudioCue=AkEvent'WW_VOX_Matriarch.Play_VOX_MAT_WarningSirenKill_Base')
	DialogEvents[`MATTY_ShieldActivate]=(DefaultAudioCue=AkEvent'WW_VOX_Matriarch.Play_VOX_MAT_ShieldActivate_Base')
	DialogEvents[`MATTY_Cloak]=(DefaultAudioCue=AkEvent'WW_VOX_Matriarch.Play_VOX_MAT_Cloak_Base')
	DialogEvents[`MATTY_ChargeAttack]=(DefaultAudioCue=AkEvent'WW_VOX_Matriarch.Play_VOX_MAT_ChargeAttack_Base')
	DialogEvents[`MATTY_OnFire]=(DefaultAudioCue=AkEvent'WW_VOX_Matriarch.Play_VOX_MAT_OnFire_Base')
	DialogEvents[`MATTY_Taunt_Phase4]=(DefaultAudioCue=AkEvent'WW_VOX_Matriarch.Play_VOX_MAT_TauntP4_Base')

`if(`notdefined(ShippingPC))
	//DialogEventNames[`BOSS_TauntBase]					=BOSS_TauntBase
	//DialogEventNames[`BOSS_Taunt_LT50]					=BOSS_Taunt_LT50
	//DialogEventNames[`BOSS_Taunt_LT25]					=BOSS_Taunt_LT25
	DialogEventNames[`BOSS_Challenge]					=BOSS_Challenge
	DialogEventNames[`BOSS_LoseTarget]					=BOSS_LoseTarget
	DialogEventNames[`BOSS_Melee]						=BOSS_Melee
	DialogEventNames[`BOSS_Grab]						=BOSS_Grab
	DialogEventNames[`BOSS_TakeDmgBase]					=BOSS_TakeDmgBase
	DialogEventNames[`BOSS_TakeDmg_LT25]				=BOSS_TakeDmg_LT25
	DialogEventNames[`BOSS_Death]						=BOSS_Death
	DialogEventNames[`BOSS_KillBase]            		=BOSS_KillBase
	DialogEventNames[`BOSS_Jump]						=BOSS_Jump
	DialogEventNames[`BOSS_Land]						=BOSS_Land

	DialogEventNames[`MATTY_Taunt_Phase1]				=MATTY_Taunt_Phase1
	DialogEventNames[`MATTY_Taunt_Phase2]				=MATTY_Taunt_Phase2
	DialogEventNames[`MATTY_Taunt_Phase3]				=MATTY_Taunt_Phase3
	DialogEventNames[`MATTY_TauntPilotCompartDestroyed]	=MATTY_TauntPilotCompartDestroyed
	DialogEventNames[`MATTY_TauntPowerClawDestroyed]	=MATTY_TauntPowerClawDestroyed
	DialogEventNames[`MATTY_NextBattlePhase1]			=MATTY_NextBattlePhase1
	DialogEventNames[`MATTY_NextBattlePhase2]			=MATTY_NextBattlePhase2
	DialogEventNames[`MATTY_NextBattlePhase3]			=MATTY_NextBattlePhase3
	DialogEventNames[`MATTY_DeadEDAR]					=MATTY_DeadEDAR
	DialogEventNames[`MATTY_ScorpionWhipWarning]		=MATTY_ScorpionWhipWarning
	DialogEventNames[`MATTY_ScorpionWhipAttack]			=MATTY_ScorpionWhipAttack
	DialogEventNames[`MATTY_ScorpionWhipKill]			=MATTY_ScorpionWhipKill
	DialogEventNames[`MATTY_TeslaBlastWarning]			=MATTY_TeslaBlastWarning
	DialogEventNames[`MATTY_TeslaBlastKill]				=MATTY_TeslaBlastKill
	DialogEventNames[`MATTY_SweepingClawAttack]			=MATTY_SweepingClawAttack
	DialogEventNames[`MATTY_SweepingClawKill]			=MATTY_SweepingClawKill
	DialogEventNames[`MATTY_PlasmaCannonWarning]		=MATTY_PlasmaCannonWarning
	DialogEventNames[`MATTY_PlasmaCannonAttack]			=MATTY_PlasmaCannonAttack
	DialogEventNames[`MATTY_PlasmaCannonKill]			=MATTY_PlasmaCannonKill
	DialogEventNames[`MATTY_LightningStormWarning]		=MATTY_LightningStormWarning
	DialogEventNames[`MATTY_LightningStormKill]			=MATTY_LightningStormKill
	DialogEventNames[`MATTY_WarningSirenWarning]		=MATTY_WarningSirenWarning
	DialogEventNames[`MATTY_WarningSirenKill]			=MATTY_WarningSirenKill
	DialogEventNames[`MATTY_ShieldActivate]				=MATTY_ShieldActivate
	DialogEventNames[`MATTY_Cloak]						=MATTY_Cloak
	DialogEventNames[`MATTY_ChargeAttack]				=MATTY_ChargeAttack
	DialogEventNames[`MATTY_OnFire]						=MATTY_OnFire
	DialogEventNames[`MATTY_Taunt_Phase4]				=MATTY_Taunt_Phase4
`endif
}

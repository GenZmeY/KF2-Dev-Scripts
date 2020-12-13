class KFPawnVoiceGroup_Patriarch extends KFPawnVoiceGroup;

`include(KFGame/KFGameDialog.uci)

defaultproperties
{
	EventDataClass=class'KFPawnVoiceGroupEventData_Patriarch'

	DialogEvents[`BOSS_TauntBase]=(DefaultAudioCue=AkEvent'WW_VOX_CHR_Patriarch.Play_Patriarch_Taunt')
	DialogEvents[`BOSS_Taunt_LT50]=(DefaultAudioCue=AkEvent'WW_VOX_CHR_Patriarch.Play_Patriarch_Taunt_50')
	DialogEvents[`BOSS_Taunt_LT25]=(DefaultAudioCue=AkEvent'WW_VOX_CHR_Patriarch.Play_Patriarch_Taunt_25')
	DialogEvents[`BOSS_Challenge]=(DefaultAudioCue=AkEvent'WW_VOX_CHR_Patriarch.Play_Patriarch_Challenge')
	DialogEvents[`BOSS_LoseTarget]=(DefaultAudioCue=AkEvent'WW_VOX_CHR_Patriarch.Play_Patriarch_Lost_Sight')

	// Not technically used as dialog, this is triggered by KFAnimNotify_ZedVoiceAkEvent with bTreatAsDialog set to true
	DialogEvents[`BOSS_Melee]=(DefaultAudioCue=AkEvent'WW_VOX_NPC_HansVolter.Play_HANS_Melee_Base')

	DialogEvents[`BOSS_TakeDmgBase]=(DefaultAudioCue=AkEvent'WW_VOX_CHR_Patriarch.Play_Patriarch_Hurt_Light')
	DialogEvents[`BOSS_TakeDmg_LT25]=(DefaultAudioCue=AkEvent'WW_VOX_CHR_Patriarch.Play_Patriarch_Hurt_Bad')
	DialogEvents[`BOSS_Death]=(DefaultAudioCue=AkEvent'WW_VOX_CHR_Patriarch.Play_Patriarch_Death')
	DialogEvents[`BOSS_KillBase]=(DefaultAudioCue=AkEvent'WW_VOX_CHR_Patriarch.Play_Patriarch_Kill_Player')
	DialogEvents[`BOSS_Jump]=(DefaultAudioCue=AkEvent'WW_VOX_CHR_Patriarch.Play_Patriarch_Jump')
	DialogEvents[`BOSS_Land]=(DefaultAudioCue=AkEvent'WW_VOX_CHR_Patriarch.Play_Patriarch_Landing')

	// Minigun
	DialogEvents[`PATTY_MinigunWarn]=(DefaultAudioCue=AkEvent'WW_VOX_CHR_Patriarch.Play_Patriarch_Minigun_Warn')
	DialogEvents[`PATTY_MinigunAttack]=(DefaultAudioCue=AkEvent'WW_VOX_CHR_Patriarch.Play_Patriarch_Minigun_Attack')
	DialogEvents[`PATTY_MinigunKill]=(DefaultAudioCue=AkEvent'WW_VOX_CHR_Patriarch.Play_Patriarch_Minigun_Kill')

	// Missile
	DialogEvents[`PATTY_MissileWarn]=(DefaultAudioCue=AkEvent'WW_VOX_CHR_Patriarch.Play_Patriarch_Missile_Warn')
	DialogEvents[`PATTY_MissileKill]=(DefaultAudioCue=AkEvent'WW_VOX_CHR_Patriarch.Play_Patriarch_Missile_Kill')

	// Mortar
	DialogEvents[`PATTY_MortarWarn]=(DefaultAudioCue=AkEvent'WW_VOX_CHR_Patriarch.Play_Patriarch_Mortar_Warn')
	DialogEvents[`PATTY_MortarKill]=(DefaultAudioCue=AkEvent'WW_VOX_CHR_Patriarch.Play_Patriarch_Mortar_Kill')

	// Tentacle
	DialogEvents[`BOSS_Grab]=(DefaultAudioCue=AkEvent'WW_VOX_CHR_Patriarch.Play_Patriarch_Tentacle_Attack')
	DialogEvents[`PATTY_TentaclePull]=(DefaultAudioCue=AkEvent'WW_VOX_CHR_Patriarch.Play_Patriarch_Tentacle_Pull')
	DialogEvents[`PATTY_TentacleKill]=(DefaultAudioCue=AkEvent'WW_VOX_CHR_Patriarch.Play_Patriarch_Tentacle_Kill')

	// Leg kick
	DialogEvents[`PATTY_LegKick]=(DefaultAudioCue=AkEvent'WW_VOX_CHR_Patriarch.Play_Patriarch_Leg_Kick')	

	// Charge
	DialogEvents[`PATTY_ChargeAttack]=(DefaultAudioCue=AkEvent'WW_VOX_CHR_Patriarch.Play_Patriarch_Charge_Attack')	

	// Whirlwind
	DialogEvents[`PATTY_WhirlwindAttack]=(DefaultAudioCue=AkEvent'WW_VOX_CHR_Patriarch.Play_Patriarch_Whirlwind_Slash')	

	// Paternal instinct
	DialogEvents[`PATTY_ChildKilled]=(DefaultAudioCue=AkEvent'WW_VOX_CHR_Patriarch.Play_Patriarch_Dead_Children')

	// Flame panicked
	DialogEvents[`PATTY_OnFire]=(DefaultAudioCue=AkEvent'WW_VOX_CHR_Patriarch.Play_Patriarch_On_Fire')

	// Battle phase taunts
	DialogEvents[`PATTY_NextBattlePhase1]=(DefaultAudioCue=AkEvent'WW_VOX_CHR_Patriarch.Play_Patriarch_Cloak_1')
	DialogEvents[`PATTY_NextBattlePhase2]=(DefaultAudioCue=AkEvent'WW_VOX_CHR_Patriarch.Play_Patriarch_Cloak_2')
	DialogEvents[`PATTY_NextBattlePhase3]=(DefaultAudioCue=AkEvent'WW_VOX_CHR_Patriarch.Play_Patriarch_Cloak_3')

	// Heal
	DialogEvents[`PATTY_Heal1]=(DefaultAudioCue=AkEvent'WW_VOX_CHR_Patriarch.Play_Patriarch_Heal_1')
	DialogEvents[`PATTY_Heal2]=(DefaultAudioCue=AkEvent'WW_VOX_CHR_Patriarch.Play_Patriarch_Heal_2')
	DialogEvents[`PATTY_Heal3]=(DefaultAudioCue=AkEvent'WW_VOX_CHR_Patriarch.Play_Patriarch_Heal_3')

`if(`notdefined(ShippingPC))	
	DialogEventNames[`BOSS_TauntBase]				=BOSS_TauntBase      
	DialogEventNames[`BOSS_Taunt_LT50]				=BOSS_Taunt_LT50     
	DialogEventNames[`BOSS_Taunt_LT25]				=BOSS_Taunt_LT25     
	DialogEventNames[`BOSS_Challenge]				=BOSS_Challenge      
	DialogEventNames[`BOSS_LoseTarget]				=BOSS_LoseTarget     
	DialogEventNames[`BOSS_Melee]					=BOSS_Melee          
	DialogEventNames[`BOSS_Grab]					=BOSS_Grab           
	DialogEventNames[`BOSS_TakeDmgBase]				=BOSS_TakeDmgBase    
	DialogEventNames[`BOSS_TakeDmg_LT25]			=BOSS_TakeDmg_LT25   
	DialogEventNames[`BOSS_Death]					=BOSS_Death          
	DialogEventNames[`BOSS_KillBase]            	=BOSS_KillBase    
	DialogEventNames[`BOSS_Jump]					=BOSS_Jump           
	DialogEventNames[`BOSS_Land]					=BOSS_Land           
	DialogEventNames[`PATTY_MinigunWarn]			=PATTY_MinigunWarn
	DialogEventNames[`PATTY_MinigunAttack]			=PATTY_MinigunAttack
	DialogEventNames[`PATTY_MinigunKill]			=PATTY_MinigunKill
	DialogEventNames[`PATTY_MissileWarn]			=PATTY_MissileWarn
	DialogEventNames[`PATTY_MissileKill]			=PATTY_MissileKill
	DialogEventNames[`PATTY_MortarWarn]				=PATTY_MortarWarn
	DialogEventNames[`PATTY_MortarKill]				=PATTY_MortarKill
	DialogEventNames[`PATTY_TentaclePull]			=PATTY_TentaclePull
	DialogEventNames[`PATTY_TentacleKill]			=PATTY_TentacleKill
	DialogEventNames[`PATTY_LegKick]				=PATTY_LegKick
	DialogEventNames[`PATTY_ChargeAttack]			=PATTY_ChargeAttack
	DialogEventNames[`PATTY_WhirlwindAttack]		=PATTY_WhirlwindAttack
	DialogEventNames[`PATTY_ChildKilled]			=PATTY_ChildKilled
	DialogEventNames[`PATTY_NextBattlePhase1]		=PATTY_NextBattlePhase1
	DialogEventNames[`PATTY_NextBattlePhase2]		=PATTY_NextBattlePhase2
	DialogEventNames[`PATTY_NextBattlePhase3]		=PATTY_NextBattlePhase3
	DialogEventNames[`PATTY_OnFire]					=PATTY_OnFire
	DialogEventNames[`PATTY_Heal1]					=PATTY_Heal1
	DialogEventNames[`PATTY_Heal2]					=PATTY_Heal2
	DialogEventNames[`PATTY_Heal3]					=PATTY_Heal3
`endif
}
class KFPawnVoiceGroup_Hans extends KFPawnVoiceGroup;

`include(KFGame/KFGameDialog.uci)

defaultproperties
{
	EventDataClass=class'KFPawnVoiceGroupEventData_Hans'

	DialogEvents[`BOSS_TauntBase]=(DefaultAudioCue=AkEvent'WW_VOX_NPC_HansVolter.Play_HANS_Taunt_Base')
	DialogEvents[`BOSS_Taunt_LT50]=(DefaultAudioCue=AkEvent'WW_VOX_NPC_HansVolter.Play_HANS_Taunt50_Base')
	DialogEvents[`BOSS_Taunt_LT25]=(DefaultAudioCue=AkEvent'WW_VOX_NPC_HansVolter.Play_HANS_Taunt25_Base')
	DialogEvents[`BOSS_Challenge]=(DefaultAudioCue=AkEvent'WW_VOX_NPC_HansVolter.Play_HANS_Challenge_Base')
	DialogEvents[`BOSS_LoseTarget]=(DefaultAudioCue=AkEvent'WW_VOX_NPC_HansVolter.Play_HANS_LostSight_Base')
	DialogEvents[`BOSS_Melee]=(DefaultAudioCue=AkEvent'WW_VOX_NPC_HansVolter.Play_HANS_Melee_Base')
	DialogEvents[`BOSS_Grab]=(DefaultAudioCue=AkEvent'WW_VOX_NPC_HansVolter.Play_HANS_Paralyze_Base')
	DialogEvents[`BOSS_Heal]=(DefaultAudioCue=AkEvent'WW_VOX_NPC_HansVolter.Play_HANS_DrawLife_Base')
	DialogEvents[`BOSS_TakeDmgBase]=(DefaultAudioCue=AkEvent'WW_VOX_NPC_HansVolter.Play_HANS_HurtLight_Base')
	DialogEvents[`BOSS_TakeDmg_LT25]=(DefaultAudioCue=AkEvent'WW_VOX_NPC_HansVolter.Play_HANS_HurtBad_Base')
	DialogEvents[`BOSS_Death]=(DefaultAudioCue=AkEvent'WW_VOX_NPC_HansVolter.Play_HANS_Death_Base')
	DialogEvents[`BOSS_KillBase]=(DefaultAudioCue=AkEvent'WW_VOX_NPC_HansVolter.Play_HANS_KillPlayer_Base')
	DialogEvents[`BOSS_Jump]=(DefaultAudioCue=AkEvent'WW_VOX_NPC_HansVolter.Play_HANS_Jump_Base')
	DialogEvents[`BOSS_Land]=(DefaultAudioCue=AkEvent'WW_VOX_NPC_HansVolter.Play_HANS_Landing_Base')

	DialogEvents[`HANS_Taunt_LT25_RO2]=(DefaultAudioCue=AkEvent'WW_VOX_NPC_HansVolter.Play_HANS_TauntG_Base')
	DialogEvents[`HANS_SprintToward]=(DefaultAudioCue=AkEvent'WW_VOX_NPC_HansVolter.Play_HANS_SprintAttack_Base')
	DialogEvents[`HANS_DrawGuns]=(DefaultAudioCue=AkEvent'WW_VOX_NPC_HansVolter.Play_HANS_DrawMkB_Base')
	DialogEvents[`HANS_DmgGuns]=(DefaultAudioCue=AkEvent'WW_VOX_NPC_HansVolter.Play_HANS_MkBDamage_Base')
	DialogEvents[`HANS_KillGuns]=(DefaultAudioCue=AkEvent'WW_VOX_NPC_HansVolter.Play_HANS_MkBKill_Base')
	DialogEvents[`HANS_Frenzy]=(DefaultAudioCue=AkEvent'WW_VOX_NPC_HansVolter.Play_HANS_Frenzy_Base')
	DialogEvents[`HANS_KillFrenzy]=(DefaultAudioCue=AkEvent'WW_VOX_NPC_HansVolter.Play_HANS_FrenzyKill_Base')
	DialogEvents[`HANS_GasToss]=(DefaultAudioCue=AkEvent'WW_VOX_NPC_HansVolter.Play_HANS_Nerve2_Base')
	DialogEvents[`HANS_GasBarrage]=(DefaultAudioCue=AkEvent'WW_VOX_NPC_HansVolter.Play_HANS_NerveBarrage_Base')
	DialogEvents[`HANS_KillGas]=(DefaultAudioCue=AkEvent'WW_VOX_NPC_HansVolter.Play_HANS_NerveKill_Base')
	DialogEvents[`HANS_SmokeToss]=(DefaultAudioCue=AkEvent'WW_VOX_NPC_HansVolter.Play_HANS_Smoke2_Base')
	DialogEvents[`HANS_SmokeBarrage]=(DefaultAudioCue=AkEvent'WW_VOX_NPC_HansVolter.Play_HANS_SmokeZeds_Base')
	DialogEvents[`HANS_HuntTaunt]=(DefaultAudioCue=AkEvent'WW_VOX_NPC_HansVolter.Play_HANS_HuntTaunt_Base')
	DialogEvents[`HANS_NadeToss]=(DefaultAudioCue=AkEvent'WW_VOX_NPC_HansVolter.Play_HANS_Grenade2_Base')
	DialogEvents[`HANS_NadeBarrage]=(DefaultAudioCue=AkEvent'WW_VOX_NPC_HansVolter.Play_HANS_GrenadeBrg_Base')
	DialogEvents[`HANS_KillNade]=(DefaultAudioCue=AkEvent'WW_VOX_NPC_HansVolter.Play_HANS_GrenadeKill_Base')
	DialogEvents[`HANS_AmbBreathe]=(DefaultAudioCue=AkEvent'WW_VOX_NPC_HansVolter.Play_HANS_Breathing_Base')
	DialogEvents[`HANS_AmbBreathe_LT25]=(DefaultAudioCue=AkEvent'WW_VOX_NPC_HansVolter.Play_HANS_BreathHurt_Base')

	DialogEvents[`HANS_NextBattlePhase1]=(DefaultAudioCue=AkEvent'WW_VOX_NPC_HansVolter.Play_HANS_Ph2Start_Base')
	DialogEvents[`HANS_NextBattlePhase2]=(DefaultAudioCue=AkEvent'WW_VOX_NPC_HansVolter.Play_HANS_Ph3Start_Base')
	DialogEvents[`HANS_NextBattlePhase3]=(DefaultAudioCue=AkEvent'WW_VOX_NPC_HansVolter.Play_HANS_Ph4Start_Base')
	DialogEvents[`HANS_AOE]=(DefaultAudioCue=AkEvent'WW_VOX_NPC_HansVolter.Play_HANS_Nerve2_Base')

`if(`notdefined(ShippingPC))
	DialogEventNames[`BOSS_TauntBase]           =BOSS_TauntBase      
	DialogEventNames[`BOSS_Taunt_LT50]          =BOSS_Taunt_LT50     
	DialogEventNames[`BOSS_Taunt_LT25]          =BOSS_Taunt_LT25     
	DialogEventNames[`BOSS_Challenge]           =BOSS_Challenge      
	DialogEventNames[`BOSS_LoseTarget]          =BOSS_LoseTarget     
	DialogEventNames[`BOSS_Melee]               =BOSS_Melee          
	DialogEventNames[`BOSS_Grab]                =BOSS_Grab           
	DialogEventNames[`BOSS_Heal]                =BOSS_Heal           
	DialogEventNames[`BOSS_TakeDmgBase]         =BOSS_TakeDmgBase    
	DialogEventNames[`BOSS_TakeDmg_LT25]        =BOSS_TakeDmg_LT25   
	DialogEventNames[`BOSS_Death]               =BOSS_Death          
	DialogEventNames[`BOSS_KillBase]            =BOSS_KillBase       
	DialogEventNames[`BOSS_Jump]                =BOSS_Jump           
	DialogEventNames[`BOSS_Land]                =BOSS_Land           
	DialogEventNames[`HANS_Taunt_LT25_RO2]      =HANS_Taunt_LT25_RO2 
	DialogEventNames[`HANS_SprintToward]        =HANS_SprintToward   
	DialogEventNames[`HANS_DrawGuns]            =HANS_DrawGuns       
	DialogEventNames[`HANS_DmgGuns]             =HANS_DmgGuns        
	DialogEventNames[`HANS_KillGuns]            =HANS_KillGuns       
	DialogEventNames[`HANS_Frenzy]              =HANS_Frenzy         
	DialogEventNames[`HANS_KillFrenzy]          =HANS_KillFrenzy     
	DialogEventNames[`HANS_GasToss]             =HANS_GasToss        
	DialogEventNames[`HANS_GasBarrage]          =HANS_GasBarrage     
	DialogEventNames[`HANS_KillGas]             =HANS_KillGas        
	DialogEventNames[`HANS_SmokeToss]           =HANS_SmokeToss      
	DialogEventNames[`HANS_SmokeBarrage]        =HANS_SmokeBarrage   
	DialogEventNames[`HANS_HuntTaunt]           =HANS_HuntTaunt      
	DialogEventNames[`HANS_NadeToss]            =HANS_NadeToss       
	DialogEventNames[`HANS_NadeBarrage]         =HANS_NadeBarrage    
	DialogEventNames[`HANS_KillNade]            =HANS_KillNade       
	DialogEventNames[`HANS_AmbBreathe]          =HANS_AmbBreathe     
	DialogEventNames[`HANS_NextBattlePhase1]    =HANS_NextBattlePhase1
	DialogEventNames[`HANS_NextBattlePhase2]    =HANS_NextBattlePhase2
	DialogEventNames[`HANS_NextBattlePhase3]    =HANS_NextBattlePhase3
	DialogEventNames[`HANS_AOE]    				=HANS_AOE
`endif
}

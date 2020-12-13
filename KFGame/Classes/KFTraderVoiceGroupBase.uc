class KFTraderVoiceGroupBase extends Object;

`include(KFGame/KFGameDialog.uci)

struct TraderDialogEventInfo
{
    var int     EventID;
    var AkEvent AudioCue;
    var byte    Priority;
    var float   CoolDown;
	var float	Chance;

	structdefaultproperties
	{
		Chance=1.f
	}
};

var TraderDialogEventInfo   DialogEvents[`TRADER_DIALOG_COUNT];
var name                    EventNames[`TRADER_DIALOG_COUNT];

defaultproperties
{
    EventNames[`TRAD_Wave20pctDead]=                 TRAD_Wave20pctDead
    EventNames[`TRAD_Wave80pctDead]=                 TRAD_Wave80pctDead
    EventNames[`TRAD_WaveLastZedDies]=               TRAD_WaveLastZedDies
    EventNames[`TRAD_Close]=                         TRAD_Close
    EventNames[`TRAD_PlayerArrive]=                  TRAD_PlayerArrive
    EventNames[`TRAD_ClickTooExpensive]=             TRAD_ClickTooExpensive
    EventNames[`TRAD_ClickTooHeavy]=                 TRAD_ClickTooHeavy
    EventNames[`TRAD_30SecLeft]=                     TRAD_30SecLeft
    EventNames[`TRAD_10SecLeft]=                     TRAD_10SecLeft
    EventNames[`TRAD_FinalShopWave]=                 TRAD_FinalShopWave
    EventNames[`TRAD_PlayerFarAway]=                 TRAD_PlayerFarAway
    EventNames[`TRAD_NoArmor]=                       TRAD_NoArmor
    EventNames[`TRAD_LowArmor]=                      TRAD_LowArmor
    EventNames[`TRAD_LowAmmo]=                       TRAD_LowAmmo
    EventNames[`TRAD_NoNades]=                       TRAD_NoNades
    EventNames[`TRAD_NeedToHeal]=                    TRAD_NeedToHeal
    EventNames[`TRAD_TeamNeedsHeal]=                 TRAD_TeamNeedsHeal
    EventNames[`TRAD_ShareDosh]=                     TRAD_ShareDosh
    EventNames[`TRAD_GoodJobHeal]=                   TRAD_GoodJobHeal
    EventNames[`TRAD_OnlySurvivor]=                  TRAD_OnlySurvivor
    EventNames[`TRAD_DiedLastWave]=                  TRAD_DiedLastWave
    EventNames[`TRAD_KilledMost]=                    TRAD_KilledMost
    EventNames[`TRAD_BestTeamPlayer]=                TRAD_BestTeamPlayer
    EventNames[`TRAD_SurviveMultWaves]=              TRAD_SurviveMultWaves
    EventNames[`TRAD_KeepDying]=                     TRAD_KeepDying
    EventNames[`TRAD_NoOneDies]=                     TRAD_NoOneDies
    EventNames[`TRAD_NoDamage]=                      TRAD_NoDamage
    EventNames[`TRAD_SomeDie]=                       TRAD_SomeDie
    EventNames[`TRAD_LT50pctDamTaken]=               TRAD_LT50pctDamTaken
    EventNames[`TRAD_HighDmgSurvivor]=               TRAD_HighDmgSurvivor
    EventNames[`TRAD_HighDmgHighHeal]=               TRAD_HighDmgHighHeal
    EventNames[`TRAD_EarnMostDosh]=                  TRAD_EarnMostDosh
    EventNames[`TRAD_KilledFleshpound]=              TRAD_KilledFleshpound
    EventNames[`TRAD_KilledScrake]=                  TRAD_KilledScrake
    EventNames[`TRAD_LittleDosh]=                    TRAD_LittleDosh
    EventNames[`TRAD_AdviceClotA]=                   TRAD_AdviceClotA
    EventNames[`TRAD_AdviceClotU]=                   TRAD_AdviceClotU
    EventNames[`TRAD_AdviceClotS]=                   TRAD_AdviceClotS
    EventNames[`TRAD_AdviceGorefast]=                TRAD_AdviceGorefast
    EventNames[`TRAD_AdviceGorefast2]=               TRAD_AdviceGorefast2
    EventNames[`TRAD_AdviceStalker]=                 TRAD_AdviceStalker
    EventNames[`TRAD_AdviceBloat]=                   TRAD_AdviceBloat
    EventNames[`TRAD_AdviceScrake]=                  TRAD_AdviceScrake
    EventNames[`TRAD_AdviceFleshpound]=              TRAD_AdviceFleshpound
    EventNames[`TRAD_AdviceSiren]=                   TRAD_AdviceSiren
    EventNames[`TRAD_AdviceHusk]=                    TRAD_AdviceHusk
    EventNames[`TRAD_AdvicePatriarch]=               TRAD_AdvicePatriarch
    EventNames[`TRAD_AdviceHans]=                    TRAD_AdviceHans
    EventNames[`TRAD_AdviceMatriarch]=               TRAD_AdviceMatriarch
    EventNames[`TRAD_ObjDefendT]=                    TRAD_ObjDefendT
    EventNames[`TRAD_ObjDefendTWon]=                 TRAD_ObjDefendTWon
    EventNames[`TRAD_ObjDefendTDeclined]=            TRAD_ObjDefendTDeclined
    EventNames[`TRAD_ObjDefendTFailed]=              TRAD_ObjDefendTFailed
    EventNames[`TRAD_ObjDefendTs]=                   TRAD_ObjDefendTs
    EventNames[`TRAD_ObjDefendTsWon]=                TRAD_ObjDefendTsWon
    EventNames[`TRAD_ObjDefendTsDeclined]=           TRAD_ObjDefendTsDeclined
    EventNames[`TRAD_ObjDefendTsFailed]=             TRAD_ObjDefendTsFailed
    EventNames[`TRAD_ObjDefendA]=                    TRAD_ObjDefendA
    EventNames[`TRAD_ObjDefendAWon]=                 TRAD_ObjDefendAWon
    EventNames[`TRAD_ObjDefendADeclined]=            TRAD_ObjDefendADeclined
    EventNames[`TRAD_ObjDefendAFailed]=              TRAD_ObjDefendAFailed
    EventNames[`TRAD_ObjDefendAs]=                   TRAD_ObjDefendAs
    EventNames[`TRAD_ObjDefendAsWon]=                TRAD_ObjDefendAsWon
    EventNames[`TRAD_ObjDefendAsDeclined]=           TRAD_ObjDefendAsDeclined
    EventNames[`TRAD_ObjDefendAsFailed]=             TRAD_ObjDefendAsFailed
    EventNames[`TRAD_ObjHackTerm]=                   TRAD_ObjHackTerm
    EventNames[`TRAD_ObjHackTermWon]=                TRAD_ObjHackTermWon
    EventNames[`TRAD_ObjHackTermDeclined]=           TRAD_ObjHackTermDeclined
    EventNames[`TRAD_ObjHackTermFailed]=             TRAD_ObjHackTermFailed
    EventNames[`TRAD_ObjHackTerms]=                  TRAD_ObjHackTerms
    EventNames[`TRAD_ObjHackTermsWon]=               TRAD_ObjHackTermsWon
    EventNames[`TRAD_ObjHackTermsDeclined]=          TRAD_ObjHackTermsDeclined
    EventNames[`TRAD_ObjHackTermsFailed]=            TRAD_ObjHackTermsFailed
    EventNames[`TRAD_ObjDownload]=                   TRAD_ObjDownload
    EventNames[`TRAD_ObjDownloadWon]=                TRAD_ObjDownloadWon
    EventNames[`TRAD_ObjDownloadDeclined]=           TRAD_ObjDownloadDeclined
    EventNames[`TRAD_ObjDownloadFailed]=             TRAD_ObjDownloadFailed
    EventNames[`TRAD_ObjRepairT]=                    TRAD_ObjRepairT
    EventNames[`TRAD_ObjRepairTWon]=                 TRAD_ObjRepairTWon
    EventNames[`TRAD_ObjRepairTDeclined]=            TRAD_ObjRepairTDeclined
    EventNames[`TRAD_ObjRepairTFailed]=              TRAD_ObjRepairTFailed
    EventNames[`TRAD_ObjRepairTs]=                   TRAD_ObjRepairTs
    EventNames[`TRAD_ObjRepairTsWon]=                TRAD_ObjRepairTsWon
    EventNames[`TRAD_ObjRepairTsDeclined]=           TRAD_ObjRepairTsDeclined
    EventNames[`TRAD_ObjRepairTsFailed]=             TRAD_ObjRepairTsFailed
    EventNames[`TRAD_ObjEscVIP]=                     TRAD_ObjEscVIP
    EventNames[`TRAD_ObjEscVIPWon]=                  TRAD_ObjEscVIPWon
    EventNames[`TRAD_ObjEscVIPDeclined]=             TRAD_ObjEscVIPDeclined
    EventNames[`TRAD_ObjEscVIPFailed]=               TRAD_ObjEscVIPFailed
    EventNames[`TRAD_ObjEscVIPs]=                    TRAD_ObjEscVIPs
    EventNames[`TRAD_ObjEscVIPsWon]=                 TRAD_ObjEscVIPsWon
    EventNames[`TRAD_ObjEscVIPsDeclined]=            TRAD_ObjEscVIPsDeclined
    EventNames[`TRAD_ObjEscVIPsFailed]=              TRAD_ObjEscVIPsFailed
    EventNames[`TRAD_ObjCollItem]=                   TRAD_ObjCollItem
    EventNames[`TRAD_ObjCollItemWon]=                TRAD_ObjCollItemWon
    EventNames[`TRAD_ObjCollItemDeclined]=           TRAD_ObjCollItemDeclined
    EventNames[`TRAD_ObjCollItemFailed]=             TRAD_ObjCollItemFailed
    EventNames[`TRAD_ObjCollItems]=                  TRAD_ObjCollItems
    EventNames[`TRAD_ObjCollItemsWon]=               TRAD_ObjCollItemsWon
    EventNames[`TRAD_ObjCollItemsDeclined]=          TRAD_ObjCollItemsDeclined
    EventNames[`TRAD_ObjCollItemsFailed]=            TRAD_ObjCollItemsFailed
}

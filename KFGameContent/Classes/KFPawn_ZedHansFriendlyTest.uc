//=============================================================================
// KFPawn_ZedHansFriendlyTest
//=============================================================================
// Hans Boss Pawn Class that will target zeds not players - for testing
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFPawn_ZedHansFriendlyTest extends KFPawn_ZedHans;

/** Can this pawn be grabbed by Zed performing grab special move (clots & Hans's energy drain) */
function bool CanBeGrabbed(KFPawn GrabbingPawn, optional bool bIgnoreFalling, optional bool bAllowSameTeamGrab)
{
    return false;
}

defaultproperties
{
	CharacterMonsterArch=KFCharacterInfo_Monster'ZED_Hans_ARCH.ZED_Hans_Benchmark_Archetype'

	// ---------------------------------------------
	// AI / Navigation
	ControllerClass=class'KFGameContent.KFAIController_HansFriendlyTest'

    BattlePhases(0)=(bCanFrenzy=true, bCanTossNerveGas=false, bCanBarrageNerveGas=false, bCanUseGuns=true, bCanTossGrenade=true, bCanBarrageGrenades=false)
    BattlePhases(1)=(bCanFrenzy=true, bCanTossNerveGas=false, bCanBarrageNerveGas=false, bCanUseGuns=true, bCanTossGrenade=false, bCanBarrageGrenades=false)
    BattlePhases(2)=(bCanFrenzy=true, bCanTossNerveGas=false, bCanBarrageNerveGas=false, bCanUseGuns=true, bCanTossGrenade=false, bCanBarrageGrenades=false)
    BattlePhases(3)=(bCanFrenzy=true, bCanTossNerveGas=false, bCanBarrageNerveGas=false, bCanUseGuns=true, bCanTossGrenade=false, bCanBarrageGrenades=false)

    DefaultInventory(0)=class'KFWeap_AssaultRifle_DualMKb42_HansFriendlyTest'
    Health=99999
}

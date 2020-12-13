//=============================================================================
// KFPawn_Human
//=============================================================================
// KF Pawn for human characters
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Andrew "Strago" Ladenberger
//=============================================================================

class KFPawn_Human_Versus extends KFPawn_Human;

simulated function SetCharacterArch( KFCharacterInfoBase Info, optional bool bForce )
{
    super.SetCharacterArch( Info, bForce );

    UpdateGameplayMICParams();
}

/** Reapply active gameplay related MIC params (e.g. when switching to the gore mesh) */
simulated function UpdateGameplayMICParams()
{
    local PlayerController PC;
    local MaterialInstanceConstant MIC;
    
    super.UpdateGameplayMICParams();

    if( WorldInfo.NetMode != NM_DedicatedServer )
    {
        PC = GetALocalPlayerController();
        if( PC != none )
        {
            foreach CharacterMICs(MIC)
            {
                MIC.SetScalarParameterValue( 'Scalar_Zedbait', PC.GetTeamNum() == 255 ? 1.f : 0.f );
            }
        }
    }
}

/** Update team highlight */
simulated function NotifyLocalPlayerTeamReceived()
{    
    UpdateGameplayMICParams();   
}

defaultproperties
{
    // ---------------------------------------------
    // Special Moves
    Begin Object Name=SpecialMoveHandler_0
        SpecialMoveClasses(SM_SirenVortexVictim)=class'KFSM_PlayerSiren_VortexVictim'
    End Object
}
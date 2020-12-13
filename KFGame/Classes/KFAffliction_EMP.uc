//=============================================================================
// KFAfflication_EMP
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFAffliction_EMP extends KFAfflictionAdvanced;

/** On EMP Panic Effect Template */
var protected ParticleSystem				EmpPanicTemplate;
/** EMP Panic Particle System Component */
var protected ParticleSystemComponent		EMPPanicEffect;
/** On EMP Disrupt Template */
var protected ParticleSystem				EmpDisruptTemplate;
/** EMP Disrupt Effect Particle System Component, this is smaller and exists on a disrupted weapon like the husks gun */
var protected ParticleSystemComponent		EMPDisruptEffect;

/** The location of EMP Disrupt, this is a smaller effect that should exist on a disrupted weapon like the husks gun */
var protected name                        	EMPDisruptSocketName;

/** Sound to play when this pawn has been EMP'd */
var protected AkEvent OnEMPSound;
/** Sound to play when this pawn stops being EMP'd */
var protected AkEvent OnEMPEndSound;

function Activate()
{
	Super.Activate();
	SetEMPPanicked(true);
}

function DeActivate()
{
	Super.DeActivate();
	SetEMPPanicked(false);
}

function Shutdown()
{
	super.Shutdown();

	// Make sure all effects are off
	ToggleEffects( false, false );	
}

/** Set the EMP disrupt functionality */
function SetEMPPanicked(bool bEnabled)
{
    if( PawnOwner.Role == ROLE_Authority )
    {
    	if( PawnOwner.bEmpPanicked == bEnabled )
    	{
    		return;
    	}

        PawnOwner.bEmpPanicked = bEnabled;
        PawnOwner.OnStackingAfflictionChanged(AF_EMP);
    }
    ToggleEffects(PawnOwner.bEmpDisrupted, PawnOwner.bEmpPanicked);
}

/** Enable/Disable the EMP overlay effect */
function ToggleEffects(bool bDisrupted, optional bool bPanicked)
{
	if ( PawnOwner.WorldInfo.NetMode != NM_DedicatedServer )
	{
		if( bDisrupted )
		{
			if( EMPDisruptEffect == none )
			{
	    		EMPDisruptEffect = PawnOwner.WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(EmpDisruptTemplate, PawnOwner.Mesh, EMPDisruptSocketName, true);
			}
		}
		else if( EMPDisruptEffect != none )
		{
			PawnOwner.DetachEmitter( EMPDisruptEffect );
		}

		if( bPanicked && EMPPanicEffect == none )
		{
        	PawnOwner.PlaySoundBase(OnEMPSound, true, true, true);
	    	EMPPanicEffect = PawnOwner.WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(EMPPanicTemplate, PawnOwner.Mesh, EffectSocketName, false);
		}
		else if( EMPPanicEffect != none )
		{
        	PawnOwner.PlaySoundBase(OnEMPEndSound, true, true );
        	PawnOwner.DetachEmitter( EMPPanicEffect );
		}

		SetEMPMatParam(bDisrupted, bPanicked);
    }
}

/** Enable/Disable the EMP overlay effect */
protected function SetEMPMatParam(bool bDisrupted, bool bPanicked)
{
	local MaterialInstanceConstant MIC;
	local float Value;

	if ( PawnOwner.WorldInfo.NetMode != NM_DedicatedServer )
	{
        if( bPanicked )
	    {
           Value = 5.0;
        }
        else if( bDisrupted )
        {
           Value = 1.0;
        }

        foreach PawnOwner.CharacterMICs(MIC)
	    {
			MIC.SetScalarParameterValue('Scalar_EMP', Value);
	    }
    }
}

defaultproperties
{
	DissipationRate=50
	
    EMPDisruptSocketName=EMPDisruptSocket
	EmpDisruptTemplate=ParticleSystem'FX_Gameplay_EMIT.Chr.FX_CHR_Weapon_Disable_Emp'
	EmpPanicTemplate=ParticleSystem'FX_Gameplay_EMIT.FX_Char_Emp_clot'
    OnEMPSound=AkEvent'WW_WEP_EXP_Grenade_EMP.Play_WEP_EXP_Grenade_EMP_Shock_LP'
    OnEMPEndSound=AkEvent'WW_WEP_EXP_Grenade_EMP.Stop_WEP_EXP_Grenade_EMP_Shock_LP'
}

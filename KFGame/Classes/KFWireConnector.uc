//=============================================================================
// KFWireConnector
//=============================================================================
// Beam emitter wire system along with KFWireStart
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//============================================================================
class KFWireConnector extends Emitter
	notplaceable
	native(Effect);

/** Beam tangent at source and target locations.  Typically one is negative of other */
var() vector StartTangent;
var() vector EndTangent;

// @todo: SetBeamTessellationFactor() is missing implementation!
var float TessellationFactor;

cpptext
{
	// For editor preview of beam properties
	virtual void PostEditChangeProperty(FPropertyChangedEvent& PropertyChangedEvent);
	virtual void PostEditChangeChainProperty( struct FPropertyChangedChainEvent& PropertyChangedEvent );

	// Apply custom beam properties
	virtual void EditorSelectionChange( UBOOL bSelected );

	/** Fix up source/target actors */
	virtual void PostDuplicate();
};

/** One-time init */
native function ApplyBeamProperties();

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	// If Super didn't sentence us to death
	if ( !bTickIsDisabled )
	{
		ApplyBeamProperties();

		// Frame delay. After the PSC has been updated once we're 
		// basically static geometry and can stop ticking
		SetTimer(0.01f, false);
	}
}

// Disable tick after one frame
simulated function Timer()
{
	SetTickIsDisabled(true);
}

defaultproperties
{
	Begin Object Name=Sprite
		Sprite=Texture2D'FX_Environmental_TEX.WireTool.KF_WireTool_Icon'
	End Object

	Begin Object Name=ParticleSystemComponent0
		Template=ParticleSystem'FX_Environmental_EMIT_TWO.FX_Cable_beam_01'
		InstanceParameters(0)={(Name=WireStart,	ParamType=PSPT_Actor)}
		InstanceParameters(1)={(Name=WireEnd, ParamType=PSPT_Actor)}
	End Object

	// remove some things we don't need from Emitter.uc
	SupportedEvents.Empty
	Components.Remove(ArrowComponent0)
	//Components.Remove(ParticleSystemComponent0)
}

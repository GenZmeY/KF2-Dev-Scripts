//=============================================================================
// KFWireStart
//=============================================================================
// Beam emitter wire system along with KFWireConnector
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//============================================================================
class KFWireStart extends Keypoint
	placeable
	native(Effect);

cpptext
{
	/** Fix up source/target actors */
	virtual void PostDuplicate();
};

defaultproperties
{
	Begin Object Name=Sprite
		Sprite=Texture2D'FX_Environmental_TEX.WireTool.KF_WireTool_Icon'
	End Object
}

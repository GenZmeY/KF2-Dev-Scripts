//=============================================================================
// KFSpawnRenderingComponent
//=============================================================================
// Handles rendering debug lines for spawn volumes (see show_spawnvolumes)
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFSpawnRenderingComponent extends PrimitiveComponent
	native
	hidecategories(Object)
	editinlinenew;

cpptext
{
	virtual FPrimitiveSceneProxy* CreateSceneProxy();
	virtual void UpdateBounds();
};


defaultproperties
{
	bAcceptsLights=false
	HiddenGame=true
	AlwaysLoadOnClient=false
	AlwaysLoadOnServer=false
}

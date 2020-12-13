//=============================================================================
// KFGibletInfo
//=============================================================================
// Used to specify giblet info in the archetype
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Sakib Saikia 8/14/2014
//=============================================================================

class KFGibletInfo extends Object
	hidecategories(Object)
	editinlinenew;

/** If the gib uses a static mesh, specify the mesh here */
var() StaticMesh GibStaticMesh;
/** If the gib uses a skeletal mesh, specify the mesh here */
var() SkeletalMesh GibSkelMesh;
/** If the gib uses a skeletal mesh, specify the physics asset here */
var() PhysicsAsset GibPhysAsset;
/** If > 0, overrides the MaxDrawDistance for the spawned gib */
var int CullDistance;
/** Optional scale to apply to the gibs **/
var() float DrawScale;
/** If more than zero, clamp this gibs max speed it will fly through the air to this amount **/
var() int GibletMaxSpeed;
/** What bone or bones in the zed's body did this gib correspond to **/
var() array<name> GibletBones;

defaultproperties
{
	DrawScale=1.0
	GibletMaxSpeed=1500
}

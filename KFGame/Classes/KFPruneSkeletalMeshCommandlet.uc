//=============================================================================
// KFPruneSkeletalMeshCommandlet
//=============================================================================
// Helper commandlet to prune a skeletal mesh. All the children bones of the
// passed in bone name are removed. The package is resaved after the operation.
//
// Usage : PruneSkeletalMesh [SkeletalMeshPath] [BoneName]
// Eg. : PruneSkeletalMesh SkeletalMeshCommandletTest.HumanIK.CHR_HUMANIK_MASTER_RIG  CHR_Head
//=============================================================================
// Killing Floor 2
// Copyright (C) 2007-2016 Tripwire Interactive LLC
// - Sakib Saikia
//=============================================================================
class KFPruneSkeletalMeshCommandlet extends Commandlet
	native;

cpptext
{
	// Remove all the bones of the mesh which are children of PruneBoneName
	UBOOL ModifyMesh(USkeletalMesh* Mesh, FString PruneHeadName, int lodIndex, bool inclusivePrune);

	// Helper functions to modify the mesh
	UBOOL GeneratePruneBoneList(USkeletalMesh* Mesh, TArray<BYTE>& OutPruneBones, FString PruneHeadName, bool inclusivePrune);
	void FixBoneHierarchy(USkeletalMesh* Mesh, const TArray<BYTE>& InPruneBones);
	void FixLOD(USkeletalMesh* Mesh, FStaticLODModel& LOD, const TArray<BYTE>& InPruneBones, FString PruneHeadName);
}

// Point of entry for the commandlet
native event int Main( string Params );

DefaultProperties
{
}

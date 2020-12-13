//=============================================================================
// TWFixupSplattermapUVCommandlet
//=============================================================================
// Helper commandlet to copy splattermap UVs from UVChannel 1 to UVChannel 2
//
// Usage : TWFixupSplattermapUV [PackageName]
// Eg. : TWFixupSplattermapUV ENV_BioticsLab_Mesh
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Sakib Saikia 3/4/2014
//=============================================================================

class TWFixupSplattermapUVCommandlet extends Commandlet
	native;

cpptext
{
	// Copy Splattermap UVs (if exits) from UV Channel 1 to UV Channel 2
	UBOOL CopySplattermapUVs(UStaticMesh* Mesh);
}


// Point of entry for the commandlet
native event int Main( string Params );

DefaultProperties
{
}

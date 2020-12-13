//=============================================================================
// TWGenerateLightmapUVCommandlet
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Author 3/7/2014
//=============================================================================

class TWGenerateLightmapUVCommandlet extends Commandlet
	native;

var int 	LightmapUVChannel;
var float 	MinChartSpacingPercent;
var float 	BorderSpacingPercent;
var bool 	bUseMaxStretch;

cpptext
{
	// Generate UV Atlas for lightmap UVs
	UBOOL GenerateLightmapUVs(UStaticMesh* Mesh);
}


// Point of entry for the commandlet
native event int Main( string Params );

DefaultProperties
{
	LightmapUVChannel=1
	MinChartSpacingPercent=1.0
	BorderSpacingPercent=0.0
	bUseMaxStretch=true
}

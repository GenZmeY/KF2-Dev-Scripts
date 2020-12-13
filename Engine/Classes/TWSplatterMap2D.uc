//=============================================================================
// TWSplatterMap2D
//=============================================================================
// Class that encapsulates the splatter map data and how to access it.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Sakib Saikia 6/27/2013
//=============================================================================

class TWSplatterMap2D extends Object
	native
	noexport;

/** The texture which contains the splatter-map data. */
var() private const editconst TWSplatterMapTexture2D Texture;

/** The scale which is applied to the splatter-map coordinates before sampling the splatter-map textures. */
var() private const editconst Vector2D CoordinateScale;

/** The bias which is applied to the splatter-map coordinates before sampling the splatter-map textures. */
var() private const editconst Vector2D CoordinateBias;




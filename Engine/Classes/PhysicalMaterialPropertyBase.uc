/**
 * This is the PhysicalMaterialPropertyBase which the PhysicalMaterial has.
 * Individual games should derive their own MyGamPhysicalMaterialProperty.
 *
 * Then inside that object you can either have a bunch of properties or have it 
 * point to your game specific objects.
 *
 * (e.g.  You have have impact sounds and impact effects for all of the weapons
 * in your game.  So you have an .uc object which contains the data needed per
 * material type and then you have your MyGamePhysicalMaterialProperty point to 
 * that. )
 *
 * class MyGamePhysicalMaterialProperty extends PhysicalMaterialPropertyBase
 *    editinlinenew;
 *
 * var() editinline MyGameSpecificImpactEffects ImpactEffects;
 * var() editinline MyGameSpecificImpactSounds ImpactSounds;
 *
 * Copyright 1998-2013 Epic Games, Inc. All Rights Reserved.
 */

class PhysicalMaterialPropertyBase extends Object
	native(Physics)
	collapsecategories
	hidecategories(Object)
	editinlinenew
	abstract;

`if(`__TW_)

// This is game specific, but adding it here allows us to access it from engine (see PhysXParticleImpactInfo).
// It also means we can remove casts to KFPhysicalMaterialProperty.  Keeping KFPhysicsMaterialProperty
// around so that our content does not need updated and because this class is marked abstract

/** Type of material this is (dirt, gravel, brick, etc) used for looking up material specific effects */
var() enum EMaterialTypes
{
	EMT_None,
	EMT_Rock,
	EMT_Dirt,
	EMT_Dust,
	EMT_Mud,
	EMT_Poop,
	EMT_Grass,
	EMT_Plant,
	EMT_Water,
    EMT_WaterShallow,
    EMT_Ice,
    EMT_Snow,
	EMT_Metal,
	EMT_MetalHollow,
	EMT_MetalArmor,
	EMT_Wood,
	EMT_WoodHollow,
    EMT_BrickRed,
    EMT_BrickWhite,
	EMT_Plaster,
    EMT_Glass,
	EMT_GlassBroken,
    EMT_Gravel,
    EMT_Concrete,
    EMT_ConcreteWet,
    EMT_Paper,
    EMT_Cloth,
    EMT_Rubber,
    EMT_Asphalt,
	EMT_Flesh,
	EMT_PlasticBag,
    EMT_Sand,
	EMT_Lava,
    EMT_Custom0,
    EMT_Custom1,
    EMT_Custom2,
    EMT_Custom3,
    EMT_Custom4,
} MaterialType;

`endif

defaultproperties
{
}

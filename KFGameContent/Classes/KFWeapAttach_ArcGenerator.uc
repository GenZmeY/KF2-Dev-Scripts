//=============================================================================
// KFWeapAttach_ArcGenerator
//=============================================================================
// A custom 3rd person weapon template for the ArcGenerator
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFWeapAttach_ArcGenerator extends KFWeapAttach_SprayBase;

simulated function ChangeMaterial()
{
	if( BarrelHeat != LastBarrelHeat )
	{
	    WeaponMIC.SetScalarParameterValue('Glow_Intensity', 1);
	}
}

defaultproperties
{

}


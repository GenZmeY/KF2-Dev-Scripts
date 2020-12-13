// NVCHANGE_BEGIN: TSC -  adding module for spawning force fields
/**
 * Copyright 1998-2011 Epic Games, Inc. All Rights Reserved.
 */
class ParticleModuleForceFieldCylindrical extends ParticleModuleForceFieldBase;

defaultproperties
{
	Begin Object Class=NxForceFieldCylindricalComponent Name=FF
	End Object
	ForceField = FF
}

// NVCHANGE_END: TSC -  adding module for spawning force fields

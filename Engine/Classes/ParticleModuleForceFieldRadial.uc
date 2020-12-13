// NVCHANGE_BEGIN: TSC -  adding module for spawning force fields
/**
 * Copyright 1998-2011 Epic Games, Inc. All Rights Reserved.
 */
class ParticleModuleForceFieldRadial extends ParticleModuleForceFieldBase;

defaultproperties
{
	Begin Object Class=NxForceFieldRadialComponent Name=FF
		Duration = 0.5;
	End Object
	ForceField = FF
}

// NVCHANGE_END: TSC -  adding module for spawning force fields

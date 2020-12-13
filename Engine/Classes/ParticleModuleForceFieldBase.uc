// NVCHANGE_BEGIN: TSC - adding module for spawning force fields
/**
 * Copyright 1998-2011 Epic Games, Inc. All Rights Reserved.
 */
class ParticleModuleForceFieldBase extends ParticleModule
	native(Particle)
	editinlinenew
	hidecategories(Object)
	abstract;

var(ForceFieldComponent) NxForceFieldComponent ForceField;


event NxForceFieldComponent GetForceFieldInstance(vector Location)
{
	local NxForceFieldComponent FF;

	FF = new ForceField.Class(ForceField);
	FF.SetTickGroup(TG_PostAsyncWork);

	// the FF needs to be colocated with the particle system component (Location), in case its offset
	FF.SetTranslation(Location + FF.Translation);
	
	return FF;
}

cpptext
{
	struct FPayload
	{
		BOOL bSpawned;
		FLOAT LastTime;
	};

	virtual UINT	RequiredBytesPerInstance(FParticleEmitterInstance* Owner = NULL);
	virtual UINT	PrepPerInstanceBlock(FParticleEmitterInstance* Owner, void* InstData);

	virtual void Spawn(FParticleEmitterInstance* Owner, INT Offset, FLOAT SpawnTime);
	virtual void Update(FParticleEmitterInstance* Owner, INT Offset, FLOAT DeltaTime);
}


defaultproperties
{
	bSpawnModule=true
	bUpdateModule=true
}

// NVCHANGE_END: TSC -  adding module for spawning force fields

/**
 * Copyright 1998-2012 Epic Games, Inc. All Rights Reserved.
 */
class ParticleModuleFlexSpawn extends ParticleModuleSpawnBase
	native(Particle)
	editinlinenew
	hidecategories(Object)
	hidecategories(ParticleModuleSpawnBase);

	struct native FlexInstancePayload
	{
		var float LayerLeftOver;
		var int LayerIndex;
	};

	/** The number of particles to emit horizontally  */
	var(Spawn)	int DimX;

	/** The number of particles to emit vertically */
	var(Spawn)	int DimY;

	/** Velocity to emit particles with, note that this increases the required spawn rate */
	var(Velocity) float Velocity;

cpptext
{
	// Begin UParticleModuleSpawnBase Interface
	virtual UBOOL GetSpawnAmount(FParticleEmitterInstance* Owner, INT Offset, FLOAT OldLeftover, FLOAT DeltaTime, INT& Number, FLOAT& Rate);
	virtual UBOOL GetBurstCount(FParticleEmitterInstance* Owner, INT Offset, FLOAT OldLeftover, FLOAT DeltaTime, INT& Number);
	// End UParticleModuleSpawnBase Interface

	// Begin UParticleModule Interface
	virtual UINT	RequiredBytesPerInstance(FParticleEmitterInstance* Owner = NULL);
	virtual UINT	PrepPerInstanceBlock(FParticleEmitterInstance* Owner, void* InstData);
	virtual void Spawn(FParticleEmitterInstance* Owner, INT Offset, FLOAT SpawnTime);
	virtual void	Update(FParticleEmitterInstance* Owner, INT Offset, FLOAT DeltaTime);
	// End UParticleModule Interface

}

defaultproperties
{
	bSpawnModule = true
	bSupported3DDrawMode = false
	DimX = 4
	DimY = 4
	Velocity = 0.0f
}

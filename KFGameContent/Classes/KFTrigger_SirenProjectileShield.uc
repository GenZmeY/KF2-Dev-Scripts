//=============================================================================
// KFTrigger_SirenProjectileShield
//=============================================================================
// Spawned during scream attack, disintegrates incoming projectiles
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFTrigger_SirenProjectileShield extends Trigger;

var KFPawn_Monster Siren;

event BaseChange()
{
	Super.BaseChange();

	Siren = KFPawn_Monster(Base);
}

event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
	local KFProjectile KFProj;

	KFProj = KFProjectile(Other);
	if( KFProj != none && !KFProj.bDeleteMe && KFProj.bCanDisintegrate && !KFProj.bHasDisintegrated )
	{
		KFProj.Disintegrate( rotator(-Velocity) );
		return;
	}

	super.Touch( Other, OtherComp, HitLocation, HitNormal );
}

simulated function bool StopsProjectile(Projectile P)
{
	return !bDeleteMe && bBlockActors;
}

defaultproperties
{
	bStatic=false
	bNoDelete=false

	Begin Object Name=CollisionCylinder
		CollisionRadius=120.0
		CollisionHeight=120.0
	End Object
}
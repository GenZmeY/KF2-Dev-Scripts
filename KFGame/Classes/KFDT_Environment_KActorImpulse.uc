//=============================================================================
// KFDT_Environment_KActorImpulse
//=============================================================================
// Damage type used only for physics actor (e.g. CanBecomeDynamic) impulses
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFDT_Environment_KActorImpulse extends KFDamageType
	abstract;

defaultproperties
{
	bCausedByWorld=true
	RadialDamageImpulse=1000.f
	KDamageImpulse=0
}

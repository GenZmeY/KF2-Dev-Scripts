/*=============================================================================
	ActorFactoryFlexForceField.uc: Implement Flex force field Actor Factory
	Copyright 2008-2011 NVIDIA corporation..
=============================================================================*/
class ActorFactoryFlexForceField extends ActorFactory
	config(Editor)
	DontCollapseCategories
	native(Physics);

/** Rotational field strength */
var(ForceField)	float	RotationalFieldStrength;
/** Radial field strength */
var(ForceField)	float	RadialFieldStrength;
/** Lift field strength */
var(ForceField)	float	LiftFieldStrength;

/** Height of capsule field */
var(ForceField)	float	CapsuleFieldHeight <ClampMin=0.0>;
/** Bottom radius of capsule field */
var(ForceField)	float	CapsuleFieldBottomRadius <ClampMin=0.0>;
/** Top radius of capsule field */
var(ForceField)	float	CapsuleFieldTopRadius <ClampMin=0.0>;
/** Percentage of distance from boundary to center where fade out starts */
var(ForceField)	float	BoundaryFadePercentage <ClampMin=0.0 | ClampMax=1.0>;

/** Percentage of noise applied to force field. 0 = None 1 = Infinite */
var(ForceField)	float	Noise <ClampMin=0.0 | ClampMax=1.0>;

cpptext
{
	virtual AActor* CreateActor( const FVector* const Location, const FRotator* const Rotation, const class USeqAct_ActorFactory* const ActorFactoryData );
	virtual FString GetMenuName();
}

defaultproperties
{
	RotationalFieldStrength = 750
	RadialFieldStrength = -400
	LiftFieldStrength = 0.0
	
	CapsuleFieldHeight = 200.0;
	CapsuleFieldBottomRadius = 100.0;
	CapsuleFieldTopRadius = 50.0;
	
	BoundaryFadePercentage = 0.1

	Noise = 0.0

	MenuName="Add FlexForceField"
	NewActorClass=class'Engine.FlexForceFieldActor'
}
